Global class ASI_CRM_CN_CheckIVJunctionD_CleanD_Batch implements Database.Batchable<sObject>, Database.Stateful{

    Private Static Final Id CN_JUNCTION_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility_Junction__cASI_CRM_CN_Junction');
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        string sSQL = ' SELECT ID ' +
                        ' FROM ASI_CRM_Inventory_Visibility_Junction__c ' +
                        ' WHERE ASI_CRM_Auto_Completed__c=TRUE AND RecordTypeId = :CN_JUNCTION_RECORD_TYPE_ID ' +
            			' ORDER BY LASTMODIFIEDDATE ';
        return Database.getQueryLocator(sSQL);
    }
    
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_CRM_Inventory_Visibility_Junction__c> ltOrgScope = (List<ASI_CRM_Inventory_Visibility_Junction__c>) scope;
        List<ASI_CRM_Inventory_Visibility_Junction__c> ltUpdate = new List<ASI_CRM_Inventory_Visibility_Junction__c>();
        
        for(ASI_CRM_Inventory_Visibility_Junction__c oRecord : ltOrgScope) {
            ltUpdate.add(new ASI_CRM_Inventory_Visibility_Junction__c(
                ID = oRecord.Id
                ,ASI_CRM_Auto_Completed__c = FALSE
            ));
        }
        
        Database.SaveResult[] oExeResult = Database.update(ltUpdate, false);
    }
    
    Global void finish(Database.BatchableContext BC){
    }

}