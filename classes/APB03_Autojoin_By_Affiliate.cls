/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | User                                                                               |
|     - Description     | automatically add created and updated user in a chatter group defined by 		     |
|                       | custom setting.																	 |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 07/05/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
global class APB03_Autojoin_By_Affiliate implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    
    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public String soql = '';
    public String ChatterGroupId;
    public String debugMsg;
    //Pour lancer le batch afin d effectuer des tests, utiliser le execute anonymous avec
    // Database.executeBatch(new APB03_Autojoin_By_Affiliate(), 200);
    
    /*
    *   START
    */
    global Database.QueryLocator start(Database.BatchableContext BC){		
        System.debug('#### START APB03_Autojoin_By_Affiliate -- Begin');
		
		debugMsg = '';
        return Database.getQueryLocator(soql);
    }

    /*
    *   EXECUTE
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
                
        System.debug('#### EXECUTE APB03_Autojoin_By_Affiliate -- StartTimer:'+System.now());
        System.debug('#### EXECUTE APB03_Autojoin_By_Affiliate -- Begin');
        System.debug('#### EXECUTE APB03_Autojoin_By_Affiliate -- Scope size : ' + scope.size());
                
        List<User> list_UsersToAutojoin = (List<User>)scope;

		/* Get all couples (group ; company) in a map then build a map (key: company; value: group ID) */
		List<ESN_AutojoinByAffiliates_Config__c> configs_list = ESN_AutojoinByAffiliates_Config__c.getAll().values();
		Map<String,Set<Id>> configAffiliate2SetGroup_map = new Map<String,Set<Id>>();
		List<Id> allUsersJoinGroup_list = new List<Id>();
		
		for(ESN_AutojoinByAffiliates_Config__c conf : configs_list){
			if(conf.Affiliate__c != 'All'){
				//configAffiliate2SetGroup_map.put(conf.Affiliate__c, conf.Chatter_Group_ID__c);
	           // AP02_AutoJoin_CollaborationGroupMember.addGroupId2CompMap(configAffiliate2SetGroup_map, conf.Chatter_Group_ID__c, conf.Affiliate__c);
	            Set<Id> ChatterGroupID_list;
		    	if(configAffiliate2SetGroup_map.get(conf.Affiliate__c) != null)         
		        	ChatterGroupID_list = configAffiliate2SetGroup_map.get(conf.Affiliate__c);
		    	else
		        	ChatterGroupID_list = new Set<Id>();
		    	
		    	// Check if user is not already in list //
		    	if(!ChatterGroupID_list.contains(conf.Chatter_Group_ID__c))	
		        	ChatterGroupID_list.add(conf.Chatter_Group_ID__c);
		        
		        configAffiliate2SetGroup_map.put(conf.Affiliate__c, ChatterGroupID_list);
			}else{
				allUsersJoinGroup_list.add(conf.Chatter_Group_ID__c);
			}
		}
			      
        /* Insert CollaborationGroupMember */
        if(list_UsersToAutojoin.size() != 0){
	        List<CollaborationGroupMember> entMembers = new List<CollaborationGroupMember>();		
	        
			System.debug('#### EXECUTE APB03_Autojoin_By_Affiliate -- startTimer_Boucle1:'+System.now());
			
			if(ChatterGroupId == null){ // Trigger execution
			  	for (User usr : list_UsersToAutojoin)	{ 
	                // Autojoin by affiliate
			  		if (configAffiliate2SetGroup_map.containsKey(usr.CompanyName) && configAffiliate2SetGroup_map.get(usr.CompanyName).size() != 0) {
		                for(Id grpID : configAffiliate2SetGroup_map.get(usr.CompanyName)){
					    	CollaborationGroupMember entMember = new CollaborationGroupMember (CollaborationGroupId = grpID, MemberId = usr.Id);
					    	entMembers.add(entMember);
		                }
		            }
	                // Autojoin all users
			  		if (allUsersJoinGroup_list.size() != 0) {
		                for(Id groupId:allUsersJoinGroup_list){
					    	CollaborationGroupMember entMember = new CollaborationGroupMember (CollaborationGroupId = groupId, MemberId = usr.Id);
					    	entMembers.add(entMember);
            				System.debug('\n' +'#### EXECUTE APB03_Autojoin_By_Affiliate -- Add CGM:[Group '+groupId+'/Member '+usr.Id+']'); 
		                }
			  		}
			  	}
			}else{ // Configuration page execution
			  	for (User usr : list_UsersToAutojoin)	{
			    	CollaborationGroupMember entMember = new CollaborationGroupMember (CollaborationGroupId = ChatterGroupId, MemberId = usr.Id);
			    	entMembers.add(entMember);                             
            		System.debug('\n' +'#### EXECUTE APB03_Autojoin_By_Affiliate -- Add CGM:[Group '+ChatterGroupId+'/Member '+usr.Id+']'); 
			  	}				
			}
            System.debug('\n' +'#### EXECUTE APB03_Autojoin_By_Affiliate -- stopTimer_Boucle1:'+System.now());        
                      
            System.debug('#### EXECUTE APB03_Autojoin_By_Affiliate -- startTimer_insert:'+System.now());
            System.debug('#### EXECUTE APB03_Autojoin_By_Affiliate -- insert '+list_UsersToAutojoin.size()+' records.');
            
            Database.SaveResult[] results;
            if(entMembers.size() != 0)
		  		results = Database.Insert(entMembers, false);                                  
            
            System.debug('\n' +'#### EXECUTE APB03_Autojoin_By_Affiliate -- stopTimer_insert:'+System.now());                                
            System.debug('\n' +'#### EXECUTE APB03_Autojoin_By_Affiliate -- StopTimer:'+System.now());            
			/*
			for(Database.SaveResult[] result : results){
                if(result)
                debugMsg += '\n' +'#### APB03_Autojoin_By_Affiliate -- EXECUTE Exception : ' + e;
                Utils_UsefulMethods.notifyAdminMsg(emailAdmin, 'APB03_Autojoin_By_Affiliate', 'Exception during the batch.',debugMsg);
                System.debug('#### EXECUTE APB03_Autojoin_By_Affiliate -- StopTimer:'+System.now());
			}
			*/
			if (results != null){
				for (Database.SaveResult result : results) {
					if (!result.isSuccess()) {
						Database.Error[] errs = result.getErrors();
						for(Database.Error err : errs)
							if(''+err.getStatusCode() != 'DUPLICATE_VALUE')
								debugMsg += '\n #### APB03_Autojoin_By_Affiliate -- EXECUTE Error : '+err.getStatusCode() + ' - ' + err.getMessage();
					}
				}
			}
        }
    }

    /*
    *   FINISH
    */
    global void finish(Database.BatchableContext BC){   
		/* Get the admin Email */
		String emailAdmin = Utils_UsefulMethods.adminEmailOfPRCustomSetting();
		     
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems from AsyncApexJob where Id =: BC.getJobId()]; 
		if(debugMsg != '')
			Utils_UsefulMethods.notifyAdminMsg(emailAdmin, 'APB03_Autojoin_By_Affiliate', 'Exception during insert list of CollaborationGroupMembers.',debugMsg);       
        System.debug('#### EXECUTE APB03_Autojoin_By_Affiliate -- Status:'+a.Status+' ');
        System.debug('#### EXECUTE APB03_Autojoin_By_Affiliate -- The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
    }
}