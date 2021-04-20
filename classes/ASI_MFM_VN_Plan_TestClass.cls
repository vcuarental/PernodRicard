/***************************************************************************************************************************
 * Name:        ASI_MFM_VN_Plan_TestClass
 * Description:
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-2-11        Andy Zhang (LAPUTA)     Cloned from ASI_MFM_PH_Plan_TestClass
 ****************************************************************************************************************************/

@isTest
/*  Test Method: 

ASI_MFM_Plan_TriggerClass
ASI_MFM_PO_TriggerClass
ASI_MFM_POLineItem_TriggerClass

ASI_MFM_SelectPaymentPrefixController
ASI_MFM_SelectPOPrefixController

***************************
*       ASI_MFM_VN_InputPlanItemsController
        ASI_MFM_VN_PlanNewPORedirectCtrl
        ASI_MFM_VN_InputPOItemsController
        ASI_MFM_VN_InputPaymentItemsController
        ASI_MFM_VN_Payment_PDF_PageController
        ASI_MFM_VN_PORelatedPaymentsController
        ASI_MFM_VN_FV_Controller
        ASI_MFM_Payment_TriggerClass
        ASI_MFM_VN_GLDate_SettingController
        ASI_MFM_VN_SupplierEditSupplierNoCtrl        
        ASI_MFM_VN_PO_PDF_PageController
        ASI_MFM_VN_BAverifyController
        ASI_MFM_SetPOStatusController
        ASI_MFM_VN_Payment_TriggerClass
        ASI_MFM_SetPaymentStatusController


ASI_MFM_RerunETLController
* History
* -----------------------------------------------------------------------------
* 2015-10-30    Elufasys      Created
*
*/


private class ASI_MFM_VN_Plan_TestClass {
    static testMethod void testPlanDPPrefixController2()
    {
        //Test ASI_MFM_SelectPlanPrefixController
        ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DP_Plan'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = ASI_MFM_VN_TestClassHelper.createVNDPMultiPrefixPlan().id);
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
        ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = ASI_MFM_VN_TestClassHelper.createVNDFMultiPrefixPlan().id);
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

    static testMethod void testVNPlanController()
    {
        //Test ASI_MFM_SelectPlanPrefixController
        ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = ASI_MFM_VN_TestClassHelper.createVNDFMultiPrefixPlan().id);
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
        ASI_MFM_Plan__c plan1 = ASI_MFM_VN_TestClassHelper.createVNDPPlan();

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
        ASI_MFM_Plan__c plan1 = ASI_MFM_VN_TestClassHelper.createVNDFPlan();

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
        //Test class:  ASI_MFM_Plan_TriggerClass      ASI_MFM_VN_InputPlanItemsController
        user u = [SELECT ID, ASI_MFM_Country__c, userRole.developerName FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        ASI_MFM_VN_TestClassHelper.createMFMDefaultValues();

        String FY = ASI_MFM_VN_TestClassHelper.getFiscalYear();

        ASI_MFM_Prefix__c pxo = ASI_MFM_VN_TestClassHelper.createVNDPPrefixPlan();

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
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        ASI_MFM_Sub_brand__c sb = ASI_MFM_VN_TestClassHelper.CreateDPSBrand();
        ASI_MFM_Sub_brand_Allocation__c sba = new ASI_MFM_Sub_brand_Allocation__c
                (
                        Name = 'Test SB Allocation1',
                        ASI_MFM_inactive__c = false,
                        ASI_MFM_Fiscal_Year__c = FY
                );
        insert sba;

        ASI_MFM_Sub_brand_Allocation_Detail__c sbal = new ASI_MFM_Sub_brand_Allocation_Detail__c
                (
                        ASI_MFM_Sub_Brand_Allocation__c = sba.id,
                        ASI_MFM_Percentage__c = 100,
                        ASI_MFM_Sub_brand__c = sb.id
                );
        insert sbal;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                        Name = 'Test Plan',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DP_Plan'),
                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                        ASI_MFM_End_Date__c = date.today().adddays(1),
                        ASI_MFM_Prefix__c = pxo.id,
                        ASI_MFM_PH_Sub_Brand_Allocation__c = sba.id,
                        ASI_MFM_PH_Total_Plan_Amount__c = 1000
                );

