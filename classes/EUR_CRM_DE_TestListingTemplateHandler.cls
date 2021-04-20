/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_ListingTemplateHandler Class.
  @Author:      IPC
  @History:     SEPT.26.2014 - Created
*/
@isTest
private with sharing class EUR_CRM_DE_TestListingTemplateHandler {
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Customer_Taxonomy__c custTaxonomyOff;
    private static User accUser ;

    private static final String ACCOUNT_DE_OFF_TRADE_RETAIL_RT = 'EUR_DE_Off_Trade_Retail';
    private static final String ACCOUNT_DE_ON_GASTRONOMY_RT = 'EUR_DE_On_Trade_Gastronomy';

    private static final String LISTING_TEMPLATE_DE_OFF_TRADE_RT = 'EUR_DE_OFF_Trade_Template';
    private static final String LISTING_TEMPLATE_DE_ON_TRADE_RT = 'EUR_DE_ON_TRADE_Template';

    private static final String LISTING_TEMPLATE_CRITERIA_DE_RT = 'EUR_CRM_DE_Template_Criteria';

    private static final String CUSTOMER_TAXONOMY_DE_RT = 'EUR_DE_Customer_Taxonomy';

    private static final String POSTAL_CODE_RT = 'EUR_DE_Postal_Code_City_Mapping';
    private static final String TERRITORY_DE_RT = 'EUR_DE_Territory';
    private static final String REGION_DE_RT = 'EUR_DE_Region';
    private static final String OFF_TRADE = 'OFF TRADE';
    private static final String ON_TRADE = 'ON TRADE';
    private static final String POSTAL_CODE_TERRITORY_MAPPING_DE_OFF_TRADE_RT = 'EUR_DE_Off_Trade_Postal_Code_Territory_Mapping';


//    @isTest
//    private static void testOnTrade() {
//        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
//        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser) {
//            EUR_CRM_DE_TestClassUtilityHelper.initDataOnTrade();
//            Test.startTest();
//            /*
//              EUR_CRM_DE_TestClassUtilityHelper.region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', EUR_CRM_DE_TestClassUtilityHelper.regionalUser.id,  EUR_CRM_DE_TestClassUtilityHelper.DE_REGION_RECORD_TYPE);
//
//            EUR_CRM_DE_TestClassUtilityHelper.territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', EUR_CRM_DE_TestClassUtilityHelper.salesRepUser.id,EUR_CRM_DE_TestClassUtilityHelper.region.id, EUR_CRM_DE_TestClassUtilityHelper.DE_TERRITORY_RECORD_TYPE);
//
//            EUR_CRM_DE_TestClassUtilityHelper.postalmapping = createPostalCodeMapping('postalmap' , '12345', EUR_CRM_DE_TestClassUtilityHelper.territory.id, EUR_CRM_DE_TestClassUtilityHelper.DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
//            EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy = createCustomerTaxonomy('testtaxonomy', EUR_CRM_DE_TestClassUtilityHelper.regionalUser.id, EUR_CRM_DE_TestClassUtilityHelper.DE_CUSTOMER_TAXONOMY_RECORD_TYPE);
//
//            EUR_CRM_DE_TestClassUtilityHelper.euAccount = creaEUAccount('testname', '12345', EUR_CRM_DE_TestClassUtilityHelper.DE_EUACCOUNT_ON_CONSUMERS_RECORD_TYPE , EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id);
//
//      */
//            Id rtid = [select id from recordtype where developername = 'EUR_DE_OFF_Trade_Template' and sobjecttype = 'EUR_CRM_JB_Template__c'].id;
//            String mod = 'TestModule1234';
//            EUR_CRM_JB_Template__c template = new EUR_CRM_JB_Template__c(
//                    EUR_CRM_Module__c = mod,
//                    recordtypeid = rtid
//            );
//
//            EUR_CRM_DE_TestClassUtilityHelper.euAccount.EUR_CRM_Status_of_Customer__c = 'Active';
//            update EUR_CRM_DE_TestClassUtilityHelper.euAccount;
//            List<EUR_CRM_Account__c> g = new List<EUR_CRM_Account__c>();
//            g.add(EUR_CRM_DE_TestClassUtilityHelper.euAccount);
//            EUR_CRM_DE_ListingTemplateHandler.assignTemplateOnTradeAccounts(g, new Set<String>(), new Set<String>(), new Set<String>(), new Set<String>());
//            EUR_CRM_DE_ListingTemplateHandler.createKey('', '', '', '', '');
//            Test.stopTest();
//        }
//    }

    @isTest
    private static void offTradeDEBeforeInsertTest() {
        EUR_CRM_Region__c region = createRegion('Test Region', OFF_TRADE);
        EUR_CRM_Territory__c territory = createTerritory('Test Territory', region.Id);
        createPostalCodeTerritoryMapping('Test Postal Territory Mapping', territory.Id);

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = createCustomerTaxonomy('Test Taxonomy', CUSTOMER_TAXONOMY_DE_RT);
        EUR_CRM_JB_Template__c listingTemplate = makeListingTemplate(customerTaxonomy.Id, LISTING_TEMPLATE_DE_OFF_TRADE_RT);
        insert listingTemplate;

        EUR_CRM_Account__c account = makeAccount('Test Account', ACCOUNT_DE_OFF_TRADE_RETAIL_RT, customerTaxonomy.Id, OFF_TRADE);

        Test.startTest();
        insert account;
        Test.stopTest();

        EUR_CRM_Account__c insertedAccount = selectAccounts()[0];

        System.assertEquals(insertedAccount.EUR_CRM_Listing_Template__c, listingTemplate.Id);
    }

    @isTest
    private static void offTradeDEBeforeUpdateTest() {
        EUR_CRM_Region__c region = createRegion('Test Region 1', OFF_TRADE);
        EUR_CRM_Territory__c territory = createTerritory('Test Territory 1', region.Id);
        createPostalCodeTerritoryMapping('Test Postal Territory Mapping 1', territory.Id);

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = createCustomerTaxonomy('Test Taxonomy', CUSTOMER_TAXONOMY_DE_RT);
        EUR_CRM_JB_Template__c listingTemplate = makeListingTemplate(customerTaxonomy.Id, LISTING_TEMPLATE_DE_OFF_TRADE_RT);
        insert listingTemplate;

        EUR_CRM_Account__c account = makeAccount('Test Account', ACCOUNT_DE_OFF_TRADE_RETAIL_RT, null, OFF_TRADE);
        insert account;

        Test.startTest();
        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
        update account;
        Test.stopTest();

        EUR_CRM_Account__c updatedAccount = selectAccounts()[0];

        System.assertEquals(updatedAccount.EUR_CRM_Listing_Template__c, listingTemplate.Id);
    }

    @isTest
    private static void onTradeDEBeforeInsertTest() {
        EUR_CRM_Region__c region = createRegion('Test Region', ON_TRADE);
        EUR_CRM_Territory__c territory = createTerritory('Test Territory', region.Id);
        createPostalCodeTerritoryMapping('Test Postal Territory Mapping', territory.Id);

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = createCustomerTaxonomy('Test Taxonomy', CUSTOMER_TAXONOMY_DE_RT);
        EUR_CRM_JB_Template__c listingTemplate = makeListingTemplate(customerTaxonomy.Id, LISTING_TEMPLATE_DE_ON_TRADE_RT);
        insert listingTemplate;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = createGroupOutletType();
        EUR_CRM_Outlet_Type__c outletType = createOutletType(groupOutletType.Id);
        EUR_CRM_Image_Level__c imageLevel = createImageLevel();
        EUR_CRM_Volume_Potential__c volumePotential = createVolumePotential();

        EUR_CRM_JB_Template_Criteria__c listingTemplateCriteria = makeListingTemplateCriteria(listingTemplate.Id);
        listingTemplateCriteria.EUR_JB_Group_Outlet_Type__c = groupOutletType.Id;
        listingTemplateCriteria.EUR_JB_Outlet_Type__c = outletType.Id;
        listingTemplateCriteria.EUR_JB_Image_Level__c = imageLevel.Id;
        listingTemplateCriteria.EUR_JB_Volume_Potential__c = volumePotential.Id;
        insert listingTemplateCriteria;


        EUR_CRM_Account__c account = makeAccount('Test Account', ACCOUNT_DE_ON_GASTRONOMY_RT, customerTaxonomy.Id, ON_TRADE);
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;
        account.EUR_CRM_Status_of_Customer__c = 'Active';

        Test.startTest();
        insert account;
        Test.stopTest();

        EUR_CRM_Account__c insertedAccount = selectAccounts()[0];

        System.assertEquals(insertedAccount.EUR_CRM_Listing_Template__c, listingTemplate.Id);
    }

    @isTest
    private static void onTradeDEBeforeUpdateTest() {
        EUR_CRM_Region__c region = createRegion('Test Region 1', ON_TRADE);
        EUR_CRM_Territory__c territory = createTerritory('Test Territory 1', region.Id);
        createPostalCodeTerritoryMapping('Test Postal Territory Mapping 1', territory.Id);

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = createCustomerTaxonomy('Test Taxonomy', CUSTOMER_TAXONOMY_DE_RT);
        EUR_CRM_JB_Template__c listingTemplate = makeListingTemplate(customerTaxonomy.Id, LISTING_TEMPLATE_DE_ON_TRADE_RT);
        insert listingTemplate;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = createGroupOutletType();
        EUR_CRM_Outlet_Type__c outletType = createOutletType(groupOutletType.Id);
        EUR_CRM_Image_Level__c imageLevel = createImageLevel();
        EUR_CRM_Volume_Potential__c volumePotential = createVolumePotential();

        EUR_CRM_JB_Template_Criteria__c listingTemplateCriteria = makeListingTemplateCriteria(listingTemplate.Id);
        listingTemplateCriteria.EUR_JB_Group_Outlet_Type__c = groupOutletType.Id;
        listingTemplateCriteria.EUR_JB_Outlet_Type__c = outletType.Id;
        listingTemplateCriteria.EUR_JB_Image_Level__c = imageLevel.Id;
        listingTemplateCriteria.EUR_JB_Volume_Potential__c = volumePotential.Id;
        insert listingTemplateCriteria;


        EUR_CRM_Account__c account = makeAccount('Test Account', ACCOUNT_DE_ON_GASTRONOMY_RT, customerTaxonomy.Id, ON_TRADE);
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;
        insert account;

        Test.startTest();
        account.EUR_CRM_Status_of_Customer__c = 'Active';
        update account;
        Test.stopTest();

        EUR_CRM_Account__c updatedAccount = selectAccounts()[0];
        System.debug('\n updatedAccount => ' + JSON.serializePretty(updatedAccount) + '\n');

        System.assertEquals(updatedAccount.EUR_CRM_Listing_Template__c, listingTemplate.Id);
    }

    @IsTest
    private static void assignTemplateOnTradeAccounts_Test() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = createGroupOutletType();
        EUR_CRM_Outlet_Type__c outletType = createOutletType(groupOutletType.Id);
        EUR_CRM_Image_Level__c imageLevel = createImageLevel();
        EUR_CRM_Volume_Potential__c volumePotential = createVolumePotential();

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = createCustomerTaxonomy('Test Taxonomy', CUSTOMER_TAXONOMY_DE_RT);
        EUR_CRM_JB_Template__c listingTemplate = makeListingTemplate(customerTaxonomy.Id, LISTING_TEMPLATE_DE_ON_TRADE_RT);
        insert listingTemplate;

        EUR_CRM_JB_Template_Criteria__c listingTemplateCriteria = makeListingTemplateCriteria(listingTemplate.Id);
        listingTemplateCriteria.EUR_JB_Group_Outlet_Type__c = groupOutletType.Id;
        listingTemplateCriteria.EUR_JB_Outlet_Type__c = outletType.Id;
        listingTemplateCriteria.EUR_JB_Image_Level__c = imageLevel.Id;
        listingTemplateCriteria.EUR_JB_Volume_Potential__c = volumePotential.Id;
        insert listingTemplateCriteria;

        EUR_CRM_Account__c account = makeAccount('Test Account', ACCOUNT_DE_ON_GASTRONOMY_RT, null, ON_TRADE);
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;
        insert account;

        EUR_CRM_DE_ListingTemplateHandler.assignTemplateOnTradeAccounts(new List<EUR_CRM_Account__c>{account},
            new Set<String>{groupOutletType.Id}, new Set<String>{outletType.Id}, new Set<String>{imageLevel.Id}, new Set<String>{volumePotential.Id}
        );
    }


    /*===================================
    *  Makers
    * ===================================*/
    private static EUR_CRM_Region__c createRegion(String regionName, String channel) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Region__c.getRecordTypeInfosByDeveloperName().get(REGION_DE_RT).getRecordTypeId();
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(
            Name = regionName
            , RecordTypeId = recordTypeId
            , EUR_CRM_Channel__c = channel
        );
        insert region;
        return region;
    }

    private static EUR_CRM_Territory__c createTerritory(String territoryName, Id regionId) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Territory__c.getRecordTypeInfosByDeveloperName().get(TERRITORY_DE_RT).getRecordTypeId();
        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(
            Name = territoryName
            , EUR_CRM_Region__c = regionId
            , RecordTypeId = recordTypeId
            , EUR_CRM_Territory_Owner__c = UserInfo.getUserId()
        );
        insert territory;
        return territory;
    }

    private static EUR_CRM_Postal_Code_Territory_Mapping__c createPostalCodeTerritoryMapping(String recordName, Id territoryId) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Postal_Code_Territory_Mapping__c.getRecordTypeInfosByDeveloperName().get(POSTAL_CODE_TERRITORY_MAPPING_DE_OFF_TRADE_RT).getRecordTypeId();
        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = new EUR_CRM_Postal_Code_Territory_Mapping__c(
            Name = recordName
            , EUR_CRM_Postal_Code__c = '12345'
            , EUR_CRM_City__c = 'Test City'
            , EUR_CRM_Territory__c = territoryId
            , RecordTypeId = recordTypeId
        );
        insert postalCodeTerritoryMapping;
        return postalCodeTerritoryMapping;
    }

    private static EUR_CRM_Customer_Taxonomy__c createCustomerTaxonomy(String name, String recordTypeDevName) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Customer_Taxonomy__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = new EUR_CRM_Customer_Taxonomy__c (
            RecordTypeId = recordTypeId
            , Name = name
        );
        insert customerTaxonomy;
        return customerTaxonomy;
    }

    private static EUR_CRM_Account__c makeAccount(String name, String recordTypeDevName, Id customerTaxonomy, String channel) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = '12345'
            , RecordTypeId = recordTypeId
            , Name = name
            , EUR_JB_Customer_Taxonomy__c = customerTaxonomy
            , EUR_CRM_Channel__c = channel
        );
