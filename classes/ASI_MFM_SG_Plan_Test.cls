/*********************************************************************************
 * Name:ASI_MFM_SG_Plan_Test
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 07/03/2018         Wilken                [WL 1.0] Added MassCreateAndUpdateController Test Code
*********************************************************************************/
@isTest
private class ASI_MFM_SG_Plan_Test {
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
    
    /*[WL 1.0] BEGIN*/
    static testMethod void ASI_MFM_Function_Test() {
        Boolean byPass = ASI_MFM_Function.bypassCallouts();
        
        Boolean byPassCache = ASI_MFM_Function.bypassTriggersFunctionCache('Test');
        Boolean byPassFunction = ASI_MFM_Function.bypassTriggersFunction('Test');
        
        ASI_MFM_Function.displayCalloutCount('Test');
        Decimal percentageTest = ASI_MFM_Function.getPercentage('(123%');
        
        Id checkRT = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_SG_Plan__c');    
    }
    
     static testMethod void testTWInputPlanItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id,
        ASI_MFM_Status__c = 'Final');
        insert p;       
        test.setCurrentPage(page.ASI_MFM_InputPlanItemsPage);
        apexpages.currentPage().getParameters().put('id', p.id); 
        list<ASI_MFM_Plan__c> p_list = new list<ASI_MFM_Plan__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(p_list);  
        ASI_MFM_InputPlanItemsController cx = new ASI_MFM_InputPlanItemsController(sc);             
    
    ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=240px, ASI_MFM_A_C_Code__c&req=T&width=160px, ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Quantity__c&req=F&width=50px, ASI_MFM_Unit_Cost__c&req=F&width=65px, ASI_MFM_Total_Cost__c&req=F&width=105px, ASI_MFM_Number_of_Outlets__c&req=F&width=80px, ASI_MFM_Expected_Volume__c&req=F&width=65px, ASI_MFM_Size__c&req=F&width=70px, ASI_MFM_FOC_Size__c&req=F&width=70px, ASI_MFM_Print_Sequence__c&req=F&width=80px';        
    mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + p.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + p.Id;
        mcauCon.cancelLink = '/' + p.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        //Boolean initPageBool = mcauCon.dummyVar;

    mcauCon.init();
    mcauCon.commitAll();
    }
    
     static testMethod void ASI_MFM_SG_InputPaymentItems_MassCreateAndUpdateControllerTest() {
        // Test for  ASI_MFM_SG_InputPaymentItemsController and  ASI_MFM_MassCreateAndUpdateController
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Exchange_Rate__c=1, ASI_MFM_Application__c = 'MFM',ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='SGD',ASI_MFM_Country__c='SG');
    
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c = 'testDescription', ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');           
        
        accountList.add(acc1);
        // SG: Supplier: ASI_CRM_SG_Supplier
        // SG: Outlet: ASI_CRM_SG_Outlet
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        accountList.add(acc2);
        insert accountList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');     
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c = 100,
      ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
        
        //-----------------------Start Test-----------------------------------        
        insert poi;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert pxa; 
        
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;  
        
        
        System.debug(Limits.getDMLRows());
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc1.id);
        insert py;
        Test.startTest();
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');    
        insert pyi;
        System.debug(Limits.getDMLRows());
        
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        pyi_list.add(pyi);
        
        System.debug(Limits.getDMLRows());
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        // Initialize the page
        
        PageReference testPage = Page.ASI_MFM_SG_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPaymentItemsController testCon = new ASI_MFM_SG_InputPaymentItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
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
        mcauCon.lookupToPicklist = 'hello,world';
        
        sobjstCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        sobjstCon.displayFieldsStr = 'Name,ASI_MFM_Requested_Balance__c, ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Currency__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_Remaining_Balance__c';
        
        sobjstCon.defWhereStatmStr = null;
        sobjstCon.orderByStr = 'ASI_MFM_PO__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_Payment_Line_Item');
        
        integer recordIndex= 0;
        for (integer i = 0; i< mcauCon.theRecordTypeElementList.size(); i++)
        {
            if (mcauCon.theRecordTypeElementList.get(i).myRecordList.size() > 0)
            {
                recordIndex = i;
                break;
                
            }
        }
        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);     
        
        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();
        
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_Payment_Line_Item');
        List<ASI_MFM_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();
        
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
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_Payment_Line_Item');
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Set values
        
        // Filter products
        testCon.po_filter = 'test';
        testCon.supplier_filter = 'test';
        testCon.plan_filter = 'test';
        testCon.raised_by_filter = 'test';
        testCon.filterPOItems();
        
        Test.stopTest();
        //------------------------------Test End-------------------------------------
    }
    
    static testMethod void testCNInputPOItemsController() {
        List<ASI_MFM_Prefix__c> pList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        pList.add(px1);
        ASI_MFM_Prefix__c px2= new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        pList.add(px2);
        insert pList; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(pr1);
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(pr2);
        insert prList;
        
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=px2.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=userInfo.getUserId(),ASI_MFM_Status__c='Final');
        insert plan;
            
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Plan__c = plan.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO'), name='test', ASI_MFM_PO_End_Date__c=Date.today(), ASI_MFM_PO_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft', ASI_MFM_Prefix__c=px1.id);
        insert po;
        
        Profile p = [select Id from Profile where Name='System Administrator']; 
        User userA = new User(  Alias = 'test', 
                                Email='test@test.com', 
                                EmailEncodingKey='UTF-8', 
                                LastName='test', 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', 
                                UserName='test@cnMFMTestUser.com');

        Id currentUID = UserInfo.getUserId();
        System.runAs(userA) {   
            Group objPGp = [SELECT id FROM group WHERE name = 'ASI MFM CN Regional User'];
            
            GroupMember gmember = new GroupMember(UserOrGroupId=currentUID, GroupId=objPGp.Id);
            insert gmember;
        }
                
        ASI_MFM_Sub_brand__c sb = new ASI_MFM_Sub_brand__c(recordtypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'), ASI_MFM_Active_for_MFM__c=true, Name='Test Sub-brand');
        insert sb;
        
        ASI_MFM_Sub_brand_Allocation__c sbAllocation = new ASI_MFM_Sub_brand_Allocation__c(Name='Test', ASI_MFM_PO__c=po.id, ASI_MFM_Sub_brand_Code__c=sb.id, recordtypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation'));
        insert sbAllocation;
        
        test.setCurrentPage(page.ASI_MFM_CN_InputPOItemsPage);
        apexpages.currentPage().getParameters().put('id', po.id); 
        list<ASI_MFM_PO__c> p_list = new list<ASI_MFM_PO__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(p_list);  
        ASI_MFM_HK_InputPOItemsController cx = new ASI_MFM_HK_InputPOItemsController(sc); 
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T, ASI_MFM_A_C_Code__c&req=T, ASI_MFM_List_Item_Description__c&req=F&width=120px, ASI_MFM_Amount__c&req=T&width=80px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'PO Line Items';
        mcauCon.successLink = '/' + po.Id;
        mcauCon.cancelLink = '/' + po.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c';
        //Boolean initPageBool = mcauCon.dummyVar;

        mcauCon.init();
        
        List<ASI_MFM_Sub_brand_Allocation__c> tmp = new List<ASI_MFM_Sub_brand_Allocation__c>();
        tmp.add(sbAllocation);
        
        mcauCon.delItemList = tmp;
        
        mcauCon.commitAll();
        mcauCon.sba_addRow();
        
        mcauCon.results[0].rowindex = 0;
        mcauCon.rowSelected_index = 0;
        
        mcauCon.sba_cloneRow();
        mcauCon.sba_deleteRow();
        ASI_MFM_MassCreateAndUpdateController.interimData interim = new ASI_MFM_MassCreateAndUpdateController.interimData();
    
        ASI_MFM_MassCreateAndUpdateController.PageBlockActionBtn a = new ASI_MFM_MassCreateAndUpdateController.PageBlockActionBtn(po.Id,'Test');
        ASI_MFM_MassCreateAndUpdateController.DisplayField d = new ASI_MFM_MassCreateAndUpdateController.DisplayField('label','name');      
        
        ASI_MFM_MassCreateAndUpdateController.interimData tempInClass = new ASI_MFM_MassCreateAndUpdateController.interimData();
        tempInClass.Id = null;
        String abbc = tempInClass.Id;
        tempInClass.Id = 'abc';
        abbc = tempInClass.Id;
        d.colKey = 'abbd';
        
        string ccc = mcauCon.MODE_NEW;
        mcauCon.theRecordTypeElementList[0].myRecordList = null;
        mcauCon.theRecordTypeElementList[0].myDisplayRecordList = null;
        
        mcauCon.results = null;
        mcauCon.sba_addRow();
        
        String bbb = ASI_MFM_MassCreateAndUpdateController.ACTION_EDIT;
        bbb = ASI_MFM_MassCreateAndUpdateController.ACTION_CLONE;
        bbb = ASI_MFM_MassCreateAndUpdateController.ACTION_ADD_NEW;
        bbb = ASI_MFM_MassCreateAndUpdateController.ACTION_REMOVE_NEW;
        bbb = ASI_MFM_MassCreateAndUpdateController.RTNAME_MASTER;
        bbb = ASI_MFM_MassCreateAndUpdateController.RTDEVNAME_MASTER;
    }
    
    static testMethod void TH_POMassCreateAndUpdateTest(){
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415', recordTypeId = pxrt_map.get('ASI_MFM_TH_Prefix')); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;  
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today().addMonths(3), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Final');//Draft
        
        try {
            insert p;
        } catch(SObjectException se) {
            System.debug('The following exception has occurred: ' + se.getMessage());
        }
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test3', ASI_MFM_Prefix__c=px.id,ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today());
        insert p3;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'));
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC',ASI_MFM_Dummy_A_C__c=false);
        insert ac;
        
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');           
        insert acc2;
        
        //ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        //insert pi;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');     //ASI_MFM_SG_Supplier            
        insert acc1;
        
        //--------------------------------Start Test---------------------------
        Test.startTest();
        
        // Create PO 
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');             
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        // Create PO Line Items
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        //Set  ASI_MFM_Complete__c = true, run the ASI_MFM_POLineItem_TriggerClass.routineBeforeUpdate 
        list<ASI_MFM_PO_Line_Item__c> poLineItems = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_Complete__c = true);
        poLineItems.add(poi);
        insert poLineItems;
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(poLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_TH_InputPOItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', po.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_TH_InputPOItemsController testCon = new ASI_MFM_TH_InputPOItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=240px,ASI_MFM_A_C_Code__c&req=T&width=160px,ASI_MFM_Customer_Name__c&req=T&width=120px,ASI_MFM_List_Item_Description__c&req=T&width=120px,ASI_MFM_TH_Unit__c&req=F&width=60px,ASI_MFM_Quantity__c&req=F&width=60px,ASI_MFM_Unit_Price__c&req=F&width=60px,ASI_MFM_Amount__c&req=T&width=80px,ASI_MFM_G_L_Date__c&req=T&width=75px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + po.Id;
        mcauCon.cancelLink = '/' + po.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TH_PO_Line_Item');
        
        mcauCon.commitAll();
        
        Test.stopTest();
    }   
    /*[WL 1.0] END*/
    static testMethod void ASI_MFM_SelectPlanPrefixController_SG_TEST() {
        
        User user1 =ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='SG';
        update user1;
        
        UserRole ur = [Select id from userrole where developername='ASI_FOC_NTMK_Merchandizing_On_Applier'];
        Profile p = [select id from profile where name='ASI SG Standard User'];
        User u = new User(alias = 'standt', email='alan.wong@elufasys.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,ASI_MFM_Country__c ='SG',ASI_MFM_Bypass_Callouts__c = true, ASI_MFM_Team__c = 'NTMK', UserRoleid=ur.id,timezonesidkey='America/Los_Angeles', username='alan.wong@elufasys.com');
        // insert u;
        
        //user qiulei = [SELECT id from user where id = '005D000000251hg'];
        
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<string, id> po_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
        Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c'); // Not use in SG
        Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c'); // Not use in SG
        Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
        
        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='SG',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form',ASI_MFM_Fiscal_year__c=getFiscalYear(),ownerId = user1.id);
        insert prefix1 ;
        
        ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id, ASI_MFM_Role_Name__c =u.userRole.developerName);
        insert prefixChild1;
        
        ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id, ASI_MFM_Role_Name__c =user1.userRole.developerName);            
        insert prefixChild2;
        
        
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        insert ac1;
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
        insert ac2;
        //ASI_MFM_A_C_Code__c: ASI_MFM_SG_A_C_Code  set in ASI_MFM_MassCreateAndUpdateController
        
        
        ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=ppc_map.get('ASI_MFM_CN_PP_Category'), Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
        insert ppc;
        
        
        ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
        insert ppcac1; 
        ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
        insert ppcac2; 
        
        
        ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1415', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
        insert mms;
        
        ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Draft', OwnerId =user1.id);
        insert Plan1;
        
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand2;
        //SG:    ASI_MFM_Sub_brand__c : ASI_CRM_SG_Sub_brand
        
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'));
        insert ac;
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        // SG: Supplier: ASI_CRM_SG_Supplier
        // SG: Outlet: ASI_CRM_SG_Outlet
        
        
        //Insert 3 Plan Line Items
        ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1',recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,ASI_MFM_A_C_Code__c=ac.id);
        insert planLineItem1;       
        
        ASI_MFM_Plan_Line_Item__c planLineItem2 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2',recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,ASI_MFM_A_C_Code__c=ac.id);
        insert planLineItem2; 
        
        ASI_MFM_Plan_Line_Item__c planLineItem3 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2',recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,ASI_MFM_A_C_Code__c=ac.id);
        insert planLineItem3; 
        
        delete planLineItem3;
        
        Plan1.ASI_MFM_Status__c='Final';
        update Plan1;
        
        //-----------------------------Test Start-------------------------------------------
        Test.startTest();
        System.debug(Limits.getDMLRows());
        
        System.runAs(user1){
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);        
            ASI_MFM_SelectPlanPrefixController ASI_MFM_SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
            ASI_MFM_SelectPlanPrefixController.getPrefixes();
            ASI_MFM_SelectPlanPrefixController.proceed();
        }
        
        user1.ASI_MFM_Country__c = null;
        update user1;
        System.runAs(user1){
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);
            ASI_MFM_SelectPlanPrefixController ASI_MFM_SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
            ASI_MFM_SelectPlanPrefixController.getPrefixes();
            ASI_MFM_SelectPlanPrefixController.proceed();
        }
        
        Id roleId;
        System.runAs(new User(id = UserInfo.getUserId())){
            user1.UserRoleId = null;
            update user1;
        }
        
        system.debug(user1.UserRoleId);
        
        System.runAs(user1){
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);
            
            ASI_MFM_SelectPlanPrefixController ASI_MFM_SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
            ASI_MFM_SelectPlanPrefixController.getPrefixes();
            ASI_MFM_SelectPlanPrefixController.proceed();
        }
        
        Test.stopTest();
        
    }
    
    
    
    
    static testMethod void ASI_MFM_Plan_TriggerClass_SG_TEST() {
        // Test ASI_MFM_Plan_TriggerClass  AND   ASI_MFM_PlanLineItem_TriggerClass
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='SG';
        update user1;
        
        UserRole ur = [Select id from userrole where developername='ASI_SG_Asst_Sales_Manager_MOT'];
        Profile p = [select id from profile where name='ASI SG Standard User'];
        User u = new User(alias = 'standt', email='alan.wong@elufasys.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,ASI_MFM_Country__c ='SG',ASI_MFM_Bypass_Callouts__c = true, ASI_MFM_Team__c = 'NTMK', UserRoleid=ur.id,timezonesidkey='America/Los_Angeles', username='alan.wong@elufasys.com');
        // insert u;
        
        //user qiulei = [SELECT id from user where id = '005D000000251hg'];
        
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<string, id> po_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
        //Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
        //Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c');
        //Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
        
        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='SG',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form',ASI_MFM_Fiscal_year__c=getFiscalYear(),ownerId = user1.id);
        insert prefix1 ;
        
        ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,ASI_MFM_Role_Name__c =u.userRole.developerName);            
        insert prefixChild1;
        
        ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,ASI_MFM_Role_Name__c =user1.userRole.developerName);            
        insert prefixChild2;
        
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        insert ac1;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
        insert ac2;
        
        
        ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='SG131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, ASI_MFM_Status__c='Draft', OwnerId =user1.id);
        insert Plan1;
        
        ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='SG132',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
        insert Plan2;
        
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'));
        insert ac;
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        // Add 3 plan Line Item
        list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        insert planLineItems;
        
        list<ASI_MFM_Plan__c> plans = new list<ASI_MFM_Plan__c>();
        plans.add(Plan1);
        Plan1.ASI_MFM_Cloned_Plan_ID__c = Plan2.Id;
        Plan2.Id = Plan1.Id;
        
        map<Id, ASI_MFM_Plan__c> mapPlans = new map<Id, ASI_MFM_Plan__c>();
        mapPlans.put(Plan2.Id, Plan2);
        
        //------------------------------Plan line Items-------------------------------
        ASI_MFM_Plan_Line_Item__c planLineItems1= new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                                                ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello133'
                                                                                ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                                                ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                                                ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                                                ASI_MFM_A_C_Code__c=ac.id);
        
        ASI_MFM_Plan_Line_Item__c planLineItems2= new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
                                                                                ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello144'
                                                                                ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                                                ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                                                ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                                                ASI_MFM_A_C_Code__c=ac.id);
        planLineItems2.Id=planLineItems1.Id;
        
        
        list<ASI_MFM_Plan_Line_Item__c> planLineItemsnew1 = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineItemsnew1.add(planLineItems1);
        
        map<Id,ASI_MFM_Plan_Line_Item__c>mapPlanlineitems =new map<Id, ASI_MFM_Plan_Line_Item__c>();
        mapPlanlineitems.put(planLineItems2.Id,planLineItems2);
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        System.runAs(user1){
            ASI_MFM_Plan_TriggerClass.routineAfterDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterUpsert(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpdate(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpsert(plans, mapPlans);
            
            ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(planLineItemsnew1, mapPlanlineitems);
            
        }
        
        Test.stopTest();
        
    }    
 
    static testMethod void ASI_MFM_Plan_TriggerClass_SG_Test3() { //Test ASI_MFM_Currency__c =SGD
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map3 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(recordTypeId=rt_map3.get('ASI_MFM_SG_Prefix'), name='test1', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Default_Customer__c=acc2.id,ASI_MFM_Location__c = 'Singapore');
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), name='test',ASI_MFM_Status__c='Final',ASI_MFM_Plan_External_ID_Upload__c='1',
                                                ASI_MFM_End_Date__c=Date.today(), ASI_MFM_Plan_Description__c='testPlanDescription',  ASI_MFM_Prefix__c=px.id,
                                                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today());
        insert p;
        Test.startTest();
        System.debug(Limits.getDMLRows());
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
                                                                  ,recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand1;
 
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
 
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Plan__c=p.id,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi;
 
        Test.stopTest();
    } 
    
    
    static testMethod void ASI_MFM_Plan_TriggerClass_SG_Test2() {  //Test ASI_MFM_Currency__c =usd , when plan is final, can not update it
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map3 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(recordTypeId=rt_map3.get('ASI_MFM_SG_Prefix'), name='test1', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Default_Customer__c=acc2.id);
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), name='test',ASI_MFM_Status__c='Final',ASI_MFM_Plan_External_ID_Upload__c='1',
                                                ASI_MFM_End_Date__c=Date.today(), ASI_MFM_Plan_Description__c='testPlanDescription',  ASI_MFM_Prefix__c=px.id,
                                                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today());
        insert p;
        p.ASI_MFM_Status__c='Submitted';
        
        /*[WL 20180613]*/
        ASI_MFM_Plan__c p2 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), 
                                                name='test2',
                                                ASI_MFM_Status__c='Draft',
                                                ASI_MFM_Plan_External_ID_Upload__c='2',
                                                ASI_MFM_End_Date__c=Date.today(), 
                                                ASI_MFM_Plan_Description__c='testPlanDescription',  
                                                ASI_MFM_Prefix__c=px.id,
                                                ASI_MFM_Plan_Name__c='testPlan2', 
                                                ASI_MFM_Start_Date__c=Date.today(),
                                                ASI_MFM_cloned_plan_id__c = p.id);
        insert p2;
        delete p2;
        /*[WL 20180613]*/
        Test.startTest();
        System.debug(Limits.getDMLRows());
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
                                                                  ,recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Plan__c=p.id,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi;
        
        p.ASI_MFM_Status__c='Final';
        update p;
    
        Test.stopTest();
    } 
    
        static testMethod void testSGInputPlanItemsController() {
        // Test ASI_MFM_SG_InputPlanItemsController
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;       
        
        test.setCurrentPage(page.ASI_MFM_SG_InputPlanItemsPage);
        apexpages.currentPage().getParameters().put('id', p.id); 
        list<ASI_MFM_Plan__c> p_list = new list<ASI_MFM_Plan__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(p_list);  
        ASI_MFM_SG_InputPlanItemsController cx = new ASI_MFM_SG_InputPlanItemsController(sc);             
    }
    
   static testMethod void PlanSingleApproveTest_MassCreateAndUpdateSG() { 
        
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c'); 
        Map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        Map<string, id> rtt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Route_Type__c');
        
        //  user u = [SELECT ID, ASI_MFM_Country__c,userRole.developerName FROM user WHERE ID = : userinfo.getUserID()];
        //    u.ASI_MFM_Country__c ='SG';
        //   UserRole ur = [Select id,developerName from userrole where developername='ASI_SG_Asst_Sales_Manager_MOT'];
        //   system.debug(ur);
        //   u.UserRoleid=ur.id;
        //  update u;
      
        User thisUser = [ SELECT ID, ASI_MFM_Country__c,userRole.developerName FROM user WHERE ID = : userinfo.getUserID()];
            System.runAs ( thisUser ) {
            thisUser.ASI_MFM_Country__c ='SG';
            UserRole ur = [Select id,developerName from userrole where developername='ASI_SG_Asst_Sales_Manager_MOT'];
            thisUser.UserRoleid=ur.id;
            update thisUser;
        }
        user u = [SELECT ID, ASI_MFM_Country__c,userRole.developerName FROM user WHERE ID = : userinfo.getUserID()];
        //Set Plan Prefix
        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='SG',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form',ASI_MFM_Fiscal_year__c=getFiscalYear(),recordTypeId = pxrt_map.get('ASI_MFM_SG_Prefix'),ASI_MFM_Location__c='Singapore');
        insert prefix1 ;

        //ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,ASI_MFM_Role_Name__c =ur.developerName);  
        ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=prefix1.Id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert prefixChild1;
         
        ASI_MFM_Route_Type__c mrt = new ASI_MFM_Route_Type__c(Name='SG Plan Sales MOT', ASI_MFM_Module__c='Plan', recordTypeId = rtt_map.get('ASI_MFM_SG_Route_Type'));
        system.debug('rtt0:' + rtt_map.get('ASI_MFM_SG_Route_Type'));
        insert mrt;
        
        list<ASI_MFM_Route_Rule_Detail__c> rtd = new list<ASI_MFM_Route_Rule_Detail__c>();
        
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 0));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 1, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 1));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 2, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 2));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 3, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 3));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 4, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 4));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 5, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 5));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 6, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 6));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 7, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 7));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 8, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 8));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 9, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 9));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 10, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 10));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 10000, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 1));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 999));
        insert rtd;
        
        ASI_MFM_Brand_Route_Type_Map__c brtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Prefix__c = prefix1.id, ASI_MFM_Route_Type__c=mrt.id);
        insert brtm;
        
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        insert ac1;
        //Set Plan
        ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='SG131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c='Draft', OwnerId =u.id,ASI_MFM_Single_Approval__c = true);
        insert Plan1;
        
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<ASI_MFM_A_C_Code__c> AClist = new List<ASI_MFM_A_C_Code__c>();
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        AClist.add(ac);
        ASI_MFM_A_C_Code__c ac3 = new ASI_MFM_A_C_Code__c(name='testAC1', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Myanmar');
        AClist.add(ac3);
        insert AClist;
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        // Set plan Line Item
        list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                           ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1', ASI_MFM_Customer_Name__c = acc2.Id
                           ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                           ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                           ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                           ASI_MFM_A_C_Code__c=ac.id
                           ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                           ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2',  ASI_MFM_Customer_Name__c = acc2.Id
                           ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000, ASI_MFM_A_C_Code__c=ac3.id
                           ));
        
        insert planLineItems;
  
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(planLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_SG_InputPlanItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', Plan1.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPlanItemsController testCon = new ASI_MFM_SG_InputPlanItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=F&width=200px,ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_A_C_Code__c&req=T&width=160px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Remarks__c&req=F&width=240px, ASI_MFM_Total_Cost__c&req=F&width=105px, ASI_MFM_Month_1_Cost__c&req=F&width=80px, ASI_MFM_Month_2_Cost__c&req=F&width=80px, ASI_MFM_Month_3_Cost__c&req=F&width=80px, ASI_MFM_Month_4_Cost__c&req=F&width=80px, ASI_MFM_Month_5_Cost__c&req=F&width=80px, ASI_MFM_Month_6_Cost__c&req=F&width=80px, ASI_MFM_Month_7_Cost__c&req=F&width=80px, ASI_MFM_Month_8_Cost__c&req=F&width=80px, ASI_MFM_Month_9_Cost__c&req=F&width=80px, ASI_MFM_Month_10_Cost__c&req=F&width=80px, ASI_MFM_Month_11_Cost__c&req=F&width=80px, ASI_MFM_Month_12_Cost__c&req=F&width=80px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + Plan1.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + Plan1.Id;
        mcauCon.cancelLink = '/' + Plan1.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_Plan_Line_Item');
       
        mcauCon.commitAll();
        
    }
    
    static testMethod void testInputPlanItemMassCreateAndUpdateCA() { 
        user u = [SELECT ID, ASI_MFM_Country__c,userRole.developerName FROM user WHERE ID = : userinfo.getUserID()];
        //Set Plan Prefix
        
        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='SG',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form',
            ASI_MFM_Fiscal_year__c=getFiscalYear(),recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'),ASI_MFM_Location__c='Cambodia');
        insert prefix1 ;

        ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=prefix1.Id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert prefixChild1;

                
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        insert ac1;
        
        //Set Plan
        ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='SG131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c='Draft', OwnerId =u.id,ASI_MFM_Single_Approval__c = true);
        insert Plan1;
        
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        List<ASI_MFM_A_C_Code__c> AClist = new List<ASI_MFM_A_C_Code__c>();
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        AClist.add(ac);
        ASI_MFM_A_C_Code__c ac3 = new ASI_MFM_A_C_Code__c(name='testAC1', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Myanmar');
        AClist.add(ac3);
        insert AClist;
        
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        // Set plan Line Item
        list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                           ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1', ASI_MFM_Customer_Name__c = acc2.Id
                           ,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                           ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                           ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                           ASI_MFM_A_C_Code__c=ac.id
                           ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                           ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2',  ASI_MFM_Customer_Name__c = acc2.Id
                           ,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000, ASI_MFM_A_C_Code__c=ac3.id
                           ));
        
        insert planLineItems;
  
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(planLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_SG_InputPlanItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', Plan1.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPlanItemsController testCon = new ASI_MFM_SG_InputPlanItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=F&width=200px,ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_A_C_Code__c&req=T&width=160px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Remarks__c&req=F&width=240px, ASI_MFM_Total_Cost__c&req=F&width=105px, ASI_MFM_Month_1_Cost__c&req=F&width=80px, ASI_MFM_Month_2_Cost__c&req=F&width=80px, ASI_MFM_Month_3_Cost__c&req=F&width=80px, ASI_MFM_Month_4_Cost__c&req=F&width=80px, ASI_MFM_Month_5_Cost__c&req=F&width=80px, ASI_MFM_Month_6_Cost__c&req=F&width=80px, ASI_MFM_Month_7_Cost__c&req=F&width=80px, ASI_MFM_Month_8_Cost__c&req=F&width=80px, ASI_MFM_Month_9_Cost__c&req=F&width=80px, ASI_MFM_Month_10_Cost__c&req=F&width=80px, ASI_MFM_Month_11_Cost__c&req=F&width=80px, ASI_MFM_Month_12_Cost__c&req=F&width=80px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + Plan1.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + Plan1.Id;
        mcauCon.cancelLink = '/' + Plan1.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_Plan_Line_Item');
       
        mcauCon.commitAll();
        
    }
    
    static testMethod void testInputPlanItemMassCreateAndUpdateMM() { 
        user u = [SELECT ID, ASI_MFM_Country__c,userRole.developerName FROM user WHERE ID = : userinfo.getUserID()];
        //Set Plan Prefix
        
        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='SG',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form',
            ASI_MFM_Fiscal_year__c=getFiscalYear(),recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'),ASI_MFM_Location__c='Myanmar');
        insert prefix1 ;

        ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=prefix1.Id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert prefixChild1;

                
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        insert ac1;
        
        //Set Plan
        ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='SG131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c='Draft', OwnerId =u.id,ASI_MFM_Single_Approval__c = true);
        insert Plan1;
        
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        List<ASI_MFM_A_C_Code__c> AClist = new List<ASI_MFM_A_C_Code__c>();
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        AClist.add(ac);
        ASI_MFM_A_C_Code__c ac3 = new ASI_MFM_A_C_Code__c(name='testAC1', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Myanmar');
        AClist.add(ac3);
        insert AClist;
        
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        // Set plan Line Item
        list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                           ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1', ASI_MFM_Customer_Name__c = acc2.Id
                           ,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                           ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                           ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                           ASI_MFM_A_C_Code__c=ac.id
                           ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                           ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2',  ASI_MFM_Customer_Name__c = acc2.Id
                           ,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000, ASI_MFM_A_C_Code__c=ac3.id
                           ));
        
        insert planLineItems;
  
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(planLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_SG_InputPlanItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', Plan1.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPlanItemsController testCon = new ASI_MFM_SG_InputPlanItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=F&width=200px,ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_A_C_Code__c&req=T&width=160px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Remarks__c&req=F&width=240px, ASI_MFM_Total_Cost__c&req=F&width=105px, ASI_MFM_Month_1_Cost__c&req=F&width=80px, ASI_MFM_Month_2_Cost__c&req=F&width=80px, ASI_MFM_Month_3_Cost__c&req=F&width=80px, ASI_MFM_Month_4_Cost__c&req=F&width=80px, ASI_MFM_Month_5_Cost__c&req=F&width=80px, ASI_MFM_Month_6_Cost__c&req=F&width=80px, ASI_MFM_Month_7_Cost__c&req=F&width=80px, ASI_MFM_Month_8_Cost__c&req=F&width=80px, ASI_MFM_Month_9_Cost__c&req=F&width=80px, ASI_MFM_Month_10_Cost__c&req=F&width=80px, ASI_MFM_Month_11_Cost__c&req=F&width=80px, ASI_MFM_Month_12_Cost__c&req=F&width=80px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + Plan1.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + Plan1.Id;
        mcauCon.cancelLink = '/' + Plan1.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_Plan_Line_Item');
       
        mcauCon.commitAll();
        
    }
    
    static testMethod void testInputPlanItemMassCreateAndUpdateLA() { 
        user u = [SELECT ID, ASI_MFM_Country__c,userRole.developerName FROM user WHERE ID = : userinfo.getUserID()];
        //Set Plan Prefix
        
        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='SG',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form',
            ASI_MFM_Fiscal_year__c=getFiscalYear(),recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'),ASI_MFM_Location__c='Laos');
        insert prefix1 ;

        ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=prefix1.Id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert prefixChild1;

                
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        insert ac1;
        
        //Set Plan
        ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='SG131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c='Draft', OwnerId =u.id,ASI_MFM_Single_Approval__c = true);
        insert Plan1;
        
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        List<ASI_MFM_A_C_Code__c> AClist = new List<ASI_MFM_A_C_Code__c>();
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        AClist.add(ac);
        ASI_MFM_A_C_Code__c ac3 = new ASI_MFM_A_C_Code__c(name='testAC1', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Myanmar');
        AClist.add(ac3);
        insert AClist;
        
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        // Set plan Line Item
        list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                           ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1', ASI_MFM_Customer_Name__c = acc2.Id
                           ,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                           ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                           ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                           ASI_MFM_A_C_Code__c=ac.id
                           ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                           ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2',  ASI_MFM_Customer_Name__c = acc2.Id
                           ,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000, ASI_MFM_A_C_Code__c=ac3.id
                           ));
        
        insert planLineItems;
  
        list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(planLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_SG_InputPlanItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', Plan1.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPlanItemsController testCon = new ASI_MFM_SG_InputPlanItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=F&width=200px,ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_A_C_Code__c&req=T&width=160px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Remarks__c&req=F&width=240px, ASI_MFM_Total_Cost__c&req=F&width=105px, ASI_MFM_Month_1_Cost__c&req=F&width=80px, ASI_MFM_Month_2_Cost__c&req=F&width=80px, ASI_MFM_Month_3_Cost__c&req=F&width=80px, ASI_MFM_Month_4_Cost__c&req=F&width=80px, ASI_MFM_Month_5_Cost__c&req=F&width=80px, ASI_MFM_Month_6_Cost__c&req=F&width=80px, ASI_MFM_Month_7_Cost__c&req=F&width=80px, ASI_MFM_Month_8_Cost__c&req=F&width=80px, ASI_MFM_Month_9_Cost__c&req=F&width=80px, ASI_MFM_Month_10_Cost__c&req=F&width=80px, ASI_MFM_Month_11_Cost__c&req=F&width=80px, ASI_MFM_Month_12_Cost__c&req=F&width=80px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + Plan1.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + Plan1.Id;
        mcauCon.cancelLink = '/' + Plan1.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_Plan_Line_Item');
       
        mcauCon.commitAll();
        
    }
    
    static testMethod void ASI_MFM_Plan_TriggerClass_SG_TEST4() {
        // Test ASI_MFM_Plan_TriggerClass  AND   ASI_MFM_PlanLineItem_TriggerClass
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='SG';
        update user1;
                
        UserRole ur = [Select id from userrole where developername='ASI_SG_Asst_Sales_Manager_MOT'];
        Profile p = [select id from profile where name='ASI SG Standard User'];
        User u = new User(alias = 'standt', email='alan.wong@elufasys.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,ASI_MFM_Country__c ='SG',ASI_MFM_Bypass_Callouts__c = true, ASI_MFM_Team__c = 'NTMK', UserRoleid=ur.id,timezonesidkey='America/Los_Angeles', username='alan.wong@elufasys.com');
           // insert u;
            
        //user qiulei = [SELECT id from user where id = '005D000000251hg'];
            
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<string, id> po_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');   
        Map<string, id> rtt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Route_Type__c');  
        //Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
        //Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c');
        //Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
             
             ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='SG',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form',ASI_MFM_Fiscal_year__c=getFiscalYear(),ownerId = user1.id, ASI_MFM_Department__c='SG Brand Marketing');
            insert prefix1 ;
             
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,ASI_MFM_Role_Name__c =u.userRole.developerName);            
            insert prefixChild1;

            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            insert prefixChild2;
            
            ASI_MFM_Route_Type__c mrt = new ASI_MFM_Route_Type__c(Name='SG Plan Sales MOT', ASI_MFM_Module__c='Plan', recordTypeId = rtt_map.get('ASI_MFM_SG_Route_Type'));
            system.debug('rtt0:' + rtt_map.get('ASI_MFM_SG_Route_Type'));
            insert mrt;
            
            list<ASI_MFM_Route_Rule_Detail__c> rtd = new list<ASI_MFM_Route_Rule_Detail__c>();
            
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 0));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 1, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 1));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 2, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 2));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 3, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 3));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 4, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 4));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 5, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 5));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 6, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 6));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 7, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 7));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 8, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 8));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 9, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 9));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 10, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 10));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 10000, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 1));
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 999));
            insert rtd;
            
            ASI_MFM_Brand_Route_Type_Map__c brtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Prefix__c = prefix1.id, ASI_MFM_Route_Type__c=mrt.id);
            insert brtm;
                                    
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            insert ac1;

            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            insert ac2;
            

            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='SG131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, ASI_MFM_Status__c='Draft', OwnerId =user1.id, ASI_MFM_Single_Approval__c= true);
            insert Plan1;
        
            ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='SG132',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan2;

            
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'), ownerid=user1.id);
            insert subBrand1;
            
            ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'), ownerid=user1.id);
            insert subBrand2;
            
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'));
            insert ac;
            
            Account acc2 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Outlet'),Name='Name3');           
            insert acc2;
            
            // Add 3 plan Line Item
            list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
            planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            ));

            planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand2.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
            ASI_MFM_A_C_Code__c=ac.id
            ));
            
            planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            ));
        

        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            ));
        
        insert planLineItems;
        
        list<ASI_MFM_Plan__c> plans = new list<ASI_MFM_Plan__c>();
        plans.add(Plan1);
        Plan1.ASI_MFM_Cloned_Plan_ID__c = Plan2.Id;
        Plan2.Id = Plan1.Id;
        
        map<Id, ASI_MFM_Plan__c> mapPlans = new map<Id, ASI_MFM_Plan__c>();
        mapPlans.put(Plan2.Id, Plan2);
        
        //------------------------------Plan line Items-------------------------------
        ASI_MFM_Plan_Line_Item__c planLineItems1= new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello133'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id);

        ASI_MFM_Plan_Line_Item__c planLineItems2= new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello144'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id);
        planLineItems2.Id=planLineItems1.Id;


        list<ASI_MFM_Plan_Line_Item__c> planLineItemsnew1 = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineItemsnew1.add(planLineItems1);

        map<Id,ASI_MFM_Plan_Line_Item__c>mapPlanlineitems =new map<Id, ASI_MFM_Plan_Line_Item__c>();
        mapPlanlineitems.put(planLineItems2.Id,planLineItems2);
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        System.runAs(user1){
            ASI_MFM_Plan_TriggerClass.routineAfterDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterUpsert(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpdate(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpsert(plans, mapPlans);
            
            ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(planLineItemsnew1, mapPlanlineitems);
            
        }

        Test.stopTest();
            
    }


}