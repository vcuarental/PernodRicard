/**
 * @name GDT_CS_CompanyName_Batch
 * @description
 * Used to move back through CompanyName present on the platform into the CustomSettings
 * 
 * @author Simon GAZIN
 */
global class GDT_CS_CompanyName_Batch implements Database.Batchable<sObject> {
	
	/* Variable Declaration */
	String idUser {get;set;}
	String query;

	Id licenseID_ChatterExternal = [SELECT Id FROM UserLicense WHERE Name = 'Chatter External' LIMIT 1].Id;
	List<User> listAll_User = [SELECT Id, ProfileId, Name, ADDomainUser__c, CompanyName FROM User WHERE isActive = true AND Profile.UserLicenseId != :licenseID_ChatterExternal ORDER BY CompanyName];
	List<GDT_CustomSettings_CompanyName__c> listAll_CompanyName = [SELECT Name, CompanyName__c, CompanyNameUser__c FROM GDT_CustomSettings_CompanyName__c ORDER BY CompanyName__c ASC NULLS FIRST]; 
	
	/**
	 * Constructor by default
	 */
	global GDT_CS_CompanyName_Batch() {
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
		Upadate_CustomSettings_CompanyName(this.listAll_User, this.listAll_CompanyName);
	}
	
	/**
	 * This method is called after all batches are processed
	 * @param  BC 
	 */
	global void finish(Database.BatchableContext BC) {
		
	}

	/**
	 * Insertion in the CustomSettings values of the different CompanyName
	 * @param  lst_User        List of all users
	 * @param  lst_CompanyName List of all CompanyName
	 */
	global void Upadate_CustomSettings_CompanyName(List<User> lst_User, List<GDT_CustomSettings_CompanyName__c> lst_CompanyName){
		
		/* Variable Declaration */
		List<GDT_CustomSettings_CompanyName__c> lstOfCustomSettingToBeInsert = new List<GDT_CustomSettings_CompanyName__c>();
		List<String> list_CompanyNameUser_Sort = new List<String>();
		List<String> list_CompanyNameUser_NoSort = new List<String>();

		// Get CompanyName
		for(User u : lst_User){
			if(u.CompanyName != null) {
				list_CompanyNameUser_NoSort.add(u.CompanyName);				
			}
		}

		//Sets, by definition, contain no duplicates.
		Set<String> mySet = new Set<String>();
		mySet.addAll(list_CompanyNameUser_NoSort);
		list_CompanyNameUser_Sort.clear();
		list_CompanyNameUser_Sort.addAll(mySet);
		list_CompanyNameUser_Sort.sort();

		Integer iIfExist = 0;

		// Auto Number for Name
		Integer iAutoNumberName = 0;

		if(lst_CompanyName.size() > 0){
			String sAutoNumberName = [SELECT Name FROM GDT_CustomSettings_CompanyName__c ORDER BY Name DESC NULLS FIRST LIMIT 1].Name;
			sAutoNumberName = sAutoNumberName.substring(1);
			iAutoNumberName = Integer.valueOf(sAutoNumberName);
		}

		// Insert in CustomSettings
		for(String lstSort : list_CompanyNameUser_Sort){
			// No Duplicate
			if(lst_CompanyName != null){
				for(GDT_CustomSettings_CompanyName__c lstAll : lst_CompanyName){
					if(lstAll.CompanyNameUser__c.equals(lstSort)) {
						iIfExist++;
					}
				}
			}

			// Insert
			if(iIfExist == 0) {
				iAutoNumberName += 1;

				GDT_CustomSettings_CompanyName__c cscn = new GDT_CustomSettings_CompanyName__c();
				cscn.Name = 'N'+  String.valueOf(iAutoNumberName).leftPad(4).replace(' ', '0');
				cscn.CompanyNameUser__c = lstSort;

				lstOfCustomSettingToBeInsert.add(cscn);
			}

			iIfExist = 0;
		}

		if(lstOfCustomSettingToBeInsert.size() > 0)
			insert lstOfCustomSettingToBeInsert;


		// Delete record in Custom Settings if CompanyName is not used by an user
		for(GDT_CustomSettings_CompanyName__c cs : lst_CompanyName) {
			for(String cn : list_CompanyNameUser_Sort) {
				if(cn == cs.CompanyNameUser__c){
					iIfExist++;
				}
			}
			if(iIfExist == 0) {
				delete cs;
			}
		}
	}
	
}