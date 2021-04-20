/**
 * Created by User on 6/1/2018.
 */

public with sharing class EUR_CRM_OP_ActionController {
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
                List<EUR_CRM_OP_Action__c> records = Database.query(query);
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
    public static String getRecordTypesForAction(String recordId) {
        Schema.SObjectType objType = EUR_CRM_OP_Action__c.SObjectType;
        List<EUR_CRM_OP_ActionController.AvailableRecordType> availableRecordTypes = new List<EUR_CRM_OP_ActionController.AvailableRecordType>();

        EUR_CRM_OP_ActionController.ActionRecordTypeWrapper wrapper = new EUR_CRM_OP_ActionController.ActionRecordTypeWrapper();
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        if (infos.size() > 1) {
            for (RecordTypeInfo i : infos) {
                if (i.isAvailable()
                        && !String.valueOf(i.getRecordTypeId()).endsWith('AAA')) {
                    availableRecordTypes.add(new AvailableRecordType(i.getRecordTypeId(), i.getName()));
                    if (i.isDefaultRecordTypeMapping()) {
                        wrapper.defaultOrUsedRecordType = new List<String>{i.RecordTypeId, i.getName()};
                    }
                }
            }
        } else {
            availableRecordTypes.add(new AvailableRecordType(infos[0].getRecordTypeId(), infos[0].getName()));
            if (infos[0].isDefaultRecordTypeMapping()) {
                wrapper.defaultOrUsedRecordType =new List<String>{infos[0].RecordTypeId,infos[0].getName()};
            }
        }
        wrapper.availableRecordTypes = availableRecordTypes;

        if (recordId != null) {
            List<EUR_CRM_OP_Action__c> actions = [
                    SELECT Id
                            , RecordTypeId
                            , RecordType.Name
                    FROM EUR_CRM_OP_Action__c
                    WHERE Id = :recordId
            ];
            if (!actions.isEmpty() && actions[0].RecordTypeId != null) {
                wrapper.defaultOrUsedRecordType = new List<String>{actions[0].RecordTypeId,actions[0].RecordType.Name};
            }
        }
        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static String saveActionInDB(EUR_CRM_OP_Action__c actionObj){
        System.debug('saveActionInDB '+actionObj);
        try {
            upsert actionObj;
            return 'SUCCESS';
        }catch(Exception ex){
            System.debug('Invalid saveActionInDB');
            return ex.getMessage();
        }
    }
    @AuraEnabled
    public static String getValuesForSuccessStatus(String nameObj,String nameField){
        List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> recordList = EUR_CRM_OP_DynamicFieldService.getFields(nameObj, new List<String>{nameField});
        return JSON.serialize(recordList);
    }

    @AuraEnabled
    public static String getRestrictedValuesForSuccessStatus(String nameObj,String nameField, Id templateId){
        List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> recordList = EUR_CRM_OP_DynamicFieldService.getFields(nameObj, new List<String>{nameField}, templateId);
        return JSON.serialize(recordList);
    }

    public class ActionRecordTypeWrapper {
        public List<EUR_CRM_OP_ActionController.AvailableRecordType> availableRecordTypes { get; set; }
        public String[] defaultOrUsedRecordType { get; set; }
    }

    public class AvailableRecordType {
        public Id value { get; set; }
        public String label { get; set; }

        public AvailableRecordType(Id idRecordType, String nameRecordType) {
            this.value = idRecordType;
            this.label = nameRecordType;
        }
    }
}