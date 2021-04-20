@isTest
private class ASI_MFM_TestClass_DL {

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

    static testMethod void testGenerateBudgetController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription',  ASI_MFM_Prefix__c=px.id,
        ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today());
        insert p;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');   
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', 
                ASI_MFM_Total_Cost__c = 1000);
        insert pi;          
        list<ASI_MFM_budget__c> b_list = new list<ASI_MFM_budget__c>{new ASI_MFM_budget__c()};
        apexpages.standardSetController sc = new apexpages.standardSetController(b_list);
        ASI_MFM_GenerateBudgetController cx = new ASI_MFM_GenerateBudgetController(sc);
        cx.selected = new ASI_MFM_budget__c(ASI_MFM_fiscal_year__c='FY1213');
        pi = [select recordType.developerName from ASI_MFM_Plan_Line_Item__c where id = :pi.id];
        u.ASI_MFM_Country__c = pi.recordType.developerName.substring(8,10);
        update u;       
        cx.proceed();
    }
    
    static testMethod void testGenPOItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(
            recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), 
            name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription', 
            ASI_MFM_Plan_Name__c='testPlan', 
            ASI_MFM_Start_Date__c=Date.today(), 
            ASI_MFM_Prefix__c=px.id, 
            ASI_MFM_Status__c = 'Final');

        insert p;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');    
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');   
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        test.startTest();
        List<Account> accToInsert = new List<Account>();
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Customer'),Name='Name3');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', 
                ASI_MFM_Total_Cost__c = 1000);   
        insert pi;  

        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');   
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        apexpages.standardController sc = new apexpages.standardController(po);
        ASI_MFM_GenPOItemsController cx= new ASI_MFM_GenPOItemsController(sc);
        pageReference pg = page.ASI_MFM_GenPOItemsPage;
        test.setCurrentPage(pg);  
        apexpages.currentPage().getParameters().put('mode', 'Full'); 
        cx.genPOItems();
        test.stopTest();
    }    

    static testMethod void testInputPlanItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
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

    static testMethod void testInputPOItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;   
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map2.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id,
        ASI_MFM_Status__c = 'Final');
        insert p; 
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        insert acc1;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');   
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, 
        ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;      
        test.setCurrentPage(page.ASI_MFM_InputPOItemsPage);
        apexpages.currentPage().getParameters().put('id', po.id); 
        list<ASI_MFM_PO__c> po_list = new list<ASI_MFM_PO__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(po_list);  
        ASI_MFM_InputPOItemsController cx = new ASI_MFM_InputPOItemsController(sc);             
        
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Spread_by_Months__c&req=F&width=40px, ASI_MFM_Sub_brand_Code__c&req=T&width=240px, ASI_MFM_SKU_Code__c&req=F&width=60px, ASI_MFM_A_C_Code__c&req=T&width=160px,  ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_GnH_Recipient_Name__c&req=F&width=120px, ASI_MFM_List_Item_Description__c&req=F&width=120px, ASI_MFM_Quantity__c&req=F&width=50px, ASI_MFM_UOM__c&req=F&width=55px, ASI_MFM_Unit_Price__c&req=F&width=60px, ASI_MFM_Amount__c&req=F&width=80px, ASI_MFM_PO_Percentage__c&req=F&width=35px, ASI_MFM_G_L_Date__c&req=T&width=75px, ASI_MFM_Pay_Acc__c&req=F&width=80px, ASI_MFM_Print_Sequence__c&req=F&width=80px';       
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'PO Line Items';
        mcauCon.successLink = '/' + po.Id;
        mcauCon.cancelLink = '/' + po.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        //Boolean initPageBool = mcauCon.dummyVar;

        mcauCon.init();
        mcauCon.commitAll();
    }
        
    static testMethod void testPlanTrigger1() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
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
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert subBrand1;
        
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName');
        insert p1;
        test.startTest();
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p1.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', 
                ASI_MFM_Total_Cost__c = 1000);
        insert pi;
        p1 = [select recordTypeId, ASI_MFM_Cloned_Plan_ID__c, ASI_MFM_Prefix__c,ASI_MFM_End_Date__c, ASI_MFM_Plan_Description__c, ASI_MFM_Plan_Name__c, ASI_MFM_Start_Date__c
        from ASI_MFM_Plan__c where id = :p1.id];
        ASI_MFM_Plan__c p2 = p1.clone(false, true);
        insert p2;
        test.stopTest();
    }
    static testMethod void testPlanTrigger2() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
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
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName');
        insert p1;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TW_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi =new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=p1.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', 
                ASI_MFM_Total_Cost__c = 1000);
        insert pi;
        delete pi;
        
        system.debug('Plan Record Type ID: ' + p1.recordTypeId);
        delete p1;
        test.stopTest();
    }
        
    static testMethod void testPOTrigger1() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
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
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        List<Account> accToInsert = new List<Account>();
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Customer'),Name='Name3');           
        accToInsert.add(acc2);
        
        insert accToInsert;
        
        test.startTest();

        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;

        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        test.stopTest();
    }
        
    static testMethod void testPOTrigger2() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;        
         
        List<ASI_MFM_Prefix__c> pxList = new List<ASI_MFM_Prefix__c>(); 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        pxList.add(px);
        ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        pxList.add(px1);
        
        insert pxList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(pr1);
        
        insert prList;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
         ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;


        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px1.id);
        insert rtm;
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account'); 
        list<Account> accList = new list<Account>(); 
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Customer'),Name='Name3');
        accList.add(acc2);
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        insert accList;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
 
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert sub;
 
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), ASI_MFM_Prefix__c=px1.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),ASI_MFM_Supplier_Name__c = acc1.id);

        insert po;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;    
        test.stopTest();
        //po = [select recordTypeId, ASI_MFM_Cloned_PO_ID__c, ASI_MFM_Prefix__c, ASI_MFM_Plan__c, ASI_MFM_Supplier_Name__c from ASI_MFM_PO__c where id = :po.id];
        ASI_MFM_PO__c po2 = po.clone(false, true);
        insert po2;
    }
          
    static testMethod void testPOTrigger3() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
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
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
         
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Customer'),Name='Name3');           
        accList.add(acc2);
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        Insert accList;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,
        ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        test.startTest();
        delete poi;
        delete po;
        test.stopTest();
    }
     
    static testMethod void testPOTrigger4() {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
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
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        insert acc1;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        delete po;
        test.stopTest();
    }
                
    static testMethod void testPaymentTrigger1() {
        user user = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c, ASI_MFM_Department__c, ASI_Department__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];

        user.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';

        update user;                                                                           
        
        System.runAs(user) {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
        
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.Department = 'Sales (Domestic & International Markets)';
        update u;
         
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        List<Account> accToInsert = new List<Account>();
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Customer'),Name='Name3');           
        accToInsert.add(acc2);
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name3');           
        accToInsert.add(acc3);
        
        Insert accToInsert;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,
        ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        test.startTest();
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TW_Payment'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Payment_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id);
        insert py;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
        pyi.ASI_MFM_Invoice_Number__c = 'test';
        update pyi;
        test.stopTest();    
        }
    }    
        
    static testMethod void testPaymentTrigger2() {
        user user = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c, ASI_MFM_Department__c, ASI_Department__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];

        user.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';

        update user;                                                                           
        
        System.runAs(user) {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.Department = 'Sales (Domestic & International Markets)';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        List<Account> accToInsert = new List<Account>();
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Customer'),Name='Name3');           
        accToInsert.add(acc2);
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name3');           
        accToInsert.add(acc3);
        
        Insert accToInsert;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');   
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD',ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,
        ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;

        test.startTest();
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TW_Payment'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Payment_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_Payment_Amount__c=100, ASI_MFM_Supplier_Name__c = acc3.id);
        insert py;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Payment_Line_Item'), 
        ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;

        delete py;  
        test.stopTest();    
        }
    }
    
    static testMethod void testSelectPlanPrefixController() {
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c();
        apexpages.standardController sc = new apexpages.standardController(p);
        ASI_MFM_SelectPlanPrefixController cx = new ASI_MFM_SelectPlanPrefixController(sc);
        cx.getPrefixes();
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        cx.getPrefixes();
        cx.proceed();
        cx.selected_prefix = null;
        cx.proceed();
    }

    static testMethod void testSelectPOPrefixController() {

        //map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');  
        //ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test', 
        //ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='planDescription', 
        //ASI_MFM_Plan_Name__c='planTestName', ASI_MFM_Start_Date__c=Date.today());
        //insert p;

        pageReference pg = page.ASI_MFM_SelectPOPrefixPage;
        test.setCurrentPage(pg);
//        apexpages.currentPage().getParameters().put('pid', p.id);  
        ASI_MFM_PO__c po = new ASI_MFM_PO__c();
        apexpages.standardController sc = new apexpages.standardController(po);
        ASI_MFM_SelectPOPrefixController cx = new ASI_MFM_SelectPOPrefixController(sc);         
        cx.getPrefixes();
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        cx.getPrefixes();
        cx.selected_prefix = null;
        cx.proceed();
    }    

    static testMethod void testSelectPaymentPrefixController() {
        user user = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c, ASI_MFM_Department__c, ASI_Department__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];

        user.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';

        update user;                                                                           
        
        System.runAs(user) {
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c();
        apexpages.standardController sc = new apexpages.standardController(py);
        ASI_MFM_SelectPaymentPrefixController cx = new ASI_MFM_SelectPaymentPrefixController(sc);           
        cx.getPrefixes();
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        cx.getPrefixes();
        cx.selected_prefix = null;
        cx.proceed();
        }
    } 

    static testMethod void testSubmitPlanController() {  
        user user = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c, ASI_MFM_Department__c, ASI_Department__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];

        user.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';

        update user;                                                                           
        
        System.runAs(user) {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');         
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test', ASI_MFM_Prefix__c=px.id,
        ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
        ASI_MFM_Plan_Name__c='testPlanName', ASI_MFM_Start_Date__c=Date.today());
        insert p;
        apexpages.standardController sc = new apexpages.standardController(p);
        ASI_MFM_SubmitPlanController cx = new ASI_MFM_SubmitPlanController(sc);
        cx.genPDF();    
        }            
    }
    
    static testMethod void testSetPlanStatusController() {
        user user = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c, ASI_MFM_Department__c, ASI_Department__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];

        user.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';

        update user;                                                                           
        
        System.runAs(user) {
        Test.setCurrentPage(Page.ASI_MFM_PlanDetailPage);
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode');
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test2',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id);
        insert p1;
        
        Test.startTest();        
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p));
        ext.setStatus();
        ASI_MFM_SetPlanStatusController ext2 = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p1));
        ext2.setStatus();
        test.stopTest(); 
        }
    }
    
    static testMethod void testPOStatusController () {
        user user = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c, ASI_MFM_Department__c, ASI_Department__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];

        user.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';

        update user;                                                                           
        
        System.runAs(user) {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');  
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;  
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test',
        ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
        ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;

        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        insert acc1;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                       
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        Test.startTest();        
        ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), name='test2', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c  = 'Final'); 
        insert po2;
        ASI_MFM_SetPOStatusController ext = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext.setStatus();
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po2));
        ext2.setStatus();
        
        test.stopTest(); 
        }
    }

    static testMethod void testPaymentApprovers()
    {
        user user = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c, ASI_MFM_Department__c, ASI_Department__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];

        user.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';

        update user;                                                                           
        
        System.runAs(user) {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c = 'Mixed Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        List<Account> accToInsert = new List<Account>();
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Customer'),Name='Name3');           
        accToInsert.add(acc2);
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name3');           
        accToInsert.add(acc3);
        
        Insert accToInsert;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');   
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD',ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,
        ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', Plan_Type__c = 'Mixed Plan');
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;

        map<string, id> rt_MFMDynamicRouteMap = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Dynamic_Approval_Route__c');
        Id usrManangerId = [Select Id, ManagerId From User where id =: UserInfo.getUserId()].ManagerId;      
        ASI_MFM_Dynamic_Approval_Route__c MFMDynamicRoute = new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_User__c = usrManangerId, ASI_MFM_Approval_Limit__c = 10000, ASI_MFM_End_of_1st_Route__c = true, ASI_MFM_Skip_to_Next_Level__c = false, ASI_MFM_Inactive__c = false, RecordTypeId = rt_MFMDynamicRouteMap.get('ASI_MFM_TW_Dynamic_Approval_Route'));
        insert MFMDynamicRoute; 

        map<string, id> rt_MFMFixRouteMap = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Fix_Approval_Route__c');        
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute1 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'Sales', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute2 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'TMKT', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute3 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'MKT', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute4 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'FIN', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute5 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'OP', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        List<ASI_MFM_Fix_Approval_Route__c> MFMFixRouteList = new List<ASI_MFM_Fix_Approval_Route__c>();
        MFMFixRouteList.add(MFMFixRoute1);
        MFMFixRouteList.add(MFMFixRoute2);
        MFMFixRouteList.add(MFMFixRoute3);
        MFMFixRouteList.add(MFMFixRoute4);
        MFMFixRouteList.add(MFMFixRoute5);
        insert MFMFixRouteList;   
        test.startTest();

        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TW_Payment'), ASI_MFM_Plan__c = p1.Id,ASI_MFM_Prefix__c=px.id, ASI_MFM_Payment_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_Payment_Amount__c=100000000, ASI_MFM_Supplier_Name__c = acc3.id);
        insert py;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Payment_Line_Item'), 
        ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
        
        test.stopTest();
        }
    }

    static testMethod void testPaymentApprovers2()
    {
        user user = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c, ASI_MFM_Department__c, ASI_Department__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];

        user.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';

        update user;                                                                           
        
        System.runAs(user) {
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
            ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c = 'Mixed Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        List<Account> accToInsert = new List<Account>();
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Customer'),Name='Name3');           
        accToInsert.add(acc2);
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TW_Supplier'),Name='Name3');           
        accToInsert.add(acc3);
        
        Insert accToInsert;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');   
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='USD',ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1'
        ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,
        ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', Plan_Type__c = 'Mixed Plan');
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;

        map<string, id> rt_MFMDynamicRouteMap = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Dynamic_Approval_Route__c');
        Id usrManangerId = [Select Id, ManagerId From User where id =: UserInfo.getUserId()].ManagerId;      
        ASI_MFM_Dynamic_Approval_Route__c MFMDynamicRoute = new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_User__c = usrManangerId, ASI_MFM_Approval_Limit__c = 10000, ASI_MFM_End_of_1st_Route__c = true, ASI_MFM_Skip_to_Next_Level__c = false, ASI_MFM_Inactive__c = false, RecordTypeId = rt_MFMDynamicRouteMap.get('ASI_MFM_TW_Dynamic_Approval_Route'));
        insert MFMDynamicRoute; 

        map<string, id> rt_MFMFixRouteMap = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Fix_Approval_Route__c');        
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute1 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'Sales', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute2 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'TMKT', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute3 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'MKT', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute4 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'FIN', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        ASI_MFM_Fix_Approval_Route__c MFMFixRoute5 = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Department__c = 'OP', ASI_MFM_Marketing_Director__c = UserInfo.getUserId(), ASI_MFM_Finance__c = UserInfo.getUserId(),  ASI_MFM_Corporate_Approver_1__c = UserInfo.getUserId(), ASI_MFM_Corporate_Approver_2__c = UserInfo.getUserId(), ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 10000, RecordTypeId = rt_MFMFixRouteMap.get('ASI_MFM_TW_Fix_Approval_Route'));
        List<ASI_MFM_Fix_Approval_Route__c> MFMFixRouteList = new List<ASI_MFM_Fix_Approval_Route__c>();
        MFMFixRouteList.add(MFMFixRoute1);
        MFMFixRouteList.add(MFMFixRoute2);
        MFMFixRouteList.add(MFMFixRoute3);
        MFMFixRouteList.add(MFMFixRoute4);
        MFMFixRouteList.add(MFMFixRoute5);
        insert MFMFixRouteList;   

        test.startTest();
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TW_Payment'), ASI_MFM_Plan__c = p1.Id,ASI_MFM_Prefix__c=px.id, ASI_MFM_Payment_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_Payment_Amount__c=100000000, ASI_MFM_Supplier_Name__c = acc3.id);
        insert py;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TW_Payment_Line_Item'), 
        ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;

        delete py;  
        test.stopTest();
        }
    }
    
    static testMethod void ASI_MFM_TH_Payment_Main_TEST() {// Test      ASI_MFM_Payment_TriggerClass  ASI_MFM_SelectPaymentPrefixController

        /*user user = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c, ASI_MFM_Department__c, ASI_Department__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];

        user.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';

        update user;                                                                           
        
        System.runAs(user) {
        
        ASI_MFM_Default_Value__c SettingB = new ASI_MFM_Default_Value__c();
        SettingB.Country__c='TH';
        SettingB.name ='TH_Tax_Code__c';
        insert SettingB;
        
        // Plan prefix
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='THP14', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415', recordTypeId = pxrt_map.get('ASI_MFM_TH_Prefix')); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;
        
        user u = [select userRole.developerName,ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        System.debug(u+'SeeASI_MFM_Country__c'+u.ASI_MFM_Country__c);
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        //Create Plan
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        // ** Create PO     
        px = new ASI_MFM_Prefix__c(name='THP14', ASI_MFM_Module__c='PO');
        insert px;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');           
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Customer'),Name='Name3');           
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name3', ASI_KOR_Customer_Code__c = 'THS2');      
        accList.add(acc3);
        
        insert accList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='THP14', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='BHT', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        
        
        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        
        //Po Line Items
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);// ASI_HK_CRM_Sub_brand    ASI_TH_CRM_Outlet
        insert sub;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000, ASI_MFM_Complete__c = true,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        
        // **********  Create Payment      ******** 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='THP14', ASI_MFM_Module__c='Payment',ASI_MFM_Region__c=true );  //   ASI_MFM_TR_Rec_Type__c='region'
        
        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;  
        
        //  ASI MFM Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=pxa.id); // Note :use Payment Prefix
        insert rtm;
        
        System.debug(Limits.getDMLRows());
        // ASI MFM Route Rule Details Set Approver 
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1,ASI_MFM_Region__c='UPC');
        insert rrd;
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2,ASI_MFM_Region__c='STH');
        insert rrd2;
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3,ASI_MFM_Region__c='WS');
        insert rrd3;
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4,ASI_MFM_Region__c='GBKK(High)');
        insert rrd4;
        
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5,ASI_MFM_Region__c='GBKK(Low)');
        insert rrd5;
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        insert rrd6; 
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        insert rrd7;
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        insert rrd8;
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        insert rrd9;
        ASI_MFM_Route_Rule_Detail__c rrd10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=100, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=10);
        insert rrd10;
        
        // Create Paymet
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='BHT', ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Payment_Amount__c=100,ASI_MFM_TH_Region__c='UPC;STH;WS;GBKK(High);GBKK(Low)',ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_POSM_Deposit__c=true);  //ASI_MFM_Payee__c    
        insert py;
        
        
        ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='BHT', ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Payment_Amount__c=100,ASI_MFM_TH_Region__c='UPC;STH;WS;GBKK(High);GBKK(Low)',ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_Supplier_Name__c = acc3.id);  //ASI_MFM_Payee__c    
        insert py1;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
        
        Test.startTest();
        //--------------------Change Tony Ren (elufa)-----------------------
        Payments.add(py);
        py.Id=py1.Id;
        mapPayments.put(py1.Id, py1);
        ASI_MFM_Payment_TriggerClass.routineBeforeInsert(Payments);
        ASI_MFM_Payment_TriggerClass.routineAfterUpdate(Payments,mapPayments);
        ASI_MFM_Payment_TriggerClass.routineBeforeUpdate(Payments,mapPayments);
        
        // ASI_MFM_SelectPaymentPrefixController
        PageReference PaymentPrefixPage = Page.ASI_MFM_SelectPaymentPrefixPage;
        Test.setCurrentPage(PaymentPrefixPage);
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(py.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', py.id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
        ASI_MFM_SelectPaymentPrefixController SelectPaymentPrefixController = new ASI_MFM_SelectPaymentPrefixController(stdController);
        
        SelectPaymentPrefixController.getPrefixes();
        SelectPaymentPrefixController.proceed();

        ASI_MFM_Payment_TriggerClass.routineBeforerDelete(Payments);
        set<id> POID_set = new set<id>();
        POID_set.add(po.id);
        ASI_MFM_Payment_TriggerClass.CompletePOLine(POID_set);
        
        //--------------------Change End-----------------------
        
        test.stopTest(); 
        }*/
    }
}