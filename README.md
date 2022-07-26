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
Download the [`SHA256SUM`](https://github.com/hinto-janaiyo/monero-bash/releases/latest) file, download and import my [`PGP key`](https://github.com/hinto-janaiyo/monero-bash/blob/main/gpg/hinto-janaiyo.asc), and verify the tar:
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
    monero-bash                                Open interactive wallet menu
    list                                       List wallets
    new     <wallet type>                      Enter wallet creation mode

PACKAGE
    install <packages> [--verbose]             Install one/multiple packages
    remove  <packages> [--verbose]             Remove one/multiple packages
    update  [--verbose]                        Check for package updates
    upgrade [--verbose] [--force]              Upgrade all out-of-date packages

PROCESS
    full    <process>                          Start <process> fully attached in foreground
    config  <processes>                        Enter interactive configuration for <process>
    default <processes> [--config] [--systemd] Reset your config/systemd file to the default

SYSTEMD
    start   <processes>                        Start process as systemd background process
    stop    <processes>                        Gracefully stop systemd background process
    kill    <processes>                        Forcefully kill systemd background process
    restart <processes>                        Restart systemd background process
    enable  <processes>                        Enable <process> to auto-start on computer boot
    disable <processes>                        Disable <process> from auto-starting on computer boot
    edit    <processes>                        Edit systemd service file
    refresh <processes>                        Refresh your systemd service file to match your config
    watch   <processes>                        Watch live output of systemd background process

STATS
    status                                     Print status of all running processes
    size                                       Print size of all packages and folders
    version                                    Print current package versions

OTHER
    rpc     <JSON-RPC method>                  Send a JSON-RPC call to monerod
    changes <package>                          Print the latests changes for <package>
    help    <command>                          Print help for a command, or all if none specified
```

## Documentation
* [[P2Pool configuration]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/p2pool.md)
* [[monero-bash configuration]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/guide.md)
* [[monero-bash file structure]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/structure.md)
* [[monero-bash development process]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/development.md)
* [[monero-bash package upgrade process]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/upgrade.md)

## FAQ
<details>
<summary>Where are packages downloaded from?</summary>

---
[The latest versions are downloaded using the GitHub API.](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/pkg/download.sh)

* monero-bash [`https://github.com/hinto-janaiyo/monero-bash`](https://github.com/hinto-janaiyo/monero-bash)
* Monero [`https://downloads.getmonero.org/cli/linux64`](https://downloads.getmonero.org/cli/linux64)
* P2Pool [`https://github.com/SChernykh/p2pool`](https://github.com/SChernykh/p2pool)
* XMRig [`https://github.com/xmrig/xmrig`](https://github.com/xmrig/xmrig)

Hashes for Monero are found here: [`https://www.getmonero.org/downloads/hashes.txt`](https://www.getmonero.org/downloads/hashes.txt)

Every other package hash is found on its GitHub page.

[The metadata used for package downloads can be found here.](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/struct/pkg.sh)

This defines some important information:
* PGP key link
* PGP key fingerprint
* GitHub API link

---

</details>

<details>
<summary>Where are PGP keys downloaded from?</summary>

---

* monero-bash `21958EE945980282FCB849C8D7483F6CA27D1B1D` -> [hinto-janaiyo](https://raw.githubusercontent.com/hinto-janaiyo/monero-bash/main/pgp/hinto-janaiyo.asc)
* Monero `81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92` -> [binaryFate](https://raw.githubusercontent.com/monero-project/monero/master/utils/gpg_keys/binaryfate.asc)
* P2Pool `1FCAAB4D3DC3310D16CBD508C47F82B54DA87ADF` -> [SChernykh](https://raw.githubusercontent.com/monero-project/gitian.sigs/master/gitian-pubkeys/SChernykh.asc)
* XMRig `9AC4CEA8E66E35A5C7CDDC1B446A53638BE94409` -> [XMRig](https://raw.githubusercontent.com/xmrig/xmrig/master/doc/gpg_keys/xmrig.asc)

This metadata is found in the [monero-bash source code, here.](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/struct/pkg.sh)

---

</details>

<details>
<summary>I want to see ALL the things monero-bash is doing</summary>

---

Export this variable before running monero-bash:
```
export STD_LOG_DEBUG=true
```
Doing this will make monero-bash print debug info on all the things it's doing in the background.

Using the `--verbose` flag on the install/upgrade/remove commands does the same thing.

You can make monero-bash print ***very verbose*** info by ALSO exporting:
```
export STD_LOG_DEBUG_VERBOSE=true
```
This will print the function call stack and command line numbers along with the regular debug information.

---

</details>

<details>
<summary>Where is monero-bash installed?</summary>

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
/etc/systemd/system/monero-bash-$PROCESS.service
```

---

</details>

<details>
<summary>Where are packages installed?</summary>

---

```
$HOME/.monero-bash/packages
```

---

</details>

<details>
<summary>Where are the config files?</summary>

---

```
$HOME/.monero-bash/config
```

---

</details>

<details>
<summary>Where are the wallets?</summary>

---

```
$HOME/.monero-bash/wallets
```

---

</details>

<details>
<summary>I can't upgrade?</summary>

---

```
monero-bash upgrade <package> --force
```
Will forcefully upgrade, even if up to date

You can also remove and re-install the package:
```
monero-bash remove <package>
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

If you cancel ***BEFORE*** the package is upgraded, monero-bash will swap back the old version, and clean up temporary files.

If you cancel ***AFTER*** the package is upgraded, but before the upgrade process is over, monero-bash will force update it and clean up.

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
