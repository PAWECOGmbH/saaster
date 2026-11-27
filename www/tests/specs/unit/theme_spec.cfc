component extends="testbox.system.BaseSpec" {

    /*
        theme.cfc - the sysadmin theme settings. Only Tabler's own theme attribute values and
        validated hex colors may reach the <html> attributes and the inline CSS of every
        backend page.
    */

    function beforeAll() {
        variables.theme = new backend.core.com.theme();
    }

    function run() {

        describe("normalizeValue", () => {

            it("returns a listed choice in its own spelling", () => {
                expect(variables.theme.normalizeValue("settingThemePrimary", " Green ")).toBe("green");
                expect(variables.theme.normalizeValue("settingThemeRadius", "1.5")).toBe("1.5");
                expect(variables.theme.normalizeValue("settingThemeNavbar", "primary")).toBe("primary");
            });

            it("falls back to the default for values outside the list", () => {
                expect(variables.theme.normalizeValue("settingThemePrimary", "inverted")).toBe("blue");
                expect(variables.theme.normalizeValue("settingThemeBase", 'slate" onclick="x')).toBe("neutral");
                expect(variables.theme.normalizeValue("settingThemeRadius", "1.0")).toBe("1");
                expect(variables.theme.normalizeValue("settingThemeFont", "comic")).toBe("sans-serif");
                expect(variables.theme.normalizeValue("settingThemeNavbar", "")).toBe("default");
            });

            it("accepts only six-digit hex colors as custom color", () => {
                expect(variables.theme.normalizeValue("settingColorPrimary", "##1F8A70")).toBe("##1f8a70");
                expect(variables.theme.normalizeValue("settingColorPrimary", "##fff")).toBe("##206bc4");
                expect(variables.theme.normalizeValue("settingColorPrimary", "red")).toBe("##206bc4");
                expect(variables.theme.normalizeValue("settingColorPrimary", "##123456;} body {display: none")).toBe("##206bc4");
            });

            it("accepts none, the Tabler colors and custom as accent colors", () => {
                expect(variables.theme.normalizeValue("settingThemeAccent", "none")).toBe("none");
                expect(variables.theme.normalizeValue("settingThemeAccent2", "Teal")).toBe("teal");
                expect(variables.theme.normalizeValue("settingThemeAccent", "brand")).toBe("none");
                expect(variables.theme.normalizeValue("settingColorAccent", "##FFE066")).toBe("##ffe066");
                expect(variables.theme.normalizeValue("settingColorAccent2", "url(x)")).toBe("##0ca678");
                expect(variables.theme.choices("settingThemeAccent")[1].value).toBe("none");
                expect(arrayLast(variables.theme.choices("settingThemeAccent2")).value).toBe("custom");
                expect(variables.theme.choices("settingThemePrimary")[1].value).toBe("blue");
            });

            it("leaves other settings untouched", () => {
                expect(variables.theme.normalizeValue("settingInvoicePrefix", " RE-")).toBe(" RE-");
                expect(variables.theme.choices("settingInvoicePrefix")).toBeEmpty();
            });

        });

        describe("themeSetting", () => {

            it("uses the Tabler defaults when the settings are missing", () => {
                var result = variables.theme.themeSetting({});

                expect(result.htmlAttributes).toBe(' data-bs-theme-primary="blue" data-bs-theme-base="neutral" data-bs-theme-radius="1" data-bs-theme-font="sans-serif"');
                expect(result.customCss).toBe("");
            });

            it("sets a color preset and the primary navbar as attributes only", () => {
                var result = variables.theme.themeSetting({
                    settingThemePrimary: "teal", settingThemeNavbar: "primary", settingThemeBase: "slate",
                    settingThemeRadius: "0.5", settingThemeFont: "serif", settingColorPrimary: "##123456"
                });

                expect(result.htmlAttributes).toInclude('data-bs-theme-primary="teal"');
                expect(result.htmlAttributes).toInclude('data-bs-theme-base="slate"');
                expect(result.htmlAttributes).toInclude('data-bs-theme-radius="0.5"');
                expect(result.htmlAttributes).toInclude('data-bs-theme-font="serif"');
                expect(result.htmlAttributes).toInclude('data-bs-navbar-theme="primary"');
                expect(result.customCss).toBe("");
            });

            it("overrides the primary tokens for a custom color", () => {
                var result = variables.theme.themeSetting({settingThemePrimary: "custom", settingColorPrimary: "##1F8A70"});

                expect(result.htmlAttributes).notToInclude("data-bs-theme-primary");
                expect(result.customCss).toInclude("--tblr-primary: ##1f8a70;");
                expect(result.customCss).toInclude("--tblr-primary-rgb: 31, 138, 112;");
                expect(result.customCss).toInclude("--tblr-primary-fg: var(--tblr-light);");
            });

            it("switches to dark text on light custom colors", () => {
                expect(variables.theme.themeSetting({settingThemePrimary: "custom", settingColorPrimary: "##f59f00"}).customCss)
                    .toInclude("--tblr-primary-fg: var(--tblr-dark);");
                expect(variables.theme.themeSetting({settingThemePrimary: "custom", settingColorPrimary: "##ffffff"}).customCss)
                    .toInclude("--tblr-primary-fg: var(--tblr-dark);");
            });

            it("gives light presets dark text and keeps the layout navigation for them", () => {
                var result = variables.theme.themeSetting({settingThemePrimary: "yellow", settingThemeNavbar: "primary"});

                expect(result.htmlAttributes).toInclude('data-bs-theme-primary="yellow"');
                expect(result.htmlAttributes).notToInclude("data-bs-navbar-theme");
                expect(result.primaryNavbar).toBeFalse();
                expect(result.customCss).toInclude("--tblr-primary-fg: var(--tblr-dark);");
                expect(result.customCss).toInclude("--tblr-link-color: light-dark(color-mix(in oklab, var(--tblr-primary) 55%, var(--tblr-black))");
                expect(result.customCss).notToInclude("--tblr-primary:");
            });

            it("keeps the layout navigation for light custom colors", () => {
                var light = variables.theme.themeSetting({settingThemePrimary: "custom", settingColorPrimary: "##ffe066", settingThemeNavbar: "primary"});
                var dark = variables.theme.themeSetting({settingThemePrimary: "custom", settingColorPrimary: "##1f8a70", settingThemeNavbar: "primary"});

                expect(light.primaryNavbar).toBeFalse();
                expect(light.htmlAttributes).notToInclude("data-bs-navbar-theme");
                expect(dark.primaryNavbar).toBeTrue();
                expect(dark.htmlAttributes).toInclude('data-bs-navbar-theme="primary"');
            });

            it("sets accent colors as Saaster tokens and marks the page for the accent decoration", () => {
                var result = variables.theme.themeSetting({settingThemeAccent: "orange", settingThemeAccent2: "custom", settingColorAccent2: "##1F8A70"});

                expect(result.hasAccent).toBeTrue();
                expect(result.htmlAttributes).toInclude("data-saaster-accent");
                expect(result.customCss).toInclude("--saaster-accent: var(--tblr-orange);");
                expect(result.customCss).toInclude("--saaster-accent-fg: var(--tblr-light);");
                expect(result.customCss).toInclude("--saaster-accent-text: light-dark(var(--saaster-accent), ");
                expect(result.customCss).toInclude("--saaster-accent-2: ##1f8a70;");
                expect(result.customCss).notToInclude("--tblr-primary:");
            });

            it("gives light accent colors dark text", () => {
                var result = variables.theme.themeSetting({settingThemeAccent: "custom", settingColorAccent: "##ffe066", settingThemeAccent2: "yellow"});

                expect(result.customCss).toInclude("--saaster-accent-fg: var(--tblr-dark);");
                expect(result.customCss).toInclude("--saaster-accent-text: light-dark(color-mix(in oklab, var(--saaster-accent) 55%, var(--tblr-black))");
                expect(result.customCss).toInclude("--saaster-accent-2-fg: var(--tblr-dark);");
            });

            it("uses the second accent color alone and leaves the first to the primary color", () => {
                var result = variables.theme.themeSetting({settingThemeAccent2: "teal"});

                expect(result.htmlAttributes).toInclude("data-saaster-accent");
                expect(result.customCss).toInclude("--saaster-accent-2: var(--tblr-teal);");
                expect(result.customCss).notToInclude("--saaster-accent:");
            });

            it("has no accent decoration without accent colors", () => {
                var result = variables.theme.themeSetting({settingThemeAccent: "none", settingThemeAccent2: "none", settingColorAccent: "##123456"});

                expect(result.hasAccent).toBeFalse();
                expect(result.htmlAttributes).notToInclude("data-saaster-accent");
                expect(result.customCss).notToInclude("--saaster-accent");
            });

            // --tblr-primary-rgb of the presets in tabler-themes.css (Tabler 1.7.5); update with Tabler
            it("marks exactly the presets below the contrast limit as darkText", () => {
                var tablerRgb = {
                    blue: "##066fd1", azure: "##4299e1", indigo: "##4263eb", purple: "##ae3ec9",
                    pink: "##d6336c", red: "##d63939", orange: "##f76707", yellow: "##f59f00",
                    lime: "##74b816", green: "##2fb344", teal: "##0ca678", cyan: "##17a2b8"
                };
                loop array=variables.theme.choices("settingThemePrimary") item="local.choice" {
                    if (local.choice.value eq "custom") continue;
                    expect(local.choice.darkText).toBe(variables.theme.needsDarkText(tablerRgb[local.choice.value]), local.choice.value);
                }
            });

        });

        describe("Tabler assets", () => {

            // tabler-themes.css and tabler-vendors.css (color picker on the settings page) must match tabler.min.css
            it("use one Tabler version in every template", () => {
                var scanner = new tests.support.security_scanner();
                var versions = {};
                loop array=["backend/core/views/css.cfm", "backend/core/views/js.cfm", "backend/core/views/sysadmin/system_settings.cfm"] item="local.file" {
                    loop array=reMatch("@tabler/core@[0-9.]+", scanner.readSource(local.file)) item="local.match" {
                        versions[local.match] = local.file;
                    }
                }
                expect(structCount(versions)).toBe(1, "Tabler versions: " & structKeyList(versions));
            });

        });

        describe("contrastWithWhite", () => {

            it("follows the WCAG formula", () => {
                expect(variables.theme.contrastWithWhite("##ffffff")).toBe(1);
                expect(round(variables.theme.contrastWithWhite("##000000"))).toBe(21);
                expect(variables.theme.needsDarkText("##206bc4")).toBeFalse();
                expect(variables.theme.needsDarkText("##2fb344")).toBeTrue();
            });

        });

    }

}
