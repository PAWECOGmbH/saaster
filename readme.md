# Saaster - Development Branch
## Introduction
Welcome to the development branch of Saaster. 
This branch is meant for contributors and developers to collaborate and improve the project. Feel free to fork the repository, make changes, and create pull requests. Below are the instructions to set up the project locally for development purposes.
## Setup for Development Purposes
To set up the project for local development, follow these steps:

### Step 1
Open a terminal and navigate to the desired folder where you want to set up the project.

### Step 2
Clone the development branch by running the following command:

```git clone --branch development https://github.com/ptruessel/saaster```

### Step 3
Navigate to the project folder:

```cd saaster```

### Step 4
Set up configuration files:

```mv config/example.env .env```

```mv config/example.config.cfm www/config.cfm```

### Step 5
Modify the configuration settings (optional):
- To modify the `.env` file:
  
  ```nano .env```
  
- To modify the `config.cfm` file:
  
  ```nano www/config.cfm```

### Step 6
Start the Docker containers:

```docker compose up -d```

_Note: This might take a while to initialize._

### Step 7
Verify that the containers are running:

```docker ps -a```

_You should see three running containers, except for Flyway, which only runs when required._

### Step 8
Open your browser and visit http://localhost:8085 to see Saaster.


## Load Test Data
If you need to load test data for development purposes, you can find sample SQL files in the `config/db/dev/` folder.

To load the data, use the following command:

```cat ./config/db/dev/create-sysadmin.sql | docker exec -i mysql8 mysql -u user -pdefaultpass saaster```

Make sure to change the SQL file name and update the MySQL credentials in the command if necessary.

