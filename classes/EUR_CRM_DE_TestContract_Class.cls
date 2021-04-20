/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_Contract_Class Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_DE_TestContract_Class{
    private static String mechanicTypeName1 = 'Pouring Refund';
    private static String mechanicTypeName2 = 'Events';

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Contract_Focus_Brand__c contractFocusBrand;
    private static EUR_CRM_Quality__c brandQuality;
    
    private static EUR_CRM_Mechanic_Type__c mechType1;
    private static EUR_CRM_Mechanic_Type__c mechType2;
    
    private static EUR_CRM_Contract_Activity_Item__c contractActivity1;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity2;
    
    private static EUR_CRM_Contract_Product_Item__c productItem1;
    private static EUR_CRM_Contract_Product_Item__c productItem2;
    public final static String DE_REGION_RECORD_TYPE = 'DE Region';
    public final static String DE_TERRITORY_RECORD_TYPE = 'DE Territory';
    public final static String DE_OFF_TRADE_USER_PROFILE = 'EUR DE OFF Trade User';
    public final static String DE_POSTAL_CODE_MAPPING_RECORD_TYPE = 'DE Off Trade Postal Code - Territory Mapping';
    public final static String DE_CUSTOMER_TAXONOMY_RECORD_TYPE =  'DE Customer Taxonomy';
    public final static String DE_ACTION_LIST_TEMPLATE_EXT_ID = 'DE_OFF_ALT_Leaflet_Campaign';
    public final static String DE_ACTION_LIST_TEMPLATE_RECORD_TYPE = 'DE O/P Action List Template';
    public final static String REGIONAL_OFF_TRADE_MANAGER_ROLE = 'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East';
    public final static String SR_OFF_TRADE_ROLE = 'EUR_DE_BZL_Nord_East';
    public final static String TEST_POSTAL = '12345';
    public final static String DE_EUACCOUNT_RECORD_TYPE = 'DE OFF STD';
    
    @TestSetup
    public static void dataInsert1(){
        //User regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_OFF_TRADE_USER_PROFILE,REGIONAL_OFF_TRADE_MANAGER_ROLE,'testdezxc2@testemail.com', 'testdezxc2@testemail.com', 'testdezxc2');
        
        //User salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_OFF_TRADE_USER_PROFILE, SR_OFF_TRADE_ROLE,'testdezxc3@testemail.com', 'testdezxc3@testemail.com', 'testdezxc3');  
        //Create account
        
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade(); //Added by Laputa Hugo Cheung 26/09/2016
        
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', EUR_CRM_DE_TestClassUtilityHelper.regionalUser.id,  DE_REGION_RECORD_TYPE);
    
            EUR_CRM_Territory__c territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', EUR_CRM_DE_TestClassUtilityHelper.salesRepUser.id,region.id, DE_TERRITORY_RECORD_TYPE);
         
            EUR_CRM_Postal_Code_Territory_Mapping__c postalmapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('postalmap' , TEST_POSTAL , territory.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
        }
         
    }
    
    static testMethod void testMethod1(){
        User u = [SELECT Id FROM User WHERE UserName = 'testdezxc5@testemail.com']; //Added by Laputa Hugo Cheung 26/09/2016
        //EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        //system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
        system.runAs(u){
            test.startTest();
            
            //EUR_CRM_Customer_Taxonomy__c customerTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('testtaxonomy', EUR_CRM_DE_TestClassUtilityHelper.regionalUser.id, DE_CUSTOMER_TAXONOMY_RECORD_TYPE);
         EUR_CRM_Customer_Taxonomy__c customerTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('testtaxonomy', u.id, DE_CUSTOMER_TAXONOMY_RECORD_TYPE);
         //EUR_CRM_OP_Action_List_Template__c actionListTemplate = EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('testsdfsdf',DE_ACTION_LIST_TEMPLATE_EXT_ID ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE );
         
         accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('testname', TEST_POSTAL , DE_EUACCOUNT_RECORD_TYPE , customerTaxonomy.id);
         //sku = createSKU('test', '23',DE_SKU);
         //bqs = createSIZE('test',DE_SIZE);
        
        
        
        
        //accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
            
            //Create Wine Spirit
        wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, EUR_CRM_DE_TestClassUtilityHelper.DE_WINE_SPIRIT_RECORD_TYPE, 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        system.assertNotEquals(wineSpirits, null);

        //Create category
        category = EUR_CRM_TestClassUtilityHelper.createCategory(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CATEGORY_RECORD_TYPE, 'TEST-0001', wineSpirits.Id)[0];
        insert category;
        system.assertNotEquals(category, null);
        
        //Create Brand
        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, EUR_CRM_DE_TestClassUtilityHelper.DE_BRAND_RECORD_TYPE, 'VODKA', 'TEST-0001', category.Id)[0];
        insert brand;
        system.assertNotEquals(brand, null);
  
        //Create BQ
        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, EUR_CRM_DE_TestClassUtilityHelper.DE_QUALITY_RECORD_TYPE, 'Cocktail', 'TEST-0001', brand.Id)[0];
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);
        
        List<EUR_CRM_Mechanic_Type__c> mechTypeList = new List<EUR_CRM_Mechanic_Type__c>();
        //Create Mechanic Type
        mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName1)[0];
        mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType1.EUR_CRM_Has_Lump_Sum__c = false;
        mechType1.EUR_CRM_Has_Per_BQ__c = true;
        mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
        mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = false;
        mechTypeList.add(mechType1);
        
        //Create Mechanic Type
        mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName2)[0];
        mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType2.EUR_CRM_Has_Lump_Sum__c = true;
        mechType2.EUR_CRM_Has_Per_BQ__c = true;
        mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechTypeList.add(mechType2);
        
        insert mechTypeList;
        
        //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
        insert contract;

         // Create contract Focus Brand
        contractFocusBrand  = EUR_CRM_DE_TestClassUtilityHelper.createContractFocusBrandItem(EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_FOCUS_BRAND_RECORD_TYPE, contract.Id, brand.Id);
        
        List<EUR_CRM_Contract_Activity_Item__c> contractActivityList = new List<EUR_CRM_Contract_Activity_Item__c>();
        //Create Contract Activity1
        contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);
        contractActivityList.add(contractActivity1);
        
        //Create Contract Activity 2
        contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
        contractActivity2.EUR_CRM_Name__c = 'Test';
        contractActivityList.add(contractActivity2);
        insert contractActivityList;
        
        //Create Contract Product Item
        List<EUR_CRM_Contract_Product_Item__c> productItemList = new List<EUR_CRM_Contract_Product_Item__c>();
        productItem1 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity2.Id, brand);
        productItem2 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity1.Id, brandQuality);
        productItemList.add(productItem2); 
        productItemList.add(productItem1);
        insert productItemList;
        
        
            
            List<EUR_CRM_Mechanic_Type__c> mechanicTypeList = new List<EUR_CRM_Mechanic_Type__c>();
            mechanicTypeList.add(mechType1);
            mechanicTypeList.add(mechType2);

            system.assertNotEquals(contract, null);
            system.assertNotEquals(mechType1, null);
            system.assertNotEquals(mechType2, null);
            
            test.StopTest();
            EUR_CRM_DE_Contract_Class ctrl = new EUR_CRM_DE_Contract_Class();
            ctrl.retrieveContractDetails(contract.Id);
            system.debug('@contractFocusBrand'+contractFocusBrand);
            system.debug('@contract'+contract);
            ctrl.retrieveFocusBrands(contract.Id);
            ctrl.retrieveListingPouring(contract.Id);
            ctrl.retrieveMechanicTypes(contract);
            ctrl.retrieveContractActivityItems(contract);
            

            ctrl.retrieveContractActivityItems(contract, mechanicTypeList);
            
            ctrl.retrieveContractProductItems(contract);
            ctrl.retrieveContractProductItems(contract,mechanicTypeList);
            
            ctrl.retrieveItemSourceBrandQualities(contract);
            
            ctrl.retrieveFiscalYearStart();
            
            ctrl.formatFiscalYear(Date.Today());
        }
    }
    
    static testMethod void testMethod2(){
        User u = [SELECT Id FROM User WHERE UserName = 'testdezxc5@testemail.com']; //Added by Laputa Hugo Cheung 26/09/2016
        //EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        //system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
        system.runAs(new User(Id = u.Id)){
            
        test.startTest(); 
        //EUR_CRM_Customer_Taxonomy__c customerTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('testtaxonomy', EUR_CRM_DE_TestClassUtilityHelper.regionalUser.id, DE_CUSTOMER_TAXONOMY_RECORD_TYPE);
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('testtaxonomy', u.id, DE_CUSTOMER_TAXONOMY_RECORD_TYPE);
         //EUR_CRM_OP_Action_List_Template__c actionListTemplate = EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('testsdfsdf',DE_ACTION_LIST_TEMPLATE_EXT_ID ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE );
         
        
         accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('testname', TEST_POSTAL , DE_EUACCOUNT_RECORD_TYPE , customerTaxonomy.id);
         //sku = createSKU('test', '23',DE_SKU);
         //bqs = createSIZE('test',DE_SIZE);
        
        
        
        
        //accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
            //Create Wine Spirit
        wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, EUR_CRM_DE_TestClassUtilityHelper.DE_WINE_SPIRIT_RECORD_TYPE, 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        system.assertNotEquals(wineSpirits, null);

        //Create category
        category = EUR_CRM_TestClassUtilityHelper.createCategory(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CATEGORY_RECORD_TYPE, 'TEST-0001', wineSpirits.Id)[0];
        insert category;
        system.assertNotEquals(category, null);
        
        //Create Brand
        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, EUR_CRM_DE_TestClassUtilityHelper.DE_BRAND_RECORD_TYPE, 'VODKA', 'TEST-0001', category.Id)[0];
        insert brand;
        system.assertNotEquals(brand, null);
  
        //Create BQ
        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, EUR_CRM_DE_TestClassUtilityHelper.DE_QUALITY_RECORD_TYPE, 'Cocktail', 'TEST-0001', brand.Id)[0];
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);
        
        List<EUR_CRM_Mechanic_Type__c> mechTypeList = new List<EUR_CRM_Mechanic_Type__c>();
        //Create Mechanic Type
        mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName1)[0];
        mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType1.EUR_CRM_Has_Lump_Sum__c = false;
        mechType1.EUR_CRM_Has_Per_BQ__c = true;
        mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
        mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = false;
        mechTypeList.add(mechType1);
        
        //Create Mechanic Type
        mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName2)[0];
        mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType2.EUR_CRM_Has_Lump_Sum__c = true;
        mechType2.EUR_CRM_Has_Per_BQ__c = true;
        mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechTypeList.add(mechType2);
        
        insert mechTypeList;
        
        //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
        insert contract;

         // Create contract Focus Brand
        contractFocusBrand  = EUR_CRM_DE_TestClassUtilityHelper.createContractFocusBrandItem(EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_FOCUS_BRAND_RECORD_TYPE, contract.Id, brand.Id);
        
        List<EUR_CRM_Contract_Activity_Item__c> contractActivityList = new List<EUR_CRM_Contract_Activity_Item__c>();
        //Create Contract Activity1
        contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);
        contractActivityList.add(contractActivity1);
        
        //Create Contract Activity 2
        contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
        contractActivity2.EUR_CRM_Name__c = 'Test';
        contractActivityList.add(contractActivity2);
        insert contractActivityList;
        
        //Create Contract Product Item
        List<EUR_CRM_Contract_Product_Item__c> productItemList = new List<EUR_CRM_Contract_Product_Item__c>();
        productItem1 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity2.Id, brand);
        productItem2 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity1.Id, brandQuality);
        productItemList.add(productItem2); 
        productItemList.add(productItem1);
        insert productItemList;
        
        
            
            List<EUR_CRM_Mechanic_Type__c> mechanicTypeList = new List<EUR_CRM_Mechanic_Type__c>();
            mechanicTypeList.add(mechType1);
            mechanicTypeList.add(mechType2);
            
            test.stopTest();
            EUR_CRM_DE_Contract_Class ctrl = new EUR_CRM_DE_Contract_Class(contract.Id);
            String CONTRACT_MECHANIC_TABLE_PREFIX = EUR_CRM_DE_Contract_Class.CONTRACT_MECHANIC_TABLE_PREFIX;
            String CONTRACT_LINE_ITEM_TABLE_PREFIX = EUR_CRM_DE_Contract_Class.CONTRACT_LINE_ITEM_TABLE_PREFIX;
            String CONTRACT_SUMMARY_ITEM_PREFIX = EUR_CRM_DE_Contract_Class.CONTRACT_SUMMARY_ITEM_PREFIX;
            String DESCRIPTION_PREFIX = EUR_CRM_DE_Contract_Class.DESCRIPTION_PREFIX;
            String CURRENT_CONTRACT_ACTIVITY_FLAG = EUR_CRM_DE_Contract_Class.CURRENT_CONTRACT_ACTIVITY_FLAG;
            String FLAGSHIP = EUR_CRM_DE_Contract_Class.FLAGSHIP;
            ctrl.retrieveContractDetails(contract.Id);
            ctrl.retrieveFocusBrands(contract.Id);
            ctrl.retrieveListingPouring(contract.Id);
            ctrl.retrieveMechanicTypes(contract);
            ctrl.retrieveContractActivityItems(contract);
            

            ctrl.retrieveContractActivityItems(contract, mechanicTypeList);
            
            ctrl.retrieveContractProductItems(contract);
            ctrl.retrieveContractProductItems(contract,mechanicTypeList);
            
            ctrl.retrieveItemSourceBrandQualities(contract);
            
            ctrl.retrieveFiscalYearStart();
            
            ctrl.formatFiscalYear(Date.Today());
            EUR_CRM_Budget__c budget = ctrl.createBudget(UserInfo.getUserId(), '2015', 'National Sales Manager');
            insert budget;
            ctrl.cloneBudget(budget, '2015');
            ctrl.createContractTransactionDebit(budget.id,contract.Id  , 10, null);
            ctrl.createContractTransactionDebit(budget.id, 10, null);
        }
        
    }
}