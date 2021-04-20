public class EUR_CRM_DE_ContractBuilderRedirectCtrl {
	EUR_CRM_Contract__c contract;

	public EUR_CRM_DE_ContractBuilderRedirectCtrl(ApexPages.StandardController stdController) {
		contract = (EUR_CRM_Contract__c) stdController.getRecord();
	}

	public PageReference redirect() {
		System.debug(this.contract);

		PageReference pageRef = new PageReference('/apex/EUR_CRM_DE_ContractBuilderPage?id=' + this.contract.Id);
		pageRef.setRedirect(true);

		return pageRef;
	}
}