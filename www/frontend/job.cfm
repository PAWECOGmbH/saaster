<cfscript>

    // Get adID from url
    urlAdID = listLast(cgi.path_info, "-");
    if(!isNumeric(urlAdID)) {
        location url="#application.mainURL#" addtoken="false";
    }

    // Get UUID of ad
    uuid = application.objAdsBackend.getAdDetails(urlAdID, 1).strUUID;
    if(!len(trim(uuid))) {
        location url="#application.mainURL#" addtoken="false";
    }

    // If call from backend
    backend = false;
    if (structKeyExists(url, "backend")) {
        if (structKeyExists(session, "admin")) {
            backend = true;
        }
    }

    jobDetail = application.objAdsFrontend.getAdDetail(uuid, backend);
    if(!structKeyExists(jobDetail, "id")) {
        location url="#application.mainURL#/stelle-suchen" addtoken="false";
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
                        <cfif structKeyExists(session, "alert")>
                            <div class="mb-3">
                                #session.alert#
                            </div>
                        </cfif>
                        <div class="d-flex justify-content-between align-items-start">
                            <div class="pe-4"><h1>#jobDetail.jobTitle# (#jobDetail.workloadSet#)</h1></div>
                            <div class="d-md-flex d-none align-items-center justify-content-between column-gap-3">
                                <cfif jobDetail.showApplication eq 1>
                                    <cfif structKeyExists(session, "customer_id") and planGroupID eq 2>
                                        <a href="#application.mainURL#/stelle/bewerben?job=#jobDetail.uuid#">
                                            <button class="btn-pill job-btn">Jetzt bewerben</button>
                                        </a>
                                    <cfelse>
                                        <a href="#application.mainURL#/login?redirect=#urlEncodedFormat('#replace(cgi.path_info, '/', '', 'one')#')#">
                                            <button class="btn-pill job-btn">Jetzt bewerben</button>
                                        </a>
                                    </cfif>
                                </cfif>
                            </div>
                        </div>
                        <div class="sub-details d-flex flex-sm-row flex-column align-items-start justify-content-start column-gap-4 row-gap-3 mb-1">
                            <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                                <iconify-icon icon="hugeicons:maps"></iconify-icon>
                                <span>
                                    <cfset totalLocations = arrayLen(jobDetail.locations)>
                                    <cfset locCnt = 0>
                                    <cfloop array="#jobDetail.locations#" index="loc">
                                        <cfset locCnt++>
                                        #loc.name#<cfif locCnt lt totalLocations>, </cfif>
                                    </cfloop>
                                </span>
                            </div>
                        </div>
                        <div class="sub-details d-flex flex-sm-row flex-column align-items-start justify-content-start column-gap-4 row-gap-3">
                            <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                                <iconify-icon icon="carbon:industry"></iconify-icon>
                                <span>
                                    <cfset totalIndustries = arrayLen(jobDetail.industries)>
                                    <cfset indCnt = 0>
                                    <cfloop array="#jobDetail.industries#" index="ind">
                                        <cfset indCnt++>
                                        #ind.name#<cfif indCnt lt totalIndustries>, </cfif>
                                    </cfloop>
                                </span>
                            </div>
                        </div>
                        <div class="d-flex d-md-none align-items-center justify-content-center column-gap-3 pt-4">
                            <cfif jobDetail.showApplication eq 1>
                                <button class="btn-pill job-btn w-100">Jetzt bewerben</button>
                            </cfif>
                            <button class="switch-icons position-relative" style="background: none; outline: none; border: none; width: 25px;">
                                <span class="text-secondary position-relative z-1" style="display: flex; justify-content: center; align-items: center;">
                                    <iconify-icon icon="material-symbols:favorite-outline"></iconify-icon>
                                </span>
                                <span class="text-red" style="display: none; ">
                                    <iconify-icon icon="material-symbols:favorite"></iconify-icon>
                                </span>
                            </button>
                        </div>
                    </div>
                </div>

                <!--- Description --->
                <div class="mt-4 pb-4 description">
                    <div class="description-para">
                        <p>#jobDetail.jobDescription#</p>
                    </div>
                </div>

                <!-- Video Section -->
                <cfif len(trim(jobDetail.videoLink))>
                    <cfset videoIframe = application.objAdsFrontend.generateEmbedCode(jobDetail.videoLink)>
                    <cfif len(trim(videoIframe))>
                        <div class="outer-container pt-3 pb-4">
                            <div class="video-container">
                                #videoIframe#
                            </div>
                        </div>
                    </cfif>
                </cfif>

            </div>

            <cfinclude template="company_sidebar.cfm">

        </div>
    </section>
    </cfoutput>

</main>