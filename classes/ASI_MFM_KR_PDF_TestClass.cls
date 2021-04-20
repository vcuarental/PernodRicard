/*
Test:
ASI_MFM_KR_Plan_TriggerClass 
ASI_MFM_KR_Plan_PDF_Controller

ASI_MFM_KR_PR_PDF_PageController
ASI_MFM_KR_Payment_PDF_PageController

ASI_MFM_KR_PO_PDF_PageController
ASI_MFM_KR_PO_TriggerClass
ASI_MFM_KR_PaymentLineItem_TriggerClass
*/



@istest
public class ASI_MFM_KR_PDF_TestClass {     
    
    //----------------------------------------------------------Fiscal Year---------------------------------------------------------------------------------------
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
    
    //----------------------------------------------------------PO Prefix--------------------------------------------------------------------------------------- 
    public static ASI_MFM_Prefix__c createPrefixPO ()
    {
        ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
            (
                Name = 'Test',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                ASI_MFM_Module__c = 'PO',
                ASI_MFM_Fiscal_year__c = getFiscalYear()
            );
        insert prefixPO;
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
            (
                ASI_MFM_Prefix__c = prefixPO.id,
                ASI_MFM_Role_Name__c = r.DeveloperName
            );
        insert rel;
        return prefixPO;
    }
    //----------------------------------------------------------Plan Prefix--------------------------------------------------------------------------------------- 
    public static ASI_MFM_Prefix__c createPrefixPlan ()
    {
        ASI_MFM_Prefix__c prefixPlan = new ASI_MFM_Prefix__c
            (
                Name = 'Test',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                ASI_MFM_Module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = getFiscalYear()
            );
        insert prefixPlan;
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
            (
                ASI_MFM_Prefix__c = prefixPlan.id,
                ASI_MFM_Role_Name__c = r.DeveloperName
            );
        insert rel;
        return prefixPlan;
    }
    //----------------------------------------------------------PR Prefix--------------------------------------------------------------------------------------- 
    public static ASI_MFM_Prefix__c createPrefixPR ()
    {
        ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
            (
                Name = 'Test',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                ASI_MFM_Module__c = 'PR',
                ASI_MFM_Fiscal_year__c = getFiscalYear()
            );
        insert prefixPR;  
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
            (
                ASI_MFM_Prefix__c = prefixPR.id,
                ASI_MFM_Role_Name__c = r.DeveloperName
            );
        insert rel;
        return prefixPR;
    }
    
