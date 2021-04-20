@isTest
private class ASI_MFM_HK_InputPaymentItemsTest {

    static testMethod void test_main() {
        System.debug('********1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');

        insert px;
        System.debug('********2.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);

        insert pr;
        
        System.debug('********3.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_HK_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, 
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');

        insert p;
        
        System.debug('********4.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_HK_Supplier'),Name='Name2');           

        accountList.add(acc1);

        System.debug('********5.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_HK_CRM_Outlet'),Name='Name3');           
        accountList.add(acc2);
        insert accountList;
        
        System.debug('********6.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');     
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        System.debug('********7.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);

        insert pro;
        
        System.debug('********8.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        System.debug('********9.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        System.debug('********10.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        System.debug('********11.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c=100, 
            ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);

        Test.startTest();        
        insert poi;
        
        System.debug('********12.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        
        System.debug('********13.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert pxa; 
        
        System.debug('********14.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);

        insert pra;  
        
        System.debug('********15.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');

        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_HK_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc1.id);
        insert py;
        
        System.debug('********16.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_HK_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       
            
        insert pyi;




        
        System.debug('********17.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');      

        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        pyi_list.add(pyi);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_HK_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_HK_InputPaymentItemsController testCon = new ASI_MFM_HK_InputPaymentItemsController(stdSetController);
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
        
        System.debug('********18.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_HK_Payment_Line_Item');
       
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
        

        System.debug('********19.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');

        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);     

        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();
        
        System.debug('********20.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');

        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_HK_Payment_Line_Item');
        List<ASI_MFM_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();
        
        System.debug('********21.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
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
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_HK_Payment_Line_Item');
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();

        System.debug('********22.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');      

        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Set values
        //mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_MFM_Request_Quantity_Bottle__c', 5);

        // Filter products
        testCon.po_filter = 'test';
        testCon.supplier_filter = 'test';
        testCon.plan_filter = 'test';
        testCon.raised_by_filter = 'test';
        testCon.filterPOItems();

        Test.stopTest();
    }
    
        static testMethod void test_main2() {
        System.debug('********1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');

        insert px;
        System.debug('********2.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);

        insert pr;
        
        System.debug('********3.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_HK_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, 
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');

        insert p;
        
        System.debug('********4.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_HK_Supplier'),Name='Name2');           

        accountList.add(acc1);

        System.debug('********5.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_HK_CRM_Outlet'),Name='Name3');           
        accountList.add(acc2);
        insert accountList;
        
        System.debug('********6.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');     
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        System.debug('********7.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);

        insert pro;
        
        System.debug('********8.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        System.debug('********9.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        System.debug('********10.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        System.debug('********11.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c =100,
            ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);

               
        insert poi;
        
        System.debug('********12.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        
        System.debug('********13.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert pxa; 
        
        System.debug('********14.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);

        insert pra;  
        
        System.debug('********15.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');


        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_HK_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc1.id);
        insert py;
        
        Test.startTest(); 
            
        System.debug('********16.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_HK_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       
            
        insert pyi;




        
        System.debug('********17.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');      

        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        pyi_list.add(pyi);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_HK_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_HK_InputPaymentItemsController testCon = new ASI_MFM_HK_InputPaymentItemsController(stdSetController);
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
        
        System.debug('********18.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_HK_Payment_Line_Item');
       
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
        

        System.debug('********19.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');

        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);     
        
        System.debug('********20.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');

        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_HK_Payment_Line_Item');
        List<ASI_MFM_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);

        
        System.debug('********21.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');

        System.debug('********22.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');      

        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Set values
        //mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_MFM_Request_Quantity_Bottle__c', 5);
                
        // Save
        System.debug('********23.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        mcauCon.commitAll();

        System.debug('********24.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
        mcauCon.triggerPageBlockAction();
        mcauCon.refresh();

        System.debug('********25.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');

        mcauCon.clearAll();

        Test.stopTest();
    }
}