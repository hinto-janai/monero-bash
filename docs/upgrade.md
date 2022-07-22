# How does monero-bash upgrade packages?
* [Intro](#Intro)
* [Download](#Download)
* [Verify](#Verify)
* [Upgrade](#Upgrade)
* [Details](#Details)
* Date: 2022-04-07

## Intro
The monero-bash upgrade process is:
* Download
* Verify
* Upgrade

Here's a very simplified step-by-step explanation of what happens when you `monero-bash upgrade`

## Download
```
download() {
    wget -P "$tmp" -q --show-progress --content-disposition "https://downloads.getmonero.org/cli/linux64"
}
```
For this example, let's download `Monero`

The download function does a simple job:
1. It downloads `https://downloads.getmonero.org/cli/linux64` into a temporary folder with a progress bar

## Verify
```
verify::hash() {
	echo "$HASH" "$tar" | sha256sum -c
}
```
After successful download, `monero-bash`:
1. Checks if the tar hash matches `https://www.getmonero.org/downloads/hashes.txt`
2. Either prints a green `OK` or a red `FAILED` message

## Upgrade
```
upgrade() {
	if [[ $VERIFY = "true" ]]; then
		tar -xf "$TAR"
		mv "$NEW_PACKAGE" "$OLD_PACKAGE"
		sudo sed -i "s/MONERO_VER=.*/MONERO_VER=$NEW_VERSION/" "$STATE"
	else
		print::compromised
		exit
	fi
}
```
If the verification goes well, monero-bash:
1. Extracts the `tar` file
2. Replaces the old `Monero` folder with the new
3. Edits the local `state` file with new info

If the verification **fails,** `monero-bash`:
1. Spits out a [scary looking message](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/print/compromised.sh)
2. Exits immediately

`monero-bash` requires sudo to create `systemd` files when upgrading/installing packages

## Details
For the sake of being simple and easy to read, the functions presented in the examples above were ***heavily*** reduced.

[Click here to see the actual upgrade functions](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/upgrade)

What you'll find is a bunch of grep/awk/sed, error handling, cleanup, and safety checks.
