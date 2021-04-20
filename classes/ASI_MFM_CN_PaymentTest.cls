@isTest //(seealldata=true)
public class ASI_MFM_CN_PaymentTest {
    
    static testmethod void ASI_MFM_CN_Payment_PDF_Controller_TEST(){
        //Assume "dummy for test class" payment & payment line item exists for test class
        //ASI_MFM_Payment__c Payment = [Select id from ASI_MFM_Payment__c where ASI_MFM_remarks__c = 'dummy for test class' limit 1];
        //ASI_MFM_Payment_Line_Item__c PayItem = [Select id from ASI_MFM_Payment_Line_Item__c where recordtypeid = :Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item') limit 1];
        Id rtid = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier');//ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
        Account supplier = new Account(Name='TestAcc', recordTypeId=rtid , ASI_MFM_Customer_Supplier_Number__c='123', ASI_MFM_Customer_Supplier_Name__c='SupplierName');
        insert supplier;
        ASI_MFM_Payment__c Payment = new ASI_MFM_Payment__c(Id=ASI_MFM_Function.CreateFakeId(ASI_MFM_Payment__c.SObjectType, 1), ASI_MFM_Supplier_Name__c=supplier.Id);
        List<ASI_MFM_Payment_Line_Item__c> lineItems = new List<ASI_MFM_Payment_Line_Item__c>();
        lineItems.add(new ASI_MFM_Payment_Line_Item__c(Id=ASI_MFM_Function.CreateFakeId(ASI_MFM_Payment_Line_Item__c.SObjectType, 1), ASI_MFM_Payment__c=Payment.Id));
        
        ASI_MFM_CN_Payment_PDF_Controller con = new ASI_MFM_CN_Payment_PDF_Controller();
        con.Payment = payment;
        con.PaymentLineItems = lineItems;
        con.init();
        
        Payment.ASI_MFM_Insurance_Percentage__c = 'IS02 (2%)';
        Payment.ASI_MFM_WT_Percentage__c = 'WT10 (10%)';
        Payment.ASI_MFM_VAT_Percentage__c = 'TW05 (5%)';
        //Payment.
        
        //update payment;
        con.init();
        
        
        ASI_MFM_CN_Payment_PDF_Controller.Payment_WrapperClass wrapper = new ASI_MFM_CN_Payment_PDF_Controller.Payment_WrapperClass(new ASI_MFM_Plan__c());
        wrapper.plan = wrapper.plan;
        wrapper.poline_firstItem= wrapper.poline_firstItem;
        wrapper.paylineList = wrapper.paylineList;
        wrapper.PoList = wrapper.PoList;
        wrapper.totalPoAmount = wrapper.totalPoAmount;
        wrapper.totalActualAmount = wrapper.totalActualAmount;

        ASI_MFM_CN_Payment_PDF_Controller.getApprDetailInfo(userInfo.getUserId());
        
        ASI_MFM_CN_Payment_PDF_Controller.ASI_ApprHist_LineItem hist = new ASI_MFM_CN_Payment_PDF_Controller.ASI_ApprHist_LineItem();
        hist.id = hist.id;
        hist.StepStatus = hist.StepStatus;
        hist.Comments = hist.Comments;
        hist.CreatedDate = hist.CreatedDate;
        hist.CreatedDateString = hist.CreatedDateString;
        hist.oriActorId = hist.oriActorId;
        hist.oriActorName = hist.oriActorName;
        hist.oriActorTitle = hist.oriActorTitle;
        hist.oriActorDepartment = hist.oriActorDepartment;
        hist.actActorId = hist.actActorId;
        hist.actActorName = hist.actActorName;
        hist.actActorTitle = hist.actActorTitle;
        hist.actActorDepartment = hist.actActorDepartment;
        
    }
    
