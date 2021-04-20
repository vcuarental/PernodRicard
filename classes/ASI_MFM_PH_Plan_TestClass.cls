@isTest
/*  Test Method: 

ASI_MFM_Plan_TriggerClass
ASI_MFM_PO_TriggerClass
ASI_MFM_POLineItem_TriggerClass

ASI_MFM_SelectPaymentPrefixController
ASI_MFM_SelectPOPrefixController

***************************
*       ASI_MFM_PH_InputPlanItemsController
        ASI_MFM_PH_PlanNewPORedirectCtrl
        ASI_MFM_PH_InputPOItemsController
        ASI_MFM_PH_InputPaymentItemsController
        ASI_MFM_PH_Payment_PDF_PageController
        ASI_MFM_PH_PORelatedPaymentsController
        ASI_MFM_PH_FV_Controller
        ASI_MFM_Payment_TriggerClass
        ASI_MFM_PH_GLDate_SettingController
        ASI_MFM_PH_SupplierEditSupplierNoCtrl        
        ASI_MFM_PH_PO_PDF_PageController
        ASI_MFM_PH_BAverifyController
        ASI_MFM_SetPOStatusController
        ASI_MFM_PH_Payment_TriggerClass
        ASI_MFM_SetPaymentStatusController


ASI_MFM_RerunETLController
* History
* -----------------------------------------------------------------------------
* 2015-10-30    Elufasys      Created
* 2019-08-01    Wilken        [WL 1.0] Increase coverage for ASI_MFM_PH_Plan_TriggerClass
*
*/


