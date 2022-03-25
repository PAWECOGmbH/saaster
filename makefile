SHELL := bash

help:
	@echo Makefile commands:
	@echo dev
	@echo reinit
	@echo seed
	@echo clean
	@echo build
	@echo url

.DEFAULT_GOAL := help

.PHONY: dev reinit seed clean build url

dev:
	@echo Creating local development environment
	@echo ------------------------------------------------------
	@docker-compose up -d cfml mysql mailslurper
	@echo Wait until all containers are ready...
	@until curl --output /dev/null --silent --head --fail http://localhost:80; do\
		sleep 0.1;\
	done
	@echo 	
	@echo ------------------------------------------------------
	@echo Saaster:		http://localhost/login
	@echo Mailslurper:	http://localhost:9000
	@echo Lucee Admin:	http://localhost/lucee/admin/server.cfm
	@echo ------------------------------------------------------
	@echo

reinit:
	@echo Rebuilding MySQL container
	@echo ------------------------------------------------------
	@docker-compose rm -svf mysql
	@docker-compose up -d mysql
	@echo ------------------------------------------------------

seed:
	@echo Seeding testdata..
	@docker-compose up -d db_seeder
	@echo Done!

clean:
	@echo Removing all containers
	@echo ------------------------------------------------------
	@docker-compose down -v
	@echo ------------------------------------------------------
	@echo Done!

build:
	@echo Starting application in production...
	@echo ------------------------------------------------------
	@docker-compose up -d cfml mysql
	@echo ------------------------------------------------------
	@echo Done!

url:
	@echo 	
	@echo ------------------------------------------------------
	@echo Saaster:		http://localhost/login
	@echo Mailslurper: 	http://localhost:9000
	@echo Lucee Admin:	http://localhost/lucee/admin/server.cfm
	@echo ------------------------------------------------------
	@echo