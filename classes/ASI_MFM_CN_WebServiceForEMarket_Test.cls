@isTest//(seealldata=true) // Enoch@Introv 20190702 fix for insufficient access rights plan line item insert
public class ASI_MFM_CN_WebServiceForEMarket_Test {
    /*static testmethod void (){
        
    }*/
    static Id checkRecordType(string strsobject, string rt_name){
        id RT_id;
        List<recordType> sobjectlist = Global_RecordTypeCache.getRtList(strsobject);
            for (recordtype pl : sobjectlist ){
                if (pl.developername == rt_name)
                RT_id = pl.id;
            }
            system.debug('RT_id: ' + RT_id);
            return RT_id;
            
    }
    
    static testmethod void testGetMFMPlansIdRequest(){
        //User user1 = getSystemAdminUser();
       // user1.ASI_MFM_Bypass_Callouts__c = true;
        //user1.ASI_MFM_Team__c = 'NTMK';
        //System.debug(user1.ASI_MFM_Country__c);
       // system.debug(user1.userRole.developerName);
       // user1.ASI_MFM_Country__c ='CN';
       /// user1.ASI_MFM_CN_Staff_No__c ='S0001';
      //  update user1;
        
       // UserRole ur = [Select id from userrole where developername='ASI_FOC_NTMK_Merchandizing_On_Applier'];
      //  Profile p = [select id from profile where name='ASI CN Standard User'];
      //   User u = new User(alias = 'standt', email='admin_introv@testorg.com',
      //      emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
      //      localesidkey='en_US', profileid = p.Id,ASI_MFM_Country__c ='CN',
      //      ASI_MFM_Bypass_Callouts__c = true, ASI_MFM_Team__c = 'NTMK', UserRoleid=ur.id,
      //      timezonesidkey='America/Los_Angeles', username='admin_introv@testorg.com');
           // insert u;
               List<User> lstUsr = new List<User>();
        User User1 = new User(ASI_MFM_CN_Staff_No__c ='S0001', CompanyName = 'Pernod Ricard China', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(ASI_MFM_CN_Staff_No__c ='S0002', CompanyName = 'Pernod Ricard China', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];    
   /*        list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
      //  user1.ASI_MFM_Bypass_Callouts__c = true;
        user2.ASI_MFM_Team__c = 'NTMK';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.CompanyName = 'Pernod Ricard China';
        user2.ASI_MFM_Country__c ='CN';
        user2.ASI_MFM_CN_Staff_No__c ='S0002';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.CompanyName = 'Pernod Ricard China';
        user1.ASI_MFM_Country__c ='CN';
        user1.ASI_MFM_CN_Staff_No__c ='S0001';
        user1.managerid = user2.id;
        
        users.add(user1);
        
        update users;*/
            

        
        System.runAs(user1){
            
            //AM@Introv 20190718 - error on prod as well - disable passTrigger to check the whole flow
			//AM@Introv 20190620 - set bypass
            //ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true; 
        
            Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   

                                      
            ASI_MFM_Fiscal_Year__c fy = new ASI_MFM_Fiscal_Year__c(Name='FY13');
            insert fy;

            List<ASI_MFM_Prefix__c> LPrefix = new list<ASI_MFM_Prefix__c>();
            String strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='22XX',ASI_MFM_Module__c='Plan',recordTypeId=strRTID,Plan_Type__c='Allowance & Discount Spending Form'
                                                              ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id);
            LPrefix.add(prefix1);
            //create prefix po
            
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='22YY', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                         ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            system.debug('recordTypeId: ' + strRTID);
            LPrefix.add(px);

            insert LPrefix;
             
    
            List<ASI_MFM_Role_Prefix_Relationship__c> LPrefixRel = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            LPrefixRel.add(prefixChild1);
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            LPrefixRel.add(prefixChild2);
            insert LPrefixRel;
            
                                    
            List<ASI_MFM_A_C_Code__c> LAC = new List<ASI_MFM_A_C_Code__c>();
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');                       
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            LAC.add(ac1);
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            LAC.add(ac2);
            insert LAC;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C');
            List<ASI_MFM_PP_Category_A_C__c> LPPAC = new List<ASI_MFM_PP_Category_A_C__c>(); 
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            LPPAC.add(ppcac1); 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            LPPAC.add(ppcac2);
            insert LPPAC; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=LPrefix[0].Id
                                                        ,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            Plan1 = [SELECT Id, Name, ASI_MFM_Prefix__c, recordTypeId, ASI_MFM_End_Date__c, ASI_MFM_Plan_Description__c, 
                        ASI_MFM_Plan_Name__c, ASI_MFM_Start_Date__c, ASI_MFM_Budget_Owner__c, 
                        ASI_MFM_PP_Category__c, ASI_MFM_Market_Strategy__c, ASI_MFM_Status__c, OwnerId,
//                        ASI_MFM_Fiscal_Year_look_up__c, ASI_MFM_Fiscal_Year_look_up__r.Name, ASI_MFM_Prefix__r.name
                            ASI_MFM_Fiscal_year__c,ASI_MFM_Prefix__r.name
                        FROM ASI_MFM_Plan__c 
                        WHERE Id=:Plan1.Id];
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            List<ASI_MFM_Sub_brand__c> LSB = new List<ASI_MFM_Sub_brand__c>(); 
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
                                                                      ,recordTypeId=strRTId);
            LSB.add(subBrand1);
            //insert subBrand1;
            
            ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2'
                                                                      ,recordTypeId=strRTId) ;
            LSB.add(subBrand2);
            insert LSB;
            
