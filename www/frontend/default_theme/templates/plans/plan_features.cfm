<cfoutput>

<div class="container py-3">

        <h2 class="display-6 text-center mb-4">Compare plans</h2>

        <div class="table-responsive">

            <table class="table table-striped table-bordered align-middle text-center">

                <!--- Plan Names Header --->
                <thead>
                    <tr class="table-secondary">

                        <!--- Empty Cell for Feature Names --->
                        <th class="text-start">Feature</th>

                        <!--- Loop through Plans for Column Headers --->
                        <cfloop array="#planData#" index="p">
                            <th class="fw-bold col">#p.planName#</th>
                        </cfloop>

                    </tr>
                </thead>

                <tbody>

                    <!--- Loop through Features --->
                    <cfloop array="#planFeatures#" index="f">
                        <cfset featureID = f.id>

                        <cfloop group="f.category">

                            <!--- Feature Category Row --->
                            <cfif f.category>

                                <tr class="table-primary">
                                    <td class="fw-bold text-start" colspan="#arrayLen(planData) + 1#">
                                        <strong>#f.name#</strong>
                                    </td>
                                </tr>

                            <cfelse>

                                <!--- Individual Feature Row --->
                                <tr>

                                    <!--- Feature Name --->
                                    <td class="text-start w-50">
                                        <span class="fw-bold">#f.name#</span><br />
                                        <span class="text-muted small d-inline-block text-wrap">#f.description#</span>
                                    </td>

                                    <!--- Feature Values for Each Plan --->
                                    <cfloop array="#planData#" index="p">

                                        <cfset thisPlanID = p.planID>
                                        <cfset featureContent = objPlans.getFeatureValue(thisPlanID, featureID)>

                                        <td>

                                            <cfif len(trim(featureContent.value))>

                                                <!--- Replace newlines with <br> --->
                                                #replace(featureContent.value, chr(13), "<br />")#

                                            <cfelse>

                                                <!--- Checkmark if no value --->
                                                <cfif featureContent.checkmark>
                                                    <i class="bi bi-check-circle text-success"></i>
                                                </cfif>

                                            </cfif>

                                        </td>

                                    </cfloop>

                                </tr>

                            </cfif>

                        </cfloop>

                    </cfloop>

                </tbody>

            </table>

        </div>

</div>

</cfoutput>

