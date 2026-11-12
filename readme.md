<div align="center"><img src="https://www.saaster.io/images/saaster-logo.png" height="100"/></div><br><br>
<b>Saaster</b> is a CFML framework for developers building SaaS applications. It uses <b>Lucee 7</b>, <b>NGINX</b>, <b>MySQL 8.1</b>, <b>Docker Compose</b>, and <b>Flyway</b>. Core features include authentication, customer and tenant management, subscriptions, invoicing, and APIs. Application code, modules, and themes provide extension points for your own product. Working with Saaster requires familiarity with CFML, SQL, Git, and Docker.
<br><br>
<a target="_blank" href="https://www.saaster.io">🌐 Website</a><br>
<a target="_blank" href="https://docs.saaster.io">📚 Documentation</a><br>
<a target="_blank" href="https://app.saaster.io">Demo</a><br>
<a href="LICENSE">📃 License</a>
<br><br>

# Release status
The first versioned public release is being prepared. No Git tags or GitHub Releases have been published yet, so there is currently no stable release tag to recommend for installation. Use `development` for local evaluation and contributions.

The public documentation's "Version 1.1" label has not been mapped to a repository tag or GitHub Release. The first software release number will be confirmed before publication. See [Release preparation](docs/releases.md) for the checklist and pending decisions.

Use the instructions in this repository for the code you have checked out. The public documentation still describes an older setup using `make`, different configuration files, and Mailslurper. Version-specific guides will be maintained alongside the code, with the public documentation linking to the matching version.

# Branches
Saaster is organized into three primary branches to support different stages of development and deployment:<br>

+ <b><code>development</code>:</b> The default branch for ongoing development and external pull requests. It may contain unstable or incomplete changes.
+ <b><code>staging</code>:</b> PAWECO's acceptance environment for the next deployment or release candidate. Contributor tests use a dedicated local test database and local services.
+ <b><code>production</code>:</b> PAWECO's approved deployment branch. A public release will be identified by a fixed tag and GitHub Release after the release checks are complete.

Pushes to `staging` and `production` trigger deployment workflows that also run database migrations. PAWECO is responsible for these promotions and release approval.

<br><br>

