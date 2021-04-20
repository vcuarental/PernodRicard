@isTest
private class ASI_CTY_CN_Vendor_PRLine_TriggerClsTest {

    static testmethod void ASI_MFM_CN_PO_TriggerClass_TEST(){
        ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');        
        list<User> users = new list<User>();
       //  List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        users.add(user2);
        users.add(user1);
        insert users;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];
    
        System.runAs(user1){       
            String strRTID;
            
            //create fix approval route
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Fix_Approval_Route__c ','ASI_MFM_CN_Fix_Approval_Route');
            ASI_MFM_Fix_Approval_Route__c fapp = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Module__c='PO', ASI_MFM_Team__c ='ABCD', ownerid = user2.id, ASI_MFM_Finance__c = user2.id);
            insert fapp;
            
            //create dynamic approval route
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Dynamic_Approval_Route__c','ASI_MFM_CN_Dynamic_Approval_Route');
            ASI_MFM_Dynamic_Approval_Route__c dapp = new ASI_MFM_Dynamic_Approval_Route__c(recordtypeid=strRTId, ASI_MFM_Type__c='PO', ASI_MFM_User__c=user2.id, ASI_MFM_Approval_Limit__c=30000, 
            ASI_MFM_End_of_1st_Route__c=true);
            insert dapp;

            ASI_MFM_Dynamic_Approval_Route__c dapp2 = new ASI_MFM_Dynamic_Approval_Route__c(recordtypeid=strRTId, ASI_MFM_Type__c='PO', ASI_MFM_User__c=UserInfo.getUserId(), ASI_MFM_Approval_Limit__c=30000, 
            ASI_MFM_End_of_1st_Route__c=true);
            insert dapp2;
            
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
            
            List<ASI_MFM_Plan__c> planList = new List<ASI_MFM_Plan__c>();
            
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            
            ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
                                                        ,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            
            planList.add(plan1);
            planList.add(plan2);
            