            List<Account> LAcct = new List<Account>();
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            Account acc2 = new Account(recordTypeId=strRTId ,Name='Name3');  
            LAcct.add(acc2); 
            
            //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            Account supplier = new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                           ASI_MFM_Customer_Supplier_Name__c='SupplierName');
            LAcct.add(supplier);
            
            insert LAcct;
            
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=Lac[0].id
            );
            insert planLineItem1;       
            planLineItem1 = [SELECT Id, Name, ASI_MFM_Plan__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,
                                ASI_MFM_List_Item_Description__c, recordTypeId, ASI_MFM_Month_1_Cost__c, ASI_MFM_Total_Cost__c,
                                ASI_MFM_Month_2_Cost__c, ASI_MFM_Month_3_Cost__c, ASI_MFM_Month_4_Cost__c, ASI_MFM_Month_5_Cost__c,
                                ASI_MFM_Month_6_Cost__c, ASI_MFM_Month_7_Cost__c, ASI_MFM_Month_8_Cost__c, ASI_MFM_Month_9_Cost__c,
                                ASI_MFM_Month_10_Cost__c, ASI_MFM_Month_11_Cost__c, ASI_MFM_Month_12_Cost__c, ASI_MFM_A_C_Code__c 
                                FROM ASI_MFM_Plan_Line_Item__c WHERE Id=:planLineItem1.Id];
            
            List<ASI_MFM_Plan_Line_Item__c> LPLItem = new List<ASI_MFM_Plan_Line_Item__c>();
            ASI_MFM_Plan_Line_Item__c planLineItem2 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
            ASI_MFM_A_C_Code__c=Lac[0].id
            );
            LPLItem.add(planLineItem2); 
            
             ASI_MFM_Plan_Line_Item__c planLineItem3 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=Lac[0].id
            );
            LPLItem.add(planLineItem3);
            insert LPLItem; 
            
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                 ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=LPrefix[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id
                                                ,ASI_MFM_From_eMarket__c=TRUE);
            insert po;
            // Assume po with plan name 'dummy for test class' exist
            //ASI_MFM_PO__c po = [select id, name from asi_mfm_po__c where ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c= 'dummy for test class' limit 1];
            
            //create po line item
            //rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
            strRTId =checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            ASI_MFM_PO_Line_Item__c poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subbrand1.id,
                                                                       ASI_MFM_A_C_Code__c = Lac[0].id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_PO_Remark__c='Remarks'  
                                                                      ,ASI_MFM_From_eMarket__c=TRUE);
            
            insert poli;
            test.startTest();
            
            //strRTId =checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
           // ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
           //                                     ASI_MFM_Base_Currency__c='RMB');
           // insert bu;
            
            
            
            ASI_MFM_CN_WebServiceForEMarket webserviceForEMarket = new ASI_MFM_CN_WebServiceForEMarket();
            ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdResult result;
            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest('22', 'FY13', 'subBrand1');
            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest('22', 'FY14', 'subBrand1');
            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest('25', 'FY13', 'subBrand1');
            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest('', 'FY13', 'subBrand1');
            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest('27', 'FY13', 'subBrand1');
            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest('22', '', '');
            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest('22', 'FY13', '');
            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest('22', 'FYXX', 'subBrand1');
            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest('22', 'FY1', '');
