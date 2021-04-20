/**
 * Created by osman on 15.01.2021.
 */

public with sharing class EUR_TR_BulkIncentiveLoaderController {

    @AuraEnabled
    public static InsertIncentiveResult insertIncentiveRecords(List<Incentive> incentiveRecords) {

        List<EUR_TR_Incentive__c> itemsToInsert = new List<EUR_TR_Incentive__c>();


        Map<Integer, IncentiveRow> rowNumberToIncentiveMap = new Map<Integer, IncentiveRow>();
        InsertIncentiveResult response = new InsertIncentiveResult();

        for (Integer i = 0; i < incentiveRecords.size(); i++) {

            EUR_TR_Incentive__c itemToInsert = new EUR_TR_Incentive__c();
            itemToInsert.EUR_TR_RelatedAccount__r = new EUR_TR_Account__c();
            itemToInsert.EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c = incentiveRecords[i].accountCode;
            itemToInsert.EUR_TR_Brand__c = incentiveRecords[i].brand;
            itemToInsert.EUR_TR_Description__c = incentiveRecords[i].description;


            String startDateErrorMessage = '';
            try {
                itemToInsert.EUR_TR_StartDate__c = convertStringToDate(incentiveRecords[i].startDate);
            } catch (Exception ex) {
                startDateErrorMessage = 'Başlangıç tarihi boş ve belirnen formatın dışında olamaz.Örnek format : 01.11.2020';
            }

            String endDateErrorMessage = '';
            try {
                itemToInsert.EUR_TR_EndDate__c = convertStringToDate(incentiveRecords[i].endDate);
            } catch (Exception ex) {
                endDateErrorMessage = 'Bitiş tarihi boş ve belirnen formatın dışında olamaz';
            }

            IncentiveRow incentiveRow = new IncentiveRow();
            incentiveRow.incentive = incentiveRecords.get(i);
            rowNumberToIncentiveMap.put(i, incentiveRow);

            if (String.isBlank(incentiveRecords[i].accountCode) || incentiveRecords[i].accountCode == null) {
                incentiveRow.isExistRequiredField = false;
                incentiveRow.errorMessage = 'Müşteri Kodu boş bırakılamaz';
                response.errorSize++;
            } else if (String.isNotBlank(startDateErrorMessage)) {
                incentiveRow.isExistRequiredField = false;
                incentiveRow.errorMessage = startDateErrorMessage;
                response.errorSize++;
            } else if (String.isNotBlank(endDateErrorMessage)) {
                incentiveRow.isExistRequiredField = false;
                incentiveRow.errorMessage = endDateErrorMessage;
                response.errorSize++;
            } else if (String.isBlank(incentiveRecords[i].brand)) {
                incentiveRow.isExistRequiredField = false;
                incentiveRow.errorMessage = 'Marka boş bırakılamaz';
                response.errorSize++;
            } else if (String.isBlank(incentiveRecords[i].description)) {
                incentiveRow.isExistRequiredField = false;
                incentiveRow.errorMessage = 'Incentive açıklaması boş bırakılamaz.';
                response.errorSize++;
            } else {
                itemsToInsert.add(itemToInsert);
            }


        }

        List<Database.SaveResult> insertResults = Database.insert(itemsToInsert, false);

        for (Integer insertResultIndex = 0; insertResultIndex < insertResults.size(); insertResultIndex++) {

            if (insertResults[insertResultIndex].isSuccess()) {
                response.successSize++;
            } else {
                response.errorSize++;
                String errorMessage = '';
                for (Database.Error error : insertResults[insertResultIndex].errors) {
                    errorMessage = error.message;
                }

                IncentiveRow incentiveRow = rowNumberToIncentiveMap.get(insertResultIndex);
                incentiveRow.errorMessage = errorMessage;
                rowNumberToIncentiveMap.put(insertResultIndex, incentiveRow);

            }
        }

        List<IncentiveRow> failedIncentiveRecords = new List<IncentiveRow>();
        for (Integer i = 0; i < rowNumberToIncentiveMap.size(); i++) {
            IncentiveRow row = rowNumberToIncentiveMap.get(i);
            if (String.isNotBlank(row.errorMessage)) {
                failedIncentiveRecords.add(row);
            }
        }

        if (!failedIncentiveRecords.isEmpty()) {
            response.CSVFileToFailedRecords = generateCSVFileToFailedRecords(failedIncentiveRecords);
        }

        return response;

    }

    private static String generateCSVFileToFailedRecords(List<IncentiveRow> incentiveRows) {

        String failedIncentiveExcel = '';
        String failedIncentiveRowData = '';


        for (IncentiveRow incentiveRow : incentiveRows) {
            failedIncentiveRowData =
                    String.format('{0},{1},{2},{3},{4},{5}\n',
                            new List<String>{
                                    incentiveRow.incentive.accountCode,
                                    incentiveRow.incentive.brand,
                                    incentiveRow.incentive.description,
                                    incentiveRow.incentive.startDate,
                                    incentiveRow.incentive.endDate,
                                    incentiveRow.errorMessage
                            });
            failedIncentiveExcel = failedIncentiveExcel + failedIncentiveRowData;
        }

        return failedIncentiveExcel;


    }

    private static Date convertStringToDate(String strDate) {
        String[] strDateArr = strDate.split('\\.');
        Date dt = Date.newInstance(Integer.valueOf(strDateArr[2]), Integer.valueOf(strDateArr[1]), Integer.valueOf(strDateArr[0]));
        return dt;
    }

    public class IncentiveRow {

        public IncentiveRow() {
            this.isExistRequiredField = true;
        }

        public Incentive incentive { get; set; }
        public String errorMessage { get; set; }
        public Boolean isExistRequiredField { get; set; }
    }

    public class InsertIncentiveResult {

        public InsertIncentiveResult() {
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

    public class Incentive {
        @AuraEnabled
        public String accountCode { get; set; }
        @AuraEnabled
        public String brand { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public String startDate { get; set; }
        @AuraEnabled
        public String endDate { get; set; }
    }

}