<cfscript>
    // Exception handling for sef and customer id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisCustomerID = thiscontent.thisID;

    if(not isNumeric(thisCustomerID) or thisCustomerID lte 0) {
        location url="#application.mainURL#/sysadmin/customers" addtoken="false";
    }

    qCustomer = application.objCustomer.getCustomerData(thisCustomerID);
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
                                    <div class="avatar avatar-xl me-3 align-self-center">
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
                            <h2 class="mt-4">Users</h2>
                            <div class="table-responsive">
                                <table
                                      class="table table-vcenter">
                                  <thead>
                                    <tr>
                                      <th>Salutation</th>
                                      <th>Prename</th>
                                      <th>Lastname</th>
                                      <th>Mail</th>
                                      <th class="w-1"></th>
                                    </tr>
                                  </thead>
                                  <tbody>
                                    <cfset counter = 1>
                                    <cfloop query="qUsers">
                                        <form id="user_form_#counter#" method="post" action="#application.mainURL#/sysadm/customers">
                                            <input type="hidden" name="edit_user" value="">
                                            <input type="hidden" name="user_id" value="#qUsers.intUserID#">
                                            <input type="hidden" name="customer_id" value="#thisCustomerID#">
                                            <input type="hidden" name="phone" value="#qUsers.strPhone#">
                                            <input type="hidden" name="mobile" value="#qUsers.strMobile#">
                                            <input type="hidden" name="language" value="#qUsers.strLanguage#">
                                            <input type="hidden" name="admin" value="#qUsers.blnAdmin#">
                                            <input type="hidden" name="active" value="#qUsers.blnActive#">
                                            <tr>
                                                <td>
                                                    <input class="form-control" name="salutation" value="#qUsers.strSalutation#">
                                                </td>
                                                <td>
                                                    <input class="form-control" name="first_name" value="#qUsers.strFirstName#">
                                                </td>
                                                <td>
                                                    <input class="form-control" name="last_name" value="#qUsers.strLastName#">
                                                </td>
                                                <td>
                                                    <input class="form-control" name="email" value="#qUsers.strEmail#">
                                                </td>
                                                <td>
                                                    <button type="submit" id="submit_button" class="btn btn-primary">Save</button>
                                                </td>
                                            </tr>
                                        </form>
                                        <cfset counter++>
                                    </cfloop>
                                  </tbody>
                                </table>
                              </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>
