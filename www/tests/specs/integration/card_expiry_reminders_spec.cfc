component extends="tests.support.integration_spec" {
    function run() {
        describe("Saved card expiry reminders", () => {
            beforeEach(() => {
                logout();
                recordLogs();
                variables.customerID = variables.fixtures.createCustomer();
                variables.owner = variables.fixtures.createUser(customerID=variables.customerID, superAdmin=true);
                variables.planID = variables.fixtures.createPlan();
                variables.fixtures.createBooking(customerID=variables.customerID, planID=variables.planID,
                    status="active", recurring="monthly");
                variables.transactionID = randRange(1000000, 2000000000);
                queryExecute(
                    options = {datasource:application.datasource,result:"local.insertResult"},
                    params = {customerID:{type:"integer",value:variables.customerID},
                        transactionID:{type:"bigint",value:variables.transactionID}},
                    sql = "INSERT INTO payrexx (intCustomerID,dtmTimeUTC,intTransactionID,strStatus,
                        strPaymentBrand,blnDefault,blnFailed)
                        VALUES (:customerID,UTC_TIMESTAMP(),:transactionID,'authorized','visa',1,0)"
                );
                variables.paymentID = local.insertResult.generatedKey;
                variables.originalPayrexx = duplicate(application.payrexxStruct);
                application.payrexxStruct = {
                    payrexxAPIurl:"http://127.0.0.1/tests/support/payrexx_checkout_mock.cfm?route=/",
                    payrexxAPIinstance:"regression",payrexxAPIkey:"test-key"
                };
                application.checkoutMock = {gateway:123,events:[],calls:[]};
                setExpiry("2027-06");
                variables.reminders = new backend.core.com.card_expiry_reminders();
            });
            afterEach(() => {
                application.payrexxStruct = variables.originalPayrexx;
                structDelete(application,"checkoutMock");
            });
            it("sends one month notice and one week notice only once each", () => {
                expect(variables.reminders.run(createDate(2027,6,1)).sent).toBe(1, serializeJSON(variables.logRecorder.getCalls()));
                expect(notices()).toBe(1);
                if (len(request.testSettings.mailCatcherUrl ?: "")) {
                    local.message = waitForMail("Your saved card expires soon");
                    expect(local.message).toInclude("/account-settings/payment");
                    expect(local.message).toInclude("06/2027");
                    expect(local.message).toInclude("Hello TestBox Contact");
                    local.plain = waitForMail("Your saved card expires soon", "text");
                    expect(local.plain).toInclude("Hello TestBox Contact");
                    expect(local.plain).toInclude("Update payment method (" & application.mainURL & "/account-settings/payment)");
                    expect(local.plain).toInclude("Contact");
                    expect(local.plain).notToInclude("<p>");
                    expect(local.message).toInclude("Contact");
                    expect(reFind('bgcolor="' & chr(35) & '[0-9A-Fa-f]{6}" style="background-color: '
                        & chr(35) & '[0-9A-Fa-f]{6};"',local.message) gt 0).toBeTrue();
                    local.wrapperWidths = reMatch('width="[0-9]+" class="wrapper"',local.message);
                    expect(arrayLen(local.wrapperWidths)).toBe(2);
                    expect(local.wrapperWidths[2]).toBe(local.wrapperWidths[1]);
                }
                expect(variables.reminders.run(createDate(2027,6,1)).sent).toBe(0);
                allowRefresh();
                expect(variables.reminders.run(createDate(2027,6,25)).sent).toBe(1);
                expect(notices()).toBe(2);
                allowRefresh();
                expect(variables.reminders.run(createDate(2027,6,25)).sent).toBe(0);
                expect(notices()).toBe(2);
            });
            it("uses the recipient language for the shared mail signoff", () => {
                queryExecute(
                    options={datasource:application.datasource},
                    params={id:{type:"integer",value:variables.owner.userID}},
                    sql="UPDATE users SET strLanguage='de' WHERE intUserID=:id"
                );
                expect(variables.reminders.run(createDate(2027,6,1)).sent).toBe(1);
                if (len(request.testSettings.mailCatcherUrl ?: "")) {
                    local.message = waitForMail("Ihre hinterlegte Karte läuft bald ab");
                    expect(local.message).toInclude("Guten Tag TestBox Contact");
                    expect(local.message).toInclude("Mit freundlichem Gruss");
                    expect(local.message).toInclude("Ihr Team vom Kundendienst");
                    expect(local.message).toInclude(encodeForHTML(application.appOwner));
                    expect(arrayLen(reMatch("Mit freundlichem Gruss",local.message))).toBe(1);
                }
            });
            it("addresses a billing recipient by the matching user name", () => {
                queryExecute(
                    options={datasource:application.datasource},
                    params={id:{type:"integer",value:variables.customerID},
                        email:{type:"varchar",value:variables.owner.email}},
                    sql="UPDATE customers SET strBillingEmail=:email WHERE intCustomerID=:id"
                );
                expect(variables.reminders.run(createDate(2027,6,1)).sent).toBe(1);
                if (len(request.testSettings.mailCatcherUrl ?: "")) {
                    local.message = waitForMail("Your saved card expires soon");
                    expect(local.message).toInclude("Hello TestBox User");
                    expect(local.message).notToInclude("Hello TestBox Contact");
                }
            });
            it("uses a general greeting for an unrelated billing address", () => {
                queryExecute(
                    options={datasource:application.datasource},
                    params={id:{type:"integer",value:variables.customerID},
                        email:{type:"varchar",value:"billing-" & createUUID() & "@saaster.invalid"}},
                    sql="UPDATE customers SET strBillingEmail=:email WHERE intCustomerID=:id"
                );
                expect(variables.reminders.run(createDate(2027,6,1)).sent).toBe(1);
                if (len(request.testSettings.mailCatcherUrl ?: "")) {
                    local.message = waitForMail("Your saved card expires soon");
                    expect(local.message).toInclude("<p>Hello</p>");
                    expect(local.message).notToInclude("TestBox Contact");
                    expect(local.message).notToInclude("TestBox User");
                }
            });
            it("uses the current Payrexx expiry and suppresses reminders after renewal", () => {
                setExpiry("27-12");
                expect(variables.reminders.run(createDate(2027,6,1)).sent).toBe(0);
                expect(notices()).toBe(0);
                expect(queryExecute(options={datasource:application.datasource},
                    params={id:{type:"integer",value:variables.paymentID}},
                    sql="SELECT strCardExpiry FROM payrexx WHERE intPayrexxID=:id").strCardExpiry).toBe("27-12");
            });
            it("does not remind an old card after the customer selects another default", () => {
                queryExecute(options={datasource:application.datasource},
                    params={id:{type:"integer",value:variables.paymentID}},
                    sql="UPDATE payrexx SET blnDefault=0 WHERE intPayrexxID=:id");
                expect(variables.reminders.run(createDate(2027,6,1)).sent).toBe(0);
                expect(notices()).toBe(0);
            });
            it("does not mail when Payrexx has no valid card expiry", () => {
                setExpiry("");
                expect(variables.reminders.run(createDate(2027,6,1)).sent).toBe(0);
                expect(notices()).toBe(0);
            });
        });
    }
    private string function waitForMail(required string subject, string part = "html") {
        local.email = new backend.core.com.invoices().getInvoiceEmail(customerID=variables.customerID);
        local.mailbox = lCase(listFirst(local.email,"@"));
        loop from=1 to=20 index="local.attempt" {
            cfhttp(url=request.testSettings.mailCatcherUrl & "/api/v1/mailbox/" & local.mailbox,
                method="get",timeout=10,result="local.list");
            if (isJSON(local.list.fileContent)) {
                loop array=deserializeJSON(local.list.fileContent) item="local.entry" {
                    if (local.entry.subject eq arguments.subject) {
                        cfhttp(url=request.testSettings.mailCatcherUrl & "/api/v1/mailbox/" & local.mailbox & "/" & local.entry.id,
                            method="get",timeout=10,result="local.message");
                        local.mail = deserializeJSON(local.message.fileContent);
                        expect(arrayToList(local.mail.header["Content-Type"])).toInclude("multipart/alternative");
                        return local.mail.body[arguments.part] ?: "";
                    }
                }
            }
            sleep(500);
        }
        fail("The card expiry email did not arrive in Inbucket.");
        return "";
    }
    private void function setExpiry(required string expiry) {
        application.checkoutMock.events = [{id:variables.transactionID,status:"authorized",
            payment:{brand:"visa",expiry:arguments.expiry}}];
    }
    private void function allowRefresh() {
        queryExecute(options={datasource:application.datasource},
            params={id:{type:"integer",value:variables.paymentID}},
            sql="UPDATE payrexx SET dtmExpiryCheckedAt=NULL WHERE intPayrexxID=:id");
    }
    private numeric function notices() {
        return queryExecute(options={datasource:application.datasource},
            params={id:{type:"integer",value:variables.paymentID}},
            sql="SELECT intCardExpiryReminderID FROM card_expiry_reminders WHERE intPayrexxID=:id").recordCount;
    }
}
