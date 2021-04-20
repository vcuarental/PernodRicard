public with sharing class EUR_CRM_FilterBuilderService {

    private final static Map<String, String> operatorsDescriptionsStringsMap = new Map<String, String>{
        'equals' => '{field} = {value}',
        'not equal to' => '{field} != {value}',
        'less than' => '{field} < {value}',
        'greater than' => '{field} > {value}',
        'less or equal' => '{field} <= {value}',
        'greater or equal' => '{field} >= {value}',
        'contains' => '{field} LIKE {value}',
        'does not contain' => '(NOT {field} LIKE {value})',
        'starts with' => '{field} LIKE {value}',
        'ends with' => '{field} LIKE {value}',
        'includes' => '{field} includes ({value})',
        'excludes' => '{field} excludes ({value})'
    };

    private final static Set<String> fieldTypesShouldEnclosedInQuotes = new Set<String>{
        'MULTIPICKLIST',
        'PICKLIST',
        'STRING',
        'TEXTAREA',
        'ID',
        'PHONE',
        'EMAIL',
        'URL',
        'REFERENCE'
    };

    private final static Map<String, String> operatorsJoinLogicMap = new Map<String, String>{
        'equals' => ' OR ',
        'not equal to' => ' AND ',
        'less than' => ' OR ',
        'greater than' => ' OR ',
        'less or equal' => ' OR ',
        'greater or equal' => ' OR ',
        'contains' => ' OR ',
        'does not contain' => ' AND ',
        'starts with' => ' OR ',
        'ends with' => ' OR ',
        'includes' => ' OR ',
        'excludes' => ' AND '
    };

    private final static Map<String, String> operatorWildCards = new Map<String, String>{
        'contains' => '%{value}%',
        'does not contain' => '%{value}%',
        'starts with' => '{value}%',
        'ends with' => '%{value}'
    };

    @TestVisible private final static Set<String> emptyValueAllowedOperators = new Set<String>{
        'equals',
        'not equal to'
    };

    private final static Set<String> parentRelationshipTypesWithLimitedChildRecords = new Set<String>{
        'contains',
        'does not contain'
    };

    public final static Set<String> dateLiterals = new Set<String>{
        'YESTERDAY',
        'TODAY',
        'TOMORROW',
        'LAST_WEEK',
        'THIS_WEEK',
        'NEXT_WEEK',
        'LAST_MONTH',
        'THIS_MONTH',
        'NEXT_MONTH',
        'LAST_90_DAYS',
        'NEXT_90_DAYS',
        'LAST_N_DAYS:n',
        'NEXT_N_DAYS:n',
        'NEXT_N_WEEKS:n',
        'LAST_N_WEEKS:n',
        'NEXT_N_MONTHS:n',
        'LAST_N_MONTHS:n',
        'THIS_QUARTER',
        'LAST_QUARTER',
        'NEXT_QUARTER',
        'NEXT_N_QUARTERS:n',
        'LAST_N_QUARTERS:n',
        'THIS_YEAR',
        'LAST_YEAR',
        'NEXT_YEAR',
        'NEXT_N_YEARS:n',
        'LAST_N_YEARS:n',
        'THIS_FISCAL_QUARTER',
        'LAST_FISCAL_QUARTER',
        'NEXT_FISCAL_QUARTER',
        'NEXT_N_FISCAL_​QUARTERS:n',
        'LAST_N_FISCAL_​QUARTERS:n',
        'THIS_FISCAL_YEAR',
        'LAST_FISCAL_YEAR',
        'NEXT_FISCAL_YEAR',
        'NEXT_N_FISCAL_​YEARS:n',
        'LAST_N_FISCAL_​YEARS:n'
    };

    private static final Set<String> BOOLEAN_CONSTANTS = new Set<String>{
        'TRUE',
        'FALSE'
    };

    public enum DateFormatTypes {
        GENERAL,
        LOCALE
    }

    public static ObjectFilterWrapper buildSObjectFilter(String sObjectName, String filterLogic, List<FiltersItemsWrapper> filterItems) {
        System.debug('\n\n sObjectName => ' + JSON.serializePretty(sObjectName) + '\n');
        System.debug('\n\n filterLogic => ' + JSON.serializePretty(filterLogic) + '\n');
        System.debug('\n\n filterItems => ' + JSON.serializePretty(filterItems) + '\n');

        ObjectFilterWrapper objectFilter = new ObjectFilterWrapper();
        objectFilter.objectName = sObjectName;
        objectFilter.filterLogic = filterLogic;

        if (filterItems != null) {
            validateFieldsValue(sObjectName, filterItems);
            try {
                substitutePickListValues(sObjectName, filterItems, false);
                substituteDateFormats(sObjectName, filterItems, DateFormatTypes.GENERAL);
                substituteRecordTypeValues(sObjectName, filterItems, false);
                objectFilter.items = filterItems;
                objectFilter.testQuery = buildSObjectFilterSelectionQuery(objectFilter);
                validateQuery(objectFilter.testQuery);
            } catch (Exception e) {
                System.debug(e.getLineNumber() + e.getMessage());
                throw new FilterBuilderException(e.getMessage());
            }
        }

        return objectFilter;
    }

    public static String buildSObjectFilterSelectionQuery(String sObjectName, String filterLogic, List<FiltersItemsWrapper> filterItems) {
        ObjectFilterWrapper filter = new ObjectFilterWrapper();
        filter.objectName = sObjectName;
        filter.items = filterItems;
        filter.filterLogic = filterLogic;
        return buildSObjectFilterSelectionQuery(filter);
    }

    public static String buildSObjectFilterSelectionQuery(ObjectFilterWrapper filter) {
        List<ChildObjectFilterWrapper> childFilters = (filter instanceof ParentObjectFilterWrapper)
            ? ((ParentObjectFilterWrapper)filter).childItems.values() : null;
        return buildSObjectFilterSelectionQuery(filter, childFilters);
    }

    public static String buildSObjectFilterSelectionQuery(ObjectFilterWrapper filter, List<ChildObjectFilterWrapper> childFilters) {
        String dynQuery = 'SELECT Id, Name';
        if (childFilters != null) {
            for (ChildObjectFilterWrapper childFilter : childFilters) {
                dynQuery += ', (' + buildChildSObjectFilterSelectionQuery(childFilter) + ')';
            }
        }
        dynQuery += ' FROM ' + filter.objectName;
        String conditions = EUR_CRM_DynamicGroupService.getConditions(getSelectionQueryCondition(filter));
        if(!String.isEmpty(conditions)) {
            dynQuery += ' WHERE (' + conditions + ')';
        }
        System.debug('dynQuery: ' + dynQuery);
        return dynQuery;
    }

    public static String buildChildSObjectFilterSelectionQuery(ChildObjectFilterWrapper childObjectFilter) {
        String dynQuery = getChildSObjectFilterSelectionBody(childObjectFilter);
        dynQuery += getSelectionQueryCondition(childObjectFilter);
        dynQuery += getChildSObjectFilterSelectionLimit(childObjectFilter);
        System.debug('childDynQuery: ' + dynQuery);
        return dynQuery;
    }

    public static String getChildSObjectFilterSelectionBody(ChildObjectFilterWrapper childObjectFilter) {
        return 'SELECT ' + childObjectFilter.childRelationshipField + ' FROM ' + childObjectFilter.childRelationshipName;
    }

    public static String getChildSObjectFilterSelectionLimit(ChildObjectFilterWrapper childObjectFilter) {
        return (parentRelationshipTypesWithLimitedChildRecords.contains(childObjectFilter.parentRelationType))
            ? ' LIMIT 1' : '';
    }

    public static String getSelectionQueryCondition(ObjectFilterWrapper filter) {
        String whereLogic = '';
        if (filter.items.isEmpty()) return whereLogic;

        whereLogic += getSelectionQueryWhereLogic(filter.filterLogic, filter.items.size());
        System.debug('whereLogic: ' + whereLogic);
        System.debug('\n\n filters => ' + JSON.serializePretty(filter.items) + '\n');

        for (Integer i = filter.items.size() - 1; i >= 0; i--) {
            String whereClause = '';
            FiltersItemsWrapper filterItem = filter.items[i];
            String fieldType;
            if(filterItem.field == 'RecordType.DeveloperName' || filterItem.field == 'Profile.Name') {
                List<String> relationSplit = filterItem.field.split('\\.');
                fieldType = getFieldType(relationSplit[0], relationSplit[1]);
            } else {
                fieldType = getFieldType(filter.objectName, filterItem.field);
            }
            System.debug('fieldType: ' + fieldType);
            // Get Operator
            String operator = filterItem.operator;
            System.debug('operator: ' + operator);
            String operatorsDescriptionString = operatorsDescriptionsStringsMap.get(operator);
            // Get Value
            String filterValue = filterItem.value;
            // Adapt values to SOQL expression
            List<String> splitValuesSet = adaptValueForSearch(filterValue, fieldType, operator);
            for (Integer j = 0; j < splitValuesSet.size(); j++) {
                String value = splitValuesSet[j];
                whereClause += operatorsDescriptionString
                    .replace('{field}', filterItem.field)
                    .replace('{value}', value);
                if (splitValuesSet.size() > 1 && j < splitValuesSet.size() - 1) {
                    whereClause += operatorsJoinLogicMap.get(operator);
                }
            }
            if (splitValuesSet.size() > 1) {
                whereClause = wrapCondition(whereClause);
            }
            System.debug('whereClause: ' + whereClause);
            // Replace condition in logic expression by its index
            whereLogic = whereLogic.replace('<exp>' + String.valueOf(i + 1) + '</exp>', whereClause);
        }

        return whereLogic;
    }

    public static void substitutePickListValues(String sObjectName, List<FiltersItemsWrapper> items, Boolean toLabel) {
        for (FiltersItemsWrapper item : items) {
            if(item.field == 'RecordType.DeveloperName' || item.field.containsIgnoreCase('__r.RecordType.DeveloperName')) continue;
            String fieldName = getFieldName(item.field);
            Schema.DescribeFieldResult fieldDescribe = getSObjectFieldDescribe(sObjectName, fieldName);
            String fieldType = String.valueOf(fieldDescribe.getType());
            if (item.value != null && (fieldType == 'PICKLIST' || fieldType == 'MULTIPICKLIST')) {
                List<String> splitValue = item.value.split(',');
                item.value = '';
                List<Schema.PicklistEntry> ple = fieldDescribe.getPicklistValues();
                for (Integer i = 0; i < splitValue.size(); i++) {
                    String formattedStr = splitValue[i].trim();
                    for (Schema.PicklistEntry f : ple) {
                        if (toLabel) {
                            if (formattedStr == f.getValue()) {
                                formattedStr = f.getLabel();
                            }
                        } else {
                            if (formattedStr == f.getLabel()) {
                                formattedStr = f.getValue();
                            }
                        }
                    }
                    item.value += formattedStr;
                    if (i < splitValue.size() - 1) item.value += ', ';
                }
            }
            System.debug('item.value: ' + item.value);
        }
    }

    public static void substituteDateFormats(String sObjectName, List<FiltersItemsWrapper> items, DateFormatTypes dateType) {
        for (FiltersItemsWrapper item : items) {
            if(item.field == 'RecordType.DeveloperName') continue;
            String fieldType = getFieldType(sObjectName, item.field);
            if (item.value != null && (fieldType == 'DATE' || fieldType == 'DATETIME')) {
                try {
                    List<String> splitValue = item.value.split(',');
                    item.value = '';
                    for (Integer i = 0; i < splitValue.size(); i++) {
                        String formattedStr = splitValue[i].trim();
                        if (String.isNotEmpty(formattedStr) && !isDateLiteralValue(formattedStr)) {
                            if (dateType == DateFormatTypes.GENERAL) {
                                formattedStr = getFormattedDateString(formattedStr, fieldType);
                            } else if (dateType == DateFormatTypes.LOCALE) {
                                formattedStr = getLocaleDateString(formattedStr, fieldType);
                            }
                        }
                        item.value += formattedStr;
                        if (i < splitValue.size() - 1) item.value += ',';
                    }
                } catch (Exception e) {
                    throw new FilterBuilderException(e.getMessage());
                }
            }
        }
    }

    public static void substituteRecordTypeValues(String sObjectName, List<FiltersItemsWrapper> items, Boolean toLabel) {
        for (FiltersItemsWrapper item : items) {
            if (item.field == 'RecordType.DeveloperName') {
                List<String> splitValue = item.value.split(',');
                item.value = '';
                Map<String, String> rtsMap = getSObjectAvailableTypes(sObjectName);
                for (Integer i = 0; i < splitValue.size(); i++) {
                    String formattedStr = splitValue[i].trim();
                    for(String rtName: rtsMap.keySet()) {
                        if (toLabel && formattedStr == rtsMap.get(rtName)) {
                            formattedStr = rtName;
                        } else if(!toLabel && formattedStr == rtName){
                            formattedStr = rtsMap.get(rtName);
                        }
                    }
                    item.value += formattedStr;
                    if (i < splitValue.size() - 1) item.value += ', ';
                }
            }
        }
    }

    private static String getSelectionQueryWhereLogic(String filterLogic, Integer filterSize) {
        String whereLogic = ' WHERE ';
        if (String.isNotEmpty(filterLogic)) {
            whereLogic += filterLogic;
        } else {
            for (Integer i = 1; i <= filterSize; i++) {
                whereLogic += i + (i != filterSize ? ' AND ' : '');
            }
        }
        return whereLogic.replaceAll('(\\d+)', '<exp>$1</exp>');
    }

    private static Schema.DescribeFieldResult getSObjectFieldDescribe(String sObjectName, String fieldApiName) {
        return getSObjectFields(sObjectName).get(fieldApiName).getDescribe();
    }

    private static Map<String, Schema.SObjectField> getSObjectFields(String sObjectName) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();

        return fieldMap;
    }

    private static String getFieldName(String field) {
        if (field.containsIgnoreCase('__r.')) {
            return field.split('__r.')[0] + '__c';
        }

        String strToReturn = '';
        List<String> strSplit = field.split('__r.');
        strToReturn = strSplit[strSplit.size() - 1];
        return strToReturn;
    }

    private static String getFieldType(String sObjectName, String fieldName) {
        Schema.DescribeFieldResult fieldDescribe = getSObjectFieldDescribe(sObjectName, getFieldName(fieldName));
        return String.valueOf(fieldDescribe.getType());
    }

    public static Map<String, String> getSObjectAvailableTypes(String sObjectName) {
        Map<String, String> rtsMap = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult obj = schemaMap.get(sObjectName).getDescribe();
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();
        for(RecordType rt : EUR_CRM_RecordTypeHelper_v2.getObjectRts(sObjectName).values()) {
            if (recordTypeInfos.get(rt.Id) != null && recordTypeInfos.get(rt.Id).isAvailable() && recordTypeInfos.get(rt.Id).isActive()) {
                rtsMap.put(rt.Name, rt.DeveloperName);
            }
        }
        return rtsMap;
    }

    public static Map<Id, String> getSObjectAvailableRecordTypes(String sObjectName) {
        Map<Id, String> rtsMap = new Map<Id, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult obj = schemaMap.get(sObjectName).getDescribe();
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosById();
        for (RecordTypeInfo rtInfo : recordTypeInfos.values()) {
            if (rtInfo.isActive() && rtInfo.isAvailable() && (!rtInfo.isMaster())) {
                rtsMap.put(rtInfo.getRecordTypeId(), rtInfo.getName());
            }
        }
        return rtsMap;
    }

    public static Map<Id, String> getSObjectAvailableRecordTypesWhereCountryCodes(String sObjectName, List<String> countryCodes) {
        Map<Id, String> rtsMap = new Map<Id, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult obj = schemaMap.get(sObjectName).getDescribe();
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosById();
        for (RecordTypeInfo rtInfo : recordTypeInfos.values()) {
            String rtCc = extractCountryCode(rtInfo.getDeveloperName());
            if (isValidRt(rtInfo) && countryCodes.contains(rtCc)) {
                rtsMap.put(rtInfo.getRecordTypeId(), rtInfo.getName());
            }
        }
        return rtsMap;
    }

    private static Boolean isValidRt(RecordTypeInfo rtInfo) {
        return rtInfo.isActive() && rtInfo.isAvailable() && (!rtInfo.isMaster());
    }

    private static String extractCountryCode(String rtDevName) {
        return rtDevName.substringBetween('EUR_', '_');
    }

    private static List<String> adaptValueForSearch(String value, String fieldType, String operator) {
        System.debug('filter value: ' + value);
        List<String> values = new List<String>();
        Set<String> conditionValues = new Set<String>();
        String operatorWildcard = getOperatorWildcard(operator);
        Boolean emptyValueEntered = false;
        if (String.isNotEmpty(value)) {
            List<String> splitValue = value.split(',', -1);
            for (Integer i = 0; i < splitValue.size(); i++) {
                String singleValue = String.escapeSingleQuotes(splitValue[i].trim());
                if (String.isNotEmpty(singleValue)) {
                    singleValue = wrapValueInQuotes(operatorWildcard.replace('{value}', singleValue), fieldType);
                    conditionValues.add(singleValue);
                } else {
                    conditionValues.add('null');
                    emptyValueEntered = true;
                }
            }
        } else {
            conditionValues.add('null');
            emptyValueEntered = true;
        }
        System.debug('conditionValues: ' + conditionValues);
        if (emptyValueEntered) checkOperatorEmptyValueAllowance(operator);
        values.addAll(conditionValues);
        return values;
    }

    private static String getOperatorWildcard(String operatorLabel) {
        if (operatorWildCards.containsKey(operatorLabel)) {
            return operatorWildCards.get(operatorLabel);
        }
        return '{value}';
    }

    private static String wrapValueInQuotes(String value, String fieldType) {
        if (fieldTypesShouldEnclosedInQuotes.contains(fieldType)) {
            return '\'' + value + '\'';
        } else {
            return value;
        }
    }

    private static String wrapCondition(String value) {
        return '(' + value + ')';
    }

    private static void checkOperatorEmptyValueAllowance(String operator) {
        if (!emptyValueAllowedOperators.contains(operator)) {
            throw new FilterBuilderException(Label.EUR_CRM_TM_OperatorValueError);
        }
    }

    private static String getFormattedDateString(String value, String fieldType) {
        if (fieldType == 'DATE') {
            value = value.replace(value.trim(), String.valueOf(Date.parse(value.trim())));
        } else if (fieldType == 'DATETIME') {
            value = value.replace(value.trim(), String.valueOf(DateTime.parse(value.trim())));
            value = value.replace(' ', 'T');
            value += 'Z';
        }
        return value;
    }

    private static String getLocaleDateString(String value, String fieldType) {
        if (fieldType == 'DATE') {
            value = value.replace(value.trim(), String.valueOf(Date.valueOf(value.trim()).format()));
        } else if (fieldType == 'DATETIME') {
            value = value.replace('T', ' ');
            value = value.replace('Z', '');
            value = value.replace(value.trim(), String.valueOf(Datetime.valueOf(value.trim()).format()));
        }
        return value;
    }

    private static void validateQuery(String dynamicQuery) {
        try {
            dynamicQuery += ' LIMIT 1';
            System.debug(dynamicQuery);
            List<sObject> sObjectsList = Database.query(dynamicQuery);
            System.debug(sObjectsList.size());
        } catch (Exception e) {
            throw new FilterBuilderException(e.getMessage());
        }
    }

    /*
    Field Validation Block Start
     */
    private static void validateFieldsValue(String sObjectName, List<FiltersItemsWrapper> filterItems) {
        for (FiltersItemsWrapper item : filterItems) {
            if (item.value == null) continue;
            List<String> splitValue = item.value.split(',');
            Schema.DescribeFieldResult fieldDescribe;
            if(item.field == 'RecordType.DeveloperName') {
                List<String> relationSplit = item.field.split('\\.');
                fieldDescribe = getSObjectFieldDescribe(relationSplit[0], relationSplit[1]);
            } else {
                String fieldName = getFieldName(item.field);
                fieldDescribe = getSObjectFieldDescribe(sObjectName, fieldName);
            }
            try {
                validateFieldValue(splitValue, fieldDescribe);
            } catch (Exception e) {
                System.debug(e.getLineNumber() + e.getMessage());
                throw new FilterBuilderException(fieldDescribe.getLabel() + ' ' + Label.EUR_CRM_TM_FieldError + ': ' + e.getMessage());
            }
        }
    }

    private static void validateFieldValue(List<String> values, Schema.DescribeFieldResult fieldDescribe) {
        String fieldType = String.valueOf(fieldDescribe.getType());
        if (fieldType == 'BOOLEAN') {
            validateBooleanValues(values);
        } else if (fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'CURRENCY') {
            validateNumberValues(values);
        } else if (fieldType == 'PICKLIST') {
            validatePickListValues(values, fieldDescribe);
        } else if (fieldType == 'ID' || fieldType == 'REFERENCE') {
            validateIdValues(values);
        } else if (fieldType == 'DATE') {
            validateDateValues(values);
        } else if (fieldType == 'DATETIME') {
            validateDatetimeValues(values);
        }
    }

    private static void validateBooleanValues(List<String> values) {
        for (String value : values) {
            String trimValue = value.trim();
            if (String.isNotEmpty(trimValue) && !BOOLEAN_CONSTANTS.contains(trimValue.toUpperCase())) {
                throw new FilterBuilderException(Label.EUR_CRM_TM_BoolConditionError);
            }
        }
    }

    private static void validateNumberValues(List<String> values) {
        try {
            for (String value : values) {
                String trimValue = value.trim();
                if (String.isNotEmpty(trimValue)) {
                    Decimal.valueOf(trimValue);
                }
            }
        } catch (Exception e) {
            throw new FilterBuilderException(Label.EUR_CRM_TM_Invalidnumber);
        }
    }

    private static void validateIdValues(List<String> values) {
        try {
            for (String value : values) {
                String trimValue = value.trim();
                if (String.isNotEmpty(trimValue)) {
                    Id.valueOf(trimValue);
                }
            }
        } catch (Exception e) {
            throw new FilterBuilderException(e.getMessage());
        }
    }

    private static void validateDateValues(List<String> values) {
        try {
            for (String value : values) {
                String trimValue = value.trim();
                if (String.isNotEmpty(trimValue) && !isDateLiteralValue(trimValue)) {
                    Date.parse(trimValue);
                }
            }
        } catch (Exception e) {
            throw new FilterBuilderException(Label.EUR_CRM_TM_InvalidDateError.replace('{value}', Date.today().format()));
        }
    }

    private static void validateDatetimeValues(List<String> values) {
        try {
            for (String value : values) {
                String trimValue = value.trim();
                if (String.isNotEmpty(trimValue) && !isDateLiteralValue(trimValue)) {
                    DateTime.parse(trimValue);
                }
            }
        } catch (Exception e) {
            throw new FilterBuilderException(Label.EUR_CRM_TM_InvalidDateError.replace('{value}', DateTime.now().format()));
        }
    }

    private static void validatePickListValues(List<String> values, Schema.DescribeFieldResult fieldDescribe) {
        List<Schema.PicklistEntry> ple = fieldDescribe.getPicklistValues();
        Set<String> picklistValues = new Set<String>();
        for (Schema.PicklistEntry f : ple) {
            picklistValues.add(f.getLabel().toLowerCase());
        }
        for (String value : values) {
            if (String.isNotEmpty(value.trim()) && !picklistValues.contains(value.trim().toLowerCase())) {
                throw new FilterBuilderException(Label.EUR_CRM_TM_PicklistError.replace('{value}', value));
            }
        }
    }
    /*
    Field Validation Block End
     */

    private static Boolean isDateLiteralValue(String value) {
        System.debug(value);
        List<String> dateLiteralParts = value.split(':');
        System.debug(dateLiteralParts.size());
        if (dateLiteralParts.size() == 1) {
            if (dateLiterals.contains(value)) {
                return true;
            }
        } else {
            if (dateLiterals.contains(dateLiteralParts[0] + ':n')) {
                Decimal.valueOf(dateLiteralParts[1]);
                return true;
            }
        }
        return false;
    }

    public virtual class ObjectFilterWrapper {
        public String objectName;
        public List<FiltersItemsWrapper> items;
        public String filterLogic;
        public String testQuery;
    }

    public class ParentObjectFilterWrapper extends ObjectFilterWrapper {
        public Map<String, ChildObjectFilterWrapper> childItems;
    }

    public class ChildObjectFilterWrapper extends ObjectFilterWrapper {
        public String childRelationshipName;
        public String childRelationshipField;
        public String parentRelationType;
    }

    public class FiltersItemsWrapper {
        public String field;
        public String operator;
        public String value;
    }

    public class FilterBuilderException extends Exception {
    }

}