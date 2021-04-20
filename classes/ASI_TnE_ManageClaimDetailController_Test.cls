@isTest
public class ASI_TnE_ManageClaimDetailController_Test{

    public testMethod static void unitTest1(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_VN_ClaimHeader'));
        insert header;

        ASI_TnE_ClaimDetail__c detail1 = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel', recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'));
        insert detail1;

        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    
    public testMethod static void unitTest2(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_HK_CRM_Running_Number__c runNum = new ASI_HK_CRM_Running_Number__c();
        runNum.ASI_HK_CRM_Object_Name__c = 'ASI_TnE_SG_Claim_Header';
        runNum.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        runNum.ASI_HK_CRM_Fiscal_Year__c = 2015;
        insert runNum;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header'), ASI_TnE_Status__c = 'Submitted');
        insert header;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    
    public testMethod static void unitTest3(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_HK_CRM_Running_Number__c runNum = new ASI_HK_CRM_Running_Number__c();
        runNum.ASI_HK_CRM_Object_Name__c = 'ASI_TnE_HK_Claim_Header';
        runNum.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        runNum.ASI_HK_CRM_Fiscal_Year__c = 2015;
        insert runNum;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'), ASI_TnE_Status__c = 'Submitted');
        insert header;

        /**
         *  DC - 01/29/2016 - Added Logic to improve coverage  for "ASI_TnE_ManageClaimDetailController"
         *  Please find single line comments on the lines added / changed as "DC - <Date of Change>"
         */
        // DC LOGIC START
        ASI_JP_TnE_Expense_Category__c expCategory
            = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_HK_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c expClassification
            = ASI_TnE_TestClassHelper.createExpenseCls(
                'ASI_JP_TnE_Expense_Classification__cASI_TnE_HK_Expense_Classification',
                expCategory,
                ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_HK_Account_Mapping')
            );

        expClassification.ASI_TnE_Read_Only_Fields__c = 'ASI_TnE_Tax_Inclusive';
        update expClassification;

        ASI_TnE_ClaimDetail__c detail1 = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel', recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'));
        insert detail1;

        ASI_MFM_Exchange_Rate__c exchgRate1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Country__c = 'HK',
            ASI_MFM_Counter_Currency__c = 'TWD',
            ASI_MFM_Effective_Date__c = Date.today().addDays(10),
            ASI_MFM_Exchange_Rate__c = 0.254,
            ASI_MFM_Base_Currency__c = 'HKD'
        );

        ASI_MFM_Exchange_Rate__c exchgRate2 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Country__c = 'HK',
            ASI_MFM_Counter_Currency__c = 'TWD',
            ASI_MFM_Effective_Date__c = Date.today().addDays(10),
            ASI_MFM_Exchange_Rate__c = 0.254,
            ASI_MFM_Base_Currency__c = 'HKD'
        );

        List<ASI_MFM_Exchange_Rate__c> lstExchgRate = new List<ASI_MFM_Exchange_Rate__c> {
            exchgRate1,
            exchgRate2
        };

        insert lstExchgRate;

        Account testAcc = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testAcc.Billing_Address__c = 'test address';
        testAcc.Revenue_Address__c = 'test address';
        testAcc.Shipping_Address__c = 'test address';
        testAcc.ASI_HK_CRM_Address__c = 'test address';
        update testAcc;      

        detail1.ASI_TnE_Expense_Classification__c = expClassification.Id;
        detail1.ASI_TnE_Expense_Category__c = expCategory.Id;
        detail1.ASI_TnE_Charge_To_Acc__c = testAcc.Id;
        update detail1;
        // DC LOGIC END
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        System.currentPageReference().getParameters().put('ROWID', '1');
        System.currentPageReference().getParameters().put('CATEGORY', expCategory.Id);
        System.currentPageReference().getParameters().put('CLASSIFICATION', expClassification.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.PARAM_CATEGORIES_IDS = at.detailWrapper[0].rowIndex + '-' + expCategory.Id; // DC - 01/29/2016
        at.PARAM_CLASSIFICATIONS_IDS = at.detailWrapper[0].rowIndex + '-' + expClassification.Id; // DC - 01/29/2016
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        at.assignClassification(); // DC - 01/29/2016
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    public testMethod static void unitTest4(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_HK_CRM_Running_Number__c runNum = new ASI_HK_CRM_Running_Number__c();
        runNum.ASI_HK_CRM_Object_Name__c = 'ASI_TnE_PH_Claim_Header';
        runNum.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        runNum.ASI_HK_CRM_Fiscal_Year__c = 2015;
        insert runNum;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_PH_Claim_Header'), ASI_TnE_Status__c = 'Submitted');
        insert header;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    
    public testMethod static void unitTest5(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_HK_CRM_Running_Number__c runNum = new ASI_HK_CRM_Running_Number__c();
        runNum.ASI_HK_CRM_Object_Name__c = 'ASI_TnE_TH_Claim_Header';
        runNum.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        runNum.ASI_HK_CRM_Fiscal_Year__c = 2015;
        insert runNum;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TH_Claim_Header'), ASI_TnE_Status__c = 'Submitted');
        insert header;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    
    public testMethod static void unitTest6(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_HK_CRM_Running_Number__c runNum = new ASI_HK_CRM_Running_Number__c();
        runNum.ASI_HK_CRM_Object_Name__c = 'ASI_TnE_MY_Claim_Header';
        runNum.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        runNum.ASI_HK_CRM_Fiscal_Year__c = 2015;
        insert runNum;
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_MY_Claim_Header'), ASI_TnE_Status__c = 'Submitted');
        insert header;

        /**
         *  DC - 01/29/2016 - Added Logic to improve coverage  for "ASI_TnE_ManageClaimDetailController"
         *  Please find single line comments on the lines added / changed as "DC - <Date of Change>"
         */
        // DC LOGIC START
        ASI_JP_TnE_Expense_Category__c expCategory
            = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_HK_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c expClassification
            = ASI_TnE_TestClassHelper.createExpenseCls(
                'ASI_JP_TnE_Expense_Classification__cASI_TnE_HK_Expense_Classification',
                expCategory,
                ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_HK_Account_Mapping')
            );

        ASI_TnE_ClaimDetail__c detail1 = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel', recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'));
        insert detail1;

        ASI_MFM_Exchange_Rate__c exchgRate1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Country__c = 'HK',
            ASI_MFM_Counter_Currency__c = 'TWD',
            ASI_MFM_Effective_Date__c = Date.today().addDays(10),
            ASI_MFM_Exchange_Rate__c = 0.254,
            ASI_MFM_Base_Currency__c = 'HKD'
        );

        ASI_MFM_Exchange_Rate__c exchgRate2 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Country__c = 'HK',
            ASI_MFM_Counter_Currency__c = 'TWD',
            ASI_MFM_Effective_Date__c = Date.today().addDays(10),
            ASI_MFM_Exchange_Rate__c = 0.254,
            ASI_MFM_Base_Currency__c = 'HKD'
        );

        List<ASI_MFM_Exchange_Rate__c> lstExchgRate = new List<ASI_MFM_Exchange_Rate__c> {
            exchgRate1,
            exchgRate2
        };

        insert lstExchgRate;

        Account testAcc = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_HK_Supplier');
        testAcc.Billing_Address__c = 'test address';
        testAcc.Revenue_Address__c = 'test address';
        testAcc.Shipping_Address__c = 'test address';
        testAcc.ASI_HK_CRM_Address__c = 'test address';
        update testAcc;      

        detail1.ASI_TnE_Expense_Classification__c = expClassification.Id;
        detail1.ASI_TnE_Expense_Category__c = expCategory.Id;
        detail1.ASI_TnE_Charge_To_Acc__c = testAcc.Id;
        update detail1;
        // DC LOGIC END
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        System.currentPageReference().getParameters().put('ROWID', '1');
        System.currentPageReference().getParameters().put('CATEGORY', expCategory.Id);
        System.currentPageReference().getParameters().put('CLASSIFICATION', expClassification.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.PARAM_CATEGORIES_IDS = at.detailWrapper[0].rowIndex + '-' + expCategory.Id; // DC - 01/29/2016
        at.PARAM_CLASSIFICATIONS_IDS = at.detailWrapper[0].rowIndex + '-' + expClassification.Id; // DC - 01/29/2016
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        at.assignClassification(); // DC - 01/29/2016
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    public testMethod static void unitTest7(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_TnE_TestClassHelper.createRunningNumbers();
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_ID_Claim_Header'), ASI_TnE_Status__c = 'Submitted');
        insert header;
        
        ASI_TnE_ClaimDetail__c claimDetail = ASI_TnE_TestClassHelper.createClaimDetail(header.id, 'ASI_TnE_ClaimDetail__cASI_TnE_ID_Claim_Detail');
        claimDetail.ASI_TnE_Market_Charged_To__c = 'Indonesia';
        update claimDetail;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        
        Test.startTest();
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        Test.StopTest();
    }
    
    public testMethod static void unitTest8(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_TnE_TestClassHelper.createRunningNumbers();
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'), ASI_TnE_Status__c = 'Draft');
        insert header;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        test.starttest();
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
        ASI_TnE_ClaimHeader__c header2 = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_PH_Claim_Header'), ASI_TnE_Status__c = 'Submitted');
        insert header2;
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(header2);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header2.Id);

        ASI_TnE_ManageClaimDetailController at2 = new ASI_TnE_ManageClaimDetailController(sc2);
        
        test.stoptest();
        
    }
    
    public testMethod static void unitTest9(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_TnE_TestClassHelper.createRunningNumbers();
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header'), ASI_TnE_Status__c = 'Draft');
        insert header;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    
    public testMethod static void unitTest10(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_TnE_TestClassHelper.createRunningNumbers();
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_PH_Claim_Header'), ASI_TnE_Status__c = 'Draft');
        insert header;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    
    public testMethod static void unitTest11(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_TnE_TestClassHelper.createRunningNumbers();
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TH_Claim_Header'), ASI_TnE_Status__c = 'Draft');
        insert header;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    
    public testMethod static void unitTest12(){
        User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
        u.ASI_TnE_Department_Code__c = 'ABC';
        u.ASI_TnE_Monthly_Allowance__c = 100000;
        u.ASI_TnE_Sub_Ledger__c  = 'ABC';
        
        ASI_TnE_TestClassHelper.createRunningNumbers();
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header'), ASI_TnE_Status__c = 'Draft');
        insert header;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(header);
        Test.setCurrentPageReference(new PageReference('Page.ASI_TnE_ManageClaimDetailPage')); 
        System.currentPageReference().getParameters().put('id', header.Id);
        
        ASI_TnE_ManageClaimDetailController at = new ASI_TnE_ManageClaimDetailController(sc);
        at.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+at.detailWrapper[0].rowIndex);
        at.cloneClaimDetail();
        at.removeClaimDetail();
        at.addNewDetail();
        
        at.saveClaimDetails();
        at.redirectClaimHeaderPage();
        at.cancel();
        
    }
    
}