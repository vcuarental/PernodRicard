public without Sharing class ASI_CRM_CN_ContractFinanceLanding {

    public string Msg {set;get;}
    Public Id batchId {Get; Set;}
    Public ASI_TH_CRM_Contract__c cutOffDate {get{
        if(cutOffDate == Null){
            cutOffDate = new ASI_TH_CRM_Contract__c();
            cutOffDate.ASI_CRM_CN_Effective_Date__c = date.today();
        }
        return cutOffDate;
    } set;}
    
    Public Date lastExecutionDate {Get{
        
        List<ASI_TH_CRM_Contract__c> tmp = new List<ASI_TH_CRM_Contract__c>([SELECT id, ASI_CRM_Landing_Cutoff_Date__c FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_Landing_Cutoff_Date__c != Null ORDER BY ASI_CRM_Landing_Cutoff_Date__c DESC Limit 1]);
        if(tmp.size() > 0){
            Return tmp[0].ASI_CRM_Landing_Cutoff_Date__c;
        }else{
            Return Null;
        }
        
    } Set;}
    
    Public void executeLanding(){
        batchId = database.executebatch(new ASI_CRM_CN_ContractFinanceLandingBatch(cutOffDate.ASI_CRM_CN_Effective_Date__c), 50);
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