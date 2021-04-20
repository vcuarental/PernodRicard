public class ASI_NPL_KR_ApprovalEmailController {
    
	public ASI_CN_NPL_NPL_Request__c  header{get;set;}
    public Id headerId {get;set;} //current header Id
    public ASI_CN_NPL_NPL_Request__c npl{get;set;} //current header
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }                   
    
	public boolean init()
    {
        npl = [SELECT Id, Name, ASI_NPL_New_SKU_Name__c
               , ASI_CN_NPL_SKU_Type__c
               , ASI_NPL_Category_1__c
               , ASI_NPL_Category_2__c
               , ASI_NPL_Size__c
               , ASI_NPL_Packing__c
               , ASI_NPL_Launch_Objective__c
               , ASI_NPL_Period_of_Sales_Start_YYYY_MM__c
               , ASI_NPL_Period_of_Sales_End_YYYY_MM__c
               , ASI_NPL_Brand_Owner__c
               , ASI_NPL_Brand_Information__c
               , ASI_NPL_Volume_9L__c
               , ASI_NPL_Channel__c
               , ASI_NPL_Launch_Date__c
               , ASI_NPL_Supply_Price_Currency__c
               , ASI_NPL_Pricing_Index_Currency__c
               , ASI_NPL_Target_RSP_Currency__c
               , ASI_NPL_Transfer_Price_Currency__c
               , ASI_NPL_Supply_Price_Comments__c
               , ASI_NPL_Pricing_Index_Comments__c 
               , ASI_NPL_Target_RSP_Comments__c 
               , ASI_NPL_Transfer_Price_Comments__c
               , ASI_NPL_Supply_Price__c
               , ASI_NPL_Pricing_Index__c 
               , ASI_NPL_Target_RSP__c
               , ASI_NPL_Tentative_Transfer_Price__c
               , ASI_NPL_One_in_One_out_SKU__c
               , ASI_NPL_SKU_To_Be_Delisted__c
               , ASI_NPL_Leftover_Disposal_Plan__c
               , ASI_NPL_SKU_Created_Date__c 
               , ASI_NPL_JDE_SKU_Code__c 
               , ASI_CN_NPL_Status__c 
               , Owner.Name
               From ASI_CN_NPL_NPL_Request__c
               WHERE Id =: headerId 
               LIMIT 1];
        
        return true;        
    }//end method: init

}