/**
 * Created by User on 6/1/2018.
 */

public with sharing class EUR_CRM_OP_DynamicFieldService {

    public static List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> getFields(String objectName, List<String> fieldList) {
        List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> res = new List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

        for (String fieldName : fieldList) {
            if (fieldMap.get(fieldName.trim()) != null) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName.trim()).getDescribe();
                if (fieldDescribe.isAccessible()) {
                    Boolean isReadOnly = fieldDescribe.isCalculated()
                            || fieldDescribe.isAutoNumber()
                            || !fieldDescribe.isCreateable()
                            ? true : false;
                    OPObjectFieldsWrapper wrap = new OPObjectFieldsWrapper(
                            fieldName,
                            fieldDescribe.getLabel(),
                            null,
                            String.valueOf(fieldDescribe.getType()),
                            !fieldDescribe.isNillable(),
                            isReadOnly
                    );
                    if (String.valueOf(fieldDescribe.getType()) == 'PICKLIST'
                            || String.valueOf(fieldDescribe.getType()) == 'MULTIPICKLIST') {
                        wrap.picklistValues = getPicklistValues(objectName, fieldName, String.valueOf(fieldDescribe.getType()) == 'PICKLIST');
                    }
                    res.add(wrap);
                }
            }
        }

        return res;
    }

    public static List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> getFieldsWithRestrictedPicklistValues(String objectName, List<String> fieldList, String recordTypeId) {
        List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> res = new List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

        for (String fieldName : fieldList) {
            if (fieldMap.get(fieldName.trim()) != null) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName.trim()).getDescribe();
                if (fieldDescribe.isAccessible()) {
                    Boolean isReadOnly = fieldDescribe.isCalculated()
                        || fieldDescribe.isAutoNumber()
                        || !fieldDescribe.isCreateable()
                        ? true : false;
                    OPObjectFieldsWrapper wrap = new OPObjectFieldsWrapper(
                        fieldName,
                        fieldDescribe.getLabel(),
                        null,
                        String.valueOf(fieldDescribe.getType()),
                        !fieldDescribe.isNillable(),
                        isReadOnly
                    );
                    if (String.valueOf(fieldDescribe.getType()) == 'PICKLIST'
                        || String.valueOf(fieldDescribe.getType()) == 'MULTIPICKLIST') {
                        wrap.picklistValues = getRestrictedPicklistValues(objectName, recordTypeId, fieldName, String.valueOf(fieldDescribe.getType()) == 'PICKLIST');
                    }
                    res.add(wrap);
                }
            }
        }

        return res;
    }

    public static List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> getFields(String objectName, List<String> fieldList, Id templateId) {
        List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> res = new List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>();
        String visitActionRTDevName = '';
        Id visitActionRtId;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(objectName);
        if (objectName == 'EUR_CRM_OP_Visit_Action__c') {
            EUR_CRM_OP_Template__c template = selectTemplateWhereId(templateId)[0];
            String templateRTDevName = template.RecordType.DeveloperName;
            String templateCountry = templateRTDevName.substringBetween('EUR_','_OP_Template');
            visitActionRTDevName = String.format('EUR_{0}_OP_Visit_Action', new List<String>{ templateCountry });
            System.debug('\n templateRTDevName => ' + templateRTDevName + '\n');
            System.debug('\n templateCountry => ' + templateCountry + '\n');
            System.debug('\n visitActionRTDevName => ' + visitActionRTDevName + '\n');
            RecordTypeInfo rtInfo = objSchema.getDescribe().getRecordTypeInfosByDeveloperName().get(visitActionRTDevName);
            visitActionRtId = rtInfo == null ? null : rtInfo.getRecordTypeId();
        }
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

        for (String fieldName : fieldList) {
            if (fieldMap.get(fieldName.trim()) != null) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName.trim()).getDescribe();
                if (fieldDescribe.isAccessible()) {
                    Boolean isReadOnly = fieldDescribe.isCalculated()
                        || fieldDescribe.isAutoNumber()
                        || !fieldDescribe.isCreateable()
                        ? true : false;
                    OPObjectFieldsWrapper wrap = new OPObjectFieldsWrapper(
                        fieldName,
                        fieldDescribe.getLabel(),
                        null,
                        String.valueOf(fieldDescribe.getType()),
                        !fieldDescribe.isNillable(),
                        isReadOnly
                    );
                    if ((String.valueOf(fieldDescribe.getType()) == 'PICKLIST'
                        || String.valueOf(fieldDescribe.getType()) == 'MULTIPICKLIST') && String.isNotBlank(visitActionRTDevName)) {
                        wrap.picklistValues = getRestrictedPicklistValues(objectName, visitActionRtId, fieldName, String.valueOf(fieldDescribe.getType()) == 'PICKLIST');
                    } if ((String.valueOf(fieldDescribe.getType()) == 'PICKLIST'
                        || String.valueOf(fieldDescribe.getType()) == 'MULTIPICKLIST') && String.isBlank(visitActionRTDevName)){
                        wrap.picklistValues = getPicklistValues(objectName, fieldName, String.valueOf(fieldDescribe.getType()) == 'PICKLIST');
                    }
                    res.add(wrap);
                }
            }
        }

        return res;
    }

    public static List<EUR_CRM_OP_Template__c> selectTemplateWhereId(Id templateId) {
        return [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM EUR_CRM_OP_Template__c WHERE Id = :templateId];
    }

    public static List<EUR_CRM_OP_DynamicFieldService.POPicklistWrapper> getRestrictedPicklistValues(String objectName, Id rtId, String fieldName, Boolean isPicklist) {
        SObjectType sobjType = ((SObject) Type.forName(objectName).newInstance()).getSObjectType();
        Map<Id, RecordTypeInfo> rtInfoById = sobjType.getDescribe().getRecordTypeInfosById();
        if (rtId == null) {
            for (RecordTypeInfo rtInfo : rtInfoById.values()) {
                if (rtInfo.isDefaultRecordTypeMapping()) {
                    rtId = rtInfo.getRecordTypeId();
                    break;
                }
            }
        }
        System.debug('\n objectName => ' + objectName + '\n');
        System.debug('\n rtId => ' + rtId + '\n');
        System.debug('\n fieldName => ' + fieldName + '\n');
        if ( ! rtInfoById.containsKey(rtId)) {
            return getPicklistValues(objectName, fieldName, isPicklist);
        }
        List<EUR_CRM_OP_DynamicFieldService.POPicklistWrapper> values = new List<EUR_CRM_OP_DynamicFieldService.POPicklistWrapper>();
        try {
            Map<String, String> picklistValues = getValues(objectName, rtId, fieldName);
            System.debug('\n picklistValues.size() => ' + picklistValues.size() + '\n');
            System.debug('\n picklistValues => ' + JSON.serializePretty(picklistValues) + '\n');
            for (String val : picklistValues.keySet()) {
                if (values.isEmpty()) {
                    values.add(new POPicklistWrapper('--none--', null));
                }
                values.add(new POPicklistWrapper(picklistValues.get(val), val));
            }
        } catch (Exception ex) {
            System.debug('Error in getRestrictedPicklistValues() => ' + ex.getMessage() + ' ' + ex.getCause() + ' ' + ex.getLineNumber());
        }
        return values;
    }

    public static Map<String, String> getValues(String objectType, String recordTypeId, String fieldName) {
        //Endpoint
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm();
        endpoint += '/services/data/v44.0';
        endpoint += '/ui-api/object-info/{0}/picklist-values/{1}/{2}';
        endpoint = String.format(endpoint, new String[]{ objectType, recordTypeId, fieldName });
        EncodingUtil.urlEncode(endpoint,'UTF-8');

        //HTTP Request send
        HttpRequest req = new HttpRequest();
        EUR_CRM_SessionProducerControl spc = new EUR_CRM_SessionProducerControl();
        String sid = EUR_CRM_SessionProducerControl.getSessionId() + '';
        req.setHeader('Authorization', 'OAuth ' + sid);
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('\n res => ' + res + '\n');

        //Parse response
        Map<String,String> result = new Map<String,String>();
        Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        if(!root.containsKey('values')){
            return result;
        }
        List<Object> pValues = (List<Object>)root.get('values');
        for(Object pValue : pValues){
            Map<String,Object> pValueMap = (Map<String,Object>)pValue;
            result.put((String)pValueMap.get('value'), (String)pValueMap.get('label'));
        }

        return result;
    }

    public static List<EUR_CRM_OP_DynamicFieldService.POPicklistWrapper> getPicklistValues(String objectName, String fieldName, Boolean isPicklist) {
        List<EUR_CRM_OP_DynamicFieldService.POPicklistWrapper> values = new List<EUR_CRM_OP_DynamicFieldService.POPicklistWrapper>();
        try {
            String[] types = new String[]{
                    objectName
            };
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
            for (Schema.DescribeSobjectResult res : results) {
                for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                    if (entry.isActive()) {
                        if (values.isEmpty() && fieldName != 'RecordTypeId' && isPicklist) {
                            values.add(new POPicklistWrapper('--none--', null));
                        }
                        values.add(new POPicklistWrapper(entry.getLabel(), entry.getValue()));
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Error in getPicklistValues.' + ex.getMessage());
        }
        return values;
    }

    public static List<EUR_CRM_OP_Object_fields__mdt> getOPObjectFields(String devName) {
        List<EUR_CRM_OP_Object_fields__mdt> opObjFields = [
                SELECT DeveloperName
                        ,EUR_CRM_Fields__c
                        ,EUR_CRM_ObjectName__c
                FROM EUR_CRM_OP_Object_fields__mdt
                WHERE DeveloperName = :devName
        ];
        return opObjFields;
    }

    public class POPicklistWrapper {
        public String label { get; set; }
        public String value { get; set; }

        public POPicklistWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class OPObjectFieldsWrapper {
        public String fieldApiName { get; set; }
        public String fieldLabel { get; set; }
        public List<EUR_CRM_OP_DynamicFieldService.POPicklistWrapper> picklistValues { get; set; }
        public Object value { get; set; }
        public String fieldType { get; set; }
        public Boolean fieldIsRequired { get; set; }
        public Boolean fieldIsReadOnly { get; set; }

        public OPObjectFieldsWrapper(String fieldApiName, String fieldLabel, Object value, String fieldType, Boolean fieldIsRequired, Boolean fieldIsReadOnly) {
            this.fieldApiName = fieldApiName;
            this.fieldLabel = fieldLabel;
            this.value = value;
            this.fieldType = fieldType;
            this.fieldIsRequired = fieldIsRequired;
            this.fieldIsReadOnly = fieldIsReadOnly;
        }

        public OPObjectFieldsWrapper(OPObjectFieldsWrapper source) {
            this.fieldApiName = source.fieldApiName;
            this.fieldLabel = source.fieldLabel;
            this.fieldType = source.fieldType;
            this.fieldIsRequired = source.fieldIsRequired;
            this.fieldIsReadOnly = source.fieldIsReadOnly;
            this.value = null;
        }
    }

}