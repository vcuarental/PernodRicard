Global class ASI_CRM_CN_CheckIVJunction_Value_Batch implements Database.Batchable<sObject>, Database.Stateful{

    Private Static Final Id CN_JUNCTION_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Junction__cASI_CRM_CN_Junction');
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        string sSQL = ' SELECT ID ' +
                        ' FROM ASI_CRM_Inventory_Visibility_Junction__c ' +
                        ' WHERE RecordTypeId = :CN_JUNCTION_RECORD_TYPE_ID ' +
            			'	AND ( ' +
            			' 		ASI_CRM_Recalculate__c=TRUE OR ASI_CRM_Recalculate_DF__c=TRUE OR ASI_CRM_Recalculate_DP_D2C__c=TRUE OR ASI_CRM_Recalculate_DP_EC__c=TRUE OR ASI_CRM_Recalculate_DP_IHBR__c=TRUE OR ASI_CRM_Recalculate_DP_MOT_Banner__c=TRUE ' +
            			' 		OR ASI_CRM_Recalculate_DP_Normal__c=TRUE OR ASI_CRM_Recalculate_DP_VIP__c=TRUE OR ASI_CRM_Recalculate_DP__c=TRUE OR ASI_CRM_Recalculate_In_transit__c=TRUE OR ASI_CRM_Recalculate_Open_PO__c=TRUE OR ASI_CRM_Recalculate_Pending__c=TRUE ' +
            			'	) ' +
            			' ORDER BY LASTMODIFIEDDATE ';
        return Database.getQueryLocator(sSQL);
    }
    
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_CRM_Inventory_Visibility_Junction__c> ltOrgScope = (List<ASI_CRM_Inventory_Visibility_Junction__c>) scope;
        List<ASI_CRM_Inventory_Visibility_Junction__c> ltUpdate = new List<ASI_CRM_Inventory_Visibility_Junction__c>();
        
        for(ASI_CRM_Inventory_Visibility_Junction__c oRecord : ltOrgScope) {
            ltUpdate.add(new ASI_CRM_Inventory_Visibility_Junction__c(
                ID = oRecord.Id
                ,ASI_CRM_QTY__c = 0
            ));
        }
        
        Database.SaveResult[] oExeResult = Database.update(ltUpdate, false);
    }
    
    Global void finish(Database.BatchableContext BC){
    }

}