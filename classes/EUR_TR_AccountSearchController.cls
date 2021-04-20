/**
 * Created by ali.kucuk@teknait.com on 9/7/2020.
 */

public with sharing class EUR_TR_AccountSearchController {

    public static EUR_TR_MiddlewareController.PostServiceResponse searchAccounts(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        AccountSearchRequest request = (AccountSearchRequest) JSON.deserialize(requestBody, AccountSearchRequest.class);
        serviceResponse.Code = -1;
        if (request.exportData == true && String.isNotEmpty(request.nextPageExportContext)) {
            String requestJson = EncodingUtil.base64Decode(request.nextPageExportContext).toString();
            request = (AccountSearchRequest) JSON.deserialize(requestJson, AccountSearchRequest.class);
        }
        if (request.recordCount == null) {
            serviceResponse.Message = 'recordCount cannot be null';
            return serviceResponse;
        }
        if (request.recordCount <= 0) {
            serviceResponse.Message = 'recordCount must be bigger than zero';
            return serviceResponse;
        }
        if (request.orderBy == AccountSearchOrderBy.location) {
            if (request.latitude == null) {
                serviceResponse.Message = 'latitude cannot be null when order by location';
                return serviceResponse;
            }
            if (request.longitude == null) {
                serviceResponse.Message = 'longitude cannot be null when order by location';
                return serviceResponse;
            }
        }
        /*
        if (request.orderBy == null) {
            request.orderBy = EUR_TR_AccountSearchController.AccountSearchOrderBy.salesVolume;
        }
        if (request.orderDirection == null){
            request.orderDirection = AccountSearchOrderDirection.descending;
        }
         */
        serviceResponse.Code = 1;
        serviceResponse.Message = 'Success';
        serviceResponse.ExtensionData = searchAccounts(request);

        return serviceResponse;
    }


    public static AccountSearchResponse searchAccounts(AccountSearchRequest request) {
        AccountSearchResponse response = new AccountSearchResponse();
        String query = ' select Id FROM EUR_TR_Account__c WHERE Id != null ';

        if (request.favouriteParams != null && String.isNotBlank(request.favouriteParams)) {
            setAccountRequestFilterFieldsByFavouriteParams(request);
            System.debug(request);
        }

        query += prepareAccountWhereStatement(request, '');

        Set<Id> mustIncludeCustomerIds = new Set<Id>();
        Boolean applyCustomerIdsFilter = getRemPeopleFilteredCustomers(request, mustIncludeCustomerIds);
        Boolean visitFilterApplied = getVisitFilteredCustomers(request, applyCustomerIdsFilter, mustIncludeCustomerIds);
        applyCustomerIdsFilter = applyCustomerIdsFilter || visitFilterApplied;

        String rangeComplianceQuery = prepareRangeComplianceQuery(request);
        String crossComplianceQuery = prepareCrossComplianceQuery(request);

        Set<Id> productFilteredAccountIds = new Set<Id>();
        Boolean hasProductFilter = false;
        if (request.productFilters != null) {
            for (AccountSearchRequestProductFilter filter : request.productFilters) {
                Boolean filterApplied = getProductFilterCustomers(request, filter, productFilteredAccountIds, applyCustomerIdsFilter, mustIncludeCustomerIds, rangeComplianceQuery, crossComplianceQuery);
                hasProductFilter = hasProductFilter || filterApplied;
            }
        }

        if (hasProductFilter || applyCustomerIdsFilter) {

            if (hasProductFilter == false && applyCustomerIdsFilter == true) {
                productFilteredAccountIds = mustIncludeCustomerIds;
            }

            query += ' and Id IN :productFilteredAccountIds ';
        }

        if (String.isNotEmpty(rangeComplianceQuery)) {
            query += ' AND Id IN (' + rangeComplianceQuery + ')';
        }

        if (String.isNotEmpty(crossComplianceQuery)) {
            query += ' AND Id IN (' + crossComplianceQuery + ')';
        }


        if (request.exportData == true) {
            if (request.exportContext != null && String.isNotEmpty(request.exportContext.lastIdInPreviousPage)) {
                query += ' AND Id > \'' + request.exportContext.lastIdInPreviousPage + '\'' ;
            }
            query += ' ORDER BY Id ';
            query += ' LIMIT ' + request.recordCount;
        } else if (request.orderBy == AccountSearchOrderBy.location) {
            query += ' ORDER BY DISTANCE(EUR_TR_Location__c, GEOLOCATION(' + request.latitude + ',' + request.longitude + '), \'km\') ';
            query += request.orderDirection == AccountSearchOrderDirection.ascending ? 'ASC' : 'DESC';
            query += ' NULLS LAST ';
            query += ' LIMIT ' + request.recordCount;
        } else if (request.orderBy == AccountSearchOrderBy.bluePassScore) {
            query += ' AND Id IN (SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_RemPeople__c) ';
        } else if (request.orderBy == AccountSearchOrderBy.growth || request.orderBy == AccountSearchOrderBy.salesVolume) {
            query += ' AND Id IN (SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_AccountSalesMAT__c WHERE EUR_TR_RelatedAccount__c!=NULL) ';
        } else {
            query += ' ORDER BY Name ';
            query += request.orderDirection == AccountSearchOrderDirection.ascending ? 'ASC' : 'DESC';
            query += ' LIMIT ' + request.recordCount;
        }


        System.debug(query);
        List<Id> matchedAccountIds = new List<Id>();
        for (EUR_TR_Account__c account : Database.query(query)) {
            matchedAccountIds.add(account.Id);
        }

        if (request.exportData != true && request.orderBy == AccountSearchOrderBy.bluePassScore) {
            String orderQuery = 'SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_RemPeople__c ' +
                    'WHERE EUR_TR_RelatedAccount__c IN:matchedAccountIds ' +
                    'ORDER BY EUR_TR_BluePassScore__c ';

            orderQuery += request.orderDirection == AccountSearchOrderDirection.ascending ? 'ASC' : 'DESC';
            orderQuery += ' LIMIT ' + request.recordCount;

            Set<Id> orderedAccountIds = new Set<Id>();
            for (EUR_TR_RemPeople__c account : Database.query(orderQuery)) {
                orderedAccountIds.add(account.EUR_TR_RelatedAccount__c);
            }
            matchedAccountIds = new List<Id>(orderedAccountIds);
        }

        if (request.exportData != true && request.orderBy == AccountSearchOrderBy.growth) {
            String orderQuery = 'SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_AccountSalesMAT__c ' +
                    'WHERE EUR_TR_RelatedAccount__c IN:matchedAccountIds ' +
                    'GROUP BY EUR_TR_RelatedAccount__c ' +
                    'ORDER BY SUM(EUR_TR_MAT1MAT2Difference__c) ';

            orderQuery += request.orderDirection == AccountSearchOrderDirection.ascending ? 'ASC' : 'DESC';
            orderQuery += ' LIMIT ' + request.recordCount;

            System.debug(orderQuery);

            Set<Id> orderedAccountIds = new Set<Id>();
            for (AggregateResult salesMATAggResult : Database.query(orderQuery)) {
                if (salesMATAggResult.get('EUR_TR_RelatedAccount__c') != null) {
                    orderedAccountIds.add((Id) salesMATAggResult.get('EUR_TR_RelatedAccount__c'));
                }
            }

            matchedAccountIds = new List<Id>(orderedAccountIds);

        }

        if (request.exportData != true && request.orderBy == AccountSearchOrderBy.salesVolume) {
            String orderQuery = 'SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_AccountSalesMAT__c ' +
                    'WHERE EUR_TR_RelatedAccount__c IN:matchedAccountIds ' +
                    'GROUP BY EUR_TR_RelatedAccount__c ' +
                    'ORDER BY SUM(EUR_TR_MAT1__c) ';

            orderQuery += request.orderDirection == AccountSearchOrderDirection.ascending ? 'ASC' : 'DESC';
            orderQuery += ' LIMIT ' + request.recordCount;

            Set<Id> orderedAccountIds = new Set<Id>();
            for (AggregateResult salesMATAggResult : Database.query(orderQuery)) {
                if (salesMATAggResult.get('EUR_TR_RelatedAccount__c') != null) {
                    orderedAccountIds.add((Id) salesMATAggResult.get('EUR_TR_RelatedAccount__c'));
                }
            }

            matchedAccountIds = new List<Id>(orderedAccountIds);

        }

        if (request.exportData == true && matchedAccountIds.size() > 0 && matchedAccountIds.size() >= request.recordCount) {
            request.exportContext = new AccountSearchExportContext();
            request.exportContext.lastIdInPreviousPage = matchedAccountIds.get(matchedAccountIds.size() - 1);
            response.nextPageExportContext = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(request)));
        }

        //search result enrichment
        Map<Id, AggregateResult> totalSalesMap = new Map<Id, AggregateResult>();
        for (AggregateResult aggregateResult : [
                SELECT EUR_TR_RelatedAccount__c, SUM(EUR_TR_MAT1__c) MAT1, SUM(EUR_TR_MAT2__c) MAT2
                FROM EUR_TR_AccountSalesMAT__c
                WHERE EUR_TR_RelatedAccount__c IN :matchedAccountIds
                GROUP BY EUR_TR_RelatedAccount__c
        ]) {
            totalSalesMap.put((Id) aggregateResult.get('EUR_TR_RelatedAccount__c'), aggregateResult);
        }

        Map<Id, EUR_TR_Account__c> accountMap = new Map<Id, EUR_TR_Account__c>([
                SELECT Id, Name, EUR_TR_AccountCode__c, EUR_TR_Location__Latitude__s, EUR_TR_Location__Longitude__s, EUR_TR_TAPDKLocation__Latitude__s
                        , EUR_TR_TAPDKLocation__Longitude__s, EUR_TR_PresellerName__c, EUR_TR_SalesChiefName__c, EUR_TR_AreaManagerName__c
                        , EUR_TR_ChannelManagerName__c, RecordType.DeveloperName, EUR_TR_Address__c, EUR_TR_TAPDKNo__c, EUR_TR_TopExManagerName__c
                        , EUR_TR_RegisteredName__c, EUR_TR_TAPDKType__c, EUR_TR_HasCensus__c, EUR_TR_CensusDate__c, EUR_TR_CensusChannel__c, EUR_TR_CensusType__c
                        , EUR_TR_CensusScore__c, EUR_TR_CensusImageUrl__c,EUR_TR_MATCY__c, EUR_TR_MATLY__c, EUR_TR_FavoriteCount__c, EUR_TR_LastVisitedDate__c
                        , (SELECT EUR_TR_StartDateTime__c,EUR_TR_VisitFrequency__c FROM EUR_TR_Visits__r ORDER BY EUR_TR_StartDateTime__c DESC LIMIT 1)
                        , (SELECT Id FROM EUR_TR_Route_Detail__r WHERE EUR_TR_RelatedRoute__r.OwnerId = :UserInfo.getUserId() AND EUR_TR_RelatedRoute__r.EUR_TR_IsFavorite__c = TRUE)
                FROM EUR_TR_Account__c
                WHERE Id = :matchedAccountIds
        ]);

        List<EUR_TR_Account__c> accounts = new List<EUR_TR_Account__c>();

        if (request.orderBy == AccountSearchOrderBy.Name || request.orderBy == AccountSearchOrderBy.location || request.orderBy == AccountSearchOrderBy.salesVolume || request.orderBy == AccountSearchOrderBy.growth || request.orderBy == AccountSearchOrderBy.bluePassScore) {
            for (Id orderedId : matchedAccountIds) {
                if (accountMap.containsKey(orderedId)) {
                    accounts.add(accountMap.get(orderedId));
                }
            }
        } else {
            accounts = accountMap.values();
        }

        Set<Id> startedDailyWorkVisitAccountIds = new Set<Id>();
        if (request.exportData != true) {
            startedDailyWorkVisitAccountIds = getStartedDailyWorkVisitAccountIds(matchedAccountIds);
        }

        EUR_TR_Visit__c latestVisit = null;
        for (EUR_TR_Account__c account : accounts) {
            AggregateResult aggregateResult = totalSalesMap.get(account.Id);
            if (aggregateResult != null) {
                account.EUR_TR_MATCY__c = (Decimal) aggregateResult.get('MAT1');
                account.EUR_TR_MATLY__c = (Decimal) aggregateResult.get('MAT2');
            }

            if (account.EUR_TR_Visits__r != null && !account.EUR_TR_Visits__r.isEmpty()) {
                latestVisit = account.EUR_TR_Visits__r[0];
                account.EUR_TR_LastVisitedDate__c = latestVisit.EUR_TR_StartDateTime__c;
            }

            if (request.exportData != true && !startedDailyWorkVisitAccountIds.isEmpty()) {
                if (startedDailyWorkVisitAccountIds.contains(account.Id)) {
                    account.EUR_TR_IsAccountInRouteVisit__c = true;
                } else {
                    account.EUR_TR_IsAccountInRouteVisit__c = false;
                }
            }

            account.EUR_TR_FavoriteCount__c = account.EUR_TR_Route_Detail__r.size();
        }
        response.accounts = accounts;
        return response;
    }

    static Boolean getVisitFilteredCustomers(AccountSearchRequest request, Boolean applyCustomerIdsFilter, Set<Id> mustIncludeCustomerIds) {
        Id connectedUserId = UserInfo.getUserId();
        String query = '';
        if (request.visitFrequency != null && !request.visitFrequency.isEmpty()) {
            query += 'SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_Visit__c WHERE OwnerId = \'' + connectedUserId + '\' ';
            query += prepareStringInStatement('AND', 'EUR_TR_VisitFrequency__c', request.visitFrequency);
            query += prepareAccountWhereStatement(request, 'EUR_TR_RelatedAccount__r.');
            if (applyCustomerIdsFilter) {
                query += ' AND EUR_TR_RelatedAccount__c IN:mustIncludeCustomerIds';
            }


            System.debug(query);
            Set<Id> newMustIncludeCustomerIds = new Set<Id>();
            for (SObject record : Database.query(query)) {
                newMustIncludeCustomerIds.add((Id) record.get('EUR_TR_RelatedAccount__c'));
            }
            mustIncludeCustomerIds.clear();
            mustIncludeCustomerIds.addAll(newMustIncludeCustomerIds);
            return true;
        }
        return applyCustomerIdsFilter;
    }

    static String prepareRangeComplianceQuery(AccountSearchRequest request) {
        String query = '';

        if (request.rangeCompliance != null && !request.rangeCompliance.isEmpty()) {
            query += 'SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_AccountRange__c WHERE ' +
                    prepareStringInStatement('', 'EUR_TR_MATCluster__c', request.rangeCompliance);

            query += prepareAccountWhereStatement(request, 'EUR_TR_RelatedAccount__r.');
        }
        return query;
    }

    static String prepareCrossComplianceQuery(AccountSearchRequest request) {

        String query = '';
        if (request.crossCompliance != null && !request.crossCompliance.isEmpty()) {

            query += 'SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_CrossCompliance__c WHERE ';
            List<String> listOfCrossCompliance = new List<String>();
            for (String crossCompliance : request.crossCompliance) {
                if (String.isBlank(crossCompliance)) {
                    continue;
                }
                listOfCrossCompliance.add(String.format('{0}={1}', new List<String>{
                        crossCompliance, String.valueOf(true)
                }));
            }
            if (!listOfCrossCompliance.isEmpty()) {
                query += String.format('{0}', new List<String>{
                        String.join(listOfCrossCompliance, ' AND ')
                });
                query += prepareAccountWhereStatement(request, 'EUR_TR_RelatedAccount__r.');
            }

        }
        return query;

    }

    static String prepareMinMaxStatement(String field, Decimal min, Decimal max) {
        String statement = '';
        if (min != null) {
            statement += ' AND ' + field + ' >= ' + min;
        }
        if (max != null) {
            statement += ' AND ' + field + ' <= ' + max;
        }
        return statement;
    }

    static Boolean getRemPeopleFilteredCustomers(AccountSearchRequest request, Set<Id> mustIncludeCustomerIds) {
        String qWhere = '';
        qWhere += prepareMinMaxStatement('EUR_TR_BluePassScore__c', request.bluePassScoreMin, request.bluePassScoreMax);
        qWhere += prepareMinMaxStatement('EUR_TR_MyWhiskeyScore__c', request.whiskeyScoreMin, request.whiskeyScoreMax);
        qWhere += prepareMinMaxStatement('EUR_TR_MyVodkaScore__c', request.vodkaScoreMin, request.vodkaScoreMax);
        qWhere += prepareMinMaxStatement('EUR_TR_PlacementScore__c', request.placementScoreMin, request.placementScoreMax);
        qWhere += prepareMinMaxStatement('EUR_TR_PassportAvailabilityScore__c', request.availabilityScoreMin, request.availabilityScoreMax);
        qWhere += prepareMinMaxStatement('EUR_TR_WhiteCriteriaScore__c', request.whiteCriteriaScoreMin, request.whiteCriteriaScoreMax);

        Boolean hasRemPeopleFilter = false;

        if (String.isNotEmpty(qWhere)) {
            hasRemPeopleFilter = true;
            String query = 'SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_RemPeople__c WHERE EUR_TR_RelatedAccount__c != null '
                    + qWhere
                    + prepareAccountWhereStatement(request, 'EUR_TR_RelatedAccount__r.');

            System.debug(query);
            for (SObject record : Database.query(query)) {
                mustIncludeCustomerIds.add((Id) record.get('EUR_TR_RelatedAccount__c'));
            }
        }
        return hasRemPeopleFilter;
    }

    static Boolean getProductFilterCustomers(AccountSearchRequest request, AccountSearchRequestProductFilter filter, Set<Id> bsAccountIds, Boolean applyCustomerIdsFilter, Set<Id> mustIncludeCustomerIds, String rangeComplianceQuery, String crossComplianceQuery) {
        AccountSearchPeriod period = filter.period;
        List<String> brands = filter.brands == null ? new List<String>() : filter.brands;
        List<String> skus = filter.skus == null ? new List<String>() : filter.skus;
        Decimal brandShareMin = filter.brandShareMin == null ? 0 : filter.brandShareMin / 100;
        Decimal brandShareMax = filter.brandShareMax == null ? 1 : filter.brandShareMax / 100;
        List<String> clusters = filter.clusters == null ? new List<String>() : filter.clusters;
        List<String> caseClusters = filter.caseClusters == null ? new List<String>() : filter.caseClusters;
        Decimal volumeMin = filter.volumeMin == null ? 0 : filter.volumeMin;
        Decimal volumeMax = filter.volumeMax == null ? 99999 : filter.volumeMax;
        List<String> existNonExists = filter.existNonExists == null ? new List<String>() : filter.existNonExists;
        String matLast6 = filter.matLast6;
        String invoiceStatus = filter.invoiceStatus;
        String isIncentiveAccount = filter.isIncentiveAccount;
        List<String> incentiveBrands = filter.incentiveBrands;

        String shareField = '';
        String clusterField = '';
        String caseClusterField = '';
        String volumeField = '';
        switch on period {
            when MAT {
                shareField = 'EUR_TR_MATShare__c';
                clusterField = 'EUR_TR_MATCluster__c';
                caseClusterField = 'EUR_TR_MATCaseCluster__c';
                volumeField = 'EUR_TR_MATActual__c';
            }
            when MTD {
                shareField = 'EUR_TR_MTDShare__c';
                clusterField = 'EUR_TR_MTDCluster__c';
                caseClusterField = 'EUR_TR_MTDCaseCluster__c';
                volumeField = 'EUR_TR_MTDActual__c';
            }
            when QTD {
                shareField = 'EUR_TR_QTDShare__c';
                clusterField = 'EUR_TR_QTDCluster__c';
                caseClusterField = 'EUR_TR_QTDCaseCluster__c';
                volumeField = 'EUR_TR_QTDActual__c';
            }
            when YTD {
                shareField = 'EUR_TR_QTDShare__c';
                clusterField = 'EUR_TR_QTDCluster__c';
                caseClusterField = 'EUR_TR_QTDCaseCluster__c';
                volumeField = 'EUR_TR_QTDActual__c';
            }
            when else {
                return false;
            }
        }

        String qHaving = 'having EUR_TR_RelatedAccount__c!=null ';
        String qWhere = '';
        if (filter.brandShareMin != null) {
            qHaving += ' and avg(' + shareField + ')>=  ' + brandShareMin;
        }
        if (filter.brandShareMax != null) {
            qHaving += ' and avg(' + shareField + ')<=  ' + brandShareMax;
        }
        if (!clusters.isEmpty()) {
            qWhere += prepareStringInStatement('AND', clusterField, clusters);
        }
        if (!caseClusters.isEmpty()) {
            qWhere += prepareStringInStatement('AND', caseClusterField, caseClusters);
        }
        if (filter.volumeMin != null) {
            qHaving += ' and sum(' + volumeField + ')>= ' + volumeMin;
        }
        if (filter.volumeMax != null) {
            qHaving += ' and sum(' + volumeField + ')<= ' + volumeMax;
        }

        qWhere += prepareAccountWhereStatement(request, 'EUR_TR_RelatedAccount__r.');

        if (matLast6 != null && !existNonExists.isEmpty()) {
            if (matLast6 == 'MAT') {
                qWhere += prepareStringInStatement('AND', 'EUR_TR_MAT_VARYOK__c', existNonExists);
            } else {
                qWhere += prepareStringInStatement('AND', 'EUR_TR_YTD_VARYOK__c', existNonExists);
            }
        }

        String invoiceQuery = getInvoiceFilterQuery(invoiceStatus, brands, skus);
        if (String.isNotEmpty(invoiceQuery)) {
            qWhere += ' AND EUR_TR_RelatedAccount__c NOT IN (' + invoiceQuery + ')';
        }
        if (applyCustomerIdsFilter) {
            qWhere += ' AND EUR_TR_RelatedAccount__c IN:mustIncludeCustomerIds ';
        }

        if (String.isNotEmpty(rangeComplianceQuery)) {
            qWhere += ' AND EUR_TR_RelatedAccount__c IN (' + rangeComplianceQuery + ')';
        }

        if (String.isNotEmpty(crossComplianceQuery)) {
            // obtained Ids to salesforce limit (Maximum 2 semi join sub-selects are allowed)
            Set<Id> accountIdsByCrossCompliance = new Set<Id>();
            for (SObject record : Database.query(crossComplianceQuery)) {
                accountIdsByCrossCompliance.add((String) record.get('EUR_TR_RelatedAccount__c'));
            }
            if (!accountIdsByCrossCompliance.isEmpty()) {
                qWhere += ' AND EUR_TR_RelatedAccount__c IN :accountIdsByCrossCompliance';
            }

        }

        if (isIncentiveAccount != null && incentiveBrands != null) {
            Set<Id> accountIdsByIncentive = getAccountIdsByIncentiveFilters(isIncentiveAccount, incentiveBrands);
            if (!accountIdsByIncentive.isEmpty()) {
                qWhere += ' AND EUR_TR_RelatedAccount__c IN :accountIdsByIncentive';
            }
        }

        String bsQuery = '';
        if (period != null && !brands.isEmpty() && !skus.isEmpty()) {
            bsQuery = ' SELECT EUR_TR_RelatedAccount__c from EUR_TR_AccountSales__c WHERE '
                    + prepareStringInStatement('', 'EUR_TR_BrandQuality__c', brands)
                    + prepareStringInStatement('AND', 'EUR_TR_BrandQualitySize__c', skus)
                    + qWhere
                    + ' GROUP BY EUR_TR_RelatedAccount__c '
                    + qHaving;
        }
        if (period != null && !brands.isEmpty() && skus.isEmpty()) {
            bsQuery = 'SELECT EUR_TR_RelatedAccount__c from EUR_TR_AccountSalesHofBrand__c WHERE '
                    + prepareStringInStatement('', 'EUR_TR_Brand_Quality__c', brands)
                    + qWhere
                    + ' GROUP BY EUR_TR_RelatedAccount__c '
                    + qHaving;
        }
        if (period != null && brands.isEmpty() && skus.isEmpty()) {
            bsQuery = 'SELECT EUR_TR_RelatedAccount__c from EUR_TR_AccountSalesBrand__c WHERE EUR_TR_RelatedAccount__c!=null '
                    + qWhere
                    + ' GROUP BY EUR_TR_RelatedAccount__c '
                    + qHaving;
        }

        Boolean hasBSFilter = false;
        if (String.isNotEmpty(bsQuery)) {
            hasBSFilter = true;
            System.debug(bsQuery);
            // workaround -  System.QueryException: Aggregate query does not support queryMore()
            // source : https://salesforce.stackexchange.com/questions/33100/system-queryexception-aggregate-query-does-not-support-querymore
            List<SObject> results = Database.query(bsQuery);
            for (SObject record : results) {
                bsAccountIds.add((Id) record.get('EUR_TR_RelatedAccount__c'));
            }
        }

        return hasBSFilter;
    }

    static String getInvoiceFilterQuery(String invoiceStatus, List<String> brands, List<String> skus) {
        Boolean hasInvoiceFilter = false;
        if (String.isNotEmpty(invoiceStatus)) {
            String invoiceWhere = 'select EUR_TR_RelatedAccount__c from EUR_TR_InvoiceSummary__c  where Id!=null ';
            if (invoiceStatus == 'Son 3 Ay') {
                invoiceWhere += ' and EUR_TR_3MonthsCount__c > 0';
                hasInvoiceFilter = true;
            } else if (invoiceStatus == 'Son 6 Ay') {
                invoiceWhere += ' and EUR_TR_6MonthsCount__c > 0';
                hasInvoiceFilter = true;
            } else if (invoiceStatus == 'Son 12 Ay') {
                invoiceWhere += ' and EUR_TR_12MonthsCount__c > 0';
                hasInvoiceFilter = true;
            }
            if (brands != null && !brands.isEmpty()) {
                invoiceWhere += prepareStringInStatement('AND', 'EUR_TR_HouseOfBrands__c', brands);
                hasInvoiceFilter = true;
            }
            if (skus != null && !skus.isEmpty()) {
                invoiceWhere += prepareStringInStatement('AND', 'EUR_TR_BrandQualitySize__c', skus);
                hasInvoiceFilter = true;
            }
            if (hasInvoiceFilter) {
                return invoiceWhere;
            }
        }
        return '';
    }

    static Set<Id> getAccountIdsByIncentiveFilters(String isIncentiveAccount, List<String> brands) {

        Set<Id> incentiveAccountIds = new Set<Id>();

        if (String.isBlank(isIncentiveAccount)) {
            return incentiveAccountIds;
        }

        if (isIncentiveAccount.equalsIgnoreCase('Hayır')) {
            return incentiveAccountIds;
        }

        if (isIncentiveAccount.equalsIgnoreCase('Evet')) {
            if (brands != null && !brands.isEmpty()) {
                for (SObject incentive : [SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_Incentive__c WHERE EUR_TR_RelatedAccount__c != NULL AND EUR_TR_Brand__c = :brands GROUP BY EUR_TR_RelatedAccount__c]) {
                    incentiveAccountIds.add((Id) incentive.get('EUR_TR_RelatedAccount__c'));
                }
            } else {
                for (SObject incentive : [SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_Incentive__c WHERE EUR_TR_RelatedAccount__c != NULL GROUP BY EUR_TR_RelatedAccount__c]) {
                    incentiveAccountIds.add((Id) incentive.get('EUR_TR_RelatedAccount__c'));
                }
            }
        }

        return incentiveAccountIds;

    }

    static String prepareStringParam(String param) {
        return '\'' + String.escapeSingleQuotes(param) + '\'';
    }

    static String prepareStringInStatement(String operator, String field, List<String> params) {
        List<String> paramsWithQuotes = new List<String>();
        for (String item : params) {
            paramsWithQuotes.add(prepareStringParam(item));
        }
        return String.format(' {0} {1} IN  ({2}) ', new List<String>{
                operator,
                field,
                String.join(paramsWithQuotes, ',')
        });
    }

    static String prepareAccountWhereStatement(AccountSearchRequest request, String fieldPrefix) {
        String qWhere = '';
        if (String.isNotEmpty(request.searchTerm)) {
            String name = prepareStringParam('%' + request.searchTerm + '%');
            String nameReplaced = name.replace('i', 'İ');
            qWhere += String.format(' AND (' +
                    '{0}Name like {1} ' +
                    'or {0}Name like {2} ' +
                    'or {0}EUR_TR_LocalName__c like {1} ' +
                    'or {0}EUR_TR_LocalName__c like {2} ' +
                    'or {0}EUR_TR_AccountCode__c like {1} ' +
                    'or {0}EUR_TR_AccountCode__c like {2} ' +
                    'or {0}EUR_TR_RegisteredName__c like {1} ' +
                    'or {0}EUR_TR_RegisteredName__c like {2}' +
                    ') '
                    , new List<String>{
                            fieldPrefix, name, nameReplaced
                    });
        }

        if (request.types != null && !request.types.isEmpty()) {
            qWhere += prepareStringInStatement('AND', fieldPrefix + 'EUR_TR_Type__c', request.types);
        }

        if (request.classes != null && !request.classes.isEmpty()) {
            qWhere += prepareStringInStatement('AND', fieldPrefix + 'EUR_TR_Class__c', request.classes);
        }

        if (request.statuses != null && !request.statuses.isEmpty()) {
            qWhere += prepareStringInStatement('AND', fieldPrefix + 'EUR_TR_Status__c', request.statuses);
        }

        if (request.distributors != null && !request.distributors.isEmpty()) {
            qWhere += prepareStringInStatement('AND', fieldPrefix + 'EUR_TR_DistributorName__c', request.distributors);
        }

        if (request.channels != null && !request.channels.isEmpty()) {
            qWhere += prepareStringInStatement('AND', fieldPrefix + 'EUR_TR_Channel__c', request.channels);
        }

        if (request.cities != null && !request.cities.isEmpty()) {
            qWhere += prepareStringInStatement('AND', fieldPrefix + 'EUR_TR_CityName__c', request.cities);
        }

        if (request.districts != null && !request.districts.isEmpty()) {
            qWhere += prepareStringInStatement('AND', fieldPrefix + 'EUR_TR_DistrictName__c', request.districts);
        }

        if (request.ranges != null && !request.ranges.isEmpty()) {
            qWhere += prepareStringInStatement('AND', fieldPrefix + 'EUR_TR_Range__c', request.ranges);
        }

        if (request.attackbrands != null && !request.attackbrands.isEmpty()) {
            qWhere += prepareStringInStatement('AND', fieldPrefix + 'EUR_TR_AttackBrand__c', request.attackbrands);
        }

        Boolean hasLocationFilter = request.longitude != null && request.longitude > 0
                && request.latitude != null && request.latitude > 0
                && request.radiusKm != null && request.radiusKm > 0;

        if (hasLocationFilter) {
            qWhere += String.format('and DISTANCE({0}EUR_TR_Location__c, GEOLOCATION({1},{2}), \'\'km\'\') < {3}'
                    , new List<String>{
                            fieldPrefix,
                            String.valueOf(request.latitude),
                            String.valueOf(request.longitude),
                            String.valueOf(request.radiusKm)
                    });
        }

        if (request.outOfScope != null && request.outOfScope == true) {
            qWhere += ' and ' + fieldPrefix + 'RecordType.DeveloperName = \'EUR_TR_TAPDK\' ';
            qWhere += String.format(' and ( NOT {0}Name Like \'\'%MIGROS%\'\') and ( NOT {0}Name Like \'\'%CARREFOUR%\'\') and ( NOT {0}Name Like \'\'%METRO%\'\')  ',
                    new List<String>{
                            fieldPrefix
                    });

        } else {
            qWhere += ' and ' + fieldPrefix + 'RecordType.DeveloperName != \'EUR_TR_TAPDK\' ';
        }

        if (request.census != null) {
            if (request.census == true) {
                qWhere += ' and ' + fieldPrefix + 'EUR_TR_HasCensus__c = TRUE ';
            } else {
                qWhere += ' and ' + fieldPrefix + 'EUR_TR_HasCensus__c = FALSE ';
            }
        }
        return qWhere;
    }

    static void setAccountRequestFilterFieldsByFavouriteParams(AccountSearchRequest searchRequest) {

        String jsonFavouritesArray = '[' + searchRequest.favouriteParams + ']';
        List<Object> items = (List<Object>) JSON.deserializeUntyped(jsonFavouritesArray);

        Map<String, Object> favouriteParamMap = new Map<String, Object>();
        /*for (Object itemObj : items) {
            Map<String, Object> item = (Map<String, Object>) itemObj;
            if (favouriteParamMap.containsKey((String) item.get('key'))) {
                if ((String) item.get('key') == 'longitude' || (String) item.get('key') == 'latitude'){
                    continue;
                }
                Object val = favouriteParamMap.get((String) item.get('key'));
                favouriteParamMap.remove((String) item.get('key'));
                list<String> tmpList = new List<String>();
                tmpList.add(String.valueOf(val));
                tmpList.add(String.valueOf(String.valueOf(item.get('value'))));
                favouriteParamMap.put((String) item.get('key'), tmpList);
                //System.debug(favouriteParamMap.get((String) item.get('key')));
            } else {
                favouriteParamMap.put((String) item.get('key'), item.get('value'));
            }
        }*/
        for (Object itemObj : items) {
            Map<String, Object> item = (Map<String, Object>) itemObj;
            favouriteParamMap.put((String) item.get('key'), item.get('value'));
        }

        EUR_TR_AccountSearchController.AccountSearchRequestProductFilter accountSearchRequestProductFilter = new AccountSearchRequestProductFilter();
        if (searchRequest.productFilters == null) {
            searchRequest.productFilters = new List<EUR_TR_AccountSearchController.AccountSearchRequestProductFilter>();
        }
        searchRequest.productFilters.add(accountSearchRequestProductFilter);

        Object favouriteParam = null;
        String paramKeyName = '';

        paramKeyName = 'longitude';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null) {
                searchRequest.longitude = Double.valueOf(favouriteParam);
            }
        }

        paramKeyName = 'latitude';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null) {
                searchRequest.latitude = Double.valueOf(favouriteParam);
            }
        }

        paramKeyName = 'cities';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> cities = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!cities.isEmpty()) {
                    searchRequest.cities = cities;
                }
            }
        }

        paramKeyName = 'types';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> types = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!types.isEmpty()) {
                    searchRequest.types = types;
                }
            }
        }

        paramKeyName = 'classes';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> classes = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!classes.isEmpty()) {
                    searchRequest.classes = classes;
                }
            }
        }

        paramKeyName = 'ranges';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> ranges = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!ranges.isEmpty()) {
                    searchRequest.ranges = ranges;
                }
            }
        }

        paramKeyName = 'distributors';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> distributors = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!distributors.isEmpty()) {
                    searchRequest.distributors = distributors;
                }
            }
        }

        paramKeyName = 'statuses';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> statuses = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!statuses.isEmpty()) {
                    searchRequest.statuses = statuses;
                }
            }
        }

        paramKeyName = 'brands';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> brands = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!brands.isEmpty()) {
                    accountSearchRequestProductFilter.brands = brands;
                }
            } else if (favouriteParam != null) {
                accountSearchRequestProductFilter.brands = new List<String>();
                accountSearchRequestProductFilter.brands.add(String.valueOf(favouriteParam));
            }
        }

        paramKeyName = 'period';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null) {
                String periods = String.valueOf(favouriteParam);
                if (!String.isEmpty(periods)) {
                    if (periods != null) {
                        if (periods == AccountSearchPeriod.MAT.name()) {
                            accountSearchRequestProductFilter.period = AccountSearchPeriod.MAT;
                        } else if (periods == AccountSearchPeriod.MTD.name()) {
                            accountSearchRequestProductFilter.period = AccountSearchPeriod.MTD;
                        } else if (periods == AccountSearchPeriod.QTD.name()) {
                            accountSearchRequestProductFilter.period = AccountSearchPeriod.QTD;
                        } else if (periods == AccountSearchPeriod.YTD.name()) {
                            accountSearchRequestProductFilter.period = AccountSearchPeriod.YTD;
                        }
                    }

                }
            }
        }

        paramKeyName = 'volumeMax';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            String volumeMax = String.valueOf(favouriteParam);

            if (String.isNotBlank(volumeMax)) {
                accountSearchRequestProductFilter.volumeMax = Decimal.valueOf(volumeMax);
            }
        }

        paramKeyName = 'volumeMin';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            String volumeMin = String.valueOf(favouriteParam);

            if (String.isNotBlank(volumeMin)) {
                accountSearchRequestProductFilter.volumeMin = Decimal.valueOf(volumeMin);
            }
        }

        paramKeyName = 'invoiceStatus';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null) {
                accountSearchRequestProductFilter.invoicestatus = String.valueOf(favouriteParam);
            }
        }

        paramKeyName = 'rangeCompliance';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> rangeCompliance = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!rangeCompliance.isEmpty()) {
                    searchRequest.rangeCompliance = rangeCompliance;
                }
            }
        }

        paramKeyName = 'crossCompliance';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> crossCompliance = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!crossCompliance.isEmpty()) {
                    searchRequest.crossCompliance = crossCompliance;
                }
            }
        }

        paramKeyName = 'districts';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> districts = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!districts.isEmpty()) {
                    searchRequest.districts = districts;
                }
            }
        }

        paramKeyName = 'radiusKm';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null) {
                searchRequest.radiusKm = Double.valueOf(favouriteParam);
            }
        }

        paramKeyName = 'sku';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                accountSearchRequestProductFilter.skus = new List<String>();
                accountSearchRequestProductFilter.skus.add(String.valueOf(favouriteParam));
            } else if (favouriteParam != null) {
                accountSearchRequestProductFilter.brands = new List<String>();
                accountSearchRequestProductFilter.brands.add(String.valueOf(favouriteParam));
            }
        }

        paramKeyName = 'channels';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> channels = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!channels.isEmpty()) {
                    searchRequest.channels = channels;
                }
            }
        }

        paramKeyName = 'isIncentiveAccount';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null) {
                accountSearchRequestProductFilter.isIncentiveAccount = String.valueOf(favouriteParam);
            }
        }

        paramKeyName = 'incentiveBrands';
        if (favouriteParamMap.containsKey(paramKeyName)) {
            favouriteParam = favouriteParamMap.get(paramKeyName);
            if (favouriteParam != null && favouriteParam instanceof List<Object>) {
                List<String> incentiveBrands = getValuesFromObjectList((List<Object>) favouriteParam);
                if (!incentiveBrands.isEmpty()) {
                    if (!incentiveBrands.isEmpty()) {
                        accountSearchRequestProductFilter.incentiveBrands = incentiveBrands;
                    }
                }
            }
        }

        /*
       paramKeyName = 'existNonExists';
       if (favouriteParamMap.containsKey(paramKeyName)) {
           favouriteParam = favouriteParamMap.get(paramKeyName);
           if (favouriteParam != null && favouriteParam instanceof List<Object>) {
               List<String> existNonExists = getValuesFromObjectList((List<Object>) favouriteParam);
               if (!existNonExists.isEmpty()) {
                   accountSearchRequestProductFilter.existNonExists = existNonExists;
               }
           }
       }

       paramKeyName = 'cluster';
       if (favouriteParamMap.containsKey(paramKeyName)) {
           favouriteParam = favouriteParamMap.get(paramKeyName);
           if (favouriteParam != null && favouriteParam instanceof List<Object>) {
               List<String> clusters = getValuesFromObjectList((List<Object>) favouriteParam);
               if (!clusters.isEmpty()) {
                   accountSearchRequestProductFilter.clusters = clusters;
               }
           }
       }

       paramKeyName = 'caseCluster';
       if (favouriteParamMap.containsKey(paramKeyName)) {
           favouriteParam = favouriteParamMap.get(paramKeyName);
           if (favouriteParam != null && favouriteParam instanceof List<Object>) {
               List<String> caseClusters = getValuesFromObjectList((List<Object>) favouriteParam);
               if (!caseClusters.isEmpty()) {
                   accountSearchRequestProductFilter.caseClusters = caseClusters;
               }
           }
       }
       */

    }

    private static List<String> getValuesFromObjectList(List<Object> objValues) {
        List<String> strValues = new List<String>();
        for (Object value : objValues) {
            strValues.add((String) value);
        }
        return strValues;
    }

    static Set<Id> getStartedDailyWorkVisitAccountIds(List<Id> matchedAccountIds) {

        Id currentWorkedDayId = null;
        Set<Id> startedDailyWorkVisitAccountIds = new Set<Id>();

        EUR_TR_Visit__c currentWorkedDay = EUR_TR_WorkedDayController.getCurrentWorkedDay();

        if (currentWorkedDay != null) {
            currentWorkedDayId = currentWorkedDay.Id;
            if (!matchedAccountIds.isEmpty()) {
                String aggregateResultQueryToDailyRouteVisits =
                        'SELECT EUR_TR_RelatedAccount__c ' +
                                'FROM EUR_TR_Visit__c ' +
                                'WHERE EUR_TR_RelatedAccount__c = :matchedAccountIds AND ' +
                                'EUR_TR_RelatedWorkedDay__c != NULL AND EUR_TR_VisitType__c = \'In-Route\' AND EUR_TR_RelatedWorkedDay__c = :currentWorkedDayId ' +
                                'GROUP BY EUR_TR_RelatedAccount__c';

                List<SObject> results = Database.query(aggregateResultQueryToDailyRouteVisits);
                for (SObject record : results) {
                    Id relatedAccount = String.valueOf(record.get('EUR_TR_RelatedAccount__c'));
                    startedDailyWorkVisitAccountIds.add(relatedAccount);
                }
            }
        }

        return startedDailyWorkVisitAccountIds;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse OrderAccounts(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        AccountOrderRequest request = (AccountOrderRequest) JSON.deserialize(requestBody, AccountOrderRequest.class);
        serviceResponse.Code = -1;
        if (request.Accounts == null || request.Accounts.size() <= 0) {
            serviceResponse.Message = 'Accounts can not be null';
            return serviceResponse;
        }
        if (request.orderBy == null) {
            serviceResponse.Message = 'orderBy must be bigger than zero';
            return serviceResponse;
        }
        if (request.orderDirection == null) {
            serviceResponse.Message = 'orderDirection must be bigger than zero';
            return serviceResponse;
        }

        System.debug('Account Size To Order : ' + request.Accounts.size());

        String AccountQuery = '';
        List<EUR_TR_Account__c> AccountResult = new List<EUR_TR_Account__c>();
        Map<Id, Boolean> foundIds = new Map<Id, Boolean>();
        String IdInStatement = prepareStringInStatement('', '', request.accounts);

        AccountQuery = 'SELECT Id, Name, EUR_TR_AccountCode__c, EUR_TR_Location__Latitude__s, EUR_TR_Location__Longitude__s, EUR_TR_TAPDKLocation__Latitude__s ';
        AccountQuery += '  , EUR_TR_TAPDKLocation__Longitude__s, EUR_TR_PresellerName__c, EUR_TR_SalesChiefName__c, EUR_TR_AreaManagerName__c ';
        AccountQuery += ' , EUR_TR_ChannelManagerName__c, RecordType.DeveloperName, EUR_TR_Address__c, EUR_TR_TAPDKNo__c, EUR_TR_TopExManagerName__c ';
        AccountQuery += ' , EUR_TR_RegisteredName__c, EUR_TR_TAPDKType__c, EUR_TR_HasCensus__c, EUR_TR_CensusDate__c, EUR_TR_CensusChannel__c, EUR_TR_CensusType__c ';
        AccountQuery += ' , EUR_TR_CensusScore__c, EUR_TR_CensusImageUrl__c,EUR_TR_MATCY__c, EUR_TR_MATLY__c, EUR_TR_FavoriteCount__c, EUR_TR_LastVisitedDate__c ';
        AccountQuery += ' FROM EUR_TR_Account__c ';
        AccountQuery += ' WHERE Id ' + IdInStatement;

        if (request.orderBy == AccountSearchOrderBy.location || request.orderBy == AccountSearchOrderBy.Name) {

            if (request.orderBy == AccountSearchOrderBy.location) {
                AccountQuery += ' ORDER BY DISTANCE(EUR_TR_Location__c, GEOLOCATION(' + request.latitude + ',' + request.longitude + '), \'km\') ';
            } else {
                AccountQuery += ' ORDER BY Name ';
            }
            AccountQuery += request.orderDirection == AccountSearchOrderDirection.ascending ? 'ASC' : 'DESC';
            AccountQuery += ' NULLS LAST ';
            Map<Id, EUR_TR_Account__c> AccountQueryresult = new Map<Id, EUR_TR_Account__c>((EUR_TR_Account__c[]) Database.query(AccountQuery));

            for (EUR_TR_Account__c item : AccountQueryresult.values()) {
                AccountResult.add(item);
            }

        } else if (request.orderBy == AccountSearchOrderBy.bluePassScore) {

            String bluePassQuery = 'SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_RemPeople__c ';
            bluePassQuery += 'WHERE EUR_TR_RelatedAccount__c!=NULL AND EUR_TR_BluePassScore__c!=NULL AND EUR_TR_RelatedAccount__c ' + IdInStatement;
            bluePassQuery += 'GROUP BY EUR_TR_RelatedAccount__c ';
            bluePassQuery += 'ORDER BY SUM(EUR_TR_BluePassScore__c) ';
            bluePassQuery += request.orderDirection == AccountSearchOrderDirection.ascending ? 'ASC' : 'DESC';

            System.debug(bluePassQuery);
            System.debug(AccountQuery);

            Map<Id, EUR_TR_Account__c> AccountQueryResult = new Map<Id, EUR_TR_Account__c>((EUR_TR_Account__c[]) Database.query(AccountQuery));

            Set<Id> orderedAccountIdsByBluePassScore = new Set<Id>();
            List<SObject> orderedBluePassResult = Database.query(bluePassQuery);
            for (SObject record : orderedBluePassResult) {
                orderedAccountIdsByBluePassScore.add((Id) record.get('EUR_TR_RelatedAccount__c'));
            }

            // Some accounts don't have a blue pass score, these accounts will be located at the beginning of the list.
            for (EUR_TR_Account__c account : AccountQueryResult.values()) {
                if (!orderedAccountIdsByBluePassScore.contains(account.Id)) {
                    AccountResult.add(account);
                }
            }

            for (Id orderedAccountId : orderedAccountIdsByBluePassScore) {
                if (AccountQueryResult.containsKey(orderedAccountId)) {
                    AccountResult.add(AccountQueryResult.get(orderedAccountId));
                }
            }
            System.debug(AccountResult.size());

        } else if (request.orderBy == AccountSearchOrderBy.salesVolume || request.orderBy == AccountSearchOrderBy.growth) {
            String salesvolumeQuery = 'SELECT EUR_TR_RelatedAccount__c FROM EUR_TR_AccountSalesMAT__c ';
            salesvolumeQuery += ' WHERE EUR_TR_RelatedAccount__c ' + IdInStatement;
            salesvolumeQuery += ' GROUP BY EUR_TR_RelatedAccount__c ORDER BY SUM(EUR_TR_MAT1__c) ';
            salesvolumeQuery += request.orderDirection == AccountSearchOrderDirection.ascending ? 'ASC' : 'DESC';

            System.debug(salesvolumeQuery);
            List<AggregateResult> salesvolumeResult = Database.query(salesvolumeQuery);
            Map<Id, EUR_TR_Account__c> AccountQueryResult = new Map<Id, EUR_TR_Account__c>((EUR_TR_Account__c[]) Database.query(AccountQuery));

            for (EUR_TR_Account__c acc : AccountQueryResult.values()) {
                foundIds.put(acc.Id, false);
            }


            for (AggregateResult item : salesvolumeResult) {
                String AccountId = String.valueOf(item.get('EUR_TR_RelatedAccount__c'));
                if (AccountQueryResult.containsKey(AccountId)) {
                    AccountResult.add(AccountQueryResult.get(AccountId));
                    foundIds.put(AccountId, true);
                }
            }

            for (Id accId : foundIds.keySet()) {
                if (foundIds.get(accId) == false) {
                    AccountResult.add(AccountQueryResult.get(accId));
                }
            }
        }

        Map<Id, AggregateResult> totalSalesMap = new Map<Id, AggregateResult>();
        for (AggregateResult aggregateResult : [
                SELECT EUR_TR_RelatedAccount__c,
                        SUM(EUR_TR_MAT1__c) EUR_TR_MAT1__c,
                        SUM(EUR_TR_MAT2__c) EUR_TR_MAT2__c
                FROM EUR_TR_AccountSalesMAT__c
                WHERE EUR_TR_RelatedAccount__c IN :request.accounts
                GROUP BY EUR_TR_RelatedAccount__c
        ]) {
            totalSalesMap.put((Id) aggregateResult.get('EUR_TR_RelatedAccount__c'), aggregateResult);
        }

        for (EUR_TR_Account__c account : AccountResult) {
            AggregateResult aggregateResult = totalSalesMap.get(account.Id);

            if (aggregateResult != null) {
                account.EUR_TR_MATCY__c = (Decimal) aggregateResult.get('EUR_TR_MAT1__c');
                account.EUR_TR_MATLY__c = (Decimal) aggregateResult.get('EUR_TR_MAT2__c');
            }
        }

        System.debug(AccountQuery);

        serviceResponse.Code = 1;
        serviceResponse.Message = 'Success';
        serviceResponse.ExtensionData = AccountResult;

        return serviceResponse;
    }

    public class AccountSearchRequest {
        public String searchTerm { get; set; }
        public List<String> types { get; set; }
        public List<String> classes { get; set; }
        public List<String> statuses { get; set; }
        public List<String> distributors { get; set; }
        public List<String> channels { get; set; }
        public List<String> cities { get; set; }
        public List<String> districts { get; set; }
        public List<String> ranges { get; set; }
        public List<String> attackbrands { get; set; }
        public Decimal latitude { get; set; }
        public Decimal longitude { get; set; }
        public Decimal radiusKm { get; set; }
        public List<AccountSearchRequestProductFilter> productFilters { get; set; }
        public Boolean outOfScope { get; set; }
        public Boolean census { get; set; }
        public Decimal bluePassScoreMin { get; set; }
        public Decimal bluePassScoreMax { get; set; }
        public Decimal whiskeyScoreMin { get; set; }
        public Decimal whiskeyScoreMax { get; set; }
        public Decimal vodkaScoreMin { get; set; }
        public Decimal vodkaScoreMax { get; set; }
        public Decimal placementScoreMin { get; set; }
        public Decimal placementScoreMax { get; set; }
        public Decimal availabilityScoreMin { get; set; }
        public Decimal availabilityScoreMax { get; set; }
        public Decimal whiteCriteriaScoreMin { get; set; }
        public Decimal whiteCriteriaScoreMax { get; set; }
        public List<String> rangeCompliance { get; set; }
        public List<String> crossCompliance { get; set; }
        public List<String> visitFrequency { get; set; }
        public String favouriteParams { get; set; }

        public AccountSearchOrderBy orderBy { get; set; }
        public AccountSearchOrderDirection orderDirection { get; set; }
        public Integer recordCount { get; set; }
        public Boolean exportData { get; set; }
        public AccountSearchExportContext exportContext { get; set; }
        public String nextPageExportContext { get; set; }
    }

    public class AccountSearchExportContext {
        public Id lastIdInPreviousPage { get; set; }
        public Boolean hasNextPage { get; set; }
    }
    public enum AccountSearchPeriod {
        MAT, MTD, QTD, YTD
    }

    public enum AccountSearchOrderBy {
        location, salesVolume, growth, bluePassScore, Name
    }

    public enum AccountSearchOrderDirection {
        ascending, descending
    }
    public class AccountSearchRequestProductFilter {
        public AccountSearchPeriod period { get; set; }
        public List<String> brands { get; set; }
        public List<String> skus { get; set; }
        public Decimal brandShareMin { get; set; }
        public Decimal brandShareMax { get; set; }
        public List<String> clusters { get; set; }
        public List<String> caseClusters { get; set; }
        public Decimal volumeMin { get; set; }
        public Decimal volumeMax { get; set; }
        public List<String> existNonExists { get; set; }
        public String matLast6 { get; set; }
        public String invoiceStatus { get; set; }
        public List<String> incentiveBrands { get; set; }
        public String isIncentiveAccount { get; set; }
    }

    public class AccountSearchResponse {
        public List<EUR_TR_Account__c> accounts { get; set; }
        public String nextPageExportContext { get; set; }
    }

    public class AccountOrderRequest {
        public AccountSearchOrderBy orderBy { get; set; }
        public AccountSearchOrderDirection orderDirection { get; set; }
        public List<String> accounts { get; set; }
        public Decimal latitude { get; set; }
        public Decimal longitude { get; set; }
    }
}