# monero-bash development
* [stdlib & hbc](#stdlib-hbc)
* [external](#external)
	- [ShellCheck](#ShellCheck)
	- [xmrpc](#xmrpc)
## stdlib & hbc
monero-bash uses general-purpose functions from a Bash library, [stdlib.](https://github.com/hinto-janaiyo/stdlib)

It also follows a development process similar to traditional programming languages, where the code is spread out across many files and then compiled into a final single executable in the end. This helps with code re-use from libraries and overall organization of the codebase. This "build" process is not achieved with `Make` or `gcc`, but rather [hbc, a Bash "compiler".](https://github.com/hinto-janaiyo/hbc)

`hbc` takes in files from the `lib` &  `src` folders, processes it, adds many safety checks, runs it through [ShellCheck](https://github.com/koalaman/shellcheck), and "compiles" it into one large executable: `monero-bash`. The library code used is defined at the top of the `main.sh` script, indicated by `#include <file_path>`.

**Yes, both `stdlib` and `hbc` are created by me.**

Mostly for monero-bash but also for my other Bash projects. The `#include` feature is really handy for code reuse.

See more info here: [`stdlib`](https://github.com/hinto-janaiyo/stdlib) & [`hbc`](https://github.com/hinto-janaiyo/hbc)

## external
### ShellCheck
As stated above, monero-bash heavily relies on [ShellCheck](https://github.com/koalaman/shellcheck) for catching compile-time errors.

### xmrpc
The code for monero-bash's [`rpc command`](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/rpc.sh) is originally from: [https://github.com/jtgrassie/xmrpc](https://github.com/jtgrassie/xmrpc)

It was slightly modified to:
- Work with `wget`
- Print debug info
- Work as a function

Copyright (c) 2019-2022, jtgrassie  
Copyright (c) 2014-2022, The Monero Project  
