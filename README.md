# monero-bash (WORK IN PROGRESS)
>a wrapper for monero written in bash, for Linux

![monero-bash.png](https://i.ibb.co/x8zcf7p/monero-bash.png)

## Contents
* [About](#About)
* [Features](#Features)
* [Install](#Install)
* [Usage](#Usage)
* [Details](#Details)
* [Todo](#Todo)
* [Is this a virus?](#Is-this-a-virus)

---

monero-bash is a wrapper/manager for:

* `monerod`
* `monero-wallet-cli`
* `monero-rpc`
* `xmrig`
* `p2pool`

monero-bash abstracts/automates these programs into simple interactive prompts and `linux-like` commands

This project is a [CCS Proposal](https://repo.getmonero.org/monero-project/ccs-proposals/-/merge_requests/297)

If this program was/is useful to you, please show support to get it funded!

---

## Features
📦 `PACKAGE MANAGER` automated downloading, verifying and upgrading of packages
💵 `WALLET` wallet menu to display names/amounts of wallets
👺 `DAEMON` control `monerod` more easily/automatically
⛏️  `MINING` automated mining, **default is P2Pool**
👁️  `WATCH` switch between normal terminal and live output of `monerod`, `xmrig`, `p2pool`
📈 `STATS` various stats to display (processes, price, disk usage, etc)

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
```
monero-bash usage:          monero-bash <option> <more options>

# UNINSTALL #
uninstall                   uninstall monero-bash and remove /.monero-bash/

# PACKAGES #
install <all/name>          install <all> or a specific package
remove <name>               remove specific package
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

# WATCH #
watch daemon                show live daemon output
watch xmrig                 show live xmrig output
watch p2pool                show live p2pool output

# STATS #
status                      print useful stats
list                        list wallets
size                        show size of monero-bash folders
price                       fetch price data from cryptocompare.com API
integrity                   check hash integrity of monero-bash

# HELP #
help                        show this help message
```

## Details
***monero-bash does not have any hard dependencies***

If you have a modern Linux system, you most likely have everything needed for monero-bash to work
* bash
* wget
* procfs
* systemd
* GNU coreutils
* GNU grep/awk/sed

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

Not added at all
* `remove` command

## [Is this a virus?](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/upgrade_explaination.md)