        insert plan;

        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_VN_TestClassHelper.createVNPlanLines1(plan);
        List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
        planLineSet.add(planLine);

        ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);

        PageReference inputPlanItemsPage = Page.ASI_MFM_VN_InputPlanItemsPage;
        Map<String, String> pageParams = inputPlanItemsPage.getParameters();
        Test.startTest();

        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(inputPlanItemsPage);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);

        ASI_MFM_VN_InputPlanItemsController PlanManageAllController = new ASI_MFM_VN_InputPlanItemsController(stdController);
        //Test function
        PlanManageAllController.init();
        System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)planLine.id);
        PlanManageAllController.cloneLine();
        PlanManageAllController.SaveItems();
        PlanManageAllController.addLineItem();
        System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)planLine.id);
        PlanManageAllController.removeLine();

        //Test RemoteAction
        List<Account> remo= ASI_MFM_VN_InputPlanItemsController.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_VN_DF_Customer');

        test.stopTest();

    }


    static testMethod void InputPlanItems_Test_Fail_Case() {
        //Test class:     ASI_MFM_VN_InputPlanItemsController
        ASI_MFM_VN_TestClassHelper.createMFMDefaultValues();

        ASI_MFM_Plan__c plan = ASI_MFM_VN_TestClassHelper.createVNDFPlan();
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_VN_TestClassHelper.createVNPlanLines2(plan);
        List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
        planLineSet.add(planLine);

        ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);

        PageReference inputPlanItemsPage = Page.ASI_MFM_VN_InputPlanItemsPage;
        Map<String, String> pageParams = inputPlanItemsPage.getParameters();
        Test.startTest();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(inputPlanItemsPage);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);

        ASI_MFM_VN_InputPlanItemsController PlanManageAllController = new ASI_MFM_VN_InputPlanItemsController(stdController);
        //Test function
        PlanManageAllController.init();
        System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)planLine.id);
        PlanManageAllController.cloneLine();
        PlanManageAllController.SaveItems();
        PlanManageAllController.addLineItem();
        System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)planLine.id);
        PlanManageAllController.removeLine();

        test.stopTest();

    }


    static testMethod void Plan_TriggerClass1(){

        user u = [SELECT ID, ASI_MFM_Country__c, userRole.developerName FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        ASI_MFM_VN_TestClassHelper.createMFMDefaultValues();

        String FY = ASI_MFM_VN_TestClassHelper.getFiscalYear();

        ASI_MFM_Prefix__c pxo = ASI_MFM_VN_TestClassHelper.createVNDPPrefixPlan();

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
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        ASI_MFM_Sub_brand__c sb = ASI_MFM_VN_TestClassHelper.CreateDPSBrand();
        ASI_MFM_Sub_brand_Allocation__c sba = new ASI_MFM_Sub_brand_Allocation__c
                (
                        Name = 'Test SB Allocation1',
                        ASI_MFM_inactive__c = false,
                        ASI_MFM_Fiscal_Year__c = FY
                );
        insert sba;

        ASI_MFM_Sub_brand_Allocation_Detail__c sbal = new ASI_MFM_Sub_brand_Allocation_Detail__c
                (
                        ASI_MFM_Sub_Brand_Allocation__c = sba.id,
                        ASI_MFM_Percentage__c = 100,
                        ASI_MFM_Sub_brand__c = sb.id
                );
        insert sbal;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                        Name = 'Test Plan',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DP_Plan'),
                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                        ASI_MFM_End_Date__c = date.today().adddays(1),
                        ASI_MFM_Prefix__c = pxo.id
                );
        insert plan;

        ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c
                (
                        Name = 'Test Plan1',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DP_Plan'),
                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                        ASI_MFM_End_Date__c = date.today().adddays(1),
                        ASI_MFM_Prefix__c = pxo.id,
                        ASI_MFM_PH_Sub_Brand_Allocation__c = sba.id,
                        ASI_MFM_PH_Total_Plan_Amount__c = 1000,
                        ASI_MFM_Cloned_Plan_ID__c = plan.id
                );

        insert plan1;

    }

    static testMethod void Plan_TriggerClass2(){

        user u = [SELECT ID, ASI_MFM_Country__c, userRole.developerName FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        ASI_MFM_VN_TestClassHelper.createMFMDefaultValues();

        String FY = ASI_MFM_VN_TestClassHelper.getFiscalYear();

        ASI_MFM_Prefix__c pxo = ASI_MFM_VN_TestClassHelper.createVNDFPrefixPlan();

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
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        ASI_MFM_Sub_brand__c sb = ASI_MFM_VN_TestClassHelper.CreateDPSBrand();

        ASI_MFM_Plan__c plan2 = new ASI_MFM_Plan__c
                (
                        Name = 'Test Plan',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan'),
                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                        ASI_MFM_End_Date__c = date.today().adddays(1),
                        ASI_MFM_Prefix__c = pxo.id
                );
        insert plan2;

        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_VN_DF_Customer'),Name='Name3');

        ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_VN_Plan_Line_Item'),
                        ASI_MFM_List_Item_Description__c = 'test description',
                        ASI_MFM_Total_Cost__c = 1234,
                        ASI_MFM_Plan__c = plan2.id,
                        ASI_MFM_Sub_brand_Code__c=sb.id,
                        ASI_MFM_A_C_Code__c=ASI_MFM_VN_testClasshelper.createACVNDPCode().id,
                        ASI_MFM_Customer_Name__c=acc2.id
                );
        insert planLine;

        delete planLine;
        delete plan2;
    }
}