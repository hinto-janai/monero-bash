# monero-bash guide:
* [Mining](#mining)
* [Full vs Start](#full-vs-start)
* [Configuration](#configuration)
* [File Structure](#file-structure)

## Mining
To quickly start mining on P2Pool, make sure you have all the packages:
* `monero-bash install all`

Configure basic mining settings:
* `monero-bash config`

You can then:
* `monero-bash start all`

Remember, you are using your own nodes to mine. Both the Monero & P2Pool nodes have to be fully synced!

## `Full` vs `Start`
There are 2 ways to start a process with monero-bash:
* `monero-bash full <process>`
* `monero-bash start <process>`

***Full*** will launch the process in the current terminal.  
***Start*** will use `systemd` to start the program in the background. 

## Configuration
Config files for all packages are in `~/.monero-bash/config`, you can edit them or replace them with your own.

P2Pool does not come with a config file, but monero-bash lets you edit small things:

## File Structure
These are all the folders/files created by `monero-bash` after installation:

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
