public  class EUR_CRM_MassUpdateCriteriaSetBatch{
    public string criteriaSetLevel {get;set;}
    public string countryCodeStr {get;set;}
    public void runImageBatchJob(){
        criteriaSetLevel = '%Image%';
        try{
            EUR_CRM_CriteriaSetMassUpdateController batch = new EUR_CRM_CriteriaSetMassUpdateController(criteriaSetLevel,countryCodeStr );
            Database.executeBatch(batch, 40);
            system.debug('***:batch ' + batch);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
        }catch(Exception ex){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
    }
    
    public void runVolumeBatchJob(){
        criteriaSetLevel = '%Volume%';
        try{
            EUR_CRM_CriteriaSetMassUpdateController batch = new EUR_CRM_CriteriaSetMassUpdateController(criteriaSetLevel,countryCodeStr );
            Database.executeBatch(batch, 40);
            system.debug('***:batch ' + batch);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
        }catch(Exception ex){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
    }
}