Global class ASI_CRM_CN_CheckIVJunction_DelJ_Batch implements Database.Batchable<sObject>, Database.Stateful{

    Private Static Final Id CN_JUNC_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Junction__cASI_CRM_CN_Junction');
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        string sSQL = ' SELECT ID ' +
                        ' FROM ASI_CRM_Inventory_Visibility_Junction__c ' +
                        ' WHERE RecordTypeId = :CN_JUNC_RECORD_TYPE_ID ' +
            			' ORDER BY LASTMODIFIEDDATE ';
        return Database.getQueryLocator(sSQL);
    }
    
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_CRM_Inventory_Visibility_Junction__c> ltOrgScope = (List<ASI_CRM_Inventory_Visibility_Junction__c>) scope;
        Database.DeleteResult[] oExeResult = Database.delete(ltOrgScope, false);
    }
    
    Global void finish(Database.BatchableContext BC){
    }

}