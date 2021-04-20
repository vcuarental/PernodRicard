/*********************************************************************************
 * Name:ASI_CRM_SG_PromotionPlanService
 * Description: Service Class for SG Promotion Plan
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 03/04/2018       Hugo Cheung             Created
*********************************************************************************/
public class ASI_CRM_SG_PromotionPlanService {
    
    private static ASI_CRM_SG_PromotionPlanService PROMOTION_PLAN_SERVICE = new ASI_CRM_SG_PromotionPlanService();
    
	//Email Template Id
    private static final Id CREATE_EMAIL_TEMPLATE_ID = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ASI_CRM_SG_PromotionPlanCreateTemp'].Id;
    private static final Id APPROVED_EMAIL_TEMPLATE_ID = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ASI_CRM_SG_PromotionPlanApprovedTemp'].Id;
    private static final Id REJECTED_EMAIL_TEMPLATE_ID = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ASI_CRM_SG_PromotionPlanRejectedTemp'].Id;
	private final static String RECORDTYPEID_PROMOTION = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Promotion__cASI_CRM_SG_Ad_hoc_Trade_Promotion');
	private final static String RECORDTYPEID_PROMOTIONREADONLY = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Promotion__cASI_CRM_SG_Ad_hoc_Trade_Promotion_Read_Only');
	private final static String RECORDTYPEID_PROMOTIONPLAN_OUTLET = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Plan__cASI_CRM_SG_Outlet_Promotion_Plan');
	private final static String RECORDTYPEID_PROMOTIONPLAN_OUTLETREADONLY = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Plan__cASI_CRM_SG_Outlet_Promotion_Plan_Read_Only');
	private final static String RECORDTYPEID_PROMOTIONPLAN_WHOLESALER = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Plan__cASI_CRM_SG_Wholesaler_Promotion_Plan');
	private final static String RECORDTYPEID_PROMOTIONPLAN_WHOLESALERREADONLY = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Plan__cASI_CRM_SG_Wholesaler_Promotion_Plan_Read_Only');
	
	private final static map<string, string> MAP_ROLLBACK_PROMOTIONRECORDTYPE = new map<string, string>{
		RECORDTYPEID_PROMOTIONREADONLY => RECORDTYPEID_PROMOTION
	};
	
	private final static map<string, string> MAP_PROMOTIONPLANRECORDTYPE = new map<string, string>{
		RECORDTYPEID_PROMOTIONPLAN_OUTLET => RECORDTYPEID_PROMOTIONPLAN_OUTLETREADONLY,
		RECORDTYPEID_PROMOTIONPLAN_WHOLESALER => RECORDTYPEID_PROMOTIONPLAN_WHOLESALERREADONLY
	};
	
	// Final Approved status
	private static final String FINAL_APPROVED = 'Final Approved';
	private static final String REJECTED = 'Rejected';
    
    //Not Allow to create instance
    private ASI_CRM_SG_PromotionPlanService() { 
    }
    
    public static ASI_CRM_SG_PromotionPlanService getInstance() {
		return PROMOTION_PLAN_SERVICE;
	}
	
	public void rejectAllPromotions(List<ASI_CRM_Promotion_Plan__c> promotionPlanList){
		Map<Id, ASI_CRM_Promotion_Plan__c> promotionPlanMap = new Map<Id, ASI_CRM_Promotion_Plan__c>(promotionPlanList);
		List<ASI_HK_CRM_Promotion__c> list_promotionToUpdate = new List<ASI_HK_CRM_Promotion__c>();
		String whereClause = '';
		
        Map<Id, Set<Id>> promotionOwnerIdMap = new Map<Id, Set<Id>>();
        Set<Id> allOwnerIdSet = new Set<Id>();
		for(ASI_HK_CRM_Promotion__c promotion : retrievePromotionList(promotionPlanMap.keySet(), whereClause)){
			promotion.ASI_HK_CRM_Status__c = REJECTED;
			promotion.recordtypeid = RECORDTYPEID_PROMOTION;
			list_promotionToUpdate.add(promotion);
			
            Set<Id> ownerIdSet = promotionOwnerIdMap.containsKey(promotion.ASI_CRM_Promotion_Plan__c)
                               ? promotionOwnerIdMap.get(promotion.ASI_CRM_Promotion_Plan__c)
                               : new Set<Id>();
            
			ownerIdSet.add(promotion.OwnerId);
            promotionOwnerIdMap.put(promotion.ASI_CRM_Promotion_Plan__c, ownerIdSet);
            
            allOwnerIdSet.add(promotion.OwnerId);
		}
		
		if(list_promotionToUpdate.size() > 0) update list_promotionToUpdate;
        if(promotionOwnerIdMap != null) commonSendEmail(promotionPlanMap, promotionOwnerIdMap, allOwnerIdSet, REJECTED_EMAIL_TEMPLATE_ID);
	}

