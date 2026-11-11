component output="false" {

    variables.calls = [];
    variables.failOnCall = false;
    variables.warnModuleID = 0;

    public void function afterBookingAccessEnded(
        required numeric customerID,
        required numeric moduleID,
        required string reason
    ) {
        arrayAppend(variables.calls, duplicate(arguments));
        if (variables.failOnCall) {
            throw(type = "Test.SubscriptionHookFailure", message = "Simulated module cleanup failure");
        }
    }

    public boolean function deletesCustomerDataOnWithdraw(required numeric moduleID) {
        return arguments.moduleID eq variables.warnModuleID;
    }

    public void function setWarnModule(required numeric moduleID) {
        variables.warnModuleID = arguments.moduleID;
    }

    public array function getCalls() {
        return variables.calls;
    }

    public void function setFailure(required boolean failOnCall) {
        variables.failOnCall = arguments.failOnCall;
    }

}
