# Copilot Instructions for Saaster

## Overview
Saaster is a CFML-based SaaS framework using Lucee 6, NGINX, and MySQL 8.1, containerized via Docker Compose. The codebase is modular, with clear separation between API, frontend, backend, and setup logic. Configuration is flexible and environment-driven.

## Architecture
- **Core directories:**
  - `www/`: Main web app (entry points, config, API, resources)
  - `api/`: API endpoints, JWT auth, Taffy REST framework
  - `frontend/`: UI, themes, mail templates
  - `backend/`: Admin, modules, business logic
  - `setup/`: Installation wizard, mock data loader
  - `config/`: Environment, NGINX, DB migrations, backups
- **Database migrations:**
  - SQL files in `config/db/core/` and `config/db/dev/` for schema and test data
- **Modularity:**
  - Features are added via modules in `backend/modules/`

## Developer Workflow
- **Local setup:**
  - Use `compose-dev.yml` with Docker Compose
  - Copy and edit config files from `config/` as described in the README
  - Access Lucee admin at `/lucee/admin/server.cfm` for DB and SMTP setup
  - Run setup wizard at `/setup/index.cfm` to initialize app and create sysadmin
- **Reload config:**
  - Visit `/index.cfm?reinit=1` after changing `config.cfm`
- **Test data:**
  - Import SQL from `config/db/dev/` or use `/setup/mockdata/index.cfm`
- **Custom Docker image:**
  - Commit configured Lucee container and update `.env` with new image name

## Conventions & Patterns
- **CFML/CFM:**
  - Application logic in `.cfc` (components), views in `.cfm` (templates)
  - API follows Taffy REST conventions in `api/taffy/`
  - JWT auth in `api/jwt/`
- **Config:**
  - Environment variables in `.env`, app config in `www/config.cfm`
  - NGINX config in `config/nginx/conf.d/`
- **Modules:**
  - Extendable via `backend/modules/` and `api/jwt/models/`
- **Testing:**
  - Manual via setup wizard and mock data; no automated test suite detected

## Integration Points
- **External:**
  - SMTP (local via Inbucket)
  - MySQL DB
  - NGINX reverse proxy
- **Internal:**
  - API endpoints communicate via REST (Taffy)
  - Frontend and backend share config and DB

## Examples
- To add a new API endpoint: create a `.cfc` in `api/resources/` and register in Taffy
- To add a module: place in `backend/modules/` and wire up in config
- To update DB schema: add migration SQL to `config/db/core/`

## References
- See `readme.md` for setup and workflow details
- Key config: `config/example.env`, `config/example.base.conf`, `config/example.config_dev.cfm`, `www/config.cfm`
- Setup logic: `setup/index.cfm`, `setup/mockdata/`

## Coding Instructions
- Comments and documentation should be in english. Never use german in code comments.
- Follow standard ColdFusion (Lucee 6) best practices script based.
- Use 4 spaces for indentation, no tabs.
- Instead of `var`, always use `local` to declare local variables, but only in functions.
- Instead of 'for' loops, prefer the cf tag 'loop'.
- In CF Script, SQL queries must always be built in this order: options, params, sql. The types should be like: {type: "string", value: arguments.importUUID}