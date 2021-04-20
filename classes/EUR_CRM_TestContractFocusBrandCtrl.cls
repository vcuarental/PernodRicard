/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractFocusBrandController Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_TestContractFocusBrandCtrl{
    private static String mechanicTypeName1 = 'Pouring Refund';
    private static String mechanicTypeName2 = 'Events';

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand1;
    private static EUR_CRM_Brand__c brand2;
    private static EUR_CRM_Quality__c brandQuality;
        
    private static EUR_CRM_Contract_Focus_Brand__c focusBrand1;
    private static EUR_CRM_Contract_Focus_Brand__c focusBrand2;

    
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
        brand2 = EUR_CRM_TestClassUtilityHelper.createBrand(1, EUR_CRM_DE_TestClassUtilityHelper.DE_BRAND_RECORD_TYPE, 'BEEFEATER', 'TEST-0002', category.Id)[0];
        insert brand2;
        system.assertNotEquals(brand2, null);

        
        //Create BQ
        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, EUR_CRM_DE_TestClassUtilityHelper.DE_QUALITY_RECORD_TYPE, 'Cocktail', 'TEST-0001', brand1.Id)[0];
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);
        
        //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
        insert contract;
                
        //Create Focus Brand
        focusBrand1 = EUR_CRM_DE_TestClassUtilityHelper.createContractFocusBrandItem(EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_FOCUS_BRAND_RECORD_TYPE, contract.Id, brand1.Id);
        insert focusBrand1;

    }
    
    static testMethod void testMethod1(){
        //EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();

            test.startTest();

            dataInsert1();

            List<EUR_CRM_Brand__c> brandRef = new List<EUR_CRM_Brand__c>();
            brandRef.add(brand1);
            brandRef.add(brand2);
            
            PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractBuilderPage');
            pageRef.getParameters().put('PARAM_BRAND_ID', brand2.Id);
                    
            Test.setCurrentPage(pageRef);

            EUR_CRM_ContractFocusBrand_Controller ctrl = new EUR_CRM_ContractFocusBrand_Controller();
            ctrl.contractObj = contract;
            ctrl.brandReferenceList = brandRef;
            
            ctrl.init();
            
            ctrl.addContractFocusBrand();
            ctrl.removeContractFocusBrand();
            
            Map<Id, EUR_CRM_Contract_Focus_Brand__c> focusBrands = ctrl.existingFocusBrands;
            Map<Id, EUR_CRM_Brand__c> brandSelection = ctrl.brandSelection;
            Set<Id> deletedFocusBrands = ctrl.deletedFocusBrands;
            
            test.stopTest();

    }
}