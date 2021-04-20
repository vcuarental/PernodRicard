/**
 * Created by larsz on 8/3/2020.
 */

public with sharing class EUR_CRM_LookupFieldController {
    @AuraEnabled
    public static List<SObject> getRecentRecords(String ObjectName, List<String> ReturnFields, Integer MaxResults) {

        List<Id> recentIds = new List<Id>();

        for (RecentlyViewed recent : [
                SELECT Id
                FROM RecentlyViewed
                WHERE Type = :ObjectName
                ORDER BY LastViewedDate DESC
                LIMIT :MaxResults
        ]) {
            recentIds.add(recent.Id);
        }

        String sQUERY = 'SELECT Id, ';

        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';
        }

        sQuery += ' FROM ' + ObjectName + ' WHERE Id IN :recentIds';

        List<sObject> searchResult = Database.query(sQuery);

        return searchResult;
    }

    @AuraEnabled
    public static List<sObject> searchRecords(String ObjectName, List<String> ReturnFields, List<String> QueryFields,
            String SearchText, String SortColumn, String SortOrder, Integer MaxResults, String Filter) {

        //always put a limit on the results
        if (MaxResults == null || MaxResults == 0) {
            MaxResults = 5;
        }

        SearchText = '%' + SearchText + '%';

        String sQuery = 'SELECT Id, ';

        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';
        }

        sQuery += ' FROM ' + ObjectName + ' WHERE Name LIKE :SearchText';

        if (string.isNotBlank(SortColumn) && string.isNotBlank(SortOrder)) {
            sQuery += ' ORDER BY ' + SortColumn + ' ' + SortOrder;
        }

        sQuery += ' LIMIT ' + MaxResults;

        System.debug(sQuery);

        List <sObject> searchResult = Database.query(sQuery);

        return searchResult;
    }

    @AuraEnabled
    public static List<sObject> getRecord(String ObjectName, List<String> ReturnFields, String Id) {
        String sQUERY = 'SELECT Id, ';

        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';
        }

        sQuery += ' FROM ' + ObjectName + ' WHERE Id = :Id';

        List<sObject> searchResult = Database.query(sQuery);

        return searchResult;
    }

    @AuraEnabled
    public static string findObjectIcon(String ObjectName) {
        for (Schema.DescribeTabSetResult describeTabSetResult : Schema.describeTabs()) {
            for (Schema.DescribeTabResult describeTabResult : describeTabSetResult.getTabs()) {
                if (describeTabResult.getSobjectName() == ObjectName) {
                    if (describeTabResult.isCustom() == true) {
                        for (Schema.DescribeIconResult describeIcon : describeTabResult.getIcons()) {
                            if (describeIcon.getContentType() == 'image/svg+xml') {
                                return 'custom:' + describeIcon.getUrl().substringBetween('custom/', '.svg').substringBefore('_');
                            }
                        }
                    } else {
                        return 'standard:' + ObjectName.toLowerCase();
                    }
                }
            }
        }

        return 'standard:default';
    }

    @AuraEnabled
    public static objectDetails getObjectDetails(String ObjectName) {

        objectDetails details = new objectDetails();

        Schema.DescribeSObjectResult describeSobjectsResult = Schema.describeSObjects(new List<String>{
                ObjectName
        })[0];

        details.label = describeSobjectsResult.getLabel();
        details.pluralLabel = describeSobjectsResult.getLabelPlural();

        details.iconName = findObjectIcon(ObjectName);

        return details;
    }

    public class objectDetails {
        @AuraEnabled
        public string iconName;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string pluralLabel;
    }
}