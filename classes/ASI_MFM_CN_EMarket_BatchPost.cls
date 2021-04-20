Global class ASI_MFM_CN_EMarket_BatchPost implements Database.Batchable<sObject>, Database.Stateful{
	
    private static Final Id G_RTID_BATCH_LOG = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');
    Private Static Final Id G_RTID_PO = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');
    
    Public Id LogId;
    Global ASI_MFM_CN_EMarket_BatchPost(){}
    Global ASI_MFM_CN_EMarket_BatchPost(Id idTmp){
        this.LogId = idTmp;
    }
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        string sWhereClause = '';
        if (this.LogId != NULL)
            sWhereClause = ' AND ID = :LogId ';
        
        string sSQL = ' SELECT ID,NAME ' +
            				' ,ASI_MFM_Log_Detail__c,ASI_MFM_LogType__c,ASI_MFM_Need_Operation__c,ASI_MFM_Operation_Done__c ' +
            			' FROM ASI_MFM_BatchLog__c ' + 
            			' WHERE RecordTypeId = :G_RTID_BATCH_LOG AND ASI_MFM_LogType__c=\'eMarket\' AND ASI_MFM_Need_Operation__c=TRUE ' +
            				sWhereClause +
            			' ORDER BY CREATEDDATE LIMIT 1 ';
        return Database.getQueryLocator(sSQL);
    }

    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_MFM_BatchLog__c> ltOrgScope = (List<ASI_MFM_BatchLog__c>) scope;        
        ASI_MFM_BatchLog__c oLog = ltOrgScope[0];
        
        try{
            ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs oArgs = (ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs)System.JSON.deserialize(oLog.ASI_MFM_Log_Detail__c,ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs.class);
            string sTaskID = oArgs.TaskID;
            if ((sTaskID != '00000000-0000-0000-0000-000000000000') && (sTaskID != NULL) && (sTaskID != '')) {
                List<ASI_MFM_PO__c> ltExistingPO = [SELECT Id, Name, ASI_MFM_Status__c FROM ASI_MFM_PO__c WHERE ASI_MFM_Task_ID__c = :sTaskID AND RecordTypeId =:G_RTID_PO AND ASI_MFM_Status__c != 'Final'];
                for(ASI_MFM_PO__c oRecord : ltExistingPO) {
                    oRecord.ASI_MFM_Status__c = 'Final';
                }
                update ltExistingPO;
            }
        } catch (exception e) {
            
        }
    }

    Global void finish(Database.BatchableContext BC){
    }
    
}