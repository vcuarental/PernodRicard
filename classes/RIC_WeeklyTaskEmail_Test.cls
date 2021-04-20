@isTest
public class RIC_WeeklyTaskEmail_Test{
    
    @TestSetup
    public static void initializeTasks(){
        //MBAZ init some datas
        Profile p = [SELECT Id FROM Profile WHERE Name='RIC_Workflow Plann\'R'];
        
        //prepare Users
        List<User> users = new List<User>();
        for(Integer i = 0; i < RIC_WeeklyTaskEmail.EMAIL_CNT; i++){
            users.add(new User(Alias = 'user'+i, Email='user'+i+'@email.com',
                               EmailEncodingKey='UTF-8', LastName='User'+i, LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = p.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='user'+i+'@email.com.DS78gOUds'
                              ));
        }
        insert users ;
        List<Recordtype> RT = new List<Recordtype>();
        RT=[select id from recordtype
           where developerName='RIC_PRF_DDO'];
        //Use Run As Hack for allowing DML after user insertion
        User currUser =  [SELECT ID, ProfileId, UserRoleId FROM User WHERE id = :UserInfo.getUserId() LIMIT 1];
        String rType = RT[0].id;
        System.runAs(currUser){
          /* ______________ OPP ___________________ */              
            //Project
            Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('EmailTest');
            proj.RecordTypeId=rType;
            insert proj;
            
            //Millestone
            Milestone1_Milestone__c mil = Milestone1_Test_Utility.sampleMilestone(proj);
            insert mil;
            
            //Tasks
            List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
            for (Integer i = 0; i < 100; i++){
                Milestone1_Task__c task = Milestone1_Test_Utility.sampleTask(mil);
                task.Due_Date__c = Date.Today().addDays(-5);
                task.Assigned_To__c = users.get(i).Id;
                task.RIC_Status__c = 'En Cours';
                tasks.add(task);
            }
            insert tasks;
            /* ______________ Not OPP ___________________ */ 
            //Project
            Milestone1_Project__c proj1 = Milestone1_Test_Utility.sampleProjectActive('EmailTest');
            proj.RecordTypeId=[SELECT Id 
                               FROM RecordType 
                               Where (DeveloperName= 'RIC_PRF_DDO')].Id;
            insert proj1;
            
            //Millestone
            Milestone1_Milestone__c mil1 = Milestone1_Test_Utility.sampleMilestone(proj);
            insert mil1;
            
            //Tasks
            List<Milestone1_Task__c> tasks1 = new List<Milestone1_Task__c>();
            for (Integer i = 0; i <100; i++){
                Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(mil);
                task1.Due_Date__c = Date.Today().addDays(-5);
                task1.Assigned_To__c = users.get(i).Id;
                task1.RIC_Status__c = 'En Cours';
                tasks1.add(task1);
            }
            insert tasks1;
        }
    }
    
    @isTEST
    public static void excecuteBtch(){ 
        Test.startTest();
        RIC_WeeklyTaskEmail sendEmail = new RIC_WeeklyTaskEmail();
        DataBase.executeBatch(sendEmail);  
        //RIC_WeeklyTaskEmail_Opp sendEmail_Opp = new RIC_WeeklyTaskEmail_Opp();
        //DataBase.executeBatch(sendEmail_Opp);
        Test.stoptest();
    }
    /* @isTEST
    public static void excecuteBtch_Opp(){ 
        Test.startTest();
        RIC_WeeklyTaskEmail_Opp sendEmail_Opp = new RIC_WeeklyTaskEmail_Opp();
        DataBase.executeBatch(sendEmail_Opp);  
        Test.stoptest();
    }*/
    
}