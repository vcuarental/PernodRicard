/**
 * @name GDT_CS_Profile_Batch
 * @description
 * Used to move back through CompanyName present on the platform into the CustomSettings
 * 
 * @author Simon GAZIN
 */
global class GDT_CS_Profile_Batch implements Database.Batchable<sObject> {
	
	/* Variable Declaration */
	String idUser {get;set;}
	String query;

	List<Profile> listAll_Profile = [SELECT Id, Name, UserLicense.Name FROM Profile ORDER BY Name ASC NULLS FIRST];
	List<GDT_CustomSettings_Profile__c> listAll_csProfile = [SELECT ProfileID__c, ProfileName__c FROM GDT_CustomSettings_Profile__c];
	
	/**
	 * Constructor by default
	 */
	global GDT_CS_Profile_Batch() {
	}
	
	/**
	 * To collect the records or objects to pass to the interface method execute
	 * @param  BC 
	 * @return    QueryLocator object or an iterable that contains the records or objects passed to the job
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		this.idUser = UserInfo.getUserId();
		this.query = 'SELECT Id, ProfileId, Name FROM User WHERE isActive = true AND Id =:idUser';
		
		return Database.getQueryLocator(query);
	}

	/**
	 * This method is called for each batch of records that you pass to it
	 * @param  BC    
	 * @param  scope
	 */
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Upadate_CustomSettings_ADDomaine(this.listAll_Profile, this.listAll_csProfile);
	}
	
	/**
	 * This method is called after all batches are processed
	 * @param  BC 
	 */
	global void finish(Database.BatchableContext BC) {
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];

		// Send an email to the Apex job's submitter 
		// notifying of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Batch Custom Settings Profile updating: '+ a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
	}

	/**
	 * Insertion in the CustomSettings values of the different Profile
	 * @param  lstProfile    List of all profiles
	 * @param  lst_csProfile List of all profiles in CustomSettings
	 */
	global void Upadate_CustomSettings_ADDomaine(List<Profile> lstProfile, List<GDT_CustomSettings_Profile__c> lst_csProfile) {
		//Don't include the query SOQL in loops, to bypass the limit (101)
		List<GDT_CustomSettings_Profile__c> lstOfCustomSettingToBeInsert = new List<GDT_CustomSettings_Profile__c>();
		
		Integer iIfExist = 0;

		for(Profile lp : lstProfile) {
			GDT_CustomSettings_Profile__c csp = new GDT_CustomSettings_Profile__c();
			csp.Name = lp.Id;
			csp.ProfileName__c = lp.Name;
			csp.ProfileID__c = lp.Id;
			csp.UserLicenseID__c = lp.UserLicense.Name;

			for(GDT_CustomSettings_Profile__c cs : lst_csProfile){
				if(cs.ProfileID__c == lp.Id) {
					iIfExist++;
					
					if(lp.Name != cs.ProfileName__c){ 
						cs.ProfileName__c = lp.Name;
						update cs;
					}
				}
			}

			if(iIfExist == 0) {
				lstOfCustomSettingToBeInsert.add(csp);
			}
			iIfExist = 0;
		}

		insert lstOfCustomSettingToBeInsert;

		//Delete Profile in Custom Settings
		iIfExist = 0;
		for(GDT_CustomSettings_Profile__c cs : lst_csProfile) {
			for(Profile lp : lstProfile) {
				if(lp.Id == cs.ProfileID__c){
					iIfExist++;
				}
			}
			if(iIfExist == 0) {
				delete cs;
			}
			iIfExist = 0;
		}
	}
	
}