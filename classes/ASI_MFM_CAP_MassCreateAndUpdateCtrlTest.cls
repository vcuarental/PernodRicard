@isTest
private class ASI_MFM_CAP_MassCreateAndUpdateCtrlTest {

    @isTest
    public static void testMassUpdateController()
    {  
        ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        ASI_MFM_A_C_Code__c acCode = ASI_MFM_CAP_TestClassHelper.createACCode();
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_CAP_TestClassHelper.createPlanLines(plan);
        
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineList.add(planLine);
        
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(planLineList);
        
        PageReference planInputItemsPage = Page.ASI_MFM_CAP_InputPlanItemsPage;
        Map<String, String> pageParams = planInputItemsPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(planInputItemsPage);
        
        ASI_MFM_CAP_InputPlanItemsController planInputItemsController = new ASI_MFM_CAP_InputPlanItemsController(standardController);
        
        ASI_MFM_CAP_MassCreateUpdateController mcauCon = new  ASI_MFM_CAP_MassCreateUpdateController();  
        mcauCon.headerPlanID = plan.id;
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_A_C_Code__c&req=T&width=160px,  ASI_MFM_AP_Code__c&req=T&width=160px,ASI_MFM_BU_Code__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=160px,';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Plan';
        mcauCon.successLink = '/' + plan.Id;
        mcauCon.cancelLink = '/' + plan.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRT = false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.includeRecordTypes='ASI_MFM_CAP_Plan_Line_Item';
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_BU_Code__c';
        //mcauCon.PageController = itChangeRequestController.thisController;       
        mcauCon.defaultFieldValuesStr = 'ASI_MFM_Quotation__c=Y';
        Boolean initPageBool = mcauCon.dummyVar; 
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Plan_Line_Item');        
        Integer recordIndex = 0;        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        mcauCon.commitAll();        
        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();   
        mcauCon.addNewRowByInfo('ASI_MFM_CAP_Plan',plan);
        List<ASI_MFM_CAP_MassCreateUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
        List<String> testString = new String[]{'tes1', 'test2'};
        mcauCon.initDateFields(testString);
        ASI_MFM_CAP_MassCreateUpdateController.DisplayField dp = new ASI_MFM_CAP_MassCreateUpdateController.DisplayField('labeltest', 'label', false);
        ASI_MFM_CAP_MassCreateUpdateController.PageBlockActionBtn dp2 = new ASI_MFM_CAP_MassCreateUpdateController.PageBlockActionBtn('testID', 'label');
    
    }   
    
    @isTest
    public static void testMassUpdateController1()
    {  
        ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        ASI_MFM_A_C_Code__c acCode = ASI_MFM_CAP_TestClassHelper.createACCode();
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_CAP_TestClassHelper.createPlanLines(plan);
        
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineList.add(planLine);
        
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(planLineList);
        
        PageReference planInputItemsPage = Page.ASI_MFM_CAP_InputPlanItemsPage;
        Map<String, String> pageParams = planInputItemsPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(planInputItemsPage);
        
        ASI_MFM_CAP_InputPlanItemsController planInputItemsController = new ASI_MFM_CAP_InputPlanItemsController(standardController);
        
        ASI_MFM_CAP_MassCreateUpdateController mcauCon = new  ASI_MFM_CAP_MassCreateUpdateController();  
        
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        //mcauCon.displayFieldsStr = 'ASI_MFM_A_C_Code__c&req=T&width=160px,  ASI_MFM_AP_Code__c&req=T&width=160px,ASI_MFM_BU_Code__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=160px,';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Plan';
        mcauCon.successLink = '/' + plan.Id;
        mcauCon.cancelLink = '/' + plan.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRT = false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.includeRecordTypes='ASI_MFM_CAP_Plan_Line_Item';
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_BU_Code__c';
        //mcauCon.PageController = itChangeRequestController.thisController;       
        mcauCon.defaultFieldValuesStr = 'ASI_MFM_Quotation__c=Y';
        Boolean initPageBool = mcauCon.dummyVar; 
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Plan_Line_Item');        
        Integer recordIndex = 0;        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        mcauCon.commitAll();        
        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();   
        mcauCon.addNewRowByInfo('ASI_MFM_CAP_Plan',plan);
        List<ASI_MFM_CAP_MassCreateUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
    
    }    

    @isTest
    public static void testMassUpdateController2()
    {  
        ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        ASI_MFM_A_C_Code__c acCode = ASI_MFM_CAP_TestClassHelper.createACCode();
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_CAP_TestClassHelper.createPlanLines(plan);
        
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        planLine.id = null;
        planLineList.add(planLine);
        
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(planLineList);
        
        PageReference planInputItemsPage = Page.ASI_MFM_CAP_InputPlanItemsPage;
        Map<String, String> pageParams = planInputItemsPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(planInputItemsPage);
        
        ASI_MFM_CAP_InputPlanItemsController planInputItemsController = new ASI_MFM_CAP_InputPlanItemsController(standardController);
        
        ASI_MFM_CAP_MassCreateUpdateController mcauCon = new  ASI_MFM_CAP_MassCreateUpdateController();  
        
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_A_C_Code__c&req=T&width=160px,  ASI_MFM_AP_Code__c&req=T&width=160px,ASI_MFM_BU_Code__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=160px,';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Plan';
        mcauCon.successLink = '/' + plan.Id;
        mcauCon.cancelLink = '/' + plan.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRT = false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.includeRecordTypes='ASI_MFM_CAP_Plan_Line_Item';
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_BU_Code__c';
        //mcauCon.PageController = itChangeRequestController.thisController;       
        mcauCon.defaultFieldValuesStr = 'ASI_MFM_Quotation__c=Y';
        Boolean initPageBool = mcauCon.dummyVar; 
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Plan_Line_Item');        
        Integer recordIndex = 0;        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        mcauCon.commitAll();        
        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();   
        mcauCon.addNewRowByInfo('ASI_MFM_CAP_Plan',plan);
        List<ASI_MFM_CAP_MassCreateUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
    
    }

