@isTest
private class ASI_MFM_CAP_OTH_MgAll_PaymentCtrlTest {
    
    @TestSetup
    public static void dataSetup() {
        ASI_MFM_Plan__c testPlanInstance = ASI_MFM_CAP_TestClassHelper.createPlanOpex();

        testPlanInstance.ASI_MFM_Status__c = 'Final';
        update testPlanInstance;

        ASI_MFM_PO__c testPoInstance = ASI_MFM_CAP_TestClassHelper.createPo('CAPEX', testPlanInstance);

        testPoInstance.ASI_MFM_Status__c = 'Final';
        update testPoInstance;

        testPlanInstance.ASI_MFM_Plan_Type__c = 'CAPEX';
        update testPlanInstance;
        
        ASI_MFM_PO_Line_Item__c testPoLineInstance = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = testPoInstance.id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item'),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Amount__c = 1000,
            ASI_MFM_AP_Code__c = ASI_MFM_CAP_TestClassHelper.createAPCode().id
        );

        insert testPoLineInstance;

        ASI_MFM_Payment__c testPaymentInstance = new ASI_MFM_Payment__c
        (
            ASI_MFM_Payment_Type__c = 'CAPEX',
			ASI_MFM_CAP_PO__c = testPoInstance.Id,
            ASI_MFM_Plan__c = testPoInstance.ASI_MFM_Plan__c,
            ASI_MFM_Currency__c = 'HKD',
            ASI_MFM_Prefix__c= ASI_MFM_CAP_TestClassHelper.createPrefixPayment().id,
            ASI_MFM_Supplier_Name__c = ASI_MFM_CAP_TestClassHelper.createAccSupplier().id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment'),
            ASI_MFM_Is_Direct_Payment__c = true,
            ASI_MFM_Status__c = 'Draft',
            ASI_MFM_Invoice_Date__c = date.today(),
            ASI_MFM_Invoice_Number__c = '123Tesyt'
        );

