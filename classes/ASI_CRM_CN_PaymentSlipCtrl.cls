public without sharing class ASI_CRM_CN_PaymentSlipCtrl {
    public string PageId {set;get;}
    public List<ASI_CRM_CN_PH_Payee_Line_Item__c> PayeeLineItems {set;get;}
    public string PTSelected {set;get;}
    public string T1Selected {set;get;}
    public string T2Selected {set;get;}
    public boolean havePayee {set;get;}
    public string T1Name {set;get;}
    public string T2Name {set;get;}
    public string invoice {set;get;}
    public ASI_TH_CRM_PaymentRequest__c thisPR {set;get;}
    public string UserId {set;get;}
    public User UserName {set;get;}
    public string PayeeItem {set;get;}
    public string strAmount {set;get;}
    public decimal strAmountDecimal {set;get;}
    public string strRemarks {set;get;}  
    public string WS { set; get; }
    public string name { set; get; }
    
    //Added by Twinkle 24Oct2014
    public Map<String, String> MInvoiceNum; 
    public Map<String, String> MType;
    public Map<String, String> MCash;
    
    //Added by Twinkle 29Oct2014
    public string RVP {set;get;}
    public string RFM {set;get;}
    
    public ASI_CRM_CN_PaymentSlipCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
        T1Name = ApexPages.currentPage().getParameters().get('T1');
        T2Name = ApexPages.currentPage().getParameters().get('T2');
        invoice = ApexPages.currentPage().getParameters().get('invoice');
        PTSelected = ApexPages.currentPage().getParameters().get('PTSelected');
        strAmount = ApexPages.currentPage().getParameters().get('strAmount1');
        strRemarks = ApexPages.currentPage().getParameters().get('Remarks1');
        RVP = ApexPages.currentPage().getParameters().get('RVP');
        RFM = ApexPages.currentPage().getParameters().get('RFM');
        WS = ApexPages.currentPage().getParameters().get('WS');
        name = ApexPages.currentPage().getParameters().get('name');
        UserId = UserInfo.getUserId();
        //Added by William Yang(Introv) 20141222
        if(strAmount != null && strAmount != '')
            strAmountdecimal = Decimal.valueof(strAmount);
        
        if (PageId != null){
            try{
                thisPR = [SELECT id, Name, ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_PO_No__c , ASI_CRM_CN_OutletWS__r.Name, ASI_TH_CRM_Total_Amount__c,ASI_CRM_CN_Payment_Type__c, 
                            ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_OutletWS__r.Owner.Name,
                            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Chi_Name__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Legal_Name__c, ASI_CRM_CN_OutletWS__r.RecordTypeId                            
                            FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
            }catch(exception e){
                system.debug('Try (thisPR): ' + e);
            }
            try{

                PayeeLineItems = [SELECT ASI_CRM_CN_Invoice_Number__c, ASI_CRM_CN_Type__c, ASI_CRM_CN_Discount_Amount__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.ASI_HK_CRM_Chinese_Name__c,
                                    ASI_CRM_CN_Cash_Amount__c,ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name,
                                    ASI_CRM_CN_Cash_Payee_Name_T1__r.ASI_KOR_Legal_Name__c, ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Legal_Name__c, 
                                    ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Legal_Name__c,
                                    ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Chi_Name__c,
                                  	ASI_CRM_CN_Payee_T1__r.ASI_MFM_Customer_Supplier_Number__c,
                                    ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Chi_Name__c,
                                    ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T1__r.Name,
                                    ASI_CRM_CN_Payee_Name_T2_lookup__c, ASI_CRM_CN_Payee_Name_T2_lookup__r.Name,
                                    ASI_CRM_CN_Amount__c, ASI_CRM_CN_Reason__c, ASI_CRM_CN_Payee_Name_T1__r.RecordTypeId,
                                    ASI_CRM_CN_Payee_Name_T2_lookup__r.RecordTypeId,
                                    ASI_CRM_CN_Cash_Payee_Name_T1__r.RecordTypeId,
                                    ASI_CRM_CN_Cash_Payee_Name_T1__r.ASI_MFM_Customer_Supplier_Name__c,
                                  	Name,
                                    ASI_CRM_CN_RFM_Name__c, ASI_CRM_CN_RVP_Name__c
                                    FROM ASI_CRM_CN_PH_Payee_Line_Item__c
                                    WHERE ASI_CRM_CN_Payment_Request__c = :PageId];
            }catch(exception e){
                system.debug('Try (PayeeLineItems): ' + e);
            }
            if (PayeeLineItems.size() > 0)
                havePayee = true;
        }else{
            thisPR = new ASI_TH_CRM_PaymentRequest__c();
            PayeeLineItems = new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            havePayee = false;
        }
        if (UserId != null){
            UserName = [SELECT Name FROM User WHERE Id = :UserId];
        }else{
            UserName = new User();
        }
        if (strAmount == null)
            strAmount = string.valueof(0);
    }
    
    //Updated by Twinkle 24Oct2014
    public List<SelectOption> getPayee(){
        MInvoiceNum = new Map<String, String>(); 
        MType = new Map<String, String>();
        MCash = new Map<String, String>();
        
        List<SelectOption> options = new List<SelectOption>();
        string name1;
        string name2;
        string cashname;
        
        if (PayeeLineItems.size() > 0)
            for(ASI_CRM_CN_PH_Payee_Line_Item__c a : PayeeLineItems){ 

                //Cash Payee Name
                if (a.ASI_CRM_CN_Cash_Payee_Name_T1__c != null){
                    if (a.ASI_CRM_CN_Cash_Payee_Name_T1__r.ASI_MFM_Customer_Supplier_Name__c != null)
                        cashname = a.ASI_CRM_CN_Cash_Payee_Name_T1__r.ASI_MFM_Customer_Supplier_Name__c;
                    else
                        cashname = a.ASI_CRM_CN_Cash_Payee_Name_T1__r.Name;
                }else{
                    cashname = '';
                }
                
                //T1 Payee Name
                if (a.ASI_CRM_CN_Payee_Name_T1__c != null){
                    if (a.ASI_CRM_CN_Payee_Name_T1__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'))
                        name1 = a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Chi_Name__c;
                    else
                        name1 = a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Legal_Name__c;
                }else{
                    name1 = '';
                }
                system.debug(name1);
                
                //T2 Payee Name
                if (a.ASI_CRM_CN_Payee_Name_T2_lookup__c != null){
                    if (a.ASI_CRM_CN_Payee_Name_T2_lookup__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'))
                        name2 = a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Chi_Name__c;
                    else
                        name2 = a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Legal_Name__c;
                }else{
                    name2 = '';
                }  
                system.debug(name2);
                
                if (PTSelected != 'Receipt'){
                    if (a.ASI_CRM_CN_Amount__c != null){
                        if (a.ASI_CRM_CN_Type__c != 'Cash'){
                            options.add(new SelectOption(a.id, '(T1): ' + name1 + ' & (T2): ' + name2 + ' - $' + a.ASI_CRM_CN_Amount__c));
                            MInvoiceNum.put(a.id, a.ASI_CRM_CN_Invoice_Number__c);
                            MType.put(a.id, a.ASI_CRM_CN_Type__c);
                            MCash.put(a.id, a.ASI_CRM_CN_Cash_Payee_Name_T1__c);
                        }
                    }
                }else{
                    //if (a.ASI_CRM_CN_Amount__c > 0){
                        if (a.ASI_CRM_CN_Type__c != 'Cash')
                            options.add(new SelectOption(a.id, '(T1): ' + name1 + ' & (T2): ' + name2 + ' - $' + a.ASI_CRM_CN_Amount__c));                            
                        
                        else
                            options.add(new SelectOption(a.id, cashname + ' - $' + a.ASI_CRM_CN_Amount__c)); 
                        
                        MInvoiceNum.put(a.id, a.ASI_CRM_CN_Invoice_Number__c);
                        MType.put(a.id, a.ASI_CRM_CN_Type__c);
                        MCash.put(a.id, a.ASI_CRM_CN_Cash_Payee_Name_T1__c);
                    //}
                }            
            }
            
      return options;
    }

    public pageReference GeneratePDF(){
        boolean hasError = false;
        //strAmountdecimal = 0;
        string T1_name;
        string T2_name;
        string strReason = '';
        String invoice1;
        String WS;
        String type = MType.get(PayeeItem);
        
        //Added by Twinkle 23Oct2014
        if(MInvoiceNum.get(PayeeItem) != null)
            invoice1 = MInvoiceNum.get(PayeeItem); 
        else
            invoice1 = ' - ';
        //End by Twinkle 23Oct2014

        if (PayeeLineItems.size() > 0){ 
            for(ASI_CRM_CN_PH_Payee_Line_Item__c a : PayeeLineItems){
                if (a.id == PayeeItem){     
                    
                    WS = a.ASI_CRM_CN_Payee_T1__r.ASI_MFM_Customer_Supplier_Number__c;
                    name = a.Name;
                    
                    //Added by Twinkle 24Oct2014
                    if (PTSelected == 'Instruction'){
                        if (a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Legal_Name__c != null)    
                            T1_name = a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Legal_Name__c;
                        else if (a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Chi_Name__c!= null)
                            T1_name = a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Chi_Name__c;
                        else
                            T1_name = a.ASI_CRM_CN_Payee_Name_T1__r.Name;
                    }
                    
                    if (type == 'Cash' || (type == 'Cash & Discount' && MCash != null)){
                        if (a.ASI_CRM_CN_Cash_Payee_Name_T1__r.ASI_MFM_Customer_Supplier_Name__c != null)
                            T2_name = a.ASI_CRM_CN_Cash_Payee_Name_T1__r.ASI_MFM_Customer_Supplier_Name__c;
                        else
                            T2_name = a.ASI_CRM_CN_Cash_Payee_Name_T1__r.Name;
                    }
                    else{
                        if (a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Legal_Name__c!= null)
                            T2_name = a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Legal_Name__c;
                        else if (a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Chi_Name__c!= null)
                            T2_name = a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Chi_Name__c;
                        else
                            T2_name = a.ASI_CRM_CN_Payee_Name_T2_lookup__r.Name;
                    }
                    //End by Twinkle 24Oct2014
                    
                    RVP = a.ASI_CRM_CN_RVP_Name__c;
                    RFM = a.ASI_CRM_CN_RFM_Name__c;
                        
                    if (a.ASI_CRM_CN_Amount__c != null)
                        strAmountdecimal = a.ASI_CRM_CN_Amount__c;
                    if (a.ASI_CRM_CN_Reason__c != null && a.ASI_CRM_CN_Reason__c != ''){
                        if (a.ASI_CRM_CN_Reason__c.contains('\n')){
                            strReason = a.ASI_CRM_CN_Reason__c.replace('\n','<br/>');
                        }else{
                            strReason = a.ASI_CRM_CN_Reason__c;
                        }
                    }
                        /*
                    if (a.ASI_CRM_CN_Type__c == 'Cash' && a.ASI_CRM_CN_Cash_Amount__c != null)
                        strAmountdecimal = a.ASI_CRM_CN_Cash_Amount__c;
                    if (a.ASI_CRM_CN_Discount_Amount__c!= null && a.ASI_CRM_CN_Type__c == 'Discount')
                        strAmountdecimal = a.ASI_CRM_CN_Discount_Amount__c;
                    if (a.ASI_CRM_CN_Discount_Amount__c!= null && a.ASI_CRM_CN_Type__c == 'Others')
                        strAmountdecimal = a.ASI_CRM_CN_Discount_Amount__c;
                        */
                }
            }
        }
        
            string PDFPage;
            if (PTSelected == 'Instruction'){
                if (strAmountdecimal  > 0)
                    PDFPage = '/apex/ASI_CRM_CN_PaymentInstrPDFPage?id=';
                else if (strAmountdecimal  <= 0)
                    PDFPage = '/apex/ASI_CRM_CN_PaymentInstrCancelPDFPage?id=';
            }
            if (PTSelected == 'Receipt'){
                PDFPage = '/apex/ASI_CRM_CN_PaymentReceiptPDFPage?id=';
                // if (strAmountdecimal  <= 0)
                //     hasError = true;
            }
        if (hasError == false){
            System.debug(LoggingLevel.INFO, '*** PDFPage: ' + PDFPage);
            pageReference returnPage = new pageReference(PDFPage + PageId);
            returnPage.getParameters().put('T1',T1_name );
            returnPage.getParameters().put('T2',T2_name );
            returnPage.getParameters().put('strAmount1', string.valueof(strAmountdecimal));
            returnPage.getParameters().put('Remarks1', strReason);
            returnPage.getParameters().put('invoice', invoice1);
            returnPage.getParameters().put('RVP', RVP);
            returnPage.getParameters().put('RFM', RFM);
            returnPage.getParameters().put('WS', WS);
            returnPage.getParameters().put('name', name);
            System.debug('*** returnPage.getParameters(): ' + JSON.serializePretty(returnPage.getParameters()) + '');
            returnPage.setRedirect(true);
            return returnPage;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Amount must be more than 0.'));
            return null;
        }
    }
    
    // 2015-07-09 Ben @ Elufa
    public pageReference GeneratePDFT2(){
        boolean hasError = false;
        string T1_name;
        string T2_name;
        string strReason = '';
        String invoice1;
        String WS;
        String type = MType.get(PayeeItem);
        
        if(MInvoiceNum.get(PayeeItem) != null)
            invoice1 = MInvoiceNum.get(PayeeItem); 
        else
            invoice1 = ' - ';

        if (PayeeLineItems.size() > 0){ 
            for(ASI_CRM_CN_PH_Payee_Line_Item__c a : PayeeLineItems){
                if (a.id == PayeeItem){     
                    
                    WS = a.ASI_CRM_CN_Payee_T1__r.ASI_MFM_Customer_Supplier_Number__c;
                    name = a.Name;
                    
                    if (PTSelected == 'Instruction'){
                        if (a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Legal_Name__c != null)    
                            T1_name = a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Legal_Name__c;
                        else if (a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Chi_Name__c!= null)
                            T1_name = a.ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Chi_Name__c;
                        else
                            T1_name = a.ASI_CRM_CN_Payee_Name_T1__r.Name;
                    }
                    
                    if (type == 'Cash' || (type == 'Cash & Discount' && MCash != null)){
                        if (a.ASI_CRM_CN_Cash_Payee_Name_T1__r.ASI_MFM_Customer_Supplier_Name__c != null)
                            T2_name = a.ASI_CRM_CN_Cash_Payee_Name_T1__r.ASI_MFM_Customer_Supplier_Name__c;
                        else
                            T2_name = a.ASI_CRM_CN_Cash_Payee_Name_T1__r.Name;
                    }
                    else{
                        if (a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Legal_Name__c!= null)
                            T2_name = a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Legal_Name__c;
                        else if (a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Chi_Name__c!= null)
                            T2_name = a.ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Chi_Name__c;
                        else
                            T2_name = a.ASI_CRM_CN_Payee_Name_T2_lookup__r.Name;
                    }
                    
                    RVP = a.ASI_CRM_CN_RVP_Name__c;
                    RFM = a.ASI_CRM_CN_RFM_Name__c;
                        
                    if (a.ASI_CRM_CN_Amount__c != null)
                        strAmountdecimal = a.ASI_CRM_CN_Amount__c;
                    if (a.ASI_CRM_CN_Reason__c != null && a.ASI_CRM_CN_Reason__c != ''){
                        if (a.ASI_CRM_CN_Reason__c.contains('\n')){
                            strReason = a.ASI_CRM_CN_Reason__c.replace('\n','<br/>');
                        }else{
                            strReason = a.ASI_CRM_CN_Reason__c;
                        }
                    }
                }
            }
        }
        
            string PDFPage;
            if (PTSelected == 'Instruction'){
                if (strAmountdecimal  > 0)
                    PDFPage = '/apex/ASI_CRM_CN_PaymentInstrT2PDFPage?id=';
                else if (strAmountdecimal  <= 0)
                    PDFPage = '/apex/ASI_CRM_CN_PaymentInstrCancelT2PDFPage?id=';
            }
        if (hasError == false){
            pageReference returnPage = new pageReference(PDFPage + PageId);
            returnPage.getParameters().put('T1',T1_name );
            returnPage.getParameters().put('T2',T2_name );
            returnPage.getParameters().put('strAmount1', string.valueof(strAmountdecimal));
            returnPage.getParameters().put('Remarks1', strReason);
            returnPage.getParameters().put('invoice', invoice1);
            returnPage.getParameters().put('RVP', RVP);
            returnPage.getParameters().put('RFM', RFM);
            returnPage.getParameters().put('WS', WS);
            returnPage.getParameters().put('name', name);
            returnPage.setRedirect(true);
            return returnPage;
        }else
            return null;
    }
    // 2015-07-09 Ben @ Elufa End
    
    public pageReference CancelPage(){
        pageReference returnPage = new pageReference('/apex/ASI_CRM_RedirectPRViewPage?id=' + PageId);  //change by laputa 20170826 from   ASI_CRM_CN_Payment_Header_Page to ASI_CRM_RedirectPRViewPage
        returnPage.setRedirect(true);
        return returnPage;
    }
}