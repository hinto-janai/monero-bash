# monero-bash guide:
* [Mining](#mining)
* [Usage](#usage)
* [Folder Structure](#folder-structure)
* [Configuration](#configuration)
* [systemd](#systemd)

## Mining
To quickly start mining on P2Pool, make sure you have all the packages:
* `monero-bash install all`

Configure basic mining settings:
* `monero-bash mine config`

You can then:
* `monero-bash mine start`

Remember, you are using your own node to mine. The blockchain has to be fully synced!


## Usage
<details>
<summary>Click to reveal full command usage</summary>

```
monero-bash usage:            monero-bash <option> <more options>

monero-bash                   the default command will open wallet selection
uninstall                     uninstall monero-bash and remove /.monero-bash/

install <pkg>                 install <all> or a specific package
install <pkg> verbose         print detailed download information
remove <pkg>                  remove <all> or a specific package
remove <pkg> force            forcefully remove a package

update                        only CHECK for updates
upgrade <pkg>                 upgrade <all> or a specific package
upgrade <pkg> force           forcefully upgrade packages
upgrade <pkg> verbose         print detailed download information
version                       print installed package versions

mine config                   configure mining settings
mine start                    start monerod, xmrig, p2pool in the background
mine stop                     stop monerod, xmrig, p2pool

start <daemon/xmrig/p2pool>   start process detached (background)
stop <daemon/xmrig/p2pool>    gracefully stop the process
kill <daemon/xmrig/p2pool>    forcefully kill the process
full <daemon/xmrig/p2pool>    start the process attached (foreground)

watch <daemon/xmrig/p2pool>   watch live output of process

gpg                           toggle GPG verification of binaries
gpg import                    import GPG keys of package authors
backup                        encrypt and backup your /wallets/
decrypt                       decrypt backup.tar.gpg

status                        print status of all running processes
list                          list wallets
size                          show size of monero-bash folders
price                         fetch price data from cryptocompare.com API
integrity                     check hash integrity of monero-bash

help                          show this help message

```
</details>

## Folder Structure

After installation, monero-bash will:
* move itself to `/usr/local/share/monero-bash`
* add itself to PATH
* create a `.monero-bash` in your $HOME

```
/home/user/.monero-bash/
├─ config               config files
├─ wallets              wallet files
├─ .bitmonero           monero blockchain/data folder
```
*note:* the `.bitmonero` folder path can be set anywhere

## Configuration
If you already have a custom `monerod.conf` or `monero-wallet-cli.conf`, put them in your `.bitmonero` folder and monero-bash will use them

[Refer to this documentation for monero.conf files](https://monerodocs.org/interacting/monero-config-file)

If you have a custom xmrig or p2pool `config.json`, rename them to:
* `xmrig.json`
* `p2pool.json`
and put them in the `.monero-bash/config` folder

`P2Pool` does not use `xmrig.json` config settings! Please setup P2Pool with `monero-bash mine config`

[Check here for xmrig configuration](https://xmrig.com/docs/miner/config)

For `monero-bash` configuration, edit `/.monero-bash/config/monero-bash.conf`
```
######################
# monero-bash config #
######################
# monerod
DATA_PATH=""                     path of .bitmonero

# p2pool
DAEMON_IP="127.0.0.1"            IP used if P2Pool is invoked directly/config is not setup
WALLET=""                        wallet used if P2Pool is invoked directly/config is not setup

# monero-wallet-cli
AUTO_START_DAEMON="true"         auto-start daemon on wallet open
AUTO_STOP_DAEMON="true"          auto-stop daemon on wallet close

# monero-rpc

# monero-bash
PRICE_API_IP_WARNING="true"      warn when checking price API

# updates (only checks)
AUTO_UPDATE="false"              check for updates on wallet open
```

## systemd
monero-bash creates and uses systemd service files to control:
* `monerod`
* `xmrig`
* `p2pool`

This allows these program to auto-restart, start on boot, and allows monero-bash to use `journalctl`. The `monero-bash watch` command uses the output of journalctl to show live, refreshing output of the programs.

If you'd like to directly invoke a program:
* `monero-bash full <daemon/p2pool/xmrig>`
This will launch them in the current terminal
