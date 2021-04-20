public with sharing class EUR_CRM_CriteriaSetControllerExt { 
	
	public List<EUR_CRM_Criteria_Threshold__c> criteriaThList {get;set;}
	public EUR_CRM_Criteria_Set__c criteriaSet {get;set;}
	
	public String cSetId;
	public String parentURL {get;set;}
	
	public EUR_CRM_CriteriaSetControllerExt (ApexPages.StandardController controller){
		cSetId = Apexpages.currentPage().getParameters().get('cid');
		parentURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+cSetId; 
		
		criteriaThList = new List<EUR_CRM_Criteria_Threshold__c>();
		criteriaThList  = [Select Id, EUR_CRM_Question__c from EUR_CRM_Criteria_Threshold__c
								where EUR_CRM_Criteria_Set__c =: cSetId 
									ORDER BY EUR_CRM_Sequence__c LIMIT 1000];
		system.debug('@@CriteriaThreshold' + criteriaThList.size());						
		
	}
	
	public pageReference saveCriteria(){
		Pagereference p = new PageReference(parentURL);
        return p;
	}
}