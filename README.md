# monero-bash (WORK IN PROGRESS)
>a wrapper for monero written in bash

![monero-bash.png](https://i.ibb.co/x8zcf7p/monero-bash.png)

## about
monero-bash does what `bash` normally does, it glues together multiple programs in a more automatic fashion.

in this case:
* monero daemon
* monero-wallet-cli
* monero-rpc
* (automatic xmrig+p2pool mining soon...)

monero-bash abstracts `monero-cli` commands into interactive prompts and `linux-like` syntax

while monero-bash is helpful for people who just want automation, it's also just as powerful as monero-cli because:
```
it is essentially a bunch of bash scripts invoking monero-cli
```

and so, any `monerod.conf` or `monero-wallet-cli.conf` that you may have in your `.bitmonero` folder, can be used by monero-bash

**[for full details and usage, click here](https://github.com/hinto-janaiyo/monero-bash/blob/main/docs/help.md)**

## features
**monero-bash acts as a general meta-program:**
* `monero-bash` initial configuration, wallet manager
* `monero-bash update` `monero-bash upgrade` check/install latest version of `monero-cli` (and verify SHA256SUMS automatically)
* `monero-bash price` fetch price API for USD and EURO
* `monero-bash daemon <option>` control the monero daemon

**to be added:**
* automatic p2pool mining
* GPG key verification for binaries
* RPC/Daemon API integration
* "offline" mode, block all internet-related commands
* daemon inside screen session
* automatic encrypted wallet backups

## if you want to beta-test:
[download the latest release, here](https://github.com/hinto-janaiyo/monero-bash/releases/latest)

or

```
git clone https://github.com/hinto-janaiyo/monero-bash &&
cd monero-bash &&
./monero-bash
```
*note1: **ALWAYS clone the main branch,** the others have untested bash functions that may blow up your computer*
*note2: **GNU/LINUX ONLY**, running this on MacOS or BSD is a bad idea (unless you have GNU utils installed)*

after the initial configuration, it will be added to PATH via your user's `.bashrc`, so:
```
monero-bash
```
will work anywhere
