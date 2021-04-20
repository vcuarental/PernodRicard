/*Filename:    ASI_CRM_TW_AccountsAdditional_TriggerCls.cls
* Author:      Twinkle LI (Introv Limited)
* Purpose:     Handle TW Customer Trigger Logic
*
*/
public with sharing class ASI_CRM_TW_AccountsAdditional_TriggerCls {
    public static void routineAfterUpdate(list<ASI_CRM_AccountsAdditionalField__c > trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap){ 
        Map<Id, ASI_CRM_AccountsAdditionalField__c> mapCustUpdated = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();  
        Set<Id> setCustUpdated = new Set<Id>();
        Set<Id> setSubChannel = new Set<Id>();
        Map<id, ASI_MFM_Sub_Channel__c> mapSubChannel = new Map<id, ASI_MFM_Sub_Channel__c>();
        
        Boolean havePending = false;
        for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
            if(cust.ASI_CRM_MY_GeoConverStatus__c == 'Pending'){
                havePending = true;
                break;
            }
        }
        
        for (ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
            system.debug(cust.ASI_CRM_CN_Sub_Channel__c+','+cust.Name);
            system.debug(trigger_oldMap.get(cust.id).ASI_CRM_CN_Sub_Channel__c+','+trigger_oldMap.get(cust.id).Name);
            if(cust.ASI_CRM_CN_Sub_Channel__c != trigger_oldMap.get(cust.id).ASI_CRM_CN_Sub_Channel__c){
                mapCustUpdated.put(cust.id, cust);
                setCustUpdated.add(cust.id);
            }
        }
        system.debug('mapCustUpdated: '+mapCustUpdated);
        
        List<ASI_CRM_Pros_Segmentation__c> listProsToUpdate = [SELECT Id, ASI_CRM_SG_Customer__c, ASI_CRM_SG_Group_Outlet_Type__c FROM ASI_CRM_Pros_Segmentation__c WHERE ASI_CRM_SG_Customer__c IN:setCustUpdated];
        for(ASI_CRM_Pros_Segmentation__c prosSeg : listProsToUpdate){
            if(prosSeg.ASI_CRM_SG_Customer__c != NULL && mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c) != NULL)
                setSubChannel.add(mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c).ASI_CRM_CN_Sub_Channel__c);
        }
        
        List<ASI_MFM_Sub_Channel__c> listSubChannel = [SELECT id, ASI_CRM_Group_Outlet_Type__c FROM ASI_MFM_Sub_Channel__c WHERE id IN:setSubChannel];     
        for(ASI_MFM_Sub_Channel__c sc:listSubChannel){
            mapSubChannel.put(sc.id, sc);
        }
        system.debug('mapSubChannel: '+mapSubChannel);
          
        for(ASI_CRM_Pros_Segmentation__c prosSeg : listProsToUpdate){
            if(prosSeg.ASI_CRM_SG_Customer__c != NULL && mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c) != NULL && 
               mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c).ASI_CRM_CN_Sub_Channel__c != NULL &&
               mapSubChannel.get(mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c).ASI_CRM_CN_Sub_Channel__c) != NULL)
                prosSeg.ASI_CRM_SG_Group_Outlet_Type__c = mapSubChannel.get(mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c).ASI_CRM_CN_Sub_Channel__c).ASI_CRM_Group_Outlet_Type__c;
        }
        
        update listProsToUpdate;
        
        if(havePending){
            if(!test.isRunningTest())
            {
                ASI_CRM_TW_AccountAddressBatch batch = new ASI_CRM_TW_AccountAddressBatch();
                DataBase.executeBatch(batch, 20);
            }
        }
    }
}