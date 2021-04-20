public with sharing class  ASI_MFM_KR_PlanRequestEmailController
{	
    
    /*
    public ASI_MFM_KR_PlanRequestEmailController (ApexPages.StandardController stdController){ 
        this.planList = (ASI_MFM_Plan__c)stdController.getRecord();    
    }
	public ASI_MFM_Budget__c budgetList{get;set;}
    public string Brand {get;set;}
    public decimal Budget {get;set;}
    public Map<String,ASI_MFM_KR_BudgetCheckingClass.BrandBudget> resultMap {get;set;}

      */
    public Id receiptID {get;set;}
    public ASI_MFM_Plan__c planList{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> planLines{get;set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public List<Attachment> AttList {get;set;}
    public boolean hasAttachment {get;set;} {hasAttachment=false;}
        
    public boolean init()
    {
        planList = [SELECT Id, Name, 
                    Owner.Name, 
                    ASI_MFM_Start_Date__c, 
                    ASI_MFM_Plan_Name__c, 
                    ASI_MFM_Plan_Amount__c, 
                    ASI_MFM_End_Date__c, ASI_MFM_Comment__c,
                    ASI_MFM_Mechanics__c, 
                    ASI_MFM_Project_Code__r.Name, 
                    ASI_MFM_Remarks__c,
                    ASI_MFM_Objectives__c
                    FROM ASI_MFM_Plan__c 
                    WHERE Id = :receiptID LIMIT 1];
        
        planLines = [SELECT Id, Name, 
                     ASI_MFM_A_C_Code__r.Name,
                     ASI_MFM_AP_Code__r.Name,
                     ASI_MFM_KR_subLedger__r.Name,
                     ASI_MFM_AccountsAdditionalField__r.Name,
                     ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name,
                     ASI_MFM_Sub_brand_Code__r.Name, 
                     ASI_MFM_Company_Code__c, 
                     ASI_MFM_List_Item_Description__c,
                     ASI_MFM_PRPO_Needed__c, 
                     ASI_MFM_Total_Cost__c
                     FROM ASI_MFM_Plan_Line_Item__c 
                     WHERE ASI_MFM_Plan__c =: receiptID 
                     AND recordType.developerName = 'ASI_MFM_KR_Plan_Line_Item'];
        
        AttList= [select Id, name from Attachment where ParentId =: receiptID];
        if(AttList.size()>0){
            hasAttachment=true;
        }
        
        //ASI_MFM_KR_BudgetCheckingClass bcc = new ASI_MFM_KR_BudgetCheckingClass(); //budget check
        //bcc.GetBudget(planList); //budget check
        //resultMap = new Map<String,ASI_MFM_KR_BudgetCheckingClass.BrandBudget>(); //budget check
        //resultMap = bcc.getResult(); //budget check
        return true;        
    }//end method: init
}//end class