public with sharing class ASI_HK_CRM_CommonUtils {
//v4
    public static String genQueryString(Set<String> queryFields, String sObjStr) {
        return genQueryString(queryFields, sObjStr, null);
    }
    public static String genQueryString(Set<String> queryFields, String sObjStr, String whereStatm) {
        return genQueryString(queryFields, sObjStr, whereStatm, null);
    }
    public static String genQueryString(Set<String> queryFields, String sObjStr, String whereStatm, String extraStr) {
        if (sObjStr != null && sObjStr.trim() != '') {
            if (queryFields == null) {
                queryFields = allFieldsOfSObject(sObjStr);
            }
            if (queryFields != null && queryFields.size() > 0) {
                String strFormat = 'SELECT {0} FROM {1}';
                if (whereStatm != null && whereStatm.trim() != '') strFormat += ' WHERE {2}';
                if (extraStr != null && extraStr.trim() != '') strFormat += ' {3}';
                Set<String> queryFieldsLower = new Set<String>();
                for (String queryField : queryFields) {
                    queryFieldsLower.add(queryField.toLowerCase());
                }
                if (!queryFieldsLower.contains('count()')) {
                    queryFieldsLower.add('id');
                }
                return String.format(strFormat, new String[] {
                    String.join(new List<String>(queryFieldsLower), ',')
                    , sObjStr
                    , whereStatm
                    , extraStr
                });
            }
        }
        return null;
    }
    public static Set<String> allFieldsOfSObject(String sObjStr) {
        Set<String> result = new Set<String>();
        if (sObjStr != null && sObjStr.trim() != '') {
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(sObjStr);
            if (sObjType != null) {
                Set<String> tempFieldSet = sObjType.getDescribe().fields.getMap().keySet();
                for (String f : tempFieldSet) {
                    result.add(f.toLowerCase());
                }
            }
        }
        return result;
    }
}