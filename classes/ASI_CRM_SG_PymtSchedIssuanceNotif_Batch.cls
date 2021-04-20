/***************************************************************************************************
 * Name : ASI_CRM_SG_PymtSchedIssuanceNotif_Batch
 * Created : DC @03/25/2016 11:29 AM
 * Revision History:
 * 1. 03/25/2016 - [DC 1.0] Created
 * 2. 29 Mar 2016 - [VL 2.0] Correct the selected schedule date
 * 3. 04/05/2016 - [DC 1.1] Fixed defect #43 in defect list.
 * 4. 18 Apr 2016 - [VL 3.0] include % achieved payment schedule
 * 5. 23 Apr 2016 - [VL 4.0] add report link to email
 * 6. 10 Jun 2016 - [HC 1.0] Update the payment schedule sort order
 * 7. 18 Jul 2016 - [HC 2.0] Update the URL port number
 **************************************************************************************************/

global class ASI_CRM_SG_PymtSchedIssuanceNotif_Batch
    implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private final static String EMAIL_SUBJECT = 'Prepare to Issue Payment Schedule(s)';
    private static final String BODY_DATE_FORMAT = 'd MMM YYYY';
    private static final String HI = 'Hi ';
    private static final String COMMA = ',';
    private static final String BLANK_SPACE = ' ';
    private static final String GREETING =
        'Here is the Payment Schedules which are ready to issue of your contract(s).';
    private static final String S_DOLLAR_SIGN = ' : S$ ';
    private static final String THANKS = 'Thanks';
    private static final String PERIOD = '. ';
    private static final String ANCHOR_START = '<a href="';
    private static final String ANCHOR_END = '"> ';
    private static final String ANCHOR_CLOSING_TAG = '</a>';
    private static final String LINE_BREAK = '<br />';
    private static final String REPORT_LINK = 'YTD Achievement Report: ';
    /* [HC 2.0] BEGIN */
    private static final String YTD_REPORT_LINK_START = 'https://obiee.pernod-ricard-asia.com:{0}/analytics/saw.dll?GO&Action=Extract&Path=/shared/PRSG/Report/Till%20Date%20Performance%20Summary%20Report&P0=1&P1=eq&P2=%22ASI_TH_CRM_CONTRACT%22.%22ROWID%22&P3=%22';
    /* [HC 2.0] END */
    private static final String YTD_REPORT_LINK_END = '%22';
    private static final String YTD_REPORT_LINK_CLICK_HERE = 'Click Here';
    private static final String OUTLET = 'Outlet: ';
    private static final String BASE_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/';

    private String query = 'SELECT Id'
                         + '     , ASI_CRM_Contract__c'
                         + '     , ASI_CRM_Schedule_Date__c'
                         + '     , ASI_CRM_Sponsorship__c'
                         + '     , ASI_CRM_Contract__r.Name'
                         + '     , ASI_CRM_Contract__r.OwnerId'
                         + '     , ASI_CRM_Contract__r.ASI_CRM_CN_Sys_Approver_2__c'
                         + '     , ASI_CRM_Contract__r.Owner.Email'
                         + '     , ASI_CRM_Contract__r.Owner.Name'
                         + '     , ASI_CRM_Contract__r.ASI_CRM_CN_Sys_Approver_2__r.Email'
                         + '     , ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.name'
                        /* [VL 3.0] BEGIN */
                         + '     , ASI_CRM_Percentof_achieved_Sales_Target__c'
                        /* [VL 3.0] END */
                         + '  FROM ASI_CRM_Payment_Schedule__c'
                         /*+ ' WHERE ASI_CRM_Contract__c = \'a8cM00000000IowIAE\''
                         + '   AND ASI_CRM_Schedule_Date__c <> NULL';*/
                         + ' WHERE RecordType.DeveloperName = \'ASI_CRM_SG_Payment_Schedule\''
                         + '   AND ASI_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c = \'Contract Approved\''
                         + '   AND ASI_CRM_Type__c = \'Cash Sponsorship\''
                        /* [VL 3.0] BEGIN */
                        /*
                         + '   AND ASI_CRM_Schedule_Date__c <> NULL'
                        // [VL 2.0] BEGIN 
                        // + '   AND ASI_CRM_Schedule_Date__c = LAST_N_DAYS:35'
                         + '   AND ASI_CRM_Schedule_Date__c <= NEXT_N_DAYS:35'
                        // [VL 2.0] END
                        */
                         + '   AND ('
                         + '      (ASI_CRM_Schedule_Date__c <> NULL AND ASI_CRM_Schedule_Date__c <= NEXT_N_DAYS:35) OR '
                         + '      (ASI_CRM_Percentof_achieved_Sales_Target__c <> NULL AND ASI_CRM_Achieved__c = TRUE) '
                         + '   ) '
                        /* [VL 3.0] END */
                         + '   AND ASI_CRM_Alerted__c = FALSE';

    private Map<Id, EmailWrapper> mapOwnerId_EmailMessage = new Map<Id, EmailWrapper>();

    private List<ASI_CRM_Payment_Schedule__c> lstPaymentSchedules_ToUpdate = 
        new List<ASI_CRM_Payment_Schedule__c>();

    private Map<Id, List<Id>> mapOwnerId_OwnedContractIds = new Map<Id, List<Id>>();

    private Map<Id, List<ASI_CRM_Payment_Schedule__c>> mapContractId_PaymentSchedules =
        new Map<Id, List<ASI_CRM_Payment_Schedule__c>>();

    private Map<Id, Boolean> mapContractId_IsProcessed = new Map<Id, Boolean>();

    private Map<Id, String> mapContractId_ContractName = new Map<Id, String>();
    
    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext contextInstance, list<Sobject> pLstFetchedRecords) {

        List<ASI_CRM_Payment_Schedule__c> lstPaymentSchedules_ToProcess =
            (List<ASI_CRM_Payment_Schedule__c>) pLstFetchedRecords;

        System.debug('------ lstPaymentSchedules_ToProcess ------ : \n\n' + lstPaymentSchedules_ToProcess);

        /* [HC 2.0] BEGIN */
        Set<Id> userIdSet = new Set<Id>();
        /* [HC 2.0] END */

        for(ASI_CRM_Payment_Schedule__c scheduleIterator : lstPaymentSchedules_ToProcess) {
            
            /* [HC 2.0] BEGIN */
            userIdSet.add(scheduleIterator.ASI_CRM_Contract__r.OwnerId);
            /* [HC 2.0] END */

            if( !mapOwnerId_OwnedContractIds.containsKey(scheduleIterator.ASI_CRM_Contract__r.OwnerId) ) {

                mapOwnerId_OwnedContractIds.put(
                    scheduleIterator.ASI_CRM_Contract__r.OwnerId,
                    new List<Id> {scheduleIterator.ASI_CRM_Contract__c}
                );

            } else {
                mapOwnerId_OwnedContractIds.get(scheduleIterator.ASI_CRM_Contract__r.OwnerId)
                                           .add(scheduleIterator.ASI_CRM_Contract__c);
            }

            if( !mapContractId_PaymentSchedules.containsKey(scheduleIterator.ASI_CRM_Contract__c) ) {

                mapContractId_PaymentSchedules.put(
                    scheduleIterator.ASI_CRM_Contract__c,
                    new List<ASI_CRM_Payment_Schedule__c> {scheduleIterator}
                );

            } else {
                mapContractId_PaymentSchedules.get(scheduleIterator.ASI_CRM_Contract__c)
                                              .add(scheduleIterator);
            }

            if( !mapContractId_ContractName.containsKey(scheduleIterator.ASI_CRM_Contract__c) ) {

                mapContractId_ContractName.put(
                    scheduleIterator.ASI_CRM_Contract__c,
                    scheduleIterator.ASI_CRM_Contract__r.Name
                );

            }

            lstPaymentSchedules_ToUpdate.add( new ASI_CRM_Payment_Schedule__c(
                Id = scheduleIterator.Id,
                ASI_CRM_Alerted__c = true
            ));

        }

        /* [HC 2.0] BEGIN */
        Map<Id, User> userIdMap = new Map<Id, User>([SELECT Id, ASI_OBIEE_Domain__c
                                                        FROM User
                                                            WHERE Id in :userIdSet]);
        /* [HC 2.0] END */        

        EmailWrapper wrapperPlaceHolder;
        String emailHtmlBody;
        String recordLink;
        DateTime datePlaceHolder;

        for(ASI_CRM_Payment_Schedule__c scheduleIterator : lstPaymentSchedules_ToProcess) {

            if( !mapOwnerId_EmailMessage.containsKey(scheduleIterator.ASI_CRM_Contract__r.OwnerId) ) {

                wrapperPlaceHolder = new EmailWrapper();
                
                wrapperPlaceHolder.toEmailAddress =
                    mapContractId_PaymentSchedules.get(
                        mapOwnerId_OwnedContractIds.get(scheduleIterator.ASI_CRM_Contract__r.OwnerId).get(0)
                    ).get(0).ASI_CRM_Contract__r.Owner.Email;
                
                wrapperPlaceHolder.ccEmailAddress =
                    mapContractId_PaymentSchedules.get(
                        mapOwnerId_OwnedContractIds.get(scheduleIterator.ASI_CRM_Contract__r.OwnerId).get(0)
                    ).get(0).ASI_CRM_Contract__r.ASI_CRM_CN_Sys_Approver_2__r.Email;

                // Generating email body
                emailHtmlBody = HI;
                
                emailHtmlBody += mapContractId_PaymentSchedules.get(mapOwnerId_OwnedContractIds.get(scheduleIterator.ASI_CRM_Contract__r.OwnerId).get(0))
                                                            .get(0).ASI_CRM_Contract__r.Owner.Name
                               + COMMA
                               + LINE_BREAK
                               + LINE_BREAK
                               + GREETING
                               + LINE_BREAK;

            } else {
                wrapperPlaceHolder = mapOwnerId_EmailMessage.get(scheduleIterator.ASI_CRM_Contract__r.OwnerId);
                emailHtmlBody = wrapperPlaceHolder.emailBody;
            }

            if( !mapContractId_IsProcessed.containsKey(scheduleIterator.ASI_CRM_Contract__c) ) {
                emailHtmlBody += LINE_BREAK
                               + scheduleIterator.ASI_CRM_Contract__r.Name
                               + BLANK_SPACE
                               + ANCHOR_START
                               + BASE_URL + scheduleIterator.ASI_CRM_Contract__c
                               + ANCHOR_END
                               + BASE_URL + scheduleIterator.ASI_CRM_Contract__c
                               + ANCHOR_CLOSING_TAG
                               + LINE_BREAK
                               + OUTLET
                               + scheduleIterator.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.name
                               + LINE_BREAK
                            /* [VL 4.0] BEGIN */
                               + REPORT_LINK
                               + BLANK_SPACE
                               + ANCHOR_START
                               /* [HC 2.0] BEGIN */
                               + String.format(YTD_REPORT_LINK_START, new String[]{userIdMap.get(scheduleIterator.ASI_CRM_Contract__r.OwnerId).ASI_OBIEE_Domain__c})
                               /* [HC 2.0] END */
                               + scheduleIterator.ASI_CRM_Contract__c
                               + YTD_REPORT_LINK_END
                               + ANCHOR_END
                               + YTD_REPORT_LINK_CLICK_HERE
                               + ANCHOR_CLOSING_TAG
                               + LINE_BREAK
                            /* [VL 4.0] END */
                    ;

                Integer index = 1;

                /* [HC 1.0] BEGIN */
                List<ASI_CRM_Payment_Schedule__c> sortedPaymentScheduleList = mapContractId_PaymentSchedules.get(scheduleIterator.ASI_CRM_Contract__c);

                Boolean swapped = true;
                Integer currentRunTime = 0;
                ASI_CRM_Payment_Schedule__c tempPaymentSchedule;

                while(swapped) {

                    swapped = false;
                    currentRunTime += 1;

                    for(Integer i = 0; i < sortedPaymentScheduleList.size() - currentRunTime ; i++) {

                        Integer percentOfAchievedSalesTarget = 0;
                        Integer nextPercentOfAchievedSalesTarget = 0;
                        if(sortedPaymentScheduleList[i].ASI_CRM_Percentof_achieved_Sales_Target__c != NULL) {

                            percentOfAchievedSalesTarget = Integer.valueOf(sortedPaymentScheduleList[i].ASI_CRM_Percentof_achieved_Sales_Target__c);

                        }

                        if(sortedPaymentScheduleList[i + 1].ASI_CRM_Percentof_achieved_Sales_Target__c != NULL) {

                            nextPercentOfAchievedSalesTarget = Integer.valueOf(sortedPaymentScheduleList[i + 1].ASI_CRM_Percentof_achieved_Sales_Target__c);

                        }

                        if(percentOfAchievedSalesTarget > nextPercentOfAchievedSalesTarget) {

                            tempPaymentSchedule = sortedPaymentScheduleList[i];
                            sortedPaymentScheduleList[i] = sortedPaymentScheduleList[i + 1];
                            sortedPaymentScheduleList[i + 1] = tempPaymentSchedule;
                            swapped = true;

                        }

                    }

                }



                for(ASI_CRM_Payment_Schedule__c innerScheduleIterator
                    : sortedPaymentScheduleList) {

                    /* [VL 3.0] BEGIN */
                    /*
                    Date temp = innerScheduleIterator.ASI_CRM_Schedule_Date__c;

                    datePlaceHolder =
                        DateTime.newInstance(temp.year(), temp.month(), temp.day());

                    emailHtmlBody += (index++)
                                   + PERIOD
                                   + datePlaceHolder.format(BODY_DATE_FORMAT).toUpperCase()
                                   + S_DOLLAR_SIGN
                                   + innerScheduleIterator.ASI_CRM_Sponsorship__c
                                   + LINE_BREAK;
                    */
                        if (innerScheduleIterator.ASI_CRM_Schedule_Date__c <> null) {
                            Date temp = innerScheduleIterator.ASI_CRM_Schedule_Date__c;

                            datePlaceHolder =
                                DateTime.newInstance(temp.year(), temp.month(), temp.day());
        
                            emailHtmlBody += (index++)
                                           + PERIOD
                                           + datePlaceHolder.format(BODY_DATE_FORMAT).toUpperCase()
                                           + S_DOLLAR_SIGN
                                           + innerScheduleIterator.ASI_CRM_Sponsorship__c
                                           + LINE_BREAK;
                        } else {
                            emailHtmlBody += (index++)
                                           + PERIOD
                                           + innerScheduleIterator.ASI_CRM_Percentof_achieved_Sales_Target__c
                                           + '%'
                                           + LINE_BREAK;
                        }
                    
                    /* [VL 3.0] END */

                    mapContractId_IsProcessed.put(innerScheduleIterator.ASI_CRM_Contract__c, true);
                }

                /* [HC 1.0] END */
            }

            wrapperPlaceHolder.emailBody = emailHtmlBody;

            mapOwnerId_EmailMessage.put(scheduleIterator.ASI_CRM_Contract__r.OwnerId, wrapperPlaceHolder);

        }
    }

    global void execute(SchedulableContext contextInstance) {}

    global void finish(Database.BatchableContext contextInstance) {

        List<Messaging.SingleEmailMessage> lstEmails_ToSend = new List<Messaging.SingleEmailMessage>();
        
        try {

            if( !mapOwnerId_EmailMessage.isEmpty() ) {
                
                for(Id ownerId : mapOwnerId_EmailMessage.keySet()) {
                    
                    Messaging.SingleEmailMessage emailPlaceHolder = new Messaging.SingleEmailMessage();

                    emailPlaceHolder.setToAddresses( new List<String> {
                        mapOwnerId_EmailMessage.get(ownerId).toEmailAddress
                    });

                    if(String.isNotBlank(mapOwnerId_EmailMessage.get(ownerId).ccEmailAddress)) {
                        emailPlaceHolder.setCcAddresses( new List<String> {
                            mapOwnerId_EmailMessage.get(ownerId).ccEmailAddress
                        });
                    }

                    emailPlaceHolder.setSubject(EMAIL_SUBJECT);

                    emailPlaceHolder.setHtmlBody(
                        mapOwnerId_EmailMessage.get(ownerId).emailBody + LINE_BREAK + THANKS
                    );

                    lstEmails_ToSend.add(emailPlaceHolder);
                }

                Messaging.sendEmail(lstEmails_ToSend);

                if( !lstPaymentSchedules_ToUpdate.isEmpty() ) {
                    update lstPaymentSchedules_ToUpdate;
                }
            }  

        } catch(Exception exceptionInstance) {
            // TODO : Nothing
        }
    }

    /* Wrapper class for holding email related data */
    private class EmailWrapper {
        public String toEmailAddress;
        public String ccEmailAddress;
        public String emailBody;

        public EmailWrapper() {
            toEmailAddress = '';
            ccEmailAddress = '';
            emailBody = '';
        }
    }
}