public  class EUR_CRM_MassUpdateVolumeLevelThreshold{
  public string countryCodeStr {get;set;}
  private static final String MESSAGE_TEXT = 'Batch job has been successfully submitted. You will receive a notification when the job is finished.';

  public void runBatchJob(){
    try{
      EUR_CRM_VolumeLevelThresholdMassUpdate batch = new EUR_CRM_VolumeLevelThresholdMassUpdate(countryCodeStr);
      Database.executeBatch(batch);

      ApexPages.Message msg = new Apexpages.Message(Apexpages.Severity.Info, MESSAGE_TEXT);
      Apexpages.addMessage(msg);
    }catch(Exception ex){
      Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
    }
  }

}