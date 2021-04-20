@isTest
public class ASI_CRM_JP_PurchaseContractUploadTest {
    
    @isTest
	static void testControllerWithData() { 
        
        Test.startTest();
        
        User u = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
         LastName = 'last',
         Email = 'puser000@amamama.com',
         Username = 'puser000@amamama.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US'
        );
     	insert u;
        
      	System.runAs(u) {
        	ASI_CRM_SG_TestClassHelper.createDataSettings();
        	ASI_CRM_SG_TestClassHelper.paymentData paymentC = new ASI_CRM_SG_TestClassHelper.paymentData(true);
			ASI_CRM_Group_Outlet_Type__c groupOutletType = 
            	new ASI_CRM_Group_Outlet_Type__c(
                	ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
                	ASI_CRM_SG_Name__c='High Energy Bar'
            	);
        	insert groupOutletType;
        
        	ASI_CRM_AccountsAdditionalField__c  customer1 = 
            	new ASI_CRM_AccountsAdditionalField__c (
                	name = 'customer Test1',
                	recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                	ASI_CRM_IsParentAccount__c = true,
                	ASI_CRM_MY_CustomerCode__c = '123test123',
                	ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id,
                	ASI_CRM_Business_Registration_Number__c = '12',
                	ASI_CRM_Active__c = true
            	);
			insert customer1 ; 
         
			ASI_CRM_AccountsAdditionalField__c  customer2 = 
            	new ASI_CRM_AccountsAdditionalField__c (
                	name = 'customer Test1',
                	recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                	ASI_CRM_IsParentAccount__c = true,
                	ASI_CRM_MY_CustomerCode__c = '123test',
                	ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id,
                	ASI_CRM_Business_Registration_Number__c = '1',
                	ASI_CRM_Active__c = true,
                	ASI_CRM_Customer__c = customer1.Id
            	);
			insert customer2 ; 
         
			ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
			customerC.customer = customer2;

        	ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
        	ASI_CRM_SG_TestClassHelper.wholesalesCustomerData ws = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
        	List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        	List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
        
        	ASI_CRM_SG_TestClassHelper.offtakeData offtakeC = 
            	new ASI_CRM_SG_TestClassHelper.offtakeData(
                	true, 
                	'ASI_CRM_SG_Actual_offtake', 
                	contractC1.contract.Id, 
                	ws.customer.Id, 
                	skuList.get(0).Id
            	);
          
        	ASI_CRM_Customer_Mapping__c m = new ASI_CRM_Customer_Mapping__c();
        	m.ASI_CRM_External_ID__c = '123';
        	m.ASI_CRM_JDE_Customer__c = customerC.customer.Id;
        
        	m.ASI_CRM_Wholesaler__c = ws.customer.Id;
        	m.ASI_CRM_Offtake_Customer_No__c = 'customer';
        	m.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Customer_Mapping__cASI_CRM_SG_Customer_Mapping');
        	insert m;
        
        	ASI_CRM_JP_PurchaseContractUploadCmpCtrl controller1 = new ASI_CRM_JP_PurchaseContractUploadCmpCtrl();
        	controller1.resultMessages =  new List<String>();
        	controller1.PanelName = '';
        	controller1.template = '';
        	controller1.report = '';
        	controller1.inlineVF = false;
        	controller1.batchMode = false;
			controller1.dummyVar = false;
        	controller1.objName = '';
        
        	ASI_CRM_JP_PurchaseContractUploadCmpCtrl controller = new ASI_CRM_JP_PurchaseContractUploadCmpCtrl();
        	System.debug('--parentID--'+controller.parentID);
        	controller.emailNotification = true;
        	controller.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
        	controller.parentObjectAPIName = 'ASI_CRM_ActualOfftakeHeader__c';
        	controller.ParentObjectUploadMsg = 'ASI_CRM_Upload_Log__c';
        	controller.recordtypeName = 'ASI CRM SG Actual Offtake';
        	controller.fields = 'ASI_CRM_Type_Uploaded__c,ASI_CRM_Code_Uploaded__c,ASI_CRM_Wholesaler_Code_Uploaded__c,' 
                + 'ASI_CRM_Customer_Code_Uploaded__c,ASI_TH_CRM_Offtake_G_L_Date__c,ASI_CRM_SKU_Code_Uploaded__c,' 
                + 'ASI_CRM_InvoiceNumber__c,ASI_CRM_Original_Quantity__c';
        	controller.fieldsLabel = 'Type,Code,Wholesaler Code,Customer Code,Offtake G/L Date,SKU Code,Invoice Number,Quantity';
        	controller.defaultValues = 'Mass Uploaded:true;';
        	controller.fileSize = 130000;
        	controller.parentField = 'Id,Name';
        	controller.currentPageURL = offtakeC.offtake.Id;
        	controller.namefile = 'nameTesting.csv';

            /*
        	String content = '"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135183","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
            				+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135184","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135185","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135186","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135187","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135188","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","PRS-AAT-18-0065","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF;
			*/
            String content = '"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135183","3","","","",""'+'"\n"'
            				+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135184","3","","","",""'+'"\n"'
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135185","3","","","",""'+'"\n"'
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135186","3","","","",""'+'"\n"'
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135187","3","","","",""'+'"\n"'
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","135188","3","","","",""'+'"\n"'
                			+'"INV","U","' + ws.customer.ASI_CRM_MY_CustomerCode__c + '","customer","20170701","test1","PRS-AAT-18-0065","3","","","",""';
            
        
			system.debug('----content--'+content);
        	controller.contentFile = Blob.valueOf(content);
        	system.debug('----controller.contentFile--'+controller.contentFile);
        	controller.lookupEXID = 'ASI_TH_CRM_Actual_Offtake__c/Id:ASI_CRM_Code_Uploaded__c&ASI_CRM_Code_Uploaded__c,ASI_CRM_Code_Uploaded__c&ASI_CRM_Code_Uploaded__c;';
        	controller.opt_allOrNone = true;
        	controller.upsertMode = false;

        	Account testccount = 
            	new Account(
                	Name = 'TestAccount',
                	RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet (TH)').getRecordTypeId()
            	); // RecordTypeForTest.getRecType('Account', 'Outlet (TH)' )
        	insert testccount ;
        
        	ASI_CRM_ActualOfftakeHeader__c actualofftakeheader = new ASI_CRM_ActualOfftakeHeader__c();
        	actualofftakeheader.ASI_CRM_Status__c = 'Draft';
        	actualofftakeheader.ASI_CRM_OfftakeDate__c = system.today();
        	actualofftakeheader.ASI_CRM_Outlet__c = testccount.Id;
        	actualofftakeheader.ASI_CRM_ToOutlet__c = customer1.Id;
        	insert actualofftakeheader;
        
        	controller.currentPageURL = actualofftakeheader.Id;
        
        	Attachment att = 
            	new Attachment(
                	ParentId = actualofftakeheader.Id, 
                	name = 'nameTesting.csv', 
                	body=Blob.valueOf(content), 
                	ContentType ='text/plain; charset=GB2312',
                	description='This is the testing'
            	);
        	insert att;
        
        	system.debug('offtakeC.offtake.Id'+offtakeC.offtake);
        	system.debug('84--->att-->'+att);
          
        	controller.AttId = att.id;
        	controller.init();
        	controller.uploadCSVByBatch();
        	string[] myArray = controller.StatusMsgs;
        	controller.back();
        	controller.uploadCSV();
        
        	controller.refreshPage();
        	controller.refreshPage2();

        	List<String> lst = new List<String>();
        	Account obj = new Account();
        	ASI_CRM_JP_PurchaseContractUploadCmpCtrl.Row r1 = new ASI_CRM_JP_PurchaseContractUploadCmpCtrl.Row(obj);
        	ASI_CRM_JP_PurchaseContractUploadCmpCtrl.Row r2 = new ASI_CRM_JP_PurchaseContractUploadCmpCtrl.Row(obj, 'Name', 'Test');
        	r2.addError('errMsg');
        	r2.addError('test');
    	}
        Test.stopTest();
    }
    
    @isTest
    static void testControllerWithNoData() {
        
        Test.startTest();
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        ASI_CRM_SG_TestClassHelper.paymentData paymentC = new ASI_CRM_SG_TestClassHelper.paymentData(true);
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData ws = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
        ASI_CRM_SG_TestClassHelper.offtakeData offtakeC = 
            new ASI_CRM_SG_TestClassHelper.offtakeData(
                true, 
                'ASI_CRM_SG_Actual_offtake', 
                contractC1.contract.Id, 
                ws.customer.Id, 
                skuList.get(0).Id
            );
        
        ASI_CRM_Customer_Mapping__c m = new ASI_CRM_Customer_Mapping__c();
        m.ASI_CRM_External_ID__c = '123';
        m.ASI_CRM_JDE_Customer__c = customerC.customer.Id;
        m.ASI_CRM_Wholesaler__c = ws.customer.Id;
        m.ASI_CRM_Offtake_Customer_No__c = 'customer';
        m.recordtypeid = 
            Global_RecordTypeCache.getRTId('ASI_CRM_Customer_Mapping__cASI_CRM_SG_Customer_Mapping');
        insert m;

        ASI_CRM_JP_PurchaseContractUploadCmpCtrl controller = new ASI_CRM_JP_PurchaseContractUploadCmpCtrl();
        controller.emailNotification = true;
        controller.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
        controller.parentObjectAPIName = 'ASI_CRM_ActualOfftakeHeader__c';
        controller.ParentObjectUploadMsg = 'ASI_CRM_Upload_Log__c';
        controller.recordtypeName = 'ASI CRM SG Actual Offtake';
        controller.fields = 
            'ASI_CRM_Type_Uploaded__c,ASI_CRM_Code_Uploaded__c,ASI_CRM_Wholesaler_Code_Uploaded__c,ASI_CRM_Customer_Code_Uploaded__c,' 
            + 'ASI_TH_CRM_Offtake_G_L_Date__c,ASI_CRM_SKU_Code_Uploaded__c,ASI_CRM_InvoiceNumber__c,ASI_CRM_Original_Quantity__c';
        controller.fieldsLabel = 'Type,Code,Wholesaler Code,Customer Code,Offtake G/L Date,SKU Code,Invoice Number,Quantity';
        controller.defaultValues = 'Mass Uploaded:true;';
        controller.fileSize = 1;
        controller.currentPageURL = offtakeC.offtake.Id;
        controller.namefile = 'name.csv';
        
        String content = '123,213,213,123,123123,';
        
        controller.contentFile = Blob.valueOf(content);
        controller.lookupEXID = '';
        controller.opt_allOrNone = true;
        controller.upsertMode = false;

        controller.init();
        controller.uploadCSV();
        string[] myArray = controller.StatusMsgs;

        Test.stopTest();
        
    }
    
    @isTest
	static void testControllerWithWrongFileName() { 
        
        Test.startTest();
        
        ASI_CRM_JP_PurchaseContractUploadCmpCtrl controller = new ASI_CRM_JP_PurchaseContractUploadCmpCtrl();
        System.debug('--parentID--'+controller.parentID);
        controller.emailNotification = true;
        controller.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
        controller.parentObjectAPIName = 'ASI_CRM_ActualOfftakeHeader__c';
        controller.ParentObjectUploadMsg = 'ASI_CRM_Upload_Log__c';
        controller.recordtypeName = 'ASI CRM SG Actual Offtake';
        controller.fields = 'ASI_CRM_Type_Uploaded__c,ASI_CRM_Code_Uploaded__c,ASI_CRM_Wholesaler_Code_Uploaded__c,' 
            + 'ASI_CRM_Customer_Code_Uploaded__c,ASI_TH_CRM_Offtake_G_L_Date__c,ASI_CRM_SKU_Code_Uploaded__c,' 
            + 'ASI_CRM_InvoiceNumber__c,ASI_CRM_Original_Quantity__c';
        controller.fieldsLabel = 'Type,Code,Wholesaler Code,Customer Code,Offtake G/L Date,SKU Code,Invoice Number,Quantity';
        controller.defaultValues = 'Mass Uploaded:true;';
        controller.fileSize = 130000;
        controller.parentField = 'Id,Name';
        controller.namefile = 'nameTesting.txt';
        
        String content = '"INV","U","123","customer","20170701","test1","135183","3"'+'"\n"'
            			+'"INV","U","123","customer","20170701","test1","135183","3"';
        
        system.debug('----content--'+content);
        controller.contentFile = Blob.valueOf(content);
        system.debug('----controller.contentFile--'+controller.contentFile);
        controller.lookupEXID = 'ASI_TH_CRM_Actual_Offtake__c/Id:ASI_CRM_Code_Uploaded__c&ASI_CRM_Code_Uploaded__c,ASI_CRM_Code_Uploaded__c&ASI_CRM_Code_Uploaded__c;';
        controller.opt_allOrNone = true;
        controller.upsertMode = false;

        controller.init();
        controller.uploadCSVByBatch();

        Test.stopTest();
    }
}