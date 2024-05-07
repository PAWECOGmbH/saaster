<cfscript>

    objInvoices = new backend.core.com.invoices();

    // If the download is called up by e-mail
    if (structKeyExists(url, "pdf")) {

        // Get the invoiceID
        qInvoice = objInvoices.getInvoice(url.pdf);

        if (qInvoice.recordCount) {
            thiscontent.thisID = qInvoice.intInvoiceID;
        } else {
            getAlert('alertNotValidAnymore', 'warning');
            location url="#application.mainURL#/login" addtoken="false";
        }

    }

    // Exception handling for the invoice id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisInvoiceID = thiscontent.thisID;
    if(not isNumeric(thisInvoiceID) or thisInvoiceID lte 0) {
        location url="#application.mainURL#/login" addtoken="false";
    }

    // Get the invoice data
    getInvoiceData = objInvoices.getInvoiceData(thisInvoiceID);
    if(not isStruct(getInvoiceData) or !structKeyExists(getInvoiceData, "customerID") or getInvoiceData.customerID eq 0) {
        location url="#application.mainURL#/login" addtoken="false";
    }

    // Is the user allowed to see this invoice
    if (structKeyExists(session, "customer_id")) {
        if (!session.sysadmin) {
            checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, getInvoiceData.customerID);
            if(not checkTenantRange) {
                location url="#application.mainURL#/dashboard" addtoken="false";
            }
        }
    }

    getTime = new backend.core.com.time(getInvoiceData.customerID);
    addressBlock = objInvoices.getInvoiceAddress(thisInvoiceID);
    qPayments = objInvoices.getInvoicePayments(thisInvoiceID);

    // Get customer data
    customerData = application.objCustomer.getCustomerData(getInvoiceData.customerID);

    // Get sysadmin data
    sysAdminData = application.objSysadmin.getSysAdminData();

    // Generate UUID for the pdf name
    pdfName = "invoice-" & replace(lcase(getInvoiceData.number), " ", "", "all") & "-" & dateTimeFormat(getTime.utc2local(now()), "yyyymmddHHNNSS");

    // If Swiss QR invoice is activated
    swissQrInvoice = false;
    if (application.objSysadmin.getSystemSetting('settingSwissQrBill').strDefaultValue eq 1) {

        swissQrInvoice = true;

        qrStruct = objInvoices.setSwissQrInvoiceStruct(getInvoiceData.customerID, getInvoiceData.amountOpen, getInvoiceData.currency, getInvoiceData.number);
        swissQrSlip = new backend.core.com.swissqrbill().generateSwissBill(qrStruct, "variable");        

    }

</cfscript>

