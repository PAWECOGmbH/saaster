<cfscript>

	cfmailparam( name="charset", value="utf-8" );
	cfmailparam( name="MIME-Version", value=1.0 );
	cfmailparam( name="Content-Type", value="text/html; charset=utf-8" );

	param name="variables.mailTitle" default="Title";
	param name="variables.mailContent" default="Content";
	param name="variables.mailType" default="html";

  	// Get customer data
  	customerData = new backend.core.com.sysadmin().getSysAdminData();

</cfscript>

<!DOCTYPE html>
<html>

<head>
  	<title><cfoutput>#variables.mailTitle#</cfoutput></title>

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

		<cfoutput>
			/* BLUE LINKS */
			a.footer {color:###variables.headerFontColor#; text-decoration: none;}

			/* iOS BLUE LINKS */
			.appleBody a {color:###variables.headerFontColor#; text-decoration: none;}
			.appleFooter a {color:###variables.headerFontColor#; text-decoration: none;}

			.mail-btn{
				border-bottom: 10px solid ###variables.buttonBGColor#;
				border-top: 10px solid ###variables.buttonBGColor#;
				border-left: 20px solid ###variables.buttonBGColor#;
				border-right: 20px solid ###variables.buttonBGColor#;
				background-color: ###variables.buttonBGColor#;
				color: ###variables.buttonFontColor#;
				text-decoration: none;
				font-size: #variables.buttonFontSize#;
			}
		</cfoutput>


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

		/* FULL-WIDTH TABLES */
		table[class="responsive-table"]{
			width:100%!important;
		}

		td[class="padding-copy"]{
			padding: 10px 5% 10px 5% !important;
			text-align: left;
		}

		/* ADJUST BUTTONS ON MOBILE */
		td[class="mobile-wrapper"]{
			padding: 10px 5% 15px 5% !important;
		}
		}
  	</style>

</head>

<body style="margin: 0; padding: 0; background-color: #<cfoutput>#variables.mailbodyBGColor#</cfoutput>;">
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<cfoutput>
				<td bgcolor="###variables.mailbodyBGColor#">
					<div align="center" style="padding: 0px 15px 0px 15px;">
						<table border="0" cellpadding="0" cellspacing="0" width="#variables.mailMaxWidthContent#" class="wrapper">
							<tr>
								<td colspan="3" style="padding: 20px 10px 30px 10px;" class="logo">
									<table border="0" cellpadding="0" cellspacing="0" width="100%">
										<tr>
											<td bgcolor="###variables.mailbodyBGColor#" width="100%" align="left">
												<a target="_blank">
													<cfif len(trim(customerData.logo))>
														<img alt="Logo" src="#application.mainURL#/userdata/images/logos/#customerData.logo#" width="200" style="display: block; width: 200px; font-size: 16px;" border="0">
													<cfelse>
														<img alt="Logo" src="#application.mainURL#/dist/img/logo.png" width="200" style="display: block; width: 200px; font-size: 16px;" border="0">
													</cfif>
												</a>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td width="9"></td>
								<td valign="top" bgcolor="#variables.mailContentbgColor#">
									<table border="0" cellpadding="0" cellspacing="0" width="100%">
										<tr>
											<td style="padding: 10px 20px 10px 20px; background-color: ###variables.headerBGColor#; width: 100%; font-family: #variables.fontFamily#; color: ###variables.headerFontColor#; font-size: #variables.fontSizeTitle#px;">#variables.mailTitle#</td>
										</tr>
									</table>
								</td>
								<td width="9"></td>
							</tr>
							<tr>
								<td width="9"></td>
								<cfif variables.MailType eq "html">

									<td align="center" valign="top" bgcolor="###variables.mailContentbgColor#" style="padding: 20px 20px 30px 20px; ">

										<table width="100%" border="0" cellpadding="0" cellspacing="0" class="wrapper" style="font-size: #variables.fontSizeText#px; font-family: #variables.fontFamily#; color: ###variables.fontColorText#;">
											<tr>
												<td style="padding: 0 0 20px 0; font-size: #variables.fontSizeText#px; font-family: #variables.fontFamily#; color: ###variables.fontColorText#; text-decoration: none;">
													#variables.mailContent#
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

	<cfif variables.MailType neq "html">
		<cfoutput>#variables.mailContent#</cfoutput>
	</cfif>

	<cfoutput>

		<table border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="###variables.mailbodyBGColor#">
			<tr>
				<td style="padding: 0px 0 0 0;" bgcolor="###variables.mailbodyBGColor#">
					&nbsp;
				</td>
			</tr>
		</table>

		<table border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td bgcolor="###variables.mailbodyBGColor#">
					<div align="center" style="padding: 0 15px 0 15px;" bgcolor="#variables.headerBGColor#">
						<table border="0" cellpadding="0" cellspacing="0" width="640" class="wrapper">
							<tr>
								<td align="center" bgcolor="#variables.headerBGColor#">
									<table width="100%" cellspacing="0" cellpadding="0" border="0">
										<tr>
											<td valign="top" style="padding: 20px;" class="mobile-wrapper">

												<table cellpadding="0" cellspacing="0" border="0" align="left" width="47%" class="responsive-table">
													<tr>
														<td class="padding-copy" style="padding: 0px 0 0px 0px; font-size: #variables.fontSizeText#px; line-height: 22px; font-family: #variables.fontFamily#; color: ###variables.headerFontColor#; border:none;">
															<span style="font-size: 21px;">#getTrans('txtContact')#</span><br><br>
															#customerData.companyName#<br>
															#customerData.address#<br>
															#customerData.zip# #customerData.city#<br>
															<a href="mailto:#customerData.email#" style="color: ###variables.headerFontColor#; text-decoration:none;">#customerData.email#</a><br>
															<cfif len(trim(customerData.phone))>
																#customerData.phone#
															</cfif>
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