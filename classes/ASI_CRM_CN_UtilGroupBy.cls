/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_UtilGroupBy
 * Description: Apex class for ASI_CRM_CN_UtilGroupBy
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-02-08       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_UtilGroupBy {
    public static Map<Id, List<SObject>> groupByIds(String apiFieldName, List<SObject> records) {
        Map<Id, List<SObject>> grouped = new Map<Id, List<SObject>>();
        for (SObject rec : records) {
            Id key = (Id) rec.get(apiFieldName);
            if (!grouped.containsKey(key)) {
                grouped.put(key, (List<SObject>) new List<SObject>{});
            }
            grouped.get(key).add(rec);
        }
        return grouped;
    }

    public static Map<String, List<SObject>> groupByStrings(String apiFieldName, List<SObject> records) {
        Map<String, List<SObject>> grouped = new Map<String, List<SObject>>();
        for (SObject rec : records) {
            String key = '';
            if (apiFieldName.contains(';')) {
                key = getValuesFromFieldNames(apiFieldName, rec);
                if (key.countMatches(';') != apiFieldName.countMatches(';')) {
                    continue;
                }
            } else {
                key = (String) rec.get(apiFieldName);
            }

            if (!grouped.containsKey(key)) {
                grouped.put(key, (List<SObject>) new List<SObject>{});
            }
            grouped.get(key).add(rec);
        }
        return grouped;
    }

    /**
     * Get values from fieldNames string. Assume all values can be casted to string.
     *
     * @param apiFieldNames Field names separated by semicolons. For example ASI_CRM_CN_Supplier__c;ASI_CRM_Account__c
     * @param record Record which values are get from
     *
     * @return Values separated by semicolons
     */
    public static String getValuesFromFieldNames(String apiFieldNames, SObject record){
        List<String> fieldNames = apiFieldNames.split(';');
        List<String> values = new List<String>();

        for (String fieldName : fieldNames) {
            values.add((String) record.get(fieldName));
        }

        return String.join(values, ';');
    }
}