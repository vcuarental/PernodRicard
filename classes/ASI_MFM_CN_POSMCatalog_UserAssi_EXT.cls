public class ASI_MFM_CN_POSMCatalog_UserAssi_EXT {
    Private Static Final String WAREHOUSE_ID = Global_recordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
    Private Static Final String OUTLET_ID = Global_recordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
    Private Static Final String CITY_ID = Global_recordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City');
    Private Static Final String IBD_ID =  Global_recordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy');
    Private Static Final String INV_BALANCE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Inventory_Balance__cASI_MFM_CN_Inventory_Balance');
    Private Static Final String POSMSKU_ID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU');
    Private Static Final String CART_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM');
    Private Static Final String CART_RO_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only');
    Private Static Final String CART_ITEM_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item');
    Private Static Final String USER_ASSI_ID = Global_RecordTypeCache.getRtId('ASI_MFM_RequestItem_UserAssignment__cASI_MFM_CN_UA_POSM');
    
    Private Static Final String EXP_CONTROL_ID = Global_recordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Tax_Saving_Control_Form');
    
    Public ASI_MFM_CN_POSMCatalog_UserAssi_EXT(ASI_MFM_CN_POSMCatalog_CTRL controller){}
    
    @RemoteAction
    Public Static Map<Id,User> getUser() {
        return new Map<Id,User>([SELECT ID, Name, Username, ADDomainUser__c FROM User WHERE CompanyName = 'Pernod Ricard China' AND IsActive = true]);
    }
    
    @RemoteAction
    Public Static Map<String, User> searchUser(String keyword) {
        String searchStr = '%'+keyword+'%';
        Map<String, User> resultMap = new Map<String, User>();
        for(User u :[SELECT ID, Name, Username, ADDomainUser__c 
                     FROM User 
                     WHERE CompanyName = 'Pernod Ricard China' 
                     AND IsActive = true 
                     AND (Name LIKE :searchStr OR Username LIKE :searchStr OR ADDomainUser__c LIKE :searchStr)
                     ORDER BY Name LIMIT 10
                    ])
        {
            resultMap.put(((u.Name==null)?'':u.Name+' ')+'(' +u.Username+')'+((u.ADDomainUser__c==null)?'':' '+u.ADDomainUser__c), u);
        }
        return resultMap;
    }
    
    @RemoteAction
    Public Static Map<Id,List<ASI_MFM_RequestItem_UserAssignment__c>> searchUserAssiRec(List<Id> reqItemIdSet){
        Map<Id,List<ASI_MFM_RequestItem_UserAssignment__c>> existingAssignmentMap = new Map<Id,List<ASI_MFM_RequestItem_UserAssignment__c>>();
        for(ASI_MFM_RequestItem_UserAssignment__c ua : [SELECT Id, ASI_MFM_User__c, ASI_MFM_User__r.Name, ASI_MFM_User__r.Username, ASI_MFM_User__r.ADDomainUser__c
                                                        , ASI_MFM_Request_Item__c, ASI_MFM_Qty__c, ASI_MFM_IBD_ID__c 
                                                        FROM ASI_MFM_RequestItem_UserAssignment__c
                                                        WHERE RecordTypeId = :USER_ASSI_ID AND ASI_MFM_Request_Item__c IN :reqItemIdSet])
        {
            if(!existingAssignmentMap.containsKey(ua.ASI_MFM_IBD_ID__c)){existingAssignmentMap.put(ua.ASI_MFM_IBD_ID__c,new List<ASI_MFM_RequestItem_UserAssignment__c>());}
            existingAssignmentMap.get(ua.ASI_MFM_IBD_ID__c).add(ua);
        }
        return existingAssignmentMap;
    }
    
    Public Static Map<Id,List<ASI_MFM_RequestItem_UserAssignment__c>> getUserAssiRecByReqId(Id reqId){
        Map<Id,List<ASI_MFM_RequestItem_UserAssignment__c>> existingAssignmentMap = new Map<Id,List<ASI_MFM_RequestItem_UserAssignment__c>>();
        for(ASI_MFM_RequestItem_UserAssignment__c ua : [SELECT Id, ASI_MFM_User__c, ASI_MFM_User__r.Name, ASI_MFM_User__r.Username, ASI_MFM_User__r.ADDomainUser__c
                                                        , ASI_MFM_Request_Item__c, ASI_MFM_Qty__c, ASI_MFM_IBD_ID__c 
                                                        FROM ASI_MFM_RequestItem_UserAssignment__c
                                                        WHERE RecordTypeId = :USER_ASSI_ID AND ASI_MFM_Request_Item__r.ASI_FOC_Request_Order__c = :reqId])
        {
            if(!existingAssignmentMap.containsKey(ua.ASI_MFM_IBD_ID__c)){existingAssignmentMap.put(ua.ASI_MFM_IBD_ID__c,new List<ASI_MFM_RequestItem_UserAssignment__c>());}
            existingAssignmentMap.get(ua.ASI_MFM_IBD_ID__c).add(ua);
        }
        return existingAssignmentMap;
    }
    
    @RemoteAction
    Public Static Map<String,String> upsertAssignment(Id cartId, Map<String, List<Map<String,Object>>> input) {
        try{
            List<ASI_MFM_RequestItem_UserAssignment__c> updateUaList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
            List<ASI_MFM_RequestItem_UserAssignment__c> insertUaList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
            List<ASI_MFM_RequestItem_UserAssignment__c> deleteUaList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
            
            Map<Id, ASI_MFM_RequestItem_UserAssignment__c> uaMap = new Map<Id, ASI_MFM_RequestItem_UserAssignment__c>([SELECT Id, ASI_MFM_User__c, ASI_MFM_User__r.Name, ASI_MFM_User__r.Username, ASI_MFM_User__r.ADDomainUser__c
                                                                                                                       , ASI_MFM_Request_Item__c, ASI_MFM_Qty__c, ASI_MFM_IBD_ID__c 
                                                                                                                       FROM ASI_MFM_RequestItem_UserAssignment__c
                                                                                                                       WHERE RecordTypeId = :USER_ASSI_ID 
                                                                                                                       AND ASI_MFM_Request_Item__r.ASI_FOC_Request_Order__c = :cartId
                                                                                                                       AND ASI_MFM_Request_Item__r.ASI_MFM_IBD__c IN :input.keySet()
                                                                                                                      ]);
            
            for(String key :input.keySet()) {
                List<Map<String,Object>> inUaList = input.get(key);
                if(inUaList!=null) {
                    for(Map<String,Object> inUaMap :inUaList) {
                        String uaId = String.valueOf(inUaMap.get('uaId'));
                        String reqItemId  = String.valueOf(inUaMap.get('reqItemId'));
                        String receiverId = String.valueOf(inUaMap.get('recId'));
                        Integer qty = Integer.valueOf(inUaMap.get('qty'));
                        if(reqItemId==null || reqItemId=='') {
                            // skip update and insert
                        } else {
                            if(uaId!=null && uaId!='') {
                                // update
                                ASI_MFM_RequestItem_UserAssignment__c uaObj = uaMap.remove(uaId);
                                uaObj.ASI_MFM_User__c = receiverId;
                                uaObj.ASI_MFM_Qty__c = qty;
                                updateUaList.add(uaObj);
                            } else {
                                // insert
                                insertUaList.add(new ASI_MFM_RequestItem_UserAssignment__c(
                                    ASI_MFM_User__c = receiverId,
                                    ASI_MFM_Qty__c = qty,
                                    ASI_MFM_Request_Item__c = reqItemId
                                ));
                            }
                        }
                    }
                }
            }
            for(Id uaId :uaMap.keySet()){
                deleteUaList.add(uaMap.get(uaId));
            }
            if(updateUaList.size() > 0) update updateUaList;
            if(insertUaList.size() > 0) insert insertUaList;
            if(deleteUaList.size() > 0) delete deleteUaList;
        } catch (Exception e) {
            return new Map<String,String>{'error'=>e.getMessage()};
        }

        
        return new Map<String,String>{'success'=>'success'};
    }
    
    Public Static void createAssignmentRec(Map<String,ASI_MFM_CN_POSMCatalog_CTRL.LotObject> lotMap, List<ASI_FOC_Request_Item__c> updatedItemList) {
        // lotId means IBD_Id
        try {// try catch for partal deployment 20191217
            

        Set<Id> reqItemIdSet = new Set<Id>();
        for(ASI_FOC_Request_Item__c reqItem :updatedItemList) {reqItemIdSet.add(reqItem.Id);}
        Map<Id,List<ASI_MFM_RequestItem_UserAssignment__c>> existingAssignmentMap = searchUserAssiRec(new List<Id>(reqItemIdSet));
        
        List<ASI_MFM_RequestItem_UserAssignment__c> insertList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
        List<ASI_MFM_RequestItem_UserAssignment__c> updateList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
        List<ASI_MFM_RequestItem_UserAssignment__c> deleteList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
        
        for(String lotid : lotMap.keySet()){
            ASI_MFM_CN_POSMCatalog_CTRL.LotObject lotObj = lotMap.get(lotid);
            
            Id reqItemId = null;
            List<ASI_MFM_RequestItem_UserAssignment__c> existingUaList = existingAssignmentMap.get(lotid);
            for(ASI_FOC_Request_Item__c reqItem :updatedItemList) {
                if(reqItem.ASI_MFM_IBD__c == lotid) {
                    reqItemId = reqItem.Id;
                    break;
                }
            }

            if(reqItemId!=null && lotObj.userAssignment!=null) {
                for(Map<String,Object> userAssiDetail :lotObj.userAssignment) {
                    ASI_MFM_RequestItem_UserAssignment__c ua = new ASI_MFM_RequestItem_UserAssignment__c(
                        RecordTypeId = USER_ASSI_ID,
                        ASI_MFM_Request_Item__c = reqItemId,
                        ASI_MFM_Qty__c = Integer.valueOf(userAssiDetail.get('qty')),
                        ASI_MFM_User__c = String.valueOf(userAssiDetail.get('recId'))
                    );

                    if(existingUaList!=null && existingUaList.size()>0) {
                        ua.Id = existingUaList[0].Id;
                        updateList.add(ua);
                        existingUaList.remove(0);
                    } else {insertList.add(ua);}
                }
            }

            if(existingUaList!=null && existingUaList.size()>0) {
                //delet remain existing record
                if(lotObj.cloneFromId==null || lotObj.cloneFromId=='') {
                    deleteList.addAll(existingUaList);
                }
            }
            if(updateList.size()>0) update updateList;
            if(insertList.size()>0) insert insertList;
            if(deleteList.size()>0) delete deleteList;
        }
            
        } catch (Exception e) {}
    }
    
    

}