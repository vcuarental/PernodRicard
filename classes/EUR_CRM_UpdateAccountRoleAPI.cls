/*********************************************************************************
* Name: EUR_CRM_UpdateAccountRoleAPI
* Description: Automatically update the field 'EUR_CRM_Owner_Role_API_Name__c' in Account 
when the Role is updated in User profile
*
* Version History
* Date			Developer	Comments
* ----------	----------	-------------------------------------------------------
*29-11-2017	Kevin Choi		Created		
*********************************************************************************/

public with sharing class EUR_CRM_UpdateAccountRoleAPI  extends EUR_CRM_TriggerAbstract  {
    private static final Integer MAX_BATCHES = 10;
    
    public EUR_CRM_UpdateAccountRoleAPI() {
        super('EUR_CRM_UpdateAccountRoleAPI');		
    }
    
    private static Set<String> validateCountryCode = new Set<String>{
        'RU',
        'ZA'
    }; 
            
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        system.debug('Execute EUR_CRM_UpdateAccountRoleAPI');
        
        List<User> userList = (List<User>) sObjList;
        List<Id> userIdUpdateList = new List<Id>();
        Map<ID, User> userMap = (Map<ID, User>) newMap;
        Map<ID, User> userOldMap = (Map<ID, User>) oldMap;
       	 
        for (User user: userList){
             if (validateCountryCode.contains(user.EUR_CRM_Country_Code__c) && userMap.get(user.Id).UserRoleId != userOldMap.get(user.Id).UserRoleId){
                 userIdUpdateList.add(user.Id);
                 
             }
        }
        
        if (userIdUpdateList.size() > 0){
          	EUR_CRM_UpdateAccountRoleAPIBatch batch = new EUR_CRM_UpdateAccountRoleAPIBatch(userIdUpdateList);
        	database.executeBatch(batch);  
           
        }
                
    }
    /*
    @future
    private static void updateAccountRoleAPIName(List<Id> userIdUpdateList) {
        system.debug('Execute updateAccountRoleAPIName:'+userIdUpdateList);
       	Map<Id, User> userRoleMap = new Map<Id, User>();	
		for (user u : [select user.id ,isActive, user.ManagerId, user.UserRole.name, user.UserRole.DeveloperName
            					FROM user, user.profile, user.UserRole
            					Where user.profile.name like 'EUR%' and user.UserRole.name like 'EUR%' and IsActive = true and Id IN :userIdUpdateList]){
                                    
				userRoleMap.put(u.id, u);
			}
        
        List<EUR_CRM_Account__c> accountToUpdate = new List<EUR_CRM_Account__c>();    
		for (EUR_CRM_Account__c account : [SELECT id, EUR_CRM_Owner_Role_API_Name__c, RecordtypeId, CreatedById, OwnerId
												FROM EUR_CRM_Account__c 
												WHERE OwnerId IN :userRoleMap.keyset()]) {

			Account.EUR_CRM_Owner_Role_API_Name__c = userRoleMap.get(account.OwnerId).UserRole.DeveloperName;
			accountToUpdate.add(account);
       	}
        
        
        if(accountToUpdate.size() < 10000) {
			System.debug(accountToUpdate.size());
			update accountToUpdate;

		} else {
			Integer runningBatchJobs = [select count() from AsyncApexJob where JobType = 'BatchApex' and status in ('Queued','Processing','Preparing') ];

			if(runningBatchJobs < MAX_BATCHES) {
				//create the postDMLS
				Database.executeBatch(new EUR_CRM_BatchDML_Utility(accountToUpdate, 'EUR_CRM_Account__c', EUR_CRM_BatchDML_Utility.Operation.UPDATE_RECORDS,true, null));
			} else {
				for(User user: userRoleMap.values()){
					user.addError(Label.EUR_CRM_No_Resources_Available);
				}
			}
		} 
    }*/
    
}