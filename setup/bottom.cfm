<cfif not FindNoCase("step3b.cfm", cgi.script_name)>
    </div>
</cfif>
</div>
</body>
</html>

<cfinclude template="/backend/core/views/js.cfm">

<script>
    var select_box_element = document.querySelector('#select_box');
        dselect(select_box_element, {
        search: true
    });
</script>

<cfset structDelete(session, "alert")>