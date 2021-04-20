public with sharing class ASI_MFM_MY_POLineViewController {
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}
    private String soqlSubbrand {get;set;}
    private String soqlpo {get;set;}
    //Old 
    /*public String Plan_Number;
    public String Plan_Name;
    public String PO_Number;
    public String PO_Line_Number;
    public String Sub_Brand_Code;
    public String Sub_Brand;
    public String Suppliers_Num;
    public String Suppliers;
    public String GLdates;
    public String Status;*/
    //New
    public transient String Plan_ID {get;set;}
    public transient String PO_Line_ID {get;set;}
    public transient String PO_ID {get;set;}
    public transient String PlanNames {get;set;}
    
    public transient String SubBrand_Code {get;set;}
    public transient String SubBrand {get;set;}
    
    public transient String Supplier_Num {get;set;}
    public transient String suppl {get;set;}
    public transient String Fiscalyear {get;set;}
    public transient String state {get;set;}
    public ASI_MFM_PO_Line_Item__c gl_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c gl_toDate { get; set; }    //public String GL_D {get;set;}
    public String NowFY {get;set;}
    
    public transient Decimal TotalOriginalPO {get;set;} //Original PO Amount
    public transient Decimal TotalRemainingPO {get;set;}  //Remaining PO Amount
    public Boolean display {get;set;}
    
    public transient Decimal ALLPOAmount {get;set;}
    public transient Decimal ALLPaymentAmount{get;set;} 
    public transient Decimal ALLPORemain {get;set;}
    
    public ASI_MFM_MY_POLineViewController(){
        init();
    }
    public PageReference refresh() {
        init();
        return null;
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
        
        //limit: G/L day <Today
        //       Complete = false
        //       Status= Final
        soql='select id, name,RecordType.DeveloperName,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Invoice_Number__c,ASI_MFM_PO__r.ASI_MFM_Status__c, ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Base_Currency_Remaining_Balance__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO__r.ASI_MFM_PO_Name__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Supplier_Number__c, ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Base_Currency_Amount__c) TotalOPO, sum(ASI_MFM_Base_Currency_Remaining_Balance__c) TotalRPO from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        soqlpo='select id,name,Owner.name,ASI_MFM_Supplier_Name__r.name ,ASI_MFM_Plan__r.name,ASI_MFM_BU_Code__r.name,ASI_MFM_PO_Name__c,ASI_MFM_BU_Code__c,ASI_MFM_Plan__c,ASI_MFM_Sys_Plan_Amount__c,ASI_MFM_Plan_Balance__c,ASI_MFM_Sys_Plan_Name__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Number__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_PO_Raised_Date__c,ASI_MFM_Remarks__c,ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c,ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_PO_Balance__c,ASI_MFM_Payment_Request_Amount__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Base_Currency_Amount__c    from ASI_MFM_PO__c where ASI_MFM_PO_Amount__c>=0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        
        
        if(Fiscalyear!=null && Fiscalyear.length()>0){
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soqlpo += ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        
        this.numOfRowInTable = 30;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
       // Plan_Number = null;
        Plan_ID =null;
        PO_Line_ID=null;
        PO_ID=null;
        PlanNames=null;
        SubBrand_Code=null;
        SubBrand=null;
        Supplier_Num=null;
        suppl=null;
        state=null;
        gl_fromDate = new ASI_MFM_PO_Line_Item__c ();
        gl_toDate = new ASI_MFM_PO_Line_Item__c ();
        runQuery();
        
    }
    public class SummarySubbrand{
        /*For Sub-Brand use*/
        public Decimal TotalOPO { get; private set; }// Original PO 
        public Decimal TotalRPO { get; private set; }// Remaining PO
        public String Name { get; private set; }// Sub-Brand Name
        public SummarySubbrand(AggregateResult ar) {
            TotalOPO = (Decimal) ar.get('TotalOPO');
            TotalRPO = (Decimal) ar.get('TotalRPO');
            Name = (String) ar.get('Name');
        }
    }
    
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'DESC'; } return sortDir;  }
        set;
    }
    public String sortField {
        get  { if (sortField == null) {sortField = 'ASI_MFM_G_L_Date__c'; } return sortField;  }
        set;
    }
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom; }
        set;
    }
    public transient List<ASI_MFM_PO_Line_Item__c> TotalLineItem{get;set;}
    public transient List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    public transient List<SummarySubbrand> Summaries{get;set;}
    public transient List<ASI_MFM_PO__c> TotalpoItem{get;set;}
    //public SummarySubbrand[] Summaries { get; set; }
    //sort
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        runQuery();
    }
    
    public void runQuery() {
        TotalOriginalPO=0;
        TotalRemainingPO=0;
        ALLPOAmount=0;
        ALLPaymentAmount=0;
        ALLPORemain=0;
           system.debug('TestSQL'+soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
        try {
            // Search Sub- brand as SubTotal
            String SubbrandGroup=' group by ASI_MFM_Sub_brand_Code__r.name';
            String SubbrandSear;
            SubbrandSear=soqlSubbrand+SubbrandGroup;   //soqlSubbrand +='group by ASI_MFM_Sub_brand_Code__r.name';
            AggregateResult[] groupedResults=Database.query(SubbrandSear); //Run query
            Summaries = new List<SummarySubbrand>();
            
            // Add to class   System.debug(Status+'Summaries123'+Summaries);
            for (AggregateResult ar : groupedResults) {
                Summaries.add(new SummarySubbrand(ar));
            }
            groupedResults.clear();
            
            /*Caculate amount*/
            TotalLineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
            for(ASI_MFM_PO_Line_Item__c POli : TotalLineItem){
                //Calculate PO Original Amount
                if(POli.ASI_MFM_Amount__c!=null){
                    if(POli.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c!=null){
                        TotalOriginalPO=TotalOriginalPO+POli.ASI_MFM_Amount__c*POli.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c;
                    }else{
                        TotalOriginalPO=TotalOriginalPO+POli.ASI_MFM_Amount__c;
                    }
                    
                }
                //Calculate PO remaining
                if(POli.ASI_MFM_Remaining_Balance__c!=null){
                    if(POli.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c!=null){
                        TotalRemainingPO=TotalRemainingPO+POli.ASI_MFM_Remaining_Balance__c*POli.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c;
                    }else{
                        TotalRemainingPO=TotalRemainingPO+POli.ASI_MFM_Remaining_Balance__c;
                    }
                    
                }
            }
            
            /*Show in Main Page*/
            this.totalNumOfRecord = TotalLineItem.size();
            
            TotalpoItem = Database.query(soqlpo);
            for(ASI_MFM_PO__c POli : TotalpoItem){
                if(POli.ASI_MFM_Base_Currency_Amount__c!=null){
                    ALLPOAmount=ALLPOAmount+POli.ASI_MFM_Base_Currency_Amount__c;
                }
                if(POli.ASI_MFM_Payment_Request_Amount__c!=null){
                    ALLPaymentAmount=ALLPaymentAmount+POli.ASI_MFM_Payment_Request_Amount__c;
                }
                if(POli.ASI_MFM_PO_Balance__c!=null){
                    ALLPORemain=ALLPORemain+POli.ASI_MFM_PO_Balance__c;
                }                  
            }
            system.debug('TestSQL'+soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
            lineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
            if(lineItem.size()>0){
                system.debug('LineItems:'+lineItem);
                //if lineItem stores more than one data,show the summary table
                display=true; 
            }else{
                //hide the summary table
                display=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Records Found, Please Check your search input' ));
                 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input'));
            }
            TotalLineItem.clear();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input'));
            System.debug('Fail123');
        }
    }
    
    
    //search function    
    public PageReference runSearch() {
        String[] str;
        Datetime searchDate;
        soql='select id, name,RecordType.DeveloperName,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Base_Currency_Remaining_Balance__c,ASI_MFM_Invoice_Number__c,ASI_MFM_PO__r.ASI_MFM_Status__c, ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Name__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_PO_Supplier_Number__c ,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';//       ASI_MFM_PO_Amount__c > 0 AND               //soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Base_Currency_Amount__c) TotalOPO, sum(ASI_MFM_Base_Currency_Remaining_Balance__c) TotalRPO from ASI_MFM_PO_Line_Item__c where ASI_MFM_G_L_Date__c <= TODAY AND ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\'  AND ASI_MFM_PO_Amount__c > 0 AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__c = false  AND ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Base_Currency_Amount__c) TotalOPO, sum(ASI_MFM_Base_Currency_Remaining_Balance__c) TotalRPO from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        soqlpo='select id,name,Owner.name,ASI_MFM_Supplier_Name__r.name ,ASI_MFM_Plan__r.name,ASI_MFM_BU_Code__r.name,ASI_MFM_PO_Name__c,ASI_MFM_BU_Code__c,ASI_MFM_Plan__c,ASI_MFM_Sys_Plan_Amount__c,ASI_MFM_Plan_Balance__c,ASI_MFM_Sys_Plan_Name__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Number__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_PO_Raised_Date__c,ASI_MFM_Remarks__c,ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c,ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_PO_Balance__c,ASI_MFM_Payment_Request_Amount__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Base_Currency_Amount__c    from ASI_MFM_PO__c where ASI_MFM_PO_Amount__c>=0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        
        /* Elufa PRA Support 14 July*/ 
        if(PO_ID!=null && PO_ID.length()>0){
            soql += ' and ASI_MFM_PO__r.Name LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO__r.Name LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
            //soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
           // soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
        }
        
        if(PO_Line_ID!=null && PO_Line_ID.length()>0){
            soqlSubbrand += ' and Name LIKE \''+String.escapeSingleQuotes(PO_Line_ID)+'%\'';
            soql += ' and Name LIKE \''+String.escapeSingleQuotes(PO_Line_ID)+'%\'';
        }       
        
        if(Plan_ID!=null && Plan_ID.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_ID)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_ID)+'%\'';
        }
        
        /* Elufa PRA Support 14 July*/ 
        if(PlanNames!=null && PlanNames.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+String.escapeSingleQuotes(PlanNames)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+String.escapeSingleQuotes(PlanNames)+'%\'';
        }
        
        if(Fiscalyear!=null && Fiscalyear.length()>0 && Plan_ID.length()==0 && PO_Line_ID.length()==0 && PO_ID.length()==0){
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            soqlpo += ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        
        
        if(SubBrand_Code!=null && SubBrand_Code.length()>0){
            soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(SubBrand_Code)+'%\'';
            soql += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(SubBrand_Code)+'%\'';
        }
        
        if(SubBrand!=null && SubBrand.length()>0){
            soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SubBrand)+'%\'';
            soql += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SubBrand)+'%\'';
        }
        
        if(Supplier_Num!=null && Supplier_Num.length()>0){
            soqlSubbrand += ' and ASI_MFM_PO_Supplier_Number__c LIKE \'%'+String.escapeSingleQuotes(Supplier_Num)+'%\'';
            soql += ' and ASI_MFM_PO_Supplier_Number__c LIKE \'%'+String.escapeSingleQuotes(Supplier_Num)+'%\'';
        }
        
        
        if(suppl!=null && suppl.length()>0){
            soqlSubbrand +=  ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(suppl)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(suppl)+'%\'';
        }
        if (gl_fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate = DateTime.newInstance(gl_fromDate.ASI_MFM_G_L_Date__c.year(),gl_fromDate.ASI_MFM_G_L_Date__c.month(),gl_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
        }
        if (gl_toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate = DateTime.newInstance(gl_toDate.ASI_MFM_G_L_Date__c.year(),gl_toDate.ASI_MFM_G_L_Date__c.month(),gl_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c    <= ' + toDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_G_L_Date__c    <= ' + toDate + ''; 
        }   
        if(state!=null && state.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(state)+'%\''; 
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(state)+'%\''; 
        }
        
        /*
Plan_Number = Apexpages.currentPage().getParameters().get('Plan_Number');
Plan_Name = Apexpages.currentPage().getParameters().get('Plan_Name');
PO_Number = Apexpages.currentPage().getParameters().get('PO_Number');

PO_Line_Number = Apexpages.currentPage().getParameters().get('PO_Line_Number');
Sub_Brand_Code = Apexpages.currentPage().getParameters().get('Sub_Brand_Code');
Sub_Brand = Apexpages.currentPage().getParameters().get('Sub_Brand');
Suppliers_Num = Apexpages.currentPage().getParameters().get('Suppliers_Num');
Suppliers = Apexpages.currentPage().getParameters().get('Suppliers');
GLdates = Apexpages.currentPage().getParameters().get('GLdates');
Status = Apexpages.currentPage().getParameters().get('Status');


if (!Plan_Number.equals('')){
soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_Number)+'%\'';
soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_Number)+'%\'';
}

if (!Plan_Name.equals('')){
soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \''+String.escapeSingleQuotes(Plan_Name)+'%\'';
soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \''+String.escapeSingleQuotes(Plan_Name)+'%\'';
}


if (!PO_Number.equals('')){
soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_Number)+'%\'';
soqlSubbrand += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_Number)+'%\'';
}


if (!PO_Line_Number.equals('')){
soqlSubbrand += ' and Name LIKE \''+String.escapeSingleQuotes(PO_Line_Number)+'%\'';
soql += ' and Name LIKE \''+String.escapeSingleQuotes(PO_Line_Number)+'%\'';
}


if (!Sub_Brand_Code.equals('')){
soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+String.escapeSingleQuotes(Sub_Brand_Code)+'%\'';
soql += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+String.escapeSingleQuotes(Sub_Brand_Code)+'%\'';
}

if (!Sub_Brand.equals('')){
soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \''+String.escapeSingleQuotes(Sub_Brand)+'%\'';
soql += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \''+String.escapeSingleQuotes(Sub_Brand)+'%\'';
}

if (!Suppliers_Num.equals('')){
soqlSubbrand += ' and ASI_MFM_PO_Supplier_Number__c LIKE \''+String.escapeSingleQuotes(Suppliers_Num)+'%\'';
soql += ' and ASI_MFM_PO_Supplier_Number__c LIKE \''+String.escapeSingleQuotes(Suppliers_Num)+'%\'';
}


if (!Suppliers.equals('')){
soqlSubbrand +=  ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(Suppliers)+'%\'';
soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(Suppliers)+'%\'';
}

if (!GLdates.equals('')) {
str = GLdates.split('-');
searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
soql += ' and ASI_MFM_G_L_Date__c <= ' +searchDate.format('yyyy-MM-dd');
soqlSubbrand += ' and ASI_MFM_G_L_Date__c <= ' +searchDate.format('yyyy-MM-dd');
}
if (!Status.equals('')){
soql += ' and ASI_MFM_PO__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(Status)+'%\''; 
soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(Status)+'%\''; 
}
*/
        this.LimitFrom = 0;
        this.currentPageNum = 1;
        runQuery();
        return null;
    }
    
    // save BAverify 
    //public void save(){
      //  update lineItem;
    //}
    
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