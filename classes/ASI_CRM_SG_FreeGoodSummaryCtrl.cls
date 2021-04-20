/*********************************************************************************
 * Name: ASI_CRM_SG_FreeGoodSummaryCtrl
 * Description: Controller class for ASI_CRM_SG_PaymentSummaryPage 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-04-15    	Laputa: Vincent      	Create
 */


public without sharing class ASI_CRM_SG_FreeGoodSummaryCtrl extends ASI_CRM_SG_PageControllerBase {
    
	public set<string> set_promotionName {get;set;}
	public list<ASI_FOC_Request_Item__c> childs {get;set;}
	public integer promotionSize {get;set;}
	
    public ASI_CRM_SG_FreeGoodSummaryCtrl(ApexPages.StandardController standardController){
		set_promotionName = new set<string>();
		childs = getChilds(standardController.getId());
		set_promotionName = getPromotionName(childs);
		promotionSize = set_promotionName.size();
	}
	
	private list<ASI_FOC_Request_Item__c> getChilds(String headerId){
		return [
			select ASI_CRM_Promotion_Detail__c, ASI_CRM_Promotion_Detail__r.ASI_HK_CRM_Promotion__r.ASI_CRM_Promotion_Plan__r.Name
			from ASI_FOC_Request_Item__c
			where
			ASI_FOC_Request_Order__c = :headerId
		];
	}
	
	private set<string> getPromotionName(list<ASI_FOC_Request_Item__c> childs){
		set<string> s = new set<string>();
		for(ASI_FOC_Request_Item__c l : childs){
			if(l.ASI_CRM_Promotion_Detail__c != null){
				s.add(l.ASI_CRM_Promotion_Detail__r.ASI_HK_CRM_Promotion__r.ASI_CRM_Promotion_Plan__r.Name);
			}
		}
		return s;
	}
	
}