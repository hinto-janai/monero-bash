# monero-bash
>a wrapper for Monero written in Bash, for Linux

![monero-bash](https://user-images.githubusercontent.com/101352116/179381901-f47ea0ba-5740-4bfa-9cd6-52798de48eb0.png)

## Contents
* [About](#About)
* [Features](#Features)
* [Install](#Install)
* [Usage](#Usage)
* [Documentation](#Documentation)
* [FAQ](#FAQ)

## About
***monero-bash is a Linux CLI wrapper/manager for:***

* [`Monero`](https://github.com/monero-project/monero)
* [`P2Pool`](https://github.com/SChernykh/p2pool)
* [`XMRig`](https://github.com/xmrig/xmrig)

monero-bash automates these programs into interactive prompts and simple commands

***Installing `monero-bash` and mining on `P2Pool` in 40 seconds:***

https://user-images.githubusercontent.com/101352116/162639580-f635d492-60b7-43e7-bb4d-9a1669650e53.mp4

[This project was a community funded CCS Proposal, thanks to all who donated](https://ccs.getmonero.org/proposals/monero-bash.html)

## Features
* 📦 **`PKG MANAGER`** Manage the download/verification/upgrading of packages
* 💵 **`WALLET MENU`** Interactive menu for selecting/creating wallets
* 👺 **`SYSTEMD`** Control ***monerod/p2pool/xmrig*** as background processes
* ⛏️ **`MINING`** Interactive mining configuration, ***built for P2Pool***
* 👁️ **`WATCH`** Switch between normal terminal and live output of ***monerod/p2pool/xmrig***
* 📈 **`STATS`** Display statistics (CPU usage, P2Pool shares, etc)
* 📋 **`RPC`** Interact with the ***monerod*** JSON-RPC interface

## Install

---

[To install monero-bash, download the latest release here, extract and run the main script:](https://github.com/hinto-janaiyo/monero-bash/releases/latest)
```
tar -xf monero-bash-v2.0.0.tar
cd monero-bash
./monero-bash
```
This will start the interactive install process into `$HOME/.monero-bash`

It is recommended to verify the hash and PGP signature before installation.  
Download the [`SHA256SUM`](https://github.com/hinto-janaiyo/monero-bash/releases/latest) file, download and import my [`PGP key`](https://github.com/hinto-janaiyo/monero-bash/blob/main/gpg/hinto-janaiyo.asc), and verify:
```
sha256sum -c SHA256SUM
gpg --import hinto-janaiyo.asc
gpg --verify SHA256SUM
```

---

To install with git:
```
git clone https://github.com/hinto-janaiyo/monero-bash
cd monero-bash
./monero-bash
```
**ALWAYS clone the main branch, the other branches are not tested**

---

To uninstall cleanly:
```
monero-bash uninstall
```
 Or manually remove everything:
```
rm -r $HOME/.monero-bash
sudo rm /usr/local/bin/monero-bash
sudo rm /etc/systemd/system/monero-bash*
```
**THIS WILL DELETE YOUR WALLETS - remember to move them before uninstalling!**

---

## Usage
```
USAGE: monero-bash [command] <argument> [--option]

WALLET
    monero-bash                              Open interactive wallet menu
    list                                     List wallets
    new                                      Enter wallet creation mode

PACKAGE
    install <packages> [--verbose]           Install one/multiple packages
    remove  <packages>                       Remove one/multiple packages
    update                                   Check for package updates
    upgrade <packages> [--verbose|--force]   Upgrade pkgs, if none specified, upgrade all out-of-date pkgs

PROCESS
    full    <monerod/p2pool/xmrig>           Start process fully attached in foreground
    start   <monerod/p2pool/xmrig>           Start process as systemd background process
    stop    <monerod/p2pool/xmrig>           Gracefully stop systemd background process
    kill    <monerod/p2pool/xmrig>           Forcefully kill systemd background process
    restart <monerod/p2pool/xmrig>           Restart systemd background process
    watch   <monerod/p2pool/xmrig>           Watch live output of systemd background process
    edit    <monerod/p2pool/xmrig>           Edit systemd service file
    reset   <bash/monerod/p2pool/xmrig>      Reset your config/systemd service file to default

STATS
    status                                   Print status of all running processes
    size                                     Print size of all packages and folders
    version                                  Print current package versions
    changes <monero-bash version>            Print current/specified monero-bash changelog

RPC
    rpc     <JSON-RPC method>                Send a JSON-RPC call to monerod

HELP
    help                                     Print this help message
```

## Documentation
* [[P2Pool configuration]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/p2pool.md)
* [[monero-bash configuration]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/guide.md)
* [[monero-bash file structure]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/structure.md)
* [[monero-bash gpg import process]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/gpg.md)
* [[monero-bash development process]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/development.md)
* [[monero-bash package upgrade process]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/upgrade.md)

## FAQ
<details>
<summary>Where does monero-bash download packages from?</summary>

---

* monero-bash [`https://github.com/hinto-janaiyo/monero-bash`](https://github.com/hinto-janaiyo/monero-bash)
* Monero [`https://downloads.getmonero.org/cli/linux64`](https://downloads.getmonero.org/cli/linux64)
* P2Pool [`https://github.com/SChernykh/p2pool`](https://github.com/SChernykh/p2pool)
* XMRig [`https://github.com/xmrig/xmrig`](https://github.com/xmrig/xmrig)

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
