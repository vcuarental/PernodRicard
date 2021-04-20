@isTest
/* Filename:    ASI_MFM_SG_Class_Test.apxc
* Author:      Elufa
* Purpose:     SG Class Test
* 
* 
* Test Method: testSGInputPlanItemsController
*              testSGInputPOItemsController
ASI_MFM_SG_InputPaymentItems_MassCreateAndUpdateControllerTest
ASI_MFM_SelectPlanPrefixController_SG_TEST
ASI_MFM_Plan_TriggerClass_SG_TEST
testPOTrigger
ASI_MFM_SG_BAverifyTest
ASI_MFM_Payment_TriggerClass_SG_TEST
testGenerateBudgetController
ASI_MFM_SetPlanStatusController_test
testSGGenPOItemsController
*              ASI_MFM_PORelatedPaymentTest: ASI_MFM_SG_PORelatedPaymentsController
*
* History
* -----------------------------------------------------------------------------
* 2015-03-02    tony.ren@elufasys.com      Created
*
*
*/
private class ASI_MFM_SG_Class_Test {
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
    
    
    static testMethod void  ASI_MFM_SG_FV_ControllerTest(){  // Test For ASI_MFM_SG_FV_Controller
        Test.setCurrentPage(Page.ASI_MFM_SG_FV_Page);
        // Start Plan
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');   //  ASI_MFM_HK_Supplier       
        accList.add(acc1);
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');    //ASI_HK_CRM_Outlet       
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name3');       //ASI_MFM_HK_Supplier     
        accList.add(acc3);
        
        insert accList;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO'),name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        
        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment'),name='test', ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Other_than_POSM__c=true,
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Final',ASI_MFM_ETL__c = false);   //acc3.id
        insert py;
        Test.startTest();
        System.debug(Limits.getDMLRows());
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        list<ASI_MFM_Payment_Line_Item__c> paymentLineItems = new list<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id,ASI_MFM_Voucher_Created__c=false);  // it must include ASI_MFM_Payee__c 
        paymentLineItems.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id,ASI_MFM_Payment_Line_Item_Finance_Verify__c=true,ASI_MFM_Voucher_Created__c=false);  // it must include ASI_MFM_Payee__c 
        paymentLineItems.add(pyi2);
        insert paymentLineItems;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SG_FV_Page');
        Test.setCurrentPage(pageRef);
        ASI_MFM_SG_FV_Controller ext = new ASI_MFM_SG_FV_Controller(new ApexPages.StandardController(pyi));
        
        ext.Statu='Final';
        ext.PO_Num=po.name;
        ext.PO_Line_Num='t';
        ext.Py_Num=py.name;
        ext.Py_Line_Num='t';
        ext.Suppl='N';
        ext.Dept='S';
        ext.AC_Code=ac.name;
        ext.gl_fromDate.ASI_MFM_G_L_Date__c=Date.today();
        ext.gl_toDate.ASI_MFM_G_L_Date__c=Date.today(); 
        
        ext.save();
        ext.firstPage();
        ext.lastPage();
        ext.prevPage();
        ext.nextPage();
        ext.runSearch();
        //ext.refresh();
        //ext.init();
        //ext.save();
        //ext.toggleSort();
        test.stopTest(); 
        
    }
    
    
    static testMethod void ASI_MFM_Payment_TriggerClass_SG_TEST() {        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), 
          recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
    
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
              
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
                
        ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Exchange_Rate__c=1, ASI_MFM_Application__c = 'MFM', ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='SGD',ASI_MFM_Country__c='SG');
    
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'),Name='Name3');           
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name3'); // ASI_CRM_SG_Supplier          
        accList.add(acc3);
        
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        //--------------------Change-----------------------
        //list<ASI_MFM_Payment__c>  = new list<ASI_MFM_Payment__c>();
        //map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        //--------------------Change End-----------------------
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
           
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test5', ASI_MFM_Module__c='Payment');
        
        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id);  //ASI_MFM_Payee__c    
        insert py;
        
        ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_GST__c=true);  //ASI_MFM_Payee__c    
        insert py1;
        
        list<ASI_MFM_Payment_Line_Item__c> py_list = new list<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        py_list.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'), ASI_MFM_Payment__c=py1.id, ASI_MFM_Payment_Amount__c=1, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '1234567');
        py_list.add(pyi2);
        insert py_list;
        
        
        //--------------------Change Tony Ren (elufa)-----------------------
        //Payments.add(py);
        py.Id=py1.Id;
        //mapPayments.put(py1.Id, py1);
        //ASI_MFM_Payment_TriggerClass.routineBeforeInsert(Payments);   //Wilken 20180730 SG MFM has its own trigger class
        //ASI_MFM_Payment_TriggerClass.routineAfterUpdate(Payments,mapPayments); //Wilken 20180730 SG MFM has its own trigger class
        //--------------------Change End-----------------------
        // ASI_MFM_SelectPaymentPrefixController
        PageReference PaymentPrefixPage = Page.ASI_MFM_SelectPaymentPrefixPage;
        Test.setCurrentPage(PaymentPrefixPage);
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(py.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', py.id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
        ASI_MFM_SelectPaymentPrefixController SelectPaymentPrefixController = new ASI_MFM_SelectPaymentPrefixController(stdController);
        
        SelectPaymentPrefixController.getPrefixes();
        //SelectPaymentPrefixController.proceed(); //20160901, updated on staging
        
        test.stopTest(); 
        SelectPaymentPrefixController.proceed(); //20160901, updated on staging
    }
    
    
    
    
    static testMethod void ASI_MFM_PDFTestPO() {
        Test.setCurrentPage(Page.ASI_MFM_SG_PO_PDF_Page);
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), recordTypeId = pxrt_map.get('ASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        
        //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Location__c = 'Singapore');
        insert px;
        
        //System.debug('px----- ' + px);
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //System.debug('pr-----' + pr);
        
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today().addMonths(3), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Final');//Draft  Final
        //System.debug('rt' + rt_map);
        
        try {
            insert p;
        } catch(SObjectException se) {
            System.debug('The following exception has occurred: ' + se.getMessage());
        }
        
        //System.debug('S1');
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), name='test3', ASI_MFM_Prefix__c=px.id,ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today());
        insert p3;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        //ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        //insert pi;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');     //ASI_MFM_SG_Supplier            
        insert acc1;
        
        
        
        //--------------------------------Start Test---------------------------
        Test.startTest();
        System.debug(Limits.getDMLRows());
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');             
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        po.name='Name1';
        update po;
        
        acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_Amount__c=1);
        insert poi;
        //System.debug('poi----- ');
        
        ASI_MFM_SG_PO_PDF_PageController ext = new ASI_MFM_SG_PO_PDF_PageController(new ApexPages.StandardController(po));
        ext.POID= po.Id;
        ext.dummyVar = false;
        ext.init();
        test.stopTest(); 
        //------------------------End Test------------------------------------------
        
    }
    
    
    
    
    static testMethod void  ASI_MFM_SG_BAverifyTest(){
        // Test For ASI_MFM_SG_BAverifyController 
        Test.setCurrentPage(Page.ASI_MFM_SG_BAVerify);
    
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), 
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;    
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()]; 
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
    ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Exchange_Rate__c=1, ASI_MFM_Application__c = 'MFM',ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='SGD',ASI_MFM_Country__c='SG');
    
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today(), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
                
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name2');     //ASI_MFM_SG_Supplier            
        insert acc1;
                
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c = 'Final'); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
             
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, 
      ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Amount__c = 100);
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert pxa; 
        
        
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;  
    
        Test.startTest();
        
    System.debug(Limits.getDMLRows());
        
    ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Final', ASI_MFM_G_L_Date__c = date.today());
        insert py;
         
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');    
        insert pyi;         
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SG_BAverify');
        Test.setCurrentPage(pageRef);
        ASI_MFM_SG_BAverifyController ext = new ASI_MFM_SG_BAverifyController(new ApexPages.StandardController(poi));
        
        // Add parameters to page 
        ApexPages.currentPage().getParameters().put('PO_Number', po.name);
        ApexPages.currentPage().getParameters().put('PO_Line_Number', 'P');
        ApexPages.currentPage().getParameters().put('Suppliers_Number', '9');
        ApexPages.currentPage().getParameters().put('Suppliers', acc1.Name);
        ApexPages.currentPage().getParameters().put('A_C_Code', 'A');
        ApexPages.currentPage().getParameters().put('GLdates', '2015-03-02');
        
        
        ext.Plan_Num='1';
        ext.PO_Num='1';
        ext.PO_Line_Num='1';
        ext.Sub_Brands='1';
        ext.Suppliers_Num='1';      
        ext.Suppl='1';
        ext.AC_Code='1';
        ext.GL_date='1';
        ext.Dept='1';
        ext.Fiscal_Years='FY1415';
        
        ext.save();
        ext.firstPage();
        ext.lastPage();
        ext.prevPage();
        ext.nextPage();
        ext.PO_Number=' ';
        ext.runSearch();
        ext.GenerateActualPORemaining();
        //ext.refresh();
        test.stopTest();
    }
    
    
    
    static testMethod void testGenerateBudgetController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), name='test',
                                                ASI_MFM_End_Date__c=Date.today(), ASI_MFM_Plan_Description__c='testPlanDescription',  ASI_MFM_Prefix__c=px.id,
                                                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today());
        insert p;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
                                                                  ,recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');   
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi;          
        list<ASI_MFM_budget__c> b_list = new list<ASI_MFM_budget__c>{new ASI_MFM_budget__c()};
            apexpages.standardSetController sc = new apexpages.standardSetController(b_list);
        ASI_MFM_GenerateBudgetController cx = new ASI_MFM_GenerateBudgetController(sc);
        cx.selected = new ASI_MFM_budget__c(ASI_MFM_fiscal_year__c='FY1415');
        pi = [select recordType.developerName from ASI_MFM_Plan_Line_Item__c where id = :pi.id];
        u.ASI_MFM_Country__c = pi.recordType.developerName.substring(8,10);
        update u;       
        cx.proceed();
    } 
    static testMethod void ASI_MFM_PaymentSubmitControllerTest(){       
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), recordTypeId = pxrt_map.get('ASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Exchange_Rate__c=1, ASI_MFM_Application__c = 'MFM',ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='SGD',ASI_MFM_Country__c='SG');
    
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name3'); // ASI_CRM_SG_Supplier          
        accList.add(acc3);
        
        insert accList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        //--------------------Change-----------------------
        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        //--------------------Change End-----------------------
        
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        
        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        Test.startTest(); //20160901, updated on staging
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft');  //ASI_MFM_Payee__c    
        insert py;
        
        //ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft');  //ASI_MFM_Payee__c    
        //insert py1;
        //Test.startTest(); //20160901, updated on staging
        System.debug(Limits.getDMLRows());
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
        
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=py.id;
        //insert attach;
        
        ASI_MFM_PaymentSubmitController ext1 = new ASI_MFM_PaymentSubmitController(new ApexPages.StandardController(py));
        //ext1.setStatus();
        ext1.proceed();
        Test.stopTest();
        
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
    
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), name='test',  ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c = 'testDescription', ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
        
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name2');           
        
        accountList.add(acc1);
        // SG: Supplier: ASI_CRM_SG_Supplier
        // SG: Outlet: ASI_CRM_SG_Outlet
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'),Name='Name3');           
        accountList.add(acc2);
        insert accountList;
    
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
                
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id, ASI_MFM_Supplier_Name__c = acc1.id); 
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
    
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
              
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c = 100,
      ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
        
        //-----------------------Start Test-----------------------------------        
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert pxa; 
        
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;  
        
    System.debug('Before Test.startTest Limit SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());
       
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Draft');
        insert py;
       
     System.debug('After insert payment header Limit SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());
     
    Test.startTest();
    
    System.debug('After insert payment header Limit: SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());
    
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');    
        insert pyi;
    
        System.debug('After insert payment line Limit: SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());
        
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        pyi_list.add(pyi);
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
        
        // Initialize the page
        
        PageReference testPage = Page.ASI_MFM_SG_InputPaymentItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', py.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_SG_InputPaymentItemsController testCon = new ASI_MFM_SG_InputPaymentItemsController(stdSetController);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        ASI_MFM_SFObjSelectTableController sobjstCon = new ASI_MFM_SFObjSelectTableController();
        
    System.debug('After initialize constructor Limit: SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());
    
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
    
    System.debug('After Controller add new row:  SOQL: ' + Limits.getLimitQueries() + ' DML: ' + Limits.getDMLRows());
        
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_Payment_Line_Item');
        List<ASI_MFM_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();
        
    System.debug('After Controller add blank row: add new row:  SOQL: ' + Limits.getLimitQueries() + ' DML: ' + Limits.getDMLRows());
    
        // Change page number
        sobjstCon.nextPage();
        sobjstCon.lastPage();
        sobjstCon.prevPage();
        sobjstCon.firstPage();
        
    System.debug('After Controller paging:  SOQL: ' + Limits.getLimitQueries() + ' DML: ' + Limits.getDMLRows());
    
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
    
    static testMethod void ASI_MFM_SetPlanStatusController_test() {
        //Test.setCurrentPage(Page.ASI_MFM_PlanDetailPage);
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');  
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'));
        insert ac;   
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
                                                                  ,recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode');
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), name='test',
                                                ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
                                                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
                                                ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Draft');
        insert p;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), name='test2',
                                                 ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
                                                 ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
                                                 ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p1;
        
        
        // Add 3 plan Line Item
        list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = p.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = p.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        insert planLineItems;
        ASI_MFM_Plan__c p3 = [SELECT id,name,ASI_MFM_Status__c,ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where id=:p.id];
        System.debug('p amount:'+p3.ASI_MFM_Plan_Amount__c);
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Submitted');
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p3));
        ext.setStatus();
        ext.setStatus();
        
        test.stopTest(); 
    }
    
    
    static testMethod void ASI_MFM_DeletePaymentTest(){
       
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        
        List<ASI_MFM_Prefix__c> PreList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        PreList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        PreList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        PreList.add(pxa);
        insert PreList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> RPreList= new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPreList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPreList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPreList.add(pra);
        insert RPreList;
        
    ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Exchange_Rate__c=1, ASI_MFM_Application__c = 'MFM',ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='SGD',
    ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today());
    insert ex;
         
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
       
         map<string, id>  rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name3'); // ASI_CRM_SG_Supplier          
        accList.add(acc3);
        
        insert accList;
              
     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Exchange_Rate__c=1);
        insert po;

        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();

       
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
             
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
          ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft', ASI_MFM_Exchange_Rate__c=1);  //ASI_MFM_Payee__c    
        insert py;
        
        
        Test.startTest(); 
      
        System.debug(Limits.getDMLRows());   
       
         ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
        
        delete pyi;
        
        Test.stopTest();
        
    }
    
}