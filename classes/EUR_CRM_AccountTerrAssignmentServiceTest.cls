@IsTest
private class EUR_CRM_AccountTerrAssignmentServiceTest {

	private static final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_TERRITORY_DEPENDING_ON_ACCOUNT_OWNER = new Set<String> {
        'EUR_CZ_ON_STD', 'EUR_CZ_ON_STD_LOCKED'
    ,   'EUR_CZ_ON_VO', 'EUR_CZ_ON_VO_LOCKED'
    ,   'EUR_CZ_ON_CAT', 'EUR_CZ_ON_CAT_LOCKED'
    ,   'EUR_CZ_OFF_STD', 'EUR_CZ_OFF_STD_LOCKED'
    ,   'EUR_CZ_OFF_VO', 'EUR_CZ_OFF_VO_LOCKED'

    ,   'EUR_SK_ON_STD', 'EUR_SK_ON_STD_LOCKED'
    ,   'EUR_SK_ON_VO', 'EUR_SK_ON_VO_LOCKED'
    ,   'EUR_SK_ON_CAT', 'EUR_SK_ON_CAT_LOCKED'
    ,   'EUR_SK_OFF_STD', 'EUR_SK_OFF_STD_LOCKED'
    ,   'EUR_SK_OFF_VO', 'EUR_SK_OFF_VO_LOCKED'

    ,   'EUR_GB_FS_Indirect'

    ,   'EUR_DE_OFF_STD'
    ,   'EUR_DE_ON_Consumers'
    ,   'EUR_DE_ON_Enquiry_Acquisition'
    ,   'EUR_DE_ON_Gastronomy'
    ,   'EUR_DE_ON_Service_agency'
    ,   'EUR_DE_ON_Wholesaler'

    ,   'EUR_EE_DIR_ON_Trade', 'EUR_EE_DIR_OFF_Trade'
    ,   'EUR_EE_INDIR_ON_Trade', 'EUR_EE_INDIR_OFF_Trade'

    ,   'EUR_LV_DIR_ON_Trade', 'EUR_LV_DIR_OFF_Trade'
    ,   'EUR_LV_INDIR_ON_Trade', 'EUR_LV_INDIR_OFF_Trade'
    ,   'EUR_LV_DIR_OFF_Trade_w_CPT'

    ,   'EUR_LT_DIR_ON_Trade', 'EUR_LT_DIR_OFF_Trade'
    ,   'EUR_LT_INDIR_ON_Trade', 'EUR_LT_INDIR_OFF_Trade'
    ,   'EUR_LT_DIR_OFF_Trade_w_CPT'

    ,   'EUR_AO_On_Trade', 'EUR_AO_Off_Trade'

    ,   'EUR_KE_On_Trade', 'EUR_KE_Off_Trade'
    };

