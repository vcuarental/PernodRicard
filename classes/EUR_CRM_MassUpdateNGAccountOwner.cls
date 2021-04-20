/*********************************************************************************
 * Name:EUR_CRM_MassUpdateNGAccountOwner 
 * Description: Apex Batch Job Class to update the owner and sharing access of the account related to the territories
 * Field to Update:
 * On trade Owner = Owner change to All related Account On Trade Recordtypes
 * Off Trade owner = Owner change to All related Account On Trade Recordtypes
 * KD Owner = Share edit rights to all the related Account (any recordtypes)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/11/2015        Laputa: Conrad          Added Comment Header
**********************************************************************************/
global class EUR_CRM_MassUpdateNGAccountOwner implements Database.Batchable<sObject>, Database.Stateful{
    private static final String ACCOUNT_NG_ON_TRADE = 'EUR_NG_On_Trade';
    private static final String ACCOUNT_NG_OFF_TRADE_TRADITIONAL = 'EUR_NG_Off_Trade_Traditional';
    private Set<Id> terrIds;
    global final String query;
    
    // Checking if user or role exist in the sharing of account. Key is made as ParentID + UserORGroupID
    // For custom object EU Account
    global Set<String> sharingAccountEUKeys;

    // Checking if user or role exist in the sharing of account. Key is made as ParentID + UserORGroupID
    // For Standard Account
    global Set<String> sharingAccountStdKeys;

    global EUR_CRM_MassUpdateNGAccountOwner(String q){
        query = q;
    }

    global EUR_CRM_MassUpdateNGAccountOwner(Set<Id> terrIds){
        /*this.terrIds = terrIds;
        query = 'SELECT Id, RecordTypeId, OwnerId, EUR_CRM_Territory__c, EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Off_Trade_Owner__c, EUR_CRM_Territory__r.EUR_CRM_On_Trade_Owner__c, EUR_CRM_Image_Level__c, EUR_CRM_RTDevName__c, EUR_CRM_Image_Level_Name__c FROM EUR_CRM_Account__c' +
            ' WHERE EUR_CRM_Territory__r.EUR_CRM_IsOwnerChanged__c =  true '+
            ' AND eur_crm_country_code__c = \'NG\' AND EUR_CRM_Territory__c IN :terrIds';*/
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('@@@ EUR_CRM_MassUpdateNGAccountOwner query: ' + query);
        return Database.getQueryLocator(query);
    }

    //Main Logic Implementation
    global void execute (Database.Batchablecontext BC, List<sObject> scope){
       /* List<EUR_CRM_Account__c> acctList = (List<EUR_CRM_Account__c>)scope;
        List<EUR_CRM_Account__c> acctToUpdateList = new List<EUR_CRM_Account__c>();
        
        Set<ID> territoryIDSet = new Set<ID>();
        Map<Id,Id> accountTerritoryShare = new Map<Id,Id>();

        List<EUR_CRM_Account__Share> euAcctSharelist = new List<EUR_CRM_Account__Share>();
        List<AccountShare> stdAcctSharelist = new List<AccountShare>();
		
		//Put the off/on trade kd owners in this
		Set<ID> userIds = new Set<ID>();
				
        for (EUR_CRM_Account__c acct : acctList){   
            Boolean isChanged = false;
            
            if (acct.EUR_CRM_Territory__c != null){
            	// Make on trade owner of Territory, the account owner for NG ON TRADE recordtypes
                if(acct.EUR_CRM_RTDevName__c == ACCOUNT_NG_ON_TRADE){	
                	if(acct.EUR_CRM_Image_Level_Name__c == 'Mainstream') {
            			if(acct.EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c != null) {
            				acct.OwnerID = acct.EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c;
            				territoryIDSet.add(acct.EUR_CRM_Territory__c);
	                        isChanged  = true;
	                        userIds.add(acct.EUR_CRM_Territory__r.EUR_CRM_On_Trade_Owner__c);
            			}
            			continue;
                	}
                	
                    if (acct.EUR_CRM_Territory__r.EUR_CRM_On_Trade_Owner__c != null){
                        acct.OwnerID = acct.EUR_CRM_Territory__r.EUR_CRM_On_Trade_Owner__c;
                        territoryIDSet.add(acct.EUR_CRM_Territory__c);
                        isChanged  = true;
                        userIds.add(acct.EUR_CRM_Territory__r.EUR_CRM_On_Trade_Owner__c);
                    }
                }
                // Differnt logic for the two OFF trade recordtypes
                else if (acct.EUR_CRM_RTDevName__c == ACCOUNT_NG_OFF_TRADE_TRADITIONAL) {
                	if (acct.EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c != null){
                        acct.OwnerID = acct.EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c;
                        territoryIDSet.add(acct.EUR_CRM_Territory__c);
                        isChanged  = true;
                        userIds.add(acct.EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c);
                    }
                }
                
                // KD Owner will be able to edit the related account
                if(acct.EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c != null && acct.EUR_CRM_RTDevName__c == ACCOUNT_NG_ON_TRADE && acct.EUR_CRM_Image_Level_Name__c != 'Mainstream') {                    
                	accountTerritoryShare.put(acct.Id, acct.EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c); // Put sharing on KD Owners
                	userIds.add(acct.EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c);
                	isChanged  = true;
                	territoryIDSet.add(acct.EUR_CRM_Territory__c);
                }
                
            }
            
            if(isChanged){ 
                acctToUpdateList.add(acct);
            }
        }
        
        //Get the user role ID for each users in the offtradeowner
        Map<ID, User> userMap = new Map<ID, User>();
        // Map userRoleID to GroupID
        Map<ID, ID> roleToGroupIDMap = new Map<ID, ID>();
        
        if(userIds.size() > 0) {
        	userMap = new Map<ID, User>([SELECT ID, Name, userRoleID FROM User WHERE ID IN : userIds]);
        	Set<ID> userRoleIDSet = new Set<ID>();
        	for(User u : userMap.values()) {
        		if(u.userRoleID != null) {
        			userRoleIDSet.add(u.userRoleID);
        		}
        	}
        	
        	// Map the role to group id for checking later if the sharing is shared to a role
        	List<Group> groupList = [SELECT ID, relatedID FROM Group WHERE relatedID IN : userRoleIDSet];
        	for(Group g : groupList) {
        		roleToGroupIDMap.put(g.relatedID, g.ID);
        	}
        }
        
        if (acctToUpdateList.size() > 0){
            update acctToUpdateList;
        }

        Map<Id,Id> euAccountToAccountMap = new Map<Id,Id>();
        Map<Id,Id> accountToEUAccountMap = new Map<Id,Id>();
		List<EUR_CRM_Account__Share> accountEUShareList = new List<EUR_CRM_Account__Share>();
		List<AccountShare> accountSTDShareList = new List<AccountShare>();
		
        if(accountTerritoryShare.size() > 0){
            for(EUR_CRM_Account_Link__c link: [select EUR_CRM_Standard_Account__c,EUR_CRM_EU_Account__c from EUR_CRM_Account_Link__c where EUR_CRM_EU_Account__c in:accountTerritoryShare.keyset()]){
                euAccountToAccountMap.put(link.EUR_CRM_EU_Account__c, link.EUR_CRM_Standard_Account__c);
                accountToEUAccountMap.put(link.EUR_CRM_Standard_Account__c, link.EUR_CRM_EU_Account__c);
            }
            
            // Retrieve EU and Standard Account sharing
            accountEUShareList = [SELECT ParentId, RowCause, UserOrGroupId FROM EUR_CRM_Account__Share WHERE ParentId In : euAccountToAccountMap.keyset()];
            accountSTDShareList = [SELECT UserOrGroupId, RowCause, AccountId FROM AccountShare WHERE AccountId In : accountToEUAccountMap.keyset()];
            
            // Fill the sharingAccountKeys to add the unique keys of accountID + UserOrGroupID
			if(sharingAccountEUKeys == null) {
				sharingAccountEUKeys = new Set<String>();
			}
			
			if(sharingAccountStdKeys == null) {
				sharingAccountStdKeys = new Set<String>();
			}
			for(EUR_CRM_Account__Share euAcctShare : accountEUShareList) {
				sharingAccountEUKeys.add((String)euAcctShare.ParentId + (string)euAcctShare.UserOrGroupId);
			}
			
			for(AccountShare acctShare : accountSTDShareList) {
				sharingAccountStdKeys.add((String)acctShare.AccountId + (String)acctShare.UserOrGroupId);
			}
			//Use the statefull sharing account set keys to detect if they already exist in the account as a sharing
            
            for(Id euAcct : accountTerritoryShare.keyset()){
            	// Retrieve User
            	User u = userMap.get(accountTerritoryShare.get(euAcct));
            	// Retrieve role of the user from role map
            	ID groupIDfromuserRoleID = roleToGroupIDMap.get(u.userRoleID);
            	boolean isShared = sharingAccountEUKeys.contains((String)euAcct+(String)accountTerritoryShare.get(euAcct)) || sharingAccountEUKeys.contains((string)euAcct+(String)groupIDfromuserRoleID);
                if(accountTerritoryShare.containskey(euAcct) && !isShared ){
                    EUR_CRM_Account__Share teamMember = new EUR_CRM_Account__Share();
                    teamMember.AccessLevel = 'Edit';
                    teamMember.ParentId = euAcct;
                    teamMember.UserOrGroupId = accountTerritoryShare.get(euAcct);
                    euAcctSharelist.add(teamMember);
                }
            }
        }

        if(euAccountToAccountMap.size() > 0){
            for(Id euAcct : accountTerritoryShare.keyset()){
            	// Retrieve User
            	User u = userMap.get(accountTerritoryShare.get(euAcct));
            	// Retrieve role of the user from role map
            	ID groupIDfromuserRoleID = roleToGroupIDMap.get(u.userRoleID);
            	boolean isShared = sharingAccountStdKeys.contains((String)euAccountToAccountMap.get(euAcct)+(string)accountTerritoryShare.get(euAcct)) || sharingAccountStdKeys.contains((string)euAccountToAccountMap.get(euAcct)+(string)groupIDfromuserRoleID);
            	
                if(accountTerritoryShare.containskey(euAcct) && !isShared){
                    AccountShare teamMember = new AccountShare();
                    teamMember.AccountAccessLevel = 'Edit';
                    teamMember.AccountId = euAccountToAccountMap.get(euAcct);
                    teamMember.OpportunityAccessLevel = 'None';
                    teamMember.UserOrGroupId = accountTerritoryShare.get(euAcct);
                    stdAcctSharelist.add(teamMember);
                }
            }
        }

        if(euAcctSharelist.size() >0){
        	System.debug('@@@@@@@@@@@@@@@@@@@@@ euAcctSharelist ' + euAcctSharelist);
            insert euAcctSharelist;
        }     

        if(stdAcctSharelist.size() >0){
            insert stdAcctSharelist;
        } 
            
        List <EUR_CRM_Territory__c> territoriesToUpdate = [SELECT ID, Name, EUR_CRM_IsOwnerChanged__c FROM EUR_CRM_Territory__c WHERE ID IN: territoryIDSet];
        
        for (EUR_CRM_Territory__c i : territoriesToUpdate){
            i.EUR_CRM_IsOwnerChanged__c = false;
        }

        if (territoriesToUpdate.size() > 0){
            update territoriesToUpdate;
        }
        
        deleteSharingRules(accountSTDShareList, accountEUShareList, accountTerritoryShare, accountToEUAccountMap);*/
        
    }
    
    // Send email, clean and end execution
    global void finish(Database.BatchableContext BC){   
       /* AsyncApexJob apexjob = [Select Id From AsyncApexJob WHERE Id =:BC.getJobId()];
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), apexjob.id, new String[] {});*/
    }
    
	/*********************************************************************************
	 * Description: Process which manual Sharing to delete based on the parameters passed inside
	 *
	 * Parameters:  AccountEUSharingList
	 *              AccountStandardSharingList
	 *				TerritoryKDSharingMap 
	 *				Eu Account to Standard Share Map     
	 *
	 * Return: void
	 * Exception:
	*********************************************************************************/
    public void deleteSharingRules(List<AccountShare> accounSTDtSharing, List<EUR_CRM_Account__Share> accountEUSharing, Map<Id,Id> accountToUserShare, Map<ID, ID> accountToEUAccountMap) {
    	
    	/*List<AccountShare> accountShareToDelete = new List<AccountShare>();
    	List<EUR_CRM_Account__Share> accountEUShareToDelete = new List<EUR_CRM_Account__Share>();
    	
    	if(accountToUserShare.size() > 0) {
	    	//Loop through account share, checking for manual share if the parentid+userID doesnt match with the KD owner in territory
	    	// Delete those who doesnt match with KD owner AND rowcause = manual
	    	for(AccountShare aShare : accounSTDtSharing) {
	    		if(aShare.RowCause == 'Manual') {
	    			ID euAccID = accountToEUAccountMap.get(aShare.accountID);
	    			if(accountToUserShare.containsKey(euAccID)) {
	    				ID currentKDOwner = accountToUserShare.get(euAccID);
	    				if (aShare.UserOrGroupId != currentKDOwner) {
	    					accountShareToDelete.add(aShare);
	    				}
	    			}
	    		}
	    	}
	    	for(EUR_CRM_Account__Share aShare : accountEUSharing) {
	    		System.debug('################### aShare ' + aShare);
	    		if(aShare.RowCause == 'Manual') {
	    			System.debug('################### call delete ' + accountToUserShare);
	    			if(accountToUserShare.containsKey(aShare.parentID)) {
	    				ID currentKDOwner = accountToUserShare.get(aShare.parentID);
	    				if (aShare.UserOrGroupId != currentKDOwner) {
	    					accountEUShareToDelete.add(aShare);
	    				}
	    			}
	    		}
	    	}
	    	
	    	if(accountShareToDelete.size() > 0) {
	    		delete accountShareToDelete;
	    	}
	    	
	    	if(accountEUShareToDelete.size() > 0) {
	    		delete accountEUShareToDelete;
	    	}
    	}*/
    	
    }

}