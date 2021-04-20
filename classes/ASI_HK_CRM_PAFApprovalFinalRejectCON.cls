public with sharing class ASI_HK_CRM_PAFApprovalFinalRejectCON {
	
	private static final String STATUS_FINAL_REJECT = 'Draft';
	private static final Set<String> STATUS_ALLOW_FINAL_REJECT = new Set<String> {
		'FM Approved'
		, 'MKTD Approved'
		, 'MD Final'
		, 'Approve Final'
        , 'FD Approved'
	};
	private static final Set<String> PERMIT_PROFILE_NAMES = new Set<String> {
		'ASI HK CRM Sales Admin'
		, 'ASI HK CRM System Administrator'
		, 'System Administrator'
		, 'ASI Vendor Support System Administrator'
		, 'ASI System Administrator',
            'ASI HK CRM Approver'
	};
	public ID pafId { get; private set; }
	private ASI_HK_CRM_Pre_Approval_Form__c paf;
	Set<ID> permitProfileIds;
	
	public ASI_HK_CRM_PAFApprovalFinalRejectCON(ApexPages.StandardController stdCon) {
		this.pafId = stdCon.getId();
		if (this.pafId != null) {
			paf = [SELECT Id, ASI_HK_CRM_PAF_Status__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE Id = :pafId];
			List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN :PERMIT_PROFILE_NAMES];
			permitProfileIds = new Set<ID>();
			for (Profile p : profiles) {
				permitProfileIds.add(p.Id);
			}
		}
	}
	
	public PageReference doFinalReject() {
		PageReference redirectPage = null;
		if (paf == null) {
			showPageError('Pre-Approval Form not found');
		} else if (!permitProfileIds.contains(UserInfo.getProfileId())) {
			showPageError('You are not allowed to reject the record');
		} else if (!STATUS_ALLOW_FINAL_REJECT.contains(paf.ASI_HK_CRM_PAF_Status__c)) {
			showPageError('The current approval stage cannot be rejected');
		} else {
			paf.ASI_HK_CRM_PAF_Status__c = STATUS_FINAL_REJECT;
			try {
				update paf;
			} catch (Exception e) {
				showPageError(e.getMessage());
			}
		}
		return redirectPage;
	}
	
	private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
	private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }
}