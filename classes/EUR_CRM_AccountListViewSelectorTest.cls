@isTest
private class EUR_CRM_AccountListViewSelectorTest {

    static testmethod void test() {
        List<EUR_CRM_Account__c> euaccount = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> euaccountUpdate = new List<EUR_CRM_Account__c>();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        // The query used by the batch job.
        String query = 'Select Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c,' +
                ' EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE' +
                ' Recordtype.DeveloperName = :validRecordTypes AND EUR_CRM_Is_Active__c = FALSE';

        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;

        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccounts('Test EU ACCOUNT', 5);
        insert euaccount;
        //system.debug('@euaccount:'+euaccount);
        for (EUR_CRM_Account__c acc : [
                select eur_crm_country_code__c,name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, EUR_CRM_City__c,EUR_CRM_Image_Level_Name__c,EUR_CRM_Group_Outlet_Type_Name__c,
                        EUR_CRM_Region__c, EUR_CRM_Street__c, EUR_CRM_Building_Number__c, EUR_CRM_Comp_Establishment_Name_legally__c, EUR_CRM_Status__c, EUR_CRM_Channel__c, EUR_CRM_Manager_of_Account_Owner__c,
                        EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c
                from EUR_CRM_Account__c
        ]) {
            system.debug('@eur_crm_country_code__c:' + acc.eur_crm_country_code__c);
            euaccountUpdate.add(acc);
        }
        update euaccountUpdate;

        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;
        // Create Promo
        List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(20, 'EUR_RU_ON_Trade_Phase_1', 'Test Promo', template);
        List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
        for (EUR_CRM_ObjPromo__c p : promos) {
            p.EUR_CRM_Status__c = 'Draft';
            p.EUR_CRM_Active_End_Date__c = Date.today();
            promosToInsert.add(p);
        }
        insert promosToInsert;

        List<EUR_CRM_ObjPromo_Account_Mapping__c> opMapping = EUR_CRM_RU_TestClassHelper.createOPAccountMapping(10, 'EUR_RU_O_P_Account_Mapping', euaccount[0], promosToInsert[0]);
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        for (EUR_CRM_ObjPromo_Account_Mapping__c m : opMapping) {
            m.EUR_CRM_Is_Active__c = true;
            m.EUR_CRM_Evaluation_Required__c = false;
            opMappingToInsert.add(m);
        }
        insert opMappingToInsert;

        EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
        insert objPromoAction;

        EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount[0], promosToInsert[0]);
        visitAction.EUR_CRM_Stage__c = 'Execution';
        visitAction.EUR_CRM_Status__c = 'Participating';
        insert visitAction;

        Test.startTest();
        EUR_CRM_AccountListViewSelectorCtrller con = new EUR_CRM_AccountListViewSelectorCtrller();
        con.countryCode = 'RU';
        con.objPromo = promosToInsert[0];
        ApexPages.StandardController standardController = con.standardController;
        con.sortFieldName = 'fld1';
        con.oldSortFieldName = 'fld2';
        Integer pageNumber = con.pageNumber;

        // Change the filter
        List<SelectOption> testOptions = con.getListViewOptions();

        for (SelectOption op : con.getListViewOptions()) {
            //if(op.getLabel().equalsIgnoreCase('All RU O/Ps')){
            con.filterId = op.getValue();
            //}

        }
        ApexPages.StandardSetController ssc = con.con;
        //con.filterId = '00B40000006onAr';
        con.retrieveAccounts();
        con.sort();
        con.doNext();
        con.doPrevious();
        con.first();
        con.last();
        con.getHasPrevious();
        con.getHasNext();
        con.getPageNumber();
        con.getTotalPages();
        con.getPageSize();
        con.getRecordSize();
        con.doSelectItem();
        con.getSelectedAccounts();
        con.doDeselectItem();
        con.getHasSelectedAccounts();
        con.selectAll();
        con.deSelectAll();

        con.quickSaveAccounts();
        con.saveAccounts();
        con.quickSaveContinue();
        con.validateAccounts();
        con.cancel();
        con.getIsDeactivated();
        con.getListViewOptions();
        con.resetFilter();
        Set<Id> existingOPAccountIds = new Set<Id>();
        existingOPAccountIds.add(euaccount[0].id);
        existingOPAccountIds.add(euaccount[1].id);
        List<EUR_CRM_ObjPromo_Account_Mapping__c> toInsertOPAccounts = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        toInsertOPAccounts.add(opMappingToInsert[0]);
        con.removeDuplicateOPAccounts(existingOPAccountIds, toInsertOPAccounts);
        con.selectedAccounts = existingOPAccountIds;
        con.validateAccounts();

