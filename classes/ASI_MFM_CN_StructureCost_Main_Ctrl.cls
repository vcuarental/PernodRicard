Global with Sharing class ASI_MFM_CN_StructureCost_Main_Ctrl {
    
    //Global List<paymentLine> paymentLineClass {Get; Set;}{paymentLineClass = new List<paymentLine>();}
    
    Public String pageId {Get; Set;}
    Public ASI_MFM_Payment__c paymentHeader {Get; Set;}
    Public List<ASI_MFM_Payment_Detail__c> paymentAdjustmentLine {Get; Set;}{paymentAdjustmentLine = new List<ASI_MFM_Payment_Detail__c>();}
    Public List<ASI_MFM_Payment_Detail__c> paymentLine {Get; Set;}{paymentLine = new List<ASI_MFM_Payment_Detail__c>();}
    Public List<ASI_MFM_Payment_Detail__c> allocationLine {Get; Set;}{allocationLine = new List<ASI_MFM_Payment_Detail__c>();}
    Public List<ASI_MFM_Payment_Detail__c> accrualLine {Get; Set;}{accrualLine = new List<ASI_MFM_Payment_Detail__c>();}
    Public List<ASI_MFM_Payment_Detail__c> classificationLine {Get; Set;}{classificationLine = new List<ASI_MFM_Payment_Detail__c>();}
    
    //picklist
    Public Map<String, List<SelectOption>> expenseTypeOption {Get; Set;}
    Public List<SelectOption> departmentOption {Get; Set;}{departmentOption = new List<SelectOption>();}
    Public List<SelectOption> expenseType {Get; Set;}
    Public Map<String, List<SelectOption>> mapClassificationList {Get; Set;}
    Public List<SelectOption> classification {Get; Set;}
    Public String classificationPicklist {Get; Set;}
    Public String purposePicklist {Get; Set;}
    
    //Prefix
    public list<selectOption> available_prefixes {get; private set;}
    public string selected_prefix {get; set;}
    public Map<id, asi_mfm_prefix__c> prefixMap {get; set;}{prefixMap = new Map<Id, asi_mfm_prefix__c>();}
    
    //------------
    Public Boolean accrualPaymentform {Get; Set;}{accrualPaymentform = False;}
    Public Boolean refresh {Get; Set;}{refresh = False;}
    Public Boolean isRental {Get; Set;}{isRental = False;}
    Public Boolean needInit {Get; Set;}{needInit = True;}
    Public Boolean isClassification {Get; Set;}{isClassification = False;}
    Public Boolean isAccrual {Get; Set;}{isAccrual = False;}
    Public Boolean isAdmin {Get; Set;}{isAdmin = False;}
    Public Boolean isApprover {Get; Set;}{isApprover = False;}
    Public Boolean isPendingForFinance {Get; Set;}{isPendingForFinance = False;}	//20191021:AM@Introv - allow G/L date and Invoice Number to be optional
    
    //Master data
    Public Map<Id, ASI_MFM_Tax_Code__c> TaxCode_List {Get; Set;}{TaxCode_List = new Map<id, ASI_MFM_Tax_Code__c>([Select id, Name, ASI_MFM_VAT_Rate__c, ASI_MFM_Manual_Input__c from ASI_MFM_Tax_Code__c WHERE recordType.developerName Like 'ASI_MFM_CN_Tax_Code']);}
    //Public Map<Id, Id> mapACCode {Get; Set;}{mapACCode = new Map<Id, Id>();}
    //Public Map<Id, ASI_CRM_Expense_Control_Form_Line__c> mapExpenseType {Get; Set;}{mapExpenseType = new Map<Id, ASI_CRM_Expense_Control_Form_Line__c>();}
    
    Public ASI_MFM_CN_StructureCost_Main_Ctrl(apexPages.StandardController stdc){
        
        init();
    }
    
    Public void init(){
        
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>([SELECT id FROM PermissionSetAssignment WHERE AssigneeId = : userInfo.getUserId() AND PermissionSet.Name Like '%ASI_MFM_CN_StructureCost_AdminUser%']);
        if(psa.size() > 0)
            isAdmin = True;
        
        List<GroupMember> gm = new List<GroupMember>([SELECT GroupId, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName LIKE 'ASI_MFM_CN_SC_Approver_Group' AND UserOrGroupId = : userInfo.getUserId()]);
        if(gm.size() > 0)
            isApprover = True;
        
        if(needInit){
            if(ApexPages.currentPage().getParameters().get('id') != '' && ApexPages.currentPage().getParameters().get('id') != null){
                
                pageId = ApexPages.currentPage().getParameters().get('id');
                
                paymentHeader = [SELECT id,ASI_MFM_Invoice_Date__c, ASI_MFM_Department_Text__c, ASI_MFM_Expense_Type__r.Name, ASI_MFM_Expense_Type__c, ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c, ASI_MFM_Total_Budget__c
                                 , ASI_MFM_Remaining_Budget__c, ASI_MFM_Actual_Paid_Amount__c, ASI_MFM_Expense_Date_From__c, ASI_MFM_Expense_Date_To__c, ASI_MFM_Vendor_Code__c
                                 , ASI_MFM_Bank_Account__c, ASI_MFM_Bank_Information__c, ASI_MFM_New_Bank_Account__c, ASI_MFM_Allocation_Method_Ratio__c
                                 , ASI_MFM_New_Bank_Information__c, ASI_MFM_Last_Year_Payment__c, ASI_MFM_Period_From__c, ASI_MFM_Period_To__c, ASI_MFM_Classification__c
                                 , ASI_MFM_Total_Amount_Without_Tax__c, ASI_MFM_No_Invoice_Amount__c, ASI_MFM_Allocation_Method__c, ASI_MFM_BU__c, ASI_MFM_BU__r.Name, ASI_MFM_Budget_Owner__c, ASI_MFM_Prefix__c
                                 , ASI_MFM_Pre_payment__c, ASI_MFM_Currency__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Tax_Code__c, ASI_MFM_Remarks__c, ASI_MFM_Status__c, ASI_MFM_JDE_Adjustment__c
                                 , ASI_MFM_Supplier_Name__c, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_PO__c, ASI_MFM_Prefix__r.ASI_MFM_Module__c, ASI_MFM_CN_Fiscal_Year__c//, ASI_MFM_PaymentDate__c
                                 , ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_Payment_Amount_RMB__c, ASI_MFM_G_L_Date__c, ASI_MFM_Accrual_ETL__c, ASI_MFM_Accrual_Date__c
                                 , ASI_MFM_Receipt_ETL__c, ASI_MFM_Receipt_No__c, ASI_MFM_Receipt_Date__c, ASI_MFM_ETL__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Accrual_Type__c, ASI_MFM_PO__r.ASI_MFM_CN_Amount_Ex__c
                                 , ASI_MFM_Contract__c, ASI_MFM_Remaining_Contract_Amount__c, ASI_MFM_Accrual_Voucher__c, ASI_MFM_Non_VAT_Amount_RMB__c, ASI_MFM_Invoice_Amount__c, ASI_MFM_VAT_Amount__c, ASI_MFM_Normal_Invoice_Amount__c
                                 , ASI_MFM_Expense_Type__r.ASI_MFM_Allocation__c, ASI_MFM_Expense_Type__r.ASI_MFM_BudgetControlLevel__c, ASI_MFM_Expense_Type__r.ASI_MFM_BudgetControlMethod__c, ASI_MFM_Expense_Type__r.ASI_MFM_Reclassification__c
                                 , ASI_MFM_Expense_Type__r.ASI_MFM_Subledger__c, ASI_MFM_Expense_Type__r.ASI_MFM_Subledger_Options__c, ASI_MFM_StructureCost_Line_Checking__c, ASI_MFM_Contract__r.ASI_MFM_Total_Amount__c
                                 , ASI_MFM_Contract__r.ASI_MFM_CIP_Amount__c, ASI_MFM_Contract__r.ASI_MFM_Paid_Amount__c, ASI_MFM_Completion__c, ASI_MFM_Rental_Deposit_Invoice__c, ASI_MFM_Rental_Deposit__c
                                 , ASI_MFM_Invoice_Afterwards__c, ASI_MFM_Contract__r.ASI_MFM_Contract__c,  ASI_MFM_Apply_CIP_Logic__c, ASI_MFM_Total_Non_Sales_Allocated_Amount__c, ASI_MFM_Total_Sales_Allocated_Amount__c
                                 , OwnerId, ASI_MFM_Pass_Verification__c
                                 , (SELECT id, recordType.DeveloperName, recordTypeId, ASI_MFM_A_C_Code__c, ASI_MFM_Accrual_ETL__c, ASI_MFM_Accrual_Reverse_Amount__c, ASI_MFM_Accrual_Reverse_Budget__c, ASI_MFM_Amount__c
                                    , ASI_MFM_Document_Number__c, ASI_MFM_Document_Type__c, ASI_MFM_Employee_Allocated_Amount__c, ASI_MFM_Employee_Allocated_Percent__c, ASI_MFM_Employee_Code__c,  ASI_MFM_Fiscal_Year__c
                                    , ASI_MFM_GL_date__c, ASI_MFM_Non_Sales_Allocated_Amount__c, ASI_MFM_Non_Sales_Allocated_Percent__c, ASI_MFM_Payment__c, ASI_MFM_Remark__c, ASI_MFM_Reverse_ETL__c
                                    , ASI_MFM_Sales_Allocated_Amount__c, ASI_MFM_Sales_Allocated_Percent__c, ASI_MFM_Subledger__c, ASI_MFM_Non_VAT_Amount_RMB__c, ASI_MFM_Reclassification__c
                                    , ASI_MFM_Purpose__c, ASI_MFM_Headcount__c FROM Payment_Details__r)
                                 FROM ASI_MFM_Payment__c WHERE id = : pageId];
                
                for(ASI_MFM_Payment_Detail__c obj : paymentHeader.Payment_Details__r){
                    
                    if(obj.recordType.DeveloperName.contains('ASI_MFM_CAP_CN_Accrual_Detail')){
                        
                        accrualLine.add(obj);
                    }else if(obj.recordType.DeveloperName.contains('ASI_MFM_CAP_CN_Expense_Adjustment')){
                        
                        paymentAdjustmentLine.add(obj);
                    }else if(obj.recordType.DeveloperName.contains('ASI_MFM_CAP_CN_Payment_Allocation')){
                        
                        allocationLine.add(obj);
                    }else if(obj.recordType.DeveloperName.contains('ASI_MFM_CAP_CN_Payment_Detail')){
                        
                        paymentLine.add(obj);
                    }else if(obj.recordType.DeveloperName.contains('ASI_MFM_CN_Classification_Line')){
                        
                        classificationLine.add(obj);
                    }
                }
                
                //20191021:AM@Introv - allow G/L date and Invoice Number to be optional
                if(paymentHeader.ASI_MFM_Status__c == 'Pending For Finance'){
                    isPendingForFinance = TRUE;
                }
                
                if(paymentHeader.ASI_MFM_Contract__c != Null){
                    isRental = True;
                }
                
                if(paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_Reclassification__c != Null){
                    
                    classificationPicklist = '';
                    
                    if(!paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_Subledger__c)
                        classificationPicklist += '<option value=""></option>';
                    
                    for(string s : paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_Reclassification__c.split(';')){
                        classificationPicklist += '<option value="' + s.replace('\'', '\\\'') + '">' + s.replace('\'', '\\\'') + '</option>';
                    }
                }
                
                if(paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_Subledger_Options__c != Null){
                    
                    purposePicklist = '';
                    purposePicklist += '<option value=""></option>';
                    
                    for(string s : paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_Subledger_Options__c.split(';')){
                        purposePicklist += '<option value="' + s.replace('\'', '\\\'') + '">' + s.replace('\'', '\\\'') + '</option>';
                    }
                }
                
                
                accrualPaymentform = paymentHeader.ASI_MFM_Prefix__r.ASI_MFM_Module__c == 'Structure Cost Accrual' ? true : false;
            }
            
            needInit = False;
        }
    }
    
    Public void expenseControlFormSelection(){
        
        if(paymentHeader.ASI_MFM_Prefix__c != Null){
            ASI_MFM_Prefix__c px = [SELECT id, ASI_MFM_Module__c FROM ASI_MFM_Prefix__c WHERE id = : paymentHeader.ASI_MFM_Prefix__c];
            accrualPaymentform = px.ASI_MFM_Module__c == 'Structure Cost Accrual' ? true : false;
        }else{
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Prefix cannot be null'));
        }
        
        Id userId = paymentHeader.id == Null ? userinfo.getUserId() : paymentHeader.OwnerId;
        
        List<ASI_CRM_Expense_Control_Form_Line__c> expenseControlList = new List<ASI_CRM_Expense_Control_Form_Line__c>([SELECT id
                                                                                                                        , ASI_MFM_Expense_Control_Form__r.Name
                                                                                                                        , ASI_MFM_Expense_Control_Form__r.ASI_MFM_BudgetOwner__c
                                                                                                                        , ASI_MFM_Expense_Control_Form__r.ASI_MFM_Subledger__c
                                                                                                                        , ASI_MFM_Expense_Control_Form__r.ASI_MFM_Reclassification__c
                                                                                                                        , ASI_MFM_Expense_Control_Form__c
                                                                                                                        , ASI_MFM_Expense_Control_Form__r.ASI_MFM_BU__c
                                                                                                                        , ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c
                                                                                                                        , ASI_MFM_Expense_Control_Form__r.ASI_MFM_ExpenseType__c
                                                                                                                        , RecordType.developerName
                                                                                                                        FROM ASI_CRM_Expense_Control_Form_Line__c 
                                                                                                                        WHERE ASI_MFM_User__c = : userId
                                                                                                                        AND RecordType.developerName LIKE 'ASI_MFM_CN_Expense_Control_Form_Allowed_User'
                                                                                                                        //OR RecordType.developerName LIKE 'ASI_MFM_CN_Expense_Control_Form_Line'
                                                                                                                        AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_Rental_Request_Expense__c != True
                                                                                                                        AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_Only_Renovation_Furniture__c != True
                                                                                                                        Order By ASI_MFM_Expense_Control_Form__r.ASI_MFM_ExpenseType__c]);
        Set<String> deparmentSet = new Set<String>();
        Set<Id> expenseTypeId = new Set<Id>();
        expenseTypeOption = new Map<String, List<SelectOption>>();
        mapClassificationList = new Map<String, List<SelectOption>>();
        
        if(expenseControlList.size() > 0){
            for(ASI_CRM_Expense_Control_Form_Line__c ecf : expenseControlList){
                
                //Map Expense Type
                //if(!mapExpenseType.containsKey(ecf.ASI_MFM_Expense_Control_Form__c)){
                    
                    //mapExpenseType.put(ecf.ASI_MFM_Expense_Control_Form__c, ecf);
                //}
                
                //Classification Picklist
                if(ecf.RecordType.developerName == 'ASI_MFM_CN_Expense_Control_Form_Allowed_User'){
                    if(!mapClassificationList.containsKey(ecf.ASI_MFM_Expense_Control_Form__c)){
                        if(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Reclassification__c != Null){
                            
                            List<SelectOption> tmp = new List<SelectOption>();
                            
                            if(!ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Subledger__c)
                                tmp.add(new SelectOption('', 'None'));
                            
                            for(string s : ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Reclassification__c.split(';')){
                                
                                tmp.add(new SelectOption(s, s));
                            }
                            
                            mapClassificationList.put(ecf.ASI_MFM_Expense_Control_Form__c, tmp);
                        }
                    }
                    
                    //Department Picklist
                    if(!deparmentSet.contains(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c)){
                        deparmentSet.add(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c);
                        departmentOption.add(new SelectOption(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c, ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c));
                    }
                    
                    if(!expenseTypeId.contains(ecf.ASI_MFM_Expense_Control_Form__c)){// duplication check
                        //Expense Type Picklist
                        String key = '' + ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_BU__c + ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c;
                        
                        List<SelectOption> tmpOption = new List<SelectOption>();
                        
                        if(expenseTypeOption.containsKey(key)){
                            tmpOption.addAll(expenseTypeOption.get(key));
                        }
                        
                        if((paymentHeader.ASI_MFM_Department_Text__c == Null || paymentHeader.ASI_MFM_Department_Text__c == '') && pageId == Null)
                            paymentHeader.ASI_MFM_Department_Text__c = ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c;
                        
                        tmpOption.add(new SelectOption(ecf.ASI_MFM_Expense_Control_Form__c, ecf.ASI_MFM_Expense_Control_Form__r.Name));
                        
                        expenseTypeOption.put(key, tmpOption);
                        expenseTypeId.add(ecf.ASI_MFM_Expense_Control_Form__c);
                    }
                }
            }
            
            if(paymentHeader.ASI_MFM_BU__c != Null && paymentHeader.ASI_MFM_Department_Text__c != Null && paymentHeader.ASI_MFM_Department_Text__c != '' && expenseTypeOption.containsKey('' + paymentHeader.ASI_MFM_BU__c + paymentHeader.ASI_MFM_Department_Text__c)){
                
                expenseType = expenseTypeOption.get('' + paymentHeader.ASI_MFM_BU__c + paymentHeader.ASI_MFM_Department_Text__c);
                classification = mapClassificationList.containsKey(paymentHeader.ASI_MFM_Expense_Type__c) ? mapClassificationList.get(paymentHeader.ASI_MFM_Expense_Type__c) : new List<SelectOption>();
            }
        }
    }
    
    //Select Prefix
    public pageReference getPrefixes() {
        
        //asi_mfm_prefix__c rentalPrefix = new asi_mfm_prefix__c();
        String contractid = ApexPages.currentPage().getParameters().get('contractid');
        available_prefixes = new list<selectOption>();
        list<selectOption> available_prefixes2 = new list<selectOption>();
        List<asi_mfm_prefix__c> rentalprefixList = new List<asi_mfm_prefix__c>();
        
        user u = [select userRole.developerName, asi_mfm_country__c, companyName from user where id = :userInfo.getUserId()];
        
        if (u.companyName != 'Pernod Ricard China') {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input payments');
            apexpages.addmessage(err); 
        }else {
            
            for (asi_mfm_prefix__c px:[select id, name, ASI_MFM_Location__c, ASI_MFM_Module__c from asi_mfm_prefix__c where ASI_MFM_Inactive__c = false and asi_mfm_module__c Like 'Structure Cost%' and (NOT asi_mfm_module__c Like '%Budget%') and recordtype.developerName like 'ASI_MFM_CN_Prefix' order by name]) {
                
                prefixMap.put(px.id, px);
                
                if(!px.asi_mfm_module__c.contains('Structure Cost Rental Payment')){
                    available_prefixes2.add(new SelectOption(px.id, px.Name));
                }
                
                if(px.asi_mfm_module__c.contains('Structure Cost Rental Payment')){
                    //rentalPrefix = px;
                    rentalprefixList.add(px);
                }
            }           
            if (available_prefixes2.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input payments');
                apexpages.addmessage(err);
            }
            else if ((contractid != Null && contractid != '')) {
                
                available_prefixes.add(new selectOption('', '-- None --'));
                for(asi_mfm_prefix__c rentalPrefix : rentalprefixList)
                    available_prefixes.add(new SelectOption(rentalPrefix.id, rentalPrefix.Name));
            }
            else {
                
                available_prefixes.add(new selectOption('', '-- None --'));
                available_prefixes.addAll(available_prefixes2);
            }
        }       
        return null;
    }
    
    public pageReference proceed() {
        
        if (selected_prefix == null || selected_prefix == '') {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Please select prefix first');
            apexpages.addmessage(err); 
            return null;            
        }
        
        String contractid = ApexPages.currentPage().getParameters().get('contractid');
        String bu = ApexPages.currentPage().getParameters().get('bu');
        String department = ApexPages.currentPage().getParameters().get('department');
        String expensetype = ApexPages.currentPage().getParameters().get('expensetype');
        String completion = ApexPages.currentPage().getParameters().get('completion');
        String taxCode = ApexPages.currentPage().getParameters().get('taxCode');
        
        /*String url = '';
        if(contractid != Null && contractid != '')
            url = '/apex/ASI_MFM_CN_StructureCost_Edit_Page' + '?prefixId=' + selected_prefix + '&contractid=' + contractId + '&bu=' + bu + '&department=' + department + '&expensetype=' + expensetype + '&isrental=true';
        else 
            url = '/apex/ASI_MFM_CN_StructureCost_Edit_Page' + '?prefixId=' + selected_prefix;
        
        return new PageReference(url);*/
        
        paymentHeader = new ASI_MFM_Payment__c(ASI_MFM_Status__c = 'Draft', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_CN_StructureCost_Payment'), ASI_MFM_Currency__c = 'RMB');
        
        paymentHeader.ASI_MFM_Prefix__c = selected_prefix;
        
        if(prefixMap.get(selected_prefix).ASI_MFM_Module__c.contains('Structure Cost Accrual')){
            paymentHeader.ASI_MFM_Accrual_Date__c = date.today();
            if(date.today().month() == 6)
                paymentHeader.ASI_MFM_Accrual_Type__c = 'Year End Accrual';
            else
                paymentHeader.ASI_MFM_Accrual_Type__c = 'Monthly Accrual';
        }
        
        if(contractid != Null && contractid != ''){
            isRental = true;
        }
        
        if(isRental){
            paymentHeader.ASI_MFM_Department_Text__c = department;
            paymentHeader.ASI_MFM_BU__c = bu;
            paymentHeader.ASI_MFM_Contract__c = contractid;
            paymentHeader.ASI_MFM_Expense_Type__c = expensetype;
            paymentHeader.ASI_MFM_Completion__c = Boolean.valueOf(completion);
            paymentHeader.ASI_MFM_Tax_Code__c = taxCode;
            paymentHeader.ASI_MFM_isRental_Payment__c = True;
        }
        
        Return redirectToPage('/apex/ASI_MFM_CN_StructureCost_Edit_Page', null, false); 
    }
    //Select Prefix End
    
    //Main Page Function add allocation line item
    Public pageReference editLineItem(){
        
        isClassification = False;
        isAccrual = False;
        
        return redirectToPage('/apex/ASI_MFM_CN_StructureCostPaymentEditLine', paymentHeader.id, false);
    }
    
    //Main Page Function add allocation line item
    Public pageReference editClassificationLineItem(){
        
        isClassification = True;
        isAccrual = False;
        
        return redirectToPage('/apex/ASI_MFM_CN_StructureCostPaymentEditLine', paymentHeader.id, false);
    }
    
    Public pageReference editAccrualLineItem(){
        
        isClassification = False;
        isAccrual = True;
        
        return redirectToPage('/apex/ASI_MFM_CN_StructureCostPaymentEditLine', paymentHeader.id, false);
    }
    
    Public pageReference submitForApproval(){
        
        if(paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_Subledger__c && ( classificationLine.size() == 0 || classificationLine == Null )){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Please input Reclassification line before submit for approval.'));
            return null;
        }
        
        if(paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_Allocation__c && ( allocationLine.size() == 0 || allocationLine == Null )){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Please input Allocation line before submit for approval.'));
            return null;
        }
        
        if(!paymentHeader.ASI_MFM_StructureCost_Line_Checking__c){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Please adjust Allocation & Classification line amount before submit for approval.'));
            return null;
        }
        
        if(paymentHeader.ASI_MFM_Exchange_Rate__c == Null || paymentHeader.ASI_MFM_Exchange_Rate__c == 0){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Exchange Rate cannot be found in system, please contact admin.'));
            return null;
        }
        
        if(isRental){
            //20190324-Andy: CR#88-add a new field  “Total Paid Amount with VAT & Deposit”
            ASI_MFM_Rental_Request_Line__c rentalContract = new ASI_MFM_Rental_Request_Line__c();
            rentalContract = [SELECT id, ASI_MFM_Total_Amount__c, ASI_MFM_Paid_Amount__c, ASI_MFM_Total_Paid_Amount_w_VAT__c FROM ASI_MFM_Rental_Request_Line__c WHERE id = : paymentHeader.ASI_MFM_Contract__c];
            Double paidAmount = rentalContract.ASI_MFM_Paid_Amount__c != Null ? rentalContract.ASI_MFM_Paid_Amount__c : 0;
            Double totalContractAmount = rentalContract.ASI_MFM_Total_Amount__c != Null ? rentalContract.ASI_MFM_Total_Amount__c : 0;
            Double paidAmountWVAT = rentalContract.ASI_MFM_Total_Paid_Amount_w_VAT__c != Null ? rentalContract.ASI_MFM_Total_Paid_Amount_w_VAT__c : paidAmount;
            
            AggregateResult[] oAggDeposit = [SELECT SUM(ASI_MFM_Rental_Deposit__c) sum_deposit FROM ASI_MFM_Payment__c WHERE id != :paymentHeader.id AND ASI_MFM_Contract__c = :paymentHeader.ASI_MFM_Contract__c AND ASI_MFM_Status__c NOT IN ('Draft','Invalid','Rejected','Cancelled')];
            Object oResult = oAggDeposit[0].get('sum_deposit');
            Double dTotalDeposit = 0.00;
            if (oResult != NULL) dTotalDeposit = (Double)oResult;
            system.debug('dTotalDeposit:'+dTotalDeposit);
            
            //if(totalContractAmount - paidAmount - paymentHeader.ASI_MFM_Payment_Amount_RMB__c < 0){
            //20200618:KL@Introv Start
            //if(totalContractAmount - paidAmountWVAT - paymentHeader.ASI_MFM_Payment_Amount_RMB__c < 0){
            //20200618:KL@Introv End
            if(totalContractAmount - paidAmountWVAT - paymentHeader.ASI_MFM_Payment_Amount_RMB__c + paymentHeader.ASI_MFM_Rental_Deposit__c + dTotalDeposit  < 0){
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Total payment amount over total contract amount, please revise your payment.'));
                return null;
            }
            
        }
        
        ASI_MFM_PO__c currentBudget = ASI_MFM_CN_StructureCostHelperClass.queryBudget(null, null, paymentHeader.ASI_MFM_PO__c)[0];//[SELECT id, ASI_MFM_CN_Amount_Ex__c, ASI_MFM_Previous_FY_Prepayment_Amount__c, ASI_MFM_Status__c FROM ASI_MFM_PO__c WHERE Id = : paymentHeader.ASI_MFM_PO__c];
        
        if(currentBudget.ASI_MFM_Status__c != 'Final'){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'The current budget status is "Draft", you are not allowed to submit payment, please contact Admin'));
            return null;
        }
        
        Double paymentAmount = paymentHeader.ASI_MFM_Pre_payment__c ? ASI_MFM_CN_StructureCostHelperClass.calculatePrePaymentPeriod(paymentHeader, paymentHeader.ASI_MFM_Expense_Date_From__c, paymentHeader.ASI_MFM_Expense_Date_To__c, paymentHeader.ASI_MFM_CN_Fiscal_Year__c) : paymentHeader.ASI_MFM_Non_VAT_Amount_RMB__c;
        
        Set<id> tmpPayId = new Set<Id>();
        tmpPayId.add(paymentHeader.id);
        
        Set<id> tmpPOId = new Set<Id>();
        tmpPOId.add(paymentHeader.ASI_MFM_PO__c);
        
        Set<String> tmpfy = new Set<String>();
        tmpfy.add(paymentHeader.ASI_MFM_CN_Fiscal_Year__c);
        
        Boolean byExpenseType = paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_BudgetControlLevel__c == 'By Expense Type' ? True : False;
        
        Set<String> expenseTypeSet = new Set<String>();
        expenseTypeSet.add(paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c);
        
        
        Map<String, Map<String, Double>> mapAmount = ASI_MFM_CN_StructureCostHelperClass.calculateBudgetRemaining(tmpPayId, tmpPOId, tmpfy, byExpenseType, expenseTypeSet);
        
        if(paymentHeader.ASI_MFM_Expense_Type__r.ASI_MFM_BudgetControlMethod__c && ( !paymentHeader.ASI_MFM_Apply_CIP_Logic__c || (paymentHeader.ASI_MFM_Apply_CIP_Logic__c && !paymentHeader.ASI_MFM_Completion__c))){
            
            if(mapAmount.containsKey(paymentHeader.ASI_MFM_PO__c)){
                if((currentBudget.ASI_MFM_CN_Amount_Ex__c - (currentBudget.ASI_MFM_Previous_FY_Prepayment_Amount__c != Null ? currentBudget.ASI_MFM_Previous_FY_Prepayment_Amount__c : 0) - paymentAmount - mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('ActualAmount') - mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('JDEAmount') < 0) && !byExpenseType){
                    
                    apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Over Budget ' + /*(currentBudget.ASI_MFM_CN_Amount_Ex__c + '  ' + mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('ActualAmount') + '  ' + mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('JDEAmount')) + */', Please adjust your payment.'));
                    return null;
                }else if((mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('TotalExpenseRemaining') - paymentAmount/* - mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('ActualAmount') - mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('JDEAmount')*/ < 0) && byExpenseType){
                    
                    apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Over Budget ' + /*(mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('TotalExpenseRemaining') + '  ' + mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('ActualAmount') + '  ' + mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('JDEAmount')) +*/ ', Please adjust your payment.'));
                    return null;
                }
            }else if(currentBudget.ASI_MFM_CN_Amount_Ex__c - (currentBudget.ASI_MFM_Previous_FY_Prepayment_Amount__c != Null ? currentBudget.ASI_MFM_Previous_FY_Prepayment_Amount__c : 0) - paymentAmount < 0 ){
                
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Over Budget ' + /*(currentBudget.ASI_MFM_CN_Amount_Ex__c - paymentAmount) +*/ ', Please adjust your payment.'));
                return null;
            }
        }
        
        if(paymentHeader.id != null){
            try {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(paymentHeader.id);
                req1.setSubmitterId(UserInfo.getUserId());
                Approval.ProcessResult result = Approval.process(req1);
                
                if (!result.isSuccess()){
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Record failed to submit for approval.'));
                    return null;
                }else if((accrualPaymentform && !paymentHeader.ASI_MFM_Accrual_Type__c.toLowerCase().contains('monthly accrual')) || !accrualPaymentform){
                    
                    if(paymentHeader.ASI_MFM_Apply_CIP_Logic__c && paymentHeader.ASI_MFM_Completion__c){
                        paymentAmount = 0;
                    }
                    
                    //if(( !paymentHeader.ASI_MFM_Apply_CIP_Logic__c || (paymentHeader.ASI_MFM_Apply_CIP_Logic__c && !paymentHeader.ASI_MFM_Completion__c))){
                        
                        if(mapAmount.containsKey(paymentHeader.ASI_MFM_PO__c)){
                            currentBudget.ASI_MFM_Actual_Paid_Amount__c = mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('ActualAmount') + paymentAmount;
                            currentBudget.ASI_MFM_JDE_Adjustment__c = mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('JDEAmount');
                            //currentBudget.ASI_MFM_Remaining_Budget__c = (currentBudget.ASI_MFM_CN_Amount_Ex__c - mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('ActualAmount') - mapAmount.get(paymentHeader.ASI_MFM_PO__c).get('JDEAmount') - paymentAmount);
                        }else{
                            
                            currentBudget.ASI_MFM_Actual_Paid_Amount__c = paymentAmount;
                            //currentBudget.ASI_MFM_JDE_Adjustment__c = 0;
                            //currentBudget.ASI_MFM_Remaining_Budget__c = currentBudget.ASI_MFM_CN_Amount_Ex__c - paymentAmount;
                        }
                    //}
                    
                    if(paymentHeader.ASI_MFM_Contract__c != Null){
                        try{
                            Update new ASI_MFM_Rental_Request_Line__c(id = paymentHeader.ASI_MFM_Contract__c);
                        }catch(dmlException dmle){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getMessage()));
                            return null;
                        }
                    }
                    
                    ASI_MFM_CN_StructureCostHelperClass.updateBudget(currentBudget);
                }
            }
            catch (System.DmlException e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0));
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        
        refresh = True;
        
        return redirectToPage('/apex/ASI_MFM_CN_StructureCost_MainPage', paymentHeader.id, false);
    }
    
    //Main Page Function
    Public pageReference edit(){
        
        return redirectToPage('/apex/ASI_MFM_CN_StructureCost_Edit_Page', paymentHeader.id, true);
    }
    
    //Edit Page Function
    Public void expenseTypeSelectOption(){
        
        if(paymentHeader.ASI_MFM_BU__c != Null && paymentHeader.ASI_MFM_Department_Text__c != Null && paymentHeader.ASI_MFM_Department_Text__c != '' && expenseTypeOption.containsKey('' + paymentHeader.ASI_MFM_BU__c + paymentHeader.ASI_MFM_Department_Text__c)){
            expenseType = expenseTypeOption.get('' + paymentHeader.ASI_MFM_BU__c + paymentHeader.ASI_MFM_Department_Text__c);
            
            if(expenseType.size() > 0){
                paymentHeader.ASI_MFM_Expense_Type__c = expenseType[0].getValue();
                classification = mapClassificationList.containsKey(expenseType[0].getValue()) ? mapClassificationList.get(expenseType[0].getValue()) : new List<SelectOption>();
            }
        }else{
            expenseType = new List<SelectOption>();
        }
    }
    
    //Edit Page Function
    Public void classificationSelectOption(){
        classification = mapClassificationList.containsKey(paymentHeader.ASI_MFM_Expense_Type__c) ? mapClassificationList.get(paymentHeader.ASI_MFM_Expense_Type__c) : new List<SelectOption>();
    }
    
    //Edit Page Function
    Public pageReference save(){
        
        if(paymentHeader.ASI_MFM_Prefix__c == Null){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Prefix cannot be null'));
            return null;
        }
        
        if(!accrualPaymentform && paymentHeader.ASI_MFM_Pre_payment__c && (paymentHeader.ASI_MFM_Expense_Date_From__c == Null || paymentHeader.ASI_MFM_Expense_Date_To__c == Null)){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Expense Period From and To cannot be null for Prepayment'));
            return null;
            
        }else if(!accrualPaymentform && !paymentHeader.ASI_MFM_Pre_payment__c && (paymentHeader.ASI_MFM_Period_From__c == Null || paymentHeader.ASI_MFM_Period_To__c == Null)){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Period From and To cannot be null for payment'));
            return null;
        }
        
        if(!accrualPaymentform && paymentHeader.ASI_MFM_Pre_payment__c && (paymentHeader.ASI_MFM_Expense_Date_From__c > paymentHeader.ASI_MFM_Expense_Date_To__c)){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Expense Period From cannot be greater than Expense Period To.'));
            return null;
            
        }else if(!accrualPaymentform && !paymentHeader.ASI_MFM_Pre_payment__c && (paymentHeader.ASI_MFM_Period_From__c > paymentHeader.ASI_MFM_Period_To__c)){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Period From cannot be greater than Period To.'));
            return null;
        }
        
        if(paymentHeader.ASI_MFM_Currency__c != 'RMB' && paymentHeader.ASI_MFM_Tax_Code__c != Null){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Please remove tax code for foreign payment.'));
            return null;
        }else if(paymentHeader.ASI_MFM_Currency__c == 'RMB' && paymentHeader.ASI_MFM_Tax_Code__c == Null){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Please select tax code for payment.'));
            return null;
        }
        
        if(paymentHeader.ASI_MFM_Pre_payment__c){
            
            paymentHeader.ASI_MFM_Last_Year_Payment__c = False;
            paymentHeader.ASI_MFM_Period_From__c = Null;
            paymentHeader.ASI_MFM_Period_To__c = Null;
            
        }else{
            paymentHeader.ASI_MFM_Expense_Date_From__c = Null;
            paymentHeader.ASI_MFM_Expense_Date_To__c = Null;
        }
        
        if(paymentHeader.ASI_MFM_Expense_Type__c != Null && paymentHeader.ASI_MFM_Department_Text__c != Null && paymentHeader.ASI_MFM_Department_Text__c != '' && paymentHeader.ASI_MFM_BU__c != Null){
            
            String thisPaymentFY = paymentHeader.ASI_MFM_CN_Fiscal_Year__c;
            
            if(pageId == Null || pageId == ''){
                ASI_MFM_Prefix__c px = [SELECT id, Name, ASI_MFM_Fiscal_year__c, ASI_MFM_Next_Number__c FROM ASI_MFM_Prefix__c WHERE id = : paymentHeader.ASI_MFM_Prefix__c];
                thisPaymentFY = px.ASI_MFM_Fiscal_year__c;
            }
            List<ASI_MFM_PO__c> budget = new List<ASI_MFM_PO__c>();
            
            //withoutSharingClass qb = new withoutSharingClass();
            
            budget = ASI_MFM_CN_StructureCostHelperClass.queryBudget(thisPaymentFY, paymentHeader.ASI_MFM_Expense_Type__c, null);
            
            
            
            if(budget.size() > 0){
                paymentHeader.ASI_MFM_PO__c = budget[0].id;
                paymentHeader.ASI_MFM_Budget_Owner__c = budget[0].ASI_MFM_Budget_Owner__c;
                
                // mdy by BLS(wzq) Abolish the restriction of monthly accural, which is only done once a month begin
                // if(paymentHeader.ASI_MFM_Accrual_Type__c != Null && paymentHeader.ASI_MFM_Accrual_Type__c != '' && paymentHeader.ASI_MFM_Accrual_Type__c.toLowerCase().contains('monthly accrual')){
                    
                //     date af = paymentHeader.ASI_MFM_Accrual_Date__c != Null ? date.newInstance(paymentHeader.ASI_MFM_Accrual_Date__c.year(), paymentHeader.ASI_MFM_Accrual_Date__c.month(), 1) : date.newInstance(date.today().year(), date.today().month(), 1);
                //     date at = paymentHeader.ASI_MFM_Accrual_Date__c != Null ? date.newInstance(paymentHeader.ASI_MFM_Accrual_Date__c.year(), paymentHeader.ASI_MFM_Accrual_Date__c.month(), date.daysInMonth(paymentHeader.ASI_MFM_Accrual_Date__c.year(), paymentHeader.ASI_MFM_Accrual_Date__c.month())) : date.newInstance(date.today().year(), date.today().month(), date.daysInMonth(date.today().year(), date.today().month()));
                    
                //     List<ASI_MFM_Payment__c> payment = new List<ASI_MFM_Payment__c>([SELECT id FROM ASI_MFM_Payment__c WHERE recordtype.developerName Like 'ASI_MFM_CAP_CN_StructureCost_Payment' AND id != : paymentHeader.id AND ASI_MFM_Accrual_Type__c Like 'Monthly Accrual' AND ASI_MFM_Accrual_Date__c >= : af AND ASI_MFM_Accrual_Date__c <= : at AND ASI_MFM_PO__c = : paymentHeader.ASI_MFM_PO__c]);
                    
                //     if(payment.size() > 0){
                //         apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Monthly Accrual form for this month already exists'));
                //         return null;
                //     }
                // }
                 // mdy by BLS(wzq) Abolish the restriction of monthly accural, which is only done once a month end
                
                try{
                    if(pageId == Null || pageId == ''){
                        
                        //insert paymentHeader;
                        paymentHeader = ASI_MFM_CN_StructureCostHelperClass.upsertPayment(paymentHeader, true);
                        
                    }else{
                        
                        //Update paymentHeader;
                        paymentHeader = ASI_MFM_CN_StructureCostHelperClass.upsertPayment(paymentHeader, false);
                    }
                    
                }catch(dmlException dmle){
                    
                    apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , dmle.getMessage()));
                    return null;
                }
                
            }else{
                
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'No budget for the selected Expense Type'));
                return null;
            }
        }
        
        if(paymentHeader.id != Null){
            
            if(pageId == Null || pageId == ''){
                return new pageReference('/' + paymentHeader.id);
            }else{
                return redirectToPage('/apex/ASI_MFM_CN_StructureCost_MainPage', paymentHeader.id, true);
            }
        }
        
        return null;
    }
    
    //Edit Page Function
    public PageReference redirectToPage(String pagePath, String pid, Boolean setredirect){
        
        if(pid != Null)
        {
             pagePath = pagePath +'?id='+pid;
        }
        PageReference redirect = new PageReference(pagePath);
        // if(pid != Null)
        //     redirect.getParameters().put('id',pid);
        
        // redirect.setRedirect(setredirect);
        return redirect;
    }
    
    //Edit Page Function
    Public pageReference cancel(){
        
        if(paymentHeader != Null && paymentHeader.id != Null)
            return redirectToPage('/apex/ASI_MFM_CN_StructureCost_MainPage', paymentHeader.id, true);
        else if(paymentHeader != Null && paymentHeader.ASI_MFM_Contract__c != Null)
            return new pageReference('/' + paymentHeader.ASI_MFM_Contract__c);
        else
            return new pageReference('/' + ASI_MFM_Payment__c.sObjectType.getDescribe().getKeyPrefix());
    }
    
    @remoteAction
    Global static List<paymentLine> paymentLine(String headerId, Boolean accrual, Boolean isClassification){
        
        if(headerId != '' && headerId != Null){
            List<paymentLine> paymentLineClass = new List<paymentLine>();
            
            String recordTypeName = isClassification ? 'ASI_MFM_CN_Classification_Line' : !accrual ? 'ASI_MFM_CAP_CN_Payment_Allocation' : 'ASI_MFM_CAP_CN_Accrual_Detail';
            
            for(ASI_MFM_Payment_Detail__c obj : [SELECT id, recordType.DeveloperName, recordTypeId, ASI_MFM_A_C_Code__c, ASI_MFM_Accrual_ETL__c
                                                 , ASI_MFM_Accrual_Reverse_Amount__c, ASI_MFM_Accrual_Reverse_Budget__c,  ASI_MFM_Amount__c
                                                 , ASI_MFM_Document_Number__c, ASI_MFM_Document_Type__c, ASI_MFM_Employee_Allocated_Amount__c
                                                 , ASI_MFM_Employee_Allocated_Percent__c, ASI_MFM_Employee_Code__c,  ASI_MFM_Fiscal_Year__c
                                                 , ASI_MFM_GL_date__c, ASI_MFM_Non_Sales_Allocated_Amount__c, ASI_MFM_Non_Sales_Allocated_Percent__c
                                                 , ASI_MFM_Payment__c, ASI_MFM_Remark__c, ASI_MFM_Reverse_ETL__c, ASI_MFM_Sales_Allocated_Amount__c
                                                 , ASI_MFM_Sales_Allocated_Percent__c, ASI_MFM_Subledger__c, ASI_MFM_Reclassification__c
                                                 , ASI_MFM_Headcount__c, ASI_MFM_Purpose__c, ASI_MFM_Payment__r.ASI_MFM_Expense_Type__r.ASI_MFM_Reclassification__c
                                                 , ASI_MFM_Payment__r.ASI_MFM_Expense_Type__r.ASI_MFM_Subledger__c, ASI_MFM_Payment__r.ASI_MFM_Expense_Type__r.ASI_MFM_Subledger_Options__c
                                                 FROM ASI_MFM_Payment_Detail__c WHERE ASI_MFM_Payment__c = :headerId AND recordType.DeveloperName = : recordTypeName]){
                                                     
                                                     paymentLine tmp = new paymentLine();
                                                     
                                                     tmp.lineId = obj.id;
                                                     tmp.isDelete = false;
                                                     
                                                     if(obj.recordType.DeveloperName == 'ASI_MFM_CN_Classification_Line'){
                                                         
                                                         tmp.reclassification = obj.ASI_MFM_Reclassification__c;
                                                         tmp.headCount = obj.ASI_MFM_Headcount__c;
                                                         tmp.purpose = obj.ASI_MFM_Purpose__c;
                                                         tmp.classificationAmount = obj.ASI_MFM_Amount__c;
                                                         tmp.remark = obj.ASI_MFM_Remark__c;
                                                         
                                                         paymentLineClass.add(tmp);
                                                         
                                                     }else if(obj.recordType.DeveloperName == 'ASI_MFM_CAP_CN_Payment_Allocation'){
                                                         
                                                         tmp.salesAmount = obj.ASI_MFM_Sales_Allocated_Amount__c > 0 ? obj.ASI_MFM_Sales_Allocated_Amount__c : 0;
                                                         tmp.nonSalesAmount = obj.ASI_MFM_Non_Sales_Allocated_Amount__c > 0 ? obj.ASI_MFM_Non_Sales_Allocated_Amount__c : 0;
                                                         tmp.salesPrecent = obj.ASI_MFM_Sales_Allocated_Percent__c > 0 ? obj.ASI_MFM_Sales_Allocated_Percent__c : 0;
                                                         tmp.nonSalesPrecent = obj.ASI_MFM_Non_Sales_Allocated_Percent__c > 0 ? obj.ASI_MFM_Non_Sales_Allocated_Percent__c : 0;
                                                         tmp.employeePrecent = obj.ASI_MFM_Employee_Allocated_Percent__c > 0 ? obj.ASI_MFM_Employee_Allocated_Percent__c : 0;
                                                         tmp.employeeAmount = obj.ASI_MFM_Employee_Allocated_Amount__c > 0 ? obj.ASI_MFM_Employee_Allocated_Amount__c : 0;
                                                         tmp.employeeCode = obj.ASI_MFM_Employee_Code__c != '' && obj.ASI_MFM_Employee_Code__c != Null ? obj.ASI_MFM_Employee_Code__c : '';
                                                         
                                                         paymentLineClass.add(tmp);
                                                         
                                                     }else if(obj.recordType.DeveloperName == 'ASI_MFM_CAP_CN_Accrual_Detail'){
                                                         
                                                         tmp.lineId = obj.id;
                                                         tmp.reverseAmount = obj.ASI_MFM_Accrual_Reverse_Amount__c > 0 ? obj.ASI_MFM_Accrual_Reverse_Amount__c : 0;
                                                         tmp.glDate = obj.ASI_MFM_GL_date__c != Null ? obj.ASI_MFM_GL_date__c.year() + '-' + obj.ASI_MFM_GL_date__c.month() + '-' + obj.ASI_MFM_GL_date__c.day() : Null;
                                                         tmp.ETL = obj.ASI_MFM_Reverse_ETL__c;
                                                         
                                                         paymentLineClass.add(tmp);
                                                     }
                                                 }
            
            return paymentLineClass;
        }
        
        return Null;
    }
    
    @remoteAction
    Global static String savePaymentLine(List<paymentLine> upsertList, List<paymentLine> deleteList, String headerId, Decimal totalAmount, Decimal totalAmountNonTax, Boolean isSales, Boolean isAmount, Boolean accrual, Boolean isClassification, String remark, Decimal salesAmount, Decimal nonSalesAmount){
        
        String errorMsg = '';
        Boolean hasError = false;
        List<ASI_MFM_Payment_Detail__c> deleteLine = new List<ASI_MFM_Payment_Detail__c>();
        List<ASI_MFM_Payment_Detail__c> upsertLine = new List<ASI_MFM_Payment_Detail__c>();
        decimal salesPercent = salesAmount != Null && totalAmount != Null ? (salesAmount/totalAmount).setScale(4) : 0;
        decimal nonSalesPercent = nonSalesAmount != Null && totalAmount != Null ? (nonSalesAmount/totalAmount).setScale(4) : 0;
        
        //delete
        if(deleteList.size() > 0){
            
            set<String> idSet = new Set<String>();
            
            for(paymentLine deleteitem : deleteList){
                
                if(!idSet.contains(deleteitem.lineId)){
                    deleteLine.add(new ASI_MFM_Payment_Detail__c(id = deleteitem.lineId));
                    idSet.add(deleteitem.lineId);
                }
            }
        }
        
        //upsert
        if(upsertList.size() > 0){
            
            set<String> idSet = new Set<String>();
            Boolean hasSalesallocation = false;
            Double totalEmplyeeAmount = 0;
            Double totalEmplyeepercent = 0;
            Double totalEmplyeeAmountNonTax = 0;
            Decimal totalReverseAmountWithoutTax = 0;
            
            for(paymentLine upsertItem : upsertList){
                
                if(!idSet.contains(upsertItem.lineId) || upsertItem.lineId == ''){
                    
                    if(isClassification){
                        
                        if(upsertItem.reclassification != ''){
                            
                            upsertLine.add(new ASI_MFM_Payment_Detail__c(id = (upsertItem.lineId == '' ? Null : upsertItem.lineId)
                                                                         , ASI_MFM_Reclassification__c = upsertItem.reclassification
                                                                         , ASI_MFM_Headcount__c = upsertItem.headCount
                                                                         , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CN_Classification_Line')
                                                                         , ASI_MFM_Payment__c = headerId
                                                                         , ASI_MFM_Purpose__c = upsertItem.purpose
                                                                         , ASI_MFM_Amount__c = upsertItem.classificationAmount
                                                                         , ASI_MFM_Remark__c = upsertItem.remark
                                                                        ));
                            
                            totalEmplyeeAmount += upsertItem.classificationAmount != Null ? upsertItem.classificationAmount : 0;
                            
                        }else if(upsertItem.lineId != ''){
                            
                            deleteLine.add(new ASI_MFM_Payment_Detail__c(id = upsertItem.lineId));
                        }
                    }else{
                        if(!accrual){
                            //20190806:AM@introv - fix issue when amount<0
                            //if(upsertItem.salesAmount > 0 || upsertItem.nonSalesAmount > 0 || upsertItem.salesPrecent > 0 || upsertItem.nonSalesPrecent > 0 || upsertItem.employeePrecent > 0 || upsertItem.employeeAmount > 0){
                            if(upsertItem.salesAmount != 0 || upsertItem.nonSalesAmount != 0 || upsertItem.salesPrecent != 0 || upsertItem.nonSalesPrecent != 0 || upsertItem.employeePrecent != 0 || upsertItem.employeeAmount != 0){
                                //20190806:AM@introv - fix issue when amount<0
                                /*
                                ASI_MFM_Payment_Detail__c tmp = new ASI_MFM_Payment_Detail__c(id = (upsertItem.lineId == '' ? Null : upsertItem.lineId)
                                                                                              , ASI_MFM_Sales_Allocated_Amount__c = upsertItem.salesAmount > 0 ? upsertItem.salesAmount : upsertItem.salesPrecent/100 * totalAmount
                                                                                              , ASI_MFM_Non_Sales_Allocated_Amount__c = upsertItem.nonSalesAmount > 0 ? upsertItem.nonSalesAmount : upsertItem.nonSalesPrecent/100 * totalAmount
                                                                                              , ASI_MFM_Sales_Allocated_Percent__c = upsertItem.salesPrecent > 0 ? upsertItem.salesPrecent : (upsertItem.salesAmount/totalAmount)*100
                                                                                              , ASI_MFM_Non_Sales_Allocated_Percent__c = upsertItem.nonSalesPrecent > 0 ? upsertItem.nonSalesPrecent : (upsertItem.nonSalesAmount/totalAmount)*100
                                                                                              , ASI_MFM_Employee_Allocated_Percent__c = upsertItem.employeePrecent > 0 ? upsertItem.employeePrecent : (upsertItem.employeeAmount/totalAmount)*100
                                                                                              , ASI_MFM_Employee_Allocated_Amount__c = upsertItem.employeeAmount > 0 ? upsertItem.employeeAmount : upsertItem.employeePrecent/100 * totalAmount
                                                                                              , ASI_MFM_Employee_Code__c = String.valueOf(upsertItem.employeeCode)
                                                                                              , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Payment_Allocation')
                                                                                              , ASI_MFM_Payment__c = headerId
                                                                                              , ASI_MFM_Remark__c = remark
                                                                                             );
                                */
                                ASI_MFM_Payment_Detail__c tmp = new ASI_MFM_Payment_Detail__c(id = (upsertItem.lineId == '' ? Null : upsertItem.lineId)
                                                                                              , ASI_MFM_Sales_Allocated_Amount__c = upsertItem.salesAmount != 0 ? upsertItem.salesAmount : upsertItem.salesPrecent/100 * totalAmount
                                                                                              , ASI_MFM_Non_Sales_Allocated_Amount__c = upsertItem.nonSalesAmount != 0 ? upsertItem.nonSalesAmount : upsertItem.nonSalesPrecent/100 * totalAmount
                                                                                              , ASI_MFM_Sales_Allocated_Percent__c = upsertItem.salesPrecent != 0 ? upsertItem.salesPrecent : (upsertItem.salesAmount/totalAmount)*100
                                                                                              , ASI_MFM_Non_Sales_Allocated_Percent__c = upsertItem.nonSalesPrecent != 0 ? upsertItem.nonSalesPrecent : (upsertItem.nonSalesAmount/totalAmount)*100
                                                                                              , ASI_MFM_Employee_Allocated_Percent__c = upsertItem.employeePrecent != 0 ? upsertItem.employeePrecent : (upsertItem.employeeAmount/totalAmount)*100
                                                                                              , ASI_MFM_Employee_Allocated_Amount__c = upsertItem.employeeAmount != 0 ? upsertItem.employeeAmount : upsertItem.employeePrecent/100 * totalAmount
                                                                                              , ASI_MFM_Employee_Code__c = String.valueOf(upsertItem.employeeCode)
                                                                                              , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Payment_Allocation')
                                                                                              , ASI_MFM_Payment__c = headerId
                                                                                              , ASI_MFM_Remark__c = remark
                                                                                             );
                                
                                Boolean hasTax = totalAmount != totalAmountNonTax ? True : False;
                                
                                tmp.ASI_MFM_Non_Sales_Allocated_Amount_ETL__c = hasTax ? (totalAmountNonTax.setScale(2) * ((tmp.ASI_MFM_Non_Sales_Allocated_Percent__c/100).setScale(4))).setScale(2) : tmp.ASI_MFM_Non_Sales_Allocated_Amount__c;
                                tmp.ASI_MFM_Sales_Allocated_Amount_ETL__c = hasTax ? (totalAmountNonTax.setScale(2) * ((tmp.ASI_MFM_Sales_Allocated_Percent__c/100).setScale(4))).setScale(2) : tmp.ASI_MFM_Sales_Allocated_Amount__c;
                                tmp.ASI_MFM_Employee_Allocated_Amount_ETL__c = hasTax ? (totalAmountNonTax.setScale(2) * ((tmp.ASI_MFM_Employee_Allocated_Percent__c/100).setScale(4))).setScale(2) : tmp.ASI_MFM_Employee_Allocated_Amount__c;
                                
                                if(isSales && tmp.ASI_MFM_Sales_Allocated_Amount__c + tmp.ASI_MFM_Non_Sales_Allocated_Amount__c == totalAmount && tmp.ASI_MFM_Non_Sales_Allocated_Amount_ETL__c + tmp.ASI_MFM_Sales_Allocated_Amount_ETL__c != totalAmountNonTax.setScale(2)){
                                    
                                    tmp.ASI_MFM_Sales_Allocated_Amount_ETL__c += (totalAmountNonTax.setScale(2) - tmp.ASI_MFM_Sales_Allocated_Amount_ETL__c - tmp.ASI_MFM_Non_Sales_Allocated_Amount_ETL__c);
                                }
                                
                                //system.debug('checkcheck   ' + totalAmountNonTax + '   ' + (tmp.ASI_MFM_Non_Sales_Allocated_Percent__c/100).setScale(4) + '   ' + ((tmp.ASI_MFM_Sales_Allocated_Percent__c/100).setScale(4)) + '   ' + tmp.ASI_MFM_Non_Sales_Allocated_Amount_ETL__c + '    ' + tmp.ASI_MFM_Sales_Allocated_Amount_ETL__c + '    ' + tmp.ASI_MFM_Employee_Allocated_Amount_ETL__c);
                                
                                upsertLine.add(tmp);
                                
                                if(!isSales && (String.valueOf(upsertItem.employeeCode) == '' || String.valueOf(upsertItem.employeeCode) == Null)){
                                    hasError = true;
                                    errorMsg = 'Employee code is required';
                                }
                                
                                if(!isSales)
                                    totalEmplyeeAmountNonTax += tmp.ASI_MFM_Employee_Allocated_Amount_ETL__c;
                                
                                if(!isSales && isAmount)
                                    totalEmplyeeAmount += upsertItem.employeeAmount;
                                
                                if(!isSales && !isAmount)
                                    totalEmplyeepercent += upsertItem.employeePrecent;
                                
                                if(hasSalesallocation){
                                    hasError = true;
                                    errorMsg += 'Not allowed to craete multiple Sales and non-Sales Allocation line.\n';
                                }
                                
                                if((isSales && isAmount && upsertItem.salesAmount + upsertItem.nonSalesAmount != totalAmount ) || (isSales && !isAmount && upsertItem.salesPrecent + upsertItem.nonSalesPrecent != 100)){
                                    hasError = true;
                                    errorMsg += 'Sales and non-Sales Allocation must equal 100% or Total Payment Amount.';
                                }
                                
                                if(isSales){
                                    hasSalesallocation = true;
                                }
                                
                            }else if(upsertItem.lineId != ''){
                                
                                deleteLine.add(new ASI_MFM_Payment_Detail__c(id = upsertItem.lineId));
                            }
                        }else{
                            
                            if(upsertItem.reverseAmount > 0){
                                
                                Date gl = null;
                                
                                try{
                                    
                                    if(upsertItem.glDate != '' && upsertItem.glDate != Null && upsertItem.glDate.split('-').size() == 3){
                                        gl = date.newInstance(integer.valueOf(upsertItem.glDate.split('-')[0]), integer.valueOf(upsertItem.glDate.split('-')[1]), integer.valueOf(upsertItem.glDate.split('-')[2]));
                                    }else{
                                        
                                        return 'G/L Date cannot be null';
                                    }
                                }catch(exception e){
                                    
                                    return e.getMessage();
                                }
                                
                                if(!upsertItem.ETL){
                                    
                                    //20180315 Introv Added logic totalAmount != totalAmountNonTax ?
                                    double etlamount = (totalAmount != totalAmountNonTax ? (((upsertItem.reverseAmount > 0 ? upsertItem.reverseAmount : 0)/totalAmount).setScale(4) * totalAmountNonTax.setScale(2)).setScale(2) : upsertItem.reverseAmount);
                                    
                                    upsertLine.add(new ASI_MFM_Payment_Detail__c(id = (upsertItem.lineId == '' ? Null : upsertItem.lineId)
                                                                                 , ASI_MFM_Accrual_Reverse_Amount__c = upsertItem.reverseAmount > 0 ? upsertItem.reverseAmount : 0
                                                                                 , ASI_MFM_Accrual_Reverse_Amount_ETL__c = etlamount
                                                                                 //, ASI_MFM_Employee_Allocated_Amount_ETL__c = etlamount
                                                                                 , ASI_MFM_GL_date__c = gl
                                                                                 //, ASI_MFM_Sales_Allocated_Amount_ETL__c = (salesPercent * etlamount).setScale(2)
                                                                                 //, ASI_MFM_Non_Sales_Allocated_Amount_ETL__c = (nonSalesPercent * etlamount).setScale(2)
                                                                                 , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Accrual_Detail')
                                                                                 , ASI_MFM_Payment__c = headerId
                                                                                 , ASI_MFM_Remark__c = remark
                                                                                ));
                                }
                                
                                totalEmplyeeAmount += upsertItem.reverseAmount;
                                totalReverseAmountWithoutTax += (((upsertItem.reverseAmount > 0 ? upsertItem.reverseAmount : 0)/totalAmount).setScale(4) * totalAmountNonTax.setScale(2)).setScale(2);
                                
                            }else if(upsertItem.lineId != ''){
                                
                                deleteLine.add(new ASI_MFM_Payment_Detail__c(id = upsertItem.lineId));
                            }
                        }
                    }
                    idSet.add(upsertItem.lineId);
                }
            }
            
            //handle rounding issue
            if(accrual && !isClassification && totalEmplyeeAmount == totalAmount.setScale(2) && upsertLine.size() > 0){
                
                upsertLine[0].ASI_MFM_Accrual_Reverse_Amount_ETL__c += (totalAmountNonTax.setScale(2) - totalReverseAmountWithoutTax);
            }
            
            //handle rounding issue
            if(!accrual && !isClassification && !isSales && upsertLine.size() > 0 && totalAmountNonTax.setScale(2) != totalEmplyeeAmountNonTax){
                upsertLine[0].ASI_MFM_Employee_Allocated_Amount_ETL__c += (totalAmountNonTax.setScale(2) - totalEmplyeeAmountNonTax);
            }
            
            //Exception
            if(!accrual && !isClassification && ((!isSales && isAmount && totalEmplyeeAmount != totalAmount) || (!isSales && !isAmount && totalEmplyeepercent != 100 ))){
                hasError = true;
                errorMsg = 'Total Employee Allocation must equals 100% or Total Payment Amount.';
            }
            
            if(accrual && !isClassification && totalEmplyeeAmount > totalAmount){
                hasError = true;
                errorMsg = 'Total Reverse Amount cannot be greater than Total Amount.';
            }
            
            if(isClassification && !accrual && totalEmplyeeAmount != totalAmount){
                hasError = true;
                errorMsg = 'Total Classification Amount must equals Total Amount.';
            }
        }
        
        if(!hasError){
            if(deleteLine.size() > 0){
                try{
                    
                    delete deleteLine;
                    
                }catch(dmlException dmle){
                    
                    return dmle.getMessage();
                }
            }
            
            if(upsertLine.size() > 0){
                try{
                    
                    upsert upsertLine;
                    
                }catch(dmlException dmle){
                    
                    return dmle.getMessage();
                }
            }
        }else{
            return errorMsg;
        }
        
        return 'Success';
    }
    
    Global Class paymentLine{
        
        Global Decimal salesAmount {Get; Set;}
        Global Decimal nonSalesAmount {Get; Set;}
        Global Decimal salesPrecent {Get; Set;}
        Global Decimal nonSalesPrecent {Get; Set;}
        Global Decimal employeePrecent {Get; Set;}
        Global Decimal employeeAmount {Get; Set;}
        Global String employeeCode {Get; Set;}
        Global String lineId {Get; Set;}
        Global Boolean isDelete {Get; Set;}
        Global Decimal reverseAmount {Get; Set;}
        Global String glDate {Get; Set;}
        Global String reclassification {Get; Set;}
        Global String purpose {Get; Set;}
        Global Decimal headCount {Get; Set;}
        Global Decimal classificationAmount {Get; Set;}
        Global Boolean ETL {Get; Set;}
        Global String remark {Get; Set;} //20171110 Introv
    }
    
    /*Public without sharing class withoutSharingClass{
        
        public List<ASI_MFM_PO__c> queryBudget(String thisPaymentFY, String expenseType){
            return [SELECT id, ASI_MFM_Budget_Owner__c FROM ASI_MFM_PO__c WHERE ASI_MFM_PO_Fiscal_Year__c = : thisPaymentFY AND ASI_MFM_Status__c != 'Archived' AND ASI_MFM_Expense_Type__c = : expenseType AND RecordTypeId = : Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_CN_Structure_Cost')];
        }
    }*/
}