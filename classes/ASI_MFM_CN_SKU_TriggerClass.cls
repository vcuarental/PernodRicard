public class ASI_MFM_CN_SKU_TriggerClass {
    
    Private Static Final String WAREHOUSE_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
    Private Static Final String INVENTORY_BALANCE_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Inventory_Balance__cASI_MFM_CN_Inventory_Balance'); 
    Private Static Final String POSM_SKU_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU');
    
    Private Static List<ASI_FOC_Warehouse__c> warehouseList = new List<ASI_FOC_Warehouse__c>([SELECT id
                                                                                              , Name
                                                                                              FROM ASI_FOC_Warehouse__c 
                                                                                              WHERE RecordTypeId = : WAREHOUSE_RECORDTYPE_ID
                                                                                              AND ASI_MFM_Inventory_Required__c = TRUE
                                                                                             ]);
    
    Public Static void beforeInsertMedthod(List<ASI_MFM_SKU_Code__c> triggerNew){
        
        //Andy@Introv 20190124: quantity field is no longer used
        reassignAvailableQuantity4POSM(triggerNew);
        
        //20191029:AM@introv - assign packaging description field same as packing field
        reassignPackingDesription(triggerNew);
        
        List<ASI_MFM_SKU_Code__c> posmSKUList = new List<ASI_MFM_SKU_Code__c>();
        
        if(!ASI_CRM_CN_Function.IsBypassTrigger('ASI_MFM_CN_SKU_TriggerClass')){
            
            Boolean hasUpdatedRunningNumber = False;
            
            Set<Id> itemGroupIdSet = new Set<Id>();
            
            for(ASI_MFM_SKU_Code__c obj : triggerNew){
                
                if(obj.ASI_MFM_Item_Group__c != Null && String.isBlank(obj.ASI_MFM_SKU_Code__c))
                    itemGroupIdSet.add(obj.ASI_MFM_Item_Group__c);
                
                if(obj.recordTypeId == POSM_SKU_RECORDTYPE_ID){
                    posmSKUList.add(obj);
                }
            }
            
            if(posmSKUList.size() > 0){
                Map<Id, ASI_MFM_Item_Group__c> itemGroupMap = new Map<Id, ASI_MFM_Item_Group__c>([SELECT Id, ASI_CRM_CN_Chinese_Name__c, ASI_CRM_CN_Eng_Name__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_Running_Number__c FROM ASI_MFM_Item_Group__c WHERE Id IN : itemGroupIdSet]);
                
                for(ASI_MFM_SKU_Code__c obj : posmSKUList){
                    
                    if(String.isBlank(obj.ASI_MFM_SKU_Code__c) && itemGroupMap.containsKey(obj.ASI_MFM_Item_Group__c)){
                        
                        Integer nextNum = resetRunningNumber(2, Integer.valueOf(itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_MFM_Running_Number__c), 1);
                        String skucode =  itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_MFM_Item_Group_Code__c + runningNumber(2, nextNum);
                        obj.ASI_MFM_SKU_Code__c = skucode;
                        obj.ASI_MFM_SKU_External_ID__c = 'CN_POSM_'+skucode; //20181212 @introv update for missing field JDE use ext id field
                        
                        itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_MFM_Running_Number__c = nextNum;
                        hasUpdatedRunningNumber = True;
                    }
                    
                    if(itemGroupMap.containsKey(obj.ASI_MFM_Item_Group__c))
                        obj.Name = itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_CRM_CN_Chinese_Name__c + '/' + itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_CRM_CN_Eng_Name__c + (String.isNotBlank(obj.ASI_MFM_SKU_Code__c) ? ' - ' + obj.ASI_MFM_SKU_Code__c : '');
                }
                
                if(hasUpdatedRunningNumber){
                    try{
                        Update itemGroupMap.values();
                    }catch(dmlException dmle){
                        
                    }
                }
            }
        }
    }
    
    Public Static void beforeUpdateMethod(List<ASI_MFM_SKU_Code__c> triggerNew, Map<Id, ASI_MFM_SKU_Code__c> triggerOldMap){
        
        //Andy@Introv 20190124: quantity field is no longer used
        reassignAvailableQuantity4POSM(triggerNew);
        
        //20191029:AM@introv - assign packaging description field same as packing field
        reassignPackingDesription(triggerNew);
        
        List<ASI_MFM_SKU_Code__c> posmSKUList = new List<ASI_MFM_SKU_Code__c>();
        List<ASI_MFM_Inventory_Balance__c> insertInventoryBalance = new List<ASI_MFM_Inventory_Balance__c>();
        Set<String> existingInventoryBalance = new Set<String>();
        
        if(!ASI_CRM_CN_Function.IsBypassTrigger('ASI_MFM_CN_SKU_TriggerClass')){
            
            Boolean hasUpdatedRunningNumber = False;
            Set<Id> itemGroupIdSet = new Set<Id>();
            
            for(ASI_MFM_SKU_Code__c obj : triggerNew){
                
                if(obj.ASI_MFM_Item_Group__c != Null && String.isBlank(obj.ASI_MFM_SKU_Code__c))
                    itemGroupIdSet.add(obj.ASI_MFM_Item_Group__c);
                
                if(obj.recordTypeId == POSM_SKU_RECORDTYPE_ID){
                    posmSKUList.add(obj);
                }
            }
            
            if(posmSKUList.size() > 0){
                
                for(ASI_MFM_Inventory_Balance__c obj : [SELECT ASI_MFM_SKU__c, ASI_MFM_Warehouse__c FROM ASI_MFM_Inventory_Balance__c WHERE ASI_MFM_SKU__c IN : posmSKUList]){
                    
                    existingInventoryBalance.add('' + obj.ASI_MFM_SKU__c + obj.ASI_MFM_Warehouse__c);
                }
                
                Map<Id, ASI_MFM_Item_Group__c> itemGroupMap = new Map<Id, ASI_MFM_Item_Group__c>([SELECT Id, ASI_CRM_CN_Chinese_Name__c, ASI_CRM_CN_Eng_Name__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_Running_Number__c FROM ASI_MFM_Item_Group__c WHERE Id IN : itemGroupIdSet]);
                
                for(ASI_MFM_SKU_Code__c obj : posmSKUList){
                    
                    for(ASI_FOC_Warehouse__c wh : warehouseList){
                        
                        if(!existingInventoryBalance.contains('' + obj.id + wh.id)){
                            insertInventoryBalance.add(new ASI_MFM_Inventory_Balance__c(recordTypeId = INVENTORY_BALANCE_RECORDTYPE_ID
                                                                                        , ASI_MFM_SKU__c = obj.id
                                                                                        , ASI_MFM_Warehouse__c = wh.id
                                                                                       ));
                        }
                    }
                    
                    if(String.isBlank(obj.ASI_MFM_SKU_Code__c) && itemGroupMap.containsKey(obj.ASI_MFM_Item_Group__c)){
                        
                        Integer nextNum = resetRunningNumber(2, Integer.valueOf(itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_MFM_Running_Number__c), 1);
                        
                        obj.ASI_MFM_SKU_Code__c = itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_MFM_Item_Group_Code__c + runningNumber(2, nextNum);
                        itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_MFM_Running_Number__c = nextNum;
                        hasUpdatedRunningNumber = True;
                    }
                    
                    if(itemGroupMap.containsKey(obj.ASI_MFM_Item_Group__c))
                        obj.Name = itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_CRM_CN_Chinese_Name__c + '/' + itemGroupMap.get(obj.ASI_MFM_Item_Group__c).ASI_CRM_CN_Eng_Name__c + (String.isNotBlank(obj.ASI_MFM_SKU_Code__c) ? ' - ' + obj.ASI_MFM_SKU_Code__c : '');
                }
                
                try{
                    if(hasUpdatedRunningNumber)
                        Update itemGroupMap.values();
                    
                    if(insertInventoryBalance.size() > 0)
                        Insert insertInventoryBalance;
                    
                }catch(dmlException dmle){
                    
                }
            }
        }
    }
    
    Public Static Void afterInsertMethodPOSM(List<ASI_MFM_SKU_Code__c> triggerNew){
        List<ASI_MFM_Inventory_Balance__c> insertInventoryBalance = new List<ASI_MFM_Inventory_Balance__c>();  
        
        for(ASI_MFM_SKU_Code__c obj : triggerNew){
            if(obj.recordTypeId == POSM_SKU_RECORDTYPE_ID){
                for(ASI_FOC_Warehouse__c wh : warehouseList){
                    insertInventoryBalance.add(new ASI_MFM_Inventory_Balance__c(recordTypeId = INVENTORY_BALANCE_RECORDTYPE_ID
                                                                                , ASI_MFM_SKU__c = obj.id
                                                                                , ASI_MFM_Warehouse__c = wh.id
                                                                               ));
                }
            }
        }
        
        try{
            
            if(insertInventoryBalance.size() > 0){
                
                insert insertInventoryBalance;
            }
            
        }catch(dmlException dmle){
            
        }
    }
    
    Public Static Void afterInsertMethod(List<ASI_MFM_SKU_Code__c> triggerNew){
        
        if(!ASI_CRM_CN_Function.IsBypassTrigger('ASI_MFM_CN_SKU_TriggerClass')){
            Set<Id> itemGroupId = new Set<Id>();
            
            List<ASI_CRM_SKU_Photo__c> listOfSKUPhoto = new List<ASI_CRM_SKU_Photo__c>();
            
            Map<Id, Map<String, ASI_CRM_Product_Warehouse_Photo__c>> mapProductPhoto = new Map<Id, Map<String, ASI_CRM_Product_Warehouse_Photo__c>>();
            
            for(ASI_MFM_SKU_Code__c obj : triggerNew){
                
                if(obj.ASI_MFM_Item_Group__c != NULL){
                    itemGroupId.add(obj.ASI_MFM_Item_Group__c);
                }
            }
            
            for(ASI_CRM_Product_Warehouse_Photo__c obj : [SELECT id
                                                          , ASI_CRM_Photo_Category__c
                                                          , ASI_CRM_Item_Group__c
                                                          , ASI_CRM_Photo_Version__c
                                                          FROM ASI_CRM_Product_Warehouse_Photo__c
                                                          WHERE ASI_CRM_Item_Group__c IN : itemGroupId
                                                          AND ASI_CRM_Photo_Version__c != NULL
                                                          AND ASI_CRM_Photo_Category__c != NULL
                                                          AND ASI_CRM_Photo_Category__c != ''
                                                          AND RecordType.DeveloperName = 'ASI_CRM_CN_Product_Warehouse_Photo'
                                                          ORDER BY ASI_CRM_Photo_Category__c ASC
                                                          , ASI_CRM_Photo_Version__c DESC
                                                         ]){
                                                             
                                                             Map<String, ASI_CRM_Product_Warehouse_Photo__c> mapProductPhoto2 = new Map<String, ASI_CRM_Product_Warehouse_Photo__c>();
                                                             
                                                             if(mapProductPhoto.containsKey(obj.ASI_CRM_Item_Group__c)){
                                                                 mapProductPhoto2 = mapProductPhoto.get(obj.ASI_CRM_Item_Group__c);
                                                                 
                                                                 if(mapProductPhoto2.containsKey(obj.ASI_CRM_Photo_Category__c)){
                                                                     if(mapProductPhoto2.get(obj.ASI_CRM_Photo_Category__c).ASI_CRM_Photo_Version__c < obj.ASI_CRM_Photo_Version__c){
                                                                         mapProductPhoto2.put(obj.ASI_CRM_Photo_Category__c, obj);
                                                                     }else if(mapProductPhoto2.get(obj.ASI_CRM_Photo_Category__c).ASI_CRM_Photo_Version__c == obj.ASI_CRM_Photo_Version__c){
                                                                         mapProductPhoto2.put('' + obj.ASI_CRM_Photo_Category__c + obj.Id, obj);
                                                                     }
                                                                 }else{
                                                                     mapProductPhoto2.put(obj.ASI_CRM_Photo_Category__c, obj);
                                                                 }
                                                             }else{
                                                                 mapProductPhoto2.put(obj.ASI_CRM_Photo_Category__c, obj);
                                                             }
                                                             mapProductPhoto.put(obj.ASI_CRM_Item_Group__c, mapProductPhoto2);
                                                         }
            
            for(ASI_MFM_SKU_Code__c obj : triggerNew){
                
                if(obj.ASI_MFM_Item_Group__c != NULL && mapProductPhoto.containsKey(obj.ASI_MFM_Item_Group__c)){
                    for(ASI_CRM_Product_Warehouse_Photo__c photo : mapProductPhoto.get(obj.ASI_MFM_Item_Group__c).values()){
                        
                        ASI_CRM_SKU_Photo__c tmpSKUPhoto = new ASI_CRM_SKU_Photo__c(ASI_CRM_Attachment__c = photo.id, ASI_CRM_SKU__c = obj.id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SKU_Photo__cASI_CRM_CN_SKU_Photo'));
                        
                        listOfSKUPhoto.add(tmpSKUPhoto);
                    }
                }
            }
            
            try{
                insert listOfSKUPhoto;
                
            }catch(dmlException dmle){
                
            }
        }
    }
    
    //Andy@Introv 20190124: quantity field is no longer used after deploy inventory balance detail, but PRCN IT would like keep this field and set to null from 0
    Private Static Void reassignAvailableQuantity4POSM(List<ASI_MFM_SKU_Code__c> triggerNew) {
        for(ASI_MFM_SKU_Code__c obj : triggerNew){
            if(obj.ASI_HK_CRM_Available_Quantity__c != Null && obj.ASI_HK_CRM_Available_Quantity__c == 0)
                obj.ASI_HK_CRM_Available_Quantity__c = NULL;
        }
    }
    
    //20191029:AM@introv - assign packaging description field same as packing field
    private static void reassignPackingDesription(List<ASI_MFM_SKU_Code__c> triggerNew) {
        for(ASI_MFM_SKU_Code__c obj : triggerNew){
            if(obj.ASI_MFM_Minimum_Packing_Qty__c != NULL && obj.ASI_MFM_Minimum_Box_Qty__c  != NULL)
                obj.ASI_FOC_Packing_Description__c = '1 x ' + string.valueOf(obj.ASI_MFM_Minimum_Packing_Qty__c) + ' x ' + string.valueOf(obj.ASI_MFM_Minimum_Box_Qty__c) + ' PC';
        }
    }
    
    @TestVisible
    Private Static Integer resetRunningNumber(Integer maxLength, Integer currentNumber, Integer addingNum){
        
        Integer returnNum = (currentNumber != Null ? currentNumber : 0) + addingNum;
        
        if(('' + returnNum).length() > maxLength)
            returnNum = 0;
        
        return returnNum;
    }
    
    @TestVisible
    Private Static String runningNumber(Integer maxLength, Integer nextNumber){

        String returnStr = '';
        
        for(integer i = ('' + nextNumber).length(); i < maxLength; i++){
            
            returnStr += '0';
        }
        
        Return returnStr + nextNumber;
    }
}