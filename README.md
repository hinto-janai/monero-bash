# monero-bash
>a wrapper for monero written in bash, for Linux

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

monero-bash automates these programs into interactive prompts and `linux-like` commands

***Installing `monero-bash` and mining on P2Pool in 40 seconds:***

https://user-images.githubusercontent.com/101352116/162639580-f635d492-60b7-43e7-bb4d-9a1669650e53.mp4

[This project was a community funded CCS Proposal, thanks to all who donated](https://ccs.getmonero.org/proposals/monero-bash.html)

## Features
* 📦 `PACKAGE MANAGER` downloading, verifying and upgrading of packages
* 💵 `WALLET` wallet menu to display names/amounts of wallets
* 👺 `DAEMON` control `monerod` more automatically
* ⛏️  `MINING` easy mining setup, **default is P2Pool**
* 👁️  `WATCH` switch between normal terminal and live output of `monerod`, `xmrig`, `p2pool`
* 🔒 `GPG` verify packages with GPG, and `backup/decrypt` your wallets
* 📈 `STATS` various stats to display (processes, price, disk usage, etc)

## Install
[To install monero-bash, download the latest release here and](https://github.com/hinto-janaiyo/monero-bash/releases/latest)
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
[For full usage and configuration options of monero-bash, click here](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/guide.md)

<details>
<summary>Click for command usage</summary>

```
monero-bash usage: monero-bash <option> <more options>

monero-bash                       the default command will open wallet selection
uninstall                         uninstall monero-bash and remove /.monero-bash/

install <all/pkg>                 install <all> or a specific package
install <all/pkg> verbose         print detailed download information
remove <all/pkg>                  remove <all> or a specific package
remove <all/pkg> force            forcefully remove a package

update                            only CHECK for updates
upgrade <all/pkg>                 upgrade <all> or a specific package
upgrade <all/pkg> force           forcefully upgrade packages
upgrade <all/pkg> verbose         print detailed download information
version                           print installed package versions

config                            configure MINING settings
start <all/daemon/xmrig/p2pool>   start process detached (background)
stop <all/daemon/xmrig/p2pool>    gracefully stop the process
kill <all/daemon/xmrig/p2pool>    forcefully kill the process
restart <all/daemon/xmrig/p2pool> restart the process
full <daemon/xmrig/p2pool>        start the process attached (foreground)
watch <daemon/xmrig/p2pool>       watch live output of process

gpg                               toggle GPG verification of binaries
gpg import                        import GPG keys of package authors
backup                            encrypt and backup your /wallets/
decrypt                           decrypt backup.tar.gpg

status                            print status of all running processes
list                              list wallets
size                              show size of monero-bash folders
price                             fetch price data from cryptocompare.com API
integrity                         check hash integrity of monero-bash

help                              show this help message
```
</details>

## FAQ
<details>
<summary>Where does monero-bash download packages from?</summary>

---

[Click here for a quick explanation of how monero-bash upgrades packages](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/upgrade_explanation.md)

If you'd like to see detailed output when installing/upgrading, type:
```
monero-bash install/upgrade <package> verbose
```

* Monero - `https://downloads.getmonero.org/cli/linux64`
* monero-bash - `https://github.com/hinto-janaiyo/monero-bash`
* XMRig - `https://github.com/xmrig/xmrig`
* P2Pool - `https://github.com/SChernykh/p2pool`

The latest packages are downloaded through the GitHub API. If the API fails, monero-bash will attempt to find a download link by HTML filtering the package's `/releases/latest/` GitHub page.

Hashes for Monero are found here: `https://www.getmonero.org/downloads/hashes.txt`

Every other package hash is found on its respective GitHub page.

Unfortunately, there is no "official" central repo for all these programs, so `monero-bash` individually seeks out the links/hashes (makes my life very hard)

---

</details>

<details>
<summary>Does monero-bash have dependencies?</summary>

---

***monero-bash does not have any hard dependencies***

If you have a mainstream Linux distro (Ubuntu, Debian, Mint, Arch, Fedora, etc.), you already have everything needed for monero-bash to work:
* bash
* wget
* procfs
* systemd
* GNU coreutils
* GNU grep/awk/sed

---
</details>

<details>
<summary>monero-bash won't let me upgrade!</summary>

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
<summary>What happens if I cancel/shutdown mid-upgrade?</summary>

---

monero-bash uses a temporary folder until it's ready to swap binaries:
```
/tmp/monero-bash.XXXXXXXXX
```

If you cancel ***right*** as the software is being upgraded, monero-bash will swap back your old binaries, and clean up temporary files.

If you cancel ***after*** software is installed, but before the local state is updated, monero-bash will force update it and clean up.

**There's nothing monero-bash can do to help if you shutdown your computer mid-upgrade**

---

</details>

<details>
<summary>What is the hash check before every upgrade?</summary>

---

monero-bash checks its own hash integrity before any manipulation of data. If any hash check fails, any command involving data manipulation will also fail.

If you've edited some files and now it won't work, remove monero-bash manually and install a fresh copy:
```
sudo rm -r /usr/local/share/monero-bash
sudo rm /usr/local/bin/monero-bash
sudo rm -r "$HOME/.monero-bash"
```
If you're manually editing the code and forcing it to work, please be careful. Shell scripts are one empty variable away from wiping your drive. Definitely not speaking from experience.

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
<summary>Where does monero-bash install packages?</summary>

---

```
/usr/local/share/monero-bash/bin/
```
is where packages live, with respective folder names

---
</details>

<details>
<summary>How to uninstall?</summary>

---
```
monero-bash uninstall
```
This will delete all `monero-bash` files AND `.monero-bash`

If your monero-bash is bugged and not uninstalling, you can manually remove everything like this:
```
sudo rm -r /usr/local/share/monero-bash
sudo rm /usr/local/bin/monero-bash
sudo rm -r "$HOME/.monero-bash"
```
To delete `systemd` files:
```
sudo rm /etc/systemd/system/monero-bash-monerod.service
sudo rm /etc/systemd/system/monero-bash-xmrig.service
sudo rm /etc/systemd/system/monero-bash-p2pool.service
```

Please be careful, remember to move your `/wallets/` before uninstalling!

---
</details>
