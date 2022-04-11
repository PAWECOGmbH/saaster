<cfscript>
    qCustomers = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT customers.*, countries.strCountryName
            FROM customers
            LEFT JOIN countries ON countries.intCountryID = customers.intCountryID
            WHERE customers.blnActive = 1;
        "
    )

    dump(qCustomers);
</cfscript>

<cfinclude template="/includes/header.cfm">

<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Customers</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">Sysadmin</li>
                            <li class="breadcrumb-item active">Customers</li>
                        </ol>
                    </div>
                    <!---                   
                        <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                            <a href="##" class="btn btn-primary">
                                <i class="fas fa-plus pe-3"></i> Button
                            </a>
                        </div> 
                    --->
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
                        <div class="card-header">
                            <h3 class="card-title">Customers</h3>
                        </div>
                        <div class="card-body">
                            <div class="card">
                                <div class="table-responsive">
                                    <table class="table table-vcenter table-mobile-md card-table">
                                        <thead>
                                            <tr>
                                                <th>Company</th>
                                                <th>Contact</th>
                                                <th>City</th>
                                                <th>Country</th>
                                                <th class="w-1"></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfoutput query="qCustomers">
                                                <tr>
                                                    <td data-label="Name">
                                                        <div class="d-flex py-1 align-items-center">
                                                            <cfif len(trim(strLogo))>
                                                                <img src="#application.mainURL#/userdata/images/logos/#strLogo#" style="margin-right:20px" class="avatar avatar-sm mr-3 align-self-center" alt="#strCompanyName#">
                                                            <cfelse>
                                                                <div style="margin-right:20px" class="avatar avatar-sm mr-3 align-self-center">#left(strCompanyName,2)#</div>
                                                            </cfif>
                                                            <a href="#application.mainURL#/sysadmin/customers/details/#intCustomerID#">
                                                                <div class="flex-fill">
                                                                    <div class="font-weight-medium">#strCompanyName#</div>
                                                                </div>
                                                            </a>
                                                        </div>
                                                    </td>

                                                    <td data-label="Contact">
                                                        <div>#strContactPerson#</div>
                                                        <div class="text-muted"><a href="##" class="text-reset">#strEmail#</a></div>
                                                    </td>

                                                    <td data-label="City">
                                                        #strCity#
                                                    </td>

                                                    <td data-label="Country">
                                                        #strCountryName#
                                                    </td>

                                                    <td>
                                                        <div class="btn-list flex-nowrap">
                                                            <a href="#application.mainURL#/sysadmin/customers/edit/#intCustomerID#" class="btn">
                                                                Edit
                                                            </a>
                                                            <!---   
                                                            <a href="##" class="btn">
                                                                Remove
                                                            </a>
                                                            <div class="dropdown">
                                                                <button class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                                    Actions
                                                                </button>
                                                                <div class="dropdown-menu dropdown-menu-end">
                                                                    <a class="dropdown-item" href="##">
                                                                        Action
                                                                    </a>
                                                                    <a class="dropdown-item" href="##">
                                                                        Another action
                                                                    </a>
                                                                </div>
                                                            </div> 
                                                            --->
                                                        </div>
                                                    </td>
                                                </tr>
                                            </cfoutput>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="card-footer">
                        
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>
