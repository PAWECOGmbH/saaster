<!doctype html>
<html>
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
        <meta http-equiv="X-UA-Compatible" content="ie=edge"/>
        <title>Error</title>
        <link href="./dist/css/tabler.min.css" rel="stylesheet"/>
    </head>

    <cfoutput>
        <cfparam  name="darkTheme" default="">

        <cfif getLayout.layoutBody neq "">
            <cfset darkTheme = "theme-dark">
        </cfif>

        <body  class="d-flex flex-column #darkTheme#">
            <div class="page page-center">
                <div class="container-tight py-4">
                    <div class="empty">
                        <div class="empty-header">500</div>
                        <p class="empty-title">Oops…</p>

                        <p class="empty-subtitle text-muted">
                            #application.objLanguage.getTrans('txtTechInform')#
                        </p>

                        <div class="empty-action">
                            <cfif structKeyExists(session, "customer_id")>
                                <a href="./dashboard" class="btn btn-primary">
                                    #application.objLanguage.getTrans('txtTakeBack')#
                                </a>
                            <cfelse>
                                <a href="./" class="btn btn-primary">
                                    #application.objLanguage.getTrans('txtTakeBack')#
                                </a>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </body>
    </cfoutput>
</html>