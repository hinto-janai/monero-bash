# monero-bash guide:
* [Usage](#usage)
* [Folder Structure](#folder-structure)
* [Configuration](#configuration)


## Usage
```
monero-bash usage: monero-bash <option> <more options>

# SETUP #
config            configure monero-bash settings
uninstall         remove /monero-bash/ folder and remove from PATH

# UPDATE #
update            only CHECK for updates
upgrade           upgrade all OR upgrade <specific thing>
version           print current versions
path              RESET path to /monero-bash/

# DAEMON #
daemon            check status of daemon
daemon start      start the daemon (detached)
daemon stop       stop all daemon processes
daemon full       start the daemon without detaching

# STATS #
list              list wallets
size              show size of /monero-bash/
price             fetch price data from cryptocompare.com API

# HELP #
help              show this help message
```
if you ever move the `/monero-bash/` folder, execute `./monero-bash path` to re-add to PATH

currently, it gets added/removed from PATH via your `$USER/.bashrc` with `echo` and `sed`

an alternative would be to:
```
sudo ln -s monero-bash /usr/bin/monero-bash
```
this is a much cleaner (and safer) way of doing it, but it requires `sudo`, which i'd like to avoid


## Folder Structure
the `/monero-bash/` folder starts like this:
```
monero-bash/
├─ monero-bash
├─ config
├─ src
```
these 3: `monero-bash`, `config` and `src` must ALWAYS be in a `/monero-bash/` folder

after the initial configuration, `/monero-bash/` might look something like this:

```
monero-bash/            root folder
├─ monero-bash          main script itself
├─ config               config file for monero-bash
├─ cli                  where monero-cli binaries live
├─ src                  source code of monero-bash
├─ wallets              where wallet files live
├─ .bitmonero           monero blockchain/data folder
├─ .tmp
├─ .old
```
*note: `/cli/  /wallets/  /.bitmonero/` these folders don't HAVE to be inside `/monero-bash/`, you can set the paths anywhere*

the `.tmp` folder is used when downloading/extracting `monero-cli` and `monero-bash` (it is deleted afterwards)

when upgrading, `monero-bash` (by default), moves any old `/cli/` or `monero-bash` files in a timestamped folder inside `.old` instead of deleting them (if you'd like to change that, see the next section)


## Configuration
if you already use custom configs/options for `monerod` or `monero-wallet-cli` and want `monero-bash` to use them as well, make a `monerod.conf` or `monero-wallet-cli.conf` file and put them in your `.bitmonero` folder. [refer to this official monero documentation to learn more](https://monerodocs.org/interacting/monero-config-file)

for `monero-bash` specific configuration, edit the file `/monero-bash/config`
```
######################
# monero-bash config #
######################

# first time prompt
FIRST_TIME="true"                 # triggers the interactive configuration, set to "false" after

# path
DATA_PATH=""                      # the path of /.bitmonero/      
MONERO_CLI_PATH=""                # the path of the monero-cli binaries
WALLET_PATH=""                    # the path of your wallets

# monero-cli

# monero daemon
START_DAEMON="true"               # start the daemon automatically when starting the wallet
STOP_DAEMON="true"                # stop the daemon automatically after closing the wallet

# monero-bash
UPDATE_MONERO_CLI="true"          # allow monero-cli updates to be downloaded
UPDATE_MONERO_BASH="true"         # allow monero-bash updates to be downloaded
OLD_FOLDER="true"                 # move old /cli/ and monero-bash files into /.old/ instead of deleting them
ADD_TO_PATH="true"                # allow monero-bash to edit your bashrc to add to PATH
```
