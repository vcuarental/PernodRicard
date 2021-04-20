@isTest (SeeAllData=false)
// && !Test.isRunningTest()
public with sharing class ASI_MFM_Plan_TriggerClass_TestClass {
    
    public static String Current_Fiscal_year;

    static testMethod void TestHK(){
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'HK',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_HK_CRM_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_HK_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_HK_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326',ASI_MFM_BU_Code__c='hongkong');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;
        
        Delete p;

    }

    static testMethod void TestTH() {     // Test  ASI_MFM_SelectPlanPrefixController   ASI_MFM_Plan_TriggerClass  AND   ASI_MFM_PlanLineItem_TriggerClass
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
            
            ASI_MFM_Plan_TriggerClass.routineAfterUpdate(plans,mapPlans);
            ASI_MFM_Plan_TriggerClass.routineAfterDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterUpsert(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpdate(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpsert(plans, mapPlans);
            
            Plan1.ASI_MFM_Status__c = 'Submitted';
            Plan1.ASI_MFM_Status__c = 'Draft';
            update Plan1;
        }
      
        
        
        Test.stopTest();
    }
    

    
    
    static testMethod void SG_TEST() {
        // Test ASI_MFM_Plan_TriggerClass  AND   ASI_MFM_PlanLineItem_TriggerClass
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='SG';
        update user1;
        
        UserRole ur = [Select id from userrole where developername='ASI_SG_Asst_Sales_Manager_MOT'];
        Profile p = [select id from profile where name='ASI SG Standard User'];
        User u = new User(alias = 'standt', email='alan.wong@elufasys.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,ASI_MFM_Country__c ='SG',ASI_MFM_Bypass_Callouts__c = true, ASI_MFM_Team__c = 'NTMK', UserRoleid=ur.id,timezonesidkey='America/Los_Angeles', username='alan.wong@elufasys.com');
        // insert u;
        
        //user qiulei = [SELECT id from user where id = '005D000000251hg'];
        
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<string, id> po_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
        //Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
        //Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c');
        //Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
        
        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='SG',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form',ASI_MFM_Fiscal_year__c=getFiscalYear(),ownerId = user1.id);
        insert prefix1 ;
        
        ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,ASI_MFM_Role_Name__c =u.userRole.developerName);            
        insert prefixChild1;
        
        ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,ASI_MFM_Role_Name__c =user1.userRole.developerName);            
        insert prefixChild2;
        
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        insert ac1;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
        insert ac2;
        
        
        ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='SG131',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, ASI_MFM_Status__c='Draft', OwnerId =user1.id);
        insert Plan1;
        
        ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='SG132',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=plan_map.get('ASI_MFM_SG_Plan'),ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c='testDescription', ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
        insert Plan2;

        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2',recordTypeId=subBrandCode_map.get('ASI_CRM_SG_Sub_brand'));
        insert subBrand2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'));
        insert ac;
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        // Add 3 plan Line Item
        list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,
                                                         ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                         ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                         ASI_MFM_A_C_Code__c=ac.id
                                                        ));
        
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
                                                         ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
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
                                                                                ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                                                ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                                                ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                                                ASI_MFM_A_C_Code__c=ac.id);
        
        ASI_MFM_Plan_Line_Item__c planLineItems2= new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
                                                                                ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello144'
                                                                                ,recordTypeId=planLineItem_map.get('ASI_MFM_SG_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                                                ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                                                ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                                                ASI_MFM_A_C_Code__c=ac.id);
        planLineItems2.Id=planLineItems1.Id;
        
        
        list<ASI_MFM_Plan_Line_Item__c> planLineItemsnew1 = new list<ASI_MFM_Plan_Line_Item__c>();
        planLineItemsnew1.add(planLineItems1);
        
        map<Id,ASI_MFM_Plan_Line_Item__c>mapPlanlineitems =new map<Id, ASI_MFM_Plan_Line_Item__c>();
        mapPlanlineitems.put(planLineItems2.Id,planLineItems2);
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        System.runAs(user1){
            ASI_MFM_Plan_TriggerClass.routineAfterDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterUpsert(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpdate(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpsert(plans, mapPlans);
            
            ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(planLineItemsnew1, mapPlanlineitems);
        
                
            Plan2.ASI_MFM_Single_Approval__c = TRUE;
            UPDATE Plan2;
    
    
        }
        
        Test.stopTest();
        
    }    
    
        
    static testMethod void TW_Plan_TriggerClass_Test(){
        
        Profile prof = [select id from profile where name='ASI System Administrator'];
        UserRole ur=new UserRole(Name='Test UserRole', DeveloperName = 'Test_UserRole');
        insert ur;
   
        User u = new User(alias = 'systemA', email='systemadmin@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', 
                          languagelocalekey='en_US', localesidkey='en_US', 
                          profileid = prof.Id,isactive = true ,
                          timezonesidkey='America/Los_Angeles',
                          username='systemadmin@updaterspregiontest.com',
                          userroleID=ur.id, ASI_CRM_User_Group__c = 'Test',
                          ASI_MFM_Country__c = 'TW');
    
        System.runAs(u) { 
            id planLinertId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item');
            
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY0000');
            insert px;        
            
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='Test_UserRole');
            insert pr;
                    
            Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
            ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
            insert subBrand1;
                        
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test', ASI_MFM_A_and_P_Tree__c = 'Total A&P');
            insert ac;
            
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='Spending per Bottle', ASI_MFM_A_and_P_Tree__c = 'Total A&D');
            insert ac2;
            
            id customerrtId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer');
            Account acc2 = new Account(recordTypeId=customerrtId,Name='Name3');  
            
            ASI_MFM_Plan__c p0 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test',
                                                    ASI_MFM_End_Date__c = Date.newInstance(Date.today().year(),6,30), ASI_MFM_Plan_Description__c = 'test', 
            										ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.newInstance(Date.today().year(),6,1),
                                                    ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_Year__c=getFiscalYear(), ASI_MFM_Status__c='Submitted');
            insert p0;
            ASI_MFM_Plan_Line_Item__c pi0 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=planLinertId, ASI_MFM_Plan__c=p0.id
                                                                          ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_Size__c='1', ASI_MFM_Total_Cost__c=100);
            insert pi0;
            
            ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.newInstance(Date.today().year(),6,30), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
            ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.newInstance(Date.today().year(),6,1), 
            ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_year__c='FY0000', ASI_MFM_Additional_Brand_Manager_1__c=u.id, ASI_MFM_Status__c='Draft', ASI_MFM_Cloned_Plan_ID__c=p0.id, ASI_CRM_Converted_Date__c=System.today());
            insert p;        
                     
            insert acc2;
        
            Test.startTest();
                        
            ASI_MFM_Plan_Line_Item__c pi1 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=planLinertId, ASI_MFM_Plan__c=p.id
                                                                          ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_Size__c='1', ASI_MFM_Total_Cost__c=100);
            insert pi1;
            
            ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=planLinertId, ASI_MFM_Plan__c=p.id 
                                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Month_8_Cost__c=100);
            insert pi2;
            
            p0.ASI_MFM_Status__c='Draft';
            update p0;                        
            
            delete p0;
             
           // map<Id, ASI_MFM_Plan__c> mapPlans = new map<Id, ASI_MFM_Plan__c>();
            //mapPlans.put(p0.Id, p0);
            //ASI_MFM_Plan_TriggerClass.routineAfterUpdate(p0, mapPlans);
            Test.stopTest();
        }

    }


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