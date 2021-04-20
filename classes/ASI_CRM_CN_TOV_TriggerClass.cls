public without sharing class ASI_CRM_CN_TOV_TriggerClass {
    
    public static void routineAfterUpdate(list<ASI_CRM_TOV__c> trigger_new, map<id, ASI_CRM_TOV__c> trigger_oldMap) {
        Set<id> FOC_Set = new Set<id>();
        for(ASI_CRM_TOV__c tov: trigger_new){
            if(tov.ASI_CRM_Free_Goods_Request__c != null){
                FOC_Set.add(tov.ASI_CRM_Free_Goods_Request__c);
            }
        }
        if(FOC_Set.size() > 0) {
            for (ASI_CRM_TOV__c tov : [select ASI_CRM_Free_Goods_Request__c, ASI_CRM_Free_Goods_Request__r.ASI_FOC_Delivery_Status__c , ASI_CRM_Status__c FROM ASI_CRM_TOV__c WHERE ASI_CRM_Free_Goods_Request__c IN : FOC_Set]){
                if(tov.ASI_CRM_Status__c != 'Received' || tov.ASI_CRM_Free_Goods_Request__r.ASI_FOC_Delivery_Status__c == 'Delivered'){
                    if (FOC_Set.contains(tov.ASI_CRM_Free_Goods_Request__c)){
                        FOC_Set.remove(tov.ASI_CRM_Free_Goods_Request__c);
                    }
                }
            }
            if (FOC_Set.size() > 0) {
                List<ASI_FOC_Free_Goods_Request__c> focList = [SELECT id FROM ASI_FOC_Free_Goods_Request__c WHERE id IN: FOC_Set];
                for (ASI_FOC_Free_Goods_Request__c foc :  focList){
                    foc.ASI_FOC_Delivery_Status__c = 'Delivered';
                }
                update focList;
            }
        }
        
    }
    
    public static void routineBeforeUpdate(list<ASI_CRM_TOV__c> trigger_new, map<id, ASI_CRM_TOV__c> trigger_oldMap) {
        assignSOOwner(trigger_new);
		assignPOSMOwner(trigger_new);
    }
    
    Public Static void routineBeforeInsert(List<ASI_CRM_TOV__c> triggerNew){
        assignSOOwner(triggerNew);
		assignPOSMOwner(triggerNew);
    }
    
    private static void assignSOOwner(List<ASI_CRM_TOV__c> triggerNew){
        Set<String> soID = new Set<String>();
        
        for(ASI_CRM_TOV__c obj : triggerNew){
            if(obj.ASI_CRM_SF_SO_Request_Number__c != NULL)
                soID.add(obj.ASI_CRM_SF_SO_Request_Number__c);
        }
        
        Map<id, ASI_KOR_Sales_Order_Request__c> mapSO = new Map<id, ASI_KOR_Sales_Order_Request__c>([SELECT id, ownerID, 
                                                                                                            ASI_CTY_CN_WS_Sales_Rep1__c, ASI_CTY_CN_WS_Sales_Rep1__r.Email,
                                                                                                            ASI_CTY_CN_WS_Sales_Rep2__c, ASI_CTY_CN_WS_Sales_Rep2__r.Email,
                                                                                                            ASI_CTY_CN_WS_Sales_Rep3__c, ASI_CTY_CN_WS_Sales_Rep3__r.Email
                                                                                                       FROM ASI_KOR_Sales_Order_Request__c WHERE Id IN : soID]);
        
        for(ASI_CRM_TOV__c obj : triggerNew){
            if(obj.ASI_CRM_SF_SO_Request_Number__c != NULL) {
                obj.ASI_CRM_SF_SO_Owner__c = mapSO.get(obj.ASI_CRM_SF_SO_Request_Number__c).ownerID;
            }
            //add Alex BLS -- send TOV to sales start
            if(obj.ASI_CRM_SF_SO_Request_Number__c != NULL && mapSO.get(obj.ASI_CRM_SF_SO_Request_Number__c).ASI_CTY_CN_WS_Sales_Rep1__c != null) {
                obj.ASI_CTY_CN_WS_SOR_Sales_Email_1__c = mapSO.get(obj.ASI_CRM_SF_SO_Request_Number__c).ASI_CTY_CN_WS_Sales_Rep1__r.Email;
            }
            if(obj.ASI_CRM_SF_SO_Request_Number__c != NULL && mapSO.get(obj.ASI_CRM_SF_SO_Request_Number__c).ASI_CTY_CN_WS_Sales_Rep2__c != null) {
                obj.ASI_CTY_CN_WS_SOR_Sales_Email_2__c = mapSO.get(obj.ASI_CRM_SF_SO_Request_Number__c).ASI_CTY_CN_WS_Sales_Rep2__r.Email;
            }
            if(obj.ASI_CRM_SF_SO_Request_Number__c != NULL && mapSO.get(obj.ASI_CRM_SF_SO_Request_Number__c).ASI_CTY_CN_WS_Sales_Rep3__c != null) {
                obj.ASI_CTY_CN_WS_SOR_Sales_Email_3__c = mapSO.get(obj.ASI_CRM_SF_SO_Request_Number__c).ASI_CTY_CN_WS_Sales_Rep3__r.Email;
            }
            //add Alex BLS -- send TOV to sales end
        }
    }
    //20200724 edit by Leo Jing BLS start: New assignment of field Vendor_Email
    private static void assignPOSMOwner(List<ASI_CRM_TOV__c> triggerNew){
        Set<String> setPOSMID = new Set<String>();

        for(ASI_CRM_TOV__c obj : triggerNew){
            if(obj.ASI_CRM_Free_Goods_Request__c  != NULL)
                setPOSMID.add(obj.ASI_CRM_Free_Goods_Request__c );                
        }
        
        Map<id, ASI_FOC_Free_Goods_Request__c> mapPOSM = new Map<id, ASI_FOC_Free_Goods_Request__c>([SELECT id, ownerID
                                                                                                     , ASI_MFM_SIREmailAddress1__c, ASI_MFM_SIREmailAddress2__c, ASI_MFM_SIREmailAddress3__c, ASI_MFM_SIREmailAddress4__c
                                                                                                     , ASI_MFM_SIREmailAddress5__c, ASI_MFM_SIREmailAddress6__c, ASI_MFM_SIREmailAddress7__c, ASI_MFM_SIREmailAddress8__c
                                                                                                     , ASI_MFM_FromWarehouse__r.ASI_CRM_CN_Vendor_Email_1__c,ASI_MFM_FromWarehouse__r.ASI_CRM_CN_Vendor_Email_2__c
                                                                                                     , ASI_CRM_CN_FG_Supplier_Email__c
                                                                                                     FROM ASI_FOC_Free_Goods_Request__c WHERE Id IN : setPOSMID]);

        List<ASI_MFM_RequestItem_UserAssignment__c> userAssignmentList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
            userAssignmentList = [ SELECT Id,Name,ASI_MFM_User__r.Email,ASI_MFM_Request_Item__r.ASI_FOC_Request_Order__c FROM  ASI_MFM_RequestItem_UserAssignment__c WHERE ASI_MFM_Request_Item__r.ASI_FOC_Request_Order__c IN: setPOSMID]; 
        
        Map<String,Set<String>> order_UserMap = new Map<String,Set<String>>();

        for (ASI_MFM_RequestItem_UserAssignment__c userA : userAssignmentList) {
            Set<String>  userEmailSet = order_UserMap.get(userA.ASI_MFM_Request_Item__r.ASI_FOC_Request_Order__c);
            if (userEmailSet == null) {
                userEmailSet = new Set<String>();
                order_UserMap.put(userA.ASI_MFM_Request_Item__r.ASI_FOC_Request_Order__c, userEmailSet);
            }
            userEmailSet.add(userA.ASI_MFM_User__r.Email);
        }
        for(ASI_CRM_TOV__c obj : triggerNew){
            if(obj.ASI_CRM_Free_Goods_Request__c != NULL) {
               
                obj.ASI_CRM_SF_SO_Owner__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ownerID;      
                obj.ASI_CRM_CN_Supplier_Email__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_CRM_CN_FG_Supplier_Email__c;

                if (obj.ASI_CRM_CN_Is_POSM_TOV__c) {
                    obj.ASI_CRM_CN_Vendor_Email_1__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_FromWarehouse__r.ASI_CRM_CN_Vendor_Email_1__c;
                    obj.ASI_CRM_CN_Vendor_Email_2__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_FromWarehouse__r.ASI_CRM_CN_Vendor_Email_2__c;   
                    List<String> emailSet = new List<String>(order_UserMap.get(obj.ASI_CRM_Free_Goods_Request__c));
                    if (emailSet != null) {
                        Integer length = emailSet.size()>8?8:emailSet.size();    
                        for ( Integer i = 0 ; i < 8 ; i++ ) {
                            if(i+1 > length){
                                obj.put('ASI_MFM_SIREmailAddress'+(i+1)+'__c', '');
                            }else {
                                obj.put('ASI_MFM_SIREmailAddress'+(i+1)+'__c', emailSet[i]);
                            }
                            

                        }                        
                    }                    
                }else{
                    obj.ASI_MFM_SIREmailAddress1__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_SIREmailAddress1__c;
                    obj.ASI_MFM_SIREmailAddress2__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_SIREmailAddress2__c;
                    obj.ASI_MFM_SIREmailAddress3__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_SIREmailAddress3__c;
                    obj.ASI_MFM_SIREmailAddress4__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_SIREmailAddress4__c;
                    obj.ASI_MFM_SIREmailAddress5__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_SIREmailAddress5__c;
                    obj.ASI_MFM_SIREmailAddress6__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_SIREmailAddress6__c;                
                    obj.ASI_MFM_SIREmailAddress7__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_SIREmailAddress7__c;
                    obj.ASI_MFM_SIREmailAddress8__c = mapPOSM.get(obj.ASI_CRM_Free_Goods_Request__c).ASI_MFM_SIREmailAddress8__c;   
                }                 
                                      
            }
        }    
    }
    //20200724 edit by Leo Jing BLS end. 
    
    //2019/10/27 CanterDuan 添加功能：新增TOV时，获取最新的税率
    public static void GetTaxRate(List<ASI_CRM_TOV__c> triggerNew){
        //获取税率信息
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c 
                                                                                        FROM ASI_CRM_CN_Tax_Rate_Config__c 
                                                                                        ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        if(taxRateList.isEmpty()) return;
        for(ASI_CRM_TOV__c tov: triggerNew){
            tov.ASI_CRM_CN_Tax_Rate__c = taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }
    }
    //2019/10/27 END
}