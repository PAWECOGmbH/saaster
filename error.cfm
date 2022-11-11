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
                            <a href="./dashboard" class="btn btn-primary">
                                <svg xmlns="http://www.w3.org/2000/svg" class="icon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><line x1="5" y1="12" x2="19" y2="12" /><line x1="5" y1="12" x2="11" y2="18" /><line x1="5" y1="12" x2="11" y2="6" /></svg>
                                #application.objLanguage.getTrans('txtTakeBack')#
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </body>
    </cfoutput>
</html>