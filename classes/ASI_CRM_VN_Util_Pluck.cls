/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_Util_Pluck
 * Description: Functional programming to write less code and more readable. Credit to: https://github.com/ipavlic/apex-lambda
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-02       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_VN_Util_Pluck {
    public static List<Date> dates(List<SObject> records, Schema.SObjectField field) {
        List<Date> results = new List<Date>();
        for (SObject rec : records) {
            results.add((Date)rec.get(field));
        }
        return results;
    }
    public static List<Decimal> decimals(List<SObject> records, Schema.SObjectField field) {
        List<Decimal> results = new List<Decimal>();
        for (SObject rec : records) {
            results.add((Decimal)rec.get(field));
        }
        return results;
    }
    public static Set<Id> ids(List<SObject> records, Schema.SObjectField field) {
        Set<Id> results = new Set<Id>();
        for (SObject rec : records) {
            results.add((Id)rec.get(field));
        }
        return results;
    }
    public static Set<Id> ids(List<SObject> records) {
        Set<Id> results = new Set<Id>();
        for (SObject rec : records) {
            results.add(rec.Id);
        }
        return results;
    }
    public static List<String> strings(List<SObject> records, Schema.SObjectField field) {
        List<String> results = new List<String>();
        for (SObject rec : records) {
            results.add((String)rec.get(field));
        }
        return results;
    }
}