# monero-bash

![monero-bash](https://user-images.githubusercontent.com/101352116/183257273-6224fa0d-cb10-4a3f-bb5d-057df7c0e18e.jpg)

## Contents
* [About](#About)
* [Features](#Features)
* [Distro Coverage](#Distro-Coverage)
* [Install](#Install)
* [Commands](#Commands)
* [Usage](#Usage)
	- [Wallet](#Wallet)
	- [Config](#Config)
	- [Mining](#Mining)
	- [Watch](#Watch)
	- [Security](#Security)
* [Privacy](#Privacy)
	- [Tor](#Tor)
	- [HTTP Spoofing](#HTTP-Spoofing)
	- [Connections](#Connections)
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
* 📦 **`PKG MANAGER`** Automatic download/verification/upgrading of packages
* 💵 **`WALLET MENU`** Interactive menu for selecting/creating wallets
* 👺 **`SYSTEMD`** Control **monerod/p2pool/xmrig** as background processes
* ⛏️ **`MINING`** Interactive mining configuration, ***built for P2Pool***
* 📈 **`STATUS`** Display stats (CPU usage, P2Pool shares, Hashrate, etc)
* 👁️ **`WATCH`** Watch live output of processes or general status
* 🧅 **`TOR`** Route connections through Tor
* 📄 **`RPC`** **monerod** JSON-RPC interface
* 🔒 **`GPG`** Encrypt and backup your wallets

## Distro Coverage
| Linux Distribution                   | Version            | Status | Info |
|--------------------------------------|--------------------|--------|------|
| [Debian](https://www.debian.org)     | 11, 10             | 🟢     |
| [Ubuntu](https://ubuntu.com)         | LTS 22.04, 20.04   | 🟢     |
| [Pop!\_OS](https://pop.system76.com) | LTS 22.04, 20.04   | 🟢     |
| [Linux Mint](https://linuxmint.com)  | 21, 20.03          | 🟢     |
| [Fedora](https://getfedora.org)      | Workstation 36, 35 | 🔴     | SELinux disables `systemd` functionality
| [Arch Linux](https://archlinux.org)  |                    | 🟡     | `wget` must be installed
| [Manjaro](https://manjaro.org)       | 21.3.6             | 🟢     |
| [Gentoo](https://www.gentoo.org)     |                    | 🔴     | `wget` & `systemd` must be installed

## Install
[**To install: download the latest release here, extract and run monero-bash**](https://github.com/hinto-janaiyo/monero-bash/releases/latest)
```bash
tar -xf monero-bash-v1.9.1.tar
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

## Commands
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

tor                                                   Test Tor connection
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

## Privacy
### Tor
monero-bash supports routing all of its traffic through the [Tor network.](https://en.wikipedia.org/wiki/Tor_(network)) Options in [`monero-bash.conf`](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monero-bash.conf):
```
USE_TOR                Enable connections via Tor
TEST_TOR               Run tests to make sure Tor works before making any connections
TOR_PROXY              Tor SOCKS proxy IP/port to use (default: 127.0.0.1:9050)
TOR_QUIET              Silence Tor set-up messages
```
[`torsocks`](https://github.com/dgoulet/torsocks) is the backend library used to route the traffic through Tor, although it is not necessary to download, only access to a regular Tor SOCKS proxy is needed.

**Quick setup guide for Tor (only for proxy purposes):**

*	<details>
	<summary>Debian/Ubuntu/Pop!_OS/Linux Mint</summary>

	```
	sudo apt install tor
	sudo systemctl start tor.service
	```
	</details>
*	<details>
	<summary>Arch Linux/Manjaro</summary>

	```
	sudo pacman -S tor
	sudo systemctl start tor.service
	```
	</details>
*	<details>
	<summary>Fedora</summary>

	```
	sudo dnf install tor
	sudo systemctl start tor.service
	```
	</details>
*	<details>
	<summary>Gentoo</summary>

	```
	sudo emerge --ask net-vpn/tor
	sudo systemctl start tor.service
	```
	</details>

**Things to note:**
* ***This ONLY affects monero-bash.*** This will not make your Monero node run through Tor, see [monerod.conf](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monerod.conf) & [monero-wallet-cli.conf](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monero-wallet-cli.conf) if you'd like to run Monero through Tor

* If the torsocks shared object file is already detected on your computer: `/usr/lib/x86_64-linux-gnu/torsocks/libtorsocks.so` or `/usr/lib/torsocks/libtorsocks.so`, it will be used. If it isn't found (or even installed), [monero-bash will use the one it comes with](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/libtorsocks.so)

* The built-in shared object file is from `torsocks v2.3.0` with a SHA256 hash of `91464358f1358e3dfbf3968fad81a4fff95d6f3ce0961a1ba1ae7054b6998159`, this should match against Debian's APT version. You are free to replace it with your own (or just install torsocks), just make sure it is placed in the correct path: `/usr/local/share/monero-bash/src/libtorsocks.so`

* The actual wrapper script `/usr/bin/torsocks` has been [rewritten and modified to reflect monero-bash's use-case (remove macOS code, Tor shell, etc)](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/torsocks.sh) and it will always be used over any system versions found

* Tor will not be used for RPC calls to `localhost/127.0.0.1/192.168.x.x`

---

### HTTP Spoofing
monero-bash has options to spoof the HTTP headers sent during connections such that you blend in with web-browsers. Options in [`monero-bash.conf`](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monero-bash.conf):
```
FAKE_HTTP_HEADERS      Send random (weighted) browser-like HTTP headers instead of [Wget/VERSION]
TOR_BROWSER_MIMIC      Mimic the HTTP headers that [Tor browser] uses
ONLY_USER_AGENT        Only send a random [User-Agent] instead of all the normal HTTP headers
ONLY_WGET_CURL         Only use random [2016-2022] versions of Wget/Curl as the User-Agent
HTTP_HEADERS_VERBOSE   Print the HTTP headers selected before making a connection
```

**Things to note:**
* Some HTTP header values are favored more instead of being purely randomly selected, e.g. English is weighted more than other languages

* The list of fake HTTP headers can be found in plain-text at [`docs/fake_http_headers`](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/fake_http_headers) and the selection process in the source code at [`src/func/header.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/header.sh)

* Tor proxying must be enabled for `TOR_BROWSER_MIMIC` to work

* `ONLY_USER_AGENT` & `ONLY_WGET_CURL` will always be enabled when sending a non-local RPC call

* Fake HTTP headers will not used for RPC calls to `localhost/127.0.0.1/192.168.x.x`

---

### Connections
For transparency and ease-of-mind, here's all the connections `monero-bash` makes:

| Domain                   | Why                                                                                       | When | Where |
|--------------------------|-------------------------------------------------------------------------------------------|------|-------|
| https://github.com       | Fetching metadata information on packages + Tar/hash/signature/key download | `monero-bash update`, `monero-bash upgrade` | [`download.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/download.sh) [`eol.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/eol.sh) [`gpg.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/gpg.sh) [`verify.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/verify.sh) [`version.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/version.sh)
| https://getmonero.org  | Tar/hash/signature/key download specifically for Monero (not hosted on GitHub) | When upgrading Monero | Same as above
| https://cryptocompare.com | XMR price data | `monero-bash price` | [`price.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/price.sh)
| https://torproject.com | Test Tor connection + Get exit IP | `monero-bash tor` or when using any internet-related command with `TEST_TOR` enabled | [`torsocks.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/torsocks.sh)
| RPC | Monero RPC calls, the IP given in `DAEMON_RPC_IP` will be contacted | `monero-bash rpc` | [`rpc.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/rpc.sh)
| DNS | DNS connections will usually be handled by your OS (or whatever custom DNS setup you have). If using Tor, the `torsocks` wrapper will route all DNS requests through the Tor network automatically | Any internet-related command when DNS isn't already cached | All of the above

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

**Optional:**
* `tor` is obviously required if using monero-bash's Tor options
* `screen` or `tmux` is nice to have for `monero-bash full <process>`

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
<summary>Where are the fake HTTP headers sourced from?</summary>

---

[A combination of this recent list on Github](https://gist.github.com/pzb/b4b6f57144aea7827ae4) and the free listings on [whatismybrowser.com.](https://developers.whatismybrowser.com/useragents/explore) Their full list is behind a 50$ paywall...! Their free lists have 1000s of common User-Agents, but they do not provide an API or an easy way to scrape it cleanly, probably on purpose. If you know how to use `grep/sed` (or Python) though, then it's easy :)

The full list monero-bash uses (including more than just User-Agents) can be found in plain-text and Bash array form at [`docs/fake_http_headers`](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/fake_http_headers) and the selection process can be found in the source code at [`src/func/header.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/header.sh)

---

</details>

<details>
<summary>Where are the [monero-bash seed] mnemonics sourced from?</summary>

---

[The Monero GitHub repo.](https://github.com/monero-project/monero/tree/master/src/mnemonics)

Plain-text and Bash array versions of the seed mnemonics for all languages can be found in this repo at [`docs/seed`](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/seed) or directly in the code at [`src/func/seed.sh`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/seed.sh)

---

</details>
