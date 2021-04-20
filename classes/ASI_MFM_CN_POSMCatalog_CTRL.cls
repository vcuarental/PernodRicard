Public class ASI_MFM_CN_POSMCatalog_CTRL {

    Private Static Final String BRAND_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand');
    Private Static Final String SUB_BRAND_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
    Private Static Final String CATEGORY_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MFM_CN_Category_Master');
    Private Static Final String ITEMGROUP_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
    Private Static Final String POSM_IETMGROUP_PHOTO_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo'); 
    Private Static Final String CHANNEL_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_MFM_CN_POSM_Channel');
    Private Static Final String SEC_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSMCatalogSecCtrl__cASI_MFM_CN_POSM');
    Private Static Final String CART_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM');
    Private Static Final String CART_RO_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only');
    Private Static Final String CART_ITEM_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item');
    Private Static Final String POSMSKU_ID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU');
    Private Static Final String INV_BALANCE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Inventory_Balance__cASI_MFM_CN_Inventory_Balance');
    Private Static Final String DELIVERYZONE_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_MFM_CN_POSM');
    Private Static Final String WAREHOUSE_ID = Global_recordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
    Private Static Final String EXP_CONTROL_ID = Global_recordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Tax_Saving_Control_Form');
	Private Static Final String USER_ASSIGN_ID = Global_recordTypeCache.getRtId('ASI_MFM_Request_Item_User_Assignment__cASI_MFM_CN_UA_POSM');
    private static Final Id BATCH_LOG_ID = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');
    Private Static Final Integer PAGE_SIZE = 50;
    
    Public ASI_MFM_CN_POSMCatalog_CTRL(){}
    @RemoteAction
    public static String currentUerInfo(){       
        return UserInfo.getUserId();
    }

    //20200108 Enoch@Introv FGR Header status Checking
    Public Static Boolean editableFGR(Id requestId) {
        Boolean result = true;
        ASI_FOC_Free_Goods_Request__c fgr = [SELECT id, ASI_FOC_Request_Status__c FROM ASI_FOC_Free_Goods_Request__c WHERE id = :requestId LIMIT 1];
        return fgr.ASI_FOC_Request_Status__c=='Open';
    }
    
    //-------- start shopping cart ----------
    @RemoteAction
    Public Static Map<String, Object> retrieveShoppingCart(){		
        return retrieveCartDetail(' AND RecordTypeId = :CART_ID AND ASI_FOC_Request_Status__c = \'Open\' LIMIT 1', null, true);
    }
    @RemoteAction
    Public Static List<String> retrieveCartHistoryId(String filterStatus){		
        List<String> fgReqIdList = new List<String>();
		Id userId = UserInfo.getUserId();
        String soqlStr = 'SELECT id FROM ASI_FOC_Free_Goods_Request__c WHERE Owner.Id=:userId AND ASI_FOC_Request_Status__c != \'Open\'';
        soqlStr += ' AND ASI_MFM_ForPOSMCart__c = true AND(RecordTypeId = :CART_ID OR RecordTypeId = :CART_RO_ID)';
        if(filterStatus!=null && filterStatus!='') {
            Set<String> setStatus = new Set<String>{'Final','Rejected','Completed'};
            if(filterStatus=='Final') {
                soqlStr += ' AND ASI_FOC_Request_Status__c IN :setStatus';
            } else {
                soqlStr += ' AND ASI_FOC_Request_Status__c NOT IN :setStatus';
            }
//            soqlStr += ' AND ASI_FOC_Request_Status__c LIKE :filterStatus';
        }
        soqlStr += ' ORDER BY CreatedDate desc';
        for(ASI_FOC_Free_Goods_Request__c fgr : (List<ASI_FOC_Free_Goods_Request__c>)database.query(soqlStr)){
            fgReqIdList.add(fgr.Id);
        }
        return fgReqIdList;
    }
    @RemoteAction
    Public Static Map<String, Object> retrieveShoppingHistory(List<String> orderIdList){
        String filterStr = '';
        if(orderIdList!=null && orderIdList.size()>0) {
            filterStr = ' AND Id IN :orderIdList';
        } else {
            Map<String,Object> tmpResult = new Map<String,Object>();
            tmpResult.put('carts',new List<ASI_FOC_Free_Goods_Request__c>());
            return tmpResult;
        }
       	filterStr+=' AND RecordTypeId = :CART_RO_ID AND ASI_FOC_Request_Status__c != \'Open\' ORDER BY CreatedDate desc LIMIT 10';
        return retrieveCartDetail(filterStr, orderIdList, false);
    }
    
    Static Map<String, Object> retrieveCartDetail(String filterString, List<String> orderIdList, Boolean isRetrieveShoppingCart){
        Map<String,Object> tmpResult = new Map<String,Object>();
        List<ASI_FOC_Request_Item__c> cartItemList = new List<ASI_FOC_Request_Item__c>();
		Set<String> itemIdSet = new Set<String>();
        
        Id userId = UserInfo.getUserId();
        String soqlStr = 'SELECT id, name, ASI_MFM_POSM_PO_Number__c, owner.name, owner.id, ASI_MFM_Request_Category__c,ASI_FOC_Request_Status__c, ASI_FOC_Approver_1__r.Name, ASI_CRM_Outlet__c ,ASI_CRM_Outlet__r.name, ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Name__r.Name , ASI_FOC_Lead_Time__c, ASI_MFM_DetailAddress__c, ASI_FOC_Date_of_Delivery__c , ASI_MFM_DeliveryTime__c,ASI_FOC_ETA_Date__c,ASI_MFM_ReasonForTime__c'
            +' ,ASI_MFM_FromWarehouse__c, ASI_MFM_FromWarehouse__r.name, ASI_FOC_To_Regional_Warehouse__c, ASI_FOC_To_Regional_Warehouse__r.name, ASI_FOC_To_Regional_Warehouse__r.ASI_FOC_Warehouse_Code__c, ASI_FOC_Delivery_Zone__c, ASI_FOC_Delivery_Zone__r.name'
            +' ,ASI_MFM_Region__c, ASI_MFM_Region__r.ASI_CRM_Chinese_Name__c,  ASI_MFM_City__c, ASI_MFM_City__r.Name, ASI_MFM_City__r.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c, ASI_FOC_Purpose__c, ASI_MFM_Add_Value_Service__c,ASI_MFM_Add_ValueSet_Service__c, ASI_MFM_LeadTimeCart__c, ASI_FOC_Receiptor_Name__c,ASI_FOC_Receiptor_Mobile__c'
            +' ,ASI_MFM_RecipientEmail__c, ASI_FOC_Delivery_Instruction_1__c, ASI_CRM_CN_Purpose_Description__c, ASI_FOC_Deliver_to_Address_Line_1__c, ASI_FOC_Deliver_to_Address_Line_2__c'
            +' ,(SELECT id, name, ASI_FOC_SKU__c, ASI_FOC_SKU__r.ASI_MFM_SKU_Code__c, ASI_FOC_SKU__r.ASI_MFM_Minimum_Packing_Qty__c, ASI_FOC_SKU__r.ASI_MFM_Minimum_Box_Qty__c , ASI_MFM_IBD__c'
            +'   , ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Unit_Cost__c'
            +'   , ASI_MFM_IBD__r.ASI_MFM_CN_SFDC_RemainQty__c, ASI_MFM_Quantity__c, ASI_FOC_Request_Order__c ,  ASI_FOC_SKU__r.ASI_MFM_Box_Net_Weight_KG__c' 
            +' 	 , ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_FOC_City__c, ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_FOC_City__r.Name, ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_MFM_User_Assignment_Needed__c, ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_MFM_Regional_Warehouse__c'
            +' 	 , ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c ,ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.name ,ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.name'
            +'   , ASI_FOC_SKU__r.ASI_MFM_Item_Group__c, ASI_FOC_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c, ASI_FOC_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c, ASI_FOC_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Reference_Unit_Price__c '
            +'   , ASI_FOC_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Unit__c, ASI_FOC_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c ,ASI_FOC_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_CRM_CN_CHI_NAME_C__c'
            +'   , ASI_FOC_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c, ASI_FOC_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Utilization_Status__c, ASI_FOC_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Hidden__c'
            +'	 , ASI_FOC_Brand_Director_Approval_Required__c, ASI_FOC_Brand_Approver__r.Name, ASI_FOC_Brand_Director_Approval_Status__c'
            +'  FROM ASI_FOC_Request_Items__r '
            +'  WHERE RecordTypeId = :CART_ITEM_ID)'
            +' FROM ASI_FOC_Free_Goods_Request__c '
            +' WHERE Owner.Id=:userId AND ASI_MFM_ForPOSMCart__c = true ';

        if(filterString!=null && filterString != '') {
            soqlStr += filterString;
        }
        List<ASI_FOC_Free_Goods_Request__c> freegoodRequset = database.query(soqlStr);
        
        if(freegoodRequset==null || freegoodRequset.size()==0) {
            if(isRetrieveShoppingCart){
                freegoodRequset = new List<ASI_FOC_Free_Goods_Request__c>();
                freegoodRequset.add(new ASI_FOC_Free_Goods_Request__c(RecordTypeId=CART_ID,ASI_FOC_Request_Type__c='POS',ASI_FOC_Description__c='POSM'
                                                                      ,ASI_FOC_Request_Status__c = 'Open'
                                                                      ,ASI_CRM_CN_Purpose_Description__c='具体以仓库确认时间为准'
                                                                      ,ASI_MFM_ForPOSMCart__c = true
                                                                      ));
                insert freegoodRequset;
            }
        } else {
            if(freegoodRequset!=null && freegoodRequset.size()>0) {
                for(ASI_FOC_Free_Goods_Request__c fgreq : freegoodRequset) {
                    for(ASI_FOC_Request_Item__c requestItem : fgreq.ASI_FOC_Request_Items__r) {
                        cartItemList.add(requestItem);
                        itemIdSet.add(requestItem.ASI_FOC_SKU__r.ASI_MFM_Item_Group__c);
                    }
                }                
            }
        }
        
        Map<id,String> imageUrlMap = new Map<id,String>();
        for(ASI_MFM_Item_Group__c itemgroup : [SELECT Id,(SELECT Id, ASI_Image_URL__c FROM Product_Warehouse_Photos__r WHERE RecordTypeId =:POSM_IETMGROUP_PHOTO_RECORDTYPE_ID ORDER BY CreatedDate DESC Limit 1)
                                               FROM ASI_MFM_Item_Group__c 
                                               WHERE RecordTypeId = :ITEMGROUP_RECORDTYPE_ID AND Id IN :itemIdSet]) {
                                                   if(itemgroup.Product_Warehouse_Photos__r !=null && itemgroup.Product_Warehouse_Photos__r.size()!=0) {
                                                       imageUrlMap.put(itemgroup.Id,itemgroup.Product_Warehouse_Photos__r[0].ASI_Image_URL__c);
                                                   }
                                               }

        if(isRetrieveShoppingCart && freegoodRequset.size() == 1) {
            tmpResult.put('cart',freegoodRequset[0]);
            // Get Userassignment by Request Id
            tmpResult.put('userAssi',ASI_MFM_CN_POSMCatalog_UserAssi_EXT.getUserAssiRecByReqId(freegoodRequset[0].Id));
        } else tmpResult.put('carts',freegoodRequset);
        tmpResult.put('cartItems',cartItemList);
        tmpResult.put('itemids',itemIdSet);
        tmpResult.put('imageUrlMap',imageUrlMap);
        return tmpResult;
    }
    @RemoteAction
    Public Static ResultObj removeAllItemFromCart(String requestid) {
        List<ASI_FOC_Request_Item__c> lineToDelete = [SELECT id FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = :requestid AND recordTypeId = :CART_ITEM_ID];
        system.debug(lineToDelete);
        try{
            //20200108 Enoch@Introv FGR Header status Checking
            if(!editableFGR(requestid)) return new ResultObj(false, '不允许更改已提交购物车');
            delete lineToDelete;
            return new ResultObj(true, 'success');
        } catch (Exception e) {
            return new ResultObj(false, e.getMessage());
        }
    }
    @RemoteAction
    Public Static ResultObj removeItemFromCart(List<String> lineIdList) {
        //20200108 Enoch@Introv FGR Header status Checking
        List<ASI_FOC_Request_Item__c> lineToDelete = [SELECT id, ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c FROM ASI_FOC_Request_Item__c WHERE Id IN :lineIdList AND recordTypeId = :CART_ITEM_ID];
        system.debug(lineIdList);
        system.debug(lineToDelete);
        try{
            //20200108 Enoch@Introv FGR Header status Checking
            if(lineToDelete.size()>0 && lineToDelete[0].ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c!='Open') return new ResultObj(false, '不允许更改已提交购物车');
            delete lineToDelete;
            return new ResultObj(true, 'success');
        } catch (Exception e) {
            return new ResultObj(false, e.getMessage());
        }
    }
    
    Public Static void updateDZone(String requestId) {
        List<ASI_FOC_Request_Item__c> item = [SELECT id, name, ASI_FOC_Request_Order__r.ASI_MFM_City__c, ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_FOC_City__c
                                             FROM ASI_FOC_Request_Item__c
                                             WHERE ASI_FOC_Request_Order__c = :requestId
                                             LIMIT 1];
		Id fromCityId = null;
        Id toCityId = null;
        Id dzoneId = null;
        Integer leadTime = 10;
        try{
            if(item!=null && item.size()>0) {
                fromCityId = item[0].ASI_FOC_Request_Order__r.ASI_MFM_City__c;
                toCityId   = item[0].ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_FOC_City__c;
        	}
            if(fromCityId!=null && toCityId!=null) {
                List<ASI_FOC_Delivery_Zone__c> dzoneList = retrieveDeliveryZone(fromCityId,toCityId);
                if(dzoneList!=null && dzoneList.size()>0) {
                    leadTime = Integer.valueOf(dzoneList[0].ASI_MFM_TotalLeadTime__c);
                    dzoneId = dzoneList[0].Id;
                }
            }
        } catch(Exception e){}
        ASI_FOC_Free_Goods_Request__c  fgr = new ASI_FOC_Free_Goods_Request__c (Id=requestId, ASI_FOC_Delivery_Zone__c=dzoneId, ASI_MFM_LeadTimeCart__c=leadTime);
        Date d = Date.today();
        fgr.ASI_FOC_Date_of_Delivery__c = d.addDays(leadTime);
        update fgr;
    }
    
    @RemoteAction
    Public static ResultObj addItemToCart(String requestId,Map<String,LotObject> lotMap) {
        //20200108 Enoch@Introv FGR Header status Checking
        if(!editableFGR(requestId)) return new ResultObj(false, '不允许更改已提交购物车');
        
        Savepoint sp = Database.setSavepoint();
        // to do add Balance Detail RTID
        List<Object> debug = new List<Object>();
        List<ASI_FOC_Request_Item__c> updateRequestLine = new List<ASI_FOC_Request_Item__c>();
        List<ASI_FOC_Request_Item__c> insertRequestLine = new List<ASI_FOC_Request_Item__c>();
        List<ASI_FOC_Request_Item__c> deleteRequestLine = new List<ASI_FOC_Request_Item__c>();
        Map<id,ASI_MFM_InventoryBalanceDetail__c> ibdMap = new Map<id,ASI_MFM_InventoryBalanceDetail__c>([SELECT id, name, ASI_MFM_CN_SFDC_RemainQty__c, ASI_MFM_SKU__c 
                                                                                                            ,ASI_MFM_Action__c, ASI_MFM_ItemGroup__c,ASI_MFM_InventoryBalance__r.ASI_MFM_Unit_Cost__c
                                                                                                          FROM ASI_MFM_InventoryBalanceDetail__c 
                                                                                                          WHERE Id IN :lotMap.keySet()]);
        for(Id lotId : ibdMap.keySet()) {
            ASI_MFM_InventoryBalanceDetail__c dbLot = ibdMap.get(lotId);
            LotObject submitedLot = lotMap.get(lotId);
            system.debug(dbLot);
            system.debug(submitedLot);
            if(submitedLot.qty > dbLot.ASI_MFM_CN_SFDC_RemainQty__c) {
                return new ResultObj(false, 'Inv Balance : '+dbLot.name+' Quantity ' + dbLot.ASI_MFM_CN_SFDC_RemainQty__c);
            }
            ASI_FOC_Request_Item__c reqItem = new ASI_FOC_Request_Item__c();
            if(submitedLot.reqItemId!=null && submitedLot.reqItemId!='') {
                reqItem.Id = submitedLot.reqItemId;
                if(submitedLot.qty==0) 
                    deleteRequestLine.add(reqItem);
                else 
	                updateRequestLine.add(reqItem);
            } else {
	            reqItem.ASI_FOC_Request_Order__c = requestId;
                insertRequestLine.add(reqItem);
                // 
            }
            reqItem.ASI_MFM_Clone_From__c = (submitedLot.cloneFromId==null||submitedLot.cloneFromId=='')?null:submitedLot.cloneFromId; //Enoch@Introv 20191211 update for clone User Assignment 
            reqItem.recordTypeId = CART_ITEM_ID;
            reqItem.ASI_FOC_SKU__c = dbLot.ASI_MFM_SKU__c;
            reqItem.ASI_MFM_ItemGroup__c = dbLot.ASI_MFM_ItemGroup__c;
            reqItem.ASI_FOC_Original_Request_Quantity_PC_BT__c = submitedLot.qty;
            reqItem.ASI_FOC_Request_Quantity_PC__c = submitedLot.qty;
            reqItem.ASI_MFM_Quantity__c = submitedLot.qty;
            reqItem.ASI_MFM_IBD__c = lotId;
        }
        try {
            if(deleteRequestLine.size()>0)
                delete deleteRequestLine;
            if(updateRequestLine.size()>0)
	            update updateRequestLine;
            if(insertRequestLine.size()>0) {
                insert insertRequestLine;
                List<ASI_MFM_CN_JCT_FGL_IBD__c> jctList = new List<ASI_MFM_CN_JCT_FGL_IBD__c>();
                for(ASI_FOC_Request_Item__c reqItem :insertRequestLine){
                    jctList.add(new ASI_MFM_CN_JCT_FGL_IBD__c(ASI_MFM_Request_Item__c=reqItem.id,ASI_MFM_IBD__c=reqItem.ASI_MFM_IBD__c));
                }
                insert jctList;
            }
            List<ASI_FOC_Request_Item__c> updatedItemList = new List<ASI_FOC_Request_Item__c>();
            if(updateRequestLine.size()>0) {
                for(ASI_FOC_Request_Item__c item : updateRequestLine){updatedItemList.add(item);}
            }
            if(insertRequestLine.size()>0) {
                for(ASI_FOC_Request_Item__c item : insertRequestLine){updatedItemList.add(item);}
            }
            ResultObj result = new ResultObj(true, 'test');
            result.updatedItemList = updatedItemList;
            
            if(updateRequestLine.size()==0 && insertRequestLine.size()>0)updateDZone(requestId);
            ASI_MFM_CN_POSMCatalog_UserAssi_EXT.createAssignmentRec(lotMap,updatedItemList);

            return result;
        } catch (Exception e) {
            Database.rollback( sp );
            return new ResultObj(false, e.getMessage());
        }
        
    }
    
    Static string getAddrSubstring(string sRawAddr, integer iLength) {
		string sSubstring = '';
        if(sRawAddr!=null && sRawAddr!='') {
            sSubstring = sRawAddr.substring(0, (sRawAddr.length()>iLength?iLength:sRawAddr.length()));
        }
        return sSubstring;
    }
    
	static ASI_FOC_Free_Goods_Request__c assigFGHeader(String requestId, String fromWarehouseId, String toWarehouseId, String outletId, String agencyId, String deliveryZoneId, String regionId, String cityId
                                       , String address1, String address2, String receiptor, String phone, String purpose, String category
                                       , String arrivalDate, String deliveryTime, String timeReason, String deliveryInstruction, Integer leadTime, String mail, String addValueService, String ponum) {
		String address = ''+address1;
        if(address2!=null && address2!='') address += ' '+address2;
                                           
        //20190816:AM@Introv - add city to address (rollback-add only submit)
        /*
        if(cityId!=null && cityId!='') {
        	ASI_CRM_City__c oCity = [SELECT Id, Name From ASI_CRM_City__c WHERE Id = :cityId];
            address = oCity.Name+' '+address;
        }
        */
                                           
        //20190904:AM@Introv - check address string
        //if(address1!=null && address1!='') address1 = address1.substring(0, 30);
        //if(address2!=null && address2!='') address2 = address2.substring(0, 30);
		//if(address!=null && address!='') address = address.substring(0, 60);
        address1 = getAddrSubstring(address1,30);
		address2 = getAddrSubstring(address2,30);
		address = getAddrSubstring(address,60);
                                           
        ASI_FOC_Free_Goods_Request__c freeGoodsReq = new ASI_FOC_Free_Goods_Request__c (Id=requestId);
        freeGoodsReq.ASI_FOC_Deliver_to_Address_Line_1__c='';
        freeGoodsReq.ASI_FOC_Deliver_to_Address_Line_2__c='';
        if(fromWarehouseId!=null && fromWarehouseId!='')freeGoodsReq.ASI_MFM_FromWarehouse__c 		  = fromWarehouseId;
        if(toWarehouseId!=null && toWarehouseId!='')	freeGoodsReq.ASI_FOC_To_Regional_Warehouse__c = toWarehouseId;
        if(outletId!=null && outletId!='')				freeGoodsReq.ASI_CRM_Outlet__c 				  = outletId;
		if(outletId==null || outletId=='')              freeGoodsReq.ASI_CRM_Outlet__c 				  = null;
		freeGoodsReq.ASI_MFM_Supplier_Name__c			= (agencyId==null|| agencyId=='')? null:agencyId;
       	freeGoodsReq.ASI_FOC_Delivery_Zone__c	  	  	= (deliveryZoneId==null || deliveryZoneId=='')? null:deliveryZoneId;
        freeGoodsReq.ASI_MFM_Region__c					= (regionId==null || regionId=='')? null:regionId;
 	    freeGoodsReq.ASI_MFM_City__c 					= (cityId==null || cityId=='')? null:cityId;
        //if(regionId!=null && regionId!='')				freeGoodsReq.ASI_MFM_Region__c 				  = regionId;
        //if(cityId!=null && cityId!='')					freeGoodsReq.ASI_MFM_City__c 				  = cityId;
        //if(receiptor!=null && receiptor!='')			freeGoodsReq.ASI_FOC_Receiptor_Name__c 		  = receiptor;
        freeGoodsReq.ASI_FOC_Receiptor_Name__c 			= (receiptor!=null)? receiptor:'';
		freeGoodsReq.ASI_FOC_Receiptor_Mobile__c  		= (phone!=null) ? phone:'';
//        if(phone!=null && phone!='')					freeGoodsReq.ASI_FOC_Receiptor_Mobile__c 	  = phone;
        if(address1!=null && address1!='')				freeGoodsReq.ASI_FOC_Deliver_to_Address_Line_1__c = address1;
        if(address2!=null && address2!='')				freeGoodsReq.ASI_FOC_Deliver_to_Address_Line_2__c = address2;
        if(address!=null && address!='')				freeGoodsReq.ASI_MFM_DetailAddress__c 			= address;
		freeGoodsReq.ASI_FOC_Purpose__c 				= (purpose!=null)?purpose:null;
        if(category!=null && category!='')				freeGoodsReq.ASI_MFM_Request_Category__c 		= category;
		freeGoodsReq.ASI_MFM_RecipientEmail__c			= (mail!=null)? mail:'';
        //if(mail!=null) 									freeGoodsReq.ASI_MFM_RecipientEmail__c 			= mail;
        if(arrivalDate!=null && arrivalDate!=''){
            List<String> dateSplit = arrivalDate.split('/');
            freeGoodsReq.ASI_FOC_Date_of_Delivery__c = Date.newInstance( Integer.ValueOf(dateSplit[2]),Integer.ValueOf(dateSplit[1]),Integer.ValueOf(dateSplit[0]));
        }
        if(deliveryTime!=null && deliveryTime!='')		freeGoodsReq.ASI_MFM_DeliveryTime__c  = deliveryTime;
        if(timeReason!=null && timeReason!='')			freeGoodsReq.ASI_MFM_ReasonForTime__c = timeReason;
                                               
        if(deliveryInstruction!=null && deliveryInstruction!='') freeGoodsReq.ASI_FOC_Delivery_Instruction_1__c = deliveryInstruction;
        //20200716 edit by Leo Jing BLS.
        // if(addValueService!=null && addValueService!='') freeGoodsReq.ASI_MFM_Add_Value_Service__c = addValueService;
        if(addValueService!=null && addValueService!='') freeGoodsReq.ASI_MFM_Add_ValueSet_Service__c = addValueService;
        if(leadTime!=null) freeGoodsReq.ASI_MFM_LeadTimeCart__c  = leadTime;
		freeGoodsReq.ASI_MFM_POSM_PO_Number__c 			= (ponum==null || ponum=='')? '':ponum;
		return freeGoodsReq;
	}
    
    private static string assignDebugMsg(string sLabel, string sValue) {
        string sTmpValue = '';
        sTmpValue = sLabel + ':' + (sValue==NULL ? 'NULL' : sValue) + ';';
        return sTmpValue;
    }
    private static ASI_MFM_BatchLog__c InsertDebugMsg(string sDateTime, string sMsg) {
        ASI_MFM_BatchLog__c oLog = new ASI_MFM_BatchLog__c(
            RecordTypeId = BATCH_LOG_ID
            , ASI_MFM_Log_Detail__c  = '[' + sDateTime + ']:{' + sMsg + '}'
            , ASI_MFM_LogType__c = 'POSM Catalog'
        );
        insert oLog;
        return oLog;
    }
    
    @RemoteAction
    Public Static Void takeLog(Map<String, String> logMap){
        try{
            String message = '';
            for(String tag : logMap.keySet()) {message += assignDebugMsg(tag,logMap.get(tag));}
            Datetime dtTime = Datetime.now();
            string sDatetime = dtTime.format('yyyyMMddhhmmss');
	        ASI_MFM_BatchLog__c oLog = InsertDebugMsg(sDatetime, UserInfo.getUserId() + ';'+message);
        } catch(Exception e) {
            
        }
    }
    
    @RemoteAction
	Public Static ResultObj saveCart(String requestId, String fromWarehouseId, String toWarehouseId, String outletId, String agencyId, String deliveryZoneId, String regionId, String cityId
                                       , String address1, String address2, String receiptor, String phone, String purpose, String category
                                       , String arrivalDate, String deliveryTime, String timeReason, String deliveryInstruction, Integer leadTime, String mail, String addValueService, String ponum) {
        try {
        	ASI_FOC_Free_Goods_Request__c freeGoodsReq = assigFGHeader(requestId, fromWarehouseId, toWarehouseId, outletId, agencyId, deliveryZoneId, regionId, cityId, address1, address2, receiptor, phone, purpose, category, arrivalDate, deliveryTime, timeReason, deliveryInstruction, leadTime, mail, addValueService, ponum);
            update freeGoodsReq;
            return new ResultObj(true, 'success');
        } catch (Exception e) {
        	return new ResultObj(false, e.getMessage());
        }
	}
       
    @RemoteAction
	Public static ResultObj submitCart(String requestId, String fromWarehouseId, String toWarehouseId, Boolean isToRegionalWH, String outletId, String agencyId, String deliveryZoneId, String regionId, String cityId
                                       , String address1, String address2, String receiptor, String phone, String purpose, String category
                                       , String arrivalDate, String deliveryTime, String timeReason, String deliveryInstruction, Integer leadTime, String mail, String addValueService, String addValueServiceLabel, String ponum) {
		
		Savepoint sp = Database.setSavepoint();
        try{
            if(ponum != null && ponum !='') {
                Map<String, ASI_MFM_PO__c> poSearchResult = searchPo(ponum);
                if(poSearchResult.keySet().size()==0) return new ResultObj(false, '请填写正确PO号');
            }
			
            ASI_FOC_Free_Goods_Request__c freeGoodsReq = assigFGHeader(requestId, fromWarehouseId, toWarehouseId, outletId, agencyId, deliveryZoneId, regionId, cityId, address1, address2, receiptor, phone, purpose, category, arrivalDate, deliveryTime, timeReason, deliveryInstruction, leadTime, mail, addValueService, ponum);
            freeGoodsReq.ASI_MFM_SubmitDate__c = system.now();
            freeGoodsReq.ASI_FOC_Request_Status__c = 'In Progress';
            
            List<ASI_FOC_Request_Item__c> reqItemList = new List<ASI_FOC_Request_Item__c>();
            
            //20190816:AM@Introv - add city to address
            String address = ''+address1;
	        if(address2!=null && address2!='') address += ' '+address2;
            //String address = (freeGoodsReq.ASI_MFM_DetailAddress__c == NULL?'':freeGoodsReq.ASI_MFM_DetailAddress__c);
            string sDetailAddress = address;
            if(cityId!=null && cityId!='') {
                ASI_CRM_City__c oCity = [SELECT Id, Name From ASI_CRM_City__c WHERE Id = :cityId];
                sDetailAddress = oCity.Name+' '+sDetailAddress;
            }
            if(sDetailAddress!=null && sDetailAddress!='') {
                //20190904:AM@Introv - check address string
                //sDetailAddress = sDetailAddress.substring(0, 60);
                sDetailAddress = getAddrSubstring(sDetailAddress,60);
                
                freeGoodsReq.ASI_MFM_DetailAddress__c = sDetailAddress;
            }
            
            //20190819:AM@Introv - combine addValueService with the comments field in the shopping cart (length is short, use value instead)
            string sInstruction = ''+deliveryInstruction;
            //if(addValueServiceLabel!=null && addValueServiceLabel!='') sInstruction = addValueServiceLabel + ' ' + sInstruction;
            if(addValueService!=null && addValueService!='') sInstruction =sInstruction + ' ' + addValueService;
            if(sInstruction!=null && sInstruction!='') {                
                freeGoodsReq.ASI_FOC_Delivery_Instruction_1__c = getAddrSubstring(sInstruction,30);                
            }
            
            Set<ID> lineItemID = new Set<ID>();
            List<ASI_FOC_Request_Item__c> lineItemList = [SELECT id, ASI_FOC_Brand_Director_Approval_Status__c, ASI_FOC_Brand_Director_Approval_Required__c
                                                          , ASI_FOC_Brand_Approver__c, ASI_FOC_Request_Order__c 
                                                          , ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c
                                                          , ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_MFM_User_Assignment_Needed__c
                                                          , ASI_MFM_Total_Assignment_Quantity__c
                                                          , ASI_MFM_Quantity__c
                                                          , (SELECT id, ASI_MFM_Qty__c FROM Request_Item_User_Assignments__r)
                                                      FROM ASI_FOC_Request_Item__c 
                                                      WHERE ASI_FOC_Request_Order__c = : requestId];
            Set<Id> warehouseIdset = new Set<Id>();
            Boolean assignmentCoutPass = true;
            Boolean fromWH_UserAssignmentNeeded = false;
            List<ASI_MFM_RequestItem_UserAssignment__c> updateUaList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
           	List<ASI_MFM_RequestItem_UserAssignment__c> deleteUaList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
            
            for(ASI_FOC_Request_Item__c item : lineItemList) {
                if(item.ASI_MFM_Total_Assignment_Quantity__c != item.ASI_MFM_Quantity__c) assignmentCoutPass = false;
                fromWH_UserAssignmentNeeded = item.ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_MFM_User_Assignment_Needed__c;
                warehouseIdset.add(item.ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c);
                item.ASI_MFM_Warehouse__c = toWarehouseId;
                item.ASI_MFM_Region__c  = (regionId==null||regionId=='')? null:regionId;
                item.ASI_MFM_City__c    = (cityId==null||cityId=='')? null:cityId;
                item.ASI_MFM_Address__c = address;
                reqItemList.add(item);
                if(item.ASI_FOC_Brand_Director_Approval_Status__c != 'In Progress' && item.ASI_FOC_Brand_Director_Approval_Status__c != 'Approved' 
                   && item.ASI_FOC_Brand_Director_Approval_Required__c && item.ASI_FOC_Brand_Approver__c != NULL)
                    	lineItemID.add(item.id);
                if((!fromWH_UserAssignmentNeeded || !isToRegionalWH) && item.ASI_MFM_Total_Assignment_Quantity__c > item.ASI_MFM_Quantity__c){
                    List<ASI_MFM_RequestItem_UserAssignment__c> tmpList =  new List<ASI_MFM_RequestItem_UserAssignment__c>(item.Request_Item_User_Assignments__r);
                    ASI_MFM_RequestItem_UserAssignment__c firstUa = tmpList.remove(0);
                    firstUa.ASI_MFM_Qty__c = item.ASI_MFM_Quantity__c;
                    updateUaList.add(firstUa);
                    deleteUaList.addAll(tmpList);
                }
            }
            if(warehouseIdset.size()>1) return new ResultObj(false, '不允许提交多仓库项目, 请先清除购物车。');
            if(fromWH_UserAssignmentNeeded && isToRegionalWH && !assignmentCoutPass) return new ResultObj(false, '分配数量不吻合。'); 
            if(lineItemID.size()>0) 
            {
                List<Approval.ProcessSubmitRequest> lineItm_req = new List<Approval.ProcessSubmitRequest>();
                for(ID objID : lineItemID){
                    Approval.ProcessSubmitRequest tmp = new Approval.ProcessSubmitRequest();
                    tmp.setObjectId(objID);
                    lineItm_req.add(tmp);
                }
                
                List<Approval.ProcessResult> lineItm_result = Approval.process(lineItm_req);  
                for(Approval.ProcessResult obj : lineItm_result){
                    if (!obj.isSuccess()) {
                        return null;
                    }
                }
            }
            freeGoodsReq.RecordTypeId = CART_RO_ID;
            update reqItemList;
            update freeGoodsReq;
            if(updateUaList.size()>0) update updateUaList;
            if(deleteUaList.size()>0) delete deleteUaList;
            
            /*
            freeGoodsReq.ASI_FOC_Request_Status__c = 'Approved by Logistic';
            freeGoodsReq.ASI_FOC_Sys_Approved_By_Logistic__c = true;
            freeGoodsReq.ASI_FOC_Sys_Submitted__c = true;
            update freeGoodsReq;
            
            if(lineItemID.size()==0) 
            {
                List<Approval.ProcessSubmitRequest> header_req = new List<Approval.ProcessSubmitRequest>();
                
                Approval.ProcessSubmitRequest tmp_header_req = new Approval.ProcessSubmitRequest();
                tmp_header_req.setObjectId(freeGoodsReq.id);
                header_req.add(tmp_header_req);
                
                List<Approval.ProcessResult> header_result = Approval.process(header_req);  
                for(Approval.ProcessResult obj : header_result){
                    if (!obj.isSuccess()) {
                        return null;
                    }
                }
            }
			*/
            
            return new ResultObj(true, 'success');
        } catch(Exception e) {
            Database.rollback( sp );
            system.debug(e);
            return new ResultObj(false, e.getMessage()+'|||'+e.getLineNumber());
        }
    }
    
    @TestVisible
    Public class LotObject {
    	public Integer qty;
        public String reqItemId;
        public String cloneFromId;
        public Boolean userAssignmentNeed;
        public List<Map<String,Object>> userAssignment;
    }
    /*
    @TestVisible 
    class SubmitData {
        private Map<String, Object> dataMap;
        public SubmitData(Map<String, Object> inputData){
            dataMap = inputData;
        }
        public String getStr(String key) {
            return (dataMap.containsKey(key)) ? String.valueOf(dataMap.get(key)):'';
        }
        public Integer getInt(String key) {
            return (dataMap.containsKey(key)) ? Integer.valueOf(dataMap.get(key)):0;
        }
    }
    */
    @TestVisible
    class ResultObj {
    	public String message;
        public Boolean success;
        public Object debug;
        
        public List<ASI_FOC_Request_Item__c> updatedItemList;
        public List<ASI_MFM_Expense_Control_Form__c> purposeList;
        public Map<String,String> categoryMap;
        public Map<String,String> purposeMap;
        public Map<String,String> addValueServiceMap;
        public Map<String,String> timeMap;
        public Map<String,String> flowItemMap;
        public Set<String> provinceList;
        public Set<String> cityList;
        public Map<String,Set<String>> cityMap;
        public Map<String,ASI_CRM_City__c> cityDetailMap;
        public List<String> outletNameList;
        public Map<String,ASI_CRM_AccountsAdditionalField__c> outletMap;        
        
		public List<String> officeNameList;
        public List<String> whNameList;
        public Map<String,ASI_FOC_Warehouse__c> whMap;
        public Map<String,ASI_FOC_Warehouse__c> officeMap;
        public ASI_FOC_Warehouse__c dummyWh;
        
        public ResultObj(Boolean b, String m){
            message = m;
            success = b;
        }
    }
    
    //-------- end shopping cart ----------

    //-------- start config data ----------
    @RemoteAction 
    Public Static ResultObj retrieveConfig() {
        try{
            
            //Enoch@Introv @20200115 New picklist request category
            Map<String,String> categoryMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResultReqCate = ASI_FOC_Free_Goods_Request__c.ASI_MFM_Request_Category__c.getDescribe();
            List<Schema.PicklistEntry> pleReqCate = fieldResultReqCate.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : pleReqCate){
                if(pickListVal.getValue().contains('ASI_MFM_CN')) categoryMap.put(pickListVal.getValue(),pickListVal.getLabel());
            }
            
            
            List<ASI_MFM_Expense_Control_Form__c> purposeList = [SELECT id,name, ASI_MFM_Tax_Saving_Purpose__c, ASI_MFM_ChineseDescription__c
                                                                 FROM ASI_MFM_Expense_Control_Form__c
                                                                 WHERE recordTypeId = :EXP_CONTROL_ID
                                                                 AND ASI_MFM_ForPOSMCart__c = true];
			/*
            Map<String,String> purposeMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = ASI_FOC_Free_Goods_Request__c.ASI_FOC_Purpose__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                //purposeMap.put(pickListVal.getValue(),pickListVal.getLabel());
                purposeMap.put(pickListVal.getLabel(),pickListVal.getValue());
            }
            */
            //20200716 edit by Leo Jing BLS Start
            // Map<String,String> addValueServiceMap = new Map<String,String>();
            // Schema.DescribeFieldResult fieldResultAVS = ASI_FOC_Free_Goods_Request__c.ASI_MFM_Add_Value_Service__c.getDescribe();
            // List<Schema.PicklistEntry> pleAVS = fieldResultAVS.getPicklistValues();
            // for( Schema.PicklistEntry pickListVal : pleAVS){
            //     addValueServiceMap.put(pickListVal.getValue(),pickListVal.getLabel());
            // }           
            Map<String,String> addValueServiceMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResultAVS = ASI_FOC_Free_Goods_Request__c.ASI_MFM_Add_ValueSet_Service__c.getDescribe();
            List<Schema.PicklistEntry> pleAVS = fieldResultAVS.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : pleAVS){
                addValueServiceMap.put(pickListVal.getValue(),pickListVal.getLabel());
            }
            //20200716 edit by Leo Jing BLS end
            Map<String,String> timeMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResultTime = ASI_FOC_Free_Goods_Request__c.ASI_MFM_DeliveryTime__c.getDescribe();
            List<Schema.PicklistEntry> pleTime = fieldResultTime.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : pleTime){
                timeMap.put(pickListVal.getLabel(),pickListVal.getValue());
            }
            
            Map<String,String> flowItemMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResultFlowitem = ASI_MFM_Item_Group__c.ASI_MFM_CN_FlowItem__c.getDescribe();
            List<Schema.PicklistEntry> pleFitem = fieldResultFlowitem.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : pleFitem){
                flowItemMap.put(pickListVal.getLabel(),pickListVal.getValue());
            }
            
            ResultObj config = new ResultObj(true,'success');
			//config.purposeMap = purposeMap;
			config.categoryMap = categoryMap;
			config.timeMap = timeMap;
			config.flowItemMap = flowItemMap;
            config.purposeList=purposeList;
            config.addValueServiceMap = addValueServiceMap;
            return config;
        } catch (Exception e) {
            return new ResultObj(false,e.getMessage());
        }
    }
    @RemoteAction
    Public Static List<ASI_FOC_Delivery_Zone__c> retrieveDeliveryZone(String fromId, String toId) {
        if(fromId == null || fromId == '') return new List<ASI_FOC_Delivery_Zone__c>();
        if(toId == null || toId == '') return new List<ASI_FOC_Delivery_Zone__c>();
        return [SELECT id, name, ASI_MFM_TotalLeadTime__c, ASI_MFM_OutStorageTime__c, ASI_MFM_TransportTime__c, ASI_FOC_City_From__c,ASI_FOC_City_From__r.name, ASI_FOC_City_To__c,ASI_FOC_City_To__r.name
                FROM ASI_FOC_Delivery_Zone__c
                WHERE recordtypeId = :DELIVERYZONE_ID 
                AND ASI_FOC_City_From__c = :fromId AND ASI_FOC_City_To__c = :toId 
                ORDER BY ASI_MFM_TotalLeadTime__c desc];
    }
	@RemoteAction
    Public Static List<ASI_FOC_Delivery_Zone__c> retrieveDeliveryZoneMap() {
        return new List<ASI_FOC_Delivery_Zone__c>();
/*
        return [SELECT id, name, ASI_MFM_TotalLeadTime__c, ASI_MFM_OutStorageTime__c, ASI_MFM_TransportTime__c, ASI_FOC_City_From__c,ASI_FOC_City_From__r.name, ASI_FOC_City_To__c,ASI_FOC_City_To__r.name
                                                 FROM ASI_FOC_Delivery_Zone__c
                                                 WHERE recordtypeId = :DELIVERYZONE_ID];
*/
    }
    @RemoteAction
    Public Static ResultObj retrieveCity() {
        try{
            Id cityRTID = Global_recordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City');
            Set<String> citySet = new Set<String>();
            Map<String, Set<String>> cityMap = new Map<String, Set<String>>();
            Map<String, ASI_CRM_City__c> cityDetailMap = new Map<String, ASI_CRM_City__c>();
            List<ASI_CRM_City__c> cityList = [SELECT Id, name, ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c, ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name
                                              FROM ASI_CRM_City__c 
                                              WHERE RecordTypeId=:cityRTID];
            for(ASI_CRM_City__c city : cityList) {
                citySet.add(city.name);
                cityDetailMap.put(city.name,city);
                if(!cityMap.containsKey(city.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c)) cityMap.put(city.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c, new Set<String>());
                cityMap.get(city.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c).add(city.Name);
            }
            
            ResultObj config = new ResultObj(true,'success');
			config.provinceList = cityMap.keySet();
        	config.cityList = citySet;
            config.cityMap  = cityMap;
            config.cityDetailMap = cityDetailMap;
            return config;
        } catch(Exception e) {
            return new ResultObj(false,e.getMessage());
        }
    }
    @RemoteAction
    Public Static Map<String, ASI_MFM_PO__c> searchPo(String keyword) {
        String searchStr = keyword;
        Id poRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO');
        Id poroRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');
        List<String> excludeList = new List<String>{'Memo', 'Event Memo', 'Other Memo', 'IT Capex', 'IT Opex', 'IT Capex Hardware Region', 'IT Capex Hardware HQ', 'IT Capex Software', 'IT Capex Renovation'};
        Map<String, ASI_MFM_PO__c> resultMap = new Map<String, ASI_MFM_PO__c>();
        for(ASI_MFM_PO__c  po :[SELECT id, Name, ASI_MFM_PO_Type__c
                                FROM ASI_MFM_PO__c
                                WHERE (RecordTypeId = :poRTID OR RecordTypeId = :poroRTID)
                                AND ASI_MFM_Status__c = 'Final'
                                AND ASI_MFM_PO_Type__c NOT IN :excludeList
                                AND (Name = :searchStr)
                                ORDER BY Name LIMIT 1
                               ])
        {
            resultMap.put(po.Name, po);
        }
        return resultMap;
    }
    @RemoteAction
    Public Static Map<String, ASI_CRM_AccountsAdditionalField__c> searchOutlet(String keyword) {
        String searchStr = '%'+keyword+'%';
        Id customerRTID = Global_recordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        Id WSRTID = Global_recordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Map<String, ASI_CRM_AccountsAdditionalField__c> resultMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c u :[SELECT id, Name, ASI_CRM_CN_City_Name__c, ASI_CRM_CN_CCity__c,
                                                   ASI_CRM_CN_Contact_Person__c, ASI_CRM_CN_Phone_Number__c,
                                                   ASI_CRM_CN_Province__c, ASI_CRM_CN_Address__c, ASI_CRM_CN_Email__c
                                                   FROM ASI_CRM_AccountsAdditionalField__c 
                                                   WHERE (RecordTypeId = :customerRTID OR RecordTypeId = :WSRTID)
                                                   AND ASI_CRM_CN_Inactive_Flag__c=false 
                                                   AND ASI_CRM_CN_Competitor_Outlet__c=false
                                                   AND ASI_CRM_CN_Dummy_Outlet_Flag__c=false 
                                                   AND (Name LIKE :searchStr)
                                                   ORDER BY Name LIMIT 10
                                                  ])
        {
            resultMap.put(u.Name, u);
        }
        return resultMap;
    }
    @RemoteAction
    Public Static Map<String, Account> searchAgency(String keyword) {
        String searchStr = '%'+keyword+'%';
        Map<String, Account> resultMap = new Map<String, Account>();
        for(Account u :[SELECT id, Name, Phone, ASI_MFM_Address_Line_1__c, ASI_MFM_Address_Line_2__c
                        , ASI_MFM_City__c, ASI_MFM_Customer_Supplier_Name__c, ASI_LUX_Email_Business__c
                        FROM Account 
                        WHERE (RecordType.DeveloperName = 'ASI_MFM_CN_Supplier')
                        AND ASI_HK_CRM_Inactive__c = false
                        AND (Name LIKE :searchStr)
                        ORDER BY Name LIMIT 10])
        {
			resultMap.put(u.Name,u);
        }
            
        return resultMap;
    }
	@RemoteAction
    Public Static ResultObj retrieveOutlet() {
        try{
            Id customerRTID = Global_recordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            Id WSRTID = Global_recordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
            List<ASI_CRM_AccountsAdditionalField__c> custList = [SELECT id, name, ASI_CRM_CN_City_Name__c, ASI_CRM_CN_CCity__c,
                                                                 ASI_CRM_CN_Contact_Person__c, ASI_CRM_CN_Phone_Number__c,
                                                                 ASI_CRM_CN_Province__c, ASI_CRM_CN_Address__c, ASI_CRM_CN_Email__c
                                                                 FROM ASI_CRM_AccountsAdditionalField__c 
                                                                 WHERE (RecordTypeId = :customerRTID OR RecordTypeId = :WSRTID)
                                                                 AND ASI_CRM_CN_Inactive_Flag__c=false 
                                                                 AND ASI_CRM_CN_Competitor_Outlet__c=false
                                                                 AND ASI_CRM_CN_Dummy_Outlet_Flag__c=false 
                                                                 //AND (ASI_CRM_CN_JDE_Code__c!='' or ASI_CRM_CN_JDE_Code_Premium__c!='' or ASI_CRM_CN_JDE_Code_RTD__c!='')
                                                                 ];
            List<String> outletNameList = new List<String>();
            Map<String,ASI_CRM_AccountsAdditionalField__c> outletMap = new Map<String,ASI_CRM_AccountsAdditionalField__c>();
            for(ASI_CRM_AccountsAdditionalField__c cust:custList){
                outletNameList.add(cust.name);
                outletMap.put(cust.name,cust);
            }
            ResultObj  config = new ResultObj(true,'success');
            config.outletNameList = outletNameList;
            config.outletMap = outletMap;
            return config;
        } catch(Exception e) {
            return new ResultObj(false,e.getMessage());
        }
    }
    @RemoteAction
    Public Static ResultObj retrieveWarehouseDetail() {
        try{
            List<ASI_FOC_Warehouse__c> warehouseList = [SELECT id, name, ASI_FOC_Warehouse_Code__c,ASI_MFM_User_Assignment_Needed__c,ASI_MFM_Regional_Warehouse__c,
                                                        ASI_FOC_Contact__c, ASI_FOC_Phone_Number__c, ASI_MFM_POSM_Sequence__c, ASI_FOC_Warehouse_Type__c,
                                                        ASI_FOC_Warehouse_Address__c, ASI_FOC_City__r.name,  ASI_FOC_City__r.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c,
                                                        ASI_FOC_City__r.ASI_CRM_Province_Name__c, ASI_MFM_Direct_Delivery__c,
                                                        ASI_MFM_Operation_Team_Email_1__c, ASI_MFM_Operation_Team_Email_2__c, ASI_MFM_Operation_Team_Email_3__c, 
                                                        ASI_MFM_Operation_Team_Email_4__c, ASI_MFM_Operation_Team_Email_5__c, ASI_MFM_Operation_Team_Email_6__c, 
                                                        ASI_MFM_Operation_Team_Email_7__c, ASI_MFM_Operation_Team_Email_8__c, 
                                                        ASI_FOC_SIR_Email_Address_1__c, ASI_FOC_SIR_Email_Address_2__c, ASI_FOC_SIR_Email_Address_3__c, 
                                                        ASI_FOC_SIR_Email_Address_4__c, ASI_FOC_SIR_Email_Address_5__c, ASI_FOC_SIR_Email_Address_6__c, 
                                                        ASI_FOC_SIR_Email_Address_7__c, ASI_FOC_SIR_Email_Address_8__c
                                                        FROM ASI_FOC_Warehouse__c 
                                                        WHERE RecordTypeId=:WAREHOUSE_ID 
                                                        AND ASI_FOC_Warehouse_Type__c != 'In Transit'
                                                        AND ASI_MFM_Is_Active__c = true
                                                        //AND ASI_MFM_Direct_Delivery__c = false
                                                       ];
            List<String> whNameList = new List<String>();
            Map<String,ASI_FOC_Warehouse__c> whMap = new Map<String,ASI_FOC_Warehouse__c>();
            List<String> officeNameList = new List<String>();
            Map<String,ASI_FOC_Warehouse__c> officeMap = new Map<String,ASI_FOC_Warehouse__c>();
            ASI_FOC_Warehouse__c dummyWh;
            for(ASI_FOC_Warehouse__c wh : warehouseList){
                String whName = wh.name+' - '+wh.ASI_FOC_Warehouse_Code__c;

				if(wh.ASI_FOC_Warehouse_Type__c != null && wh.ASI_FOC_Warehouse_Type__c.toLowerCase() == 'dummy warehouse') {
                    if(wh.ASI_FOC_Warehouse_Code__c.toLowerCase() == 'dummy') {
                        dummyWh = wh;
                    } else {
                        officeMap.put(whName,wh);
                    	officeNameList.add(whName);
                    }
                } else {
                    whNameList.add(whName);
	                whMap.put(whName,wh);
                }
            }
            ResultObj  config = new ResultObj(true,'success');
            config.whNameList = whNameList;
            config.whMap = whMap;
            config.officeNameList = officeNameList;
            config.officeMap = officeMap;
            config.dummyWh = dummyWh;
            return config;
        } catch (Exception e) {
            return new ResultObj(false,e.getMessage());
        }
        
    }
    //-------- end config data ----------
    //-------- start item data ----------
    @RemoteAction
    Public Static Map<String, Object> retrieveItemDetails(List<Id> itemId) {
        return retrieveItemDetailsFunc(itemId, true);
    }
    @RemoteAction
    Public Static Map<String, Object> retrieveItemDetailsOfCart(List<Id> itemId) {
        return retrieveItemDetailsFunc(itemId, false);
    }

    Static Map<String, Object> retrieveItemDetailsFunc(List<Id> itemId, Boolean withSKU) {
        Map<String,Object> tmpResult = new Map<String,Object>();
        Map<Id,ASI_MFM_Item_Group__c> itemMap = new Map<Id,ASI_MFM_Item_Group__c>([SELECT Id, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c
                                                                                    ,ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c
                                                                                    ,ASI_MFM_Sub_brand__r.ASI_CRM_CN_CHI_NAME_C__c
                                                                                    ,ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c
                                                                                    ,ASI_MFM_Category_Level_1__r.ASI_CRM_CN_Chinese_Name__c
                                                                                    ,ASI_MFM_Category_Level_2__r.ASI_CRM_CN_Chinese_Name__c
                                                                                    ,ASI_MFM_Category_Level_3__r.ASI_CRM_CN_Chinese_Name__c
                                                                                    ,ASI_MFM_Length__c, ASI_MFM_Height__c, ASI_MFM_Width__c
                                                                                    ,ASI_MFM_Size__c, ASI_MFM_Reference_Unit_Price__c, ASI_MFM_Unit__c
                                                                                    ,ASI_MFM_Item_Group_Code__c, ASI_MFM_Utilization_Status__c
                                                                                    ,ASI_MFM_Weight__c, ASI_MFM_Importation__c
                                                                                    ,ASI_MFM_Usage__c, ASI_MFM_Main_Channel__c, ASI_MFM_Item_Group_Remark__c
                                                                                    ,ASI_MFM_Bundle_Item_Group__c, ASI_MFM_Channel__c
                                                                                    ,(SELECT Id, ASI_Image_URL__c, ASI_MFM_Image_URL_720_480__c, ASI_Image_URL_240_180__c, ASI_File_Name__c, ASI_FileID__c
                                                                                        FROM Product_Warehouse_Photos__r WHERE RecordType.developerName Like 'ASI_MFM_CN_POSM_Photo'
                                                                                        ORDER BY CreatedDate DESC Limit 5)
                                                                                    ,(SELECT id, name, ASI_MFM_SKU_Code__c, ASI_FOC_Unit_Cost__c
                                                                                        FROM SKUs__r
                                                                                        WHERE recordTypeId = :POSMSKU_ID)
                                                                                    FROM ASI_MFM_Item_Group__c
                                                                                    WHERE recordTypeId = :ITEMGROUP_RECORDTYPE_ID
                                                                                    AND Id IN :itemId
                                                                                    AND ASI_MFM_Utilization_Status__c LIKE 'Active'
                                                                                    AND ASI_CRM_CN_Hidden__c = FALSE]);
        tmpResult.put('itemMap',itemMap);
        if(withSKU) {
            Map<Id, Map<Id,ASI_MFM_Inventory_Balance__c>> invBalancesMapBySKU = new Map<Id, Map<Id,ASI_MFM_Inventory_Balance__c>>();
            for(ASI_MFM_Inventory_Balance__c balance : [SELECT id, name, ASI_MFM_SKU__c, ASI_MFM_Warehouse__c, ASI_MFM_Warehouse__r.Name, ASI_MFM_Warehouse__r.ASI_MFM_User_Assignment_Needed__c, ASI_MFM_Warehouse__r.ASI_MFM_Regional_Warehouse__c 
                                                        ,(SELECT id, Name, ASI_MFM_CN_SFDC_RemainQty__c, ASI_MFM_SFDCAvailableQuantity__c,ASI_MFM_SFDCOwner__c,ASI_MFM_SFDCOwner__r.Name FROM Inventory_Balance_Details__r)
                                                        FROM ASI_MFM_Inventory_Balance__c 
                                                        WHERE recordTypeId = :INV_BALANCE_ID
                                                        AND ASI_MFM_SKU__r.ASI_MFM_Item_Group__c IN :itemMap.keySet()]) {
                                                            if(!invBalancesMapBySKU.containsKey(balance.ASI_MFM_SKU__c)) {
                                                                invBalancesMapBySKU.put(balance.ASI_MFM_SKU__c,new Map<Id,ASI_MFM_Inventory_Balance__c>());
                                                            }
                                                            invBalancesMapBySKU.get(balance.ASI_MFM_SKU__c).put(balance.Id, balance);
                                                        }
            tmpResult.put('skuMap',invBalancesMapBySKU);
        }
        Map<String,Decimal> mapOrderQty = new Map<String,Decimal>();
/*        
        Date lastMonth = system.today().addMonths(-3);
        // Need to update status set for qty calaulation double confirm order have sharing rule
        Set<String> statusSet = new Set<String>{'Open','Submitted'};
        List<AggregateResult> reqList = [SELECT ASI_MFM_ItemGroup__c, sum(ASI_MFM_Quantity__c) sumQty
                                         FROM ASI_FOC_Request_Item__c
                                         WHERE recordtypeId = :CART_ITEM_ID 
                                         AND ASI_MFM_ItemGroup__c IN :itemId
                                         AND ASI_FOC_Request_Order__r.ASI_MFM_SubmitDate__c >= :lastMonth
                                         AND ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c IN :statusSet
                                         GROUP BY ASI_MFM_ItemGroup__c];
        
        for(AggregateResult ar : reqList){
            if(ar.get('ASI_MFM_ItemGroup__c')!=null && ar.get('ASI_MFM_ItemGroup__c')!='')
                mapOrderQty.put((String)ar.get('ASI_MFM_ItemGroup__c'),(Decimal)ar.get('sumQty'));
        }
*/
        tmpResult.put('orderQtyMap',mapOrderQty);
        return tmpResult;
    }
    
    //-------- end item detail ----------
    @RemoteAction
    Public Static Map<String, Object> retrieveAllItemLabel(){
        Map<String, String> tmpMap = new Map<String, String>();
        List<ASI_MFM_Item_Group__c> itemGroupList = [SELECT Id, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c,ASI_MFM_Item_Group_Code__c
                                                     FROM ASI_MFM_Item_Group__c 
                                                     WHERE RecordTypeId=:ITEMGROUP_RECORDTYPE_ID 
                                                     AND ASI_MFM_Utilization_Status__c Like 'Active'
                                                     AND ASI_CRM_CN_Hidden__c = FALSE
                                                     //to add // bundleItem = false
                                                    ];
        for(ASI_MFM_Item_Group__c item: itemGroupList){
            tmpMap.put(item.ASI_CRM_CN_Chinese_Name__c+'/'+item.ASI_CRM_CN_Eng_Name__c+'-'+item.ASI_MFM_Item_Group_Code__c,item.id);
        }
        return new Map<String, Object>{'itemMap'=>tmpMap,'pageSize'=>PAGE_SIZE};
    }
    
    @RemoteAction
    Public Static Map<String, Object> retrieveAllItemLabel2(){
        Map<String, String> tmpMap = new Map<String, String>();
        List<ASI_MFM_Inventory_Balance__c> itemGroupList = [SELECT Id, ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.Name, ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c, 
                                                     ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c,ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c
                                                     FROM ASI_MFM_Inventory_Balance__c 
                                                     WHERE RecordTypeId=:INV_BALANCE_ID
                                                     AND ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Utilization_Status__c Like 'Active'
                                                     AND ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Hidden__c = FALSE
                                                     AND ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.recordTypeId = :ITEMGROUP_RECORDTYPE_ID
                                                     //to add // bundleItem = false
                                                    ];
        for(ASI_MFM_Inventory_Balance__c item: itemGroupList){
            tmpMap.put(item.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c+'/'+item.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c+'-'+item.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c,item.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.id);
        }
        return new Map<String, Object>{'itemMap'=>tmpMap,'pageSize'=>PAGE_SIZE};
    }
    @RemoteAction
    Public Static Set<Id> filterItemIds2(String itemId, List<String> brandId, List<String> subbrandId, List<String> category1, List<String> category2, List<String> category3 
                                        ,List<String> channel, List<String> exlcusionBrandSet, String itemFroupDes
                                        ,List<String>itemIds, List<String>warehouseIds, Boolean haveInv, Integer ageMin, Integer ageMax, String flowitem, String oneTime){
        Set<Id> tmpItemSet = new Set<Id>();
		String soqlStr = 'SELECT count(id), ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__c itemgroup '
            + ' FROM ASI_MFM_InventoryBalanceDetail__c'
            + ' WHERE ASI_MFM_InventoryBalance__r.recordTypeId = :INV_BALANCE_ID'
            //+ ' AND ASI_MFM_Aging_in_Days__c >= :ageMin'
            + ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c IN :warehouseIds'
            + ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__c IN :itemIds'
            + ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.recordTypeId = :ITEMGROUP_RECORDTYPE_ID'
			+ ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Utilization_Status__c LIKE \'Active\''
            + ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Hidden__c = FALSE';
		
                                            
        //if(itemId!=null && itemId!='') {
            //soqlStr += ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__c = :itemId';
        //} else {
            if(itemId!=null && itemId!=''){
                soqlStr += ' AND (ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.Name LIKE \'%' + itemId + '%\'';
                soqlStr += ' OR ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c LIKE \'%' + itemId + '%\'';
                soqlStr += ' OR ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c LIKE \'%' + itemId + '%\'';
                soqlStr += ' OR ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c LIKE \'%' + itemId + '%\')';
            }
            if(ageMax!=null && ageMax>0 && ageMax>ageMin){
                soqlStr += ' AND ASI_MFM_Aging_in_Days__c < :ageMax';
            }
            if(ageMin!=null && ageMin > 0){//modify by BLS 2020-12-01
                soqlStr += ' AND ASI_MFM_Aging_in_Days__c >= :ageMin';
            }
            if(flowitem!=null) {
                if(flowitem!='YES' && flowitem!='NO') flowitem='NO';
                soqlStr += ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_CN_FlowItem__c = :flowitem';
            }
            if(oneTime!=null) {
                if(oneTime!='YES' && oneTime!='NO') oneTime='NO';
                soqlStr += ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_CN_OneTimeItem__c = :oneTime';
            }
                                            
            if(haveInv){
                soqlStr+=' AND ASI_MFM_CN_SFDC_RemainQty__c > 0';
                soqlStr+=' AND ASI_MFM_InventoryBalance__r.ASI_MFM_TotalSFDCAvailableQuantity__c > 0';
            } else {
                soqlStr+=' AND ASI_MFM_CN_SFDC_RemainQty__c = 0';
                soqlStr+=' AND ASI_MFM_InventoryBalance__r.ASI_MFM_TotalSFDCAvailableQuantity__c = 0';
            }
            if(category1.size() > 0){
                soqlStr += ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_1__c IN : category1';
            }
            
            if(category2.size() > 0){
                soqlStr += ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_2__c IN : category2';
            }
            
            if(category3.size() > 0){
                soqlStr += ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_3__c IN : category3';
            }
            
            if(channel.size() > 0){
                //------ edit by Andy Man @20181009 (start) ------
                // change to main channel filter
                //soqlStr += ' AND ASI_MFM_Channel__c IN : channel';
                soqlStr += getMainChannelSearchStrForIB(channel);
                //------ edit by Andy Man @20181009 (end) ------
            }
            
            if(subbrandId.size() > 0){
                
                soqlStr += ' AND ( ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Sub_brand__c IN : subbrandId OR (ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c IN : brandId AND ( ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c NOT IN : exlcusionBrandSet)))';
                
            }else if(brandId.size() > 0 && subbrandId.size() == 0){
                
                soqlStr += ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c IN : brandId';
            }
            
            if(string.isNotBlank(itemFroupDes)){
                soqlStr += ' AND (ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Remark__c LIKE \'%' + itemFroupDes + '%\' OR ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Description__c  LIKE \'%' + itemFroupDes + '%\')';
            }
        //}
		soqlStr += ' GROUP BY ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__c';
                                            system.debug(soqlStr);
        for(AggregateResult ar : database.query(soqlStr)){
            if(ar.get('itemgroup')!=null && ar.get('itemgroup')!='')
                tmpItemSet.add((Id)ar.get('itemgroup'));
        }
		return tmpItemSet;
    }
    
    @RemoteAction
    Public Static Set<Id> filterItemIds(String itemId, List<String> brandId, List<String> subbrandId, List<String> category1, List<String> category2, List<String> category3, List<String> channel, List<String> exlcusionBrandSet, String itemFroupDes){
        Set<Id> tmpItemSet = new Set<Id>();
        String soqlStr = 'SELECT Id'
            + ' FROM ASI_MFM_Item_Group__c'
            + ' WHERE recordTypeId = : ITEMGROUP_RECORDTYPE_ID'
            + ' AND ASI_MFM_Utilization_Status__c LIKE \'Active\''
            + ' AND ASI_CRM_CN_Hidden__c = FALSE';
        //to add // bundleItem = false
        
        if(itemId!=null && itemId!='') {
            soqlStr += ' AND Id = :itemId';
        } else {
            if(category1.size() > 0){
                soqlStr += ' AND ASI_MFM_Category_Level_1__c IN : category1';
            }
            
            if(category2.size() > 0){
                soqlStr += ' AND ASI_MFM_Category_Level_2__c IN : category2';
            }
            
            if(category3.size() > 0){
                soqlStr += ' AND ASI_MFM_Category_Level_3__c IN : category3';
            }
            
            if(channel.size() > 0){
                //------ edit by Andy Man @20181009 (start) ------
                // change to main channel filter
                //soqlStr += ' AND ASI_MFM_Channel__c IN : channel';
                soqlStr += getMainChannelSearchStr(channel);
                //------ edit by Andy Man @20181009 (end) ------
            }
            
            if(subbrandId.size() > 0){
                
                soqlStr += ' AND ( ASI_MFM_Sub_brand__c IN : subbrandId OR (ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c IN : brandId AND ( ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c NOT IN : exlcusionBrandSet)))';
                
            }else if(brandId.size() > 0 && subbrandId.size() == 0){
                
                soqlStr += ' AND ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c IN : brandId';
            }
            
            if(string.isNotBlank(itemFroupDes)){
                soqlStr += ' AND (ASI_MFM_Item_Group_Remark__c LIKE \'%' + itemFroupDes + '%\' OR ASI_MFM_Item_Group_Description__c  LIKE \'%' + itemFroupDes + '%\')';
            }
        }
        for(ASI_MFM_Item_Group__c itemGroup : database.query(soqlStr)){
            tmpItemSet.add(itemGroup.Id);
        }
        return tmpItemSet;
    }
    @RemoteAction
    Public Static Integer pageCount(String itemId, List<String> brandId, List<String> subbrandId, List<String> category1, List<String> category2, List<String> category3, List<String> channel, List<String> exlcusionBrandSet, String itemFroupDes){
        
        String soqlStr = 'SELECT count()'
            + ' FROM ASI_MFM_Item_Group__c'
            + ' WHERE recordTypeId = : ITEMGROUP_RECORDTYPE_ID'
            + ' AND ASI_MFM_Utilization_Status__c LIKE \'Active\''
            + ' AND ASI_CRM_CN_Hidden__c = FALSE';
        //to add // bundleItem = false
        
        if(itemId!=null && itemId!='') {
            soqlStr += ' AND Id = :itemId';
        } else {
            if(category1.size() > 0){
                soqlStr += ' AND ASI_MFM_Category_Level_1__c IN : category1';
            }
            
            if(category2.size() > 0){
                soqlStr += ' AND ASI_MFM_Category_Level_2__c IN : category2';
            }
            
            if(category3.size() > 0){
                soqlStr += ' AND ASI_MFM_Category_Level_3__c IN : category3';
            }
            
            if(channel.size() > 0){
                //------ edit by Andy Man @20181009 (start) ------
                // change to main channel filter
                //soqlStr += ' AND ASI_MFM_Channel__c IN : channel';
                soqlStr += getMainChannelSearchStr(channel);
                //------ edit by Andy Man @20181009 (end) ------
            }
            
            if(subbrandId.size() > 0){
                
                soqlStr += ' AND ( ASI_MFM_Sub_brand__c IN : subbrandId OR (ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c IN : brandId AND ( ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c NOT IN : exlcusionBrandSet)))';
                
            }else if(brandId.size() > 0 && subbrandId.size() == 0){
                
                soqlStr += ' AND ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c IN : brandId';
            }
            
            if(string.isNotBlank(itemFroupDes)){
                soqlStr += ' AND (ASI_MFM_Item_Group_Remark__c LIKE \'%' + itemFroupDes + '%\' OR ASI_MFM_Item_Group_Description__c  LIKE \'%' + itemFroupDes + '%\')';
            }
        }
        system.debug('##page count');
        system.debug('## sql ' + soqlStr);
        return database.countQuery(soqlStr);
    }
    
    @RemoteAction
    Public Static Map<String, ASI_MFM_Brand__c> retrieveAllBrands(){
        
        Map<String, ASI_MFM_Brand__c> tmpMap = new Map<String, ASI_MFM_Brand__c>();
        
        for(ASI_MFM_Brand__c brand : [SELECT Id, Name, ASI_CRM_CN_Chinese_Name__c, ASI_HK_CRM_English_Name__c, ASI_MFM_Active_for_POSM__c,ASI_MFM_ForPOSMCart__c FROM ASI_MFM_Brand__c 
                                      WHERE recordTypeId = : BRAND_RECORDTYPE_ID 
                                      AND ASI_CRM_CN_Competitor__c = False 
                                      AND ASI_MFM_Active_for_POSM__c = True
                                      ORDER BY ASI_MFM_POSM_Sequence__c]){
/*
            if(String.isNotBlank(brand.ASI_CRM_CN_Chinese_Name__c))
                tmpMap.put(brand.id, brand.ASI_CRM_CN_Chinese_Name__c);
            else if(String.isNotBlank(brand.ASI_HK_CRM_English_Name__c))
                tmpMap.put(brand.id, brand.ASI_HK_CRM_English_Name__c);
            else
                tmpMap.put(brand.id, brand.Name);
*/
			tmpMap.put(brand.id, brand);
        }
        
        Return tmpMap;
    }
    
    @RemoteAction
    Public Static Map<String, ASI_MFM_Sub_brand__c> retrieveAllSubBrands(){
        
        Map<String, ASI_MFM_Sub_brand__c> tmpMap = new Map<String, ASI_MFM_Sub_brand__c>();
        
        for(ASI_MFM_Sub_brand__c subbrand : [SELECT Id, ASI_MFM_Brand__c, Name, ASI_HK_CRM_English_Name__c, ASI_CRM_CN_CHI_NAME_C__c FROM ASI_MFM_Sub_brand__c 
                                             WHERE recordTypeId = : SUB_BRAND_RECORDTYPE_ID AND ASI_MFM_Active_for_POSM__c = True]){
            
            if(String.isNotBlank(subbrand.ASI_CRM_CN_CHI_NAME_C__c)){
                
                subbrand.Name = subbrand.ASI_CRM_CN_CHI_NAME_C__c;
                tmpMap.put(subbrand.id, subbrand);
            }else if(String.isNotBlank(subbrand.ASI_HK_CRM_English_Name__c)){
                
                subbrand.Name = subbrand.ASI_HK_CRM_English_Name__c;
                tmpMap.put(subbrand.id, subbrand);
            }else
                tmpMap.put(subbrand.id, subbrand);
        }
        
        Return tmpMap;
    }
    
    @RemoteAction
    Public Static Map<String, ASI_HK_CRM_Product_Category__c> retrieveAllCategories(){
        
        Map<String, ASI_HK_CRM_Product_Category__c> tmpMap = new Map<String, ASI_HK_CRM_Product_Category__c>();
        
        for(ASI_HK_CRM_Product_Category__c category : [SELECT Id, Name, ASI_HK_CRM_English_Name__c
                                                       , ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Level__c
                                                       , (SELECT Id, ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_English_Name__c, ASI_MFM_Category_Level_2_3__c
                                                       , ASI_CRM_CN_Product_Category__r.ASI_CRM_CN_Chinese_Name__c, ASI_CRM_CN_Product_Category__r.ASI_MFM_Level__c FROM Sub_categories__r )
                                                       FROM ASI_HK_CRM_Product_Category__c 
                                                       WHERE recordTypeId = : CATEGORY_RECORDTYPE_ID
                                                       ORDER By ASI_MFM_Level__c]){
            
            if(String.isNotBlank(category.ASI_CRM_CN_Chinese_Name__c)){
                
                category.Name = category.ASI_CRM_CN_Chinese_Name__c;
                
            }else if(String.isNotBlank(category.ASI_HK_CRM_English_Name__c)){
                
                category.Name = category.ASI_HK_CRM_English_Name__c;
            }
                                                           
			tmpMap.put(category.id, category);
        }
        
        Return tmpMap;
    }
    
    //------ edit by Andy Man @20181009 (start) ------ 
    // override retrieveAllChannels method
    @RemoteAction
    Public Static Map<String, String> retrieveAllChannels(){
        Map<String, String> tmpMap = new Map<String, String>();
        
        Schema.DescribeFieldResult chkList = ASI_MFM_Item_Group__c.ASI_MFM_Main_Channel__c.getDescribe();
        for (Schema.PicklistEntry chkValue : chkList.getPicklistValues())
        {
            tmpMap.put(chkValue.getValue(), chkValue.getLabel());
        }
        
        Return tmpMap;
    }
    
    /* backup@20181008
    @RemoteAction
    Private Static Map<String, String> retrieveAllChannels_bak(){
        
        Map<String, String> tmpMap = new Map<String, String>();
        
        for(ASI_CRM_CN_Channel__c channel : [SELECT Id, Name, ASI_CRM_CN_Channel_Eng_Name__c, ASI_CRM_CN_Channel_Chi_Name__c FROM ASI_CRM_CN_Channel__c   
                                                       WHERE recordTypeId = : CHANNEL_RECORDTYPE_ID]){
                                                           
            if(String.isNotBlank(channel.ASI_CRM_CN_Channel_Chi_Name__c))
                tmpMap.put(channel.id, channel.ASI_CRM_CN_Channel_Chi_Name__c);
            else if(String.isNotBlank(channel.ASI_CRM_CN_Channel_Eng_Name__c))
                tmpMap.put(channel.id, channel.ASI_CRM_CN_Channel_Eng_Name__c);
            else
                tmpMap.put(channel.id, channel.Name);
        }
        
        Return tmpMap;
    }
	*/
    
    // change to main channel filter
    Private Static String getMainChannelSearchStr(List<String> channelList)
    {
        String tmpSearch = '';
        
        if(channelList.size() > 0){
            for(String includeValue : channelList)
    			tmpSearch += ('\'' + includeValue + '\',');
			tmpSearch = ' AND ASI_MFM_Main_Channel__c INCLUDES (' + tmpSearch.removeEnd(',') +') ';
        }
        
        return tmpSearch;
    }
    Private Static String getMainChannelSearchStrForIB(List<String> channelList)
    {
        String tmpSearch = '';
        
        if(channelList.size() > 0){
            for(String includeValue : channelList)
    			tmpSearch += ('\'' + includeValue + '\',');
			tmpSearch = ' AND ASI_MFM_InventoryBalance__r.ASI_MFM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Main_Channel__c INCLUDES (' + tmpSearch.removeEnd(',') +') ';
        }
        
        return tmpSearch;
    }
    //------ edit by Andy Man @20181009 (end) ------
    
    //------ get sku inv detail ------
    //20200713 edit by Leo Jing BLS start.
    @RemoteAction
    Public Static Map<String, Map<String,ASI_MFM_Inventory_Balance__c>> retrieveInventory(List<string> itemid, Integer ageMin, Integer ageMax, List<string> warehouseIdList){
        Map<String, Map<String,ASI_MFM_Inventory_Balance__c>> tmpMap = new Map<String, Map<String,ASI_MFM_Inventory_Balance__c>>();
        String soqlStr = 'SELECT id, name, ASI_MFM_TotalSFDCAvailableQuantity__c, ASI_MFM_Warehouse__r.name, ASI_MFM_Warehouse__r.ASI_MFM_User_Assignment_Needed__c, ASI_MFM_Warehouse__r.ASI_MFM_Regional_Warehouse__c, ASI_MFM_Warehouse__r.ASI_FOC_City__c, ASI_MFM_Warehouse__r.ASI_FOC_City__r.Name, ASI_MFM_SKU__r.ASI_MFM_SKU_Code__c, ASI_MFM_SKU__r.ASI_MFM_Minimum_Packing_Qty__c, ASI_MFM_SKU__r.ASI_MFM_Minimum_Box_Qty__c '
                         +', ASI_MFM_SKU__r.ASI_MFM_Item_Group__c, ASI_MFM_Warehouse__c, ASI_MFM_SKU__r.ASI_MFM_Box_Net_Weight_KG__c, ASI_MFM_SKU__r.ASI_MFM_Minimum_Unit_PC_CA__c '
            			 +', ASI_MFM_Warehouse__r.ASI_MFM_Use_Min_Package_Unit__c '
                         +', ASI_MFM_Unit_Cost__c '
                         +',(SELECT id, Name, ASI_MFM_CN_SFDC_RemainQty__c, ASI_MFM_SFDCAvailableQuantity__c,ASI_MFM_SFDCOwner__c,ASI_MFM_SFDCOwner__r.Name FROM Inventory_Balance_Details__r WHERE id != null';
        if(ageMin!=null && ageMin>0) {//modify by BLS 2020-12-01
            soqlStr += ' AND ASI_MFM_Aging_in_Days__c >= :ageMin ';
        }
        if(ageMax!=null && ageMax>0 && ageMax>ageMin) {
            soqlStr += ' AND ASI_MFM_Aging_in_Days__c <:ageMax ';
        }
        soqlStr += ' AND ASI_MFM_CN_SFDC_RemainQty__c > 0 ORDER BY Name )';
        soqlStr += 'FROM ASI_MFM_Inventory_Balance__c WHERE recordTypeId = :INV_BALANCE_ID AND ASI_MFM_SKU__r.RecordTypeId = :POSMSKU_ID ';
		if(warehouseIdList!=null && warehouseIdList.size()>0) {
        	soqlStr += 'AND ASI_MFM_Warehouse__c IN :warehouseIdList ';
    	}

        if(itemid!=null && itemid.size()>0)soqlStr += 'AND ASI_MFM_SKU__r.ASI_MFM_Item_Group__c IN :itemid ';

        for(ASI_MFM_Inventory_Balance__c ib :database.query(soqlStr)) {
            if(!tmpMap.containsKey(ib.ASI_MFM_SKU__r.ASI_MFM_Item_Group__c)){
                tmpMap.put(ib.ASI_MFM_SKU__r.ASI_MFM_Item_Group__c, new Map<String,ASI_MFM_Inventory_Balance__c>());
            } 
			tmpMap.get(ib.ASI_MFM_SKU__r.ASI_MFM_Item_Group__c).put(ib.Id, ib);
        }
        return tmpMap;
    }
    //20200713 edit by Leo Jing BLS end.
    
    // --- get login user sec table ---
	@RemoteAction
    Public Static List<ASI_MFM_POSMCatalogSecCtrl__c> retrieveSecTable(){
        List<ASI_MFM_POSMCatalogSecCtrl__c> secList = [SELECT id, name, ASI_MFM_ItemGroup__c, ASI_MFM_Warehouse__c, ASI_MFM_Warehouse__r.Name, ASI_MFM_CanOrderinCatalog__c// ,ASI_MFM_Open_to_all_user__c
                                                       FROM ASI_MFM_POSMCatalogSecCtrl__c
                                                       WHERE recordTypeId = :SEC_RECORDTYPE_ID
                                                       AND (ASI_MFM_User__c = :UserInfo.getUserId() OR ASI_MFM_Open_to_all_user__c=true)
														];
        return secList;
    }
    
    @RemoteAction
    Public Static Map<String,List<ASI_MFM_POSMCatalogSecCtrl__c>> retrieveSecTableSeparate(){
        List<ASI_MFM_POSMCatalogSecCtrl__c> whList = [SELECT id, name, ASI_MFM_ItemGroup__c, ASI_MFM_Warehouse__c, ASI_MFM_Warehouse__r.Name, ASI_MFM_CanOrderinCatalog__c// ,ASI_MFM_Open_to_all_user__c
                                                       FROM ASI_MFM_POSMCatalogSecCtrl__c
                                                       WHERE recordTypeId = :SEC_RECORDTYPE_ID
                                                       AND ASI_MFM_Warehouse__c != null
                                                       AND ASI_MFM_MappingType__c = 'Warehouse - User'
                                                       AND ASI_MFM_User__c = :UserInfo.getUserId() 
														];
        Set<Id> warehouseIdSet = new Set<Id>();

        for(ASI_MFM_POSMCatalogSecCtrl__c whSec : whList) {if(whSec.ASI_MFM_CanOrderinCatalog__c=='Yes') warehouseIdSet.add(whSec.ASI_MFM_Warehouse__c);}
    
        List<ASI_MFM_POSMCatalogSecCtrl__c> itemList = [SELECT id, name, ASI_MFM_ItemGroup__c, ASI_MFM_Warehouse__c, ASI_MFM_Warehouse__r.Name, ASI_MFM_CanOrderinCatalog__c// ,ASI_MFM_Open_to_all_user__c
                                                       FROM ASI_MFM_POSMCatalogSecCtrl__c
                                                       WHERE recordTypeId = :SEC_RECORDTYPE_ID
                                                       AND ASI_MFM_ItemGroup__c != null
                                                       AND ASI_MFM_MappingType__c = 'Item Group - User'
                                                       AND ASI_MFM_User__c = :UserInfo.getUserId()
                                                       ];
        if (itemList.size() == 0) {
            for (ASI_MFM_InventoryBalanceDetail__c ibd :[SELECT id, ASI_MFM_ItemGroup__c 
                                                      FROM ASI_MFM_InventoryBalanceDetail__c
                                                     WHERE ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c IN :warehouseIdSet]) 
            {
                    itemList.add(new ASI_MFM_POSMCatalogSecCtrl__c(ASI_MFM_ItemGroup__c=ibd.ASI_MFM_ItemGroup__c, ASI_MFM_CanOrderinCatalog__c='Yes',recordTypeId=SEC_RECORDTYPE_ID ));
                
            }
        }
        
        return new Map<String,List<ASI_MFM_POSMCatalogSecCtrl__c>>{'whList'=>whList, 'itemList'=>itemList};
    }

    //------ add new security control by Alex BLS-- Inventory Owner ------
    @RemoteAction
    Public static Map<Id, Set<Id>> retrieveInventoryOwnerCtrl(){
        // add Alex BLS add inventory owner ctrl start 
        // if the configuration data indicates that only the inventoryOwner and his line manager can be seen in the item group of the warehouse, the corresponding owner is himself
        List<ASI_MFM_POSMCatalogSecCtrl__c> invOwnerList = [SELECT id, ASI_MFM_Inventory_Owner__c, ASI_MFM_Inventory_Owner__r.ManagerId, ASI_MFM_Warehouse__c, ASI_MFM_Warehouse__r.Name
                                                               FROM ASI_MFM_POSMCatalogSecCtrl__c
                                                               WHERE recordTypeId = :SEC_RECORDTYPE_ID
                                                               AND ASI_MFM_Warehouse__c != null
                                                               AND ASI_MFM_Inventory_Owner__c != null
                                                               AND ASI_MFM_MappingType__c = 'Inventory Owner - User'
                                                               AND ASI_MFM_Inventory_Owner__c != :UserInfo.getUserId()
                                                               AND ASI_MFM_Inventory_Owner__r.ManagerId != :UserInfo.getUserId()
                                                           ];
        Map<Id, Set<Id>> wareHouseInvOwnersMap = new Map<Id, Set<Id>>();
        for (ASI_MFM_POSMCatalogSecCtrl__c inOwner : invOwnerList) {
            if (!wareHouseInvOwnersMap.containsKey(inOwner.ASI_MFM_Warehouse__c)) {
                wareHouseInvOwnersMap.put(inOwner.ASI_MFM_Warehouse__c, new Set<Id>());
            }
            wareHouseInvOwnersMap.get(inOwner.ASI_MFM_Warehouse__c).add(inOwner.ASI_MFM_Inventory_Owner__c);
        }

        return wareHouseInvOwnersMap;
    }

    @RemoteAction
    Public Static Set<Id> retrieveAvailableItemGroup(){ 
        Set<Id> tmpSet = new Set<Id>();
        for(ASI_MFM_POSMCatalogSecCtrl__c sec : retrieveSecTable()){
            if(sec.ASI_MFM_ItemGroup__c!=null) tmpSet.add(sec.ASI_MFM_ItemGroup__c);
        }
        return tmpSet;
    }
    @RemoteAction
    Public Static Set<Id> retrieveAvailableWarehouse(){ 
        Set<Id> tmpSet = new Set<Id>();
        for(ASI_MFM_POSMCatalogSecCtrl__c sec : retrieveSecTable()){
            if(sec.ASI_MFM_Warehouse__c!=null) tmpSet.add(sec.ASI_MFM_Warehouse__c);
        }
        return tmpSet;
    }    

    @RemoteAction
    Public Static Map<String, ASI_MFM_Item_Group__c> retrieveAllPOSMItemGroup(Integer pageNumber){
        
        Return queryItemGroup(null, new List<String>(), new List<String>(), new List<String>(), new List<String>(), new List<String>(), new List<String>(), new List<String>(), '', pageNumber);
    }
    
    @RemoteAction
    Public Static Map<String, ASI_MFM_Item_Group__c> searchPOSMItemGroup(String itemId, List<String> brandId, List<String> subbrandId, List<String> category1, List<String> category2, List<String> category3, List<String> channel, List<String> exlcusionBrandSet, String itemFroupDes, Integer PageNumber){
        
        Return queryItemGroup(itemId, brandId, subbrandId, category1, category2, category3, channel, exlcusionBrandSet, itemFroupDes, PageNumber);
    }
    
    Private Static Map<String, ASI_MFM_Item_Group__c> queryItemGroup(String itemId, List<String> brandId, List<String> subbrandId, List<String> category1, List<String> category2, List<String> category3, List<String> channel, List<String> exlcusionBrandSet, String itemFroupDes, Integer PageNumber){
        
        Map<String, ASI_MFM_Item_Group__c> tmpMap = new Map<String, ASI_MFM_Item_Group__c>();
        String soqlStr = 'SELECT Id, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c'
            + ', ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c'
            + ', ASI_MFM_Sub_brand__r.ASI_CRM_CN_CHI_NAME_C__c'
            + ', ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c'
            + ', ASI_MFM_Category_Level_1__r.ASI_CRM_CN_Chinese_Name__c'
            + ', ASI_MFM_Category_Level_2__r.ASI_CRM_CN_Chinese_Name__c'
            + ', ASI_MFM_Category_Level_3__r.ASI_CRM_CN_Chinese_Name__c'
            + ', ASI_MFM_Length__c, ASI_MFM_Height__c, ASI_MFM_Width__c'
            + ', ASI_MFM_Size__c'
            + ', ASI_MFM_Item_Group_Code__c, ASI_MFM_Utilization_Status__c'
            + ', ASI_MFM_Weight__c, ASI_MFM_Importation__c'
            + ', ASI_MFM_Usage__c, ASI_MFM_Main_Channel__c, ASI_MFM_Item_Group_Remark__c'
            + ', ASI_MFM_Bundle_Item_Group__c, ASI_MFM_Channel__c'
            + ', (SELECT Id, ASI_Image_URL__c, ASI_MFM_Image_URL_720_480__c, ASI_Image_URL_240_180__c, ASI_File_Name__c, ASI_FileID__c'
            + ' FROM Product_Warehouse_Photos__r WHERE RecordTypeId = : POSM_IETMGROUP_PHOTO_RECORDTYPE_ID'
            + ' ORDER BY CreatedDate DESC Limit 5)'
            + ' FROM ASI_MFM_Item_Group__c'
            + ' WHERE recordTypeId = : ITEMGROUP_RECORDTYPE_ID'
            + ' AND ASI_MFM_Utilization_Status__c LIKE \'Active\''
            + ' AND ASI_CRM_CN_Hidden__c = FALSE';
        //to add // bundleItem = false
		
        if(itemId!=null && itemId!='') {
            soqlStr += ' AND Id = :itemId';
        } else {
            if(category1.size() > 0){
                soqlStr += ' AND ASI_MFM_Category_Level_1__c IN : category1';
            }
            
            if(category2.size() > 0){
                soqlStr += ' AND ASI_MFM_Category_Level_2__c IN : category2';
            }
            
            if(category3.size() > 0){
                soqlStr += ' AND ASI_MFM_Category_Level_3__c IN : category3';
            }
            
            if(channel.size() > 0){
                //------ edit by Andy Man @20181009 (start) ------
                // change to main channel filter
                //soqlStr += ' AND ASI_MFM_Channel__c IN : channel';
                soqlStr += getMainChannelSearchStr(channel);
                //------ edit by Andy Man @20181009 (end) ------
            }
            
            if(subbrandId.size() > 0){
                
                soqlStr += ' AND ( ASI_MFM_Sub_brand__c IN : subbrandId OR (ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c IN : brandId AND ( ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c NOT IN : exlcusionBrandSet)))';
                
            }else if(brandId.size() > 0 && subbrandId.size() == 0){
                
                soqlStr += ' AND ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c IN : brandId';
            }
            
            if(string.isNotBlank(itemFroupDes)){
                soqlStr += ' AND (ASI_MFM_Item_Group_Remark__c LIKE \'%' + itemFroupDes + '%\' OR ASI_MFM_Item_Group_Description__c  LIKE \'%' + itemFroupDes + '%\')';
            }
            
            soqlStr += ' LIMIT ' + PAGE_SIZE;
            soqlStr += ' OFFSET ' + PAGE_SIZE * (PageNumber > 0 ? PageNumber - 1 : 0);
        }
        for(ASI_MFM_Item_Group__c itemGroup : database.query(soqlStr)){
                                                           
            if(String.isNotBlank(itemGroup.ASI_CRM_CN_Chinese_Name__c))
                itemGroup.Name = itemGroup.ASI_CRM_CN_Chinese_Name__c;
            else if(String.isNotBlank(itemGroup.ASI_CRM_CN_Eng_Name__c))
                itemGroup.Name = itemGroup.ASI_CRM_CN_Eng_Name__c;
                                                           
			tmpMap.put(itemGroup.id, itemGroup);
        }
        Return tmpMap;
    }
}