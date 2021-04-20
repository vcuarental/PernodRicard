@IsTest (IsParallel = true)
private class EUR_CRM_OP_ActionControllerTest {

    @IsTest
    private static void getActionFieldsTest(){
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {

            String res = EUR_CRM_OP_ActionController.getActionFields('Action', null);
            System.assertNotEquals('[]', res);
        }
    }
    
    @IsTest
    private static void getActionFieldsWithIdTest(){
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_OP_Action__c newAction = new EUR_CRM_OP_Action__c(Name = 'test', EUR_CRM_Reoccuring_Type__c = 'Repeat until successful');
            insert newAction;
            String res = EUR_CRM_OP_ActionController.getActionFields('Action', newAction.Id);
            System.assertNotEquals('[]', res);
            System.assertEquals(true, res.contains('test'));
        }
    }

    @IsTest
    private static void getRecordTypesForActionTest(){
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<RecordType> rt = [SELECT Id,SobjectType FROM RecordType WHERE SobjectType = 'EUR_CRM_OP_Action__c'];
            System.assertEquals(2, rt.size());
            String res = EUR_CRM_OP_ActionController.getRecordTypesForAction(rt[0].Id);
            System.assertNotEquals(null, ((EUR_CRM_OP_ActionController.ActionRecordTypeWrapper) JSON.deserialize(res, EUR_CRM_OP_ActionController.ActionRecordTypeWrapper.class)).availableRecordTypes);
//            System.assertNotEquals(null, ((EUR_CRM_OP_ActionController.ActionRecordTypeWrapper) JSON.deserialize(res, EUR_CRM_OP_ActionController.ActionRecordTypeWrapper.class)).defaultOrUsedRecordType);
        }
    }

    @IsTest
    private static void saveActionInDBTest(){
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_OP_Action__c act = new EUR_CRM_OP_Action__c(Name = 'Test', EUR_CRM_Reoccuring_Type__c = 'Repeat until successful');
            String res = EUR_CRM_OP_ActionController.saveActionInDB(act);
            System.assertEquals('SUCCESS', res);
        }
    }

    @IsTest
    private static void getValuesForSuccessStatusTest(){
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            String r = EUR_CRM_OP_ActionController.getActionFields('Action', null);
            List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> l = (List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>) JSON.deserialize(r, List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>.class);
            System.assertNotEquals(0, l.size());
            System.assertNotEquals(null, l[0].fieldApiName);
            String recordList = EUR_CRM_OP_ActionController.getValuesForSuccessStatus('EUR_CRM_OP_Visit_Action__c', l[0].fieldApiName);
            List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> ll = (List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>) JSON.deserialize(recordList, List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>.class);
            System.assertNotEquals(false, true);
        }
    }

    private static List<User> getEMEAandEURsystemAdminUser() {
        return [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'EUR System Admin'
                AND UserRole.Name = 'EMEA'
            LIMIT 1
        ];
    }
}