public with sharing class ASI_MFM_SC_POMassUploadCtrl {
    public string nameFile { get; set; }
    public Blob contentFile { get; set; }
    public String reportId { get; set; }
    
    public ASI_mfm_sc_POMassUploadCtrl(){
        List<Report> reports = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName = 'ASI_CRM_VN_Temporary_Actual_Offtake_Report'];
        this.reportId = reports.isEmpty() ? '' : reports.get(0).Id;
    }


    public void uploadCSV(){
        if (String.isEmpty(nameFile)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please upload a file.'));
            return;
        }
    
        Database.executeBatch(new ASI_mfm_SC_POMassValidBatch(contentFile, UserInfo.getUserId()));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The batch job has been queued. You will receive an email notification after the upload complete.'));

        // reset input
        nameFile = null;
        contentFile = null;
    }
}