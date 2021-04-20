global class EUR_NIM_FilteredListController
{
    @AuraEnabled
    public static List<sObject> querySObject(String sObjectName, List<String> fields, String whereClause) {
        String query = '';
        if (String.isNotBlank(whereClause))
        {
            query = ' WHERE ' + whereClause;
        }
        System.debug(query);
        System.debug(fields);
        String fieldString = ' Id';

        Set<String> fieldSet = new Set<String>();
        for (String field : fields)
        {
            System.debug(field);
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(field);


            if (m.get('soqlStmt') != null)
            {
                fieldSet.add((String)m.get('soqlStmt'));
            }
            // add to soql field from fron-end resriction. Assume that fron-end resriction in format fieldName=fieldValue (Relation.Type='User')
            else if (m.get('frontendFilterRestriction') != null)
            {
                fieldSet.add( ((String) m.get('frontendFilterRestriction')).substringBefore('=') );
            }
            else if (m.get('fieldName') != null && (String)m.get('fieldName') != 'Id')
            {
                fieldSet.add((String) m.get('fieldName'));
            }

            if (m.get('currencyFieldName') != null)
                fieldSet.add((String)m.get('currencyFieldName'));
        }

        fieldString = String.join(new List<String>(fieldSet), ',');

        query = 'SELECT ' + fieldString + ' FROM ' + sObjectName + ' ' + query + ' limit 1000000';
        System.debug(query);

        try
        {
            return Database.query(query);
        }
        catch (Exception ex)
        {
            AuraHandledException e = new AuraHandledException(ex.getMessage() + ' Executed Query: '  + query);
            throw e;
        }

    }

    @AuraEnabled
    public static List<Map<String, String>> getSObjectFieldList(String sObjectName) {
        List<Map<String, String>> fieldsToReturn = new List<Map<String, String>>();
        Schema.DescribeSObjectResult dsor = Schema.describeSObjects(new String[]{sObjectName})[0];
        // the map to be returned with the final data

        Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();

        // iterate over the requested fields and get the describe info for each one.
        // add it to a map with field name as key
        for(String field : objectFields.keySet())
        {
            // skip fields that are not part of the object
            Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
            if (dr.isAccessible() ) {
                Map<String, String> fm = new Map<String, String>();
                fm.put('fieldName', dr.getLocalName());
                fm.put('value', dr.getLocalName());
                fm.put('label', dr.getLabel());
                fm.put('type', dr.getType().name());

                fieldsToReturn.add(fm);
            }
        }
        System.debug(fieldsToReturn);

        return fieldsToReturn;
    }
    
    @AuraEnabled
    public static Object getTranslations()
    {
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();

        Map<String, Object> ret = new Map<String, Object>();
        ret.putAll((Map<String, Object>)translateSObject('Account', gdMap));

        Map<String, Object> theMap = new Map<String,Object>();
/*

        theMap.put('Account__c_Status__c', toOptionList(getOptionsForDescribe(Account.XXXX.getDescribe()),true));
*/
        ret.put('picklists' , theMap);
        return ret;
    }
    
    public static Map<String, String> translateSObject(String selectedObject, Map<String, Schema.SObjectType> gdMap)
    {
        Map<String, String> ret = new Map<String, String>();
        Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();


        List<SelectOption> soList = new List<SelectOption>();
        for(String key : fieldMap.keySet())
        {
            Schema.DescribeFieldResult describe =  fieldMap.get(key).getDescribe();

            ret.put(selectedObject + '_' + describe.getName() , describe.getLabel());
        }

        return ret;
    }


    @AuraEnabled
    public static Object getParent(Id parentId)
    {
        String pluralLabel = parentId.getSObjectType().getDescribe().getLabelPlural();
        String objectType = parentId.getSObjectType().getDescribe().getName();

        String query = 'SELECT Id, Name FROM ' + objectType + ' WHERE Id = \'' + parentId + '\'';

        List<sObject> results = Database.query(query);

        Parent parentObject = new Parent();
        parentObject.Name = (String)results[0].get('Name');
        parentObject.pluralLabel = pluralLabel;

        system.debug('parentObject === ' + parentObject);

        return JSON.serialize(parentObject);
    }

    public class Parent {
        public String pluralLabel;
        public String name;
    }
}