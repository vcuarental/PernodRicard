@isTest
public class EUR_CRM_TestContractPaymentPlanHandler {

    private final static String DE_OFF_TRADE_USER_PROFILE = 'EUR DE OFF Trade User';
    private final static String REGIONAL_OFF_TRADE_MANAGER_ROLE = 'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East';
    private final static String DE_CUSTOMER_TAXONOMY_RECORD_TYPE =  'DE Customer Taxonomy';
    private final static String TEST_POSTAL = '12345';
    private final static String DE_EUACCOUNT_RECORD_TYPE = 'DE OFF STD';
    private final static String DE_CONTRACT_RECORD_TYPE = 'DE Contract';

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract_Payment_Plan__c contractPaymentPlan;

    static testMethod void testCreateContractPaymentPlan() {

        User regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_OFF_TRADE_USER_PROFILE,    
        REGIONAL_OFF_TRADE_MANAGER_ROLE,'testdezxc2@testemail.com', 'testdezxc2@testemail.com', 'testdezxc2');
        
        User salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_OFF_TRADE_USER_PROFILE,    
        EUR_CRM_DE_TestClassUtilityHelper.SR_OFF_TRADE_ROLE,'testdezxc3@testemail.com', 'testdezxc3@testemail.com', 'testdezxc3'); 

		System.RunAs(regionalUser){
            //EUR_CRM_DE_TestClassUtilityHelper.initData();
            EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', regionalUser.id,  EUR_CRM_DE_TestClassUtilityHelper.DE_REGION_RECORD_TYPE);
            EUR_CRM_Territory__c territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', salesRepUser.id,region.id, EUR_CRM_DE_TestClassUtilityHelper.DE_TERRITORY_RECORD_TYPE);
        
            EUR_CRM_Postal_Code_Territory_Mapping__c postalmapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('postalmap' , TEST_POSTAL , territory.id, EUR_CRM_DE_TestClassUtilityHelper.DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
            EUR_CRM_Customer_Taxonomy__c customerTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('testtaxonomy', regionalUser.id, DE_CUSTOMER_TAXONOMY_RECORD_TYPE);
            accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('testname', TEST_POSTAL , DE_EUACCOUNT_RECORD_TYPE , customerTaxonomy.id);

            test.StartTest();

    		contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(180))[0];
    		contract.EUR_CRM_Contract_Approved_Date__c = null;
    		contract.EUR_CRM_Contract_Uploaded__c = false;
    		insert contract;

    		contract = [SELECT Id FROM EUR_CRM_Contract__c WHERE EUR_CRM_Account__c = :accountEU.Id LIMIT 1];

    		contractPaymentPlan = [SELECT Id FROM EUR_CRM_Contract_Payment_Plan__c WHERE EUR_CRM_Contract__c = :contract.Id];
    		System.assertNotEquals(contractPaymentPlan, null);

    		test.StopTest();
        }
	}
}