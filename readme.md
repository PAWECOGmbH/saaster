<div align="center"><img src="https://www.saaster.io/images/saaster-logo.png" height="100"/></div><br><br>
<b>Saaster</b> is a CFML-based framework designed to simplify the development of SaaS applications. It is built on a modern stack, using <b>Lucee 6</b>, <b>NGINX</b>, and <b>MySQL 8.1</b>, and is fully containerized with <b>Docker Compose</b>. The architecture provides a solid foundation for building scalable SaaS platforms while keeping configuration flexible. Saaster includes core features such as user authentication, API integration, and a modular approach to extend functionality. This framework allows developers to focus on building their application's unique components without reinventing common SaaS patterns.
<br><br>
<a target="_blank" href="https://www.saaster.io">🌐 Website</a><br>
<a target="_blank" href="https://docs.saaster.io">📚 Documentation</a><br>
<a target="_blank" href="https://github.com/PAWECOGmbH/saaster/blob/main/LICENSE">📃 License</a>
<br><br>

# Branches
Saaster is organized into three primary branches to support different stages of development and deployment:<br>

+ <b>Development:</b> This is the default branch where new features, bug fixes, and improvements are implemented. Developers work primarily in this branch. It may contain unstable code, and its purpose is for active development and experimentation. Use this branch for contributing and testing new functionality.
+ <b>Staging:</b> The staging branch is used to test features that have been merged from development. It mimics the production environment as closely as possible to ensure stability before release. The staging branch uses a copy of the production database for testing with live data, making it suitable for integration and acceptance testing.
+ <b>Production:</b> The production branch contains the stable version of Saaster that is deployed to the live environment. Code is only merged into production after thorough testing in staging. This branch should always reflect the current state of the live environment and should be free from experimental or incomplete features.

<br><br>

# Development Setup
To set up Saaster for local development, follow these steps. This will allow you to work on the project, make modifications, and test it in a development environment. Make sure Docker is installed and running before you begin.<br>

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
mv config/example_dev.env .env
```
Update the ```.env``` file with your configuration. You can also adopt the suggestions for the local environment.<br><br>


<b>5. Set up the application configuration</b><br>
Copy the example configuration file and make any necessary changes:
```
mv config/example.config_dev.cfm www/config.cfm
```
Edit ```www/config.cfm``` to suit your development environment.<br>
Note: If you change the ```config.cfm``` file after the first start of the application, you need to reload the application scope:<br>
```http://localhost:8080?reinit=1```

<br>

<b>6. Start the containers</b><br>
Use Docker Compose to start the development environment:
```
docker compose -f compose-dev.yml up
```

<b>7. Configure Lucee</b><br>
Access the Lucee admin interface:

+ <b>URL:</b> ```http://localhost:8080/lucee/admin/server.cfm```
+ <b>Steps:</b>
  + Set up the database connection (<b>important:</b> Make sure to enable 'Allow Multiple Queries.') 
  + Configure SMTP (you can use Inbucket for local email handling).
  + Adjust any additional settings required for your development setup.
 
<br>

<b>8. Set up Saaster</b><br>
Run the setup script to initialize Saaster:

+ <b>URL:</b> ```http://localhost:8080/setup/index.cfm```
+ Work your way through the wizard.
+ Complete the registration; the first registration creates the Sysadmin account.
+ Access Inbucket (local email client) at ```http://localhost:9000``` to view any emails.

<br><br>

## Optional: Load Test Data
If you want to load test data into your database:

1.	In the folder ```config/db/dev/```, you'll find several SQL files containing test data. For example, to import the "create-plans.sql" file:
```
cat ./config/db/dev/create-plans.sql | docker exec -i {MYSQL_CONTAINER_NAME} mysql -u {MYSQL_USER} -p{MYSQL_PASSWORD} {MYSQL_DATABASE}
```

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

4.	Remove the old container:<br>
```docker container rm <lucee_container_name>```

5.	Update your ```.env``` file with the new image name:<br>
```LUCEE_IMAGE=saaster:20241002```

6.	Restart the container with your saved image:<br>
```docker compose -f compose-dev.yml up -d```

<br><br>

## Live Setup
For production deployment, Saaster can be run on an Ubuntu server using Docker. This setup ensures a stable and scalable environment. A detailed guide on how to configure the server, set up Docker, and deploy Saaster in a live environment can be found in the official documentation:

+ <b>Production Setup Guide:</b> *coming soon*

<br><br>

## Contributing
We welcome contributions from developers to help improve Saaster. Whether it's fixing bugs, adding new features, or improving documentation, contributions are highly appreciated. Follow the steps below to get started:

1.	<b>Fork the repository</b><br>
	First, fork the <a href="https://github.com/PAWECOGmbH/saaster" target="_blank">Saaster repository</a> to your GitHub account.

2.	<b>Clone your fork</b><br>
	Clone your forked repository to your local machine:<br>
	```git clone https://github.com/{your-username}/saaster```<br>
	```cd saaster```

3.	<b>Create a new branch</b><br>
	Always create a new branch for your changes to keep things organized:<br>
	```git checkout -b feature/your-feature-name```

4.	<b>Make your changes</b><br>
   	Implement your changes and commit them with a clear and concise commit message:<br>
  	```git add .```<br>
  	```git commit -m "Add feature description"```
  	
5.	<b>Push your branch</b><br>
	Push your branch to your forked repository:<br>
	```git push origin feature/your-feature-name```

6.	<b>Create a pull request</b><br>
	Go to the <a href="https://github.com/PAWECOGmbH/saaster" target="_blank">Saaster repository</a> on GitHub and create a pull request from your forked repository. Ensure your pull request clearly describes the changes and why they are necessary.


### Guidelines
+ <b>Code style:</b> Follow the existing code style of the project.
+ <b>Testing:</b> Ensure that your changes do not break any existing functionality. Add tests where applicable.
+ <b>Documentation:</b> If your changes affect functionality, please update the relevant documentation.

For more information or if you're unsure about something, feel free to open an issue or ask for guidance on an existing one.

<br><br>

## Dependencies

- [Tabler](https://github.com/tabler/tabler/blob/main/LICENSE)
- [Dropify](https://github.com/JeremyFagis/dropify/blob/master/LICENCE.md)
- [Trumbowyg](https://github.com/Alex-D/Trumbowyg/blob/develop/LICENSE)
- [Bootstrap](https://github.com/twbs/bootstrap/blob/main/LICENSE)
- [MockDataCFC](https://github.com/Ortus-Solutions/MockDataCFC/blob/development/LICENSE)
- [Fontawesome](https://fontawesome.com/v4/license/)
- [jquery](https://github.com/jquery/jquery)
- [taffy](https://github.com/atuttle/Taffy)











