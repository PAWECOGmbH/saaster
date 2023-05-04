
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
            writeOutput("#local.qContent.fieldContent#</textarea>");
        }

        return;

    }


    // Get the text which has to be translated
    public string function textToTranslate() {

        cfquery(name="local.qContent" datasource=application.datasource ) {
            writeOutput("SELECT #variables.thisField# as myField FROM #variables.thisTable# WHERE #variables.thisPrimKey# = #variables.thisID#");
        }

        writeOutput("<p>#local.qContent.myField#</p>");

        return;

    }

    public query function getLanguages(){

        local.qLanguages = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT intLanguageID, strLanguageISO, strLanguageEN, strLanguage, blnDefault, intPrio
                FROM languages
                ORDER BY blnDefault DESC, intPrio
            "
        )
        
        return local.qLanguages;
    }

    public query function searchCustomTranslations(){

        // Custom results
        defaultQueryCustom = "
            SELECT *
            FROM custom_translations
            WHERE strVariable LIKE '%#session.search#%'
        ";
        orListCustom = "";
        orderQryCustom = "
            ORDER BY strVariable
        ";

        qLanguages = getLanguages();

        // Loop over query and append to query string
        loop query=qLanguages {
            orListCustom = listAppend(orListCustom, "OR strString#qLanguages.strLanguageISO# LIKE '%#session.search#%'", " ");
        }

        cfquery(datasource=application.datasource name="qCustomResults") {
            writeOutput(defaultQueryCustom & orListCustom & orderQryCustom);
        }

        return qCustomResults;
    }

    public query function searchSystemTranslations(){

        // System results
        defaultQuerySys = "
        SELECT *
        FROM system_translations
        WHERE strVariable LIKE '%#session.search#%'
        ";
        orListCustom = "";
        orderQrySys = "
            ORDER BY strVariable
        ";

        qLanguages = getLanguages();

        // Loop over query and append to query string
        loop query=qLanguages {
            orListCustom = listAppend(orListCustom, "OR strString#qLanguages.strLanguageISO# LIKE '%#session.search#%'", " ");
        }

        cfquery(datasource=application.datasource name="qSystemResults") {
            writeOutput(defaultQuerySys & orListCustom & orderQrySys);
        }
        
        return qSystemResults;
    }

    public query function getSystemTranslations(){

        local.qSystemResults = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM system_translations
            "
        );

        return local.qSystemResults;
    }

    public query function getCustomTranslations(){

        local.qCustomResults = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM custom_translations
            "
        );

        return local.qCustomResults;
    }


}