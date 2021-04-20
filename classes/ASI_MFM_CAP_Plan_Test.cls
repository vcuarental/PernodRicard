/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_Plan_Test
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-06-24       Wilken Lee               [WL 1.0] Increase coverage for ASI_MFM_CAP_Plan_TriggerClass
 * 2019-10-23       Wilken Lee               [WL 2.0] Increase coverage for ASI_MFM_CAP_PlanSummaryByAPCodeCtrl
 ****************************************************************************************************************************/
@isTest
public class ASI_MFM_CAP_Plan_Test {
    private static ASI_MFM_Plan__c plan;
    private static ASI_MFM_Plan_Line_Item__c planLines;
    private static ASI_MFM_PO__c po;
    private static ASI_MFM_PO_Line_Item__c poLineItem;
    
    @testSetup static void testSetupMethod(){
        ASI_MFM_CAP_TestClassHelper.createRoutePlanType();
        
        plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        
        planLines = ASI_MFM_CAP_TestClassHelper.createPlanLines(plan);
        
        ASI_MFM_CAP_TestClassHelper.createRoutePOType();
        
        po = ASI_MFM_CAP_TestClassHelper.createPo('CAPEX', plan);
        
        poLineItem = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
    }
    
    static testMethod void testPlanSummaryByAPCodePage()
    {
        plan = [select id, ASI_MFM_Prefix__c from ASI_MFM_Plan__c limit 1];
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
        ASI_MFM_CAP_PlanSummaryByAPCodeCtrl planSummaryController = new ASI_MFM_CAP_PlanSummaryByAPCodeCtrl(stdController);
        
        Test.startTest();
                
        PageReference planSummaryPage = Page.ASI_MFM_CAP_PlanSummaryByAPCodePage;
        Test.setCurrentPage(planSummaryPage);
        ApexPages.currentPage().getParameters().put('id', plan.id);
        
        planSummaryController.setcurrentHeaderId(plan.id); //WL 2.0     
              
        Test.stopTest();
    }
    
    /*[WL 1.0] BEGIN*/
    static testMethod void testPlan_Approver(){        
        /*ASI_MFM_Route_Type__c routeType = new ASI_MFM_Route_Type__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_CAP_Route_Type'),  ASI_MFM_Module__c = 'Plan', Name = 'Route Plan Test');
        insert routeType;
        
        List<ASI_MFM_Route_Rule_Detail__c> routeDetails = new List<ASI_MFM_Route_Rule_Detail__c>();
        for(integer i = 0; i < 10; i++){
            ASI_MFM_Route_Rule_Detail__c routedetail = new ASI_MFM_Route_Rule_Detail__c(
                ASI_MFM_Route_Type__c = routeType.id,
                ASI_MFM_Approver__c = userinfo.getuserid(),
                ASI_MFM_Minimum_Amount__c = 0);
            routeDetails.add(routedetail);
        }
        insert routeDetails;*/
        
        ASI_MFM_Prefix__c prefix = ASI_MFM_CAP_TestClassHelper.createPrefixPlanCAPEX();
        
        ASI_MFM_CAP_TestClassHelper.createApprovalRoute('Plan', prefix.Id, userinfo.getUserId());
        
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name = 'AP Plan1', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
                                                    ASI_MFM_Prefix__c = prefix.Id, ASI_MFM_Plan_Type__c = 'CAPEX' );
        
