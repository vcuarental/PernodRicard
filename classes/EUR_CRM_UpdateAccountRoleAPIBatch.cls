global class EUR_CRM_UpdateAccountRoleAPIBatch implements Database.Batchable<sObject>{

	private List<Id> userIdUpdateList; 
    
    public EUR_CRM_UpdateAccountRoleAPIBatch(List<Id> userIdList){
        userIdUpdateList = userIdList;
        
    }
    
    global static String generateQuery(){

        //List<String> validRecordType = New List<String>{'EUR_BE_O_P_Account_Mapping'}; 

        return  'select user.id ,isActive, user.UserRole.name, user.UserRole.DeveloperName '+
            					'FROM user, user.profile, user.UserRole '+
            					'Where IsActive = true ' +
            					'and Id IN :userIdUpdateList';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('QUERY: ' + generateQuery());
        return Database.getQueryLocator(generateQuery());
    }

    //Main Logic Implementation
    global void execute (Database.Batchablecontext BC, List<sObject> scope){ 
        List<User> userList = (List<User>)scope;
        Map<Id, User> userRoleMap = new Map<Id, User>();
        
        system.debug('userList:'+userList);
        
		for (user u :userList){                 
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
        }

    }

    global void finish(Database.BatchableContext BC){

    }  
    
}