        insert testPaymentInstance;
  
    }
    
    private static TestMethod void testConstructor() {
        ASI_MFM_Payment__c testPaymentInstance = [SELECT Id FROM ASI_MFM_Payment__c LIMIT 1];
        ASI_MFM_PO_Line_Item__c testPoLineInstance = [SELECT Id FROM ASI_MFM_PO_Line_Item__c LIMIT 1];
        
        ASI_MFM_Payment_Line_Item__c testPaymentLineInstance = new ASI_MFM_Payment_Line_Item__c
        (
        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item'),
        ASI_MFM_Payment__c=testPaymentInstance.id, 
        ASI_MFM_Payment_Amount__c=10, 
        ASI_MFM_PO_Line_Item__c=testPoLineInstance.id, 
        ASI_MFM_Invoice_Date__c = date.today(), 
        ASI_MFM_Invoice_Number__c = '123456',
        ASI_MFM_AP_Code__c = ASI_MFM_CAP_TestClassHelper.createOPEXAPCode().id,
        ASI_MFM_A_C_Code__c = ASI_MFM_CAP_TestClassHelper.createACCode().id,
        ASI_MFM_BU__c = ASI_MFM_CAP_TestClassHelper.createOPEXBUCode().id,
        ASI_MFM_Paid_Amount_in_PO_Currency__c = 100
        );

        System.Test.startTest();

          insert testPaymentLineInstance;
        
            PageReference pageRef = Page.ASI_MFM_CAP_OTH_MgAll_PaymentPage;
            pageRef.getParameters().put('id', testPaymentInstance.Id);
            // pageRef.getParameters().put('prtId', testPlanInstance.RecordTypeId);

            List<ASI_MFM_Payment__c> testPaymentList = [SELECT Id
                                                          FROM ASI_MFM_Payment__c
                                                         WHERE Id = :testPaymentInstance.Id
                                                         LIMIT 1];

            System.Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController stdController = 
                new ApexPages.StandardSetController(testPaymentList);

            ASI_MFM_CAP_OTH_MgAll_PaymentController controllerInstance = 
                new ASI_MFM_CAP_OTH_MgAll_PaymentController(stdController);

        System.Test.stopTest();

    }

    private static TestMethod void testPoItemsSearch() {
        ASI_MFM_Payment__c testPaymentInstance = [SELECT Id FROM ASI_MFM_Payment__c LIMIT 1];
        ASI_MFM_PO_Line_Item__c testPoLineInstance = [SELECT Id FROM ASI_MFM_PO_Line_Item__c LIMIT 1];
        
    ASI_MFM_Payment_Line_Item__c testPaymentLineInstance = new ASI_MFM_Payment_Line_Item__c
        (
        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item'),
        ASI_MFM_Payment__c=testPaymentInstance.id, 
        ASI_MFM_Payment_Amount__c=10, 
        ASI_MFM_PO_Line_Item__c=testPoLineInstance.id, 
        ASI_MFM_Invoice_Date__c = date.today(), 
        ASI_MFM_Invoice_Number__c = '123456',
        ASI_MFM_AP_Code__c = ASI_MFM_CAP_TestClassHelper.createOPEXAPCode().id,
        ASI_MFM_A_C_Code__c = ASI_MFM_CAP_TestClassHelper.createACCode().id,
        ASI_MFM_BU__c = ASI_MFM_CAP_TestClassHelper.createOPEXBUCode().id,
        ASI_MFM_Paid_Amount_in_PO_Currency__c = 100
        );
        
        System.Test.startTest();
          insert testPaymentLineInstance;

            PageReference pageRef = Page.ASI_MFM_CAP_OTH_MgAll_PaymentPage;
            pageRef.getParameters().put('id', testPaymentInstance.Id);
            // pageRef.getParameters().put('prtId', testPlanInstance.RecordTypeId);

            List<ASI_MFM_Payment__c> testPaymentList = [SELECT Id
                                                          FROM ASI_MFM_Payment__c
                                                         WHERE Id = :testPaymentInstance.Id
                                                         LIMIT 1];

            System.Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController stdController = 
                new ApexPages.StandardSetController(testPaymentList);

            ASI_MFM_CAP_OTH_MgAll_PaymentController controllerInstance = 
                new ASI_MFM_CAP_OTH_MgAll_PaymentController(stdController);

            controllerInstance.po_filter = 'PO00';
            controllerInstance.supplier_filter = '123';
            controllerInstance.plan_filter = 'Test';
            controllerInstance.raised_by_filter = UserInfo.getLastName();
            controllerInstance.FilterPOItems();

        System.Test.stopTest();

    }

    private static TestMethod void testMethodCalls() {
        ASI_MFM_Payment__c testPaymentInstance = [SELECT Id FROM ASI_MFM_Payment__c LIMIT 1];
        ASI_MFM_PO_Line_Item__c testPoLineInstance = [SELECT Id, ASI_MFM_Currency__c, ASI_MFM_Remaining_Balance__c, ASI_MFM_List_Item_Description__c FROM ASI_MFM_PO_Line_Item__c LIMIT 1];
        
    ASI_MFM_Payment_Line_Item__c testPaymentLineInstance = new ASI_MFM_Payment_Line_Item__c
        (
        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item'),
        ASI_MFM_Payment__c=testPaymentInstance.id, 
        ASI_MFM_Payment_Amount__c=10, 
        ASI_MFM_PO_Line_Item__c=testPoLineInstance.id, 
        ASI_MFM_Invoice_Date__c = date.today(), 
        ASI_MFM_Invoice_Number__c = '123456',
        ASI_MFM_AP_Code__c = ASI_MFM_CAP_TestClassHelper.createOPEXAPCode().id,
        ASI_MFM_A_C_Code__c = ASI_MFM_CAP_TestClassHelper.createACCode().id,
        ASI_MFM_BU__c = ASI_MFM_CAP_TestClassHelper.createOPEXBUCode().id,
        ASI_MFM_Paid_Amount_in_PO_Currency__c = 100
        );
        
        System.Test.startTest();
          insert testPaymentLineInstance;
        
            PageReference pageRef = Page.ASI_MFM_CAP_OTH_MgAll_PaymentPage;
            pageRef.getParameters().put('id', testPaymentInstance.Id);
            pageRef.getParameters().put('crtName', 'ASI_MFM_CAP_TW_Payment_Line_Item');

            List<ASI_MFM_Payment__c> testPaymentList = [SELECT Id
                                                          FROM ASI_MFM_Payment__c
                                                         WHERE Id = :testPaymentInstance.Id
                                                         LIMIT 1];

            System.Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController stdController = 
                new ApexPages.StandardSetController(testPaymentList);

            ASI_MFM_CAP_OTH_MgAll_PaymentController controllerInstance = 
                new ASI_MFM_CAP_OTH_MgAll_PaymentController(stdController);

            controllerInstance.po_filter = 'PO00';
            controllerInstance.supplier_filter = '123';
            controllerInstance.plan_filter = 'Test';
            controllerInstance.raised_by_filter = UserInfo.getLastName();

            // Method calls
            ASI_MFM_SFObjSelectTableController tableInstance = new ASI_MFM_SFObjSelectTableController();
            tableInstance.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
            tableInstance.displayFieldsStr = 'Name,CreatedById';
            tableInstance.init();

            controllerInstance.setComponentController('selectTable', tableInstance);

            controllerInstance.setComponentController(new ASI_MFM_SFObjSelectTableController());

            controllerInstance.mcau_triggerPageBlockAction(
                new ASI_MFM_CAP_MassCreateUpdateController(),
                ASI_MFM_CAP_MassCreateUpdateController.ACTION_REMOVE_NEW
            );
            controllerInstance.mcau_initPageBlockActionButtonList();

            controllerInstance.thisController = controllerInstance;
            controllerInstance.getComponentController();
            controllerInstance.sobjst_initActionButtonList();
            controllerInstance.sobjst_initActionButtonStageMap();
            
            ASI_MFM_CAP_MassCreateUpdateController mcauInstance = new ASI_MFM_CAP_MassCreateUpdateController();
            mcauInstance.sObjTypeStr = 'ASI_MFM_Payment_Line_Item__c';
            mcauInstance.isDefaultEditVal = false;
            mcauInstance.isFastModeBool = false;
            mcauInstance.isUseFirstRowForNew = true;
            mcauInstance.init();
            controllerInstance.setComponentController('massCreateAndUpdate', mcauInstance);

            controllerInstance.sobjst_triggerActionForSObject(
                tableInstance,
                'add',
                testPoLineInstance
            );
            System.debug('------ init_search ------ : ' + controllerInstance.init_search);
            controllerInstance.FilterPOItems();

        System.Test.stopTest();

    }

}