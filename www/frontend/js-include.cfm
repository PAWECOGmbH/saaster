<script src="https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta17/dist/js/tabler.min.js"></script>

<cfif fileExists("/frontend/dist/js/frontend-min.js")>
    <script src="/frontend/dist/js/frontend-min.js?v=1.0.0"></script>
<cfelse>
    <script src="/frontend/dist/js/frontend.js"></script>
</cfif>