/*
Test Class:
- ASI_MFM_KR_PO_SEND_PDFController
- ASI_MFM_KR_PlanRequestEmailController
- ASI_MFM_KR_PREmailConntroller
- ASI_MFM_KR_POEmailController
- ASI_MFM_KR_PayEmailController

- ASI_MFM_KR_SelectPRPrefixController
- ASI_MFM_KR_PRNewPORedirectCtrl
- ASI_MFM_KR_PlanNewPRRedirectCtrl
- ASI_MFM_KR_SetPRStatusController
- ASI_MFM_KR_SetPOReceiptStatusController

- ASI_MFM_KR_SelectProjectCodeController
*/


@istest
public class ASI_MFM_KR_EmailPrefix_TestClass {
    
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
    
     /*---------------------------------------------Test PO: ASI_MFM_KR_PO_SEND_PDFController -----------------------------------------------------------*/
     static testMethod void POPDFController_Test_1(){
         
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
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
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
            
            //Prefix Relationship
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PO); 
  
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PR);
            insert PrefixRole_List;
            
            //APPROVAL SETTING:
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
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
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
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
             
            Test.startTest();
            System.debug(Limits.getDMLRows());
            
            PageReference SetStatusPage = Page.ASI_MFM_KR_PO_SEND_PDFPage;
            Test.setCurrentPage(SetStatusPage);    
            //ApexPages.currentPage().getParameters().put('status', 'Draft');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_KR_PO_SEND_PDFController SetStatusController = new ASI_MFM_KR_PO_SEND_PDFController(stdController);
            SetStatusController.send();
            test.stopTest();  
        }
     }
     
     /*---------------------------------------------Test Plan: ASI_MFM_KR_PlanRequestEmailController -----------------------------------------------------------*/
     static testMethod void PlanRequestEmailController_Test_1(){
         
         userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
                    ASI_MFM_Fiscal_year__c = getFiscalYear()
                );  
            insert prefixKR_PLAN;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
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
            
             
            Test.startTest();       
            System.debug(Limits.getDMLRows());
         
         
            //ASI_MFM_KR_PlanRequestEmailController ext = new ASI_MFM_KR_PlanRequestEmailController(new ApexPages.StandardController(plan));
            ASI_MFM_KR_PlanRequestEmailController ext = new ASI_MFM_KR_PlanRequestEmailController();
            ext.receiptID = plan.ID;
            
            ext.dummyVar = ext.init();
            test.stopTest();     
        }
     }
     
     /*---------------------------------------------Test PR: ASI_MFM_KR_PREmailConntroller -----------------------------------------------------------*/
     static testMethod void PREmailController_Test_1(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
            
            
              
            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
         
            //ASI_MFM_KR_PREmailConntroller ext = new ASI_MFM_KR_PREmailConntroller(new ApexPages.StandardController(PR_Header));
            ASI_MFM_KR_PREmailConntroller ext = new ASI_MFM_KR_PREmailConntroller();
            ext.headerId = PR_Header.ID;
            
            ext.dummyVar = ext.init();  
            test.stopTest();     
        }
     }  
     
     
     /*---------------------------------------------Test PO: ASI_MFM_KR_POEmailController -----------------------------------------------------------*/
     static testMethod void ASI_MFM_KR_POEmailController(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            insert prefixPO;
            
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
            
            //Insert AP Code
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_Plan__c = 'Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
           
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            //Insert PO
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 //ASI_MFM_Purchase_Request__c = PR_Header.id,
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
            
            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
           
            ASI_MFM_KR_POEmailController ext = new ASI_MFM_KR_POEmailController();
            //ASI_MFM_KR_POEmailController ext = new ASI_MFM_KR_POEmailController(new ApexPages.StandardController(po));
            ext.headerId = po.ID;
            
            ext.dummyVar = ext.init();
            test.stopTest();     
        }
     }
    
     /*---------------------------------------------Test Payment: ASI_MFM_KR_PayEmailController -----------------------------------------------------------*/
     static testMethod void ASI_MFM_KR_PaymentEmailController(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            //Insert Prefix
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c> ();
            List<ASI_MFM_Role_Prefix_Relationship__c> RelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPO);
            
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPayment);
            insert PrefixList;
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PO);
            
            //Prefix Relationship
             ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_Payment);
            insert RelationshipList;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            /*    
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            */
            
            //Insert AP Code
            /*ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_Plan__c = 'Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
           */
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            //Insert PO
           
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 //ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO_Read_Only'));
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
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Approved',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment_Read_Only'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Prefix__c = prefixPayment.id);
            
            insert PaymentHeader;
             
            /*
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 100,
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number');
            insert PaymentLine;
            */
            Test.startTest();       
            System.debug(Limits.getDMLRows());
         
            ASI_MFM_KR_PayEmailController ext = new ASI_MFM_KR_PayEmailController();
            ext.headerId = PaymentHeader.ID;
            
            ext.dummyVar = ext.init();
            test.stopTest();     
        }
     }
    
     /*---------------------------------------------Test PR: ASI_MFM_KR_SelectPRPrefixController -----------------------------------------------------------*/
     static testMethod void PRPrefixController_Test_1(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
            ext.getPrefixes();
            ext.selected_prefix = prefixPR.id;
            ext.proceed();
            test.stopTest();         
        }
     }
     
          /*---------------------------------------------Test PR: ASI_MFM_KR_SelectPRPrefixController -----------------------------------------------------------*/
     static testMethod void PRPrefixController_Test_2(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today());
            insert PR_Line;
            
            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
         
            ASI_MFM_KR_SelectPRPrefixController ext = new ASI_MFM_KR_SelectPRPrefixController(new ApexPages.StandardController(PR_Header));
            //ApexPages.currentPage().getParameters().put('planid', plan.id);
            ext.getPrefixes();
            //ext.selected_prefix = prefixPR.id;
            ext.proceed();
            test.stopTest();         
        }
     }
     
     /*---------------------------------------------Test PR: ASI_MFM_KR_PRNewPORedirectCtrl -----------------------------------------------------------*/
     static testMethod void PRDirectNewPOController_Test_1(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
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
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            insert prefixPO;
            
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
            
            //Insert AP Code
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_Plan__c = 'Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            //Insert Custom Setting : ASI MFM Field ID Mappings
            List<ASI_MFM_Field_ID_Mappings__c> FieldIDDateList  = new List<ASI_MFM_Field_ID_Mappings__c>();
            ASI_MFM_Field_ID_Mappings__c f1 = new ASI_MFM_Field_ID_Mappings__c(Name='1',ASI_MFM_Object_Name__c= 'ASI_MFM_PO__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Plan__c',ASI_MFM_Field_ID__c='1');
            FieldIDDateList.add(f1);
            ASI_MFM_Field_ID_Mappings__c f2 = new ASI_MFM_Field_ID_Mappings__c(Name='2',ASI_MFM_Object_Name__c= 'ASI_MFM_PO__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Prefix__c',ASI_MFM_Field_ID__c='2');
            FieldIDDateList.add(f2);// 
            ASI_MFM_Field_ID_Mappings__c f3 = new ASI_MFM_Field_ID_Mappings__c(Name='3',ASI_MFM_Object_Name__c= 'ASI_MFM_PO__c',ASI_MFM_Field_Name__c= 'ASI_MFM_PO_Name__c',ASI_MFM_Field_ID__c='3');
            FieldIDDateList.add(f3);
            insert FieldIDDateList;
        
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
                    ASI_MFM_Plan_Name__c = 'Test Plan2',
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
                                                                                     ASI_MFM_Currency__c = 'KRW',
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Draft',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header; 
              
            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
            //ASI_MFM_Prefix__c px_id=[select id from ASI_MFM_Prefix__c where ASI_MFM_Inactive__c = false and ASI_MFM_country_name__c='KR' and ASI_MFM_Module__c='PO' and name=: PR_Header.ASI_MFM_Prefix__r.name limit 1 ];
            system.assertEquals(prefixPO.ASI_MFM_country_name__c,null);
            
            /*
            ASI_MFM_KR_PRNewPORedirectCtrl ext = new ASI_MFM_KR_PRNewPORedirectCtrl(new ApexPages.StandardController(PR_Header));
            ext.redirect();
            */
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);
            ASI_MFM_KR_PRNewPORedirectCtrl ext  = new ASI_MFM_KR_PRNewPORedirectCtrl(stdController);
            ext.redirect();  
            test.stopTest();         
        }
     }
     
    /*---------------------------------------------Test PR: ASI_MFM_KR_PlanNewPRRedirectCtrl -----------------------------------------------------------*/
     static testMethod void ASI_MFM_KR_PlanNewPRRedirectCtrl_Test_1(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
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
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                    ASI_MFM_Start_Date__c = date.today(),
                    ASI_MFM_End_Date__c = date.today(), 
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Submitted',
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
   
            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
         
            ASI_MFM_KR_PlanNewPRRedirectCtrl ext = new ASI_MFM_KR_PlanNewPRRedirectCtrl(new ApexPages.StandardController(plan));
            //ext.pr = PR_Header.id;
            //ApexPages.currentPage().getParameters().put('planid', plan.id);
            ext.redirect();
            test.stopTest();         
        }
     }
     
       
     static testMethod void ASI_MFM_KR_PlanNewPRRedirectCtrl_Test_2(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
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
                                                                 ASI_MFM_PRPO_Needed__c = true,
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
   
            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
         
            ASI_MFM_KR_PlanNewPRRedirectCtrl ext = new ASI_MFM_KR_PlanNewPRRedirectCtrl(new ApexPages.StandardController(plan));
            //ext.pr = PR_Header.id;
            //ApexPages.currentPage().getParameters().put('planid', plan.id);
            ext.redirect();
            test.stopTest();         
        }
     }
  
       static testMethod void ASI_MFM_KR_PlanNewPRRedirectCtrl_Test_3(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
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
                                                                 ASI_MFM_PRPO_Needed__c = true,
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
                    ASI_MFM_Budget_Type__c = 'NORM',
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
   
            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
         
            ASI_MFM_KR_PlanNewPRRedirectCtrl ext = new ASI_MFM_KR_PlanNewPRRedirectCtrl(new ApexPages.StandardController(plan));
            //ext.pr = PR_Header.id;
            //ApexPages.currentPage().getParameters().put('planid', plan.id);
            ext.redirect();
            test.stopTest();         
        }
     }
     
     static testMethod void ASI_MFM_KR_PlanNewPRRedirectCtrl_Test_4(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
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
                                                                 ASI_MFM_PRPO_Needed__c = true,
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
                    ASI_MFM_Budget_Type__c = 'DISC',
                    ASI_MFM_Need_Attachment__c = true
                );
               
            insert plan;

            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
         
            ASI_MFM_KR_PlanNewPRRedirectCtrl ext = new ASI_MFM_KR_PlanNewPRRedirectCtrl(new ApexPages.StandardController(plan));
            //ext.pr = PR_Header.id;
            //ApexPages.currentPage().getParameters().put('planid', plan.id);
            ext.redirect();
            test.stopTest();         
        }
     }
    /*---------------------------------------------Test PR: ASI_MFM_KR_SetPRStatusController -----------------------------------------------------------*/
       static testMethod void ASI_MFM_KR_SetPRStatusController_Test_1(){
         
         userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            string fiscalYear = getFiscalYear();
            
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c> ();
            List<ASI_MFM_Role_Prefix_Relationship__c> RelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            PrefixList.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            PrefixList.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            PrefixList.add(prefixPO);
            
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPayment);
            insert PrefixList;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PR);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PO);  
            insert RelationshipList;
            
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            //Insert PO: 
            ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),    
                                                 ASI_MFM_Status__c = 'Draft',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po1;  
            
            
            
            
           
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po1.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),      
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id   
                                                                            );
            
            insert po_line;  
         Test.startTest();  
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po1.id,
                                                                      ASI_MFM_Company_Code__c = '222',
                                                                      ASI_MFM_Currency__c = 'KRW',
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_Payment_Amount__c = 1000);  
            
            insert PaymentHeader;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
              
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 1,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_PO__c = po1.id,
                                                                                        ASI_MFM_Beneficiary_Customer__c = customer1.id
                                                                                        );
            insert PaymentLine;
            
                  
            System.debug(Limits.getDMLRows());
         
            /*
            ASI_MFM_KR_SetPRStatusController ext = new ASI_MFM_KR_SetPRStatusController(new ApexPages.StandardController(PR_Header));
            ApexPages.currentPage().getParameters().put('status', 'Closed');
            ext.setStatus();
            */
            PageReference SetStatusPage = Page.ASI_MFM_KR_SetPRStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Closed');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_SetPRStatusController SetStatusController = new ASI_MFM_KR_SetPRStatusController(stdController);
            ApexPages.currentPage().getParameters().put('status', 'Closed');
            SetStatusController.setStatus();
            
            test.stopTest();     
        }
     } 
     
     static testMethod void ASI_MFM_KR_SetPRStatusController_Test_3(){
         
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR'; 
        update u;
        
        System.runAs(u){ 
            
            string fiscalYear = getFiscalYear();
            
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c> ();
            List<ASI_MFM_Role_Prefix_Relationship__c> RelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            PrefixList.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            PrefixList.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            PrefixList.add(prefixPO);
            
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPayment);
            insert PrefixList;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PR);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PO);  
            insert RelationshipList;
            
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
                    ASI_MFM_Start_Date__c =date.today(),
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            //Insert PO: 
            ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Draft',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po1;  
            
        
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po1.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today()   
                                                                            //ASI_MFM_Purchase_Request_Line__c = PR_Line.id   
                                                                            );
            
            insert po_line; 
            
             
            Test.startTest();       
            System.debug(Limits.getDMLRows());
         
            /*
            ASI_MFM_KR_SetPRStatusController ext = new ASI_MFM_KR_SetPRStatusController(new ApexPages.StandardController(PR_Header));
            ApexPages.currentPage().getParameters().put('status', 'Closed');
            ext.setStatus();
            */
            PageReference SetStatusPage = Page.ASI_MFM_KR_SetPRStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Closed');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_SetPRStatusController SetStatusController = new ASI_MFM_KR_SetPRStatusController(stdController);
            ApexPages.currentPage().getParameters().put('status', 'Closed');
            SetStatusController.setStatus();
            
            test.stopTest();     
        }
     } 
     
      static testMethod void ASI_MFM_KR_SetPRStatusController_Test_2(){             //With existing PO (Draft status)
         
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            string fiscalYear = getFiscalYear();
            //Insert Prefix
            
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c> ();
            List<ASI_MFM_Role_Prefix_Relationship__c> RelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            PrefixList.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            PrefixList.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            PrefixList.add(prefixPO);
            
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPayment);
            insert PrefixList;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PR);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PO);  
            insert RelationshipList;
            
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
                    ASI_MFM_Start_Date__c =date.today(),
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            //Insert PO: 
            ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Draft',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po1;  
            
        
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po1.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today()   
                                                                            //ASI_MFM_Purchase_Request_Line__c = PR_Line.id   
                                                                            );
            
            insert po_line;

            Test.startTest();       
            System.debug(Limits.getDMLRows());
         
         
            PageReference SetStatusPage = Page.ASI_MFM_KR_SetPRStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Draft');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_SetPRStatusController SetStatusController = new ASI_MFM_KR_SetPRStatusController(stdController);
            SetStatusController.setStatus();
            
            test.stopTest();    
        }
     } 
     
     static testMethod void ASI_MFM_KR_SetPRStatusController_Test_4(){             //Closed > Draft
         
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            string fiscalYear = getFiscalYear();
            //Insert Prefix
            
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c> ();
            List<ASI_MFM_Role_Prefix_Relationship__c> RelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            PrefixList.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            PrefixList.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            PrefixList.add(prefixPO);
            
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPayment);
            insert PrefixList;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PR);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PO);  
            insert RelationshipList;
            
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
                                                                                     ASI_MFM_Status__c = 'Closed',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 

            Test.startTest();       
            System.debug(Limits.getDMLRows());
         
         
            PageReference SetStatusPage = Page.ASI_MFM_KR_SetPRStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Draft');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_SetPRStatusController SetStatusController = new ASI_MFM_KR_SetPRStatusController(stdController);
            SetStatusController.setStatus();
            
            test.stopTest();    
        }
     }
     
    static testMethod void ASI_MFM_KR_SetPRStatusController_Test_5(){             //Submitted > Draft
         
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            string fiscalYear = getFiscalYear();
            //Insert Prefix
            
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c> ();
            List<ASI_MFM_Role_Prefix_Relationship__c> RelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            PrefixList.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            PrefixList.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            PrefixList.add(prefixPO);
            
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPayment);
            insert PrefixList;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PR);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PO);  
            insert RelationshipList;
            
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
                    ASI_MFM_End_Date__c =date.today(),
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
                                                                                     ASI_MFM_Status__c = 'Submitted',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            

            Test.startTest();       
            System.debug(Limits.getDMLRows());
         
         
            PageReference SetStatusPage = Page.ASI_MFM_KR_SetPRStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Draft');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_SetPRStatusController SetStatusController = new ASI_MFM_KR_SetPRStatusController(stdController);
            SetStatusController.setStatus();
            
            test.stopTest();    
        }
     } 
     
    static testMethod void ASI_MFM_KR_SetPRStatusController_Test_6(){             //Draft > Draft
         
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            string fiscalYear = getFiscalYear();
            //Insert Prefix
            
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c> ();
            List<ASI_MFM_Role_Prefix_Relationship__c> RelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            PrefixList.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            PrefixList.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            PrefixList.add(prefixPO);
            
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPayment);
            insert PrefixList;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PR);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PO);  
            insert RelationshipList;
            
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
                                                                                     ASI_MFM_Status__c = 'Draft',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
         
            Test.startTest();       
            System.debug(Limits.getDMLRows());
         
         
            PageReference SetStatusPage = Page.ASI_MFM_KR_SetPRStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Draft');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_SetPRStatusController SetStatusController = new ASI_MFM_KR_SetPRStatusController(stdController);
            SetStatusController.setStatus();
            
            test.stopTest();    
        }
     }
     
    static testMethod void ASI_MFM_KR_SetPRStatusController_Test_7(){             //Draft > Draft
         
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            string fiscalYear = getFiscalYear();
            //Insert Prefix
            
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c> ();
            List<ASI_MFM_Role_Prefix_Relationship__c> RelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            PrefixList.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            PrefixList.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            PrefixList.add(prefixPO);
            
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPayment);
            insert PrefixList;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PR);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PO);  
            insert RelationshipList;
            
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
                                                                                     ASI_MFM_Status__c = 'Rejected',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            plan.ASI_MFM_Status__c='Closed';
            update plan;
            
            Test.startTest();       
            System.debug(Limits.getDMLRows());
         
         
            PageReference SetStatusPage = Page.ASI_MFM_KR_SetPRStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Draft');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_SetPRStatusController SetStatusController = new ASI_MFM_KR_SetPRStatusController(stdController);
            SetStatusController.setStatus();
            
            test.stopTest();    
        }
     }
    
    static testMethod void ASI_MFM_KR_SetPRStatusController_Test_8(){             //Draft > Approved
         
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            string fiscalYear = getFiscalYear();
            
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c> ();
            List<ASI_MFM_Role_Prefix_Relationship__c> RelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            PrefixList.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            PrefixList.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            PrefixList.add(prefixPO);
            
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            PrefixList.add(prefixPayment);
            insert PrefixList;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PR);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            RelationshipList.add(rel_PO);  
            insert RelationshipList;
            
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
                    ASI_MFM_AP_Code__c = AP_Code.id,
                    ASI_MFM_Actual_Spending_Amount__c = 0
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Closing_Comments__c = 'Test',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 1,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 1000,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 0);
            insert PR_Line;
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            //Insert PO: 
            ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),    
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Closing_Comments__c = 'Test',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_VAT__c = 0,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po1;  
            
            
            
            
           
            ASI_MFM_Plan_Line_Item__c planLine1 = [select id from ASI_MFM_Plan_Line_Item__c limit 1];
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po1.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 1,    
                                                                            ASI_MFM_Amount__c = 0,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),      
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id,
                                                                            ASI_MFM_Base_Currency_Amount__c = 0,
                                                                            ASI_MFM_Plan_Line_Item__c = planLine1.id 
                                                                            );
            
            insert po_line;  
         Test.startTest();  
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Approved',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po1.id,
                                                                      ASI_MFM_Company_Code__c = '222',
                                                                      ASI_MFM_Currency__c = 'KRW',
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_Payment_Amount__c = 0);  
            
            insert PaymentHeader;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
              

            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 0,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_PO__c = po1.id,
                                                                                        ASI_MFM_Beneficiary_Customer__c = customer1.id,
                                                                                        ASI_MFM_Paid_Amount_in_PO_Currency__c = 0
                                                                                        );
            insert PaymentLine;
                  
            System.debug(Limits.getDMLRows());
         
            try{
            PageReference SetStatusPage = Page.ASI_MFM_KR_SetPRStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Closed');
            ApexPages.currentPage().getParameters().put('comment', 'Test');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            ASI_MFM_KR_SetPRStatusController SetStatusController = new ASI_MFM_KR_SetPRStatusController(stdController);
            SetStatusController.setStatus();
            }catch(Exception e){ 
            }
            test.stopTest();    
        }
     }
	     
     /*---------------------------------------------Test PO Receipt: ASI_MFM_KR_SetPOReceiptStatusController -----------------------------------------------------------*/
     static testMethod void ASI_MFM_KR_SetPOReceiptStatusController_Test_1(){     
         userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
            
            Test.startTest();       
            System.debug(Limits.getDMLRows());
         
            PageReference SetStatusPage = Page.ASI_MFM_KR_SetPOReceiptStatusPage;
            Test.setCurrentPage(SetStatusPage);    
            ApexPages.currentPage().getParameters().put('status', 'Approved');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POR_Header);        
            ASI_MFM_KR_SetPOReceiptStatusController SetStatusController = new ASI_MFM_KR_SetPOReceiptStatusController(stdController);
            SetStatusController.setStatus();
            
            test.stopTest();  
            
        }
     }
     
      /*---------------------------------------------Test Project Code: ASI_MFM_KR_SelectProjectCodeController -----------------------------------------------------------*/
     static testMethod void ASI_MFM_KR_SelectProjectCodeController_Test_1(){  
         
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
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
                    ASI_MFM_Fiscal_year__c = getFiscalYear()
                );  
            insert prefixKR_PLAN;
            
            //Insert Prefix-Relationship
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
                
            insert rel;
            
            
            
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
           ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
           ASI_MFM_Prefix__c PjPrefix = new ASI_MFM_Prefix__c(name= 'Test',
                                                               ASI_MFM_Next_Number__c =10,
                                                               ASI_MFM_Project_Code__c =  pjCode.id,
                                                               ASI_MFM_Fiscal_year__c = fiscalYear,
                                                               ASI_MFM_Module__c = 'Plan');
                                                               
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
            
         //Insert Custom Setting : ASI MFM Field ID Mappings
            List<ASI_MFM_Field_ID_Mappings__c> FieldIDDateList  = new List<ASI_MFM_Field_ID_Mappings__c>();
            ASI_MFM_Field_ID_Mappings__c f1 = new ASI_MFM_Field_ID_Mappings__c(Name='1',ASI_MFM_Object_Name__c= 'ASI_MFM_Plan__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Prefix__c',ASI_MFM_Field_ID__c='1');
            FieldIDDateList.add(f1);
            ASI_MFM_Field_ID_Mappings__c f2 = new ASI_MFM_Field_ID_Mappings__c(Name='2',ASI_MFM_Object_Name__c= 'ASI_MFM_Plan__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Fiscal_year__c',ASI_MFM_Field_ID__c='2');
            FieldIDDateList.add(f2);// 
            ASI_MFM_Field_ID_Mappings__c f3 = new ASI_MFM_Field_ID_Mappings__c(Name='3',ASI_MFM_Object_Name__c= 'ASI_MFM_Plan__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Project_Code__c',ASI_MFM_Field_ID__c='3');
            FieldIDDateList.add(f3);
            ASI_MFM_Field_ID_Mappings__c f4 = new ASI_MFM_Field_ID_Mappings__c(Name='4',ASI_MFM_Object_Name__c= 'ASI_MFM_Plan__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Promotion_Code__c',ASI_MFM_Field_ID__c='4');
            FieldIDDateList.add(f4);
            insert FieldIDDateList;
        
          
         Test.startTest();
            System.debug(Limits.getDMLRows());
            
            PageReference SetStatusPage = Page.ASI_MFM_KR_SelectProjectCodePage;
            Test.setCurrentPage(SetStatusPage);       
            ApexPages.currentPage().getParameters().put('Module', 'Plan');
             
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            //ASI_MFM_KR_SelectProjectCodeController SetStatusController = new ASI_MFM_KR_SelectProjectCodeController(stdController);
            ASI_MFM_KR_SelectProjectCodeController ext = new ASI_MFM_KR_SelectProjectCodeController();
            ext.plan = plan;
            ext.init();
            ext.proceed();
            
            //Test RemoteAction
            String[] remo= ASI_MFM_KR_SelectProjectCodeController.findSObjects('ASI_MFM_Project_Code__c','WHERE RecordType.DeveloperName != null');
              
         test.stopTest();  
        }   
     }
      
       
}