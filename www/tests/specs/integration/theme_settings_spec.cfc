component extends="tests.support.integration_spec" {

    /*
        Sysadmin theme settings: saving keeps only allowed values, backend pages carry the
        Tabler theme attributes on <html>, and the settings page shows the saved theme.
    */

    variables.themeSettings = "settingThemePrimary,settingColorPrimary,settingThemeAccent,settingColorAccent,settingThemeAccent2,settingColorAccent2,settingThemeNavbar,settingThemeBase,settingThemeRadius,settingThemeFont";

    function run() {

        describe("Theme settings", () => {

            beforeEach(() => {
                logout();
                variables.savedSettings = readSettings();
                variables.previousSettingStruct = duplicate(application.systemSettingStruct);
                variables.previousTheme = duplicate(application.themeStruct);
            });

            afterEach(() => {
                loop collection=variables.savedSettings key="local.setting" {
                    writeSetting(local.setting, variables.savedSettings[local.setting]);
                }
                application.systemSettingStruct = variables.previousSettingStruct;
                application.themeStruct = variables.previousTheme;
            });

            it("are stored with allowed values only", () => {
                application.objSysadmin.saveSystemSettings({
                    fieldnames: variables.themeSettings,
                    settingThemePrimary: "Green",
                    settingColorPrimary: "##123456;} body {display: none",
                    settingThemeAccent: "custom",
                    settingColorAccent: "##AE3EC9",
                    settingThemeAccent2: "magenta",
                    settingColorAccent2: "</style>",
                    settingThemeNavbar: "primary",
                    settingThemeBase: "unknown",
                    settingThemeRadius: "1.5",
                    settingThemeFont: "comic"
                });
                local.saved = readSettings();

                expect(local.saved.settingThemePrimary).toBe("green");
                expect(local.saved.settingColorPrimary).toBe("##206bc4");
                expect(local.saved.settingThemeAccent).toBe("custom");
                expect(local.saved.settingColorAccent).toBe("##ae3ec9");
                expect(local.saved.settingThemeAccent2).toBe("none");
                expect(local.saved.settingColorAccent2).toBe("##0ca678");
                expect(local.saved.settingThemeNavbar).toBe("primary");
                expect(local.saved.settingThemeBase).toBe("neutral");
                expect(local.saved.settingThemeRadius).toBe("1.5");
                expect(local.saved.settingThemeFont).toBe("sans-serif");
            });

            it("replace the removed secondary color", () => {
                local.rows = queryExecute(
                    options = {datasource: application.datasource},
                    sql = "SELECT COUNT(*) AS cnt FROM system_settings WHERE strSettingVariable = 'settingColorSecondary'"
                );
                expect(local.rows.cnt).toBe(0);
                expect(listLen(structKeyList(variables.savedSettings))).toBe(listLen(variables.themeSettings));
            });

            it("put a Tabler color preset on the html element of backend pages", () => {
                application.themeStruct = application.objTheme.themeSetting({
                    settingThemePrimary: "teal", settingThemeNavbar: "primary", settingThemeBase: "slate",
                    settingThemeRadius: "0.5", settingThemeFont: "serif"
                });
                local.page = renderPage("dashboard", createOwner().userID);
                local.html = reMatch("<html[^>]*>", local.page.fileContent);

                expect(local.page.statusCode).toInclude("200", left(local.page.fileContent, 500));
                expect(local.html).notToBeEmpty();
                expect(local.html[1]).toInclude('data-bs-theme-primary="teal"');
                expect(local.html[1]).toInclude('data-bs-theme-base="slate"');
                expect(local.html[1]).toInclude('data-bs-theme-radius="0.5"');
                expect(local.html[1]).toInclude('data-bs-theme-font="serif"');
                expect(local.html[1]).toInclude('data-bs-navbar-theme="primary"');
                expect(local.page.fileContent).toInclude("/dist/css/tabler-themes.min.css");
                expect(local.page.fileContent).notToInclude("--tblr-primary:");
                expect(local.page.fileContent).notToInclude("color.cfm");
            });

            it("set a custom primary color with readable text", () => {
                application.themeStruct = application.objTheme.themeSetting({
                    settingThemePrimary: "custom", settingColorPrimary: "##F59F00"
                });
                local.page = renderPage("dashboard", createOwner().userID);
                local.html = reMatch("<html[^>]*>", local.page.fileContent);

                expect(local.page.statusCode).toInclude("200", left(local.page.fileContent, 500));
                expect(local.html[1]).notToInclude("data-bs-theme-primary");
                expect(local.page.fileContent).toInclude("--tblr-primary: ##f59f00;");
                expect(local.page.fileContent).toInclude("--tblr-primary-rgb: 245, 159, 0;");
                expect(local.page.fileContent).toInclude("--tblr-primary-fg: var(--tblr-dark);");
            });

            it("put the accent colors on backend pages and the account settings tiles", () => {
                application.themeStruct = application.objTheme.themeSetting({
                    settingThemeAccent: "pink", settingThemeAccent2: "custom", settingColorAccent2: "##0CA678"
                });
                local.page = renderPage("account-settings", createOwner().userID);
                local.html = reMatch("<html[^>]*>", local.page.fileContent);

                expect(local.page.statusCode).toInclude("200", left(local.page.fileContent, 500));
                expect(local.html[1]).toInclude("data-saaster-accent");
                expect(local.page.fileContent).toInclude("--saaster-accent: var(--tblr-pink);");
                expect(local.page.fileContent).toInclude("--saaster-accent-2: ##0ca678;");
                expect(local.page.fileContent).toInclude('class="avatar avatar-sm bg-accent-lt flex-shrink-0"');
            });

            it("are shown with their saved values to the sysadmin", () => {
                writeSetting("settingThemePrimary", "custom");
                writeSetting("settingColorPrimary", "##1f8a70");
                writeSetting("settingThemeRadius", "2");
                writeSetting("settingThemeAccent", "orange");
                writeSetting("settingThemeAccent2", "none");
                local.sysadmin = variables.fixtures.createUser(
                    customerID=variables.fixtures.createCustomer(), sysAdmin=true, superAdmin=true
                );
                local.page = renderPage("sysadmin/system-settings", local.sysadmin.userID);

                expect(local.page.statusCode).toInclude("200", left(local.page.fileContent, 500));
                expect(reFind('id="theme-primary-custom"[^>]*checked', local.page.fileContent)).toBeGT(0, "Custom color selected");
                expect(local.page.fileContent).toInclude('name="settingColorPrimary" value="##1f8a70"');
                expect(local.page.fileContent).toInclude('<option value="2" selected>');
                expect(local.page.fileContent).toInclude('class="form-colorinput-color bg-teal"');
                expect(reFind('name="settingThemeAccent" type="radio" value="orange"[^>]*checked', local.page.fileContent)).toBeGT(0, "Accent color selected");
                expect(reFind('name="settingThemeAccent2" type="radio" value="none"[^>]*checked', local.page.fileContent)).toBeGT(0, "No second accent color");
                expect(local.page.fileContent).toInclude('name="settingColorAccent2" value="##0ca678"');
                expect(local.page.fileContent).notToInclude("settingColorSecondary");
            });

        });

    }

    private struct function createOwner() {
        return variables.fixtures.createUser(customerID=variables.fixtures.createCustomer(), superAdmin=true);
    }

    private struct function readSettings() {
        local.rows = queryExecute(
            options = {datasource: application.datasource},
            params = {
                settings: {type: "varchar", value: variables.themeSettings, list: true}
            },
            sql = "SELECT strSettingVariable, strDefaultValue FROM system_settings WHERE strSettingVariable IN (:settings)"
        );
        local.result = {};
        loop query="local.rows" {
            local.result[local.rows.strSettingVariable] = local.rows.strDefaultValue;
        }
        return local.result;
    }

    private void function writeSetting(required string setting, required string value) {
        queryExecute(
            options = {datasource: application.datasource},
            params = {
                value: {type: "varchar", value: arguments.value},
                setting: {type: "varchar", value: arguments.setting}
            },
            sql = "UPDATE system_settings SET strDefaultValue = :value WHERE strSettingVariable = :setting"
        );
    }

    private struct function renderPage(required string route, required numeric userID) {
        cfhttp(
            url = "http://127.0.0.1/tests/support/organization_flow_probe.cfm?route="
                & urlEncodedFormat(arguments.route) & "&language=en&userID=" & arguments.userID,
            result = "local.response", redirect = false, timeout = 40
        );
        return local.response;
    }

}
