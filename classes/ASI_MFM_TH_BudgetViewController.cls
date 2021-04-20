public with sharing class ASI_MFM_TH_BudgetViewController {
    private String soql {get;set;}
    private String soqlBudget{get;set;}
    private String soqlBudgetSum{get;set;}
    private String soqlPlan{get;set;}
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    //public String Sub_Brand_Code;
    //public String Sub_Brand;
	//public String Departments;
	//public String Budget_Type;
    public String Budget_Typeset;
	//public String Fiscal_Year;
    public String Fiscal_Yearset;
    public Set<String> setDeptCategory {set;get;}
    
    public transient String SubBCode{get;set;} 
    public transient String SubB{get;set;}
    public transient String Dept{get;set;}

    public transient String  BudgetTypes{get;set;}
    public transient String FiscalYears {get;set;}
    public transient String FYShowing {get;set;}
    public transient String BTShowing {get;set;}
    public Decimal TotalBA {get;set;}
    public Decimal TotalPlanAmount {get;set;}
    /*
    public Decimal TotalBudgetAmount {get;set;}  // Budget 
    public Decimal TotalLE1Amount {get;set;}     //Budget LE1
    public Decimal TotalLE2Amount {get;set;}     //Budget LE2
    public Decimal TotalLE3Amount {get;set;}     //Budget LE3
    public Decimal TotalLE4Amount {get;set;}     //Budget LE4
    
    public Decimal BudgetTHHAmount {get;set;}
    public Decimal BudgetTHMAmount {get;set;}
    public Decimal BudgetTHTAmount {get;set;}
    public Decimal BudgetTHKAmount {get;set;}
    public Decimal BudgetTHPAmount {get;set;}
    public Decimal BudgetTHAAmount {get;set;}
    public Decimal BudgetTHDAmount {get;set;}

    
    
    public Decimal TotalTHHAmount {get;set;}
    public Decimal TotalTHMAmount {get;set;}
    public Decimal TotalTHTAmount {get;set;}
    public Decimal TotalTHKAmount {get;set;}
    public Decimal TotalTHPAmount {get;set;}
    public Decimal TotalTHAAmount {get;set;}
    public Decimal TotalTHDAmount {get;set;}*/
    public ASI_MFM_TH_BudgetViewController(ApexPages.StandardController controller){
         init();
        
    }
    
    public List<SummaryObject> Summaries{get;set;} 
    public List<SummaryObject> SummariesP{get;set;} 
    public class SummaryObject{
        /*For Sub-Brand use*/
       
        public Decimal TotalAmt { get; private set; }// Remaining PO
        public String Name { get; private set; }// Sub-Brand Name
        public SummaryObject(AggregateResult ar) {
            TotalAmt = (Decimal) ar.get('TotalAmount');
            Name = (String) ar.get('Name');
        }
    }
    
    
    public void init() {
        SubBCode=NULL;
        SubB=NULL;
        Dept=NULL;
        for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) {
            // Get effective value
            if(Setting.name == 'TH'){
                BudgetTypes= Setting.ASI_MFM_Budget_Type__c; 
                FiscalYears= Setting.ASI_MFM_Fiscal_Year__c;
                
                Budget_Typeset = Setting.ASI_MFM_Budget_Type__c;   // default value
                BTShowing= Setting.ASI_MFM_Budget_Type__c; 
                
                Fiscal_Yearset = Setting.ASI_MFM_Fiscal_Year__c;  // Use in sql find Budegt
                //Fiscal_Year= Setting.ASI_MFM_Fiscal_Year__c;  // Use in sql calculate Plan amount
                FYShowing= Setting.ASI_MFM_Fiscal_Year__c;// show in the page
                
            }
        }
        soql='select id, name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Fiscal_Year__c,ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c,ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c,ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c,ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c,ASI_MFM_Region_AND_Customer__c,ASI_MFM_Type__c,ASI_MFM_Department__c,ASI_MFM_Total_Amount__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name from ASI_MFM_Budget__c where  ASI_MFM_Budget__c.RecordType.DeveloperName LIKE \'ASI_MFM_TH_Budget%\' ';
        soql +=' and ASI_MFM_Type__c LIKE \''+String.escapeSingleQuotes(Budget_Typeset)+'%\'';
        soql +=' and ASI_MFM_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Yearset)+'%\'';
        
        soqlBudgetSum='select ASI_MFM_Department__c Name,sum(ASI_MFM_Total_Amount__c) TotalAmount from ASI_MFM_Budget__c where ASI_MFM_Budget__c.RecordType.DeveloperName LIKE \'ASI_MFM_TH_Budget%\'';
        soqlBudgetSum+=' and ASI_MFM_Type__c LIKE \''+String.escapeSingleQuotes(Budget_Typeset)+'%\'';
        soqlBudgetSum +=' and ASI_MFM_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Yearset)+'%\'';
        
        soqlPlan='select ASI_MFM_Prefix__r.name Name,sum(ASI_MFM_Plan_Amount__c) TotalAmount from ASI_MFM_Plan__c where ASI_MFM_Plan__c.RecordType.DeveloperName LIKE \'ASI_MFM_TH_Plan%\'';
        soqlPlan +=' and ASI_MFM_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Yearset)+'%\'';
        //soqlBudget=soql;
        
        this.numOfRowInTable = 100;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        runQuery();
    }
    
    public PageReference refresh() {
        init();
        return null;
    }
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'DESC'; } return sortDir;  }
        set;
    }
    public String sortField {
        get  { if (sortField == null) {sortField = 'ASI_MFM_Fiscal_Year__c'; } return sortField;  }
        set;
    }
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom; }
        set;
    }
    
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
    
    public void toggleSort() {
		sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
		runQuery();
        //runSearch();
      }
    
    public Integer maxPageNum { get { return maxNumOfPage(); } private set; }
    public Integer currentPageNum { get; protected set { currentPageNum = value; newPageNum = String.valueOf(value); } }
    public String newPageNum { get; set; }
    public transient List<ASI_MFM_Budget__c> TotalLineItem{get;set;}
    public transient List<ASI_MFM_Budget__c> TotalLineItems{get;set;}
    public transient List<ASI_MFM_Budget__c> lineItem{get;set;}
    
        
   
    
    public void runQuery() {
     TotalPlanAmount=0;
        /*
        TotalBudgetAmount=0;
        TotalLE1Amount=0;
        TotalLE2Amount=0;
        TotalLE3Amount=0;
        TotalLE4Amount=0;
        
        TotalTHHAmount=0;
        TotalTHMAmount=0;
        TotalTHTAmount=0;
        TotalTHKAmount=0;
        TotalTHPAmount=0;
        TotalTHAAmount=0;
        TotalTHDAmount=0;
        BudgetTHHAmount=0;
        BudgetTHMAmount=0;
        BudgetTHTAmount=0;
        BudgetTHKAmount=0;
        BudgetTHPAmount=0;
        BudgetTHAAmount=0;
        BudgetTHDAmount=0;  */
            
        try {
            //////////////////////////////////////////New////////////////////////////////////////
            setDeptCategory = new Set<String>();
            TotalBA=0;
            String BudgetSQL=soqlBudgetSum+'group by ASI_MFM_Department__c';
            AggregateResult[] groupedResults=Database.query(BudgetSQL);
            Summaries = new List<SummaryObject>();
            for (AggregateResult ar : groupedResults) {
                if(ar.get('Name') != null){
                    setDeptCategory.add(String.valueof(ar.get('Name')));
                }
                Summaries.add(new SummaryObject(ar));
            }
            for(SummaryObject so:Summaries){
                TotalBA=TotalBA+so.TotalAmt;
            }
             String PlanSQL=soqlPlan+'group by ASI_MFM_Prefix__r.name';
            AggregateResult[] groupedResults2=Database.query(PlanSQL);
            
            SummariesP = new List<SummaryObject>();
            for (AggregateResult ar : groupedResults2) {
                SummariesP.add(new SummaryObject(ar));
            }
            
            //
            
            //setDeptCategory.add('THM');
            /////////////////////////////////////////New////////////////////////////////////////
            TotalLineItems = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
            
            //TotalLineItem = Database.query(soqlBudget + ' order by ' + sortField + ' ' + sortDir);
            
            list<ASI_MFM_Plan__c> PlanItem  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where ASI_MFM_Fiscal_year__c=:FiscalYears AND ASI_MFM_Plan__c.RecordType.DeveloperName LIKE:'%ASI_MFM_TH_Plan%'];
            for(ASI_MFM_Plan__c Planli : PlanItem){ // calculate the sum of Total plan amount
                TotalPlanAmount=TotalPlanAmount+Planli.ASI_MFM_Plan_Amount__c;
            }
            /*
            list<ASI_MFM_Plan__c> PlanItemTHT  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where ASI_MFM_Prefix__r.name Like :'%THT%' AND ASI_MFM_Fiscal_year__c=:FiscalYears AND ASI_MFM_Plan__c.RecordType.DeveloperName LIKE:'%ASI_MFM_TH_Plan%'];
            for(ASI_MFM_Plan__c Planli : PlanItemTHT){ // calculate the sum of plan amount in THT
                TotalTHTAmount=TotalTHTAmount+Planli.ASI_MFM_Plan_Amount__c;
            }
            
            list<ASI_MFM_Plan__c> PlanItemTHH  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where ASI_MFM_Prefix__r.name Like :'%THH%'  AND ASI_MFM_Fiscal_year__c=:FiscalYears AND ASI_MFM_Plan__c.RecordType.DeveloperName LIKE:'%ASI_MFM_TH_Plan%'];
            for(ASI_MFM_Plan__c Planli : PlanItemTHH){ // calculate the sum of plan amount in THH
                TotalTHHAmount=TotalTHHAmount+Planli.ASI_MFM_Plan_Amount__c;
            }  
            
            list<ASI_MFM_Plan__c> PlanItemTHM  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where ASI_MFM_Prefix__r.name Like :'%THM%'  AND ASI_MFM_Fiscal_year__c=:FiscalYears AND ASI_MFM_Plan__c.RecordType.DeveloperName LIKE:'%ASI_MFM_TH_Plan%'];
            for(ASI_MFM_Plan__c Planli : PlanItemTHM){ // calculate the sum of plan amount in THM
                TotalTHMAmount=TotalTHMAmount+Planli.ASI_MFM_Plan_Amount__c;
            }            
            
            list<ASI_MFM_Plan__c> PlanItemTHK  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where ASI_MFM_Prefix__r.name Like :'%THK%'  AND ASI_MFM_Fiscal_year__c=:FiscalYears AND ASI_MFM_Plan__c.RecordType.DeveloperName LIKE:'%ASI_MFM_TH_Plan%'];
            for(ASI_MFM_Plan__c Planli : PlanItemTHK){ // calculate the sum of plan amount in THK
                TotalTHKAmount=TotalTHKAmount+Planli.ASI_MFM_Plan_Amount__c;
            }  
            
            list<ASI_MFM_Plan__c> PlanItemTHP  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where ASI_MFM_Prefix__r.name Like :'%THP%'  AND ASI_MFM_Fiscal_year__c=:FiscalYears AND ASI_MFM_Plan__c.RecordType.DeveloperName LIKE:'%ASI_MFM_TH_Plan%'];
            for(ASI_MFM_Plan__c Planli : PlanItemTHP){ // calculate the sum of plan amount in THP
                TotalTHPAmount=TotalTHPAmount+Planli.ASI_MFM_Plan_Amount__c;
            }  
            list<ASI_MFM_Plan__c> PlanItemTHA  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where ASI_MFM_Prefix__r.name Like :'%THA%'  AND ASI_MFM_Fiscal_year__c=:FiscalYears AND ASI_MFM_Plan__c.RecordType.DeveloperName LIKE:'%ASI_MFM_TH_Plan%'];
            for(ASI_MFM_Plan__c Planli : PlanItemTHA){ // calculate the sum of plan amount in THP
                TotalTHAAmount=TotalTHAAmount+Planli.ASI_MFM_Plan_Amount__c;
            } 
            list<ASI_MFM_Plan__c> PlanItemTHD  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where ASI_MFM_Prefix__r.name Like :'%THD%'  AND ASI_MFM_Fiscal_year__c=:FiscalYears AND ASI_MFM_Plan__c.RecordType.DeveloperName LIKE:'%ASI_MFM_TH_Plan%'];
            for(ASI_MFM_Plan__c Planli : PlanItemTHD){ // calculate the sum of plan amount in THP
                TotalTHDAmount=TotalTHDAmount+Planli.ASI_MFM_Plan_Amount__c;
            } 
           
            
            for(ASI_MFM_Budget__c buli : TotalLineItem){  // Calculate Budget break amount
                if(buli.ASI_MFM_Type__c!=null){
                    if(buli.ASI_MFM_Type__c.contains('Budget') && buli.ASI_MFM_Total_Amount__c!=null){ // calculate total Budget amount   if(buli.ASI_MFM_Total_Amount__c>0)
                            TotalBudgetAmount=TotalBudgetAmount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Type__c.contains('LE1')  && buli.ASI_MFM_Total_Amount__c!=null ){ // calculate LE1 amount     
                            TotalLE1Amount=TotalLE1Amount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Type__c.contains('LE2') && buli.ASI_MFM_Total_Amount__c!=null ){
                            TotalLE2Amount=TotalLE2Amount+buli.ASI_MFM_Total_Amount__c;  
                    }
                    if(buli.ASI_MFM_Type__c.contains('LE3') && buli.ASI_MFM_Total_Amount__c!=null ){
                            TotalLE3Amount=TotalLE3Amount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Type__c.contains('LE4') && buli.ASI_MFM_Total_Amount__c!=null ){
                            TotalLE4Amount=TotalLE4Amount+buli.ASI_MFM_Total_Amount__c;
                    }
                    
                    if(buli.ASI_MFM_Department__c.contains('THM') && buli.ASI_MFM_Total_Amount__c!=null){
                        BudgetTHMAmount=BudgetTHMAmount+buli.ASI_MFM_Total_Amount__c;
                    }
                    
                    if(buli.ASI_MFM_Department__c.contains('THK') && buli.ASI_MFM_Total_Amount__c!=null){
                        BudgetTHKAmount=BudgetTHKAmount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Department__c.contains('THH') && buli.ASI_MFM_Total_Amount__c!=null){
                        BudgetTHHAmount=BudgetTHHAmount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Department__c.contains('THT') && buli.ASI_MFM_Total_Amount__c!=null){
                        BudgetTHTAmount=BudgetTHTAmount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Department__c.contains('THP') && buli.ASI_MFM_Total_Amount__c!=null){
                        BudgetTHPAmount=BudgetTHPAmount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Department__c.contains('THA') && buli.ASI_MFM_Total_Amount__c!=null){
                        BudgetTHAAmount=BudgetTHAAmount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Department__c.contains('THD') && buli.ASI_MFM_Total_Amount__c!=null){
                        BudgetTHDAmount=BudgetTHDAmount+buli.ASI_MFM_Total_Amount__c;
                    }
                }
                
        	}
*/
              this.totalNumOfRecord = TotalLineItems.size();
              lineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
            TotalLineItems.clear();
          } catch (Exception e) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' + soql));
              //System.debug('Fail123');
    		}

    }
    
    
    public PageReference runSearch() {
        FYShowing=FiscalYears;  //Show in the page
        BTShowing=BudgetTypes;
        soql='select id, name, ASI_MFM_Fiscal_Year__c,ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c,ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c,ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c,ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c,ASI_MFM_Region_AND_Customer__c,ASI_MFM_Type__c,ASI_MFM_Department__c,ASI_MFM_Total_Amount__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name from ASI_MFM_Budget__c where  ASI_MFM_Budget__c.RecordType.DeveloperName LIKE \'ASI_MFM_TH_Budget%\' ';
        //soqlBudget=soql;
        
        soqlBudgetSum='select ASI_MFM_Department__c Name,sum(ASI_MFM_Total_Amount__c) TotalAmount from ASI_MFM_Budget__c where ASI_MFM_Budget__c.RecordType.DeveloperName LIKE \'ASI_MFM_TH_Budget%\'';
       soqlPlan='select ASI_MFM_Prefix__r.name Name,sum(ASI_MFM_Plan_Amount__c) TotalAmount from ASI_MFM_Plan__c where ASI_MFM_Plan__c.RecordType.DeveloperName LIKE \'ASI_MFM_TH_Plan%\'';
      
        
        if(SubBCode!=null && SubBCode.length()>0){
            soql +=' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+String.escapeSingleQuotes(SubBCode)+'%\'';
        }
        if(SubB!=null && SubB.length()>0){
            soql +=' and ASI_MFM_Sub_brand_Code__r.name LIKE \''+String.escapeSingleQuotes(SubB)+'%\'';
        }
        if(Dept!=null && Dept.length()>0){
            soql +=' and ASI_MFM_Department__c LIKE \''+String.escapeSingleQuotes(Dept)+'%\'';
        }
        if(BudgetTypes!=null && BudgetTypes.length()>0){
            soql +=' and ASI_MFM_Type__c LIKE \''+String.escapeSingleQuotes(BudgetTypes)+'%\'';
            //soqlBudget +=' and ASI_MFM_Type__c LIKE \''+String.escapeSingleQuotes(BudgetTypes)+'%\'';
            soqlBudgetSum+=' and ASI_MFM_Type__c LIKE \''+String.escapeSingleQuotes(BudgetTypes)+'%\'';
            
        }
        if(FiscalYears!=null && FiscalYears.length()>0){
            soql +=' and ASI_MFM_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(FiscalYears)+'%\'';
            //soqlBudget +=' and ASI_MFM_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(FiscalYears)+'%\'';
            
            soqlBudgetSum +=' and ASI_MFM_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(FiscalYears)+'%\'';
            soqlPlan +=' and ASI_MFM_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(FiscalYears)+'%\'';
        }
        runQuery();
        return null;
    }
    
     public List<SelectOption> getSearchCategoryOptions() {
        List<SelectOption> searchCategoryOptions = new List<SelectOption>();
        
        searchCategoryOptions.add(new SelectOption('','--None--'));
        for(String category : setDeptCategory){
            searchCategoryOptions.add(new SelectOption(category, category));
        }        
        searchCategoryOptions.sort();
        return searchCategoryOptions;
    }
    
}