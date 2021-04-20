public with sharing class ASI_CRM_CN_ContractPONoAutoNumber extends ASI_HK_CRM_TriggerAbstract {
    
    public ASI_CRM_CN_ContractPONoAutoNumber() {
        super('ASI_CRM_CN_ContractPONoAutoNumber');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT)
            && !isBypassByCurrentUser()) {
            List<ASI_TH_CRM_Contract__c> soList = (List<ASI_TH_CRM_Contract__c>)sObjList;               
                     
            User currentUser = [Select ASI_CRM_CN_Prefix__c From User Where id = :UserInfo.getUserId()];
           
            ASI_HK_CRM_AutoNumberAssignment autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c);
            for (ASI_TH_CRM_Contract__c so : soList) {
                /*if (so.ASI_TH_CRM_Contract_No_Data_Migration__c == null || so.ASI_TH_CRM_Contract_No_Data_Migration__c == '' ){
                    so.ASI_CRM_CN_PO_No__c = autoNumAssign.nextAutoNumStr();
                }else{
                    so.Name = so.ASI_TH_CRM_Contract_No_Data_Migration__c;
                }  */
                System.Debug('Start Assign');
                if(so.ASI_CRM_CN_PO_No__c == null || so.ASI_CRM_CN_PO_No__c == '')
                    so.ASI_CRM_CN_PO_No__c = currentUser.ASI_CRM_CN_Prefix__c + autoNumAssign.nextAutoNumStr();            
                System.Debug('Stop Assign');
                //so.ASI_CRM_CN_PO_No__c = 'Auto PO';            
            }
            autoNumAssign.writeToDB();
        }
    }

}