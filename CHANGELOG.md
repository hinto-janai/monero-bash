# v1.9.1
## Updates
* **HTTP Spoofing:** Added `TOR_BROWSER_MIMIC` option that mimics the HTTP headers used by [Tor browser](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/fake_http_headers/tor_browser)
* **HTTP Spoofing:** Added `ONLY_WGET_CURL` option to only use random [`wget/curl` versions](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/fake_http_headers/wget_curl) as the User-Agent
* **HTTP Spoofing:** More language permutations [[230] -> [4105],](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/fake_http_headers/language) more referers [[5] -> [10]](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/fake_http_headers/referer)
* **Price:** Added `XMR<->Cryptocurrency`, `Day High`, `Day Low`, and `Day Change %` to `monero-bash price`
* **Watch:** Spacing is auto-adjusted on terminal size changes
* **Status:** P2Pool stat calculation is slightly faster

## Fixes
* **Package manager:** The GitHub API returns 1-line JSON (sometimes) which causes parsing errors. This long standing issue was the cause of most update/upgrade failures, it is now fixed
* **HTTP Spoofing:** Compressed data when using `Accept-Encoding: gzip` is now decompressed properly
* **HTTP Spoofing:** Only set once when upgrading multiple packages
* **Tor:** Tests now use the fake HTTP headers
* **Status:** Fixed P2Pool `x/hour, x/day` math

---

