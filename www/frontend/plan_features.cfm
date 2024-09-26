
<cfscript>
    planFeatures = objPlans.getPlanFeatures(session.lng);
</cfscript>

<cfoutput>
<div class="d-none d-sm-block">
    <table class="planFeatures">
        <cfloop array="#planFeatures#" index="f">
            <cfset featureID = f.id>
            <cfoutput group="f.category">

                <cfif f.category>
                    <tr class="categorie#featureID#">
                        <td class="feat categoryName">
                            <strong>#f.name#</strong>
                        </td>
                        <cfloop array="#planArray#" index="p">
                            <td class="allPlans planName">#p.planName#</td>
                        </cfloop>
                    </tr>
                <cfelse>
                    <tr>
                        <td class="feat content-td-head"><span data-bs-toggle="tooltip" data-bs-placement="top" title="#f.description#">#f.name#</span></td>

                        <cfloop array="#planArray#" index="p">
                            <cfset thisPlanID = p.planID>
                            <cfset featureContent = objPlans.getFeatureValue(thisPlanID, featureID, session.lng)>

                            <td class="content-td-body">
                                <cfif len(trim(featureContent.value))>
                                    #replace(featureContent.value, chr(13), "<br />")#
                                <cfelse>
                                    <i class="fas fa-check"></i>
                                </cfif>                                
                            </td>
                        </cfloop>
                    </tr>
                </cfif>

            </cfoutput>
        </cfloop>
    </table>
</div>
</cfoutput>