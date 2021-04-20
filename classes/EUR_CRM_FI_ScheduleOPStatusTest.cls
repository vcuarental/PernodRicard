@isTest
private class EUR_CRM_FI_ScheduleOPStatusTest {
	static testMethod void EUR_CRM_FI_ScheduleOPStatusTest(){
		List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
   		EUR_CRM_ObjPromo__c objPromo1 = new EUR_CRM_ObjPromo__c(
   			Name = 'TestClass',
   			EUR_CRM_Evaluation_Period_End_Date__c = System.Today(),
   			EUR_CRM_Status__c = 'Draft',
   			RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__cEUR_FI_On_Trade_O_P')
   		);
   		objPromoList.add(objPromo1);
   		EUR_CRM_ObjPromo__c objPromo2 = new EUR_CRM_ObjPromo__c(
   			Name = 'TestClass',
   			EUR_CRM_Evaluation_Period_End_Date__c = System.Today().addMonths(1),
   			EUR_CRM_Status__c = 'Draft',
   			RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__cEUR_FI_On_Trade_O_P')
   		);
   		objPromoList.add(objPromo2);
   		insert objPromoList;
   		
   		List<EUR_CRM_ObjPromo_Target__c> objTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
   		EUR_CRM_ObjPromo_Target__c objTarget1 = new EUR_CRM_ObjPromo_Target__c(
   			RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__cEUR_CRM_Objective_Product'),
   			EUR_CRM_Actual_Number_of_Commitments__c = 100,
   			EUR_CRM_Is_Quota__c = true,
   			EUR_CRM_Visit_Targets__c = 100,
   			EUR_CRM_ObjPromo__c = objPromo1.Id
   		);
   		objTargetList.add(objTarget1);
   		EUR_CRM_ObjPromo_Target__c objTarget2 = new EUR_CRM_ObjPromo_Target__c(
   			RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__cEUR_CRM_Objective_Product'),
   			EUR_CRM_Actual_Number_of_Commitments__c = 100,
   			EUR_CRM_Is_Quota__c = true,
   			EUR_CRM_Visit_Targets__c = 100,
   			EUR_CRM_ObjPromo__c = objPromo2.Id
   		);
   		objTargetList.add(objTarget2);
   		insert objTargetList;
		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_ScheduleOPStatus());
		Test.stopTest();
	}
}