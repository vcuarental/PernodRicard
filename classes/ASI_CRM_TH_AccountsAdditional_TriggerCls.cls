/*Filename:     ASI_CRM_TH_AccountsAdditional_TriggerCls.cls
* Author:       Twinkle LI (Introv Limited)
* Purpose:      Handle TH Customer Trigger Logic
* Created Date: 04/03/2016
*/
public with sharing class ASI_CRM_TH_AccountsAdditional_TriggerCls {
    public static void routineAfterUpdate(list<ASI_CRM_AccountsAdditionalField__c > trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap){ 
        Map<Id, ASI_CRM_AccountsAdditionalField__c> mapCustUpdated = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();  
        Set<Id> setCustUpdated = new Set<Id>();
        Set<Id> setOutletType = new Set<Id>();
        Map<id, ASI_TH_CRM_OutletType__c> mapOutletType = new Map<id, ASI_TH_CRM_OutletType__c>();
        
        for (ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
            if(cust.ASI_TH_CRM_OutletType__c != trigger_oldMap.get(cust.id).ASI_TH_CRM_OutletType__c){
                mapCustUpdated.put(cust.id, cust);
                setCustUpdated.add(cust.id);
            }
        }
        system.debug('mapCustUpdated: '+mapCustUpdated);
        
        List<ASI_CRM_Pros_Segmentation__c> listProsToUpdate = [SELECT Id, ASI_CRM_SG_Customer__c, ASI_CRM_SG_Group_Outlet_Type__c FROM ASI_CRM_Pros_Segmentation__c WHERE ASI_CRM_SG_Customer__c IN:setCustUpdated];
        for(ASI_CRM_Pros_Segmentation__c prosSeg : listProsToUpdate){
            if(prosSeg.ASI_CRM_SG_Customer__c != NULL && mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c) != NULL)
                setOutletType.add(mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c).ASI_TH_CRM_OutletType__c);
        }
        
        List<ASI_TH_CRM_OutletType__c> listOutletType = [SELECT id, ASI_CRM_Group_Outlet_Type__c FROM ASI_TH_CRM_OutletType__c WHERE id IN: setOutletType];     
        for(ASI_TH_CRM_OutletType__c ot : listOutletType){
            mapOutletType.put(ot.id, ot);
        }
        system.debug('mapOutletType: '+mapOutletType);
          
        for(ASI_CRM_Pros_Segmentation__c prosSeg : listProsToUpdate){
            if(prosSeg.ASI_CRM_SG_Customer__c != NULL && mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c) != NULL && 
               mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c).ASI_TH_CRM_OutletType__c != NULL &&
               mapOutletType.get(mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c).ASI_TH_CRM_OutletType__c) != NULL)
                prosSeg.ASI_CRM_SG_Group_Outlet_Type__c = mapOutletType.get(mapCustUpdated.get(prosSeg.ASI_CRM_SG_Customer__c).ASI_TH_CRM_OutletType__c).ASI_CRM_Group_Outlet_Type__c;
        }
        
        update listProsToUpdate;
    }
    
    public static void routineBeforeUpdate(list<ASI_CRM_AccountsAdditionalField__c > trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap){ 
        Set<Id> setOutletTypeIds = new Set<Id>();
        Set<Id> setOutletSubTypeIds = new Set<Id>();
        Set<Id> setOutletImageIds = new Set<Id>();
        
        Map<Id, ASI_TH_CRM_OutletType__c> mapOutletType = new Map<Id, ASI_TH_CRM_OutletType__c>();  
        Map<Id, ASI_TH_CRM_OutletSubType__c> mapOutletSubType = new Map<Id, ASI_TH_CRM_OutletSubType__c>();  
        Map<Id, ASI_TH_CRM_OutletImage__c> mapOutletImage = new Map<Id, ASI_TH_CRM_OutletImage__c>();  
        
        for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
            setOutletTypeIds.add(cust.ASI_TH_CRM_OutletType__c);
            setOutletSubTypeIds.add(cust.ASI_TH_CRM_OutletSubType__c);
            setOutletImageIds.add(cust.ASI_TH_CRM_OutletImage__c);
        }
        
        List<ASI_TH_CRM_OutletType__c> listOutletType = [SELECT id, ASI_TH_CRM_Code__c FROM ASI_TH_CRM_OutletType__c WHERE id IN: setOutletTypeIds];
        List<ASI_TH_CRM_OutletSubType__c> listOutletSubType = [SELECT id, ASI_TH_CRM_Code__c FROM ASI_TH_CRM_OutletSubType__c WHERE id IN: setOutletSubTypeIds];
        List<ASI_TH_CRM_OutletImage__c> listOutletImage = [SELECT id, ASI_TH_CRM_Code__c FROM ASI_TH_CRM_OutletImage__c WHERE id IN: setOutletImageIds];
        
        for(ASI_TH_CRM_OutletType__c ot : listOutletType){
            mapOutletType.put(ot.id, ot);
        }
        for(ASI_TH_CRM_OutletSubType__c ost : listOutletSubType){
            mapOutletSubType.put(ost.id, ost);
        }
        for(ASI_TH_CRM_OutletImage__c oi : listOutletImage){
            mapOutletImage.put(oi.id, oi);
        }
        
        for (ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
            if((cust.ASI_CRM_JDE_Outlet_Type__c != null && mapOutletType != null && mapOutletType.size() > 0 && mapOutletType.get(cust.ASI_TH_CRM_OutletType__c) != null && mapOutletType.get(cust.ASI_TH_CRM_OutletType__c).ASI_TH_CRM_Code__c != cust.ASI_CRM_JDE_Outlet_Type__c) || 
            
               (cust.ASI_CRM_JDE_Outlet_Sub_type__c != null && mapOutletSubType != null && mapOutletSubType.size() > 0 && mapOutletSubType.get(cust.ASI_TH_CRM_OutletSubType__c) != null && mapOutletSubType.get(cust.ASI_TH_CRM_OutletSubType__c).ASI_TH_CRM_Code__c != cust.ASI_CRM_JDE_Outlet_Sub_type__c) ||
               
               (cust.ASI_CRM_JDE_Outlet_Image__c != null && mapOutletImage != null && mapOutletImage.size() > 0 && mapOutletImage.get(cust.ASI_TH_CRM_OutletImage__c) != null && mapOutletImage.get(cust.ASI_TH_CRM_OutletImage__c).ASI_TH_CRM_Code__c != cust.ASI_CRM_JDE_Outlet_Image__c)){
                cust.ASI_CRM_PROS_Discrepancy__c = true;
                
            }
            else {
                cust.ASI_CRM_PROS_Discrepancy__c = false;
            }
        }
    }
}