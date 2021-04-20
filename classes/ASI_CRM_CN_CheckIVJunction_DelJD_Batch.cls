Global class ASI_CRM_CN_CheckIVJunction_DelJD_Batch implements Database.Batchable<sObject>, Database.Stateful{

    Private Static Final Id CN_JUNC_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Junc_Detail__cASI_CRM_CN_Junction_Detail');
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        string sSQL = ' SELECT ID ' +
                        ' FROM ASI_CRM_Inventory_Visibility_Junc_Detail__c ' +
                        ' WHERE RecordTypeId = :CN_JUNC_RECORD_TYPE_ID ' +
            			' ORDER BY LASTMODIFIEDDATE ';
        return Database.getQueryLocator(sSQL);
    }
    
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_CRM_Inventory_Visibility_Junc_Detail__c> ltOrgScope = (List<ASI_CRM_Inventory_Visibility_Junc_Detail__c>) scope;
        Database.DeleteResult[] oExeResult = Database.delete(ltOrgScope, false);
    }
    
    Global void finish(Database.BatchableContext BC){
    }

}