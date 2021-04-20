/**
 * Created by User on 6/1/2018.
 */

public with sharing class EUR_CRM_OP_MultyPiclistController {
    @AuraEnabled
    public static String getMultyPiclistFields(String devName, String recordId, String fieldName) {
        List<EUR_CRM_OP_Object_fields__mdt> opObjFields = EUR_CRM_OP_DynamicFieldService.getOPObjectFields(devName);
        if (!opObjFields.isEmpty() && opObjFields[0].EUR_CRM_Fields__c != null) {
            String[] opObjFieldList = opObjFields[0].EUR_CRM_Fields__c.split(',');
            String nameObj = opObjFields[0].EUR_CRM_ObjectName__c;
            List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> recordList = EUR_CRM_OP_DynamicFieldService.getFields(nameObj, opObjFieldList);
            if (recordId == null) {
                return JSON.serialize(recordList);
            } else {
                String query = 'SELECT Id, ' + fieldName + ' FROM EUR_CRM_OP_Action__c WHERE Id = \'' + recordId + '\'';
                List<EUR_CRM_OP_Action__c> records = Database.query(query);
                if (!records.isEmpty()) {
                    recordList[0].value = records[0].get(fieldName);
                }
                return JSON.serialize(recordList);
            }
        } else {
            return JSON.serialize(new List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>());
        }
    }

}