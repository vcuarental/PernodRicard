/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractClass Class.
  @Author:      IPC
  @History:     JUN.03.2014 - Created
*/
@IsTest(SeeAllData=false)
private with sharing class EUR_CRM_ContractClass_Test {
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
    private static EUR_CRM_Cocktail_Menu__c cockMenu;
    private static EUR_CRM_Contract_Cocktail__c contractCock;


    public static void dataInsert() {
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        accountEU.EUR_CRM_Sub_Channel__c = null;
        insert accountEU;

        Contact c = new Contact(firstname = 'Test fname', lastname = 'Test Lastname', EUR_CRM_Account__c = accountEU.Id);
        insert c;

        contractNull = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'EUR GB Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contractNull.EUR_CRM_Contract_Type__c = 'Standard Contract';
        contractNull.EUR_CRM_Contact__c = c.Id;

        mechType = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Visibility Mechanic Type', 'Cocktail')[0];
        mechType.EUR_CRM_Grouping_Name__c = 'Cocktail';
        insert mechType;
        system.assertNotEquals(mechType, null);

        mechanic = EUR_CRM_TestClassUtilityHelper.createMechanic(1, 'GB Mechanic', 'Cocktail', mechType.Id)[0];
        insert mechanic;
        system.assertNotEquals(mechanic, null);

        wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, 'GB Wine/Spirits', 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        system.assertNotEquals(wineSpirits, null);

        category = EUR_CRM_TestClassUtilityHelper.createCategory(1, 'GB Category', 'TEST-0001', wineSpirits.Id)[0];
        insert category;
        system.assertNotEquals(category, null);

        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'EUR GB Brand', 'VODKA', 'TEST-0001', category.Id)[0];
        insert brand;
        system.assertNotEquals(brand, null);

        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR GB Quality', 'Cocktail', 'TEST-0001',
                brand.Id)[0];
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        contractMech = EUR_CRM_TestClassUtilityHelper.createContractMechanic(1, 'EUR GB Contract Mechanic', mechanic.Id)
        [0];
        contractMech.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        contractMech.EUR_CRM_Brand__c = brand.Id;
        insert contractMech;
        system.assertNotEquals(contractMech, null);

        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'EUR GB Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contract.EUR_CRM_Contract_Type__c = 'Standard Contract';
        contract.EUR_CRM_Marketing_Package_Lump_Sum__c = null;
        contract.EUR_CRM_Contact__c = c.Id;
        insert contract;
        system.assertNotEquals(contract, null);
        System.debug('$$$ - Check contract id - ' + contract.Id);

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

        contractItem = EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', contract.Id)[0];
        contractItem.EUR_CRM_Process_Option_Lump_Sum__c = false;
        contractItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
        contractItem.EUR_CRM_Contract_Mechanic__c = contractMech.Id;
        insert contractItem;

        cockMenu = new EUR_CRM_Cocktail_Menu__c(name='test Menu');
        insert cockMenu;

        contractCock = new  EUR_CRM_Contract_Cocktail__c(EUR_CRM_Cocktail_Menu__c=cockMenu.Id,EUR_CRM_Contract_Line_Item__c=contractItem.Id);
        insert contractCock;

        system.assertNotEquals(contractItem, null);

        //Create Contract Cocktail
        createContractCocktail(contractItem.Id);
    }
    @IsTest
    static void testContractClass1(){
        dataInsert();

        test.startTest();
            List<EUR_CRM_Contract_Line_Item__c> contractLineItemList = new List<EUR_CRM_Contract_Line_Item__c>();
            contractLineItemList.add(contractItem);

            Map<Id, List<EUR_CRM_Contract_Line_Item__c>> contractLineItemMap = new Map<Id, List<EUR_CRM_Contract_Line_Item__c>>();
            contractLineItemMap.put(mechType.Id, contractLineItemList);

            EUR_CRM_ContractClass ctrl = new EUR_CRM_ContractClass(contract.Id);

            ctrl.retrieveAllContractMechanicItems();
            ctrl.getMechanicTypeId('Cocktail');
            ctrl.retrieveTrimmedContractMechanicItems(contractLineItemMap);
            ctrl.retrieveContractMechanic(contractMech.Id);
            ctrl.retrieveContractMechanicItems(mechType.Id);
            ctrl.getTrimmedContractMechanicItems(mechType.Id, contractLineItemMap);
            ctrl.retrieveContractMechanic(brandQuality.Id, 'Cocktail');
            EUR_CRM_ContractClass.ContractCocktailWrapper cockWrap = new EUR_CRM_ContractClass.ContractCocktailWrapper(contractMech.Id,brandQuality.Id,cockMenu.Id,contractCock.name);
            EUR_CRM_ContractClass.ContractLineItemWrapper lineWrapper = new EUR_CRM_ContractClass.ContractLineItemWrapper(contract.Id,contractMech.Id,brandQuality.Id);
            EUR_CRM_ContractClass.ContractLineItemWrapper lineWrapper2 = new EUR_CRM_ContractClass.ContractLineItemWrapper(contractItem);

        test.stopTest();
    }

    private static EUR_CRM_Contract_Cocktail__c createContractCocktail(Id contractLineItemId){
        //Create Cocktail Menu
        Id cocktailMenuRecordTypeGB = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Cocktail_Menu__c', 'EUR_GB_Cocktail_Menu');

        EUR_CRM_Cocktail_Menu__c cocktailMenu = new EUR_CRM_Cocktail_Menu__c(Name='Test_Cocktail', RecordTypeId=cocktailMenuRecordTypeGB);
        insert cocktailMenu;
        system.assertNotEquals(cocktailMenu, null);

        //Create Contract Cocktail
        EUR_CRM_Contract_Cocktail__c contractCocktail = new EUR_CRM_Contract_Cocktail__c(EUR_CRM_Contract_Line_Item__c=contractLineItemId, EUR_CRM_Cocktail_Menu__c=cocktailMenu.Id);
        insert contractCocktail;
        system.assertNotEquals(contractCocktail, null);

        return contractCocktail;
    }

    @IsTest
    static void testCreatingContractClassWithCAItems() {
        dataInsert();
        Test.startTest();
        EUR_CRM_ContractClass contractNew = new EUR_CRM_ContractClass(contract.Id);
        Test.stopTest();
        System.assertEquals(1, contractNew.contractActivityItemsWithProductItems.size());
        System.assertEquals(1, contractNew.contractActivityItemsWithProductItems[0].Contract_Product_Items__r.size());
    }
}