global without sharing class ASI_MFM_CN_ClosePO_Ctrl {
    
    public string msg {set;get;}
    public Id BatchId {get;set;}
    public Id LogId {get;set;}
    public Map<String,String> pickListFYmap {get;set;}
    public Set<String> pickListFYkey {get;set;}
    public String jsonPhaseList;

    public ASI_MFM_PO_Line_Item__c poline{get;set;}
    public ASI_MFM_CN_ClosePO_Ctrl() {
        poline = new ASI_MFM_PO_Line_Item__c();
        
        pickListFYkey = new Set<String>();
        pickListFYmap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = ASI_MFM_Prefix__c.ASI_MFM_Fiscal_year__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListFYkey.add(pickListVal.getValue());
                pickListFYmap.put(pickListVal.getValue(),pickListVal.getLabel());
            }
    }
    public static String getSql(string fields, string fy, string poid, string ownerid){
        String strSql = 'SELECT '+fields+' FROM ASI_MFM_PO_Line_Item__c WHERE recordType.developerName LIKE \'ASI_MFM_CN_PO_Line_Item\' AND ASI_MFM_CN_ReceiptNotPaid__c!=0';
        strSql += ' AND ASI_MFM_PO__r.recordType.developerName LIKE \'ASI_MFM_CN_PO%\'';
        strSql += ' AND ASI_MFM_PO__r.ASI_MFM_Status__c Like \'Final\'';
        strSql += ' AND ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c = \''+fy+'\'';
        if(poid!=null && poid!='') {strSql += ' AND ASI_MFM_PO__c = \''+poid+'\'';}
        if(ownerid!=null && ownerid!='') {strSql += ' AND ASI_MFM_PO__r.OwnerId = \''+ownerid+'\'';}
        system.debug('###');
        system.debug('###'+strSql);
        return strSql;
    }
