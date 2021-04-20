public with sharing class ASI_MFM_MY_Payment_SummaryCtrl {
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}
    private String soqlSubbrand {get;set;}
    public transient Decimal TotalRemainingPO {get;set;}  //Remaining PO Amount 
    public transient Decimal TotalPayment {get;set;}
    public transient Decimal VerifiedPY {get;set;} 
    public transient Decimal UnverifiedPY {get;set;}
    
    public transient String FinVerify {get;set;}
    public transient String VoucherCreat {get;set;}
    public transient String PO_ID {get;set;}
    public transient String Payment_ID {get;set;}
    public transient String SubBrand_Code {get;set;}
    public transient String PaymentStatus {get;set;}
    public transient String InvoiceNumber {get;set;}
    public transient String SubBrand {get;set;}
    public transient String Fiscalyear {get;set;}
    public Boolean display {get;set;}
    public String NowFY {get;set;}
    Map<id,boolean> payline;
    Map<id,String> payStatus;
    
    public transient String Suppl {get;set;}  //public String Due_Dates {get;set;}  public String DueDate_Ends {get;set;}
    public ASI_MFM_PO_Line_Item__c due_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c due_toDate { get; set; }
    
    List <Report> reportList=new List<Report>();
    public transient List<ASI_MFM_Payment_Line_Item__c> TotalLineItem{get;set;}
    public transient List<ASI_MFM_Payment_Line_Item__c> lineItem{get;set;}
    public transient List<SummarySubbrand> Summaries{get;set;} 
    
    List<ASI_MFM_Payment__c> payment =new List<ASI_MFM_Payment__c>();
    List<ASI_MFM_Payment__c> paymentupdate =new List<ASI_MFM_Payment__c>();
    List<ASI_MFM_PO_Line_Item__c> poline =new List<ASI_MFM_PO_Line_Item__c>();
    List<ASI_MFM_PO_Line_Item__c> polineupdate =new List<ASI_MFM_PO_Line_Item__c>();
    
    public ASI_MFM_MY_Payment_SummaryCtrl(){
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
        
        soql='select id, name,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_AC_Remark__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Voucher_Created__c,ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment_Date__c,ASI_MFM_Invoice_Date__c, ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\' ';
        soqlSubbrand='select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Payment_Amount__c) TPA, sum(ASI_MFM_Paid_Amount_in_Base_Currency__c) TPABC from ASI_MFM_Payment_Line_Item__c where (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL) AND  ASI_MFM_Payment__r.ASI_MFM_ETL__c = false AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Draft\' AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\'  ';
         if(Fiscalyear!=null && Fiscalyear.length()>0){
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        payline=new Map<id,boolean>();
        
        this.numOfRowInTable = 50;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        PO_ID=null;
        Payment_ID=null;
        SubBrand_Code=null;
        SubBrand=null;
        Suppl=null;
        FinVerify=null;
        VoucherCreat=null; 
        PaymentStatus = null;
        InvoiceNumber = null;
        due_fromDate = new ASI_MFM_PO_Line_Item__c ();
        due_toDate = new ASI_MFM_PO_Line_Item__c ();
        runQuery();
    }
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'ASC'; } return sortDir;  }
        set;
    }
    //  Due Date  : ASI_MFM_Due_Date__c
    public String sortField {
        get  { if (sortField == null) {sortField = 'ASI_MFM_Invoice_Date__c'; } return sortField;  }
        set;
    }
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom; }
        set;
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
            for(ASI_MFM_Payment_Line_Item__c pai: lineItem){
                pai.ASI_MFM_A_C_Code__c=pai.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                payline.put(pai.id,pai.ASI_MFM_Payment_Line_Item_Finance_Verify__c);

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
        soql='select id, name,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_AC_Remark__c,ASI_MFM_G_L_Date__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Voucher_Created__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c, ASI_MFM_Invoice_Date__c,ASI_MFM_Payment_Date__c,ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_PO_Line_Item__r.name,ASI_MFM_Payment_Line_Item_Finance_Verify__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_TH_Tax_Type__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c, ASI_MFM_Withholding_Tax_Amount__c  from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\' ';
        soqlSubbrand='select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name Name,sum(ASI_MFM_Payment_Amount__c) TPA, sum(ASI_MFM_Paid_Amount_in_Base_Currency__c) TPABC from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\'  ';
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
         if (VoucherCreat!=null && VoucherCreat.length()>0){
            if(VoucherCreat=='Unchecked'){
                soqlSubbrand +=  ' and ASI_MFM_Voucher_Created__c =false ';
                soql +=  ' and ASI_MFM_Voucher_Created__c =false ';
            }
            if(VoucherCreat=='Checked'){
                soqlSubbrand +=  ' and ASI_MFM_Voucher_Created__c =true ';
                soql +=  ' and ASI_MFM_Voucher_Created__c =true ';
            }
        }
        if(Fiscalyear!=null && Fiscalyear.length()>0 && PO_ID.length()==0 && Payment_ID.length()==0){
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        if (PO_ID!=null && PO_ID.length()>0){
            soqlSubbrand+= ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
            soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
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
            soql += ' and ASI_MFM_Invoice_Number__c LIKE \''+String.escapeSingleQuotes(InvoiceNumber)+'%\'';
            soqlSubbrand += ' and ASI_MFM_Invoice_Number__c LIKE \''+String.escapeSingleQuotes(InvoiceNumber)+'%\'';
        }
        if (SubBrand_Code!=null && SubBrand_Code.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(SubBrand_Code)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(SubBrand_Code)+'%\'';
        }
        
        if (SubBrand!=null && SubBrand.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SubBrand)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SubBrand)+'%\'';
        }
        
        
        if (Suppl!=null && Suppl.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(Suppl)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(Suppl)+'%\'';
        }
        
        
        if (due_fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate = DateTime.newInstance(due_fromDate.ASI_MFM_G_L_Date__c.year(),due_fromDate.ASI_MFM_G_L_Date__c.month(),due_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_Invoice_Date__c  >= ' + fromDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_Invoice_Date__c  >= ' + fromDate + ''; 
        }
        if (due_toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate = DateTime.newInstance(due_toDate.ASI_MFM_G_L_Date__c.year(),due_toDate.ASI_MFM_G_L_Date__c.month(),due_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_Invoice_Date__c    <= ' + toDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_Invoice_Date__c    <= ' + toDate + ''; 
        }
        if(due_fromDate.ASI_MFM_G_L_Date__c==null && due_toDate.ASI_MFM_G_L_Date__c==null){
            soql += ' AND (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL)  ';
            soqlSubbrand += ' AND (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL)  ';
        }
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