@isTest
public class ASI_MFM_CAP_ConvertAccrual_Test {

    static testMethod void testController_ConvertToAccrual(){
        ASI_MFM_CAP_TestClassHelper.createMFMDefaultValues();
        
        Account acc1 = ASI_MFM_CAP_TestClassHelper.createAccSupplier();
        
        ASI_MFM_PO__c PO = ASI_MFM_CAP_TestClassHelper.createPO();
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c
        (
            ASI_MFM_Payment_Type__c = 'OPEX',
            ASI_MFM_Plan__c = PO.ASI_MFM_Plan__c,
            ASI_MFM_Currency__c = 'HKD',
            ASI_MFM_Prefix__c= ASI_MFM_CAP_TestClassHelper.createPrefixPayment().id,
            ASI_MFM_Supplier_Name__c = ASI_MFM_CAP_TestClassHelper.createAccSupplier().id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment'),
            ASI_MFM_Is_Direct_Payment__c = true,
            ASI_MFM_Status__c = 'Draft',
            ASI_MFM_Invoice_Date__c = date.today(),
            ASI_MFM_Invoice_Number__c = '123Tesyt',
            ASI_MFM_OCR__c = true
        );
        insert py;
        
        Test.StartTest();
        
        ASI_MFM_Payment_Line_Item__c pyi = ASI_MFM_CAP_TestClassHelper.createPaymentLines(py, poLine);
        
        //Test convert to accrual
        PageReference testPage = Page.ASI_MFM_CAP_ConvertAccrual_Page;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        pageParams.put('actionType', 'ConvertToAccrual');
        Test.setCurrentPageReference(testPage);
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(py);
        ASI_MFM_CAP_ConvertAccrual_Controller controller = new ASI_MFM_CAP_ConvertAccrual_Controller(stdController);
        controller.Convert(); 
        
        //Test convert to T&E
        PageReference testPage2 = Page.ASI_MFM_CAP_ConvertAccrual_Page;
        Map<String, String> pageParams2 = testPage2.getParameters();
        pageParams2.put('id', py.Id);
        pageParams2.put('actionType', 'ConvertToTnE');
        Test.setCurrentPageReference(testPage2);
        controller.Convert(); 
    }

     static testMethod void testController_ConvertToTnE(){
        ASI_MFM_CAP_TestClassHelper.createMFMDefaultValues();
        
        Account acc1 = ASI_MFM_CAP_TestClassHelper.createAccSupplier();
        
        ASI_MFM_PO__c PO = ASI_MFM_CAP_TestClassHelper.createPO();
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c
        (
            ASI_MFM_Payment_Type__c = 'OPEX',
            ASI_MFM_Plan__c = PO.ASI_MFM_Plan__c,
            ASI_MFM_Currency__c = 'HKD',
            ASI_MFM_Prefix__c= ASI_MFM_CAP_TestClassHelper.createPrefixPayment().id,
            ASI_MFM_Supplier_Name__c = ASI_MFM_CAP_TestClassHelper.createAccSupplier().id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment'),
            ASI_MFM_Is_Direct_Payment__c = true,
            ASI_MFM_Status__c = 'Draft',
            ASI_MFM_Invoice_Date__c = date.today(),
            ASI_MFM_Invoice_Number__c = '123Tesyt',
            ASI_MFM_OCR__c = true
        );
        insert py;
        
        Test.StartTest();
        
        ASI_MFM_Payment_Line_Item__c pyi = ASI_MFM_CAP_TestClassHelper.createPaymentLines(py, poLine);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(py);
        ASI_MFM_CAP_ConvertAccrual_Controller controller = new ASI_MFM_CAP_ConvertAccrual_Controller(stdController);
        
        //Test convert to T&E
        PageReference testPage2 = Page.ASI_MFM_CAP_ConvertAccrual_Page;
        Map<String, String> pageParams2 = testPage2.getParameters();
        pageParams2.put('id', py.Id);
        pageParams2.put('actionType', 'ConvertToTnE');
        Test.setCurrentPageReference(testPage2);
        controller.Convert(); 
    }
}