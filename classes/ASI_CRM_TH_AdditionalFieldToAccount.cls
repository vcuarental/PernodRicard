public with sharing class ASI_CRM_TH_AdditionalFieldToAccount extends ASI_HK_CRM_TriggerAbstract {
    public ASI_CRM_TH_AdditionalFieldToAccount() {
        super('ASI_CRM_TH_AdditionalFieldToAccount');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)) {
            List<ASI_CRM_AccountsAdditionalField__c> soList = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;
            Map<String, ASI_CRM_ServicePack__c> servicePackMap = new Map<String, ASI_CRM_ServicePack__c>();
            
            Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ServicePack__cASI_CRM_TH_ServicePack');
            List<ASI_CRM_ServicePack__c> listServicePack = [SELECT Id, ASI_CRM_Outlet_Type__c, ASI_CRM_OutletImage__c FROM ASI_CRM_ServicePack__c WHERE RecordTypeId =: RecordTypeId];
            for(ASI_CRM_ServicePack__c sp : listServicePack){
                if(sp.ASI_CRM_Outlet_Type__c != null && sp.ASI_CRM_OutletImage__c != null)
                    servicePackMap.put((''+sp.ASI_CRM_Outlet_Type__c).substring(0,15) + (''+sp.ASI_CRM_OutletImage__c).substring(0,15), sp); 
            }
            
            for (ASI_CRM_AccountsAdditionalField__c accountAdditionalField : soList) {
                //Update Service Pack - According to Outlet Type & Outlet Image changes
                if (accountAdditionalField.ASI_TH_CRM_OutletSubType__c != null && accountAdditionalField.ASI_TH_CRM_OutletImage__c != null){
                    if(accountAdditionalField.ASI_TH_CRM_OutletType__c != null && accountAdditionalField.ASI_TH_CRM_OutletImage__c != null){
                        ASI_CRM_ServicePack__c servicePack = (ASI_CRM_ServicePack__c)servicePackMap.get((''+accountAdditionalField.ASI_TH_CRM_OutletType__c).substring(0,15) + (''+accountAdditionalField.ASI_TH_CRM_OutletImage__c).substring(0,15));
                        accountAdditionalField.ASI_CRM_Service_Pack__c = (servicePack == null) ? null : servicePack.id;
                    }
                }
            }
        }
    }
}