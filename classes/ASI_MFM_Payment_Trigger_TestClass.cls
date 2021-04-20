@isTest (SeeAllData=false)

public with sharing class ASI_MFM_Payment_Trigger_TestClass {



    static testMethod void  ASI_MFM_TH_BAverifyTest(){
        // Test For ASI_MFM_TH_BAverifyController 
        Test.setCurrentPage(Page.ASI_MFM_TH_BAVerify);
        // Start Plan
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415', recordTypeId = pxrt_map.get('ASI_MFM_TH_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;    
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        List<ASI_MFM_Plan__c> plist = new List<ASI_MFM_Plan__c>();
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today().addMonths(3), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Final');
        plist.add(p);
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test3', ASI_MFM_Prefix__c=px.id,ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today());
        plist.add(p3);
        insert plist;
        // Start PO
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);
        insert subBrand1;
        System.debug(Limits.getDMLRows());
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        System.debug(Limits.getDMLRows());
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> acclist = new List<Account>();
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');           
        acclist.add(acc2);
        
        Account acc1 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');     //ASI_MFM_SG_Supplier            
        acclist.add(acc1);
        insert acclist;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');             
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c = 'Final'); 
        insert po;
        
        
        // Start PO line Items
        acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');           
        insert acc2;
        Test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);// ASI_HK_CRM_Sub_brand    ASI_TH_CRM_Outlet
        insert sub;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_SG_BA_verify__c = true);
        insert poi;
        // Finished 
        // Start Test
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_TH_BAverify');
        Test.setCurrentPage(pageRef);
        ASI_MFM_TH_BAverifyController ext = new ASI_MFM_TH_BAverifyController(new ApexPages.StandardController(poi));
        
        // Add parameters to page 
        //ApexPages.currentPage().getParameters().put('PO_Number', po.name);
        //ApexPages.currentPage().getParameters().put('PO_Line_Number', 'P');
        //ApexPages.currentPage().getParameters().put('Suppliers_Number', '9');
        //ApexPages.currentPage().getParameters().put('Suppliers', acc1.Name); 
        //ApexPages.currentPage().getParameters().put('A_C_Code', 'A');
        //ApexPages.currentPage().getParameters().put('GLdates', '2015-03-02');
        ext.save();
        ext.runSearch();
        ext.PO_Num='1';
        ext.Plan_Num='1';
        ext.PO_Line_Num='2';
        ext.Suppliers_Num='1';
        ext.Suppl='c';
        ext.AC_Code='1';
        ext.Fiscal_Year='FY1415';
        ext.gl_fromDate.ASI_MFM_G_L_Date__c=Date.today();
        ext.gl_toDate.ASI_MFM_G_L_Date__c=Date.today();
        ext.save();
        ext.firstPage();
        ext.lastPage();
        ext.prevPage();
        ext.nextPage();
        //ext.PO_Number=' ';
        ext.runSearch();
        ext.refresh();
        ext.toggleSort();
        ext.gotopage();
        
        test.stopTest();
    }
     
    
    static testMethod void  ASI_MFM_SetPaymentStatusTest(){  
        
        // Start Plan
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        preList.add(px);
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        preList.add(pxa); 
        insert preList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TH';
        update u;
        

        List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRelationList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pro);   
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pra);
        insert PrefixRelationList;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        
        //Set PO 
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');      
        accList.add(acc1);
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');        
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS2');      
        accList.add(acc3);
        
        insert accList;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='THB', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        // Set Payment
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        
        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        list<ASI_MFM_Payment__c> Pay_LIst = new list<ASI_MFM_Payment__c>();
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        System.debug(Limits.getDMLRows());
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_POSM_Deposit__c = true,ASI_MFM_Invoice_Due_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='THB', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_ETL__c = false,ASI_MFM_Status__c='Final');   //acc3.id
        Pay_LIst.add(py);
        insert Pay_LIst;

        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id);  
        insert pyi;
        
        
        // Test ASI_MFM_SetPaymentStatusController
        
        
        PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
        Test.setCurrentPage(pageRef5);
        
        ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
        ASI_MFM_SetPaymentStatusController ext5 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(py));
        ext5.setStatus();
        
        test.stopTest(); 
        
    }
    
    
    static testMethod void ASI_MFM_TH_Payment_Main_TEST() {// Test      ASI_MFM_Payment_TriggerClass  ASI_MFM_SelectPaymentPrefixController
        
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
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
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
        Test.startTest();
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
        
        //--------------------Change End-----------------------
        
        test.stopTest(); 
    }
    
    
    static testMethod void PaymentMassCreateAndUpdateTest3() {
        // Test for  ASI_MFM_MassCreateAndUpdateController in Payment
        
        //Set Prefix
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        preList.add(px);
        
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo);
        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
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
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        preList.add(px);
        
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo);
        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
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
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        preList.add(px);
        
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo);
        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
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
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        preList.add(px);
        
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo);
        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
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

    
    
    
    
    static testMethod void ASI_MFM_TH_Budgets_TEST() {   //Test  ASI_MFM_TH_Budgets_PDF_PageController and  ASI_MFM_TH_BudgetViewController
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;      
        
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<string, id> po_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        Map<string, id> budget_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Budget__c');
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');
        Map<string, id> Prefix_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        
        ASI_MFM_Budget_Setting__c SettingB = new ASI_MFM_Budget_Setting__c();
        SettingB.ASI_MFM_Budget_Type__c='LE4';
        SettingB.name ='TH';
        SettingB.ASI_MFM_Fiscal_Year__c='FY1415';
        insert SettingB;
        
        // Prefix : Plan
        List<ASI_MFM_Prefix__c> pxlist = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='THM14',ASI_MFM_Module__c='Plan',ASI_MFM_Fiscal_year__c='FY1415',recordTypeId=Prefix_map.get('ASI_MFM_TH_Prefix'),ASI_MFM_Department__c='TestD');
        pxlist.add(prefix1);
        
        ASI_MFM_Prefix__c prefix2 = new ASI_MFM_Prefix__c(Name='THP14',ASI_MFM_Module__c='Plan',ASI_MFM_Fiscal_year__c='FY1415',recordTypeId=Prefix_map.get('ASI_MFM_TH_Prefix'),ASI_MFM_Department__c='TestD');
        pxlist.add(prefix2);
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='THM14', ASI_MFM_Module__c='PO');
        pxlist.add(pxo);
        ASI_MFM_Prefix__c pxo1 = new ASI_MFM_Prefix__c(name='THP14', ASI_MFM_Module__c='PO');
        pxlist.add(pxo1);
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='THM14', ASI_MFM_Module__c='Payment');
        pxlist.add(pxa);
        ASI_MFM_Prefix__c pxa1 = new ASI_MFM_Prefix__c(name='THP14', ASI_MFM_Module__c='Payment');
        pxlist.add(pxa1);
        insert pxlist ;
        
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rpxlist = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        
        ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,ASI_MFM_Role_Name__c =u.userRole.developerName);            
        rpxlist.add(prefixChild1);
        ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix2.Id,ASI_MFM_Role_Name__c =u.userRole.developerName);            
        rpxlist.add(prefixChild2);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rpxlist.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pro1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rpxlist.add(pro1);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rpxlist.add(pra);  
        ASI_MFM_Role_Prefix_Relationship__c pra1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rpxlist.add(pra1); 
        insert rpxlist;
        
        //Create 2 Sub-Brand
        List<ASI_MFM_Sub_brand__c> sblist = new List<ASI_MFM_Sub_brand__c>();
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'),ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_MFM__c =true ); // ASI_CRM_SG_Sub_brand
        sblist.add(subBrand1);
        
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'),ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_MFM__c =true);
        sblist.add(subBrand2);
        ASI_MFM_Sub_brand__c subBrand3 = new ASI_MFM_Sub_brand__c(Name='subBrand3',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'),ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_MFM__c =true);
        sblist.add(subBrand3);
        insert sblist;
        
        // Create Budget
        List<ASI_MFM_Budget__c> Budgetlist = new List<ASI_MFM_Budget__c>();
        ASI_MFM_Budget__c budget1 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THM',ASI_MFM_Type__c='Budget',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10000000,ASI_MFM_P3_Amount__c=1000000
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget1);
        ASI_MFM_Budget__c budget2 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THM',ASI_MFM_Type__c='LE1',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10000000,ASI_MFM_P3_Amount__c=10000400
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget2);
        ASI_MFM_Budget__c budget3 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THM',ASI_MFM_Type__c='LE2',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10000000,ASI_MFM_P3_Amount__c=1000040
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget3);
        
        ASI_MFM_Budget__c budget4 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THM',ASI_MFM_Type__c='LE3',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10000000,ASI_MFM_P3_Amount__c=1000041
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget4);
        ASI_MFM_Budget__c budget5 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THM',ASI_MFM_Type__c='LE4',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10001000,ASI_MFM_P3_Amount__c=1000040
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget5);
        
        ASI_MFM_Budget__c budget6 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THP',ASI_MFM_Type__c='Budget',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10001001,ASI_MFM_P3_Amount__c=10000400
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget6);
        
        ASI_MFM_Budget__c budget7 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THP',ASI_MFM_Type__c='LE1',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10001001,ASI_MFM_P3_Amount__c=10000400
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget7);
        
        ASI_MFM_Budget__c budget8 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THP',ASI_MFM_Type__c='LE2',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10001001,ASI_MFM_P3_Amount__c=10000400
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget8);
        ASI_MFM_Budget__c budget9 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THP',ASI_MFM_Type__c='LE3',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10001001,ASI_MFM_P3_Amount__c=10000400
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget9);
        ASI_MFM_Budget__c budget10 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THP',ASI_MFM_Type__c='LE4',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                           ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10001001,ASI_MFM_P3_Amount__c=10000400
                                                           ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget10);
        ASI_MFM_Budget__c budget11 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand3.id,ASI_MFM_Department__c='THP',ASI_MFM_Type__c='LE4',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                           ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10001001,ASI_MFM_P3_Amount__c=10000400
                                                           ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget11);
        ASI_MFM_Budget__c budget12 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand3.id,ASI_MFM_Department__c='THM',ASI_MFM_Type__c='LE4',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                           ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10001001,ASI_MFM_P3_Amount__c=10000400
                                                           ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget12);
        ASI_MFM_Budget__c budget14 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand3.id,ASI_MFM_Department__c='THP',ASI_MFM_Type__c='LE4',ASI_MFM_Region_AND_Customer__c='GBKK'
                                                           ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10001001,ASI_MFM_P3_Amount__c=10000400
                                                           ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        Budgetlist.add(budget14); // Redundant
        insert Budgetlist;
        
        
        // * Create 3 Plan *
        List<ASI_MFM_Plan__c> Planlist = new List<ASI_MFM_Plan__c>();
        ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='TH131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_TH_Plan'),ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest',ASI_MFM_TH_Region__c='UPC;STH;WS;GBKK(High);GBKK(Low)', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c='Final');
        Planlist.add(Plan1);
        
        ASI_MFM_Plan__c Plan3 = new ASI_MFM_Plan__c(Name='TH131',ASI_MFM_Prefix__c=prefix2.Id,recordTypeId=plan_map.get('ASI_MFM_TH_Plan'),ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTes1t',ASI_MFM_TH_Region__c='UPC;STH;WS;GBKK(High);GBKK(Low)', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c='Final');
        Planlist.add(Plan3);
        insert Planlist;
        
        // Create AC Code
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_TH_A_C_Code'));
        insert ac;
        List<Account> Accountlist = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');     //ASI_MFM_SG_Supplier            
        Accountlist.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Customer'),Name='Name3');            
        Accountlist.add(acc2);
        insert Accountlist;
        
        
        
        // Add 4 plan Line Item for 2 Plan
        list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hellos1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));  //Delete Redundant Data
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand2.id,ASI_MFM_List_Item_Description__c='hello2'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand3.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        //insert planLineItems;
        
        //  list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan3.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_TH_Region__c='GBKK'
                                                        ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan3.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand2.id,ASI_MFM_List_Item_Description__c='hello2'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
                                                         ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_TH_Region__c='GBKK'
                                                        ));
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan3.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_TH_Region__c='GBKK'
                                                        ));//Delete Redundant Data
        
        
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan3.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_TH_Region__c='UPC'
                                                        ));
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan3.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand3.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_TH_Region__c='UPC'
                                                        ));    
        insert planLineItems;
        
        //Plan and Plan Line items finished
        
        //Create PO
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');             
        list<ASI_MFM_PO__c> Polist = new list<ASI_MFM_PO__c>();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=Plan1.id,ASI_MFM_Supplier_Name__c = acc1.id); 
        Polist.add(po);
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=pxo1.id, ASI_MFM_Plan__c=Plan3.id,ASI_MFM_Supplier_Name__c = acc1.id); 
        Polist.add(po1);
        insert Polist;
        // Start Test    
        Test.startTest();
        System.debug(Limits.getDMLRows());
        //Create PO line Itmems                pxo1
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        list<ASI_MFM_PO_Line_Item__c> poilist = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_Amount__c=1,ASI_MFM_TH_Region__c='GBKK');
        // ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_Complete__c = true,ASI_MFM_Amount__c=1);
        poilist.add(poi);
        
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_Amount__c=1,ASI_MFM_TH_Region__c='GBKK');
        poilist.add(poi2);
        
        insert poilist;  
        
        // PO line items Finished
        
        System.runAs(u){
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);
            ASI_MFM_TH_Budgets_PDF_PageController ext = new ASI_MFM_TH_Budgets_PDF_PageController(stdController);
            ext.FiscalYearNum='FY1415';
            ext.PrefixInput='THM14';
            ext.PrefixUse2='THM';
            ext.PrefixUse='THM14';
            //ext.initNotRegion();
            boolean inb=ext.dummyVarTHK;
            inb=ext.dummyBRD;
            inb=ext.dummyBR;
            
            ASI_MFM_TH_Budgets_PDF_PageController ext2 = new ASI_MFM_TH_Budgets_PDF_PageController(stdController);
            ext2.FiscalYearNum='FY1415';
            ext2.PrefixUse2='THP';
            ext2.PrefixUse='THP14';
            ext2.initBybrandRegionD();
            ext2.initBybrandandRegion();
            //
            //
            
            
            
            //  Test ASI_MFM_TH_BudgetViewController
            PageReference pageRef = new Pagereference('/apex/ASI_MFM_TH_BudgetViewPage');
            Test.setCurrentPage(pageRef);
            ASI_MFM_TH_BudgetViewController ext3 = new ASI_MFM_TH_BudgetViewController(new ApexPages.StandardController(budget4));
            ApexPages.currentPage().getParameters().put('Sub_Brand', 'C');
            ApexPages.currentPage().getParameters().put('Departments', 'THM');
            ApexPages.currentPage().getParameters().put('Budget_Type', 'LE1');
            ApexPages.currentPage().getParameters().put('Fiscal_Year', 'FY1415');
            ext3.firstPage();
            ext3.lastPage();
            ext3.prevPage();
            ext3.nextPage();
            ext3.runSearch();
        }
        
        test.stopTest();
    }
 
    static testMethod void ASI_MFM_TH_Payment_TriggerTEST2() { // Test      ASI_MFM_Payment_TriggerClass/ ASI_MFM_PaymentLineItem_TriggerClass  Test ASI_MFM_POSM_Deposit__c
        //Test Case: ASI_MFM_POSM_Deposit__c = true && Status='Final' in ASI_MFM_Payment__r
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        // Create Plan 
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        // Suplier
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');  
        accList.add(acc1);
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');          
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name3', ASI_KOR_Customer_Code__c = 'THS2');      
        accList.add(acc3);
        
        insert accList;
        
        // Create PO
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='THB', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        // Create PO line Items
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);// ASI_HK_CRM_Sub_brand    ASI_TH_CRM_Outlet
        insert sub;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000, //ASI_MFM_Quantity__c=100, ASI_MFM_Unit_Price__c=10,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        Test.startTest(); // start the test
        // prepare Payment
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        
        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
        
        
        // Create Payment 
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Due_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='BHT', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Final',ASI_MFM_POSM_Deposit__c = true);   //   acc2.id   ,
        insert py;
        
        //Paymet line item
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id);  // it must include ASI_MFM_Payee__c 
        insert pyi;
        
        
        test.stopTest(); 
    }
    
    static testMethod void ASI_MFM_TH_Payment_TriggerTEST3() {   // for Test class: Case ASI_MFM_POSM_Balance__c = true &&  Status='Final' in ASI_MFM_Payment (ASI_MFM_PaymentLineItem_TriggerClass)
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        // Create Plan 
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        // Suplier
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');  
        accList.add(acc1);
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');          
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name3', ASI_KOR_Customer_Code__c = 'THS2');      
        accList.add(acc3);
        
        insert accList;
        
        // Create PO
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='THB', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Draft',ASI_MFM_Is_FOC_PO__c=true );
        insert po;
        
        // Create PO line Items
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);// ASI_HK_CRM_Sub_brand    ASI_TH_CRM_Outlet
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000, //ASI_MFM_Quantity__c=100, ASI_MFM_Unit_Price__c=10,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        // prepare Payment
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        
        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
        
        Test.startTest(); // start the test
        // Create Payment 
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Due_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='THB', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Final',ASI_MFM_POSM_Balance__c = true);   //   acc2.id
        insert py;
        
        //Paymet line item
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id);  // it must include ASI_MFM_Payee__c 
        insert pyi;
        
        test.stopTest(); 
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










    static testMethod void ASI_MFM_PDFTestPayment() {   // for Test class: ASI_MFM_TH_Payment_PDF_PageController  and ASI_MFM_SetPOStatusController
        Test.setCurrentPage(Page.ASI_MFM_TH_Payment_PDF_Page);
          
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        // Create Plan 
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
     
        // Suplier
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');  
        accList.add(acc1);
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');          
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name3', ASI_KOR_Customer_Code__c = 'THS2');      
        accList.add(acc3);
        
        insert accList;
        
        // Create PO
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='THB', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Draft',ASI_MFM_Is_FOC_PO__c=true);
        insert po;
        
        // Create PO line Items
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000, //ASI_MFM_Quantity__c=100, ASI_MFM_Unit_Price__c=10,
        ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
         // prepare Payment
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');

        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
        
        Test.startTest(); // start the test
        // Create Payment 
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        list<ASI_MFM_Payment__c> PaymentList  = new list<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_POSM_Balance__c=true,
            ASI_MFM_Currency__c='THB', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id, ASI_MFM_Invoice_Due_Date__c=date.today());   //   acc2.id
        
        PaymentList.add(py);

        ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_POSM_Balance__c=true,
        ASI_MFM_Currency__c='THB', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id, ASI_MFM_Invoice_Due_Date__c=date.today());   //   acc2.id
        
        PaymentList.add(py1);

        insert PaymentList;
        
        //Paymet line item
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id);  // it must include ASI_MFM_Payee__c 
        insert pyi;
        
        ASI_MFM_Payment_TriggerClass.routineBeforerDelete(PaymentList);
        ASI_MFM_Payment_TriggerClass.routineAfterDelete(PaymentList);
        test.stopTest(); 
    }
    



    static testMethod void ASI_MFM_SetPOStatusClass() {
        // Test ASI_MFM_SetPOStatusController
       //Prefix
       List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
       ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=ASI_MFM_JP_TestClassHelper.getFiscalYear());
       prefixList.add(px); 
       ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
       prefixList.add(pxo);
       ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
       prefixList.add(pxa);
       insert prefixList;
       
       //User
       user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
       u.ASI_MFM_Country__c = 'JP';
       update u;
       
       List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
       ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pr);
       ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pro);
       ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pra);
       insert RPList;
       
       //Plan
       ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
                                               ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                               ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
       insert p;
       
       //Brand and Sub-Brand
       ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
       insert brand1;
       ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
       insert subBrand1;
       
       //AP AC Code
       ASI_MFM_AP_Code__c ap = ASI_MFM_JP_TestClassHelper.createJPAPCode();
       ASI_MFM_A_C_Code__c ac = ASI_MFM_JP_TestClassHelper.createJPACCode();
       
       //Account : Customer  Supplier
       List<Account> accToInsert = new List<Account>();
       Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
       accToInsert.add(acc2);
       Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2');           
       accToInsert.add(acc1);
       insert accToInsert;
       
       //Plan line 
       ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                    ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
       insert pi;  
       
       
       //Create PO 
       ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO');
       insert rt;
       
       ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
       insert rtm;
       ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id,Brand_MFM__c=brand1.id);
       insert rtbr;
       
       date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
       ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
       insert podr;
       
       //PO 
       ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id,ASI_MFM_Currency__c='JPY', ASI_MFM_Status__c='Final',
                                            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
       insert po;
       
       
       
       // PO Line
       List<ASI_MFM_PO_Line_Item__c> POLineList = new List<ASI_MFM_PO_Line_Item__c>();
       ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                 ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                 ASI_MFM_G_L_Date__c = Date.today());
       POLineList.add(poi);
       ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                 ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                 ASI_MFM_G_L_Date__c = Date.today());
       POLineList.add(pol);
       insert POLineList;
       
       // PO Receipt 
       ASI_MFM_PO_Receipt__c POR =new ASI_MFM_PO_Receipt__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_JP_PO_Receipt'),ASI_MFM_PO__c=po.id);
       insert POR;
       
       System.debug(Limits.getDMLRows());
       Test.startTest();
       //PO Receipt Item
       List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
       ASI_MFM_PO_Receipt_Item__c PORI = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,ASI_MFM_PO_Line_Item__c=poi.id,ASI_MFM_PO__c=po.id,ASI_MFM_Marketing_Verify__c=true);
       PORIList.add(PORI);
       ASI_MFM_PO_Receipt_Item__c PORI2 = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,ASI_MFM_PO_Line_Item__c=pol.id,ASI_MFM_PO__c=po.id,ASI_MFM_Marketing_Verify__c=true);
       PORIList.add(PORI2);
       insert PORIList;
       
       // Create Payment  
       ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,
                                                      ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Submitted');  
       insert py;
       
       
       //Paymet line item
       List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
       ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=82, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id,ASI_MFM_Payment_Line_Item_Finance_Verify__c=true); 
       payLineList.add(pyi);
       ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=pol.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id); 
       payLineList.add(pyi2);
       insert payLineList;
       
       // Test ASI_MFM_SetPOStatusController
       PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
       Test.setCurrentPage(pageRef);
       
       ApexPages.currentPage().getParameters().put('status', 'Complete'); 
       ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
       ext1.setStatus();
       
       
       //TEST : ASI_MFM_JP_Payment_PDF_PageController
       ASI_MFM_JP_Payment_PDF_PageController ext = new ASI_MFM_JP_Payment_PDF_PageController(new ApexPages.StandardController(py));
       ext.payID= py.Id; // initialization of the class
       ext.dummyVar = false;
       ext.init();
               
       Test.stopTest();
   }
   
   
   static testMethod void ASI_MFM_Payment_TermClass() {
       //Test ASI_MFM_Payment_TriggerClass   ASI_MFM_SetPOStatusController
       
       //Prefix
       List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
       ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=ASI_MFM_JP_TestClassHelper.getFiscalYear());
       prefixList.add(px); 
       ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
       prefixList.add(pxo);
       ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
       prefixList.add(pxa);
       insert prefixList;
       
       //User
       user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
       u.ASI_MFM_Country__c = 'JP';
       update u;
       
       List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
       ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pr);
       ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pro);
       ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pra);
       insert RPList;
       
       //Plan
       ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
                                               ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                               ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
       insert p;
       
       //Brand and Sub-Brand
       ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
       insert brand1;
       ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
       insert subBrand1;
       
       //AP AC Code
       ASI_MFM_AP_Code__c ap = ASI_MFM_JP_TestClassHelper.createJPAPCode();
       ASI_MFM_A_C_Code__c ac = ASI_MFM_JP_TestClassHelper.createJPACCode();
       
       //Account : Customer  Supplier
       List<Account> accToInsert = new List<Account>();
       Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name1',ASI_MFM_Payment_Terms__c='Month Ends 60 Days BH 601');           
       accToInsert.add(acc1);
       Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name2');           
       accToInsert.add(acc2);
        Account acc3 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name3',ASI_MFM_Payment_Terms__c='Month End');           
       accToInsert.add(acc3);
       insert accToInsert;
       
       //Plan line 
       ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                    ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
       insert pi;  
       
       
       //Create PO 
       ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO');
       insert rt;
       
       ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
       insert rtm;
       ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id,Brand_MFM__c=brand1.id);
       insert rtbr;
       
       date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
       ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
       insert podr;
       
       //PO 
       ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id,ASI_MFM_Currency__c='JPY', ASI_MFM_Status__c='Final',
                                            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
       insert po;
       
       
       
       // PO Line
       List<ASI_MFM_PO_Line_Item__c> POLineList = new List<ASI_MFM_PO_Line_Item__c>();
       ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                 ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                 ASI_MFM_G_L_Date__c = Date.today());
       POLineList.add(poi);
       ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                 ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                 ASI_MFM_G_L_Date__c = Date.today());
       POLineList.add(pol);
       insert POLineList;
       
       System.debug(Limits.getDMLRows());
       Test.startTest();
       //Payment Term 
       ASI_MFM_Payment_Term__c pt = new ASI_MFM_Payment_Term__c(name='601',ASI_MFM_Description__c='Month Ends 60 Days BH 601',ASI_MFM_JP_PaymentTermDigits__c='601',ASI_MFM_Fixed_Date__c=3,ASI_MFM_JP_NumberOfDays__c=60,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Term__cASI_MFM_JP_Payment_Term'));
       insert pt;
       
       // Create Payment  Test ASI_MFM_Payment_TriggerClass 
       List<ASI_MFM_Payment__c> pylist =new List<ASI_MFM_Payment__c>();
       
       ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,
                                                      ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');  
       pylist.add(py);
       ASI_MFM_Payment__c pa = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,
                                                      ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft');  
       pylist.add(pa);
       insert pylist;
       
       
               
       // Test ASI_MFM_SetPOStatusController
       PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
       Test.setCurrentPage(pageRef);
       
       ApexPages.currentPage().getParameters().put('status', 'Complete'); 
       ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
       ext1.setStatus();
       
       Test.stopTest();
   }
   
   static testMethod void ASI_MFM_SetPaymentStatusClass() {
       //Test ASI_MFM_SetPaymentStatusController
       
       ASI_MFM_Tax_Code__c tax= new ASI_MFM_Tax_Code__c(name='Default JP Tax',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_JP_Tax_Code'),ASI_MFM_Default__c=true);
       insert tax;
       
       ASI_MFM_Payment__c py=ASI_MFM_JP_TestClassHelper.createJPPayment();
       
       
       //Test:  ASI_MFM_SelectPaymentPrefixController
       PageReference PaymentPrefixPage = Page.ASI_MFM_SelectPaymentPrefixPage;
       Test.setCurrentPage(PaymentPrefixPage);
       ApexPages.currentPage().getParameters().put('RecordType', String.valueof(py.recordtypeid).substring(0,15));
       ApexPages.currentPage().getParameters().put('id', py.id);
       ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
       ASI_MFM_SelectPaymentPrefixController SelectPaymentPrefixController = new ASI_MFM_SelectPaymentPrefixController(stdController);
       
       SelectPaymentPrefixController.getPrefixes();
       SelectPaymentPrefixController.proceed();
       
       
       
       //ASI_MFM_SetPaymentStatusController
       PageReference pageRef4 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
       Test.setCurrentPage(pageRef4);
       // Fail to change status
       ApexPages.currentPage().getParameters().put('status', 'Test'); 
       ASI_MFM_SetPaymentStatusController ext4 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(py));
       ext4.setStatus();
       
       
       PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
       Test.setCurrentPage(pageRef5);
       // change status as Submitted
       ApexPages.currentPage().getParameters().put('status', 'Submitted'); 
       ASI_MFM_SetPaymentStatusController ext5 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(py));
       ext5.setStatus();
       
       // change status as Draft
       PageReference pageRef6 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
       Test.setCurrentPage(pageRef6);
       
       ApexPages.currentPage().getParameters().put('status', 'Draft');
       ASI_MFM_SetPaymentStatusController ext6 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(py));
       ext6.setStatus();
       
       
       Test.stopTest();
       
   }
   
       
   static testMethod void testPaymentManageAll() {
       // ASI_MFM_JP_PORelatedReceiptnPaymentsCtrl
       //Prefix
       List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
       ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=ASI_MFM_JP_TestClassHelper.getFiscalYear());
       prefixList.add(px); 
       ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
       prefixList.add(pxo);
       ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
       prefixList.add(pxa);
       insert prefixList;
       
       //User
       user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
       u.ASI_MFM_Country__c = 'JP';
       update u;
       
       List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
       ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pr);
       ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pro);
       ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pra);
       insert RPList;
       
       //Plan
       ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
                                               ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                               ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
       insert p;
       
       //Brand and Sub-Brand
       ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
       insert brand1;
       ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
       insert subBrand1;
       
       //AP AC Code
       ASI_MFM_AP_Code__c ap = ASI_MFM_JP_TestClassHelper.createJPAPCode();
       ASI_MFM_A_C_Code__c ac = ASI_MFM_JP_TestClassHelper.createJPACCode();
       
       //Account : Customer  Supplier
       List<Account> accToInsert = new List<Account>();
       Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
       accToInsert.add(acc2);
       Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2');           
       accToInsert.add(acc1);
       insert accToInsert;
       
       //Plan line 
       ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                    ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
       insert pi;  
       
       
       //Create PO 
       ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO');
       insert rt;
       
       ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
       insert rtm;
       ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id,Brand_MFM__c=brand1.id);
       insert rtbr;
       
       date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
       ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
       insert podr;
       
       //PO 
       ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id,ASI_MFM_Currency__c='JPY', ASI_MFM_Status__c='Final',
                                            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
       insert po;
       
       
       
       // PO Line
       List<ASI_MFM_PO_Line_Item__c> POLineList = new List<ASI_MFM_PO_Line_Item__c>();
       ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                 ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                 ASI_MFM_G_L_Date__c = Date.today());
       POLineList.add(poi);
       ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                 ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                 ASI_MFM_G_L_Date__c = Date.today());
       POLineList.add(pol);
       insert POLineList;
       
       // PO Receipt 
       ASI_MFM_PO_Receipt__c POR =new ASI_MFM_PO_Receipt__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_JP_PO_Receipt'),ASI_MFM_PO__c=po.id);
       insert POR;
       
       System.debug(Limits.getDMLRows());
       Test.startTest();
       //PO Receipt Item
       List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
       ASI_MFM_PO_Receipt_Item__c PORI = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,ASI_MFM_PO_Line_Item__c=poi.id,ASI_MFM_PO__c=po.id,ASI_MFM_Marketing_Verify__c=true);
       PORIList.add(PORI);
       ASI_MFM_PO_Receipt_Item__c PORI2 = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,ASI_MFM_PO_Line_Item__c=pol.id,ASI_MFM_PO__c=po.id,ASI_MFM_Marketing_Verify__c=true);
       PORIList.add(PORI2);
       insert PORIList;
       
       // Create Payment  
       ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,
                                                      ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');  
       insert py;
       
       
       //Paymet line item
       List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
       ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=82, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id); 
       payLineList.add(pyi);
       ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=pol.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id); 
       payLineList.add(pyi2);
       insert payLineList;
       
       ASI_MFM_JP_PORelatedReceiptnPaymentsCtrl ext1 = new ASI_MFM_JP_PORelatedReceiptnPaymentsCtrl(new ApexPages.StandardController(po));
       
       
       ApexPages.standardSetController sc = new ApexPages.standardSetController(payLineList);
       
       PageReference inputItemsPage = Page.ASI_MFM_JP_PaymentManageAllPage;
       Map<String, String> pageParams = inputItemsPage.getParameters();
       
       
       pageParams.put('id', py.Id);
       Test.setCurrentPageReference(inputItemsPage);
       ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
       
       ASI_MFM_JP_PaymentManageAllCtrl ManageAllController = new ASI_MFM_JP_PaymentManageAllCtrl(stdController);
       ManageAllController.init();
       
       System.currentPageReference().getParameters().put('PARAM_PORLINE_SOURCE_ITEM_ID', (String)PORI2.id);
       ManageAllController.addLineItem();
       
       System.currentPageReference().getParameters().put('PARAM_PAYLine_ID', 'z0');
       ManageAllController.removePaymentLine();
       
       ManageAllController.saveLinetems();
       
       ManageAllController.cancel();
       
       Test.stopTest();
       
   }
   
   
   static testMethod void testPaymentFinanceVerify() {
       // ASI_MFM_JP_PORelatedReceiptnPaymentsCtrl
       //Prefix
       List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
       ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=ASI_MFM_JP_TestClassHelper.getFiscalYear());
       prefixList.add(px); 
       ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
       prefixList.add(pxo);
       ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
       prefixList.add(pxa);
       insert prefixList;
       
       //User
       user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
       u.ASI_MFM_Country__c = 'JP';
       update u;
       
       List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
       ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pr);
       ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pro);
       ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
       RPList.add(pra);
       insert RPList;
       
       //Plan
       ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
                                               ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                               ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
       insert p;
       
       //Brand and Sub-Brand
       ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
       insert brand1;
       ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
       insert subBrand1;
       
       //AP AC Code
       ASI_MFM_AP_Code__c ap = ASI_MFM_JP_TestClassHelper.createJPAPCode();
       ASI_MFM_A_C_Code__c ac = ASI_MFM_JP_TestClassHelper.createJPACCode();
       
       //Account : Customer  Supplier
       List<Account> accToInsert = new List<Account>();
       Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
       accToInsert.add(acc2);
       Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2');           
       accToInsert.add(acc1);
       insert accToInsert;
       
       //Plan line 
       ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                    ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
       insert pi;  
       
       
       //Create PO 
       ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO');
       insert rt;
       
       ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
       insert rtm;
       ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id,Brand_MFM__c=brand1.id);
       insert rtbr;
       
       date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
       ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
       insert podr;
       
       //PO 
       ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id,ASI_MFM_Currency__c='JPY', ASI_MFM_Status__c='Final',
                                            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
       insert po;
       
       
       
       // PO Line
       List<ASI_MFM_PO_Line_Item__c> POLineList = new List<ASI_MFM_PO_Line_Item__c>();
       ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                 ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                 ASI_MFM_G_L_Date__c = Date.today());
       POLineList.add(poi);
       ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                 ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                 ASI_MFM_G_L_Date__c = Date.today());
       POLineList.add(pol);
       insert POLineList;
       
       // PO Receipt 
       ASI_MFM_PO_Receipt__c POR =new ASI_MFM_PO_Receipt__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_JP_PO_Receipt'),ASI_MFM_PO__c=po.id);
       insert POR;
       
       System.debug(Limits.getDMLRows());
       Test.startTest();
       //PO Receipt Item
       List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
       ASI_MFM_PO_Receipt_Item__c PORI = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),ASI_MFM_Amount__c=100,ASI_MFM_PO_Receipt__c=POR.id,ASI_MFM_PO_Line_Item__c=poi.id,ASI_MFM_PO__c=po.id,ASI_MFM_Marketing_Verify__c=true);
       PORIList.add(PORI);
       ASI_MFM_PO_Receipt_Item__c PORI2 = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),ASI_MFM_Amount__c=100,ASI_MFM_PO_Receipt__c=POR.id,ASI_MFM_PO_Line_Item__c=pol.id,ASI_MFM_PO__c=po.id,ASI_MFM_Marketing_Verify__c=true);
       PORIList.add(PORI2);
       insert PORIList;
       
       // Create Payment  
       ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,
                                                      ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Submitted');  
       insert py;
       
       
       //Paymet line item
       List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
       ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=100, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id, ASI_MFM_Voucher_Created__c=false); 
       payLineList.add(pyi);
       ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=pol.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id); 
       payLineList.add(pyi2);
       insert payLineList;
       
       ASI_MFM_JP_FV_Controller ext = new ASI_MFM_JP_FV_Controller();
       ext.init(); 
       ext.Payment_ID='t';
       ext.PayLine_ID='t';
       ext.PORLineID='t';
       ext.PO_ID='t';
       ext.POline_ID='t';
       ext.PaymentStatus='t';
       ext.InvoiceNumber='t';
       ext.Payee='t';
       ext.runSearch();
       ext.save();
       List<Account> remo= ASI_MFM_JP_FV_Controller.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_JP_Customer');
       
       
       
       ApexPages.standardSetController sc = new ApexPages.standardSetController(payLineList);
       
       PageReference inputItemsPage = Page.ASI_MFM_JP_PaymentManageAllPage;
       Map<String, String> pageParams = inputItemsPage.getParameters();
       
       
       pageParams.put('id', py.Id);
       Test.setCurrentPageReference(inputItemsPage);
       ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
       
       ASI_MFM_JP_PaymentManageAllCtrl ManageAllController = new ASI_MFM_JP_PaymentManageAllCtrl(stdController);
       ManageAllController.init();        
       ManageAllController.saveLinetems();
        List<string> remo2= ASI_MFM_JP_PaymentManageAllCtrl.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_JP_Customer');
       
       
       Test.stopTest();
       
   }
   
    
    static testMethod void testGFPaymentTrigger1() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;

        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;     
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        

        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
        ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
        ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxa; 
        
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
        
        ASI_MFM_Route_Type__c mrt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
        insert mrt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=mrt.id, ASI_MFM_Prefix__c=pxa.id);
        insert rtm;
        
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
        
        Test.startTest();
               
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Status__c='Draft');
        insert py;
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
        
        ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
            ASI_MFM_Currency__c='ABD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Status__c='Draft',ASI_MFM_Is_Direct_Payment__c=true);
        insert py1;
        
        ASI_MFM_Payment_Line_Item__c pyi1 = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'), ASI_MFM_Payment__c=py1.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '2234568');
        //insert pyi1;
        
        py.ASI_MFM_Status__c='Final';
        update py;
        
        py1.ASI_MFM_Status__c='Final';
        update py1;

        poi.ASI_MFM_Complete__c = false;
        UPDATE poi;

        set<id> POList = new set<id>();
        POList.add(poi.Id);
        ASI_MFM_Payment_TriggerClass.CompletePOLine(POList);

    }

    static testMethod void TWTest(){
        user u = [SELECT id, userRole.developerName FROM user WHERE id = :userInfo.getUserId()];    
        u.ASI_MFM_Country__c ='TW';
        u.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - HYPER';
        update u;
        
        System.runAs(u) {            
            
            List<Account> listAcc = new List<Account>();
            listAcc.add(new Account(RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'),Name='Test Outlet',ASI_TH_CRM_Region__c ='North'));  
            listAcc.add(new Account(RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'),Name='Test Customer'));  
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));    
            insert listAcc;            
            
            List<ASI_MFM_A_C_Code__c> ACList = new List<ASI_MFM_A_C_Code__c> ();
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',
            ASI_MFM_A_and_P_Tree__c='TOTAL A&P' , ASI_MFM_Reporting_Category__c ='Trade A&P');

            ACList.add(ac);
 
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',
            ASI_MFM_A_and_P_Tree__c='TOTAL A&P' , ASI_MFM_Reporting_Category__c ='MKT A&P');

            ACList.add(ac2);

            insert ACList;
            
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
            insert ap;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
            insert sub;
            
            
            List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
            ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxp);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxo);
            ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxy);
            insert prList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            insert rprList;
            
            ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
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
            
            ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
            insert rtbr;
                        
            List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
            listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                             ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
            //listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
              //                               ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
            insert listPlan;      
            
            List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
            listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =listAcc[4].id,
                                                     ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
            listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =listAcc[4].id,
                                                     ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_Total_Cost__c=2000));
            insert listPL;
            
            List<ASI_MFM_Exchange_Rate__c> listXR = new List<ASI_MFM_Exchange_Rate__c>();
            listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1)); 
            listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='TWD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1)); 
            insert listXR;    
           
            System.debug(Limits.getDMLRows());
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Status__c='Draft',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO'), ASI_MFM_Plan__c=listPlan[0].id,ASI_MFM_Supplier_Name__c = listAcc[3].id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Currency__c='TWD');
            insert po;            
            
            List<ASI_MFM_PO_Line_Item__c> poLinelist= new List<ASI_MFM_PO_Line_Item__c> ();
            ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=listAcc[4].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
            poLinelist.add(poi1);
            ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac2.id, ASI_MFM_Customer_Name__c=listAcc[4].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
            poLinelist.add(poi2);
            insert poLinelist;
            
            // Create Payment  
                ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_TW_Payment'), ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Payment_Date__c=date.today(),
                                                               ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = ListAcc[3].id,ASI_MFM_Status__c='Submitted');  
            insert py;
                        
            Test.startTest(); // start the test
            System.debug(Limits.getDMLRows());
            
            //Paymet line item
            List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_TW_Payment_Line_Item'), 
            ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi1.id, ASI_MFM_Invoice_Date__c = date.today(),
             ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=ListAcc[3].id, ASI_MFM_A_C_Code__c = ac2.id ); 
            payLineList.add(pyi);
            ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_TW_Payment_Line_Item'), ASI_MFM_Payment__c=py.id,ASI_MFM_A_C_Code__c = ac2.id,  ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi2.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=ListAcc[3].id); 
            payLineList.add(pyi2);
            insert payLineList;
            
            update pyi;
            
            delete pyi2;
            

            test.stopTest();
        }
    }

    public static String Current_Fiscal_year;

    private static string getFiscalYear(){
        if (Current_Fiscal_year == null){
            Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
            Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
            Datetime GMTdate = Datetime.now();
            String yearA1 = GMTdate.format('YY');
            Integer yearA0 = Integer.valueOf(yearA1) -1;
            Integer yearA2 = Integer.valueOf(yearA1) +1;

            if (system.today() < orgFiscalYear){
                Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
            }
            else{
                Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
            }
        }

        return Current_Fiscal_year;
    }

}