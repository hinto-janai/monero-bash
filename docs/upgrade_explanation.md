# is monero-bash a virus?
* [Intro](#Intro)
* [Download](#Download)
* [Verify](#Verify)
* [Upgrade](#Upgrade)
* [Conclusion](#Conclusion)
* Date: 2022-03-27

## Intro
Is monero-bash a virus? Will it steal my Monero? Is it downloading malware instead of the real packages?
```
No
```
So what actually happens when you type `monero-bash upgrade`?	

Here's a short and simplified step-by-step explanation of the code/commands that gets executed when you `upgrade`

## Download
```
download_Monero()
{
    wget -P "$tmp" -q --show-progress --content-disposition "https://downloads.getmonero.org/cli/linux64"
}
```
For this example, we'll be downloading `Monero`. Above is the first function called when you `upgrade`

The download function is a single command:
1. It downloads `https://downloads.getmonero.org/cli/linux64` into a temporary folder with a progress bar

## Verify
```
verify_hash_Monero()
{
	tarName="$(ls "$tmp")"
	echo "$(wget -qO- "https://www.getmonero.org/downloads/hashes.txt" \
		| grep "monero-linux-x64" | awk '{print $1}')" \
		"$tmp/$tarName" | sha256sum -c &>/dev/null
	print_OKFAILED
}
```
After successful download, `monero-bash`:
1. Finds the downloaded `tar` file
2. Compares its hash with the official hash list from `https://www.getmonero.org/downloads/hashes.txt`
3. Either prints a green "OK" or a red "FAILED" message

## Upgrade
```
upgrade_Monero()
{
	if [[ $? = "0" ]]; then
		tar -xf "$tarName"
		rm -rf "$DIRECTORY"
		mv "$tmp/$folderName" "$DIRECTORY"
		sudo sed -i "s@.*"$NAME_SED"_VER=.*@"$NAME_SED"_VER=\""$NAME_NEWVER"\"@" "$state"
	else
		compromised_"$NAME_FUNC"_Hash
		exit
	fi
}
```
THIS EXAMPLE CODE WAS SHORTENED FOR SIMPLICITY SAKE

[I encourage you to click here to see the entire function](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/upgrade) and [here, for all the source code](https://github.com/hinto-janaiyo/monero-bash/blob/main/src)

If the verification goes well, `monero-bash`:
1. Extracts the `tar` file
3. Replaces the old `Monero` folder with the new
4. Edits the `state` file with the new version number

If the verification **fails,** `monero-bash`:
1. Spits out a [scary looking message](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/compromised)
2. Exits immediately

Since `monero-bash` gets installed in `/usr/local/share/monero-bash/`, sudo is required to edit the `state` file, as `/usr/` is a write-protected directory.

Not unlike `apt` or `pacman` (or really, any program) that needs sudo when manipulating data located in write-protected areas.

## Conclusion
I am far too concerned with making sure `monero-bash` doesn't blow up anyone's files to have the time to:
1. Learn how to write malware
2. Implement the malware
3. Try to obfuscate the malware

Espescially in an open-source environment. At the end of the day, all the code is open, not just in the repo but on your computer itself. Unlike compiled binaries, `monero-bash` is literally just a collection of scripts you can open up at any time at `/usr/local/share/monero-bash/`
