/*
 * *******************************************************************************
 * Name: ASI_CRM_CN_ItemGp_Allocation_TriggerCls
 * Description: 
 * Version History
 * Date 			Developer 			Comments
 * --------------- -------------------- --------------------------------------------------------------------------------
 * ???				???			 		Created
 * 2019-06-28		Vincent Lam			[VL 1.0] Hide sub-region checking as it's not deployed yet
 * 2019-06-28		Vincent Lam			[VL 2.0] Rollup Customer + Channel quantity to Commercial Team + Region + Item Group level
 */
Public without Sharing class ASI_CRM_CN_ItemGp_Allocation_TriggerCls {

    Public Static void beforeInsertFunction(List<ASI_CRM_Item_Group_Allocation__c> triggerNew){
        
        calculateRemainingQty(triggerNew, Null);
    }
    
    Public Static void beforeUpdateFunction(List<ASI_CRM_Item_Group_Allocation__c> triggerNew, Map<Id, ASI_CRM_Item_Group_Allocation__c> triggerOldMap){
        
        calculateRemainingQty(triggerNew, triggerOldMap);
    }
    
    Public Static void calculateRemainingQty(List<ASI_CRM_Item_Group_Allocation__c> triggerNew, Map<Id, ASI_CRM_Item_Group_Allocation__c> triggerOldMap){
        
		Set<Id> regionSet = new Set<Id>();
        Set<Id> allocatedItemGroup = new Set<Id>();
        Set<String> commercialTeamSet = new Set<String>();
        Map<String, ASI_CRM_Item_Group_Allocation__c> allocationMap = new Map<String, ASI_CRM_Item_Group_Allocation__c>();
        Date startDate;
        Date endDate;
        
        for(ASI_CRM_Item_Group_Allocation__c obj : triggerNew){
            
            if( (!obj.ASI_CRM_Inactive__c && triggerOldMap == Null || !(obj.ASI_CRM_Inactive__c && triggerOldMap.get(obj.id).ASI_CRM_Inactive__c ))){
                regionSet.add(obj.ASI_CRM_Region__c);
                allocatedItemGroup.add(obj.ASI_CRM_Item_Group__c);
                commercialTeamSet.add(obj.ASI_CRM_Commercial_Team__c);
                
                if(startDate == Null || startDate > obj.ASI_CRM_Effective_Date__c)
                    startDate = obj.ASI_CRM_Effective_Date__c;
                
                if(endDate == Null || endDate < obj.ASI_CRM_Effective_Date__c)
                    endDate = obj.ASI_CRM_Effective_Date__c;
                
				/* [VL 2.0] BEGIN */
				/*
                String Key = '' + 
								obj.ASI_CRM_Item_Group__c + 
								obj.ASI_CRM_Region__c + 
								obj.ASI_CRM_Commercial_Team__c + 
								String.valueOf(date.newInstance(obj.ASI_CRM_Effective_Date__c.year(), obj.ASI_CRM_Effective_Date__c.month(), 1));
				*/
                String Key = '' + 
								obj.ASI_CRM_Customer__c + '_' +
								obj.ASI_CRM_Channel__c + '_' +
								obj.ASI_CRM_Item_Group__c + '_' +
								obj.ASI_CRM_Region__c + '_' +
								obj.ASI_CRM_Commercial_Team__c + '_' +
								String.valueOf(date.newInstance(obj.ASI_CRM_Effective_Date__c.year(), obj.ASI_CRM_Effective_Date__c.month(), 1));
				/* [VL 2.0] BEGIN */
                
                obj.ASI_CRM_MTD_Order_Quantity__c = 0;
                
                allocationMap.put(Key, obj);
            }
        }
        
        endDate = endDate == Null ? date.today() : endDate;
        
        startDate = date.newInstance(endDate.year(), endDate.month(), 1);
        endDate = date.newInstance(endDate.year(), endDate.month(), date.daysInMonth(endDate.year(), endDate.month()));
        
        for(ASI_KOR_Sales_Order_Transaction__c obj : [SELECT id
                                                      , ASI_CRM_CN_Product_Name__c
                                                      , ASI_CRM_CN_Product_Name__r.Name
                                                      , ASI_CRM_Order_Qty_Bottle__c
                                                      , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                      , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                      , ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c
													  /* [VL 2.0] BEGIN */
													  , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__c
                                                      , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c
                                                      /* [VL 2.0] END */
                                                      , ASI_KOR_Sales_Order_Request__c
                                                      FROM ASI_KOR_Sales_Order_Transaction__c
                                                      WHERE ASI_CRM_CN_Product_Name__c IN : allocatedItemGroup
                                                      AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c IN : regionSet
                                                      AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c IN : commercialTeamSet
                                                      AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c >= : startDate
                                                      AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c <= : endDate
                                                      AND (NOT ASI_KOR_Sales_Order_Request__r.ASI_KOR_Order_Status__c Like 'Open')
                                                      AND RecordType.developerName Like '%_CN_%']
		){
                                                          
			/* [VL 2.0] BEGIN */
			/*
			String key = '' + 
							obj.ASI_CRM_CN_Product_Name__c + 
							obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + 
							obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + 
							String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));
			*/
			string customerId = obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__c;
			string channelId = obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c;
			String Key = '' + 
							'null_' +
							'null_' +
							obj.ASI_CRM_CN_Product_Name__c + '_' +
							obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + '_' +
							obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_' +
							String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));
			String Key1 = '' + 
							'null_' +
							channelId + '_' +
							obj.ASI_CRM_CN_Product_Name__c + '_' +
							obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + '_' +
							obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_' +
							String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));
			String Key2 = '' + 
							customerId + '_' +
							channelId + '_' +
							obj.ASI_CRM_CN_Product_Name__c + '_' +
							obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + '_' +
							obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_' +
							String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));
			/* [VL 2.0] END */
			
			  if(allocationMap.containsKey(key)){
				  
				  ASI_CRM_Item_Group_Allocation__c tmp = allocationMap.get(key);
				  tmp.ASI_CRM_MTD_Order_Quantity__c = tmp.ASI_CRM_MTD_Order_Quantity__c + obj.ASI_CRM_Order_Qty_Bottle__c;
				  allocationMap.put(key, tmp);
			  }
			/* [VL 2.0] BEGIN */
			  if(channelId != null && allocationMap.containsKey(key1)){
				  
				  ASI_CRM_Item_Group_Allocation__c tmp = allocationMap.get(key1);
				  tmp.ASI_CRM_MTD_Order_Quantity__c = tmp.ASI_CRM_MTD_Order_Quantity__c + obj.ASI_CRM_Order_Qty_Bottle__c;
				  allocationMap.put(key1, tmp);
			  }
			  if(channelId != null && customerId != null && allocationMap.containsKey(key2)){
				  
				  ASI_CRM_Item_Group_Allocation__c tmp = allocationMap.get(key2);
				  tmp.ASI_CRM_MTD_Order_Quantity__c = tmp.ASI_CRM_MTD_Order_Quantity__c + obj.ASI_CRM_Order_Qty_Bottle__c;
				  allocationMap.put(key2, tmp);
			  }
			/* [VL 2.0] END */
		  }
    }
		
		/* [VL 1.0] BEGIN */
		/*
        Set<Id> regionSet = new Set<Id>();
        Set<Id> allocatedItemGroup = new Set<Id>();
        Set<String> commercialTeamSet = new Set<String>();
        Map<String, Double> totalQty = new Map<String, Double>();
        Map<String, Double> totalSubRegionQty = new Map<String, Double>();
        Map<String, ASI_CRM_Item_Group_Allocation__c> allocationMap = new Map<String, ASI_CRM_Item_Group_Allocation__c>();
        Map<Id, ASI_CRM_Region__c> regionMap = new Map<Id, ASI_CRM_Region__c>([SELECT id
                                                                                , ASI_CRM_Parent_Region__c
                                                                                FROM ASI_CRM_Region__c
                                                                                WHERE recordTypeId = : Global_RecordTypeCache.getRtID('ASI_CRM_Region__cASI_CRM_CN_Region')
                                                                               ]);
        Date startDate;
        Date endDate;

        for(ASI_CRM_Item_Group_Allocation__c obj : triggerNew){
            
            if( (!obj.ASI_CRM_Inactive__c && triggerOldMap == Null )|| (triggerOldMap != Null && !(obj.ASI_CRM_Inactive__c && triggerOldMap.get(obj.id).ASI_CRM_Inactive__c ))){
                
                Double qty = obj.ASI_CRM_Allocation_Quantity_Bottle__c != Null ? obj.ASI_CRM_Allocation_Quantity_Bottle__c : 0;
                Double qty2 = qty;
                
                regionSet.add(obj.ASI_CRM_Region__c);
                allocatedItemGroup.add(obj.ASI_CRM_Item_Group__c);
                commercialTeamSet.add(obj.ASI_CRM_Commercial_Team__c);
                
                if(startDate == Null || startDate > obj.ASI_CRM_Effective_Date__c)
                    startDate = obj.ASI_CRM_Effective_Date__c;
                
                if(endDate == Null || endDate < obj.ASI_CRM_Effective_Date__c)
                    endDate = obj.ASI_CRM_Effective_Date__c;
                
                String Key = '' + obj.ASI_CRM_Item_Group__c + obj.ASI_CRM_Region__c + obj.ASI_CRM_Commercial_Team__c + String.valueOf(date.newInstance(obj.ASI_CRM_Effective_Date__c.year(), obj.ASI_CRM_Effective_Date__c.month(), 1));
                
                obj.ASI_CRM_MTD_Order_Quantity__c = 0;
                
                allocationMap.put(Key, obj);
                
                //20180308 Introv
                if(totalQty.containsKey('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c))
                    qty += totalQty.get('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c);
                
                if(regionMap.containsKey(obj.ASI_CRM_Region__c) && regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c != Null){
                    if(totalSubRegionQty.containsKey('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c))
                        qty2 += totalSubRegionQty.get('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c);
                    
                    totalSubRegionQty.put('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c, qty);
                }
                totalQty.put('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c, qty);
            }
        }
        
        //20180308 Introv
        for(ASI_CRM_Item_Group_Allocation__c obj : [SELECT Id
                                                    , ASI_CRM_Allocation_Quantity__c
                                                    , ASI_CRM_Allocation_Quantity_Bottle__c 
                                                    , ASI_CRM_Commercial_Team__c 
                                                    , ASI_CRM_Inactive__c 
                                                    , ASI_CRM_Effective_Date__c 
                                                    , ASI_CRM_Item_Group__c 
                                                    , ASI_CRM_MTD_Order_Quantity__c 
                                                    , ASI_CRM_MTD_Order_Quantity_CA__c 
                                                    , ASI_CRM_Region__c
                                                    , ASI_CRM_Region__r.ASI_CRM_Parent_Region__c
                                                    , ASI_CRM_Remaining_Qty_BT__c 
                                                    , ASI_CRM_Remaining_Qty_CA__c 
                                                    , ASI_CRM_UOM__c 
                                                    FROM ASI_CRM_Item_Group_Allocation__c
                                                    WHERE Id NOT IN : triggerNew
                                                    AND ASI_CRM_Inactive__c = False
                                                    AND recordTypeId = : Global_RecordTypeCache.getRtID('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation')
                                                   ]){
                                                       Double qty = obj.ASI_CRM_Allocation_Quantity_Bottle__c != Null ? obj.ASI_CRM_Allocation_Quantity_Bottle__c : 0;
                                                       Double qty2 = qty;
                                                       
                                                       if(totalQty.containsKey('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c))
                                                           qty += totalQty.get('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c);
                                                       
                                                       if(regionMap.containsKey(obj.ASI_CRM_Region__c) && regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c != Null){
                                                           if(totalSubRegionQty.containsKey('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c))
                                                               qty2 += totalSubRegionQty.get('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c);
                                                           
                                                           totalSubRegionQty.put('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c, qty2);
                                                       }
                                                       
                                                       totalQty.put('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c, qty);
                                                   }
        
        for(ASI_CRM_Item_Group_Allocation__c obj : triggerNew){
            if((regionMap.containsKey(obj.ASI_CRM_Region__c) && regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c != Null
               && totalSubRegionQty.containsKey('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c)
               && totalQty.containsKey('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c))
               || (totalQty.containsKey('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c) && totalSubRegionQty.containsKey('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c))
              ){
                  if((totalSubRegionQty.get('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c) > totalQty.get('' + regionMap.get(obj.ASI_CRM_Region__c).ASI_CRM_Parent_Region__c + obj.ASI_CRM_Item_Group__c))
                     || (totalSubRegionQty.get('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c) > totalQty.get('' + obj.ASI_CRM_Region__c + obj.ASI_CRM_Item_Group__c))){
                         
                         obj.addError('Total Sub-Region allocated Qty cannot be greater than Parent Region allocated Qty');
                     }
              }
        }
        //20180308 End
        
        endDate = endDate == Null ? date.today() : endDate;
        
        startDate = date.newInstance(endDate.year(), endDate.month(), 1);
        endDate = date.newInstance(endDate.year(), endDate.month(), date.daysInMonth(endDate.year(), endDate.month()));
        
        for(ASI_KOR_Sales_Order_Transaction__c obj : [SELECT id
                                                      , ASI_CRM_CN_Product_Name__c
                                                      , ASI_CRM_CN_Product_Name__r.Name
                                                      , ASI_CRM_Order_Qty_Bottle__c
                                                      , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                      , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__r.ASI_CRM_Parent_Region__c
                                                      , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c
                                                      , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                      , ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c
                                                      , ASI_KOR_Sales_Order_Request__c
                                                      FROM ASI_KOR_Sales_Order_Transaction__c
                                                      WHERE ASI_CRM_CN_Product_Name__c IN : allocatedItemGroup
                                                      AND (ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c IN : regionSet
                                                           OR (ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c IN : regionSet
                                                               AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c LIKE 'Premium')
                                                               )//20180320 Introv
                                                      AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c IN : commercialTeamSet
                                                      AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c >= : startDate
                                                      AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c <= : endDate
                                                      AND (NOT ASI_KOR_Sales_Order_Request__r.ASI_KOR_Order_Status__c Like 'Open')
                                                      AND RecordType.developerName Like '%_CN_%']){
                                                          
                                                          //20180320 Introv added Premium sub region logic
                                                          Id regionId = obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
                                                          Boolean isSubRegion = False;
                                                          
                                                          if(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c.containsIgnoreCase('Premium') && obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c != Null){
                                                              
                                                              regionId = obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c;
                                                              isSubRegion = True;
                                                          }
                                                          
                                                          String key = '' + obj.ASI_CRM_CN_Product_Name__c + regionId + obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));
                                                          String key2 = '' + obj.ASI_CRM_CN_Product_Name__c + obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));
                                                          
                                                          if(allocationMap.containsKey(key)){
                                                              
                                                              ASI_CRM_Item_Group_Allocation__c tmp = allocationMap.get(key);
                                                              tmp.ASI_CRM_MTD_Order_Quantity__c = tmp.ASI_CRM_MTD_Order_Quantity__c + obj.ASI_CRM_Order_Qty_Bottle__c;
                                                              allocationMap.put(key, tmp);
                                                          }
                                                          
                                                          //20180321 Introv
                                                          if(allocationMap.containsKey(key2) && isSubRegion){
                                                              
                                                              ASI_CRM_Item_Group_Allocation__c tmp = allocationMap.get(key2);
                                                              tmp.ASI_CRM_MTD_Order_Quantity__c = tmp.ASI_CRM_MTD_Order_Quantity__c + obj.ASI_CRM_Order_Qty_Bottle__c;
                                                              allocationMap.put(key2, tmp);
                                                          }
    }
	*/
	/* [VL 1.0] END */
}