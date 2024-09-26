<cfscript>
    this.datasources["saaster_dev"] = {
		class: "com.mysql.cj.jdbc.Driver",
		bundleName: "com.mysql.cj",
		bundleVersion: "8.4.0",
		connectionString: "jdbc:mysql://mysql_dev:3306/mysql_database?characterEncoding=UTF-8&serverTimezone=Etc/UTC&maxReconnects=3&allowMultiQueries=true",
		username: "root",
		password: "encrypted:1b0e4cb3e71cee3db00ec826396e1c6b6268659da807bde426d2c793e9ef9517239a533165a2515a",

		// optional settings
		connectionLimit:-1, // default:-1
		liveTimeout:15, // default: -1; unit: minutes
		alwaysSetTimeout:true, // default: false
		validate:false, // default: false
	};
	this.mailservers =[ {
		host: 'inbucket'
		, port: 2500
		, username: ''
		, password:  ''
		, ssl: false
		, tls: false
		, lifeTimespan: createTimeSpan(0,0,4,0)
		, idleTimespan: createTimeSpan(0,0,1,0)
	}];

	variables.datasource = "saaster_dev";

</cfscript>