    static testmethod void ASI_MFM_CN_InputPaymentItemsController_TEST(){
        //Assume "dummy for test class" payment & payment line item exists for test class
        //Test.setCurrentPage(Page.ASI_MFM_CN_InputPaymentItemsPage);
        //ASI_MFM_Payment__c Payment = [Select id from ASI_MFM_Payment__c where ASI_MFM_remarks__c = 'dummy for test class' limit 1];
        ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(Id=ASI_MFM_Function.CreateFakeId(ASI_MFM_Payment__c.SObjectType, 1));
        
        ASI_MFM_CN_InputPaymentItemsController con = new ASI_MFM_CN_InputPaymentItemsController(new apexPages.StandardSetController(new list<ASI_MFM_Payment_Line_Item__c>()));
        con.init(payment);
        con.mcau_initPageBlockActionButtonList();
        con.mcau_triggerPageBlockAction(new ASI_MFM_MassCreateAndUpdateController(),'');
        con.mcau_triggerActionForSObject(new ASI_MFM_MassCreateAndUpdateController(),'remove_new',new ASI_MFM_Payment_Line_Item__c());
        
        con.setComponentController('massCreateAndUpdate', new ASI_MFM_MassCreateAndUpdateController());
        con.sobjst_triggerActionForSObject(new ASI_MFM_SFObjSelectTableController(),'add',new ASI_MFM_PO_Line_Item__c());
        con.sobjst_initActionButtonStageMap();
        con.sobjst_initActionButtonList();
        con.getComponentController();
        ASI_MFM_ComponentInterface s;
        con.setComponentController(s);
        con.setComponentController('String',s);
        con.po_filter = 'test po';
        con.supplier_filter = 'test supplier';
        con.plan_filter = 'test plan';
        con.po_obj_filter.ASI_MFM_Currency__c = 'RMB';
        //con.sobjst_triggerActionForSObject(new ASI_MFM_SFObjSelectTableController(), 'add', new ASI_MFM_PO_Line_Item__c());
        //con.sobjst_triggerActionForSObject(new ASI_MFM_SFObjSelectTableController(), 'else', new ASI_MFM_PO_Line_Item__c());
        con.FilterPOItems();
    }
        
    static testmethod void ASI_MFM_SelectPaymentPrefixController_TEST(){

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
  /*      user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];    */
   /*     list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'NTMK';
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'NTMK';
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        update users;

        users.clear();
        
        User user3 = ASI_MFM_Function.getSystemAdminUser();
        user3.ASI_MFM_Team__c = 'NTMK';
        user3.ASI_MFM_Country__c = null;
        user3.managerid = user2.id;
        users.add(user3);*/

        


        
        String strRTID;

        list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            
        system.runAs(user1) {

            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Payment',ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix');//ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', recordTypeId=strRTID,ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            
            insert prefixs;
        }
        
        test.startTest();
        
        system.runAs(user1) {
                
            //ASI_MFM_SelectPaymentPrefixController con = new ASI_MFM_SelectPaymentPrefixController(new apexPages.Standardcontroller([Select id from ASI_MFM_Payment__c where ASI_MFM_remarks__c = 'dummy for test class' limit 1]));
            ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment'));       
            ASI_MFM_SelectPaymentPrefixController con = new ASI_MFM_SelectPaymentPrefixController(new apexPages.Standardcontroller(py));
            
            ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment'));
            //ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='PO',Plan_Type__c='Allowance & Discount Spending Form'
            //    ,ASI_MFM_Fiscal_year__c='FY1314');
            //    insert prefix1 ;
            //con.selected_prefix = String.valueof(prefix1.id);
            con.getPrefixes();
            con.proceed();
        }
        
        system.runAs(user1) {
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;
            
            ASI_MFM_Payment__c py = new ASI_MFM_Payment__c();       
            ASI_MFM_SelectPaymentPrefixController con = new ASI_MFM_SelectPaymentPrefixController(new apexPages.Standardcontroller(py));
            ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment'));
            con.getPrefixes();
            con.proceed();
        }
        

