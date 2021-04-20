public without Sharing class ASI_CRM_CN_HeavyContractFinanceCalc {

    public string Msg {set;get;}
    Public Id batchId {Get; Set;}
    Public ASI_TH_CRM_Contract__c cutOffDate {get{
        if(cutOffDate == Null){
            Date returndate = Date.today();
	        Integer EndFY = returndate.year() -3;
	        returndate = Date.newInstance(EndFY,6,30);
	        cutOffDate = new ASI_TH_CRM_Contract__c();
            cutOffDate.ASI_CRM_CN_Effective_Date__c = returndate;
        }
        return cutOffDate;
    } set;}
    
    Public Date lastExecutionDate {Get{
        
        List<ASI_TH_CRM_Contract__c> tmp = new List<ASI_TH_CRM_Contract__c>([SELECT id, ASI_CRM_CN_ETL_Cutoff_Date__c FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_ETL_Cutoff_Date__c != Null AND RecordType.DeveloperName = 'ASI_CRM_CN_Contract' and ASI_TH_CRM_Promotion_Type__c='Heavy Contract On' ORDER BY ASI_CRM_CN_ETL_Cutoff_Date__c DESC Limit 1]);
        if(tmp.size() > 0){
            Return tmp[0].ASI_CRM_CN_ETL_Cutoff_Date__c;
        }else{
            Return Null;
        }
        
    } Set;}
    
    Public void executeLanding(){
        batchId = database.executebatch(new ASI_CRM_CN_HeavyContractFinanceBatch(cutOffDate.ASI_CRM_CN_Effective_Date__c), 1);
        Msg = 'Process Started';
    }
    
    public string[] StatusMsgs {
        get {
            string s = msg==null? '': msg;
            if(BatchId!=null) {
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                    s = aajs[0].Status;
                }
            }
            return s.split('\n');
        }
    }
}