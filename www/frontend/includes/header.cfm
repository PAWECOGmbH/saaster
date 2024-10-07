<header class="header" id="mainHeader">
    <nav class="navbar navbar-expand-lg navbar-bg text-white" style="z-index: 5;">
        <div
            class="container mx-auto d-flex justify-content-between align-items-center py-md-2 py-0 mx-auto px-0">
            <div class="d-flex justify-content-between align-items-center navBar-width z-2 px-0 logo-mx">
                <div class="d-flex align-items-center column-gap-4">
                    <a class="navbar-brand" href="/">
                        <img src="/dist/img/logo-web.png" alt="SearchLogo Application" class="nav-logo">
                    </a>
                    <div class="d-lg-flex d-none">
                        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/stelle-suchen">Stelle suchen</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/fachkraefte-suchen">Fachkräfte suchen</a>
                            </li>
                        </ul>
                    </div>
                </div>
                <div class="d-lg-flex d-none justify-content-center  align-items-center column-gap-2 buttonLogin-me">
                    <cfif structKeyExists(session, "customer_id")>
                        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/account-settings/plans?g=1">Für Arbeitgeber</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/account-settings/plans?g=2">Für Fachkräfte</a>
                            </li>
                        </ul>
                    <cfelse>
                        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/plans?g=1">Für Arbeitgeber</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white hover-text fs-3" href="/plans?g=2">Für Fachkräfte</a>
                            </li>
                        </ul>
                    </cfif>
                    <div class="d-flex column-gap-3 btn-flex">
                        <cfif structKeyExists(session, "customer_id")>
                            <a href="/dashboard" class="btn custom-btn-style btn-pill btn-outline-primary btn-lg text-white">
                                Dashboard
                            </a>
                        <cfelse>
                            <a href="/login" class="btn custom-btn-style btn-pill btn-outline-primary btn-lg text-white">
                                Login
                            </a>
                        </cfif>
                    </div>
                </div>
            </div>
            <button class="navbar-toggler text-white buttonBurger-me" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false"
                aria-label="Toggle navigation">
                <span class="navbar-toggler-icon fs-2"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <div class="pt-3 pb-4 d-flex justify-content-end custom-ui">
                    <div class="px-3 mx-5"> 
                        <ul class="navbar-nav me-auto mb-3 mb-lg-0 px-0">
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
                    
                        <div class="d-flex flex-column align-items-start justify-content-start row-gap-3 btn-flex w-100">
                            <cfif structKeyExists(session, "customer_id")>
                                <a href="/dashboard" class="btn custom-btn-style btn-pill btn-outline-primary btn-lg text-white">
                                    Dashboard
                                </a>
                            <cfelse>
                                <a href="/login" class="btn custom-btn-style btn-pill btn-outline-primary btn-lg text-white">
                                    Login
                                </a>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </nav>
    <div class="opacity"></div>
</header>