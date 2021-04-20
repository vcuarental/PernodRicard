/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Update volume tracker 'latest forecast of contract volume' from volume captured in Store Audit
  @Author:      IPC
  @History:     MAY.29.2014 - Created
*/
public with sharing class EUR_CRM_VolumeTrackerContractVol extends EUR_CRM_TriggerAbstract{
    
    public EUR_CRM_VolumeTrackerContractVol(){
        super('EUR_CRM_VolumeTrackerContractVol');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<EUR_CRM_Contract__c> contractsList = new List<EUR_CRM_Contract__c>();
        List<EUR_CRM_GB_Volume_Tracker__c> volumeTrackerList = new List<EUR_CRM_GB_Volume_Tracker__c>();
        List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemList = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        Map<String, List<EUR_CRM_Store_Audit_Item__c>> accStoreAuditItemMap = new Map<String, List<EUR_CRM_Store_Audit_Item__c>>();

        Id recId = Schema.SObjectType.EUR_CRM_Store_Audit_Item__c.getRecordTypeInfosByName().get('GB FS Store Audit').getRecordTypeId();
        
        for(EUR_CRM_Store_Audit_Item__c sItem :(List<EUR_CRM_Store_Audit_Item__c>)sObjList){
            if(sItem.RecordTypeId == recId && sItem.EUR_CRM_Volume_per_Month_9L_Cases__c != null){
                if(!accStoreAuditItemMap.containsKey(sItem.EUR_CRM_Store_Audit_Account__c)){
                    accStoreAuditItemMap.put(sItem.EUR_CRM_Store_Audit_Account__c, new List<EUR_CRM_Store_Audit_Item__c>());
                }
                accStoreAuditItemMap.get(sItem.EUR_CRM_Store_Audit_Account__c).add(sItem);
            }
        }
        
        if(accStoreAuditItemMap.size() > 0){
            contractsList = new List<EUR_CRM_Contract__c>([Select EUR_CRM_Account__c, EUR_CRM_Active__c
                            from EUR_CRM_Contract__c 
                            where EUR_CRM_Active__c = true
                            and EUR_CRM_Account__c IN: accStoreAuditItemMap.keySet()]);
        }
        
        if(contractsList.size() > 0){
            volumeTrackerList = new List<EUR_CRM_GB_Volume_Tracker__c>([Select EUR_CRM_Contract__c, EUR_CRM_Account__c from EUR_CRM_GB_Volume_Tracker__c where EUR_CRM_Contract__c IN: contractsList]);
        }
        
        if(volumeTrackerList.size() > 0){
            volumeTrackerItemList = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>([Select EUR_CRM_Adjusted_Contract_Volume__c, EUR_CRM_Brand_Quality__c, EUR_CRM_Account__c, EUR_CRM_Contract__c, EUR_CRM_Contract_Duration__c
                                    from EUR_CRM_GB_Volume_Tracker_Line_Item__c
                                    where EUR_CRM_Volume_Tracker__c IN: volumeTrackerList]);
        }
        
        if(volumeTrackerItemList.size() > 0){
            List<EUR_CRM_Store_Audit_Item__c> storeAuditItemList = new List<EUR_CRM_Store_Audit_Item__c>();
            Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> tempVolumeTrackerItem = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
            Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> tempMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
            List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> updateVolumeTrackerItem = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
            
            for(EUR_CRM_GB_Volume_Tracker_Line_Item__c vtiL :volumeTrackerItemList){
                storeAuditItemList = accStoreAuditItemMap.get(vtiL.EUR_CRM_Account__c);
                if(accStoreAuditItemMap.containsKey(vtiL.EUR_CRM_Account__c) && storeAuditItemList.size() > 0){
                    for(EUR_CRM_Store_Audit_Item__c sai :storeAuditItemList){
                        if(vtiL.EUR_CRM_Brand_Quality__c == sai.EUR_CRM_Brand_Quality__c){
                            vtiL.EUR_CRM_Adjusted_Contract_Volume__c = sai.EUR_CRM_Volume_per_Month_9L_Cases__c * (vtiL.EUR_CRM_Contract_Duration__c);
                            
                            if(!tempVolumeTrackerItem.containsKey(vtiL.EUR_CRM_Account__c)){
                                tempMap.put(vtiL.EUR_CRM_Brand_Quality__c, vtiL);
                                tempVolumeTrackerItem.put(vtiL.EUR_CRM_Account__c, vtiL);
                                updateVolumeTrackerItem.add(vtiL);
                            }else{
                                if(!tempMap.containsKey(vtiL.EUR_CRM_Brand_Quality__c)){
                                    updateVolumeTrackerItem.add(vtiL);
                                }
                            }
                            
                        }
                    }
                }
            }
            system.debug('***:' +updateVolumeTrackerItem);
            if(updateVolumeTrackerItem.size() > 0){
                update updateVolumeTrackerItem;
            }
        }
    }
}