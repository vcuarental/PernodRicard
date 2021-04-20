/*********************************************************************************
 * Name:ASI_CRM_JP_CallDetail_Test3
 * Description: Test Class for Call Detail of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 31/12/2014       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_CallDetail_Test3 {
//Test for Class ASI_CRM_JP_CallDetailCalcNumOfAttendees (98%)
    static testMethod void ASI_CRM_JP_CallDetailCalcNumOfAttendees_Test(){
        User u1 = ASI_CRM_JP_TestClassHelper.createUser();
        User u2 = ASI_CRM_JP_TestClassHelper.createUser('test2');
        User u3 = ASI_CRM_JP_TestClassHelper.createUser('test3');
        
        
        System.runAs(u1){
            ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today(), ASI_CRM_Period_To__c = system.today().addDays(6));
            insert plan;
            ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', ASI_CRM_Attendees_BS__c = 'Test1;Test2', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(1), ASI_CRM_Visit_Date_To__c = system.now().addDays(1));
            insert detail1;
            List<ASI_CRM_Employee_Attendee__c> attList = new List<ASI_CRM_Employee_Attendee__c>();
            ASI_CRM_Employee_Attendee__c att = new ASI_CRM_Employee_Attendee__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee'), ASI_CRM_Attendee__c = u2.Id, ASI_CRM_Call_Detail__c = detail1.Id, ASI_CRM_Payer__c = true);
            ASI_CRM_Employee_Attendee__c att2 = new ASI_CRM_Employee_Attendee__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee'), ASI_CRM_Attendee__c = u3.Id, ASI_CRM_Call_Detail__c = detail1.Id, ASI_CRM_Payer__c = false);
            
            test.startTest();
            attList.add(att);
            attList.add(att2);
            insert attList;
            att2.ASI_CRM_Payer__c = true;
            update att2;
            test.stopTest();
        }
        
    }
}