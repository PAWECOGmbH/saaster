<cfscript>
    // Exception handling for set and invoice id
    param name="thiscontent.thisID" default=0 type="numeric";

    thisInvoiceID = thiscontent.thisID;
    if(not isNumeric(thisInvoiceID) or thisInvoiceID lte 0){
        abort;
    }

    objInvoices = new com.invoices();

    // Get the invoice data
    getInvoiceData = objInvoices.getInvoiceData(thisInvoiceID);
    if(not isStruct(getInvoiceData) or !structKeyExists(getInvoiceData, "customerID") or getInvoiceData.customerID eq 0) {
        abort;
    }

    // Is the user allowed to see this invoice
    if (!session.sysadmin) {
        checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, getInvoiceData.customerID);
        if(not checkTenantRange) {
            abort;
        }
    }

    customerData = application.objCustomer.getCustomerData(getInvoiceData.customerID);

    // Get invoice address block
    addressBlock = objInvoices.getInvoiceAddress(thisInvoiceID);

    qPayments = objInvoices.getInvoicePayments(thisInvoiceID);

</cfscript>

<cfdocument
    overwrite="yes"
    pageType="A4"
    saveAsName="invoice.pdf"
    unit="cm"
    marginLeft="1.8"
    marginRight="1.8"
    marginTop="2"
    marginBottom="1"
    format="pdf">

    <cfoutput>

    <head>
        <title>#getInvoiceData.title#</title>
    </head>
    <body style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; line-height: 18px;">
        <table width="100%" border="0">
            <tr>
                <td align="right" height="100" valign="top">
                    <img alt="Logo" src="#application.mainURL#/dist/img/logo.png" width="180" style="display: block; width: 180px; font-size: 16px;" border="0">
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
                                #replace(customerData.billingInfo, chr(13), "<br />")#
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
                        <tr><td colspan="6" style="border-top: 1px solid ##ccc;"><!--- <hr style="height: 1px; border: 0; background-color: ##ccc; margin-bottom: 2px;"> ---></td></tr>
                    </table>
                </td>
            </tr>
        </table>
        <cfdocumentitem type="footer">
            <table width="100%" border="0" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; line-height: 18px;">
                <tr>
                    <td align="center">
                        <b>#application.appOwner#</b> #customerData.address#, #customerData.zip# #customerData.city#<br>
                        E-Mail : #customerData.email# |
                        #getTrans('formPhone')#: #customerData.phone# | Website: #customerData.website#

                    </td>
                </tr>
            </table>
        </cfdocumentitem>
    </body>
    </html>
    </cfoutput>

</cfdocument>