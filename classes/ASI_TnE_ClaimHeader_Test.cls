/*********************************************************************************
 * Name:ASI_TnE_ClaimHeader_Test
 * Description: Test Class for ASI TnE Claim Header
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 11/05/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_TnE_ClaimHeader_Test {
    //For calculate tax rate & generate account number
    static testMethod void ASI_TnE_ClaimHeader_Test() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();
        ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
        ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail');
        detail.ASI_TnE_Receipt_Date__c = date.today().addDays(1);
        
        update detail;
        detail.ASI_TnE_Tax_Inclusive__c = false;
    
        test.startTest();
        update detail;
        
        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        detail.ASI_TnE_Expense_Classification__c = cls.Id;
        detail.ASI_TnE_Market_Charged_To__c = 'Vietnam';
        detail.ASI_TnE_Tax_Inclusive__c = true;
        update detail;
        test.stopTest();
    }
    
    //just test delete
    static testMethod void ASI_TnE_ClaimHeader_Test3() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();
        ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
        ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail');
        
        test.startTest();
        delete detail;
        test.stopTest();
    }
    
    //For calculate tax rate & generate account number
    static testMethod void ASI_TnE_ClaimHeader_Test2() {
        User u1 = ASI_TnE_TestClassHelper.newUser('testUser');
        u1.ASI_TnE_Department_Code__c = '0123456789';
        insert u1;
        System.runAs(u1){
            ASI_TnE_TestClassHelper.createTaxDateMapping();
            ASI_TnE_TestClassHelper.createRunningNumbers();
            ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
            ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail');
            test.startTest();
            ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
            ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
            ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
            cls.ASI_TnE_DM_BS__c = 'testtest';
            update cls;
            detail.ASI_TnE_Expense_Classification__c = cls.Id;
            detail.ASI_TnE_Market_Charged_To__c = 'Vietnam';
            update detail;
            test.stopTest();
        }
    }
    
    @isTest
    static void exportTOAPController_Test2() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();
        
        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        update testPayee;
        
        ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
        ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail');
        
        header.ASI_TnE_Type__c = 'Corp Card';
        header.ASI_TnE_Status__c = 'Draft';
        // DC - 01/28/2016 - Updated CLaim Header data to match with required data in Controller.
        header.ASI_TnE_AP_Sync__c = NULL;
        header.ASI_TnE_Sync_to_JDE_Date__c = NULL;
        header.ASI_TnE_Payee_Supplier__c = testPayee.Id;
        update header;
        System.debug('------ Limits.getQueries() 1 ------ : ' + Limits.getQueries());
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<Group> groupListEx = new List<Group>();
        
        // DC - 01/28/2016 - Added logic for creation of groups for TW, ID, PH.
        Group twGroup = new Group(Name='ASI_TnE_TW_Finance_Users', DoesIncludeBosses = false, developername='ASI_TnE_TW_Finance_Users');
        groupListEx.add(twGroup);

        Group idGroup = new Group(Name='ASI_TnE_ID_Finance_Users', DoesIncludeBosses = false, developername='ASI_TnE_ID_Finance_Users');
        groupListEx.add(idGroup);

        Group phGroup = new Group(Name='ASI_TnE_PH_Finance_Users', DoesIncludeBosses = false, developername='ASI_TnE_PH_Finance_Users');
        groupListEx.add(twGroup);
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        
        insert u;
        
        System.runAs(u) {
            //insert groupListEx;
        }
        
        PageReference pageRef = Page.ASI_TnE_ExportToAp_Page;
        Test.setCurrentPage(pageRef);
        
        ASI_TnE_ExportToAp_Controller exportTOAPController = new ASI_TnE_ExportToAp_Controller();
        exportTOAPController.claimHeaderInstance.ASI_TnE_KR_GL_Date__c = Date.today();
        System.debug('------ exportTOAPController.tneTypeFilter plain ------ : ' + exportTOAPController.tneTypeFilter);
        System.debug('------ exportTOAPController.developerNameFilter plain ------ : ' + exportTOAPController.developerNameFilter);
        exportTOAPController.updateVoucher();
        // DC - 01/28/2016 - Called methods for improving the coverage.
        exportTOAPController.updateVoucherHSBC();
        exportTOAPController.updateVoucherAmex();
        exportTOAPController.reportID = NULL;
        exportTOAPController.reportHSBCID = NULL;
        exportTOAPController.reportAMEXID = NULL;
        exportTOAPController.afterSyncReportID = NULL;
        exportTOAPController.afterSyncReportHSBCID = NULL;
        exportTOAPController.afterSyncReportAMEXID = NULL;
        
        Map<String, ID> groupMap = new Map<String, ID>();
        
        Set<String> nameGroupFilter = new Set<String>();
        nameGroupFilter.add('ASI_TnE_TW_Finance_Users');
        nameGroupFilter.add('ASI_TnE_ID_Finance_Users');
        nameGroupFilter.add('ASI_TnE_PH_Finance_Users');
        
        List<Group> financeGroupList = [SELECT ID, name, developername FROM GROUP WHERE developername IN : nameGroupFilter];
        
        test.starttest();
        
        for(Group financeGroupItem : financeGroupList) {
            groupMap.put(financeGroupItem.developername, financeGroupItem.id);
        }
        
        ID twFinanceGroup = groupMap.get('ASI_TnE_TW_Finance_Users');
        ID idFinanceGroup = groupMap.get('ASI_TnE_ID_Finance_Users');
        ID phFinanceGroup = groupMap.get('ASI_TnE_PH_Finance_Users');
        
        List<User> userToInsert = new List<User>();
        
        User uTW = new User(Alias = 'standt5', Email='standarduser5@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test15@laputa.com');
        
        userToInsert.add(uTW);
        
        User uID = new User(Alias = 'standt6', Email='standarduser6@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test16@laputa.com');
            
        userToInsert.add(uID);

        User uPH = new User(Alias = 'standt7', Email='standarduser7@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test17@laputa.com');
            
        userToInsert.add(uPH);

        insert userToInsert;
        
        List<GroupMember> groupMemberToInsert = new List<GroupMember>();
        
        GroupMember GMTW = new GroupMember( Groupid=twFinanceGroup, UserOrGroupId=uTW.id);
        groupMemberToInsert.add(GMTW);

        GroupMember GMID = new GroupMember( Groupid=idFinanceGroup, UserOrGroupId=uID.id);
        groupMemberToInsert.add(GMID);

        GroupMember GMPH = new GroupMember( Groupid=phFinanceGroup, UserOrGroupId=uPH.id);
        groupMemberToInsert.add(GMPH);
        
        System.runAs(u) {
            insert groupMemberToInsert;
        }
        
        // DC - 02/02/2016 - Run instances using TW, ID, PH users.
        System.runAs(uTW) {
            ASI_TnE_ExportToAp_Controller exportTOAPController5 = new ASI_TnE_ExportToAp_Controller();
            System.debug('------ exportTOAPController.tneTypeFilter uTH ------ : ' + exportTOAPController5.tneTypeFilter);
            System.debug('------ exportTOAPController.developerNameFilter uTH ------ : ' + exportTOAPController5.developerNameFilter);
        }
        
        System.runAs(uID) {
            ASI_TnE_ExportToAp_Controller exportTOAPController6 = new ASI_TnE_ExportToAp_Controller();
            System.debug('------ exportTOAPController.tneTypeFilter uID ------ : ' + exportTOAPController6.tneTypeFilter);
            System.debug('------ exportTOAPController.developerNameFilter uID ------ : ' + exportTOAPController6.developerNameFilter);
        }

        System.runAs(uPH) {
            ASI_TnE_ExportToAp_Controller exportTOAPController7 = new ASI_TnE_ExportToAp_Controller();
            System.debug('------ exportTOAPController.tneTypeFilter uPH ------ : ' + exportTOAPController7.tneTypeFilter);
            System.debug('------ exportTOAPController.developerNameFilter uPH ------ : ' + exportTOAPController7.developerNameFilter);
        }
        
        test.stoptest();
    }
    
    @isTest
    static void exportToAPController_Test() {
        
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        update testPayee;
        
        ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
        ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail');
        
        header.ASI_TnE_Type__c = 'Corp Card';
        header.ASI_TnE_Status__c = 'Draft';
        // DC - 01/28/2016 - Updated CLaim Header data to match with required data in Controller.
        header.ASI_TnE_AP_Sync__c = NULL;
        header.ASI_TnE_Sync_to_JDE_Date__c = NULL;
        header.ASI_TnE_Payee_Supplier__c = testPayee.Id;
        update header;
        System.debug('------ Limits.getQueries() 1 ------ : ' + Limits.getQueries());
    
         
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<Group> groupListEx = new List<Group>();
        
        Group hkGroup = new Group(Name='ASI_TnE_HK_Finance_Users', DoesIncludeBosses = false, developername='ASI_TnE_HK_Finance_Users');
        groupListEx.add(hkGroup);
        
        Group sgGroup = new Group(Name='ASI_TnE_SG_Finance_Users', DoesIncludeBosses = false, developername='ASI_TnE_SG_Finance_Users');
        groupListEx.add(sgGroup);
        
        Group myGroup = new Group(Name='ASI_TnE_MY_Finance_Users', DoesIncludeBosses = false, developername='ASI_TnE_MY_Finance_Users');
        groupListEx.add(myGroup);
        
        Group thGroup = new Group(Name='ASI_TnE_TH_Finance_Users', DoesIncludeBosses = false, developername='ASI_TnE_TH_Finance_Users');
        groupListEx.add(thGroup);
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        
        insert u;
        
        System.runAs(u) {
            //insert groupListEx;
        }
        
        PageReference pageRef = Page.ASI_TnE_ExportToAp_Page;
        Test.setCurrentPage(pageRef);
        
        ASI_TnE_ExportToAp_Controller exportTOAPController = new ASI_TnE_ExportToAp_Controller();
        exportTOAPController.claimHeaderInstance.ASI_TnE_KR_GL_Date__c = Date.today();
        System.debug('------ exportTOAPController.tneTypeFilter plain ------ : ' + exportTOAPController.tneTypeFilter);
        System.debug('------ exportTOAPController.developerNameFilter plain ------ : ' + exportTOAPController.developerNameFilter);
        exportTOAPController.updateVoucher();
        // DC - 01/28/2016 - Called methods for improving the coverage.
        exportTOAPController.updateVoucherHSBC();
        exportTOAPController.updateVoucherAmex();
        exportTOAPController.reportID = NULL;
        exportTOAPController.reportHSBCID = NULL;
        exportTOAPController.reportAMEXID = NULL;
        exportTOAPController.afterSyncReportID = NULL;
        exportTOAPController.afterSyncReportHSBCID = NULL;
        exportTOAPController.afterSyncReportAMEXID = NULL;
        
        Map<String, ID> groupMap = new Map<String, ID>();
        
        Set<String> nameGroupFilter = new Set<String>();
        nameGroupFilter.add('ASI_TnE_HK_Finance_Users');
        nameGroupFilter.add('ASI_TnE_TH_Finance_Users');
        nameGroupFilter.add('ASI_TnE_SG_Finance_Users');
        nameGroupFilter.add('ASI_TnE_MY_Finance_Users');
        
        List<Group> financeGroupList = [SELECT ID, name, developername FROM GROUP WHERE developername IN : nameGroupFilter];
        
        test.starttest();
        
        for(Group financeGroupItem : financeGroupList) {
            groupMap.put(financeGroupItem.developername, financeGroupItem.id);
        }
        
        ID hkFinanceGroup = groupMap.get('ASI_TnE_HK_Finance_Users');
        ID thFinanceGroup = groupMap.get('ASI_TnE_TH_Finance_Users');
        ID myFinanceGroup = groupMap.get('ASI_TnE_MY_Finance_Users');
        ID sgFinanceGroup = groupMap.get('ASI_TnE_SG_Finance_Users');
        
        List<User> userToInsert = new List<User>();
        
        User uHK = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test11@laputa.com');
            
        userToInsert.add(uHK);
        
        User uTH = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test12@laputa.com');
            
        userToInsert.add(uTH);

        User uMY = new User(Alias = 'standt3', Email='standarduser3@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test13@laputa.com');
            
        userToInsert.add(uMY);
        
        User uSG = new User(Alias = 'standt4', Email='standarduser4@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test14@laputa.com');
            
        userToInsert.add(uSG);

        insert userToInsert;
        
        List<GroupMember> groupMemberToInsert = new List<GroupMember>();
        
        GroupMember GMHK = new GroupMember( Groupid=hkFinanceGroup, UserOrGroupId=uHK.id);
        groupMemberToInsert.add(GMHK);
        
        GroupMember GMTH = new GroupMember( Groupid=thFinanceGroup, UserOrGroupId=uTH.id);
        groupMemberToInsert.add(GMTH);
        
        GroupMember GMMY = new GroupMember( Groupid=myFinanceGroup, UserOrGroupId=uMY.id);
        groupMemberToInsert.add(GMMY);
        
        GroupMember GMSG = new GroupMember( Groupid=sgFinanceGroup, UserOrGroupId=uSG.id);
        groupMemberToInsert.add(GMSG);
        
        System.runAs(u) {
            insert groupMemberToInsert;
        }
        System.runAs(uHK) {
            ASI_TnE_ExportToAp_Controller exportTOAPController1 = new ASI_TnE_ExportToAp_Controller();
            System.debug('------ exportTOAPController.tneTypeFilter uHK ------ : ' + exportTOAPController1.tneTypeFilter);
            System.debug('------ exportTOAPController.developerNameFilter uHK ------ : ' + exportTOAPController1.developerNameFilter);
            exportTOAPController1.updateVoucherHSBC();
        }
        
        System.runAs(uSG) {
            ASI_TnE_ExportToAp_Controller exportTOAPController2 = new ASI_TnE_ExportToAp_Controller();
            System.debug('------ exportTOAPController.tneTypeFilter uSG ------ : ' + exportTOAPController2.tneTypeFilter);
            System.debug('------ exportTOAPController.developerNameFilter uSG ------ : ' + exportTOAPController2.developerNameFilter);
        }
        
        System.runAs(uMY) {
            ASI_TnE_ExportToAp_Controller exportTOAPController3 = new ASI_TnE_ExportToAp_Controller();
            System.debug('------ exportTOAPController.tneTypeFilter uMY ------ : ' + exportTOAPController3.tneTypeFilter);
            System.debug('------ exportTOAPController.developerNameFilter uMY ------ : ' + exportTOAPController3.developerNameFilter);
        }
        
        System.runAs(uTH) {
            ASI_TnE_ExportToAp_Controller exportTOAPController4 = new ASI_TnE_ExportToAp_Controller();
            System.debug('------ exportTOAPController.tneTypeFilter uTH ------ : ' + exportTOAPController4.tneTypeFilter);
            System.debug('------ exportTOAPController.developerNameFilter uTH ------ : ' + exportTOAPController4.developerNameFilter);
        }

        System.debug('------ Limits.getQueries() 1.1------ : ' + Limits.getQueries());

        test.stoptest();
    }

    // DC - 02/02/2016 - Added following methods for class "ASI_TnE_ClaimsDetailGenAccountNo"
    @isTest
    static void claimsDetailGenAccountNo_InsertTest1() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c, CompanyName, Department FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.CompanyName = 'test';
        u.Department = 'test';
        update u;
        ASI_TnE_TestClassHelper.createRouteType(u,1);
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        System.Test.startTest();
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TH_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId(),ASI_TnE_Sys_Exceed_Budget__c=true
        );
        insert header;

        
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TH_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_InsertTest2() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_InsertTest3() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;

        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        ASI_TnE_Employee_Code_Mapping__c mcc = new ASI_TnE_Employee_Code_Mapping__c(
            ASI_TnE_Department_Code__c = 'TestDC1',
            ASI_TnE_Employee_Code__c = 'TestEC1',
            ASI_TnE_Employee_Name__c = UserInfo.getUserId(),
            ASI_TnE_Market__c = 'Singapore',
            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TH_Employee_Code_Mapping')
        );
        insert mcc;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_Market_Charged_To__c = 'Singapore',
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_InsertTest4() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;

        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TH_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TH_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            // ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_InsertTest5() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        cls.ASI_TnE_DM_BS__c = 'testtest';
        update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;

        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TH_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TH_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            // ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest6() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            // ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest7() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TH_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TH_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            // ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest8() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest9() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        cls.ASI_TnE_DM_BS__c = 'testtest';
        update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest10() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;

        ASI_TnE_Employee_Code_Mapping__c mcc = new ASI_TnE_Employee_Code_Mapping__c(
            ASI_TnE_Department_Code__c = 'TestDC1',
            ASI_TnE_Employee_Code__c = 'TestEC1',
            ASI_TnE_Employee_Name__c = UserInfo.getUserId(),
            ASI_TnE_Market__c = 'Singapore',
            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TH_Employee_Code_Mapping')
        );
        insert mcc;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 100,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_Market_Charged_To__c = 'Singapore',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest11() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;

        ASI_TnE_Employee_Code_Mapping__c mcc = new ASI_TnE_Employee_Code_Mapping__c(
            ASI_TnE_Department_Code__c = 'TestDC1',
            ASI_TnE_Employee_Code__c = 'TestEC1',
            ASI_TnE_Employee_Name__c = UserInfo.getUserId(),
            ASI_TnE_Market__c = 'Singapore',
            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TH_Employee_Code_Mapping')
        );
        insert mcc;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_Market_Charged_To__c = 'Singapore',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail'),
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest12() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;

        ASI_TnE_Employee_Code_Mapping__c mcc = new ASI_TnE_Employee_Code_Mapping__c(
            ASI_TnE_Department_Code__c = 'TestDC1',
            ASI_TnE_Employee_Code__c = 'TestEC1',
            ASI_TnE_Employee_Name__c = UserInfo.getUserId(),
            ASI_TnE_Market__c = 'Singapore',
            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TH_Employee_Code_Mapping')
        );
        insert mcc;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_Market_Charged_To__c = 'Singapore',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail'),
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest13() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        testPayee.ASI_LUX_Email_Business__c = 'test@email.com';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;
        
        ASI_MFM_AP_Code__c apCode = new ASI_MFM_AP_Code__c(
            Name='testApCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_AP_Code'),
            ASI_MFM_A_C_Code__c = acCode.id
        );
        insert apCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final',
            ASI_MFM_Owner_Link__c = UserInfo.getUserId()
        );
        
        insert plan;
        
        ASI_MFM_Plan_Line_Item__c plan_line = new ASI_MFM_Plan_Line_Item__c
        (
            ASI_MFM_Plan__c = plan.id,
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'),
            ASI_MFM_T_E__c = true,
            ASI_MFM_Total_Cost__c = 1000,
            ASI_MFM_AP_Code__c = apCode.id,
            ASI_MFM_A_C_Code__c = acCode.id,
            ASI_MFM_List_Item_Description__c = 'test',
            ASI_MFM_BU_Code__c = buCode.id
        );
        insert plan_line;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;

        ASI_TnE_Employee_Code_Mapping__c mcc = new ASI_TnE_Employee_Code_Mapping__c(
            ASI_TnE_Department_Code__c = 'TestDC1',
            ASI_TnE_Employee_Code__c = 'TestEC1',
            ASI_TnE_Employee_Name__c = UserInfo.getUserId(),
            ASI_TnE_Market__c = 'Singapore',
            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TH_Employee_Code_Mapping')
        );
        insert mcc;
        
        System.Test.startTest();
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;
        
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_CAP_Plan__c = plan.Id,
            ASI_TnE_Market_Charged_To__c = 'Singapore',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TH_Claim_Detail'),
            ASI_TnE_SubBrand__c = testSub.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest14() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'AFFILIATE';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        cls.ASI_TnE_DM_BS__c = 'testtest';
        update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
            // ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_Expense_Classification__c = cls.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_Market_Charged_To__c = 'Singapore'
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_InsertTest15() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        // cls.ASI_TnE_DM_BS__c = 'testtest';
        // update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TH_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TH_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_InsertTest16() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        cls.ASI_TnE_DM_BS__c = 'testtest';
        update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id,
            ASI_TnE_MFM_PO__c = po.Id
        );
        insert detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest17() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'testAddress';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        cls.ASI_TnE_DM_BS__c = 'testtest';
        update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            // ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            ASI_TnE_Expense_Classification__c = cls.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TH_Claim_Detail'),
            // ASI_TnE_SubBrand__c = testSub.Id,
            // ASI_TnE_Market_Charged_To__c = 'Singapore',
            ASI_TnE_MFM_PO__c = po.Id
        );
        update detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest18() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'AFFILIATE';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        cls.ASI_TnE_DM_BS__c = 'testtest';
        update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            // ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id
        );
        insert detail;
        System.Test.stopTest();
    }

    @isTest
    static void claimsDetailGenAccountNo_UpdateTest19() {
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();

        Account testPayee = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testPayee.Name += 'HSBC AMERICAN EXPRESS';
        testPayee.Billing_Address__c = 'testAddress';
        testPayee.Revenue_Address__c = 'testAddress';
        testPayee.Shipping_Address__c = 'testAddress';
        testPayee.ASI_HK_CRM_Address__c = 'AFFILIATE';
        update testPayee;

        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
        cls.ASI_TnE_DM_BS__c = 'testtest';
        update cls;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c testSub = new ASI_MFM_Sub_brand__c(
            Name = 'test Sub',
            ASI_MFM_Sub_brand_Code__c = '00221'
        );
        insert testSub;

        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'HK';
        u.ASI_TnE_Department_Code__c = 'DeptCode12';
        update u;
        ASI_MFM_Prefix__c prefixCapPlan = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'Plan',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCapPlan;

        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c relPlan = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert relPlan;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan123',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
            ASI_MFM_Prefix__c = prefixCapPlan.id,
            ASI_MFM_Plan_Type__c = 'CAPEX',
            ASI_MFM_Status__c = 'Final'

        );
        
        insert plan;

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'PO16',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1516'
        );
        insert prefixCap;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'CAPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Invoice_Amount_from_JDE__c = 10,
            ASI_MFM_T_E_Amount__c = 10,
            ASI_MFM_T_E_Amount_Posted__c = 100,
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'),
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Plan__c = plan.Id
        );
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Base_Currency_Amount__c = 100000,//20170712
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')
        );
        insert poLine;
        update poLine;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = '1234567', ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(), ASI_TnE_Payee_Employee__c = UserInfo.getUserId()
        );
        insert header;

        System.Test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.Id,
            ASI_TnE_Receipt_Date__c = date.today(),
            ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',
            ASI_TnE_Receipt_Amount__c = 1,
            ASI_TnE_FX_Rate__c = 0.254,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail'),
            // ASI_TnE_Expense_Classification__c = cls.Id,
            // ASI_TnE_BU__c= buCode.Id,
            // ASI_TnE_Charge_To_Acc__c = testPayee.Id,
            // ASI_TnE_SubBrand__c = testSub.Id,
            ASI_TnE_A_C_Code__c = acCode.Id
        );
        insert detail;

        detail = new ASI_TnE_ClaimDetail__c(
            Id = detail.Id,
            ASI_TnE_Expense_Classification__c = cls.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail'),
            // ASI_TnE_SubBrand__c = testSub.Id,
            // ASI_TnE_Market_Charged_To__c = 'Singapore',
            ASI_TnE_MFM_PO__c = po.Id
        );
        update detail;

        System.Test.stopTest();
    }
}