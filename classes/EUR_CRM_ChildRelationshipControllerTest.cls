@IsTest (IsParallel = true)
private class EUR_CRM_ChildRelationshipControllerTest {

    @IsTest
    static void describeRelationshipWithNullOrEmptyParamsTest() {
        System.assertEquals('null', EUR_CRM_ChildRelationshipController.describeRelationship(null, 'Contacts'));
        System.assertEquals('null', EUR_CRM_ChildRelationshipController.describeRelationship('', 'Contacts'));
        System.assertEquals('null', EUR_CRM_ChildRelationshipController.describeRelationship('Account', null));
        System.assertEquals('null', EUR_CRM_ChildRelationshipController.describeRelationship('Account', ''));
    }

    @IsTest
    static void describeRelationshipWithWrongChildRelationTest() {
        System.assertEquals('null', EUR_CRM_ChildRelationshipController.describeRelationship('Account', 'Test_Fake_Relation__r'));
    }

    @IsTest
    static void describeRelationshipSuccessTest() {
        String result = EUR_CRM_ChildRelationshipController.describeRelationship('Account', 'Contacts');
        System.assertNotEquals('null', result);
        EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper jsonResult = (EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper)JSON.deserialize(result, EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper.class);
        System.assertEquals('AccountId', jsonResult.childRelationshipField);
    }

}