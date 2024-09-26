component displayname="invoices" output="false" {

    // Create invoice number
    private numeric function createInvoiceNumber(required numeric customerID) {

        // Check start number
        local.startNumber = application.objSettings.getSetting('settingInvoiceNumberStart');
        local.nextNumber = local.startNumber;

        if (!isNumeric(trim(local.startNumber))) {
            local.nextNumber = 1;
        }

        qNextNumber = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT MAX(intInvoiceNumber) as nextInvoice
                FROM invoices
            "
        )

        if (qNextNumber.recordCount and isNumeric(qNextNumber.nextInvoice)) {

            if (qNextNumber.nextInvoice >= local.nextNumber) {
                local.nextNumber = qNextNumber.nextInvoice+1;
            }
        }

        return local.nextNumber;

    }

    // Create invoice
    public struct function createInvoice(required struct invoiceData) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        local.objCurrency = new backend.core.com.currency();

        local.userID = "";
        local.bookingID = 0;
        local.prefix = application.objSettings.getSetting('settingInvoicePrefix');
        local.title = "";
        local.invoiceDate = createODBCDate(now());
        local.dueDate = createODBCDate(now()+30);
        local.currency = local.objCurrency.getCurrency().iso;
        local.isNet = application.objSettings.getSetting('settingInvoiceNet');
        local.paymentStatusID = 1;
        local.vatType = application.objSettings.getSetting('settingStandardVatType');
        local.language = application.objLanguage.getDefaultLanguage().iso;

        if (structKeyExists(invoiceData, "customerID") and isNumeric(invoiceData.customerID)) {
            local.customerID = invoiceData.customerID;
        } else {
            local.argsReturnValue['message'] = "No customerID found!";
            return local.argsReturnValue;
        }
        if (structKeyExists(invoiceData, "userID") and isNumeric(invoiceData.userID)) {
            local.userID = invoiceData.userID;
        }
        if (structKeyExists(invoiceData, "bookingID") and isNumeric(invoiceData.bookingID)) {
            local.bookingID = invoiceData.bookingID;
        }
        local.invoiceNumber = createInvoiceNumber(local.customerID);
        if (structKeyExists(invoiceData, "prefix") and len(trim(invoiceData.prefix))) {
            local.prefix = left(invoiceData.prefix, 20);
        }
        if (structKeyExists(invoiceData, "title") and len(trim(invoiceData.title))) {
            local.title = left(invoiceData.title, 50);
        }
        if (structKeyExists(invoiceData, "invoiceDate") and isDate(invoiceData.invoiceDate)) {
            local.invoiceDate = invoiceData.invoiceDate;
        }
        if (structKeyExists(invoiceData, "dueDate") and isDate(invoiceData.dueDate)) {
            local.dueDate = invoiceData.dueDate;
        }
        if (structKeyExists(invoiceData, "currency") and len(trim(invoiceData.currency))) {
            local.currency = left(invoiceData.currency, 3);
        }
        if (structKeyExists(invoiceData, "isNet") and isBoolean(invoiceData.isNet)) {
            local.isNet = invoiceData.isNet;
        }
        if (structKeyExists(invoiceData, "paymentStatusID") and isNumeric(invoiceData.paymentStatusID) and invoiceData.paymentStatusID <= 5 and invoiceData.paymentStatusID > 0) {
            local.paymentStatusID = invoiceData.paymentStatusID;
        }
        if (structKeyExists(invoiceData, "vatType") and isNumeric(invoiceData.vatType) and invoiceData.vatType <= 3 and invoiceData.vatType > 0) {
            local.vatType = invoiceData.vatType;
        }
        if (structKeyExists(invoiceData, "language") and len(trim(invoiceData.language))) {
            local.language = invoiceData.language;
        }

        if (local.vatType eq 1) {
            local.total_text = application.objLanguage.getTrans('txtTotalIncl', local.language);
        } else if (local.vatType eq 2) {
            local.total_text = application.objLanguage.getTrans('txtTotalExcl', local.language);
        } else if (local.vatType eq 3) {
            local.total_text = application.objLanguage.getTrans('txtExemptTax', local.language);
        } else {
            local.total_text = "Total";
        }


        try {

            local.dbType = len(local.userID) ? "numeric" : "varchar";

            queryExecute(
                options = {datasource = application.datasource, result="getNewID"},
                params = {
                    customerID: {type: "numeric", value: local.customerID},
                    userID: {type: #local.dbType#, value: local.userID},
                    invoiceNumber: {type: "numeric", value: local.invoiceNumber},
                    prefix: {type: "nvarchar", value: local.prefix},
                    title: {type: "nvarchar", value: local.title},
                    invoiceDate: {type: "datetime", value: local.invoiceDate},
                    dueDate: {type: "datetime", value: local.dueDate},
                    currency: {type: "varchar", value: local.currency},
                    language: {type: "nvarchar", value: local.language},
                    isNet: {type: "boolean", value: local.isNet},
                    vatType: {type: "numeric", value: local.vatType},
                    paymentStatusID: {type: "numeric", value: local.paymentStatusID},
                    total_text: {type: "nvarchar", value: local.total_text},
                    bookingID: {type: "numeric", value: local.bookingID},
                },
                sql = "
                    INSERT INTO invoices (intCustomerID, intUserID, intInvoiceNumber, strPrefix, strInvoiceTitle, dtmInvoiceDate, dtmDueDate, strCurrency, blnIsNet, intVatType, strTotalText, intPaymentStatusID, strLanguageISO, intBookingID)
                    VALUES (:customerID, COALESCE(NULLIF(:userID, ''), NULL), :invoiceNumber, :prefix, :title, :invoiceDate, :dueDate, :currency, :isNet, :vatType, :total_text, :paymentStatusID, :language, :bookingID)
                "
            )

        } catch (any e) {

            local.argsReturnValue['message'] = e.message;
            return local.argsReturnValue;

        }

        local.argsReturnValue['newInvoiceID'] = getNewID.generatedkey;
        local.argsReturnValue['message'] = "OK";
        local.argsReturnValue['success'] = true;
        return local.argsReturnValue;


    }

    // Update invoice
    public struct function updateInvoice(required struct invoiceData) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        local.objCurrency = new backend.core.com.currency();

        local.userID = "";
        local.title = "";
        local.invoiceDate = createODBCDate(now());
        local.dueDate = createODBCDate(now()+30);
        local.currency = local.objCurrency.getCurrency().iso;
        local.isNet = application.objSettings.getSetting('settingStandardNet');
        local.vatType = application.objSettings.getSetting('settingStandardVatType');
        local.language = application.objLanguage.getDefaultLanguage().iso;

        if (structKeyExists(invoiceData, "invoiceID") and isNumeric(invoiceData.invoiceID)) {
            local.invoiceID = invoiceData.invoiceID;
        } else {
            local.argsReturnValue['message'] = "No invoiceID found!";
            return local.argsReturnValue;
        }
        if (structKeyExists(invoiceData, "userID") and isNumeric(invoiceData.userID)) {
            local.userID = invoiceData.userID;
        }
        if (structKeyExists(invoiceData, "title") and len(trim(invoiceData.title))) {
            local.title = left(invoiceData.title, 50);
        }
        if (structKeyExists(invoiceData, "invoiceDate") and isDate(invoiceData.invoiceDate)) {
            local.invoiceDate = invoiceData.invoiceDate;
        }
        if (structKeyExists(invoiceData, "dueDate") and isDate(invoiceData.dueDate)) {
            local.dueDate = invoiceData.dueDate;
        }
        if (structKeyExists(invoiceData, "currency") and len(trim(invoiceData.currency))) {
            local.currency = left(invoiceData.currency, 3);
        }
        if (structKeyExists(invoiceData, "isNet") and isBoolean(invoiceData.isNet)) {
            local.isNet = invoiceData.isNet;
        }
        if (structKeyExists(invoiceData, "vatType") and isNumeric(invoiceData.vatType) and invoiceData.vatType <= 3 and invoiceData.vatType > 0) {
            local.vatType = invoiceData.vatType;
        }
        if (structKeyExists(invoiceData, "language") and len(trim(invoiceData.language))) {
            local.language = invoiceData.language;
        }

        local.customerID = new backend.core.com.invoices().getInvoiceData(local.invoiceID).customerID;

        // Total text
        if (local.vatType eq 1) {
            local.total_text = application.objLanguage.getTrans('txtTotalIncl', local.language);
        } else if (local.vatType eq 2) {
            local.total_text = application.objLanguage.getTrans('txtTotalExcl', local.language);
        } else if (local.vatType eq 3) {
            local.total_text = application.objLanguage.getTrans('txtExemptTax', local.language);
        } else {
            local.total_text = "Total";
        }

        try {

             queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: local.invoiceID},
                    userID: {type: "numeric", value: local.userID},
                    title: {type: "nvarchar", value: local.title},
                    invoiceDate: {type: "datetime", value: local.invoiceDate},
                    dueDate: {type: "datetime", value: local.dueDate},
                    currency: {type: "varchar", value: local.currency},
                    total_text: {type: "nvarchar", value: local.total_text},
                    isNet: {type: "boolean", value: local.isNet},
                    vatType: {type: "numeric", value: local.vatType},
                    language: {type: "varchar", value: local.language}
                },
                sql = "
                    UPDATE invoices
                    SET intUserID = :userID,
                        strInvoiceTitle = :title,
                        dtmInvoiceDate = :invoiceDate,
                        dtmDueDate = :dueDate,
                        strCurrency = :currency,
                        strTotalText = :total_text,
                        blnIsNet = :isNet,
                        intVatType = :vatType,
                        strLanguageISO = :language
                    WHERE intInvoiceID = :invoiceID
                "
            )


        } catch (any e) {

            local.argsReturnValue['message'] = e.message;
            return argsReturnValue;

        }

        // Recalculating
        local.recalc = recalculateInvoice(local.invoiceID);



        if (!local.recalc.success) {
            local.argsReturnValue['message'] = "Error in function recalculateInvoice()";
            return local.argsReturnValue;
        }

        local.argsReturnValue['message'] = "OK";
        local.argsReturnValue['success'] = true;
        return local.argsReturnValue;


    }


    public void function deleteInvoice(required numeric invoiceID) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                invoiceID: {type: "numeric", value: arguments.invoiceID}
            },
            sql = "
                DELETE FROM invoices WHERE intInvoiceID = :invoiceID
            "
        )

        return;

    }



    // Insert invoice positions
    public struct function insertInvoicePositions(required struct invoicePosData) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        param name="local.append" default=true;

        if (structKeyExists(arguments.invoicePosData, "invoiceID") and isNumeric(arguments.invoicePosData.invoiceID) and arguments.invoicePosData.invoiceID gt 0) {
            local.invoiceID = invoicePosData.invoiceID;
            if (!isStruct(getInvoiceData(local.invoiceID))) {
                local.argsReturnValue['message'] = "No valid invoiceID found!";
                return local.argsReturnValue;
            }
        } else {
            local.argsReturnValue['message'] = "No valid invoiceID found!";
            return local.argsReturnValue;
        }
        if (structKeyExists(arguments.invoicePosData, "positions")) {
            local.positions = arguments.invoicePosData.positions;
        } else {
            local.argsReturnValue['message'] = "No positions found!";
            return local.argsReturnValue;
        }
        if (structKeyExists(arguments.invoicePosData, "append")) {
            local.append = arguments.invoicePosData.append;
        }

        // Do we have to delete all positions first?
        if (!local.append) {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: local.invoiceID}
                },
                sql = "
                    DELETE FROM invoice_positions
                    WHERE intInvoiceID = :invoiceID
                "
            )

            local.thisPosition = 0;

        } else {

            // Get the last position of this invoice
            qNextPosNumber = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: local.invoiceID}
                },
                sql = "
                    SELECT MAX(intPosNumber) as posNumber
                    FROM invoice_positions
                    WHERE intInvoiceID = :invoiceID
                "
            )

            if (qNextPosNumber.recordCount and isNumeric(qNextPosNumber.posNumber)) {
                local.thisPosition = qNextPosNumber.posNumber;
            } else {
                local.thisPosition = 0;
            }

        }


        if (isArray(local.positions) and arrayLen(local.positions)) {


            cfloop(array=local.positions, index="pos") {

                local.thisPosition++;
                local.title = "";
                local.description = "";
                local.single_price = 0;
                local.quantity = 1;
                local.unit = "";
                local.discountPercent = 0;
                local.vat = 0;

                if (structKeyExists(pos, "title") and len(trim(pos.title))) {
                    local.title = left(pos.title, 255);
                }
                if (structKeyExists(pos, "description") and len(trim(pos.description))) {
                    local.description = left(pos.description, 1000);
                }
                if (structKeyExists(pos, "price") and isNumeric(pos.price)) {
                    local.single_price = pos.price;
                }
                if (structKeyExists(pos, "quantity") and isNumeric(pos.quantity)) {
                    local.quantity = pos.quantity;
                }
                if (structKeyExists(pos, "unit") and len(trim(pos.unit))) {
                    local.unit = left(pos.unit, 20);
                }
                if (structKeyExists(pos, "discountPercent") and isNumeric(pos.discountPercent)) {
                    local.discountPercent = pos.discountPercent;
                }
                if (structKeyExists(pos, "vat") and isNumeric(pos.vat)) {
                    local.vat = pos.vat;
                }

                // Calculate discount (percent)
                if (local.discountPercent gt 0) {

                    local.discount = local.single_price*local.discountPercent/100;
                    local.new_price = local.single_price-local.discount;

                    local.price = round((local.new_price*local.quantity), 2);

                // No discount
                } else {

                    local.price = round((local.single_price*local.quantity), 2);

                }

                try {

                    // Insert position
                    qNextPosNumber = queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            invoiceID: {type: "numeric", value: local.invoiceID},
                            thisPosition: {type: "numeric", value: local.thisPosition},
                            title: {type: "nvarchar", value: local.title},
                            description: {type: "nvarchar", value: local.description},
                            single_price: {type: "decimal", value: local.single_price, scale: 2},
                            quantity: {type: "decimal", value: local.quantity, scale: 2},
                            unit: {type: "nvarchar", value: local.unit},
                            discountPercent: {type: "decimal", value: local.discountPercent, scale: 2},
                            vat: {type: "decimal", value: local.vat, scale: 2},
                            total_price: {type: "decimal", value: local.price, scale: 2}
                        },
                        sql = "
                            INSERT INTO invoice_positions
                                    (intInvoiceID, intPosNumber, strTitle, strDescription, decSinglePrice, decQuantity, strUnit,
                                    decTotalPrice, intDiscountPercent, decVat)
                            VALUES (:invoiceID, :thisPosition, :title, :description, :single_price, :quantity, :unit,
                                    :total_price, :discountPercent, :vat)
                        "
                    )

                } catch (any e) {

                    local.argsReturnValue['message'] = e.message;
                    return local.argsReturnValue;

                }

            }

            // Recalculating
            local.recalc = recalculateInvoice(local.invoiceID);

            if (local.recalc.success) {
                local.argsReturnValue['success'] = true;
                local.argsReturnValue['message'] = "OK";
                return local.argsReturnValue;
            } else {
                local.argsReturnValue['message'] = "Error in function recalculateInvoice()";
            }


        } else {

           local.argsReturnValue['message'] = "No positions found!";
           return local.argsReturnValue;

        }


    }

    // Update position
    public struct function updatePosition(required struct invoicePosData) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (structKeyExists(arguments.invoicePosData, "invoicePosID") and isNumeric(arguments.invoicePosData.invoicePosID) and arguments.invoicePosData.invoicePosID gt 0) {
            local.invoicePosID = invoicePosData.invoicePosID;
        } else {
            local.argsReturnValue['message'] = "No valid invoicePosID found!";
            return local.argsReturnValue;
        }

        local.qInvoice = queryExecute(
            options = {datasource = application.datasource},
            params = {
                posID: {type: "numeric", value: local.invoicePosID}
            },
            sql = "
                SELECT intInvoiceID
                FROM invoice_positions
                WHERE intInvoicePosID = :posID
                LIMIT 1
            "
        )

        local.title = "";
        local.description = "";
        local.single_price = 0;
        local.quantity = 1;
        local.unit = "";
        local.discountPercent = 0;
        local.vat = 0;
        local.pos = 0;

        if(local.qInvoice.recordCount){
            local.invoiceID = local.qInvoice.intInvoiceID;
        } else {
            local.argsReturnValue['message'] = "No invoice found!";
            return local.argsReturnValue;
        }

        if (structKeyExists(arguments.invoicePosData, "title") and len(trim(arguments.invoicePosData.title))) {
            local.title = left(arguments.invoicePosData.title, 255);
        }
        if (structKeyExists(arguments.invoicePosData, "description") and len(trim(arguments.invoicePosData.description))) {
            local.description = left(arguments.invoicePosData.description, 1000);
        }
        if (structKeyExists(arguments.invoicePosData, "price") and isNumeric(arguments.invoicePosData.price)) {
            local.single_price = arguments.invoicePosData.price;
        }
        if (structKeyExists(arguments.invoicePosData, "quantity") and isNumeric(arguments.invoicePosData.quantity)) {
            local.quantity = arguments.invoicePosData.quantity;
        }
        if (structKeyExists(arguments.invoicePosData, "unit") and len(trim(arguments.invoicePosData.unit))) {
            local.unit = left(arguments.invoicePosData.unit, 20);
        }
        if (structKeyExists(arguments.invoicePosData, "discountPercent") and isNumeric(arguments.invoicePosData.discountPercent)) {
            local.discountPercent = arguments.invoicePosData.discountPercent;
        }
        if (structKeyExists(arguments.invoicePosData, "vat") and isNumeric(arguments.invoicePosData.vat)) {
            local.vat = arguments.invoicePosData.vat;
        }
        if (structKeyExists(arguments.invoicePosData, "pos") and isNumeric(arguments.invoicePosData.pos)) {
            local.pos = arguments.invoicePosData.pos;
        }

        // Calculate discount (percent)
        if (local.discountPercent gt 0) {

            local.discount = local.single_price*local.discountPercent/100;
            local.new_price = local.single_price-local.discount;

            local.price = round((local.new_price*local.quantity), 2);

        // No discount
        } else {

            local.price = round((local.single_price*local.quantity), 2);

        }

        // Update position
        qNextPosNumber = queryExecute(
            options = {datasource = application.datasource},
            params = {
                invoicePosID: {type: "numeric", value: local.invoicePosID},
                title: {type: "nvarchar", value: local.title},
                description: {type: "nvarchar", value: local.description},
                single_price: {type: "decimal", value: local.single_price, scale: 2},
                quantity: {type: "decimal", value: local.quantity, scale: 2},
                unit: {type: "nvarchar", value: local.unit},
                discountPercent: {type: "decimal", value: local.discountPercent, scale: 2},
                vat: {type: "decimal", value: local.vat, scale: 2},
                total_price: {type: "decimal", value: local.price, scale: 2},
                pos: {type: "numeric", value: local.pos}
            },
            sql = "
                UPDATE invoice_positions
                SET strTitle = :title,
                    strDescription = :description,
                    decSinglePrice = :single_price,
                    decQuantity = :quantity,
                    strUnit = :unit,
                    decTotalPrice = :total_price,
                    intDiscountPercent = :discountPercent,
                    decVat = :vat,
                    intPosNumber = :pos
                WHERE intInvoicePosID = :invoicePosID
            "
        )


        // Recalculating
        local.recalc = recalculateInvoice(local.invoiceID);

        if (local.recalc.success) {
            local.argsReturnValue['success'] = true;
            local.argsReturnValue['message'] = "OK";
        } else {
            local.argsReturnValue['message'] = "Error in function recalculateInvoice()";
        }

        return local.argsReturnValue;

    }

    // Delete position
    public struct function deletePosition(required numeric posID) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        local.qInvoice = queryExecute(
            options = {datasource = application.datasource},
            params = {
                posID: {type: "numeric", value: arguments.posID}
            },
            sql = "
                SELECT intInvoiceID
                FROM invoice_positions
                WHERE intInvoicePosID = :posID
                LIMIT 1
            "
        )

        if (local.qInvoice.recordCount) {

            try {

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        posID: {type: "numeric", value: arguments.posID}
                    },
                    sql = "
                        DELETE FROM invoice_positions WHERE intInvoicePosID = :posID
                    "
                )

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        posID: {type: "numeric", value: arguments.posID}
                    },
                    sql = "
                        DELETE FROM invoice_positions WHERE intInvoicePosID = :posID
                    "
                )


                // Recalculating
                local.recalc = recalculateInvoice(local.qInvoice.intInvoiceID);

                if (local.recalc.success) {
                    local.argsReturnValue['success'] = true;
                    local.argsReturnValue['message'] = "OK";
                } else {
                    local.argsReturnValue['message'] = "Error in function recalculateInvoice()";
                }

            } catch (any e) {

                local.argsReturnValue['message'] = e.message;
            }

        } else {

            local.argsReturnValue['message'] = "No invoice found!";

        }

        return local.argsReturnValue;

    }

    // Recalculate the invoice
    public struct function recalculateInvoice(required numeric invoiceID) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;


        qInvoicePositions = queryExecute(
            options = {datasource = application.datasource},
            params = {
                invoiceID: {type: "numeric", value: arguments.invoiceID}
            },
            sql = "
                SELECT invoices.intCustomerID, invoices.blnIsNet, invoices.intVatType, invoices.strLanguageISO, invoice_positions.*
                FROM invoices LEFT JOIN invoice_positions ON invoices.intInvoiceID = invoice_positions.intInvoiceID
                WHERE invoices.intInvoiceID = :invoiceID
            "
        )

        // Get language from the first entry in positions
        local.customerLng = qInvoicePositions.strLanguageISO;


        // Delete vat table
        queryExecute(
            options = {datasource = application.datasource},
            params = {
                invoiceID: {type: "numeric", value: arguments.invoiceID}
            },
            sql = "
                DELETE FROM invoice_vat
                WHERE intInvoiceID = :invoiceID;
            "
        )

        local.subtotal_price = 0;
        local.vat_total = 0;

        if (qInvoicePositions.recordcount and len(trim(qInvoicePositions.decTotalPrice))) {

            // Loop over all positions
            cfloop(query="qInvoicePositions") {

                // Calc prices
                local.vat_amount = calcVat(qInvoicePositions.decTotalPrice, qInvoicePositions.blnIsNet, qInvoicePositions.decVat);
                local.vat_total = local.vat_total + local.vat_amount;
                local.subtotal_price = local.subtotal_price + qInvoicePositions.decTotalPrice;

                // Define vat text and sum
                if (qInvoicePositions.blnIsNet eq 1) {
                    local.vat_text = application.objLanguage.getTrans('txtPlusVat', local.customerLng) & ' ' & lsCurrencyFormat(qInvoicePositions.decVat, "none") & '%';
                } else {
                    local.vat_text = application.objLanguage.getTrans('txtVatIncluded', local.customerLng) & ' ' & lsCurrencyFormat(qInvoicePositions.decVat, "none") & '%';
                }

                if (qInvoicePositions.intVatType eq 1) {

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            invoiceID: {type: "numeric", value: arguments.invoiceID},
                            decVat: {type: "decimal", value: qInvoicePositions.decVat, scale: 2},
                            vat_text: {type: "nvarchar", value: left(local.vat_text, 50)},
                            vat_amount: {type: "decimal", value: local.vat_amount, scale: 2}
                        },
                        sql = "
                            INSERT INTO invoice_vat (intInvoiceID, decVat, strVatText, decVatAmount)
                            VALUES (:invoiceID, :decVat, :vat_text, :vat_amount)
                        "
                    )

                }

            }

        }

        // Round subtotal according to the setting
        local.subtotal_price = roundAmount(local.subtotal_price, application.objSettings.getSetting('settingRoundFactor'));

        // Add up subtotal and vat
        if (qInvoicePositions.blnIsNet eq 1) {
            local.total_price = local.subtotal_price + local.vat_total;
        } else {
            local.total_price = local.subtotal_price;
        }

        // Round total according to the setting
        local.total_price = roundAmount(local.total_price, application.objSettings.getSetting('settingRoundFactor'));

        // Define total text
        if (qInvoicePositions.intVatType eq 1) {
            local.total_text = application.objLanguage.getTrans('txtTotalIncl', local.customerLng);
        } else if (qInvoicePositions.intVatType eq 2) {
            local.total_text = application.objLanguage.getTrans('txtTotalExcl', local.customerLng);
            local.total_price = local.subtotal_price;
        } else {
            local.total_text = application.objLanguage.getTrans('txtExemptTax', local.customerLng);
            local.total_price = local.subtotal_price;
        }


        // Update invoice
        queryExecute(
            options = {datasource = application.datasource},
            params = {
                invoiceID: {type: "numeric", value: arguments.invoiceID},
                subtotal_price: {type: "decimal", value: local.subtotal_price, scale: 2},
                total_price: {type: "decimal", value: local.total_price, scale: 2},
                vat_text: {type: "nvarchar", value: left(local.total_text, 50)}
            },
            sql = "
                UPDATE invoices
                SET decSubTotalPrice = :subtotal_price,
                    decTotalPrice = :total_price,
                    strTotalText = :vat_text
                WHERE intInvoiceID = :invoiceID
            "
        )

        local.argsReturnValue['success'] = true;
        local.argsReturnValue['message'] = "OK";
        return local.argsReturnValue;

    }

    // Calculating vat
    public numeric function calcVat(required numeric amount, required boolean isNet, required numeric rate) {

        if (arguments.isNet eq 0) {
            local.cvat = 10 & arguments.rate;
            local.vat_amount = (arguments.amount/local.cvat)*arguments.rate;
        } else {
            local.vat_amount = (arguments.amount/100)*arguments.rate;
        }

        return local.vat_amount;

    }

    // Round prices depending on settings
    public numeric function roundAmount(required numeric amount, required numeric factor) {

        if (arguments.factor eq 5) {
            local.rounded_price = round(arguments.amount*20)/20;
        } else {
            local.rounded_price = numberFormat(arguments.amount, "__.__");
        }

        return local.rounded_price;

    }

    // Get customers invoices
    public struct function getInvoices(required numeric customerID, numeric start, numeric count, string order) {

        local.queryLimit;
        local.queryOrder;

        if (structKeyExists(arguments, "start") and structKeyExists(arguments, "count")){
            local.queryLimit = "LIMIT #arguments.start#, #arguments.count#"
        }

        if (structKeyExists(arguments, "order")){
            local.queryOrder = "ORDER BY " & arguments.order;
        }

        local.qTotalCount = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT COUNT(intCustomerID) as totalCount
                FROM invoices
                WHERE intCustomerID = :customerID
                AND intPaymentStatusID > 1
            "
        )

        local.structInvoices = structNew();
        local.structInvoices['totalCount'] = qTotalCount.totalCount;
        local.structInvoices['arrayInvoices'] = "";

        local.qInvoice = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT  invoices.intInvoiceID as invoiceID,
                        CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) as invoiceNumber,
                        invoices.strInvoiceTitle as invoiceTitle,
                        DATE_FORMAT(invoices.dtmInvoiceDate, '%Y-%m-%e') as invoiceDate,
                        DATE_FORMAT(invoices.dtmDueDate, '%Y-%m-%e') as invoiceDueDate,
                        invoices.strCurrency as invoiceCurrency,
                        invoices.decTotalPrice as invoiceTotal,
                        invoices.strLanguageISO as invoiceLanguage,
                        invoices.intPaymentStatusID as invoiceStatusID,
                        (
                            SELECT strColor
                            FROM invoice_status
                            WHERE intPaymentStatusID = invoices.intPaymentStatusID
                        ) as invoiceStatusColor,
                        (
                            SELECT strInvoiceStatusVariable
                            FROM invoice_status
                            WHERE intPaymentStatusID = invoices.intPaymentStatusID
                        ) as invoiceStatusVariable
                FROM invoices
                WHERE invoices.intPaymentStatusID > 1
                AND invoices.intCustomerID = :customerID
                #local.queryOrder#
                #local.queryLimit#
            "
        )

        local.arrayInvoices = arrayNew(1);

        cfloop(query="local.qInvoice") {

            local.invoiceStruct = structNew();

            local.invoiceStruct['invoiceID'] = local.qInvoice.invoiceID;
            local.invoiceStruct['invoiceNumber'] = local.qInvoice.invoiceNumber;
            local.invoiceStruct['invoiceTitle'] = local.qInvoice.invoiceTitle;
            local.invoiceStruct['invoiceDate'] = local.qInvoice.invoiceDate;
            local.invoiceStruct['invoiceDueDate'] = local.qInvoice.invoiceDueDate;
            local.invoiceStruct['invoiceCurrency'] = local.qInvoice.invoiceCurrency;
            local.invoiceStruct['invoiceTotal'] = local.qInvoice.invoiceTotal;
            local.invoiceStruct['invoiceStatusID'] = local.qInvoice.invoiceStatusID;
            local.invoiceStruct['invoiceStatusVariable'] = local.qInvoice.invoiceStatusVariable;
            local.invoiceStruct['invoiceStatusColor'] = local.qInvoice.invoiceStatusColor;
            local.invoiceStruct['invoiceLanguage'] = local.qInvoice.invoiceLanguage;

            arrayAppend(local.arrayInvoices, local.invoiceStruct);

        }

        local.structInvoices['arrayInvoices'] = local.arrayInvoices;

        return local.structInvoices;
    }

    // Get invoice data
    public struct function getInvoiceData(required numeric invoiceID) {

        local.invoiceInfo = structNew();
        local.positionArray = arrayNew(1);
        local.vatArray = arrayNew(1);

        if (arguments.invoiceID gt 0) {

            qInvoice = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: arguments.invoiceID}
                },
                sql = "
                    SELECT invoices.*, invoice_status.strInvoiceStatusVariable, invoice_status.strColor
                    FROM invoices INNER JOIN invoice_status ON invoices.intPaymentStatusID = invoice_status.intPaymentStatusID
                    WHERE invoices.intInvoiceID = :invoiceID
                "
            )

            if (qInvoice.recordCount) {

                local.invoiceInfo['customerID'] = qInvoice.intCustomerID;
                local.invoiceInfo['userID'] = qInvoice.intUserID;
                local.invoiceInfo['number'] = qInvoice.strPrefix & qInvoice.intInvoiceNumber;
                local.invoiceInfo['title'] = qInvoice.strInvoiceTitle;
                local.invoiceInfo['date'] = qInvoice.dtmInvoiceDate;
                local.invoiceInfo['dueDate'] = qInvoice.dtmDueDate;
                local.invoiceInfo['currency'] = qInvoice.strCurrency;
                local.invoiceInfo['vatType'] = qInvoice.intVatType;
                local.invoiceInfo['isNet'] = qInvoice.blnIsNet;
                local.invoiceInfo['subtotal'] = qInvoice.decSubTotalPrice;
                local.invoiceInfo['total'] = qInvoice.decTotalPrice;
                local.invoiceInfo['totaltext'] = qInvoice.strTotalText;
                local.invoiceInfo['language'] = qInvoice.strLanguageISO;
                local.invoiceInfo['paymentstatus'] = application.objLanguage.getTrans(qInvoice.strInvoiceStatusVariable);
                local.invoiceInfo['paymentstatusVar'] = qInvoice.strInvoiceStatusVariable;
                local.invoiceInfo['paymentstatusID'] = qInvoice.intPaymentStatusID;
                local.invoiceInfo['paymentstatusColor'] = qInvoice.strColor;

                local.invoiceInfo['amountOpen'] = qInvoice.decTotalPrice;
                local.invoiceInfo['amountPaid'] = 0;

                qPayments = getInvoicePayments(arguments.invoiceID);
                local.paid = 0;

                if (qPayments.recordCount) {
                    cfloop(query="qPayments") {
                        local.paid = local.paid + qPayments.decAmount;
                    }
                }

                local.invoiceInfo['amountOpen'] = qInvoice.decTotalPrice - local.paid;
                local.invoiceInfo['amountPaid'] = local.paid;

            }


            qPositions = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: arguments.invoiceID}
                },
                sql = "
                    SELECT *
                    FROM invoice_positions
                    WHERE intInvoiceID = :invoiceID
                    ORDER BY intPosNumber
                "
            )

            if (qPositions.recordCount) {

                cfloop(query="qPositions") {

                    local.position[qPositions.currentRow]['invoicePosID'] = qPositions.intInvoicePosID;
                    local.position[qPositions.currentRow]['posNumber'] = qPositions.intPosNumber;
                    local.position[qPositions.currentRow]['title'] = qPositions.strTitle;
                    local.position[qPositions.currentRow]['description'] = qPositions.strDescription;
                    local.position[qPositions.currentRow]['singlePrice'] = qPositions.decSinglePrice;
                    local.position[qPositions.currentRow]['quantity']   = qPositions.decQuantity;
                    local.position[qPositions.currentRow]['unit'] = qPositions.strUnit;
                    local.position[qPositions.currentRow]['discountPercent'] = qPositions.intDiscountPercent;
                    local.position[qPositions.currentRow]['totalPrice'] = qPositions.decTotalPrice;
                    local.position[qPositions.currentRow]['vat'] = qPositions.decVat;
                    arrayAppend(local.positionArray, local.position[qPositions.currentRow]);

                }

            }

            local.invoiceInfo['positions'] = local.positionArray;


            qVat = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: arguments.invoiceID}
                },
                sql = "
                    SELECT *
                    FROM invoice_vat
                    WHERE intInvoiceID = :invoiceID
                "
            )

            if (qVat.recordCount) {

                 cfloop(query="qVat") {

                     local.vat[qVat.currentRow]['vat'] = qVat.decVat;
                     local.vat[qVat.currentRow]['vatText'] = qVat.strVatText;
                     local.vat[qVat.currentRow]['amount'] = qVat.decVatAmount;
                     arrayAppend(local.vatArray, local.vat[qVat.currentRow]);

                 }

            }

            local.invoiceInfo['vatArray'] = local.vatArray;

            return local.invoiceInfo;


        }

    }

    // Get invoice payments
    public query function getInvoicePayments(required numeric invoiceID) {

        if (arguments.invoiceID gt 0) {

            qPayments = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: arguments.invoiceID}
                },
                sql = "
                    SELECT *
                    FROM payments
                    WHERE intInvoiceID = :invoiceID
                    ORDER BY dtmPayDate
                "
            )

            return qPayments;

        }

    }


    // Get the colored invoice status badge
    public string function getInvoiceStatusBadge(required string language, required string color, required string variable) {

        cfsavecontent (variable="local.htmlForBadge") {
            echo("<span class='badge bg-#arguments.color#'>#application.objLanguage.getTrans(arguments.variable, arguments.language)#</span>")
        }

        return local.htmlForBadge;

    }


    // Insert payment
    public struct function insertPayment(required struct paymentStruct) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        local.type = "";
        local.customerID = 0;
        local.payrexxID = 0;

        if (!structKeyExists(arguments.paymentStruct, "invoiceID") or !isNumeric(paymentStruct.invoiceID)) {
            local.argsReturnValue['message'] = "No valid invoiceID found!";
            return local.argsReturnValue;
        }
        if (!structKeyExists(arguments.paymentStruct, "date") or !isDate(paymentStruct.date)) {
            local.argsReturnValue['message'] = "No valid payment date found!";
            return local.argsReturnValue;
        }
        if (!structKeyExists(arguments.paymentStruct, "amount") or !isNumeric(paymentStruct.amount)) {
            local.argsReturnValue['message'] = "No valid amount found!";
            return local.argsReturnValue;
        }
        if (structKeyExists(arguments.paymentStruct, "type")) {
            local.type = paymentStruct.type;
        }
        if (structKeyExists(arguments.paymentStruct, "customerID")) {
            local.customerID = paymentStruct.customerID;
        }
        if (structKeyExists(arguments.paymentStruct, "payrexxID")) {
            local.payrexxID = paymentStruct.payrexxID;
        }

        local.invoiceID = paymentStruct.invoiceID;
        local.date = paymentStruct.date;
        local.amount = paymentStruct.amount;

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: local.invoiceID},
                    customerID: {type: "numeric", value: local.customerID},
                    paydate: {type: "datetime", value: local.date},
                    amount: {type: "decimal", value: local.amount, scale: 2},
                    type: {type: "varchar", value: local.type},
                    payrexxID: {type: "numeric", value: local.payrexxID}
                },
                sql = "
                    INSERT INTO payments (intInvoiceID, intCustomerID, decAmount, dtmPayDate, strPaymentType, intPayrexxID)
                    VALUES (:invoiceID, :customerID, :amount, :paydate, :type, :payrexxID)
                "
            )

        } catch (any e) {

            local.argsReturnValue['message'] = e.message;
            return local.argsReturnValue;

        }

        // Update invoice status
        setInvoiceStatus(local.invoiceID);

        local.argsReturnValue['message'] = "OK";
        local.argsReturnValue['success'] = true;
        return local.argsReturnValue;


    }


    // Delete payment
    public any function deletePayment(required numeric paymentID) {

        local.qInvoice = queryExecute(
            options = {datasource = application.datasource},
            params = {
                paymentID: {type: "numeric", value: arguments.paymentID},
            },
            sql = "
                SELECT intInvoiceID
                FROM payments
                WHERE intPaymentID = :paymentID
            "
        )

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                paymentID: {type: "numeric", value: arguments.paymentID},
            },
            sql = "
                DELETE FROM payments WHERE intPaymentID = :paymentID
            "
        )

        if (local.qInvoice.recordCount) {
            setInvoiceStatus(local.qInvoice.intInvoiceID);
        }

    }



    public void function setInvoiceStatus(required numeric invoiceID, numeric status) {

        if (structKeyExists(arguments, "status")) {

            // Update invoice
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: arguments.invoiceID},
                    status: {type: "numeric", value: arguments.status}
                },
                sql = "
                    UPDATE invoices
                    SET intPaymentStatusID = :status
                    WHERE intInvoiceID = :invoiceID
                "
            )

        } else {

            // Check payments
            local.qPayments = getInvoicePayments(arguments.invoiceID);
            local.paid = 0;

            if (qPayments.recordCount) {
                cfloop(query="qPayments") {
                    local.paid = local.paid + qPayments.decAmount;
                }
            }

            // Payment status
            objInvoice = getInvoiceData(arguments.invoiceID);
            local.invoiceAmount = objInvoice.total;
            local.dueDate = objInvoice.dueDate;
            if (local.paid eq 0) {
                local.status = 2; // open
                if (local.dueDate < dateFormat(now(), "yyyy-mm-dd")) {
                    local.status = 6; // overdue
                }
            } else if (local.paid lt local.invoiceAmount) {
                local.status = 4; // part paid
            } else if (local.paid gte local.invoiceAmount) {
                local.status = 3; // paid
            }

            // Update invoice
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: arguments.invoiceID},
                    status: {type: "numeric", value: local.status}
                },
                sql = "
                    UPDATE invoices
                    SET intPaymentStatusID = :status
                    WHERE intInvoiceID = :invoiceID
                "
            )

            // Update bookings if needed and paid
            if (local.status eq 3) {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        invoiceID: {type: "numeric", value: arguments.invoiceID}
                    },
                    sql = "
                        UPDATE bookings
                        SET strStatus = 'active'
                        WHERE strStatus = 'payment'
                        AND intBookingID =
                        COALESCE(
                            (
                                SELECT intBookingID
                                FROM invoices
                                WHERE intInvoiceID = :invoiceID
                            ), 0
                        )
                    "
                )
            }


        }

        return;

    }


    // Pay invoice over Payrexx
    public struct function payInvoice(required numeric invoiceID) {

        local.returnValue = structNew();
        local.returnValue['success'] = false;
        local.returnValue['message'] = "The payment could not be charged!";

        local.objPayrexx = new backend.core.com.payrexx();
        local.objInvoice = new backend.core.com.invoices();
        local.objNoti = new backend.core.com.notifications();

        local.qOpenInvoices = queryExecute(
            options = {datasource = application.datasource},
            params = {
                invoiceID: {type: "numeric", value: arguments.invoiceID}
            },
            sql = "
                SELECT invoices.strPrefix, invoices.intInvoiceNumber, invoices.strInvoiceTitle, invoices.decTotalPrice, invoices.intCustomerID,
                        payrexx.intTransactionID, payrexx.intPayrexxID, payrexx.strPaymentBrand
                FROM invoices INNER JOIN payrexx ON invoices.intCustomerID = payrexx.intCustomerID
                WHERE invoices.intInvoiceID = :invoiceID
                AND payrexx.blnFailed = 0
                AND payrexx.strStatus = 'authorized'
                ORDER BY payrexx.blnDefault DESC
            "
        )

        // Loop over all registered cards until the amount could be charged (default first)
        loop query="local.qOpenInvoices" {

            local.paymentStruct = structNew();
            local.paymentStruct['amount'] = local.qOpenInvoices.decTotalPrice * 100;
            local.paymentStruct['purpose'] = local.qOpenInvoices.strInvoiceTitle;
            local.paymentStruct['referenceId'] = local.qOpenInvoices.intCustomerID & "@" & application.projectname; // In order to recive the correct webhook, we need to pass the project name

            // Try to charge over Payrexx
            local.charge = local.objPayrexx.callPayrexx(local.paymentStruct, "POST", "Transaction", local.qOpenInvoices.intTransactionID);

            if (structKeyExists(local.charge, "status") and local.charge.status eq "success") {

                // Insert payment
                local.payment = structNew();
                local.payment['invoiceID'] = arguments.invoiceID;
                local.payment['customerID'] = local.qOpenInvoices.intCustomerID;
                local.payment['date'] = now();
                local.payment['amount'] = local.qOpenInvoices.decTotalPrice;
                local.payment['payrexxID'] = local.qOpenInvoices.intPayrexxID;
                local.payment['type'] = local.qOpenInvoices.strPaymentBrand;

                local.insPayment = local.objInvoice.insertPayment(local.payment);

                local.returnValue['invoiceID'] = arguments.invoiceID;
                local.returnValue['success'] = true;
                local.returnValue['message'] = "Charged successfully!";

                return local.returnValue;


            } else {

                // If not success, we have to disable the card and make a notification
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        payrexxID: {type: "numeric", value: local.qOpenInvoices.intPayrexxID}
                    },
                    sql = "
                        UPDATE payrexx
                        SET blnFailed = 1
                        WHERE intPayrexxID = :payrexxID
                    "
                )

                // Notification
                local.notiStruct = structNew();
                local.notiStruct['customerID'] = local.qOpenInvoices.intCustomerID;
                local.notiStruct['title_var'] = 'titChargingNotPossible';
                local.notiStruct['descr_var'] = 'txtChargingNotPossible';
                local.notiStruct['linktext_var'] = 'titPaymentSettings';
                local.notiStruct['link'] = '#application.mainURL#/account-settings/payment';
                local.objNoti.insertNotification(local.notiStruct);

            }

        }



        return local.returnValue;


    }


    // Get invoice address block
    public string function getInvoiceAddress(required numeric invoiceID) {

        local.invoiceData = new backend.core.com.invoices().getInvoiceData(arguments.invoiceID);
        local.customerID = local.invoiceData.customerID;

        // Get customer data
        local.customerData = application.objCustomer.getCustomerData(local.customerID);

        local.addressBlock = "";
        if (len(trim(local.customerData.billingAccountName)) and len(trim(local.customerData.billingAddress))) {

            cfsavecontent(variable="local.addressBlock") {
                echo(
                    "
                        #local.customerData.billingAccountName#<br />
                        #replace(local.customerData.billingAddress, chr(13), '<br />', 'all')#<br />
                    "
                )
            }

        } else {

            local.invoicePerson = "";
            if (structKeyExists(local.invoiceData, "userID") and (local.invoiceData.userID) gt 0) {
                local.userData = application.objCustomer.getUserDataByID(local.invoiceData.userID);
                if (len(trim(local.userData.strSalutation))) {
                    local.invoicePerson = local.userData.strSalutation & " " & local.userData.strFirstName & " " & local.userData.strLastName;
                } else {
                    local.invoicePerson = local.userData.strFirstName & " " & local.userData.strLastName;
                }
            } else {

            }

            cfsavecontent(variable="local.addressBlock") {
                echo(
                    "
                        #local.customerData.companyName#<br />
                        #len(local.invoicePerson) ? local.invoicePerson & "<br />" : ""#
                        #len(local.customerData.address) ? local.customerData.address & "<br />" : ""#
                        #len(local.customerData.address2) ? local.customerData.address2 & "<br />" : ""#
                        #len(local.customerData.zip) ? local.customerData.zip & " " : ""# #len(local.customerData.city) ? local.customerData.city & "<br />" : ""#
                        #len(local.customerData.countryName) ? local.customerData.countryName & "<br />" : ""#
                    "
                )
            }
        }


        return local.addressBlock;


    }


    // Send invoice by e-mail
    public struct function sendInvoice(required numeric invoiceID) {

        local.returnValue = structNew();
        local.returnValue['success'] = false;
        local.returnValue['message'] = "";

        getTrans = application.objLanguage.getTrans;

        local.invoiceID = arguments.invoiceID;

        // Get invoice data
        local.invoiceData = getInvoiceData(local.invoiceID);

        if (!structIsEmpty(local.invoiceData)) {
            local.customerID = local.invoiceData.customerID;
        } else {
            return local.returnValue['message'] = "No invoice found!";
        }

        try {

            // Create UUID and save into table
            local.uuid = application.objGlobal.getUUID();
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: local.invoiceID},
                    uuid: {type: "varchar", value: local.uuid}
                },
                sql = "
                    UPDATE invoices
                    SET strUUID = :uuid
                    WHERE intInvoiceID = :invoiceID
                "
            )

            // Build the link in order to download the pdf without login
            local.dl_link = application.mainURL & "/account-settings/invoice/print?pdf=" & local.uuid;

            // Get the invoicing email address
            local.customerData = application.objCustomer.getCustomerData(local.customerID);
            if (len(trim(local.customerData.billingEmail))) {
                local.toEmail = local.customerData.billingEmail;
            } else {
                local.toEmail = local.customerData.email;
            }

            local.invoicePerson = "";
            if (structKeyExists(local.invoiceData, "userID") and (local.invoiceData.userID) gt 0) {
                local.userData = application.objCustomer.getUserDataByID(local.invoiceData.userID);
                if (len(trim(userData.strSalutation))) {
                    local.invoicePerson = local.userData.strSalutation & " " & local.userData.strFirstName & " " & local.userData.strLastName;
                } else {
                    local.invoicePerson = local.userData.strFirstName & " " & local.userData.strLastName;
                }
            }

            variables.mailTitle = getTrans('titInvoiceReady', local.customerData.language);
            variables.mailType = "html";

            cfsavecontent (variable = "variables.mailContent") {

                echo("
                    #getTrans('titHello', local.customerData.language)#  #local.invoicePerson#<br><br>
                    #getTrans('msgThanksForPurchaseFindInvoice', local.customerData.language)#<br><br>
                    #getTrans('txtDownloadInvoice', local.customerData.language)#<br><br>
                    <a href='#local.dl_link#' style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#getTrans('btnDownloadInvoice', local.customerData.language)#</a>
                    <br><br>
                    #getTrans('txtRegards', local.customerData.language)#<br>
                    #getTrans('txtYourTeam', local.customerData.language)#<br>
                    #application.appOwner#
                ");
            }

            // Send activation link
            mail to="#local.toEmail#" from="#application.fromEmail#" subject="#getTrans('titInvoiceReady', local.customerData.language)#" type="html" {
                include template="/config.cfm";
                include template="/frontend/core/mail_design.cfm";
            }


        } catch (any e) {

            local.returnValue['message'] = e.message;
            return local.returnValue;

        }

        local.returnValue['success'] = true;
        return local.returnValue;


    }


    // Send email with payment request
    public struct function sendPaymentRequest(required numeric invoiceID) {

        local.returnValue = structNew();
        local.returnValue['success'] = false;
        local.returnValue['message'] = "";

        getTrans = application.objLanguage.getTrans;

        local.invoiceID = arguments.invoiceID;

        // Get invoice data
        local.invoiceData = getInvoiceData(local.invoiceID);

        if (!structIsEmpty(local.invoiceData)) {
            local.customerID = local.invoiceData.customerID;
        } else {
            return local.returnValue['message'] = "No invoice found!";
        }

        try {

            // Get the invoicing email address
            local.customerData = application.objCustomer.getCustomerData(local.customerID);
            if (len(trim(local.customerData.billingEmail))) {
                local.toEmail = local.customerData.billingEmail;
            } else {
                local.toEmail = local.customerData.email;
            }

            local.invoicePerson = "";
            if (structKeyExists(local.invoiceData, "userID") and (local.invoiceData.userID) gt 0) {
                local.userData = application.objCustomer.getUserDataByID(local.invoiceData.userID);
                if (len(trim(userData.strSalutation))) {
                    local.invoicePerson = local.userData.strSalutation & " " & local.userData.strFirstName & " " & local.userData.strLastName;
                } else {
                    local.invoicePerson = local.userData.strFirstName & " " & local.userData.strLastName;
                }
            }

            // Build the link to the invoice (incl. redirect)
            local.dl_link = application.mainURL & "/account-settings/invoice/" & local.invoiceID & "?redirect=" & urlEncodedFormat("account-settings/invoice/#local.invoiceID#?del_redirect");

            variables.mailTitle = getTrans('titInvoice', local.customerData.language) & " | " & local.invoiceData.title;
            variables.mailType = "html";

            cfsavecontent (variable = "variables.mailContent") {
                echo("
                    #getTrans('titHello', local.customerData.language)# #local.invoicePerson#<br><br>
                    #getTrans('txtPleasePayInvoice', local.customerData.language)#<br><br>
                    <a href='#local.dl_link#' style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#getTrans('txtViewInvoice', local.customerData.language)#</a>
                    <br><br>
                    #getTrans('txtRegards', local.customerData.language)#<br>
                    #getTrans('txtYourTeam', local.customerData.language)#<br>
                    #application.appOwner#
                ");
            }

            // Send activation link
            mail to="#local.toEmail#" from="#application.fromEmail#" subject="#variables.mailTitle#" type="html" {
                include template="/config.cfm";
                include template="/frontend/core/mail_design.cfm";
            }


        } catch (any e) {

            local.returnValue['message'] = e.message;
            return local.returnValue;

        }

        local.returnValue['success'] = true;
        return local.returnValue;


    }

    public query function getInvoice(required string invoiceUUID){

        local.qInvoice = queryExecute(
            options = {datasource = application.datasource},
            params = {
                uuid: {type: "varchar", value: arguments.invoiceUUID}
            },
            sql = "
                SELECT intInvoiceID
                FROM invoices
                WHERE strUUID = :uuid
            "
        )

        return local.qInvoice;
    }


    public struct function setSwissQrInvoiceStruct(required numeric deptorID, required numeric amount, string currency="CHF", string addText = "") {

        // get billers data (sysadmin)
        local.billerData = application.objSysAdmin.getSysAdminData();

        // Get deptors data (customer)
        local.deptorData = application.objCustomer.getCustomerData(arguments.deptorID);

        local.qrDataSet = {};

        if (isStruct(local.billerData)) {

            // Set the qr code size (square)
            local.qrDataSet['qrSize'] = "300";

            // Path to the swiss cross logo (if desired)
            local.qrDataSet['qrLogo'] = application.mainURL & "/dist/img/ch-cross.png";

            // Set all the needed data
            local.qrDataSet['billerIBAN'] = application.objSysAdmin.getSystemSetting('settingIBANnumber').strDefaultValue;
            local.qrDataSet['billerQrReference'] = application.objSysAdmin.getSystemSetting('settingQRreference').strDefaultValue;

            local.qrDataSet['billerName'] = len(trim(local.billerData.companyName)) ? local.billerData.companyName : local.billerData.strContactPerson; // Company or Pre- and Lastname
            local.qrDataSet['billerStreetAndNumber'] = local.billerData.address; // Street and number
            local.qrDataSet['billerZipAndCity'] = local.billerData.zip & " " & local.billerData.city; // ZIP and City
            local.qrDataSet['billerCountryIso'] =  "CH"; // Only CH possible because its Swiss bill

            local.qrDataSet['debtorName'] = len(trim(local.deptorData.companyName)) ? local.deptorData.companyName : local.deptorData.contactPerson; // Company or Pre- and Lastname
            local.qrDataSet['debtorStreetAndNumber'] = local.deptorData.address; // Street and number
            local.qrDataSet['debtorZipAndCity'] = local.deptorData.zip & " " & local.deptorData.city; // ZIP and City
            local.qrDataSet['debtorCountryIso'] = len(trim(local.deptorData.countryISO)) ? local.deptorData.countryISO : "CH"; // Country in ISO format (2 digits)

            local.qrDataSet['invoiceAmount'] = arguments.amount; // Amount (xxx.xx)
            local.qrDataSet['invoiceCurrency'] = arguments.currency; // Currency (only CHF or EUR possible)
            local.qrDataSet['invoiceAddText'] = arguments.addText; // Additional info text

        }

        return local.qrDataSet;

    }






}