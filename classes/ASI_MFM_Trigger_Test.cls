/***************************************************************************************************************************
 * Name:        ASI_MFM_Trigger_Test
 * Description: 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-07-17       Wilken Lee              [Created] Provide coverage for MFM triggers
 ****************************************************************************************************************************/
@isTest(SeeAllData=true)
private class ASI_MFM_Trigger_Test {    
	private static string getFiscalYear(){
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
	static testMethod void test_ASI_MFM_Plan_BeforeInsert() {
		ASI_MFM_Plan__c capPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c cnPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c gfPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c hkPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c krPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c myPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c phPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c rmPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c scPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c sgPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c thPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c trPlan = new ASI_MFM_Plan__c();
		ASI_MFM_Plan__c twPlan = new ASI_MFM_Plan__c();				
			
		capPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan');
		cnPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CN_Plan');
		gfPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan');
		hkPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan');
		krPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan');
		myPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan');
		phPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DP_Plan');
		rmPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_RM_Plan');
		scPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SC_Plan');
		sgPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan');
		thPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TH_Plan');
		trPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan');
		twPlan.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan');
			
		try {
			insert capPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert cnPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert gfPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert hkPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert krPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert myPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert phPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert rmPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert scPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert sgPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert thPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert twPlan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}			
	}        

	static testMethod void test_ASI_MFM_PlanLineItem_BeforeInsert() {
		ASI_MFM_CAP_TestClassHelper.createRoutePlanType();
		
		ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
		
		ASI_MFM_Plan_Line_Item__c capLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c capTWLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c cnLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c gfLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c hkLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c jpLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c krLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c myLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c phLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c rmLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c scLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c sgLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c thLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c trLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		ASI_MFM_Plan_Line_Item__c twLine = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.Id);
		
		capLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CAP_Plan_Line_Item');
		capTWLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CAP_TW_Plan_Line_Item');
		cnLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CN_Plan_Line_Item');
		gfLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item');
		hkLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item');
		jpLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item');
		krLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item');
		myLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item');
		phLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_PH_Plan_Line_Item');
		rmLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_RM_Plan_Line_Item');
		scLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SC_Plan_Line_Item');
		sgLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item');
		thLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TH_Plan_Line_Item');
		trLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item');
		twLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item');
		
		try {
			insert capLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}

		try {
			insert capTWLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert cnLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert gfLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert hkLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert krLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert myLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert phLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert rmLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert scLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert sgLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert thLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert twLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}	
	}
	
