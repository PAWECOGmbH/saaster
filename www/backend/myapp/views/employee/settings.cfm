<cfscript>

    // Security
    if (planGroupID neq 2) {
        location url="#application.mainURL#/dashboard" addtoken=false;
    }

    objProfile = new backend.myapp.com.profile();
    getProfileAccess = objProfile.getProfileAccess(session.user_id);

    objAds = new backend.myapp.com.ads();
    qAd = objAds.getAdDetails(getProfileAccess.adID, 2);
    if(not qAd.recordCount){
        location url="#application.mainURL#/employee/ads/new" addtoken="false";
    }

    if (getProfileAccess.public eq 1) {
        disableTag = "";
    } else {
        disableTag = "disabled";
    }

</cfscript>

<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">Inserateverwaltung</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item">Jobprofil</li>
                        <li class="breadcrumb-item active">Einstellungen</li>
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
                    <div class="card-header">
                        <h3 class="card-title">Einstellungen Ihres Jobprofils</h3>
                    </div>
                    <div class="card-body">

                        <form action="#application.mainURL#/handler/profile" method="post">
                            <input type="hidden" name="status">
                            <input type="hidden" name="adID" value="#qAd.intAdID#">
                            <div class="card col-lg-6">
                                <div class="card-body">
                                    <div class="divide-y">
                                        <div>
                                            <label class="row">
                                                <span class="col"><strong>Möchten Sie Ihr Profil veröffentlichen?</strong></span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" type="checkbox" name="public" onchange="this.form.submit()" <cfif getProfileAccess.public eq 1>checked</cfif> <cfif session.currentPlan.status eq "free">disabled</cfif>>
                                                    </label>
                                                </span>
                                            </label>
                                            <cfif session.currentPlan.status eq "free">
                                                <div class="text-danger mt-3">Bevor Sie Ihr Profil veröffentlichen können, müssen Sie den <a href="#application.mainURL#/account-settings/plans">Plan wechseln</a>.</div>
                                            </cfif>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>

                        <form action="#application.mainURL#/handler/profile" method="post">
                            <input type="hidden" name="access">
                            <input type="hidden" name="adID" value="#qAd.intAdID#">
                            <div class="card col-lg-6 mt-3">
                                <div class="card-header">
                                    Welche Daten dürfen wir auf Stellensuche.ch publizieren?
                                </div>
                                <div class="card-body">
                                    <div class="divide-y">
                                        <div>
                                            <label class="row">
                                                <span class="col">Anrede</span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" name="showSalutation" type="checkbox" onchange="this.form.submit()" <cfif getProfileAccess.showSalutation eq 1>checked</cfif> #disableTag#>
                                                    </label>
                                                </span>
                                            </label>
                                        </div>
                                        <div>
                                            <label class="row">
                                                <span class="col">Vorname</span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" name="showFirstName" type="checkbox" onchange="this.form.submit()" <cfif getProfileAccess.showFirstName eq 1>checked</cfif> #disableTag#>
                                                    </label>
                                                </span>
                                            </label>
                                        </div>
                                        <div>
                                            <label class="row">
                                                <span class="col">Name</span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" name="showLastName" type="checkbox" onchange="this.form.submit()" <cfif getProfileAccess.showLastName eq 1>checked</cfif> #disableTag#>
                                                    </label>
                                                </span>
                                            </label>
                                        </div>
                                        <div>
                                            <label class="row">
                                                <span class="col">E-Mail</span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" name="showEmail" type="checkbox" onchange="this.form.submit()" <cfif getProfileAccess.showEmail eq 1>checked</cfif> #disableTag#>
                                                    </label>
                                                </span>
                                            </label>
                                        </div>
                                        <div>
                                            <label class="row">
                                                <span class="col">Telefon</span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" name="showTel" type="checkbox" onchange="this.form.submit()" <cfif getProfileAccess.showTel eq 1>checked</cfif> #disableTag#>
                                                    </label>
                                                </span>
                                            </label>
                                        </div>
                                        <div>
                                            <label class="row">
                                                <span class="col">Handy</span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" name="showMobile" type="checkbox" onchange="this.form.submit()" <cfif getProfileAccess.showMobile eq 1>checked</cfif> #disableTag#>
                                                    </label>
                                                </span>
                                            </label>
                                        </div>
                                        <div>
                                            <label class="row">
                                                <span class="col">Strasse</span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" name="showstreet" type="checkbox" onchange="this.form.submit()" <cfif getProfileAccess.showstreet eq 1>checked</cfif> #disableTag#>
                                                    </label>
                                                </span>
                                            </label>
                                        </div>
                                        <div>
                                            <label class="row">
                                                <span class="col">PLZ/Ort</span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" name="showZipCity" type="checkbox" onchange="this.form.submit()" <cfif getProfileAccess.showZipCity eq 1>checked</cfif> #disableTag#>
                                                    </label>
                                                </span>
                                            </label>
                                        </div>
                                        <div>
                                            <label class="row">
                                                <span class="col">Foto</span>
                                                <span class="col-auto">
                                                    <label class="form-check form-check-single form-switch">
                                                        <input class="form-check-input" name="showPhoto" type="checkbox" onchange="this.form.submit()" <cfif getProfileAccess.showPhoto eq 1>checked</cfif> #disableTag#>
                                                    </label>
                                                </span>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>


                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>