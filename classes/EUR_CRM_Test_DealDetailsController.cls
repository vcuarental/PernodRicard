/**
 * Created by V. Kamenskyi on 23.07.2018.
 */

@IsTest
private class EUR_CRM_Test_DealDetailsController {

    @TestSetup
    private static void init() {}

    @IsTest
    private static void newModel() {
        EUR_CRM_DealDetailsController.Model model = new EUR_CRM_DealDetailsController.Model();
        System.assertNotEquals(null, model);
        System.assertEquals(null, model.deal);
        System.assertEquals(null, model.productsInDeal);
        System.assertEquals(null, model.posmGroupings);
        System.assertEquals(null, model.freeProductGroupings);
        System.assertEquals(null, model.dealRecordTypesByIds);
        System.assertEquals(null, model.discountTypes);
        System.assertNotEquals(null, model.currentUser);
        System.assertNotEquals(null, model.labels);
        System.assertNotEquals(null, model.picklistEntries);
        // Why it is null?
//        System.assertNotEquals(null, model.productLevelByOrderType);
    }

    @IsTest
    private static void getModelByDealId() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            EUR_CRM_Deal__c deal = (EUR_CRM_Deal__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Deal__c(
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Objectives_Promotions__c = op.Id
            ), true);
            System.assertNotEquals(null, deal.Id);
            System.assertNotEquals(null, deal.EUR_CRM_Country__c);
            EUR_CRM_DealDetailsController.Model model = EUR_CRM_DealDetailsController.getModel(deal.Id);
            System.assertEquals(deal.Id, model.deal.Id);
        }
    }

    @IsTest
    private static void doUpsertForDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            EUR_CRM_Deal__c deal = (EUR_CRM_Deal__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Deal__c(
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Objectives_Promotions__c = op.Id
            ), true);
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeObjectField('deal', deal);
            gen.writeEndObject();
            String res = EUR_CRM_DealDetailsController.doUpsert(gen.getAsString());
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(res, Database.UpsertResult.class);
            System.assert(result.isSuccess());
        }
    }

    @IsTest
    private static void doDeleteForDeal() {
        User testUser = (User) EUR_CRM_TestDataFactory.createSObject(new User(Country = EUR_CRM_Deal__c.EUR_CRM_Country__c.getDescribe().getPicklistValues()[0].getValue()), true);
        System.runAs(testUser) {
            EUR_CRM_Objectives_Promotions__c op = (EUR_CRM_Objectives_Promotions__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Objectives_Promotions__c(), true);
            EUR_CRM_Deal__c deal = (EUR_CRM_Deal__c) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Deal__c(
                    EUR_CRM_Country__c = testUser.Country,
                    EUR_CRM_Deal_logic__c = 'OR',
                    EUR_CRM_Objectives_Promotions__c = op.Id
            ), true);
            String res = EUR_CRM_DealDetailsController.doDelete(deal.Id);
            Database.DeleteResult result = (Database.DeleteResult) JSON.deserialize(res, Database.DeleteResult.class);
            System.assert(result.isSuccess());
        }
    }
}