	static testMethod void test_ASI_MFM_PlanLineItem_BeforeUpdate_MY_CAP() {
		//Start MY Plan Line*****************************
			ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1920', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_MY_Prefix'));
			insert px;    
			
			user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
			 u.ASI_MFM_Country__c = 'MY';
			update u;
			
			ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
			insert pr;
			
			ASI_MFM_Plan__c myPlan = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today().addMonths(3), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft');
			insert myPlan;
			
			Account myAccount = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'), Name = 'MY Customer');
			insert myAccount;
			
			ASI_MFM_BU__c myBU = new ASI_MFM_BU__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_MY_BU'), Name = 'MY BU');
			insert myBU;
			
			ASI_MFM_Plan_Line_Item__c myLine =new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = myPlan.id, ASI_MFM_Customer_Name__c = myAccount.Id, ASI_MFM_BU_Code__c  = myBU.Id, ASI_MFM_Total_Cost__c=100000,recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'));
			insert myLine;
			
			update myLine;
			delete myLine;
			delete myPlan;
		//End MY Plan Line*****************************
		
		//Start CAP Plan Line*****************************
			ASI_MFM_Plan__c capPlan = ASI_MFM_CAP_TestClassHelper.createPlan();
			
			ASI_MFM_Plan_Line_Item__c  capLine = ASI_MFM_CAP_TestClassHelper.createCAPEXPlanLines(capPlan);
			update capLine;
			delete capLine;
			delete capPlan;
		//End CAP Plan Line*****************************
	}
	
	static testMethod void test_ASI_MFM_PlanLineItem_BeforeUpdate_PH_SG() {		
		//Start PH Plan Line*****************************
			ASI_MFM_Plan__c phPlan = ASI_MFM_PH_TestClassHelper.createPHDPPlan();
			ASI_MFM_Plan_Line_Item__c phLine = ASI_MFM_PH_TestClassHelper.createPHPlanLines1(phPlan);
			
			update phLine;
			delete phLine;
			delete phPlan;
		//End PH Plan Line*****************************
		
		//Start SG Plan Line*****************************
			user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
			u.ASI_MFM_Country__c = 'SG';
			update u;
			
			Account sgAccount = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_SG_Customer'),Name='SG Customer');           
			insert sgAccount;
		
			ASI_MFM_Prefix__c sgPrefix = new ASI_MFM_Prefix__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'), name='test1', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1920', ASI_MFM_Default_Customer__c=sgAccount.id,ASI_MFM_Location__c = 'Singapore');
			insert sgPrefix;
			
			ASI_MFM_Role_Prefix_Relationship__c sgRolePrefix = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=sgPrefix.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
			insert sgRolePrefix;	
			
        	//20200701:AM@introv - fix duplicate external ID start
        	/*
			ASI_MFM_Plan__c sgPlan = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), name='test',ASI_MFM_Status__c='Draft',ASI_MFM_Plan_External_ID_Upload__c='1',
														ASI_MFM_End_Date__c=Date.today(), ASI_MFM_Plan_Description__c='testPlanDescription',  ASI_MFM_Prefix__c=sgPrefix.id,
														ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today());*/
        	ASI_MFM_Plan__c sgPlan = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), name='test',ASI_MFM_Status__c='Draft',ASI_MFM_Plan_External_ID_Upload__c='ASI_PR_SG_TEST_999',
														ASI_MFM_End_Date__c=Date.today(), ASI_MFM_Plan_Description__c='testPlanDescription',  ASI_MFM_Prefix__c=sgPrefix.id,
														ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today());
			//20200701:AM@introv - fix duplicate external ID end
        	insert sgPlan;

			ASI_MFM_Sub_brand__c sgSubBrand = new ASI_MFM_Sub_brand__c(Name='SG Sub-brand', recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'));
			insert sgSubBrand;
			
			ASI_MFM_A_C_Code__c sgACCode = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'));
			insert sgACCode;
			
			ASI_MFM_Plan_Line_Item__c sgLine = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Plan__c = sgPlan.id, ASI_MFM_Sub_brand_Code__c = sgSubBrand.Id, ASI_MFM_A_C_Code__c=sgACCode.id, ASI_MFM_Customer_Name__c=sgAccount.id, ASI_MFM_List_Item_Description__c='testDescription');
			insert sgLine;
			update sgLine;
			delete sgLine;
			delete sgPlan;
		//END SG Plan Line*****************************
	}
	
	static testMethod void test_ASI_MFM_PO_BeforeInsert() {
		ASI_MFM_PO__c capPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c cnPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c gfPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c hkPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c krPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c myPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c phPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c rmPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c scPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c sgPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c thPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c trPO = new ASI_MFM_PO__c();
		ASI_MFM_PO__c twPO = new ASI_MFM_PO__c();				
			
		capPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO');
		cnPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO');
		gfPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO');
		hkPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO');
		krPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO');
		myPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO');
		phPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DP_PO');
		rmPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_RM_PO');
		scPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SC_PO');
		sgPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO');
		thPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TH_PO');
		trPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO');
		twPO.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO');
			
		try {
			insert capPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert cnPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert gfPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert hkPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert krPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert myPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert phPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert rmPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert scPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert sgPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert thPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert twPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}			
	}        
	
	static testMethod void test_ASI_MFM_PO_BeforeUpdate_CAP_GF(){
		//CAP PO
        ASI_MFM_CAP_TestClassHelper.createRoutePOType();
        ASI_MFM_PO__c capPO = ASI_MFM_CAP_TestClassHelper.createPO();
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(capPO);
		
		update poLine;
		
		//PO Line
		try {
			delete poLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}	

		//PO
		try {
			delete capPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}			
		
		//GF PO
		Test.startTest(); 
		ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_TR_Rec_Type__c = 'Duty Paid');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
                
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_TR_Rec_Type__c = 'Duty Paid');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c gfPO = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Prefix__c=pxo.id); 
        insert gfPO;
		
		try {
			delete gfPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}		        
	}
	
	static testMethod void test_ASI_MFM_PO_BeforeUpdate_MY() {
		string fy = getFiscalYear();
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        
		ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='USD', ASI_MFM_Counter_Currency__c='EUR', ASI_MFM_Country__c='MY', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = fy);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
		List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
		
		ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand'));
        insert sub;
		
		ASI_MFM_BU__c myBU = new ASI_MFM_BU__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_MY_BU'), Name = 'MY BU');
		insert myBU;
		
        ASI_MFM_Plan__c myPlan = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert myPlan;


		ASI_MFM_Plan_Line_Item__c myLine =new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = myPlan.id, ASI_MFM_Customer_Name__c = acc1.Id, ASI_MFM_BU_Code__c  = myBU.Id, ASI_MFM_Total_Cost__c=100000,recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'));
		insert myLine;
				
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;        
        
		test.startTest();
		
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO'), ASI_MFM_Plan__c=myPlan.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=px.id, ASI_MFM_BU_Code__c = myBU.Id); 
        insert po;        
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true, ASI_MFM_BU_Code__c = myBU.Id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
		update poi;
		delete poi;
		delete po;
				
        test.stopTest();
    }
	
	static testMethod void test_ASI_MFM_PO_BeforeUpdate_KR() {
		string fy = getFiscalYear();
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        
		List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
		ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
		Prefix_List.add(prefixKR_PLAN);
		ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = fy);
		Prefix_List.add(prefixPR);
		ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PO',ASI_MFM_Fiscal_year__c = fy);
		Prefix_List.add(prefixPO);
		ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = fy);
		Prefix_List.add(prefixPayment);
		insert Prefix_List;
		
		//-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
		List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
		ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPayment.id,ASI_MFM_Role_Name__c = u.userRole.developerName);
		PrefixRole_List.add(rel_Payment);
		ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPO.id,ASI_MFM_Role_Name__c = u.userRole.developerName);
		PrefixRole_List.add(rel_PO); 
		ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = u.userRole.developerName);
		PrefixRole_List.add(rel_Plan); 
		ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id,ASI_MFM_Role_Name__c = u.userRole.developerName);
		PrefixRole_List.add(rel_PR);
		
		insert PrefixRole_List;   
	  
		ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
													recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
													ASI_MFM_Start_Date__c = date.today().adddays(1),
													ASI_MFM_End_Date__c = date.today().adddays(1),
													ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
													ASI_MFM_Status__c='Approved',   
													ASI_MFM_Budget_Type__c = 'NORM',  
													OwnerId =u.id);
		insert plan1;
		
		ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
																			 ASI_MFM_Actual_Spending_Amount__c=0,
																			 ASI_MFM_Month_1_Cost__c = 100,
																			 ASI_MFM_Month_2_Cost__c = 100,
																			 ASI_MFM_Month_3_Cost__c = 100,   
																			 ASI_MFM_Month_4_Cost__c = 100,
																			 ASI_MFM_Month_5_Cost__c = 100,
																			 ASI_MFM_Month_6_Cost__c = 100,
																			 ASI_MFM_Month_7_Cost__c = 100,
																			 ASI_MFM_Month_8_Cost__c = 100,
																			 ASI_MFM_Month_9_Cost__c = 100,
																			 ASI_MFM_Month_10_Cost__c = 100,
																			 ASI_MFM_Month_11_Cost__c = 100,
																			 ASI_MFM_Month_12_Cost__c = 200,
																			 ASI_MFM_Total_Cost__c = 10000,
																			 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
		insert planLine1;
					
		
		//-------------------------------------------------- Customer----------------------------------------------------------//
		List<Account> AccountList = new List<Account>();
		Account kracc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
		AccountList.add(kracc1);
		Account kracc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
		AccountList.add(kracc2);
		insert AccountList;
		
		ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test Name',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
		insert customer1;
	
		test.startTest();
		
		/*ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
																				 ASI_MFM_Comment__c = 'comment',
																				 ASI_MFM_PR_Name__c='PR Name',
																				 ASI_MFM_Company_Code__c = 'PRK',
																				 ASI_MFM_PR_Date__c = date.today(),
																				 ASI_MFM_Plan__c = plan1.id,
																				 ASI_MFM_Service_Item_POSM__c = 'POSM',
																				 ASI_MFM_Ship_To__c = kracc1.ID,
																				 ASI_MFM_Status__c = 'Approved',
																				 ASI_MFM_Prefix__c = prefixPR.id,
																				 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
		
		insert PR_Header;    
		
		ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
																						 ASI_MFM_Plan_Line_Item__c = planLine1.id,
																						 ASI_MFM_Purchase_Request__c = PR_Header.id,
																						 ASI_MFM_Quantity__c = 10,
																						 ASI_MFM_UOM__c = 'EA',
																						 ASI_MFM_Estimated_PR_budget__c = 100,
																						 ASI_MFM_Delivery_Date__c= date.today(),
																						 ASI_MFM_Description__c = 'Description',
																						 ASI_MFM_Unit_Cost__c = 100);
		insert PR_Line;*/
		
		
		
		
		//-------------------------------------------------- PO ----------------------------------------------------------//
		ASI_MFM_PO__c krPO = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = kracc2.id,
											 //ASI_MFM_Purchase_Request__c = PR_Header.id,
											 ASI_MFM_PO_Raised_Date__c = date.today(),  
											 ASI_MFM_Status__c = 'Approved',
											 ASI_MFM_Prefix__c = prefixPO.id,
											 ASI_MFM_Plan__c = plan1.id,
											 ASI_MFM_VAT__c = 10.00,
											 ASI_MFM_Company_Code__c = '222',
											 ASI_MFM_Warehouse__c = kracc1.id,
											 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
		insert krPO;  
		
		
		
		ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
																	   ASI_MFM_PO__c = krPO.id,
																	   ASI_MFM_Plan_Line_Item__c = planLine1.id,
																	   ASI_MFM_Unit_Price__c = 1000,  
																	   ASI_MFM_KR_Quantity__c = 100,    
																	   ASI_MFM_Amount__c = 100000,
																	   ASI_MFM_Base_Currency_Amount__c=100000,
																	   ASI_MFM_Delivery_Date__c =  date.today(),
																	   ASI_MFM_G_L_Date__c = date.today()  
																	   //ASI_MFM_Purchase_Request_Line__c = PR_Line.id
																	  );
		
		insert po_line;
		update po_line;
		delete po_line;
		
		try {
			delete krPO;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
        test.stopTest();
    }
	
	static testMethod void test_ASI_MFM_Payment_BeforeInsert() {
		ASI_MFM_Payment__c capPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c cnPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c gfPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c hkPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c krPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c myPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c phPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c rmPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c scPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c sgPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c thPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c trPayment = new ASI_MFM_Payment__c();
		ASI_MFM_Payment__c twPayment = new ASI_MFM_Payment__c();				
			
		capPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment');
		cnPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment');
		gfPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment');
		hkPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_HK_Payment');
		krPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment');
		myPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MY_Payment');
		phPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DP_Payment');
		rmPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_RM_Payment');
		scPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SC_Payment');
		sgPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment');
		thPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_TH_Payment');
		trPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_TR_Payment');
		twPayment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_TW_Payment');
			
		try {
			insert capPayment;
			system.debug('CAP Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert cnPayment;
			system.debug('CN Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert gfPayment;
			system.debug('GF Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert hkPayment;
			system.debug('HK Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert krPayment;
			system.debug('KR Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert myPayment;
			system.debug('MY Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert phPayment;
			system.debug('PH Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert rmPayment;
			system.debug('RM Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert scPayment;
			system.debug('SC Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert sgPayment;
			system.debug('SG Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert thPayment;
			system.debug('TH Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert twPayment;
			system.debug('TW Payment Success');
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}			
	}        

	static testMethod void test_ASI_MFM_Payment_BeforeUpdate_SC() {   
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){                                        
            ASI_MFM_AP_Code__c  AP_Code = ASI_MFM_SC_TestClass.createAPCode();            
            ASI_MFM_BU__c  BU_Code = ASI_MFM_SC_TestClass.createBUCode();
                        
            ASI_MFM_Prefix__c prefixPLAN = ASI_MFM_SC_TestClass.createPrefix('Plan', 'Plan', Role_Test.DeveloperName);                                 
            ASI_MFM_Prefix__c prefixPO = ASI_MFM_SC_TestClass.createPrefix('PO1', 'PO', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment1 = ASI_MFM_SC_TestClass.createPrefix('Payment', 'Payment', Role_Test.DeveloperName);  
            ASI_MFM_Prefix__c prefixPayment2 = ASI_MFM_SC_TestClass.createPrefix('Payment', 'Payment', Role_Test.DeveloperName);  
                                
            ASI_MFM_Plan__c plan = ASI_MFM_SC_TestClass.createPlan(prefixPLAN.id);
			
			ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan.Id,
																			 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SC_Plan_Line_Item'),
																			 ASI_MFM_Total_Cost__c=100000,
																			 asi_mfm_ap_code__c = AP_Code.Id,
																			 ASI_MFM_AP_Code_PL__c = 'Medical',
																			 ASI_MFM_List_Item_Description__c='hello',
																			 ASI_MFM_AP_Group__c='Non-specific'
																			 );
																				 
            insert planLine1;

            Account acc1 = ASI_MFM_SC_TestClass.createAccSupplier();            
            Account acc2 = ASI_MFM_SC_TestClass.createAccSubledger();           
                                   
            ASI_MFM_PO__c po = ASI_MFM_SC_TestClass.createPO(prefixPO.id, plan.id , acc1.id);
			
			 ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SC_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.Id,                                                                             
                                                                           ASI_MFM_Amount__c = 1000,
                                                                           asi_mfm_ap_code__c = AP_Code.Id,
                                                                           ASI_MFM_BU_Code__c = BU_Code.id,
                                                                           ASI_MFM_SC_Subledger__c = acc2.id,
                                                                           ASI_MFM_AP_Code_PL__c = 'Medical',
                                                                           ASI_MFM_List_Item_Description__c='hello',
                                                                           ASI_MFM_AP_Group__c='Non-specific'
                                                                          );
            
            insert po_line; 			
               
            ASI_MFM_Payment__c PaymentHeader = ASI_MFM_SC_TestClass.createPayment(prefixPayment1.id,po.id,acc1.id);
			
			Test.startTest();            
            ASI_MFM_Payment_Line_Item__c PaymentDetail = ASI_MFM_SC_TestClass.createPaymentLine(PaymentHeader.id, po_line.id , acc1.id, AP_Code.id, BU_Code.id , AP_Code.ASI_MFM_A_C_Code__c);
            
            PaymentDetail.ASI_MFM_Payment_Amount__c=200;
            update PaymentDetail;
                        
			try{
              delete PaymentDetail;
            }
			catch(Exception e){
				system.debug('Exception thrown');
			}
			
            try{
              delete PaymentHeader;
            }
			catch(Exception e){
				system.debug('Exception thrown');
			}
			
			try{
              update po;
            }
			catch(Exception e){
				system.debug('Exception thrown');
			}
			
			try{
              delete po;
            }
			catch(Exception e){
				system.debug('Exception thrown');
			}
			
			try{
              update plan;
            }
			catch(Exception e){
				system.debug('Exception thrown');
			}
		}
	}

	static testMethod void test_ASI_MFM_PaymentLineItem_BeforeInsert() {
		ASI_MFM_CAP_TestClassHelper.createRoutePaymentType();

        ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPO();
    
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        
        ASI_MFM_Payment__c Payment = ASI_MFM_CAP_TestClassHelper.createPayment(po);
		
		ASI_MFM_Payment_Line_Item__c capLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c capTWLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c cnLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c gfLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c hkLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c jpLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c krLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c myLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c phLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c rmLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c scLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c sgLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c thLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c trLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		ASI_MFM_Payment_Line_Item__c twLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = Payment.Id);
		
		capLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item');
		capTWLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_TW_Payment_Line_Item');
		cnLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');
		gfLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item');
		hkLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_HK_Payment_Line_Item');
		jpLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item');
		krLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item');
		myLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MY_Payment_Line_Item');
		phLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item');
		rmLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_RM_Payment_Line_Item');
		scLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SC_Payment_Line_Item');
		sgLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item');
		thLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_TH_Payment_Line_Item');
		trLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_TR_Payment_Line_Item');
		twLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_TW_Payment_Line_Item');
		
		try {
			insert capLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}

		try {
			insert capTWLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert cnLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert gfLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert hkLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert krLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert myLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert phLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert rmLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert scLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert sgLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert thLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		try {
			insert twLine;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}	
	}	
	
	static testMethod void test_ASI_MFM_PaymentLineItem_BeforeUpdate_SG() {
		User thisUser = [SELECT ID, ASI_MFM_Country__c, userRole.developerName FROM user WHERE ID = :userinfo.getUserID()];
      
		//Prefix
		List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c>();
		ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(  name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore');
		PrefixList.add(px);
		ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
		PrefixList.add(pxo);
		ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
		PrefixList.add(pxa);
		insert PrefixList; 

		//Role Prefix Relationship
		List<ASI_MFM_Role_Prefix_Relationship__c> RolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
		ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
		RolePrefixList.add(pr);
		ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
		RolePrefixList.add(pro); 
		ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
		RolePrefixList.add(pra);
		insert RolePrefixList;
				
		ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1), ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
		insert p1;      

		Account acc3 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name3');
		insert acc3;

		ASI_MFM_PO__c po = new ASI_MFM_PO__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(), ASI_MFM_Currency__c='SGD');
		insert po;

		ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_List_Item_Description__c='testDescription',  ASI_MFM_G_L_Date__c = Date.today()); 		
		insert poi;

		System.debug(Limits.getDMLRows());

		ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Send_Approval_Email__c=true, ASI_MFM_Status__c='Draft',ASI_MFM_Supplier_Name__c = acc3.id);
		insert py;
		
		Test.startTest(); 

		ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'), ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Currency__c = 'SGD', ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Payment__c=py.id,ASI_MFM_Invoice_Number__c = '123456');
		insert pyi;

		update pyi;
		delete pyi;
		
		update py;
		delete py;
				
		test.stopTest(); 
	}
	
	 static testMethod void test_ASI_MFM_PaymentLineItem_VN(){
		//Prefix
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;

        //User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        List<Account> accList = ASI_MFM_VN_TestClassHelper.createDFAccount();

        ASI_MFM_A_C_Code__c ac = ASI_MFM_VN_TestClassHelper.createACVNDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_VN_TestClassHelper.CreateDFSBrand();

        // Create Plan
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='VND', ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert plan;

        // Create PO
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=plan.id, ASI_MFM_PO_Raised_Date__c=date.today(), ASI_MFM_Currency__c='VND', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;

        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_VN_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);
        insert poLineList;

        // Create Payment
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_VN_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(), ASI_MFM_Currency__c='VND', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Submitted');
        insert py;

        Test.startTest(); // start the test

        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_VN_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '1234561',ASI_MFM_Payee__c=accList[0].id,ASI_MFM_Complete_POL__c = true);
        payLineList.add(pyi);
        
        insert payLineList;
		update payLineList;
		delete payLineList;
		
		delete py;
		
		//PO
		try {
			delete po;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		//Plan
		try {
			delete plan;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}

        test.stopTest();
    }
	
	static testMethod void test_ASI_MFM_PaymentLineItem_RM() {
		
		//Prefix
		List<ASI_MFM_Prefix__c> prefixToInsert = new List<ASI_MFM_Prefix__c>();
      
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c= getFiscalYear());
        prefixToInsert.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        prefixToInsert.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        prefixToInsert.add(pxa); 
        insert prefixToInsert; 
        
		//Role Prefix Relationshiop
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()]; 
        
		List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixToInsert = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixToInsert.add(pr);  
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixToInsert.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixToInsert.add(pra); 
        insert rolePrefixToInsert; 
                
		//Account
        List<Account> accountToInsert = new list<Account>();
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_RM_Supplier'), Name='Name2');           
        accountToInsert.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_RM_Customer'),Name='Name3');           
        accountToInsert.add(acc2);
        insert accountToInsert;    
		
		//A/C Code
		ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
		
		//Sub-brand
		ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');        
        insert sub;
		
		//Plan
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_RM_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');        
        insert p;

		//PO        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_RM_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_RM_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
        insert poi;
		
		Test.startTest(); 
        
		//Payment
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_RM_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc1.id);
        insert py;
		
		ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_RM_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       
        insert pyi; 
		update pyi;
		
		delete py;
		
		//PO
		try {
			delete po;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		//Plan
		try {
			delete p;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		test.stopTest();
	}

	static testMethod void test_ASI_MFM_PaymentLineItem_CAP(){
		ASI_MFM_Prefix__c planPrefix = new ASI_MFM_Prefix__c(
                              Name = 'AP18',
                              recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
                              ASI_MFM_Module__c = 'Plan',
                              ASI_MFM_Fiscal_year__c = 'FY1819');
                              
		ASI_MFM_Prefix__c poPrefix = new ASI_MFM_Prefix__c(
								  Name = 'PO18',
								  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
								  ASI_MFM_Module__c = 'PO',
								  ASI_MFM_Fiscal_year__c = 'FY1819');
		ASI_MFM_Prefix__c paymentPrefix= new ASI_MFM_Prefix__c(
								  Name = 'PA18',
								  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
								  ASI_MFM_Module__c = 'Payment',
								  ASI_MFM_Fiscal_year__c = 'FY1819');                              
		List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
		
		prefixList.add(planPrefix);
		prefixList.add(poPrefix);
		prefixList.add(paymentPrefix);
		insert prefixList;
    
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = :userinfo.getUserRoleId() ];
    
		List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
		
        ASI_MFM_Role_Prefix_Relationship__c rolePrefixPlan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = planPrefix.id, ASI_MFM_Role_Name__c = r.DeveloperName);
		ASI_MFM_Role_Prefix_Relationship__c rolePrefixPO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = poPrefix.id, ASI_MFM_Role_Name__c = r.DeveloperName);
		ASI_MFM_Role_Prefix_Relationship__c rolePrefixPayment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = paymentPrefix.id, ASI_MFM_Role_Name__c = r.DeveloperName);
        rolePrefixList.add(rolePrefixPlan);
		rolePrefixList.add(rolePrefixPO);
		rolePrefixList.add(rolePrefixPayment);
		insert rolePrefixList;
    
		ASI_MFM_Plan__c planData = new ASI_MFM_Plan__c (Name = 'AP Plan1', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), ASI_MFM_Prefix__c = planPrefix.id, ASI_MFM_Status__c = 'Final', ASI_MFM_Plan_Type__c = 'CAPEX');
        
        insert planData;
    
		ASI_MFM_BU__c capBU = new ASI_MFM_BU__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU'), Name = 'CAP BU');
		insert capBU;
			
		ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CAP_Plan_Line_Item'), ASI_MFM_List_Item_Description__c = 'test description', 
																		ASI_MFM_Total_Cost__c = 100000, ASI_MFM_Plan__c = planData.id, ASI_MFM_BU_Code__c = capBU.Id);
        insert planLine;    
    
		ASI_MFM_PO__c poData = new ASI_MFM_PO__c(Name = 'Test PO', ASI_MFM_PO_Type__c = 'CAPEX', ASI_MFM_Status__c = 'Final', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO'), ASI_MFM_Prefix__c = poPrefix.Id);
        insert poData;
    
		ASI_MFM_PO_Line_Item__c poLine1 = new ASI_MFM_PO_Line_Item__c(ASI_MFM_G_L_Date__c = date.today(), ASI_MFM_PO__c = poData.id, ASI_MFM_Amount__c = 100, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item'), 
																	ASI_MFM_BU_Code__c = capBU.Id);
		insert poLine1;

		Test.startTest();  
    
		ASI_MFM_Payment__c paymentData = new ASI_MFM_Payment__c(ASI_MFM_Payment_Type__c = 'CAPEX', ASI_MFM_Plan__c = planData.Id, ASI_MFM_Currency__c = 'HKD', ASI_MFM_Prefix__c= paymentPrefix.Id, ASI_MFM_Exchange_Rate__c = 1, 
																ASI_MFM_CAP_PO__c = poData.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment'), ASI_MFM_OCR__c = true, ASI_MFM_Status__c = 'Draft',
																ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = 'INVNUM123');
        insert paymentData;
    
		ASI_MFM_Payment_Line_Item__c paymentLine1 = new ASI_MFM_Payment_Line_Item__c( recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item'), ASI_MFM_Payment__c= paymentData.id, 
																				ASI_MFM_Payment_Amount__c=10,  ASI_MFM_PO_Line_Item__c=poLine1.id,  ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_PO__c = poData.Id, 
																				ASI_MFM_Invoice_Number__c = 'INVNUM123', ASI_MFM_BU__c = capBU.Id);
        insert paymentLine1;                                   
		update paymentLine1;
    
		delete paymentLine1;
		delete paymentData;

		try {
			delete poData;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
		
		Test.stopTest();   
	}

	static testMethod void test_ASI_MFM_PaymentLineItem_GF() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;

        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;     
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
										ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
										ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxa; 
        
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
        
        ASI_MFM_Route_Type__c mrt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
        insert mrt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=mrt.id, ASI_MFM_Prefix__c=pxa.id);
        insert rtm;
        
        Test.startTest();
               
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
													ASI_MFM_Currency__c='USD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Status__c='Draft');
        insert py;
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
		update pyi;
		delete pyi;
        
        delete py;
    }
	
	static testMethod void test_ASI_MFM_PaymentLineItem_JP() {
        //Prefix
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=ASI_MFM_JP_TestClassHelper.getFiscalYear());
        prefixList.add(px); 
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'JP';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
		//BU Code
		ASI_MFM_BU__c jpBU = new ASI_MFM_BU__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_JP_BU'), Name = 'JP BU');
		insert jpBU;
			
        //Plan
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        //Brand and Sub-Brand
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
        insert brand1;

        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        //AP AC Code
        ASI_MFM_AP_Code__c ap = ASI_MFM_JP_TestClassHelper.createJPAPCode();
        ASI_MFM_A_C_Code__c ac = ASI_MFM_JP_TestClassHelper.createJPACCode();
        
        //Account : Customer  Supplier
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        insert accToInsert;
        
        //Plan line 
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_BU_Code__c = jpBU.Id, ASI_MFM_Customer_Name__c = acc2.Id, 
                                                                     ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        //Create PO         
        Date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;
        
        //PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id,ASI_MFM_Currency__c='JPY', ASI_MFM_Status__c='Final',ASI_MFM_BU_Code__c = jpBU.Id,
                                             ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
        
        
        // PO Line
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100, ASI_MFM_BU_Code__c = jpBU.Id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                  ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
		
		Test.startTest();
        
        // PO Receipt 
        ASI_MFM_PO_Receipt__c POR =new ASI_MFM_PO_Receipt__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_JP_PO_Receipt'),ASI_MFM_PO__c=po.id);
        insert POR;
        
        System.debug(Limits.getDMLRows());
        
        //PO Receipt Item
        List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
        ASI_MFM_PO_Receipt_Item__c PORI = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,ASI_MFM_PO_Line_Item__c=poi.id,ASI_MFM_PO__c=po.id,ASI_MFM_Marketing_Verify__c=true);
        PORIList.add(PORI);
        insert PORIList;
        
		
		
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,
                                                       ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Submitted');  
        insert py;
        
        //Paymet line item
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=82, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id,ASI_MFM_Payment_Line_Item_Finance_Verify__c=true); 
        insert pyi;		
	}
	

    static testMethod void test_ASI_MFM_PaymentLineItem_KR() {  
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PO',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPO);
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPayment);
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPayment.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Payment);
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPO.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PO); 
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Plan); 
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;   
          
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Actual_Spending_Amount__c=0,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
                        
            
            //-------------------------------------------------- Customer----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            insert AccountList;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test Name',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
        
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            //-------------------------------------------------- PO ----------------------------------------------------------//
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 ASI_MFM_Warehouse__c = acc1.id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Base_Currency_Amount__c=100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;            
            
			Test.startTest();        
			
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Submitted',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc2.id,
                                                                       ASI_MFM_PO__c = po.id,
                                                                       ASI_MFM_Company_Code__c = '222',
                                                                       ASI_MFM_Send_Approval_Email__c=true,
                                                                       ASI_MFM_Is_Direct_Payment__c = true,
                                                                       ASI_MFM_Invoice_Number__c = 'OLD INVOICE NUMBER');  
            
            insert PaymentHeader;
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                         ASI_MFM_Beneficiary_Customer__c = customer1.id);
			insert PaymentLine;
			update PaymentLine;
			delete PaymentLine;
		}
	}
	
	static testMethod void test_ASI_MFM_PaymentLineItem_CAPSG() {
        ASI_MFM_Prefix__c prefixPayment = ASI_MFM_CAP_SG_TestClassHelper.createPrefixPayment();
        ASI_MFM_Prefix__c prefixPO = ASI_MFM_CAP_SG_TestClassHelper.createPrefixPO();
        ASI_MFM_AP_Code__c apCode = ASI_MFM_CAP_SG_TestClassHelper.createapCode();
        
		Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CAP_SG_Supplier'), Name='Name3');
        insert acc;
		
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c
								(
									ASI_MFM_Currency__c = 'SGD',
									ASI_MFM_Prefix__c= prefixPayment.id,
									recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_SG_Payment'),
									ASI_MFM_Status__c = 'Draft',
									ASI_MFM_Invoice_Date__c = date.today(),
									ASI_MFM_Invoice_Number__c = '123Tesyt',
									ASI_MFM_Supplier_Name__c = acc.Id,
                                    ASI_MFM_Exchange_Rate__c = 1 //11/28/2019 Howard@Introv Add Exchange Rate
								);
        insert py;
		
        ASI_MFM_PO__c po = new ASI_MFM_CAP_SG_TestClassHelper.createPO(prefixPO).po;
        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_CAP_SG_TestClassHelper.createPOLine(po).poLine;
        
        ASI_MFM_Payment_Line_Item__c pyi = ASI_MFM_CAP_TestClassHelper.createPaymentLines(py, poLine);
		
		delete pyi;
    }
	
	static testMethod void  test_ASI_MFM_PaymentLineItem_MY(){  
        
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        preList.add(px);        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        preList.add(pxa); 
        insert preList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRelationList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pro);   
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pra);
        insert PrefixRelationList;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        
        //Set PO         
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'),Name='Name2', ASI_LUX_Email_Business__c='test@test.com');      
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'),Name='Name3');        
        accList.add(acc2);
        insert accList;        
        
		ASI_MFM_BU__c myBU = new ASI_MFM_BU__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_MY_BU'), Name = 'MY BU');
		insert myBU;


        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_BU_Code__c = myBU.Id, ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_TR_Supplier_Email__c = 'test@test.com', ASI_MFM_Status__c = 'Draft');
        insert po;
            
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
		
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_BU_Code__c = myBU.Id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
		System.debug(Limits.getDMLRows());
		
        // Set Payment
        Test.startTest();
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MY_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_Invoice_Date__c=date.today(),ASI_MFM_Invoice_Number__c='Test',
                                                       ASI_MFM_BU__c = myBU.Id, ASI_MFM_Currency__c='MYR', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_ETL__c = false,ASI_MFM_Status__c='Draft');
        insert py;
        
        // Set Payment Line Items
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MY_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id);  
        insert pyi;
		update pyi;
		delete pyi;
		
		try {
			delete py;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());				
		}
	}
	
	 static testMethod void test_ASI_MFM_PaymentLineItem_PH() {   
         /*
		//Prefix
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
		//Account
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

         ASI_MFM_Route_Type__c mrt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
         insert mrt;
         
        // Create PO
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final', ASI_MFM_Route_Type__c = mrt.id);
        insert po;
                
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Submitted');  
        insert py;
        
        
        Test.startTest(); // start the test
        System.debug(Limits.getDMLRows());
        
        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id,ASI_MFM_Complete_POL__c = true); 
		insert pyi;
		delete pyi;
		*/
	}
}