<cfscript>

    // Exception handling for sef and customer id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisCustomerID = thiscontent.thisID;

    if (not isNumeric(thisCustomerID) or thisCustomerID lte 0) {
        location url="#application.mainURL#/sysadmin/customers" addtoken="false";
    }

    qCustomer = application.objCustomer.getCustomerData(thisCustomerID);
    qUsers = application.objUser.getAllUsers(thisCustomerID);

    if (not qCustomer.recordCount) {
        location url="#application.mainURL#/sysadmin/customers" addtoken="false";
    }

    objInvoice = new com.invoices();
    arrInvoices = objInvoice.getInvoices(thisCustomerID);

    objModules = new com.modules();
    arrModules = objModules.getAllModules();
    currentModules = objModules.getBookedModules(thisCustomerID);



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
                                </div>
                                <div class="me-5 flex-column text-muted ps-3">
                                    <div>
                                        Contact person
                                    </div>
                                    <div>
                                        E-mail
                                    </div>
                                    <div>
                                        Phone
                                    </div>
                                </div>
                                <div class="me-5 d-flex flex-column ps-3">
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

                            <div class="card mt-4">
                                <ul class="nav nav-tabs nav-fill" data-bs-toggle="tabs">
                                    <li class="nav-item">
                                        <a href="##users" class="nav-link active" data-bs-toggle="tab"><i class="fas fa-users pe-3"></i> Users</a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="##invoices" class="nav-link" data-bs-toggle="tab"><i class="fas fa-file-alt pe-3"></i> Invoices</a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="##plans" class="nav-link" data-bs-toggle="tab"><i class="fas fa-map pe-3"></i> Plans</a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="##modules" class="nav-link" data-bs-toggle="tab"><i class="fas fa-th-list pe-3"></i> Modules</a>
                                    </li>
                                </ul>
                                <div class="card-body" style="height: 400px;">
                                    <div class="tab-content">
                                        <div class="tab-pane show active" id="users">

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
                                                                    <form id="user_form_#counter#" method="post" action="#application.mainURL#/sysadm/customers">
                                                                        <input type="hidden" name="edit_user" value="">
                                                                        <input type="hidden" name="user_id" value="#qUsers.intUserID#">
                                                                        <input type="hidden" name="customer_id" value="#thisCustomerID#">
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
                                        <div class="tab-pane" id="invoices">

                                            <a href="##" data-bs-toggle="modal" data-bs-target="##invoice_new" class="btn btn-outline-primary ms-3">
                                                <i class="fas fa-plus pe-3"></i> New invoice
                                            </a>

                                            <cfif arrInvoices.totalCount gt 0>

                                                <div class="card-body card-body-scrollable card-body-scrollable-shadow">
                                                    <div class="divide-y">

                                                        <div class="table-responsive">
                                                            <table class="table table-vcenter table-mobile-md card-table">
                                                                <thead>
                                                                    <tr>
                                                                        <th>Date (UTC)</th>
                                                                        <th>Number</th>
                                                                        <th>Status</th>
                                                                        <th>Due date (UTC)</th>
                                                                        <th>Currency</th>
                                                                        <th class="text-end">Total</th>
                                                                        <th class="text-end"></th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                <cfloop array="#arrInvoices.arrayInvoices#" item="invoice">
                                                                    <tr>
                                                                        <td>#lsDateFormat(invoice.invoiceDate)#</td>
                                                                        <td>#invoice.invoiceNumber#</td>
                                                                        <td>#objInvoice.getInvoiceStatusBadge('en', invoice.invoiceStatusColor, invoice.invoiceStatusVariable)#</td>
                                                                        <td>#lsDateFormat(invoice.invoiceDueDate)#</td>
                                                                        <td>#invoice.invoiceCurrency#</td>
                                                                        <td class="text-end">#lsCurrencyFormat(invoice.invoiceTotal, "none")#</td>
                                                                        <td class="text-end">
                                                                            <div class="btn-list flex-nowrap float-end">
                                                                                <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                                                    Action
                                                                                </button>
                                                                                <div class="dropdown-menu dropdown-menu-end">
                                                                                    <a class="dropdown-item" href="#application.mainURL#/sysadmin/invoice/edit/#invoice.invoiceID#">Edit invoice</a>
                                                                                    <a class="dropdown-item" href="#application.mainURL#/account-settings/invoice/print/#invoice.invoiceID#" target="_blank">Print invoice</a>
                                                                                </div>
                                                                            </div>
                                                                        </td>
                                                                    </tr>
                                                                </cfloop>
                                                                </tbody>
                                                            </table>
                                                        </div>

                                                    </div>
                                                </div>

                                            </cfif>

                                        </div>
                                        <div class="tab-pane" id="plans">



                                        </div>
                                        <div class="tab-pane" id="modules">

                                            <div class="row">

                                                <cfloop array="#arrModules#" item="module">
                                                    <div class="col-lg-4 mb-3">
                                                        <div class="form-selectgroup form-selectgroup-boxes d-flex flex-column">
                                                            <label class="form-selectgroup-item flex-fill">
                                                                <input type="checkbox" class="form-selectgroup-input" name="moduleID" value="#module.moduleID#" >
                                                                <div class="form-selectgroup-label d-flex align-items-center p-3">
                                                                    <div class="me-3">
                                                                        <span class="form-selectgroup-check"></span>
                                                                    </div>
                                                                    <div class="form-selectgroup-label-content d-flex align-items-center">
                                                                        <span class="avatar me-3" style="background-image: url(#application.mainURL#/userdata/images/modules/#module.picture#)"></span>
                                                                        <div>
                                                                            <div class="font-weight-medium">#module.name#</div>
                                                                            <div class="text-muted">#module.short_description#</div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </cfloop>

                                            </div>

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
    <cfinclude template="/includes/footer.cfm">
</div>


<cfoutput>
<form action="#application.mainURL#/sysadm/invoices" method="post">
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