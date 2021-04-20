/*********************************************************************************
 * Name:ASI_CRM_SG_PromotionService
 * Description: Service Class for SG Promotion Detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-04-06       Vincent Lam             Created
*********************************************************************************/
public class ASI_CRM_SG_PromotionService {
    
    private static ASI_CRM_SG_PromotionService PROMOTION_SERVICE = new ASI_CRM_SG_PromotionService();
	private static final string FINALAPPROVED = 'Final Approved';
    
    //Not Allow to create instance
    private ASI_CRM_SG_PromotionService() { 
    }
    
    public static ASI_CRM_SG_PromotionService getInstance() {
		return PROMOTION_SERVICE;
    }

    public void rollupTargetToPromotion(List<ASI_HK_CRM_Promotion__c> PromotionList) {
        Map<Id, ASI_HK_CRM_Promotion__c> PromotionMap = new Map<Id, ASI_HK_CRM_Promotion__c>(PromotionList);
		Set<string> set_promotionId = new Set<string>();
		List<ASI_CRM_Promotion_Plan__c> list_promotionToUpdate = new List<ASI_CRM_Promotion_Plan__c>();
        
        for(ASI_HK_CRM_Promotion__c pd : PromotionList) {
            set_promotionId.add(pd.ASI_CRM_Promotion_Plan__c);
        }
        
        for(AggregateResult ar : retrievePromotionList(set_promotionId, '')) {
            String promotionId = String.valueOf(ar.get('promotionId'));
			Decimal sumRow = (Decimal)ar.get('sumRow');
            Decimal sumTargetValue = (Decimal)ar.get('sumTargetValue');
            Decimal sumTargetVolume9L = (Decimal)ar.get('sumTargetVolume9L');
            Decimal sumIncentiveValue = (Decimal)ar.get('sumIncentiveValue');
            Decimal sumIncentiveVolume9L = (Decimal)ar.get('sumIncentiveVolume9L');
            Decimal sumIncentiveValueCash = (Decimal)ar.get('sumIncentiveValueCash');
            Decimal sumIncentiveValueFOC = (Decimal)ar.get('sumIncentiveValueFOC');
            Decimal sumIncentiveValueOIK = (Decimal)ar.get('sumIncentiveValueOIK');
            Decimal sumIncentiveValueVoucher = (Decimal)ar.get('sumIncentiveValueVoucher');
			ASI_CRM_Promotion_Plan__c p = new ASI_CRM_Promotion_Plan__c(
				Id = promotionId,
				ASI_CRM_Total_Number_of_PromotionDetails__c = sumRow,
				ASI_CRM_Committed_Target_Value__c = sumTargetValue,
				ASI_CRM_Committed_Target_Volume_9L__c = sumTargetVolume9L,
				ASI_CRM_Committed_Incentive_Value__c = sumIncentiveValue,
				ASI_CRM_Committed_Incentive_Value_Cash__c = sumIncentiveValueCash,
				ASI_CRM_Committed_Incentive_Value_FOC__c = sumIncentiveValueFOC,
				ASI_CRM_CommittedIncentiveValue_OIK__c = sumIncentiveValueOIK,
				ASI_CRM_CommittedIncentiveValue_Voucher__c = sumIncentiveValueVoucher,
				ASI_CRM_Committed_Incentive_Volume_9L__c = sumIncentiveVolume9L
			);
			list_promotionToUpdate.add(p);
        }
		
		if(list_promotionToUpdate.size()>0) update list_promotionToUpdate;
        
    }
    
