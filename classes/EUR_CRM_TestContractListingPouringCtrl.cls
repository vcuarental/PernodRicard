/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractListingPouringController Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_TestContractListingPouringCtrl{
    private static String mechanicTypeName1 = 'Pouring Refund';
    private static String mechanicTypeName2 = 'Events';

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand1;
    private static EUR_CRM_Brand__c brand2;
    private static EUR_CRM_Quality__c brandQuality1;
    private static EUR_CRM_Quality__c brandQuality2;
        
    private static EUR_CRM_Contract_Listing_Pouring__c listingPouring1;
    private static EUR_CRM_Contract_Listing_Pouring__c listingPouring2;

        public static void dataInsert1(){
        //Create account
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
        
        //Create Wine Spirit
        wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, EUR_CRM_DE_TestClassUtilityHelper.DE_WINE_SPIRIT_RECORD_TYPE, 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        system.assertNotEquals(wineSpirits, null);

        //Create category
        category = EUR_CRM_TestClassUtilityHelper.createCategory(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CATEGORY_RECORD_TYPE, 'TEST-0001', wineSpirits.Id)[0];
        insert category;
        system.assertNotEquals(category, null);
        
        //Create Brand
        brand1 = EUR_CRM_TestClassUtilityHelper.createBrand(1, EUR_CRM_DE_TestClassUtilityHelper.DE_BRAND_RECORD_TYPE, 'ABSOLUT', 'TEST-0001', category.Id)[0];
        insert brand1;
        system.assertNotEquals(brand1, null);
        brand2 = EUR_CRM_TestClassUtilityHelper.createBrand(1, EUR_CRM_DE_TestClassUtilityHelper.DE_BRAND_RECORD_TYPE, 'CHIVAS', 'TEST-0002', category.Id)[0];
        insert brand2;
        system.assertNotEquals(brand2, null);

        
        //Create BQ
        brandQuality1 = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, EUR_CRM_DE_TestClassUtilityHelper.DE_QUALITY_RECORD_TYPE, 'ABSOLUT CITRON', 'TEST-0001', brand1.Id)[0];
        insert brandQuality1;
        system.assertNotEquals(brandQuality1, null);
        brandQuality2 = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, EUR_CRM_DE_TestClassUtilityHelper.DE_QUALITY_RECORD_TYPE, 'CHIVAS BLUE', 'TEST-0002', brand2.Id)[0];
        insert brandQuality2;
        system.assertNotEquals(brandQuality2, null);

        
        //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
        insert contract;
                
        //Create Listing/ Pouring
        listingPouring1 = EUR_CRM_DE_TestClassUtilityHelper.createContractListingPouringItem(EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_LISTING_POURING_RECORD_TYPE, contract.Id, brandQuality1.Id, true, true);
        insert listingPouring1;
    }
    
    static testMethod void testMethod1(){
        //EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();

            
            test.startTest();
            
            dataInsert1();

            List<EUR_CRM_Quality__c> bqRef = new List<EUR_CRM_Quality__c>();
            bqRef.add(brandQuality1);
            bqRef.add(brandQuality2);
            
            PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractBuilderPage');
            pageRef.getParameters().put('PARAM_BRAND_ID', brand2.Id);
            pageRef.getParameters().put('PARAM_CATEGORY_ID', category.Id);
                    
            Test.setCurrentPage(pageRef);

            EUR_CRM_ContractListingPouringController ctrl = new EUR_CRM_ContractListingPouringController();
            ctrl.contractObj = contract;
            ctrl.brandQualityReferenceList = bqRef;
            
            ctrl.init();
            ctrl.validateListingPouringCategory();
            ctrl.save();
            
            Map<Id, EUR_CRM_ContractListingPouringController.ListingPouringCategoryWrapper> listingPouringMap = ctrl.listingPouringMap;
            Integer listingPouringMapSize = ctrl.listingPouringMapSize;
            
            EUR_CRM_ContractListingPouringController.ListingPouringCategoryWrapper lpCategoryWrapper = new EUR_CRM_ContractListingPouringController.ListingPouringCategoryWrapper();
            lpCategoryWrapper.addListingPouring(listingPouring1);
            lpCategoryWrapper.addListingPouring(contract.Id, brandQuality2);
            
            EUR_CRM_ContractListingPouringController.ListingPouringWrapper lpWrapper = new EUR_CRM_ContractListingPouringController.ListingPouringWrapper(listingPouring1, category.Name, brandQuality1.Name);
            
            test.stopTest();
        
    }
}