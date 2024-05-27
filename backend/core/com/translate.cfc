
component displayname="translate" accessors="true" {

    public any function args(required string thisTable, required string thisField, required numeric thisID, numeric maxLength) {

        param name="arguments.maxLength" default="";

        variables.thisTable = arguments.thisTable;
        variables.thisField = arguments.thisField;
        variables.thisID = arguments.thisID;
        variables.maxLength = arguments.maxLength;
        variables.thisPrimKey = application.objGlobal.getPrimaryKey(arguments.thisTable);

        return this;

    }


    // Open a modal
    public string function openModal(required string modalName, required string redirect, string modalTitle, boolean itsEditor) {

        param name="arguments.modalTitle" default="Translate content";
        param name="arguments.itsEditor" default=0;

        local.transTable = variables.thisTable & "_trans";

        savecontent variable="getModal" {

            writeOutput("
            <div id='#arguments.modalName#_#variables.thisID#' class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
            <form action='#application.mainURL#/sysadm/languages' method='post'>
            <input type='hidden' name='modal_lng'>
            <input type='hidden' name='table' value='#local.transTable#'>
            <input type='hidden' name='field' value='#variables.thisField#'>
            <input type='hidden' name='id' value='#variables.thisID#'>
            <input type='hidden' name='key' value='#variables.thisPrimKey#'>
            <input type='hidden' name='referer' value='#arguments.redirect#'>
            <div class='modal-dialog modal-lg modal-dialog-centered' role='document'>
            <div class='modal-content'>
            <div class='modal-header'>
            <h5 class='modal-title'>#arguments.modalTitle#</h5>
            <button type='button' class='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>
            </div>
            <div class='modal-body'>")

            writeOutput(textToTranslate());
            writeOutput(transFields(arguments.itsEditor));

            writeOutput("
            </div>
            <div class='modal-footer'>
            <a href='##' class='btn btn-link link-secondary' data-bs-dismiss='modal'>Cancel</a>
            <button type='submit' class='btn btn-primary ms-auto'>Save changes</button>
            </div>
            </div>
            </div>
            </form>
            </div>")

        }

        return getModal;

    }


    private string function transFields(boolean itsEditor) {

        param name="arguments.itsEditor" default=0;

        local.itsEditor = "";
        local.transTable = variables.thisTable & "_trans";

        // Loop over existing languages exept the default language
        local.getLng = application.objLanguage.getAllLanguages('WHERE blnDefault = 0');


        loop query = local.getLng {
            if (arguments.itsEditor eq 1) {
                local.itsEditor = "editor";
            }
            writeOutput("<div class='hr-text hr-text-left my-3 mt-4'>#local.getLng.strLanguageEN#</div>");
            if (isNumeric(variables.maxLength)) {
                writeOutput("<textarea class='form-control #local.itsEditor#'  name='text_#local.getLng.strLanguageISO#' maxlength='#variables.maxLength#' rows='3' placeholder='Translate to #lcase(local.getLng.strLanguageEN)#'>");
            } else {
                writeOutput("<textarea class='form-control #local.itsEditor#' name='text_#local.getLng.strLanguageISO#' rows='3' placeholder='Translate to #lcase(local.getLng.strLanguageEN)#'>");
            }

            cfquery(name="local.qContent" datasource=application.datasource ) {
                writeOutput("SELECT #variables.thisField# as fieldContent FROM #local.transTable# WHERE #variables.thisPrimKey# = #variables.thisID# AND intLanguageID = '#local.getLng.intLanguageID#'");
            }
            local.replacedCode = replace(local.qContent.fieldContent, "invalidTag", "meta", "all");
            local.replacedCode = replaceList(local.replacedCode, "<,>", "&lt;,&gt;");
            writeOutput("#local.replacedCode#</textarea>");
        }

        return;

    }


    // Get the text which has to be translated
    public string function textToTranslate() {

        cfquery(name="local.qContent" datasource=application.datasource ) {
            writeOutput("SELECT #variables.thisField# as myField FROM #variables.thisTable# WHERE #variables.thisPrimKey# = #variables.thisID#");
        }

        local.replacedCode = replaceList(local.qContent.myField, "<,>", "&lt;,&gt;");
        local.replacedCode = replace(local.replacedCode, "#chr(13)#", "<br />", "all");
        writeOutput(local.replacedCode);

        return;

    }

}