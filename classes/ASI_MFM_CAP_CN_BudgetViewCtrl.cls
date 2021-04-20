/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Tony Ren                                                                  
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI CN user                                                                                                                                                             
|     - Object(s)       | Custom Object: PO
|                       |                                                                                        
|     - Description     | Show all po  record RecordType.DeveloperName='ASI_MFM_CAP_CN_Structure_Cost'                             
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 13/02/2017                                                                        
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/

public class ASI_MFM_CAP_CN_BudgetViewCtrl {
    public integer counter=0;  //keeps track of the offset
    public integer list_size=30; //sets the page size or number of rows
    
    public integer total_size{get;set;} //used to show user the total size of the list
    public integer start_index{set;get;}
    public integer end_index{set;get;}
    
    public integer pageNumber{set;get;}
    public integer totalPages{set;get;}
    //SQL
    Public String QuerySQL {set;get;}{QuerySQL='';}
    Public String CountSQL {set;get;}{CountSQL='';}
    Public String FilterSQL {set;get;}{FilterSQL='';}
    Public String LimitSQL {set;get;}{LimitSQL='';}//public transient String ListJSON  {set;get;}{ListJSON=null;}
    
    Public List<SelectOption> fiscalYearOptions {Get; Set;}{fiscalYearOptions = new List<SelectOption>();}
    public string Msg {set;get;}
    Public Id batchId {Get; Set;}
    
    Public transient List<ASI_MFM_PO__c> POList {set;get;}{POList=new List<ASI_MFM_PO__c> ();} 
    
    //Search Filter 
    public String Fiscal_Years {get;set;} 
    public ASI_MFM_PO__c TempPO  { get; set; }{TempPO =new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_CAP_CN_Structure_Cost'));}
    
    public ASI_MFM_CAP_CN_BudgetViewCtrl(){
        init();
    }
    
    public void init(){
        String NowFY='FY';
        Integer fyyear;
        Date Today_date=Date.today();
        if(Today_date.month()<7){
            
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
            fyyear = (Integer.valueOf(string.valueof(Today_date.year()-1).substring(2,4)) * 100) + Integer.valueOf(string.valueof(Today_date.year()).substring(2,4));
        }else{
            
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
            fyyear = (Integer.valueOf(string.valueof(Today_date.year()).substring(2,4)) * 100) + Integer.valueOf(string.valueof(Today_date.year()+1).substring(2,4));
        }
        
        fiscalYearOptions.add(new SelectOption('', ''));
        
        for(integer i = -202 ; i <= 202 ; i+=101){
            fiscalYearOptions.add(new SelectOption('FY' + (fyyear + i), 'FY' + (fyyear + i)));
        }
        
        Fiscal_Years=NowFY;
        
        POList=new List<ASI_MFM_PO__c> ();
        counter=0;
        end_index = list_size;
        start_index=1;
        pageNumber=1;
        CountSQL='Select count() from ASI_MFM_PO__c   where  ';
        QuerySQL='Select Id,Name,ASI_MFM_Budget_Owner__r.Name,ASI_MFM_CN_Amount_Ex__c, ASI_MFM_Actual_Paid_Amount__c, ASI_MFM_Remaining_Budget__c, ASI_MFM_Budget_Owner__c,ASI_MFM_Status__c,ASI_MFM_LE__c,ASI_MFM_Expense_Type__c,ASI_MFM_Expense_Type__r.Name,ASI_MFM_BU_Code__c,ASI_MFM_BU_Code__r.Name,ASI_MFM_PO_Fiscal_Year__c,ASI_MFM_Department__c,ASI_MFM_Budget_ID__c from ASI_MFM_PO__c  where  ';
        FilterSQL=' RecordType.DeveloperName = \'ASI_MFM_CAP_CN_Structure_Cost\' ';
        
        queryRecord();
        
    }
    
     public void queryRecord(){
         LimitSQL= ' order by  '+sortField+'  '+sortDir+'  limit  '+list_size+' offset  '+counter;
         total_size=Database.countQuery(CountSQL+FilterSQL);
        
         if (total_size > 0){
            POList=Database.query(QuerySQL+FilterSQL+LimitSQL);
        }
          totalPages=getTotalPages();
        
        if (total_size > 0 && total_size != null){
            if ( counter + list_size > total_size){
                end_index = total_size;
            }else{
                end_index = counter + list_size;
            }
            start_index = counter +1;
        }
     }
    
     public void runSearch(){
         FilterSQL=' RecordType.DeveloperName = \'ASI_MFM_CAP_CN_Structure_Cost\' ';
         
         if(TempPO.ASI_MFM_Expense_Type__c!=null){
            string ExpenseTypeId=string.valueOf(TempPO.ASI_MFM_Expense_Type__c);
            FilterSQL += ' and ASI_MFM_Expense_Type__c =\''+ExpenseTypeId+'\'';            
        }
         if(Fiscal_Years!=null && Fiscal_Years.length()>0){
            FilterSQL += ' and ASI_MFM_PO_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Years)+'%\'';
        }
        
        queryRecord();
     }
    
    Public void executeRecalc(){
        batchId = database.executebatch(new ASI_MFM_CN_StructureCostBudget_Batch(Fiscal_Years));
        Msg = 'Process Started';
    }
	
    Public void executeReverse(){
        batchId = database.executebatch(new ASI_MFM_CN_StructureCost_Reverse_Batch(Fiscal_Years));
        Msg = 'Process Started';
    }
	    
    public string[] StatusMsgs {
        get {
            string s = msg==null? '': msg;
            if(BatchId!=null) {
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                    s = aajs[0].Status;
                }
            }
            return s.split('\n');
        }
    }
       
    //sort
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        
        queryRecord();
    }
    
    
    //*****  functionality *****
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    
    
    public Integer getTotalPages() {
        system.debug(list_size+' || '+total_size+'Current Page:' + math.mod(total_size, list_size) );
        if (math.mod(total_size, list_size) > 0) {
            
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }
    
    
    public String sortField {
        get  { if (sortField == null) {sortField = ' Name '; } return sortField;  }
        set;
    }
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'DESC'; } return sortDir;  }
        set;
    }
    
    
    
}