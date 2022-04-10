
component displayname="sysadmin" output="false" {

    public array function getTimezones() {

        local.timezone = arrayNew(1);
        local.timezone = [
            'UTC-12:00','UTC-11:00','UTC-10:00','UTC-09:00','UTC-08:00','UTC-07:00','UTC-06:00','UTC-05:00','UTC-04:00','UTC-03:00',
            'UTC-02:00','UTC-01:00','UTC+00:00','UTC+01:00','UTC+02:00','UTC+03:00','UTC+04:00','UTC+05:00','UTC+06:00','UTC+07:00',
            'UTC+08:00','UTC+09:00','UTC+10:00','UTC+11:00','UTC+12:00','UTC+13:00','UTC+14:00'
        ]

        return local.timezone;

    }


    public query function getSysAdminInvoices() {

        local.qInvoices = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT  invoices.intInvoiceID as invoiceID,
                        CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) as invoiceNumber,
                        invoices.strInvoiceTitle as invoiceTitle,
                        DATE_FORMAT(invoices.dtmInvoiceDate, '%Y-%m-%d') as invoiceDate,
                        DATE_FORMAT(invoices.dtmDueDate, '%Y-%m-%d') as invoiceDueDate,
                        invoices.strCurrency as invoiceCurrency,
                        invoices.decTotalPrice as invoiceTotal,
                        invoice_status.strInvoiceStatusVariable as invoiceStatusVariable,
                        invoice_status.strColor as invoiceStatusColor,
                        IF(
                            LENGTH(customers.strCompanyName),
                            customers.strCompanyName,
                            IF(
                                LENGTH(invoices.intUserID),
                                (
                                    SELECT CONCAT(users.strFirstName, ' ', users.strLastName)
                                    FROM users
                                    WHERE intUserID = invoices.intUserID
                                ),
                                customers.strContactPerson
                            )
                        ) as customerName

                FROM invoices

                INNER JOIN invoice_status ON 1=1
                AND invoices.intPaymentStatusID = invoice_status.intPaymentStatusID

                INNER JOIN customers ON 1=1
                AND invoices.intCustomerID = customers.intCustomerID

                ORDER BY invoiceDate DESC
            "
        )

        return local.qInvoices;

    }





}