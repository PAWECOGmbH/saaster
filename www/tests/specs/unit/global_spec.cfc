component extends="testbox.system.BaseSpec" {

    /*
        global.cfc - helpers without database access: e-mail validation and
        password hashing. Uses the objGlobal instance the real application start
        put into the application scope.
    */

    function run() {

        describe("checkEmail", () => {

            it("accepts a plain address", () => {
                expect(application.objGlobal.checkEmail("info@example.com")).toBeTrue();
            });

            it("accepts dots, plus tags and subdomains", () => {
                expect(application.objGlobal.checkEmail("first.last+tag@mail.example.com")).toBeTrue();
            });

            it("ignores surrounding whitespace", () => {
                expect(application.objGlobal.checkEmail("  info@example.com  ")).toBeTrue();
            });

            it("rejects an empty value", () => {
                expect(application.objGlobal.checkEmail("")).toBeFalse();
            });

            it("rejects a value without @", () => {
                expect(application.objGlobal.checkEmail("info.example.com")).toBeFalse();
            });

            it("rejects a domain without a dot", () => {
                expect(application.objGlobal.checkEmail("info@localhost")).toBeFalse();
            });

            it("rejects spaces inside the address", () => {
                expect(application.objGlobal.checkEmail("in fo@example.com")).toBeFalse();
            });

        });

        describe("generateHash", () => {

            it("returns a salt and a hash", () => {
                var result = application.objGlobal.generateHash("secret");

                expect(result).toHaveKey("thisSalt");
                expect(result).toHaveKey("thisHash");
            });

            /*
                The login (frontend/core/com/login.cfc) recomputes the hash as
                hash(password & salt, 'SHA-512'). If generateHash ever changed its
                formula, every existing password would stop working.
            */
            it("hashes the string together with the salt using SHA-512", () => {
                var result = application.objGlobal.generateHash("secret");

                expect(result.thisHash).toBe(hash("secret" & result.thisSalt, "SHA-512"));
            });

            it("uses a new salt every time", () => {
                var first  = application.objGlobal.generateHash("secret");
                var second = application.objGlobal.generateHash("secret");

                expect(first.thisSalt).notToBe(second.thisSalt);
                expect(first.thisHash).notToBe(second.thisHash);
            });

        });

        describe("assetUrl", () => {

            it("appends the modification time of the file as version", () => {
                var path = "/backend/dist/js/backend.js";
                var expected = dateTimeFormat(getFileInfo(expandPath(path)).lastmodified, "yyyymmddHHnnss");

                expect(application.objGlobal.assetUrl(path)).toBe(path & "?v=" & expected);
            });

            it("returns the path unchanged if the file does not exist", () => {
                expect(application.objGlobal.assetUrl("/backend/dist/js/testbox-missing.js")).toBe("/backend/dist/js/testbox-missing.js");
            });

            // Lucee 6.2 could not compile the old ternary "objGlobal.assetUrl : (path) => path" (Lambda not present)
            it("is used by css.cfm and js.cfm, which compile and render", () => {
                for (var view in ["css", "js"]) {
                    savecontent variable="local.html" {
                        include "/backend/core/views/#view#.cfm";
                    }
                    expect(local.html).toInclude("/backend/dist/");
                    expect(reFind("/backend/dist/[^""]+\?v=\d{14}", local.html)).toBeGT(0, view & ".cfm: versioned asset");
                }
            });

        });

        /*
            The sysadmin and blog searches use MATCH ... AGAINST (... IN BOOLEAN MODE).
            MySQL throws a syntax error on dangling operators, so only words may pass.
        */
        describe("fullTextSearch", () => {

            it("turns every word into a prefix search", () => {
                expect(application.objGlobal.fullTextSearch("Muster AG")).toBe("Muster* AG*");
            });

            it("keeps umlauts, digits and apostrophes inside a word", () => {
                expect(application.objGlobal.fullTextSearch("Müller 8000 O'Neil")).toBe("Müller* 8000* O'Neil*");
            });

            it("searches an e-mail address as one phrase", () => {
                expect(application.objGlobal.fullTextSearch("info@example.com")).toBe('"info@example.com"');
                expect(application.objGlobal.fullTextSearch('"info@example.com"')).toBe('"info@example.com"');
            });

            it("accepts what the views send (wrapped in * or quotes)", () => {
                expect(application.objGlobal.fullTextSearch("*Muster*")).toBe("Muster*");
            });

            it("removes the boolean operators", () => {
                expect(application.objGlobal.fullTextSearch("+foo -bar ~baz (qux) <a >b ""c")).toBe("foo* bar* baz* qux* a* b* c*");
                expect(application.objGlobal.fullTextSearch("foo --")).toBe("foo*");
                expect(application.objGlobal.fullTextSearch("foo-bar")).toBe("foo* bar*");
            });

            it("returns an empty string when no word is left", () => {
                for (var input in ["", "   ", "-", "--", "~", "*", "**", "%", "()", "'", "+-<>"]) {
                    expect(application.objGlobal.fullTextSearch(input)).toBe("", "Input: " & input);
                }
            });

            it("keeps operators inside an e-mail phrase, where MySQL accepts them", () => {
                expect(application.objGlobal.fullTextSearch('a -- b@c ~ )')).toBe('"a -- b@c ~ )"');
                expect(application.objGlobal.fullTextSearch('" "')).toBe("");
            });

        });

    }

}
