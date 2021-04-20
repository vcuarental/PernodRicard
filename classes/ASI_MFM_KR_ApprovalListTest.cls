/*
Test : ASI_MFM_KR_ApprovalListController

*/
@istest

public class ASI_MFM_KR_ApprovalListTest {
    /*
     * Test Class for ASI_MFM_SetPOStatusController  Start
     * 
     * */ 
    
        
    
    public static string getFiscalYear(){
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
   
    
    /*
    
    static testMethod void PHSetPOSatus_Test3(){
          // Test ASI_MFM_PH_Payment_TriggerClass
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(pol);
        insert poLineList;
  
        
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Submitted');  
        insert py;
        
        
        Test.startTest(); // start the test
        System.debug(Limits.getDMLRows());
        
        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id,ASI_MFM_Complete_POL__c = true); 
        payLineList.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi2);
        insert payLineList;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'Complete');   // change status as draft
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();
        
        test.stopTest(); 
    }
    
     
    static testMethod void PHSetPOSatus_Test() {
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_PH_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        insert prefixList;
        
        
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);

        insert RPList;
        
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addDays(10),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Draft');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        insert poLineList;
  

        
        
        
        Test.startTest();
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'Complete');   // change status as draft
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();
        test.stopTest(); 
    }
   
    static testMethod void PHSetPOSatus_Test2() {
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_PH_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        insert prefixList;
        
        
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);

        insert RPList;
        
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addDays(10),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        insert poLineList;
  

        
        
        
        Test.startTest();
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'Complete');   // change status as draft
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();
        test.stopTest(); 
    }
    
       
    static testMethod void ASI_MFM_TRPO_TriggerTest() { //To  test ASI_MFM_TR_PO_TriggerClass  
        
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TR';
        update u;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TR', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        // Set Plan Prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='TR14', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
        insert rtm;
        
        // ASI MFM Route Rule Details Set Approver 
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        insert rrd;
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        insert rrd2;
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        insert rrd3;
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        insert rrd4;
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
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
        
        
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final',ASI_MFM_Approver_1__c=u.id);
        insert p1;
        //Set PO prefix
        px = new ASI_MFM_Prefix__c(name='TRPO', ASI_MFM_Module__c='PO',ASI_MFM_Region__c=true );
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rts;
        
        ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
        insert rtms;
        
        // ASI MFM  PO Route Rule Details Set Approver 
        List<ASI_MFM_Route_Rule_Detail__c> RRDList= new List<ASI_MFM_Route_Rule_Detail__c> ();
        ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1);
        RRDList.add(rrds);
        ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds2);
        ASI_MFM_Route_Rule_Detail__c rrds3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds3);
        ASI_MFM_Route_Rule_Detail__c rrds4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds4);
        ASI_MFM_Route_Rule_Detail__c rrds5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds5);
        ASI_MFM_Route_Rule_Detail__c rrds6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds6);
        ASI_MFM_Route_Rule_Detail__c rrds7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds7);
        ASI_MFM_Route_Rule_Detail__c rrds8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds8);
        ASI_MFM_Route_Rule_Detail__c rrds9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds9);
        ASI_MFM_Route_Rule_Detail__c rrds10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds10);
        insert RRDList;
        
        // Test Start
        test.startTest();
        
        // Create PO
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Customer'),Name='Name3');        
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TR_Supplier'),Name='Name2'); 
        insert acc1;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Responsible_By__c=u.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_Currency__c='HKD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_TR_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_Complete__c = true,ASI_MFM_Amount__c=123);// ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,   
        insert poi;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'draft');   // change status as draft
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();
        
        
        test.stopTest();
    }
    
    
    
    static testMethod void SetPOSatus_Test() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='ASI_TR_Purchasing');
        insert Role_Test;
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', UserRoleid =Role_Test.id,
                          LocaleSidKey='en_US', ProfileId = p.Id,ASI_MFM_Country__c = 'TR',BypassTriggers__c='ASI_MFM_TR_ByPassTrigger',
                          TimeZoneSidKey='America/Los_Angeles', UserName='test4@tasdf.com');
        insert u;
        
        System.runAs(u){ 
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TR', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        // Set Plan Prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='TR14', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='ASI_TR_Purchasing');
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
        insert rtm;
        
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final',ASI_MFM_Approver_1__c=u.id);
        insert p1;
        //Set PO prefix
        px = new ASI_MFM_Prefix__c(name='TRPO', ASI_MFM_Module__c='PO',ASI_MFM_Region__c=true );
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='ASI_TR_Purchasing');
        insert pr;
        
        ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rts;
        
        ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
        insert rtms;
        
        // ASI MFM  PO Route Rule Details Set Approver 
        List<ASI_MFM_Route_Rule_Detail__c> RRDList= new List<ASI_MFM_Route_Rule_Detail__c> ();
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        RRDList.add(rrd);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrd2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        RRDList.add(rrd3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        RRDList.add(rrd4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        RRDList.add(rrd5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        RRDList.add(rrd6); 
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        RRDList.add(rrd7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        RRDList.add(rrd8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        RRDList.add(rrd9);
        ASI_MFM_Route_Rule_Detail__c rrd10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=100, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=10);
        RRDList.add(rrd10);
        ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1);
        RRDList.add(rrds);
        ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds2);
        ASI_MFM_Route_Rule_Detail__c rrds3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds3);
        ASI_MFM_Route_Rule_Detail__c rrds4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds4);
        ASI_MFM_Route_Rule_Detail__c rrds5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds5);
        ASI_MFM_Route_Rule_Detail__c rrds6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds6);
        ASI_MFM_Route_Rule_Detail__c rrds7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds7);
        ASI_MFM_Route_Rule_Detail__c rrds8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds8);
        ASI_MFM_Route_Rule_Detail__c rrds9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds9);
        ASI_MFM_Route_Rule_Detail__c rrds10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds10);
        insert RRDList;
        
        
        
        // Create PO
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');  
        List<Account> AccList = new List<Account>();
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Customer'),Name='Name3');        
        AccList.add(acc2);
        
        Account acc1 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Supplier'),Name='Name2'); 
        AccList.add(acc1);
        insert AccList;
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Responsible_By__c=u.Id,
                                             recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO'),
                                             ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id,
                                             ASI_MFM_Status__c ='Final',
                                             ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_Currency__c='HKD',
                                             ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),
                                             ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_TR_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);
        insert sub;
        test.startTest(); //introv 20180212
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'),
                                                                  ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_A_C_Code__c=ac.id, 
                                                                  ASI_MFM_Customer_Name__c=acc2.id, 
                                                                  ASI_MFM_List_Item_Description__c='testDescription',
                                                                  ASI_MFM_Sub_brand_Code__c=sub.id, 
                                                                  ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Synced__c=true,
                                                                  ASI_MFM_Complete__c = true,ASI_MFM_Amount__c=123);  
        insert poi;
        
        ASI_MFM_PO_Receipt__c POR =new ASI_MFM_PO_Receipt__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),
                                                             ASI_MFM_PO__c=po.id,ASI_MFM_Status__c='Draft');
        insert POR;
        
        //test.startTest(); //introv 20180212
        System.debug(Limits.getDMLRows());
        
        List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
        ASI_MFM_PO_Receipt_Item__c PORI = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),
                                                                         ASI_MFM_Amount__c=10,
                                                                         ASI_MFM_PO_Receipt__c=POR.id,
                                                                         ASI_MFM_PO_Line_Item__c=poi.id,
                                                                         ASI_MFM_ACC_Verify__c =false,ASI_MFM_Receipt_Date__c=date.today());
        PORIList.add(PORI);
        ASI_MFM_PO_Receipt_Item__c PORI2 = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),
                                                                          ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,
                                                                          ASI_MFM_PO_Line_Item__c=poi.id,
                                                                          ASI_MFM_ACC_Verify__c =true,
                                                                          ASI_MFM_Receipt_Date__c=date.today());
        PORIList.add(PORI2);
        insert PORIList;

        // Test Start
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('status', 'Voided');  
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        test.stopTest();
        }
    }
    
    */
    /*
    static testMethod void SetPOSatus_Test2() {
       // test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
       
            
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='ASI_TR_Purchasing');
        insert Role_Test;
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', UserRoleid =Role_Test.id,
                          LocaleSidKey='en_US', ProfileId = p.Id,ASI_MFM_Country__c = 'TR',BypassTriggers__c='ASI_MFM_TR_ByPassTrigger',
                          TimeZoneSidKey='America/Los_Angeles', UserName='test4@tasdf.com');
        insert u;
        
        System.runAs(u){ 
            
            ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TR', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
            insert xr;         
            
            // Set Plan Prefix
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='TR14', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
            insert px;
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='ASI_TR_Purchasing');
            insert pr;
            
            ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
            insert rt;
            ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
            insert rtm;
            
            
            
            ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                     ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName',
                                                     ASI_MFM_Status__c = 'Final',ASI_MFM_Approver_1__c=u.id);
            insert p1;
            //Set PO prefix
            px = new ASI_MFM_Prefix__c(name='TRPO', ASI_MFM_Module__c='PO',ASI_MFM_Region__c=true );
            insert px;
            pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='ASI_TR_Purchasing');
            insert pr;
            
            ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
            insert rts;
            
            ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
            insert rtms;
            
            // ASI MFM  PO Route Rule Details Set Approver 
            List<ASI_MFM_Route_Rule_Detail__c> RRDList= new List<ASI_MFM_Route_Rule_Detail__c> ();
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
            RRDList.add(rrd);
            ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrd2);
            ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
            RRDList.add(rrd3);
            ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
            RRDList.add(rrd4);
            ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
            RRDList.add(rrd5);
            ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
            RRDList.add(rrd6); 
            ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
            RRDList.add(rrd7);
            ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
            RRDList.add(rrd8);
            ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
            RRDList.add(rrd9);
            ASI_MFM_Route_Rule_Detail__c rrd10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=100, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=10);
            RRDList.add(rrd10);
            ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1);
            RRDList.add(rrds);
            ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds2);
            ASI_MFM_Route_Rule_Detail__c rrds3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds3);
            ASI_MFM_Route_Rule_Detail__c rrds4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds4);
            ASI_MFM_Route_Rule_Detail__c rrds5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds5);
            ASI_MFM_Route_Rule_Detail__c rrds6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds6);
            ASI_MFM_Route_Rule_Detail__c rrds7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds7);
            ASI_MFM_Route_Rule_Detail__c rrds8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds8);
            ASI_MFM_Route_Rule_Detail__c rrds9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds9);
            ASI_MFM_Route_Rule_Detail__c rrds10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds10);
            insert RRDList;
            
            
          
            // Create PO
            map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');  
            List<Account> AccList = new List<Account>();
            Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Customer'),Name='Name3');        
            AccList.add(acc2);
            
            Account acc1 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Supplier'),Name='Name2'); 
            AccList.add(acc1);
            insert AccList;
            
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Responsible_By__c=u.Id,
                                                 recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO'),
                                                 ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id,
                                                 ASI_MFM_Status__c ='Final',
                                                 ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_Currency__c='HKD',
                                                 ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),
                                                 ASI_MFM_Supplier_Name__c = acc1.id);
            insert po;
            
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
            insert ac;
            
            Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_TR_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);
            insert sub;
            test.startTest(); //introv 20180212
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'),
                                                                      ASI_MFM_PO__c=po.id,
                                                                      ASI_MFM_A_C_Code__c=ac.id, 
                                                                      ASI_MFM_Customer_Name__c=acc2.id, 
                                                                      ASI_MFM_List_Item_Description__c='testDescription',
                                                                      ASI_MFM_Sub_brand_Code__c=sub.id, 
                                                                      ASI_MFM_G_L_Date__c = Date.today(),
                                                                      ASI_MFM_Complete__c = true,ASI_MFM_Amount__c=123);  
            insert poi;
            
            ASI_MFM_PO_Receipt__c POR =new ASI_MFM_PO_Receipt__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),
                                                                 ASI_MFM_PO__c=po.id,ASI_MFM_Status__c='Draft');
            insert POR;
            
            //test.startTest();  //introv 20180212
            System.debug(Limits.getDMLRows());
            
            List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c PORI = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),
                                                                             ASI_MFM_Amount__c=10,
                                                                             ASI_MFM_PO_Receipt__c=POR.id,
                                                                             ASI_MFM_PO_Line_Item__c=poi.id,
                                                                             ASI_MFM_ACC_Verify__c =false,ASI_MFM_Receipt_Date__c=date.today());
            PORIList.add(PORI);
            ASI_MFM_PO_Receipt_Item__c PORI2 = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),
                                                                              ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,
                                                                              ASI_MFM_PO_Line_Item__c=poi.id,
                                                                              ASI_MFM_ACC_Verify__c =true,
                                                                              ASI_MFM_Receipt_Date__c=date.today());
            PORIList.add(PORI2);
            insert PORIList;
            
            // Test Start
            
            PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('status', 'Voided');  
            ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
            ext2.setStatus();
            
            test.stopTest();
            
        }
    }
    
    
    static testMethod void ASI_MFM_GF_PDFTestSetPOSatus2() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Complete');  //
        ApexPages.currentPage().getParameters().put('createdLine', 'No');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
    }
    
    
    static testMethod void ASI_MFM_GF_PDFTestSetPOSatus3() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Complete');  //
        ApexPages.currentPage().getParameters().put('createdLine', 'Yes');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
    }
    
    
    static testMethod void ASI_MFM_GF_SetPOStatus() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        
        List<ASI_MFM_Prefix__c> PreList= new List<ASI_MFM_Prefix__c> ();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
        PreList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
        PreList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
        PreList.add(pxa); 
        
        
        insert PreList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pr);
            
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pra);  
        
        insert PrList;
        
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
      
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        List<ASI_MFM_Payment__c> Paymentlist = new List<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), 
                                                       ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Pre_payment__c=true,
                                                       ASI_MFM_Supplier_Name__c = acc1.id);
        Paymentlist.add(py);
        
        ASI_MFM_Payment__c py2 = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), 
                                                        ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Pre_payment__c=true,
                                                        ASI_MFM_Status__c='Final',
                                                        ASI_MFM_Supplier_Name__c = acc1.id);
        Paymentlist.add(py2);
        insert Paymentlist;
        
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       
        
        pyi_list.add(pyi);
        insert pyi_list;
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Complete');  //
        ApexPages.currentPage().getParameters().put('createdLine', 'No');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
    }
    
    static testMethod void ASI_MFM_GF_PDFTestSetPOSatus4() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c =ASI_MFM_KR_CSVTestClass.getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Draft');  
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
    }

    */
    /*
    //Test For ASI_MFM_SetPOStatusController
    static testMethod void ASI_MFM_SetPOStatustestMethod1() { 
        
        String fiscalYear = ASI_MFM_KR_CSVTestClass.getFiscalYear();
        
        userrole Role_Test= new userrole(Name='ASI_KR_Purchasing Trade Marketing ',developerName='ASI_KR_Purchasingtest');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.BypassTriggers__c='ASI_MFM_KR_SetPOToDraft';
        update u;
        
        System.runAs(u){ 
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PO',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPO);
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPayment);
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPayment.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Payment);
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPO.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PO); 
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Plan); 
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;   
          
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Actual_Spending_Amount__c=0,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
                        
            
            //-------------------------------------------------- Customer----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            insert AccountList;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test Name',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
        
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            
            
            //-------------------------------------------------- PO ----------------------------------------------------------//
            //Test.startTest(); //introv 20180112
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 ASI_MFM_Warehouse__c = acc1.id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Base_Currency_Amount__c=100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;
            Test.startTest(); //introv 20180112
              PageReference pageRef2 = new Pagereference('/apex/ASI_MFM_PODetailPage');
            Test.setCurrentPage(pageRef2);
            ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
            ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
            ext2.setStatus();
            
            
            
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Submitted',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc2.id,
                                                                       ASI_MFM_PO__c = po.id,
                                                                       ASI_MFM_Company_Code__c = '222',
                                                                       ASI_MFM_Send_Approval_Email__c=true,
                                                                       ASI_MFM_Is_Direct_Payment__c = true,
                                                                       ASI_MFM_Invoice_Number__c = 'OLD INVOICE NUMBER');  
            
            insert PaymentHeader;
            
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                         ASI_MFM_Beneficiary_Customer__c = customer1.id);
            //ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
            
            PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('status', 'Closed');   // change status as draft
            ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
            ext1.setStatus();
            
            delete PaymentHeader;
           //ext1.setStatus();
            
            test.stopTest();       
        }
        
    }
    
    static testMethod void ASI_MFM_PaymentLineItem_TestClass() { // from ASI_MFM_JP_Payment_TestClass
        //Test : ASI_MFM_JP_PaymentLineItem_TriggerClass : ASI_MFM_SelectPaymentPrefixController
        
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
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_VAT_Adjustment__c=1,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=82, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id); 
        payLineList.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_VAT_Adjustment__c=1,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=pol.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id); 
        payLineList.add(pyi2);
        insert payLineList;
        
        //Test : ASI_MFM_JP_PaymentLineItem_TriggerClass : Update ETL 
        pyi2.ASI_MFM_ETL__c=true;
        update pyi2;
        
        pyi2.ASI_MFM_ETL__c=false;
        update pyi2;
        //Test: ASI_MFM_JP_PaymentLineItem_TriggerClass  End
        
        
                  
        // Test ASI_MFM_SetPOStatusController
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'Complete'); 
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();
        
        
        Test.stopTest();
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
    
    
    static testMethod void ASI_MFM_Payment_TermClass() { // from ASI_MFM_JP_Payment_TestClass
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
    
    
    
    
    static testMethod void ASI_MFM_PDFTestPayment() {   //From ASI_MFM_TH_PlanTest_Class // for Test class: ASI_MFM_TH_Payment_PDF_PageController  and ASI_MFM_SetPOStatusController
        Test.setCurrentPage(Page.ASI_MFM_TH_Payment_PDF_Page);
          
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
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
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_POSM_Balance__c=true,ASI_MFM_Invoice_Due_Date__c=date.today(),
            ASI_MFM_Currency__c='THB', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id);   //   acc2.id
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
    
    
    static testMethod void THSetPOStatus() {   
        Test.setCurrentPage(Page.ASI_MFM_TH_Payment_PDF_Page);
          
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
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
            ASI_MFM_Currency__c='THB',ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Complete',ASI_MFM_Is_FOC_PO__c=true);
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
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_POSM_Balance__c=true,ASI_MFM_Invoice_Due_Date__c=date.today(),
            ASI_MFM_Currency__c='THB', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id);   //   acc2.id
        insert py;
        
     	//Paymet line item
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id);  // it must include ASI_MFM_Payee__c 
        insert pyi;
        
        
        // Test ASI_MFM_SetPOStatusController
     	PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();
        test.stopTest(); 
    }
    
    
    
       static testMethod void testPOStatusController () { // from ASI_MFM_TestClass_DL 

        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');  
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
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

    static testMethod void ASI_MFM_SetPOStatusControllerTestMY() {   // For Test class:  ASI_MFM_SetPOStatusController
        
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();  
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
        preList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        preList.add(pxa); 
        insert preList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> preRList = new List<ASI_MFM_Role_Prefix_Relationship__c>(); 
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        preRList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        preRList.add(pro);  
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        preRList.add(pra); 
        insert preRList; 
        
        // Create Plan 
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        // Suplier
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name2');  
        accList.add(acc1);
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_MY_Customer'),Name='Name3');          
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name3');      
        accList.add(acc3);
        
        insert accList;
        
        // Create PO
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        // Create PO line Items
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        // prepare Payment
        
        
        
        Test.startTest(); // start the test
        // Create Payment 
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_MY_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='MYR',ASI_MFM_Status__c='Draft', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id);   //   acc2.id
        insert py;
        
        //Paymet line item
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id);  // it must include ASI_MFM_Payee__c 
        insert pyi;
        
        // Test ASI_MFM_SetPOStatusController
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'Complete');   // change PO status as Complete
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();//System.debug('new_statusTEST:'+ext.new_status);
        test.stopTest(); 
    }
	//////////////////////Test Class for ASI_MFM_SetPOStatusController----------------End
*/
    static testMethod void ASI_MFM_SetPOStatusControllerTestHK() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
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
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c='Draft');
        insert po;
        System.debug('PO Balance := ' + po.ASI_MFM_PO_Balance__c);
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1000, ASI_MFM_Base_Currency_Amount__c=1000
            );
        insert pol;
        
        
        Test.startTest();
        ASI_MFM_PO__c p1 = [Select id, ASI_MFM_Status__c, ASI_MFM_PO_Balance__c, ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO__c where id = :pol.ASI_MFM_PO__c];
        System.debug('PO Balance := ' + p1.ASI_MFM_PO_Balance__c + 'Base Cur Amt: ' + p1.ASI_MFM_Base_Currency_Amount__c);
        p1.ASI_MFM_Status__c = 'Final';
		update p1;        
        system.debug('test po status: ' + p1.ASI_MFM_Status__c);
        
        ApexPages.currentPage().getParameters().put('status', 'Voided');   // change PO status as Voided
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(p1));
        ext1.setStatus();//System.debug('new_statusTEST:'+ext.new_status);
        
        po.ASI_MFM_Status__c = 'Final';
        update p;
        
        ApexPages.currentPage().getParameters().put('status', 'Complete');   // change PO status as Complete
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(p1));
        ext2.setStatus();
        
        test.stopTest(); 
    }
      /*      
    static testMethod void ApprovalList_Test1() {
       
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        list<User> users = [SELECT Id, Name, Managerid, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE and ID != : userInfo.getUserId() LIMIT 1];      
        User u2=users[0];
        u2.UserRoleid =Role_Test.id;
        u2.ASI_MFM_Country__c='KR';
        u2.ASI_MFM_Team__c='Brand Marketing';
        u2.CompanyName = 'Pernod Ricard Korea';
        u2.ASI_KOR_User_Region_Name__c='505';
        u2.ASI_KOR_User_Branch_Name__c='Metro WS-Seoul S';
        update u2;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.ASI_MFM_Country__c='KR';
        u.ASI_MFM_Team__c='Brand Marketing';
        u.CompanyName = 'Pernod Ricard Korea';
         u.ASI_KOR_User_Region_Name__c='505';
        u.ASI_KOR_User_Branch_Name__c='Metro WS-Seoul S';
        u.ManagerID=u2.Id;
        update u;
        
        string fiscalYear = ASI_MFM_KR_CSVTestClass.getFiscalYear();
        System.runAs(u){ 
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Purchase_Request__c'); 
            rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            
            List<Account> AccountList = new List<Account>();
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            
            insert AccountList;
            
            
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c = '222',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Plan); 
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;   
            
            List<ASI_KR_Setting__c> SettingList = new List<ASI_KR_Setting__c>();
            ASI_KR_Setting__c KRData= new ASI_KR_Setting__c(name='Test',ASI_MFM_Object__c='Plan',ASI_MFM_API_Name__c='ASI_MFM_Plan__c',ASI_CRM_Type__c='ASI_MFM_KR_ApprovalListPage');
            SettingList.add(KRData);
             ASI_KR_Setting__c KRData2= new ASI_KR_Setting__c(name='Test2',ASI_MFM_Object__c='Purchase Request',ASI_MFM_API_Name__c='ASI_MFM_Purchase_Request__c',ASI_CRM_Type__c='ASI_MFM_KR_ApprovalListPage');
           SettingList.add(KRData2);
            insert SettingList;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',ASI_MFM_Submit_for_Approval__c=true,ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),ASI_MFM_Start_Date__c = date.today(),ASI_MFM_End_Date__c = date.today(),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Draft',   ASI_MFM_Budget_Type__c = 'NORM',   OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', Name = 'AP Code Test',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand.id,ASI_MFM_AP_Code__c = AP_Code.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand.id, ASI_MFM_AP_Code__c = AP_Code.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine2;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_Approval_List_No_Of_Row__c = 5);
            insert setting;
            
            Test.startTest();
            if([select count() from ProcessInstance where targetobjectid=:plan1.id] < 1){       
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                
                req.setComments('Submitting request for approval..');
                req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                req.setObjectId(plan1.Id);
                req.setSubmitterID(UserInfo.getUserId());
                //req.setSkipEntryCriteria(true);
                //req.setProcessDefinitionNameOrId('ASI_MFM_KR_PR_Approval_Process');
                //Submit the approval request
                Approval.ProcessResult result = Approval.process(req);
                
                ASI_MFM_KR_ApprovalListController con = new ASI_MFM_KR_ApprovalListController();
                 
                List<SelectOption> testList= con.getApprovalStatusOptions();
                testList= con.getRegionNameOptions();
                testList= con.getBranchNameOptions();
                testList= con.getSearchObjectOptions();
                
                con.Status='Approved';
                con.init();
                con.runSearch();
                con.RegionName='505';
                con.BranchName='Metro WS-Seoul S';
                con.Beginning();
               
               // List<ProcessInstance> Listl= [ SELECT Id,CompletedDate,CreatedBy.Name,targetobject.Name,status,TargetObject.Type,CreatedDate,createdBy.CompanyName   FROM ProcessInstance ];
                
               //system.assertEquals(Listl[0].TargetObject.Type,Listl[0].createdBy.CompanyName );
            }
            
            test.stopTest();
            
        }
        
    }
    
    
    // Test : ASI_MFM_KR_ApprovalListController
    static testMethod void ApprovalList_Test2() {
        
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        list<User> users = [SELECT Id, Name, Managerid, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User 
                            WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE and ID != : userInfo.getUserId() LIMIT 1];      
        User u2=users[0];
        u2.UserRoleid =Role_Test.id;
        u2.ASI_MFM_Country__c='KR';
        u2.ASI_MFM_Team__c='Brand Marketing';
        u2.CompanyName = 'Pernod Ricard Korea';
        update u2;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.ASI_MFM_Country__c='KR';
        u.ASI_MFM_Team__c='Brand Marketing';
        u.CompanyName = 'Pernod Ricard Korea';
         u.ASI_KOR_User_Region_Name__c='505';
        u.ASI_KOR_User_Branch_Name__c='Metro WS-Seoul S';
        u.ManagerID=u2.Id;
        update u;
        
        
        
        string fiscalYear = ASI_MFM_KR_CSVTestClass.getFiscalYear();
        System.runAs(u){ 
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Purchase_Request__c'); 
            rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            
            List<Account> AccountList = new List<Account>();
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            
            insert AccountList;
            
            
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c = '222',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Plan); 
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;   
            
            
            ASI_KR_Setting__c KRData= new ASI_KR_Setting__c(name='Test',ASI_MFM_Object__c='Purchase Request',ASI_MFM_API_Name__c='ASI_MFM_Purchase_Request__c',ASI_CRM_Type__c='ASI_MFM_KR_ApprovalListPage');
            insert KRData;
            
            
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',ASI_MFM_Submit_for_Approval__c=true,ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),ASI_MFM_Start_Date__c = date.today(),ASI_MFM_End_Date__c = date.today(),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved',   ASI_MFM_Budget_Type__c = 'NORM',   OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', Name = 'AP Code Test',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand.id,ASI_MFM_AP_Code__c = AP_Code.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand.id, ASI_MFM_AP_Code__c = AP_Code.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine2;
            
            
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test Name',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),ASI_MFM_Comment__c = 'comment',ASI_MFM_PR_Name__c='PR Name',ASI_MFM_Company_Code__c = 'PRK',ASI_MFM_PR_Date__c = date.today(),ASI_MFM_Plan__c = plan1.id,ASI_MFM_Service_Item_POSM__c = 'POSM',ASI_MFM_Ship_To__c = acc1.ID,ASI_MFM_Submit_for_Approval__c=true,ASI_MFM_Status__c = 'Draft',ASI_MFM_Prefix__c = prefixPR.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_Approval_List_No_Of_Row__c = 5);
            insert setting;
            
            Test.startTest();
            if([select count() from ProcessInstance where targetobjectid=:plan1.id] < 1){       
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                
                req.setComments('Submitting request for approval..');
                req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                req.setObjectId(PR_Header.Id);
                req.setSubmitterID(UserInfo.getUserId());
                req.setSkipEntryCriteria(true);
                req.setProcessDefinitionNameOrId('ASI_MFM_KR_PR_Approval_Process_V2');
                
                
                //Submit the approval request
                Approval.ProcessResult result = Approval.process(req);
                
                ASI_MFM_KR_ApprovalListController con = new ASI_MFM_KR_ApprovalListController();
                con.RegionName='505';
                con.BranchName='Metro WS-Seoul S';
                con.runSearch();
                con.Beginning();
               
                con.Next();
                 con.Previous();
                con.End();
                con.getDisablePrevious();
                con.toggleSort();
                List<SelectOption> testList= con.getApprovalStatusOptions();
                testList= con.getRegionNameOptions();
                testList= con.getBranchNameOptions();
                testList= con.getSearchObjectOptions();
                
                 Set<String> UserList= new Set<String>();
                UserList.add('T21');
                String tempstr=con.ConstructSQLPO(UserList);
                
                List<ASI_MFM_AP_Code__c> remo1= ASI_MFM_KR_ApprovalListController.findList('ASI_MFM_AP_Code__c','ID','WHERE RecordType.DeveloperName != null');
                //List<ProcessInstanceWorkitem> Listl= [ SELECT id,processinstance.createdBy.CompanyName,processinstance.status,processinstance.CreatedDate,processinstance.targetobjectid,processinstance.createdBy.id FROM ProcessInstanceWorkitem ];
                //system.assertEquals(Null,Listl[0].processinstance.CreatedDate);
               
            }
            
            test.stopTest();
            
        }		
    }

*/
}