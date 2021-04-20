/**
 * Created by ali.kucuk@teknait.com on 12/26/2020.
 */

public with sharing class EUR_TR_BulkProfitabilityLoaderController {

    final static SObjectField upsertExternalId = Schema.SObjectType.EUR_TR_AccountProfitability__c.fields.getMap().get('EUR_TR_ExternalId__c');

    @AuraEnabled
    public static UpsertProfitabilityResult upsertProfitabilityItems(List<ProfitabilityItem> items) {

        List<EUR_TR_AccountProfitability__c> itemsToUpsert = new List<EUR_TR_AccountProfitability__c>();
        Map<Integer, ProfitabilityRow> rowNumberToProfitabilityMap = new Map<Integer, ProfitabilityRow>();

        for (Integer i = 0; i < items.size(); i++) {

            EUR_TR_AccountProfitability__c itemToUpsert = new EUR_TR_AccountProfitability__c();
            itemToUpsert.EUR_TR_RelatedAccount__r = new EUR_TR_Account__c();
            itemToUpsert.EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c = items[i].AccountCode;
            itemToUpsert.EUR_TR_Year__c = items[i].Year;
            itemToUpsert.EUR_TR_Quarter__c = items[i].Quarter;
            itemToUpsert.EUR_TR_ProfitAmount__c = items[i].ProfitAmount;
            itemToUpsert.EUR_TR_TotalAmount__c = items[i].TotalAmount;
            itemToUpsert.EUR_TR_ExternalId__c = String.format('{0}_{1}_{2}', new List<String>{
                    items[i].AccountCode,
                    items[i].Year,
                    items[i].Quarter
            });
            itemsToUpsert.add(itemToUpsert);

            ProfitabilityRow profitabilityRow = new ProfitabilityRow();
            profitabilityRow.profitabilityItem = items[i];
            rowNumberToProfitabilityMap.put(i, profitabilityRow);

        }

        List<Database.UpsertResult> upsertResults = Database.upsert(itemsToUpsert, upsertExternalId, false);

        UpsertProfitabilityResult response = new UpsertProfitabilityResult();
        List<ProfitabilityRow> failedProfitabilityRecords = new List<ProfitabilityRow>();
        for (Integer upsertResultIndex = 0; upsertResultIndex < upsertResults.size(); upsertResultIndex++) {

            if (upsertResults[upsertResultIndex].isSuccess()) {
                response.successSize++;
            } else {
                response.errorSize++;
                String errorMessage = '';
                for (Database.Error error : upsertResults[upsertResultIndex].errors) {
                    errorMessage = error.message;
                }

                ProfitabilityRow profitabilityRow = rowNumberToProfitabilityMap.get(upsertResultIndex);
                profitabilityRow.errorMessage = errorMessage;
                failedProfitabilityRecords.add(profitabilityRow);

            }
        }


        if (!failedProfitabilityRecords.isEmpty()) {
            response.CSVFileToFailedRecords = generateCSVFileToFailedRecords(failedProfitabilityRecords);
        }

        return response;

    }

    private static String generateCSVFileToFailedRecords(List<ProfitabilityRow> profitabilityRows) {

        String failedProfitabilityExcel = '';
        String failedProfitabilityRowData = '';


        for (ProfitabilityRow profitabilityRow : profitabilityRows) {
            failedProfitabilityRowData =
                    String.format('{0},{1},{2},{3},{4}\n',
                            new List<String>{
                                    profitabilityRow.profitabilityItem.AccountCode,
                                    'FY' + profitabilityRow.profitabilityItem.Year + profitabilityRow.profitabilityItem.Quarter,
                                    String.valueOf(profitabilityRow.profitabilityItem.ProfitAmount),
                                    String.valueOf(profitabilityRow.profitabilityItem.TotalAmount),
                                    profitabilityRow.errorMessage
                            });
            failedProfitabilityExcel = failedProfitabilityExcel + failedProfitabilityRowData;
        }

        return failedProfitabilityExcel;


    }

    public class UpsertProfitabilityResult {
        @AuraEnabled public Integer errorSize { get; set; }
        @AuraEnabled public Integer successSize { get; set; }
        public UpsertProfitabilityResult() {
            this.errorSize = 0;
            this.successSize = 0;
        }
        @AuraEnabled
        public String CSVFileToFailedRecords { get; set; }
    }

    public class ProfitabilityItem {
        @AuraEnabled public String AccountCode { get; set; }
        @AuraEnabled public String Year { get; set; }
        @AuraEnabled public String Quarter { get; set; }
        @AuraEnabled public Decimal ProfitAmount { get; set; }
        @AuraEnabled public Decimal TotalAmount { get; set; }
    }

    public class ProfitabilityRow {
        public ProfitabilityItem profitabilityItem { get; set; }
        public String errorMessage { get; set; }
    }


}