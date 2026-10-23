component extends="tests.support.integration_spec" {

    /*
        Dashboard widgets (widget.cfc::prepareUserWidgets) - issue #626.

        Regression 1: the booked modules were bound as one string ("3,5,7"), which
        MySQL reads as 3. Only the widgets of the first module were found.

        Regression 2: on every dashboard call, the user's widget entries that were not
        in that list were deleted - with the position and the on/off setting the user
        had chosen. A module that was missing from the session for a moment (payment
        pending, expired, stale session) wiped the settings for good.
    */

    function run() {

        var widgets = new backend.core.com.widget();

        describe("Dashboard widgets", () => {

            beforeEach(() => {
                variables.createdModules = [];
                variables.createdWidgets = [];

                variables.customerID = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID = variables.customerID);

                variables.moduleA = createModule("A");
                variables.moduleB = createModule("B");
                variables.moduleC = createModule("C");
                variables.widgetA = createWidget("A", variables.moduleA);
                variables.widgetB = createWidget("B", variables.moduleB);
                variables.widgetC = createWidget("C", variables.moduleC);
            });

            afterEach(() => {
                for (var widgetID in variables.createdWidgets) {
                    queryExecute("DELETE FROM widgets WHERE intWidgetID = :id", { id: { type: "numeric", value: widgetID } }, { datasource: application.datasource });
                }
                for (var moduleID in variables.createdModules) {
                    queryExecute("DELETE FROM modules WHERE intModuleID = :id", { id: { type: "numeric", value: moduleID } }, { datasource: application.datasource });
                }
            });

            it("finds the widgets of every booked module, not only the first one", () => {
                var found = ownWidgets(valueList(widgets.getAllWidgets(variables.moduleA & "," & variables.moduleB & "," & variables.moduleC, 0).intWidgetID));

                expect(found).toBe([variables.widgetA, variables.widgetB, variables.widgetC]);
            });

            it("shows the widgets of all booked modules on the dashboard", () => {
                var shown = widgets.prepareUserWidgets(variables.user.userID, variables.moduleA & "," & variables.moduleB, 0);

                expect(ownWidgets(valueList(shown.intWidgetID))).toBe([variables.widgetA, variables.widgetB]);
            });

            it("keeps position and on/off setting while a module is unavailable", () => {
                widgets.prepareUserWidgets(variables.user.userID, variables.moduleA & "," & variables.moduleB, 0);
                setUserWidget(variables.widgetB, 1, 0);
                setUserWidget(variables.widgetA, 2, 1);

                // Module B is missing for a moment (e.g. payment pending)
                var shown = widgets.prepareUserWidgets(variables.user.userID, variables.moduleA, 0);
                expect(ownWidgets(valueList(shown.intWidgetID))).toBe([variables.widgetA], "Widget B must be hidden");

                // ... and is back
                shown = widgets.prepareUserWidgets(variables.user.userID, variables.moduleA & "," & variables.moduleB, 0);
                var rowB = shown.filter((row) => row.intWidgetID eq variables.widgetB);
                expect(rowB.recordCount).toBe(1);
                expect(rowB.intPrio).toBe(1, "The position chosen by the user is lost");
                expect(rowB.blnActive).toBe(0, "The on/off setting chosen by the user is lost");
            });

            it("keeps the settings when no module is available at all", () => {
                widgets.prepareUserWidgets(variables.user.userID, variables.moduleA, 0);
                setUserWidget(variables.widgetA, 5, 0);

                expect(ownWidgets(valueList(widgets.prepareUserWidgets(variables.user.userID, "", 0).intWidgetID))).toBeEmpty();

                var rowA = widgets.prepareUserWidgets(variables.user.userID, variables.moduleA, 0);
                expect(rowA.intPrio).toBe(5);
                expect(rowA.blnActive).toBe(0);
            });

            it("adds a newly available widget once, at the end", () => {
                widgets.prepareUserWidgets(variables.user.userID, variables.moduleA, 0);
                widgets.prepareUserWidgets(variables.user.userID, variables.moduleA & "," & variables.moduleC, 0);
                widgets.prepareUserWidgets(variables.user.userID, variables.moduleA & "," & variables.moduleC, 0);

                var entries = queryExecute(
                    "SELECT intWidgetID, intPrio FROM user_widgets WHERE intUserID = :userID AND intWidgetID IN (:ids) ORDER BY intPrio",
                    { userID: { type: "numeric", value: variables.user.userID }, ids: { type: "numeric", value: variables.widgetA & "," & variables.widgetC, list: true } },
                    { datasource: application.datasource }
                );
                expect(valueList(entries.intWidgetID)).toBe(variables.widgetA & "," & variables.widgetC);
            });

            it("hides a widget the sysadmin deactivated, without deleting the user's entry", () => {
                widgets.prepareUserWidgets(variables.user.userID, variables.moduleA, 0);
                queryExecute("UPDATE widgets SET blnActive = 0 WHERE intWidgetID = :id", { id: { type: "numeric", value: variables.widgetA } }, { datasource: application.datasource });

                expect(ownWidgets(valueList(widgets.prepareUserWidgets(variables.user.userID, variables.moduleA, 0).intWidgetID))).toBeEmpty();
                expect(userWidgetCount(variables.widgetA)).toBe(1);
            });

            it("ignores anything but whole numbers in the module list", () => {
                var found = ownWidgets(valueList(widgets.getAllWidgets(variables.moduleA & ",abc,1 OR 1=1," & variables.moduleB, 0).intWidgetID));

                expect(found).toBe([variables.widgetA, variables.widgetB]);
            });

        });

    }

    private numeric function createModule(required string name) {
        queryExecute(
            "INSERT INTO modules (strModuleName, blnActive, blnBookable, intNumTestDays, intPrio) VALUES (:name, 1, 1, 0, 999)",
            { name: { type: "varchar", value: "TestBox Module " & arguments.name } },
            { datasource: application.datasource, result: "local.result" }
        );
        arrayAppend(variables.createdModules, local.result.generatedKey);
        return local.result.generatedKey;
    }

    private numeric function createWidget(required string name, required numeric moduleID) {
        queryExecute(
            "INSERT INTO widgets (strWidgetName, strFilePath, blnActive, intRatioID, blnPermDisplay) VALUES (:name, '/testbox/widget.cfm', 1, 1, 0)",
            { name: { type: "varchar", value: "TestBox Widget " & arguments.name } },
            { datasource: application.datasource, result: "local.result" }
        );
        var widgetID = local.result.generatedKey;
        arrayAppend(variables.createdWidgets, widgetID);

        queryExecute(
            "INSERT INTO widgets_modules (intWidgetID, intModuleID) VALUES (:widgetID, :moduleID)",
            { widgetID: { type: "numeric", value: widgetID }, moduleID: { type: "numeric", value: arguments.moduleID } },
            { datasource: application.datasource }
        );
        return widgetID;
    }

    private void function setUserWidget(required numeric widgetID, required numeric prio, required numeric active) {
        queryExecute(
            "UPDATE user_widgets SET intPrio = :prio, blnActive = :active WHERE intUserID = :userID AND intWidgetID = :widgetID",
            {
                prio: { type: "numeric", value: arguments.prio },
                active: { type: "numeric", value: arguments.active },
                userID: { type: "numeric", value: variables.user.userID },
                widgetID: { type: "numeric", value: arguments.widgetID }
            },
            { datasource: application.datasource }
        );
    }

    private numeric function userWidgetCount(required numeric widgetID) {
        return queryExecute(
            "SELECT COUNT(*) AS cnt FROM user_widgets WHERE intUserID = :userID AND intWidgetID = :widgetID",
            { userID: { type: "numeric", value: variables.user.userID }, widgetID: { type: "numeric", value: arguments.widgetID } },
            { datasource: application.datasource }
        ).cnt;
    }

    // Only the widgets this spec created, in ascending order (the database may hold others)
    private array function ownWidgets(required string widgetIDs) {
        var own = listToArray(arguments.widgetIDs).map((id) => val(id)).filter((id) => arrayFind(variables.createdWidgets, id));
        own.sort("numeric");
        return own;
    }

}
