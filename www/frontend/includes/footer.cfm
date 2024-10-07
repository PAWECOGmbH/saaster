<footer class="pt-sm-5 pt-4 footer">
    <div class="job-card-container container mx-auto px-xl-2 px-sm-3 gap-btw pb-5">
        <div class="row">
            <div class="col-sm-6 col-md-6 col-lg-4 col-xl-3 ps-0 pe-0">
                <div class="row">
                    <a class="navbar-brand ps-0 pe-0" href="/">
                        <img src="/dist/img/logo-web.png" alt="SearchLogo Application" height="65">
                    </a>
                </div>
                <div class="row d-flex flex-column row-gap-3 pt-4">
                    <div class="info ps-0 pe-0">
                        <a href="tel:062 777 45 29"
                            class="d-flex text-white align-items-center justify-content-start column-gap-2">
                            <iconify-icon icon="fluent:call-28-regular"></iconify-icon>
                            <span>062 777 45 29</span>
                        </a>
                    </div>
                    <div class="info ps-0 pe-0">
                        <a href="mailTo:info@stellensuche.ch"
                            class="d-flex text-white align-items-center justify-content-start column-gap-2">
                            <iconify-icon icon="material-symbols:mail-outline"></iconify-icon>
                            <span>info@stellensuche.ch</span>
                        </a>
                    </div>
                    <div class="info ps-0 pe-0">
                        <a href="https://maps.app.goo.gl/XJzj4mRv8qcSxkzi7" target="_blank"
                            class="d-flex text-white align-items-center justify-content-start column-gap-2">
                            <iconify-icon icon="ph:map-pin-fill"></iconify-icon>
                            <span class="d-flex">Sternschnuppen GmbH<br>Postfach 125, 5707 Seengen</span>
                        </a>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-md-6 col-lg-4 col-xl-3 d-flex justify-content-start pt-sm-0 pt-4 ps-0 pe-0">
                <div class="link-head">
                    <h2>Quick links</h2>
                    <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                        <li class="nav-item">
                            <a class="nav-link text-white hover-text fs-3" href="/stelle-suchen">Stelle suchen</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white hover-text fs-3" href="/fachkraefte-suchen">Fachkräfte suchen</a>
                        </li>
                        <cfif structKeyExists(session, "customer_id")>
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/account-settings/plans?g=1">Für Arbeitgeber</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/account-settings/plans?g=2">Für Fachkräfte</a>
                            </li>
                        <cfelse>
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/plans?g=1">Für Arbeitgeber</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/plans?g=2">Für Fachkräfte</a>
                            </li>
                        </cfif>
                    </ul>
                </div>
            </div>
            <div class="col-sm-6 col-md-6 col-lg-4 col-xl-3 d-flex justify-content-start pt-lg-0 pt-4 ps-0 pe-0">
                <div class="link-head">
                    <h2>Information</h2>
                    <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                        <li class="nav-item">
                            <a class="nav-link text-white hover-text fs-3" href="#">Über uns</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white hover-text fs-3" href="#">FAQ</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white hover-text fs-3" href="https://www.sternschnuppen.ch/agb" target="_blank">AGB</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white hover-text fs-3" href="https://www.sternschnuppen.ch/datenschutz" target="_blank">Datenschutz</a>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="col-sm-6 col-md-6 col-lg-4 col-xl-3 pt-xl-0 pt-4 ps-0 pe-0">
                <div class="link-head">
                    <h2>Newsletter</h2>
                    <div class="w-100">
                        <form class="d-flex flex-row row-gap-3 column-gap-2 search-form" role="search">
                            <input class="form-control email-letter" type="email" placeholder="E-Mail-Adresse" aria-label="Search" required>
                            <button class="btn btn-pill btn-primary fs-3 btn-submit py-3" type="submit">Abonnieren</button>
                        </form>
                    </div>
                    <div class="social">
                        <!--- <div class="link-head">
                            <h2>Follow US</h2>
                            <div class="social-icons d-flex align-items-center  justify-content-start">
                                <iconify-icon icon="tabler:brand-twitter"></iconify-icon>
                                <iconify-icon icon="ph:instagram-logo"></iconify-icon>
                                <iconify-icon icon="circum:facebook"></iconify-icon>
                                <iconify-icon icon="prime:twitter"></iconify-icon>
                            </div>
                        </div> --->
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="cc w-100" style="background-color: var(--bg-color);">
        <div class="w-100 container px-xl-0 gap-btw d-flex flex-sm-row flex-column row-gap-3 justify-content-between align-items-center mx-auto py-3">
            <cfoutput>
            <span class="fs-3">© #dateFormat(now(), "yyyy")# Sternschnuppen GmbH</span>
            </cfoutput>
            <div class="d-flex column-gap-sm-2 ">
                <span class="pe-sm-0 pe-1 wir">WIR AKZEPTIEREN&nbsp;</span>
                <img src="/frontend/includes/img/card_bank-transfer.svg" style="max-width: 50px;">
                <img src="/frontend/includes/img/card_twint.svg" style="max-width: 50px;">
                <img src="/frontend/includes/img/card_post-finance-pay.svg" style="max-width: 50px;">
                <img src="/frontend/includes/img/card_mastercard.svg" style="max-width: 50px;">
                <img src="/frontend/includes/img/card_visa.svg" style="max-width: 50px;">
            </div>
        </div>
    </div>
</footer>