
<cfscript>

    // Security
    if (planGroupID neq 2) {
        location url="#application.mainURL#/dashboard" addtoken=false;
    }

    objProfile = new backend.myapp.com.profile();
    getProfileAccess = objProfile.getProfileAccess(session.user_id);
    getUploadedFiles = objProfile.getUploadedFiles(session.user_id, session.customer_id);

    getCustomerData = application.objCustomer.getUserDataByID(session.user_id);

    fileList = application.objGlobal.buildAllowedFileLists(variables.documentsFileTypes);
    allowedFileTypesList = fileList.allowedFileTypesList;
    acceptFileTypesList = fileList.acceptFileTypesList;

</cfscript>

<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">Profil verwalten</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item active">Profildetails</li>
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
                    <div class="card-body">
                        <p>
                            Mit Ihrem persönlichen Profil können Sie sich direkt bei interessanten Stellen per Klick bewerben.
                            Ergänzen Sie Ihr Profil, um genügend Informationen für die Firmen anzubieten.
                            Wenn Sie ein passendes Stelleninserat gefunden haben, klicken Sie auf "Bewerben" und wir senden
                            dem Arbeitgeber alle Informationen aus Ihrem Profil. Um sich zu bewerben, müssen Sie auf
                            Stellensuche.ch angemeldet sein.
                        </p>
                        <p class="text-primary">Steigern Sie Ihre Chancen mit einem <a href="#application.mainURL#/employee/ads/new"><u>öffentlichen Jobprofil</u></a>, um von interessierten Firmen gefunden zu werden.</p>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h3 class="card-title">Benutzerdaten</h3>
                                        <div class="card-actions">
                                            <a href="#application.mainURL#/account-settings/my-profile">
                                                Bearbeiten <i class="far fa-edit"></i>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <dl class="row">
                                            <dt class="col-3">Anrede:</dt>
                                            <dd class="col-9">#getCustomerData.strSalutation#</dd>
                                            <dt class="col-3">Vorname:</dt>
                                            <dd class="col-9">#getCustomerData.strFirstName#</dd>
                                            <dt class="col-3">Name:</dt>
                                            <dd class="col-9">#getCustomerData.strLastName#</dd>
                                            <dt class="col-3">E-Mail:</dt>
                                            <dd class="col-9">#getCustomerData.strEmail#</dd>
                                            <dt class="col-3">Telefon:</dt>
                                            <dd class="col-9">#getCustomerData.strPhone#</dd>
                                            <dt class="col-3">Handy:</dt>
                                            <dd class="col-9">#getCustomerData.strMobile#</dd>
                                        </dl>
                                    </div>
                                </div>
                                <div class="card mt-4 mb-4">
                                    <div class="card-header">
                                        <h3 class="card-title">Adresse</h3>
                                        <div class="card-actions">
                                            <a href="#application.mainURL#/account-settings/company">
                                                Bearbeiten <i class="far fa-edit"></i>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <dl class="row">
                                            <dt class="col-3">Strasse:</dt>
                                            <dd class="col-9">#getCustomerData.strAddress#</dd>
                                            <cfif len(trim(getCustomerData.strAddress2))>
                                                <dt class="col-3">Zusatz:</dt>
                                                <dd class="col-9">#getCustomerData.strAddress2#</dd>
                                            </cfif>
                                            <dt class="col-3">PLZ/Ort:</dt>
                                            <dd class="col-9">#getCustomerData.strZIP# #getCustomerData.strCity#</dd>
                                        </dl>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-6">

                                <div class="card">
                                    <div class="card-header">
                                        <h3 class="card-title">Foto</h3>
                                        <div class="card-actions">
                                            <a href="#application.mainURL#/account-settings/my-profile">
                                                Bearbeiten <i class="far fa-edit"></i>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <cfif len(trim(getCustomerData.strPhoto))>
                                            <div class="text-center">
                                                <img src="#application.mainURL#/userdata/images/users/#getCustomerData.strPhoto#" alt="foto" style="max-height: 200px;">
                                            </div>
                                        <cfelse>
                                            Kein Foto vorhanden.
                                        </cfif>
                                    </div>
                                </div>
                                <form action="#application.mainURL#/handler/profile" method="post" enctype="multipart/form-data">
                                    <div class="card mt-4">
                                        <div class="card-body">
                                            <h3 class="card-title">Lebenslauf und andere Dokumente</h3>
                                            <cfif getUploadedFiles.recordCount>
                                                <div class="card">
                                                    <div class="table-responsive">
                                                        <table class="table table-vcenter card-table">
                                                            <thead>
                                                                <tr>
                                                                    <th class="w-1"></th>
                                                                    <th>Dateiname</th>
                                                                    <th>Datum</th>
                                                                    <th class="w-1"></th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <cfloop query="getUploadedFiles">
                                                                    <tr>
                                                                        <td>
                                                                            <cfswitch expression="#listLast(getUploadedFiles.strFile, ".")#">
                                                                            <cfcase value="pdf">
                                                                                <i class="far fa-file-pdf" title="PDF"></i>
                                                                            </cfcase>
                                                                            <cfcase value="pdf">
                                                                                <i class="far fa-file-archive" title="ZIP"></i>
                                                                            </cfcase>
                                                                            <cfcase value="doc,docx">
                                                                                <i class="far fa-file-word" title="Word"></i>
                                                                            </cfcase>
                                                                            <cfcase value="doc,docx">
                                                                                <i class="far fa-file-powerpoint" title="Powerpoint"></i>
                                                                            </cfcase>
                                                                            <cfdefaultcase>
                                                                                #listLast(getUploadedFiles.strFile, ".")#
                                                                            </cfdefaultcase>
                                                                            </cfswitch>
                                                                        </td>
                                                                        <td><a href="#application.mainURL#/userdata/profiledata/#session.user_ID#/#getUploadedFiles.strFile#">#getUploadedFiles.strFile#</a></td>
                                                                        <td>#lsDateTimeFormat(getUploadedFiles.dtmUploadDate, "dd.mm.yyyy HH:MM")#</td>
                                                                        <td><a href="##?" onclick="sweetAlert('warning', '#application.mainURL#/handler/profile?del=#getUploadedFiles.intUploadID#', 'Datei löschen', 'Möchten Sie diese Datei wirklich löschen?', '#getTrans('btnNoCancel')#', '#getTrans('btnYesDelete')#')">Löschen</a></td>
                                                                    </tr>
                                                                </cfloop>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </cfif>
                                            <div class="mt-3">
                                                <p class="text-secondary mb-1">Erlaubt sind .pdf, .zip, .doc, .docx, .ppt und .pptx</p>
                                                <input name="data" required type="file" accept="#allowedFileTypesList#" class="dropify" data-height="90" data-allowed-file-extensions='[#acceptFileTypesList#]' data-max-file-size="5M" />
                                            </div>
                                            <div class="mt-2">
                                                <button name="upload_btn" class="btn btn-primary btn-block">#getTrans('btnUpload')#</button>
                                            </div>
                                        </div>
                                    </div>
                                </form>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>

