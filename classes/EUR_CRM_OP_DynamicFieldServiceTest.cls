/**
 * Created by User on 6/8/2018.
 */
@IsTest(IsParallel = true)
private class EUR_CRM_OP_DynamicFieldServiceTest {
    @IsTest
    private static void getFieldsTest(){
        String objName = 'User';
        List<String> fieldList = new List<String>{'DefaultGroupNotificationFrequency','Name','CreatedById'};
        List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> res = EUR_CRM_OP_DynamicFieldService.getFields('User',fieldList);

        System.assertEquals(3,res.size());

        System.assertNotEquals(null,res[0].fieldLabel);
        System.assertNotEquals(null,res[0].fieldApiName);
        System.assertNotEquals(null,res[0].fieldType);
        System.assertNotEquals(null,res[0].fieldIsReadOnly);
        System.assertNotEquals(null,res[0].fieldIsRequired);
        System.assertNotEquals(null,res[0].picklistValues);
    }

    @IsTest
    private static void getFieldsWithRestrictedPicklistValuesTest(){
        String objName = 'User';
        List<String> fieldList = new List<String>{'DefaultGroupNotificationFrequency','Name','CreatedById'};
        List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> res = EUR_CRM_OP_DynamicFieldService.getFieldsWithRestrictedPicklistValues('User',fieldList, null);

        System.assertEquals(3,res.size());

        System.assertNotEquals(null,res[0].fieldLabel);
        System.assertNotEquals(null,res[0].fieldApiName);
        System.assertNotEquals(null,res[0].fieldType);
        System.assertNotEquals(null,res[0].fieldIsReadOnly);
        System.assertNotEquals(null,res[0].fieldIsRequired);
        System.assertNotEquals(null,res[0].picklistValues);
    }
 
    @IsTest
    private static void getPicklistValuesTest(){
        String objName = 'User';
        List<EUR_CRM_OP_DynamicFieldService.POPicklistWrapper> res = EUR_CRM_OP_DynamicFieldService.getPicklistValues('User','DefaultGroupNotificationFrequency',true);
        System.assertNotEquals(null,res[1].label);
        System.assertNotEquals(null,res[1].value);
    }

    @IsTest
    private static void getRestrictedPicklistValuesTest(){
        String objectName = 'EUR_CRM_OP_Visit_Action__c';
        String fieldName = 'EUR_CRM_Display_Type__c';
        EUR_CRM_OP_Template__c template = makeTemplate('EUR_DE_OP_Template');
        insert template;

        EUR_CRM_OP_DynamicFieldService.getFields(objectName,new List<String>{ fieldName }, template.Id);

    }


    /* ========================================================= */
    /*      Makers
    /* ========================================================= */
    private static EUR_CRM_OP_Template__c makeTemplate(String rt) {
        Id rtId = SObjectType.EUR_CRM_OP_Template__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_OP_Template__c (
            RecordTypeId = rtId
        );
    }
}