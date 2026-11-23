component extends="tests.support.integration_spec" {
    function run() {
        describe("Swiss QR settings", () => {
            beforeEach(() => {
                variables.original = {};
                variables.baseline = {
                    settingSwissQrBill: "0", settingIBANnumber: "CH5800791123000889012",
                    settingQRreference: "RF18539007547034", settingRoundFactor: "1", settingInvoicePrefix: "QR"
                };
                loop collection=variables.baseline item="local.setting" {
                    variables.original[local.setting] = savedValue(local.setting);
                }
                writeSettings(variables.baseline);
                local.admin = variables.fixtures.createUser(customerID=variables.fixtures.createCustomer(), sysAdmin=true, superAdmin=true);
                variables.auth = authenticate(local.admin.userID);
            });

            afterEach(() => {
                writeSettings(variables.original);
            });

            it("keeps settings intact and renders the QR error and submitted values", () => {
                local.result = submit({
                    settingSwissQrBill: "1", settingRoundFactor: "5", settingInvoicePrefix: "OTHER",
                    settingIBANnumber: "CH4431999123000889012", settingQRreference: "RF18539007547034"
                });
                expect(local.result.statusCode).toInclude("302");
                expect(local.result.responseHeader.Location).notToInclude("reinit");
                loop collection=variables.baseline item="local.setting" {
                    expect(savedValue(local.setting)).toBe(variables.baseline[local.setting]);
                }
                cfhttp(url=probeURL("sysadmin/system-settings"), result="local.page", redirect=false) {
                    cfhttpparam(type="header", name="Cookie", value=variables.auth.cookies);
                }
                expect(local.page.statusCode).toInclude("200");
                expect(local.page.fileContent).toInclude('data-qr-validation-error="true"');
                expect(local.page.fileContent).toInclude("A QR-IBAN requires a numeric QR reference");
                expect(local.page.fileContent).toInclude('value="CH4431999123000889012"');
                expect(local.page.fileContent).toInclude('value="RF18539007547034"');
                expect(local.page.fileContent).notToInclude('##encodeForHTMLAttribute');
            });

            it("rejects incorrect IBAN and RF check digits on save", () => {
                local.badIBAN = submit({settingIBANnumber: "CH5900791123000889012"});
                expect(local.badIBAN.statusCode).toInclude("302");
                expect(local.badIBAN.responseHeader.Location).notToInclude("reinit");
                expect(savedValue("settingIBANnumber")).toBe(variables.baseline.settingIBANnumber);

                local.badReference = submit({settingQRreference: "RF19539007547034"});
                expect(local.badReference.statusCode).toInclude("302");
                expect(local.badReference.responseHeader.Location).notToInclude("reinit");
                expect(savedValue("settingQRreference")).toBe(variables.baseline.settingQRreference);
            });

            it("accepts a valid QR pair and allows an ordinary IBAN without a reference", () => {
                local.result = submit({
                    settingSwissQrBill: "1", settingRoundFactor: "5", settingIBANnumber: "CH4431999123000889012",
                    settingQRreference: "21 00000 00003 13947 14300 09017"
                });
                expect(local.result.statusCode).toInclude("302");
                expect(local.result.responseHeader.Location).toInclude("reinit=1");
                expect(savedValue("settingSwissQrBill")).toBe("1");
                expect(savedValue("settingQRreference")).toBe("21 00000 00003 13947 14300 09017");

                local.result = submit({settingIBANnumber: "CH5800791123000889012", settingQRreference: ""});
                expect(local.result.responseHeader.Location).toInclude("reinit=1");
                expect(savedValue("settingIBANnumber")).toBe("CH5800791123000889012");
                expect(savedValue("settingQRreference")).toBe("");
            });
        });
    }

    private string function probeURL(required string route) {
        return "http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=" & arguments.route;
    }

    private struct function authenticate(required numeric userID) {
        cfhttp(url=probeURL("sysadmin/system-settings") & "&userID=" & arguments.userID, result="local.page", redirect=false);
        expect(local.page.statusCode).toInclude("200");
        local.headers = local.page.responseHeader["Set-Cookie"];
        if (!isArray(local.headers)) local.headers = [local.headers];
        local.auth = {cookies: arrayToList(arrayMap(local.headers, (cookieHeader) => listFirst(cookieHeader, ";")), "; ")};
        loop list="csrf_token,context_token" item="local.name" {
            local.match = reFind('name="' & local.name & '" value="([^"]*)"', local.page.fileContent, 1, true);
            expect(local.match.len[1]).toBeGT(0);
            local.auth[local.name] = mid(local.page.fileContent, local.match.pos[2], local.match.len[2]);
        }
        return local.auth;
    }

    private struct function submit(required struct fields) {
        cfhttp(url=probeURL("sysadm/settings"), method="POST", result="local.response", redirect=false) {
            cfhttpparam(type="header", name="Cookie", value=variables.auth.cookies);
            cfhttpparam(type="formfield", name="edit_sysadmin_settings", value="1");
            cfhttpparam(type="formfield", name="csrf_token", value=variables.auth.csrf_token);
            cfhttpparam(type="formfield", name="context_token", value=variables.auth.context_token);
            loop collection=arguments.fields item="local.field" {
                cfhttpparam(type="formfield", name=local.field, value=arguments.fields[local.field]);
            }
        }
        return local.response;
    }

    private string function savedValue(required string setting) {
        return application.objSysadmin.getSystemSetting(arguments.setting).strDefaultValue;
    }

    private void function writeSettings(required struct settings) {
        loop collection=arguments.settings item="local.setting" {
            queryExecute(
                options = {datasource: application.datasource},
                params = {
                    setting: {type: "varchar", value: local.setting},
                    value: {type: "varchar", value: arguments.settings[local.setting]}
                },
                sql = "UPDATE system_settings SET strDefaultValue = :value WHERE strSettingVariable = :setting"
            );
        }
    }
}
