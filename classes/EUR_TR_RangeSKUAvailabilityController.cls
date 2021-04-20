/**
 * Created by osman on 12.01.2021.
 */

public with sharing class EUR_TR_RangeSKUAvailabilityController {

    public static EUR_TR_MiddlewareController.PostServiceResponse getRangeSKUAvailabilityPercentagesFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_RangeSKUAvailabilityControllerException('Geçersiz istek , model boş gönderilemez!');
            }

            EUR_TR_Account__c relatedAccount = (EUR_TR_Account__c) JSON.deserialize(requestBody, EUR_TR_Account__c.class);
            serviceResponse.ExtensionData = getRangeSKUAvailabilityPercentages(relatedAccount);

        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }


    public static RangeSKUAvailabilityPercentage getRangeSKUAvailabilityPercentages(EUR_TR_Account__c relatedAccount) {

        if (relatedAccount == null) {
            throw new EUR_TR_RangeSKUAvailabilityControllerException('Account parametresi boş gönderilemez.');
        }

        List<EUR_TR_Account__c> foundAccounts = [
                SELECT Id
                FROM EUR_TR_Account__c
                WHERE Id = :relatedAccount.Id
                LIMIT 1
        ];

        if (foundAccounts.isEmpty()) {
            throw new EUR_TR_RangeSKUAvailabilityControllerException('Nokta bulunamadı');
        }

        Decimal totalRNCount = getTotalCountByAvailabilityField(relatedAccount, 'EUR_TR_RN__c');
        Decimal totalLast3mAvailabilityCount = getTotalCountByAvailabilityField(relatedAccount, 'EUR_TR_Last3mAvailability__c');
        Decimal totalLast6mAvailabilityCount = getTotalCountByAvailabilityField(relatedAccount, 'EUR_TR_Last6mAvailability__c');
        Decimal totalLast9mAvailabilityCount = getTotalCountByAvailabilityField(relatedAccount, 'EUR_TR_Last9mAvailability__c');
        Decimal totalLast12mAvailabilityCount = getTotalCountByAvailabilityField(relatedAccount, 'EUR_TR_Last12mAvailability__c');
        Decimal totalMTDAvailabilityCount = getTotalCountByAvailabilityField(relatedAccount, 'EUR_TR_MTDAvailability__c');
        Decimal totalYTDAvailabilityCount = getTotalCountByAvailabilityField(relatedAccount, 'EUR_TR_YTDAvailability__c');
        Decimal totalQTDAvailabilityCount = getTotalCountByAvailabilityField(relatedAccount, 'EUR_TR_QTDAvailability__c');

        Decimal lastThreeMonthsPercentage = 0;
        Decimal lastSixMonthsPercentage = 0;
        Decimal lastNineMonthsPercentage = 0;
        Decimal lastTwelveMonthsPercentage = 0;
        Decimal MTDPercentage = 0;
        Decimal YTDPercentage = 0;
        Decimal QTDPercentage = 0;

        if (totalRNCount != 0) {
            lastThreeMonthsPercentage = ((totalLast3mAvailabilityCount / totalRNCount) * 100).round(System.RoundingMode.HALF_EVEN);
            lastSixMonthsPercentage = ((totalLast6mAvailabilityCount / totalRNCount) * 100).round(System.RoundingMode.HALF_EVEN);
            lastNineMonthsPercentage = ((totalLast9mAvailabilityCount / totalRNCount) * 100).round(System.RoundingMode.HALF_EVEN);
            lastTwelveMonthsPercentage = ((totalLast12mAvailabilityCount / totalRNCount) * 100).round(System.RoundingMode.HALF_EVEN);
            MTDPercentage = ((totalMTDAvailabilityCount / totalRNCount) * 100).round(System.RoundingMode.HALF_EVEN);
            YTDPercentage = ((totalYTDAvailabilityCount / totalRNCount) * 100).round(System.RoundingMode.HALF_EVEN);
            QTDPercentage = ((totalQTDAvailabilityCount / totalRNCount) * 100).round(System.RoundingMode.HALF_EVEN);
        }


        RangeSKUAvailabilityPercentage rangeSKUAvailabilityPercentage = new RangeSKUAvailabilityPercentage();
        rangeSKUAvailabilityPercentage.lastThreeMonthsPercentage = lastThreeMonthsPercentage;
        rangeSKUAvailabilityPercentage.lastSixMonthsPercentage = lastSixMonthsPercentage;
        rangeSKUAvailabilityPercentage.lastNineMonthsPercentage = lastNineMonthsPercentage;
        rangeSKUAvailabilityPercentage.lastTwelveMonthsPercentage = lastTwelveMonthsPercentage;
        rangeSKUAvailabilityPercentage.MTDPercentage = MTDPercentage;
        rangeSKUAvailabilityPercentage.YTDPercentage = YTDPercentage;
        rangeSKUAvailabilityPercentage.QTDPercentage = QTDPercentage;

        System.debug(JSON.serializePretty(rangeSKUAvailabilityPercentage));

        return rangeSKUAvailabilityPercentage;


    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getSKUAvailabilityFiltersFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        try {
            serviceResponse.ExtensionData = getSKUAvailabilityFilters();
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }
        return serviceResponse;

    }

    public static List<PicklistEntry> getSKUAvailabilityFilters() {

        List<PicklistEntry> entries = new List<PicklistEntry>();
        entries.add(createPicklistEntry('3 Ay', 'EUR_TR_Last3mAvailability__c'));
        entries.add(createPicklistEntry('6 Ay', 'EUR_TR_Last6mAvailability__c'));
        entries.add(createPicklistEntry('9 Ay', 'EUR_TR_Last9mAvailability__c'));
        entries.add(createPicklistEntry('12 Ay', 'EUR_TR_Last12mAvailability__c'));
        entries.add(createPicklistEntry('QTD', 'EUR_TR_QTDAvailability__c'));
        entries.add(createPicklistEntry('YTD', 'EUR_TR_YTDAvailability__c'));
        entries.add(createPicklistEntry('MTD', 'EUR_TR_MTDAvailability__c'));
        return entries;

    }

    private static PicklistEntry createPicklistEntry(String label, String value) {
        PicklistEntry entry = new PicklistEntry();
        entry.label = label;
        entry.value = value;
        return entry;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getListOfSKUByAvailabilityFilterFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_RangeSKUAvailabilityControllerException('Geçersiz istek , model boş gönderilemez!');
            }

            EUR_TR_Account__c relatedAccount = (EUR_TR_Account__c) JSON.deserialize(requestBody, EUR_TR_Account__c.class);

            if (String.isBlank(relatedAccount.Id)) {
                throw new EUR_TR_RangeSKUAvailabilityControllerException('Nokta bilgisi boş gönderilemez.');
            }

            serviceResponse.ExtensionData = getListOfSKUByAvailabilityFilter(relatedAccount);

        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static List<SKUWrapper> getListOfSKUByAvailabilityFilter(EUR_TR_Account__c account) {

        Id accountId = account.Id;
        String groupedByBrandQualitySizeRangeSKUAvailabilityQuery = 'SELECT EUR_TR_BrandQualitySize__c FROM EUR_TR_RangeSKUAvailability__c ' +
                'WHERE EUR_TR_RelatedAccount__c = :accountId AND EUR_TR_BrandQualitySize__c != NULL ' +
                'AND RecordType.DeveloperName = \'EUR_TR_RangeSKUAvailability\'  GROUP BY EUR_TR_BrandQualitySize__c ';
        System.debug(groupedByBrandQualitySizeRangeSKUAvailabilityQuery);

        Set<String> listOfBrandQualitySize = new Set<String>();
        for (AggregateResult aggregateResult : Database.query(groupedByBrandQualitySizeRangeSKUAvailabilityQuery)) {
            String brandQualitySize = (String) aggregateResult.get('EUR_TR_BrandQualitySize__c');
            if (brandQualitySize != null) {
                listOfBrandQualitySize.add(brandQualitySize);
            }
        }

        Map<String, EUR_TR_SKU__c> brandQualityToSKUMap = new Map<String, EUR_TR_SKU__c>();
        if (!listOfBrandQualitySize.isEmpty()) {
            String skuQuery = 'SELECT EUR_TR_BrandQualitySize__c, EUR_TR_ImageUrl__c FROM EUR_TR_SKU__c WHERE EUR_TR_BrandQualitySize__c IN :listOfBrandQualitySize ';
            System.debug(skuQuery);
            for (EUR_TR_SKU__c sku : Database.query(skuQuery)) {
                if (!brandQualityToSKUMap.containsKey(sku.EUR_TR_BrandQualitySize__c)) {
                    brandQualityToSKUMap.put(sku.EUR_TR_BrandQualitySize__c, sku);
                }
            }
        }


        String allRangeSKUAvailabilityQuery = 'SELECT ' +
                'Id,EUR_TR_BrandQualitySize__c, EUR_TR_YTDAvailability__c, EUR_TR_MTDAvailability__c,' +
                'EUR_TR_QTDAvailability__c,' +
                'EUR_TR_Last3mAvailability__c,' +
                'EUR_TR_Last6mAvailability__c,' +
                'EUR_TR_Last9mAvailability__c,' +
                'EUR_TR_Last12mAvailability__c,' +
                'EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c ' +
                'FROM EUR_TR_RangeSKUAvailability__c ' +
                'WHERE EUR_TR_RelatedAccount__c = :accountId AND EUR_TR_BrandQualitySize__c != NULL ' +
                'AND RecordType.DeveloperName = \'EUR_TR_RangeSKUAvailability\' ';

        System.debug(allRangeSKUAvailabilityQuery);

        List<SKUWrapper> skuWrappers = new List<SKUWrapper>();
        for (EUR_TR_RangeSKUAvailability__c rangeSKUAvailability : Database.query(allRangeSKUAvailabilityQuery)) {
            SKUWrapper skuWrapper = new SKUWrapper();
            EUR_TR_SKU__c sku = brandQualityToSKUMap.get(rangeSKUAvailability.EUR_TR_BrandQualitySize__c);
            if (sku != null) {
                skuWrapper.sku = sku;
                skuWrapper.relatedSKUAvailability = rangeSKUAvailability;
                skuWrappers.add(skuWrapper);
            }
        }

        return skuWrappers;

    }

    private static Decimal getTotalCountByAvailabilityField(EUR_TR_Account__c account, String availabilityField) {

        Id accountId = account.Id;

        String query = '{0} {1} {2} {3}';
        String querySelect = 'SELECT EUR_TR_RelatedAccount__c,count(Id) ';
        String queryFrom = 'FROM EUR_TR_RangeSKUAvailability__c';
        String queryWhere = 'WHERE RecordType.DeveloperName = \'EUR_TR_RangeSKUAvailability\' AND EUR_TR_RelatedAccount__c=:accountId ';
        queryWhere += String.format('AND {0}=TRUE ', new List<String>{
                availabilityField
        });
        String queryGroup = 'GROUP BY EUR_TR_RelatedAccount__c ';


        query = String.format(query, new List<String>{
                querySelect,
                queryFrom,
                queryWhere,
                queryGroup
        });

        System.debug(query);

        // If the record size is more than 50000 , below code syntax will handle more than 50000 records without throw any error.
        Decimal totalCount = 0;
        for (AggregateResult result : Database.query(query)) {
            totalCount = (Decimal) result.get('expr0');
            if (totalCount == null) {
                totalCount = 0;
            }
            break;
        }

        return totalCount;

    }

    class EUR_TR_RangeSKUAvailabilityControllerException extends Exception {
    }

    public class RangeSKUAvailabilityPercentage {

        @AuraEnabled
        public Decimal lastThreeMonthsPercentage { get; set; }
        @AuraEnabled
        public Decimal lastSixMonthsPercentage { get; set; }
        @AuraEnabled
        public Decimal lastNineMonthsPercentage { get; set; }
        @AuraEnabled
        public Decimal lastTwelveMonthsPercentage { get; set; }
        @AuraEnabled
        public Decimal QTDPercentage { get; set; }
        @AuraEnabled
        public Decimal YTDPercentage { get; set; }
        @AuraEnabled
        public Decimal MTDPercentage { get; set; }

    }

    class PicklistEntry {
        public String label { get; set; }
        public String value { get; set; }
    }

    class SKUWrapper {
        public EUR_TR_RangeSKUAvailability__c relatedSKUAvailability { get; set; }
        public EUR_TR_SKU__c sku { get; set; }
    }

}