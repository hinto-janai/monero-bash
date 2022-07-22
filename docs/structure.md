# monero-bash file structure
These are all the folders/files created by `monero-bash` after installation:

**INSTALLATION**
```
$HOME/.monero-bash/
├─ wallets
├─ config
	├─ monero-bash.conf
	├─ monerod.conf
	├─ monero-wallet-cli.conf
	├─ p2pool.conf
	├─ xmrig.json
├─ packages
	├─ monero-bash
	├─ monero
	├─ p2pool
	├─ xmrig
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
