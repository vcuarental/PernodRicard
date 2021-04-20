/**
 * Created by osman on 4.02.2021.
 */

public with sharing class EUR_TR_BulkProfitabilityDeleteController {

    @AuraEnabled
    public static void deleteRecords(Integer batchSize) {
        try {
            if (batchSize > 10000) {
                throw new EUR_TR_BulkProfitabilityDeleteControllerException('Lütfen sistem yönecisiniz ile iletişime geçiniz.');
            }
            checkRecordIsExistToDeleteOperation();
            Database.executeBatch(new EUR_TR_DeleteProfitabilityBatch(), batchSize);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<AsyncApexJob> checkDeleteStatus() {
        List<AsyncApexJob> deleteApexJobsNotCompleted = [
                SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,CreatedDate,ParentJobId
                FROM AsyncApexJob
                WHERE ApexClass.Name = 'EUR_TR_DeleteProfitabilityBatch'
                AND Status != 'Completed'
                AND ParentJobId = NULL
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        return deleteApexJobsNotCompleted;
    }

    private static void checkRecordIsExistToDeleteOperation() {

        List<EUR_TR_AccountProfitability__c> listOfAccountProfitability = [
                SELECT Id
                FROM EUR_TR_AccountProfitability__c
                WHERE RecordType.DeveloperName = 'EUR_TR_AccountProfitability'
                LIMIT 1
        ];
        if (listOfAccountProfitability.isEmpty()) {
            throw new EUR_TR_BulkProfitabilityDeleteControllerException('Silinecek kayıt bulunamadı');
        }

        List<AsyncApexJob> deleteApexJobsNotCompleted = [
                SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,CreatedDate,ParentJobId
                FROM AsyncApexJob
                WHERE ApexClass.Name = 'EUR_TR_DeleteProfitabilityBatch'
                AND Status != 'Completed'
                AND ParentJobId = NULL
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        if (!deleteApexJobsNotCompleted.isEmpty()) {
            throw new EUR_TR_BulkProfitabilityDeleteControllerException('Toplu silme işlemi devam etmektedir, lütfen daha sonra tekrar deneyiniz');
        }


    }

    class EUR_TR_BulkProfitabilityDeleteControllerException extends Exception {
    }

}