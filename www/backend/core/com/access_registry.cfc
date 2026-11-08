component output="false" hint="Immutable application and module permission manifests, loaded at application startup." {

    public any function init(array manifests = []) {
        variables.permissions = {};
        variables.routes = {};
        loop array=arguments.manifests item="local.manifest" {
            registerManifest(local.manifest);
        }
        return this;
    }

    public any function load() {
        local.manifests = [];
        local.paths = [expandPath("/backend/myapp/access.json")];
        loop array=directoryList(expandPath("/backend/modules"), false, "path") item="local.modulePath" {
            if (directoryExists(local.modulePath)) {
                arrayAppend(local.paths, local.modulePath & "/access.json");
            }
        }
        arraySort(local.paths, "textnocase");
        loop array=local.paths item="local.path" {
            if (fileExists(local.path)) {
                local.manifest = deserializeJSON(fileRead(local.path, "utf-8"));
                local.manifest.basePath = replace(replace(getDirectoryFromPath(local.path), expandPath("/"), ""), chr(92), "/", "all");
                arrayAppend(local.manifests, local.manifest);
            }
        }
        return init(local.manifests);
    }

    public struct function permission(required string key) {
        return duplicate(variables.permissions[arguments.key] ?: {});
    }

    public array function granted(required string scope, required array roles) {
        local.result = [];
        loop collection=variables.permissions key="local.key" item="local.permission" {
            if (local.permission.scope eq arguments.scope) {
                loop array=arguments.roles item="local.role" {
                    if (arrayFindNoCase(local.permission.roles, local.role)) {
                        arrayAppend(local.result, local.key);
                        break;
                    }
                }
            }
        }
        return local.result;
    }

    public struct function policy(required string path, required string method) {
        local.path = lCase(reReplace(arguments.path, "^/", ""));
        if (not structKeyExists(variables.routes, local.path)) {
            return {registered: false, permissions: []};
        }
        return {registered: true, permissions: duplicate(variables.routes[local.path][uCase(arguments.method)] ?: [])};
    }

    private void function registerManifest(required struct manifest) {
        local.namespace = arguments.manifest.namespace ?: "";
        local.base = arguments.manifest.basePath ?: "";
        if (not reFind("^[a-z][a-z0-9_]*$", local.namespace) or listFind("organization,tenant", local.namespace)
            or not reFind("^backend/(myapp/|modules/[a-zA-Z0-9_-]+/)$", local.base)) {
            invalid("Invalid extension namespace or base path.");
        }
        loop array=(arguments.manifest.permissions ?: []) item="local.permission" {
            local.key = local.permission.key ?: "";
            if (left(local.key, len(local.namespace) + 1) neq local.namespace & "."
                or len(local.key) gt 80 or not reFind("^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$", local.key)
                or structKeyExists(variables.permissions, local.key)
                or not listFind("organization,tenant", local.permission.scope ?: "")
                or not len(trim(local.permission.label ?: "")) or not isArray(local.permission.roles ?: "")) {
                invalid("Invalid or duplicate permission: " & local.key);
            }
            loop array=local.permission.roles item="local.role" {
                if (not listFind("organization.owner,organization.admin,organization.member,tenant.admin,tenant.editor,tenant.viewer", local.role)
                    or (local.permission.scope eq "organization" and left(local.role, 7) eq "tenant.")) {
                    invalid("Invalid role grant for " & local.key);
                }
            }
            variables.permissions[local.key] = duplicate(local.permission);
        }
        loop array=(arguments.manifest.routes ?: []) item="local.route" {
            local.path = lCase(local.base & (local.route.path ?: ""));
            if (not reFind("^[a-z0-9_/-]+\.cfm$", local.path) or find("//", local.path)
                or not isArray(local.route.methods ?: "") or not arrayLen(local.route.methods)
                or not isArray(local.route.permissions ?: "") or not arrayLen(local.route.permissions)) {
                invalid("Invalid extension route: " & local.path);
            }
            loop array=local.route.permissions item="local.key" {
                if (not structKeyExists(variables.permissions, local.key) or left(local.key, len(local.namespace) + 1) neq local.namespace & ".") {
                    invalid("Unknown permission for " & local.path);
                }
            }
            if (not structKeyExists(variables.routes, local.path)) {
                variables.routes[local.path] = {};
            }
            loop array=local.route.methods item="local.method" {
                if (not listFind("GET,POST,PUT,PATCH,DELETE,HEAD", local.method) or structKeyExists(variables.routes[local.path], local.method)) {
                    invalid("Invalid or duplicate HTTP method for " & local.path);
                }
                variables.routes[local.path][local.method] = duplicate(local.route.permissions);
            }
        }
    }

    private void function invalid(required string message) {
        throw(type = "Saaster.Access.InvalidManifest", message = arguments.message);
    }
}
