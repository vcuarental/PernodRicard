/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ActualOfftakeMassDelBatchTest
 * Description: Test class for ASI_CRM_VN_ActualOfftakeMassDeleteBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-26       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_ActualOfftakeMassDelBatchTest {
    //    Delete all template ActualOfftake by user
    @IsTest static void batchTest() {
        // data creations
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        User user = ASI_CRM_VN_TestClassHelper.createUserByProfileName('System Administrator');
        insert user;

        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;

        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;

        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;

        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.OwnerId = user.Id;
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert onTradeCustomer;

        ASI_TH_CRM_Actual_Offtake__c offtake = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand.Id);
        offtake.OwnerId = user.Id;
        offtake.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__c' + 'ASI_CRM_VN_Actual_Offtake_Temporary');
        insert offtake;
        // data creations

        System.assertEquals(1, [SELECT Id FROM ASI_TH_CRM_Actual_Offtake__c WHERE RecordType.DeveloperName = 'ASI_CRM_VN_Actual_Offtake_Temporary'].size());


        ASI_CRM_VN_ActualOfftakeMassDeleteBatch controller = new ASI_CRM_VN_ActualOfftakeMassDeleteBatch(user.Id);

        Test.startTest();

        Database.executeBatch(controller);

        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM ASI_TH_CRM_Actual_Offtake__c WHERE RecordType.DeveloperName = 'ASI_CRM_VN_Actual_Offtake_Temporary'].size());

    }
}