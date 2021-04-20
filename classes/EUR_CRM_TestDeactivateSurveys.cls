@isTest
public class EUR_CRM_TestDeactivateSurveys{
 static User eurSysUser; 
    static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }
    static testMethod  void testDeactivateSurvey(){
        setUser();        
        System.runAs(eurSysUser){
            Id fiOnAccountRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade'); 
            Id fiOnSurveyHeaderRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Survey_Header__c','EUR_FI_ON_Trade_Survey_Header'); 
            Id fiSurveyRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Survey__c','EUR_FI_Survey'); 
            
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test', 
            EUR_CRM_Status__c = 'Active');
            insert account;
            Date yesterday = System.today().addDays(-1);
            EUR_CRM_Survey_Header__c surveyHeader = new EUR_CRM_Survey_Header__c(
                recordtypeid = fiOnSurveyHeaderRecordTypeId,
                name = 'test survey header',
                EUR_CRM_Valid_From__c = yesterday,
                EUR_CRM_Valid_Until__c = yesterday ,
                EUR_CRM_Active__c = true                
            );
            
            insert surveyHeader;
            EUR_CRM_Survey_Header__c surveyHeader2= new EUR_CRM_Survey_Header__c(
                recordtypeid = fiOnSurveyHeaderRecordTypeId,
                name = 'test survey header2',
                EUR_CRM_Valid_From__c = yesterday,
                EUR_CRM_Valid_Until__c = yesterday ,
                EUR_CRM_Active__c = true                
            );
            
            insert surveyHeader2;
            
            EUR_CRM_Survey__c survey = new EUR_CRM_Survey__c(
                EUR_CRM_Account__c = account.id,
                EUR_CRM_Survey_Header__c = surveyHeader.id,
                EUR_CRM_Active__c = true
                
            );
            
            insert survey;
            Test.startTest();
            
            system.assert(EUR_CRM_DeactivateSurveys.generateQuery() != null);
            Database.BatchableContext BC = null;
            EUR_CRM_DeactivateSurveys ds = new EUR_CRM_DeactivateSurveys();
            ds.execute(BC,(List<sObject>) ( new List<EUR_CRM_Survey__c>{survey }));
            ds.finish(BC);
            Test.stopTest();
        }        
    }
    
    /*
    EUR_CRM_ScheduleDeactivateSurveys
    */
    static testMethod void testScheduleDeactivateSurveys() {
        
                String sched = '0 00 * * * ?';
                // Abort all CronTrigger records
               // for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);
              List<CronJobDetail> details = [ SELECT Id FROM CronJobDetail where name = 'Deactivate EU Surveys'];
                   if(details  != null && details.size() > 0){
                          CronJobDetail cd =details.get(0);
                       CronTrigger d =[select id from CronTrigger where  CronJobDetailId =: cd.id ];
                       if(d!=null)
                           System.abortJob(d.Id);
                    } 
                Test.startTest();
                    EUR_CRM_ScheduleDeactivateSurveys.schedule();
                 Test.stopTest();  
    } 
}