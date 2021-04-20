global virtual class EUR_CRM_BatchVirtualClass {

    private List<String> errors = new List<String>();

    global virtual void finish(Database.BatchableContext BC) {
        this.sendEmailReport(BC);
    }

    protected void insertRecords(List<sObject> recs) {
        List<Database.SaveResult> saveResults = Database.insert(recs, false);

        for (Database.SaveResult saveResult : saveResults) {
            if ( ! saveResult.isSuccess()) {
                System.debug('\n\n Error on inserting record! \n');

                for(Database.Error error : saveResult.getErrors()) {
                    System.debug('\n\n The following error has occurred: ' + error.getStatusCode() + ' : ' + error.getMessage() + '\n');
                    System.debug('\n\n Object\'s fields that affected this error: ' + error.getFields() + '\n');

                    this.errors.add('Error Status: ' + error.getStatusCode() + ' ;\n' + 'Message: ' + error.getMessage() + ' ;\n' + 'Problem Fields: ' + error.getFields() + '.\n');
                }
            }
        }
        System.debug('\n\n this.errors => ' + this.errors + '\n');
    }

    protected void upsertRecords(List<sObject> recs) {
        List<Database.UpsertResult> saveResults = Database.upsert(recs, false);

        for (Database.UpsertResult saveResult : saveResults) {
            if ( ! saveResult.isSuccess()) {
                System.debug('\n\n Error on upserting record! \n');

                for(Database.Error error : saveResult.getErrors()) {
                    System.debug('\n\n The following error has occurred: ' + error.getStatusCode() + ' : ' + error.getMessage() + '\n');
                    System.debug('\n\n Object\'s fields that affected this error: ' + error.getFields() + '\n');

                    this.errors.add('Error Status: ' + error.getStatusCode() + ' ;\n' + 'Message: ' + error.getMessage() + ' ;\n' + 'Problem Fields: ' + error.getFields() + '.\n');
                }
            }
        }
        System.debug('\n\n this.errors => ' + this.errors + '\n');
    }

    protected void deleteRecords(List<sObject> recs) {
        List<Database.DeleteResult> deleteResults = Database.delete(recs, false);

        for (Database.DeleteResult deleteResult : deleteResults) {
            if ( ! deleteResult.isSuccess()) {
                System.debug('\n\n Error on deleting record! \n');

                for(Database.Error error : deleteResult.getErrors()) {
                    System.debug('\n\n The following error has occurred: ' + error.getStatusCode() + ' : ' + error.getMessage() + '\n');
                    System.debug('\n\n Object\'s fields that affected this error: ' + error.getFields() + '\n');

                    this.errors.add('Error Status: ' + error.getStatusCode() + ' ;\n' + 'Message: ' + error.getMessage() + ' ;\n' + 'Problem Fields: ' + error.getFields() + '.\n');
                }
            }
        }
        System.debug('\n\n this.errors => ' + this.errors + '\n');
    }

    protected void sendEmailReport(Database.BatchableContext BC) {
        AsyncApexJob aaj = this.selectBatchInfo(BC);
        String messageText = this.getMessageBody(aaj);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new List<String> { UserInfo.getUserEmail() });
        message.setSubject(aaj.ApexClass.Name + ' status: ' + aaj.Status);
        message.setPlainTextBody(messageText);

        System.debug('\n\n message => ' + message + '\n');
        if ( ! Test.isRunningTest()) {
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            } catch (Exception e) {
                System.debug('\n\n e.getMessage() => ' + e.getMessage() + '\n');
            }
        }
    }


    /* ========================================================= */
    /*     Commentary
    /* ========================================================= */
    private String getMessageBody(AsyncApexJob aaj) {
        String reportMessage = this.getReportMessage();
        String messageText = '\nThe batch Apex job processed ' + aaj.TotalJobItems + ' ' +
            'batches with ' + aaj.NumberOfErrors + ' failures. \n' +
            'Report: ' + reportMessage
        ;
        return messageText;
    }

    private String getReportMessage() {
        String reportMessage = '';
        reportMessage += 'Count of errors: ' + this.errors.size() + '\n';
        for (String err : this.errors) {
            reportMessage += err + '\n';
        }
        return reportMessage;
    }

    protected Date getStartDate(Database.BatchableContext BC, Date endDate) {
        Integer daysSinceLastRun = getDaysSinceLastRun(BC);
        if (daysSinceLastRun == null || daysSinceLastRun == 0) {
            daysSinceLastRun = 1;
        }
        return endDate.addDays(- Math.abs(daysSinceLastRun));
    }

    protected Integer getDaysSinceLastRun(Database.BatchableContext BC) {
        List<AsyncApexJob> asyncApexJobs = selectAsyncApexJobs(BC);
        if (asyncApexJobs.isEmpty()) { return null; }

        List<AsyncApexJob> jobs = this.selectCompletedBatchInfo(asyncApexJobs[0].ApexClassId);

        return jobs.isEmpty() ? null : jobs[0].CompletedDate.date().daysBetween(Date.today());
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private AsyncApexJob selectBatchInfo(Database.BatchableContext BC) {
        return [
            SELECT Id
            ,   Status
            ,   NumberOfErrors
            ,   JobItemsProcessed
            ,   TotalJobItems
            ,   ApexClass.Name
            FROM AsyncApexJob
            WHERE Id = :BC.getJobId()
        ];
    }

    private List<AsyncApexJob> selectAsyncApexJobs(Database.BatchableContext BC) {
        return [
            SELECT Id
            ,   ApexClassId
            FROM AsyncApexJob
            WHERE Id = :BC.getJobId()
        ];
    }

    private List<AsyncApexJob> selectCompletedBatchInfo(Id classId) {
        return [
            SELECT CompletedDate
            FROM AsyncApexJob
            WHERE Status = 'Completed'
                AND ApexClassId = :classId
            ORDER BY CompletedDate DESC
            LIMIT 1
        ];
    }

}