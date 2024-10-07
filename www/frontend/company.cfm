<cfscript>

    // Get adID from url
    companyID = listLast(cgi.path_info, "-");
    if(!isNumeric(companyID)) {
        location url="#application.mainURL#" addtoken="false";
    }

    // If call from backend
    backend = false;
    if (structKeyExists(url, "backend")) {
        if (structKeyExists(session, "admin")) {
            backend = true;
        }
    }

    companyProfile = application.objProfilesFrontend.getCompanyProfile(companyID, backend);
    if(!structKeyExists(companyProfile, "name")) {
        location url="#application.mainURL#" addtoken="false";
    }

</cfscript>

<main>

    <cfoutput>
    <cfif backend>
        <div class="alert alert-important alert-success alert-dismissible" role="alert">
            <h2 class="text-center">Dies ist eine Vorschau!</h2>
        </div>
    </cfif>
    <section class="mt-4 mb-5 pb-4">
        <div class="container-xl jb-container mx-auto d-flex justify-content-between align-content-center column-gap-4 gap-btw">
            <div class="job-card-container detail-job container-xl mx-auto" style="background-color: ##ffffff;">
                <div id="job-detail-section">
                    <div class="job-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div class="pe-4"><h1>#companyProfile.name#</h1></div>
                        </div>
                    </div>
                </div>

                <!--- Description --->
                <div class="mt-4 pb-4 description">
                    <div class="description-para">
                        #companyProfile.description#
                    </div>
                </div>

            </div>

            <div class="sidebar">
                <div>
                    <cfif len(trim(companyProfile.logo))>
                        <div class="descrip-img py-3">
                            <div>
                                <img src="#application.mainURL#/userdata/images/logos/#companyProfile.logo#" alt="#companyProfile.name#">
                            </div>
                        </div>
                    </cfif>

                    <div class="sidebar-detail py-3">
                        <h1>Kontakt</h1>
                        <div class="d-flex sidebar-detail-list justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                            <iconify-icon icon="ep:location"></iconify-icon>
                            <span class="w-100">
                                #companyProfile.name#<br />
                                <cfif len(trim(companyProfile.contact))>
                                    #companyProfile.contact#<br />
                                </cfif>
                                #companyProfile.address#<br />
                                <cfif len(trim(companyProfile.address2))>
                                    #companyProfile.address2#<br />
                                </cfif>
                                #companyProfile.zip# #companyProfile.city#
                            </span>
                        </div>
                        <cfif len(trim(companyProfile.phone))>
                            <div class="d-flex sidebar-detail-list web justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                                <iconify-icon icon="mdi:phone-classic"></iconify-icon>
                                <span class="w-100"><a href="tel:#replace(companyProfile.phone,' ', '','all')#">#companyProfile.phone#</a></span>
                            </div>
                        </cfif>
                        <cfif len(trim(companyProfile.email))>
                            <div class="d-flex sidebar-detail-list web justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                                <iconify-icon icon="material-symbols:mail-outline"></iconify-icon>
                                <span class="w-100"><a href="mailto:#companyProfile.email#">#companyProfile.email#</a></span>
                            </div>
                        </cfif>
                        <cfif len(trim(companyProfile.website)) and isValid("url", companyProfile.website)>
                            <div class="d-flex sidebar-detail-list web justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                                <iconify-icon icon="streamline:web"></iconify-icon>
                                <span class="w-100"><a href="#companyProfile.website#" target="_blank">#companyProfile.website#</a></span>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </section>
    </cfoutput>

</main>