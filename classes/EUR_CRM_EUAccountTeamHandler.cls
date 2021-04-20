public with sharing class EUR_CRM_EUAccountTeamHandler extends EUR_CRM_TriggerAbstract{
	
	public EUR_CRM_EUAccountTeamHandler(){
        super('EUR_CRM_EUAccountTeamHandler');
    }
    
    private static Map<String, String> accessRightMap = new Map<String, String>{
    	'Read Only' => 'Read',
    	'Read/Write' => 'Edit'
    };
    
    //	work on before insert, before update and before delete triggers on EUR_CRM_Account_Team__c object
    //	when account team record is inserted, apex sharing need to be added to EUR_CRM_Account__Share and AccountShare objects, and get the sharing record Id
    //	and saved onto the account team record
    //	update will only allow users to change the Access Level and Role Names, but the users are not allowed to be updated (use delete and create new one)
    //  when deleting the account team record, relevant sharing in EUR_CRM_Account__Share and AccountShare objects will be deleted
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
    	List<EUR_CRM_Account_Team__c> acctTeamlist = (List<EUR_CRM_Account_Team__c>) sObjList;
    	
    	List<AccountShare> acctSharelist = new List<AccountShare>();
    	List<EUR_CRM_Account__Share> euAcctSharelist = new List<EUR_CRM_Account__Share>();
    	
    	if(tAction == TriggerAction.BEFORE_INSERT){
    		Set<Id> euAcctIdSet = new Set<Id>();
    		Map<Id, Id> euAcct2AcctMap = new Map<Id, Id>();
    		Map<String, AccountShare> euAcctTeam2StdMap = new Map<String, AccountShare>();
    		Map<String, EUR_CRM_Account__Share> euAcctTeam2EUAcctMap = new Map<String, EUR_CRM_Account__Share>();
    		
    		for(EUR_CRM_Account_Team__c acctteam : acctTeamlist){
    			euAcctIdSet.add(acctteam.EUR_CRM_Account__c);
    			euAcctTeam2EUAcctMap.put(getAcctTeamKey(acctteam), createEUAcctShare(acctteam));
    		}
    		if(euAcctIdSet.size()>0){
    			for(EUR_CRM_Account_Link__c acctlink: [Select EUR_CRM_Standard_Account__c, EUR_CRM_EU_Account__c From EUR_CRM_Account_Link__c
    				 Where EUR_CRM_EU_Account__c in: euAcctIdSet]){
    				euAcct2AcctMap.put(acctlink.EUR_CRM_EU_Account__c, acctlink.EUR_CRM_Standard_Account__c);
    			}
    			if(euAcct2AcctMap.size()>0){
    				for(EUR_CRM_Account_Team__c acctteam : acctTeamlist){
    					Id acctId = euAcct2AcctMap.get(acctteam.EUR_CRM_Account__c);
    					/* if acctid is null, eu account and acct are not 1:1 linked
    					if(acctId == null)
    						system.debug('acct team: '+acctteam);
    					*/
    					euAcctTeam2StdMap.put(getAcctTeamKey(acctteam), createAcctShare(acctteam, acctId));
    				}
    			}
    		}
    		if(euAcctTeam2StdMap.size()>0){
    			insert euAcctTeam2StdMap.values();		
    		}
    		if(euAcctTeam2EUAcctMap.size()>0){
    			insert euAcctTeam2EUAcctMap.values();
    		}
    		if(euAcctTeam2StdMap.size()>0 || euAcctTeam2EUAcctMap.size()>0){
    			for(EUR_CRM_Account_Team__c acctteam : acctTeamlist){
    				acctteam.EUR_CRM_Account_Share_Record_Id__c = euAcctTeam2StdMap.get(getAcctTeamKey(acctteam)) == null ? null : euAcctTeam2StdMap.get(getAcctTeamKey(acctteam)).Id;
    				acctteam.EUR_CRM_EU_Account_Share_Record_Id__c = euAcctTeam2EUAcctMap.get(getAcctTeamKey(acctteam)) == null ? null : euAcctTeam2EUAcctMap.get(getAcctTeamKey(acctteam)).Id;
    			}
    		}
    	}
    	if(tAction == TriggerAction.BEFORE_UPDATE){
    		System.debug('update trigger starts');
    		Map<Id, EUR_CRM_Account_Team__c> oldAcctTeamMap = (Map<Id, EUR_CRM_Account_Team__c>) oldMap;
    		Map<Id, EUR_CRM_Account_Team__c> newAcctTeamMap = (Map<Id, EUR_CRM_Account_Team__c>) newMap;
    		for(EUR_CRM_Account_Team__c acctteam : acctTeamlist){
    			if(oldAcctTeamMap.get(acctteam.Id).EUR_CRM_Team_Member__c <> newAcctTeamMap.get(acctteam.Id).EUR_CRM_Team_Member__c)
    				acctteam.EUR_CRM_Team_Member__c.addError('You cannot change the team member once the sharing is established. Delete the current and create a new team member record.');
    			if(oldAcctTeamMap.get(acctteam.Id).EUR_CRM_Access_Level__c <> newAcctTeamMap.get(acctteam.Id).EUR_CRM_Access_Level__c && String.IsNotBlank(acctteam.EUR_CRM_Access_Level__c)){
    				String accLevel = accessRightMap.get(acctteam.EUR_CRM_Access_Level__c);
    				if(String.IsNotBlank(acctteam.EUR_CRM_Account_Share_Record_Id__c))
    					acctSharelist.add(new AccountShare(id=acctteam.EUR_CRM_Account_Share_Record_Id__c, AccountAccessLevel=accLevel, OpportunityAccessLevel=accLevel));
    				if(String.IsNotBlank(acctteam.EUR_CRM_EU_Account_Share_Record_Id__c))
    					euAcctSharelist.add(new EUR_CRM_Account__Share(id=acctteam.EUR_CRM_EU_Account_Share_Record_Id__c, AccessLevel=accLevel));
    			}
    		}
    		if(acctSharelist.size()>0){
    			System.debug(acctSharelist);
    			update acctSharelist;
    		}
    		if(euAcctSharelist.size()>0){
    			update euAcctSharelist;
    		}
    	}
    	
    	if(tAction == TriggerAction.BEFORE_DELETE){
    		for(EUR_CRM_Account_Team__c acctteam : acctTeamlist){
    			if(String.IsNotBlank(acctteam.EUR_CRM_Account_Share_Record_Id__c))
    				acctSharelist.add(new AccountShare(id=acctteam.EUR_CRM_Account_Share_Record_Id__c));
    			if(String.IsNotBlank(acctteam.EUR_CRM_EU_Account_Share_Record_Id__c))
    					euAcctSharelist.add(new EUR_CRM_Account__Share(id=acctteam.EUR_CRM_EU_Account_Share_Record_Id__c));
    		}
    		if(acctSharelist.size()>0){
    			delete acctSharelist;
    		}
    		if(euAcctSharelist.size()>0){
    			delete euAcctSharelist;
    		}
    	}
    }
    
    private String getAcctTeamKey(EUR_CRM_Account_Team__c member){
    	return member.EUR_CRM_Account__c+'_'+member.EUR_CRM_Team_Member__c;
    }
    
    private EUR_CRM_Account__Share createEUAcctShare(EUR_CRM_Account_Team__c member){
    	EUR_CRM_Account__Share teamMember = new EUR_CRM_Account__Share();
    	teamMember.AccessLevel = accessRightMap.get(member.EUR_CRM_Access_Level__c) == null ? 'Read' : accessRightMap.get(member.EUR_CRM_Access_Level__c);
    	teamMember.ParentId = member.EUR_CRM_Account__c;
    	teamMember.UserOrGroupId = member.EUR_CRM_Team_Member__c;
    	return teamMember;
    }
    
    private AccountShare createAcctShare(EUR_CRM_Account_Team__c member, Id acctId){
    	AccountShare teamMember = new AccountShare();
    	teamMember.AccountAccessLevel = accessRightMap.get(member.EUR_CRM_Access_Level__c) == null ? 'Read' : accessRightMap.get(member.EUR_CRM_Access_Level__c);
    	teamMember.OpportunityAccessLevel = teamMember.AccountAccessLevel;
    	teamMember.AccountId = acctId;
    	teamMember.UserOrGroupId = member.EUR_CRM_Team_Member__c;
    	System.debug('team member:' + teamMember);
    	return teamMember;
    }
}