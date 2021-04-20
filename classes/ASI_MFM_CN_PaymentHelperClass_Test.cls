@isTest
public class ASI_MFM_CN_PaymentHelperClass_Test {

    public static testmethod void ASI_MFM_CN_POReceiptItem_TriggerClass_TEST3(){
        
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
            
            //ASI_MFM_CN_Payment_TriggerHelperClass.teamMemberSharing(pList);
            //ASI_MFM_CN_Payment_TriggerHelperClass.BudgetOwnerValidationCheck(plList, plList);
            payment.ASI_MFM_AP_Remark__c='Testing';
            
            update payment;
            
            Test.stopTest();
        }
    }

      
    public static testmethod void ASI_MFM_CN_POReceiptItem_TriggerClass_TEST2(){
        
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
            
            Insert new ASI_MFM_Plan__Share(AccessLevel = 'Edit', RowCause = Schema.ASI_MFM_Plan__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c, UserOrGroupId = userInfo.getUserId(), ParentID = Plan1.id);
            
            /*strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            List<ASI_MFM_Sub_brand__c> LSB = new List<ASI_MFM_Sub_brand__c>(); 
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
                                                                      ,recordTypeId=strRTId);
            LSB.add(subBrand1);
            
            ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2'
                                                                      ,recordTypeId=strRTId) ;
            LSB.add(subBrand2);
            insert LSB;*/
            
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
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(OwnerID = user8.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'submitted', ASI_MFM_Prefix__c=LPrefix[2].Id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=user2.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_BU__c=bu.id, ASI_MFM_Currency__c='RMB', ASI_MFM_Sys_Local_Currency__c = 'RMB');
            insert payment;
            
            //create payment line
			strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment_Line_Item__c','ASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 1, ASI_MFM_Paid_Amount_in_PO_Currency__c = 1, ASI_MFM_Tax_Amount__c = 1, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[0].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli1);
            /*
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[1].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            */
            insert palList;
            
            
            Test.stopTest();
        }
    }
}