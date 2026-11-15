<!--- Save the HTML part into a variable --->
<cfsavecontent variable="local.invoiceData">
    <cfoutput>
    <head>
        <title>#encodeForHTML(local.snapshot.invoice.title)#</title>
    </head>
    <body style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; line-height: 18px;">
        <table width="100%" border="0" style="table-layout: fixed;">
            <tr>
                <td align="right" height="100" valign="top">
                    <img alt="Logo" src="#local.snapshot.logoURL#" style="#local.logoSize# font-size: 16px;" border="0">
                </td>
            </tr>
            <tr>
                <td height="150" valign="top" style="font-family: Arial, Helvetica, sans-serif; font-size: 12px;">
                    #local.snapshot.addressHTML#
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px solid ##ccc; padding-bottom: 5px;">
                    <b>#local.getTrans('titInvoice', local.invoiceLng)# #local.snapshot.invoice.number#</b>
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px solid ##ccc; padding-bottom: 5px; font-size: 12px;">
                    <b>#encodeForHTML(local.snapshot.invoice.title)#</b>
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px solid ##ccc; padding-bottom: 5px;">
                    <table width="100%" border="0" style="table-layout: fixed;">
                        <tr>
                            <td width="20%" style="width: 20%;">
                                #local.getTrans('titInvoiceDate', local.invoiceLng)#:<br />
                                #local.getTrans('txtDueDate', local.invoiceLng)#:
                            </td>
                            <td width="30%" style="width: 30%;">
                                #local.snapshot.invoiceDateText#<br />
                                #local.snapshot.dueDateText#
                            </td>
                            <td width="50%" valign="top" style="width: 50%;">
                                #replace(local.snapshot.customer.billingInfo, chr(13), "<br />", "all")#
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr><td style="padding: 5px;"></td></tr>
            <tr>
                <td>
                    <table width="100%" border="0" style="border-collapse: collapse; table-layout: fixed;">
                        <tr>
                            <td width="5%" style="width: 5%; border-bottom: 1px solid ##ccc; font-size: 10px;">#local.getTrans('titPos', local.invoiceLng)#</td>
                            <td width="45%" style="width: 45%; border-bottom: 1px solid ##ccc; font-size: 10px;">#local.getTrans('titDescription', local.invoiceLng)#</td>
                            <td width="15%" style="width: 15%; border-bottom: 1px solid ##ccc; font-size: 10px;" align="right">#local.getTrans('titQuantity', local.invoiceLng)#</td>
                            <td width="15%" style="width: 15%; border-bottom: 1px solid ##ccc; font-size: 10px;" align="right">#local.getTrans('titSinglePrice', local.invoiceLng)#</td>
                            <td width="10%" style="width: 10%; border-bottom: 1px solid ##ccc; font-size: 10px;" align="right">#local.getTrans('titDiscount', local.invoiceLng)#</td>
                            <td width="10%" style="width: 10%; border-bottom: 1px solid ##ccc; font-size: 10px;" align="right">#local.getTrans('titTotal', local.invoiceLng)# #local.snapshot.invoice.currency#</td>
                        </tr>
                        <cfloop array="#local.snapshot.invoice.positions#" index="local.pos">
                            <tr>
                                <td valign="top" style="border-bottom: 1px solid ##ccc;">#local.pos.posNumber#</td>
                                <td valign="top" style="border-bottom: 1px solid ##ccc;">
                                    <b>#local.pos.title#</b><br />
                                    #local.pos.description#
                                </td>
                                <td valign="top" align="right" style="border-bottom: 1px solid ##ccc;">#lsCurrencyFormat(local.pos.quantity, "none")# #local.pos.unit#</td>
                                <td valign="top" align="right" style="border-bottom: 1px solid ##ccc;">
                                    #lsCurrencyFormat(local.pos.singlePrice, "none")#
                                    <cfif local.pos.vat gt 0>
                                        <br />
                                        <span style="font-size: 9px; color: ##ccc;">(#local.pos.vat#%)</span>
                                    </cfif>
                                </td>
                                <td valign="top" align="right" style="border-bottom: 1px solid ##ccc;"><cfif local.pos.discountPercent gt 0>#local.pos.discountPercent#%</cfif></td>
                                <td valign="top" align="right" style="border-bottom: 1px solid ##ccc;">#lsCurrencyFormat(local.pos.totalPrice, "none")#</td>
                            </tr>
                        </cfloop>
                        <tr>
                            <td></td>
                            <td colspan="4"><b>#local.getTrans('titTotal', local.invoiceLng)#</b></td>
                            <td align="right"><b>#lsCurrencyFormat(local.snapshot.invoice.subtotal, "none")#</b></td>
                        </tr>
                        <cfif arrayLen(local.snapshot.invoice.vatArray)>
                            <tr><td colspan="6"></td></tr>
                            <cfloop array="#local.snapshot.invoice.vatArray#" index="local.vat">
                                <tr>
                                    <td></td>
                                    <td colspan="4" style="font-size: 10px;">#local.objInvoices.getVatText(local.snapshot.invoice.isNet, local.vat.vat, local.invoiceLng)#</td>
                                    <td align="right">#lsCurrencyFormat(local.vat.amount, "none")#</td>
                                </tr>
                            </cfloop>
                            <tr><td colspan="100%"></td></tr>
                        </cfif>
                        <tr>
                            <td style="border-top: 1px solid ##ccc; padding: 5px 0;"></td>
                            <td style="border-top: 1px solid ##ccc; padding: 5px 0;" colspan="4"><b>#local.objInvoices.getTotalText(local.snapshot.invoice.vatType, local.invoiceLng)#</b></td>
                            <td style="border-top: 1px solid ##ccc; padding: 5px 0;" align="right"><b>#lsCurrencyFormat(local.snapshot.invoice.total, "none")#</b></td>
                        </tr>

                        <cfif local.qPayments.recordCount>
                            <cfloop query="local.qPayments">
                                <tr>
                                    <td style="border-top: 1px solid; padding: 5px 0;"></td>
                                    <td style="border-top: 1px solid; padding: 5px 0;" colspan="4">#local.getTrans('txtIncoPayments', local.invoiceLng)# #lsDateFormat(local.getTime.utc2local(utcDate=local.qPayments.dtmPayDate))# (#encodeForHTML(local.qPayments.strPaymentType)#):</td>
                                    <td style="border-top: 1px solid; padding: 5px 0;" class="text-end pr-0" align="right">- #lsCurrencyFormat(local.qPayments.decAmount, "none")#</td>
                                </tr>
                            </cfloop>

                            <tr>
                                <td style="border-top: 1px solid ##ccc;"></td>
                                <td style="border-top: 1px solid ##ccc;" colspan="4"><b>#local.getTrans('txtRemainingAmount', local.invoiceLng)#</b></td>
                                <td style="border-top: 1px solid ##ccc;" class="text-end pr-0" align="right"><b>#lsCurrencyFormat(local.snapshot.invoice.amountOpen, "none")#</b></td>
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
<cfsavecontent variable="local.invoiceDataFooter">
    <cfoutput>
    <table width="100%" border="0" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; line-height: 18px;">
        <tr>
            <td align="center">
                <b>#encodeForHTML(local.snapshot.issuer.companyName)#</b>, #local.snapshot.issuer.address#, #local.snapshot.issuer.zip# #local.snapshot.issuer.city#<br>
                #local.getTrans('formEmailAddress', local.invoiceLng)#: #local.snapshot.issuer.email# |
                #local.getTrans('formPhone', local.invoiceLng)#: #local.snapshot.issuer.phone# |
                #local.getTrans('formWebsite', local.invoiceLng)#: #local.snapshot.issuer.website#

            </td>
        </tr>
    </table>
    </cfoutput>
</cfsavecontent>


<!--- Reserve a printable gap below the footer in the modern renderer. --->
<cfdocument name="local.pdf" pageType="A4" unit="cm" marginLeft="1.8" marginRight="1.8" marginTop="2" marginBottom="3" format="pdf">
    <cfoutput>#local.invoiceData#<cfdocumentitem type="footer">#local.invoiceDataFooter#</cfdocumentitem></cfoutput>
</cfdocument>
<cfif structKeyExists(local.snapshot, "qr")>
    <cfset local.slip = new backend.core.com.swissqrbill().generateSwissBill(local.snapshot.qr, "variable")>
    <cfif !isBinary(local.slip)><cfthrow type="InvoiceDocument.QR" message="Could not generate the invoice payment slip." detail="#local.slip#"></cfif>
    <cfpdf action="merge" name="local.mergedPDF">
        <cfpdfparam source="local.pdf">
        <cfpdfparam source="local.slip">
    </cfpdf>
    <cfset local.pdf = local.mergedPDF>
</cfif>
