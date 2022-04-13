<cfscript>
    // Exception handling for sef and customer id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisCustomerID = thiscontent.thisID;

    if(not isNumeric(thisCustomerID) or thisCustomerID lte 0) {
        location url="#application.mainURL#/sysadmin/customers" addtoken="false";
    }

    qCustomer = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT customers.*, countries.strCountryName
            FROM customers
            LEFT JOIN countries ON countries.intCountryID = customers.intCountryID
            WHERE customers.blnActive = 1
            AND customers.intCustomerID = #thisCustomerID#;
        "
    )

    qUsers = application.objUser.getAllUsers(thisCustomerID);
</cfscript>

<cfinclude template="/includes/header.cfm">

<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">Sysadmin</li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/customers">Customers</a></li>
                            <li class="breadcrumb-item active">#qCustomer.strCompanyName#</li>
                        </ol>
                    </div>
                    <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="#application.mainURL#/sysadmin/customers/edit/#qCustomer.intCustomerID#" class="btn btn-primary">
                            <i class="fas fa-edit pe-3"></i> Edit
                        </a>
                    </div>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card d-flex flex-row">
                        <div class="card-body">
                            <div class="d-flex">
                                <cfif len(trim(qCustomer.strLogo))>
                                    <div>
                                        <img src="#application.mainURL#/userdata/images/logos/#qCustomer.strLogo#" style="margin-right:20px" class="avatar avatar-xl mr-3 align-self-center" alt="#qCustomer.strCompanyName#">
                                    </div>
                                <cfelse>
                                    <div style="margin-right:20px" class="avatar avatar-xl mr-3 align-self-center">
                                        #left(qCustomer.strCompanyName,2)#
                                    </div>
                                </cfif>
                                <div class="align-self-center">
                                    <h2>#qCustomer.strCompanyName#</h2>
                                </div>
                            </div>
                            <div class="d-flex pt-4">
                                <div class="me-5 text-muted">
                                    Address
                                </div>
                                <div class="d-flex flex-column ps-3 pe-5">
                                    <div>
                                        #qCustomer.strAddress#
                                    </div>
                                    <div>
                                        #qCustomer.strZIP# #qCustomer.strCity#
                                    </div>
                                    <div>
                                        #qCustomer.strCountryName#
                                    </div>
                                </div>
                                <div class="me-5 flex-column text-muted ps-3">
                                    <div>
                                    Contact person
                                    </div>
                                    <div>
                                    E-Mail
                                    </div>
                                    <div>
                                    Phone
                                    </div>
                                </div>
                                <div class="d-flex flex-column ps-3">
                                    <div>
                                        #qCustomer.strContactPerson#
                                    </div>
                                    <div>
                                        #qCustomer.strEmail#
                                    </div>
                                    <div>
                                        #qCustomer.strPhone#
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <h2 class="pt-3 ps-3">Users</h2>
                            <cfloop query="qUsers">
                                <div class="list-group list-group-flush">
                                    <div class="list-group-item">
                                        <div class="row align-items-center">
                                            <div class="col text-truncate">
                                                <a href="" class="text-reset d-block">#qUsers.strFirstName# #strLastName#</a>
                                                #qUsers.strEmail#
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </cfloop>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>
