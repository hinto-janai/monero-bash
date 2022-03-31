# is monero-bash a virus?
* [Intro](#Intro)
* [Download](#Download)
* [Verify](#Verify)
* [Upgrade](#Upgrade)
* [Details](#Details)
* [Conclusion](#Conclusion)
* Date: 2022-03-30

## Intro
Is monero-bash a virus? Will it steal my Monero? Is it downloading malware instead of the real packages?
```
No
```
Here's a ***very, very simplified*** step-by-step explanation of what happens when you `monero-bash upgrade`

## Download
```
download_Monero()
{
    wget -P "$tmp" -q --show-progress --content-disposition "https://downloads.getmonero.org/cli/linux64"
}
```
For this example, let's download `Monero`

The download function does a simple job:
1. It downloads `https://downloads.getmonero.org/cli/linux64` into a temporary folder with a progress bar

## Verify
```
verify_hash_Monero()
{
	echo "https://www.getmonero.org/downloads/hashes.txt" "$tarName" | sha256sum -c
}
```
After successful download, `monero-bash`:
1. Checks if the tar hash matches `https://www.getmonero.org/downloads/hashes.txt`
2. Either prints a green `OK` or a red `FAILED` message

## Upgrade
```
upgrade_Monero()
{
	if [[ $verifyOK = "true" ]]; then
		tar -xf "$tarName"
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
3. Edits the `state` file with the new version number

If the verification **fails,** `monero-bash`:
1. Spits out a [scary looking message](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/compromised)
2. Exits immediately

Since `monero-bash` gets installed in `/usr/local/share/monero-bash/`, sudo is required to edit the `state` file when upgrading/installing

## Details
For the sake of being simple and easy to read, the functions presented in the examples above were ***HEAVILY*** reduced and turned into pseudo-code. The `Verify` function shown is not even a valid command. 

[I highly encourage you to click here to see the actual Upgrade function](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/upgrade), and here for some of the important functions it's made out of: [Download](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/download) [Verify](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/verify) [Version](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/version)

What you'll find is a bunch of grep/awk/sed, error handling, cleanup, and safety checks.

## Conclusion
I am far too concerned with making sure `monero-bash` doesn't blow up anyone's files to have the time to:
1. Learn how to write malware
2. Implement the malware
3. Try to obfuscate the malware

All the code is open, not just in this repo but on your computer itself. `monero-bash` is literally just a collection of scripts you can open up at any time at `/usr/local/share/monero-bash/`
