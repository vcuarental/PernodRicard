Global class ASI_MFM_CN_ClosePO_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    private static Final Id PO_RECEIPT_RT = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt');
    private static Final Id PO_RECEIPT_ITEM_RT = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_CN_PO_Receipt_item');
    private static Final Integer LOG_DETAIL_SIZE = 4000;
    private ASI_MFM_PO_Receipt__c insertPOReceiptHeader;
    
	public Id LogId;
    public String strSql;
        
    Global ASI_MFM_CN_ClosePO_Batch(){}
    Global ASI_MFM_CN_ClosePO_Batch(Id log, String str){
        this.LogId = log;
        this.strSql = str;
        if(this.insertPOReceiptHeader==null) {
            this.insertPOReceiptHeader = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = date.today(), recordTypeId = PO_RECEIPT_RT);
            insert this.insertPOReceiptHeader;
        }
    }
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(strSql);
    }
    
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_MFM_PO_Line_Item__c> poLineList = (List<ASI_MFM_PO_Line_Item__c>) scope;
        List<ASI_MFM_PO_Receipt_Item__c> insertPOReceiptItemList = new List<ASI_MFM_PO_Receipt_Item__c>();
        if(insertPOReceiptHeader==null) {
            insertPOReceiptHeader = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = date.today(), recordTypeId = PO_RECEIPT_RT);
            insert insertPOReceiptHeader;
        }
        
        for(ASI_MFM_PO_Line_Item__c obj : poLineList){
            insertPOReceiptItemList.add(new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_Amount__c = obj.ASI_MFM_CN_Paid_Amount__c
                                                                       , recordTypeId = PO_RECEIPT_ITEM_RT
                                                                       , ASI_MFM_PO_Line_Item__c = obj.id
                                                                       , ASI_MFM_Sub_brand_temp__c = obj.ASI_MFM_Sub_brand_Code__c
                                                                       , ASI_MFM_A_C_Code_temp__c = obj.ASI_MFM_A_C_Code__c
                                                                       , ASI_MFM_PO_Receipt__c = insertPOReceiptHeader.id
                                                                       , ASI_MFM_Receipt_Date__c = date.today()
                                                                       , ASI_MFM_Currency_Temp__c = obj.ASI_MFM_Currency__c
                                                                      ));
        }
        
        String errMsg = '';
        if(insertPOReceiptItemList.size()>0) {
            Database.SaveResult[] insertResults = Database.insert(insertPOReceiptItemList, false);
            for(Integer i=0;i<insertResults.size();i++){
                Database.SaveResult sr = insertResults.get(i);
                if(sr.isSuccess()){
                    // success updated record;
                } else {
                    if(errMsg.length()<LOG_DETAIL_SIZE) {
                        errMsg += 'Receipt Item for PO Line('+insertPOReceiptItemList.get(i).ASI_MFM_PO_Line_Item__c+')\n';
                        for(Database.Error err : sr.getErrors()) {
                            errMsg += err.getStatusCode() + ': ' + err.getMessage() + err.getFields()+'\n';
                        }
                    }
                }
            }
        }
        if(errMsg!='' && LogId!=null) {
            ASI_MFM_BatchLog__c logger = [SELECT id, ASI_MFM_Log_Detail__c  FROM ASI_MFM_BatchLog__c WHERE id =:LogId];
            if(logger.ASI_MFM_Log_Detail__c==null) logger.ASI_MFM_Log_Detail__c='';
            if(logger.ASI_MFM_Log_Detail__c.length()+errMsg.length() < LOG_DETAIL_SIZE ) {
                logger.ASI_MFM_Log_Detail__c += errMsg;
            } else {
                logger.ASI_MFM_Log_Detail__c = (logger.ASI_MFM_Log_Detail__c+errMsg).substring(0, LOG_DETAIL_SIZE)+'...';
            }
            update logger;
        }        
    }
    
    Global void finish(Database.BatchableContext BC){
        if(insertPOReceiptHeader != null){
            Integer itemCount = [SELECT count() FROM ASI_MFM_PO_Receipt_Item__c WHERE ASI_MFM_PO_Receipt__c = :insertPOReceiptHeader.id];
            if(itemCount == 0) delete insertPOReceiptHeader;
        }
        if(LogId!=null) {
            ASI_MFM_BatchLog__c logger = [SELECT id, ASI_MFM_Log_Detail__c  FROM ASI_MFM_BatchLog__c WHERE id =:LogId];
            if(logger.ASI_MFM_Log_Detail__c==null || logger.ASI_MFM_Log_Detail__c=='') {
                delete logger;
            }
        }
    }
    
}