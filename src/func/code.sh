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

# functions that handle exit codes and prints proper messages
code_Wget()
{
	case $? in
		0) : ;;
		1|8) print_Error_Exit "wget - Generic error" ;;
		2) print_Error_Exit "wget - Parse error" ;;
		3) print_Error_Exit "wget - File I/O error" ;;
		4) print_Error_Exit "wget - Network failure" ;;
		5) print_Error_Exit "wget - SSL verification failure" ;;
		6) print_Error_Exit "wget - Username/password authentication failure" ;;
		7) print_Error_Exit "wget - Protocol errors" ;;
		*) print_Error_Exit "wget - Unknown error"
	esac
}

code_Tar()
{
	case $? in
		0) : ;;
		1) print_Error_Exit "tar - Some files differ" ;;
		2) print_Error_Exit "tar - Fatal error" ;;
		*) print_Error_Exit "tar - Unknown error"
	esac
}
