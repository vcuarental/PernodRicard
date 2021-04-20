@IsTest (IsParallel = true)
private class EUR_CRM_TemplateAssignmentHandler_Test {


    /* ========================================================= */
    /*     Create Single Account
    /* ========================================================= */
    @IsTest
    private static void createSingleAccountWithAllRequiredDataJBTemplateCriteriaTest() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(jbTemplate.Id, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void createSingleAccountWithoutGroupOutletTypeJBTemplateCriteriaTest() {
        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, null, null, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, null, null, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', null, null, imageLevel.Id, volumePotential.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void createSingleAccountWithoutOutletTypeJBTemplateCriteriaTest() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void createSingleAccountWithoutImageLevelJBTemplateCriteriaTest() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, null, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, null, volumePotential.Id);
        insert jbTemplateCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', groupOutletType.Id, outletType.Id, null, volumePotential.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void createSingleAccountWithoutVolumePotentialJBTemplateCriteriaTest() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, null);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, null);
        insert jbTemplateCriteria;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', groupOutletType.Id, outletType.Id, imageLevel.Id, null);

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void createSingleAccountWithAllRequiredDataCustomerTaxonomyTest() {
        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy(jbTemplate.Id);
        insert customerTaxonomy;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', customerTaxonomy.Id);

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(jbTemplate.Id, accounts[0].EUR_JB_Default_Template__c);
    }


    /* ========================================================= */
    /*     Update Single Account
    /* ========================================================= */
    @IsTest
    private static void updateSingleAccountWithAllRequiredDataJBTemplateCriteriaTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', null);
        insert account;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(jbTemplate.Id, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void updateSingleAccountWithoutGroupOutletTypeJBTemplateCriteriaTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', null);
        insert account;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, null, null, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, null, null, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void updateSingleAccountWithoutOutletTypeJBTemplateCriteriaTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', null);
        insert account;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void updateSingleAccountWithoutImageLevelJBTemplateCriteriaTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', null);
        insert account;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, null, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, null, volumePotential.Id);
        insert jbTemplateCriteria;

        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Volume_Potential__c = volumePotential.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void updateSingleAccountWithoutVolumePotentialJBTemplateCriteriaTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', null);
        insert account;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, null);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, null);
        insert jbTemplateCriteria;

