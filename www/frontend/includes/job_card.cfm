<cfoutput>
<div class="job-card">
    <a href="#application.mainURL#/#ad.mapping#">
        <div class="d-flex justify-content-between align-items-start">
            <div class="pe-3">
                <h2>#ad.jobTitle# (#ad.workloadSet#)</h2>
            </div>
            <div class="d-md-flex d-none align-items-center justify-content-between column-gap-3">
                <span class="btn-pill job-btn">Stelle ansehen</span>
            </div>
        </div>
        <div class="sub-details d-flex flex-sm-row flex-column align-items-start justify-content-start column-gap-4 row-gap-3">
            <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                <iconify-icon icon="hugeicons:maps"></iconify-icon>
                <span>
                    <cfset totalLocations = arrayLen(ad.locations)>
                    <cfset locCnt = 0>
                    <cfloop array="#ad.locations#" index="loc">
                        <cfset locCnt++>
                        #loc.name#<cfif locCnt lt totalLocations><cfif locCnt eq 3> ...<cfbreak><cfelse>,</cfif></cfif>
                    </cfloop>
                </span>
            </div>
            <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                <iconify-icon icon="carbon:industry"></iconify-icon>
                <span>
                    <cfset totalIndustries = arrayLen(ad.industries)>
                    <cfset indCnt = 0>
                    <cfloop array="#ad.industries#" index="ind">
                        <cfset indCnt++>
                        #ind.name#<cfif indCnt lt totalIndustries><cfif indCnt eq 3> ...<cfbreak><cfelse>,</cfif></cfif>
                    </cfloop>
                </span>
            </div>
            <div class="detail d-flex align-items-center justify-content-start column-gap-2">
                <iconify-icon icon="tabler:contract"></iconify-icon>
                <span>#ad.contractType.name#</span>
            </div>
        </div>
        <div class="d-flex d-md-none align-items-center justify-content-center column-gap-3 pt-4">
            <span class="btn-pill job-btn">Stelle ansehen</span>
        </div>
    </a>
</div>
</cfoutput>