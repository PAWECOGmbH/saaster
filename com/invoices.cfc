component displayname="invoices" output="false" {

    <!--- Create invoice number --->
    private numeric function createInvoiceNumber(required numeric customerID) {

        <!--- Check start number --->
        local.startNumber = application.objGlobal.getSetting(arguments.customerID, 'settingInvoiceNumberStart');
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

    <!--- Create invoice --->
    public struct function createInvoice(required struct invoiceData) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (structKeyExists(invoiceData, "customerID") and isNumeric(invoiceData.customerID)) {
            local.customerID = invoiceData.customerID;
        } else {
            local.argsReturnValue['message'] = "No customerID found!";
            return local.argsReturnValue;
        }
        local.invoiceNumber = createInvoiceNumber(local.customerID);
        if (structKeyExists(invoiceData, "prefix") and len(trim(invoiceData.prefix))) {
            local.prefix = left(invoiceData.prefix, 20);
        } else {
            local.prefix = application.objGlobal.getSetting(local.customerID, 'settingInvoicePrefix');
        }
        if (structKeyExists(invoiceData, "title") and len(trim(invoiceData.title))) {
            local.title = left(invoiceData.title, 50);
        } else {
            local.title = "";
        }
        if (structKeyExists(invoiceData, "invoiceDate") and isDate(invoiceData.invoiceDate)) {
            local.invoiceDate = invoiceData.invoiceDate;
        } else {
            local.invoiceDate = createODBCDate(now());
        }
        if (structKeyExists(invoiceData, "dueDate") and isDate(invoiceData.dueDate)) {
            local.dueDate = invoiceData.dueDate;
        } else {
            local.dueDate = createODBCDate(now()+30);
        }
        if (structKeyExists(invoiceData, "currency") and len(trim(invoiceData.currency))) {
            local.currency = left(invoiceData.currency, 3);
        } else {
            local.currency = IIF(len(trim(application.objGlobal.getDefaultCurrency().iso)), application.objGlobal.getDefaultCurrency().iso, 'USD');
        }
        if (structKeyExists(invoiceData, "isNet") and isBoolean(invoiceData.isNet)) {
            local.isNet = invoiceData.isNet;
        } else {
            local.isNet = application.objGlobal.getSetting(local.customerID, 'settingInvoiceNet');
        }
        if (structKeyExists(invoiceData, "paymentStatusID") and isNumeric(invoiceData.paymentStatusID) and invoiceData.paymentStatusID <= 5 and invoiceData.paymentStatusID > 0) {
            local.paymentStatusID = invoiceData.paymentStatusID;
        } else {
            local.paymentStatusID = 1;
        }
        if (structKeyExists(invoiceData, "vatType") and isNumeric(invoiceData.vatType) and invoiceData.vatType <= 3 and invoiceData.vatType > 0) {
            local.vatType = invoiceData.vatType;
        } else {
            local.vatType = application.objGlobal.getSetting(local.customerID, 'settingStandardVatType');
        }

        <!--- Total text --->
        local.customerLng = application.objCustomer.getCustomerData(local.customerID).strLanguageISO;
        if (!len(trim(local.customerLng))) {
            local.customerLng = application.objGlobal.getDefaultLanguage().iso;
        }
        if (local.vatType eq 1) {
            local.total_text = application.objGlobal.getTrans('txtTotalIncl', customerLng);
        } else if (local.vatType eq 2) {
            local.total_text = application.objGlobal.getTrans('txtTotalExcl', customerLng);
        } else if (local.vatType eq 3) {
            local.total_text = application.objGlobal.getTrans('txtExemptTax', customerLng);
        } else {
            local.total_text = "Total";
        }


        try {

             queryExecute(
                options = {datasource = application.datasource, result="getNewID"},
                params = {
                    customerID: {type: "numeric", value: local.customerID},
                    invoiceNumber: {type: "numeric", value: local.invoiceNumber},
                    prefix: {type: "nvarchar", value: local.prefix},
                    title: {type: "nvarchar", value: local.title},
                    invoiceDate: {type: "date", value: local.invoiceDate},
                    dueDate: {type: "date", value: local.dueDate},
                    currency: {type: "nvarchar", value: local.currency},
                    isNet: {type: "boolean", value: local.isNet},
                    vatType: {type: "numeric", value: local.vatType},
                    paymentStatusID: {type: "numeric", value: local.paymentStatusID},
                    total_text: {type: "nvarchar", value: local.total_text}
                },
                sql = "
                    INSERT INTO invoices (intCustomerID, intInvoiceNumber, strPrefix, strInvoiceTitle, dtmInvoiceDate, dtmDueDate, strCurrency, blnIsNet, intVatType, strTotalText, intPaymentStatusID)
                    VALUES (:customerID, :invoiceNumber, :prefix, :title, :invoiceDate, :dueDate, :currency, :isNet, :vatType, :total_text, :paymentStatusID)
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

    <!--- Update invoice --->
    public struct function updateInvoice(required struct invoiceData) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (structKeyExists(invoiceData, "invoiceID") and isNumeric(invoiceData.invoiceID)) {
            local.invoiceID = invoiceData.invoiceID;
        } else {
            local.argsReturnValue['message'] = "No invoiceID found!";
            return local.argsReturnValue;
        }
        local.customerID = new com.invoices().getInvoiceData(local.invoiceID).customerID;
        if (structKeyExists(invoiceData, "userID") and isNumeric(invoiceData.userID)) {
            local.userID = invoiceData.userID;
        } else {
           local.userID = "";
        }
        if (structKeyExists(invoiceData, "title") and len(trim(invoiceData.title))) {
            local.title = left(invoiceData.title, 50);
        } else {
            local.title = "";
        }
        if (structKeyExists(invoiceData, "invoiceDate") and isDate(invoiceData.invoiceDate)) {
            local.invoiceDate = invoiceData.invoiceDate;
        } else {
            local.invoiceDate = createODBCDate(now());
        }
        if (structKeyExists(invoiceData, "dueDate") and isDate(invoiceData.dueDate)) {
            local.dueDate = invoiceData.dueDate;
        } else {
            local.dueDate = createODBCDate(now()+30);
        }
        if (structKeyExists(invoiceData, "currency") and len(trim(invoiceData.currency))) {
            local.currency = left(invoiceData.currency, 3);
        } else {
            local.currency = IIF(len(trim(application.objGlobal.getDefaultCurrency().iso)), application.objGlobal.getDefaultCurrency().iso, 'USD');
        }
        if (structKeyExists(invoiceData, "isNet") and isBoolean(invoiceData.isNet)) {
            local.isNet = invoiceData.isNet;
        } else {
            local.isNet = application.objGlobal.getSetting(local.customerID, 'settingStandardNet');
        }
        if (structKeyExists(invoiceData, "vatType") and isNumeric(invoiceData.vatType) and invoiceData.vatType <= 3 and invoiceData.vatType > 0) {
            local.vatType = invoiceData.vatType;
        } else {
            local.vatType = application.objGlobal.getSetting(local.customerID, 'settingStandardVatType');
        }

        <!--- Total text --->
        local.customerLng = application.objCustomer.getCustomerData(local.customerID).strLanguageISO;
        if (!len(trim(local.customerLng))) {
            local.customerLng = application.objGlobal.getDefaultLanguage().iso;
        }
        if (local.vatType eq 1) {
            local.total_text = application.objGlobal.getTrans('txtTotalIncl', customerLng);
        } else if (local.vatType eq 2) {
            local.total_text = application.objGlobal.getTrans('txtTotalExcl', customerLng);
        } else if (local.vatType eq 3) {
            local.total_text = application.objGlobal.getTrans('txtExemptTax', customerLng);
        } else {
            local.total_text = "Total";
        }

        try {

             queryExecute(
                options = {datasource = application.datasource, result="getNewID"},
                params = {
                    invoiceID: {type: "numeric", value: local.invoiceID},
                    userID: {type: "numeric", value: local.userID},
                    title: {type: "nvarchar", value: local.title},
                    invoiceDate: {type: "date", value: local.invoiceDate},
                    dueDate: {type: "date", value: local.dueDate},
                    currency: {type: "nvarchar", value: local.currency},
                    isNet: {type: "boolean", value: local.isNet},
                    vatType: {type: "numeric", value: local.vatType}
                },
                sql = "
                    UPDATE invoices
                    SET intUserID = :userID,
                        strInvoiceTitle = :title,
                        dtmInvoiceDate = :invoiceDate,
                        dtmDueDate = :dueDate,
                        strCurrency = :currency,
                        blnIsNet = :isNet,
                        intVatType = :vatType
                    WHERE intInvoiceID = :invoiceID
                "
            )

        } catch (any e) {

            local.argsReturnValue['message'] = e.message;
            return argsReturnValue;

        }

        <!--- Recalculating --->
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



    <!--- Insert invoice positions --->
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

        <!--- Do we have to delete all positions first? --->
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

            <!--- Get the last position of this invoice --->
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

                if (structKeyExists(pos, "title") and len(trim(pos.title))) {
                    local.title = left(pos.title, 255);
                } else {
                    local.title = "";
                }
                if (structKeyExists(pos, "description") and len(trim(pos.description))) {
                    local.description = left(pos.description, 1000);
                } else {
                    local.description = "";
                }
                if (structKeyExists(pos, "price") and isNumeric(pos.price)) {
                    local.single_price = pos.price;
                } else {
                    local.single_price = 0;
                }
                if (structKeyExists(pos, "quantity") and isNumeric(pos.quantity)) {
                    local.quantity = pos.quantity;
                } else {
                    local.quantity = 1;
                }
                if (structKeyExists(pos, "unit") and len(trim(pos.unit))) {
                    local.unit = left(pos.unit, 20);
                } else {
                    local.unit = "";
                }
                if (structKeyExists(pos, "discountPercent") and isNumeric(pos.discountPercent)) {
                    local.discountPercent = pos.discountPercent;
                } else {
                    local.discountPercent = 0;
                }
                if (structKeyExists(pos, "vat") and isNumeric(pos.vat)) {
                    local.vat = pos.vat;
                } else {
                    local.vat = 0;
                }

                <!--- Calculate discount (percent) --->
                if (local.discountPercent gt 0) {

                    local.discount = local.single_price*local.discountPercent/100;
                    local.new_price = local.single_price-local.discount;

                    local.price = round((local.new_price*local.quantity), 2);

                <!--- No discount --->
                } else {

                    local.price = round((local.single_price*local.quantity), 2);

                }

                try {

                    <!--- Insert position --->
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

            <!--- Recalculating --->
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

    <!--- Update position --->
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

        if(local.qInvoice.recordCount){
            local.invoiceID = local.qInvoice.intInvoiceID;
        } else {
            local.argsReturnValue['message'] = "No invoice found!";
            return local.argsReturnValue;
        }

        if (structKeyExists(arguments.invoicePosData, "title") and len(trim(arguments.invoicePosData.title))) {
            local.title = left(arguments.invoicePosData.title, 255);
        } else {
            local.title = "";
        }
        if (structKeyExists(arguments.invoicePosData, "description") and len(trim(arguments.invoicePosData.description))) {
            local.description = left(arguments.invoicePosData.description, 1000);
        } else {
            local.description = "";
        }
        if (structKeyExists(arguments.invoicePosData, "price") and isNumeric(arguments.invoicePosData.price)) {
            local.single_price = arguments.invoicePosData.price;
        } else {
            local.single_price = 0;
        }
        if (structKeyExists(arguments.invoicePosData, "quantity") and isNumeric(arguments.invoicePosData.quantity)) {
            local.quantity = arguments.invoicePosData.quantity;
        } else {
            local.quantity = 1;
        }
        if (structKeyExists(arguments.invoicePosData, "unit") and len(trim(arguments.invoicePosData.unit))) {
            local.unit = left(arguments.invoicePosData.unit, 20);
        } else {
            local.unit = "";
        }
        if (structKeyExists(arguments.invoicePosData, "discountPercent") and isNumeric(arguments.invoicePosData.discountPercent)) {
            local.discountPercent = arguments.invoicePosData.discountPercent;
        } else {
            local.discountPercent = 0;
        }
        if (structKeyExists(arguments.invoicePosData, "vat") and isNumeric(arguments.invoicePosData.vat)) {
            local.vat = arguments.invoicePosData.vat;
        } else {
            local.vat = 0;
        }
        if (structKeyExists(arguments.invoicePosData, "pos") and isNumeric(arguments.invoicePosData.pos)) {
            local.pos = arguments.invoicePosData.pos;
        } else {
            local.pos = 0;
        }

        <!--- Calculate discount (percent) --->
        if (local.discountPercent gt 0) {

            local.discount = local.single_price*local.discountPercent/100;
            local.new_price = local.single_price-local.discount;

            local.price = round((local.new_price*local.quantity), 2);

        <!--- No discount --->
        } else {

            local.price = round((local.single_price*local.quantity), 2);

        }

        <!--- Update position --->
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


        <!--- Recalculating --->
        local.recalc = recalculateInvoice(local.invoiceID);

        if (local.recalc.success) {
            local.argsReturnValue['success'] = true;
            local.argsReturnValue['message'] = "OK";
        } else {
            local.argsReturnValue['message'] = "Error in function recalculateInvoice()";
        }

        return local.argsReturnValue;

    }

    <!--- Delete position --->
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


                <!--- Recalculating --->
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

    <!--- Recalculate the invoice --->
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
                SELECT invoices.intCustomerID, invoices.blnIsNet, invoices.intVatType, invoice_positions.*
                FROM invoices LEFT JOIN invoice_positions ON invoices.intInvoiceID = invoice_positions.intInvoiceID
                WHERE invoices.intInvoiceID = :invoiceID
            "
        )

        <!--- Customers language --->
        local.customerLng = application.objCustomer.getCustomerData(qInvoicePositions.intCustomerID).strLanguageISO;
        if (!len(trim(local.customerLng))) {
            local.customerLng = application.objGlobal.getDefaultLanguage().iso;
        }

        <!--- Delete vat table --->
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

            <!--- Loop over all positions --->
            cfloop(query="qInvoicePositions") {

                <!--- Calc prices --->
                local.vat_amount = calcVat(qInvoicePositions.decTotalPrice, qInvoicePositions.blnIsNet, qInvoicePositions.decVat);
                local.vat_total = local.vat_total + local.vat_amount;
                local.subtotal_price = local.subtotal_price + qInvoicePositions.decTotalPrice;

                <!--- Define vat text and sum --->
                if (qInvoicePositions.blnIsNet eq 1) {
                    local.vat_text = application.objGlobal.getTrans('txtPlusVat', local.customerLng) & ' ' & numberFormat(qInvoicePositions.decVat, '__.__') & '%';
                } else {
                    local.vat_text = application.objGlobal.getTrans('txtVatIncluded', local.customerLng) & ' ' & numberFormat(qInvoicePositions.decVat, '__.__') & '%';
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

        <!--- Round subtotal according customers setting --->
        local.subtotal_price = roundAmount(local.subtotal_price, application.objGlobal.getSetting(qInvoicePositions.intCustomerID, 'settingRoundFactor'));

        <!--- Add up subtotal and vat --->
        if (qInvoicePositions.blnIsNet eq 1) {
            local.total_price = local.subtotal_price + local.vat_total;
        } else {
            local.total_price = local.subtotal_price;
        }

        <!--- Round total according customers setting --->
        local.total_price = roundAmount(local.total_price, application.objGlobal.getSetting(qInvoicePositions.intCustomerID, 'settingRoundFactor'));

        <!--- Define total text --->
        if (qInvoicePositions.intVatType eq 1) {
            local.total_text = application.objGlobal.getTrans('txtTotalIncl', local.customerLng);
        } else if (qInvoicePositions.intVatType eq 2) {
            local.total_text = application.objGlobal.getTrans('txtTotalExcl', local.customerLng);
            local.total_price = local.subtotal_price;
        } else {
            local.total_text = application.objGlobal.getTrans('txtExemptTax', local.customerLng);
            local.total_price = local.subtotal_price;
        }


        <!--- Update invoice --->
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

    <!--- Calculating vat --->
    public numeric function calcVat(required numeric amount, required boolean isNet, required numeric rate) {

        if (arguments.isNet eq 0) {
            local.cvat = 10 & arguments.rate;
            local.vat_amount = (arguments.amount/local.cvat)*arguments.rate;
        } else {
            local.vat_amount = (arguments.amount/100)*arguments.rate;
        }

        return local.vat_amount;

    }

    <!--- Round prices depending on settings --->
    public numeric function roundAmount(required numeric amount, required numeric factor) {

        if (arguments.factor eq 5) {
            local.rounded_price = round(arguments.amount*20)/20;
        } else {
            local.rounded_price = arguments.amount;
        }

        return local.rounded_price;

    }

    <!--- Get customers invoices --->
    public query function getInvoices(required numeric customerID) {

        if (arguments.customerID gt 0) {

            qInvoice = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT  invoices.intInvoiceID as invoiceID,
                            CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) as invoiceNumber,
                            invoices.strInvoiceTitle as invoiceTitle,
                            DATE_FORMAT(invoices.dtmInvoiceDate, '%Y-%m-%d') as invoiceDate,
                            DATE_FORMAT(invoices.dtmDueDate, '%Y-%m-%d') as invoiceDueDate,
                            invoices.strCurrency as invoiceCurrency,
                            invoices.decTotalPrice as invoiceTotal,
                            invoice_status.strInvoiceStatusVariable as invoiceStatusVariable,
                            invoice_status.strColor as invoiceStatusColor
                    FROM invoices
                    INNER JOIN invoice_status ON 1=1
                    AND invoices.intPaymentStatusID = invoice_status.intPaymentStatusID
                    AND invoices.intPaymentStatusID > 1
                    AND invoices.intCustomerID = :customerID

                "
            )

            return qInvoice;

        }

    }

    <!--- Get invoice data --->
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
                local.invoiceInfo['date'] = dateFormat(qInvoice.dtmInvoiceDate, 'yyyy-mm-dd');
                local.invoiceInfo['dueDate'] = dateFormat(qInvoice.dtmDueDate, 'yyyy-mm-dd');
                local.invoiceInfo['currency'] = qInvoice.strCurrency;
                local.invoiceInfo['vatType'] = qInvoice.intVatType;
                local.invoiceInfo['isNet'] = qInvoice.blnIsNet;
                local.invoiceInfo['subtotal'] = qInvoice.decSubTotalPrice;
                local.invoiceInfo['total'] = qInvoice.decTotalPrice;
                local.invoiceInfo['totaltext'] = qInvoice.strTotalText;
                local.invoiceInfo['paymentstatus'] = application.objGlobal.getTrans(qInvoice.strInvoiceStatusVariable);
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

    <!--- Get invoice payments --->
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


    <!--- Get the colored invoice status badge --->
    public string function getInvoiceStatusBadge(required string language, required string color, required string variable) {

        cfsavecontent (variable="local.htmlForBadge") {
            echo("<span class='badge bg-#arguments.color#'>#application.objGlobal.getTrans(arguments.variable, arguments.language)#</span>")
        }

        return local.htmlForBadge;

    }


    <!--- Insert payment --->
    public struct function insertPayment(required struct paymentStruct) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (!structKeyExists(arguments.paymentStruct, "invoiceID") or !isNumeric(paymentStruct.invoiceID)) {
            local.argsReturnValue['message'] = "No valid invoiceID found!";
            return local.argsReturnValue;
        }
        if (!structKeyExists(arguments.paymentStruct, "date") or !isDate(paymentStruct.date)) {
            local.argsReturnValue['message'] = "No valid payment date found!";
            return local.argsReturnValue;
        }
        if (!structKeyExists(arguments.paymentStruct, "amount") or !isNumeric(paymentStruct.amount)) {
            local.argsReturnValue['message'] = "No valid payment date found!";
            return local.argsReturnValue;
        }
        if (structKeyExists(arguments.paymentStruct, "type")) {
            local.type = paymentStruct.type;
        } else {
            local.type = "";
        }

        local.invoiceID = paymentStruct.invoiceID;
        local.date = paymentStruct.date;
        local.amount = paymentStruct.amount;


        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    invoiceID: {type: "numeric", value: local.invoiceID},
                    paydate: {type: "date", value: local.date},
                    amount: {type: "decimal", value: local.amount, scale: 2},
                    type: {type: "varchar", value: local.type}
                },
                sql = "
                    INSERT INTO payments (intInvoiceID, decAmount, dtmPayDate, strPaymentType)
                    VALUES (:invoiceID, :amount, :paydate, :type)
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


    <!--- Delete payment --->
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
                    invoiceID: {type: "numeric", value: local.invoiceID},
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
                if (local.dueDate < now()) {
                    local.status = 6; // open
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

        }

        return;

    }







}