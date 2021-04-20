@IsTest (IsParallel = true)
private class EUR_CRM_OP_MultyPiclistControllerTest {
    @IsTest
    private static void getMultyPiclistFieldsTest() {
        EUR_CRM_OP_Action__c act = new EUR_CRM_OP_Action__c(Name = 'Test', EUR_CRM_MultiPLOpTarget__c = 'Name', EUR_CRM_Reoccuring_Type__c = 'Repeat until successful');
        insert act;
        String res = EUR_CRM_OP_MultyPiclistController.getMultyPiclistFields('Action', act.Id, 'Name');
        System.assertNotEquals('[]', res);
    }
}