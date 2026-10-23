component extends="tests.support.integration_spec" {

    /*
        book.cfc::updateBooking - changing status and period of a booking.

        Regression: the old version crashed with "can't cast [] to date value"
        when only the status of a booking with SQL NULL dates was updated
        (e.g. by the scheduler setting a booking to "expired"). Nullable dates
        need an explicit NULL flag in Lucee 6, and malformed dates must be
        rejected instead of silently clearing a booking period.

        Moved here from the former tests/payment-regression runner. That runner
        also checked Lucee's full NULL support mode; Saaster runs without it,
        so only the default mode is covered.
    */

    // Reads a booking straight from the database, independent of book.cfc.
    private query function readBooking(required numeric bookingID) {
        return queryExecute(
            "SELECT intBookingID, strStatus,
                    DATE_FORMAT(dteStartDate, '%Y-%m-%d') AS startDate,
                    DATE_FORMAT(dteEndDate, '%Y-%m-%d') AS endDate,
                    dteStartDate IS NULL AS startIsNull,
                    dteEndDate IS NULL AS endIsNull
             FROM bookings WHERE intBookingID = :bookingID",
            { bookingID: { type: "numeric", value: arguments.bookingID } },
            { datasource: application.datasource }
        );
    }

    function run() {

        describe("updateBooking", () => {

            beforeEach(() => {
                variables.logs = recordLogs();
                variables.book = new backend.core.com.book();
                variables.customerID = variables.fixtures.createCustomer();
            });

            afterEach(() => {
                restoreLogs();
            });

            describe("on a booking without dates", () => {

                beforeEach(() => {
                    variables.bookingID = variables.fixtures.createBooking(customerID = variables.customerID, status = "payment");
                });

                it("updates the status", () => {
                    expect(variables.book.updateBooking({ bookingID: variables.bookingID, status: "expired" })).toBe(variables.bookingID);
                    expect(readBooking(variables.bookingID).strStatus).toBe("expired");
                });

                it("keeps the NULL dates NULL", () => {
                    variables.book.updateBooking({ bookingID: variables.bookingID, status: "expired" });

                    var row = readBooking(variables.bookingID);
                    expect(row.startIsNull).toBe(1);
                    expect(row.endIsNull).toBe(1);
                });

                it("accepts a valid period", () => {
                    expect(variables.book.updateBooking({ bookingID: variables.bookingID, dateStart: "2026-09-01", dateEnd: "2026-09-30" })).toBe(variables.bookingID);

                    var row = readBooking(variables.bookingID);
                    expect(row.startDate).toBe("2026-09-01");
                    expect(row.endDate).toBe("2026-09-30");
                });

            });

            describe("on a booking with a period", () => {

                beforeEach(() => {
                    variables.bookingID = variables.fixtures.createBooking(
                        customerID = variables.customerID,
                        startDate  = "2026-09-01",
                        endDate    = "2026-09-30",
                        status     = "active"
                    );
                });

                it("keeps the existing dates on a status-only update", () => {
                    variables.book.updateBooking({ bookingID: variables.bookingID, status: "expired" });

                    var row = readBooking(variables.bookingID);
                    expect(row.startDate).toBe("2026-09-01");
                    expect(row.endDate).toBe("2026-09-30");
                });

                it("keeps the omitted date on a partial period update", () => {
                    variables.book.updateBooking({ bookingID: variables.bookingID, dateEnd: "2026-10-31" });

                    var row = readBooking(variables.bookingID);
                    expect(row.startDate).toBe("2026-09-01");
                    expect(row.endDate).toBe("2026-10-31");
                });

                it("stores explicitly empty dates as SQL NULL", () => {
                    variables.book.updateBooking({ bookingID: variables.bookingID, dateStart: "", dateEnd: " " });

                    var row = readBooking(variables.bookingID);
                    expect(row.startIsNull).toBe(1);
                    expect(row.endIsNull).toBe(1);
                });

                it("rejects a malformed date string with booking and field in the message", () => {
                    expect(() => {
                        variables.book.updateBooking({ bookingID: variables.bookingID, dateEnd: "invalid-date", status: "expired" });
                    }).toThrow(type = "InvalidBookingDate", regex = "dateEnd.*#variables.bookingID#");
                });

                it("rejects a non-simple date value with booking and field in the message", () => {
                    expect(() => {
                        variables.book.updateBooking({ bookingID: variables.bookingID, dateEnd: [], status: "expired" });
                    }).toThrow(type = "InvalidBookingDate", regex = "dateEnd.*#variables.bookingID#");
                });

                it("leaves the booking untouched when a date is rejected", () => {
                    try {
                        variables.book.updateBooking({ bookingID: variables.bookingID, dateEnd: "invalid-date", status: "expired" });
                    } catch (InvalidBookingDate e) {
                        // expected, see the specs above
                    }

                    var row = readBooking(variables.bookingID);
                    expect(row.strStatus).toBe("active");
                    expect(row.endDate).toBe("2026-09-30");
                });

            });

            describe("without a valid booking", () => {

                it("returns 0 for a booking that does not exist", () => {
                    expect(variables.book.updateBooking({ bookingID: 999999999, status: "expired" })).toBe(0);
                });

                it("returns 0 for a missing, zero or non-numeric booking ID", () => {
                    expect(variables.book.updateBooking({})).toBe(0);
                    expect(variables.book.updateBooking({ bookingID: 0 })).toBe(0);
                    expect(variables.book.updateBooking({ bookingID: "invalid" })).toBe(0);
                });

                it("writes no log entry", () => {
                    variables.book.updateBooking({ bookingID: 999999999, status: "expired" });
                    variables.book.updateBooking({});

                    expect(variables.logs.count()).toBe(0);
                });

            });

        });

    }

}
