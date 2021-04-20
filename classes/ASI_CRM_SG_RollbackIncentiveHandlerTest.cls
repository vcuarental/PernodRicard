/***************************************************************************************************************************
 * Name:        ASI_CRM_SG_RollbackIncentiveHandlerTest
 * Description: Test class for ASI_CRM_SG_RollbackIncentiveHandler
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-05-18       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_SG_RollbackIncentiveHandlerTest {
    @IsTest static void testBehavior() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer, 'Yes');
        ASI_CRM_Promotion_Plan__c promotionPlan = new ASI_CRM_Promotion_Plan__c(
            Name = 'testPromotionPlan',
            ASI_CRM_Start_Date__c = Date.today().toStartOfMonth(),
            ASI_CRM_End_Date__c = Date.today().addMonths(1).toStartOfMonth().addDays(-1),
            ASI_CRM_Enrollment_Cut_off_Date__c = Date.today().addDays(15),
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Plan__cASI_CRM_SG_Wholesaler_Promotion_Plan')
        );
        insert promotionPlan;

        ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c(
            Name = 'testPromotionPlan',
            ASI_CRM_Promotion_Plan__c = promotionPlan.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion__cASI_CRM_SG_Ad_hoc_Trade_Promotion')
        );
        insert promotion;

        ASI_HK_CRM_Promotion_Detail__c promotionDetail = new ASI_HK_CRM_Promotion_Detail__c(
            ASI_HK_CRM_Promotion__c = promotion.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion_Detail__cASI_CRM_SG_Customer')
        );
        insert promotionDetail;

        ASI_CRM_SG_TestClassHelper.paymentData paymentData = new ASI_CRM_SG_TestClassHelper.paymentData(false, contractC1);
        paymentData.payment.ASI_CRM_System_Remark__c = 'SG Promotion (To Be Deleted)';
        paymentData.payment.ASI_CRM_Generation_From_Date__c = system.today();
        insert paymentData.payment;
        ASI_CRM_SG_TestClassHelper.paymentItemData paymentItemData = new ASI_CRM_SG_TestClassHelper.paymentItemData(false, paymentData.payment);
        paymentItemData.paymentItem.ASI_CRM_Promotion_Detail__c = promotionDetail.Id;
        insert paymentItemData.paymentItem;

        ASI_CRM_SG_TestClassHelper.freeGoodsData foc = new ASI_CRM_SG_TestClassHelper.freeGoodsData(false, 'ASI_CRM_SG_FOC');
        foc.freeGoods.ASI_CRM_System_Remark__c = 'SG Promotion (To Be Deleted)';
        foc.freeGoods.ASI_CRM_SG_Year__c = String.valueOf(system.today().year());
        foc.freeGoods.ASI_CRM_SG_Month__c = String.valueOf(system.today().month());
        insert foc.freeGoods;
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData focLine = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, foc.freeGoods);
        focLine.freeGoodsItem.ASI_CRM_Promotion_Detail__c = promotionDetail.Id;
        insert focLine.freeGoodsItem;
        
        ASI_CRM_Voucher__c v = new ASI_CRM_Voucher__c(
        	ASI_CRM_System_Generated_Msg__c = 'SG Promotion (To Be Deleted)',
            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Voucher__cASI_CRM_SG_Voucher'),
            ASI_CRM_Generation_Reference_Date__c = system.today()
        );
        insert v;
        ASI_CRM_Voucher_Detail__c vd = new ASI_CRM_Voucher_Detail__c(
        	recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Voucher_Detail__cASI_CRM_SG_Voucher_Detail'),
            ASI_CRM_Voucher_Header__c = v.id,
            ASI_CRM_Promotion_Detail__c = promotionDetail.Id
        );
        insert vd;

        Test.startTest();
        ASI_TH_CRM_PaymentRequest__c paymentRequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c LIMIT 1];
        ASI_FOC_Free_Goods_Request__c a = [SELECT Id FROM ASI_FOC_Free_Goods_Request__c LIMIT 1];
        ASI_CRM_Voucher__c b = [SELECT Id FROM ASI_CRM_Voucher__c LIMIT 1];

        System.debug('delete now');
        delete paymentRequest;
        delete a;
        delete b;
        System.debug('delete finish');
        Test.stopTest();

    }
}