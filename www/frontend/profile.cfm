
<cfscript>

    // Get adID from url
    urlAdID = listLast(cgi.path_info, "-");
    if(!isNumeric(urlAdID)) {
        location url="#application.mainURL#" addtoken="false";
    }

    // Get UUID of ad
    uuid = application.objAdsBackend.getAdDetails(urlAdID, 2).strUUID;
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

    profileDetail = application.objProfilesFrontend.getWorkerProfile(uuid, backend);
    if(!structKeyExists(profileDetail, "profileID")) {
        location url="#application.mainURL#/fachkraefte-suchen" addtoken="false";
    }

</cfscript>


<cfoutput>
<main>
    <cfif backend>
        <div class="alert alert-important alert-success alert-dismissible" role="alert">
            <h2 class="text-center">Dies ist eine Vorschau!</h2>
        </div>
    </cfif>
    <section>
        <div style="background-color: ##E6F0F2;" class="py-4">
            <div class="container-xl pf-container mx-auto d-flex justify-content-between align-content-center column-gap-4 gap-btw">

                <div id="profile-detail-section">
                    <div class="profile-hero d-md-flex justify-content-start align-items-center column-gap-4">
                        <div>
                            <cfif len(trim(profileDetail.photo))>
                                <img src="/userdata/images/users/#profileDetail.photo#" alt="Foto" class="profile-pic">
                            <cfelse>
                                <iconify-icon icon="bi:person-video" width="12rem" style="color: ##c0c0c0;"></iconify-icon>
                            </cfif>
                        </div>
                        <div class="profile-details pt-md-0 pt-4">
                            <h1>#profileDetail.salutation# #profileDetail.firstName# #profileDetail.lasttName#</h1>
                            <p class="position">#profileDetail.jobTitle#</p>
                            <div class="sub-details pt-4 d-flex">
                                <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                                    <iconify-icon icon="hugeicons:maps"></iconify-icon>
                                    <span>
                                        <cfset totalLocations = arrayLen(profileDetail.locations)>
                                        <cfset locCnt = 0>
                                        <cfloop array="#profileDetail.locations#" index="loc">
                                            <cfset locCnt++>
                                            #loc.name#<cfif locCnt lt totalLocations>, </cfif>
                                        </cfloop>
                                    </span>
                                </div>
                            </div>
                            <div class="sub-details pt-2 d-flex">
                                <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                                    <iconify-icon icon="tabler:contract"></iconify-icon>
                                    <span>#profileDetail.contractType.name#</span>
                                </div>
                            </div>
                            <div class="sub-details pt-2 d-flex">
                                <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                                    <iconify-icon icon="material-symbols:work-outline"></iconify-icon>
                                    <span>#profileDetail.workloadSet#</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        <div class="profile-detail-container py-md-3 container-xl mx-auto d-flex flex-md-row flex-column-reverse justify-content-between align-content-center px-xl-0 gap-btw column-gap-xl-5 column-gap-4">
            <div class="profile-sidebar">

                <!-- Video Section -->
                <cfif len(trim(profileDetail.videoLink))>
                    <cfset videoIframe = application.objAdsFrontend.generateEmbedCode(profileDetail.videoLink)>
                    <cfif len(trim(videoIframe))>
                        <h2>Video</h2>
                        <div class="outer-container pt-3 pb-4">
                            <div class="video-container">
                                #videoIframe#
                            </div>
                        </div>
                    </cfif>
                </cfif>

                <div>
                    <h2>Kontakt</h2>
                    <div class="sidebar-detail py-3">

                        <!--- Adresse --->
                        <cfif len(trim(profileDetail.address))>
                            <div class="d-flex sidebar-detail-list web justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                                <iconify-icon icon="ph:phone-light"></iconify-icon>
                                <span>#profileDetail.address#</span>
                            </div>
                        </cfif>

                        <!--- PLZ/Ort --->
                        <cfif len(trim(profileDetail.zipCity))>
                            <div class="d-flex sidebar-detail-list web justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                                <iconify-icon icon="material-symbols-light:home-outline"></iconify-icon>
                                <span>#profileDetail.zipCity#</span>
                            </div>
                        </cfif>

                        <!--- E-Mail --->
                        <cfif len(trim(profileDetail.email))>
                            <div class="d-flex sidebar-detail-list web justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                                <iconify-icon icon="material-symbols-light:mail-outline"></iconify-icon>
                                <span><a href="mailto:#profileDetail.email#">#profileDetail.email#</a></span>
                            </div>
                        </cfif>

                        <!--- Telefon --->
                        <cfif len(trim(profileDetail.phone))>
                            <div class="d-flex sidebar-detail-list justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                                <iconify-icon icon="ph:phone-light"></iconify-icon>
                                <span>#profileDetail.phone#</span>
                            </div>
                        </cfif>

                        <!--- Mobile --->
                        <cfif len(trim(profileDetail.mobile))>
                            <div class="d-flex sidebar-detail-list justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                                <iconify-icon icon="circum:mobile-2"></iconify-icon>
                                <span>#profileDetail.mobile#</span>
                            </div>
                        </cfif>

                    </div>
                    <div class="pt-3">
                        <h2>Gesuchte Fachgebiete</h2>
                        <div class="skills d-flex pt-2 justify-content-start flex-wrap align-items-center column-gap-2 row-gap-3">
                            <cfloop array="#profileDetail.industries#" index="ind">
                                <span class="skill btn-pill">#ind.name#</span>
                            </cfloop>
                        </div>
                    </div>
                    <div class="pt-4">
                        <h2>Gesuchte Position</h2>
                        <div class="d-flex sidebar-detail-list justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                            <iconify-icon icon="ep:position"></iconify-icon>
                            <span>#profileDetail.jobPosition.name#</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="profile-main-content py-md-3 pt-3">

                <h3 class="h2 pb-4">Profilbeschrieb</h2>

                <div class="description-para">
                    <p>#replace(profileDetail.jobDescription, chr(13), "<br />", "all")#</p>
                </div>

            </div>
        </div>
    </section>
</main>
</cfoutput>