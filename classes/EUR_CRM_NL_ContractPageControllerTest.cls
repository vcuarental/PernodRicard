/**
 * Created by Alona Riabchenko on 28-Mar-18.
 */
@isTest
private with sharing class EUR_CRM_NL_ContractPageControllerTest {
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract__c contractNull;
    private static EUR_CRM_Contract_Line_Item__c contractItem;
    private static EUR_CRM_Contract_Mechanic__c contractMech;
    private static EUR_CRM_Mechanic_Type__c mechType;
    private static EUR_CRM_Mechanic__c mechanic;
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Quality__c brandQuality;

    @isTest
    private static void retrieveContractProductItemsTest(){
        dataInsert();
        PageReference pageRef = Page.EUR_CRM_NL_ContractSummaryPage;
        Test.setCurrentPage(pageRef);

        EUR_CRM_NL_ContractPageController extController = new EUR_CRM_NL_ContractPageController(new ApexPages.StandardController(contract));

        String mechanicTypeName = extController.mechanicTypeName;
        System.debug('mechanicTypeName = '+mechanicTypeName);
        Set<String> mechanicTypes = extController.mechanicTypes;
        System.debug('mechanicTypes = '+mechanicTypes);
    }

    public static void dataInsert(){
        Test.startTest();
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert accountEU;

        contractNull = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'GB Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contractNull.EUR_CRM_Contract_Type__c = 'Standard Contract';

        wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, 'GB Wine/Spirits', 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        system.assertNotEquals(wineSpirits, null);

        category = EUR_CRM_TestClassUtilityHelper.createCategory(1, 'GB Category', 'TEST-0001', wineSpirits.Id)[0];
        insert category;
        system.assertNotEquals(category, null);

        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'GB Brand', 'VODKA', 'TEST-0001', category.Id)[0];
        insert brand;
        system.assertNotEquals(brand, null);

        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'GB Quality', 'Cocktail', 'TEST-0001', brand.Id)[0];
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);
        Test.stopTest();

        mechType = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'GB Mechanic Type', 'House Pouring Spirits')[0];
        mechType.EUR_CRM_Grouping_Name__c = 'House Pouring Spirits';
        mechType.EUR_CRM_Lump_Sum_Or_Per_BQ__c = false;
        mechType.EUR_CRM_Has_Lump_Sum__c = true;
        mechType.EUR_CRM_Has_Per_BQ__c = true;
        insert mechType;
        system.assertNotEquals(mechType, null);

        mechanic = EUR_CRM_TestClassUtilityHelper.createMechanic(1, 'GB Mechanic', 'Cocktail', mechType.Id)[0];
        insert mechanic;
        system.assertNotEquals(mechanic, null);

        contractMech = EUR_CRM_TestClassUtilityHelper.createContractMechanic(1, 'GB Contract Mechanic', mechanic.Id)[0];
        contractMech.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        contractMech.EUR_CRM_Brand__c = brand.Id;
        insert contractMech;
        system.assertNotEquals(contractMech, null);

        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'GB Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contract.EUR_CRM_Contract_Type__c = 'Standard Contract';
        insert contract;
        system.assertNotEquals(contract, null);

        contractItem = EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', contract.Id)[0];
        contractItem.EUR_CRM_Process_Option_Lump_Sum__c = true;
        contractItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
        contractItem.EUR_CRM_Contract_Mechanic__c = contractMech.Id;
        insert contractItem;
        system.assertNotEquals(contractItem, null);

        EUR_CRM_Contract_Activity_Item__c acItem = new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Contract__c = contract.Id);
        insert acItem;

        EUR_CRM_Contract_Product_Item__c productItem = new EUR_CRM_Contract_Product_Item__c();
        productItem = EUR_CRM_FI_TestClassHelper.createProductItem(1,acItem).get(0);
        productItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        productItem.EUR_CRM_Volume_lt__c = 1;
        insert productItem;

        System.assertNotEquals(null,productItem.Id);
    }

}