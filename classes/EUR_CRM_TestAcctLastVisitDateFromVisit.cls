/***************************************************
*   EUR_CRM_TestAcctLastVisitDateFromVisit
*
*   Test class for EUR_CRM_SetAccountLastVisitDateFromVisit trigger handler
* ***************************************************/

@isTest
public class EUR_CRM_TestAcctLastVisitDateFromVisit {
    // Main Method
    static testmethod void testTriggerExecution(){
        // Applicable to CH visit only (for now)
        Id CHVisitRecordTypeId = [select Id from RecordType where SObjectType ='EUR_CRM_Visit__c' and developername = 'EUR_CH_Visit'].id;
        // Insert test account
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c();
        insert acc;
        // Insert test visits with different dates
        List<EUR_CRM_Visit__c> visits = new List<EUR_CRM_Visit__c>();
        EUR_CRM_Visit__c oldVisit = new EUR_CRM_Visit__c(
                                                        RecordTypeId = CHVisitRecordTypeId,
                                                        EUR_CRM_Account__c = acc.Id,
                                                        EUR_CRM_Start_Datetime__c = (DateTime.Now().addDays(-2))
                                                    );
        visits.add(oldVisit);
        EUR_CRM_Visit__c newVisit = new EUR_CRM_Visit__c(
                                                        RecordTypeId = CHVisitRecordTypeId,
                                                        EUR_CRM_Account__c = acc.Id,
                                                        EUR_CRM_Start_Datetime__c = (DateTime.Now().addDays(-1))
                                                    );
        visits.add(newVisit);
        insert visits;

        // Account last visit date should be that of the newest visit
        acc = [SELECT Id, EUR_CRM_Last_Visit_Date__c FROM EUR_CRM_Account__c WHERE Id =: acc.Id];
        System.assertEquals(newVisit.EUR_CRM_Start_Datetime__c, acc.EUR_CRM_Last_Visit_Date__c);

        // Update visit start datetime and check again
        oldVisit.EUR_CRM_Start_Datetime__c = Datetime.Now();
        update oldVisit;
        acc = [SELECT Id, EUR_CRM_Last_Visit_Date__c FROM EUR_CRM_Account__c WHERE Id =: acc.Id];
        System.assertEquals(oldVisit.EUR_CRM_Start_Datetime__c, acc.EUR_CRM_Last_Visit_Date__c);

    }
}