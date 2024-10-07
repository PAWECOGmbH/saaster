
<cfscript>

    // Security
    if (planGroupID neq 1) {
        location url="#application.mainURL#/dashboard" addtoken=false;
    }

    getCustomerData = application.objCustomer.getCustomerData(session.customer_id);
    getProfileData = new backend.myapp.com.profile().getProfileData(session.customer_id);

</cfscript>

<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">Profil verwalten</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item active">Arbeitgeber</li>
                        <li class="breadcrumb-item active">Profil</li>
                    </ol>
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
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-8">
                                <div class="card">
                                    <form action="#application.mainURL#/handler/profile" method="post">
                                        <input type="hidden" name="companyID" value="#session.customer_id#">
                                        <input type="hidden" name="companyName" value="#getCustomerData.companyName#">
                                        <input type="hidden" name="companyCity" value="#getCustomerData.city#">
                                        <div class="card-header">
                                            <h3 class="card-title">Firmenbeschrieb</h3>
                                        </div>
                                        <div class="card-body">
                                            <textarea class="form-control editor_small" name="description" style="height: 500px;">#getProfileData.description#</textarea>
                                        </div>
                                        <div class="card-footer">
                                            <button type="submit" id="submit_button" class="btn btn-primary">Firmenbeschrieb speichern</button>
                                            <cfif len(trim(getProfileData.url_slug))>
                                                <a href="#application.mainURL#/#getProfileData.url_slug#?backend" class="btn btn-success" target="_blank">Vorschau</a>
                                            </cfif>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="card">
                                    <div class="card-header">
                                        <h3 class="card-title">Stammdaten</h3>
                                        <div class="card-actions">
                                            <a href="#application.mainURL#/account-settings/company">
                                                Bearbeiten <i class="far fa-edit"></i>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <dl class="row">
                                            <dt class="col-3">Firma:</dt>
                                            <dd class="col-9">#getCustomerData.companyName#&nbsp;</dd>
                                            <dt class="col-3">Kontakt:</dt>
                                            <dd class="col-9">#getCustomerData.contactPerson#&nbsp;</dd>
                                            <dt class="col-3">Adresse:</dt>
                                            <dd class="col-9">#getCustomerData.address#&nbsp;</dd>
                                            <dt class="col-3">Zusatz:</dt>
                                            <dd class="col-9">#getCustomerData.address2#&nbsp;</dd>
                                            <dt class="col-3">PLZ/Ort:</dt>
                                            <dd class="col-9">#getCustomerData.zip# #getCustomerData.city#</dd>
                                            <dt class="col-3">&nbsp;</dt>
                                            <dd class="col-9">&nbsp;</dd>
                                            <dt class="col-3">Telefon:</dt>
                                            <dd class="col-9">#getCustomerData.phone#&nbsp;</dd>
                                            <dt class="col-3">E-Mail:</dt>
                                            <dd class="col-9">#getCustomerData.email#&nbsp;</dd>
                                            <dt class="col-3">Website:</dt>
                                            <dd class="col-9">#getCustomerData.website#&nbsp;</dd>
                                        </dl>
                                    </div>
                                </div>
                                <div class="card mt-4">
                                    <div class="card-header">
                                        <h3 class="card-title">Logo</h3>
                                        <div class="card-actions">
                                            <a href="#application.mainURL#/account-settings/company">
                                                Bearbeiten <i class="far fa-edit"></i>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <cfif len(trim(getCustomerData.logo))>
                                            <div class="text-center">
                                                <img src="#application.mainURL#/userdata/images/logos/#getCustomerData.logo#" alt="logo" style="max-height: 200px;">
                                            </div>
                                        <cfelse>
                                            Kein Logo vorhanden.
                                        </cfif>
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

