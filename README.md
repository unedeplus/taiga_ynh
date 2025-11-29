# Taiga YunoHost App (WIP)

This is a YunoHost package for [Taiga](https://taiga.io/), an open-source agile project management platform.

## Status
Work in progress. Not ready for production use.

## How to use
- Clone this repository on your YunoHost server.
- Run the install script via YunoHost's app installation process.

## Packaging resources
- [YunoHost packaging documentation](https://yunohost.org/en/packaging_apps)
- [Example apps](https://github.com/YunoHost-Apps)

## Structure
- `manifest.json`: App metadata and install arguments
- `scripts/install`: Installation script
- `scripts/remove`: Removal script
- `scripts/upgrade`: Upgrade script
- `conf/`: Configuration templates

## TODO
- Implement full install/remove/upgrade logic
- Add configuration templates
- Test on a YunoHost instance
