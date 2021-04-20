/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *Test.isRunningTest()
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ASI_MFM_MassUploadByBatchTestClass {

    @isTest
    public static void ASI_MFM_MassUploadByBatch_Test (){
        Account a = new Account(name='test', recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'));
        insert a;
        Contact c = new Contact(accountid=a.id,firstname='James',lastname='test', recordTypeId = Global_RecordTypeCache.getRtId('ContactASI_HK_CRM_Wholesalers_Outlets'));
        insert c;
        
        //Added by Introv @20170322 for TW CRM3
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name = 'testSubBrand',
            ASI_CRM_TW_Company__c = 'PRT', 
            ASI_CRM_Active__c = TRUE, 
            ASI_TH_CRM_Active__c = TRUE,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
        );
        insert sub;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel'), 
            Name = 'TOT (酒店)',
            ASI_CRM_CN_Channel_Code__c = 'TOT');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
            Name = 'Piano Bar (PB)', 
            ASI_CRM_CN_Sub_Channel_Code__c = 'PB',
            ASI_CRM_CN_Channel__c = channel.id, 
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_TW_SubChannel'));
        insert subChannel;   
        
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type'),
            Name = 'PB (鋼琴酒吧)', 
            ASI_TH_CRM_Code__c = 'TW_PB',
            ASI_CRM_Sub_Channel__c = subChannel.id
        );
        insert outletType;
            
        List<Account> listAcc = new List<Account>();
        listAcc.add(new Account(
            RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
            Name='Test Outlet', 
            ASI_TH_CRM_Region__c ='North',
            ASI_KOR_Customer_Code__c = 'EXID_123')
        );   
        insert listAcc;
        /*
        List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
        listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
            Name = 'Test Outlet', 
            ASI_CRM_Account__c = listAcc[0].id, 
            ASI_TH_CRM_OutletType__c = outletType.id, 
            ASI_CRM_Region__c = 'North',
            ASI_CRM_Channel__c = channel.id,
            ASI_CRM_CN_Sub_Channel__c = subChannel.id,
            ASI_CRM_City__c = 'Test City', 
            ASI_CRM_Town__c = 'Test Town', 
            ASI_CRM_TW_Street__c = 'Test Street', 
            ASI_CRM_TW_Number__c = '1', 
            ASI_CRM_TW_Floor__c = '12')
        );
        insert listAccountAdditionalField;
            
        List<ASI_FOC_Free_Goods_Request__c> listFGR = new List<ASI_FOC_Free_Goods_Request__c>();
        //POSM
        listFGR.add(new ASI_FOC_Free_Goods_Request__c(
            recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'),
            ASI_CRM_Target_Outlet__c = listAcc[0].Id,
            ASI_CRM_Receiver__c = 'Mary',
            ASI_CRM_SG_Order_Date__c = date.today(),
            ASI_CRM_Purpose__c = 'purpose')
        );
        insert listFGR;*/
        /*
        List<ASI_MFM_SKU_Code__c> listSKU = new List<ASI_MFM_SKU_Code__c>();
        listSKU.add(new ASI_MFM_SKU_Code__c(
            name = 'POSM SKU',
            ASI_HK_CRM_Active__c = TRUE,
            ASI_MFM_Sub_brand__c = sub.id,
            //ASI_MFM_Item_Group__c = listItemGp[0].id,
            ASI_HK_CRM_IsPOSProduct__c = TRUE,
            ASI_MFM_SKU_External_ID__c = 'EXID_123',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
        );
        insert listSKU;
*/
        ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
        insert uploadLog;
        //End by Introv @20170322 for TW CRM3
        
        test.startTest();
        
        ASI_MFM_MassUploadByBatchController controller = new ASI_MFM_MassUploadByBatchController();
        
        controller.emailNotification = true;
        controller.ObjAPIName = 'Contact';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'AccountID';
        controller.recordtypeName = 'contactType1';
        controller.fields = 'firstname,lastname,description,reportstoid,DoNotCall,Birthdate,reportstoid';
        controller.fieldsLabel = 'firstname,lastname,description,reportsto,DoNotCall,Birthdate,reportsto';
        controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = 'birthdate:2013-01-01';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test,desc,Y,2013-08-01,test\rJohn,Test,desc,N,2013-08-01,test');
        controller.uploadCSVByBatch();
        
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        //controller.fields = 'name,NumberOfEmployees,AnnualRevenue,PersonDoNotCall,PersonBirthdate,PersonMobilePhone';
        controller.fields = 'PersonDoNotCall,PersonBirthdate,PersonMobilePhone';
        controller.fieldsLabel = 'DoNotCall,Birthdate,mobile';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('name,,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        //controller.emailNotification = true;
       	//controller.uploadCSVByBatch();
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        controller.fields = 'name,NumberOfEmployees,AnnualRevenue';
        controller.fieldsLabel = 'name,NumberOfEmployees,AnnualRevenue';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = true;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('name,,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
       // controller.emailNotification = true;
        controller.uploadCSVByBatch();
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        
        //Added by Introv @20170322 for TW CRM3
        /*controller.ObjAPIName = 'ASI_FOC_Request_Item__c';
        controller.parentID = String.valueof(uploadLog.id);
        controller.parentField = 'ASI_FOC_Request_Order__c';
        controller.recordtypeName = 'ASI CRM TW POSM Request Item';
        controller.fields = 'ASI_FOC_SKU__c,ASI_FOC_Request_Quantity_Bottle__c,ASI_CRM_Target_Outlet__c,ASI_CRM_Delivery_To__c,ASI_CRM_Delivery_Address__c,ASI_CRM_Delivery_Tel__c,ASI_CRM_Receiver__c';
        controller.fieldsLabel = 'SKU,Request Quantity(Bottle),Target Outlet,Delivery To,Delivery Address,Delivery Tel,Receiver';
        controller.lookupEXID = 'ASI_MFM_SKU_Code__c/ASI_FOC_SKU__c:FOC Recordtype&RecordTypeid,SKU&ASI_MFM_SKU_External_ID__c; Account/ASI_CRM_Target_Outlet__c:Target Recordtype&RecordTypeid,Target Outlet&ASI_KOR_Customer_Code__c;Account/ASI_CRM_Delivery_To__c:Delivery Recordtype&RecordTypeid,Delivery To&ASI_KOR_Customer_Code__c';
        controller.template = 'ASI_CRM_TW_POSM_Upload_Template';
        controller.currentPageURL = String.valueof(listFGR[0].id);
        controller.inlineVF = true;
        controller.DefaultValues = 'FOC Recordtype:TW SKU Code;Target Recordtype:Outlet (TW);Delivery Recordtype:Outlet (TW)';
        controller.upsertMode = true;
        controller.parentObjectAPIName = 'ASI_MFM_Mass_Upload_Log__c';
        controller.ParentObjectUploadMsg = 'ASI_MFM_Error_Message__c';
        //controller.emailNotification = true;
        controller.opt_allOrNone = false;
        controller.recEXIDcol = 'Id';
        controller.contentFile = blob.valueOf('SKU,Request Quantity(Bottle),Target Outlet,Delivery To,Delivery Address,Delivery Tel,Receiver\rEXID_123,3,EXID_123,EXID_123,address,22223333,Mary');
        controller.uploadCSVByBatch();
        controller.refreshPage();
        controller.refreshPage2();*/
        //End by Introv @20170322 for TW CRM3
               System.debug('controller 1');

        
        //Added by Laputa @20190721 for PR VN MFM
      ASI_MFM_Budget__c b = ASI_MFM_CAP_TestClassHelper.createBudget();       
        
        ASI_MFM_MassUploadByBatchController controller2 = new ASI_MFM_MassUploadByBatchController();
        String[] testGetter = controller.StatusMsgs;
        controller2.ObjAPIName = 'ASI_MFM_Budget__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller2.emailNotification = true;
        controller2.recordtypeName = 'CAP Budget';
        controller2.fields = 'ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c';
        controller2.fieldsLabel = 'P1 Amount,P2 Amount';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller2.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller2.currentPageURL = String.valueof(b.id);
        controller2.inlineVF = false;
        controller2.DefaultValues = 'AP Recordtype:CAP AP Code;BU Recordtype:CAP BU;Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller2.parentObjectAPIName = 'ASI_MFM_Budget__c';
        controller2.ParentObjectUploadMsg = 'ASI_MFM_Remarks__c';
        controller2.init();
        controller2.filesize = 2000;
        controller2.namefile = 'test.csv';
        controller2.contentFile = blob.valueOf('ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c\r220,420');
        controller2.upsertMode = true;
        controller2.opt_allOrNone = false;
        controller2.recEXID = 'test'; 
        controller2.recEXIDcol = 'Id'; 
        controller2.uploadCSVByBatch();  
        System.debug('controller 2');

        ASI_MFM_MassUploadByBatchController controller3 = new ASI_MFM_MassUploadByBatchController();
        ASI_MFM_Plan__c a1 = ASI_MFM_CAP_TestClassHelper.createPlan();  
        controller3.ObjAPIName = 'ASI_MFM_Plan__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller3.emailNotification = true;
        controller3.recordtypeName = 'CAP Plan';
        controller3.fields = 'name,ASI_MFM_Plan_Type__c';
        controller3.fieldsLabel = 'Plan ID,Plan Type';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller3.template = 'ASI_MFM_PlanLineItemTemplate';
        controller3.currentPageURL = String.valueof(a1.id);
        controller3.inlineVF = false;
        controller3.DefaultValues = 'Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller3.parentObjectAPIName = 'ASI_MFM_Plan__c';
        controller3.ParentObjectUploadMsg = 'ASI_MFM_Plan_Description__c';
        controller3.init();
        controller3.filesize = 2000;
        controller3.namefile = 'test.csv';
        controller3.contentFile = blob.valueOf('name,ASI_MFM_Plan_Type__c\rtest,CAPEX');
        controller3.upsertMode = true;
        controller3.opt_allOrNone = false;
        controller3.recEXIDcol = 'Id'; 
        controller3.uploadCSVByBatch(); 
                System.debug('controller 3');

        
         ASI_MFM_Plan__c p1 = ASI_MFM_CAP_TestClassHelper.createPlan();    
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_CAP_TestClassHelper.createPlanLines(p1);  
        
        
        ASI_MFM_MassUploadByBatchController controller4 = new ASI_MFM_MassUploadByBatchController();
        String[] testGetter2 = controller.StatusMsgs;
        controller4.ObjAPIName = 'ASI_MFM_Plan_Line_Item__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller4.emailNotification = true;
        controller4.recordtypeName = 'CAP Plan';
        controller4.fields = 'name,ASI_MFM_Total_Cost__c';
        controller4.fieldsLabel = 'Plan Line Item ID,Plan Line Amount';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller4.template = 'ASI_MFM_PlanLineItemTemplate';
        controller4.currentPageURL = String.valueof(planLine.id);
        controller4.inlineVF = false;
        controller4.DefaultValues = 'Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller4.parentObjectAPIName = 'ASI_MFM_Plan_Line_Item__c';
        controller4.ParentObjectUploadMsg = 'ASI_MFM_List_Item_Description__c';
        controller4.init();
        controller4.filesize = 2000;
        controller4.namefile = 'test.csv';
        controller4.contentFile = blob.valueOf('name,ASI_MFM_Total_Cost__c\rtest,200');
        controller4.upsertMode = true;
        controller4.opt_allOrNone = false;
        controller4.recEXIDcol = 'Id'; 
        controller4.uploadCSVByBatch();        

                System.debug('controller 4');

        
        
        //Introv ASI_TH_CRM_Offtake_Stock_In_Trade__c
		//Account account = new Account(Name='testAccount');
        //ASI_MFM_Sub_brand__c  subBrand = new ASI_MFM_Sub_brand__c(Name='testSubBrand');
        
        Account acc_TH_CRM = new Account
        (
            Name = 'SRI NAKHON',
            ASI_KOR_Customer_Code__c = 'TH_118985',
            recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_TH_CRM_Wholesaler')
        );
        ASI_MFM_Sub_brand__c sb_TH_CRM = new ASI_MFM_Sub_brand__c
        (
            Name = '100 PIPERS 1500 CC.-130',
            ASI_MFM_Sub_brand_External_ID__c = 'TH_130',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand')
        );
        
        //RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_TH_CRM_WS_Stock_In_Trade_Detail'];
        
        ASI_TH_CRM_Offtake_Stock_In_Trade__c stockInTrade = new ASI_TH_CRM_Offtake_Stock_In_Trade__c(ASI_TH_CRM_Account__c=acc_TH_CRM.Id);
        
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetail = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_TH_CRM_WS_Stock_In_Trade_Detail'),
            ASI_TH_CRM_Account__c=acc_TH_CRM.Id,
            ASI_TH_CRM_Sub_brand__c=sb_TH_CRM.Id,
            ASI_TH_CRM_SIT__c=stockInTrade.Id,
            //RecordTypeId=recordType.Id,
            ASI_TH_CRM_Date__c=Date.today()
        );
		ASI_MFM_MassUploadByBatchController controller5 = new ASI_MFM_MassUploadByBatchController();
        controller5.ObjAPIName = 'ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c';
        //controller5.parentID = String.valueof(osit.id);
        //controller5.parentField = 'ASI_TH_CRM_SIT__c';
        controller5.emailNotification = true;
        controller5.recordtypeName = 'ASI_TH_CRM_WS_Stock-In-Trade Detail';
        controller5.fields = 'ASI_CRM_Account_Code__c,ASI_TH_CRM_Sub_brand__c,ASI_TH_CRM_Date__c,ASI_TH_CRM_Ending_Stock_Final__c,ASI_TH_CRM_OfftakeSITDetail_External_ID__c';
        controller5.fieldsLabel = 'Customer Code,SubBrand Code,SIT Date,Ending Stock (Final),External ID';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        //controller5.template = 'ASI_TH_CRM_WS_Offtake_Template';
        controller5.currentPageURL = String.valueof(stockInTradeDetail.id);
        //controller5.currentPageURL = '';
        controller5.inlineVF = false;
        controller5.DefaultValues = '';
		controller5.parentObjectAPIName = 'ASI_TH_CRM_Offtake_Stock_In_Trade__c';
        controller5.ParentObjectUploadMsg = 'ASI_CRM_Branch__c';
        //controller5.parentObjectAPIName = 'ASI_TH_CRM_Offtake_Stock_In_Trade__c';
        //controller5.ParentObjectUploadMsg = 'ASI_TH_CRM_OfftakeSIT_External_ID__c';
        controller5.init();
        controller5.filesize = 2000;
        controller5.namefile = 'test.csv';
        controller5.contentFile = blob.valueOf('Customer Code,SubBrand Code,SIT Date,Ending Stock (Final),External ID\rTH_118985,TH_130,2019-07-31,402,TH_118985TH_1302019-07-31');
        controller5.upsertMode = true;
        controller5.opt_allOrNone = true;
        //controller5.recEXIDcol = 'Id'; 
        controller5.uploadCSVByBatch(); 
        //controller5.uploadCSV(); 
                System.debug('controller 5');

        test.stopTest();
    }

    
    
    
    
    
    
    //Other Coverage - subtle changes from ASI_MFM_MassUploadByBatch_Test()
    //Test 1. Different record type
    //Test 2. upsert = false
    //Test 3. Wrong CSV file
    //etc...
    @isTest
    public static void ASI_MFM_MassUploadByBatch_Test2(){   
        test.startTest();

        //Test 1. Different record type
        //csv cleansing
      	ASI_MFM_Budget__c b = ASI_MFM_CAP_TestClassHelper.createBudgetVN();       
        ASI_MFM_MassUploadByBatchController controller2 = new ASI_MFM_MassUploadByBatchController();
        controller2.ObjAPIName = 'ASI_MFM_Budget__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller2.emailNotification = true;
        controller2.recordtypeName = 'VN DP Budget';
        controller2.fields = 'ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c';
        controller2.fieldsLabel = 'P1 Amount,P2 Amount';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller2.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller2.currentPageURL = String.valueof(b.id);
        controller2.inlineVF = false;
        controller2.DefaultValues = 'AP Recordtype:CAP AP Code;BU Recordtype:CAP BU;Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller2.parentObjectAPIName = 'ASI_MFM_Budget__c';
        controller2.ParentObjectUploadMsg = 'ASI_MFM_Remarks__c';
        controller2.init();
        controller2.filesize = 2000;
        controller2.namefile = 'test.csv';
        controller2.contentFile = blob.valueOf('ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c\r"220",420\r220",420\r"220,420');
        controller2.upsertMode = true;
        controller2.opt_allOrNone = false;
        controller2.recEXIDcol = 'Id'; 
        controller2.uploadCSVByBatch();  
        
    	//Test 2. upsert = false
    	//Test 3. Wrong CSV file
        ASI_MFM_Plan__c p1 = ASI_MFM_CAP_TestClassHelper.createPlan();    
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_CAP_TestClassHelper.createPlanLines(p1);  
        ASI_MFM_MassUploadByBatchController controller4 = new ASI_MFM_MassUploadByBatchController();        
        controller4.ObjAPIName = 'ASI_MFM_Plan_Line_Item__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller4.emailNotification = true;
        controller4.recordtypeName = 'CAP Plan';
        controller4.fields = 'name,ASI_MFM_Total_Cost__c';
        controller4.fieldsLabel = 'Plan Line Item ID,Plan Line Amount';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller4.template = 'ASI_MFM_PlanLineItemTemplate';
        controller4.currentPageURL = String.valueof(planLine.id);
        controller4.inlineVF = false;
        controller4.DefaultValues = 'Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller4.parentObjectAPIName = 'ASI_MFM_Plan_Line_Item__c';
        controller4.ParentObjectUploadMsg = 'ASI_MFM_List_Item_Description__c';
        controller4.init();
        controller4.filesize = 2000;
        controller4.namefile = 'test.csvWRONG';
        controller4.contentFile = blob.valueOf('name,ASI_MFM_Total_Cost__c\rtest",200');
        controller4.upsertMode = false;
        controller4.opt_allOrNone = false;
        controller4.recEXIDcol = 'Id'; 
        controller4.uploadCSVByBatch(); 

        
        test.stopTest();
    }
    
    @isTest
    public static void ASI_MFM_MassUploadByBatch_Test3(){   
        test.startTest();
		ASI_CRM_Budget__c crmb = new ASI_CRM_Budget__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Budget__cASI_CRM_SG_Wholesaler_Budget')
            //ASI_MFM_AP_Code__c = createCAPEXAPCode().id,
            //ASI_MFM_Budget_Type__c = 'CAPEX',
            //ASI_MFM_Type__c = 'Original Budget',
            //ASI_MFM_Fiscal_Year__c = 'FY1314'
        );       
        
        ASI_MFM_MassUploadByBatchController controller6 = new ASI_MFM_MassUploadByBatchController();
        controller6.ObjAPIName = 'ASI_CRM_Budget__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller6.emailNotification = true;
        controller6.recordtypeName = 'SG Wholesaler Budget';
        controller6.fields = 'ASI_CRM_Case_9L__c';
        controller6.fieldsLabel = 'Case';
        //controller6.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        //controller6.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller6.currentPageURL = String.valueof(crmb.id);
        controller6.inlineVF = false;
        controller6.DefaultValues = 'AP Recordtype:CAP AP Code;BU Recordtype:CAP BU;Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller6.parentObjectAPIName = 'ASI_CRM_Budget__c';
        controller6.ParentObjectUploadMsg = 'ASI_CRM_External_Key__c';
        controller6.init();
        controller6.filesize = 2000;
        controller6.namefile = 'test.csv';
        controller6.contentFile = blob.valueOf('ASI_CRM_Case_9L__c\r100');
        controller6.upsertMode = false;
        controller6.opt_allOrNone = false;
        controller6.recEXIDcol = 'Id'; 
        controller6.uploadCSVByBatch(); 
                System.debug('controller 6');
        test.stopTest();
    }
    
    @isTest
    public static void ASI_MFM_MassUploadByBatch_Test4(){   
        test.startTest();
        ASI_CRM_KR_PVA__c b = new ASI_CRM_KR_PVA__c();       
        ASI_MFM_MassUploadByBatchController controller2 = new ASI_MFM_MassUploadByBatchController();
        controller2.ObjAPIName = 'ASI_CRM_KR_PVA__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller2.emailNotification = true;
        controller2.recordtypeName = 'ASI CRM KR PVA';
        controller2.fields = 'ASI_CRM_KR_Channel__c';
        controller2.fieldsLabel = 'Channel';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        //controller2.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller2.currentPageURL = String.valueof(b.id);
        controller2.inlineVF = false;
        controller2.DefaultValues = 'Outlet Image:Iconic;PVA:P';
        controller2.parentObjectAPIName = 'ASI_CRM_KR_PVA__c';
        controller2.ParentObjectUploadMsg = 'ASI_CRM_KR_External_ID_Upload__c';
        controller2.init();
        controller2.filesize = 2000;
        controller2.namefile = 'test.csv';
        controller2.contentFile = blob.valueOf('ASI_CRM_KR_Channel__c\r"test"');
        controller2.upsertMode = true;
        controller2.opt_allOrNone = false;
        controller2.recEXIDcol = 'Id'; 
        controller2.uploadCSVByBatch();  
        test.stopTest();
    }
    
    @isTest
    public static void ASI_MFM_MassUploadByBatch_Test5(){   
        test.startTest();
        ASI_CRM_WS_Target__c b = new ASI_CRM_WS_Target__c();       
        ASI_MFM_MassUploadByBatchController controller2 = new ASI_MFM_MassUploadByBatchController();
        controller2.ObjAPIName = 'ASI_CRM_WS_Target__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller2.emailNotification = true;
        controller2.recordtypeName = 'CN WS Target';
        controller2.fields = 'ASI_CRM_GS_Target__c';
        controller2.fieldsLabel = 'GS Target';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        //controller2.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller2.currentPageURL = String.valueof(b.id);
        controller2.inlineVF = false;
        controller2.DefaultValues = 'Outlet Image:Iconic;PVA:P';
        controller2.parentObjectAPIName = 'ASI_CRM_WS_Target__c';
        controller2.ParentObjectUploadMsg = 'ASI_CRM_External_ID__c';
        controller2.init();
        controller2.filesize = 2000;
        controller2.namefile = 'test.csv';
        controller2.contentFile = blob.valueOf('ASI_CRM_GS_Target__c\r200');
        controller2.upsertMode = true;
        controller2.opt_allOrNone = false;
        controller2.recEXIDcol = 'Id'; 
        controller2.uploadCSVByBatch();  
        test.stopTest();
    }
}