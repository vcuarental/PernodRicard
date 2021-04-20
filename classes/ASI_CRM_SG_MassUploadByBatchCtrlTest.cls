/*********************************************************************************
 * Name: ASI_CRM_SG_MassUploadByBatchControllerTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-22       Billy Lo                Created
 */
@isTest
private class ASI_CRM_SG_MassUploadByBatchCtrlTest {

    private static testMethod void testControllerWithData() { 
        
        Test.startTest();
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        ASI_CRM_SG_TestClassHelper.paymentData paymentC = new ASI_CRM_SG_TestClassHelper.paymentData(true);
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData ws = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
        ASI_CRM_SG_TestClassHelper.offtakeData offtakeC = new ASI_CRM_SG_TestClassHelper.offtakeData(true, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, ws.customer.Id, skuList.get(0).Id);
        ASI_CRM_Customer_Mapping__c m = new ASI_CRM_Customer_Mapping__c();
        m.ASI_CRM_External_ID__c = '123';
        m.ASI_CRM_JDE_Customer__c = customerC.customer.Id;
        m.ASI_CRM_Wholesaler__c = ws.customer.Id;
        m.ASI_CRM_Offtake_Customer_No__c = 'customer';
        m.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Customer_Mapping__cASI_CRM_SG_Customer_Mapping');
        insert m;

        ASI_CRM_SG_MassUploadByBatchController controller = new ASI_CRM_SG_MassUploadByBatchController();
        controller.emailNotification = true;
        controller.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
        controller.parentObjectAPIName = 'ASI_CRM_ActualOfftakeHeader__c';
        controller.ParentObjectUploadMsg = 'ASI_CRM_Upload_Log__c';
        controller.recordtypeName = 'ASI CRM SG Actual Offtake';
        controller.fields = 'ASI_CRM_Type_Uploaded__c,ASI_CRM_Code_Uploaded__c,ASI_CRM_Wholesaler_Code_Uploaded__c,ASI_CRM_Customer_Code_Uploaded__c,ASI_TH_CRM_Offtake_G_L_Date__c,ASI_CRM_SKU_Code_Uploaded__c,ASI_CRM_InvoiceNumber__c,ASI_CRM_Original_Quantity__c';
        controller.fieldsLabel = 'Type,Code,Wholesaler Code,Customer Code,Offtake G/L Date,SKU Code,Invoice Number,Quantity';
        controller.defaultValues = 'Mass Uploaded:true;';
        controller.fileSize = 1;
        controller.currentPageURL = '';
        controller.namefile = 'name.csv';
        controller.containsHeader = false;
        
        String content = 'INV,U,' + ws.customer.ASI_CRM_MY_CustomerCode__c + ',customer,20170701,test1,135183,3,';
        content = content + content;
        
        controller.contentFile = Blob.valueOf(content);
        controller.lookupEXID = 'ASI_TH_CRM_Actual_Offtake__c/Id:ASI_CRM_Code_Uploaded__c&ASI_CRM_Code_Uploaded__c,ASI_CRM_Code_Uploaded__c&ASI_CRM_Code_Uploaded__c;';
        controller.opt_allOrNone = true;
        controller.upsertMode = false;
        controller.noOfLastRowToIgnore = '0';

        controller.init();
        controller.uploadCSVByBatch();
        Account obj = new Account();
        ASI_CRM_SG_MassUploadByBatchController.Row r1 = new ASI_CRM_SG_MassUploadByBatchController.Row(obj);
        ASI_CRM_SG_MassUploadByBatchController.Row r2 = new ASI_CRM_SG_MassUploadByBatchController.Row(obj, 'Name', 'Test');
        r2.addError('test');
        string[] myArray = controller.StatusMsgs;
        boolean myBoolean = controller.isDisplayErrorLog;
        Test.stopTest();
        
    }
    
