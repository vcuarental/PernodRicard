/*********************************************************************************
 * Name:ASI_MFM_TW_AccrualGenerationCtrl
 * Description: 
 * Test Class: 	ASI_MFM_TW_TestClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-11-06       Wilken Lee              Created for TW MFM Accrual Generation page
 * 2020-11-26       PRA COE                 [PRA COE] 1.0 change batch size to 1
*********************************************************************************/
global without sharing class ASI_MFM_TW_AccrualGenerationCtrl{
	public ASI_MFM_Settings__c mfmSetting {get; set;}
	public Id generationBatchID {get; set;}
	public AsyncApexJob apexJob {get; set;}
	public Boolean hasMessage {get; set;}
	public Boolean hasGenerated {get; set;}
	public Boolean isAdminUser {get; set;}
	
	
    public ASI_MFM_TW_AccrualGenerationCtrl(){
		hasMessage = false;
		hasGenerated = false;
		mfmSetting = [select id, ASI_MFM_TW_Accrual_PO_Generation_Day__c, ASI_MFM_TW_Post_G_L_Date__c,ASI_MFM_TW_Today__c from ASI_MFM_Settings__c where recordtype.DeveloperName = 'ASI_MFM_TW_Setting' limit 1];
		
		validateIsPOGenerationAdminUser();
    }
	
	private void validateIsPOGenerationAdminUser(){
		isAdminUser = false;
		List<GroupMember> adminGrpMember = [select UserOrGroupId from GroupMember where GroupID  in (select id from Group Where DeveloperName = 'ASI_MFM_TW_Accrual_PO_Generation_Admin')];
		for (GroupMember gm:adminGrpMember){
			if (UserInfo.getUserId() == gm.UserOrGroupId)
				isAdminUser = true;
		}
		
		if (!isAdminUser){
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'The Accrual PO Generation function is available for Admin User only.');
			ApexPages.addMessage(errorMessage);
		}
	}
	
	public PageReference save(){
		try {
			update mfmSetting;
			hasMessage = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Saved Setting Successfully'));
			return null;
			
		 } catch(DmlException ex) {
			hasMessage = true;
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(0));
			ApexPages.addMessage(errorMessage);
			return null;
		}
	}
	
	public PageReference generate(){
        //PRA COE 1.0 change batch size to 1
		generationBatchID = Database.executebatch(new ASI_MFM_TW_AccrualPOGeneration_Batch(),1);	
		
		hasGenerated = true;
		refreshStatus();
		
		system.debug('generationBatchID:' + generationBatchID + ' hasGenerated: ' + hasGenerated);
		return null;
	}
	
	public PageReference refreshStatus(){
		hasGenerated = true;
		List<AsyncApexJob> apexJobList = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id  = :generationBatchID LIMIT 1];
		
		if (apexJobList != null && apexJobList.size() == 1)
			apexJob = apexJobList.get(0);
			
		system.debug('apexJob:' + apexJob);
		return null;
	}
}