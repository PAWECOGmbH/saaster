SHELL := bash

help:
	@echo Available targets:
	@echo dev 		-> Creates a local development environment
	@echo reinit 	-> Rebuilds the database
	@echo seed 		-> Ability to seed test data
	@echo clean 	-> Remove all containers and volumes
	@echo url 		-> List of all URLs

.DEFAULT_GOAL := help

.PHONY: dev reinit seed clean url

dev:
	@cd .
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
	@cd .
	@echo Rebuilding MySQL container
	@echo ------------------------------------------------------
	@docker-compose rm -svf mysql
	@docker-compose up -d mysql
	@echo ------------------------------------------------------

seed:
	@cd .
	@n=0; \
	for file in $(notdir $(wildcard db/dev/*.sql)); do \
		let "n+=1" ; \
		echo "[$$n]" $$file; \
	done
	@echo "Choose a number: "; \
    read number; \
	k=0; \
	for file in $(notdir $(wildcard db/dev/*.sql)); do \
		let "k+=1"; \
		if [ "$$k" = "$$number" ]; then \
		sqlfile="$$file"; \
		echo "[+]" $$sqlfile;\
		fi \
	done; \
	MYSQL_SEED_FILE="$$sqlfile" \
	docker-compose up -d db_seeder
	@echo Done!

clean:
	@cd .
	@echo Removing all containers
	@echo ------------------------------------------------------
	@docker-compose down -v
	@echo ------------------------------------------------------
	@echo Done!

url:
	@cd .
	@echo 	
	@echo ------------------------------------------------------
	@echo Saaster:		http://localhost/login
	@echo Mailslurper: 	http://localhost:9000
	@echo Lucee Admin:	http://localhost/lucee/admin/server.cfm
	@echo ------------------------------------------------------
	@echo