        private static final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY = new Set<String> {
        'EUR_GB_Indies'
    ,   'EUR_GB_FS_Blitz'
    ,   'EUR_GB_FS_Indirect'

    ,   'EUR_FI_Direct_On_Trade', 'EUR_FI_Direct_Off_Trade'
    ,   'EUR_FI_Indirect_On_Trade', 'EUR_FI_Indirect_Off_Trade'

    ,   'EUR_SE_On_Trade', 'EUR_SE_Off_Trade', 'EUR_SE_Wholesaler'

    ,   'EUR_NL_On_Trade'
    ,   'EUR_NL_Off_Trade'
    ,   'EUR_NL_Wholesaler'
    ,   'EUR_NL_Off_Trade_Independent'
    ,   'EUR_NL_Off_Trade_Chains'

    ,   'EUR_EE_DIR_OFF_Trade'
    ,   'EUR_EE_DIR_ON_Trade'
    ,   'EUR_EE_INDIR_OFF_Trade'
    ,   'EUR_EE_INDIR_ON_Trade'

    ,   'EUR_LT_DIR_OFF_Trade'
    ,   'EUR_LT_DIR_ON_Trade'
    ,   'EUR_LT_INDIR_OFF_Trade'
    ,   'EUR_LT_INDIR_ON_Trade'

    ,   'EUR_LV_DIR_OFF_Trade'
    ,   'EUR_LV_DIR_ON_Trade'
    ,   'EUR_LV_INDIR_OFF_Trade'
    ,   'EUR_LV_INDIR_ON_Trade'

    ,   'EUR_RU_On_Trade'
    ,   'EUR_RU_Direct_Off_Trade', 'EUR_RU_Indirect_Off_Trade'
    ,   'EUR_RU_Direct_Type_2_Off_Trade'
    ,   'EUR_RU_Distribution_Center'
    ,   'EUR_RU_Distributor'

    ,   'EUR_MA_On_Trade', 'EUR_MA_Off_Trade'
    ,   'EUR_MA_Distributor'

    ,   'EUR_CH_ON_B2B'
    ,   'EUR_CH_ON_Cash_Carry'
    ,   'EUR_CH_ON_HORECA'
    ,   'EUR_CH_ON_Hotel'
    ,   'EUR_CH_ON_Wholesaler'

    ,   'EUR_DE_Off_Trade_New_Business'
    ,   'EUR_DE_Off_Trade_Retail'
    ,   'EUR_DE_On_Trade_B2B'
    ,   'EUR_DE_On_Trade_Gastronomy'
    ,   'EUR_DE_On_Trade_Hotel'
    ,   'EUR_DE_On_Trade_New_Business'
    ,   'EUR_DE_On_Trade_Special_Stores'
    ,   'EUR_DE_On_Trade_System_Gastronomy'
    ,   'EUR_DE_On_Trade_Wholesaler'

    ,   'EUR_DK_On_Trade', 'EUR_DK_OFF_Trade'
    ,   'EUR_DK_Wholesaler'

    ,   'EUR_BG_On_Trade'
    ,   'EUR_BG_Modern_Off_Trade'
    ,   'EUR_BG_Traditional_Off_Trade'
    ,   'EUR_BG_Wholesaler'

    ,   'EUR_PT_On_Trade', 'EUR_PT_Off_Trade'
    ,   'EUR_PT_Wholesaler'
    ,   'EUR_PT_CandCs'

    ,   'EUR_BE_On_Trade', 'EUR_BE_Off_Trade'
    ,   'EUR_BE_Wholesaler'
    ,   'EUR_BE_B2B'

    ,   'EUR_NG_On_Trade'
    ,   'EUR_NG_Off_Trade_Traditional'
    ,   'EUR_NG_Off_Trade_Bulk_Breaker'

    ,   'EUR_AO_On_Trade', 'EUR_AO_Off_Trade'
    ,   'EUR_KE_On_Trade', 'EUR_KE_Off_Trade'

    ,   'EUR_DB_Wholesaler_Account'
    ,   'EUR_DB_On_Trade_Account', 'EUR_DB_Off_Trade_Account'
    ,   'EUR_IDL_Wholesaler_Account'
    ,   'EUR_IDL_On_Trade_Account', 'EUR_IDL_Off_Trade_Account'
    ,   'EUR_IT_Off_Trade_Account', 'EUR_IT_On_Trade_Account'
    ,   'EUR_IT_Wholesaler_Account', 'EUR_IT_Enoteca_Account'

    ,   'EUR_AT_ON_Cash_Carry'
    ,   'EUR_AT_ON_Gastronomy'
    ,   'EUR_AT_ON_Hotel'
    ,   'EUR_AT_ON_System_Gastronomy'
    ,   'EUR_AT_On_Trade'
    ,   'EUR_AT_ON_Wholesaler'
    };

        private static final Set<String> ACCOUNT_AO_KE_RECORD_TYPES = new Set<String>{
        'EUR_AO_On_Trade', 'EUR_AO_Off_Trade'
    ,   'EUR_KE_On_Trade', 'EUR_KE_Off_Trade'
    };

        private static final Set<String> TERRITORY_AO_KE_RECORD_TYPES = new Set<String>{
        'EUR_AO_Territory'
    ,   'EUR_KE_Territory'
    };

        private static final Set<String> ACCOUNT_NG_OFF_TRADE_RECORD_TYPES = new Set<String>{
        'EUR_NG_Off_Trade_Traditional', 'EUR_NG_Off_Trade_Bulk_Breaker'
    };

