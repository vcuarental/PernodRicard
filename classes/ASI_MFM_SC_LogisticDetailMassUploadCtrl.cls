public with sharing class ASI_MFM_SC_LogisticDetailMassUploadCtrl {

    public string nameFile { get; set; }
    public Blob contentFile { get; set; }
    public String reportId { get; set; }
    public String payheaderId { get; set; }
    public String poHeaderName { get; set; }
    public Id BatchId {get;set;}
    
    
    public ASI_MFM_SC_LogisticDetailMassUploadCtrl(){
      //  List<Report> reports = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName = 'ASI_CRM_VN_Temporary_Actual_Offtake_Report'];
      //  this.reportId = reports.isEmpty() ? '' : reports.get(0).Id;
      payheaderId=Apexpages.currentpage().getparameters().get('PayHeader');
      poHeaderName =Apexpages.currentpage().getparameters().get('PoHeader');
    }


    public void uploadCSV(){
        if (String.isEmpty(nameFile)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please upload a file.'));
            return;
        }
    
        BatchId = Database.executeBatch(new ASI_MFM_SC_LogisPayDetailMassUploadBatch(contentFile, UserInfo.getUserId(),payheaderId ,poHeaderName ));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'The batch job has been queued. You will receive an email notification after the upload complete.'));

        // reset input
        nameFile = null;
        contentFile = null;
    }
    
      public string[] StatusMsgs {
        get {
            string s = '';
            if(BatchId!=null) {
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                	//system.debug('aajs[0].Status:: ' + aajs[0].Status + 'aajs[0].ExtendedStatus::'+ aajs[0].ExtendedStatus);
                	
                    s = aajs[0].Status + (aajs[0].ExtendedStatus == null ? '' : ': ' + aajs[0].ExtendedStatus);
                    if((aajs[0].Status=='Completed') || Test.isRunningTest() ) {
                        ASI_MFM_Payment__c payment = [select ASI_MFM_Sys_Error_Log__c from ASI_MFM_Payment__c where id =:payheaderId  limit 1 ];
                        system.debug('payment:::'+ payment);
                        if(String.isNotBlank(payment.ASI_MFM_Sys_Error_Log__c) || String.isNotEmpty(payment.ASI_MFM_Sys_Error_Log__c)){
                            s ='Upload Failed. Please see errors below.<br/>';
                            s += payment.ASI_MFM_Sys_Error_Log__c;
                        }
                    }
                }
            }
            s.replace('Completed', 'Success');
            return s.split('<br/>');
        }
    }
   
}