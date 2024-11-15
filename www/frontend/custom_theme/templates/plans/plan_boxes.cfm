<cfoutput>
<div class="container py-3">
    <main>
        <div class="row row-cols-1 row-cols-md-4 mb-3 text-center">

            <!--- Include of the boxes --->
            <cfloop array="#planData#" index="i">
                <cfinclude template="box.cfm">
            </cfloop>

        </div>
    </main>
</div>
</cfoutput>