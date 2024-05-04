<cfscript>

    // Exception handling for sef and customer id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisCustomerID = thiscontent.thisID;

    if (not isNumeric(thisCustomerID) or thisCustomerID lte 0) {
        location url="#application.mainURL#/sysadmin/customers" addtoken="false";
    }

    getCustomer = application.objCustomer.getCustomerData(thisCustomerID);
    qUsers = application.objUser.getAllUsers(thisCustomerID);

    // Customers currency
    custCurrency = getCustomer.currencyStruct.iso;
    custCurrencyID = new backend.core.com.currency().getCurrency(custCurrency).id;

    if (!isStruct(getCustomer) or structIsEmpty(getCustomer)) {
        location url="#application.mainURL#/sysadmin/customers" addtoken="false";
    }

    objInvoice = new backend.core.com.invoices();
    arrInvoices = objInvoice.getInvoices(customerID=thisCustomerID, order='intInvoiceNumber DESC');


    // ***** Modules
    objModules = new backend.core.com.modules(currencyID=custCurrencyID);
    arrModules = objModules.getAllModules();

    objBookModule = new backend.core.com.book('module');
    objBookPlan = new backend.core.com.book('plan');

    objSysadmin = new backend.core.com.sysadmin();

    // Get the current modules of the customer (we are using a query because the function is filtered with a date)
    qCurrentModules = objSysadmin.getCurrentModules(thisCustomerID);

    currentModuleList = valueList(qCurrentModules.intModuleID);


    // ***** Plans
    objPlans = new backend.core.com.plans(currencyID=custCurrencyID);

    // Get the group id of the customer
    custGroupID = objPlans.prepareForGroupID(thisCustomerID);

    // Get all plans using the group id
    arrPlans = objPlans.getPlans(custGroupID.groupID);

    // Current plan the customer has booked
    currentPlan = objPlans.getCurrentPlan(thisCustomerID);
    planStatusText = objPlans.getPlanStatusAsText(currentPlan);

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
                                    #getCustomer.companyName#
                                <cfelse>
                                    #getCustomer.contactPerson# (Private)
                                </cfif>
                            </li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="#application.mainURL#/sysadmin/customers/edit/#getCustomer.customerID#" class="btn btn-primary">
                            <i class="fas fa-edit pe-3"></i> Edit
                        </a>
                    </div>
                </div>
            </div>
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
                                        <img src="#application.mainURL#/userdata/images/logos/#getCustomer.logo#" style="margin-right:20px" class="avatar avatar-xl mr-3 align-self-center" alt="#getCustomer.companyName#">
                                    </div>
                                <cfelse>
                                    <cfif len(trim(getCustomer.companyName))>
                                        <div class="avatar avatar-xl me-3 align-self-center">
                                            #left(getCustomer.companyName,2)#
                                        </div>
                                    <cfelse>
                                        <div class="avatar avatar-xl me-3 align-self-center">
                                            #left(getCustomer.contactPerson,2)#
                                        </div>
                                    </cfif>
                                </cfif>
                                <cfif len(trim(getCustomer.companyName))>
                                    <div class="align-self-center">
                                        <h2>#getCustomer.companyName#</h2>
                                    </div>
                                <cfelse>
                                    <div class="align-self-center">
                                        <h2>#getCustomer.contactPerson# (Private)</h2>
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
                                        E-mail
                                    </div>
                                    <div>
                                        Phone
                                    </div>
                                </div>
                                <div class="me-5 d-flex flex-column ps-3">
                                    <div>
                                        #getCustomer.contactPerson#
                                    </div>
                                    <div>
                                        #getCustomer.email#
                                    </div>
                                    <div>
                                        #getCustomer.phone#
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

                                        </div>
                                        <div class="tab-pane" id="invoices">

                                            <a href="##" data-bs-toggle="modal" data-bs-target="##invoice_new" class="btn btn-outline-primary ms-3">
                                                <i class="fas fa-plus pe-3"></i> New invoice
                                            </a>

                                            <cfif arrInvoices.totalCount gt 0>

                                                <div class="card mt-3" style="height: 20rem;">
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
                                                                            <th>Title</th>
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
                                                                            <td>#objInvoice.getInvoiceStatusBadge(session.lng, invoice.invoiceStatusColor, invoice.invoiceStatusVariable)#</td>
                                                                            <td>#lsDateFormat(invoice.invoiceDueDate)#</td>
                                                                            <td><cfif len(invoice.invoiceTitle) gt 25>#left(invoice.invoiceTitle, 25)# ...<cfelse>#invoice.invoiceTitle#</cfif></td>
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
                                                                                        <a class="dropdown-item cursor-pointer" href="#application.mainURL#/sysadm/invoices?i=#invoice.invoiceID#&email&redirect=#urlEncodedFormat('sysadmin/customers/details/#thisCustomerID#?del_redirect##invoices')#">Send invoice by e-mail</a>
                                                                                        <cfif invoice.invoiceStatusID eq 1 or invoice.invoiceStatusID eq 2>
                                                                                            <a class="dropdown-item cursor-pointer" href="#application.mainURL#/sysadm/invoices?i=#invoice.invoiceID#&status=5&redirect=#urlEncodedFormat('sysadmin/customers/details/#thisCustomerID#?del_redirect##invoices')#">Cancel invoice</a>
                                                                                        </cfif>
                                                                                        <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/invoices?i=#invoice.invoiceID#&status=delete&redirect=#urlEncodedFormat('sysadmin/customers/details/#thisCustomerID#?del_redirect##invoices')#', 'Delete invoice', 'Do you want to delete this invoice permanently?', 'No, cancel!', 'Yes, delete!')">Delete invoice</a>
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
                                                </div>

                                            </cfif>

                                        </div>
                                        <div class="tab-pane" id="plans">

                                            <div class="row">

                                                <cfloop array="#arrPlans#" item="plan">
                                                    <div class="col-lg-3 mb-3 mt-3">
                                                        <div class="card">
                                                            <div class="card-header">
                                                                <ul class="nav nav-pills card-header-pills">
                                                                    <li class="nav-item">
                                                                        <cfif plan.planID eq currentPlan.planID>
                                                                            <a class="btn btn-outline-#planStatusText.fontColor# disabled">#plan.planName#: #currentPlan.status#</a>
                                                                        <cfelse>
                                                                            <a class="btn btn-outline-info disabled">#plan.planName#</a>
                                                                        </cfif>
                                                                    </li>
                                                                    <li class="nav-item ms-auto">
                                                                        <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Action</a>
                                                                        <div class="dropdown-menu">

                                                                            <cfset checkBookingM = objBookPlan.checkBooking(customerID=thisCustomerID, bookingData=plan, recurring='monthly', makeBooking=false, makeInvoice=false, chargeInvoice=false)>
                                                                            <cfset checkBookingY = objBookPlan.checkBooking(customerID=thisCustomerID, bookingData=plan, recurring='yearly', makeBooking=false, makeInvoice=false, chargeInvoice=false)>

                                                                            <cfif currentPlan.planID eq plan.planID>

                                                                                <a href="##" class="openPopup dropdown-item" data-href="#application.mainURL#/backend/core/views/sysadmin/ajax_period.cfm?b=#currentPlan.bookingID#&c=#thisCustomerID#&p=#plan.planID#">
                                                                                    Edit period
                                                                                </a>

                                                                                <cfif currentPlan.status eq "test">
                                                                                    <cfif plan.priceMonthly gt 0>
                                                                                        <a href="#application.mainURL#/sysadm/plans?booking&invoice&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item">
                                                                                            Make invoice for monthly cycle (#custCurrency# #lsCurrencyFormat(plan.priceMonthly, "none")#)
                                                                                        </a>
                                                                                    </cfif>
                                                                                    <cfif plan.priceYearly gt 0>
                                                                                        <a href="#application.mainURL#/sysadm/plans?booking&invoice&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item">
                                                                                            Make invoice for yearly cycle (#custCurrency# #lsCurrencyFormat(plan.priceYearly, "none")#)
                                                                                        </a>
                                                                                    </cfif>
                                                                                <cfelse>
                                                                                    <cfif checkBookingM.amountToPay gt 0>
                                                                                        <a href="#application.mainURL#/sysadm/plans?booking&change&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingM.message.message#">
                                                                                            Make invoice for "#checkBookingM.message.title#" monthly (#custCurrency# #lsCurrencyFormat(checkBookingM.amountToPay, "none")#)
                                                                                        </a>
                                                                                    </cfif>
                                                                                    <cfif checkBookingY.amountToPay gt 0>
                                                                                        <a href="#application.mainURL#/sysadm/plans?booking&change&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingY.message.message#">
                                                                                            Make invoice for "#checkBookingY.message.title#" yearly (#custCurrency# #lsCurrencyFormat(checkBookingY.amountToPay, "none")#)
                                                                                        </a>
                                                                                    </cfif>
                                                                                </cfif>

                                                                                <cfif currentPlan.status eq "canceled">
                                                                                    <a href="#application.mainURL#/sysadm/plans?booking&b=#currentPlan.bookingID#&c=#thisCustomerID#&p=#plan.planID#&revoke" class="dropdown-item">
                                                                                        Revoke cancellation
                                                                                    </a>
                                                                                <cfelse>
                                                                                    <cfif currentPlan.status neq "payment">
                                                                                        <a href="#application.mainURL#/sysadm/plans?booking&b=#currentPlan.bookingID#&c=#thisCustomerID#&p=#plan.planID#&cancel" class="dropdown-item">
                                                                                            Cancel at expiry date
                                                                                        </a>
                                                                                    </cfif>
                                                                                </cfif>

                                                                                <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/plans?booking&b=#currentPlan.bookingID#&c=#thisCustomerID#&p=#plan.planID#&delete', 'Warning!', 'Please note that the customer can no longer use the plan after withdrawal. The system will NOT issue a credit note!', 'Cancel', 'OK, withdraw!')">
                                                                                    Withdraw plan
                                                                                </a>

                                                                            <cfelse>

                                                                                <cfif currentPlan.status eq "payment">

                                                                                    <a class="dropdown-item">
                                                                                        No action available (waiting for payment)
                                                                                    </a>

                                                                                <cfelse>

                                                                                    <cfif plan.itsFree>
                                                                                        <a href="#application.mainURL#/sysadm/plans?booking&c=#thisCustomerID#&p=#plan.planID#&free" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="There is no automatic refund if it is a downgrade!">
                                                                                            Activate now (free)
                                                                                        </a>
                                                                                    </cfif>
                                                                                    <cfif plan.testDays gt 0 and currentPlan.status neq "test" and currentPlan.status neq "free" and currentPlan.status neq "active">
                                                                                        <a href="#application.mainURL#/sysadm/plans?booking&test&c=#thisCustomerID#&p=#plan.planID#" class="dropdown-item" class="dropdown-item">
                                                                                            Activate the test time (#plan.testDays# days)
                                                                                        </a>
                                                                                    </cfif>

                                                                                    <cfif currentPlan.status eq "active" and !plan.itsFree>

                                                                                        <cfif checkBookingM.amountToPay gt 0>
                                                                                            <a href="#application.mainURL#/sysadm/plans?booking&change&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingM.message.message#">
                                                                                                Make invoice for "#checkBookingM.message.title#" monthly (#custCurrency# #lsCurrencyFormat(checkBookingM.amountToPay, "none")#)
                                                                                            </a>
                                                                                        <cfelse>
                                                                                            <a href="#application.mainURL#/sysadm/plans?booking&change&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingM.message.message#">
                                                                                                Change to this plan monthly cycle (#checkBookingM.message.title#)
                                                                                            </a>
                                                                                        </cfif>

                                                                                        <cfif checkBookingY.amountToPay gt 0>
                                                                                            <a href="#application.mainURL#/sysadm/plans?booking&change&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingY.message.message#">
                                                                                                Make invoice for "#checkBookingY.message.title#" yearly (#custCurrency# #lsCurrencyFormat(checkBookingY.amountToPay, "none")#)
                                                                                            </a>
                                                                                        <cfelse>
                                                                                            <a href="#application.mainURL#/sysadm/plans?booking&change&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingY.message.message#">
                                                                                                Change to this plan yearly cycle (#checkBookingY.message.title#)
                                                                                            </a>
                                                                                        </cfif>

                                                                                    <cfelse>

                                                                                        <cfif plan.priceMonthly gt 0>
                                                                                            <a href="#application.mainURL#/sysadm/plans?booking&invoice&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item">
                                                                                                Make invoice for monthly cycle (#custCurrency# #lsCurrencyFormat(plan.priceMonthly, "none")#)
                                                                                            </a>
                                                                                        </cfif>
                                                                                        <cfif plan.priceYearly gt 0>
                                                                                            <a href="#application.mainURL#/sysadm/plans?booking&invoice&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item">
                                                                                                Make invoice for yearly cycle (#custCurrency# #lsCurrencyFormat(plan.priceYearly, "none")#)
                                                                                            </a>
                                                                                        </cfif>

                                                                                    </cfif>

                                                                                </cfif>

                                                                            </cfif>

                                                                        </div>
                                                                    </li>
                                                                </ul>
                                                            </div>
                                                            <cfif (plan.planID eq currentPlan.planID)>
                                                                <div class="card-header p-3 small">
                                                                    <cfif currentPlan.status eq "canceled">
                                                                        Data deletion: #dateFormat(currentPlan.endDate, "yyyy-mm-dd")#
                                                                    <cfelse>
                                                                        Period: #dateFormat(currentPlan.startDate, "yyyy-mm-dd")# - #dateFormat(currentPlan.endDate, "yyyy-mm-dd")# (#currentPlan.recurring#)
                                                                    </cfif>
                                                                    <cfif structKeyExists(currentPlan, "nextPlan") and !structIsEmpty(currentPlan.nextPlan) and currentPlan.nextPlan.planID eq currentPlan.planID>
                                                                        <br />
                                                                        New plan: #currentPlan.nextPlan.planName# (#dateFormat(currentPlan.nextPlan.startDate, "yyyy-mm-dd")# <cfif isDate(currentPlan.nextPlan.endDate)>- #dateFormat(currentPlan.nextPlan.endDate, "yyyy-mm-dd")#</cfif> - #currentPlan.nextPlan.recurring#)
                                                                    </cfif>
                                                                </div>
                                                            <cfelse>
                                                                <div class="card-header small p-3">
                                                                    <cfif structKeyExists(currentPlan, "nextPlan") and !structIsEmpty(currentPlan.nextPlan) and currentPlan.nextPlan.planID eq plan.planID>
                                                                        WAITING:
                                                                        <br />
                                                                        #dateFormat(currentPlan.nextPlan.startDate, "yyyy-mm-dd")# <cfif isDate(currentPlan.nextPlan.endDate)>- #dateFormat(currentPlan.nextPlan.endDate, "yyyy-mm-dd")#</cfif> (#currentPlan.nextPlan.recurring#)
                                                                    <cfelse>
                                                                        Not booked
                                                                    </cfif>
                                                                </div>
                                                            </cfif>
                                                            <div class="card-body">
                                                                <div class="d-flex align-items-center">
                                                                    <div class="d-flex align-items-center">
                                                                        <div>
                                                                            <div class="text-muted">#left(plan.shortdescription, 70)# <cfif len(plan.shortdescription) gt 70>...</cfif></div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </cfloop>

                                            </div>

                                        </div>
                                        <div class="tab-pane" id="modules">

                                            <div class="row">

                                                <cfloop array="#arrModules#" item="module">
                                                    <cfif structKeyExists(module, "moduleID")>
                                                        <cfset moduleStatus = objModules.getModuleStatus(thisCustomerID, module.moduleID)>
                                                        <cfif arrayLen(module.includedInPlans)>
                                                            <div class="col-lg-4 mb-3 mt-3">
                                                                <div class="card">
                                                                    <div class="card-header">
                                                                        <ul class="nav nav-pills card-header-pills">
                                                                            <a class="btn btn-outline-info disabled">Included in a plan</a>
                                                                        </ul>
                                                                    </div>
                                                                    <div class="card-body">
                                                                        <div class="d-flex align-items-center p-3">
                                                                            <div class="d-flex align-items-center">
                                                                                <span class="avatar me-3" style="background-image: url(#application.mainURL#/userdata/images/modules/#module.picture#)"></span>
                                                                                <div>
                                                                                    <div class="font-weight-medium">#module.name#</div>
                                                                                    <div class="text-muted">#left(module.shortdescription, 30)# <cfif len(module.shortdescription) gt 30>...</cfif></div>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        <cfelse>
                                                            <div class="col-lg-4 mb-3 mt-3">
                                                                <div class="card">
                                                                    <div class="card-header">
                                                                        <ul class="nav nav-pills card-header-pills">
                                                                            <li class="nav-item">
                                                                                <cfif listFind(currentModuleList, module.moduleID)>
                                                                                    <a class="btn btn-outline-#moduleStatus.fontColor# disabled">Status: #moduleStatus.status#</a>
                                                                                <cfelse>
                                                                                    <a class="btn btn-outline-info disabled">Not booked yet</a>
                                                                                </cfif>
                                                                            </li>
                                                                            <li class="nav-item ms-auto">
                                                                                <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Action</a>
                                                                                <div class="dropdown-menu">
                                                                                    <cfif listFind(currentModuleList, module.moduleID) and moduleStatus.status neq "expired">
                                                                                        <cfif moduleStatus.status eq "canceled">
                                                                                            <a href="#application.mainURL#/sysadm/modules?booking&b=#moduleStatus.bookingID#&c=#thisCustomerID#&m=#module.moduleID#&revoke" class="dropdown-item">
                                                                                                Revoke cancellation
                                                                                            </a>
                                                                                        <cfelse>
                                                                                            <a href="##" class="openPopup dropdown-item" data-href="#application.mainURL#/backend/core/views/sysadmin/ajax_period.cfm?b=#moduleStatus.bookingID#&c=#thisCustomerID#&m=#module.moduleID#">
                                                                                                Edit period
                                                                                            </a>
                                                                                            <cfif moduleStatus.status neq "payment">
                                                                                                <a href="#application.mainURL#/sysadm/modules?booking&b=#moduleStatus.bookingID#&c=#thisCustomerID#&m=#module.moduleID#&cancel" class="dropdown-item">
                                                                                                    Cancel at expiry date
                                                                                                </a>
                                                                                            </cfif>
                                                                                        </cfif>
                                                                                        <cfif moduleStatus.recurring neq "onetime" and moduleStatus.status neq "payment" and moduleStatus.status neq "canceled">
                                                                                            <cfif moduleStatus.recurring eq "monthly">
                                                                                                <cfset amountToPay = objBookModule.checkBooking(customerID=thisCustomerID, bookingData=module, recurring='yearly', makeBooking=false, makeInvoice=false, chargeInvoice=false).amountToPay>
                                                                                                <cfif amountToPay gt 0>
                                                                                                    <a href="#application.mainURL#/sysadm/modules?booking&change&c=#thisCustomerID#&m=#module.moduleID#&r=yearly" class="dropdown-item">
                                                                                                        Make invoice for change to yearly cycle (#custCurrency# #lsCurrencyFormat(amountToPay, "none")#)
                                                                                                    </a>
                                                                                                <cfelse>
                                                                                                    <a href="#application.mainURL#/sysadm/modules?booking&change&c=#thisCustomerID#&m=#module.moduleID#&r=yearly" class="dropdown-item">
                                                                                                        Change to yearly cycle (Changed after exiry date)
                                                                                                    </a>
                                                                                                </cfif>
                                                                                            <cfelseif moduleStatus.recurring eq "yearly">
                                                                                                <cfset amountToPay = objBookModule.checkBooking(customerID=thisCustomerID, bookingData=module, recurring='monthly', makeBooking=false, makeInvoice=false, chargeInvoice=false).amountToPay>
                                                                                                <cfif amountToPay gt 0>
                                                                                                    <a href="#application.mainURL#/sysadm/modules?booking&change&c=#thisCustomerID#&m=#module.moduleID#&r=monthly" class="dropdown-item">
                                                                                                        Make invoice for change to monthly cycle (#custCurrency# #lsCurrencyFormat(amountToPay, "none")#)
                                                                                                    </a>
                                                                                                <cfelse>
                                                                                                    <a href="#application.mainURL#/sysadm/modules?booking&change&c=#thisCustomerID#&m=#module.moduleID#&r=monthly" class="dropdown-item">
                                                                                                        Change to monthly cycle (Changed after exiry date)
                                                                                                    </a>
                                                                                                </cfif>
                                                                                            </cfif>
                                                                                        </cfif>
                                                                                    <cfelse>
                                                                                        <cfif module.priceOnetime gt 0 or module.priceMonthly gt 0 or module.priceYearly gt 0>
                                                                                            <cfif module.testDays gt 0>
                                                                                                <cfif structKeyExists(moduleStatus, "status") and (moduleStatus.status eq "expired" or moduleStatus.status eq "test")>
                                                                                                <cfelse>
                                                                                                    <a href="#application.mainURL#/sysadm/modules?booking&test&c=#thisCustomerID#&m=#module.moduleID#&r=onetime" class="dropdown-item">
                                                                                                        Activate the test time (#module.testDays# days)
                                                                                                    </a>
                                                                                                </cfif>
                                                                                            </cfif>
                                                                                            <cfif module.priceMonthly gt 0 and module.priceYearly gt 0>
                                                                                                <a href="#application.mainURL#/sysadm/modules?booking&invoice&c=#thisCustomerID#&m=#module.moduleID#&r=monthly" class="dropdown-item">
                                                                                                    Make invoice monthly cycle (#custCurrency# #lsCurrencyFormat(module.priceMonthlyAfterVAT, "none")#)
                                                                                                </a>
                                                                                                <a href="#application.mainURL#/sysadm/modules?booking&invoice&c=#thisCustomerID#&m=#module.moduleID#&r=yearly" class="dropdown-item">
                                                                                                    Make invoice yearly cycle (#custCurrency# #lsCurrencyFormat(module.priceYearlyAfterVAT, "none")#)
                                                                                                </a>
                                                                                            <cfelseif module.priceOnetime gt 0>
                                                                                                <a href="#application.mainURL#/sysadm/modules?booking&invoice&c=#thisCustomerID#&m=#module.moduleID#&r=onetime" class="dropdown-item">
                                                                                                    Make invoice onetime billing (#custCurrency# #lsCurrencyFormat(module.priceOneTimeAfterVAT, "none")#)
                                                                                                </a>
                                                                                            </cfif>
                                                                                        </cfif>
                                                                                        <a href="#application.mainURL#/sysadm/modules?booking&c=#thisCustomerID#&m=#module.moduleID#&free" class="dropdown-item">
                                                                                            Activate now (free)
                                                                                        </a>
                                                                                    </cfif>
                                                                                    <cfif listFind(currentModuleList, module.moduleID)>
                                                                                        <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/modules?booking&b=#moduleStatus.bookingID#&c=#thisCustomerID#&m=#module.moduleID#&delete', 'Warning!', 'Please note that the customer can no longer use the module after withdrawal. The system will NOT issue a credit note!', 'Cancel', 'OK, withdraw!')">
                                                                                            Withdraw module
                                                                                        </a>
                                                                                    </cfif>
                                                                                </div>
                                                                            </li>
                                                                        </ul>
                                                                    </div>
                                                                    <cfif listFind(currentModuleList, module.moduleID)>
                                                                        <div class="card-header small">
                                                                            <cfif moduleStatus.status eq "canceled">
                                                                                Data deletion: #dateFormat(moduleStatus.endDate, "yyyy-mm-dd")#
                                                                            <cfelse>
                                                                                Period: #dateFormat(moduleStatus.startDate, "yyyy-mm-dd")# - #dateFormat(moduleStatus.endDate, "yyyy-mm-dd")# (#moduleStatus.recurring#)
                                                                            </cfif>
                                                                            <cfif structKeyExists(moduleStatus, "nextModule")>
                                                                                <br />
                                                                                New module period: #dateFormat(moduleStatus.nextModule.startDate, "yyyy-mm-dd")# - #dateFormat(moduleStatus.nextModule.endDate, "yyyy-mm-dd")# (#moduleStatus.nextModule.recurring#)
                                                                            </cfif>
                                                                        </div>
                                                                    </cfif>
                                                                    <div class="card-body">
                                                                        <div class="d-flex align-items-center p-3">
                                                                            <div class="d-flex align-items-center">
                                                                                <span class="avatar me-3" style="background-image: url(#application.mainURL#/userdata/images/modules/#module.picture#)"></span>
                                                                                <div>
                                                                                    <div class="font-weight-medium">#module.name#</div>
                                                                                    <div class="text-muted">#left(module.shortdescription, 30)# <cfif len(module.shortdescription) gt 30>...</cfif></div>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </cfif>
                                                    </cfif>
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

<!--- Delete the session, if there is one --->
<cfset structDelete(session, "comingfrom")>