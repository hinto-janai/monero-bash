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
# Copyright (c) 2011-2022, Dominic Tarr
# Copyright (c) ????-2022, Tamas Szerb <toma@rulez.org>
# Copyright (c) 2008-2022, Robert Hogan <robert@roberthogan.net>
# Copyright (c) 2008-2022, David Goulet <dgoulet@ev0ke.net>
# Copyright (c) 2008-2022, Alex Xu (Hello71) <alex_y_xu@yahoo.ca>

# unix permissions for folders

permission_DotMoneroBash()
{
	sudo chmod 700 "$dotMoneroBash"
	sudo chmod -R 600 "$config"
	sudo chmod 700 "$config" "$wallets"
	sudo chown -R "$USER:$USER" "$dotMoneroBash"
}

permission_InstallDirectory()
{
	sudo chmod -R 700 "$installDirectory"
	sudo chmod -R 600 "$installDirectory/config" "$installDirectory/src/txt" "$MB_API"
	sudo chmod 700 "$installDirectory/config" "$installDirectory/src/txt" "$MB_API"
	sudo chown -R "$USER:$USER" "$installDirectory"
}

permission_Systemd()
{
	[[ -f /etc/systemd/system/monero-bash-monerod.service ]] && sudo chmod 600 /etc/systemd/system/monero-bash-monerod.service
	[[ -f /etc/systemd/system/monero-bash-p2pool.service ]] && sudo chmod 600 /etc/systemd/system/monero-bash-p2pool.service
	[[ -f /etc/systemd/system/monero-bash-xmrig.service ]] && sudo chmod 600 /etc/systemd/system/monero-bash-xmrig.service
}

permission_All()
{
	permission_InstallDirectory
	permission_Systemd
	permission_DotMoneroBash
}
