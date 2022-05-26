<cfscript>
    // Exception handling for set and invoice id
    param name="thiscontent.thisID" default=0 type="numeric";

    thisInvoiceID = thiscontent.thisID;
    if(not isNumeric(thisInvoiceID) or thisInvoiceID lte 0){
        abort;
    }

    // Get the invoice data
    getInvoiceData = createObject("component", "com.invoices").getInvoiceData(thisInvoiceID);
    if(not isStruct(getInvoiceData) or not arrayLen(getInvoiceData.positions)) {
        abort;
    }

    // Is the user allowed to see this invoice
    checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, getInvoiceData.customerID);
    if(not checkTenantRange) {
        abort;
    }

</cfscript>

<cfdocument
    overwrite="yes"
    pageType="A4"
    saveAsName="invoice.pdf"
    unit="cm"
    marginLeft="1.8"
    marginRight="1.8"
    marginTop="1"
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
                    <cfif len(trim(getCustomerData.strLogo))>
                        <img src="#application.mainURL#/userdata/images/logos/#getCustomerData.strLogo#" style="max-height: 100px;">
                    </cfif>
                </td>
            </tr>
            <tr>
                <td height="120" valign="top" style="font-family: Arial, Helvetica, sans-serif; font-size: 12px;">
                    #getCustomerData.strBillingAccountName#<br />
                    #replace(getCustomerData.strBillingAddress, chr(13), "<br />")#
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px solid gray; padding-bottom: 5px;">
                    <b>#getTrans('titInvoice')# #getInvoiceData.number#</b>
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px solid gray; padding-bottom: 5px; font-size: 12px;">
                    <b>#getInvoiceData.title#</b>
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px solid gray; padding-bottom: 5px;">
                    <table width="100%" border="0">
                        <tr>
                            <td width="20%">
                                #getTrans('titInvoiceDate')#:<br />
                                #getTrans('txtDueDate')#:
                            </td>
                            <td width="30%">
                                #dateFormat(getInvoiceData.date, "dd.mm.yyyy")#<br />
                                #dateFormat(getInvoiceData.dueDate, "dd.mm.yyyy")#
                            </td>
                            <td width="50%" valign="top">
                                #replace(getCustomerData.strBillingInfo, chr(13), "<br />")#
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
                            <td width="5%" style="border-bottom: 1px solid gray;"><b>#getTrans('titPos')#</b></td>
                            <td width="35%" style="border-bottom: 1px solid gray;"><b>#getTrans('titDescription')#</b></td>
                            <td width="15%" style="border-bottom: 1px solid gray;" align="right"><b>#getTrans('titQuantity')#</b></td>
                            <td width="15%" style="border-bottom: 1px solid gray;" align="right"><b>#getTrans('titSinglePrice')#</b></td>
                            <td width="15%" style="border-bottom: 1px solid gray;" align="center"><b>#getTrans('titDiscount')#</b></td>
                            <td width="15%" style="border-bottom: 1px solid gray;" align="right"><b>#getTrans('titTotal')# #getInvoiceData.currency#</b></td>
                        </tr>
                        <cfloop array="#getInvoiceData.positions#" index="pos">
                            <tr>
                                <td valign="top" style="border-bottom: 1px solid gray;">#pos.posNumber#</td>
                                <td valign="top" style="border-bottom: 1px solid gray;">
                                    <b>#pos.title#</b><br />
                                    #pos.description#
                                </td>
                                <td valign="top" align="right" style="border-bottom: 1px solid gray;">#lsnumberFormat(pos.quantity, "__.__")# #pos.unit#</td>
                                <td valign="top" align="right" style="border-bottom: 1px solid gray;">
                                    #lsnumberFormat(pos.singlePrice, "_,___.__")#<br />
                                    <span style="font-size: 9px; color: gray;">(#pos.vat#%)</span>
                                </td>
                                <td valign="top" align="center" style="border-bottom: 1px solid gray;"><cfif pos.discountPercent gt 0>#pos.discountPercent#%</cfif></td>
                                <td valign="top" align="right" style="border-bottom: 1px solid gray;">#lsnumberFormat(pos.totalPrice, "_,___.__")#</td>
                            </tr>
                        </cfloop>
                        <tr>
                            <td></td>
                            <td colspan="4"><b>#getTrans('titTotal')#</b></td>
                            <td align="right"><b>#lsnumberFormat(getInvoiceData.subtotal, "_,___.__")#</b></td>
                        </tr>
                        <cfif arrayLen(getInvoiceData.vatArray)>
                            <tr><td colspan="6"></td></tr>
                            <cfloop array="#getInvoiceData.vatArray#" index="vat">
                                <tr>
                                    <td></td>
                                    <td colspan="4" style="font-size: 10px;">#vat.vatText#</td>
                                    <td align="right">#lsnumberFormat(vat.amount, "_,___.__")#</td>
                                </tr>
                            </cfloop>
                            <tr><td colspan="100%"></td></tr>
                        </cfif>
                        <tr>
                            <td style="border-top: 1px solid gray;"></td>
                            <td style="border-top: 1px solid gray;" colspan="4"><b>#getInvoiceData.totaltext#</b></td>
                            <td style="border-top: 1px solid gray;" align="right"><b>#lsnumberFormat(getInvoiceData.total, "_,___.__")#</b></td>
                        </tr>
                        <tr><td colspan="6"><hr style="height: 1px; border: 0; background-color: gray; margin-bottom: 2px;"></td></tr>
                        <tr><td colspan="6"><hr style="height: 1px; border: 0; background-color: gray; margin: 0;"></td></tr>
                    </table>
                </td>
            </tr>
        </table>
        <cfdocumentitem type="footer">
            <table width="100%" border="0" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; line-height: 18px;">
                <tr><td align="center">#application.appOwner#</td></tr>
            </table>
        </cfdocumentitem>
    </body>
    </html>
    </cfoutput>

</cfdocument>