
<cfscript>

// Environment
variables.environment = "prod" // "dev" or "prod"

// Enter the URL of your live project (incl. http:// or https://)
variables.mainURL = "https://staging.yourdomain.com";

// Password for the Scheduler (url.pass)
variables.schedulePassword = "saaster2024";


// ####################################
//  APPLICATION SETTINGS
// ####################################

// The name of your application.cfc / make sure its unique
variables.applicationname = "saaster_dev";

// Please use the timespan tag directly
variables.sessiontimeout = createTimespan(00,03,00,00);

// You can use "modern" or "classic" for lucee pdf print
variables.pdf_type = "classic";

// RequestTimeout in seconds
variables.requesttimeout = 6000;

// Set allowed image file types
variables.imageFileTypes = ["jpeg","png","jpg","gif","bmp"]; // Svg and webp will not work for image file upload
variables.documentsFileTypes = ["pdf", "zip", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "csv", "mp4", "mov", "mp3"];

// Default meta tags
variables.metaTitle = "The Saaster Company Ltd.";
variables.metaDescription = "This is a demo application using Saaster as a base software";
variables.metaHTML = "";


// ####################################
//  API SETTINGS
// ####################################
variables.apiSecret = "";
variables.apiReloadPassword = "";


// ####################################
//  OPERATOR SETTINGS
// ####################################

// Here you can choose any name
variables.appName = "SaaSTER";

// Enter the name of the operator (Your company)
variables.appOwner = "The SaaSTER Company ltd.";

// From which e-mail address should the system e-mails be sent?
variables.fromEmail = "SaaSTER Company <info@yourdomain.com>";

// Enter the email address of the administrator
variables.toEmail = "info@yourdomain.com";

// Enter an email address for error messages
variables.errorEmail = "error@yourdomain.com";


// ####################################
//  CUSTOMER SETTINGS
// ####################################

// To simulate a customer in local environment, enter a public IP address here.
// variables.usersIP = "62.171.127.255"; // CH
variables.usersIP = "146.70.62.238"; // DE


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
variables.payrexxWebhookPassword = "";

// PSP IDs (comma separated list without spaces)
variables.payrexxPSPs = "";


// ####################################
//  GOOGLE RECAPTCHA V2
// ####################################
variables.reCAPTCHA_site_key = "";
variables.reCAPTCHA_secret = "";


// ####################################
//  Footer text variable
// ####################################

cfsavecontent (variable="variables.footerText") {
    echo("<div><p>Open source software running under the <a href='https://github.com/git/git-scm.com/blob/main/MIT-LICENSE.txt' target='_blank'>MIT license</a> - #dateFormat(now(), 'yyyy')# by #variables.appOwner#</p></div>");
}


// ####################################
//  Email settings
// ####################################

//  General
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
