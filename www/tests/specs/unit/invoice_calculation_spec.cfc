component extends="testbox.system.BaseSpec" {

    /*
        invoices.cfc - the pure calculation helpers: VAT and rounding.
        No database involved.
    */

    function beforeAll() {
        variables.invoices = new backend.core.com.invoices();
    }

    // Two decimals as text, so floating point noise does not decide the result.
    private string function money(required numeric amount) {
        return numberFormat(arguments.amount, "0.00");
    }

    function run() {

        describe("calcVat on net amounts", () => {

            it("calculates 8.1% of 100", () => {
                expect(money(variables.invoices.calcVat(100, true, 8.1))).toBe("8.10");
            });

            it("calculates 19% of 200", () => {
                expect(money(variables.invoices.calcVat(200, true, 19))).toBe("38.00");
            });

            it("returns 0 for a rate of 0", () => {
                expect(money(variables.invoices.calcVat(100, true, 0))).toBe("0.00");
            });

        });

        describe("calcVat on gross amounts", () => {

            it("extracts 8.1% from 108.10", () => {
                expect(money(variables.invoices.calcVat(108.1, false, 8.1))).toBe("8.10");
            });

            it("extracts 2.6% from 102.60", () => {
                expect(money(variables.invoices.calcVat(102.6, false, 2.6))).toBe("2.60");
            });

            /*
                The VAT contained in a gross amount is gross / (100 + rate) * rate.
                Rates of 10% and more (e.g. 19% in Germany, 20% in Austria) must
                work just like the Swiss single-digit rates.
            */
            it("extracts 19% from 119.00", () => {
                expect(money(variables.invoices.calcVat(119, false, 19))).toBe("19.00");
            });

            it("extracts 20% from 120.00", () => {
                expect(money(variables.invoices.calcVat(120, false, 20))).toBe("20.00");
            });

        });

        describe("roundAmount", () => {

            it("rounds up to 5 cents with factor 5", () => {
                expect(money(variables.invoices.roundAmount(10.03, 5))).toBe("10.05");
            });

            it("rounds down to 5 cents with factor 5", () => {
                expect(money(variables.invoices.roundAmount(10.02, 5))).toBe("10.00");
            });

            it("rounds to 1 cent with any other factor", () => {
                expect(money(variables.invoices.roundAmount(12.344, 1))).toBe("12.34");
                expect(money(variables.invoices.roundAmount(12.346, 1))).toBe("12.35");
            });

        });

    }

}
