/*********************************************************************************
 * Name:ASI_CRM_PH_DailyRollUp_Batch
 * Description: 
 * Test Class: ASI_CRM_SG_TestClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-07-09       Wilken Lee              Created
*********************************************************************************/
global class ASI_CRM_PH_DailyRollUp_Batch implements Database.Batchable<sObject>,  Schedulable{		
	private final String customerRTName = 'ASI_CRM_PH_Customer';


    global void execute(SchedulableContext contextInstance) {}
    
    global Database.QueryLocator start(Database.BatchableContext contextInstance){
		string Query = 'select id, Name, ASI_CRM_Contracted__c from ASI_CRM_AccountsAdditionalField__c where recordtype.DeveloperName = ';
		
		Query += '\'' + customerRTName + '\' AND ASI_CRM_Active__c = TRUE';
			
        system.debug('Query: ' + Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext contextInstance, List<sObject> listsObject){
        system.debug('Debug: execute');     
        
		List<ASI_CRM_AccountsAdditionalField__c> custToUpdate = new List<ASI_CRM_AccountsAdditionalField__c>();
		
        Map<Id, ASI_CRM_AccountsAdditionalField__c> mapCustomerId_Record = new Map<Id, ASI_CRM_AccountsAdditionalField__c>( (List<ASI_CRM_AccountsAdditionalField__c>) listsObject );   
               
        List<ASI_TH_CRM_Contract__c> contractList = [select id, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c, ASI_CRM_CN_Outlet_WS__c 
			from ASI_TH_CRM_Contract__c where ASI_CRM_CN_Outlet_WS__c in :mapCustomerId_Record.keySet() and ASI_CRM_CN_Approval_Status__c = 'Approved'];
        
		system.debug('contractList size: ' + contractList.size() + ' mapCustomerId_Record.keySet(): ' + mapCustomerId_Record.keySet());
		
		Map<Id,List<ASI_TH_CRM_Contract__c>> custContractListMap = new Map<Id,List<ASI_TH_CRM_Contract__c>>();
		
		for (ASI_TH_CRM_Contract__c contract:contractList){
			List<ASI_TH_CRM_Contract__c> cList = new List<ASI_TH_CRM_Contract__c>();
			
			if (custContractListMap.get(contract.ASI_CRM_CN_Outlet_WS__c) == null){				
				cList.add(contract);
				
				custContractListMap.put(contract.ASI_CRM_CN_Outlet_WS__c, cList);
			}
			else {
				cList = custContractListMap.get(contract.ASI_CRM_CN_Outlet_WS__c);
				cList.add(contract);
				
			}
		}
		
        system.debug('custContractListMap: ' + custContractListMap);
        
        for (ASI_CRM_AccountsAdditionalField__c cust: mapCustomerId_Record.values()){
			cust.ASI_CRM_Contracted__c = false;
			
			if (custContractListMap.get(cust.Id) != null){
				for (ASI_TH_CRM_Contract__c c:custContractListMap.get(cust.Id)){
					if (c.ASI_TH_CRM_End_Date__c > System.Today())
						cust.ASI_CRM_Contracted__c = true;
				}
			}
		}
		
		update mapCustomerId_Record.values();
	}
    
   global void finish(Database.BatchableContext contextInstance){
   }
}