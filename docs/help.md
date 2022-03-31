# monero-bash guide:
* [Usage](#usage)
* [Folder Structure](#folder-structure)
* [Configuration](#configuration)

## Usage
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

## Folder Structure
The `/monero-bash/` folder starts like this:

```
monero-bash/
├─ monero-bash       main script
├─ bin               where package binaries live
├─ config            config files for all packages
├─ src               monero-bash source code
├─ old               temp folder when upgrading
```
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
*note:* the `.bitmonero/` folder path can be set anywhere

When upgrading, `monero-bash` moves packages into a timestamped folder inside `old` instead of deleting them (to change that, see the next section)


## Configuration
If you already have a custom `monerod.conf` or `monero-wallet-cli.conf`, just put them in your `.bitmonero` folder and monero-bash will use them

[Refer to this documentation to learn more](https://monerodocs.org/interacting/monero-config-file)

For `monero-bash` specific configuration, edit `/.monero-bash/config/monero-bash.conf`
```
######################
# monero-bash config #
######################
# monerod
DATA_PATH=""                            the path of /.bitmonero/
SYSTEMD_MONEROD="false"                 use systemd to control monerod 

# monero-wallet-cli
AUTO_START_DAEMON="true"                auto-start daemon on wallet open
AUTO_STOP_DAEMON="true"                 auto-stop daemon on wallet close

# monero-rpc

# monero-bash
PRICE_API_IP_WARNING="true"             warn when checking price
OLD_FOLDER="true"                       move old packages into old, instead of deleting

# p2pool
SYSTEMD_P2POOL="true"                   use systemd to control p2pool

# xmrig
SYSTEMD_XMRIG="true"                    use systemd to control xmrig

# updates (only checks)
AUTO_UPDATE_MONERO="false"              check for update on startup
AUTO_UPDATE_MONERO_BASH="false"
AUTO_UPDATE_P2POOL="false"
AUTO_UPDATE_XMRIG="false"
```
If `SYSTEMD_x` is set to `false`, monero-bash will directly invoke the program. if set to `true`, monero-bash will create a `.service` file and launch the program as a `systemd` service instead. `systemd` MUST be used if you want to use the `monero-bash watch` command, as it uses `journalctl`
