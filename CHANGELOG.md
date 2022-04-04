# v0.6.1
## Updates
* `monero-bash install/upgrade <package> verbose` option to print detailed download information
* If a hash error occurs, the ONLINE hash and LOCAL hash will be printed for comparison
* GPG keys have been added in /monero-bash/gpg/, but not integrated yet

## To be added
* Automatic P2Pool mining
* GPG key verification for binaries
* RPC/Daemon API integration
* Automatic encrypted wallet backups

## Added but not usable yet
* XMRig, P2Pool can be installed but not invoked
* systemd intergrated, but not invokable
* `watch` command works, but not invokable


# v0.6
## Updates
* Package manager is 2x~ faster (less API calls)
* Canceling mid-upgrade is much safer (proper clean-up and package revert)

## To be added
* Automatic P2Pool mining
* GPG key verification for binaries
* RPC/Daemon API integration
* Automatic encrypted wallet backups

## Added but not usable yet
* XMRig, P2Pool can be installed but not invoked
* systemd intergrated, but not invokable
* `watch` command works, but not invokable


# v0.5
## Updates
* Full package manager functions
* GitHub API is used for downloads, HTML filter for backup
* More error, safety checks
* Updated readme and documentation to include future features
* `monero-bash` creates personal `.monero-bash` folder

## To be added
* Automatic P2Pool mining
* GPG key verification for binaries
* RPC/Daemon API integration
* Automatic encrypted wallet backups

## Added but not usable yet
* XMRig, P2Pool can be installed but not invoked
* systemd intergrated, but not invokable
* `watch` command works, but not invokable
