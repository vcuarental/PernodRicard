@isTest
public class ASI_TnE_TW_ManageClaimDetailCtrl_Test{

    public testMethod static void unitTest1() {
        ASI_TnE_ClaimHeader__c headerInstance = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        ASI_JP_TnE_Expense_Category__c category = 
            ASI_TnE_TW_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_TW_Expense_Category');
        
        ASI_JP_TnE_Expense_Classification__c classification = ASI_TnE_TW_TestClassHelper.createExpenseCls(
            'ASI_JP_TnE_Expense_Classification__cASI_TnE_TW_Expense_Classification',
            category,
            ASI_TnE_TW_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_TW_Account_Mapping')
        );

        ASI_TnE_ClaimDetail__c detailInstance = ASI_TnE_TW_TestClassHelper.createClaimDetail(
            headerInstance.Id,
            'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',
            classification
        );

        headerInstance.ASI_TnE_Status__c = 'Submitted';
        update headerInstance;
        
        ASI_MFM_Sub_brand__c subBrandInstance = ASI_TnE_TW_TestClassHelper.createSubBrand();
        
        Account accountInstance = ASI_TnE_TW_TestClassHelper.createAccount('AccountASI_TnE_TW_Supplier');
        ASI_TnE_Employee_Code_Mapping__c codeMappingInstance =  ASI_TnE_TW_TestClassHelper.createEmployeeCodeMapping();
        
        codeMappingInstance.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TW_Employee_Code_Mapping');
        update codeMappingInstance;
        
        System.debug('------ codeMappingInstance.RecordTypeId ------ : ' + codeMappingInstance.RecordTypeId);
        
        ASI_TnE_Corp_Card_Employee_Mapping__c employeeInstance = ASI_TnE_TW_TestClassHelper.createEmployeeMapping(
            '7',
            '8',
            accountInstance.Id,
            accountInstance.Id
        );
        
        Test.startTest();
        Test.setCurrentPage(Page.ASI_TnE_TW_ManageClaimDetailPage);
        ApexPages.currentPage().getParameters().put('id', headerInstance.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(headerInstance);
        ASI_TnE_TW_ManageClaimDetailController controllerInstance = new ASI_TnE_TW_ManageClaimDetailController(controller);
        
        System.debug('------ employeeMappingRecordType ------ : ' + controllerInstance.employeeMappingRecordType);
        
        controllerInstance.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+controllerInstance.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+controllerInstance.detailWrapper[0].rowIndex);
        controllerInstance.cloneClaimDetail();
        controllerInstance.removeClaimDetail();
        controllerInstance.addNewDetail();
        controllerInstance.saveClaimDetails();
        controllerInstance.redirectClaimHeaderPage();
        controllerInstance.cancel();
        
        Test.stopTest();
    }

    public testMethod static void unitTest2() {
        ASI_TnE_ClaimHeader__c headerInstance = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        ASI_JP_TnE_Expense_Category__c category = 
            ASI_TnE_TW_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_TW_Expense_Category');
        
        ASI_JP_TnE_Expense_Classification__c classification = ASI_TnE_TW_TestClassHelper.createExpenseCls(
            'ASI_JP_TnE_Expense_Classification__cASI_TnE_TW_Expense_Classification',
            category,
            ASI_TnE_TW_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_TW_Account_Mapping')
        );
        
        ASI_TnE_ClaimDetail__c detailInstance = ASI_TnE_TW_TestClassHelper.createClaimDetail(
            headerInstance.Id,
            'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',
            classification
        );

        headerInstance.ASI_TnE_Status__c = 'Submitted';
        headerInstance.RecordTypeId = [SELECT Id from RecordType where DeveloperName = 
        'ASI_TnE_TW_Claim_Header_Finance' LIMIT 1].Id;
        update headerInstance;

        Test.startTest();
        Test.setCurrentPage(Page.ASI_TnE_TW_ManageClaimDetailPage);
        ApexPages.currentPage().getParameters().put('id', headerInstance.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(headerInstance);
        ASI_TnE_TW_ManageClaimDetailController controllerInstance = new ASI_TnE_TW_ManageClaimDetailController(controller);

        controllerInstance.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+controllerInstance.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+controllerInstance.detailWrapper[0].rowIndex);
        controllerInstance.cloneClaimDetail();
        controllerInstance.removeClaimDetail();
        controllerInstance.addNewDetail();
        controllerInstance.saveClaimDetails();
        controllerInstance.redirectClaimHeaderPage();
        controllerInstance.cancel();
        
        Test.stopTest();
    }

