component extends="tests.support.form_scanner" output="false" hint="Reads core sources as text for the static security specs: SQL interpolations, raw output, handler wiring." {

    /*
        Nothing here executes code. The specs use it to make sure that fixes stay in
        place: no new value interpolated into SQL without being reviewed, no database
        field written into a page without encoding, and the security calls still sit
        in the handler branches where they belong.
    */

    variables.sqlRoots = [
        "backend/core/com",
        "backend/core/handler",
        "backend/core/views",
        "frontend/core/com",
        "frontend/core/handler",
        "frontend/core/scheduletasks",
        "api/resources"
    ];

    public string function readSource(required string relativePath) {
        return replace(fileRead(expandPath("/" & reReplace(arguments.relativePath, "^/", "")), "utf-8"), chr(13), "", "all");
    }

    // All .cfm and .cfc files below the given roots, relative to www/.
    public array function filesBelow(required array roots) {
        var files = [];

        for (var root in arguments.roots) {
            var absoluteRoot = expandPath("/" & root);
            if (not directoryExists(absoluteRoot)) {
                continue;
            }
            for (var path in directoryList(absoluteRoot, true, "path", "*.cfm|*.cfc")) {
                arrayAppend(files, relativePath(path));
            }
        }

        arraySort(files, "textnocase");
        return files;
    }

    /*
        Every #expression# inside SQL: the sql string of queryExecute() and the body
        of cfquery tags. Values inside cfqueryparam tags are bound and left out.
        One entry per file and expression: { file, expression }.
    */
    public array function sqlInterpolations() {
        var result = [];

        for (var file in filesBelow(variables.sqlRoots)) {
            var source = readSource(file);
            // [^"]* instead of an alternation for escaped quotes: Lucee's default regex engine
            // recurses on alternations inside repetitions and overflows on long SQL strings.
            var blocks = findAll('\bsql\s*[=:]\s*"([^"]*)"', source).map((m) => m[2]);
            // Tag names are assembled from parts: Lucee would read a literal query tag inside a string as a tag.
            var queryTag = "cf" & "query";
            blocks.append(findAll("<" & queryTag & "\b[^>]*>([\s\S]*?)</" & queryTag & ">", source).map((m) => reReplaceNoCase(m[2], "<" & queryTag & "param\b[^>]*>", "", "all")), true);

            var seen = {};
            for (var block in blocks) {
                for (var match in findAll("##([^##\n]{1,120})##", block)) {
                    var expression = trim(match[2]);
                    if (len(expression) and not structKeyExists(seen, expression)) {
                        seen[expression] = true;
                        arrayAppend(result, { "file": file, "expression": expression });
                    }
                }
            }
        }

        return result;
    }

    /*
        Database values written into a page without encoding: #query.strX#, #query.txtX#,
        the user name from the session and the customer fields of the struct-based queries.
        Returns { file, line, expression } per occurrence.
    */
    public array function rawOutputs(required array roots) {
        var result = [];
        var field = "([a-zA-Z_][a-zA-Z0-9_.]*\.(?:str|txt)[A-Za-z0-9_]+|session\.user_name|[a-zA-Z_][a-zA-Z0-9_]*\.(?:companyName|contactPerson|customerName))";

        // An encoded value never matches these: "#encodeForHTML(q.strName)#" does not contain "#q.strName#".
        var patterns = [
            "##" & field & "##",                                        // #q.strName#
            "##(?:left|right|mid|trim|lCase|uCase)\(\s*" & field & "\b"  // #left(q.strName, 25)#
        ];

        for (var file in filesBelow(arguments.roots).filter((f) => right(f, 4) eq ".cfm")) {
            var lines = listToArray(readSource(file), chr(10), true);
            for (var lineNumber = 1; lineNumber lte arrayLen(lines); lineNumber++) {
                for (var pattern in patterns) {
                    for (var match in findAll(pattern, lines[lineNumber])) {
                        arrayAppend(result, { "file": file, "line": lineNumber, "expression": match[2], "source": trim(lines[lineNumber]) });
                    }
                }
            }
        }

        return result;
    }

    /*
        The body of a top-level handler branch "if (structKeyExists(form|url, 'key')) { ... }",
        found by brace matching. Empty if the branch does not exist.
    */
    public string function branchBody(required string relativePath, required string scope, required string key) {
        var source = readSource(arguments.relativePath);
        var start = reFindNoCase("if\s*\(\s*structKeyExists\(\s*" & arguments.scope & "\s*,\s*[""']" & arguments.key & "[""']\s*\)", source);

        if (not start) {
            return "";
        }

        var open = find("{", source, start);
        var depth = 0;
        for (var position = open; position lte len(source); position++) {
            var character = mid(source, position, 1);
            if (character eq "{") {
                depth++;
            } else if (character eq "}") {
                depth--;
                if (depth eq 0) {
                    return mid(source, open, position - open + 1);
                }
            }
        }

        return mid(source, open, len(source) - open + 1);
    }

}
