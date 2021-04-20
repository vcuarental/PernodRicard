/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 29/11/2016
*
********************************************************************************/
public with sharing class LAT_VFC_CloseCase {
	
	public String caseId								{get;set;}
	public LAT_Case__c latCase      					{get;set;}
	public LAT_CaseSolution__c latCaseSolution          {get;set;}
	public LAT_Solution__c latSolution          		{get;set;}


	public LAT_VFC_CloseCase(ApexPages.StandardController controller ) {

		this.caseId = ApexPages.currentPage().getParameters().get('id');
		this.latCase = [SELECT LAT_Account__r.name, LAT_Status__c, LAT_Type__c, LAT_Reason__c, LAT_ReasonForNotApproved__c, LAT_Comments__c FROM LAT_Case__c WHERE id =: caseId ];
		this.latCase.LAT_Status__c = 'Fechado e resolvido';
		this.latSolution = new LAT_Solution__c();
		this.latCaseSolution = new LAT_CaseSolution__c();
	}

	public PageReference closeCase() {
		if (this.latSolution.LAT_SolutionName__c !=null && this.latSolution.LAT_SolutionName__c !=''){
				insert this.latSolution;
				this.latCaseSolution.LAT_Case__c = this.latCase.id;
				this.latCaseSolution.LAT_Solution__c = this.latSolution.id;
				insert this.latCaseSolution;
				
		} else {
			if (this.latSolution.LAT_SolutionNote__c !=null && this.latSolution.LAT_SolutionNote__c !='' ){
				this.latSolution.LAT_SolutionName__c.addError('Required Field');
				return null;
			} 
		}
		try {
			update this.latCase;
		} catch (Exception e){
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMsg);
            return null;
			
		}

		PageReference pageRef = new PageReference('/' + this.latCase.id);
		pageRef.setRedirect(true);
		return pageRef;


	}
}