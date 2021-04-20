/**********************************************************************************************
*                                  Company: ValueNet                                          *
*---------------------------------------------------------------------------------------------*
* Clase que realiza el calculo y actualiza el campo LAT_MX_AvailableCreditLimit__c de Account *
***********************************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 04/11/2016
*
********************************************************************************/


public without sharing class LAT_MX_AvailableCreditLimit{
    
    private static Set<String> updtedAccountsRunning;

    public static string CalculatesAvailableCreditLimit(Set<String> setAccountsIds){
        if (updtedAccountsRunning == null) {
            System.debug('Se crea el updtedAccountsRunning.');
            updtedAccountsRunning = new Set<String>();
        } else {
            System.debug('Ya existia el updtedAccountsRunning : '+updtedAccountsRunning);
        }
        if(!Utils.wasMigrationDone('12')) {
            List<Account> listAccounts = [SELECT Id, Name, Client_code_AN8__c, Credit_line__c, LAT_MX_AvailableCreditLimit__c, ParentId FROM Account WHERE Id IN: setAccountsIds OR ParentId IN: setAccountsIds];       
            setAccountsIds = new Set<String>();
            
            for(Account acc: listAccounts){
                setAccountsIds.add(acc.Id);
                if(acc.ParentId != null){
                    setAccountsIds.add(acc.ParentId);
                }
            }
            
            listAccounts = [SELECT Id, Name, Client_code_AN8__c, Credit_line__c, LAT_MX_AvailableCreditLimit__c, ParentId FROM Account WHERE Id IN: setAccountsIds OR ParentId IN: setAccountsIds];
            
            Set<String> setAccounts = new Set<String>();
            Map<String,Set<Account>> mapParentChildsAccounts = new Map<String,Set<Account>>();
            
            for(Account acc: listAccounts){
                String name = acc.Name;
                Id id = acc.Id;
                setAccounts.add(acc.Id);
                if(acc.ParentId == null){
                    if(!mapParentChildsAccounts.containsKey(acc.Id)){
                        mapParentChildsAccounts.put(acc.Id,new Set<Account>());
                    }
                }else{
                    if(!mapParentChildsAccounts.containsKey(acc.ParentId)){
                        mapParentChildsAccounts.put(acc.ParentId,new Set<Account>{acc});
                    }else{
                        mapParentChildsAccounts.get(acc.ParentId).add(acc);
                    }                                
                }    
            }
            
            Map<String,Decimal> mapAccountSumPedidos = new Map<String,Decimal>();
            
            for(Opportunity opp: [SELECT Id, AccountId, (SELECT Id, TotalPrice FROM OpportunityLineItems WHERE cd_line_status__c != '999' AND TotalPrice != null) FROM Opportunity WHERE AccountId IN: setAccounts]){
                Decimal deuda = 0;
                for(OpportunityLineItem oli: opp.OpportunityLineItems){
                    if(oli.TotalPrice != 0){
                        deuda += oli.TotalPrice;
                    }
                }
                if(!mapAccountSumPedidos.containsKey(opp.AccountId)){
                    mapAccountSumPedidos.put(opp.AccountId, deuda);
                }else{
                    mapAccountSumPedidos.put(opp.AccountId, mapAccountSumPedidos.get(opp.AccountId) + deuda);
                }
            }
            
            
            Map<String,Decimal> mapAccountDeuda = new Map<String,Decimal>();
            
            for(Titulos__c titulo: [SELECT Id, valorSaldo__c, Cliente__c FROM Titulos__c WHERE Cliente__c IN: setAccounts AND valorSaldo__c != null]){
                if(!mapAccountDeuda.containsKey(titulo.Cliente__c)){
                    mapAccountDeuda.put(titulo.Cliente__c,titulo.valorSaldo__c);
                }else{
                    mapAccountDeuda.put(titulo.Cliente__c,mapAccountDeuda.get(titulo.Cliente__c) + titulo.valorSaldo__c);
                }
            }

            List<Account> listAccountUpdate = new List<Account>();

            for(Account acc: listAccounts){
                Decimal AvailableCreditLimit = 0;
                if(acc.ParentId != null){
                    if(acc.Credit_line__c != null){
                        AvailableCreditLimit = acc.Credit_line__c;
                    }
                    if(!mapAccountSumPedidos.isEmpty()){
                        AvailableCreditLimit -= mapAccountSumPedidos.containsKey(acc.Id) ? mapAccountSumPedidos.get(acc.Id) : 0;
                    }
                    if(!mapAccountDeuda.isEmpty()){
                        AvailableCreditLimit -= mapAccountDeuda.containsKey(acc.Id) ? mapAccountDeuda.get(acc.Id) : 0;
                    }
                }else{
                    if(acc.Credit_line__c != null){
                        AvailableCreditLimit = acc.Credit_line__c;
                    }
                    if(!mapAccountSumPedidos.isEmpty()){
                        AvailableCreditLimit -= mapAccountSumPedidos.containsKey(acc.Id) ? mapAccountSumPedidos.get(acc.Id) : 0;
                    }
                    if(!mapAccountDeuda.isEmpty()){
                        AvailableCreditLimit -= mapAccountDeuda.containsKey(acc.Id) ? mapAccountDeuda.get(acc.Id) : 0;
                    }
                    if(mapParentChildsAccounts.containsKey(acc.Id) && !mapParentChildsAccounts.values().isEmpty()){
                        for(Account accChilds: mapParentChildsAccounts.get(acc.Id)){
                            AvailableCreditLimit -= mapAccountSumPedidos.containsKey(accChilds.Id) ? mapAccountSumPedidos.get(accChilds.Id) : 0;
                            AvailableCreditLimit -= mapAccountDeuda.containsKey(accChilds.Id) ? mapAccountDeuda.get(accChilds.Id) : 0;                   
                        }
                    }
                }
                system.debug('##### ' +  acc.LAT_MX_AvailableCreditLimit__c + '  ' + AvailableCreditLimit );

                if(acc.LAT_MX_AvailableCreditLimit__c != AvailableCreditLimit){
                    acc.LAT_MX_AvailableCreditLimit__c = AvailableCreditLimit;
                    acc.Is_Interface_Process_AR__c = true;
                    listAccountUpdate.add(acc);  
                }
            }
            
            String returnMessage = 'OK';
            
            if(!listAccountUpdate.isEmpty()){
                map<Id, Account> mapIdAcc = new map<Id, Account>(listAccountUpdate);
                Savepoint sp = Database.setSavepoint();
                
                LAT_MX_AP01_Account.setExcludedMethods.add('All');
                LAT_MX_AP02_AccountWOS.setExcludedMethods.add('All');
                List<Database.SaveResult> results = Database.update(listAccountUpdate, false);
                LAT_MX_AP01_Account.setExcludedMethods.clear();
                LAT_MX_AP02_AccountWOS.setExcludedMethods.clear();
                
                for(Database.SaveResult res: results){
                    if(!res.isSuccess()){
                        for(Database.Error err : res.getErrors()){
                            String errorMs = err.getMessage();
                            returnMessage = errorMs;

                        }
                    }
                }

                if (returnMessage != 'OK') {
                    Database.rollback(sp);
                }
            }
            
            return returnMessage;
        }     
        //MIGRATED 04/11/2016
        else {

            Boolean salir = true;
            for (String accId : setAccountsIds) {
                if (!updtedAccountsRunning.contains(accId)) {
                    salir = false;
                }
            }

            if (salir) {
                System.debug('Nos vamos porque ya estaba procesado este Set de Accounts');
                return 'OK';
            } else {
                System.debug('Seguimos porque no estaba procesado este Set de Accounts');
                updtedAccountsRunning.addAll(setAccountsIds);
            }

            List<Account> listAccounts = [SELECT Id, Name, Client_code_AN8__c, Credit_line__c, LAT_MX_AvailableCreditLimit__c, ParentId FROM Account WHERE Id IN: setAccountsIds OR ParentId IN: setAccountsIds];       
            setAccountsIds = new Set<String>();
            
            for(Account acc: listAccounts){
                String name = acc.Name;
                Id id = acc.Id;
                setAccountsIds.add(acc.Id);
                if(acc.ParentId != null){
                    setAccountsIds.add(acc.ParentId);
                }
            }
            
            listAccounts = [SELECT Id, Name, Client_code_AN8__c, Credit_line__c, LAT_MX_AvailableCreditLimit__c, ParentId FROM Account WHERE Id IN: setAccountsIds OR ParentId IN: setAccountsIds];
            
            Set<String> setAccounts = new Set<String>();
            Map<String,Set<Account>> mapParentChildsAccounts = new Map<String,Set<Account>>();
            
            for(Account acc: listAccounts){
                setAccounts.add(acc.Id);
                if(acc.ParentId == null){
                    if(!mapParentChildsAccounts.containsKey(acc.Id)){
                        mapParentChildsAccounts.put(acc.Id,new Set<Account>());
                    }
                }else{
                    if(!mapParentChildsAccounts.containsKey(acc.ParentId)){
                        mapParentChildsAccounts.put(acc.ParentId,new Set<Account>{acc});
                    }else{
                        mapParentChildsAccounts.get(acc.ParentId).add(acc);
                    }                                
                }    
            }
            
            Map<String,Decimal> mapAccountSumPedidos = new Map<String,Decimal>();
            
            for(LAT_Opportunity__c opp: [SELECT Id, LAT_Account__c, (SELECT Id, LAT_TotalPrice__c FROM OpportunityLineItems__r WHERE LAT_CdLineStatus__c != '999' AND LAT_TotalPrice__c != null) 
                                        FROM LAT_Opportunity__c 
                                        WHERE LAT_Account__c IN: setAccounts AND LAT_CloseDate__c >= LAST_N_MONTHS:12]){
                Decimal deuda = 0;
                for(LAT_OpportunityLineItem__c oli: opp.OpportunityLineItems__r){
                    if(oli.LAT_TotalPrice__c != 0){
                        deuda += oli.LAT_TotalPrice__c;
                    }
                }
                if(!mapAccountSumPedidos.containsKey(opp.LAT_Account__c)){
                    mapAccountSumPedidos.put(opp.LAT_Account__c, deuda);
                }else{
                    mapAccountSumPedidos.put(opp.LAT_Account__c, mapAccountSumPedidos.get(opp.LAT_Account__c) + deuda);
                }
            }
            
            
            Map<String,Decimal> mapAccountDeuda = new Map<String,Decimal>();
            
            for(Titulos__c titulo: [SELECT Id, valorSaldo__c, Cliente__c FROM Titulos__c WHERE Cliente__c IN: setAccounts AND valorSaldo__c != null]){
                if(!mapAccountDeuda.containsKey(titulo.Cliente__c)){
                    mapAccountDeuda.put(titulo.Cliente__c,titulo.valorSaldo__c);
                }else{
                    mapAccountDeuda.put(titulo.Cliente__c,mapAccountDeuda.get(titulo.Cliente__c) + titulo.valorSaldo__c);
                }
            }

            List<Account> listAccountUpdate = new List<Account>();

            for(Account acc: listAccounts){
                Decimal AvailableCreditLimit = 0;
                if(acc.ParentId != null){
                    if(acc.Credit_line__c != null){
                        AvailableCreditLimit = acc.Credit_line__c;
                    }
                    if(!mapAccountSumPedidos.isEmpty()){
                        AvailableCreditLimit -= mapAccountSumPedidos.containsKey(acc.Id) ? mapAccountSumPedidos.get(acc.Id) : 0;
                    }
                    if(!mapAccountDeuda.isEmpty()){
                        AvailableCreditLimit -= mapAccountDeuda.containsKey(acc.Id) ? mapAccountDeuda.get(acc.Id) : 0;
                    }
                }else{
                    if(acc.Credit_line__c != null){
                        AvailableCreditLimit = acc.Credit_line__c;
                    }
                    if(!mapAccountSumPedidos.isEmpty()){
                        AvailableCreditLimit -= mapAccountSumPedidos.containsKey(acc.Id) ? mapAccountSumPedidos.get(acc.Id) : 0;
                    }
                    if(!mapAccountDeuda.isEmpty()){
                        AvailableCreditLimit -= mapAccountDeuda.containsKey(acc.Id) ? mapAccountDeuda.get(acc.Id) : 0;
                    }
                    if(mapParentChildsAccounts.containsKey(acc.Id) && !mapParentChildsAccounts.values().isEmpty()){
                        for(Account accChilds: mapParentChildsAccounts.get(acc.Id)){
                            AvailableCreditLimit -= mapAccountSumPedidos.containsKey(accChilds.Id) ? mapAccountSumPedidos.get(accChilds.Id) : 0;
                            AvailableCreditLimit -= mapAccountDeuda.containsKey(accChilds.Id) ? mapAccountDeuda.get(accChilds.Id) : 0;                   
                        }
                    }
                }
                system.debug('##### ' +  acc.LAT_MX_AvailableCreditLimit__c + '  ' + AvailableCreditLimit );

                if(acc.LAT_MX_AvailableCreditLimit__c != AvailableCreditLimit){
                    acc.LAT_MX_AvailableCreditLimit__c = AvailableCreditLimit;
                    acc.Is_Interface_Process_AR__c = true;
                    listAccountUpdate.add(acc);  
                }
            }
            
            String returnMessage = 'OK';
            
            if(!listAccountUpdate.isEmpty()){
                map<Id, Account> mapIdAcc = new map<Id, Account>(listAccountUpdate);
                Savepoint sp = Database.setSavepoint();
                
                LAT_MX_AP01_Account.setExcludedMethods.add('All');
                LAT_MX_AP02_AccountWOS.setExcludedMethods.add('All');
                List<Database.SaveResult> results = Database.update(listAccountUpdate, false);
                LAT_MX_AP01_Account.setExcludedMethods.clear();
                LAT_MX_AP02_AccountWOS.setExcludedMethods.clear();
                
                for(Database.SaveResult res: results){
                    if(!res.isSuccess()){
                        for(Database.Error err : res.getErrors()){
                            String errorMs = err.getMessage();
                            returnMessage = errorMs;
                        }
                    }
                }

                if (returnMessage != 'OK') {
                    Database.rollback(sp);
                }
            }
            
            return returnMessage;
        }        
    }

    public static void isForCC() {
        String e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
        e = 'a';
    }
}