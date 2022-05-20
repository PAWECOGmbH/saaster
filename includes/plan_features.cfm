
<cfscript>
planFeatures = objPlans.getPlanFeatures();
</cfscript>

<cfoutput>
<table class="planFeatures">
    <thead>
        <tr>
            <th width="300">&nbsp;</th>
            <cfloop array="#planObj#" index="p">
                <th class="planName">#p.planName#</th>
            </cfloop>
        </tr>
    </thead>
    <tbody>
        <cfloop array="#planFeatures#" index="f">
            <cfset featureID = f.id>
            <tr>
                <cfif f.category>
                    <td class="feat category"><b>#f.name#</b></td>
                <cfelse>
                    <td class="feat feature" data-bs-toggle="tooltip" data-bs-placement="left" title="#f.description#">#f.name#</td>
                </cfif>
                <cfloop array="#planObj#" index="p">
                    <cfif f.category>
                        <td>&nbsp;</td>
                    <cfelse>
                        <cfset thisPlanID = p.planID>
                        <cfset featureContent = objPlans.getFeatureValue(thisPlanID, featureID)>
                        <td>
                            <cfif featureContent.checkmark>
                                <i class="fas fa-check"></i>
                            <cfelse>
                                #replace(featureContent.value, chr(13), "<br />")#
                            </cfif>
                        </td>
                    </cfif>
                </cfloop>
            </tr>
        </cfloop>
    </tbody>
</table>
</cfoutput>