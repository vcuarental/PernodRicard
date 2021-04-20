/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRB del objeto Case
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/

public without sharing class LAT_BR_AP01_Case {
    /*********************************************************************************************************
    * Nombre del metodo: originalOwner
    * Descripcion: Cambia el Owner para el creador
    * Desarrollador: Rodrigo Aguirre
    * Fecha: 01/10/2013
    * Modo: before update
    ********************************************************************************************************/
    //public static void originalOwner(Map<Id, Case> triggerNewMap, Map<Id, Case> triggerOldMap){
        /*
        for(Case c: triggerNewMap.values()){
             system.debug('1 '+c.type+'2 '+c.Status );
            if(triggerNewMap.get(c.Id).Status == 'Reprovado' && triggerNewMap.get(c.Id).Type == 'Alteração - Cadastro de cliente'){
                c.OwnerId = c.CreatedById;
            }
        }
*/
    //}
    
    /*********************************************************************************************************
    * Nombre del metodo: updateStatusNovoCadastroCliente
    * Descripcion: Change the status field of the client to "Novo Cadastro" if meets a set of conditions
    * Desarrollador: Nicolas Javier Romero
    * Fecha: 28/11/2013
    * Modo: before update
    ********************************************************************************************************/
    //public static void updateStatusNovoCadastroCliente(List<Case> triggerNew){
        /*
        Set<Id> setIdAcc = new Set<Id>();
        

        for(Case caso :triggerNew){
            if(caso.Reason == 'Alt. tipo cliente' && (caso.Status == 'Fechado e cancelado' || caso.Status == 'Fechado e resolvido' || caso.Status == 'Reprovado')){
                setIdAcc.add(caso.AccountId);
            }
        }
        
        Map<Id, Account> mapIdAcc = new Map<Id, Account>([SELECT Id, Type, Status__c FROM Account WHERE Id IN: setIdAcc]);
        Id controladoriaId;
        try{controladoriaId = [SELECT Id FROM Group WHERE Name='Controladoria' AND Type='Queue'].Id;}catch(Exception e){}
        
        List<Account> listAccUpd = new List<Account>();
        for(Case caso :triggerNew){
             system.debug(Logginglevel.ERROR, '1 '+caso.type+'2 '+caso.Status );
            if(caso.Reason == 'Alt. tipo cliente' && (caso.Status == 'Fechado e cancelado' || caso.Status == 'Fechado e resolvido')){
                system.debug(Logginglevel.ERROR , 'caso.OwnerId: '+caso.OwnerId);
                if(caso.OwnerId == controladoriaId && mapIdAcc.containsKey(caso.AccountId) && mapIdAcc.get(caso.AccountId).Type == 'Outros'){
                    Account acc = mapIdAcc.get(caso.AccountId);
                    acc.Status__c = 'Novo Cadastro';
                    listAccUpd.add(acc);
                }
            }
        }
        
        system.debug('listAccUpd: '+listAccUpd);
        
        List<DataBase.saveresult> results = DataBase.update(listAccUpd, false);
        system.debug('results: '+results);
        for(DataBase.saveresult result: results){
            if(!result.isSuccess()){
                for(Database.Error error: result.getErrors()){
                    triggerNew[0].addError('Ocorreu um erro ao tentar atualizar o cliente: '+error.getMessage());
                }
            }
        }
*/
    //}
    
    /*********************************************************************************************************
    * Nombre del metodo: updateStatusCaseClose
    * Descripcion: 
    * Desarrollador: Bruno Vuono
    * Fecha: 10/07/2014
    * Modo: before update
    ********************************************************************************************************/
    //public static void UpdateStatusCaseClose(List<Case> triggerNew) {
/*
        QueueSobject controladoriaQueue;

        // TODO: move
        List<QueueSobject> tmpQueues = [Select id,Queue.id from QueueSobject where Queue.Name = 'Controladoria' limit 1];
        if(tmpQueues != null && tmpQueues.size() > 0){
            controladoriaQueue = tmpQueues[0];
            map<Id, RecordType> mapIdRtCase = new map<Id, RecordType>(Global_RecordTypeCache.getRtList('Case'));

            set<Id> setParentAcc = new set<Id>();
            for (Case cas : triggerNew ){
                if ('Solicitação de inativação de cliente'.equals(cas.Reason) && 'Fechado e resolvido'.equals(cas.Status) && mapIdRtCase.get(cas.RecordTypeid).DeveloperName == 'Alteracao_cadastro_de_clientes'  && cas.ownerId == controladoriaQueue.Queue.id){
                    setParentAcc.add(cas.AccountId);
                }
            }
            if(!setParentAcc.isEmpty()){
                List<Account> Accounts = [SELECT Id, Status__c,Type, RecordTypeId FROM Account WHERE Id IN: setParentAcc];
                for(Account con: Accounts){
                    con.Rating = 'Cliente inativo';
                    con.Status__c = 'Aprovado - Aguardando retorno do JDE';

                }
                update Accounts;
            }
        }
    */
    //}
    
    /*********************************************************************************************************
    * Nombre del metodo: updateStatusAccount
    * Descripcion: 
    * Desarrollador: Francisco Orzabal
    * Fecha: 12/06/2014
    * Modo: before update
    ********************************************************************************************************/
    //public static void updateStatusAccount(List<Case> triggerNew) {
    /*
        Set<Id> setOwnerIds = new Set<Id>();
        Set<Id> setAccIds = new Set<Id>();
        Map<String, String> mapQueues;
        Map<Id, Account> mapAccs;
        List<Queuesobject> lQueueList;
        List<Account> listAccToUpdate;
        
        for (Case c : triggerNew) {
            setOwnerIds.add(c.OwnerId);
            setAccIds.add(c.AccountId);
        }
        
        lQueueList = [SELECT Id, queue.Name, QueueId 
                        FROM QueueSobject 
                        WHERE QueueId =: setOwnerIds];
        
        mapQueues = new Map<String, String>();      
        for (Queuesobject q : lQueueList) {
            mapQueues.put(q.QueueId, q.queue.name); 
        }           
        
        mapAccs = new Map<Id, Account>([SELECT Id, Status__c, Type, RecordTypeId, Channel__c FROM Account WHERE Id IN: setAccIds]);
        
        listAccToUpdate = new List<Account>();
        
        
        for (Case c : triggerNew) {

            if(mapAccs.get(c.AccountId).Status__c == 'Em análise - Crédito e Cobrança'){
                    listAccToUpdate.add(new account(Id = c.AccountId, Status__c = 'Em análise - Controladoria'));

                }else{
                   listAccToUpdate.add(new account(Id = c.AccountId, Status__c = 'Em análise - Crédito e Cobrança'));
                }  
         
            if (mapQueues.containsKey(c.OwnerId) && mapQueues.get(c.OwnerId) == 'Customer service' && c.Status == 'Fechado e resolvido') {
                // OFF TRADE
                if (mapAccs.get(c.AccountId).RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Off_Trade') 
                        && (mapAccs.get(c.AccountId).Channel__c == 'Off Trade'|| mapAccs.get(c.AccountId).Channel__c == 'Distribution')) {
                    if(c.Type == 'Alteração - Cadastro de cliente'){
                        listAccToUpdate.add(new account(Id = c.AccountId, Status__c = 'Aprovado - Aguardando retorno do JDE'));

                    } else {
                       listAccToUpdate.add(new account(Id = c.AccountId, Status__c = 'Em análise - Crédito e Cobrança'));

                    }                
                // ON TRADE
                } else if (mapAccs.get(c.AccountId).RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'On_Trade') && mapAccs.get(c.AccountId).Channel__c == 'On Trade' && mapAccs.get(c.AccountId).Type == 'LD') {
                    
                    listAccToUpdate.add(new account(Id = c.AccountId, Status__c = 'Em análise - Controladoria'));
                }

                else if (mapAccs.get(c.AccountId).Channel__c == 'Eventos' && mapAccs.get(c.AccountId).Type == 'LD') {
                    /*
                    System.debug('Enter1');
                    if (mapAccs.get(c.AccountId).Status__c == 'Em análise - Crédito e Cobrança')
                    {
                       listAccToUpdate.add(new account(Id = c.AccountId, Status__c = 'Em análise - Controladoria'));
                    }
                    else{
                       listAccToUpdate.add(new account(Id = c.AccountId, Status__c = 'Em análise - Crédito e Cobrança'));

                    }  
                    *//*
                }
                
            } else if (mapQueues.containsKey(c.OwnerId) && mapQueues.get(c.OwnerId) == 'Controladoria' && c.Status == 'Fechado e resolvido'&&  mapAccs.get(c.AccountId).Channel__c != 'Eventos'){
                   listAccToUpdate.add(new account(Id = c.AccountId, Status__c = 'Aprovado - Aguardando retorno do JDE'));

            }
                    
        }
                
        if (!listAccToUpdate.isEmpty()) {
            DataBase.update(listAccToUpdate);
        }
    */
    //}
    
    /*********************************************************************************************************
    * Nombre del metodo: shareWithAccountOwner
    * Descripcion: Comparte el caso con el owner de la cuenta. 
    * Desarrollador: Francisco Orzabal
    * Fecha: 12/06/2014
    * Modo: After insert
    ********************************************************************************************************/
    //public static void shareWithAccountOwner(List<Case> triggerNew) {
        /*
        Set<Id> setAccIds = new Set<Id>();
        Map<Id, Account> mapAccs;
        List<CaseShare> listCaseShare = new List<CaseShare>();
        
        for(Case c : triggerNew){
            setAccIds.add(c.AccountId);            
        }
        
        mapAccs = new Map<Id, Account>([SELECT Id, OwnerId, Status__c
                                        FROM Account 
                                        WHERE Id IN: setAccIds]);
        
        system.debug(Logginglevel.ERROR, 'mapAccs: ' + mapAccs);
        if(!mapAccs.isEmpty()){
            for(Case c : triggerNew){
                CaseShare share = new CaseShare();
                share.CaseId = c.Id;
                share.UserOrGroupId = mapAccs.containskey(c.AccountId) && mapAccs.get(c.AccountId).OwnerId != null ? mapAccs.get(c.AccountId).OwnerId: '';
                share.CaseAccessLevel = 'Read';                                                           
                listCaseShare.add(share);
            }
                    
            if(!listCaseShare.isEmpty()){
                DataBase.insert(listCaseShare, false);
            }
        }
*/
    //}

    //MIGRATED 02/11/2016 
    public static void originalOwner(Map<Id, LAT_Case__c> triggerNewMap, Map<Id, LAT_Case__c> triggerOldMap){
        for(LAT_Case__c c: triggerNewMap.values()){
             system.debug('1 '+c.LAT_type__c+'2 '+c.LAT_Status__c );
            if(triggerNewMap.get(c.Id).LAT_Status__c == 'Reprovado' && triggerNewMap.get(c.Id).LAT_Type__c == 'Alteração - Cadastro de cliente'){
                c.OwnerId = c.CreatedById;
            }
        }
    }
    
    //MIGRATED 02/11/2016 
    public static void updateStatusNovoCadastroCliente(List<LAT_Case__c> triggerNew){
        Set<Id> setIdAcc = new Set<Id>();
        
        for(LAT_Case__c caso :triggerNew){
            if(caso.LAT_Reason__c == 'Alt. tipo cliente' && (caso.LAT_Status__c == 'Fechado e cancelado' || caso.LAT_Status__c == 'Fechado e resolvido' || caso.LAT_Status__c == 'Reprovado')){
                setIdAcc.add(caso.LAT_Account__c);
            }
        }
        
        Map<Id, Account> mapIdAcc = new Map<Id, Account>([SELECT Id, Type, Status__c FROM Account WHERE Id IN: setIdAcc]);
        Id controladoriaId;
        try{controladoriaId = [SELECT Id FROM Group WHERE Name='Controladoria' AND Type='Queue'].Id;}catch(Exception e){}
        
        List<Account> listAccUpd = new List<Account>();
        for(LAT_Case__c caso :triggerNew){
             system.debug(Logginglevel.ERROR, '1 '+caso.LAT_type__C+'2 '+caso.LAT_Status__c );
            if(caso.LAT_Reason__c == 'Alt. tipo cliente' && (caso.LAT_Status__c == 'Fechado e cancelado' || caso.LAT_Status__c == 'Fechado e resolvido')){
                system.debug(Logginglevel.ERROR , 'caso.OwnerId: '+caso.OwnerId);
                if(caso.OwnerId == controladoriaId && mapIdAcc.containsKey(caso.LAT_Account__C) && mapIdAcc.get(caso.LAT_Account__C).Type == 'Outros'){
                    Account acc = mapIdAcc.get(caso.LAT_Account__C);
                    acc.Status__c = 'Novo Cadastro';
                    listAccUpd.add(acc);
                }
            }
        }
        
        system.debug('listAccUpd: '+listAccUpd);
        
        List<DataBase.saveresult> results = DataBase.update(listAccUpd, false);
        system.debug('results: '+results);
        for(DataBase.saveresult result: results){
            if(!result.isSuccess()){
                for(Database.Error error: result.getErrors()){
                    triggerNew[0].addError('Ocorreu um erro ao tentar atualizar o cliente: '+error.getMessage());
                }
            }
        }
    }

    //MIGRATED 02/11/2016 
    public static void UpdateStatusCaseClose(List<LAT_Case__c> triggerNew) {
        QueueSobject controladoriaQueue;
        List<QueueSobject> tmpQueues = [Select id,Queue.id from QueueSobject where Queue.Name = 'Controladoria' limit 1];
        if(tmpQueues != null && tmpQueues.size() > 0){
            controladoriaQueue = tmpQueues[0];
            map<Id, RecordType> mapIdRtCase = new map<Id, RecordType>(Global_RecordTypeCache.getRtList('LAT_Case__c'));

            set<Id> setParentAcc = new set<Id>();
            for (LAT_Case__c cas : triggerNew ){
                if ('Solicitação de inativação de cliente'.equals(cas.LAT_Reason__c) && 'Fechado e resolvido'.equals(cas.LAT_Status__c) && mapIdRtCase.get(cas.RecordTypeid).DeveloperName == 'Alteracao_cadastro_de_clientes'  && cas.ownerId == controladoriaQueue.Queue.id){
                    setParentAcc.add(cas.LAT_Account__c);
                }
            }
            if(!setParentAcc.isEmpty()){
                List<Account> Accounts = [SELECT Id, Status__c,Type, RecordTypeId FROM Account WHERE Id IN: setParentAcc];
                for(Account con: Accounts){
                    con.Rating = 'Cliente Inativo';
                    con.Status__c = 'Aprovado - Aguardando retorno do JDE';

                }
                update Accounts;
            }
        }    
    }
    //MIGRATED 02/11/2016 
    public static void updateStatusAccount(List<LAT_Case__c> triggerNew) {
        system.debug('UpdateStatusAccount+++' + triggerNew.size());

        Set<Id> setOwnerIds = new Set<Id>();
        Set<Id> setAccIds = new Set<Id>();
        Map<String, String> mapQueues;
				Map<Id, Account> mapAccs;
				Map<Id, List<LAT_Case__c>> mapCases;
        List<Queuesobject> lQueueList;
        Set<Account> listAccToUpdate;
				String legalOwnerId, admOwnerId;
				
        for (LAT_Case__c c : triggerNew) {
            setOwnerIds.add(c.OwnerId);
            setAccIds.add(c.LAT_Account__c);
        }
        
        lQueueList = [SELECT Id, queue.Name, QueueId 
                        FROM QueueSobject 
                        WHERE QueueId =: setOwnerIds];
        
        mapQueues = new Map<String, String>();      
        for (Queuesobject q : lQueueList) {
						mapQueues.put(q.QueueId, q.queue.name); 
        }           
				
				mapAccs = new Map<Id, Account>([SELECT Id, Type, Status__c, RecordTypeId, Channel__c, LAT_Account__r.LAT_DirectSale__c 
																				FROM Account WHERE Id IN: setAccIds]);
				mapCases = new Map<Id, List<LAT_Case__c>>();
        for (LAT_Case__c lc : [SELECT Id, LAT_Status__c, OwnerId, Owner.Name, LAT_Account__c FROM LAT_Case__c WHERE LAT_Account__c IN :setAccIds]) {
					List<LAT_Case__c> cases = new List<LAT_Case__c>();
					if (mapCases.containsKey(lc.LAT_Account__c)) {
						cases = mapCases.get(lc.LAT_Account__c);
					}
          cases.add(lc);
					mapCases.put(lc.LAT_Account__c, cases);
				}
				system.debug('CASES mapCases === '+mapCases);

        Map<Id, LAT_BR_SegmentationBehaviorHandler.OldAccountTyping> mapAccsBehavior = LAT_BR_SegmentationBehaviorHandler.getMapOfOldTyping(mapAccs.values());
        listAccToUpdate = new Set<Account>();
        
        for (LAT_Case__c c : triggerNew) {            
            if (mapQueues.containsKey(c.OwnerId) && mapQueues.get(c.OwnerId) == 'Crédito e Cobrança' && c.LAT_Status__c == 'Fechado e resolvido') {
              	system.debug('Crédito e Cobrança');
              	// Case of trade direct sales
              	if(c.LAT_Type__c == 'Alteração - Cadastro de cliente'){
                    listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Aprovado - Aguardando retorno do JDE'));
                    system.debug('Enter Here Status1 entramos');
                } else {
                    system.debug('Enter Here else');
                    //Es un alta de cliente  (NOVO CADASTRO)
                    if (mapAccs.get(c.LAT_Account__c).Status__c == 'Em análise - Crédito e Cobrança') {
                        system.debug('Enter Here solo ontrade' + mapAccs.get(c.LAT_Account__c).Status__c);
                        listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Em aprovação - Financeiro', Checked_over_Credit_and_collection__c = true));
                    }
                }
            } else if (mapQueues.containsKey(c.OwnerId) && mapQueues.get(c.OwnerId) == 'Customer service' && c.LAT_Status__c == 'Fechado e resolvido') {
                system.debug('Enter Customer Service +++ Fechado e resolvido');
                if (c.LAT_Type__c == 'Alteração - Cadastro de cliente') {
                    listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Aprovado - Aguardando retorno do JDE'));
                } else {
                    //listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Em análise - ADM Vendas'));
                    // IG - Nuevo flujo de aprobacion
                    if ((mapAccsBehavior.get(c.LAT_Account__c).recordTypeDeveName == 'Off_Trade' && (mapAccsBehavior.get(c.LAT_Account__c).Channel == 'Off Trade' || mapAccsBehavior.get(c.LAT_Account__c).Channel == 'Distribution')) ||
                        (mapAccsBehavior.get(c.LAT_Account__c).recordTypeDeveName == 'Eventos' && mapAccsBehavior.get(c.LAT_Account__c).Channel == 'Eventos' && mapAccsBehavior.get(c.LAT_Account__c).directSales != null && mapAccsBehavior.get(c.LAT_Account__c).directSales) ||
                        (mapAccsBehavior.get(c.LAT_Account__c).recordTypeDeveName == 'On_Trade' && mapAccsBehavior.get(c.LAT_Account__c).Channel == 'On Trade' && mapAccsBehavior.get(c.LAT_Account__c).directSales != null && mapAccsBehavior.get(c.LAT_Account__c).directSales)) {
                      listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Em análise - Crédito e Cobrança', Checked_over_Sales_Administration__c = true));
                    } else if ((mapAccsBehavior.get(c.LAT_Account__c).recordTypeDeveName == 'Eventos' && mapAccsBehavior.get(c.LAT_Account__c).Channel == 'Eventos' && mapAccsBehavior.get(c.LAT_Account__c).type == 'LD') ||
                               (mapAccsBehavior.get(c.LAT_Account__c).recordTypeDeveName == 'On_Trade' && mapAccsBehavior.get(c.LAT_Account__c).Channel == 'On Trade' && mapAccsBehavior.get(c.LAT_Account__c).type == 'LD')) {
                      listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Em análise - ADM Vendas'));
                    }
                }
            } else if (mapQueues.containsKey(c.OwnerId) && mapQueues.get(c.OwnerId) == 'Administração de Vendas' && c.LAT_Status__c == 'Fechado e resolvido'){
                // Nueva demanda alteracion de propietario
                if (c.LAT_Type__c == 'Alteração - Cadastro de cliente') {
                    listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Aprovado - Aguardando retorno do JDE'));
                } else {
									// OFF TRADE
									// IG - Nuevo flujo de aprobacion
									// Si hay una demanda legal y ya fue cerrada pasa a Em análise - Controladoria
									Boolean haveLegalDemand = false;
									Boolean isClosedLegalDemand = false;
                  
									if (mapCases.containsKey(c.LAT_Account__c)) {
										for (LAT_Case__c cs : mapCases.get(c.LAT_Account__c)) {
											system.debug('CASES === '+cs.Owner.Name+' === '+ cs.LAT_Status__c);
											if (cs.Owner.Name == 'Legal') {	
												haveLegalDemand = true;
												if (cs.LAT_Status__c == 'Fechado e resolvido') {
													isClosedLegalDemand = true;
												}
                      } 
										}
									}
									
									if (!haveLegalDemand || (haveLegalDemand && isClosedLegalDemand)) {
										listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Em análise - Controladoria', Checked_over_Sales_Administration__c = true));
									} else if (haveLegalDemand && !isClosedLegalDemand) {
                    listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Em análise - Legal', Checked_over_Sales_Administration__c = true));
                  }                                      
                  // IG - end Nuevo flujo de aprobacion
                } 
                
            } else if (mapQueues.containsKey(c.OwnerId) && mapQueues.get(c.OwnerId) == 'Controladoria' && c.LAT_Status__c == 'Fechado e resolvido'){//&&  mapAccs.get(c.LAT_Account__c).Channel__c != 'Eventos'){
              listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Aprovado - Aguardando retorno do JDE'));
            } else if (mapQueues.containsKey(c.OwnerId) && mapQueues.get(c.OwnerId) == 'Fiscal' && c.LAT_Status__c == 'Fechado e resolvido'){//&&  mapAccs.get(c.LAT_Account__c).Channel__c != 'Eventos'){
              listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Aprovado - Aguardando retorno do JDE'));
            } else if (mapQueues.containsKey(c.OwnerId) && mapQueues.get(c.OwnerId) == 'Legal' && c.LAT_Status__c == 'Fechado e resolvido'){
							if (mapCases.containsKey(c.LAT_Account__c)) {
								for (LAT_Case__c cs : mapCases.get(c.LAT_Account__c)) {
									if (cs.Owner.Name == 'Administração de Vendas' && cs.LAT_Status__c == 'Fechado e resolvido') {
										listAccToUpdate.add(new account(Id = c.LAT_Account__c, Status__c = 'Em análise - Controladoria', Checked_over_Sales_Administration__c = true));
									} 
								}
							}
						}
        }
                
        if (!listAccToUpdate.isEmpty()) {
            List<Account> toUpdate = new List<Account>();
            toUpdate.addAll(listAccToUpdate);
            DataBase.update(toUpdate);
        }
    }

    //MIGRATED 02/11/2016 
    public static void shareWithAccountOwner(List<LAT_Case__c> triggerNew) {
        
        Set<Id> setAccIds = new Set<Id>();
        Map<Id, Account> mapAccs;
        List<LAT_Case__Share> listCaseShare = new List<LAT_Case__Share>();
        
        for(LAT_Case__c c : triggerNew){
            setAccIds.add(c.LAT_Account__c);            
        }
        
        mapAccs = new Map<Id, Account>([SELECT Id, OwnerId, Status__c
                                        FROM Account 
                                        WHERE Id IN: setAccIds]);
        
        system.debug(Logginglevel.ERROR, 'mapAccs: ' + mapAccs);
        if(!mapAccs.isEmpty()){
            for(LAT_Case__c c : triggerNew){
                LAT_Case__Share share = new LAT_Case__Share();
                share.ParentId = c.Id;
                share.UserOrGroupId = mapAccs.containskey(c.LAT_Account__c) && mapAccs.get(c.LAT_Account__c).OwnerId != null ? mapAccs.get(c.LAT_Account__c).OwnerId: '';
                share.AccessLevel = 'Read';                                                           
                listCaseShare.add(share);
            }
                    
            if(!listCaseShare.isEmpty()){
                DataBase.insert(listCaseShare, false);
            }
        }
    }
    //MIGRATED 02/11/2016 
    public static void shareWithAccountOwner(Map<Id,LAT_Case__c> triggerNew, Map<Id,LAT_Case__c> triggerOld) {
        List<LAT_Case__Share> listCaseShare = new List<LAT_Case__Share>();
        List<String> accIds = new List<String>();
        Map<String, String> accountOwners = new Map<String,String>();
      
        for(LAT_Case__c cs : triggerNew.values()){
            if(cs.LAT_Account__c != null){
                accIds.add(cs.LAT_Account__c);
            }
        }

        for(Account acc: [Select id, OwnerId from Account where id in : accIds]){
            accountOwners.put(acc.id, acc.OwnerId);
        }

        for(LAT_Case__c lcas : triggerNew.values()){
            if(triggerOld.get(lcas.id).ownerId != lcas.ownerId){
                if(accountOwners.get(lcas.LAT_Account__c) != null && accountOwners.get(lcas.LAT_Account__c) == triggerOld.get(lcas.id).ownerId){
                    LAT_Case__Share share = new LAT_Case__Share();
                    share.ParentId = lcas.Id;
                    share.UserOrGroupId = accountOwners.get(lcas.LAT_Account__c);
                    share.AccessLevel = 'Edit';    
                    listCaseShare.add(share);         
                }
            }
        }
        
         if(!listCaseShare.isEmpty()){
            DataBase.insert(listCaseShare, false);
        }
    }

    public static void sendAccountToJDE(List<LAT_Case__c> triggerNew) {
        Set<Id> accountIds = new Set<Id>();
        for (LAT_Case__c c : triggerNew ) {
            if(c.LAT_SendAccountToJDE__c) {
                //Send account to JDe
                accountIds.add(c.LAT_Account__c);
                //Once Integrated remove the flag.
                c.LAT_SendAccountToJDE__c = false;
            }
        }

        if (accountIds.size() > 0) {
            List<Account> accountsToIntegrate = [SELECT Id, Name, Status__c, Client_country_an8__c FROM Account WHERE Id IN:accountIds];
            for (Account acc : accountsToIntegrate) {
                if(acc.Client_country_an8__c != null) {
                    acc.Status__c = 'Aprovado - Aguardando retorno do JDE';
                    update acc;
                }
            }
        } 
    }

    public static void loadClientType(List<LAT_Case__c> triggerNew) {
        Set<Id> accountIds = new Set<Id>();
        for (LAT_Case__c c : triggerNew ) {
            if(c.LAT_SendAccountToJDE__c) {
                accountIds.add(c.LAT_Account__c);
            }
        }

        if(accountIds.size() >0) {
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, LAT_Account__r.LAT_BR_Segmentation__r.Client_Type__c FROM Account WHERE Id IN :accountIds]);
            for (LAT_Case__c c : triggerNew ){
                if(accMap.get(c.LAT_Account__c) != null) {
                    c.LAT_BR_ClientType__c = accMap.get(c.LAT_Account__c).LAT_Account__r.LAT_BR_Segmentation__r.Client_Type__c;
                }
            }
        }
    }

    public static void setQueueResponsable(Map<Id,LAT_Case__c> triggerNew, Map<Id,LAT_Case__c> triggerOld) {
        if(trigger.isInsert) {
            updateQueueResponsable(triggerNew);
        } else {
            for(LAT_Case__c c : triggerNew.values()){
                if(c.OwnerId != triggerOld.get(c.Id).OwnerId) {
                    updateQueueResponsable(triggerNew);
                    break;
                }
            }
        }
    }

    public static void updateQueueResponsable(Map<Id,LAT_Case__c> triggerNew) {
        System.debug('%%%% Entramos en updateQueueResponsable');
        List<UDC__c> udcs = [SELECT Name, Descricao2__c, CodDefUsuario__c FROM UDC__c WHERE CodProd__c = 'CASE' AND CodUs__c = 'FN' AND Internal_Id__c LIKE '1-%'];
        Map<String, String> mapUdc = new Map<String, String> ();
        for(UDC__c u : udcs){
            mapUdc.put(u.CodDefUsuario__c, u.Descricao2__c);
        }
        for(LAT_Case__c c : triggerNew.values()) {
            System.debug('%%%% c.OwnerId : ' + c.OwnerId);
            System.debug('%%%% mapUdc.get(c.OwnerId) : ' + mapUdc.get(c.OwnerId));
            if(mapUdc.get(c.OwnerId) != null) {
                c.LAT_QueueResponsable__c = mapUdc.get(c.OwnerId);
            }
        }   
    }

    public static void checkCaseForOwnerChange(){  
        Set<Id> accountIds = new Set<Id>();
        
        for (LAT_Case__c c :LAT_CaseTriggerHandler.triggerNew ){
            accountIds.add(c.LAT_Account__c);
        }

        Map<Id, LAT_Case__c> caseMap = new Map<Id,LAT_Case__c>([select id, lat_account__c from lat_case__c where LAT_Reason__c = 'Alt. Proprietário' and lat_status__c = 'Fechado e resolvido' and lat_account__c in :accountIds and createddate = THIS_MONTH]);
            
        for (LAT_Case__c ct :LAT_CaseTriggerHandler.triggerNew ){
            for(LAT_Case__c cm :caseMap.values()){
                if(ct.LAT_Account__c == cm.LAT_Account__c){
                    ct.addError(Label.LAT_BR_VFC_Only_One_Owner_Change_Per_Month);
                }
            }
        }
    }

}