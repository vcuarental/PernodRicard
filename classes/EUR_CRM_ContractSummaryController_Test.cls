/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractSummaryController Class.
  @Author:      IPC
  @History:     MAY.30.2014 - Created
*/
@isTest(SeeAllData=true)
private with sharing class EUR_CRM_ContractSummaryController_Test {
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
    private static List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems;
    private static EUR_CRM_Contract_Product_Item__c contractProductItem;

    public static void dataInsert() {
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert accountEU;

        Contact c = new Contact(firstname = 'Test fname', lastname = 'Test Lastname', EUR_CRM_Account__c = accountEU.Id);
        insert c;

        contractNull = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'GB Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contractNull.EUR_CRM_Contract_Type__c = 'Standard Contract';
        contractNull.EUR_CRM_Contact__c = c.Id;

        wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, 'GB Wine/Spirits', 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        system.assertNotEquals(wineSpirits, null);

        category = EUR_CRM_TestClassUtilityHelper.createCategory(1, 'GB Category', 'TEST-0001', wineSpirits.Id)[0];
        insert category;
        system.assertNotEquals(category, null);

        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'EUR GB Brand', 'VODKA', 'TEST-0001', category.Id)[0];
        insert brand;
        system.assertNotEquals(brand, null);

        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR GB Quality', 'Cocktail', 'TEST-0001', brand.Id)[0];
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        mechType = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR GB Mechanic Type', 'House Pouring Spirits')[0];
        mechType.EUR_CRM_Grouping_Name__c = 'House Pouring Spirits';
        insert mechType;
        system.assertNotEquals(mechType, null);

        mechanic = EUR_CRM_TestClassUtilityHelper.createMechanic(1, 'GB Mechanic', 'Cocktail', mechType.Id)[0];
        insert mechanic;
        system.assertNotEquals(mechanic, null);

        contractMech = EUR_CRM_TestClassUtilityHelper.createContractMechanic(1, 'EUR GB Contract Mechanic', mechanic.Id)[0];
        contractMech.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        contractMech.EUR_CRM_Brand__c = brand.Id;
        insert contractMech;
        system.assertNotEquals(contractMech, null);

        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'EUR GB Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contract.EUR_CRM_Contract_Type__c = 'Standard Contract';
        contract.EUR_CRM_Contact__c = c.Id;
        insert contract;
        system.assertNotEquals(contract, null);

        contractItem = EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', contract.Id)[0];
        contractItem.EUR_CRM_Process_Option_Lump_Sum__c = true;
        contractItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
        contractItem.EUR_CRM_Contract_Mechanic__c = contractMech.Id;
        insert contractItem;
        system.assertNotEquals(contractItem, null);

        contractActivityItems = EUR_CRM_TestClassUtilityHelper.createContractActivityItems(new
                List<EUR_CRM_Mechanic_Type__c>{
                mechType
        }, contract.Id);
        insert contractActivityItems;
        System.assertNotEquals(contractActivityItems, null);

        contractProductItem = EUR_CRM_TestClassUtilityHelper.createContractProductItem(contractActivityItems[0].Id,
                brand.Id, brandQuality.Id);
        insert contractProductItem;
        System.assertNotEquals(contractProductItem, null);
    }

    static testMethod void testContractSummary1() {
        dataInsert();

        test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ContractSummaryPage');
        rf.getParameters().put('id', contract.id);
        Test.setCurrentPage(rf);

        EUR_CRM_ContractSummaryController ctrl = new EUR_CRM_ContractSummaryController(standardController);

        EUR_CRM_ContractSummaryController.CONTRACT_MECHANIC_TABLE_PREFIX = 'ContractMechanicTable_';
        EUR_CRM_ContractSummaryController.CONTRACT_LINE_ITEM_TABLE_PREFIX = 'ContractLineItemTable_';

        EUR_CRM_ContractSummaryController.MechanicTypeWrapper mechWrap1 = new EUR_CRM_ContractSummaryController.MechanicTypeWrapper('Cocktail');


        ctrl.cloneContractHeader();
        ctrl.clonedContractObj.EUR_CRM_Account__c = accountEU.Id;
        ctrl.clonedContractObj.EUR_CRM_End_Date__c = date.today().addDays(20);
        ctrl.clonedContractObj.EUR_CRM_Start_Date__c = date.today();

        mechWrap1.putContractLineItem('Cocktail', contractItem);
        mechWrap1.removeContractLineItem('Cocktail');

        List<EUR_CRM_Contract_Mechanic__c> contractMechList = new List<EUR_CRM_Contract_Mechanic__c>();
        contractMechList.add(contractMech);
        mechWrap1.setContractMechanicMap(contractMechList);

        mechWrap1.putContractMechanic(contractMech.Id, contractMech);

        mechWrap1.removeContractMechanic(contractMech.Id);

        mechWrap1.amendTotalValue(102);
        mechWrap1.putContractLineItemWrappper(brand.name, contractItem);
        List<EUR_CRM_Contract_Mechanic__c> mech = mechWrap1.contractMechanicList;
        Integer tInt = mechWrap1.contractLineItemMapSize;
        tInt = mechWrap1.contractMechanicMapSize;
        Map<String, EUR_CRM_ContractSummaryController.MechanicTypeWrapper> mechWrap = mechWrap1.subMechanics;
        //tInt = mechWrap1.subMechanicsSize;
        test.stopTest();
    }

    static testMethod void testContractSummaryNULL() {
        dataInsert();

        test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contractNull);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ContractSummaryPage');
        Test.setCurrentPage(rf);

        EUR_CRM_ContractSummaryController ctrl = new EUR_CRM_ContractSummaryController(standardController);

        test.stopTest();
    }

    @IsTest
    static void testNewCloneContract() {
        dataInsert();
        Test.startTest();

        ApexPages.StandardController standardController = new Apexpages.StandardController(contract);
        PageReference rf = new PageReference('/apex/EUR_CRM_ContractSummaryPage');
        rf.getParameters().put('id', contract.Id);
        Test.setCurrentPage(rf);

        EUR_CRM_ContractSummaryController ctrl = new EUR_CRM_ContractSummaryController(standardController);

        EUR_CRM_ContractSummaryController.CONTRACT_MECHANIC_TABLE_PREFIX = 'ContractMechanicTable_';
        EUR_CRM_ContractSummaryController.CONTRACT_LINE_ITEM_TABLE_PREFIX = 'ContractLineItemTable_';

        EUR_CRM_ContractSummaryController.MechanicTypeWrapper mechWrap1 = new EUR_CRM_ContractSummaryController.MechanicTypeWrapper('Cocktail');

        ctrl.cloneContractHeader();
        ctrl.clonedContractObj.EUR_CRM_Account__c = accountEU.Id;
        ctrl.clonedContractObj.EUR_CRM_End_Date__c = Date.today().addDays(20);
        ctrl.clonedContractObj.EUR_CRM_Start_Date__c = Date.today();

        ctrl.saveClonedContractNew();

        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> activityItemsCloned = [
                SELECT Id, (SELECT Id FROM Contract_Product_Items__r)
                FROM
                        EUR_CRM_Contract_Activity_Item__c
                WHERE EUR_CRM_Contract__c = :ctrl.clonedContractObj.Id
        ];
        System.assertEquals(1, activityItemsCloned.size());
        System.assertEquals(1, activityItemsCloned[0].Contract_Product_Items__r.size());
    }
}