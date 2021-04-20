public without sharing class ASI_FOC_Request_Item_TriggerClass {
    //20190408 Andy @Introv - #97-add public group for item approvers
	Private Static Final List<Group> POSM_ITEM_APPROVER_LIST = new List<Group>([SELECT id, name FROM Group where group.name='ASI MFM CN POSM Item Approver']);
    Static Integer afterUpdateCount = 0;

	public static void routineAfterUpsert(list<ASI_FOC_Request_Item__c> trigger_new, map<id, ASI_FOC_Request_Item__c> trigger_oldMap) {
        if(afterUpdateCount == 0){
            afterUpdateCount++;
            
            //20190103 Andy @Introv - approval from IBD
        	set<id> IBD_set = new set<id>();
            
			// Set ASI_FOC_SYS_Request_Line_Information__c for the related request order
            set<id> rq_set = new set<id>();
            for (ASI_FOC_Request_Item__c i:trigger_new) {
                rq_set.add(i.ASI_FOC_Request_Order__c);
                
                //20190103 Andy @Introv - approval from IBD
                if (i.ASI_MFM_IBD__c != null) {
                    IBD_set.add(i.ASI_MFM_IBD__c);
            	}
            }
            // Modified by Alan Wong (Elufa) 20150803
            list<ASI_FOC_Free_Goods_Request__c> rq_list = [select (select ASI_FOC_SKU__r.name, ASI_FOC_SKU__r.ASI_FOC_SKU_Chinese_Description__c, ASI_FOC_Request_Quantity_Bottle__c,ASI_FOC_Original_Request_Quantity_PC_BT__c, ASI_FOC_Packing_Description__c, ASI_FOC_Brand_Director_Approval_Status__c, ASI_MFM_IBD__c 
                from ASI_FOC_Request_Items__r /*where ASI_FOC_Brand_Director_Approval_Status__c != 'Rejected' and ASI_FOC_Brand_Director_Approval_Status__c != 'Cancelled'*/ order by ASI_FOC_SKU__r.name)
                from ASI_FOC_Free_Goods_Request__c where id in :rq_set for update];
            
            //20190103 Andy @Introv - approval from IBD
        	map<id, ASI_MFM_InventoryBalanceDetail__c> IBD_map = new map<id, ASI_MFM_InventoryBalanceDetail__c>([select ASI_MFM_SFDCOwner__c, ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c from ASI_MFM_InventoryBalanceDetail__c where id in :IBD_set]);
            
            // -- End -- //
            string sku_x = 'SKU';
            string pkg_x = 'Packaging';
            string qty_x = 'Qty.';
            String ChiDes_x = 'Chinese Description';		// 20151028 Ben @ Elufa
            String approvalStatus = 'Approval Status';
            string hdr = sku_x.rightPad(31) + pkg_x.rightPad(11) + qty_x.rightPad(6) + ChiDes_x.rightPad(31) + approvalStatus.rightPad(10) + '<br/>';	
            for (ASI_FOC_Free_Goods_Request__c rq:rq_list) {
                rq.ASI_FOC_SYS_Request_Line_Information__c = '<pre>' + hdr;
    //			integer line_no = 0;
                for (ASI_FOC_Request_Item__c i:rq.ASI_FOC_Request_Items__r) {
    //				line_no++;
    //				rq.ASI_FOC_SYS_Request_Line_Information__c += string.valueOf(line_no).trim().rightPad(4);
                    string sku_name = i.ASI_FOC_SKU__r.name == null ? '' : i.ASI_FOC_SKU__r.name;
                    rq.ASI_FOC_SYS_Request_Line_Information__c += sku_name.trim().left(30).rightPad(31);
                    string sku_pkg = i.ASI_FOC_Packing_Description__c == null ? '' : i.ASI_FOC_Packing_Description__c;
                    rq.ASI_FOC_SYS_Request_Line_Information__c += sku_pkg.trim().left(10).rightPad(11);				
                    //string sku_qty = i.ASI_FOC_Request_Quantity_Bottle__c == null ? '' : string.valueOf(i.ASI_FOC_Request_Quantity_Bottle__c);
                    string sku_qty = i.ASI_FOC_Original_Request_Quantity_PC_BT__c == null ? '' : string.valueOf(i.ASI_FOC_Original_Request_Quantity_PC_BT__c); // Modified by Alan Wong (Elufa) 20150803
                    rq.ASI_FOC_SYS_Request_Line_Information__c += sku_qty.trim().right(5).rightPad(6);
                    string sku_ChiDes = i.ASI_FOC_SKU__r.ASI_FOC_SKU_Chinese_Description__c == null ? '' : i.ASI_FOC_SKU__r.ASI_FOC_SKU_Chinese_Description__c;
                    rq.ASI_FOC_SYS_Request_Line_Information__c += sku_ChiDes.trim().right(30).rightPad(31);
                    string approvalStatus_Str = i.ASI_FOC_Brand_Director_Approval_Status__c == null ? '' : i.ASI_FOC_Brand_Director_Approval_Status__c;
                    rq.ASI_FOC_SYS_Request_Line_Information__c += approvalStatus_Str.trim().right(9).rightPad(10) + '<br/>';
                    
                    if (i.ASI_MFM_IBD__c != NULL) {
                        if (IBD_map.containsKey(i.ASI_MFM_IBD__c)) {
                            if (IBD_map.get(i.ASI_MFM_IBD__c).ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c != NULL) {
                                rq.ASI_MFM_FromWarehouse__c = IBD_map.get(i.ASI_MFM_IBD__c).ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c;
                            }
                        }
                    }
                }
                rq.ASI_FOC_SYS_Request_Line_Information__c += '</pre>';
            }
            System.debug(LoggingLevel.INFO, '*** rq_list: ' + rq_list);
            update rq_list;
        }

        
        
	}
	
	public static void routineBeforeUpsert(list<ASI_FOC_Request_Item__c> trigger_new, map<id, ASI_FOC_Request_Item__c> trigger_oldMap) {
		set<id> sku_set = new set<id>();
        set<id> FOC_set = new set<id>();
        //20181210 Andy @Introv - approval from IBD
        set<id> IBD_set = new set<id>();
        
		for (ASI_FOC_Request_Item__c i:trigger_new) {
			sku_set.add(i.ASI_FOC_SKU__c);
            FOC_set.add(i.ASI_FOC_Request_Order__c);
			if (i.ASI_FOC_Sys_Clone_Flag__c) {
				i.ASI_FOC_Sys_Clone_Flag__c = false;
			}
            //20181210 Andy @Introv - approval from IBD
            if (i.ASI_MFM_IBD__c != null) {
            	IBD_set.add(i.ASI_MFM_IBD__c);
            }
		}
        Map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_FOC_Request_Item__c'); // Added By Alan Wong (Elufa) 20150616
		map<id, ASI_FOC_Free_Goods_Request__c> foc_map = new map<id, ASI_FOC_Free_Goods_Request__c>([SELECT id, ASI_FOC_Description__c, OwnerID, ASI_CRM_CN_FG_Supplier_Email__c FROM ASI_FOC_Free_Goods_Request__c WHERE id IN:FOC_set]);
// Set Brand Approval Required Flag and Brand Approver
		map<id, ASI_MFM_SKU_Code__c> sku_map = new map<id, ASI_MFM_SKU_Code__c>([select ASI_FOC_Location_Item_Owner__c, ASI_FOC_Location_Item_Owner__r.ManagerID, ASI_FOC_Brand_Director_Approval_Required__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ownerId from ASI_MFM_SKU_Code__c where id in :sku_set]);
		
        //20181210 Andy @Introv - approval from IBD
        map<id, ASI_MFM_InventoryBalanceDetail__c> IBD_map = new map<id, ASI_MFM_InventoryBalanceDetail__c>([select ASI_MFM_SFDCOwner__c, ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_FOC_Warehouse_Type__c from ASI_MFM_InventoryBalanceDetail__c where id in :IBD_set]);
		
        //20171113 Introv
        
        Map<id, ASI_CRM_SKU_Photo__c> mapSKUPhoto = new Map<id, ASI_CRM_SKU_Photo__c>();
        for(ASI_CRM_SKU_Photo__c obj : [SELECT Id
                                        , ASI_CRM_Attachment__r.ASI_Image_URL__c
                                        , ASI_CRM_SKU__c
                                        FROM ASI_CRM_SKU_Photo__c
                                        WHERE ASI_CRM_SKU__c IN : sku_set
                                        ORDER BY ASI_CRM_Attachment__r.ASI_CRM_Photo_Category__c ASC
                                        , ASI_CRM_Photo_Version__c DESC
                                        , ASI_CRM_Attachment__r.ASI_Name__c ASC
                                       ]){
                                           mapSKUPhoto.put(obj.ASI_CRM_SKU__c, obj);
                                       }
        
        //20171113 End
        
        List<ASI_FOC_Free_Goods_Request__Share> sharingList = new List<ASI_FOC_Free_Goods_Request__Share>();//20151230 Ben @ Elufa System
        
        for (ASI_FOC_Request_Item__c i:trigger_new) {
            
            //20171113 Introv
            if(mapSKUPhoto.containsKey(i.ASI_FOC_SKU__c))
                i.ASI_FOC_SKU_Image_URL__c = mapSKUPhoto.get(i.ASI_FOC_SKU__c).ASI_CRM_Attachment__r.ASI_Image_URL__c;
            //20171113 End
            
			if (sku_map.containsKey(i.ASI_FOC_SKU__c)) {
                //20151211 Ben @ Elufa System
                if(i.recordTypeId == rt_map.get('ASI_FOC_CN_Request_Item')){
                    i.ASI_FOC_Brand_Director_Approval_Required__c = sku_map.get(i.ASI_FOC_SKU__c).ASI_FOC_Brand_Director_Approval_Required__c;
                    if (i.ASI_FOC_Brand_Director_Approval_Required__c) {
                        i.ASI_FOC_Brand_Approver__c = sku_map.get(i.ASI_FOC_SKU__c).ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ownerId;
                    }
                    else {
                        i.ASI_FOC_Brand_Approver__c = null;
                    }
                }else if(i.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Request_Item')){
                    //20190102 Andy @Introv - add regional approval/HQ approval - START
                    //20181210 Andy @Introv - approval from IBD - START
                    /*
                    if(foc_map.get(i.ASI_FOC_Request_Order__c).OwnerID != sku_map.get(i.ASI_FOC_SKU__c).ASI_FOC_Location_Item_Owner__c && sku_map.get(i.ASI_FOC_SKU__c).ASI_FOC_Location_Item_Owner__c != NULL){
                        
                        i.ASI_FOC_Brand_Director_Approval_Required__c = TRUE;
                        i.ASI_FOC_Brand_Approver__c = sku_map.get(i.ASI_FOC_SKU__c).ASI_FOC_Location_Item_Owner__c;//20160119 Ben @ Elufa Systems removed ManagerID
                        
                        //20151230 Ben @ Elufa System
                        if(trigger.isInsert){
                            ASI_FOC_Free_Goods_Request__Share shareRecord = new ASI_FOC_Free_Goods_Request__Share();
                            shareRecord.ParentId = i.ASI_FOC_Request_Order__c;
                            shareRecord.UserOrGroupId = sku_map.get(i.ASI_FOC_SKU__c).ASI_FOC_Location_Item_Owner__c;//20160119 Ben @ Elufa Systems removed ManagerID
                            shareRecord.AccessLevel = 'edit';
                            if(shareRecord.UserOrGroupId != NULL)
                                sharingList.add(shareRecord);
                        }
                        //20151230 End
                        }else{
                        i.ASI_FOC_Brand_Director_Approval_Required__c = FALSE;
                        i.ASI_FOC_Brand_Approver__c = NULL;
                    }
                    */
                    Boolean bBrandApprovalRequired = FALSE;
                    if (i.ASI_MFM_IBD__c != null) {
                        //20190104 - keep item approval for all types
                        // HQ = 1 ; Region = 2 ; else = 0
                    	//Integer iApprovalType = getOrderApprovalType(IBD_map.get(i.ASI_MFM_IBD__c).ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_FOC_Warehouse_Type__c);
                        
                        //if (iApprovalType == 1) {
                            //20190102 Andy @Introv - HQ approval
                            if(foc_map.get(i.ASI_FOC_Request_Order__c).OwnerID != IBD_map.get(i.ASI_MFM_IBD__c).ASI_MFM_SFDCOwner__c && IBD_map.get(i.ASI_MFM_IBD__c).ASI_MFM_SFDCOwner__c != NULL){
                                bBrandApprovalRequired = TRUE;
                                i.ASI_FOC_Brand_Director_Approval_Required__c = TRUE;
                                i.ASI_FOC_Brand_Approver__c = IBD_map.get(i.ASI_MFM_IBD__c).ASI_MFM_SFDCOwner__c;
                                
                                //20151230 Ben @ Elufa System
                                if(trigger.isInsert){
                                    ASI_FOC_Free_Goods_Request__Share shareRecord = new ASI_FOC_Free_Goods_Request__Share();
                                    shareRecord.ParentId = i.ASI_FOC_Request_Order__c;
                                    shareRecord.UserOrGroupId = IBD_map.get(i.ASI_MFM_IBD__c).ASI_MFM_SFDCOwner__c;
                                    shareRecord.AccessLevel = 'edit';
                                    if(shareRecord.UserOrGroupId != NULL)
                                        sharingList.add(shareRecord);
                                }
                            }
                        //}
                    } else {
                        //20190314 - rollback old approval
                        if(foc_map.get(i.ASI_FOC_Request_Order__c).OwnerID != sku_map.get(i.ASI_FOC_SKU__c).ASI_FOC_Location_Item_Owner__c && sku_map.get(i.ASI_FOC_SKU__c).ASI_FOC_Location_Item_Owner__c != NULL){
                            bBrandApprovalRequired = TRUE;
                            i.ASI_FOC_Brand_Director_Approval_Required__c = TRUE;
                            i.ASI_FOC_Brand_Approver__c = sku_map.get(i.ASI_FOC_SKU__c).ASI_FOC_Location_Item_Owner__c;//20160119 Ben @ Elufa Systems removed ManagerID
                            
                            //20151230 Ben @ Elufa System
                            if(trigger.isInsert){
                                ASI_FOC_Free_Goods_Request__Share shareRecord = new ASI_FOC_Free_Goods_Request__Share();
                                shareRecord.ParentId = i.ASI_FOC_Request_Order__c;
                                shareRecord.UserOrGroupId = sku_map.get(i.ASI_FOC_SKU__c).ASI_FOC_Location_Item_Owner__c;//20160119 Ben @ Elufa Systems removed ManagerID
                                shareRecord.AccessLevel = 'edit';
                                if(shareRecord.UserOrGroupId != NULL)
                                    sharingList.add(shareRecord);
                            }
                            //20151230 End
                        }
                    }
                    
                    if (!bBrandApprovalRequired) {
                        i.ASI_FOC_Brand_Director_Approval_Required__c = FALSE;
                        i.ASI_FOC_Brand_Approver__c = NULL;
                    }
                    //20181210 Andy @Introv - approval from IBD - END
                    //20190102 Andy @Introv - add regional approval/HQ approval - END
                    
                    //20181130 Andy @Introv - new field (ASI_MFM_AutoComplete__c)
                    i.ASI_MFM_AutoComplete__c = TRUE;
                }
                //20151211 End
			}
            
            //20181130 Andy @Introv - new field (ASI_MFM_AutoComplete__c) - START
            if (i.ASI_FOC_ETL_Complete__c)
                i.ASI_MFM_AutoComplete__c = TRUE;
            //20181130 Andy @Introv - new field (ASI_MFM_AutoComplete__c) - END
            
            if (foc_map.containsKey(i.ASI_FOC_Request_Order__c)) {
				i.ASI_FOC_Reason__c = foc_map.get(i.ASI_FOC_Request_Order__c).ASI_FOC_Description__c;
                i.ASI_CRM_CN_FG_Supplier_Email__c = foc_map.get(i.ASI_FOC_Request_Order__c).ASI_CRM_CN_FG_Supplier_Email__c;// add by BLS send supplier email 2020-11-23
			}
            if (i.recordTypeId == rt_map.get('ASI_FOC_CN_Request_Item')){
                if (i.ASI_FOC_Cancel_Quantity_PC_BT__c == i.ASI_FOC_Original_Request_Quantity_PC_BT__c && i.ASI_FOC_Original_Request_Quantity_PC_BT__c > 0 &&
                    (i.ASI_FOC_Brand_Director_Approval_Status__c == null || i.ASI_FOC_Brand_Director_Approval_Status__c == '')) {
                        i.ASI_FOC_Brand_Director_Approval_Status__c = 'Cancelled';
                }
            }
            //20160203 Ben @ Elufa
            else if (i.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Request_Item')){
                if (i.ASI_FOC_Cancel_Quantity_PC_BT__c == i.ASI_FOC_Original_Request_Quantity_PC_BT__c && i.ASI_FOC_Original_Request_Quantity_PC_BT__c > 0) {
                        i.ASI_FOC_Brand_Director_Approval_Status__c = 'Cancelled';
                }
            }
            //20160203 End
            if (trigger_oldMap != null){
                if (i.recordTypeId == rt_map.get('ASI_FOC_CN_Request_Item') && i.ASI_FOC_Original_Request_Quantity_PC_BT__c != trigger_oldMap.get(i.Id).ASI_FOC_Original_Request_Quantity_PC_BT__c)
                {
                    i.ASI_FOC_Request_Quantity_Bottle__c = i.ASI_FOC_Original_Request_Quantity_PC_BT__c;
                }
                if (i.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Request_Item') && i.ASI_FOC_Original_Request_Quantity_PC_BT__c != trigger_oldMap.get(i.Id).ASI_FOC_Original_Request_Quantity_PC_BT__c)
                {
                    i.ASI_FOC_Request_Quantity_PC__c = i.ASI_FOC_Original_Request_Quantity_PC_BT__c;
                }
            }
            else{
                 if (i.recordTypeId == rt_map.get('ASI_FOC_CN_Request_Item'))
                {
                    i.ASI_FOC_Request_Quantity_Bottle__c = i.ASI_FOC_Original_Request_Quantity_PC_BT__c;
                }
                if (i.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Request_Item'))
                {
                    i.ASI_FOC_Request_Quantity_PC__c = i.ASI_FOC_Original_Request_Quantity_PC_BT__c;
                }
            }
        }
        //20151230 Ben @ Elufa System
        if(sharingList.size()>0)
            Database.insert(sharingList, false);
        //20151230 End
        
        //20190408 Andy @Introv - #97-add public group for item approvers
        if(sharingList.size()>0) {
            Set<Id> setSharing = new Set<id>();
            for(ASI_FOC_Free_Goods_Request__Share oShare : sharingList) {
                setSharing.add(oShare.UserOrGroupId);
            }
            AssignSharingList2DefaultGroup(setSharing);
        }

        // 20200720 Jack Yuan start
        // if (trigger_oldMap == null 
        //     || (trigger_oldMap != null && item.ASI_FOC_SKU__c != trigger_oldMap.get(item.Id).ASI_FOC_SKU__c) ) {
            System.debug(LoggingLevel.INFO, '*** update request items: ');
            Map<String, Decimal> logisticSettingMap = new Map<String, Decimal>();
            List<ASI_MFM_Expense_Control_Form__c> logisticSettings = [SELECT ASI_CRM_CN_FG_Bottle_Size__c, ASI_CRM_CN_FG_Logistics_Cost_per_Btl__c 
                                                                      FROM ASI_MFM_Expense_Control_Form__c 
                                                                      WHERE RecordType.DeveloperName = 'ASI_CN_Logistics_Btl_Control_Form'];
            for (ASI_MFM_Expense_Control_Form__c logisticS : logisticSettings) {
                String btlSize = logisticS.ASI_CRM_CN_FG_Bottle_Size__c != 'Other' && logisticS.ASI_CRM_CN_FG_Bottle_Size__c != null ? String.valueOf(Decimal.valueOf(logisticS.ASI_CRM_CN_FG_Bottle_Size__c).setScale(2)) : 'Other';
                logisticSettingMap.put(btlSize, logisticS.ASI_CRM_CN_FG_Logistics_Cost_per_Btl__c);
            }
            Set<Id> skuIds = new Set<Id>();
            for (ASI_FOC_Request_Item__c item : trigger_new) {
                skuIds.add(item.ASI_FOC_SKU__c);
            }
            Map<Id, String> skuIdBtlSizeMap = new Map<Id, String>();
            List<ASI_MFM_SKU_Code__c> skuList = [SELECT ASI_MFM_Item_Group__r.ASI_CRM_CN_TP_Bottle_Size__c  
                                                 FROM ASI_MFM_SKU_Code__c WHERE Id IN :skuIds];
            for (ASI_MFM_SKU_Code__c sku : skuList) {
                skuIdBtlSizeMap.put(sku.Id, String.valueOf(sku.ASI_MFM_Item_Group__r.ASI_CRM_CN_TP_Bottle_Size__c));
            }
            for (ASI_FOC_Request_Item__c item : trigger_new) {
                item.ASI_CRM_CN_FG_Logistics_Cost_per_Btl__c = logisticSettingMap.get(skuIdBtlSizeMap.get(item.ASI_FOC_SKU__c)) == null 
                                                                ? logisticSettingMap.get('Other')
                                                                : logisticSettingMap.get(skuIdBtlSizeMap.get(item.ASI_FOC_SKU__c));
            }

        // }
      // 20200720 Jack Yuan end
        
	}
    
    //20190408 Andy @Introv - #97-add public group for item approvers
    @future
    private static void AssignSharingList2DefaultGroup(Set<Id> setSharing) {
        if (POSM_ITEM_APPROVER_LIST.size() > 0) {
            Id idGroup = POSM_ITEM_APPROVER_LIST[0].id;
            
            List<GroupMember> oNewMember = new List<GroupMember>();
            for(Id idSharing : setSharing) {
                oNewMember.add(new GroupMember(GroupId=idGroup,UserOrGroupId=idSharing));
            }
            insert oNewMember;
        }
    }
    
    Public Static void routineBeforeDelete(List<ASI_FOC_Request_Item__c> trigger_old){
        
        Set<ID> headerID = new Set<ID>();
        
        for(ASI_FOC_Request_Item__c obj : trigger_old){
            headerID.add(obj.ASI_FOC_Request_Order__c);
        }
        
        Map<ID, ASI_FOC_Free_Goods_Request__c> headerMap = new Map<ID, ASI_FOC_Free_Goods_Request__c>([SELECT id, ASI_FOC_Request_Status__c FROM ASI_FOC_Free_Goods_Request__c WHERE id IN : headerID]);
        
        for(ASI_FOC_Request_Item__c obj : trigger_old){
            if(headerMap.containsKey(obj.ASI_FOC_Request_Order__c)){
                if(headerMap.get(obj.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c != 'Open'){
                    obj.addError('Not allowed to delete record in current status');
                }
            }
        }
    }

    //202009 added by LEO Jing BSL
    public static void autoSubmitOrderApproval(list<ASI_FOC_Request_Item__c> trigger_new, map<id, ASI_FOC_Request_Item__c> trigger_oldMap){
        System.debug(LoggingLevel.INFO, '*** YES: ');
        Set<Id> yes_itemIds = new Set<Id>();
        Set<Id> no_itemIds = new Set<Id>();
        Set<Id> prrIds = new Set<Id>();
        for (ASI_FOC_Request_Item__c item : trigger_new) {
            ASI_FOC_Request_Item__c old_item = trigger_oldMap.get(item.Id);            
            if (item.ASI_FOC_POSM_Request_Approval__c != null && item.ASI_FOC_Brand_Director_Approval_Status__c == 'Approved' && item.ASI_FOC_Brand_Director_Approval_Status__c != old_item.ASI_FOC_Brand_Director_Approval_Status__c) {
                yes_itemIds.add(item.Id);
                prrIds.add(item.ASI_FOC_POSM_Request_Approval__c);
            }
            if (item.ASI_FOC_POSM_Request_Approval__c != null && item.ASI_FOC_Brand_Director_Approval_Status__c == 'Rejected' && item.ASI_FOC_Brand_Director_Approval_Status__c != old_item.ASI_FOC_Brand_Director_Approval_Status__c) {
                no_itemIds.add(item.Id);                
            }
        }

        List<ASI_FOC_Request_Item__c> yes_itemList = [SELECT Id FROM ASI_FOC_Request_Item__c WHERE ASI_MFM_Request_Item_Approval__c IN: yes_itemIds];
        List<ASI_FOC_Request_Item__c> no_itemList = [SELECT Id FROM ASI_FOC_Request_Item__c WHERE ASI_MFM_Request_Item_Approval__c IN: no_itemIds];

        if (yes_itemList.size() > 0) {
            for (ASI_FOC_Request_Item__c item : yes_itemList) {
                item.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';
            }
            update yes_itemList;
        }
        if (no_itemList.size() > 0) {
            for (ASI_FOC_Request_Item__c item : no_itemList) {
                item.ASI_FOC_Brand_Director_Approval_Status__c = 'Rejected';
            }
            update no_itemList;
        }

        if (prrIds.size() == 0) return;
        List<ASI_FOC_Free_Goods_Request__c> prrList =  [SELECT Id,ASI_FOC_Request_Status__c,(SELECT Id,ASI_FOC_Brand_Director_Approval_Status__c FROM ASI_FOC_POSM_Request_Item_Approval__r) FROM ASI_FOC_Free_Goods_Request__c WHERE Id IN: prrIds];
        for (ASI_FOC_Free_Goods_Request__c prr : prrList){
            if (prr.ASI_FOC_Request_Status__c != 'Final') {
                Boolean pass = true;
                for (ASI_FOC_Request_Item__c item : prr.ASI_FOC_POSM_Request_Item_Approval__r) {  
                    if (item.ASI_FOC_Brand_Director_Approval_Status__c != 'Approved') {
                        pass = false;
                        continue; 
                    }
                }
                System.debug(LoggingLevel.INFO, '*** pass: ' + pass);
                if (pass) {
                    System.debug(LoggingLevel.INFO, '*** prr.Id: ' + prr.Id);
                    List<Approval.ProcessSubmitRequest> header_req = new List<Approval.ProcessSubmitRequest>();                    
                    Approval.ProcessSubmitRequest tmp_header_req = new Approval.ProcessSubmitRequest();
                    tmp_header_req.setObjectId(prr.id);
                    header_req.add(tmp_header_req);                    
                    List<Approval.ProcessResult> header_result = Approval.process(header_req);  
                    
                }
            }
            
        }
    }
    
    //20190104 - keep item approval for all types
    /*
    //20190102 Andy @Introv - add regional approval/HQ approval - START
    // HQ = 1 ; Region = 2 ; else = 0
    Private Static Integer getOrderApprovalType(string sCheckType) {
        Integer iType = 0;
        
        String sHQ = 'HQ Warehouse';
        String sRegion = 'Region Warehouse';
        
        if ((sCheckType != NULL) && (sCheckType != '')) {
            if (sCheckType.toLowerCase() == sHQ.toLowerCase())
                iType = 1;
            if (sCheckType.toLowerCase() == sRegion.toLowerCase())
                iType = 2;
        }
        
        return iType;
    }
    //20190102 Andy @Introv - add regional approval/HQ approval - END
    */
}