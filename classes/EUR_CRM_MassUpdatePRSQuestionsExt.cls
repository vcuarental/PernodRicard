public with sharing class EUR_CRM_MassUpdatePRSQuestionsExt {
	public string criteriaSetLevel {get;set;}
	public string countryCodeStr {get;set;}
	public Boolean enableBBPBool {get; set;}
	public Boolean enableBPBool {get; set;}
	public Boolean enableILBool {get; set;}
	public Boolean enableVPBool {get; set;}


	public void runBrandBuildingBatchJob(){
	    criteriaSetLevel = 'BrandBuilding';
	    try{
	        EUR_CRM_MassUpdatePRSQuestionsBatch batch = new EUR_CRM_MassUpdatePRSQuestionsBatch(criteriaSetLevel,countryCodeStr );
	        Database.executeBatch(batch, 40);
	        system.debug('***:batch ' + batch);
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
	    }catch(Exception ex){
	        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
	    }
	}
	
	public void runBusinessPotentialBatchJob(){
	    criteriaSetLevel = 'BusinessPotential';
	    try{
	        EUR_CRM_MassUpdatePRSQuestionsBatch batch = new EUR_CRM_MassUpdatePRSQuestionsBatch(criteriaSetLevel,countryCodeStr );
	        Database.executeBatch(batch, 40);
	        system.debug('***:batch ' + batch);
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
	    }catch(Exception ex){
	        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
	    }
	}

	public void runImageLevelBatchJob(){
	    criteriaSetLevel = 'ImageLevel';
	    try{
	        EUR_CRM_MassUpdatePRSQuestionsBatch batch = new EUR_CRM_MassUpdatePRSQuestionsBatch(criteriaSetLevel,countryCodeStr );
	        Database.executeBatch(batch, 40);
	        system.debug('***:batch ' + batch);
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
	    }catch(Exception ex){
	        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
	    }
	}

	public void runVolumePotentialBatchJob(){
	    criteriaSetLevel = 'VolumePotential';
	    try{
	        EUR_CRM_MassUpdatePRSQuestionsBatch batch = new EUR_CRM_MassUpdatePRSQuestionsBatch(criteriaSetLevel,countryCodeStr );
	        Database.executeBatch(batch, 40);
	        system.debug('***:batch ' + batch);
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
	    }catch(Exception ex){
	        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
	    }
	}
}