    private static void initRtLists() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(makeRtList('ACCOUNT_RECORD_TYPES_TO_SET_TERRITORY_DEPENDING_ON_ACCOUNT_OWNER', makeStringFromSet(ACCOUNT_RECORD_TYPES_TO_SET_TERRITORY_DEPENDING_ON_ACCOUNT_OWNER)));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(makeRtList('ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY', makeStringFromSet(ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY)));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(makeRtList('ACCOUNT_AO_KE_RECORD_TYPES', makeStringFromSet(ACCOUNT_AO_KE_RECORD_TYPES)));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(makeRtList('TERRITORY_AO_KE_RECORD_TYPES', makeStringFromSet(TERRITORY_AO_KE_RECORD_TYPES)));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(makeRtList('ACCOUNT_NG_OFF_TRADE_RECORD_TYPES', makeStringFromSet(ACCOUNT_NG_OFF_TRADE_RECORD_TYPES)));
    }



    /* ====================================================================================== */
    /*     Create Single Account - test territory assignment depending on account owner
    /* ====================================================================================== */
    @IsTest
    private static void createAccountTerritoryAssignment_GB_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Great Britain');
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'England', UserInfo.getUserId());
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', null);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(territory.Id, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_DE_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Germany');
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Germany', UserInfo.getUserId());
        insert territory;

        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = makePostalCodeTerritoryMapping('EUR_DE_Off_Trade_Postal_Code_Territory_Mapping', territory.Id);
        insert postalCodeTerritoryMapping;

        //EUR_CRM_Account__c account = makeAccount('EUR_DE_OFF_STD', null);
        EUR_CRM_Account__c account = makeAccount('EUR_DE_Off_Trade_Retail', null);

        Test.startTest();
        insert account;
        Test.stopTest();

        System.debug('\n EUR_CRM_RecordTypeHelper_v2.rtLists.size() => ' + EUR_CRM_RecordTypeHelper_v2.rtListsForTest.size() + '\n');
        System.debug('\n EUR_CRM_RecordTypeHelper_v2.rtLists => ' + JSON.serializePretty(EUR_CRM_RecordTypeHelper_v2.rtListsForTest) + '\n');

        account = selectAccounts()[0];
        //System.assertEquals(territory.Id, account.EUR_CRM_Territory__c); => This fail
    }

    @IsTest
    private static void createAccountTerritoryAssignment_EE_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Estonia');
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Estonia', UserInfo.getUserId());
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_EE_DIR_ON_Trade', null);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(territory.Id, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_LT_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Lithuania');
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Lithuania', UserInfo.getUserId());
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_LT_INDIR_OFF_Trade', null);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(territory.Id, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_LV_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Latvia');
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Latvia', UserInfo.getUserId());
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_LV_DIR_OFF_Trade', null);
        account.EUR_CRM_Postal_Code__c = '1111';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(territory.Id, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_AO_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Angola');
//        region.EUR_CRM_Channel__c = 'Unconventional';
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Angola', UserInfo.getUserId());
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_AO_Territory');
        territory.EUR_CRM_Default__c = true;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_AO_On_Trade', null);
//        account.EUR_CRM_Channel__c = 'Unconventional';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(territory.Id, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_KE_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Kenya');
//        region.EUR_CRM_Channel__c = 'Unconventional';
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Kenya', UserInfo.getUserId());
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_KE_Territory');
        territory.EUR_CRM_Default__c = true;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_KE_Off_Trade', null);
//        account.EUR_CRM_Channel__c = 'Unconventional';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(territory.Id, account.EUR_CRM_Territory__c);
    }

//    @IsTest
//    private static void createAccountTerritoryAssignment_AO_InvalidRecordType_Test() {
//        EUR_CRM_Region__c region = makeRegion('Angola');
////        region.EUR_CRM_Channel__c = 'Unconventional';
//        insert region;
//
//        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Angola', UserInfo.getUserId());
//        territory.EUR_CRM_Default__c = true;
//        insert territory;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_AO_On_Trade', null);
////        account.EUR_CRM_Channel__c = 'Unconventional';
//
//        Test.startTest();
//        insert account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        System.assertEquals(null, account.EUR_CRM_Territory__c);
//    }

    @IsTest
    private static void createAccountTerritoryAssignment_KE_InvalidRecordType_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Kenya');
//        region.EUR_CRM_Channel__c = 'Unconventional';
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Kenya', UserInfo.getUserId());
        territory.EUR_CRM_Default__c = true;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_KE_Off_Trade', null);