<!--- Save the HTML part into a variable --->
<cfsavecontent variable="invoiceData">
    <cfoutput>
    <head>
        <title>#getInvoiceData.title#</title>
    </head>
    <body style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; line-height: 18px;">
        <table width="100%" border="0">
            <tr>
                <td align="right" height="100" valign="top">
                    <cfif len(trim(sysAdminData.logo))>
                        <img alt="Logo" src="#application.mainURL#/userdata/images/logos/#sysAdminData.logo#" style="display: block; max-width: 180px; font-size: 16px;" border="0">
                    <cfelse>
                        <img alt="Logo" src="#application.mainURL#/dist/img/logo.png" style="display: block; max-width: 180px; font-size: 16px;" border="0">
                    </cfif>
                </td>
            </tr>
            <tr>
                <td height="150" valign="top" style="font-family: Arial, Helvetica, sans-serif; font-size: 12px;">
                    #addressBlock#
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px solid ##ccc; padding-bottom: 5px;">
                    <b>#getTrans('titInvoice')# #getInvoiceData.number#</b>
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px solid ##ccc; padding-bottom: 5px; font-size: 12px;">
                    <b>#getInvoiceData.title#</b>
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px solid ##ccc; padding-bottom: 5px;">
                    <table width="100%" border="0">
                        <tr>
                            <td width="20%">
                                #getTrans('titInvoiceDate')#:<br />
                                #getTrans('txtDueDate')#:
                            </td>
                            <td width="30%">
                                #lsDateFormat(getTime.utc2local(utcDate=getInvoiceData.date))#<br />
                                #lsDateFormat(getTime.utc2local(utcDate=getInvoiceData.dueDate))#
                            </td>
                            <td width="50%" valign="top">
                                #replace(customerData.billingInfo, chr(13), "<br />", "all")#
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr><td style="padding: 5px;"></td></tr>
            <tr>
                <td>
                    <table width="100%" border="0" style="border-collapse: collapse;">
                        <tr>
                            <td width="5%" style="border-bottom: 1px solid ##ccc; font-size: 10px;">#getTrans('titPos')#</td>
                            <td width="45%" style="border-bottom: 1px solid ##ccc; font-size: 10px;">#getTrans('titDescription')#</td>
                            <td width="15%" style="border-bottom: 1px solid ##ccc; font-size: 10px;" align="right">#getTrans('titQuantity')#</td>
                            <td width="15%" style="border-bottom: 1px solid ##ccc; font-size: 10px;" align="right">#getTrans('titSinglePrice')#</td>
                            <td width="10%" style="border-bottom: 1px solid ##ccc; font-size: 10px;" align="right">#getTrans('titDiscount')#</td>
                            <td width="10%" style="border-bottom: 1px solid ##ccc; font-size: 10px;" align="right">#getTrans('titTotal')# #getInvoiceData.currency#</td>
                        </tr>
                        <cfloop array="#getInvoiceData.positions#" index="pos">
                            <tr>
                                <td valign="top" style="border-bottom: 1px solid ##ccc;">#pos.posNumber#</td>
                                <td valign="top" style="border-bottom: 1px solid ##ccc;">
                                    <b>#pos.title#</b><br />
                                    #pos.description#
                                </td>
                                <td valign="top" align="right" style="border-bottom: 1px solid ##ccc;">#lsCurrencyFormat(pos.quantity, "none")# #pos.unit#</td>
                                <td valign="top" align="right" style="border-bottom: 1px solid ##ccc;">
                                    #lsCurrencyFormat(pos.singlePrice, "none")#
                                    <cfif pos.vat gt 0>
                                        <br />
                                        <span style="font-size: 9px; color: ##ccc;">(#pos.vat#%)</span>
                                    </cfif>
                                </td>
                                <td valign="top" align="right" style="border-bottom: 1px solid ##ccc;"><cfif pos.discountPercent gt 0>#pos.discountPercent#%</cfif></td>
                                <td valign="top" align="right" style="border-bottom: 1px solid ##ccc;">#lsCurrencyFormat(pos.totalPrice, "none")#</td>
                            </tr>
                        </cfloop>
                        <tr>
                            <td></td>
                            <td colspan="4"><b>#getTrans('titTotal')#</b></td>
                            <td align="right"><b>#lsCurrencyFormat(getInvoiceData.subtotal, "none")#</b></td>
                        </tr>
                        <cfif arrayLen(getInvoiceData.vatArray)>
                            <tr><td colspan="6"></td></tr>
                            <cfloop array="#getInvoiceData.vatArray#" index="vat">
                                <tr>
                                    <td></td>
                                    <td colspan="4" style="font-size: 10px;">#vat.vatText#</td>
                                    <td align="right">#lsCurrencyFormat(vat.amount, "none")#</td>
                                </tr>
                            </cfloop>
                            <tr><td colspan="100%"></td></tr>
                        </cfif>
                        <tr>
                            <td style="border-top: 1px solid ##ccc; padding: 5px 0;"></td>
                            <td style="border-top: 1px solid ##ccc; padding: 5px 0;" colspan="4"><b>#getInvoiceData.totaltext#</b></td>
                            <td style="border-top: 1px solid ##ccc; padding: 5px 0;" align="right"><b>#lsCurrencyFormat(getInvoiceData.total, "none")#</b></td>
                        </tr>

                        <cfif qPayments.recordCount>
                            <cfloop query="qPayments">
                                <tr>
                                    <td style="border-top: 1px solid; padding: 5px 0;"></td>
                                    <td style="border-top: 1px solid; padding: 5px 0;" colspan="4">#getTrans('txtIncoPayments')# #lsDateFormat(getTime.utc2local(utcDate=qPayments.dtmPayDate))# (#qPayments.strPaymentType#):</td>
                                    <td style="border-top: 1px solid; padding: 5px 0;" class="text-end pr-0" align="right">- #lsCurrencyFormat(qPayments.decAmount, "none")#</td>
                                </tr>
                            </cfloop>

                            <tr>
                                <td style="border-top: 1px solid ##ccc;"></td>
                                <td style="border-top: 1px solid ##ccc;" colspan="4"><b>#getTrans('txtRemainingAmount')#</b></td>
                                <td style="border-top: 1px solid ##ccc;" class="text-end pr-0" align="right"><b>#lsCurrencyFormat(getInvoiceData.amountOpen, "none")#</b></td>
                            </tr>
                        </cfif>
                        <tr><td colspan="6" style="border-top: 1px solid ##ccc;"></td></tr>
                    </table>
                </td>
            </tr>
        </table>
    </body>
    </html>
    </cfoutput>
</cfsavecontent>
<cfsavecontent variable="invoiceDataFooter">
    <cfoutput>
    <table width="100%" border="0" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; line-height: 18px;">
        <tr>
            <td align="center">
                <b>#sysAdminData.companyName#</b>, #sysAdminData.address#, #sysAdminData.zip# #sysAdminData.city#<br>
                #getTrans('formEmailAddress')#: #sysAdminData.email# |
                #getTrans('formPhone')#: #sysAdminData.phone# |
                #getTrans('formWebsite')#: #sysAdminData.website#

            </td>
        </tr>
    </table>
    </cfoutput>
</cfsavecontent>


<cfif !swissQrInvoice>

    <cfdocument
        saveAsName="#pdfName#.pdf"
        pageType="A4"
        unit="cm"
        marginLeft="1.8"
        marginRight="1.8"
        marginTop="2"
        marginBottom="1"
        format="pdf"
        overwrite="yes">

        <cfoutput>
        #invoiceData#
        <cfdocumentitem type="footer">
            #invoiceDataFooter#
        </cfdocumentitem>
        </cfoutput>

    </cfdocument>



<!--- With Swiss QR invoice  --->
<cfelse>

    <cftry>
    
        <cfdocument
            name="invoice"
            pageType="A4"
            unit="cm"
            marginLeft="1.8"
            marginRight="1.8"
            marginTop="2"
            marginBottom="1"
            format="pdf"
            overwrite="yes">

            <cfoutput>
            #invoiceData#
            <cfdocumentitem type="footer">
                #invoiceDataFooter#
            </cfdocumentitem>
            </cfoutput>

        </cfdocument>

        <cfpdf action="merge" destination="#pdfName#.pdf" overwrite="yes">
            <cfpdfparam source="invoice">
            <cfpdfparam source="#swissQrSlip#">
        </cfpdf>

        <!--- Open PDF in browser and delete the file immediately --->
        <cfheader name="Content-Disposition" value="attachment;filename=""#pdfName#.pdf"";">
        <cfheader name="Content-Type" value="application/pdf">
        <cfcontent type="application/pdf" file="#pdfName#.pdf" deletefile="yes" reset="yes">
        </cfcontent>

        <cfcatch type="any">
            <cfoutput>
                #swissQrSlip#
            </cfoutput>
            <cfabort>
        </cfcatch>
        
    </cftry>

</cfif>