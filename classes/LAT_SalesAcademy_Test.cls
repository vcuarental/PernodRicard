@isTest
private class LAT_SalesAcademy_Test {
	
	@isTest static void test_method_one() {
		Account a = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
		insert a;
		Test.startTest();

		LAT_SalesAcademy__c sales = new LAT_SalesAcademy__c();
		sales.account__c = a.Id;
		insert sales;

		LAT_ClientAnalysis__c clientAnalysis = new LAT_ClientAnalysis__c();
		clientAnalysis.SalesAcademy__c = sales.Id;
		insert clientAnalysis;

		
		LAT_SWOTAnalysis__c swotAnalysis = new LAT_SWOTAnalysis__c();
		swotAnalysis.SalesAcademy__c = sales.Id;
		insert swotAnalysis;

		
		LAT_ActionPlan__c actionPlan = new LAT_ActionPlan__c();
		actionPlan.SalesAcademy__c = sales.Id;
		insert actionPlan;

		
		LAT_ObjectivesDefinition__c objetivesDefinition = new LAT_ObjectivesDefinition__c();
		objetivesDefinition.SalesAcademy__c = sales.Id;
		insert objetivesDefinition;

		
		LAT_StrategicObjectives__c strategicObjetives = new LAT_StrategicObjectives__c();
		strategicObjetives.objetive__c = objetivesDefinition.Id;
		insert strategicObjetives;

		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}