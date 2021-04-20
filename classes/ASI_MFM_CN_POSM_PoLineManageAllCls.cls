global with sharing class ASI_MFM_CN_POSM_PoLineManageAllCls {
    public String posmItemListJson {get;set;}
    public String posmItemMapJson {get;set;}
    public String warehouseListJson {get;set;}
    public String warehouseMapJson {get;set;} 
    public Boolean poEditable {get;set;}
    public Boolean isOwner {get;set;} // 20201207 by HUJINCHAO-BLS
    public String poType {get;set;}
    
    public id pid {get; private set;}
    public ASI_MFM_PO__c PO {get;set;}
    public ASI_MFM_SKU_Code__c sku{get;set;}

    
    public ASI_MFM_CN_POSM_PoLineManageAllCls(){}
    public ASI_MFM_CN_POSM_PoLineManageAllCls(ApexPages.StandardController sc) {
        isOwner = false;
        sku = new ASI_MFM_SKU_Code__c();
        pid = apexpages.currentPage().getParameters().get('id');
        PO = [SELECT id,name,ASI_MFM_Status__c, ASI_MFM_PO_Type__c, OwnerId FROM ASI_MFM_PO__c WHERE id=:pid LIMIT 1];
        poType = PO.ASI_MFM_PO_Type__c;
        poEditable = (PO.ASI_MFM_Status__c=='Draft');
        if([select group.DeveloperName from GroupMember 
            where (group.DeveloperName LIKE 'ASI_MFM_CN_Procurement_User' OR group.DeveloperName LIKE 'ASI_FOC_CN_POSM_Logistic_Group') // Enoch@Introv 20191114 add user Group FOC Logistic Group
            and UserOrGroupId = :UserInfo.getUserId()].size() > 0) {
                poEditable = true;
            }
        /*
        if (UserInfo.getUserId() == PO.OwnerId && poType == 'eMarket' && [SELECT Id FROM ASI_MFM_Stock_In_Request__c WHERE ASI_MFM_PO_Number__c = :PO.Id].size() == 0) {
            poEditable = true;
        }
        */
        if (UserInfo.getUserId() == PO.OwnerId && poType == 'eMarket') { // 20201207 by HUJINCHAO-BLS Add authority to PO Owner
            poEditable = true;
            isOwner = true;
        }
        Map<String,ItemGroupObj> posmItemGroupMap = new Map<String,ItemGroupObj>();
        List<String> posmItemGroupNameList = new List<String>();
/*
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        List<ASI_MFM_Item_Group__c> itemGroupList = [SELECT Id,name,ASI_MFM_Minimum_Order_Qty__c,ASI_MFM_Item_Group_Code__c,ASI_MFM_Item_Group_Description__c,ASI_MFM_Reference_Unit_Price__c, ASI_MFM_Bundle_Item_Group__c 
                                                     FROM ASI_MFM_Item_Group__c 
                                                     WHERE RecordTypeId=:posmitemRTID 
                                                     AND ASI_MFM_Utilization_Status__c = 'Active'
                                                     AND ASI_CRM_CN_Hidden__c = false
                                                    ];
        for(ASI_MFM_Item_Group__c itemGroup : itemGroupList) {
            ItemGroupObj objItemGroup = new ItemGroupObj(itemGroup);
            posmItemGroupNameList.add(objItemGroup.name);
            posmItemGroupMap.put(objItemGroup.name, objItemGroup);
        }
*/
        posmItemListJson = JSON.serialize(posmItemGroupNameList);
        posmItemMapJson = JSON.serialize(posmItemGroupMap);

        
        Id warehouseRTID = Global_recordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
        List<ASI_FOC_Warehouse__c> warehouseList = [SELECT id, name, ASI_FOC_Warehouse_Code__c,
                                                    ASI_FOC_Contact__c, ASI_FOC_Phone_Number__c, 
                                                    ASI_FOC_Warehouse_Address__c, ASI_FOC_City__r.name,  ASI_FOC_City__r.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c,
                                                    ASI_FOC_City__r.ASI_CRM_Province_Name__c, ASI_MFM_Direct_Delivery__c,
                                                    ASI_MFM_Operation_Team_Email_1__c, ASI_MFM_Operation_Team_Email_2__c, ASI_MFM_Operation_Team_Email_3__c, 
                                                    ASI_MFM_Operation_Team_Email_4__c, ASI_MFM_Operation_Team_Email_5__c, ASI_MFM_Operation_Team_Email_6__c, 
                                                    ASI_MFM_Operation_Team_Email_7__c, ASI_MFM_Operation_Team_Email_8__c, 
                                                    ASI_FOC_SIR_Email_Address_1__c, ASI_FOC_SIR_Email_Address_2__c, ASI_FOC_SIR_Email_Address_3__c, 
                                                    ASI_FOC_SIR_Email_Address_4__c, ASI_FOC_SIR_Email_Address_5__c, ASI_FOC_SIR_Email_Address_6__c, 
                                                    ASI_FOC_SIR_Email_Address_7__c, ASI_FOC_SIR_Email_Address_8__c
                                                    FROM ASI_FOC_Warehouse__c 
                                                    WHERE RecordTypeId=:warehouseRTID];
        List<String> whNameList = new List<String>();
        Map<String,ASI_FOC_Warehouse__c> whMap = new Map<String,ASI_FOC_Warehouse__c>();
        for(ASI_FOC_Warehouse__c wh : warehouseList){
            String whName = wh.name+' - '+wh.ASI_FOC_Warehouse_Code__c;
            whNameList.add(whName);
            whMap.put(whName,wh);
        }
        warehouseListJson = JSON.serialize(whNameList);
        warehouseMapJson = JSON.serialize(whMap);

        //List<User> users = [SELECT Id,Name,Email FROM User WHERE IsActive = TRUE AND License_Type__c != 'Customer Community'];
    }
    
    @RemoteAction 
    global static ItemGroupObj getItemGroup(String itemId){
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        List<ASI_MFM_Item_Group__c> itemGroupList = [SELECT Id,name,ASI_MFM_Minimum_Order_Qty__c,ASI_MFM_Item_Group_Code__c
                                                     		,ASI_MFM_Item_Group_Description__c,ASI_MFM_Reference_Unit_Price__c
                                                     		, ASI_MFM_Bundle_Item_Group__c 
                                                     FROM ASI_MFM_Item_Group__c 
                                                     WHERE RecordTypeId=:posmitemRTID 
                                                     AND ASI_MFM_Utilization_Status__c = 'Active'
                                                     AND ASI_CRM_CN_Hidden__c = false
                                                     AND Id = :itemId
                                                    ];

        if(itemGroupList.size()>0) return new ItemGroupObj(itemGroupList[0]);
        return null;
    }
    
    @RemoteAction
    global static ResultObj sendTIV(String dataSet) {
    	Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
        List<Object> dataList = (List<Object>)dataMap.get('sirList');
        Id posmLineId = (Id)dataMap.get('posmLineId');
        Id poid = (Id)dataMap.get('poid');
        
        ASI_MFM_PO_POSM_Line__c posmline = [SELECT id,name,ASI_MFM_Send_SIR__c,ASI_MFM_Send_TIV__c
                                            FROM ASI_MFM_PO_POSM_Line__c
                                            WHERE id=:posmLineId
                                            LIMIT 1];
        if(posmline==null) {
            return new ResultObj(false, 'POSM Line Not Found : ' +posmLineId, null);
        }
        List<ASI_MFM_Stock_In_Request__c> sirList = new List<ASI_MFM_Stock_In_Request__c>();
        for(Object dataObj : dataList) {
            String jsonData = JSON.serialize(dataObj);
            SirObj sir = (SirObj)JSON.deserialize(jsonData, SirObj.class);
            
            //if(sir.id!=null && !sir.tivnotesent && sir.tivnum!=null && sir.tivnum!='') {            
            if(sir.id!=null && sir.tivnum!=null && sir.tivnum!='') { // Enoch@Introv 20191114 remove bool checking of tivnotesent
                if(sir.isSendEmail)
                {
                    sirList.add(new ASI_MFM_Stock_In_Request__c(
                    id=sir.id, 
                    ASI_MFM_TIV_Note_SentFlag__c = false,
                    ASI_MFM_TIV_Number__c=sir.tivnum));
                }
                else
                {
                    sirList.add(new ASI_MFM_Stock_In_Request__c(
                    id=sir.id, 
                    ASI_MFM_TIV_Number__c=sir.tivnum));
                }
               
               // ASI_MFM_Stock_In_Request__c newSir = new ASI_MFM_Stock_In_Request__c();
               // newSir.Id = sir.id;
               // newSir.ASI_MFM_TIV_Number__c = sir.tivnum;
              //  if(sir.isSendEmail)
              // {
              //   newSir.ASI_MFM_TIV_Note_SentFlag__c = false;
              // }
              // sirList.add(newSir);

            }
        }
        if(sirList.size()==0) {
            return new ResultObj(false, 'Please Input TIV Number.', null);
        }
        try{
            posmline.ASI_MFM_Send_TIV__c = true;
            posmline.ASI_MFM_Send_SIR__c = true; // add from send SIR function
            update sirList;
            update posmline;
           
        } catch(Exception e) {
            return new ResultObj(false, 'Fail To Send TIV', null);
        }
        
        try{
            for(ASI_MFM_Stock_In_Request__c sir :sirList) { sir.ASI_MFM_TIV_Note_Sent__c = true; }
            //update sirList;
        } catch(Exception e) {
            return new ResultObj(false, 'Fail To Update SIR Send Note', null);
        }
        
        return new ResultObj(true, 'success', getPosmLineList(poid));
    }

    @RemoteAction
    global static ResultObj sendSir(String dataSet) {
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
        Id posmLineId = (Id)dataMap.get('posmLineId');
        Id poid = (Id)dataMap.get('poid');
        ASI_MFM_PO_POSM_Line__c posmline = [SELECT id,name,ASI_MFM_Send_SIR__c
                                            FROM ASI_MFM_PO_POSM_Line__c
                                            WHERE id=:posmLineId
                                            LIMIT 1];
        //if(posmline.name == 'PPL-18000004') {
        //    return new ResultObj(false, 'Status Check Not Allow to send SIR : ' +posmLineId, null);
        //}
        if(posmline==null) {
            return new ResultObj(false, 'POSM Line Not Found : ' +posmLineId, null);
        }
        posmline.ASI_MFM_Send_SIR__c = true;
        update posmline;
        return new ResultObj(true, 'success', getPosmLineList(poid));
    }

    @RemoteAction
    global static ResultObj submit(String dataSet) {
        System.debug(LoggingLevel.INFO, '*** dataSet: ' + dataSet);
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
        List<Object> dataList = (List<Object>)dataMap.get('submitedList');
        String deletedJsonStr = JSON.serialize(dataMap.get('deleteIdList'));
        Set<String> deleteIdList = (Set<String>)JSON.deserialize(deletedJsonStr, Set<String>.class);
        
        Id poid = Id.valueOf(String.valueOf(dataMap.get('poid')));
        ASI_MFM_PO__c currentpo = [SELECT ASI_MFM_Budget_Owner__c,ASI_MFM_Supplier_Email__c,ASI_MFM_PO_Type__c, ASI_MFM_PO_Amount__c, ASI_MFM_Total_Quantity__c, OwnerId FROM ASI_MFM_PO__c WHERE id=:poid LIMIT 1];
        Boolean isOwner = false;
        if (currentpo != null && currentpo.OwnerId == System.UserInfo.getUserId()) {
            isOwner = true;
        }

        Id posmLineRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
        List<ASI_MFM_PO_POSM_Line__c> posmlineList = new List<ASI_MFM_PO_POSM_Line__c>();
        Decimal poamount = currentpo.ASI_MFM_PO_Amount__c;
        Decimal posmLineQty = 0;
        Set<Id> posmIds = new Set<Id>();
        for(Object dataObj : dataList) {
            String jsonData = JSON.serialize(dataObj);
            PosmLine posmObj = (PosmLine)JSON.deserialize(jsonData, PosmLine.class);
            if (posmObj.id != null && posmObj.id != '') {
                posmIds.add(posmObj.id);
            }
            
            poamount -= posmObj.totalPrice;
            if(posmObj.itemgroup==null||posmObj.itemgroup=='')
                return new ResultObj(false, 'Please Select Item Group.', null);
            if(!posmObj.bundleFlag && (posmObj.unitPrice==null||posmObj.unitPrice<=0))
                //return new ResultObj(false, 'Please Input Unit Price.', null);
			if(posmObj.qty==null||posmObj.qty<=0)
                return new ResultObj(false, 'Please Input Quantity.', null);
            //if(posmObj.bundleQty==null||posmObj.bundleQty<=0)
                //return new ResultObj(false, 'Please Input Bundle Quantity.', null);
            if(posmObj.warehouseid==null||posmObj.warehouseid=='')
                return new ResultObj(false, 'Please Select Warehouse.', null);
            //if(posmObj.directDelivery&&(posmObj.outletid==null||posmObj.outletid==''))
                //return new ResultObj(false, 'Please Select Outlet.', null);
            if(posmObj.province==null||posmObj.province=='')
                return new ResultObj(false, 'Please Input Province.', null);
            if(posmObj.city==null||posmObj.city=='')
                return new ResultObj(false, 'Please Input City.', null);
            if(posmObj.address==null||posmObj.address=='')
                return new ResultObj(false, 'Please Input Detail Address.', null);
            if(posmObj.contactPerson==null||posmObj.contactPerson=='')
                return new ResultObj(false, 'Please Input Contact Person.', null);
            if(posmObj.receiptOwnerId == null || posmObj.receiptOwnerId == '') {
                if(currentpo.ASI_MFM_Budget_Owner__c != null) {
                    posmObj.receiptOwnerId = currentpo.ASI_MFM_Budget_Owner__c;
                }
            }
            if(posmObj.phoneNumber==null||posmObj.phoneNumber=='')
                return new ResultObj(false, 'Please Input Contact Phone Number.', null);
            if(posmObj.directDelivery&&(posmObj.email==null||posmObj.email==''))
                //return new ResultObj(false, 'Please Input Email.', null);
            if(posmObj.vatId==null||posmObj.vatId=='')
                return new ResultObj(false, 'Please Select VAT.', null);
            //if(posmObj.vas==null||posmObj.vas=='')
            //    return new ResultObj(false, 'Please Select VAS.', null);
            ASI_MFM_PO_POSM_Line__c posmLine = new ASI_MFM_PO_POSM_Line__c();
            if(posmObj.id!=null&&posmObj.id!=''){
                posmLine.Id = posmObj.id;
            } else {
                posmLine.ASI_MFM_PO__c = poid;
            }
            if(posmObj.outletid!=null&&posmObj.outletid!='') {
                posmLine.ASI_MFM_Delivery_Address_Outlet__c = Id.valueOf(posmObj.outletid);
            } 
            posmLine.ASI_MFM_Item_Group__c 					= posmObj.itemgroup;
            posmLine.ASI_MFM_Delivery_Address_Warehouse__c 	= Id.valueOf(posmObj.warehouseid);
            posmLine.ASI_MFM_Bundle_Item_Group__c 			= posmObj.bundleFlag;
            posmLine.ASI_MFM_Unit_Price__c 		= posmObj.unitPrice;
            posmLine.ASI_MFM_Quantity__c   		= posmObj.qty;
            posmLine.ASI_MFM_Bundle_Quantity__c = posmObj.bundleQty;
            posmLine.ASI_MFM_Province__c   		= posmObj.province;
            posmLine.ASI_MFM_City__c       		= posmObj.city;
            if(posmObj.receiptOwnerId!=null&&posmObj.receiptOwnerId!='') {
                posmLine.ASI_CTY_CN_Vendor_ReceiptOwner__c  = Id.valueOf(posmObj.receiptOwnerId);
            }

            posmLine.ASI_MFM_Detail_Address__c 	= posmObj.address;
            posmLine.ASI_MFM_Contact_Person__c 	= posmObj.contactPerson;
            posmLine.ASI_MFM_Phone_Number__c   	= posmObj.phoneNumber;
            if(posmObj.vatId!=null&&posmObj.vatId!='') {
                posmLine.ASI_MFM_Tax_Code__c    = posmObj.vatId;
            }
            posmLine.ASI_MFM_Operation_Team_Email_1__c = posmObj.opEmail_1;
            posmLine.ASI_MFM_Operation_Team_Email_2__c = posmObj.opEmail_2;
            posmLine.ASI_MFM_Operation_Team_Email_3__c = posmObj.opEmail_3;
			posmLine.ASI_MFM_Operation_Team_Email_4__c = posmObj.opEmail_4;
            posmLine.ASI_MFM_Operation_Team_Email_5__c = posmObj.opEmail_5;
            posmLine.ASI_MFM_Operation_Team_Email_6__c = posmObj.opEmail_6;
			posmLine.ASI_MFM_Operation_Team_Email_7__c = posmObj.opEmail_7;
            posmLine.ASI_MFM_Operation_Team_Email_8__c = posmObj.opEmail_8;
			posmLine.ASI_MFM_SIR_Email_Address_1__c = posmObj.sirEmail_1;
            posmLine.ASI_MFM_SIR_Email_Address_2__c = posmObj.sirEmail_2;
            posmLine.ASI_MFM_SIR_Email_Address_3__c = posmObj.sirEmail_3; 
            posmLine.ASI_MFM_SIR_Email_Address_4__c = posmObj.sirEmail_4;
            posmLine.ASI_MFM_SIR_Email_Address_5__c = posmObj.sirEmail_5;
            posmLine.ASI_MFM_SIR_Email_Address_6__c = posmObj.sirEmail_6;
			posmLine.ASI_MFM_SIR_Email_Address_7__c = posmObj.sirEmail_7;
            posmLine.ASI_MFM_SIR_Email_Address_8__c = posmObj.sirEmail_8;
            posmLine.ASI_MFM_Email__c = posmObj.email;
            posmLine.ASI_MFM_VAS__c = posmObj.vas;
            if(currentpo.ASI_MFM_Supplier_Email__c!=null) {
                posmLine.ASI_MFM_Supplier_Email__c = currentpo.ASI_MFM_Supplier_Email__c;
            }
            if(currentpo.ASI_MFM_Budget_Owner__c!=null) {
                posmLine.ASI_MFM_Budget_Owner__c = currentpo.ASI_MFM_Budget_Owner__c;
            }
            posmLineQty += posmLine.ASI_MFM_Quantity__c;
            posmlineList.add(posmLine);
            
        }
        if (currentpo.ASI_MFM_PO_Type__c == 'eMarket' && posmLineQty != currentpo.ASI_MFM_Total_Quantity__c && isOwner) {
            return new ResultObj(false, 'POSM Line total quantity must be equals to PO total quantity(' + currentpo.ASI_MFM_Total_Quantity__c + ')', null);
        }

        Map<Id, Integer> posmSirQtyMap = null; 
        if (posmIds.size() > 0) {  // 20201207 by HUJINCHAO-BLS If the quantity filled in is less than that of Sir quantity, an error will be reported
            System.debug(LoggingLevel.INFO, '*** posmIds: ' + posmIds);
            List<ASI_MFM_Stock_In_Request__c> sirList = [SELECT Id, Name, 
                                                         ASI_MFM_PO_POSM_Line_Number__c, 
                                                         ASI_MFM_Total_Quantity__c,
                                                         ASI_MFM_Lot_Quantity__c
                                                         FROM ASI_MFM_Stock_In_Request__c 
                                                         WHERE ASI_MFM_PO_POSM_Line_Number__c IN :posmIds];
            System.debug(LoggingLevel.INFO, '*** sirList: ' + sirList);
            if (sirList != null && sirList.size() > 0) {
                posmSirQtyMap = new Map<Id, Integer>();
                for (ASI_MFM_Stock_In_Request__c sir : sirList) {
                    if (sir.ASI_MFM_Lot_Quantity__c != null) {
                        if (!posmSirQtyMap.containsKey(sir.ASI_MFM_PO_POSM_Line_Number__c)) {
                            posmSirQtyMap.put(sir.ASI_MFM_PO_POSM_Line_Number__c, Integer.valueOf(sir.ASI_MFM_Lot_Quantity__c));
                        } else {
                            posmSirQtyMap.put(sir.ASI_MFM_PO_POSM_Line_Number__c, posmSirQtyMap.get(sir.ASI_MFM_PO_POSM_Line_Number__c) + Integer.valueOf(sir.ASI_MFM_Lot_Quantity__c));
                        }
                    }
                }

                for(Object dataObj : dataList) {
                    String jsonData = JSON.serialize(dataObj);
                    PosmLine posmObj = (PosmLine)JSON.deserialize(jsonData, PosmLine.class);
                    if(posmObj.qty == null || posmObj.qty <= 0) {
                        continue;
                    }

                    if (posmObj.id != null && posmObj.id != '' && posmSirQtyMap.containsKey(posmObj.id)) {
                        if (posmObj.qty < posmSirQtyMap.get(posmObj.id)) {
                            return new ResultObj(false, 'POSM Line quantity must be greater than or equal to SIR writed quantity', null);
                        }
                    }
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** posmSirQtyMap: ' + posmSirQtyMap);
        //20181025 @introv change amount check logic to all PO type POSM Amount < PO Amount
        //if(currentpo.ASI_MFM_PO_Type__c=='eMarket') {
        //    if(Math.abs(poamount)>1) return new ResultObj(false, 'POSM Line Total Amount Not Equal To Po Amount', null);
        //} else 
        if(poamount<0 && currentpo.ASI_MFM_PO_Type__c != 'Gift material'){
            return new ResultObj(false, 'POSM Line Total Amount Must Samller Than Po Amount', null);
        }
        //20181025 @introv change amount check logic to all PO type POSM Amount < PO Amount only
            
        if(posmlineList.size()>0) {
            upsert posmlineList;
        }

        if(deleteIdList.size()>0) {
        	List<ASI_MFM_PO_POSM_Line__c> deletedList = [SELECT id FROM ASI_MFM_PO_POSM_Line__c WHERE id IN :deleteIdList];
            delete deletedList;
        }
        // 20201204 Added by jack yuan BLS
        if (currentpo.ASI_MFM_PO_Type__c == 'eMarket') {
            currentpo.ASI_CTY_CN_Vendor_IS_POSM_Line_Updated__c = true;
            update currentpo;
        }

        
        return new ResultObj(true, 'success', getPosmLineList(poid));
    }
    
    @RemoteAction
    global static ReusltConfig searchConfig(String dataSet) {
        try{
            Id customerRTID = Global_recordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            List<ASI_CRM_AccountsAdditionalField__c> custList = [SELECT id, name, ASI_CRM_CN_City_Name__c, 
                                                                 ASI_CRM_CN_Contact_Person__c, ASI_CRM_CN_Phone_Number__c,
                                                                 ASI_CRM_CN_Province__c, ASI_CRM_CN_Address__c, ASI_CRM_CN_Email__c
                                                                 FROM ASI_CRM_AccountsAdditionalField__c 
                                                                 WHERE RecordTypeId = :customerRTID 
                                                                 AND ASI_CRM_CN_Inactive_Flag__c=false 
                                                                 AND ASI_CRM_CN_Competitor_Outlet__c=false
                                                                 AND ASI_CRM_CN_Dummy_Outlet_Flag__c=false 
                                                                 AND (ASI_CRM_CN_JDE_Code__c!='' or ASI_CRM_CN_JDE_Code_Premium__c!='' or ASI_CRM_CN_JDE_Code_RTD__c!='')
                                                                 ];
            List<String> outletNameList = new List<String>();
            Map<String,ASI_CRM_AccountsAdditionalField__c> outletMap = new Map<String,ASI_CRM_AccountsAdditionalField__c>();
            for(ASI_CRM_AccountsAdditionalField__c cust:custList){
                outletNameList.add(cust.name);
                outletMap.put(cust.name,cust);
            }
            Id cityRTID = Global_recordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City');
            Set<String> citySet = new Set<String>();
            Map<String, Set<String>> cityMap = new Map<String, Set<String>>();
            List<ASI_CRM_City__c> cityList = [SELECT id, name, ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c
                                              FROM ASI_CRM_City__c 
                                              WHERE RecordTypeId=:cityRTID];
            for(ASI_CRM_City__c city : cityList) {
                citySet.add(city.name);
                if(!cityMap.containsKey(city.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c)) cityMap.put(city.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c, new Set<String>());
                cityMap.get(city.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c).add(city.name);
            }
            
            Id taxCodeRTID = Global_recordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_CN_Tax_Code');
            Map<String, ASI_MFM_Tax_Code__c> taxCodeMap = new Map<String, ASI_MFM_Tax_Code__c>();
            List<ASI_MFM_Tax_Code__c> taxCodeList = [SELECT id,name,ASI_MFM_VAT_Rate__c FROM ASI_MFM_Tax_Code__c WHERE RecordTypeId=:taxCodeRTID Order by Name];
            for(ASI_MFM_Tax_Code__c tc : taxCodeList){
                taxCodeMap.put(tc.id+'',tc);
            }
            
            Map<String,String> vasMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResultVAS = ASI_MFM_PO_POSM_Line__c.ASI_MFM_VAS__c.getDescribe();
            List<Schema.PicklistEntry> pleVAS = fieldResultVAS.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : pleVAS){
                vasMap.put(pickListVal.getValue(),pickListVal.getLabel());
            }

            Map<String, String> userMap = new Map<String, String>();
            Set<String> userNameList = new Set<String>();
            for(User item : [SELECT Id, Name FROM User WHERE IsActive = TRUE AND License_Type__c != 'Customer Community']) {
                userMap.put(item.Name, item.Id);
                userNameList.add(item.Name);
            }
            
            ReusltConfig config = new ReusltConfig(true,'success');
            config.outletNameList = outletNameList;
            config.outletMap = outletMap;
			config.provinceList = cityMap.keySet();
        	config.cityList = citySet;
            config.cityMap  = cityMap;
            config.taxCodeMap = taxCodeMap;
            config.vasMap = vasMap;
            config.userMap = userMap;
            config.userList = userNameList;
            //config.outletMap = outletMap;
            return config;
        } catch(Exception e) {
            return new ReusltConfig(false,e.getMessage());
        }
    }
    
    @TestVisible
    private static List<PosmLine> getPosmLineList(Id poid){
        Id posmlineRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
        Id sirRTID = Global_recordTypeCache.getRtId('ASI_MFM_Stock_In_Request__cASI_MFM_CN_Stock_In_Request'); 
        List<ASI_MFM_PO_POSM_Line__c> posmlineList = [SELECT id,name,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_Minimum_Order_Qty__c,
                                                      	ASI_MFM_Item_Group__r.name,ASI_MFM_Item_Group_Code__c,
                                                      	ASI_MFM_Tax_Code__c,ASI_MFM_Tax_Code__r.name,ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c,
                                                      	ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Description__c,ASI_MFM_Item_Group__c,
                                                     	ASI_MFM_Unit_Price__c,ASI_MFM_Bundle_Quantity__c,ASI_MFM_Quantity__c,ASI_MFM_Total_Price__c,ASI_MFM_Total_Price_w_VAT__c,
                                                      	ASI_MFM_Delivery_Address_Outlet__c,ASI_MFM_Delivery_Address_Warehouse__c,
                                                      	ASI_MFM_Delivery_Address_Outlet__r.name,ASI_MFM_Delivery_Address_Warehouse__r.name,
                                                      	ASI_MFM_Delivery_Address_Warehouse__r.ASI_FOC_Warehouse_Code__c,
                                                      	ASI_MFM_Delivery_Address_Warehouse__r.ASI_MFM_Direct_Delivery__c,
                                                      	ASI_MFM_Bundle_Item_Group__c,ASI_MFM_City__c, ASI_MFM_Contact_Person__c, 
                                                      	ASI_MFM_Phone_Number__c, ASI_MFM_Province__c, ASI_MFM_Detail_Address__c,
                                                      	ASI_MFM_Operation_Team_Email_1__c, ASI_MFM_Operation_Team_Email_2__c, ASI_MFM_Operation_Team_Email_3__c, 
                                                        ASI_MFM_Operation_Team_Email_4__c, ASI_MFM_Operation_Team_Email_5__c, ASI_MFM_Operation_Team_Email_6__c, 
                                                        ASI_MFM_Operation_Team_Email_7__c, ASI_MFM_Operation_Team_Email_8__c, 
                                                        ASI_MFM_SIR_Email_Address_1__c, ASI_MFM_SIR_Email_Address_2__c, ASI_MFM_SIR_Email_Address_3__c, 
                                                        ASI_MFM_SIR_Email_Address_4__c, ASI_MFM_SIR_Email_Address_5__c, ASI_MFM_SIR_Email_Address_6__c, 
                                                        ASI_MFM_SIR_Email_Address_7__c, ASI_MFM_SIR_Email_Address_8__c,ASI_MFM_Email__c,
                                                      	ASI_MFM_VAS__c, ASI_CTY_CN_Vendor_ReceiptOwner__c, ASI_CTY_CN_Vendor_ReceiptOwner__r.Name,
                                                      	(SELECT id,name,ASI_MFM_TIV_Note_Sent__c,ASI_MFM_TIV_Number__c, ASI_MFM_Item_Group_Code__c, 
                                                            ASI_MFM_Delivery_Address__c, ASI_MFM_PO_Number__r.name, ASI_MFM_PO_POSM_Line_Number__r.name, 
                                                         	ASI_MFM_Status__c, ASI_MFM_Total_Number_Of_Box__c, ASI_MFM_Lot_Quantity__c, ASI_Delivery_Date__c, ASI_MFM_Net_Weight__c, 
                                                         	ASI_MFM_Box_Net_Weight__c, ASI_MFM_Total_Quantity__c, ASI_MFM_Lot_Number__c,
                                                         	ASI_MFM_Min_Unit_Price__c, ASI_MFM_Qty_Per_Bag_Box__c, ASI_MFM_Qty_Per_Box__c, ASI_MFM_Total_Qty_Per_Bag_Box__c, 
                                                         	ASI_MFM_Fraction_Qty__c, ASI_MFM_Box_Size_M3__c
                                                         FROM Stock_In_Requests__r 
                                                         WHERE RecordTypeId=:sirRTID 
                                                         ORDER BY CreatedDate, name)
                                                      FROM ASI_MFM_PO_POSM_Line__c 
                                                      WHERE RecordTypeId=:posmlineRTID 
                                                      AND ASI_MFM_PO__c=:poid
                                                      ORDER BY CreatedDate];
        
        List<PosmLine> plList = new List<PosmLine>();
        for(ASI_MFM_PO_POSM_Line__c line : posmlineList){
            PosmLine posmLine = new PosmLine(line);
            for(ASI_MFM_Stock_In_Request__c  sir : line.Stock_In_Requests__r){
                posmLine.sirList.add(new SirObj(sir));
            }
            posmLine.editable = (posmLine.sirList.size()==0);
            plList.add(posmLine);
        }
        
        return plList;
	}
    
    @RemoteAction
    global static ResultObj searchPosmLineList(String dataSet) {
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
        Id poid = (Id)dataMap.get('poid');
        List<PosmLine> plList = getPosmLineList(poid);
        return new ResultObj(true,'success',plList);
    }
    
    global class ReusltConfig {
        public String message;
        public Boolean success;
        public Set<String> provinceList;
        public Set<String> cityList;
        public Map<String,Set<String>> cityMap;
        public List<String> outletNameList;
        public Map<String,ASI_CRM_AccountsAdditionalField__c> outletMap;
        //public List<String> taxCodeList;
        public Map<String,ASI_MFM_Tax_Code__c> taxCodeMap;
        public Map<String,String> vasMap;

        public Map<String, String> userMap;
        public Set<String> userList;
        
        public ReusltConfig(Boolean b, String m) {
            message = m;
            success = b;
        }
    }
    
    global class ResultObj {
    	public String message;
        public Boolean success;
        public List<PosmLine> posmLineList;
        public ResultObj(Boolean b, String m, List<PosmLine> pl){
            message = m;
            success = b;
            posmLineList = pl;
        }
    }
    
    global class PosmLine {
        public String id;
        public Boolean editable;
        public Integer rowcontrol;
        public String itemgroup;
        public String itemgroupCode;
        public String itemgroupName;
        public String itemgroupLabel;
        public String itemgroupDesc;
        public String vat;
        public String vatId;
        public Decimal vatRate;
        public Decimal minOrderQty;
        public Decimal unitPrice;
        public Decimal bundleQty;
        public Decimal qty;
        public Decimal totalPrice;
        public Decimal totalPriceVat;
        public String warehouseName;
        public String outletName;
        public Boolean bundleFlag;
        public String sentMail;
        public String tivNum;
        public String sirLink;
        public String status;
        public String warehouseid;
        public String outletid;
        public String address;
		public String city;
        public String contactPerson;
        public String receiptOwnerName;  // 20201208 by HUJINCHAO-BLS Add receiptOwner Name
        public String receiptOwnerId;  // 20201208 by HUJINCHAO-BLS Add receiptOwner Id
        public String phoneNumber;
        public String province;
        public String email;
        public String sirEmail_1;
        public String sirEmail_2;
        public String sirEmail_3;
        public String sirEmail_4;
        public String sirEmail_5;
        public String sirEmail_6;
        public String sirEmail_7;
        public String sirEmail_8;
        public String opEmail_1;
        public String opEmail_2;
        public String opEmail_3;
        public String opEmail_4;
        public String opEmail_5;
        public String opEmail_6;
        public String opEmail_7;
        public String opEmail_8;
        public Boolean directDelivery;
        public String vas;

        public List<SirObj> sirList;
        public PosmLine(ASI_MFM_PO_POSM_Line__c data) {
            sirList = new List<SirObj>();
        	if(data.id!=null) id=data.id;
            rowcontrol=0;
            sentMail='';
            tivNum='';
            sirLink='link';
            if(data.ASI_MFM_Tax_Code__c!=null) {
                vatId = data.ASI_MFM_Tax_Code__c;
                vat = data.ASI_MFM_Tax_Code__r.name;
                vatRate = data.ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c;
            }
            if(data.ASI_MFM_Item_Group__c!=null) itemgroup=data.ASI_MFM_Item_Group__c;
            itemgroupCode = '';
            itemgroupLabel = (data.ASI_MFM_Item_Group__c!=null&&data.ASI_MFM_Item_Group__r.name!=null)? data.ASI_MFM_Item_Group__r.name:'';
            itemgroupName = (data.ASI_MFM_Item_Group__c!=null&&data.ASI_MFM_Item_Group__r.name!=null)? data.ASI_MFM_Item_Group__r.name+' '+data.ASI_MFM_Item_Group_Code__c:'';
            itemgroupDesc = (data.ASI_MFM_Item_Group__c!=null&&data.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Description__c!=null)? data.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Description__c:'';
            unitPrice = (data.ASI_MFM_Unit_Price__c!=null)? data.ASI_MFM_Unit_Price__c:0;
            minOrderQty = (data.ASI_MFM_Minimum_Order_Qty__c!=null)?data.ASI_MFM_Minimum_Order_Qty__c:0;
            bundleQty = (data.ASI_MFM_Bundle_Quantity__c!=null)? data.ASI_MFM_Bundle_Quantity__c:0;
            qty = (data.ASI_MFM_Quantity__c!=null)? data.ASI_MFM_Quantity__c:0;
            totalPrice = (data.ASI_MFM_Total_Price__c!=null)? data.ASI_MFM_Total_Price__c:0;
            totalPriceVat = (data.ASI_MFM_Total_Price_w_VAT__c!=null)? data.ASI_MFM_Total_Price_w_VAT__c:0;
            bundleFlag = (data.ASI_MFM_Bundle_Item_Group__c!=null) ? data.ASI_MFM_Bundle_Item_Group__c:false;
            warehouseName = (data.ASI_MFM_Delivery_Address_Warehouse__c!=null&&data.ASI_MFM_Delivery_Address_Warehouse__r.name!=null)? data.ASI_MFM_Delivery_Address_Warehouse__r.name+' - '+data.ASI_MFM_Delivery_Address_Warehouse__r.ASI_FOC_Warehouse_Code__c:'';
            outletName = (data.ASI_MFM_Delivery_Address_Outlet__c!=null&&data.ASI_MFM_Delivery_Address_Outlet__r.name!=null)?data.ASI_MFM_Delivery_Address_Outlet__r.name:'';

            if(data.ASI_MFM_Delivery_Address_Warehouse__c!=null){
                warehouseid=data.ASI_MFM_Delivery_Address_Warehouse__c;
            	directDelivery=data.ASI_MFM_Delivery_Address_Warehouse__r.ASI_MFM_Direct_Delivery__c;
            }
            if(data.ASI_MFM_Delivery_Address_Outlet__c!=null) outletid=data.ASI_MFM_Delivery_Address_Outlet__c;
            city = (data.ASI_MFM_City__c!=null)?data.ASI_MFM_City__c:'';
            contactPerson = (data.ASI_MFM_Contact_Person__c!=null)?data.ASI_MFM_Contact_Person__c:'';
            phoneNumber = (data.ASI_MFM_Phone_Number__c!=null)?data.ASI_MFM_Phone_Number__c:'';
            province = (data.ASI_MFM_Province__c!=null)?data.ASI_MFM_Province__c:'';
            address = (data.ASI_MFM_Detail_Address__c!=null)?data.ASI_MFM_Detail_Address__c:'';

            // 20201208 by HUJINCHAO-BLS Assign values to receipt Owner Name and receipt Owner id
            receiptOwnerName = (data.ASI_CTY_CN_Vendor_ReceiptOwner__c != null && data.ASI_CTY_CN_Vendor_ReceiptOwner__r.Name != null) ? data.ASI_CTY_CN_Vendor_ReceiptOwner__r.Name:'';
            if (data.ASI_CTY_CN_Vendor_ReceiptOwner__c != null) {
                receiptOwnerId = data.ASI_CTY_CN_Vendor_ReceiptOwner__c;
            }

            editable = true;//(data.ASI_MFM_PO__r.ASI_MFM_Status__c == 'Draft');
            
            email = (data.ASI_MFM_Email__c!=null)?data.ASI_MFM_Email__c:'';
            sirEmail_1 = (data.ASI_MFM_SIR_Email_Address_1__c!=null)?data.ASI_MFM_SIR_Email_Address_1__c:'';
            sirEmail_2 = (data.ASI_MFM_SIR_Email_Address_2__c!=null)?data.ASI_MFM_SIR_Email_Address_2__c:'';
            sirEmail_3 = (data.ASI_MFM_SIR_Email_Address_3__c!=null)?data.ASI_MFM_SIR_Email_Address_3__c:'';
            sirEmail_4 = (data.ASI_MFM_SIR_Email_Address_4__c!=null)?data.ASI_MFM_SIR_Email_Address_4__c:'';
            sirEmail_5 = (data.ASI_MFM_SIR_Email_Address_5__c!=null)?data.ASI_MFM_SIR_Email_Address_5__c:'';
            sirEmail_6 = (data.ASI_MFM_SIR_Email_Address_6__c!=null)?data.ASI_MFM_SIR_Email_Address_6__c:'';
            sirEmail_7 = (data.ASI_MFM_SIR_Email_Address_7__c!=null)?data.ASI_MFM_SIR_Email_Address_7__c:'';
            sirEmail_8 = (data.ASI_MFM_SIR_Email_Address_8__c!=null)?data.ASI_MFM_SIR_Email_Address_8__c:'';
            opEmail_1 = (data.ASI_MFM_Operation_Team_Email_1__c!=null)?data.ASI_MFM_Operation_Team_Email_1__c:'';
            opEmail_2 = (data.ASI_MFM_Operation_Team_Email_2__c!=null)?data.ASI_MFM_Operation_Team_Email_2__c:'';
            opEmail_3 = (data.ASI_MFM_Operation_Team_Email_3__c!=null)?data.ASI_MFM_Operation_Team_Email_3__c:'';
            opEmail_4 = (data.ASI_MFM_Operation_Team_Email_4__c!=null)?data.ASI_MFM_Operation_Team_Email_4__c:'';
            opEmail_5 = (data.ASI_MFM_Operation_Team_Email_5__c!=null)?data.ASI_MFM_Operation_Team_Email_5__c:'';
            opEmail_6 = (data.ASI_MFM_Operation_Team_Email_6__c!=null)?data.ASI_MFM_Operation_Team_Email_6__c:'';
            opEmail_7 = (data.ASI_MFM_Operation_Team_Email_7__c!=null)?data.ASI_MFM_Operation_Team_Email_7__c:'';
            opEmail_8 = (data.ASI_MFM_Operation_Team_Email_8__c!=null)?data.ASI_MFM_Operation_Team_Email_8__c:'';
            
            vas = (data.ASI_MFM_VAS__c!=null)?data.ASI_MFM_VAS__c:'';
        }
    }
    
    global class SirObj {
        String id {get;set;}
        String name {get;set;}
        String tivnum {get;set;}
        Boolean tivnotesent {get;set;}
        String address {get;set;}
        String lognum {get;set;}
        String ponum {get;set;}
        String itemgroupcode {get;set;}
        String netweight {get;set;}
        String boxsizem3 {get;set;}
        String boxnetweight {get;set;}
        String minunitprice {get;set;}
        String totalqty {get;set;}
        String lotqty {get;set;}
        String totalqtyperbagbox {get;set;}
        String qtyperbagbox {get;set;}
        String qtyperbox {get;set;}
        String fractionqty {get;set;}
        String totalnumofbox {get;set;}
        String deliverydate {get;set;}
        Boolean isSendEmail {get;set;}
        
        public SirObj(ASI_MFM_Stock_In_Request__c sir) {
            
            id = sir.id;
            name = (sir.Name!=null)? sir.Name:'';
            tivnum = (sir.ASI_MFM_TIV_Number__c!=null)? sir.ASI_MFM_TIV_Number__c:'';
            tivnotesent = (sir.ASI_MFM_TIV_Note_Sent__c)? sir.ASI_MFM_TIV_Note_Sent__c:false;
            address = (sir.ASI_MFM_Delivery_Address__c!=null)?sir.ASI_MFM_Delivery_Address__c:'';
            lognum = (sir.ASI_MFM_Lot_Number__c!=null)?sir.ASI_MFM_Lot_Number__c:'';
            ponum = (sir.ASI_MFM_PO_Number__r.Name!=null)?sir.ASI_MFM_PO_Number__r.Name:'';
            itemgroupcode = (sir.ASI_MFM_Item_Group_Code__c!=null)?sir.ASI_MFM_Item_Group_Code__c:'';
            netweight = (sir.ASI_MFM_Net_Weight__c!=null)?sir.ASI_MFM_Net_Weight__c+'':'';
            boxsizem3 = (sir.ASI_MFM_Box_Size_M3__c!=null)?sir.ASI_MFM_Box_Size_M3__c+'':'';
            boxnetweight = (sir.ASI_MFM_Box_Net_Weight__c!=null)?sir.ASI_MFM_Box_Net_Weight__c+'':'';
            minunitprice = (sir.ASI_MFM_Min_Unit_Price__c!=null)?sir.ASI_MFM_Min_Unit_Price__c+'':'';
            totalqty = (sir.ASI_MFM_Total_Quantity__c!=null)?sir.ASI_MFM_Total_Quantity__c+'':'';
            lotqty = (sir.ASI_MFM_Lot_Quantity__c!=null)?sir.ASI_MFM_Lot_Quantity__c+'':'';
            totalqtyperbagbox = (sir.ASI_MFM_Total_Qty_Per_Bag_Box__c!=null)?sir.ASI_MFM_Total_Qty_Per_Bag_Box__c+'':'';
            qtyperbagbox = (sir.ASI_MFM_Qty_Per_Bag_Box__c!=null)?sir.ASI_MFM_Qty_Per_Bag_Box__c+'':'';
            qtyperbox = (sir.ASI_MFM_Qty_Per_Box__c!=null)?sir.ASI_MFM_Qty_Per_Box__c+'':'';
            fractionqty = (sir.ASI_MFM_Fraction_Qty__c!=null)?sir.ASI_MFM_Fraction_Qty__c+'':'';
            totalnumofbox = (sir.ASI_MFM_Total_Number_Of_Box__c!=null)?sir.ASI_MFM_Total_Number_Of_Box__c+'':'';
            deliverydate = (sir.ASI_Delivery_Date__c!=null)?sir.ASI_Delivery_Date__c.format():'';
		}
    }
    
    global class ItemGroupObj {
        public Id id;
        public String name;
        public String description;
        public Decimal unitPrice;
        public Boolean isBundle;
        public Decimal minOrderQty;
        public ItemGroupObj(ASI_MFM_Item_Group__c itemGroup) {
            this.id = itemGroup.id;
            this.name = itemGroup.name+' '+itemGroup.ASI_MFM_Item_Group_Code__c;
            this.unitPrice = (itemGroup.ASI_MFM_Reference_Unit_Price__c!=null)? itemGroup.ASI_MFM_Reference_Unit_Price__c:0;
            this.description = (itemGroup.ASI_MFM_Item_Group_Description__c!=null)? itemGroup.ASI_MFM_Item_Group_Description__c:'';
            this.isBundle = (itemGroup.ASI_MFM_Bundle_Item_Group__c!=null)? itemGroup.ASI_MFM_Bundle_Item_Group__c:false;
            this.minOrderQty = (itemGroup.ASI_MFM_Minimum_Order_Qty__c!=null)? itemGroup.ASI_MFM_Minimum_Order_Qty__c:null;
        }
    }
    
}