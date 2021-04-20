@isTest
private class ASI_MFM_SG_PO_Test {
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
    
    static testMethod void POMassCreateAndUpdateTestSG(){
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        //Set Plan prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        //Set PO
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='Singapore');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Set   Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
        
        insert rrdlist;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        // Set PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        
        list<ASI_MFM_PO_Line_Item__c> poLineItems = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=10, 
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineItems.add(poi);
        insert poLineItems;
                
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(poLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_SG_InputPOItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', po.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPOItemsController testCon = new ASI_MFM_SG_InputPOItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=240px,ASI_MFM_A_C_Code__c&req=T&width=160px,ASI_MFM_Customer_Name__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=120px,ASI_MFM_SG_Unit__c&req=F&width=60px,ASI_MFM_Quantity__c&req=F&width=60px,ASI_MFM_Unit_Price__c&req=F&width=60px,ASI_MFM_Amount__c&req=T&width=80px,ASI_MFM_G_L_Date__c&req=T&width=75px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + po.Id;
        mcauCon.cancelLink = '/' + po.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_PO_Line_Item');
        
        mcauCon.commitAll();        
        Test.stopTest();
    }
    
    static testMethod void POMassCreateAndUpdateTestCA(){
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        //Set Plan prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        //Set PO
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='Cambodia');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Set   Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        // Set PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        list<ASI_MFM_PO_Line_Item__c> poLineItems = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=10, 
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineItems.add(poi);
        insert poLineItems;
        
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(poLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_SG_InputPOItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', po.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPOItemsController testCon = new ASI_MFM_SG_InputPOItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=240px,ASI_MFM_A_C_Code__c&req=T&width=160px,ASI_MFM_Customer_Name__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=120px,ASI_MFM_SG_Unit__c&req=F&width=60px,ASI_MFM_Quantity__c&req=F&width=60px,ASI_MFM_Unit_Price__c&req=F&width=60px,ASI_MFM_Amount__c&req=T&width=80px,ASI_MFM_G_L_Date__c&req=T&width=75px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + po.Id;
        mcauCon.cancelLink = '/' + po.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_PO_Line_Item');
        
        mcauCon.commitAll();
        
        Test.stopTest();
    }
    
    static testMethod void POMassCreateAndUpdateTestMM(){
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        //Set Plan prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        //Set PO
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='Myanmar');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Set   Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        // Set PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        list<ASI_MFM_PO_Line_Item__c> poLineItems = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=10, 
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineItems.add(poi);
        insert poLineItems;
        
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(poLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_SG_InputPOItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', po.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPOItemsController testCon = new ASI_MFM_SG_InputPOItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=240px,ASI_MFM_A_C_Code__c&req=T&width=160px,ASI_MFM_Customer_Name__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=120px,ASI_MFM_SG_Unit__c&req=F&width=60px,ASI_MFM_Quantity__c&req=F&width=60px,ASI_MFM_Unit_Price__c&req=F&width=60px,ASI_MFM_Amount__c&req=T&width=80px,ASI_MFM_G_L_Date__c&req=T&width=75px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + po.Id;
        mcauCon.cancelLink = '/' + po.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_PO_Line_Item');
        
        mcauCon.commitAll();
        
        Test.stopTest();
    }
    
