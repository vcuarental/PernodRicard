/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractPDFController Class.
  @Author:      IPC
  @History:     JUN.03.2014 - Created
*/
@isTest 
private with sharing class EUR_CRM_ContractPDFController_Test{
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract_Line_Item__c contractItem;
    private static EUR_CRM_Contract_Line_Item__c contractItemCockTail;
    private static EUR_CRM_Contract_Mechanic__c contractMech;
    private static EUR_CRM_Contract_Mechanic__c contractMechCockTail;
    private static EUR_CRM_Mechanic_Type__c mechType;
    private static EUR_CRM_Mechanic_Type__c mechTypeCockTail;
    private static EUR_CRM_Mechanic__c mechanic;
    private static EUR_CRM_Mechanic__c mechanicCockTail;
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Quality__c brandQuality;
    private static EUR_CRM_Quality__c brandQuality2;
    private static EUR_CRM_Quality__c brandQuality3;
    private static EUR_CRM_Stock_Deal_Mechanic__c stockDealMech;
    private static EUR_CRM_Cocktail_Menu__c cocktailMenu;
    private static EUR_CRM_Contract_Cocktail__c contractCocktail;
    
    public static void dataInsert1(){
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert accountEU;

        Contact c = new Contact(firstname='Test fname', lastname='Test Lastname',EUR_CRM_Account__c=accountEU.Id);
        insert c;
        
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'GB Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contract.EUR_CRM_Contract_Type__c = 'Standard Contract';
        contract.EUR_CRM_Mktg_Package_Mechanic_Handling__c = 'Per Brand-Quality';
        contract.EUR_CRM_Contact__c = c.Id;
        contract.EUR_CRM_Marketing_Package_Lump_Sum__c = 10;
        insert contract;
        system.assertNotEquals(contract, null);
        
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
        
        stockDealMech = EUR_CRM_TestClassUtilityHelper.createStockDealMech(1, brandQuality.Id, 'TEST-0001')[0];
        stockDealMech.EUR_CRM_Bottles_per_Case_BQ__c = 1;
        stockDealMech.EUR_CRM_Liquid_per_Bottle_litre__c = 1;
        stockDealMech.EUR_CRM_Litres_per_Case__c = 1;
        stockDealMech.EUR_CRM_Qty_Buy__c = 1;
        stockDealMech.EUR_CRM_Qty_Free__c = 1;
        stockDealMech.EUR_CRM_RTM_Price__c = 1;
        insert stockDealMech;
        system.assertNotEquals(stockDealMech, null);
        
        //House Pouring Spirits
        mechType = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'GB Mechanic Type', 'House Pouring Spirits')[0];
        mechType.EUR_CRM_Grouping_Name__c = 'Cocktail';
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
        
        contractItem = EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', contract.Id)[0];
        contractItem.EUR_CRM_Process_Option_Lump_Sum__c = true;
        contractItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
        contractItem.EUR_CRM_Contract_Mechanic__c = contractMech.Id;
        contractItem.EUR_CRM_Retro_Per_9L__c = 1;
        contractItem.EUR_CRM_Stock_Deal__c = stockDealMech.Id;
        contractItem.EUR_Min_Qty_Per_Annum_9L__c = 2;
        contractItem.EUR_CRM_Value__c = 3;
        contractItem.EUR_CRM_Total_Value_Reference__c = 1;
        contractItem.EUR_CRM_Retro_Per_9L__c = 1;
        contractItem.EUR_CRM_No_of_People__c= 3;
        //contractItem.EUR_CRM_Cocktail_Percent__c = 1;
        insert contractItem;
        system.assertNotEquals(contractItem, null);
        
        //Cocktail
        mechTypeCockTail = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'GB Mechanic Type', 'Cocktail')[0];
        mechTypeCockTail.EUR_CRM_Grouping_Name__c = 'Cocktail';
        insert mechTypeCockTail;
        system.assertNotEquals(mechTypeCockTail, null);
        
        mechanicCockTail = EUR_CRM_TestClassUtilityHelper.createMechanic(1, 'GB Mechanic', 'Cocktail', mechTypeCockTail.Id)[0];
        insert mechanicCockTail;
        system.assertNotEquals(mechanicCockTail, null);
        
        contractMechCockTail = EUR_CRM_TestClassUtilityHelper.createContractMechanic(1, 'GB Contract Mechanic', mechanicCockTail.Id)[0];
        contractMechCockTail.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        contractMechCockTail.EUR_CRM_Brand__c = brand.Id;
        insert contractMechCockTail;
        system.assertNotEquals(contractMechCockTail, null);
        
        contractItemCockTail = EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', contract.Id)[0];
        contractItemCockTail.EUR_CRM_Process_Option_Lump_Sum__c = true;
        contractItemCockTail.EUR_CRM_Mechanic_Type__c = mechTypeCockTail.Id;
        contractItemCockTail.EUR_CRM_Contract_Mechanic__c = contractMechCockTail.Id;
        insert contractItemCockTail;
        system.assertNotEquals(contractItemCockTail, null);

        List<EUR_CRM_Cocktail_Menu__c> cocktailMenuList = EUR_CRM_TestClassUtilityHelper.createCocktailMenu(1,'EUR_GB_Cocktail_Menu','Cocktail');
        insert cocktailMenuList;
        cocktailMenu = cocktailMenuList.get(0);
        system.assertNotEquals(cocktailMenu, null);

        List<EUR_CRM_Contract_Cocktail__c> contractCocktailList = EUR_CRM_TestClassUtilityHelper.createContractCocktail(1,cocktailMenu.Id,contractItemCockTail.Id);
        insert contractCocktailList;
        contractCocktail = contractCocktailList.get(0);
        system.assertNotEquals(contractCocktail, null);
    }

    static testMethod void testContractBuilder1(){
        dataInsert1();
        
        test.startTest();
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            PageReference rf = new Pagereference('/apex/EUR_CRM_GB_Contract_PDF');
            rf.getParameters().put('id', contract.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_ContractPDFController ctrl = new EUR_CRM_ContractPDFController(standardController);
            
            EUR_CRM_ContractPDFController.LUMP_SUM = 'Lump Sum';
            EUR_CRM_ContractPDFController.PER_BQ = 'Per Brand-Quality';
            String dateFormat = ctrl.dateFormat;
            
            //Premium Pouring Spirits
            mechType.Name = 'Premium Pouring Spirits';
            update mechType;
            
            List<String> keys = new List<String>{'atest','btest','ctest'};
            
            EUR_CRM_ContractPDFController.ContentBrandWrapper brandWrapp = new EUR_CRM_ContractPDFController.ContentBrandWrapper('key');
            //brandWrapp.add('bString');
            //brandWrapp.add('cString');
            //brandWrapp.sort();
        
            EUR_CRM_ContractPDFController.ContractContentWrapper contentWrapp = new EUR_CRM_ContractPDFController.ContractContentWrapper();
            List<EUR_CRM_ContractPDFController.ContentBQWrapper> bqlist = contentWrapp.bqList;
            List<EUR_CRM_ContractPDFController.ContentBrandWrapper> brandList = contentWrapp.brandList;
            String totalStr = contentWrapp.totalStr;
            
            ctrl = new EUR_CRM_ContractPDFController(standardController);
            
            //Must Stock Item
            mechType.Name = 'Must Stock Item';
            update mechType;
            
            ctrl = new EUR_CRM_ContractPDFController(standardController);
            
            //May Stock Item
            mechType.Name = 'May Stock Item';
            update mechType;
            
            ctrl = new EUR_CRM_ContractPDFController(standardController);
            
            //House Pouring Champagne
            mechType.Name = 'House Pouring Champagne';
            update mechType;
            
            ctrl = new EUR_CRM_ContractPDFController(standardController);

            //Marketing Support
            mechType.Name = 'Marketing Support';
            update mechType;
            
            ctrl = new EUR_CRM_ContractPDFController(standardController);
            
            //Free Stock
            mechType.Name = 'Free Stock';
            update mechType;
            
            ctrl = new EUR_CRM_ContractPDFController(standardController);
            
            //Point of Sales
            mechType.Name = 'Point of Sales';
            update mechType;
            
            ctrl = new EUR_CRM_ContractPDFController(standardController);
            
            //Educations
            mechType.Name = 'Educations';
            update mechType;
            
            ctrl = new EUR_CRM_ContractPDFController(standardController);
            
            //Trips
            mechType.Name = 'Trips';
            update mechType;
            
            ctrl = new EUR_CRM_ContractPDFController(standardController);
            Boolean testBool = ctrl.HPShasCocktail;
            Decimal testDeci = ctrl.totalContractValue;
            //String testStr= ctrl.currencyCode;
            EUR_CRM_ContractPDFController.ContractHeaderWrapper ctrlHeaderWr= new EUR_CRM_ContractPDFController.ContractHeaderWrapper(contract);
            EUR_CRM_ContractPDFController.ContractContentWrapper ctrlContentWr = new EUR_CRM_ContractPDFController.ContractContentWrapper();
            EUR_CRM_ContractPDFController.ContentBrandWrapper ctrlBrandWr = new EUR_CRM_ContractPDFController.ContentBrandWrapper('test');
            EUR_CRM_ContractPDFController.ContentBQWrapper ctrlBqWr = new EUR_CRM_ContractPDFController.ContentBQWrapper(contractItem);
            List<EUR_CRM_ContractPDFController.ContentBQWrapper> houseSpiritList = ctrlContentWr.houseSpiritsList;
            List<EUR_CRM_ContractPDFController.ContentBQWrapper> premiumSpiritList = ctrlContentWr.premiumSpiritsList;
            List<EUR_CRM_ContractPDFController.ContentBQWrapper> champagnesList = ctrlContentWr.champagneList;
            Date dateTest = ctrlHeaderWr.contractStartDate;
            dateTest = ctrlHeaderWr.contractEndDate;
            String testStr = ctrlHeaderWr.marketingPackageLumpSumStr;
            testDeci = ctrlContentWr.lumpSum;
            testStr =ctrlContentWr.lumpSumStr;
            Integer testInteger = ctrlContentWr.bqMapSize;
            testInteger = ctrlBrandWr.bqListSize;
            testStr = ctrlBqWr.itemName;
            EUR_CRM_Contract_Line_Item__c li = ctrlBqWr.cocktailLineItemObj;
            Set<String> cocktailNames = ctrlBqWr.cocktailNames;
            testBool = ctrlBqWr.hasCocktail;
            testInteger = ctrlBqWr.compareTo(ctrlBqWr);

        test.stopTest();
    }
}