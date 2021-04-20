@isTest
private class ASI_MFM_KR_Toolbar_TestClass {

    //testing data setup for all methods in this class
    @testSetup static void setupCommonData(){
            //-------------------------------------------------- Fiscal Year Setup ----------------------------------------------------------//
        String fiscalYear = getFiscalYear();
        
            //-------------------------------------------------- User Setup ----------------------------------------------------------//
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c ='Brand Marketing';
        update u;
        
        system.debug('u contains ' + u);
        
        System.runAs(u){ 

            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',
                                       ASI_MFM_Address_Line_1__c = '1',
                                       ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            
            //-------------------------------------------------- Budget Setup ----------------------------------------------------------//
            
            List<ASI_MFM_Budget_Setup__c> NewRecord = new List<ASI_MFM_Budget_Setup__c>();
            
            ASI_MFM_Budget_Setup__c Budget_Budget = new ASI_MFM_Budget_Setup__c(//ASI_MFM_Start_Date__c= (date.today()).adddays(-50),
                ASI_MFM_Type__c = 'Budget',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),
                ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE1 = new ASI_MFM_Budget_Setup__c(//ASI_MFM_Start_Date__c= (date.today()).adddays(-40),
                ASI_MFM_Type__c = 'LE1',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),
                ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE2 = new ASI_MFM_Budget_Setup__c(//ASI_MFM_Start_Date__c= (date.today()).adddays(-30),
                ASI_MFM_Type__c = 'LE2',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),
                ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE3 = new ASI_MFM_Budget_Setup__c(//ASI_MFM_Start_Date__c= (date.today()).adddays(-20),
                ASI_MFM_Type__c = 'LE3',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),
                ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE4 = new ASI_MFM_Budget_Setup__c(//ASI_MFM_Start_Date__c= (date.today()).adddays(-10),
                ASI_MFM_Type__c = 'LE4',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),
                ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            
            NewRecord.add(Budget_Budget);
            NewRecord.add(Budget_LE1);
            NewRecord.add(Budget_LE2);
            NewRecord.add(Budget_LE3);
            NewRecord.add(Budget_LE4);
            insert NewRecord;
            
            //-------------------------------------------------- AP Code Setup Setup ----------------------------------------------------------//

            List<ASI_MFM_AP_Code__c> APCode_List = new List<ASI_MFM_AP_Code__c>();
            ASI_MFM_AP_Code__c	AP_Code_Media1 = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code1', 
                                                                 Name = 'AP Code Test1',
                                                                 ASI_MFM_AP_Type__c = 'Media A&P',
                                                                 ASI_MFM_PRPO_Needed__c=true,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            APCode_List.add(AP_Code_Media1);
            
            ASI_MFM_AP_Code__c	AP_Code_Media2 = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code2', 
                                                                 Name = 'AP Code Test2',
                                                                 ASI_MFM_AP_Type__c = 'Media A&P',
                                                                 ASI_MFM_PRPO_Needed__c=true,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            APCode_List.add(AP_Code_Media2);
            
            ASI_MFM_AP_Code__c	AP_Code_Other1 = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code3', 
                                                                 Name = 'AP Code Test3',
                                                                 ASI_MFM_AP_Type__c = 'Other A&P',
                                                                 ASI_MFM_PRPO_Needed__c=true,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            APCode_List.add(AP_Code_Other1);
            
            insert APCode_List;
            
            //-------------------------------------------------- Prefix  ----------------------------------------------------------//
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan'
                    //ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            Prefix_List.add(prefixKR_PLAN);
            
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
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
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
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Plan); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;            
            
            
            //-------------------------------------------------- Approval Process ----------------------------------------------------------//
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //-------------------------------------------------- BrandGroup, Brand, SubBrand----------------------------------------------------------//
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
            
            //-------------------------------------------------- Plan/PR/PO/Payment Setup----------------------------------------------------------//
            
            List<ASI_MFM_Plan__c> plan_List = new List<ASI_MFM_Plan__c>();
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test_Plan1',
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',
                                                        OwnerId =u.id
                                                        );
           
                
            plan_List.add(plan1);
           
            
            ASI_MFM_Plan__c plan2 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Closed',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
                                                        
            plan_List.add(plan2);
        
            try{
                insert plan_List;
            }catch(exception ex){
                system.debug(ex.getMessage());
            }
            
            system.debug('plan_list insert :' + plan_List);
            
