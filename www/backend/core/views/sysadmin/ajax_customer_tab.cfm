<cfsetting showdebugoutput="no">
<cfscript>
// This endpoint is called by its path, so it must enforce its own role check.
if (!(structKeyExists(session, "user_id") and structKeyExists(session, "sysadmin") and session.sysadmin)) {
    cfheader(statuscode=403, statustext="Forbidden");
    writeOutput("Forbidden");
    abort;
}
param name="url.customerID" default="";
param name="url.tab" default="";
if (!isValid("integer", url.customerID) or val(url.customerID) lte 0 or !listFind("invoices,plans,modules", url.tab)) {
    cfheader(statuscode=400, statustext="Bad Request");
    writeOutput("Invalid customer or tab");
    abort;
}
thisCustomerID = int(url.customerID);
getCustomer = application.objCustomer.getCustomerData(thisCustomerID);
if (structIsEmpty(getCustomer)) {
    cfheader(statuscode=404, statustext="Not Found");
    writeOutput("Customer not found");
    abort;
}
getTrans = application.objLanguage.getTrans;
csrfField = application.objGlobal.csrfField;
csrfParam = application.objGlobal.csrfParam;
custCurrency = getCustomer.currencyStruct.iso;
custCurrencyID = new backend.core.com.currency().getCurrency(custCurrency).id;

