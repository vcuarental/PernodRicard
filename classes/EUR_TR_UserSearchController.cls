/**
 * Created by osman on 18.12.2020.
 */

public with sharing class EUR_TR_UserSearchController {

    class EUR_TR_UserSearchControllerException extends Exception {
    }

    @AuraEnabled
    public static List<Object> getFilters() {

        Filter titleFilter = new Filter();
        titleFilter.label = 'Ünvan';
        titleFilter.value = 'Title';
        titleFilter.fieldType = 'STRING';

        Filter roleFilter = new Filter();
        roleFilter.label = 'Rol';
        roleFilter.value = 'UserRole.DeveloperName';
        roleFilter.picklistOptions = getUserRoles();
        roleFilter.fieldType = 'PICKLIST';


        Filter profileFilter = new Filter();
        profileFilter.label = 'Profil';
        profileFilter.value = 'Profile.Name';
        profileFilter.fieldType = 'PICKLIST';
        profileFilter.picklistOptions = getUserProfiles();

        Filter nameFilter = new Filter();
        nameFilter.label = 'İsim';
        nameFilter.value = 'Name';
        nameFilter.fieldType = 'STRING';

        Filter cityFilter = new Filter();
        cityFilter.label = 'Bölge/Şehir';
        cityFilter.value = 'EUR_TR_CityName__c';
        cityFilter.fieldType = 'PICKLIST';
        cityFilter.picklistOptions = getPicklistOptions('EUR_TR_Account__c', 'EUR_TR_CityName__c');
        cityFilter.isUserField = false;

        Filter channelFilter = new Filter();
        channelFilter.label = 'Kanal';
        channelFilter.value = 'EUR_TR_Channel__c';
        channelFilter.fieldType = 'PICKLIST';
        channelFilter.picklistOptions = getPicklistOptions('EUR_TR_Account__c', 'EUR_TR_Channel__c');
        channelFilter.isUserField = false;

        Filter managerFilter = new Filter();
        managerFilter.label = 'Yönetici';
        managerFilter.value = 'ManagerId';
        managerFilter.fieldType = 'PICKLIST';
        managerFilter.picklistOptions = getManagers();
        managerFilter.isUserField = false;

        List<Filter> filters = new List<Filter>{
                titleFilter,
                roleFilter,
                profileFilter,
                nameFilter,
                channelFilter,
                cityFilter,
                managerFilter
        };

        return filters;
    }

    @AuraEnabled
    public static List<String> getUsersByQueryFilter(UserQueryFilterRequest userQueryFilterRequest) {

        System.debug(JSON.serializePretty(userQueryFilterRequest));

        Set<Id> userIds = new Set<Id>();

        if (userQueryFilterRequest.fieldName != null && String.isNotBlank(userQueryFilterRequest.fieldName) && (userQueryFilterRequest.selectedOptions == null || userQueryFilterRequest.selectedOptions.isEmpty())) {
            throw new EUR_TR_UserSearchControllerException('Lütfen seçim yapınız');
        }

        if (userQueryFilterRequest.fieldName == 'EUR_TR_CityName__c') {

            if (userQueryFilterRequest.queryReference == 'byOwner') {
                userIds = getUsersByOwner(userQueryFilterRequest);
            }

            if (userQueryFilterRequest.queryReference == 'bySalesChief') {
                userIds = getUsersBySalesChiefName(userQueryFilterRequest);
            }

        } else if (userQueryFilterRequest.fieldName == 'EUR_TR_Channel__c') {

            if (userQueryFilterRequest.queryReference == 'byOwner') {
                userIds = getUsersByOwner(userQueryFilterRequest);
            }

            if (userQueryFilterRequest.queryReference == 'bySalesChief') {
                userIds = getUsersBySalesChiefName(userQueryFilterRequest);
            }

        } else if (userQueryFilterRequest.fieldName == 'ManagerId') {

            Map<Id, User> userMap = new Map<Id, User>([
                    SELECT Id
                    FROM User
                    WHERE ManagerId IN :userQueryFilterRequest.selectedOptions AND Profile.Name LIKE '%EUR TR%'
                    LIMIT 2000
            ]);

            userIds = userMap.keySet();

        }

        List<String> listOfUserIdString = new List<String>();
        for (Id userId : userIds) {
            listOfUserIdString.add(userId);
        }

        return listOfUserIdString;

    }

    @AuraEnabled
    public static String generateQueryByUserIds(List<String> userIds) {

        String query = '';
        Set<String> userIdSet = new Set<String>(userIds);
        List<String> formattedUserIdsToFilter = new List<String>();

        for (Id userId : userIdSet) {

            String result = String.format('{0}', new List<String>{
                    userId
            });
            result = '\'' + result + '\'';
            formattedUserIdsToFilter.add(result);
        }

        if (!formattedUserIdsToFilter.isEmpty()) {
            String InQueryStatement = String.join(formattedUserIdsToFilter, ',');
            query = String.format('Id IN ({0})', new List<String>{
                    InQueryStatement
            });
        }

        if (String.isBlank(query)) {
            query = 'Id=NULL';
        }

        return query;

    }


    private static Set<Id> getUsersBySalesChiefName(UserQueryFilterRequest userQueryFilterRequest) {

        System.debug(JSON.serializePretty(userQueryFilterRequest));

        if (userQueryFilterRequest.fieldName != null && String.isNotBlank(userQueryFilterRequest.fieldName) && (userQueryFilterRequest.selectedOptions == null || userQueryFilterRequest.selectedOptions.isEmpty())) {
            throw new EUR_TR_UserSearchControllerException('Lütfen seçim yapınız');
        }

        //String query = '';
        Set<Id> userIds = new Set<Id>();
        if (userQueryFilterRequest.fieldName == 'EUR_TR_CityName__c') {

            List<String> selectedCities = userQueryFilterRequest.selectedOptions;
            String cityAggregateQuery = 'SELECT EUR_TR_SalesChiefName__c ' +
                    'FROM EUR_TR_Account__c ' +
                    'WHERE EUR_TR_CityName__c != NULL ' +
                    'AND EUR_TR_SalesChiefName__c != NULL ' +
                    'AND EUR_TR_CityName__c IN :selectedCities ' +
                    'GROUP BY EUR_TR_CityName__c,EUR_TR_SalesChiefName__c ' ;

            Set<String> employeeNames = new Set<String>();
            for (SObject record : Database.query(cityAggregateQuery)) {
                employeeNames.add((String) record.get('EUR_TR_SalesChiefName__c'));
            }
            System.debug(employeeNames.size());


            Set<Id> areaManagerIds = new Set<Id>();
            Set<Id> salesChiefUserIds = new Set<Id>();
            if (employeeNames != null && !employeeNames.isEmpty()) {

                String salesChiefEmployeeQuery = 'SELECT EUR_TR_RelatedUser__c ' +
                        'FROM EUR_TR_Employee__c ' +
                        'WHERE NAME IN :employeeNames AND EUR_TR_RelatedUser__c != NULL AND EUR_TR_RelatedUser__r.Profile.Name like \'%EUR TR%\'';

                for (EUR_TR_Employee__c employee : Database.query(salesChiefEmployeeQuery)) {
                    salesChiefUserIds.add(employee.EUR_TR_RelatedUser__c);
                }

                if (!salesChiefUserIds.isEmpty()) {
                    String areaManagerEmployeeQuery = 'SELECT EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c ' +
                            'FROM EUR_TR_Employee__c ' +
                            'WHERE EUR_TR_RelatedUser__c != NULL AND EUR_TR_RelatedUser__c IN :salesChiefUserIds ' +
                            'AND EUR_TR_ReportsTo_AreaManager__c != NULL AND EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c != NULL';
                    for (EUR_TR_Employee__c employee : Database.query(areaManagerEmployeeQuery)) {
                        areaManagerIds.add(employee.EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c);
                    }
                }

            }


            if (!areaManagerIds.isEmpty()) {
                userIds.addAll(areaManagerIds);
            }
            if (!salesChiefUserIds.isEmpty()) {
                userIds.addAll(salesChiefUserIds);
            }

        } else if (userQueryFilterRequest.fieldName == 'EUR_TR_Channel__c') {


            List<String> selectedChannels = userQueryFilterRequest.selectedOptions;
            String channelAggregateQuery = 'SELECT EUR_TR_SalesChiefName__c ' +
                    'FROM EUR_TR_Account__c ' +
                    'WHERE EUR_TR_Channel__c != NULL ' +
                    'AND EUR_TR_SalesChiefName__c != NULL ' +
                    'AND EUR_TR_Channel__c IN :selectedChannels ' +
                    'GROUP BY EUR_TR_Channel__c,EUR_TR_SalesChiefName__c ';
            System.debug(channelAggregateQuery);

            Set<String> employeeNames = new Set<String>();
            for (SObject record : Database.query(channelAggregateQuery)) {
                employeeNames.add((String) record.get('EUR_TR_SalesChiefName__c'));
            }
            System.debug(employeeNames.size());


            Set<Id> areaManagerIds = new Set<Id>();
            Set<Id> salesChiefUserIds = new Set<Id>();
            if (employeeNames != null && !employeeNames.isEmpty()) {

                String salesChiefEmployeeQuery = 'SELECT EUR_TR_RelatedUser__c ' +
                        'FROM EUR_TR_Employee__c ' +
                        'WHERE NAME IN :employeeNames AND EUR_TR_RelatedUser__c != NULL AND EUR_TR_RelatedUser__r.Profile.Name like \'%EUR TR%\'';

                for (EUR_TR_Employee__c employee : Database.query(salesChiefEmployeeQuery)) {
                    salesChiefUserIds.add(employee.EUR_TR_RelatedUser__c);
                }

                if (!salesChiefUserIds.isEmpty()) {
                    String areaManagerEmployeeQuery = 'SELECT EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c ' +
                            'FROM EUR_TR_Employee__c ' +
                            'WHERE EUR_TR_RelatedUser__c != NULL AND EUR_TR_RelatedUser__c IN :salesChiefUserIds ' +
                            'AND EUR_TR_ReportsTo_AreaManager__c != NULL AND EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c != NULL';

                    for (EUR_TR_Employee__c employee : Database.query(areaManagerEmployeeQuery)) {
                        areaManagerIds.add(employee.EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c);
                    }
                }

            }


            if (!areaManagerIds.isEmpty()) {
                userIds.addAll(areaManagerIds);
            }
            if (!salesChiefUserIds.isEmpty()) {
                userIds.addAll(salesChiefUserIds);
            }

        }

        return userIds;

    }


    public static Set<Id> getUsersByOwner(UserQueryFilterRequest userQueryFilterRequest) {

        System.debug(JSON.serializePretty(userQueryFilterRequest));

        Set<Id> userIds = new Set<Id>();
        try {
            if (userQueryFilterRequest.fieldName == 'EUR_TR_CityName__c') {
                List<String> selectedCities = userQueryFilterRequest.selectedOptions;
                String cityAggregateQuery = 'SELECT OwnerId ' +
                        'FROM EUR_TR_Account__c ' +
                        'WHERE EUR_TR_CityName__c != NULL ' +
                        'AND EUR_TR_CityName__c IN :selectedCities ' +
                        'GROUP BY OwnerId,EUR_TR_CityName__c ' +
                        'ORDER BY OwnerId ';

                Set<Id> salesChiefIds = new Set<Id>();
                for (SObject record : Database.query(cityAggregateQuery)) {
                    salesChiefIds.add((String) record.get('OwnerId'));
                }
                System.debug(salesChiefIds.size());

                Set<Id> areaManagerIds = new Set<Id>();
                if (salesChiefIds != null && !salesChiefIds.isEmpty()) {
                    String employeeQuery = 'SELECT EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c ' +
                            'FROM EUR_TR_Employee__c ' +
                            'WHERE EUR_TR_RelatedUser__c != NULL AND EUR_TR_RelatedUser__c IN :salesChiefIds ' +
                            'AND EUR_TR_ReportsTo_AreaManager__c != NULL AND EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c != NULL';

                    for (EUR_TR_Employee__c employee : Database.query(employeeQuery)) {
                        areaManagerIds.add(employee.EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c);
                    }
                }


                if (!areaManagerIds.isEmpty()) {
                    userIds.addAll(areaManagerIds);
                }
                if (!salesChiefIds.isEmpty()) {
                    userIds.addAll(salesChiefIds);
                }

            } else if (userQueryFilterRequest.fieldName == 'EUR_TR_Channel__c') {

                List<String> selectedChannels = userQueryFilterRequest.selectedOptions;
                String channelAggregateQueryToSalesChiefs = 'SELECT OwnerId ' +
                        'FROM EUR_TR_Account__c ' +
                        'WHERE EUR_TR_Channel__c != NULL ' +
                        'AND EUR_TR_Channel__c IN :selectedChannels ' +
                        'GROUP BY OwnerId,EUR_TR_Channel__c ' +
                        'ORDER BY OwnerId ';
                System.debug(channelAggregateQueryToSalesChiefs);

                Set<Id> salesChiefIds = new Set<Id>();
                for (SObject record : Database.query(channelAggregateQueryToSalesChiefs)) {
                    salesChiefIds.add((String) record.get('OwnerId'));
                }
                System.debug(salesChiefIds.size());


                Set<Id> areaManagerIds = new Set<Id>();
                if (salesChiefIds != null && !salesChiefIds.isEmpty()) {
                    String employeeQuery = 'SELECT EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c ' +
                            'FROM EUR_TR_Employee__c ' +
                            'WHERE EUR_TR_RelatedUser__c != NULL AND EUR_TR_RelatedUser__c IN :salesChiefIds ' +
                            'AND EUR_TR_ReportsTo_AreaManager__c != NULL AND EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c != NULL';

                    for (EUR_TR_Employee__c employee : Database.query(employeeQuery)) {
                        areaManagerIds.add(employee.EUR_TR_ReportsTo_AreaManager__r.EUR_TR_RelatedUser__c);
                    }
                }


                if (!areaManagerIds.isEmpty()) {
                    userIds.addAll(areaManagerIds);
                }
                if (!salesChiefIds.isEmpty()) {
                    userIds.addAll(salesChiefIds);
                }

            } else {
                throw new EUR_TR_UserSearchControllerException('Bilinmeyen Alan');
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        //return query;
        return userIds;
    }

    private static List<PicklistOption> getManagers() {

        String managerQuery = 'SELECT ManagerId FROM User ' +
                'WHERE ManagerId != null ' +
                'AND Profile.Name LIKE \'%EUR TR%\' ' +
                'GROUP BY ManagerId ';
        List<SObject> results = Database.query(managerQuery);
        Set<Id> managerIds = new Set<Id>();
        for (SObject record : results) {
            managerIds.add((Id) record.get('ManagerId'));
        }
        List<PicklistOption> managerOptions = new List<PicklistOption>();
        PicklistOption managerOption = new PicklistOption();
        List<User> managers = [SELECT Id,Name FROM User WHERE Id IN :managerIds];
        System.debug(managers.size());
        for (User manager : managers) {
            managerOption = new PicklistOption();
            managerOption.label = manager.Name;
            managerOption.value = manager.Id;
            managerOptions.add(managerOption);
        }
        return managerOptions;

    }

    private static List<PicklistOption> getUserRoles() {

        List<PicklistOption> options = new List<PicklistOption>();
        PicklistOption option = new PicklistOption();

        List<UserRole> userRoles = [
                SELECT Id,Name,DeveloperName
                FROM UserRole
                WHERE Name LIKE '%EUR_TR%' OR Name LIKE '%EUR TR%'
        ];
        System.debug(userRoles.size());

        for (UserRole userRole : userRoles) {
            option = new PicklistOption();
            option.label = userRole.Name;
            option.value = userRole.DeveloperName;
            options.add(option);
        }

        return options;

    }

    public static List<PicklistOption> getPicklistOptions(String objectName, String fieldName) {
        List<PicklistOption> options = new List<PicklistOption>();
        PicklistOption option = null;
        List<PicklistEntry> picklistEntries = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
        for (PicklistEntry entry : picklistEntries) {
            if (entry.isActive()) {
                option = new PicklistOption();
                option.label = entry.label;
                option.value = entry.value;
                options.add(option);
            }
        }

        return options;
    }

    private static List<PicklistOption> getUserProfiles() {

        List<PicklistOption> options = new List<PicklistOption>();
        PicklistOption option = new PicklistOption();

        List<Profile> profiles = [
                SELECT Id,Name
                FROM Profile
                WHERE Name LIKE '%EUR TR%'
        ];

        System.debug(profiles.size());

        for (Profile profile : profiles) {
            option = new PicklistOption();
            option.label = profile.Name;
            option.value = profile.Name;
            options.add(option);
        }
        return options;

    }

    public class Filter {

        public Filter() {
            this.isUserField = true;
        }

        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String fieldType { get; set; }
        @AuraEnabled
        public Boolean isUserField { get; set; }
        @AuraEnabled
        public List<PicklistOption> picklistOptions { get; set; }
    }

    public class PicklistOption {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }

    public class UserQueryFilterRequest {
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public List<String> selectedOptions { get; set; }
        @AuraEnabled
        public String queryReference { get; set; }
    }


}