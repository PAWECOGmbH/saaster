<cfscript>
    if (cgi.request_method neq "POST" or not structKeyExists(form, "member_action") or not structKeyExists(session, "user_id")
        or not application.objGlobal.csrfVerify()) {
        header statuscode=403 statustext="Forbidden";
        abort;
    }
    if (structKeyExists(form, "member_action")) {
        membershipOrganization = application.objMembershipAccess.organizationForCustomer(session.customer_id);
        try {
            if (listFind("preview,activate", form.member_action)) {
                if (membershipOrganization.enabled or not application.objMembershipAccess.canSetup(session.user_id, membershipOrganization.id)
                    or not isValid("integer", form.ownerID ?: "")) {
                    throw(type = "Saaster.Membership.Forbidden", message = "Setup is not available.");
                }
                if (form.member_action eq "preview") {
                    session.membershipPreviewOwner = form.ownerID;
                } else {
                    application.objMembershipMigration.activate(session.user_id, membershipOrganization.id, form.ownerID, (form.reviewed ?: "") eq "1");
                    structDelete(session, "membershipPreviewOwner");
                    getAlert("msgMembershipActivated", "success");
                }
            } else {
                if (not membershipOrganization.enabled or not isValid("integer", form.userID ?: "")) {
                    throw(type = "Saaster.Membership.Forbidden", message = "Membership administration is not available.");
                }
                switch (form.member_action) {
                    case "resend_invitation":
                        invitationResult = application.objMembership.resendInvitation(session.user_id, membershipOrganization.id, form.userID);
                        getAlert(invitationResult.message, invitationResult.success ? "success" : "danger");
                        break;
                    case "save_member":
                        organizationChanges = {};
                        if (structKeyExists(form, "organization_role") or structKeyExists(form, "organization_status")) {
                            organizationChanges = {role: form.organization_role ?: "", status: form.organization_status ?: ""};
                        }
                        tenantChanges = [];
                        loop collection=form key="membershipField" {
                            if (left(membershipField, 12) eq "tenant_role_") {
                                membershipTenantID = mid(membershipField, 13, len(membershipField));
                                arrayAppend(tenantChanges, {customerID: membershipTenantID, role: form[membershipField],
                                    status: form["tenant_status_" & membershipTenantID] ?: "active"});
                            }
                        }
                        application.objMembership.saveMember(session.user_id, membershipOrganization.id, form.userID, organizationChanges, tenantChanges);
                        break;
                    case "set_org":
                        application.objMembership.setOrganizationMember(session.user_id, membershipOrganization.id, form.userID, form.role ?: "", form.status ?: "");
                        break;
                    case "remove_org":
                        application.objMembership.removeOrganizationMember(session.user_id, membershipOrganization.id, form.userID);
                        break;
                    case "transfer":
                        application.objMembership.transferOwnership(session.user_id, membershipOrganization.id, form.userID);
                        break;
                    case "set_tenant":
                        if (not isValid("integer", form.customerID ?: "") or application.objMembershipAccess.organizationForCustomer(form.customerID).id neq membershipOrganization.id) {
                            throw(type = "Saaster.Membership.Forbidden", message = "The tenant is outside this organization.");
                        }
                        if (len(form.role ?: "")) {
                            application.objMembership.setTenantMember(session.user_id, form.customerID, form.userID, form.role, form.status ?: "");
                        } else {
                            application.objMembership.removeTenantMember(session.user_id, form.customerID, form.userID);
                        }
                        break;
                    default:
                        throw(type = "Saaster.Membership.InvalidValue", message = "Unknown membership action.");
                }
                if (form.member_action neq "resend_invitation") {
                    getAlert("msgMembershipSaved", "success");
                }
            }
        } catch (Saaster.Membership error) {
            getAlert(error.type eq "Saaster.Membership.LastOwner" ? "msgMembershipLastOwner" : "msgMembershipDenied", "warning");
        }
        if (not application.objMembershipAccess.refreshSession()) {
            location url=application.objGlobal.getLink("templates/login.cfm") addtoken=false;
        }
        if ((session.membership_access ?: false) and not application.objMembershipAccess.canManage(session.user_id, session.customer_id)) {
            location url="#application.mainURL#/dashboard" addtoken=false;
        }
        location url="#application.mainURL#/account-settings/memberships" addtoken=false;
    }
</cfscript>
