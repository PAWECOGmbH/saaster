
<cfscript>

    qCountries = application.objGlobal.getCountry(language=session.lng);

    custCompany = getCustomerData.companyName;
    custContactPerson = getCustomerData.contactPerson;
    custAddress = getCustomerData.address;
    custAddress2 = getCustomerData.address2;
    custZIP = getCustomerData.zip;
    custCity = getCustomerData.city;
    countryID = getCustomerData.countryID;
    timezoneID = getCustomerData.timezoneID;
    custPhone = getCustomerData.phone;
    custWebsite = getCustomerData.website;
    custBillingAccountName = getCustomerData.billingAccountName;
    custBillingEmail = getCustomerData.billingEmail;
    custBillingAddress = getCustomerData.billingAddress;
    custBillingInfo = getCustomerData.billingInfo;

    if (len(trim(getCustomerData.email))) {
        custEmail = getCustomerData.email;
    } else {
        custEmail = session.user_email;
    }

    timeZones = getTime.getTimezones();

</cfscript>

<cfoutput>
<div id="fillData" class="modal fade" tabindex="-1" style="display: none;" aria-hidden="true" data-bs-backdrop='static' data-bs-keyboard='false'>
    <div class="modal-dialog modal-fullscreen">
        <div class="modal-content">
            <form action="#application.mainURL#/customer" method="post">
            <input type="hidden" name="edit_company_btn">
            <input type="hidden" name="email" value="#custEmail#">
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-4"></div>
                    <div class="col-md-4">
                        <h5 class="modal-title h4 text-blue mb-4">#getTrans('txtUpdateInformation')#:</h5>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('formCompanyName')#</label>
                            <input type="text" name="company" class="form-control" value="#HTMLEditFormat(custCompany)#" minlength="3" maxlength="100" >
                        </div>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('formContactName')# *</label>
                            <input type="text" name="contact" class="form-control" value="#HTMLEditFormat(custContactPerson)#" minlength="3" maxlength="100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('formAddress')# *</label>
                            <input type="text" name="address" class="form-control" value="#HTMLEditFormat(custAddress)#" minlength="3" maxlength="100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('formAddress2')#</label>
                            <input type="text" name="address2" class="form-control" value="#HTMLEditFormat(custAddress2)#" maxlength="100">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('formZIP')# *</label>
                            <input type="text" name="zip" class="form-control" value="#HTMLEditFormat(custZIP)#" minlength="4" maxlength="10" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('formCity')# *</label>
                            <input type="text" name="city" class="form-control" value="#HTMLEditFormat(custCity)#" minlength="3" maxlength="100" required>
                        </div>
                        <cfif qCountries.recordCount>
                            <div class="mb-3">
                                <label class="form-label">#getTrans('formCountry')#</label>
                                <select name="countryID" class="form-select" required>
                                    <option value=""></option>
                                    <cfloop query="qCountries">
                                        <option value="#qCountries.intCountryID#" <cfif qCountries.intCountryID eq countryID>selected</cfif>>#qCountries.strCountryName#</option>
                                    </cfloop>
                                </select>
                            </div>
                        <cfelse>
                            <div class="mb-3">
                                <label class="form-label">#getTrans('titTimezone')#</label>
                                <select name="timezoneID" class="form-select" required>
                                    <option value=""></option>
                                    <cfloop array="#timeZones#" index="i">
                                        <option value="#i.id#" <cfif i.utc eq timezoneID>selected</cfif>>#i.timezone# - #i.city# (#i.utc#)</option>
                                    </cfloop>
                                </select>
                            </div>
                        </cfif>
                        <div>
                            <button type="submit" id="submit_button" class="btn btn-primary">#getTrans('btnSave')#</button>
                        </div>
                    </div>
                    <div class="col-md-4"></div>
                </div>
            </div>
            </form>
        </div>
    </div>
</div>
</cfoutput>