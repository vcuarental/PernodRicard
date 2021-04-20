/*********************************************************************************
 * Name: ASI_MFM_CAP_Payment_Test
 * Description: Test Class for ASI_MFM_CAP_Payment_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-04-05       Wilken Lee              [WL 1.0] Increase coverage
*/
@isTest
public class ASI_MFM_CAP_Payment_Test {
	/*[WL 1.0] BEGIN*/
		static ASI_MFM_Payment__c paymentData;
		static ASI_MFM_Plan__c planData;
		static ASI_MFM_PO__c poData;
		static ASI_MFM_Prefix__c paymentPrefix;
		static ASI_MFM_PO_Line_Item__c poLine1;
		static ASI_MFM_PO_Line_Item__c poLine2;
		
		
		static void prepareTestDataPlanAndPO(){
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
		paymentPrefix= new ASI_MFM_Prefix__c(
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
		
		planData = new ASI_MFM_Plan__c (
													Name = 'AP Plan1',
													recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
													ASI_MFM_Prefix__c = planPrefix.id,
													ASI_MFM_Status__c = 'Final',
													ASI_MFM_Plan_Type__c = 'CAPEX');
        
        insert planData;
		
		ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c(
																			recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CAP_Plan_Line_Item'),
																			ASI_MFM_List_Item_Description__c = 'test description',
																			ASI_MFM_Total_Cost__c = 100000,
																			ASI_MFM_Plan__c = planData.id);
        insert planLine;		
		
		poData = new ASI_MFM_PO__c(
											Name = 'Test PO',
											ASI_MFM_PO_Type__c = 'CAPEX',
											ASI_MFM_Status__c = 'Final',
											recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO'),
											ASI_MFM_Prefix__c = poPrefix.Id);
        insert poData;
		
		poLine1 = new ASI_MFM_PO_Line_Item__c(
																	ASI_MFM_G_L_Date__c = date.today(),
																	ASI_MFM_PO__c = poData.id,
																	ASI_MFM_Amount__c = 100,
																	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item'));
		poLine2 = new ASI_MFM_PO_Line_Item__c(
																	ASI_MFM_G_L_Date__c = date.today(),
																	ASI_MFM_PO__c = poData.id,
																	ASI_MFM_Amount__c = 200,
																	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item'));
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();	
		poLineList.add(poLine1);
		poLineList.add(poLine2);
        insert poLineList;			
	}
	
	static void prepareTestDataPayment(){
		paymentData = new ASI_MFM_Payment__c(
													ASI_MFM_Payment_Type__c = 'CAPEX',
													ASI_MFM_Plan__c = planData.Id,
													ASI_MFM_Currency__c = 'HKD',
													ASI_MFM_Prefix__c= paymentPrefix.Id,
													ASI_MFM_Exchange_Rate__c = 1,
													ASI_MFM_CAP_PO__c = poData.Id,
													//ASI_MFM_Supplier_Name__c = ASI_MFM_CAP_TestClassHelper.createAccSupplier().id,
													recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment'),
													ASI_MFM_OCR__c = true,
													ASI_MFM_Status__c = 'Draft',
													ASI_MFM_Invoice_Date__c = date.today(),
													ASI_MFM_Invoice_Number__c = 'INVNUM123');
        insert paymentData;
		
		ASI_MFM_Payment_Line_Item__c paymentLine1 = new ASI_MFM_Payment_Line_Item__c(
																			recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item'),
																			ASI_MFM_Payment__c= paymentData.id, 
																			ASI_MFM_Payment_Amount__c=10, 
																			ASI_MFM_PO_Line_Item__c=poLine1.id, 
																			ASI_MFM_Invoice_Date__c = date.today(), 
																			ASI_MFM_PO__c = poData.Id,
																			ASI_MFM_Invoice_Number__c = 'INVNUM123');        
		ASI_MFM_Payment_Line_Item__c paymentLine2 = new ASI_MFM_Payment_Line_Item__c(
																			recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item'),
																			ASI_MFM_Payment__c= paymentData.id, 
																			ASI_MFM_Payment_Amount__c=20, 
																			ASI_MFM_PO_Line_Item__c=poLine2.id, 
																			ASI_MFM_Invoice_Date__c = date.today(), 
																			ASI_MFM_PO__c = poData.Id,
																			ASI_MFM_Invoice_Number__c = 'INVNUM123');  																			
        List<ASI_MFM_Payment_Line_Item__c> paymentLineList = new List<ASI_MFM_Payment_Line_Item__c>();
		paymentLineList.add(paymentLine1);
		paymentLineList.add(paymentLine2);
		insert paymentLineList;
	}
	
	static testMethod void testASI_MFM_CAP_Payment_TriggerClass_routineBeforerDelete(){
		prepareTestDataPlanAndPO();
		
		Test.startTest();  
		
		prepareTestDataPayment();
		
		delete paymentData;
		
		Test.stopTest();   
	}
	
	static testMethod void testASI_MFM_CAP_Payment_TriggerClass_clonePaymentWithRelatedRecords(){
		prepareTestDataPlanAndPO();
		
		Test.startTest();  
		
		prepareTestDataPayment();
		
		ASI_MFM_Payment__c testPaymentCloned = paymentData.clone();
		
		testPaymentCloned.ASI_MFM_Invoice_Number__c = 'INVNUMCLONE';
		
		List<ASI_MFM_Payment__c> paymentList = new List<ASI_MFM_Payment__c>();
		
		paymentList.add(testPaymentCloned);
		
        ASI_MFM_CAP_Payment_TriggerClass.clonePaymentWithRelatedRecords(paymentList);
		
		Test.stopTest();   
	}
	/*[WL 1.0] END*/
    
    // DC - 08/02/2016 - Added method to test cloning functionality.
    static testMethod void testPaymentTrigger1()
    {
        ASI_MFM_CAP_TestClassHelper.createRoutePaymentType();

        ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();//capex
        
        plan.ASI_MFM_Status__c = 'Final';
        update plan;
        
        System.debug('------ Limits.getQueries() -2 ------ : ' + Limits.getQueries());

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'OPEX',
			ASI_MFM_Status__c = 'Final',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO'),
            ASI_MFM_Prefix__c = ASI_MFM_CAP_TestClassHelper.createPrefixPO().id,
            ASI_MFM_Plan__c = plan.id
        );
        insert po;

        // ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPO();

        System.debug('------ Limits.getQueries() -1 ------ : ' + Limits.getQueries());
        
        /*ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
        (
            Name = 'Test Plan',
            ASI_MFM_Status__c = 'Final',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            ASI_MFM_Actual_Depreciation_Start_Date__c = date.today().adddays(1),
            ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
           // ASI_MFM_Expenditure_Type__c = 'Computer Hardware',
            ASI_MFM_Prefix__c = ASI_MFM_CAP_TestClassHelper.createPrefixPlan().id,
            ASI_MFM_Plan_Type__c = 'OPEX'
        );
        insert plan;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c
        (
            Name = 'Test PO',
            ASI_MFM_PO_Type__c = 'OPEX',
            ASI_MFM_PO_Raised_Date__c = date.today(),
            ASI_MFM_PO_Start_Date__c = date.today(),
            ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO'),
            ASI_MFM_Prefix__c = ASI_MFM_CAP_TestClassHelper.createPrefixPO().id,
            ASI_MFM_Plan__c = plan.id
        );
        insert po;*/
        
        System.Test.StartTest();
        
        // ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
        (
            ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.id,
            ASI_MFM_Amount__c = 100,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item')
        );
        insert poLine;

        System.debug('------ Limits.getQueries() 0 ------ : ' + Limits.getQueries());
        
        // ASI_MFM_Payment__c py = ASI_MFM_CAP_TestClassHelper.createPayment(po);
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c
        (
            ASI_MFM_Payment_Type__c = 'OPEX',
            ASI_MFM_Plan__c = po.ASI_MFM_Plan__c,
			ASI_MFM_CAP_PO__c = po.Id,
            ASI_MFM_Currency__c = 'HKD',
            ASI_MFM_Prefix__c= ASI_MFM_CAP_TestClassHelper.createPrefixPayment().id,
            ASI_MFM_Supplier_Name__c = ASI_MFM_CAP_TestClassHelper.createAccSupplier().id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment'),
            ASI_MFM_Is_Direct_Payment__c = false,
            ASI_MFM_Status__c = 'Draft',
            ASI_MFM_Invoice_Date__c = date.today(),
            ASI_MFM_Invoice_Number__c = '123Tesyt'
        );
        insert py;
        /*ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Id = po.ASI_MFM_Plan__c,ASI_MFM_Plan_Type__c = 'CAPEX');
        update plan;*/

        System.debug('------ Limits.getQueries() 1 ------ : ' + Limits.getQueries());

        ASI_MFM_Payment_Line_Item__c testPaymentLine = new ASI_MFM_Payment_Line_Item__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_HK_Payment_Line_Item'),
            ASI_MFM_Payment__c=py.id, 
            ASI_MFM_Payment_Amount__c=10, 
            ASI_MFM_PO_Line_Item__c=poLine.id, 
            ASI_MFM_Invoice_Date__c = date.today(), 
            ASI_MFM_Invoice_Number__c = '123456',
            ASI_MFM_Paid_Amount_in_PO_Currency__c = 10,
            ASI_MFM_Tax_Amount__c = 2
        );
        insert testPaymentLine;

        System.debug('------ Limits.getQueries() 2 ------ : ' + Limits.getQueries());        

        Test.StopTest();
    }
    
    
    // DC - 08/02/2016 - Changed the data created in this method to match with that required in trigger.
    static testMethod void testPaymentTrigger2(){
        ASI_MFM_CAP_TestClassHelper.createRoutePaymentType();

        ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPO();
    
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        
        ASI_MFM_Payment__c py = ASI_MFM_CAP_TestClassHelper.createPayment(po);
        
        ASI_MFM_Route_Type__c lstRouteTypes = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='Payment');
        insert lstRouteTypes;
        
        List<ASI_MFM_Brand_Route_Type_Map__c> lstTestRouteMap = new List<ASI_MFM_Brand_Route_Type_Map__c>();
        
        List<ASI_MFM_Route_Rule_Detail__c> routeRuleDetailList = new List<ASI_MFM_Route_Rule_Detail__c>();
        
        
        
        for(Integer i = 0; i < 10; i++) {
            lstTestRouteMap.add(new ASI_MFM_Brand_Route_Type_Map__c(
                ASI_MFM_Prefix__c = py.ASI_MFM_Prefix__c,
                ASI_MFM_Route_Type__c = lstRouteTypes.Id,
                ASI_MFM_Active__c = true,
                ASI_MFM_Responsible_By__c = UserInfo.getUserId()
            ));
            
            routeRuleDetailList.add(new ASI_MFM_Route_Rule_Detail__c(
                                        ASI_MFM_Approver__c = UserInfo.getUserId(),
                                        ASI_MFM_Route_Type__c = lstRouteTypes.id,
                                        ASI_MFM_Minimum_Amount__c = 0
                                    ));
        }
        
        insert lstTestRouteMap;
        insert routeRuleDetailList; 
        
        ASI_MFM_CAP_Payment_TriggerClass.populateApprover(py,'tw', lstRouteTypes.Id, routeRuleDetailList);
        
        ASI_MFM_AP_Code__c testApCode = ASI_MFM_CAP_TestClassHelper.createOPEXAPCode();
        ASI_MFM_A_C_Code__c testAcCode = ASI_MFM_CAP_TestClassHelper.createACCode();
        ASI_MFM_BU__c testBuCode = ASI_MFM_CAP_TestClassHelper.createOPEXBUCode();

        System.Test.StartTest();
    System.debug('------ Start Test: Limits.getQueries() ------ : ' + Limits.getQueries());
    
        ASI_MFM_Payment_Line_Item__c testPaymentLine = new ASI_MFM_Payment_Line_Item__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item'),
            ASI_MFM_Payment__c=py.id, 
            ASI_MFM_Payment_Amount__c=10, 
            ASI_MFM_PO_Line_Item__c=poLine.id, 
            ASI_MFM_Invoice_Date__c = date.today(), 
            ASI_MFM_Invoice_Number__c = '123456',
            ASI_MFM_AP_Code__c = testApCode.id,
            ASI_MFM_A_C_Code__c = testAcCode.id,
            ASI_MFM_BU__c = testBuCode.id
        );
        insert testPaymentLine;

