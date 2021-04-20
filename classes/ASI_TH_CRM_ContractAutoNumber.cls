public with sharing class ASI_TH_CRM_ContractAutoNumber extends ASI_HK_CRM_TriggerAbstract {
    
    String keyName;
    
    public ASI_TH_CRM_ContractAutoNumber() {
        super('ASI_TH_CRM_ContractAutoNumber');
        keyName='ASI_TH_CRM_Contract__c';
    }
    
    public ASI_TH_CRM_ContractAutoNumber(String keyName) {
        super('ASI_TH_CRM_ContractAutoNumber');
        this.keyName=keyName;
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT)
            && !isBypassByCurrentUser()) {
            List<ASI_TH_CRM_Contract__c> soList = (List<ASI_TH_CRM_Contract__c>)sObjList;            
            Map<id, Account> accountMap = new Map<id, Account>();
            Set<Id> outletIds = new Set<Id>();
            for (ASI_TH_CRM_Contract__c so : soList) {
                outletIds.add(so.ASI_TH_CRM_Outlet__c);
            }
            for (Account outlet : [Select ownerid From Account WHERE id in :outletIds]){
                accountMap.put(outlet.id, outlet);
            }
            
            ASI_HK_CRM_AutoNumberAssignment autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment(keyName);
            for (ASI_TH_CRM_Contract__c so : soList) {
                if (so.ASI_TH_CRM_Contract_No_Data_Migration__c == null || so.ASI_TH_CRM_Contract_No_Data_Migration__c == '' ){
                    so.Name = autoNumAssign.nextAutoNumStr();
                }else{
                    so.Name = so.ASI_TH_CRM_Contract_No_Data_Migration__c;
                }
                //so.OwnerId = ((Account)[Select ownerid From Account WHERE id = :so.ASI_TH_CRM_Outlet__c]).ownerid;
                so.OwnerId = ((Account)accountMap.get(so.ASI_TH_CRM_Outlet__c)).ownerid;
            }
            autoNumAssign.writeToDB();
        }
    }

}