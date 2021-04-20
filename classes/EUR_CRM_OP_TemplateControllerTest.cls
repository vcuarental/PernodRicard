@IsTest (IsParallel = true)
private class EUR_CRM_OP_TemplateControllerTest {
    @IsTest
    private static void getActionFieldsTest() {
        String res = EUR_CRM_OP_TemplateController.getActionFields('Template',null);
        System.assertNotEquals('[]', res);
    }

    @IsTest
    private static void getTargetQuotaLevelsTest() {
        String val = 'General Level';
        EUR_CRM_OP_Template__c template = new EUR_CRM_OP_Template__c(EUR_CRM_Target_Quota_Levels__c = val);
        insert template;
        String res = EUR_CRM_OP_TemplateController.getTargetQuotaLevels(template.Id);
        System.assertEquals(true,res.contains(val));
    }

    @IsTest
    private static void saveTemplateInDBTest() {
        EUR_CRM_OP_Template__c template = new EUR_CRM_OP_Template__c();
        insert template;
        EUR_CRM_OP_Action__c action1 = new EUR_CRM_OP_Action__c(EUR_CRM_Reoccuring_Type__c = 'Repeat until successful');
        EUR_CRM_OP_Action__c action2 = new EUR_CRM_OP_Action__c(EUR_CRM_Reoccuring_Type__c = 'Repeat until successful');
        List<EUR_CRM_OP_Action__c> actionList = new List<EUR_CRM_OP_Action__c>{action1,action2};
        String res = EUR_CRM_OP_TemplateController.saveTemplateInDB(template,actionList);
        System.assertEquals(true,res.containsIgnoreCase('SUCCESS'));
    }

    @IsTest
    private static void deleteActionTest() {
        EUR_CRM_OP_Action__c action = new EUR_CRM_OP_Action__c(EUR_CRM_Reoccuring_Type__c = 'Repeat until successful');
        insert action;
        String res = EUR_CRM_OP_TemplateController.deleteAction(action.Id);
        System.assertEquals(true,res.containsIgnoreCase('SUCCESS'));
    }

    @IsTest
    private static void getOPActionRecordsTest() {
        EUR_CRM_OP_Template__c template = new EUR_CRM_OP_Template__c();
        insert template;
        EUR_CRM_OP_Action__c action1 = new EUR_CRM_OP_Action__c(EUR_CRM_OP_Template__c = template.Id, EUR_CRM_Reoccuring_Type__c = 'Repeat until successful');
        EUR_CRM_OP_Action__c action2 = new EUR_CRM_OP_Action__c(EUR_CRM_OP_Template__c = template.Id, EUR_CRM_Reoccuring_Type__c = 'Repeat until successful');
        List<EUR_CRM_OP_Action__c> actionList = new List<EUR_CRM_OP_Action__c>{action1,action2};
        insert actionList;
        List<EUR_CRM_OP_Action__c> actList = EUR_CRM_OP_TemplateController.getOPActionRecords(template.Id);
        System.assertEquals(3,actList.size());
    }
}