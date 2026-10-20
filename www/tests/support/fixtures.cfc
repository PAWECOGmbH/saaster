component output="false" hint="Creates test data and removes it again." {

    /*
        Why the fixtures write their rows with plain SQL instead of going through
        application.objCustomer and friends: otherwise every test depends on
        exactly that function working, even when it is not what the test checks.
        A bug in insertUser would turn dozens of specs red that only use users
        as a backdrop.

        The exception is the subject under test itself: a spec for insertUser
        obviously calls insertUser.
    */

    // .invalid is reserved by RFC 2606 and never deliverable. Even if a test
    // accidentally triggers a mail, it cannot reach a real person. At the same
    // time the domain marks test data that was left behind.
    variables.emailDomain = "@saaster.invalid";

    public any function init() {
        variables.createdCustomerIds = [];
        return this;
    }

    public string function marker() {
        return variables.emailDomain;
    }

    public string function uniqueEmail(string prefix = "testbox") {
        return arguments.prefix & "-" & lCase(replace(createUUID(), "-", "", "all")) & variables.emailDomain;
    }

    /*
        A customer (tenant). parentID > 0 makes it a sub-tenant of another customer.
        Deleting the customer later cascades to users, customer_user, invoices
        and everything else hanging on it (ON DELETE CASCADE in the schema).
    */
    public numeric function createCustomer(
        string companyName = "TestBox Company",
        string contactPerson = "TestBox Contact",
        numeric parentID = 0,
        boolean active = true
    ) {
        queryExecute(
            "INSERT INTO customers (intCustParentID, dtmInsertDate, dtmMutDate, blnActive, strCompanyName, strContactPerson, strEmail)
             VALUES (:parentID, UTC_TIMESTAMP(), UTC_TIMESTAMP(), :active, :companyName, :contactPerson, :email)",
            {
                parentID: { type: "numeric", value: arguments.parentID },
                active: { type: "bit", value: arguments.active },
                companyName: { type: "varchar", value: arguments.companyName },
                contactPerson: { type: "varchar", value: arguments.contactPerson },
                email: { type: "varchar", value: uniqueEmail("customer") }
            },
            { datasource: application.datasource, result: "local.insertResult" }
        );

        var customerID = local.insertResult.generatedKey;
        arrayAppend(variables.createdCustomerIds, customerID);

        return customerID;
    }

    /*
        A user who belongs to a customer, including the customer_user link that
        Saaster uses for tenant access (blnStandard = 1 marks the main tenant).
        Returns a struct that loginAs() in integration_spec.cfc understands.
    */
    public struct function createUser(
        required numeric customerID,
        string firstName = "TestBox",
        string lastName = "User",
        string email = "",
        string language = "en",
        boolean active = true,
        boolean admin = false,
        boolean superAdmin = false,
        boolean sysAdmin = false,
        string passwordHash = "",
        string passwordSalt = ""
    ) {
        var userEmail = len(trim(arguments.email)) ? trim(arguments.email) : uniqueEmail("user");

        queryExecute(
            "INSERT INTO users (intCustomerID, dtmInsertDate, dtmMutDate, strFirstName, strLastName, strEmail, strLanguage,
                                blnActive, blnAdmin, blnSuperAdmin, blnSysAdmin, strUUID, strPasswordHash, strPasswordSalt)
             VALUES (:customerID, UTC_TIMESTAMP(), UTC_TIMESTAMP(), :firstName, :lastName, :email, :language,
                     :active, :admin, :superAdmin, :sysAdmin, :uuid, :passwordHash, :passwordSalt)",
            {
                customerID: { type: "numeric", value: arguments.customerID },
                firstName: { type: "varchar", value: arguments.firstName },
                lastName: { type: "varchar", value: arguments.lastName },
                email: { type: "varchar", value: userEmail },
                language: { type: "varchar", value: arguments.language },
                active: { type: "bit", value: arguments.active },
                admin: { type: "bit", value: arguments.admin or arguments.superAdmin },
                superAdmin: { type: "bit", value: arguments.superAdmin },
                sysAdmin: { type: "bit", value: arguments.sysAdmin },
                uuid: { type: "varchar", value: createUUID() },
                passwordHash: { type: "varchar", value: arguments.passwordHash },
                passwordSalt: { type: "varchar", value: arguments.passwordSalt }
            },
            { datasource: application.datasource, result: "local.insertResult" }
        );

        // The trigger insertConnect on users already links the user to its customer as standard tenant.
        var userID = local.insertResult.generatedKey;

        return {
            "userID": userID,
            "customerID": arguments.customerID,
            "firstName": arguments.firstName,
            "lastName": arguments.lastName,
            "email": userEmail,
            "language": arguments.language,
            "admin": arguments.admin or arguments.superAdmin,
            "superAdmin": arguments.superAdmin,
            "sysAdmin": arguments.sysAdmin
        };
    }

    /*
        A booking of a customer. Empty dates are stored as SQL NULL.

        Plan and module stay NULL by default: both columns have foreign keys, and
        the test database has no plans or modules unless a spec creates them.
        Pass IDs only for rows that exist.
    */
    public numeric function createBooking(
        required numeric customerID,
        any planID = "",
        any moduleID = "",
        string startDate = "",
        string endDate = "",
        string recurring = "monthly",
        string status = "payment"
    ) {
        queryExecute(
            "INSERT INTO bookings (intCustomerID, intPlanID, intModuleID, dteStartDate, dteEndDate, strRecurring, strStatus)
             VALUES (:customerID, :planID, :moduleID, :startDate, :endDate, :recurring, :status)",
            {
                customerID: { type: "numeric", value: arguments.customerID },
                planID: { type: "numeric", value: val(arguments.planID), null: not isNumeric(arguments.planID) },
                moduleID: { type: "numeric", value: val(arguments.moduleID), null: not isNumeric(arguments.moduleID) },
                startDate: { type: "date", value: arguments.startDate, null: not isDate(arguments.startDate) },
                endDate: { type: "date", value: arguments.endDate, null: not isDate(arguments.endDate) },
                recurring: { type: "varchar", value: arguments.recurring },
                status: { type: "varchar", value: arguments.status }
            },
            { datasource: application.datasource, result: "local.insertResult" }
        );

        return local.insertResult.generatedKey;
    }

    // Gives a user access to an additional tenant.
    public void function grantTenant(required numeric userID, required numeric customerID, boolean standard = false) {
        queryExecute(
            "INSERT INTO customer_user (intCustomerID, intUserID, blnStandard) VALUES (:customerID, :userID, :standard)",
            {
                customerID: { type: "numeric", value: arguments.customerID },
                userID: { type: "numeric", value: arguments.userID },
                standard: { type: "bit", value: arguments.standard }
            },
            { datasource: application.datasource }
        );
    }

    // Removes everything this instance created. Children first, in case a
    // sub-tenant points to a parent created in the same run.
    public void function cleanup() {
        for (var index = arrayLen(variables.createdCustomerIds); index gte 1; index--) {
            queryExecute(
                "DELETE FROM customers WHERE intCustomerID = :customerID",
                { customerID: { type: "numeric", value: variables.createdCustomerIds[index] } },
                { datasource: application.datasource }
            );
        }

        variables.createdCustomerIds = [];
    }

    // Removes data a crashed run left behind, recognisable by the marker domain.
    public void function removeOrphans() {
        queryExecute(
            "DELETE FROM customers WHERE strEmail LIKE :marker",
            { marker: { type: "varchar", value: "%" & variables.emailDomain } },
            { datasource: application.datasource }
        );
    }

}
