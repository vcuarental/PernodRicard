/**
 * Created by osman on 29.12.2020.
 */

public with sharing class EUR_TR_BulkCrossComplianceController {

    final static SObjectField upsertExternalId = Schema.SObjectType.EUR_TR_CrossCompliance__c.fields.getMap().get('EUR_TR_ExternalId__c');

    @AuraEnabled
    public static UpsertCrossComplianceResult upsertCrossComplianceItems(List<CrossCompliance> crossComplianceRecords) {

        List<EUR_TR_CrossCompliance__c> itemsToUpsert = new List<EUR_TR_CrossCompliance__c>();


        Map<Integer, CrossComplianceRow> rowNumberToCrossComplianceMap = new Map<Integer, CrossComplianceRow>();
        UpsertCrossComplianceResult response = new UpsertCrossComplianceResult();

        for (Integer i = 0; i < crossComplianceRecords.size(); i++) {


            EUR_TR_CrossCompliance__c itemToUpsert = new EUR_TR_CrossCompliance__c();
            itemToUpsert.EUR_TR_RelatedAccount__r = new EUR_TR_Account__c();
            itemToUpsert.EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c = crossComplianceRecords[i].AccountCode;
            itemToUpsert.EUR_TR_AbsCross__c = crossComplianceRecords[i].Abs;
            itemToUpsert.EUR_TR_BFWJWRL__c = crossComplianceRecords[i].BFWJWRL;
            itemToUpsert.EUR_TR_CR12JD__c = crossComplianceRecords[i].CR12JD;
            itemToUpsert.EUR_TR_PassBells__c = crossComplianceRecords[i].PassBells;
            itemToUpsert.EUR_TR_WyboCross__c = crossComplianceRecords[i].Wybo;
            itemToUpsert.EUR_TR_ExternalId__c = crossComplianceRecords[i].AccountCode;

            CrossComplianceRow crossComplianceRow = new CrossComplianceRow();
            crossComplianceRow.crossCompliance = crossComplianceRecords.get(i);
            rowNumberToCrossComplianceMap.put(i, crossComplianceRow);

            if (String.isBlank(crossComplianceRecords[i].AccountCode) || crossComplianceRecords[i].AccountCode == null) {
                crossComplianceRow.isExistRequiredField = false;
                crossComplianceRow.errorMessage = 'Müşteri Kodu boş bırakılamaz';
                response.errorSize++;
            } else {
                itemsToUpsert.add(itemToUpsert);
            }


        }

        List<Database.UpsertResult> upsertResults = Database.upsert(itemsToUpsert, upsertExternalId, false);

        for (Integer upsertResultIndex = 0; upsertResultIndex < upsertResults.size(); upsertResultIndex++) {

            if (upsertResults[upsertResultIndex].isSuccess()) {
                response.successSize++;
            } else {
                response.errorSize++;
                String errorMessage = '';
                for (Database.Error error : upsertResults[upsertResultIndex].errors) {
                    errorMessage = error.message;
                }

                CrossComplianceRow crossComplianceRow = rowNumberToCrossComplianceMap.get(upsertResultIndex);
                crossComplianceRow.errorMessage = errorMessage;
                rowNumberToCrossComplianceMap.put(upsertResultIndex, crossComplianceRow);

            }
        }

        List<CrossComplianceRow> failedCrossComplianceRecords = new List<CrossComplianceRow>();
        for (Integer i = 0; i < rowNumberToCrossComplianceMap.size(); i++) {
            CrossComplianceRow row = rowNumberToCrossComplianceMap.get(i);
            if (String.isNotBlank(row.errorMessage)) {
                failedCrossComplianceRecords.add(row);
            }
        }

        if (!failedCrossComplianceRecords.isEmpty()) {
            response.CSVFileToFailedRecords = generateCSVFileToFailedRecords(failedCrossComplianceRecords);
        }

        return response;

    }

    private static String generateCSVFileToFailedRecords(List<CrossComplianceRow> crossComplianceRows) {

        String failedCrossComplianceExcel = '';
        String failedCrossComplianceRowData = '';


        for (CrossComplianceRow crossComplianceRow : crossComplianceRows) {
            failedCrossComplianceRowData =
                    String.format('{0},{1},{2},{3},{4},{5},{6},{7}\n',
                            new List<String>{
                                    crossComplianceRow.crossCompliance.AccountCode,
                                    crossComplianceRow.crossCompliance.AccountName,
                                    crossComplianceRow.crossCompliance.CR12JD == true ? '1' : '',
                                    crossComplianceRow.crossCompliance.BFWJWRL == true ? '1' : '',
                                    crossComplianceRow.crossCompliance.PassBells == true ? '1' : '',
                                    crossComplianceRow.crossCompliance.Wybo == true ? '1' : '',
                                    crossComplianceRow.crossCompliance.Abs == true ? '1' : '',
                                    crossComplianceRow.errorMessage
                            });
            failedCrossComplianceExcel = failedCrossComplianceExcel + failedCrossComplianceRowData;
        }

        failedCrossComplianceExcel = failedCrossComplianceExcel;

        return failedCrossComplianceExcel;


    }

    public class CrossComplianceRow {

        public CrossComplianceRow() {
            this.isExistRequiredField = true;
        }

        public CrossCompliance crossCompliance { get; set; }
        public String errorMessage { get; set; }
        public Boolean isExistRequiredField { get; set; }
    }

    public class UpsertCrossComplianceResult {

        public UpsertCrossComplianceResult() {
            this.errorSize = 0;
            this.successSize = 0;
        }

        @AuraEnabled
        public Integer errorSize { get; set; }
        @AuraEnabled
        public Integer successSize { get; set; }
        @AuraEnabled
        public String CSVFileToFailedRecords { get; set; }

    }

    public class CrossCompliance {

        @AuraEnabled
        public String AccountCode { get; set; }
        @AuraEnabled
        public String AccountName { get; set; }
        @AuraEnabled
        public Boolean CR12JD { get; set; }
        @AuraEnabled
        public Boolean BFWJWRL { get; set; }
        @AuraEnabled
        public Boolean PassBells { get; set; }
        @AuraEnabled
        public Boolean Wybo { get; set; }
        @AuraEnabled
        public Boolean Abs { get; set; }

    }
}