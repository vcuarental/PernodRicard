Global class ASI_CRM_CN_CheckIVJunction_Batch implements Database.Batchable<sObject>, Database.Stateful{

    Private Static Final Id CN_DETAIL_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Detail__cASI_CRM_CN_Inventory_Visibility_Detail');
    Private Static Final Id CN_SUMMARY_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Summary__cASI_CRM_CN_Summary');
    Private Static Final Id CN_JUNCTION_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Junction__cASI_CRM_CN_Junction');
    
    Private Static Final Id CN_WH_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_CRM_CN_Inventory_Visibility');
    Private Static Final Map<Id, ASI_FOC_Warehouse__c> MAP_WAREHOUSE = new Map<Id, ASI_FOC_Warehouse__c>([
        SELECT ID,ASI_FOC_Warehouse_Code__c,ASI_MFM_Location_Code__c 
        FROM ASI_FOC_Warehouse__c
        WHERE RecordTypeId = :CN_WH_RECORD_TYPE_ID
    ]);
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        string sSQL = ' SELECT ID,NAME,ASI_CRM_Item_Group__c, ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c ' +
            			' FROM ASI_CRM_Inventory_Visibility_Detail__c ' + 
            			' WHERE ASI_CRM_Auto_Completed__c=FALSE AND RecordTypeId = :CN_DETAIL_RECORD_TYPE_ID ' +
            			' ORDER BY LASTMODIFIEDDATE ';
        return Database.getQueryLocator(sSQL);
    }
    
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_CRM_Inventory_Visibility_Detail__c> ltOrgScope = (List<ASI_CRM_Inventory_Visibility_Detail__c>) scope;
        
        //1) generate header
        Map<Id, String> mapDetailKey = getMapDetailKey(ltOrgScope);
        
        //2) generate and update junction
        genAndUpdateJunc(ltOrgScope, mapDetailKey);
        
        //3) update detail flag
        updateDetailFlag(ltOrgScope);
    }
    
    Private Static void genAndUpdateJunc(List<ASI_CRM_Inventory_Visibility_Detail__c> ltDetail, Map<Id, String> mapDetailKey) {
        List<ASI_CRM_Inventory_Visibility_Junction__c> ltInsert = new List<ASI_CRM_Inventory_Visibility_Junction__c>();
        
        Map<string, Id> mapHeaderCode = new Map<string, Id>();
        Map<Id, ASI_CRM_Inventory_Visibility_Summary__c> mapRawHeader = new Map<Id, ASI_CRM_Inventory_Visibility_Summary__c>([
            SELECT Id, ASI_CRM_Key__c 
            FROM ASI_CRM_Inventory_Visibility_Summary__c
            WHERE RecordTypeId = :CN_SUMMARY_RECORD_TYPE_ID
            	AND ASI_CRM_Key__c IN :mapDetailKey.values()
        ]);
        for(Id idHedaer : mapRawHeader.keySet()) {
            ASI_CRM_Inventory_Visibility_Summary__c oHeader = mapRawHeader.get(idHedaer);
            mapHeaderCode.put(oHeader.ASI_CRM_Key__c, idHedaer);
        }
        
        for (ASI_CRM_Inventory_Visibility_Detail__c oRecord : ltDetail) {
            if (mapDetailKey.containsKey(oRecord.Id)) {
                if (mapHeaderCode.containsKey(mapDetailKey.get(oRecord.Id))) {
                    ltInsert.add(new ASI_CRM_Inventory_Visibility_Junction__c(
                        RecordTypeID = CN_JUNCTION_RECORD_TYPE_ID
                        , ASI_CRM_Summary__c = mapHeaderCode.get(mapDetailKey.get(oRecord.Id))
                        , ASI_CRM_Detail__c = oRecord.Id
                    ));
                }
            }
        }
        
        Database.SaveResult[] oExeResult = Database.insert(ltInsert, false);
    }
    
    Private Static Map<Id, String> getMapDetailKey(List<ASI_CRM_Inventory_Visibility_Detail__c> ltDetail) {
        Map<String, ASI_CRM_Inventory_Visibility_Summary__c> mapHeader = new Map<String, ASI_CRM_Inventory_Visibility_Summary__c>();
        
        Map<Id, String> mapDetailKey = new Map<Id, String>();
        
        for(ASI_CRM_Inventory_Visibility_Detail__c oRecord : ltDetail) {
            if ((oRecord.ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c != NULL) 
                && (oRecord.ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c != '')
                && (oRecord.ASI_CRM_Item_Group__c != NULL)
            ){
                string sCheckDetailCode = oRecord.ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c;
                
                for (Id idWarehouse : MAP_WAREHOUSE.keySet()){
                    ASI_FOC_Warehouse__c oWarehouse = MAP_WAREHOUSE.get(idWarehouse);
                    if (oWarehouse.ASI_FOC_Warehouse_Code__c == sCheckDetailCode) {
                        if ((oWarehouse.ASI_MFM_Location_Code__c != NULL) && (oWarehouse.ASI_MFM_Location_Code__c != '')) {
                            string sKey = String.valueOf(oRecord.ASI_CRM_Item_Group__c) + '_' + oWarehouse.ASI_MFM_Location_Code__c;
                            
                            mapDetailKey.put(oRecord.Id, sKey);
                            mapHeader.put(sKey, new ASI_CRM_Inventory_Visibility_Summary__c(
                                RecordTypeId = CN_SUMMARY_RECORD_TYPE_ID
                                , ASI_CRM_Item_Group__c = oRecord.ASI_CRM_Item_Group__c
                                , ASI_CRM_Location__c = oWarehouse.ASI_MFM_Location_Code__c
                                , ASI_CRM_Key__c = sKey
                            ));
                        }
                    }
                }
			}
        }

        Database.UpsertResult[] oExeResult = Database.upsert(mapHeader.values(), ASI_CRM_Inventory_Visibility_Summary__c.ASI_CRM_Key__c, false);
        
        return mapDetailKey;
    }
    
    Private Static void updateDetailFlag(List<ASI_CRM_Inventory_Visibility_Detail__c> ltDetail) {
        List<ASI_CRM_Inventory_Visibility_Detail__c> ltUpdate = new List<ASI_CRM_Inventory_Visibility_Detail__c>();
        
        for(ASI_CRM_Inventory_Visibility_Detail__c oRecord : ltDetail) {
            ltUpdate.add(new ASI_CRM_Inventory_Visibility_Detail__c(
                ID = oRecord.Id
                ,ASI_CRM_Auto_Completed__c = TRUE
            ));
        }
        
        Database.SaveResult[] oExeResult = Database.update(ltUpdate, false);
    }
    
    Global void finish(Database.BatchableContext BC){
    }

}