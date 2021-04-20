@isTest
public class ASI_MFM_CN_StructureCost_Test {
    
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
    
    Static testmethod void ASI_MFM_CN_Payment_SC_TriggerCls_test(){
        
        Test.startTest();
        
        createTestData();
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
                                          ));
        
        Insert payment;

        payment[0].ASI_MFM_Status__c = 'Submitted';
        payment[1].ASI_MFM_Status__c = 'Draft';
        
        Update payment;
        
        payment[0].ASI_MFM_Status__c = 'Final';
        Update Payment[0];
        
        po[0].ASI_MFM_LE__c = 2;
        Update po;
        
        Test.stopTest();
    }
    
    Static testmethod void ASI_MFM_CN_StructureCost_Main_Ctrl_test(){
        
        
        
        createTestData();
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        //MT@Introv 20190603 new controls on these fields start
                                                        , ASI_MFM_Proposed_New_Space__c = 15
                                                        , ASI_MFM_Headcount_Forecast_in_3_years__c = 1
                                                        , ASI_MFM_Comment__c = ''
                                                        , ASI_MFM_Renovation_New__c = 'No Renovation'
                                                        //MT@Introv 20190603 new controls on these fields end
                                                       ));
        
        Insert rentalRequest;
        
        rentalDetail.add(new ASI_MFM_Rental_Request_Line__c(ASI_MFM_Rental_Request__c = rentalRequest[0].id
                                                            , ASI_MFM_Total_Amount__c = 10000
                                                            , ASI_MFM_ExpenseType__c = expenseControlForm[0].id
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
                                                      , ASI_MFM_Accrual_Reverse_Amount__c = 3000
                                                      , ASI_MFM_GL_date__c = date.today()
                                                      , ASI_MFM_Payment__c = payment[0].id
                                                     ));
        paymentline.add(new ASI_MFM_Payment_Detail__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Accrual_Detail')
                                                      , ASI_MFM_Accrual_Reverse_Amount__c = 3000
                                                      , ASI_MFM_GL_date__c = date.newInstance(2017, 03, 31)
                                                      , ASI_MFM_Payment__c = payment[1].id
                                                      , ASI_MFM_Reverse_ETL__c = True
                                                     ));
        
        Insert paymentline;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', payment[0].Id);
        ApexPages.currentPage().getParameters().put('bu', bu[0].Id);
        ApexPages.currentPage().getParameters().put('department', 'Admin');
        ApexPages.currentPage().getParameters().put('expensetype', expenseControlForm[0].id);
        ApexPages.currentPage().getParameters().put('completion', 'false');
        ApexPages.currentPage().getParameters().put('taxCode', taxcode[0].id);
        
        ApexPages.StandardController scon = new ApexPages.StandardController(payment[0]);
        ASI_MFM_CN_StructureCost_Main_Ctrl con = new ASI_MFM_CN_StructureCost_Main_Ctrl(scon);
        
        con.getPrefixes();
        con.expenseControlFormSelection();
        con.proceed();
        con.editLineItem();
        con.editAccrualLineItem();
        con.accrualPaymentform = False;
        con.submitForApproval();
        con.edit();
        con.expenseTypeSelectOption();
        con.classificationSelectOption();
        con.save();
        con.redirectToPage('/', payment[0].id, true);
        con.cancel();
        
        con.selected_prefix = prefixs[0].id;
        con.proceed();
        
        List<ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine> upsertDetail = new List<ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine>();
        
        ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine a = new ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine();
        a.salesAmount = 1500;
        a.nonSalesAmount = 1500;
        a.salesPrecent = 0;
        a.nonsalesPrecent = 0;
        a.employeePrecent = 0;
        a.employeeAmount = 0;
        a.employeeCode = '';
        a.lineId = '';
        a.reverseAmount = 1000;
        a.glDate = '2017-03-31';
        a.purpose = '';
        a.headCount = 0;
        a.classificationAmount = 3000;
        a.ETL = False;
        a.reclassification = 'test';
        a.isDelete = False;
        
        upsertDetail.add(a);
        
        List<ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine> DeleteDetail = new List<ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine>();
        ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine b = new ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine();
        b.salesAmount = 1500;
        b.nonSalesAmount = 1500;
        b.salesPrecent = 0;
        b.nonsalesPrecent = 0;
        b.employeePrecent = 0;
        b.employeeAmount = 0;
        b.employeeCode = '';
        b.lineId = paymentline[0].id;
        b.reverseAmount = 0;
        b.glDate = '';
        b.purpose = '';
        b.headCount = 0;
        b.classificationAmount = 0;
        b.ETL = False;
        b.reclassification = '';
        b.isDelete = True;
        
		DeleteDetail.add(b);
        
        ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine(payment[0].Id, False, False);
        ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine(payment[0].Id, True, False);
        ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine(payment[0].Id, False, True);
        
        ASI_MFM_CN_StructureCost_Main_Ctrl.savePaymentLine(upsertDetail, DeleteDetail, payment[0].Id, 3000, 2830.19, true, true, false, false, 'test', 1500, 1500);
        DeleteDetail = new List<ASI_MFM_CN_StructureCost_Main_Ctrl.paymentLine>();
        ASI_MFM_CN_StructureCost_Main_Ctrl.savePaymentLine(upsertDetail, DeleteDetail, payment[0].Id, 3000, 2830.19, false, true, false, false, 'test', 1500, 1500);
        ASI_MFM_CN_StructureCost_Main_Ctrl.savePaymentLine(upsertDetail, DeleteDetail, payment[0].Id, 3001, 2830.19, false, true, false, false, 'test', 1500, 1500);
        ASI_MFM_CN_StructureCost_Main_Ctrl.savePaymentLine(upsertDetail, DeleteDetail, payment[0].Id, 3001, 2830.19, true, true, false, false, 'test', 1500, 1500);
        
        ASI_MFM_CN_StructureCost_Main_Ctrl.savePaymentLine(upsertDetail, DeleteDetail, payment[0].Id, 3000, 2830.19, false, false, true, false, 'test', 1500, 1500);
        ASI_MFM_CN_StructureCost_Main_Ctrl.savePaymentLine(upsertDetail, DeleteDetail, payment[0].Id, 3000, 2830.19, false, false, false, true, 'test', 1500, 1500);
        
        con.paymentHeader.ASI_MFM_Prefix__c = null;
        con.save();
        
        con.paymentHeader.ASI_MFM_Prefix__c = prefixs[0].id;
        con.paymentHeader.ASI_MFM_Expense_Date_From__c = null;
        con.save();
        
        con.paymentHeader.ASI_MFM_Tax_Code__c = Null;
        con.save();
        
        con.paymentHeader.ASI_MFM_Tax_Code__c = taxcode[0].id;
        con.paymentHeader.ASI_MFM_Pre_payment__c = true;
        con.paymentHeader.ASI_MFM_Expense_Date_From__c = null;
        con.save();
        
        con.paymentHeader.ASI_MFM_Expense_Date_From__c = date.today().addMonths(20);
        con.paymentHeader.ASI_MFM_Expense_Date_To__c = date.today();
        con.save();
        
        con.paymentHeader.ASI_MFM_Pre_payment__c = false;
        con.paymentHeader.ASI_MFM_Period_From__c = date.today().addMonths(20);
        con.paymentHeader.ASI_MFM_Period_To__c = date.today();
        con.save();
        
        database.executeBatch(new ASI_MFM_CN_StructureCostBudget_Batch('FY1617'));
        
        payment[1].ASI_MFM_Status__c = 'Final';
        Update payment[1];
        
        database.executeBatch(new ASI_MFM_CN_StructureCost_Reverse_Batch('FY1617'));
        
        con.editClassificationLineItem();
        
        Test.stopTest();
    }
    
    Static testmethod void ASI_MFM_CN_SCPayment_PDFController_test(){
        
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
                                                            , ASI_MFM_Tax_Code__c = taxcode[0].id
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
        
        ApexPages.StandardController scon = new ApexPages.StandardController(payment[0]);
        ASI_MFM_CN_SCPayment_PDFController con = new ASI_MFM_CN_SCPayment_PDFController(scon);
        
        con.dummyVar = false;
        con.paymentID = payment[0].id;
        con.init();
        
        List<ProcessInstanceWorkitem> workitems = [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = : payment[0].id];
        
        if(workitems.size() > 0){
            Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
            approvalReq.setWorkitemId(workitems[0].Id);
            approvalReq.setAction('Reject');
            Approval.process(approvalReq);
        }
        
        
        
        ASI_MFM_CAP_CN_BudgetViewCtrl budgetviewcon = new ASI_MFM_CAP_CN_BudgetViewCtrl();
        
        budgetviewcon.counter = 0;
        budgetviewcon.list_size = 1;
        
        List<String> a = budgetviewcon.StatusMsgs;
        budgetviewcon.runSearch();
        budgetviewcon.executeRecalc();
        budgetviewcon.executeReverse();
        budgetviewcon.toggleSort();
        budgetviewcon.Beginning();
        budgetviewcon.counter = 10;
        budgetviewcon.list_size = 1;
        budgetviewcon.Previous();
        budgetviewcon.Next();
        budgetviewcon.End();
        budgetviewcon.getTotalPages();
        budgetviewcon.getPageNumber();
        budgetviewcon.getDisablePrevious();
        budgetviewcon.getDisableNext();
        String b = budgetviewcon.sortField;
        String c = budgetviewcon.sortDir;
        
        paymentline[3].ASI_MFM_Reverse_ETL__c = true;
        Update paymentline[3];
        
        Test.stopTest();
    }
    
    Static testmethod void ASI_MFM_CN_RentalRequestNewPayment_test(){
        
        createTestData();
        Test.startTest();
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Request')
                                                        , ASI_MFM_Status__c = 'Draft'
                                                        , ASI_MFM_Due_Day_Renewal_Inform__c = date.today().addDays(5)
                                                        , ASI_MFM_Lead_Time__c = 5
                                                        , ASI_MFM_Leasing_Rate_Proposal__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                        //MT@Introv 20190603 new controlling on these fields start
                                                        , ASI_MFM_Proposed_New_Space__c = 15
                                                        , ASI_MFM_Headcount_Forecast_in_3_years__c = 1
                                                        , ASI_MFM_Comment__c = ''
                                                        , ASI_MFM_Renovation_New__c = 'No Renovation'
                                                        //MT@Introv 20190603 new controlling on these fields end
                                                       ));
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval')
                                                        , ASI_MFM_Status__c = 'Draft'
                                                        , ASI_MFM_Leasing_Rate_Proposal__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                       ));
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Request_RO')
                                                        , ASI_MFM_Status__c = 'submitted'
                                                        , ASI_MFM_Current_Leasing_Renovation__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                        , ASI_MFM_Leasing_Rate_Proposal__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                       ));
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Request')
                                                        , ASI_MFM_Status__c = 'Final'
                                                        , ASI_MFM_Leasing_Rate_Proposal__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                        //MT@Introv 20190603 new controlling on these fields start
                                                        , ASI_MFM_Proposed_New_Space__c = 15
                                                        , ASI_MFM_Headcount_Forecast_in_3_years__c = 1
                                                        , ASI_MFM_Comment__c = ''
                                                        , ASI_MFM_Renovation_New__c = 'No Renovation'
                                                        //MT@Introv 20190603 new controlling on these fields end
                                                       ));
        
        Insert rentalRequest;
        
        rentalDetail.add(new ASI_MFM_Rental_Request_Line__c(ASI_MFM_Rental_Request__c = rentalRequest[0].id
                                                            , ASI_MFM_Total_Amount__c = 100
                                                            , ASI_MFM_ExpenseType__c = expenseControlForm[0].id
                                                            , ASI_MFM_Completion__c = True
                                                            , ASI_MFM_Apply_CIP_Logic__c = True
                                                            , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line')
                                                           ));
        
        rentalDetail.add(new ASI_MFM_Rental_Request_Line__c(ASI_MFM_Rental_Request__c = rentalRequest[2].id
                                                            , ASI_MFM_Total_Amount__c = 100
                                                            , ASI_MFM_ExpenseType__c = expenseControlForm[0].id
                                                            , ASI_MFM_Completion__c = True
                                                            , ASI_MFM_Apply_CIP_Logic__c = True
                                                            , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line')
                                                           ));
        
        Insert rentalDetail;
        Update rentalDetail;
        
        rentalRequest[2].ASI_MFM_Status__c = 'Final';
        Update rentalRequest[2];
        
        ApexPages.StandardController scon = new ApexPages.StandardController(rentalDetail[0]);
        
        ApexPages.currentPage().getParameters().put('id', rentalDetail[0].Id);
        
        
        ASI_MFM_CN_RentalRequestNewPayment con = new ASI_MFM_CN_RentalRequestNewPayment(scon);
        
        con.redirectToPayment();
        con.allowCreatePayment = False;
        
        con.redirectToPayment();
        
        test.setCurrentPage(page.asi_mfm_cn_rentalreuqestcreationpage);
        ApexPages.StandardController scon2 = new ApexPages.StandardController(rentalRequest[2]);
        
        ApexPages.currentPage().getParameters().put('id', rentalRequest[2].id);
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Form'));
        
        ASI_MFM_CN_RentalRequestCtrl rcon = new ASI_MFM_CN_RentalRequestCtrl(scon2);
        rcon.backToRentalRequest();
        rcon.Cancel();
        rcon.Cancel2();
        rcon.createRentalApproval();
                    
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval'));
        rcon.createRentalApproval();
        
        rcon.departmentPicklist();
        rcon.editContract();
        rcon.getrentalLine();
        rcon.getTaxCodePiskList();
        rcon.reCalculateTotal();
        rcon.modifyRenovationSection();
        
        rentalRequest[1].ASI_MFM_Related_Kickoff_Form_ID__c = rentalRequest[2].id;
        Update rentalRequest[1];
        
        rcon.createRentalApproval();
        
        ASI_MFM_CN_RentalRequestCtrl.getContractLines(rentalRequest[2].id, 'Admin', bu[0].id, false, currentUser.id);
        ASI_MFM_CN_RentalRequestCtrl.getContractLines(rentalRequest[2].id, 'Admin', bu[0].id, true, currentUser.id);
        
        List<ASI_MFM_CN_RentalRequestCtrl.contractClass> insertList = new List<ASI_MFM_CN_RentalRequestCtrl.contractClass>();
        List<ASI_MFM_CN_RentalRequestCtrl.contractClass> deleteList = new List<ASI_MFM_CN_RentalRequestCtrl.contractClass>();
        
        ASI_MFM_CN_RentalRequestCtrl.contractClass tmp = new ASI_MFM_CN_RentalRequestCtrl.contractClass();
        tmp.totalAmount = 10;
        tmp.PeriodTo = '2018-03-31';
		tmp.PeriodFrom = '2017-03-31';
        tmp.expenseTypeId = expenseControlForm[0].id;
        
        insertList.add(tmp);
        
        ASI_MFM_CN_RentalRequestCtrl.contractClass tmp2 = new ASI_MFM_CN_RentalRequestCtrl.contractClass();
        tmp.totalAmount = 10;
        tmp.expenseTypeId = expenseControlForm[0].id;
        tmp.lineId = rentalDetail[1].id;
        
        deleteList.add(tmp2);
        
        ASI_MFM_CN_RentalRequestCtrl.SaveDetailLine(insertList, deleteList, rentalRequest[2].id);
        ASI_MFM_CN_RentalRequestCtrl.saveContractLines(insertList, deleteList, rentalRequest[2].id);
        
        ASI_MFM_CN_RentalApprovalPDFController pdfcon = new ASI_MFM_CN_RentalApprovalPDFController(scon2);
        pdfcon.HeaderID = rentalRequest[2].id;
        pdfcon.init();
        
        ASI_MFM_CN_RentalRequestReminder_Schd schdCls = new ASI_MFM_CN_RentalRequestReminder_Schd();
        String sch = '0 0 23 * * ?';
        system.schedule('EventEvaluation', sch, schdCls);
        
        rentalRequest[2].recordtypeId = null;
        Update rentalRequest[2];
        ApexPages.StandardController scon3 = new ApexPages.StandardController(rentalRequest[2]);
        ASI_MFM_RentalRedirect_Ctrl redirectCon = new ASI_MFM_RentalRedirect_Ctrl(scon3);
        redirectCon.redirect();
        
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
        
        //Andy@Introv 20190603 start
        expenseControlForm.add(new ASI_MFM_Expense_Control_Form__c(Name = 'Test Furniture'
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
                                                                   , ASI_MFM_Only_Renovation_Furniture__c = True
                                                                   , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Expense_Control_Form')
                                                                  ));
        
        expenseControlForm.add(new ASI_MFM_Expense_Control_Form__c(Name = 'Test Expense'
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
                                                                   , ASI_MFM_Rental_Request_Expense__c = True
                                                                   , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Expense_Control_Form')
                                                                  ));
        //Andy@Introv 20190603 end
        
        Insert expenseControlForm;
        
        expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id
                                                                 , ASI_MFM_User__c = userInfo.getUserId()
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Expense_Control_Form_Allowed_User')
                                                                ));
        
        //Andy@Introv 20190603 start
        expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[1].id
                                                                 , ASI_MFM_User__c = userInfo.getUserId()
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Expense_Control_Form_Allowed_User')
                                                                ));
        
        expenseLine.add(new ASI_CRM_Expense_Control_Form_Line__c(ASI_MFM_Expense_Control_Form__c = expenseControlForm[2].id
                                                                 , ASI_MFM_User__c = userInfo.getUserId()
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Expense_Control_Form_Line__cASI_MFM_CN_Expense_Control_Form_Allowed_User')
                                                                ));
        //Andy@Introv 20190603 end
        
        Insert expenseLine;
        
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Renovation Form', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu[0].id, ASI_MFM_Department__c = 'Admin'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Structure Cost Payment', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu[0].id, ASI_MFM_Department__c = 'Admin'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Approval Form', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu[0].id, ASI_MFM_Department__c = 'Admin'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Request Form', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu[0].id, ASI_MFM_Department__c = 'Admin'));
        //MT@Introv 20190603 start
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Renovation Request', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu[0].id, ASI_MFM_Department__c = 'Admin'));
        //MT@Introv 20190603 end
        
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
    
    //MT@Introv 20190530 Teststart
    Static testmethod void ASI_MFM_CN_RentalRequest_TriggerCls_test(){
 
        createTestData();
        Test.startTest();
	
        //Testing on new logics in inserting the records
        //[0]:F if(obj.ASI_MFM_Renovation_New__c != 'No Renovation' && ( obj.ASI_MFM_CAPX_Budget__c == NULL || obj.ASI_MFM_CAPX_Budget__c == 0 ) )
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Request')
                                                        , ASI_MFM_Status__c = 'Draft'
                                                        , ASI_MFM_Renovation_New__c = 'New Renovation'
                                                        , ASI_MFM_CAPX_Budget__c = Null
                                                        , ASI_MFM_Proposed_New_Space__c = 1
                                                        , ASI_MFM_Headcount_Forecast_in_3_years__c = 1 
                                                        , ASI_MFM_Comment__c =''
                                                       ));
		//[1]:F checkComment: >16.69                                                       
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                       , ASI_MFM_Department__c = 'Admin'
                                                       , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Request')
                                                       , ASI_MFM_Status__c = 'Draft'
                                                       , ASI_MFM_Renovation_New__c = 'No Renovation'
                                                       , ASI_MFM_CAPX_Budget__c = Null
                                                       , ASI_MFM_Proposed_New_Space__c = 100
                                                       , ASI_MFM_Headcount_Forecast_in_3_years__c = 1
                                                       , ASI_MFM_Comment__c = ''
                                                      ));
        //[2]:T good to go Rental Request
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                       , ASI_MFM_Department__c = 'Admin'
                                                       , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Request')
                                                       , ASI_MFM_Status__c = 'Draft'
                                                       , ASI_MFM_Renovation_New__c = 'No Renovation'
                                                       , ASI_MFM_CAPX_Budget__c = Null
                                                       , ASI_MFM_Proposed_New_Space__c = 1
                                                       , ASI_MFM_Headcount_Forecast_in_3_years__c = 1
                                                       , ASI_MFM_Comment__c = ''
                                                      ));
        
        //[3]:T good to go Rental Approval_1
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                       , ASI_MFM_Department__c = 'Admin'
                                                       , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval')
                                                       , ASI_MFM_Status__c = 'Draft'
                                                       , ASI_MFM_Comment__c = ''
        												));
        
        //[4]:T good to go Rental Approval_2 [4]
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                       , ASI_MFM_Department__c = 'Admin'
                                                       , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval')
                                                       , ASI_MFM_Status__c = 'Draft'
                                                       , ASI_MFM_Comment__c = ''
                                                      ));                                                      
        //[5]:T
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                      , ASI_MFM_Department__c = 'Admin'
                                                      , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Request')
                                                      , ASI_MFM_Status__c = 'Draft'
                                                      , ASI_MFM_Comment__c = ''
                                                     ));

        //[6]:T
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                     , ASI_MFM_Department__c = 'Admin'
                                                     , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Form')
                                                     , ASI_MFM_Status__c = 'Draft'
                                                     , ASI_MFM_Comment__c = ''
                                                    ));
        //[7]:T
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                     , ASI_MFM_Department__c = 'Admin'
                                                     , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Form')
                                                     , ASI_MFM_Status__c = 'Draft'
                                                     , ASI_MFM_Comment__c = ''
                                                    ));
		//insert testing
        Database.SaveResult[] srInList_1 = Database.insert(rentalRequest, false);
        
		integer i = 0;
        
        for (Database.SaveResult sr : srInList_1) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Insert_1['+i+']: Successful ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Insert_1['+i+']: The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Insert_1['+i+']: Fields that affected this error: ' + err.getFields());
                }
            }
            i++;
        }
        
        //insert detail line for the rental approval [3] (Rental Approval)
        rentalDetail.add(new ASI_MFM_Rental_Request_Line__c(ASI_MFM_Rental_Request__c = rentalRequest[3].id
                                                            , ASI_MFM_Total_Amount__c = 100
                                                            , ASI_MFM_ExpenseType__c = expenseControlForm[0].id
                                                            , ASI_MFM_Completion__c = True
                                                            , ASI_MFM_Apply_CIP_Logic__c = True
                                                            , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line')
                                                           ));
        //insert detail line for the rental approval [6] (Renovation Form)      
        rentalDetail.add(new ASI_MFM_Rental_Request_Line__c(ASI_MFM_Rental_Request__c = rentalRequest[5].id
                                                            , ASI_MFM_Total_Amount__c = 100
                                                            , ASI_MFM_ExpenseType__c = expenseControlForm[0].id
                                                            , ASI_MFM_Completion__c = True
                                                            , ASI_MFM_Apply_CIP_Logic__c = True
                                                            , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line')
                                                           ));
        
		
        Database.SaveResult[] srInList_2 = Database.insert(rentalDetail, false);
        i=0;
        for (Database.SaveResult sr : srInList_2) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Insert_2['+i+']: successful ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Insert_2['+i+']: The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Insert_2['+i+']: Fields that affected this error: ' + err.getFields());
                }
            }
            i++;
        }
        
        
        //update testing
		rentalRequest[2].ASI_MFM_Comment__c = 'Updated';
		rentalRequest[3].ASI_MFM_Comment__c = 'Updated';
		rentalRequest[4].ASI_MFM_Comment__c = 'Updated';
		rentalRequest[5].ASI_MFM_Comment__c = 'Updated';
		rentalRequest[6].ASI_MFM_Comment__c = 'Updated';
		rentalRequest[7].ASI_MFM_Comment__c = 'Updated';        
       
        List<ASI_MFM_Rental_Request__c> rentalRequest_up = new List<ASI_MFM_Rental_Request__c> ();
        
        rentalRequest_up.add(rentalRequest[2]);
        rentalRequest_up.add(rentalRequest[3]);
        rentalRequest_up.add(rentalRequest[4]);
        rentalRequest_up.add(rentalRequest[5]);
        rentalRequest_up.add(rentalRequest[6]);
        rentalRequest_up.add(rentalRequest[7]);        
        
        
		Database.SaveResult[] srUpList_1 = Database.update(rentalRequest_up, false);
        i=0;
        for (Database.SaveResult sr : srUpList_1) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Update_1['+i+']: successful ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Update_1['+i+']: The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Update_1['+i+']: Fields that affected this error: ' + err.getFields());
                }
            }
            i++;
        }
        
		//draft to submitted test
		rentalRequest[3].ASI_MFM_Status__c = 'Submitted';
		rentalRequest[4].ASI_MFM_Status__c = 'Submitted';
		rentalRequest[6].ASI_MFM_Status__c = 'Submitted';
		rentalRequest[7].ASI_MFM_Status__c = 'Submitted'; 
        
        rentalRequest[3].recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval_RO');
		rentalRequest[4].recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval_RO');
		rentalRequest[6].recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Form_RO');
		rentalRequest[7].recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Form_RO');
        
        rentalRequest_up.clear();
        rentalRequest_up.add(rentalRequest[3]);
        rentalRequest_up.add(rentalRequest[4]);
        rentalRequest_up.add(rentalRequest[6]);
        rentalRequest_up.add(rentalRequest[7]);      
        
        
        Database.SaveResult[] srUpList_2 = Database.update(rentalRequest_up, false);
        i=0;
        for (Database.SaveResult sr : srUpList_2) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Update_2['+i+']: successful ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Update_2['+i+']: The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Update_2['+i+']: Fields that affected this error: ' + err.getFields());
                }
            }
            i++;
        }
        
        Test.stopTest();

    }
    //MT@Introv 20190530 end
    
    //Andy@Introv 20190603 start
    Static testmethod void ASI_MFM_CN_RentalRequestNewPayment_test2(){
        
        createTestData();
        Test.startTest();
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Request')
                                                        , ASI_MFM_Status__c = 'Draft'
                                                        , ASI_MFM_Due_Day_Renewal_Inform__c = date.today().addDays(5)
                                                        , ASI_MFM_Lead_Time__c = 5
                                                        , ASI_MFM_Leasing_Rate_Proposal__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                        //MT@Introv 20190603 new controlling on these fields start
                                                        , ASI_MFM_Proposed_New_Space__c = 15
                                                        , ASI_MFM_Headcount_Forecast_in_3_years__c = 1
                                                        , ASI_MFM_Comment__c = ''
                                                        , ASI_MFM_Renovation_New__c = 'No Renovation'
                                                        //MT@Introv 20190603 new controlling on these fields end
                                                       ));
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval')
                                                        , ASI_MFM_Status__c = 'Draft'
                                                        , ASI_MFM_Leasing_Rate_Proposal__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                       ));
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Request_RO')
                                                        , ASI_MFM_Status__c = 'submitted'
                                                        , ASI_MFM_Current_Leasing_Renovation__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                        , ASI_MFM_Leasing_Rate_Proposal__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                       ));
        
        rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu[0].id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Request')
                                                        , ASI_MFM_Status__c = 'Final'
                                                        , ASI_MFM_Leasing_Rate_Proposal__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                                        //MT@Introv 20190603 new controlling on these fields start
                                                        , ASI_MFM_Proposed_New_Space__c = 15
                                                        , ASI_MFM_Headcount_Forecast_in_3_years__c = 1
                                                        , ASI_MFM_Comment__c = ''
                                                        , ASI_MFM_Renovation_New__c = 'No Renovation'
                                                        //MT@Introv 20190603 new controlling on these fields end
                                                       ));
        
        Insert rentalRequest;
        
        rentalDetail.add(new ASI_MFM_Rental_Request_Line__c(ASI_MFM_Rental_Request__c = rentalRequest[0].id
                                                            , ASI_MFM_Total_Amount__c = 100
                                                            , ASI_MFM_ExpenseType__c = expenseControlForm[0].id
                                                            , ASI_MFM_Completion__c = True
                                                            , ASI_MFM_Apply_CIP_Logic__c = True
                                                            , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line')
                                                           ));
        
        rentalDetail.add(new ASI_MFM_Rental_Request_Line__c(ASI_MFM_Rental_Request__c = rentalRequest[2].id
                                                            , ASI_MFM_Total_Amount__c = 100
                                                            , ASI_MFM_ExpenseType__c = expenseControlForm[0].id
                                                            , ASI_MFM_Completion__c = True
                                                            , ASI_MFM_Apply_CIP_Logic__c = True
                                                            , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line')
                                                           ));
        
        Insert rentalDetail;
        Update rentalDetail;
        
        rentalRequest[2].ASI_MFM_Status__c = 'Final';
        Update rentalRequest[2];
        
        ApexPages.StandardController scon = new ApexPages.StandardController(rentalDetail[0]);
        
        ApexPages.currentPage().getParameters().put('id', rentalDetail[0].Id);
        
        
        ASI_MFM_CN_RentalRequestNewPayment con = new ASI_MFM_CN_RentalRequestNewPayment(scon);
        
        con.redirectToPayment();
        con.allowCreatePayment = False;
        
        con.redirectToPayment();
        
        test.setCurrentPage(page.asi_mfm_cn_rentalreuqestcreationpage);
        ApexPages.StandardController scon2 = new ApexPages.StandardController(rentalRequest[2]);
        
        ApexPages.currentPage().getParameters().put('id', rentalRequest[2].id);
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Request'));
        
        ASI_MFM_CN_RentalRequestCtrl rcon = new ASI_MFM_CN_RentalRequestCtrl(scon2);
        rcon.backToRentalRequest();
        rcon.Cancel();
        rcon.Cancel2();
        rcon.createRentalApproval();
                    
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval'));
        rcon.createRentalApproval();
        
        rcon.departmentPicklist();
        rcon.editContract();
        rcon.getrentalLine();
        rcon.getTaxCodePiskList();
        rcon.reCalculateTotal();
        rcon.modifyRenovationSection();
        
        rentalRequest[1].ASI_MFM_Related_Kickoff_Form_ID__c = rentalRequest[2].id;
        Update rentalRequest[1];
        
        rcon.createRentalApproval();
        
        ASI_MFM_CN_RentalRequestCtrl.getContractLines(rentalRequest[2].id, 'Admin', bu[0].id, false, currentUser.id);
        ASI_MFM_CN_RentalRequestCtrl.getContractLines(rentalRequest[2].id, 'Admin', bu[0].id, true, currentUser.id);
        
        List<ASI_MFM_CN_RentalRequestCtrl.contractClass> insertList = new List<ASI_MFM_CN_RentalRequestCtrl.contractClass>();
        List<ASI_MFM_CN_RentalRequestCtrl.contractClass> deleteList = new List<ASI_MFM_CN_RentalRequestCtrl.contractClass>();
        
        ASI_MFM_CN_RentalRequestCtrl.contractClass tmp = new ASI_MFM_CN_RentalRequestCtrl.contractClass();
        tmp.totalAmount = 10;
        tmp.PeriodTo = '2018-03-31';
		tmp.PeriodFrom = '2017-03-31';
        tmp.expenseTypeId = expenseControlForm[0].id;
        
        insertList.add(tmp);
        
        ASI_MFM_CN_RentalRequestCtrl.contractClass tmp2 = new ASI_MFM_CN_RentalRequestCtrl.contractClass();
        tmp.totalAmount = 10;
        tmp.expenseTypeId = expenseControlForm[0].id;
        tmp.lineId = rentalDetail[1].id;
        
        deleteList.add(tmp2);
        
        ASI_MFM_CN_RentalRequestCtrl.SaveDetailLine(insertList, deleteList, rentalRequest[2].id);
        ASI_MFM_CN_RentalRequestCtrl.saveContractLines(insertList, deleteList, rentalRequest[2].id);
        
        ASI_MFM_CN_RentalApprovalPDFController pdfcon = new ASI_MFM_CN_RentalApprovalPDFController(scon2);
        pdfcon.HeaderID = rentalRequest[2].id;
        pdfcon.init();
        
        ASI_MFM_CN_RentalRequestReminder_Schd schdCls = new ASI_MFM_CN_RentalRequestReminder_Schd();
        String sch = '0 0 23 * * ?';
        system.schedule('EventEvaluation', sch, schdCls);
        
        rentalRequest[2].recordtypeId = null;
        Update rentalRequest[2];
        ApexPages.StandardController scon3 = new ApexPages.StandardController(rentalRequest[2]);
        ASI_MFM_RentalRedirect_Ctrl redirectCon = new ASI_MFM_RentalRedirect_Ctrl(scon3);
        redirectCon.redirect();
        
        Test.stopTest();
    }
    //Andy@Introv 20190603 end
}