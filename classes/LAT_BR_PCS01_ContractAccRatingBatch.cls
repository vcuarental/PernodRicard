/**********************************************************************************************************************************
                                                                                                                                      
    Developer: Francisco Orzabal                                                                                                   
    Created Date: 03/06/2014                                                                                                        
                                                                                                                                      
    Description: Se encarga de clasificar que cuentas tienen contratos activos y cuales no.

    Last Modified Date:                                                                                                                     
    Last Developer:                                                                                                   
    
    Versión:
    V1.0 - 03/06/2014 - Initial version [FO]
    
/**********************************************************************************************************************************/

global class LAT_BR_PCS01_ContractAccRatingBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
                
        Id IdRT = Global_RecordTypeCache.getRtId('AccountOn_Trade');

        String query = 'SELECT Id, Rating FROM Account WHERE RecordTypeId =: IdRT  and Rating != \'Cliente inativo\'';
        
        return Database.getQueryLocator(query);
    
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        List<Account> listAccounts;
        List<Account> listAccountsWithContract;
        List<Account> listAccountsToUpdate; 
        Date hoy;        
        List<LAT_Contract__c> listContracts;
        Set<Id> setAccIds;
                        
        listAccounts = (List<Account>)scope;                                                    
        setAccIds = new Set<Id>();           
        listAccountsToUpdate = new List<Account>();
        hoy = Date.today();

        String query = 'SELECT Id, Rating, (SELECT Id, Account__c FROM LAT_Contracts__r WHERE LAT_BR_RealValidityDate__c >=: hoy limit 1) FROM Account WHERE Id IN: listAccounts';
        
        listAccountsWithContract = DataBase.query(query);
        
        for (Account acc : listAccountsWithContract) {
            if(!acc.LAT_Contracts__r.isEmpty()) {
                setAccIds.add(acc.Id); 
            }
        }
                                                            
        for (Account acc : listAccounts) {
            
            if (setAccIds.contains(acc.Id) && acc.Rating != 'Cliente com contrato') {
                acc.Rating = 'Cliente com contrato';
                listAccountsToUpdate.add(acc);
            } else if (!setAccIds.contains(acc.Id) && acc.Rating != 'Cliente') {
                acc.Rating = 'Cliente';            
                listAccountsToUpdate.add(acc);
            }
            
        }
                         
        if (!listAccountsToUpdate.isEmpty()) {
            DataBase.update(listAccountsToUpdate);
        }
                                                                                                                                  
    }

    global void finish(Database.BatchableContext BC){
    
    }

}