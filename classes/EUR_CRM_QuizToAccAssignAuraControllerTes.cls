@IsTest (IsParallel = true)
private class EUR_CRM_QuizToAccAssignAuraControllerTes {

    @TestSetup
    private static void setupMethod() {
        insert makeAccount();
    }

    @IsTest
    private static void setupTest() {
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
    }


    @IsTest
    private static void getSelectionMethodOptionsTest() {
        List<EUR_CRM_QuizToAccAssignAuraController.SelectOptionWrapper> selectOptionWrappers =
            EUR_CRM_QuizToAccAssignAuraController.getSelectionMethodOptions();

        System.assert(selectOptionWrappers.size() >= 3);

        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.NONE, selectOptionWrappers[0].value);
        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.NONE, selectOptionWrappers[0].label);

        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.ACCOUNT_LIST_VIEWS, selectOptionWrappers[1].value);
        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.ACCOUNT_LIST_VIEWS, selectOptionWrappers[1].label);

        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.CUSTOMER_TAXONOMY, selectOptionWrappers[2].value);
        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.CUSTOMER_TAXONOMY, selectOptionWrappers[2].label);

//        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.PROS, selectOptionWrappers[3].value);
//        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.PROS, selectOptionWrappers[3].label);
//
//        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.PROFS, selectOptionWrappers[4].value);
//        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.PROFS, selectOptionWrappers[4].label);
    }

    @IsTest
    private static void getAccountListViewOptionsTest() {
        List<EUR_CRM_QuizToAccAssignAuraController.SelectOptionWrapper> selectOptionWrappers =
            EUR_CRM_QuizToAccAssignAuraController.getAccountListViewOptions();

        System.assertNotEquals(0, selectOptionWrappers.size());

        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.NONE, selectOptionWrappers[0].value);
        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.NONE, selectOptionWrappers[0].label);

        String filterId = null;
        for (EUR_CRM_QuizToAccAssignAuraController.SelectOptionWrapper option : selectOptionWrappers) {
            if (option.label == 'My Accounts') {
                filterId = option.value;
                break;
            }
        }
        //System.assertNotEquals(null, filterId);
    }

    @IsTest
    private static void getCustomerTaxonomyOptionsTest() {
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('Simple Customer Taxonomy');
        insert customerTaxonomy;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        for (EUR_CRM_Account__c account : accounts) {
            account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
        }
        update accounts;

        List<EUR_CRM_QuizToAccAssignAuraController.SelectOptionWrapper> selectOptionWrappers =
            EUR_CRM_QuizToAccAssignAuraController.getCustomerTaxonomyOptions();

        System.assertEquals(2, selectOptionWrappers.size());

        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.NONE, selectOptionWrappers[0].value);
        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.NONE, selectOptionWrappers[0].label);

        System.assertEquals('Simple Customer Taxonomy', selectOptionWrappers[1].value);
        System.assertEquals('Simple Customer Taxonomy', selectOptionWrappers[1].label);
    }

    @IsTest
    private static void getPROSTableTest() {
        List<EUR_CRM_QuizToAccAssignAuraController.PROSWrapperAura> prosWrapperAuras =
            EUR_CRM_QuizToAccAssignAuraController.getPROSTable();

        System.assertNotEquals(0, prosWrapperAuras.size());
    }

    @IsTest
    private static void getPROFSTest() {
        List<EUR_CRM_QuizToAccAssignAuraController.PROFSWrapperAura> profsWrapperAuras =
            EUR_CRM_QuizToAccAssignAuraController.getPROFS();

        System.assertNotEquals(0, profsWrapperAuras.size());
    }

    @IsTest
    private static void getAccountsOfListViewTest() {
        List<EUR_CRM_QuizToAccAssignAuraController.SelectOptionWrapper> selectOptionWrappers =
            EUR_CRM_QuizToAccAssignAuraController.getAccountListViewOptions();

        String filterId = null;
        for (EUR_CRM_QuizToAccAssignAuraController.SelectOptionWrapper option : selectOptionWrappers) {
            if (option.label == 'My Accounts') {
                filterId = option.value;
                break;
            }
        }
        //System.assertNotEquals(null, filterId);

        EUR_CRM_Quiz__c quiz = makeQuiz();
        insert quiz;

        List<EUR_CRM_QuizToAccAssignAuraController.AccountWrapperAura> accountWrapperAuras =
            EUR_CRM_QuizToAccAssignAuraController.getAccountsOfListView(filterId, quiz.Id);

        System.assertEquals(1, accountWrapperAuras.size());
        System.assertEquals('Simple Account', accountWrapperAuras[0].Name);
    }

    @IsTest
    private static void getAccountsOfCustomerTaxonomyTest() {
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy('Simple Customer Taxonomy');
        insert customerTaxonomy;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        for (EUR_CRM_Account__c account : accounts) {
            account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
        }
        update accounts;

        EUR_CRM_Quiz__c quiz = makeQuiz();
        insert quiz;

        List<EUR_CRM_QuizToAccAssignAuraController.AccountWrapperAura> accountWrapperAuras =
            EUR_CRM_QuizToAccAssignAuraController.getAccountsOfCustomerTaxonomy('Simple Customer Taxonomy', quiz.Id);

        System.assertEquals(1, accountWrapperAuras.size());
        System.assertEquals('Simple Account', accountWrapperAuras[0].Name);
    }

    @IsTest
    private static void getAccountsOfProsTest() {
        EUR_CRM_PRS_Group_Outlet_Type__c got = makeGOT('Restaurant');
        got.RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByName().get('EUR BE PRS On Trade Group Outlet Type').getRecordTypeId();
        insert got;
        EUR_CRM_PRS_Seg_Aspect__c segAspect = makeSegAspect('Iconic');
        segAspect.RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByName().get('EUR BE PRS Segmentation Aspect - Image Level').getRecordTypeId();
        insert segAspect;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        for (EUR_CRM_Account__c account : accounts) {
            account.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
            account.EUR_CRM_PRS_Image_Level__c = segAspect.Id;
        }
        update accounts;

        EUR_CRM_Quiz__c quiz = makeQuiz();
        insert quiz;

        List<EUR_CRM_QuizToAccAssignAuraController.PROSWrapperAura> prosWrapperAuras =
            EUR_CRM_QuizToAccAssignAuraController.getPROSTable();

        prosWrapperAuras[0].imageLevelCheckboxWrappers[0].isChecked = true;

        List<EUR_CRM_QuizToAccAssignAuraController.AccountWrapperAura> accountWrapperAuras =
            EUR_CRM_QuizToAccAssignAuraController.getAccountsOfPros(JSON.serialize(prosWrapperAuras), quiz.Id);

        System.assertEquals(1, accountWrapperAuras.size());
        System.assertEquals('Simple Account', accountWrapperAuras[0].Name);
    }

    @IsTest
    private static void getAccountsOfProfsTest() {
        EUR_CRM_PRS_Group_Outlet_Type__c got = makeGOT('Hyper/Supermarket');
        got.RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByName().get('EUR BE PRS Off Trade Group Outlet Type').getRecordTypeId();
        insert got;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        for (EUR_CRM_Account__c account : accounts) {
            account.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
        }
        update accounts;

        EUR_CRM_Quiz__c quiz = makeQuiz();
        insert quiz;

        List<EUR_CRM_QuizToAccAssignAuraController.PROFSWrapperAura> profsWrapperAuras =
            EUR_CRM_QuizToAccAssignAuraController.getPROFS();

        List<EUR_CRM_QuizToAccAssignAuraController.AccountWrapperAura> accountWrapperAuras =
            EUR_CRM_QuizToAccAssignAuraController.getAccountsOfProfs(JSON.serialize(new List<EUR_CRM_QuizToAccAssignAuraController.PROFSWrapperAura> { profsWrapperAuras[0] }), quiz.Id);

        System.assertEquals(1, accountWrapperAuras.size());
        System.assertEquals('Simple Account', accountWrapperAuras[0].Name);
    }

    @IsTest
    private static void getAssignedAccountsEmptyListTest() {
        EUR_CRM_Quiz__c quiz = makeQuiz();
        insert quiz;

        List<EUR_CRM_QuizToAccAssignAuraController.AccountWrapperAura> accountWrappers =
            EUR_CRM_QuizToAccAssignAuraController.getAssignedAccounts(String.valueOf(quiz.Id));

        System.assertEquals(0, accountWrappers.size());
    }

    @IsTest
    private static void getAssignedAccountsTest() {
        EUR_CRM_Quiz__c quiz = makeQuiz();
        insert quiz;

        List<EUR_CRM_QuizPartaker__c> quizPartakers = new List<EUR_CRM_QuizPartaker__c>();
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        for (EUR_CRM_Account__c acc : accounts) {
            quizPartakers.add(new EUR_CRM_QuizPartaker__c(EUR_CRM_QuizId__c = quiz.Id, EUR_CRM_AccountId__c = acc.Id));
        }
        insert quizPartakers;

        List<EUR_CRM_QuizToAccAssignAuraController.AccountWrapperAura> accountWrapperAuras =
            EUR_CRM_QuizToAccAssignAuraController.getAssignedAccounts(String.valueOf(quiz.Id));

        System.assertEquals(1, accountWrapperAuras.size());
    }

    @IsTest
    private static void assignToAccountsTest() {
        EUR_CRM_Quiz__c quiz = makeQuiz();
        insert quiz;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        List<Id> accIds = new List<Id>();
        for (EUR_CRM_Account__c acc : accounts) {
            accIds.add(acc.Id);
        }

        String result = EUR_CRM_QuizToAccAssignAuraController.assignToAccounts(JSON.serialize(accIds), String.valueOf(quiz.Id));
        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.SUCCESS_RESULT, result);

        List<EUR_CRM_QuizPartaker__c> quizPartakers = selectQuizPartakers(quiz.Id);
        System.assertEquals(1, quizPartakers.size());
        System.assertEquals(accounts[0].Id, quizPartakers[0].EUR_CRM_AccountId__c);
    }

    @IsTest
    private static void deleteAccountAssignmentsTest() {
        EUR_CRM_Quiz__c quiz = makeQuiz();
        insert quiz;

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        List<Id> accIds = new List<Id>();
        for (EUR_CRM_Account__c acc : accounts) {
            accIds.add(acc.Id);
        }

        String result = EUR_CRM_QuizToAccAssignAuraController.assignToAccounts(JSON.serialize(accIds), String.valueOf(quiz.Id));
        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.SUCCESS_RESULT, result);

        List<EUR_CRM_QuizPartaker__c> quizPartakers = selectQuizPartakers(quiz.Id);
        System.assertEquals(1, quizPartakers.size());
        System.assertEquals(accounts[0].Id, quizPartakers[0].EUR_CRM_AccountId__c);

        result = EUR_CRM_QuizToAccAssignAuraController.deleteAccountAssignments(JSON.serialize(accIds), String.valueOf(quiz.Id));
        System.assertEquals(EUR_CRM_QuizToAccAssignAuraController.SUCCESS_RESULT, result);

        quizPartakers = selectQuizPartakers(quiz.Id);
        System.assertEquals(0, quizPartakers.size());
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'Simple Account'
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }

    private static EUR_CRM_Customer_Taxonomy__c makeCustomerTaxonomy(String chain) {
        return new EUR_CRM_Customer_Taxonomy__c(
            EUR_CRM_Chain__c = chain
        ,   Name = chain
        );
    }

    private static EUR_CRM_Quiz__c makeQuiz() {
        return new EUR_CRM_Quiz__c(
            Name = 'Simple Quiz'
        );
    }

    private static EUR_CRM_PRS_Group_Outlet_Type__c makeGOT(String name) {
        return new EUR_CRM_PRS_Group_Outlet_Type__c(
            EUR_CRM_PRS_Group_Outlet_Name__c = name
        );
    }

    private static EUR_CRM_PRS_Seg_Aspect__c makeSegAspect(String name) {
        return new EUR_CRM_PRS_Seg_Aspect__c(
            EUR_CRM_Segmentation_IL_Aspect_Name__c = name
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            FROM EUR_CRM_Account__c
        ];
    }

    private static List<EUR_CRM_QuizPartaker__c> selectQuizPartakers(Id quizId) {
        return [
            SELECT Id
            ,   EUR_CRM_AccountId__c
            FROM EUR_CRM_QuizPartaker__c
            WHERE EUR_CRM_QuizId__c = :quizId
        ];
    }

}