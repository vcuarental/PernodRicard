@isTest
private class EUR_CRM_RU_AssignAccountTest {
	private static User user;
    private static EUR_CRM_Region__c testRegion;
    private static EUR_CRM_Territory__c offTradeTerritory;
    private static EUR_CRM_Postal_Code_Territory_Mapping__c offTradeTerritoryMapping;
    private static EUR_CRM_Territory__c onTradeTerritory;
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Customer_Taxonomy__c custTaxonomy;
    
    static void setUpUsers(){
        user = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_RU', 'testuser123902@test.com', 'testuser123902@test.com', 'test898441');
        system.assertNotEquals(user, null);
    }
     static testmethod void test() {
     	setUpUsers();
     	Test.startTest();
            system.runAs(user){
		    	EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
				EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
		
		       	apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
				insert apexConfig;
				
		       	euaccount = EUR_CRM_RU_TestClassHelper.createEUAccount('Test EU ACCOUNT','EUR RU On Trade');
		       	insert euaccount;
		       	List<EUR_CRM_Account__c> accs = new List<EUR_CRM_Account__c>();
		       	accs.add(euaccount);
		       	
		       	EUR_CRM_RU_AssignAccountOwnerHandler e = new EUR_CRM_RU_AssignAccountOwnerHandler();
		       	e.executeTriggerAction(null,accs,null,null);
		       	//update euaccount;
            }
       Test.stopTest();     
     }

}