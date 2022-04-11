# monero-bash guide:
* [Mining](#mining)
* [Usage](#usage)
* [Configuration](#configuration)
* [File Structure](#file-structure)
* [systemd](#systemd)

## Mining
To quickly start mining on P2Pool, make sure you have all the packages:
* `monero-bash install all`

Configure basic mining settings:
* `monero-bash config`

You can then:
* `monero-bash start all`

Remember, you are using your own node to mine. The blockchain has to be fully synced!


## Usage
<details>
<summary>Click to reveal full command usage</summary>

```
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

## Configuration
If you already have a custom `monerod.conf` or `monero-wallet-cli.conf`, put them in `.monero-bash/config/` folder and monero-bash will use them. [Refer to this documentation for monero.conf files](https://monerodocs.org/interacting/monero-config-file)

If you have a custom xmrig or p2pool `config.json`, rename them to:
* `xmrig.json`
* `p2pool.json`

and put them in the `.monero-bash/config` folder

[Check here for xmrig configuration](https://xmrig.com/docs/miner/config)

P2Pool does not use the xmrig.json wallet!

Please setup P2Pool with `monero-bash config` or edit `.monero-bash/config/monero-bash.conf`
```
######################
# monero-bash config #
######################
# monero-bash
AUTO_START_DAEMON="true"         auto-start daemon on wallet open
AUTO_STOP_DAEMON="true"          auto-stop daemon on wallet close
AUTO_UPDATE="false"              check for all updates on wallet open
PRICE_API_IP_WARNING="true"      warn when checking price API

# p2pool
DAEMON_IP="127.0.0.1"            monerod IP to connect to (default: 127.0.0.1/localhost)
WALLET=""                        wallet address to send payouts to
LOG_LEVEL="2"                    log/console output level (default: 2, options are 0-6)
EXTRA_FLAGS="--mini"             any extra flags to start p2pool with (default: --mini)
```

## File Structure
Here are all the folders/files created by `monero-bash` after installation:

**INSTALLATION PATH**
```
/usr/local/share/monero-bash/
├─ monero-bash          main script
├─ config               backup config files
├─ gpg                  gpg keys
├─ src                  source code

/usr/local/bin/monero-bash
├─ monero-bash          symlink to main script
```

**HOME FOLDER**
```
/home/user/.monero-bash/
├─ config               config files
├─ wallets              wallet files
├─ .bitmonero           monero blockchain/data folder
```
*note:* the `.bitmonero` folder path can be set anywhere

**SYSTEMD SERVICES**
```
/etc/systemd/system/
├─ monero-bash-monerod.service
├─ monero-bash-p2pool.service
├─ monero-bash-xmrig.service
```

**TEMP FILES**
```
/tmp/
├─ monero-bash.XXXXXXXXXX
├─ monero-bash-hash.XXXXXXXXXX
├─ monero-bash-sig.XXXXXXXXXX
├─ monero-bash-gpg.XXXXXXXXX
├─ monero-bash-service.XXXXXXXXX
```
*note:* monero-bash `/tmp/` folders are deleted after upgrade, and wiped if computer is rebooted. All files created by `monero-bash` have `700/600` permissions or are within folders that have those permissions. This is to prevent any other user from reading the data. After uninstalling monero-bash, all these files are deleted with the exception of `$HOME/.bitmonero` if you picked that as your data directory.

## systemd
monero-bash creates and uses systemd service files to control:
* `monerod`
* `xmrig`
* `p2pool`

If you'd like to directly invoke a program:
* `monero-bash full <daemon/p2pool/xmrig>`

This will launch them in the current terminal

`monerod` and `p2pool` are ran as the $USER, and `xmrig` is ran as `root`. If you'd like to change that, edit `/etc/systemd/system/monero-bash-xmrig.service`. Note that without root, your hashrate may be low.
