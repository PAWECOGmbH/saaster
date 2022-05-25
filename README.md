# Saaster

Opensource saas solution written in CFML.

## Requirements for development environment

Windows:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) with any Distrobution for example: [Ubuntu](https://apps.microsoft.com/store/detail/ubuntu/9PDXGNCFSCZV?hl=en-en&gl=EN)</br> In Docker Desktop enable WSL Integration with the distro you choosed.
- make (Install in WSL2 distro)

Linux:

- Docker
- Docker Compose
- make

MacOS:

- Not tested yet. Coming soon...

## Setup local development environment

### 1. Clone the repository

```
git clone https://github.com/PAWECOGmbH/saaster
```

### 2. Create the required config files

You can find some example config files in the "configs" folder of the repository. Copy them to the root directory of the application and rename them as followed:

```
config/example.cfconfig.json   ->   /.cfconfig.json
config/example.env             ->   /.env
config/example.server.json     ->   /server.json
```

These files should work out of the box. You can obviously change the values of these configs to your liking.

### 3. Start the application

Now you can start the application. Open any console* in the root application directory and execute following commands:

> *On Windows you need to use the WSL distro to use make. The filesystem of Windows ist mounted unter /mnt on your WSL system.

```
make
```

This will output all possible commands:

```
Makefile commands:
dev                     -> creates the local development environment      
reinit                  -> reinites the database
seed                    -> seeds certain sql files
clean                   -> removes full application with all containers
build                   -> starts the application in production mode (not wokrking yet.)
url                     -> outputs all importent URL's of the application
```

Now enter `make dev` and let the application build.</br>
If everything worked out, then it should display the URL's:

```
------------------------------------------------------
Saaster: http://localhost/login
Mailslurper: http://localhost:9000
Lucee Admin: http://localhost/lucee/admin/server.cfm
------------------------------------------------------
```

</br>

## Seeding MySQL files

In the directory db/dev/ you find some SQL files. This files provide you with testdata or basic configuration of saaster.

To execute this files, use following make command:

```
make seed
```

Then enter the number of the sql file you would like to seed.

```
[1] create-plans.sql   
[2] create-widgets.sql 
[3] create-sysadmin.sql
[4] create-modules.sql 
Choose a number: 3
```
