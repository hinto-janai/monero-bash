# monero-bash -- WORK IN PROGRESS
>a wrapper for monero written in bash

![monero-bash.png](https://i.ibb.co/x8zcf7p/monero-bash.png)

## if you want to beta-test:
[download latest release, here](https://github.com/hinto-janaiyo/monero-bash/releases/latest)

OR

```
git clone https://github.com/hinto-janaiyo/monero-bash &&
cd monero-bash &&
./monero-bash
```
*note: **ALWAYS** clone the main branch, the others might contain system-breaking commands* 

it will be added to path so after the initial configuration:
```
monero-bash
```
will work anywhere

---

for help:
```
monero-bash help
```

to configure, edit:
```
/monero-bash/config/
```

to uninstall cleanly:
```
monero-bash uninstall
```

---

## features to be added:
* automatic p2pool mining
* gpg key verification for binaries
* "offline" mode, block all internet-related commands
* daemon inside screen session
* blockchain API stats
