@IsTest (IsParallel = true)
private class EUR_CRM_AccountVisitFrequencyServiceTest {

    private static final Set<String> FI_ACCOUNT_RECORD_TYPE_DEV_NAMES = new Set<String> {
        'EUR_FI_Direct_Off_Trade'
        ,   'EUR_FI_Direct_On_Trade'
        ,   'EUR_FI_Indirect_Off_Trade'
        ,   'EUR_FI_Indirect_On_Trade'
    };

    private static final Set<String> NG_ACCOUNT_RECORD_TYPE_DEV_NAMES = new Set<String> {
        'EUR_NG_On_Trade'
        ,   'EUR_NG_Off_Trade_Traditional'
        ,   'EUR_NG_Off_Trade_Modern'
    };

    private static final Set<String> VISIT_FREQUENCY_CRITERIA_RECORD_TYPE_DEV_NAMES = new Set<String> {
        'EUR_NG_Visit_Frequency_Criteria_On_Trade'
    ,   'EUR_NG_Visit_Frequency_Criteria_Off_Trade'
    };

    private static final Set<String> VALID_ACCOUNT_CHANNELS = new Set<String> {
        'ON TRADE'
    ,   'OFF TRADE'
    };

    private static final Set<String> VISIT_FREQUENCY_NAMES = new Set<String> {
        'Once a quarter'
        ,   'Once every 6 months'
    };

    private final static Set<String> ACC_RT_TO_ASSIGN_VF = new Set<String>{
    	'EUR_GB_FS_Indirect',
    	'EUR_BG_Modern_Off_Trade',
    	'EUR_BG_Wholesaler',
    	'EUR_BE_Off_Trade'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_AccountVisitFrequencyService', 'FI_ACCOUNT_RECORD_TYPE_DEV_NAMES', FI_ACCOUNT_RECORD_TYPE_DEV_NAMES));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_AccountVisitFrequencyService', 'NG_ACCOUNT_RECORD_TYPE_DEV_NAMES', NG_ACCOUNT_RECORD_TYPE_DEV_NAMES));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_AccountVisitFrequencyService', 'VISIT_FREQUENCY_CRITERIA_RECORD_TYPE_DEV_NAMES', VISIT_FREQUENCY_CRITERIA_RECORD_TYPE_DEV_NAMES));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_AccountVisitFrequencyService', 'VALID_ACCOUNT_CHANNELS', VALID_ACCOUNT_CHANNELS));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_AccountVisitFrequencyService', 'VISIT_FREQUENCY_NAMES', VISIT_FREQUENCY_NAMES));
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_AccountVisitFrequencyHandler', 'ACC_RT_TO_ASSIGN_VF', ACC_RT_TO_ASSIGN_VF));
    }
    /* ========================================================= */
    /*     Create Single Account
    /* ========================================================= */
    @IsTest
    private static void createAccount_FI_Direct_Off_Trade_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency__c onceEvery6Month = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once every 6 months');
        insert onceEvery6Month;

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_Off_Trade');

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void createAccount_FI_Direct_On_Trade_OnceEvery6MonthTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency__c onceEvery6Month = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once every 6 months');
        insert onceEvery6Month;

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_On_Trade');

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceEvery6Month.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void createAccount_FI_Indirect_Off_Trade_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency__c onceEvery6Month = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once every 6 months');
        insert onceEvery6Month;

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade');

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void createAccount_FI_Indirect_On_Trade_OnceEvery6MonthTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency__c onceEvery6Month = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once every 6 months');
        insert onceEvery6Month;

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade');

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceEvery6Month.Id, account.EUR_CRM_Visit_Frequency__c);
    }

