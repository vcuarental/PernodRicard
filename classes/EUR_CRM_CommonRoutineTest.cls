/*
*	Test class for EUR_CRM_CommonRoutine
* 
*/

@isTest
public class EUR_CRM_CommonRoutineTest {

	static testmethod void testDmlWithPartialSuccess(){

		String recordTypeDevName = 'DE_ON_Gastronomy';
		List<EUR_CRM_Account__c> accList = EUR_CRM_TestClassUtilityHelper.createAccountsEU(5, recordTypeDevName);

		// Cause update error to fire
		try {
			EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', accList);
		} catch(Exception e){}
		finally{
			system.assert(accList[0].Id == null);
		}

		// Cause  delete error to fire
		try{
			EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Delete', accList);
		} catch(Exception e){}

		// Cause  undelete error to fire
		try{
			EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Undelete', accList);
		} catch(Exception e){}

		// Cause  Insert to fire
		try{
			EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Insert', accList);
			List<EUR_CRM_Account__c> accounts = [SELECT Id, Name From EUR_CRM_Account__c WHERE Id IN :accList];
			System.assertEquals('TestAccount', accounts[0].Name);
		} catch(Exception e){}

		// Cause  insert error to fire
		try{
			EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Insert', accList);
		} catch(Exception e){}

		// Cause Upsert to fire
		try{
			for(EUR_CRM_Account__c acc : accList){
				acc.Name= 'New Name';			
			}
			EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', accList);
			List<EUR_CRM_Account__c> accounts = [SELECT Id, Name From EUR_CRM_Account__c WHERE Id IN :accList];
			System.assertEquals('New Name', accounts[0].Name);
		} catch(Exception e){}

		// Cause  delete to fire
		try{
			EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Delete', accList);
			List<EUR_CRM_Account__c> accounts = [SELECT Id From EUR_CRM_Account__c WHERE Id IN :accList];
			system.assertEquals(0, accounts.size());
		} catch(Exception e){}	

		// Cause  Undelete to fire
		try{
			EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Undelete', accList);
			List<EUR_CRM_Account__c> accounts = [SELECT Id From EUR_CRM_Account__c WHERE Id IN :accList];
			system.assertEquals(5, accounts.size());
		} catch(Exception e){}		
	}
}