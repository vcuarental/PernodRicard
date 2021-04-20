public with sharing class ASI_MFM_CN_ScanToPayController {
    
    Public String PONumber {Get; Set;}
    Public String invoiceStatus {Get; Set;}
    Public String POType {Get; Set;}
    Public String budgetOwner {Get; Set;}
    Public string raised_by_filter {Get; Set;}
    Public string planId {Get; Set;}
    Public string selectedBU {Get; Set;}
    Public string supplier {Get; Set;}
    Public Boolean prePayment {Get; Set;}
    Public Boolean initError {Get; Set;}
    Public Boolean isProcurement {Get; Set;}
    Public List<SelectOption> BUOptions {Get; Set;}
    Public List<SelectOption> fiscalYearOption {Get; Set;}
    Public String fiscalYear {Get; Set;}
    Public List<invoiceClass> invoiceList {Get; Set;}
    Public list<selectOption> available_prefixes {Get; private Set;}
    Public string selected_prefix {Get; Set;}
    Public Boolean dummyVar { Get { if (dummyVar != true) {dummyVar = init();} Return dummyVar; } Set; }
    Public list<asi_mfm_role_prefix_relationship__c> px_list {Get; Set;}
    Public ASI_MFM_objectPickListHelper budgetOwnerPickList {Get; Set;}
    
    Map<string, asi_mfm_role_prefix_relationship__c> px_map = new Map<string, asi_mfm_role_prefix_relationship__c>();
    Map<Id, invoiceClass> mapInvoice;
    Map<Id, List<invoiceClass>> mapInvoiceByPO;
    
    Public Boolean init() {
        
        initError =FALSE;
        user u = [select userRole.developerName, asi_mfm_country__c, ASI_MFM_Team__c, Name from user where id = :userInfo.getUserId()];
        
        isProcurement = u.ASI_MFM_Team__c != NULL && u.ASI_MFM_Team__c != '' && u.ASI_MFM_Team__c == 'Procurement' ? TRUE : FALSE;
        
        if (u.userRole.developerName == null) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The role of the user is not defined yet');
            apexpages.addmessage(err);
            initError = TRUE;
        }
        else if (u.asi_mfm_country__c == null) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The country of the user is not defined yet');
            apexpages.addmessage(err);
            initError = TRUE;
        }else{
            
            raised_by_filter = userInfo.getUserId();
            budgetOwner = userInfo.getUserId();
            budgetOwnerPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO__c','ASI_MFM_Budget_Owner__c','1000',' isActive = true and ASI_MFM_Country__c =\'CN\' ');
            fiscalYearOption = new List<SelectOption>();
            BUOptions = new List<SelectOption>();
            fiscalYearOption.add(new SelectOption('All', 'All'));
            date thisFY = date.today();
            Integer fy;
            
            //20171110 Introv
            
            fy = thisFY.month() >= 7 ? Integer.valueOf(String.valueOf(thisFY.year() - 2003) + String.valueOf(thisFY.year() - 2002)) : Integer.valueOf(String.valueOf(thisFY.year() - 2004) + String.valueOf(thisFY.year() - 2003));
            
            for(integer i = 0 ; i < 5; i++){ 
                
                fiscalYearOption.add(new SelectOption('FY' + fy, 'FY' + fy));
                fy += 101;
            }
            
            /*fy = thisFY.month() >= 7 ? 'FY' + String.valueOf(thisFY.year() - 2000) + String.valueOf(thisFY.year() - 1999) : 'FY' + String.valueOf(thisFY.year() - 2001) + String.valueOf(thisFY.year() - 2000);
            fiscalYearOption.add(new SelectOption(fy, fy));
            fy = 'FY' + String.valueOf(Integer.valueOf(fy.subString(2)) - 101);
            fiscalYearOption.add(new SelectOption(fy, fy));*/
            
            BUOptions.add(new SelectOption('', 'All'));
            for(ASI_MFM_BU__c obj : [SELECT id, Name FROM ASI_MFM_BU__c WHERE RecordType.DeveloperName = 'ASI_MFM_CN_BU']){
                BUOptions.add(new SelectOption(obj.id, obj.Name));
            }
            
            px_list = new list<asi_mfm_role_prefix_relationship__c>();
            for (asi_mfm_role_prefix_relationship__c px:[SELECT asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c 
                                                         FROM asi_mfm_role_prefix_relationship__c
                                                         WHERE asi_mfm_prefix__r.ASI_MFM_Inactive__c = FALSE 
                                                         AND asi_mfm_prefix__r.asi_mfm_module__c = 'Payment' 
                                                         AND asi_mfm_role_name__c = :u.userRole.developerName 
                                                         AND asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c 
                                                         order BY asi_mfm_prefix__r.name]) {
                                                             px_map.put(px.asi_mfm_prefix__c, px);
                                                             px_list.add(px);    
                                                         }
            if (px_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input payments');
                apexpages.addmessage(err);
                initError = TRUE;
            }
        }
        Return TRUE;
    }
    
    Public Void getVATInvoice(){
        
        mapInvoice = new Map<Id, invoiceClass>();
        invoiceList = new List<invoiceClass>();
        mapInvoiceByPO = new Map<Id, List<invoiceClass>>();
        Set<Id> poIdSet = new Set<Id>();
        Map<Id, Decimal> mapReceiptNotPaid = new Map<Id, Decimal>();
        date thisFY = date.today();
        String fy1;
        String fy2;
        fy1 = thisFY.month() >= 7 ? 'FY' + String.valueOf(thisFY.year() - 2000) + String.valueOf(thisFY.year() - 1999) : 'FY' + String.valueOf(thisFY.year() - 2001) + String.valueOf(thisFY.year() - 2000);
        fy2 = 'FY' + String.valueOf(Integer.valueOf(fy1.subString(2)) - 101);
        
        String soqlString = 'SELECT id, ASI_MFM_Invoice_Amount__c, ASI_MFM_Payment_No__c, ASI_MFM_Payment_No__r.Name, ASI_MFM_Supplier__c, 	ASI_MFM_PO_No__r.ASI_MFM_Budget_Owner__c,';
        soqlString += ' ASI_MFM_Tax_Code__c, ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c, ASI_MFM_PO_No__c, ASI_MFM_PO_No__r.Name, ASI_MFM_Status__c, Name, ASI_MFM_Supplier__r.Name, ASI_MFM_BU__c, ASI_MFM_PO_No__r.ASI_MFM_Total_Receipt_Amount__c,';
        soqlString += ' ASI_MFM_PO_No__r.ASI_MFM_PO_Amount__c, ASI_MFM_Paid_Amount__c, ASI_MFM_Invoice_Date__c, ASI_MFM_Currency__c, ASI_MFM_Reciept_Not_Paid__c, ASI_MFM_PO_Amount__c, ASI_MFM_Tax_Code__r.Name,';
        soqlString += ' AS_MFM_Invoice_Amount_Before_Tax__c, ASI_MFM_Remarks__c, ASI_MFM_PO_Remarks__c, ASI_MFM_PO_No__r.ASI_MFM_BU_Code__c, ASI_MFM_Overdue_Date__c, ASI_MFM_PO_No__r.ASI_MFM_Remarks__c, ASI_MFM_PO_No__r.ASI_MFM_PO_Type__c';//20160902 Leo,add po remark//20170302,Elufa,add PO Type
        soqlString += ' FROM ASI_MFM_VAT_Invoice__c WHERE RecordType.DeveloperName = \'ASI_MFM_CN_VAT_Invoice\'';
        
        if(PONumber != '' && PONumber != NULL)
            soqlString += ' AND ASI_MFM_PO_No__r.Name LIKE \'%' + PONumber + '%\'';
        if(invoiceStatus != '' && invoiceStatus != NULL)
            soqlString += ' AND ASI_MFM_Status__c LIKE \'' + invoiceStatus + '\'';
        if(POType != '' && POType != NULL)
            soqlString += ' AND ASI_MFM_PO_No__r.ASI_MFM_PO_Type__c LIKE \'' + POType + '\'';
        if(budgetOwner != '' && budgetOwner != NULL)
            soqlString += ' AND ASI_MFM_PO_No__r.ASI_MFM_Budget_Owner__c = \'' + budgetOwner + '\'';
        if(raised_by_filter != '' && raised_by_filter != NULL)
            soqlString += ' AND ASI_MFM_PO_No__r.OwnerId = \'' + raised_by_filter + '\'';
        if(selectedBU != '' && selectedBU != NULL)
            soqlString += ' AND ASI_MFM_BU__c = \'' + selectedBU + '\'';
        if(supplier != '' && supplier != NULL)
            soqlString += ' AND ASI_MFM_Supplier__r.Name LIKE \'%' + supplier + '%\'';
        if(planId != '' && planId != NULL)
            soqlString += ' AND ASI_MFM_PO_No__r.ASI_MFM_Plan__r.Name LIKE \'%' + planId + '%\'';
        if(fiscalYear == 'All')
            soqlString += ' AND (ASI_MFM_PO_No__r.ASI_MFM_Fiscal_Year__c LIKE \'' + fy1 + '\' OR ASI_MFM_PO_No__r.ASI_MFM_Fiscal_Year__c LIKE \'' + fy2 + '\')';
        else if(fiscalYear != 'ALL')
            soqlString += ' AND ASI_MFM_PO_No__r.ASI_MFM_Fiscal_Year__c LIKE \'' + fiscalYear + '\'';
        
        soqlString += ' ORDER BY ASI_MFM_PO_No__r.Name DESC, ASI_MFM_Invoice_Date__c DESC, ASI_MFM_Tax_Code__r.Name DESC, ASI_MFM_BU__c DESC';
        
        for(ASI_MFM_VAT_Invoice__c obj : database.query(soqlString)){
            
            List<invoiceClass> tmpList = new List<invoiceClass>();
            invoiceClass tmpInvoice = new invoiceClass();
            tmpInvoice.committed = obj.ASI_MFM_Payment_No__c == NULL ? FALSE : TRUE;
            tmpInvoice.VATInvoice = obj;
            tmpInvoice.VATInvoice.ASI_MFM_Paid_Amount__c = obj.ASI_MFM_Invoice_Amount__c;
            poIdSet.add(obj.ASI_MFM_PO_No__c);
            invoiceList.add(tmpInvoice);
            mapInvoice.put(obj.id, tmpInvoice);
            
            if(mapInvoiceByPO.containsKey(obj.ASI_MFM_PO_No__c)){
                
                tmpList = mapInvoiceByPO.get(obj.ASI_MFM_PO_No__c);
                tmpList.add(tmpInvoice);
                mapInvoiceByPO.put(obj.ASI_MFM_PO_No__c, tmpList);
            }else{
                
                tmpList.add(tmpInvoice);
                mapInvoiceByPO.put(obj.ASI_MFM_PO_No__c, tmpList);
            }
        }
        
        for(ASI_MFM_PO_Line_Item__c obj : [SELECT Id
                                           , ASI_MFM_Amount__c
                                           , ASI_MFM_PO__c
                                           , ASI_MFM_CN_Paid_Amount__c
                                           , ASI_MFM_CN_ReceiptNotPaid__c
                                           FROM ASI_MFM_PO_Line_Item__c
                                           WHERE ASI_MFM_PO__c IN : poIdSet]){
                                               
                                               if(mapReceiptNotPaid.containsKey(obj.ASI_MFM_PO__c)){
                                                   
                                                   mapReceiptNotPaid.put(obj.ASI_MFM_PO__c, mapReceiptNotPaid.get(obj.ASI_MFM_PO__c) + obj.ASI_MFM_CN_ReceiptNotPaid__c);
                                               }else if(!mapReceiptNotPaid.containsKey(obj.ASI_MFM_PO__c)){
                                                   
                                                   mapReceiptNotPaid.put(obj.ASI_MFM_PO__c, obj.ASI_MFM_CN_ReceiptNotPaid__c);
                                               }
        }
        for(invoiceClass obj : invoiceList){
            obj.receiptNotPaid = mapReceiptNotPaid.containsKey(obj.VATInvoice.ASI_MFM_PO_No__c) ? mapReceiptNotPaid.get(obj.VATInvoice.ASI_MFM_PO_No__c) : 0;
        }
    }
    
    Public Void closePayment(){
        
        /*Boolean hasError = FALSE;
        Savepoint sp = Database.setSavepoint();
        
        if(invoiceList == NULL || invoiceList.size() == 0 ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No Invoice to close'));
            hasError = TRUE;
        }
        if(!hasError){
            List<ASI_MFM_VAT_Invoice__c> tmpUpdateList = new List<ASI_MFM_VAT_Invoice__c>();
            
            for(invoiceClass obj : invoiceList){
                
                if(obj.checked != NULL && obj.checked && obj.VATInvoice.ASI_MFM_Payment_No__c != NULL && !hasError){
                    
                    obj.VATInvoice.ASI_MFM_Status__c = 'Closed';
                    tmpUpdateList.add(obj.VATInvoice);
                }else if(obj.checked != NULL && obj.checked && obj.VATInvoice.ASI_MFM_Payment_No__c == NULL){
                    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Payment Number is required'));
                    hasError = TRUE;
                    break;
                }
            }
            
            if(tmpUpdateList.size() > 0 && !hasError){
                try{
                    
                    List<database.SaveResult> result =  database.update(tmpUpdateList);
                    for(database.SaveResult obj : result){
                        if(mapInvoice.containsKey(obj.getId())){
                            mapInvoice.get(obj.getId()).committed = obj.isSuccess();
                            mapInvoice.get(obj.getId()).checked = FALSE;
                        }
                    }
                    
                }catch(dmlException dmle){
                    
                    Database.rollback(sp);
                }
            }
        }*/
    }
    
    Public Void convertPayment(){
        
        Boolean hasError = FALSE;
        List<ASI_MFM_VAT_Invoice__c> selectedInvoice = new List<ASI_MFM_VAT_Invoice__c>();
        Set<Id> invoiceSet = new Set<Id>();
        Set<Id> taxCodeSet = new Set<Id>();
        
        Decimal totalInvoiceAmt = 0;
        
        if(selected_prefix == '' || selected_prefix == NULL){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select prefix'));
            hasError = TRUE;
        }
        if(invoiceList == NULL || invoiceList.size() == 0 ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No Invoice to convert'));
            hasError = TRUE;
        }
        
        if(!hasError){
            
            Set<String> validationSet = new Set<String>();
            
            for(invoiceClass obj : invoiceList){
                //remove ASI_MFM_Invoice_Date__c in validationSet
                //if((validationSet.contains('' + obj.VATInvoice.ASI_MFM_PO_No__c + obj.VATInvoice.ASI_MFM_Tax_Code__c + obj.VATInvoice.ASI_MFM_Supplier__c + obj.VATInvoice.ASI_MFM_Invoice_Date__c) && obj.checked != NULL && !obj.checked) || validationSet.size() > 1){
                if((validationSet.contains('' + obj.VATInvoice.ASI_MFM_PO_No__c + obj.VATInvoice.ASI_MFM_Tax_Code__c + obj.VATInvoice.ASI_MFM_Supplier__c) && obj.checked != NULL && !obj.checked) || validationSet.size() > 1){
  
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Your are not allowed to bypass the validation.'));
                    hasError = TRUE;
                    break;
                }
                //check error of same invoices date, PO number & VAT rate
                if(obj.checked != NULL && obj.checked ){
                    
                    //validationSet.add('' + obj.VATInvoice.ASI_MFM_PO_No__c + obj.VATInvoice.ASI_MFM_Tax_Code__c + obj.VATInvoice.ASI_MFM_Supplier__c+ obj.VATInvoice.ASI_MFM_Invoice_Date__c);
                    validationSet.add('' + obj.VATInvoice.ASI_MFM_PO_No__c + obj.VATInvoice.ASI_MFM_Tax_Code__c + obj.VATInvoice.ASI_MFM_Supplier__c);
                    selectedInvoice.add(obj.VATInvoice);
                    invoiceSet.add(obj.VATInvoice.ASI_MFM_PO_No__c);
                    taxCodeSet.add(obj.VATInvoice.ASI_MFM_Tax_Code__c);
                    totalInvoiceAmt += obj.VATInvoice.ASI_MFM_Invoice_Amount__c;
                    
                    if(obj.VATInvoice.ASI_MFM_Payment_No__c != NULL){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Not allowed to re-convert invoices.'));
                        hasError = TRUE;
                        break;
                    }
                    if(invoiceSet.size() > 1){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Not allowed to convert multi PO'));
                        hasError = TRUE;
                        break;
                    }
                    if(taxCodeSet.size() > 1){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Not allowed to convert multi Tax Code'));
                        hasError = TRUE;
                        break;
                    }
                    if(obj.VATInvoice.ASI_MFM_PO_No__r.ASI_MFM_BU_Code__c != obj.VATInvoice.ASI_MFM_BU__c){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Inconsistent BU Code between PO and Invoice, Please verify.'));
                        hasError = TRUE;
                        break;
                    }
                }
            }
            Savepoint sp = Database.setSavepoint();
            
            if(!hasError && selectedInvoice.size() > 0){
                
                //20191107:AM@introv - Change SFDC payment "invoice date" to follow with the scanned invoice issue date
                //ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_STP_Payment__c = True, ASI_MFM_Pre_payment__c = prePayment, ASI_MFM_Currency__c = selectedInvoice[0].ASI_MFM_Currency__c, ASI_MFM_CN_Tax_Code_Picklist__c = selectedInvoice[0].ASI_MFM_Tax_Code__r.Name, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Prefix__c = selected_prefix, ASI_MFM_Budget_Owner__c = isProcurement ? userInfo.getUserID() : selectedInvoice[0].ASI_MFM_PO_No__r.ASI_MFM_Budget_Owner__c, ASI_MFM_Supplier_Name__c = selectedInvoice[0].ASI_MFM_Supplier__c, ASI_MFM_BU__c = selectedInvoice[0].ASI_MFM_BU__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment'));
                Date dtPaymentInovice = date.today();
                if (selectedInvoice[0].ASI_MFM_Invoice_Date__c != NULL) 
                    dtPaymentInovice = selectedInvoice[0].ASI_MFM_Invoice_Date__c;
                ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_STP_Payment__c = True, ASI_MFM_Pre_payment__c = prePayment, ASI_MFM_Currency__c = selectedInvoice[0].ASI_MFM_Currency__c, ASI_MFM_CN_Tax_Code_Picklist__c = selectedInvoice[0].ASI_MFM_Tax_Code__r.Name, ASI_MFM_Invoice_Date__c = dtPaymentInovice, ASI_MFM_Prefix__c = selected_prefix, ASI_MFM_Budget_Owner__c = isProcurement ? userInfo.getUserID() : selectedInvoice[0].ASI_MFM_PO_No__r.ASI_MFM_Budget_Owner__c, ASI_MFM_Supplier_Name__c = selectedInvoice[0].ASI_MFM_Supplier__c, ASI_MFM_BU__c = selectedInvoice[0].ASI_MFM_BU__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment'));
                
                //20160902, added by Leo
                String remarks = selectedInvoice[0].ASI_MFM_PO_No__r.ASI_MFM_Remarks__c;
                if(remarks != null)
                {
                    Integer endLen = remarks.length();
                    if(endLen > 255)
                        remarks = remarks.substring(0, 255);
                    else
                        remarks = remarks.substring(0, endLen);
                    payment.ASI_MFM_Remarks__c = remarks;
                }
                //20160902, added by Leo
                
                try{
                    database.insert(payment);
                }catch(dmlException dmle){
                    
                    Database.rollback(sp);
                    hasError = TRUE;
                }
                
                if(!hasError){
                    Decimal remainingReceiptBalance = 0;
                    
                    List<ASI_MFM_PO_Line_Item__c> selectedPOLineItemList = new List<ASI_MFM_PO_Line_Item__c>();
                    
                    selectedPOLineItemList = [SELECT Id
                                              , ASI_MFM_Amount__c
                                              , ASI_MFM_PO__c
                                              , ASI_MFM_CN_Paid_Amount__c
                                              , ASI_MFM_CN_ReceiptNotPaid__c
                                              , ASI_MFM_Sub_brand_Code__c//20160922 Ben @ Elufa
                                              , ASI_MFM_A_C_Code__c
                                              FROM ASI_MFM_PO_Line_Item__c
                                              WHERE ASI_MFM_PO__c = : selectedInvoice[0].ASI_MFM_PO_No__c];
                    
                    List<poLineClass> poLineItemList = new List<poLineClass>();
                    
                    if(selectedPOLineItemList.size() > 0){
                        for(ASI_MFM_PO_Line_Item__c obj : selectedPOLineItemList){
                            
                            remainingReceiptBalance += obj.ASI_MFM_CN_Paid_Amount__c;
                            poLineClass tmpClass = new poLineClass();
                            tmpClass.lineItemId = obj.id;
                            tmpClass.headerId = obj.ASI_MFM_PO__c;
                            tmpClass.subBrandId = obj.ASI_MFM_Sub_brand_Code__c;//20160922 Ben @ Elufa
                            tmpClass.remainingRecieptAmt = prePayment ? (obj.ASI_MFM_Amount__c  * (1 + selectedInvoice[0].ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c/100)).setScale(2): obj.ASI_MFM_CN_ReceiptNotPaid__c < 0 ? 0 : (obj.ASI_MFM_CN_ReceiptNotPaid__c * (1 + selectedInvoice[0].ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c/100)).setScale(2);
                            tmpClass.amount = obj.ASI_MFM_Amount__c;
                            tmpClass.acCode = obj.ASI_MFM_A_C_Code__c;//20170103 Elufa
                            poLineItemList.add(tmpClass);
                        }
                        if(poLineItemList.size() > 0){
                            
                            if(prePayment && ( remainingReceiptBalance > 0 || selectedInvoice[0].ASI_MFM_PO_No__r.ASI_MFM_Total_Receipt_Amount__c > 0)){
                                
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Pre-payment is not allowed after receipt/payment made'));
                                Database.rollback(sp);
                                hasError = TRUE;
                            }
                            
                            remainingReceiptBalance = prePayment ? selectedInvoice[0].ASI_MFM_PO_Amount__c * (1 + selectedInvoice[0].ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c/100) : (selectedInvoice[0].ASI_MFM_PO_No__r.ASI_MFM_Total_Receipt_Amount__c - remainingReceiptBalance) * (1 + selectedInvoice[0].ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c/100);
                            if(!hasError){
                                if(remainingReceiptBalance + 0.1 < totalInvoiceAmt){
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Invoice amount > receipt not paid, please do receipt first OR check the PO total amount '));
                                    Database.rollback(sp);
                                    hasError = TRUE;
                                }else{
                                    
                                    List<ASI_MFM_Payment_Line_Item__c> paymentLineList = new List<ASI_MFM_Payment_Line_Item__c>();
                                    Integer i = 0;
                                    Integer j = 0;
                                    Decimal totalPaidAmount = 0;
                                    while(i < selectedInvoice.size() && j < poLineItemList.size()){
                                        
                                        ASI_MFM_Payment_Line_Item__c tmpPaymentLine = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c = payment.Id
                                                                                                                       , ASI_MFM_PO_Line_Item__c = poLineItemList[j].lineItemId
                                                                                                                       , ASI_MFM_Invoice_Date__c = selectedInvoice[i].ASI_MFM_Invoice_Date__c
                                                                                                                       , ASI_MFM_VAT_Invoice__c = selectedInvoice[i].Id
                                                                                                                       , ASI_MFM_PO_Line_Currency__c = selectedInvoice[i].ASI_MFM_Currency__c
                                                                                                                       , ASI_MFM_PO__c = poLineItemList[j].headerId
                                                                                                                       , ASI_MFM_A_C_Code__c = poLineItemList[j].acCode//20170103 Elufa
                                                                                                                       , ASI_MFM_Sub_brand__c = poLineItemList[j].subBrandId//20160922 Ben @ Elufa
                                                                                                                       , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item')
                                                                                                                      );
                                        selectedInvoice[i].ASI_MFM_Payment_No__c = payment.id;
                                        if(poLineItemList[j].remainingRecieptAmt <= 0){
                                            
                                            j++;
                                        }else if(poLineItemList[j].remainingRecieptAmt > selectedInvoice[i].ASI_MFM_Paid_Amount__c){
                                            
                                            poLineItemList[j].remainingRecieptAmt = poLineItemList[j].remainingRecieptAmt - selectedInvoice[i].ASI_MFM_Paid_Amount__c;
                                            tmpPaymentLine.ASI_MFM_CN_Invoice_Amount__c = selectedInvoice[i].ASI_MFM_Paid_Amount__c;
                                            paymentLineList.add(tmpPaymentLine);
                                            
                                            selectedInvoice[i].ASI_MFM_Paid_Amount__c = selectedInvoice[i].ASI_MFM_Invoice_Amount__c;
                                            selectedInvoice[i].ASI_MFM_Status__c = 'Closed';
                                            totalPaidAmount += selectedInvoice[i].ASI_MFM_Paid_Amount__c;
                                            i++;
                                        }else if(poLineItemList[j].remainingRecieptAmt < selectedInvoice[i].ASI_MFM_Paid_Amount__c){
                                            
                                            selectedInvoice[i].ASI_MFM_Paid_Amount__c = selectedInvoice[i].ASI_MFM_Paid_Amount__c - poLineItemList[j].remainingRecieptAmt;
                                            tmpPaymentLine.ASI_MFM_CN_Invoice_Amount__c = poLineItemList[j].remainingRecieptAmt;
                                            paymentLineList.add(tmpPaymentLine);
                                            
                                            selectedInvoice[i].ASI_MFM_Status__c = 'Closed';
                                            poLineItemList[j].remainingRecieptAmt = 0;
                                            totalPaidAmount += poLineItemList[j].remainingRecieptAmt;
                                            j++;
                                        }else if(poLineItemList[j].remainingRecieptAmt == selectedInvoice[i].ASI_MFM_Paid_Amount__c){
                                            
                                            tmpPaymentLine.ASI_MFM_CN_Invoice_Amount__c = poLineItemList[j].remainingRecieptAmt;
                                            paymentLineList.add(tmpPaymentLine);
                                            
                                            selectedInvoice[i].ASI_MFM_Paid_Amount__c = selectedInvoice[i].ASI_MFM_Invoice_Amount__c;
                                            poLineItemList[j].remainingRecieptAmt = 0;
                                            selectedInvoice[i].ASI_MFM_Status__c = 'Closed';
                                            totalPaidAmount += poLineItemList[j].remainingRecieptAmt;
                                            j++;
                                            i++;
                                        }
                                    }
                                    try{
                                        database.insert(paymentLineList);
                                        
                                    }catch(dmlException dmle){
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,dmle.getMessage()));
                                        Database.rollback(sp);
                                        hasError = TRUE;
                                    }
                                    if(!hasError){
                                        try{
                                            List<database.SaveResult> updateResult =  database.update(selectedInvoice);
                                            Id POId;
                                            
                                            for(database.SaveResult obj : updateResult){
                                                if(mapInvoice.containsKey(obj.getId())){
                                                    
                                                    mapInvoice.get(obj.getId()).committed = obj.isSuccess();
                                                    mapInvoice.get(obj.getId()).checked = FALSE;
                                                    POId = mapInvoice.get(obj.getId()).VATInvoice.ASI_MFM_PO_No__c;
                                                }
                                            }
                                            if(mapInvoiceByPO.containsKey(POId)){
                                                for(invoiceClass obj : mapInvoiceByPO.get(POId)){
                                                    obj.receiptNotPaid -= totalPaidAmount;
                                                }
                                            }
                                            
                                        }catch(dmlException dmle){
                                            
                                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,dmle.getMessage()));
                                            Database.rollback(sp);
                                            hasError = TRUE;
                                        }
                                    }
                                }
                            }
                        }else{
                            
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No related PO line'));
                            Database.rollback(sp);
                            hasError = TRUE;
                        }
                    }
                }
            }else if(hasError || selectedInvoice.size() == 0){
                
                Database.rollback(sp);
                hasError = TRUE;
            }/*else if(selectedInvoice.size() == 0){
                
                Database.rollback(sp);
                hasError = TRUE;
            }*/
        }
    }
    
    Public Class poLineClass{
        
        String lineItemId;
        String headerId;
        Id acCode;//20170103 Elufa
        String subBrandId; //20160922 Ben @ Elufa
        Decimal remainingRecieptAmt;
        Decimal amount;
    }
    
    Public Class invoiceClass{
        
        Public Boolean checked {set;get;}
        Public Boolean committed {set;get;}
        Public Decimal receiptNotPaid {set;get;}
        Public ASI_MFM_VAT_Invoice__c VATInvoice{set;get;}
    }
}