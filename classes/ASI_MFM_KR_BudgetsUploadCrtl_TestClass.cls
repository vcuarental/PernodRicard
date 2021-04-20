/*
Test Class:
- ASI_MFM_KR_BudgetsUploadController
- ASI_MFM_KR_PlanBudgetCheckingCtrl
- ASI_MFM_SetPlanStatusCOntroller
- ASI_MFM_KR_PR_ExpirationDateEmailRemind
*/

@istest
public class ASI_MFM_KR_BudgetsUploadCrtl_TestClass {
    
    /*---------------------------------------------Fiscal Year Method -----------------------------------------------------------*/
    public static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1  ;
        Integer yearA2 = Integer.valueOf(yearA1) +1  ;
        String Current_Fiscal_year;
        
        Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        
        return Current_Fiscal_year;
    }
    
    //*******************Test ASI_MFM_SetPlanStatusController ************************************************************************
    static testMethod void SGSetPlanStatustest1() {
        //Test.setCurrentPage(Page.ASI_MFM_PlanDetailPage);
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');  
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1920');
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
        ApexPages.currentPage().getParameters().put('status', 'Draft');
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p1));
        ext.setStatus();
        ext.setStatus();
        
        test.stopTest(); 
    }
    
    static testMethod void SGSetPlanStatustest2() {
        //Test.setCurrentPage(Page.ASI_MFM_PlanDetailPage);
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');  
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1920');
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
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name2');   //  ASI_MFM_HK_Supplier       
        insert acc1;
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'),name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_PO_End_Date__c=date.today().addDays(1),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Draft');
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p1));
        ext.setStatus();
        ext.setStatus();
        
        test.stopTest(); 
    }
    
    
    
    static testMethod void TWSetPlanStatusTest1() {
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
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Draft');
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p1));
        ext.setStatus();
        
        
        ASI_MFM_SetPlanStatusController ext2 = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p));
        ext2.setStatus();
        
        test.stopTest(); 
    }
    
    static testMethod void TWSetPlanStatusTest2() {
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
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Complete');
        insert p;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TW_Plan'), name='test2',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id);
        insert p1;
        
        Test.startTest();   
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Draft');
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p1));
        ext.setStatus();
        
        
        ASI_MFM_SetPlanStatusController ext2 = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p));
        ext2.setStatus();
        
        test.stopTest(); 
    }
     //*******************Test ASI_MFM_SetPlanStatusController ************************************************************************
    //***********************************************************************************************************************************************************
    
    static testMethod void KRSetPlanStatusTest_Draft() {
        Test.setCurrentPage(Page.ASI_MFM_PlanDetailPage);
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()]; 
        u.ASI_MFM_Team__c = 'Brand Marketing';
        u.CompanyName = 'Pernod Ricard Korea';
        update u; 
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_KR_Plan_Read_Only'), name='test',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Approved');
        insert p;
                
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_KR_Plan_Read_Only'), name='test2',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Approved');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert px;
            
            // Suplier

            List<Account> accList = new List<Account>();
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');  
            accList.add(acc1);
            

            
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name3');          
            accList.add(acc2);
            
            Account acc3 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name3', ASI_KOR_Customer_Code__c = 'THS2');      
            accList.add(acc3);
            
            insert accList;
            Test.startTest(); 
            // Create PO
            rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pro;     
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_KR_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                                 ASI_MFM_Currency__c='KRW', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Submitted',ASI_MFM_Is_FOC_PO__c=true);
            insert po;
            ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_KR_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                                 ASI_MFM_Currency__c='KRW', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Draft',ASI_MFM_Is_FOC_PO__c=true);
            insert po1;
            
            
            // Create PO line Items
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
            insert ac;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
            insert sub;
            rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_KR_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000, //ASI_MFM_Quantity__c=100, ASI_MFM_Unit_Price__c=10,
                                                                      ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
            insert poi;
            
           
        ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert prefixPR;
            
        ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = p.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc2.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
        insert PR_Header;    
        
        ASI_MFM_Purchase_Request__c PR_Header1 = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = p.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc2.ID,
                                                                                     ASI_MFM_Status__c = 'Submitted',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
        insert PR_Header1;
        
        
        
           
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Draft');
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p));
        ext.setStatus();               
        
        delete poi;
        test.stopTest(); 
    }
    
    static testMethod void KRSetPlanStatusTest_Closed() {
        Test.setCurrentPage(Page.ASI_MFM_PlanDetailPage);
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()]; 
        u.ASI_MFM_Team__c = 'Brand Marketing';
        u.CompanyName = 'Pernod Ricard Korea';
        update u; 
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert subBrand1;                
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_KR_Plan_Read_Only'), name='test2',
        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'veryLongDescription', 
        ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
        ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Approved');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert px;
            
            // Suplier

            List<Account> accList = new List<Account>();                        
            
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name3');          
            accList.add(acc2);
            
            Account acc3 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name3', ASI_KOR_Customer_Code__c = 'THS2');      
            accList.add(acc3);
            
            insert accList;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test Name',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            
            // Create PO
            rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pro; 
            List<ASI_MFM_PO__c> polist = new List<ASI_MFM_PO__c>();    
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_KR_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                                 ASI_MFM_Currency__c='KRW', ASI_MFM_Supplier_Name__c = acc3.id, ASI_MFM_Status__c = 'Submitted',ASI_MFM_Is_FOC_PO__c=true);
            polist.add(po);
            ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_KR_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                                 ASI_MFM_Currency__c='KRW', ASI_MFM_Supplier_Name__c = acc3.id, ASI_MFM_Status__c = 'Draft',ASI_MFM_Is_FOC_PO__c=true);
            polist.add(po1);
            insert polist;
            
            Test.startTest(); 
            // Create PO line Items
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
            insert ac;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
            insert sub;
            rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_KR_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000, //ASI_MFM_Quantity__c=100, ASI_MFM_Unit_Price__c=10,
                                                                      ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
            insert poi;
            
           
        ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert prefixPR;
        
        List<ASI_MFM_Purchase_Request__c> prlist = new List<ASI_MFM_Purchase_Request__c>();    
        ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = p1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc2.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
        prlist.add(PR_Header);    
        
        ASI_MFM_Purchase_Request__c PR_Header1 = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = p1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc2.ID,
                                                                                     ASI_MFM_Status__c = 'Submitted',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
        prlist.add(PR_Header1);
        insert prlist;
        ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Submitted',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc3.id,
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
                                                                                         ASI_MFM_PO_Line_Item__c = poi.id,
                                                                                         ASI_MFM_Beneficiary_Customer__c = customer1.id);
            //ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
                                   
        
        PageReference pageRef1 = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('status', 'Closed');
        ASI_MFM_SetPlanStatusController ext1 = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p1));
        ext1.setStatus();
        
        test.stopTest(); 
    }
    
    static testMethod void THSetPlanStatusTest1() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        System.runAs(u){ 
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
            insert px;
            
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
                                                 ASI_MFM_Currency__c='THB', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Complete',ASI_MFM_Is_FOC_PO__c=true);
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
        
            Test.startTest();
            
            PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('status', 'Complete');
            ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p1));
            ext.setStatus();
            
            
            test.stopTest();
        }
    }
    
    static testMethod void THSetPlanStatusTest2() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        System.runAs(u){ 
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
            insert px;
            
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pr;
            
            // Create Plan 
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
            ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                     ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Draft');
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
                                                 ASI_MFM_Currency__c='THB', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Complete',ASI_MFM_Is_FOC_PO__c=true);
            //insert po;
            
            // Create PO line Items
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
            insert ac;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
            insert sub;
            rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000, //ASI_MFM_Quantity__c=100, ASI_MFM_Unit_Price__c=10,
                                                                      ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
            //insert poi;
        
            Test.startTest();
            
            PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('status', 'Submitted');
            ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p1));
            ext.setStatus();
            
            
            test.stopTest();
        }
    }
    
    static testMethod void GFSetPlanStatusTest() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = 'FY1920');
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
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert sub;
        
        test.startTest();
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='5651 Consumer Event', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_GF_A_C_Code'));
        insert ac;
                
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        insert acctList;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = sub.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription',
                                                                     ASI_MFM_Month_1_Cost__c = 10, ASI_MFM_Month_2_Cost__c = 10, ASI_MFM_Month_3_Cost__c = 10, ASI_MFM_Month_4_Cost__c = 10, ASI_MFM_Month_5_Cost__c = 10, ASI_MFM_Month_6_Cost__c = 10, 
                                                                     ASI_MFM_Month_7_Cost__c = 10, ASI_MFM_Month_8_Cost__c = 10, ASI_MFM_Month_9_Cost__c = 10, ASI_MFM_Month_10_Cost__c = 10, ASI_MFM_Month_11_Cost__c = 10, ASI_MFM_Month_12_Cost__c = 10);   
        insert pi;  
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c = 'Draft', ASI_MFM_PO_Type__c = 'Event FOC', ASI_MFM_PO_Start_Date__c=Date.today(), ASI_MFM_PO_End_Date__c=Date.today().addDays(1)); 
        insert po;
        
       
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='Sponsorship [Media]', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_GF_AP_Code'), ASI_MFM_A_C_Code__c=ac.Id);
        insert ap;
      
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Draft');
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p));
        ext.setStatus();
        
        
        test.stopTest();
    }
    
    public static string getFiscalYear_Correct(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1  ;
        Integer yearA2 = Integer.valueOf(yearA1) +1  ;
        String Current_Fiscal_year;
        
        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
    
    
    
    
    
    //Test ASI_MFM_KR_PlanBudgetCheckingCtrl 
    
    
    static testMethod void PlanBudgetCheckingTest() {
         String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c ='Brand Marketing';
        update u;
        System.runAs(u){ 
            //-------------------------------------------------- Prefix  ----------------------------------------------------------//
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPayment);
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PO',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPO);
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPayment.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Payment);
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPO.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PO); 
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Plan); 
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id, ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PR);
            insert PrefixRole_List;
            
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //-------------------------------------------------- BrandGroup, Brand, SubBrand----------------------------------------------------------//
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            
            
          
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,ASI_MFM_Company_Code__c='222', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 ,  ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1, ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
            insert setting;
             //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code',name = 'AP Code Test',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
    
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',ASI_MFM_Fiscal_year__c=fiscalYear,ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved', ASI_MFM_Budget_Type__c = 'NORM',OwnerId =u.id);
            insert plan1;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,   ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR', ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100, ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id, ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,    ASI_MFM_Month_4_Cost__c = 100, ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100, ASI_MFM_Month_7_Cost__c = 100, ASI_MFM_Month_8_Cost__c = 100, ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine3);
            insert PlanList;
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            //------------------------------------------------------- Customer ----------------------------------------------------------// 
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
           
            //-------------------------------------------------- PR ----------------------------------------------------------//
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),ASI_MFM_Comment__c = 'comment',ASI_MFM_PR_Name__c='PR Name',ASI_MFM_Company_Code__c = 'PRK',ASI_MFM_PR_Date__c = date.today(),ASI_MFM_Plan__c = plan1.id,ASI_MFM_Service_Item_POSM__c = 'POSM',ASI_MFM_Ship_To__c = acc1.ID,ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPR.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),ASI_MFM_Plan_Line_Item__c = planLine1.id,ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_AP_Code__c = AP_Code.ID,ASI_MFM_Quantity__c = 10,ASI_MFM_UOM__c = 'EA',ASI_MFM_Tax_Code__c = TaxCode.id,ASI_MFM_Estimated_PR_budget__c = 100,ASI_MFM_Delivery_Date__c= date.today(),ASI_MFM_Description__c = 'Description',ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            //-------------------------------------------------- PO ----------------------------------------------------------//
            List<ASI_MFM_PO__c> POList= new List<ASI_MFM_PO__c>();
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            POList.add(po);  
            ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Draft',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            POList.add(po2); 
            ASI_MFM_PO__c po3 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Is_Direct_Payment__c=true,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Draft',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            POList.add(po3);
            
            insert POList;
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),ASI_MFM_PO__c = po.id,ASI_MFM_Plan_Line_Item__c = planLine1.id,ASI_MFM_Unit_Price__c = 1000,ASI_MFM_KR_Quantity__c = 100,  ASI_MFM_Amount__c = 100000,ASI_MFM_Delivery_Date__c =  date.today(),ASI_MFM_G_L_Date__c = date.today(),ASI_MFM_Purchase_Request_Line__c = PR_Line.id);
            
            insert po_line;
            Test.startTest();
              List<ASI_MFM_Budget_Setup__c> NewRecord = new List<ASI_MFM_Budget_Setup__c>();
            
            ASI_MFM_Budget_Setup__c Budget_Budget = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-50),ASI_MFM_Type__c = 'Budget',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE1 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-40),ASI_MFM_Type__c = 'LE1',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE2 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-30), ASI_MFM_Type__c = 'LE2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE3 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-20),ASI_MFM_Type__c = 'LE3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE4 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-10),ASI_MFM_Type__c = 'LE4',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            NewRecord.add(Budget_Budget);
            NewRecord.add(Budget_LE1);
            NewRecord.add(Budget_LE2);
            NewRecord.add(Budget_LE3);
            NewRecord.add(Budget_LE4);
            insert NewRecord;
            
              ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan1);
            ASI_MFM_KR_PlanBudgetCheckingCtrl con  = new ASI_MFM_KR_PlanBudgetCheckingCtrl(stdController);
            ASI_MFM_KR_PlanBudgetCheckingCtrl.wrapperClass temp= ASI_MFM_KR_PlanBudgetCheckingCtrl.getresultSetByPlanId(plan1.Id);
            test.stopTest();       
        }
        
    }
    
    // Test ASI_MFM_SetPaymentStatusController
    static testMethod void  ASI_MFM_SetPaymentStatusTest(){  
          
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c ='Brand Marketing';
        update u;
        
        System.runAs(u){ 
            //-------------------------------------------------- Prefix  ----------------------------------------------------------//
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPR);
            
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPayment);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            //insert prefixPO;
            Prefix_List.add(prefixPO);
            
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PO); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Plan); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            
            //-------------------------------------------------- Approval Process ----------------------------------------------------------//
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //-------------------------------------------------- BrandGroup, Brand, SubBrand----------------------------------------------------------//
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
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
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',
                                       ASI_MFM_Address_Line_1__c = '1',
                                       ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            //------------------------------------------------------- Customer ----------------------------------------------------------// 
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c=true,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            //-------------------------------------------------- PR ----------------------------------------------------------//
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
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            
            
            
            //-------------------------------------------------- PO ----------------------------------------------------------//
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Draft',
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
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;
            
            
            
            //------------------------------------------------------- Payment ----------------------------------------------------------//
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Approved',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc2.id,
                                                                       ASI_MFM_PO__c = po.id,
                                                                       ASI_MFM_Company_Code__c = '222',
                                                                       ASI_MFM_Send_Approval_Email__c=true,
                                                                       ASI_MFM_Is_Direct_Payment__c = true,
                                                                       ASI_MFM_Invoice_Number__c = 'OLD INVOICE NUMBER');  
            //Test.startTest(); //20180209 introv 
            insert PaymentHeader;
            
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                         ASI_MFM_Beneficiary_Customer__c = customer1.id);
            //ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            Test.startTest();  //20180209 introv
            insert PaymentLine;
            
            
            
            
            
            
            
            System.debug(Limits.getDMLRows());
            //-------------------------------------------------- PO Receipt ----------------------------------------------------------//
          
            PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
            Test.setCurrentPage(pageRef5);
            
            ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
            ASI_MFM_SetPaymentStatusController ext5 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(PaymentHeader));
            ext5.setStatus();

            PaymentHeader.ASI_MFM_Status__c='Rejected';
            UPDATE PaymentHeader;
            PageReference pageRef6 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
            Test.setCurrentPage(pageRef6);
            ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
            ASI_MFM_SetPaymentStatusController ext6 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(PaymentHeader));
            ext6.setStatus();
            
            /*    
            PaymentHeader.ASI_MFM_Status__c='Draft';
            UPDATE PaymentHeader;
            PageReference pageRef7 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
            Test.setCurrentPage(pageRef7);
            ApexPages.currentPage().getParameters().put('status', 'Approved');   // change status as draft
            ASI_MFM_SetPaymentStatusController ext7 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(PaymentHeader));
            ext7.setStatus(); 
            */
            
            test.stopTest();
        }
    }
    
    static testMethod void  ASI_MFM_SetPaymentStatusTest1(){  
          
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c ='Brand Marketing';
        update u;
        
        System.runAs(u){ 
            //-------------------------------------------------- Prefix  ----------------------------------------------------------//
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPR);
            
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPayment);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            //insert prefixPO;
            Prefix_List.add(prefixPO);
            
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PO); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Plan); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            
            //-------------------------------------------------- Approval Process ----------------------------------------------------------//
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //-------------------------------------------------- BrandGroup, Brand, SubBrand----------------------------------------------------------//
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
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
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',
                                       ASI_MFM_Address_Line_1__c = '1',
                                       ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            //------------------------------------------------------- Customer ----------------------------------------------------------// 
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c=true,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            //-------------------------------------------------- PR ----------------------------------------------------------//
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
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            
            
            
            //-------------------------------------------------- PO ----------------------------------------------------------//
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Draft',
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
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;
            
            
            
            //------------------------------------------------------- Payment ----------------------------------------------------------//
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Approved',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc2.id,
                                                                       ASI_MFM_PO__c = po.id,
                                                                       ASI_MFM_Company_Code__c = '222',
                                                                       ASI_MFM_Send_Approval_Email__c=true,
                                                                       ASI_MFM_Is_Direct_Payment__c = true,
                                                                       ASI_MFM_Invoice_Number__c = 'OLD INVOICE NUMBER');  
            //Test.startTest(); //20180209 introv 
            insert PaymentHeader;
            
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                         ASI_MFM_Beneficiary_Customer__c = customer1.id);
            //ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            Test.startTest();  //20180209 introv
            insert PaymentLine;
            
            
            
            
            
            
            
            System.debug(Limits.getDMLRows());
            //-------------------------------------------------- PO Receipt ----------------------------------------------------------//
            /*
            PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
            Test.setCurrentPage(pageRef5);
            
            ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
            ASI_MFM_SetPaymentStatusController ext5 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(PaymentHeader));
            ext5.setStatus();
            
            PaymentHeader.ASI_MFM_Status__c='Rejected';
            UPDATE PaymentHeader;
            PageReference pageRef6 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
            Test.setCurrentPage(pageRef6);
            ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
            ASI_MFM_SetPaymentStatusController ext6 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(PaymentHeader));
            ext6.setStatus();
            */
             
            PaymentHeader.ASI_MFM_Status__c='Draft';
            UPDATE PaymentHeader;
            PageReference pageRef7 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
            Test.setCurrentPage(pageRef7);
            ApexPages.currentPage().getParameters().put('status', 'Approved');   // change status as draft
            ASI_MFM_SetPaymentStatusController ext7 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(PaymentHeader));
            ext7.setStatus(); 
            
            
            test.stopTest();
        }
    }    
    
    
    /*---------------------------------------------Test Budget: ASI_MFM_KR_BudgetsUploadController -----------------------------------------------------------*/
    static testMethod void ASI_MFM_KR_BudgetsUploadController_Test_1(){  
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            List<ASI_MFM_Budget_Setup__c> NewRecord = new List<ASI_MFM_Budget_Setup__c>();
            
            ASI_MFM_Budget_Setup__c Budget_Budget = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-50),ASI_MFM_Type__c = 'Budget',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE1 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-40),ASI_MFM_Type__c = 'LE1',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE2 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-30), ASI_MFM_Type__c = 'LE2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE3 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-20),ASI_MFM_Type__c = 'LE3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE4 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-10),ASI_MFM_Type__c = 'LE4',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            NewRecord.add(Budget_Budget);
            NewRecord.add(Budget_LE1);
            NewRecord.add(Budget_LE2);
            NewRecord.add(Budget_LE3);
            NewRecord.add(Budget_LE4);
            insert NewRecord;
            
            
            Test.startTest();
            System.debug(Limits.getDMLRows()); 
            
            PageReference SetStatusPage = Page.ASI_MFM_KR_SelectProjectCodePage;
            Test.setCurrentPage(SetStatusPage);
            ASI_MFM_KR_BudgetsUploadController ext = new ASI_MFM_KR_BudgetsUploadController();
            ext.Fiscalyear = Fiscalyear;
            ext.init();
            ext.changefy();  
            test.stopTest();  
        }   
    }
    
    static testMethod void ASI_MFM_KR_BudgetsUploadController_Test_2(){  //Without Start Date
        
        String fiscalYear = getFiscalYear_Correct();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            List<ASI_MFM_Budget_Setup__c> NewRecord = new List<ASI_MFM_Budget_Setup__c>();
            
            ASI_MFM_Budget_Setup__c Budget_Budget = new ASI_MFM_Budget_Setup__c(ASI_MFM_Type__c = 'Budget',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE1 = new ASI_MFM_Budget_Setup__c( ASI_MFM_Type__c = 'LE1',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'), ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE2 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Type__c = 'LE2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE3 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Type__c = 'LE3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE4 = new ASI_MFM_Budget_Setup__c( ASI_MFM_Type__c = 'LE4',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'), ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            
            NewRecord.add(Budget_Budget);
            NewRecord.add(Budget_LE1);
            NewRecord.add(Budget_LE2);
            NewRecord.add(Budget_LE3);
            NewRecord.add(Budget_LE4);
            insert NewRecord;
            
            
            Test.startTest();
            System.debug(Limits.getDMLRows()); 
            
            PageReference SetStatusPage = Page.ASI_MFM_KR_SelectProjectCodePage;
            Test.setCurrentPage(SetStatusPage);       
          
            ASI_MFM_KR_BudgetsUploadController ext = new ASI_MFM_KR_BudgetsUploadController();
            
            ext.init();
            ext.Fiscalyear = Fiscalyear;
            ext.changefy();  
            ext.SaveRecords();
            
            test.stopTest();  
        }   
    }
    
    // Test For ASI_MFM_KR_PR_ExpirationDateEmailRemind
    static testMethod void PR_ExpirationDateEmailRemindTest() {
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c ='Brand Marketing';
        update u;
        System.runAs(u){ 
            //-------------------------------------------------- Prefix  ----------------------------------------------------------//
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPayment);
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PO',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPO);
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPayment.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Payment);
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPO.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PO); 
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Plan); 
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id, ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PR);
            insert PrefixRole_List;
            
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c='222', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',ASI_MFM_Fiscal_year__c=fiscalYear,ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved', ASI_MFM_Budget_Type__c = 'NORM',OwnerId =u.id);
            insert plan1;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,   ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR', ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100, ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID, ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,    ASI_MFM_Month_4_Cost__c = 100, ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100, ASI_MFM_Month_7_Cost__c = 100, ASI_MFM_Month_8_Cost__c = 100, ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine3);
            insert PlanList;
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            //------------------------------------------------------- Customer ----------------------------------------------------------// 
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code',name = 'AP Code Test',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            //-------------------------------------------------- PR ----------------------------------------------------------//
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),ASI_MFM_Comment__c = 'comment',ASI_MFM_PR_Name__c='PR Name',ASI_MFM_Company_Code__c = 'PRK',ASI_MFM_PR_Date__c = date.today(),ASI_MFM_Plan__c = plan1.id,ASI_MFM_Service_Item_POSM__c = 'POSM',ASI_MFM_Ship_To__c = acc1.ID,ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPR.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),ASI_MFM_Plan_Line_Item__c = planLine1.id,ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_AP_Code__c = AP_Code.ID,ASI_MFM_Quantity__c = 10,ASI_MFM_UOM__c = 'EA',ASI_MFM_Tax_Code__c = TaxCode.id,ASI_MFM_Estimated_PR_budget__c = 100,ASI_MFM_Delivery_Date__c= date.today(),ASI_MFM_Description__c = 'Description',ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            //-------------------------------------------------- PO ----------------------------------------------------------//
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),ASI_MFM_PO__c = po.id,ASI_MFM_Plan_Line_Item__c = planLine1.id,ASI_MFM_Unit_Price__c = 1000,ASI_MFM_KR_Quantity__c = 100,  ASI_MFM_Amount__c = 100000,ASI_MFM_Delivery_Date__c =  date.today(),ASI_MFM_G_L_Date__c = date.today(),ASI_MFM_Purchase_Request_Line__c = PR_Line.id);
            
            insert po_line;
            
            Test.startTest();
            database.executebatch(new ASI_MFM_KR_PR_ExpirationDateEmailRemind(),200);    
            test.stopTest();       
        }
    }
    
    static testMethod void PlanManageAll_Test2() {
        //Test class: ASI_MFM_KR_PlanManageAllController
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_KOR_User_Branch_Code__c ='505';
        u.BypassTriggers__c = 'ASI_MFM_KR_Cross_Fiscal_Year_Checking';//20180208 introv
        update u;
        
        System.runAs(u){ 
            
            ASI_TnE_Branch_Channel__c BrandCode = new ASI_TnE_Branch_Channel__c(Name = 'Test_Branch_Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'));
            insert BrandCode;
                
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan',ASI_MFM_Fiscal_year__c = getFiscalYear());
            insert prefixKR_PLAN;
            
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = r.DeveloperName);
                
            insert rel;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code',  Name = 'AP Code Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
             Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
             Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
             Datetime GMTdate = Datetime.now();
             String yearA1 = GMTdate.format('YY');
             Date StartDate =  Date.newInstance(2000+integer.valueOf(yearA1), 7, 1);
             Date EnDDate =  Date.newInstance(2000+integer.valueOf(yearA1)+1,6,30);
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name = 'Test Plan2',ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),ASI_MFM_Start_Date__c = StartDate,ASI_MFM_End_Date__c =  EnDDate,ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Status__c='Draft',OwnerId =u.id);
               
            insert plan;
            
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),ASI_MFM_List_Item_Description__c = 'test description',ASI_MFM_Total_Cost__c = 1234,ASI_MFM_Plan__c = plan.id,ASI_MFM_KR_subLedger__c = BrandCode.id,ASI_MFM_AP_Code__c = AP_Code.id,ASI_MFM_Sub_brand_Code__c = SubBrand.id);
            insert planLine;
            
            
            List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
            planLineSet.add(planLine);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_PlanManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            Test.startTest();
            
            pageParams.put('id', plan.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            
            ASI_MFM_KR_PlanManageAllController PlanManageAllController = new ASI_MFM_KR_PlanManageAllController(stdController);
            //Test function
            PlanManageAllController.init();
           PlanManageAllController.Recalculate();
            test.stopTest(); 
        }
    }
     
    
     static testMethod void PlanManageAll_Test() {
        //Test class:  ASI_MFM_Plan_TriggerClass      ASI_MFM_PH_InputPlanItemsController
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_KOR_User_Branch_Code__c ='505';
        update u;
        
        System.runAs(u){ 
            
            ASI_TnE_Branch_Channel__c BrandCode = new ASI_TnE_Branch_Channel__c
                (
                    Name = 'Test_Branch_Code',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel')
                );
                insert BrandCode;
                
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            insert prefixKR_PLAN;
            
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c = date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Status__c='Draft',
                    OwnerId =u.id
                );
               
            insert plan;
            
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),
                    ASI_MFM_List_Item_Description__c = 'test description',
                    ASI_MFM_Total_Cost__c = 1234,
                    ASI_MFM_Plan__c = plan.id,
                    ASI_MFM_KR_subLedger__c = BrandCode.id,
                    ASI_MFM_AP_Code__c = AP_Code.id,
                    ASI_MFM_Sub_brand_Code__c = SubBrand.id
                );
            insert planLine;
            
            
            List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
            planLineSet.add(planLine);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_PlanManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            Test.startTest();
            
            pageParams.put('id', plan.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            
            ASI_MFM_KR_PlanManageAllController PlanManageAllController = new ASI_MFM_KR_PlanManageAllController(stdController);
            //Test function
            PlanManageAllController.init();
            PlanManageAllController.Recalculate();
            System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)planLine.id);
            PlanManageAllController.cloneLine();
            PlanManageAllController.SaveItems();
            PlanManageAllController.addLineItem();
            System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)planLine.id);
            PlanManageAllController.removeLine();
            
            //Test RemoteAction
            List<Account> remo= ASI_MFM_KR_PlanManageAllController.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_PH_DF_Customer');
            List<ASI_MFM_AP_Code__c> remo1= ASI_MFM_KR_PlanManageAllController.findList('ASI_MFM_AP_Code__c','ID','WHERE RecordType.DeveloperName != null');
            List<ASI_CRM_AccountsAdditionalField__c> remo2= ASI_MFM_KR_PlanManageAllController.findCustomers('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName = ASI_CRM_KR_Wholesaler');  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_PlanManageAllController.findAPACCodeMap('ASI_MFM_AP_Code__c','WHERE RecordType.DeveloperName != null');   
            
            test.stopTest(); 
        }
    }
    
    static testMethod void PlanManageAll_Test_PlanLineWithoutFields() {
        //Test class:  ASI_MFM_Plan_TriggerClass      ASI_MFM_PH_InputPlanItemsController
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_KOR_User_Branch_Code__c ='505';
        update u;
        
        System.runAs(u){ 
            
            ASI_TnE_Branch_Channel__c BrandCode = new ASI_TnE_Branch_Channel__c
                (
                    Name = 'Test_Branch_Code',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel')
                );
                insert BrandCode;
                
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            insert prefixKR_PLAN;
            
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c = date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Status__c='Draft',
                    OwnerId =u.id
                );
               
            insert plan;
            
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),
                    ASI_MFM_List_Item_Description__c = 'test description',
                    ASI_MFM_Total_Cost__c = 1234,
                    ASI_MFM_Plan__c = plan.id,
                    ASI_MFM_KR_subLedger__c = BrandCode.id
                );
            insert planLine;
            
            
            List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
            planLineSet.add(planLine);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_PlanManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            Test.startTest();
            
            pageParams.put('id', plan.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            
            ASI_MFM_KR_PlanManageAllController PlanManageAllController = new ASI_MFM_KR_PlanManageAllController(stdController);
            //Test function
            PlanManageAllController.init();
            System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)planLine.id);
            PlanManageAllController.cloneLine();
            PlanManageAllController.SaveItems();
            PlanManageAllController.addLineItem();
            System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)planLine.id);
            PlanManageAllController.removeLine();
            
            //Test RemoteAction
            List<Account> remo= ASI_MFM_KR_PlanManageAllController.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_PH_DF_Customer');
            List<ASI_MFM_AP_Code__c> remo1= ASI_MFM_KR_PlanManageAllController.findList('ASI_MFM_AP_Code__c','ID','WHERE RecordType.DeveloperName != null');
            List<ASI_CRM_AccountsAdditionalField__c> remo2= ASI_MFM_KR_PlanManageAllController.findCustomers('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName = ASI_CRM_KR_Wholesaler');  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_PlanManageAllController.findAPACCodeMap('ASI_MFM_AP_Code__c','WHERE RecordType.DeveloperName != null');   
            
            test.stopTest(); 
        }
    }
}