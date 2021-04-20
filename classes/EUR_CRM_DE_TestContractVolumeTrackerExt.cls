/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_ContractVolumeTrackerExt Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_DE_TestContractVolumeTrackerExt {
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

    private static EUR_CRM_Contract_Product_Item__c productItem1;
    private static EUR_CRM_Contract_Product_Item__c productItem2;

    private static EUR_CRM_GB_Volume_Tracker__c volumeTracker;
    private static EUR_CRM_GB_Volume_Tracker_Line_Item__c volumeTrackerItem;

    static User regionalUser;
    static User salesRepUser;

    public static void dataInsert() {
        EUR_CRM_DE_TestClassUtilityHelper.regionalUser = regionalUser;
        EUR_CRM_DE_TestClassUtilityHelper.salesRepUser = salesRepUser;
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
    }

    public static void dataInsert1() {
        //Create account
        /*accountEU = EUR_CRM_DE_TestClassUtilityHelper.createEUAccountWithCTaxonomy('TEST_ACCOUNT1', '12345', 
                                        EUR_CRM_DE_TestClassUtilityHelper.DE_EUACCOUNT_ON_CONSUMERS_RECORD_TYPE, 
                                        EUR_CRM_DE_TestClassUtilityHelper.DE_POSTAL_CODE_MAPPING_ON_TRADE_RECORD_TYPE);
        */

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

        //Create Mechanic Type
        mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName1)[0];
        mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType1.EUR_CRM_Has_Lump_Sum__c = false;
        mechType1.EUR_CRM_Has_Per_BQ__c = true;
        mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c = false;
        mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
        mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = false;
        mechType1.EUR_CRM_For_Compliance_Check__c = true;

        //Create Mechanic Type
        mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, mechanicTypeName2)[0];
        mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
        mechType2.EUR_CRM_Has_Lump_Sum__c = true;
        mechType2.EUR_CRM_Has_Per_BQ__c = true;
        mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c = false;
        mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
        mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
        mechType2.EUR_CRM_For_Compliance_Check__c = true;
        insert new List<EUR_CRM_Mechanic_Type__c>{
                mechType1, mechType2
        };

        //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
        insert contract;

        //Create Contract Activity1
        contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);

        //Create Contract Activity 2
        contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
        contractActivity2.EUR_CRM_Name__c = 'Test';
        insert new List<EUR_CRM_Contract_Activity_Item__c>{
                contractActivity1, contractActivity2
        };

        //Create Contract Product Item
        productItem1 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity2.Id, brand);
        productItem2 = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity1.Id, brandQuality);
        insert new List<EUR_CRM_Contract_Product_Item__c>{
                productItem1, productItem2
        };

        volumeTracker = EUR_CRM_TestClassUtilityHelper.createVolumeTracker(1, EUR_CRM_DE_TestClassUtilityHelper.DE_VOLUME_TRACKER_RECORD_TYPE, contract.Id)[0];
        insert volumeTracker;
        system.assertNotEquals(volumeTracker, null);

        volumeTrackerItem = EUR_CRM_TestClassUtilityHelper.createVolumeTrackerItem(1, volumeTracker.Id)[0];
        //volumeTrackerItem.EUR_CRM_Brand__c = brand.Id;
        //volumeTrackerItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        volumeTrackerItem.EUR_CRM_Initial_Contract_Volume__c = 2;
        insert volumeTrackerItem;
        system.assertNotEquals(volumeTrackerItem, null);
    }

    static testMethod void testMethod1() {
//        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        createUser();
		System.debug('### SOQL Limits 1:'+Limits.getQueries());
        system.runAs(regionalUser) {
            dataInsert();
			System.debug('### SOQL Limits 2:'+Limits.getQueries());
            Test.startTest();

            dataInsert1();
			System.debug('### SOQL Limits 3:'+Limits.getQueries());

            PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractVolTrackerPage');
            Test.setCurrentPage(pageRef);

            volumeTrackerItem.EUR_CRM_Brand_Quality__c = null;
            volumeTrackerItem.EUR_CRM_Brand__c = null;

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            EUR_CRM_DE_ContractVolumeTrackerExt ctrl = new EUR_CRM_DE_ContractVolumeTrackerExt(standardController);

            Test.stopTest();
        }

    }

    static testMethod void testMethod2() {
//        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        createUser();
        system.runAs(regionalUser) {
            dataInsert();

            Test.startTest();

            dataInsert1();

            volumeTrackerItem.EUR_CRM_Brand_Quality__c = null;
            update volumeTrackerItem;

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractVolTrackerPage');
            pageRef.getParameters().put('id', contract.id);
            pageRef.getParameters().put('IS_QUICK_SAVE', 'true');
            Test.setCurrentPage(pageRef);

            EUR_CRM_DE_ContractVolumeTrackerExt ctrl = new EUR_CRM_DE_ContractVolumeTrackerExt(standardController);

            ctrl.saveVolTracker();

            test.stopTest();
        }
    }

    static testMethod void testMethod3() {
//        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        createUser();
        system.runAs(regionalUser) {

            dataInsert();

            Test.startTest();

            dataInsert1();

            volumeTrackerItem.EUR_CRM_Brand_Quality__c = null;
            update volumeTrackerItem;

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(contract);
            PageReference pageRef = new PageReference('apex/EUR_CRM_DE_ContractVolTrackerPage');
            pageRef.getParameters().put('id', contract.id);
            pageRef.getParameters().put('IS_QUICK_SAVE', 'false');
            Test.setCurrentPage(pageRef);

            EUR_CRM_DE_ContractVolumeTrackerExt ctrl = new EUR_CRM_DE_ContractVolumeTrackerExt(standardController);

            ctrl.saveVolTracker();

            test.stopTest();
        }
    }
    static void createUser() {
        regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.REGIONAL_ON_TRADE_MANAGER_ROLE, 'testdezxc5@testemail.com', 'testdezxc5@testemail.com', 'testdezxc5');
        salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.SR_ON_TRADE_ROLE,'testdezxc6@testemail.com', 'testdezxc6@testemail.com', 'testdezxc6');
    }

}