    public testMethod static void unitTest3() {
        ASI_TnE_ClaimHeader__c headerInstance = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        Account accountInstance = ASI_TnE_TW_TestClassHelper.createAccount('AccountASI_TnE_TW_Supplier');
        ASI_TnE_Employee_Code_Mapping__c codeMappingInstance =  ASI_TnE_TW_TestClassHelper.createEmployeeCodeMapping();
        
        codeMappingInstance.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TW_Employee_Code_Mapping');
        update codeMappingInstance;
        
        System.debug('------ codeMappingInstance.RecordTypeId ------ : ' + codeMappingInstance.RecordTypeId);
        
        ASI_TnE_Corp_Card_Employee_Mapping__c employeeInstance = ASI_TnE_TW_TestClassHelper.createEmployeeMapping(
            '7',
            '8',
            accountInstance.Id,
            accountInstance.Id
        );
        
        ASI_JP_TnE_Expense_Category__c category = 
            ASI_TnE_TW_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_TW_Expense_Category');
        
        ASI_JP_TnE_Expense_Classification__c classification = ASI_TnE_TW_TestClassHelper.createExpenseCls(
            'ASI_JP_TnE_Expense_Classification__cASI_TnE_TW_Expense_Classification',
            category,
            ASI_TnE_TW_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_TW_Account_Mapping')
        );
        
        ASI_TnE_ClaimDetail__c detailInstance = ASI_TnE_TW_TestClassHelper.createClaimDetail(
            headerInstance.Id,
            'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',
            classification
        );

        headerInstance.ASI_TnE_Status__c = 'Submitted';
        update headerInstance;
        
        Test.startTest();
        Test.setCurrentPage(Page.ASI_TnE_TW_ManageClaimDetailPage);
        ApexPages.currentPage().getParameters().put('id', headerInstance.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(headerInstance);
        ASI_TnE_TW_ManageClaimDetailController controllerInstance = new ASI_TnE_TW_ManageClaimDetailController(controller);
        
        System.debug('------ employeeMappingRecordType ------ : ' + controllerInstance.employeeMappingRecordType);
        
        controllerInstance.PARAM_CATEGORIES_IDS = '1-'+ category.Id;
        
        // controllerInstance.PARAM_CLASSIFICATIONS_IDS = '1-'+ classification.Id;
        
        controllerInstance.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+controllerInstance.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+controllerInstance.detailWrapper[0].rowIndex);
        controllerInstance.cloneClaimDetail();
        controllerInstance.removeClaimDetail();
        controllerInstance.addNewDetail();
        controllerInstance.saveClaimDetails();
        controllerInstance.redirectClaimHeaderPage();
        controllerInstance.cancel();
        
        Test.stopTest();
    }
    
    public testMethod static void unitTest4() {
        ASI_TnE_ClaimHeader__c headerInstance = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        Account accountInstance = ASI_TnE_TW_TestClassHelper.createAccount('AccountASI_TnE_TW_Supplier');
        ASI_TnE_Employee_Code_Mapping__c codeMappingInstance =  ASI_TnE_TW_TestClassHelper.createEmployeeCodeMapping();
        
        codeMappingInstance.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TW_Employee_Code_Mapping');
        update codeMappingInstance;
        
        System.debug('------ codeMappingInstance.RecordTypeId ------ : ' + codeMappingInstance.RecordTypeId);
        
        ASI_TnE_Corp_Card_Employee_Mapping__c employeeInstance = ASI_TnE_TW_TestClassHelper.createEmployeeMapping(
            '7',
            '8',
            accountInstance.Id,
            accountInstance.Id
        );
        
        ASI_MFM_Exchange_Rate__c exchgRate1 = ASI_TnE_TW_TestClassHelper.createExchangeRate(Date.today());
        ASI_MFM_Exchange_Rate__c exchgRate2 = ASI_TnE_TW_TestClassHelper.createExchangeRate(Date.today().addMonths(-6));
        
        ASI_JP_TnE_Expense_Category__c category = 
            ASI_TnE_TW_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_TW_Expense_Category');
        
        ASI_JP_TnE_Expense_Classification__c classification = ASI_TnE_TW_TestClassHelper.createExpenseCls(
            'ASI_JP_TnE_Expense_Classification__cASI_TnE_TW_Expense_Classification',
            category,
            ASI_TnE_TW_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_TW_Account_Mapping')
        );
        
        ASI_TnE_ClaimDetail__c detailInstance = ASI_TnE_TW_TestClassHelper.createClaimDetail(
            headerInstance.Id,
            'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',
            classification
        );

        headerInstance.ASI_TnE_Status__c = 'Submitted';
        update headerInstance;
        
        Test.startTest();
        Test.setCurrentPage(Page.ASI_TnE_TW_ManageClaimDetailPage);
        ApexPages.currentPage().getParameters().put('id', headerInstance.Id);
        ApexPages.currentPage().getParameters().put('ROWID', '1');
        ApexPages.currentPage().getParameters().put('CATEGORY', category.Id);
        ApexPages.currentPage().getParameters().put('CLASSIFICATION', classification.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(headerInstance);
        ASI_TnE_TW_ManageClaimDetailController controllerInstance = new ASI_TnE_TW_ManageClaimDetailController(controller);
        
        System.debug('------ employeeMappingRecordType ------ : ' + controllerInstance.employeeMappingRecordType);
        
        controllerInstance.PARAM_CATEGORIES_IDS = '1-'+ category.Id;
        
        // controllerInstance.PARAM_CLASSIFICATIONS_IDS = '1-'+ classification.Id;
        
        controllerInstance.addNewDetail();
        System.currentPageReference().getParameters().put('PARAM_CLONE_CLAIM_DETAIL_ID', ''+controllerInstance.detailWrapper[0].rowIndex);
        System.currentPageReference().getParameters().put('PARAM_DELETE_CLAIM_DETAIL_ID', ''+controllerInstance.detailWrapper[0].rowIndex);
        controllerInstance.cloneClaimDetail();
        controllerInstance.removeClaimDetail();
        controllerInstance.addNewDetail();
        controllerInstance.saveClaimDetails();
        controllerInstance.redirectClaimHeaderPage();
        controllerInstance.assignClassification();
        controllerInstance.cancel();
        ASI_TnE_TW_ManageClaimDetailController.findSObjects('ASI_CRM_AccountsAdditionalField__c','test','test');
        
        Test.stopTest();
    }   
}