        ASI_MFM_Plan__c plan = [SELECT ID, Name, ASI_MFM_Plan_Type__c FROM ASI_MFM_Plan__c WHERE ID = : po.ASI_MFM_Plan__c].get(0);
        plan.ASI_MFM_Plan_Type__c = 'OPEX';
        update plan;

        List<ASI_MFM_Default_Value__c> lstMfmDefaults = new List<ASI_MFM_Default_Value__c> {
            new ASI_MFM_Default_Value__c(
                Name = 'CAP_CAPEX_BU_Code__c',
                ASI_MFM_Value__c = testBuCode.Id,
                Country__c = 'HK'
            ),
            new ASI_MFM_Default_Value__c(
                Name = 'CAP_OPEX_BU_Code__c',
                ASI_MFM_Value__c = testBuCode.Id,
                Country__c = 'HK'
            )
        };

        insert lstMfmDefaults;

        py.ASI_MFM_Plan__c = po.ASI_MFM_Plan__c;
        py.ASI_MFM_Status__c = 'Submitted';
        py.ASI_MFM_Payment_Type__c = 'OPEX';
        try {
      update py;
        } 
    catch(DmlException exceptionInstance) {
            System.assert(true);
        }

        po.ASI_MFM_PO_Type__c = 'OPEX';
        update po;
        System.debug('------ Updated PO: Limits.getQueries() ------ : ' + Limits.getQueries());