# v1.9.0
## Updates
* **Tor Integration:** [All monero-bash connections can now be routed through Tor](https://github.com/hinto-janaiyo/monero-bash#Tor)
* **HTTP Spoofing:** [Fake HTTP headers can now be set to blend in with browsers](https://github.com/hinto-janaiyo/monero-bash#http-spoofing)
* **Config:** `monero-bash.conf/p2pool.conf` are now automatically upgraded (merged with old config)
* **Watch:** A new screen buffer is used, exiting will now return to your original terminal instead of clearing
* **Tor:** New command to test Tor connection: `monero-bash tor`

## Fixes
* **Watch:** Fixed date spacing

---

# v1.8.3
## Updates
* **Edit/Reset:** New option to specifically edit/reset either `[config]` or `[systemd]`
* **Help:** Color-coded help screen: `monero-bash help`

## Fixes
* **RPC:** Fixed trailing error text
* **Config:** Values are handled more strictly/safely
* **systemd:** Warning will be printed if an old service file is detected

---

# v1.8.2
[**Config file upgrades are not automatic, click here to see the new versions.**](https://github.com/hinto-janaiyo/monero-bash/blob/main/config)  
**You can also use `monero-bash reset <process>` to reset your configs to the new default.**
## Updates
* **Watch:** More efficient, runs smoother on slower computers
* **Watch:** Added `WATCH_REFRESH_RATE` in [`monero-bash.conf`](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monero-bash.conf) which changes second interval of `monero-bash watch`
* **systemd:** [Services are now hardened & sandboxed, see more info here](https://github.com/hinto-janaiyo/monero-bash#Security)

## Fixes
* **Status:** Only installed package versions will be listed
* **Process:** `monero-bash start all` will ignore non-installed packages
* **Process:** First time configuration prompt won't appear afterwards if skipped
* **Process:** Fixed `monero-bash stop <process>` sometimes not detecting systemd process
* **Process:** `kill` command deprecated, `stop` will reliably auto-kill after 35-seconds

---

# v1.8.1
**REMINDER: `monero-bash v2.0.0` in progress, `v1.x.x` versions will not be compatible.**
## Updates
* **Watch:** 8-bit color -> 256-bit color
* **Watch:** New command to watch refreshing stats: `monero-bash watch`
* **Watch:** **[<-] [->]** Left/Right arrow keys will switch between different processes, any other key will exit
* **Watch:** Package version, date, process uptime & state will be printed and updated live
* **RPC:** Updated help list with modern RPC calls: `monero-bash rpc help`
* **Status:** Monero info is now fetched using the RPC IP in `monero-bash.conf`, this is around `25x` faster. If no IP is found, the fallbacks are:
	- `rpc-bind-ip` & `rpc-bind-port` in `monerod.conf`
	- `localhost:18081`

## Fixes
* **systemd:** Processes will only restart on failure, with 5 second delay

---

# v1.8.0
**REMINDER: `monero-bash v2.0.0` in progress, `v1.x.x` versions will not be compatible.**
## Updates
[**Config file upgrades are not automatic, click here to see the new versions.**](https://github.com/hinto-janaiyo/monero-bash/blob/main/config)  
**You can also use `monero-bash reset <process>` to reset your configs to the new default.**
* **Config:** New config file: `p2pool.conf`, old options found in `monero-bash.conf` will be used as a fallback, new options are:
	- `Mini` Use P2Pool mini or not, fallback is `false`
	- `Out/In peers` P2Pool's default `10/10` will be used as fallback
	- `RPC/ZMQ` Ports in `monerod.conf` and P2Pool's default ports `18081/18083` will be used as fallbacks
* **Config:** All config files now contain many more advanced options (with helpful comments)
* **Status:** All stats are now formatted and/or color-coded
* **Status:** New P2Pool stats: `Total payouts`, `XMR received`, `Hashrate`, `Effort`, `Connections`
* **Status:** P2Pool stat precision increased: `1.00` -> `1.0000000`
* **Status:** P2Pool errors will be indicated (Not synced, RPC, ZMQ)
* **systemd:** New command to auto-start processes on boot: `monero-bash enable/disable <process>`
* **Package manager:** Package hash & PGP will be shown: `[8de5...fcc1] HASH OK [9AC4...4409] SIGN OK`
* **Install:** Fresh monero-bash installs will prompt for `mb` symlink creation: `monero-bash <command>` -> `mb <command>`
* **Install:** monero-bash install will list install PATH information before installing
* **Wallet:** Typed in seed during recovery mode is now visible and cleared after confirming
* **Misc:** General UI changes

## Fixes
* **Status:** P2Pool shares found before being fully synced will be excluded
* **systemd:** `monero-bash restart <process>` uses systemd's `restart` instead of `stop` -> `start`
* **Seed:** Non-english seeds will be `24` words instead of `25` to prevent incorrect CRC issue
* **Git:** Branches have been cleaned & squashed: `709` -> `348` total commits. [The original v1.7.0 branch can be found here.](https://github.com/hinto-janaiyo/monero-bash/tree/v1.7.0-pre-rebase)

---

# v1.7.0
**REMINDER: `monero-bash v2.0.0` in progress, `v1.x.x` versions will not be compatible.**
## Updates
* P2Pool: Default log level 2 -> 1
* Update: UI more clearly indicates if up-to-date or not
* Update: Exits 0 on new packages, 1 on up-to-date
* Upgrade: Exits 0 on success, 1 on failure
* Version: Exits 0 on up-to-date, 1 on old packages
* Misc: General UI changes

## Fixes
* `status`: Fixed always exiting 1
* `monero-bash seed`: Fixed, but still experimental
* Safety: Using a non-GNU/Linux OS or a Bash version less than v5 will error & exit

---

# v1.6.0 - RECOMMENDED UPDATE
## Updates
* **v1 END OF LIFE**
	- `monero-bash v2.0.0` in progress, a rewrite to make the code safer, faster, and easier to debug
	- Major version upgrades (v1.X.X > v2.X.X) will include changes that break backwards compatability
	- `v1.X.X` versions will still function, but you will not be able to upgrade `monero-bash` past `v1.9.9`

## Fixes
* **systemd**
	- Service file permission fix (700 > 600)
* **P2Pool**
	- Fetch PGP key from [GitHub](https://github.com/monero-project/gitian.sigs/blob/master/gitian-pubkeys/SChernykh.asc) instead of [p2pool.io](https://p2pool.io/SChernykh.asc)
* **Misc**
	- Fix text coloring issues

---

# v1.5.3
## Updates
* **Config**
	- Small updates to `monerod.conf` & `monero-wallet-cli.conf`

## Fixes
* **Mine**
	- `monero-bash config` no longer prompts for difficulty (p2pool 2.1 auto-selects diff)

* **Install**
	- `monero-bash` properly errors out if not installed on GNU/Linux

---

# v1.5.2
## Updates
* **Status**
	- `p2pool` prints latest payout

## Fixes
* **Process**
	- `monerod` no longer asks for sudo

* **Wallet**
	- slightly more robust wallet name parsing

---

# v1.5.1
## Updates
* **Process**
	- Edit `AUTO_HUGEPAGES` to toggle auto hugepage allocation and `HUGEPAGES` to set custom hugepage size in [monero-bash.conf.](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monero-bash.conf) Hugepage is only set on `monero-bash start all` command.

## Fixes
* **RPC**
	- fixed contacting other monerod's for RPC calls

---

# v1.5
## Updates
* **Monerod JSON RPC interface**
	- Usage  
		- `monero-bash rpc [host:port] method [name:value ...]`  
	- Examples  
		- `monero-bash rpc get_block`  
		- `monero-bash rpc node.community.rino.io:18081 get_block`  
		- `monero-bash rpc 127.0.0.1:18081 get_block height:123456`  
	- Configuration  
		- Default IP+Port: `localhost:18081`  
		- You can specify a different IP+Port or configure a permanent default in [`monero-bash.conf`](https://github.com/hinto-janaiyo/monero-bash/blob/main/config/monero-bash.conf)  
		- To list all methods: `monero-bash rpc` or see [`https://www.getmonero.org/resources/developer-guides/daemon-rpc.html`](https://www.getmonero.org/resources/developer-guides/daemon-rpc.html)  
	- Credit  
		- Original code was taken and modified from [jtgrassie's xmrpc](https://github.com/jtgrassie/xmrpc)  
		- 90% of the work done by [plowsof](https://github.com/plowsof)  

* **Status**
	- `p2pool` displays latest share found & shares per day

## Fixes
* **P2Pool**
	- mini pool fix - reconfigure with `monero-bash config` or edit `p2pool.json`
	- `p2pool.cache/p2pool_peers.txt` are kept between upgrades for faster sync

---

# v1.4.1
## Updates
* **GPG**
	- gpg verification is now **always on** when installing/upgrading packages
	- `gpg toggle` & `gpg import` deprecated

## Fixes
* **Update**
	- `update` bug fix

* **Wallet**
	- wallet files (key images, signed transactions) are now created in `~/.monero-bash`

* **Process**
	- `xmrig` hugepage = 1280, the rest are 1024

---

# v1.4
## Updates
* **Status**
	- `status` produces general info for all processes: PID, CPU usage, uptime
	- `p2pool` shows submitted shares & shares/per hour
	- `xmrig` shows accepted shares & hashrate
	- no longer needs sudo privileges

* **Process**
	- `reset` command to reset your configs & systemd services to the default

## Fixes
* **Traps**
	- traps are more strict (less chance for data corruption if interrupted during operation)

* **Error**
	- error messages are more helpful

---

# v1.3
## Updates
* **Process**
	- Hugepages are individually prepared per process. Only `monero-bash start all` set hugepages before, now anytime any process is started, whether attached or not, it will set its own hugepages

## Fixes
* **Process**
	- `monero-bash full p2pool` properly works now

---

# v1.2.2
## Fixes
* **Seed**
	- Added warning when using builtin seed generator


# v1.2.1
## Updates
* **Seed**
	- `monero-bash seed` or `monero-bash seed <LANGUAGE>` to quickly generate 25-word Monero seed

## Fixes
* **Wallet**
	- Fixed infinite error printing during wallet_Collision function

---

# v1.2
## Updates
* **Package manager**
	- `monero-bash install/upgrade/remove` now lists packages that will change
	- `monero-bash update && monero-bash upgrade` is now essentially `sudo apt update && sudo apt upgrade`

* **Process**
	- `monero-bash <command> daemon` can also be invoked with `monero-bash <command> <monero/monerod>`

---

# v1.1.2
## Fixes
* **INSTALL FIX**
	- Hashlist is properly produced during install

---

# v1.1.1 - BROKEN INSTALL DO NOT USE
## Updates
* **Wallet**
	- `monero-bash` command can now `recover` wallets through standard seeds
	- If wallet name collides with option, extra prompt will appear
	- More clear color distinction in wallet menu

* **Status**
	- `monero-bash status` only prints status of installed packages
	- More stats for `XMRig`

---

# v1.1.0
## Updates
* **Processes**
	- `monero-bash restart <process>` command
	- `monero-bash edit <process>` to edit systemd service files

* **Wallet**
	- `monero-bash` command can create `view-only` wallets
		- This requires the ***Main Address*** and ***Private Viewkey*** which can be get with the: `address` and `viewkey` commands while inside monero-wallet-cli

* **GPG**
	- If `monero-bash gpg` is toggled on, keys will automatically be imported on installation/upgrade of package
	- `monero-bash gpg <author/package/all>` to select which keys to import manually

---

# v1.0.0
## Official Release
* See the [main repo](https://github.com/hinto-janaiyo/monero-bash) for all information on monero-bash

---

# v0.7
## Updates
* **P2Pool mining integrated**
	- `monero-bash mine config` to configure basic mining settings
	- `monero-bash mine start` to start `monerod, p2pool, xmrig`
	- `monero-bash mine stop` to stop them

* **watch**
	- `monero-bash watch <daemon/p2pool/xmrig>` to watch live output of process

* **GPG integrated**
	- `monero-bash gpg` toggle on/off GPG verification when upgrading/installing
	- `monero-bash gpg import` compare local/online keys, import if OK
		- Monero - [binaryfate](https://github.com/monero-project/monero/blob/master/utils/gpg_keys/binaryfate.asc)
		- monero-bash - [hinto-janaiyo](https://github.com/hinto-janaiyo/monero-bash/blob/master/gpg/hinto-janaiyo.asc)
		- XMRig - [xmrig](https://github.com/xmrig/xmrig/blob/master/doc/gpg_keys/xmrig.asc)
		- P2Pool - [SChernykh](https://p2pool.io/SChernykh.asc)

* **backup**
	- `monero-bash backup` encrypt and backup your /wallet/ folder
	- `monero-bash decrypt` decrypt the encrypted backup.tar.gpg

## To be added
* RPC/Daemon API integration

---

# v0.6.1
## Updates
* `monero-bash install/upgrade <package> verbose` option to print detailed download information
* If a hash error occurs, the ONLINE hash and LOCAL hash will be printed for comparison
* GPG keys have been added in /monero-bash/gpg/, but not integrated yet

## To be added
* Automatic P2Pool mining
* GPG key verification for binaries
* RPC/Daemon API integration
* Automatic encrypted wallet backups

## Added but not usable yet
* XMRig, P2Pool can be installed but not invoked
* systemd intergrated, but not invokable
* `watch` command works, but not invokable

---

# v0.6
## Updates
* Package manager is 2x~ faster (less API calls)
* Canceling mid-upgrade is much safer (proper clean-up and package revert)

## To be added
* Automatic P2Pool mining
* GPG key verification for binaries
* RPC/Daemon API integration
* Automatic encrypted wallet backups

## Added but not usable yet
* XMRig, P2Pool can be installed but not invoked
* systemd intergrated, but not invokable
* `watch` command works, but not invokable

---

# v0.5
## Updates
* Full package manager functions
* GitHub API is used for downloads, HTML filter for backup
* More error, safety checks
* Updated readme and documentation to include future features
* `monero-bash` creates personal `.monero-bash` folder

## To be added
* Automatic P2Pool mining
* GPG key verification for binaries
* RPC/Daemon API integration
* Automatic encrypted wallet backups

## Added but not usable yet
* XMRig, P2Pool can be installed but not invoked
* systemd intergrated, but not invokable
* `watch` command works, but not invokable
