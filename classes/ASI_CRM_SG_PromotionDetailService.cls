/*********************************************************************************
 * Name:ASI_CRM_SG_PromotionDetailService
 * Description: Service Class for SG Promotion Detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-04-06       Vincent Lam             Created
*********************************************************************************/
public class ASI_CRM_SG_PromotionDetailService {
    
    private static ASI_CRM_SG_PromotionDetailService PROMOTION_DETAIL_SERVICE = new ASI_CRM_SG_PromotionDetailService();
    
    //Not Allow to create instance
    private ASI_CRM_SG_PromotionDetailService() { 
    }
    
    public static ASI_CRM_SG_PromotionDetailService getInstance() {
    return PROMOTION_DETAIL_SERVICE;
  }

    public void rollupToPromotion(List<ASI_HK_CRM_Promotion_Detail__c> promotionDetailList) {
        Map<Id, ASI_HK_CRM_Promotion_Detail__c> promotionDetailMap = new Map<Id, ASI_HK_CRM_Promotion_Detail__c>(promotionDetailList);
		Set<string> set_promotionId = new Set<string>();
		List<ASI_HK_CRM_Promotion__c> list_promotionToUpdate = new List<ASI_HK_CRM_Promotion__c>();
        
        for(ASI_HK_CRM_Promotion_Detail__c pd : promotionDetailList) {
            set_promotionId.add(pd.ASI_HK_CRM_Promotion__c);
        }
        
        for(AggregateResult ar : retrievePromotionList(set_promotionId)) {
            String promotionId = String.valueOf(ar.get('promotionId'));
            Decimal sumTargetValue = (Decimal)ar.get('sumTargetValue');
            Decimal sumTargetVolume9L = (Decimal)ar.get('sumTargetVolume9L');
            Decimal sumIncentiveValue = (Decimal)ar.get('sumIncentiveValue');
            Decimal sumIncentiveValueCash = (Decimal)ar.get('sumIncentiveValueCash');
            Decimal sumIncentiveValueFOC = (Decimal)ar.get('sumIncentiveValueFOC');
            Decimal sumIncentiveValueOIK = (Decimal)ar.get('sumIncentiveValueOIK');
            Decimal sumIncentiveValueVoucher = (Decimal)ar.get('sumIncentiveValueVoucher');
            Decimal sumIncentiveVolume9L = (Decimal)ar.get('sumIncentiveVolume9L');
            Decimal sumActualVolume9L = (Decimal)ar.get('sumActualVolume9L');
            Decimal sumActualValue = (Decimal)ar.get('sumActualValue');
            Decimal sumActualIncentiveValue = (Decimal)ar.get('sumActualIncentiveValue');
            Decimal sumActualIncentiveValueCash = (Decimal)ar.get('sumActualIncentiveValueCash');
            Decimal sumActualIncentiveValueFOC = (Decimal)ar.get('sumActualIncentiveValueFOC');
            Decimal sumActualIncentiveValueOIK = (Decimal)ar.get('sumActualIncentiveValueOIK');
            Decimal sumActualIncentiveValueVoucher = (Decimal)ar.get('sumActualIncentiveValueVoucher');
            Decimal sumActualIncentiveVolume9L = (Decimal)ar.get('sumActualIncentiveVolume9L');
			ASI_HK_CRM_Promotion__c p = new ASI_HK_CRM_Promotion__c(
				Id = promotionId,
				ASI_CRM_Total_Target_Value__c = sumTargetValue,
				ASI_CRM_Total_Target_Volume_9L__c = sumTargetVolume9L,
				ASI_CRM_Total_Incentive_Value__c = sumIncentiveValue,
				ASI_CRM_Total_Incentive_Value_Cash__c = sumIncentiveValueCash,
				ASI_CRM_Total_Incentive_Value_FOC__c = sumIncentiveValueFOC,
				ASI_CRM_TotalIncentiveValue_OtherinKind__c = sumIncentiveValueOIK,
				ASI_CRM_Total_Incentive_Value_Voucher__c = sumIncentiveValueVoucher,
				ASI_CRM_Total_Incentive_Volume_9L__c = sumIncentiveVolume9L,
				ASI_CRM_Total_Actual_Volume_9L__c = sumActualVolume9L,
				ASI_CRM_Total_Actual_Value__c = sumActualValue,
				ASI_CRM_Total_Actual_Incentive_Value__c = sumActualIncentiveValue,
				ASI_CRM_TotalActualIncentiveValueCash__c = sumActualIncentiveValueCash,
				ASI_CRM_TotalActualIncentiveValueFOC__c = sumActualIncentiveValueFOC,
				ASI_CRM_TotalActualIncentiveValueOIK__c = sumActualIncentiveValueOIK,
				ASI_CRM_TotalActualIncentiveValueVoucher__c = sumActualIncentiveValueVoucher,
				ASI_CRM_Total_Actual_Incentive_Volume_9L__c = sumActualIncentiveVolume9L
			);
			list_promotionToUpdate.add(p);
        }
		
		if(list_promotionToUpdate.size()>0) update list_promotionToUpdate;
        
    }
    
    private List<AggregateResult> retrievePromotionList(Set<string> set_promotionId) {
        String query = 'SELECT  '
                     + '	ASI_HK_CRM_Promotion__c promotionId, '
                     + '	sum(ASI_CRM_Target_Value__c) sumTargetValue, '
                     + '	sum(ASI_CRM_Target_Volume_9L__c) sumTargetVolume9L, '
                     + '	sum(ASI_CRM_Incentive_Value__c) sumIncentiveValue, '
                     + '	sum(ASI_CRM_Incentive_Value_Cash__c) sumIncentiveValueCash, '
                     + '	sum(ASI_CRM_Incentive_Value_FOC__c) sumIncentiveValueFOC, '
                     + '	sum(ASI_CRM_Incentive_Value_Other_in_Kind__c) sumIncentiveValueOIK, '
                     + '	sum(ASI_CRM_Incentive_Value_Voucher__c) sumIncentiveValueVoucher, '
                     + '	sum(ASI_CRM_Incentive_Volume_9L__c) sumIncentiveVolume9L, '
                     + '	sum(ASI_CRM_ActualConsumption_9L__c) sumActualVolume9L, '
                     + '	sum(ASI_CRM_Actual_Consumption_Value__c) sumActualValue, '
                     + '	sum(ASI_CRM_Actual_Incentive_Value__c) sumActualIncentiveValue, '
                     + '	sum(ASI_CRM_Actual_Incentive_Value_Cash__c) sumActualIncentiveValueCash, '
                     + '	sum(ASI_CRM_Actual_Incentive_Value_FOC__c) sumActualIncentiveValueFOC, '
                     + '	sum(ASI_CRM_Actual_Incentive_Value_OIK__c) sumActualIncentiveValueOIK, '
                     + '	sum(ASI_CRM_Actual_Incentive_Value_Voucher__c) sumActualIncentiveValueVoucher, '
                     + '	sum(ASI_CRM_Actual_Incentive_Volume_9L__c) sumActualIncentiveVolume9L '
                     + 'FROM ASI_HK_CRM_Promotion_Detail__c '
                     + 'WHERE ASI_HK_CRM_Promotion__c in :set_promotionId '
                     + 'Group by '
                     + '	ASI_HK_CRM_Promotion__c '
                     + 'Order by ASI_HK_CRM_Promotion__c ';
        
        return (List<AggregateResult>) Database.query(query);
    }
    
}