Global class ASI_CRM_CN_CheckIVJunctionD_Batch implements Database.Batchable<sObject>, Database.Stateful{
	Private Static Final Id CN_JUNCTION_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Junction__cASI_CRM_CN_Junction');
    
    Private Static Final Id CN_SUMMARY_DETAIL_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Summary__cASI_CRM_CN_Detail');
    Private Static Final Id CN_JUNCTION_DETAIL_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Junc_Detail__cASI_CRM_CN_Junction_Detail');
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        string sSQL = ' SELECT ID,NAME,ASI_CRM_Item_Group__c,ASI_CRM_Location_Code__c,ASI_CRM_Sequence__c,ASI_CRM_Warehouse__r.ASI_FOC_Status__c,ASI_CRM_Detail__r.ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c,ASI_CRM_Date__c ' +
            			' FROM ASI_CRM_Inventory_Visibility_Junction__c ' + 
            			' WHERE ASI_CRM_Auto_Completed__c=FALSE AND RecordTypeId=:CN_JUNCTION_RECORD_TYPE_ID ' +
            			' ORDER BY LASTMODIFIEDDATE ';
        return Database.getQueryLocator(sSQL);
    }
    
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_CRM_Inventory_Visibility_Junction__c> ltOrgScope = (List<ASI_CRM_Inventory_Visibility_Junction__c>) scope;
        
        //1) generate header
        Map<String, String> mapDetailKey = getMapDetailKey(ltOrgScope);
        
        //2) generate and update junction
        genAndUpdateJunc(ltOrgScope, mapDetailKey);
        
        //3) update detail flag
        updateDetailFlag(ltOrgScope);
    }

	Private Static void genAndUpdateJunc(List<ASI_CRM_Inventory_Visibility_Junction__c> ltDetail, Map<String, String> mapDetailKey) {
        List<ASI_CRM_Inventory_Visibility_Junc_Detail__c> ltInsert = new List<ASI_CRM_Inventory_Visibility_Junc_Detail__c>();
        
        Map<string, Id> mapHeaderCode = new Map<string, Id>();
        Map<Id, ASI_CRM_Inventory_Visibility_Summary__c> mapRawHeader = new Map<Id, ASI_CRM_Inventory_Visibility_Summary__c>([
            SELECT Id, ASI_CRM_Key__c 
            FROM ASI_CRM_Inventory_Visibility_Summary__c
            WHERE RecordTypeId = :CN_SUMMARY_DETAIL_RECORD_TYPE_ID
            	AND ASI_CRM_Key__c IN :mapDetailKey.values()
        ]);
        for(Id idHeader : mapRawHeader.keySet()) {
            ASI_CRM_Inventory_Visibility_Summary__c oHeader = mapRawHeader.get(idHeader);
            mapHeaderCode.put(oHeader.ASI_CRM_Key__c, idHeader);
        }
        
        for (ASI_CRM_Inventory_Visibility_Junction__c oRecord : ltDetail) {
            if (mapDetailKey.containsKey(oRecord.Id)) {
                if (mapHeaderCode.containsKey(mapDetailKey.get(oRecord.Id))) {
                    ltInsert.add(new ASI_CRM_Inventory_Visibility_Junc_Detail__c(
                        RecordTypeID = CN_JUNCTION_DETAIL_RECORD_TYPE_ID
                        , ASI_CRM_Summary__c = mapHeaderCode.get(mapDetailKey.get(oRecord.Id))
                        , ASI_CRM_Junction__c = oRecord.Id
                    ));
                }
            }
            if (oRecord.ASI_CRM_Sequence__c == 4) {
                id idItemGroup = oRecord.ASI_CRM_Item_Group__c;
                string sLocation = oRecord.ASI_CRM_Location_Code__c;
                integer iSequence = 3;
            	string sPONumber = oRecord.ASI_CRM_Detail__r.ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c;
                string sKey = String.valueOf(idItemGroup) + '_' + sLocation + '_' + String.valueOf(iSequence);
                ltInsert.add(new ASI_CRM_Inventory_Visibility_Junc_Detail__c(
                    RecordTypeID = CN_JUNCTION_DETAIL_RECORD_TYPE_ID
                    , ASI_CRM_Summary__c = mapHeaderCode.get(sKey)
                    , ASI_CRM_Junction__c = oRecord.Id
                ));
            }
        }
        
        Database.SaveResult[] oExeResult = Database.insert(ltInsert, false);
    }
    
    Private Static Map<String, String> getMapDetailKey(List<ASI_CRM_Inventory_Visibility_Junction__c> ltDetail) {
        Map<String, ASI_CRM_Inventory_Visibility_Summary__c> mapHeader = new Map<String, ASI_CRM_Inventory_Visibility_Summary__c>();
        
        Map<String, String> mapDetailKey = new Map<String, String>();
        
        for(ASI_CRM_Inventory_Visibility_Junction__c oRecord : ltDetail) {
            id idItemGroup = oRecord.ASI_CRM_Item_Group__c;
            string sLocation = oRecord.ASI_CRM_Location_Code__c;
            integer iSequence = integer.valueOf(oRecord.ASI_CRM_Sequence__c);
            string sWHStatus = oRecord.ASI_CRM_Warehouse__r.ASI_FOC_Status__c;
            string sPONumber = oRecord.ASI_CRM_Detail__r.ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c;
            date dtDate = oRecord.ASI_CRM_Date__c;

            switch on iSequence {
                when 1,2{
                    //20200217:AM - no filter in order to match summary report start
                    /*
                    if (dtDate == null) continue;
                    datetime dtDatetime = Datetime.newInstance(dtDate.year(), dtDate.month(), dtDate.day());
                    string sKey = String.valueOf(idItemGroup) + '_' + sLocation + '_' + String.valueOf(iSequence) + '_' + sPONumber + '_' + dtDatetime.format('yyyyMMdd');
                    */
                    string sKey = String.valueOf(idItemGroup) + '_' + sLocation + '_' + String.valueOf(iSequence) + '_' + sPONumber + '_';
                    if (dtDate == null) {
                        sKey += 'null';
                    }
                    else {
                        datetime dtDatetime = Datetime.newInstance(dtDate.year(), dtDate.month(), dtDate.day());
                        sKey += dtDatetime.format('yyyyMMdd');
                    }
                    //20200217:AM - no filter in order to match summary report end
                    
                    mapDetailKey.put(oRecord.Id, sKey);
                    mapHeader.put(sKey, new ASI_CRM_Inventory_Visibility_Summary__c(
                        RecordTypeId = CN_SUMMARY_DETAIL_RECORD_TYPE_ID
                        , ASI_CRM_Item_Group__c = idItemGroup
                        , ASI_CRM_Location__c = sLocation
                        , ASI_CRM_Sequence__c = iSequence
                        , ASI_CRM_PO_Number__c = sPONumber
                        , ASI_CRM_Date__c = dtDate
                        , ASI_CRM_Key__c = sKey
                    ));
                }
                when 3{
                    string sKey = String.valueOf(idItemGroup) + '_' + sLocation + '_' + String.valueOf(iSequence);
                    
                    mapDetailKey.put(oRecord.Id, sKey);
                    mapHeader.put(sKey, new ASI_CRM_Inventory_Visibility_Summary__c(
                        RecordTypeId = CN_SUMMARY_DETAIL_RECORD_TYPE_ID
                        , ASI_CRM_Item_Group__c = idItemGroup
                        , ASI_CRM_Location__c = sLocation
                        , ASI_CRM_Sequence__c = iSequence
                        //, ASI_CRM_PO_Number__c = sPONumber
                        , ASI_CRM_Key__c = sKey
                    ));
                }
                when 4{
                    //20200217:AM - no filter in order to match summary report start
                    /*
                    if (dtDate == null) continue;
                    datetime dtDatetime = Datetime.newInstance(dtDate.year(), dtDate.month(), dtDate.day());
                    string sKey = String.valueOf(idItemGroup) + '_' + sLocation + '_' + String.valueOf(iSequence) + '_' + sPONumber + '_' + dtDatetime.format('yyyyMMdd');
                    */
                    string sKey = String.valueOf(idItemGroup) + '_' + sLocation + '_' + String.valueOf(iSequence) + '_' + sPONumber + '_';
                    if (dtDate == null) {
                        sKey += 'null';
                    }
                    else {
                        datetime dtDatetime = Datetime.newInstance(dtDate.year(), dtDate.month(), dtDate.day());
                        sKey += dtDatetime.format('yyyyMMdd');
                    }
                    //20200217:AM - no filter in order to match summary report end
                    
                    mapDetailKey.put(oRecord.Id, sKey);
                    mapHeader.put(sKey, new ASI_CRM_Inventory_Visibility_Summary__c(
                        RecordTypeId = CN_SUMMARY_DETAIL_RECORD_TYPE_ID
                        , ASI_CRM_Item_Group__c = idItemGroup
                        , ASI_CRM_Location__c = sLocation
                        , ASI_CRM_Sequence__c = iSequence
                        , ASI_CRM_PO_Number__c = sPONumber
                        , ASI_CRM_Date__c = dtDate
                        , ASI_CRM_Key__c = sKey
                    ));
                    
                    iSequence = 3;
                    sKey = String.valueOf(idItemGroup) + '_' + sLocation + '_' + String.valueOf(iSequence);
                    mapDetailKey.put(oRecord.Id+'Seq4', sKey);
                    mapHeader.put(sKey, new ASI_CRM_Inventory_Visibility_Summary__c(
                        RecordTypeId = CN_SUMMARY_DETAIL_RECORD_TYPE_ID
                        , ASI_CRM_Item_Group__c = idItemGroup
                        , ASI_CRM_Location__c = sLocation
                        , ASI_CRM_Sequence__c = iSequence
                        //, ASI_CRM_PO_Number__c = sPONumber
                        , ASI_CRM_Key__c = sKey
                    ));
                }
                when 5{
                    string sKey = String.valueOf(idItemGroup) + '_' + sLocation + '_' + String.valueOf(iSequence) + '_' + sPONumber + '_' + sWHStatus;
                    
                    mapDetailKey.put(oRecord.Id, sKey);
                    mapHeader.put(sKey, new ASI_CRM_Inventory_Visibility_Summary__c(
                        RecordTypeId = CN_SUMMARY_DETAIL_RECORD_TYPE_ID
                        , ASI_CRM_Item_Group__c = idItemGroup
                        , ASI_CRM_Location__c = sLocation
                        , ASI_CRM_Sequence__c = iSequence
                        , ASI_CRM_PO_Number__c = sPONumber
                        , ASI_CRM_Warehouse_Status__c = sWHStatus
                        , ASI_CRM_Key__c = sKey
                    ));
                }
            }
        }

        Database.UpsertResult[] oExeResult = Database.upsert(mapHeader.values(), ASI_CRM_Inventory_Visibility_Summary__c.ASI_CRM_Key__c, false);
        
        return mapDetailKey;
    }
    
    Private Static void updateDetailFlag(List<ASI_CRM_Inventory_Visibility_Junction__c> ltDetail) {
        List<ASI_CRM_Inventory_Visibility_Junction__c> ltUpdate = new List<ASI_CRM_Inventory_Visibility_Junction__c>();
        
        for(ASI_CRM_Inventory_Visibility_Junction__c oRecord : ltDetail) {
            ltUpdate.add(new ASI_CRM_Inventory_Visibility_Junction__c(
                ID = oRecord.Id
                ,ASI_CRM_Auto_Completed__c = TRUE
            ));
        }
        
        Database.SaveResult[] oExeResult = Database.update(ltUpdate, false);
    }
    
    Global void finish(Database.BatchableContext BC){
    }

}