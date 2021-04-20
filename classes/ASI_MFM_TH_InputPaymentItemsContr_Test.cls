@isTest

public class ASI_MFM_TH_InputPaymentItemsContr_Test {
    
    
    static testMethod void PaymentMassCreateAndUpdateTest3() {
        // Test for  ASI_MFM_MassCreateAndUpdateController in Payment
        
        //Set Prefix
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(px);
        
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(pxo);
        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(pxa);
        insert preList; 
        
        //Set  Role_Prefix_Relationship
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        List<ASI_MFM_Role_Prefix_Relationship__c> PreRelatList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pra);
        insert PreRelatList;
        
        
        //Plan
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');           
        accountList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Customer'),Name='Name3');            // SG: Outlet: ASI_CRM_SG_Outlet              TH Outlet:  ASI_TH_CRM_Outlet
        accountList.add(acc2);
        insert accountList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c'); 
        List<ASI_MFM_PO_Line_Item__c> poi_list = new list<ASI_MFM_PO_Line_Item__c>();      
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=10,ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
        poi_list.add(poi);
        
        
        //-----------------------Start Test-----------------------------------
        Test.startTest();
        
        insert poi_list;
        
        //Payment 
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        list<ASI_MFM_Payment__c> pay_list = new list<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc1.id ,ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_POSM_Deposit__c = true);
        pay_list.add(py);  
        
        insert pay_list;
        
        
        //Payment Line 
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c'); 
        //
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Remaining_Amount__c=10,ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');    
        pyi_list.add(pyi);
        
        //insert pyi_list; //20160901
        //Run Controller
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_TH_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_TH_InputPaymentItemsController testCon = new ASI_MFM_TH_InputPaymentItemsController(stdSetController);
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
        sobjstCon.displayFieldsStr = 'Name, ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Currency__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_Remaining_Balance__c';
        
        
        sobjstCon.defWhereStatmStr = null;
        sobjstCon.orderByStr = 'ASI_MFM_PO__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TH_Payment_Line_Item');
        mcauCon.commitAll();
        
        Test.stopTest();
        //------------------------------Test End-------------------------------------
    }
    
    
    static testMethod void PaymentMassCreateAndUpdateTest4() {  //Test negative_pol_balance
        // Test for  ASI_MFM_MassCreateAndUpdateController in Payment
        
        //Set Prefix
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(px);
        
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(pxo);
        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(pxa);
        insert preList; 
        
        //Set  Role_Prefix_Relationship
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        List<ASI_MFM_Role_Prefix_Relationship__c> PreRelatList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pra);
        insert PreRelatList;
        
        
        //Plan
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');           
        accountList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Customer'),Name='Name3');            // SG: Outlet: ASI_CRM_SG_Outlet              TH Outlet:  ASI_TH_CRM_Outlet
        accountList.add(acc2);
        insert accountList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c'); 
        List<ASI_MFM_PO_Line_Item__c> poi_list = new list<ASI_MFM_PO_Line_Item__c>();      
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=100,ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id,ASI_MFM_POSM_Deposit__c = true);
        poi_list.add(poi);
        
        //-----------------------Start Test-----------------------------------
        Test.startTest();
        
        insert poi_list;
        
        //Payment 
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        list<ASI_MFM_Payment__c> pay_list = new list<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_Supplier_Name__c = acc1.id);
        pay_list.add(py);  
        
        insert pay_list;
        
        //Payment Line 
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c'); 
        // 
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=100, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');    
        pyi_list.add(pyi);
        
        //insert pyi_list; //20160901
        //Run Controller
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_TH_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_TH_InputPaymentItemsController testCon = new ASI_MFM_TH_InputPaymentItemsController(stdSetController);
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
        sobjstCon.displayFieldsStr = 'Name, ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Currency__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_Remaining_Balance__c';
        
        
        sobjstCon.defWhereStatmStr = null;
        sobjstCon.orderByStr = 'ASI_MFM_PO__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TH_Payment_Line_Item');
        mcauCon.commitAll();
        
        Test.stopTest();
        //------------------------------Test End-------------------------------------
    }
    
    
    
    static testMethod void PaymentMassCreateAndUpdateTest1() {
        // Test for  ASI_MFM_MassCreateAndUpdateController in Payment
        
        //Set Prefix
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(px);
        
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(pxo);
        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(pxa);
        insert preList; 
        
        //Set  Role_Prefix_Relationship
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        List<ASI_MFM_Role_Prefix_Relationship__c> PreRelatList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pra);
        insert PreRelatList;
        
        
        //Plan
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');           
        accountList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Customer'),Name='Name3');            // SG: Outlet: ASI_CRM_SG_Outlet              TH Outlet:  ASI_TH_CRM_Outlet
        accountList.add(acc2);
        insert accountList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c'); 
        List<ASI_MFM_PO_Line_Item__c> poi_list = new list<ASI_MFM_PO_Line_Item__c>();      
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=10,ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id,ASI_MFM_POSM_Deposit__c = true);
        poi_list.add(poi);
        
        //-----------------------Start Test-----------------------------------
        Test.startTest();
        
        insert poi_list;
        
        //Payment 
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        list<ASI_MFM_Payment__c> pay_list = new list<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_Supplier_Name__c = acc1.id);
        pay_list.add(py);  
        
        insert pay_list;
        
        
        //Payment Line 
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c'); 
        //Case: complete POSM deposit with  : PO.POSM_Deposit__c = true && payment line.ASI_MFM_POSM_Balance__c =false    
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Complete_POL__c = true);    
        pyi_list.add(pyi);
        
        //insert pyi_list; //20160901
        //Run Controller
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_TH_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_TH_InputPaymentItemsController testCon = new ASI_MFM_TH_InputPaymentItemsController(stdSetController);
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
        sobjstCon.displayFieldsStr = 'Name, ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Currency__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_Remaining_Balance__c';
        
        
        sobjstCon.defWhereStatmStr = null;
        sobjstCon.orderByStr = 'ASI_MFM_PO__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TH_Payment_Line_Item');
        mcauCon.commitAll();
        
        Test.stopTest();
        //------------------------------Test End-------------------------------------
    }
    
    
    static testMethod void PaymentMassCreateAndUpdateTest2() {
        // Test for  ASI_MFM_MassCreateAndUpdateController in Payment
        
        //Set Prefix
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(px);
        
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(pxo);
        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c='FY2021');
        preList.add(pxa);
        insert preList; 
        
        //Set  Role_Prefix_Relationship
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        List<ASI_MFM_Role_Prefix_Relationship__c> PreRelatList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PreRelatList.add(pra);
        insert PreRelatList;
        
        
        //Plan
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');           
        accountList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Customer'),Name='Name3');            // SG: Outlet: ASI_CRM_SG_Outlet              TH Outlet:  ASI_TH_CRM_Outlet
        accountList.add(acc2);
        insert accountList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c'); 
        List<ASI_MFM_PO_Line_Item__c> poi_list = new list<ASI_MFM_PO_Line_Item__c>();      
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=10,ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id,ASI_MFM_POSM_Deposit__c = true);
        poi_list.add(poi);
        
        
        //-----------------------Start Test-----------------------------------
        Test.startTest();
        
        insert poi_list;
        
        //Payment 
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        list<ASI_MFM_Payment__c> pay_list = new list<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc1.id ,ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_POSM_Balance__c = true);
        pay_list.add(py);  
        
        insert pay_list;
        
        
        //Payment Line 
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c'); 
        //Case: complete POSM deposit with  : PO.POSM_Deposit__c = true && payment line.ASI_MFM_POSM_Balance__c =false    
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=9, ASI_MFM_PO_Line_Remaining_Amount__c=10,ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Complete_POL__c = false);    
        pyi_list.add(pyi);
        //insert pyi_list; //20160901
        //Run Controller
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_TH_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_TH_InputPaymentItemsController testCon = new ASI_MFM_TH_InputPaymentItemsController(stdSetController);
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
        sobjstCon.displayFieldsStr = 'Name, ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Currency__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_Remaining_Balance__c';
        
        
        sobjstCon.defWhereStatmStr = null;
        sobjstCon.orderByStr = 'ASI_MFM_PO__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TH_Payment_Line_Item');
        mcauCon.commitAll();
        
        Test.stopTest();
        //------------------------------Test End-------------------------------------
    }

    
    static testMethod void ASI_MFM_TH_InputPaymentItems_MassCreateAndUpdateControllerTest() {
        // Test for  ASI_MFM_TH_InputPaymentItemsController and  ASI_MFM_MassCreateAndUpdateController
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY2021');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');           
        
        accountList.add(acc1);// SG: Supplier: ASI_CRM_SG_Supplier         TH Supplier:  ASI_TH_CRM_Supplier
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Customer'),Name='Name3');            // SG: Outlet: ASI_CRM_SG_Outlet              TH Outlet:  ASI_TH_CRM_Outlet
        accountList.add(acc2);
        insert accountList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');     
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c='FY2021');
        insert pxo; 
        
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=10,ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
        
        
        //-----------------------Start Test-----------------------------------
       
        
        insert poi;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Parent_Prefix__c=pxo.id, ASI_MFM_Fiscal_year__c='FY2021');
        insert pxa; 
        
        
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;  
        
        
     Test.startTest();
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_Supplier_Name__c = acc1.id);
        insert py;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');    
        insert pyi;
        
        
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        pyi_list.add(pyi);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_TH_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_TH_InputPaymentItemsController testCon = new ASI_MFM_TH_InputPaymentItemsController(stdSetController);
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
        sobjstCon.displayFieldsStr = 'Name, ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Currency__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_Remaining_Balance__c';
        
        
        sobjstCon.defWhereStatmStr = null;
        sobjstCon.orderByStr = 'ASI_MFM_PO__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TH_Payment_Line_Item');
        
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
     
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TH_Payment_Line_Item');
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
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TH_Payment_Line_Item');
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
}