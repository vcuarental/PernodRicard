public class ASI_CRM_KR_PVAUploadController {
    
    
    public String Fiscalyear{get;set;}
    
    public list<selectOption> availableActivityType {get; private set;}
    public list<selectOption> availableFiscalYear {get; private set;}
  
    public ASI_CRM_KR_PVAUploadController() {
      }
    
    public void init() {
        
         
        string  NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        Fiscalyear=NowFY;
        
        
        availableActivityType= new list<selectOption>();
        availableActivityType=getPickListValue(ASI_CRM_KR_A_P_Guideline__c.ASI_CRM_KR_Activity_Type__c.getDescribe());
        
        availableFiscalYear= new list<selectOption>();
        availableFiscalYear=getPickListValue(ASI_CRM_KR_A_P_Guideline__c.ASI_CRM_KR_Fiscal_Year__c.getDescribe());
        
     
    }
    
      public List<SelectOption> getPickListValue(Schema.DescribeFieldResult fieldResult){
        List<SelectOption> Selectoptions = new List<SelectOption>();
        //=ASI_KOR_Visitation_Plan_Detail__c.ASI_CRM_KR_Cancel_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();//Selectoptions.add(new SelectOption('','--None--'));
        for( Schema.PicklistEntry f : ple){
            Selectoptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return Selectoptions;
    }
    
}