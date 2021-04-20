/**
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_VolumeTrackerContractVol Class.
  @Author:      IPC
  @History:     JUN.19.2014 - Created
 */
@isTest
private class EUR_CRM_VolumeTrackerContractVol_Test {
    private static EUR_CRM_Quality__c brandQuality;
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_GB_Volume_Tracker__c volumeTracker;
    private static EUR_CRM_GB_Volume_Tracker_Line_Item__c volumeTrackerItem;
    private static EUR_CRM_Store_Audit__c storeAudit;
    private static EUR_CRM_Store_Audit_Item__c storeAuditItem;
    
    static testMethod void myUnitTest() {
        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR_GB_Quality', 'Cocktail', 'TEST-0001', null)[0];
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);
        
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_GB_FS_Indirect')[0];
        insert accountEU;
        system.assertNotEquals(accountEU, null);
        
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'EUR_GB_Contract', accountEU.Id, date.today(), date.today().addDays(20))[0];
        contract.EUR_CRM_Active__c = true;
        insert contract;
        system.assertNotEquals(contract, null);
        
        volumeTracker = EUR_CRM_TestClassUtilityHelper.createVolumeTracker(1, 'EUR_GB_Volume_Tracker', contract.Id)[0];
        insert volumeTracker;
        system.assertNotEquals(volumeTracker, null);
        
        volumeTrackerItem = EUR_CRM_TestClassUtilityHelper.createVolumeTrackerItem(1, volumeTracker.Id)[0];
        volumeTrackerItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        volumeTrackerItem.EUR_CRM_Initial_Contract_Volume__c = 2;
        insert volumeTrackerItem;
        system.assertNotEquals(volumeTrackerItem, null);
        
        storeAudit = EUR_CRM_TestClassUtilityHelper.createStoreAudit(1, 'EUR_GB_Store_Audit', accountEU.Id)[0];
        insert storeAudit;
        system.assertNotEquals(storeAudit, null);
        
        storeAuditItem = EUR_CRM_TestClassUtilityHelper.createStoreAuditItem(1, 'EUR_GB_FS_Store_Audit', storeAudit.Id)[0];
        storeAuditItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        storeAuditItem.EUR_CRM_Volume_per_Month_9L_Cases__c = 10.00;
        insert storeAuditItem;
        system.assertNotEquals(storeAuditItem, null);
        
        storeAuditItem.EUR_CRM_Volume_per_Month_9L_Cases__c  = 20.00;
        update storeAuditItem;
    }
}