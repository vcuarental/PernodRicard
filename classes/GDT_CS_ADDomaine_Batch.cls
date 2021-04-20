/**
 * @name GDT_CS_ADDomaine_Batch
 * @description
 * Used to move back through AD Domain present on the platform into the CustomSettings
 * 
 * @author Simon GAZIN
 */
global class GDT_CS_ADDomaine_Batch implements Database.Batchable<sObject> {
	
	/* Variable Declaration */
	String idUser {get;set;}
	String query;

	List<User> listAll_User = [SELECT Id, ProfileId, Name, ADDomainUser__c FROM User WHERE isActive = true];
	List<GDT_CustomSettings_ADDomaine__c> listAll_ADDomaine = [SELECT Name, AffiliateGroup__c, ADDomaine__c, NumberOfUser__c FROM GDT_CustomSettings_ADDomaine__c ORDER BY ADDomaine__c ASC NULLS FIRST]; 
	
	/**
	 * Constructor by default
	 */
	global GDT_CS_ADDomaine_Batch() {
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
		// Call method - Update_CustomSettings_ADDomaine(List<User>, List<GDT_CustomSettings_ADDomaine__c>)
		Update_CustomSettings_ADDomaine(this.listAll_User, this.listAll_ADDomaine);
	}
	
	/**
	 * This method is called after all batches are processed
	 * @param  BC 
	 */
	global void finish(Database.BatchableContext BC) {
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];

		// Send an email to the Apex job's submitter 
		// Notifying of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Batch Custom Settings AD Domaine updating: '+ a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
	/**
	 * Insertion in the CustomSettings values of the different AD Domain
	 * @param  lst_User      List of all users
	 * @param  lst_ADDomaine List of all AD Domain
	 */
	global void Update_CustomSettings_ADDomaine(List<User> lst_User, List<GDT_CustomSettings_ADDomaine__c> lst_ADDomaine){
		
		/* Variable Declaration */
		List<GDT_CustomSettings_ADDomaine__c> lstOfCustomSettingToBeInsert = new List<GDT_CustomSettings_ADDomaine__c>();
		List<String> list_ADDomaine_Sort = new List<String>();
		List<String> list_ADDomaine_NoSort = new List<String>();

		String substringtDomaine = null;

		// Get AD Domain
		for(User u : lst_User){
			if(u.ADDomainUser__c != null && u.ADDomainUser__c.contains('\\')) {
				//Substring Domaine only
				substringtDomaine = (u.ADDomainUser__c).substring(0, ((u.ADDomainUser__c).indexOf('\\',0)));
				list_ADDomaine_NoSort.add(substringtDomaine);               
			}
		}

		//Sets, by definition, contain no duplicates.
		Set<String> mySet = new Set<String>();
		mySet.addAll(list_ADDomaine_NoSort);
		list_ADDomaine_Sort.clear();
		list_ADDomaine_Sort.addAll(mySet);
		list_ADDomaine_Sort.sort();

		Integer iIfExist = 0;
		// Insert in CustomSettings
		for(String lstSort : list_ADDomaine_Sort){
			
			GDT_CustomSettings_ADDomaine__c csd = new GDT_CustomSettings_ADDomaine__c();
				csd.Name = lstSort;
				csd.ADDomaine__c = lstSort;
				csd.NumberOfUser__c = 0;
				csd.DateLastUpdate__c = Datetime.now();

			//Calulate the number of user
			for(String lstNoSort : list_ADDomaine_NoSort) {
				if(lstSort.equals(lstNoSort)){
					csd.NumberOfUser__c += 1;
				}
			}

			//No insert duplicate value
			for(GDT_CustomSettings_ADDomaine__c lstAll : listAll_ADDomaine){
				if(lstAll.ADDomaine__c.equals(lstSort)) {
					lstAll.NumberOfUser__c = csd.NumberOfUser__c;
					lstAll.DateLastUpdate__c = Datetime.now();
					try {
						update lstAll;
						iIfExist++;
					} catch(Exception e) {
						System.debug(e.getMessage());
					}
				}
			}

			if(iIfExist == 0) {
				lstOfCustomSettingToBeInsert.add(csd);
			}


			iIfExist = 0;
		}

		if(lstOfCustomSettingToBeInsert.size() > 0) {
			try {
				insert lstOfCustomSettingToBeInsert;
			} catch(Exception e) {
				System.debug(e.getMessage());
			}        
		}


		// Delete record in Custom Settings if AD Domaine is not used by an user
		for(GDT_CustomSettings_ADDomaine__c cs : lst_ADDomaine) {
			for(String adDomaine : list_ADDomaine_Sort) {
				if(adDomaine == cs.ADDomaine__c){
					iIfExist++;
				}
			}
			if(iIfExist == 0) {
				delete cs;
			}
		}
	}
}