public with sharing class GDT_ManageLicense_Controller_cs {

	private final sObject mysObject;

	//The extension constructor initializes the private member
	//variable mysObject by using the getRecord method from the standard
	//controller.
	public GDT_ManageLicense_Controller_cs(ApexPages.StandardController stdController) {
		this.mysObject = (sObject)stdController.getRecord();
	}

	//Listing all profiles
	public List<GDT_CustomSettings_Profile__c> listUpdate_csProfile_All = new List<GDT_CustomSettings_Profile__c>();
	public List<GDT_CustomSettings_Profile__c> list_csProfile_All {
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

	//Number of profile
	public Integer nbProfile_All {
		get {
			return [SELECT count() FROM Profile];
		}
	}

	//Number of different domain
	public Integer nbDomaine_All {
		get { return [SELECT count() FROM GDT_CustomSettings_ADDomaine__c]; }
	}

	//Listing all profiles
	public List<GDT_CustomSettings_ADDomaine__c> listUpdate_csDomaine = new List<GDT_CustomSettings_ADDomaine__c>();
	public List<GDT_CustomSettings_ADDomaine__c> list_csDomaine_All {
		get {
			try {
				listUpdate_csDomaine = [SELECT AffiliateGroup__c, ADDomaine__c, NumberOfUser__c FROM GDT_CustomSettings_ADDomaine__c ORDER BY ADDomaine__c ASC NULLS FIRST]; 
				return listUpdate_csDomaine; 
			} catch(Exception e) {
				System.debug(e.getMessage());
				return null;
			}
		}
	}

	/**
	 * Custom Settings (Object Profile)
	 */
	//Update record in Custom Settings
	public void saveCustomSettings_Profile() {
		if(listUpdate_csProfile_All != null)
			update listUpdate_csProfile_All;
	}

	public void refresh_CustomSettings_Profile() {

		GDT_CS_Profile_Batch myBatchObject = new GDT_CS_Profile_Batch();
		ID batchprocessid = Database.executebatch(myBatchObject);
		
		ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The values are being calculated. Thanks to refresh the page in a few minutes')); 
	}

	/**
	 * Custom Settings (Object AD Domaine)
	 */
	//Update record in custom settings
	public void saveCustomSettings_Domaine() {
		if(listUpdate_csDomaine != null)
			update listUpdate_csDomaine;
	}


	public void refresh_CustomSettings_ADDomaine() {

		GDT_CS_ADDomaine_Batch myBatchObject = new GDT_CS_ADDomaine_Batch();
		ID batchprocessid = Database.executebatch(myBatchObject);
		
		ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The values are being calculated. Thanks to refresh the page in a few minutes')); 
	}

}