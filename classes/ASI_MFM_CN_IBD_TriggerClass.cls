public without sharing class ASI_MFM_CN_IBD_TriggerClass {
    
    Public Static Void beforeInsertFunction(List<ASI_MFM_InventoryBalanceDetail__c> triggerNew){
        assignDefaultInfo(triggerNew);
        assignOwner(triggerNew);
    }
    
    Public Static Void beforeUpdateFunction(List<ASI_MFM_InventoryBalanceDetail__c> triggerNew){
        assignOwner(triggerNew);
    }
    
    Public Static Void afterUpdateFunction(List<ASI_MFM_InventoryBalanceDetail__c> triggerNew, Map<id, ASI_MFM_InventoryBalanceDetail__c> trigger_oldMap){
        releaseRequestItem(triggerNew, trigger_oldMap);
        //itemGroupFlagUpdate(triggerNew, trigger_oldMap);
    }
    
    /*
    @TestVisible
    Private Static Void itemGroupFlagUpdate(List<ASI_MFM_InventoryBalanceDetail__c> triggerNew, Map<id, ASI_MFM_InventoryBalanceDetail__c> trigger_oldMap){
        Set<Id> idSet = new Set<Id>();
        Set<Id> itemGroupIdSet = new Set<Id>();
        Map<Id,Decimal> availableItemMap = new Map<Id,Decimal>();
        List<ASI_MFM_Item_Group__c> updateItemGroupList = new List<ASI_MFM_Item_Group__c>();
        
        // only get updated JDE Available Quantity
        for(ASI_MFM_InventoryBalanceDetail__c obj : triggerNew){
            if (obj.ASI_MFM_JDEAvailableQuantity__c != trigger_oldMap.get(obj.Id).ASI_MFM_JDEAvailableQuantity__c) {
                idSet.add(obj.Id);
                itemGroupIdSet.add(obj.ASI_MFM_ItemGroup__c);
            }
        }
        
        if (itemGroupIdSet.size() > 0) {
            String rtid = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy');
            String soqlStr = 'SELECT SUM(ASI_MFM_JDEAvailableQuantity__c) available, ASI_MFM_ItemGroup__c itemgroup FROM ASI_MFM_InventoryBalanceDetail__c WHERE recordTypeId = :rtid AND ASI_MFM_ItemGroup__c IN :itemGroupIdSet GROUP BY ASI_MFM_ItemGroup__c';
            for(AggregateResult ar : database.query(soqlStr)){
                if(ar.get('itemgroup')!=null && ar.get('itemgroup')!='') {
                    availableItemMap.put((Id)ar.get('itemgroup'), (Decimal)ar.get('available'));
                }                    
            }
            system.debug(JSON.serialize(availableItemMap));
            
            if(availableItemMap.keySet().size()>0){
                rtid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
                updateItemGroupList = [SELECT id, ASI_CRM_CN_Hidden__c , ASI_MFM_Utilization_Status__c 
                                       FROM ASI_MFM_Item_Group__c 
                                       WHERE id IN :availableItemMap.keySet() 
                                       AND recordTypeId = :rtid];
                for(ASI_MFM_Item_Group__c itemGroup :updateItemGroupList) {
                    Decimal available = availableItemMap.get(itemGroup.id);
                    if(available==null) continue;
                    if(available>0) {
                        itemGroup.ASI_CRM_CN_Hidden__c = false;
                        itemGroup.ASI_MFM_Utilization_Status__c = 'Active';
                    } else {
                        itemGroup.ASI_CRM_CN_Hidden__c = true;
                        itemGroup.ASI_MFM_Utilization_Status__c = 'Inactive';
                    }
                }
                if(updateItemGroupList.size()>0) update updateItemGroupList;
            }

        }
    }
	*/
    
    @TestVisible
    Private Static Void releaseRequestItem(List<ASI_MFM_InventoryBalanceDetail__c> triggerNew, Map<id, ASI_MFM_InventoryBalanceDetail__c> trigger_oldMap){
        Set<Id> idSet = new Set<Id>();
        
        // only get updated JDE Available Quantity
        for(ASI_MFM_InventoryBalanceDetail__c obj : triggerNew){
            if (obj.ASI_MFM_JDEAvailableQuantity__c != trigger_oldMap.get(obj.Id).ASI_MFM_JDEAvailableQuantity__c) {
                idSet.add(obj.Id);
            }
        }
        
        // only get request item
        if (idSet.size() > 0) {
            //20191203:AM@introv - fix over-committed issue
            List<ASI_MFM_CN_JCT_FGL_IBD__c> updateJUNC = new List<ASI_MFM_CN_JCT_FGL_IBD__c>();
            
            List<ASI_FOC_Request_Item__c> updateRI = new List<ASI_FOC_Request_Item__c>();
            for(ASI_MFM_CN_JCT_FGL_IBD__c  obj : [SELECT id, ASI_MFM_Request_Item__c FROM ASI_MFM_CN_JCT_FGL_IBD__c
                                                    WHERE ASI_MFM_IBD__c IN :idSet
                                                        AND ASI_MFM_Request_Item__r.ASI_FOC_ETL_Complete__c != TRUE
                                                        AND ASI_MFM_FGL_Status__c NOT IN ('Rejected','Cancelled')
                                                        AND ASI_MFM_FreeGoodsRequestStatus__c IN ('Final','Completed')]){
            	updateRI.add(new ASI_FOC_Request_Item__c(Id = obj.ASI_MFM_Request_Item__c, ASI_FOC_ETL_Complete__c=TRUE));
				
				//20191203:AM@introv - fix over-committed issue
                updateJUNC.add(new ASI_MFM_CN_JCT_FGL_IBD__c(Id = obj.Id, ASI_MFM_Holdied_Quantity__c = FALSE));
            }
            
            //20191203:AM@introv - fix over-committed issue
            for(ASI_MFM_CN_JCT_FGL_IBD__c  obj : [SELECT id, ASI_MFM_Request_Item__c FROM ASI_MFM_CN_JCT_FGL_IBD__c
                                                    WHERE ASI_MFM_IBD__c IN :idSet
                                                        AND ASI_MFM_Request_Item__r.ASI_FOC_ETL_Complete__c = TRUE
                                                        AND ASI_MFM_Holdied_Quantity__c = TRUE]){
				updateJUNC.add(new ASI_MFM_CN_JCT_FGL_IBD__c(Id = obj.Id, ASI_MFM_Holdied_Quantity__c = FALSE));
			}
            
            if (updateRI.size() > 0)
                update updateRI;
            
            if (updateJUNC.size() > 0)
                update updateJUNC;
        }
    }

    @TestVisible
    Private Static Void assignOwner(List<ASI_MFM_InventoryBalanceDetail__c> triggerNew){
        // 1. get owner text
        // 2. assign owner lookup
       	
        //modify by BLS 2020-09-23 USER.ADDomainUser__c will be updated remove Domain
        // string sPrefix = getADDomainPrefix();
        // if (sPrefix == '') return;
        
        Set<string> userSet = new Set<string>();
        Map<string, Id> userMap = new Map<string, Id>();
        
        for(ASI_MFM_InventoryBalanceDetail__c obj : triggerNew){
            if (obj.ASI_MFM_Action__c != NULL)
                // userSet.add(sPrefix + obj.ASI_MFM_Action__c);
                userSet.add(obj.ASI_MFM_Action__c);
        }
        
        if(userSet.size() > 0)
            userMap = getUserMapping(userSet);
        
        for(ASI_MFM_InventoryBalanceDetail__c obj : triggerNew){
            if (obj.ASI_MFM_Action__c != NULL) {
                //string sOwnerText = sPrefix + obj.ASI_MFM_Action__c;
                string sOwnerText = obj.ASI_MFM_Action__c;
                sOwnerText = sOwnerText.toLowerCase();
                if (userMap.containsKey(sOwnerText))
                {
                    obj.ASI_MFM_SFDCOwner__c = userMap.get(sOwnerText);
                }
            }
        }
    }
    
    // @TestVisible
    // Private Static string getADDomainPrefix() {
    //     string sPrefix = '';
    //     ASI_MFM_CN_Setting__mdt setting = [SELECT id, DeveloperName, ASI_MFM_CN_TextValue__c
    //                                        FROM ASI_MFM_CN_Setting__mdt
    //                                        WHERE DeveloperName LIKE 'ASI_MFM_CN_POSM_ADDomainUser_Prefix'
    //                                        LIMIT 1];
        
    //     if (setting != NULL)
    //         sPrefix = setting.ASI_MFM_CN_TextValue__c;
        
    //     return sPrefix;
    // }
    
    @TestVisible
    Private Static Void assignDefaultInfo(List<ASI_MFM_InventoryBalanceDetail__c> triggerNew){
        
    	// assign default item group + sku
        Set<Id> ibSet = new Set<Id>();
        Map<Id, ASI_MFM_Inventory_Balance__c> ibMap = new Map<Id, ASI_MFM_Inventory_Balance__c>();
        
    	for(ASI_MFM_InventoryBalanceDetail__c obj : triggerNew){
            if (obj.ASI_MFM_InventoryBalance__c != NULL)
                ibSet.add(obj.ASI_MFM_InventoryBalance__c);
        }
        
        if(ibSet.size() > 0)
            ibMap = getIBMapping(ibSet);
        
        for(ASI_MFM_InventoryBalanceDetail__c obj : triggerNew){
            if (obj.ASI_MFM_InventoryBalance__c != NULL)
            {
                if (ibMap.containsKey(obj.ASI_MFM_InventoryBalance__c))
                {
                    ASI_MFM_Inventory_Balance__c objIB = ibMap.get(obj.ASI_MFM_InventoryBalance__c);
                    if (objIB.ASI_MFM_SKU__c != NULL)
                    	obj.ASI_MFM_SKU__c = objIB.ASI_MFM_SKU__c;
                    if (objIB.ASI_MFM_SKU__c != NULL)
                    	obj.ASI_MFM_ItemGroup__c = objIB.ASI_MFM_SKU__r.ASI_MFM_Item_Group__c;
                }
            }
        }   
        
    }
    
    @TestVisible
    Private Static Map<string, Id> getUserMapping(Set<string> userSet){
        Map<string, Id> userMap = new Map<string, Id>();
        List<User> userList = new List<User>();
        
        if(userSet.size() > 0)
        {
            userList = [SELECT id, ADDomainUser__c FROM User WHERE ADDomainUser__c IN :userSet];
            for (User u : userList) {
                string sOwnerText = u.ADDomainUser__c;
                sOwnerText = sOwnerText.toLowerCase();
                if (!userMap.containsKey(sOwnerText)) {
                    userMap.put(sOwnerText, u.Id);
                }
            }
        }
        
        return userMap;
    }
    
    @TestVisible
    Private Static Map<Id, ASI_MFM_Inventory_Balance__c> getIBMapping(Set<Id> ibSet){
        Map<Id, ASI_MFM_Inventory_Balance__c> ibMap = new Map<Id, ASI_MFM_Inventory_Balance__c>();
        
        if(ibSet.size() > 0)
        {
            ibMap = new Map<Id, ASI_MFM_Inventory_Balance__c>([SELECT id, ASI_MFM_SKU__c,
                                                               	ASI_MFM_SKU__r.ASI_MFM_Item_Group__c 
                                                               FROM ASI_MFM_Inventory_Balance__c WHERE id IN :ibSet]);
        }
        
        return ibMap;
    }
    
}