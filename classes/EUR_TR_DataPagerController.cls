/**
 * Created by bsavcı on 8/27/2020.
 */

public with sharing class EUR_TR_DataPagerController {

    @AuraEnabled
    public static List<ObjectField> getAllFields(String objName) {
        //isNamePointing may be true for lookup relationships so isNamePointing will be false for a SObject
        return getAllFields(objName, false);
    }
    @AuraEnabled
    public static List<ObjectField> getAllFieldsOfLookup(List<String> referenceObjectNames, Boolean isNamePointing) {
        List<ObjectField> responseList = new List<ObjectField>();
        for (String referenceObjectName : referenceObjectNames) {
            responseList.addAll(getAllFields(referenceObjectName, isNamePointing));
        }
        return responseList;
    }
    private static List<ObjectField> getAllFields(String objName, Boolean isNamePointing) {
        Map<String, Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objToken = objGlobalMap.get(objName);

        Map<String, Schema.SObjectField> allFields = objToken.getDescribe().fields.getMap();
        List<ObjectField> responseList = new List<ObjectField>();

        for (Schema.SObjectField sField : allFields.values()) {
            Schema.DescribeFieldResult dField = sField.getDescribe();
            if (!dField.isFilterable() || dField.getType().name() == 'ID' || !dField.isAccessible()
                    || (!objToken.getDescribe().isCustom() && dField.getType().name() == 'REFERENCE')
                    || dField.getName() == 'IsDeleted'
                    || dField.isDeprecatedAndHidden()
                    || (isNamePointing && !dField.isNameField())) {
                continue;
            }

            ObjectField field = new ObjectField();
            field.label = dField.getType().name() == 'REFERENCE' ? dField.getLabel().replace('ID', '') + '>' : dField.getLabel();
            field.value = dField.getName();
            field.type = String.valueOf(dField.getType());
            field.references = new List<String>();
            field.objectName = objName;
            field.isNamePointing = dField.isNamePointing(); //Info about isNamePointing https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_calls_describesobjects_describesobjectresult.htm
            if (dField.getType().name() == 'REFERENCE') {
                field.references.add(dField.getReferenceTo()[0].getDescribe().name);
            }
            responseList.add(field);
        }
        return responseList;
    }

    @AuraEnabled
    public static List<ObjectField> getFieldOptions(String objName, String fieldName) {
        List<ObjectField> responseList = new List<ObjectField>();

        Schema.SObjectType SObjName = Schema.getGlobalDescribe().get(objName);

        Schema.SObjectType objType = SObjName.newSObject().getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

        List<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPicklistValues();

        for (Schema.PicklistEntry entry : values) {
            ObjectField field = new ObjectField();
            field.label = String.isBlank(entry.getLabel()) ? entry.getValue() : entry.getLabel();
            field.value = entry.getValue();
            responseList.add(field);
        }
        return responseList;
    }

    @AuraEnabled
    public static QueryResponse query(QueryRequest request) {

        ensurePageSizeInRange(request);

        QueryResponse response = new QueryResponse();
        String query = prepareQuery(request);
        response.total = getTotalCount(request);
        response.data = getData(request, query);
        response.pageMap = createPagerMap(request, query);
        response.queryString = query;
        return response;
    }

    private static List<Map<String, Object> > createPagerMap(QueryRequest request, String query) {
        List<Map<String, Object> > result = new List<Map<String, Object> >();
        Id lastPagedItemId = request.pagerStartId;
        String pagedQuery = query;
        for (Integer i = 0; i < request.pagerCount; i++) {
            if (String.isNotEmpty(String.valueOf(lastPagedItemId))) {
                if (pagedQuery.containsIgnoreCase(' WHERE ')) {
                    pagedQuery += ' and ';
                } else {
                    pagedQuery += ' WHERE ';
                }
                pagedQuery += ' ID >= \'' + String.valueOf(lastPagedItemId) + '\'';
            }
            pagedQuery += ' ORDER BY ID ';
            pagedQuery += ' LIMIT 1 ';
            if (i > 0) {
                pagedQuery += ' OFFSET ' + String.valueOf(request.pageSize);
            }
            System.debug(pagedQuery);
            List<SObject> items = Database.query(pagedQuery);
            if (items.size() == 0) {
                break;
            }
            Integer pageCurrentIndex = request.pagerStartIndex + i;
            Id pageCurrentId = items[0].Id;
            Map<String, Object> mapItem = new Map<String, Object>();
            mapItem.put('Index', pageCurrentIndex);
            mapItem.put('Id', pageCurrentId);
            result.add(mapItem);
            pagedQuery = query;
            lastPagedItemId = pageCurrentId;
        }
        return result;
    }

    private static List<SObject> getData(QueryRequest request, String query) {
        if (String.isNotEmpty(String.valueOf(request.selectedPageFirstId))) {
            if (query.containsIgnoreCase(' WHERE ')) {
                query += ' and ';
            } else {
                query += ' WHERE ';
            }
            query += ' ID >= \'' + String.valueOf(request.selectedPageFirstId) + '\'';
        }
        query += ' ORDER BY ID ';
        query += ' LIMIT ' + request.pageSize;
        System.debug(query);
        return Database.query(query);
    }


    private static void ensurePageSizeInRange(QueryRequest request) {
        if (request.pageSize == null || request.pageSize < 5) {
            request.pageSize = 5;
        } else if (request.pageSize > 2000) {
            request.pageSize = 2000;
        }
    }

    private static String prepareQuery(QueryRequest request) {
        String query = 'SELECT ' + String.join(request.fields, ',') + ' FROM ' + request.objectName;
        if (String.isNotBlank(request.filter)) {
            query += ' WHERE ' + request.filter;
        }
        System.debug(query);
        return query;
    }
    private static Integer getTotalCount(QueryRequest request) {
        String query = 'SELECT Count(ID) total FROM ' + request.objectName;
        if (String.isNotBlank(request.filter)) {
            query += ' WHERE ' + request.filter;
        }
        System.debug(query);
        AggregateResult result = (AggregateResult) Database.query(query);
        return (Integer) result.get('total');
    }

    public class ObjectField {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String objectName { get; set; }
        @AuraEnabled
        public Boolean isNamePointing { get; set; }
        @AuraEnabled
        public List<String> references { get; set; }
    }

    public class QueryRequest {
        @AuraEnabled
        public String objectName { get; set; }
        @AuraEnabled
        public String filter { get; set; }
        @AuraEnabled
        public List<String> fields { get; set; }
        @AuraEnabled
        public Integer pageSize { get; set; }
        @AuraEnabled
        public Id selectedPageFirstId { get; set; }
        @AuraEnabled
        public Integer pagerCount { get; set; }
        @AuraEnabled
        public Integer pagerStartIndex { get; set; }
        @AuraEnabled
        public Id pagerStartId { get; set; }
    }

    public class QueryResponse {
        @AuraEnabled
        public List<SObject> data { get; set; }
        @AuraEnabled
        public Integer total { get; set; }
        @AuraEnabled
        public List<Map<String, Object> > pageMap { get; set; }
        @AuraEnabled
        public String queryString { get; set; }
    }
}