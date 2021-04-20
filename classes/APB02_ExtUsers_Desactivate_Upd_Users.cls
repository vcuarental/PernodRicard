/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | User                                                                               |
|     - Description     | Desactivate External Users who has expired and automatically change status.        |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 20/12/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
global class APB02_ExtUsers_Desactivate_Upd_Users implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    
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
                
                var.EXT_USR_RQT_Expiration_Status__c = 'About to expire';
                list_ExtUsersToUpdate.add(var);
                list_ExtUsersAboutToExpire.add(var);
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
                
                update list_ExtUsersToUpdate;
                                
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
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- Status:'+a.Status+' ');
        System.debug('#### EXECUTE APB01_ExtUsers_Desactivate -- The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
    }
}