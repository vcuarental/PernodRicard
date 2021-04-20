//LAT_Opportunity__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_AR_LATOpportunityBeforeInsert   {
	
	public static void execute(){
		Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c',new set<String>{'Nova_oportunidade','OPP_1_NewOrder_ARG','OPP_2_NewOrder_URU','LAT_MX_OPP_NewOrder'});
		List<LAT_Opportunity__c> oppsToSetManager = new List<LAT_Opportunity__c>();

	    list <Id> accIds = new list<Id>();
	    for (LAT_Opportunity__c opp : LAT_OpportunityTriggerHandler.triggerNew) {
	        if(setOppRt.contains(opp.RecordTypeId)){
	            accIds.add(opp.LAT_Account__c);
	        }
	    }
	    
	    if(!accIds.isEmpty()){
	        map <Id, Account> mapAccounts = new map <Id, Account>([SELECT Id, Name, ParentId, LAT_BR_RegionalClientOnPremise__c FROM Account WHERE Id IN: accIds]);
	        for (LAT_Opportunity__c opp : LAT_OpportunityTriggerHandler.triggerNew) {
	            if(opp.LAT_Account__c != null && mapAccounts.containsKey(opp.LAT_Account__c) && opp.RecordTypeId != Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')){
	                opp.LAT_AR_ParentAccount__c = mapAccounts.get(opp.LAT_Account__c).ParentId;
	            }
	            if(opp.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'))
	                opp.LAT_Country__c = 1;
	            else if(opp.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_2_NewOrder_URU'))
	                opp.LAT_Country__c = 5;
	            else if(opp.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG'))
	                opp.LAT_Country__c = 6;
	            else if(opp.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder'))  
	                opp.LAT_Country__c = 12; 

	            if (opp.LAT_StageName__c == 'Mobile Order') {
	                opp.Name = mapAccounts.get(opp.LAT_Account__c).Name;
	                if (opp.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG') 
	                    || opp.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_3_HeaderBlocked_ARG')
	                    || opp.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_5_OrderBlocked_ARG')) {
	                    opp.LAT_OrderOrigin__c = 'APP';
	                }
	            }
				checkIfIsB2bAndOriginIsCTY(opp, mapAccounts);

				if(opp.LAT_Country__c == 6){
					oppsToSetManager.add(opp);
				}
			}
	    }
	    
		if(!oppsToSetManager.isEmpty()){
			setManagerOfManager(oppsToSetManager);
		}
		
	}

	public static void checkIfIsB2bAndOriginIsCTY(LAT_Opportunity__c opp, Map<Id, Account> mapAccounts){
		if(opp.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG') && !opp.LAT_IsAdmin__c) {
			if(mapAccounts.get(opp.LAT_Account__c).LAT_BR_RegionalClientOnPremise__c == 'B2B'){
				if((opp.LAT_OrderOrigin__c == 'CRM' || opp.LAT_OrderOrigin__c == 'APP') && opp.LAT_LeadSource__c != 'B2B'){
					opp.addError('Solo se le pueden cargar pedidos a clientes B2B a través de la Community, o directamente en JDE. No es posible hacerlo desde CRM o Compass');
				}
			}
		}
	}

	public static void setManagerOfManager(List<LAT_Opportunity__c> oppsToSetManager){
				
		Set<Id> oppOwners = new Set<Id>();
		Set<Id> oppOwnersManagers = new Set<Id>();
		Set<Id> oppOwnersManagersGerentes = new Set<Id>();

		Map<Id, User> oppOwnersManagersMap = new Map<Id, User>();

		Map<Id, User> oppOwnersManagerGerentesMap = new Map<Id, User>();
		Map<Id, User> oppOwnersManagerGerentesDirectorMap = new Map<Id, User>();

		for (LAT_Opportunity__c opp : oppsToSetManager) {
			oppOwners.add(opp.ownerid);
		}

		System.debug('oppOwners: ' + oppOwners);

		if(!oppOwners.isEmpty()){
			oppOwnersManagersMap = new Map<Id, User>([SELECT Id, ManagerId, Manager.Name FROM User WHERE Id IN :oppOwners]);
		}

		for (User u : oppOwnersManagersMap.values()) {
			oppOwnersManagers.add(u.managerid);
		}
		System.debug('oppOwnersManagersMap: ' + oppOwnersManagersMap);

		if(oppOwnersManagersMap != null){
			oppOwnersManagerGerentesMap = new Map<Id, User>([SELECT Id, ManagerId, Manager.Name FROM User WHERE Id IN :oppOwnersManagers]);
		}

		for (User u : oppOwnersManagerGerentesMap.values()) {
			oppOwnersManagersGerentes.add(u.managerid);
		}

		System.debug('oppOwnersManagerGerentesMap: ' + oppOwnersManagerGerentesMap);
		
		if(oppOwnersManagerGerentesMap != null){
			oppOwnersManagerGerentesDirectorMap = new Map<Id, User>([SELECT Id, ManagerId, Manager.Name, Manager.UserRole.Name  FROM User WHERE Id IN :oppOwnersManagersGerentes]) ;
		}
		
		System.debug('oppOwnersManagerGerentesDirectorMap: ' + oppOwnersManagerGerentesDirectorMap);
	
		for (LAT_Opportunity__c opp : oppsToSetManager) {

			if(oppOwnersManagersMap.get(opp.ownerid).managerid != null && oppOwnersManagerGerentesMap.get(oppOwnersManagersMap.get(opp.ownerid).Managerid).id != null){
				opp.LAT_AR_Gerente__c = oppOwnersManagerGerentesMap.get(oppOwnersManagersMap.get(opp.ownerid).Managerid).Managerid;
			}
			
			if(oppOwnersManagersMap.get(opp.ownerid).managerid != null && 
				oppOwnersManagerGerentesDirectorMap.get(oppOwnersManagerGerentesMap.get(oppOwnersManagersMap.get(opp.OwnerId).Managerid).Managerid).id  != null){
				opp.LAT_AR_Director__c = oppOwnersManagerGerentesDirectorMap.get(oppOwnersManagerGerentesMap.get(oppOwnersManagersMap.get(opp.ownerid).Managerid).Managerid).managerid;
				
			}
			

		}
	}

}