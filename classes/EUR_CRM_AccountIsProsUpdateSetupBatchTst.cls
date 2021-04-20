@IsTest (IsParallel = true)
private class EUR_CRM_AccountIsProsUpdateSetupBatchTst {

//    private static final Integer COUNT_OF_RECORDS = 5;


    /* ========================================================= */
    /*     Simple Tests
    /* ========================================================= */
    @IsTest
    private static void simpleImageCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        groupOutletType.EUR_CRM_Image_Criteria_Set__c = criteriaSet.Id;
        insert groupOutletType;

        EUR_CRM_Account__c account = makeAccount(groupOutletType.Id, null);
        insert account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
        Test.stopTest();

        account = selectAccounts()[0];
        //System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
    }

    @IsTest
    private static void simpleVolumeCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        groupOutletType.EUR_CRM_Volume_Criteria_Set__c = criteriaSet.Id;
        insert groupOutletType;

        EUR_CRM_Account__c account = makeAccount(groupOutletType.Id, null);
        insert account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
        Test.stopTest();

        account = selectAccounts()[0];
        //System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
    }

    @IsTest
    private static void simpleBrandBuildPotQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType = makePRSGroupOutletType();
        prsGroupOutletType.EUR_CRM_BrandBuildPotQuestionSet__c = questionSet.Id;
        insert prsGroupOutletType;

        EUR_CRM_Account__c account = makeAccount(null, prsGroupOutletType.Id);
        insert account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
    }

    @IsTest
    private static void simpleBusinessPotentialQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType = makePRSGroupOutletType();
        prsGroupOutletType.EUR_CRM_BusinessPotentialQuestionSet__c = questionSet.Id;
        insert prsGroupOutletType;

        EUR_CRM_Account__c account = makeAccount(null, prsGroupOutletType.Id);
        insert account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
    }

    @IsTest
    private static void simpleImageLevelQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType = makePRSGroupOutletType();
        prsGroupOutletType.EUR_CRM_Image_Level_Question_Set__c = questionSet.Id;
        insert prsGroupOutletType;

        EUR_CRM_Account__c account = makeAccount(null, prsGroupOutletType.Id);
        insert account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
    }

    @IsTest
    private static void simpleVolumePotentialQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType = makePRSGroupOutletType();
        prsGroupOutletType.EUR_CRM_Volume_Potential_Question_Set__c = questionSet.Id;
        insert prsGroupOutletType;

        EUR_CRM_Account__c account = makeAccount(null, prsGroupOutletType.Id);
        insert account;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
        Test.stopTest();

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
    }


    /* ========================================================= */
    /*     Complicated Tests (only for "local" tests)
    /* ========================================================= */
