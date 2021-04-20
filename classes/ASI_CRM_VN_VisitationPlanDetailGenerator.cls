/*********************************************************************************
 * Name:ASI_CRM_VN_VisitationPlanDetailGenerator
 * Description: copied and modified from SG CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 05/10/2015         Laputa: Hank            Created
*********************************************************************************/
public with sharing class ASI_CRM_VN_VisitationPlanDetailGenerator {
	public static final Date DEF_VALUE_VISIT_DATE = System.today().addDays(1);
	public static final String ASI_VN_CRM_VISITATIONPLAN_DETAIL_RECORDTYPE = 'ASI_CRM_VN_Visitation_Plan_Detail';
	public static final String ASI_VN_CRM_OFFTRADE_VISITATIONPLAN_DETAIL_RECORDTYPE = 'ASI_CRM_VN_OffTrade_Visitation_Plan_Detail';
  
	@TestVisible
	private Id VN_RecordtypeId {
		get
    		{ return [Select Id from Recordtype where Developername=:ASI_VN_CRM_VISITATIONPLAN_DETAIL_RECORDTYPE].Id;
    	}
		private set; 
  	}
    
	private Id VN_OffTradeRecordtypeId {
		get {
    		return [Select Id from Recordtype where Developername =: ASI_VN_CRM_OFFTRADE_VISITATIONPLAN_DETAIL_RECORDTYPE].Id;
    	}
    	private set;
  	}

	public ASI_HK_CRM_Visitation_Plan_Detail__c generateBasicVisitationPlanDetail(ASI_HK_CRM_Visitation_Plan__c visitPlan, ASI_CRM_AccountsAdditionalField__c acct, Date visitDate) {
  		ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlan = new ASI_HK_CRM_Visitation_Plan_Detail__c();
    	visitationPlan.ASI_HK_CRM_Visitation_Plan__c = visitPlan.Id;
    	visitationPlan.ASI_CRM_MY_Customer__c = acct.Id;  
        visitationPlan.ASI_HK_CRM_Visit_Date__c = visitDate;
    	visitationPlan.ASI_CRM_Purpose_of_Visit__c = 'Normal Visit';
      
      	if(acct.Recordtype.Developername == 'ASI_CRM_VN_Off_Trade_Outlet') {
      		visitationPlan.recordtypeId = VN_OffTradeRecordtypeId;
      	} else {
      		visitationPlan.recordtypeId = VN_RecordtypeId;
      	}
      
		return visitationPlan;
  	}

	public ASI_HK_CRM_Visitation_Plan_Detail__c generateVisitationPlanDetail(ASI_HK_CRM_Visitation_Plan__c visitPlan, ASI_CRM_AccountsAdditionalField__c acct, Date visitDate) {
		return generateBasicVisitationPlanDetail(visitPlan, acct, visitDate);
	}

}