@isTest
public class ASI_MFM_CN_POSM_ItemGroupPDFCtrl_Test {
    Static List<ASI_MFM_Payment__c> payment = new List<ASI_MFM_Payment__c>();
    Static List<ASI_MFM_Payment_Detail__c> paymentline = new List<ASI_MFM_Payment_Detail__c>();
    Static List<ASI_MFM_Prefix__c> prefixs = new List<ASI_MFM_Prefix__c>();
    Static List<ASI_MFM_Expense_Control_Form__c> expenseControlForm = new List<ASI_MFM_Expense_Control_Form__c>();
    Static List<ASI_CRM_Expense_Control_Form_Line__c> expenseLine = new List<ASI_CRM_Expense_Control_Form_Line__c>();
    Static List<ASI_MFM_PO__c> po = new List<ASI_MFM_PO__c>();
    Static List<ASI_MFM_BU__c> bu = new List<ASI_MFM_BU__c>();
    Static List<ASI_MFM_PP_Category__c> ppcat = new List<ASI_MFM_PP_Category__c>();
    Static List<ASI_MFM_Brand__c> brand = new List<ASI_MFM_Brand__c>();
    Static List<ASI_MFM_Sub_brand__c> subbrand = new List<ASI_MFM_Sub_brand__c>();
    Static List<ASI_MFM_Exchange_Rate__c> exrate = new List<ASI_MFM_Exchange_Rate__c>();
    Static List<Account> supplier = new List<Account>();
    Static List<ASI_MFM_Tax_Code__c> taxcode = new List<ASI_MFM_Tax_Code__c>();
    Static User tempU = [select id from user where CompanyName = 'Pernod Ricard China' AND ManagerId != null AND isActive = true limit 1];
    Static User currentuser;
    Static List<ASI_CRM_Fix_Approval_Route__c> tmpFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
    Static List<ASI_CRM_Dynamic_Approval_Route__c> tmpDynamicRoute = new List<ASI_CRM_Dynamic_Approval_Route__c>();
    Static List<ASI_MFM_Rental_Request__c> rentalRequest = new List<ASI_MFM_Rental_Request__c>();
    Static List<ASI_MFM_Rental_Request_Line__c> rentalDetail = new List<ASI_MFM_Rental_Request_Line__c>();
    Static List<ASI_MFM_CN_RentalRequestSetting__c> customSetting = new List<ASI_MFM_CN_RentalRequestSetting__c>();
    
