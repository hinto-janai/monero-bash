# monero-bash file structure
These are all the folders/files created by `monero-bash` after installation:

**INSTALLATION**
```
$HOME/.monero-bash/
  ├─ wallets              Wallet folder
  ├─ changes              Changelog folder
  ├─ config               Config folder for all packages
  ├─ export_import        Where monero-wallet-cli exports/imports files from
  ├─ packages             Package folder
```

**PATH**
```
/usr/local/bin/
  ├─ monero-bash          Symlink to main script
  ├─ mb                   Optional alias symlink
```

**SYSTEMD**
```
/etc/systemd/system/
  ├─ monero-bash-monerod.service
  ├─ monero-bash-p2pool.service
  ├─ monero-bash-xmrig.service
```
After uninstalling monero-bash, all these files are deleted.

*note:* monero-bash uses `/tmp/` to create temporary files and folders. They are deleted after upgrade, and wiped if the computer is rebooted. 
