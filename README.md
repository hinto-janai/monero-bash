# monero-bash
>a wrapper for Monero written in Bash, for Linux

![monero-bash.png](https://i.ibb.co/x8zcf7p/monero-bash.png)

## Contents
* [About](#About)
* [Features](#Features)
* [Install](#Install)
* [Usage](#Usage)
* [FAQ](#FAQ)

## About
monero-bash is a wrapper/manager for:

* [`monerod`](https://github.com/monero-project/monero)
* [`monero-wallet-cli`](https://github.com/monero-project/monero)
* [`xmrig`](https://github.com/xmrig/xmrig)
* [`p2pool`](https://github.com/SChernykh/p2pool)

monero-bash automates these programs into interactive prompts and simple commands

***Installing `monero-bash` and mining on P2Pool in 40 seconds:***

https://user-images.githubusercontent.com/101352116/162639580-f635d492-60b7-43e7-bb4d-9a1669650e53.mp4

[This project was a community funded CCS Proposal, thanks to all who donated](https://ccs.getmonero.org/proposals/monero-bash.html)

## Features
* 📦 `PACKAGE MANAGER` download/verify/upgrade packages (including itself)
* 💵 `WALLET` wallet menu to select/create wallets
* 👺 `DAEMON` control `monerod/p2pool/xmrig` more automatically
* ⛏️  `MINING` easy mining setup, **default is P2Pool**
* 👁️  `WATCH` switch between normal terminal and live output of `monerod/p2pool/xmrig`
* 🔒 `GPG` backup/decrypt your wallets
* 📈 `STATS` various stats to display (processes, price, CPU/disk usage, etc)

## Install
[To install monero-bash, download the latest release here and](https://github.com/hinto-janaiyo/monero-bash/releases/latest)
```
./monero-bash
```
This will install monero-bash onto your system, to uninstall cleanly: `monero-bash uninstall`

OR

```
git clone https://github.com/hinto-janaiyo/monero-bash &&
cd monero-bash &&
./monero-bash
```
**ALWAYS clone the main branch,** the other branches are not tested and may result in system damage

## Usage
[For full usage and configuration options of monero-bash, click here](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/guide.md)

<details>
<summary>Click for command usage</summary>

```
monero-bash usage: monero-bash <option> <more options>

monero-bash                              open wallet menu
uninstall                                uninstall ALL OF monero-bash
rpc                                      send a JSON RPC call to monerod

install <all/pkg>                        install <all> or a specific package
install <all/pkg> verbose                print detailed download information
remove  <all/pkg>                        remove <all> or a specific package

update                                   CHECK for updates
upgrade                                  upgrade all packages
upgrade <pkg>                            upgrade a specific package
upgrade <all/pkg> force                  forcefully upgrade packages
upgrade <all/pkg> verbose                print detailed download information
version                                  print installed package versions

config                                   configure MINING settings
start   <all/daemon/xmrig/p2pool>        start process detached (background)
stop    <all/daemon/xmrig/p2pool>        gracefully stop the process
kill    <all/daemon/xmrig/p2pool>        forcefully kill the process
restart <all/daemon/xmrig/p2pool>        restart the process
full    <daemon/xmrig/p2pool>            start the process attached (foreground)
watch   <daemon/xmrig/p2pool>            watch live output of process
edit    <daemon/xmrig/p2pool>            edit systemd service file
reset   <bash/daemon/xmrig/p2pool>       reset your configs/systemd to default

backup                                   encrypt and backup your /wallets/
decrypt                                  decrypt backup.tar.gpg

status                                   print status of all running processes
seed                                     generate random 25-word Monero seed
list                                     list wallets
size                                     show size of monero-bash folders
price                                    fetch price data from cryptocompare.com API
integrity                                check hash integrity of monero-bash

help                                     show this help message
```
</details>

## FAQ
<details>
<summary>Where does monero-bash download packages from?</summary>

---

* Monero [`https://downloads.getmonero.org/cli/linux64`](https://downloads.getmonero.org/cli/linux64)
* monero-bash [`https://github.com/hinto-janaiyo/monero-bash`](https://github.com/hinto-janaiyo/monero-bash)
* XMRig [`https://github.com/xmrig/xmrig`](https://github.com/xmrig/xmrig)
* P2Pool [`https://github.com/SChernykh/p2pool`](https://github.com/SChernykh/p2pool)

[The latest versions are downloaded using the GitHub API.](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/download)

VPN/Tor connections are often rate-limited by the API, if so, monero-bash will find the download link by filtering the HTML of the package's `/releases/latest/` GitHub page.

Hashes for Monero are found here: [`https://www.getmonero.org/downloads/hashes.txt`](https://www.getmonero.org/downloads/hashes.txt)

[Every other package hash is found on its GitHub page.](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/verify)

---

</details>

<details>
<summary>How does monero-bash upgrade packages?</summary>

---

[Click here for an explanation on how monero-bash upgrades packages](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/upgrade_explanation.md)

To see detailed output when installing/upgrading, type:
```
monero-bash install/upgrade <package> verbose
```

---

</details>

<details>
<summary>Does monero-bash have dependencies?</summary>

---

**No**

If you have a mainstream Linux distro (Ubuntu, Debian, Mint, Arch, Fedora) you already have everything needed:

* bash
* wget
* procfs
* systemd
* GNU coreutils
* GNU grep/awk/sed

---
</details>

<details>
<summary>monero-bash won't let me upgrade?</summary>

---

```
monero-bash upgrade <package> force
```
Will forcefully upgrade, even if up to date

OR

```
monero-bash remove <package> &&
monero-bash install <package>
```

---
</details>

<details>
<summary>Can I cancel mid-upgrade?</summary>

---

**Yes**

monero-bash uses temporary folders until it's ready to swap binaries:
```
/tmp/monero-bash.XXXXXXXXX
```

If you cancel ***right*** as the software is being upgraded, monero-bash will swap back your old binaries, and clean up temporary files.

If you cancel ***after*** software is installed, but before the local state is updated, monero-bash will force update it and clean up.

---

</details>

<details>
<summary>Where does monero-bash install itself?</summary>

---

Installation path:
```
/usr/local/share/monero-bash
```
PATH symlink:
```
/usr/local/bin/monero-bash
```
User folder:
```
/home/user/.monero-bash
```

---
</details>

<details>
<summary>Where does monero-bash install packages?</summary>

---

```
/usr/local/share/monero-bash/bin/
```

---
</details>

<details>
<summary>How to uninstall?</summary>

---
```
monero-bash uninstall
```
This will delete ALL `monero-bash` files AND `.monero-bash`

To manually remove everything:
```
sudo rm -r /usr/local/share/monero-bash
sudo rm /usr/local/bin/monero-bash
sudo rm -r "$HOME/.monero-bash"

sudo rm /etc/systemd/system/monero-bash-monerod.service
sudo rm /etc/systemd/system/monero-bash-xmrig.service
sudo rm /etc/systemd/system/monero-bash-p2pool.service
```

Please be careful, remember to move your `/wallets/` before uninstalling!

---
</details>
