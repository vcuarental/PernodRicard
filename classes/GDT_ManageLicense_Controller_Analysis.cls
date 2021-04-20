/**
 * Name     :   GDT_ManageLicense_Controller_Analysis.cls
 *  VFP, GDT_ManageLicense_Analysis.page
 *  Objet, GDT_ManageLicense_Analysis__c
 * 
 * Author   :   Simon GAZIN
 * Date     :   11.03.2015
 ***************************************************************/
public with sharing class GDT_ManageLicense_Controller_Analysis {
	/** Standard Controller */
	public final GDT_ManageLicense_Analysis__c mysObject;

	/** Variable Declaration */

	/** Retrieves the analysis list */
	public List<GDT_ManageLicense_Analysis__c> listAll_Analysis {get;set;}
	public List<GDT_ManageLicense_Analysis__c> listAll_Analysis_picklist {get;set;}
	public List<groupAnalysisWrapper> wrappers {get;set;}

	public List<groupAnalysisWrapper> licenseWrappers {get;set;}

	/** Hide/Display Chart */
	public Boolean bChartAffiliate   {get;set;}
	public Boolean bChartLicense     {get;set;}
	public Boolean bChartApplication {get;set;}

	//The extension constructor initializes the private member
	//variable mysObject by using the getRecord method from the standard
	//controller.
	public GDT_ManageLicense_Controller_Analysis(ApexPages.StandardController stdController) {
		this.mysObject = (GDT_ManageLicense_Analysis__c)stdController.getRecord();

		initializes();
	}


	/**
	 * Initializes
	 *  Initializes variables at start
	 */
	public void initializes() {
		//this.mysObject.GDT_Analysis_AffiliateGroup__c = 'Pernod Ricard';
		//this.mysObject.GDT_Analysis_AppName__c = 'BMC Remedyforce';
		bChartAffiliate   = false;
		bChartLicense     = false;
		bChartApplication = false;

	listAll_Analysis = [SELECT Id, GDT_Analysis_AffiliateGroup__c, GDT_Analysis_LicenseType__r.Name, GDT_Analysis_LicenseType__r.GDT_License_APIName__c, GDT_Analysis_TotalLicenses__c, GDT_Analysis_UsedLicenses__c, GDT_Analysis_RemainingLicenses__c, GDT_Analysis_DateLastUpdate__c, GDT_Analysis_AppName__c FROM GDT_ManageLicense_Analysis__c WHERE GDT_Analysis_LastUpdate__c=true  ORDER BY GDT_Analysis_AffiliateGroup__c, GDT_Analysis_LicenseType__c];
		listAll_Analysis_picklist = listAll_Analysis;

		wrappers = new List<groupAnalysisWrapper>();
		licenseWrappers = new List<groupAnalysisWrapper>();

		Map<String,groupAnalysisWrapper> tmpWrappers = new Map<String,groupAnalysisWrapper>();
		Map<String,groupAnalysisWrapper> tmplicenseWrappers = new Map<String,groupAnalysisWrapper>();

		for(GDT_ManageLicense_Analysis__c mAnalysis : listAll_Analysis){
			String apiName = mAnalysis.GDT_Analysis_LicenseType__r.GDT_License_APIName__c;
			String appNAme = mAnalysis.GDT_Analysis_AppName__c == null ? '' : mAnalysis.GDT_Analysis_AppName__c;
			if(tmpWrappers.containsKey(apiName + '-' + appNAme)){
				groupAnalysisWrapper tmp = tmpWrappers.get(apiName + '-' + appNAme);
				tmp.totalNumber += mAnalysis.GDT_Analysis_UsedLicenses__c;
				tmp.remainingLicenses += mAnalysis.GDT_Analysis_RemainingLicenses__c;
				tmp.totalLicenses += mAnalysis.GDT_Analysis_TotalLicenses__c;
				tmpWrappers.put(apiName + '-' + appNAme, tmp);
			}else{
				tmpWrappers.put(apiName + '-' + appNAme, new groupAnalysisWrapper(apiName,appNAme, mAnalysis.GDT_Analysis_UsedLicenses__c,mAnalysis.GDT_Analysis_TotalLicenses__c,mAnalysis.GDT_Analysis_RemainingLicenses__c));
			}

			if(tmplicenseWrappers.containsKey(apiName)){
				groupAnalysisWrapper tmp = tmplicenseWrappers.get(apiName);
				tmp.totalNumber += mAnalysis.GDT_Analysis_UsedLicenses__c;
				tmp.remainingLicenses += mAnalysis.GDT_Analysis_RemainingLicenses__c;
				tmp.totalLicenses += mAnalysis.GDT_Analysis_TotalLicenses__c;
				tmplicenseWrappers.put(apiName, tmp);
			}else{
				tmplicenseWrappers.put(apiName, new groupAnalysisWrapper(apiName,'', mAnalysis.GDT_Analysis_UsedLicenses__c,mAnalysis.GDT_Analysis_TotalLicenses__c,mAnalysis.GDT_Analysis_RemainingLicenses__c));
			}

		}
		licenseWrappers = tmplicenseWrappers.values();
		wrappers = tmpWrappers.values();


	}

	/** Retrieves the license list */
	public List<GDT_ManageLicense_License__c> listAll_License {
		get {
			return [SELECT Id, GDT_License_APIName__c, Name FROM GDT_ManageLicense_License__c];
		}
	}
	/** Retrieves the purchase list */
	public List<GDT_ManageLicense_Purchase__c> listAll_Purchase {
		get {
			return [SELECT Id,  GDT_Purchase_Description__c ,GDT_Purchase_AffiliateGroup__c, GDT_Purchase_LicenseType__r.Name, GDT_Purchase_LicenseType__r.GDT_License_APIName__c, GDT_Purchase_TotalLicenses__c, GDT_Purchase_ExpirationDate__c, GDT_Purchase_PurchaseDate__c, GDT_Purchase_AppName__c FROM GDT_ManageLicense_Purchase__c where GDT_Purchase_ExpirationDate__c >= TODAY ORDER BY GDT_Purchase_AffiliateGroup__c, GDT_Purchase_LicenseType__c];
		}
	}

	/** User list */
	public List<User> listAll_User {
		get {
			if(Test.isRunningTest())
				return [SELECT Id, ProfileId, Name FROM User WHERE isActive = true LIMIT 500];
			else
				return [SELECT Id, ProfileId, Name FROM User WHERE isActive = true];
		}
	}

	/** Select List */
	public String slAffiliate {get; set;}
	public List<SelectOption> optAffiliate { 
		get {
			return picklistOption('Affiliate', 'GDT_Analysis_AffiliateGroup__c', 'Analysis');
		}
	}

	public String slLicenseName {get; set;}
	public List<SelectOption> optLicenseName { 
		get {
			return picklistOption('License Name', 'Name', 'License');
		}
	}

	public String slLicenseApiName {get; set;}
	public List<SelectOption> optLicenseApiName { 
		get {
			return picklistOption('License API Name', 'GDT_License_APIName__c', 'License');
		}
	}

	public String slAppName {get; set;}
	public List<SelectOption> optAppName { 
		get {
			return picklistOption('Application', 'GDT_Analysis_AppName__c', 'Analysis');
		}
	}

	/**  to the SelectList */
	public List<SelectOption> picklistOption(String valueName, String fieldName, String typeObject ){
		List<SelectOption> options  = new List<SelectOption>();

		//Default value
		String  defaultValue 	= 	'-- '+ valueName +' --';
		options.add(new SelectOption(valueName, defaultValue));

		List<String> listValue = new List<String>();
		if(typeObject == 'Analysis') {
			for(GDT_ManageLicense_Analysis__c lst : listAll_Analysis_picklist) {
				listValue.add(String.valueOf(lst.get(fieldName)));
			}
		}
		else if(typeObject == 'License'){
			for(GDT_ManageLicense_License__c lst : listAll_License) {
				listValue.add(String.valueOf(lst.get(fieldName)));
			}	
		}

		//Sets, by definition, contain no duplicates.
		Set<String> mySet = new Set<String>();
		List<String> resultList = new List<String>();
		mySet.addAll(listValue);
		resultList.addAll(mySet);
		listValue = resultList;
		//Sort the list
		listValue.sort();

		for (String lst : listValue) {
			if(lst != null) {
				options.add(new SelectOption(lst, lst));
			}
		}

		return options;
	}

	//Event OnChange (picklist)
	public void onChangeFilter(){
		initializes();

		if(slAffiliate != 'Affiliate') {
			bChartAffiliate = true;
			List<GDT_ManageLicense_Analysis__c> listFilter = new List<GDT_ManageLicense_Analysis__c>();
			for(GDT_ManageLicense_Analysis__c obj: listAll_Analysis) {
				if(obj.GDT_Analysis_AffiliateGroup__c == slAffiliate)
					listFilter.add(obj);
			}
			listAll_Analysis = listFilter;
		}
		/*
		if(slLicenseName != 'License Name') {
			List<GDT_ManageLicense_Analysis__c> listFilter = new List<GDT_ManageLicense_Analysis__c>();
			for(GDT_ManageLicense_Analysis__c obj: listAll_Analysis) {
				if(obj.GDT_Analysis_LicenseType__r.Name == slLicenseName)
					listFilter.add(obj);
			}
			listAll_Analysis = listFilter;
		}
		*/
		if(slLicenseApiName != 'License API Name') {
			bChartLicense = true;
			List<GDT_ManageLicense_Analysis__c> listFilter = new List<GDT_ManageLicense_Analysis__c>();
			for(GDT_ManageLicense_Analysis__c obj: listAll_Analysis) {
				if(obj.GDT_Analysis_LicenseType__r.GDT_License_APIName__c == slLicenseApiName)
					listFilter.add(obj);
			}
			listAll_Analysis = listFilter;
		}

		if(slAppName != 'Application') {
			bChartApplication = true;
			List<GDT_ManageLicense_Analysis__c> listFilter = new List<GDT_ManageLicense_Analysis__c>();
			for(GDT_ManageLicense_Analysis__c obj: listAll_Analysis) {
				if(obj.GDT_Analysis_AppName__c == slAppName)
					listFilter.add(obj);
			}
			listAll_Analysis = listFilter;
		}
	}


	/** CUSTOM SETTINGS (Object Profile) */

	/** Listing all profiles */
	public List<GDT_CustomSettings_Profile__c> listUpdate_csProfile_All = new List<GDT_CustomSettings_Profile__c>();
	public List<GDT_CustomSettings_Profile__c> csProfile_All {
		get {
			try {
				listUpdate_csProfile_All = [SELECT ProfileID__c, ProfileName__c, UserLicenseID__c, AffiliateGroup__c, ApplicationName__c FROM GDT_CustomSettings_Profile__c ORDER BY ProfileName__c ASC NULLS FIRST]; 
				return listUpdate_csProfile_All; 
			} catch(Exception e) {
				System.debug(e.getMessage());
				return null;
			}           
		}
	}
	

	/** LICENSE */

	/** Listing of the object : UserLicense */
	public List<UserLicense> listAll_StandardLicense {
		get {
			return [SELECT Id, Name FROM UserLicense ORDER BY Name ASC];
		}
	}

	//SelectList in Visualforce page : License
	public String licenseName = 'Salesforce';
	public String getlicenseName() {return licenseName;}
	public void setlicenseName(String licenseName) {this.licenseName = licenseName;}
	public List<SelectOption> soLicenseObject {
		get {
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('None', '--None--'));
			for(UserLicense ul : listAll_StandardLicense) {
				options.add(new SelectOption(ul.Name, ul.Name));
			}
			return options;
		}
	}


	/** REPORT */

	//Attribut 'filter'
	public String filterReport_Affiliate {
		get {
			return '[{column:\'GDT_ManageLicense_Analysis__c.GDT_Analysis_AffiliateGroup__c\', operator:\'equals\', value:\''+ slAffiliate +'\'}, {column:\'GDT_ManageLicense_Analysis__c.GDT_Analysis_LastUpdate__c\', operator:\'equals\', value:\'True\'}]';
		}
	}
	//Attribut 'filter'
	public String filterReport_License {
		get {
			return '[{column:\'GDT_ManageLicense_License__c.GDT_License_APIName__c\', operator:\'equals\', value:\''+ slLicenseApiName +'\'}, {column:\'GDT_ManageLicense_Analysis__c.GDT_Analysis_LastUpdate__c\', operator:\'equals\', value:\'True\'}]';
		}
	}
	//Attribut 'filter'
	public String filterReport_Application {
		get {
			return '[{column:\'GDT_ManageLicense_Analysis__c.GDT_Analysis_AppName__c\', operator:\'equals\', value:\''+ slAppName +'\'}, {column:\'GDT_ManageLicense_Analysis__c.GDT_Analysis_LastUpdate__c\', operator:\'equals\', value:\'True\'}]';
		}
	}

	//Attribut 'ReportId'
	public Id reportID_Affiliate {
		get {
			try {
				return [SELECT Id FROM Report WHERE DeveloperName = 'GDT_ManageLicense_ReportType_Affiliate'].Id;  
			} catch(Exception e) {
				System.debug('ERROR GET(reportID_Affiliate) : ' + e.getMessage());
				return null;
			}
		}
	}
	public Id reportID_License {
		get {
			try {
				return [SELECT Id FROM Report WHERE DeveloperName = 'GDT_ManageLicense_ReportType_License'].Id; 
			} catch(Exception e) {
				System.debug('ERROR GET(reportID_License) : ' + e.getMessage());
				return null;
			}
		}
	}
	public Id reportID_Application {
		get {
			try {
				return [SELECT Id FROM Report WHERE DeveloperName = 'GDT_ManageLicense_ReportType_Application'].Id; 
			} catch(Exception e) {
				System.debug('ERROR GET(reportID_License) : ' + e.getMessage());
				return null;
			}
		}
	}
	public Id reportID_UserLicenses {
		get {
			try {
				return [SELECT Id FROM Report WHERE DeveloperName = 'GDT_ML_UserLicenses'].Id; 
			} catch(Exception e) {
				System.debug('ERROR GET(reportID_License) : ' + e.getMessage());
				return null;
			}
		}
	}


	/** AD Domaine User */
	//Custom class
	public class CustomSettingsClass {
		public String cscAffiliate {get;set;}
		public Integer cscNumberOfUser {get;set;}
		public CustomSettingsClass(String affiliate, Integer numberOfuser){
			this.cscAffiliate = affiliate;
			this.cscNumberOfUser = numberOfuser;
		}
	}
	public List<CustomSettingsClass> listAll_ADDomaine {
		get {
			//Return result
			List<CustomSettingsClass> listToReturn = new List<CustomSettingsClass>();

			//CustomSettings AD Domaine
			AggregateResult[] agR = [SELECT AffiliateGroup__c, SUM(NumberOfUser__c) Number FROM GDT_CustomSettings_ADDomaine__c GROUP BY AffiliateGroup__c];
			for(AggregateResult ar : agR){
				listToReturn.add(new CustomSettingsClass(String.valueOf(ar.get('AffiliateGroup__c')), Integer.valueOf(ar.get('Number'))));
			}

			return listToReturn;
		}
	}
	//Last update date
	public Datetime lastUpdateDate {
		get {
			return [SELECT DateLastUpdate__c FROM GDT_CustomSettings_ADDomaine__c LIMIT 1].DateLastUpdate__c;
		}
	}

	/* */
	public void updatingLicenseUsed(){

		GDT_ManageLicense_Batch myBatchObject = new GDT_ManageLicense_Batch();
		ID batchprocessid = Database.executebatch(myBatchObject);
		ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The values are being calculated. Thanks to refresh the page in a few minutes')); 
	}

	class groupAnalysisWrapper{
		public String licenseApi{get;set;}
		public String application{get;set;}
		public Decimal totalNumber{get;set;}
		public Decimal totalLicenses{get;set;}
		public Decimal remainingLicenses{get;set;}

		public groupAnalysisWrapper(String apiName, String appName, Decimal tNumber, Decimal totalL, Decimal remaining){
			licenseApi = apiName;
			Application = appName;
			totalNumber = tNumber;
			totalLicenses = totalL;
			remainingLicenses = remaining;
		}
	}

}