/*********************************************************************************
 * Name: ASI_CRM_SG_PromotionPlanEmailCtrl
 * Description: Show all information of promotion plan in the approval email, controller
 *
 * Version History
 * Date             Developer                Comments
 * ---------------  --------------------     --------------------------------------------------------------------------------
 * 2018-04-04       Vincent Lam			     Created
 */
public class ASI_CRM_SG_PromotionPlanEmailCtrl {
  public ASI_CRM_SG_PromotionPlanEmailCtrl(){
    withCustomer = withCustomer != null ? withCustomer : false;
  }
  
  public String headerId {get;set;}
  public Boolean withCustomer {get;set;}
    
  public List<ASI_CRM_Promotion_Mechanic__c> getChilds(){
    
    return [select id, 
         ASI_CRM_Promotional_SKU__r.Name,
         ASI_CRM_Promotional_Sub_brand__r.Name,
         ASI_CRM_Buy_Qty__c,
         ASI_CRM_Buy_Unit__c,
         ASI_CRM_Trade_Deal_Bottle_Qty__c,
         ASI_CRM_Additional_SKU_POSM__r.Name,
         ASI_CRM_Additional_SKU_Bottle_Qty__c,
         ASI_CRM_Ad_hoc_Cash__c,
         ASI_CRM_Gift_Voucher__r.Name,
		 ASI_CRM_Other_in_Kind_Cash__c,
         ASI_CRM_Target_Qty_Bottle__c,
         ASI_CRM_Remark__c,
		 ASI_CRM_Mechanic_Description__c,
		 ASI_CRM_ROI__c
         from ASI_CRM_Promotion_Mechanic__c 
         where ASI_CRM_Promotion_Plan__c = :headerId];
  }
  
  public ASI_CRM_Promotion_Plan__c getHeader(){
    
    return [select id,
         Name, 
         ASI_CRM_Status__c, 
         ASI_CRM_Start_Date__c,
         ASI_CRM_End_Date__c,
         ASI_CRM_Description__c,
         RecordType.Name,
         ASI_CRM_Enrollment_Cut_off_Date__c,
         ASI_CRM_Approval_Cut_off_Date__c,
         //ASI_CRM_Total_Target_Volume_9L__c,
         //ASI_CRM_Total_Incentive_Volume_9L__c,
         //ASI_CRM_Total_Target_Value__c,
         //ASI_CRM_Total_Incentive_Value__c,
         ASI_CRM_Total_Incentive_Value_Formula__c,
         ASI_CRM_Total_Incentive_Value_FOC__c,
         ASI_CRM_Total_Incentive_Value_Cash__c,
         ASI_CRM_Total_Incentive_Value_Voucher__c,
         ASI_CRM_TotalIncentiveValue_OtherInKind__c,
         ASI_CRM_Total_Incentive_Volume_9L_Rollup__c,
         ASI_CRM_Total_Target_Value_Rollup__c,
         ASI_CRM_Total_Target_Volume_9L_Rollup__c,
		 ASI_CRM_Total_Target_ROI_Percent__c,
		 ASI_CRM_Committed_Target_Value__c, 
		 ASI_CRM_Committed_Target_Volume_9L__c,
		 ASI_CRM_Committed_Incentive_Value__c,
		 ASI_CRM_Committed_Incentive_Value_Cash__c,
		 ASI_CRM_Committed_Incentive_Value_FOC__c,
		 ASI_CRM_CommittedIncentiveValue_OIK__c,
		 ASI_CRM_CommittedIncentiveValue_Voucher__c,
		 ASI_CRM_Committed_Incentive_Volume_9L__c,
		 ASI_CRM_Total_Committed_ROI_Percent__c
         from ASI_CRM_Promotion_Plan__c
         where id = :headerId
		 limit 1];  
  }
  
  public Map<string, Map<string, List<ASI_HK_CRM_Promotion_Detail__c>>> getCustomerDetail(){
     Map<string, Map<string, List<ASI_HK_CRM_Promotion_Detail__c>>> map_owner_c = new  Map<string, Map<string, List<ASI_HK_CRM_Promotion_Detail__c>>>();
	String query = 'SELECT Id, ASI_CRM_Promotion_Mechanic__c, ASI_CRM_SG_Customer__c, ASI_CRM_Target_Qty_Bottle__c, ASI_CRM_SG_Customer__r.Name, ASI_HK_CRM_Promotion__r.owner.name ' 
           + ', ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Additional_SKU_POSM__c '
                     + ', ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Additional_SKU_Bottle_Qty__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Ad_hoc_Cash__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Buy_Qty__c '
                     + ', ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Buy_Unit__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Gift_Voucher__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Gift_Voucher_Value_Cash__c '
                     + ', ASI_CRM_Promotion_Mechanic__r.ASI_CRM_IGC_Cost_Case_Promotional__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Other_in_Kind_Cash__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Promotional_SKU__c '
                     + ', ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Promotional_Sub_brand__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Promotion_Plan__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_ROI__c '
                     + ', ASI_CRM_Promotion_Mechanic__r.ASI_CRM_RTM_WS_Price_Bottle_Additional__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_RTM_WS_Price_Bottle_Promotional__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Trade_Deal_Bottle_Qty__c '
                     + ', ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Promotional_SKU__r.Name, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Promotional_Sub_brand__r.Name, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Additional_SKU_POSM__r.Name, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Gift_Voucher__r.Name '
                     + ', ASI_CRM_P12M_Avg_Consumption_9L__c, ASI_CRM_Target_Volume_9L__c, ASI_CRM_Monthly_Avg_Target_Volume_9L__c '
					 + ', ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Packaging_Size_Promotional__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Bottle_Size_Promotional__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Target_Qty_Bottle__c '
                     + ', ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Remark__c, ASI_CRM_Promotion_Mechanic__r.ASI_CRM_Mechanic_Description__c '
					 + 'FROM ASI_HK_CRM_Promotion_Detail__c '
                     + 'WHERE ASI_HK_CRM_Promotion__r.ASI_CRM_Promotion_Plan__c = :headerId '
                     + 'Order by ASI_HK_CRM_Promotion__r.owner.name, ASI_CRM_SG_Customer__r.Name ';
        
    for(ASI_HK_CRM_Promotion_Detail__c pd : (List<ASI_HK_CRM_Promotion_Detail__c>) Database.query(query)){
		string owner = pd.ASI_HK_CRM_Promotion__r.owner.name;
		string cName = pd.ASI_CRM_SG_Customer__r.Name;
		Map<string, List<ASI_HK_CRM_Promotion_Detail__c>> map_c = map_owner_c.containsKey(owner) ? map_owner_c.get(owner) : new Map<string, List<ASI_HK_CRM_Promotion_Detail__c>>();
		List<ASI_HK_CRM_Promotion_Detail__c> list_p = map_c.containsKey(cName) ? map_c.get(cName) : new List<ASI_HK_CRM_Promotion_Detail__c>();
		list_p.add(pd);
		map_c.put(cName, list_p);
		map_owner_c.put(owner, map_c);
	}
	return map_owner_c;
  }
  
}