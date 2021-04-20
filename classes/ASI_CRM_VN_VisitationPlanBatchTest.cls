/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_VisitationPlanBatchTest
 * Description: Test class for ASI_CRM_VN_VisitationPlanBatchTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-25       Jeffrey Cheung          Created
 ****************************************************************************************************************************/
@IsTest
private class ASI_CRM_VN_VisitationPlanBatchTest {
    @IsTest static void getPeriodStartTest() {
        ASI_CRM_VN_VisitationPlanBatch controller = new ASI_CRM_VN_VisitationPlanBatch();
        System.assertEquals( Date.newInstance(2018,1,1), controller.getPeriodStart(Date.newInstance(2018,1,1)) );
        System.assertEquals( Date.newInstance(2018,1,1), controller.getPeriodStart(Date.newInstance(2018,1,15)) );
        System.assertEquals( Date.newInstance(2018,1,15), controller.getPeriodStart(Date.newInstance(2018,1,16)) );
        System.assertEquals( Date.newInstance(2018,1,15), controller.getPeriodStart(Date.newInstance(2018,1,31)) );
    }

    @IsTest static void getPeriodEndTest() {
        ASI_CRM_VN_VisitationPlanBatch controller = new ASI_CRM_VN_VisitationPlanBatch();
        System.assertEquals( Date.newInstance(2018,1,15), controller.getPeriodEnd(Date.newInstance(2018,1,1)) );
        System.assertEquals( Date.newInstance(2018,1,15), controller.getPeriodEnd(Date.newInstance(2018,1,15)) );
        System.assertEquals( Date.newInstance(2018,1,31), controller.getPeriodEnd(Date.newInstance(2018,1,16)) );
        System.assertEquals( Date.newInstance(2018,1,31), controller.getPeriodEnd(Date.newInstance(2018,1,31)) );
    }

    @IsTest static void batchTest(){
//        create data
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        String profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User newUser = ASI_CRM_VN_TestClassHelper.createUser(profileId);
        newUser.email = 'jeffrey.cheung@laputatech.com';
        insert newUser;

        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;

        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;

        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;

        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.OwnerId = newUser.Id;
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert onTradeCustomer;


        ASI_HK_CRM_Visitation_Plan__c firstHalfPlan = ASI_CRM_VN_TestClassHelper.createVisitationPlan();
        firstHalfPlan.OwnerId = newUser.Id;
        firstHalfPlan.ASI_CRM_VN_Period__c = 'First Half';
        firstHalfPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_VN_Visitation_Plan');
        ASI_HK_CRM_Visitation_Plan__c secondHalfPlan = ASI_CRM_VN_TestClassHelper.createVisitationPlan();
        secondHalfPlan.OwnerId = newUser.Id;
        secondHalfPlan.ASI_CRM_VN_Period__c = 'Second Half';
        secondHalfPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_VN_Visitation_Plan');

        insert firstHalfPlan;
        insert secondHalfPlan;

        ASI_HK_CRM_Visitation_Plan_Detail__c detail1 = ASI_CRM_VN_TestClassHelper.createVisitationPlanDetail(
                Date.today().day() < 16 ? firstHalfPlan.Id : secondHalfPlan.Id,
                onTradeCustomer.Id
        );
        detail1.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_VN_Visitation_Plan_Detail');
        detail1.ASI_HK_CRM_Visit_Date__c = Date.today().addDays(-1);
        insert detail1;
		
        Test.startTest();

        //        execute batch
        Database.executeBatch(new ASI_CRM_VN_VisitationPlanBatch());

        Test.stopTest();

//        assertion
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> details = [SELECT Id FROM ASI_HK_CRM_Visitation_Plan_Detail__c WHERE ASI_HK_CRM_Visit_Date__c = TODAY];
        System.assertEquals(1, details.size());
    }
}