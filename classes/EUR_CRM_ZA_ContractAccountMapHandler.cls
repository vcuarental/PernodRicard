public  class EUR_CRM_ZA_ContractAccountMapHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ZA_ContractAccountMapHandler(){
        super('EUR_CRM_ZA_ContractAccountMapHandler');
    }

    private final Set<String> validContractRecordTypes = new Set<String>{
      'EUR_ZA_Head_Office_Contract'
    };
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> contractRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Contract__c');
        Map<Id,Recordtype> contractRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : contractRecordTypes){
           contractRecordTypesMap.put(rt.id,rt);
        }
        Map<Id,Id> accountContractMap = new Map<Id, Id>();
        for(EUR_CRM_Contract__c contract : (List<EUR_CRM_Contract__c>) sObjList){ 

            String devName = contractRecordTypesMap.get(contract.recordTypeId).developername;
            EUR_CRM_Contract__c oldRecord = (EUR_CRM_Contract__c ) oldMap.get(contract.id);

            if(validContractRecordTypes.contains(devName)){
                if(contract.EUR_CRM_Status__c == 'Activated' && oldRecord.EUR_CRM_Status__c != contract.EUR_CRM_Status__c){
                    accountContractMap.put(contract.EUR_CRM_Account__c, contract.id);
                }
            }
        }
        List<EUR_CRM_Contract_Account_Mapping__c> toInsert = new List<EUR_CRM_Contract_Account_Mapping__c>();
        if(accountContractMap.keySet().size() > 0){
            Id zaContractAcctMappingId = [SELECT Id FROM Recordtype WHERE SObjectType = 'EUR_CRM_Contract_Account_Mapping__c' AND DeveloperName = 'EUR_ZA_Contract_Account_Mapping'].Id;
            for(EUR_CRM_Account__c euAccount : [select id,EUR_CRM_Parent_Account__c from EUR_CRM_Account__c where EUR_CRM_Parent_Account__c in: accountContractMap.keySet() ]){
                Id contractId = accountContractMap.get(euAccount.EUR_CRM_Parent_Account__c);
                if(contractId != null){
                    toInsert.add(new EUR_CRM_Contract_Account_Mapping__c(EUR_CRM_Account__c = euAccount.id, EUR_CRM_Contract__c = contractId, RecordtypeId = zaContractAcctMappingId));
                }       
            }
            if(toInsert.size() > 0){
                insert toInsert;
            } 
        }
    }
}