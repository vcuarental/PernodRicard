public class ASI_CRM_CN_PriceDiscount_EmailController {
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public String currentHeaderID {set;get;}
    public Integer RTnumbetr {get;set;}  
    public ASI_CRM_Price_And_Discount__c PDCurrent{get;set;}
    public List<ASI_CRM_Price_And_Discount_Detail__c> lineItem{get;set;}
    public String SpaceStr {get;set;}
    
    public boolean init(){
        PDCurrent=[select id,name,RecordType.DeveloperName,RecordType.name,
                   ASI_CRM_Type__c,ASI_CRM_Remark__c,ASI_CRM_Effective_From__c,ASI_CRM_Effective_To__c,ASI_CRM_JDE_Code__c,ASI_CRM_Customer__r.name,
                   ASI_CRM_Customer_Region__c,ASI_CRM_Volume_Based__c,ASI_CRM_Volume_Based_Mechanics__c,ASI_CRM_Channel__c,ASI_CRM_ReasonForThePriceIsLowerThanT1__c,
                   ASI_CRM_Reason_for_Investment__c,ASI_CRM_CN_Total_Gross_Sales_Impact__c,ASI_CRM_IHBR_Price_Type__c
                   , ASI_CRM_CN_Estimated_annual_order_amount__c //20161104, Leo@Elufa
                   from ASI_CRM_Price_And_Discount__c where id= : currentHeaderID];
        lineItem=[select id,name,ASI_CRM_Item_Group_Description__c,ASI_CRM_Current_T1_Price_BT_with_VAT__c,ASI_CRM_Item_Group_Description__r.name,
                  ASI_CRM_Item_Group_Description__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_New_Price_BT_non_VAT__c,ASI_CRM_vs_Current_T1_with_VAT__c,ASI_CRM_Total_Estimated_Vol_BT__c,
                  ASI_CRM_Gross_Sales_Impact__c,ASI_CRM_Promotion_Code__r.Name,ASI_CRM_Buy_X__c,ASI_CRM_Get_Y__c,
                  ASI_CRM_New_Price_BT_with_VAT__c,ASI_CRM_vs_Current_T1_with_VAT_Percent__c
                  ,ASI_CRM_Promotion_Code__r.ASI_CRM_Description__c //20160822, added by Leo
                  from ASI_CRM_Price_And_Discount_Detail__c where ASI_CRM_Price_And_Discount__c=: currentHeaderID];
        
        if(PDCurrent.RecordType.DeveloperName.contains('ASI_CRM_CN_Customer_Price_and_Discount_Request')){
            RTnumbetr=2;
        }else{
            RTnumbetr=1;
        }       
        SpaceStr='                       ';
        return true;
    }

}