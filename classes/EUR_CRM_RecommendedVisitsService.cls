/**
 * Created by Ilation Tokarskyi on 19.11.2020.
 */

public with sharing class EUR_CRM_RecommendedVisitsService {
    private static final String INVALID_ACCOUNT_IDS = 'The following resource(s) were not found. Account Id(s): \n';
    private static final String INVALID_PRODUCTS_IDS = 'The following resource(s) were not found. Product Id(s): \n';
    private static final String DML_ERROR = 'Unexpected internal server error.';
    private static final String INVALID_BODY_FORMAT = 'The message has an invalid format.\n';
    private static final String SUCCESS_BODY_FORMAT = 'The Following Resource(s) Successfully Created:\n';
    private static String invalid_Body_String = '';
    private EUR_CRM_RecommendedVisitsParser parser;
    private List<String> notValidWeeks = new List<String>();
    private Set<String> accIds = new Set<String>();
    private Set<String> prodIds = new Set<String>();
    private Set<Date> weekStartDates = new Set<Date>();
    private Set<Id> accIdsForPromDelete = new Set<Id>();
    private Set<Id> weekIdsForPromDelete = new Set<Id>();
    private Set<Id> recAccDMLIds = new Set<Id>();
    private Set<Id> weekDMLIds = new Set<Id>();
    private Set<Id> promDMLIds = new Set<Id>();
    private Set<Id> recProdDMLIds = new Set<Id>();
    private List<EUR_CRM_RecommendedVisitsParser.Week> validWeeks = new List<EUR_CRM_RecommendedVisitsParser.Week>();
    private List<EUR_CRM_Week_KDP__c> weeksToUpsert = new List<EUR_CRM_Week_KDP__c>();
    private List<EUR_CRM_Recommended_Account__c> recAccountsToUpsert = new List<EUR_CRM_Recommended_Account__c>();
    private List<EUR_CRM_Promotion_KDP__c> promotionsToInsert = new List<EUR_CRM_Promotion_KDP__c>();
    private List<EUR_CRM_Promotion_Products_KDP__c> promProductsToInsert = new
            List<EUR_CRM_Promotion_Products_KDP__c>();
    private Map<EUR_CRM_Promotion_KDP__c, List<Id>> productsByPromtionMap = new Map<EUR_CRM_Promotion_KDP__c, List<Id>>();
    private Map<Date, EUR_CRM_Week_KDP__c> existWeekByStartDate = new Map<Date, EUR_CRM_Week_KDP__c>();

    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public Boolean isInvalidBody(String jsonString) {
        Boolean result = false;
        try {
            parser = EUR_CRM_RecommendedVisitsParser.parse(jsonString);
        } catch (Exception ex) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(INVALID_BODY_FORMAT);
            return true;
        }
        for (EUR_CRM_RecommendedVisitsParser.Week week : parser.Weeks) {
            if (isNotValidStartWeekDate(week.WeekStartDate)) {
                notValidWeeks.add(week.WeekStartDate);
            }
            configureAccIdsAndProdIdsSet(week.accounts);
        }
        if (!notValidWeeks.isEmpty()) {
            RestContext.response.statusCode = 400;
            invalid_Body_String += INVALID_BODY_FORMAT + 'Week Start Dates:\n' + notValidWeeks.toString() + '\n';
            System.debug('\n\n notValidWeeks size => ' + JSON.serializePretty(notValidWeeks.size()) + '\n');
            System.debug('\n\n notValidWeeks  => ' + JSON.serialize(notValidWeeks) + '\n');
            result = true;
        }
        if (isNotValidAccountIds()) {
            RestContext.response.statusCode = 404;
            invalid_Body_String += INVALID_ACCOUNT_IDS + accIds.toString() + '\n';
            System.debug('\n\n notValid accIds size => ' + JSON.serializePretty(accIds.size()) + '\n');
            System.debug('\n\n notValid accIds  => ' + JSON.serialize(accIds) + '\n');
            result = true;
        }if (isNotValidProdustIds()) {
            RestContext.response.statusCode = 404;
            invalid_Body_String += INVALID_PRODUCTS_IDS + prodIds.toString() + '\n';
            System.debug('\n\n notValid prodIds size => ' + JSON.serializePretty(prodIds.size()) + '\n');
            System.debug('\n\n notValid prodIds  => ' + JSON.serialize(prodIds) + '\n');
            result = true;
        }
        if (result) {
            RestContext.response.responseBody = Blob.valueOf(invalid_Body_String);
        } else {
            validWeeks = parser.Weeks;
        }
        return result;
    }

    public void insertRecommendedObjects() {
        checkExistWeeksByStartDate();
        configureListsToInsert();
    }
    /* ========================================================= */
    /*     High-level Helpers
    /* ========================================================= */
    private void configureListsToInsert() {
        System.debug('\n\n validWeeks size => ' + JSON.serializePretty(validWeeks.size()) + '\n');
        System.debug('\n\n validWeeks => ' + JSON.serialize(validWeeks) + '\n');
        for (EUR_CRM_RecommendedVisitsParser.Week week : validWeeks) {
            Id existId;
            if (existWeekByStartDate.containsKey(parseDateFromString(week.WeekStartDate))) {
                existId = existWeekByStartDate.get(parseDateFromString(week.WeekStartDate)).Id;
            }
            weeksToUpsert.add(createWeekFromParserClass(week, existId));
        }
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('\n\n weeksToUpsert size => ' + JSON.serializePretty(weeksToUpsert.size()) + '\n');
            System.debug('\n\n weeksToUpsert => ' + JSON.serialize(weeksToUpsert) + '\n');
            upsert weeksToUpsert;
            this.configureIdSet(weeksToUpsert, weekDMLIds);

            for (Integer i = 0; i < weeksToUpsert.size(); i++) {
                for (EUR_CRM_RecommendedVisitsParser.Account account : validWeeks.get(i).accounts) {
                    Id existId;
                    if (existWeekByStartDate.containsKey(weeksToUpsert[i].EUR_CRM_Week_Start_Date__c)) {
                        for (EUR_CRM_Recommended_Account__c recAcc : existWeekByStartDate.get(weeksToUpsert[i]
                                .EUR_CRM_Week_Start_Date__c).Recommended_Accounts__r) {
                            if (account.Id == recAcc.EUR_CRM_Account__c) {
                                existId = recAcc.Id;
                                accIdsForPromDelete.add(account.Id);
                                weekIdsForPromDelete.add(weeksToUpsert[i].Id);
                            }
                        }
                    }
                    recAccountsToUpsert.add(createRecAccFromParserClass(account, weeksToUpsert.get(i).Id, existId));
                    for (EUR_CRM_RecommendedVisitsParser.Upcoming_promotion promotion : account.Promotions) {
                        promotionsToInsert.add(createPromKDPFromParserClass(promotion, weeksToUpsert.get(i).Id, account
                                .Id));
                        productsByPromtionMap.put(promotionsToInsert.get(promotionsToInsert.size() - 1), promotion.Products);
                    }
                }
            }
            System.debug('\n\n recAccountsToInsert size => ' + JSON.serializePretty(recAccountsToUpsert.size()) + '\n');
            System.debug('\n\n recAccountsToInsert => ' + JSON.serialize(recAccountsToUpsert) + '\n');
            upsert recAccountsToUpsert;
            this.configureIdSet(recAccountsToUpsert, recAccDMLIds);
            System.debug('\n\n accIdsForPromDelete size => ' + JSON.serializePretty(accIdsForPromDelete.size()) + '\n');
            System.debug('\n\n accIdsForPromDelete  => ' + JSON.serialize(accIdsForPromDelete) + '\n');
            delete getPromotionsByAccIdAndWeekId(accIdsForPromDelete, weekIdsForPromDelete);
            System.debug('\n\n promotionsToInsert size => ' + JSON.serializePretty(promotionsToInsert.size()) + '\n');
            System.debug('\n\n promotionsToInsert => ' + JSON.serialize(promotionsToInsert) + '\n');
            insert promotionsToInsert;
            this.configureIdSet(promotionsToInsert, promDMLIds);

            for (EUR_CRM_Promotion_KDP__c promotion : productsByPromtionMap.keySet()) {
                List<Id> productIds = productsByPromtionMap.get(promotion);
                if (productIds == null) {
                    continue;
                }
                for (Id productId : productIds) {
                    promProductsToInsert.add(createPromPodFromParserClass(productId, promotion.Id));
                }
            }
            System.debug('\n\n promProductsToInsert size => ' + JSON.serializePretty(promProductsToInsert.size()) + '\n');
            System.debug('\n\n promProductsToInsert => ' + JSON.serialize(promProductsToInsert) + '\n');
            insert promProductsToInsert;
            this.configureIdSet(promProductsToInsert, recProdDMLIds);

            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(SUCCESS_BODY_FORMAT + 'Week(s):\n' +
                    weekDMLIds.toString() + '\n' + 'Recommednded Account(s):\n' + recAccDMLIds.toString() + '\n' +
            'Promotion(s):\n' + promDMLIds.toString() + '\n' + 'Recommended Product(s):\n' + recProdDMLIds.toString());
        } catch (DmlException ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, 'Rollbacked');
            Database.rollback(sp);
            RestContext.response.responseBody = Blob.valueOf(DML_ERROR);
            RestContext.response.statusCode = 500;
        }
    }

    private void checkExistWeeksByStartDate() {
        this.configureWeekDates();
        List<EUR_CRM_Week_KDP__c> weeks = getWeeksByStartDate(weekStartDates);
        for (EUR_CRM_Week_KDP__c week : weeks) {
            existWeekByStartDate.put(week.EUR_CRM_Week_Start_Date__c, week);
        }
    }

    private void configureWeekDates() {
        for (EUR_CRM_RecommendedVisitsParser.Week week : validWeeks) {
            weekStartDates.add(this.parseDateFromString(week.WeekStartDate));
        }
    }
    /* ========================================================= */
    /*     Low-level Helpers
    /* ========================================================= */
    private Boolean isNotValidAccountIds() {
        List<EUR_CRM_Account__c> accounts = getAccountsByIds(accIds);
        if (accounts.size() != accIds.size()) {
            for (EUR_CRM_Account__c account : accounts) {
                accIds.remove(account.Id);
            }
            return true;
        }
        return false;
    }
    private Boolean isNotValidProdustIds() {
        List<EUR_CRM_Brand__c> products = getProductsByIds(prodIds);
        if (products.size() != prodIds.size()) {
            for (EUR_CRM_Brand__c product : products) {
                prodIds.remove(product.Id);
            }
            return true;
        }
        return false;
    }
    public Boolean isNotValidStartWeekDate(String stringDate) {
        Datetime dayDate = this.parseDateFromString(stringDate);
        if (dayDate.format('E') == 'Mon') {
            return false;
        } else {
            return true;
        }
    }
    private void configureAccIdsAndProdIdsSet(List<EUR_CRM_RecommendedVisitsParser.Account> accounts) {
        for (EUR_CRM_RecommendedVisitsParser.Account account : accounts) {
            accIds.add(account.Id);
            for (EUR_CRM_RecommendedVisitsParser.Upcoming_promotion promotion : account.Promotions) {
                prodIds.addAll(promotion.Products);
            }
        }
    }
    private Date parseDateFromString(String stringDate) {
        List<String> dateList = stringDate.split('-');
        return Date.newInstance(Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]), Integer.valueOf
                (dateList[2]));
    }
    private void configureIdSet(List<SObject> records, Set<Id> toFill) {
        for (SObject record: records) {
            toFill.add(record.Id);
        }
    }
    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private EUR_CRM_Week_KDP__c createWeekFromParserClass(EUR_CRM_RecommendedVisitsParser.Week week, Id existId) {
        return new EUR_CRM_Week_KDP__c(
                EUR_CRM_Country_Code__c = week.Affiliate,
                EUR_CRM_Week_Start_Date__c = this.parseDateFromString(week.WeekStartDate),
                Id = existId
        );
    }

    private EUR_CRM_Recommended_Account__c createRecAccFromParserClass(EUR_CRM_RecommendedVisitsParser.Account
            account, Id weekId, Id existId) {
        return new EUR_CRM_Recommended_Account__c(
                EUR_CRM_Account__c = account.Id,
                EUR_CRM_Visit_Type__c = account.VisitType,
                EUR_CRM_Promotion_Score__c = account.PromotionScore,
                EUR_CRM_Business_Development_Score__c = account.BusinessDevScore,
                EUR_CRM_Week_KDP__c = weekId,
                EUR_CRM_Visit_Rank__c = String.valueOf(account.visitRank),
                Id = existId
        );
    }

    private EUR_CRM_Promotion_KDP__c createPromKDPFromParserClass(EUR_CRM_RecommendedVisitsParser.Upcoming_promotion
            promotion, Id weekId, Id accId) {
        return new EUR_CRM_Promotion_KDP__c(
                EUR_CRM_Promotion_Name__c = promotion.Promotion,
                EUR_CRM_Week_KDP__c = weekId,
                EUR_CRM_Account__c = accId
        );
    }

    private EUR_CRM_Promotion_Products_KDP__c createPromPodFromParserClass(Id brandId, Id promId) {
        return new EUR_CRM_Promotion_Products_KDP__c(
                EUR_CRM_Brand__c = brandId,
                EUR_CRM_Promotion__c = promId
        );
    }

    private List<EUR_CRM_Account__c> getAccountsByIds(Set<String> ids) {
        return [
                SELECT Id
                FROM EUR_CRM_Account__c
                WHERE Id IN :ids
        ];
    }
    private List<EUR_CRM_Brand__c> getProductsByIds(Set<String> ids) {
        return [
                SELECT Id
                FROM EUR_CRM_Brand__c
                WHERE Id IN :ids
        ];
    }

    private List<EUR_CRM_Week_KDP__c> getWeeksByStartDate(Set<Date> dates) {
        return [
                SELECT Id, EUR_CRM_Week_Start_Date__c, (
                        SELECT Id,EUR_CRM_Account__c
                        FROM Recommended_Accounts__r
                )
                FROM EUR_CRM_Week_KDP__c
                WHERE EUR_CRM_Week_Start_Date__c IN :dates
        ];
    }

    private List<EUR_CRM_Promotion_KDP__c> getPromotionsByAccIdAndWeekId(Set<Id> accIds, Set<Id> weekIds) {
        return [
                SELECT Id
                FROM EUR_CRM_Promotion_KDP__c
                WHERE EUR_CRM_Account__c IN :accIds
                AND EUR_CRM_Week_KDP__c IN :weekIds
        ];
    }
}