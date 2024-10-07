<cfoutput>
<div class="profile-card">
    <a href="#application.mainURL#/#profile.mapping#">
        <div class="d-lg-flex justify-content-between align-items-start column-gap-4">
            
                <cfif len(trim(profile.photo))>
                    <div class="image-container">
                        <img src="/userdata/images/users/#profile.photo#" alt="Foto" class="responsive-image">
                    </div>
                <cfelse>
                    <iconify-icon icon="bi:person-video" width="11rem" style="color: ##c0c0c0;"></iconify-icon>
                </cfif>
            
            <div class="w-100 pt-lg-0 pt-4">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <h2>#profile.firstName# #profile.lasttName#</h2>
                        <h3 class="position">#profile.jobTitle#</h3>
                    </div>
                    <div class="d-md-flex d-none align-items-center justify-content-between column-gap-3">
                        <span class="btn-pill job-btn profile-btn">Profil anzeigen</span>
                    </div>
                </div>
                <div class="sub-details pt-3 d-flex flex-sm-row flex-column align-items-start justify-content-start column-gap-4 row-gap-3">
                    <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                        <iconify-icon icon="hugeicons:maps"></iconify-icon>
                        <span>
                            <cfset totalLocations = arrayLen(profile.locations)>
                            <cfset locCnt = 0>
                            <cfloop array="#profile.locations#" index="loc">
                                <cfset locCnt++>
                                    #loc.name#<cfif locCnt lt totalLocations>,<cfif locCnt eq 3>...<cfbreak></cfif>
                                </cfif>
                            </cfloop>
                        </span>
                    </div>
                    <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                        <iconify-icon icon="tabler:contract"></iconify-icon>
                        <span>#profile.contractType.name#</span>
                    </div>
                    <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                        <iconify-icon icon="material-symbols:work-outline"></iconify-icon>
                        <span>#profile.workloadSet#</span>
                    </div>
                </div>
                <div class="skills d-flex pt-4 justify-content-start column-gap-2 flex-wrap">
                    <cfloop array="#profile.industries#" index="ind">
                        <span class="skill btn-pill mb-2">#ind.name#</span>
                    </cfloop>
                </div>
                <div class="d-flex d-md-none align-items-center justify-content-center column-gap-3 pt-4">
                    <span class="btn-pill job-btn profile-btn">Profil anzeigen</span>
                </div>
            </div>
        </div>
    </a>
</div>
</cfoutput>