    static testMethod void POMassCreateAndUpdateTestLA(){
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        //Set Plan prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        //Set PO
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='Laos');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Set   Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        // Set PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        list<ASI_MFM_PO_Line_Item__c> poLineItems = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=10, 
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineItems.add(poi);
        insert poLineItems;
        
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(poLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_SG_InputPOItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', po.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPOItemsController testCon = new ASI_MFM_SG_InputPOItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=240px,ASI_MFM_A_C_Code__c&req=T&width=160px,ASI_MFM_Customer_Name__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=120px,ASI_MFM_SG_Unit__c&req=F&width=60px,ASI_MFM_Quantity__c&req=F&width=60px,ASI_MFM_Unit_Price__c&req=F&width=60px,ASI_MFM_Amount__c&req=T&width=80px,ASI_MFM_G_L_Date__c&req=T&width=75px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + po.Id;
        mcauCon.cancelLink = '/' + po.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_PO_Line_Item');
        
        mcauCon.commitAll();
        
        Test.stopTest();
    }
    
    
    static testMethod void testPOTrigger() {  //Test : ASI_MFM_SelectPOPrefixController
        //To test PO Trigger
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()]; 
        u.ASI_MFM_Country__c ='SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='PO');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='teste', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=2));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=3));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=4));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=5));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=6));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=7));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=8));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=9));        
        insert rrdlist;
                
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        
        System.debug(Limits.getDMLRows());
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addDays(1), ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c='Draft');
        insert po;                              
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        test.startTest();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO_Read_Only'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c='Submitted', ASI_MFM_Cloned_PO_ID__c=po.id);
        insert po1;
        
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), 
                                ASI_MFM_PO__c=po1.id, ASI_MFM_Quantity__c=10,  ASI_MFM_Unit_Price__c=10, ASI_MFM_Spread_by_Months__c=true,
                                ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', 
                                ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Amount__c = 100);
        insert poi1;
        
        /////  Test ASI_MFM_SelectPOPrefixController
        System.runAs(u){  
            PageReference poPrefixPage = Page.ASI_MFM_SelectPOPrefixPage;
            Test.setCurrentPage(poPrefixPage);
            //system.debug('ayooo ' + plan1.recordtypeid);
            ApexPages.currentPage().getParameters().put('RecordType', po.recordtypeid);
            ApexPages.currentPage().getParameters().put('id', po.id);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_SelectPOPrefixController SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
            
            SelectPOPrefixController.getPrefixes();
            SelectPOPrefixController.proceed();
        }
        
        
        test.stopTest();
    }
    
    static testMethod void testPOTrigger2() {  //Test : ASI_MFM_SelectPOPrefixController
        //To test PO Trigger
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());       
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()]; 
        u.ASI_MFM_Country__c ='SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test2', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(), ASI_MFM_Inactive__c = false);
        insert px2;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='teste', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=2));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=3));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=4));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=5));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=6));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=7));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=8));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=9));        
        insert rrdlist;
                
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        System.debug(Limits.getDMLRows());
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addDays(1), ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c='Draft');
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        test.startTest();
        
        po.ASI_MFM_Status__c='Submitted';
        po.ASI_MFM_Exchange_Rate__c=2;
        update po;
        
        po.ASI_MFM_Status__c='Final';
        po.ASI_MFM_JDE_Document_Number__c = '123456';
        update po;
        
        
        test.stopTest();
    }
    
    static testMethod void testSGInputPOItemsController() {
        // Test ASI_MFM_SG_InputPOItemsController 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
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
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name2');           
        insert acc1;
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c='Final');
        insert po;      
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        test.setCurrentPage(page.ASI_MFM_SG_InputPOItemsPage);
        apexpages.currentPage().getParameters().put('id', po.id); 
        list<ASI_MFM_PO__c> po_list = new list<ASI_MFM_PO__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(po_list);  
        ASI_MFM_SG_InputPOItemsController cx = new ASI_MFM_SG_InputPOItemsController(sc);           
                
        po.ASI_MFM_Status__c = 'Complete';
        update po;
        
         
    }
    
    static testMethod void testSGGenPOItemsController() { //Test ASI_MFM_SG_GenPOItemsController
        // Set Prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr; 
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Create Plan
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), name='test', ASI_MFM_End_Date__c=Date.today(), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        // Set Sub-Brand
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'));
        insert sub;
        
        // SKU Code
        ASI_MFM_SKU_Code__c sku = new  ASI_MFM_SKU_Code__c(ASI_HK_CRM_Available_Quantity__c = 100, ASI_HK_CRM_Active__c = True, name='testSKU', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'), ASI_MFM_Sub_brand__c=sub.id );
        insert sku;
        
        list<ASI_CRM_MY_SKUPriceCost__c> skuprice_map = new list<ASI_CRM_MY_SKUPriceCost__c>();
        skuprice_map.add(new ASI_CRM_MY_SKUPriceCost__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle')
                                                        , ASI_CRM_Cost__c = 100
                                                        , ASI_CRM_EffectiveDate__c = date.today().addMonths(-10)
                                                        , ASI_CRM_SKU__c = sku.id
                                                       ));
        
        skuprice_map.add(new ASI_CRM_MY_SKUPriceCost__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle')
                                                        , ASI_CRM_Cost__c = 100
                                                        , ASI_CRM_EffectiveDate__c = date.today().addMonths(-10)
                                                        , ASI_CRM_SKU__c = sku.id
                                                       ));
        
        skuprice_map.add(new ASI_CRM_MY_SKUPriceCost__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle')
                                                        , ASI_CRM_Cost__c = 100
                                                        , ASI_CRM_EffectiveDate__c = date.today().addMonths(-10)
                                                        , ASI_CRM_SKU__c = sku.id
                                                       ));
        
        Insert skuprice_map;
        
        //AC Code
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_CRM_AccountsAdditionalField__c cust = new ASI_CRM_AccountsAdditionalField__c(Name = 'Test Cust'
                                                                                         , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet')
                                                                                        );
        
        Insert cust;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = sub.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;  
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Event_Name__c = 'Test'
                                             , ASI_MFM_Event_Start_Date__c = date.today().addDays(-7)
                                             , ASI_MFM_Event_End_Date__c = date.today().addDays(3)
                                             , ASI_MFM_Is_FOC_PO__c = True
                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO')
                                             , ASI_MFM_Plan__c=p.id
                                             , ASI_MFM_Supplier_Name__c = acc2.id
                                             , ASI_MFM_Prefix__c=pxo.id
                                             , ASI_MFM_Currency__c='USD'
                                             , ASI_MFM_Status__c='Draft'
                                             , ASI_MFM_Outlet__c = cust.id
                                             , ASI_MFM_Contact_Person__c = 'Peter'
                                             , ASI_MFM_Delivery_date__c = Date.today().addDays(3)
                                             , ASI_MFM_Contact_Number__c = '12345678'
                                             , ASI_MFM_Exchange_Rate__c = 7.78
                                            ); 
        insert po;
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_SKU_Code__c=sku.id, ASI_MFM_SKU__c=sku.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        update poi;
        
        apexpages.standardController sc = new apexpages.standardController(po);
        ASI_MFM_SG_GenPOItemsController cx= new ASI_MFM_SG_GenPOItemsController(sc);
        pageReference pg = page.ASI_MFM_GenPOItemsPage;
        test.setCurrentPage(pg);  
        apexpages.currentPage().getParameters().put('mode', 'Full'); 
        cx.genPOItems();  
        
        delete poi;
        delete po; 
          
        test.stopTest();
    }    
    
    static testMethod void testSGGenPOItems() { //Test ASI_MFM_SG_GenPOItemsController
        // Set Prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Create Plan
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), name='test', ASI_MFM_End_Date__c=Date.today(), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        // Set Sub-Brand
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'));
        insert sub;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = sub.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;  
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        String a = ASI_MFM_SG_PO_TriggerClass.getCreatableFieldsSOQL('ASI_MFM_PO__c', 'id != Null');
                
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
                                                          ASI_MFM_Complete__c = true,        ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        poi.ASI_MFM_List_Item_Description__c='testDescription2';
        
        update poi;
        
        
    }    
    
    
}