/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_UtilPluck
 * Description: Get a field from a list and return that. Similar to Array.map() in Javascript
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-29       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_UtilPluck {
    public static Set<Id> pluckIds(Schema.SObjectField field, List<SObject> records) {
        Set<Id> results = new Set<Id>();
        for (SObject rec : records) {
            results.add((Id)rec.get(field));
        }
        return results;
    }

}