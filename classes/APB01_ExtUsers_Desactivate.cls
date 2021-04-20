/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | User                                                                               |
|     - Description     | Send email to prevent Managers that External Users are about to expire.		     |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 20/12/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
global class APB01_ExtUsers_Desactivate implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    
    public String soql = 'SELECT Email,FirstName,LastName,CompanyName,EXT_USR_RQT_Expiration_Date__c,EXT_USR_RQT_Expiration_Status__c,Id FROM User WHERE IsActive = true AND EXT_USR_RQT_Expiration_Date__c != null'; //query string variable
    public String debugMsg = '';
    global List<String> listIDAcct = new List<String>(); 
    //Pour lancer le batch afin d effectuer des tests, utiliser le execute anonymous avec
    // Database.executeBatch(new APB01_ExtUsers_Desactivate(), 200);
    
    /*
    *   START
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('#### START APB01_ExtUsers_Desactivate -- Begin');
        Date dateToday = Date.today();
        String ExtProfileID = EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c;
        soql += ' AND ProfileId = \''+ExtProfileID+'\'';
        return Database.getQueryLocator(soql);
    }

    /*
    *   EXECUTE
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        String emailAdmin = Utils_UsefulMethods.emailFromUsernameEntry(EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_Username__c);
        
        Integer delayToAvertize = (Integer)EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_Notification_Delay__c;
        
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- StartTimer:'+System.now());
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- Begin');
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- Scope size : ' + scope.size());
                
        List<User> list_ExtUsers = (List<User>)scope;
        
        Map<Id,User> map_UserId_ExtUsers = new Map<Id,User>(list_ExtUsers);
    /*    for(User var : list_ExtUsers){
            map_UserId_ExtUsers.put(var.Id, var);
        }     */
        List<User> list_ExtUsersToUpdate = new List<User>();
        List<User> list_ExtUsersAboutToExpire = new List<User>();
        
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- startTimer_Boucle1:'+System.now());
        
        for(User var : list_ExtUsers){          
            Integer delta = Date.today().daysBetween(var.EXT_USR_RQT_Expiration_Date__c.date());
            System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- user process: ID='+var.Id+', Exp Date='+var.EXT_USR_RQT_Expiration_Date__c.date()+', delta='+delta);
                
            if(delta <= 0){
                /* External User expired today. His status becomes "expired" and he is desactivated. */
                System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- User_expires');
                
                var.EXT_USR_RQT_Expiration_Status__c = 'Expired';
                var.IsActive = false;
                list_ExtUsersToUpdate.add(var);
                
            } else if(delta <= delayToAvertize){
                /* delay depassed but not expired yet. External User become "about to expire". */
                System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- User_about_to_expires');
                
                if(var.EXT_USR_RQT_Expiration_Status__c != 'About to expire')
                	list_ExtUsersAboutToExpire.add(var);
                	
                var.EXT_USR_RQT_Expiration_Status__c = 'About to expire';
                list_ExtUsersToUpdate.add(var);                
            }
        }
        
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- stopTimer_Boucle1:'+System.now());    
        
        /* Update users */
        if(list_ExtUsersToUpdate.size() != 0){
            Savepoint sp = null;
            try {           
                sp = Database.setSavepoint();
                
                System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- startTimer_update:'+System.now());             
                System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- update '+list_ExtUsersToUpdate.size()+' records.');                
                                           
                /* Treatment of Users about to expire */
                if(list_ExtUsersAboutToExpire.size() != 0){
                    System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- treat Users to expire :'+list_ExtUsersAboutToExpire.size()+' records.');
                    
                    // Create an external_user_request for each external user to merge info in the mail.
                    List<External_User_Request__c> newRqtsToInsert = new List<External_User_Request__c>();
                    for(User extU : list_ExtUsersAboutToExpire){
                        External_User_Request__c newRqt = new External_User_Request__c();
                        newRqt.EXT_USE_RQT_Expiry_Date__c = extU.EXT_USR_RQT_Expiration_Date__c;
                        newRqt.EXT_USR_RQT_First_Name__c = extU.FirstName;
                        newRqt.EXT_USR_RQT_Last_Name__c = extU.LastName;
                        newRqt.EXT_USR_RQT_Company__c = extU.CompanyName;
                        newRqt.EXT_USR_RQT_External_User__c = extU.Id;
                        newRqt.EXT_USR_RQT_Email__c = extU.Email;
                        newRqt.EXT_USR_RQT_Status__c = 'Closed';
                        debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- treat user [ID:'+extU.Id+'/email:'+extU.Email+'}.';
                        newRqtsToInsert.add(newRqt);
                    }
                    
                    System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- Insert external user request :'+list_ExtUsersAboutToExpire.size()+' records.');
                    insert newRqtsToInsert;
                    
                    // Create a contact used by the template.
                    Contact newContact = new Contact();
                    newContact.FirstName = 'PR';
                    newContact.LastName = 'noreply';
                    newContact.Email = 'noreply@pernod-ricard.com';
                    insert newContact;
                    
                    // Get the list of groupID with external Users and create a map <ExtUserID, list of group>
                    List<CollaborationGroupMember> list_CollabGrpMember_EU = [SELECT MemberId,CollaborationGroupId FROM CollaborationGroupMember WHERE MemberID IN :list_ExtUsersAboutToExpire];
                    System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- query :'+list_CollabGrpMember_EU.size()+' groups for all EU to expire.');
                    
                    Map<Id,List<Id>> map_ExtUserId_GroupId = new Map<Id,List<Id>>();
                    List<Id> list_groupExtUsers = new List<Id>();
                    
                    for(CollaborationGroupMember var : list_CollabGrpMember_EU){
                        debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- add [ExtUser/GroupId] : ['+var.MemberId+'/'+var.CollaborationGroupId+'].';
                        List<Id> list_groupId;
                        if(!map_ExtUserId_GroupId.containsKey(var.MemberId))
                            list_groupId = new List<Id>();
                        else
                            list_groupId = map_ExtUserId_GroupId.get(var.MemberId);
                        list_groupId.add(var.CollaborationGroupId);
                        list_groupExtUsers.add(var.CollaborationGroupId);
                        map_ExtUserId_GroupId.put(var.MemberId,list_groupId);                       
                    }
                    
                    // Get the link between groupId and AdminID and create a map <groupId, List<AdminId>>
                    List<CollaborationGroupMember> list_CollabGrpMember_Admin = [Select MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationRole = 'admin' AND CollaborationGroupId IN :list_groupExtUsers];
                    debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- query :'+list_CollabGrpMember_Admin.size()+' admin for all groups.';
                    
                    Map<Id,List<Id>> map_GroupId_ListAdminId = new Map<Id,List<Id>>();
                    List<Id> list_allAdminId = new List<Id>();
                    
                    for(CollaborationGroupMember var : list_CollabGrpMember_Admin){
                        debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- add [groupId/AdminId] : ['+var.CollaborationGroupId+'/'+var.MemberId+'].';
                        List<Id> list_adminId;
                        if(!map_GroupId_ListAdminId.containsKey(var.CollaborationGroupId))
                            list_adminId = new List<Id>();
                        else
                            list_adminId = map_GroupId_ListAdminId.get(var.CollaborationGroupId);
                        list_adminId.add(var.MemberId);
                        list_allAdminId.add(var.MemberId);
                        map_GroupId_ListAdminId.put(var.CollaborationGroupId,list_adminId);
                    }
                
                    // Get all admins of group contained an external user, then create a map <AdminID,AdminEmail>
                    List<User> list_Admin = [SELECT Id, email FROM User userAdmin WHERE Id IN :list_allAdminId];
                    debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- query :'+list_Admin.size()+' admins with email for all groups.';
                    
                    MAP<Id,String> map_UserAdminId_Email = new MAP<Id,String>();                    
                    for(User var : list_Admin){
                        debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- add [AdminId/AdminEmail] : ['+var.Id+'/'+var.Email+'].';
                        map_UserAdminId_Email.put(var.Id,var.Email);
                    }
                    
                    // Get the email template by name
                    EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE developerName = 'EXT_USR_RQT_Email_to_the_Pernod_Ricard_Employee_for_renew_external_users'];
                    debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- Get the email template Id : '+template.Id+'.';
                    
                    // Create a list with all emails which will be sent
                    List<Messaging.SingleEmailMessage> list_emailsToSent = new List<Messaging.SingleEmailMessage>();
                    
                    // For each external user near to expire, send an email to his groups admins.
                    //for(User currExtUser : list_ExtUsersAboutToExpire){
                    for(External_User_Request__c currExtUserRqt : newRqtsToInsert){
                        List<String> toAddresses = new List<String>();
                        
                        // Check if the current External User is a member of a group
                        if(map_ExtUserId_GroupId.containskey(currExtUserRqt.EXT_USR_RQT_External_User__c)){
                            // parcourt la liste des groupes rattachés à ce user
                            debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- treat extUser '+currExtUserRqt.EXT_USR_RQT_External_User__c+'.';
                            for(Id currGroupId : map_ExtUserId_GroupId.get(currExtUserRqt.EXT_USR_RQT_External_User__c)){
                                // parcourt la liste des admins rattachés à ce groupe
                                debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- map_GroupId_ListAdminId : '+map_GroupId_ListAdminId.get(currGroupId).size()+'.';
                                for(Id currAdminId : map_GroupId_ListAdminId.get(currGroupId)){
                                    toAddresses.add(''+map_UserAdminId_Email.get(currAdminId));                             
                                }
                            }
                            debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- toAddresses : '+toAddresses.size()+' records.';
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTargetObjectId(newContact.Id);
                            mail.setWhatId(currExtUserRqt.Id);
                            debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- setTargetObjectId : '+currExtUserRqt.Id+'.';
                            //mail.setSubject('An external user is about to expire');
                            //mail.setPlainTextBody('email body d\'exemple car le template ne marche pas.');
                            mail.setTemplateId(template.Id);
                            mail.setBccAddresses(toAddresses);
                            mail.setSenderDisplayName('noreply@pernod-ricard.com');
                            
                            list_emailsToSent.add(mail);
                            System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- Emails to sent : '+list_emailsToSent.size()+' records.');
                        }
                    }
                    
                    debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- Sent '+list_emailsToSent.size()+' emails.';
                    List<Messaging.SendEmailResult> listResults = Messaging.sendEmail(list_emailsToSent,false);
                    for(Messaging.SendEmailResult result: listResults){
                        if(!result.isSuccess()){
                            debugMsg += '\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- error when send email :'+result.getErrors()+'.';
                            System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- error when send email :'+result.getErrors()+'.');
                        }
                    }
                    
                    // Delete records temporary created for the treatment
                    delete newRqtsToInsert;
                    delete newContact;
                }   
                                
                System.debug('\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- stopTimer_update:'+System.now());                
                System.debug('\n' +'#### EXECUTE APB01_ExtUsers_Desactivate -- StopTimer:'+System.now());            
            }catch (Exception e){
                if(sp!=null)Database.rollback(sp);
                
                debugMsg += '\n' +'#### APB01_ExtUsers_Desactivate -- EXECUTE Exception : ' + e;
                Utils_UsefulMethods.notifyAdminMsg(emailAdmin, 'APB01_ExtUsers_Desactivate', 'Exception during the batch.',debugMsg);
                //notifyAdmin(emailAdmin, 'Exception during the batch APB01_ExtUsers_Desactivate : '+ e.getTypeName()+' : '+e.getMessage()+'. Cause :'+e.getCause()+'.');
                System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- StopTimer:'+System.now());
            }
        }
    }

    /*
    *   FINISH
    */
    global void finish(Database.BatchableContext BC){        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems from AsyncApexJob where Id =: BC.getJobId()];
        
        // Because of MIXED_DML_SETUP error, we need to use a second batch to update users.
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- call second batch: APB02_ExtUsers_Desactivate_Upd_Users');
        if(!Test.isRunningTest())
        	Database.executeBatch(new APB02_ExtUsers_Desactivate_Upd_Users(),200);
        
        
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- Status:'+a.Status+' ');
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
    }
}