            insert planList;
            
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
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

            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
            insert region;
            
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;
            
            ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
            insert city;
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name ='channel Testing', ASI_CRM_CN_On_Off__c='ON',recordtypeid=Schema.getGlobalDescribe().get('ASI_CRM_CN_Channel__c').getDescribe().getRecordTypeInfosByName().get('CN New Channel').getRecordTypeId(),ASI_CRM_For_Outlet__c=true);
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
            insert subChannel;

             ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
             AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
             AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
             AccountsAdditionalField.Name='TEST';
             AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
             AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
             AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
             AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
             insert AccountsAdditionalField; 
            
            Date TodayDateBefore3= system.today().addMonths(-5);
            Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
            Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
            Id contractId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'); 


            
            ASI_TH_CRM_Contract__c contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = contractId,
                                                                         ASI_CRM_CN_Status__c = 'Final',
                                                                         ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                         ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                         ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                         Name = 'Contract1',ASI_CRM_CN_PO_No__c = 'Test',
                                                                         ASI_CRM_CN_Outlet_WS__c=AccountsAdditionalField.Id,ASI_CRM_Volume_Option__c = 'Normal');
            insert contract2;        

            Test.startTest();
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',ASI_MFM_PO_Type__c = 'Gift material',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Contract_Number__c= contract2.ASI_CRM_CN_PO_No__c);
            insert po;
            
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            ASI_MFM_PO_Line_Item__c poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id  );
            insert poli;
  
            Map<id,User> mapUser = new Map<id, User>();
            mapUser.put(users[0].id, users[0]);
            
            
            
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(po);
            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            po.ASI_MFM_Plan__c = Plan2.Id;
            mapPos.put(po.Id, po);
            ASI_MFM_CN_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_CN_PO_TriggerClass.validateContractNumber(pos);
            Map<Id, List<ASI_MFM_PO__c>> polistMap = new Map<Id, List<ASI_MFM_PO__c>>();
            polistMap.put(po.Id, new List<ASI_MFM_PO__c>{po});
            ASI_MFM_CN_PO_TriggerClass.BudgetOwnerValidationCheck(new Set<Id>{plan1.Id}, polistMap, null);
            // ASI_MFM_CN_PO_TriggerClass.setApprovers();
            Test.stopTest();
        }       
    }

    static testMethod void testPRlineApproved() {
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='ASI_CN_TEST',developerName='ASI_CN_TEST');
        insert Role_Test;

        list<User> users = new list<User>();        
        user user1 = [select id,ASI_MFM_Bypass_Callouts__c,ASI_MFM_Team__c,ASI_MFM_Country__c,managerid,ASI_MFM_CN_Staff_No__c,  userRole.developerName, CompanyName from user where id = :userInfo.getUserId()];  
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        user1.ASI_MFM_Country__c ='CN';
        user1.CompanyName = 'Pernod Ricard China';
        user1.ASI_MFM_CN_Staff_No__c ='S0001';
        user1.UserRoleId =Role_Test.id;
        users.add(user1);
        System.debug(LoggingLevel.INFO, '*** Role_Test: ' + Role_Test);
        update users;

        System.runAs(user1){ 
            Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
            String strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            List<ASI_MFM_Prefix__c> LPrefix = new list<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CNB20',ASI_MFM_Module__c='Plan',recordTypeId=strRTID,Plan_Type__c='Marketing A&P Plan',ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id);
            LPrefix.add(prefix1);            
            ASI_MFM_Prefix__c prefix2 = new ASI_MFM_Prefix__c(Name='22YY', ASI_MFM_Module__c='PO', recordTypeId=strRTID,ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            LPrefix.add(prefix2);
            ASI_MFM_Prefix__c prefix3 = new ASI_MFM_Prefix__c(Name='22YY', ASI_MFM_Module__c='CN Vendor PR', recordTypeId=strRTID,ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            LPrefix.add(prefix3);
            insert LPrefix;
                                  
            List<ASI_MFM_Role_Prefix_Relationship__c> LPrefixRel = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[0].Id,ASI_MFM_Role_Name__c =Role_Test.DeveloperName);            
            LPrefixRel.add(prefixChild1);
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[1].Id,ASI_MFM_Role_Name__c =Role_Test.DeveloperName);            
            LPrefixRel.add(prefixChild2);
            
            //AM@Introv 20190620 - fix prefix issue
            List<ASI_MFM_Prefix__c> prefix = [SELECT Id FROM ASI_MFM_Prefix__c WHERE recordtype.developername = 'ASI_MFM_CN_Prefix' and ASI_MFM_Module__c = 'PO' and Name like '22%' and ASI_MFM_Fiscal_year__c = 'FY1314' limit 1];
            if(prefix.size() > 0){
                ASI_MFM_Role_Prefix_Relationship__c prefixChild3 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix[0].Id,ASI_MFM_Role_Name__c =Role_Test.DeveloperName);            
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
            insert LPPAC;
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            System.debug(LoggingLevel.INFO, '*** JSON.serialize(LPrefix): ' + JSON.serialize(LPrefix));
            System.debug(LoggingLevel.INFO, '*** JSON.serialize(LPrefixRel): ' + JSON.serialize(LPrefixRel));
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNB1332',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = date.valueof('2015-06-30'), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=date.valueof('2014-07-01'), ASI_MFM_Budget_Owner__c=user1.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            Plan1 = [SELECT Id,name, ASI_MFM_Fiscal_year__c FROM ASI_MFM_Plan__c WHERE id = :Plan1.id]; 
            system.debug('d001: ' + Plan1.name);
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            List<ASI_MFM_Sub_brand__c> LSB = new List<ASI_MFM_Sub_brand__c>(); 
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
            
            List<ASI_MFM_Sub_brand__c> subBrands = new List<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id,ASI_MFM_Active_for_POSM__c=true));
            insert subBrands;
            
            List<Account> LAcct = new List<Account>();
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            Account supplier = new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',ASI_MFM_Customer_Supplier_Name__c='SupplierName');
            LAcct.add(supplier);
            insert LAcct;
            
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[0].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=LAC[0].id
            );
            insert planLineItem1;                   
            
           
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN', ASI_MFM_Base_Currency__c='RMB');
            insert bu;

            strRTId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MFM_CN_Category_Master');
            List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();                                                                                            
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 1',Name='Display 陈列',ASI_MFM_Running_Number__c=1,ASI_HK_CRM_Category_Code__c='11',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1));
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 2',Name='BAG 包',ASI_MFM_Running_Number__c=2,ASI_HK_CRM_Category_Code__c='22',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2));
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 3',Name='LEATHER 皮质',ASI_MFM_Running_Number__c=3,ASI_HK_CRM_Category_Code__c='33',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3));
            insert ProductCategoryList;
            
            List<ASI_TH_CRM_Sub_category__c> SubCategoryList = new List<ASI_TH_CRM_Sub_category__c>(); 
            strRTId = Global_recordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_MFM_CN_POSM_Sub_Cetagory_Master');
            SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(RecordTypeId=strRTId,ASI_MFM_Category_Level_2_3__c=ProductCategoryList[1].id,ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].id));
            SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(RecordTypeId=strRTId,ASI_MFM_Category_Level_2_3__c=ProductCategoryList[2].id,ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].id));
            insert SubCategoryList;
            
            strRTId = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
            List<ASI_MFM_Item_Group__c> itemGroupList = new List<ASI_MFM_Item_Group__c>();
            itemGroupList.add(new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_Bundle_Item_Group__c=false,
                                                          ASI_MFM_Utilization_Status__c ='Active'
                                                          ,ASI_MFM_Sub_brand__c=subBrands[0].id,ASI_MFM_Inspection__c='抽查',ASI_MFM_Unit__c='ml'
                                                          ,ASI_MFM_Safety_Instruction__c='易碎',ASI_MFM_Period_of_Validity__c='2 - 4 Months'
                                                          ,ASI_CRM_CN_Eng_Name__c='eng',ASI_CRM_CN_Chinese_Name__c='chi',ASI_MFM_Campaign_Name__c=''
                                                          ,ASI_CRM_CN_Pack_Value__c=24,ASI_MFM_Importation__c='import '
                                                          ,ASI_MFM_Category_Level_1__c=ProductCategoryList[0].id
                                                          ,ASI_MFM_Category_Level_2__c=ProductCategoryList[1].id
                                                          ,ASI_MFM_Category_Level_3__c=ProductCategoryList[2].id
                                                          ,ASI_MFM_Category_Level_1_Piclklist__c='Display 陈列'
                                                          ,ASI_MFM_Category_Level_2_Piclklist__c='BAG 包' 
                                                          ,ASI_MFM_Category_Level_3_Piclklist__c='LEATHER 皮质'
                                                          ,ASI_MFM_CN_OneTimeItem__c='Yes'
                                                          ,RecordTypeId=strRTId));
            insert itemGroupList;
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_CTY_CN_Vendor_Plan__c = Plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefix1.id,
                                                                                     ASI_CTY_CN_Vendor_AC_Code__c = ppcac1.ASI_MFM_A_C_Code__c,
                                                                                     ASI_CTY_CN_Vendor_PP_Category__c = ppcac1.ASI_MFM_PP_Category__c,
                                                                                     Recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_CN_Vendor_Purchase_Request'));
            
            insert PR_Header;
            List<ASI_CRM_Quotation__c> mergeQuotations = new List<ASI_CRM_Quotation__c>();
            ASI_CRM_Quotation__c mergeQ1 = new ASI_CRM_Quotation__c();
            mergeQ1.ASI_CTY_CN_Vendor_Item_Group__c = itemGroupList[0].Id;
            mergeQ1.ASI_CTY_CN_Vendor_Supplier__c = supplier.Id;
            mergeQ1.ASI_CTY_CN_Vendor_Status__c = 'Completed';
            mergeQ1.ASI_CTY_CN_Vendor_Result_Status__c = 'Win-Bid';
            mergeQ1.RecordTypeId = Global_recordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Merge_Quotation');
            mergeQuotations.add(mergeQ1);
            ASI_CRM_Quotation__c mergeQ2 = new ASI_CRM_Quotation__c();
            mergeQ2.ASI_CTY_CN_Vendor_Item_Group__c = itemGroupList[0].Id;
            mergeQ2.ASI_CTY_CN_Vendor_Supplier__c = supplier.Id;
            mergeQ2.ASI_CTY_CN_Vendor_Status__c = 'Completed';
            mergeQ2.ASI_CTY_CN_Vendor_Result_Status__c = 'Fail-Bid';
            mergeQ2.RecordTypeId = Global_recordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Merge_Quotation');
            mergeQuotations.add(mergeQ2);
            insert mergeQuotations;

            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_CN_Vendor_Purchase_Request_Line'),
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_CTY_CN_Vendor_Total_Quantity__c = 100,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_CTY_CN_Vendor_Item_Group_Code__c = itemGroupList[0].Id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_CTY_CN_Vendor_Merge_Quotation__c = mergeQ1.Id,
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;

            List<ASI_CRM_Quotation__c> quotations = new List<ASI_CRM_Quotation__c>();
            ASI_CRM_Quotation__c quotation1 = new ASI_CRM_Quotation__c();
            quotation1.ASI_CTY_CN_Purchase_Request_Line__c = PR_Line.Id;
            quotation1.ASI_CTY_CN_Vendor_Item_Group__c = itemGroupList[0].Id;
            quotation1.ASI_CTY_CN_Vendor_Quotation__c = mergeQuotations[0].Id;
            quotation1.ASI_CTY_CN_Vendor_Supplier__c = supplier.Id;
            quotation1.ASI_CTY_CN_Vendor_Status__c = 'Completed';
            quotation1.ASI_CTY_CN_Vendor_Result_Status__c = 'Win-Bid';
            quotation1.ASI_CTY_CN_Vendor_Unitl_Price__c = 100;
            quotation1.RecordTypeId = Global_recordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Quotation');
            quotations.add(quotation1);
            ASI_CRM_Quotation__c quotation2 = new ASI_CRM_Quotation__c();
            quotation2.ASI_CTY_CN_Purchase_Request_Line__c = PR_Line.Id;
            quotation2.ASI_CTY_CN_Vendor_Quotation__c = mergeQuotations[1].Id;
            quotation2.ASI_CTY_CN_Vendor_Item_Group__c = itemGroupList[0].Id;
            quotation2.ASI_CTY_CN_Vendor_Supplier__c = supplier.Id;
            quotation2.ASI_CTY_CN_Vendor_Status__c = 'Completed';
            quotation2.ASI_CTY_CN_Vendor_Result_Status__c = 'Fail-Bid';
            quotation2.ASI_CTY_CN_Vendor_Unitl_Price__c = 100;
            quotation2.ASI_CTY_CN_Vendor_IsConfirmed__c = true;
            quotation2.ASI_CTY_CN_Vendor_Sample__c = 200;
            quotation2.ASI_CTY_CN_Vendor_Model__c = 200;
            quotation2.RecordTypeId = Global_recordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Quotation');
            quotations.add(quotation2);
            insert quotations;
            PR_Line.ASI_CTY_CN_Vendor_Select_Quotation__c = quotation1.Id;
            update PR_Line;
    	Test.startTest();
    	ASI_MFM_Purchase_Request_Line__c PRLine = [SELECT ASI_CTY_CN_Vendor_Status__c FROM ASI_MFM_Purchase_Request_Line__c LIMIT 1];
    	PRLine.ASI_CTY_CN_Vendor_Status__c = 'Approved';
    	update PRLine;
    	Test.stopTest();
    }
}

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
}