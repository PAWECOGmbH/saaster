
<cfscript>

    // Security
    if (planGroupID neq 1) {
        location url="#application.mainURL#/dashboard" addtoken=false;
    }

    objAds = new backend.myapp.com.ads();
    qLocations = objAds.getLocations();
    qContractTypes = objAds.getContractTypes();
    qIndustries = objAds.getIndustries();
    qPositions = objAds.getJobPositions();

</cfscript>


<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">Inserateverwaltung</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/employer/ads">Inserate</a></li>
                        <li class="breadcrumb-item active">Inserat erfassen</li>
                    </ol>
                </div>

            </div>
        </div>
        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>
    </div>
    <div class="#getLayout.layoutPage#">
        <div class="row">
            <div class="col-lg-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Erstellen Sie ein neues Inserat</h3>
                    </div>
                    <form action="#application.mainURL#/handler/ads" method="post">
                        <input type="hidden" name="new_ad">
                        <input type="hidden" name="typeID" value="1">
                        <div class="card-body">

                            <div class="row pt-3">
                                <div class="col-lg-6">
                                    <div class="mb-3">
                                        <label class="form-label">Titel der Stelle:</label>
                                        <input type="text" class="form-control" name="title" placeholder="Vergeben Sie einen aussagekräftigen Titel" minlength="10" maxlength="250" required>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="mb-3 pt-4 small text-muted">
                                        z. Bsp. <em>Florist*in mit eidg. Fachausweis</em><br />
                                        Tipp: Lassen Sie das Pensum im Titel weg, dies wird automatisch vom System hinzugefügt.
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-6">
                                    <div class="mb-3">
                                        <label class="form-label">Position:</label>
                                        <select class="form-select" name="positionID" required>
                                            <option></option>
                                            <cfloop query="qPositions">
                                                <option value="#qPositions.intJobPositionID#">#qPositions.strName#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="mb-3 pt-4 small text-muted">
                                        Wählen Sie die gewünschte Position.
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-6">
                                    <div class="mb-3">
                                        <label class="form-label">Branche/Arbeitsfeld:</label>
                                        <select id="industries" class="form-select" name="industryID" multiple autocomplete="off" tabindex="-1" required>
                                            <cfloop query="qIndustries">
                                                <option value="#qIndustries.intIndustryID#">#qIndustries.strName#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="mb-3 pt-4 small text-muted">
                                        Wählen Sie eine oder mehrere Branchen.<br />
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-6">
                                    <div class="mb-3">
                                        <label class="form-label">Vertragsart:</label>
                                        <select class="form-select" name="ctypeID" required>
                                            <option></option>
                                            <cfloop query="qContractTypes">
                                                <option value="#qContractTypes.intContractTypeID#">#qContractTypes.strName#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="mb-3 pt-4 small text-muted">
                                        Wählen Sie die gewünschte Vertragsart.
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-6">
                                    <div class="mb-3">
                                        <label class="form-label">Pensum:</label>
                                        <div class="row">
                                            <div class="col-lg-4 d-flex align-items-center">
                                                <div class="me-2">
                                                    <nobr>Von:</nobr>
                                                </div>
                                                <div class="flex-grow-1 me-2">
                                                    <input type="text" class="form-control" name="min" maxlength="3" placeholder="100" required id="minInput" oninput="validateWorkload('minInput')">
                                                </div>
                                                <div>
                                                    %
                                                </div>
                                            </div>
                                            <div class="col-lg-4 d-flex align-items-center">
                                                <div class="me-2">
                                                    <nobr>Bis:</nobr>
                                                </div>
                                                <div class="flex-grow-1 me-2">
                                                    <input type="text" class="form-control" name="max" maxlength="3" placeholder="100" required id="maxInput" oninput="validateWorkload('maxInput')">
                                                </div>
                                                <div>
                                                    %
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="mb-3 pt-4 small text-muted">
                                        Geben Sie das Pensum an, z. Bsp. von 80 bis 100.
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-6">
                                    <label class="form-label">Arbeitsort:</label>
                                    <select id="locations" class="form-select" name="locationID" multiple autocomplete="off" tabindex="-1" required>
                                        <cfloop query="qLocations">
                                            <option value="#qLocations.intLocationID#">#qLocations.strName#</option>
                                        </cfloop>
                                    </select>
                                </div>
                                <div class="col-lg-4">
                                    <div class="mb-3 pt-4 small text-muted">
                                        Wählen Sie einen oder mehrere Arbeitsorte.<br />
                                        Tipp: Schreiben Sie die ersten Buchstaben der gewünschten Ortschaft.
                                    </div>
                                </div>
                            </div>

                            <div class="row pt-3">
                                <div class="col-lg-6">
                                    <div class="mb-3">
                                        <label class="form-label">Stellenantritt:</label>
                                        <input type="text" class="form-control" name="jobstarting" placeholder="Per sofort oder nach Vereinbarung" maxlength="100" required>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="mb-3 pt-4 small text-muted">
                                        Geben Sie hier an, per wann die Stelle zu besetzen ist.
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-6">
                                    <div class="mb-3">
                                        <label class="form-label">Stellenbeschrieb:</label>
                                        <textarea class="form-control editor_small" name="description" style="height: 400px;" placeholder="Schreiben Sie etwas..." required></textarea>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="mb-3 pt-4 small text-muted">
                                        Schreiben Sie den Text zur offenen Stelle.
                                    </div>
                                </div>
                            </div>

                            <div class="row pt-3">
                                <div class="col-lg-6">
                                    <div class="mb-3">
                                        <label class="form-label">Videolink (optional, Youtube oder Vimeo):</label>
                                        <input type="text" class="form-control" name="video" maxlength="100">
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="mb-3 pt-4 small text-muted">
                                        Sie können bei Bedarf ein Video aus Youtube oder Vimeo hinterlegen. Setzen Sie einfach den Link des Videos hier ein.
                                    </div>
                                </div>
                            </div>

                            <div class="row pt-3">
                                <div class="col-lg-6">
                                    <div class="mb-3">
                                        <label class="form-check form-switch">
                                            <input type="checkbox" class="form-check-input" name="application" checked>
                                            <span class="form-check-label">Bewerbungen via Stellensuche.ch zulassen</span>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div class="col-lg-6 mt-4 mb-3">
                                <button type="submit" id="submit_button" class="btn btn-primary">Inserat speichern</button>
                            </div>

                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>

<script>

    document.addEventListener('DOMContentLoaded', function() {

        new TomSelect("#locations");
        new TomSelect("#industries");

    });

</script>