/**
Author/Company:     IP Converge Data Services,Inc.
Description:        Test class for EUR_CRM_TestClassUtilityHelper
History:            17.JUN.2014        IPC     Created
 */
@isTest (SeeAllData=true)
private class EUR_CRM_TestClassUtilityHelper_Test {

    static testMethod void testUtil1() {
        test.startTest();
            EUR_CRM_TestClassUtilityHelper util = new EUR_CRM_TestClassUtilityHelper();
            
            EUR_CRM_TestClassUtilityHelper.createUser('System Administrator');
            EUR_CRM_TestClassUtilityHelper.createAccountsEU(5, 'GB FS Indirect');
            EUR_CRM_TestClassUtilityHelper.createAccounts(1, 'On Trade');
            EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'LT Image Level Criteria');
            EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(2, 'Yes/No', null);
            EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Integer Input', null);
            EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR LT Group Outlet', '', null, null);
            EUR_CRM_TestClassUtilityHelper.createOutletType(1, 'EUR LT Outlet Type', '', null);
            EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'LT Image Level', '', null, 'Nightclub');
            EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1, null, null);
            EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1, null, null, 100);
            EUR_CRM_TestClassUtilityHelper.createvolumePotential(1, 'LT Volume Potential', '', null, 'Medium');
            EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1, null, null);
            EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1, null, null, 100);
            EUR_CRM_TestClassUtilityHelper.createServicePack(1, 'EUR_PRT_Service_Pack', 'Restaurant', 'Iconic');
            EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', '', null, null, null, null, null, null);
            EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', '', null, null);
            EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, '', null, null);
            EUR_CRM_TestClassUtilityHelper.createRouteTemplate(1, 'EUR_LV_Route_Template', '');
            EUR_CRM_TestClassUtilityHelper.createRouteTemplateItem(1, null);
            EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1, 'CZ Visit Frequency');
            EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR LV Direct Account Visit Event', null, null, DateTime.now(), DateTime.now().addDays(14));
            EUR_CRM_TestClassUtilityHelper.createRouteTempDay(1, null);
            EUR_CRM_TestClassUtilityHelper.createRegion(1, '', null);
            EUR_CRM_TestClassUtilityHelper.createTerritory(1, '', null, null);
            EUR_CRM_TestClassUtilityHelper.createTerritoryMapping(1, '', null);
            EUR_CRM_TestClassUtilityHelper.createContracts(1, 'GB Contract', null, date.today(), date.today().addDays(20));
            EUR_CRM_TestClassUtilityHelper.createMechType(1, 'GB Mechanic Type', 'Cocktail');
            EUR_CRM_TestClassUtilityHelper.createContactLineItem(1, 'GB Contract Line Item', null);
            EUR_CRM_TestClassUtilityHelper.createMechanic(1, 'GB Mechanic', 'Cocktail', null);
            EUR_CRM_TestClassUtilityHelper.createContractMechanic(1, 'GB Contract Mechanic', null);
            EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, 'GB Wine/Spirits', 'TEST-0001', 'SPIRITS');
            EUR_CRM_TestClassUtilityHelper.createCategory(1, 'GB Category', 'TEST-0001', null);
            EUR_CRM_TestClassUtilityHelper.createBrand(1, 'GB Brand', 'VODKA', 'TEST-0001', null);
            EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'GB Quality', 'Cocktail', 'TEST-0001', null);
            EUR_CRM_TestClassUtilityHelper.createStockDealMech(1, null, 'TEST-0001');
            EUR_CRM_TestClassUtilityHelper.createVolumeTracker(1, 'EUR GB Volume Tracker', null);
            EUR_CRM_TestClassUtilityHelper.createVolumeTrackerItem(1, null);
            EUR_CRM_TestClassUtilityHelper.createTemplate(1, 'GB Template', 'template name');
            EUR_CRM_TestClassUtilityHelper.createTemplateCriteria(1, 'JB Template Criteria', null);
            EUR_CRM_TestClassUtilityHelper.createStoreAudit(1, 'GB Store Audit', null);
            EUR_CRM_TestClassUtilityHelper.createStoreAuditItem(1, 'GB FS Store Audit', null);
        test.stopTest();
    }
}