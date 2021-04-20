/**
 * Created by illia on 25.07.18.
 */

@isTest(isParallel=true)
private class EUR_CRM_NL_ROIEvalControllerTest {

    private static final String BAR_PRESENTATION = 'Bar Presentation';
    private static final String BRAND_ACTIVATION = 'Brand Activation';
    private static final String DRINKS_MENU = 'Drinks Menu';
    private static final String EXCLUSIVITY = 'Exclusivity';
    private static final String HOUSE_POURING = 'House Pouring';
    private static final String LISTING = 'Listing';
    private static final String LUMPSUM = 'Lumpsum';
    private static final String MARKETING_TAILORMADE = 'Marketing Tailormade';
    private static final String OTHER_ACTIVITIES = 'Other Activities';
    private static final String POS = 'POS';
    private static final String POURING_REFUND = 'Pouring Refund';
    private static final String TRAININGS = 'Trainings';
    private static PageReference pageRef = Page.EUR_CRM_NL_ROIEvaluationPage;

    @testSetup
    private static void setup() {
        EUR_CRM_Contract__c testContract = createContract(createAccount().Id);
    }


    @isTest
    static void testEUR_CRM_NL_ROIEvalControllerWithNoParameters() {
        Test.startTest();
        EUR_CRM_Contract__c testContract = [Select Id From EUR_CRM_Contract__c LIMIT 1];
        pageRef.getParameters().put('id',String.valueOf(testContract.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testContract);
        EUR_CRM_NL_ROIEvalController roiEvalController = new EUR_CRM_NL_ROIEvalController();
        Test.stopTest();
        System.assertEquals(testContract.Id, pageRef.getParameters().get('Id'));
    }



    @isTest
    static void testEUR_CRM_NL_ROIEvalControllerWithParameters(){
        Test.startTest();
        EUR_CRM_Contract__c testContract = [Select Id From EUR_CRM_Contract__c LIMIT 1];
        createRecordsOfObjects(testContract.Id);
        
        pageRef.getParameters().put('id',String.valueOf(testContract.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testContract);
        EUR_CRM_NL_ROIEvalController roiEvalController = new EUR_CRM_NL_ROIEvalController(standardController);
        Test.stopTest();
        System.assertEquals(testContract.Id, pageRef.getParameters().get('Id'));

        System.assertEquals(new List<Decimal>{10.00, 15.00, 15.00, 10.00, 10.00}, roiEvalController.mechTypeWrapperMap.get('Pouring Refund')[0].pouringRefundNetSales);
        System.assertEquals(new List<Decimal>{5.00, 10.00, 10.00, 7.50, 7.50}, roiEvalController.mechTypeWrapperMap.get('Pouring Refund')[0].pouringRefundCM);
        System.assertEquals(new List<Decimal>{1000.0000, 1275.0000, 53655.0000, 146950.0000, 15960.0000}, roiEvalController.mechTypeWrapperMap.get('Pouring Refund')[0].pouringRefundTtlNetSales);
        System.assertEquals(new List<Decimal>{500.0000, 850.0000, 35770.0000, 110212.5000, 11970.0000}, roiEvalController.mechTypeWrapperMap.get('Pouring Refund')[0].pouringRefundTtlCM);

        System.assertEquals(218840.00,roiEvalController.GtNetSales);
        System.assertEquals(1800,roiEvalController.GtOtherInvest);
        System.assertEquals(159302.5,roiEvalController.GtTotalCM);
        System.assertEquals(154307.68,roiEvalController.GtProfit);
        System.assertEquals(152607.6800,roiEvalController.GtProfitIclMktInv);
        System.assertEquals(70,Math.round(roiEvalController.PercentProfitNSInclInv));
    }

    static void createRecordsOfObjects(Id contractId){
        Map<String, EUR_CRM_Contract_Activity_Item__c> testContractActivityItemsMap = createContractActivityItemsMap(contractId);
        EUR_CRM_Category__c testCategory = createCategory('TestCategory');


        EUR_CRM_Brand__c testBrandFirst = createBrand(testCategory.Id, 'TestBrandFirst');
        EUR_CRM_Quality__c premiumBrandQualityFirst = createBrandQuality(testBrandFirst.Id, testBrandFirst.Name, 'Premium', 7.50, 10.00);
        EUR_CRM_Quality__c superPremiumBrandQualityFirst = createBrandQuality(testBrandFirst.Id, testBrandFirst.Name, 'Super Premium', 10.00, 15.00);
        EUR_CRM_Quality__c noneSubCategoryBrandQualityFirst = createBrandQuality(testBrandFirst.Id, testBrandFirst.Name, null, 5.00, 10.00);

        /*********************************
         *Create products for ContractActivityItem with MechanicType = Listing
        ********************************/

        List<EUR_CRM_Contract_Product_Item__c> listingProductItems = new List<EUR_CRM_Contract_Product_Item__c>{
                createProductItem(testContractActivityItemsMap.get(LISTING).Id, 1596, premiumBrandQualityFirst.Id),
                createProductItem(testContractActivityItemsMap.get(LISTING).Id, 14695, premiumBrandQualityFirst.Id),
                createProductItem(testContractActivityItemsMap.get(LISTING).Id, 3577, superPremiumBrandQualityFirst.Id),
                createProductItem(testContractActivityItemsMap.get(LISTING).Id, 85, superPremiumBrandQualityFirst.Id),
                createProductItem(testContractActivityItemsMap.get(LISTING).Id, 100, noneSubCategoryBrandQualityFirst.Id)

        };
        insert listingProductItems;

        /*********************************
         *Create products for ContractActivityItem with MechanicType = Marketing Tailormade, Lumpsum,
        ********************************/

        List<EUR_CRM_Contract_Product_Item__c> otherProductItems = new List<EUR_CRM_Contract_Product_Item__c>{
                createProductItem(testContractActivityItemsMap.get(MARKETING_TAILORMADE).Id, 10, premiumBrandQualityFirst.Id),
                createProductItem(testContractActivityItemsMap.get(TRAININGS).Id, 20, premiumBrandQualityFirst.Id),
                createProductItem(testContractActivityItemsMap.get(BAR_PRESENTATION).Id, 30, superPremiumBrandQualityFirst.Id),
                createProductItem(testContractActivityItemsMap.get(LUMPSUM).Id, 40, superPremiumBrandQualityFirst.Id),
                createProductItem(testContractActivityItemsMap.get(DRINKS_MENU).Id, 50, noneSubCategoryBrandQualityFirst.Id)

        };
        insert otherProductItems;

        /*********************************
         *Create products for ContractActivityItem with MechanicType = Pouring Refund
        ********************************/
        List<EUR_CRM_Contract_Rebate__c> pouringRefundContractRebates = new List<EUR_CRM_Contract_Rebate__c>{
                createContractRebate(testContractActivityItemsMap.get(POURING_REFUND).Id, 'Premium', 0.26, 0.00, false),
                createContractRebate(testContractActivityItemsMap.get(POURING_REFUND).Id, 'Super Premium', 0.08, 0.10, true)
        };
        insert pouringRefundContractRebates;

    }


    static EUR_CRM_Account__c createAccount() {
        EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c();
        Id accountRecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByName().get('EUR NL Wholesaler').getRecordTypeId();
        newAccount.RecordTypeId = accountRecordTypeId;
        newAccount.Name = 'TestAccount';
        newAccount.EUR_CRM_Postal_Code__c = '00000';
        newAccount.EUR_CRM_City__c = 'testCity';
        newAccount.EUR_CRM_Street__c = 'testStreet';
        newAccount.EUR_CRM_Delivery_Type__c = 'Indirect';
        newAccount.EUR_CRM_Status__c = 'Active';

        insert newAccount;
        return newAccount;
    }

    /****
    * Create new Contract (EU)
    * *****/
    static EUR_CRM_Contract__c createContract(Id accountId) {
        Schema.RecordTypeInfo contractRecordTypeId=  Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByName().get('EUR NL Independant Contract');
        EUR_CRM_Contract__c newContract = new EUR_CRM_Contract__c();
        newContract.EUR_CRM_Account__c = accountId;
        newContract.EUR_CRM_Start_Date__c = Date.newInstance(2018, 1, 1);
        newContract.EUR_CRM_End_Date__c = Date.newInstance(2018, 6, 1);
        newContract.EUR_CRM_Active__c = true;
        newContract.RecordTypeId = contractRecordTypeId.getRecordTypeId();
        newContract.EUR_CRM_Status__c = 'Activated';

        insert newContract;
        return newContract;
    }


    /**
    * Create new Contract Activity Item (EU)
    * */
    static Map<String, EUR_CRM_Contract_Activity_Item__c> createContractActivityItemsMap(Id contractId) {
        Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypes = createMechanicTypes();
        Map<String, EUR_CRM_Contract_Activity_Item__c> newContractActivityItemsMap = new Map<String, EUR_CRM_Contract_Activity_Item__c>();
        EUR_CRM_Contract_Activity_Item__c newContractActivityItem;
        for (EUR_CRM_Mechanic_Type__c mechType : mechanicTypes.values()) {
            newContractActivityItem = new EUR_CRM_Contract_Activity_Item__c();
            newContractActivityItem.EUR_CRM_Contract__c = contractId;
            newContractActivityItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
            newContractActivityItem.EUR_CRM_Amount_Year_1__c = 100;
            newContractActivityItem.EUR_CRM_Amount__c = 200;
            newContractActivityItemsMap.put(mechType.Name, newContractActivityItem);
        }
        insert newContractActivityItemsMap.values();

        return newContractActivityItemsMap;
    }

    /** Create new Contract Rebate for Contract Activity Item
    *
    * */
    static EUR_CRM_Contract_Rebate__c createContractRebate(Id contractActivityItemId, String premiumSuperPremium, Decimal performanceRebate, Decimal conditionalRebate,
            Boolean giveConditionalRebate) {
        EUR_CRM_Contract_Rebate__c newContractRebate = new EUR_CRM_Contract_Rebate__c();
        newContractRebate.EUR_CRM_Contract_Activity_Item_EU__c = contractActivityItemId;
        newContractRebate.EUR_CRM_Product_Sub_Category__c = premiumSuperPremium;
        newContractRebate.EUR_CRM_Performance_Rebate__c = performanceRebate;
        newContractRebate.EUR_CRM_Conditional_Rebate__c = conditionalRebate;
        newContractRebate.EUR_CRM_Give_Conditional_Rebate__c = giveConditionalRebate;

        return newContractRebate;
    }

    /**
    * Create new Contract Product Item for Contract Activity Item
    * */
    static EUR_CRM_Contract_Product_Item__c createProductItem(Id contractActivityItemId, Integer volumeLt, Id brandQualityId) {
        EUR_CRM_Contract_Product_Item__c newProductItem = new EUR_CRM_Contract_Product_Item__c();
        newProductItem.EUR_CRM_Contract_Activity_Item__c = contractActivityItemId;
        newProductItem.EUR_CRM_Volume_lt__c = volumeLt;
        newProductItem.EUR_CRM_Brand_Quality__c = brandQualityId;
//        insert newProductItem;
        return newProductItem;
    }


    /**
    * Create new Brand Quality for Contract Product Item
    * */
    static EUR_CRM_Quality__c createBrandQuality(Id brandId, String brandQualityName, String premiumSuperPremium, Decimal contributiveMargin, Decimal netSales) {
        EUR_CRM_Quality__c newBrandQuality = new EUR_CRM_Quality__c();
        newBrandQuality.Name = brandQualityName;
        newBrandQuality.EUR_CRM_Brand__c = brandId;
        newBrandQuality.EUR_CRM_Sub_Category__c = premiumSuperPremium;
        newBrandQuality.EUR_CRM_Contributive_Margin_BQ__c = contributiveMargin;
        newBrandQuality.EUR_CMR_Net_Sales__c = netSales;
        insert newBrandQuality;
        return newBrandQuality;

    }

    /**
    * Create new Brand(EU) for Brand Quality
    * */
    static EUR_CRM_Brand__c createBrand(Id categoryId, String brandName) {
        EUR_CRM_Brand__c newBrand = new EUR_CRM_Brand__c();
        newBrand.Name = brandName;
        newBrand.EUR_CRM_Category__c = categoryId;
        insert newBrand;
        return newBrand;
    }


    /**
    * Create new Category (EU) for Brand
    * */
    static EUR_CRM_Category__c createCategory(String categoryName) {
        EUR_CRM_Category__c newCategory = new EUR_CRM_Category__c(Name = categoryName);
        insert newCategory;
        return newCategory;
    }

    /**
    * Create Mechanic Types for Contract Activity Items
    * */
    static Map<String, EUR_CRM_Mechanic_Type__c> createMechanicTypes() {
        Map<String, EUR_CRM_Mechanic_Type__c> newMechanicTypesMap = new Map<String, EUR_CRM_Mechanic_Type__c>();
        List<String> mechanicTypeNames = new List<String>{
                EUR_CRM_NL_ROIEvalControllerTest.BAR_PRESENTATION,
                EUR_CRM_NL_ROIEvalControllerTest.BRAND_ACTIVATION,
                EUR_CRM_NL_ROIEvalControllerTest.DRINKS_MENU,
                EUR_CRM_NL_ROIEvalControllerTest.EXCLUSIVITY,
                EUR_CRM_NL_ROIEvalControllerTest.HOUSE_POURING,
                EUR_CRM_NL_ROIEvalControllerTest.LUMPSUM,
                EUR_CRM_NL_ROIEvalControllerTest.MARKETING_TAILORMADE,
                EUR_CRM_NL_ROIEvalControllerTest.OTHER_ACTIVITIES,
                EUR_CRM_NL_ROIEvalControllerTest.TRAININGS,
                EUR_CRM_NL_ROIEvalControllerTest.POS,
                EUR_CRM_NL_ROIEvalControllerTest.LISTING,
                EUR_CRM_NL_ROIEvalControllerTest.POURING_REFUND
        };
        for (String mechTypeName : mechanicTypeNames) {
            Id mechTypeRecordTypeId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c.getRecordTypeInfosByName().get('EUR NL Mechanic Type').getRecordTypeId();
            EUR_CRM_Mechanic_Type__c newMechanicType = new EUR_CRM_Mechanic_Type__c(
                    Name = mechTypeName,
                    RecordTypeId = mechTypeRecordTypeId
            );
            newMechanicTypesMap.put(mechTypeName, newMechanicType);
        }
        insert newMechanicTypesMap.values();
        return newMechanicTypesMap;
    }
}