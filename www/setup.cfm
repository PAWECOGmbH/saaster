<cfscript>
    this.datasources["saaster"] = {
		class: "com.mysql.cj.jdbc.Driver",
		bundleName: "com.mysql.cj",
		bundleVersion: "8.4.0",
		connectionString: "jdbc:mysql://mysql8:3306/saaster?characterEncoding=UTF-8&serverTimezone=Etc/UTC&maxReconnects=3&allowMultiQueries=true",
		username: "root",
		password: "encrypted:7ee10ae4170baece63b1b9df0d7f101f36f3a741836a52e8caf5153d4a3508c7",

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
</cfscript>