@isTest
public class EUR_CRM_TestObjPromoPageController {

    private final static List<String> objPromoRecordTypeList = new List<String> {
        'EUR_DE_Off_Trade_Sales_Drive',
        'EUR_DE_Off_Trade_Leaflet_Campaign',
        'EUR_DE_Off_Trade_Trade_Fair',
        'EUR_DE_Off_Trade_Secondary_Placement_Carton'
    };

    private final static List<String> actionListTemplateExternalIdList = new List<String> {
        'DE_OFF_ALT_Sales_Drive',
        'DE_OFF_ALT_Leaflet_Campaign',
        'DE_OFF_ALT_Trade_Fair',
        'DE_OFF_ALT_2nd_PL_Carton'
    };

    private final static List<String> opTargetRecordTypeList = new List<String> {
        'EUR_DE_Regional_Listing_Target',
        'EUR_DE_Sales_Agency_Managed_Target',
        'EUR_DE_SR_Volume_Target'
    };

    @TestSetup
    public static void setupTestData() {
        EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('Testing', UserInfo.getUserId(), 'EUR_DE_Region');
        EUR_CRM_Territory__c territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('Testing', UserInfo.getUserId(), region.Id, 'EUR_DE_Territory');
        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('Testing', '0000', territory.Id, 'EUR_DE_On_Trade_Postal_Code_Territory_Mapping');

        EUR_CRM_Customer_Taxonomy__c taxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('Testing', UserInfo.getUserId(), 'EUR_DE_Customer_Taxonomy');
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = '0000',
            recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_DE_ON_Consumers'),
            name = 'Testing',
            EUR_CRM_Status_of_Customer__c = 'Active',
            EUR_JB_Customer_Taxonomy__c = taxonomy.Id );

