public without sharing class ASI_MFM_CN_RepackApproveExtension {
	public ASI_MFM_POSM_Return_Request__c rq;
	public Boolean isAccessed {get; set;}
    public ASI_MFM_CN_RepackApproveExtension(ApexPages.StandardController con) {
        rq = (ASI_MFM_POSM_Return_Request__c)con.getRecord();
        isAccessed = true;
    }

    public void init() {
        Profile pro = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
    	if (pro.Name != 'ASI_CRM_CN_Logistic_User' && pro.Name != 'ASI CN IT System Administrator') {
    		Apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'You can not access the page.'));
    		isAccessed = false;
    	}
    }
    public PageReference saveRepack() {
        update rq;
        return new PageReference('/' + rq.Id);
    }
}