switch (url.tab) {
    case "invoices":
        objInvoice = new backend.core.com.invoices();
        arrInvoices = objInvoice.getInvoices(customerID=thisCustomerID, order="intInvoiceNumber DESC");
        break;
    case "plans":
        objPlans = new backend.core.com.plans(currencyID=custCurrencyID);
        objBookPlan = new backend.core.com.book("plan");
        arrPlans = objPlans.getPlans();
        groupedPlans = {};
        loop array=arrPlans item="plan" {
            groupID = plan.planGroupID;
            if (!structKeyExists(groupedPlans, groupID)) groupedPlans[groupID] = [];
            arrayAppend(groupedPlans[groupID], plan);
        }
        sortedGroupIDs = structKeyArray(groupedPlans);
        arraySort(sortedGroupIDs, "numeric", "asc");
        currentPlan = objPlans.getCurrentPlan(thisCustomerID);
        planStatusText = objPlans.getPlanStatusAsText(currentPlan);
        break;
    case "modules":
        objModules = new backend.core.com.modules(currencyID=custCurrencyID);
        objBookModule = new backend.core.com.book("module");
        objSysadmin = new backend.core.com.sysadmin();
        arrModules = objModules.getAllModules();
        blockedModuleIDs = valueList(application.objModuleBlocks.forCustomer(thisCustomerID).intModuleID);
        qCurrentModules = objSysadmin.getCurrentModules(thisCustomerID);
        currentModuleList = valueList(qCurrentModules.intModuleID);
        break;
}
</cfscript>
<cfoutput>
<cfswitch expression="#url.tab#">
<cfcase value="invoices">
<a href="##" data-bs-toggle="modal" data-bs-target="##invoice_new" class="btn btn-outline-primary ms-3">
    <i class="ti ti-plus pe-3"></i> New invoice
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
                                <td>#objInvoice.getInvoiceStatusBadge('en', invoice.invoiceStatusColor, invoice.invoiceStatusVariable)#</td>
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
                                            <a class="dropdown-item cursor-pointer" href="#application.mainURL#/sysadm/invoices?#csrfParam()#&i=#invoice.invoiceID#&email&redirect=#urlEncodedFormat('sysadmin/customers/details/#thisCustomerID#?del_redirect##invoices')#">Send invoice by e-mail</a>
                                            <cfif invoice.invoiceStatusID eq 1 or invoice.invoiceStatusID eq 2>
                                                <a class="dropdown-item cursor-pointer" href="#application.mainURL#/sysadm/invoices?#csrfParam()#&i=#invoice.invoiceID#&status=5&redirect=#urlEncodedFormat('sysadmin/customers/details/#thisCustomerID#?del_redirect##invoices')#">Cancel invoice</a>
                                            </cfif>
                                            <cfif !invoice.documentIssued>
                                            <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/invoices?#csrfParam()#&i=#invoice.invoiceID#&status=delete&redirect=#urlEncodedFormat('sysadmin/customers/details/#thisCustomerID#?del_redirect##invoices')#', 'Delete invoice', 'Do you want to delete this invoice permanently?', 'No, cancel!', 'Yes, delete!')">Delete invoice</a>
                                            </cfif>
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
</cfcase>
<cfcase value="plans">
<div class="row">

    <cfloop array="#sortedGroupIDs#" index="groupID">
        <h3>Group #groupID#</h3>
        <cfloop array="#groupedPlans[groupID]#" item="plan">
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
                                <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" <cfif currentPlan.planGroupID gt 0 and currentPlan.planGroupID neq plan.planGroupID>style="cursor: not-allowed;" disabled</cfif>>Action</a>
                                <div class="dropdown-menu">

                                    <cfset checkBookingM = objBookPlan.checkBooking(customerID=thisCustomerID, bookingData=plan, recurring='monthly', makeBooking=false, makeInvoice=false, chargeInvoice=false)>
                                    <cfset checkBookingY = objBookPlan.checkBooking(customerID=thisCustomerID, bookingData=plan, recurring='yearly', makeBooking=false, makeInvoice=false, chargeInvoice=false)>

                                    <cfif currentPlan.planID eq plan.planID>

                                        <a href="##" class="openPopup dropdown-item" data-href="#application.mainURL#/backend/core/views/sysadmin/ajax_period.cfm?b=#currentPlan.bookingID#&c=#thisCustomerID#&p=#plan.planID#">
                                            Edit period
                                        </a>

                                        <cfif currentPlan.status eq "test">
                                            <cfif plan.priceMonthly gt 0>
                                                <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&invoice&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item">
                                                    Make invoice for monthly cycle (#custCurrency# #lsCurrencyFormat(plan.priceMonthly, "none")#)
                                                </a>
                                            </cfif>
                                            <cfif plan.priceYearly gt 0>
                                                <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&invoice&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item">
                                                    Make invoice for yearly cycle (#custCurrency# #lsCurrencyFormat(plan.priceYearly, "none")#)
                                                </a>
                                            </cfif>
                                        <cfelse>
                                            <cfif checkBookingM.amountToPay gt 0>
                                                <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&change&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingM.message.message#">
                                                    Make invoice for "#checkBookingM.message.title#" monthly (#custCurrency# #lsCurrencyFormat(checkBookingM.amountToPay, "none")#)
                                                </a>
                                            </cfif>
                                            <cfif checkBookingY.amountToPay gt 0>
                                                <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&change&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingY.message.message#">
                                                    Make invoice for "#checkBookingY.message.title#" yearly (#custCurrency# #lsCurrencyFormat(checkBookingY.amountToPay, "none")#)
                                                </a>
                                            </cfif>
                                        </cfif>

                                        <cfif currentPlan.status eq "canceled">
                                            <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&b=#currentPlan.bookingID#&c=#thisCustomerID#&p=#plan.planID#&revoke" class="dropdown-item">
                                                Revoke cancellation
                                            </a>
                                        <cfelse>
                                            <cfif currentPlan.status neq "payment">
                                                <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&b=#currentPlan.bookingID#&c=#thisCustomerID#&p=#plan.planID#&cancel" class="dropdown-item">
                                                    Cancel at expiry date
                                                </a>
                                            </cfif>
                                        </cfif>

                                        <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/plans?#csrfParam()#&booking&b=#currentPlan.bookingID#&c=#thisCustomerID#&p=#plan.planID#&delete', 'Warning!', 'Please note that the customer can no longer use the plan after withdrawal. The system will NOT issue a credit note!', 'Cancel', 'OK, withdraw!')">
                                            Withdraw plan
                                        </a>

                                    <cfelse>

                                        <cfif currentPlan.status eq "payment">

                                            <a class="dropdown-item">
                                                No action available (waiting for payment)
                                            </a>

                                        <cfelse>

                                            <cfif plan.itsFree>
                                                <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&c=#thisCustomerID#&p=#plan.planID#&free" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="There is no automatic refund if it is a downgrade!">
                                                    Activate now (free)
                                                </a>
                                            </cfif>
                                            <cfif plan.testDays gt 0 and currentPlan.status neq "test" and currentPlan.status neq "free" and currentPlan.status neq "active">
                                                <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&test&c=#thisCustomerID#&p=#plan.planID#" class="dropdown-item" class="dropdown-item">
                                                    Activate the test time (#plan.testDays# days)
                                                </a>
                                            </cfif>

                                            <cfif currentPlan.status eq "active" and !plan.itsFree>

                                                <cfif checkBookingM.amountToPay gt 0>
                                                    <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&change&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingM.message.message#">
                                                        Make invoice for "#checkBookingM.message.title#" monthly (#custCurrency# #lsCurrencyFormat(checkBookingM.amountToPay, "none")#)
                                                    </a>
                                                <cfelse>
                                                    <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&change&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingM.message.message#">
                                                        Change to this plan monthly cycle (#checkBookingM.message.title#)
                                                    </a>
                                                </cfif>

                                                <cfif checkBookingY.amountToPay gt 0>
                                                    <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&change&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingY.message.message#">
                                                        Make invoice for "#checkBookingY.message.title#" yearly (#custCurrency# #lsCurrencyFormat(checkBookingY.amountToPay, "none")#)
                                                    </a>
                                                <cfelse>
                                                    <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&change&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item" data-bs-toggle="tooltip" data-bs-placement="top" title="#checkBookingY.message.message#">
                                                        Change to this plan yearly cycle (#checkBookingY.message.title#)
                                                    </a>
                                                </cfif>

                                            <cfelse>

                                                <cfif plan.priceMonthly gt 0>
                                                    <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&invoice&c=#thisCustomerID#&p=#plan.planID#&r=monthly" class="dropdown-item">
                                                        Make invoice for monthly cycle (#custCurrency# #lsCurrencyFormat(plan.priceMonthly, "none")#)
                                                    </a>
                                                </cfif>
                                                <cfif plan.priceYearly gt 0>
                                                    <a href="#application.mainURL#/sysadm/plans?#csrfParam()#&booking&invoice&c=#thisCustomerID#&p=#plan.planID#&r=yearly" class="dropdown-item">
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
    </cfloop>

</div>
</cfcase>
<cfcase value="modules">
<div class="row">

    <cfloop array="#arrModules#" item="module">
        <cfif structKeyExists(module, "moduleID")>
            <cfset moduleStatus = objModules.getModuleStatus(thisCustomerID, module.moduleID)>
            <cfset moduleAccessBlocked = listFind(blockedModuleIDs, module.moduleID) gt 0>
            <cfset moduleAccessManaged = moduleAccessBlocked or objModules.getModuleAccessBookings(thisCustomerID, module.moduleID).recordCount gt 0>
            <cfif arrayLen(module.includedInPlans)>
                <div class="col-lg-4 mb-3 mt-3">
                    <div class="card">
                        <div class="card-header">
                            <ul class="nav nav-pills card-header-pills">
                                <li class="nav-item"><a class="btn btn-outline-info disabled">Included in a plan</a></li>
                                <cfif moduleAccessManaged>
                                    <li class="nav-item ms-auto">
                                        <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-expanded="false">Action</a>
                                        <div class="dropdown-menu">
                                            <cfinclude template="module_access_action.cfm">
                                        </div>
                                    </li>
                                </cfif>
                            </ul>
                        </div>
                        <cfif moduleAccessBlocked><div class="card-header"><span class="badge bg-red-lt">Access blocked</span></div></cfif>
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
                                                <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&b=#moduleStatus.bookingID#&c=#thisCustomerID#&m=#module.moduleID#&revoke" class="dropdown-item">
                                                    Revoke cancellation
                                                </a>
                                            <cfelse>
                                                <a href="##" class="openPopup dropdown-item" data-href="#application.mainURL#/backend/core/views/sysadmin/ajax_period.cfm?b=#moduleStatus.bookingID#&c=#thisCustomerID#&m=#module.moduleID#">
                                                    Edit period
                                                </a>
                                                <cfif moduleStatus.status neq "payment">
                                                    <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&b=#moduleStatus.bookingID#&c=#thisCustomerID#&m=#module.moduleID#&cancel" class="dropdown-item">
                                                        Cancel at expiry date
                                                    </a>
                                                </cfif>
                                            </cfif>
                                            <cfif moduleStatus.recurring neq "onetime" and moduleStatus.status neq "payment" and moduleStatus.status neq "canceled">
                                                <cfif moduleStatus.recurring eq "monthly">
                                                    <cfset amountToPay = objBookModule.checkBooking(customerID=thisCustomerID, bookingData=module, recurring='yearly', makeBooking=false, makeInvoice=false, chargeInvoice=false).amountToPay>
                                                    <cfif amountToPay gt 0>
                                                        <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&change&c=#thisCustomerID#&m=#module.moduleID#&r=yearly" class="dropdown-item">
                                                            Make invoice for change to yearly cycle (#custCurrency# #lsCurrencyFormat(amountToPay, "none")#)
                                                        </a>
                                                    <cfelse>
                                                        <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&change&c=#thisCustomerID#&m=#module.moduleID#&r=yearly" class="dropdown-item">
                                                            Change to yearly cycle (Changed after exiry date)
                                                        </a>
                                                    </cfif>
                                                <cfelseif moduleStatus.recurring eq "yearly">
                                                    <cfset amountToPay = objBookModule.checkBooking(customerID=thisCustomerID, bookingData=module, recurring='monthly', makeBooking=false, makeInvoice=false, chargeInvoice=false).amountToPay>
                                                    <cfif amountToPay gt 0>
                                                        <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&change&c=#thisCustomerID#&m=#module.moduleID#&r=monthly" class="dropdown-item">
                                                            Make invoice for change to monthly cycle (#custCurrency# #lsCurrencyFormat(amountToPay, "none")#)
                                                        </a>
                                                    <cfelse>
                                                        <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&change&c=#thisCustomerID#&m=#module.moduleID#&r=monthly" class="dropdown-item">
                                                            Change to monthly cycle (Changed after exiry date)
                                                        </a>
                                                    </cfif>
                                                </cfif>
                                            </cfif>
                                        <cfelse>
                                            <cfif module.priceOnetime gt 0 or module.priceMonthly gt 0 or module.priceYearly gt 0>
                                                <cfif module.testDays gt 0>
                                                    <cfif structKeyExists(moduleStatus, "status") and moduleStatus.status eq "expired" and (moduleStatus.recurring ?: "") eq "test">
                                                        <!--- An expired test phase can get a new end date and runs again as test phase (##624) --->
                                                        <a href="##" class="openPopup dropdown-item" data-href="#application.mainURL#/backend/core/views/sysadmin/ajax_period.cfm?b=#moduleStatus.bookingID#&c=#thisCustomerID#&m=#module.moduleID#">
                                                            Extend the test phase
                                                        </a>
                                                    <cfelseif structKeyExists(moduleStatus, "status") and (moduleStatus.status eq "expired" or moduleStatus.status eq "test")>
                                                    <cfelse>
                                                        <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&test&c=#thisCustomerID#&m=#module.moduleID#&r=onetime" class="dropdown-item">
                                                            Activate the test time (#module.testDays# days)
                                                        </a>
                                                    </cfif>
                                                </cfif>
                                                <cfif module.priceMonthly gt 0 and module.priceYearly gt 0>
                                                    <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&invoice&c=#thisCustomerID#&m=#module.moduleID#&r=monthly" class="dropdown-item">
                                                        Make invoice monthly cycle (#custCurrency# #lsCurrencyFormat(module.priceMonthlyAfterVAT, "none")#)
                                                    </a>
                                                    <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&invoice&c=#thisCustomerID#&m=#module.moduleID#&r=yearly" class="dropdown-item">
                                                        Make invoice yearly cycle (#custCurrency# #lsCurrencyFormat(module.priceYearlyAfterVAT, "none")#)
                                                    </a>
                                                <cfelseif module.priceOnetime gt 0>
                                                    <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&invoice&c=#thisCustomerID#&m=#module.moduleID#&r=onetime" class="dropdown-item">
                                                        Make invoice onetime billing (#custCurrency# #lsCurrencyFormat(module.priceOneTimeAfterVAT, "none")#)
                                                    </a>
                                                </cfif>
                                            </cfif>
                                            <a href="#application.mainURL#/sysadm/modules?#csrfParam()#&booking&c=#thisCustomerID#&m=#module.moduleID#&free" class="dropdown-item">
                                                Activate now (free)
                                            </a>
                                        </cfif>
                                        <cfif listFind(currentModuleList, module.moduleID)>
                                            <cfset withdrawDeletesData = false>
                                            <cfif structKeyExists(application, "objSubscriptionHooks") and structKeyExists(application.objSubscriptionHooks, "deletesCustomerDataOnWithdraw")>
                                                <cfset withdrawDeletesData = application.objSubscriptionHooks.deletesCustomerDataOnWithdraw(module.moduleID)>
                                            </cfif>
                                            <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/modules?#csrfParam()#&booking&b=#moduleStatus.bookingID#&c=#thisCustomerID#&m=#module.moduleID#&delete', 'Warning!', 'Please note that the customer can no longer use the module after withdrawal. The system will NOT issue a credit note!<cfif withdrawDeletesData> All customer data stored by this module will be permanently deleted.</cfif>', 'Cancel', 'OK, withdraw!')">
                                                Withdraw module
                                            </a>
                                        </cfif>
                                        <cfinclude template="module_access_action.cfm">
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
                        <cfif moduleAccessBlocked><div class="card-header"><span class="badge bg-red-lt">Access blocked</span></div></cfif>
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
            <cfinclude template="module_access_modal.cfm">
        </cfif>
    </cfloop>

</div>
</cfcase>
</cfswitch>
</cfoutput>
