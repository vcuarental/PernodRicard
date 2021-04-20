@isTest
public class ASI_MFM_CN_TaxSaving_Test {
    
    Public Static Testmethod void ASI_MFM_CN_Payment_Tax_Saving_CTRL_Test(){
        
        List<User> lstUsr = new List<User>();
        User User9 = new User(companyName = 'Pernod Ricard China', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test991',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test991', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test991' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User8 = new User(companyName = 'Pernod Ricard China', managerid = User9.id, ASI_MFM_Team__c = 'Testing', ASI_MFM_Country__c ='CN', alias = 'test992',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test992', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test992' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User7 = new User(companyName = 'Pernod Ricard China', managerid = User8.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test993',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test993', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test993' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User6 = new User(companyName = 'Pernod Ricard China', managerid = User7.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test994',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test994', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test994' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User5 = new User(companyName = 'Pernod Ricard China', managerid = User6.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test995',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test995', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test995' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User4 = new User(companyName = 'Pernod Ricard China', managerid = User5.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test996',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test996', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test996' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User3 = new User(companyName = 'Pernod Ricard China', managerid = User4.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test997',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test997', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test997' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User1 = new User(companyName = 'Pernod Ricard China', managerid = User3.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test998',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test998', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test998' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(companyName = 'Pernod Ricard China', BypassTriggers__c = 'ASI_MFM_CN_PO_TriggerClass', managerid = User1.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'tes999',ASI_MFM_Bypass_Callouts__c = true, email='test999' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        
        lstUsr.add(user3);
        lstUsr.add(user4);
        lstUsr.add(user5);
        lstUsr.add(user6);
        lstUsr.add(user7);
        lstUsr.add(user8);
        lstUsr.add(user9);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        for(user u : [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName, ASI_MFM_Team__c
                      FROM User
                      WHERE id =: user1.id 
                      OR id = : user2.id
                      OR id = : user3.id
                      OR id = : user4.id
                      OR id = : user5.id
                      OR id = : user6.id
                      OR id = : user7.id
                      OR id = : user8.id
                      OR id = : user9.id
                      LIMIT 9]){
                          if(u.id == user1.Id){
                              user1 = u;
                          }else if(u.id == user2.Id){
                              user2 = u;
                          }else if(u.id == user3.Id){
                              user3 = u;
                          }else if(u.id == user4.Id){
                              user4 = u;
                          }else if(u.id == user5.Id){
                              user5 = u;
                          }else if(u.id == user6.Id){
                              user6 = u;
                          }else if(u.id == user7.Id){
                              user7 = u;
                          }else if(u.id == user8.Id){
                              user8 = u;
                          }else if(u.id == user9.Id){
                              user9 = u;
                          }
                      }
        
        List<User> ul = new List<User>();
        
        user2.ManagerId = user1.id;
        user1.ManagerId = user3.id;
        user3.ManagerId = user4.id;
        user4.ManagerId = user5.id;
        user5.ManagerId = user6.id;
        user6.ManagerId = user7.id;
        user7.ManagerId = user8.id;
        user8.ManagerId = user9.id;
        
        ul.add(user2);
        ul.add(user1);
        ul.add(user3);
        ul.add(user4);
        ul.add(user5);
        ul.add(user6);
        ul.add(user7);
        ul.add(user8);
        
        update ul;
        
        String strRTID;
        
        List<ASI_MFM_Expense_Control_Form__c> expenseControlForm = new List<ASI_MFM_Expense_Control_Form__c>();
        List<ASI_CRM_Expense_Control_Form_Line__c> expenseLine = new List<ASI_CRM_Expense_Control_Form_Line__c>();
        List<Account> LAcct = new List<Account>();
        strRTId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet');//ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
        Account acc2 = new Account(recordTypeId=strRTId ,Name='Name3');  
        LAcct.add(acc2);
        
        System.runas(user2){
            
            ASI_MFM_Fix_Approval_Route__c fixRoute = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_BA__c = user1.id, ASI_MFM_Corporate_Approver_1__c = user1.id, ASI_MFM_Corporate_Approver_2__c = user1.id,
                                                                                       ASI_MFM_Corporate_Approver_3__c = user1.id, ASI_MFM_Corporate_Approver_4__c = user1.id, ASI_MFM_Finance__c = user1.id, ASI_MFM_Module__c = 'Payment', ASI_MFM_Team__c = 'NTMK',
                                                                                       ASI_MFM_Approval_Limit_BA__c = -10, ASI_MFM_Approval_Limit_CA1__c = -10, ASI_MFM_Approval_Limit_CA2__c = -10, ASI_MFM_Approval_Limit_CA3__c = -10,
                                                                                       ASI_MFM_Approval_Limit_CA4__c = -10, ASI_MFM_Approval_Limit_Finance__c = -10, ASI_MFM_Approval_Limit_BD__c = -10, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_CN_Fix_Approval_Route'));
            
            insert fixRoute;
            
            ASI_MFM_Team__c team = new ASI_MFM_Team__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Team__cASI_MFM_CN_Project_Team'), Name = 'Test');
            Insert team;
            
            ASI_MFM_Team_Member__c teamMember = new ASI_MFM_Team_Member__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Team_Member__cASI_MFM_CN_Team_Member'), ASI_MFM_Team__c = team.id, ASI_MFM_Team_Member__c = userInfo.getUserId());
            Insert teamMember;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix');//ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            List<ASI_MFM_Prefix__c> LPrefix = new list<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN', recordTypeId=strRTID, ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                                              ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user2.id);
            LPrefix.add(prefix1);
            //create prefix po
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                         ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            system.debug('recordTypeId: ' + strRTID);
            LPrefix.add(px);
            ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='Payment', recordTypeId=strRTID,
                                                          ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=99);
            system.debug('recordTypeId: ' + strRTID);
            LPrefix.add(px2);
            insert LPrefix;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> lstRPR = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[0].Id,
                                                                                                       ASI_MFM_Role_Name__c =user2.userRole.developerName);            
            lstRPR.add(prefixChild2);
            
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[1].Id,
                                                                                                       ASI_MFM_Role_Name__c =user2.userRole.developerName);            
            lstRPR.add(prefixChild1);
            ASI_MFM_Role_Prefix_Relationship__c prefixChild3 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[2].Id,
                                                                                                       ASI_MFM_Role_Name__c =user2.userRole.developerName);            
            lstRPR.add(prefixChild3);
            insert lstRPR;
            
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');//ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');                       
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');//ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code'); 
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId );
            
            List<ASI_MFM_A_C_Code__c> lstACCode = new List<ASI_MFM_A_C_Code__c>();
            lstACCode.add(ac1); lstACCode.add(ac2); lstACCode.add(ac);
            insert lstACCode;
            
            expenseControlForm.add(new ASI_MFM_Expense_Control_Form__c(Name = 'Vat-in deduct Consumer'
                                                                       , ASI_MFM_Module__c = 'Consumer A&P Payment'
                                                                       , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Tax_Saving_Control_Form')
                                                                       , ASI_MFM_Tax_Saving_Purpose__c = 'Vat-in deduct Consumer'
                                                                      ));
            
            Insert expenseControlForm;
            
            expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id
                                                                     , ASI_MFM_Department_Category__c = '90'
                                                                     , ASI_MFM_Subbrand_Code__c = '000'
                                                                     , ASI_MFM_Tax_Saving_Formula__c = '100*ASI_MFM_Payment_Amount__c'
                                                                     , ASI_MFM_Tax_Saving_Formula_2__c = 'ASI_MFM_Payment__r.ASI_MFM_VAT_Amount__c * ASI_MFM_Payment_Amount_Ratio__c'
                                                                     , ASI_MFM_A_C_Code__c = lstACCode[0].id
                                                                     , ASI_MFM_Cr_Dr__c = 'Debit'
                                                                     , ASI_MFM_Group_By__c = true
                                                                     , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Tax_Saving_Control_Form_Line')
                                                                    ));
            
            expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id
                                                                     , ASI_MFM_Department_Category__c = '90'
                                                                     , ASI_MFM_Subbrand_Code__c = '000'
                                                                     , ASI_MFM_Tax_Saving_Formula__c = '100*ASI_MFM_Payment_Amount__c'
                                                                     , ASI_MFM_Tax_Saving_Formula_2__c = 'ASI_MFM_Payment__r.ASI_MFM_VAT_Amount__c * ASI_MFM_Payment_Amount_Ratio__c'
                                                                     , ASI_MFM_A_C_Code__c = lstACCode[0].id
                                                                     , ASI_MFM_Cr_Dr__c = 'Credit'
                                                                     , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Tax_Saving_Control_Form_Line')
                                                                    ));
            
            Insert expenseLine;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PP_Category__cASI_MFM_CN_PP_Category');//ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PP_Category_A_C__cASI_MFM_CN_PP_Category_A_C');//ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            List<ASI_MFM_PP_Category_A_C__c> lstPPCat = new List<ASI_MFM_PP_Category_A_C__c>();
            lstPPCat.add(ppcac1); lstPPCat.add(ppcac2);
            insert lstPPCat; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            //ASI_MFM_CN_Supplier 
            strRTId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier');//ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            Account supplier = new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                           ASI_MFM_Customer_Supplier_Name__c='SupplierName');
            LAcct.add(supplier);
            insert LAcct;
            
            //create BU Code
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CN_BU');//ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                 ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            //create brand
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_CN_Brand');//ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
            
            //create sub brand
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_CN_Sub_Brand');//ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            ASI_MFM_Sub_brand__c sb = new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,
                                                               ASI_MFM_Brand__c=brand.id, ASI_MFM_Brand_Director__c = user2.id );
            insert sb;
            
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CN_Plan');//ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=LPrefix[0].Id
                                                        ,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user2.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user2.id
                                                        , ASI_MFM_Project_Team__c = team.id
                                                       );
            insert Plan1;
            
            // Insert new ASI_MFM_Plan__Share(AccessLevel = 'Edit', RowCause = Schema.ASI_MFM_Plan__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c, UserOrGroupId = userInfo.getUserId(), ParentID = Plan1.id);
            
            //insert plan line item
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CN_Plan_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                                                    ,ASI_MFM_Sub_brand_Code__c = sb.id,ASI_MFM_List_Item_Description__c='hello1'
                                                                                    ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
                                                                                    ASI_MFM_A_C_Code__c=ac.id
                                                                                   );
            insert planLineItem1;
            
            //create po
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO');//ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=LPrefix[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_Currency__c='RMB',
                                                 ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                 ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id );
            insert po;
            
            System.debug(Limits.getDMLRows());
            //create po line item
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            List<ASI_MFM_PO_Line_Item__c> polList = new List<ASI_MFM_PO_Line_Item__c>();
            ASI_MFM_PO_Line_Item__c poli1 = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=sb.id,
                                                                        ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=LAcct[0].id, ASI_MFM_Amount__c=1000);
            polList.add(poli1);
            ASI_MFM_PO_Line_Item__c poli2 = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=sb.id,
                                                                        ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=LAcct[0].id, ASI_MFM_Amount__c=1000);
            polList.add(poli2);
            
            insert polList;
            
            Insert new ASI_MFM_Tax_Code__c(Name = '6%', ASI_MFM_VAT_Rate__c = 6);
            
            Test.startTest();
            
            // create payment
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment__c','ASI_MFM_CN_Payment');
            
            List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
            
            
            
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(OwnerID = user2.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%',
                                                                ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'submitted', 
                                                                ASI_MFM_Prefix__c=LPrefix[2].Id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=user2.id, 
                                                                ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_BU__c=bu.id, ASI_MFM_Currency__c='RMB', 
                                                                ASI_MFM_VAT_Amount__c = 10000,
                                                                ASI_MFM_Tax_Saving_Category__c = 'Vat-in deduct Consumer',
                                                                ASI_MFM_Sys_Local_Currency__c = 'RMB');
            pList.add(payment);
            insert pList;
            
            
            //create payment line
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment_Line_Item__c','ASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 1, 
                                                                                   ASI_MFM_Paid_Amount_in_PO_Currency__c = 1,
                                                                                   ASI_MFM_Tax_Amount__c = 1, 
                                                                                   RecordTypeId=strRTId, 
                                                                                   ASI_MFM_PO_Line_Item__c=polList[0].id, 
                                                                                   ASI_MFM_Payment__c = payment.id);
            
            palList.add(payli1);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, 
                                                                                   ASI_MFM_Payment_Amount__c = 10,
                                                                                   ASI_MFM_Paid_Amount_in_PO_Currency__c = 10,
                                                                                   ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, 
                                                                                   ASI_MFM_PO_Line_Item__c=polList[1].id,
                                                                                   ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            
            insert palList;
            
            ApexPages.StandardController scon = new ApexPages.StandardController(payment);
            ASI_MFM_CN_Payment_Tax_Saving_CTRL con = new ASI_MFM_CN_Payment_Tax_Saving_CTRL(scon);
            
            con.selectedCategory = expenseControlForm[0].id;
            
            con.generateTaxSavingLine();
            //con.saveWithoutLine();
            //con.deleteTaxSavingLine();
            
            Test.stopTest();
        }
    }
    
    Public Static TestMethod void ASI_MFM_CN_Payment_Tax_Saving_CTRL_Trade_Test() {
        String accRecordType = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet');
        Account acc = new Account(Name='TEST',RecordTypeId = accRecordType);
        insert acc;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        List<ASI_MFM_A_C_Code__c> lstACCode = new List<ASI_MFM_A_C_Code__c>();
        List<ASI_MFM_Expense_Control_Form__c> expenseControlForm = new List<ASI_MFM_Expense_Control_Form__c>();
        List<ASI_CRM_Expense_Control_Form_Line__c> expenseLine = new List<ASI_CRM_Expense_Control_Form_Line__c>();
        
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') );
        
        lstACCode.add(ac1); lstACCode.add(ac2); lstACCode.add(ac);
        insert lstACCode;
        
        expenseControlForm.add(new ASI_MFM_Expense_Control_Form__c(Name = 'Vat-in deduct Trade'
                                                                   , ASI_MFM_Module__c = 'Trade A&P Payment'
                                                                   , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Tax_Saving_Control_Form')
                                                                   , ASI_MFM_Tax_Saving_Purpose__c = 'Vat-in deduct Trade'
                                                                  ));
        
        Insert expenseControlForm;
        
        expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id
                                                                 , ASI_MFM_Department_Category__c = '90'
                                                                 , ASI_MFM_Subbrand_Code__c = '000'
                                                                 , ASI_MFM_Tax_Saving_Formula__c = '100*ASI_CRM_Payment_Amount__c'
                                                                 , ASI_MFM_Tax_Saving_Formula_2__c = 'ASI_TH_CRM_Payment_Request__r.ASI_CRM_Tax_Amount__c * ASI_CRM_Payment_Amount_Ratio__c'
                                                                 , ASI_MFM_A_C_Code__c = lstACCode[0].id
                                                                 , ASI_MFM_Cr_Dr__c = 'Debit'
                                                                 , ASI_MFM_Group_By__c = true
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Tax_Saving_Control_Form_Line')
                                                                ));
        
        expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id
                                                                 , ASI_MFM_Department_Category__c = '90'
                                                                 , ASI_MFM_Subbrand_Code__c = '000'
                                                                 , ASI_MFM_Tax_Saving_Formula__c = '100*ASI_CRM_Payment_Amount__c'
                                                                 , ASI_MFM_Tax_Saving_Formula_2__c = 'ASI_TH_CRM_Payment_Request__r.ASI_CRM_Tax_Amount__c * ASI_CRM_Payment_Amount_Ratio__c'
                                                                 , ASI_MFM_A_C_Code__c = lstACCode[0].id
                                                                 , ASI_MFM_Cr_Dr__c = 'Credit'
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Tax_Saving_Control_Form_Line')
                                                                ));
        
        Insert expenseLine;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //ASI_CRM_Subbrand_Volume__c
        
        List<ASI_TH_CRM_Contract__c> tmpCT = new List<ASI_TH_CRM_Contract__c>();
        
        ASI_TH_CRM_Contract__c ctLast = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
                                                                   recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                   ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
                                                                   ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
                                                                   ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
                                                                   ASI_CRM_CN_PO_Version__c = '0.0',
                                                                   Name = 'Contract1',                                                       
                                                                   ASI_CRM_CN_Status__c = 'Archived'
                                                                  );
        tmpCT.add(ctLast);
        
        ASI_CRM_Contract_Cost_Setting__c ContractCostSetting = 
            new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_BRSF_Activity_Code_Default__c = true,
                                                 ASI_CRM_CN_Promotion_Type__c = 'New Contract ON');
        insert ContractCostSetting;
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
                                                               recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
                                                               ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
                                                               ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
                                                               ASI_CRM_CN_PO_Version__c = '0.1',
                                                               Name = 'Contract2',
                                                               ASI_CRM_CN_Status__c = 'Draft',
                                                               ASI_CRM_CN_Last_PO_version__c = ctLast.id,
                                                               ASI_CRM_CN_V0_0_PO_version__c = ctLast.id
                                                               
                                                              );
        tmpCT.add(ct);
        
        Insert tmpCT;
        
        List<ASI_CRM_Contract_Cost__c> LContractCost = new List<ASI_CRM_Contract_Cost__c>();
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,name='Promotion Service Fee',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,name='Promotion Service Fee',
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,name='Trading Term Incentives',
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        insert LContractCost;
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST', ASI_CRM_Premium_JDE_Company_Code__c = 'ABC', ASI_CRM_JDE_Company_Code__c = 'ABC');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        /*   a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];*/
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST4',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
        }
        insert subBrands;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
                                                       RecordTypeId=rtOutlet,
                                                       Name='TEST', 
                                                       ASI_CRM_CN_Image__c='Iconic',
                                                       ASI_CRM_CN_CCity__c=city.Id,
                                                       ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        test.startTest();
        
        list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                if(subBrand.name !='TEST3'){
                    svs.add(new ASI_CRM_Subbrand_Volume__c(
                        ASI_CRM_Account__c=a2s[0].Id,
                        ASI_CRM_Subbrand__c=subBrand.Id,
                        ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                        ASI_CRM_T1_Depletion_STD_Billing__c=1,
                        ASI_CRM_T2_Depletion_STD_Billing__c=1,
                        ASI_CRM_PR_Direct_STD_Billing__c=1,
                        ASI_CRM_T1_Depletion_CR12__c=1,
                        ASI_CRM_T2_Depletion_CR12__c=1,
                        ASI_CRM_PR_Direct_CR12__c=1,
                        ASI_CRM_Empty_Bottle__c=1,
                        ASI_CRM_Green_Cap_Std_Billing__c=1,
                        ASI_CRM_Empty_Bottle_CR12__c=1,
                        ASI_CRM_Green_Cap_CR12__c=1));
                    
                    
                    svs.add(new ASI_CRM_Subbrand_Volume__c(
                        ASI_CRM_Account__c=a2s[0].Id,
                        ASI_CRM_Subbrand__c=null,
                        ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                        ASI_CRM_T1_Depletion_STD_Billing__c=1,
                        ASI_CRM_T2_Depletion_STD_Billing__c=1,
                        ASI_CRM_PR_Direct_STD_Billing__c=1,
                        ASI_CRM_T1_Depletion_CR12__c=1,
                        ASI_CRM_T2_Depletion_CR12__c=1,
                        ASI_CRM_PR_Direct_CR12__c=1,
                        ASI_CRM_Empty_Bottle__c=1,
                        ASI_CRM_Green_Cap_Std_Billing__c=1,
                        ASI_CRM_Empty_Bottle_CR12__c=1,
                        ASI_CRM_Green_Cap_CR12__c=1));
                }
            }
        }
        insert svs;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            if(subBrand.name =='TEST1' || subBrand.name =='TEST3'){
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ct.Id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
                
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ctLast.id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            }
            if(subBrand.name =='TEST4'){
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ctLast.id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            }
        }
        
        insert ctis;
        
        list<ASI_TH_CRM_PaymentRequest__c> prsInsert = new list<ASI_TH_CRM_PaymentRequest__c>();
        prsInsert.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                       ASI_CRM_CN_OutletWS__c = a2s[0].id,
                                                       ASI_CRM_New_FY_Payment__c=True, ASI_TH_CRM_Status__c='Draft',
                                                       ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                       ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        prsInsert.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                       ASI_CRM_CN_OutletWS__c = a2s[0].id,
                                                       ASI_CRM_New_FY_Payment__c=True, ASI_TH_CRM_Status__c='Approved',
                                                       ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                       ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prsInsert;
        Set<id> SPRID = new Set<id>();
        for(ASI_TH_CRM_PaymentRequest__c pr : prsInsert){
            SPRID.add(pr.id);
        }
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs = [Select id, ASI_TH_CRM_Contract__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_BRSF_Start_Date__c,
               ASI_CRM_CN_BRSF_End_Date__c, ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,
               ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Bottle_Collection_Rate__c, 
               ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,ASI_CRM_CN_No_of_Month__c,
               ASI_CRM_New_FY_Payment__c, ASI_CRM_Commercial_Team__c, ASI_CRM_Prestige_Region_Code__c
               from ASI_TH_CRM_PaymentRequest__c where id IN :SPRID];
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,ASI_CRM_CN_Incentive_BT__c = 1,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,ASI_CRM_CN_Incentive_BT__c = 1,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,ASI_CRM_CN_Incentive_BT__c = 1,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        ASI_CRM_Contract_Cost_Setting__c costSetting = new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_BRSF_Activity_Code_Default__c = true,ASI_CRM_CN_Promotion_Type__c='New Contract ON');    
        insert costSetting;
        
        test.setCurrentPageReference(new PageReference('Page.ASI_CRM_CN_Payment_Tax_Saving_Page'));
        ApexPages.currentPage().getParameters().put('id',prsInsert[1].Id);
        
        ASI_MFM_CN_Payment_Tax_Saving_CTRL con = new ASI_MFM_CN_Payment_Tax_Saving_CTRL();
        
        con.selectedCategory = expenseControlForm[0].id;
        
        con.generateTaxSavingLine_Trade();
        con.deleteTaxSavingLine();
        con.saveWithoutLine();
        
        test.stopTest();
    }
    
    Public Static TestMethod void ASI_MFM_CN_Payment_Tax_Saving_CTRL_Trade_Test2() {
        String accRecordType = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet');
        Account acc = new Account(Name='TEST',RecordTypeId = accRecordType);
        insert acc;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        List<ASI_MFM_A_C_Code__c> lstACCode = new List<ASI_MFM_A_C_Code__c>();
        List<ASI_MFM_Expense_Control_Form__c> expenseControlForm = new List<ASI_MFM_Expense_Control_Form__c>();
        List<ASI_CRM_Expense_Control_Form_Line__c> expenseLine = new List<ASI_CRM_Expense_Control_Form_Line__c>();
        
        ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
        ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') );
        
        lstACCode.add(ac1); lstACCode.add(ac2); lstACCode.add(ac);
        insert lstACCode;
        
        expenseControlForm.add(new ASI_MFM_Expense_Control_Form__c(Name = 'Vat-in deduct Trade'
                                                                   , ASI_MFM_Module__c = 'Trade A&P Payment'
                                                                   , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Tax_Saving_Control_Form')
                                                                   , ASI_MFM_Tax_Saving_Purpose__c = 'Vat-in deduct Trade'
                                                                  ));
        
        Insert expenseControlForm;
        
        expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id
                                                                 , ASI_MFM_Department_Category__c = '90'
                                                                 , ASI_MFM_Subbrand_Code__c = '000'
                                                                 , ASI_MFM_Tax_Saving_Formula__c = '100*ASI_CRM_Payment_Amount__c'
                                                                 , ASI_MFM_Tax_Saving_Formula_2__c = 'ASI_TH_CRM_Payment_Request__r.ASI_CRM_Tax_Amount__c * ASI_CRM_Payment_Amount_Ratio__c'
                                                                 , ASI_MFM_A_C_Code__c = lstACCode[0].id
                                                                 , ASI_MFM_Cr_Dr__c = 'Debit'
                                                                 , ASI_MFM_Group_By__c = true
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Tax_Saving_Control_Form_Line')
                                                                ));
        
        expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id
                                                                 , ASI_MFM_Department_Category__c = '90'
                                                                 , ASI_MFM_Subbrand_Code__c = '000'
                                                                 , ASI_MFM_Tax_Saving_Formula__c = '100*ASI_CRM_Payment_Amount__c'
                                                                 , ASI_MFM_Tax_Saving_Formula_2__c = 'ASI_TH_CRM_Payment_Request__r.ASI_CRM_Tax_Amount__c * ASI_CRM_Payment_Amount_Ratio__c'
                                                                 , ASI_MFM_A_C_Code__c = lstACCode[0].id
                                                                 , ASI_MFM_Cr_Dr__c = 'Credit'
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Tax_Saving_Control_Form_Line')
                                                                ));
        
        Insert expenseLine;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //ASI_CRM_Subbrand_Volume__c
        
        List<ASI_TH_CRM_Contract__c> tmpCT = new List<ASI_TH_CRM_Contract__c>();
        
        ASI_TH_CRM_Contract__c ctLast = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
                                                                   recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                   ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
                                                                   ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
                                                                   ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
                                                                   ASI_CRM_CN_PO_Version__c = '0.0',
                                                                   Name = 'Contract1',                                                       
                                                                   ASI_CRM_CN_Status__c = 'Archived'
                                                                  );
        tmpCT.add(ctLast);
        
        ASI_CRM_Contract_Cost_Setting__c ContractCostSetting = 
            new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_BRSF_Activity_Code_Default__c = true,
                                                 ASI_CRM_CN_Promotion_Type__c = 'New Contract ON');
        insert ContractCostSetting;
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
                                                               recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
                                                               ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
                                                               ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
                                                               ASI_CRM_CN_PO_Version__c = '0.1',
                                                               Name = 'Contract2',
                                                               ASI_CRM_CN_Status__c = 'Draft',
                                                               ASI_CRM_CN_Last_PO_version__c = ctLast.id,
                                                               ASI_CRM_CN_V0_0_PO_version__c = ctLast.id
                                                              );
        tmpCT.add(ct);
        
        Insert tmpCT;
        
        List<ASI_CRM_Contract_Cost__c> LContractCost = new List<ASI_CRM_Contract_Cost__c>();
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,name='Promotion Service Fee',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,name='Promotion Service Fee',
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,name='Trading Term Incentives',
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        insert LContractCost;
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST', ASI_CRM_Premium_JDE_Company_Code__c = 'ABC', ASI_CRM_JDE_Company_Code__c = 'ABC');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        /*   a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];*/
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST4',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
        }
        insert subBrands;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'prestige',
                                                       RecordTypeId=rtOutlet,
                                                       Name='TEST', 
                                                       ASI_CRM_CN_Image__c='Iconic',
                                                       ASI_CRM_CN_CCity__c=city.Id,
                                                       ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        test.startTest();
        
        list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                if(subBrand.name !='TEST3'){
                    svs.add(new ASI_CRM_Subbrand_Volume__c(
                        ASI_CRM_Account__c=a2s[0].Id,
                        ASI_CRM_Subbrand__c=subBrand.Id,
                        ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                        ASI_CRM_T1_Depletion_STD_Billing__c=1,
                        ASI_CRM_T2_Depletion_STD_Billing__c=1,
                        ASI_CRM_PR_Direct_STD_Billing__c=1,
                        ASI_CRM_T1_Depletion_CR12__c=1,
                        ASI_CRM_T2_Depletion_CR12__c=1,
                        ASI_CRM_PR_Direct_CR12__c=1,
                        ASI_CRM_Empty_Bottle__c=1,
                        ASI_CRM_Green_Cap_Std_Billing__c=1,
                        ASI_CRM_Empty_Bottle_CR12__c=1,
                        ASI_CRM_Green_Cap_CR12__c=1));
                    
                    
                    svs.add(new ASI_CRM_Subbrand_Volume__c(
                        ASI_CRM_Account__c=a2s[0].Id,
                        ASI_CRM_Subbrand__c=null,
                        ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                        ASI_CRM_T1_Depletion_STD_Billing__c=1,
                        ASI_CRM_T2_Depletion_STD_Billing__c=1,
                        ASI_CRM_PR_Direct_STD_Billing__c=1,
                        ASI_CRM_T1_Depletion_CR12__c=1,
                        ASI_CRM_T2_Depletion_CR12__c=1,
                        ASI_CRM_PR_Direct_CR12__c=1,
                        ASI_CRM_Empty_Bottle__c=1,
                        ASI_CRM_Green_Cap_Std_Billing__c=1,
                        ASI_CRM_Empty_Bottle_CR12__c=1,
                        ASI_CRM_Green_Cap_CR12__c=1));
                }
            }
        }
        insert svs;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            if(subBrand.name =='TEST1' || subBrand.name =='TEST3'){
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ct.Id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
                
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ctLast.id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            }
            if(subBrand.name =='TEST4'){
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ctLast.id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            }
        }
        
        insert ctis;
        
        list<ASI_TH_CRM_PaymentRequest__c> prsInsert = new list<ASI_TH_CRM_PaymentRequest__c>();
        prsInsert.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                       ASI_CRM_CN_OutletWS__c = a2s[0].id,
                                                       ASI_CRM_New_FY_Payment__c=True, ASI_TH_CRM_Status__c='Draft',
                                                       ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                       ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'),
                                                       ASI_CRM_Tax_Saving_Category__c = 'Vat-in deduct Trade'
                                                      ));
        prsInsert.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                                                       ASI_CRM_CN_OutletWS__c = a2s[0].id,
                                                       ASI_CRM_New_FY_Payment__c=True, ASI_TH_CRM_Status__c='Approved',
                                                       ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                                                       ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'),
                                                       ASI_CRM_Tax_Saving_Category__c = 'Vat-in deduct Trade'
                                                      ));
        insert prsInsert;
        Set<id> SPRID = new Set<id>();
        for(ASI_TH_CRM_PaymentRequest__c pr : prsInsert){
            SPRID.add(pr.id);
        }
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs = [Select id, ASI_TH_CRM_Contract__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_BRSF_Start_Date__c,
               ASI_CRM_CN_BRSF_End_Date__c, ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,
               ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Bottle_Collection_Rate__c, 
               ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,ASI_CRM_CN_No_of_Month__c,
               ASI_CRM_New_FY_Payment__c, ASI_CRM_Commercial_Team__c, ASI_CRM_Prestige_Region_Code__c
               from ASI_TH_CRM_PaymentRequest__c where id IN :SPRID];
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,ASI_CRM_CN_Incentive_BT__c = 1,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,ASI_CRM_CN_Incentive_BT__c = 1,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,ASI_CRM_CN_Incentive_BT__c = 1,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        ASI_CRM_Contract_Cost_Setting__c costSetting = new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_BRSF_Activity_Code_Default__c = true,ASI_CRM_CN_Promotion_Type__c='New Contract ON');    
        insert costSetting;
        
        test.setCurrentPageReference(new PageReference('Page.ASI_CRM_CN_Payment_Tax_Saving_Page'));
        ApexPages.currentPage().getParameters().put('id',prsInsert[1].Id);
        
        ASI_MFM_CN_Payment_Tax_Saving_CTRL con = new ASI_MFM_CN_Payment_Tax_Saving_CTRL();
        
        con.selectedCategory = expenseControlForm[0].id;
        
        con.generateTaxSavingLine_Trade();
        con.deleteTaxSavingLine();
        con.saveWithoutLine();
        
        con.getSubbrandCode(False, 'asd', 'asd');
        con.getSubbrandCode(False, '', 'asd');
        con.getSubbrandCode(True, 'test', 'asd');
        con.getSubbrandCode(True, 'test', '');
        con.getACCode('', 'testStr');
        con.Back();
        
        test.stopTest();
    }
}