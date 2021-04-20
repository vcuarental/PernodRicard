/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_ContractBuilderController Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_DE_TestContractBuilderCnt{
    private static String mechanicTypeName1 = 'Pouring Refund';
    private static String mechanicTypeName2 = 'Events';
    private static String mechanicTypeName3 = 'Others';
    private static String mechanicTypeName4 = 'Drinks Menu';
    private static String mechanicTypeName5 = 'WKZ Fix Amount';
    private static String mechanicTypeName6 = 'Napkins';
    private static String mechanicTypeName7 = 'Events';
    private static String mechanicTypeName8 = 'Visibility/ Branding';
    private static String mechanicTypeName9 = 'POS Material';
    private static String mechanicTypeName10 = 'POS WKZ';

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract__c flagshipContract;
    private static EUR_CRM_Budget__c budget;

    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Quality__c brandQuality;

    private static EUR_CRM_Mechanic_Type__c mechType1;
    private static EUR_CRM_Mechanic_Type__c mechType2;
    private static EUR_CRM_Mechanic_Type__c mechType3;
    private static EUR_CRM_Mechanic_Type__c mechType4;
    private static EUR_CRM_Mechanic_Type__c mechType5;
    private static EUR_CRM_Mechanic_Type__c mechType6;
    private static EUR_CRM_Mechanic_Type__c mechType7;
    private static EUR_CRM_Mechanic_Type__c mechType8;
    private static EUR_CRM_Mechanic_Type__c mechType9;
    private static EUR_CRM_Mechanic_Type__c mechType10;

    private static EUR_CRM_Contract_Activity_Item__c contractActivity1;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity2;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity3;
    private static EUR_CRM_Contract_Product_Item__c productItem1;
    private static EUR_CRM_Contract_Product_Item__c productItem2;
    private static EUR_CRM_Contract_Product_Item__c productItem3;

    private static User regionalUser;
    private static User salesRepUser;


    @TestSetup
    static void initData(){
//       EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
            EUR_CRM_DE_TestClassUtilityHelper.NATIONAL_ON_TRADE_MANAGER_ROLE,'testdezxc5@testemail.com', 'testdezxc5@testemail.com', 'testdezxc5');

        salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
            EUR_CRM_DE_TestClassUtilityHelper.SR_ON_TRADE_ROLE,'testdezxc6@testemail.com', 'testdezxc6@testemail.com', 'testdezxc6');
        //regionalUser = [select Id, UserName from User where UserName = 'testdezxc5@testemail.com' limit 1];
        //salesRepUser = [select Id, UserName from User where UserName = 'testdezxc6@testemail.com' limit 1];
    }

    public static void dataInsert1(){
        //Create account
        //
        User regionalUser = [select Id, UserName from User where UserName = 'testdezxc5@testemail.com' limit 1];
        User salesRepUser = [select Id, UserName from User where UserName = 'testdezxc6@testemail.com' limit 1];

        EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', regionalUser.id,  EUR_CRM_DE_TestClassUtilityHelper.DE_REGION_RECORD_TYPE, 'Off trade');
        //System.debug('### dataInsert1 SOQL Limits 1:'+Limits.getQueries());

        EUR_CRM_Territory__c territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', salesRepUser.id,region.id, EUR_CRM_DE_TestClassUtilityHelper.DE_TERRITORY_RECORD_TYPE);
        //System.debug('### dataInsert1 SOQL Limits 2:'+Limits.getQueries());

        EUR_CRM_Postal_Code_Territory_Mapping__c postalmapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('postalmap' , EUR_CRM_DE_TestClassUtilityHelper.TEST_POSTAL , territory.id, EUR_CRM_DE_TestClassUtilityHelper.DE_POSTAL_CODE_MAPPING_RECORD_TYPE);

        //System.debug('### dataInsert1 SOQL Limits 3:'+Limits.getQueries());
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('testtaxonomy', regionalUser.id, EUR_CRM_DE_TestClassUtilityHelper.DE_CUSTOMER_TAXONOMY_RECORD_TYPE);

        //System.debug('### dataInsert1 SOQL Limits 4:'+Limits.getQueries());
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('testname', EUR_CRM_DE_TestClassUtilityHelper.TEST_POSTAL , EUR_CRM_DE_TestClassUtilityHelper.DE_EUACCOUNT_RECORD_TYPE , customerTaxonomy.id, 'Off trade');

        //System.debug('### dataInsert1 SOQL Limits 5:'+Limits.getQueries());
        EUR_CRM_DE_Contract_Class ctrl = new EUR_CRM_DE_Contract_Class();
        budget = ctrl.createBudget(UserInfo.getUserId(), '2015', 'National Sales Manager');
        insert budget;
        //System.debug('### dataInsert1 SOQL Limits 6:'+Limits.getQueries());

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
        brand.EUR_CRM_Is_Competitor__c = false;
        brand.EUR_CRM_Active__c = true;
        insert brand;
        system.assertNotEquals(brand, null);

        //Create BQ
        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, EUR_CRM_DE_TestClassUtilityHelper.DE_QUALITY_RECORD_TYPE, 'Cocktail', 'TEST-0001', brand.Id)[0];
        brandQuality.EUR_CRM_Active__c = true;
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        //Create Mechanic Type
        mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName1)[0];
        mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType1.EUR_CRM_Has_Lump_Sum__c = false;
        mechType1.EUR_CRM_Has_Per_BQ__c = true;
        mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
        mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType1.EUR_CRM_Has_Start_Date__c = true;
        mechType1.EUR_CRM_Has_End_Date__c = true;
        mechType1.EUR_CRM_Has_Payment_Term__c = true;
        mechType1.EUR_CRM_Ignore_CM_Flagship__c = true;
        mechtype1.EUR_CRM_Mechanic_Type_Name_English__c = 'Pouring Refund';

        //Create Mechanic Type
        mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName2)[0];
        mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType2.EUR_CRM_Has_Lump_Sum__c = true;
        mechType2.EUR_CRM_Has_Per_BQ__c = true;
        mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType2.EUR_CRM_Has_Start_Date__c = true;
        mechType2.EUR_CRM_Has_End_Date__c = true;
        mechType2.EUR_CRM_Has_Payment_Term__c = true;
        mechType2.EUR_CRM_Ignore_CM_Flagship__c = true;
        mechType2.EUR_CRM_Mechanic_Type_Name_English__c = 'Training';

        //Create Mechanic Type
        mechType3 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName3)[0];
        mechType3.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType3.EUR_CRM_Has_Lump_Sum__c = true;
        mechType3.EUR_CRM_Has_Per_BQ__c = true;
        mechType3.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType3.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType3.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType3.EUR_CRM_Has_Start_Date__c = true;
        mechType3.EUR_CRM_Has_End_Date__c = true;
        mechType3.EUR_CRM_Has_Payment_Term__c = true;
        mechType3.EUR_CRM_Ignore_CM_Flagship__c = true;
        mechType3.EUR_CRM_Mechanic_Type_Name_English__c = 'Others';


        //Create Mechanic Type
        mechType4 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName4)[0];
        mechType4.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType4.EUR_CRM_Has_Lump_Sum__c = false;
        mechType4.EUR_CRM_Has_Per_BQ__c = false;
        mechType4.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = true;
        mechType4.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
        mechType4.EUR_CRM_Has_Multiple_Activity_Item__c = false;
        mechType4.EUR_CRM_Has_Start_Date__c = false;
        mechType4.EUR_CRM_Has_End_Date__c = false;
        mechType4.EUR_CRM_Has_Payment_Term__c = true;
        mechType4.EUR_CRM_Ignore_CM_Flagship__c = false;
        mechType4.EUR_CRM_Mechanic_Type_Name_English__c = 'Drinks Menu';

        //Create Mechanic Type
        mechType5 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName5)[0];
        mechType5.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType5.EUR_CRM_Has_Lump_Sum__c = true;
        mechType5.EUR_CRM_Has_Per_BQ__c = true;
        mechType5.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType5.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType5.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType5.EUR_CRM_Has_Start_Date__c = true;
        mechType5.EUR_CRM_Has_End_Date__c = true;
        mechType5.EUR_CRM_Has_Payment_Term__c = true;
        mechType5.EUR_CRM_Ignore_CM_Flagship__c = true;
        mechType5.EUR_CRM_Mechanic_Type_Name_English__c = 'WKZ Fix Amount';

        //Create Mechanic Type
        mechType6 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName6)[0];
        mechType6.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType6.EUR_CRM_Has_Lump_Sum__c = true;
        mechType6.EUR_CRM_Has_Per_BQ__c = true;
        mechType6.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType6.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType6.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType6.EUR_CRM_Has_Start_Date__c = true;
        mechType6.EUR_CRM_Has_End_Date__c = true;
        mechType6.EUR_CRM_Has_Payment_Term__c = true;
        mechType6.EUR_CRM_Ignore_CM_Flagship__c = true;
        mechType6.EUR_CRM_Mechanic_Type_Name_English__c = 'Napkins';

        //Create Mechanic Type
        mechType7 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName7)[0];
        mechType7.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType7.EUR_CRM_Has_Lump_Sum__c = true;
        mechType7.EUR_CRM_Has_Per_BQ__c = true;
        mechType7.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType7.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType7.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType7.EUR_CRM_Has_Start_Date__c = true;
        mechType7.EUR_CRM_Has_End_Date__c = true;
        mechType7.EUR_CRM_Has_Payment_Term__c = true;
        mechType7.EUR_CRM_Ignore_CM_Flagship__c = true;
        mechType7.EUR_CRM_Mechanic_Type_Name_English__c = 'Events';

        //Create Mechanic Type
        mechType8 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName8)[0];
        mechType8.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType8.EUR_CRM_Has_Lump_Sum__c = true;
        mechType8.EUR_CRM_Has_Per_BQ__c = true;
        mechType8.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType8.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType8.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType8.EUR_CRM_Has_Start_Date__c = true;
        mechType8.EUR_CRM_Has_End_Date__c = true;
        mechType8.EUR_CRM_Has_Payment_Term__c = true;
        mechType8.EUR_CRM_Ignore_CM_Flagship__c = true;
        mechType8.EUR_CRM_Mechanic_Type_Name_English__c = 'Visibility/ Branding';

        //Create Mechanic Type
        mechType9 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName9)[0];
        mechType9.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType9.EUR_CRM_Has_Lump_Sum__c = true;
        mechType9.EUR_CRM_Has_Per_BQ__c = true;
        mechType9.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType9.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType9.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType9.EUR_CRM_Has_Start_Date__c = true;
        mechType9.EUR_CRM_Has_End_Date__c = true;
        mechType9.EUR_CRM_Has_Payment_Term__c = true;
        mechType9.EUR_CRM_Ignore_CM_Flagship__c = true;
        mechType9.EUR_CRM_Mechanic_Type_Name_English__c = 'POS Material';

        //Create Mechanic Type
        mechType10 = EUR_CRM_TestClassUtilityHelper.createMechType(1, 'EUR DE Mechanic Type', mechanicTypeName10)[0];
        mechType10.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType10.EUR_CRM_Has_Lump_Sum__c = true;
        mechType10.EUR_CRM_Has_Per_BQ__c = true;
        mechType10.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
        mechType10.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType10.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType10.EUR_CRM_Has_Start_Date__c = true;
        mechType10.EUR_CRM_Has_End_Date__c = true;
        mechType10.EUR_CRM_Has_Payment_Term__c = true;
        mechType10.EUR_CRM_Ignore_CM_Flagship__c = true;
        mechType10.EUR_CRM_Mechanic_Type_Name_English__c = 'POS WKZ';

    }

    public static void dataInsert2() {
        //System.debug('### dataInsert2 SOQL Limits 1:'+Limits.getQueries());
        //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addYears(3))[0];
        contract.EUR_CRM_Contract_Type__c = 'Flagship Contract';
        contract.eur_crm_budget__c = budget.id;
        insert contract;
        //System.debug('### dataInsert2 SOQL Limits 2:'+Limits.getQueries());

        //Create Contract Activity1
        contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);
        contractActivity1.EUR_CRM_Name__c = 'Test Pouring Refund';
        contractActivity1.EUR_CRM_Payment_Term_By_SR__c = 'Nach Umsetzung';
        contractActivity1.EUR_CRM_Start_Date__c = Date.today();
        contractActivity1.EUR_CRM_End_Date__c = Date.today().addYears(2);

        //Create Contract Activity 2
        contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
        contractActivity2.EUR_CRM_Name__c = 'Test Training';
        contractActivity2.EUR_CRM_Is_PR_Training__c = false;
        contractActivity2.EUR_CRM_Amount__c = 1000;
        contractActivity2.EUR_CRM_Start_Date__c = Date.today();
        contractActivity2.EUR_CRM_End_Date__c = Date.today().addYears(2);

        contractActivity3 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);
        contractActivity3.EUR_CRM_Name__c = 'Test Event';
        contractActivity3.EUR_CRM_Is_PR_Event__c = true;
        contractActivity3.EUR_CRM_Start_Date__c = Date.today();
        contractActivity3.EUR_CRM_End_Date__c = Date.today().addYears(2);
        insert new List<EUR_CRM_Contract_Activity_Item__c> {contractActivity1, contractActivity2, contractActivity3};
        //System.debug('### dataInsert2 SOQL Limits 3:'+Limits.getQueries());

        //Create Focus Brand
        //Create Listing/ Pouring
        //Create Contract Product Item
        productItem1 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity2.Id, brand);
        productItem1.EUR_CRM_Amount__c = 2;
        productItem1.EUR_CRM_Quantity__c = 1000;
        productItem2 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity1.Id, brandQuality);
        productItem2.EUR_CRM_Amount__c = 2;
        productItem2.EUR_CRM_Quantity__c = 1000;
        productItem3 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity3.Id, brandQuality);
        productItem3.EUR_CRM_Amount__c = 2;
        productItem3.EUR_CRM_Quantity__c = 1000;
        insert new List<EUR_CRM_Contract_Product_Item__c> {productItem1, productItem2, productItem3};
        //System.debug('### dataInsert2 SOQL Limits 4:'+Limits.getQueries());
    }

    static testMethod void testContractBuilder1(){
        //EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
//        regionalUser = [select Id, UserName from User where UserName = 'testdezxc5@testemail.com' limit 1];
//        salesRepUser = [select Id, UserName from User where UserName = 'testdezxc6@testemail.com' limit 1];
//        System.debug('### SOQL Limits 1:'+Limits.getQueries());
//        system.runAs(regionalUser){

            dataInsert1();

            System.debug('### SOQL Limits 2:'+Limits.getQueries());

            insert new List<EUR_CRM_Mechanic_Type__c> {mechType1, mechType2};


            String contractActivityKey1 = 'CURRENT_CA_FLAG';
            Id contractSourceId1 = brandQuality.Id;
            Id contractSourceId2 = brand.Id;


            test.startTest();
            System.debug('### SOQL Limits 3:'+Limits.getQueries());
            dataInsert2();
            System.debug('### SOQL Limits 4:'+Limits.getQueries());

            PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractBuilderPage');
            pageRef.getParameters().put('PARAM_MECHANIC_TYPE_NAME', mechType1.Name);
            pageRef.getParameters().put('PARAM_CONTRACT_ACTIVITY_KEY', contractActivityKey1);
            pageRef.getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID', contractSourceId1);

            Test.setCurrentPage(pageRef);

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            EUR_CRM_DE_ContractBuilderController ctrl = new EUR_CRM_DE_ContractBuilderController(standardController);
            EUR_CRM_DE_ContractBuilderRedirectCtrl redirectCtrl = new EUR_CRM_DE_ContractBuilderRedirectCtrl(standardController);
            redirectCtrl.redirect();

            EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper mechanicTypeWrapper1 = new EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper(mechanicTypeName1);
            EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper mechanicTypeWrapper2 = new EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper(mechType2);
            EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper contractActivityWrapper1 = new EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper(contractActivity1);
            EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper contractActivityWrapper2 = new EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper(contractActivity2);
            mechanicTypeWrapper1.contractActivityItems = new Map<String, EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper>{contractActivityKey1=>contractActivityWrapper1};
            contractActivityWrapper1.brandQualityItems = new Map<Id, EUR_CRM_Quality__c>{brandQuality.Id=>brandQuality};
            System.debug('### SOQL Limits 5:'+Limits.getQueries());
            Boolean hasProductItems = mechanicTypeWrapper1.hasProductItems;

            mechanicTypeWrapper1.currentContractActivityItem = contractActivityWrapper1;
            System.debug('\n mechanicTypeWrapper1.currentContractActivityItem => ' + JSON.serializePretty(mechanicTypeWrapper1.currentContractActivityItem) + '\n');
            ctrl.getPouringRefundPaymentTermOptions();
            mechanicTypeWrapper2.currentContractActivityItem = contractActivityWrapper2;
            System.debug('\n mechanicTypeWrapper2.currentContractActivityItem => ' + JSON.serializePretty(mechanicTypeWrapper2.currentContractActivityItem) + '\n');
//            ctrl.getTrainingPaymentTermOptions();

            ctrl.initContract(contract.Id);
            ctrl.initContractContent(contract);

            pageRef.getParameters().put('PARAM_CONTRACT_ACTIVITY_KEY', '0');
            ctrl.retrieveCurrentContractActivity();


            Map<String, EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper> wrapperMap = ctrl.mechanicTypeWrapperMap;
            System.debug('### SOQL Limits 6:'+Limits.getQueries());
            System.debug('Saving saveCurrentContractActivity');
            ctrl.saveCurrentContractActivity();
            System.debug('Save Contract');
			test.stopTest();
            System.debug('### SOQL Limits 7:'+Limits.getQueries());
//            ctrl.saveContract();
            ctrl.cloneContractActivity();
            ctrl.postProcessPRDActivity();

            ctrl.addContractProductItem();
            pageRef.getParameters().put('PARAM_CONTRACT_PRODUCT_ITEM_ID', brandQuality.Id);
            ctrl.removeContractProductItem();

            ctrl.removeContractActivity();
            ctrl.removeCurrentContractActivity();
            ctrl.clearContractActivity();
            String unitValue = ctrl.defaultUnitValue;
            List<SelectOption> unitOptions = ctrl.unitOptions;
            pageRef.getParameters().put('PARAM_MECHANIC_TYPE_NAME', mechType2.Name);
            pageRef.getParameters().put('PARAM_PR_DE_FLAG', 'true');
            System.debug('### SOQL Limits 8:'+Limits.getQueries());
            mechanicTypeWrapper2.resetCurrentContractActivity();
            Decimal mTotal = mechanicTypeWrapper2.total;
            Decimal mDTotal = mechanicTypeWrapper2.deductibleTotal;
            Set<String> mSet = mechanicTypeWrapper2.contractActivityNameSet;

            Decimal aTotal = contractActivityWrapper1.total;
            contractActivityWrapper1.assignDescriptionId();
            contractActivityWrapper1.retrieveExistingBrands();
            contractActivityWrapper1.retrieveExistingBrandQualities();

            pageRef.getParameters().put('param_PRDEFlag', 'true');
            ctrl.postProcessPRDActivity();
            ctrl.saveContract();

            ctrl.cloneContractActivity();

            system.assertNotEquals(accountEU, null);
            system.assertNotEquals(contract, null);
            system.assertNotEquals(mechType1, null);
            system.assertNotEquals(mechType2, null);
            pageRef.getParameters().put('PARAM_SELECTED_FLAGSHIP_BRAND', brand.Id);
            ctrl.resetFlagshipBrandSelection();
            Double totalByCurrentFY = mechanicTypeWrapper1.TotalByCurrentFY();
            Double deductibleTotalByCurrentFY = mechanicTypeWrapper1.DeductibleTotalByCurrentFY();
//            System.debug('### SOQL Limits 5:'+Limits.getQueries());

//        }
    }

    static testMethod void testContractBuilder2(){
        //EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        regionalUser = [select Id, UserName from User where UserName = 'testdezxc5@testemail.com' limit 1];
        salesRepUser = [select Id, UserName from User where UserName = 'testdezxc6@testemail.com' limit 1];


//        system.runAs(regionalUser){

            dataInsert1();
            test.startTest();
            insert new List<EUR_CRM_Mechanic_Type__c> {mechType3, mechType4, mechType5, mechType6, mechType7, mechType8, mechType9, mechType10};


            String contractActivityKey1 = '54524287';
            Id contractSourceId1 = brandQuality.Id;
            Id contractSourceId2 = brand.Id;

            dataInsert2();


            PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractBuilderPage');
            pageRef.getParameters().put('PARAM_MECHANIC_TYPE_NAME', mechType1.Name);
            pageRef.getParameters().put('PARAM_CONTRACT_ACTIVITY_KEY', contractActivityKey1);
            pageRef.getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID', contractSourceId1);

            Test.setCurrentPage(pageRef);

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            EUR_CRM_DE_ContractBuilderController ctrl = new EUR_CRM_DE_ContractBuilderController(standardController);
            EUR_CRM_DE_ContractBuilderRedirectCtrl redirectCtrl = new EUR_CRM_DE_ContractBuilderRedirectCtrl(standardController);
            redirectCtrl.redirect();

            EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper mechanicTypeWrapper1 = new EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper(mechanicTypeName1);
            EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper mechanicTypeWrapper2 = new EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper(mechType2);
            Integer lastCount = mechanicTypeWrapper2.lastContractActivityCount;

            EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper contractActivityWrapper1 = new EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper(contractActivity1);
            mechanicTypeWrapper1.contractActivityItems = new Map<String, EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper>{contractActivityKey1=>contractActivityWrapper1};
            contractActivityWrapper1.brandQualityItems = new Map<Id, EUR_CRM_Quality__c>{brandQuality.Id=>brandQuality};

            Boolean hasProductItems = mechanicTypeWrapper1.hasProductItems;
            Boolean isValid = ctrl.validateContract(contract);

            ctrl.getDrinksMenuPaymentTermOptions();
            ctrl.getWKZFixAmountPaymentTermOptions();
            ctrl.getNapkinsPaymentTermOptions();
            ctrl.getVisibilityPaymentTermOptions();
            ctrl.getPOSMaterialPaymentTermOptions();
            ctrl.getPOSWKZPaymentTermOptions();
//            ctrl.getEventsPaymentTermOptions();
//            ctrl.getOtherPaymentTermOptions();
            test.stopTest();

            String st1 = EUR_CRM_DE_ContractBuilderController.CONTRACT_MECHANIC_TABLE_PREFIX;
            String st2 = EUR_CRM_DE_ContractBuilderController.CONTRACT_LINE_ITEM_TABLE_PREFIX;
            String st3 = EUR_CRM_DE_ContractBuilderController.CONTRACT_SUMMARY_ITEM_PREFIX;
            String st4 = ctrl.PR_DEUTSCHLAND;
            String st5 = ctrl.FOCUS_BRAND_KEY;
            String st6 = ctrl.LISTING_POURING_KEY;
            String st7 = EUR_CRM_DE_ContractBuilderController.FLAGSHIP;
            String st8 = ctrl.mechanicTypeValue;
            List<EUR_CRM_Brand__c> brandsList = ctrl.allBrandList;
            List<EUR_CRM_Quality__c> qualityList = ctrl.allBrandQualityList;
            Boolean b1 = ctrl.isFlagshipMode;
            Double d1 = ctrl.actualContractTotal;
            String st9 = ctrl.remainingUserBudgetTotalStr;
//        }
    }

    static testMethod void testContractBuilder3(){
        //30 soql
        //EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        regionalUser = [select Id, UserName from User where UserName = 'testdezxc5@testemail.com' limit 1];
        salesRepUser = [select Id, UserName from User where UserName = 'testdezxc6@testemail.com' limit 1];
        //System.debug('### testContractBuilder3 SOQL Limits 1:'+Limits.getQueries());
//        system.runAs(regionalUser){

            test.startTest();
            dataInsert1();  //46 soql
            //System.debug('### testContractBuilder3 SOQL Limits 2:'+Limits.getQueries());
            insert new List<EUR_CRM_Mechanic_Type__c> {mechType1, mechType2};
            //System.debug('### testContractBuilder3 SOQL Limits 3:'+Limits.getQueries());

            String contractActivityKey1 = '54524287';
            Id contractSourceId1 = brandQuality.Id;
            Id contractSourceId2 = brand.Id;

            dataInsert2();  //51 soql
            //System.debug('### testContractBuilder3 SOQL Limits 4:'+Limits.getQueries());
            test.stopTest();

            PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractBuilderPage');
            pageRef.getParameters().put('PARAM_MECHANIC_TYPE_NAME', mechType1.Name);
            Test.setCurrentPage(pageRef);

            EUR_CRM_ComponentControllerBase baseController = new EUR_CRM_ComponentControllerBase();

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            EUR_CRM_DE_ContractBuilderController ctrl = new EUR_CRM_DE_ContractBuilderController(standardController);
            EUR_CRM_DE_ContractBuilderRedirectCtrl redirectCtrl = new EUR_CRM_DE_ContractBuilderRedirectCtrl(standardController);
            ctrl.setComponentController(baseController);
            ctrl.setComponentControllerMap('MapKey', baseController);
            redirectCtrl.redirect();

            EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper mechanicTypeWrapper1 = new EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper(mechanicTypeName1);
            EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper mechanicTypeWrapper2 = new EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper(mechType2);
            Integer lastCount = mechanicTypeWrapper2.lastContractActivityCount;

            EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper contractActivityWrapper1 = new EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper(contractActivity1);
            mechanicTypeWrapper1.contractActivityItems = new Map<String, EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper>{contractActivityKey1=>contractActivityWrapper1};
            contractActivityWrapper1.brandQualityItems = new Map<Id, EUR_CRM_Quality__c>{brandQuality.Id=>brandQuality};

            ctrl.retrieveCurrentContractActivity();
            ctrl.saveCurrentContractActivity();
            ctrl.saveContract();
            //System.debug('### testContractBuilder3 SOQL Limits 5:'+Limits.getQueries());
//        }
    }

    static testMethod void testContractBuilder4(){
        //EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        regionalUser = [select Id, UserName from User where UserName = 'testdezxc5@testemail.com' limit 1];
        salesRepUser = [select Id, UserName from User where UserName = 'testdezxc6@testemail.com' limit 1];


//        system.runAs(regionalUser){
//            System.debug('### Limits 1:'+Limits.getQueries());
            dataInsert1();
//            System.debug('### Limits 2:'+Limits.getQueries());
            insert new List<EUR_CRM_Mechanic_Type__c> {mechType1, mechType2};

            String contractActivityKey1 = '54524287';
            Id contractSourceId1 = brandQuality.Id;
            Id contractSourceId2 = brand.Id;

            test.startTest();
            dataInsert2();
//            System.debug('### Limits 3:'+Limits.getQueries());

            EUR_CRM_ComponentControllerBase baseController = new EUR_CRM_ComponentControllerBase();

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            EUR_CRM_DE_ContractBuilderController ctrl = new EUR_CRM_DE_ContractBuilderController(standardController);
            EUR_CRM_DE_ContractBuilderRedirectCtrl redirectCtrl = new EUR_CRM_DE_ContractBuilderRedirectCtrl(standardController);
            ctrl.setComponentController(baseController);
            ctrl.setComponentControllerMap('MapKey', baseController);
            redirectCtrl.redirect();

            EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper mechanicTypeWrapper1 = new EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper(mechanicTypeName1);
            EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper mechanicTypeWrapper2 = new EUR_CRM_DE_ContractBuilderController.MechanicTypeWrapper(mechType2);
            Integer lastCount = mechanicTypeWrapper2.lastContractActivityCount;

            EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper contractActivityWrapper1 = new EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper(contractActivity1);
            mechanicTypeWrapper1.contractActivityItems = new Map<String, EUR_CRM_DE_ContractBuilderController.ContractActivityItemWrapper>{contractActivityKey1=>contractActivityWrapper1};
            contractActivityWrapper1.brandQualityItems = new Map<Id, EUR_CRM_Quality__c>{brandQuality.Id=>brandQuality};

            ctrl.retrieveCurrentContractActivity();
            ctrl.saveCurrentContractActivity();
            ctrl.saveContract();
            test.stopTest();
//        }
    }

    @IsTest
    private static void testContractBuilder5() {
        regionalUser = [select Id, UserName from User where UserName = 'testdezxc5@testemail.com' limit 1];
        salesRepUser = [select Id, UserName from User where UserName = 'testdezxc6@testemail.com' limit 1];
//        system.runAs(regionalUser) {
            dataInsert1();
            Test.startTest();
            dataInsert2();

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            EUR_CRM_DE_ContractBuilderController controller = new EUR_CRM_DE_ContractBuilderController(standardController);
            controller.createContractProductItem(contractActivity1);
            controller.createContractProductItem(contractActivity1, brand);
            Test.stopTest();
//        }
    }
}