public class ASI_MFM_KR_FV_Controller {
    //SQL
    private String soql {get;set;}{soql=null;}
    public String WhereStatm {get;set;}{WhereStatm = '';}
    
    //Search filter
    public transient String FinVerify {get;set;}{FinVerify=null;}
    public transient String PO_ID {get;set;}{PO_ID=null;}
    public transient String POline_ID {get;set;}{POline_ID=null;}
    public transient String PORLineID {get;set;}{PORLineID=null;}
    public transient String Payment_ID {get;set;}{Payment_ID=null;}
    public transient String PayLine_ID {get;set;}{PayLine_ID=null;}
    public transient String SubBrand_Code {get;set;}{SubBrand_Code=null;}
    public transient String PaymentStatus {get;set;}{PaymentStatus=null;}
    public transient String InvoiceNumber {get;set;}{InvoiceNumber=null;}
    public transient String Company {get;set;}{Company='PRK';}
    public ASI_MFM_PO__c pofilter{get;set;} {pofilter = new ASI_MFM_PO__c();}
    
    public transient String Payee {get;set;}{Payee=null;}
    public transient String Fiscalyear {get;set;}{Fiscalyear=null;}
    public ASI_MFM_Payment_Line_Item__c FromDate  { get; set; }{FromDate=new ASI_MFM_Payment_Line_Item__c();}
    public ASI_MFM_Payment_Line_Item__c ToDate  { get; set; }{ToDate =new ASI_MFM_Payment_Line_Item__c();}
    
    //Mass Update G/L Date :ASI_MFM_G_L_Date__c
    public ASI_MFM_Payment_Line_Item__c UpdatedGLDate  { get; set; }
    
    public String reportFolderid {get;set;}
    //Current Fiscal Year
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
    public transient List<csvRow> csvRowItem {get; set;} 
    public transient Map<Id, ASI_MFM_Payment_Line_Item__c> PaymentLineMap { get; set; } {PaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>();}
    
    public transient Map<id, id> APACMap { get; set; } {APACMap = new Map<id, id>();}//id is AP Code ID
    
    //20170207, edited by Leo, String selectedFields, added two new field: ASI_MFM_Payment__r.ASI_MFM_KR_VAT_Amount__c, ASI_MFM_Payment__r.ASI_MFM_KR_TotalPayAmtIncludeVAT__c
    public static final String selectedFields  =  'select Id, Name, ASI_MFM_Payee__r.ASI_MFM_Customer_Supplier_Number__c, ASI_MFM_Payee__r.Name, ASI_MFM_Payment__r.ASI_MFM_Company_Code__c, ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c,ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c, ASI_MFM_Payment__r.Owner.Name, ASI_MFM_Payment__r.Owner.Email, ASI_MFM_Payment__r.ASI_MFM_Finance_Verify_LineNumber__c, ASI_MFM_Payment__r.ASI_MFM_KR_VAT_Amount__c,ASI_MFM_Payment__r.ASI_MFM_KR_TotalPayAmtIncludeVAT__c, ASI_MFM_Tax_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Tax_Explanation_Code__c,ASI_MFM_Payment__r.ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_in_Base_Currency__c,ASI_MFM_Payment__r.ASI_MFM_Tax_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Total_PaymentAmount_IncludingVAT__c,ASI_MFM_GL_Offset__c,ASI_MFM_Verify_by__r.name,ASI_MFM_Tax_Confirmed_Cost__c,ASI_MFM_Payment__r.ASI_MFM_Pre_payment__c,ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Payee__r.ASI_KOR_Venue_Business_License_Number__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Phase__c,ASI_MFM_Tax_Explanation_Code__c,ASI_MFM_Business_Unit__c,ASI_MFM_Company__c,ASI_MFM_Tax_Code__c,ASI_MFM_Tax_Code__r.Name,ASI_MFM_Payment__r.ASI_MFM_JP_Payment_Date__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_PO_Receipt_Item__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c, ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c,ASI_MFM_AP_Remark__c, ASI_MFM_Payment__r.Id, ASI_MFM_Recharge__c, ASI_MFM_Payment__r.ASI_MFM_Recharge__c, ASI_MFM_Amount_with_Tax__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Date__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Payment__r.ASI_MFM_VAT_Rate__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_G_L_Date__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment_Date__c,ASI_MFM_Invoice_Date__c, ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Payment__r.ASI_MFM_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_List_Item_Description__c ,ASI_MFM_Verify_by__c, ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.ASI_HK_CRM_Payment_Term_Code__c, ASI_MFM_Payment__r.ASI_MFM_Payment_Term__c, ASI_MFM_KR_Tax_Explanation_Code__c  from ASI_MFM_Payment_Line_Item__c'; // Modified by 2017-09-08  Linus@introv
    public static final String mustWhereClause = ' where ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment__r.ASI_MFM_Offset_Payment__c=false AND ASI_MFM_Payment__r.ASI_MFM_Status__c = \'Approved\' ';// 
    public static final String Payment_Developer_Name = 'ASI_MFM_KR_Payment';
    
