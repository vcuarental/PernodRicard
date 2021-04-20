public with sharing class GRP_CC_UpdateChainAccountResponsibleCtrl  {
    private ApexPages.StandardSetController standardController; 

    public String GRP_CC_ChainAccount_PR_Resp{get;set;}
	public GRP_CC_ChainAccount__c chainAccount = new GRP_CC_ChainAccount__c();
	public Integer nbSelectedCA{get;set;}
	public String titleLabel{get;set;}
	public String subtitleLabel{get;set;}
    
    public GRP_CC_UpdateChainAccountResponsibleCtrl(ApexPages.StandardSetController stdController)
    {
        this.standardController = stdController;
		this.chainAccount = (GRP_CC_ChainAccount__c)stdController.getRecord();
    }

	public GRP_CC_ChainAccount__c getchainAccount()
    {
        return this.chainAccount;
    }
	
    public pageReference updateChainAccounts() {  
		PageReference returnPage = null;	
        
		// Get the selected records 
		System.debug('updateChainAccounts() - chainAccount.GRP_CC_PRResponsible__c : '+ chainAccount.GRP_CC_PRResponsible__c);
        List<GRP_CC_ChainAccount__c> selectedChainAccounts = (List<GRP_CC_ChainAccount__c>) standardController.getSelected();
		System.debug('updateChainAccounts() - selectedChainAccounts.size() : '+ selectedChainAccounts.size());
        System.debug('updateChainAccounts() - selectedChainAccounts : '+ selectedChainAccounts);
		if (selectedChainAccounts.size() == 0) {
			this.nbSelectedCA = 0;
			// Display a specif message in case of no Chain Account selected
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You need to select a Chain Account first.'));		
			//returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
		} else {
			this.nbSelectedCA = selectedChainAccounts.size();
			if (this.nbSelectedCA == 1) {			
				String chainAccId = selectedChainAccounts[0].Id; 
				GRP_CC_ChainAccount__c[] chainAcc = [SELECT Name FROM GRP_CC_ChainAccount__c WHERE Id=:chainAccId LIMIT 1];
				this.titleLabel = 'PR Responsible Edit';
				this.subtitleLabel = chainAcc[0].Name;
			} else {
				this.titleLabel = '';
				this.subtitleLabel = 'Mass PR Responsible Edit';
			}
			// Mandatory fields : PR Responsible, PR Responsible Manager, Country, Region, Chain Account Responsible Email must be set for Save action otherwise there will be no change for the relative(s) Chain Account(s)	
			//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Mandatory fields : PR Responsible, PR Responsible Manager, Country, Region, Chain Account Responsible Email must be set for Save action otherwise there will be no change for the relative(s) Chain Account(s)'));			
			for(GRP_CC_ChainAccount__c selectedChainAccount : selectedChainAccounts)
			{
                System.debug('updateChainAccounts() - selectedChainAccount : '+ selectedChainAccount);
				if ((chainAccount.GRP_CC_PRResponsible__c != null) && (chainAccount.GRP_CC_PRResponsible__c != '')) {
					selectedChainAccount.GRP_CC_PRResponsible__c = chainAccount.GRP_CC_PRResponsible__c;
				}
			}       
		}
        return returnPage;        
    }
	
	public PageReference saveChainAccounts()
    {       
        // Call StandardSetController 'save' method to update 
        return standardController.save();   
    }
    
    public PageReference cancelUpdateChainAccounts()
    {       
        // Call StandardSetController 'cancel' method 
        return standardController.cancel();  
        //PageReference returnPage;		
        //returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        //return returnPage;
    }
}