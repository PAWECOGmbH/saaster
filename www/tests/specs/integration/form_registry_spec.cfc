component extends="tests.support.integration_spec" {

    /*
        Every form and every action link of the Saaster core, checked one by one
        against support/form_registry.cfc. The runner shows one entry per form and
        per link - that makes this spec the collection of all forms at the same time.

        What is checked:
          - The registry is complete: every form and action link in the core views
            and both themes is listed, and every listed entry still exists.
          - Handler forms post, carry the CSRF field, lead to a core handler that the
            CSRF rule protects, and that handler really reacts to the listed trigger.
          - View forms only search, sort, filter or navigate: read-only fields only.
          - Protected links carry the token on every occurrence and are covered by the rule.
          - Open links are documented. Real state changes without protection ("gap")
            appear as skipped specs until they are closed.

        Nothing is executed - the sources are read as text. Mapping paths come from
        the migrated base data in the test database.
    */

    function run() {

        var registry = new tests.support.form_registry();

        describe("Form registry", () => {

            beforeEach(() => {
                if (not structKeyExists(variables, "scanner")) {
                    variables.scanner = new tests.support.form_scanner();
                    variables.allForms = variables.scanner.scanForms();
                    variables.allLinks = variables.scanner.scanLinks();
                }
            });

            describe("completeness", () => {

                it("lists every form found in the core views and themes", () => {
                    var unlisted = [];

                    for (var formInfo in variables.allForms) {
                        if (countRegistryMatches(formInfo) neq 1) {
                            arrayAppend(unlisted, formInfo.file & " -> " & formInfo.target & " (" & arrayToList(formInfo.candidates, ", ") & ")");
                        }
                    }

                    if (arrayLen(unlisted)) {
                        fail("Forms not listed exactly once in form_registry.cfc:" & chr(10) & arrayToList(unlisted, chr(10)));
                    }
                });

                it("lists every link that triggers a handler action", () => {
                    var unlisted = [];

                    for (var link in variables.allLinks) {
                        var path = variables.scanner.resolveMapping(link.target);
                        if (not len(path) or not variables.scanner.isCoreHandler(path)) {
                            continue;
                        }

                        var dispatch = variables.scanner.dispatchKeys(path);
                        for (var key in link.urlKeys) {
                            if (structKeyExists(dispatch, "url." & key) and not isListedLink(link.file, link.target, "url." & key)) {
                                arrayAppend(unlisted, link.file & " -> " & link.target & "?" & key);
                            }
                        }
                    }

                    if (arrayLen(unlisted)) {
                        fail("Action links not listed in form_registry.cfc:" & chr(10) & arrayToList(uniqueValues(unlisted), chr(10)));
                    }
                });

                /*
                    Independent of the registry: if the CSRF rule protects a link, the
                    link must carry the token - otherwise the action is simply broken,
                    because every click is rejected. This is how links with an extra
                    key like "&delete" or "&revoke" are caught, whatever the registry
                    says about their main key.
                */
                it("puts a CSRF token on every link the CSRF rule protects", () => {
                    var broken = [];

                    for (var link in variables.allLinks) {
                        var path = variables.scanner.resolveMapping(link.target);
                        if (len(path) and application.objGlobal.csrfRequired(path, "GET", link.urlKeys) and not link.hasToken) {
                            arrayAppend(broken, link.file & " -> " & link.target & "?" & link.query);
                        }
                    }

                    if (arrayLen(broken)) {
                        fail("Links rejected by the CSRF check because the token is missing:" & chr(10) & arrayToList(uniqueValues(broken), chr(10)));
                    }
                });

            });

            describe("Handler forms (change data, CSRF protected)", () => {

                for (var entry in registry.handlerForms()) {
                    it(
                        title = entry.purpose & "  [" & shortFile(entry.file) & " -> " & entry.target & " | " & entry.trigger & "]",
                        data  = { entry: entry },
                        body  = (data) => {
                            var matches = matchingForms(data.entry);
                            expect(arrayLen(matches)).toBe(data.entry.count ?: 1, "Form not found as listed (stale registry entry?)");

                            for (var formInfo in matches) {
                                expect(formInfo.method).toBe("post", "Must be a POST form");
                                expect(formInfo.hasCsrfField).toBeTrue("The CSRF field ##csrfField()## is missing inside the form");

                                for (var target in (data.entry.resolvesTo ?: [data.entry.target])) {
                                    var path = variables.scanner.resolveMapping(target);
                                    expect(path).notToBeEmpty("Mapping [#target#] does not exist");
                                    expect(variables.scanner.isCoreHandler(path)).toBeTrue("[#target#] leads to [#path#], not to a core handler");
                                    expect(application.objGlobal.csrfRequired(path, "POST", formInfo.urlKeys)).toBeTrue("The CSRF rule does not cover [#path#]");

                                    var dispatch = variables.scanner.dispatchKeys(path);
                                    for (var trigger in listToArray(data.entry.trigger)) {
                                        expect(dispatch).toHaveKey(trigger, "[#path#] does not react to [#trigger#] on its top level");
                                    }
                                }
                            }
                        }
                    );
                }

            });

            describe("View forms (search, sort, filter, navigate - no CSRF needed)", () => {

                for (var entry in registry.viewForms()) {
                    it(
                        title = entry.purpose & "  [" & shortFile(entry.file) & " -> " & entry.target & "]",
                        data  = { entry: entry, readOnlyFields: registry.readOnlyFields() },
                        body  = (data) => {
                            var matches = matchingForms(data.entry);
                            expect(arrayLen(matches)).toBe(data.entry.count ?: 1, "Form not found as listed (stale registry entry?)");

                            var path = variables.scanner.resolveMapping(data.entry.target);
                            expect(path).notToBeEmpty("Mapping [#data.entry.target#] does not exist");
                            expect(application.objGlobal.csrfRequired(path, "POST", [])).toBeFalse("[#path#] is protected - this is a handler form, not a view form");

                            for (var formInfo in matches) {
                                expect(formInfo.hasCsrfField).toBeTrue("The CSRF field ##csrfField()## is missing inside the form");

                                var writable = formInfo.fields.filter((field) => not arrayFindNoCase(data.readOnlyFields, field));
                                expect(writable).toBeEmpty("Fields beyond search/sort/filter: [#arrayToList(writable)#] - such a form must post to a handler");
                            }
                        }
                    );
                }

            });

            describe("Inert forms (never submitted)", () => {

                for (var entry in registry.inertForms()) {
                    it(
                        title = entry.purpose & "  [" & shortFile(entry.file) & "]",
                        data  = { entry: entry },
                        body  = (data) => {
                            var matches = matchingForms(data.entry);
                            expect(arrayLen(matches)).toBe(1, "Form not found as listed (stale registry entry?)");
                            expect(matches[1].fields).toBeEmpty("This form now has fields - it is no longer inert and needs a real target");
                        }
                    );
                }

            });

            describe("Protected action links (GET with CSRF token)", () => {

                for (var entry in registry.protectedLinks()) {
                    it(
                        title = entry.purpose & "  [" & shortFile(entry.file) & " -> " & entry.target & "?" & listLast(entry.key, ".") & "]",
                        data  = { entry: entry },
                        body  = (data) => {
                            var occurrences = matchingLinks(data.entry);
                            expect(arrayLen(occurrences)).toBeGT(0, "Link not found as listed (stale registry entry?)");

                            var path = variables.scanner.resolveMapping(data.entry.target);
                            expect(variables.scanner.dispatchKeys(path)).toHaveKey(data.entry.key, "[#path#] does not react to [#data.entry.key#]");

                            for (var link in occurrences) {
                                expect(link.hasToken).toBeTrue("An occurrence in [#data.entry.file#] has no ##csrfParam()##");
                                expect(application.objGlobal.csrfRequired(path, "GET", link.urlKeys)).toBeTrue("The CSRF rule does not cover this link");
                            }
                        }
                    );
                }

            });

            describe("Open action links (GET without CSRF token)", () => {

                for (var entry in registry.openLinks()) {
                    var title = entry.purpose & "  [" & shortFile(entry.file) & " -> " & entry.target & "?" & listLast(entry.key, ".") & "]";

                    if (entry.reason eq "gap") {
                        // A real state change without protection - visible as skipped until it is closed.
                        it(
                            title  = "GAP - needs CSRF protection: " & title,
                            data   = { entry: entry },
                            skip   = true,
                            labels = "csrf-gap",
                            body   = (data) => {
                                expect(arrayLen(matchingLinks(data.entry))).toBeGT(0);
                            }
                        );
                    } else {
                        it(
                            title = "accepted without token (" & entry.reason & "): " & title,
                            data  = { entry: entry },
                            body  = (data) => {
                                var occurrences = matchingLinks(data.entry);
                                expect(arrayLen(occurrences)).toBeGT(0, "Link not found as listed (stale registry entry?)");

                                var path = variables.scanner.resolveMapping(data.entry.target);
                                for (var link in occurrences) {
                                    expect(application.objGlobal.csrfRequired(path, "GET", link.urlKeys)).toBeFalse("This link is now CSRF protected - move it to protectedLinks()");
                                }
                            }
                        );
                    }
                }

                it("still finds every documented gap in the code", () => {
                    var stale = registry.openLinks()
                        .filter((entry) => entry.reason eq "gap")
                        .filter((entry) => arrayLen(matchingLinks(entry)) eq 0)
                        .map((entry) => entry.file & " -> " & entry.target & "?" & listLast(entry.key, "."));

                    if (arrayLen(stale)) {
                        fail("Documented gaps no longer found - remove them from openLinks():" & chr(10) & arrayToList(stale, chr(10)));
                    }
                });

            });

        });

    }


    // ---------- helpers ----------

    // Scanned forms of the entry's file and target whose submitted names contain every listed trigger.
    private array function matchingForms(required struct entry) {
        var triggers = listToArray(arguments.entry.trigger ?: "");

        return variables.allForms.filter((formInfo) => {
            if (formInfo.file neq entry.file or formInfo.target neq entry.target) {
                return false;
            }
            for (var trigger in triggers) {
                if (not arrayFindNoCase(formInfo.candidates, trigger)) {
                    return false;
                }
            }
            return true;
        });
    }

    private array function matchingLinks(required struct entry) {
        var key = listLast(arguments.entry.key, ".");

        return variables.allLinks.filter((link) => link.file eq entry.file and link.target eq entry.target and arrayFindNoCase(link.urlKeys, key));
    }

    // How many registry entries (of any kind) describe this scanned form.
    private numeric function countRegistryMatches(required struct formInfo) {
        var registry = new tests.support.form_registry();
        var matches = 0;

        for (var entry in registry.handlerForms().merge(registry.viewForms()).merge(registry.inertForms())) {
            if (entry.file neq arguments.formInfo.file or entry.target neq arguments.formInfo.target) {
                continue;
            }

            var triggers = listToArray(entry.trigger ?: "");
            var allPresent = true;
            for (var trigger in triggers) {
                if (not arrayFindNoCase(arguments.formInfo.candidates, trigger)) {
                    allPresent = false;
                    break;
                }
            }

            if (allPresent) {
                matches++;
            }
        }

        return matches;
    }

    private boolean function isListedLink(required string file, required string target, required string key) {
        var registry = new tests.support.form_registry();

        for (var entry in registry.protectedLinks().merge(registry.openLinks())) {
            if (entry.file eq arguments.file and entry.target eq arguments.target and entry.key eq arguments.key) {
                return true;
            }
        }

        return false;
    }

    private string function shortFile(required string file) {
        return reReplace(reReplace(arguments.file, "^backend/core/views/", ""), "^frontend/([a-z_]+)/templates/", "\1:");
    }

    private array function uniqueValues(required array values) {
        var seen = {};
        return arguments.values.filter((value) => {
            if (structKeyExists(seen, value)) {
                return false;
            }
            seen[value] = true;
            return true;
        });
    }

}
