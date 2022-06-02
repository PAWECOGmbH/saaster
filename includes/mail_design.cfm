
<cfmailparam name="charset" value="utf-8">
<cfmailparam name="MIME-Version" value="1.0">
<cfmailparam name="Content-Type" value="text/html; charset=utf-8">

<cfparam name="variables.MailTitel" default="MailTitel">
<cfparam name="variables.MailInhalt" default="MailInhalt">
<cfparam name="variables.MailArt" default="html">

<!--- general --->
<cfset MailMaxWidthContent = 660>
<cfset FontFamily = "Arial, Helvetica, sans-serif">
<cfset FontColorTitle = "464646">
<cfset FontColorSubtitle = "464646">
<cfset FontSizeTitle = 21>
<cfset FontSizeSubtitle = 16>
<cfset FontColorText = "464646">
<cfset FontSizeText = 14>
<cfset FontColorTextSmall = "b2b2b2">
<cfset FontSizeTextSmall = 12>

<!--- view in browser --->
<cfset HiddenOnLocalhost = 0>
<cfset FontColorViewInBrowser = "b2b2b2">
<cfset FontSizeViewInBrowser = 12>

<!--- header --->
<cfset HeaderBGColor = "f4f4f4">
<cfset HeaderFontColor = "464646">
<cfset HeaderFontSize = 14>

<!--- buttons --->
<cfset ButtonBGColor = "feda00">
<cfset ButtonFontColor = "016aac">
<cfset ButtonFontSize = 14>

<!DOCTYPE html>
<html lang="de">

