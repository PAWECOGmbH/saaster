
<div align="center">
	<img src="https://www.saaster.io/images/saaster-logo.png" height="100"/>
</div>
<br>

<b>Saaster</b> is a comprehensive, <b>CFML-based</b> foundation designed to streamline the development of SaaS projects. Built on a modern architecture with <b>Lucee 6 and NGINX</b>, it integrates seamlessly with <b>MySQL 8.1</b> for efficient data management and uses <b>Docker Compose</b> for easy containerized deployment. Saaster comes equipped with a robust set of essential features, enabling you to focus on building your unique product while relying on a scalable, flexible, and reliable base application. Whether you're launching a new SaaS platform or expanding an existing one, Saaster provides the core functionality you need to get started quickly and efficiently.
<br><br>
<a target="_blank" href="https://www.saaster.io">🌐 Website</a><br>
<a target="_blank" href="https://docs.saaster.io">📚 Documentation</a><br>
<a target="_blank" href="https://github.com/PAWECOGmbH/saaster/blob/main/LICENSE">📃 License</a><br><br>

# Saaster - Development Branch
## Introduction
This branch is meant for contributors and developers to collaborate and improve the project. Feel free to fork the repository, make changes, and create pull requests. Below are the instructions to set up the project locally for development purposes.

## Setup for Development Purposes
To set up the project for local development, follow these steps:

Open a terminal and navigate to the desired folder where you want to set up the project.
Clone the development branch by running the following command:

```git clone https://github.com/ptruessel/saaster```

Navigate to the project folder:

```cd saaster```

Copy the config files:

```mv config/example.env .env```
```mv config/example.config.cfm www/config.cfm```

Start the Docker containers:

```docker compose -f compose-dev.yml up -d```

Open your browser and visit http://localhost:8085 to see Saaster.

## Load Test Data
If you need to load test data for development purposes, you can find sample SQL files in the `config/db/dev/` folder.
To load the data, use the following command:

```cat ./config/db/dev/create-sysadmin.sql | docker exec -i mysql_dev mysql -u root -pmysql_root_pass mysql_database```
Make sure to change the SQL file name and update the MySQL credentials in the command if necessary.

## Mockdata
If you need some customers or invoices while developing, you can make use of the mockdata generator we implementet.
You can access it under: `www/setup/mockdata/index.cfm`


## 🔗 Dependencies

- [Tabler](https://github.com/tabler/tabler/blob/main/LICENSE)
- [Dropify](https://github.com/JeremyFagis/dropify/blob/master/LICENCE.md)
- [Trumbowyg](https://github.com/Alex-D/Trumbowyg/blob/develop/LICENSE)
- [Bootstrap](https://github.com/twbs/bootstrap/blob/main/LICENSE)
- [MockDataCFC](https://github.com/Ortus-Solutions/MockDataCFC/blob/development/LICENSE)
- [Fontawesome](https://fontawesome.com/v4/license/)
- [jquery](https://github.com/jquery/jquery)
- [taffy](https://github.com/atuttle/Taffy)