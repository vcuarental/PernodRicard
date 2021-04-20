public  class EUR_CRM_MassUpdateImageLevelThreshold{
  public string countryCodeStr {get;set;}
 
  public void runBatchJob(){
    try{
      EUR_CRM_ImageLevelThresholdMassUpdate batch = new EUR_CRM_ImageLevelThresholdMassUpdate (countryCodeStr);
      Database.executeBatch(batch);
      Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
    }catch(Exception ex){
      Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
    }
  } 
  
}