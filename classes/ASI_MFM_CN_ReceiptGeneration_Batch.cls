Global class ASI_MFM_CN_ReceiptGeneration_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    Private Static Final Id PO_RECEIPT_RT = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt');
    Private Static Final Id PO_RECEIPT_ITEM_RT = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_CN_PO_Receipt_item');
    Private Static ASI_MFM_PO_Receipt__c insertPOReceiptHeader;
    Private Static Final Double PO_NOTIFICATION_THRESHOLD = 1000000;
    Private Static Set<String> PO_TYPE_SET = new Set<String>{'EMARKET', 'IT OPEX', 'IT CAPEX HARDWARE REGION', 'IT CAPEX HARDWARE HQ', 'IT CAPEX SOFTWARE', 'IT CAPEX RENOVATION'};
    Public Id LogId;
    Global ASI_MFM_CN_ReceiptGeneration_Batch(){}
    Global ASI_MFM_CN_ReceiptGeneration_Batch(Id log){
        this.LogId = log;
    }
    Global Database.QueryLocator start(Database.BatchableContext BC){        
        String fy = 'FY' + (date.today().month() < 7 ? String.valueOf(date.today().addYears(-1).year() - 2000) + String.valueOf(date.today().year() - 2000) : String.valueOf(date.today().year() - 2000) + String.valueOf(date.today().addYears(1).year() - 2000));
        Date thisMonth = date.newInstance(date.today().year(), date.today().month(), 1);
        String whereClause = ' WHERE (ASI_MFM_Last_Receipt_Date__c < : thisMonth OR ASI_MFM_Last_Receipt_Date__c = Null) AND ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c Like \'' + fy + '\' AND ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c != \'61202305\' AND ASI_MFM_Latest_Phasing__c = True AND (NOT ASI_MFM_PO__r.ASI_MFM_PO_Type__c IN : PO_TYPE_SET)  AND ASI_MFM_PO__r.ASI_MFM_BU_Code__r.ASI_MFM_Auto_Receipt__c = True AND ASI_MFM_PO__r.ASI_MFM_Fully_Receipted__c = False AND ASI_MFM_PO__r.ASI_MFM_Status__c Like \'Final\'';
        String additionalFields = '';
        
        String queryStr = queryReceiptPhasing(additionalFields, whereClause);
        
        return Database.getQueryLocator(queryStr);
    }

    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Integer currentMonth = Date.today().month() < 7 ? Date.today().month() + 6 : Date.today().month() - 6;
		
        Set<Id> poIdSet = new Set<Id>();
        
        List<ASI_MFM_PO_Receipt_Phasing__c> receiptPhasingList = (List<ASI_MFM_PO_Receipt_Phasing__c>) scope;
        List<ASI_MFM_PO_Receipt_Item__c> insertPOReceiptItemList = new List<ASI_MFM_PO_Receipt_Item__c>();
        
        Map<Id, ASI_MFM_PO_Line_Item__c> mapPOLinebyPOId = new Map<Id, ASI_MFM_PO_Line_Item__c>();
        Map<Id, List<ASI_MFM_PO_Line_Item__c>> mapPOLinsbyPOId = new Map<Id, List<ASI_MFM_PO_Line_Item__c>>();
        
        Boolean hasLine = False;
        
        for(ASI_MFM_PO_Receipt_Phasing__c obj : receiptPhasingList){
            
            poIdSet.add(obj.ASI_MFM_PO__c);
            
            double cumulativeAmt = 0;
            
            for(integer i = 1; i <= currentMonth; i++){
                
                String phasingAmount = 'ASI_MFM_Allocated_Amount_' + ( i < 7 ? i + 6 : i - 6) + '__c';
                
                cumulativeAmt += double.valueOf(obj.get(phasingAmount) != Null ? obj.get(phasingAmount) : 0);
            }
            
            if(cumulativeAmt != 0)
                hasLine = True;
        }
        
        for(ASI_MFM_PO_Line_Item__c poline : [SELECT id, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Amount__c, ASI_MFM_Currency__c, ASI_MFM_PO__c, ASI_MFM_PO__r.ASI_MFM_CN_PO_Amount_RMB__c, ASI_MFM_A_C_Code__c FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c IN : poIdSet]){
            
            List<ASI_MFM_PO_Line_Item__c> tmp = new List<ASI_MFM_PO_Line_Item__c>();
            
            if(mapPOLinsbyPOId.containsKey(poline.ASI_MFM_PO__c))
                tmp = mapPOLinsbyPOId.get(poline.ASI_MFM_PO__c);
            
            tmp.add(poline);
            mapPOLinsbyPOId.put(poline.ASI_MFM_PO__c, tmp);
            
            mapPOLinebyPOId.put(poline.ASI_MFM_PO__c, poline);
        }
        
        if(insertPOReceiptHeader == Null /*&& hasLine*/){
            insertPOReceiptHeader = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = date.today()
                                                              , recordTypeId = PO_RECEIPT_RT
                                                              , ASI_MFM_Auto_Receipt__c = True
                                                             );
            
            try{
                
                Insert insertPOReceiptHeader;
                
            }catch(dmlException dmle){
                system.debug(dmle.getMessage());
            }
        }
        
        for(ASI_MFM_PO_Receipt_Phasing__c obj : receiptPhasingList){
            
            double cumulativeAmt = 0;
            
            for(integer i = 1; i <= currentMonth; i++){
                
                String phasingAmount = 'ASI_MFM_Allocated_Amount_' + ( i < 7 ? i + 6 : i - 6) + '__c';
                
                cumulativeAmt += double.valueOf(obj.get(phasingAmount) != Null ? obj.get(phasingAmount) : 0);
                
                integer year;
                
                if(i < 7 && date.today().month() < 7)
                    year = date.today().addYears(-1).year();
                else if((i >= 7 && date.today().month() < 7) || (i < 7 && date.today().month() >= 7))
                    year = date.today().year();
                else if(i >= 7 && date.today().month() >= 7)
                    year = date.today().addYears(1).year();
                
                
                date receiptdate = date.newInstance(year, ( i < 7 ? i + 6 : i - 6), 1);
            }
            
            if(mapPOLinebyPOId.containsKey(obj.ASI_MFM_PO__c) /*&& cumulativeAmt != 0*/){
                
                for(ASI_MFM_PO_Line_Item__c poline : mapPOLinsbyPOId.get(obj.ASI_MFM_PO__c)){
                    
                    Double poAmt = 0;
                    
                    if(cumulativeAmt > poline.ASI_MFM_Amount__c){
                        poAmt = poline.ASI_MFM_Amount__c;
                        cumulativeAmt = cumulativeAmt - poline.ASI_MFM_Amount__c;
                    }else{
                        poAmt = cumulativeAmt;
                        cumulativeAmt = 0;
                    }
                    
                    //20200804:AM@Introv - fix error when amount = 0 (PO receipt validation)
                    if (poAmt > 0) {
                        insertPOReceiptItemList.add(new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_Amount__c = poAmt
                                                                                   , recordTypeId = PO_RECEIPT_ITEM_RT
                                                                                   , ASI_MFM_PO_Line_Item__c = poline.id
                                                                                   , ASI_MFM_Sub_brand_temp__c = poline.ASI_MFM_Sub_brand_Code__c
                                                                                   , ASI_MFM_A_C_Code_temp__c = poline.ASI_MFM_A_C_Code__c
                                                                                   , ASI_MFM_PO_Receipt__c = insertPOReceiptHeader.id
                                                                                   , ASI_MFM_Auto_Receipt__c = True
                                                                                   , ASI_MFM_Receipt_Date__c = date.today()
                                                                                   , ASI_MFM_Currency_Temp__c = poline.ASI_MFM_Currency__c
                                                                                  ));
                    }
                }
                
                /*insertPOReceiptItemList.add(new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_Amount__c = cumulativeAmt
                                                                           , recordTypeId = PO_RECEIPT_ITEM_RT
                                                                           , ASI_MFM_PO_Line_Item__c = mapPOLinebyPOId.get(obj.ASI_MFM_PO__c).id
                                                                           , ASI_MFM_Sub_brand_temp__c = mapPOLinebyPOId.get(obj.ASI_MFM_PO__c).ASI_MFM_Sub_brand_Code__c
                                                                           , ASI_MFM_A_C_Code_temp__c = mapPOLinebyPOId.get(obj.ASI_MFM_PO__c).ASI_MFM_A_C_Code__c
                                                                           , ASI_MFM_PO_Receipt__c = insertPOReceiptHeader.id
                                                                           , ASI_MFM_Auto_Receipt__c = True
                                                                           , ASI_MFM_Receipt_Date__c = date.today()
                                                                           , ASI_MFM_Currency_Temp__c = mapPOLinebyPOId.get(obj.ASI_MFM_PO__c).ASI_MFM_Currency__c
                                                                          ));*/
            }
            
            
            obj.ASI_MFM_Last_Receipt_Date__c = date.today();
            
            if(mapPOLinebyPOId.containsKey(obj.ASI_MFM_PO__c)
               && mapPOLinebyPOId.get(obj.ASI_MFM_PO__c).ASI_MFM_PO__r.ASI_MFM_CN_PO_Amount_RMB__c > PO_NOTIFICATION_THRESHOLD
               && date.newInstance(date.today().year(), date.today().addMonths(1).month(), 1).addDays(-7) == date.today()){
                   
                   obj.ASI_MFM_Auto_Receipt_Notification__c = True;
			}
        }
        
        try{
            
            if(insertPOReceiptItemList.size() > 0)
                Insert insertPOReceiptItemList;
            Update receiptPhasingList;
            
            
        }catch(dmlException dmle){
            // ADD Logger @ 201903
            if(LogId!=null) {
                ASI_MFM_BatchLog__c logger = [SELECT id, ASI_MFM_Log_Detail__c FROM ASI_MFM_BatchLog__c WHERE id =:LogId];
                logger.ASI_MFM_Log_Detail__c += dmle.getMessage()+'\n';
                update logger;
            }
            system.debug(dmle.getMessage());
        }
    }
    
    Global void finish(Database.BatchableContext BC){
        
        if(insertPOReceiptHeader != Null){
            List<ASI_MFM_PO_Receipt_Item__c> receiptLineList = new List<ASI_MFM_PO_Receipt_Item__c>([SELECT id FROM ASI_MFM_PO_Receipt_Item__c WHERE ASI_MFM_PO_Receipt__c = : insertPOReceiptHeader.id]);
            if(receiptLineList.size() == 0) {
                insertPOReceiptHeader.ASI_MFM_ETL__c = FALSE;
                insertPOReceiptHeader.ASI_MFM_Auto_Receipt__c = FALSE;
                update insertPOReceiptHeader;
                
                delete insertPOReceiptHeader;
            }
        }
    }
    
    @TestVisible
    Private Static String queryReceiptPhasing(String additionalFields, String whereClause){
        
        Map<String, Schema.SObjectField> phasing_FIELD_MAP = Schema.SObjectType.ASI_MFM_PO_Receipt_Phasing__c.fields.getMap();
        
        String queryStr = 'SELECT ';
        
        queryStr += String.join(new List<String>(phasing_FIELD_MAP.keySet()), ', ');
        
        queryStr += additionalFields;
        
        queryStr += ' FROM ASI_MFM_PO_Receipt_Phasing__c ' + whereClause;
        
        Return queryStr;
    }
}