//            result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest(Plan1.ASI_MFM_Prefix__r.name, Plan1.ASI_MFM_Fiscal_Year_look_up__r.Name, planLineItem1.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c);
result = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlansIdRequest(Plan1.ASI_MFM_Prefix__r.name, Plan1.ASI_MFM_Fiscal_year__c, planLineItem1.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c);

                        
            ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanDetailsResult result2 = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanDetailsRequest('');
            result2 = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanDetailsRequest('');
            //result2 = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanDetailsRequest('CNM131');
            System.debug('Plan1.name'+Plan1.name);
            result2 = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanDetailsRequest(Plan1.name);                        
            result2 = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanDetailsRequest('TEST');
            
            ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanBalanceResult result3 = new ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanBalanceResult();
            result3 = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanBalanceRequest(Plan1.name);
            result3 = ASI_MFM_CN_WebServiceForEMarket.GetMFMPlanBalanceRequest('');
            
            ASI_MFM_CN_WebServiceForEMarket.CreatePOResult result4 = new ASI_MFM_CN_WebServiceForEMarket.CreatePOResult();
            ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs poRequestArgs = new ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs();
            poRequestArgs.PrDept = '';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '23';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = '';            
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            //result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            //poRequestArgs.PrDept = '22';
           // poRequestArgs.PlanId = Plan1.Name;
          //  poRequestArgs.BudgetControlReqInd = null;          
           // result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = '';     
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = ''; 
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = ''; 
            poRequestArgs.ResponsibleBy= ''; 
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= ''; 
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001'; 
            poRequestArgs.SupplierNo='';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '25';
            poRequestArgs.EventId = '';      
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = '';            
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = '';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
        //    poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = 'VAT';
            poRequestArgs.TaskID = '';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs); 
        //    poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = 'VAT';
            poRequestArgs.TaskID  = 'test';
            system.debug('d004: '+poRequestArgs);
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            
            ASI_MFM_CN_WebServiceForEMarket.PODetail poDetail = new ASI_MFM_CN_WebServiceForEMarket.PODetail();
            poDetail.AccountCode = 'AccountCode';
            poDetail.Amount = 200;
            poDetail.SkuCode = 'SKU001';
            poDetail.Quantity = 1;
            poDetail.UnitPrice = 200;
            
            List<ASI_MFM_CN_WebServiceForEMarket.PODetail> poDetailList = new List<ASI_MFM_CN_WebServiceForEMarket.PODetail>();
            poDetailList.add(poDetail);
            poRequestArgs.PoDetails = poDetailList;
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            
            ASI_MFM_CN_WebServiceForEMarket.CompletePoResult result5 = new ASI_MFM_CN_WebServiceForEMarket.CompletePoResult();
            result5 = ASI_MFM_CN_WebServiceForEMarket.CompletePoRequest('');
            result5 = ASI_MFM_CN_WebServiceForEMarket.CompletePoRequest(po.Name);
            
            ASI_MFM_CN_WebServiceForEMarket.EventPP ep = new ASI_MFM_CN_WebServiceForEMarket.EventPP();
            ep.Code = ep.Code;
            ep.Description = ep.Description;
            
            ASI_MFM_CN_WebServiceForEMarket.POInfo poInfo = new ASI_MFM_CN_WebServiceForEMarket.POInfo();
            poInfo.Id = poInfo.Id;
            poInfo.Amount = poInfo.Amount;
            poInfo.AmountInLocalCurrency = poInfo.AmountInLocalCurrency; 

            Test.stopTest();
        }
        
    }
    
    static testmethod void testGetMFMPORequest(){         
        list<User> users = new list<User>();        
        user user1 = [select id,ASI_MFM_Bypass_Callouts__c,ASI_MFM_Team__c,ASI_MFM_Country__c,managerid,ASI_MFM_CN_Staff_No__c,  userRole.developerName, CompanyName from user where id = :userInfo.getUserId()];  
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        user1.ASI_MFM_Country__c ='CN';
        user1.CompanyName = 'Pernod Ricard China';
        user1.ASI_MFM_CN_Staff_No__c ='S0001';
        users.add(user1);  
        update users;

        
        System.runAs(user1){ 
            
            //AM@Introv 20190620 - set bypass
            ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true; 
            
        	Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
            
            ASI_MFM_Fiscal_Year__c fy = new ASI_MFM_Fiscal_Year__c(Name='FY14');
            insert fy;
           
            String strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            List<ASI_MFM_Prefix__c> LPrefix = new list<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='22XX',ASI_MFM_Module__c='Plan',recordTypeId=strRTID,Plan_Type__c='Allowance & Discount Spending Form',ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id);
            LPrefix.add(prefix1);            
            ASI_MFM_Prefix__c prefix2 = new ASI_MFM_Prefix__c(Name='22YY', ASI_MFM_Module__c='PO', recordTypeId=strRTID,ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            LPrefix.add(prefix2);
            insert LPrefix;
                                  
            List<ASI_MFM_Role_Prefix_Relationship__c> LPrefixRel = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[0].Id,ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            LPrefixRel.add(prefixChild1);
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[1].Id,ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            LPrefixRel.add(prefixChild2);
            
            //AM@Introv 20190620 - fix prefix issue
            List<ASI_MFM_Prefix__c> prefix = [SELECT Id FROM ASI_MFM_Prefix__c WHERE recordtype.developername = 'ASI_MFM_CN_Prefix' and ASI_MFM_Module__c = 'PO' and Name like '22%' and ASI_MFM_Fiscal_year__c = 'FY1314' limit 1];
            if(prefix.size() > 0){
                ASI_MFM_Role_Prefix_Relationship__c prefixChild3 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix[0].Id,ASI_MFM_Role_Name__c =user1.userRole.developerName);            
                LPrefixRel.add(prefixChild3);
            }
            
            insert LPrefixRel;
                                      
            List<ASI_MFM_A_C_Code__c> LAC = new List<ASI_MFM_A_C_Code__c>();
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');                       
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            LAC.add(ac1);
            insert LAC;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C');
            List<ASI_MFM_PP_Category_A_C__c> LPPAC = new List<ASI_MFM_PP_Category_A_C__c>(); 
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            LPPAC.add(ppcac1); 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id,ASI_MFM_PP_Category__c=ppc.id);
            LPPAC.add(ppcac2);
            //insert LPPAC; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=LPrefix[0].Id,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = date.valueof('2015-06-30'), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=date.valueof('2014-07-01'), ASI_MFM_Budget_Owner__c=user1.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            Plan1 = [SELECT Id,name, ASI_MFM_Fiscal_year__c FROM ASI_MFM_Plan__c WHERE id = :Plan1.id]; 
            system.debug('d001: ' + Plan1.name);
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            List<ASI_MFM_Sub_brand__c> LSB = new List<ASI_MFM_Sub_brand__c>(); 
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=strRTId);
            LSB.add(subBrand1);
            insert LSB;
            
            List<Account> LAcct = new List<Account>();
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            Account supplier = new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',ASI_MFM_Customer_Supplier_Name__c='SupplierName');
            LAcct.add(supplier);
            insert LAcct;
            
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=LAC[0].id
            );
            insert planLineItem1;                   
            
           
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN', ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO_Read_Only');
            Date startDate = date.newinstance((2000+integer.valueof(prefix2.ASI_MFM_Fiscal_year__c.substring(2,4))),7,1);
            Date endDate = date.newinstance((2000+integer.valueof(prefix2.ASI_MFM_Fiscal_year__c.substring(4,6))),6,30);
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=LPrefix[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=LAcct[0].id, ASI_MFM_Currency__c='USD',
												ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=endDate,
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id 
                                                ,ASI_MFM_From_eMarket__c=TRUE);
            insert po;
            
            test.startTest();
            
            ASI_MFM_CN_WebServiceForEMarket.CreatePOResult result4 = new ASI_MFM_CN_WebServiceForEMarket.CreatePOResult();
            ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs poRequestArgs = new ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs();
            ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs duppoRequestArgs = new ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs();
            
            poRequestArgs.PrDept = '';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '23';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = '';            
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = '';     
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = ''; 
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = ''; 
            poRequestArgs.ResponsibleBy= ''; 
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= ''; 
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001'; 
            poRequestArgs.SupplierNo='';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '25';
            poRequestArgs.EventId = '';      
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = '';            
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = '';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = 'VAT';
            poRequestArgs.TaskID = '';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
        //    poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = 'VAT';
            poRequestArgs.TaskID = 'Test';
            
           // result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            
            ASI_MFM_CN_WebServiceForEMarket.PODetail poDetail = new ASI_MFM_CN_WebServiceForEMarket.PODetail();
            poDetail.AccountCode = 'AccountCode';
            poDetail.Amount = 200;
            poDetail.SkuCode = 'SKU001';
            poDetail.Quantity = 1;
            poDetail.UnitPrice = 200;
            
            List<ASI_MFM_CN_WebServiceForEMarket.PODetail> poDetailList = new List<ASI_MFM_CN_WebServiceForEMarket.PODetail>();
            poDetailList.add(poDetail);
            poRequestArgs.PoDetails = poDetailList;
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            
            ASI_MFM_CN_WebServiceForEMarket.CompletePoResult result5 = new ASI_MFM_CN_WebServiceForEMarket.CompletePoResult();
            result5 = ASI_MFM_CN_WebServiceForEMarket.CompletePoRequest('');
            result5 = ASI_MFM_CN_WebServiceForEMarket.CompletePoRequest(po.Name);
		//	poRequestArgs.PrDept = '25';
         poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = 'VAT';
            
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            poDetail.AccountCode = 'AccountCode';
            poDetail.Amount = 200;
            poDetail.SkuCode = 'SKU001';
            poDetail.Quantity = 1;
            poDetail.UnitPrice = 200;
            
            poDetailList.clear();
            poDetailList.add(poDetail);
            poRequestArgs.PoDetails = poDetailList;
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            
            ASI_MFM_CN_WebServiceForEMarket.Plan oPlan = new ASI_MFM_CN_WebServiceForEMarket.Plan();
            oPlan.Id = Plan1.id;
            oPlan.Name = Plan1.Name;
            
			poRequestArgs.PoDetails = new List<ASI_MFM_CN_WebServiceForEMarket.PODetail>();
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            
            poRequestArgs = NULL;
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            
            Test.stopTest();
        }
        
    }
    
    static testmethod void testGetWebService(){         
        list<User> users = new list<User>();        
        user user1 = [select id,ASI_MFM_Bypass_Callouts__c,ASI_MFM_Team__c,ASI_MFM_Country__c,managerid,ASI_MFM_CN_Staff_No__c,  userRole.developerName, CompanyName from user where id = :userInfo.getUserId()];  
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        user1.ASI_MFM_Country__c ='CN';
        user1.CompanyName = 'Pernod Ricard China';
        user1.ASI_MFM_CN_Staff_No__c ='S0001';
        users.add(user1);  
        update users;

        
        System.runAs(user1){ 
            
            //AM@Introv 20190620 - set bypass
            ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true; 
            
        	Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
            
            ASI_MFM_Fiscal_Year__c fy = new ASI_MFM_Fiscal_Year__c(Name='FY14');
            insert fy;
           
            String strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            List<ASI_MFM_Prefix__c> LPrefix = new list<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='22XX',ASI_MFM_Module__c='Plan',recordTypeId=strRTID,Plan_Type__c='Allowance & Discount Spending Form',ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id);
            LPrefix.add(prefix1);            
            ASI_MFM_Prefix__c prefix2 = new ASI_MFM_Prefix__c(Name='22YY', ASI_MFM_Module__c='PO', recordTypeId=strRTID,ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            LPrefix.add(prefix2);
            insert LPrefix;
                                  
            List<ASI_MFM_Role_Prefix_Relationship__c> LPrefixRel = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[0].Id,ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            LPrefixRel.add(prefixChild1);
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[1].Id,ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            LPrefixRel.add(prefixChild2);
            
            //AM@Introv 20190620 - fix prefix issue
            List<ASI_MFM_Prefix__c> prefix = [SELECT Id FROM ASI_MFM_Prefix__c WHERE recordtype.developername = 'ASI_MFM_CN_Prefix' and ASI_MFM_Module__c = 'PO' and Name like '22%' and ASI_MFM_Fiscal_year__c = 'FY1314' limit 1];
            if(prefix.size() > 0){
                ASI_MFM_Role_Prefix_Relationship__c prefixChild3 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix[0].Id,ASI_MFM_Role_Name__c =user1.userRole.developerName);            
                LPrefixRel.add(prefixChild3);
            }
            
            insert LPrefixRel;
                                      
            List<ASI_MFM_A_C_Code__c> LAC = new List<ASI_MFM_A_C_Code__c>();
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');                       
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            LAC.add(ac1);
            insert LAC;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C');
            List<ASI_MFM_PP_Category_A_C__c> LPPAC = new List<ASI_MFM_PP_Category_A_C__c>(); 
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            LPPAC.add(ppcac1); 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id,ASI_MFM_PP_Category__c=ppc.id);
            LPPAC.add(ppcac2);
            //insert LPPAC; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=LPrefix[0].Id,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = date.valueof('2015-06-30'), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=date.valueof('2014-07-01'), ASI_MFM_Budget_Owner__c=user1.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            Plan1 = [SELECT Id,name, ASI_MFM_Fiscal_year__c FROM ASI_MFM_Plan__c WHERE id = :Plan1.id]; 
            system.debug('d001: ' + Plan1.name);
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            List<ASI_MFM_Sub_brand__c> LSB = new List<ASI_MFM_Sub_brand__c>(); 
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',ASI_MFM_Sub_brand_Code__c='subBrand1',recordTypeId=strRTId);
            LSB.add(subBrand1);
            insert LSB;
            
            List<Account> LAcct = new List<Account>();
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            Account supplier = new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',ASI_MFM_Customer_Supplier_Name__c='SupplierName');
            LAcct.add(supplier);
            insert LAcct;
            
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=LAC[0].id
            );
            insert planLineItem1;                   
            
           
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN', ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO_Read_Only');
            Date startDate = date.newinstance((2000+integer.valueof(prefix2.ASI_MFM_Fiscal_year__c.substring(2,4))),7,1);
            Date endDate = date.newinstance((2000+integer.valueof(prefix2.ASI_MFM_Fiscal_year__c.substring(4,6))),6,30);
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=LPrefix[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=LAcct[0].id, ASI_MFM_Currency__c='USD',
												ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=endDate,
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id 
                                                ,ASI_MFM_From_eMarket__c=TRUE);
            insert po;
            
            test.startTest();
            
            ASI_MFM_CN_WebServiceForEMarket.CreatePOResult result4 = new ASI_MFM_CN_WebServiceForEMarket.CreatePOResult();
            ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs poRequestArgs = new ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs();
            ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs duppoRequestArgs = new ASI_MFM_CN_WebServiceForEMarket.CreatePORequestArgs();
            
            poRequestArgs.PrDept = '';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '23';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = '';            
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = '';     
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = ''; 
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = ''; 
            poRequestArgs.ResponsibleBy= ''; 
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= ''; 
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '22';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001'; 
            poRequestArgs.SupplierNo='';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '25';
            poRequestArgs.EventId = '';      
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = '';            
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = '';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = 'VAT';
            poRequestArgs.TaskID = 'test-taskid';
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            //poRequestArgs.PrDept = '25';
            poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = 'VAT';
            poRequestArgs.TaskID = 'Test';
            
           	//result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequest(poRequestArgs);
            
            ASI_MFM_CN_WebServiceForEMarket.PODetail poDetail = new ASI_MFM_CN_WebServiceForEMarket.PODetail();
            poDetail.AccountCode = 'AccountCode';
            poDetail.Amount = 200;
            poDetail.SkuCode = 'SKU001';
            poDetail.Quantity = 1;
            poDetail.UnitPrice = 200;
            
            List<ASI_MFM_CN_WebServiceForEMarket.PODetail> poDetailList = new List<ASI_MFM_CN_WebServiceForEMarket.PODetail>();
            poDetailList.add(poDetail);
            poRequestArgs.PoDetails = poDetailList;
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            
            ASI_MFM_CN_WebServiceForEMarket.CompletePoResult result5 = new ASI_MFM_CN_WebServiceForEMarket.CompletePoResult();
            result5 = ASI_MFM_CN_WebServiceForEMarket.CompletePoRequest('');
            result5 = ASI_MFM_CN_WebServiceForEMarket.CompletePoRequest(po.Name);
			//poRequestArgs.PrDept = '25';
         	poRequestArgs.PlanId = Plan1.Name;
            poRequestArgs.BudgetControlReqInd = false;
            poRequestArgs.bu = bu.ASI_MFM_BU_Code__c; 
            poRequestArgs.SubBrand = 'subBrand1'; 
            poRequestArgs.ResponsibleBy= 'S0001';
            poRequestArgs.PrDept = '22';
            poRequestArgs.SupplierNo='123';  
            poRequestArgs.PrNo  = 'PR0001';
            poRequestArgs.Vat  = 'VAT';
            
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            poDetail.AccountCode = 'AccountCode';
            poDetail.Amount = 200;
            poDetail.SkuCode = 'SKU001';
            poDetail.Quantity = 1;
            poDetail.UnitPrice = 200;
            
            poDetailList.clear();
            poDetailList.add(poDetail);
            poRequestArgs.PoDetails = poDetailList;
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            
            
            ASI_MFM_CN_WebServiceForEMarket.Plan oPlan = new ASI_MFM_CN_WebServiceForEMarket.Plan();
            oPlan.Id = Plan1.id;
            oPlan.Name = Plan1.Name;
            
			poRequestArgs.PoDetails = new List<ASI_MFM_CN_WebServiceForEMarket.PODetail>();
            result4 = ASI_MFM_CN_WebServiceForEMarket.CreatePORequestRaw(poRequestArgs);
            
            result4 = ASI_MFM_CN_WebServiceForEMarket.GetFinalPOID(poRequestArgs.TaskID);
            result4 = ASI_MFM_CN_WebServiceForEMarket.GetFinalPOID('');
            result4 = ASI_MFM_CN_WebServiceForEMarket.GetFinalPOID('testing');
            
            Test.stopTest();
        }
        
    }
    
    public static User getSystemAdminUser(){      
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];         
        User u1 = [select id,Name, managerid, ASI_MFM_Bypass_Callouts__c,ASI_MFM_Country__c, userRole.developerName, CompanyName from User where profileId =: p.Id 
        and isActive =: true limit 1];      
        return u1;

    }
    public static User getManager(){      
    
        Profile p = [SELECT Id FROM Profile WHERE Name='ASI CN Standard User']; 
        //UserRole role = [select id, developername from userrole where developername = 'ASI_CN_NTMK_Merchandizing_SM'];        
        User u2 = [select id,Name,managerid, ASI_MFM_Bypass_Callouts__c,ASI_MFM_Country__c, userRole.developerName, CompanyName from User where profileId =: p.Id 
        and userRole.developerName = 'ASI_CN_NTMK_Merchandizing_SM' and isActive =: true limit 1];      
        return u2;

    }
    
    public static User getUser(){      
    
        //Profile p = [SELECT Id FROM Profile WHERE Name='ASI CN Standard User']; 
        //UserRole role = [select id, developername from userrole where developername = 'ASI_CN_NTMK_Merchandizing_SM'];        
        User u2 = [select id,Name,managerid, ASI_MFM_Bypass_Callouts__c,ASI_MFM_Country__c, userRole.developerName, CompanyName from User where profile.name ='ASI CN Standard User' 
        and isActive =: true limit 1];      
        return u2;

    }
}