/*    
    public static String getSql(string fields, string searchType, string value){
        String strSql = 'SELECT '+fields+' FROM ASI_MFM_PO_Line_Item__c WHERE recordType.developerName LIKE \'ASI_MFM_CN_PO_Line_Item\' AND ASI_MFM_CN_ReceiptNotPaid__c!=0';
        strSql += ' AND ASI_MFM_PO__r.recordType.developerName LIKE \'ASI_MFM_CN_PO%\'';
        if(searchType=='po') {
            strSql += ' AND ASI_MFM_PO__c = \''+value+'\'';
        } else if(searchType=='owner') {
            strSql += ' AND ASI_MFM_PO__r.OwnerId = \''+value+'\'';
        } else if(searchType=='fy') {
            strSql += ' AND ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c = \''+value+'\'';
        } else {
            return '';
        }
        return strSql;
    }
/*    
    @RemoteAction
    public static Integer searchPO(string searchType, string value){
        String strSql = getSql('count()',searchType,value);
        if(strSql=='') return 0;
        try {
            return Database.countQuery(strSql);
        } catch(Exception e){
            return 0;
        }
    }
*/
    @RemoteAction
    public static Integer searchPO(string fy, string poid, string ownerid){
        String strSql = getSql('count()',fy,poid,ownerid);
        try {
            return Database.countQuery(strSql);
        } catch(Exception e){
            return 0;
        }
    }
    
    @RemoteAction
    public static List<ASI_MFM_PO__c> searchPOList(string searchType, string value){
        String strSql = 'SELECT id, name, OwnerId, Owner.Name FROM ASI_MFM_PO__c WHERE recordType.developerName LIKE \'ASI_MFM_CN_PO%\'';
        if(searchType=='po') {
            strSql += ' AND Id = \''+value+'\'';
        } else if(searchType=='owner') {
            strSql += ' AND OwnerId = \''+value+'\'';
        } else if(searchType=='fy') {
            strSql += ' AND ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c = \''+value+'\'';
        } else {
            return new List<ASI_MFM_PO__c>();
        }
        if(strSql=='') return new List<ASI_MFM_PO__c>();
        try {
            return Database.query(strSql);
        } catch(Exception e){
            return new List<ASI_MFM_PO__c>();
        }
    }
    
    public void startCloseJob(){
        String searchFy  = Apexpages.currentPage().getParameters().get('searchFy');
        String searchPoId = Apexpages.currentPage().getParameters().get('searchPoId');
        String searchOwnerId = Apexpages.currentPage().getParameters().get('searchOwnerId');

		Id rtid = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');        
        ASI_MFM_BatchLog__c log = new ASI_MFM_BatchLog__c(RecordTypeId=rtid, ASI_MFM_Log_Detail__c='', ASI_MFM_LogType__c='Close PO');
        insert log;
		LogId = log.Id;
        String strsql = getSql(' id, ASI_MFM_CN_Paid_Amount__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c ',searchFy,searchPoId,searchOwnerId);
        ASI_MFM_CN_ClosePO_Batch objbatch = new ASI_MFM_CN_ClosePO_Batch(LogId,strsql);
        BatchId = Database.executebatch(objbatch);
    }
    
    public string[] StatusMsgs {
        get {
            string s = msg==null? '': msg;
            if(BatchId!=null) {
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                    s = 'Job Processing. \n Status: '+ aajs[0].Status+'\n';
                    
                    if(aajs[0].ExtendedStatus != null)
                        s += aajs[0].ExtendedStatus;
                    
                    if(aajs[0].Status=='Completed' && LogId!=null) {
                        s = 'Job Completed. \nStatus: '+ aajs[0].Status+'\n';
                        List<ASI_MFM_BatchLog__c> loglist = [SELECT Id, ASI_MFM_Log_Detail__c FROM ASI_MFM_BatchLog__c WHERE ID = :LogId];
                        if(loglist!=null && loglist.size()>0){
                            ASI_MFM_BatchLog__c log = loglist[0];
                            s = 'Job Failure: \n'+log.ASI_MFM_Log_Detail__c;
                        }   
                    }
                }

            }
            return s.split('\n');
        }
    }

	webservice static String closePoById(Id poid){
        Map<String,Object> result = new Map<String,Object>();
        
        result.put('success',true);
        
        String fy = 'FY' + (date.today().month() < 7 ? String.valueOf(date.today().addYears(-1).year() - 2000) + String.valueOf(date.today().year() - 2000) : String.valueOf(date.today().year() - 2000) + String.valueOf(date.today().addYears(1).year() - 2000));
        ASI_MFM_PO__c po = [SELECT id, ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c FROM ASI_MFM_PO__c  WHERE id=:poid];
        if(po.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c != fy) {
            result.put('message','Only allow current FY PO to close');
            result.put('success',false);
            return JSON.serialize(result);
        }

        result.put('message','Close PO success');
        result.put('success',true);
        
        Id PO_RECEIPT_RT = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt');
        Id PO_RECEIPT_ITEM_RT = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_CN_PO_Receipt_item');
        Integer LOG_DETAIL_SIZE = 4000;
        
        ASI_MFM_PO_Receipt__c insertPOReceiptHeader = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = date.today(), recordTypeId = PO_RECEIPT_RT);
        insert insertPOReceiptHeader;
        
        List<ASI_MFM_PO_Receipt_Item__c> insertPOReceiptItemList = new List<ASI_MFM_PO_Receipt_Item__c>();
        for(ASI_MFM_PO_Line_Item__c obj : [
            SELECT id, ASI_MFM_CN_Paid_Amount__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c
            FROM ASI_MFM_PO_Line_Item__c
            WHERE recordType.developerName LIKE 'ASI_MFM_CN%' 
            AND ASI_MFM_CN_ReceiptNotPaid__c!=0
            AND ASI_MFM_PO__c = :poid
        ]){
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
        } else {
            result.put('message','There is no PO Line to close');
        }
        if(errMsg!=''){
            result.put('message',errMsg);
            result.put('success',false);
        }
        
    	return JSON.serialize(result);
    }
	
}