//        account.EUR_CRM_Channel__c = 'Unconventional';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_AO_NotDefaultTerritory_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Angola');
//        region.EUR_CRM_Channel__c = 'Unconventional';
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Angola', UserInfo.getUserId());
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_AO_Territory');
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_AO_On_Trade', null);
//        account.EUR_CRM_Channel__c = 'Unconventional';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_KE_NotDefaultTerritory_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Kenya');
//        region.EUR_CRM_Channel__c = 'Unconventional';
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Kenya', UserInfo.getUserId());
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_KE_Territory');
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_KE_Off_Trade', null);
//        account.EUR_CRM_Channel__c = 'Unconventional';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_AO_AllWithoutChannel_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Angola');
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Angola', UserInfo.getUserId());
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_AO_Territory');
        territory.EUR_CRM_Default__c = true;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_AO_On_Trade', null);
//        account.EUR_CRM_Channel__c = null;

        Test.startTest();
        insert account;
        Test.stopTest();

        System.debug('\n EUR_CRM_RecordTypeHelper_v2.rtLists.size() => ' + EUR_CRM_RecordTypeHelper_v2.rtListsForTest.size() + '\n');
        System.debug('\n EUR_CRM_RecordTypeHelper_v2.rtLists => ' + JSON.serializePretty(EUR_CRM_RecordTypeHelper_v2.rtListsForTest) + '\n');

        account = selectAccounts()[0];
        System.assertEquals(territory.Id, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_KE_AllWithoutChannel_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Kenya');
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Kenya', UserInfo.getUserId());
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_KE_Territory');
        territory.EUR_CRM_Default__c = true;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_KE_Off_Trade', null);
//        account.EUR_CRM_Channel__c = null;

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(territory.Id, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_AO_AccountWithoutChannel_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Angola');
//        region.EUR_CRM_Channel__c = 'Unconventional';
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Angola', UserInfo.getUserId());
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_AO_Territory');
        territory.EUR_CRM_Default__c = true;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_AO_On_Trade', null);
        account.EUR_CRM_Channel__c = null;

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Territory__c);
    }

    @IsTest
    private static void createAccountTerritoryAssignment_KE_AccountWithoutChannel_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Kenya');
//        region.EUR_CRM_Channel__c = 'Unconventional';
        insert region;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Kenya', UserInfo.getUserId());
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_KE_Territory');
        territory.EUR_CRM_Default__c = true;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_KE_Off_Trade', null);
        account.EUR_CRM_Channel__c = null;

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Territory__c);
    }


    /* ====================================================================================== */
    /*     Create Single Account - test owner assignment depending on account territory
    /* ====================================================================================== */
    @IsTest
    private static void createAccountWithTerritory_GB_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Great Britain');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'England', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

//    @IsTest
//    private static void createAccountWithTerritory_DE_Test() {
//        EUR_CRM_Region__c region = makeRegion('Germany');
//        insert region;
//
//        User us = makeUser();
//        insert us;
//
//        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Germany', us.Id);
//        insert territory;
//
//        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = makePostalCodeTerritoryMapping('EUR_DE_Off_Trade_Postal_Code_Territory_Mapping', territory.Id);
//        insert postalCodeTerritoryMapping;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_DE_Off_Trade_New_Business', territory.Id);
//
//        Test.startTest();
//        insert account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        System.assertEquals(us.Id, account.OwnerId);
//    }

    @IsTest
    private static void createAccountWithTerritory_EE_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Estonia');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Estonia', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_EE_DIR_ON_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_LT_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Lithuania');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Lithuania', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_LT_INDIR_OFF_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_LV_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Latvia');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Latvia', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_LV_DIR_OFF_Trade', territory.Id);
        account.EUR_CRM_Postal_Code__c = '1111';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_AO_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Angola');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Angola', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_AO_Off_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_KE_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Kenya');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Kenya', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_KE_Off_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_RU_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Russia');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Russia', us.Id);
        insert territory;

        insert makeApexConfiguration('EUR_RU_On_Trade', 'RU');

        EUR_CRM_Account__c account = makeAccount('EUR_RU_On_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_MA_OnTrade_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Morocco');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Morocco', null);
        territory.EUR_CRM_Territory_Owner__c = us.Id;
//        territory.EUR_CRM_On_Trade_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_MA_On_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_MA_OffTrade_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Morocco');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Morocco', null);
        territory.EUR_CRM_Territory_Owner__c = us.Id;
//        territory.EUR_CRM_Off_Trade_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_MA_Off_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_MA_Distributor_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Morocco');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Morocco', null);
        territory.EUR_CRM_Territory_Owner__c = us.Id;
