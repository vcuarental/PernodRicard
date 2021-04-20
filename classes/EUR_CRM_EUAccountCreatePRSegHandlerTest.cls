@isTest
private class  EUR_CRM_EUAccountCreatePRSegHandlerTest {

    static testMethod void testCreatingPRSeg() {
        EUR_CRM_Account__c euAcct = (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_DK_On_Trade')).get(0);// new EUR_CRM_Account__c(name='test eu account');
        insert euAcct;
        System.assertEquals(1, [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :euAcct.Id].size());
    }

}