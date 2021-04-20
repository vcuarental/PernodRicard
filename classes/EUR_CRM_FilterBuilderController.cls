public with sharing class EUR_CRM_FilterBuilderController {

    @TestVisible private final static Map<String, Set<String>> typesOperatorsMap = new Map<String, Set<String>>{
            'PICKLIST' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'STRING' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'TEXTAREA' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'PHONE' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'EMAIL' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'URL' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'MULTIPICKLIST' => new Set<String>{
                    'equals', 'not equal to', 'includes', 'excludes'
            },
            'BOOLEAN' => new Set<String>{
                    'equals', 'not equal to'
            },
            'ID' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'REFERENCE' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'DOUBLE' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'CURRENCY' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'PERCENT' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'DATE' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'DATETIME' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'DEFAULT' => new Set<String>{
                    'equals', 'not equal to'
            }
    };

    private final static Set<String> notFilterableFieldTypes = new Set<String>{
            'ADDRESS',
            'LOCATION'
    };

    public static final String ACCOUNT_OBJECT_NAME = 'EUR_CRM_Account__c';
    private static List<String> USER_COUNTRY_CODES {
        get {
            String countryCodes = selectAdminCountries();
            if (countryCodes != null) { return countryCodes.split(';'); }
            return new List<String>();
        }
    }

    @AuraEnabled
    public static Map<String, String> getSObjectFieldsSelectOptions(String sObjectName) {
        Map<String, String> sObjectFields = new Map<String, String>();
        List<String> fieldNames = new List<String>();
        for (Schema.SObjectField sfield : getSObjectFields(sObjectName).values()) {
            Schema.DescribeFieldResult dfield = sfield.getDescribe();
            String fieldType = String.valueOf(dfield.getType());
            if (dfield.isAccessible() && !notFilterableFieldTypes.contains(fieldType) && (fieldType != 'TEXTAREA' || dfield.getLength() <= 255)) {
                sObjectFields.put(dfield.getName(), dfield.getLabel());
                if (dfield.getName() == 'RecordTypeId') {
//                    sObjectFields.put('RecordType.DeveloperName', Label.FB_RecordType);
                    sObjectFields.put('RecordType.DeveloperName', 'Label.FB_RecordType');
                }
            }
        }
        Map<String, String> sObjectFieldsSO = new Map<String, String>();
        for (String fieldName : sObjectFields.keySet()) {
            sObjectFieldsSO.put(fieldName, sObjectFields.get(fieldName));
            fieldNames.add(sObjectFields.get(fieldName));
        }
        fieldNames.sort();
        sObjectFieldsSO.put('fieldNames', JSON.serialize(fieldNames));
        return sObjectFieldsSO;
    }

    @AuraEnabled
    public static String describeFields(String sObjectName, List<String> fieldApiNames) {
        Map<Id, String> sObjectAvailableTypes = getSobjectAvailableRts(sObjectName);
        List<FieldDescribeWrapper> fieldDescribeWrapperList = new List<FieldDescribeWrapper>();
        Map<String, SObjectField> fieldDescribeMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        for (String fieldApiName : fieldApiNames) {
            FieldDescribeWrapper fieldDescribeWrapper = new FieldDescribeWrapper();
            System.debug(fieldApiName);
            fieldDescribeWrapper.name = fieldApiName;
            if (fieldApiName == 'RecordType.DeveloperName') {
                fieldDescribeWrapper.fieldType = 'PICKLIST';
                fieldDescribeWrapper.picklistOptions = new List<String>();
                fieldDescribeWrapper.picklistOptions.addAll(EUR_CRM_FilterBuilderService.getSObjectAvailableTypes(sObjectName).keySet());
            } else {
                String fieldName = getFieldName(fieldApiName);
                Schema.DescribeFieldResult fieldDescribe = getSObjectFields(sObjectName).get(fieldName).getDescribe();
                fieldDescribeWrapper.fieldType = String.valueOf(fieldDescribe.getType());
                if(fieldDescribeWrapper.fieldType == 'REFERENCE') {
                    fieldDescribeWrapper.parentSObjectName = fieldDescribeMap.get(fieldApiName).getDescribe().getReferenceTo()[0].getDescribe().getName();
                }
                if (fieldDescribeWrapper.fieldType == 'PICKLIST' || fieldDescribeWrapper.fieldType == 'MULTIPICKLIST') {
                    fieldDescribeWrapper.picklistOptions = new List<String>();

                    /**
                    * Get picklist values acording to user available record types
                    * */
                    Set<String> availablePicklistValuesDependsOnRecordType = new Set<String>();
                    if (sObjectAvailableTypes.size() < 100) {
                        for (Id recTypeId : sObjectAvailableTypes.keySet()) {
                            Map<String, String> availablePicklistValuesMap = EUR_CRM_FilterBuilderController.getPicklistValuesByRecordTypeViaHttp(sObjectName, Id.valueOf(recTypeId), fieldApiName);
                            availablePicklistValuesDependsOnRecordType.addAll(availablePicklistValuesMap.values());
                            System.debug('availablePicklistValuesMap : ' + availablePicklistValuesMap);
                        }
                        fieldDescribeWrapper.picklistOptions.addAll(availablePicklistValuesDependsOnRecordType);
                    } if (sObjectAvailableTypes.isEmpty() || sObjectAvailableTypes.size() > 100 || Test.isRunningTest()){
//                        if (sObjectAvailableTypes.isEmpty()) {
                            List<Schema.PicklistEntry> ple = fieldDescribe.getPicklistValues();
                            for (Schema.PicklistEntry f : ple) {
//                            if (availablePicklistValuesDependsOnRecordType.contains(f.getLabel()) || Test.isRunningTest()) {
                                fieldDescribeWrapper.picklistOptions.add(f.getLabel());
//                            }
                            }
//                        }
                    }
                    fieldDescribeWrapper.picklistOptions.sort();
                }
            }
            fieldDescribeWrapper.operatorOptions = new List<String>();
            if (typesOperatorsMap.containsKey(fieldDescribeWrapper.fieldType)) {
                fieldDescribeWrapper.operatorOptions.addAll(typesOperatorsMap.get(fieldDescribeWrapper.fieldType));
            } else {
                fieldDescribeWrapper.operatorOptions.addAll(typesOperatorsMap.get('DEFAULT'));
            }
            fieldDescribeWrapperList.add(fieldDescribeWrapper);
        }
        return JSON.serialize(fieldDescribeWrapperList);
    }

    private static Map<Id, String> getSobjectAvailableRts(String sObjectName) {
        if (sObjectName == ACCOUNT_OBJECT_NAME) {
            return EUR_CRM_FilterBuilderService.getSObjectAvailableRecordTypesWhereCountryCodes(sObjectName, USER_COUNTRY_CODES);
        }
           return EUR_CRM_FilterBuilderService.getSObjectAvailableRecordTypes(sObjectName);

    }


    @AuraEnabled
    public static String validateFilterItems(String sObjectName, String filterLogic, String filtersInfo) {
        List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = (List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>) JSON.deserialize(filtersInfo, List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>.class);
        FilterBuilderResponse response = new FilterBuilderResponse();
        try {
            response.success = true;
            response.message = 'OK';
            response.filter = EUR_CRM_FilterBuilderService.buildSObjectFilter(sObjectName, filterLogic, filterItems);
        } catch (Exception e) {
            System.debug(e.getLineNumber() + e.getMessage());
            response.success = false;
            response.message = e.getMessage();
        }
        return JSON.serialize(response);
    }

    public static String getFieldName(String field) {
        String strToReturn = '';
        List<String> strSplit = field.split('__r.');
        strToReturn = strSplit[strSplit.size() - 1];
        return strToReturn;
    }

    @TestVisible
    public static Map<String, Schema.SObjectField> getSObjectFields(String sObjectName) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();

        return fieldMap;
    }

    public class FieldDescribeWrapper {
        public String parentSObjectName;
        public String name;
        public String fieldType;
        public List<String> picklistOptions;
        public List<String> operatorOptions;
    }

    @TestVisible
    private class FilterBuilderResponse {
        @TestVisible private Boolean success;
        @TestVisible private String message;
        @TestVisible private EUR_CRM_FilterBuilderService.ObjectFilterWrapper filter;
    }

    public static Map<String, String> getPicklistValuesByRecordTypeViaHttp(String objectType, String recordTypeId, String fieldName) {
        if (Limits.getCallouts() == Limits.getLimitCallouts()) {
            return new Map<String, String>();
        }
        //Endpoint
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm();
        endpoint += '/services/data/v42.0';
        endpoint += '/ui-api/object-info/{0}/picklist-values/{1}/{2}';
        endpoint = String.format(endpoint, new String[]{
                objectType, recordTypeId, fieldName
        });
        EncodingUtil.urlEncode(endpoint, 'UTF-8');

        //HTTP Request send
        HttpRequest req = new HttpRequest();
        EUR_CRM_SessionProducerControl spc = new EUR_CRM_SessionProducerControl();
        String sid = EUR_CRM_SessionProducerControl.getSessionId() + '';
        req.setHeader('Authorization', 'OAuth ' + sid);
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res;

        res = http.send(req);

        //Parse response
        Map<String, String> result = new Map<String, String>();
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if (!root.containsKey('values')) {
            return result;
        }
        List<Object> pValues = (List<Object>) root.get('values');
        for (Object pValue : pValues) {
            Map<String, Object> pValueMap = (Map<String, Object>) pValue;
            result.put((String) pValueMap.get('value'), (String) pValueMap.get('label'));
        }
        return result;
    }

    private static String selectAdminCountries() {
        return [
            SELECT EUR_CRM_Affiliate_Code_Picklist__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ].EUR_CRM_Affiliate_Code_Picklist__c;
    }

}