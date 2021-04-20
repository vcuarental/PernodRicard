/*********************************************************************************
 * Name:ASI_MFM_SG_PaymentPDF_Test
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/06/2018       Wilken              [WL 1.0] Add coverage for payment reject case
*********************************************************************************/
@isTest (seealldata=true)
    private class ASI_MFM_SG_PaymentPDF_Test {
        
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
        
        
        static testMethod void ASI_MFM_PDFTestPayment4() {
            User thisUser = [SELECT ID, ASI_MFM_Country__c, userRole.Id, userRole.developerName FROM user WHERE ID = :userinfo.getUserID()];

      UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
      insert r;

      //New Test User
      Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
      User newUser1 = new User(profileId = p.Id, username = 'newUser1@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user', UserRoleId = r.Id);
      User newUser2 = new User(profileId = p.Id, username = 'newUser2@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user', UserRoleId = r.Id);
      User newUser3 = new User(profileId = p.Id, username = 'newUser3@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
      User newUser4 = new User(profileId = p.Id, username = 'newUser4@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
      User newUser5 = new User(profileId = p.Id, username = 'newUser5@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
      User newUser6 = new User(profileId = p.Id, username = 'newUser6@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
      User newUser7 = new User(profileId = p.Id, username = 'newUser7@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
      User newUser8 = new User(profileId = p.Id, username = 'newUser8@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
      User newUser9 = new User(profileId = p.Id, username = 'newUser9@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
      User newUser10 = new User(profileId = p.Id, username = 'newUser10@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        
      List<User> newUserList = new List<User>();
      newUserList.add(newUser1);
      newUserList.add(newUser2);
      newUserList.add(newUser3);
      newUserList.add(newUser4);
      newUserList.add(newUser5);
      newUserList.add(newUser6);
      newUserList.add(newUser7);
      newUserList.add(newUser8);
      newUserList.add(newUser9);
      newUserList.add(newUser10);
      
      insert newUserList;
      
      System.runAs(newUser1){    
        //Prefix
        List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(  name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), 
                                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'),
                                ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        PrefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        PrefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        PrefixList.add(pxa);
        insert PrefixList; 
        
        List<ASI_MFM_Role_Prefix_Relationship__c> RolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c = 'MyCustomRole');
        RolePrefixList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c = 'MyCustomRole');
        RolePrefixList.add(pro); 
        
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pra2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = r.DeveloperName);
        RolePrefixList.add(pra);
        RolePrefixList.add(pra2);
        insert RolePrefixList;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(Name ='Test', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_SG_Brand'));
        insert brand;
        
        ASI_MFM_Sub_brand__c subbrand = new ASI_MFM_Sub_brand__c(Name = 'Test', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'),
                                    ASI_MFM_Brand__c = brand.Id);
        insert subbrand;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'),
                              ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), 
                              ASI_MFM_End_Date__c=date.today().addMonths(1),
                              ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', 
                              ASI_MFM_Status__c = 'Final'
                            );
        insert p1;
        
        
        Account acc3 = new Account(    recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),
                        Name='Name3'); // ASI_CRM_SG_Supplier          
        insert acc3;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'),
                            ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                            ASI_MFM_Currency__c='SGD');// ASI_MFM_Supplier_Name__c = acc1.id 
        insert po;
        
        //------------------------------------------Test start ---------------------------------------------
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'),
                                      ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_List_Item_Description__c='testDescription', 
                                      ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Sub_brand_Code__c = subbrand.Id); //ASI_MFM_Customer_Name__c=acc2.id, 
        insert poi;
        
        System.debug(Limits.getDMLRows());
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=pxa.id); // Note :use Payment Prefix
        insert rtm;
      
        // ASI MFM Route Rule Details Set Approver 
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser1.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser2.id, ASI_MFM_Minimum_Amount__c=1, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser3.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=2));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser4.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=3));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser5.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=4));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser6.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=5));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser7.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=6));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser8.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=7));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser9.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=8));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser10.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=9));        
        insert rrdlist;
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(
                          recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'),                          
                          ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Send_Approval_Email__c=true,
                          ASI_MFM_Status__c='Draft',ASI_MFM_Supplier_Name__c = acc3.id);  //ASI_MFM_Payee__c ,ASI_MFM_Sys_Approver_1__c=u2.id     
        insert py;
        System.debug('After insert payment ' + Limits.getDMLRows());
        
        py.OwnerId = newUser2.Id;
        update py;
        
        Test.startTest(); 
        System.debug('Start Test DML Limit ' + Limits.getDMLRows());
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(
                                    recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'),  
                                    ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Payment__c=py.id,ASI_MFM_Invoice_Number__c = '123456');// 
        insert pyi;
        //----------------------------Submit ---- Start
        System.debug('After insert payment line ' + Limits.getDMLRows());        // Create an approval request for the account
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(py.id);
        req1.setSubmitterId(thisUser.Id); 
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        //List<Id> newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');//     Reject
        req2.setNextApproverIds(new Id[] {thisUser.id});
        // Use the ID from the newly created item to specify the item to be worked
        //req2.setWorkitemId(newWorkItemIds.get(0));
        
        if(result.getNewWorkitemIds().size()>0){
          req2.setWorkitemId(result.getNewWorkitemIds().get(0));
          Approval.process(req2);
        }
        
        // Submit the request for approval--End
        PageReference pageRef = Page.ASI_MFM_SG_Payment_PDF_Page;
        pageRef.getParameters().put('Id', py.Id);
        Test.setCurrentPage(pageRef);

        ASI_MFM_SG_Payment_PDF_PageController ext = new ASI_MFM_SG_Payment_PDF_PageController(new ApexPages.StandardController(py));
        ext.paymentID= py.Id;
        ext.dummyVar = false;
        ext.init();
        
        ASI_MFM_SG_Payment_PDF_PageController.getApprDetailInfo(userInfo.getUserId());
        ASI_MFM_SG_Payment_PDF_PageController.ASI_ApprHist_LineItem hist = new ASI_MFM_SG_Payment_PDF_PageController.ASI_ApprHist_LineItem();
        hist.id = hist.id;//'Test';
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
        ASI_MFM_ApprovalHistoryHelper histHelper = new ASI_MFM_ApprovalHistoryHelper ('ASI_MFM_Payment__c', py.id);
        
        test.stopTest(); 
      }
        }
        
        static testMethod void ASI_MFM_PDFTestPayment5() { // Test ASI_MFM_Approval_History_ComController
            User thisUser = [SELECT ID, ASI_MFM_Country__c, userRole.developerName FROM user WHERE ID = :userinfo.getUserID()];
      
      //Prefix
      List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c>();
      ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(  name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), 
                              recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'),
                              ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
      PrefixList.add(px);
      ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
      PrefixList.add(pxo);
      ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
      PrefixList.add(pxa);
      insert PrefixList; 
      
      List<ASI_MFM_Role_Prefix_Relationship__c> RolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
      ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
      RolePrefixList.add(pr);
      ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
      RolePrefixList.add(pro); 
      ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
      RolePrefixList.add(pra);
      insert RolePrefixList;
                
      ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'),
                            ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), 
                            ASI_MFM_End_Date__c=date.today().addMonths(1),
                            ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', 
                            ASI_MFM_Status__c = 'Final'
                          );
      insert p1;
      
      
      Account acc3 = new Account(    recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),
                      Name='Name3'); // ASI_CRM_SG_Supplier          
      insert acc3;
      
      ASI_MFM_PO__c po = new ASI_MFM_PO__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'),
                          ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                          ASI_MFM_Currency__c='SGD');// ASI_MFM_Supplier_Name__c = acc1.id 
      insert po;
      
      //------------------------------------------Test start ---------------------------------------------
      
      ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'),
                                    ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_List_Item_Description__c='testDescription', 
                                    ASI_MFM_G_L_Date__c = Date.today()); //ASI_MFM_Customer_Name__c=acc2.id, 
      insert poi;
      
      System.debug(Limits.getDMLRows());
      
      ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
      insert rt;
      
      ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=pxa.id); // Note :use Payment Prefix
      insert rtm;
      
      // ASI MFM Route Rule Details Set Approver 
      List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=2));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=3));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=4));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=5));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=6));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=7));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=8));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=9));        
      insert rrdlist;
      
      ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'),                          
                        ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Send_Approval_Email__c=true,
                        ASI_MFM_Status__c='Draft',ASI_MFM_Supplier_Name__c = acc3.id);  //ASI_MFM_Payee__c ,ASI_MFM_Sys_Approver_1__c=u2.id     
      insert py;
      System.debug('After insert payment ' + Limits.getDMLRows());
      
      
      Test.startTest(); 
      System.debug('Start Test DML Limit ' + Limits.getDMLRows());
            
      
      ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'),
                                        ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Payment__c=py.id,ASI_MFM_Invoice_Number__c = '123456');// 
      insert pyi;
      //----------------------------Submit ---- Start
      System.debug(Limits.getDMLRows());        // Create an approval request for the account
      Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
      req1.setComments('Submitting request for approval.');
      req1.setObjectId(py.id);
      req1.setSubmitterId(thisUser.Id); 
      req1.setSkipEntryCriteria(true);
      Approval.ProcessResult result = Approval.process(req1);
      //List<Id> newWorkItemIds = result.getNewWorkitemIds();
      Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
      req2.setComments('Approving request.');
      req2.setAction('Approve');//     Reject
      req2.setNextApproverIds(new Id[] {thisUser.id});
      // Use the ID from the newly created item to specify the item to be worked
      //req2.setWorkitemId(newWorkItemIds.get(0));
      
      if(result.getNewWorkitemIds().size()>0){
        req2.setWorkitemId(result.getNewWorkitemIds().get(0));
        Approval.process(req2);
      }
      
      // Submit the request for approval--End      
      ASI_MFM_Approval_History_ComController ext = new ASI_MFM_Approval_History_ComController();
      ext.InputID= py.Id;
      ext.InputObject='ASI_MFM_Payment__c';
      ext.dummyVar = false;
      ext.init();
      
      ASI_MFM_Approval_History_ComController.getApprDetailInfo(userInfo.getUserId());
      ASI_MFM_Approval_History_ComController.ASI_ApprHist_LineItem hist = new ASI_MFM_Approval_History_ComController.ASI_ApprHist_LineItem();
      hist.id = hist.id;//'Test';
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
      ASI_MFM_ApprovalHistoryHelper histHelper = new ASI_MFM_ApprovalHistoryHelper ('ASI_MFM_Payment__c', py.id);
      
      test.stopTest(); 
        }
        
        static testMethod void test_PaymentTrigger() {
            User thisUser = [SELECT ID, ASI_MFM_Country__c, userRole.developerName FROM user WHERE ID = :userinfo.getUserID()];
      
      //Prefix
      List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c>();
      ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(  name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), 
                              recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'),
                              ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
      PrefixList.add(px);
      ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
      PrefixList.add(pxo);
      ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
      PrefixList.add(pxa);
      insert PrefixList; 
      
      List<ASI_MFM_Role_Prefix_Relationship__c> RolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
      ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
      RolePrefixList.add(pr);
      ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
      RolePrefixList.add(pro); 
      ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
      RolePrefixList.add(pra);
      insert RolePrefixList;
                
      ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'),
                            ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), 
                            ASI_MFM_End_Date__c=date.today().addMonths(1),
                            ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', 
                            ASI_MFM_Status__c = 'Final'
                          );
      insert p1;      
      
      Account acc3 = new Account(    recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),
                      Name='Name3'); // ASI_CRM_SG_Supplier          
      insert acc3;
      
      ASI_MFM_PO__c po = new ASI_MFM_PO__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'),
                          ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                          ASI_MFM_Currency__c='SGD');// ASI_MFM_Supplier_Name__c = acc1.id 
      insert po;
      
      ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'),
                                    ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_List_Item_Description__c='testDescription', 
                                    ASI_MFM_G_L_Date__c = Date.today()); //ASI_MFM_Customer_Name__c=acc2.id, 
      insert poi;
      
      System.debug(Limits.getDMLRows());
      
      ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
      insert rt;
      
      ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=pxa.id); // Note :use Payment Prefix
      insert rtm;
      
      // ASI MFM Route Rule Details Set Approver 
      List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=2));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=3));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=4));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=5));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=6));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=7));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=8));
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=9));        
      insert rrdlist;
      
      ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'),                          
                        ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Send_Approval_Email__c=true,
                        ASI_MFM_Status__c='Submitted',ASI_MFM_Supplier_Name__c = acc3.id);  //ASI_MFM_Payee__c ,ASI_MFM_Sys_Approver_1__c=u2.id     
      insert py;
      System.debug('After insert payment ' + Limits.getDMLRows());
      
      
      Test.startTest(); 
      System.debug('Start Test DML Limit ' + Limits.getDMLRows());
      
      ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(
                                  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'),
                                  ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Currency__c = 'SGD', ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), 
                                  ASI_MFM_Payment__c=py.id,ASI_MFM_Invoice_Number__c = '123456');// 
      insert pyi;
      
      System.debug('test_PaymentTrigger after insert payment line ' + Limits.getDMLRows());        // Create an approval request for the account                                               
      
      py.ASI_MFM_Status__c = 'Draft';
      update py;
      
        delete pyi;
        delete py;        
    
      test.stopTest(); 
        }
        
    /*[WL 1.0] BEGIN*/
    static testMethod void test_PaymentTrigger2() {
            User thisUser = [SELECT ID, ASI_MFM_Country__c, userRole.developerName FROM user WHERE ID = :userinfo.getUserID()];
      
      //Prefix
      List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c>();
      ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(  name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), 
                              recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'),
                              ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
      PrefixList.add(px);
      ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
      PrefixList.add(pxo);
      ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
      PrefixList.add(pxa);
      insert PrefixList; 
      
      List<ASI_MFM_Role_Prefix_Relationship__c> RolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
      ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
      RolePrefixList.add(pr);
      ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
      RolePrefixList.add(pro); 
      ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
      RolePrefixList.add(pra);
      insert RolePrefixList;
                
      ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'),
                            ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), 
                            ASI_MFM_End_Date__c=date.today().addMonths(1),
                            ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', 
                            ASI_MFM_Status__c = 'Final'
                          );
      insert p1;      
      
      Account acc3 = new Account(    recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),
                      Name='Name3'); // ASI_CRM_SG_Supplier          
      insert acc3;
      
      ASI_MFM_PO__c po = new ASI_MFM_PO__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'),
                          ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                          ASI_MFM_Currency__c='SGD');// ASI_MFM_Supplier_Name__c = acc1.id 
      insert po;
      
      ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'),
                                    ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_List_Item_Description__c='testDescription', 
                                    ASI_MFM_G_L_Date__c = Date.today()); //ASI_MFM_Customer_Name__c=acc2.id, 
      insert poi;
      
      System.debug(Limits.getDMLRows());
      
      ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
      insert rt;
      
      ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=pxa.id); // Note :use Payment Prefix
      insert rtm;
      
      // ASI MFM Route Rule Details Set Approver 
      List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
      rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=thisUser.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
      insert rrdlist;
      
      ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'),                          
                        ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Send_Approval_Email__c=true,
                        ASI_MFM_Status__c='Submitted',ASI_MFM_Supplier_Name__c = acc3.id);  //ASI_MFM_Payee__c ,ASI_MFM_Sys_Approver_1__c=u2.id     
      insert py;
      System.debug('After insert payment ' + Limits.getDMLRows());
      
      
      Test.startTest(); 
      System.debug('Start Test DML Limit ' + Limits.getDMLRows());
      
      ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(
                                  recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'),
                                  ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Currency__c = 'SGD', ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), 
                                  ASI_MFM_Payment__c=py.id,ASI_MFM_Invoice_Number__c = '123456');// 
      insert pyi;
      
      System.debug('After insert payment line: ' + Limits.getDMLRows());        // Create an approval request for the account                     
            
      py.ASI_MFM_Status__c = 'Final';
      update py;
      test.stopTest(); 
        }
    /*[WL 1.0] END*/    
    }