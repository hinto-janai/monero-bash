# monero-bash guide:
* [Usage](#usage)
* [Folder Structure](#folder-structure)
* [Configuration](#configuration)
* [systemd](#systemd)

## Usage
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

daemon                        print status of daemon
daemon start                  start the daemon (detached)
daemon stop                   gracefully stop the daemon
daemon kill                   forcefully kill all daemon processes
daemon full                   start the daemon attached

mine start                    start monerod, xmrig, p2pool in the background
mine stop                     stop monerod, xmrig, p2pool

xmrig full                    start xmrig attached
p2pool full                   start p2pool attached

watch daemon                  show live daemon output
watch xmrig                   show live xmrig output
watch p2pool                  show live p2pool output

gpg                           toggle GPG verification of binaries
gpg import                    import GPG keys of package authors
backup                        encrypt and backup your /wallets/
decrypt                       decrypt wallets.tar.gpg

status                        print useful stats
list                          list wallets
size                          show size of monero-bash folders
price                         fetch price data from cryptocompare.com API
integrity                     check hash integrity of monero-bash

help                          show this help message
```

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

[Refer to this documentation to learn more](https://monerodocs.org/interacting/monero-config-file)

For `monero-bash` specific configuration, edit `/.monero-bash/config/monero-bash.conf`
```
######################
# monero-bash config #
######################
# monerod
DATA_PATH=""                     path of .bitmonero

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

If you'd like to directly invoke `monerod`, `XMRig` and `P2Pool`:
* `monero-bash daemon full`
* `monero-bash xmrig full`
* `monero-bash p2pool full`
These will launch them in the current terminal
