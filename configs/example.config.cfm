
<cfscript>

// ####################################
// DATABASE SETTINGS
// ####################################

variables.datasource = "database";



// ####################################
//  SERVER SETTINGS
// ####################################

// Environment
variables.environment = "dev"; // "dev" or "prod"

// Enter the URL of your live project (incl. http:// or https://)
// Is only used when the environment is set to prod
variables.mainURL = "https://www.saaster.io";

// Password for the Scheduler (url.pass)
variables.schedulePassword = "saaster2022";



// ####################################
//  APPLICATION SETTINGS
// ####################################

// The name of your application.cfc
variables.applicationname = "saaster.io";

// Please use the timespan tag directly
variables.sessiontimeout = createTimespan(00,03,00,00);

// You can use "modern" or "classic" for lucee pdf print
variables.pdf_type = "classic";

// RequestTimeout in seconds
variables.requesttimeout = 60;

// Set allowed image file types
variables.imageFileTypes = ["jpeg","png","jpg","gif","bmp"]; // Svg type will not work for image file upload
variables.documentsFileTypes = ["pdf"];


// ####################################
//  API SETTINGS
// ####################################
variables.apiSecret = "YourExtremlySafeSecret";
variables.apiReloadPassword = "password";


// ####################################
//  OPERATOR SETTINGS
// ####################################

// Here you can choose any name
variables.appName = "SaaSTER";

// Enter the name of the operator (Your company)
variables.appOwner = "The SaaSTER Company ltd.";

// From which e-mail address should the system e-mails be sent?
variables.fromEmail = "SaaSTER Company <info@saaster.io>";

// Enter the email address of the administrator
variables.toEmail = "info@saaster.io";

// Enter an email address for error messages
variables.errorEmail = "error@saaster.io";



// ####################################
//  CUSTOMER SETTINGS
// ####################################

// To simulate a customer in local environment, enter a public IP address here.
variables.usersIP = "62.171.127.255";



// ####################################
//  PAYREXX SETTINGS
// ####################################

// The basic URL to the Payrexx API
variables.payrexxAPIurl = "https://api.payrexx.com/v1.0/";

// Your personal Payrexx instance
variables.payrexxAPIinstance = "";

// Your API key from Payrexx
variables.payrexxAPIkey = "";

// Look and feel of your payment page (id from Payrexx)
variables.payrexxDesignID = "";

// Webhook directory for developing environment
variables.payrexxWebhookDev = "";

// The webhook password that is specified in the url variable
variables.payrexxWebhookPassword = "payrexxSaaster2024";

// PSP IDs (comma separated list without spaces)
variables.payrexxPSPs = "";



// ####################################
//  Footer text variable
// ####################################

cfsavecontent (variable="variables.footerText") {
    echo("<div><p>Open source software running under the <a href='https://github.com/PAWECOGmbH/saaster/blob/main/LICENSE' target='_blank'>MIT license</a> - #dateFormat(now(), 'yyyy')# by #variables.appOwner#</p></div>");
}



// ####################################
//  Email settings
// ####################################

//  Generel
variables.mailMaxWidthContent = 660;
variables.fontFamily = "Arial, Helvetica, sans-serif";
variables.fontColorTitle = "464646";
variables.fontColorSubtitle = "464646";
variables.fontSizeTitle = 21;
variables.fontSizeSubtitle = 16;
variables.fontColorText = "464646";
variables.fontSizeText = 14;
variables.fontColorTextSmall = "b2b2b2";
variables.fontSizeTextSmall = 12;

//  Header
variables.headerBGColor = "f4f4f4";
variables.headerFontColor = "464646";
variables.headerFontSize = 14;

//  Buttons
variables.buttonBGColor = "feda00";
variables.buttonFontColor = "016aac";
variables.buttonFontSize = 14;


</cfscript>
