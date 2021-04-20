public with sharing class GDT_GeneralConfigDAO {
    

        //Map to store in a context status values of General config and avoid the same SOQL call. 
    private static Map<String,String> maKeyWithGeneralConfigValues = new Map<String,String>();

    static{
        List<GDT_GeneralConfig__c> listGeneralConfigValues = [select Name,GDT_Value__c from GDT_GeneralConfig__c];
        for(GDT_GeneralConfig__c cConfig : listGeneralConfigValues ){
            maKeyWithGeneralConfigValues.put(cConfig.Name,cConfig.GDT_Value__c);
        }
    }

    /* recovers de config from the CustomSetting and parse it as a StringArray. Each value separated with 'regexp' */
    public static String[] getValueAsStringArray(String key, String regexp) {
        if(maKeyWithGeneralConfigValues.containsKey(key) ){
            if(maKeyWithGeneralConfigValues.get(key) != null){
             return maKeyWithGeneralConfigValues.get(key).split(regexp, 0);
            }
        }
        return null;
    }

    public static String[] getValueAsStringArray(String key, String regexp, boolean returnEmptyIfNotExists) {
        String[] result = getValueAsStringArray(key, regexp);
        if (returnEmptyIfNotExists && (result == null)) {
            result = new List<String>();
        } 
        return result;
    }

    public static Set<String> getValueAsStringSet(String key, String regexp, boolean returnEmptyIfNotExists) {
        Set<String> result = null;
        List<String> data = getValueAsStringArray(key, regexp);
        if (returnEmptyIfNotExists && (data == null)) {
            result = new Set<String>();
        } else if (data != null) {
            result = new Set<String>(data);
        }
        return result;
    }
}