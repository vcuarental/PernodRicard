public with sharing class EUR_CRM_MassUpdatePRSFinalResultCriteria {
	public string countryCodeStr {get; set;}
	public Boolean enableBBPBool {get; set;}
	public Boolean enableBPBool {get; set;}
	public Boolean enableILBool {get; set;}
	public Boolean enableVPBool {get; set;}

	public EUR_CRM_MassUpdatePRSFinalResultCriteria(){
		enableBBPBool = false;
		enableBPBool = false;
		enableILBool = false;
		enableVPBool = false;
	}

	public void runBrandBuildingBatchJob() {
		try{
			EUR_CRM_MassUpdatePRSFinalResultBatch batch = new EUR_CRM_MassUpdatePRSFinalResultBatch(countryCodeStr, 'BrandBuilding');
			Database.executeBatch(batch);
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
		} catch(Exception ex){
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
		}
	}

	public void runBusinessPotentialBatchJob() {
		try{
			EUR_CRM_MassUpdatePRSFinalResultBatch batch = new EUR_CRM_MassUpdatePRSFinalResultBatch(countryCodeStr, 'BusinessPotential');
			Database.executeBatch(batch);
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
		} catch(Exception ex){
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
		}
	}

	public void runImageLevelBatchJob() {
		try{
			EUR_CRM_MassUpdatePRSFinalResultBatch batch = new EUR_CRM_MassUpdatePRSFinalResultBatch(countryCodeStr, 'ImageLevel');
			Database.executeBatch(batch);
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
		} catch(Exception ex){
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
		}
	}

	public void runVolumePotentialBatchJob() {
		try{
			EUR_CRM_MassUpdatePRSFinalResultBatch batch = new EUR_CRM_MassUpdatePRSFinalResultBatch(countryCodeStr, 'VolumePotential');
			Database.executeBatch(batch);
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
		} catch(Exception ex){
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
		}
	}

}