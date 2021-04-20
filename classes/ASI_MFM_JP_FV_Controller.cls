public class ASI_MFM_JP_FV_Controller {
    //SQL
    private String soql {get;set;}{soql=null;}
    public String WhereStatm {get;set;}{WhereStatm = '';}
    
    //Search
    public transient String FinVerify {get;set;}{FinVerify=null;}
    public transient String ETLCheckbox {get;set;}{FinVerify=null;}
    public transient String PO_ID {get;set;}{PO_ID=null;}
    public transient String POline_ID {get;set;}{POline_ID=null;}
    public transient String PORLineID {get;set;}{PORLineID=null;}
    public transient String Payment_ID {get;set;}{Payment_ID=null;}
    public transient String PayLine_ID {get;set;}{PayLine_ID=null;}
    public transient String SubBrand_Code {get;set;}{SubBrand_Code=null;}
    public transient String PaymentStatus {get;set;}{PaymentStatus=null;}
    public transient String InvoiceNumber {get;set;}{InvoiceNumber=null;}
    public transient String Payee {get;set;}{Payee=null;}
    public transient String Fiscalyear {get;set;}{Payee=null;}
    public String reportFolderid {get;set;}
    public String NowFY {get;set;}
    
    //Page Information
    public boolean SaveSuccess {get;set;}{ SaveSuccess=false;}
    public String Msg {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;} 
    
    
    //Data
    private String init_soql {get;set;} 
    public String jsonDataMinimal {set;get;} {jsonDataMinimal = null;}
    public String lineItemJson {get; set;} {lineItemJson = null;}
    public transient List<ASI_MFM_Payment_Line_Item__c> LineItem {get; set;} 
    public transient Map<Id, ASI_MFM_Payment_Line_Item__c> PaymentLineMap { get; set; } {PaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>();}
    
    public transient Map<id, id> APACMap { get; set; } {APACMap = new Map<id, id>();}//id is AP Code ID
    
    //
    public static final String selectedFields  =  'select id, name,ASI_MFM_Payment__r.ASI_MFM_No_Need_to_ETL__c,ASI_MFM_Payment__r.createddate,createddate,ASI_MFM_Tax_Code__c,ASI_MFM_Payment__r.ASI_MFM_Tax_Code__r.name,ASI_MFM_Payment__r.ASI_MFM_JP_Payment_Date__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_PO_Receipt_Item__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c, ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c,ASI_MFM_AP_Remark__c, ASI_MFM_Payment__r.Id, ASI_MFM_Recharge__c, ASI_MFM_Payment__r.ASI_MFM_Recharge__c, ASI_MFM_Amount_with_Tax__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Date__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Payment__r.ASI_MFM_VAT_Rate__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_G_L_Date__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment_Date__c,ASI_MFM_Invoice_Date__c, ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Payment__r.ASI_MFM_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_List_Item_Description__c from ASI_MFM_Payment_Line_Item__c';
    public static final String mustWhereClause = ' where ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment__r.ASI_MFM_Status__c = \'Submitted\' ';// 
    public static final String Payment_Developer_Name = 'ASI_MFM_JP_Payment';
    
    public static final String FolderName ='ASI MFM JP Report';
    
    
    /*Method: For Auto-Complete*/
    @RemoteAction
    public static List<sObject> findSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        // create the filter text
        String filter = qry;
        //begin building the dynamic soql query
        String soql = 'select Id, Name from ' + obj + filter +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        try {
            sobjs = Database.query(soql);
            return sobjs; 
        }
        catch (QueryException e) {
            return null;
        }
        return sobjs;
    }
    
    
    
    public void init() {
        
        
        //select ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c from ASI_MFM_AP_AC_Code_Map__c
        List<Folder> FolderList = new List<Folder>();
        FolderList = [SELECT Id FROM Folder WHERE Name =:FolderName And Type = 'Report'];
        reportFolderid = FolderList!=null? (String)FolderList[0].Id : '';
        
        
        NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        Fiscalyear=NowFY;
        
        init_soql = selectedFields +  mustWhereClause  + ' AND ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \''+ Payment_Developer_Name +'%\'';
        
        init_soql+=ASI_MFM_ByPass_Setting.ReturnSqlStatement('ASI_MFM_JP_FV_Controller','Initialization','JP');
        
        if(Fiscalyear!=null && Fiscalyear.length()>0){
            WhereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        WhereStatm +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false and ASI_MFM_ETL__c=false';
        FinVerify='Unchecked';
        ETLCheckbox='Unchecked';
        
        runQuery();
    }
    
    
    
    public void runQuery() {
        
        
        
        
        try {   
            LineItem = new List<ASI_MFM_Payment_Line_Item__c>();
            LineItem = Database.query(init_soql + WhereStatm);
            
            if(LineItem!=null){
                PaymentLineMap = new  Map<Id, ASI_MFM_Payment_Line_Item__c>();
                LineItemJson = JSON.serialize(LineItem);
                PaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>(lineItem);
                
                List<SmallDataRow> dataRows = new List<SmallDataRow>();  
                
                for(ASI_MFM_Payment_Line_Item__c  paymentline : LineItem){  
                    paymentline.ASI_MFM_Tax_Code__c=paymentline.ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c;
                    paymentline.ASI_MFM_G_L_Date__c=paymentline.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c;
                    paymentline.ASI_MFM_A_C_Code__c=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                    paymentline.ASI_MFM_AP_Code__c=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c;
                    SmallDataRow  inputFields = new SmallDataRow(paymentline); 
                    dataRows.add(inputFields);  
                    PaymentLineMap.put(paymentline.Id, paymentline);
                }
                this.jsonDataMinimal = JSON.serialize(dataRows);   
                system.debug(lineItem);  
            }else{
                LineItemJson = null;
                PaymentLineMap  = null;
                jsonDataMinimal = null;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input'));
        }
    }
    
    
    
    public PageReference runSearch() {
        WhereStatm = '';
        
        if(FinVerify!=null && FinVerify.length()>0){
            if(FinVerify=='Unchecked'){
                WhereStatm +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
                
            }
            if(FinVerify=='Checked'){
                WhereStatm +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =true ';
                
            }
        }
         if(ETLcheckbox!=null && ETLcheckbox.length()>0){
            if(ETLcheckbox=='Unchecked'){
                WhereStatm +=  ' and ASI_MFM_ETL__c =false ';
                
            }
            if(ETLcheckbox=='Checked'){
                WhereStatm +=  ' and ASI_MFM_ETL__c =true ';
                
            }
        }
        
        if(Payment_ID!=null && Payment_ID.length()>0){
            WhereStatm += ' and ASI_MFM_Payment__r.name LIKE \''+String.escapeSingleQuotes(Payment_ID)+'%\'';
        }
        
        if(PayLine_ID!=null && PayLine_ID.length()>0){
            WhereStatm += ' and name LIKE \''+String.escapeSingleQuotes(PayLine_ID)+'%\'';
        }
        
        if(PORLineID!=null && PORLineID.length()>0){
            WhereStatm += ' and ASI_MFM_PO_Receipt_Item__r.name LIKE \''+String.escapeSingleQuotes(PORLineID)+'%\'';
        }
        
        if(PO_ID!=null && PO_ID.length()>0){
            WhereStatm += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
        }
        if(POline_ID!=null && POline_ID.length()>0){
            WhereStatm += ' and ASI_MFM_PO_Line_Item__r.name LIKE \''+String.escapeSingleQuotes(POline_ID)+'%\'';
        }
        
        
        if(PaymentStatus!=null && PaymentStatus.length()>0){// 
            WhereStatm += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(PaymentStatus)+'%\'';
        }
        
        if(InvoiceNumber!=null && InvoiceNumber.length()>0){
            WhereStatm += ' and ASI_MFM_Invoice_Number__c LIKE \'%'+String.escapeSingleQuotes(InvoiceNumber)+'%\''; //ASI_MFM_Payment__r.
        }
        
        
        if(Payee!=null && Payee.length()>0){
            WhereStatm += ' and ASI_MFM_Payee__r.name LIKE \'%'+String.escapeSingleQuotes(Payee)+'%\'';
        }
        
        if(Fiscalyear!=null && Fiscalyear.length()>0 && Payee.length()==0 && InvoiceNumber.length()==0 && POline_ID.length()==0 && PO_ID.length()==0 && PayLine_ID.length()==0 && Payment_ID.length()==0){
            WhereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        SaveSuccess=false;
        UpsertPermission=true;
        runQuery();
        return null;
    }    
    
    
    public PageReference save() {
        //Get AP & A/C Code Map
        List<ASI_MFM_AP_AC_Code_Map__c> APACList = new List<ASI_MFM_AP_AC_Code_Map__c>();  
        APACList=[select id,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.id from ASI_MFM_AP_AC_Code_Map__c where ASI_MFM_AP_Code__r.RecordType.DeveloperName='ASI_JP_AP_Code'];
        
        APACMap = new Map<id, id>();
        for(ASI_MFM_AP_AC_Code_Map__c apac:APACList){
            if(!APACMap.containsKey(apac.ASI_MFM_AP_Code__r.id)){
                APACMap.put(apac.ASI_MFM_AP_Code__r.id, apac.ASI_MFM_A_C_Code__c);
            }
        }
        //Get AP & A/C Code Map --End
        
        UpsertPermission = true;
        SaveSuccess = false;
        PageReference pageRef = null;
        
        Database.upsertResult[] updateTarget; //update Payment lines
        Database.upsertResult[] updatePaymentHeadersResult;
        Database.upsertResult[] updatePOLinesResult;
        
        //Count Number of line update
        Integer count = 0;
        Set<String> verLines = new Set<String>();
        String invoiceMessage ='';
        
        if(LineItemJson!=null ){
            LineItem = LineItem == null? (List<ASI_MFM_Payment_Line_Item__c>) JSON.deserialize(LineItemJson, List<ASI_MFM_Payment_Line_Item__c>.class): LineItem ;
        } 
        if(LineItem!=null){
            PaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>(lineItem);
        }       
        
        
        List<ASI_MFM_Payment_Line_Item__c> paymentLinesToUpdate = new List<ASI_MFM_Payment_Line_Item__c>();  
        List<SmallDataRow> smallTableRow = (List<SmallDataRow>)JSON.deserialize(jsonDataMinimal, List<SmallDataRow>.class);  
        
        //system.assertEquals(LineItem.size(), 100);
        
        Boolean isRedirect = True; 
        
        
        for(SmallDataRow sdr : smallTableRow){  
            
            if(PaymentLineMap!=null){
                
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Invoice_Date__c  = sdr.invoiceDateStr!=null? date.parse(sdr.invoiceDateStr): null;
                PaymentLineMap.get(sdr.recordId).ASI_MFM_G_L_Date__c  = sdr.glDateStr!=null? date.parse(sdr.glDateStr): null;
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment_Line_Item_Finance_Verify__c  = sdr.FVerify ;
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Status_Invalid__c  = sdr.Invalid ;
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Invoice_Number__c = sdr.invoiceNumber!=null? sdr.invoiceNumber: null; 
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Comments__c = sdr.APremark!=null? sdr.APremark: null; 
                PaymentLineMap.get(sdr.recordId).ASI_MFM_AP_Code__c = sdr.apCode!=null? Id.valueOf(sdr.apCode) : null; 
                // PaymentLineMap.get(sdr.recordId).ASI_MFM_Tax_Code__c = sdr.taxcode!=null? Id.valueOf(sdr.taxcode) : null; 
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Invoice_Due_Date__c = sdr.invoiceDueDateStr !=null? date.parse(sdr.invoiceDueDateStr): null; 

                if(PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment__r.ASI_MFM_Status__c !='Draft' && !PaymentLineMap.get(sdr.recordId).ASI_MFM_ETL__c ){ // Final
                    paymentLinesToUpdate.add(PaymentLineMap.get(sdr.recordId));
                }
                
                PaymentLineMap.put(sdr.recordId, PaymentLineMap.get(sdr.recordId));
                
            }
        }  
        /*
            if(PaymentLineMap!=null){
            
            for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){
            
            if (PaymentLine.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true ) {
            count++;
            verLines.add(PaymentLine.ASI_MFM_Payment__r.name);
            }
            
            if(PaymentLine.ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Final'){
            paymentLinesToUpdate.add(PaymentLine);
            }                      
            
            }
            }*/
        
        if(PaymentLineMap!=null && !PaymentLineMap.isEmpty() && paymentLinesToUpdate!=null && paymentLinesToUpdate.size()>0 ){
            //Only "Final" Status should be verified
            Map<Id, ASI_MFM_Payment_Line_Item__c> ValidatePaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>(paymentLinesToUpdate);
            isRedirect =  valdationCheckingStep(ValidatePaymentLineMap);
            
        }
        
        if(!isRedirect){
            //Save Fail
            UpsertPermission = false;
            SaveSuccess = false;
            return null;
        }
        
        Map<Id, ASI_MFM_Payment__c> update_ASI_MFM_Payments = new Map<Id, ASI_MFM_Payment__c>();
        Map<Id, ASI_MFM_PO_Line_Item__c> update_ASI_MFM_PO_Lines = new Map<Id, ASI_MFM_PO_Line_Item__c>();
        
        if(PaymentLineMap!=null && !PaymentLineMap.isEmpty()){
            for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){
                
                //-------------------------------------Update Payment Header -------------------------------------
                ASI_MFM_Payment__c  updatePayment = new ASI_MFM_Payment__c(Id = paymentLine.ASI_MFM_Payment__c);
                //updatePayment.ASI_MFM_Status__c = paymentLine.ASI_MFM_Payment_Line_Item_Finance_Verify__c? 'Submitted': updatePayment.ASI_MFM_Status__c ;
                //update_ASI_MFM_Payments.put(paymentLine.ASI_MFM_Payment__c,  updatePayment);
                
                //G/L Date
                if(paymentLine.ASI_MFM_G_L_Date__c!= null && (paymentLine.ASI_MFM_G_L_Date__c <> paymentLine.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c)){ //Update GL Date 
                    updatePayment.ASI_MFM_G_L_Date__c = paymentLine.ASI_MFM_G_L_Date__c; 
                    update_ASI_MFM_Payments.put(paymentLine.ASI_MFM_Payment__c,  updatePayment);
                }
                if(paymentLine.ASI_MFM_Status_Invalid__c){
                    updatePayment.ASI_MFM_Status__c='Draft';
                    //change line status
                    paymentLine.ASI_MFM_Payment_Line_Item_Finance_Verify__c=false;
                    paymentLine.ASI_MFM_Status_Invalid__c=false;
                    update_ASI_MFM_Payments.put(paymentLine.ASI_MFM_Payment__c,  updatePayment);
                }
                
                //Tax Code: ASI_MFM_Tax_Code__c
                //  if(paymentLine.ASI_MFM_Tax_Code__c!= null && (paymentLine.ASI_MFM_Tax_Code__c <> paymentLine.ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c)){ 
                //       updatePayment.ASI_MFM_Tax_Code__c = paymentLine.ASI_MFM_Tax_Code__c; 
                //      update_ASI_MFM_Payments.put(paymentLine.ASI_MFM_Payment__c,  updatePayment);
                //    }
                
                
                //--------------------------------------Update PO line ------------------------------------------
                ASI_MFM_PO_Line_Item__c updatePOLine = new ASI_MFM_PO_Line_Item__c(Id = paymentLine.ASI_MFM_PO_Line_Item__c);
                if(paymentLine.ASI_MFM_AP_Code__c!=null && (paymentLine.ASI_MFM_AP_Code__c <> paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c)){
                    updatePOLine.ASI_MFM_AP_Code__c = paymentLine.ASI_MFM_AP_Code__c;
                    if(APACMap.containsKey(paymentLine.ASI_MFM_AP_Code__c)){
                        updatePOLine.ASI_MFM_A_C_Code__c=APACMap.get(paymentLine.ASI_MFM_AP_Code__c);
                        paymentLine.ASI_MFM_A_C_Code__c=APACMap.get(paymentLine.ASI_MFM_AP_Code__c);
                    }else{
                        paymentline.ASI_MFM_A_C_Code__c=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                    }
                    update_ASI_MFM_PO_Lines.put(paymentLine.ASI_MFM_PO_Line_Item__c, updatePOLine);
                }else{
                    paymentline.ASI_MFM_AP_Code__c=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c;
                    paymentline.ASI_MFM_A_C_Code__c=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                }
                
                //Invoice Date is more than 31 days
                if (paymentline.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true ) {
                    count++;
                    if(paymentline.ASI_MFM_Payment__r.ASI_MFM_No_Need_to_ETL__c){
                        paymentline.ASI_MFM_ETL__c=true;
                    }
                    
                    Date cutoffdate=date.newinstance(paymentline.ASI_MFM_Payment__r.createddate.year(), paymentline.ASI_MFM_Payment__r.createddate.month(), paymentline.ASI_MFM_Payment__r.createddate.day());
                    if((cutoffdate.addDays(31))<paymentline.ASI_MFM_Invoice_Date__c && !verLines.contains(paymentline.ASI_MFM_Payment__r.name)){
                        invoiceMessage+='No: '+paymentline.ASI_MFM_Payment__r.name+':  Invoice Date is more than 31 days. '+'<br/>';
                    }
                    verLines.add(paymentline.ASI_MFM_Payment__r.name);
                   // invoiceMessage+=cutoffdate.addDays(31);
                }
                
                
            }
        }    
        
        
        //Update
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        try{   
            
            if(update_ASI_MFM_Payments!=null && update_ASI_MFM_Payments.size()>0){
                updatePaymentHeadersResult  = Database.upsert(update_ASI_MFM_Payments.values());
            }
            
            if(update_ASI_MFM_PO_Lines!=null && update_ASI_MFM_PO_Lines.size()>0){
                updatePOLinesResult = Database.upsert(update_ASI_MFM_PO_Lines.values());
            }
            
            
            if(paymentLinesToUpdate!=null && paymentLinesToUpdate.size()>0){
                updateTarget = Database.upsert(paymentLinesToUpdate);
            }
            
            Msg = count!=null && count>0? string.valueOf(count) + ' Payment Line(s) verified. Payment No. ' +verLines  +'</br>'+invoiceMessage: ' No selected Payment line(s) is needed to be verified. ' +'</br>';
            if(invoiceMessage!=''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, invoiceMessage));
            }
            SaveSuccess=true;
            /*if(PaymentLineMap!=null){
			lineItem = new List<ASI_MFM_Payment_Line_Item__c>();
			lineItem.addAll(PaymentLineMap.values());
				LineItemJson = JSON.serialize(LineItem);
			}
		*/
            init();
        }catch(Exception e){
            
            UpsertPermission = false;
            SaveSuccess= false;
            msg += 'Save Error!'+ e.getMessage() +'</br>';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error!' + e));
            Database.rollback(pSavepoint);      
            return null;
            
        }
        return pageRef;
        
    }    
    
    
    //Method: For valdationCheckingStep  
    public Boolean valdationCheckingStep(Map<Id, ASI_MFM_Payment_Line_Item__c> PaymentLineMap){
        
        Boolean isProcess = true;
        Integer idx = 1; 
        msg = '';
        
        Set<Id> ACCodes = new Set<Id>();
        Set<Id> APCodes = new Set<Id>();
        if(PaymentLineMap == null) return false;       
        
        
        Map<String, List<ASI_MFM_Payment_Line_Item__c>> validationCheckingOnInvoice = new Map<String, List<ASI_MFM_Payment_Line_Item__c>> ();
        List<ASI_MFM_Payment_Line_Item__c> relatedInvoicePaymentLines = new  List<ASI_MFM_Payment_Line_Item__c> ();
        
        if(ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_JP_JDE_Accruals')) {
            Msg = '';
            return true;
        }else{
            
            //1st step: check required fields  
            for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){ 
                // if(paymentLine.ASI_MFM_Tax_Code__c == null){
                //    isProcess = false;      
                //    paymentLine.ASI_MFM_Tax_Code__c.addError('Please input Tax Code.');
                //    msg += 'Save Error: ('+ paymentLine.Name + '): '+  ' Please input Tax Code.'  +'</br>';  
                //}
                
                
                if(paymentLine.ASI_MFM_AP_Code__c == null){
                    isProcess = false;      
                    paymentLine.ASI_MFM_AP_Code__c.addError('Please input AP Code.');
                    msg += 'Save Error: ('+ paymentLine.Name + '): '+  ' Please input AP Code.'  +'</br>';                
                }else{
                    
                    APCodes.add(paymentLine.ASI_MFM_AP_Code__c);
                }
                
                
            }
             
            // 2nd step: check same invoice number should contain same invoice date and gl date ,Tax Code
            for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){ 
                
                //Check whether the data is empty
                if(paymentLine.ASI_MFM_Invoice_Date__c ==null ){
                    isProcess = false;      
                    paymentLine.ASI_MFM_Invoice_Date__c.addError('Please input Invoice Date.');
                    msg += 'Save Error: ('+ paymentLine.Name + '): '+  ' Please input Invoice Date.'  +'</br>';
                }
                
                if(String.isEmpty(paymentLine.ASI_MFM_Invoice_Number__c)){
                    isProcess = false;      
                    paymentLine.ASI_MFM_Invoice_Number__c.addError('Please input Invoice No.');
                    msg += 'Save Error: (' + paymentLine.Name + '): '+  ' Please input Invoice No.'  +'</br>';
                }
                else{
                    relatedInvoicePaymentLines = validationCheckingOnInvoice.get(paymentLine.ASI_MFM_Invoice_Number__c);
                    if(relatedInvoicePaymentLines ==  null) relatedInvoicePaymentLines = new List<ASI_MFM_Payment_Line_Item__c> ();
                    relatedInvoicePaymentLines.add(paymentLine);
                    validationCheckingOnInvoice.put(paymentLine.ASI_MFM_Invoice_Number__c, relatedInvoicePaymentLines);
                }
            }
            
            if(!validationCheckingOnInvoice.isEmpty()){
                
                
                for(String invoiceNumber : validationCheckingOnInvoice.keyset()){
                    
                    Set<Date> invoiceDate = new Set<Date>();
                    Set<Date> glDate = new Set<Date>();
                    Set<ID> TaxCodes = new Set<ID>();
                    Set<Id> samePayee = new Set<Id>();
                    Set<String> recharges = new Set<String>();
                    // Set<Date> invoiceDueDate = new Set<Date>();
                    Boolean invoiceValid = true;
                    
                    for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                        
                        invoiceDate.add(paymentLine.ASI_MFM_Invoice_Date__c);
                        glDate.add(paymentLine.ASI_MFM_G_L_Date__c);
                        TaxCodes.add(paymentLine.ASI_MFM_Tax_Code__c);
                        samePayee.add(paymentLine.ASI_MFM_Payee__c);
                        if(paymentLine.ASI_MFM_Recharge__c) recharges.add(invoiceNumber);
                        // invoiceDueDate.add(paymentLine.ASI_MFM_Invoice_Due_Date__c);
                    }
                    
                    if(invoiceDate!=null&& invoiceDate.size()>1) {
                        //more than one invoice date 
                        for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                            
                            isProcess = false;                         
                            invoiceValid = false;
                            paymentLine.ASI_MFM_Invoice_Date__c.addError('Please check invoice Date');
                        }                    
                    }
                    
                    if(glDate!=null&& glDate.size()>1) {
                        //more than one gl date 
                        for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                            isProcess = false;    
                            invoiceValid = false;
                            paymentLine.ASI_MFM_G_L_Date__c.addError('Please check GL Date');
                        }                    
                    }
                    
                    if(TaxCodes!=null&& TaxCodes.size()>1) {
                        //more than one Tax Code
                        for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                            isProcess = false;    
                            invoiceValid = false;
                            paymentLine.ASI_MFM_Tax_Code__c.addError('Please check Tax Code');
                        }                    
                    }
                    
                    if(samePayee!=null&& samePayee.size()>1){
                        //more than one payee 
                        for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                            isProcess = false;    
                            invoiceValid = false;
                            paymentLine.ASI_MFM_Payee__c.addError('Please check Payee');
                        }                     
                    }
                    
                    
                    if(!invoiceValid)
                        msg += 'Save Error: '+  '(Invoice Number: '+ InvoiceNumber + ') Same invoice number should have same Payee, same Invoice Date, G/L Date and Tax Code.'+'</br>';
                }
                
                
            }
            
            
            
        }
        
        
        
        return isProcess;
        
    }
    
    
    public class SmallDataRow {  
        
        public Id recordId                        { get; set;}  
        public String glDateStr                   { get; set;}
        public String invoiceDateStr              { get; set;}
        public String acCode                      { get; set;}
        public String taxcode                      { get; set;}
        public String apCode                      { get; set;}
        public String invoiceDueDateStr           { get; set;}
        public String invoiceNumber               { get; set;}
        public Boolean FVerify                    { get; set;}
        public String APremark                    { get; set;} 
        public Boolean Invalid                    { get; set;} 
        //public boolean recharge                   { get; set;}
        
        
        public SmallDataRow(ASI_MFM_Payment_Line_Item__c paymentline){  
            this.glDateStr = paymentline.ASI_MFM_G_L_Date__c !=null? paymentline.ASI_MFM_G_L_Date__c.format():null;
            this.recordId =  paymentline.Id;  
            this.invoiceNumber = paymentline.ASI_MFM_Invoice_Number__c!=null?  paymentline.ASI_MFM_Invoice_Number__c :null;
            this.FVerify = paymentline.ASI_MFM_Payment_Line_Item_Finance_Verify__c;
            this.invoiceDateStr  = paymentline.ASI_MFM_Invoice_Date__c !=null? paymentline.ASI_MFM_Invoice_Date__c.format():null;
            this.APremark = paymentline.ASI_MFM_Comments__c !=null ? paymentline.ASI_MFM_Comments__c :null;
            this.apCode = paymentline.ASI_MFM_AP_Code__c!=null? String.valueOf(paymentLine.ASI_MFM_AP_Code__c): null;
            this.invoiceDateStr = paymentline.ASI_MFM_Invoice_Due_Date__c !=null? paymentline.ASI_MFM_Invoice_Due_Date__c.format():null;
            // this.taxcode= paymentline.ASI_MFM_Tax_Code__c!=null? String.valueOf(paymentLine.ASI_MFM_Tax_Code__c): null;
            this.Invalid = paymentline.ASI_MFM_Status_Invalid__c; 
        }  
    }   
    
    
    
    
    
}