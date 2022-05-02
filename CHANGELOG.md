#v1.5.1
## Updates
* **monero-bash.conf**
	- `AUTO_HUGEPAGES` setting to toggle auto hugepage allocation for processes


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


# v1.3
## Updates
* **Process**
	- Hugepages are individually prepared per process. Only `monero-bash start all` set hugepages before, now anytime any process is started, whether attached or not, it will set its own hugepages

## Fixes
* **Process**
	- `monero-bash full p2pool` properly works now


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


# v1.2
## Updates
* **Package manager**
	- `monero-bash install/upgrade/remove` now lists packages that will change
	- `monero-bash update && monero-bash upgrade` is now essentially `sudo apt update && sudo apt upgrade`

* **Process**
	- `monero-bash <command> daemon` can also be invoked with `monero-bash <command> <monero/monerod>`


# v1.1.2
## Fixes
* **INSTALL FIX**
	- Hashlist is properly produced during install


# v1.1.1 - BROKEN INSTALL DO NOT USE
## Updates
* **Wallet**
	- `monero-bash` command can now `recover` wallets through standard seeds
	- If wallet name collides with option, extra prompt will appear
	- More clear color distinction in wallet menu

* **Status**
	- `monero-bash status` only prints status of installed packages
	- More stats for `XMRig`


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


# v1.0.0
## Official Release
* See the [main repo](https://github.com/hinto-janaiyo/monero-bash) for all information on monero-bash


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
