
component displayname="sysadmin" output="false" {

    public struct function getSysAdminData() {

        local.sysadminStruct = structNew();

        local.qCustomer = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT customers.*
                FROM users
                INNER JOIN customers ON users.intCustomerID = customers.intCustomerID
                WHERE users.blnSysAdmin = 1
            "
        )

        local.customerStruct['customerID'] = local.qCustomer.intCustomerID;
        local.customerStruct['companyName'] = local.qCustomer.strCompanyName;
        local.customerStruct['contactPerson'] = local.qCustomer.strContactPerson;
        local.customerStruct['address'] = local.qCustomer.strAddress;
        local.customerStruct['address2'] = local.qCustomer.strAddress2;
        local.customerStruct['zip'] = local.qCustomer.strZIP;
        local.customerStruct['city'] = local.qCustomer.strCity;
        local.customerStruct['countryID'] = local.qCustomer.intCountryID;
        local.customerStruct['timezoneID'] = local.qCustomer.intTimezoneID;
        local.customerStruct['phone'] = local.qCustomer.strPhone;
        local.customerStruct['email'] = local.qCustomer.strEmail;
        local.customerStruct['website'] = local.qCustomer.strWebsite;
        local.customerStruct['logo'] = local.qCustomer.strLogo;
        local.customerStruct['billingAccountName'] = local.qCustomer.strBillingAccountName;
        local.customerStruct['billingEmail'] = local.qCustomer.strBillingEmail;
        local.customerStruct['billingAddress'] = local.qCustomer.strBillingAddress;
        local.customerStruct['billingInfo'] = local.qCustomer.strBillingInfo;

        return local.customerStruct;

    }

}