    static testMethod void Plan_PDF_Test(){                                 //Test: ASI_MFM_KR_Plan_TriggerClass & ASI_MFM_KR_Plan_PDF_Controller
        
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        System.runAs(u){ 
            
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042',ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='Plan', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());  
            //insert px;
            
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                                                        ASI_MFM_Start_Date__c = date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = createPrefixPlan().id,
                                                        ASI_MFM_Status__c='Draft',
                                                        OwnerId =u.id);
            insert plan1;
            
            
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
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            ASI_MFM_KR_Plan_PDF_Controller ext = new ASI_MFM_KR_Plan_PDF_Controller(new ApexPages.StandardController(plan1));
            
            ext.currentHeaderId= plan1.Id; 
            ext.init();   
            ext.getapprovalDetails();
            
            
        }
    }
    
    
    static testMethod void PR_PDF_Test(){                                 //Test: ASI_MFM_KR_PR_PDF_PageController
        
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        
        
        System.runAs(u){ 
            
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Purchase_Request__c'); 
            rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KR_Warehouse'),Name='Name1',ASI_MFM_Address_Line_1__c = '1', ASI_MFM_Address_Line_2__c = '2',
                                       ASI_MFM_Address_Line_3__c = '3', ASI_MFM_Address_Line_4__c = '4');          
            insert acc1;
            
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042',ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                                                        ASI_MFM_Start_Date__c = date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = createPrefixPlan().id,  
                                                        ASI_MFM_Status__c='Draft',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
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
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            plan1.ASI_MFM_Status__c = 'Approved';
            plan1.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only');
            update plan1;
            
            
            //Budget Checking for Plan
           // ASI_MFM_KR_Budget_Setting__c BudgetCheck = new ASI_MFM_KR_Budget_Setting__c(Name='123',ASI_MFM_Budget_Type__c = 'LE1', ASI_MFM_Activation_Time__c = date.today().adddays(-5));
           // insert BudgetCheck;
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = getFiscalYear(),
                                                             ASI_MFM_P3_Amount__c = 100,
                                                             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget'));
            insert Budget;
            
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Draft',
                                                                                     ASI_MFM_Prefix__c = createPrefixPR().id,
                                                                                     ASI_MFM_KR_Ship_to_Address__c = 'address',
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header;    
            
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today());
            insert PR_Line;
            
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=PR_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth1; 
            
            ASI_MFM_KR_PR_PDF_PageController ext = new ASI_MFM_KR_PR_PDF_PageController(new ApexPages.StandardController(PR_Header));
            ext.dummyVar = false;
            ext.prId= PR_Header.Id; 
            ext.init();   
            ext.getapprovalDetails();
            
            
        }
    }
    static testMethod void PR_PDF_Test_1(){                                 //Test: ASI_MFM_KR_PR_PDF_PageController
        
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        
        
        System.runAs(u){ 
            
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Purchase_Request__c'); 
            rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KR_Warehouse'),Name='Name1',ASI_MFM_Address_Line_1__c = '1', ASI_MFM_Address_Line_2__c = '2',
                                       ASI_MFM_Address_Line_3__c = '3', ASI_MFM_Address_Line_4__c = '4');          
            insert acc1;
            
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042',ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                                                        ASI_MFM_Start_Date__c = date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = createPrefixPlan().id,  
                                                        ASI_MFM_Status__c='Draft',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
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
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            plan1.ASI_MFM_Status__c = 'Approved';
            plan1.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only');
            update plan1;
            
            
            //Budget Checking for Plan
          //  ASI_MFM_KR_Budget_Setting__c BudgetCheck = new ASI_MFM_KR_Budget_Setting__c(Name='123',ASI_MFM_Budget_Type__c = 'LE1', ASI_MFM_Activation_Time__c = date.today().adddays(-5));
            //insert BudgetCheck;
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = getFiscalYear(),
                                                             ASI_MFM_P3_Amount__c = 100,
                                                             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget'));
            insert Budget;
            
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Draft',
                                                                                     ASI_MFM_Prefix__c = createPrefixPR().id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request'));
            
            insert PR_Header;    
            
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today());
            insert PR_Line;
            
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=PR_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth1; 
            
            ASI_MFM_KR_PR_PDF_PageController ext = new ASI_MFM_KR_PR_PDF_PageController(new ApexPages.StandardController(PR_Header));
            ext.dummyVar = false;
            ext.prId= PR_Header.Id; 
            ext.init();   
            ext.getapprovalDetails();
            
            
        }
    }
    
    static testMethod void PO_PDF_Test(){                                 //Test: ASI_MFM_KR_PO_PDF_PageController && ASI_MFM_KR_PO_TriggerClass
        
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
                                                        ASI_MFM_Start_Date__c = date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
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
            
            
            
            Test.startTest();
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
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
            
              
            
            System.debug(Limits.getDMLRows());
            ASI_MFM_KR_PO_PDF_PageController ext = new ASI_MFM_KR_PO_PDF_PageController(new ApexPages.StandardController(po));
            
            ext.POID= po.Id; 
            ext.dummyVar = ext.init();
            test.stopTest(); 
            
            
        }
    }
    
    /*---------------------------------------------Test Payment PDF: ASI_MFM_KR_Payment_PDF_PageController -----------------------------------------------------------*/
     static testMethod void Payment_PDF_Test(){
         
         //USER ROLE:
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        //USER:
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR';
        u.ASI_KOR_User_Branch_Code__c = '555';
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
            
            ASI_TnE_Branch_Channel__c Branch = new ASI_TnE_Branch_Channel__c(Name = '55555',ASI_TnE_Branch_Default__c = TRUE, recordTypeid =Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'));
            
            insert Branch;
            
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
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'JA11',//Name = 'Tax Code',// 20180208 introv 
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100,
                                                                   ASI_MFM_Tax_Expl_Code__c = 'E');
            insert TaxCode;  
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_Pre_payment__c = true,
                                                                      ASI_MFM_Tax_Code__c=TaxCode.id,
                                                                      ASI_MFM_KR_TotalPayAmtIncludeVAT__c=100);//20180208 introv
            
            insert PaymentHeader;
            
         Test.startTest();      
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 100,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                        ASI_MFM_KR_subLedger__c =Branch.id );
            insert PaymentLine;
                 

            /*---------------------------------------------Start Test-----------------------------------------------------------*/
       
            System.debug(Limits.getDMLRows());        // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(PaymentHeader.id);
            req1.setSubmitterId(u.Id); 
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approved');//     Reject
            req2.setNextApproverIds(new Id[] {u.id});
           
            if(result.getNewWorkitemIds().size()>0){
                req2.setWorkitemId(result.getNewWorkitemIds().get(0));
                Approval.process(req2);
            }
            
            
            PageReference pageRef = Page.ASI_MFM_KR_Payment_PDF_Page;
            pageRef.getParameters().put('Id', PaymentHeader.Id);
            Test.setCurrentPage(pageRef);
            
            ASI_MFM_KR_Payment_PDF_PageController ext = new ASI_MFM_KR_Payment_PDF_PageController(new ApexPages.StandardController(PaymentHeader));
            ext.paymentID= PaymentHeader.Id; 
            ext.dummyVar = ext.init();
            ext.init();
            ext.getapprovalDetails();
            
        test.stopTest(); 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }    
     }
     
     
     /*---------------------------------------------Test Payment PDF: ASI_MFM_KR_Payment_PDF_PageController -----------------------------------------------------------*/
     static testMethod void Payment_PDF_Test_2(){
         
         //USER ROLE:
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        //USER:
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR';
        u.ASI_KOR_User_Branch_Code__c = '555';
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
            
            ASI_TnE_Branch_Channel__c Branch = new ASI_TnE_Branch_Channel__c(Name = '55555',ASI_TnE_Branch_Default__c = TRUE, recordTypeid =Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'));
            
            insert Branch;
            
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
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_Pre_payment__c = false);
            
            insert PaymentHeader;
            
         Test.startTest();      
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 100,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                        ASI_MFM_KR_subLedger__c =Branch.id );
            insert PaymentLine;
                 

            /*---------------------------------------------Start Test-----------------------------------------------------------*/
       
            System.debug(Limits.getDMLRows());        // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(PaymentHeader.id);
            req1.setSubmitterId(u.Id); 
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approved');//     Reject
            req2.setNextApproverIds(new Id[] {u.id});
           
            if(result.getNewWorkitemIds().size()>0){
                req2.setWorkitemId(result.getNewWorkitemIds().get(0));
                Approval.process(req2);
            }
            
            
            PageReference pageRef = Page.ASI_MFM_KR_Payment_PDF_Page;
            pageRef.getParameters().put('Id', PaymentHeader.Id);
            Test.setCurrentPage(pageRef);
            
            ASI_MFM_KR_Payment_PDF_PageController ext = new ASI_MFM_KR_Payment_PDF_PageController(new ApexPages.StandardController(PaymentHeader));
            ext.paymentID= PaymentHeader.Id; 
            ext.dummyVar = ext.init();
            ext.init();
            ext.getapprovalDetails();
            
        test.stopTest(); 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }    
     }
         /*---------------------------------------------Test Payment PDF: ASI_MFM_KR_Payment_TriggerClass -----------------------------------------------------------*/
     static testMethod void Payment_Trigger_Test(){
         
         //USER ROLE:
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        //USER:
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR';
        u.ASI_KOR_User_Branch_Code__c = '555';
        update u;
        
        System.runAs(u){ 
         
            String FiscalYear = getFiscalYear();
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'JA11',//Name = 'Tax Code',// 20180208 introv 
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100,
                                                                    ASI_MFM_Tax_Expl_Code__c = 'E');
            insert TaxCode;  
            
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
            
            ASI_TnE_Branch_Channel__c Branch = new ASI_TnE_Branch_Channel__c(Name = '55555',ASI_TnE_Branch_Default__c = TRUE, recordTypeid =Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'));
            
            insert Branch;
            
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
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_Pre_payment__c = true,
                                                                      ASI_MFM_Tax_Code__c=TaxCode.id,
                                                                      ASI_MFM_KR_TotalPayAmtIncludeVAT__c=100);//20180208 introv
            
            insert PaymentHeader;
            
            
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 100,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_KR_subLedger__c =Branch.id );
            insert PaymentLine;
                 
           PaymentHeader.ASI_MFM_Status__c = 'Submitted';
           update PaymentHeader;
                 
           PaymentHeader.ASI_MFM_Status__c = 'Approved';
           PaymentHeader.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment_Read_Only');
           update PaymentHeader;
           
         Test.stopTest();
        }    
     }
      /*---------------------------------------------Test: ASI_MFM_KR_Approver_CommentController -----------------------------------------------------------*/
     static testMethod void ASI_MFM_KR_Approver_CommentController_Test(){
         
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR';
        u.ASI_KOR_User_Branch_Code__c = '555';
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
            
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_PO__c = po.id);
            
            insert PaymentHeader;
            
         Test.startTest();      
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 100,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id);
            insert PaymentLine;
                 
            ProcessInstanceHistory processInstanceTest = new ProcessInstanceHistory();
           //INSERT processInstanceTest;
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(PaymentHeader.id);
            req1.setSubmitterId(u.Id); 
            //req1.setNextApproverIds(new Id[] {userinfo.getUserId()}); 
            //req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
            
            //System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
            
             // First, get the IDs for the WorkItems 
            List<Id> newWorkItemIds = new List<Id>();
            for (List<ProcessInstance> pis : [Select (Select Id From Workitems) From ProcessInstance p WHERE p.TargetObjectId =: PaymentHeader.id]) {
                for (ProcessInstance pi : pis) {
                    for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
                        for (ProcessInstanceWorkitem wi : wis ) {
                            newWorkItemIds.add(wi.id);
                            system.assertEquals(newWorkItemIds,null);
                        }
                    }           
                }
            }
        
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approved');//     Reject
            req2.setWorkitemId(PaymentHeader.id);
            //req2.setNextApproverIds(new Id[] {u.id});
            req2.setNextApproverIds(new Id[] {userinfo.getUserId()}); 
            
            if(result.getNewWorkitemIds().size()>0){
                //req2.setWorkitemId(result.getNewWorkitemIds().get(0));
                req2.setWorkitemId(newWorkItemIds.get(0));
                //Approval.process(req2);
                Approval.ProcessResult result2 =  Approval.process(req2);
            }
            
            
            //System.debug(Limits.getDMLRows());        // Create an approval request for the account
           
   
            PageReference pageRef = Page.ASI_MFM_KR_Payment_PDF_Page;
            pageRef.getParameters().put('Id', PaymentHeader.Id);
            Test.setCurrentPage(pageRef);
            
            ASI_MFM_KR_Approver_CommentController ext = new ASI_MFM_KR_Approver_CommentController();
            ASI_MFM_KR_Approver_CommentController.approvalDetail ad= new ASI_MFM_KR_Approver_CommentController.approvalDetail();
            ad.title ='title';
            ad.status = 'Pending';
            ad.history = processInstanceTest;
            ext.currentHeaderId= PaymentHeader.Id; 
            //ext.dummyVar = ext.init();
            //ext.init();
            ext.getapprovalDetails();
            
        test.stopTest(); 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }    
     }
     
      /*---------------------------------------------Test: ASI_MFM_KR_PaymentLineItem_TriggerClass -----------------------------------------------------------*/
     static testMethod void ASI_MFM_KR_PaymentLineItem_TriggerClass_Test(){
         
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
            
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_PO__c = po.id);
            
            insert PaymentHeader;
            
            ASI_MFM_Payment__c PaymentHeader1 = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_PO__c = po.id
                                                                      );
            
            insert PaymentHeader1;
            
            Test.startTest();      
                        
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 50,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id);
            insert PaymentLine;
            
            ASI_MFM_Payment_Line_Item__c PaymentLine1 = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                          ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                          ASI_MFM_Payment_Amount__c = 50,
                                                                                          ASI_MFM_Cashout_Payment_Number__c = PaymentHeader1.id,
                                                                                          ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                          ASI_MFM_PO_Line_Item__c = po_line.id);
            insert PaymentLine1;
            
            
            
           
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
       
            System.debug(Limits.getDMLRows());        // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(PaymentHeader.id);
            req1.setSubmitterId(u.Id); 
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approved');//     Reject
            req2.setNextApproverIds(new Id[] {u.id});
           
            if(result.getNewWorkitemIds().size()>0){
                req2.setWorkitemId(result.getNewWorkitemIds().get(0));
                Approval.process(req2);
            }
            
            
            PageReference pageRef = Page.ASI_MFM_KR_Payment_PDF_Page;
            pageRef.getParameters().put('Id', PaymentHeader.Id);
            Test.setCurrentPage(pageRef);
            
            ASI_MFM_KR_Approver_CommentController ext = new ASI_MFM_KR_Approver_CommentController();
            ext.currentHeaderId= PaymentHeader.Id; 
            //ext.dummyVar = ext.init();
            //ext.init();
            ext.getapprovalDetails();
            
        test.stopTest(); 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }    
     }
     
    /*---------------------------------------------Test: ASI_MFM_KR_PaymentLineItem_TriggerClass -----------------------------------------------------------*/
     static testMethod void ASI_MFM_KR_PaymentLineItem_TriggerClass_Test1(){
         
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
            
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_PO__c = po.id);
            
            insert PaymentHeader;
            
            ASI_MFM_Payment__c PaymentHeader1 = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_PO__c = po.id
                                                                      );
            
            insert PaymentHeader1;
            
            Test.startTest();      
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                         ASI_MFM_Status__c = 'Draft',
                                                                         recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
            
            
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_Amount__c = 1,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            insert POR_Line;
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 50,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                         ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
            
            ASI_MFM_Payment_Line_Item__c PaymentLine1 = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                          ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                          ASI_MFM_Payment_Amount__c = 50,
                                                                                          ASI_MFM_Cashout_Payment_Number__c = PaymentHeader1.id,
                                                                                          ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                          ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                          ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine1;
            
            
            
           
            /*---------------------------------------------Start Test-----------------------------------------------------------*/
       
            System.debug(Limits.getDMLRows());        // Create an approval request for the account
            
            
            test.stopTest(); 
            /*---------------------------------------------End Test-----------------------------------------------------------*/
        }    
     }

}