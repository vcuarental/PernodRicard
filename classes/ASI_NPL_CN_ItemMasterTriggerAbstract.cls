public class ASI_NPL_CN_ItemMasterTriggerAbstract {

    public ASI_NPL_CN_ItemMasterTriggerAbstract(){
    }

    public void executeAfterInsertTriggerAction(ASI_CN_NPL_Item_Master__c[] items){
        insertWarehouseItemMaster(items);
    }

    private static void insertWarehouseItemMaster(ASI_CN_NPL_Item_Master__c[] items){
        List<ASI_FOC_Warehouse__c> warehouses = getAllNormalGoodsWarehouse();
        List<ASI_NPL_Warehouse_Item_Master__c> warehouseItems = new List<ASI_NPL_Warehouse_Item_Master__c>(); //MT@Introv@20200429: Fix dml inside the loop

        for(ASI_CN_NPL_Item_Master__c item : items){
            for(ASI_FOC_Warehouse__c warehouse : warehouses){
                ASI_NPL_Warehouse_Item_Master__c warehouseItem = new ASI_NPL_Warehouse_Item_Master__c();
                warehouseItem.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_NPL_Warehouse_Item_Master__cASI_NPL_CN_Warehouse_Item_Master');
                warehouseItem.ASI_NPL_Item_Master__c = item.id;
                warehouseItem.ASI_NPL_Warehouse__c = warehouse.id;
                //MT@Introv@20200429: Fix dml inside the loop START
                //insert warehouseItem;
                warehouseItems.add(warehouseItem);
                //MT@Introv@20200429: Fix dml inside the loop END
            }
        }
        //MT@Introv@20200429: Fix dml inside the loop START
        if(!warehouseItems.isEmpty()){
            insert warehouseItems;
        }
        //MT@Introv@20200429: Fix dml inside the loop END
    }

    private static List<ASI_FOC_Warehouse__c> getAllNormalGoodsWarehouse(){
        List<ASI_FOC_Warehouse__c> warehouses = [select id from ASI_FOC_Warehouse__c where ASI_MFM_Inventory_Required__c = TRUE AND recordtype.developername = 'ASI_NPL_CN_Normal_Goods_Warehouse'];
        return warehouses;
    }

    //20200228:AM@Introv - CR(Opt_Auto) start
    public static void beforeInsertMethod(List<ASI_CN_NPL_Item_Master__c> triggerNew) {
        assignPicklistValues(triggerNew);
    }
    
    public static void beforeUpdateMethod(List<ASI_CN_NPL_Item_Master__c> triggerNew, Map<Id, ASI_CN_NPL_Item_Master__c> triggerOldMap) {
        assignPicklistValues(triggerNew);
    }
    
    public static void afterUpdateMethod(List<ASI_CN_NPL_Item_Master__c> triggerNew, Map<Id, ASI_CN_NPL_Item_Master__c> triggerOldMap) {
		checkPnd(triggerNew, triggerOldMap);
        checkChannelStrategy(triggerNew, triggerOldMap);
        // 20200611 Added by Jack Yuan BLS start
        generatePOSMItemGroup(triggerNew, triggerOldMap);
        // 20200611 Added by Jack Yuan BLS end
    }

    private static void checkPnd(List<ASI_CN_NPL_Item_Master__c> triggerNew, Map<Id, ASI_CN_NPL_Item_Master__c> triggerOldMap) {
        /*
        CONTAINS(RecordType.DeveloperName, 'ASI_CN_NPL') && 
        ISCHANGED(ASI_CN_NPL_Item_Goup_Code__c) && 
        ISPICKVAL(ASI_CN_NPL_Status__c,'Completed') && 
        ASI_CN_NPL_NPLT1PriceFlag__c && 
        NOT(ASI_CN_NPL_Ignore_Checking__c)
		*/
        
        List<ASI_CN_NPL_Item_Master__c> ltUpdate = new List<ASI_CN_NPL_Item_Master__c>();
        for(ASI_CN_NPL_Item_Master__c oIM : triggerNew) {
            if (triggerOldMap.containsKey(oIM.Id)) {
            	ASI_CN_NPL_Item_Master__c oOld = triggerOldMap.get(oIM.Id);
                if ((oIM.ASI_CN_NPL_Item_Goup_Code__c != oOld.ASI_CN_NPL_Item_Goup_Code__c) && (oIM.ASI_CN_NPL_Status__c=='Completed') && (oIM.ASI_CN_NPL_NPLT1PriceFlag__c))
                    ltUpdate.add(oIM);
            }
        }
        if (ltUpdate.size()>0) updatePnDRemarks(ltUpdate);
    }
    
    private static void updatePnDRemarks(List<ASI_CN_NPL_Item_Master__c> triggerNew) {
        Set<String> setItemGroupCode = new Set<String>();
        Map<Id, string> mapIMRemarks = new Map<Id, string>();
        Map<Id, string> mapIMItemGroup = new Map<Id, string>();
        for(ASI_CN_NPL_Item_Master__c oIM : triggerNew) {
            mapIMRemarks.put(oIM.Id, oIM.ASI_CN_NPL_Item_Group_Description_GE__c + '\r\n' + oIM.ASI_CN_NPL_Item_Group_Description_CH__c + '\r\nItem Group Code : ' + oIM.ASI_CN_NPL_Item_Goup_Code__c);
            mapIMItemGroup.put(oIM.Id, oIM.ASI_CN_NPL_Item_Goup_Code__c);
            setItemGroupCode.add(oIM.ASI_CN_NPL_Item_Goup_Code__c);
        }
        
        Map<String, ASI_MFM_Item_Group__c> mapItemGroup = new Map<String, ASI_MFM_Item_Group__c>();
        List<ASI_MFM_Item_Group__c> ltItemGroup = new List<ASI_MFM_Item_Group__c>([
            SELECT id, ASI_MFM_Sub_brand__c, ASI_MFM_Item_Group_Code__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN :setItemGroupCode
		]);
        for(ASI_MFM_Item_Group__c oItemGroup : ltItemGroup){
			mapItemGroup.put(oItemGroup.ASI_MFM_Item_Group_Code__c, oItemGroup);
        }
        
        boolean bError = FALSE;
        for(ASI_CN_NPL_Item_Master__c oIM : triggerNew) {
            if(!mapItemGroup.containsKey(oIM.ASI_CN_NPL_Item_Goup_Code__c)){
                oIM.addError('Item Group with Item Group Code (' + oIM.ASI_CN_NPL_Item_Goup_Code__c + ') not found.');
                bError = TRUE;
                break;
            }
        }
        if (bError) return;
        
        List<ASI_CRM_Price_And_Discount__c> ltUpdatePnd = new List<ASI_CRM_Price_And_Discount__c>([
            SELECT Id, ASI_CRM_Item_Master_Reference_Number__c, ASI_CRM_Remark__c, ASI_CRM_Send_Email_Notification__c
            FROM ASI_CRM_Price_And_Discount__c
            WHERE ASI_CRM_Item_Master_Reference_Number__c IN :mapIMRemarks.keySet()
        ]);
        if (ltUpdatePnd.size()>0) {
            //update Price and Discount
            Map<Id, Id> mapPnDItemGroup = new Map<Id, Id>();
            Set<Id> setPndID = new Set<Id>();
            for(ASI_CRM_Price_And_Discount__c oPnD : ltUpdatePnd) {
                oPnD.ASI_CRM_Send_Email_Notification__c = TRUE;
                oPnd.ASI_CRM_Remark__c = mapIMRemarks.get(oPnD.ASI_CRM_Item_Master_Reference_Number__c);
                setPndID.add(oPnD.Id);
                mapPnDItemGroup.put(oPnD.Id, mapItemGroup.get(mapIMItemGroup.get(oPnD.ASI_CRM_Item_Master_Reference_Number__c)).Id);
            }
            update ltUpdatePnd;
            uncheckPnDNotify(setPndID);
            
            //update Price and Discount line
            updatePnDDetail(setPndID, mapPnDItemGroup);
        }
    }
    
    private static void checkChannelStrategy(List<ASI_CN_NPL_Item_Master__c> triggerNew, Map<Id, ASI_CN_NPL_Item_Master__c> triggerOldMap) {
    	List<ASI_CN_NPL_Item_Master__c> ltUpdate = new List<ASI_CN_NPL_Item_Master__c>();
        for(ASI_CN_NPL_Item_Master__c oIM : triggerNew) {
            if (triggerOldMap.containsKey(oIM.Id)) {
            	ASI_CN_NPL_Item_Master__c oOld = triggerOldMap.get(oIM.Id);
                if ((oIM.ASI_CN_NPL_Item_Goup_Code__c != oOld.ASI_CN_NPL_Item_Goup_Code__c) && (oIM.ASI_CN_NPL_Status__c=='Completed') && (oIM.ASI_CN_NPL_NPL_Reference_No__c != NULL))
                    ltUpdate.add(oIM);
            }
        }
        if (ltUpdate.size()>0) updateChannelStrategy(ltUpdate);
    }
    
    private static void updateChannelStrategy(List<ASI_CN_NPL_Item_Master__c> triggerNew) {
        Set<Id> setIMId = new Set<Id>();
        Set<String> setItemGroupCode = new Set<String>();
        Map<Id, string> mapIMItemGroup = new Map<Id, string>();
        for(ASI_CN_NPL_Item_Master__c oIM : triggerNew) {
            setIMId.add(oIM.Id);
            mapIMItemGroup.put(oIM.Id, oIM.ASI_CN_NPL_Item_Goup_Code__c);
            setItemGroupCode.add(oIM.ASI_CN_NPL_Item_Goup_Code__c);
        }
        
        Map<String, ASI_MFM_Item_Group__c> mapItemGroup = new Map<String, ASI_MFM_Item_Group__c>();
        List<ASI_MFM_Item_Group__c> ltItemGroup = new List<ASI_MFM_Item_Group__c>([
            SELECT id, ASI_MFM_Sub_brand__c, ASI_MFM_Item_Group_Code__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN :setItemGroupCode
		]);
        for(ASI_MFM_Item_Group__c oItemGroup : ltItemGroup){
			mapItemGroup.put(oItemGroup.ASI_MFM_Item_Group_Code__c, oItemGroup);
        }
        
        boolean bError = FALSE;
        for(ASI_CN_NPL_Item_Master__c oIM : triggerNew) {
            if(!mapItemGroup.containsKey(oIM.ASI_CN_NPL_Item_Goup_Code__c)){
                oIM.addError('Item Group with Item Group Code (' + oIM.ASI_CN_NPL_Item_Goup_Code__c + ') not found.');
                bError = TRUE;
                break;
            }
        }
        if (bError) return;
        
        List<ASI_CRM_CN_Channel_Strategy__c> ltUpdateCS = new List<ASI_CRM_CN_Channel_Strategy__c>([
            SELECT Id, ASI_NPL_Item_Group__c, ASI_NPL_New_Product_Launch_Request__r.ASI_CN_NPL_Item_Master__c
            FROM ASI_CRM_CN_Channel_Strategy__c
            WHERE ASI_NPL_New_Product_Launch_Request__r.ASI_CN_NPL_Item_Master__c IN :setIMId
		]);
        
        for (ASI_CRM_CN_Channel_Strategy__c oCS : ltUpdateCS) {
            oCS.ASI_NPL_Item_Group__c = mapItemGroup.get(mapIMItemGroup.get(oCS.ASI_NPL_New_Product_Launch_Request__r.ASI_CN_NPL_Item_Master__c)).Id;
        }
        if (ltUpdateCS.size()>0) update ltUpdateCS;
    }
    
    private static void updatePnDDetail(Set<Id> setPndID, Map<Id, Id> mapPnDItemGroup) {
        List<ASI_CRM_Price_And_Discount_Detail__c> ltUpdateLine = new List<ASI_CRM_Price_And_Discount_Detail__c>([
            SELECT Id, ASI_CRM_Item_Group_Description__c, ASI_CRM_Price_And_Discount__c
            FROM ASI_CRM_Price_And_Discount_Detail__c
            WHERE ASI_CRM_Price_And_Discount__c IN :setPndID
        ]);
        
        for(ASI_CRM_Price_And_Discount_Detail__c oDetail : ltUpdateLine) {
            oDetail.ASI_CRM_Item_Group_Description__c = mapPnDItemGroup.get(oDetail.ASI_CRM_Price_And_Discount__c);
        }
        if (ltUpdateLine.size()>0) update ltUpdateLine;
    }
    
    @future
    private static void uncheckPnDNotify(Set<Id> setPndID) {
        List<ASI_CRM_Price_And_Discount__c> ltUncheck = new List<ASI_CRM_Price_And_Discount__c>();
        for (Id idPnD : setPndID) {
            ltUncheck.add(new ASI_CRM_Price_And_Discount__c(Id=idPnD, ASI_CRM_Send_Email_Notification__c=FALSE));
        }
        update ltUncheck;
    }
    
    private static void assignPicklistValues(List<ASI_CN_NPL_Item_Master__c> trigger_new) {
        for (ASI_CN_NPL_Item_Master__c oRequest : trigger_new) {
            if (oRequest.ASI_CN_NPL_New_Brand_Sub_Brand_Picklist__c != NULL) {
                oRequest.ASI_CN_NPL_New_Brand_Sub_Brand__c = (oRequest.ASI_CN_NPL_New_Brand_Sub_Brand_Picklist__c=='Yes');
            }
            if (oRequest.ASI_CN_NPL_New_Item_Group_Picklist__c != NULL) {
                oRequest.ASI_CN_NPL_New_Item_Group__c = (oRequest.ASI_CN_NPL_New_Item_Group_Picklist__c=='Yes');
            }
            if (oRequest.ASI_CN_NPL_VAP_Picklist__c != NULL) {
                oRequest.ASI_CN_NPL_VAP__c = (oRequest.ASI_CN_NPL_VAP_Picklist__c=='Yes');
            }
        }
    }
    //20200228:AM@Introv - CR(Opt_Auto) end


    // 20200611 Added by Jack Yuan BLS
    private static void generatePOSMItemGroup (List<ASI_CN_NPL_Item_Master__c> triggerNew, Map<Id, ASI_CN_NPL_Item_Master__c> triggerOldMap) {
        Set<Id> nplIds = new Set<Id>();
        for (ASI_CN_NPL_Item_Master__c itemMaster : triggerNew) {
            if (itemMaster.ASI_CN_NPL_Status__c == 'Completed' && triggerOldMap.get(itemMaster.Id).ASI_CN_NPL_Status__c != 'Completed') {
                if (String.isNotBlank(itemMaster.ASI_CN_NPL_NPL_Reference_No__c)) nplIds.add(itemMaster.ASI_CN_NPL_NPL_Reference_No__c);
            }
        }
        List<ASI_CN_NPL_NPL_Request__c> nplList = [SELECT ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Status__c,
                                                         ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Goup_Code__c, 
                                                         ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Description_CH__c,
                                                         ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Description_GE__c,
                                                         ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Sub_Brand_RP6__c,
                                                         ASI_CN_NPL_Sub_brand__c,
                                                         OwnerId
                                                  FROM ASI_CN_NPL_NPL_Request__c
                                                  WHERE Id IN :nplIds
                                                    AND (ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Goup_Code__c LIKE '9D%' 
                                                        OR ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Goup_Code__c LIKE '9L%')
                                                    AND ASI_CN_NPL_Status__c = 'Final Approved'];
        if (nplList.isEmpty()) { return;}
        Set<String> subbrandCode = new Set<String>();
        Set<String> itemGroupCode = new Set<String>();
        for (ASI_CN_NPL_NPL_Request__c npl : nplList) {
            subbrandCode.add(npl.ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Sub_Brand_RP6__c);
            itemGroupCode.add(npl.ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Goup_Code__c);
        }
        Map<String, Id> subbrandMap = new Map<String, Id>();
        for (ASI_MFM_Sub_brand__c subbrand : [SELECT Id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Sub_brand_Code__c IN:subbrandCode AND RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand']){
            subbrandMap.put(subbrand.ASI_MFM_Sub_brand_Code__c, subbrand.Id);
        }
        // if the item group already exists, will not generate
        Set<String> existItemGroupCode = new Set<String>();
        for (ASI_MFM_Item_Group__c itemGroup : [SELECT Id, ASI_MFM_Item_Group_Code__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN:itemGroupCode AND RecordType.DeveloperName = 'ASI_MFM_CN_POSM_Item_Group']){
            existItemGroupCode.add(itemGroup.ASI_MFM_Item_Group_Code__c);
        }

        List<ASI_MFM_Item_Group__c> POSMItemGroupList = new List<ASI_MFM_Item_Group__c>();
        for (ASI_CN_NPL_NPL_Request__c npl : nplList) {
            if (existItemGroupCode.contains(npl.ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Goup_Code__c) || 
                subbrandMap.isEmpty() || subbrandMap.get(npl.ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Sub_Brand_RP6__c) == NULL) {
                continue;
            }
            ASI_MFM_Item_Group__c POSMItemGroup = new ASI_MFM_Item_Group__c();
            POSMItemGroup.ASI_MFM_Sub_brand__c = subbrandMap.get(npl.ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Sub_Brand_RP6__c);
            POSMItemGroup.ASI_CRM_CN_Chinese_Name__c = npl.ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Description_CH__c;
            POSMItemGroup.ASI_CRM_CN_Eng_Name__c = npl.ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Description_GE__c;
            POSMItemGroup.ASI_MFM_Item_Group_Code__c = npl.ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Goup_Code__c;
            POSMItemGroup.OwnerId = npl.OwnerId;
            POSMItemGroup.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
            POSMItemGroupList.add(POSMItemGroup);
        }
        if (!POSMItemGroupList.isEmpty()) {
            insert POSMItemGroupList;
        }
        

    }

}