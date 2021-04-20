/**
 * @name GDT_User_Maintenance_BMC_Client
 * @description
 * Batch class that switchs users from BMC_RF_ServiceDesk Client profile to BMC_RF_ServiceDesk Client Only and the opposite.
 * the users are 
 *  - the 'BMC_RF_ServiceDesk Client' profile and createdDate < LAST_N_DAYS:60 and (lastLoginDate = null OR lastLoginDate < LAST_N_DAYS:180)
 *  - the 'BMC_RF_ServiceDesk Client Only' profile and lastLoginDate >= LAST_N_DAYS:180
 * @author Bruno Vuono/ Sophie Ducatel
 */
global class GDT_User_Maintenance_BMC_Client implements Database.Batchable<sObject>, Database.Stateful{
    //List of the profiles to switch from/to
    public Set<String> profilesIds{get;set;}
    //Assigned default values
    public String SERVICEDESK_CLIENT = '';
    public String SERVICEDESK_CLIENT_ONLY = '';
    public String days = '';
    //List of the processed users
    public List<User> processedClientUsers{get;set;}
    public List<User> processedClientOnlyUsers{get;set;}

    global GDT_User_Maintenance_BMC_Client() {
        //Retrieve profiles name values from the general config custom setting.
        try{
            //Retrieve profiles name values from the general config custom setting.
            SERVICEDESK_CLIENT = GDT_GeneralConfigDAO.getValueAsStringArray('BMC_RF_ServiceDesk_Client_Profile', ',')[0];
            SERVICEDESK_CLIENT_ONLY = GDT_GeneralConfigDAO.getValueAsStringArray('BMC_RF_ServiceDesk_Client_Only_Profile', ',')[0];
            days = GDT_GeneralConfigDAO.getValueAsStringArray('GDT_User_BMCclient_Prof_switch_in_Days', ',')[0];
        }catch(Exception ex){
            SERVICEDESK_CLIENT = '';
            SERVICEDESK_CLIENT_ONLY = '';
            days = '180';
        }
        processedClientUsers = new List<User>();
        processedClientOnlyUsers = new List<User>();
        profilesIds = new Set<String>{SERVICEDESK_CLIENT, SERVICEDESK_CLIENT_ONLY};

    }
    
    //Executes the query for the users process.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id,Name,username, profile.Name, profileId,lastLoginDate, createdDate from User where isActive = True AND ((profileId = \'' + SERVICEDESK_CLIENT + '\' and createdDate < LAST_N_DAYS:60 and (lastLoginDate = null OR lastLoginDate < LAST_N_DAYS:' + days + ')) OR (profileId = \'' + SERVICEDESK_CLIENT_ONLY + '\' AND lastLoginDate >= LAST_N_DAYS:'+ days +'))';
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        processUsers((List<User>)scope);
    }
    
    //Batch finish method that send a email with the list of the proccessed users.
    global void finish(Database.BatchableContext BC) {
        List<String> emailRecipients = GDT_GeneralConfigDAO.getValueAsStringArray('GDT_User_Email_Notification', ',',false);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailRecipients);
        mail.setSubject('GDT User Maintenance : BMC Clients Processed');
        system.debug(processedClientUsers.size());
        system.debug(processedClientOnlyUsers.size());
        String messageBody = notificationEmailBuilder(processedClientUsers,processedClientOnlyUsers);
        mail.setHtmlBody(messageBody);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    //Email builder method.
    public String notificationEmailBuilder(List<User> processedClientUsers, List<User>processedClientOnlyUsers){
        String clientUsers = GDT_User_Maintenance_Scheduler.prepareList('Processed from BMC_RF Client to Client Only Users', processedClientUsers, new List<String>{'id','name', 'username'});
        String clientOnlyUsers = GDT_User_Maintenance_Scheduler.prepareList('Processed from BMC_RF Client Only to Client Users', processedClientOnlyUsers,new List<String>{'id','name', 'username'});
        String summaryHeader = GDT_User_Maintenance_Scheduler.generateSummary(new Map<String, Integer>{'Processed from BMC_RF Client to Client Only Users' => processedClientUsers.size(), 'Processed from BMC_RF Client Only to Client Users' => processedClientOnlyUsers.size()});
        String emailBody = GDT_User_Maintenance_Scheduler.prepareBody('GDT User Maintenance : BMC Clients Processed', summaryHeader + clientUsers + clientOnlyUsers);
        return emailBody;
    }

    //Method that switch the profiles and updates it on the DB.
    public void processUsers(List<User> users){
        
        if(profilesIds.contains(SERVICEDESK_CLIENT) && profilesIds.contains(SERVICEDESK_CLIENT_ONLY)){
            for(User usr : users){
                if(usr.profileId == SERVICEDESK_CLIENT){
                    usr.profileId = SERVICEDESK_CLIENT_ONLY;
                    processedClientUsers.add(usr);
                }else if(usr.profileId == SERVICEDESK_CLIENT_ONLY){
                    usr.profileId = SERVICEDESK_CLIENT;
                    processedClientOnlyUsers.add(usr);
                }
            }
        }
        system.debug(processedClientUsers);
        Database.update(users, false);
    }
    
}