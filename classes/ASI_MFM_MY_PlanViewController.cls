public with sharing class ASI_MFM_MY_PlanViewController {
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}
    private String soqlSubbrand {get;set;}
    private String soqlSubbrandplan {get;set;}
    public transient Decimal ALLPlanAmount {get;set;}
    public transient Decimal ALLTotalPOAmount{get;set;} 
    public transient Decimal ALLPlanBalance {get;set;}
    public transient Decimal TotalSubBrand {get;set;}
    
   /* public String Plan_Number;
    public String Plan_Name;
    public String Fiscal_Year;
    public String Status;
    public String Plan_Line_Num;
    public String AC_code;
    public String  BU_Code;
    public String SubBrand_Code;
    public String Sub_Brand;
    public String Customer_Name;*/
    
    //New
    
    public transient String Plan_ID {get;set;}
    public transient String PlanName {get;set;}
    public transient String Fiscalyear {get;set;}
    public transient String Statu {get;set;}
    public transient String PlanLine_ID {get;set;}
    public transient String ACcode {get;set;}
    public transient String  BUCode {get;set;}
    public transient String SubBrandCode {get;set;}
    public transient String SubBrand {get;set;}
    public transient String CustomerName {get;set;}
    
    public String NowFY {get;set;}
    
    public Boolean display {get;set;}

    
    public ASI_MFM_MY_PlanViewController(){
        init();
    }
    
    public void init() {
        
        //Get Today Fiscal Year
        NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  // If today's month is Jan-Jun 
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{ //else If today's month is July to DEC
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        // Get Today Fiscal Year Finished
        Fiscalyear=NowFY;  
        soqlSubbrandplan='select id, name,Owner.name,ASI_MFM_Plan_Name__c,ASI_MFM_Plan_Description__c,ASI_MFM_End_Date__c,ASI_MFM_Start_Date__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Status__c,ASI_MFM_Plan_Raised_Date__c,ASI_MFM_Plan_Amount__c,ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan_Balance__c  from ASI_MFM_Plan__c where ASI_MFM_Plan_Amount__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        soql='select id,name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c,ASI_MFM_Plan__r.name,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Plan_id_sys__c,ASI_MFM_Plan_Name_sys__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_Customer_Name__c,ASI_MFM_Total_Cost__c,ASI_MFM_Number_of_Outlets__c,ASI_MFM_Expected_Volume__c,ASI_MFM_Size__c,ASI_MFM_BU_Code__c from ASI_MFM_Plan_Line_Item__c where  ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Total_Cost__c) TotalPLI from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
         if (Fiscalyear!=null && Fiscalyear.length()>0){
             soqlSubbrand+= ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
             soql += ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
             soqlSubbrandplan += ' and ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        this.numOfRowInTable = 50;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        
        Plan_ID=null;
        PlanName =null;
        
        Statu=null;
        PlanLine_ID=null;
        ACcode =null;
        BUCode =null;
        SubBrandCode =null;
        SubBrand =null;
        CustomerName =null;
        runQuery();
    }
    
    public PageReference refresh() {
        init();
        return null;
    }
    
    public class SummarySubbrand{
        /*For Sub-Brand use*/
        public Decimal TotalPLI { get; private set; }// plan line amount
        public String Name { get; private set; }// Sub-Brand Name
        public SummarySubbrand(AggregateResult ar) {
            TotalPLI = (Decimal) ar.get('TotalPLI');
            Name = (String) ar.get('Name');
        }
    }
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'DESC'; } return sortDir;  }
        set;
    }
    public String sortField {
        get  { if (sortField == null) {sortField = 'ASI_MFM_Plan__r.name'; } return sortField;  }
        set;
    }
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom; }
        set;
    }
    public transient List<ASI_MFM_Plan_Line_Item__c> TotalLineItem{get;set;}
    public transient List<ASI_MFM_Plan_Line_Item__c> lineItem{get;set;}
    public transient List<SummarySubbrand> Summaries{get;set;}
    public transient List<ASI_MFM_Plan__c> Totalplan{get;set;}
     //sort
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        runQuery();
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
    
    public void runQuery() {
        ALLPlanAmount=0;
        ALLTotalPOAmount=0;
        ALLPlanBalance=0;
        TotalSubBrand=0;
        try {
            /* Search Sub- brand as SubTotal*/
            String SubbrandGroup='group by ASI_MFM_Sub_brand_Code__r.name';
            String SubbrandSear;
            SubbrandSear=soqlSubbrand+SubbrandGroup;   //soqlSubbrand +='group by ASI_MFM_Sub_brand_Code__r.name';
            AggregateResult[] groupedResults=Database.query(SubbrandSear); //Run query
            Summaries = new List<SummarySubbrand>();
            /*Add to class*/
            for (AggregateResult ar : groupedResults) {
                Summaries.add(new SummarySubbrand(ar));
                //TotalSubBrand=TotalSubBrand+ar.TotalPLI;
            } //
            
            for(SummarySubbrand sumsub:Summaries){
                TotalSubBrand=TotalSubBrand+sumsub.TotalPLI;
            }
            groupedResults.clear();
            //Total Plan Amount
            Totalplan = Database.query(soqlSubbrandplan);
            for(ASI_MFM_Plan__c Planterms : Totalplan){
                  if(Planterms.ASI_MFM_Plan_Amount__c!=null)
                      ALLPlanAmount=ALLPlanAmount+Planterms.ASI_MFM_Plan_Amount__c;
                  if(Planterms.ASI_MFM_Total_PO_Amount__c!=null)
                      ALLTotalPOAmount=ALLTotalPOAmount+Planterms.ASI_MFM_Total_PO_Amount__c;
                  if(Planterms.ASI_MFM_Plan_Balance__c!=null)
                      ALLPlanBalance=ALLPlanBalance+Planterms.ASI_MFM_Plan_Balance__c;
              }
            
            //Plan line Amount
            TotalLineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
              this.totalNumOfRecord = TotalLineItem.size();
              lineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
            if(lineItem.size()>0){
                //if lineItem stores more than one data,show the summary table
                display=true; 
            }else{
                //hide the summary table
                display=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Records Found, Please Check your search input' ));
            }
            Totalplan.clear();
            TotalLineItem.clear();
          } catch (Exception e) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' + soql));
            }
        }
    
    public PageReference runSearch() {
        soqlSubbrandplan='select id, name,Owner.name,ASI_MFM_Plan_Name__c,ASI_MFM_Plan_Description__c,ASI_MFM_End_Date__c,ASI_MFM_Start_Date__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Status__c,ASI_MFM_Plan_Raised_Date__c,ASI_MFM_Plan_Amount__c,ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan_Balance__c  from ASI_MFM_Plan__c where ASI_MFM_Plan_Amount__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        soql='select id,name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Customer_Name__r.name,ASI_MFM_BU_Code__r.name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c,ASI_MFM_Plan__r.name,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Plan_id_sys__c,ASI_MFM_Plan_Name_sys__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_Customer_Name__c,ASI_MFM_Total_Cost__c,ASI_MFM_Number_of_Outlets__c,ASI_MFM_Expected_Volume__c,ASI_MFM_Size__c,ASI_MFM_BU_Code__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Total_Cost__c) TotalPLI from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        if(Plan_ID!=null && Plan_ID.length()>0){
            soql += ' and ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_ID)+'%\'';
            soqlSubbrand+= ' and ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_ID)+'%\'';
        }
        if (PlanLine_ID!=null && PlanLine_ID.length()>0){ 
            soqlSubbrand+= ' and name LIKE \''+String.escapeSingleQuotes(PlanLine_ID)+'%\'';
            soql += ' and name LIKE \''+String.escapeSingleQuotes(PlanLine_ID)+'%\'';
        }
        if (PlanName!=null && PlanName.length()>0){
            soqlSubbrand+= ' and ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+String.escapeSingleQuotes(PlanName)+'%\'';
            soql += ' and ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+String.escapeSingleQuotes(PlanName)+'%\'';
        }
        if (Fiscalyear!=null && Fiscalyear.length()>0 && PlanLine_ID.length()==0 && Plan_ID.length()==0){
            soqlSubbrand+= ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soql += ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soqlSubbrandplan += ' and ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        if (ACcode!=null && ACcode.length()>0){
            soqlSubbrand+= ' and ASI_MFM_A_C_Code__r.name LIKE \'%'+String.escapeSingleQuotes(ACcode)+'%\'';
            soql += ' and ASI_MFM_A_C_Code__r.name LIKE \'%'+String.escapeSingleQuotes(ACcode)+'%\'';
        }
        if (BUCode!=null && BUCode.length()>0){
            soqlSubbrand += ' and ASI_MFM_BU_Code__r.name LIKE \'%'+String.escapeSingleQuotes(BUCode)+'%\'';
            soql += ' and ASI_MFM_BU_Code__r.name LIKE \'%'+String.escapeSingleQuotes(BUCode)+'%\'';
        }
        if (SubBrandCode!=null && SubBrandCode.length()>0){
            soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+String.escapeSingleQuotes(SubBrandCode)+'%\'';
            soql += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+String.escapeSingleQuotes(SubBrandCode)+'%\'';
        }
        if (SubBrand!=null && SubBrand.length()>0){
            soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SubBrand)+'%\'';
            soql += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SubBrand)+'%\'';
        }
        if (CustomerName!=null && CustomerName.length()>0){
            soqlSubbrand+= ' and ASI_MFM_Customer_Name__r.name LIKE \'%'+String.escapeSingleQuotes(CustomerName)+'%\'';
            soql += ' and ASI_MFM_Customer_Name__r.name LIKE \'%'+String.escapeSingleQuotes(CustomerName)+'%\'';
        }
        if (Statu!=null && Statu.length()>0){
            soqlSubbrand += ' and ASI_MFM_Plan__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(Statu)+'%\''; 
            soql += ' and ASI_MFM_Plan__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(Statu)+'%\''; 
        }
        /*
        
        
        Plan_Number = Apexpages.currentPage().getParameters().get('Plan_Number');
        Plan_Line_Num= Apexpages.currentPage().getParameters().get('Plan_Line_Num');
        Plan_Name = Apexpages.currentPage().getParameters().get('Plan_Name');
        Fiscal_Year = Apexpages.currentPage().getParameters().get('Fiscal_Year');
        AC_code = Apexpages.currentPage().getParameters().get('AC_code');
        BU_Code= Apexpages.currentPage().getParameters().get('BU_Code');
        SubBrand_Code= Apexpages.currentPage().getParameters().get('SubBrand_Code');
        Sub_Brand= Apexpages.currentPage().getParameters().get('Sub_Brand');
        Customer_Name= Apexpages.currentPage().getParameters().get('Customer_Name');
        Status = Apexpages.currentPage().getParameters().get('Status');
        
      
        if (!Plan_Number.equals('')){
            soql += ' and ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_Number)+'%\'';
            soqlSubbrand+= ' and ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_Number)+'%\'';
        }
        if (!Plan_Line_Num.equals('')){
            soqlSubbrand+= ' and name LIKE \''+String.escapeSingleQuotes(Plan_Line_Num)+'%\'';
            soql += ' and name LIKE \''+String.escapeSingleQuotes(Plan_Line_Num)+'%\'';
        }
        if (!Plan_Name.equals('')){
            soqlSubbrand+= ' and ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \''+String.escapeSingleQuotes(Plan_Name)+'%\'';
            soql += ' and ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \''+String.escapeSingleQuotes(Plan_Name)+'%\'';
        }
        if (!Fiscal_Year.equals('')){
            soqlSubbrand+= ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Year)+'%\'';
            soql += ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Year)+'%\'';
        }
        if (!AC_code.equals('')){
            soqlSubbrand+= ' and ASI_MFM_A_C_Code__r.name LIKE \''+String.escapeSingleQuotes(AC_code)+'%\'';
            soql += ' and ASI_MFM_A_C_Code__r.name LIKE \''+String.escapeSingleQuotes(AC_code)+'%\'';
        }
        if (!BU_Code.equals('')){
            soqlSubbrand += ' and ASI_MFM_BU_Code__r.name LIKE \''+String.escapeSingleQuotes(BU_Code)+'%\'';
            soql += ' and ASI_MFM_BU_Code__r.name LIKE \''+String.escapeSingleQuotes(BU_Code)+'%\'';
        }
        if (!SubBrand_Code.equals('')){
            soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+String.escapeSingleQuotes(SubBrand_Code)+'%\'';
            soql += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+String.escapeSingleQuotes(SubBrand_Code)+'%\'';
        }
        if (!Sub_Brand.equals('')){
            soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \''+String.escapeSingleQuotes(Sub_Brand)+'%\'';
            soql += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \''+String.escapeSingleQuotes(Sub_Brand)+'%\'';
        }
        if (!Customer_Name.equals('')){
            soqlSubbrand+= ' and ASI_MFM_Customer_Name__r.name LIKE \''+String.escapeSingleQuotes(Customer_Name)+'%\'';
            soql += ' and ASI_MFM_Customer_Name__r.name LIKE \''+String.escapeSingleQuotes(Customer_Name)+'%\'';
        }
        if (!Status.equals('')){
            soqlSubbrand += ' and ASI_MFM_Plan__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(Status)+'%\''; 
            soql += ' and ASI_MFM_Plan__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(Status)+'%\''; 
        }
        */
        this.LimitFrom = 0;
        this.currentPageNum = 1;
        runQuery();
        return null;
    }
    
    
    
    /*
    public PageReference runSearch() {
        Plan_Number = Apexpages.currentPage().getParameters().get('Plan_Number');
        Plan_Name = Apexpages.currentPage().getParameters().get('Plan_Name');
        Fiscal_Year = Apexpages.currentPage().getParameters().get('Fiscal_Year');
        Status = Apexpages.currentPage().getParameters().get('Status');
        StartDates = Apexpages.currentPage().getParameters().get('StartDates');
        EndDates = Apexpages.currentPage().getParameters().get('EndDates');                             
        String[] str;
        Datetime searchDate;
        
        
        soql='select id, name,Owner.name,ASI_MFM_Plan_Name__c,ASI_MFM_Plan_Description__c,ASI_MFM_End_Date__c,ASI_MFM_Start_Date__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Status__c,ASI_MFM_Plan_Raised_Date__c,ASI_MFM_Plan_Amount__c,ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan_Balance__c  from ASI_MFM_Plan__c where ASI_MFM_Plan_Amount__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        if (!Plan_Number.equals(''))
            soql += ' and name LIKE \''+String.escapeSingleQuotes(Plan_Number)+'%\'';
        if (!Plan_Name.equals(''))
            soql += ' and ASI_MFM_Plan_Name__c LIKE \''+String.escapeSingleQuotes(Plan_Name)+'%\'';
        if (!Fiscal_Year.equals(''))
            soql += ' and ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Year)+'%\'';
        if (!Status.equals(''))
            soql += ' and ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(Status)+'%\''; 
        
        if (!StartDates.equals('')) {
            str = StartDates.split('-');
            searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
            soql += ' and ASI_MFM_Start_Date__c >= ' +searchDate.format('yyyy-MM-dd');
        }
        
        if (!EndDates.equals('')) {
            str = EndDates.split('-');
            searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
            soql += ' and ASI_MFM_End_Date__c <= ' +searchDate.format('yyyy-MM-dd');
        }
       
        runQuery();
        return null;
    }
 */

}