<head>
  <title><cfoutput>#variables.MailTitel#</cfoutput></title>

  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width">

  <style type="text/css">
      
    #outlook a{padding:0;} /* Force Outlook to provide a "view in browser" message */
    .ReadMsgBody{width:100%;} .ExternalClass{width:100%;} /* Force Hotmail to display emails at full width */
    .ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div {line-height: 100%;} /* Force Hotmail to display normal line spacing */
    body, table, td, a{-webkit-text-size-adjust:100%; -ms-text-size-adjust:100%;} /* Prevent WebKit and Windows mobile changing default text sizes */
    table, td{mso-table-lspace:0pt; mso-table-rspace:0pt;} /* Remove spacing between tables in Outlook 2007 and up */
    img{-ms-interpolation-mode:bicubic;} /* Allow smoother rendering of resized image in Internet Explorer */

    /* RESET STYLES */
    body{margin:0; padding:0;}
    img{border:0; height:auto; line-height:100%; outline:none; text-decoration:none;}
    table{border-collapse:collapse !important;}
    body{height:100% !important; margin:0; padding:0; width:100% !important;}
    .small{font-size: smaller;}

    /* BLUE LINKS */
    a.footer {color:#ffffff; text-decoration: none;}

    /* iOS BLUE LINKS */
    .appleBody a {color:#666666; text-decoration: none;}
    .appleFooter a {color:#ffffff; text-decoration: none;}

      /* MOBILE STYLES */
    @media screen and (max-width: 525px) {

      /* ALLOWS FOR FLUID TABLES */
      table[class="wrapper"]{
        width:100% !important;
      }

      /* ADJUSTS LAYOUT OF LOGO IMAGE */
      td[class="logo"]{
        text-align: left;
        padding: 20px 0 20px 0 !important;
      }

      td[class="logo"] img{
        margin:0 auto!important;
      }

      /* USE THESE CLASSES TO HIDE CONTENT ON MOBILE */
      td[class="mobile-hide"]{
        display:none;}

      img[class="mobile-hide"]{
        display: none !important;
      }

      img[class="img-max"]{
        max-width: 100% !important;
        height:auto !important;
      }

      /* FULL-WIDTH TABLES */
      table[class="responsive-table"]{
        width:100%!important;
      }

      /* UTILITY CLASSES FOR ADJUSTING PADDING ON MOBILE */
      td[class="padding"]{
        padding: 10px 5% 15px 5% !important;
      }

      td[class="padding-copy"]{
        padding: 10px 5% 10px 5% !important;
        text-align: left;
      }

      td[class="padding-meta"]{
        padding: 30px 5% 0px 5% !important;
        text-align: left;
      }

      td[class="no-pad"]{
        padding: 0 0 20px 0 !important;
      }

      td[class="no-padding"]{
        padding: 0 !important;
      }

      td[class="section-padding"]{
        padding: 50px 15px 50px 15px !important;
      }

      td[class="section-padding-bottom-image"]{
        padding: 50px 15px 0 15px !important;
      }

      /* ADJUST BUTTONS ON MOBILE */
      td[class="mobile-wrapper"]{
          padding: 10px 5% 15px 5% !important;
      }

      table[class="mobile-button-container"]{
          margin:0 auto;
          width:100% !important;
      }
    }	
  </style>

</head>

<body style="margin: 0; padding: 0; background-color: #f4f4f4;">
  <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <cfoutput>		
        <td bgcolor="#HeaderBGColor#">
          <div align="center" style="padding: 0px 15px 0px 15px;">
            <table border="0" cellpadding="0" cellspacing="0" width="#MailMaxWidthContent#" class="wrapper">    
              <tr>
                <td colspan="3" style="padding: 20px 10px 30px 10px;" class="logo">
                  <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                      <td bgcolor="###HeaderBGColor#" width="100%" align="left"><a target="_blank"><img alt="Logo" src="#application.mainURL#/dist/img/logo.png" width="320" style="display: block; font-family: #FontFamily#; color: ###HeaderFontColor#; width: 320px; font-size: 16px;" border="0"></a></td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td width="9"></td>
                <td valign="top" bgcolor="##FFFFFF">
                  <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                      <!--- <td style="padding: 0 0 0 20px; background-color: ##949399;"></td> --->
                      <td style="padding: 10px 20px 10px 20px; background-color: ##337ab7; width: 100%; font-family: #FontFamily#; color: ##ffffff;">#variables.MailTitel#</td>
                    </tr>
                  </table>
                </td>
                <td width="9"></td>
              </tr>
              <tr>
                <td width="9"></td>
                <cfif variables.MailArt eq "html">
                  
                  <td align="center" valign="top" bgcolor="##FFFFFF" style="padding: 20px 20px 30px 20px; ">
                    
                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="wrapper" style="font-size: #HeaderFontSize#px; font-family: #FontFamily#; color: ###HeaderFontColor#;">
                      <tr>
                        <td style="padding: 0 0 20px 0; font-size: #HeaderFontSize#px; font-family: #FontFamily#; color: ###HeaderFontColor#; text-decoration: none;">
                          #variables.MailInhalt#
                        </td>
                      </tr>							
                    </table>
                    
                  </td>
                    
                </cfif>
                <td width="9"></td>
              </tr>
            </table>
          </div>
        </td>
      </cfoutput>	
    </tr>
  </table>

  <cfif variables.MailArt neq "html">
    <cfoutput>#variables.MailInhalt#</cfoutput>
  </cfif>

  <!-- TWO COLUMNS: FOOTER -->
  <cfoutput>

    <table border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="###HeaderBGColor#">
      <tr>
        <td style="padding: 0px 0 0 0;" bgcolor="###HeaderBGColor#">
          &nbsp;
        </td>
      </tr>
    </table>

    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr> 		
        <td bgcolor="###HeaderBGColor#">
          <div align="center" style="padding: 0 15px 0 15px;" bgcolor="##949399">
            <table border="0" cellpadding="0" cellspacing="0" width="640" class="wrapper">
              <tr>
                <td align="center" bgcolor="##337ab7">
                  <table width="100%" cellspacing="0" cellpadding="0" border="0">
                    <tr>
                      <td valign="top" style="padding: 20px;" class="mobile-wrapper">
                        <table cellpadding="0" cellspacing="0" border="0" align="left" width="47%" class="responsive-table">
                          <tr>
                            <td class="padding-copy" style="padding: 0px 0 0px 0px; font-size: #FontSizeText#px; line-height: 0px; font-family: #FontFamily#; color: ##ffffff; border:none;">
                              <span style="font-size: 21px;">KONTAKT</span><br><br>									
                              Muster Firma<br>
                              Muster Strasse<br>
                              Muster PLZ/Ort<br>
                              Muster E-Mail<br>
                            </td>
                            <td style="border-right: 1px solid ##ffffff;" class="mobile-hide"></td>
                          </tr>				
                        </table>

                        <table cellpadding="0" cellspacing="0" border="0" align="right" width="47%" class="responsive-table">
                          <tr>
                            <td class="padding-copy" style="padding: 0px 0 0px 0px; font-size: #FontSizeText#px; line-height: 20px; font-family: #FontFamily#; color: ##ffffff; border:none;">
                              <span style="font-size: 21px;">NETWORK</span><br>
                              <!--- <a href="" class="normal" target="_blank" title="Besuchen Sie uns auf Facebook"><img width="30" src="/img/social/facebook.png" alt="Besuchen Sie uns auf Facebook" border="0"/></a>
                              <img src="/img/spacer.gif" width="2" />   --->                    
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>								
                  </table>
                </td>
              </tr>					
            </table>				
          </div>
        </td>
      </tr>
    </table>
  </cfoutput>
</body>