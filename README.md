# monero-bash

![monero-bash](https://user-images.githubusercontent.com/101352116/183257273-6224fa0d-cb10-4a3f-bb5d-057df7c0e18e.jpg)

## Contents
* [About](#About)
* [Features](#Features)
* [Distro Coverage](#Distro-Coverage)
* [Install](#Install)
* [Usage](#Usage)
	- [Wallet](#Wallet)
	- [Config](#Config)
	- [Mining](#Mining)
	- [Watch](#Watch)
	- [Security](#Security)
	- [Commands](#Commands)
* [FAQ](#FAQ)

## About
**monero-bash is a Linux CLI wrapper for: [`Monero`](https://github.com/monero-project/monero) | [`P2Pool`](https://github.com/SChernykh/p2pool) | [`XMRig`](https://github.com/xmrig/xmrig)**

***A few video demos:***

*	<details>
	<summary>Wallet menu</summary>

	https://user-images.githubusercontent.com/101352116/184435540-6505d8d3-8cf0-4d72-a414-506f0abca57f.mp4
	</details>

*	<details>
	<summary>Package manager</summary>

	https://user-images.githubusercontent.com/101352116/184544224-4698de80-9818-41d5-89d3-a0a1b8dc7add.mp4
	</details>

*	<details>
	<summary>Mining & watching live stats</summary>

	https://user-images.githubusercontent.com/101352116/185520243-eaeed5dc-2454-40f3-8b1f-4ea18f40c1cf.mp4
	</details>


[This project was funded by the Monero Community via the CCS, thanks to all who donated!](https://ccs.getmonero.org/proposals/monero-bash.html)

## Features
* 📦 **`PKG MANAGER`** Manage the download/verification/upgrading of packages
* 💵 **`WALLET MENU`** Interactive menu for selecting/creating wallets
* 👺 **`SYSTEMD`** Control ***monerod/p2pool/xmrig*** as background processes
* ⛏️ **`MINING`** Interactive mining configuration, ***built for P2Pool***
* 📈 **`STATUS`** Display stat (CPU usage, P2Pool shares, Hashrate, etc)
* 👁️ **`WATCH`** Watch live output of processes or general status
* 📋 **`RPC`** Interact with the ***monerod*** JSON-RPC interface
* 🔒 **`GPG`** Encrypt and backup your wallets

## Distro Coverage
| Linux Distribution                   | Version            | Status | Info |
|--------------------------------------|--------------------|--------|------|
| [Debian](https://www.debian.org)     | 11, 10             | ✅     |
| [Ubuntu](https://ubuntu.com)         | LTS 22.04, 20.04   | ✅     |
| [Pop!\_OS](https://pop.system76.com) | LTS 22.04, 20.04   | ✅     |
| [Linux Mint](https://linuxmint.com)  | 21, 20.03          | ✅     |
| [Fedora](https://getfedora.org)      | Workstation 36, 35 | ❌     | SELinux disables `systemd` functionality
| [Arch Linux](https://archlinux.org)  |                    | ⚠️      | `wget` must be installed
| [Manjaro](https://manjaro.org)       | 21.3.6             | ✅     |
| [Gentoo](https://www.gentoo.org)     |                    | ❌     | `wget` & `systemd` must be installed

***✅ = Works out the box***  
***⚠️ = Small issues***  
***❌ = Big issues***  

## Install
[**To install: download the latest release here, extract and run monero-bash**](https://github.com/hinto-janaiyo/monero-bash/releases/latest)
```bash
tar -xf monero-bash-v1.8.4.tar
cd monero-bash
./monero-bash
```
This will start the interactive install process into `/usr/local/share/monero-bash`

It is recommended to verify the hash and PGP signature before installation.  
Download the [`SHA256SUM`](https://github.com/hinto-janaiyo/monero-bash/releases/latest) file, download and import my [`PGP key`](https://github.com/hinto-janaiyo/monero-bash/blob/main/gpg/hinto-janaiyo.asc), and verify:
```bash
sha256sum -c SHA256SUM
gpg --import hinto-janaiyo.asc
gpg --verify SHA256SUM
```

---

**To install with git:**
```bash
git clone https://github.com/hinto-janaiyo/monero-bash
cd monero-bash
./monero-bash
```
ALWAYS clone the main branch, the other branches are not tested

---

**To uninstall:**
```
monero-bash uninstall
```
 Or manually remove everything:
```bash
rm -r ~/.monero-bash
sudo rm /usr/local/bin/monero-bash
sudo rm -r /usr/local/share/monero-bash
sudo rm /etc/systemd/system/monero-bash*
sudo rm /etc/systemd/system/multi-user.target.wants/monero-bash*
```
THIS WILL DELETE YOUR WALLETS - remember to move them before uninstalling!

## Usage
### Wallet
Wallet files are found in: `~/.monero-bash/wallets`

To open the wallet menu, type: `monero-bash`. You will have 4 options:
* `Select` Type a wallets name to open it
* `New` Create a new wallet
* `View` Create a new VIEW-ONLY wallet
* `Recover` Recover a wallet with a standard 24/25 word Monero seed

For safety reasons, there is no built-in way to **delete** a wallet.  
You'll have to manually remove the files inside the wallet folder, for example:
```bash
rm ~/.monero-bash/wallets/MY_WALLET
rm ~/.monero-bash/wallets/MY_WALLET.keys
```

---

### Config
Config files for all packages are in: `~/.monero-bash/config`

monero-bash comes with pre-configured/optimized configuration files:
* [`monero-bash.conf`](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monero-bash.conf)
* [`monerod.conf`](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monerod.conf)
* [`monero-wallet-cli.conf`](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monero-wallet-cli.conf)
* [`p2pool.conf`](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/p2pool.conf)
* [`xmrig.json`](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/xmrig.json)

P2Pool does not have native support for a config file, so monero-bash uses its self-created `p2pool.conf`.

Processes that are started in the background (`monero-bash start <process>`) will also respect their config files.  
For example: If you set `MINI=true` in `p2pool.conf`, `monero-bash start p2pool` will start P2Pool on the mini sidechain.

---

### Mining
These instructions (and monero-bash itself) is built around running your own P2Pool, with XMRig pointed at it, [click here for more info.](https://github.com/SChernykh/p2pool) However you can use any combination you'd like: only Monero, only P2Pool, etc.

***Warning:***
* Wallet addresses are public on P2Pool! It is recommended to create a seperate mining wallet.
* You are using your own nodes to mine. Both the Monero & P2Pool nodes have to be fully synced!

**To start mining on P2Pool with XMRig:**
1. Install all the packages: `monero-bash install all`
2. Configure basic mining settings: `monero-bash config`
3. Start all processes in the background: `monero-bash start all`
4. And watch them live with: `monero-bash watch`

Unfortunately, you cannot interact directly with a `systemd` background process so it may be useful to download `screen` or `tmux` so you can open multiple terminals and use:
```
monero-bash full <monero/p2pool/xmrig>
```
This allows you to interact with the processes directly AND have them in a background terminal.

---

### Watch
To watch live status output:
```
monero-bash watch
```
Or a specific (background) process:
```
monero-bash watch <process>
```
Press the ***LEFT/RIGHT*** arrow keys to switch processes. To just print a static status page, you can:
```
monero-bash status
```

---

### Security
Fun fact: Docker uses the exact same Linux namespace primitives as systemd, _both are not VMs,_ both directly use the host kernel for "sandboxing".

Processes started with systemd aka `monero-bash start` will utilize [systemd's security features.](https://www.freedesktop.org/software/systemd/man/systemd.exec.html) **These are completely bypassed if you start processes directly with `monero-bash full`, you are relying on your own security measures in that instance.**

Here are the options set in the service files:
```
PrivateTmp=yes               Mounts a private /tmp/ folder for the process
NoNewPrivileges=yes          The process (and its children) cannot escalate privileges
ProcSubset=pid               The process can only see its own /proc/ directory
RestrictRealtime=yes         Disallows realtime scheduling
RestrictNamespaces=true      Restricts access to Linux namespace functionality for the process
CapabilityBoundingSet=...    Controls certain system capabilities the process has
PrivateUsers=true            Creates a new user namespace for the executed processes
ProtectHostname=true         Creates a new UTS namespace for the executed process + disallows hostname changes
ProtectClock=...             Disallows changing the systems clock
ProtectKernelModules=...     Disallows loading kernel modules
ProtectKernelLogs=yes        Disallows accessing the kernel log ring buffer
ProtectProc=invisible        Processes owned by other users in /proc/ are hidden from the process
ProtectControlGroups=yes     /sys/fs/cgroup/ will be made read-only
ProtectKernelTunables=yes    Disallows changing kernel variables
ProtectSystem=strict         Mounts /usr/, /etc/, and /boot/ as read-only for the process
ProtectHome=read-only        Mounts /home/ as read-only for the process
BindPaths=...                Allows CERTAIN directories to be read from/written to
```
In the event of fatal process bugs like remote code execution, these settings will prevent or at the very least lessen the damage done.

**Note: `XMRig` is ran as `root` for the MSR hashrate boost.** Although it is still heavily restricted with these settings, they are not perfect. Unless you consider XMRig malware, you should be more concerned with programs that have much more realistic attack surfaces: constant internet-facing applications like Monero/P2Pool nodes, or any other software on your computer in the same vein.

---

### Commands
```
USAGE: monero-bash command <argument> [optional]

monero-bash                                           Open wallet menu
uninstall                                             Uninstall ALL OF monero-bash

update                                                Check for package updates
upgrade [force|verbose]                               Upgrade all out-of-date packages
upgrade <package> [force|verbose]                     Upgrade a specific package
install <all/package> [verbose]                       Install <all> or a specific package
remove  <all/package>                                 Remove <all> or a specific package

config                                                Configure P2Pool+XMRig mining settings
full    <monero/p2pool/xmrig>                         Start the process directly attached (foreground)
start   <all/monero/p2pool/xmrig>                     Start process with systemd (background)
stop    <all/monero/p2pool/xmrig>                     Gracefully stop the systemd process
restart <all/monero/p2pool/xmrig>                     Restart the systemd process
enable  <all/monero/p2pool/xmrig>                     Enable the process to auto-start on boot
disable <all/monero/p2pool/xmrig>                     Disable the process from auto-starting on boot
reset   <bash/monero/p2pool/xmrig> [config|systemd]   Reset your configs/systemd to default
edit    <bash/monero/p2pool/xmrig> [config|systemd]   Edit config/systemd service file
watch   [monero|p2pool|xmrig]                         Watch live status or a specific process

rpc     [help]                                        Send a RPC call to monerod
seed    [language]                                    Generate random 25-word Monero seed
list                                                  List wallets
size                                                  Show size of monero-bash folders
price                                                 Fetch price data from cryptocompare.com API
status                                                Print status of all installed packages
version                                               Print versions of installed packages

backup                                                Encrypt & backup [wallets] -> [backup.tar.gpg]
decrypt                                               Decrypt [backup.tar.gpg] -> [backup]

help                                                  Show this help message
```

## FAQ
<details>
<summary>Where does monero-bash download packages from?</summary>

---

[The latest versions are downloaded using the GitHub API.](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/download.sh)

* Monero [`https://downloads.getmonero.org/cli/linux64`](https://downloads.getmonero.org/cli/linux64)
* monero-bash [`https://github.com/hinto-janaiyo/monero-bash`](https://github.com/hinto-janaiyo/monero-bash)
* XMRig [`https://github.com/xmrig/xmrig`](https://github.com/xmrig/xmrig)
* P2Pool [`https://github.com/SChernykh/p2pool`](https://github.com/SChernykh/p2pool)

VPN/Tor connections are often rate-limited by the API, if so, monero-bash will find the download link by filtering the HTML of the package's `/releases/latest/` GitHub page.

Hashes for Monero are found here: [`https://www.getmonero.org/downloads/hashes.txt`](https://www.getmonero.org/downloads/hashes.txt)

[Every other package hash is found on its GitHub page.](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/verify.sh)

---

</details>

<details>
<summary>Where are PGP keys downloaded from?</summary>

---

Keys are pre-downloaded in: `gpg/` [**HOWEVER, they are checked against the online versions before getting imported.**](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/gpg.sh) If a difference is found, you'll be dropped into a selection menu to pick which key to trust. If this happens, please search around to see what caused the difference.

* monero-bash `21958EE945980282FCB849C8D7483F6CA27D1B1D` -> [hinto-janaiyo](https://raw.githubusercontent.com/hinto-janaiyo/monero-bash/main/pgp/hinto-janaiyo.asc)
* Monero `81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92` -> [binaryFate](https://raw.githubusercontent.com/monero-project/monero/master/utils/gpg_keys/binaryfate.asc)
* P2Pool `1FCAAB4D3DC3310D16CBD508C47F82B54DA87ADF` -> [SChernykh](https://raw.githubusercontent.com/monero-project/gitian.sigs/master/gitian-pubkeys/SChernykh.asc)
* XMRig `9AC4CEA8E66E35A5C7CDDC1B446A53638BE94409` -> [XMRig](https://raw.githubusercontent.com/xmrig/xmrig/master/doc/gpg_keys/xmrig.asc)

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
<summary>I can't upgrade?</summary>

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
<summary>Where is monero-bash installed?</summary>

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
`systemd` files:
```bash
/etc/systemd/systemd/monero-bash-$PACKAGE_NAME.service
/etc/systemd/system/multi-user.target.wants/monero-bash-$PACKAGE_NAME.service
```

---
</details>

<details>
<summary>Where are packages installed?</summary>

---

```
/usr/local/share/monero-bash/bin/
```

---
</details>

<details>
<summary>Where are the config files?</summary>

---

```
~/.monero-bash/config
```

---

</details>

<details>
<summary>Where are the wallets?</summary>

---

```
~/.monero-bash/wallets
```

---

</details>

<details>
<summary>Where are the systemd files?</summary>

---

```
/etc/systemd/system/
├─ monero-bash-monerod.service
├─ monero-bash-p2pool.service
├─ monero-bash-xmrig.service

/etc/systemd/system/multi-user.target.wants/
├─ monero-bash-monerod.service
├─ monero-bash-p2pool.service
├─ monero-bash-xmrig.service
```

---

</details>

<details>
<summary>Does monero-bash have dependencies?</summary>

---

**No**

If you have a mainstream Linux distro you already have everything needed:

* `bash v5+`
* `wget`
* `systemd`
* `GNU core utilities`
* `Linux core utilities (util-linux)`

See [Distro Coverage](#Distro-Coverage) for more info.

Having either `screen` or `tmux` is nice to have for `monero-bash full <process>`, but it is optional.

---

</details>
