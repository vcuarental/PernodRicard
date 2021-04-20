public with sharing class ASI_CRM_CN_TP_PO_Add_TP_Ctrl {
	public String contractId;
	public Boolean isCanEdit {get; set;}
	public List<PlanWapper> finalPlans {get; set;}

    public ASI_CRM_CN_TP_PO_Add_TP_Ctrl(ApexPages.StandardController controller) {
        contractId = controller.getId();
        finalPlans = new List<PlanWapper>();
        isCanEdit = true;
        init();
    }

    public void init() {
    	Set<Id> oldTPIds = new Set<Id>();
    	ASI_TH_CRM_Contract__c contract = [SELECT ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Description__c,(SELECT Id FROM Plans__r) FROM ASI_TH_CRM_Contract__c WHERE Id = :contractId];
    	if (contract.ASI_CRM_CN_Status__c == 'Archived' || contract.ASI_CRM_CN_Status__c == 'Submitted') {
    		isCanEdit = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The PO is Archived or Submitted.'));
            return;
    	}
    	for (ASI_MFM_Plan__c plan : contract.Plans__r) {
    		oldTPIds.add(plan.Id);
    	}

    	List<ASI_MFM_Plan__c> finalPlanList = [SELECT Name, ASI_CRM_CN_TP_Customer__c, ASI_MFM_Status__c, ASI_CRM_CN_TP_KA_Banner__c, Owner.Name, 
                                                    CreatedDate, ASI_CRM_CN_TP_Estimated_Total_Amount__c, ASI_CRM_CN_TP_Total_Fixed_Cost__c 
                                              FROM ASI_MFM_Plan__c
						    				  WHERE ASI_CRM_CN_TP_Customer__c = :contract.ASI_CRM_CN_Outlet_WS__c 
						    				  AND RecordType.DeveloperName = 'ASI_CRM_CN_TP_Trade_Plan_Read_Only'
						    				  AND ASI_MFM_Status__c = 'Final' 
                                              AND Id NOT IN :oldTPIds
                                              AND ASI_CRM_CN_TP_Contract__c = null
                                              AND ASI_MFM_Remarks__c = :contract.ASI_CRM_CN_Description__c];
		for (ASI_MFM_Plan__c plan : finalPlanList) {
			PlanWapper planw = new PlanWapper();
			planw.selected = false;
			planw.plan = plan;
			finalPlans.add(planw);
		}
    }

    public PageReference saveTPs(){
    	System.debug(LoggingLevel.INFO, '*** saveTPs: ' );
    	List<ASI_MFM_Plan__c> updatePlans = new List<ASI_MFM_Plan__c>();
    	for (PlanWapper planw : finalPlans) {
    		if (planw.selected) {
    			planw.plan.ASI_CRM_CN_TP_Contract__c = contractId;
    			updatePlans.add(planw.plan);
    		}
    	}
    	if (!updatePlans.isEmpty()) {
    		update updatePlans;
            ASI_CRM_CN_TP_Plan_TriggerClass.POModification(new Set<Id>{contractId});
            ASI_TH_CRM_Contract__c con = new ASI_TH_CRM_Contract__c(Id = contractId);
            con.ASI_CRM_CN_Status__c = 'Archived';
            update con;
    	}
    	
    	return new PageReference('/' + contractId);
    }

    class PlanWapper{
    	public Boolean selected {get; set;}
    	public ASI_MFM_Plan__c plan {get; set;}
    }
}