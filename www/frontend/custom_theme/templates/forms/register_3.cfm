<cfoutput>

<div class="container py-4 px-3 mx-auto w-25">

    <div class="card">

        <div class="card-header">
            #getTrans('txtUpdateInformation')#
        </div>

        <form id="submit_form" method="post" action="#application.mainURL#/logincheck">
            <input type="hidden" name="fill_remaining_data">
            <div class="card-body">
                <div class="mb-3">
                    <label class="form-label">#getTrans('formCompanyName')#</label>
                    <input type="text" name="company" class="form-control" value="#HTMLEditFormat(sessionData.company)#" minlength="3" maxlength="100" >
                </div>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formContactName')# *</label>
                    <input type="text" name="contact" class="form-control" value="#HTMLEditFormat(sessionData.first_name)# #HTMLEditFormat(sessionData.name)#" minlength="3" maxlength="100" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formAddress')# *</label>
                    <input type="text" name="address" class="form-control" value="" minlength="3" maxlength="100" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formAddress2')#</label>
                    <input type="text" name="address2" class="form-control" value="" maxlength="100">
                </div>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formZIP')# *</label>
                    <input type="text" name="zip" class="form-control" value="" minlength="4" maxlength="10" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formCity')# *</label>
                    <input type="text" name="city" class="form-control" value="" minlength="3" maxlength="100" required>
                </div>
                <cfif additionalData.qCountries.recordCount>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formCountry')# *</label>
                        <select name="countryID" class="form-select" required>
                            <option value=""></option>
                            <cfloop query="additionalData.qCountries">
                                <option value="#additionalData.qCountries.intCountryID#">#additionalData.qCountries.strCountryName#</option>
                            </cfloop>
                        </select>
                    </div>
                <cfelse>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('titTimezone')# *</label>
                        <select name="timezoneID" class="form-select" required>
                            <option value=""></option>
                            <cfloop array="#additionalData.timeZones#" index="i">
                                <option value="#i.id#">#i.timezone# - #i.city# (#i.utc#)</option>
                            </cfloop>
                        </select>
                    </div>
                </cfif>
                <div>
                    <button type="submit" id="submit_button" class="btn btn-primary">#getTrans('btnSave')#</button>
                </div>
            </div>
        </form>

    </div>

</div>

</cfoutput>