//        insert euAccount;
        return euAccount;
    }

    private static EUR_CRM_JB_Template__c makeListingTemplate(Id customerTaxonomyId, String recordTypeDevName) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_JB_Template__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        EUR_CRM_JB_Template__c template = new EUR_CRM_JB_Template__c(
            EUR_CRM_Customer_Taxonomy__c = customerTaxonomyId
            , RecordTypeId = recordTypeId
        );
//        insert template;
        return template;
    }

    private static EUR_CRM_JB_Template_Criteria__c makeListingTemplateCriteria(Id listingTemplateId) {
        Id recordTypeId = Schema.SObjectType.EUR_CRM_JB_Template_Criteria__c.getRecordTypeInfosByDeveloperName().get(LISTING_TEMPLATE_CRITERIA_DE_RT).getRecordTypeId();

        return new EUR_CRM_JB_Template_Criteria__c(
            RecordTypeId = recordTypeId
            , EUR_JB_Template__c = listingTemplateId
            , EUR_JB_Image_Level__c = null
            , EUR_JB_Outlet_Type__c = null
            , EUR_JB_Volume_Potential__c = null
            , EUR_JB_Group_Outlet_Type__c = null
            , EUR_JB_Active__c = true
        );
    }

    private static EUR_CRM_Group_Outlet_Type__c createGroupOutletType() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = new EUR_CRM_Group_Outlet_Type__c(
//            Name = 'Test group outlet'
        );
        insert groupOutletType;
        return groupOutletType;
    }

    private static EUR_CRM_Outlet_Type__c createOutletType(Id groupOutletTypeId) {
        EUR_CRM_Outlet_Type__c outletType = new EUR_CRM_Outlet_Type__c(
            EUR_CRM_Group_Outlet_Type__c = groupOutletTypeId
        );
        insert outletType;
        return outletType;
    }

    private static EUR_CRM_Image_Level__c createImageLevel() {
        EUR_CRM_Image_Level__c imageLevel = new EUR_CRM_Image_Level__c();
        insert imageLevel;
        return imageLevel;
    }

    private static EUR_CRM_Volume_Potential__c createVolumePotential() {
        EUR_CRM_Volume_Potential__c volumePotential = new EUR_CRM_Volume_Potential__c();
        insert volumePotential;
        return volumePotential;
    }



    /*===================================
    *  SOQL Selectors
    * ===================================*/
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
                , EUR_CRM_Listing_Template__c
                , EUR_JB_Customer_Taxonomy__c
                , EUR_CRM_Status_of_Customer__c
            FROM EUR_CRM_Account__c
        ];
    }

    private static List<EUR_CRM_JB_Template_Criteria__c> selectTemplateCriterias() {
        return [
            SELECT Id, EUR_JB_Active__c, EUR_JB_Template__r.EUR_CRM_Record_Type_Name__c,
                EUR_JB_External_ID__c, EUR_JB_Group_Outlet_Type__c, EUR_JB_Image_Level__c,
                EUR_JB_Outlet_Type__c, EUR_JB_Template__c, EUR_JB_Volume_Potential__c
            FROM EUR_CRM_JB_Template_Criteria__c
//            WHERE EUR_JB_Group_Outlet_Type__c IN:groupOutletTypeSet
//                AND EUR_JB_Outlet_Type__c IN:outletTypeSet
//                AND EUR_JB_Image_Level__c IN:imageLevelSet
//                AND EUR_JB_Volume_Potential__c IN:volumePotentialSet
//                AND EUR_JB_Active__c = true
//                AND EUR_JB_Template__r.recordtype.developername = 'EUR_DE_ON_TRADE_Template'
//            ORDER by lastmodifieddate asc
        ];
    }







}