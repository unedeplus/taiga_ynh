
# Taiga YunoHost App

This is a YunoHost package for [Taiga](https://taiga.io/), an open-source agile project management platform.

## Status
Work in progress. Not ready for production use.

## Installation
You can install this app on your YunoHost server using the web admin or CLI:

```
yunohost app install https://github.com/unedeplus/taiga_ynh
```

## Structure
- `manifest.toml`: App metadata and install arguments (TOML format)
- `scripts/install`: Installation script
- `scripts/remove`: Removal script
- `scripts/upgrade`: Upgrade script
- `scripts/backup`: Backup script
- `scripts/restore`: Restore script
- `conf/`: Configuration templates (e.g., nginx)

## Packaging resources
- [YunoHost packaging documentation](https://yunohost.org/en/packaging_apps)
- [Example apps](https://github.com/YunoHost-Apps)

## Support
This app is not officially supported by YunoHost. For issues, open an issue on the [GitHub repo](https://github.com/unedeplus/taiga_ynh).

## TODO
- Implement full install/remove/upgrade/backup/restore logic
- Add configuration templates
- Test on a YunoHost instance
