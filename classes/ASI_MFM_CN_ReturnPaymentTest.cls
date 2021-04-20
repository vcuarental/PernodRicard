@isTest
public class ASI_MFM_CN_ReturnPaymentTest {
    static testmethod void test_MFM_CN_ReturnByFinanceController(){
		// Assume po with plan name 'dummy for test class' exist
		//ASI_MFM_PO__c po = [select id, name from asi_mfm_po__c where ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c= 'dummy for test class' limit 1];
		
		//User user2 = ASI_MFM_Function.getSystemAdminUser();
		List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
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
        System.runas(user2){
            List<ASI_MFM_PO_Receipt__c> LReceipt = new list<ASI_MFM_PO_Receipt__c>();
            id CNReceiptRecTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt');
            LReceipt.add(new ASI_MFM_PO_Receipt__c(recordtypeid = CNReceiptRecTypeid, ASI_MFM_Receipt_Date__c = date.today(), budget_owner__c = user2.id));
            insert LReceipt;
            
            String strRTID;
            
            List<ASI_MFM_Prefix__c> LPrefix = new list<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                                              ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user2.id);
            LPrefix.add(prefix1);
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                         ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            system.debug('recordTypeId: ' + strRTID);
            LPrefix.add(px);
            //insert px;
            //insert prefix1 ;
            ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test2', ASI_MFM_Module__c='Payment', recordTypeId=strRTID,
                                                         ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=87);
            LPrefix.add(px2);
            insert LPrefix;
            
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[0].Id,
                                                                                                       ASI_MFM_Role_Name__c =user2.userRole.developerName);            
            insert prefixChild2;
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[1].Id,
                                                                                                       ASI_MFM_Role_Name__c =user2.userRole.developerName);            
            insert prefixChild1;
            
            ASI_MFM_Role_Prefix_Relationship__c prefixChild0 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[2].Id,
                                                                                                       ASI_MFM_Role_Name__c =user2.userRole.developerName);            
            insert prefixChild0;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');                       
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            insert ac1;
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            insert ac2;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac1; 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac2; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=LPrefix[0].Id
                                                        ,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user2.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user2.id);
            insert Plan1;
            
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
            //insert subBrand2;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code'); 
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId );
            insert ac;
            
            List<Account> LAcct = new List<Account>();
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            Account acc2 = new Account(recordTypeId=strRTId ,Name='Name3');  
            LAcct.add(acc2);         
            //insert acc2;
            
            //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            Account supplier = new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                           ASI_MFM_Customer_Supplier_Name__c='SupplierName');
            LAcct.add(supplier);
            //insert supplier;
            insert LAcct;
            
            //create BU Code
            //ASI_MFM_CN_BU recordtype
            //rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_BU__c');
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                 ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            //create brand
            //rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Brand__c');
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
            
            //create sub brand
            //rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            ASI_MFM_Sub_brand__c sb = new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,
                                                               ASI_MFM_Brand__c=brand.id );
            insert sb;
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            //ASI_MFM_CN_PO RecordTypeId: 012M00000000TpE
            
            //rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=LPrefix[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=LAcct[1].id, ASI_MFM_Currency__c='USD',
                                                 ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                 ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id );
            insert po;
            
            ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment'),ASI_MFM_Prefix__c=LPrefix[2].id,
                                                           ASI_MFM_Budget_Owner__c =user2.id,ASI_MFM_Supplier_Name__c=LAcct[1].id);
            insert py;
                
            test.startTest();
            ASI_MFM_CN_ReturnPaymentByFinanceCtrl con = new ASI_MFM_CN_ReturnPaymentByFinanceCtrl(new ApexPages.Standardcontroller(py));
            con.cancel();
            con.doApprove();
                
            Delete py;
                
            test.stopTest();
        }
	}
}