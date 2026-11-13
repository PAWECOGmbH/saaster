# Changelog

## Unreleased

- Updated setup and demo-data instructions; added [contribution](CONTRIBUTING.md), [customization and update](docs/customization-and-updates.md), and [security](SECURITY.md) guidance.
- Added bug report, feature request, and pull request templates.
- Added isolated TestBox checks before staging deployment. Failed checks block deployment; pushes to `development` do not trigger tests.
- Hardened test result validation and switched booking-after-payment tests to the local Payrexx mock.
- Excluded tests and demo data from staging/production deployments while retaining them in the repository and forks.
- Replaced tar-based SSH/SFTP backup scripts with encrypted Borg backup and restore. Update backup settings before use; the new restore scripts cannot read the previous tar format. See the [Borg requirements and recovery guide](config/backup/readme.md).
- Removed bundled Font Awesome assets and updated the backend view template to use Tabler Icons.
