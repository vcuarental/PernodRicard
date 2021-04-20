/**
 * Created by osman on 24.11.2020.
 */

public with sharing class EUR_TR_CloseWorkedDayBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    public class EUR_TR_CloseWorkedDayBatchException extends Exception {
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        System.debug('Batch is started...');
        return Database.getQueryLocator([
                SELECT Id,OwnerId, (
                        SELECT
                                Id,EUR_TR_StartDateTime__c,EUR_TR_EndDateTime__c
                        FROM EUR_TR_Visits__r
                        WHERE EUR_TR_RelatedWorkedDay__c != NULL AND
                        EUR_TR_EndDateTime__c = NULL AND
                        EUR_TR_StartDateTime__c != NULL AND
                        RecordType.DeveloperName = 'EUR_TR_Visit' AND
                        EUR_TR_StartDateTime__c < TODAY AND
                        OwnerId != NULL
                )
                FROM EUR_TR_Visit__c
                WHERE RecordType.DeveloperName = 'EUR_TR_WorkedDay' AND
                EUR_TR_StartDateTime__c != NULL AND
                EUR_TR_EndDateTime__c = NULL AND
                EUR_TR_StartDateTime__c < TODAY AND
                OwnerId != NULL
                ORDER BY CreatedDate ASC
        ]);
    }

    public void execute(Database.BatchableContext param1, List<EUR_TR_Visit__c> workedDays) {

        EUR_TR_Definition__c workedDayDefinition = EUR_TR_WorkedDayController.getWorkedDayDefinition();
        if (workedDayDefinition == null) {
            throw new EUR_TR_CloseWorkedDayBatchException('EUR_TR_Definition cannot be found to EUR_TR_WorkedDay record type.');
        }

        Decimal maxPassedDurationAfterStartedVisit = workedDayDefinition.EUR_TR_VisitHourDurationToClose__c * 60;

        Map<Id, EUR_TR_Visit__c> ownerToWorkedDayMap = new Map<Id, EUR_TR_Visit__c>();

        for (EUR_TR_Visit__c workedDay : workedDays) {
            if (workedDay.OwnerId != null) {
                ownerToWorkedDayMap.put(workedDay.OwnerId, workedDay);
            }
        }

        List<EUR_TR_Employee__c> employees = [
                SELECT Id,EUR_TR_RelatedUser__c,EUR_TR_AutoClosedDayCount__c
                FROM EUR_TR_Employee__c
                WHERE EUR_TR_RelatedUser__c = :ownerToWorkedDayMap.keySet() AND EUR_TR_RelatedUser__c != NULL
        ];

        Map<Id, EUR_TR_Employee__c> userToEmployeeMap = new Map<Id, EUR_TR_Employee__c>();

        for (EUR_TR_Employee__c employee : employees) {
            userToEmployeeMap.put(employee.EUR_TR_RelatedUser__c, employee);
        }

        List<EUR_TR_Visit__c> visitsToClose = new List<EUR_TR_Visit__c>();
        List<EUR_TR_Visit__c> workedDaysToClose = new List<EUR_TR_Visit__c>();
        Map<Id, EUR_TR_Employee__c> updatedEmployeeMapToAutoClosedDay = new Map<Id, EUR_TR_Employee__c>();

        Datetime endDateTime = Datetime.now();

        for (Id ownerId : userToEmployeeMap.keySet()) {

            EUR_TR_Visit__c workedDay = ownerToWorkedDayMap.get(ownerId);
            List<EUR_TR_Visit__c> visits = workedDay.EUR_TR_Visits__r;

            Boolean isWorkedDayProperToClose = true;
            if (visits != null) {

                for (EUR_TR_Visit__c visit : visits) {

                    if (visit.EUR_TR_StartDateTime__c != null && visit.EUR_TR_EndDateTime__c == null) {
                        // If any visit time difference is greater than defined time difference , The system will not control other visits in day.Shortly ,only proper days to close will be closed by the system.
                        if (isWorkedDayProperToClose) {
                            Decimal passedDurationAfterStartedVisit = Decimal.valueOf(((endDateTime.getTime() - visit.EUR_TR_StartDateTime__c.getTime()) / 1000 / 60)).setScale(1, RoundingMode.HALF_UP);
                            if (passedDurationAfterStartedVisit < maxPassedDurationAfterStartedVisit) {
                                isWorkedDayProperToClose = false;
                            }
                        }
                        visit.EUR_TR_EndDateTime__c = endDateTime;
                        visit.EUR_TR_IsAutoClosedBySystem__c = true;
                    }

                }

            }

            if (isWorkedDayProperToClose) {

                if (visits != null && !visits.isEmpty()) {
                    visitsToClose.addAll(visits);
                }

                workedDay.EUR_TR_EndDateTime__c = endDateTime;
                workedDay.EUR_TR_IsAutoClosedBySystem__c = true;
                workedDaysToClose.add(workedDay);

                EUR_TR_Employee__c relatedEmployee = userToEmployeeMap.get(ownerId);
                if (relatedEmployee.EUR_TR_AutoClosedDayCount__c == null) {
                    relatedEmployee.EUR_TR_AutoClosedDayCount__c = 1;
                } else if (relatedEmployee.EUR_TR_AutoClosedDayCount__c == 0) {
                    relatedEmployee.EUR_TR_AutoClosedDayCount__c = 1;
                } else {
                    relatedEmployee.EUR_TR_AutoClosedDayCount__c += 1;
                }

                updatedEmployeeMapToAutoClosedDay.put(relatedEmployee.Id, relatedEmployee);

            }


        }

        Savepoint sp = Database.setSavepoint();
        try {

            Map<Id, EUR_TR_Employee__c> employeeBeforeUpdateMap = new Map<Id, EUR_TR_Employee__c>([
                    SELECT Id,EUR_TR_RelatedUser__c,EUR_TR_AutoClosedDayCount__c
                    FROM EUR_TR_Employee__c
                    WHERE EUR_TR_RelatedUser__c = :ownerToWorkedDayMap.keySet() AND EUR_TR_RelatedUser__c != NULL
            ]);


            if (!workedDaysToClose.isEmpty()) {
                update workedDaysToClose;
            }

            if (!visitsToClose.isEmpty()) {
                update visitsToClose;
            }

            if (!updatedEmployeeMapToAutoClosedDay.isEmpty()) {
                update updatedEmployeeMapToAutoClosedDay.values();
            }

            if (!workedDaysToClose.isEmpty()) {

                Map<Id, EUR_TR_Employee__c> employeeAfterUpdateMap = new Map<Id, EUR_TR_Employee__c>([
                        SELECT Id,EUR_TR_RelatedUser__c,EUR_TR_AutoClosedDayCount__c
                        FROM EUR_TR_Employee__c
                        WHERE EUR_TR_RelatedUser__c = :ownerToWorkedDayMap.keySet() AND EUR_TR_RelatedUser__c != NULL
                ]);

                Set<Id> userIdsToSendAutoClosedDayCountInfoMail = new Set<Id>();

                for (EUR_TR_Employee__c employeeBeforeUpdate : employeeBeforeUpdateMap.values()) {

                    EUR_TR_Employee__c employeeAfterUpdate = employeeAfterUpdateMap.get(employeeBeforeUpdate.Id);
                    Decimal closedDayCountBeforeUpdate = employeeBeforeUpdate.EUR_TR_AutoClosedDayCount__c;
                    Decimal closedDayCountAfterUpdate = employeeAfterUpdate.EUR_TR_AutoClosedDayCount__c;

                    if (closedDayCountBeforeUpdate != null && closedDayCountAfterUpdate != null && closedDayCountBeforeUpdate != closedDayCountAfterUpdate) {
                        Boolean IsAutoClosedDayCountInformationMailRequired = Math.mod(Integer.valueOf(closedDayCountAfterUpdate), 3) == 0;
                        if (IsAutoClosedDayCountInformationMailRequired) {
                            userIdsToSendAutoClosedDayCountInfoMail.add(employeeAfterUpdate.EUR_TR_RelatedUser__c);
                        }
                    }

                }

                if (!userIdsToSendAutoClosedDayCountInfoMail.isEmpty()) {
                    sendAutoClosedDayInfoMail(userIdsToSendAutoClosedDayCountInfoMail);
                }

                Set<Id> closedWorkedDayIds = new Set<Id>();
                for (EUR_TR_Visit__c visit : workedDaysToClose) {
                    closedWorkedDayIds.add(visit.Id);
                }

                if (!closedWorkedDayIds.isEmpty()) {
                    //EUR_TR_RouteController.deleteNotStartedRouteVisits(closedWorkedDayIds);
                    EUR_TR_RouteReportController.calculateWorkedDaySummaryReport(closedWorkedDayIds);
                }

            }


        } catch (Exception ex) {

            Database.rollback(sp);
            System.debug('Message : ' + ex.getMessage());
            System.debug('Exception Trace String : ' + ex.getStackTraceString());
            throw new EUR_TR_CloseWorkedDayBatchException(ex);

        }


    }

    public void finish(Database.BatchableContext param1) {
        System.debug('EUR_TR_CloseWorkedDayBatch batch is completed');
    }

    private static void sendAutoClosedDayInfoMail(Set<Id> userIds) {

        // TODO : Email message format and message detail
        List<User> users = [
                SELECT Id,Email,Name
                FROM User
                WHERE IsActive = TRUE AND Id IN :userIds AND Email != NULL
        ];

        List<Messaging.SingleEmailMessage> autoClosedDayInfoEmailMessages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage autoClosedDayInfoEmailMessage = null;
        for (User user : users) {
            autoClosedDayInfoEmailMessage = createAutoClosedDayInfoMailMessageInstanceByUser(autoClosedDayInfoEmailMessage, user);
            autoClosedDayInfoEmailMessages.add(autoClosedDayInfoEmailMessage);
        }

        if (!autoClosedDayInfoEmailMessages.isEmpty()) {
            List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(autoClosedDayInfoEmailMessages);
            Boolean isSuccess = sendEmailResults.get(0).isSuccess();
            if (isSuccess) {
                System.debug('Mail is sent successfully...');
            } else {
                System.debug('Mail is not sent successfully... ' + sendEmailResults.get(0).getErrors().get(0).getMessage());
            }
        }


    }


    private static Messaging.SingleEmailMessage createAutoClosedDayInfoMailMessageInstanceByUser(Messaging.SingleEmailMessage autoClosedDayInfoEmailMessage, User user) {

        String emailBody = createAutoClosedDayInformationEmailBody(user.Name);
        autoClosedDayInfoEmailMessage = new Messaging.SingleEmailMessage();
        autoClosedDayInfoEmailMessage.setHtmlBody(emailBody);
        autoClosedDayInfoEmailMessage.setToAddresses(new List<String>{
                user.Email
        });
        autoClosedDayInfoEmailMessage.setSenderDisplayName('Pernod Ricard Salesforce Destek');
        autoClosedDayInfoEmailMessage.setSubject('Pernod Ricard Gün Bitirme Bilgilendirme Maili');
        autoClosedDayInfoEmailMessage.setUseSignature(false);
        autoClosedDayInfoEmailMessage.setBccSender(false);
        autoClosedDayInfoEmailMessage.setSaveAsActivity(false);
        return autoClosedDayInfoEmailMessage;

    }

    private static String createAutoClosedDayInformationEmailBody(String userName) {

        String htmlTemplate = '<html>\n' +
                '<head>' +
                '</head>\n' +
                '<body style="color:black;">{0}</body> ' +
                '</html>' ;

        String rows = '';
        rows = String.format('<p>Sayın {0},</p> ', new List<String>{
                userName
        });

        rows += '<p>Gün kapama işleminiz 3 kere sistem tarafından otomatik olarak gerçekleşmiştir. Lütfen günü tamamlandığınızda ziyaret ve gün bitirme işlemlerini yapmayı unutmayınız.</p>';
        rows += '<p>Teşekkürler</p>';
        rows += '<p>Salesforce</p>';

        htmlTemplate = String.format(htmlTemplate, new List<String>{
                rows
        });
        return htmlTemplate;

    }

}