        EUR_CRM_ObjPromo_OnTrade_Variation__c objPromoOnTradeVariation = EUR_CRM_DE_TestClassUtilityHelper.createPromoVariation(1, 'EUR_DE_ObjPromo_Promo_Variation', 'Testing')[0];
        insert objPromoOnTradeVariation;
    }

    public static testmethod void testPROSObjPromoPageController() {
        EUR_CRM_ObjPromo_OnTrade_Variation__c objPromoOnTradeVariation = [SELECT Id FROM EUR_CRM_ObjPromo_OnTrade_Variation__c];
        Id actionListTemplateRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', 'EUR_DE_OP_Action_List_Template');

        EUR_CRM_OP_Action_List_Template__c actionListTemplate = new EUR_CRM_OP_Action_List_Template__c();
        actionListTemplate.RecordTypeId = actionListTemplateRecordTypeId;
        actionListTemplate.Name = 'Testing';
        actionListTemplate.EUR_CRM_External_ID__c = 'DE_ON_ALT_ON_PROS_TMKT_Promos';
        insert actionListTemplate;

        EUR_CRM_ObjPromo__c objPromo1 = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(1, '', 'Testing')[0];
        objPromo1.RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo__c', 'EUR_DE_OnTrade_PROS_TMKT_Promo');
        objPromo1.EUR_CRM_OP_Action_List_Template__c = actionListTemplate.Id;
        objPromo1.EUR_CRM_PROS_Group_Outlet__c = 'Restaurant';
        objPromo1.EUR_CRM_PROS_Image_Level__c = 'Iconic';
        objPromo1.EUR_CRM_ObjPromo_OnTrade_Variation__c = objPromoOnTradeVariation.Id;
        objPromo1.EUR_CRM_Region__c = 'On Trade Prestige Region';
        objPromo1.EUR_CRM_Territory__c = 'On Trade Territory 9';

        EUR_CRM_ObjPromo__c objPromo2 = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(1, '', 'Testing')[0];
        objPromo2.RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo__c', 'EUR_DE_OnTrade_PROS_TMKT_Promo');
        objPromo2.EUR_CRM_OP_Action_List_Template__c = actionListTemplate.Id;

        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
        objPromoList.add(objPromo1);
        objPromoList.add(objPromo2);
        insert objPromoList;

        Test.startTest();

        EUR_CRM_ObjPromo__c objPromoTest= [select Id,EUR_CRM_OP_Action_List_Template__c,
            EUR_CRM_PROS_Group_Outlet__c,EUR_CRM_PROS_Image_Level__c,
            EUR_CRM_ObjPromo_OnTrade_Variation__c,EUR_CRM_Region__c,
            EUR_CRM_Territory__c, recordType.DeveloperName,EUR_CRM_Status__c,OwnerId
        from EUR_CRM_ObjPromo__c where EUR_CRM_PROS_Group_Outlet__c = 'Restaurant' limit 1];

        EUR_CRM_ObjPromo__c objPromoTest2= [select Id,EUR_CRM_OP_Action_List_Template__c,
            EUR_CRM_PROS_Group_Outlet__c,EUR_CRM_PROS_Image_Level__c,
            EUR_CRM_ObjPromo_OnTrade_Variation__c,EUR_CRM_Region__c,EUR_CRM_Status__c,
            EUR_CRM_Territory__c, recordType.DeveloperName, OwnerId
        from EUR_CRM_ObjPromo__c where EUR_CRM_PROS_Group_Outlet__c = null limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController(objPromoTest);
        EUR_CRM_ObjectivePromoPageController controller = new EUR_CRM_ObjectivePromoPageController(stdController);
        controller.verifyMissingTargetInit();
        controller.getVariationDetails();
        controller.getActions();
        controller.redirect();
        controller.editTargets();
        controller.saveTarget();
        controller.saveObjPromoDetail();
        controller.cancel();
        controller.hasEditAccess();
        controller.initMixedObjTargets();

        ApexPages.StandardController stdController2 = new ApexPages.StandardController(objPromoTest2);
        EUR_CRM_ObjectivePromoPageController controller2 = new EUR_CRM_ObjectivePromoPageController(stdController2);
        controller2.verifyMissingTargetInit();
        EUR_CRM_ObjectivePromoPageController.ProductUser testing = new EUR_CRM_ObjectivePromoPageController.ProductUser();
        User u = testing.targetOwner;
        EUR_CRM_SKU__c sku = testing.sku;
        EUR_CRM_Size__c size = testing.bqs;
        EUR_CRM_ObjectivePromoPageController.euAccountsWrapper wrapper = new EUR_CRM_ObjectivePromoPageController.euAccountsWrapper(null, false);

        Test.stopTest();
    }

    public static testmethod void testObjPromoPageController() {
        EUR_CRM_Customer_Taxonomy__c taxonomy = [SELECT Id FROM EUR_CRM_Customer_Taxonomy__c];

        Id actionListTemplateRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', 'EUR_DE_OP_Action_List_Template');
        List<EUR_CRM_OP_Action_List_Template__c> actionListTemplateList = new List<EUR_CRM_OP_Action_List_Template__c>();
        for(Integer i = 0 ; i < 4; i++) {
            EUR_CRM_OP_Action_List_Template__c actionListTemplate = new EUR_CRM_OP_Action_List_Template__c();
            actionListTemplate.RecordTypeId = actionListTemplateRecordTypeId;
            actionListTemplate.Name = 'Testing' + i;
            actionListTemplate.EUR_CRM_External_ID__c = actionListTemplateExternalIdList.get(i);
            actionListTemplateList.add(actionListTemplate);
        }
        insert actionListTemplateList;

        List<EUR_CRM_ObjPromo__c> objPromoList = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(4, '', 'Testing');
        for(Integer i = 0 ; i < 4; i++) {
            objPromoList.get(i).RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo__c', objPromoRecordTypeList.get(i));
            objPromoList.get(i).EUR_CRM_OP_Action_List_Template__c = actionListTemplateList.get(i).Id;
        }

        insert objPromoList;

        EUR_CRM_ObjPromo_Target__c objectiveOPTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'EUR_DE_Objective_Volume_Target', objPromoList.get(3).Id, null)[0];
        insert objectiveOPTarget;

        Test.startTest();

        objPromoList = [SELECT Id, RecordTypeId, RecordType.DeveloperName, EUR_CRM_Status__c, EUR_CRM_ObjPromo_OnTrade_Variation__c, OwnerId FROM EUR_CRM_ObjPromo__c];

        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> customerTaxonomyMappingList = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
        for(Integer i = 0 ; i < 4 ; i++) {
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMapping = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            customerTaxonomyMapping.EUR_CRM_Customer_Taxonomy__c = taxonomy.Id;
            customerTaxonomyMapping.EUR_CRM_ObjPromo__c = objPromoList.get(i).Id;
            customerTaxonomyMappingList.add(customerTaxonomyMapping);
        }
        insert customerTaxonomyMappingList;

        for(EUR_CRM_ObjPromo__c objPromo : objPromoList) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(objPromo);
            EUR_CRM_ObjectivePromoPageController controller = new EUR_CRM_ObjectivePromoPageController(stdController);
            controller.verifyMissingTargetInit();
        }
        Test.stopTest();

    }

//    @IsTest
//    private static void superTest() {
//        Test.startTest();
//        new EUR_CRM_ObjectivePromoPageController().superMethod();
//        Test.stopTest();
//    }

}