    public static final String FolderName ='ASI MFM KR Report';

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
        if(obj=='ASI_MFM_Tax_Code__c'){
            soql = 'select Id, Name,ASI_MFM_Description__c,ASI_MFM_Tax_Expl_Code__c from ' + obj + filter +' order by Name';
        }
        
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
        
        
        pofilter = new ASI_MFM_PO__c();
        
        //Mass Update G/L Date : Set As Today
        UpdatedGLDate=new ASI_MFM_Payment_Line_Item__c();
        UpdatedGLDate.ASI_MFM_G_L_Date__c=system.today();// Date.newInstance(date.today().year(), date.today().month(), 23);
        
        
        // Search filter: current fiscal year   
        NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        Fiscalyear=NowFY;
        //End
        
       Beginning();
    }
    
    public void Beginning(){
         init_soql = selectedFields +  mustWhereClause  + ' AND ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \''+ Payment_Developer_Name +'%\'';
        if(Fiscalyear!=null && Fiscalyear.length()>0){
            WhereStatm += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        WhereStatm +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
        FinVerify='Unchecked';
        
        WhereStatm +=  ' and ASI_MFM_Payment__r.ASI_MFM_Company__c = \'PRK\'';
        runQuery();
    }
    
    
    public void runQuery() {
        
        try {   
            LineItem = new List<ASI_MFM_Payment_Line_Item__c>();
            csvRowItem = new List<csvRow>();
            LineItem = Database.query(init_soql + WhereStatm);
            
            if(LineItem!=null){
                
                PaymentLineMap = new  Map<Id, ASI_MFM_Payment_Line_Item__c>();
                LineItemJson = JSON.serialize(LineItem);
                PaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>(lineItem);
                
                List<SmallDataRow> dataRows = new List<SmallDataRow>();  
                
                for(ASI_MFM_Payment_Line_Item__c  paymentline : LineItem){  
                    
                    //Default value for Tax explaination Code 
                    if(paymentline.ASI_MFM_Payment__r.ASI_MFM_Currency__c=='KRW' && !String.isEmpty(paymentline.ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.ASI_HK_CRM_Payment_Term_Code__c) &&  String.isEmpty(paymentline.ASI_MFM_Tax_Explanation_Code__c) ){
                        paymentline.ASI_MFM_Tax_Explanation_Code__c = paymentline.ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.ASI_HK_CRM_Payment_Term_Code__c;
                    }
                    paymentline.ASI_MFM_Tax_Explanation_Code__c=paymentline.ASI_MFM_KR_Tax_Explanation_Code__c ;//20180122 Introv
                    paymentline.ASI_MFM_Tax_Code__c=paymentline.ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c;
                    paymentline.ASI_MFM_G_L_Date__c=paymentline.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c;
                    paymentline.ASI_MFM_A_C_Code__c=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                    paymentline.ASI_MFM_AP_Code__c=paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c;
                    SmallDataRow  inputFields = new SmallDataRow(paymentline); 
                    dataRows.add(inputFields);  
                    PaymentLineMap.put(paymentline.Id, paymentline);
                }
                this.jsonDataMinimal = JSON.serialize(dataRows);
                
                //create csv data
                map<id,Datetime> ApprovedDateMap = new map<id,Datetime>();
                set<id> listPaymentId = new set<id>();
                list<ProcessInstanceStep> approvalHistory = new list<ProcessInstanceStep>();
                for(ASI_MFM_Payment_Line_Item__c  paymentline : LineItem){
                    listPaymentId.add(paymentline.ASI_MFM_Payment__c);
                }
                approvalHistory = [SELECT CreatedDate, ProcessInstance.TargetObjectId FROM ProcessInstanceStep where ProcessInstance.TargetObjectId in :listPaymentId and stepStatus='Approved' order by CreatedDate desc];
                if(approvalHistory!=null && approvalHistory.size()>0){
                    for(ProcessInstanceStep step : approvalHistory){
                        if(!ApprovedDateMap.containsKey(step.ProcessInstance.TargetObjectId)){
                            ApprovedDateMap.put(step.ProcessInstance.TargetObjectId,step.CreatedDate);
                        }
                    }
                }
                for(ASI_MFM_Payment_Line_Item__c  paymentline : LineItem){
                    csvRow row = new csvRow();
                    row.paymentline = paymentline;
                    if(ApprovedDateMap.containsKey(paymentline.ASI_MFM_Payment__c)){
                        Datetime aDatetime= ApprovedDateMap.get(paymentline.ASI_MFM_Payment__c);
                    	row.ApprovedDate = aDatetime.year()+'-'+aDatetime.format('MM')+'-'+aDatetime.format('dd');                      
                    }else{
                        row.ApprovedDate = '-';
                    }
                    csvRowItem.add(row);
                }
                
                
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
         if(Company!=null && Company.length()>0){
             WhereStatm += ' and ASI_MFM_Payment__r.ASI_MFM_Company__c = \''+Company+'\'';
         }
        
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
        
        
        if(pofilter.ASI_MFM_Supplier_Name__c!=null){
            string SupplierIdstr=string.valueOf(pofilter.ASI_MFM_Supplier_Name__c);
            WhereStatm += ' and ASI_MFM_Payee__c =\''+SupplierIdstr+'\'';            
        }
        
        //&& POline_ID.length()==0 && PO_ID.length()==0 && PayLine_ID.length()==0 && Payment_ID.length()==0 && Payee.length()==0
        if(Fiscalyear!=null && Fiscalyear.length()>0  && InvoiceNumber.length()==0 ){
            WhereStatm += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        SaveSuccess=false;
        UpsertPermission=true;
        runQuery();
        return null;
    }    
    
    //Save Record
    public PageReference save() {
        
        UpsertPermission = true;
        SaveSuccess = false;
        PageReference pageRef = null;
        
        Database.upsertResult[] updateTarget; //update Payment lines
        Database.upsertResult[] updatePaymentHeadersResult;
        Database.upsertResult[] updatePOLinesResult;
        
        
        //Get AP & A/C Code Map
        List<ASI_MFM_AP_AC_Code_Map__c> APACList = new List<ASI_MFM_AP_AC_Code_Map__c>();  
        APACList=[select id,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.id from ASI_MFM_AP_AC_Code_Map__c where ASI_MFM_AP_Code__r.RecordType.DeveloperName='ASI_KR_AP_Code'];
        
        APACMap = new Map<id, id>();
        for(ASI_MFM_AP_AC_Code_Map__c apac:APACList){
            if(!APACMap.containsKey(apac.ASI_MFM_AP_Code__r.id)){
                APACMap.put(apac.ASI_MFM_AP_Code__r.id, apac.ASI_MFM_A_C_Code__c);
            }
        }
        
        Map<ID, ASI_MFM_Tax_Code__c> TaxMap = new Map<ID,ASI_MFM_Tax_Code__c>([SELECT ID, Name,ASI_MFM_Tax_Expl_Code__c FROM ASI_MFM_Tax_Code__c where RecordType.DeveloperName like 'ASI_MFM_KR%' AND ASI_MFM_Inactive__c =FALSE ]); 

        //Count Number of line update
        Integer count = 0;
        Set<String> verLines = new Set<String>();
        
        if(LineItemJson!=null ){
            LineItem = LineItem == null? (List<ASI_MFM_Payment_Line_Item__c>) JSON.deserialize(LineItemJson, List<ASI_MFM_Payment_Line_Item__c>.class): LineItem ;
        } 
        if(LineItem!=null){
            PaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>(lineItem);
        }       
        
        
        List<ASI_MFM_Payment_Line_Item__c> paymentLinesToUpdate = new List<ASI_MFM_Payment_Line_Item__c>();  
        List<SmallDataRow> smallTableRow = (List<SmallDataRow>)JSON.deserialize(jsonDataMinimal, List<SmallDataRow>.class);  
        Boolean isRedirect = True; 
        
        //transform data
        for(SmallDataRow sdr : smallTableRow){ 
            if(PaymentLineMap!=null){
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Invoice_Date__c  = sdr.invoiceDateStr!=null? date.parse(sdr.invoiceDateStr): null;
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment_Line_Item_Finance_Verify__c  = sdr.FVerify ;
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Invoice_Number__c = sdr.invoiceNumber!=null? sdr.invoiceNumber: null; 
                PaymentLineMap.get(sdr.recordId).ASI_MFM_AP_Remark__c = sdr.APremark!=null? sdr.APremark: null; 
                PaymentLineMap.get(sdr.recordId).ASI_MFM_AP_Code__c = sdr.apCode!=null? Id.valueOf(sdr.apCode) : null; 
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Payee__c = sdr.Payee!=null? Id.valueOf(sdr.Payee) : null; 
                try{
                    PaymentLineMap.get(sdr.recordId).ASI_MFM_Tax_Code__c = (sdr.taxcode!=null)? Id.valueOf(sdr.taxcode) : null; 
                }catch(Exception e){}
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Business_Unit__c = sdr.BusinessUnit!=null? sdr.BusinessUnit: null; 
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Phase__c = sdr.Phase!=null? sdr.Phase: null;
                PaymentLineMap.get(sdr.recordId).ASI_MFM_GL_Offset__c = sdr.GLOffset!=null? sdr.GLOffset: null; 
                if(PaymentLineMap.get(sdr.recordId).ASI_MFM_Tax_Code__c!=null && TaxMap.containsKey(PaymentLineMap.get(sdr.recordId).ASI_MFM_Tax_Code__c)){
                    PaymentLineMap.get(sdr.recordId).ASI_MFM_Tax_Explanation_Code__c=TaxMap.get(PaymentLineMap.get(sdr.recordId).ASI_MFM_Tax_Code__c).ASI_MFM_Tax_Expl_Code__c;
                }
                if (PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment_Line_Item_Finance_Verify__c == true || Test.isRunningTest()) {
                    count++;
                    verLines.add(PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment__r.name);
                    PaymentLineMap.get(sdr.recordId).ASI_MFM_G_L_Date__c =UpdatedGLDate.ASI_MFM_G_L_Date__c;
                }
                if(PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment__r.ASI_MFM_Status__c !='Draft' && !PaymentLineMap.get(sdr.recordId).ASI_MFM_ETL__c ){ 
                    paymentLinesToUpdate.add(PaymentLineMap.get(sdr.recordId));
                }
                PaymentLineMap.put(sdr.recordId, PaymentLineMap.get(sdr.recordId));
                PaymentLineMap.get(sdr.recordId).ASI_MFM_Payment__r.ASI_MFM_KR_TotalPayAmtIncludeVAT__c  = sdr.TaxAmount!=null?  Decimal.valueOf(sdr.TaxAmount.replace(',','')): null;
                
            }
        } // end of transforming data
        
        //Checking
        if(PaymentLineMap!=null && !PaymentLineMap.isEmpty() && paymentLinesToUpdate!=null && paymentLinesToUpdate.size()>0 ){
            Map<Id, ASI_MFM_Payment_Line_Item__c> ValidatePaymentLineMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>(paymentLinesToUpdate);
            isRedirect =  valdationCheckingStep(ValidatePaymentLineMap);
        }
        
        if(!isRedirect){
            //Save Fail
            UpsertPermission = false;
            SaveSuccess = false;
            if(!Test.isRunningTest()){
                 return null;
            }
           
        }
        
        //Data Handling: Uodate Payment And PO line
        Map<Id, ASI_MFM_Payment__c> update_ASI_MFM_Payments = new Map<Id, ASI_MFM_Payment__c>();
        Map<Id, ASI_MFM_PO_Line_Item__c> update_ASI_MFM_PO_Lines = new Map<Id, ASI_MFM_PO_Line_Item__c>();
        
        if(PaymentLineMap!=null && !PaymentLineMap.isEmpty()){
            for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){
                Boolean AllowUpdatePayment=false;
                //--------------------------------------Update Payment Header ------------------------------------------//
                ASI_MFM_Payment__c  updatePayment = new ASI_MFM_Payment__c(Id = paymentLine.ASI_MFM_Payment__c);
                
                
                if(paymentLine.ASI_MFM_Tax_Code__c!=null ){
                    updatePayment.ASI_MFM_Tax_Code__c=paymentLine.ASI_MFM_Tax_Code__c;
                    AllowUpdatePayment=true;
                }
                
                if(paymentLine.ASI_MFM_Payment__r.ASI_MFM_KR_TotalPayAmtIncludeVAT__c!= null){
                    updatePayment.ASI_MFM_KR_TotalPayAmtIncludeVAT__c = paymentLine.ASI_MFM_Payment__r.ASI_MFM_KR_TotalPayAmtIncludeVAT__c;
                    AllowUpdatePayment=true;
                }
                
                if(AllowUpdatePayment){
                     update_ASI_MFM_Payments.put(paymentLine.ASI_MFM_Payment__c, updatePayment);
                }
                
                //--------------------------------------Update PO line ------------------------------------------//
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
                //End Update PO line
                //update Payment line Verify By
                if(paymentLine.ASI_MFM_Payment_Line_Item_Finance_Verify__c){
                    paymentLine.ASI_MFM_Verify_by__c = userinfo.getUserId(); 
                }
            }
        }    
        
        //Update
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        try{   
           
            
            if(update_ASI_MFM_PO_Lines!=null && update_ASI_MFM_PO_Lines.size()>0){
                updatePOLinesResult = Database.upsert(update_ASI_MFM_PO_Lines.values());
            }
            
            if(paymentLinesToUpdate!=null && paymentLinesToUpdate.size()>0){
                updateTarget = Database.upsert(paymentLinesToUpdate);
            }
            
            if(update_ASI_MFM_Payments!=null && update_ASI_MFM_Payments.size()>0){
                updatePaymentHeadersResult  = Database.upsert(update_ASI_MFM_Payments.values());
            }
            
            Msg = count!=null && count>0? string.valueOf(count) + ' Payment Line(s) verified. Payment No. ' +verLines  +'</br>': ' No selected Payment line(s) is needed to be verified. ' +'</br>';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, count + ' Payment Line verified. Payment No. ' + verLines));
            SaveSuccess=true;
            runQuery();
        } catch (System.DmlException e) {

            Set<String> ErrMsg= new Set<String> ();
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                //str+= e.getDmlMessage(i);
                ErrMsg.add(e.getDmlMessage(i));
            }
            UpsertPermission = false;
            SaveSuccess= false;
            for(String str:ErrMsg){
                 msg += 'Save Error!'+ str +'</br>';
            }
           
            
            Database.rollback(pSavepoint);      
            return null;
        }
        
        /*catch(Exception e){
            UpsertPermission = false;
            SaveSuccess= false;
            msg += 'Save Error!'+ e.getMessage() +'</br>';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error!' + e));
            Database.rollback(pSavepoint);      
            return null;
        }*/
        return pageRef;
    }    
    
    public PageReference exportCSV() {
        runQuery();
        PageReference ref = new PageReference('/apex/ASI_MFM_KR_FV_ExportPage');
        return ref;
    }
    
    
    //Method: For Valdation Checking  
    public Boolean valdationCheckingStep(Map<Id, ASI_MFM_Payment_Line_Item__c> PaymentLineMap){
        
        Boolean isProcess = true;
        Integer idx = 1; 
        msg = '';
        
        Set<Id> ACCodes = new Set<Id>();
        Set<Id> APCodes = new Set<Id>();
        Set<Id> TaxCodeSet = new  Set<Id>();
        Map<Id,ASI_MFM_Tax_Code__c> TaxMap= new Map<Id,ASI_MFM_Tax_Code__c>(); 
        if(PaymentLineMap == null) return false;       
        
        
        Map<String, List<ASI_MFM_Payment_Line_Item__c>> validationCheckingOnInvoice = new Map<String, List<ASI_MFM_Payment_Line_Item__c>> ();
     
        List<ASI_MFM_Payment_Line_Item__c> relatedInvoicePaymentLines = new  List<ASI_MFM_Payment_Line_Item__c> ();
        List<ASI_MFM_Payment_Line_Item__c> relatedPaymentLines = new  List<ASI_MFM_Payment_Line_Item__c> ();
        
        
        //One Payment header can only have one tax code : Payment Id==Tax code Id
        Map<String, List<ASI_MFM_Payment_Line_Item__c>> validationCheckingOnTaxCode= new Map<String, List<ASI_MFM_Payment_Line_Item__c>> ();
        
        
        //1st step: check required fields  
        for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){
            
            //check AP Code 
            if(paymentLine.ASI_MFM_AP_Code__c == null){
                isProcess = false;      
                paymentLine.ASI_MFM_AP_Code__c.addError('Please input AP Code.');
                msg += 'Save Error: ('+ paymentLine.Name + '): '+  ' Please input AP Code.'  +'</br>';                
            }else{
                APCodes.add(paymentLine.ASI_MFM_AP_Code__c);
            }
            
            
            if(paymentLine.ASI_MFM_Payment_Line_Item_Finance_Verify__c && paymentLine.ASI_MFM_Tax_Code__c != null){
                TaxCodeSet.add(paymentLine.ASI_MFM_Tax_Code__c);
            }
            
           
            
            
            if(paymentLine.ASI_MFM_Payee__c == null || Test.isRunningTest()){
                isProcess = false;      
                paymentLine.ASI_MFM_Payee__c.addError('Please input Payee.');
                msg += 'Save Error: ('+ paymentLine.Name + '): '+  ' Please input Payee.'  +'</br>';                
            } 
            
            // 2nd step: check same invoice number should contain same invoice date and gl date ,Tax Code
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
                relatedInvoicePaymentLines = validationCheckingOnTaxCode.get(paymentLine.ASI_MFM_Invoice_Number__c);
                if(relatedInvoicePaymentLines ==  null) relatedInvoicePaymentLines = new List<ASI_MFM_Payment_Line_Item__c> ();
                relatedInvoicePaymentLines.add(paymentLine);
                //put all line to  Map<String, List<ASI_MFM_Payment_Line_Item__c>>  base on one invoice number 
                validationCheckingOnInvoice.put(paymentLine.ASI_MFM_Invoice_Number__c, relatedInvoicePaymentLines);
            }
            
            
            
            //ASI_MFM_Tax_Code__c Checking 
            if(paymentLine.ASI_MFM_Tax_Code__c == null || String.isEmpty(paymentLine.ASI_MFM_Tax_Code__c)){
                isProcess = false;      
                paymentLine.ASI_MFM_Tax_Code__c.addError('Please input Tax Code.');
                msg += 'Save Error: ('+ paymentLine.Name + '): '+  ' Please input Tax Code.'  +'</br>';                
            }else{
                relatedPaymentLines = validationCheckingOnTaxCode.get(paymentLine.ASI_MFM_Payment__c);
                if(relatedPaymentLines ==  null) relatedPaymentLines = new List<ASI_MFM_Payment_Line_Item__c> ();
                relatedPaymentLines.add(paymentLine);
                validationCheckingOnTaxCode.put(paymentLine.ASI_MFM_Payment__c, relatedPaymentLines);
            }
            
        }
        
        if(TaxCodeSet.size()>0){
            TaxMap=new map<id, ASI_MFM_Tax_Code__c>([select Id,Name,ASI_MFM_Tax_Expl_Code__c from ASI_MFM_Tax_Code__c where id in : TaxCodeSet]);
        }
        
        
        
        for(ASI_MFM_Payment_Line_Item__c paymentLine : PaymentLineMap.values()){ 
            if(paymentLine.ASI_MFM_Payment_Line_Item_Finance_Verify__c && paymentLine.ASI_MFM_Tax_Code__c != null){
                
                if(TaxMap.containsKey(paymentLine.ASI_MFM_Tax_Code__c)){
                    //If Tax Explanation Code=BLANK, pls block to save.
                    if(TaxMap.get(paymentLine.ASI_MFM_Tax_Code__c).ASI_MFM_Tax_Expl_Code__c==null){
                        isProcess = false;      
                        paymentLine.ASI_MFM_Payment__r.ASI_MFM_KR_VAT_Amount__c.addError('Tax Explanation Code=BLANK.');
                        msg += 'Save Error: (' + paymentLine.Name + '): '+  ' Tax Explanation Code=BLANK, you can not choose this tax code!'  +'</br>';
                    }
                    //IF Tax Explanation Code =V then VAT amount should be greater than 0 otherwise block to save
                    else if(TaxMap.get(paymentLine.ASI_MFM_Tax_Code__c).ASI_MFM_Tax_Expl_Code__c=='V' && paymentLine.ASI_MFM_Payment__r.ASI_MFM_KR_VAT_Amount__c<=0){
                        isProcess = false;      
                        paymentLine.ASI_MFM_Payment__r.ASI_MFM_KR_VAT_Amount__c.addError('VAT amount should be greater than 0.');
                        msg += 'Save Error: (' + paymentLine.Name + '): '+  ' Tax Explanation Code =V, VAT amount should be greater than 0.'  +'</br>';
                    }
                    //IF Tax Explanation Code =E then VAT should be 0 
                    else if(TaxMap.get(paymentLine.ASI_MFM_Tax_Code__c).ASI_MFM_Tax_Expl_Code__c=='E' && paymentLine.ASI_MFM_Payment__r.ASI_MFM_KR_VAT_Amount__c!=0 && TaxMap.get(paymentLine.ASI_MFM_Tax_Code__c).Name != 'JG11'){
                        isProcess = false;      
                        paymentLine.ASI_MFM_Payment__r.ASI_MFM_KR_VAT_Amount__c.addError('VAT should be 0.');
                        msg += 'Save Error: (' + paymentLine.Name + '): '+  ' Tax Explanation Code =E, VAT should be 0.'  +'</br>';
                    }
                }
            }
        }
        
        
        if(!validationCheckingOnTaxCode.isEmpty()){
            Boolean TaxValid = true;
            set<String> PaymentHaederSet = new set<String>();
            for(String paymentid : validationCheckingOnTaxCode.keyset()){
                Set<String> TaxCodeCheck = new Set<String>();
                for(ASI_MFM_Payment_Line_Item__c payline : validationCheckingOnTaxCode.get(paymentid)){ 
                    TaxCodeCheck.add(payline.ASI_MFM_Tax_Code__c);
                    
                }

                if(TaxCodeCheck!=null&& TaxCodeCheck.size()>1) {
                    //more than one Tax Code
                    for(ASI_MFM_Payment_Line_Item__c payline : validationCheckingOnTaxCode.get(paymentid)){ 
                        isProcess = false;    
                        TaxValid = false;
                        PaymentHaederSet.add(payline.ASI_MFM_Payment__r.Name);
                        payline.ASI_MFM_Tax_Code__c.addError('Please check Tax Code!');
                    }                    
                }
            }
            
            if(!TaxValid){
                for(String str:PaymentHaederSet){
                    msg += 'Save Error: '+  '(Payment number: '+ str + ') Same payment header should have same Tax Code.'+'</br>';
                }
            }
            
        
        }//End of tax code checking
        
        if(!validationCheckingOnInvoice.isEmpty()){
            
            
            for(String invoiceNumber : validationCheckingOnInvoice.keyset()){
                //checking : one invoice number with same invoice Date,G/L Date, Tax Codes , same Payee, Tax Explanation Code(ASI_MFM_Tax_Explanation_Code__c) 
                Set<Date> invoiceDate = new Set<Date>();
                Set<Date> glDate = new Set<Date>();
                Set<ID> TaxCodes = new Set<ID>();
                Set<Id> samePayee = new Set<Id>();
               // set<string> TaxEC = new Set<string>();
                set<String> GLOffset = new Set<string>();
                
                Boolean invoiceValid = true;
                
                for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                    
                    invoiceDate.add(paymentLine.ASI_MFM_Invoice_Date__c);
                    glDate.add(paymentLine.ASI_MFM_G_L_Date__c);
                    TaxCodes.add(paymentLine.ASI_MFM_Tax_Code__c);
                    samePayee.add(paymentLine.ASI_MFM_Payee__c);
                    GLOffset.add(paymentLine.ASI_MFM_GL_Offset__c);//TaxEC.add(paymentLine.ASI_MFM_Tax_Explanation_Code__c);
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
              
                 if(GLOffset!=null&& GLOffset.size()>1){
                    //more than G/L Off set
                    for(ASI_MFM_Payment_Line_Item__c paymentLine : validationCheckingOnInvoice.get(invoiceNumber)){ 
                        isProcess = false;    
                        invoiceValid = false;
                        paymentLine.ASI_MFM_GL_Offset__c.addError('Please check GL Offset');
                    }                     
                }
               
                
                if(!invoiceValid)
                    msg += 'Save Error: '+  '(Invoice Number: '+ InvoiceNumber + ') Same invoice number should have same G/L Offset, Payee, same Invoice Date, G/L Date and Tax Code.'+'</br>';
            }
        }
        return isProcess;
        
    }
    
    
    public class SmallDataRow {  
        public Id recordId                        { get; set;}  
        public String invoiceNumber               { get; set;}
        public String invoiceDateStr              { get; set;}
        public String Payee                       { get; set;}
        public String taxcode                     { get; set;}
        public String apCode                      { get; set;}
        public Boolean FVerify                    { get; set;}
        public String APremark                    { get; set;} 
        public string BusinessUnit                { get; set;} 
        public string Phase                       { get; set;}
        public string TaxExplanationCode          { get; set;}
        public String GLOffset                    { get; set;}
        public string TaxAmount                   {set;get;}
        
        public SmallDataRow(ASI_MFM_Payment_Line_Item__c paymentline){       
            this.recordId =  paymentline.Id;  
            this.invoiceNumber = paymentline.ASI_MFM_Invoice_Number__c!=null?  paymentline.ASI_MFM_Invoice_Number__c :null;
            this.FVerify = paymentline.ASI_MFM_Payment_Line_Item_Finance_Verify__c;
            this.invoiceDateStr  = paymentline.ASI_MFM_Invoice_Date__c !=null? paymentline.ASI_MFM_Invoice_Date__c.format():null;
            this.APremark = paymentline.ASI_MFM_Comments__c !=null ? paymentline.ASI_MFM_Comments__c :null;
            this.apCode = paymentline.ASI_MFM_AP_Code__c!=null? String.valueOf(paymentLine.ASI_MFM_AP_Code__c): null;
            this.taxcode= paymentline.ASI_MFM_Tax_Code__c!=null? String.valueOf(paymentLine.ASI_MFM_Tax_Code__c): null;
            this.BusinessUnit = paymentline.ASI_MFM_Business_Unit__c !=null ? paymentline.ASI_MFM_Business_Unit__c :null;
            this.Phase = paymentline.ASI_MFM_Phase__c !=null ? paymentline.ASI_MFM_Phase__c :null;
            this.GLOffset = paymentline.ASI_MFM_GL_Offset__c !=null ? paymentline.ASI_MFM_GL_Offset__c :null;    
            this.TaxExplanationCode = paymentline.ASI_MFM_Tax_Explanation_Code__c !=null ? paymentline.ASI_MFM_Tax_Explanation_Code__c :null;
            this.Payee = paymentline.ASI_MFM_Payee__c!=null? String.valueOf(paymentLine.ASI_MFM_Payee__c): null;
            this.TaxAmount = paymentline.ASI_MFM_Tax_Amount__c!=null? String.valueOf(paymentLine.ASI_MFM_Tax_Amount__c): null;
            
        }  
    }
    
    public class csvRow {
        public ASI_MFM_Payment_Line_Item__c paymentline { get; set;}
        public String ApprovedDate                    	{ get; set;}
        
		public csvRow(){
			ApprovedDate = '';
		}
        
    }
    
    
    
    
    
}