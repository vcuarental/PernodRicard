/*
Test Class:
- ASI_MFM_KR_PlanSubmitController
- ASI_MFM_KR_PRSubmitForApprovalCtrl
- ASI_MFM_KR_PlanToolBarController
- ASI_MFM_KR_PRToolBarController
- ASI_MFM_KR_POToolBarController
- ASI_MFM_KR_PaymentToolBarController

- ASI_MFM_SetPlanStatusController
*/


@istest
public class ASI_MFM_KR_SubmitApprlToolBar_TestClass {
    
    /*---------------------------------------------Fiscal Year Method -----------------------------------------------------------*/
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
    
    /*---------------------------------------------Test Plan: ASI_MFM_KR_PlanSubmitController -----------------------------------------------------------*/
     static testMethod void PlanSubmitController_Test_WithoutAtth(){
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
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
                    ASI_MFM_Module__c = 'Plan'
                    //ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            insert prefixKR_PLAN;
            
            //Insert Prefix-Relationship
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
            
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //Insert Plan
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c =date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Draft',
                    OwnerId =u.id
                );
               
            insert plan;

            PageReference SetStatusPage = Page.ASI_MFM_KR_PlanSubmitPage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            ASI_MFM_KR_PlanSubmitController SetStatusController = new ASI_MFM_KR_PlanSubmitController(stdController);
            SetStatusController.submit();
            plan.ASI_MFM_Status__c='Submitted';
            UPDATE plan; 
            
        }
     }
     
    static testMethod void PlanSubmitController_Test_ApprovedStatus(){
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
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
                    ASI_MFM_Module__c = 'Plan'
                    //ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            insert prefixKR_PLAN;
            
            //Insert Prefix-Relationship
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
            
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //Insert Plan
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c =date.today(),
                    ASI_MFM_End_Date__c =date.today(), 
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Submitted',
                    OwnerId =u.id
                );
               
            insert plan;

            PageReference SetStatusPage = Page.ASI_MFM_KR_PlanSubmitPage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            ASI_MFM_KR_PlanSubmitController SetStatusController = new ASI_MFM_KR_PlanSubmitController(stdController);
            SetStatusController.submit();
            plan.ASI_MFM_Status__c='Submitted';
            UPDATE plan; 
            
        }
     }
     
     static testMethod void PlanSubmitController_Test_NoAtth(){
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
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
                    ASI_MFM_Module__c = 'Plan'
                    //ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            insert prefixKR_PLAN;
            
            //Insert Prefix-Relationship
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
            
            
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
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c = date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Draft',
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
            
            /*
            //Insert Attachment
            attachment Atth = new attachment(parentid=plan.id,Name='Attachment Name',Body=Blob.valueOf('Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=planLine.id,Name='Attachment Name',Body=Blob.valueOf('Attachment Body'));
            insert atth1;
            */
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
            PageReference SetStatusPage = Page.ASI_MFM_KR_PlanSubmitPage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            ASI_MFM_KR_PlanSubmitController SetStatusController = new ASI_MFM_KR_PlanSubmitController(stdController);
            SetStatusController.submit();
            plan.ASI_MFM_Status__c='Submitted';
            UPDATE plan; 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
            
        }
     }

     /*---------------------------------------------Test PR: ASI_MFM_KR_PRSubmitForApprovalCtrl -----------------------------------------------------------*/
     static testMethod void PRSubmitController_Test_1(){         // Draft status
         
            String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing');
            insert Role_Test;
            
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
            update u;
            
            
         System.runAs(u){ 
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
            
          // Insert PR Header:
          ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     //ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Draft',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header;    
            
            
            // Insert PR Line:
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             //ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             //ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
            PageReference SetStatusPage = Page.ASI_MFM_KR_PRSubmitForApprovalpage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_PRSubmitForApprovalCtrl SetStatusController = new ASI_MFM_KR_PRSubmitForApprovalCtrl(stdController);
            SetStatusController.setStatus();
            PR_Header.ASI_MFM_Status__c='Submitted';
            UPDATE PR_Header; 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }
     }
     
     static testMethod void PRSubmitController_Test_2(){         // Submitted status
         
            String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing');
            insert Role_Test;
            
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
            update u;
            
            
         System.runAs(u){ 
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
            
          // Insert PR Header:
          ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     //ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Submitted',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header;    
            
            
            // Insert PR Line:
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             //ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             //ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
            PageReference SetStatusPage = Page.ASI_MFM_KR_PRSubmitForApprovalpage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_PRSubmitForApprovalCtrl SetStatusController = new ASI_MFM_KR_PRSubmitForApprovalCtrl(stdController);
            SetStatusController.setStatus();
            PR_Header.ASI_MFM_Status__c='Submitted';
            UPDATE PR_Header; 
            PR_Header.ASI_MFM_Status__c='Rejected';
            UPDATE PR_Header; 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }
     }
     
   
          static testMethod void PRSubmitController_Test_3(){         // Attachment 
         
            String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing');
            insert Role_Test;
            
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
            update u;
            
            
         System.runAs(u){ 
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
            
          //Inset a AP Code that requiries attchment 
          ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_PR__c ='Contract',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
          // Insert PR Header:
          ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     //ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'Service',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Draft',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header;    
            
            
            // Insert PR Line:
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             //ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',  
                                                                                             //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            /*
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            
            */
            
            PageReference SetStatusPage = Page.ASI_MFM_KR_PRSubmitForApprovalpage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_PRSubmitForApprovalCtrl SetStatusController = new ASI_MFM_KR_PRSubmitForApprovalCtrl(stdController);
            SetStatusController.setStatus();
            PR_Header.ASI_MFM_Status__c='Submitted';
            UPDATE PR_Header; 
           
        }
     }
    
     static testMethod void PRSubmitController_Test_4(){         // If no PR Line 
         
            String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing');
            insert Role_Test;
            
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
            update u;
            
            
         System.runAs(u){ 
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
            
          //Inset a AP Code that requiries attchment 
          ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_PR__c ='Contract',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
          // Insert PR Header:
          ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     //ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'Service',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header;    
            
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
            PageReference SetStatusPage = Page.ASI_MFM_KR_PRSubmitForApprovalpage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_PRSubmitForApprovalCtrl SetStatusController = new ASI_MFM_KR_PRSubmitForApprovalCtrl(stdController);
            SetStatusController.setStatus();
            PR_Header.ASI_MFM_Status__c='Submitted';
            UPDATE PR_Header; 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }
     }
     
     static testMethod void PRSubmitController_Test_5(){         // Rejected status
         
            String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing');
            insert Role_Test;
            
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
            update u;
            
            
         System.runAs(u){ 
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
            
          // Insert PR Header:
          ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     //ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Rejected',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header;    
            
            
            // Insert PR Line:
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             //ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             //ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
            PageReference SetStatusPage = Page.ASI_MFM_KR_PRSubmitForApprovalpage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_PRSubmitForApprovalCtrl SetStatusController = new ASI_MFM_KR_PRSubmitForApprovalCtrl(stdController);
            SetStatusController.setStatus();
            PR_Header.ASI_MFM_Status__c='Submitted';
            UPDATE PR_Header; 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }
     }
     
     
     
     /*---------------------------------------------Test Plan Tool bar: ASI_MFM_KR_PlanToolBarController -----------------------------------------------------------*/
     static testMethod void PlanToolBarController_Test_1(){   
         
         String fiscalYear = getFiscalYear();
         
         userrole Role_Test= new userrole(Name='XXXTrade Marketing');
         insert Role_Test;
         
         user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
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
                    ASI_MFM_Module__c = 'Plan'
                    //ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            insert prefixKR_PLAN;
            
            //Insert Prefix-Relationship
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
            
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //Insert Plan
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c =date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Draft',
                    ASI_MFM_Need_Attachment__c = true,
                    OwnerId =u.id
                );
               
            insert plan;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                                                        ASI_MFM_Start_Date__c = date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Draft',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            PageReference SetStatusPage = Page.ASI_MFM_KR_Plan_PlanToolBarPage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            ASI_MFM_KR_PlanToolBarController SetStatusController = new ASI_MFM_KR_PlanToolBarController(stdController);
            SetStatusController.init();
            
         }
     }
     
     /*---------------------------------------------Test PR Tool bar: ASI_MFM_KR_PRToolBarController -----------------------------------------------------------*/
     static testMethod void PRToolBarController_Test_1(){
         
         String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing');
            insert Role_Test;
            
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
            update u;
            
            
         System.runAs(u){ 
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
            
          // Insert PR Header:
          ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     //ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Draft',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header;    
            
            
            // Insert PR Line:
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             //ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             //ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;

            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth; 
            
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
            PageReference SetStatusPage = Page.ASI_MFM_KR_PR_PRToolBarPage;
            Test.setCurrentPage(SetStatusPage);   
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_PRToolBarController SetStatusController = new ASI_MFM_KR_PRToolBarController(stdController);
            SetStatusController.init(); 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
         }
         
     }
     
     /*---------------------------------------------Test PO Tool bar: ASI_MFM_KR_POToolBarController -----------------------------------------------------------*/
     static testMethod void POToolBarController_Test_1(){
        //USER ROLE:
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        //USER:
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            String FiscalYear = getFiscalYear();
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //PLAN PREFIX:
            ASI_MFM_Prefix__c prefixPlan = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPlan);
            //insert prefixPlan;
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            //insert prefixPR; 
            Prefix_List.add(prefixPR);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            //insert prefixPO;
            Prefix_List.add(prefixPO);
            insert Prefix_List;
            
            //PREFIX-ROLE RELATIONSHIP:
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPlan.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            //insert rel;
            PrefixRole_List.add(rel);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            //insert rel_PO;
            PrefixRole_List.add(rel_PO);
            insert PrefixRole_List;
            
            //ACCOUNT:
            List<Account> accList = new List<Account>();
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            accList.add(acc1);
            
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            accList.add(acc2);
            insert accList;
            
            //APPROVAL SETTING FOR PLAN:
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            //PROJECT CODE FOR PLAN:
            /*
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            */
            
            //PLAN:
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                       // ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c =date.today(),
                                                        ASI_MFM_Prefix__c = prefixPlan.id,  
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            /*
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
            ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            */
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 // ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            
            //Budget Checking for Plan
            /*
            ASI_MFM_KR_Budget_Setting__c BudgetCheck = new ASI_MFM_KR_Budget_Setting__c(Name='123',ASI_MFM_Budget_Type__c = 'LE1', ASI_MFM_Activation_Time__c = date.today().adddays(-5));
            insert BudgetCheck;
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
            // ASI_MFM_Sub_brand_Code__c = SubBrand.id,
            ASI_MFM_Budget_Type__c ='NORM',
            ASI_MFM_Fiscal_Year__c = getFiscalYear(),
            ASI_MFM_P3_Amount__c = 100,
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget'));
            insert Budget;
            */
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             //ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today());
            insert PR_Line;
            
            
            
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
            Test.startTest();
            System.debug(Limits.getDMLRows());
            
            PageReference SetStatusPage = Page.ASI_MFM_KR_PR_PRToolBarPage;
            Test.setCurrentPage(SetStatusPage);   
              
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_KR_POToolBarController SetStatusController = new ASI_MFM_KR_POToolBarController(stdController);
            SetStatusController.init(); 
            
            test.stopTest();  
            /*---------------------------------------------End Test-----------------------------------------------------------*/
         }
           
     }
     
     /*---------------------------------------------Test Payment Tool bar: ASI_MFM_KR_PaymentToolBarController -----------------------------------------------------------*/
     static testMethod void PaymentToolBarController_Test_1(){
         
         //USER ROLE:
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        //USER:
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
         
            String FiscalYear = getFiscalYear();
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            /*
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan'
                    //ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            Prefix_List.add(prefixKR_PLAN);
            */
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPR);
            
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPayment);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            //insert prefixPO;
            Prefix_List.add(prefixPO);
            insert Prefix_List;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            //Prefix Relationship
             ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Payment);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PO); 
            /*
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Plan); 
            */
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
                
            //APPROVAL SETTING:
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            //Insert Plan
            /*
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        //ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                                                        ASI_MFM_Status__c='Approved',
                                                        OwnerId =u.id);
            insert plan1;
            */
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                    // ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            //Insert PO
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today()   
                                                                            //ASI_MFM_Purchase_Request_Line__c = PR_Line.id   
                                                                            );
            
            insert po_line;
            
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id);
            
            insert PaymentHeader;
             
           /* 
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 100,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id);
            insert PaymentLine;
           */         
           
           attachment Atth = new attachment(parentid=PaymentHeader.id,Name='Attachment Name',Body=Blob.valueOf('Attachment Body'));
            insert atth;
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
            Test.startTest();
            System.debug(Limits.getDMLRows());
            
            PageReference SetStatusPage = Page.ASI_MFM_KR_Payment_PaymentToolBarPage;
            Test.setCurrentPage(SetStatusPage);   
              
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PaymentHeader);        
            ASI_MFM_KR_PaymentToolBarController SetStatusController = new ASI_MFM_KR_PaymentToolBarController(stdController);
            SetStatusController.init(); 
            
            test.stopTest();  
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }    
         
         
     }
     
      /*---------------------------------------------Test Plan Set Status: ASI_MFM_SetPlanStatusController -----------------------------------------------------------*/
     static testMethod void PlanSetStatusController_Test_1(){   //Rejected > Draft
         
          String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
            insert Role_Test;
            
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
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
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
             
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //Insert Plan
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c = date.today(),
                    ASI_MFM_End_Date__c =date.today(), 
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Rejected',
                    OwnerId =u.id
                );
               
            insert plan;
            
            PageReference SetStatusPage = Page.ASI_MFM_SetPlanStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Draft');
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            ASI_MFM_SetPlanStatusController SetStatusController = new ASI_MFM_SetPlanStatusController(stdController);
            SetStatusController.setStatus();
         }
     }
     

     static testMethod void PlanSetStatusController_Test_2(){   //Approved > Draft
         
          String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
            insert Role_Test;
            
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
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
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
             
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //Insert Plan
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c =date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Approved',
                    OwnerId =u.id
                );
               
            insert plan;
            
            PageReference SetStatusPage = Page.ASI_MFM_SetPlanStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Draft');
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            ASI_MFM_SetPlanStatusController SetStatusController = new ASI_MFM_SetPlanStatusController(stdController);
            SetStatusController.setStatus();
            
            
         }
           
         
     }

     static testMethod void PlanSetStatusController_Test_3(){   //Approved > Closed
         
          String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
            insert Role_Test;
            
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
            update u;
            
            
         System.runAs(u){ 
             //Insert Prefix
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            insert prefixKR_PLAN;
            
            //Insert Prefix-Relationship
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
             
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //Insert Plan
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c =date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Approved',
                    OwnerId =u.id
                );
               
            insert plan;
            
            PageReference SetStatusPage = Page.ASI_MFM_SetPlanStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Closed');
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            ASI_MFM_SetPlanStatusController SetStatusController = new ASI_MFM_SetPlanStatusController(stdController);
            SetStatusController.setStatus();
            
            
         }
         
         
     }
     
     static testMethod void PlanSetStatusController_Test_4_WithExistingPRPO(){   //Approved > Draft
         
          String fiscalYear = getFiscalYear();
            
            userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
            insert Role_Test;
              
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
            u.UserRoleid =Role_Test.id;
            u.CompanyName = 'Pernod Ricard Korea';
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
            
            //Prefix PR:
             ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            insert prefixPR; 
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            insert prefixPO;

            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
                
            insert rel;
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            insert rel_PR;
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            insert rel_PO;
            
             
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
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
                    OwnerId =u.id
                );
               
            insert plan;
            
            // Insert PR Header:
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                      ASI_MFM_Plan__c = plan.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            List<ASI_MFM_PO__c> polist = new List<ASI_MFM_PO__c>();
            //Insert PO
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Plan__c = plan.id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            polist.add(po);
            
            //Insert PO2
            ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,  
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Plan__c = plan.id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            polist.add(po2);
            insert polist;      
            
            Test.startTest();  
            System.debug(Limits.getDMLRows());
            
            PageReference SetStatusPage = Page.ASI_MFM_SetPlanStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Closed');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            ASI_MFM_SetPlanStatusController SetStatusController = new ASI_MFM_SetPlanStatusController(stdController);   
            
            SetStatusController.setStatus();
            
            test.stopTest();  
            
         }
     }
     

}