//    @IsTest
//    private static void createAccount_FI_RegularWithParentTest() {
//        EUR_CRM_Account__c parentAccount = makeAccount('EUR_FI_Direct_Off_Trade');
//        insert parentAccount;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade');
//        account.EUR_CRM_Parent_Account__c = parentAccount.Id;
//
//        Test.startTest();
//        insert account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        // TODO: why is it happened?
//        System.assertEquals(parentAccount.Id, account.EUR_CRM_Parent_Account__c);
//    }

    @IsTest
    private static void createAccount_FI_HeadOfficeWithParentTest() {
        initCMT();
        EUR_CRM_Account__c parentAccount = makeAccount('EUR_FI_Direct_Off_Trade');
        parentAccount.EUR_CRM_Business_Type__c = 'Head Office';
        insert parentAccount;

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade');
        account.EUR_CRM_Business_Type__c = 'Head Office';
        account.EUR_CRM_Parent_Account__c = parentAccount.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Parent_Account__c);
    }

    @IsTest
    private static void createAccount_NG_Off_Trade_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequencySkeleton('Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(onceQuarterVF.Id, null, null, null);
        visitFrequencyCriteria.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_NG_Visit_Frequency_Criteria_Off_Trade');
        visitFrequencyCriteria.EUR_CRM_Outlet_Classification__c = 'cls';
        visitFrequencyCriteria.EUR_CRM_Outlet_Classification_Type__c = 'cls type';
        insert visitFrequencyCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_Off_Trade_Traditional');
        account.EUR_CRM_Channel__c = 'OFF TRADE';
        account.EUR_CRM_Outlet_Classification__c = 'cls';
        account.EUR_CRM_Outlet_Classification_Type__c = 'cls type';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void createAccount_NG_On_Trade_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequencySkeleton('Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(onceQuarterVF.Id, groupOutletType.Id,  imageLevel.Id, volumePotential.Id);
        visitFrequencyCriteria.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_NG_Visit_Frequency_Criteria_On_Trade');
        insert visitFrequencyCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_On_Trade');
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void createAccount_BG_Wholesaler_Direct_OnceAWeekTest() {
        initCMT();
        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once a week'));
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 2 weeks'));
        insert visitFrequencies;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');
        account.EUR_CRM_Delivery_Type__c = 'Direct';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(visitFrequencies[0].Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void createAccount_BG_Wholesaler_Indirect_OnceAWeekTest() {
        initCMT();
        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once a week'));
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 2 weeks'));
        insert visitFrequencies;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');
        account.EUR_CRM_Delivery_Type__c = 'Indirect';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(visitFrequencies[1].Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void createAccount_GB_FS_Indirect_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequencySkeleton('Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(onceQuarterVF.Id, groupOutletType.Id, imageLevel.Id, volumePotential.Id);
        visitFrequencyCriteria.EUR_CRM_Outlet_Type__c = outletType.Id;
        insert visitFrequencyCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect');
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void createAccount_BG_Modern_Off_Trade_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequencySkeleton('Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(onceQuarterVF.Id, groupOutletType.Id, imageLevel.Id, volumePotential.Id);
        visitFrequencyCriteria.EUR_CRM_Outlet_Type__c = outletType.Id;
        insert visitFrequencyCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

//    @IsTest
//    private static void createAccount_BE_Off_Trade_CustomerTaxonomyEveryOneMonthTest() {
//        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
//        visitFrequencies.add(makeVisitFrequency('EUR_BE_Visit_Frequency', 'Once every 1 month'));
//        visitFrequencies.add(makeVisitFrequency('EUR_BE_Visit_Frequency', 'Once every 2 weeks'));
//        insert visitFrequencies;
//
//        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy');
//        customerTaxonomy.EUR_CRM_Visit_Frequency__c = visitFrequencies[0].Id;
//        insert customerTaxonomy;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_BE_Off_Trade');
//        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
//        account.EUR_CRM_Status__c = 'Acc Status';
//
//        Test.startTest();
//        insert account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        System.assertEquals(visitFrequencies[0].Id, account.EUR_CRM_Visit_Frequency__c);
//    }
//
//    @IsTest
//    private static void createAccount_BE_Off_Trade_CustomerTaxonomyEveryTwoWeeksTest() {
//        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
//        visitFrequencies.add(makeVisitFrequency('EUR_BE_Visit_Frequency', 'Once every 1 month'));
//        visitFrequencies.add(makeVisitFrequency('EUR_BE_Visit_Frequency', 'Once every 2 weeks'));
//        insert visitFrequencies;
//
//        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy');
//        customerTaxonomy.EUR_CRM_Visit_Frequency__c = visitFrequencies[1].Id;
//        insert customerTaxonomy;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_BE_Off_Trade');
//        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
//        account.EUR_CRM_Status__c = 'Acc Status';
//
//        Test.startTest();
//        insert account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        System.assertEquals(visitFrequencies[1].Id, account.EUR_CRM_Visit_Frequency__c);
//    }

    @IsTest
    private static void createAccount_BG_Modern_Off_Trade_ProspectStatus_CustomerTaxonomyTest() {
        initCMT();
        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 1 month'));
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 2 weeks'));
        insert visitFrequencies;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy');
        customerTaxonomy.Name = 'BG_OFF_Indirect KAs';
        insert customerTaxonomy;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
        account.EUR_CRM_Status__c = 'Prospect';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(visitFrequencies[0].Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void createAccount_BG_Modern_Off_Trade_ActiveStatus_CustomerTaxonomyTest() {
        initCMT();
        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 1 month'));
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 2 weeks'));
        insert visitFrequencies;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy');
        customerTaxonomy.Name = 'BG_OFF_Indirect KAs';
        insert customerTaxonomy;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
        account.EUR_CRM_Status__c = 'Active';

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(visitFrequencies[1].Id, account.EUR_CRM_Visit_Frequency__c);
    }


    /* ========================================================= */
    /*     Update Single Account
    /* ========================================================= */
    @IsTest
    private static void updateAccount_FI_Direct_Off_Trade_OnceQuarterToNullTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency__c onceEvery6Month = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once every 6 months');
        insert onceEvery6Month;

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_Off_Trade');
        account.EUR_CRM_Visit_Frequency__c = onceEvery6Month.Id;
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(onceEvery6Month.Id, account.EUR_CRM_Visit_Frequency__c);

        Test.startTest();
        account.EUR_CRM_Visit_Frequency__c = null;
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void updateAccount_FI_Direct_On_Trade_OnceEvery6MonthToNullTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency__c onceEvery6Month = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once every 6 months');
        insert onceEvery6Month;

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_On_Trade');
        account.EUR_CRM_Visit_Frequency__c = onceQuarterVF.Id;
        insert account;

        Test.startTest();
        account.EUR_CRM_Visit_Frequency__c = null;
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceEvery6Month.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void updateAccount_FI_Indirect_Off_Trade_OnceQuarterToNullTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency__c onceEvery6Month = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once every 6 months');
        insert onceEvery6Month;

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade');
        account.EUR_CRM_Visit_Frequency__c = onceEvery6Month.Id;
        insert account;

        Test.startTest();
        account.EUR_CRM_Visit_Frequency__c = null;
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void updateAccount_FI_Indirect_On_Trade_OnceEvery6MonthToNullTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency__c onceEvery6Month = makeVisitFrequency('EUR_FI_Visit_Frequency', 'Once every 6 months');
        insert onceEvery6Month;

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade');
        account.EUR_CRM_Visit_Frequency__c = onceQuarterVF.Id;
        insert account;

        Test.startTest();
        account.EUR_CRM_Visit_Frequency__c = null;
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceEvery6Month.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void updateAccount_FI_RegularWithParentToHeadOfficeTest() {
        initCMT();
        EUR_CRM_Account__c parentAccount = makeAccount('EUR_FI_Direct_Off_Trade');
        parentAccount.EUR_CRM_Business_Type__c = 'Head Office';
        insert parentAccount;

        Test.startTest();
        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade');
        account.EUR_CRM_Parent_Account__c = parentAccount.Id;
        insert account;

        account.EUR_CRM_Business_Type__c = 'Head Office';
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Parent_Account__c);
    }

//    @IsTest
//    private static void updateAccount_FI_HeadOfficeToRegularWithParentTest() {
//        EUR_CRM_Account__c parentAccount = makeAccount('EUR_FI_Direct_Off_Trade');
//        insert parentAccount;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade');
//        account.EUR_CRM_Business_Type__c = 'Head Office';
//        account.EUR_CRM_Parent_Account__c = parentAccount.Id;
//        insert account;
//
//        account.EUR_CRM_Business_Type__c = 'Regular Office';
//        account.EUR_CRM_Parent_Account__c = parentAccount.Id;
//
//        Test.startTest();
//        update account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        System.assertEquals(parentAccount.Id, account.EUR_CRM_Parent_Account__c);
//    }

    @IsTest
    private static void updateAccount_NG_Off_Trade_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequencySkeleton('Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(onceQuarterVF.Id, null, null, null);
        visitFrequencyCriteria.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_NG_Visit_Frequency_Criteria_Off_Trade');
        visitFrequencyCriteria.EUR_CRM_Outlet_Classification__c = 'cls';
        visitFrequencyCriteria.EUR_CRM_Outlet_Classification_Type__c = 'cls type 2';
        insert visitFrequencyCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_Off_Trade_Traditional');
        account.EUR_CRM_Channel__c = 'OFF TRADE';
        account.EUR_CRM_Outlet_Classification__c = 'cls';
        account.EUR_CRM_Outlet_Classification_Type__c = 'cls type';
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Visit_Frequency__c);

        account.EUR_CRM_Outlet_Classification_Type__c = 'cls type 2';

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void updateAccount_NG_On_Trade_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequencySkeleton('Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(onceQuarterVF.Id, groupOutletType.Id,  imageLevel.Id, volumePotential.Id);
        visitFrequencyCriteria.RecordTypeId = selectRecordTypeIdWhereDeveloperName('EUR_NG_Visit_Frequency_Criteria_On_Trade');
        insert visitFrequencyCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_NG_On_Trade');
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        insert account;

        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void updateAccount_BG_Wholesaler_ToDirectThenToIndirect_OnceAWeekTest() {
        initCMT();
        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once a week'));
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 2 weeks'));
        insert visitFrequencies;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');
        insert account;

        Test.startTest();
        account.EUR_CRM_Delivery_Type__c = 'Direct';
        update account;

        account = selectAccounts()[0];
        System.assertEquals(visitFrequencies[0].Id, account.EUR_CRM_Visit_Frequency__c);

        account.EUR_CRM_Delivery_Type__c = 'Indirect';
        update account;

        account = selectAccounts()[0];
        System.assertEquals(visitFrequencies[1].Id, account.EUR_CRM_Visit_Frequency__c);

        Test.stopTest();
    }

    @IsTest
    private static void updateAccount_BG_Wholesaler_ToIndirectThenToDirect_OnceAWeekTest() {
        initCMT();
        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once a week'));
        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 2 weeks'));
        insert visitFrequencies;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');
        insert account;

        Test.startTest();
        account.EUR_CRM_Delivery_Type__c = 'Indirect';
        update account;
        account = selectAccounts()[0];
        System.assertEquals(visitFrequencies[1].Id, account.EUR_CRM_Visit_Frequency__c);

        account.EUR_CRM_Delivery_Type__c = 'Direct';
        update account;

        account = selectAccounts()[0];
        System.assertEquals(visitFrequencies[0].Id, account.EUR_CRM_Visit_Frequency__c);
        Test.stopTest();
    }

    @IsTest
    private static void updateAccount_GB_FS_Indirect_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequencySkeleton('Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(onceQuarterVF.Id, groupOutletType.Id, imageLevel.Id, volumePotential.Id);
        visitFrequencyCriteria.EUR_CRM_Outlet_Type__c = outletType.Id;
        insert visitFrequencyCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect');
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Visit_Frequency__c);

        Test.startTest();
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void updateAccount_BG_Modern_Off_Trade_OnceQuarterTest() {
        initCMT();
        EUR_CRM_Visit_Frequency__c onceQuarterVF = makeVisitFrequencySkeleton('Once a quarter');
        insert onceQuarterVF;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(onceQuarterVF.Id, groupOutletType.Id, imageLevel.Id, volumePotential.Id);
        visitFrequencyCriteria.EUR_CRM_Outlet_Type__c = outletType.Id;
        insert visitFrequencyCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Visit_Frequency__c);

        Test.startTest();
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        update account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(onceQuarterVF.Id, account.EUR_CRM_Visit_Frequency__c);
    }

//    @IsTest
//    private static void updateAccount_BE_Off_Trade_CustomerTaxonomyEveryOneMonthTest() {
//        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
//        visitFrequencies.add(makeVisitFrequency('EUR_BE_Visit_Frequency', 'Once every 1 month'));
//        visitFrequencies.add(makeVisitFrequency('EUR_BE_Visit_Frequency', 'Once every 2 weeks'));
//        insert visitFrequencies;
//
//        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy');
//        customerTaxonomy.EUR_CRM_Visit_Frequency__c = visitFrequencies[0].Id;
//        insert customerTaxonomy;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_BE_Off_Trade');
//        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
//        insert account;
//
//        account = selectAccounts()[0];
//        System.assertEquals(null, account.EUR_CRM_Visit_Frequency__c);
//
//        Test.startTest();
//        account.EUR_CRM_Status__c = 'Acc Status';
//
//        update account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        System.assertEquals(visitFrequencies[0].Id, account.EUR_CRM_Visit_Frequency__c);
//    }

//    @IsTest
//    private static void updateAccount_BE_Off_Trade_CustomerTaxonomyEveryTwoWeeksTest() {
//        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
//        visitFrequencies.add(makeVisitFrequency('EUR_BE_Visit_Frequency', 'Once every 1 month'));
//        visitFrequencies.add(makeVisitFrequency('EUR_BE_Visit_Frequency', 'Once every 2 weeks'));
//        insert visitFrequencies;
//
//        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy');
//        customerTaxonomy.EUR_CRM_Visit_Frequency__c = visitFrequencies[1].Id;
//        insert customerTaxonomy;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_BE_Off_Trade');
//        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
//        insert account;
//
//        account = selectAccounts()[0];
//        System.assertEquals(null, account.EUR_CRM_Visit_Frequency__c);
//
//        Test.startTest();
//        account.EUR_CRM_Status__c = 'Acc Status';
//
//        update account;
//        Test.stopTest();
//
//        account = selectAccounts()[0];
//        System.assertEquals(visitFrequencies[1].Id, account.EUR_CRM_Visit_Frequency__c);
//    }

//    @IsTest
//    private static void updateAccount_BG_Modern_Off_Trade_ProspectStatus_CustomerTaxonomyTest() {
//        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
//        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 1 month'));
//        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 2 weeks'));
//        insert visitFrequencies;
//
//        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy');
//        customerTaxonomy.Name = 'BG_OFF_Indirect KAs';
//        insert customerTaxonomy;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
//        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
//        account.EUR_CRM_Status__c = 'Acc Status';
//        insert account;
//
//        account = selectAccounts()[0];
//        System.assertEquals(null, account.EUR_CRM_Visit_Frequency__c);
//
//        Test.startTest();
//        account.EUR_CRM_Status__c = 'Prospect';
//        update account;
//
//        account = selectAccounts()[0];
//        System.assertEquals(visitFrequencies[0].Id, account.EUR_CRM_Visit_Frequency__c);
//
//        account.EUR_CRM_Status__c = 'Active';
//        update account;
//
//        account = selectAccounts()[0];
//        System.assertEquals(visitFrequencies[1].Id, account.EUR_CRM_Visit_Frequency__c);
//        Test.stopTest();
//    }

//    @IsTest
//    private static void updateAccount_BG_Modern_Off_Trade_ActiveStatus_CustomerTaxonomyTest() {
//        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
//        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 1 month'));
//        visitFrequencies.add(makeVisitFrequency('EUR_BG_Visit_Frequency', 'Once every 2 weeks'));
//        insert visitFrequencies;
//
//        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy');
//        customerTaxonomy.Name = 'BG_OFF_Indirect KAs';
//        insert customerTaxonomy;
//
//        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
//        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
//        account.EUR_CRM_Status__c = 'Acc Status';
//        insert account;
//
//        account = selectAccounts()[0];
//        System.assertEquals(null, account.EUR_CRM_Visit_Frequency__c);
//
//        Test.startTest();
//        account.EUR_CRM_Status__c = 'Active';
//        update account;
//
//        account = selectAccounts()[0];
//        System.assertEquals(visitFrequencies[1].Id, account.EUR_CRM_Visit_Frequency__c);
//
//        account.EUR_CRM_Status__c = 'Prospect';
//        update account;
//
//        account = selectAccounts()[0];
//        System.assertEquals(visitFrequencies[0].Id, account.EUR_CRM_Visit_Frequency__c);
//        Test.stopTest();
//    }


    /* ========================================================= */

    private static EUR_CRM_Visit_Frequency__c makeVisitFrequency(String rtDevName, String name) {
        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequencySkeleton(name);
        visitFrequency.RecordTypeId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        return visitFrequency;
    }

    private static EUR_CRM_Account__c makeAccount(String rtDevName) {
        EUR_CRM_Account__c account = makeAccountSkeleton();
        account.RecordTypeId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        return account;
    }

    private static EUR_CRM_Account__c makeAccountSkeleton() {
        return new EUR_CRM_Account__c(
            Name = 'Test Account'
        ,   EUR_CRM_Postal_Code__c = '112233'
        );
    }

    private static EUR_CRM_Visit_Frequency__c makeVisitFrequencySkeleton(String name) {
        return new EUR_CRM_Visit_Frequency__c(
            Name = name
        );
    }

    private static EUR_CRM_Group_Outlet_Type__c makeGroupOutletType() {
        return new EUR_CRM_Group_Outlet_Type__c(
            EUR_CRM_Name__c = 'Restaurant'
        );
    }

    private static EUR_CRM_Outlet_Type__c makeOutletType(Id groupOutletTypeId) {
        return new EUR_CRM_Outlet_Type__c(
            EUR_CRM_Group_Outlet_Type__c = groupOutletTypeId
        ,   EUR_CRM_Name__c = 'Restaurant'
        );
    }

    private static EUR_CRM_Image_Level__c makeImageLevel() {
        return new EUR_CRM_Image_Level__c(
            EUR_CRM_Name__c = 'Leading'
        );
    }

    private static EUR_CRM_Volume_Potential__c makeVolumePotential() {
        return new EUR_CRM_Volume_Potential__c(
            EUR_CRM_Name__c = 'High'
        );
    }

    private static EUR_CRM_Visit_Frequency_Criteria__c makeVisitFrequencyCriteria(Id visitFrequencyId, Id groupOutletId,  Id imageLevelId, Id volumePotentialId) {
        return new EUR_CRM_Visit_Frequency_Criteria__c(
            EUR_CRM_Visit_Frequency__c = visitFrequencyId
        ,   EUR_CRM_Group_Outlet_Type__c = groupOutletId
        ,   EUR_CRM_Image_Level__c = imageLevelId
        ,   EUR_CRM_Volume_Potential__c = volumePotentialId
        );
    }

    private static EUR_CRM_Customer_Taxonomy__c makeCustomerTaxonomy(String rtDevName) {
        return new EUR_CRM_Customer_Taxonomy__c(
            Name = 'Taxonomy'
        ,   RecordTypeId = selectRecordTypeIdWhereDeveloperName(rtDevName)
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
            ,   EUR_CRM_Visit_Frequency__c
            ,   EUR_CRM_Parent_Account__c
            FROM EUR_CRM_Account__c
        ];
    }

}