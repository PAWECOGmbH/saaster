component output="false" hint="Stands in for application.objLog during a spec and records every log call." {

    /*
        The real log.cfc writes files into www/logs and can send mails. During a
        test run neither is wanted - and often the log call itself is what a spec
        wants to check ("a missing booking writes no success log").

        integration_spec.cfc swaps this in with recordLogs() and puts the real
        logger back afterwards, even if the spec fails.
    */

    public any function init() {
        variables.calls = [];
        return this;
    }

    public void function logWrite(required string type, required string level, required string message, boolean sendMail, datetime date) {
        arrayAppend(variables.calls, {
            "type": arguments.type,
            "level": arguments.level,
            "message": arguments.message
        });
    }

    public array function getCalls() {
        return variables.calls;
    }

    public numeric function count() {
        return arrayLen(variables.calls);
    }

    public void function reset() {
        variables.calls = [];
    }

}