        Test.stopTest();

    }

    static testmethod void test2() {

        Set<Id> selectedAccounts = new Set<Id>();
        List<EUR_CRM_Account__c> euaccount = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> euaccountUpdate = new List<EUR_CRM_Account__c>();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        // The query used by the batch job.
        String query = 'Select Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c,' +
                ' EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE' +
                ' Recordtype.DeveloperName = :validRecordTypes AND EUR_CRM_Is_Active__c = FALSE';

        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;

        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccounts('Test EU ACCOUNT', 5);
        insert euaccount;
        for (EUR_CRM_Account__c acc: euaccount) {
            selectedAccounts.add(acc.Id);
        }

        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        template.EUR_CRM_External_ID__c = 'RU_OFF_Discount_Campaign';
        insert template;
        // Create Promo
        List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(20, 'EUR_RU_Off_Trade_Discount_Campaign', 'Test Promo', template);
        List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
        for (EUR_CRM_ObjPromo__c p : promos) {
            p.EUR_CRM_Status__c = 'Active';
            p.EUR_CRM_Active_End_Date__c = Date.today();
            promosToInsert.add(p);
        }
        insert promosToInsert;


        List<EUR_CRM_ObjPromo_Account_Mapping__c> opMapping = EUR_CRM_RU_TestClassHelper.createOPAccountMapping(6000, 'EUR_RU_O_P_Account_Mapping', euaccount[0], promosToInsert[0]);
        insert opMapping;

        EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
        insert objPromoAction;

        EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount[0], promosToInsert[0]);
        visitAction.EUR_CRM_Stage__c = 'Execution';
        visitAction.EUR_CRM_Status__c = 'Participating';
        insert visitAction;

        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(euaccount);
        EUR_CRM_AccountListViewSelectorCtrller con = new EUR_CRM_AccountListViewSelectorCtrller();
        EUR_CRM_AccountListViewSelectorCtrller.euAccountsWrapper wrap = new EUR_CRM_AccountListViewSelectorCtrller.euAccountsWrapper(euaccount[0], true);
        con.con = stdSetController;
        con.countryCode = 'RU';
        con.objPromo = promosToInsert[0];
        // Change the filter
        List<SelectOption> testOptions = con.getListViewOptions();
        Id testFilterId;
        for (SelectOption op : con.con.getListViewOptions()) {
            system.debug('@op.getLabel():' + op.getLabel());
            if (op.getLabel().equalsIgnoreCase('All RU O/Ps')) {
                testFilterId = op.getValue();
            }
        }

        if (testFilterId != NULL) {
            con.filterId = testFilterId;    //Set the Filter Id
            con.resetFilter();    //Invoke 'Reset Filter' method
            ApexPages.StandardSetController stdSetCon = con.con;    //Retrieve the Standard Set Controller results

            con.getWrapAccounts();
        }
                //con.retrieveAccounts();
                //con.getWrapAccounts();
                //con.selectAll();
                //con.deSelectAll();
                con.sort();
        con.doNext();
        con.doPrevious();
        con.first();
        con.last();
        con.getHasPrevious();
        con.getHasNext();
        con.getPageNumber();
        con.getTotalPages();
        con.getPageSize();
        con.getRecordSize();
        con.doSelectItem();
        con.getSelectedAccounts();
        con.doDeselectItem();
        con.getHasSelectedAccounts();

        con.euAccounts = euaccount;
        con.selectedAccounts = selectedAccounts;
        con.quickSaveAccounts();
        con.saveAccounts();
        con.quickSaveContinue();
        con.validateAccounts();
        con.cancel();
        con.getIsDeactivated();
        con.getListViewOptions();


        Test.stopTest();


    }

    static testmethod void test3() {

        List<EUR_CRM_Account__c> euaccount = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> euaccountUpdate = new List<EUR_CRM_Account__c>();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        // The query used by the batch job.
        String query = 'Select Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c,' +
                ' EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE' +
                ' Recordtype.DeveloperName = :validRecordTypes AND EUR_CRM_Is_Active__c = FALSE';

        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;

        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccounts('Test EU ACCOUNT', 5);
        insert euaccount;

        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        template.EUR_CRM_External_ID__c = 'RU_OFF_Discount_Campaign';
        insert template;
        // Create Promo
        List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(20, 'EUR_RU_Off_Trade_Discount_Campaign', 'Test Promo', template);
        List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
        for (EUR_CRM_ObjPromo__c p : promos) {
            p.EUR_CRM_Status__c = 'Active';
            p.EUR_CRM_Active_End_Date__c = Date.today();
            promosToInsert.add(p);
        }
        insert promosToInsert;


        List<EUR_CRM_ObjPromo_Account_Mapping__c> opMapping = EUR_CRM_RU_TestClassHelper.createOPAccountMapping(6000, 'EUR_RU_O_P_Account_Mapping', euaccount[0], promosToInsert[0]);
        insert opMapping;

        EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
        insert objPromoAction;

        EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount[0], promosToInsert[0]);
        visitAction.EUR_CRM_Stage__c = 'Execution';
        visitAction.EUR_CRM_Status__c = 'Participating';
        insert visitAction;

        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(euaccount);
        EUR_CRM_AccountListViewSelectorCtrller con = new EUR_CRM_AccountListViewSelectorCtrller();
        EUR_CRM_AccountListViewSelectorCtrller.euAccountsWrapper wrap = new EUR_CRM_AccountListViewSelectorCtrller.euAccountsWrapper(euaccount[0], true);
        con.con = stdSetController;
        con.countryCode = 'RU';

        // Change the filter
        List<SelectOption> testOptions = con.getListViewOptions();
        Id testFilterId;
        for (SelectOption op : con.con.getListViewOptions()) {

            //if(op.getLabel().equalsIgnoreCase('All RU O/Ps')){
            con.filterId = op.getValue();
            //}

        }

        if (testFilterId != NULL) {
            con.filterId = testFilterId;    //Set the Filter Id
            con.resetFilter();    //Invoke 'Reset Filter' method
            ApexPages.StandardSetController stdSetCon = con.con;    //Retrieve the Standard Set Controller results

            con.getWrapAccounts();
        }


        try {
            con.quickSaveAccounts();
        } catch (Exception e) {
        }


        Test.stopTest();


    }
}