    Static testmethod void ASI_MFM_CN_POSM_ItemGropPDFCtrl_test(){
        
        createTestData();
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , ASI_MFM_Status__c = 'Final'
                                                        , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval')
                                                       ));
        
        Insert rentalRequest;
        
        rentalDetail.add(new ASI_MFM_Rental_Request_Line__c(ASI_MFM_Rental_Request__c = rentalRequest[0].id
                                                            , ASI_MFM_Total_Amount__c = 10000
                                                            , ASI_MFM_ExpenseType__c = expenseControlForm[0].id
                                                            , ASI_MFM_Completion__c = False
                                                            , ASI_MFM_Apply_CIP_Logic__c = True
                                                            , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line')
                                                           ));
        
        Insert rentalDetail;
        
        payment.add(new ASI_MFM_Payment__c(ASI_MFM_Invoice_Amount__c = 1000
                                           , ASI_MFM_No_Invoice_Amount__c = 1000
                                           , ASI_MFM_Normal_Invoice_Amount__c = 1000
                                           , ASI_MFM_Tax_Code__c = taxcode[0].id
                                           , ASI_MFM_Supplier_Name__c = supplier[0].id
                                           , ASI_MFM_BU__c = bu[0].id
                                           , ASI_MFM_Prefix__c = prefixs[0].id
                                           , ASI_MFM_Status__c = 'Draft'
                                           , ASI_MFM_Pre_payment__c = True
                                           , ASI_MFM_Expense_Date_From__c = date.today()
                                           , ASI_MFM_G_L_Date__c = date.today()
                                           , ASI_MFM_Invoice_Number__c = '1111'
                                           , ASI_MFM_Expense_Date_To__c = date.today().addMonths(10)
                                           , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_CN_StructureCost_Payment')
                                           , ASI_MFM_Currency__c = 'RMB'
                                           , ASI_MFM_Expense_Type__c = expenseControlForm[0].id
                                           , ASI_MFM_PO__c = po[0].id
                                           , ASI_MFM_Department_Text__c = 'Admin'
                                           , ASI_MFM_Contract__c = rentalDetail[0].id
                                           , ASI_MFM_Remarks__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                          ));
        
        payment.add(new ASI_MFM_Payment__c(ASI_MFM_Invoice_Amount__c = 1000
                                           , ASI_MFM_No_Invoice_Amount__c = 1000
                                           , ASI_MFM_Normal_Invoice_Amount__c = 1000
                                           , ASI_MFM_Tax_Code__c = taxcode[0].id
                                           , ASI_MFM_Supplier_Name__c = supplier[0].id
                                           , ASI_MFM_BU__c = bu[0].id
                                           , ASI_MFM_Prefix__c = prefixs[0].id
                                           , ASI_MFM_Status__c = 'Submitted'
                                           , ASI_MFM_Pre_payment__c = True
                                           , ASI_MFM_Expense_Date_From__c = date.today()
                                           , ASI_MFM_G_L_Date__c = date.today()
                                           , ASI_MFM_Invoice_Number__c = '1111'
                                           , ASI_MFM_Expense_Date_To__c = date.today().addMonths(10)
                                           , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_CN_StructureCost_Payment')
                                           , ASI_MFM_Currency__c = 'RMB'
                                           , ASI_MFM_Expense_Type__c = expenseControlForm[0].id
                                           , ASI_MFM_PO__c = po[0].id
                                           , ASI_MFM_Department_Text__c = 'Admin'
                                           , ASI_MFM_Contract__c = rentalDetail[0].id
                                           , ASI_MFM_Remarks__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                          ));
        payment.add(new ASI_MFM_Payment__c(ASI_MFM_Invoice_Amount__c = 1000
                                           , ASI_MFM_No_Invoice_Amount__c = 1000
                                           , ASI_MFM_Normal_Invoice_Amount__c = 1000
                                           , ASI_MFM_Tax_Code__c = taxcode[0].id
                                           , ASI_MFM_Supplier_Name__c = supplier[0].id
                                           , ASI_MFM_BU__c = bu[0].id
                                           , ASI_MFM_Prefix__c = prefixs[0].id
                                           , ASI_MFM_Status__c = 'Final'
                                           , ASI_MFM_Pre_payment__c = True
                                           , ASI_MFM_Expense_Date_From__c = date.today()
                                           , ASI_MFM_G_L_Date__c = date.today()
                                           , ASI_MFM_Invoice_Number__c = '1111'
                                           , ASI_MFM_Expense_Date_To__c = date.today().addMonths(10)
                                           , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_CN_StructureCost_Payment')
                                           , ASI_MFM_Currency__c = 'RMB'
                                           , ASI_MFM_Expense_Type__c = expenseControlForm[0].id
                                           , ASI_MFM_PO__c = po[0].id
                                           , ASI_MFM_Department_Text__c = 'Admin'
                                           , ASI_MFM_Contract__c = rentalDetail[0].id
                                           , ASI_MFM_Remarks__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                          ));
        
        Insert payment;
        
        paymentline.add(new ASI_MFM_Payment_Detail__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Payment_Allocation')
                                                      , ASI_MFM_Non_Sales_Allocated_Amount__c = 1500
                                                      , ASI_MFM_Sales_Allocated_Amount__c = 1500
                                                      , ASI_MFM_Payment__c = payment[0].id
                                                     ));
        paymentline.add(new ASI_MFM_Payment_Detail__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CN_Classification_Line')
                                                      , ASI_MFM_Reclassification__c = 'test'
                                                      , ASI_MFM_Headcount__c = 1
                                                      , ASI_MFM_Amount__c = 3000
                                                      , ASI_MFM_Payment__c = payment[0].id
                                                     ));
        paymentline.add(new ASI_MFM_Payment_Detail__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Accrual_Detail')
                                                      , ASI_MFM_Accrual_Reverse_Amount__c = 1500
                                                      , ASI_MFM_GL_date__c = date.newInstance(2017, 03, 31)
                                                      , ASI_MFM_Payment__c = payment[0].id
                                                      , ASI_MFM_Reverse_ETL__c = True
                                                      , ASI_MFM_Accrual_Reverse_Budget__c = False
                                                     ));
        paymentline.add(new ASI_MFM_Payment_Detail__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Accrual_Detail')
                                                      , ASI_MFM_Accrual_Reverse_Amount__c = 1500
                                                      , ASI_MFM_GL_date__c = date.today()
                                                      , ASI_MFM_Payment__c = payment[0].id
                                                      , ASI_MFM_Reverse_ETL__c = false
                                                      , ASI_MFM_Accrual_Reverse_Budget__c = False
                                                     ));
        
        Insert paymentline;
        
        Test.startTest();
        
        rentalRequest[0].ASI_MFM_Status__c = 'Final';
        Update rentalRequest;
        
        rentalDetail[0].ASI_MFM_Apply_CIP_Logic__c = True;
        rentalDetail[0].ASI_MFM_Completion__c = True;
        update rentalDetail;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(payment[0].id);
        Approval.process(req1);
        
        ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL cls2 = new ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL();
        cls2.getApprovalHisotry(payment[0].id);
        
        List<ProcessInstanceWorkitem> workitems = [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = : payment[0].id];
        
        if(workitems.size() > 0){
            Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
            approvalReq.setWorkitemId(workitems[0].Id);
            approvalReq.setAction('Reject');
            Approval.process(approvalReq);
        }
        
        
        
        
        
        Test.stopTest();
    }

	Private Static Void createTestData(){
        
        currentUser = [Select id, CompanyName, ManagerId From User Where id = : userInfo.getUserId()];
        currentUser.companyName = 'Pernod Ricard China';
        Update currentUser;
        
        customSetting.add(new ASI_MFM_CN_RentalRequestSetting__c(Name = 'Default Renovation Item'
                                                                 , ASI_MFM_Default_Renovation_Item_1__c = 'Test'
                                                                ));
        
        Insert customSetting;
        
        taxcode.add(new ASI_MFM_Tax_Code__c(Name = '6%', ASI_MFM_VAT_Rate__c = 6
                                            , recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_CN_Tax_Code')
                                           ));
        Insert taxcode;
        
        String fy = date.today().month() >= 7 ? 'FY' + String.valueOf(date.today().year() - 2000) + String.valueOf(date.today().year() - 1999) : 'FY' + String.valueOf(date.today().year() - 2001) + String.valueOf(date.today().year() - 2000);

        ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CNSCP'
                                                          , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix')
                                                          , ASI_MFM_Module__c='Structure Cost Payment'
                                                          , ASI_MFM_Fiscal_year__c = fy
                                                          , ASI_MFM_Next_Number__c = 0
                                                          , ownerId = userinfo.getUserId());
        prefixs.add(prefix1);
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(Name='CNSCB'
                                                     , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix')
                                                     , ASI_MFM_Module__c='Structure Cost Budget'
                                                     , ASI_MFM_Fiscal_year__c = fy
                                                     , ASI_MFM_Next_Number__c = 0
                                                     , ownerId = userinfo.getUserId());
        prefixs.add(px);

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(Name='CNSCR'
                                                     , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix')
                                                     , ASI_MFM_Module__c='Structure Cost Rental Payment'
                                                     , ASI_MFM_Fiscal_year__c = fy
                                                     , ASI_MFM_Next_Number__c = 0
                                                     , ownerId = userinfo.getUserId());
        prefixs.add(px2);
        
        ASI_MFM_Prefix__c px3 = new ASI_MFM_Prefix__c(Name='CNSCR'
                                                     , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix')
                                                     , ASI_MFM_Module__c='Structure Cost Accrual'
                                                     , ASI_MFM_Fiscal_year__c = fy
                                                     , ASI_MFM_Next_Number__c = 0
                                                     , ownerId = userinfo.getUserId());
        prefixs.add(px3);
        
        insert prefixs;
        
        bu.add(new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c = 'Test' , ASI_MFM_CN_Country__c='CN', ASI_MFM_Base_Currency__c='RMB', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CN_BU')));
        Insert bu;
        
        ppcat.add(new ASI_MFM_PP_Category__c(recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_PP_Category__cASI_MFM_CN_PP_Category'), Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1'));
        Insert ppcat;
        
        //create brand
        brand.add(new ASI_MFM_Brand__c(name='brandname',Recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_CN_Brand')));
        insert brand; 
        
        //create sub brand
        subbrand.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_CN_Sub_Brand'), ASI_MFM_Brand__c=brand[0].id, ASI_MFM_Brand_Director__c = userInfo.getUserId()));
        insert subbrand;
        
        exrate.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01')
                                                , ASI_MFM_Exchange_Rate__c = 7.77500
                                                , ASI_MFM_Counter_Currency__c='USD'
                                                , ASI_MFM_Base_Currency__c='RMB'
                                                , ASI_MFM_Application__c='MFM' ));
        insert exrate;
        
        supplier.add(new Account(Name='TestAcc', recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Structure_Cost_Supplier') , ASI_MFM_Customer_Supplier_Number__c='123',
                                 ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
        supplier.add(new Account(Name='TestAcc', recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Structure_Cost_Supplier') , ASI_MFM_Customer_Supplier_Number__c='123',
                                 ASI_MFM_Customer_Supplier_Name__c='SupplierName', ASI_MFM_Dummy_Supplier__c = True));
        insert supplier;
        
        expenseControlForm.add(new ASI_MFM_Expense_Control_Form__c(Name = 'Test'
                                                                   , ASI_MFM_BU__c = bu[0].id
                                                                   , ASI_MFM_Allocation__c = True
                                                                   , ASI_MFM_AllocationMethod__c = 'Sales/Non-Sales'
                                                                   , ASI_MFM_BudgetControlLevel__c = 'By Department'
                                                                   , ASI_MFM_BudgetControlMethod__c = True
                                                                   , ASI_MFM_BudgetOwner__c = userInfo.getUserId()
                                                                   , ASI_MFM_Department__c = 'Admin'
                                                                   , ASI_MFM_ExpenseType__c = 'Testing Fee'
                                                                   , ASI_MFM_PercentageAmount__c = 'Amount'
                                                                   , ASI_MFM_PP_Category__c = ppcat[0].id
                                                                   , ASI_MFM_Reclassification__c = 'test'
                                                                   , ASI_MFM_Sub_Brand__c = subbrand[0].id
                                                                   , ASI_MFM_Subledger_Options__c = 'test'
                                                                   , ASI_MFM_Subledger__c = True
                                                                   , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Expense_Control_Form')
                                                                  ));
        
        Insert expenseControlForm;
        
        expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id
                                                                 , ASI_MFM_User__c = userInfo.getUserId()
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Expense_Control_Form_Allowed_User')
                                                                ));
        
        Insert expenseLine;
        
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Renovation Form', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu[0].id, ASI_MFM_Department__c = 'Admin'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Structure Cost Payment', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu[0].id, ASI_MFM_Department__c = 'Admin'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Approval Form', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu[0].id, ASI_MFM_Department__c = 'Admin'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Request Form', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu[0].id, ASI_MFM_Department__c = 'Admin'));
        
        
        insert tmpFixRoute;
        
        po.add(new ASI_MFM_PO__c(Name = 'Test Budget'
                                 , ASI_MFM_BU_Code__c = bu[0].id
                                 , ASI_MFM_Prefix__c = prefixs[1].id
                                 , ASI_MFM_Expense_Type__c = expenseControlForm[0].id
                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_CN_Structure_Cost')
                                 , ASI_MFM_PO_Original_Amount__c = 100000000
                                 , ASI_MFM_CN_Amount_Ex__c = 100000000
                                 , ASI_MFM_Previous_FY_Prepayment_Amount__c = 10000
                                 , ASI_MFM_Status__c = 'Final'
                                 , ASI_MFM_LE__c = 1
                                ));
        
        Insert po;
    }
}