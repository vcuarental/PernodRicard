@isTest
public class ASI_MFM_CN_ClosePO_Test {
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
    
    public class TestObj {
        public Date thisMonth;
        public Date midThisMonth;
        public Date nextMonth;
        public String fy;
        
        public ASI_MFM_Market_Strategy__c ms;
        public List<User> lstUsr;
        public User user1;
        public User user2;
        public User byPassUser;
        public list<ASI_MFM_Prefix__c> prefixs;
        public list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds;
        public list<ASI_MFM_A_C_Code__c> acs;
        public ASI_MFM_PP_Category__c ppc;
        public ASI_MFM_Market_Strategy__c mms;
        public ASI_MFM_Plan__c Plan1;
        public ASI_MFM_Plan__c Plan2;
        public List<ASI_MFM_Plan_Line_Item__c> planlineList;
        public ASI_MFM_Brand__c brand;
        public list<ASI_MFM_Sub_brand__c> subBrands;
        public list<Account> accs;
        public ASI_MFM_Plan_Line_Item__c planLineItem1;
        public ASI_MFM_Plan_Line_Item__c planLineItem2;
        public ASI_MFM_BU__c bu;
        //public ASI_MFM_Exchange_Rate__c ex;
        public list<ASI_MFM_PO__c> pos;
        public list<ASI_MFM_PO_Line_Item__c> polis;
        public ASI_MFM_PO_Receipt__c pOReceipt;
        public ASI_MFM_PO_Receipt_Item__c poreceiptItem;
        
        public TestObj(){
            ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
            
			lstUsr = new List<User>();
            user1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us;', ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            user2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us; ',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            byPassUser = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test999',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us; ASI_MFM_CN_PO_SetPlan_TriggerClass; ASI_MFM_CN_PlanLine_TriggerClass; ASI_MFM_CN_POLine_SetPlan_TriggerClass;', ASI_MFM_Bypass_Callouts__c = true, email='test999' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            lstUsr.add(user1);
            lstUsr.add(user2);
            lstUsr.add(byPassUser);
            insert lstUsr;
            
            
            for(user u : [SELECT Id, Name, ManagerId,BypassVR__c,BypassWF__c,BypassTriggers__c, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                          FROM User
                          WHERE id =: user1.id 
                          OR id =: user2.id
                          LIMIT 2]){
                              if(user1.id == u.id){
                                  user1 = u;
                              }else{
                                  user2 = u;
                              }
                          }
            System.runAs(user1){
                Date thisMonth = Date.today().toStartOfMonth();
                Date midThisMonth = thisMonth.addDays(10);
                Date nextMonth = thisMonth.addMonths(1).addDays(-1);
                String fy = getFiscalYear();
                
                String strRTID;
                
				prefixs = new list<ASI_MFM_Prefix__c>();
                prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                                  ,ASI_MFM_Fiscal_year__c=fy,ownerId = user1.id));
                
