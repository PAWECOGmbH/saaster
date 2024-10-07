<cfscript>

    // Delete search
    if (structKeyExists(url, "del_search")) {
        session.searchData = {};
    }

    // Param the search session in an empty struct
    param name="session.searchData" default={};

    // Default ads array
    arrayProfiles = application.objProfilesFrontend.getProfiles(search = session.searchData);
    totalProfiles = arrayLen(arrayProfiles);

    // Location query
    qLocations = application.objAdsBackend.getLocations();

    // Job industry query
    qIndustries = application.objAdsBackend.getIndustries();

    // Contract types query
    qContractTypes = application.objAdsBackend.getContractTypes();

</cfscript>

<cfoutput>

<main>

    <!-- Hero Section -->
    <section class="bg-color hero-section py-sm-5 py-0">
        <div class="container d-flex flex-md-row flex-column justify-content-between align-items-center w-100 py-md-0 pt-4 pb-4 title-mx">
            <div class="d-flex w-100 flex-column row-gap-sm-2 align-items-start justify-content-start hero-txt">
                <h1 class="lh-base">Suche nach Fachkräften</h1>
                <h2 class="fs-1 pt-sm-0 pt-3 pb-sm-2 pb-4 fw-regular" style="font-weight: 400;">
                    Suchen Sie nach neuen Mitarbeiter:innen mit den gewünschten Fähigkeiten
                </h2>
            </div>
        </div>
    </section>

    <!-- Job Cards -->
    <form class="d-flex filterForm flex-column row-gap-3 column-gap-2 search-form w-100" action="#application.mainURL#/handler/search" method="post">
        <input type="hidden" name="searchDataSpec">
        <section class="job-search-card py-sm-4 py-4 my-3">
            <div class="search-filter">
                <div class="filter-head">
                    <h3>Filter</h3>
                    <cfif isStruct(session.searchData) and !structIsEmpty(session.searchData)>
                        <a href="#application.mainURL#/fachkraefte-suchen?del_search" class="clear-search">
                            <iconify-icon icon="iwwa:delete" width="2rem" height="2rem" title="Filter löschen"></iconify-icon>
                        </a>
                    </cfif>
                </div>
                <div class="d-flex filterForm flex-column row-gap-3 column-gap-2 search-form w-100">
                    <div class="h-auto d-flex align-items-center w-100">
                        <div class="first-select select-wrapper">
                            <div class="select">
                                <select id="locations" name="locationID" multiple="multiple" autocomplete="off" tabindex="-1" placeholder="Ort oder Kanton">
                                    <cfloop query="qLocations">
                                        <cfif structKeyExists(session.searchData, "locationID") and len(trim(session.searchData.locationID))>
                                            <option value="#qLocations.intLocationID#" <cfif listFind(session.searchData.locationID, qLocations.intLocationID)>selected</cfif>>#qLocations.strName#</option>
                                        <cfelse>
                                            <option value="#qLocations.intLocationID#">#qLocations.strName#</option>
                                        </cfif>
                                    </cfloop>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="h-auto d-flex align-items-center w-100">
                        <div class="first-select select-wrapper">
                            <div class="select">
                                <select id="industries" class="form-select" name="industryID" multiple="multiple" autocomplete="off" tabindex="-1" placeholder="Berufsfeld">
                                    <cfloop query="qIndustries">
                                        <cfif structKeyExists(session.searchData, "industryID") and len(trim(session.searchData.industryID))>
                                            <option value="#qIndustries.intIndustryID#" <cfif listFind(session.searchData.industryID, qIndustries.intIndustryID)>selected</cfif>>#qIndustries.strName#</option>
                                        <cfelse>
                                            <option value="#qIndustries.intIndustryID#">#qIndustries.strName#</option>
                                        </cfif>
                                    </cfloop>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="job-type">
                        <h3>Vertragsart</h3>
                        <div class="job-checkbox">
                            <cfloop query="qContractTypes">
                                <cfif structKeyExists(session.searchData, "ctypeID") and listLen(session.searchData.ctypeID)>
                                    <div class="job-box position-relative">
                                        <input type="checkbox" id="#qContractTypes.intContractTypeID#" name="ctypeID" value="#qContractTypes.intContractTypeID#" <cfif listFind(session.searchData.ctypeID, qContractTypes.intContractTypeID)>checked</cfif>>
                                        <label for="#qContractTypes.intContractTypeID#">#qContractTypes.strName#</label>
                                    </div>
                                <cfelse>
                                    <div class="job-box position-relative">
                                        <input type="checkbox" id="#qContractTypes.intContractTypeID#" name="ctypeID" value="#qContractTypes.intContractTypeID#">
                                        <label for="#qContractTypes.intContractTypeID#">#qContractTypes.strName#</label>
                                    </div>
                                </cfif>
                            </cfloop>
                        </div>
                    </div>
                    <button class="btn btn-pill btn-primary fs-3 filter-btn py-1" type="submit">Filter anwenden</button>
                </div>
            </div>
            <div class="w-100">
                <div class="w-100 job-search position-relative container mx-auto">
                    <div class="input-group">
                        <span class="input-group-append">
                            <div class="input-group-text bg-transparent">
                                <iconify-icon icon="basil:search-outline"></iconify-icon>
                            </div>
                        </span>
                        <cfif structKeyExists(session.searchData, "searchQuery") and len(trim(session.searchData.searchQuery))>
                            <input class="form-control" type="text" name="searchQuery" aria-label="Search" value="#session.searchData.searchQuery#">
                        <cfelse>
                            <input class="form-control" type="text" name="searchQuery" placeholder="Beruf, Stichwort oder Name" aria-label="Search">
                        </cfif>
                    </div>

                    <div class="py-4 job-card-container stelle-cards container mx-auto px-xl-0 gap-btw">
                        <h2>#totalProfiles# Profile gefunden</h2>
                        <div class="job-card-flex d-flex flex-column row-gap-3 pt-3">
                            <cfif arrayLen(arrayProfiles)>
                                <cfloop array="#arrayProfiles#" index="profile">
                                    <cfinclude template="/frontend/includes/profile_card.cfm">
                                </cfloop>
                            </cfif>
                        </div>
                    </div>

                </div>
            </div>
        </section>
    </form>
</main>

</cfoutput>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        new TomSelect("#locations");
        new TomSelect("#industries");
    });
</script>