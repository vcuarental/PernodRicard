@isTest
public class ASI_MFM_CN_ScanToPay_Test {
    Static Testmethod Void scanToPayTest(){
        
        List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(BypassTriggers__c = 'ASI_MFM_CN_PO_TriggerClass', managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'Procurement', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                 FROM User
                 WHERE id =: user1.id 
                 LIMIT 1];
        user2 = [SELECT Id, BypassTriggers__c, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                 FROM User
                 WHERE id =: user2.id 
                 LIMIT 1];
        
        system.debug(user2);
        
        System.runas(user2){
            
            String strRTID;
            List<ASI_MFM_Prefix__c> LPrefix = new list<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                                              ,ASI_MFM_Fiscal_year__c='FY1516',ownerId = user2.id);
            LPrefix.add(prefix1);
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                         ASI_MFM_Fiscal_year__c='FY1516', ASI_MFM_Next_Number__c=86);
            system.debug('recordTypeId: ' + strRTID);
            LPrefix.add(px);
            ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='Payment', recordTypeId=strRTID,
                                                         ASI_MFM_Fiscal_year__c='FY1516', ASI_MFM_Next_Number__c=99);
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
            
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');                       
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            List<ASI_MFM_A_C_Code__c> lstACCode = new List<ASI_MFM_A_C_Code__c>();
            lstACCode.add(ac1); lstACCode.add(ac2);
            insert lstACCode;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            List<ASI_MFM_PP_Category_A_C__c> lstPPCat = new List<ASI_MFM_PP_Category_A_C__c>();
            lstPPCat.add(ppcac1); lstPPCat.add(ppcac2);
            insert lstPPCat; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1516', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=LPrefix[0].Id
                                                        ,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = Date.valueOf('2016-05-29'), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.valueOf('2016-01-29'), ASI_MFM_Budget_Owner__c=user2.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user2.id, ASI_MFM_Fiscal_year__c = 'FY1516');
            insert Plan1;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            List<ASI_MFM_Sub_brand__c> LSB = new List<ASI_MFM_Sub_brand__c>(); 
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
                                                                      ,recordTypeId=strRTId);
            LSB.add(subBrand1);
            
            ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2'
                                                                      ,recordTypeId=strRTId) ;
            LSB.add(subBrand2);
            insert LSB;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code'); 
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId );
            insert ac;
            
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
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                 ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
            
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            ASI_MFM_Sub_brand__c sb = new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,
                                                               ASI_MFM_Brand__c=brand.id );
            insert sb;
            
             ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueOf('2015-12-29'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=LPrefix[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_Currency__c='RMB',
                                                 ASI_MFM_PO_Start_Date__c=Date.valueOf('2016-03-29'),ASI_MFM_PO_End_Date__c=Date.valueOf('2016-03-29'),
                                                 ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ownerid = user2.id, ASI_MFM_CN_BU_Picklist__c = 'BUCode', ASI_MFM_PO_Type__c = 'Test');
            insert po;
            
            //insert plan line item
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                                                    ,ASI_MFM_Sub_brand_Code__c = sb.id,ASI_MFM_List_Item_Description__c='hello1'
                                                                                    ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
                                                                                    ASI_MFM_A_C_Code__c=ac.id
                                                                                   );
            insert planLineItem1;
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            List<ASI_MFM_PO_Line_Item__c> polList = new List<ASI_MFM_PO_Line_Item__c>();
            ASI_MFM_PO_Line_Item__c poli1 = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=Date.valueOf('2016-05-29'),ASI_MFM_Sub_brand_Code__c=sb.id,
                                                                       ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=LAcct[0].id, ASI_MFM_Amount__c=100);
            polList.add(poli1);
            ASI_MFM_PO_Line_Item__c poli2 = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=Date.valueOf('2016-05-29'),ASI_MFM_Sub_brand_Code__c=sb.id,
                                                                       ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=LAcct[0].id, ASI_MFM_Amount__c=100);
            polList.add(poli2);
            insert polList;
            
            ASI_MFM_Tax_Code__c taxCode = new ASI_MFM_Tax_Code__c(Name = '11%', ASI_MFM_VAT_Rate__c = 0, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_CN_Tax_Code'));
            
            Insert taxCode;
            
            Test.startTest();
            
            List<ASI_MFM_VAT_Invoice__c> invoiceList = new List<ASI_MFM_VAT_Invoice__c>();
            
            invoiceList.add(new ASI_MFM_VAT_Invoice__c(Name = 'Test1', ASI_MFM_BU__c = bu.Id, ASI_MFM_Supplier__c = LAcct[1].id, ASI_MFM_Tax_Code__c = taxCode.id, ASI_MFM_Status__c = 'Open', ASI_MFM_Invoice_Amount__c = 10
                                                       , ASI_MFM_Currency__c = 'RMB', ASI_MFM_PO_No__c = po.id, ASI_MFM_Invoice_Date__c = Date.valueOf('2016-03-29'), recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_VAT_Invoice__cASI_MFM_CN_VAT_Invoice')
                                                      ));
            invoiceList.add(new ASI_MFM_VAT_Invoice__c(Name = 'Test2', ASI_MFM_BU__c = bu.Id, ASI_MFM_Supplier__c = LAcct[1].id, ASI_MFM_Tax_Code__c = taxCode.id, ASI_MFM_Status__c = 'Open', ASI_MFM_Invoice_Amount__c = 110
                                                       , ASI_MFM_Currency__c = 'RMB', ASI_MFM_PO_No__c = po.id, ASI_MFM_Invoice_Date__c = Date.valueOf('2016-03-29'), recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_VAT_Invoice__cASI_MFM_CN_VAT_Invoice')
                                                      ));
            invoiceList.add(new ASI_MFM_VAT_Invoice__c(Name = 'Test3', ASI_MFM_BU__c = bu.Id, ASI_MFM_Supplier__c = LAcct[1].id, ASI_MFM_Tax_Code__c = taxCode.id, ASI_MFM_Status__c = 'Open', ASI_MFM_Invoice_Amount__c = 80
                                                       , ASI_MFM_Currency__c = 'RMB', ASI_MFM_PO_No__c = po.id, ASI_MFM_Invoice_Date__c = Date.valueOf('2016-03-29'), recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_VAT_Invoice__cASI_MFM_CN_VAT_Invoice')
                                                      ));
            Insert invoiceList;
            
            PageReference pageRef = Page.ASI_MFM_CN_ScanToPay_Page;
            Test.setCurrentPage(pageRef);
            
            ASI_MFM_CN_ScanToPayController con = new ASI_MFM_CN_ScanToPayController();
            con.init();
            con.selected_prefix = LPrefix[2].id;
            con.prePayment = TRUE;
            con.budgetOwner = NULL;
            con.raised_by_filter = NULL;
            con.fiscalYear = 'FY1516';
            
            con.getVATInvoice();
            for(ASI_MFM_CN_ScanToPayController.invoiceClass obj : con.invoiceList){
                obj.checked = TRUE;
            }
            con.convertPayment();
            
            con.getVATInvoice();
            for(ASI_MFM_CN_ScanToPayController.invoiceClass obj : con.invoiceList){
                obj.checked = TRUE;
            }
            con.convertPayment();
            
            for(ASI_MFM_CN_ScanToPayController.invoiceClass obj : con.invoiceList){
                obj.checked = FALSE;
            }
            
            con.convertPayment();
            
            con.PONumber = 'PO11111';
            con.invoiceStatus = 'Open';
            con.POType = 'Test';
            con.selectedBU = bu.Id;
            con.supplier = 'TestAcc';
            con.planId = 'CNM131';
            con.budgetOwner = user2.id;
            con.raised_by_filter = user2.id;
            con.fiscalYear = 'All';
            
            con.getVATInvoice();
            con.convertPayment();

			for(ASI_MFM_CN_ScanToPayController.invoiceClass obj : con.invoiceList){
                obj.VATInvoice.ASI_MFM_BU__c = NULL;
            }
            
            con.convertPayment();
            
            con.selected_prefix = NULL;
            
            con.convertPayment();
            con.closePayment();
            
            ASI_MFM_CN_POSupplierEmailCtrller con2 = new ASI_MFM_CN_POSupplierEmailCtrller();
            con2.headerId = po.id;
            List<String> a = con2.getSubBrand();
            
            Test.stopTest();
        }
    }
    Static Testmethod Void eMailControllerTest(){
        
        test.startTest();
        
        ASI_MFM_CN_PaymentCashOutEmailCTRLLER con = new ASI_MFM_CN_PaymentCashOutEmailCTRLLER();
        con.dummyVar = FALSE;
        con.init();
        
        test.stopTest();
    }
}