        account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        account.EUR_CRM_Outlet_Type__c = outletType.Id;
        account.EUR_CRM_Image_Level__c = imageLevel.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);
    }

    @IsTest
    private static void updateSingleAccountWithAllRequiredDataCustomerTaxonomyTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect', null);
        insert account;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(null, accounts[0].EUR_JB_Default_Template__c);

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy(jbTemplate.Id);
        insert customerTaxonomy;

        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;

        Test.startTest();
        update account;
        Test.stopTest();

        accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(jbTemplate.Id, accounts[0].EUR_JB_Default_Template__c);
    }


    /* ========================================================= */
    /*     Create Multiple Accounts
    /* ========================================================= */
    @IsTest
    private static void createMultipleAccountsWithAllRequiredDataJBTemplateCriteriaTest() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect', groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);

        Test.startTest();
        insert accounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(jbTemplate.Id, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void createMultipleAccountsWithAllRequiredMultipleDataJBTemplateCriteriaTest() {
        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = makeGroupOutletTypes();
        insert groupOutletTypes;

        List<EUR_CRM_Outlet_Type__c> outletTypes = makeOutletTypes(groupOutletTypes);
        insert outletTypes;

        List<EUR_CRM_Image_Level__c> imageLevels = makeImageLevels();
        insert imageLevels;

        List<EUR_CRM_Volume_Potential__c> volumePotentials = makeVolumePotentials();
        insert volumePotentials;

        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = makeVisitFrequencies();
        insert visitFrequencies;

        List<EUR_CRM_Visit_Frequency_Criteria__c> visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequencies, groupOutletTypes, outletTypes, imageLevels, volumePotentials);
        insert visitFrequencyCriteria;

        List<EUR_CRM_JB_Template__c> jbTemplates = makeJBTemplates('GB Template');
        insert jbTemplates;

        List<EUR_CRM_JB_Template_Criteria__c> jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplates, groupOutletTypes, outletTypes, imageLevels, volumePotentials);
        insert jbTemplateCriteria;

        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect', groupOutletTypes, outletTypes, imageLevels, volumePotentials);

        Test.startTest();
        insert accounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (Integer i = 0; i < accountsAfter.size(); i++) {
            System.assertEquals(jbTemplates[i].Id, accountsAfter[i].EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void createMultipleAccountsWithoutGroupOutletTypeJBTemplateCriteriaTest() {
        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, null, null, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, null, null, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect', null, null, imageLevel.Id, volumePotential.Id);

        Test.startTest();
        insert accounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void createMultipleAccountsWithoutOutletTypeJBTemplateCriteriaTest() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect', groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);

        Test.startTest();
        insert accounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void createMultipleAccountsWithoutImageLevelJBTemplateCriteriaTest() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, null, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, null, volumePotential.Id);
        insert jbTemplateCriteria;

        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect', groupOutletType.Id, outletType.Id, null, volumePotential.Id);

        Test.startTest();
        insert accounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void createMultipleAccountsWithoutVolumePotentialJBTemplateCriteriaTest() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, null);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, null);
        insert jbTemplateCriteria;

        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect', groupOutletType.Id, outletType.Id, imageLevel.Id, null);

        Test.startTest();
        insert accounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void createSingleAccountWithAllRequiredDataMultipleCustomerTaxonomyTest() {
        List<EUR_CRM_JB_Template__c> jbTemplates = makeJBTemplates('GB Template');
        insert jbTemplates;

        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = makeCustomerTaxonomies(jbTemplates);
        insert customerTaxonomies;

        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect', customerTaxonomies);

        Test.startTest();
        insert accounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (Integer i = 0; i < accountsAfter.size(); i++) {
            System.assertEquals(jbTemplates[i].Id, accountsAfter[i].EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void createMultipleAccountsWithAllRequiredMultipleDataJBTemplateCriteriaAndCustomerTaxonomyTest() {
        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = makeGroupOutletTypes();
        insert groupOutletTypes;

        List<EUR_CRM_Outlet_Type__c> outletTypes = makeOutletTypes(groupOutletTypes);
        insert outletTypes;

        List<EUR_CRM_Image_Level__c> imageLevels = makeImageLevels();
        insert imageLevels;

        List<EUR_CRM_Volume_Potential__c> volumePotentials = makeVolumePotentials();
        insert volumePotentials;

        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = makeVisitFrequencies();
        insert visitFrequencies;

        List<EUR_CRM_Visit_Frequency_Criteria__c> visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequencies, groupOutletTypes, outletTypes, imageLevels, volumePotentials);
        insert visitFrequencyCriteria;

        List<EUR_CRM_JB_Template__c> jbTemplates = makeJBTemplates('GB Template');
        insert jbTemplates;

        List<EUR_CRM_JB_Template_Criteria__c> jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplates, groupOutletTypes, outletTypes, imageLevels, volumePotentials);
        insert jbTemplateCriteria;

        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect', groupOutletTypes, outletTypes, imageLevels, volumePotentials);

        List<EUR_CRM_JB_Template__c> jbTemplatesForTaxonomy = makeJBTemplates('GB Template');
        insert jbTemplatesForTaxonomy;

        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = makeCustomerTaxonomies(jbTemplatesForTaxonomy);
        insert customerTaxonomies;

        for (Integer i = 0; i < accounts.size(); i++) {
            accounts[i].EUR_JB_Customer_Taxonomy__c = customerTaxonomies[i].Id;
        }

        Test.startTest();
        insert accounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (Integer i = 0; i < accountsAfter.size(); i++) {
            System.assertEquals(jbTemplates[i].Id, accountsAfter[i].EUR_JB_Default_Template__c);
        }
    }


    /* ========================================================= */
    /*     Update Multiple Accounts
    /* ========================================================= */
    @IsTest
    private static void updateMultipleAccountsWithAllRequiredDataJBTemplateCriteriaTest() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect');
        insert accounts;

        List<EUR_CRM_Account__c> accountsBefore = selectAccounts();
        System.assertEquals(5, accountsBefore.size());
        for (EUR_CRM_Account__c account : accountsBefore) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        for (EUR_CRM_Account__c account : accountsBefore) {
            account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
            account.EUR_CRM_Outlet_Type__c = outletType.Id;
            account.EUR_CRM_Image_Level__c = imageLevel.Id;
            account.EUR_CRM_Volume_Potential__c = volumePotential.Id;
        }

        Test.startTest();
        update accountsBefore;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(jbTemplate.Id, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void updateMultipleAccountsWithAllRequiredMultipleDataJBTemplateCriteriaTest() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect');
        insert accounts;

        List<EUR_CRM_Account__c> accountsBefore = selectAccounts();
        System.assertEquals(5, accountsBefore.size());
        for (EUR_CRM_Account__c account : accountsBefore) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }

        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = makeGroupOutletTypes();
        insert groupOutletTypes;

        List<EUR_CRM_Outlet_Type__c> outletTypes = makeOutletTypes(groupOutletTypes);
        insert outletTypes;

        List<EUR_CRM_Image_Level__c> imageLevels = makeImageLevels();
        insert imageLevels;

        List<EUR_CRM_Volume_Potential__c> volumePotentials = makeVolumePotentials();
        insert volumePotentials;

        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = makeVisitFrequencies();
        insert visitFrequencies;

        List<EUR_CRM_Visit_Frequency_Criteria__c> visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequencies, groupOutletTypes, outletTypes, imageLevels, volumePotentials);
        insert visitFrequencyCriteria;

        List<EUR_CRM_JB_Template__c> jbTemplates = makeJBTemplates('GB Template');
        insert jbTemplates;

        List<EUR_CRM_JB_Template_Criteria__c> jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplates, groupOutletTypes, outletTypes, imageLevels, volumePotentials);
        insert jbTemplateCriteria;

        for (Integer i = 0; i < accountsBefore.size(); i++) {
            accountsBefore[i].EUR_CRM_Group_Outlet_Type__c = groupOutletTypes[i].Id;
            accountsBefore[i].EUR_CRM_Outlet_Type__c = outletTypes[i].Id;
            accountsBefore[i].EUR_CRM_Image_Level__c = imageLevels[i].Id;
            accountsBefore[i].EUR_CRM_Volume_Potential__c = volumePotentials[i].Id;
        }

        Test.startTest();
        update accountsBefore;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (Integer i = 0; i < accountsAfter.size(); i++) {
            System.assertEquals(jbTemplates[i].Id, accountsAfter[i].EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void updateMultipleAccountsWithoutGroupOutletTypeJBTemplateCriteriaTest() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect');
        insert accounts;

        List<EUR_CRM_Account__c> accountsBefore = selectAccounts();
        System.assertEquals(5, accountsBefore.size());
        for (EUR_CRM_Account__c account : accountsBefore) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, null, null, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, null, null, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        for (EUR_CRM_Account__c account : accountsBefore) {
            account.EUR_CRM_Image_Level__c = imageLevel.Id;
            account.EUR_CRM_Volume_Potential__c = volumePotential.Id;
        }

        Test.startTest();
        update accountsBefore;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void updateMultipleAccountsWithoutOutletTypeJBTemplateCriteriaTest() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect');
        insert accounts;

        List<EUR_CRM_Account__c> accountsBefore = selectAccounts();
        System.assertEquals(5, accountsBefore.size());
        for (EUR_CRM_Account__c account : accountsBefore) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, null, imageLevel.Id, volumePotential.Id);
        insert jbTemplateCriteria;

        for (EUR_CRM_Account__c account : accountsBefore) {
            account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
            account.EUR_CRM_Image_Level__c = imageLevel.Id;
            account.EUR_CRM_Volume_Potential__c = volumePotential.Id;
        }

        Test.startTest();
        update accountsBefore;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void updateMultipleAccountsWithoutImageLevelJBTemplateCriteriaTest() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect');
        insert accounts;

        List<EUR_CRM_Account__c> accountsBefore = selectAccounts();
        System.assertEquals(5, accountsBefore.size());
        for (EUR_CRM_Account__c account : accountsBefore) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Volume_Potential__c volumePotential = makeVolumePotential();
        insert volumePotential;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, null, volumePotential.Id);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, null, volumePotential.Id);
        insert jbTemplateCriteria;

        for (EUR_CRM_Account__c account : accountsBefore) {
            account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
            account.EUR_CRM_Outlet_Type__c = outletType.Id;
            account.EUR_CRM_Volume_Potential__c = volumePotential.Id;
        }

        Test.startTest();
        update accountsBefore;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void updateMultipleAccountsWithoutVolumePotentialJBTemplateCriteriaTest() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect');
        insert accounts;

        List<EUR_CRM_Account__c> accountsBefore = selectAccounts();
        System.assertEquals(5, accountsBefore.size());
        for (EUR_CRM_Account__c account : accountsBefore) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        insert groupOutletType;

        EUR_CRM_Outlet_Type__c outletType = makeOutletType(groupOutletType.Id);
        insert outletType;

        EUR_CRM_Image_Level__c imageLevel = makeImageLevel();
        insert imageLevel;

        EUR_CRM_Visit_Frequency__c visitFrequency = makeVisitFrequency();
        insert visitFrequency;

        EUR_CRM_Visit_Frequency_Criteria__c visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequency.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, null);
        insert visitFrequencyCriteria;

        EUR_CRM_JB_Template__c jbTemplate = makeJBTemplate('GB Template');
        insert jbTemplate;

        EUR_CRM_JB_Template_Criteria__c jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplate.Id, groupOutletType.Id, outletType.Id, imageLevel.Id, null);
        insert jbTemplateCriteria;

        for (EUR_CRM_Account__c account : accountsBefore) {
            account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
            account.EUR_CRM_Outlet_Type__c = outletType.Id;
            account.EUR_CRM_Image_Level__c = imageLevel.Id;
        }

        Test.startTest();
        update accountsBefore;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (EUR_CRM_Account__c account : accountsAfter) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void updateSingleAccountWithAllRequiredDataMultipleCustomerTaxonomyTest() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect');
        insert accounts;

        List<EUR_CRM_Account__c> accountsBefore = selectAccounts();
        System.assertEquals(5, accountsBefore.size());
        for (EUR_CRM_Account__c account : accountsBefore) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }

        List<EUR_CRM_JB_Template__c> jbTemplates = makeJBTemplates('GB Template');
        insert jbTemplates;

        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = makeCustomerTaxonomies(jbTemplates);
        insert customerTaxonomies;

        for (Integer i = 0; i < accountsBefore.size(); i++) {
            accountsBefore[i].EUR_JB_Customer_Taxonomy__c = customerTaxonomies[i].Id;
        }

        Test.startTest();
        update accountsBefore;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (Integer i = 0; i < accountsAfter.size(); i++) {
            System.assertEquals(jbTemplates[i].Id, accountsAfter[i].EUR_JB_Default_Template__c);
        }
    }

    @IsTest
    private static void updateMultipleAccountsWithAllRequiredMultipleDataJBTemplateCriteriaAndCustomerTaxonomyTest() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('EUR_GB_FS_Indirect');
        insert accounts;

        List<EUR_CRM_Account__c> accountsBefore = selectAccounts();
        System.assertEquals(5, accountsBefore.size());
        for (EUR_CRM_Account__c account : accountsBefore) {
            System.assertEquals(null, account.EUR_JB_Default_Template__c);
        }

        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = makeGroupOutletTypes();
        insert groupOutletTypes;

        List<EUR_CRM_Outlet_Type__c> outletTypes = makeOutletTypes(groupOutletTypes);
        insert outletTypes;

        List<EUR_CRM_Image_Level__c> imageLevels = makeImageLevels();
        insert imageLevels;

        List<EUR_CRM_Volume_Potential__c> volumePotentials = makeVolumePotentials();
        insert volumePotentials;

        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = makeVisitFrequencies();
        insert visitFrequencies;

        List<EUR_CRM_Visit_Frequency_Criteria__c> visitFrequencyCriteria = makeVisitFrequencyCriteria(visitFrequencies, groupOutletTypes, outletTypes, imageLevels, volumePotentials);
        insert visitFrequencyCriteria;

        List<EUR_CRM_JB_Template__c> jbTemplates = makeJBTemplates('GB Template');
        insert jbTemplates;

        List<EUR_CRM_JB_Template_Criteria__c> jbTemplateCriteria = makeJBTemplateCriteria('GB Template Criteria', jbTemplates, groupOutletTypes, outletTypes, imageLevels, volumePotentials);
        insert jbTemplateCriteria;

        List<EUR_CRM_JB_Template__c> jbTemplatesForTaxonomy = makeJBTemplates('GB Template');
        insert jbTemplatesForTaxonomy;

        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = makeCustomerTaxonomies(jbTemplatesForTaxonomy);
        insert customerTaxonomies;

        for (Integer i = 0; i < accountsBefore.size(); i++) {
            accountsBefore[i].EUR_CRM_Group_Outlet_Type__c = groupOutletTypes[i].Id;
            accountsBefore[i].EUR_CRM_Outlet_Type__c = outletTypes[i].Id;
            accountsBefore[i].EUR_CRM_Image_Level__c = imageLevels[i].Id;
            accountsBefore[i].EUR_CRM_Volume_Potential__c = volumePotentials[i].Id;
            accountsBefore[i].EUR_JB_Customer_Taxonomy__c = customerTaxonomies[i].Id;
        }
        Test.startTest();
        update accountsBefore;
        Test.stopTest();

        List<EUR_CRM_Account__c> accountsAfter = selectAccounts();
        System.assertEquals(5, accountsAfter.size());
        for (Integer i = 0; i < accountsAfter.size(); i++) {
            System.assertEquals(jbTemplates[i].Id, accountsAfter[i].EUR_JB_Default_Template__c);
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> makeAccounts(String rtDevName, Id groupOutletId, Id outletTypeId, Id imageLevelId, Id volumePotentialId) {
        Id rtId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(makeAccount(rtId, groupOutletId, outletTypeId, imageLevelId, volumePotentialId));
        }
        return accounts;
    }

    private static List<EUR_CRM_Account__c> makeAccounts(String rtDevName, List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes, List<EUR_CRM_Outlet_Type__c> outletTypes, List<EUR_CRM_Image_Level__c> imageLevels, List<EUR_CRM_Volume_Potential__c> volumePotentials) {
        Id rtId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(makeAccount(rtId, groupOutletTypes[i].Id, outletTypes[i].Id, imageLevels[i].Id, volumePotentials[i].Id));
        }
        return accounts;
    }

    private static List<EUR_CRM_Account__c> makeAccounts(String rtDevName, List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies) {
        Id rtId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Customer_Taxonomy__c customerTaxonomy : customerTaxonomies) {
            accounts.add(makeAccount(rtId, customerTaxonomy.Id));
        }
        return accounts;
    }

    private static List<EUR_CRM_Account__c> makeAccounts(String rtDevName) {
        Id rtId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(makeAccount(rtId, null));
        }
        return accounts;
    }

    private static List<EUR_CRM_Group_Outlet_Type__c> makeGroupOutletTypes() {
        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_Group_Outlet_Type__c>();
        for (Integer i = 0; i < 5; i++) {
            groupOutletTypes.add(makeGroupOutletType());
        }
        return groupOutletTypes;
    }

    private static List<EUR_CRM_Outlet_Type__c> makeOutletTypes(List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes) {
        List<EUR_CRM_Outlet_Type__c> outletTypes = new List<EUR_CRM_Outlet_Type__c>();
        for (EUR_CRM_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
            outletTypes.add(makeOutletType(groupOutletType.Id));
        }
        return outletTypes;
    }

    private static List<EUR_CRM_Image_Level__c> makeImageLevels() {
        List<EUR_CRM_Image_Level__c> imageLevels = new List<EUR_CRM_Image_Level__c>();
        for (Integer i = 0; i < 5; i++) {
            imageLevels.add(makeImageLevel());
        }
        return imageLevels;
    }

    private static List<EUR_CRM_Volume_Potential__c> makeVolumePotentials() {
        List<EUR_CRM_Volume_Potential__c> volumePotentials = new List<EUR_CRM_Volume_Potential__c>();
        for (Integer i = 0; i < 5; i++) {
            volumePotentials.add(makeVolumePotential());
        }
        return volumePotentials;
    }

    private static List<EUR_CRM_Visit_Frequency__c> makeVisitFrequencies() {
        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
        for (Integer i = 0; i < 5; i++) {
            visitFrequencies.add(makeVisitFrequency());
        }
        return visitFrequencies;
    }

    private static List<EUR_CRM_Visit_Frequency_Criteria__c> makeVisitFrequencyCriteria(List<EUR_CRM_Visit_Frequency__c> visitFrequencies, List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes, List<EUR_CRM_Outlet_Type__c> outletTypes, List<EUR_CRM_Image_Level__c> imageLevels, List<EUR_CRM_Volume_Potential__c> volumePotentials) {
        List<EUR_CRM_Visit_Frequency_Criteria__c> visitFrequencyCriteria = new List<EUR_CRM_Visit_Frequency_Criteria__c>();
        for (Integer i = 0; i < 5; i++) {
            visitFrequencyCriteria.add(makeVisitFrequencyCriteria(visitFrequencies[i].Id, groupOutletTypes[i].Id, outletTypes[i].Id, imageLevels[i].Id, volumePotentials[i].Id));
        }
        return visitFrequencyCriteria;
    }

    private static List<EUR_CRM_JB_Template__c> makeJBTemplates(String rtName) {
        List<EUR_CRM_JB_Template__c> templates = new List<EUR_CRM_JB_Template__c>();
        for (Integer i = 0; i < 5; i++) {
            templates.add(makeJBTemplate(rtName));
        }
        return templates;
    }

    private static List<EUR_CRM_JB_Template_Criteria__c> makeJBTemplateCriteria(String rtName, List<EUR_CRM_JB_Template__c> templates, List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes, List<EUR_CRM_Outlet_Type__c> outletTypes, List<EUR_CRM_Image_Level__c> imageLevels, List<EUR_CRM_Volume_Potential__c> volumePotentials) {
        List<EUR_CRM_JB_Template_Criteria__c> templateCriteria = new List<EUR_CRM_JB_Template_Criteria__c>();
        for (Integer i = 0; i < 5; i++) {
            templateCriteria.add(makeJBTemplateCriteria(rtName, templates[i].Id, groupOutletTypes[i].Id, outletTypes[i].Id, imageLevels[i].Id, volumePotentials[i].Id));
        }
        return templateCriteria;
    }

    private static List<EUR_CRM_Customer_Taxonomy__c> makeCustomerTaxonomies(List<EUR_CRM_JB_Template__c> templates) {
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomies = new List<EUR_CRM_Customer_Taxonomy__c>();
        for (EUR_CRM_JB_Template__c template : templates) {
            customerTaxonomies.add(makeCustomerTaxonomy(template.Id));
        }
        return customerTaxonomies;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String rtDevName, Id groupOutletId, Id outletTypeId, Id imageLevelId, Id volumePotentialId) {
        EUR_CRM_Account__c account = makeAccountSkeleton();
        account.RecordTypeId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletId;
        account.EUR_CRM_Outlet_Type__c = outletTypeId;
        account.EUR_CRM_Image_Level__c = imageLevelId;
        account.EUR_CRM_Volume_Potential__c = volumePotentialId;
        return account;
    }

    private static EUR_CRM_Account__c makeAccount(Id rtId, Id groupOutletId, Id outletTypeId, Id imageLevelId, Id volumePotentialId) {
        EUR_CRM_Account__c account = makeAccountSkeleton();
        account.RecordTypeId = rtId;
        account.EUR_CRM_Group_Outlet_Type__c = groupOutletId;
        account.EUR_CRM_Outlet_Type__c = outletTypeId;
        account.EUR_CRM_Image_Level__c = imageLevelId;
        account.EUR_CRM_Volume_Potential__c = volumePotentialId;
        return account;
    }

    private static EUR_CRM_Account__c makeAccount(String rtDevName, Id customerTaxonomyId) {
        EUR_CRM_Account__c account = makeAccountSkeleton();
        account.RecordTypeId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomyId;
        return account;
    }

    private static EUR_CRM_Account__c makeAccount(Id rtId, Id customerTaxonomyId) {
        EUR_CRM_Account__c account = makeAccountSkeleton();
        account.RecordTypeId = rtId;
        account.EUR_JB_Customer_Taxonomy__c = customerTaxonomyId;
        return account;
    }

    private static EUR_CRM_Account__c makeAccountSkeleton() {
        return new EUR_CRM_Account__c(
            Name = 'GB test on trade account'
        ,   EUR_CRM_Postal_Code__c = '112233'
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

    private static EUR_CRM_Visit_Frequency__c makeVisitFrequency() {
        return new EUR_CRM_Visit_Frequency__c(
            Name = 'once a week'
        );
    }

    private static EUR_CRM_Visit_Frequency_Criteria__c makeVisitFrequencyCriteria(Id visitFrequencyId, Id groupOutletId, Id outletTypeId, Id imageLevelId, Id volumePotentialId) {
        return new EUR_CRM_Visit_Frequency_Criteria__c(
            EUR_CRM_Visit_Frequency__c = visitFrequencyId
        ,   EUR_CRM_Group_Outlet_Type__c = groupOutletId
        ,   EUR_CRM_Outlet_Type__c = outletTypeId
        ,   EUR_CRM_Image_Level__c = imageLevelId
        ,   EUR_CRM_Volume_Potential__c = volumePotentialId
        );
    }

    private static EUR_CRM_JB_Template__c makeJBTemplate(String rtName) {
        return new EUR_CRM_JB_Template__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_JB_Template__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId()
        ,   Name = 'JB Template Name'
        );
    }

    private static EUR_CRM_JB_Template_Criteria__c makeJBTemplateCriteria(String rtName, Id jbTemplateId, Id groupOutletId, Id outletTypeId, Id imageLevelId, Id volumePotentialId) {
        return new EUR_CRM_JB_Template_Criteria__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_JB_Template_Criteria__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId()
        ,   EUR_JB_Template__c = jbTemplateId
        ,   EUR_JB_Active__c = true
        ,   EUR_JB_Group_Outlet_Type__c = groupOutletId
        ,   EUR_JB_Outlet_Type__c = outletTypeId
        ,   EUR_JB_Image_Level__c = imageLevelId
        ,   EUR_JB_Volume_Potential__c = volumePotentialId
        );
    }

    private static EUR_CRM_Customer_Taxonomy__c makeCustomerTaxonomy(Id jbTemplateId) {
        return new EUR_CRM_Customer_Taxonomy__c(
            Name = 'Customer Taxonomy'
        ,   EUR_JB_Template__c = jbTemplateId
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static Id selectRecordTypeIdWhereDeveloperName(String rtDevName) {
        return [
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE DeveloperName = :rtDevName
            LIMIT 1
        ][0].Id;
    }

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,   EUR_JB_Default_Template__c
            FROM EUR_CRM_Account__c
        ];
    }

}