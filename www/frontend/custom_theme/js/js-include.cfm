
<cfoutput>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<cfif fileExists("/frontend/#application.activeTheme#/js/scripts-min.js")>
    <script src="/frontend/#application.activeTheme#/js/scripts-min.js?v=1.0.0"></script>
<cfelse>
    <script src="/frontend/#application.activeTheme#/js/scripts.js"></script>
</cfif>
</cfoutput>