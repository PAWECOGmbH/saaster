
<cfscript>
    arrayAds = application.objAdsFrontend.getAds("dteStart DESC", 5, 0);
</cfscript>

<main>

    <cfoutput>
    <section class="bg-color hero-section">
        <div
            class="container mx-auto d-flex flex-md-row flex-column justify-content-between align-items-center mx-auto px-xl-3 px-sm-3 gap-btw">
            <div class="d-flex w-100 flex-column row-gap-sm-3 align-items-start justify-content-start hero-txt">
                <h1 class="lh-base ">Erfolgreiche Stellensuche!</h1>
                <h2 class="fs-1 pt-sm-1 pt-3 pb-sm-2 pb-4" style="font-weight: 400;">
                    Entdecke deinen Traumjob!
                </h2>
                <div class="w-100">
                    <form class="d-flex flex-sm-row flex-column row-gap-3 column-gap-2 search-form" role="search" action="#application.mainURL#/handler/search" method="post">
                        <input type="hidden" name="searchDataJob">
                        <div class="input-group">
                            <span class="input-group-append">
                                <div class="input-group-text bg-transparent">
                                    <iconify-icon icon="basil:search-outline"></iconify-icon>
                                </div>
                            </span>
                            <input class="form-control me-sm-2" type="text" name="searchQuery" placeholder="Stelle suchen" aria-label="Search" required style="border-radius: 1000px !important;">
                        </div>
                        <button class="btn btn-pill btn-primary fs-3 btn-submit py-3" type="submit">Job suchen</button>
                    </form>
                </div>
            </div>
            <div class="img">
                <img src="/dist/img/headerbild-start.png" alt="Frau im Headerbild">
            </div>
        </div>
    </section>

    <section class="cards-container py-sm-5 pt-4 pb-3">
        <div class="container mx-auto px-xl-0 gap-btw">
            <div class="d-flex justify-content-center align-items-center">
                <div class="row column-gap-0 row-gap-4 justify-content-between">
                    <div class="col-md-6 col-12 ps-0">
                        <div class="row">
                            <div class="card-head">
                                <h2>Für Stellensuchende</h2>
                            </div>
                        </div>
                        <div class="row w-100 row-gap-3">
                            <div class="col-12 col-md-12 col-xl-6">
                                <div class="card">
                                    <h3>Finden Sie die passende Stelle und bewerben Sie sich online</h3>
                                    <h4>Entdecken Sie unsere Stellenangebote und bewerben Sie sich mit einem Klick</h4>
                                    <a class="btn btn-submit fs-3 btn-pill text-white" href="#application.mainURL#/stelle-suchen">Stelle suchen</a>
                                </div>
                            </div>
                            <div class="col-12 col-md-12 col-xl-6">
                                <div class="card">
                                    <h3>Präsentieren Sie sich als Fachkraft auf Stellensuche.ch</h3>
                                    <h4>Lassen Sie sich von potentiellen Arbeitgebern finden, indem Sie Ihr Profil veröffentlichen</h4>
                                    <a class="btn btn-submit fs-3 btn-pill text-white" href="#application.mainURL#/plans?g=2">Profil anlegen</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="last-card-container col-md-6 col-12 ps-0 pe-0">
                        <div class="row">
                            <div class="card-head">
                                <h2>Für Arbeitgeber</h2>
                            </div>
                        </div>
                        <div class="row w-100 row-gap-3">
                            <div class="col-12 col-md-12 col-xl-6">
                                <div class="card">
                                    <h3>Inserieren Sie Ihre offenen Stellen auf Stellensuche.ch</h3>
                                    <h4>Veröffentlichen Sie hier Ihre Stelle und nehmen Sie Bewerbungen direkt online an</h4>
                                    <a class="btn btn-submit fs-3 btn-pill text-white" href="#application.mainURL#/plans?g=1">Inserieren</a>
                                </div>
                            </div>
                            <div class="col-12 col-md-12 col-xl-6">
                                <div class="card">
                                    <h3>Suchen Sie selbst nach interessanten Fachkräften</h3>
                                    <h4>Suchen Sie selbst nach interessanten Mitarbeitern direkt auf Stellensuche.ch</h4>
                                    <a class="btn btn-submit fs-3 btn-pill text-white" href="#application.mainURL#/fachkraefte-suchen">Fachkraft suchen</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="py-4">
        <div class="job-card-container stelle-cards container mx-auto px-xl-2 px-md-3 gap-btw">
            <h2 style="font-weight: 500; font-size: 26px;">Die neusten Stellenangebote</h2>
            <div class="job-card-flex d-flex flex-column row-gap-3 pt-3">
                <cfif arrayLen(arrayAds)>
                    <cfloop array="#arrayAds#" index="ad">
                        <cfinclude template="/frontend/includes/job_card.cfm">
                    </cfloop>
                </cfif>
            </div>
            <div class="w-100 d-flex align-items-center justify-content-center ">
                <a class="btn-pill btn button" href="#application.mainURL#/stelle-suchen">
                    Weitere Stellen anzeigen
                </a>
            </div>
        </div>
    </section>
    </cfoutput>

</main>