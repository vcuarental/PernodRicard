/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractBuilderControllerExt Class.
  @Author:      IPC
  @History:     MAY.30.2014 - Created
*/
@isTest
private with sharing class EUR_CRM_ContractBuilderCtrlExt_Test {
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract_Line_Item__c contractItemP;
    private static EUR_CRM_Contract_Line_Item__c contractItemP2;
    private static EUR_CRM_Contract_Line_Item__c contractItemC;
    private static EUR_CRM_Contract_Line_Item__c contractItemC2;
    private static EUR_CRM_Contract_Mechanic__c contractMechC;
    private static EUR_CRM_Contract_Mechanic__c contractMechP;
    private static EUR_CRM_Mechanic_Type__c mechTypeC;
    private static EUR_CRM_Mechanic_Type__c mechTypeP;
    private static EUR_CRM_Mechanic__c mechanicC;
    private static EUR_CRM_Mechanic__c mechanicP;
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Quality__c brandQuality;
    private static EUR_CRM_Cocktail_Menu__c cocktailMenu;
    private static EUR_CRM_Stock_Deal_Mechanic__c stockDealMech;
    
    public static void dataInsert1(){
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        accountEU.EUR_CRM_Sub_Channel__c = null;
        insert accountEU;

        Contact c = new Contact(firstname='Test fname', lastname='Test Lastname',EUR_CRM_Account__c=accountEU.Id);
        insert c;

        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'EUR GB Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contract.EUR_CRM_Contract_Type__c = 'Standard Contract';
        contract.EUR_CRM_Marketing_Package_Lump_Sum__c = null;
        contract.EUR_CRM_Contact__c = c.Id;
        insert contract;
        
        cocktailMenu = new EUR_CRM_Cocktail_Menu__c();
        cocktailMenu.Name = 'Cosmopolitan';
        insert cocktailMenu;
        
        wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, 'EUR AT Wine/Spirits', 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        system.assertNotEquals(wineSpirits, null);
        
        category = EUR_CRM_TestClassUtilityHelper.createCategory(1, 'EUR AT Category', 'TEST-0001', wineSpirits.Id)[0];
        insert category;
        system.assertNotEquals(category, null);
        
        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'EUR AT Brand', 'VODKA', 'TEST-0001', category.Id)[0];
        insert brand;
        system.assertNotEquals(brand, null);
        
        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR AT Quality', 'House Pouring Champagne', 'TEST-0001', brand.Id)[0];
        brandQuality.EUR_CRM_Active__c = true;
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);
        
        stockDealMech = EUR_CRM_TestClassUtilityHelper.createStockDealMech(1, brandQuality.Id, 'TEST-0001')[0];
        stockDealMech.EUR_CRM_Bottles_per_Case_BQ__c = 1;
        stockDealMech.EUR_CRM_Liquid_per_Bottle_litre__c = 1;
        stockDealMech.EUR_CRM_Litres_per_Case__c = 1;
        stockDealMech.EUR_CRM_Qty_Buy__c = 1;
        stockDealMech.EUR_CRM_Qty_Free__c = 1;
        stockDealMech.EUR_CRM_RTM_Price__c = 1;
        stockDealMech.EUR_CRM_Date_Effective__c = date.today();
        stockDealMech.EUR_CRM_Date_Expiry__c = date.today().addDays(20);
        stockDealMech.EUR_CRM_Stock_Deal_Name__c = 'Buy 5 Get 1 Free';
        insert stockDealMech;
        
        mechTypeP = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR GB Mechanic Type', 'House Pouring Spirits')[0];
        mechTypeP.EUR_CRM_Grouping_Name__c = 'Pouring';
        mechTypeP.EUR_CRM_Has_Lump_Sum__c = true;
        mechTypeP.EUR_CRM_Has_Per_BQ__c = true;
        mechTypeP.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        insert mechTypeP;

        system.debug('***mechTypeP ' + [SELECT EUR_CRM_Mechanic_Process_Type__c FROM EUR_CRM_Mechanic_Type__c WHERE id = :mechTypeP.ID]);
        
        mechanicP = EUR_CRM_TestClassUtilityHelper.createMechanic(1, 'GB Mechanic', 'House Pouring Spirits', mechTypeP.Id)[0];
        mechanicP.EUR_CRM_Mechanic_Type__c = mechTypeP.Id;
        insert mechanicP;
        system.assertNotEquals(mechanicP, null);
        
        contractMechP = EUR_CRM_TestClassUtilityHelper.createContractMechanic(1, 'EUR GB Contract Mechanic', mechanicP.Id)[0];
        contractMechP.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        contractMechP.EUR_CRM_Brand__c = brand.Id;
        contractMechP.EUR_CRM_Mechanic__c = mechanicP.Id;
        insert contractMechP;
        system.assertNotEquals(contractMechP, null);
        
        contractItemP = EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', contract.Id)[0];
        contractItemP.EUR_CRM_Process_Option_Lump_Sum__c = false;//true
        contractItemP.EUR_CRM_Mechanic_Type__c = mechTypeP.Id;
        //contractItemP.EUR_CRM_Contract_Mechanic__c = contractMechP.Id;
        insert contractItemP;
        system.assertNotEquals(contractItemP, null);
        
        contractItemP2 = EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', contract.Id)[0];
        contractItemP2.EUR_CRM_Process_Option_Lump_Sum__c = false;
        contractItemP2.EUR_CRM_Mechanic_Type__c = mechTypeP.Id;
        //contractItemP2.EUR_CRM_Contract_Mechanic__c = contractMechP.Id;
        insert contractItemP2;
        system.assertNotEquals(contractItemP2, null);
        
        mechTypeC = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR GB Mechanic Type', 'Cocktail')[0];
        mechTypeP.EUR_CRM_Grouping_Name__c = 'Pouring';
        mechTypeP.EUR_CRM_Has_Lump_Sum__c = true;
        mechTypeP.EUR_CRM_Has_Per_BQ__c = true;
        mechTypeP.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        insert mechTypeC;
        
        mechanicC = EUR_CRM_TestClassUtilityHelper.createMechanic(1, 'GB Mechanic', 'Cocktail', mechTypeC.Id)[0];
        mechanicC.EUR_CRM_Mechanic_Type__c = mechTypeC.Id;
        insert mechanicC;
        system.assertNotEquals(mechanicC, null);
        
        contractMechC = EUR_CRM_TestClassUtilityHelper.createContractMechanic(1, 'EUR GB Contract Mechanic', mechanicC.Id)[0];
        contractMechC.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        contractMechC.EUR_CRM_Brand__c = brand.Id;
        contractMechC.EUR_CRM_Mechanic__c = mechanicC.Id;
        contractMechC.EUR_CRM_Brand_Quality_Name_Ref__c = 'Cocktail';
        insert contractMechC;
        system.assertNotEquals(contractMechC, null);
        
        contractItemC = EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', contract.Id)[0];
        contractItemC.EUR_CRM_Process_Option_Lump_Sum__c = false;//true
        contractItemC.EUR_CRM_Mechanic_Type__c = mechTypeC.Id;
        contractItemC.EUR_CRM_Contract_Mechanic__c = contractMechC.Id;
        insert contractItemC;
        system.assertNotEquals(contractItemC, null);
        
        contractItemC2 = EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', contract.Id)[0];
        contractItemC2.EUR_CRM_Process_Option_Lump_Sum__c = false;
        contractItemC2.EUR_CRM_Mechanic_Type__c = mechTypeC.Id;
        contractItemC2.EUR_CRM_Contract_Mechanic__c = contractMechC.Id;
        insert contractItemC2;
        system.assertNotEquals(contractItemC2, null);

    }
    
    static testMethod void testContractBuilder1(){
        dataInsert1();
        
        test.startTest();
            PageReference rf = new Pagereference('/apex/EUR_CRM_ContractBuilderPage');
            rf.getParameters().put('PARAM_MECHANIC_TYPE_NAME', mechTypeP.Name);
            rf.getParameters().put('PARAM_CONTRACT_MECHANIC_ID', contractMechP.Id);
            rf.getParameters().put('PARAM_BQ_NAME', brandQuality.Name);
            rf.getParameters().put('IS_QUICK_SAVE', 'false');
            rf.getParameters().put('PARAM_HANDLING_CHOICE', 'Lump Sum');
            rf.getParameters().put('PARAM_BQ_REF', contractItemP.id);

            Test.setCurrentPage(rf);
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            EUR_CRM_ContractBuilderControllerExt ctrl = new EUR_CRM_ContractBuilderControllerExt(standardController);
            
            String LUMP_SUM = 'Lump Sum';
            EUR_CRM_ContractBuilderControllerExt.LUMP_SUM = 'Lump Sum';
            EUR_CRM_ContractBuilderControllerExt.PER_BQ = 'Per Brand-Quality';
            EUR_CRM_ContractBuilderControllerExt.CONTRACT_MECHANIC_TABLE_PREFIX = 'ContractMechanicTable_';
            EUR_CRM_ContractBuilderControllerExt.CONTRACT_LINE_ITEM_TABLE_PREFIX = 'ContractLineItemTable_';
            
            
            EUR_CRM_ContractBuilderControllerExt.MechanicTypeWrapper mechWrap1 = new EUR_CRM_ContractBuilderControllerExt.MechanicTypeWrapper('House Pouring Spirits');
            EUR_CRM_ContractBuilderControllerExt.MechanicTypeWrapper mechWrap2 = new EUR_CRM_ContractBuilderControllerExt.MechanicTypeWrapper(mechTypeP);
            
            List<EUR_CRM_Contract_Line_Item__c> contractItemList = new List<EUR_CRM_Contract_Line_Item__c>();
            contractItemList.add(contractItemP);
            mechWrap1.contractLineItemList = contractItemList;
            
            mechWrap2.setContractLineItemMap(contractItemList);
            mechWrap2.putContractLineItem('House Pouring Spirits', contractItemP);
            
            List<EUR_CRM_Contract_Mechanic__c> contractMechList = new List<EUR_CRM_Contract_Mechanic__c>();
            contractMechList.add(contractMechP);
            mechWrap2.setContractMechanicMap(contractMechList);
            
            mechWrap2.putContractMechanic(contractMechP.Id, contractMechP);
            
            mechWrap2.amendTotalValue(102);
            
            Map<Id, EUR_CRM_Contract_Mechanic__c> contractMechMap = new Map<Id, EUR_CRM_Contract_Mechanic__c>();
            contractMechMap.put(contractMechP.Id, contractMechP);
            mechWrap1.contractMechanicMap = contractMechMap;
            mechWrap2.contractMechanicMap = contractMechMap;
            String testSTR = mechWrap1.mechanicTypeChoice;
            List<EUR_CRM_Contract_Line_Item__c> contractLineItemList = mechWrap1.contractLineItemList;
            List<EUR_CRM_Contract_Mechanic__c> contractMechanicList = mechWrap1.contractMechanicList;
            Integer testINT = mechWrap1.contractLineItemMapSize;
            testINT = mechWrap1.contractMechanicMapSize;
            Map<String, EUR_CRM_ContractBuilderControllerExt.MechanicTypeWrapper> subMechanics = mechWrap1.subMechanics;
            Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper> removeContractLineItemWrapper = mechWrap1.removeContractLineItemWrapper(brandQuality.name);
            Map<String, EUR_CRM_Contract_Line_Item__c> removeContractLineItem = mechWrap1.removeContractLineItem(brandQuality.name);


            ctrl.addContractLineItem();
            ctrl.saveContract();
            ctrl.resetMarketingLumpSum();
            ctrl.setLineItemValue();
            ctrl.resetMechanicTypeHandling();
            ctrl.editSelectedCocktail();
            ctrl.isGB_Contract(contract.recordtypeId);
            ctrl.addContractMechanic();

            rf.getParameters().put('PARAM_CONTRACT_MECHANIC_ID', contractMechC.Id);
            rf.getParameters().put('PARAM_BQ_REF', contractItemC.id);
            
            ctrl.addCocktailContractLineItem();
            ctrl.removeCocktailContractLineItem();
            
            EUR_CRM_ContractBuilderControllerExt.rowWrapper rowWrap = new EUR_CRM_ContractBuilderControllerExt.rowWrapper(1,(sObject) contract);
            String resultStr = ctrl.stockDealJSON;
            resultStr = ctrl.marketingPackageHandlingChoice;
            EUR_CRM_Contract_Line_Item__c contractLineItemParam = ctrl.contractLineItemParam;
            Id stockDealIdParam = ctrl.stockDealIdParam;
            resultStr = ctrl.mechanicTypeNameParam;
            resultStr = ctrl.brandQualityNameParam;
            system.assertNotEquals(accountEU, null);
            system.assertNotEquals(contract, null);
            system.assertNotEquals(cocktailMenu, null);
            system.assertNotEquals(stockDealMech, null);
            system.assertNotEquals(mechTypeP, null);
            //system.assertNotEquals(mechTypeC, null);
            Boolean isGB = ctrl.isGB_RectypeId;
            String currencyCode = ctrl.currencyCode;
            
        test.stopTest();

        for (Integer i = 0; i < 20; i++) {
            system.debug('');
        }
    }

}