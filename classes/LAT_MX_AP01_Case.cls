/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Case
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/

public with sharing class LAT_MX_AP01_Case{
       
    /*****************************************************************************************
    * Nombre del metodo: 
    * Descripcion: Metodo que completa los campos LAT_MX_CCManagerOrExecutive__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 0/10/2013
    * Modo: before insert
    *****************************************************************************************/
    public static void UpdatesCaseFields (List<Case> triggerNew){
    
        set<Id> setAccId = new set<Id>();
        
        for(Case caso: triggerNew){
            setAccId.add(caso.AccountId);
        }        
        map<String, Account> mapAccounts = new map<String, Account> ([SELECT Id, LAT_MX_CreditAndCollectionsExecutive__c, Channel__c FROM Account WHERE Id IN: setAccId]);
        set<Id> setIdUser = new set<Id>();
        
        for(String idAcc: mapAccounts.keyset()){
            if(mapAccounts.get(idAcc).LAT_MX_CreditAndCollectionsExecutive__c != null){
                setIdUser.add(mapAccounts.get(idAcc).LAT_MX_CreditAndCollectionsExecutive__c);
            }
        }
        
        CS006_DefaultUsers__c CsUserId  = CS006_DefaultUsers__c.getOrgDefaults();
        
        map<String,User> mapAprobadores = new map<String,User>();    
     
        map<String, User> mapUs = new map<String, User>();        

        for(User us: [SELECT Id, ManagerId, Username FROM User WHERE Username =: CsUserId.LAT_MX_UserName1__c OR Id IN: setIdUser]){
            if(us.Username == CsUserId.LAT_MX_UserName1__c){
                mapAprobadores.put(us.Username,us);
            }
            mapUs.put(us.id, us);
        }        
        for(Case caso: triggerNew){
            if(caso.RecordTypeId == Global_RecordTypeCache.getRtId('CaseLAT_MX_CSE_AccountAlterationCreditAndCollections')){          
                if(caso.Reason == 'Registration deposit cash payment' && mapAccounts.get(caso.AccountId).LAT_MX_CreditAndCollectionsExecutive__c != null){
                    caso.LAT_MX_CCManagerOrExecutive__c = mapAccounts.get(caso.AccountId).LAT_MX_CreditAndCollectionsExecutive__c;   
                } else if(caso.Reason == 'Payment Term Modification'){
                    if(mapAprobadores.containsKey(CsUserId.LAT_MX_UserName1__c)){
                        caso.LAT_MX_CCManagerOrExecutive__c = mapAprobadores.get(CsUserId.LAT_MX_UserName1__c).ManagerId;
                    }
                }
             }
         }       
        
    }
    
    /*********************************************************************************************************************
    * Nombre del metodo: UpdateAccountOwnerAndManagerOwner
    * Descripcion: Metodo que completa los campos AccountOwner_AR__c y     AccountOwnerManager_AR__c
    * Desarrollador: Elena Schwarzböck
    * Fecha: 08/10/2013
    * Modo: before insert, before update
    ********************************************************************************************************************/ 
    public static void UpdateAccountOwnerAndManagerOwner (List<Case> triggerNew){
        
        set<Id> setAccountIds = new set<Id>();
        
        for (Case cse: triggerNew){
            setAccountIds.add(cse.AccountId);
        }
        
        list<Account> listAccounts = new list<Account>([SELECT Id, OwnerId FROM Account WHERE Id IN: setAccountIds]);
        set<Id> setIdOwnersAccounts = new set<Id>();
        map<Id, Account> mapIdAccounts = new map<Id, Account>();
        
        if (!listAccounts.isEmpty()){
            for (Account acc: listAccounts){
                setIdOwnersAccounts.add(acc.OwnerId);
                mapIdAccounts.put(acc.Id, acc);    
            }
        }
        map<Id, User> mapIdUsers = new map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN: setIdOwnersAccounts]);

        for (Case cse:triggerNew){
            if(cse.AccountId != NULL){
                if(mapIdAccounts.get(cse.AccountId).OwnerId != NULL){
                    cse.AccountOwner_AR__c = mapIdAccounts.get(cse.AccountId).OwnerId;
                }
                if(mapIdUsers.get(cse.AccountOwner_AR__c).ManagerId != NULL){
                    cse.AccountOwnerManager_AR__c = mapIdUsers.get(cse.AccountOwner_AR__c).ManagerId;
                }
            }
            /*if(cse.AccountId == NULL){    
                cse.addError(label.AP01_00008_AR);
            }*/
        }
                

    }

    //MIGRATED 02/11/2016 
    public static void UpdatesCaseFields (List<LAT_Case__c> triggerNew){
    
        set<Id> setAccId = new set<Id>();
        
        for(LAT_Case__c caso: triggerNew){
            setAccId.add(caso.LAT_Account__c);
        }        
        map<String, Account> mapAccounts = new map<String, Account> ([SELECT Id, LAT_MX_CreditAndCollectionsExecutive__c, Channel__c FROM Account WHERE Id IN: setAccId]);
        set<Id> setIdUser = new set<Id>();
        
        for(String idAcc: mapAccounts.keyset()){
            if(mapAccounts.get(idAcc).LAT_MX_CreditAndCollectionsExecutive__c != null){
                setIdUser.add(mapAccounts.get(idAcc).LAT_MX_CreditAndCollectionsExecutive__c);
            }
        }
        
        CS006_DefaultUsers__c CsUserId  = CS006_DefaultUsers__c.getOrgDefaults();
        
        map<String,User> mapAprobadores = new map<String,User>();    
     
        map<String, User> mapUs = new map<String, User>();        

        for(User us: [SELECT Id, ManagerId, Username FROM User WHERE Username =: CsUserId.LAT_MX_UserName1__c OR Id IN: setIdUser]){
            if(us.Username == CsUserId.LAT_MX_UserName1__c){
                mapAprobadores.put(us.Username,us);
            }
            mapUs.put(us.id, us);
        }        
        for(LAT_Case__c caso: triggerNew){
            if(caso.RecordTypeId == Global_RecordTypeCache.getRtId('CaseLAT_MX_CSE_AccountAlterationCreditAndCollections')){          
                if(caso.LAT_Reason__c == 'Registration deposit cash payment' && mapAccounts.get(caso.LAT_Account__c).LAT_MX_CreditAndCollectionsExecutive__c != null){
                    caso.LAT_MX_CCManagerOrExecutive__c = mapAccounts.get(caso.LAT_Account__c).LAT_MX_CreditAndCollectionsExecutive__c;   
                } else if(caso.LAT_Reason__c == 'Payment Term Modification'){
                    if(mapAprobadores.containsKey(CsUserId.LAT_MX_UserName1__c)){
                        caso.LAT_MX_CCManagerOrExecutive__c = mapAprobadores.get(CsUserId.LAT_MX_UserName1__c).ManagerId;
                    }
                }
             }
         }       
         
    }
    
    //MIGRATED 02/11/2016 
    public static void UpdateAccountOwnerAndManagerOwner (List<LAT_Case__c> triggerNew){
        
        set<Id> setAccountIds = new set<Id>();
        
        for (LAT_Case__c cse: triggerNew){
            setAccountIds.add(cse.LAT_Account__c);
        }
        
        list<Account> listAccounts = new list<Account>([SELECT Id, OwnerId FROM Account WHERE Id IN: setAccountIds]);
        set<Id> setIdOwnersAccounts = new set<Id>();
        map<Id, Account> mapIdAccounts = new map<Id, Account>();
        
        if (!listAccounts.isEmpty()){
            for (Account acc: listAccounts){
                setIdOwnersAccounts.add(acc.OwnerId);
                mapIdAccounts.put(acc.Id, acc);    
            }
        }
        map<Id, User> mapIdUsers = new map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN: setIdOwnersAccounts]);

        for (LAT_Case__c cse:triggerNew){
            if(cse.LAT_Account__c != NULL){
                if(mapIdAccounts.get(cse.LAT_Account__c).OwnerId != NULL){
                    cse.LAT_AR_AccountOwner__c = mapIdAccounts.get(cse.LAT_Account__c).OwnerId;
                }
                if(mapIdUsers.get(cse.LAT_AR_AccountOwner__c).ManagerId != NULL){
                    cse.LAT_AR_AccountOwnerManager__c = mapIdUsers.get(cse.LAT_AR_AccountOwner__c).ManagerId;
                }
            }
            /*if(cse.AccountId == NULL){    
                cse.addError(label.AP01_00008_AR);
            }*/
        }
                
    }

}