    // [DC] added method to cover ASI_MFM_CAP_ObjectPicklistHelper
    @isTest
    public static void testMassUpdateController3()
    {  
        ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        plan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_TW_Plan');
        update plan;
        ASI_MFM_A_C_Code__c acCode = ASI_MFM_CAP_TestClassHelper.createACCode();

        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_CAP_TestClassHelper.createPlanLines(plan);
        planLine.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CAP_TW_Plan_Line_Item');
        update planLine;

        /*ASI_MFM_PO__c po = createPo('CAPEX', plan);
        po.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_TW_PO');
        update po;
        
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        planLine.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_TW_PO_Line_Item');
        update poLine;

        ASI_MFM_Payment__c payment = createPayment();
        po.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_TW_Payment');
        update payment;
        
        ASI_MFM_Payment_Line_Item__c paymentLine = ASI_MFM_CAP_TestClassHelper.createPaymentLines(payment, poLine);
        planLine.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_TW_Payment_Line_Item');
        update paymentLine;*/

        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineList.add(planLine);
        
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(planLineList);
        
        PageReference planInputItemsPage = Page.ASI_MFM_CAP_InputPlanItemsPage;
        Map<String, String> pageParams = planInputItemsPage.getParameters();
        pageParams.put('id', plan.Id);
        Test.setCurrentPageReference(planInputItemsPage);
        
        ASI_MFM_CAP_InputPlanItemsController planInputItemsController = new ASI_MFM_CAP_InputPlanItemsController(standardController);
        
        ASI_MFM_CAP_MassCreateUpdateController mcauCon = new  ASI_MFM_CAP_MassCreateUpdateController();
        mcauCon.objectPickListHelper = new ASI_MFM_CAP_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c', 'ASI_MFM_Plan__c');
        mcauCon.objectPickListHelper = new ASI_MFM_CAP_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c', 'ASI_MFM_Plan__c','','',NULL);
        mcauCon.objectPickListHelper = new ASI_MFM_CAP_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c', 'ASI_MFM_Plan__c','','',NULL,plan.Id);
        mcauCon.headerPlanID = plan.id;
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_A_C_Code__c&req=T&width=160px,  ASI_MFM_AP_Code__c&req=T&width=160px,ASI_MFM_BU_Code__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=160px,';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Plan';
        mcauCon.successLink = '/' + plan.Id;
        mcauCon.cancelLink = '/' + plan.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRT = false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.includeRecordTypes='ASI_MFM_CAP_TW_Plan_Line_Item';
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_BU_Code__c,ASI_MFM_Plan__c';
        //mcauCon.PageController = itChangeRequestController.thisController;       
        mcauCon.defaultFieldValuesStr = 'ASI_MFM_Quotation__c=Y';
        Boolean initPageBool = mcauCon.dummyVar; 
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Plan_TW_Line_Item');        
        Integer recordIndex = 0;        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        mcauCon.commitAll();        
        /*mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();   
        mcauCon.addNewRowByInfo('ASI_MFM_CAP_TW_Plan',plan);
        List<ASI_MFM_CAP_MassCreateUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
        List<String> testString = new String[]{'tes1', 'test2'};
        mcauCon.initDateFields(testString);*/
        ASI_MFM_CAP_MassCreateUpdateController.DisplayField dp = new ASI_MFM_CAP_MassCreateUpdateController.DisplayField('labeltest', 'label', false);
        ASI_MFM_CAP_MassCreateUpdateController.PageBlockActionBtn dp2 = new ASI_MFM_CAP_MassCreateUpdateController.PageBlockActionBtn('testID', 'label');

        /*// Payment Related Data
        ASI_MFM_CAP_MassCreateUpdateController mcauCon = new  ASI_MFM_CAP_MassCreateUpdateController();  
        mcauCon.headerPlanID = plan.id;
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_A_C_Code__c&req=T&width=160px,  ASI_MFM_AP_Code__c&req=T&width=160px,ASI_MFM_BU_Code__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=160px,';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Plan';
        mcauCon.successLink = '/' + plan.Id;
        mcauCon.cancelLink = '/' + plan.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRT = false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.includeRecordTypes='ASI_MFM_CAP_TW_Plan_Line_Item';
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_BU_Code__c';
        //mcauCon.PageController = itChangeRequestController.thisController;       
        mcauCon.defaultFieldValuesStr = 'ASI_MFM_Quotation__c=Y';
        Boolean initPageBool = mcauCon.dummyVar; 
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CAP_Plan_TW_Line_Item');        
        Integer recordIndex = 0;        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        mcauCon.commitAll();        
        /*mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();   
        mcauCon.addNewRowByInfo('ASI_MFM_CAP_TW_Plan',plan);
        List<ASI_MFM_CAP_MassCreateUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
        List<String> testString = new String[]{'tes1', 'test2'};
        mcauCon.initDateFields(testString);
        ASI_MFM_CAP_MassCreateUpdateController.DisplayField dp = new ASI_MFM_CAP_MassCreateUpdateController.DisplayField('labeltest', 'label', false);
        ASI_MFM_CAP_MassCreateUpdateController.PageBlockActionBtn dp2 = new ASI_MFM_CAP_MassCreateUpdateController.PageBlockActionBtn('testID', 'label');*/
    
    }
}