        py.ASI_MFM_Approved__c = true;
        py.ASI_MFM_Invoice_Number__c = 'testing-123456';
        py.ASI_MFM_Invoice_Date__c = Date.today();

        update py;

        Test.StopTest();

        delete py;        
    }

    static testMethod void testDirectPayment()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='ASI PRA Standard User'];
        UserRole r = [select id from UserRole where name = 'ESN'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_praTest@pernod-ricard.com' ,ASI_MFM_Country__c = 'HK', UserRoleID = r.id, ASI_MFM_Bypass_Callouts__c = true); 
        
        System.runAs(u) {
        
        ASI_MFM_CAP_TestClassHelper.createMFMDefaultValues();
        
        Account acc1 = ASI_MFM_CAP_TestClassHelper.createAccSupplier();
        
        ASI_MFM_PO__c PO = ASI_MFM_CAP_TestClassHelper.createPO();
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        
        ASI_MFM_Payment__c py = ASI_MFM_CAP_TestClassHelper.createPayment(po);

        // DC - 08/02/2016 - Created custom setting data.
        ASI_MFM_Country_Recordtype_Mapping__c recordMap = new ASI_MFM_Country_Recordtype_Mapping__c(
            Name = 'HK',
            Currency__c = 'HKD',
            ASI_MFM_Payment_LI_RT__c = 'CAP TW Payment Line Item',
            ASI_MFM_Payment_RT__c = 'CAP TW Payment',
            ASI_MFM_Plan_LI_RT__c = 'CAP TW Plan Line Item',
            ASI_MFM_Plan_RT__c = 'CAP TW Plan',
            PO_LI_RT__c = 'CAP TW PO Line Item',
            ASI_MFM_PO_RT__c = 'CAP TW PO',
            User_Country__c = 'HK'
        );
        insert recordMap;
        
        Test.StartTest();
        Test.setCurrentPage(Page.ASI_MFM_CAP_EditSmallAmountPayment_Page);
        
        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl controller = new ASI_MFM_CAP_EditSmallAmountPayment_Ctrl(); 
        controller.init();
        List<SelectOption> selectOptions = controller.getTypeItems();
        String[] testString = controller.getselectedtype();
        controller.setselectedType(testString);
        
        controller.LSAPHeader[0].type = 'CAPEX';
        controller.LSAPHeader[0].isTnE = true;
        controller.LSAPHeader[0].po.ASI_MFM_Plan__c = po.ASI_MFM_Plan__c;
        controller.LSAPHeader[0].po.ASI_MFM_Prefix__c = PO.ASI_MFM_Prefix__c;
        controller.LSAPHeader[0].po.ASI_MFM_Supplier_Name__c = acc1.id ;
        controller.LSAPHeader[0].po.ASI_MFM_Currency__c = 'HKD';
        controller.LSAPHeader[0].po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO');
        controller.LSAPHeader[0].po.ASI_MFM_Status__c = 'Draft';
        controller.LSAPHeader[0].po.ASI_MFM_PO_Type__c = 'Normal';
        controller.LSAPHeader[0].po.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        controller.LSAPHeader[0].po.ASI_MFM_PO_Start_Date__c = Date.today();
        controller.LSAPHeader[0].po.ASI_MFM_PO_End_Date__c = Date.today().addMonths(1);
        
        controller.payment_prefixes.id = py.ASI_MFM_Prefix__c;
        controller.LSAPHeader[0].pay.ASI_MFM_Plan__c = po.ASI_MFM_Plan__c;
        controller.LSAPHeader[0].pay.ASI_MFM_Prefix__c = py.ASI_MFM_Prefix__c;
        controller.LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c = acc1.id  ;
        controller.LSAPHeader[0].pay.ASI_MFM_Currency__c = 'HKD';
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c = '12345';
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c = Date.today();
        controller.LSAPHeader[0].pay.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment');
        controller.LSAPHeader[0].pay.ASI_MFM_Status__c = 'Draft';
        controller.LSAPHeader[0].pay.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        
        controller.AddNew_SAPL();
        
        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.SAPLineObj sapl_Clone = controller.SAPL_Item_Map.get(0);
        sapl_Clone.pl = new ASI_MFM_Payment_Line_Item__c();
        sapl_Clone.pl.ASI_MFM_Payment_List_Item_Description__c = 'abcd';
        sapl_Clone.pl.ASI_MFM_Payment_Date__c = Date.today() ;
        sapl_Clone.pl.ASI_MFM_Payment_Amount__c = 50;
        
        sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
        sapl_Clone.pol.ASI_MFM_Customer_Name__c = acc1.id;

        
        controller.rowidSAPL = 0;
        controller.Clone_SAPL();
        controller.rowidSAPL = 1;
        controller.RemoveRow_SAPL();
        String[] testPlan = ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.findSObjects('ASI_MFM_Plan__c', '');
        String[] testAccount = ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.findCustSObjects('account', 'ASI_MFM_HK_Supplier');
        controller.SaveRecord();
        }
        
        Test.StopTest();
   }
   
    static testMethod void testDirectPayment2()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='ASI PRA Standard User'];
        UserRole r = [select id from UserRole where name = 'ESN'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_praTest@pernod-ricard.com', ASI_MFM_Country__c = 'HK', UserRoleID = r.id, ASI_MFM_Bypass_Callouts__c = true); 
        System.runAs(u) {

            // DC - 08/02/2016 - Created custom setting data.
            ASI_MFM_Country_Recordtype_Mapping__c recordMap = new ASI_MFM_Country_Recordtype_Mapping__c(
                Name = 'HK',
                Currency__c = 'HKD',
                ASI_MFM_Payment_LI_RT__c = 'CAP TW Payment Line Item',
                ASI_MFM_Payment_RT__c = 'CAP TW Payment',
                ASI_MFM_Plan_LI_RT__c = 'CAP TW Plan Line Item',
                ASI_MFM_Plan_RT__c = 'CAP TW Plan',
                PO_LI_RT__c = 'CAP TW PO Line Item',
                ASI_MFM_PO_RT__c = 'CAP TW PO',
                User_Country__c = 'HK'
            );
            insert recordMap;

            Account acc1 = ASI_MFM_CAP_TestClassHelper.createAccSupplier();
            
            ASI_MFM_PO__c PO = ASI_MFM_CAP_TestClassHelper.createPO();
            ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
            
            ASI_MFM_Payment__c py = ASI_MFM_CAP_TestClassHelper.createPayment(po);
                    
            Test.StartTest();
            Test.setCurrentPage(Page.ASI_MFM_CAP_EditSmallAmountPayment_Page);
            
            ASI_MFM_CAP_EditSmallAmountPayment_Ctrl controller = new ASI_MFM_CAP_EditSmallAmountPayment_Ctrl(); 
            controller.init();
            List<SelectOption> selectOptions = controller.getTypeItems();
            String[] testString = controller.getselectedtype();
            controller.setselectedType(testString);
            
            controller.LSAPHeader[0].type = 'CAPEX';
            controller.LSAPHeader[0].isTnE = false;
            controller.LSAPHeader[0].po.ASI_MFM_Plan__c = po.ASI_MFM_Plan__c;
            controller.LSAPHeader[0].po.ASI_MFM_Prefix__c = PO.ASI_MFM_Prefix__c;
            controller.LSAPHeader[0].po.ASI_MFM_Supplier_Name__c = acc1.id ;
            controller.LSAPHeader[0].po.ASI_MFM_Currency__c = 'HKD';
            controller.LSAPHeader[0].po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO');
            controller.LSAPHeader[0].po.ASI_MFM_Status__c = 'Draft';
            controller.LSAPHeader[0].po.ASI_MFM_PO_Type__c = 'Normal';
            controller.LSAPHeader[0].po.ASI_MFM_Remarks__c = 'Auto created from direct payment';
            controller.LSAPHeader[0].po.ASI_MFM_PO_Start_Date__c = Date.today();
            controller.LSAPHeader[0].po.ASI_MFM_PO_End_Date__c = Date.today().addMonths(1);
            
            controller.payment_prefixes.id = py.ASI_MFM_Prefix__c;
            controller.LSAPHeader[0].pay.ASI_MFM_Plan__c = po.ASI_MFM_Plan__c;
            controller.LSAPHeader[0].pay.ASI_MFM_Prefix__c = py.ASI_MFM_Prefix__c;
            controller.LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c = acc1.id  ;
            controller.LSAPHeader[0].pay.ASI_MFM_Currency__c = 'HKD';
            controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c = '12345';
            controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c = Date.today();
            controller.LSAPHeader[0].pay.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment');
            controller.LSAPHeader[0].pay.ASI_MFM_Status__c = 'Draft';
            controller.LSAPHeader[0].pay.ASI_MFM_Remarks__c = 'Auto created from direct payment';
            
            
            controller.AddNew_SAPL();
            
            ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.SAPLineObj sapl_Clone = controller.SAPL_Item_Map.get(0);
            sapl_Clone.pl = new ASI_MFM_Payment_Line_Item__c();
            sapl_Clone.pl.ASI_MFM_Payment_List_Item_Description__c = 'abcd';
            sapl_Clone.pl.ASI_MFM_Payment_Date__c = Date.today() ;
            sapl_Clone.pl.ASI_MFM_Payment_Amount__c = 50;
            
            sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
            sapl_Clone.pol.ASI_MFM_Customer_Name__c = acc1.id;
             
            controller.rowidSAPL = 0;
            controller.Clone_SAPL();
            controller.rowidSAPL = 1;
            controller.RemoveRow_SAPL();
            String[] testPlan = ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.findSObjects('ASI_MFM_Plan__c', '');
            String[] testAccount = ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.findCustSObjects('account', 'ASI_MFM_HK_Supplier');
            controller.SaveRecord();
        
        }
        
        Test.StopTest();
   }
   
