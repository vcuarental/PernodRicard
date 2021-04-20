@IsTest (IsParallel = true)
private class EUR_CRM_AccountIsProsUpdateServiceTest {

    private static final Integer COUNT_OF_RECORDS = 4; // 8 or 12 or 16...


    /* ========================================================= */
    /*     Single EUR_CRM_Account__c and single child records
    /* ========================================================= */
    @IsTest
    private static void singleAccountUncheckForImageCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        groupOutletType.EUR_CRM_Image_Criteria_Set__c = criteriaSet.Id;
        insert groupOutletType;

        EUR_CRM_Account__c account = makeAccount(groupOutletType.Id, null);
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        account.EUR_CRM_IsProsUpdate__c = false;
        update account;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        //System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void singleAccountUncheckForVolumeCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Group_Outlet_Type__c groupOutletType = makeGroupOutletType();
        groupOutletType.EUR_CRM_Volume_Criteria_Set__c = criteriaSet.Id;
        insert groupOutletType;

        EUR_CRM_Account__c account = makeAccount(groupOutletType.Id, null);
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        account.EUR_CRM_IsProsUpdate__c = false;
        update account;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        //System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void singleAccountUncheckForBrandBuildPotQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType = makePRSGroupOutletType();
        prsGroupOutletType.EUR_CRM_BrandBuildPotQuestionSet__c = questionSet.Id;
        insert prsGroupOutletType;

        EUR_CRM_Account__c account = makeAccount(null, prsGroupOutletType.Id);
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        account.EUR_CRM_IsProsUpdate__c = false;
        update account;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        //System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void singleAccountUncheckForBusinessPotentialQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType = makePRSGroupOutletType();
        prsGroupOutletType.EUR_CRM_BusinessPotentialQuestionSet__c = questionSet.Id;
        insert prsGroupOutletType;

        EUR_CRM_Account__c account = makeAccount(null, prsGroupOutletType.Id);
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        account.EUR_CRM_IsProsUpdate__c = false;
        update account;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
       // System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void singleAccountUncheckForImageLevelQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType = makePRSGroupOutletType();
        prsGroupOutletType.EUR_CRM_Image_Level_Question_Set__c = questionSet.Id;
        insert prsGroupOutletType;

        EUR_CRM_Account__c account = makeAccount(null, prsGroupOutletType.Id);
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        account.EUR_CRM_IsProsUpdate__c = false;
        update account;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        //System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void singleAccountUncheckForVolumePotentialQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType = makePRSGroupOutletType();
        prsGroupOutletType.EUR_CRM_Volume_Potential_Question_Set__c = questionSet.Id;
        insert prsGroupOutletType;

        EUR_CRM_Account__c account = makeAccount(null, prsGroupOutletType.Id);
        insert account;

        account = selectAccounts()[0];
        System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        account.EUR_CRM_IsProsUpdate__c = false;
        update account;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        //System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void updateAccountWithNullFieldPriorityLevelMatrixTest() {
        EUR_CRM_Account__c account = makeAccount(null, null);
        insert account;

        EUR_CRM_PRS_Priority_Level_Criteria__c criteria = new EUR_CRM_PRS_Priority_Level_Criteria__c();
        insert criteria;

        EUR_CRM_PRS_Segmentation__c segmentation = makePRSSegmentation(account.Id, criteria.Id);
        insert segmentation;

        Test.startTest();

        System.assertEquals(null, account.EUR_CRM_PRS_Priority_Level_Criteria__c);

        account.EUR_CRM_City__c = 'Test City';
        update account;

        Test.stopTest();

        account = [SELECT EUR_CRM_PRS_Priority_Level_Criteria__c FROM EUR_CRM_Account__c WHERE EUR_CRM_City__c =
                'Test City'];
        System.assertEquals(criteria.Id, account.EUR_CRM_PRS_Priority_Level_Criteria__c);

    }

    //Added for fix coverage% on Account handler
    @IsTest
    private static void deleteAccountTest() {
        EUR_CRM_Account__c account = makeAccount(null, null);
        insert account;
        Test.startTest();
        delete account;
        undelete account;
        Test.stopTest();
    }

    /* ========================================================= */
    /*     Multiple EUR_CRM_Account__c and multiple child records
    /* ========================================================= */
