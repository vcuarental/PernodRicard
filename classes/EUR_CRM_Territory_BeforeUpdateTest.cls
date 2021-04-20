@isTest
private class EUR_CRM_Territory_BeforeUpdateTest{
    private static User accUser;
    
    static testMethod void myUnitTest(){
        accUser = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_National_Sales_Manager_Off_Trade', 'testuser123902@sales.com', 'testuser123902@sales.com', 'accTest1990');
        
        System.runAs(accUser) {
	        EUR_CRM_Region__c region = new EUR_CRM_Region__c(name='new region');
	        insert region;
	    
	        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(name='test territory', EUR_CRM_Region__c=region.Id);
	        insert territory;
	        territory.name = 'name 2';
	        update territory;            
        }
    }
    
}