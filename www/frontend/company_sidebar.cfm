<cfoutput>
<div class="sidebar">
    <div>
        <cfif len(trim(jobDetail.company.logo))>
            <div class="descrip-img py-3">
                <div>
                    <cfif len(trim(jobDetail.company.url_slug))>
                        <a href="#application.mainURL#/#jobDetail.company.url_slug#">
                            <img src="#application.mainURL#/userdata/images/logos/#jobDetail.company.logo#" alt="Logo #jobDetail.company.companyName#">
                        </a>
                    <cfelse>
                        <img src="#application.mainURL#/userdata/images/logos/#jobDetail.company.logo#" alt="Logo #jobDetail.company.companyName#">
                    </cfif>
                </div>
            </div>
        </cfif>
        <div class="sidebar-detail py-2">
            <h1>Information:</h1>
            <div class="pt-3 d-flex flex-column justify-content-start align-items-start row-gap-3 w-100">
                <div class="d-flex sidebar-detail-list  justify-content-start w-100">
                    <span>Position</span>
                    <div class="w-100">#jobDetail.jobPosition.name#</div>
                </div>
                <div class="d-flex sidebar-detail-list  justify-content-start w-100">
                    <span>Offen seit</span>
                    <div class="w-100">#dateFormat(jobDetail.dateStart, "dd.mm.yyyy")#</div>
                </div>
                <div class="d-flex sidebar-detail-list  justify-content-start w-100">
                    <span>Pensum</span>
                    <div class="w-100">#jobDetail.workloadSet#</div>
                </div>
                <div class="d-flex sidebar-detail-list  justify-content-start w-100">
                    <span>Vertragsart</span>
                    <div class="w-100">#jobDetail.contractType.name#</div>
                </div>
                <div class="d-flex sidebar-detail-list  justify-content-start w-100">
                    <span>Stellenantritt</span>
                    <div class="w-100">#jobDetail.jobStarting#</div>
                </div>
            </div>
        </div>
        <div class="sidebar-detail py-3">
            <h1>Arbeitgeber</h1>
            <div
                class="d-flex sidebar-detail-list justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                <iconify-icon icon="ep:location"></iconify-icon>
                <span class="w-100">
                    <cfif len(trim(jobDetail.company.url_slug))>
                        <a href="#application.mainURL#/#jobDetail.company.url_slug#">
                            #jobDetail.company.companyName#<br />
                        </a>
                    <cfelse>
                        #jobDetail.company.companyName#<br />
                    </cfif>
                    #jobDetail.company.address#<br />
                    <cfif len(trim(jobDetail.company.address2))>
                        #jobDetail.company.address2#<br />
                    </cfif>
                    #jobDetail.company.zip# #jobDetail.company.city#
                </span>
            </div>
            <cfif len(trim(jobDetail.company.website)) and isValid("url", jobDetail.company.website)>
                <div class="d-flex sidebar-detail-list web justify-content-start w-100 align-items-start pt-2 column-gap-2 ">
                    <iconify-icon icon="streamline:web"></iconify-icon>
                    <span class="w-100"><a href="#jobDetail.company.website#" target="_blank">#replace(replace(jobDetail.company.website, "http://", ""), "https://", "")#</a></span>
                </div>
            </cfif>
        </div>
    </div>
</div>
</cfoutput>