# monero-bash (WORK IN PROGRESS)
>a wrapper for monero written in bash, for Linux

![monero-bash.png](https://i.ibb.co/x8zcf7p/monero-bash.png)

## Contents
* [About](#About)
* [Features](#Features)
* [Install](#Install)
* [Usage](#Usage)
* [FAQ](#FAQ)
* [Todo](#Todo)

## About
monero-bash is a wrapper/manager for:

* `monerod`
* `monero-wallet-cli`
* `monero-rpc`
* `xmrig`
* `p2pool`

monero-bash abstracts/automates these programs into simple interactive prompts and `linux-like` commands

[This project is a CCS Proposal](https://repo.getmonero.org/monero-project/ccs-proposals/-/merge_requests/297)

If this program is useful to you, please show support to get it funded!

## Features
* 📦 `PACKAGE MANAGER` automated downloading, verifying and upgrading of packages
* 💵 `WALLET` wallet menu to display names/amounts of wallets
* 👺 `DAEMON` control `monerod` more easily/automatically
* ⛏️  `MINING` automated mining, **default is P2Pool**
* 👁️  `WATCH` switch between normal terminal and live output of `monerod`, `xmrig`, `p2pool`
* 📈 `STATS` various stats to display (processes, price, disk usage, etc)

## Install
[To install monero-bash, download the latest release here](https://github.com/hinto-janaiyo/monero-bash/releases/latest) and
```
./monero-bash
```
will install monero-bash onto your system, to uninstall cleanly: `monero-bash uninstall`

OR

```
git clone https://github.com/hinto-janaiyo/monero-bash &&
cd monero-bash &&
./monero-bash
```
**ALWAYS clone the main branch,** the other branches are not tested and may result in system damage

## Usage
[For full usage and configuration options of monero-bash, click here](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/help.md)

<details>
<summary>Click to reveal command usage</summary>

```
monero-bash usage:          monero-bash <option> <more options>

# UNINSTALL #
uninstall                   uninstall monero-bash and remove /.monero-bash/

# PACKAGES #
install <all/name>          install <all> or a specific package
remove <all/name>           remove <all> or a specific package
remove <all/name> force     forcefully remove a package
update                      only CHECK for updates
upgrade <all/name>          upgrade <all> or a specific package
upgrade <all/name> force    forcefully upgrade packages
version                     print installed package versions

# MONERO DAEMON #
daemon                      print status of daemon
daemon start                start the daemon (detached)
daemon stop                 gracefully stop the daemon
daemon kill                 forcefully kill all daemon processes
daemon full                 start the daemon attached

# MINE #
mine                        print status of mining
mine start                  start monerod, xmrig, p2pool in the background
mine stop                   stop monerod, xmrig, p2pool
mine kill                   forcefully kill all mining processes

# WATCH #
watch daemon                show live daemon output
watch xmrig                 show live xmrig output
watch p2pool                show live p2pool output

# BACKUP #
backup                      encrypt and backup your /wallets/

# STATS #
status                      print useful stats
list                        list wallets
size                        show size of monero-bash folders
price                       fetch price data from cryptocompare.com API
integrity                   check hash integrity of monero-bash

# HELP #
help                        show this help message
```
</details>

## FAQ
<details>
<summary>Is this a virus?</summary>

---
[No. Click here for a quick explaination of what monero-bash does.](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/upgrade_explaination.md)
---
</details>

<details>
<summary>Where does monero-bash download packages from?</summary>

---

* Monero - `https://downloads.getmonero.org/cli/linux64`
* monero-bash - `https://github.com/hinto-janaiyo/monero-bash`
* XMRig - `https://github.com/xmrig/xmrig`
* P2Pool - `https://github.com/SChernykh/p2pool`

The latest packages are always downloaded through the GitHub API. If the API fails for whatever reason, monero-bash will attempt to find a download link by HTML filtering the package's `/releases/latest/` GitHub page.

Hashes for Monero are found here: `https://www.getmonero.org/downloads/hashes.txt`
Every other package hash is found on its GitHub page.

Unfortunately, there is no "official" central repo for all these programs, so `monero-bash` individually seeks out the links/hashes (makes my life very hard)

---
</details>

<details>
<summary>Does monero-bash have dependencies?</summary>

---

***monero-bash does not have any hard dependencies***

If you have a mainstream Linux distro (Ubuntu, Debian, Mint, Arch, Fedora, etc.), you already have everything needed for monero-bash to work
* bash
* wget
* procfs
* systemd
* GNU coreutils
* GNU grep/awk/sed

---
</details>

<details>
<summary>monero-bash says I have a package but I don't and can't upgrade!</summary>

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
<summary>Where does monero-bash install itself?</summary>

---

The source folder gets installed in
```
/usr/local/share/monero-bash
```

The PATH is set with a symlink in
```
/usr/local/bin/monero-bash
```
The user folder is in
```
/home/user/.monero-bash
```

---
</details>

<details>
<summary>How to uninstall?</summary>


---
```
monero-bash uninstall
```
This will delete all monero-bash files AND `.monero-bash`

If your monero-bash is bugged and not uninstalling, you can manually remove everything like so:
```
sudo rm -r "/usr/local/share/monero-bash" &&
sudo rm "/usr/local/bin/monero-bash" &&
sudo rm -r "$HOME/.monero-bash"
```
Please be careful, remember to move your `/wallets/` before uninstalling!

---
</details>


## Todo
***To be added***
* Automatic P2Pool mining
* GPG key verification for binaries
* RPC/Daemon API integration
* Automatic encrypted wallet backups

*Added but not usable yet*
* XMRig, P2Pool can be installed but not invoked
* systemd intergrated, but not invokable
* `watch` command works, but no XMRig/P2Pool instance to watch
