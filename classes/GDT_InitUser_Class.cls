/**
 * @name GDT_InitUser_Class
 * @description
 * Class that contains the logic for GDT init user process && ESN chatter processes
 * @author Bruno Vuono/ Sophie Ducatel
 */
public with sharing class GDT_InitUser_Class {

    /* Variable Declaration */
    //Map for the affiliates list (CS: GDT_CustomSettings_ADDomaine__c)
    public static Map<String,String> userAffiliateGroups {get;set;}
    //Map for the companies list (CS: GDT_CustomSettings_CompanyName__c)
    public static Map<String, String> userCompaniesNames {get;set;}
    //Map for the Roles list (CS: Default_Role_Id__c)
    public static Map<String, String> userDefaultRoles {get;set;}
    //Map for the Profiles list (CS: Default_Profile_Id__c)
    public static Map<String, String> userDefaultProfiles {get;set;}
    //Map for the Profiles list for External Users(CS: Default_Profile_Ext_Id__c)
    public static Map<String, String> userDefaultProfilesExt {get;set;}
    //Map for the timeZone/Language list (CS: GDT_CustomSettings_TZone_Lang_Currency__c)
    public static Map<String, GDT_CustomSettings_TZone_Lang_Currency__c> userDefaultTZ {get;set;}
    //Set for the domains list (CS: GDT_InitUser_PernodRicardUser__c)
    public static Set<String> pernodRicardDomains{get;set;}


    //Constants for the trigger bypass values
    public static String TRIGGER_AUTOFOLLOW_NAME = 'Autofollow_User_InsertUpdate';
    public static String TRIGGER_AUTOJOIN_NAME = 'AutoJoin_User_InsertUpdate';
    public static String TRIGGER_CHATTER_SETTINGS = 'ChatterEmailSettings';

    //Current User
    public static User thisUser{get;set;}
    
    
    //init trigger variables
    public void initTrigger(){
        initTriggerProcess();
    }

    /**
     * Instanciate and Populate class maps/sets 
     * @return void
     */
    public static void initTriggerProcess(){
        //Instanciate all class variables
        pernodRicardDomains = new Set<String>();
        userAffiliateGroups = new Map<String,String>();
        userCompaniesNames = new Map<String,String>();
        userDefaultRoles = new Map<String,String>();
        userDefaultProfiles = new Map<String,String>();
        userDefaultProfilesExt = new Map<String,String>();
        userDefaultTZ = new Map<String,GDT_CustomSettings_TZone_Lang_Currency__c>();


        //Populate pernodRicardDomains variable with the domains from CS: GDT_InitUser_PernodRicardUser__c
        for(GDT_InitUser_PernodRicardUser__c puser : [SELECT Contains_UserName__c FROM GDT_InitUser_PernodRicardUser__c]){
           pernodRicardDomains.add(puser.Contains_UserName__c); 
        }
        //Populate current user
        thisUser = [ SELECT Id,BypassTriggers__c FROM User WHERE Id =: UserInfo.getUserId()];
        getuUserCompaniesNames();
        getUserAffiliateGroups();
        getTZLanguage();

    }

    /**
     * Populate userCompaniesNames variable with company names(field: CompanyName__c)
     * Populate userDefaultRoles variable with Role Ids(field: Default_Role_Id__c)
     * Populate userDefaultProfiles variable with Profile ids(field: Default_Profile_Id__c)
     * @return Void
     */
    public static void getuUserCompaniesNames(){
        for (GDT_CustomSettings_CompanyName__c comp : [SELECT  CompanyName__c,CompanyNameUser__c,Default_Role_Id__c, Default_Profile_Id__c, Default_Profile_Ext_Id__c, Default_Profile_Ext_Name__c FROM GDT_CustomSettings_CompanyName__c]){
            userCompaniesNames.put(comp.CompanyNameUser__c ,comp.CompanyName__c);
            userDefaultRoles.put(comp.CompanyNameUser__c, comp.Default_Role_Id__c);
            userDefaultProfiles.put(comp.CompanyNameUser__c, comp.Default_Profile_Id__c);
            userDefaultProfilesExt.put(comp.CompanyNameUser__c, comp.Default_Profile_Ext_Id__c);
        }
    }


    /**
     * Populate userDefaultTZ variable with GDT_CustomSettings_TZone_Lang_Currency__c(field: timeZone__c)
     * Populate userDefaultLanguage variable with GDT_CustomSettings_TZone_Lang_Currency__c(field: language__c)
     * Populate userDefaultLocale variable with GDT_CustomSettings_TZone_Lang_Currency__c(field: locale__c)
     * @return Void 
     */
    public static void getTZLanguage(){
        for (GDT_CustomSettings_TZone_Lang_Currency__c comp : [SELECT country__c,timeZone__c,language__c,Locale__c,currency__c FROM GDT_CustomSettings_TZone_Lang_Currency__c]){
            userDefaultTZ.put(comp.country__c.toLowerCase() ,comp);
        }
    }

    /**
     * Populate userAffiliateGroups variable with affiliates names(field: AffiliateGroup__c)
     * @return Void
     */
    public static void getUserAffiliateGroups(){
        for (GDT_CustomSettings_ADDomaine__c aDDomain : [SELECT AffiliateGroup__c, ADDomaine__c FROM GDT_CustomSettings_ADDomaine__c]){
            userAffiliateGroups.put(ADDomain.ADDomaine__c ,ADDomain.AffiliateGroup__c);
        }
    }


    /**
     * Method that manage the before action. 
     * Calls the Role assignment, profile assignment and 
     * @param newUsers LIST<User>
     * @return Void
     */
    public void InitUserBefore(List<User> newUsers) {
        for(User newUser : newUsers){
            //Check if the user is a PR employee and if is an active user
            if(PernodRicardUser(newUser) == true && newUser.isActive == true ){
                //If the user does not have a Role
                //Assign a role to the user
                AssignRole(newUser);
                //Assign a profile to the user
                AssignDefaultProfile(newUser);
                assignLanguage(newUser);
                assignTimeZone(newUser);
                assignLocale(newUser);
                assignCurrency(newUser);

                /* SETUP for REMEDY Client */
                newUser.BMC_RF_ServiceDesk_Client__c = true;
            }
        }
    }

    /**
     * Check if the user is Pernod Ricard employee
     * @param  user User
     * @return True = PR Employee | False = No PR Employee
     */
    public Static Boolean PernodRicardUser(User user){
        try{
            String usernameDomain = '@' + user.UserName.split('@')[1];
            String emailDomain = '@' + user.email.split('@')[1];

            if(pernodRicardDomains.contains(usernameDomain) && pernodRicardDomains.contains(emailDomain) && (!user.IsSFDCOnlyAccount__c && !user.DoNotFreeze__c)){
                return true;
            }
            return false;
        }catch(Exception e){
            return false;
        }
    }


    /**
     * Check if the user is an external employee
     * @param  user User
     * @return True = username ends with "-ext"
     */
    public Static Boolean isExternalUser(User user){
        try{
            String username = '@' + user.UserName.split('@')[0];
            return username.endsWithIgnoreCase('-ext');
            
        }catch(Exception e){
            return false;
        }
    }

    /**
     * Assign a default role. First check on the custom setting GDT_CustomSettings_CompanyName__c 
     * with the company of the user and else it uses the default Role from the CS: GDT_GeneralConfig__c
     * @param  user User
     * @return void
     */
    public void AssignRole(User newUser){
        /* Variable Declaration */
        String idRoleToAssign;

         /* Get ID Role */
        try {
            //get the Role from the userDefaultRoles map
            idRoleToAssign = userDefaultRoles.get(newUser.CompanyName);
   
        } catch(Exception e) {
            idRoleToAssign = null;
            System.debug(e.getMessage());
        }
        try {
            if(idRoleToAssign == null || idRoleToAssign == '') {
               //get the default Role from the CS GDT_GeneralConfig__c
                idRoleToAssign = GDT_GeneralConfigDAO.getValueAsStringArray('USER_DEFAULT_ROLE', ',',false)[0];
            }
            /* Assign Role */
            newUser.UserRoleId = idRoleToAssign;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

     /**
     * Assign a default profile. First check on the custom setting GDT_CustomSettings_CompanyName__c 
     * with the company of the user and else it uses the default Profile from the CS: GDT_GeneralConfig__c
     * @param  user User
     * @return void
     */
    public void AssignDefaultProfile(User newUser){

        /* Variable Declaration */
        String idProfileToAssign;

         /* Get ID Profile */
        try {
            if(isExternalUser(newUser)){
                idProfileToAssign = userDefaultProfilesExt.get(newUser.CompanyName);
            }
            if(idProfileToAssign == null || idProfileToAssign == ''){
                //get the Profile from the userDefaultProfiles map
                idProfileToAssign = userDefaultProfiles.get(newUser.CompanyName);
            }
        } catch(Exception e) {
            idProfileToAssign = null;
            System.debug(e.getMessage());
        }
        try {
            if(idProfileToAssign == null || idProfileToAssign == '') {
               //get the default Role from the CS GDT_GeneralConfig__c
                idProfileToAssign = GDT_GeneralConfigDAO.getValueAsStringArray('USER_DEFAULT_PROFILE', ',',false)[0];
            }

            /* Assign Profile */
            newUser.profileId = idProfileToAssign;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }


     /**
     * Assign timezone
     * @param newUser User
     */
    public void assignTimeZone(User newUser) {
        /* Variable Declaration */
        String idTimeZoneToAssign;

         /* Get ID Profile */
        try {
            //get the Profile from the userDefaultProfiles map
            String userCountry = newUser.country.toLowerCase();
            idTimeZoneToAssign = userDefaultTZ.get(userCountry).timeZone__c;
        } catch(Exception e) {
            idTimeZoneToAssign = null;
            System.debug(e.getMessage());
        }
        try {
            if(idTimeZoneToAssign == null || idTimeZoneToAssign == '') {
               //get the default Role from the CS GDT_GeneralConfig__c
                idTimeZoneToAssign = GDT_GeneralConfigDAO.getValueAsStringArray('USER_DEFAULT_TIMEZONE', ',',false)[0];
            }

            /* Assign Profile */
            newUser.TimeZoneSidKey = idTimeZoneToAssign;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

         /**
     * Assign language
     * @param newUser User
     */
    public void assignLanguage(User newUser) {
        /* Variable Declaration */
        String idLanguageToAssign;

         /* Get ID Profile */
        try {
            //get the Profile from the userDefaultProfiles map
            String userCountry = newUser.country.toLowerCase();
            idLanguageToAssign = userDefaultTZ.get(userCountry).language__c;
        } catch(Exception e) {
            idLanguageToAssign = null;
            System.debug(e.getMessage());
        }
        try {
            if(idLanguageToAssign == null || idLanguageToAssign == '') {
               //get the default Role from the CS GDT_GeneralConfig__c
                idLanguageToAssign = GDT_GeneralConfigDAO.getValueAsStringArray('USER_DEFAULT_LANGUAGE', ',',false)[0];
            }

            /* Assign Profile */
            newUser.LanguageLocaleKey = idLanguageToAssign;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }


    /* Assign locale
     * @param newUser User
     */
    public void assignLocale(User newUser) {
        /* Variable Declaration */
        String idLocaleToAssign;

         /* Get ID Profile */
        try {
            //get the Profile from the userDefaultProfiles map
            String userCountry = newUser.country.toLowerCase();
            idLocaleToAssign = userDefaultTZ.get(userCountry).locale__c;
        } catch(Exception e) {
            idLocaleToAssign = null;
            System.debug(e.getMessage());
        }
        try {
            if(idLocaleToAssign == null || idLocaleToAssign == '') {
               //get the default Role from the CS GDT_GeneralConfig__c
                idLocaleToAssign = GDT_GeneralConfigDAO.getValueAsStringArray('USER_DEFAULT_LOCALE', ',',false)[0];
            }

            /* Assign Profile */
            newUser.localeSIdKey = idLocaleToAssign;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    /* Assign Currency
     * @param newUser User
     */
    public void assignCurrency(User newUser) {
        /* Variable Declaration */
        String idCurrencyToAssign;

         /* Get ID Profile */
        try {
            //get the Profile from the userDefaultProfiles map
            String userCountry = newUser.country.toLowerCase();
            idCurrencyToAssign = userDefaultTZ.get(userCountry).currency__c;
        } catch(Exception e) {
            idCurrencyToAssign = null;
            System.debug(e.getMessage());
        }
        try {
            if(idCurrencyToAssign == null || idCurrencyToAssign == '') {
               //get the default Role from the CS GDT_GeneralConfig__c
                idCurrencyToAssign = GDT_GeneralConfigDAO.getValueAsStringArray('USER_DEFAULT_CURRENCY', ',',false)[0];
            }

            /* Assign Profile */
            newUser.DefaultCurrencyIsoCode = idCurrencyToAssign;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**
     * Assign chatter email settings
     * @param newUsers List<User>
     */
    public void AssignChatterEmailSettings(List<User> newUsers) {
        if(newUsers != null && !bypassTrigger(thisUser,TRIGGER_CHATTER_SETTINGS)){  
             for (User u : newUsers) {
                // Receive Chatter emails
                u.USERPREFERENCESDISABLEALLFEEDSEMAIL = false;
                // Follows me
                u.USERPREFERENCESDISABLEFOLLOWERSEMAIL = true;
                // Posts on my profile
                u.USERPREFERENCESDISABLEPROFILEPOSTEMAIL = true;
                // Comments on my status or a change I made
                u.USERPREFERENCESDISABLECHANGECOMMENTEMAIL = true;
                // Comments after me
                u.USERPREFERENCESDISABLELATERCOMMENTEMAIL = true;
                // Comments on a post on my profile
                u.USERPREFERENCESDISPROFPOSTCOMMENTEMAIL = true;
                // XX
                u.USERPREFERENCESCONTENTNOEMAIL = true;
                // XX
                u.USERPREFERENCESCONTENTEMAILASANDWHEN = true;
                // Mentions me in a post
                u.USERPREFERENCESDISABLEMENTIONSPOSTEMAIL = false;
                // Mentions me in a comment
                u.USERPREFERENCESDISMENTIONSCOMMENTEMAIL = false;
                // Comments on an item I like
                u.USERPREFERENCESDISCOMMENTAFTERLIKEEMAIL = true;
                // Likes a post or a comment I made
                u.USERPREFERENCESDISABLELIKEEMAIL = true;
                // Sends me a message
                u.USERPREFERENCESDISABLEMESSAGEEMAIL = false;
                // Comments on an item I bookmarked
                u.USERPREFERENCESDISABLEBOOKMARKEMAIL = true;
                // Shares a post I made 
                u.USERPREFERENCESDISABLESHAREPOSTEMAIL= true; 
            }
        }
    }


     /**
     * Logic for the after action.
     * Executes the chatter groups assignation, permission sets assignation and public groups assignation
     * @param Map<Id, sObject> oldUsers,Map<Id, sObject> newUsers
     */
    public void InitUserAfter(Map<Id, sObject> oldUsers,Map<Id, sObject> newUsers) {
        AssignChatterGroup(oldUsers,newUsers);
        AssignPermissionSets(newUsers.values());  
        AssignPublicGroup(newUsers.values());
    }

     /**
     * Method that add the users to the chatter groups usign the company from the user matching the groups on the CS: GDT_InitUser_ListChatterGroup__c
     * @param Map<Id,SObject> oldUsers, Map<Id,SObject> newUsers
     */
    public Static void AssignChatterGroup(Map<Id,SObject> oldUsers, Map<Id,SObject> newUsers) {
            Map<String, String> groupsMap = new Map<String,String>();
            List<Id> userIds = new List<Id>();
            List<Id> groupIds = new List<Id>();
            Map<String, GDT_InitUser_ListChatterGroup__c> mapChatterGroupsName = GDT_InitUser_ListChatterGroup__c.getAll();

            String userCompanyName;
            String externalProfileId = EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c;


            for(String newUserId : newUsers.keySet()){
                User oldU =  oldUsers == null ? null : (User)oldUsers.get(newUserId);
                User newU =  (User)newUsers.get(newUserId);
                // If Pernod Ricard ESN user
                if(PernodRicardUser(newU) && newU.profileId != externalProfileId && ((oldU != null && newU.isActive && !oldU.isActive) || (newU.isActive))){
                    // Get Company Name's user
                    try {
                        if(userCompaniesNames.containsKey(newU.CompanyName)){
                            userCompanyName = userCompaniesNames.get(newU.CompanyName);
                        }
                    } catch(Exception e) {
                        userCompanyName = null;
                        System.debug(e.getMessage());
                    }

                    for(GDT_InitUser_ListChatterGroup__c pGr : mapChatterGroupsName.values()){
                        if((pGr.GDT_InitUser_CompanyName__c == 'ALL' ) || (pGr.GDT_InitUser_CompanyName__c == userCompanyName && userCompanyName != null)) {
                            try {
                                userIds.add(newU.Id);
                                groupIds.add(pGr.GDT_Chatter_Group_Id__c); 
                            } catch(Exception e) {
                                System.debug(e.getMessage());
                            }
                        }
                    }
                }
            }
            if(userIds.size() > 0)AssignChatterGroupFuture(userIds,groupIds);
    }


    /**
     * Method to insert the chatter group member objects
     * @param List<Id> userIds, List<Id> groupIds
     */
    @future
    public static void AssignChatterGroupFuture(List<Id> userIds, List<Id> groupIds)  {
        List<CollaborationGroupMember> memberslist = new List<CollaborationGroupMember>();

        for(Integer i = 0; i < userIds.size();i++){
            memberslist.add(new CollaborationGroupMember(MemberId=userIds[i], CollaborationGroupId = groupIds[i])); 
        }
        processResults(memberslist, 'ChatterGroupAssigment', 'Chatter Group');
    }


     /**
     * Assign Permission Sets depends on the CustomSettings GDT_InitUser_ListPermissionSet__c
     * @param newUser User
     */
    public void AssignPermissionSets(List<User> newUsers) {
        Map<String, String> permissionSetMap = new Map<String,String>();
        Map<String, GDT_InitUser_ListPermissionSet__c> mapPermissionSetName = GDT_InitUser_ListPermissionSet__c.getAll();
        List<Id> userIds = new List<Id>();
        List<Id> permissionsIds = new List<Id>();

        // PermissionSet Listing
        String userAffiliateGroup;
        String userCompanyName;


        for(User newUser : newUsers){
            // If Pernod Ricard ESN user
             system.debug('aaaa ' + PernodRicardUser(newUser));
            if(PernodRicardUser(newUser) == true && newUser.isActive == true ){
                system.debug('aaaa ' + newUser);
                try{
                    String substringDomainStr = SubstringADDomaineUser(newUser);
                    if(userAffiliateGroups.containsKey(substringDomainStr)){
                        userAffiliateGroup = userAffiliateGroups.get(substringDomainStr);
                    }
                } catch(Exception e) {
                    userAffiliateGroup = null;
                    System.debug(e.getMessage());
                }
                // Get Company Name's user
                try {
                    if(userCompaniesNames.containsKey(newUser.CompanyName)){
                        userCompanyName = userCompaniesNames.get(newUser.CompanyName);
                    }
                } catch(Exception e) {
                    userCompanyName = null;
                    System.debug(e.getMessage());
                }

                for(GDT_InitUser_ListPermissionSet__c pSet : mapPermissionSetName.values()){
                    Set<String> excludedProfiles = new Set<String>();
                    Set<String> excludedCompanies = new Set<String>();
                    try{
                        if(pSet.GDT_InitUser_Excluded_Profiles__c != null && pSet.GDT_InitUser_Excluded_Profiles__c != ''){
                            excludedProfiles = new Set<String>(pSet.GDT_InitUser_Excluded_Profiles__c.split(',', 0));
                        }
                        if(pSet.GDT_InitUser_Excluded_Companies__c != null && pSet.GDT_InitUser_Excluded_Companies__c != ''){
                            excludedCompanies = new Set<String>();
                            for(String str : pSet.GDT_InitUser_Excluded_Companies__c.split(',', 0)){
                                excludedCompanies.add(str.toLowerCase());
                            }
                        }
                    } catch(Exception e) {
                        System.debug(e.getMessage());
                    }
			
                    if(!excludedProfiles.contains(newUser.profileId) && (userCompanyName != null && !excludedCompanies.contains(userCompanyName.toLowerCase())) && (pSet.GDT_InitUser_Affiliate_Group__c == 'ALL' && pSet.GDT_InitUser_Company_Name__c == 'ALL') 
                        || (pSet.GDT_InitUser_Affiliate_Group__c == 'ALL' && pSet.GDT_InitUser_Company_Name__c == userCompanyName && userCompanyName != null) 
                        || (pSet.GDT_InitUser_Affiliate_Group__c == userAffiliateGroup && pSet.GDT_InitUser_Company_Name__c == 'ALL') 
                        || (pSet.GDT_InitUser_Affiliate_Group__c == userAffiliateGroup && pSet.GDT_InitUser_Company_Name__c == userCompanyName && userCompanyName != null)) {
                        try {
                            userIds.add(newUser.Id);
                            permissionsIds.add(pSet.GDT_Permission_Set_Id__c); 
                        } catch(Exception e) {
                            System.debug(e.getMessage());
                        }
                    }
                }
            }
        }
       if(userIds.size() > 0)AssignPermissionSetsFuture(userIds,permissionsIds);
    }

    /**
     * Method to insert permission sets related to the user
     * @param List<Id> userIds, List<Id> permsIds
     */
     @future
    public static void AssignPermissionSetsFuture(List<Id> userIds, List<Id> permsIds)  {
        List<PermissionSetAssignment> memberslist = new List<PermissionSetAssignment>();

        for(Integer i = 0; i < userIds.size();i++){
            memberslist.add(new PermissionSetAssignment(AssigneeId=userIds[i], PermissionSetId = permsIds[i])); 
        }
        processResults(memberslist, 'PermissionSetAssignment', 'Permission Set');
    }



    /**
     * Assign Public Groups
     * @param List<User> newUsers
     */
    public Static void AssignPublicGroup(List<User> newUsers) {

        Map<String, String> groupsMap = new Map<String,String>();
        Map<String, GDT_InitUser_ListPublicGroup__c> mapGroupsName = GDT_InitUser_ListPublicGroup__c.getAll();
        List<Id> userIds = new List<Id>();
        List<Id> groupIds = new List<Id>();

        String userCompanyName;

        for(User newUser : newUsers){
            // If Pernod Ricard && is active
            if(PernodRicardUser(newUser) == true && newUser.isActive == true ){
                // Get Company Name's user
                try {
                    if(userCompaniesNames.containsKey(newUser.CompanyName)){
                        userCompanyName = userCompaniesNames.get(newUser.CompanyName);
                    }
                } catch(Exception e) {
                    userCompanyName = null;
                    System.debug(e.getMessage());
                }

                for(GDT_InitUser_ListPublicGroup__c pGr : mapGroupsName.values()){
                    if((pGr.GDT_InitUser_CompanyName__c == 'ALL' ) || (pGr.GDT_InitUser_CompanyName__c == userCompanyName && userCompanyName != null)) {
                        try {
                            userIds.add(newUser.Id);
                            groupIds.add(pGr.GDT_public_Group_Id__c); 
                        } catch(Exception e) {
                            System.debug(e.getMessage());
                        }
                    }
                }
            }
        }

        if(userIds.size() > 0)AssignPublicGroupFuture(userIds,groupIds);
    }


     /**
     * Method to insert public group assignment
     * @param List<Id> userIds, List<Id> groupIds
     */
     @future
    public static void AssignPublicGroupFuture(List<Id> userIds, List<Id> groupIds)  {
        List<GroupMember> memberslist = new List<GroupMember>();

        for(Integer i = 0; i < userIds.size();i++){
            memberslist.add(new GroupMember(UserOrGroupId=userIds[i], groupId = groupIds[i])); 
        }
        processResults(memberslist, 'PublicGroupAssigment', 'Public Group');
    }



    //Autofollow process checking the users with autofollow__c = true
    public void Autofollow_User(Map<Id,SObject> oldUsers, Map<Id,SObject> newUsers){
        if(newUsers != null && !bypassTrigger(thisUser,TRIGGER_AUTOFOLLOW_NAME)){  
            List<String> usersToTreatID_upd = new List<String>();
            String externalProfileId = EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c;
            if (oldUsers != null) {
                for(String newUserId : newUsers.keySet()){
                    User oldU =  (User)oldUsers.get(newUserId);
                    User newU =  (User)newUsers.get(newUserId);
                    //If the fields are different        
                    if (oldU.isActive != newU.isActive && newU.isActive && newU.ProfileId != externalProfileId) {
                        usersToTreatID_upd.add(newUserId);
                    }
                }
            }else{
                for(String newUserId : newUsers.keySet()){
                     User newU = (User)newUsers.get(newUserId);
                    if (newU.IsActive == true && newU.ProfileId != externalProfileId) {                   
                        usersToTreatID_upd.add(newUserId);
                    }
                }
            }
            System.debug('#### AutoFollow : user to treat[insert/update] : '+usersToTreatID_upd.size());
            if(usersToTreatID_upd.size() != 0)
                AutofollowUsers(usersToTreatID_upd);

        }
    }

    //This method checks if the user's AUTO FREEZE field(AutoFreeze__c) was updated and executes the autoFreeze logic.
    public void autoFreeze(Map<Id,SObject> oldUsers, Map<Id,SObject> newUsers){
        Set<String> allowedUsers = GDT_GeneralConfigDAO.getValueAsStringSet('GDT_InitUser_AutoFreeze_Execution',',',false);

        if(allowedUsers != null && allowedUsers.contains(UserInfo.getUserId()) && newUsers != null){
            Map<String, UserLogin> userLogins = new Map<String, UserLogin>();
            for(UserLogin ulog : [SELECT IsFrozen,UserId FROM UserLogin WHERE UserId in: newUsers.keyset()]){
                userLogins.put(ulog.userId, ulog);
            }

            if(newUsers != null){
                for(User usr: (List<User>)newUsers.values()){
                    User newUser = (User)newUsers.get(usr.id);
                    User oldUser = (User)oldUsers.get(usr.id);
                    //Check if the autoFreeze value has been changed.
                    if(oldUser.AutoFreeze__c != newUser.AutoFreeze__c){
                        //if the autofreeze changed from TRUE to FALSE we active the user and unfreeze it.
                        if(!newUser.AutoFreeze__c){
                            newUser.isActive = true;
                            userLogins.get(newUser.id).IsFrozen = false;
                        }else{
                            //if the autofreeze changed from FALSE to TRUE => we have to freeze the user
                            //Except that the user bypass the freeze (DoNotFreeze__c = TRUE)
                            if(newUser.DoNotFreeze__c == False){
                                userLogins.get(newUser.id).IsFrozen = true;
                            }
                        }
                    }
                }
            }
            update userLogins.values();
        }
    }

    //This method executes the init process(user creation) to the users that changed GDT_ReinitUser__c from FALSE to TRUE
    //Init user => Assign Chatter Email Settings, Assign Role, Assign Profile, Assign permission sets, Assign public groups, Assign chatter groups
    public void reInitUsers(Map<Id,SObject> oldUsers, Map<Id,SObject> newUsers){
        Map<Id,User> toUpdate = new Map<Id,User>();

        if(newUsers != null){
            
            for(User usr: (List<User>)newUsers.values()){
                User newUser = (User)newUsers.get(usr.id);
                User oldUser = (User)oldUsers.get(usr.id);
                system.debug('bbb ' + oldUser.GDT_ReinitUser__c + ' ' + newUser.GDT_ReinitUser__c);
                if(oldUser.GDT_ReinitUser__c != newUser.GDT_ReinitUser__c){
                    if(newUser.GDT_ReinitUser__c){
                        newUser.UserRoleId = null;
                       toUpdate.put(newUser.Id, newUser);
                    }
                }
                usr.GDT_ReinitUser__c = false;
            }
        }
        if(toUpdate.size() > 0){
            InitUserBefore(toUpdate.values());
            AssignChatterEmailSettings(toUpdate.values());
            InitUserAfter(oldUsers,toUpdate);
        }
    }


    @future 
    public static void AutofollowUsers(List<Id> userIds) {  
        /* Variables definition */     
        // set up the users that should automatically be followed
        List<user> usersfollowed=[Select Id,IsActive From user Where autofollow__c = true AND IsActive = true];
        // Initiate the list of Entity Subscription that will be created. 
        List<EntitySubscription> entSubs=new List<EntitySubscription>();
        // Get the admin Email //
        String emailAdmin = Utils_UsefulMethods.adminEmailOfPRCustomSetting();

        /* Creation of subscriptions */
        // loop the users that have been created
        for (Id userId : userIds) {
            // Loop through all users to follow       
            for (user ufl : usersfollowed){
                // check if user to follow is not the same as the user followed
                if(userId != ufl.Id){
                    EntitySubscription entSub = new EntitySubscription (parentId = ufl.Id, SubscriberId = userId);
                    System.debug('#### Autofollow : add entsub '+ufl.Id+'/'+userId);
                    entSubs.add(entSub);
                }
            }
        }
        Database.SaveResult[] results = Database.Insert(entSubs, false);
        
        // Check results of insert //
        String debugMsg = '';
        if (results != null){
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    Database.Error[] errs = result.getErrors();
                    for(Database.Error err : errs)
                        if(''+err.getStatusCode() != 'DUPLICATE_VALUE')
                            debugMsg += '\n' +'#### AP01_Autofollow_EntitySubscription -- EXECUTE Error : '+err.getStatusCode() + ' - ' + err.getMessage();
                }
            }
        }
        // If error, notify the administrator //
        if(debugMsg != ''){
            System.debug(debugMsg);
        }
    }

   

    /**
     * Substring AD Domain
     * @param  u User
     * @return Valued of the AD Domain cleaned
     */
    public Static String SubstringADDomaineUser(User u) {
        try {
            return (u.ADDomainUser__c).substring(0, ((u.ADDomainUser__c).indexOf('\\',0)));
        } catch(Exception e) {
            System.debug(e.getMessage());
            return u.ADDomainUser__c;
        }
    }


    /**
     * Checks if a trigger have to be bypassed for the current user
     * @param  User usr , String triggerName
     * @return true(bypass trigger) | false(no bypass)
     */
    public static Boolean byPassTrigger(User usr , String triggerName){
        return (usr != null && usr.BypassTriggers__c != null && usr.BypassTriggers__c.contains(triggerName));
    }

    /**
     * Method to insert generic sObject list and print on screen the errors
     * @param  List<sObject> entMembers,String objType, String subject
     * @return void
     */
    public static void processResults(List<sObject> entMembers,String objType, String subject){

        String debugMsg = '';
        Database.SaveResult[] results;
        if(entMembers.size() != 0)
            results = Database.Insert(entMembers, false);  
             
        if (results != null){
            for (Database.SaveResult result : results) {
                System.debug('####### '+result.isSuccess());
                if (!result.isSuccess()) {
                    Database.Error[] errs = result.getErrors();
                    for(Database.Error err : errs){
                        System.debug('#### EXECUTE Error : '+err.getStatusCode() + ' - ' + err.getMessage());
                        if(''+err.getStatusCode() != 'DUPLICATE_VALUE')
                            debugMsg += '\n #### EXECUTE Error : '+err.getStatusCode() + ' - ' + err.getMessage();
                    }
                }
            }
        }
        
        if(debugMsg != ''){
            System.debug('####### '+debugMsg);
        }
    }




}