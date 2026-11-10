<cfscript>

    // Exception handling for sef and customer id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisCustomerID = thiscontent.thisID;

    if (not isNumeric(thisCustomerID) or thisCustomerID lte 0) {
        location url="#application.mainURL#/sysadmin/customers" addtoken="false";
    }

    getCustomer = application.objCustomer.getCustomerData(thisCustomerID);
    qUsers = application.objUser.getAllUsers(thisCustomerID);

    if (!isStruct(getCustomer) or structIsEmpty(getCustomer)) {
        location url="#application.mainURL#/sysadmin/customers" addtoken="false";
    }

</cfscript>


<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">Sysadmin</li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/customers">Customers</a></li>
                            <li class="breadcrumb-item active">
                                <cfif len(trim(getCustomer.companyName))>
                                    #encodeForHTML(getCustomer.companyName)#
                                <cfelse>
                                    #encodeForHTML(getCustomer.contactPerson)# (Private)
                                </cfif>
                            </li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <div class="btn-list flex-nowrap justify-content-end">
                            <a href="#application.mainURL#/sysadmin/customers/edit/#getCustomer.customerID#" class="btn btn-primary">
                                <i class="ti ti-edit pe-3"></i> Edit
                            </a>
                            <div class="dropdown">
                                <button type="button" class="btn dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">Action</button>
                                <div class="dropdown-menu dropdown-menu-end">
                                    <button type="button" class="dropdown-item text-danger" data-bs-toggle="modal" data-bs-target="##delete-customer">Delete account</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <cfinclude template="account_deletion_status.cfm">
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card d-flex flex-row">
                        <div class="card-body">
                            <div class="d-flex">
                                <cfif len(trim(getCustomer.logo))>
                                    <div>
                                        <img src="#application.mainURL#/userdata/images/logos/#getCustomer.logo#" style="margin-right:20px" class="avatar avatar-xl mr-3 align-self-center" alt="#encodeForHTML(getCustomer.companyName)#">
                                    </div>
                                <cfelse>
                                    <cfif len(trim(getCustomer.companyName))>
                                        <div class="avatar avatar-xl me-3 align-self-center">
                                            #encodeForHTML(left(getCustomer.companyName,2))#
                                        </div>
                                    <cfelse>
                                        <div class="avatar avatar-xl me-3 align-self-center">
                                            #encodeForHTML(left(getCustomer.contactPerson,2))#
                                        </div>
                                    </cfif>
                                </cfif>
                                <cfif len(trim(getCustomer.companyName))>
                                    <div class="align-self-center">
                                        <h2>#encodeForHTML(getCustomer.companyName)#</h2>
                                    </div>
                                <cfelse>
                                    <div class="align-self-center">
                                        <h2>#encodeForHTML(getCustomer.contactPerson)# (Private)</h2>
                                    </div>
                                </cfif>
                            </div>
                            <div class="d-flex pt-4">
                                <div class="me-5 text-muted">
                                    Address
                                </div>
                                <div class="d-flex flex-column ps-3 pe-5">
                                    <div>
                                        #getCustomer.address#
                                    </div>
                                    <div>
                                        #getCustomer.zip# #getCustomer.city#
                                    </div>
                                </div>
                                <div class="me-5 flex-column text-muted ps-3">
                                    <div>
                                        Contact person
                                    </div>
                                    <div>
                                        Email
                                    </div>
                                    <div>
                                        Phone
                                    </div>
                                    <div>
                                        Registered at
                                    </div>
                                </div>
                                <div class="me-5 d-flex flex-column ps-3">
                                    <div>
                                        #encodeForHTML(getCustomer.contactPerson)#
                                    </div>
                                    <div>
                                        #getCustomer.email#
                                    </div>
                                    <div>
                                        #getCustomer.phone#&nbsp;
                                    </div>
                                    <div>
                                        #lsDateFormat(getCustomer.insertDate)#
                                    </div>
                                </div>
                            </div>

                            <div class="card mt-4">
                                <ul class="nav nav-tabs nav-fill" data-bs-toggle="tabs">
                                    <li class="nav-item">
                                        <a href="##users" class="nav-link active" data-bs-toggle="tab"><i class="ti ti-users pe-3"></i> Users</a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="##invoices" class="nav-link" data-bs-toggle="tab"><i class="ti ti-file-text pe-3"></i> Invoices</a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="##plans" class="nav-link" data-bs-toggle="tab"><i class="ti ti-map pe-3"></i> Plans</a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="##modules" class="nav-link" data-bs-toggle="tab"><i class="ti ti-list-details pe-3"></i> Modules</a>
                                    </li>
                                </ul>
                                <div class="card-body" style="max-height: 800px;">
                                    <div class="tab-content">
                                        <div class="tab-pane show active" id="users">

                                            <div class="card" style="height: 23rem">
                                                <div class="card-body card-body-scrollable card-body-scrollable-shadow">
                                                    <div class="divide-y">
                                                        <div class="table-responsive">
                                                            <table class="table table-vcenter">
                                                                <thead>
                                                                    <tr>
                                                                    <th>Salutation</th>
                                                                    <th>First name</th>
                                                                    <th>Last name</th>
                                                                    <th>E-mail</th>
                                                                    <th class="w-1"></th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <cfset counter = 1>
                                                                    <cfloop query="qUsers">
                                                                        <form id="user_form_#counter#" method="post" action="#application.mainURL#/sysadm/customers">#csrfField()#
                                                                            <input type="hidden" name="user_id" value="#qUsers.intUserID#">
                                                                            <input type="hidden" name="customer_id" value="#thisCustomerID#">
                                                                            <tr>
                                                                                <td>
                                                                                    <input class="form-control" name="salutation" value="#encodeForHTML(qUsers.strSalutation)#">
                                                                                </td>
                                                                                <td>
                                                                                    <input class="form-control" name="first_name" value="#encodeForHTML(qUsers.strFirstName)#">
                                                                                </td>
                                                                                <td>
                                                                                    <input class="form-control" name="last_name" value="#encodeForHTML(qUsers.strLastName)#">
                                                                                </td>
                                                                                <td>
                                                                                    <input class="form-control" name="email" value="#encodeForHTML(qUsers.strEmail)#">
                                                                                </td>
                                                                                <td>
                                                                                    <div class="btn-list flex-nowrap">
                                                                                        <button type="submit" name="edit_user" value="1" class="btn btn-primary">Save</button>
                                                                                        <cfif qUsers.recordCount gt 1 and qUsers.intUserID neq session.user_id>
                                                                                            <button
                                                                                                type="submit"
                                                                                                name="delete_user"
                                                                                                value="1"
                                                                                                class="btn btn-danger"
                                                                                                onclick="return confirm('Are you sure you want to delete this user? This operation cannot be undone!');"
                                                                                            >Delete</button>
                                                                                        </cfif>
                                                                                    </div>
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
                                        <div class="tab-pane" id="invoices" data-customer-tab="invoices" data-customer-id="#thisCustomerID#">
                                            <p class="text-muted" role="status">Loading…</p>
                                        </div>
                                        <div class="tab-pane" id="plans" data-customer-tab="plans" data-customer-id="#thisCustomerID#">
                                            <p class="text-muted" role="status">Loading…</p>
                                        </div>
                                        <div class="tab-pane" id="modules" data-customer-tab="modules" data-customer-id="#thisCustomerID#">
                                            <p class="text-muted" role="status">Loading…</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>


</div>



<cfoutput>
<form action="#application.mainURL#/sysadm/invoices" method="post">#csrfField()#
<input type="hidden" name="new_invoice" value="#thisCustomerID#">
    <div id="invoice_new" class="modal modal-blur fade" tabindex="-1" style="display: none;" aria-hidden="true" data-bs-backdrop='static' data-bs-keyboard='false'>
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">New invoice</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Invoice title</label>
                        <input type="text" name="title" class="form-control" maxlength="50">
                    </div>
                </div>
                <div class="modal-footer">
                    <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                    <button type="submit" class="btn btn-primary ms-auto">
                        Save invoice
                    </button>
                </div>
            </div>
        </div>
    </div>
</form>
</cfoutput>

<!--- Delete the session, if there is one --->
<cfset structDelete(session, "comingfrom")>

<cfinclude template="account_delete_modal.cfm">
