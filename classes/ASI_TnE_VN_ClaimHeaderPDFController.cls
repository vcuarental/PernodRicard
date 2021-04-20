public without sharing class ASI_TnE_VN_ClaimHeaderPDFController {
    public String currentHeaderId {get; set;}
    private ASI_TnE_ClaimHeader__c header;
    private List<ASI_TnE_ClaimDetail__c> claimDetails {get;set;}        
    public Decimal monthlyAllowance {get;set;}
    public Decimal entainTotal{get;set;}
    public Decimal percentageUsed {get;set;}
    public Decimal aboveBelowAllowance {get;set;}
        
    public ASI_TnE_VN_ClaimHeaderPDFController()
    {
        monthlyAllowance = 0;
        entainTotal = 0;
        percentageUsed = 0;
        aboveBelowAllowance = 0;
    }
    
    public ASI_TnE_ClaimHeader__c getHeader()
    {
        if(currentHeaderId!=null)
        {
            header = [SELECT id, Name, ASI_TnE_Date__c, Owner.Name
                      ,ASI_TnE_Department_Division__c,ASI_TnE_Title__c
                      ,ASI_TnE_Status__c,ASI_TnE_Period_Covered_From__c
                      ,ASI_TnE_Period_Covered_To__c
                      ,ASI_TnE_Region__c,ASI_TnE_Exchange_Rate_Source__c
                      ,ASI_TnE_Expense_Report_Total__c
                      ,ASI_TnE_Cash_Advance_Deduction__c
                      ,ASI_TnE_Reimbursement_Due_Employee__c
                      ,ASI_TnE_Meal_Total__c,ASI_TnE_Hotel_Total__c
                      ,ASI_TnE_Auto_Exp_Total__c,ASI_TnE_Business_Trip_Ent_Total__c
                      ,ASI_TnE_Incidental_Others_Total__c,ASI_TnE_Airline_Total__c
                      ,ASI_TnE_Local_Entertainment_Total__c,ASI_TnE_Meeting_Total__c
                      ,ASI_TnE_Purpose_of_Travel__c,ASI_TnE_First_Approval_By__c
                      ,ASI_TnE_First_Approval_Date__c,ASI_TnE_Second_Approval_By__c
                      ,ASI_TnE_Second_Approval_Date__c,ASI_TnE_Third_Approval_By__c
                      ,ASI_TnE_Third_Approval_Date__c,ASI_TnE_Remarks__c
                      ,ASI_TnE_Monthly_Allowance__c, ASI_TnE_Local_Ent_Meeting_Total__c
                      ,ASI_TnE_Monthly_Allowance_Used_Percent__c
                      FROM ASI_TnE_ClaimHeader__c WHERE Id =: currentHeaderId];
            
            monthlyAllowance = header.ASI_TnE_Monthly_Allowance__c;
            entainTotal = header.ASI_TnE_Local_Ent_Meeting_Total__c;
            percentageUsed = header.ASI_TnE_Monthly_Allowance_Used_Percent__c;
            aboveBelowAllowance = entainTotal - monthlyAllowance;
        }
        return header;
    }
    
    public List<ASI_TnE_ClaimDetail__c> getClaimDetails()
    {
        if(currentHeaderId!=null)
        {
        claimDetails = [SELECT ASI_TnE_Date__c,ASI_TnE_Destination__c
                        ,ASI_TnE_Description__c,ASI_TnE_Details_of_Expense__c
                        ,ASI_TnE_Expense_Type__c,ASI_TnE_Total_Number_Pax__c,
                        ASI_TnE_Exchange_Rate_to_VND__c, ASI_TnE_Currency__c
                        ,ASI_TnE_VAT__c,ASI_TnE_Amount__c, ASI_TnE_Total_Expense__c
                        FROM ASI_TnE_ClaimDetail__c WHERE ASI_TnE_ClaimHeader__c = :currentHeaderId];
        }
        return claimDetails;
    }
}