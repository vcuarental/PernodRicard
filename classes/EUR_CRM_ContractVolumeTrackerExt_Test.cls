/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractBuilderControllerExt Class.
  @Author:      IPC
  @History:     JUN.4.2014 - Created
*/
@isTest (SeeAllData=true)
private with sharing class EUR_CRM_ContractVolumeTrackerExt_Test {
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract__c contractNull;
    private static List<EUR_CRM_Contract_Line_Item__c> contractItem;
    private static EUR_CRM_Contract_Mechanic__c contractMech;
    private static EUR_CRM_Contract_Mechanic__c contractMech2;
    private static EUR_CRM_Mechanic_Type__c mechType;
    private static EUR_CRM_Mechanic__c mechanic;
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Quality__c brandQuality;
    private static EUR_CRM_Brand__c brand2;
    private static EUR_CRM_Quality__c brandQuality2;
    private static EUR_CRM_GB_Volume_Tracker__c volumeTracker;
    private static EUR_CRM_GB_Volume_Tracker_Line_Item__c volumeTrackerItem;
    
    public static void dataInsert1(){
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
        
        brand2 = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'GB Brand', 'VODKA', 'TEST-0002', category.Id)[0];
        insert brand2;
        system.assertNotEquals(brand2, null);
        
        brandQuality2 = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'GB Quality', 'Cocktail', 'TEST-0002', brand2.Id)[0];
        insert brandQuality2;
        system.assertNotEquals(brandQuality2, null);
        
        mechType = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'GB Mechanic Type', 'House Pouring Spirits')[0];
        mechType.EUR_CRM_Grouping_Name__c = 'Pouring';
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
        
        contractMech2 = EUR_CRM_TestClassUtilityHelper.createContractMechanic(1, 'GB Contract Mechanic', mechanic.Id)[0];
        contractMech2.EUR_CRM_Brand_Quality__c = brandQuality2.Id;
        contractMech2.EUR_CRM_Brand__c = brand2.Id;
        insert contractMech2;
        system.assertNotEquals(contractMech2, null);
        
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'GB Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contract.EUR_CRM_Contract_Type__c = 'Standard Contract';
        insert contract;
        system.assertNotEquals(contract, null);
        
        List<EUR_CRM_Contract_Line_Item__c> cliList = new List<EUR_CRM_Contract_Line_Item__c>();
        contractItem = EUR_CRM_TestClassUtilityHelper.createContactLineItem(2, 'GB Contract Line Item', contract.Id);
        contractItem[0].EUR_CRM_Contract_Mechanic__c = contractMech.Id;
        contractItem[1].EUR_CRM_Contract_Mechanic__c = contractMech2.Id;
        for(EUR_CRM_Contract_Line_Item__c cli :contractItem){
            cli.EUR_CRM_Process_Option_Lump_Sum__c = true;
            cli.EUR_CRM_Mechanic_Type__c = mechType.Id;
            cli.EUR_Min_Qty_Per_Annum_9L__c = 2;
            cliList.add(cli);
        }
        insert contractItem;
        system.assertNotEquals(contractItem, null);
        
        volumeTracker = EUR_CRM_TestClassUtilityHelper.createVolumeTracker(1, 'EUR GB Volume Tracker', contract.Id)[0];
        insert volumeTracker;
        system.assertNotEquals(volumeTracker, null);
        
        volumeTrackerItem = EUR_CRM_TestClassUtilityHelper.createVolumeTrackerItem(1, volumeTracker.Id)[0];
        volumeTrackerItem.EUR_CRM_Brand__c = brand.Id;
        volumeTrackerItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        volumeTrackerItem.EUR_CRM_Initial_Contract_Volume__c = 2;
        insert volumeTrackerItem;
        system.assertNotEquals(volumeTrackerItem, null);
    }
    
    static testMethod void testContractSummary1(){
        dataInsert1();
        
        test.startTest();
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ContractVolTrackerPage');
            rf.getParameters().put('id', contract.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_ContractVolumeTrackerExt ctrl = new EUR_CRM_ContractVolumeTrackerExt(standardController);
            
            ctrl.contractObj = contract;
            
            
            
        test.stopTest();
    }
    
    static testMethod void testContractSummary2(){
        dataInsert1();
        
        test.startTest();
            volumeTrackerItem.EUR_CRM_Brand_Quality__c = null;
            update volumeTrackerItem;
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ContractVolTrackerPage');
            rf.getParameters().put('id', contract.id);
            rf.getParameters().put('IS_QUICK_SAVE', 'true');
            Test.setCurrentPage(rf);
            
            EUR_CRM_ContractVolumeTrackerExt ctrl = new EUR_CRM_ContractVolumeTrackerExt(standardController);
            
            ctrl.saveVolTracker();
        test.stopTest();
    }
    
    static testMethod void testContractSummary3(){
        dataInsert1();
        
        test.startTest();
            
            delete volumeTracker;
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ContractVolTrackerPage');
            rf.getParameters().put('id', contract.id);
            rf.getParameters().put('IS_QUICK_SAVE', 'false');
            Test.setCurrentPage(rf);
            
            EUR_CRM_ContractVolumeTrackerExt ctrl = new EUR_CRM_ContractVolumeTrackerExt(standardController);
            
            ctrl.saveVolTracker();
        test.stopTest();
    }
}