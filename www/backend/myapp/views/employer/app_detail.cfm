
<cfscript>

    // Security
    if (planGroupID neq 1) {
        location url="#application.mainURL#/dashboard" addtoken=false;
    }

    // Exception handling for sef and user id
    param name="thiscontent.thisID" default=0 type="numeric";
    appID = thiscontent.thisID;

    if(not isNumeric(appID) or appID lte 0) {
        location url="#application.mainURL#/employer/ads" addtoken="false";
    }

    // Get app data
    objAds = new backend.myapp.com.ads();
    appData = objAds.getAppDetails(appID, session.customer_id);
    if(structIsEmpty(appData)){
        location url="#application.mainURL#/employer/ads" addtoken="false";
    }

    //dump(appData);
    //abort;

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
                        <li class="breadcrumb-item"><a href="#application.mainURL#/employer/applications/#appData.adID#">Bewerbungen</a></li>
                        <li class="breadcrumb-item active">#appData.jobTitle#</li>
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
                        <h3 class="card-title">Bewerbung von #appData.firstName# #appData.lastName#</h3>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-8">
                                <h4>Motivationsschreiben:</h4>
                                <div class="card">
                                    <div class="card-body text-secondary">
                                        #replace(appData.appLetter, "#chr(13)#", "<br />", "all")#
                                    </div>
                                    <form action="#application.mainURL#/handler/ads" method="post">
                                        <input type="hidden" name="app" value="#appData.id#">
                                        <div class="card-footer">
                                            <label class="form-check form-switch">
                                                <input class="form-check-input" onchange="this.form.submit()" type="checkbox" name="done" <cfif appData.isDone eq 1>checked</cfif>>
                                                <span class="form-check-label">Bewerbung als erledigt markieren</span>
                                            </label>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <h4>Kontakt:</h4>
                                <div class="card mb-3">
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-lg-5">
                                                <cfif len(trim(appData.salutation))>
                                                    <p class="mb-1">#appData.salutation#</p>
                                                </cfif>
                                                <p class="mb-1">#appData.firstName# #appData.lastName#</p>
                                                <p class="mb-1">#appData.address#</p>
                                                <p class="mb-3">#appData.zip# #appData.city#</p>
                                            </div>
                                            <div class="col-lg-7">
                                                <p class="mb-1">E-Mail: <a href="mailto:#appData.email#">#appData.email#</a></p>
                                                <cfif len(trim(appData.phone))>
                                                    <p class="mb-1">Telefon: #appData.phone#</p>
                                                </cfif>
                                                <cfif len(trim(appData.mobile))>
                                                    <p class="mb-1">Mobile: #appData.mobile#</p>
                                                </cfif>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <h4>Dokumente:</h4>
                                <div class="card">
                                    <div class="card-body">
                                        <cfif isArray(appData.uploads) and arrayLen(appData.uploads)>
                                            <cfloop array="#appData.uploads#" index="doc">
                                                <cfswitch expression="#listLast(doc.fileName, ".")#">
                                                    <cfcase value="pdf">
                                                        <cfset icon = '<i class="far fa-file-pdf" title="PDF"></i>'>
                                                    </cfcase>
                                                    <cfcase value="pdf">
                                                        <cfset icon = '<i class="far fa-file-archive" title="ZIP"></i>'>
                                                    </cfcase>
                                                    <cfcase value="doc,docx">
                                                        <cfset icon = '<i class="far fa-file-word" title="Word"></i>'>
                                                    </cfcase>
                                                    <cfcase value="doc,docx">
                                                        <cfset icon = '<i class="far fa-file-powerpoint" title="Powerpoint"></i>'>
                                                    </cfcase>
                                                    <cfdefaultcase>
                                                        <cfset icon = listLast(doc.fileName, ".")>
                                                    </cfdefaultcase>
                                                </cfswitch>
                                                <ul class="p-0 m-1">
                                                    <a href="#application.mainURL##doc.filePath#" target="_blank">
                                                        <i>#icon#&nbsp;&nbsp;#doc.fileName#</i>
                                                    </a>
                                                </ul>
                                            </cfloop>
                                        <cfelse>
                                            <p class="text-info">Keine Dokumente vorhanden</p>
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>