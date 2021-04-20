global class GDT_ManageLicense_Batch implements Database.Batchable<sObject>, Database.Stateful{
	


	List<String> licenseIDs {get;set;}
	List<String> licenseNames {get;set;}

	public List<GDT_ManageLicense_Purchase__c> listAll_Purchase {get;set;}
    public List<GDT_CustomSettings_Profile__c> listUpdate_csProfile_All {get;set;}	
    public Map<String, GDT_ManageLicense_Analysis__c> analysisMap{get;set;}
    public Map<String, GDT_CustomSettings_Profile__c> profilesMap{get;set;}
    public Map<String, GDT_ManageLicense_License__c> licensesMap{get;set;}
    

	global GDT_ManageLicense_Batch() {
		initAllPurchase();
	}

	public void initAllPurchase(){
		this.licenseNames = new List<String>();
		this.licenseIDs = new List<String>();
		this.analysisMap = new Map<String,GDT_ManageLicense_Analysis__c>();
		this.profilesMap = new Map<String,GDT_CustomSettings_Profile__c>();
		this.licensesMap = new Map<String,GDT_ManageLicense_License__c>();

		for(GDT_ManageLicense_License__c ml : [SELECT Id, GDT_License_APIName__c, Name FROM GDT_ManageLicense_License__c]){
			licensesMap.put(ml.GDT_License_APIName__c, ml);
			licenseNames.add(ml.GDT_License_APIName__c);
			licenseIDs.add(ml.id);
		}

		listAll_Purchase = [SELECT Id,GDT_Purchase_LicenseType__c,  GDT_Purchase_Description__c ,GDT_Purchase_AffiliateGroup__c, GDT_Purchase_LicenseType__r.Name, GDT_Purchase_LicenseType__r.GDT_License_APIName__c, GDT_Purchase_TotalLicenses__c, GDT_Purchase_ExpirationDate__c, GDT_Purchase_PurchaseDate__c, GDT_Purchase_AppName__c FROM GDT_ManageLicense_Purchase__c WHERE GDT_Purchase_PurchaseDate__c < Today AND GDT_Purchase_ExpirationDate__c > Today and GDT_Purchase_LicenseType__c in: licenseIDs];
		listUpdate_csProfile_All = [SELECT ProfileID__c, ProfileName__c, UserLicenseID__c, AffiliateGroup__c, ApplicationName__c FROM GDT_CustomSettings_Profile__c ORDER BY ProfileName__c ASC NULLS FIRST]; 
		
		for(GDT_CustomSettings_Profile__c cs : listUpdate_csProfile_All) {
			profilesMap.put(cs.ProfileID__c, cs);
		}
		UncheckLastUpdate();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(Test.isRunningTest()){return Database.getQueryLocator('SELECT Id, ProfileId, Name,Profile.UserLicense.Name FROM User WHERE isActive = true and User.Profile.UserLicense.Name in: licenseNames limit 200');}
		return Database.getQueryLocator('SELECT Id, ProfileId, Name,Profile.UserLicense.Name FROM User WHERE isActive = true and User.Profile.UserLicense.Name in: licenseNames');
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		execute_Update(scope);
	}
	
	global void finish(Database.BatchableContext BC) {

		/**Calculate TotalLicences 

		for(string str :analysisMap.keySet() ){
			system.debug(str);
		}*/
		for(GDT_ManageLicense_Purchase__c lp : listAll_Purchase) {
			String key = lp.GDT_Purchase_LicenseType__r.GDT_License_APIName__c + '-' + lp.GDT_Purchase_AffiliateGroup__c +'-' +lp.GDT_Purchase_AppName__c;
			if(analysisMap.containsKey(key)){
				GDT_ManageLicense_Analysis__c oAnalysis = analysisMap.get(key);
				oAnalysis.GDT_Analysis_TotalLicenses__c += lp.GDT_Purchase_TotalLicenses__c;
				analysisMap.put(key, oAnalysis);
			}else{
				GDT_ManageLicense_Analysis__c oAnalysis = new GDT_ManageLicense_Analysis__c();
				oAnalysis.GDT_Analysis_LicenseType__c = lp.GDT_Purchase_LicenseType__c;
				oAnalysis.GDT_Analysis_AffiliateGroup__c = lp.GDT_Purchase_AffiliateGroup__c;
				oAnalysis.GDT_Analysis_AppName__c = lp.GDT_Purchase_AppName__c;
				oAnalysis.GDT_Analysis_UsedLicenses__c = 0;
				oAnalysis.GDT_Analysis_TotalLicenses__c = lp.GDT_Purchase_TotalLicenses__c;
				analysisMap.put(key, oAnalysis);
			}
		}
		upsert analysisMap.values();



		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];

		// Send an email to the Apex job's submitter 
		// notifying of job completion. 
		List<String> emailRecipients = GDT_GeneralConfigDAO.getValueAsStringArray('GDT_Analysis_Email_Notification', ',',false);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(emailRecipients);
		mail.setSubject('GDT Manage License : Analysis Completed');
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
		if(!Test.isRunningTest()){
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
	}


	/** Uncheck the last record for the object 'GDT_ManageLicense_Analysis__c' */
	global void UncheckLastUpdate() {
		try {
			List<GDT_ManageLicense_Analysis__c> uAnalysis = null;
			uAnalysis = [SELECT Id, GDT_Analysis_LastUpdate__c, GDT_Analysis_TotalLicenses__c FROM GDT_ManageLicense_Analysis__c WHERE GDT_Analysis_LastUpdate__c = true AND GDT_Analysis_LicenseType__c in: this.licenseIDs];
			if(uAnalysis.isEmpty() == false) {
				for(GDT_ManageLicense_Analysis__c oLoop : uAnalysis) {
					oLoop.GDT_Analysis_LastUpdate__c = false;
				}
			}
			update uAnalysis;
		} catch(Exception e) {
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CATCH: '+e.getMessage()));
			System.debug(e.getMessage());
		}
	}


	global void execute_Update(List<User> scope) {
		//Uncheck the field 'LastUpdate' for other record
		for(User us : scope){
			GDT_CustomSettings_Profile__c csProfile = profilesMap.get(us.profileId);
			system.debug(us.profileId);
			String key = '';
			if(csProfile == null){
				csProfile = new GDT_CustomSettings_Profile__c();
				csProfile.UserLicenseID__c = us.Profile.UserLicense.Name;
				csProfile.AffiliateGroup__c = 'Not Assigned';
				csProfile.ApplicationName__c = null;
			}
			key = csProfile.UserLicenseID__c + '-' + csProfile.AffiliateGroup__c +'-'+ csProfile.ApplicationName__c;

			GDT_ManageLicense_Analysis__c oAnalysis;
			if(analysisMap.containsKey(key)){
				oAnalysis = analysisMap.get(key);
			}else{
				oAnalysis = new GDT_ManageLicense_Analysis__c();
				system.debug(licensesMap);
				system.debug(licensesMap.get(csProfile.UserLicenseID__c));
				oAnalysis.GDT_Analysis_LicenseType__c = licensesMap.get(csProfile.UserLicenseID__c).id;
				oAnalysis.GDT_Analysis_AffiliateGroup__c = csProfile.AffiliateGroup__c;
				oAnalysis.GDT_Analysis_AppName__c = csProfile.ApplicationName__c;
				oAnalysis.GDT_Analysis_UsedLicenses__c = 0;
				oAnalysis.GDT_Analysis_TotalLicenses__c = 0;
			}
			oAnalysis.GDT_Analysis_UsedLicenses__c ++;
			analysisMap.put(key, oAnalysis);
		}
	}
}