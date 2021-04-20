public class EUR_CRM_AutomaticSharing {
    public static final String STATUS_WAITING = 'Waiting for batch',
        STATUS_DELETE = 'To be deleted',
        STATUS_SHARED = 'Account Groups Created',
        STATUS_DRAFT = 'Draft',
        ERROR_STATUS_SHARED = 'The status "Account Groups Created" cannot be set manually',
        ERROR_ASU_ACCESS = 'Access Level cannot be changed after creation. Change the status of this record has "To be deleted" and create a new record with the correct access level.'
        ;
    
    public static boolean byPassRules = false;
    
    /*
* In case someone ask for the deletion of an ASU, then we should remove the AGU
* EXCEPT: If some was already shared in the past then we need to keep the sharing based on those one
* Since the already shared one aren't part of the schedule job, we are blind to this
*/
    public static Map<Id, Map<Id, String>> get_Already_Shared_Access(Set<Id> accIds, Set<Id> userIds) {
        /*
* accIds: Represent the account IDS to be shared, so for the current AS in status Waiting for batch
* userIds: Represent the user IDS to be shared, so for the ASU not to delete
*/
        
        //Step 1: Retrieve the AS already shared linked to those accounts
        List<EUR_CRM_Automatic_Sharing_User__c> users = [
            SELECT EUR_CRM_User__c, EUR_CRM_Access_Level__c,
            (SELECT EUR_CRM_Account__c, 
             EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.OwnerId, 
             EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.EUR_CRM_Parent_Account__r.OwnerId, 
             EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.EUR_CRM_Parent_Account__r.EUR_CRM_Parent_Account__r.OwnerId FROM Automatic_Sharing_Links_EU__r WHERE EUR_CRM_Account__c IN :accIds)
            FROM EUR_CRM_Automatic_SHaring_User__c 
            WHERE
            EUR_CRM_AS__r.EUR_CRM_Status__c = :STATUS_SHARED
            AND
            EUR_CRM_User__c IN :userIds
        ];
        
        Map<Id, Map<Id, String>> acc_user_access = new Map<Id, Map<Id, String>>();        
        for(EUR_CRM_Automatic_Sharing_User__c u : users) {
            for(EUR_CRM_Automatic_Sharing_Link__c l : u.Automatic_Sharing_Links_EU__r) {
                Map<Id, String> user_access = acc_user_access.get(l.EUR_CRM_Account__c);
                if(user_access == null) {
                    user_access = new Map<Id, String>();
                }
                String access = user_access.get(u.EUR_CRM_User__c);
                if(access == null) {
                    user_access.put(u.EUR_CRM_User__c, u.EUR_CRM_Access_Level__c);
                } else {
                    user_access.put(u.EUR_CRM_User__c, access == 'Edit' ? 'Edit' : u.EUR_CRM_Access_Level__c);
                }
                
                acc_user_access.put(l.EUR_CRM_Account__c, user_access);
            }
        }
        return acc_user_access;
    }  
    
    /*
* Get accounts for each Account Target Group (ATG)
*/
    public static Map<Id, List<EUR_CRM_Account_in_Target_Group__c>> getAccountsInATG(Set<Id> atgIds) {
        Map<Id, List<EUR_CRM_Account_in_Target_Group__c>> atg_accounts = new Map<Id, List<EUR_CRM_Account_in_Target_Group__c>>();
        
        /*
        * Sub query should prevent limit of 50K accounts
        */
        List<EUR_CRM_Account_Target_Group__c> atgs = [
            SELECT Id,
            (
                SELECT 
                Id, EUR_CRM_Account__c, EUR_CRM_Account__r.EUR_CRM_Country_Code__c,
                EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.OwnerId,
                EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.EUR_CRM_Parent_Account__r.OwnerId, 
                EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.EUR_CRM_Parent_Account__r.EUR_CRM_Parent_Account__r.OwnerId 
                FROM Account_in_Target_Groups__r 
                WHERE EUR_CRM_Account__c != null
            )
            FROM EUR_CRM_Account_Target_Group__c 
            WHERE Id IN :atgIds
        ];
        for(EUR_CRM_Account_Target_Group__c atg: atgs) {
            atg_accounts.put(atg.Id, atg.Account_in_Target_Groups__r);
        }
        
        return atg_accounts;
    }
    public static Map<Id, EUR_CRM_AccountGroup__c> getExistingAGS(Set<Id> accIds) {
        Map<Id, EUR_CRM_AccountGroup__c> existingAGS = new Map<Id, EUR_CRM_AccountGroup__c>();
        for(EUR_CRM_AccountGroup__c ag: [
            SELECT Id, EUR_CRM_Status__c, EUR_CRM_Account__c, (   
                SELECT Id, EUR_CRM_User__c, EUR_CRM_AccessLevel__c, EUR_CRM_Status__c 
                FROM EUR_CRM_AccountGroupUsers__r
            ) 
            FROM EUR_CRM_AccountGroup__c 
            WHERE EUR_CRM_Account__c IN :accIds]) {
            existingAGS.put(ag.EUR_CRM_Account__c, ag);
        }
        return existingAGS;
    }
    public static EUR_CRM_AccountGroupUser__c getExistingAGU(EUR_CRM_AccountGroup__c ag, Id userId) {
        EUR_CRM_AccountGroupUser__c aguToReturn = null;
        if(ag != null) {
            for(EUR_CRM_AccountGroupUser__c agu : ag.EUR_CRM_AccountGroupUsers__r) {
                if(userId == agu.EUR_CRM_User__c) {
                    if(aguToReturn == null) {
                        aguToReturn = agu;
                    } else {
                        //There can be two AGU to the same user when we want to change level of access
                        //Because the process is : remove old sharing in READ for example and create new sharing in EDIT 
                        if(agu.EUR_CRM_Status__c != 'To Delete') {
                            aguToReturn = agu;
                        }
                    }
                }
            }
        }
        return aguToReturn;
    }
    
    /*
* Build the account group
*/
    public static EUR_CRM_AccountGroup__c buildAccountGroup(EUR_CRM_AccountGroup__c ag, EUR_CRM_AccountGroup__c existingAG, EUR_CRM_Account_in_Target_Group__c a) {
        if(ag == null) {
            ag = new EUR_CRM_AccountGroup__c();
            ag.EUR_CRM_Account__c = a.EUR_CRM_Account__c;
            ag.EUR_CRM_Country_code__c = a.EUR_CRM_Account__r.EUR_CRM_Country_Code__c;

            if(existingAG != null) {
                
                ag.Id = existingAG.Id;
                //We keep the existing status because we will upsert only the one 
                //with the status To Delete later on to prevent creating too many records at each batch run
                ag.EUR_CRM_Status__c = existingAG.EUR_CRM_Status__c;
            } else {
                ag.EUR_CRM_Status__c = 'Normal';
            }
        }
        return ag;
    }
    
    /*
* Transform the automatic sharing users in account group users
*/
    
    public static void transform_ASU_in_AGU(
        Map<String, Set<Id>> AGU_ASU,
        Map<String, EUR_CRM_AccountGroupUser__c> AGUS_To_Upsert, 
        EUR_CRM_AccountGroup__c existingAG, 
        EUR_CRM_Automatic_Sharing__c s, 
        EUR_CRM_Account_in_Target_Group__c a, 
        List<EUR_CRM_Automatic_Sharing_User__c> users,
        Map<Id, Map<Id, String>> alreadySharedAccess) {
            //Go through each user of the AS
            for(EUR_CRM_Automatic_Sharing_User__c u : users) {
                
                
                //Get the batch AGU if we already created it in this batch
                EUR_CRM_AccountGroupUser__c batchAGU = AGUS_To_Upsert.get(a.EUR_CRM_Account__c + '-' + u.EUR_CRM_User__c);
                
                //STEP 1: We create an AGU based on what is written on the ASU
                EUR_CRM_AccountGroupUser__c toBeAnalyzedAGU = new EUR_CRM_AccountGroupUser__c();
                toBeAnalyzedAGU.EUR_CRM_AccessLevel__c = u.EUR_CRM_Access_Level__c;
                toBeAnalyzedAGU.EUR_CRM_User__c = u.EUR_CRM_User__c;
                if(s.EUR_CRM_Status__c == EUR_CRM_AutomaticSharing.STATUS_DELETE || u.EUR_CRM_To_Be_Deleted__c == true) {
                    toBeAnalyzedAGU.EUR_CRM_Status__c = 'To Delete';
                } else {
                    toBeAnalyzedAGU.EUR_CRM_Status__c = 'New';
                }
                //STEP 2: We update this same ASU based on any old ASU that is already SHARED from a previous batch
                
                Map<Id, String> user_access = alreadySharedAccess.get(a.EUR_CRM_Account__c);
                if(user_access != null) {
                    String access = user_access.get(u.EUR_CRM_User__c);
                    if(access != null) {
                        if(toBeAnalyzedAGU.EUR_CRM_Status__c == 'To Delete') {
                            //since ASU was already shared, this one shouldn't be deleted
                            toBeAnalyzedAGU.EUR_CRM_Status__c = 'New';
                            toBeAnalyzedAGU.EUR_CRM_AccessLevel__c = access;
                        } else if(toBeAnalyzedAGU.EUR_CRM_AccessLevel__c != access) {
                            //if the old record has a different access than the current record then since there is
                            //Only two choice possible (READ/EDIT), so in the end if they are differnt one must be EDIT
                            toBeAnalyzedAGU.EUR_CRM_AccessLevel__c = 'Edit';
                        }
                    }
                }
                
                //STEP 3: We update the AGU based on the other possible AGU to be shared on this batch
                
                //If we didn't find anything so we have no priority rule
                if(batchAGU == null) {
                    batchAGU = toBeAnalyzedAGU;
                } else {
                    //If we already have a batchAGU for this user and this account we need to prioritize:
                    //1 - EDIT NO DELETE
                    //2 - READ NO DELETE
                    //3 - DELETE
                    //
                    if(batchAGU.EUR_CRM_Status__c == 'To Delete') {
                        batchAGU = toBeAnalyzedAGU; //Maybe it is delete as well but it doesn't matter
                    } else {
                        //No point updating if the sharing values are the same
                        if(batchAGU.EUR_CRM_AccessLevel__c != toBeAnalyzedAGU.EUR_CRM_AccessLevel__c) {
                            //Since we have only 2 values 'Read' or 'Edit'
                            //So if we enter in this condition it means one of the value is Edit.
                            //And if we don't enter then we already have the correct sharing value
                            batchAGU.EUR_CRM_AccessLevel__c = 'Edit';
                        }
                    }
                }//End comparison with same records among the batch (not the database)
                
                //STEP 4: We compare with the existing data inside salesforce
                //in order to know if we really should do something
                
                EUR_CRM_AccountGroupUser__c existingAGU = getExistingAGU(existingAG, u.EUR_CRM_User__c);
                
                System.debug('Existing AGU');
                System.debug(existingAGU);
                
                String aguExtId = a.EUR_CRM_Account__c + '-' + u.EUR_CRM_User__c;
                //Rules are:
                //1. NO AGU existing
                //		=> Upsert ours based on ASU (Could be in a delete status)
                //2. AGU is existing
                //	2.1 Our ASU says we need to Delete
                //		2.1.1 Existing AGU is already in status To Delete? Do nothing
                //		2.1.2 Change the status of the existing AGU
                //	2.2 Our ASU want to share the record in READ or EDIT
                //		2.2.1 Existing AGU is about to be deleted
                //			=> We leave it as To Delete and create a new record
                //		2.2.2 - Existing is not about to be deleted
                //			=> Level of access is the same
                //				=> We keep the existing one
                //			=> Level of access is different
				//				=> Delete existing one & create brand new one
                //	
                if(existingAGU != null) {
                    //If the batch says we want to delete the record
                    if(batchAGU.EUR_CRM_Status__c == 'To Delete') {
                        //Then we simply "re-mark" the existing one has delete
                        batchAGU.Id = existingAGU.Id;
                        //To prevent issue we keep the access level of the existing one, it shouldn't matter since we want to delete it
                        batchAGU.EUR_CRM_AccessLevel__c = existingAGU.EUR_CRM_AccessLevel__c;
                    } else {
                        //Because if the existing one is already mark as delete
                        //then we can simply create our own new one
                        System.debug('Existing status is :' + existingAGU.EUR_CRM_Status__c);
                        if(existingAGU.EUR_CRM_Status__c != 'To Delete') {
                            
                            //Access is already correct => Already shared or not => We change nothing, we keep status of existing
                            if(existingAGU.EUR_CRM_AccessLevel__c == batchAGU.EUR_CRM_AccessLevel__c) {
                                //Here we need to say there is no change and take the AGU out of the map
                                //To prevent having too many record to upsert
                                //Limit is at 10K
                                System.debug('Replace status ' + batchAGU.EUR_CRM_Status__c + ', with : ' + existingAGU.EUR_CRM_Status__c);
                                batchAGU.EUR_CRM_Status__c = existingAGU.EUR_CRM_Status__c;
                                batchAGU.Id = existingAGU.Id;
                            } 
                            //If not the same level of access, then we delete the existing
                            else {
                                //It's important to send a clone copy or the status will be updated both in the existingAGs variable and in the MAP
                                //And because of this we will detect no change
                                EUR_CRM_AccountGroupUser__c cloneExisting = existingAGU.clone(true, true, true, true);
                                cloneExisting.EUR_CRM_Status__c = 'To Delete';
                                
                                AGUS_To_Upsert.put(aguExtId + '-EXISTING', cloneExisting);
                            }
                               
                        }
                    }  
                }
                
                //STEP 5: Now from here if it is still to delete, then we check if this user is part of a headoffice
                //relationship, because in this case he must keep the access to the records in READ
                
                //If it is still to delete
                if(batchAGU.EUR_CRM_Status__c == 'To Delete') {
                    //We check if the account isn't part of a headoffice relationship
                    //We check only 3 levels in the hierarchy, if there is more one day then code need to be updated
                    
                    boolean isOwnerOfParent = 
                        (a.EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.OwnerId == u.EUR_CRM_User__c)
                        || (a.EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.EUR_CRM_Parent_Account__r.OwnerId == u.EUR_CRM_User__c)
                        || (a.EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.EUR_CRM_Parent_Account__r.EUR_CRM_Parent_Account__r.OwnerId == u.EUR_CRM_User__c);
                    
                    if(isOwnerOfParent) {
                        //We use the same map, but make an unfoundable ID to prevent the creation
                        //of Automatic Sharing Link
                        AGUS_To_Upsert.put(aguExtId + '-HEADOFFICE', new EUR_CRM_AccountGroupUser__c(
                                EUR_CRM_AccessLevel__c = 'Read',
                                EUR_CRM_Status__c = 'New',
                                EUR_CRM_User__c = u.EUR_CRM_User__c
                            ));
                    }
                }
                
                AGUS_To_Upsert.put(aguExtId, batchAGU);
                addASU(AGU_ASU, aguExtId, u.Id);
            }//Loop through ASU
        }
    
    /*
* The goal of this function is to change the status of the Automatic Sharing
* If a new account appear in the ATG (or was removed), then the sharing need to be re-ran
*/ 
    public static void moreOrLessAccountsDetected(Set<Id> aitgs) {
        byPassRules = true;
        
        List<String> NotAcceptedStatus = new List<String>();
        NotAcceptedStatus.add(EUR_CRM_AutomaticSharing.STATUS_DRAFT);
        NotAcceptedStatus.add(EUR_CRM_AutomaticSharing.STATUS_DELETE);
        List<EUR_CRM_Automatic_Sharing__c> asToUpdate = [
            SELECT Id 
            FROM EUR_CRM_Automatic_Sharing__c 
            WHERE 
            (NOT EUR_CRM_Status__c IN :NotAcceptedStatus)  AND 
            EUR_CRM_ATG__c IN (SELECT EUR_CRM_Account_Target_Group__c FROM EUR_CRM_Account_in_Target_Group__c WHERE Id IN :aitgs)
        ];
        System.debug('AS TO reload');
        System.debug(asToUpdate);
        for(EUR_CRM_Automatic_Sharing__c a : asToUpdate) {
            a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        }
        
        update asToUpdate;
    }
    
    /*
* Only during update calls
* The user cannot move back to status draft
* Neither to status Account Groups Created
*/
    public static void controlStatusAS(Map<Id, EUR_CRM_Automatic_Sharing__c> newMap, Map<Id, EUR_CRM_Automatic_Sharing__c> oldMap) {
        if(byPassRules == false) {
            for(Id asId : newMap.keySet()) {
                EUR_CRM_Automatic_Sharing__c newRecord = newMap.get(asId);
                //Change of status
                if(newRecord.EUR_CRM_Status__c != oldMap.get(asId).EUR_CRM_Status__c) {
                    if(newRecord.EUR_CRM_Status__c == EUR_CRM_AutomaticSharing.STATUS_SHARED) {
                        newRecord.addError(EUR_CRM_AutomaticSharing.ERROR_STATUS_SHARED);
                    }
                }
            }
        }
    }
    
    private static void addASU(Map<String, Set<Id>> AGU_ASU, String key, Id asuId) {
        Set<Id> ids = AGU_ASU.get(key);
        if(ids == null) {
            ids = new Set<Id>();
        }
        ids.add(asuId);
        AGU_ASU.put(key, ids);
    }
    
    
}