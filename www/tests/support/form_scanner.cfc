component output="false" hint="Finds every form and every action link in the core views and themes, and resolves where they lead." {

    /*
        Reads the .cfm sources as text - nothing is executed. Used by
        specs/integration/form_registry_spec.cfc to compare the real code with
        support/form_registry.cfc.

        The regular expressions avoid engine-specific flags on purpose ([\s\S]
        instead of a dot-all mode), so they behave the same with Lucee's default
        regex engine and with the Java engine.
    */

    variables.scanRoots = [
        "backend/core/views",
        "frontend/default_theme",
        "frontend/custom_theme"
    ];

    public any function init() {
        variables.webRoot = replace(expandPath("/"), "\", "/", "all");
        variables.mappingCache = {};
        variables.dispatchCache = {};
        return this;
    }

    // All .cfm files below the scan roots, as paths relative to www/.
    public array function sourceFiles() {
        var files = [];

        for (var root in variables.scanRoots) {
            var absoluteRoot = expandPath("/" & root);
            if (not directoryExists(absoluteRoot)) {
                continue;
            }
            for (var path in directoryList(absoluteRoot, true, "path", "*.cfm")) {
                arrayAppend(files, relativePath(path));
            }
        }

        arraySort(files, "textnocase");
        return files;
    }

    /*
        Every <form> with its target and the names it submits.

        "candidates" are all names a handler could react to: "form.<field>" for every
        named field inside the form and "url.<key>" for every key in the action's
        query string - exactly the shape of the triggers in form_registry.cfc.
    */
    public array function scanForms() {
        var forms = [];

        for (var file in sourceFiles()) {
            var source = fileRead(expandPath("/" & file), "utf-8");

            for (var match in findAll("<form\b([^>]*)>([\s\S]*?)</form>", source)) {
                var attributes = match[2];
                var body = match[3];
                var action = firstGroup('action="([^"]*)"', attributes);
                var method = lCase(firstGroup('method="?([a-z]+)', attributes));
                var target = normaliseTarget(action);

                var fields = uniqueLowerCase(findAll('name="([^"##]+)"', body).map((m) => m[2]));
                var urlKeys = queryKeys(queryPart(action));
                var candidates = fields.map((f) => "form." & f);
                candidates.append(urlKeys.map((k) => "url." & k), true);

                arrayAppend(forms, {
                    "file": file,
                    "action": action,
                    "method": len(method) ? method : "get",
                    "target": target.path,
                    "urlKeys": urlKeys,
                    "fields": fields,
                    "candidates": candidates,
                    "hasCsrfField": findNoCase("csrfField()", body) gt 0
                });
            }
        }

        return forms;
    }

    // Every link to #application.mainURL#/<target>?<query>, one entry per occurrence.
    // Form actions are not links - POST forms are covered by scanForms() - so <form> tags are blanked first.
    public array function scanLinks() {
        var links = [];

        for (var file in sourceFiles()) {
            var source = reReplaceNoCase(fileRead(expandPath("/" & file), "utf-8"), "<form\b[^>]*>", "<form>", "all");

            for (var match in findAll("##application\.mainURL##/([a-z/\-]+)\?([^""'\s<>]*)", source)) {
                arrayAppend(links, {
                    "file": file,
                    "target": match[2],
                    "query": match[3],
                    "urlKeys": queryKeys(match[3]),
                    "hasToken": findNoCase("csrfParam()", match[3]) gt 0
                });
            }
        }

        return links;
    }

    /*
        The template a mapping points to, as Saaster's router (global.cfc::getSEF)
        would find it: system, custom and frontend mappings. Empty if unknown.
    */
    public string function resolveMapping(required string target) {
        if (structKeyExists(variables.mappingCache, arguments.target)) {
            return variables.mappingCache[arguments.target];
        }

        var result = queryExecute(
            "SELECT strPath FROM system_mappings WHERE strMapping = :mapping
             UNION SELECT strPath FROM custom_mappings WHERE strMapping = :mapping
             UNION SELECT strPath FROM frontend_mappings WHERE strMapping = :mapping
             LIMIT 1",
            { mapping: { type: "varchar", value: arguments.target } },
            { datasource: application.datasource }
        );

        variables.mappingCache[arguments.target] = result.recordCount ? result.strPath : "";
        return variables.mappingCache[arguments.target];
    }

    /*
        The keys a handler dispatches on: every "if (structKeyExists(form|url, 'x'))"
        on the top level of the file. Nested checks are parameters of an action, not
        actions. Most handlers start their branches in column 0, some wrap all of them
        in one indented block - so "top level" is the smallest indentation at which
        such a check occurs in that file. Returned as a struct: { "form.x": true }.
    */
    public struct function dispatchKeys(required string templatePath) {
        if (structKeyExists(variables.dispatchCache, arguments.templatePath)) {
            return variables.dispatchCache[arguments.templatePath];
        }

        var byIndent = {};
        var absolutePath = expandPath("/" & reReplace(arguments.templatePath, "^/", ""));

        if (fileExists(absolutePath)) {
            for (var line in listToArray(replace(fileRead(absolutePath, "utf-8"), chr(13), "", "all"), chr(10))) {
                var scope = firstGroup("^\s*(?:\}\s*else\s*)?if\s*\(\s*structKeyExists\(\s*(form|url)\s*,", line);
                var key = firstGroup("^\s*(?:\}\s*else\s*)?if\s*\(\s*structKeyExists\(\s*(?:form|url)\s*,\s*[""']([^""']+)[""']", line);
                if (len(scope) and len(key)) {
                    var indent = len(line) - len(reReplace(line, "^\s+", ""));
                    if (not structKeyExists(byIndent, indent)) {
                        byIndent[indent] = {};
                    }
                    byIndent[indent][lCase(scope & "." & key)] = true;
                }
            }
        }

        var levels = structKeyArray(byIndent);
        arraySort(levels, "numeric");
        var keys = arrayLen(levels) ? byIndent[levels[1]] : {};

        variables.dispatchCache[arguments.templatePath] = keys;
        return keys;
    }

    public boolean function isCoreHandler(required string templatePath) {
        return reFindNoCase("^/?(backend|frontend)/core/handler/", arguments.templatePath) gt 0;
    }


    // ---------- helpers ----------

    // All matches of a regex, each as an array: [full match, group 1, group 2, ...]
    private array function findAll(required string regex, required string text) {
        var results = [];
        var start = 1;

        while (start lte len(arguments.text)) {
            var found = reFindNoCase(arguments.regex, arguments.text, start, true);
            if (found.pos[1] eq 0) {
                break;
            }

            var groups = [];
            for (var i = 1; i lte arrayLen(found.pos); i++) {
                arrayAppend(groups, found.pos[i] gt 0 ? mid(arguments.text, found.pos[i], found.len[i]) : "");
            }
            arrayAppend(results, groups);

            start = found.pos[1] + max(found.len[1], 1);
        }

        return results;
    }

    private string function firstGroup(required string regex, required string text) {
        var found = reFindNoCase(arguments.regex, arguments.text, 1, true);
        return (found.pos[1] gt 0 and arrayLen(found.pos) gte 2 and found.pos[2] gt 0) ? mid(arguments.text, found.pos[2], found.len[2]) : "";
    }

    // "#application.mainURL#/sysadm/plans?x=1" -> { path: "sysadm/plans" }
    private struct function normaliseTarget(required string action) {
        var value = replaceNoCase(arguments.action, "##application.mainURL##", "", "all");
        value = reReplace(value, "^/", "");
        return { "path": listFirst(value & "?", "?") };
    }

    private string function queryPart(required string action) {
        return find("?", arguments.action) ? listRest(arguments.action, "?") : "";
    }

    // Names of the query parameters, without CFML expressions like #csrfParam()#.
    private array function queryKeys(required string query) {
        var keys = [];
        for (var pair in listToArray(arguments.query, "&")) {
            var key = lCase(trim(listFirst(pair, "=")));
            if (len(key) and not find("##", key)) {
                arrayAppend(keys, key);
            }
        }
        return uniqueLowerCase(keys);
    }

    private array function uniqueLowerCase(required array values) {
        var seen = {};
        var result = [];
        for (var value in arguments.values) {
            var normalised = lCase(trim(value));
            if (len(normalised) and not structKeyExists(seen, normalised)) {
                seen[normalised] = true;
                arrayAppend(result, normalised);
            }
        }
        return result;
    }

    private string function relativePath(required string absolutePath) {
        var normalised = replace(arguments.absolutePath, "\", "/", "all");
        return replaceNoCase(normalised, variables.webRoot, "", "one");
    }

}