        insert plan;
    }
    /*[WL 1.0] END*/
    
    static testMethod void testPlanTrigger()
    {        
        plan = [select id, ASI_MFM_Prefix__c from ASI_MFM_Plan__c limit 1];
        
        /*
         * DC - 01/21/2016 - Added logic to increase coverage of ASI_MFM_CAP_Plan_TriggerClass
         */
        
        // DC LOGIC START
        
        // ASI_MFM_Plan__c planClone = ASI_MFM_CAP_TestClassHelper.createPlanClone(plan);
        
        List<ASI_MFM_Route_Type__c> lstRouteTypes = [SELECT Id
                                                       FROM ASI_MFM_Route_Type__c
                                                      LIMIT 1];

        ASI_MFM_Brand_Route_Type_Map__c testRouteMap;
        if(!lstRouteTypes.isEmpty()) {
            testRouteMap = new ASI_MFM_Brand_Route_Type_Map__c(
                ASI_MFM_Prefix__c = plan.ASI_MFM_Prefix__c,
                ASI_MFM_Route_Type__c = lstRouteTypes[0].Id,
                ASI_MFM_Active__c = true
            );
            insert testRouteMap;
        }

        ASI_MFM_Plan__c planClone = ASI_MFM_CAP_TestClassHelper.createPlanClone(plan);

        // DC LOGIC END
        try{
            delete plan;
            delete planClone;
        }Catch(Exception e){
            
        }
        
    }

    static testMethod void testEmailAttachmentController()
    {
        //ASI_eForm_TestClassHelper.createITPSRServiceRequestItem(itpsr);
       plan = [select id from ASI_MFM_Plan__c limit 1];
       
       ASI_MFM_CAP_TestClassHelper.createFormAttachment(plan.Id);
       ASI_MFM_CAP_TestClassHelper.createNote(plan.Id);
    
       ASI_MFM_CAP_EmailAttachmentController emailAttachmentController =
            new ASI_MFM_CAP_EmailAttachmentController();
            
       emailAttachmentController.currentHeaderId = plan.Id;       
       System.assert(emailAttachmentController.getCategories()!=null, 'Result Status:'+emailAttachmentController.getCategories()); 
    }
    
    static testMethod void testInputPlanItemsController()
    {           
        plan = [select id from ASI_MFM_Plan__c limit 1];
        
        Id planOwnerId;
        planOwnerId = UserInfo.getUserId();
        plan.OwnerId = planOwnerId;
        
        update plan;

        planLines = [select id from ASI_MFM_Plan_Line_Item__c limit 1];
        List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
        planLineSet.add(planLines);
        ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
    
        PageReference inputPlanItemsPage = Page.ASI_MFM_CAP_InputPlanItemsPage;
        Map<String, String> pageParams = inputPlanItemsPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(inputPlanItemsPage);
        
        ASI_MFM_CAP_InputPlanItemsController planLineItemsController = new ASI_MFM_CAP_InputPlanItemsController(sc);

        plan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_TW_Plan');
        plan.ASI_MFM_Status__c = 'Draft';
        
        plan.OwnerId = UserInfo.getUserId();
        update plan;
        

        sc = new ApexPages.standardSetController(planLineSet);
        
        inputPlanItemsPage = Page.ASI_MFM_CAP_InputPlanItemsPage;
        pageParams = inputPlanItemsPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(inputPlanItemsPage);
        
        planLineItemsController = new ASI_MFM_CAP_InputPlanItemsController(sc);
    }
    
    static testMethod void testInputPlanItemsControllerHK()
    {           
        list<GroupMember> records =  [select id, GroupId, UserOrGroupId from GroupMember where UserOrGroupId =: userinfo.getuserid() and UserOrGroupId != null];
        system.debug('GroupMember records'+ records);
        plan = [select id from ASI_MFM_Plan__c limit 1];
        
        Id planOwnerId;
        planOwnerId = UserInfo.getUserId();
        plan.OwnerId = planOwnerId;
        
        update plan;

        planLines = [select id from ASI_MFM_Plan_Line_Item__c limit 1];
        List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
        planLineSet.add(planLines);
        ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
    
        PageReference inputPlanItemsPage = Page.ASI_MFM_CAP_InputPlanItemsPage;
        Map<String, String> pageParams = inputPlanItemsPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(inputPlanItemsPage);
        
        ASI_MFM_CAP_InputPlanItemsController planLineItemsController = new ASI_MFM_CAP_InputPlanItemsController(sc);

        plan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan_Read_Only');
        plan.ASI_MFM_Status__c = 'Submitted';
        
        plan.OwnerId = UserInfo.getUserId();
        update plan;
        

        sc = new ApexPages.standardSetController(planLineSet);
        
        inputPlanItemsPage = Page.ASI_MFM_CAP_InputPlanItemsPage;
        pageParams = inputPlanItemsPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(inputPlanItemsPage);
        
        planLineItemsController = new ASI_MFM_CAP_InputPlanItemsController(sc);
    }

    static testMethod void testPlanPDFController()
    {
        
        // [DC] Created custom setting test data.
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

        plan = [select id from ASI_MFM_Plan__c limit 1];
        
        PageReference planPDFPage = Page.ASI_MFM_CAP_PlanPDFPage;
        Map<String, String> pageParams = planPDFPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(planPDFPage);
        ASI_MFM_CAP_PlanPDFController planPDFController =
            new ASI_MFM_CAP_PlanPDFController();
        /*
         * DC - 01/22/2016 - Changed logic to increase coverage of ASI_MFM_CAP_PlanPDFController
         */
        
        planPDFController.setcurrentHeaderId(plan.id);
        // DC - 01/22/2016 - Reset Header to NULL to cover logic in getHeader() method.
        planPDFController.header = NULL;
        planPDFController.setHeaderRecordTypeId(plan.id);
        planPDFController.getHeader();
        planPDFController.getcurrentHeaderId();
        planPDFController.getHeaderRecordTypeId();
        planPDFController.setinit('test');
        planPDFController.getDetails();
        // DC - 01/22/2016 - Changed method call position to line #159
        // planPDFController.getHeader();
        
        ASI_MFM_CAP_PlanPDFController planPDFController1 =
            new ASI_MFM_CAP_PlanPDFController();
        planPDFController1.setcurrentHeaderId(plan.id);   
        planPDFController1.getHeader();
        planPDFController1.getDetails();
        
        //ASI_MFM_Plan__c planClone = ASI_MFM_CAP_TestClassHelper.createPlanClone(plan);
        update plan;
        try{
            delete plan;
        }catch(Exception e){
            
        }
        
    
    }
    
    static testMethod void testPlanPrefixController()
    { 
        plan = [select id, recordtypeid from ASI_MFM_Plan__c limit 1];
        Test.startTest();
        
        PageReference planPrefixPage = Page.ASI_MFM_SelectPlanPrefixPage;
        //Map<String, String> pageParams = planPrefixPage.getParameters();
        //pageParams.put('RecordType', plan.recordtypeid);
        //pageParams.put('id', plan.id);
        Test.setCurrentPage(planPrefixPage);
        system.debug('ayooo ' + plan.recordtypeid);
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(plan.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', plan.id);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
        ASI_MFM_SelectPlanPrefixController SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
        
        SelectPlanPrefixController.getPrefixes();
        SelectPlanPrefixController.proceed();
            
        Test.stopTest();
    }
    
    static testMethod void test_main() { 
        plan = [select id, recordtypeid from ASI_MFM_Plan__c limit 1];
        
        planLines = [select id from ASI_MFM_Plan_Line_Item__c limit 1];
  
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineList.add(planLines);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(planLineList);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_InputPlanItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_InputPlanItemsController testCon = new ASI_MFM_InputPlanItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        //ASI_MFM_SFObjSelectTableController sobjstCon = new ASI_MFM_SFObjSelectTableController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_AP_Code__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=160px,ASI_MFM_Total_Cost__c&req=T&width=100px,ASI_MFM_TnE_Category__c&req=F&width=120px,ASI_MFM_T_E__c&req=F&width=40px,ASI_MFM_Quotation__c&req=F&width=60px,ASI_MFM_Quotation_Available_Date__c&req=F&width=80px,ASI_MFM_Justification__c&req=F&width=160px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + plan.Id;
        mcauCon.cancelLink = '/' + plan.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
       // mcauCon.PageController = testCon.thisController;
        mcauCon.lookupToPicklist = 'ASI_MFM_A_C_Code__c';
        
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_Plan_Line_Item');
       
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
        //pageParams.put(mcauCon.PARAM_TRID, recordID);     
        //mcauCon.enableForEdit();
//      mcauCon.enableForEditByTableRowId(string.valueOf(pyi.id));
        //mcauCon.cloneRow();
        
        //mcauCon.addNewRow();
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_Plan_Line_Item');
        List<ASI_MFM_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        //mcauCon.removeNew();        
        //mcauCon.addMoreBlankRows();
    }
    
    static testMethod void test_main2() { 
        plan = [select id, recordtypeid from ASI_MFM_Plan__c limit 1];
                  
        planLines = [select id from ASI_MFM_Plan_Line_Item__c limit 1];
  
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineList.add(planLines);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(planLineList);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_InputPlanItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_InputPlanItemsController testCon = new ASI_MFM_InputPlanItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        //ASI_MFM_SFObjSelectTableController sobjstCon = new ASI_MFM_SFObjSelectTableController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_AP_Code__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=160px,ASI_MFM_Total_Cost__c&req=T&width=100px,ASI_MFM_TnE_Category__c&req=F&width=120px,ASI_MFM_T_E__c&req=F&width=40px,ASI_MFM_Quotation__c&req=F&width=60px,ASI_MFM_Quotation_Available_Date__c&req=F&width=80px,ASI_MFM_Justification__c&req=F&width=160px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + plan.Id;
        mcauCon.cancelLink = '/' + plan.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
       // mcauCon.PageController = testCon.thisController;
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_Customer_Name__c';
        
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_Plan_Line_Item');
       
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
        //pageParams.put(mcauCon.PARAM_TRID, recordID);     
        //mcauCon.enableForEdit();
        //mcauCon.enableForEditByTableRowId(string.valueOf(pyi.id));
        //mcauCon.cloneRow();
        //mcauCon.addNewRow();
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_Plan_Line_Item');
        List<ASI_MFM_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        //mcauCon.removeNew();        
        //mcauCon.addMoreBlankRows();
    }
    
    static testMethod void test_getGroupsForIds() { 
        plan = [select id, recordtypeid from ASI_MFM_Plan__c limit 1];   
        planLines = [select id from ASI_MFM_Plan_Line_Item__c limit 1];
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineList.add(planLines);
        
        /*[WL 1.0] BEGIN*/
        //Set<id> g =  new Set<Id>(New Map<Id, Group>([select id from Group limit 10]).keySet());
        Set<id> g =  new Set<Id>();
        Group gp = new Group(Name = 'Test Group');
        insert gp;
        
        g.add(gp.Id);
        
        GroupMember gm = new GroupMember(UserOrGroupId = UserInfo.getUserid(), GroupId = gp.Id);
        /*[WL 1.0] END*/
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(planLineList);
        
        
        PageReference testPage = Page.ASI_MFM_InputPlanItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_CAP_InputPlanItemsController ctrl = new ASI_MFM_CAP_InputPlanItemsController(stdSetController);
        ctrl.getGroupsForIds(g);
    }
}