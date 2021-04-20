@isTest
private class ASI_MFM_CN_Event_Test {
    static list<ASI_MFM_Event_Outlet__c> trigger_new=new list<ASI_MFM_Event_Outlet__c>();
    static list<ASI_MFM_Event__c > event_list=new list<ASI_MFM_Event__c >();

    static testMethod void ASI_MFM_EventPPInputPageController_TEST() {
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        update user1;
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7);
		insert RunningNo;
        System.runAs(user1){
            
            Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
            Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
            Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
            Map<string, id> event_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Event__c');
            Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
            Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
            Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
            Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c');
            Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
            //added at 20141127 by D
            Map<string, id> eventSubBrand_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Event_Sub_Brand__c');
             
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form', ASI_MFM_Fiscal_year__c='FY1314', ownerId = user1.id);
            insert prefix1;
                         
            ASI_MFM_Role_Prefix_Relationship__c prefixChild = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id, ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            insert prefixChild;
                                    
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            insert ac1;
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            insert ac2;
            
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=ppc_map.get('ASI_MFM_CN_PP_Category'), Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac1; 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac2; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            list<ASI_MFM_Plan__c> plans = new list<ASI_MFM_Plan__c>();
            plans.add(new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id,
                                          recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
                                          ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                          ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                          ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id));

            plans.add(new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id,
                                          recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
                                          ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                          ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                          ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id));
            
            insert plans;
            
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1',ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=subBrandCode_map.get('ASI_FOC_CN_Sub_brand')));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2',ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=subBrandCode_map.get('ASI_FOC_CN_Sub_brand')));
            insert subBrands;
                        
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'));
            insert ac;
            
            list<ASI_MFM_Plan_Line_Item__c> plines = new list<ASI_MFM_Plan_Line_Item__c>();
            plines.add(new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plans[0].id,
                                                     ASI_MFM_Sub_brand_Code__c = subBrands[0].id,ASI_MFM_List_Item_Description__c='hello1',
                                                     recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                     ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                     ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                     ASI_MFM_A_C_Code__c=ac.id));

            plines.add(new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plans[1].id,
                                                    ASI_MFM_Sub_brand_Code__c = subBrands[1].id,ASI_MFM_List_Item_Description__c='hello2',
                                                    recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
                                                    ASI_MFM_A_C_Code__c=ac.id));
                        
            insert plines;
                        
            ASI_MFM_Event__c event = new ASI_MFM_Event__c(ASI_MFM_Key_Event_Type_Budget_Share__c = 100,ASI_MFM_Event_Type__c = 'Image/Brand Driven Event', ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',recordtypeid = event_map.get('ASI_MFM_CN_Event'));
            insert event;
            ASI_MFM_Event_Sub_Brand__c esb = new ASI_MFM_Event_Sub_Brand__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Sub_Brand__c=subBrands[0].Id, recordtypeid=eventSubBrand_map.get('ASI_MFM_CN_Event_Sub_Brand'));
            insert esb;
        
            list<ASI_MFM_Event_PP__c> epps = new list<ASI_MFM_Event_PP__c>();
            epps.add(new ASI_MFM_Event_PP__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Plan__c=plans[0].Id));
            epps.add(new ASI_MFM_Event_PP__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Plan__c=plans[1].Id));
            epps.add(new ASI_MFM_Event_PP__c(ASI_MFM_Event__c=ASI_MFM_Function.CreateFakeId(ASI_MFM_Event__c.SObjectType,1), ASI_MFM_Plan__c=plans[0].Id));
            epps.add(new ASI_MFM_Event_PP__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Plan__c=ASI_MFM_Function.CreateFakeId(ASI_MFM_Plan__c.SObjectType,1)));
                 
            test.startTest();
                     
            ApexPages.StandardSetController scon = new ApexPages.StandardSetController(epps);
            ApexPages.currentPage().getParameters().put('id', event.Id);
            ASI_MFM_EventPPInputPageController con = new ASI_MFM_EventPPInputPageController(scon);
                            
            con.eventId = con.eventId;
            con.initSupplierNum = con.initSupplierNum;
            con.pp_filter = con.pp_filter;
            con.pp_obj_filter = con.pp_obj_filter;
            con.budgetOwnerPickList = con.budgetOwnerPickList;
            con.ppCategoryPickList = con.ppCategoryPickList;
            con.pol_obj_filter = con.pol_obj_filter;
            con.user_obj_filter = con.user_obj_filter;
            string s = con.init_search;
            s = con.init_search_with_header_info;
            ASI_MFM_Event__c e = con.event;
            con.raised_by_filter = con.raised_by_filter;
            con.subBrandPickList = con.subBrandPickList;
            con.subBrandOptions = con.subBrandOptions;
            con.FilterPP();
            con.sobjst_initActionButtonList();
            con.sobjst_initActionButtonStageMap();
            con.mcau_initPageBlockActionButtonList();
            con.mcau_triggerPageBlockAction(null,'');
            con.thisController = con.thisController;
            con.setComponentController(null);
            con.setComponentController('TEST', null);
            con.getComponentController();
            con.getComponentController('TEST');         
            
            test.stopTest();
        }
    }    

    static testMethod void ASI_MFM_CN_EventPP_TriggerClass_TEST() {

        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        update user1;
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7);
		insert RunningNo;
        System.runAs(user1){
            
            Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
            Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
            Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
            Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
            Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
            Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
            Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c');
            Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
            Map<string, id> event_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Event__c');
            //added at 20141127 by D
            Map<string, id> eventSubBrand_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Event_Sub_Brand__c');
             
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form', ASI_MFM_Fiscal_year__c='FY1314', ownerId = user1.id);
            insert prefix1;
                         
            ASI_MFM_Role_Prefix_Relationship__c prefixChild = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id, ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            insert prefixChild;
                                    
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            insert ac1;
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            insert ac2;
            
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=ppc_map.get('ASI_MFM_CN_PP_Category'), Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac1; 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac2; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            list<ASI_MFM_Plan__c> plans = new list<ASI_MFM_Plan__c>();
            plans.add(new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id,
                                          recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
                                          ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                          ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                          ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id));

            plans.add(new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id,
                                          recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
                                          ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                          ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                          ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id));
            
            insert plans;
            
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1',ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=subBrandCode_map.get('ASI_FOC_CN_Sub_brand')));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2',ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=subBrandCode_map.get('ASI_FOC_CN_Sub_brand')));
            insert subBrands;
                        
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'));
            insert ac;
            
            list<ASI_MFM_Plan_Line_Item__c> plines = new list<ASI_MFM_Plan_Line_Item__c>();
            plines.add(new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plans[0].id,
                                                     ASI_MFM_Sub_brand_Code__c = subBrands[0].id,ASI_MFM_List_Item_Description__c='hello1',
                                                     recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                     ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                     ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                     ASI_MFM_A_C_Code__c=ac.id));

            plines.add(new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plans[1].id,
                                                    ASI_MFM_Sub_brand_Code__c = subBrands[1].id,ASI_MFM_List_Item_Description__c='hello2',
                                                    recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
                                                    ASI_MFM_A_C_Code__c=ac.id));
                        
            insert plines;
                        
            ASI_MFM_Event__c event = new ASI_MFM_Event__c(ASI_MFM_Key_Event_Type_Budget_Share__c = 100,ASI_MFM_Event_Type__c = 'Image/Brand Driven Event', ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',recordTypeId = event_map.get('ASI_MFM_CN_Event'));
            insert event;
        
            ASI_MFM_Event_Sub_Brand__c esb = new ASI_MFM_Event_Sub_Brand__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Sub_Brand__c=subBrands[0].Id, recordtypeid=eventSubBrand_map.get('ASI_MFM_CN_Event_Sub_Brand'));
            insert esb;
        
            list<ASI_MFM_Event_PP__c> epps = new list<ASI_MFM_Event_PP__c>();
            epps.add(new ASI_MFM_Event_PP__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Plan__c=plans[0].Id));
            epps.add(new ASI_MFM_Event_PP__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Plan__c=plans[1].Id));
            epps.add(new ASI_MFM_Event_PP__c(ASI_MFM_Event__c=ASI_MFM_Function.CreateFakeId(ASI_MFM_Event__c.SObjectType,1), ASI_MFM_Plan__c=plans[0].Id));
            epps.add(new ASI_MFM_Event_PP__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Plan__c=ASI_MFM_Function.CreateFakeId(ASI_MFM_Plan__c.SObjectType,1)));
                 
            test.startTest();
                     
            ASI_MFM_CN_EventPP_TriggerClass.routineBeforeInsert(epps);
                     
            test.stopTest();
            
        }
    }
    
    static testMethod void ASI_MFM_CN_Event_Trigger_TEST(){
       User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        update user1;
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7);
		insert RunningNo;
        System.runAs(user1){
            
            Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
            Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
            Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
            Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
            Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
            Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
            Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c');
            Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
            Map<string, id> event_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Event__c');
            //added at 20141127 by D
            Map<string, id> eventSubBrand_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Event_Sub_Brand__c');
             
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form', ASI_MFM_Fiscal_year__c='FY1314', ownerId = user1.id);
            insert prefix1;
                         
            ASI_MFM_Role_Prefix_Relationship__c prefixChild = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id, ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            insert prefixChild;
                                    
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            insert ac1;
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            insert ac2;
            
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=ppc_map.get('ASI_MFM_CN_PP_Category'), Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac1; 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac2; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            list<ASI_MFM_Plan__c> plans = new list<ASI_MFM_Plan__c>();
            plans.add(new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id,
                                          recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
                                          ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                          ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                          ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id));

            plans.add(new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id,
                                          recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
                                          ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                          ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                          ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id));
            
            insert plans;
            
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1',ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=subBrandCode_map.get('ASI_FOC_CN_Sub_brand')));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2',ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=subBrandCode_map.get('ASI_FOC_CN_Sub_brand')));
            insert subBrands;
                        
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'));
            insert ac;
            
            list<ASI_MFM_Plan_Line_Item__c> plines = new list<ASI_MFM_Plan_Line_Item__c>();
            plines.add(new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plans[0].id,
                                                     ASI_MFM_Sub_brand_Code__c = subBrands[0].id,ASI_MFM_List_Item_Description__c='hello1',
                                                     recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
                                                     ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
                                                     ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
                                                     ASI_MFM_A_C_Code__c=ac.id));

            plines.add(new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plans[1].id,
                                                    ASI_MFM_Sub_brand_Code__c = subBrands[1].id,ASI_MFM_List_Item_Description__c='hello2',
                                                    recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
                                                    ASI_MFM_A_C_Code__c=ac.id));
                        
            insert plines;
                        
            ASI_MFM_Event__c event = new ASI_MFM_Event__c(ASI_MFM_Key_Event_Type_Budget_Share__c = 100,ASI_MFM_Event_Type__c = 'Image/Brand Driven Event', ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',recordTypeId = event_map.get('ASI_MFM_CN_Event'));
            insert event;
        
            ASI_MFM_Event_Sub_Brand__c esb = new ASI_MFM_Event_Sub_Brand__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Sub_Brand__c=subBrands[0].Id, recordtypeid=eventSubBrand_map.get('ASI_MFM_CN_Event_Sub_Brand'));
            insert esb;
            ASI_MFM_Event_Sub_Brand__c esb2 = new ASI_MFM_Event_Sub_Brand__c(ASI_MFM_Event__c=event.Id, ASI_MFM_Sub_Brand__c=subBrands[0].Id);
        
            string strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_Event_PP__c','ASI_MFM_CN_Event_PP');
            list<ASI_MFM_Event_PP__c> epps = new list<ASI_MFM_Event_PP__c>();
            epps.add(new ASI_MFM_Event_PP__c(recordTypeId=strRTId ,ASI_MFM_Event__c=event.Id, ASI_MFM_Plan__c=plans[0].Id));
            
            
            strRTId =ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            Account acc2 = new Account(recordTypeId=strRTId ,Name='Name3');           
            insert acc2;
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_Event_Outlet__c','ASI_MFM_CN_Event_Outlet');
            ASI_MFM_Event_Outlet__c eventoutlet = new ASI_MFM_Event_Outlet__c(recordTypeId=strRTId ,
            ASI_MFM_Event_Type__c='Image/Brand Driven Event', ASI_MFM_Event__c=event.id,ASI_MFM_Outlet__c=acc2.id,
            ASI_MFM_Beginning_Date__c=date.today(),ASI_MFM_End_Date__c =date.today(),ASI_MFM_Wave__c='1');
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_Channel__c','ASI_MFM_CN_Sub_Channel'); 
            ASI_MFM_Sub_Channel__c subchannel = new ASI_MFM_Sub_Channel__c(recordTypeId=strRTId ,name='testsubchannel');
            
            insert subChannel;
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_Event_Sub_Channel__c','ASI_MFM_CN_Event_Sub_Channel'); 
            ASI_MFM_Event_Sub_Channel__c esubchannel= new ASI_MFM_Event_Sub_Channel__c(recordTypeId=strRTId ,ASI_MFM_Event__c=event.id,ASI_MFM_Sub_Channel__c=subChannel.id);
            ASI_MFM_Event_Sub_Channel__c esubchannel2= new ASI_MFM_Event_Sub_Channel__c(recordTypeId=strRTId ,ASI_MFM_Event__c=event.id,ASI_MFM_Sub_Channel__c=subChannel.id);
            
            event.Name = 'Test Update';
            
            
            test.startTest();
            insert esubchannel;
            update esubchannel;
            insert eventoutlet;
            insert epps; 
            update esb;
            update event;
            try{
            insert esubchannel2;}
            catch(exception e){}
            try{
            insert esb2;}
            catch(exception e){}    
            test.stopTest();
            }
    }

}