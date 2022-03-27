<cfscript>
    // Exception handling for sef and user id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisModuleID = thiscontent.thisID;
    if(not isNumeric(thisModuleID) or thisModuleID lte 0) {
        location url="#application.mainURL#/sysadmin/modules" addtoken="false";
    }

    qModule = queryExecute(
        options = {datasource = application.datasource},
        params = {
            thisModuleID: {type: "numeric", value: thisModuleID}
        },
        sql = "
            SELECT *
            FROM modules
            WHERE intModuleID = :thisModuleID
        "
    );

    if(not qModule.recordCount){
        location url="#application.mainURL#/sysadmin/modules" addtoken="false";
    }

    param name="url.tab" default="details";
    details = "";
    prices = "";
    switch (url.tab) {
        case "details":
            details = "show active";
            break;
        case "prices":
            prices = "show active";
            break;
    }

    getModal = createObject("component", "com.translate");

</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Edit module</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/modules">Modules</a></li>
                            <li class="breadcrumb-item active">#qModule.strModuleName#</li>
                        </ol>
                    </div>
                    <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="#application.mainURL#/sysadmin/modules" class="btn btn-primary">
                            <i class="fas fa-angle-double-left pe-3"></i> Back to overview
                        </a>
                    </div>

                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="row row-cards">
                                <div class="col-md-12">
                                    <div class="card">
                                        <ul class="nav nav-tabs nav-fill mb-4" data-bs-toggle="tabs">
                                            <li class="nav-item">
                                                <a href="##details" class="nav-link #details#" data-bs-toggle="tab">
                                                    <i class="fas fa-info-circle pe-3"></i>
                                                    Details
                                                </a>
                                            </li>
                                            <li class="nav-item">
                                                <a href="##prices" class="nav-link #prices#" data-bs-toggle="tab">
                                                    <i class="fas fa-coins pe-3"></i>
                                                    Prices
                                                </a>
                                            </li>
                                        </ul>
                                        <div class="card-body">
                                            <div class="tab-content">
                                                <div class="tab-pane #details#" id="details">
                                                    <cfinclude template="module_details.cfm">
                                                </div>
                                                <div class="tab-pane #prices#" id="prices">
                                                    <cfinclude template="module_prices.cfm">
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
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>
