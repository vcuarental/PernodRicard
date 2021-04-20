public with sharing class EUR_CRM_ZA_UpdateMngrsOnContractHandler extends EUR_CRM_TriggerAbstract {

	public EUR_CRM_ZA_UpdateMngrsOnContractHandler() {
	    super('EUR_CRM_ZA_UpdateMngrsOnContractHandler');
	}
	
	private Set<String> validContractRecordTypes = new Set<String>{
		'EUR_ZA_Head_Office_Contract',
		'EUR_ZA_Outlet_Contract'
	};
	
	private static Set<String> validEUAcctRecordTypes = new Set<String>{
		'EUR_ZA_Distributor',
		'EUR_ZA_Off_Trade',
		'EUR_ZA_On_Trade_Direct',
		'EUR_ZA_On_Trade_Indirect',
		'EUR_ZA_On_Trade_Informal'
	}; 

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(validEUAcctRecordTypes);

            return TRt;
        }private set;
    }
	
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		List<Recordtype> contractRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Contract__c');
        Map<Id,Recordtype> contractRecordTypesMap = new Map<Id,Recordtype>();
        List<Recordtype> euAccountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> euAccountRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : contractRecordTypes ){
           contractRecordTypesMap.put(rt.id,rt);
        }
        
        for(Recordtype rt : euAccountRecordTypes ){
           euAccountRecordTypesMap.put(rt.id,rt);
        }
        
        Map<Id, EUR_CRM_Account__c> accountMap = new Map<Id, EUR_CRM_Account__c>();
        for(EUR_CRM_Account__c account : (List<EUR_CRM_Account__c>) sObjList) { 
        	String euAccountRTDevName = euAccountRecordTypesMap.get(account.RecordtypeId).developername;   
        	if(validEUAcctRecordTypes.contains(euAccountRTDevName)){
        		EUR_CRM_Account__c oldRecord = (EUR_CRM_Account__c ) oldMap.get(account.Id);   
	            if(account.EUR_CRM_Warehouse_Manager__c != oldRecord.EUR_CRM_Warehouse_Manager__c || account.EUR_CRM_Event_Manager__c != oldRecord.EUR_CRM_Event_Manager__c){
	            	accountMap.put(account.id, account);
	            }
        	}    
        }

        List<EUR_CRM_Contract__c> contractToUpdate = new List<EUR_CRM_Contract__c>();
        if(accountMap.size() > 0) {
            for(EUR_CRM_Contract__c contract : [SELECT id, EUR_CRM_Account__c, EUR_CRM_Warehouse_Manager__c, RecordtypeId, EUR_CRM_Event_Manager__c FROM EUR_CRM_Contract__c WHERE EUR_CRM_Account__c IN :accountMap.keyset()]){
                String contractRTDevName = contractRecordTypesMap.get(contract.RecordtypeId).developername;            
                if(validContractRecordTypes.contains(contractRTDevName)){
                    contract.EUR_CRM_Warehouse_Manager__c = accountMap.get(contract.EUR_CRM_Account__c).EUR_CRM_Warehouse_Manager__c;
                    contract.EUR_CRM_Event_Manager__c = accountMap.get(contract.EUR_CRM_Account__c).EUR_CRM_Event_Manager__c;
                    contractToUpdate.add(contract);
                }
            }
        }

        if(contractToUpdate.size() > 0){
        	update contractToUpdate;
        }
	}
}