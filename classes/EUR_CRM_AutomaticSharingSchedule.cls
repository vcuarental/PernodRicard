global class EUR_CRM_AutomaticSharingSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
      	runOperation();
    }
    public static void runOperation() {
        List<String> acceptedStatus = new List<String>();
        String s_waiting = EUR_CRM_AutomaticSharing.STATUS_WAITING,
            s_delete = EUR_CRM_AutomaticSharing.STATUS_DELETE,
            s_shared = EUR_CRM_AutomaticSharing.STATUS_SHARED;
        
        //First retrieve only the AS that need an operation
        List<EUR_CRM_Automatic_Sharing__c> sharings = [
            SELECT Id, Name, EUR_CRM_ATG__c, EUR_CRM_Status__c,
            (SELECT Id, EUR_CRM_User__c, EUR_CRM_Access_Level__c, EUR_CRM_AS__c, EUR_CRM_To_Be_Deleted__c FROM Automatic_Sharing_Users__r)
            FROM EUR_CRM_Automatic_Sharing__c 
            WHERE EUR_CRM_Status__c IN (:s_waiting, :s_delete, :s_shared)
        ];

        runOperation(sharings);
    }
    /*
     * Read the comment for the details of each steps
     * 
     * VERY IMPORTANT: 
     * - DO NOT ALLOW PARTIAL SUCCESS, 
     *	 TO KEEP THE STATUS/RECORDS ALIGNED EITHER EVERYTHING WORK OR NOTHING
     *
     * If form performance reason we need to make a batch then we should make a batch that treat
     * just a few records (Start QUERY LIMIT 5 ORDER BY LASTModifiedDate ASC)
     * And run the batch many time in one day
     */ 
    public static void runOperation(List<EUR_CRM_Automatic_Sharing__c> sharings) {
        String s_waiting = EUR_CRM_AutomaticSharing.STATUS_WAITING,
            s_delete = EUR_CRM_AutomaticSharing.STATUS_DELETE,
            s_shared = EUR_CRM_AutomaticSharing.STATUS_SHARED;
            
        //Will be used to create the AG/AGU related to the AS/ASU
        Map<Id, EUR_CRM_AccountGroup__c> AGS_To_Upsert = new Map<Id, EUR_CRM_AccountGroup__c>();
        Map<String, EUR_CRM_AccountGroupUser__c> AGUS_To_Upsert = new Map<String, EUR_CRM_AccountGroupUser__c>();
        
        //Use later on to create Automatic Sharing Link in order to know 
        //which ASU has been shared with which account already
        Map<String, Set<Id>> AGU_ASU = new Map<String, Set<Id>>();
        
        //Script is allowed to change the status to Account Groups Created
        EUR_CRM_AutomaticSharing.byPassRules = true;
        
        //Retrieve the Account Target Group IDs in order to make the query on all the accounts to be shared
		Set<Id> atgIds = new Set<Id>();
        //Keep automatic sharing ID
        Set<Id> asIds = new Set<Id>();
        //To retrieve existing AG/AGU
        Set<Id> accIds = new Set<Id>();
        
        for(EUR_CRM_Automatic_Sharing__c s : sharings) {
            asIds.add(s.Id);
            atgIds.add(s.EUR_CRM_ATG__c);
        }
        
        //Map Def: ATG ID => List<Account In Target Group>
        //Account in Target Group here is called "accounts" for simplicity
        Map<Id, List<EUR_CRM_Account_in_Target_Group__c>> atg_accounts = EUR_CRM_AutomaticSharing.getAccountsInATG(atgIds);
        
        for(List<EUR_CRM_Account_in_Target_Group__c> accs : atg_accounts.values()) {
            for(EUR_CRM_Account_in_Target_Group__c acc: accs) {
                accIds.add(acc.EUR_CRM_Account__c);
            }
        }
        
        
        Set<Id> userIds = new Set<Id>();
        for(EUR_CRM_Automatic_Sharing__c a : sharings) {
            for(EUR_CRM_Automatic_Sharing_User__c asu : a.Automatic_Sharing_Users__r) {
                userIds.add(asu.EUR_CRM_User__c);
            }
        }
        
        /* Needed for priority rules, 
         * if it is already shared in Edit and a new sharing is asked in Read then we shouldn't change anything 
         * ID ACC => ID USER => ACCESS LEVEL of AS in status Account Groups Created 
         */
        Map<Id, Map<Id, String>> alreadySharedAccess = EUR_CRM_AutomaticSharing.get_Already_Shared_Access(accIds, userIds);
        
        /*
         * We do not want to create account group that already exist, ONE ACCOUNT = ONE ACCOUNT GROUP
         */
        Map<Id, EUR_CRM_AccountGroup__c> existingAGs = EUR_CRM_AutomaticSharing.getExistingAGS(accIds);
        
        //For each automatic sharing
        for(EUR_CRM_Automatic_Sharing__c s : sharings) {
            //We don't wanna perform any action on the sharing in status Account Groups Created
            if(s.EUR_CRM_Status__c == s_waiting || s.EUR_CRM_Status__c == s_delete) {

                //Retrieve the list of "accounts" in the map previously built
                List<EUR_CRM_Account_in_Target_Group__c> accounts = atg_accounts.get(s.EUR_CRM_ATG__c);
                //get the users of this AS
                List<EUR_CRM_Automatic_Sharing_User__c> users = s.Automatic_Sharing_Users__r;
                
                if(users != null && users.size() > 0 && accounts != null) {
                    //now for each account we will try to create/update an AG & AGU
                    for(EUR_CRM_Account_in_Target_Group__c a : accounts) {
                        //Retrieve the existing AG is it exists
                        EUR_CRM_AccountGroup__c existingAG = existingAGS.get(a.EUR_CRM_Account__c);
                        //Build the Account Group for each account in the ATG
                        //It will simply take the existing one and update the ID if it already exist 
                        //and automatically setup the status to Normal
                        EUR_CRM_AccountGroup__c ag = EUR_CRM_AutomaticSharing.buildAccountGroup(AGS_To_Upsert.get(a.EUR_CRM_Account__c), existingAG, a);
                        AGS_To_Upsert.put(a.EUR_CRM_Account__c, ag);
                
                        //Build all the Account Group User for each user that this Account should be shared with
                        EUR_CRM_AutomaticSharing.transform_ASU_in_AGU(AGU_ASU, AGUS_To_Upsert, existingAG, s, a, users, alreadySharedAccess);
                        
                    }
                }
            }
        }
        
        //TO prevent always updating all records at every batch, we upsert only:
        // - Missing records
        // - Status TO Delete record
        List<EUR_CRM_AccountGroup__c> minimum_AGs = new List<EUR_CRM_AccountGroup__c>();
        for(EUR_CRM_AccountGroup__c ag : AGS_To_Upsert.values()) {
            if(ag.Id == null) {
                minimum_AGs.add(ag);
            } else {
                System.debug('AG already exist');
                if(ag.EUR_CRM_Status__c == 'To Delete') {
                    System.debug('AG status is To Delete => So we update to Normal');
                    ag.EUR_CRM_Status__c = 'Normal';//Update the status
                    minimum_AGs.add(ag);
                }
            }
        }
        
        System.debug('AG TO UPSERT: ' + minimum_AGs.size() + ' instead of ' + AGS_To_Upsert.values().size());
        //Upsert Account Groups 
        //The map AGS_To_Upsert will have the ID populated as well because of references
        upsert minimum_AGs Id;
        

       	//Link now the AGU with it's AG
        for(String keyAGU : AGUS_To_Upsert.keySet()) {
            EUR_CRM_AccountGroupUser__c agu = AGUS_To_Upsert.get(keyAGU);
            //Field agu.EUR_CRM_AccountGroup__c is not writeable if ID already exist
            //And if ID already exist then it supposed to be linked to the right AG already
            if(agu.Id == null) {
                Id accId = keyAGU.split('-')[0];
                EUR_CRM_AccountGroup__c ag = AGS_To_Upsert.get(accId);
                agu.EUR_CRM_AccountGroup__c = ag.Id;
            }
        }
        
        
        List<EUR_CRM_AccountGroupUser__c> minimum_AGUs = new List<EUR_CRM_AccountGroupUser__c>();
        for(String key : AGUS_To_Upsert.keySet()) {
            EUR_CRM_AccountGroupUser__c agu = AGUS_To_Upsert.get(key);
            String accId = key.split('-')[0];

            //If it doesn't exist we cannot escape => We need to create it
            if(agu.Id == null) {
                minimum_AGUs.add(agu);
                System.debug('NEW AGU');
            } else {
                System.debug('AGU Exist');
                //Here it means we plan to update an existing one
                //Let's compare with the actual existing one and if there is no change => THen do nothing
                EUR_CRM_AccountGroup__c existingAG = existingAGS.get(accId);
                //We should always enter inside the IF because if we don't we should be in the previous if agu.id == null
                for(EUR_CRM_AccountGroupUser__c existingAGU : existingAG.EUR_CRM_AccountGroupUsers__r) {
                    boolean sameId = (existingAGU.Id == agu.Id);
                    boolean sameStatus = (existingAGU.EUR_CRM_Status__c == agu.EUR_CRM_Status__c);
                    boolean sameAccessLevel = (existingAGU.EUR_CRM_AccessLevel__c == agu.EUR_CRM_AccessLevel__c);
                    //Same ID = Same record
                    
                    if(sameId) {
                        if(!(sameStatus && sameAccessLevel)) {
                            minimum_AGUs.add(agu);
                        } 
                    }
                }
            }
        }
        //Create new records or update the one we want to mark as deleted
        //It should populate the ID inside the map thanks to object reference
        System.debug('UPSERT AGUS: ' + minimum_AGUs.size() + ' instead of ' + AGUS_To_Upsert.values().size());
        //upsert minimum_AGUS Id;
        //We have to accept partial success here because AGU fire account triggers
        //And if one account has poor data, then the entire script will fail
        List<Database.UpsertResult> upsertResult = Database.upsert(minimum_AGUS, EUR_CRM_AccountGroupUser__c.Id.getDescribe().getSObjectField(), false);
        Integer numberOfFailure = 0;
        for(Database.UpsertResult ur : upsertResult) {
            if(ur.isSuccess() == false) {
                numberOfFailure ++;
            }
        }
        System.debug('Number of AGU failure: ' + numberOfFailure);
        //Now we want to (in this exact order):
        //- Remove the ASU that should be deleted
        //- Update the AS to the status 'account groups created'
        //- Remove the AS that should be deleted
        //
        //List<EUR_CRM_Automatic_Sharing_User__c> asuToUpdate = new List<EUR_CRM_Automatic_Sharing_User__c>();
          
        //We do not delete the AS/ASU right away, we still need them in the database
        
        //Before actually deleting AS/ASU we need to remove the one that was removed
        //from the ATG, they existing through the link of this object
        //but we have to be careful if a new automatic sharing want to keep the sharing

        //First we create the new one
        List<EUR_CRM_Automatic_Sharing_Link__c> minimum_ASLs = new List<EUR_CRM_Automatic_Sharing_Link__c>();
        
        /*
        * We retrieve first all links, then we will compare them to the ATG accounts, and remove the one
        * that disappeared
        */
        Map<String, EUR_CRM_Automatic_Sharing_Link__c> existingASLs = new Map<String, EUR_CRM_Automatic_Sharing_Link__c>();
        for(EUR_CRM_Automatic_Sharing_User__c u : [
            SELECT Id,
            (SELECT Id, EUR_CRM_External_ID__c, EUR_CRM_Account__c, EUR_CRM_ASU__r.EUR_CRM_AS__c, EUR_CRM_ASU__r.EUR_CRM_User__c, EUR_CRM_ASU__r.EUR_CRM_AS__r.EUR_CRM_ATG__c FROM Automatic_Sharing_Links_EU__r) 
            FROM EUR_CRM_Automatic_SHaring_User__c WHERE EUR_CRM_AS__c IN :asIds AND EUR_CRM_AS__r.EUR_CRM_Status__c IN (:s_waiting, :s_delete)
        ]) {
            for(EUR_CRM_Automatic_Sharing_Link__c l : u.Automatic_Sharing_Links_EU__r) {
                existingASLs.put(l.EUR_CRM_External_ID__c, l);
            }
        }

        //Here we :
        // - Create the missing ASL
        // - Find out the one that should be removed
        for(String keyAGU : AGUS_To_Upsert.keySet()) {
            Id accId = keyAGU.split('-')[0];
            //We do not want to create an ASL for the EXISTING/HEADOFFICE one (check fuunction transform_ASU_to_AGU)
            if(keyAGU.startsWith(accId) && !keyAGU.endsWith('EXISTING') && !keyAGU.endsWith('HEADOFFICE')) {
                EUR_CRM_AccountGroupUser__c agu = AGUS_To_Upsert.get(keyAGU);
                
                Set<Id> asusId = AGU_ASU.get(keyAGU);
                for(Id asuId : asusId) {

                    String extId = accId + '-' + asuId;
                    //Not existing ? Then we have to create this link
                    if(!existingASLs.containsKey(extId)) {
                        EUR_CRM_Automatic_Sharing_Link__c newASL = new EUR_CRM_Automatic_Sharing_Link__c(
                            EUR_CRM_ASU__c = asuId,
                            EUR_CRM_Account__c = accId,
                            EUR_CRM_External_ID__c = extId
                        );
                        existingASLs.put(extId, newASL);//We add it because later on we'll check the one we want to remove because they disappear from the ATG
                        minimum_ASLs.add(newASL);
                    }  
                }              
            }
        }
        insert minimum_ASLs;//Insert because we only create the missing one
        
        List<EUR_CRM_Automatic_Sharing_Link__c> aslToDelete = new List<EUR_CRM_Automatic_Sharing_Link__c>();
        
        Set<Id> usersFromASLRemoved = new Set<Id>();
        Set<Id> accsFromASLRemoved = new Set<Id>();
        //Go through each existing ASL, and we will check if the
        for(EUR_CRM_Automatic_Sharing_Link__c l : existingASLs.values()) {
            //get the accounts linked to the AS
            List<EUR_CRM_Account_in_target_group__c> aitgs = atg_accounts.get(l.EUR_CRM_ASU__r.EUR_CRM_AS__r.EUR_CRM_ATG__c);
            boolean isAccountStillInATG = false;
            if(aitgs != null) {
                //Loop thorugh each accounts
                for(EUR_CRM_Account_in_target_group__c a : aitgs) {
                    //If we found the account we mark it
                    if(a.EUR_CRM_Account__c == l.EUR_CRM_Account__c) {
                        isAccountStillInATG = true;
                    }
                }

                //end of loop: still not found? Then it means we need to remove it
                if(!isAccountStillInATG) {
                    //We have to remove the link anyway
                    aslToDelete.add(l);
                    usersFromASLRemoved.add(l.EUR_CRM_ASU__r.EUR_CRM_User__c);
                    accsFromASLRemoved.add(l.EUR_CRM_Account__c);
                }
            }
            
        }
        delete aslToDelete;

        //I split the logic to read in a easier way
        //Now let's check if any of those ASL is still part of an automatic sharing
        
        //Select the automatic sharing already shared
        List<EUR_CRM_Automatic_Sharing_Link__c> alreadySharedASL = [
            SELECT EUR_CRM_Account__c, EUR_CRM_ASU__r.EUR_CRM_User__c 
            FROM EUR_CRM_Automatic_Sharing_Link__c 
            WHERE 
            EUR_CRM_ASU__r.EUR_CRM_AS__r.EUR_CRM_Status__c = :s_shared AND 
            EUR_CRM_Account__c IN :accsFromASLRemoved AND 
            EUR_CRM_ASU__r.EUR_CRM_User__c IN :usersFromASLRemoved
        ];

        Map<Id, Set<Id>> acc_users = new Map<Id, Set<Id>>();
        for(EUR_CRM_Automatic_Sharing_Link__c l : aslToDelete) {
            //Get batch AGU
            boolean isBatchAGUStillShare = false;
            for(String acc_user : AGUS_To_Upsert.keySet()) {
                EUR_CRM_AccountGroupUser__c batchAGU = AGUS_To_Upsert.get(acc_user);
                if(acc_user.startsWith(l.EUR_CRM_Account__c)) {
                    if(batchAGU.EUR_CRM_Status__c != 'To Delete') {
                        isBatchAGUStillShare = true;
                    }
                }
            }
            boolean isAlreadyShared = false;

            for(EUR_CRM_Automatic_Sharing_Link__c l_shared : alreadySharedASL) {
                //If same account & same user
                if(l_shared.EUR_CRM_Account__c == l.EUR_CRM_Account__c && l_shared.EUR_CRM_ASU__r.EUR_CRM_User__c == l.EUR_CRM_ASU__r.EUR_CRM_User__c) {
                    isAlreadyShared = true;
                }
            }
            
            //if both are false then we should remove the AGU
            if(isBatchAGUStillShare == false && isAlreadyShared == false) {
                Set<Id> users = acc_users.get(l.EUR_CRM_Account__c);
                if(users == null) {
                    users = new Set<Id>();
                }
                users.add(l.EUR_CRM_ASU__r.EUR_CRM_User__c);
                acc_users.put(l.EUR_CRM_Account__c, users);
            }
        }

        Set<Id> usersTempId = new Set<Id>();
        for(Set<Id> userTempId : acc_users.values()) {
            usersTempId.addAll(userTempId);
        }

        //We need to be careful here since we cannot 
        //respect the map search for agu => Perfect query would be: (acc1 & user1) OR (acc2 and user1) OR (acc3, user2) ...
        //We can have here too many results, so loop through it and use the map to know the truth
        List<EUR_CRM_AccountGroupUser__c> aguToDelete = new List<EUR_CRM_AccountGroupUser__c>();
        for(EUR_CRM_AccountGroupUser__c agu : [
            SELECT Id, EUR_CRM_User__c, EUR_CRM_AccountGroup__r.EUR_CRM_Account__c 
            FROM EUR_CRM_AccountGroupUser__c 
            WHERE 
            EUR_CRM_Status__c != 'To Delete' AND 
            EUR_CRM_User__c IN :usersTempId AND 
            EUR_CRM_AccountGroup__r.EUR_CRM_Account__c IN :acc_users.keySet()
        ]) {
            Set<Id> users = acc_users.get(agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c);
            if(users != null) {
                if(users.contains(agu.EUR_CRM_User__c)) {
                    agu.EUR_CRM_Status__c = 'To Delete';
                    aguToDelete.add(agu);
                }
            }
        }
        //We have to acccept partial success here because accounts trigger are fired and if the accounts has wrong data
        //Then the entire script will fail
        //update aguToDelete;
        Database.update(aguToDelete, false);
        
        
        //Delete the ASU first
        //It will also delete the links (because they are master details)
        List<EUR_CRM_Automatic_Sharing_User__c> asuToDelete = new List<EUR_CRM_Automatic_Sharing_User__c>();
        for(EUR_CRM_Automatic_Sharing__c s : sharings) {
            if(s.EUR_CRM_Status__c == s_waiting || s.EUR_CRM_Status__c == s_delete) {
                for(EUR_CRM_Automatic_Sharing_User__c u : s.Automatic_Sharing_Users__r) {
                    if(u.EUR_CRM_To_Be_Deleted__c == true) {
                        asuToDelete.add(u);
                    }
                }
            }
        }   
        delete asuToDelete;
        
        //Then delete the AS parents
        List<EUR_CRM_Automatic_Sharing__c> asToUpdate = new List<EUR_CRM_Automatic_Sharing__c>();
        List<EUR_CRM_Automatic_Sharing__c> asToDelete = new List<EUR_CRM_Automatic_Sharing__c>();
        for(EUR_CRM_Automatic_Sharing__c s : sharings) {
            if(s.EUR_CRM_Status__c == EUR_CRM_AutomaticSharing.STATUS_DELETE) {
                asToDelete.add(s);
            } else if(s.EUR_CRM_Status__c == EUR_CRM_AutomaticSharing.STATUS_WAITING) {
                s.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_SHARED;
                asToUpdate.add(s);
            }
        }
        
        delete asToDelete;
        update asToUpdate;

        /*
        System.debug('Limits');
        System.debug(Limits.getAggregateQueries());
        System.debug(Limits.getLimitAggregateQueries());
        System.debug(Limits.getQueries());
        System.debug(Limits.getLimitQueries());
        */
    }
    
    
}