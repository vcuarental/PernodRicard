@IsTest (IsParallel = true)
private class EUR_CRM_AssignAccountCustomerTaxonomyTst {

    private static final Map<String, String> VALID_TAXONOMY_RT_BY_ACCOUNT_RT = new Map<String, String> {
        'EUR_BG_Wholesaler'             => 'EUR_BG_Wholesalers_Customer_Taxonomy'
    ,   'EUR_BG_Traditional_Off_Trade'  => 'EUR_BG_Traditional_Off_Trade_Customer_Taxonomy'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(
            'EUR_CRM_AssignAccountCustomerTaxonomy', 'VALID_TAXONOMY_RT_BY_ACCOUNT_RT', VALID_TAXONOMY_RT_BY_ACCOUNT_RT));
    }
    @IsTest
    private static void createAccount_EUR_BG_Wholesaler_Test() {
        initCMT();
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = new List<EUR_CRM_Customer_Taxonomy__c>();
        customerTaxonomies.add(makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy'));
        customerTaxonomies.add(makeCustomerTaxonomy('EUR_BG_Traditional_Off_Trade_Customer_Taxonomy'));
        insert customerTaxonomies;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(customerTaxonomies[0].Id, account.EUR_JB_Customer_Taxonomy__c);
    }

    @IsTest
    private static void createAccount_EUR_BG_Traditional_Off_Trade_Test() {
        initCMT();
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = new List<EUR_CRM_Customer_Taxonomy__c>();
        customerTaxonomies.add(makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy'));
        customerTaxonomies.add(makeCustomerTaxonomy('EUR_BG_Traditional_Off_Trade_Customer_Taxonomy'));
        insert customerTaxonomies;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Traditional_Off_Trade');

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(customerTaxonomies[1].Id, account.EUR_JB_Customer_Taxonomy__c);
    }

    @IsTest
    private static void createAccount_EUR_BG_Wholesaler_WithoutTaxonomyTest() {
        initCMT();
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = new List<EUR_CRM_Customer_Taxonomy__c>();
        customerTaxonomies.add(makeCustomerTaxonomy('EUR_BG_Traditional_Off_Trade_Customer_Taxonomy'));
        insert customerTaxonomies;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_JB_Customer_Taxonomy__c);
    }

    @IsTest
    private static void createAccount_EUR_BG_Traditional_Off_Trade_WithoutTaxonomyTest() {
        initCMT();
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = new List<EUR_CRM_Customer_Taxonomy__c>();
        customerTaxonomies.add(makeCustomerTaxonomy('EUR_BG_Wholesalers_Customer_Taxonomy'));
        insert customerTaxonomies;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Traditional_Off_Trade');

        Test.startTest();
        insert account;
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_JB_Customer_Taxonomy__c);
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Customer_Taxonomy__c makeCustomerTaxonomy(String rtDevName) {
        return new EUR_CRM_Customer_Taxonomy__c(
            Name = 'Taxonomy'
        ,   RecordTypeId = selectRecordTypeIdWhereDeveloperName(rtDevName)
        );
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
            ,   EUR_JB_Customer_Taxonomy__c
            ,   EUR_CRM_Chain__c
            ,   EUR_CRM_Taxonomy_Level_1__c
            ,   EUR_CRM_Taxonomy_Level_2__c
            FROM EUR_CRM_Account__c
        ];
    }

}