private class ASI_MFM_PH_Plan_TestClass {
      static testMethod void testPlanDPPrefixController2()
    { 
      //Test ASI_MFM_SelectPlanPrefixController
        ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DP_Plan'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = ASI_MFM_PH_TestClassHelper.createPHDPMultiPrefixPlan().id);
        insert plan1;
        Test.startTest();
        
        PageReference planPrefixPage = Page.ASI_MFM_SelectPlanPrefixPage;

        Test.setCurrentPage(planPrefixPage);
        // 
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(plan1.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', plan1.id);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);        
        ASI_MFM_SelectPlanPrefixController SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
        
        SelectPlanPrefixController.getPrefixes();
        SelectPlanPrefixController.proceed();
       
        // 
        Test.stopTest();
    }
    
      static testMethod void testPlanDFPrefixController2()
    { 
      //Test ASI_MFM_SelectPlanPrefixController
      
        /*[WL 1.0] BEGIN*/
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = ASI_MFM_PH_TestClassHelper.getFiscalYear());
        insert px;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
     
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='Plan',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        ASI_MFM_Route_Rule_Detail__c rrd10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=10);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        rrdlist.add(rrd10);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=px.id );
        insert rtm;
        /*[WL 1.0] END*/
        
        Test.startTest();
        ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = px.id);
        insert plan1;        
        
        PageReference planPrefixPage = Page.ASI_MFM_SelectPlanPrefixPage;

        Test.setCurrentPage(planPrefixPage);
        // 
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(plan1.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', plan1.id);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);        
        ASI_MFM_SelectPlanPrefixController SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
        
        SelectPlanPrefixController.getPrefixes();
        SelectPlanPrefixController.proceed();
       
       /*[WL 1.0] BEGIN*/
        ASI_MFM_Plan__c plan2 = new ASI_MFM_Plan__c( Name = 'Test Clone Plan 2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = px.Id);
        plan2.ASI_MFM_Cloned_Plan_ID__c = plan1.Id;
        insert plan2;
        
        ASI_MFM_Plan__c plan3 = new ASI_MFM_Plan__c(Name = 'Test Clone Plan 3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DP_Plan'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = px.Id);
        insert plan3;
        delete plan3;
        /*[WL 1.0] END*/
        
        Test.stopTest();
    }

    static testMethod void testPHPlanController()
    {
        //Test ASI_MFM_SelectPlanPrefixController
        ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = ASI_MFM_PH_TestClassHelper.createPHDFMultiPrefixPlan().id);
        insert plan1;
        Test.startTest();

        PageReference planPrefixPage = Page.ASI_MFM_SelectPlanPrefixPage;

        Test.setCurrentPage(planPrefixPage);
        //
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(plan1.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', plan1.id);

        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);
        ASI_MFM_SelectPlanPrefixController SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);

        SelectPlanPrefixController.getPrefixes();
        SelectPlanPrefixController.proceed();

        //
        Test.stopTest();
    }


     static testMethod void testPlanDPPrefixController()
    { 
       //Test ASI_MFM_SelectPlanPrefixController
        ASI_MFM_Plan__c plan1 = ASI_MFM_PH_TestClassHelper.createPHDPPlan();
        
        Test.startTest();
        
        PageReference planPrefixPage = Page.ASI_MFM_SelectPlanPrefixPage;

        Test.setCurrentPage(planPrefixPage);
        // 
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(plan1.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', plan1.id);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);        
        ASI_MFM_SelectPlanPrefixController SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
        
        SelectPlanPrefixController.getPrefixes();
        SelectPlanPrefixController.proceed();
       
        // 
        Test.stopTest();
    }

  
     static testMethod void testPlanDFPrefixController()
    { 
       //Test ASI_MFM_SelectPlanPrefixController
        ASI_MFM_Plan__c plan1 = ASI_MFM_PH_TestClassHelper.createPHDFPlan();
        
        Test.startTest();
        
        PageReference planPrefixPage = Page.ASI_MFM_SelectPlanPrefixPage;

        Test.setCurrentPage(planPrefixPage);
        // 
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(plan1.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', plan1.id);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);        
        ASI_MFM_SelectPlanPrefixController SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
        
        SelectPlanPrefixController.getPrefixes();
        SelectPlanPrefixController.proceed();
       
        // 
        Test.stopTest();
    }

    static testMethod void InputPlanItems_Test() {
        //Test class:  ASI_MFM_Plan_TriggerClass      ASI_MFM_PH_InputPlanItemsController
        ASI_MFM_Plan__c plan = ASI_MFM_PH_TestClassHelper.createPHDPPlan();
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_PH_TestClassHelper.createPHPlanLines1(plan);
        List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
        planLineSet.add(planLine);
        
        ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
        
        PageReference inputPlanItemsPage = Page.ASI_MFM_PH_InputPlanItemsPage;
        Map<String, String> pageParams = inputPlanItemsPage.getParameters();
        Test.startTest();
        
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(inputPlanItemsPage);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
        
        ASI_MFM_PH_InputPlanItemsController PlanManageAllController = new ASI_MFM_PH_InputPlanItemsController(stdController);
        //Test function
        PlanManageAllController.init();
        System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)planLine.id);
        PlanManageAllController.cloneLine();
        PlanManageAllController.SaveItems();
        PlanManageAllController.addLineItem();
        System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)planLine.id);
        PlanManageAllController.removeLine();
        
        //Test RemoteAction
        List<Account> remo= ASI_MFM_PH_InputPlanItemsController.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_PH_DF_Customer');
       
        test.stopTest(); 
       
    }
    
    
     static testMethod void InputPlanItems_Test_Fail_Case() {
        //Test class:     ASI_MFM_PH_InputPlanItemsController
        ASI_MFM_PH_TestClassHelper.createMFMDefaultValues();
        
        ASI_MFM_Plan__c plan = ASI_MFM_PH_TestClassHelper.createPHDFPlan();
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_PH_TestClassHelper.createPHPlanLines2(plan);
        List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
        planLineSet.add(planLine);
        
        ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
        
        PageReference inputPlanItemsPage = Page.ASI_MFM_PH_InputPlanItemsPage;
        Map<String, String> pageParams = inputPlanItemsPage.getParameters();
        Test.startTest();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(inputPlanItemsPage);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
        
        ASI_MFM_PH_InputPlanItemsController PlanManageAllController = new ASI_MFM_PH_InputPlanItemsController(stdController);
        //Test function
        PlanManageAllController.init();
        System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)planLine.id);
        PlanManageAllController.cloneLine();
        PlanManageAllController.SaveItems();
        PlanManageAllController.addLineItem();
        System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)planLine.id);
        PlanManageAllController.removeLine();
        
        delete planLine;
       
        test.stopTest(); 
       
    }
     
    
    
}