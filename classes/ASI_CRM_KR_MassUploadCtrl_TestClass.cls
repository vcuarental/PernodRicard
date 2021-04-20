/*
*/
/*********************************************************************************
* Name:        ASI_CRM_KR_MassUploadCtrl_TestClass
* Description: test class for ASI_CRM_KR_MassUploadProcess
*
* Version History
*  Date             Developer               Comments
*  ---------------  --------------------    --------------------------------------------------------------------------------
*  ???				???						Created
*  2018-07-30       Vincent Lam             [VL 1.0] The existing test class has no coverage for objects
														ASI_CRM_Holiday__c, ASI_CRM_KR_COGS__c, ASI_CRM_KR_A_P_Guideline__c, 
														ASI_CRM_KR_TempListedMenuPrice__c, ASI_CRM_KR_Temp_SIT__c 
*********************************************************************************/
@isTest
public class ASI_CRM_KR_MassUploadCtrl_TestClass {
    
    public static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;
        
        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
    
    static testMethod void ASI_MFM_MassUploadByBatch_Test(){
        Account a = new Account(name='test', recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'));
        insert a;
        Contact c = new Contact(accountid=a.id,firstname='James',lastname='test', recordTypeId = Global_RecordTypeCache.getRtId('ContactASI_HK_CRM_Wholesalers_Outlets'));
        insert c;
        
        
        test.startTest();
        ASI_CRM_KR_MassUploadByBatchController controller = new ASI_CRM_KR_MassUploadByBatchController();
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
        controller.contentFile = blob.valueOf('True,,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
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
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        //Kammy starts:
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
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
        controller.contentFile = blob.valueOf('True,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        //Kammy starts:
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        controller.fields = 'PersonDoNotCall,AnnualRevenue,PersonMobilePhone,ASI_KOR_Venue_PR_Market_Share__c';
        controller.fieldsLabel = 'DoNotCall,Annual Revenue,mobile,PRK_MS';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('1,19,3,10');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        //Kammy starts:  KR Budget 
        controller.emailNotification = true;
        controller.ObjAPIName = 'ASI_MFM_Budget__c';
        controller.recordtypeName = 'KR Budget';
        controller.fields = 'asi_mfm_type__c,ASI_MFM_P10_Amount__c,ASI_MFM_Total_Amount__c,ASI_MFM_Fiscal_Year__c';       //API Name
        controller.fieldsLabel = 'Type,P10 Amount,Total Amount,Fiscal Year';  //Label 
        controller.template = 'ASI_KR_Budget_Tempalte';
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.contentFile = blob.valueOf('LE10,100,100,FY1516');
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        test.stopTest();
    }
    
    static testMethod void ASI_MFM_MassUploadByBatch_Test_2(){
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            
            Account a = new Account(name='test', recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'));
            insert a;
            Contact c = new Contact(accountid=a.id,firstname='James',lastname='test', recordTypeId = Global_RecordTypeCache.getRtId('ContactASI_HK_CRM_Wholesalers_Outlets'));
            insert c;
            
            Account b = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue');
            insert b;
            
            ASI_CRM_KR_MassUploadByBatchController controller = new ASI_CRM_KR_MassUploadByBatchController();
            controller.emailNotification = true;
            controller.batchMode = false;
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
            
            //Kammy starts:  POSM
            controller.currentPageURLOutput = '12';
            controller.template2 = 'string';
            controller.report = 'report';
            controller.batchMode = true;
            controller.dummyVar = true;
            controller.objName = 'ObjectName';
            controller.emailNotification = false;
            controller.ObjAPIName = 'ASI_KOR_POSM_Order_Request__c';
            controller.recordtypeName = 'New POSM Request';
            controller.fields = 'ASI_MFM_KR_POSM_Order_Request_Name__c,ASI_MFM_Total_Amount__c,ASI_MFM_KR_EmailSentTime__c';       //API Name
            controller.fieldsLabel = 'POSM Order Request Name,Total Amount,Email Sent Time';  //Label 
            controller.template = 'ASI_KR_POSM_Tempalte';
            controller.inlineVF = true;
            controller.DefaultValues = '';
            controller.upsertMode = false;
            controller.recEXID = 'POSM Order Request Name';
            controller.recEXIDcol = 'ASI_MFM_KR_POSM_Order_Request_Name__c';
            controller.contentFile = blob.valueOf('1234500000000067,100,2015-08-01:T08:00:00');
            controller.uploadCSVByBatch();
            
            
            controller.uploadCSV();
            controller.refreshPage();
            controller.refreshPage2();
            
            controller.emailNotification = false;
            controller.ObjAPIName = 'ASI_KOR_POSM_Order_Request__c';
            controller.recordtypeName = 'New POSM Request';
            controller.fields = 'ASI_MFM_KR_POSM_Order_Request_Name__c,ASI_MFM_Total_Amount__c';       //API Name
            controller.fieldsLabel = 'POSM Order Request Name,Total Amount';  //Label 
            controller.template = 'ASI_KR_POSM_Tempalte';
            controller.inlineVF = true;
            controller.DefaultValues = '';
            controller.upsertMode = false;
            controller.recEXIDcol = 'ASI_MFM_KR_POSM_Order_Request_Name__c';
            controller.filesize = 5242881;
            controller.namefile = 'test.csv';
            controller.contentFile = blob.valueOf('"1234567",100');
            controller.currentPageURL ='';
            controller.uploadCSVByBatch();
            
            controller.uploadCSV();
            controller.refreshPage();
            controller.refreshPage2();
            
            test.startTest();     
            
            controller.emailNotification = false;
            controller.ObjAPIName = 'ASI_KOR_POSM_Order_Request__c';
            controller.recordtypeName = 'New POSM Request';
            controller.fields = 'ASI_MFM_KR_POSM_Order_Request_Name__c,ASI_MFM_Total_Amount__c,ASI_MFM_PO_External_ID1__c';       //API Name
            controller.fieldsLabel = 'POSM Order Request Name,Total Amount,PO External ID';  //Label 
            controller.template = 'ASI_KR_POSM_Tempalte';
            controller.lookupEXID = 'ASI_MFM_PO__c/ASI_MFM_PO_External_ID1__c:PO External ID&ASI_MFM_PO_External_ID__c';
            controller.inlineVF = true;
            controller.DefaultValues = '';
            controller.upsertMode = false;  
            controller.recEXIDcol = 'ASI_MFM_KR_POSM_Order_Request_Name__c';
            controller.filesize = 100;
            controller.namefile = 'test.doc';
            controller.contentFile = blob.valueOf('1234567,100');
            controller.currentPageURL ='';
            controller.uploadCSVByBatch();
            
            controller.uploadCSV();
            controller.refreshPage();
            controller.refreshPage2();
            
            
            test.stopTest();
        } 
    }
    
	/* [VL 1.0] BEGIN */
	@isTest 
    public static void testUploadTempSIT(){
		string rtId_wholesaler = Global_RecordTypeCache.getRtId('AccountASI_KOR_Wholesaler');
		
		// insert wholesaler
		list<account> list_a = new list<account>();
		Account WST1 = new Account(recordTypeId=rtId_wholesaler,
									Name='WS Testing Account1',
									ASI_KOR_Wholesaler_Channel__c = 'TOT',
									ASI_KOR_Customer_Code__c = '01234567890',
									ASI_KOR_Grade__c = 'T1',
                                   ASI_LUX_Le_Cercle_Member__c=true,
									ASI_KOR_Venue_Status__c  = 'Active'
								   );     
		list_a.add(WST1);
		Account WST3 = new Account(recordTypeId=rtId_wholesaler,
									Name='WS Testing Account1',
									ASI_KOR_Wholesaler_Channel__c = 'TOT',
									ASI_KOR_Customer_Code__c = '111',
									ASI_KOR_Grade__c = 'T3',
                                   ASI_LUX_Le_Cercle_Member__c=true,
									ASI_KOR_Venue_Status__c  = 'Active'
								   );
		list_a.add(WST3);
		insert list_a;
		
		// create item group
		ASI_KOR_Brand__c brand = new ASI_KOR_Brand__c(
            Name = 'Test Brand', 
            ASI_KOR_Brand_Code__c = 'BC0001'
            
        );
        
        insert brand;
        
        ASI_KOR_Sub_Brand__c subBrand = new ASI_KOR_Sub_Brand__c (
            Name =  'Test Sub-Brand', 
            ASI_KOR_Brand_Code__c = 'SBC', 
            ASI_KOR_Sub_Brand_Code__c = 'SBC', 
            ASI_KOR_Brand__c = brand.Id
        );
        
        insert subBrand;
        
        ASI_KOR_Item_Group__c itemGroup1 = new ASI_KOR_Item_Group__c(
            Name = 'IMNE45',
            ASI_KOR_Item_Group_Code__c = 'IMNE45',
            ASI_KOR_Item_Group_Name__c = 'BIS Imperial Neon 45cl',
            ASI_KOR_VMS_Item_Group_Code__c = 'IMNE_450',
            ASI_KOR_Standard_Bottle_Size__c = 450,
            ASI_KOR_Sub_Brand__c = subBrand.Id,
            ASI_KOR_Active__c = true,
			ASI_CRM_KR_StockInTradeSIT__c = true
            
        );
        insert itemGroup1;
		
        ASI_KOR_Item_Group__c itemGroup2 = new ASI_KOR_Item_Group__c(
            Name = 'IMNE45a',
            ASI_KOR_Item_Group_Code__c = 'IMNE45a',
            ASI_KOR_Item_Group_Name__c = 'BIS Imperial Neon 45cl',
            ASI_KOR_VMS_Item_Group_Code__c = 'IMNE_450',
            ASI_KOR_Standard_Bottle_Size__c = 450,
            ASI_KOR_Sub_Brand__c = subBrand.Id,
            ASI_KOR_Active__c = true
			//,ASI_CRM_KR_StockInTradeSIT__c = true
            
        );
        insert itemGroup2;
		
		// insert last month T3 SIT
		ASI_KOR_Stock_In_Trade__c sit = new ASI_KOR_Stock_In_Trade__c(
			recordtypeid = Global_RecordTypeCache.getRtId('ASI_KOR_Stock_In_Trade__cASI_KOR_SIT_Editable'),
			ASI_KOR_Wholesaler__c = WST3.id,
			ASI_KOR_Status__c = 'Editable',
			ASI_KOR_Year__c = String.valueOf(system.today().addmonths(-1).year()),
			ASI_KOR_Month__c = Datetime.newInstance(system.today().addmonths(-1), Time.newInstance(0,0,0,0)).format('MMMM')
		);
		insert sit;
		
		// insert last month T3 SIT line
		ASI_KOR_WS_Stock_In_Trade_Detail__c sitLine = new ASI_KOR_WS_Stock_In_Trade_Detail__c (
			Stock_In_Trade__c = sit.id,
			ASI_KOR_WS_SIT_End_Stock__c = 10,
			ASI_KOR_Item_Group_Code__c = itemGroup1.id
		);
		insert sitLine;
        
        sit.ASI_KOR_Status__c = 'Locked';
        sit.recordtypeid = Global_RecordTypeCache.getRtId('ASI_KOR_Stock_In_Trade__cASI_KOR_SIT_Locked');
        update sit;
		
		// insert this month T1 SIT
		ASI_KOR_Stock_In_Trade__c sit1 = new ASI_KOR_Stock_In_Trade__c(
			recordtypeid = Global_RecordTypeCache.getRtId('ASI_KOR_Stock_In_Trade__cASI_KOR_SIT_Editable'),
			ASI_KOR_Wholesaler__c = WST1.id,
			ASI_KOR_Status__c = 'Editable',
			ASI_KOR_Year__c = String.valueOf(system.today().year()),
			ASI_KOR_Month__c = Datetime.newInstance(system.today(), Time.newInstance(0,0,0,0)).format('MMMM')
		);
		insert sit1;
		
		// insert this month T1 SIT line
		ASI_KOR_WS_Stock_In_Trade_Detail__c sitLine1 = new ASI_KOR_WS_Stock_In_Trade_Detail__c (
			Stock_In_Trade__c = sit1.id,
			ASI_KOR_WS_SIT_End_Stock__c = 10,
			ASI_KOR_Item_Group_Code__c = itemGroup1.id
		);
		insert sitLine1;
		
		// insert this month temp SIT
		ASI_CRM_KR_Temp_SIT__c sitTemp1 = new ASI_CRM_KR_Temp_SIT__c (
			ASI_CRM_KR_Year__c = String.valueOf(system.today().year()),
			ASI_CRM_KR_Month__c = Datetime.newInstance(system.today(), Time.newInstance(0,0,0,0)).format('MMM'),
			ASI_CRM_KR_WS_CRM_No__c = WST1.id,
			ASI_CRM_KR_End_Stock_Case__c = 10,
			ASI_CRM_KR_Item_Group_Code__c = itemGroup1.id,
			RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_KR_Temp_SIT__cASI_CRM_KR_SIT'),
			ASI_CRM_KR_Status__c = 'Editable'
		);
		insert sitTemp1;
		
		ASI_CRM_KR_Temp_SIT__c sitTemp2 = new ASI_CRM_KR_Temp_SIT__c (
			ASI_CRM_KR_Year__c = String.valueOf(system.today().year()),
			ASI_CRM_KR_Month__c = Datetime.newInstance(system.today(), Time.newInstance(0,0,0,0)).format('MMM'),
			ASI_CRM_KR_WS_CRM_No__c = WST1.id,
			ASI_CRM_KR_End_Stock_Case__c = 10,
			ASI_CRM_KR_Item_Group_Code__c = itemGroup2.id,
			RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_KR_Temp_SIT__cASI_CRM_KR_SIT'),
			ASI_CRM_KR_Status__c = 'Editable'
		);
		insert sitTemp2;
		
        string thisYear = String.valueOf(system.today().year());
        string thisMonth = Datetime.newInstance(system.today(), Time.newInstance(0,0,0,0)).format('MMM');
        
		ASI_CRM_KR_MassUploadByBatchController controller = new ASI_CRM_KR_MassUploadByBatchController();
		controller.emailNotification = true;
		controller.batchMode = false;
		controller.ObjAPIName = 'ASI_CRM_KR_Temp_SIT__c';
		controller.recordtypeName = 'CRM KR SIT';
		controller.fields = 'ASI_CRM_KR_Year__c,ASI_CRM_KR_Month__c,ASI_CRM_KR_WS_CRM_No__c,ASI_CRM_KR_Status__c,ASI_CRM_KR_Item_Group_Code__c,ASI_CRM_KR_End_Stock_Case__c';
		controller.fieldsLabel = 'Year(YYYY),Month(MMM),WS CRM No,Status,Item Group Code,End Stock(Case)';
		controller.lookupEXID = 'Account/ASI_CRM_KR_WS_CRM_No__c:WS CRM No&ASI_KOR_Customer_Code__c;ASI_KOR_Item_Group__c/ASI_CRM_KR_Item_Group_Code__c:Item Group Code&ASI_KOR_Item_Group_Code__c;';
		controller.template = 'ASI_CRM_KR_ItemUpload_Template';
		controller.currentPageURL = String.valueof(WST1.id);
		controller.inlineVF = true;
		controller.DefaultValues = 'Status: Editable;';
		controller.recEXID = 'External ID(Upload)';
		controller.recEXIDcol = 'ASI_CRM_KR_External_ID_Upload__c';
		controller.upsertMode = true;
        controller.opt_allOrNone = true;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
		
        test.startTest();     
            
		controller.init();
		controller.filesize = 2000;
		controller.namefile = 'test.csv';
		controller.contentFile = blob.valueOf('Year(YYYY),Month(MMM),WS CRM No,Status,Item Group Code,End Stock(Case)\r'+thisYear+','+thisMonth+',01234567890,Editable,IMNE45,20');
		controller.uploadCSVByBatch();
        
		controller.contentFile = blob.valueOf('Year(YYYY),Month(MMM),WS CRM No,Status,Item Group Code,End Stock(Case)\r'+thisYear+','+thisMonth+',01234567890,Editable,IMNE45,20\r'+thisYear+','+thisMonth+',01234567890,Locked,IMNE45,20');
		controller.uploadCSVByBatch();
        
		controller.contentFile = blob.valueOf('Year(YYYY),Month(MMM),WS CRM No,Status,Item Group Code,End Stock(Case)\r'+thisYear+','+thisMonth+',111,Editable,IMNE45,20\r,,111,Locked,IMNE45a,');
		controller.uploadCSVByBatch();
         String[] myArray = new List<String>();
        for(String stringtest : controller.StatusMsgs){
            myArray.add(stringtest);
        }
        
        controller.GoToPage2();
        test.stopTest();
	}
	
	@isTest 
    public static void testUploadTempListedMenuPrice(){
		string rtId_wholesaler = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue');
		
		// insert wholesaler
		list<account> list_a = new list<account>();
		Account WST1 = new Account(recordTypeId=rtId_wholesaler,
									Name='WS Testing Account1',
									ASI_KOR_Wholesaler_Channel__c = 'TOT',
									ASI_KOR_Customer_Code__c = '01234567890',
									ASI_KOR_Grade__c = 'T1',
									ASI_KOR_Venue_Status__c  = 'Active'
								   );     
		list_a.add(WST1);
		Account WST3 = new Account(recordTypeId=rtId_wholesaler,
									Name='WS Testing Account1',
									ASI_KOR_Wholesaler_Channel__c = 'TOT',
									ASI_KOR_Customer_Code__c = '111',
									ASI_KOR_Grade__c = 'T3',
									ASI_KOR_Venue_Status__c  = 'Active'
								   );
		list_a.add(WST3);
		insert list_a;
		
		// create item group
		ASI_KOR_Brand__c brand = new ASI_KOR_Brand__c(
            Name = 'Test Brand', 
            ASI_KOR_Brand_Code__c = 'BC0001'
            
        );
        
        insert brand;
        
        ASI_KOR_Sub_Brand__c subBrand = new ASI_KOR_Sub_Brand__c (
            Name =  'Test Sub-Brand', 
            ASI_KOR_Brand_Code__c = 'SBC', 
            ASI_KOR_Sub_Brand_Code__c = 'SBC', 
            ASI_KOR_Brand__c = brand.Id
        );
        
        insert subBrand;
        
        ASI_KOR_Item_Group__c itemGroup1 = new ASI_KOR_Item_Group__c(
            Name = 'IMNE45',
            ASI_KOR_Item_Group_Code__c = 'IMNE45',
            ASI_KOR_Item_Group_Name__c = 'BIS Imperial Neon 45cl',
            ASI_KOR_VMS_Item_Group_Code__c = 'IMNE_450',
            ASI_KOR_Standard_Bottle_Size__c = 450,
            ASI_KOR_Sub_Brand__c = subBrand.Id,
            ASI_KOR_Active__c = true,
			ASI_CRM_KR_Priority_Item__c = true
            
        );
        insert itemGroup1;
		
        ASI_KOR_Item_Group__c itemGroup2 = new ASI_KOR_Item_Group__c(
            Name = 'IMNE45a',
            ASI_KOR_Item_Group_Code__c = 'IMNE45a',
            ASI_KOR_Item_Group_Name__c = 'BIS Imperial Neon 45cl',
            ASI_KOR_VMS_Item_Group_Code__c = 'IMNE_450',
            ASI_KOR_Standard_Bottle_Size__c = 450,
            ASI_KOR_Sub_Brand__c = subBrand.Id,
            ASI_KOR_Active__c = true
			//,ASI_CRM_KR_StockInTradeSIT__c = true
            
        );
        insert itemGroup2;
		
        string thisYear = String.valueOf(system.today().year());
        string thisMonth = Datetime.newInstance(system.today(), Time.newInstance(0,0,0,0)).format('MMM');
        
		ASI_CRM_KR_MassUploadByBatchController controller = new ASI_CRM_KR_MassUploadByBatchController();
		controller.emailNotification = true;
		controller.batchMode = false;
		controller.ObjAPIName = 'ASI_CRM_KR_TempListedMenuPrice__c';
		controller.recordtypeName = 'ASI KR CRM Temp Price';
		controller.fields = 'ASI_CRM_KR_Venue__c,ASI_CRM_KR_Quarter__c,ASI_CRM_KR_Fiscal_Year__c,ASI_CRM_KR_Item_Group_Code__c,ASI_CRM_KR_Listed_Price__c';
		controller.fieldsLabel = 'Venue,Quarter(Q1/Q2/Q3/Q4),Fiscal Year,Item Group Code,Price';
		controller.lookupEXID = 'Account/ASI_CRM_KR_Venue__c:Venue&ASI_KOR_Customer_Code__c;ASI_KOR_Item_Group__c/ASI_CRM_KR_Item_Group_Code__c:Item Group Code&ASI_KOR_Item_Group_Code__c;';
		controller.template = 'ASI_CRM_KR_ListedMenuPriceEntries';
		controller.currentPageURL = String.valueof(WST1.id);
		controller.inlineVF = true;
		controller.DefaultValues = '';
		controller.recEXID = 'Unique ID';
		controller.recEXIDcol = 'ASI_CRM_KR_Unique_ID__c';
		controller.upsertMode = true;
        controller.opt_allOrNone = true;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
		
        test.startTest();     
            
		controller.init();
		controller.filesize = 2000;
		controller.namefile = 'test.csv';
		controller.contentFile = blob.valueOf('Venue,Quarter(Q1/Q2/Q3/Q4),Fiscal Year,Item Group Code,Price\r01234567890,Q1,FY1516,IMNE45,20');
		controller.uploadCSVByBatch();
        
		controller.contentFile = blob.valueOf('Venue,Quarter(Q1/Q2/Q3/Q4),Fiscal Year,Item Group Code,Price\r01234567890,,,,');
		controller.uploadCSVByBatch();
        test.stopTest();
	}
	/* [VL 1.0] END */
    
}