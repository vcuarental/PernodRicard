public class ASI_MFM_CN_AutoReceipt_AdminCtrl  {
    
    public string msg {set;get;}
    public Id BatchId {get;set;}
    public Id LogId {get;set;}
    public String jsonPhaseList;
    public string G_ErrorMsg;
    public Boolean EnablePoller{get; set;}
    
    public ASI_MFM_CN_AutoReceipt_AdminCtrl() {
        EnablePoller = TRUE;
    }

    public void startReceiptJob(){
        Id rtid = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');        
        ASI_MFM_BatchLog__c log = new ASI_MFM_BatchLog__c(RecordTypeId = rtid);
        insert log;
		LogId = log.Id;
        ASI_MFM_CN_ReceiptGeneration_Batch objbatch = new ASI_MFM_CN_ReceiptGeneration_Batch(log.Id);
        BatchId = Database.executebatch(objbatch);
    }
    
    public void startEmarketJob(){
        ASI_MFM_CN_EMarket_Batch objbatch = new ASI_MFM_CN_EMarket_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    public void startFOCAutoRejectJob(){
        ASI_FOC_CN_CheckAutoReject_Batch objbatch = new ASI_FOC_CN_CheckAutoReject_Batch();
		BatchId = Database.executebatch(objbatch);
    }

    public void startRepackAutoRejectJob(){
        ASI_MFM_CN_RepackCheckAutoRejectBatch objbatch = new ASI_MFM_CN_RepackCheckAutoRejectBatch();
        BatchId = Database.executebatch(objbatch);
    }
    
    //CN Summary
    public void startIVJunctionJob(){
        ASI_CRM_CN_CheckIVJunction_Batch objbatch = new ASI_CRM_CN_CheckIVJunction_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    public void startIVJunctionValueJob(){
        ASI_CRM_CN_CheckIVJunction_Value_Batch objbatch = new ASI_CRM_CN_CheckIVJunction_Value_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    public void startIVClearSummaryJob(){
        ASI_CRM_CN_CheckIVJunction_CleanS_Batch objbatch = new ASI_CRM_CN_CheckIVJunction_CleanS_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    public void startIVClearDetailsJob(){
        ASI_CRM_CN_CheckIVJunction_CleanD_Batch objbatch = new ASI_CRM_CN_CheckIVJunction_CleanD_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    //CN Detail
    public void startIVJunctionDJob(){
        ASI_CRM_CN_CheckIVJunctionD_Batch objbatch = new ASI_CRM_CN_CheckIVJunctionD_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    public void startIVJunctionDValueJob(){
        ASI_CRM_CN_CheckIVJunctionD_Value_Batch objbatch = new ASI_CRM_CN_CheckIVJunctionD_Value_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    public void startIVClearSummaryDJob(){
        ASI_CRM_CN_CheckIVJunctionD_CleanS_Batch objbatch = new ASI_CRM_CN_CheckIVJunctionD_CleanS_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    public void startIVClearDetailsDJob(){
        ASI_CRM_CN_CheckIVJunctionD_CleanD_Batch objbatch = new ASI_CRM_CN_CheckIVJunctionD_CleanD_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    public void startIVJClearLineJob(){
        ASI_CRM_CN_CheckIVJunction_DelJ_Batch objbatch = new ASI_CRM_CN_CheckIVJunction_DelJ_Batch();
		BatchId = Database.executebatch(objbatch);
    }
    
    public void startIVJDClearLineDJob(){
        ASI_CRM_CN_CheckIVJunction_DelJD_Batch objbatch = new ASI_CRM_CN_CheckIVJunction_DelJD_Batch();
		BatchId = Database.executebatch(objbatch);
    }

    public void startRequestItemCanelJob(){

        ASI_FOC_CN_FreeRequestItemCancelBatch objbatch = new ASI_FOC_CN_FreeRequestItemCancelBatch();
        BatchId = Database.executebatch(objbatch);
    }   
    public string[] StatusMsgs {
        get {
            string s = msg==null? '': msg;
            if(BatchId!=null) {
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                    s = 'Job Processing. \n Status: '+ aajs[0].Status+'\n';	// + CheckAutoReceiptDebug();
                    
                    if(aajs[0].ExtendedStatus != null)
                        s += aajs[0].ExtendedStatus;
                    
                    if(aajs[0].Status=='Completed' && LogId!=null) {
                        s = 'Job Completed. Status: '+ aajs[0].Status+'\n';
                        ASI_MFM_BatchLog__c log = [SELECT Id, ASI_MFM_Log_Detail__c FROM ASI_MFM_BatchLog__c WHERE ID = :LogId];
                        if(log.ASI_MFM_Log_Detail__c!=null) {
                            s = 'Job Failure: \n'+log.ASI_MFM_Log_Detail__c+'\n' + CheckAutoReceiptDebug();
                        }
                    	EnablePoller = FALSE;
                    }
                }

            }
            return s.split('\n');
        }
    }
    
    @TestVisible
    private string CheckAutoReceiptDebug() {
        G_ErrorMsg = '';
        AppendDebugMessage('');
        AppendDebugMessage('CHECK AUTO RECEIPT: START...');
        
        Map<Id,Integer> dupMap = new Map<Id,Integer>();
        Set<Id> dupLineId = new Set<Id>();
        Integer currentMonth = Date.today().month() < 7 ? Date.today().month() + 6 : Date.today().month() - 6;
        String fy = 'FY' + (date.today().month() < 7 ? String.valueOf(date.today().addYears(-1).year() - 2000) + String.valueOf(date.today().year() - 2000) : String.valueOf(date.today().year() - 2000) + String.valueOf(date.today().addYears(1).year() - 2000));
        Date thisMonth = date.newInstance(date.today().year(), date.today().month(), 1);
        Set<Id> poidSet = new Set<Id>();
        List<ASI_MFM_PO_Receipt_Phasing__c> phasingList= [SELECT id, name, ASI_MFM_Last_Receipt_Date__c, ASI_MFM_Amount_Total__c, ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c
                                                          ,ASI_MFM_Allocated_Amount_8__c,ASI_MFM_Allocated_Amount_9__c
                                                          ,ASI_MFM_Allocated_Amount_10__c,ASI_MFM_Allocated_Amount_11__c
                                                          ,ASI_MFM_Allocated_Amount_12__c, ASI_MFM_Allocated_Amount_1__c
                                                          ,ASI_MFM_Allocated_Amount_2__c,ASI_MFM_Allocated_Amount_3__c
                                                          ,ASI_MFM_Allocated_Amount_4__c,ASI_MFM_Allocated_Amount_5__c
                                                          ,ASI_MFM_Allocated_Amount_6__c,ASI_MFM_Allocated_Amount_7__c
                                                          FROM ASI_MFM_PO_Receipt_Phasing__c
                                                          WHERE ASI_MFM_Latest_Phasing__c = True 
                                                          AND (ASI_MFM_Last_Receipt_Date__c < :thisMonth OR ASI_MFM_Last_Receipt_Date__c = Null)
                                                          AND ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c Like :fy 
                                                          AND ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c != '61202305' 
                                                          AND (NOT ASI_MFM_PO__r.ASI_MFM_PO_Type__c IN ('EMARKET','IT CAPEX HARDWARE HQ','IT CAPEX HARDWARE REGION','IT CAPEX RENOVATION','IT CAPEX SOFTWARE','IT OPEX'))  
                                                          AND ASI_MFM_PO__r.ASI_MFM_BU_Code__r.ASI_MFM_Auto_Receipt__c = True 
                                                          AND ASI_MFM_PO__r.ASI_MFM_Fully_Receipted__c = False 
                                                          AND ASI_MFM_PO__r.ASI_MFM_Status__c Like 'Final'
                                                          ORDER BY ASI_MFM_Last_Receipt_Date__c desc];
        for(ASI_MFM_PO_Receipt_Phasing__c phasing : phasingList) 
        {
            poidSet.add(phasing.ASI_MFM_PO__c);
            Double diff = phasing.ASI_MFM_Amount_Total__c - phasing.ASI_MFM_PO__r.ASI_MFM_PO_Amount__c;
            if(diff!=0) {
                system.debug('## po '+phasing.ASI_MFM_PO__c+' -amount : ' + diff);
                AppendDebugMessage('## po '+phasing.ASI_MFM_PO__c+' -amount : ' + diff);
            } else {
                system.debug('## po '+phasing.ASI_MFM_PO__c+' -valid : ' + diff);
                AppendDebugMessage('## po '+phasing.ASI_MFM_PO__c+' -valid : ' + diff);
            }
        }
        system.debug('## poid ' + poidSet);
        AppendDebugMessage('## poid ' + poidSet);
        Map<id,List<ASI_MFM_PO_Line_Item__c>> dummyMap = new Map<Id,List<ASI_MFM_PO_Line_Item__c>>();
        for(ASI_MFM_PO_Line_Item__c poline : [SELECT id, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Amount__c, ASI_MFM_Currency__c, ASI_MFM_PO__c, ASI_MFM_PO__r.ASI_MFM_CN_PO_Amount_RMB__c, ASI_MFM_A_C_Code__c FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c IN : poidSet])
        {
            if(!dummyMap.containskey(poline.ASI_MFM_PO__c)) dummyMap.put(poline.ASI_MFM_PO__c,new List<ASI_MFM_PO_Line_Item__c>());
            dummyMap.get(poline.ASI_MFM_PO__c).add(poline);
        }
        
        for(ASI_MFM_PO_Receipt_Phasing__c obj : phasingList){
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
            
            if(dummyMap.containsKey(obj.ASI_MFM_PO__c) && cumulativeAmt != 0){
                for(ASI_MFM_PO_Line_Item__c poline : dummyMap.get(obj.ASI_MFM_PO__c)){
                    //system.debug('##poline : ' + poline.id);
                    Double poAmt = 0;
                    if(cumulativeAmt > poline.ASI_MFM_Amount__c){
                        poAmt = poline.ASI_MFM_Amount__c;
                        cumulativeAmt = cumulativeAmt - poline.ASI_MFM_Amount__c;
                    }else{
                        poAmt = cumulativeAmt;
                        cumulativeAmt = 0;
                    }
                    if(!dupMap.containsKey(poline.id)) {
                        dupMap.put(poline.id,0);
                    } else {
                        dupMap.put(poline.id,dupMap.get(poline.id)+1);
                        dupLineId.add(poline.id);
                    }
                    system.debug('### poline :' + poline.id + ' amount :' + poline.ASI_MFM_Amount__c + ' receipt : ' + poAmt );
                    AppendDebugMessage('### poline :' + poline.id + ' amount :' + poline.ASI_MFM_Amount__c + ' receipt : ' + poAmt );
                    if(poAmt > poline.ASI_MFM_Amount__c) {
                        system.debug('### !!! ' + poline.ASI_MFM_PO__r.name);
                        AppendDebugMessage('### !!! ' + poline.ASI_MFM_PO__r.name);
                    }
                }
            }
        }
        system.debug(dupLineId);
        AppendDebugMessage('dupLineId: [' + dupLineId + ']');
        
		AppendDebugMessage('CHECK AUTO RECEIPT: END');
        	
        return G_ErrorMsg;
    }
    
    private void AppendDebugMessage(string sMsg) {
        G_ErrorMsg += ('' + sMsg + '\n');
    }
    
}