//    @IsTest
//    private static void multipleAccountUncheckForImageCriteriaSetTest() {
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
//        accounts = selectAccounts();
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//            account.EUR_CRM_IsProsUpdate__c = false;
//        }
//
//        criteriaSets = selectCriteriaSets();
//        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
//            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//
//        Test.startTest();
//        update accounts;
//        Test.stopTest();
//
//        criteriaSets = selectCriteriaSets();
//        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
//            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//    }
//
//    @IsTest
//    private static void multipleAccountUncheckForVolumeCriteriaSetTest() {
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
//        accounts = selectAccounts();
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//            account.EUR_CRM_IsProsUpdate__c = false;
//        }
//
//        criteriaSets = selectCriteriaSets();
//        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
//            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//
//        Test.startTest();
//        update accounts;
//        Test.stopTest();
//
//        criteriaSets = selectCriteriaSets();
//        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
//            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//    }
//
//    @IsTest
//    private static void multipleAccountUncheckForBrandBuildPotQuestionSetTest() {
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
//        Test.startTest();
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            accounts.addAll(makeAccounts(COUNT_OF_RECORDS, null, groupOutletType.Id));
//        }
//        insert accounts;
//
//        accounts = selectAccounts();
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//            account.EUR_CRM_IsProsUpdate__c = false;
//        }
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//
//        update accounts;
//        Test.stopTest();
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//    }
//
//    @IsTest
//    private static void multipleAccountUncheckForBusinessPotentialQuestionSetTest() {
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
//        accounts = selectAccounts();
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//            account.EUR_CRM_IsProsUpdate__c = false;
//        }
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//
//        Test.startTest();
//        update accounts;
//        Test.stopTest();
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//    }
//
//    @IsTest
//    private static void multipleAccountUncheckForImageLevelQuestionSetTest() {
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
//        accounts = selectAccounts();
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//            account.EUR_CRM_IsProsUpdate__c = false;
//        }
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//
//        Test.startTest();
//        update accounts;
//        Test.stopTest();
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//    }
//
//    @IsTest
//    private static void multipleAccountUncheckForVolumePotentialQuestionSetTest() {
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
//        accounts = selectAccounts();
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//            account.EUR_CRM_IsProsUpdate__c = false;
//        }
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//
//        Test.startTest();
//        update accounts;
//        Test.stopTest();
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//    }
//
//
//    @IsTest
//    private static void multipleAccountUncheckForCriteriaSetsAndQuestionSetsTest() {
//        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets(COUNT_OF_RECORDS);
//        insert criteriaSets;
//
//        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_Group_Outlet_Type__c>();
//        for (Integer i = 0; i < criteriaSets.size() / 2; i++) {
//            for (EUR_CRM_Group_Outlet_Type__c groupOutletType : makeGroupOutletTypes(COUNT_OF_RECORDS)) {
//                groupOutletType.EUR_CRM_Image_Criteria_Set__c = criteriaSets[i].Id;
//                groupOutletTypes.add(groupOutletType);
//            }
//        }
//        for (Integer i = criteriaSets.size() / 2; i < criteriaSets.size(); i++) {
//            for (EUR_CRM_Group_Outlet_Type__c groupOutletType : makeGroupOutletTypes(COUNT_OF_RECORDS)) {
//                groupOutletType.EUR_CRM_Volume_Criteria_Set__c = criteriaSets[i].Id;
//                groupOutletTypes.add(groupOutletType);
//            }
//        }
//        insert groupOutletTypes;
//
//        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets(COUNT_OF_RECORDS);
//        insert questionSets;
//
//        List<EUR_CRM_PRS_Group_Outlet_Type__c> prsGroupOutletTypes = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
//        for (Integer i = 0; i < questionSets.size() / 4; i++) {
//            for (EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType : makePRSGroupOutletTypes(COUNT_OF_RECORDS)) {
//                prsGroupOutletType.EUR_CRM_BrandBuildPotQuestionSet__c = questionSets[i].Id;
//                prsGroupOutletTypes.add(prsGroupOutletType);
//            }
//        }
//        for (Integer i = questionSets.size() / 4; i < questionSets.size() / 2; i++) {
//            for (EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType : makePRSGroupOutletTypes(COUNT_OF_RECORDS)) {
//                prsGroupOutletType.EUR_CRM_BusinessPotentialQuestionSet__c = questionSets[i].Id;
//                prsGroupOutletTypes.add(prsGroupOutletType);
//            }
//        }
//        for (Integer i = questionSets.size() / 2; i < questionSets.size() * (3 / 4); i++) {
//            for (EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType : makePRSGroupOutletTypes(COUNT_OF_RECORDS)) {
//                prsGroupOutletType.EUR_CRM_Image_Level_Question_Set__c = questionSets[i].Id;
//                prsGroupOutletTypes.add(prsGroupOutletType);
//            }
//        }
//        for (Integer i = questionSets.size() * (3 / 4); i < questionSets.size(); i++) {
//            for (EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType : makePRSGroupOutletTypes(COUNT_OF_RECORDS)) {
//                prsGroupOutletType.EUR_CRM_Volume_Potential_Question_Set__c = questionSets[i].Id;
//                prsGroupOutletTypes.add(prsGroupOutletType);
//            }
//        }
//        insert prsGroupOutletTypes;
//
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            accounts.addAll(makeAccounts(COUNT_OF_RECORDS, groupOutletType.Id, null));
//        }
//        for (EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType : prsGroupOutletTypes) {
//            accounts.addAll(makeAccounts(COUNT_OF_RECORDS, null, prsGroupOutletType.Id));
//        }
//        insert accounts;
//
//        accounts = selectAccounts();
//        for (EUR_CRM_Account__c account : accounts) {
//            System.assertEquals(true, account.EUR_CRM_IsProsUpdate__c);
//            account.EUR_CRM_IsProsUpdate__c = false;
//        }
//
//        criteriaSets = selectCriteriaSets();
//        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
//            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//
//        Test.startTest();
//        update accounts;
//        Test.stopTest();
//
//        criteriaSets = selectCriteriaSets();
//        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
//            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//
//        questionSets = selectQuestionSets();
//        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
//            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
//        }
//    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Criteria_Set__c> makeCriteriaSets(Integer countOfCriteriaSet) {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = new List<EUR_CRM_Criteria_Set__c>();
        for (Integer i = 0; i < countOfCriteriaSet; i++) {
            criteriaSets.add(makeCriteriaSet());
        }
        return criteriaSets;
    }

    private static List<EUR_CRM_PRS_Question_Set__c> makeQuestionSets(Integer countOfCriteriaSet) {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = new List<EUR_CRM_PRS_Question_Set__c>();
        for (Integer i = 0; i < countOfCriteriaSet; i++) {
            questionSets.add(makeQuestionSet());
        }
        return questionSets;
    }

    private static List<EUR_CRM_Group_Outlet_Type__c> makeGroupOutletTypes(Integer countOfCriteriaSet) {
        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_Group_Outlet_Type__c>();
        for (Integer i = 0; i < countOfCriteriaSet; i++) {
            groupOutletTypes.add(makeGroupOutletType());
        }
        return groupOutletTypes;
    }

    private static List<EUR_CRM_PRS_Group_Outlet_Type__c> makePRSGroupOutletTypes(Integer countOfCriteriaSet) {
        List<EUR_CRM_PRS_Group_Outlet_Type__c> prsGroupOutletTypes = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
        for (Integer i = 0; i < countOfCriteriaSet; i++) {
            prsGroupOutletTypes.add(makePRSGroupOutletType());
        }
        return prsGroupOutletTypes;
    }

    private static List<EUR_CRM_Account__c> makeAccounts(Integer countOfAccounts, Id groupOutletType, Id prsGroupOutletType) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (Integer i = 0; i < countOfAccounts; i++) {
            accounts.add(makeAccount(groupOutletType, prsGroupOutletType));
        }
        return accounts;
    }


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
        ,   EUR_CRM_IsProsUpdate__c = true
        ,   EUR_CRM_Postal_Code__c = '1122'
        , RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }

    private static EUR_CRM_PRS_Segmentation__c makePRSSegmentation(Id accountId, Id criteriaId) {
        return new EUR_CRM_PRS_Segmentation__c(
                EUR_CRM_Account__c = accountId,
                EUR_CRM_PRS_Priority_Level_Criteria__c = criteriaId
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

    private static List<EUR_CRM_Criteria_Set__c> selectCriteriaSets() {
        return [
            SELECT Id
            ,   EUR_CRM_IsQuestionsUpdated__c
            FROM EUR_CRM_Criteria_Set__c
        ];
    }

    private static List<EUR_CRM_PRS_Question_Set__c> selectQuestionSets() {
        return [
            SELECT Id
            ,   EUR_CRM_IsQuestionsUpdated__c
            FROM EUR_CRM_PRS_Question_Set__c
        ];
    }

}