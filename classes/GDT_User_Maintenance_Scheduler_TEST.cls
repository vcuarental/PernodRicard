@isTest
private class GDT_User_Maintenance_Scheduler_TEST {
    
    @isTest static void test_GDT_User_Maintenance_Scheduler() {
        initialize();
        GDT_User_Maintenance_Scheduler controller = new GDT_User_Maintenance_Scheduler();
        controller.execute(null);
        controller.canExecuteBatch(true);
        GDT_Data_Backup.createSandbox();

    }
    
    @isTest static void test_GDT_User_Maintenance_BMC_Client() {
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
            initialize();
        }
        User u1 = createUserWithProfile('u1', 'BMC_RF_ServiceDesk Client');
        insert u1;
        GDT_User_Maintenance_BMC_Client controller = new GDT_User_Maintenance_BMC_Client();
        controller.SERVICEDESK_CLIENT = '00eD0000001PqPY';
        controller.SERVICEDESK_CLIENT_ONLY = '00e1i000000YLVW';
        controller.start(null);
        List<User> usrs = [Select id, profile.Name, profileId,lastLoginDate, createdDate from User where id =: u1.id];
        controller.execute(null,usrs);
        controller.finish(null);
        User u2 = [Select id, firstname,lastmodifiedDate, profile.Name, profileId,lastLoginDate, createdDate from User where id =: u1.id];
       // system.assertEquals(u2.profile.name, 'BMC_RF_ServiceDesk Client Only');
    }

    @isTest static void test_GDT_User_Maintenance_User_Deactivation() {
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
            initialize();
        }
        User u1 = createUserWithProfile('u1', 'BMC_RF_ServiceDesk Client');
        insert u1;
        Test.startTest();
        GDT_User_Maintenance_User_Deactivation controller = new GDT_User_Maintenance_User_Deactivation();
        controller.start(null);
        u1 = [Select id, profile.Name, profileId,lastLoginDate, createdDate from User where id =: u1.id];
        controller.execute(null, new list<User>{u1});
        controller.finish(null);
        u1 = [Select id, profile.Name,IsActive, profileId,lastLoginDate, createdDate from User where id =: u1.id];
        system.assertEquals(u1.isActive, false);
         Test.stopTest();
    }




    /**
     * Variable Creation
     */
    public static void initialize() {
        List<GDT_GeneralConfig__c> gconfigs = new List<GDT_GeneralConfig__c>();

        GDT_GeneralConfig__c flagLicense = new GDT_GeneralConfig__c(name = 'GDT_ManageLicense_isActive', GDT_Value__c = 'true');
        gconfigs.add(flagLicense);

        GDT_GeneralConfig__c flagDeactivation = new GDT_GeneralConfig__c(name = 'GDT_User_Deactivation_isActive', GDT_Value__c = 'false');
        gconfigs.add(flagDeactivation);

        GDT_GeneralConfig__c flagClientExecution = new GDT_GeneralConfig__c(name = 'BMC_RF_ServiceDesk_Client_isActive', GDT_Value__c = 'false');
        gconfigs.add(flagClientExecution);

                GDT_GeneralConfig__c flagRefresh = new GDT_GeneralConfig__c(name = 'GDT_RefreshSandbox', GDT_Value__c = 'true');
        gconfigs.add(flagRefresh);

        GDT_GeneralConfig__c clientProfile = new GDT_GeneralConfig__c(name = 'BMC_RF_ServiceDesk_Client_Profile', GDT_Value__c = '00eD0000001PqPY');
        gconfigs.add(clientProfile);

        GDT_GeneralConfig__c clientProfileOnly = new GDT_GeneralConfig__c(name = 'BMC_RF_ServiceDesk_Client_Only_Profile', GDT_Value__c = '00e1i000000YLVW');
        gconfigs.add(clientProfileOnly);

        GDT_GeneralConfig__c cRECIPIENTS_ADDRESSES = new GDT_GeneralConfig__c(name = 'GDT_User_Email_Notification', GDT_Value__c = 'test@test.com');
        gconfigs.add(cRECIPIENTS_ADDRESSES);

        insert gconfigs;
    }

    public static User createUserWithProfile(String alias, String profileName){
        Profile profile = new Profile();
        if(profileName != '')
            profile = [select id from profile where name=: profileName];
        else
            profile = [select id from profile where name='Standard User'];
            
        User user = new User(alias = alias, email=alias + '@1dev.com', 
            emailencodingkey='UTF-8', firstname=alias, lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = profile.Id, 
            timezonesidkey='Europe/London', username=alias + '@esn.pernod-ricard.com');
        return user;
    }
    
}