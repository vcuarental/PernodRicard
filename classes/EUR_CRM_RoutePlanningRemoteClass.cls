public with sharing class EUR_CRM_RoutePlanningRemoteClass {
    private EUR_CRM_Route_Template__c routeTemplate;
    public List<AccountItem> accountItems { get; set; }
    public List<AccountItem> pagedAccounts { get; set; }
    public Boolean disablePlanningPeriod { get; set; }
    public Integer accountsPageNum { get; set; } {
        accountsPageNum = 1;
    }
    public Boolean accountsPageHasMore { get; set; }
    public Integer accountFirstIndex { get; set; }
    public Integer totalPages { get; set; }
    public Integer ROWS_PER_PAGE { get; set; } {
        ROWS_PER_PAGE = 20;
    }
    public Integer accountListSize { get {return accountItems.size();} set; }
    public String accountSearchFilter { get; set; }

    public EUR_CRM_RoutePlanningRemoteClass(ApexPages.StandardController standardController) {
        if (!Test.isRunningTest()) {
            standardController.addFields(new List<String>{
                    'EUR_CRM_Country_Code__c'
            });
        }
        routeTemplate = (EUR_CRM_Route_Template__c) standardController.getRecord();
        disablePlanningPeriod = false;
        if (routetemplate.EUR_CRM_Country_Code__c == 'DK') {
            disablePlanningPeriod = true;
        }

        // prepare the data
        retrieveAccounts();
        preparePagedAccounts();
    }

    @RemoteAction
    public static List<RoutePlanItem> getRoutPlanItems(String startDay, String endDay, String routeTemplateId) {
        Integer startD = Integer.valueOf(startDay);
        Integer endD = Integer.valueOf(endDay);
        List<EUR_CRM_Route_Template_Day__c> daysList = new List<EUR_CRM_Route_Template_Day__c>();
        system.debug('last day: ' + endDay);
        if (String.isNotEmpty(routeTemplateId)) {
            daysList = [
                    select id,EUR_CRM_Day__c,
                            EUR_CRM_Week_Day__c,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Route_Template__c,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__c,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__r.name,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__r.EUR_CRM_Active_Flag__c, //added to filter active accounts
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Frequency__c,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Span__c
                    from EUR_CRM_Route_Template_Day__c
                    where
                            //EUR_CRM_Day__c >=: startD AND
                    EUR_CRM_Day__c <= :endD AND
                    EUR_CRM_Route_Template_Item__c in (select id from EUR_CRM_Route_Template_Item__c where EUR_CRM_Route_Template__c = :routeTemplateId)
            ];
        }

        List<RoutePlanItem> items = new List<RoutePlanItem>();

        for (EUR_CRM_Route_Template_Day__c templateDay : daysList) {
            RoutePlanItem item = new RoutePlanItem();
            item.day = String.valueOf(templateDay.EUR_CRM_Day__c);
            item.title = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__r.name;
            item.routeTemplateId = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Route_Template__c;
            item.routeTemplateItemId = templateDay.EUR_CRM_Route_Template_Item__c;
            item.routeTemplateDayId = templateDay.id;
            item.accountId = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__c;
            item.span = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Span__c != null ? String.ValueOF(templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Span__c) : '0';
            item.frequency = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Frequency__c != null ? String.ValueOF(templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Frequency__c) : '0';
            item.id = item.accountId + item.day;
            item.accountActiveFlag = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__r.EUR_CRM_Active_Flag__c;

            Integer rStartDay = Integer.valueOf(startDay);
            Integer rEndDay = Integer.valueOf(endDay);
            Integer itemDay = Integer.valueOf(item.day);

            if (itemDay >= rStartDay && itemDay <= rEndDay)
                items.add(item);

            Integer lastDay = Integer.valueOf(endDay);

            Integer span = Integer.valueOf(item.span);

            for (Integer sDay = Integer.valueOf(item.day) + Integer.valueOf(item.span); sDay <= lastDay; sday += span) {
                if (sDay >= rStartDay && sDay <= rEndDay) {
                    RoutePlanItem cItem = item.clone();
                    cItem.duplicate = 'true';
                    cItem.day = String.valueOf(sDay);
                    cItem.id = item.id;
                    items.add(cItem);
                    system.debug(cItem);
                }
            }
        }
        return items;
    }


    @RemoteAction
    public static String deleteRouteTemplateItems(List<String> accountIds) {
        String message = 'Success deleting route template items for account: ' + accountIds;
        try {
            if (accountIds != null && accountIds.size() > 0) {
                List<EUR_CRM_Route_Template_Item__c> toDelete = [
                        select id
                        from
                                EUR_CRM_Route_Template_Item__c
                        where EUR_CRM_Account__c in:accountIds
                ];

                delete toDelete;
            } else {
                message = 'nothing to delete: ' + accountIds;
            }
        } catch (DMLException e) {
            message = 'Error on deletion. Error message: ' + e;
        }
        return message;
    }
    @RemoteAction
    public static List<RoutePlanItem> getRoutPlanItemsByAccount(String accountId, String routeTemplateId) {

        List<EUR_CRM_Route_Template_Day__c> daysList = new List<EUR_CRM_Route_Template_Day__c>();

        if (String.isNotEmpty(routeTemplateId)) {
            daysList = [
                    select id,EUR_CRM_Day__c,
                            EUR_CRM_Week_Day__c,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Route_Template__c,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__c,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__r.name,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Frequency__c,
                            EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Span__c
                    from EUR_CRM_Route_Template_Day__c
                    where
                    EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__c = :accountId
                    AND
                    EUR_CRM_Route_Template_Item__c in (select id from EUR_CRM_Route_Template_Item__c where EUR_CRM_Route_Template__c = :routeTemplateId)
            ];
        }

        List<RoutePlanItem> items = new List<RoutePlanItem>();

        for (EUR_CRM_Route_Template_Day__c templateDay : daysList) {

            RoutePlanItem item = new RoutePlanItem();
            item.day = String.valueOf(templateDay.EUR_CRM_Day__c);
            item.title = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__r.name;
            item.routeTemplateId = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Route_Template__c;
            item.routeTemplateItemId = templateDay.EUR_CRM_Route_Template_Item__c;
            item.routeTemplateDayId = templateDay.id;
            item.accountId = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Account__c;
            item.span = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Span__c != null ? String.ValueOF(templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Span__c) : '0';
            item.frequency = templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Frequency__c != null ? String.ValueOF(templateDay.EUR_CRM_Route_Template_Item__r.EUR_CRM_Visit_Frequency__c) : '0';
            item.id = item.accountId + item.day;

            items.add(item);


        }
        return items;
    }
    /*
    */
    @RemoteAction
    public static String saveRoutePlanItems(List<RoutePlanItem> items, String planningPeriod, String origPlanningPeriod) {
        Boolean isSuccess = false;
        String message = '';
        Savepoint sp = Database.setSavepoint();
        try {

            List<EUR_CRM_Route_Template_Item__c> routeItemsTobeDeleted = new List<EUR_CRM_Route_Template_Item__c>();

            List<EUR_CRM_Route_Template_Item__c> insertRouteTemplateItems = new List<EUR_CRM_Route_Template_Item__c>();
            List<EUR_CRM_Route_Template_Day__c> upsertRouteTemplateDays = new List<EUR_CRM_Route_Template_Day__c>();
            Map<Id, Id> accountRouteTemplateItemMap = new Map<Id, Id>();
            Set<String> accounts = new Set<String>();
            //get all the existing route template items.
            String routeTemplateId = items != null && items.size() > 0 ? items.get(0).routeTemplateId : '';
            for (RoutePlanItem item : items) {
                accounts.add(item.accountId);
            }
            //find items where doesnt have a routeTemplateItem Id
            if (accounts.size() > 0 && !String.isEmpty(routeTemplateId))
                for (EUR_CRM_Route_Template_Item__c templateItem : [
                        select id,EUR_CRM_Account__c, EUR_CRM_Account__r.EUR_CRM_Active_Flag__c
                        from EUR_CRM_Route_Template_Item__c
                        where
                        EUR_CRM_Account__c in:accounts
                        AND EUR_CRM_Route_Template__c = :routeTemplateId
                ]) {
                    accountRouteTemplateItemMap.put(templateItem.EUR_CRM_Account__c, templateItem.id);
                }

            //find items which has an Inactive acount
            for (EUR_CRM_Route_Template_Item__c templateItem : [
                    select id,EUR_CRM_Account__c, EUR_CRM_Account__r.EUR_CRM_Active_Flag__c, EUR_CRM_Account__r.Name
                    from EUR_CRM_Route_Template_Item__c
                    where
                    EUR_CRM_Account__r.EUR_CRM_Active_Flag__c = false
                    AND EUR_CRM_Route_Template__c = :routeTemplateId
            ]) {

                routeItemsTobeDeleted.add(templateItem);
                System.debug('$$FLAG: ' + templateItem.EUR_CRM_Account__r.EUR_CRM_Active_Flag__c + ' : ' + templateItem.EUR_CRM_Account__r.Name);
            }

            Set<String> temp = new Set<String>();

            for (RoutePlanItem item : items) {
                if (String.isEmpty(item.routeTemplateItemId) && !temp.contains(item.accountId)
                        && !accountRouteTemplateItemMap.keySet().contains(item.accountId)) {
                    EUR_CRM_Route_Template_Item__c routeTemplateItem = new EUR_CRM_Route_Template_Item__c(
                            EUR_CRM_Account__c = String.isEmpty(item.accountId) ? null : item.accountId,
                            EUR_CRM_Route_Template__c = String.isEmpty(item.routeTemplateId) ? null : item.routeTemplateId);
                    temp.add(item.accountId);
                    insertRouteTemplateItems.add(routeTemplateItem);
                }
            }

            insert insertRouteTemplateItems;
            system.debug('## insertRouteTemplateItems ' + insertRouteTemplateItems);
            for (EUR_CRM_Route_Template_Item__c templateItem : insertRouteTemplateItems) {
                accountRouteTemplateItemMap.put(templateItem.EUR_CRM_Account__c, templateItem.id);
            }
            system.debug('## accountRouteTemplateItemMap ' + accountRouteTemplateItemMap);
            for (RoutePlanItem item : items) {

                system.debug('## item ' + item);
                EUR_CRM_Route_Template_Day__c templateDay = new EUR_CRM_Route_Template_Day__c(
                        EUR_CRM_Day__c = String.isEmpty(item.day) ? 0 : Decimal.valueOf(item.day),
                        EUR_CRM_Route_Template_Item__c = String.isEmpty(item.routeTemplateItemId) ? null : item.routeTemplateItemId,
                        id = String.isEmpty(item.routeTemplateDayId) ? null : item.routeTemplateDayId
                );
                if (String.isEmpty(item.routeTemplateItemId)) {
                    system.debug('## flag ');
                    templateDay.EUR_CRM_Route_Template_Item__c = accountRouteTemplateItemMap.get(item.accountId);
                }
                system.debug('## templateDay ' + templateDay);
                upsertRouteTemplateDays.add(templateDay);
            }

            upsert upsertRouteTemplateDays;
            update (new EUR_CRM_Route_Template__c(id = routeTemplateId, EUR_CRM_Planning_Period__c = Integer.valueOf(planningPeriod)));

            //delete something.
            if (origPlanningPeriod != planningPeriod) {
                Set<Id> roDeleteRouteTemplatItems = new Set<Id>();
                Integer rDay = Integer.valueOf(planningPeriod) * 7;
                for (EUR_CRM_Route_Template_Day__c rTDay : [
                        select EUR_CRM_Route_Template_Item__c
                        from EUR_CRM_Route_Template_Day__c
                        where EUR_CRM_Day__c > :rDay
                        AND EUR_CRM_Route_Template_Item__r.EUR_CRM_Route_Template__c = :routeTemplateId
                ]) {
                    roDeleteRouteTemplatItems.add(rTDay.EUR_CRM_Route_Template_Item__c);
                }
                List<EUR_CRM_Route_Template_Item__c> rItems = new List<EUR_CRM_Route_Template_Item__c>();
                for (Id i : roDeleteRouteTemplatItems) {
                    rItems.add(new EUR_CRM_Route_Template_Item__c(id = i));
                }
                delete rItems;
            }

            if (routeItemsTobeDeleted.size() > 0) {
                delete routeItemsTobeDeleted;
            }

            isSuccess = true;
        } catch (Exception e) {
            isSuccess = false;
            Database.rollback(sp);
            message += e;
        }
        return message;
    }

    public void searchAccounts() {
        AccountItems = null;
        accountsPageNum = 1;
        retrieveAccounts();
        preparePagedAccounts();
    }

    public void retrieveAccounts() {
        if (AccountItems != null) return;

        String searchString = '%';
        if (!String.isEmpty(accountSearchFilter)) {
            searchString += (accountSearchFilter+'%');
        }
        System.debug('searchString:'+searchString);

        accountItems = new List<AccountItem>();
        cleanUpRouteItems();
        //system.debug('retrieving accounts with routetemplate: ' + routeTemplate );

        Set<Id> accountsWithEvents = new SeT<Id>();

        for (EUR_CRM_Route_Template_Item__c item : [
                select EUR_CRM_Account__c
                from EUR_CRM_Route_Template_Item__c
                where EUR_CRM_Route_Template__c = :routeTemplate.id
                AND EUR_CRM_Event_Count__c > 0
        ]) {
            accountsWithEvents.add(item.EUR_CRM_Account__c);
        }
        EUR_CRM_Route_Template__c routeTemplateInfo = [SELECT id, OwnerId, EUR_CRM_Self_Assigned__c, EUR_CRM_Assigned_To__c FROM EUR_CRM_Route_Template__c WHERE id = :routeTemplate.id LIMIT 1];
        system.debug('routeTemplateInfo:'+routeTemplateInfo);

        List<EUR_CRM_Account__c> qualifiedAccounts = new List<EUR_CRM_Account__c>();
        // Checked if EUR_CRM_Self_Assigned__c field is ture, get all accounts releated to owner of the route template
        if (routeTemplateInfo.EUR_CRM_Self_Assigned__c) {
            Id roleTemplateOwnerId = routeTemplateInfo.OwnerId;
            Set<Id> subordinateId = EUR_CRM_RoleUtils.getRoleSubordinateUsers(roleTemplateOwnerId);

            //subordinateId.add(roleTemplateOwnerId);
            system.debug('subordinateId:'+subordinateId);
            //system.debug(routeTemplateInfo.OwnerId);
            //system.debug('Is subordinateId contains RouteTemplate Owner Id? - '+subordinateId.contains(routeTemplateInfo.OwnerId));

            qualifiedAccounts = [
                    SELECT Id,Name, OwnerId, Owner.firstName, Owner.lastName, RecordtypeId, RecordType.DeveloperName,
                            EUR_CRM_Visit_Frequency__c,EUR_CRM_Visit_Frequency__r.Name,EUR_CRM_Visit_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c,
                            EUR_CRM_Visit_Frequency__r.EUR_CRM_Frequency_Span_Days__c,EUR_CRM_Visit_Frequency_Filtered__c,EUR_CRM_Visit_Frequency_Filtered__r.Name,
                            EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_No_of_Visits_Within_Interval__c,EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_Frequency_Span_Days__c,
                            EUR_CRM_Postal_Code__c,EUR_JB_City_Name__c,EUR_CRM_Street__c,EUR_CRM_Active_Flag__c,CreatedDate,EUR_CRM_Preferred_call_day__c,UserRecordAccess.HasEditAccess
                    FROM EUR_CRM_Account__c
                    WHERE Name != null
                    AND Name LIKE :searchString
                    AND (OwnerId = :routeTemplateInfo.OwnerId OR OwnerId = :subordinateId)
                    AND EUR_CRM_Active_Flag__c = true
                    AND EUR_CRM_Country_Code__c = :routeTemplate.EUR_CRM_Country_Code__c
                    ORDER BY EUR_CRM_Postal_Code__c NULLS LAST
            ];
        } else {
            // If EUR_CRM_Self_Assigned__c field is false, get all accounts releated to the person assigned
            qualifiedAccounts = [
                    SELECT Id,Name, OwnerId, Owner.firstName, Owner.lastName, RecordtypeId, RecordType.DeveloperName,
                            EUR_CRM_Visit_Frequency__c,EUR_CRM_Visit_Frequency__r.Name,EUR_CRM_Visit_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c,
                            EUR_CRM_Visit_Frequency__r.EUR_CRM_Frequency_Span_Days__c,EUR_CRM_Visit_Frequency_Filtered__c,EUR_CRM_Visit_Frequency_Filtered__r.Name,
                            EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_No_of_Visits_Within_Interval__c,EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_Frequency_Span_Days__c,
                            EUR_CRM_Postal_Code__c,EUR_JB_City_Name__c,EUR_CRM_Street__c,EUR_CRM_Active_Flag__c,CreatedDate,EUR_CRM_Preferred_call_day__c,UserRecordAccess.HasEditAccess
                    FROM EUR_CRM_Account__c
                    WHERE Name != null
                    AND Name LIKE :searchString
                    AND OwnerId = :routeTemplateInfo.EUR_CRM_Assigned_To__c
                    AND EUR_CRM_Active_Flag__c = true
                    AND EUR_CRM_Country_Code__c = :routeTemplate.EUR_CRM_Country_Code__c
                    ORDER BY EUR_CRM_Postal_Code__c NULLS LAST
            ];
        }
        system.debug('qualifiedAccounts:'+qualifiedAccounts);
        for (EUR_CRM_Account__c account : qualifiedAccounts) {
            //start of loop.
            String tempVisitFrequencyName = (account.EUR_CRM_Visit_Frequency_Filtered__c != null) ? account.EUR_CRM_Visit_Frequency_Filtered__r.Name : account.EUR_CRM_Visit_Frequency__r.Name;
            String tempVisitFrequencySpan = String.valueOf((account.EUR_CRM_Visit_Frequency_Filtered__c != null) ? account.EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_Frequency_Span_Days__c : account.EUR_CRM_Visit_Frequency__r.EUR_CRM_Frequency_Span_Days__c);
            String tempVisitFrequencyDuration = String.valueOf((account.EUR_CRM_Visit_Frequency_Filtered__c != null) ? account.EUR_CRM_Visit_Frequency_Filtered__r.EUR_CRM_No_of_Visits_Within_Interval__c : account.EUR_CRM_Visit_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c);

            AccountItem accountItem = new AccountItem();
            if (routeTemplate.EUR_CRM_Country_Code__c == 'FI') {
                // If FI affiliate, check if the account belongs to the current user
                if (account.ownerId == UserInfo.getUserId()) {
                    // If belongs to the user, add account owner name to account item
                    accountItem.accountOwnerName = account.Owner.firstName + ' ' + account.Owner.lastName;
                } else {
                    // otherwise do nothing to this account
                    continue;
                }
            }
            // Accounts to skip from adding to account list
            if (account.RecordType.DeveloperName == 'EUR_DK_Wholesaler') {
                continue;
            }

            if (routeTemplate.EUR_CRM_Country_Code__c == 'PT') {
                accountItem.accountOwnerName = account.Owner.firstName + ' ' + account.Owner.lastName;
            }

            accountItems.add(accountItem);
            accountItem.accountId = account.id;
            accountItem.accountName = account.name;
            accountItem.accountAddress = '';
            accountItem.accountPostCode = account.EUR_CRM_Postal_Code__c;
            accountItem.accountCity = account.EUR_JB_City_Name__c;
            accountItem.accountStreet = account.EUR_CRM_Street__c;
            accountItem.visitFrequencyName = tempVisitFrequencyName;
            accountItem.visitFrequency = tempVisitFrequencyDuration;
            accountItem.visitSpan = tempVisitFrequencySpan;
            accountItem.isEvent = String.valueOf(accountsWithEvents.contains(account.id));
            accountItem.prefferedCallDay = account.EUR_CRM_Preferred_call_day__c;
        }
    }

    /*****************************************************************
    *   Manages the pagination of the accounts list 
    *****************************************************************/
    public void preparePagedAccounts() {
        pagedAccounts = new List<AccountItem>();
        // The list index of the first record in the currently displayed page 
        accountFirstIndex = (accountsPageNum - 1) * ROWS_PER_PAGE ;
        // Whether there are more pages with data to be displayed
        accountsPageHasMore = (1 + accountsPageNum) < getTotalPages();
        // populates the paged visit actions list to be sent to the VF component, with a maximum of ROWS_PER_PAGE number of records 
        for (Integer i = accountFirstIndex; i < accountFirstIndex + ROWS_PER_PAGE && accountItems.size() > i; i++) {
            pagedAccounts.add(accountItems.get(i));
        }
    }

    /*****************************************************************
    *   Sets the current page in the table to the first one
    *****************************************************************/
    public void firstPage() {
        accountsPageNum = 1;
        preparePagedAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the table to the last one
    *****************************************************************/
    public void lastPage() {
        accountsPageNum = getTotalPages();
        preparePagedAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the table to the next one in order
    *****************************************************************/
    public void nextPage() {
        accountsPageNum = Math.min(accountsPageNum + 1, getTotalPages());
        preparePagedAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the table to the previous one in order
    *****************************************************************/
    public void previousPage() {
        accountsPageNum = Math.max(accountsPageNum - 1, 1);
        preparePagedAccounts();
    }
    /*****************************************************************
    *   calculates the total number of pages needed to display the full amount of data in the accountItems list
    *   returns: and Integer number of maximum number of pages needed
    *****************************************************************/
    public Integer getTotalPages() {
        if (System.Math.mod(accountItems.size(), ROWS_PER_PAGE) == 0)
            return accountItems.size() / ROWS_PER_PAGE; else
                return (accountItems.size() / ROWS_PER_PAGE) + 1;
    }


    static Boolean cleanUpRouteItems() {
        Boolean isSuccess = false;

        return isSuccess;
    }
    public class AccountItem {
        public String accountId { get; set; }
        public String accountName { get; set; }
        public String accountOwnerName { get; set; }
        public String accountAddress { get; set; }
        public String accountPostCode { get; set; }
        public String accountCity { get; set; }
        public String accountStreet { get; set; }
        public String visitFrequencyName { get; set; }
        public String visitFrequency { get; set; }
        public String visitSpan { get; set; }
        public String lastScheduleVisit { get; set; }
        public String meetingDuration { get; set; }
        public String routeTemplateItemId { get; set; }
        public String routeTemplateId { get; set; }
        public String isEvent { get; set; }
        public String prefferedCallDay { get; set; }
    }

    public class RoutePlanItem {
        public String routeTemplateId { get; set; }
        public String routeTemplateItemId { get; set; }
        public String routeTemplateDayId { get; set; }
        public String accountId { get; set; }
        public String day { get; set; }
        public String title { get; set; }
        public String span { get; set; }
        public String frequency { get; set; }
        public String duplicate { get; set; }
        public String id { get; set; }
        public Boolean accountActiveFlag { get; set; }
    }
}