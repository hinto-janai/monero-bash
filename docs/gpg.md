# monero-bash gpg import process

The `monero-bash` repo contains GPG keys for all packages, but they are checked before being imported. When a package is installed, its corresponding GPG key is checked against the official version found ONLINE. If the key monero-bash comes with DOES NOT match the key found online, you will be dropped into an interactive prompt for a decision on what to do.

List of GPG key sources:
* monero-bash | `21958EE945980282FCB849C8D7483F6CA27D1B1D` | [hinto-janaiyo](https://raw.githubusercontent.com/hinto-janaiyo/monero-bash/master/gpg/hinto-janaiyo.asc)
* Monero      | `81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92` | [binaryFate](https://raw.githubusercontent.com/monero-project/monero/master/utils/gpg_keys/binaryfate.asc)
* P2Pool      | `1FCAAB4D3DC3310D16CBD508C47F82B54DA87ADF` | [SChernykh](https://raw.githubusercontent.com/monero-project/gitian.sigs/master/gitian-pubkeys/SChernykh.asc)
* XMRig       | `9AC4CEA8E66E35A5C7CDDC1B446A53638BE94409` | [XMRig](https://raw.githubusercontent.com/xmrig/xmrig/master/doc/gpg_keys/xmrig.asc)

[Full list of `monero-bash` GPG functions](https://github.com/hinto-janaiyo/monero-bash/blob/main/src/func/gpg)
