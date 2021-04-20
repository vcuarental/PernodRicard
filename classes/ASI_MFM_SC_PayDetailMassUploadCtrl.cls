public with sharing class ASI_MFM_SC_PayDetailMassUploadCtrl {
    public string nameFile { get; set; }
    public Blob contentFile { get; set; }
    public String reportId { get; set; }
    public String payheaderId { get; set; }
    public String poHeaderName { get; set; }
    
    public ASI_MFM_SC_PayDetailMassUploadCtrl(){
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
    
        Database.executeBatch(new ASI_MFM_SC_PayDetailMassUploadBatch(contentFile, UserInfo.getUserId(),payheaderId ,poHeaderName ));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The batch job has been queued. You will receive an email notification after the upload complete.'));

        // reset input
        nameFile = null;
        contentFile = null;
    }
}