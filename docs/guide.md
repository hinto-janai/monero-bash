# monero-bash configuration
* [Mining](#mining)
* [Commands](#Commands)
* [Config](#config)

## Mining
To quickly start mining on P2Pool, make sure you have all the packages:
* `monero-bash install monero p2pool xmrig`

Configure basic mining settings:
* `monero-bash config p2pool xmrig --quick`

You can then:
* `monero-bash start monero p2pool xmrig`

Remember, you are using your own node to mine. The blockchain has to be fully synced!

## Commands
```
USAGE: monero-bash [command] <argument> [--option]

WALLET
    monero-bash                                Open interactive wallet menu
    list                                       List wallets
    new     <wallet type>                      Enter wallet creation mode

PACKAGE
    install <packages> [--verbose] [--force]   Install one/multiple packages
    remove  <packages> [--verbose]             Remove one/multiple packages
    update  [--verbose]                        Check for package updates
    upgrade [--verbose] [--force]              Upgrade all out-of-date packages

PROCESS
    full    <process>                          Start <process> fully attached in foreground
    config  <processes>                        Enter interactive configuration for <process>
    default <processes> [--config] [--systemd] Reset your config/systemd file to the default

SYSTEMD
    start   <processes>                        Start process as systemd background process
    stop    <processes>                        Gracefully stop systemd background process
    kill    <processes>                        Forcefully kill systemd background process
    restart <processes>                        Restart systemd background process
    enable  <processes>                        Enable <process> to auto-start on computer boot
    disable <processes>                        Disable <process> from auto-starting on computer boot
    edit    <processes>                        Edit systemd service file
    refresh <processes>                        Refresh your systemd service file to match your config
    watch   <processes>                        Watch live output of systemd background process

STATS
    status                                     Print status of all running processes
    size                                       Print size of all packages and folders
    version                                    Print current package versions

OTHER
    changes <package> [--print]                View the latests changes for <package>
    rpc     <JSON-RPC method> [--verbose]      Send a JSON-RPC call to monerod
    help    <command>                          Print help for a command, or all if none specified
```

## Config
To edit `monero-bash` behavior, edit its config file: `$HOME/.monero-bash/config/monero-bash.conf`

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

#---------------------------------------------------------------------------------------------------# xmrig
# by default, monero-bash runs xmrig as root for hugepages.
# to disable this and run xmrig as the
# no-privilege/no-login "monero-bash" user, set to false:
# usage: [true|false]
XMRIG_ROOT=true

#---------------------------------------------------------------------------------------------------# monerod rpc
# monerod ip to contact when using "monero-bash rpc"
# usage: [IP:PORT]
RPC_IP=localhost:18081
```

