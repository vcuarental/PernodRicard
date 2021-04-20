/**
*   Description: Test class for EUR_CRM_ZA_PublishObjectivePageCtrl
*                which is a controller for EUR_CRM_ZA_PublishObjectivePage
*
*/
@isTest
private class EUR_CRM_ZA_PublishObjetivePageCtrlTest {
    public static List<EUR_CRM_Account__c> euAccounts = new List<EUR_CRM_Account__c>();
    public static EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c();
    public static EUR_CRM_OP_Action_List_Template__c objActionTemplate = new EUR_CRM_OP_Action_List_Template__c();
    public static EUR_CRM_ObjPromo_Action__c objPromoAction = new EUR_CRM_ObjPromo_Action__c();
    public static EUR_CRM_Quality__c bq = new EUR_CRM_Quality__c();
    public static EUR_CRM_Size__c bqs = new EUR_CRM_Size__c();
    public static EUR_CRM_ObjPromo_Target__c objPromoTarget = new EUR_CRM_ObjPromo_Target__c();

    public static User testUser;
    public static void setUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMEA'];
        testUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        
        insert testUser;
    }
    
    /**
    *   Function: dataInsert
    *   Prepares the test data
    *   Input: Number of accounts that will be retrieved
    */
    public static void dataInsert(integer numOfOffTradeAccounts, integer numOfOnTradeAccounts) {
        // Create test data for Account(EU)
        euAccounts = EUR_CRM_ZA_TestClassHelper.createEUAccount(numOfOffTradeAccounts, 'Sid Test EU ACCOUNT', 'EUR_ZA_Off_Trade');
        if(numOfOnTradeAccounts > 0) {
            euAccounts.addAll(EUR_CRM_ZA_TestClassHelper.createEUAccount(numOfOnTradeAccounts, 'Sid TEST EU ACCOUNT', 'EUR_ZA_On_Trade_Direct'));
        }
        insert euAccounts;
        
        // Create test data for Action List Template
        objActionTemplate = new EUR_CRM_OP_Action_List_Template__c(); 
        objActionTemplate.EUR_CRM_External_ID__c = 'ZA_OFF_ALT_Promo';
        objActionTemplate.recordTypeId = [select Id from RecordType where Developername =: 'EUR_ZA_OP_Action_List_Template'][0].Id;
        insert objActionTemplate;
        System.assertNotEquals(objActionTemplate, null);
        
        // Create test data for Brand Quality
        bq = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR_ZA_Quality', 'Cocktail', 'TEST-0001',null)[0];
        insert bq;
        
        // Create test data for Brand Quality Size
        bqs = EUR_CRM_ZA_TestClassHelper.createBrandQualitySize(1, 'test BQS', 'bqs1111', bq.Id).get(0);
        insert bqs;

        // Create test data for EUR_CRM_ObjPromo__c
        objPromo.EUR_CRM_Status__c = 'Draft';
        objPromo.EUR_CRM_OP_Action_List_Template__c = objActionTemplate.Id;
        objPromo.recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_ZA_Off_Trade_Promotion'][0].Id;
        insert objPromo;
        
        // Create test data for Objective Promotions Target
        objPromoTarget.EUR_CRM_BQS__c = bqs.Id;
        objPromoTarget.EUR_CRM_ObjPromo__c = objPromo.Id;
        objPromoTarget.recordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c'+'EUR_CRM_Objective_Volume_Target');
        // objPromoTarget.recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EUR_CRM_Objective_Volume_Target'];
        insert objPromoTarget;
    }
    
    //Test Method to display the Account records on initial load
    static testMethod void testDisplay() {
        setUser('EUR System Admin');
        System.runAs(testUser) {
            Integer numOfOffTradeAccounts = Math.round(Math.random()*100);
            dataInsert(numOfOffTradeAccounts, 0);
            
            Test.StartTest();
            
            PageReference publishObjectivePage = Page.EUR_CRM_ZA_PublishObjectivePage;
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);
            EUR_CRM_ZA_PublishObjectivePageCtrl con = new EUR_CRM_ZA_PublishObjectivePageCtrl(sc);
            Test.setCurrentPage(publishObjectivePage);
            
            System.assertEquals(con.objPromo, objPromo);
            System.assertNotEquals(con.isAllSelected, true);
            System.assertEquals(con.selectedAccounts.size(), 0);
            System.assertEquals(con.con.getResultSize(), 0);
            System.assertEquals(false, con.getHasPrevious());
            System.assertEquals(false, con.getHasNext());
            System.assertEquals(1, con.getPageNumber());
            System.assertEquals(false, con.getHasSelectedAccounts());
                        
            // Test Sorting
            con.sortFieldName = 'EUR_CRM_City__c';
            con.sort();
            
            con.sortFieldName = 'name';
            con.sort();
            
            Test.StopTest();
        }
    }
    
    /**
    *   testMethod: testFilter
    *   Inserts a number of ON and OFF Trade accounts, filters only OFF Trade records
    */
    static testMethod void testFilter() {
        setUser('EUR System Admin');
        System.runAs(testUser) {
            Integer numOfOffTradeAccounts = 1;
            Integer numOfOnTradeAccounts = 1;
            dataInsert(numOfOffTradeAccounts, numOfOnTradeAccounts);

            Test.StartTest();
            
            PageReference publishObjectivePage = Page.EUR_CRM_ZA_PublishObjectivePage;
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);
            EUR_CRM_ZA_PublishObjectivePageCtrl con = new EUR_CRM_ZA_PublishObjectivePageCtrl(sc);
            Test.setCurrentPage(publishObjectivePage);
                        
            // Change the filter
            List<SelectOption> testOptions = con.getListViewOptions();
            Id testFilterId;
            for(SelectOption op : con.con.getListViewOptions()){
                System.debug('======== op ' + op);
                if(op.getLabel().equalsIgnoreCase('EUR ZA ALL On Trade')){
                    testFilterId = op.getValue();  
                }
            }
            
            if(testFilterId != NULL){
                con.filterId = testFilterId;    //Set the Filter Id
                con.resetFilter();    //Invoke 'Reset Filter' method
                ApexPages.StandardSetController stdSetCon = con.con;    //Retrieve the Standard Set Controller results
                
                con.getWrapAccounts();
            }
            
            Test.StopTest();
        }
    }
    
    /**
    *   testMethod: testValidateNegative
    *   Method to 
    */
    static testMethod void testValidateNegative() {
        setUser('EUR System Admin');
        System.runAs(testUser) {
            Integer numOfOffTradeAccounts = 1;
            Integer numOfOnTradeAccounts = 1;
            dataInsert(numOfOffTradeAccounts, numOfOnTradeAccounts);

            Test.StartTest();
            
            PageReference publishObjectivePage = Page.EUR_CRM_ZA_PublishObjectivePage;
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);
            EUR_CRM_ZA_PublishObjectivePageCtrl con = new EUR_CRM_ZA_PublishObjectivePageCtrl(sc);
            Test.setCurrentPage(publishObjectivePage);
                        
            // Change the filter
            List<SelectOption> testOptions = con.getListViewOptions();
            Id testFilterId;
            for(SelectOption op : con.con.getListViewOptions()){
                System.debug('======== op ' + op);
                if(op.getLabel().equalsIgnoreCase('EUR ZA ALL On Trade')){
                    testFilterId = op.getValue();  
                }
            }
            
            if(testFilterId != NULL){
                con.filterId = testFilterId;    //Set the Filter Id
                con.resetFilter();    //Invoke 'Reset Filter' method
                ApexPages.StandardSetController stdSetCon = con.con;    //Retrieve the Standard Set Controller results
                
                con.getWrapAccounts();
                con.validateAccounts();
                System.assertEquals(con.blnIsPermissible, false);
            }
            
            Test.StopTest();
        }
    }    
    
    /**
    *   testMethod: testValidateNegative
    *   Method to 
    */
    static testMethod void testValidatePositive() {
        setUser('EUR System Admin');
        System.runAs(testUser) {
            Integer numOfOffTradeAccounts = 40;
            Integer numOfOnTradeAccounts = 0;
            dataInsert(numOfOffTradeAccounts, numOfOnTradeAccounts);

            Test.StartTest();
            
            PageReference publishObjectivePage = Page.EUR_CRM_ZA_PublishObjectivePage;
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);
            EUR_CRM_ZA_PublishObjectivePageCtrl con = new EUR_CRM_ZA_PublishObjectivePageCtrl(sc);
            Test.setCurrentPage(publishObjectivePage);
                        
            // Change the filter
            List<SelectOption> testOptions = con.getListViewOptions();
            Id testFilterId;
            for(SelectOption op : con.con.getListViewOptions()){
                System.debug('======== op ' + op);
                if(op.getLabel().equalsIgnoreCase('EUR ZA ALL On Trade')){
                    testFilterId = op.getValue();  
                }
            }
            
            if(testFilterId != NULL){
                con.filterId = testFilterId;    //Set the Filter Id
                con.resetFilter();    //Invoke 'Reset Filter' method
                ApexPages.StandardSetController stdSetCon = con.con;    //Retrieve the Standard Set Controller results
                
                con.getWrapAccounts();
                con.doNext();
                con.doPrevious();
                con.last();
                con.first();
                con.getTotalPages();
                Integer intPageNumber = con.pageNumber;
                con.getPageSize();
                con.getRecordSize();
                con.contextItem = euAccounts[0].Id;
                con.doDeselectItem();
                con.doSelectItem();
                con.getSelectedAccounts();
                con.validateAccounts();
                System.assertEquals(con.blnIsPermissible, true);
                if(con.blnIsPermissible){
                    con.publish();                    
                }
            }
            
            Test.StopTest();
        }
    }    
    
    /**
    *   testMethod: testSelectAccount
    *   Selects an account and checks if it is selected in the controller
    */
    static testMethod void testSelectAccount() {
        setUser('EUR System Admin');
        System.runAs(testUser) {
            Integer numOfOffTradeAccounts = 100;
            dataInsert(numOfOffTradeAccounts, 0);
            
            Test.StartTest();
            
            PageReference publishObjectivePage = Page.EUR_CRM_ZA_PublishObjectivePage;
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);
            EUR_CRM_ZA_PublishObjectivePageCtrl con = new EUR_CRM_ZA_PublishObjectivePageCtrl(sc);

            // Change the filter
            List<SelectOption> testOptions = con.getListViewOptions();
            Id testFilterId;
            for(SelectOption op : con.con.getListViewOptions()){
                System.debug('======== op ' + op);
                if(op.getLabel().equalsIgnoreCase('EUR ZA ALL On Trade')){
                    testFilterId = op.getValue();
                }
            }
            con.filterId = testFilterId;    //Set the Filter Id
            con.resetFilter();    //Invoke 'Reset Filter' method

            //con.pageNumber;
            con.getPageSize();
            con.getRecordSize();
            con.getSelectedAccounts();

            // Test if the page size can be set properly
            con.con.setPageSize(numOfOffTradeAccounts);
            //System.assertEquals(con.getPageSize(), numOfOffTradeAccounts);            
            
            Test.setCurrentPage(publishObjectivePage);
            
            // Get the current account wrap
            List<EUR_CRM_ZA_PublishObjectivePageCtrl.euAccountsWrapper> wrapAccounts = con.getWrapAccounts();
            //System.assertEquals(wrapAccounts.size(), numOfOffTradeAccounts);
            
            // Run a loop to select 10 items
            if(wrapAccounts.size() > 0){
                for(integer i = 0; i < 10; i++) {
                    con.contextItem = (String) wrapAccounts[i].euAccount.Id;
                    con.doSelectItem();
                }
            }
            // Check if 10 items are selected
            //System.assertEquals(con.selectedAccounts.size(), 10);
            //System.assertEquals(true, con.getHasSelectedAccounts());
            
            con.validateAccounts();

            // Run a loop to deselect 3 items 
            if(wrapAccounts.size() > 0){
                for(integer i = 0; i < 3; i++) {
                    con.contextItem = (String) wrapAccounts[i].euAccount.Id;
                    con.doDeselectItem();
                }
            }
            // Check if 7 items are selected
            //System.assertEquals(con.selectedAccounts.size(), 7);
            
            // Select all items
            con.selectAll();
            //System.assertEquals(con.selectedAccounts.size(), numOfOffTradeAccounts);
            
            // Deselect all items
            con.deSelectAll();
            //System.assertEquals(con.selectedAccounts.size(), 0);
            
            // Select all items again
            con.selectAll();
            //System.assertEquals(con.selectedAccounts.size(), numOfOffTradeAccounts);
            
            Test.StopTest();
        }
    }
    
    /**
    * testMethod: testPagination
    * Repeatedly switch between pages to test if the record is showing properly. 20 records per pages.
    */
    static testMethod void testPagination() {
        setUser('EUR System Admin');
        System.runAs(testUser) {
            Integer numOfOffTradeAccounts = 100;
            Integer numOfOnTradeAccounts = 50;
            dataInsert(numOfOffTradeAccounts, numOfOnTradeAccounts);
            
            Test.StartTest();
            
            integer pageSize = 20;
            
            PageReference publishObjectivePage = Page.EUR_CRM_ZA_PublishObjectivePage;
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);
            EUR_CRM_ZA_PublishObjectivePageCtrl con = new EUR_CRM_ZA_PublishObjectivePageCtrl(sc);

            // Change the filter
            List<SelectOption> testOptions = con.getListViewOptions();
            Id testFilterId = con.con.getListViewOptions()[0].getValue();
            con.filterId = testFilterId;    //Set the Filter Id
            con.resetFilter();    //Invoke 'Reset Filter' method
            con.con.setPageSize(pageSize);
            Test.setCurrentPage(publishObjectivePage);
            
            // Get current page records and check if it matches the first page's records
            List<EUR_CRM_ZA_PublishObjectivePageCtrl.euAccountsWrapper> wrapAccounts = con.getWrapAccounts();
            // System.assertEquals(wrapAccounts.size(), numOfOffTradeAccounts);
            /*for(integer i = 0; i < pageSize; i++) {
                System.assertEquals(wrapAccounts[i].euAccount.Id, euAccounts[i].Id);
            }*/
            
            // Retrieve next page and check if it matches the second page's records
            con.doNext();
            wrapAccounts = con.getWrapAccounts();
            /*for(integer i = 0; i < pageSize; i++) {
                System.assertEquals(wrapAccounts[i].euAccount.Id, euAccounts[pageSize + i].Id);    
            }*/
            
            // Go back one page and check if it matches the previous page's records
            con.doPrevious();
            wrapAccounts = con.getWrapAccounts();
            /*for(integer i = 0; i < pageSize; i++) {
                System.assertEquals(wrapAccounts[i].euAccount.Id, euAccounts[i].Id);
            }*/
            
            // Go next 2 pages and check if it matches the third page's records
            con.doNext();
            con.doNext();
            wrapAccounts = con.getWrapAccounts();
            /*for(integer i = 0; i < pageSize; i++) {
                System.assertEquals(wrapAccounts[i].euAccount.Id, euAccounts[pageSize * 2 + i].Id);
            }*/
            
            // Go to first page and check if it matches the first page's records
            con.first();
            wrapAccounts = con.getWrapAccounts();
            /*for(integer i = 0; i < pageSize; i++) {
                System.assertEquals(wrapAccounts[i].euAccount.Id, euAccounts[i].Id);
            }*/
            
            // Go to the last page and check if it matches the last page's records
            con.last();
            wrapAccounts = con.getWrapAccounts();
            integer totalPages = con.getTotalPages();
            /*for(integer i = 0; i < wrapAccounts.size(); i++) {
                System.assertEquals(wrapAccounts[i].euAccount.Id, euAccounts[pageSize * (totalPages - 1) + i].Id);
            }*/
            
            Test.StopTest();
        }
    }
    
    /**
    * testMethod: testPublish
    * test the publish action. Should create a matching OP Account Mapping record type for each account selected
    */
    static testMethod void testPublish() {
        setUser('EUR System Admin');
        System.runAs(testUser) {
            Integer numOfOffTradeAccounts = 10;
            Integer numOfOnTradeAccounts = 10;
            dataInsert(numOfOffTradeAccounts, numOfOnTradeAccounts);
            
            Test.StartTest();

            Integer pageSize = 10;
            PageReference publishObjectivePage = Page.EUR_CRM_ZA_PublishObjectivePage;
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);
            EUR_CRM_ZA_PublishObjectivePageCtrl con = new EUR_CRM_ZA_PublishObjectivePageCtrl(sc);

            // Change the filter
            List<SelectOption> testOptions = con.getListViewOptions();
            //Id testFilterId = con.con.getListViewOptions()[0].getValue();
            Id testFilterId;
            for(SelectOption op : con.con.getListViewOptions()){
                System.debug('======== op ' + op);
                if(op.getLabel().equalsIgnoreCase('EUR ZA ALL On Trade')){
                    testFilterId = op.getValue();
                }
            }
            con.filterId = testFilterId;    //Set the Filter Id
            con.resetFilter();    //Invoke 'Reset Filter' method

            con.con.setPageSize(pageSize);
            Test.setCurrentPage(publishObjectivePage);
            
            // Get the account wrapper for the first page
            List<EUR_CRM_ZA_PublishObjectivePageCtrl.euAccountsWrapper> wrapAccounts = con.getWrapAccounts();            
            System.Debug('@@@wrapAccounts:' + wrapAccounts);
            // Run a loop to select the first 10 items from the account wrapper
            if(wrapAccounts.size() > 0){
                for(integer i = 0; i < 10; i++) {
                    con.contextItem = (String) wrapAccounts[i].euAccount.Id;
                    con.doSelectItem();
                }
            }
            
            
            // Publish selected accounts
            con.publish();
            List<EUR_CRM_ObjPromo_Account_Mapping__c> insertedOPAccountMappings = [SELECT Id FROM EUR_CRM_ObjPromo_Account_Mapping__c];
            //System.assertEquals(insertedOPAccountMappings.size(), con.selectedAccounts.size());
            
            // Published O/P Should be set to active
            //EUR_CRM_ObjPromo__c objPro
            objPromo = [SELECT EUR_CRM_Status__c FROM EUR_CRM_ObjPromo__c WHERE Id = :objPromo.Id];
            //System.assertEquals(objPromo.EUR_CRM_Status__c, 'Active');
                        
            Test.StopTest();
        }
    }
    
    /**
    * testMethod: testQuickSave
    * test quicksaving
    */
    static testMethod void testQuicksave() {
        setUser('EUR System Admin');
        System.runAs(testUser) {
            Integer numOfOffTradeAccounts = 3;
            Integer numOfOnTradeAccounts = 3;
            dataInsert(numOfOffTradeAccounts, numOfOnTradeAccounts);
            
            Test.StartTest();
            
            Integer pageSize = 2;
            PageReference publishObjectivePage = Page.EUR_CRM_ZA_PublishObjectivePage;
            publishObjectivePage.getParameters().put('isQuickSave', 'TRUE');
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);
            EUR_CRM_ZA_PUblishObjectivePageCtrl con = new EUR_CRM_ZA_PublishObjectivePageCtrl(sc);

            // Change the filter
            List<SelectOption> testOptions = con.getListViewOptions();
            Id testFilterId;
            for(SelectOption op : con.con.getListViewOptions()){
                System.debug('======== op ' + op);
                if(op.getLabel().equalsIgnoreCase('EUR ZA ALL On Trade')){
                    testFilterId = op.getValue();
                }
            }
            con.filterId = testFilterId;    //Set the Filter Id
            con.resetFilter();    //Invoke 'Reset Filter' method

            con.con.setPageSize(pageSize);
            Test.setCurrentPage(publishObjectivePage);

            // Get the account wrapper for the first page
            List<EUR_CRM_ZA_PublishObjectivePageCtrl.euAccountsWrapper> wrapAccounts = con.getWrapAccounts();     
            System.Debug('@@@wrapAccounts:' + wrapAccounts);

            EUR_CRM_Account__c acc; //Reserve an account
            // Run a loop to select the first 10 items from the account wrapper
            if(wrapAccounts.size() > 0){
                for(integer i = 0; i < pageSize; i++) {
                    acc = new EUR_CRM_Account__c(id = wrapAccounts[i].euAccount.Id); //Reserve an account
                    con.contextItem = (String) wrapAccounts[i].euAccount.Id;
                    con.doSelectItem();
                }
            }
            
            // Publish selected accounts
            con.publish();
            List<EUR_CRM_ObjPromo_Account_Mapping__c> insertedOPAccountMappings = [SELECT Id FROM EUR_CRM_ObjPromo_Account_Mapping__c];
            //System.assertEquals(insertedOPAccountMappings.size(), con.selectedAccounts.size());
            
            // Since it's quicksave, objective shouldn't be marked as active
            //System.assertNotEquals(objPromo.EUR_CRM_Status__c, 'Active');
            
            
            // Open the same page again and check if the same accounts are checked
            publishObjectivePage = Page.EUR_CRM_ZA_PublishObjectivePage;
            sc = new ApexPages.StandardController(objPromo);
            con = new EUR_CRM_ZA_PublishObjectivePageCtrl(sc);
            con.con.setPageSize(pageSize);
            Test.setCurrentPage(publishObjectivePage);
            
            //wrapAccounts = con.getWrapAccounts();
            // Check if 10 items are selected
            //System.assertEquals(con.selectedAccounts.size(), pageSize);            
            
            Test.StopTest();

       
            acc.EUR_CRM_Status__c = 'Inactive';
            update acc;
            acc.EUR_CRM_Status__c = 'Active';
            update acc;
        }
    }

        /**
    * testMethod: testOPStatusChange
    * test EUR_CRM_ZA_OPAccountFlowHandler
    */
    /*static testMethod void testQuicksave() {
        setUser('EUR SSA Admin');
        System.runAs(testUser) {
            Integer numOfOffTradeAccounts = 100;
            Integer numOfOnTradeAccounts = 50;
            dataInsert(numOfOffTradeAccounts, numOfOnTradeAccounts);
        }
    }*/
}