@istest
public class ASI_MFM_SG_PaymentTestClass {
    
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
    
    static testMethod void testGetPrefixes() { 
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
        
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c ='SG';
        update u;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Plan', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Prefix__c Payment_px = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert Payment_px;
        ASI_MFM_Role_Prefix_Relationship__c Payment_pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=Payment_px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert Payment_pr;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='PO', ASI_MFM_Department__c = 'SG Brand Marketing');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='teste', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        Account acc2 = new Account(recordTypeId= Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_Exchange_Rate__c = 1.12, ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id
                                            );
        insert po;   
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');   
        insert ac;
        
        //20180909 Introv
        List<User> SGUsers = new List<User>([SELECT Id FROM User WHERE CompanyName Like '%singapore%' limit 20]);
        
        List<ASI_MFM_Sub_brand__c> subList = new List<ASI_MFM_Sub_brand__c>();
        subList.add(new ASI_MFM_Sub_brand__c(name='testSubBrand'));
        subList.add(new ASI_MFM_Sub_brand__c(name='testSubBrand', ownerId = SGUsers[0].id));
        subList.add(new ASI_MFM_Sub_brand__c(name='testSubBrand', ownerId = SGUsers[1].id));
        subList.add(new ASI_MFM_Sub_brand__c(name='testSubBrand', ownerId = SGUsers[2].id));
        subList.add(new ASI_MFM_Sub_brand__c(name='testSubBrand', ownerId = SGUsers[3].id));
        subList.add(new ASI_MFM_Sub_brand__c(name='testSubBrand', ownerId = SGUsers[4].id));
        subList.add(new ASI_MFM_Sub_brand__c(name='testSubBrand', ownerId = SGUsers[5].id));
        insert subList;
        
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        
        poLineList.add(new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subList[0].id, ASI_MFM_G_L_Date__c = Date.today()));
        
        poLineList.add(new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subList[1].id, ASI_MFM_G_L_Date__c = Date.today()));
        poLineList.add(new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subList[2].id, ASI_MFM_G_L_Date__c = Date.today()));
        poLineList.add(new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subList[3].id, ASI_MFM_G_L_Date__c = Date.today()));
        poLineList.add(new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subList[4].id, ASI_MFM_G_L_Date__c = Date.today()));
        poLineList.add(new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subList[5].id, ASI_MFM_G_L_Date__c = Date.today()));
        
        
        insert poLineList;
    System.debug('Before Test.startTest Limit SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());
    
        test.startTest();
        
    System.debug('After Test.startTest Limit SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());
        System.runAs(u){  
            PageReference poPrefixPage = Page.ASI_MFM_SG_MakePaymentPage;
            Test.setCurrentPage(poPrefixPage);
            //system.debug('ayooo ' + plan1.recordtypeid);
            ApexPages.currentPage().getParameters().put('RecordType', po.recordtypeid);
            ApexPages.currentPage().getParameters().put('id', po.id);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);       
      
            ASI_MFM_SG_MakePaymentController MakePaymentController = new ASI_MFM_SG_MakePaymentController(stdController);
      
      System.debug('After initialize constructor Limit SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());      
      
            MakePaymentController.getPrefixes();
            MakePaymentController.pa.ASI_MFM_Invoice_Date__c=system.today();
            MakePaymentController.pa.ASI_MFM_Invoice_Number__c='T1233';
            
      System.debug('After controller get prefixes Limit SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());      
      
            MakePaymentController.proceed();
            
      System.debug('After MakePaymentController Limit SOQL: ' + Limits.getQueries() + ' DML: ' + Limits.getDMLRows());
      
            ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(po);        
            ASI_MFM_SG_MakePaymentController MakePaymentController2 = new ASI_MFM_SG_MakePaymentController(stdController2);
            MakePaymentController2.getPrefixes();
            
            MakePaymentController2.proceed();            
        }
        test.stopTest();
    }
  
    static testMethod void testGetPrefixes_ExceptionalCase_1() { 
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
        
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c ='SG';
        update u;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
    
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Plan', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
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
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_Exchange_Rate__c = 1.12, ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;   
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');   
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        System.runAs(u){  
            PageReference poPrefixPage = Page.ASI_MFM_SG_MakePaymentPage;
            Test.setCurrentPage(poPrefixPage);
            //system.debug('ayooo ' + plan1.recordtypeid);
            ApexPages.currentPage().getParameters().put('RecordType', po.recordtypeid);
            ApexPages.currentPage().getParameters().put('id', po.id);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_SG_MakePaymentController MakePaymentController = new ASI_MFM_SG_MakePaymentController(stdController);
            MakePaymentController.getPrefixes();
            MakePaymentController.proceed();

        }
        test.stopTest();
    }
    
    
    static testMethod void testGetPrefixes_ExceptionalCase_2() { 
        
        
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
        
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c ='SG';
        update u;
        
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        
        
          
          
        
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Plan', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        
        
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        
        
        ASI_MFM_Prefix__c Payment_px = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert Payment_px;
        ASI_MFM_Role_Prefix_Relationship__c Payment_pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=Payment_px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert Payment_pr;
        
        ASI_MFM_Prefix__c Payment1_px = new ASI_MFM_Prefix__c(name='test12', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert Payment1_px;
        ASI_MFM_Role_Prefix_Relationship__c Payment1_pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=Payment1_px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert Payment1_pr;
        
        
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
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_Exchange_Rate__c = 1.12, ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;   
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');   
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        System.runAs(u){  
            PageReference poPrefixPage = Page.ASI_MFM_SG_MakePaymentPage;
            Test.setCurrentPage(poPrefixPage);
            //system.debug('ayooo ' + plan1.recordtypeid);
            ApexPages.currentPage().getParameters().put('RecordType', po.recordtypeid);
            ApexPages.currentPage().getParameters().put('id', po.id);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_SG_MakePaymentController MakePaymentController = new ASI_MFM_SG_MakePaymentController(stdController);
            MakePaymentController.getPrefixes();
            MakePaymentController.proceed();
        }
        test.stopTest();
    }
     
     
     static testMethod void testGetPrefixes_ExceptionalCase_3() { // Exceiptional Case: px_list.size() >1
        
        
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
        
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c ='SG';
        update u;
        
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        
        
          
          
        
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Plan', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        
        
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        
        /*
        ASI_MFM_Prefix__c Payment_px = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert Payment_px;
        ASI_MFM_Role_Prefix_Relationship__c Payment_pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=Payment_px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert Payment_pr;
        */
        
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
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_Exchange_Rate__c = 1.12, ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;   
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');   
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        System.runAs(u){  
            PageReference poPrefixPage = Page.ASI_MFM_SG_MakePaymentPage;
            Test.setCurrentPage(poPrefixPage);
            //system.debug('ayooo ' + plan1.recordtypeid);
            ApexPages.currentPage().getParameters().put('RecordType', po.recordtypeid);
            ApexPages.currentPage().getParameters().put('id', po.id);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_SG_MakePaymentController MakePaymentController = new ASI_MFM_SG_MakePaymentController(stdController);
            MakePaymentController.getPrefixes();
            MakePaymentController.proceed();
        }
        test.stopTest();
    }
    
    
    static testMethod void testGetPrefixes_ExceptionalCase_4() { //Exceiptional Case: Missing User-asi_mfm_country__c
        
        
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
        
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c ='';
        update u;
        
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         

        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Plan', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        
        
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        
        
        ASI_MFM_Prefix__c Payment_px = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert Payment_px;
        ASI_MFM_Role_Prefix_Relationship__c Payment_pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=Payment_px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert Payment_pr;
        
        ASI_MFM_Prefix__c Payment1_px = new ASI_MFM_Prefix__c(name='test12', ASI_MFM_Inactive__c = false, ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert Payment1_px;
        ASI_MFM_Role_Prefix_Relationship__c Payment1_pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=Payment1_px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert Payment1_pr;
        
        
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
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_Exchange_Rate__c = 1.12, ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;   
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');   
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        System.runAs(u){  
            PageReference poPrefixPage = Page.ASI_MFM_SG_MakePaymentPage;
            Test.setCurrentPage(poPrefixPage);
            //system.debug('ayooo ' + plan1.recordtypeid);
            ApexPages.currentPage().getParameters().put('RecordType', po.recordtypeid);
            ApexPages.currentPage().getParameters().put('id', po.id);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_SG_MakePaymentController MakePaymentController = new ASI_MFM_SG_MakePaymentController(stdController);
            MakePaymentController.getPrefixes();
            MakePaymentController.proceed();
        }
        test.stopTest();
    }
    


}