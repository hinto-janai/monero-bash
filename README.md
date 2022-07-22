# monero-bash
>a wrapper for Monero written in Bash, for Linux

![monero-bash](https://user-images.githubusercontent.com/101352116/179381901-f47ea0ba-5740-4bfa-9cd6-52798de48eb0.png)

## Contents
* [About](#About)
* [Features](#Features)
* [Install](#Install)
* [Documentation](#Documentation)
* [FAQ](#FAQ)

## About
monero-bash is a wrapper/manager for:

* [`Monero`](https://github.com/monero-project/monero)
* [`P2Pool`](https://github.com/SChernykh/p2pool)
* [`XMRig`](https://github.com/xmrig/xmrig)

monero-bash automates these programs into interactive prompts and simple commands

***Installing `monero-bash` and mining on P2Pool in 40 seconds:***

https://user-images.githubusercontent.com/101352116/162639580-f635d492-60b7-43e7-bb4d-9a1669650e53.mp4

[This project was a community funded CCS Proposal, thanks to all who donated](https://ccs.getmonero.org/proposals/monero-bash.html)

## Features
* 📦 `PKG MANAGER` | Automatically manage the download/verification/upgrading of packages
* 💵 `WALLET MENU` | Menu that wraps around `monero-wallet-cli` for selecting/creating wallets
* 👺 `SYSTEMD`     | Control `monerod/p2pool/xmrig` as background processes
* ⛏️  `MINING`      | Interactive mining setup, **built for P2Pool**
* 👁️  `WATCH`       | Switch between normal terminal and live output of `monerod/p2pool/xmrig`
* 📈 `STATS`       | Display statistics (CPU usage, P2Pool shares, etc)
* 📋 `RPC`         | Interact with the `monerod` JSON-RPC interface

## Install
[To install monero-bash, download the latest release here and](https://github.com/hinto-janaiyo/monero-bash/releases/latest)
```
./monero-bash
```
This will install monero-bash into `$HOME/.monero-bash`

To install with git:
```
git clone https://github.com/hinto-janaiyo/monero-bash
cd monero-bash
./monero-bash
```
**ALWAYS clone the main branch,** the other branches are not tested and may result in system damage

To uninstall cleanly, you can 
```
monero-bash uninstall
```

## Documentation
* [monero-bash configuration](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/guide.md)
* [Mining configuration](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/p2pool.md)
* [monero-bash package upgrade process](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/upgrade.md)
* [monero-bash file structure](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/structure.md)
* [monero-bash development process](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/development.md)
* [monero-bash gpg import process](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/gpg.md)

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

* monero-bash | [`https://github.com/hinto-janaiyo/monero-bash`](https://github.com/hinto-janaiyo/monero-bash)
* Monero      | [`https://downloads.getmonero.org/cli/linux64`](https://downloads.getmonero.org/cli/linux64)
* P2Pool      | [`https://github.com/SChernykh/p2pool`](https://github.com/SChernykh/p2pool)
* XMRig       | [`https://github.com/xmrig/xmrig`](https://github.com/xmrig/xmrig)

[The latest versions are downloaded using the GitHub API.](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/download)

VPN/Tor connections are often rate-limited by the API, if so, monero-bash will find the download link by filtering the HTML of the package's `/releases/latest/` GitHub page.

Hashes for Monero are found here: [`https://www.getmonero.org/downloads/hashes.txt`](https://www.getmonero.org/downloads/hashes.txt)

[Every other package hash is found on its GitHub page.](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/verify)

---

</details>

<details>
<summary>Does monero-bash have dependencies?</summary>

---

**No**

If you have a mainstream Linux distro (Ubuntu, Debian, Mint, Arch, Fedora) you already have everything needed:

* Bash
* wget/curl
* systemd
* GNU coreutils

---
</details>

<details>
<summary>monero-bash won't let me upgrade?</summary>

---

```
monero-bash upgrade <package> --force
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

If you cancel ***RIGHT*** as the package is being upgraded, monero-bash will swap back the old version, and clean up temporary files.

If you cancel ***AFTER*** the package is installed, but before the local state is updated, monero-bash will force update it and clean up.

You can check your current package versions with
```
monero-bash version
```

---

</details>

<details>
<summary>Where does monero-bash install itself?</summary>

---

Installation path:
```
$HOME/.monero-bash
```
PATH symlink:
```
/usr/local/bin/monero-bash
```
systemd files:
```
/etc/systemd/system/monero-bash-$PACKAGE.service
```

---
</details>

<details>
<summary>Where does monero-bash install packages?</summary>

---

```
$HOME/.monero-bash/packages
```

---
</details>

<details>
<summary>How to uninstall?</summary>

---
```
monero-bash uninstall
```
This will delete ALL `monero-bash` files

To manually remove everything:
```
sudo rm -r $HOME/.monero-bash
sudo rm /etc/systemd/system/monero-bash-*
```

Please be careful, remember to move your `/wallets/` before uninstalling!

---
</details>