# Development Setup
These instructions cover local development. End-to-end verification of a fresh checkout using public images is still part of the [first-release checklist](docs/releases.md#release-checklist).

Before starting, install Git and Docker with the Docker Compose plugin, and make sure Docker is running. The shell commands below use Bash-compatible syntax; on Windows, use Git Bash. Running the tests also requires `curl`.

## Step-by-step setup:
<b>1. Open a terminal and navigate to the desired folder</b><br>
Choose the directory where you want to clone the project.<br>
```
cd /path/to/your/folder
```

<b>2. Clone the Saaster repository</b>
```
git clone https://github.com/PAWECOGmbH/saaster
```

<b>3. Navigate to the project folder</b>
```
cd saaster
```

<b>4. Configure environment variables</b><br>
Copy the example environment file and modify the settings to match your local setup:
```
cp config/example.env .env
```
Update the ```.env``` file with your configuration. You can also adopt the suggestions for the local environment.<br><br>

<b>5. Copy the NGINX base settings</b><br>
```
mkdir -p config/nginx/conf.d
cp config/example.base.conf config/nginx/conf.d/base.conf
```

<b>6. Set up the application configuration</b><br>
Copy the example configuration file and make any necessary changes:
```
cp config/example.config_dev.cfm www/config.cfm
```
Edit ```www/config.cfm``` to suit your development environment.<br>
Note: If you change the ```config.cfm``` file after the first start of the application, you need to reload the application scope:<br>
```http://localhost:8080?reinit=1```

<br>

<b>7. Start the containers</b><br>
Use Docker Compose to start the development environment:
```
docker compose -f compose-dev.yml up -d
```

<b>8. Configure Lucee</b><br>
Access the Lucee admin interface:

+ <b>URL:</b> ```http://localhost:8080/lucee/admin/server.cfm```
+ <b>Steps:</b>
  + Create a MySQL datasource whose name matches `variables.datasource` in `www/config.cfm` (`saaster_dev` in the development example). Use `MYSQL_CONTAINER_NAME` as the host, port `3306`, and the database name, user, and password from `.env`. Enable <b>Allow Multiple Queries</b>.
  + Configure SMTP with `INBUCKET_CONTAINER_NAME` as the host and port `2500` for local email handling.
  + Adjust any additional settings required for your development setup.

<br>

<b>9. Set up Saaster</b><br>
Run the setup script to initialize Saaster:

+ <b>URL:</b> ```http://localhost:8080/setup/index.cfm```
+ Work your way through the wizard.
+ Complete the registration; the first registration creates the Sysadmin account.
+ Access Inbucket (local email client) at ```http://localhost:9000``` to view any emails.

<br><br>

## Optional: Load Test Data
If you want to load test data into your database:

1.	In the folder ```config/db/dev/```, you'll find SQL files with demo data. They contain data only - the tables come from the migrations - and can be imported again at any time (they replace their own records). Import them in this order:

| File | Content |
| --- | --- |
| ```create-plans.sql``` | One plan group with four plans (Free, Standard, Advanced, Enterprise), features and prices in USD, EUR and CHF (CHF with 8.1% VAT) |
| ```create-modules.sql``` | Three modules: a free Todo app, Easy ERP (monthly/yearly, 30 test days), MailChimp API (one-time, 10 test days) |
| ```create-widgets.sql``` | Five dashboard widgets: shown to everybody, only with a module, only with certain plans, deactivated (replaces widgets 1-5) |
| ```create-customers.sql``` | Eleven demo companies with users, active, test, free, canceled, expired and waiting bookings, invoices in every status, payments, payment methods and tenants |
| ```create-notifications.sql``` | Notifications for the first account (customer 1, user 1) |

```
for f in create-plans create-modules create-widgets create-customers create-notifications; do
  cat ./config/db/dev/$f.sql | docker exec -i {MYSQL_CONTAINER_NAME} mysql -u {MYSQL_USER} -p{MYSQL_PASSWORD} {MYSQL_DATABASE}
done
```

All demo users log in with the password ```Saaster-Demo-2026!```, e.g. ```anna.meier@alpine-bakery.example``` (German, Standard plan) or ```oliver.smith@brightpixel.example``` (English, overdue invoice). The list of companies and what each of them shows is at the top of ```create-customers.sql```.

Replace the following placeholders:
+ ```{MYSQL_CONTAINER_NAME}```: The name of your MySQL container.
+ ```{MYSQL_USER}```: Your MySQL user.
+ ```{MYSQL_PASSWORD}```: Your MySQL password (ensure no space after -p).
+ ```{MYSQL_DATABASE}```: Your MySQL database name.

2.	You can also import mock customers and invoices:
 + <b>URL:</b> ```http://localhost:8080/setup/mockdata/index.cfm```

<br><br>

## Preserve Configurations with a Custom Docker Image
After configuring Lucee and Saaster, you may want to create a custom Docker image to preserve your settings:

1.	Stop the Lucee container:<br>
```docker stop <lucee_container_name>```

2.	Commit the container to create an image:<br>
```docker commit <lucee_container_name> <your_image_name>:version```<br>
*Example:* ```docker commit lucee_container saaster:20241002```

3.	Remove the old container:<br>
```docker container rm <lucee_container_name>```

4.	Update your ```.env``` file with the image name and tag separately:<br>
```
LUCEE_IMAGE=saaster
LUCEE_IMAGE_VERSION=20241002
```

5.	Restart the container with your saved image:<br>
```docker compose -f compose-dev.yml up -d```

<br><br>

## Testing
Saaster comes with a [TestBox](https://www.ortussolutions.com/products/testbox) test workspace in ```www/tests```. The specs run inside your local Lucee container against a dedicated test database (```saaster_test_db```), never against your development database. With the dev stack running, set it up once from the repository root:
```
bash www/tests/bin/install_test_dependencies.sh
bash www/tests/bin/prepare_test_db.sh
```
Then run the specs in the browser at ```http://localhost:8080/tests/runner.cfm``` or from the shell:
```
bash www/tests/bin/run_tests.sh "reporter=mintext"
```
The test application only starts when ```config.cfm``` is set to ```variables.environment = "dev"```. Details and how to write your own specs: [www/tests/README.md](www/tests/README.md)

<br><br>

## Live Setup
The notes below describe the existing Docker configuration for staging and production. A complete production installation, upgrade, and recovery guide, together with practical verification, is still part of [release preparation](docs/releases.md#release-checklist).

### Production and staging with one compose.yml
Production and staging use the same ```compose.yml```. Optional services have a Compose profile and only start when the profile is listed in ```COMPOSE_PROFILES``` of the server's ```.env```:

| Server | ```.env``` | Started by ```docker compose up -d``` |
| --- | --- | --- |
| Production | ```COMPOSE_PROFILES=filebrowser``` | Lucee, MySQL, File Browser |
| Staging | nothing (or ```COMPOSE_PROFILES=``` empty) | Lucee, MySQL |

To check what a server would start: ```docker compose config --services```

The File Browser variables (```FILEBROWSER_PORT```, ```FILEBROWSER_CONTAINER_NAME```) are only needed where the File Browser runs - Compose validates every service, so ```compose.yml``` has defaults for them.

When you remove a profile from a server where its service is already running (e.g. the File Browser on staging), stop and remove that container once - Compose leaves it running otherwise:
```
docker compose stop filebrowser
docker compose rm filebrowser
```

### Upgrading a server to Lucee 7
Lucee 7 needs Tomcat 11 (Jakarta), so it cannot be updated in the Lucee admin - the container must be created from the Lucee 7 image. The Lucee settings (datasource, mail server) live inside the container and are lost with it, so take them along:

1. Save the settings of the running container:<br>
```docker cp <lucee_container_name>:/opt/lucee/server/lucee-server/context/.CFConfig.json ./cfconfig-backup.json```
2. Set the image in ```.env``` (```LUCEE_IMAGE=lucee/lucee```, ```LUCEE_IMAGE_VERSION=7.1.1.17-nginx```) and recreate the container: ```docker compose up -d lucee```
3. Set up the datasource (with 'Allow Multiple Queries') and the mail server in the Lucee admin again. Alternatively, put a ```.CFConfig.json``` containing only the ```dataSources``` and ```mailServers``` parts of the backup into ```/opt/lucee/server/lucee-server/deploy/``` and restart the container - Lucee merges it into its settings.
4. Preserve the result as your own image (see [Preserve Configurations with a Custom Docker Image](#preserve-configurations-with-a-custom-docker-image)).

Since Lucee 7.1, both `<cfmail>` and the CFScript `mail` statement require the Mail extension. Both Compose files declare Mail 1.1.0.17 via `LUCEE_EXTENSIONS`, so custom images install it automatically at startup. SMTP settings still need to be configured separately.
An update performed only in the Lucee Administrator is not stored in the source Docker image. Build or save a custom image based on Lucee 7.1.1.17 before recreating its container.

The PDF extension of Lucee 7 ships the "classic" engine only as demo with a watermark, so Saaster always uses the "modern" engine; ```variables.pdf_type``` in older ```config.cfm``` files is ignored.

<br><br>

## Contributing
Contributions to code, tests, and documentation are welcome. Create a branch from `development` in your fork and target `development` when opening a pull request. PAWECO maintains the project's direction and reviews changes before merging.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the contribution workflow, coding rules, test commands, and pull request checklist. The shared repository rules are maintained in [AGENTS.md](AGENTS.md).

<br><br>

## Dependencies

- [Tabler](https://github.com/tabler/tabler/blob/main/LICENSE)
- [Dropify](https://github.com/JeremyFagis/dropify/blob/master/LICENCE.md)
- [Hugerte](https://github.com/hugerte/hugerte/blob/main/LICENSE.TXT)
- [Bootstrap](https://github.com/twbs/bootstrap/blob/main/LICENSE)
- [MockDataCFC](https://github.com/Ortus-Solutions/MockDataCFC/blob/development/LICENSE)
- [Fontawesome](https://fontawesome.com/v4/license/)
- [jquery](https://github.com/jquery/jquery)
- [taffy](https://github.com/atuttle/Taffy)
- [Bouncy Castle](https://www.bouncycastle.org/about/license/) (Argon2 password hashing, ```www/assets/java```)



