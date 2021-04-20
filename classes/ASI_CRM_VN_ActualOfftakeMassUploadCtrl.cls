/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ActualOfftakeMassUploadCtrl
 * Description: Controller for ASI_CRM_VN_ActualOfftakeMassUpload
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-17       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public with sharing class ASI_CRM_VN_ActualOfftakeMassUploadCtrl {
    public string nameFile { get; set; }
    public Blob contentFile { get; set; }
    public String reportId { get; set; }
    
    public ASI_CRM_VN_ActualOfftakeMassUploadCtrl(){
        List<Report> reports = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName = 'ASI_CRM_VN_Temporary_Actual_Offtake_Report'];
        this.reportId = reports.isEmpty() ? '' : reports.get(0).Id;
    }


    public void uploadCSV(){
        if (String.isEmpty(nameFile)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please upload a file.'));
            return;
        }
		
        Database.executeBatch(new ASI_CRM_VN_ActualOfftakeMassValidBatch(contentFile, UserInfo.getUserId()));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The batch job has been queued. You will receive an email notification after the upload complete.'));

        // reset input
        nameFile = null;
        contentFile = null;
    }

    public void genActualOfftake(){
        Database.executeBatch(new ASI_CRM_VN_ActualOfftakeMassGenBatch(UserInfo.getUserId()));
        Database.executeBatch(new ASI_CRM_VN_MCF_Contract_Batch(),1);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The batch job has been queued. You will receive an email notification after the generation complete.'));
    }

    public void deleteTempOfftake(){
        Database.executeBatch(new ASI_CRM_VN_ActualOfftakeMassDeleteBatch(UserInfo.getUserId()));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The batch job has been queued. You will receive an email notification after the delete complete.'));
    }

}