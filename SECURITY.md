# Security policy

## Report a vulnerability

Use [GitHub's private vulnerability reporting](https://github.com/PAWECOGmbH/saaster/security/advisories/new) to contact the Saaster maintainers confidentially. Keep vulnerability details out of public issues and pull requests.

Include the affected branch/commit or release, the steps to reproduce, and the potential impact. A small proof of concept is helpful; remove credentials, tokens and real customer data.

We discuss reports and coordinate fixes privately through GitHub. Public disclosure is coordinated after a fix or mitigation is available. Response and resolution times are not guaranteed.

## Maintained versions and scope

Before the first versioned release, security fixes target the current `development` branch. After the first release, fixes target the latest stable release and `development`. Reports affecting older versions are welcome; backports are not guaranteed.

This policy covers code and default configurations shipped with Saaster, including vulnerabilities in dependencies that affect Saaster. Custom application code, modules, themes and hosting configurations are the operator's responsibility; report issues in those environments when the underlying cause is in Saaster.