	public void finalApproveAllPromotions(List<ASI_CRM_Promotion_Plan__c> promotionPlanList){
		Map<Id, ASI_CRM_Promotion_Plan__c> promotionPlanMap = new Map<Id, ASI_CRM_Promotion_Plan__c>(promotionPlanList);
		List<ASI_HK_CRM_Promotion__c> list_promotionToUpdate = new List<ASI_HK_CRM_Promotion__c>();
		String whereClause = '';
		
		for(ASI_HK_CRM_Promotion__c promotion : retrievePromotionList(promotionPlanMap.keySet(), whereClause)){
			promotion.ASI_HK_CRM_Status__c = FINAL_APPROVED;
            promotion.RecordTypeId = RECORDTYPEID_PROMOTIONREADONLY;
			list_promotionToUpdate.add(promotion);
		}
		
		if(list_promotionToUpdate.size() > 0) update list_promotionToUpdate;
	}

    public void sendEmailToPromotionOwner(List<ASI_CRM_Promotion_Plan__c> promotionPlanList) {
        Map<Id, ASI_CRM_Promotion_Plan__c> promotionPlanMap = new Map<Id, ASI_CRM_Promotion_Plan__c>(promotionPlanList);
        
        for(ASI_CRM_Promotion_Plan__c i : promotionPlanList){
            i.ASI_CRM_SYS_Send_Email__c = false;
            i.recordtypeid = MAP_PROMOTIONPLANRECORDTYPE.get(i.recordtypeid);
        }
        
        Map<Id, Set<Id>> promotionOwnerIdMap = new Map<Id, Set<Id>>();
        Set<Id> allOwnerIdSet = new Set<Id>();
        for(ASI_HK_CRM_Promotion__c promotion : retrievePromotionList(promotionPlanMap.keySet(),'')) {
            Set<Id> ownerIdSet = promotionOwnerIdMap.containsKey(promotion.ASI_CRM_Promotion_Plan__c)
                               ? promotionOwnerIdMap.get(promotion.ASI_CRM_Promotion_Plan__c)
                               : new Set<Id>();
            
			ownerIdSet.add(promotion.OwnerId);
            promotionOwnerIdMap.put(promotion.ASI_CRM_Promotion_Plan__c, ownerIdSet);
            
            allOwnerIdSet.add(promotion.OwnerId);
        }
        if(promotionOwnerIdMap != null) commonSendEmail(promotionPlanMap, promotionOwnerIdMap, allOwnerIdSet, CREATE_EMAIL_TEMPLATE_ID);
    }
	
	private void commonSendEmail(Map<Id, ASI_CRM_Promotion_Plan__c> promotionPlanMap, Map<Id, Set<Id>> promotionOwnerIdMap, Set<Id> allOwnerIdSet, String emailTemplate){
		
       	Map<Id, User> userMap = new Map<Id, User>(retrieveUserList(allOwnerIdSet));
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
       	for(ASI_CRM_Promotion_Plan__c promotionPlan : promotionPlanMap.values()) {
            List<String> emailList = new List<String>();
            for(Id ownerId : promotionOwnerIdMap.get(promotionPlan.Id)) {
                emailList.add(userMap.get(ownerId).Email);
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = emailList;
            mail.saveAsActivity = false;
            mail.setTemplateID(emailTemplate);
            mail.setWhatId(promotionPlan.Id);
            mail.setTargetObjectId(promotionPlan.OwnerId);
            mailList.add(mail);
        }
        Messaging.sendEmail(mailList);
	}

    // Create a promotion where Owner is promotion plan Owner
    public void createPromotionByUser(List<ASI_CRM_Promotion_Plan__c> promotionPlans){
        if (promotionPlans.isEmpty()) {
            return;
        }

        List<Id> ownerIds = new List<Id>();
        for (ASI_CRM_Promotion_Plan__c plan : promotionPlans) {
            ownerIds.add(plan.OwnerId);
        }
        Map<Id, User> idToUserMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :ownerIds]);

        List<ASI_HK_CRM_Promotion__c> newPromotions = new List<ASI_HK_CRM_Promotion__c>();
        for (ASI_CRM_Promotion_Plan__c promotionPlan : promotionPlans) {
            ASI_HK_CRM_Promotion__c newPromotion = new ASI_HK_CRM_Promotion__c(
                Name = promotionPlan.Name/* + ' ' + (idToUserMap.containsKey(promotionPlan.OwnerId) ? idToUserMap.get(promotionPlan.OwnerId).Name : '')*/,
                ASI_CRM_Promotion_Plan__c = promotionPlan.Id,
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Promotion__cASI_CRM_SG_Ad_hoc_Trade_Promotion'),
                ASI_HK_CRM_Status__c = 'Draft',
                OwnerId = promotionPlan.OwnerId
            );

            newPromotions.add(newPromotion);
        }

        insert newPromotions;
    }
    
    private List<ASI_HK_CRM_Promotion__c> retrievePromotionList(Set<Id> promotionPlanIdSet, String whereClause) {
        String query = 'SELECT Id, OwnerId, ASI_CRM_Promotion_Plan__c, recordtypeid '
                     + 'FROM ASI_HK_CRM_Promotion__c '
                     + 'WHERE ASI_CRM_Promotion_Plan__c in :promotionPlanIdSet '
					 + whereClause;
        
        return (List<ASI_HK_CRM_Promotion__c>) Database.query(query);
    }
    
    private List<User> retrieveUserList(Set<Id> userIdSet) {
        String query = 'SELECT Id, Email '
                     + 'FROM User '
                     + 'WHERE Id in :userIdSet ';
        
        return (List<User>) Database.query(query);
    }
}