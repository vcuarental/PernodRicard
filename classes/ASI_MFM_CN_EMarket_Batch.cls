Global class ASI_MFM_CN_EMarket_Batch implements Database.Batchable<sObject>, Database.Stateful{
	
    private static Final Id G_RTID_BATCH_LOG = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');
    
    Public Id LogId;
    Global ASI_MFM_CN_EMarket_Batch(){}
    Global ASI_MFM_CN_EMarket_Batch(Id idTmp){
        this.LogId = idTmp;
    }
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        string sWhereClause = '';
        if (this.LogId != NULL)
            sWhereClause = ' AND ID = :LogId ';
        
        string sSQL = ' SELECT ID,NAME ' +
            				' ,ASI_MFM_Log_Detail__c,ASI_MFM_LogType__c,ASI_MFM_Need_Operation__c,ASI_MFM_Operation_Done__c ' +
            			' FROM ASI_MFM_BatchLog__c ' + 
            			' WHERE RecordTypeId = :G_RTID_BATCH_LOG AND ASI_MFM_LogType__c=\'eMarket\' AND ASI_MFM_Need_Operation__c=TRUE AND ASI_MFM_Operation_Done__c=FALSE ' +
            				sWhereClause +
            			' ORDER BY CREATEDDATE LIMIT 1 ';
        return Database.getQueryLocator(sSQL);
    }

    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_MFM_BatchLog__c> ltOrgScope = (List<ASI_MFM_BatchLog__c>) scope;
        
        //1) get batch log
        ASI_MFM_BatchLog__c oLog = ltOrgScope[0];
        
        ASI_MFM_BatchLog__c oUpdateLog = new ASI_MFM_BatchLog__c();
        oUpdateLog.Id = oLog.Id;
        oUpdateLog.ASI_MFM_Operation_Done__c = TRUE;
        if (this.LogId == NULL) this.LogId = oLog.Id;
        
        try{
            //2) insert PO, PO line, POSM line
            ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs oArgs = (ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs)System.JSON.deserialize(oLog.ASI_MFM_Log_Detail__c,ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs.class);
            ASI_MFM_CN_WebServiceForEMarket.CreatePOResult oResult = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(oArgs);

            if (oResult.CompletionCode == 'F') {
                oUpdateLog.ASI_MFM_Operation_Error__c = TRUE;
            	oUpdateLog.ASI_MFM_Operation_Error_Message__c = oResult.FailMsg;
            }            
        } catch (exception e) {
            oUpdateLog.ASI_MFM_Operation_Error__c = TRUE;
            oUpdateLog.ASI_MFM_Operation_Error_Message__c = 'System runtime exception error (' + String.valueof(e) + ')';
        }
        
        //3) update flag
        update oUpdateLog;
    }

    Global void finish(Database.BatchableContext BC){
        ASI_MFM_CN_EMarket_BatchPost objbatch = new ASI_MFM_CN_EMarket_BatchPost(this.LogId);
		Id oBatchId = Database.executebatch(objbatch);
    }
    
}