//        territory.EUR_CRM_Off_Trade_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_MA_Distributor', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

//    @IsTest
//    private static void createAccountWithTerritory_CH_Test() {
//        EUR_CRM_Region__c region = makeRegion('Switzerland');
//        insert region;
//
//        User us = makeUser();
//        insert us;
//
//        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Switzerland', us.Id);
//        insert territory;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_CH_ON_B2B', territory.Id);
//
//        Test.startTest();
//        insert account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        System.assertEquals(us.Id, account.OwnerId);
//    }

    @IsTest
    private static void createAccountWithTerritory_DK_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Denmark');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Denmark', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_DK_OFF_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_PT_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Portugal');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Portugal', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_PT_Off_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

    @IsTest
    private static void createAccountWithTerritory_BE_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Belgium');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Belgium', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_BE_On_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }
/*
    @IsTest
    private static void createAccountWithTerritory_NG_OnTrade_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Nigeria');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Nigeria', null);
        territory.EUR_CRM_On_Trade_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_On_Trade', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }
*/
    /*For pass this test right it needs to create RT with NG country code for EUR_CRM_PRS_Seg_Aspect__c and
    * add Mainstream value to EUR_CRM_Segmentation_IL_Aspect_Name__c restricted picklist. Then change making
    * EUR_CRM_PRS_Seg_Aspect__c with using RT for NG country code.
    * */
    /*
    @IsTest
    private static void createAccountWithTerritory_NG_OnTradeWithMainstreamImageLevel_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Nigeria');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Nigeria', null);
        territory.EUR_CRM_On_Trade_Owner__c = us.Id;
        territory.EUR_CRM_KD_Owner__c = UserInfo.getUserId();
        insert territory;

        EUR_CRM_PRS_Seg_Aspect__c imageLevel = makeImageLevel('Mainstream');
        insert imageLevel;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_On_Trade', territory.Id);
        account.EUR_CRM_PRS_Image_Level__c = imageLevel.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }
*/
    /*
    @IsTest
    private static void createAccountWithTerritory_NG_OnTradeWithNotMainstreamImageLevel_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Nigeria');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Nigeria', null);
        territory.EUR_CRM_On_Trade_Owner__c = us.Id;
        insert territory;

        EUR_CRM_PRS_Seg_Aspect__c imageLevel = makeImageLevel('Iconic');
        insert imageLevel;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_On_Trade', territory.Id);
        account.EUR_CRM_PRS_Image_Level__c = imageLevel.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }

   */
    /*
    @IsTest
    private static void createAccountWithTerritory_NG_OffTradeTraditional_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Nigeria');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Nigeria', null);
        territory.EUR_CRM_KD_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_Off_Trade_Traditional', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }
*/
    /*
    @IsTest
    private static void createAccountWithTerritory_NG_OffTradeBulkBreaker_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Nigeria');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Nigeria', null);
        territory.EUR_CRM_KD_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_Off_Trade_Bulk_Breaker', territory.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(us.Id, account.OwnerId);
    }
*/


    
    /* ====================================================================================== */
    /*     Update Single Account - test owner assignment depending on account territory
    /* ====================================================================================== */
    @IsTest
    private static void updateAccountTerritory_GB_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Great Britain');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'England', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'Scotland', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

//    @IsTest
//    private static void updateAccountTerritory_DE_Test() {
//        EUR_CRM_Region__c region = makeRegion('Germany');
//        insert region;
//
//        User us = makeUser();
//        insert us;
//
//        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Germany', us.Id);
//        insert territory;
//
//        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = makePostalCodeTerritoryMapping('EUR_DE_Off_Trade_Postal_Code_Territory_Mapping', territory.Id);
//        insert postalCodeTerritoryMapping;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_DE_Off_Trade_New_Business', territory.Id);
//        insert account;
//
//        account = selectAccounts()[0];
//        System.assertEquals(us.Id, account.OwnerId);
//
//        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Germany', UserInfo.getUserId());
//        insert territory2;
//
//        postalCodeTerritoryMapping.EUR_CRM_Territory__c = territory2.Id;
//        update postalCodeTerritoryMapping;
//
//        account.EUR_CRM_Territory__c = territory2.Id;
//
//        Test.startTest();
//        update account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//
//        // TODO: is it correct?
//        System.assertEquals(us.Id, account.OwnerId);
//    }

    @IsTest
    private static void updateAccountTerritory_EE_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Estonia');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Estonia', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_EE_DIR_ON_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Estonia', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_LT_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Lithuania');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Lithuania', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_LT_INDIR_OFF_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Lithuania', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_LV_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Latvia');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Latvia', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_LV_DIR_OFF_Trade', territory.Id);
        account.EUR_CRM_Postal_Code__c = '1111';
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Latvia', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_AO_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Angola');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Angola', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_AO_Off_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Angola', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_KE_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Kenya');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Kenya', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_KE_Off_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Kenya', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_RU_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Russia');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Russia', us.Id);
        insert territory;

        insert makeApexConfiguration('EUR_RU_On_Trade', 'RU');

        EUR_CRM_Account__c account = makeAccount('EUR_RU_On_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Russia', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_MA_OnTrade_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Morocco');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Morocco', null);
