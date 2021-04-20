@isTest
private class ASI_MFM_CN_RepackApproveExtensionTest {
    
    static testMethod void testMethod1() {
    	ASI_MFM_POSM_Return_Request__c rq = new ASI_MFM_POSM_Return_Request__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        ASI_MFM_CN_RepackApproveExtension extens = new ASI_MFM_CN_RepackApproveExtension(sc);
        extens.init();
    }
}