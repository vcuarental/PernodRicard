global without sharing class LAT_ClientByRegionHandler {


	/*
	* deleteClientByRegion
	*/
	WebService static String deleteClientByRegion(String clientId) {

		Id pId = UserInfo.getProfileId();
		String profileName = [Select Name from Profile where Id =: pId].Name;
		String message = '';

		if(profileName == 'LAT_BR2_TradeCategoria' || profileName == 'LAT_SystemAdministrator'){
			List<LAT_ClientByRegion__c> cBR = [Select id, (select id from Clientes_Foco__r) from LAT_ClientByRegion__c where Id =: clientId];
			if(cBR.size() > 0) {
				LAT_ClientByRegion__c clientToDelete = cBR.get(0);
				List<LAT_AccountInAction__c> childsToDelete = new List<LAT_AccountInAction__c>();
				if(clientToDelete.Clientes_Foco__r.size() > 0) {
					childsToDelete = clientToDelete.Clientes_Foco__r;
				}
				delete clientToDelete;
				delete childsToDelete;
			}
		} else {
			message = 'Seu perfil não pode excluir este cliente';
		}

		return message;
	}


    public static void assignRegionalManager(List<LAT_ClientByRegion__c> triggerNew) {
        /*List<String> regionalUDC = new List<String>();

        for (LAT_ClientByRegion__c cbr: triggerNew) {
            regionalUDC.add(cbr.LAT_BR_RegionalClientOnPremise__c);
        }

        Map<String, String> namesList = new Map<String, String>();
        for (UDC__c udc: [SELECT id, Name FROM UDC__c WHERE id IN: regionalUDC]) {
            namesList.put(udc.Name + ' - AP', udc.id);
        }

        Map<String, String> UDCtoSupervisor = new Map<String, String>();
        for (LAT_RegionalSupervisor__c sup:  [SELECT id, Name, Supervisor__c FROM LAT_RegionalSupervisor__c WHERE Name IN: namesList.keyset()]) {
            UDCtoSupervisor.put(namesList.get(sup.Name), sup.Supervisor__c);
        }*/


        Map<String, String> namesList = new Map<String, String>();
		Map<String, String> recordTypeMap = new Map<String, String>();

        for (LAT_ClientByRegion__c cbr: triggerNew) {
            namesList.put(cbr.LAT_RegionalClientOnPremise__c, cbr.id);
			recordTypeMap.put(cbr.id, cbr.RecordTypeId);
        }
		Map<Id, RecordType> rTypes = new Map<Id, RecordType> ([Select Id, Name, DeveloperName from RecordType where Id in :recordTypeMap.values()]);

        Map<String, LAT_RegionalSupervisor__c> regiontoSupervisor = new Map<String, LAT_RegionalSupervisor__c>();
        for (LAT_RegionalSupervisor__c sup:  [SELECT id, Name, Supervisor__c, LAT_RegionalClientOnPremise__c FROM LAT_RegionalSupervisor__c WHERE Name IN: namesList.keyset()]) {
            regiontoSupervisor.put(sup.LAT_RegionalClientOnPremise__c, sup);
        }

        for (LAT_ClientByRegion__c cbr: triggerNew) {
			if(rTypes.containsKey(cbr.RecordTypeId) && rTypes.get(cbr.RecordTypeId).developerName == 'LAT_OnTrade'){
				if (regiontoSupervisor.get(cbr.LAT_RegionalClientOnPremise__c) != null && cbr.LAT_RegionalSupervisor2__c == null) {
	                //cbr.LAT_RegionalManager__c = regiontoSupervisor.get(cbr.LAT_RegionalClientOnPremise__c).Supervisor__c;
					// add again pirate
			        cbr.LAT_RegionalSupervisor2__c = regiontoSupervisor.get(cbr.LAT_RegionalClientOnPremise__c).Supervisor__c;
	            }
			}

        }
    }

    public static void updateNames(List<LAT_ClientByRegion__c> triggerNew){
        /*List<String> ids = new List<String>();
        for(LAT_ClientByRegion__c cbr: triggerNew){
            ids.add(cbr.LAT_Regional__c);
        }

        Map<Id, UDC__c> udcMap = new Map<Id, UDC__c>([SELECT id, Name FROM UDC__c WHERE id IN: ids]);
        for(LAT_ClientByRegion__c cbr: triggerNew){
            cbr.name = udcMap.get(cbr.LAT_Regional__c).Name;
        }

        for(LAT_ClientByRegion__c cbr: triggerNew){
            cbr.name = cbr.LAT_RegionalClientOnPremise__c;
        }*/
    }

    public static void calculateAddedByRegion(List<LAT_AccountInAction__c> triggerNew){
        Set<String> ids = new Set<String>();
        List<LAT_ClientByRegion__c> cbrToUpdate = new List<LAT_ClientByRegion__c>();

        for(LAT_AccountInAction__c acc : triggerNew){
            ids.add(acc.LAT_ClientByRegion__c);
        }

        Map<id, LAT_ClientByRegion__c> clientMap = new Map<id, LAT_ClientByRegion__c>([SELECT id, LAT_Realizado__c FROM LAT_ClientByRegion__c WHERE id IN: ids]);

        for (LAT_ClientByRegion__c cbr: [SELECT id, Name, LAT_Realizado__c, LAT_Status__c, (select id, LAT_Status__c from Clientes_Foco__r) FROM LAT_ClientByRegion__c WHERE id IN: ids]) {
          Integer counter = 0;
          for (LAT_AccountInAction__c aiac: cbr.Clientes_Foco__r) {
            // if (aiac.LAT_Status__c == 'Cliente Validado') {
            //   counter ++;
            // }
			counter ++;
          }
          clientMap.get(cbr.id).LAT_Realizado__c = counter;//cbr.Clientes_Foco__r.size();
          cbrToUpdate.add(clientMap.get(cbr.id));
        }

        try {
            update cbrToUpdate;
        } catch (Exception e){
            LAT_DebugUtil.addException('LAT_ClientByRegionHandler-closeTask', e, '-1');
        }
    }

    webService static String validateSendToApproval(String regId) {

        // This method does the validation of the planed amounts against done amount.
        // Done ammount is calculated counting how many Focus Clients have been validated for this region.
        List<LAT_ClientByRegion__c> toValidate = [SELECT id, Name, LAT_Remaining__c, LAT_RegionalClientOnPremise__c, LAT_Regional__c, LAT_Regional__r.Name FROM LAT_ClientByRegion__c WHERE id =: regId];
        String returnMessage = '';

        if (!toValidate.isEmpty()) {
            LAT_ClientByRegion__c cbr = toValidate.get(0);
            String regionName = cbr.LAT_RegionalClientOnPremise__c != null ? cbr.LAT_RegionalClientOnPremise__c : cbr.LAT_Regional__r.Name;
            if (cbr.LAT_Remaining__c > 0) {
                returnMessage += '\nQuantidade de clientes validados menor que o planejado.\n';//'\n- ' + regionName + ' tem mais Planejados que Realizados\n';
            } else if (cbr.LAT_Remaining__c < 0) {
                returnMessage += '\nQuantidade de clientes validados maior que o planejado.\n';
            }
        }

        return returnMessage;
    }

    webService static String closeTask(String taskId) {
        String returnMessage = '';

        // This process may come from two places. Closing the task or, clicking "Clientes Validados" button on LAT_ClientByRegion
        List<Task> taskList = [SELECT id, WhatId, status, OwnerId FROM Task WHERE id =: taskId AND status != 'Completed' AND status != 'Concluido'];
        List<LAT_ClientByRegion__c> cbrList = [SELECT id, Name, LAT_Status__c, LAT_Remaining__c, LAT_TaskCreated__c,
                                                    Promotional_Action__r.LAT_StartDate__c, RecordType.DeveloperName,
                                                    (select id, LAT_Status__c, LAT_NoValidationReason__c from Clientes_Foco__r)
                                                  FROM LAT_ClientByRegion__c WHERE id =: taskId AND (LAT_Status__c = 'Em validação' OR LAT_Status__c = 'Não Aprovado')];



		// One of the two list must have some record
        if (!taskList.isEmpty() || !cbrList.isEmpty()) {
            List<LAT_ClientByRegion__c> toUpdate = new List<LAT_ClientByRegion__c>();
            Task tk = null;
            if (!taskList.isEmpty()) {
              tk = taskList.get(0);
              toUpdate = [SELECT id, Name, LAT_Status__c, LAT_Remaining__c, LAT_TaskCreated__c,
                                  Promotional_Action__r.LAT_StartDate__c, RecordType.DeveloperName,
                                  (select id, LAT_Status__c, LAT_NoValidationReason__c from Clientes_Foco__r)
                                FROM LAT_ClientByRegion__c WHERE id =: tk.WhatId];
            } else {
              toUpdate = cbrList;
              List<Task> tkList = [SELECT id FROM Task WHERE whatId =: taskId AND status != 'Completed' AND status != 'Concluido' LIMIT 1];
              if (!tkList.isEmpty()) {
                tk = tkList.get(0);
              }
            }

            if (!toUpdate.isEmpty()) {
                SavePoint sp = Database.setSavePoint();
                try {

                    List<LAT_AccountInAction__c> aiaToUpdate = new List<LAT_AccountInAction__c>();
                    LAT_ClientByRegion__c cbr = new LAT_ClientByRegion__c();
                    if (!toUpdate.isEmpty()) {
                      cbr = toUpdate.get(0);
					  cbr.LAT_Status__c = 'Validado';
					  update cbr;
                    //   // In case of On trade record an approval process is fired
                    //   if ((cbr.RecordType.DeveloperName != 'LAT_OnTrade')) {
                    //     cbr.LAT_Status__c = 'Validado';
                    //     update cbr;
					  //
                    //     // Every Focus Client that is not marked for approval or validated must be changed to not aproved
                    //     // and if a client is not marqued as validated, then it must have a NotValidationReason
                    //     for (LAT_AccountInAction__c acc: cbr.Clientes_Foco__r) {
                    //       if (acc.LAT_Status__c != 'Cliente Validado' && acc.LAT_Status__c != 'Cliente Em Aprovação' && acc.LAT_NoValidationReason__c != '' && acc.LAT_NoValidationReason__c != null) {
                    //           acc.LAT_Status__c = 'Cliente não aprovado';
                    //           aiaToUpdate.add(acc);
                    //       } else if (acc.LAT_Status__c != 'Cliente Validado' && acc.LAT_Status__c != 'Cliente Em Aprovação' && (acc.LAT_NoValidationReason__c == '' || acc.LAT_NoValidationReason__c == null)){
                    //           Database.rollback(sp);
                    //           returnMessage = 'Favor informar o “Motivo não validação (Planejamento)” para cada cliente não validado.';
                    //           break;
                    //       }
                    //     }
                    //   } else {
					  //
                    //     // Every Focus Client that is not marked for approval or validated must be changed to not aproved
                    //     for (LAT_AccountInAction__c acc: cbr.Clientes_Foco__r) {
                    //       if (acc.LAT_Status__c != 'Cliente Validado' && acc.LAT_Status__c != 'Cliente Em Aprovação' && acc.LAT_NoValidationReason__c != '' && acc.LAT_NoValidationReason__c != null) {
                    //           acc.LAT_Status__c = 'Cliente não aprovado';
                    //           aiaToUpdate.add(acc);
                    //       }
                    //     }
                    //     // create the new approval request to submit
                    //     Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    //     req.setObjectId(cbr.Id);
                    //     // submit the approval request for processing
                    //     Approval.ProcessResult result = Approval.process(req);
                    //   }


                    }

                    if (returnMessage == '') {
                      update aiaToUpdate;
                      //returnMessage = validateSendToApproval(cbr.id);
                      if (tk != null) {
                        tk.status = 'Completed';
                        update tk;
                      }
                    }
                } catch (Exception e){
                    Database.rollback(sp);
                    returnMessage = e.getMessage() + ' closeTask';
                    LAT_DebugUtil.addException('LAT_ClientByRegionHandler-closeTask', e, '-1');
                }
            }
        }
        return returnMessage;
    }

    webService static String ValidateClients(List<String> cfIds) {
        List<LAT_AccountInAction__c> aiaList = [SELECT id, LAT_Status__c, LAT_ClientByRegion__c, LAT_ClientByRegion__r.RecordType.DeveloperName FROM LAT_AccountInAction__c WHERE id IN: cfIds];
        String returnMessage = '';
        if (!aiaList.isEmpty()) {
            Set<String> paIds = new Set<String>();
            for (LAT_AccountInAction__c acc: aiaList) {
                if (acc.LAT_ClientByRegion__c != null && acc.LAT_ClientByRegion__r.RecordType.DeveloperName != 'LAT_OnTrade') {
                  acc.LAT_Status__c = 'Cliente Validado';
                } else {
                  acc.LAT_Status__c = 'Cliente Em Aprovação';
                }

                paIds.add(acc.LAT_ClientByRegion__c);
            }

            SavePoint sp = Database.setSavePoint();
            try {
                update aiaList;
                List<AggregateResult> agList = [SELECT COUNT(id) notValidated  FROM LAT_AccountInAction__c
                                                    WHERE LAT_ClientByRegion__c IN: paIds
                                                          AND LAT_Status__c != 'Cliente Validado' AND LAT_Status__c != 'Cliente Em Aprovação'
                                                          AND (LAT_NoValidationReason__c = '' OR LAT_NoValidationReason__c = null)
                                                    GROUP BY LAT_ClientByRegion__c];
                if (!agList.isEmpty() && Integer.valueOf(agList.get(0).get('notValidated')) > 0) {
                  Database.rollback(sp);
                  returnMessage = 'Favor informar o “Motivo não validação (Planejamento)” para cada cliente não validado.';
                }

            } catch (Exception e){
                Database.rollback(sp);
                LAT_DebugUtil.addException('LAT_ClientByRegionHandler-ValidateClients', e, '-1');
                returnMessage = e.getMessage() + ' - ValidateClients';
            }

        }

        return returnMessage;

    }

    public static void sendChatterNotification (String paid) {
        //MP List<LAT_ClientByRegion__c> toSend = [SELECT id, Name, LAT_Status__c, LAT_Remaining__c, LAT_TaskCreated__c, Promotional_Action__r.LAT_StartDate__c, LAT_RegionalSupervisor__r.supervisor__c FROM LAT_ClientByRegion__c WHERE Promotional_Action__c =: paId];
		List<LAT_ClientByRegion__c> toSend = [SELECT id, Name, LAT_Status__c, LAT_Remaining__c, LAT_TaskCreated__c, Promotional_Action__r.LAT_StartDate__c, LAT_RegionalSupervisor2__c FROM LAT_ClientByRegion__c WHERE Promotional_Action__c =: paId];

        if(toSend != null && toSend.size() > 0){
            List<ConnectApi.BatchInput> feedList = new List<ConnectApi.BatchInput>();
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();

            input.subjectId = paid;

            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            for(LAT_ClientByRegion__c cbr : toSend){
                // Create mention to Regional Manager
                //MP if(cbr.LAT_RegionalSupervisor__r.supervisor__c != null){
				if(cbr.LAT_RegionalSupervisor2__c != null){

                    ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                    mentionSegment = new ConnectApi.MentionSegmentInput();
                    mentionSegment.id = cbr.LAT_RegionalSupervisor2__c; //LAT_RegionalSupervisor__r.supervisor__c;
                    messageInput.messageSegments.add(mentionSegment);

                    ConnectApi.TextSegmentInput textSegment;
                    textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text = ' ';
                    messageInput.messageSegments.add(textSegment);
                }

            }

            ConnectApi.TextSegmentInput textSegment;
            textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = '\nClientes selecionados \n';
            messageInput.messageSegments.add(textSegment);
            input.body = messageInput;

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            feedList.add(batchInput);

            try {
                ConnectApi.ChatterFeeds.postFeedElementBatch(null, feedList);
            } catch (Exception e){
                LAT_DebugUtil.addException('LAT_ClientByRegionHandler-sendChatterNotification', e, '-1');
            }
        }
    }

    public static Map<String, LAT_RegionalSupervisor__c> getSupervisorMap() {
      Map<String, LAT_RegionalSupervisor__c> regiontoSupervisor = new Map<String, LAT_RegionalSupervisor__c>();
      for (LAT_RegionalSupervisor__c sup:  [SELECT id, Name, Supervisor__c, LAT_RegionalClientOnPremise__c FROM LAT_RegionalSupervisor__c]) {
          regiontoSupervisor.put(sup.LAT_RegionalClientOnPremise__c, sup);
      }
      return regiontoSupervisor;
    }

    webService static String SendToApproval(String paId) {
        // In order to avoid duplicates tasks we will create tasks only for ClientByRegion with Pendente Status
        List<LAT_ClientByRegion__c> toSend = [SELECT id, Name, LAT_Status__c, LAT_Realizado__c, LAT_Remaining__c,
                                                      LAT_TaskCreated__c, Promotional_Action__r.LAT_StartDate__c,
													  LAT_RegionalSupervisor2__c,
													  Promotional_Action__r.Name,
                                                       LAT_RegionalClientOnPremise__c,
                                                      (Select id FROM Clientes_Foco__r), (Select id from attachments)
                                                  FROM LAT_ClientByRegion__c
                                                  WHERE Promotional_Action__c =: paId
                                                    AND LAT_Status__c = 'Pendente'];

        List<LAT_ClientByRegion__c> toUpdate = new List<LAT_ClientByRegion__c>();
        Map<String, LAT_RegionalSupervisor__c> superMap = getSupervisorMap();

		SYSTEM.debug('============\n  toSend: '+toSend+' \n ===========');
        List<Task> taskList = new List<Task>();
        String returnMessage = '';
        Integer daysToDue = LAT_PromotionalActionHandler.getSLANumberOfDays('AP_SLA_CLIENTVALIDATION');
		SYSTEM.debug('============\n  daysToDue: '+daysToDue+' \n ===========');
        // We will only create tasks for AccountInActions asociated to a ClientByRegion object

		// MP
		// Map<String, LAT_ClientByRegion__c> cfTOcr = new Map<String, LAT_ClientByRegion__c>();
        // for (LAT_ClientByRegion__c cbr: toSend) {
		// 	SYSTEM.debug('============\n  cbr: '+cbr+' \n ===========');
        //     for (LAT_AccountInAction__c aiac: cbr.Clientes_Foco__r) {
        //       cfTOcr.put(aiac.id, cbr);
		// 	  	SYSTEM.debug('============\n  aiac.id: '+aiac.id+' \n ===========');
        //     }
        // }
		//
		// SYSTEM.debug('============\n  cfTOcr: '+cfTOcr+' \n ===========');

        // Get all Account In actions for the promotional Action in order to create the tasks for the respective managers.
        List<LAT_AccountInAction__c> aiaList = [SELECT id, LAT_Account__c, LAT_Account__r.owner.Gerente_regional__c,
                                                       LAT_PromotionalAction__c, LAT_Account__r.RecordType.DeveloperName,
                                                       LAT_Account__r.LAT_BR_RegionalClientOnPremise__c, LAT_PromotionalAction__r.Name,
													   LAT_ClientByRegion__r.LAT_RegionalSupervisor2__c,  LAT_ClientByRegion__c
                                                  FROM LAT_AccountInAction__c
                                                  WHERE LAT_PromotionalAction__c =: paId];
        Set<String> managerIds = new Set<String>();
        Set<String> updatedCbr = new Set<String>();

		SYSTEM.debug('============\n  aiaList: '+aiaList+' \n ===========');

        //MP for (LAT_AccountInAction__c aiac: aiaList) {
		 for (LAT_ClientByRegion__c cbrObj: toSend) {

		  // MP  String what = cfTOcr.get(aiac.id) != null ? cfTOcr.get(aiac.id).id : null;
          String what = cbrObj.Id ; // != null ? cbrObj.Id : null;
          //String msg = 'Favor validar os cliente foco para a Ação Prmocional ' + aiac.LAT_PromotionalAction__r.Name + '.\nObrigado,\nTrade Categoria';< TO REMOVE, MP
          String msg = 'Favor informar os clientes negociados para a Ação Promocional ' + cbrObj.Promotional_Action__r.Name + ' já validados com Trade';

		  SYSTEM.debug('============\n  what: '+what+' \n ===========');
          // If the client is off trade then the task is created for the Regionla managerIds
          // If the cliente is on trade then the task is created for the user superviser
          // located in the supervisor__c object

		 //MP
		//   if (aiac.LAT_Account__r.RecordType.DeveloperName == 'Off_Trade'
        //       && aiac.LAT_Account__r.owner.Gerente_regional__c != null
        //       && !managerIds.contains(aiac.LAT_Account__r.owner.Gerente_regional__c)
        //       && what != null) {
        //     managerIds.add(aiac.LAT_Account__r.owner.Gerente_regional__c);
        //     //Task notif = LAT_ProcessesTaks.createTask(what, aiac.LAT_Account__r.owner.Gerente_regional__c, 'Validar Clientes Foco', < TO REMOVE, MP
        //     Task notif = LAT_ProcessesTaks.createTask(what, aiac.LAT_Account__r.owner.Gerente_regional__c, 'Informar Clientes Ação Promocional',
        //                         msg, Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalActionManagers'), daysToDue, 'AP-Validar Clientes Foco');
        //     notif.LAT_PromotionalAction__c = aiac.LAT_PromotionalAction__c;
        //     taskList.add(notif);
        //   } else
		//

		  if ( //aiac.LAT_Account__r.RecordType.DeveloperName == 'On_Trade'
                    //MP  && superMap.get(aiac.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c) != null
					cbrObj.LAT_RegionalSupervisor2__c != null
                    && what != null)
					// MP && !managerIds.contains(superMap.get(aiac.LAT_ClientByRegion__r.LAT_RegionalSupervisor2__c)) {
					//&& !managerIds.contains(aiac.LAT_ClientByRegion__r.LAT_RegionalSupervisor2__c))
					 {

            // MP && !managerIds.contains(superMap.get(aiac.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c).Supervisor__c)) {
              //MP managerIds.add(superMap.get(aiac.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c).Supervisor__c);
			  managerIds.add(cbrObj.LAT_RegionalSupervisor2__c);

			  // MP Task notif = LAT_ProcessesTaks.createTask(what, superMap.get(aiac.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c).Supervisor__c, 'Informar Clientes Ação Promocional',
			  Task notif = LAT_ProcessesTaks.createTask(what, cbrObj.LAT_RegionalSupervisor2__c, 'Informar Clientes Ação Promocional',

                                  msg, Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalActionManagers'), daysToDue, 'AP-Validar Clientes Foco');
              notif.LAT_PromotionalAction__c = cbrObj.Promotional_Action__c;
              taskList.add(notif);
          }

          // The Client for Regional is marked for update as "Em aprovação" after the tasks are created
          if (
               !updatedCbr.contains(cbrObj.Id)
              && what != null) {
            LAT_ClientByRegion__c cbr = new LAT_ClientByRegion__c();
			cbr.Id = cbrObj.Id;
            cbr.LAT_TaskCreated__c = true;
            cbr.LAT_Status__c = 'Em validação';
            toUpdate.add(cbr);
            updatedCbr.add(cbr.id);
          }
        }


        try {
            if (!taskList.isEmpty()) {
                insert taskList;
                update toUpdate;
                sendChatterNotification(paId);
                returnMessage = 'Atividades para validação de clientes criadas com sucesso';
            } else {
                returnMessage = 'Os clientes já estão sendo validados';
            }
        } catch (Exception e) {
            returnMessage = 'Existe um erro:' + e.getMessage();
            LAT_DebugUtil.addException('LAT_ClientByRegionHandler-SendToApproval', e, '-1');
        }
		SYSTEM.debug('============\n  returnMessage: '+returnMessage+' \n ===========');
        return returnMessage;
    }

    public static void shareRecords( List<LAT_ClientByRegion__c> triggerNew){
        List<String> Ids = new List<String>();
        List<String> paIds = new List<String>();
        List<LAT_PromotionalAction__Share> toUpdate = new List<LAT_PromotionalAction__Share>();

        for(LAT_ClientByRegion__c cbr : triggerNew){
            ids.add(cbr.id);
            paIds.add(cbr.Promotional_Action__c);
        }

        Map<String, LAT_PromotionalAction__Share> userToPas = new Map<String, LAT_PromotionalAction__Share>();
        for (LAT_PromotionalAction__Share pas: [select id, ParentId, UserOrGroupId from LAT_PromotionalAction__Share where UserOrGroupId != null and ParentId IN: paIds]){
            userToPas.put(pas.UserOrGroupId, pas);
        }

		//
        for(LAT_ClientByRegion__c cbr : [SELECT id, Name, LAT_Status__c, LAT_Remaining__c, LAT_TaskCreated__c,
                                                                                    //MP Promotional_Action__c , LAT_RegionalSupervisor__r.supervisor__c
																					Promotional_Action__c ,  LAT_RegionalSupervisor2__c
                                                                            FROM LAT_ClientByRegion__c WHERE id =: ids]){

            LAT_PromotionalAction__Share jobShr  = new LAT_PromotionalAction__Share();
            // MP if (cbr.LAT_RegionalSupervisor__r.supervisor__c != null && userToPas.get(cbr.LAT_RegionalSupervisor__r.supervisor__c) == null) {
			if (cbr.LAT_RegionalSupervisor2__c != null && userToPas.get(cbr.LAT_RegionalSupervisor2__c) == null) {

			    jobShr.ParentId = cbr.Promotional_Action__c;
                //jobShr.UserOrGroupId = cbr.LAT_RegionalSupervisor__r.supervisor__c;
				jobShr.UserOrGroupId = cbr.LAT_RegionalSupervisor2__c;
                jobShr.AccessLevel = 'Edit';
                toUpdate.add(jobShr);
            }

        }

        try {
            insert toUpdate;
        } catch (Exception e) {
            LAT_DebugUtil.addException('LAT_ClientByRegionHandler-shareRecords', e, '-1');
        }
    }

    public static void assignAccountInActions(List<LAT_ClientByRegion__c> cbrList) {
      Set<String> paSet = new Set<String>();
      for (LAT_ClientByRegion__c cbr: cbrList) {
        paSet.add(cbr.Promotional_Action__c);
      }

      Map<String, List<LAT_AccountInAction__c>> regionalOnToAccountInAction = new Map<String, List<LAT_AccountInAction__c>>();
      Map<String, List<LAT_AccountInAction__c>> regionalOffToAccountInAction = new Map<String, List<LAT_AccountInAction__c>>();
      for (LAT_AccountInAction__c acc: [SELECT id, LAT_Account__c, LAT_Account__r.LAT_BR_RegionalClientOnPremise__c,
                                               LAT_ClientByRegion__c, LAT_PromotionalAction__c, LAT_Account__r.Regional__c,
                                               LAT_Account__r.RecordType.DeveloperName
                                          FROM LAT_AccountInAction__c
                                            WHERE LAT_PromotionalAction__c IN: paSet
                                              AND LAT_Status__c = 'Cliente não previsto'
                                              AND LAT_ClientByRegion__c = null]) {
        if (acc.LAT_ClientByRegion__c == null) {
          if (acc.LAT_Account__r.RecordType.DeveloperName == 'On_Trade') {
            if (regionalOnToAccountInAction.get(acc.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c) != null) {
              regionalOnToAccountInAction.get(acc.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c).add(acc);
            } else {
              regionalOnToAccountInAction.put(acc.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c, new List<LAT_AccountInAction__c>{acc});
            }
          } else if (acc.LAT_Account__r.RecordType.DeveloperName == 'Off_Trade') {
            if (regionalOffToAccountInAction.get(acc.LAT_Account__r.Regional__c) != null) {
              regionalOffToAccountInAction.get(acc.LAT_Account__r.Regional__c).add(acc);
            } else {
              regionalOffToAccountInAction.put(acc.LAT_Account__r.Regional__c, new List<LAT_AccountInAction__c>{acc});
            }
          }
          paSet.add(acc.LAT_PromotionalAction__c);
        }
      }

      List<LAT_AccountInAction__c> aiaList = new List<LAT_AccountInAction__c>();
      for (LAT_ClientByRegion__c cbr: [SELECT id, LAT_Regional__c, LAT_RegionalClientOnPremise__c FROM LAT_ClientByRegion__c
                                        WHERE Promotional_Action__c IN: paSet]) {
        if (regionalOnToAccountInAction.get(cbr.LAT_RegionalClientOnPremise__c) != null) {
          for (LAT_AccountInAction__c aia: regionalOnToAccountInAction.get(cbr.LAT_RegionalClientOnPremise__c)) {
             aia.LAT_ClientByRegion__c = cbr.id;
             aia.LAT_Status__c = 'Cliente Selecionado';
             aiaList.add(aia);
          }
        } else if (regionalOffToAccountInAction.get(cbr.LAT_Regional__c) != null) {
          for (LAT_AccountInAction__c aia: regionalOffToAccountInAction.get(cbr.LAT_Regional__c)) {
             aia.LAT_ClientByRegion__c = cbr.id;
             aia.LAT_Status__c = 'Cliente Selecionado';
             aiaList.add(aia);
          }
        }
      }

      update aiaList;

    }

    public static void posttoChatterWhenApproved(List<LAT_ClientByRegion__c> triggerNew, Map<id, LAT_ClientByRegion__c> oldMap) {
      List<ConnectApi.BatchInput> posts = new List<ConnectApi.BatchInput>();
      String groupId = '';
      String[] groups = LAT_GeneralConfigDao.getValueAsStringArray('AP_CHATTER_GROUP', ' ');
      if(groups != null && groups.size()>0)groupId = groups[0];

      Set<String> paIds = new Set<String>();
      for (LAT_ClientByRegion__c cbr: triggerNew) {
        if (cbr.LAT_Status__c == 'Validado' && oldMap.get(cbr.id) != null
            && oldMap.get(cbr.id).LAT_Status__c != 'Validado') {
          paIds.add(cbr.Promotional_Action__c);
        }
      }

      List<LAT_PromotionalAction__c> paList = [SELECT id, Name, (Select id, LAT_Status__c From Clientes_por_Regional__r where LAT_Status__c != 'Validado') FROM LAT_PromotionalAction__c WHERE id IN: paIds];

      for (LAT_PromotionalAction__c pa: paList) {
        if (pa.Clientes_por_Regional__r.isEmpty()) {
          String msg = 'Clientes foco da Ação Promocional ' + pa.Name + ' validados';
          ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>(), msg, pa.id);
          if(post != null)posts.add(post);
        }
      }
      LAT_ProcessesNotifications.post(posts);
    }

    public static void manageStatus(List<LAT_ClientByRegion__c> triggerNew, Map<id, LAT_ClientByRegion__c> oldMap) {
      List<LAT_ClientByRegion__c> cbrList = [SELECT id, LAT_Status__c, RecordType.DeveloperName, (Select id, LAT_Status__c, LAT_NoValidationReason__c From Clientes_Foco__r)
                                                FROM LAT_ClientByRegion__c WHERE id IN: triggerNew];

      List<LAT_AccountInAction__c> aiacList = new List<LAT_AccountInAction__c>();
      for (LAT_ClientByRegion__c cbr: cbrList) {
        if (cbr.RecordType.DeveloperName == 'LAT_OnTrade' && (cbr.LAT_Status__c == 'Validado')
            && oldMap.get(cbr.id).LAT_Status__c == 'Em aprovação') {
          for (LAT_AccountInAction__c aiac: cbr.Clientes_Foco__r) {
            if (aiac.LAT_Status__c == 'Cliente Em aprovação') {
              aiac.LAT_Status__c = 'Cliente Validado';
              aiac.LAT_NoValidationReason__c = '';
            } else {
              aiac.LAT_Status__c = 'Cliente não aprovado';
            }
            aiacList.add(aiac);
          }
        } else if (cbr.RecordType.DeveloperName == 'LAT_OnTrade' && cbr.LAT_Status__c == 'Não Aprovado'
            && oldMap.get(cbr.id).LAT_Status__c == 'Em aprovação') {
          for (LAT_AccountInAction__c aiac: cbr.Clientes_Foco__r) {
            if(aiac.LAT_Status__c != 'Cliente não aprovado') {
              aiac.LAT_Status__c = 'Cliente Selecionado';
              aiacList.add(aiac);
            }
          }
        }
      }

      try{ update aiacList; }catch(Exception e){ LAT_DebugUtil.addException('LAT_ClientByRegionHandler-manageStatus', e, '-1'); }
    }


}