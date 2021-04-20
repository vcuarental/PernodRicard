@isTest

/*
 *  (SeeAllData=true)
 * 
 * */

public class ASI_MFM_TH_PlanTest_Class {
    
    static testMethod void testTHsetPlanStatus() {
        Test.startTest();
        Test.setCurrentPage(Page.ASI_MFM_TH_SetPlanStatusPage);
          
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        // Create Plan 
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
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
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(), ASI_MFM_Currency__c='THB', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Draft',ASI_MFM_Is_FOC_PO__c=true);
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
        
        p1.ASI_MFM_Status__c='Draft';
        update p1;
        
        // Test ASI_MFM_SetPOStatusController
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'Submitted');   // change status as 
        ASI_MFM_TH_SetPlanStatusController ext1 = new ASI_MFM_TH_SetPlanStatusController(new ApexPages.StandardController(p1));
        ext1.setStatus();//System.debug('new_statusTEST:'+ext.new_status);
        test.stopTest(); 
    }
    
    
    

    static testMethod void testTHInputPlanItemsController() {
        // Test ASI_MFM_TH_InputPlanItemsController
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()]; 
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TH_Plan'), name='test',
                                                ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                                                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;       
        
        test.setCurrentPage(page.ASI_MFM_SG_InputPlanItemsPage);
        apexpages.currentPage().getParameters().put('id', p.id); 
        list<ASI_MFM_Plan__c> p_list = new list<ASI_MFM_Plan__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(p_list);  
        ASI_MFM_TH_InputPlanItemsController cx = new ASI_MFM_TH_InputPlanItemsController(sc);             
    }

    static testMethod void ASI_MFM_PDFTestPlan() {  // Test For ASI_MFM_TH_Plan_PDF_Controller          modify from HK MFM TEST class
        Test.startTest();
        Test.setCurrentPage(Page.ASI_MFM_TH_PLan_PDF_PAGE);
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;

        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);// ASI_HK_CRM_Sub_brand    ASI_TH_CRM_Outlet
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id);
        insert p;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test');
        insert ac;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC2', ASI_MFM_A_C_Code__c='5210.STK1');
        insert ac2;
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');   //ASI_HK_CRM_Outlet         ASI_TH_CRM_Wholesaler
        insert acc2;    // same with the ASI_MFM_Customer_Name__c in  ASI_MFM_TH_InputPlanItemsPage
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_TH_Region__c='GBKK');
        insert pi;
        
        ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
        ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_TH_Region__c='GBKK');
        insert pi2;
        ASI_MFM_TH_Plan_PDF_Controller ext = new ASI_MFM_TH_Plan_PDF_Controller(new ApexPages.StandardController(p));
        ext.currentHeaderId= p.Id;   // Get Plan ID 
        ext.dummyVar = false;
        ext.init(); // initialization of the class    //ASI_MFM_TH_Plan_PDF_PageController ext = new ASI_MFM_TH_Plan_PDF_PageController(new ApexPages.StandardController(p));
        test.stopTest(); 
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
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_POSM_Balance__c=true,
            ASI_MFM_Currency__c='THB', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id, ASI_MFM_Invoice_Due_Date__c=date.today());   //   acc2.id
        insert py;
        
        //Paymet line item
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id);  // it must include ASI_MFM_Payee__c 
        insert pyi;
        
        // Test PDF class
        ASI_MFM_TH_Payment_PDF_PageController ext = new ASI_MFM_TH_Payment_PDF_PageController(new ApexPages.StandardController(py));
        ext.paymentID= py.Id; // initialization of the class
        ext.dummyVar = false;
        ext.init();
     
        // Test ASI_MFM_SetPOStatusController
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'Final');   // change status as draft
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();//System.debug('new_statusTEST:'+ext.new_status);
        test.stopTest(); 
    }
    
    static testMethod void PlanMassCreateAndUpdateTest(){
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);// ASI_HK_CRM_Sub_brand    ASI_TH_CRM_Outlet
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test',
                                                ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
                                                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
                                                ASI_MFM_Prefix__c=px.id);
        insert p;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test');
        insert ac;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC2', ASI_MFM_A_C_Code__c='5210.STK1');
        insert ac2;
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');   //ASI_HK_CRM_Outlet         ASI_TH_CRM_Wholesaler
        insert acc2;    // same with the ASI_MFM_Customer_Name__c in  ASI_MFM_TH_InputPlanItemsPage
        
        list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_TH_Region__c='GBKK');
        planLineItems.add(pi);
        
        ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
                                                                      ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_TH_Region__c='GBKK');
        planLineItems.add(pi2);
        insert planLineItems;
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(planLineItems);
        
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_TH_InputPlanItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', p.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_TH_InputPlanItemsController testCon = new ASI_MFM_TH_InputPlanItemsController(stdSetController);
        
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=F&width=200px,ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_A_C_Code__c&req=T&width=160px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Remarks__c&req=F&width=240px, ASI_MFM_Total_Cost__c&req=F&width=105px, ASI_MFM_Month_1_Cost__c&req=F&width=80px, ASI_MFM_Month_2_Cost__c&req=F&width=80px, ASI_MFM_Month_3_Cost__c&req=F&width=80px, ASI_MFM_Month_4_Cost__c&req=F&width=80px, ASI_MFM_Month_5_Cost__c&req=F&width=80px, ASI_MFM_Month_6_Cost__c&req=F&width=80px, ASI_MFM_Month_7_Cost__c&req=F&width=80px, ASI_MFM_Month_8_Cost__c&req=F&width=80px, ASI_MFM_Month_9_Cost__c&req=F&width=80px, ASI_MFM_Month_10_Cost__c&req=F&width=80px, ASI_MFM_Month_11_Cost__c&req=F&width=80px, ASI_MFM_Month_12_Cost__c&req=F&width=80px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + p.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + p.Id;
        mcauCon.cancelLink = '/' + p.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c';
        Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TH_Plan_Line_Item');
        
        mcauCon.commitAll();
        
    }
    
    
    static testMethod void ASI_MFM_SetPlanStatusTest() {  //  Set Plan status as Draft when there is PO
        
        Test.setCurrentPage(Page.ASI_MFM_TH_PLan_PDF_PAGE);
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415', recordTypeId = pxrt_map.get('ASI_MFM_TH_Prefix')); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;  
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today().addMonths(3), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Final');//Final  Draft
        try {
            insert p;
        } catch(SObjectException se) {
            System.debug('The following exception has occurred: ' + se.getMessage());
        }
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), ASI_MFM_Status__c='Draft',name='test3', ASI_MFM_Prefix__c=px.id,ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today());
        insert p3;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'),ASI_TH_CRM_Active__c=true);
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');           
        insert acc2;
        
        
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
        
        ApexPages.currentPage().getParameters().put('status', 'Draft');   // change Plan status as draft
        ASI_MFM_SetPlanStatusController ext1 = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p));
        ext1.setStatus();
        
        test.stopTest(); 
        
    }
    
    
    
    static testMethod void ASI_MFM_PDFTestPlan2() {  // Test For ASI_MFM_TH_Plan_PDF_Controller          modify from HK MFM TEST class
        Test.startTest();
        Test.setCurrentPage(Page.ASI_MFM_TH_PLan_PDF_PAGE);
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);// ASI_HK_CRM_Sub_brand    ASI_TH_CRM_Outlet
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test',
                                                ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
                                                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
                                                ASI_MFM_Prefix__c=px.id);
        insert p;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test');
        insert ac;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC2', ASI_MFM_A_C_Code__c='5210.STK1');
        insert ac2;
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');   //ASI_HK_CRM_Outlet         ASI_TH_CRM_Wholesaler
        insert acc2;    // same with the ASI_MFM_Customer_Name__c in  ASI_MFM_TH_InputPlanItemsPage
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_TH_Region__c='GBKK');
        insert pi;
        
        ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
                                                                      ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_TH_Region__c='GBKK');
        insert pi2;
        ASI_MFM_TH_Plan_PDF_Controller ext = new ASI_MFM_TH_Plan_PDF_Controller(new ApexPages.StandardController(p));
        ext.currentHeaderId= p.Id;   // Get Plan ID 
        ext.dummyVar = false;
        ext.init(); // initialization of the class
        //ASI_MFM_TH_Plan_PDF_PageController ext = new ASI_MFM_TH_Plan_PDF_PageController(new ApexPages.StandardController(p));
        test.stopTest(); 
    }
    
     static testMethod void ASI_MFM_Plan_main_TEST() {     // Test  ASI_MFM_SelectPlanPrefixController   ASI_MFM_Plan_TriggerClass  AND   ASI_MFM_PlanLineItem_TriggerClass
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
        
        ASI_MFM_Budget_Setting__c SettingB = new ASI_MFM_Budget_Setting__c();
        SettingB.ASI_MFM_Budget_Type__c='LE4';
        SettingB.name ='TH';
        insert SettingB;
        // Prefix : THP
        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='THP14',ASI_MFM_Module__c='Plan',ASI_MFM_Fiscal_year__c='FY1415',ASI_MFM_Region__c=true );//ASI_MFM_TR_Rec_Type__c='region'
        insert prefix1 ;
        
        ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,ASI_MFM_Role_Name__c =u.userRole.developerName);            
        insert prefixChild1;
        
        // Add Two AC Code
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_TH_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        insert ac1;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_TH_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
        insert ac2;
        
        //  ASI MFM Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=prefix1.id);
        insert rtm;
        
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
        
        
        
        
        // * Create 2 Plan *
        ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='TH131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_TH_Plan'),ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest',ASI_MFM_TH_Region__c='UPC;STH;WS;GBKK(High);GBKK(Low)', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c='Draft');
        insert Plan1;
        
        ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='TH131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_TH_Plan'),ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest',ASI_MFM_TH_Region__c='UPC;STH', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c='Final');
        insert Plan2;
        
        // Plan2.ASI_MFM_Status__c='Submitted';
        //update Plan2;
        
        // *  Create 2 Plan *
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'),ASI_TH_CRM_Active__c=true); // ASI_CRM_SG_Sub_brand
        insert subBrand1;
        
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'),ASI_TH_CRM_Active__c=true);
        insert subBrand2;
        
        // Create Budget
        ASI_MFM_Budget__c budget1 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id,ASI_MFM_Department__c='THP',ASI_MFM_Type__c='Budget'
                                                          ,ASI_MFM_Fiscal_Year__c='FY1415',ASI_MFM_P1_Amount__c=10000000,ASI_MFM_P2_Amount__c=10000000,ASI_MFM_P3_Amount__c=10000000
                                                          ,recordTypeId=budget_map.get('ASI_MFM_TH_Budget'));
        insert budget1;
        
        
        // Create AC Code
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_TH_A_C_Code'));
        insert ac;
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_TH_CRM_Outlet'),Name='Name3');             
        insert acc2;
        
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
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
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
                                                                                ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                                                ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                                                ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                                                ASI_MFM_A_C_Code__c=ac.id);
        
        ASI_MFM_Plan_Line_Item__c planLineItems2= new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
                                                                                ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello144'
                                                                                ,recordTypeId=planLineItem_map.get('ASI_MFM_TH_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                                                ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                                                ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                                                ASI_MFM_A_C_Code__c=ac.id);
        planLineItems2.Id=planLineItems1.Id;
        
        list<ASI_MFM_Plan_Line_Item__c> planLineItemsnew1 = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineItemsnew1.add(planLineItems1);
        
        map<Id,ASI_MFM_Plan_Line_Item__c>mapPlanlineitems =new map<Id, ASI_MFM_Plan_Line_Item__c>();
        mapPlanlineitems.put(planLineItems2.Id,planLineItems2);
        //Plan and Plan Line items finished
        
        
        Test.startTest();
        
        System.runAs(u){ // Test Trigger
            ASI_MFM_Plan_TriggerClass.routineAfterDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterUpsert(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpdate(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpsert(plans, mapPlans);
            
            ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(planLineItemsnew1, mapPlanlineitems);
        }
        // Test ASI_MFM_SelectPlanPrefixController    
        PageReference planPrefixPage = Page.ASI_MFM_SelectPlanPrefixPage;
        Test.setCurrentPage(planPrefixPage);
        system.debug('ayooo ' + plan1.recordtypeid);
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(plan1.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', plan1.id);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);        
        ASI_MFM_SelectPlanPrefixController SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
        
        SelectPlanPrefixController.getPrefixes();
        SelectPlanPrefixController.proceed();
        
        
        
        Test.stopTest();
    }
    
    
    
    
}