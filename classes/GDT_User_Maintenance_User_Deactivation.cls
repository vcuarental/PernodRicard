/**
 * @name GDT_User_Maintenance_User_Deactivation
 * @description
 * Batch method that deactivate users with the conditions:
 *  -IsServiceAccount__c = false
 * - IsFrozen 
 * - LastLoginDate < LAST_N_DAYS:60
 * @author Bruno Vuono/ Sophie Ducatel
 */
global class GDT_User_Maintenance_User_Deactivation implements Database.Batchable<sObject>,Database.Stateful {
    //List of the processed Users
    public List<User> processedUsers{get;set;}
    public List<User> errorUsers{get;set;}

    public String days = '';
    
    global GDT_User_Maintenance_User_Deactivation() {
        processedUsers = new List<User>();
        errorUsers = new List<User>();
        try{
            days = GDT_GeneralConfigDAO.getValueAsStringArray('GDT_User_Deact_After_Frezze_in_Days', ',')[0];
        }catch(Exception ex){
            days = '30';
        }

    }
    
     //Executes the query for the users process.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id,Name,username FROM User WHERE IsActive = true AND DoNotFreeze__c = false AND IsServiceAccount__c = false AND Id in (SELECT UserId FROM UserLogin WHERE IsFrozen = true) AND (LastLoginDate < LAST_N_DAYS:' + days +' OR LastLoginDate = null)');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        inactivateUsers((List<User>)scope);
    }
    
    //Batch finish method that send a email with the list of the proccessed users.
    global void finish(Database.BatchableContext BC) {
        List<String> emailRecipients = GDT_GeneralConfigDAO.getValueAsStringArray('GDT_User_Email_Notification', ',',false);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailRecipients);
        mail.setSubject('GDT User Maintenance : Deactivated Users');
        String messageBody = notificationEmailBuilder(processedUsers);
        mail.setHtmlBody(messageBody); 
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        String executeAnalysis= GDT_GeneralConfigDAO.getValueAsStringArray('GDT_ManageLicense_isActive', ',',false)[0];
        //Calls batchs processes.
        if(executeAnalysis == 'true'){
            GDT_ManageLicense_Batch myBatchObject = new GDT_ManageLicense_Batch();
            ID batchprocessid = Database.executebatch(myBatchObject);
        }
    }


    public String notificationEmailBuilder(List<User> processedUsers){
        String processedUsersText = GDT_User_Maintenance_Scheduler.prepareList('Deactivated Users: ', processedUsers, new List<String>{'id','name', 'username'});
		String errorUserText = GDT_User_Maintenance_Scheduler.prepareList('Failed Users: ', errorUsers,new List<String>{'id','name', 'username'});

        String summaryHeader = GDT_User_Maintenance_Scheduler.generateSummary(new Map<String, Integer>{'Users Deactivated Failed ' => errorUsers.size() ,'Users Deactivated' => processedUsers.size()});
        String emailBody = GDT_User_Maintenance_Scheduler.prepareBody('Deactivated Users', summaryHeader + errorUserText + processedUsersText );
        return emailBody;
    }

    //Inactive the queried users. 
    public void inactivateUsers(List<User> users){
        for(User usr : users){
            usr.isActive = false;
        }
        Database.SaveResult[] srList = database.update(users, false);
        for (Integer i = 0; i < srList.size(); i++){
            if (srList[i].isSuccess()){
                processedUsers.add(users[i]);
            }else{
                errorUsers.add(users[i]);
            }
        }
    }
    
}