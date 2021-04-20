@isTest
private class ASI_MFM_HK_TestClass_DL {
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
    
    static testMethod void ASI_MFM_GenerateBudgetController_Test(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(
            RecordTypeId=rt_map.get('ASI_MFM_HK_Plan'), 
            Name='test',
            ASI_MFM_End_Date__c=Date.today(),
            ASI_MFM_Plan_Description__c='testPlanDescription',
            ASI_MFM_Prefix__c=px.id,
            ASI_MFM_Plan_Name__c='testPlan',
            ASI_MFM_Start_Date__c=Date.today()
        );
        insert plan;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(
            Name='subBrand1',
            RecordTypeId=subBrandCode_map.get('ASI_HK_CRM_Sub_brand')
        );
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');   
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_HK_CRM_Outlet'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(
            RecordTypeId=rt_map.get('ASI_MFM_HK_Plan_Line_Item'), 
            ASI_MFM_Plan__c=plan.id,
            ASI_MFM_Sub_brand_Code__c = subBrand1.id,
            ASI_MFM_A_C_Code__c=ac.id, 
            ASI_MFM_Customer_Name__c=acc2.id, 
            ASI_MFM_List_Item_Description__c='testDescription'
        );
        insert pi;          
        
        System.runAs(u) {
            test.startTest();
            
    
            list<ASI_MFM_budget__c> b_list = new list<ASI_MFM_budget__c>{new ASI_MFM_budget__c()};
            apexpages.standardSetController sc = new apexpages.standardSetController(b_list);
            ASI_MFM_GenerateBudgetController cx = new ASI_MFM_GenerateBudgetController(sc);
            cx.selected = new ASI_MFM_budget__c(ASI_MFM_fiscal_year__c=getFiscalYear());
            pi = [select recordType.developerName from ASI_MFM_Plan_Line_Item__c where id = :pi.id];
            u.ASI_MFM_Country__c = pi.recordType.developerName.substring(8,10);
            update u;       
            cx.selected_prefix = px.id;
            cx.proceed(); 
            cx.redirect();
            
            test.stopTest();
        }
    }
    
    static testMethod void ASI_MFM_GenerateBudgetController_TestTR(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TR';
        update u;

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(
            RecordTypeId=rt_map.get('ASI_MFM_HK_Plan'), 
            Name='test',
            ASI_MFM_End_Date__c=Date.today(),
            ASI_MFM_Plan_Description__c='testPlanDescription',
            ASI_MFM_Prefix__c=px.id,
            ASI_MFM_Plan_Name__c='testPlan',
            ASI_MFM_Start_Date__c=Date.today()
        );
        insert plan;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(
            Name='subBrand1',
            RecordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand')
        );
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');   
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_HK_CRM_Outlet'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(
            RecordTypeId=rt_map.get('ASI_MFM_HK_Plan_Line_Item'), 
            ASI_MFM_Plan__c=plan.id,
            ASI_MFM_Sub_brand_Code__c = subBrand1.id,
            ASI_MFM_A_C_Code__c=ac.id, 
            ASI_MFM_Customer_Name__c=acc2.id, 
            ASI_MFM_List_Item_Description__c='testDescription'
        );
        insert pi;          
        
        System.runAs(u) {
            test.startTest();
            
            list<ASI_MFM_budget__c> b_list = new list<ASI_MFM_budget__c>{new ASI_MFM_budget__c()};
            apexpages.standardSetController sc = new apexpages.standardSetController(b_list);
            ASI_MFM_GenerateBudgetController cx = new ASI_MFM_GenerateBudgetController(sc);
            cx.selected = new ASI_MFM_budget__c(ASI_MFM_fiscal_year__c=getFiscalYear());
            pi = [select recordType.developerName from ASI_MFM_Plan_Line_Item__c where id = :pi.id];
            u.ASI_MFM_Country__c = pi.recordType.developerName.substring(8,10);
            update u;       
            cx.selected_prefix = px.id;
            cx.proceed(); 
            cx.redirect();
            
            test.stopTest();
        }
    }
    
    static testMethod void testHKGenPOItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        List<Account> accList = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3');           
        accList.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'), Name='Name2');           
        accList.add(acc1);
        insert accList;
        
        
            test.startTest();
            
            ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
            insert pi;  
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    
            insert pro;  
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id); 
            insert po;
            
            apexpages.standardController sc = new apexpages.standardController(po);
            ASI_MFM_HK_GenPOItemsController cx= new ASI_MFM_HK_GenPOItemsController(sc);
            pageReference pg = page.ASI_MFM_GenPOItemsPage;
            test.setCurrentPage(pg);  
            apexpages.currentPage().getParameters().put('mode', 'Full'); 
            cx.genPOItems();    
            test.stopTest();
        
    }    

    static testMethod void testHKInputPlanItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;       
        
        test.setCurrentPage(page.ASI_MFM_HK_InputPlanItemsPage);
        apexpages.currentPage().getParameters().put('id', p.id); 
        list<ASI_MFM_Plan__c> p_list = new list<ASI_MFM_Plan__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(p_list);  
        ASI_MFM_HK_InputPlanItemsController cx = new ASI_MFM_HK_InputPlanItemsController(sc);             
    }

    static testMethod void testHKInputPOItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Exchange_Rate__c=1);
        insert po;  
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Amount__c=100.00);
        insert poi;    
        
        test.startTest();

        test.setCurrentPage(page.ASI_MFM_HK_InputPOItemsPage);
        apexpages.currentPage().getParameters().put('id', po.id); 
        list<ASI_MFM_PO__c> po_list = new list<ASI_MFM_PO__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(po_list);  
        ASI_MFM_HK_InputPOItemsController cx = new ASI_MFM_HK_InputPOItemsController(sc);  
        cx.save();
        cx.quickSave();         
        cx.onCommitted();
        cx.APPLY();
        cx.DELETESELECTED();
        cx.CLONESELECTED();
        cx.ADDNEW();
        cx.cacnel();
        cx.Beginning();
        cx.Previous();
        cx.Next();
        cx.End();
        List<String> results = new List<String>();
        results = ASI_MFM_HK_InputPOItemsController.findSObjects('ASI_MFM_PO_Line_Item__c', ' where ASI_MFM_PO__c != null');
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Spread_by_Months__c&req=F&width=40px, ASI_MFM_Sub_brand_Code__c&req=T&width=240px, ASI_MFM_A_C_Code__c&req=T&width=160px,  ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Amount__c&req=F&width=80px, ASI_MFM_PO_Percentage__c&req=F&width=35px, ASI_MFM_G_L_Date__c&req=T&width=75px, ASI_MFM_Invoice_Number__c&req=F&width=120px';        
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'POLine Items';
        mcauCon.successLink = '/' + po.Id;
        mcauCon.cancelLink = '/' + po.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        
        mcauCon.init();
        mcauCon.commitAll();
        test.stopTest();
    }
        
    static testMethod void testHKPlanTrigger1() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
                
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert subBrand1;
        
        test.startTest();
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
            ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName');
        insert p1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p1.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi;
        
        p1 = [select recordTypeId, ASI_MFM_Cloned_Plan_ID__c, ASI_MFM_Prefix__c,ASI_MFM_End_Date__c, ASI_MFM_Plan_Description__c, ASI_MFM_Plan_Name__c, ASI_MFM_Start_Date__c from ASI_MFM_Plan__c where id = :p1.id];
            
        ASI_MFM_Plan__c p2 = p1.clone(false, true);
        insert p2;
        test.stopTest();
    }
    static testMethod void testHKPlanTrigger2() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
            ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName');
        insert p1;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3');                   
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p1.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi;
        delete pi;
        delete p1;
        test.stopTest();
    }
        
    static testMethod void testPOTrigger1() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
            ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdV= new List<ASI_MFM_Route_Rule_Detail__c>();
        for(integer i=0;i<8;i++){
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=i, ASI_MFM_Route_Type__c=rt.id);
            rrdV.add(rrd);
        }
        
        insert rrdV;
        
        test.startTest();
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2), ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Exchange_Rate__c=1);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Amount__c=100.00);
        insert poi;
        
        poi.ASI_MFM_Complete__c=true;
        poi.ASI_MFM_List_Item_Description__c='testDescription2';
        
        //update poi;
        
        test.stopTest();
    }
      
    static testMethod void testHKPOTrigger2() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
            ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;

        List<ASI_MFM_Route_Rule_Detail__c> rrdV= new List<ASI_MFM_Route_Rule_Detail__c>();
        for(integer i=0;i<8;i++){
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=(i*-1), ASI_MFM_Route_Type__c=rt.id);
            rrdV.add(rrd);
        }
        
        insert rrdV;
        
        list<Account> accList = new list<Account>(); 
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');    
        accList.add(acc2);
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        insert accList;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(name='testBU', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_HK_BU'));
        insert bu;
    
        test.startTest(); 
        List<ASI_MFM_PO__c> poList = new List<ASI_MFM_PO__c>();
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='HKD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Exchange_Rate__c=5);
            
            
        
        poList.add(po);
        //insert po; //20171027 Introv
                
        ASI_MFM_PO__c po2 = po.clone(false, true);
        poList.add(po2);//20171027 Introv
        
        //insert po2;//20171027 Introv
        insert poList;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c=100.00, 
                                                                  ASI_MFM_Spread_by_Months__c=true, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        //insert poi;//20171027 Introv
        insert poi;
        
        po2.ASI_MFM_Original_PO_for_Adjustment__c = po.id;
        
        po2.ASI_MFM_Status__c = 'Final';
        update po2;
        
        po2.ASI_MFM_Status__c = 'Draft';
        update po2;
                      
        test.stopTest();
    }
           
    static testMethod void testHKPOTrigger3() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_HK_BU'), Name = 'HK_BU');
        insert bu;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_HK_Prefix'), ASI_MFM_Default_BU__c = bu.id);
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdV= new List<ASI_MFM_Route_Rule_Detail__c>();
        for(integer i=0;i<8;i++){
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=i, ASI_MFM_Route_Type__c=rt.id);
            rrdV.add(rrd);
        }
        
        insert rrdV;
        
        list<Account> accList = new list<Account>(); 
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');    
        accList.add(acc2);
        
        Insert accList;
        test.startTest();
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Exchange_Rate__c=1);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c=100.00,
            ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        delete poi;
        
        test.stopTest();
    }
    
    static testMethod void testHKPOTrigger4() { // Currency popluation Test
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr; 
        
        ASI_MFM_Exchange_Rate__c xr2 = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',
            ASI_MFM_Counter_Currency__c='EUR', ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=2.34);
        insert xr2;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_HK_BU'), Name = 'HK_BU');
        insert bu;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_HK_Prefix'), ASI_MFM_Default_BU__c = bu.id);
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdV=new List<ASI_MFM_Route_Rule_Detail__c>();
        
        for(integer i=0;i<8;i++){
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=i, ASI_MFM_Route_Type__c=rt.id);
            rrdV.add(rrd);
        }
        
        insert rrdV;
        
        list<Account> accList = new list<Account>(); 
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');    
        accList.add(acc2);
        
        Insert accList;
        
        test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Exchange_Rate__c=1);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c=100.00,
            ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        po.ASI_MFM_Exchange_Rate__c = null; 
        po.ASI_MFM_Currency__c='EUR';
        update po;
        test.stopTest();
    }
    
    static testMethod void testHKPOTrigger5() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_HK_BU'), Name = 'HK_BU');
        insert bu;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_HK_Prefix'), ASI_MFM_Default_BU__c = bu.id);
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdV= new List<ASI_MFM_Route_Rule_Detail__c>();
        for(integer i=0;i<8;i++){
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=i, ASI_MFM_Route_Type__c=rt.id);
            rrdV.add(rrd);
        }
        
        insert rrdV;
        
        list<Account> accList = new list<Account>(); 
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');    
        accList.add(acc2);
        
        Insert accList;
        test.startTest();
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
                
        delete po;
        test.stopTest();
    }
    
    static testMethod void testPOStatusController_HK(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;  
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1
            );
        insert poi;
        
        po.ASI_MFM_Status__c = 'Final';
        update po;
        
        Test.startTest();
        
        
        //PageReference myVfPage = Page.ASI_MFM_SetPOStatusPage;
        //Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        //ApexPages.currentPage().getParameters().put('status','Voided');
        ApexPages.currentPage().getParameters().put('status','Voided');
        ASI_MFM_SetPOStatusController ext = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        //ext.new_status = 'Voided';
        ext.setStatus();
        
        test.stopTest(); 
    }
    
    static testMethod void testPOStatusController_HK2(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;  
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1
            );
        insert poi;
        
        po.ASI_MFM_Status__c = 'Final';
        update po;
        
        Test.startTest();
        
        
        //PageReference myVfPage = Page.ASI_MFM_SetPOStatusPage;
        //Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        //ApexPages.currentPage().getParameters().put('status','Voided');
        ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), ASI_MFM_Status__c = 'Submitted', name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Original_PO_for_Adjustment__c = po.id);
        insert po2; 
        
        ApexPages.currentPage().getParameters().put('status','Voided');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        //ext.new_status = 'Voided';
        ext2.setStatus();
        
        test.stopTest(); 
    }
    
    static testMethod void testPOStatusController_HK_Complete(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;  
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        Id polineId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item');
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = polineId, ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1
            );
        insert poi;
        
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = polineId, ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1, ASI_MFM_Synced__c = true
            );
        //insert poi2;
        
        po.ASI_MFM_Invoice_Amount_from_JDE__c = 10;
        po.ASI_MFM_Status__c = 'Final';
        update po;
        
        Test.startTest();
        
        //PageReference myVfPage = Page.ASI_MFM_SetPOStatusPage;
        //Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        //ApexPages.currentPage().getParameters().put('status','Voided');
        //ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), ASI_MFM_Status__c = 'Submitted', name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Original_PO_for_Adjustment__c = po.id);
        //insert po2; 
        
        //ApexPages.currentPage().getParameters().put('status','Voided');
        ASI_MFM_POSetCompleteController ext2 = new ASI_MFM_POSetCompleteController(new ApexPages.StandardController(po));
        //ext.new_status = 'Voided';
        ext2.doComplete();
        List<ASI_MFM_PO_Line_Item__c> poList = new List<ASI_MFM_PO_Line_Item__c>();
        poList.add(poi);
        ext2.doComplete();
        ext2.getHistoryItem(poList);
        ext2.cloneHistoryItem(poList);
        
        test.stopTest(); 
    }
    
    static testMethod void testPOStatusController_HK_Complete2(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Inv_Amount_from_JDE_less_TnE__c = 9999999, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;  
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        Id polineId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item');
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = polineId, ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1
            );
        //insert poi;
        
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = polineId, ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1, ASI_MFM_Synced__c = true, ASI_MFM_Base_Currency_Amount__c = 123
            );
        insert poi2;
        
        po.ASI_MFM_Invoice_Amount_from_JDE__c = 100;
        po.ASI_MFM_T_E_Amount__c = 991;
        po.ASI_MFM_Status__c = 'Final';
        update po;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert pxa; 
        
        System.debug('********14.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        
        insert pra;  
        
        Test.startTest();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(ASI_MFM_Status__c = 'Submitted', recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_HK_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc1.id);
        insert py;
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_HK_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=1000, ASI_MFM_PO_Line_Item__c=poi2.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       

        insert pyi;
        
        py.ASI_MFM_Status__c = 'Final';
        //update py;
        
        
        //PageReference myVfPage = Page.ASI_MFM_SetPOStatusPage;
        //Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        //ApexPages.currentPage().getParameters().put('status','Voided');
        //ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), ASI_MFM_Status__c = 'Submitted', name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Original_PO_for_Adjustment__c = po.id);
        //insert po2; 
        
        //ApexPages.currentPage().getParameters().put('status','Voided');
        ASI_MFM_POSetCompleteController ext2 = new ASI_MFM_POSetCompleteController(new ApexPages.StandardController(po));
        //ext.new_status = 'Voided';
        //
        List<ASI_MFM_PO_Line_Item__c> poList = new List<ASI_MFM_PO_Line_Item__c>();
        poList.add(poi2);
        poList[0].ASI_MFM_Base_Currency_Amount__c = 123;
        //update poList;
        ext2.doComplete();
        ext2.getLineItem(po.id);
        ext2.getHistoryItem(poList);
        
        ext2.historyAmount = 1000;
        poList[0].ASI_MFM_Base_Currency_Amount__c = 10;
        
        ext2.invoiceAmount = 100;
        ext2.cloneHistoryItem(poList);
        poList[0].ASI_MFM_G_L_Date__c = date.today().addMonths(10);
        ext2.getFutureItem(poList);
        poList[0].ASI_MFM_G_L_Date__c = date.today();
        ext2.cloneHistoryItem(poList);
        
        test.stopTest(); 
    }
}