<cfscript>

    if(!structKeyExists(url, "job") or !structKeyExists(session, "customer_id")) {
        location url="#application.mainURL#" addtoken="false";
    }

    jobDetail = application.objAdsFrontend.getAdDetail(url.job);
    if(!structKeyExists(jobDetail, "id")) {
        location url="#application.mainURL#/stelle-suchen" addtoken="false";
    }

    motivationPatternText = application.objAdsFrontend.getMotivationPatternText(url.job, session.user_id);

</cfscript>

<main>
    <cfoutput>
    <section class="mt-4 mb-5 pb-4">
        <div class="container-xl jb-container mx-auto d-flex justify-content-between align-content-center column-gap-4 gap-btw">
            <div class="job-card-container detail-job container-xl mx-auto">
                <div id="job-detail-section">
                    <div class="job-card">
                        <p class="h3">Bewerben Sie sich auf die Stelle als</p>
                        <h1>#jobDetail.jobTitle# (#jobDetail.workloadSet#)</h1>
                        <p>
                            Ergänzen/ändern Sie das Motivationsschreiben nach Ihren Bedürfnissen und klicken Sie dann auf "Bewerbung senden".
                            Wir übermitteln dann dem Arbeitgeber via E-Mail das Motivationsschreiben und Ihre Unterlagen, die Sie im Portal hinterlegt haben.
                        </p>
                    </div>
                </div>
                <form action="#application.mainURL#/frontend/handler/ads" method="post">
                    <input type="hidden" name="application" value="#session.user_id#">
                    <input type="hidden" name="job" value="#jobDetail.uuid#">
                    <input type="hidden" name="mapping" value="#jobDetail.mapping#">
                    <div class="mt-4 mb-4 description">
                        <label class="form-label mb-2">Motivations-/Begleitschreiben:</label>
                        <textarea class="motivation" data-bs-toggle="autosize" name="motivation" placeholder="Schreiben Sie etwas...">#motivationPatternText#</textarea>
                    </div>
                    <div class="mt-4 mb-4 text-center">
                        <button class="btn btn-pill btn-primary fs-3 btn-submit py-3" type="submit">Bewerbung senden</button>
                    </div>
                </form>
            </div>

            <cfinclude template="company_sidebar.cfm">

        </div>
    </section>
    </cfoutput>

</main>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        new TomSelect("#motivation");
    });
</script>