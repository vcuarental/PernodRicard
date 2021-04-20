public class ASI_MFM_PH_FV_Controller {
    //SQL
    private String soql {get;set;}{soql=null;}
    public String WhereStatm {get;set;}{WhereStatm = '';}
    
    //Search
    public transient String FinVerify {get;set;}{FinVerify=null;}
    public transient String PO_ID {get;set;}{PO_ID=null;}
    public transient String POline_ID {get;set;}{POline_ID=null;}
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
    public boolean SaveSuccess {get;set;}
    public String Msg {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;} 
    
    public String a_c_code_RecordType_Developer_Name {set;get;}
    public String PageRecordType {set;get;}
    
    private String init_soql {get;set;} 
    public String jsonDataMinimal {set;get;} {jsonDataMinimal = null;}
    public String lineItemJson {get; set;} {lineItemJson = null;}
    public transient List<ASI_MFM_Payment_Line_Item__c> LineItem {get; set;} 
    public transient Map<Id, ASI_MFM_Payment_Line_Item__c> PaymentLineMap { get; set; } {PaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>();}
    
    public static final String DP_ACCode_RecordType_Developer_Name ='ASI_MFM_PH_DP_A_C_Code';
    public static final String DF_ACCode_RecordType_Developer_Name ='ASI_MFM_PH_DF_A_C_Code';
     
    
    public static final String selectedFields  =  'select id, name,ASI_MFM_Effective__c,ASI_MFM_Payee__r.name,ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c,ASI_MFM_Payee__r.ASI_TH_CRM_Supplier__c,ASI_MFM_Tax_Rate__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c,ASI_MFM_AP_Remark__c, ASI_MFM_Payment__r.Id, ASI_MFM_Recharge__c, ASI_MFM_Payment__r.ASI_MFM_Recharge__c, ASI_MFM_Amount_with_Tax__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Date__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_G_L_Date__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment_Date__c,ASI_MFM_Invoice_Date__c, ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Payment__r.ASI_MFM_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_List_Item_Description__c from ASI_MFM_Payment_Line_Item__c';
    public static final String mustWhereClause = ' where ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Draft\'';
    public static final String PH_DF_Payment_Developer_Name = 'ASI_MFM_PH_DF_Payment';
    public static final String PH_DP_Payment_Developer_Name = 'ASI_MFM_PH_DP_Payment';
    
    public static final String FolderName ='ASI MFM PH Report';


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
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            return sobjs; 
        }
        catch (QueryException e) {
            return null;
        }
        return sobjs;
    }
    

    
    public void initDF() { //for Duty Free
    
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
        
        PageRecordType='DF';
        this.a_c_code_RecordType_Developer_Name= DF_ACCode_RecordType_Developer_Name; //define AC Code RecordTypeName
        init_soql = selectedFields +  mustWhereClause  + ' AND ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \''+ PH_DF_Payment_Developer_Name +'%\'';
        if(Fiscalyear!=null && Fiscalyear.length()>0){
            WhereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
              WhereStatm +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
         FinVerify='Unchecked';
        //WhereStatm += 'and (ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c >= TODAY OR ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c = NULL) ';
            
        runQuery();
    }
    

    public void initDP() { //for Duty Paid
    
        List<Folder> FolderList = new List<Folder>();
        FolderList = [SELECT Id FROM Folder WHERE Name =:FolderName And Type = 'Report'];
        reportFolderid =FolderList !=null? (String)FolderList[0].Id : '';
        
        //Set Filter 
        NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
              WhereStatm +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
         FinVerify='Unchecked';
        
        Fiscalyear=NowFY;
        
        
        this.a_c_code_RecordType_Developer_Name= DP_ACCode_RecordType_Developer_Name; //define AC Code RecordTypeName
        init_soql = selectedFields +  mustWhereClause  + ' AND ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \''+ PH_DP_Payment_Developer_Name +'%\'';
         if(Fiscalyear!=null && Fiscalyear.length()>0){
            WhereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';   //WhereStatm += 'and (ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c >= TODAY OR ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c = NULL) ';
        }
        
        runQuery();
    }
    
        
    
    public void runQuery() {

        UpsertPermission = true;
        SaveSuccess=false;
        
        try {   
                LineItem = new List<ASI_MFM_Payment_Line_Item__c>();
                LineItem = Database.query(init_soql + WhereStatm);
            	
                if(LineItem!=null){
                     PaymentLineMap = new  Map<Id, ASI_MFM_Payment_Line_Item__c>();
                     LineItemJson = JSON.serialize(LineItem);
                     PaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>(lineItem);
                     
                     List<SmallDataRow> dataRows = new List<SmallDataRow>();  
                    
                     for(ASI_MFM_Payment_Line_Item__c  paymentline : LineItem){  
                         
                            paymentline.ASI_MFM_G_L_Date__c=paymentline.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c;
                            paymentline.ASI_MFM_A_C_Code__c=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                            paymentline.ASI_MFM_Recharge__c=paymentline.ASI_MFM_Recharge__c; //Copy Recharge Checkbox value
                         	paymentline.ASI_MFM_Tax_Rate__c=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c;
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
        if(Payment_ID!=null && Payment_ID.length()>0){
            WhereStatm += ' and ASI_MFM_Payment__r.name LIKE \''+String.escapeSingleQuotes(Payment_ID)+'%\'';
        }
        
        if(PayLine_ID!=null && PayLine_ID.length()>0){
            WhereStatm += ' and name LIKE \''+String.escapeSingleQuotes(PayLine_ID)+'%\'';
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
        
        /*
        if (fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate_s = DateTime.newInstance(fromDate.ASI_MFM_G_L_Date__c.year(),fromDate.ASI_MFM_G_L_Date__c.month(),fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            WhereStatm += ' AND ASI_MFM_Receipt_Date__c >= ' + fromDate_s + ''; 
        }
        if (toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate_c = DateTime.newInstance(toDate.ASI_MFM_G_L_Date__c.year(),toDate.ASI_MFM_G_L_Date__c.month(),toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            WhereStatm += ' AND ASI_MFM_Receipt_Date__c <= ' + toDate_c + ''; 
        }
        */
        runQuery();
        return null;
    }    
    
    
    public PageReference save() {
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        
         String RecordTypeStr = params.get('ASI_MFM_PH_ACCODE_RECORD_TYPE');
         String SearchRecordType = (RecordTypeStr!=null&& RecordTypeStr=='DF')? DF_ACCode_RecordType_Developer_Name:DP_ACCode_RecordType_Developer_Name; 
         
        
        UpsertPermission = true;
        SaveSuccess = false;
        PageReference pageRef = null;
        
        Database.upsertResult[] updateTarget; //update Payment lines
        Database.upsertResult[] updatePaymentHeadersResult;
        Database.upsertResult[] updatePOLinesResult;
        Database.upsertResult[] updatePOResult;
        

        //Count Number of line update
        Integer count = 0;
        Set<String> verLines = new Set<String>();
 
             if(LineItemJson!=null){
                 
                 LineItem = (List<ASI_MFM_Payment_Line_Item__c>) JSON.deserialize(LineItemJson, List<ASI_MFM_Payment_Line_Item__c>.class);

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
                 
                 if(!PaymentLineMap.get(sdr.recordId).ASI_MFM_ETL__c && PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Final' ){
                     PaymentLineMap.get(sdr.recordId).ASI_MFM_Invoice_Date__c  = sdr.invoiceDateStr!=null? date.parse(sdr.invoiceDateStr): null;
                     PaymentLineMap.get(sdr.recordId).ASI_MFM_G_L_Date__c  = sdr.glDateStr!=null? date.parse(sdr.glDateStr): null;
                     PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment_Line_Item_Finance_Verify__c  = sdr.FVerify ;
                     PaymentLineMap.get(sdr.recordId).ASI_MFM_Invoice_Number__c = sdr.invoiceNumber!=null? sdr.invoiceNumber: null; 
                     PaymentLineMap.get(sdr.recordId).ASI_MFM_AP_Remark__c = sdr.APremark!=null? sdr.APremark: null; 
                     PaymentLineMap.get(sdr.recordId).ASI_MFM_A_C_Code__c = sdr.acCode!=null? Id.valueOf(sdr.acCode) : null; 
                     PaymentLineMap.get(sdr.recordId).ASI_MFM_Invoice_Due_Date__c = sdr.invoiceDueDateStr !=null? date.parse(sdr.invoiceDueDateStr): null; 
                     PaymentLineMap.get(sdr.recordId).ASI_MFM_Recharge__c = sdr.recharge ;
                     PaymentLineMap.get(sdr.recordId).ASI_MFM_Tax_Rate__c = sdr.vat ;
                 }
                
                 if (PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment_Line_Item_Finance_Verify__c == true  && !PaymentLineMap.get(sdr.recordId).ASI_MFM_ETL__c) {
                    count++;
                    verLines.add(PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment__r.name);
                    } 
                
                if(PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Final'  && !PaymentLineMap.get(sdr.recordId).ASI_MFM_ETL__c){
                    paymentLinesToUpdate.add(PaymentLineMap.get(sdr.recordId));
                }
                
            }

        }       


        if(PaymentLineMap!=null && !PaymentLineMap.isEmpty() && paymentLinesToUpdate!=null && paymentLinesToUpdate.size()>0 ){
            //Only "Final" Status should be verified
            Map<Id, ASI_MFM_Payment_Line_Item__c> ValidatePaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>(paymentLinesToUpdate);
            isRedirect =  valdationCheckingStep(ValidatePaymentLineMap, SearchRecordType);
            system.debug('TestRedirect'+ValidatePaymentLineMap);
        }
 
         if(!isRedirect){
            
            UpsertPermission = false;
            SaveSuccess = false;
            return null;
            
        }
        
        Map<Id, ASI_MFM_Payment__c> update_ASI_MFM_Payments = new Map<Id, ASI_MFM_Payment__c>();
        Map<Id, ASI_MFM_PO__c> update_ASI_MFM_PO = new Map<Id, ASI_MFM_PO__c>();
        Map<Id, ASI_MFM_PO_Line_Item__c> update_ASI_MFM_PO_Lines = new Map<Id, ASI_MFM_PO_Line_Item__c>();
        
        if(PaymentLineMap!=null && !PaymentLineMap.isEmpty() && paymentLinesToUpdate!=null && !paymentLinesToUpdate.isEmpty()){
            
            for(ASI_MFM_Payment_Line_Item__c paymentLine : paymentLinesToUpdate){                 // PaymentLineMap.values()){
                
               //Update Payment Header
                ASI_MFM_Payment__c  updatePayment = new ASI_MFM_Payment__c(Id = paymentLine.ASI_MFM_Payment__c);
                if(paymentLine.ASI_MFM_G_L_Date__c!= null && (paymentLine.ASI_MFM_G_L_Date__c <> paymentLine.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c)){ //Update GL Date 
                    system.debug('paymentline had changed GL Date: ' + paymentline.Id);
                    updatePayment.ASI_MFM_G_L_Date__c = paymentLine.ASI_MFM_G_L_Date__c; 
                    update_ASI_MFM_Payments.put(paymentLine.ASI_MFM_Payment__c,  updatePayment);
                }
                
                /* Confirmed no need to have the recharge checkbox in Payment Header 8-9-2015
                if(paymentLine.ASI_MFM_Recharge__c <> paymentLine.ASI_MFM_Payment__r.ASI_MFM_Recharge__c){ //Update Recharge checkbox 
                    system.debug('paymentline had changed recharge checkbox: ' + paymentline.Id);
                    if(update_ASI_MFM_Payments!=null && update_ASI_MFM_Payments.containsKey(paymentLine.ASI_MFM_Payment__c)){
                        updatePayment =  update_ASI_MFM_Payments.get(paymentLine.ASI_MFM_Payment__c);
                    }
                    updatePayment.ASI_MFM_Recharge__c = paymentLine.ASI_MFM_Recharge__c;
                    update_ASI_MFM_Payments.put(paymentLine.ASI_MFM_Payment__c,  updatePayment);
                }
                */
                //Update PO Header
                /*
                ASI_MFM_PO__c updatePO = new ASI_MFM_PO__c(Id = paymentLine.ASI_MFM_PO__c);
                system.debug(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c+'TestTaxRateNew:'+paymentLine.ASI_MFM_Tax_Rate__c);
                if(paymentLine.ASI_MFM_Tax_Rate__c!=null && (paymentLine.ASI_MFM_Tax_Rate__c <> paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c)){
                    system.debug('paymentline had changed Tax Rate: '+ paymentline.Id);
                    updatePO.ASI_MFM_Tax_Rate__c = paymentLine.ASI_MFM_Tax_Rate__c;
                    update_ASI_MFM_PO.put(paymentLine.ASI_MFM_PO__c, updatePO);
                }
                */
                
                //Update PO Line
                ASI_MFM_PO_Line_Item__c updatePOLine = new ASI_MFM_PO_Line_Item__c(Id = paymentLine.ASI_MFM_PO_Line_Item__c);
                if(paymentLine.ASI_MFM_A_C_Code__c!=null && (paymentLine.ASI_MFM_A_C_Code__c <> paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c)){
                    system.debug('paymentline had changed AC Code: '+ paymentline.Id);
                    updatePOLine.ASI_MFM_A_C_Code__c = paymentLine.ASI_MFM_A_C_Code__c;
                    update_ASI_MFM_PO_Lines.put(paymentLine.ASI_MFM_PO_Line_Item__c, updatePOLine);
                }
                
                
                //Update Payment Line: FV Flag is checked, the Effective is also checked                
                if(paymentLine.ASI_MFM_Payment_Line_Item_Finance_Verify__c){
                    paymentLine.ASI_MFM_Effective__c=true;
                }else{  //Clear the Effective Flag
                    paymentLine.ASI_MFM_Effective__c=false;
                }
            }
            
            
        }    
     
        
        //Update
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        try{   
            
            if(update_ASI_MFM_Payments!=null && update_ASI_MFM_Payments.size()>0){
                system.debug('Update payment header');
                updatePaymentHeadersResult  = Database.upsert(update_ASI_MFM_Payments.values());
            }
            
            if(update_ASI_MFM_PO_Lines!=null && update_ASI_MFM_PO_Lines.size()>0){
                system.debug('Update PO lines');
                updatePOLinesResult = Database.upsert(update_ASI_MFM_PO_Lines.values());
            }
            
            if(update_ASI_MFM_PO!=null && update_ASI_MFM_PO.size()>0){
                system.debug('Update PO header');
                updatePOResult  = Database.upsert(update_ASI_MFM_PO.values());
            }
            
            if(paymentLinesToUpdate!=null && paymentLinesToUpdate.size()>0)
                updateTarget = Database.upsert(paymentLinesToUpdate); //updateList);
                Msg = count!=null && count>0? string.valueOf(count) + ' PO Line(s) verified. PO No. ' +verLines  +'</br>': ' No selected Payment line(s) is needed to be verified. ' +'</br>';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, count + ' Payment Line verified. Payment No. ' + verLines));
                SaveSuccess=true;

                if(PaymentLineMap!=null){
                    lineItem = new List<ASI_MFM_Payment_Line_Item__c>();
                    lineItem.addAll(PaymentLineMap.values());
                    LineItemJson = JSON.serialize(LineItem);
            }
        
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


    /*Method: For valdationCheckingStep*/   
    public Boolean valdationCheckingStep(Map<Id, ASI_MFM_Payment_Line_Item__c> PaymentLineMap , String SearchRecordType){
        
        Boolean isProcess = true;
        
        
        
        msg = '';    
        
        Set<Id> ACCodes = new Set<Id>();
        
        if(PaymentLineMap == null) return false;       
        
        
        Map<String, List<ASI_MFM_Payment_Line_Item__c>> validationCheckingOnInvoice = new Map<String, List<ASI_MFM_Payment_Line_Item__c>> ();
        List<ASI_MFM_Payment_Line_Item__c> relatedInvoicePaymentLines = new  List<ASI_MFM_Payment_Line_Item__c> ();



        //1st step: check required fields  : A/C Code
  
        Integer idx = 1; 
        for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){ 
            //DF: IF Supplier Number is null and FV Flag= true, can not save.
            if(paymentLine.ASI_MFM_Payment_Line_Item_Finance_Verify__c && paymentLine.ASI_MFM_Recharge__c==false && paymentLine.ASI_MFM_Payee__r.ASI_TH_CRM_Supplier__c==null && PageRecordType=='DF'){
                isProcess = false;      
                paymentLine.ASI_MFM_Payee__c.addError('DF SG Supplier Number can not be null');
                msg += 'Save Error: ('+ paymentLine.Name + '): Line'+idx+ ':'+paymentLine.ASI_MFM_Payee__r.name+' SG Supplier Number can not be null'  +'</br>';            
            }
            
            if(paymentLine.ASI_MFM_A_C_Code__c == null){
                isProcess = false;      
                paymentLine.ASI_MFM_A_C_Code__c.addError('Please input A/C Code.');
                msg += 'Save Error: ('+ paymentLine.Name + '): '+  ' Please input A/C Code.'  +'</br>';                
            }else{
                
                ACCodes.add(paymentLine.ASI_MFM_A_C_Code__c);
            }
            idx++;

        }
        
        if(!ACCodes.isEmpty()){
            
            Map<Id, ASI_MFM_A_C_Code__c> acCodesMap = new Map<Id, ASI_MFM_A_C_Code__c> ([Select id, RecordType.DeveloperName from ASI_MFM_A_C_Code__c where Id in: ACCodes ]);
            
            
            for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){ 
                
                if(paymentLine.ASI_MFM_A_C_Code__c != null && acCodesMap.containsKey(paymentLine.ASI_MFM_A_C_Code__c) && acCodesMap.get(paymentLine.ASI_MFM_A_C_Code__c).RecordType.DeveloperName<> SearchRecordType ){
                
                         isProcess = false;      
                         paymentLine.ASI_MFM_A_C_Code__c.addError('Please input suitable A/C Code.');
                         msg +='Save Error: ('+  paymentLine.Name + '): '+  ' Please input suitable A/C Code.'  +'</br>';                
                }
                
       
            }            
            
            ACCodes.clear();
        }
                

        //2nd step: check same invoice number should contain same invoice date and gl date
        for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){ 

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
               Set<Id> samePayee = new Set<Id>();
               Set<String> recharges = new Set<String>();
              // Set<Date> invoiceDueDate = new Set<Date>();
               Boolean invoiceValid = true;
               
               for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                   
                   invoiceDate.add(paymentLine.ASI_MFM_Invoice_Date__c);
                   glDate.add(paymentLine.ASI_MFM_G_L_Date__c);
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
                
                if(samePayee!=null&& samePayee.size()>1){
                    //more than one payee 
                   for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                       isProcess = false;    
                       invoiceValid = false;
                       paymentLine.ASI_MFM_Payee__c.addError('Please check Payee');
                   }                     
                }
                
                /*
                if(recharges!=null && recharges.size()>0 &&  recharges.size() <> validationCheckingOnInvoice.get(invoiceNumber).size()){
                    //rechange checkbox not same 
                   for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                       isProcess = false;    
                       invoiceValid = false;
                       paymentLine.ASI_MFM_Recharge__c.addError('Please check rechange checkbox');
                   }                      
                }
                */
                /*
                if(invoiceDueDate!=null && invoiceDueDate.size()>1){
                    //more than one invoice due date
                   for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                       isProcess = false;    
                       invoiceValid = false;
                       paymentLine.ASI_MFM_Invoice_Due_Date__c.addError('Please check Invoice Due Date');
                   }    
                }
                */
                
                if(!invoiceValid)
                msg += 'Save Error: '+  '(Invoice Number: '+ InvoiceNumber + ') Same invoice number should have same Payee, same Invoice Date and G/L Date.'+'</br>';
            }
            
        
        }
        return isProcess;
        
    }
    
    
    
    
    
    
    
    
     public class SmallDataRow {  

          public Id recordId                        { get; set;}  
          public String glDateStr                   { get; set;}
          public String invoiceDateStr              { get; set;}
          public String acCode                      { get; set;}
          public String invoiceDueDateStr           { get; set;}
          public String invoiceNumber               { get; set;}
          public Boolean FVerify                    { get; set;}
          public String APremark                    { get; set;}
          public String vat                         { get; set;}
          public boolean recharge                   { get; set;}

            
          public SmallDataRow(ASI_MFM_Payment_Line_Item__c paymentline){  
               this.glDateStr = paymentline.ASI_MFM_G_L_Date__c !=null? paymentline.ASI_MFM_G_L_Date__c.format():null;
               this.recordId =  paymentline.Id;  
               this.invoiceNumber = paymentline.ASI_MFM_Invoice_Number__c!=null?  paymentline.ASI_MFM_Invoice_Number__c :null;
               this.FVerify = paymentline.ASI_MFM_Payment_Line_Item_Finance_Verify__c;
               this.invoiceDateStr  = paymentline.ASI_MFM_Invoice_Date__c !=null? paymentline.ASI_MFM_Invoice_Date__c.format():null;
               this.APremark = paymentline.ASI_MFM_AP_Remark__c !=null ? paymentline.ASI_MFM_AP_Remark__c :null;
               this.acCode = paymentline.ASI_MFM_A_C_Code__c!=null? String.valueOf(paymentLine.ASI_MFM_A_C_Code__c): null;
               this.invoiceDateStr = paymentline.ASI_MFM_Invoice_Due_Date__c !=null? paymentline.ASI_MFM_Invoice_Due_Date__c.format():null;
               this.recharge = paymentline.ASI_MFM_Recharge__c;
               this.vat=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c!=null?  paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c :null;
          }  
     }   
   
     

    
    
}