                //create prefix po
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
                prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                  ASI_MFM_Fiscal_year__c=fy, ASI_MFM_Next_Number__c=86));
                insert prefixs;
                
				prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
                prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
                                                                         ASI_MFM_Role_Name__c =user1.userRole.developerName));            
                prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
                                                                         ASI_MFM_Role_Name__c =user1.userRole.developerName));            
                
                insert prefixChilds;
                
                
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
				acs = new list<ASI_MFM_A_C_Code__c>();
                acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
                acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
                acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
                insert acs;
                
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
				ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
                insert ppc;
                
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
                list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
                ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
                ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
                insert ppcacs; 
                
				mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
                insert mms;
                
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
                List<ASI_MFM_Plan__c> planList = new List<ASI_MFM_Plan__c>();
                Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
                                            ,recordTypeId=strRTId ,
                                            ASI_MFM_End_Date__c = nextMonth, ASI_MFM_Plan_Description__c='testDescription', 
                                            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=thisMonth, ASI_MFM_Budget_Owner__c=user1.id, 
                                            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
                Plan2 = new ASI_MFM_Plan__c(Name='CNM132',ASI_MFM_Prefix__c=prefixs[0].Id
                                            ,recordTypeId=strRTId ,
                                            ASI_MFM_End_Date__c = nextMonth, ASI_MFM_Plan_Description__c='testDescription', 
                                            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=thisMonth, ASI_MFM_Budget_Owner__c=user1.id, 
                                            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
                planList.add(Plan1);
                planList.add(Plan2);
                insert planList;
                
                //create brand
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
				brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
                insert brand; 
                
				subBrands = new list<ASI_MFM_Sub_brand__c>();
                //create sub brand
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
                subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
                subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
                subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
                insert subBrands;

                accs = new list<Account>();
                
                strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
                accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
                
                //ASI_MFM_CN_Supplier 
                strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
                accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                     ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
                accs.add(new Account(Name='TEST',ASI_MFM_Customer_Supplier_Number__c='61202305', 
                                     RecordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier')));
                insert accs;
                
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
				planlineList = new List<ASI_MFM_Plan_Line_Item__c>();
                planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                              ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
                                                              ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000, ASI_MFM_Remaining_Balance__c=120000
                                                              ,ASI_MFM_A_C_Code__c=acs[2].id
                                                             );
                planLineItem2 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
                                                              ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
                                                              ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000, ASI_MFM_Remaining_Balance__c=120000
                                                              ,ASI_MFM_A_C_Code__c=acs[2].id
                                                             );
                planlineList.add(planLineItem1);
                planlineList.add(planLineItem2);
                insert planlineList; 
                
                //create BU Code
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
				bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                     ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
                insert bu;
                
                
                
                //create exchange rate reference
                /*
				ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=thisMonth,
                                                                           ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                           ASI_MFM_Application__c='MFM' );
                insert ex;
                //*/
                
            }
        }
        public void testDataInit() {
            String strRTId;
            Date thisMonth = Date.today().toStartOfMonth();
            Date midThisMonth = thisMonth.addDays(10);
            Date nextMonth = thisMonth.addMonths(1).addDays(-1);
            String fy = getFiscalYear();
            System.runAs(user2) {
                //create po
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
				pos = new list<ASI_MFM_PO__c>();
                
                pos.add(new ASI_MFM_PO__c(Name='PO66666', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                          ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[2].id, ASI_MFM_Currency__c='RMB',
                                          ASI_MFM_PO_Start_Date__c=thisMonth,ASI_MFM_PO_End_Date__c=nextMonth,
                                          ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft',
                                          ASI_MFM_CN_BU_Picklist__c='PRCN'
                                         ));
                insert pos;
                
                //create po line item
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
                polis = new list<ASI_MFM_PO_Line_Item__c>(); 
                polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=midThisMonth,ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                      ASI_MFM_Amount__c  = 10,ASI_MFM_From_eMarket__c=true, ASI_MFM_Plan_Line_Item__c=planlineList[0].id,
                                                      ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'  ));
                
                insert polis;
                
                //create receipt header
                strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt');
                
                pOReceipt = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = date.today()
                                                                            , recordTypeId = strRTId
                                                                            , ASI_MFM_Auto_Receipt__c = True
                                                                           );
                insert pOReceipt;
                
                strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_CN_PO_Receipt_item');
                poreceiptItem = new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_Amount__c = 5
                                                                                          , recordTypeId = strRTId
                                                                                          , ASI_MFM_PO_Line_Item__c = polis[0].id
                                                                                          , ASI_MFM_Sub_brand_temp__c = polis[0].ASI_MFM_Sub_brand_Code__c
                                                                                          , ASI_MFM_A_C_Code_temp__c = polis[0].ASI_MFM_A_C_Code__c
                                                                                          , ASI_MFM_PO_Receipt__c = pOReceipt.id
                                                                                          , ASI_MFM_Auto_Receipt__c = True
                                                                                          , ASI_MFM_Receipt_Date__c = date.today()
                                                                                          , ASI_MFM_Currency_Temp__c = polis[0].ASI_MFM_Currency__c
                                                                                         );
                //insert poreceiptItem;
            }
        }
	}

    static testmethod void testPlanline() {
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_ClosePO_Test.TestObj testObj = new ASI_MFM_CN_ClosePO_Test.TestObj();
        testObj.testDataInit();
        User user1 = testObj.user1;
        User user2 = testObj.user2;
        
        System.runAs(user2){
            Test.startTest();
            Test.stopTest();
        }
    }
    
    static testmethod void ASI_MFM_ClosePO_Trigger_TEST(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        TestObj testObj = new TestObj();
        testObj.testDataInit();
        User user1 = testObj.user1;
        User user2 = testObj.user2;
        System.runAs(user2){
            Test.startTest();
            ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = false;
            testObj.pos[0].ASI_MFM_Status__c = 'Draft';
            //update testObj.pos;
            testObj.planlineList[0].ASI_MFM_Remaining_Balance__c = null;
            testObj.polis[0].ASI_MFM_From_eMarket__c = false;
            update testObj.polis;
            update testObj.planlineList;
            testObj.pos[0].ASI_MFM_Plan__c = testObj.Plan2.id;
            update testObj.pos;
            delete testObj.polis;
            undelete testObj.polis; 
			Test.stopTest();
        }
    }
    static testmethod void ASI_MFM_ClosePO_Trigger_TEST_SG(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        String fy = getFiscalYear();

//Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        System.runAs(u){
            ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                       ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
            insert xr;         
            //Set Plan prefix
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
            insert px;
            
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pr;
            
            
            ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                    ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
            insert p;
            update p;
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = p.id
                                                                                    ,ASI_MFM_List_Item_Description__c='hello1'
                                                                                    ,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SG_Plan_Line_Item')
                                                                                   );
            insert planLineItem1;
            update planLineItem1;
        }

    }
    
    static testMethod void ASI_MFM_ClosePO_Trigger_TEST_PH(){
        // Not in B5
        /*
        user u = [SELECT ID, ASI_MFM_Country__c, UserRole.DeveloperName FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        ASI_MFM_PH_TestClassHelper.createMFMDefaultValues();
        
        String FY = ASI_MFM_PH_TestClassHelper.getFiscalYear();
        
        ASI_MFM_Prefix__c pxo = ASI_MFM_PH_TestClassHelper.createPHDFPrefixPlan();
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='Plan',ASI_MFM_ByPassThreshold__c=true);
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
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        ASI_MFM_Sub_brand__c sb = ASI_MFM_PH_TestClassHelper.CreateDPSBrand();
        
        ASI_MFM_Plan__c plan2 = new ASI_MFM_Plan__c
            (
                Name = 'Test Plan',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'),
                ASI_MFM_Start_Date__c = date.today().adddays(1),
                ASI_MFM_End_Date__c = date.today().adddays(1),
                ASI_MFM_Prefix__c = pxo.id
            );
        insert plan2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_PH_DF_Customer'),Name='Name3');
        
        ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
            (
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_PH_Plan_Line_Item'),
                ASI_MFM_List_Item_Description__c = 'test description',
                ASI_MFM_Total_Cost__c = 1234,
                ASI_MFM_Plan__c = plan2.id,
                ASI_MFM_Sub_brand_Code__c=sb.id,
                ASI_MFM_A_C_Code__c=ASI_MFM_PH_testClasshelper.createACPHDPCode().id,
                ASI_MFM_Customer_Name__c=acc2.id
            );
        insert planLine;
        update planLine;
        
        delete planLine;
        delete plan2;
*/
    }
    
    static testmethod void ASI_MFM_ClosePO_Trigger_TEST_MY(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='MY';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_MY_Prefix'));
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Active__c = true); // Note :use Payment Prefix
        insert rtm;
        // ASI MFM Route Rule Details Set Approver 
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        insert rrd;
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        insert rrd2;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode');
        insert subBrand1;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), name='test', ASI_MFM_End_Date__c = Date.today().addMonths(1), 
                                                ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
                                                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), 
                                                ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Draft');
        insert p;
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test');
        insert ac;
        
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC2', ASI_MFM_A_C_Code__c='5210.STK1');
        insert ac2;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Total_Cost__c = 10, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi;
        
        ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Total_Cost__c = 100, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'), ASI_MFM_Plan__c=p.id, ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2');
        insert pi2;
        update p;
        update pi2;
    }
    
    static testmethod void ASI_MFM_ClosePO_TEST(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        Date thisMonth = Date.today().toStartOfMonth();
        Date midThisMonth = thisMonth.addDays(10);
        Date nextMonth = thisMonth.addMonths(1).addDays(-1);
        String fy = getFiscalYear();
        
        String strRTID;
        TestObj testObj = new TestObj();
        testObj.testDataInit();
        User user1 = testObj.user1;
        User user2 = testObj.user2;
        list<ASI_MFM_PO__c> pos = testObj.pos;
        ASI_MFM_PO_Receipt__c pOReceipt = testObj.pOReceipt;
        

        System.runAs(user2){
            Test.startTest();
            ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = false;
            list<ASI_MFM_PO_Line_Item__c> polis = testObj.polis;
            insert testObj.poreceiptItem;            
            List<ASI_MFM_PO_Line_Item__c> polineItemList = testObj.polis;            
            
            Id rtid = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');        
            ASI_MFM_BatchLog__c log = new ASI_MFM_BatchLog__c(RecordTypeId=rtid, ASI_MFM_Log_Detail__c='', ASI_MFM_LogType__c='Close PO');
            insert log;
            ASI_MFM_CN_ClosePO_Batch cls = new ASI_MFM_CN_ClosePO_Batch();
            cls.execute(null, polineItemList);
            
            cls = new ASI_MFM_CN_ClosePO_Batch(log.id, '');
            cls.execute(null, polineItemList);
            Test.stopTest();
        }

    }
    
    static testmethod void ASI_MFM_ClosePO_TEST2(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        Date thisMonth = Date.today().toStartOfMonth();
        Date midThisMonth = thisMonth.addDays(10);
        Date nextMonth = thisMonth.addMonths(1).addDays(-1);
        String fy = getFiscalYear();
        
        String strRTID;
        TestObj testObj = new TestObj();
        testObj.testDataInit();
        User user1 = testObj.user1;
        User user2 = testObj.user2;
        list<ASI_MFM_PO__c> pos = testObj.pos;
        ASI_MFM_PO_Receipt__c pOReceipt = testObj.pOReceipt;
        

        System.runAs(user2){
            Test.startTest();
            ASI_MFM_CN_ClosePO_Ctrl c = new ASI_MFM_CN_ClosePO_Ctrl();
            string tmp = c.msg;
            id tmpid = c.BatchId;
            tmpid = c.LogId;
            
            ASI_MFM_CN_ClosePO_Ctrl.searchPO(fy,'','');
            ASI_MFM_CN_ClosePO_Ctrl.searchPO(fy,pos[0].id,'');
            ASI_MFM_CN_ClosePO_Ctrl.searchPO(fy,'',user2.id);
            ASI_MFM_CN_ClosePO_Ctrl.searchPO(fy,pos[0].id,user2.id);
            
            ASI_MFM_CN_ClosePO_Ctrl.searchPOList('fy',fy);
            ASI_MFM_CN_ClosePO_Ctrl.searchPOList('po',pos[0].id);
			ASI_MFM_CN_ClosePO_Ctrl.searchPOList('owner',user2.id);
            
            ASI_MFM_CN_ClosePO_Ctrl.closePoById(pos[0].id);
            
            
            list<ASI_MFM_PO_Line_Item__c> polis = testObj.polis;
            insert testObj.poreceiptItem;
            ASI_MFM_CN_ClosePO_Ctrl.closePoById(pos[0].id);
            
            PageReference pageRef = Page.ASI_MFM_CN_ClosePO_Page;
            pageRef.getParameters().put('searchFy', fy);
            pageRef.getParameters().put('searchPoId', pos[0].id);
            pageRef.getParameters().put('searchOwnerId', user2.id);
            c.startCloseJob();
            string[] tmpStrs = c.StatusMsgs;
            
            Test.setCurrentPage(pageRef);
            Test.stopTest();
        }    
    }
    
    static testmethod void ASI_MFM_POLineItem_TriggerClass_TEST(){
    	ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
        List<User> lstUsr = new List<User>();
        User user1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User user2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User byPassUser = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test999',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us; ASI_MFM_CN_PO_SetPlan_TriggerClass; ASI_MFM_CN_PlanLine_TriggerClass; ASI_MFM_CN_POLine_SetPlan_TriggerClass;', ASI_MFM_Bypass_Callouts__c = true, email='test999' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
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
       /* list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
        ASI_MFM_PO_Line_Item__c poli;
        System.runAs(byPassUser){
        
            String strRTID;            
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id );
            insert po;
            
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,
                                                                      ASI_MFM_Spread_by_Months__c=true,ASI_MFM_Amount__c=1,ASI_MFM_PO_Remark__c='Remarks');

        }
        System.runAs(user2){
            Test.startTest();

            list<ASI_MFM_PO_Line_Item__c> lineItems = new list<ASI_MFM_PO_Line_Item__c>();
            lineItems.add(poli);
            map<Id, ASI_MFM_PO_Line_Item__c> mapLineItems = new map<Id, ASI_MFM_PO_Line_Item__c>();
            mapLineItems.put(poli.Id, poli);
            ASI_MFM_POLineItem_TriggerClass.routineBeforeDelete(lineItems);
            ASI_MFM_POLineItem_TriggerClass.routineBeforeInsert(lineItems);
            ASI_MFM_POLineItem_TriggerClass.routineBeforeUpsert(lineItems, mapLineItems);
            ASI_MFM_POLineItem_TriggerClass.routineAfterUpsert(lineItems, mapLineItems);
            ASI_MFM_POLineItem_TriggerClass.routineAfterAll(lineItems, mapLineItems);
            ASI_MFM_POLineItem_TriggerClass.routineAfterAll(null, mapLineItems);
            
            //20190718-AM@Introv-copy from ASI_MFM_CN_PO_Test for ASI_MFM_CN_POLine_SetPlan_TriggerClass
            ASI_MFM_CN_POLine_SetPlan_TriggerClass.routineBeforeInsert(lineItems);
            ASI_MFM_CN_POLine_SetPlan_TriggerClass.routineBeforeUpdate(lineItems, mapLineItems);
            
            list<ASI_MFM_BU__c> bu_list =new list<ASI_MFM_BU__c> ();
            bu_list.add(new ASI_MFM_BU__c());
            ASI_MFM_POLineItem_TriggerClass.setDefaultBUCode(lineItems, bu_list);
            Test.stopTest();

        }
    }    
    
    
}