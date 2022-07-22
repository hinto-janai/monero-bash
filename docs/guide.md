# monero-bash configuration
* [Mining](#mining)
* [Commands](#Commands)
* [Config](#config)
* [File Structure](#file-structure)
* [systemd](#systemd)

## Mining
To quickly start mining on P2Pool, make sure you have all the packages:
* `monero-bash install monero p2pool xmrig`

Configure basic mining settings:
* `monero-bash config`

You can then:
* `monero-bash start monero p2pool xmrig`

Remember, you are using your own node to mine. The blockchain has to be fully synced!

## Commands
```
monero-bash usage: monero-bash <option> <more options>

monero-bash                              open wallet menu
uninstall                                uninstall ALL OF monero-bash
rpc                                      send a JSON RPC call to monerod

install <all/pkg>                        install <all> or a specific package
install <all/pkg> verbose                print detailed download information
remove  <all/pkg>                        remove <all> or a specific package

update                                   CHECK for updates
upgrade                                  upgrade all packages
upgrade <pkg>                            upgrade a specific package
upgrade <all/pkg> force                  forcefully upgrade packages
upgrade <all/pkg> verbose                print detailed download information
version                                  print installed package versions

config                                   configure MINING settings
start   <all/daemon/xmrig/p2pool>        start process detached (background)
stop    <all/daemon/xmrig/p2pool>        gracefully stop the process
kill    <all/daemon/xmrig/p2pool>        forcefully kill the process
restart <all/daemon/xmrig/p2pool>        restart the process
full    <daemon/xmrig/p2pool>            start the process attached (foreground)
watch   <daemon/xmrig/p2pool>            watch live output of process
edit    <daemon/xmrig/p2pool>            edit systemd service file
reset   <bash/daemon/xmrig/p2pool>       reset your configs/systemd to default

backup                                   encrypt and backup your /wallets/
decrypt                                  decrypt backup.tar.gpg

status                                   print status of all running processes
seed                                     generate random 25-word Monero seed
list                                     list wallets
size                                     show size of monero-bash folders
price                                    fetch price data from cryptocompare.com API
integrity                                check hash integrity of monero-bash

help                                     show this help message
```

## Config
monero-bash's config files live in `$HOME/.monero-bash/config`

```
######################
# monero-bash config #
######################

#---------------------------------------------------------------------------------------------------# monero-bash
# auto-start & auto-stop monerod when opening/closing a wallet
# usage: [true|false]
AUTO_START_MONEROD=true
AUTO_STOP_MONEROD=true

# auto-update packages when opening monero-bash
# usage: [true|false]
AUTO_UPDATE=false

#---------------------------------------------------------------------------------------------------# monerod rpc
# monerod ip to contact when using "monero-bash rpc"
# usage: [IP:PORT]
RPC_IP=127.0.0.1:18081

# show verbose messages when using rpc
# usage: [true|false]
RPC_VERBOSE=false

#---------------------------------------------------------------------------------------------------# debug
# print debug messages for all monero-bash operations
# usage: [true|false]
MONERO_BASH_DEBUG=false

# print even more verbose debug info (command line number, function calls)
MONERO_BASH_DEBUG_VERBOSE=false
```

