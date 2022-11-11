# Saaster

Saaster is a web application written in CFML that offers all the basic functionality that you need for a SaaS project.

#### Used open source software:
- https://github.com/tabler/tabler/blob/main/LICENSE
- https://github.com/JeremyFagis/dropify/blob/master/LICENCE.md
- https://github.com/Alex-D/Trumbowyg/blob/develop/LICENSE
- https://github.com/twbs/bootstrap/blob/main/LICENSE
- https://github.com/Ortus-Solutions/MockDataCFC/blob/development/LICENSE
- https://fontawesome.com/v4/license/
- https://github.com/jquery/jquery

## Requirements

To run saaster we recommend your host supports:

- MySQL 5.7 or greater.
- Lucee 5.3 or greater.
- Any web server. The chosen web server should support URL rewriting.

That's pretty much it. Saaster should run on all popular web servers and got tested with IIS and Tuckey servlet filter. The chosen web server should support URL rewriting.

## Local development environment

Windows:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) with any Distrobution for example: [Ubuntu](https://apps.microsoft.com/store/detail/ubuntu/9PDXGNCFSCZV?hl=en-en&gl=EN)</br> In Docker Desktop enable WSL Integration with the distro you choosed.
- make (Install in WSL2 distro)

Linux:

- Docker
- Docker Compose
- make

MacOS:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- make (Install over xcode)

## Setup local development environment

### 1. Clone the repository

```git
git clone https://github.com/PAWECOGmbH/saaster
```

### 2. Create the required config files

You can find some example config files in the "configs" folder of the repository. Copy them to the root directory of the application and rename them as followed:

```plain
config/example.cfconfig.json   ->   /.cfconfig.json
config/example.env             ->   /.env
config/example.server.json     ->   /server.json
config/example.config.cfm      ->   /config.cfm
```

These files should work out of the box. You can obviously change the values of these configs to your liking.

### 3. Start the application

Now you can start the application. Open any console* in the root application directory and execute the following commands:

> *On Windows you need to use the WSL distro to use make. The filesystem of Windows is normally mounted under /mnt on your WSL system.

```bash
make
```

This will output all possible commands:

```plain
Makefile commands:
dev                     -> creates the local development environment      
reinit                  -> reinites the database
seed                    -> seeds certain sql files
clean                   -> removes full application with all containers
url                     -> outputs all importent URL's of the application
```

Now enter `make dev` and let the application build.</br>
If everything worked out, then it should display the URL's:

```bash
------------------------------------------------------
Saaster: http://localhost/login
Mailslurper: http://localhost:9000
Lucee Admin: http://localhost/lucee/admin/server.cfm
------------------------------------------------------
```


### Seeding MySQL files

In the directory `db/dev` you find some SQL files. These files provide you with example data and or basic configuration for saaster.

To execute these files, use the following make command:

```bash
make seed
```

Then enter the number of the sql file you would like to seed.

```bash
[1] create-plans.sql   
[2] create-widgets.sql 
[3] create-sysadmin.sql
[4] create-modules.sql 
Choose a number: 3
```

### Rebuild database

To completly rebuild the database, you can use the make target `reinit`. This command rebuilds the complete MySQL container and executes all the scripts in the `db/init` directory.

```bash
make reinit
```

### Mockdata

If you need some customers or invoices while developing, you can make use of the mockdata generator we implementet.

You can access it under `/setup/mockdata/index.cfm`
