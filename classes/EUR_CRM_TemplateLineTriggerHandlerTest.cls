@IsTest
private class EUR_CRM_TemplateLineTriggerHandlerTest {

    @IsTest
    static void testInsert() {
        EUR_CRM_JB_Template__c template = new EUR_CRM_JB_Template__c(Name='test');
        insert template;
        Datetime previousModifiedDate = DateTime.newInstance(2012,12,12);
        Test.setCreatedDate(template.Id,previousModifiedDate);
        EUR_CRM_JB_Template_Line__c templateLine = new EUR_CRM_JB_Template_Line__c(EUR_JB_CRM_Template__c = template.Id);
        insert templateLine;

        Datetime newModifiedDate = [SELECT Id,LastModifiedDate FROM EUR_CRM_JB_Template__c WHERE Id = :template.Id][0].LastModifiedDate;
        System.assertNotEquals(previousModifiedDate,newModifiedDate);

        previousModifiedDate = newModifiedDate;
        update templateLine;
        newModifiedDate = [SELECT Id,LastModifiedDate FROM EUR_CRM_JB_Template__c WHERE Id = :template.Id][0].LastModifiedDate;

        previousModifiedDate = newModifiedDate;
        delete templateLine;
        newModifiedDate = [SELECT Id,LastModifiedDate FROM EUR_CRM_JB_Template__c WHERE Id = :template.Id][0].LastModifiedDate;
    }

}