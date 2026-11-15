<cfsetting showdebugoutput="false">
<cfscript>
if (application.environment neq "dev" or not findNoCase("test", application.datasource)) {
    header statuscode=403;
    abort;
}
probeExisting = queryExecute(options={datasource:application.datasource},
    params={email:{type:"varchar",value:"borg-recovery@saaster.invalid"}},
    sql="SELECT intUserID FROM users WHERE strEmail=:email");
if ((url.action ?: "") eq "seed" and not probeExisting.recordCount) {
    probeFixtures = new tests.support.fixtures();
    probeCustomer = probeFixtures.createCustomer(companyName="Borg recovery fixture");
    probeFixtures.createUser(
        customerID=probeCustomer,
        email="borg-recovery@saaster.invalid",
        admin=true,
        passwordHash=application.objGlobal.hashPassword("Borg isolated recovery 2026!")
    );
}
probeLogin = new frontend.core.com.login().checkLogin(
    email="borg-recovery@saaster.invalid",
    password="Borg isolated recovery 2026!"
);
content type="application/json";
writeOutput(serializeJSON({
    ok: probeLogin.loginCorrect,
    customerID: probeLogin.customer_id ?: 0,
    database: queryExecute(options={datasource:application.datasource}, sql="SELECT DATABASE() AS db").db,
    company: queryExecute(
        options={datasource:application.datasource},
        params={email:{type:"varchar",value:"borg-recovery@saaster.invalid"}},
        sql="SELECT c.strCompanyName FROM customers c INNER JOIN customer_user cu ON cu.intCustomerID=c.intCustomerID INNER JOIN users u ON u.intUserID=cu.intUserID WHERE u.strEmail=:email"
    ).strCompanyName
}));
</cfscript>
