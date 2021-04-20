/**
 * Created by User on 6/3/2018.
 */

public with sharing class EUR_CRM_OP_TemplateController {
    @AuraEnabled
    public static String getActionFields(String devName, String recordId) {
        List<EUR_CRM_OP_Object_fields__mdt> opObjFields = EUR_CRM_OP_DynamicFieldService.getOPObjectFields(devName);
        if (!opObjFields.isEmpty() && opObjFields[0].EUR_CRM_Fields__c != null) {
            String[] opObjFieldList = opObjFields[0].EUR_CRM_Fields__c.split(',');
            String nameObj = opObjFields[0].EUR_CRM_ObjectName__c;

            List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> recordList = EUR_CRM_OP_DynamicFieldService.getFields(nameObj, opObjFieldList);
            if (recordId == null) {
                return JSON.serialize(recordList);
            } else {
                Set<String> availableFields = new Set<String>();
                for (EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper wrap : recordList) {
                    availableFields.add(wrap.fieldApiName);
                }
                String query = 'SELECT Id, ' + string.join(new List<String>(availableFields), ',') + ' FROM ' + nameObj + ' WHERE Id = \'' + recordId + '\'';
                List<EUR_CRM_OP_Template__c> records = Database.query(query);
                if (!records.isEmpty()) {
                    for (EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper wrapper : recordList) {
                        wrapper.value = records[0].get(wrapper.fieldApiName);
                    }
                }
                return JSON.serialize(recordList);
            }
        }
        return JSON.serialize(new List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>());
    }
    @AuraEnabled
    public static String getTargetQuotaLevels(String recordTemplateId) {
        String selectedValues;
        if (recordTemplateId != null) {
            List<EUR_CRM_OP_Template__c> templates = [
                    SELECT EUR_CRM_Target_Quota_Levels__c
                    FROM EUR_CRM_OP_Template__c
                    WHERE Id = :recordTemplateId
            ];
            if (!templates.isEmpty()) {
                selectedValues = templates[0].EUR_CRM_Target_Quota_Levels__c;
            }
        }

        EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper wrapper = new EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper(
                'EUR_CRM_Target_Quota_Levels__c'
                , Label.EUR_CRM_OP_TargetTemlateQuota
                , selectedValues
                , 'MULTIPICKLIST'
                , false
                , false
                );
        wrapper.picklistValues = EUR_CRM_OP_DynamicFieldService.getPicklistValues('EUR_CRM_OP_Template__c', 'EUR_CRM_Target_Quota_Levels__c', false);
        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static String saveTemplateInDB(EUR_CRM_OP_Template__c opTemplate,List<EUR_CRM_OP_Action__c> actionList) {
        try {
            upsert opTemplate;
            if(actionList != null) {
                for (EUR_CRM_OP_Action__c action : actionList) {
                    action.EUR_CRM_OP_Template__c = opTemplate.Id;
                    action.Id = null;
                }
                insert actionList;
            }
            return 'SUCCESS:::'+String.valueOf(opTemplate.Id);
//            return 'SUCCESS';
        } catch (Exception ex) {
            System.debug('Invalid saveActionInDB');
            return ex.getMessage();
        }
    }
    @AuraEnabled
    public static String deleteAction(String actionId) {
        System.debug('del actionId = ' + actionId);
        try {
            delete new EUR_CRM_OP_Action__c(Id = actionId);
            return 'SUCCESS';
        } catch (Exception ex) {
            System.debug('Invalid deleteAction');
            return ex.getMessage();
        }
    }
 
    @AuraEnabled
    public static List<EUR_CRM_OP_Action__c> getOPActionRecords(String recordTemplateId) {
        List<EUR_CRM_OP_Action__c> resWithTitle = new List<EUR_CRM_OP_Action__c>();
        if(recordTemplateId != null) {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType objSchema = schemaMap.get('EUR_CRM_OP_Action__c');
            Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
            Set<String> allFields = fieldMap.keySet();
            String query = 'SELECT ' + string.join(new List<String>(allFields), ',') + ' FROM EUR_CRM_OP_Action__c WHERE EUR_CRM_OP_Template__c = \'' + recordTemplateId + '\' ORDER BY CreatedDate';
            List<EUR_CRM_OP_Action__c> res = Database.query(query);

            if (!res.isEmpty()) {
                resWithTitle.add(res[0]);
                resWithTitle.addAll(res);
            }
        }
        return resWithTitle;
    }

}