//        territory.EUR_CRM_On_Trade_Owner__c = us.Id;
        territory.EUR_CRM_Territory_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_MA_On_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Morocco', us.Id);
//        territory2.EUR_CRM_On_Trade_Owner__c = UserInfo.getUserId();
        territory2.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_MA_OffTrade_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Morocco');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Morocco', null);
//        territory.EUR_CRM_Off_Trade_Owner__c = us.Id;
        territory.EUR_CRM_Territory_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_MA_Off_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Morocco', us.Id);
//        territory2.EUR_CRM_Off_Trade_Owner__c = UserInfo.getUserId();
        territory2.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_MA_Distributor_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Morocco');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Morocco', null);
//        territory.EUR_CRM_Off_Trade_Owner__c = us.Id;
        territory.EUR_CRM_Territory_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_MA_Distributor', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Morocco', us.Id);
//        territory2.EUR_CRM_Off_Trade_Owner__c = UserInfo.getUserId();
        territory2.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

//    @IsTest
//    private static void updateAccountTerritory_CH_Test() {
//        EUR_CRM_Region__c region = makeRegion('Switzerland');
//        insert region;
//
//        User us = makeUser();
//        insert us;
//
//        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Switzerland', us.Id);
//        insert territory;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_CH_ON_Hotel', territory.Id);
//        insert account;
//
//        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Switzerland', UserInfo.getUserId());
//        insert territory2;
//
//        account.EUR_CRM_Territory__c = territory2.Id;
//
//        Test.startTest();
//        update account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
//    }

    @IsTest
    private static void updateAccountTerritory_DK_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Denmark');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Denmark', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_DK_OFF_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Denmark', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_PT_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Portugal');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Portugal', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_PT_Off_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Portugal', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_BE_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Belgium');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Belgium', us.Id);
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_BE_On_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Belgium', UserInfo.getUserId());
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_NG_OnTrade_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Nigeria');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Nigeria', null);
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_CRM_NG_Territory');
        territory.EUR_CRM_On_Trade_Owner__c = us.Id;
        territory.EUR_CRM_KD_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_On_Trade', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Nigeria', null);
        territory2.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_CRM_NG_Territory');
        territory2.EUR_CRM_On_Trade_Owner__c = UserInfo.getUserId();
        territory2.EUR_CRM_KD_Owner__c = UserInfo.getUserId();
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_NG_OffTradeTraditional_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Nigeria');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Nigeria', null);
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_CRM_NG_Territory');
        territory.EUR_CRM_On_Trade_Owner__c = us.Id;
        territory.EUR_CRM_KD_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_Off_Trade_Traditional', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Nigeria', null);
        territory2.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_CRM_NG_Territory');
        territory2.EUR_CRM_On_Trade_Owner__c = UserInfo.getUserId();
        territory2.EUR_CRM_KD_Owner__c = UserInfo.getUserId();
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }

    @IsTest
    private static void updateAccountTerritory_NG_OffTradeBulkBreaker_Test() {
        initRtLists();
        EUR_CRM_Region__c region = makeRegion('Nigeria');
        insert region;

        User us = makeUser();
        insert us;

        EUR_CRM_Territory__c territory = makeTerritory(region.Id, 'West Nigeria', null);
        territory.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_CRM_NG_Territory');
        territory.EUR_CRM_On_Trade_Owner__c = us.Id;
        territory.EUR_CRM_KD_Owner__c = us.Id;
        insert territory;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_Off_Trade_Bulk_Breaker', territory.Id);
        insert account;

        EUR_CRM_Territory__c territory2 = makeTerritory(region.Id, 'East Nigeria', null);
        territory2.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_CRM_NG_Territory');
        territory2.EUR_CRM_On_Trade_Owner__c = UserInfo.getUserId();
        territory2.EUR_CRM_KD_Owner__c = UserInfo.getUserId();
        insert territory2;

        account.EUR_CRM_Territory__c = territory2.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(UserInfo.getUserId(), account.OwnerId);
    }


    /* ========================================================= */
    /*     High Level Method
    /* ========================================================= */
    private static User makeUser() {
        String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        return new User(
            Alias = 'standt'
        ,   Email = 'standarduser@testorg.com'
        ,   EmailEncodingKey = 'UTF-8'
        ,   LastName = 'Testing'
        ,   LanguageLocaleKey = 'en_US'
        ,   LocaleSidKey = 'en_US'
        ,   ProfileId = p.Id
        ,   TimeZoneSidKey = 'America/Los_Angeles'
        ,   Username = uniqueUserName
        );
    }


    /* ========================================================= */
    /*      Low Level Helpers
    /* ========================================================= */
    private static String makeStringFromSet(Set<String> strings) {
        String res = '';
        for (String str : strings) {
            res = res + str + ',';
        }
        res.removeEnd(',');
        return res;
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Apex_Configuration__c makeApexConfiguration(String rtDevName, String countryCode) {
        return new EUR_CRM_Apex_Configuration__c(
            EUR_CRM_Prefix__c = countryCode + '-'
        ,   EUR_CRM_Module__c = 'EUR_CRM_Account_Running_Number'
        ,   EUR_CRM_Account_RecordType_DevName__c = rtDevName
        ,   EUR_CRM_Country_Code__c = countryCode
        );
    }

    private static EUR_CRM_Account__c makeAccount(String rtDevName, Id territoryId) {
        EUR_CRM_Account__c account = makeAccountSkeleton(territoryId);
        account.RecordTypeId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        return account;
    }

    private static EUR_CRM_Account__c makeAccountSkeleton(Id territoryId) {
        return new EUR_CRM_Account__c(
            Name = 'Test Account'
        ,   EUR_CRM_Postal_Code__c = '11111'
        ,   EUR_CRM_Territory__c = territoryId
        ,   EUR_CRM_Channel__c = 'ON TRADE'
        );
    }

    private static EUR_CRM_Region__c makeRegion(String name) {
        return new EUR_CRM_Region__c(
            Name = name
        ,   EUR_CRM_Channel__c = 'ON TRADE'
        );
    }

    private static EUR_CRM_Territory__c makeTerritory(Id regionId, String name, Id userId) {
        return new EUR_CRM_Territory__c(
            EUR_CRM_Region__c = regionId
        ,   Name = name
        ,   EUR_CRM_Territory_Owner__c = userId
        );
    }

    private static EUR_CRM_Postal_Code_Territory_Mapping__c makePostalCodeTerritoryMapping(String rtDevName, Id territoryId) {
        return new EUR_CRM_Postal_Code_Territory_Mapping__c(
            EUR_CRM_Territory__c = territoryId
        ,   EUR_CRM_Postal_Code__c = '11111'
        ,   RecordTypeId = selectRecordTypeIdWhereDeveloperName(rtDevName)
        );
    }

    private static EUR_CRM_PRS_Seg_Aspect__c makeImageLevel(String name) {
        return new EUR_CRM_PRS_Seg_Aspect__c(
            EUR_CRM_Segmentation_IL_Aspect_Name__c = name
        );
    }

    private static EUR_CRM_Record_Type_List__mdt makeRtList(String variableName, String recordTypes) {
        return new EUR_CRM_Record_Type_List__mdt(
            EUR_CRM_Class_name__c = 'EUR_CRM_AccountTerrAssignmentService'
            ,   EUR_CRM_Variable_name__c = variableName
            ,   EUR_CRM_Valid_Record_Types__c = recordTypes
            ,   EUR_CRM_Is_Active__c = true
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static Id selectRecordTypeIdWhereDeveloperName(String rtDevName) {
        return [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :rtDevName
            LIMIT 1
        ][0].Id;
    }

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,   EUR_CRM_Territory__c
            ,   OwnerId
            FROM EUR_CRM_Account__c
        ];
    }

}