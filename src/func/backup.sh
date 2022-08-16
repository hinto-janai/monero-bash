# This file is part of [monero-bash]
#
# Copyright (c) 2022 hinto.janaiyo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Parts of this project are originally:
# Copyright (c) 2019-2022, jtgrassie
# Copyright (c) 2014-2022, The Monero Project

# tar + gpg backups
backup_Wallets()
{
	# CHECK IF FILE ALREADY EXISTS
	if [[ -f "$dotMoneroBash/backup.tar" ]]; then
		print_Error_Exit "$dotMoneroBash/backup.tar already exists!"
	elif [[ -f "$dotMoneroBash/backup.tar.gpg" ]]; then
		print_Error_Exit "$dotMoneroBash/backup.tar.gpg already exists!"
	fi

	# PASSWORD-BASED AES256 ENCRYPTION (output file: backup.tar.gpg)
	$bblue; echo "Backing up wallets..." ;$off
	cd "$dotMoneroBash"
	tar -cf "backup.tar" "wallets" --transform 's/wallets/backup/'
	gpg --no-symkey-cache --cipher-algo AES256 -c "backup.tar"
	if [[ $? != 0 ]]; then
		rm "backup.tar"
		print_Error_Exit "GPG error"
	fi
	rm "backup.tar"
	$bwhite; echo -n "Cipher algo: " ;$off; echo "AES256"
	$bwhite; echo -n "Key type: " ;$off; echo "Passphrase"
	$bwhite; echo -n "Encrypted wallet tar: " ;$off; echo "$dotMoneroBash/backup.tar.gpg"
	$bwhite; echo -n "To decrypt: " ;$bgreen; echo -n "monero-bash decrypt"
	$bwhite; echo -n " OR " ;$bgreen; echo "gpg backup.tar.gpg && tar -xf backup.tar"
}

backup_Decrypt()
{
	[[ -d "$dotMoneroBash/backup" ]]&& print_Error_Exit "$dotMoneroBash/backup already exists, please move!"
	[[ -f "$dotMoneroBash/backup.tar" ]]&& print_Error_Exit "$dotMoneroBash/backup.tar already exists!"
	[[ ! -f "$dotMoneroBash/backup.tar.gpg" ]]&& print_Error_Exit "$dotMoneroBash/backup.tar.gpg was not found!"
	$bblue; echo "Decrypting backup..." ;$off
	cd "$dotMoneroBash"
	gpg --no-symkey-cache "backup.tar.gpg"
	error_Exit "Decrypt failed"
	tar -xf "backup.tar"
	error_Exit "tar failed"
	rm "backup.tar"
	$bwhite; echo -n "Decrypted backup: " ;$off; echo "$dotMoneroBash/backup"
}