public with sharing class ASI_HK_CRM_PAFConfirmByCustomerCON {
	
	private static final String CONFIRM_STATUS = 'Confirmed with Customer';
	private static final Set<String> ALLOW_STATUS = new Set<String>{
		'FM Approved'
		, 'MKTD Approved'
		, 'MD Final'
		, 'Approve Final'
	};
	
	public ID pafId { get; set; }
	private ASI_HK_CRM_Pre_Approval_Form__c paf;
	
	public ASI_HK_CRM_PAFConfirmByCustomerCON(ApexPages.StandardController stdCon) {
		this.pafId = stdCon.getId();
		if (pafId != null)
			this.paf = [SELECT Id, ASI_HK_CRM_PAF_Status__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE Id = :pafId];
	}
	
	public PageReference confirm() {
		PageReference resultPage = null;
		try {
			if (this.paf == null)
				throw new ASI_HK_CRM_CustomException('Record not found');
			else if (!ALLOW_STATUS.contains(paf.ASI_HK_CRM_PAF_Status__c))
				throw new ASI_HK_CRM_CustomException('The current status is not allowed to confirm');
			paf.ASI_HK_CRM_PAF_Status__c = CONFIRM_STATUS;
			update paf;
			return new PageReference('/' + paf.Id);
		} catch (DmlException dmle) {
			Integer numOfErr = dmle.getNumDml();
			for (Integer i = 0; i < numOfErr; i++)
				paf.addError(dmle.getDmlMessage(i));
		} catch (Exception e) {
			paf.addError(e.getMessage());
		}
		return null;
	}
}