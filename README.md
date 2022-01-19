PoC Trend Micro Deep Security Agent (CVE-2022-23119, CVE-2022-23120)
This repository contains proof of concept (PoC) bash scripts to perform the attacks described in [MZ-21-02](https://www.modzero.com/advisories/MZ-21-02-Trendmicro.txt).

## PoC Arbitrary File Read / Directory Traversal
1. Download [Deep Security Agent 20.0.0-2740 for Ubuntu_20.04-x86_64 (20 LTS Update 2021-07-29)](https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_20.04-20.0.0-2740.x86_64.zip)
2. Verify SHA256 checksum: `183ea8a2240028aa9cfedd3f3733c9ff61aa108d8a456855f79256463530567b`
3. `unzip Agent-Ubuntu_20.04-20.0.0-2921.x86_64.zip`
4. `dpkg -i Agent-Core-Ubuntu_20.04-20.0.0-2921.x86_64.deb`
5. Locate the file `/opt/ds_agent/lib/dsa_core.so` and transfer it to a different machine in the same network
6. On this remote machine run `./poc_file_read.sh` demonstrating an attack.

## PoC Local Privilege Escalation
1. Download either (both versions are vulnerable)
    1. [Deep Security Agent 20.0.0-2740 for Ubuntu_20.04-x86_64 (20 LTS Update 2021-07-29)](https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_20.04-20.0.0-2740.x86_64.zip): `183ea8a2240028aa9cfedd3f3733c9ff61aa108d8a456855f79256463530567b`
    3. [Deep Security Agent 20.0.0-2921 for Ubuntu_20.04-x86_64 (20 LTS Update 2021-08-30)](https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_20.04-20.0.0-2921.x86_64.zip): `3f10d2be96b167151c471399e158fe6ac5268d2babc0d188d52b5974b4d50b21`
2. Run `./poc_priv_esc.sh` locally as an unprivileged user