//    @IsTest
//    private static void complicatedImageCriteriaSetTest() {
//        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets(COUNT_OF_RECORDS);
//        insert criteriaSets;
//
//        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_Group_Outlet_Type__c>();
//        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
//            for (EUR_CRM_Group_Outlet_Type__c groupOutletType : makeGroupOutletTypes(COUNT_OF_RECORDS)) {
//                groupOutletType.EUR_CRM_Image_Criteria_Set__c = criteriaSet.Id;
//                groupOutletTypes.add(groupOutletType);
//            }
//        }
//        insert groupOutletTypes;
//
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            accounts.addAll(makeAccounts(COUNT_OF_RECORDS, groupOutletType.Id, null));
//        }
//        insert accounts;
//
//        Test.startTest();
//        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
//        Test.stopTest();
//
//        accounts = selectAccounts();
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS * COUNT_OF_RECORDS, accounts.size());
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//        }
//    }
//
//    @IsTest
//    private static void complicatedVolumeCriteriaSetTest() {
//        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets(COUNT_OF_RECORDS);
//        insert criteriaSets;
//
//        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_Group_Outlet_Type__c>();
//        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
//            for (EUR_CRM_Group_Outlet_Type__c groupOutletType : makeGroupOutletTypes(COUNT_OF_RECORDS)) {
//                groupOutletType.EUR_CRM_Volume_Criteria_Set__c = criteriaSet.Id;
//                groupOutletTypes.add(groupOutletType);
//            }
//        }
//        insert groupOutletTypes;
//
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            accounts.addAll(makeAccounts(COUNT_OF_RECORDS, groupOutletType.Id, null));
//        }
//        insert accounts;
//
//        Test.startTest();
//        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
//        Test.stopTest();
//
//        accounts = selectAccounts();
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS * COUNT_OF_RECORDS, accounts.size());
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//        }
//    }
//
//    @IsTest
//    private static void complicatedBrandBuildPotQuestionSetTest() {
//        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets(COUNT_OF_RECORDS);
//        insert questionSets;
//
//        List<EUR_CRM_PRS_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : makePRSGroupOutletTypes(COUNT_OF_RECORDS)) {
//                groupOutletType.EUR_CRM_BrandBuildPotQuestionSet__c = questionSet.Id;
//                groupOutletTypes.add(groupOutletType);
//            }
//        }
//        insert groupOutletTypes;
//
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            accounts.addAll(makeAccounts(COUNT_OF_RECORDS, null, groupOutletType.Id));
//        }
//        insert accounts;
//
//        Test.startTest();
//        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
//        Test.stopTest();
//
//        accounts = selectAccounts();
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS * COUNT_OF_RECORDS, accounts.size());
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//        }
//    }
//
//    @IsTest
//    private static void complicatedBusinessPotentialQuestionSetTest() {
//        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets(COUNT_OF_RECORDS);
//        insert questionSets;
//
//        List<EUR_CRM_PRS_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : makePRSGroupOutletTypes(COUNT_OF_RECORDS)) {
//                groupOutletType.EUR_CRM_BusinessPotentialQuestionSet__c = questionSet.Id;
//                groupOutletTypes.add(groupOutletType);
//            }
//        }
//        insert groupOutletTypes;
//
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            accounts.addAll(makeAccounts(COUNT_OF_RECORDS, null, groupOutletType.Id));
//        }
//        insert accounts;
//
//        Test.startTest();
//        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
//        Test.stopTest();
//
//        accounts = selectAccounts();
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS * COUNT_OF_RECORDS, accounts.size());
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//        }
//    }
//
//    @IsTest
//    private static void complicatedImageLevelQuestionSetTest() {
//        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets(COUNT_OF_RECORDS);
//        insert questionSets;
//
//        List<EUR_CRM_PRS_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : makePRSGroupOutletTypes(COUNT_OF_RECORDS)) {
//                groupOutletType.EUR_CRM_Image_Level_Question_Set__c = questionSet.Id;
//                groupOutletTypes.add(groupOutletType);
//            }
//        }
//        insert groupOutletTypes;
//
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            accounts.addAll(makeAccounts(COUNT_OF_RECORDS, null, groupOutletType.Id));
//        }
//        insert accounts;
//
//        Test.startTest();
//        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
//        Test.stopTest();
//
//        accounts = selectAccounts();
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS * COUNT_OF_RECORDS, accounts.size());
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//        }
//    }
//
//    @IsTest
//    private static void complicatedVolumePotentialQuestionSetTest() {
//        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets(COUNT_OF_RECORDS);
//        insert questionSets;
//
//        List<EUR_CRM_PRS_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : makePRSGroupOutletTypes(COUNT_OF_RECORDS)) {
//                groupOutletType.EUR_CRM_Volume_Potential_Question_Set__c = questionSet.Id;
//                groupOutletTypes.add(groupOutletType);
//            }
//        }
//        insert groupOutletTypes;
//
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            accounts.addAll(makeAccounts(COUNT_OF_RECORDS, null, groupOutletType.Id));
//        }
//        insert accounts;
//
//        Test.startTest();
//        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 200);
//        Test.stopTest();
//
//        accounts = selectAccounts();
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS * COUNT_OF_RECORDS, accounts.size());
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//        }
//    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
//    private static List<EUR_CRM_Criteria_Set__c> makeCriteriaSets(Integer countOfCriteriaSet) {
//        List<EUR_CRM_Criteria_Set__c> criteriaSets = new List<EUR_CRM_Criteria_Set__c>();
//        for (Integer i = 0; i < countOfCriteriaSet; i++) {
//            criteriaSets.add(makeCriteriaSet());
//        }
//        return criteriaSets;
//    }
//
//    private static List<EUR_CRM_PRS_Question_Set__c> makeQuestionSets(Integer countOfCriteriaSet) {
//        List<EUR_CRM_PRS_Question_Set__c> questionSets = new List<EUR_CRM_PRS_Question_Set__c>();
//        for (Integer i = 0; i < countOfCriteriaSet; i++) {
//            questionSets.add(makeQuestionSet());
//        }
//        return questionSets;
//    }
//
//    private static List<EUR_CRM_Group_Outlet_Type__c> makeGroupOutletTypes(Integer countOfCriteriaSet) {
//        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_Group_Outlet_Type__c>();
//        for (Integer i = 0; i < countOfCriteriaSet; i++) {
//            groupOutletTypes.add(makeGroupOutletType());
//        }
//        return groupOutletTypes;
//    }
//
//    private static List<EUR_CRM_PRS_Group_Outlet_Type__c> makePRSGroupOutletTypes(Integer countOfCriteriaSet) {
//        List<EUR_CRM_PRS_Group_Outlet_Type__c> prsGroupOutletTypes = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
//        for (Integer i = 0; i < countOfCriteriaSet; i++) {
//            prsGroupOutletTypes.add(makePRSGroupOutletType());
//        }
//        return prsGroupOutletTypes;
//    }
//
//    private static List<EUR_CRM_Account__c> makeAccounts(Integer countOfAccounts, Id groupOutletType, Id prsGroupOutletType) {
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (Integer i = 0; i < countOfAccounts; i++) {
//            accounts.add(makeAccount(groupOutletType, prsGroupOutletType));
//        }
//        return accounts;
//    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Criteria_Set__c makeCriteriaSet() {
        return new EUR_CRM_Criteria_Set__c(
            EUR_CRM_IsQuestionsUpdated__c = true
        );
    }

    private static EUR_CRM_PRS_Question_Set__c makeQuestionSet() {
        return new EUR_CRM_PRS_Question_Set__c(
            EUR_CRM_IsQuestionsUpdated__c = true
        );
    }

    private static EUR_CRM_Group_Outlet_Type__c makeGroupOutletType() {
        return new EUR_CRM_Group_Outlet_Type__c(
            EUR_CRM_Name__c = 'Restaurant'
        );
    }

    private static EUR_CRM_PRS_Group_Outlet_Type__c makePRSGroupOutletType() {
        return new EUR_CRM_PRS_Group_Outlet_Type__c(
            EUR_CRM_Name__c = 'Restaurant'
        );
    }

    private static EUR_CRM_Account__c makeAccount(Id groupOutletType, Id prsGroupOutletType) {
        return new EUR_CRM_Account__c(
            Name = 'Test Account'
        ,   EUR_CRM_Group_Outlet_Type__c = groupOutletType
        ,   EUR_CRM_PRS_Group_Outlet_Type__c = prsGroupOutletType
        ,   EUR_CRM_Postal_Code__c = '1122'
        , RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,   EUR_CRM_IsProsUpdate__c
            FROM EUR_CRM_Account__c
        ];
    }

}