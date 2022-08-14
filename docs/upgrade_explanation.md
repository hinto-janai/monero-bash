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
download_Monero() {
    wget -P "$tmp" -q --show-progress --content-disposition "https://downloads.getmonero.org/cli/linux64"
}
```
For this example, let's download `Monero`

The download function does a simple job:
1. It downloads `https://downloads.getmonero.org/cli/linux64` into a temporary folder with a progress bar

## Verify
```
verify_hash_Monero() {
	echo "$HASH" "$tar" | sha256sum -c
}
```
After successful download, `monero-bash`:
1. Checks if the tar hash matches `https://www.getmonero.org/downloads/hashes.txt`
2. Either prints a green `OK` or a red `FAILED` message

## Upgrade
```
upgrade_Monero() {
	if [[ $verifyOK = "true" ]]; then
		tar -xf "$tar"
		mv "$folderName" "$currentFolder"
		sudo sed -i "s@.*"$NAME_CAPS"_VER=.*@"$NAME_CAPS"_VER=\""$NewVer"\"@" "$state"
	else
		compromised_Monero_Hash
		exit
	fi
}
```
If the verification goes well, `monero-bash`:
1. Extracts the `tar` file
2. Replaces the old `Monero` folder with the new
3. Edits the local `state` file with new info

If the verification **fails,** `monero-bash`:
1. Spits out a [scary looking message](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/compromised.sh)
2. Exits immediately

Since monero-bash gets installed in `/usr/local/share/monero-bash/`, sudo is required to edit the `state` file when upgrading/installing

## Details
For the sake of being simple and easy to read, the functions presented in the examples above were ***heavily*** reduced.

[I encourage you to click here to see the actual upgrade function](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/upgrade.sh)

And here for some of the important functions it's made out of:  [Define](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/define.sh)  -  [Download](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/download.sh) -  [Verify](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/verify.sh) - [Version](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/version.sh)

What you'll find is a bunch of grep/awk/sed, error handling, cleanup, and safety checks.

As for PGP keys, here is the full import function:
```
gpg_import_Template() {
	local LOCAL="$(cat "$installDirectory/gpg/${GPG_OWNER}.asc")"
	local ONLINE="$(wget -qO- "$GPG_PUB_KEY")"

	if [[ "$LOCAL" = "$ONLINE" ]]; then
		echo -n "$GPG_OWNER: "
		echo "OK" ;$off
		gpg --import "$installDirectory/gpg/${GPG_OWNER}.asc"
		echo
	else
		gpg_Diff
	fi
}
```
Before any key is imported, it's checked against the official version found ONLINE. If the key monero-bash comes with DOES NOT match the key found online, you will be prompted for a decision on what to do.

[To see all GPG-related functions, click here](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/gpg.sh)
