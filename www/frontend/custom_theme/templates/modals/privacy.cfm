<cfoutput>
<div id="privacy_policy" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
    <form action="step3.cfm" method="post">
        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">#getTrans('titlePrivacyPolicy')#</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    #getTrans('txtPrivacyPolicy')#
                </div>
            </div>
        </div>
    </form>
</div>
</cfoutput>