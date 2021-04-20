@isTest
private class EUR_CRM_SelectCustTaxComponentTest {
    
    static testmethod void test() {
        List<EUR_CRM_Account__c> euaccount = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> euaccountUpdate = new List<EUR_CRM_Account__c>();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy = new EUR_CRM_Customer_Taxonomy__c();
        EUR_CRM_OP_Customer_Taxonomy_Mapping__c CustomerTaxonomyMapping =new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccounts('Test EU ACCOUNT',5);
        insert euaccount;
        
        update euaccountUpdate;
        
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;
        // Create Promo
        List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(10,'EUR_RU_ON_Trade_Phase_1','Test Promo',template);
        List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
        for(EUR_CRM_ObjPromo__c p: promos){
            p.EUR_CRM_Status__c='Draft';
            p.EUR_CRM_Active_End_Date__c = Date.today();
            p.EUR_CRM_CustomerTaxonomy_Chain__c = 'JACKO';
            p.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'JACKO1';
            p.EUR_CRM_Customer_Taxonomy_Chain_Region__c = 'REG1';
            
            promosToInsert.add(p);
        }
        insert promosToInsert;
        
        List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_RU_TestClassHelper.createOPAccountMapping(10,'EUR_RU_O_P_Account_Mapping',euaccount[0],promosToInsert[0]);
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
            m.EUR_CRM_Is_Active__c = true;
            m.EUR_CRM_Evaluation_Required__c = false;
            opMappingToInsert.add(m);
        }
        insert opMappingToInsert;
        
        EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
        insert objPromoAction;
        
        EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount[0],promosToInsert[0]);
        visitAction.EUR_CRM_Stage__c = 'Execution';
        visitAction.EUR_CRM_Status__c ='Participating';
        insert visitAction;
        
        CustomerTaxonomy = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomy('test taxonomy', UserInfo.getUserId(), 'EUR RU OFF Trade Customer Taxonomy');
        
        CustomerTaxonomyMapping = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomyMapping(CustomerTaxonomy,promosToInsert[0],'EUR RU O/P - Customer Taxonomy Mapping');
        insert CustomerTaxonomyMapping;
        
        Test.startTest();
        EUR_CRM_SelectCustTaxComponentExtCtrller con =new EUR_CRM_SelectCustTaxComponentExtCtrller();
        con.countryCode = 'RU';
        con.fieldsStr = 'EUR_CRM_Region__c';
        ApexPages.StandardSetController cont = con.con;
        ApexPages.StandardSetController accCon = con.accCon;
        con.objPromoIdStr = promosToInsert[0].Id;
        try{
            Boolean initDummyVar = con.initDummyVar;
        }
        catch(exception e){}
        con.getIsRegionIncluded();
        con.getIsSubChainIncluded();
        con.getIsLevel1Included();
        con.getSubChainOptions();
        con.getRegionOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.setCon1();
        con.getTaxList();
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer pageNumber = con.pageNumber;
        con.first();
        con.last();
        con.previous();
        con.next();
        con.getPages();
        con.getRecordSize();
        con.getPageSize();
        con.retrieveAccounts();
        con.sort();
        con.doNext();
        con.doPrevious();
        con.accConFirst();
        con.accConLast();
        con.getHasPrevious();
        con.getAccConPageNumber();
        con.getTotalPages();
        Integer accConPageNumber = con.accConPageNumber;
        con.getAccConPageSize();
        con.getAccConRecordSize();
        String s = con.contextItem;
        con.doSelectItem();
        con.getSelectedAccounts();
        con.doDeselectItem();
        con.getHasSelectedAccounts();
        con.getIsDeactivated();
        con.saveAccounts();
        con.quickSaveContinue();
        Boolean isRemoveOldOPAccountMapping = con.isRemoveOldOPAccountMapping;
        List<EUR_CRM_Account__c> euAccountList = con.euAccountList;
        Boolean isSelectorRendered = con.isSelectorRendered;
        String custMappingRecordTypeStr = con.custMappingRecordTypeStr;
        Boolean limitFieldsBool = con.limitFieldsBool;
        ApexPages.StandardController standardController = con.standardController;
        con.getIsLevel2Included();
        con.getChainOptions();
        con.getHasNext();
        
        con.getIsBannerIncluded();
        con.getIsGroupIncluded();
        con.getBannerOptions();
        con.getGroupOptions();
        
        EUR_CRM_SelectCustTaxComponentExtCtrller.euAccountsWrapper testWrapper = new EUR_CRM_SelectCustTaxComponentExtCtrller.euAccountsWrapper(euaccount[0],true);
        
        
        Set<Id> existingOPAccountIds = new Set<Id>();
        existingOPAccountIds.add(euaccount[0].Id);
        con.removeDuplicateOPAccounts(existingOPAccountIds,opMappingToInsert);
        
        try{
            con.filter();
        }
        catch(exception e){}
        
        Test.stopTest();
        
    }
    
    static testmethod void test2() {
        List<EUR_CRM_Account__c> euaccount = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> euaccountUpdate = new List<EUR_CRM_Account__c>();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy = new EUR_CRM_Customer_Taxonomy__c();
        EUR_CRM_OP_Customer_Taxonomy_Mapping__c CustomerTaxonomyMapping =new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccounts('Test EU ACCOUNT',5);
        insert euaccount;
        
        
        
        
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;
        // Create Promo
        List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(10,'EUR_RU_ON_Trade_Phase_1','Test Promo',template);
        List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
        for(EUR_CRM_ObjPromo__c p: promos){
            p.EUR_CRM_Status__c='Active';
            p.EUR_CRM_Active_End_Date__c = Date.today();
            p.EUR_CRM_CustomerTaxonomy_Chain__c = 'JACKO';
            p.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'JACKO1';
            p.EUR_CRM_Customer_Taxonomy_Chain_Region__c = 'REG1';
            
            promosToInsert.add(p);
        }
        insert promosToInsert;
        
        List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_RU_TestClassHelper.createOPAccountMapping(10,'EUR_RU_O_P_Account_Mapping',euaccount[0],promosToInsert[0]);
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
            m.EUR_CRM_Is_Active__c = true;
            m.EUR_CRM_Evaluation_Required__c = false;
            opMappingToInsert.add(m);
        }
        insert opMappingToInsert;
        
        EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
        insert objPromoAction;
        
        EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount[0],promosToInsert[0]);
        visitAction.EUR_CRM_Stage__c = 'Execution';
        visitAction.EUR_CRM_Status__c ='Participating';
        insert visitAction;
        
        CustomerTaxonomy = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomy('test taxonomy', UserInfo.getUserId(), 'EUR RU OFF Trade Customer Taxonomy');
        
        CustomerTaxonomyMapping = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomyMapping(CustomerTaxonomy,promosToInsert[0],'EUR RU O/P - Customer Taxonomy Mapping');
        insert CustomerTaxonomyMapping;
        
        for(EUR_CRM_Account__c acc:euaccount){
            acc.EUR_JB_Customer_Taxonomy__c = CustomerTaxonomy.Id;
            euaccountUpdate.add(acc);
        }
        update euaccountUpdate;
        
        Test.startTest();
        EUR_CRM_SelectCustTaxComponentExtCtrller con =new EUR_CRM_SelectCustTaxComponentExtCtrller();
        con.countryCode = 'RU';
        con.fieldsStr = 'EUR_CRM_Region__c';
        con.objPromo = promosToInsert[0];
        ApexPages.StandardSetController cont = con.con;
        ApexPages.StandardSetController accCon = con.accCon;
        con.objPromoIdStr = promosToInsert[0].Id;
        try{
            Boolean initDummyVar = con.initDummyVar;
        }
        
        catch(exception e){}
        ApexPages.StandardSetController accCon2 = con.accCon;
        con.getIsRegionIncluded();
        con.getIsSubChainIncluded();
        con.getIsLevel1Included();
        con.getSubChainOptions();
        con.getRegionOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.setCon1();
        con.getTaxList();
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer pageNumber = con.pageNumber;
        con.first();
        con.last();
        con.previous();
        con.next();
        con.getPages();
        con.getRecordSize();
        con.getPageSize();
        con.retrieveAccounts();
        con.sort();
        con.doNext();
        con.doPrevious();
        con.accConFirst();
        con.accConLast();
        con.getHasPrevious();
        con.getAccConPageNumber();
        con.getTotalPages();
        Integer accConPageNumber = con.accConPageNumber;
        con.getAccConPageSize();
        con.getAccConRecordSize();
        String s = con.contextItem;
        con.doSelectItem();
        con.getSelectedAccounts();
        con.doDeselectItem();
        con.getHasSelectedAccounts();        
        con.getIsDeactivated();
        con.saveAccounts();
        con.quickSaveContinue();
        Boolean isRemoveOldOPAccountMapping = con.isRemoveOldOPAccountMapping;
        List<EUR_CRM_Account__c> euAccountList = con.euAccountList;
        Boolean isSelectorRendered = con.isSelectorRendered;
        String custMappingRecordTypeStr = con.custMappingRecordTypeStr;
        Boolean limitFieldsBool = con.limitFieldsBool;
        ApexPages.StandardController standardController = con.standardController;
        con.getIsLevel2Included();
        con.getChainOptions();
        con.getHasNext();
        
        Set<Id> existingOPAccountIds = new Set<Id>();
        existingOPAccountIds.add(euaccount[0].Id);
        con.removeDuplicateOPAccounts(existingOPAccountIds,opMappingToInsert);
        
        try{
            con.filter();
        }
        catch(exception e){}
        
        Test.stopTest();
        
    }
    
    static testmethod void test3() {
        List<EUR_CRM_Account__c> euaccount = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> euaccountUpdate = new List<EUR_CRM_Account__c>();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy = new EUR_CRM_Customer_Taxonomy__c();
        EUR_CRM_OP_Customer_Taxonomy_Mapping__c CustomerTaxonomyMapping =new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccounts('Test EU ACCOUNT',5);
        insert euaccount;
        
        
        
        
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;
        // Create Promo
        List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(10,'EUR_RU_ON_Trade_Phase_1','Test Promo',template);
        List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
        for(EUR_CRM_ObjPromo__c p: promos){
            p.EUR_CRM_Status__c='Active';
            p.EUR_CRM_Active_End_Date__c = Date.today();
            p.EUR_CRM_CustomerTaxonomy_Chain__c = 'JACKO';
            p.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'JACKO1';
            p.EUR_CRM_Customer_Taxonomy_Chain_Region__c = 'REG1';
            
            promosToInsert.add(p);
        }
        insert promosToInsert;
        
        List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_RU_TestClassHelper.createOPAccountMapping(10,'EUR_RU_O_P_Account_Mapping',euaccount[0],promosToInsert[0]);
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
            m.EUR_CRM_Is_Active__c = true;
            m.EUR_CRM_Evaluation_Required__c = false;
            opMappingToInsert.add(m);
        }
        insert opMappingToInsert;
        
        EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
        insert objPromoAction;
        
        EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount[0],promosToInsert[0]);
        visitAction.EUR_CRM_Stage__c = 'Execution';
        visitAction.EUR_CRM_Status__c ='Participating';
        insert visitAction;
        
        CustomerTaxonomy = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomy('test taxonomy', UserInfo.getUserId(), 'EUR RU OFF Trade Customer Taxonomy');
        
        CustomerTaxonomyMapping = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomyMapping(CustomerTaxonomy,promosToInsert[0],'EUR RU O/P - Customer Taxonomy Mapping');
        insert CustomerTaxonomyMapping;
        
        for(EUR_CRM_Account__c acc:euaccount){
            acc.EUR_JB_Customer_Taxonomy__c = CustomerTaxonomy.Id;
            euaccountUpdate.add(acc);
        }
        update euaccountUpdate;
        
        Test.startTest();
        EUR_CRM_SelectCustTaxComponentExtCtrller con =new EUR_CRM_SelectCustTaxComponentExtCtrller();
        con.countryCode = 'RU';
        con.fieldsStr = 'EUR_CRM_Region__c';
        con.objPromo = promosToInsert[0];
        con.isMultiSelectEnabled = True;
        ApexPages.StandardSetController cont = con.con;
        ApexPages.StandardSetController accCon = con.accCon;
        con.objPromoIdStr = promosToInsert[0].Id;
        try{
            Boolean initDummyVar = con.initDummyVar;
        }
        
        catch(exception e){}
        ApexPages.StandardSetController accCon2 = con.accCon;
        con.getIsRegionIncluded();
        con.getIsSubChainIncluded();
        con.getIsLevel1Included();
        con.getSubChainOptions();
        con.getRegionOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.setCon1();
        con.getTaxList();
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer pageNumber = con.pageNumber;
        con.first();
        con.last();
        con.previous();
        con.next();
        con.getPages();
        con.getRecordSize();
        con.getPageSize();
        con.retrieveAccounts();
        con.sort();
        con.doNext();
        con.doPrevious();
        con.accConFirst();
        con.accConLast();
        con.getHasPrevious();
        con.getAccConPageNumber();
        con.getTotalPages();
        Integer accConPageNumber = con.accConPageNumber;
        con.getAccConPageSize();
        con.getAccConRecordSize();
        String s = con.contextItem;
        con.doSelectItem();
        con.getSelectedAccounts();
        con.doDeselectItem();
        con.getHasSelectedAccounts();
        con.getIsDeactivated();
        con.saveAccounts();
        con.quickSaveContinue();
        Boolean isRemoveOldOPAccountMapping = con.isRemoveOldOPAccountMapping;
        List<EUR_CRM_Account__c> euAccountList = con.euAccountList;
        Boolean isSelectorRendered = con.isSelectorRendered;
        String custMappingRecordTypeStr = con.custMappingRecordTypeStr;
        Boolean limitFieldsBool = con.limitFieldsBool;
        ApexPages.StandardController standardController = con.standardController;
        con.getIsLevel2Included();
        con.getChainOptions();
        con.getHasNext();
        
        Set<Id> existingOPAccountIds = new Set<Id>();
        existingOPAccountIds.add(euaccount[0].Id);
        con.removeDuplicateOPAccounts(existingOPAccountIds,opMappingToInsert);
        
        try{
            con.filter();
        }
        catch(exception e){}
        
        Test.stopTest();
        
    }
    
    static testmethod void test4() {
        List<EUR_CRM_Account__c> euaccount = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> euaccountUpdate = new List<EUR_CRM_Account__c>();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy = new EUR_CRM_Customer_Taxonomy__c();
        EUR_CRM_OP_Customer_Taxonomy_Mapping__c CustomerTaxonomyMapping =new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccounts('Test EU ACCOUNT',5);
        for (EUR_CRM_Account__c acc : euaccount){
            acc.eur_crm_status__c = 'Active';
        }
        insert euaccount;
        
        
        
        
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        template.recordtypeId = EUR_CRM_RU_TestClassHelper.getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', 'EUR_BE_O_P_Action_List_Template');
        template.EUR_CRM_External_ID__c = 'BE_Off_Trade_Secondary_placement_Spyder_display';
        insert template;
        // Create Promo
        List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(10,'EUR_BE_Off_Trade_Secondary_placement_Spyder_display','Test Promo',template);
        List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
        for(EUR_CRM_ObjPromo__c p: promos){
            p.EUR_CRM_Status__c='Active';
            p.EUR_CRM_Active_End_Date__c = Date.today();
            p.EUR_CRM_CustomerTaxonomy_Chain__c = 'JACKO';
            p.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'JACKO1';
            p.EUR_CRM_Customer_Taxonomy_Chain_Region__c = 'REG1';
            
            promosToInsert.add(p);
        }
        insert promosToInsert;
        
        List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_RU_TestClassHelper.createOPAccountMapping(10,'EUR_BE_O_P_Account_Mapping',euaccount[0],promosToInsert[0]);
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
            m.EUR_CRM_Is_Active__c = true;
            m.EUR_CRM_Evaluation_Required__c = false;
            opMappingToInsert.add(m);
        }
        insert opMappingToInsert;
        
        EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
        insert objPromoAction;
        
        EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount[0],promosToInsert[0]);
        visitAction.EUR_CRM_Stage__c = 'Execution';
        visitAction.EUR_CRM_Status__c ='Participating';
        insert visitAction;
        
        CustomerTaxonomy = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomy('test taxonomy', UserInfo.getUserId(), 'EUR BE Customer Taxonomy');
        
        CustomerTaxonomyMapping = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomyMapping(CustomerTaxonomy,promosToInsert[0],'EUR RU O/P - Customer Taxonomy Mapping');
        insert CustomerTaxonomyMapping;
        
        for(EUR_CRM_Account__c acc:euaccount){
            acc.EUR_JB_Customer_Taxonomy__c = CustomerTaxonomy.Id;
            euaccountUpdate.add(acc);
        }
        update euaccountUpdate;
        
        Test.startTest();
        EUR_CRM_SelectCustTaxComponentExtCtrller con =new EUR_CRM_SelectCustTaxComponentExtCtrller();
        con.countryCode = 'BE';
        con.fieldsStr = 'EUR_CRM_Region__c';
        con.objPromo = promosToInsert[0];
        con.isMultiSelectEnabled = True;
        ApexPages.StandardSetController cont = con.con;
        ApexPages.StandardSetController accCon = con.accCon;
        con.objPromoIdStr = promosToInsert[0].Id;
        try{
            Boolean initDummyVar = con.initDummyVar;
        }
        
        catch(exception e){}
        ApexPages.StandardSetController accCon2 = con.accCon;
        con.getIsRegionIncluded();
        con.getIsSubChainIncluded();
        con.getIsLevel1Included();
        con.getSubChainOptions();
        con.getRegionOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.setCon1();
        con.getTaxList();
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer pageNumber = con.pageNumber;
        con.first();
        con.last();
        con.previous();
        con.next();
        con.getPages();
        con.getRecordSize();
        con.getPageSize();
        //con.euAccounts = euaccount;
        con.retrieveAccounts();
        con.sort();
        con.doNext();
        con.doPrevious();
        con.accConFirst();
        con.accConLast();
        con.getHasPrevious();
        con.getAccConPageNumber();
        con.getTotalPages();
        Integer accConPageNumber = con.accConPageNumber;
        con.getAccConPageSize();
        con.getAccConRecordSize();
        String s = con.contextItem;
        con.doSelectItem();
        con.getSelectedAccounts();
        con.doDeselectItem();
        con.getHasSelectedAccounts();
        con.getIsDeactivated();
        con.saveAccounts();
        con.quickSaveContinue();
        Boolean isRemoveOldOPAccountMapping = con.isRemoveOldOPAccountMapping;
        List<EUR_CRM_Account__c> euAccountList = con.euAccountList;
        Boolean isSelectorRendered = con.isSelectorRendered;
        String custMappingRecordTypeStr = con.custMappingRecordTypeStr;
        Boolean limitFieldsBool = con.limitFieldsBool;
        ApexPages.StandardController standardController = con.standardController;
        con.getIsLevel2Included();
        con.chainValue = '';
        con.getChainOptions();
        con.getHasNext();
        con.returnAllOnly();
        
        Set<Id> existingOPAccountIds = new Set<Id>();
        existingOPAccountIds.add(euaccount[0].Id);
        con.removeDuplicateOPAccounts(existingOPAccountIds,opMappingToInsert);
        
        try{
            con.filter();
        }
        catch(exception e){}
        
       Test.stopTest();
        
    }
}