// TEST INPUTPAYMENTITEMS PAGE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    static testMethod void test_main() {                   
        ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPO();
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        
        System.debug('------ Limits.getQueries() -1 ------ : ' + Limits.getQueries());
        Test.startTest();  
        
        ASI_MFM_Payment__c py = ASI_MFM_CAP_TestClassHelper.createPayment(po);
        
        py.ASI_MFM_Is_Direct_Payment__c = true;
        update py;
        delete py;
        
        System.debug('------ Limits.getQueries() -2 ------ : ' + Limits.getQueries());
        
        
        System.debug('------ Limits.getQueries() -4 ------ : ' + Limits.getQueries());
        /*WL 20190403 Review Payment Manage All page test class*/
        /*
        ASI_MFM_Payment_Line_Item__c pyi = ASI_MFM_CAP_TestClassHelper.createPaymentLines(py, poLine);

        
        System.debug('------ Limits.getQueries() -5 ------ : ' + Limits.getQueries());
        
        
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        pyi_list.add(pyi);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
         
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_CAP_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_CAP_InputPaymentItemsController testCon = new ASI_MFM_CAP_InputPaymentItemsController(stdSetController);
        
        System.debug('------ Limits.getQueries() -6 ------ : ' + Limits.getQueries());
        
        
        testCon.isFinal = false;
        testCon.isSubmitted = false;
        testCon.isOCRORDPayment = false;
        // DC - 08/02/2016 - Changed controller to "ASI_MFM_CAP_MassCreateUpdateController" from "ASI_MFM_MassCreateUpdateController"
        ASI_MFM_CAP_MassCreateUpdateController mcauCon = new ASI_MFM_CAP_MassCreateUpdateController();
        ASI_MFM_SFObjSelectTableController sobjstCon = new ASI_MFM_SFObjSelectTableController();

        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Payment_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_PO_Line_Item__c&read=A, ASI_MFM_PO_Line_Currency__c&read=A, ASI_MFM_PO_Line_Remaining_Amount__c&read=A, ASI_MFM_PO_Line_Description__c&read=A, ASI_MFM_Payee__c&req=F, ASI_MFM_Payment_Amount__c&req=F, ASI_MFM_Invoice_Number__c&req=F, ASI_MFM_Invoice_Date__c&req=F, ASI_MFM_Payment_List_Item_Description__c&req=F, ASI_MFM_AP_Remark__c&req=F';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Payment__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Payment__c = \'' + py.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Payment Line Items';
        mcauCon.successLink = '/' + py.Id;
        mcauCon.cancelLink = '/' + py.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.PageController = testCon.thisController;
        mcauCon.lookupToPicklist = 'ASI_MFM_A_C_Code__c';
        
        sobjstCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        sobjstCon.displayFieldsStr = 'Name, ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Currency__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_Remaining_Balance__c';
//      sobjstCon.defWhereStatmStr = testCon.baseWhereStatm;
        sobjstCon.defWhereStatmStr = null;
        sobjstCon.orderByStr = 'ASI_MFM_PO__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Payment_Line_Item');
       
       integer recordIndex= 0;
        for (integer i = 0; i< mcauCon.theRecordTypeElementList.size(); i++)
        {
            system.debug('mcauCon.theRecordTypeElementList IS ' +  mcauCon.theRecordTypeElementList.get(i));
            if (mcauCon.theRecordTypeElementList.get(i).myRecordList.size() > 0)
            {
                system.debug('ID IS ' +  mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0).id);
                system.debug(' mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0) IS ' +  mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0));

                recordIndex = i;
                break;

            }
        }
            
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);     
        
        mcauCon.enableForEdit();
        mcauCon.cloneRow();        
        mcauCon.addNewRow();
        
        system.debug('test_main After Add New Row');
        
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Payment_Line_Item');
        List<ASI_MFM_CAP_MassCreateUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();*/

        Test.stopTest();
        //delete pyi;
    }
    
    static testMethod void test_main2() {
        ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPO();
        
        System.debug('------ Limits.getQueries() -1 ------ : ' + Limits.getQueries());
        
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        
        System.debug('------ Limits.getQueries() -2 ------ : ' + Limits.getQueries());
                
        ASI_MFM_Payment__c py = ASI_MFM_CAP_TestClassHelper.createPayment(po);
        
        Test.startTest();   
        
        System.debug('------ Limits.getQueries() -3 ------ : ' + Limits.getQueries());
    
        ASI_MFM_Payment_Line_Item__c pyi = ASI_MFM_CAP_TestClassHelper.createPaymentLines(py, poLine);

        System.debug('------ Limits.getQueries() -4 ------ : ' + Limits.getQueries());
        
        List<ASI_MFM_Payment__c> paymentList = new List<ASI_MFM_Payment__c>();
        paymentList.add(py);
        
        ASI_MFM_CAP_Payment_TriggerClass.clonePaymentWithRelatedRecords(paymentList);
        
        delete py;
        /*WL 20190403 Review Test class SOQL
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        pyi_list.add(pyi);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        System.debug('------ Limits.getQueries() -5 ------ : ' + Limits.getQueries());
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_CAP_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_CAP_InputPaymentItemsController testCon = new ASI_MFM_CAP_InputPaymentItemsController(stdSetController);
        testCon.isFinal = false;
        testCon.isSubmitted = false;
        testCon.isOCRORDPayment = false;
        // DC - 08/02/2016 - Changed controller to "ASI_MFM_CAP_MassCreateUpdateController" from "ASI_MFM_MassCreateUpdateController"
        ASI_MFM_CAP_MassCreateUpdateController mcauCon = new ASI_MFM_CAP_MassCreateUpdateController();
        ASI_MFM_SFObjSelectTableController sobjstCon = new ASI_MFM_SFObjSelectTableController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Payment_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_PO_Line_Item__c&req=T&read=O, ASI_MFM_Payee__c&req=F&width=150px, ASI_MFM_Payment_Amount__c&req=F, ASI_MFM_Invoice_Number__c&req=F, ASI_MFM_Invoice_Date__c&req=F';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Payment__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Payment__c = \'' + py.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Payment Line Items';
        mcauCon.successLink = '/' + py.Id;
        mcauCon.cancelLink = '/' + py.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.PageController = testCon.thisController;
        mcauCon.lookupToPicklist='';
        
        sobjstCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        sobjstCon.displayFieldsStr = 'Name, ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Currency__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_Remaining_Balance__c';
//      sobjstCon.defWhereStatmStr = testCon.baseWhereStatm;
        sobjstCon.defWhereStatmStr = null;
        sobjstCon.orderByStr = 'ASI_MFM_PO__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Payment_Line_Item');
       
       integer recordIndex= 0;
        for (integer i = 0; i< mcauCon.theRecordTypeElementList.size(); i++)
        {
            system.debug('mcauCon.theRecordTypeElementList IS ' +  mcauCon.theRecordTypeElementList.get(i));
            if (mcauCon.theRecordTypeElementList.get(i).myRecordList.size() > 0)
            {
                system.debug('ID IS ' +  mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0).id);
                system.debug(' mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0) IS ' +  mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0));

                recordIndex = i;
                break;

            }
        }
        
            
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);       
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Payment_Line_Item');
        List<ASI_MFM_CAP_MassCreateUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        /*
        // Change page number
        sobjstCon.nextPage();
        sobjstCon.lastPage();
        sobjstCon.prevPage();
        sobjstCon.firstPage();
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Remove old product
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Payment_Line_Item');
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        */
        
        Test.stopTest();
    }
    
    static testMethod void testPaymentAssignApprover()
    {
        ASI_MFM_CAP_TestClassHelper.createRoutePaymentType();
        ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPO();
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        Test.startTest();   
        ASI_MFM_Payment__c py = ASI_MFM_CAP_TestClassHelper.createPayment(po);
        List<ASI_MFM_Payment__c> pyList = new List<ASI_MFM_Payment__c>();
        pyList.add(py);
        

        ASI_MFM_Payment_Line_Item__c pyi = ASI_MFM_CAP_TestClassHelper.createPaymentLines(py, poLine);
        ApexPages.StandardController stdController = new ApexPages.StandardController(py);
        

        PageReference testPage = Page.ASI_MFM_CAP_InputPaymentItemsPage;
        PageReference testPage2 = Page.ASI_MFM_CAP_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);



        Test.setCurrentPage(testPage);
        
        ASI_MFM_CAP_PaymentAssignApprover controller = new ASI_MFM_CAP_PaymentAssignApprover(stdController); 
        controller.updateApprover();
        Test.setCurrentPage(testPage2);
        ASI_MFM_CAP_PaymentAssignApprover controller2 = new ASI_MFM_CAP_PaymentAssignApprover();
        controller2.updateApprover();
    }
}