    private static testMethod void testControllerWithNoData() {
        
        Test.startTest();
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        ASI_CRM_SG_TestClassHelper.paymentData paymentC = new ASI_CRM_SG_TestClassHelper.paymentData(true);
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData ws = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
        ASI_CRM_SG_TestClassHelper.offtakeData offtakeC = new ASI_CRM_SG_TestClassHelper.offtakeData(true, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, ws.customer.Id, skuList.get(0).Id);
        ASI_CRM_Customer_Mapping__c m = new ASI_CRM_Customer_Mapping__c();
        m.ASI_CRM_External_ID__c = '123';
        m.ASI_CRM_JDE_Customer__c = customerC.customer.Id;
        m.ASI_CRM_Wholesaler__c = ws.customer.Id;
        m.ASI_CRM_Offtake_Customer_No__c = 'customer';
        m.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Customer_Mapping__cASI_CRM_SG_Customer_Mapping');
        insert m;

        ASI_CRM_SG_MassUploadByBatchController controller = new ASI_CRM_SG_MassUploadByBatchController();
        controller.emailNotification = true;
        controller.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
        controller.parentObjectAPIName = 'ASI_CRM_ActualOfftakeHeader__c';
        controller.ParentObjectUploadMsg = 'ASI_CRM_Upload_Log__c';
        controller.recordtypeName = 'ASI CRM SG Actual Offtake';
        controller.fields = 'ASI_CRM_Type_Uploaded__c,ASI_CRM_Code_Uploaded__c,ASI_CRM_Wholesaler_Code_Uploaded__c,ASI_CRM_Customer_Code_Uploaded__c,ASI_TH_CRM_Offtake_G_L_Date__c,ASI_CRM_SKU_Code_Uploaded__c,ASI_CRM_InvoiceNumber__c,ASI_CRM_Original_Quantity__c';
        controller.fieldsLabel = 'Type,Code,Wholesaler Code,Customer Code,Offtake G/L Date,SKU Code,Invoice Number,Quantity';
        controller.defaultValues = 'Mass Uploaded:true;';
        controller.fileSize = 1;
        controller.currentPageURL = '';
        controller.namefile = 'name.csv';
        controller.containsHeader = false;
        
        String content = '123,213,213,123,123123,';
        
        controller.contentFile = Blob.valueOf(content);
        controller.lookupEXID = '';
        controller.opt_allOrNone = true;
        controller.upsertMode = false;
        controller.noOfLastRowToIgnore = '0';

        controller.init();
        controller.uploadCSVByBatch();
        string[] myArray = controller.StatusMsgs;
        boolean myBoolean = controller.isDisplayErrorLog;
        Test.stopTest();
        
    }
    
