<cfset qUser = application.objUser.getAllUsers(session.customer_id)>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper"> 
    <div class="container-xl">
        <cfoutput>               
        <div class="row mb-3">           
            <div class="col-md-12 col-lg-12">
                <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">#getTrans('titUserOverview')#</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                        <li class="breadcrumb-item active">#getTrans('titUserOverview')#</li>
                    </ol>
                </div>                  
                <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">                          
                    <a href="#application.mainURL#/account-settings/user/new" class="btn btn-primary" style="white-space: normal; width: 205px;">
                        <i class="fa fa-address-book pe-3"></i>#getTrans('btnNewUser')#
                    </a>                                                 
                </div> 
            </div>                        
        </div>   
        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>                   
        <div class="row">
            <div class="col-md-12 col-lg-12">
                <div class="card">
                        
                    <div class="table-responsive">
                        <table class="table card-table table-vcenter text-nowrap">
                            <thead >
                                <tr>       
                                    <th>#getTrans('titPhoto')#</th>                                       
                                    <th>#getTrans('formFirstName')#</th>
                                    <th>#getTrans('formName')#</th>
                                    <th>#getTrans('formEmailAddress')#</th>
                                    <th class="text-center">#getTrans('titAdmin')#</th>
                                    <th class="text-center">#getTrans('titActive')#</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                            <cfloop query="qUser">
                                <tr>                                    
                                    <cfif not len(trim(qUser.strPhoto))>
                                        <td>
                                            <span class="avatar avatar-md brround">#ucase(left(qUser.strFirstName,1))##ucase(left(qUser.strLastName,1))#</span>
                                        </td>
                                    <cfelse>
                                        <td>
                                            <img src="#application.mainURL#/userdata/images/users/#qUser.strPhoto#" title="#qUser.strFirstName#" class="avatar avatar-md brround">
                                        </td>     
                                    </cfif>                                                
                                    <td>#qUser.strFirstName#</td>
                                    <td>#qUser.strLastName#</td>
                                    <td>#qUser.strEmail#</td>
                                    <td class="text-center"><cfif qUser.blnAdmin><i class="fa fa-check text-green"></i><cfelse><i class="fa fa-close text-red"></cfif></td>
                                    <td class="text-center"><cfif qUser.blnActive><i class="fa fa-check text-green"></i><cfelse><i class="fa fa-close text-red"></cfif></td>
                                    <td class="text-right" style="padding-left:40px; width: 100px">
                                        <span class="dropdown">
                                            <cfif (qUser.intCustomerID eq session.customer_id or session.superadmin eq 1) and session.user_id neq qUser.intUserID>
                                                <div class="btn-group">
                                                    <button type="button" class="btn dropdown-toggle align-text-top" data-bs-boundary="viewport" data-bs-toggle="dropdown">
                                                        #getTrans('blnAction')#
                                                    </button>
                                                    <div class="dropdown-menu dropdown-menu-end">
                                                        <cfif qUser.intUserID eq session.user_id>
                                                            <a class="dropdown-item" href="#application.mainURL#/account-settings/my-profile">#getTrans('btnEdit')#</a>
                                                        <cfelse>                                                                
                                                            <a class="dropdown-item" href="#application.mainURL#/account-settings/user/edit/#qUser.intUserID#">#getTrans('btnEdit')#</a>
                                                            <a class="dropdown-item" style="cursor: pointer;" onclick="sweetAlert('warning', '#application.mainURL#/user?delete=#qUser.intUserID#', '#getTrans("titDeleteUser")#', '#getTrans("txtDeleteUserConfirmText")#', '#getTrans("btnNoCancel")#', '#getTrans("btnYesDelete")#')">#getTrans('btnDelete')#</a>
                                                            <a class="dropdown-item" href="#application.mainURL#/user?invit=#qUser.intUserID#">#getTrans('btnSendActivLink')#</a>
                                                        </cfif>
                                                    </div>
                                                </div>
                                            </cfif>
                                        </span>    
                                    </td>                                                
                                </tr>
                            </cfloop>
                            <cfif qUser.recordCount lte 1>
                                <!--- Spacer in order to show the action button correctly --->
                                <tr><td colspan="100%"><br></td></tr>
                            </cfif>
                            </tbody>
                        </table>
                    </div>     
                </div>
            </div>
        </div> 
        </cfoutput>               
    </div>
    <cfinclude template="/includes/footer.cfm"> 
</div>
      
 