        system.runAs(user1) {
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;
            
            ASI_MFM_Payment__c py = new ASI_MFM_Payment__c();       
            ASI_MFM_SelectPaymentPrefixController con = new ASI_MFM_SelectPaymentPrefixController(new apexPages.Standardcontroller(py));
            ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment'));
            con.getPrefixes();
            con.proceed();
        }

            
        test.stopTest();
    }
    
    public static testmethod void ASI_MFM_CN_POReceiptItem_TriggerClass_TEST(){
        
        List<User> lstUsr = new List<User>();
        User User11 = new User(companyName = 'Pernod Ricard China', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test9999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test1000' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User10 = new User(companyName = 'Pernod Ricard China', managerid = User11.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User9 = new User(companyName = 'Pernod Ricard China', managerid = User10.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test991',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test991', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test991' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
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
        lstUsr.add(User10);
        lstUsr.add(User11);
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
                      OR id = : user10.id
                      OR id = : User11.id
                      LIMIT 10]){
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
                          }else if(u.id == user10.Id){
                              user10 = u;
                          }else if(u.id == user11.Id){
                              user11 = u;
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
        user9.ManagerId = user10.id;
        user10.ManagerId = user11.id;
        
        ul.add(user2);
        ul.add(user1);
        ul.add(user3);
        ul.add(user4);
        ul.add(user5);
        ul.add(user6);
        ul.add(user7);
        ul.add(user8);
        ul.add(user9);
        ul.add(user10);
        
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
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(OwnerID = user2.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'submitted', ASI_MFM_Prefix__c=LPrefix[2].Id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=user2.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_BU__c=bu.id, ASI_MFM_Currency__c='RMB', ASI_MFM_Sys_Local_Currency__c = 'RMB');
            insert payment;
            
            //create payment line
			strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment_Line_Item__c','ASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[0].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli1);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[1].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            
            insert palList;
            
            ASI_MFM_CN_InputPaymentItemsController con = new ASI_MFM_CN_InputPaymentItemsController(new apexPages.StandardSetController(new list<ASI_MFM_Payment_Line_Item__c>()));
            con.po_filter = 'test po';
            con.supplier_filter = 'test supplier';
            con.plan_filter = 'test plan';
            payment.ASI_MFM_Supplier_Name__c = LAcct[1].id;
            payment.ASI_MFM_BU__c = bu.id;
            con.init(payment);
            
            payment.ASI_MFM_Status__c = 'draft';
            payment.ASI_MFM_Currency__c = 'USD';
            update payment;
            
            /*payment.ASI_MFM_Budget_Owner__c = User8.id;
            
            List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
            pList.add(payment);
            
            for(ASI_MFM_Payment_Line_Item__c pl : [SELECT id, ASI_MFM_Payment__r.OwnerId, ASI_MFM_Payment__r.ASI_MFM_Budget_Owner__c, ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__c FROM ASI_MFM_Payment_Line_Item__c WHERE ID IN : palList]){
                if(pl.id == payli1.id)
                    payli1 = pl;
                else
                    payli2 = pl;
            }
            List<ASI_MFM_Payment_Line_Item__c> plList = new List<ASI_MFM_Payment_Line_Item__c>();
            
            ASI_MFM_CN_Payment_TriggerHelperClass.teamMemberSharing(pList);
            ASI_MFM_CN_Payment_TriggerHelperClass.BudgetOwnerValidationCheck(plList, plList);*/
            
            delete payment;
            
            Test.stopTest();
        }
    }
    
    public static testmethod void ASI_MFM_CN_Payment_TriggerClass_TEST5(){
        
        List<User> lstUsr = new List<User>();
        User User11 = new User(companyName = 'Pernod Ricard China', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test9999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test1000' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User10 = new User(companyName = 'Pernod Ricard China', managerid = User11.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User9 = new User(companyName = 'Pernod Ricard China', managerid = User10.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test991',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test991', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test991' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
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
        lstUsr.add(User10);
        lstUsr.add(User11);
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
                      OR id = : user10.id
                      OR id = : User11.id
                      LIMIT 10]){
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
                          }else if(u.id == user10.Id){
                              user10 = u;
                          }else if(u.id == user11.Id){
                              user11 = u;
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
        user9.ManagerId = user10.id;
        user10.ManagerId = user11.id;
        
        ul.add(user2);
        ul.add(user1);
        ul.add(user3);
        ul.add(user4);
        ul.add(user5);
        ul.add(user6);
        ul.add(user7);
        ul.add(user8);
        ul.add(user9);
        ul.add(user10);
        
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
            
            
            List<ASI_MFM_Dynamic_Approval_Route__c> LTDyRoute = new List<ASI_MFM_Dynamic_Approval_Route__c>();
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user1.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user2.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user3.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user4.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user5.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user6.id, ASI_MFM_End_of_1st_Route__c=true));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user7.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user8.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user9.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user10.id));
            insert LTDyRoute;
            
            
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
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_Payment_Amount__c =10000,OwnerID = user2.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'submitted', ASI_MFM_Prefix__c=LPrefix[2].Id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=user2.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_BU__c=bu.id, ASI_MFM_Currency__c='RMB', ASI_MFM_Sys_Local_Currency__c = 'RMB');
            insert payment;
            
            //create payment line
			strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment_Line_Item__c','ASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[0].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli1);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[1].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            
            insert palList;
            
            ASI_MFM_CN_InputPaymentItemsController con = new ASI_MFM_CN_InputPaymentItemsController(new apexPages.StandardSetController(new list<ASI_MFM_Payment_Line_Item__c>()));
            con.po_filter = 'test po';
            con.supplier_filter = 'test supplier';
            con.plan_filter = 'test plan';
            payment.ASI_MFM_Supplier_Name__c = LAcct[1].id;
            payment.ASI_MFM_BU__c = bu.id;
            con.init(payment);
            
            payment.ASI_MFM_Status__c = 'draft';
            payment.ASI_MFM_Currency__c = 'USD';
            update payment;
            
            /*payment.ASI_MFM_Budget_Owner__c = User8.id;
            
            List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
            pList.add(payment);
            
            for(ASI_MFM_Payment_Line_Item__c pl : [SELECT id, ASI_MFM_Payment__r.OwnerId, ASI_MFM_Payment__r.ASI_MFM_Budget_Owner__c, ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__c FROM ASI_MFM_Payment_Line_Item__c WHERE ID IN : palList]){
                if(pl.id == payli1.id)
                    payli1 = pl;
                else
                    payli2 = pl;
            }
            List<ASI_MFM_Payment_Line_Item__c> plList = new List<ASI_MFM_Payment_Line_Item__c>();
            
            ASI_MFM_CN_Payment_TriggerHelperClass.teamMemberSharing(pList);
            ASI_MFM_CN_Payment_TriggerHelperClass.BudgetOwnerValidationCheck(plList, plList);*/
            
            delete payment;
            
            Test.stopTest();
        }
    }
    
    public static testmethod void ASI_MFM_CN_Payment_TriggerClass_TEST4(){
        
        List<User> lstUsr = new List<User>();
        User User11 = new User(companyName = 'Pernod Ricard China', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test9999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test1000' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User10 = new User(companyName = 'Pernod Ricard China', managerid = User11.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User9 = new User(companyName = 'Pernod Ricard China', managerid = User10.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test991',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test991', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test991' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
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
        lstUsr.add(User10);
        lstUsr.add(User11);
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
                      OR id = : user10.id
                      OR id = : User11.id
                      LIMIT 10]){
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
                          }else if(u.id == user10.Id){
                              user10 = u;
                          }else if(u.id == user11.Id){
                              user11 = u;
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
        user9.ManagerId = user10.id;
        user10.ManagerId = user11.id;
        
        ul.add(user2);
        ul.add(user1);
        ul.add(user3);
        ul.add(user4);
        ul.add(user5);
        ul.add(user6);
        ul.add(user7);
        ul.add(user8);
        ul.add(user9);
        ul.add(user10);
        
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
            
            
            List<ASI_MFM_Dynamic_Approval_Route__c> LTDyRoute = new List<ASI_MFM_Dynamic_Approval_Route__c>();
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user1.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user2.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user3.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user4.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user5.id, ASI_MFM_End_of_1st_Route__c=true));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user6.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user7.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user8.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user9.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user10.id));
            insert LTDyRoute;
            
            
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
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_Payment_Amount__c =10000,OwnerID = user2.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'submitted', ASI_MFM_Prefix__c=LPrefix[2].Id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=user2.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_BU__c=bu.id, ASI_MFM_Currency__c='RMB', ASI_MFM_Sys_Local_Currency__c = 'RMB');
            insert payment;
            
            //create payment line
			strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment_Line_Item__c','ASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[0].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli1);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[1].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            
            insert palList;
            
            ASI_MFM_CN_InputPaymentItemsController con = new ASI_MFM_CN_InputPaymentItemsController(new apexPages.StandardSetController(new list<ASI_MFM_Payment_Line_Item__c>()));
            con.po_filter = 'test po';
            con.supplier_filter = 'test supplier';
            con.plan_filter = 'test plan';
            payment.ASI_MFM_Supplier_Name__c = LAcct[1].id;
            payment.ASI_MFM_BU__c = bu.id;
            con.init(payment);
            
            payment.ASI_MFM_Status__c = 'draft';
            payment.ASI_MFM_Currency__c = 'USD';
            update payment;
            
            /*payment.ASI_MFM_Budget_Owner__c = User8.id;
            
            List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
            pList.add(payment);
            
            for(ASI_MFM_Payment_Line_Item__c pl : [SELECT id, ASI_MFM_Payment__r.OwnerId, ASI_MFM_Payment__r.ASI_MFM_Budget_Owner__c, ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__c FROM ASI_MFM_Payment_Line_Item__c WHERE ID IN : palList]){
                if(pl.id == payli1.id)
                    payli1 = pl;
                else
                    payli2 = pl;
            }
            List<ASI_MFM_Payment_Line_Item__c> plList = new List<ASI_MFM_Payment_Line_Item__c>();
            
            ASI_MFM_CN_Payment_TriggerHelperClass.teamMemberSharing(pList);
            ASI_MFM_CN_Payment_TriggerHelperClass.BudgetOwnerValidationCheck(plList, plList);*/
            
            delete payment;
            
            Test.stopTest();
        }
    }
    
    public static testmethod void ASI_MFM_CN_Payment_TriggerClass_TEST3(){
        
        List<User> lstUsr = new List<User>();
        User User11 = new User(companyName = 'Pernod Ricard China', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test9999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test1000' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User10 = new User(companyName = 'Pernod Ricard China', managerid = User11.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User9 = new User(companyName = 'Pernod Ricard China', managerid = User10.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test991',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test991', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test991' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
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
        lstUsr.add(User10);
        lstUsr.add(User11);
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
                      OR id = : user10.id
                      OR id = : User11.id
                      LIMIT 10]){
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
                          }else if(u.id == user10.Id){
                              user10 = u;
                          }else if(u.id == user11.Id){
                              user11 = u;
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
        user9.ManagerId = user10.id;
        user10.ManagerId = user11.id;
        
        ul.add(user2);
        ul.add(user1);
        ul.add(user3);
        ul.add(user4);
        ul.add(user5);
        ul.add(user6);
        ul.add(user7);
        ul.add(user8);
        ul.add(user9);
        ul.add(user10);
        
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
            
            
            List<ASI_MFM_Dynamic_Approval_Route__c> LTDyRoute = new List<ASI_MFM_Dynamic_Approval_Route__c>();
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user1.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user2.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user3.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user4.id, ASI_MFM_End_of_1st_Route__c=true));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user5.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user6.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user7.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user8.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user9.id));
            //LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user10.id));
            insert LTDyRoute;
            
            
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
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_Payment_Amount__c =10000,OwnerID = user2.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'submitted', ASI_MFM_Prefix__c=LPrefix[2].Id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=user2.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_BU__c=bu.id, ASI_MFM_Currency__c='RMB', ASI_MFM_Sys_Local_Currency__c = 'RMB');
            insert payment;
            
            //create payment line
			strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment_Line_Item__c','ASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[0].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli1);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[1].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            
            insert palList;
            
            ASI_MFM_CN_InputPaymentItemsController con = new ASI_MFM_CN_InputPaymentItemsController(new apexPages.StandardSetController(new list<ASI_MFM_Payment_Line_Item__c>()));
            con.po_filter = 'test po';
            con.supplier_filter = 'test supplier';
            con.plan_filter = 'test plan';
            payment.ASI_MFM_Supplier_Name__c = LAcct[1].id;
            payment.ASI_MFM_BU__c = bu.id;
            con.init(payment);
            
            payment.ASI_MFM_Status__c = 'draft';
            payment.ASI_MFM_Currency__c = 'USD';
            update payment;
            
            /*payment.ASI_MFM_Budget_Owner__c = User8.id;
            
            List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
            pList.add(payment);
            
            for(ASI_MFM_Payment_Line_Item__c pl : [SELECT id, ASI_MFM_Payment__r.OwnerId, ASI_MFM_Payment__r.ASI_MFM_Budget_Owner__c, ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__c FROM ASI_MFM_Payment_Line_Item__c WHERE ID IN : palList]){
                if(pl.id == payli1.id)
                    payli1 = pl;
                else
                    payli2 = pl;
            }
            List<ASI_MFM_Payment_Line_Item__c> plList = new List<ASI_MFM_Payment_Line_Item__c>();
            
            ASI_MFM_CN_Payment_TriggerHelperClass.teamMemberSharing(pList);
            ASI_MFM_CN_Payment_TriggerHelperClass.BudgetOwnerValidationCheck(plList, plList);*/
            
            delete payment;
            
            Test.stopTest();
        }
    }
    
    public static testmethod void ASI_MFM_CN_Payment_TriggerClass_TEST2(){
        
        List<User> lstUsr = new List<User>();
        User User11 = new User(companyName = 'Pernod Ricard China', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test9999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test1000' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User10 = new User(companyName = 'Pernod Ricard China', managerid = User11.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User9 = new User(companyName = 'Pernod Ricard China', managerid = User10.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test991',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test991', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test991' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User8 = new User(companyName = 'Pernod Ricard China', managerid = User9.id, ASI_MFM_Team__c = 'Testing', ASI_MFM_Country__c ='CN', alias = 'test992',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test992', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test992' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User7 = new User(companyName = 'Pernod Ricard China', managerid = User8.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test993',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test993', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test993' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User6 = new User(companyName = 'Pernod Ricard China', managerid = User7.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test994',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test994', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test994' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User5 = new User(companyName = 'Pernod Ricard China', managerid = User6.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test995',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test995', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test995' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User4 = new User(companyName = 'Pernod Ricard China', managerid = User5.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test996',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test996', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test996' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User3 = new User(companyName = 'Pernod Ricard China', managerid = User4.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test997',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test997', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test997' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User1 = new User(companyName = 'Pernod Ricard China CN', managerid = User3.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test998',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test998', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test998' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(companyName = 'Pernod Ricard China CN', BypassTriggers__c = 'ASI_MFM_CN_PO_TriggerClass', managerid = User1.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'tes999',ASI_MFM_Bypass_Callouts__c = true, email='test999' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        
        lstUsr.add(user3);
        lstUsr.add(user4);
        lstUsr.add(user5);
        lstUsr.add(user6);
        lstUsr.add(user7);
        lstUsr.add(user8);
        lstUsr.add(user9);
        lstUsr.add(user2);
        lstUsr.add(user1);
        lstUsr.add(User10);
        lstUsr.add(User11);
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
                      OR id = : user10.id
                      OR id = : User11.id
                      LIMIT 10]){
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
                          }else if(u.id == user10.Id){
                              user10 = u;
                          }else if(u.id == user11.Id){
                              user11 = u;
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
        user9.ManagerId = user10.id;
        user10.ManagerId = user11.id;
        
        ul.add(user2);
        ul.add(user1);
        ul.add(user3);
        ul.add(user4);
        ul.add(user5);
        ul.add(user6);
        ul.add(user7);
        ul.add(user8);
        ul.add(user9);
        ul.add(user10);
        
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
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_Payment_Amount__c =10000,OwnerID = user2.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'submitted', ASI_MFM_Prefix__c=LPrefix[2].Id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=user2.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_BU__c=bu.id, ASI_MFM_Currency__c='RMB', ASI_MFM_Sys_Local_Currency__c = 'RMB');
            insert payment;
            
            //create payment line
			strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment_Line_Item__c','ASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[0].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli1);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[1].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            
            insert palList;
            
            ASI_MFM_CN_InputPaymentItemsController con = new ASI_MFM_CN_InputPaymentItemsController(new apexPages.StandardSetController(new list<ASI_MFM_Payment_Line_Item__c>()));
            con.po_filter = 'test po';
            con.supplier_filter = 'test supplier';
            con.plan_filter = 'test plan';
            payment.ASI_MFM_Supplier_Name__c = LAcct[1].id;
            payment.ASI_MFM_BU__c = bu.id;
            con.init(payment);
            
            payment.ASI_MFM_Status__c = 'draft';
            payment.ASI_MFM_Currency__c = 'USD';
            update payment;
            
            /*payment.ASI_MFM_Budget_Owner__c = User8.id;
            
            List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
            pList.add(payment);
            
            for(ASI_MFM_Payment_Line_Item__c pl : [SELECT id, ASI_MFM_Payment__r.OwnerId, ASI_MFM_Payment__r.ASI_MFM_Budget_Owner__c, ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__c FROM ASI_MFM_Payment_Line_Item__c WHERE ID IN : palList]){
                if(pl.id == payli1.id)
                    payli1 = pl;
                else
                    payli2 = pl;
            }
            List<ASI_MFM_Payment_Line_Item__c> plList = new List<ASI_MFM_Payment_Line_Item__c>();
            
            ASI_MFM_CN_Payment_TriggerHelperClass.teamMemberSharing(pList);
            ASI_MFM_CN_Payment_TriggerHelperClass.BudgetOwnerValidationCheck(plList, plList);*/
            
            delete payment;
            
            Test.stopTest();
        }
    }
    
    public static testmethod void ASI_MFM_CN_Payment_TriggerClass_TEST(){
        
        List<User> lstUsr = new List<User>();
        User User11 = new User(companyName = 'Pernod Ricard China', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test9999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test1000' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User10 = new User(companyName = 'Pernod Ricard China', managerid = User11.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test999',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test999', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test999' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User9 = new User(companyName = 'Pernod Ricard China', managerid = User10.id, ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test991',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test991', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test991' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
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
        lstUsr.add(User10);
        lstUsr.add(User11);
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
                      OR id = : user10.id
                      OR id = : User11.id
                      LIMIT 10]){
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
                          }else if(u.id == user10.Id){
                              user10 = u;
                          }else if(u.id == user11.Id){
                              user11 = u;
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
        user9.ManagerId = user10.id;
        user10.ManagerId = user11.id;
        
        ul.add(user2);
        ul.add(user1);
        ul.add(user3);
        ul.add(user4);
        ul.add(user5);
        ul.add(user6);
        ul.add(user7);
        ul.add(user8);
        ul.add(user9);
        ul.add(user10);
        
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
            
            
            List<ASI_MFM_Dynamic_Approval_Route__c> LTDyRoute = new List<ASI_MFM_Dynamic_Approval_Route__c>();
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user1.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user2.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user3.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user4.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user5.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user6.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user7.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user8.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user9.id));
            LTDyRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_Type__c = 'Payment', ASI_MFM_Approval_Limit__c=1000, ASI_MFM_User__c=user10.id));
            insert LTDyRoute;
            
            
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
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_Payment_Amount__c =10000,OwnerID = user2.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'submitted', ASI_MFM_Prefix__c=LPrefix[2].Id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=user2.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_BU__c=bu.id, ASI_MFM_Currency__c='RMB', ASI_MFM_Sys_Local_Currency__c = 'RMB');
            insert payment;
            
            //create payment line
			strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment_Line_Item__c','ASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[0].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli1);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[1].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            
            insert palList;
            
            ASI_MFM_CN_InputPaymentItemsController con = new ASI_MFM_CN_InputPaymentItemsController(new apexPages.StandardSetController(new list<ASI_MFM_Payment_Line_Item__c>()));
            con.po_filter = 'test po';
            con.supplier_filter = 'test supplier';
            con.plan_filter = 'test plan';
            payment.ASI_MFM_Supplier_Name__c = LAcct[1].id;
            payment.ASI_MFM_BU__c = bu.id;
            con.init(payment);
            
            payment.ASI_MFM_Status__c = 'draft';
            payment.ASI_MFM_Currency__c = 'USD';
            update payment;
            
            /*payment.ASI_MFM_Budget_Owner__c = User8.id;
            
            List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
            pList.add(payment);
            
            for(ASI_MFM_Payment_Line_Item__c pl : [SELECT id, ASI_MFM_Payment__r.OwnerId, ASI_MFM_Payment__r.ASI_MFM_Budget_Owner__c, ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__c FROM ASI_MFM_Payment_Line_Item__c WHERE ID IN : palList]){
                if(pl.id == payli1.id)
                    payli1 = pl;
                else
                    payli2 = pl;
            }
            List<ASI_MFM_Payment_Line_Item__c> plList = new List<ASI_MFM_Payment_Line_Item__c>();
            
            ASI_MFM_CN_Payment_TriggerHelperClass.teamMemberSharing(pList);
            ASI_MFM_CN_Payment_TriggerHelperClass.BudgetOwnerValidationCheck(plList, plList);*/
            
            delete payment;
            
            Test.stopTest();
        }
    }
    
    public static testmethod void ASI_MFM_CN_POReceiptItem_TriggerClass_TEST4(){
        
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
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[0].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli1);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[1].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            
            insert palList;
            
            //20180713 Introv
            delete palList;
            
            Test.stopTest();
        }
    }
    
    public static testmethod void ASI_MFM_CN_PaymentLineItem_TriggerClass_TEST(){
        
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
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_Pre_payment__c=true, OwnerID = user8.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'submitted', ASI_MFM_Prefix__c=LPrefix[2].Id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=user2.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_BU__c=bu.id, ASI_MFM_Currency__c='RMB', ASI_MFM_Sys_Local_Currency__c = 'RMB');
            insert payment;
            
            //create payment line
			strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');//ASI_MFM_Function.checkRecordType('ASI_MFM_Payment_Line_Item__c','ASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_CN_Invoice_Amount__c=10,ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[0].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli1);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = sb.id, ASI_MFM_Payment_Amount__c = 10, ASI_MFM_Paid_Amount_in_PO_Currency__c = 10, ASI_MFM_Tax_Amount__c = 10, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=polList[1].id, ASI_MFM_Payment__c = payment.id);
            palList.add(payli2);
            
            insert palList;
            
            //20180713 Introv
            delete palList;
            
            Test.stopTest();
        }
    }
    
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
                                                                                   ASI_MFM_Paid_Amount_in_PO_Currency__c = 10,
                                                                                   ASI_MFM_Tax_Amount__c = 10, 
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