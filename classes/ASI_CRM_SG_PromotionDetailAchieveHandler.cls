/*********************************************************************************
 * Name: ASI_CRM_SG_PromotionDetailAchieveHandler
 * Description: Handler to reset all the achievement of promotion detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/04/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_SG_PromotionDetailAchieveHandler {
    private ASI_CRM_SG_PromotionDetailAchieveHandler() {
    }
    
    public static List<ASI_CRM_Promotion_Detail_Achievement__c> resetAchievementList(Map<Id, Date> promotionDetailIdDateMap, Set<Integer> monthSet, Set<Integer> yearSet) {
        List<ASI_CRM_Promotion_Detail_Achievement__c> promotionDetailAchievementList = new List<ASI_CRM_Promotion_Detail_Achievement__c>();
    	for(ASI_CRM_Promotion_Detail_Achievement__c promotionDetailAchievement : retrievePromotionAchievementList(promotionDetailIdDateMap.keySet(), monthSet, yearSet)) {
            Date targetDate = promotionDetailIdDateMap.get(promotionDetailAchievement.ASI_CRM_Promotion_Detail__c);
            
            if(targetDate.month() == promotionDetailAchievement.ASI_CRM_Achievement_Month__c && 
               targetDate.year() == promotionDetailAchievement.ASI_CRM_Achievement_Year__c) {
                promotionDetailAchievement.ASI_CRM_IssuedConsumption_9L__c          = null;
                promotionDetailAchievement.ASI_CRM_Carry_Over_Promotional_Bottle__c = null;
                promotionDetailAchievement.ASI_CRM_Carry_Over_Additional_Bottle__c  = null;

                promotionDetailAchievementList.add(promotionDetailAchievement);
            }
        }
        return promotionDetailAchievementList;
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private static List<ASI_CRM_Promotion_Detail_Achievement__c> retrievePromotionAchievementList(Set<Id> promotionDetailIdSet, Set<Integer> monthSet, Set<Integer> yearSet) {
        String query = 'SELECT Id, ASI_CRM_IssuedConsumption_9L__c, ASI_CRM_Carry_Over_Promotional_Bottle__c, ASI_CRM_Carry_Over_Additional_Bottle__c, '
                     + 'ASI_CRM_Achievement_Month__c, ASI_CRM_Achievement_Year__c, ASI_CRM_Promotion_Detail__c '
                     + 'FROM ASI_CRM_Promotion_Detail_Achievement__c '
                     + 'WHERE ASI_CRM_Promotion_Detail__c in :promotionDetailIdSet '
                     + 'AND ASI_CRM_Achievement_Month__c in :monthSet ' 
                     + 'AND ASI_CRM_Achievement_Year__c in :yearSet ';
        
        return (List<ASI_CRM_Promotion_Detail_Achievement__c>) Database.query(query);
    }
}