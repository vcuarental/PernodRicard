/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_ContractPDFControllerExt Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_DE_TestContractPDFControllerExt {
    private static String mechanicTypeName1 = 'Pouring Refund';
    private static String mechanicTypeName2 = 'Events';

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;

    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Quality__c brandQuality;

    private static EUR_CRM_Mechanic_Type__c mechType1;
    private static EUR_CRM_Mechanic_Type__c mechType2;

    private static EUR_CRM_Contract_Activity_Item__c contractActivity1;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity2;

    private static EUR_CRM_Contract_Focus_Brand__c focusBrand1;
    private static EUR_CRM_Contract_Listing_Pouring__c listingPouring1;

    private static EUR_CRM_Contract_Product_Item__c productItem1;
    private static EUR_CRM_Contract_Product_Item__c productItem2;

    public static void dataInsert1() {
        //Create account
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;

        System.debug('After Account Creation');

        //Create Wine Spirit
        wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, EUR_CRM_DE_TestClassUtilityHelper.DE_WINE_SPIRIT_RECORD_TYPE, 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        system.assertNotEquals(wineSpirits, null);

        System.debug('After WineSpirits Creation');

        //Create category
        category = EUR_CRM_TestClassUtilityHelper.createCategory(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CATEGORY_RECORD_TYPE, 'TEST-0001', wineSpirits.Id)[0];
        insert category;
        system.assertNotEquals(category, null);

        System.debug('After Category Creation');

        //Create Brand
        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, EUR_CRM_DE_TestClassUtilityHelper.DE_BRAND_RECORD_TYPE, 'VODKA', 'TEST-0001', category.Id)[0];
        insert brand;
        system.assertNotEquals(brand, null);

        System.debug('After Brand');

        //Create BQ
        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, EUR_CRM_DE_TestClassUtilityHelper.DE_QUALITY_RECORD_TYPE, 'Cocktail', 'TEST-0001', brand.Id)[0];
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        System.debug('After BrandQuality');

        //Create Mechanic Type
        mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName1)[0];
        mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType1.EUR_CRM_Has_Lump_Sum__c = false;
        mechType1.EUR_CRM_Has_Per_BQ__c = true;
        mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c = false;
        mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
        mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = false;

        //Create Mechanic Type
        mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName2)[0];
        mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType2.EUR_CRM_Has_Lump_Sum__c = true;
        mechType2.EUR_CRM_Has_Per_BQ__c = true;
        mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c = false;
        mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        insert new List<EUR_CRM_Mechanic_Type__c>{
                mechType1, mechType2
        };
    }

    public static void dataInsert2() {
        //Create Contract
        System.debug('@@@ accountEU: ' + accountEU);
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addYears(3))[0];
        insert contract;

        //Create Contract Activity1
        contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);

        //Create Contract Activity 2
        contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
        contractActivity2.EUR_CRM_Name__c = 'Test';
        insert new List<EUR_CRM_Contract_Activity_Item__c>{
                contractActivity1, contractActivity2
        };

        //Create Focus Brand
        focusBrand1 = EUR_CRM_DE_TestClassUtilityHelper.createContractFocusBrandItem(EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_FOCUS_BRAND_RECORD_TYPE, contract.Id, brand.Id);
        insert focusBrand1;

        //Create Listing/ Pouring
        listingPouring1 = EUR_CRM_DE_TestClassUtilityHelper.createContractListingPouringItem(EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_LISTING_POURING_RECORD_TYPE, contract.Id, brandQuality.Id, true, true);
        insert listingPouring1;

        //Create Contract Product Item
        productItem1 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity2.Id, brand);
        productItem2 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity1.Id, brandQuality);
        insert new List<EUR_CRM_Contract_Product_Item__c>{
                productItem1, productItem2
        };
    }

    //static testMethod void testMethod1(){
    //    EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();

    //    system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){

    //        test.startTest();
    //        dataInsert1();

    //        PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractPDF_Concept');
    //        Test.setCurrentPage(pageRef);

    //        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
    //        EUR_CRM_DE_ContractPDFControllerExt ctrl = new EUR_CRM_DE_ContractPDFControllerExt(standardController);

    //        EUR_CRM_Contract__c contractDetails = ctrl.retrieveContractDetails(contract.Id);
    //        contract = contractDetails;

    //        EUR_CRM_DE_ContractPDFControllerExt.ContractWrapper contractWrapper = new EUR_CRM_DE_ContractPDFControllerExt.ContractWrapper(contract);
    //        Integer size1 = contractWrapper.listingPouringListSize;
    //        Integer size2 = contractWrapper.listingListSize;
    //        Integer size3 = contractWrapper.pouringListSize;
    //        Integer size4 = contractWrapper.focusBrandListSize;

    //        ctrl.initContractContent(contract, contractWrapper);

    //        EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper contractContentWrapper1 = new EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper();
    //        EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper contractContentWrapper2 = new EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper(mechType1);
    //        List <EUR_CRM_Contract_Activity_Item__c> caList = new List<EUR_CRM_Contract_Activity_Item__c>();
    //        caList.add(contractActivity2);
    //        EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper contractContentWrapper3 = new EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper(mechType2, caList);
    //        Boolean ccAvailable1 = contractContentWrapper1.isAvailable;
    //        Boolean ccAvailable2 = contractContentWrapper2.isAvailable;
    //        Boolean ccAvailable3 = contractContentWrapper3.isAvailable;

    //        Decimal total1 = contractContentWrapper1.total;
    //        Decimal total2 = contractContentWrapper2.total;
    //        Decimal total3 = contractContentWrapper3.total;
    //        Decimal paTotal1 = contractContentWrapper1.prdActivitiesTotal;
    //        Decimal paTotal2 = contractContentWrapper2.prdActivitiesTotal;
    //        Decimal paTotal3 = contractContentWrapper3.prdActivitiesTotal;
    //        Decimal npaTotal1 = contractContentWrapper1.nonPRDActivitiesTotal;
    //        Set<EUR_CRM_Contract_Product_Item__c> npSet1 = contractContentWrapper1.nonPRDUniqueContractProductSet;
    //        Set<EUR_CRM_Contract_Product_Item__c> ucpSet1 = contractContentWrapper1.uniqueContractProductSet;

    //        EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper caWrapper1 = new EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper(contractActivity1);
    //        EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper caWrapper2 = new EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper(contractActivity2);

    //        system.assertNotEquals(accountEU, null);
    //        system.assertNotEquals(contract, null);
    //        system.assertNotEquals(mechType1, null);
    //        system.assertNotEquals(mechType2, null);

    //        test.stopTest();
    //    }
    //}

    static testMethod void testMethod2() {
        EUR_CRM_DE_TestClassUtilityHelper.initRegionalUser();

        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser) {

            System.debug('Before Data Insert');

            dataInsert1();
            System.debug('After Data Insert 1');

            test.startTest();
            dataInsert2();
            System.debug('After DataInsert 2');


            PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractPDF_Concept');
            Test.setCurrentPage(pageRef);

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            EUR_CRM_DE_ContractPDFControllerExt ctrl = new EUR_CRM_DE_ContractPDFControllerExt(standardController);

            EUR_CRM_Contract__c contractDetails = ctrl.retrieveContractDetails(contract.Id);
            contract = contractDetails;

            EUR_CRM_Contract_Payment_Plan__c contractPaymentPlan = [SELECT Id FROM EUR_CRM_Contract_Payment_Plan__c WHERE EUR_CRM_Contract__c = :contract.Id];

            EUR_CRM_DE_ContractPDFControllerExt.ContractWrapper contractWrapper = new EUR_CRM_DE_ContractPDFControllerExt.ContractWrapper(contract, contractPaymentPlan);
            EUR_CRM_Contract__c contractHeader = contractWrapper.contractHeader;
            Map<String, EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper> contractContentWrapperMap = contractWrapper.contractContentWrapperMap;
            List<EUR_CRM_Contract_Focus_Brand__c> focusBrandList = contractWrapper.focusBrandList;
            List<EUR_CRM_Contract_Listing_Pouring__c> listingPouringList = contractWrapper.listingPouringList;
            List<EUR_CRM_Contract_Listing_Pouring__c> listingList = contractWrapper.listingList;
            List<EUR_CRM_Contract_Listing_Pouring__c> pouringList = contractWrapper.pouringList;
            Integer size1 = contractWrapper.listingPouringListSize;
            Integer size2 = contractWrapper.listingListSize;
            Integer size3 = contractWrapper.pouringListSize;
            Integer size4 = contractWrapper.focusBrandListSize;
            String totalAmount = contractWrapper.totalAmount;
            String totalAmountWithoutNoInvoicing = contractWrapper.totalAmountWithoutNoInvoicing;

            System.debug('Checking Status 1');

            ctrl.initContractContent(contract, contractWrapper);

            EUR_CRM_DE_ContractPDFControllerExt.ContractWrapper contractWrapperObj = ctrl.contractWrapperObj;
            List<EUR_CRM_Contract_Product_Item__c> exclusivePouringRefundWKZ = ctrl.exclusivePouringRefundWKZ;
            List<EUR_CRM_Contract_Product_Item__c> nonExclusivePouringRefundWKZ = ctrl.nonExclusivePouringRefundWKZ;

            EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper contractContentWrapper1 = new EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper();
            EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper contractContentWrapper2 = new EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper(mechType1);
            List <EUR_CRM_Contract_Activity_Item__c> caList = new List<EUR_CRM_Contract_Activity_Item__c>();
            caList.add(contractActivity2);
            EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper contractContentWrapper3 = new EUR_CRM_DE_ContractPDFControllerExt.ContractContentWrapper(mechType2, caList);
            Boolean ccAvailable1 = contractContentWrapper1.isAvailable;
            Boolean ccAvailable2 = contractContentWrapper2.isAvailable;
            Boolean ccAvailable3 = contractContentWrapper3.isAvailable;

            Decimal total1 = contractContentWrapper1.total;
            Decimal total2 = contractContentWrapper2.total;
            Decimal total3 = contractContentWrapper3.total;
            Decimal paTotal1 = contractContentWrapper1.prdActivitiesTotal;
            Decimal paTotal2 = contractContentWrapper2.prdActivitiesTotal;
            Decimal paTotal3 = contractContentWrapper3.prdActivitiesTotal;
            Decimal npaTotal1 = contractContentWrapper1.nonPRDActivitiesTotal;
            Set<EUR_CRM_Contract_Product_Item__c> npSet1 = contractContentWrapper3.nonPRDUniqueContractProductSet;
            Set<EUR_CRM_Contract_Product_Item__c> ucpSet1 = contractContentWrapper3.uniqueContractProductSet;

            System.debug('Checking Status 2');

            EUR_CRM_Mechanic_Type__c mechanicType = contractContentWrapper1.mechanicType;
            Map<Id, EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper> contractActivityMap = contractContentWrapper1.contractActivityMap;
            Integer contractActivityCount = contractContentWrapper1.contractActivityCount;
            EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper singleContractActivity = contractContentWrapper1.singleContractActivity;
            List<EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper> prdActivities = contractContentWrapper1.prdActivities;
            List<EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper> nonPRDActivities = contractContentWrapper1.nonPRDActivities;
            Integer uniqueContractProductSetSize = contractContentWrapper1.uniqueContractProductSetSize;
            Set<EUR_CRM_Contract_Product_Item__c> uniqueExclusiveContractProductSet = contractContentWrapper3.uniqueExclusiveContractProductSet;
            Set<EUR_CRM_Contract_Product_Item__c> uniqueNonExclusiveContractProductSet = contractContentWrapper1.uniqueNonExclusiveContractProductSet;
            Set<EUR_CRM_Contract_Product_Item__c> allContractProducts = contractContentWrapper1.allContractProducts;
            Integer allContractProductsSize = contractContentWrapper1.allContractProductsSize;
            Integer sumAllBrandQualitiesSize = contractContentWrapper1.sumAllBrandQualitiesSize;
            Set<EUR_CRM_DE_ContractPDFControllerExt.ContractPaymentPlanPeriodWrapper> allContractPaymentPlanPeriods = contractContentWrapper3.allContractPaymentPlanPeriods;
            Integer allContractPaymentPlanpEriodSize = contractContentWrapper1.allContractPaymentPlanPeriodsSize;

            EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper caWrapper1 = new EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper(contractActivity1);
            EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper caWrapper2 = new EUR_CRM_DE_ContractPDFControllerExt.ContractActivityWrapper(contractActivity2);

            EUR_CRM_Contract_Activity_Item__c contractActivity = caWrapper1.contractActivity;
            Map<Id, EUR_CRM_Contract_Product_Item__c> contractProductMap = caWrapper1.contractProductMap;
            Set<EUR_CRM_Contract_Product_Item__c> allContractProductItems = caWrapper1.allContractProductItems;
            Integer contractProductMapSize = caWrapper1.contractProductMapSize;
            Set<EUR_CRM_Contract_Product_Item__c> exclusiveContractProducts = caWrapper1.exclusiveContractProducts;
            String paymentTerm = caWrapper1.paymentTerm;

            System.debug('Checking Status 3');


            /*EUR_CRM_DE_ContractPDFControllerExt.ContractProductWrapper contractProductWrapper1= new EUR_CRM_DE_ContractPDFControllerExt.ContractProductWrapper(productItem1);
            EUR_CRM_DE_ContractPDFControllerExt.ContractProductWrapper contractProductWrapper2 = new EUR_CRM_DE_ContractPDFControllerExt.ContractProductWrapper(productItem2);
            EUR_CRM_Contract_Product_Item__c contractProduct = contractProductWrapper1.contractProduct;
            Integer vol1 = contractProductWrapper1.totalVolume;
            Integer vol2 = contractProductWrapper2.totalVolume;*/

            system.assertNotEquals(accountEU, null);
            system.assertNotEquals(contract, null);
            system.assertNotEquals(mechType1, null);
            system.assertNotEquals(mechType2, null);

            List<EUR_CRM_Contract_Payment_Plan_Period__c> contractPaymentPlanPeriod = [
                    SELECT EUR_CRM_List_of_Brand__c,
                            EUR_CRM_Description__c,
                            EUR_CRM_Payment_Period_Start_Date__c,
                            EUR_CRM_Payment_Period_End_Date__c,
                            EUR_CRM_CPPP_Rate__c,
                            EUR_CRM_CPPP_Unit__c,
                            EUR_CRM_CPPP_Volume__c,
                            EUR_CRM_CPPP_Amount__c,
                            EUR_CRM_CPPP_Payment_Term__c,
                            EUR_CRM_CPPP_Earliest_Date_of_Invoice__c,
                            EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Name__c
                    FROM EUR_CRM_Contract_Payment_Plan_Period__c
                    LIMIT 1
            ];
            if (contractPaymentPlanPeriod.size() > 0) {
                EUR_CRM_DE_ContractPDFControllerExt.ContractPaymentPlanPeriodWrapper cpppWrapper = new EUR_CRM_DE_ContractPDFControllerExt.ContractPaymentPlanPeriodWrapper(contractPaymentPlanPeriod[0]);
                EUR_CRM_DE_ContractPDFControllerExt.ContractPaymentPlanPeriodWrapper cpppWrapper2 = new EUR_CRM_DE_ContractPDFControllerExt.ContractPaymentPlanPeriodWrapper(contractPaymentPlanPeriod[0], 'some mechanic type');
                EUR_CRM_DE_ContractPDFControllerExt.ContractProductWrapper cpWrapper = new EUR_CRM_DE_ContractPDFControllerExt.ContractProductWrapper('Ballantines', 'Liter', 100);


                ctrl.retrieveContractProductItems(contract);
                String a = contractContentWrapper1.prdActivitiesTotalStr;
                String b = contractContentWrapper1.nonPRDActivitiesTotalStr;
                set<EUR_CRM_Contract_Product_Item__c> cpSet = contractContentWrapper3.PRDUniqueContractProductSet;
                String c = contractContentWrapper1.totalStr;
                String dynamicFormatString = ctrl.getDynamicFormatString();
            }

            System.assertEquals(0, contractContentWrapper1.sumAllBrandSize);
            System.assertEquals(0, contractContentWrapper1.sumAllBrandQualitiesSize);
            System.assertEquals(0, contractContentWrapper1.allContractProductsSize);

            test.stopTest();
        }
    }
}