            List<ASI_MFM_Plan_Line_Item__c> planLine_List = new List<ASI_MFM_Plan_Line_Item__c>();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan_List[0].ID,
                                                                                 ASI_MFM_Actual_Spending_Amount__c=0,
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
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.Id,
                                                                                 ASI_MFM_AP_Code__c = APCode_List[0].Id, //Media A&P
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            planLine_List.add( planLine1);
  
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan_List[1].ID,
                                                                                 ASI_MFM_Actual_Spending_Amount__c=0,
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
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.Id,
                                                                                 ASI_MFM_AP_Code__c = APCode_List[0].Id, //Media A&P
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
 
            planLine_List.add( planLine2);
            
            insert planLine_List; 

            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan_List[0].id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine_List[0].id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;

            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Draft',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan_List[0].id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 ASI_MFM_Warehouse__c = acc1.id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           ASI_MFM_Plan_Line_Item__c =  planLine_List[0].id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;


            
            
        }
        
        
    }
    
    
    
    static ASI_MFM_PO__c testDataGeneratePO(Id PrefixId, Id PlanId, String POStatus){

            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',
                                       ASI_MFM_Address_Line_1__c = '1',
                                       ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
  
          
            List<ASI_MFM_Plan_Line_Item__c> planLine_List = [Select id from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: PlanId];
                    
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = AccountList[1].Id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = POStatus,
                                                 ASI_MFM_Prefix__c = PrefixId,
                                                 ASI_MFM_Plan__c = PlanId,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 ASI_MFM_Warehouse__c =AccountList[0].Id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           ASI_MFM_Plan_Line_Item__c =  planLine_List[0].id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today()
                                                                          );
            
            insert po_line;
            
            return PO; 
    }    
    
    
    

       @isTest static void ASI_MFM_KR_PlanToolBarController_Test1(){
            //-------------------------------------------------- Fiscal Year Setup ----------------------------------------------------------//
            String fiscalYear = getFiscalYear();
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
            u.CompanyName = 'Pernod Ricard Korea';
            u.ASI_MFM_Country__c  = 'KR';
            u.ASI_MFM_Team__c ='Brand Marketing';
            update u;
            
            system.debug('ASI_MFM_KR_PlanToolBarController_Test1 contains ' + u);
            
            System.runAs(u){ 
                
                //KR_Test001 is generated by prefix 
                ASI_MFM_Plan__c queryRecord = [Select id, Name from ASI_MFM_Plan__c where name='KR_Test001' limit 1]; 
                System.assertNotEquals(null, queryRecord);
                
                Test.startTest();
                System.debug(Limits.getDMLRows());                 
        		
        		PageReference pageRef = Page.ASI_MFM_KR_Plan_PlanToolBarPage; //create a page reference to yourVisualforcePage.page
        		Test.setCurrentPage(pageRef); //set page context  
        		ApexPages.StandardController standardController = new ApexPages.standardController(queryRecord); //construct the standard account object controller
        		ASI_MFM_KR_PlanToolBarController pageExt = new ASI_MFM_KR_PlanToolBarController(standardController);   
        		pageExt.overBudget = false; 
        		pageExt.needAttachment = false;
                pageExt.init();
                
                test.stopTest(); 
                
                
            }        
        }



        
       @isTest static void ASI_MFM_KR_PlanBudgetCheckingCtrl_Test1(){
            //-------------------------------------------------- Fiscal Year Setup ----------------------------------------------------------//
            String fiscalYear = getFiscalYear();
            user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
            u.CompanyName = 'Pernod Ricard Korea';
            u.ASI_MFM_Country__c  = 'KR';
            u.ASI_MFM_Team__c ='Brand Marketing';
            update u;
            
            system.debug('ASI_MFM_KR_PlanBudgetCheckingCtrl_Test1 contains ' + u);

            
            System.runAs(u){ 
                
                //KR_Test001 is generated by prefix 
                ASI_MFM_Plan__c queryRecord = [Select id, Name from ASI_MFM_Plan__c where name='KR_Test001' limit 1]; 
                System.assertNotEquals(null, queryRecord);
                
                //Query Sub-Brand
                ASI_MFM_Sub_brand__c querySubBrand = [Select id, Name from ASI_MFM_Sub_brand__c where name='TestSubBrand' limit 1]; 
                System.assertNotEquals(null, querySubBrand);
                
                //Query Project Code
                ASI_MFM_Project_Code__c queryProjectCode = [Select id, name from ASI_MFM_Project_Code__c where name ='PJ Code' limit 1];
                System.assertNotEquals(null, queryProjectCode);
                
                //Insert Budget 
                List<ASI_MFM_Budget__c> Budget_List = new List<ASI_MFM_Budget__c>();
                ASI_MFM_Budget__c Budget1 = new ASI_MFM_Budget__c(  
                                                                    ASI_MFM_Type__c = 'Budget',
                                                                    ASI_MFM_Budget_Type__c = 'NORM',
                                                                    ASI_MFM_Code__c = queryProjectCode.Id,
                                                                    ASI_MFM_Sub_brand_Code__c = querySubBrand.Id, 
                                                                    ASI_MFM_KR_AP_Type__c = 'Media A&P',
                                                                    ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget')
                                                                 );

                Budget_List.add(Budget1);
                ASI_MFM_Budget__c Budget2 = new ASI_MFM_Budget__c(  
                                                                    ASI_MFM_Type__c = 'LE1',
                                                                    ASI_MFM_Budget_Type__c = 'NORM',
                                                                    ASI_MFM_Code__c = queryProjectCode.Id,
                                                                    ASI_MFM_Sub_brand_Code__c = querySubBrand.Id, 
                                                                    ASI_MFM_KR_AP_Type__c = 'Media A&P',
                                                                    ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget')
                                                                 );

                Budget_List.add(Budget2);
                ASI_MFM_Budget__c Budget3 = new ASI_MFM_Budget__c(  
                                                                    ASI_MFM_Type__c = 'LE2',
                                                                    ASI_MFM_Budget_Type__c = 'NORM',
                                                                    ASI_MFM_Code__c = queryProjectCode.Id,
                                                                    ASI_MFM_Sub_brand_Code__c = querySubBrand.Id, 
                                                                    ASI_MFM_KR_AP_Type__c = 'Media A&P',
                                                                    ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget')
                                                                 );

                Budget_List.add(Budget3);
                ASI_MFM_Budget__c Budget4 = new ASI_MFM_Budget__c(  
                                                                    ASI_MFM_Type__c = 'LE3',
                                                                    ASI_MFM_Budget_Type__c = 'NORM',
                                                                    ASI_MFM_Code__c = queryProjectCode.Id,
                                                                    ASI_MFM_Sub_brand_Code__c = querySubBrand.Id, 
                                                                    ASI_MFM_KR_AP_Type__c = 'Media A&P',
                                                                    ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget')
                                                                 );

                Budget_List.add(Budget4);

                ASI_MFM_Budget__c Budget5 = new ASI_MFM_Budget__c(  
                                                                    ASI_MFM_Type__c = 'LE4',
                                                                    ASI_MFM_Budget_Type__c = 'NORM',
                                                                    ASI_MFM_Code__c = queryProjectCode.Id,
                                                                    ASI_MFM_Sub_brand_Code__c = querySubBrand.Id, 
                                                                    ASI_MFM_KR_AP_Type__c = 'Media A&P',
                                                                    ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget')
                                                                 );

                Budget_List.add(Budget5);
                
                insert Budget_List; 

                //KR_Test001 is generated by prefix 
                ASI_MFM_Plan__c queryClosedPlan = [Select id, Name from ASI_MFM_Plan__c where name='KR_Test002' limit 1]; 
                System.assertNotEquals(null, queryClosedPlan);
                

                Test.startTest();
                System.debug(Limits.getDMLRows());                 
        		
                //Insert PO 
                ASI_MFM_Prefix__c POPrefix = [Select id from ASI_MFM_Prefix__c where ASI_MFM_Module__c = 'PO' and ASI_MFM_Fiscal_year__c =: fiscalYear limit 1];
                System.assertNotEquals(null, POPrefix);
                ASI_MFM_PO__c testApprovedPO  = testDataGeneratePO(POPrefix.Id, queryClosedPlan.Id, 'Approved');
                
        		PageReference pageRef = Page.ASI_MFM_KR_PlanBudgetCheckingVFP; //create a page reference to yourVisualforcePage.page
        		Test.setCurrentPage(pageRef); //set page context  
        		ApexPages.StandardController standardController = new ApexPages.standardController(queryRecord); //construct the standard account object controller
        		ASI_MFM_KR_PlanBudgetCheckingCtrl pageExt = new ASI_MFM_KR_PlanBudgetCheckingCtrl(standardController);   
                ASI_MFM_KR_PlanBudgetCheckingCtrl.wrapperClass resultWrapper = new ASI_MFM_KR_PlanBudgetCheckingCtrl.wrapperClass();
                resultWrapper =  ASI_MFM_KR_PlanBudgetCheckingCtrl.getresultSetByPlanId(String.valueOf(queryRecord.Id)); 
                 
                test.stopTest(); 
                
                
            }        
        }
        
    /*---------------------------------------------Fiscal Year Method -----------------------------------------------------------*/
    public static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1  + 50 ;
        Integer yearA2 = Integer.valueOf(yearA1) +1   + 50;
        String Current_Fiscal_year;
        
        Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        /*
        if(system.today()< orgFiscalYear){
        Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
        Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        */
        return Current_Fiscal_year;
    }
    


}