    private static testMethod void testControllerWithWrongData() {
        
        Test.startTest();
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        ASI_CRM_SG_TestClassHelper.paymentData paymentC = new ASI_CRM_SG_TestClassHelper.paymentData(true);
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData ws = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
        ASI_CRM_SG_TestClassHelper.offtakeData offtakeC = new ASI_CRM_SG_TestClassHelper.offtakeData(true, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, ws.customer.Id, skuList.get(0).Id);
        ASI_CRM_Customer_Mapping__c m = new ASI_CRM_Customer_Mapping__c();
        m.ASI_CRM_External_ID__c = '123';
        m.ASI_CRM_JDE_Customer__c = customerC.customer.Id;
        m.ASI_CRM_Wholesaler__c = ws.customer.Id;
        m.ASI_CRM_Offtake_Customer_No__c = 'customer';
        m.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Customer_Mapping__cASI_CRM_SG_Customer_Mapping');
        insert m;

        ASI_CRM_SG_MassUploadByBatchController controller = new ASI_CRM_SG_MassUploadByBatchController();
        controller.emailNotification = true;
        controller.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
        controller.parentObjectAPIName = 'ASI_CRM_ActualOfftakeHeader__c';
        controller.ParentObjectUploadMsg = 'ASI_CRM_Upload_Log__c';
        controller.recordtypeName = 'ASI CRM SG Actual Offtake';
        controller.fields = 'ASI_CRM_Type_Uploaded__c,ASI_CRM_Code_Uploaded__c,ASI_CRM_Wholesaler_Code_Uploaded__c,ASI_CRM_Customer_Code_Uploaded__c,ASI_TH_CRM_Offtake_G_L_Date__c,ASI_CRM_SKU_Code_Uploaded__c,ASI_CRM_InvoiceNumber__c,ASI_CRM_Original_Quantity__c';
        controller.fieldsLabel = 'Type,Code,Wholesaler Code,Customer Code,Offtake G/L Date,SKU Code,Invoice Number,Quantity';
        controller.defaultValues = 'Mass Uploaded:true;';
        controller.fileSize = 1;
        controller.currentPageURL = '';
        controller.namefile = 'name.csv';
        controller.containsHeader = false;
        
        String content = 'INV,U,test,test,20170701,test1,135183,3,';
        
        controller.contentFile = Blob.valueOf(content);
        controller.lookupEXID = '';
        controller.opt_allOrNone = true;
        controller.upsertMode = false;
        controller.noOfLastRowToIgnore = '0';

        controller.init();
        controller.uploadCSVByBatch();
        string[] myArray = controller.StatusMsgs;
        boolean myBoolean = controller.isDisplayErrorLog;
        Test.stopTest();
        
    }

    
    private static testMethod void testControllerWithDataOffTrade() { 
        
        Test.startTest();
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        ASI_CRM_SG_TestClassHelper.paymentData paymentC = new ASI_CRM_SG_TestClassHelper.paymentData(true);
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData ws = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
        ASI_CRM_SG_TestClassHelper.offtakeData offtakeC = new ASI_CRM_SG_TestClassHelper.offtakeData(true, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, ws.customer.Id, skuList.get(0).Id);
        
        ASI_CRM_SKU_Mapping__c m = new ASI_CRM_SKU_Mapping__c();
        m.ASI_CRM_SKU__c = skuList.get(0).Id;
        m.ASI_CRM_Customer_Number__c = '19855';
        m.ASI_CRM_Item_Number__c = 'XXX';
        m.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_SKU_Mapping__cASI_CRM_SG_Offtrade_SKU_Mapping');
        insert m;
        
        ASI_CRM_MY_SKUPriceCost__c c1=new ASI_CRM_MY_SKUPriceCost__c(ASI_CRM_Price__c=1, ASI_CRM_Cost__c=1, ASI_CRM_EffectiveDate__c=Date.today(),ASI_CRM_SKU__c= skuList.get(0).Id,recordTypeID=Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'));
    ASI_CRM_MY_SKUPriceCost__c c2=new ASI_CRM_MY_SKUPriceCost__c(ASI_CRM_Price__c=1, ASI_CRM_Cost__c=1, ASI_CRM_EffectiveDate__c=Date.today(),ASI_CRM_SKU__c= skuList.get(0).Id,recordTypeID=Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'));
    ASI_CRM_MY_SKUPriceCost__c c3=new ASI_CRM_MY_SKUPriceCost__c(ASI_CRM_Price__c=1, ASI_CRM_Cost__c=1, ASI_CRM_EffectiveDate__c=Date.today(),ASI_CRM_SKU__c= skuList.get(0).Id,recordTypeID=Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle'));
    ASI_CRM_MY_SKUPriceCost__c c4=new ASI_CRM_MY_SKUPriceCost__c(ASI_CRM_Price__c=1, ASI_CRM_Cost__c=1, ASI_CRM_EffectiveDate__c=Date.today(),ASI_CRM_SKU__c= skuList.get(0).Id,recordTypeID=Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle'));
    ASI_CRM_MY_SKUPriceCost__c c5=new ASI_CRM_MY_SKUPriceCost__c(ASI_CRM_Price__c=1, ASI_CRM_Cost__c=1, ASI_CRM_EffectiveDate__c=Date.today(),ASI_CRM_SKU__c= skuList.get(0).Id,recordTypeID=Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'));
    ASI_CRM_MY_SKUPriceCost__c c6=new ASI_CRM_MY_SKUPriceCost__c(ASI_CRM_Price__c=1, ASI_CRM_Cost__c=1, ASI_CRM_EffectiveDate__c=Date.today(),ASI_CRM_SKU__c= skuList.get(0).Id,recordTypeID=Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Open_Outlet_Price_Per_Bottle'));
    ASI_CRM_MY_SKUPriceCost__c c7=new ASI_CRM_MY_SKUPriceCost__c(ASI_CRM_Price__c=1, ASI_CRM_Cost__c=1, ASI_CRM_EffectiveDate__c=Date.today(),ASI_CRM_SKU__c= skuList.get(0).Id,recordTypeID=Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Incentive_Price_Per_Bottle'));
    ASI_CRM_MY_SKUPriceCost__c c8=new ASI_CRM_MY_SKUPriceCost__c(ASI_CRM_Price__c=1, ASI_CRM_Cost__c=1, ASI_CRM_EffectiveDate__c=Date.today(),ASI_CRM_SKU__c= skuList.get(0).Id,recordTypeID=Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Quarterly_Promo_Price'));
List<ASI_CRM_MY_SKUPriceCost__c> priceL= new List<ASI_CRM_MY_SKUPriceCost__c>();
    priceL.add(c1);priceL.add(c2);priceL.add(c3);priceL.add(c4);priceL.add(c5);priceL.add(c6);priceL.add(c7);priceL.add(c8);
    
    insert priceL;

        ASI_CRM_SG_MassUploadByBatchController controller = new ASI_CRM_SG_MassUploadByBatchController();
        controller.emailNotification = true;
        controller.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
        controller.parentObjectAPIName = 'ASI_CRM_ActualOfftakeHeader__c';
        controller.ParentObjectUploadMsg = 'ASI_CRM_Upload_Log__c';
        controller.recordtypeName = 'ASI CRM SG Actual Offtake';
        controller.fields = 'ASI_CRM_Customer_Code_Uploaded__c,ASI_CRM_Customer_Name_Uploaded__c,ASI_CRM_InvoiceNumber__c,ASI_TH_CRM_Offtake_G_L_Date__c,ASI_CRM_Wholesaler_Code_Uploaded__c,ASI_CRM_SKU_Code_Uploaded__c,ASI_CRM_Gross_Sales__c,ASI_CRM_Original_Quantity__c,ASI_CRM_Type_Uploaded__c';
        controller.fieldsLabel = 'STORE,STORE NAME,PO NUMBER,PO DATE,BANNER,ITEM NO,STORE REC VALUE,STORE REC QTY,Type (Uploaded)';
        controller.defaultValues = 'Mass Uploaded:true;Type (Uploaded):Off-Trade;';
        controller.fileSize = 1;
        controller.currentPageURL = '';
        controller.namefile = 'name.csv';
        controller.containsHeader = false;
        /*
        String content = 'STORE,STORE NAME,PO NUMBER,PO DATE,BANNER,ITEM NO,STORE REC VALUE,STORE REC QTY\r';
        content += '50131,CS ALTEZ,B1004968,27-Apr-18,CS,XXX,100,100';
        */
        String content = '50131,CS ALTEZ,B1004968,27-Apr-18,CS,XXX,100,100,Off-Trade';
        
        controller.contentFile = Blob.valueOf(content);
        controller.lookupEXID = 'ASI_TH_CRM_Actual_Offtake__c/Id:ASI_CRM_Code_Uploaded__c&ASI_CRM_Code_Uploaded__c,ASI_CRM_Code_Uploaded__c&ASI_CRM_Code_Uploaded__c;';
        controller.opt_allOrNone = true;
        controller.upsertMode = false;
        controller.noOfLastRowToIgnore = '0';

        controller.init();
        controller.uploadCSVByBatch();
        Account obj = new Account();
        ASI_CRM_SG_MassUploadByBatchController.Row r1 = new ASI_CRM_SG_MassUploadByBatchController.Row(obj);
        ASI_CRM_SG_MassUploadByBatchController.Row r2 = new ASI_CRM_SG_MassUploadByBatchController.Row(obj, 'Name', 'Test');
        r2.addError('test');
        string[] myArray = controller.StatusMsgs;
        boolean myBoolean = controller.isDisplayErrorLog;
        Test.stopTest();
        
    }
    
    
}