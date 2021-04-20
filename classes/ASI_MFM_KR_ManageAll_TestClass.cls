/*
Test:
- ASI_MFM_KR_PlanManageAllController

- ASI_MFM_KR_PRManageAllController
- ASI_MFM_KR_POManageAllController
- ASI_MFM_KR_PaymentManageAllController
- ASI_MFM_KR_POReceiptManageAllCtrler

- ASI_MFM_KR_DirectPaymentCtler
- ASI_MFM_KR_MakePaymentRedirectController
- ASI_MFM_KR_PORC_Controller
- ASI_MFM_KR_FV_Controller
*/

@istest
public class ASI_MFM_KR_ManageAll_TestClass {
    
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

    
    
    
    
    
     
    static testMethod void ASI_MFM_SetPlanStatusSG_TEST() {
        // Test      ASI_MFM_Payment_TriggerClass
        
        
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), recordTypeId = pxrt_map.get('ASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Exchange_Rate__c=1, ASI_MFM_Application__c = 'MFM', ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='SGD',ASI_MFM_Country__c='SG');
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name3'); // ASI_CRM_SG_Supplier          
        accList.add(acc3);
        
        insert accList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        //--------------------Change-----------------------
        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        //--------------------Change End-----------------------
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
       
        
      
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
            
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Draft');
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p1));
        ext.setStatus();
        test.stopTest();
      
    }
    
    
    
    
    
  static testMethod void ASI_MFM_SelectPaymentPrefixTest() {   
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'KR';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
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
            
  
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear() );
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_Payment_Request__c = 'true',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c =date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
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
            
            List<ASI_MFM_Purchase_Request_Line__c> PRList = new List<ASI_MFM_Purchase_Request_Line__c>();
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            PRList.add(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                              ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                              ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                              ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                              ASI_MFM_Quantity__c = 10,
                                                                                              ASI_MFM_UOM__c = 'EA',
                                                                                              ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                              ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                              ASI_MFM_Delivery_Date__c= date.today(),
                                                                                              ASI_MFM_Description__c = 'Description',
                                                                                              ASI_MFM_Unit_Cost__c = 100);
            PRList.add(PR_Line2);
            insert PRList;    
            
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;
            System.debug('Before start test1(SetPrefix): Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            Test.startTest();  
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                         ASI_MFM_Status__c = 'Draft',
                                                                         recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
            
            LIST<ASI_MFM_PO_Receipt_Item__c> PORList = NEW LIST<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_Amount__c = 1,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line);
            
            ASI_MFM_PO_Receipt_Item__c POR_Line2 = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                   ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                   ASI_MFM_Quantity__c = 1,
                                                                                   ASI_MFM_PO__c = po.id,
                                                                                   ASI_MFM_Paid__c = false,
                                                                                   ASI_MFM_Amount__c = 1,
                                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line2);
            INSERT PORList;
            
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc2.id,
                                                                       ASI_MFM_PO__c = po.id,
                                                                       ASI_MFM_Company_Code__c = '222',
                                                                       ASI_MFM_Send_Approval_Email__c=true);  
            
            insert PaymentHeader;
                  
            System.debug('After start test1 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                         ASI_MFM_Beneficiary_Customer__c = customer1.id,
                                                                                         ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
            
            
            PageReference PaymentPrefixPage = Page.ASI_MFM_SelectPaymentPrefixPage;
            Test.setCurrentPage(PaymentPrefixPage);
            ApexPages.currentPage().getParameters().put('RecordType', String.valueof(PaymentHeader.recordtypeid).substring(0,15));
            ApexPages.currentPage().getParameters().put('id', PaymentHeader.id);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PaymentHeader);        
            ASI_MFM_SelectPaymentPrefixController SelectPaymentPrefixController = new ASI_MFM_SelectPaymentPrefixController(stdController);
            System.debug('After start test2 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            SelectPaymentPrefixController.getPrefixes();
            SelectPaymentPrefixController.proceed();
            System.debug('After start test3 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            test.stopTest();
            
        }
    } 
    
    
    /*static testMethod void ASI_MFM_SetPlanStatusGF1() {
                
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;        
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert sub;
        
        test.startTest();
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='Sponsorship [Media]', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_GF_A_C_Code'));
        insert ac;
                
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        insert acctList;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = sub.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription',
                                                                     ASI_MFM_Month_1_Cost__c = 10, ASI_MFM_Month_2_Cost__c = 10, ASI_MFM_Month_3_Cost__c = 10, ASI_MFM_Month_4_Cost__c = 10, ASI_MFM_Month_5_Cost__c = 10, ASI_MFM_Month_6_Cost__c = 10, 
                                                                     ASI_MFM_Month_7_Cost__c = 10, ASI_MFM_Month_8_Cost__c = 10, ASI_MFM_Month_9_Cost__c = 10, ASI_MFM_Month_10_Cost__c = 10, ASI_MFM_Month_11_Cost__c = 10, ASI_MFM_Month_12_Cost__c = 10);   
        insert pi;  
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c = 'Draft', ASI_MFM_PO_Type__c = 'Event FOC'); 
        insert po;
        
       
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='Sponsorship [Media]', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_GF_AP_Code'), ASI_MFM_A_C_Code__c=ac.Id);
        insert ap;
      
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PlanDetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Draft');
        ASI_MFM_SetPlanStatusController ext = new ASI_MFM_SetPlanStatusController(new ApexPages.StandardController(p));
        ext.setStatus();
        
        
        test.stopTest();
    }*/
    
    static testMethod void PaymentManageAll3_Test() {   
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'KR';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
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
            
  
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_Payment_Request__c = 'true',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c =date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
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
            
            List<ASI_MFM_Purchase_Request_Line__c> PRList = new List<ASI_MFM_Purchase_Request_Line__c>();
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            PRList.add(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                              ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                              ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                              ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                              ASI_MFM_Quantity__c = 10,
                                                                                              ASI_MFM_UOM__c = 'EA',
                                                                                              ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                              ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                              ASI_MFM_Delivery_Date__c= date.today(),
                                                                                              ASI_MFM_Description__c = 'Description',
                                                                                              ASI_MFM_Unit_Cost__c = 100);
            PRList.add(PR_Line2);
            insert PRList;    
            
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;
            System.debug('Before start test(ManageAll3): Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            Test.startTest();
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                         ASI_MFM_Status__c = 'Draft',
                                                                         recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
            
            LIST<ASI_MFM_PO_Receipt_Item__c> PORList = NEW LIST<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_Amount__c = 1,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line);
            
            ASI_MFM_PO_Receipt_Item__c POR_Line2 = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                   ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                   ASI_MFM_Quantity__c = 1,
                                                                                   ASI_MFM_PO__c = po.id,
                                                                                   ASI_MFM_Paid__c = false,
                                                                                   ASI_MFM_Amount__c = 1,
                                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line2);
            INSERT PORList;
            
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc2.id,
                                                                       ASI_MFM_PO__c = po.id,
                                                                       ASI_MFM_Company_Code__c = '222',
                                                                       ASI_MFM_Send_Approval_Email__c=true);  
            
            
            insert PaymentHeader;
            
            System.debug('After start test1 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                         ASI_MFM_Beneficiary_Customer__c = customer1.id,
                                                                                         ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
                       
            System.debug('After start test2 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            List<ASI_MFM_Payment__c> PaymentSet = new List<ASI_MFM_Payment__c>();
            PaymentSet.add(PaymentHeader);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PaymentSet);
            
            PageReference ManageAllPage = Page.asi_mfm_kr_paymentmanageallpage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            
  
            //pageParams.put('id', PR_Header.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PaymentHeader);        
            
            ASI_MFM_KR_PaymentManageAllController ManageAllController = new ASI_MFM_KR_PaymentManageAllController(stdController);
            
            System.debug('After start test2 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            //Test function
            ManageAllController.init();
            ManageAllController.addallLineItem();
            /*
            System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)PaymentLine.id);
            ManageAllController.cloneLine(); 
            
              System.currentPageReference().getParameters().put('PARAM_PAYLine_ID', (String)PaymentLine.id);
            ManageAllController.removePaymentLine();
            
            //ManageAllController.saveLinetems();
            ManageAllController.onCommitted();  
      */
      
            System.currentPageReference().getParameters().put('PARAM_PORLINE_SOURCE_ITEM_ID', (String)POR_Line.id);
            ManageAllController.addLineItem(); 
            
            System.currentPageReference().getParameters().put('PARAM_PORLINE_SOURCE_ITEM_ID', (String)POR_Line2.id);
            ManageAllController.addLineItem(); 
            
            ManageAllController.retrieveExchangeRate();
            
          
            
            ManageAllController.saveLinetems();
            ManageAllController.onCommitted();
      
            System.currentPageReference().getParameters().put('PARAM_PAYLine_ID', (String)PaymentLine.id);
            ManageAllController.removePaymentLine();
            
            ManageAllController.cancel();    
            /*
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_PaymentManageAllController.findCustomers('Account','WHERE RecordType.DeveloperName != null');  
            List<ASI_MFM_Payment_Line_Item__c> remo5= ASI_MFM_KR_PaymentManageAllController.PaymentLineItems(PaymentHeader.id);   
            String[] remo6= ASI_MFM_KR_PaymentManageAllController.findSObjects('Account','WHERE RecordType.DeveloperName != null'); 
            */
            
            System.debug('After start test3 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            test.stopTest(); 
            
            
        }
    } 
    
    static testMethod void PaymentManageAll2_Test() {   
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'KR';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
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
            
  
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_Payment_Request__c = 'true',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c =date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
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
            
            List<ASI_MFM_Purchase_Request_Line__c> PRList = new List<ASI_MFM_Purchase_Request_Line__c>();
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            PRList.add(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                              ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                              ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                              ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                              ASI_MFM_Quantity__c = 10,
                                                                                              ASI_MFM_UOM__c = 'EA',
                                                                                              ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                              ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                              ASI_MFM_Delivery_Date__c= date.today(),
                                                                                              ASI_MFM_Description__c = 'Description',
                                                                                              ASI_MFM_Unit_Cost__c = 100);
            PRList.add(PR_Line2);
            insert PRList;    
            
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;
            System.debug('Before start test(ManageAll2): Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            Test.startTest();
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                         ASI_MFM_Status__c = 'Draft',
                                                                         recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
            
            LIST<ASI_MFM_PO_Receipt_Item__c> PORList = NEW LIST<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_Amount__c = 1,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line);
            
            ASI_MFM_PO_Receipt_Item__c POR_Line2 = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                   ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                   ASI_MFM_Quantity__c = 1,
                                                                                   ASI_MFM_PO__c = po.id,
                                                                                   ASI_MFM_Paid__c = false,
                                                                                   ASI_MFM_Amount__c = 1,
                                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line2);
            INSERT PORList;
            
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc2.id,
                                                                       ASI_MFM_PO__c = po.id,
                                                                       ASI_MFM_Company_Code__c = '222',
                                                                       ASI_MFM_Send_Approval_Email__c=true);  
            
            
            insert PaymentHeader;
            
            System.debug('After start test1 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                         ASI_MFM_Beneficiary_Customer__c = customer1.id,
                                                                                         ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
                       
            
            List<ASI_MFM_Payment__c> PaymentSet = new List<ASI_MFM_Payment__c>();
            PaymentSet.add(PaymentHeader);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PaymentSet);
            
            PageReference ManageAllPage = Page.asi_mfm_kr_paymentmanageallpage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            
  
            //pageParams.put('id', PR_Header.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PaymentHeader);        
            
            ASI_MFM_KR_PaymentManageAllController ManageAllController = new ASI_MFM_KR_PaymentManageAllController(stdController);
            System.debug('After start test2 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            //Test function
            ManageAllController.init();
            ManageAllController.addallLineItem();
            
            System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)PaymentLine.id);
            ManageAllController.cloneLine(); 
            /*
              System.currentPageReference().getParameters().put('PARAM_PAYLine_ID', (String)PaymentLine.id);
            ManageAllController.removePaymentLine();
            */
            //ManageAllController.saveLinetems();
            ManageAllController.onCommitted();  
      /*
            System.currentPageReference().getParameters().put('PARAM_PORLINE_SOURCE_ITEM_ID', (String)POR_Line.id);
            ManageAllController.addLineItem(); 
            
            System.currentPageReference().getParameters().put('PARAM_PORLINE_SOURCE_ITEM_ID', (String)POR_Line2.id);
            ManageAllController.addLineItem(); 
            
            ManageAllController.retrieveExchangeRate();
            
          
            
            ManageAllController.saveLinetems();
            ManageAllController.onCommitted();

            ManageAllController.cancel();
            */
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_PaymentManageAllController.findCustomers('Account','WHERE RecordType.DeveloperName != null');  
            List<ASI_MFM_Payment_Line_Item__c> remo5= ASI_MFM_KR_PaymentManageAllController.PaymentLineItems(PaymentHeader.id);   
            String[] remo6= ASI_MFM_KR_PaymentManageAllController.findSObjects('Account','WHERE RecordType.DeveloperName != null'); 
            System.debug('After start test3 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
            test.stopTest(); 
            
            
        }
    } 
    
    
       static testMethod void PlanManageAll_Test2() {
        //Test class: ASI_MFM_KR_PlanManageAllController
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_KOR_User_Branch_Code__c ='505';
        u.BypassTriggers__c = 'ASI_MFM_KR_Cross_Fiscal_Year_Checking';//20180208 introv
        update u;
        
        System.runAs(u){ 
            
            ASI_TnE_Branch_Channel__c BrandCode = new ASI_TnE_Branch_Channel__c(Name = 'Test_Branch_Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'));
            insert BrandCode;
                
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan',ASI_MFM_Fiscal_year__c = getFiscalYear());
            insert prefixKR_PLAN;
            
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = r.DeveloperName);
                
            insert rel;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code',  Name = 'AP Code Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
             Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
             Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
             Datetime GMTdate = Datetime.now();
             String yearA1 = GMTdate.format('YY');
             Date StartDate =  Date.newInstance(2000+integer.valueOf(yearA1), 7, 1);
             Date EnDDate =  Date.newInstance(2000+integer.valueOf(yearA1)+1,6,30);
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name = 'Test Plan2',ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),ASI_MFM_Start_Date__c = StartDate,ASI_MFM_End_Date__c =  EnDDate,ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Status__c='Draft',OwnerId =u.id);
               
            insert plan;
            
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),ASI_MFM_List_Item_Description__c = 'test description',ASI_MFM_Total_Cost__c = 1234,ASI_MFM_Plan__c = plan.id,ASI_MFM_KR_subLedger__c = BrandCode.id,ASI_MFM_AP_Code__c = AP_Code.id,ASI_MFM_Sub_brand_Code__c = SubBrand.id);
            insert planLine;
            
            
            List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
            planLineSet.add(planLine);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_PlanManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            Test.startTest();
            
            pageParams.put('id', plan.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            
            ASI_MFM_KR_PlanManageAllController PlanManageAllController = new ASI_MFM_KR_PlanManageAllController(stdController);
            //Test function
            PlanManageAllController.init();
           PlanManageAllController.Recalculate();
            test.stopTest(); 
        }
    }
     
    
     static testMethod void PlanManageAll_Test() {
        //Test class:  ASI_MFM_Plan_TriggerClass      ASI_MFM_PH_InputPlanItemsController
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_KOR_User_Branch_Code__c ='505';
        update u;
        
        System.runAs(u){ 
            
            ASI_TnE_Branch_Channel__c BrandCode = new ASI_TnE_Branch_Channel__c
                (
                    Name = 'Test_Branch_Code',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel')
                );
                insert BrandCode;
                
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            insert prefixKR_PLAN;
            
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c = date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Status__c='Draft',
                    OwnerId =u.id
                );
               
            insert plan;
            
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),
                    ASI_MFM_List_Item_Description__c = 'test description',
                    ASI_MFM_Total_Cost__c = 1234,
                    ASI_MFM_Plan__c = plan.id,
                    ASI_MFM_KR_subLedger__c = BrandCode.id,
                    ASI_MFM_AP_Code__c = AP_Code.id,
                    ASI_MFM_Sub_brand_Code__c = SubBrand.id
                );
            insert planLine;
            
            
            List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
            planLineSet.add(planLine);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_PlanManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            Test.startTest();
            
            pageParams.put('id', plan.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            
            ASI_MFM_KR_PlanManageAllController PlanManageAllController = new ASI_MFM_KR_PlanManageAllController(stdController);
            //Test function
            PlanManageAllController.init();
            PlanManageAllController.Recalculate();
            System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)planLine.id);
            PlanManageAllController.cloneLine();
            PlanManageAllController.SaveItems();
            PlanManageAllController.addLineItem();
            System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)planLine.id);
            PlanManageAllController.removeLine();
            
            //Test RemoteAction
            List<Account> remo= ASI_MFM_KR_PlanManageAllController.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_PH_DF_Customer');
            List<ASI_MFM_AP_Code__c> remo1= ASI_MFM_KR_PlanManageAllController.findList('ASI_MFM_AP_Code__c','ID','WHERE RecordType.DeveloperName != null');
            List<ASI_CRM_AccountsAdditionalField__c> remo2= ASI_MFM_KR_PlanManageAllController.findCustomers('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName = ASI_CRM_KR_Wholesaler');  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_PlanManageAllController.findAPACCodeMap('ASI_MFM_AP_Code__c','WHERE RecordType.DeveloperName != null');   
            
            test.stopTest(); 
        }
    }
    
    static testMethod void PlanManageAll_Test_PlanLineWithoutFields() {
        //Test class:  ASI_MFM_Plan_TriggerClass      ASI_MFM_PH_InputPlanItemsController
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_KOR_User_Branch_Code__c ='505';
        update u;
        
        System.runAs(u){ 
            
            ASI_TnE_Branch_Channel__c BrandCode = new ASI_TnE_Branch_Channel__c
                (
                    Name = 'Test_Branch_Code',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel')
                );
                insert BrandCode;
                
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            insert prefixKR_PLAN;
            
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
                );
                
            insert rel;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                    ASI_MFM_Start_Date__c = date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Status__c='Draft',
                    OwnerId =u.id
                );
               
            insert plan;
            
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),
                    ASI_MFM_List_Item_Description__c = 'test description',
                    ASI_MFM_Total_Cost__c = 1234,
                    ASI_MFM_Plan__c = plan.id,
                    ASI_MFM_KR_subLedger__c = BrandCode.id
                );
            insert planLine;
            
            
            List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
            planLineSet.add(planLine);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_PlanManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            Test.startTest();
            
            pageParams.put('id', plan.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);        
            
            ASI_MFM_KR_PlanManageAllController PlanManageAllController = new ASI_MFM_KR_PlanManageAllController(stdController);
            //Test function
            PlanManageAllController.init();
            System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)planLine.id);
            PlanManageAllController.cloneLine();
            PlanManageAllController.SaveItems();
            PlanManageAllController.addLineItem();
            System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)planLine.id);
            PlanManageAllController.removeLine();
            
            //Test RemoteAction
            List<Account> remo= ASI_MFM_KR_PlanManageAllController.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_PH_DF_Customer');
            List<ASI_MFM_AP_Code__c> remo1= ASI_MFM_KR_PlanManageAllController.findList('ASI_MFM_AP_Code__c','ID','WHERE RecordType.DeveloperName != null');
            List<ASI_CRM_AccountsAdditionalField__c> remo2= ASI_MFM_KR_PlanManageAllController.findCustomers('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName = ASI_CRM_KR_Wholesaler');  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_PlanManageAllController.findAPACCodeMap('ASI_MFM_AP_Code__c','WHERE RecordType.DeveloperName != null');   
            
            test.stopTest(); 
        }
    }
    
    static testMethod void PRManageAll_Test() {
        userrole Role_Test= new userrole(Name='XXXTrade Marketing');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Purchase_Request__c'); 
            rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KR_Warehouse'),Name='Name1' );          
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
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c = '222',ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
        
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );
            insert prefixKR_PLAN;
            
            userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = r.DeveloperName
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
            
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c=true,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
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
                                                                                 ASI_MFM_AP_Code__c = AP_Code.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
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
                                                                                 ASI_MFM_AP_Code__c = AP_Code.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine2;
            
            plan1.ASI_MFM_Status__c = 'Approved';
            plan1.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only');
            update plan1;
            
            
            //Budget Checking for Plan
            //ASI_MFM_KR_Budget_Setting__c BudgetCheck = new ASI_MFM_KR_Budget_Setting__c(Name='123',ASI_MFM_Budget_Type__c = 'LE1', ASI_MFM_Activation_Time__c = date.today().adddays(-5));
           // insert BudgetCheck;
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                             ASI_MFM_P3_Amount__c = 100,
                                                             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget'));
            insert Budget;
            
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = '222',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Draft',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
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
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
   
            
            
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=PR_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth1; 
            
            
            List<ASI_MFM_Purchase_Request_Line__c> PRLineSet = new List<ASI_MFM_Purchase_Request_Line__c>();
            PRLineSet.add(PR_Line);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PRLineSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_PRManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            Test.startTest();
            
            pageParams.put('id', PR_Header.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PR_Header);        
            
            ASI_MFM_KR_PRManageAllController ManageAllController = new ASI_MFM_KR_PRManageAllController(stdController);
            //Test function
            ManageAllController.init();
            
            
            
            ManageAllController.addallLineItem();
            
            System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)PR_Line.id);
            ManageAllController.cloneLine();
            
            
            System.currentPageReference().getParameters().put('PARAM_PORLine_ID', (String)PR_Line.id);
            ManageAllController.removeLine();
            
            System.currentPageReference().getParameters().put('PARAM_POLINE_SOURCE_ITEM_ID', (String)planLine1.id);  
            ManageAllController.addLineItem();
            
            System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)PR_Line.id);
            ManageAllController.cloneLine();
            
            ManageAllController.saveLinetems();
            
            
            ManageAllController.cancel();
               
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo1= ASI_MFM_KR_PRManageAllController.findList('ASI_MFM_AP_Code__c','ID','WHERE RecordType.DeveloperName != null');
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_PRManageAllController.findSKUList('ASI_MFM_AP_Code__c','WHERE RecordType.DeveloperName != null');   
            
            test.stopTest();
            
         }
    }
    
     static testMethod void POManageAll_Test() {   
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            
            /*
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Purchase_Request__c'); 
            rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            */
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
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
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
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
          //  insert BudgetCheck;
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
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
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            //insert PR_Line2;    
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
                                        
      Test.startTest();
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),   
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id   
                                                                            );
            
            insert po_line;
            
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=PR_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth1; 
            
            
            List<ASI_MFM_PO__c> POLineSet = new List<ASI_MFM_PO__c>();
            POLineSet.add(po);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(POLineSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_PRManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            
            
            //pageParams.put('id', PR_Header.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            
            ASI_MFM_KR_POManageAllController ManageAllController = new ASI_MFM_KR_POManageAllController(stdController);
            //Test function
            ManageAllController.init();
            
            
            
            
            ManageAllController.retrieveExchangeRate();
            
            System.currentPageReference().getParameters().put('PARAM_PORLine_ID', (String)PR_Line.id);
            ManageAllController.removeLine();
            
            System.currentPageReference().getParameters().put('PARAM_POLINE_SOURCE_ITEM_ID', (String)PR_Line.id);
            ManageAllController.addLineItem();  
            
            System.currentPageReference().getParameters().put('mode', 'full');
            ManageAllController.copyPRD();
            
            
            
            //System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)po_line.id);
            ManageAllController.buildPRItemSoql();
            
            ManageAllController.saveLinetems();
            ManageAllController.onCommitted();  
            
            
            ManageAllController.cancel();
               
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo1= ASI_MFM_KR_POManageAllController.findList('ASI_MFM_AP_Code__c','ID','WHERE RecordType.DeveloperName != null');
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_POManageAllController.findCustomers('Account','WHERE RecordType.DeveloperName != null');   
            
            delete PO;
    test.stopTest();
            
         }
    } 
    
    static testMethod void PaymentManageAll_Test() {   
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'KR';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
        
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
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
            
            /*
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            */
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_Payment_Request__c = 'true',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c =date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
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
            
            
            /*
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
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
            
            List<ASI_MFM_Purchase_Request_Line__c> PRList = new List<ASI_MFM_Purchase_Request_Line__c>();
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            PRList.add(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            PRList.add(PR_Line2);
            insert PRList;    
            
            //Supplier: 
            //Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            //insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
                                        
    
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
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
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                        ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
            
            LIST<ASI_MFM_PO_Receipt_Item__c> PORList = NEW LIST<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_Amount__c = 1,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line);
            
            ASI_MFM_PO_Receipt_Item__c POR_Line2 = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c = false,
                                                                                  ASI_MFM_Amount__c = 1,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line2);
            INSERT PORList;
           
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Company_Code__c = '222',
                                                                      ASI_MFM_Send_Approval_Email__c=true);  
            
            insert PaymentHeader;
            
        
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 1,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_Beneficiary_Customer__c = customer1.id,
                                                                                        ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
            
            
            /*
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=PR_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth1; 
            */
            
            List<ASI_MFM_Payment__c> PaymentSet = new List<ASI_MFM_Payment__c>();
            PaymentSet.add(PaymentHeader);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PaymentSet);
            
            PageReference ManageAllPage = Page.asi_mfm_kr_paymentmanageallpage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            
            
            //pageParams.put('id', PR_Header.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PaymentHeader);        
            
            ASI_MFM_KR_PaymentManageAllController ManageAllController = new ASI_MFM_KR_PaymentManageAllController(stdController);
            //Test function
            ManageAllController.init();
            
            //ManageAllController.saveLinetems();
            ManageAllController.onCommitted();  
            
            System.currentPageReference().getParameters().put('PARAM_PORLINE_SOURCE_ITEM_ID', (String)POR_Line.id);
            ManageAllController.addLineItem(); 
            
            System.currentPageReference().getParameters().put('PARAM_PORLINE_SOURCE_ITEM_ID', (String)POR_Line2.id);
            ManageAllController.addLineItem(); 
            
            ManageAllController.retrieveExchangeRate();
            
            System.currentPageReference().getParameters().put('PARAM_PAYLine_ID', (String)POR_Line.id);
            ManageAllController.removePaymentLine();
      
            ManageAllController.saveLinetems();
            ManageAllController.onCommitted();

            ManageAllController.cancel();
                 
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_PaymentManageAllController.findCustomers('Account','WHERE RecordType.DeveloperName != null');  
            List<ASI_MFM_Payment_Line_Item__c> remo5= ASI_MFM_KR_PaymentManageAllController.PaymentLineItems(PaymentHeader.id);   
            String[] remo6= ASI_MFM_KR_PaymentManageAllController.findSObjects('Account','WHERE RecordType.DeveloperName != null'); 
    test.stopTest();
            
         }
    } 
    
    
    
    
    static testMethod void PaymentManageAll_Test_IsDirectPayment() {   
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
        
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
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
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(ASI_MFM_Pre_Payment__c = true,name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c =date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //Added by 2017-09-13 Linus@Introv
            ASI_MFM_Tax_Code__c TaxCode_JA11 = new ASI_MFM_Tax_Code__c (Name = 'JA11',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                        ASI_MFM_VAT_Rate__c = 100,
                                                                        ASI_MFM_Tax_Expl_Code__c = 'E');
            insert TaxCode_JA11;
            
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
            
            
            /*
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
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
            
            List<ASI_MFM_Purchase_Request_Line__c> PRLine_List = new List<ASI_MFM_Purchase_Request_Line__c>();
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            
            PRLine_List.add(PR_Line);
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            PRLine_List.add(PR_Line2);
            insert PRLine_List;    
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '286',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
                                        
    
             
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),   
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                            );
            
            insert po_line;
            
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                        ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
            
            List<ASI_MFM_PO_Receipt_Item__c> POR_LINE_LIST = NEW List<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            
            POR_LINE_LIST.ADD(POR_Line);
            
            ASI_MFM_PO_Receipt_Item__c POR_Line2 = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c = false,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            POR_LINE_LIST.ADD(POR_Line2);
            insert POR_LINE_LIST;
         Test.startTest();    
         
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Company_Code__c = '286',
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_Is_Direct_Payment__c = true,
                                                                      ASI_MFM_Pre_payment__c = true,
                                                                      ASI_MFM_Tax_Code__c = TaxCode_JA11.id,
                                                                      ASI_MFM_KR_TotalPayAmtIncludeVAT__c = 1);  
            
            insert PaymentHeader;
            
              
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Paid_Amount_in_PO_Currency__c=0,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_Beneficiary_Customer__c = customer1.id,
                                                                                        ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
            
            
            /*
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=PR_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth1; 
            */
            
            List<ASI_MFM_Payment__c> PaymentSet = new List<ASI_MFM_Payment__c>();
            PaymentSet.add(PaymentHeader);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PaymentSet);
            
            PageReference ManageAllPage = Page.asi_mfm_kr_paymentmanageallpage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            
            
            //pageParams.put('id', PR_Header.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PaymentHeader);        
            
            ASI_MFM_KR_PaymentManageAllController ManageAllController = new ASI_MFM_KR_PaymentManageAllController(stdController);
            //Test function
            ManageAllController.init();
            
            //ManageAllController.saveLinetems();
            //ManageAllController.onCommitted();  
            
            //System.currentPageReference().getParameters().put('PARAM_PORLINE_SOURCE_ITEM_ID', (String)POR_Line.id);
            //ManageAllController.addLineItem(); 
            
            System.currentPageReference().getParameters().put('PARAM_PORLINE_SOURCE_ITEM_ID', (String)POR_Line2.id);
            ManageAllController.addLineItem(); 
            
            ManageAllController.retrieveExchangeRate();
            
            System.currentPageReference().getParameters().put('PARAM_PAYLine_ID', (String)POR_Line2.id);
            ManageAllController.removePaymentLine();
            
            
            
            ManageAllController.saveLinetems();
            ManageAllController.onCommitted();
             
            
            //System.currentPageReference().getParameters().put('mode', 'full');
            //ManageAllController.copyPRD();

            //System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)po_line.id);
            //ManageAllController.buildPRItemSoql();
            
            
            
            
            
            ManageAllController.cancel();
                 
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_PaymentManageAllController.findCustomers('Account','WHERE RecordType.DeveloperName != null');  
            List<ASI_MFM_Payment_Line_Item__c> remo5= ASI_MFM_KR_PaymentManageAllController.PaymentLineItems(PaymentHeader.id);   
             
    test.stopTest();
            
         }
    } 
    
    static testMethod void POReceiptManageAllCtrler_Test() {     //ASI_MFM_KR_POReceiptManageAllCtrler
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
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
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
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
            
            
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            List<ASI_MFM_Purchase_Request_Line__c> POR_LINE_LIST = NEW List<ASI_MFM_Purchase_Request_Line__c>();
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            POR_LINE_LIST.ADD(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            POR_LINE_LIST.ADD(PR_Line2);
            insert POR_LINE_LIST;    
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
                                        
    
            List<ASI_MFM_PO_Line_Item__c> PO_LINE_LIST = NEW List<ASI_MFM_PO_Line_Item__c>();
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),   
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                            );
        
            PO_LINE_LIST.ADD(po_line);
            
            ASI_MFM_PO_Line_Item__c po_line2 = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),   
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                            );
            
            PO_LINE_LIST.ADD(po_line2);
            insert PO_LINE_LIST;
            
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                        ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
       Test.startTest();      
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Amount__c = 10,
                                                                                  ASI_MFM_Receipt_Date__c = DATE.today(),
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            insert POR_Line;

            
            
            
            List<ASI_MFM_PO_Receipt__c> PORSet = new List<ASI_MFM_PO_Receipt__c>();
            PORSet.add(POR_Header);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PORSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_POReceiptManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            
            
            //pageParams.put('id', PR_Header.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POR_Header);        
            
            ASI_MFM_KR_POReceiptManageAllCtrler ManageAllController = new ASI_MFM_KR_POReceiptManageAllCtrler(stdController);
            //Test function
            ManageAllController.init();
            
           
            //ManageAllController.onCommitted();  
            
            System.currentPageReference().getParameters().put('PARAM_POLINE_SOURCE_ITEM_ID', (String)po_line2.id);
            ManageAllController.addLineItem(); 
            
            //ManageAllController.retrieveExchangeRate();  
             ManageAllController.saveLinetems();
             
            System.currentPageReference().getParameters().put('PARAM_PORLine_ID', (String)POR_Line.id);
            ManageAllController.removeLine();
            
            
            
            ManageAllController.saveLinetems();
            ManageAllController.onCommitted();
             
            
            //System.currentPageReference().getParameters().put('mode', 'full');
            //ManageAllController.copyPRD();

            //System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)po_line.id);
            //ManageAllController.buildPRItemSoql();

            ManageAllController.cancel();
                 
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_POReceiptManageAllCtrler.findCustomers('Account','WHERE RecordType.DeveloperName != null'); 
            List<ASI_MFM_AP_Code__c> remo5= ASI_MFM_KR_POReceiptManageAllCtrler.findCustomers('','WHERE RecordType.DeveloperName != null'); 
            List<ASI_MFM_AP_Code__c> remo6= ASI_MFM_KR_POReceiptManageAllCtrler.findList('Account','WHERE RecordType.DeveloperName != null',''); 
             
    test.stopTest();
            
         }
    } 
    
    static testMethod void POReceiptManageAllCtrler_Test_2() {     //ASI_MFM_KR_POReceiptManageAllCtrler
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
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
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
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
            
            
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            LIST<ASI_MFM_Purchase_Request_Line__c> PRLine_List = NEW LIST<ASI_MFM_Purchase_Request_Line__c>();
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            
            PRLine_List.ADD(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            PRLine_List.ADD(PR_Line2);
            insert PRLine_List;    
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
                                        
    
            LIST<ASI_MFM_PO_Line_Item__c> POLine_List = NEW LIST<ASI_MFM_PO_Line_Item__c>();
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),   
                                                                            ASI_MFM_AP_Code__c = AP_Code.id,
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                            );
            
            
            POLine_List.ADD(po_line);
            
             ASI_MFM_PO_Line_Item__c po_line2 = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(), 
                                                                            ASI_MFM_AP_Code__c = AP_Code.id,
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                            );
            
            POLine_List.ADD(po_line2);
            insert POLine_List;
            
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                        ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
       Test.startTest();      
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Amount__c = 10,
                                                                                  ASI_MFM_AP_Code__c = AP_Code.id,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            insert POR_Line;
            
            
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Company_Code__c = '222',
                                                                      ASI_MFM_Send_Approval_Email__c=true);  
            
            insert PaymentHeader;
            
              
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 100,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_Beneficiary_Customer__c = customer1.id,
                                                                                        ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
            
            
            /*
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=PR_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth1; 
            */
            
            List<ASI_MFM_PO_Receipt__c> PORSet = new List<ASI_MFM_PO_Receipt__c>();
            PORSet.add(POR_Header);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PORSet);
            
            PageReference ManageAllPage = Page.ASI_MFM_KR_POReceiptManageAllPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            
            
            //pageParams.put('id', PR_Header.Id);
            Test.setCurrentPageReference(ManageAllPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POR_Header);        
            
            ASI_MFM_KR_POReceiptManageAllCtrler ManageAllController = new ASI_MFM_KR_POReceiptManageAllCtrler(stdController);
            //Test function
            ManageAllController.init();
            
            ManageAllController.saveLinetems();
            ManageAllController.onCommitted();  
            
            System.currentPageReference().getParameters().put('PARAM_POLINE_SOURCE_ITEM_ID', (String)po_line2.id);
            ManageAllController.addLineItem(); 
            
            
              System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)POR_Line.id);
            ManageAllController.cloneLine();
            //ManageAllController.retrieveExchangeRate();
            
            System.currentPageReference().getParameters().put('PARAM_PORLine_ID', (String)POR_Line.id);
            ManageAllController.removeLine();
            
            
            
            ManageAllController.saveLinetems();
            ManageAllController.onCommitted();
             
            
            //System.currentPageReference().getParameters().put('mode', 'full');
            //ManageAllController.copyPRD();

            //System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)po_line.id);
            //ManageAllController.buildPRItemSoql();

            ManageAllController.cancel();      
    
    test.stopTest();
            
         }
    } 
    
    static testMethod void ASI_MFM_KR_PORelatedReceiptnPaymentsCtrl_Test_1() {
        // ASI_MFM_KR_PORelatedReceiptnPaymentsCtrl
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.ASI_MFM_Country__c = 'KR';
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
 
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
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
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
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
            
            
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            LIST<ASI_MFM_Purchase_Request_Line__c> pr_line_list = new LIST<ASI_MFM_Purchase_Request_Line__c>();
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            
            pr_line_list.add(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            pr_line_list.add(PR_Line2);
            insert pr_line_list;    
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
                                        
    
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),   
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                            );
            
            insert po_line;
            
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                        ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
       Test.startTest();   
            
            LIST<ASI_MFM_PO_Receipt_Item__c> POR_LINE_LIST = NEW LIST<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Amount__c=1,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            
            POR_LINE_LIST.ADD(POR_Line);
            ASI_MFM_PO_Receipt_Item__c POR_Line2 = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c = false,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            POR_LINE_LIST.ADD(POR_Line2);
            insert POR_LINE_LIST;
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Company_Code__c = '222',
                                                                      ASI_MFM_Send_Approval_Email__c=true);  
            
            insert PaymentHeader;
            
              
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Paid_Amount_in_PO_Currency__c=0,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_Beneficiary_Customer__c = customer1.id,
                                                                                        ASI_MFM_PO_Receipt_Item__c = POR_LINE_LIST[0].id);
            insert PaymentLine;
            
            
            /*
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=PR_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth1; 
            */
            
            List<ASI_MFM_Payment__c> PaymentSet = new List<ASI_MFM_Payment__c>();
            PaymentSet.add(PaymentHeader);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PaymentSet);
            
            PageReference ManageAllPage = Page.asi_mfm_kr_paymentmanageallpage;
            Map<String, String> pageParams = ManageAllPage.getParameters();
            
            
            //pageParams.put('id', PR_Header.Id);
            Test.setCurrentPageReference(ManageAllPage);
            //ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PaymentHeader);        
            
            ASI_MFM_KR_PORelatedReceiptnPaymentsCtrl ManageAllController = new ASI_MFM_KR_PORelatedReceiptnPaymentsCtrl();
            //Test function
            ManageAllController.header = po;
            ManageAllController.PRId = PR_Header.id;
            ManageAllController.initalize();
            ManageAllController.initalizePOReceiptsLines();
            ManageAllController.initalizePOReceipts();  
            ManageAllController.initalizePaymentLines();
            ManageAllController.initalizePayments(); 

         
             
    test.stopTest();
            
         }
    }
    
      static testMethod void ASI_MFM_KR_DirectPaymentCtler_Test_1() {
          
            
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR';
        u.ASI_KOR_User_Branch_Code__c = '555';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            ASI_MFM_A_C_Code__c AC_Code = new ASI_MFM_A_C_Code__c (ASI_MFM_A_C_Code__c = 'Code', Name = 'Test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_KR_A_C_Code'));
            insert AC_Code;   
    
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c = '222', ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_AP_Type__c = 'testing',
                                                                 ASI_MFM_AP_Category__c = 'type',
                                                                 ASI_MFM_PRPO_Needed__c=false,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = FiscalYear
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
                    Name = 'PRK',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear,
                    ASI_MFM_Inactive__c=false
                );
            Prefix_List.add(prefixPayment);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'PRK',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,
                     ASI_MFM_Inactive__c=false
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            
            ASI_TnE_Branch_Channel__c Branch = new ASI_TnE_Branch_Channel__c(Name = '55555',ASI_TnE_Branch_Default__c = TRUE, recordTypeid =Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'));
            
            insert Branch;
            
            
            
            
            
            list<ASI_MFM_Plan__c> PlanList = new  list<ASI_MFM_Plan__c>();
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan1',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM', 
                                                        OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Plan__c plan2 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan2;
            PlanList.add(plan1);
            PlanList.add(plan2);
            
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
                                                                                 ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 ASI_MFM_AccountsAdditionalField__c = customer1.id, 
                                                                                 ASI_MFM_Venue_Where__c = customer1.id, 
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,  
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            
            LIST<ASI_MFM_Purchase_Request_Line__c> pr_list = new LIST<ASI_MFM_Purchase_Request_Line__c>();
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            pr_list.add(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            pr_list.add(PR_Line2);
            insert pr_list;    
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            //insert po;  
                                        
    
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),   
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id   
                                                                            );
            
            //insert po_line;
            
            
            //Insert Payment
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Company_Code__c = '222',
                                                                      ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_Payment_Amount__c = 1000);  
            
            //insert PaymentHeader;
            
              /*
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                        ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                        ASI_MFM_Payment_Amount__c = 1,
                                                                                        ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                        ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                        ASI_MFM_Beneficiary_Customer__c = customer1.id,
                                                                                        ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
            
            */
            /*
            attachment Atth = new attachment(parentid=PR_Header.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth;  
            attachment Atth1 = new attachment(parentid=PR_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert atth1; 
            */
    
    test.startTest();
            List <ASI_MFM_PO_Line_Item__c> POLINELIST = NEW List <ASI_MFM_PO_Line_Item__c>();
            POLINELIST.ADD(po_line);
            
            List<ASI_MFM_Payment__c> PaymentSet = new List<ASI_MFM_Payment__c>();
            PaymentSet.add(PaymentHeader);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PaymentSet);
            
            PageReference ManageAllPage = Page.asi_mfm_kr_paymentmanageallpage;

            Test.setCurrentPageReference(ManageAllPage);
            
            ApexPages.currentpage().getHeaders().put('Referer', plan1.id);       
            
            ASI_MFM_KR_DirectPaymentCtler ManageAllController = new ASI_MFM_KR_DirectPaymentCtler();
            ManageAllController.init();
            
            //Test function
            ManageAllController.header.po.ASI_MFM_Plan__c = plan1.id;  
            ManageAllController.header.pay.ASI_MFM_Supplier_Name__c = acc2.id;  
            ManageAllController.header.pay.ASI_MFM_Invoice_Number__c = 'Invoice No.';  
            ManageAllController.header.pay.ASI_MFM_Invoice_Date__c = date.today();  
            ManageAllController.Company = 'PRK';
            ManageAllController.create_po = po;
            ManageAllController.Save_POItem = POLINELIST;  
            //ManageAllController.APCodeId = AP_Code.ID;
            
            ManageAllController.checkPrefixes();   
            ManageAllController.CopyFromPlan();  
              

            ManageAllController.Refresh(); 
            
            ApexPages.currentpage().getParameters().put('PARAM_clone_ID', '1'); 
            ManageAllController.cloneLine();
            
            ApexPages.currentpage().getParameters().put('PARAM_clone_ID', '1'); 
            ManageAllController.cloneLine();
            
            ASI_MFM_KR_DirectPaymentCtler.HeaderObj Header = new  ASI_MFM_KR_DirectPaymentCtler.HeaderObj();
            String id = Header.id;
            Header.id = '1';
            id = Header.id;
            
            ASI_MFM_KR_DirectPaymentCtler.LineObj CloneLine = new  ASI_MFM_KR_DirectPaymentCtler.LineObj();
            id = CloneLine.id;
            CloneLine.id = '1';  
            id = CloneLine.id;   
            CloneLine.PlanLine = planLine1;   
            CloneLine.pl = new ASI_MFM_Payment_Line_Item__c();  
            CloneLine.pl.ASI_MFM_Payment_Amount__c = 1000;
            CloneLine.pl.ASI_MFM_AP_Remark__c = 'OriLine.pl.ASI_MFM_AP_Remark__c';
            CloneLine.pl.ASI_MFM_Invoice_Number__c='Invoice No.'; 
            CloneLine.pl.ASI_MFM_Invoice_Date__c= date.today();  
            CloneLine.pl.ASI_MFM_Beneficiary_Customer__c = customer1.id;
            CloneLine.pl.ASI_MFM_Payment_List_Item_Description__c = 'Description';
            //CloneLine.pl.ASI_MFM_Total_Cost__c = 1000;    
            
            CloneLine.pol= new ASI_MFM_PO_Line_Item__c();  
            CloneLine.pol.ASI_MFM_Tax_Code__c = taxcode.id;   
            CloneLine.pol.ASI_MFM_Sub_brand_Code__c = SubBrand.id;
            CloneLine.pol.ASI_MFM_Plan_Line_Item__c=planLine1.id;
            CloneLine.pol.ASI_MFM_A_C_Code__c = AC_Code.id;
            
            
            ApexPages.currentpage().getParameters().put('PARAM_RLine_ID','1'); 
            ManageAllController.removeLine(); 
            
            ManageAllController.CopyFromPlan();  
            ManageAllController.SaveRecord();
            
            //ManageAllController.onCommitted(double.valueOf('1.99'));
            //ManageAllController.ValdationChecking();
            ManageAllController.Reset();  
       
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_DirectPaymentCtler.findList('ASI_MFM_AP_Code__c','ASI_MFM_AP_Code__c','WHERE RecordType.DeveloperName != null');  
            List<ASI_CRM_AccountsAdditionalField__c> remo5= ASI_MFM_KR_DirectPaymentCtler.findCustomers('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName != null');  
            List<ASI_CRM_AccountsAdditionalField__c> remo6= ASI_MFM_KR_DirectPaymentCtler.findSObjects('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName != null'); 
            Map<String, Decimal> remo7= ASI_MFM_KR_DirectPaymentCtler.retrieveExchangeRate(); 
             
    test.stopTest();
         }
      }
      
      static testMethod void ASI_MFM_KR_MakePaymentRedirectController_Test_1() {
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            
           
            list<ASI_MFM_Prefix__c> Prefix_list = new list<ASI_MFM_Prefix__c> ();
            //Insert Prefix
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            Prefix_list.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test1',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            Prefix_list.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            Prefix_list.add(prefixPO);
            insert Prefix_list;
  
            //Insert Prefix-Relationship
            list<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_list = new list<ASI_MFM_Role_Prefix_Relationship__c> ();
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
                
            PrefixRole_list.add(rel);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PR);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PO);
            insert PrefixRole_list;  
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //Insert AP Code
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_Attachments_for_Plan__c = 'Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            //Insert Custom Setting : ASI MFM Field ID Mappings
            List<ASI_MFM_Field_ID_Mappings__c> FieldIDDateList  = new List<ASI_MFM_Field_ID_Mappings__c>();
            ASI_MFM_Field_ID_Mappings__c f1 = new ASI_MFM_Field_ID_Mappings__c(Name='1',ASI_MFM_Object_Name__c= 'ASI_MFM_Payment__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Supplier_Name__c',ASI_MFM_Field_ID__c='1');
            FieldIDDateList.add(f1);
            ASI_MFM_Field_ID_Mappings__c f2 = new ASI_MFM_Field_ID_Mappings__c(Name='2',ASI_MFM_Object_Name__c= 'ASI_MFM_Payment__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Currency__c',ASI_MFM_Field_ID__c='2');
            FieldIDDateList.add(f2);// 
            ASI_MFM_Field_ID_Mappings__c f3 = new ASI_MFM_Field_ID_Mappings__c(Name='3',ASI_MFM_Object_Name__c= 'ASI_MFM_Payment__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Project_Code__c',ASI_MFM_Field_ID__c='3');
            FieldIDDateList.add(f3);
            insert FieldIDDateList;
        
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
                                        

              
            Test.startTest();       
            System.debug(Limits.getDMLRows());
           
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
            ASI_MFM_KR_MakePaymentRedirectController ext  = new ASI_MFM_KR_MakePaymentRedirectController(stdController);
            ext.redirect();  
            test.stopTest();         
        }
      }
      
      static testMethod void ASI_MFM_KR_PORC_Controller_Test_1() {
                  String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            list<ASI_MFM_Prefix__c> Prefix_list = new list<ASI_MFM_Prefix__c> ();
            //Insert Prefix
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            Prefix_list.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test1',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            Prefix_list.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            Prefix_list.add(prefixPO);
            insert Prefix_list;
  
            //Insert Prefix-Relationship
            list<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_list = new list<ASI_MFM_Role_Prefix_Relationship__c> ();
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
                
            PrefixRole_list.add(rel);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PR);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PO);
            insert PrefixRole_list;  
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //Insert AP Code
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c = true,
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
                    ASI_MFM_Start_Date__c =date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Approved',
                    OwnerId =u.id,
                    ASI_MFM_Plan_Name__c = 'Test Plan2',
                    ASI_MFM_Need_Attachment__c = true,
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
               
            insert plan;
            
            List<string> PlanIdList = new List<string>();
            PlanIdList.add(plan.id);
            
            //Insert Plan Line
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),
                    ASI_MFM_List_Item_Description__c = 'test description',
                    ASI_MFM_Total_Cost__c = 12,
                    ASI_MFM_Plan__c = plan.id,
                    //ASI_MFM_KR_subLedger__c = BrandCode.id,
                    ASI_MFM_AP_Code__c = AP_Code.id,    
                    ASI_MFM_Month_1_Cost__c = 1,
                    ASI_MFM_Month_2_Cost__c = 1,
                    ASI_MFM_Month_3_Cost__c = 1,
                    ASI_MFM_Month_4_Cost__c = 1,
                    ASI_MFM_Month_6_Cost__c = 1,
                    ASI_MFM_Month_7_Cost__c = 1,
                    ASI_MFM_Month_8_Cost__c = 1,
                    ASI_MFM_Month_9_Cost__c = 1,
                    ASI_MFM_Month_10_Cost__c = 1,
                    ASI_MFM_Month_11_Cost__c = 1,
                    ASI_MFM_Month_12_Cost__c = 1
                    //ASI_MFM_Sub_brand_Code__c = SubBrand.id
                );
            insert planLine;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanLineList = new List<ASI_MFM_Plan_Line_Item__c>();
            PlanLineList.add(planLine);
            
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine.id,
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
            
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po; 
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
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
            System.debug(Limits.getDMLRows());
           
            
             ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                        ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
     
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_Receipt_Date__c = date.today(),
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            insert POR_Line;
            
            List<string> POReceiptIdList = new List<string>();
            POReceiptIdList.add(POR_Line.id);
            
            //ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
            ASI_MFM_KR_PORC_Controller ext = new ASI_MFM_KR_PORC_Controller();
            
            ext.SelectStatus = 'Approved';
            ext.runSearch();
            //ext.ConstructMap(PlanLineList);   
            
            //Test RemoteAction 
            List<ASI_MFM_Plan__c> planlist = new List<ASI_MFM_Plan__c>();
            planlist.add(plan);  
            string remo= ASI_MFM_KR_PORC_Controller.updatePlan(planlist);  
            string remo1= ASI_MFM_KR_PORC_Controller.uncheckallflag(PlanIdList);  
            string remo2= ASI_MFM_KR_PORC_Controller.poReceiptClose(POReceiptIdList,3,'2016','3','3');  
            string remo4= ASI_MFM_KR_PORC_Controller.poReceiptClose(POReceiptIdList,3,'2016','03','03');  
            
            test.stopTest();
          }
      } 
      
    static testMethod void ASI_MFM_KR_PORC_Controller_Test_2() {
       String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            
           list<ASI_MFM_Prefix__c> Prefix_list = new list<ASI_MFM_Prefix__c> ();
            //Insert Prefix
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            Prefix_list.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test1',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            Prefix_list.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            Prefix_list.add(prefixPO);
            insert Prefix_list;
  
            //Insert Prefix-Relationship
            list<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_list = new list<ASI_MFM_Role_Prefix_Relationship__c> ();
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
                
            PrefixRole_list.add(rel);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PR);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PO);
            insert PrefixRole_list;   
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //Insert AP Code
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c = true,
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
                    ASI_MFM_Start_Date__c =date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Approved',
                    OwnerId =u.id,
                    ASI_MFM_Plan_Name__c = 'Test Plan2',
                    ASI_MFM_Need_Attachment__c = true,
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
               
            insert plan;
            
            List<string> PlanIdList = new List<string>();
            PlanIdList.add(plan.id);
            
            //Insert Plan Line
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),
                    ASI_MFM_List_Item_Description__c = 'test description',
                    ASI_MFM_Total_Cost__c = 12,
                    ASI_MFM_Plan__c = plan.id,
                    //ASI_MFM_KR_subLedger__c = BrandCode.id,
                    ASI_MFM_AP_Code__c = AP_Code.id,    
                    ASI_MFM_Month_1_Cost__c = 1,
                    ASI_MFM_Month_2_Cost__c = 1,
                    ASI_MFM_Month_3_Cost__c = 1,
                    ASI_MFM_Month_4_Cost__c = 1,
                    ASI_MFM_Month_6_Cost__c = 1,
                    ASI_MFM_Month_7_Cost__c = 1,
                    ASI_MFM_Month_8_Cost__c = 1,
                    ASI_MFM_Month_9_Cost__c = 1,
                    ASI_MFM_Month_10_Cost__c = 1,
                    ASI_MFM_Month_11_Cost__c = 1,
                    ASI_MFM_Month_12_Cost__c = 1
                    //ASI_MFM_Sub_brand_Code__c = SubBrand.id
                );
            insert planLine;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanLineList = new List<ASI_MFM_Plan_Line_Item__c>();
            PlanLineList.add(planLine);
            
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine.id,
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
            
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po; 
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
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
            System.debug(Limits.getDMLRows());
           
            
             ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                        ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
     
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_Receipt_Date__c = date.today(),
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            insert POR_Line;
            
            List<string> POReceiptIdList = new List<string>();
            POReceiptIdList.add(POR_Line.id);
            
            //ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
            ASI_MFM_KR_PORC_Controller ext = new ASI_MFM_KR_PORC_Controller();
            
            ext.SelectStatus = 'Approved';
            //ext.runSearch();
            ext.ConstructMap(PlanLineList);   
            
            //Test RemoteAction 
            List<ASI_MFM_Plan__c> planlist = new List<ASI_MFM_Plan__c>();
            planlist.add(plan);  
            string remo= ASI_MFM_KR_PORC_Controller.updatePlan(planlist);  
            string remo1= ASI_MFM_KR_PORC_Controller.uncheckallflag(PlanIdList);  
            string remo2= ASI_MFM_KR_PORC_Controller.poReceiptClose(POReceiptIdList,3,'2016','3','3');  
            string remo4= ASI_MFM_KR_PORC_Controller.poReceiptClose(POReceiptIdList,3,'2016','03','03');  
            
            test.stopTest();
          }
      } 
      
     static testMethod void ASI_MFM_KR_PORC_Controller_Test_3() {
       String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            
           list<ASI_MFM_Prefix__c> Prefix_list = new list<ASI_MFM_Prefix__c> ();
            //Insert Prefix
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            Prefix_list.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test1',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            Prefix_list.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            Prefix_list.add(prefixPO);
            insert Prefix_list;
  
            //Insert Prefix-Relationship
            list<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_list = new list<ASI_MFM_Role_Prefix_Relationship__c> ();
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
                
            PrefixRole_list.add(rel);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PR);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PO);
            insert PrefixRole_list;   
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //Insert AP Code
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c = true,
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
                    ASI_MFM_Start_Date__c =date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,  
                    ASI_MFM_Status__c='Approved',
                    OwnerId =u.id,
                    ASI_MFM_Plan_Name__c = 'Test Plan2',
                    ASI_MFM_Need_Attachment__c = true,
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
               
            insert plan;
            
            List<string> PlanIdList = new List<string>();
            PlanIdList.add(plan.id);
            
            //Insert Plan Line
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),
                    ASI_MFM_List_Item_Description__c = 'test description',
                    ASI_MFM_Total_Cost__c = 12,
                    ASI_MFM_Plan__c = plan.id,
                    //ASI_MFM_KR_subLedger__c = BrandCode.id,
                    ASI_MFM_AP_Code__c = AP_Code.id,    
                    ASI_MFM_Month_1_Cost__c = 1,
                    ASI_MFM_Month_2_Cost__c = 1,
                    ASI_MFM_Month_3_Cost__c = 1,
                    ASI_MFM_Month_4_Cost__c = 1,
                    ASI_MFM_Month_6_Cost__c = 1,
                    ASI_MFM_Month_7_Cost__c = 1,
                    ASI_MFM_Month_8_Cost__c = 1,
                    ASI_MFM_Month_9_Cost__c = 1,
                    ASI_MFM_Month_10_Cost__c = 1,
                    ASI_MFM_Month_11_Cost__c = 1,
                    ASI_MFM_Month_12_Cost__c = 1
                    //ASI_MFM_Sub_brand_Code__c = SubBrand.id
                );
            insert planLine;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanLineList = new List<ASI_MFM_Plan_Line_Item__c>();
            PlanLineList.add(planLine);
            
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
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine.id,
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
            
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po; 
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
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
            System.debug(Limits.getDMLRows());
           
            
             ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                        ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
     
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Plan_Line_Item__c=planLine.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_ACC_Verify__c=false,
                                                                                  ASI_MFM_Receipt_Date__c = date.today(),
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            
            insert POR_Line;
            
            List<string> POReceiptIdList = new List<string>();
            POReceiptIdList.add(POR_Line.id);
            
            //ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
            ASI_MFM_KR_PORC_Controller ext = new ASI_MFM_KR_PORC_Controller();
            
            ext.SelectStatus = 'Approved';
            //ext.runSearch();
            ext.ConstructMap(PlanLineList);   
            
            //Test RemoteAction 
            List<ASI_MFM_Plan__c> planlist = new List<ASI_MFM_Plan__c>();
            planlist.add(plan);  
            string remo= ASI_MFM_KR_PORC_Controller.updatePlan(planlist);  
            string remo1= ASI_MFM_KR_PORC_Controller.uncheckallflag(PlanIdList);  
            string remo2= ASI_MFM_KR_PORC_Controller.poReceiptClose(POReceiptIdList,3,'2016','3','3');  
            string remo4= ASI_MFM_KR_PORC_Controller.poReceiptClose(POReceiptIdList,3,'2016','03','03');  
            
            test.stopTest();
          }
      } 
    /*
      static testMethod void ASI_MFM_KR_FV_Controller_Test_1() {
          
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            
           list<ASI_MFM_Prefix__c> Prefix_list = new list<ASI_MFM_Prefix__c> ();
            //Insert Prefix
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = fiscalYear
                );  
            Prefix_list.add(prefixKR_PLAN);
            
            //PR PREFIX:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test1',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = fiscalYear 
                );
            Prefix_list.add(prefixPR);
            
            //PO PREFIX:  
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear,  
                    ASI_MFM_Inactive__c = false
                );
            Prefix_list.add(prefixPO);
            insert Prefix_list;
  
            //Insert Prefix-Relationship
            list<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_list = new list<ASI_MFM_Role_Prefix_Relationship__c> ();
            ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
                
            PrefixRole_list.add(rel);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PR);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_list.add(rel_PO);
            insert PrefixRole_list;  
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=getFiscalYear());
            insert pjCode;
            
            //Insert AP Code
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
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
                    ASI_MFM_Need_Attachment__c = true,
                    ASI_MFM_Fiscal_year__c = FiscalYear
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
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1',ASI_HK_CRM_Payment_Term_Code__c = 'TEST');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po; 
                          
    
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
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
           
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Approved',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                      ASI_MFM_Supplier_Name__c = acc2.id,
                                                                      ASI_MFM_PO__c = po.id,
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
                                                                                        ASI_MFM_Beneficiary_Customer__c = customer1.id
                                                                                        );
            insert PaymentLine;
            
            Map<Id, ASI_MFM_Payment_Line_Item__c> PaymentLineMap = NEW Map<Id, ASI_MFM_Payment_Line_Item__c>();
            PaymentLineMap.put(PaymentLine.id, PaymentLine);
            
                 
            System.debug(Limits.getDMLRows());
             
            //ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
            ASI_MFM_KR_FV_Controller ext = new ASI_MFM_KR_FV_Controller();
            List<Account> remo= ASI_MFM_KR_FV_Controller.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_PH_DF_Customer');
            EXT.PaymentLineMap = PaymentLineMap;
            ext.Fiscalyear = 'FY1516';
            ext.InvoiceNumber = '12345';
            ext.init();  
            ext.runSearch();  
            ext.save();  //added   
            
            //Test RemoteAction  
            
            test.stopTest();
          }
      } 
    */
    //----------------------------------------------------------ASI_MFM_KR_PO_TriggerClass---------------------------------------------------------------------------------------//
    static testMethod void ASI_MFM_KR_PO_TriggerClass_Test() {   //beforeUpsertMethod
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c = 'Brand Marketing';
        update u;
        
        System.runAs(u){ 
            
            
            
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
            ASI_MFM_Fix_Approval_Route__c fixApprovalRoute = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Module__c = 'Plan', ASI_MFM_Team__c = 'Brand Marketing', ASI_MFM_BA__c=u.id, ASI_MFM_Approval_Limit_BA__c=0);
            insert fixApprovalRoute;
            
            //-------------------------------------------------- Approval Process ----------------------------------------------------------//
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=fiscalyear);
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
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
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
            
            ASI_MFM_Plan__c plan2 = new ASI_MFM_Plan__c( Name = 'Test Plan3',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Draft',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        ASI_MFM_Cloned_Plan_ID__c = plan1.id,
                                                        ASI_MFM_KR_Included_Initial_Plan_Amount__c = true,
                                                        OwnerId =u.id);
            insert plan2;
            
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
           
            
            //-------------------------------------------------- Customer----------------------------------------------------------//
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',
                                       ASI_MFM_Address_Line_1__c = '1',
                                       ASI_MFM_Address_Line_2__c = '2');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c cus1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Wholesaler'),Name='Name1');
            insert cus1;
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c=true,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            //-------------------------------------------------- PR ----------------------------------------------------------//
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
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            insert acc2;
            
            //-------------------------------------------------- PO ----------------------------------------------------------//
            Test.startTest();        
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Draft',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 ASI_MFM_Warehouse__c = acc1.id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id,
                                                                           ASI_MFM_AccountsAdditionalField__c = cus1.id
                                                                          );
            
            insert po_line;
            
            
            
            test.stopTest();       
        }
    } //End of beforeUpsertMethod testing
    
    static testMethod void ASI_MFM_KR_PO_TriggerClass_Test_2() {   //routineAfterAll
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            
            
            
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
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=fiscalyear);
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
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
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
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
         
                        
            //-------------------------------------------------- Customer----------------------------------------------------------//
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',
                                       ASI_MFM_Address_Line_1__c = '1',
                                       ASI_MFM_Address_Line_2__c = '2');          
            insert acc1;
            
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c=true,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            //-------------------------------------------------- PR ----------------------------------------------------------//
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
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            insert acc2;
            
            //-------------------------------------------------- PO ----------------------------------------------------------//
            Test.startTest();        
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Submitted',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 ASI_MFM_Warehouse__c = acc1.id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;
            
            po.ASI_MFM_Status__c = 'Approved';
            update po;
            
            test.stopTest();       
        }
    } //End of routineAfterAll testing
    
}