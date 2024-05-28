
<cfscript>

    objPayrexx = new backend.core.com.payrexx();
    getWebhook = objPayrexx.getWebhook(customerID=session.customer_id, status='authorized', default='', includingFailed='yes');

    // The user has canceled the payment process
    if (structKeyExists(url, "cancel")) {

        // If the user is coming from registration process, set the default plan
        if (structKeyExists(session, "redirect") and findNoCase("plan=", session.redirect)) {

            objBook = new backend.core.com.book();
            codeToDecrypt = listLast(session.redirect, "=");

            if (len(trim(codeToDecrypt)) gt 100) {

                // We need to search the groupID
                getPlanData = objBook.decryptBookingLink(codeToDecrypt);
                objPlans = new backend.core.com.plans();
                planGroupID = objPlans.getPlanDetail(getPlanData.planID).planGroupID;

                // Set the default plan
                setPlan = objPlans.setDefaultPlan(session.customer_id, planGroupID);

                // Save plan into a session
                application.objCustomer.setProductSessions(session.customer_id, session.lng);

                // Destroy redirect session
                structDelete(session, "redirect");

                logWrite("user", "info", "The user has canceled the payment process, the default plan has been set [CustomerID: #session.customer_id#, UserID: #session.user_id#]");

                location url="#application.mainURL#/dashboard" addtoken="false";

            }

        }

        logWrite("user", "info", "The user has canceled the payment process [CustomerID: #session.customer_id#, UserID: #session.user_id#]");

    }

</cfscript>




<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('titPaymentSettings')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                            <li class="breadcrumb-item active">#getTrans('titPaymentSettings')#</li>
                        </ol>
                    </div>

                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="#application.mainURL#/payment-settings?add=#session.customer_id#" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> #getTrans('btnAddPaymentMethod')#
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
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('txtPaymentSettings')#</h3>
                        </div>
                        <div class="card-body">
                            <cfif getWebhook.recordCount>
                                <cfloop query="getWebhook">
                                    <div class="row align-items-center mb-4">
                                        <div class="col-lg-2 mb-2">
                                            <img src="/dist/img/payments/card_#lcase(replace(getWebhook.strPaymentBrand,' ', '-', 'all'))#.svg" class="avatar-lg">
                                        </div>
                                        <div class="col-lg-2 mb-3">
                                            <div class="font-weight-medium">#getWebhook.strPaymentBrand#</div>
                                            <div class="text-muted">#getWebhook.strCardNumber#</div>
                                        </div>
                                        <div class="col-lg-3 mb-3">
                                            <label class="form-check form-switch">
                                                <cfif getWebhook.blndefault eq 1 and getWebhook.blnFailed eq 0>
                                                    <input class="form-check-input" type="checkbox" name="default" checked <cfif getWebhook.recordCount eq 1>disabled</cfif>>
                                                <cfelse>
                                                    <input onclick="window.location.href='#application.mainURL#/payment-settings?default=#getWebhook.intPayrexxID#'" class="form-check-input" type="checkbox" name="default">
                                                </cfif>
                                                <span class="form-check-label">#getTrans('btnSetStandard')#</span>
                                            </label>
                                        </div>
                                        <div class="col-lg-2 mb-3">
                                            <cfif getWebhook.recordCount gt 1>
                                                <a onclick="sweetAlert('warning', '#application.mainURL#/payment-settings?del=#getWebhook.intPayrexxID#', '#getTrans('btnRemovePaymentMethod')#', '#getTrans('msgRemovePaymentMethod')#', '#getTrans('btnNoCancel')#', '#getTrans('btnYesDelete')#')" class="btn">#getTrans('btnRemovePaymentMethod')#</a>
                                            <cfelse>
                                                <a onclick="sweetAlert('info', '', '', '#getTrans('msgNeedOnePaymentType')#', 'OK')" class="btn">#getTrans('btnRemovePaymentMethod')#</a>
                                            </cfif>
                                        </div>
                                        <cfif getWebhook.blnFailed eq 1>
                                            <div class="col-lg-2 mb-2">
                                                <i class="fas fa-exclamation-triangle text-yellow h1" data-bs-toggle="tooltip" data-bs-placement="top" title="#getTrans('titChargingNotPossible')#"></i>
                                            </div>
                                        </cfif>
                                    </div>
                                </cfloop>
                            <cfelse>
                                <p>
                                    <span class="text-red">#getTrans('txtNoPaymentMethod')# </span>
                                    <a href="#application.mainURL#/payment-settings?add=#session.customer_id#">
                                        #getTrans('btnAddPaymentMethod')#
                                    </a>
                                </p>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>


</div>

