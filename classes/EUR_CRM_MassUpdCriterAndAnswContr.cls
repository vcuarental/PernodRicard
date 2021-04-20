public with sharing class EUR_CRM_MassUpdCriterAndAnswContr {
    public string countryCodeStr {get;set;}
    public string fieldToUpdate {get;set;}

    private static final String MESSAGE_TEXT = 'Batch job has been successfully submitted. You will receive a notification when the job is finished.';

    public void runBatchJob(){
            EUR_CRM_PRSSegAspCriteriaMassUpdt batch = new EUR_CRM_PRSSegAspCriteriaMassUpdt(countryCodeStr, fieldToUpdate);
            Database.executeBatch(batch);

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, MESSAGE_TEXT);
            Apexpages.addMessage(msg);
    }

    public void runImageBatchJob() {
            EUR_CRM_PRSAnswerMassUpdate batch = new EUR_CRM_PRSAnswerMassUpdate('%_Question_Set_Image_Level', countryCodeStr);
            Database.executeBatch(batch);

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, MESSAGE_TEXT);
            Apexpages.addMessage(msg);
    }

    public void runVolumeBatchJob() {
            EUR_CRM_PRSAnswerMassUpdate batch = new EUR_CRM_PRSAnswerMassUpdate('%_Question_Set_Volume_Potential', countryCodeStr);
            Database.executeBatch(batch);

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, MESSAGE_TEXT);
            Apexpages.addMessage(msg);
    }
}