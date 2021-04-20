@isTest
private class ASI_MFM_CN_RepackCheckAutoRejectBchTest {
    @testSetup
    static void preTest() {
    	User admin = ASI_CRM_CN_TP_TestUtils.generateAdminUser('testAdmin@Pernod.com');
        System.runAs(admin){
        	Id REPACK_RT_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_Repack_Request_Form');
        	ASI_MFM_POSM_Return_Request__c repack = new ASI_MFM_POSM_Return_Request__c();
        	repack.RecordTypeId = REPACK_RT_ID;
        	repack.ASI_MFM_Request_Status__c = 'Submitted';
        	repack.ASI_MFM_Repack_SYS_Submitted_Time__c = System.now().addDays(-6);
        	insert repack;
            
        }
    }

    static testMethod void testMethod1() {
    	Database.executebatch(new ASI_MFM_CN_RepackCheckAutoRejectBatch());    
    }
}