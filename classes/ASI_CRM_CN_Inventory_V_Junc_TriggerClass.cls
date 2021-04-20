public without sharing class ASI_CRM_CN_Inventory_V_Junc_TriggerClass {
	public static void routineBeforeInsert(list<ASI_CRM_Inventory_Visibility_Junction__c> trigger_new) {
        assignNumberFields(trigger_new);
        assignLookupFields(trigger_new);
        checkIgnoreCount(trigger_new);
    }
    
    public static void routineBeforeUpdate(list<ASI_CRM_Inventory_Visibility_Junction__c> trigger_new, map<id, ASI_CRM_Inventory_Visibility_Junction__c> trigger_oldMap) {
        assignNumberFields(trigger_new);
        checkIgnoreCount(trigger_new);
    }
    
    private static void checkIgnoreCount(list<ASI_CRM_Inventory_Visibility_Junction__c> trigger_new) {
        Set<Id> setDetail = new Set<Id>();
        for (ASI_CRM_Inventory_Visibility_Junction__c oRecord : trigger_new) {
            setDetail.add(oRecord.ASI_CRM_Detail__c);
        }
        
        Map<Id, ASI_CRM_Inventory_Visibility_Detail__c> mapDetail = new Map<Id, ASI_CRM_Inventory_Visibility_Detail__c>([
            SELECT Id, ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c
            FROM ASI_CRM_Inventory_Visibility_Detail__c
            WHERE Id IN :setDetail
        ]);
        
        Set<string> setPONumber = new Set<string>();
        for (Id idDetail : mapDetail.keySet()) {
        	ASI_CRM_Inventory_Visibility_Detail__c oRecord = mapDetail.get(idDetail);
            if (oRecord.ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c != NULL) setPONumber.add(oRecord.ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c);
        }
        
        if (setPONumber.size()>0) {
            Map<Id, ASI_CRM_Inventory_Visibility__c> mapHeader = new Map<Id, ASI_CRM_Inventory_Visibility__c>([
                SELECT Id, name, ASI_CRM_PO_Number__c
                FROM ASI_CRM_Inventory_Visibility__c
                WHERE ASI_CRM_PO_Number__c IN :setPONumber
            ]);
            
            Set<string> setPONumberValid = new Set<string>();
            for (Id idHeader : mapHeader.keySet()) {
                ASI_CRM_Inventory_Visibility__c oRecord = mapHeader.get(idHeader);
                if (oRecord.ASI_CRM_PO_Number__c != NULL) setPONumberValid.add(oRecord.ASI_CRM_PO_Number__c);
            }
            
            for (ASI_CRM_Inventory_Visibility_Junction__c oRecord : trigger_new) {
                Id idDetail = oRecord.ASI_CRM_Detail__c;
                ASI_CRM_Inventory_Visibility_Detail__c oDetail = mapDetail.get(idDetail);
                if (oDetail.ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c != NULL) {
                    if (!setPONumberValid.contains(oDetail.ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c)) oRecord.ASI_CRM_Ignore_Count_Open_PO__c = TRUE;
                }
            }
        }
    }
    
    private static void assignNumberFields(list<ASI_CRM_Inventory_Visibility_Junction__c> trigger_new) {
        for (ASI_CRM_Inventory_Visibility_Junction__c oRecord : trigger_new) {
        	oRecord.ASI_CRM_QTY__c = oRecord.ASI_CRM_Detail_QTY__c;
            oRecord.ASI_CRM_QTY_Duty_Free__c = oRecord.ASI_CRM_Detail_QTY_Duty_Free__c;
            oRecord.ASI_CRM_QTY_Duty_Paid__c = oRecord.ASI_CRM_Detail_QTY_Duty_Paid__c;
            oRecord.ASI_CRM_QTY_In_transit__c = oRecord.ASI_CRM_Detail_QTY_In_transit__c;
            oRecord.ASI_CRM_QTY_Open_PO__c = oRecord.ASI_CRM_Detail_QTY_Open_PO__c;
            oRecord.ASI_CRM_QTY_Pending__c = oRecord.ASI_CRM_Detail_QTY_Pending__c;
            
            oRecord.ASI_CRM_V1_QTY_DF__c = oRecord.ASI_CRM_V1_Detail_QTY_DF__c;
            oRecord.ASI_CRM_V1_QTY_DP_D2C__c = oRecord.ASI_CRM_V1_Detail_QTY_DP_D2C__c;
            oRecord.ASI_CRM_V1_QTY_DP_EC__c = oRecord.ASI_CRM_V1_Detail_QTY_DP_EC__c;
            oRecord.ASI_CRM_V1_QTY_DP_IHBR__c = oRecord.ASI_CRM_V1_Detail_QTY_DP_IHBR__c;
            oRecord.ASI_CRM_V1_QTY_DP_MOT_Banner__c = oRecord.ASI_CRM_V1_Detail_QTY_DP_MOT_Banner__c;
            oRecord.ASI_CRM_V1_QTY_DP_Normal__c = oRecord.ASI_CRM_V1_Detail_QTY_DP_Normal__c;
            oRecord.ASI_CRM_V1_QTY_DP_VIP__c = oRecord.ASI_CRM_V1_Detail_QTY_DP_VIP__c;
            oRecord.ASI_CRM_V1_QTY_In_transit__c = oRecord.ASI_CRM_V1_Detail_QTY_In_transit__c;
            oRecord.ASI_CRM_V1_QTY_Open_PO__c = oRecord.ASI_CRM_V1_Detail_QTY_Open_PO__c;
            oRecord.ASI_CRM_V1_QTY_Pending__c = oRecord.ASI_CRM_V1_Detail_QTY_Pending__c;
            
            if (oRecord.ASI_CRM_QTY__c == null) oRecord.ASI_CRM_QTY__c = 0;
            if (oRecord.ASI_CRM_QTY_Duty_Free__c == null) oRecord.ASI_CRM_QTY_Duty_Free__c = 0;
            if (oRecord.ASI_CRM_QTY_Duty_Paid__c == null) oRecord.ASI_CRM_QTY_Duty_Paid__c = 0;
            if (oRecord.ASI_CRM_QTY_In_transit__c == null) oRecord.ASI_CRM_QTY_In_transit__c = 0;
            if (oRecord.ASI_CRM_QTY_Open_PO__c == null) oRecord.ASI_CRM_QTY_Open_PO__c = 0;
            if (oRecord.ASI_CRM_QTY_Pending__c == null) oRecord.ASI_CRM_QTY_Pending__c = 0;
            
            if (oRecord.ASI_CRM_V1_QTY_DF__c == null) oRecord.ASI_CRM_V1_QTY_DF__c = 0;
            if (oRecord.ASI_CRM_V1_QTY_DP_D2C__c == null) oRecord.ASI_CRM_V1_QTY_DP_D2C__c = 0;
            if (oRecord.ASI_CRM_V1_QTY_DP_EC__c == null) oRecord.ASI_CRM_V1_QTY_DP_EC__c = 0;
            if (oRecord.ASI_CRM_V1_QTY_DP_IHBR__c == null) oRecord.ASI_CRM_V1_QTY_DP_IHBR__c = 0;
            if (oRecord.ASI_CRM_V1_QTY_DP_MOT_Banner__c == null) oRecord.ASI_CRM_V1_QTY_DP_MOT_Banner__c = 0;
            if (oRecord.ASI_CRM_V1_QTY_DP_Normal__c == null) oRecord.ASI_CRM_V1_QTY_DP_Normal__c = 0;
            if (oRecord.ASI_CRM_V1_QTY_DP_VIP__c == null) oRecord.ASI_CRM_V1_QTY_DP_VIP__c = 0;
            if (oRecord.ASI_CRM_V1_QTY_In_transit__c == null) oRecord.ASI_CRM_V1_QTY_In_transit__c = 0;
            if (oRecord.ASI_CRM_V1_QTY_Open_PO__c == null) oRecord.ASI_CRM_V1_QTY_Open_PO__c = 0;
            if (oRecord.ASI_CRM_V1_QTY_Pending__c == null) oRecord.ASI_CRM_V1_QTY_Pending__c = 0;
        }
    }
    
    private static void assignLookupFields(list<ASI_CRM_Inventory_Visibility_Junction__c> trigger_new) {
        Set<Id> setDetail = new Set<Id>();
        for (ASI_CRM_Inventory_Visibility_Junction__c oRecord : trigger_new) {
            setDetail.add(oRecord.ASI_CRM_Detail__c);
        }
        
        Map<Id, ASI_CRM_Inventory_Visibility_Detail__c> mapDetail = new Map<Id, ASI_CRM_Inventory_Visibility_Detail__c>([
            SELECT Id, ASI_CRM_Item_Group__c, ASI_CRM_SKU__c, ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c
            FROM ASI_CRM_Inventory_Visibility_Detail__c
            WHERE Id IN :setDetail
        ]);
        
        Set<string> setWarehouseCode = new Set<string>();
        for (Id idDetail : mapDetail.keySet()) {
        	ASI_CRM_Inventory_Visibility_Detail__c oRecord = mapDetail.get(idDetail);
            setWarehouseCode.add(oRecord.ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c);
        }
        
        Map<string, Id> mapWarehouse = new Map<string, Id>();
        for (ASI_FOC_Warehouse__c oWarehouse : [
            SELECT Id, ASI_FOC_Warehouse_Code__c
            FROM ASI_FOC_Warehouse__c 
            WHERE ASI_FOC_Warehouse_Code__c IN :setWarehouseCode
            	AND RecordType.DeveloperName = 'ASI_CRM_CN_Inventory_Visibility'
        ]) {
            mapWarehouse.put(oWarehouse.ASI_FOC_Warehouse_Code__c, oWarehouse.Id);
        }
        
        for (ASI_CRM_Inventory_Visibility_Junction__c oRecord : trigger_new) {
            ASI_CRM_Inventory_Visibility_Detail__c oDetail = mapDetail.get(oRecord.ASI_CRM_Detail__c);
            oRecord.ASI_CRM_Item_Group__c = oDetail.ASI_CRM_Item_Group__c;
            oRecord.ASI_CRM_SKU__c = oDetail.ASI_CRM_SKU__c;
            
            if ((oDetail.ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c != null) && (oDetail.ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c != '')) {
                if (mapWarehouse.containsKey(oDetail.ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c)) {
                    oRecord.ASI_CRM_Warehouse__c = mapWarehouse.get(oDetail.ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c);
                }
            }
        }
    }
}