    public void rollupActualToPromotion(List<ASI_HK_CRM_Promotion__c> PromotionList) {
        Map<Id, ASI_HK_CRM_Promotion__c> PromotionMap = new Map<Id, ASI_HK_CRM_Promotion__c>(PromotionList);
		Set<string> set_promotionId = new Set<string>();
		List<ASI_CRM_Promotion_Plan__c> list_promotionToUpdate = new List<ASI_CRM_Promotion_Plan__c>();
        
        for(ASI_HK_CRM_Promotion__c pd : PromotionList) {
            set_promotionId.add(pd.ASI_CRM_Promotion_Plan__c);
        }
        
        for(AggregateResult ar : retrievePromotionList(set_promotionId, 'AND ASI_HK_CRM_Status__c = :FINALAPPROVED ')) {
            String promotionId = String.valueOf(ar.get('promotionId'));
			Decimal sumRow = (Decimal)ar.get('sumRow');
            Decimal sumActualVolume9L = (Decimal)ar.get('sumActualVolume9L');
            Decimal sumActualValue = (Decimal)ar.get('sumActualValue');
            Decimal sumActualIncentiveValue = (Decimal)ar.get('sumActualIncentiveValue');
            Decimal sumActualIncentiveVolume9L = (Decimal)ar.get('sumActualIncentiveVolume9L');
            Decimal sumActualIncentiveValueCash = (Decimal)ar.get('sumActualIncentiveValueCash');
            Decimal sumActualIncentiveValueFOC = (Decimal)ar.get('sumActualIncentiveValueFOC');
            Decimal sumActualIncentiveValueOIK = (Decimal)ar.get('sumActualIncentiveValueOIK');
            Decimal sumActualIncentiveValueVoucher = (Decimal)ar.get('sumActualIncentiveValueVoucher');
			ASI_CRM_Promotion_Plan__c p = new ASI_CRM_Promotion_Plan__c(
				Id = promotionId,
				ASI_CRM_Total_Number_of_PromotionDetails__c = sumRow,
				ASI_CRM_Actual_Volume_9L__c = sumActualVolume9L,
				ASI_CRM_Actual_Value__c = sumActualValue,
				ASI_CRM_Actual_Incentive_Value__c = sumActualIncentiveValue,
				ASI_CRM_Actual_Incentive_Value_Cash__c = sumActualIncentiveValueCash,
				ASI_CRM_Actual_Incentive_Value_FOC__c = sumActualIncentiveValueFOC,
				ASI_CRM_ActualIncentiveValue_OtherinKind__c = sumActualIncentiveValueOIK,
				ASI_CRM_Actual_Incentive_Value_Voucher__c = sumActualIncentiveValueVoucher,
				ASI_CRM_Actual_Incentive_Volume_9L__c = sumActualIncentiveVolume9L
			);
			list_promotionToUpdate.add(p);
        }
		
		if(list_promotionToUpdate.size()>0) update list_promotionToUpdate;
        
    }
    
    private List<AggregateResult> retrievePromotionList(Set<string> set_promotionId, string whereClause) {
        String query = 'SELECT  '
                     + '	ASI_CRM_Promotion_Plan__c promotionId, '
                     + '	sum(ASI_CRM_PromotionDetails__c) sumRow, '
                     + '	sum(ASI_CRM_Total_Target_Value__c) sumTargetValue, '
                     + '	sum(ASI_CRM_Total_Target_Volume_9L__c) sumTargetVolume9L, '
                     + '	sum(ASI_CRM_Total_Incentive_Value__c) sumIncentiveValue, '
                     + '	sum(ASI_CRM_Total_Incentive_Value_Cash__c) sumIncentiveValueCash, '
                     + '	sum(ASI_CRM_Total_Incentive_Value_FOC__c) sumIncentiveValueFOC, '
                     + '	sum(ASI_CRM_TotalIncentiveValue_OtherinKind__c) sumIncentiveValueOIK, '
                     + '	sum(ASI_CRM_Total_Incentive_Value_Voucher__c) sumIncentiveValueVoucher, '
                     + '	sum(ASI_CRM_Total_Incentive_Volume_9L__c) sumIncentiveVolume9L, '
                     + '	sum(ASI_CRM_Total_Actual_Volume_9L__c) sumActualVolume9L, '
                     + '	sum(ASI_CRM_Total_Actual_Value__c) sumActualValue, '
                     + '	sum(ASI_CRM_Total_Actual_Incentive_Value__c) sumActualIncentiveValue, '
                     + '	sum(ASI_CRM_TotalActualIncentiveValueCash__c) sumActualIncentiveValueCash, '
                     + '	sum(ASI_CRM_TotalActualIncentiveValueFOC__c) sumActualIncentiveValueFOC, '
                     + '	sum(ASI_CRM_TotalActualIncentiveValueOIK__c) sumActualIncentiveValueOIK, '
                     + '	sum(ASI_CRM_TotalActualIncentiveValueVoucher__c) sumActualIncentiveValueVoucher, '
                     + '	sum(ASI_CRM_Total_Actual_Incentive_Volume_9L__c) sumActualIncentiveVolume9L '
                     + 'FROM ASI_HK_CRM_Promotion__c '
                     + 'WHERE ASI_CRM_Promotion_Plan__c in :set_promotionId ';
		if(whereClause != ''){
			query += whereClause;
		}             
		query        +=''
					 + 'Group by '
                     + '	ASI_CRM_Promotion_Plan__c '
                     + 'Order by ASI_CRM_Promotion_Plan__c ';
        
        return (List<AggregateResult>) Database.query(query);
    }
    
}