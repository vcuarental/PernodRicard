@IsTest
public class ASI_MFM_CN_AnP_VendorDataCtrl_Test {
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
    @testSetup 
    static void setup() {
        
        
        list<User> users = new list<User>();
        
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
        
        system.runAs(user1){
            
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
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                              ,ASI_MFM_Fiscal_year__c = getFiscalYear(), ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                              ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_Next_Number__c=86));
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
            
            //create po
            List<ASI_MFM_PO__c> listpo = new List<ASI_MFM_PO__c>();
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            listpo.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                 ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today().addMonths(1),
                                                 ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id ));

            listpo.add(new ASI_MFM_PO__c(Name='PO22222', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                 ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today().addMonths(1),
                                                 ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id ));
            listpo.add(new ASI_MFM_PO__c(Name='PO33333', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                 ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today().addMonths(1),
                                                 ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id,ASI_MFM_Status__c = 'Submitted' ));
            insert listpo;
            
            
            //create po line item
            List<ASI_MFM_PO_Line_Item__c> listpoline = new List<ASI_MFM_PO_Line_Item__c>();
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');

            listpoline.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=listpo[0].id, ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id  ));
            listpoline.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=listpo[0].id, ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id  ));
            
            Insert listpoline;
        }
    }
	static testMethod void testAnpVendorData() {
        ASI_MFM_PO__c po = [SELECT id FROM ASI_MFM_PO__c Limit 1];
        test.starttest();
        ASI_MFM_CN_AnP_VendorDataCtrl cls = new ASI_MFM_CN_AnP_VendorDataCtrl();
        cls.POID = po.id;
        boolean b = cls.dummyVar;
        test.stopTest();
	}
}