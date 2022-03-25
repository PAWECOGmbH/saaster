<cfif not FindNoCase("step3b.cfm", cgi.script_name)>
    </div>
</cfif>
</div>
</body>
</html>

<script src="../dist/js/tabler.min.js"></script>
<script src="../dist/js/search_select.js"></script>

<script>
    var select_box_element = document.querySelector('#select_box');
        dselect(select_box_element, {
        search: true
    });
</script>

<cfset structDelete(session, "alert")>