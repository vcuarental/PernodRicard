@isTest
/*********************************************************************************
 * Name:ASI_MFM_SG_PDF_Test
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/07/2018       Wilken              [WL 1.0] Reduce SOQL usage in ASI_MFM_Payment_TriggerClass_SG_Test2
*********************************************************************************/
private class ASI_MFM_SG_PDF_Test {  

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
 
    static testMethod void  ASI_MFM_SG_GLDateSettingTest(){
        List<ASI_MFM_GL_Date_Setting__c> GLDateList  = new List<ASI_MFM_GL_Date_Setting__c>();
        ASI_MFM_GL_Date_Setting__c d1 = new ASI_MFM_GL_Date_Setting__c(name='1',ASI_MFM_Country__c='SG',ASI_MFM_Start_Date__c=Date.today(),ASI_MFM_End_Date__c=Date.today().addMonths(1),ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Month__c=1);
        GLDateList.add(d1);
        ASI_MFM_GL_Date_Setting__c d2 = new ASI_MFM_GL_Date_Setting__c(name='2',ASI_MFM_Country__c='SG',ASI_MFM_Start_Date__c=Date.today().addMonths(1),ASI_MFM_End_Date__c=Date.today().addMonths(2),ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Month__c=1);
        GLDateList.add(d2);
        
        insert GLDateList;
        
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SG_GL_Date_SettingPage');
        Test.setCurrentPage(pageRef);
        ASI_MFM_SG_GL_Date_SettingController ext = new ASI_MFM_SG_GL_Date_SettingController();
        ext.save();
        ext.init();
        ext.refresh();
        //ext.setting.insertSetting();
        test.stopTest();
    }

    static testMethod void ASI_MFM_PORelatedPaymentTest() {
        
        Test.setCurrentPage(Page.ASI_MFM_SG_Payment_PDF_Page);
        
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), recordTypeId = pxrt_map.get('ASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        //System.debug('------S1--------');
        //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
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

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Department__c = 'SG Brand Marketing');
        insert px;
        
        
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
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Department__c = 'SG Brand Marketing');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        
        //------------------------------------------Test start ---------------------------------------------
        Test.startTest();
    System.debug(Limits.getDMLRows());
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
 
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today()
                                                                  , ASI_MFM_Amount__c = 100//20180620 Introv
                                                                 );
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Department__c = 'SG Brand Marketing');

        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;

        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        
         System.debug('----- ASI_MFM_Supplier_Name__c ----------'+acc3.id);
        
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id);  //ASI_MFM_Payee__c    
        insert py;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
    
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(
                    recordTypeId=rt_map.get('ASI_MFM_SG_Payment_Line_Item'), 
                    ASI_MFM_Paid_Amount_in_PO_Currency__c = 10,
                    ASI_MFM_Payment__c=py.id, 
                    ASI_MFM_Payment_Amount__c=10, 
                    ASI_MFM_PO_Line_Item__c=poi.id, 
                    ASI_MFM_Invoice_Date__c = date.today(), 
                    ASI_MFM_Invoice_Number__c = '123456');
                    
    system.debug('recordTypeId: ' + pyi.recordTypeId + ' ASI_MFM_Payment__c: ' + py.id + ' ASI_MFM_PO_Line_Item__c: ' + poi.id);
        insert pyi;
        
        ASI_MFM_SG_PORelatedPaymentsController ext2 = new ASI_MFM_SG_PORelatedPaymentsController(new ApexPages.StandardController(po));
        
        test.stopTest(); 
        //---------------------------------------------Test End ----------------------------------------------------------
    }
   
    


     static testMethod void ASI_MFM_Payment_TriggerClass_SG_Test2() {
        /*[WL 1.0] BEGIN*/
    List<ASI_MFM_GL_Date_Setting__c> GLDateList  = new List<ASI_MFM_GL_Date_Setting__c>();
    
        ASI_MFM_GL_Date_Setting__c d1 = new ASI_MFM_GL_Date_Setting__c(name='1',ASI_MFM_Country__c='SG',ASI_MFM_Start_Date__c=Date.today(),ASI_MFM_End_Date__c=Date.today().addMonths(1),ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Month__c=1);
        GLDateList.add(d1);
        ASI_MFM_GL_Date_Setting__c d2 = new ASI_MFM_GL_Date_Setting__c(name='2',ASI_MFM_Country__c='SG',ASI_MFM_Start_Date__c=Date.today().addMonths(1),ASI_MFM_End_Date__c=Date.today().addMonths(2),ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Month__c=1);
        GLDateList.add(d2);
        
        insert GLDateList;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), 
      recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
    
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), 
      ASI_MFM_End_Date__c=date.today(), ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;

        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
    
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRTId('AccountASI_CRM_SG_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRTId('AccountASI_CRM_SG_Outlet'),Name='Name3');           
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId = Global_RecordTypeCache.getRTId('AccountASI_CRM_SG_Supplier'),Name='Name3'); // ASI_CRM_SG_Supplier          
        accList.add(acc3);
        
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
            ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
            
        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
               
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
 
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
              
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,
                                                                   ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today()
                                                                   , ASI_MFM_Amount__c = 100//20180620 Introv
                                                                  );
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test5', ASI_MFM_Module__c='Payment', ASI_MFM_Location__c = 'Singapore');

        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;
 
        Test.startTest();
 
    System.debug(Limits.getDMLRows());
    
        List<ASI_MFM_Payment__c> pylist = new List<ASI_MFM_Payment__c>();
        
    ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Payment__cASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Submitted');  //ASI_MFM_Payee__c    
        pylist.add(py);
       
        ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Payment__cASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_GST__c=true);  //ASI_MFM_Payee__c    
    pylist.add(py1);
        
    insert pylist;
       
        list<ASI_MFM_Payment_Line_Item__c> py_list = new list<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(
                          recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'), 
                          ASI_MFM_Payment__c=py.id, 
                          ASI_MFM_Payment_Amount__c=10, 
                          ASI_MFM_Paid_Amount_in_PO_Currency__c=10, 
                          ASI_MFM_PO_Line_Item__c=poi.id, 
                          ASI_MFM_Invoice_Date__c = date.today(), 
                          ASI_MFM_Invoice_Number__c = '123456');
        py_list.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(
                          recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'), 
                          ASI_MFM_Payment__c=py1.id, 
                          ASI_MFM_Payment_Amount__c=1, 
                          ASI_MFM_Paid_Amount_in_PO_Currency__c=1, 
                          ASI_MFM_PO_Line_Item__c=poi.id, 
                          ASI_MFM_Invoice_Date__c = date.today(), 
                          ASI_MFM_Invoice_Number__c = '1234567');
        py_list.add(pyi2);
        insert py_list;
         
        System.debug(Limits.getDMLRows());
        py.ASI_MFM_Status__c='Final';
        update py;
        
        test.stopTest(); 
    }
    

     
}