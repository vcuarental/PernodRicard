public with sharing class ASI_MFM_MY_FV_Controller {
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}
    private String soqlSubbrand {get;set;}
    public Decimal TotalRemainingPO {get;set;}  //Remaining PO Amount 
    public Decimal TotalPayment {get;set;}
    public Decimal VerifiedPY {get;set;} 
    public Decimal UnverifiedPY {get;set;}
    
    public transient String FinVerify {get;set;}
    
    public transient String PO_ID {get;set;}
    public transient String Payment_ID {get;set;}
    public transient String SubBrand_Code {get;set;}
    public transient String PaymentStatus {get;set;}
    public transient String InvoiceNumber {get;set;}
    public transient String SubBrand {get;set;}
    public transient String Fiscalyear {get;set;}
    public Boolean display {get;set;}
    public String rid {get;set;}
    public String pid {get;set;}
    public String eid {get;set;}
    Map<id,boolean> payline;
    Map<id,String> payStatus;
    public String Suppliers_Num{get;set;}
    public String Suppl {get;set;}  //public String Due_Dates {get;set;}  public String DueDate_Ends {get;set;}
    public String NowFY {get;set;}
    public ASI_MFM_PO_Line_Item__c due_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c due_toDate { get; set; }
    
    List <Report> reportList=new List<Report>();
    public transient List<ASI_MFM_Payment_Line_Item__c> TotalLineItem{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> lineItem{get;set;}
    public List<SummarySubbrand> Summaries{get;set;} 
    
    List<ASI_MFM_Payment__c> payment =new List<ASI_MFM_Payment__c>();
    List<ASI_MFM_Payment__c> paymentupdate =new List<ASI_MFM_Payment__c>();
    List<ASI_MFM_PO_Line_Item__c> poline =new List<ASI_MFM_PO_Line_Item__c>();
    List<ASI_MFM_PO_Line_Item__c> polineupdate =new List<ASI_MFM_PO_Line_Item__c>();
    
    public ASI_MFM_MY_FV_Controller(){
        init();
    }
    public class SummarySubbrand{
        /*For Sub-Brand use*/
        public Decimal TotalTPA { get; private set; }// total payment amount 
        public Decimal TotalTPABC { get; private set; }// total payment amount in base currency
        public String Name { get; private set; }// Sub-Brand Name
        public SummarySubbrand(AggregateResult ar) {
            TotalTPA = (Decimal) ar.get('TPA');
            TotalTPABC = (Decimal) ar.get('TPABC');
            Name = (String) ar.get('Name');
        }
    }
    
    public void init() {
        NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        Fiscalyear=NowFY;
        
        //ASI_MFM_ETL__c ==null AND   remove  (ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c >= TODAY OR ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c = NULL) AND 
        soql='select id, name,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_G_L_Date__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment_Date__c,ASI_MFM_Invoice_Date__c, ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment__r.ASI_MFM_Status__c = \'Final\' AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\' ';
        soqlSubbrand='select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Payment_Amount__c) TPA, sum(ASI_MFM_Paid_Amount_in_Base_Currency__c) TPABC from ASI_MFM_Payment_Line_Item__c where (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL) AND ASI_MFM_Payment__r.ASI_MFM_Status__c =\'Final\'  AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\'  ';
        if(Fiscalyear!=null && Fiscalyear.length()>0){
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        soqlSubbrand +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
                soql +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
        payline=new Map<id,boolean>();
        
        this.numOfRowInTable = 50;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        PO_ID=null;
        Payment_ID=null;
        SubBrand_Code=null;
        SubBrand=null;
        Suppl=null;
        Suppliers_Num=null;
        FinVerify='Unchecked';
        PaymentStatus = 'Final';
        InvoiceNumber = null;
         //Due_Dates=null;
        //DueDate_Ends=null;
        due_fromDate = new ASI_MFM_PO_Line_Item__c ();
        due_toDate = new ASI_MFM_PO_Line_Item__c ();
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_MY_Invalid_Payment_Line_Report'];
        if (reportList.size()>0){
            rid= (String)reportList.get(0).get('Id');
        }
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_MY_Finance_Verify_Report'];
        if (reportList.size()>0){
            pid= (String)reportList.get(0).get('Id');
        }
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_MY_ETL_Report'];
        if (reportList.size()>0){
            eid= (String)reportList.get(0).get('Id');
        }
        runQuery();
    }
  // public PageReference refresh() {
  //      init();
  //      return null;
 //   }
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'ASC'; } return sortDir;  }
        set;
    }
    //  Due Date  : ASI_MFM_Due_Date__c
    public String sortField {
        get  { if (sortField == null) {sortField = 'ASI_MFM_Payment__r.ASI_MFM_Status__c'; } return sortField;  }
        set;
    }
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom; }
        set;
    }
    
    
    
    // save FVerify 
    public void save(){
        Map<id,boolean> PaymentVerifyMap = new Map<id,boolean>();
        
        //-----------------------------------Update PO line -----------------------------------
        set<id> po_set = new set<id>();
        for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
            po_set.add(pli.ASI_MFM_PO_Line_Item__c); // Get PO Line Id
            if(!PaymentVerifyMap.containsKey(pli.ASI_MFM_Payment__c)){
                PaymentVerifyMap.put(pli.ASI_MFM_Payment__c, pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c);
            }
        }
        poline=[select id,name,ASI_MFM_Finance_Verify_Date__c,ASI_MFM_A_C_Code__c from ASI_MFM_PO_Line_Item__c where id in: po_set];
        
        for(ASI_MFM_PO_Line_Item__c poli:poline){
            Boolean changestat = true;
            for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
                if(pli.ASI_MFM_PO_Line_Item__c==poli.id &&( (pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c==true && pli.ASI_MFM_Finance_Verify_Save_Date__c!=poli.ASI_MFM_Finance_Verify_Date__c) || pli.ASI_MFM_A_C_Code__c!=poli.ASI_MFM_A_C_Code__c) && changestat == true){
                    if(pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c==true && pli.ASI_MFM_Finance_Verify_Save_Date__c!=poli.ASI_MFM_Finance_Verify_Date__c){
                        poli.ASI_MFM_Finance_Verify_Date__c=pli.ASI_MFM_Finance_Verify_Save_Date__c;
                    }
                    if(pli.ASI_MFM_A_C_Code__c!=poli.ASI_MFM_A_C_Code__c){ // If change happen in AC CODE
                        poli.ASI_MFM_A_C_Code__c=pli.ASI_MFM_A_C_Code__c;
                    }
                    polineupdate.add(poli);
                    changestat=false;    
                }
            }
        }
        if(polineupdate.size()>0){
            update polineupdate;
            polineupdate.clear();
        }
        //-----------------------------------Update PO Line End-----------------------------------
        
        
        payStatus=new Map<id,string>();
        /*     //Update Payment
        set<id> pay_set = new set<id>();
        for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
            pay_set.add(pli.ASI_MFM_Payment__c);
        }
        
        payment=[select id,ASI_MFM_Status__c,name,ASI_MFM_Invoice_Number__c from ASI_MFM_Payment__c where id in:pay_set];
        for(ASI_MFM_Payment__c pa:payment){
            Boolean changehappen = true;  // Every Payment Only can change one times
            Boolean changeInvoice = true;
            Boolean Updatehappen = false;
            for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
                if(pli.ASI_MFM_Status_Invalid__c==true){
                    pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c=False;
                    pli.ASI_MFM_Effective__c=false;
                }
                if(pa.id==pli.ASI_MFM_Payment__c &&  pli.ASI_MFM_Status_Invalid__c==true && changehappen == true && pa.ASI_MFM_Status__c!='Invalid'){ //If  pa.ASI_MFM_Status__c='Invalid',don't need to change
                    pa.ASI_MFM_Status__c='Invalid'; //  change status to Invalid  Final
                    Updatehappen=true;
                    payStatus.put(pa.id, pa.ASI_MFM_Status__c);
                    changehappen = false; 
                    pli.ASI_MFM_Status_Invalid__c=False;
                }
                   Update Header Invoice Number
                if(pa.id==pli.ASI_MFM_Payment__c && pa.ASI_MFM_Invoice_Number__c!=pli.ASI_MFM_Invoice_Number__c && changeInvoice == true){
                    pa.ASI_MFM_Invoice_Number__c=pli.ASI_MFM_Invoice_Number__c;
                    changeInvoice = false;
                    Updatehappen=true;
                }  
            }
            if(Updatehappen){
                    paymentupdate.add(pa);  
                }
        }

        for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
           if(pli.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Invalid'){
                pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c=False;//Datetime temp;   //pli.ASI_MFM_Finance_Verify_Save_Date__c=temp ;
               pli.ASI_MFM_Effective__c=false;
            }
            pli.ASI_MFM_Status_Invalid__c=False;
       }
        */
        // Message :Payment Line Item
        Integer count = 0;
        Set<String> verLines = new Set<String>();
        Date selectedDate =  Date.today(); 
        List<ASI_MFM_Payment_Line_Item__c> updateList = new List<ASI_MFM_Payment_Line_Item__c>();
        Map<id, map<string, date>> InvoiceDate_Map = new Map<id, map<string, date>>();
        Map<id, map<string, date>> GLDate_Map = new Map<id, map<string, date>>();
        
        boolean Save = true;
        boolean isnull = false;
        boolean PartialVerify = false;
        for (ASI_MFM_Payment_Line_Item__c ver : lineItem)
        {
            //    validate <blank> is NOT allowed for invoice date, GL date
            if(ver.ASI_MFM_G_L_Date__c==null){
                ver.ASI_MFM_G_L_Date__c.addError('G/L Date can not be null.');
                isnull=true;
                 Save = false;  
            }
            
            if(ver.ASI_MFM_Invoice_Date__c==null){
                ver.ASI_MFM_Invoice_Date__c.addError('Invoice Date can not be null.');
                isnull=true;
                 Save = false;
            }
            
            //One Invoice Number should have one G/L Date
            if(!GLDate_Map.containsKey(ver.ASI_MFM_Payee__c)){
                map<string, date> newmap= new map<string, date>();
                newmap.put(ver.ASI_MFM_Invoice_Number__c,ver.ASI_MFM_G_L_Date__c);
                GLDate_Map.put(ver.ASI_MFM_Payee__c, newmap);
            }else {
                if (GLDate_Map.get(ver.ASI_MFM_Payee__c).containsKey(ver.ASI_MFM_Invoice_Number__c)){
                    if(GLDate_Map.get(ver.ASI_MFM_Payee__c).get(ver.ASI_MFM_Invoice_Number__c) != ver.ASI_MFM_G_L_Date__c){
                        Save = false;                
                        ver.ASI_MFM_G_L_Date__c.addError(ver.ASI_MFM_Invoice_Number__c+' Please Check G/L Date.');
                    }
                }
            }  
            
            //One Invoice Number should have One Invoice Date
            if(!InvoiceDate_Map.containsKey(ver.ASI_MFM_Payee__c)){
                map<string, date> newmap= new map<string, date>();
                newmap.put(ver.ASI_MFM_Invoice_Number__c,ver.ASI_MFM_Invoice_Date__c);
                InvoiceDate_Map.put(ver.ASI_MFM_Payee__c, newmap);
            }else {
                if (InvoiceDate_Map.get(ver.ASI_MFM_Payee__c).containsKey(ver.ASI_MFM_Invoice_Number__c)){
                    if(InvoiceDate_Map.get(ver.ASI_MFM_Payee__c).get(ver.ASI_MFM_Invoice_Number__c) != ver.ASI_MFM_Invoice_Date__c){
                        Save = false;                      
                        ver.ASI_MFM_Invoice_Date__c.addError(ver.ASI_MFM_Invoice_Number__c+' Please Check Invoice Date.');
                    }
                }
            }      
            
            /*
            if(ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true && payStatus.containsKey(ver.ASI_MFM_Payment__c)){
                if(payStatus.get(ver.ASI_MFM_Payment__c)=='Invalid'){
                    ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c = false;
                    ver.ASI_MFM_Effective__c=false;
                }
            }*/
            //Update Payment Line Related Fields
            if (ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true) {
               
                if(PaymentVerifyMap.containsKey(ver.ASI_MFM_Payment__c)){
                     // there be error prompt if user perform finance verify with partial records 
                    if(PaymentVerifyMap.get(ver.ASI_MFM_Payment__c)!=ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c){
                        
                        PartialVerify=true;
                        Save = false;
                    }
                }
                if(Save){
                    count++;
                    verLines.add(ver.ASI_MFM_Payment__r.name);
                    ver.ASI_MFM_ETL_Failed__c=false;
                    ver.ASI_MFM_Effective__c=true;
                    if(ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c!=payline.get(ver.id)){ // If Finance_Verify is checked, save the Time
                        ver.ASI_MFM_Finance_Verify_Save_Date__c=datetime.now();
                    }
                }
               
                
                
            }else{
                if(PaymentVerifyMap.containsKey(ver.ASI_MFM_Payment__c)){
                     // there be error prompt if user perform finance verify with partial records 
                    if(PaymentVerifyMap.get(ver.ASI_MFM_Payment__c)!=ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c){
                        
                        ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c.addError('Please Check');
                        PartialVerify=true;
                        Save = false;
                    }
                }
                ver.ASI_MFM_Finance_Verify_Save_Date__c=null; // If Finance_Verify is unchecked, clear the Time
                ver.ASI_MFM_Effective__c=false;
            }
            
            
            if(ver.ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Final' || ver.ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Invalid'){
                updateList.add(ver);
            }
        }//-----------------------For Loop End-----------------------
        if(Save){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, count + ' Payment Line verified. Payment No. ' + verLines));
            update updateList;       //update lineItem;  //update Payment Line Item
            updateList.clear();
            //update paymentupdate;   // Update payment
            //paymentupdate.clear();
            runQuery();
        }else{
            if(PartialVerify){
                apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'Can Not Partially Verify Payment Line in One Payment .'));  
            }
            else if(isnull){
                 apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'Please Note: G/L Date and Invoice Date can not be null.'));  
            }else{
                apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'Please Note: One Invoice Number can only have one G/L Date and One Invoice Date.'));    
            }
            
        }
        
        
    }
    
    
    
    
    
    
    //sort
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        runQuery();
    }
    
    public void runQuery() {
        try {
            
            String SubbrandGroup='group by ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name';
            String SubbrandSear;
            SubbrandSear=soqlSubbrand+SubbrandGroup;  
            AggregateResult[] groupedResults=Database.query(SubbrandSear); //Run query
            Summaries = new List<SummarySubbrand>();
            /*Add to class*/
            for (AggregateResult ar : groupedResults) {
                Summaries.add(new SummarySubbrand(ar));
            }
            groupedResults.clear();
            
            UnverifiedPY=0;VerifiedPY=0;
            TotalRemainingPO=0;
            TotalPayment=0;
            TotalLineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
            
            for(ASI_MFM_Payment_Line_Item__c PAYLI : TotalLineItem){
                if(PAYLI.ASI_MFM_PO_Line_Remaining_Amount__c!=null){
                    if(PAYLI.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c!=null){
                        TotalRemainingPO=TotalRemainingPO+PAYLI.ASI_MFM_PO_Line_Remaining_Amount__c*PAYLI.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c;
                    }else{
                        TotalRemainingPO=TotalRemainingPO+PAYLI.ASI_MFM_PO_Line_Remaining_Amount__c;
                    }
                    
                }
                if(PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c !=null){
                    TotalPayment=PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c +TotalPayment;
                    if(PAYLI.ASI_MFM_Payment_Line_Item_Finance_Verify__c==true){
                        VerifiedPY=VerifiedPY+PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                    }else{
                        UnverifiedPY=UnverifiedPY+PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                    }
                }
            }
            
            this.totalNumOfRecord = TotalLineItem.size();
            lineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
         	 Date selectedDate =  Date.today(); 
            for(ASI_MFM_Payment_Line_Item__c pai: lineItem){
                pai.ASI_MFM_A_C_Code__c=pai.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                //pai.ASI_MFM_Invoice_Number__c=pai.ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c;
                payline.put(pai.id,pai.ASI_MFM_Payment_Line_Item_Finance_Verify__c);
                if(pai.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Final' && pai.ASI_MFM_Payment_Line_Item_Finance_Verify__c== false && pai.ASI_MFM_G_L_Date__c ==null){
                    pai.ASI_MFM_G_L_Date__c=selectedDate;
                }
            }

            if(lineItem.size()>0){
                display=true;  //if lineItem stores more than one data,show the summary table
            }else{
                display=false; //hide the summary table
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Records Found, Please Check your search input' ));
            }
            TotalLineItem.clear();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' + e));//System.debug('Fail123');
        }
    }
    
    //search function
    public PageReference runSearch() {
        soql='select id, name,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_G_L_Date__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c, ASI_MFM_Invoice_Date__c,ASI_MFM_Payment_Date__c,ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_PO_Line_Item__r.name,ASI_MFM_Payment_Line_Item_Finance_Verify__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_TH_Tax_Type__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c, ASI_MFM_Withholding_Tax_Amount__c  from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Draft\' AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Submitted\' AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\' ';
        soqlSubbrand='select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name Name,sum(ASI_MFM_Payment_Amount__c) TPA, sum(ASI_MFM_Paid_Amount_in_Base_Currency__c) TPABC from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_ETL__c = false AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Draft\' AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\'  ';
        String[] str;
        Datetime searchDate;
        if (FinVerify!=null && FinVerify.length()>0){
            if(FinVerify=='Unchecked'){
                soqlSubbrand +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
                soql +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
            }
            if(FinVerify=='Checked'){
                soqlSubbrand +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =true ';
                soql +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =true ';
            }
        }
        
        if (PO_ID!=null && PO_ID.length()>0){
            soqlSubbrand+= ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
            soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
        }
         if(Fiscalyear!=null && Fiscalyear.length()>0 && PO_ID.length()==0 && Payment_ID.length()==0 && InvoiceNumber.length()==0 && Suppliers_Num.length()==0 && Suppl.length()==0 && SubBrand.length()==0 && SubBrand_Code.length()==0){
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        
        if (Payment_ID!=null && Payment_ID.length()>0){
            soql += ' and ASI_MFM_Payment__r.name LIKE \''+String.escapeSingleQuotes(Payment_ID)+'%\'';
            soqlSubbrand += ' and ASI_MFM_Payment__r.name LIKE \''+String.escapeSingleQuotes(Payment_ID)+'%\'';
        }
        if (PaymentStatus!=null && PaymentStatus.length()>0){
            soql += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(PaymentStatus)+'%\'';
            soqlSubbrand += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(PaymentStatus)+'%\'';
        }
        if (InvoiceNumber!=null && InvoiceNumber.length()>0){
            soql += ' and ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c LIKE \''+String.escapeSingleQuotes(InvoiceNumber)+'%\'';
            soqlSubbrand += ' and ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c LIKE \''+String.escapeSingleQuotes(InvoiceNumber)+'%\'';
        }
        if (SubBrand_Code!=null && SubBrand_Code.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(SubBrand_Code)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(SubBrand_Code)+'%\'';
        }
        
        if (SubBrand!=null && SubBrand.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SubBrand)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SubBrand)+'%\'';
        }
        
        if (Suppliers_Num!=null && Suppliers_Num.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c LIKE \'%'+String.escapeSingleQuotes(Suppliers_Num)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c LIKE \'%'+String.escapeSingleQuotes(Suppliers_Num)+'%\'';
        }
        
        if (Suppl!=null && Suppl.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(Suppl)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(Suppl)+'%\'';
        }//ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c  
        
        
        if (due_fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate = DateTime.newInstance(due_fromDate.ASI_MFM_G_L_Date__c.year(),due_fromDate.ASI_MFM_G_L_Date__c.month(),due_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c  >= ' + fromDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c  >= ' + fromDate + ''; 
        }
        if (due_toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate = DateTime.newInstance(due_toDate.ASI_MFM_G_L_Date__c.year(),due_toDate.ASI_MFM_G_L_Date__c.month(),due_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c    <= ' + toDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c    <= ' + toDate + ''; 
        }
      /*  if(due_fromDate.ASI_MFM_G_L_Date__c==null && due_toDate.ASI_MFM_G_L_Date__c==null){
            soql += ' AND (ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c >= TODAY OR ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c = NULL)  ';
            soqlSubbrand += ' AND (ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c >= TODAY OR ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c = NULL)  ';
        }*/
        this.LimitFrom = 0;
        this.currentPageNum = 1;
        runQuery();
        
        return null;
    }
    
    // change page function
    public void firstPage() {
        this.currentPageNum=1;
        implChangePage(1);
        this.LimitFrom = 0;
        runQuery();
    }
    public void lastPage() {
        this.currentPageNum=this.maxNumOfPage();
        implChangePage(this.maxNumOfPage());
        this.LimitFrom = this.maxPageNum*this.numOfRowInTable-this.numOfRowInTable;
        runQuery();
    }
    public void prevPage() {
        if(this.currentPageNum>0){
            this.currentPageNum = this.currentPageNum -1;
            implChangePage(this.currentPageNum);
            this.LimitFrom=this.LimitFrom-this.numOfRowInTable;
            runQuery();
        }
    }
    public void nextPage() {
        if(this.currentPageNum<this.maxPageNum){
            this.currentPageNum=this.currentPageNum + 1;
            implChangePage(this.currentPageNum);
            //this.numOfRowInTable=this.numOfRowInTable+2;
            this.LimitFrom=this.LimitFrom+this.numOfRowInTable;
            runQuery();
            //implChangePage(this.currentPageNum + 1); 
        }
        
    }
    
    public void implChangePage(Integer pageNum) {
        Integer maxPNum = this.maxNumOfPage();
        if (pageNum <= 0) this.currentPageNum = 1;
        else if (pageNum > maxPNum) this.currentPageNum = maxPNum;
    }
    
    private Integer maxNumOfPage() {
        if (this.totalNumOfRecord == 0 || this.numOfRowInTable == 0)
            return 1;
        return ((this.totalNumOfRecord - 1) / this.numOfRowInTable) + 1;
    }
    
    public Integer maxPageNum { get { return maxNumOfPage(); } private set; }
    public Integer currentPageNum { get; protected set { currentPageNum = value; newPageNum = String.valueOf(value); } }
    public String newPageNum { get; set; }
    
}