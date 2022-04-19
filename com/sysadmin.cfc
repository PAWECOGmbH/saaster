
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




}