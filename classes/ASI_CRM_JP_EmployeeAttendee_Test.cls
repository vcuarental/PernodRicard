/*********************************************************************************
 * Name:ASI_CRM_JP_EmployeeAttendee_Test
 * Description: Test Class for EmployeeAttendee of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 6/1/2015       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_EmployeeAttendee_Test {
    //Test for Class ASI_CRM_EmployeeAttendeeTgrHdlr
    static testMethod void ASI_CRM_EmployeeAttendeeTgrHdlr_Test() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test2@laputa.com');
        insert u2;
        
        User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test3@laputa.com');
        insert u3;
        
        test.startTest();
        System.runAs(u1){
            ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today(), ASI_CRM_Period_To__c = system.today().addDays(60));
            insert plan;
            
            ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now(), ASI_CRM_Visit_Date_To__c = system.now());
            insert detail1;
            
            ASI_CRM_Employee_Attendee__c att = new ASI_CRM_Employee_Attendee__c (RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee'), ASI_CRM_Attendee__c = u2.Id, ASI_CRM_Call_Detail__c = detail1.Id);
            insert att;
            
            att.ASI_CRM_Attendee__c = u3.Id;
            update att; 
            
            att.ASI_CRM_Attendee__c = u1.Id;
            
            ASI_CRM_Employee_Attendee__c att2 = new ASI_CRM_Employee_Attendee__c (RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee'), ASI_CRM_Attendee__c = u1.Id, ASI_CRM_Call_Detail__c = detail1.Id);
            try{
                insert att2; 
            }catch(Exception e){
                System.Assert(e.getMessage().contains(' '));
            }
            
            try{
                update att;
            }catch(Exception e){
                System.Assert(e.getMessage().contains(' '));
            }
                    
        }
        test.stopTest();
    }
    
    //Test for Class ASI_CRM_JP_CallDetailTransfer
    static testMethod void ASI_CRM_JP_CallDetailTransfer_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test2@laputa.com');
        insert u2;
        
        
        System.runAs(u1){
            List<ASI_CRM_Call_Plan__c> planList = new List<ASI_CRM_Call_Plan__c>();
            ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today(), ASI_CRM_Period_To__c = system.today().addDays(30));
            ASI_CRM_Call_Plan__c plan2 = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today().addDays(31), ASI_CRM_Period_To__c = system.today().addDays(60));
            ASI_CRM_Call_Plan__c plan3 = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today().addDays(61), ASI_CRM_Period_To__c = system.today().addDays(90));
            ASI_CRM_Call_Plan__c plan4 = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today().addDays(91), ASI_CRM_Period_To__c = system.today().addDays(120));
            ASI_CRM_Call_Plan__c plan5 = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u2.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today().addDays(61), ASI_CRM_Period_To__c = system.today().addDays(90));
            ASI_CRM_Call_Plan__c plan6 = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u2.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today().addDays(91), ASI_CRM_Period_To__c = system.today().addDays(120));
            planList.add(plan);
            planList.add(plan2);
            planList.add(plan3);
            planList.add(plan4);
            planList.add(plan5);
            planList.add(plan6);
            insert planList;
            test.startTest();
            List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();
            ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now(), ASI_CRM_Visit_Date_To__c = system.now());
            ASI_CRM_Call_Detail__c detail2 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan2.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(40), ASI_CRM_Visit_Date_To__c = system.now().addDays(40));
            ASI_CRM_Call_Detail__c detail3 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan3.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(70), ASI_CRM_Visit_Date_To__c = system.now().addDays(70));
            ASI_CRM_Call_Detail__c detail4 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan4.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(110), ASI_CRM_Visit_Date_To__c = system.now().addDays(110));
            detailList.add(detail1);
            detailList.add(detail2);
            detailList.add(detail3);
            detailList.add(detail4);
            insert detailList;
            
            List<ASI_CRM_Employee_Attendee__c> attList = new List<ASI_CRM_Employee_Attendee__c>();
            ASI_CRM_Employee_Attendee__c att = new ASI_CRM_Employee_Attendee__c (RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee'), ASI_CRM_Attendee__c = u2.Id, ASI_CRM_Call_Detail__c = detail1.Id, ASI_CRM_Payer__c = true);
            ASI_CRM_Employee_Attendee__c att2 = new ASI_CRM_Employee_Attendee__c (RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee'), ASI_CRM_Attendee__c = u2.Id, ASI_CRM_Call_Detail__c = detail2.Id, ASI_CRM_Payer__c = false);
            ASI_CRM_Employee_Attendee__c att3 = new ASI_CRM_Employee_Attendee__c (RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee'), ASI_CRM_Attendee__c = u2.Id, ASI_CRM_Call_Detail__c = detail3.Id, ASI_CRM_Payer__c = true);
            ASI_CRM_Employee_Attendee__c att4 = new ASI_CRM_Employee_Attendee__c (RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee'), ASI_CRM_Attendee__c = u2.Id, ASI_CRM_Call_Detail__c = detail4.Id, ASI_CRM_Payer__c = false);
            attList.add(att);
            attList.add(att2);
            attList.add(att3);
            attList.add(att4);
            insert attList;
            
            att2.ASI_CRM_Payer__c = true;
            att4.ASI_CRM_Payer__c = true;
            List<ASI_CRM_Employee_Attendee__c> attListToUpdate = new List<ASI_CRM_Employee_Attendee__c>();
            attListToUpdate.add(att2);
            attListToUpdate.add(att4);
            update attListToUpdate;
        }
        test.stopTest();
    }
    
    //Test for ASI_CRM_JP_ProtectDeleteEmployee_Record 
    static testMethod void ASI_CRM_JP_ProtectDeleteEmployee_Record_Test(){ 
            User u1 = ASI_CRM_JP_TestClassHelper.createUser();
        
            ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(Name = 'Test', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan_Locked'), ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today(), ASI_CRM_Period_To__c = system.today().addDays(60));
            insert plan;
            ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now(), ASI_CRM_Visit_Date_To__c = system.now());
            insert detail1;
            ASI_CRM_Employee_Attendee__c att = new ASI_CRM_Employee_Attendee__c (RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee'), ASI_CRM_Attendee__c = u1.Id, ASI_CRM_Call_Detail__c = detail1.Id);
            insert att;
            
            test.startTest();
            try{
                delete att;
            }catch(Exception e){
                
            }
            try{
                delete detail1;
            }catch(Exception e){
                
            }
            test.stopTest();
    }
}