@isTest
private class ASI_MFM_KR_SelectPRPrefixControllerTest {
    @testSetup
    static void testDataPre() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China',ASI_MFM_Team__c = 'PR');
        insert adminUser;

        User adminUser1 = new User(Alias = 'admin', Email='adminuser@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test3@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser1;

    }

    static testMethod void testMethod1() {
        User user1 = [select Id from User where UserName='test2@wholesaler.com' limit 1];
        User adminUser1 = [select Id from User where UserName='test3@wholesaler.com' limit 1];
        UserRole Role_Test = [select Id, DeveloperName from UserRole where Name='My Role' limit 1];
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
                          
            
           
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN', ASI_MFM_Base_Currency__c='RMB');
            insert bu;

            
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
            ASI_MFM_KR_SelectPRPrefixController ext = new ASI_MFM_KR_SelectPRPrefixController(new ApexPages.StandardController(PR_Header));
            ext.getPrefixes();
            ext.proceed();
        }
    }

    static testMethod void testMethod2() {

    	String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR';
        update u;
        
        System.runAs(u){ 
            
            //Insert Prefix
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            insert prefixKR_PLAN;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
                
            insert rel;
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            insert prefixPR; 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            insert rel_PR;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //Insert AP Code
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_Plan__c = 'Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            //Insert Plan
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                    ASI_MFM_Start_Date__c = date.today(),
                    ASI_MFM_End_Date__c = date.today(), 
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Approved',
                    OwnerId =u.id,
                    ASI_MFM_Need_Attachment__c = true
                );
               
            insert plan;
            
            //Insert Plan Line
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),
                    ASI_MFM_List_Item_Description__c = 'test description',
                    ASI_MFM_Total_Cost__c = 1234,
                    ASI_MFM_Plan__c = plan.id,
                    //ASI_MFM_KR_subLedger__c = BrandCode.id,
                    ASI_MFM_AP_Code__c = AP_Code.id
                    //ASI_MFM_Sub_brand_Code__c = SubBrand.id
                );
            insert planLine;
            
            // Insert PR Header:
           ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Draft',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header; 
              
            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
         
            ASI_MFM_KR_SelectPRPrefixController ext = new ASI_MFM_KR_SelectPRPrefixController(new ApexPages.StandardController(PR_Header));
            //ApexPages.currentPage().getParameters().put('planid', plan.id);
            Id reId = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request');
            ApexPages.currentPage().getParameters().put('RecordType', reId);
            ext.getPrefixes();
            ext.selected_prefix = prefixPR.id;
            ext.proceed();
            test.stopTest();         
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