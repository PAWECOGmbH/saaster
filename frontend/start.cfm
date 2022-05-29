start

<!--- <cfdump  var="#GetLocale()#">
<cfdump  var="#LSNumberFormat(1000, '__,___.__')#"> --->

<cfset objPrices = new com.prices()>

<cfdump  var="#objPrices.getCurrency()#">