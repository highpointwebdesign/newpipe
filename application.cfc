component {

	this.name = "RVMealPlanner"; // name of the application context
	this.dotNotationUpperCase = false;

	processingdirective preserveCase="true";
	
// regional
	// default locale used for formating dates, numbers ...
	this.locale = "en_US"; 
	// default timezone used
	this.timezone = "America/Chicago"; 

// scope handling
	// lifespan of an untouched application scope
	this.applicationTimeout = createTimeSpan( 1, 0, 0, 0 ); 
	
	// session handling enabled or not
	this.sessionManagement = true; 
	// cfml or jee based sessions
	this.sessionType = "cfml"; 
	// untouched session lifespan
	this.sessionTimeout = createTimeSpan( 0, 0, 30, 0 ); 
	this.sessionStorage = "memory";
	
	// client scope enabled or not
	this.clientManagement = false; 
	this.clientTimeout = createTimeSpan( 90, 0, 0, 0 );
	this.clientStorage = "cookie";
						
	// using domain cookies or not
	this.setDomainCookies = false; 
	this.setClientCookies = true;

	// prefer the local scope at un-scoped write
	this.localMode = "classic"; 
	
	// buffer the output of a tag/function body to output in case of an exception
	this.bufferOutput = false; 
	this.compression = false;
	this.suppressRemoteComponentContent = false;
	
	// If set to false Lucee ignores type definitions with function arguments and return values
	this.typeChecking = true;
	
	
// request
	// max lifespan of a running request
	this.requestTimeout=createTimeSpan(0,0,0,50); 

// charset
	this.charset.web="UTF-8";
	this.charset.resource="windows-1252";
	
	this.scopeCascading = "standard";
	this.searchResults = true;
// regex
	this.regex.type = "perl";
//////////////////////////////////////////////
//               MAIL SERVERS               //
//////////////////////////////////////////////
	this.mailservers =[ 

	];
//////////////////////////////////////////////
//               DATASOURCES                //
//////////////////////////////////////////////
	// sg details
//	database:
//	username: uwnfy23gc90sb
//	password: iar37kdgv46m

	//	datasources
		this.datasources["sg"] = {
			class: "com.mysql.cj.jdbc.Driver", 
			bundleName: "com.mysql.cj", 
			bundleVersion: "8.0.33",
			//	connectionString: "jdbc:mysql://34.174.216.218:3306/dbrhzbrqhhlw5g?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=EXCEPTION&serverTimezone=America/Chicago&maxReconnects=3&jdbcCompliantTruncation=true&allowMultiQueries=true",
			connectionString: "jdbc:mysql://localhost:3307/dbrhzbrqhhlw5g?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=EXCEPTION&serverTimezone=America/Chicago&maxReconnects=3&jdbcCompliantTruncation=true&allowMultiQueries=true",
			username: "root",
			password: "password",
			
			// optional settings
			connectionLimit:-1, // default:-1
			liveTimeout:15, // default: -1; unit: minutes
			alwaysSetTimeout:true, // default: false
			validate:false, // default: false
		};
//////////////////////////////////////////////
//                 CACHES                   //
//////////////////////////////////////////////
		

//////////////////////////////////////////////
//               MAPPINGS                   //
//////////////////////////////////////////////

this.mappings["/lucee/admin"]={
		physical:"{lucee-config}/context/admin"
		,archive:"{lucee-config}/context/lucee-admin.lar"};

this.mappings["/lucee/doc"]={
		archive:"{lucee-config}/context/lucee-doc.lar"};

}