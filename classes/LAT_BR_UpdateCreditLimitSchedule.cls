global class LAT_BR_UpdateCreditLimitSchedule implements Schedulable {

	final Set<Id> setIdRecordType = Global_RecordTypeCache.getRtIdSet('Account', new Set <String> {'Off_Trade'});
    Map<id, List<Account>> OwnerToAccounts = new Map<id, List<Account>>();
    private String NotesIndependiente = '';
	private String NotesPadre = '';

	global void execute(SchedulableContext sc) {
		// Cuantos meses atras tiene que haber sido creada la ultima fiscal note
		String[] monthsArray = LAT_GeneralConfigDao.getValueAsStringArray('UPDATE_CREDIT_LIMIT_MONTHS', ' ');
		// Cuantos meses atras tiene que haber sido creado el cliente para ser considerado
		String[] createdArray = LAT_GeneralConfigDao.getValueAsStringArray('UPDATE_CREDIT_LIMIT_CREATED_FILTER', ' ');

		Integer months = monthsArray != null ? Integer.valueOf(monthsArray[0]) : 12;
		Integer creatdDateMonths = createdArray != null ? Integer.valueOf(createdArray[0]) : 3;

		this.NotesIndependiente = 'Em função do não faturamento no últimos ' + months + ' meses,' +
					 			   ' o Limite de Crédito do cliente foi alterado automaticamente para R$ 1,00.' +
				 				   ' Em caso de dúvidas contactar a área de Créditos&Cobranças.';

		this.NotesPadre = 'Em função do não faturamento no últimos ' + months + ' meses de nenhum cliente' +
	  									' da hierarquia (Cliente Pai e Clientes Filhos), o Limite de Crédito' +
	  									' do cliente foi alterado automaticamente para R$ 1,00.' +
	  								    ' Em caso de dúvidas contactar a área de Créditos&Cobranças.';

		Date filterDate = Date.today().addmonths(-months);
		Date clientCreatedDate = Date.today().addmonths(-creatdDateMonths);

		// Se obtienen todas las accounts necesarias
		List<Account> accList = this.getInitialAccounts(clientCreatedDate, filterDate);
		List<String> accIds = new List<String>();
		List<Account> toUpdate = new List<Account>();
		Map<String, Decimal> oldCredtitLine = new Map<String, Decimal>();
		system.debug('---> Procesamiento De Clientes Independientes');
		for (Account acc: accList) {
		      // Si no tiene ChildAccount es CLiente Independiente, de lo contrario es padre
		      if (acc.ChildAccounts.isEmpty()) {
		            // Si no tiene fiscal notes es porque no ha facturado en los ultimos 12 meses
		            if (acc.Fiscal_Notes__r.isEmpty()) {
		                  // Agrego al mapa, para luego enviar mail por Owner detallando las accounts
		                  if (acc.Credit_Line__c != null) {
		                  	oldCredtitLine.put(acc.id, acc.Credit_line__c);
		              	  } else {
							oldCredtitLine.put(acc.id, 0);
		              	  }
		                  acc = updateAccount(acc, NotesIndependiente);
		                  toUpdate.add(acc);
		                  OwnerToAccounts = addToMap(OwnerToAccounts, acc);
		            }
		      } else {
		      		if (acc.Fiscal_Notes__r.isEmpty()) {
			            // Agrego para procesar luego por padre
			            for (Account child: acc.ChildAccounts) {
			            	accIds.add(child.id);
			            }
			        }
		      }
		}

		system.debug('---> Procesamiento De Clientes padre');
		// Procesamiento de clientes padre
		List<Account> ChildList = [SELECT Id, ParentId,  Parent.id, Parent.OwnerId, Credit_line__c, 
										Parent.Client_code_AN8__c, Parent.Corporate_Name__c, Parent.CNPJ__c,
										Parent.Status__c, Parent.Notes__c, Owner.ManagerId, Owner.Name, 
										Parent.CreatedDate, CreatedDate, Parent.Regional__r.Name,
										(Select id, LAT_BillingDate__c FROM Fiscal_Notes__r 
		                                    WHERE LAT_BillingDate__c >: filterDate LIMIT 1) 
		                        FROM Account 
		                        WHERE RecordTypeId IN: setIdRecordType 
		                              AND Rating != 'Cliente Inativo' AND id IN: accIds
		                              AND Client_code_AN8__c != null AND CreatedDate <: clientCreatedDate
		                        ORDER BY Corporate_Name__c, Owner.Name];

		// Tomo todos los hijos y los inserto en un mapa ordenadso por padre
		Map<Id, List<Account>> ParentToChild = new Map<Id, List<Account>>();
		for (Account acc: ChildList) {
		      if (ParentToChild.get(acc.ParentId) != null) {
		            ParentToChild.get(acc.ParentId).add(acc);
		      } else {
		            ParentToChild.put(acc.ParentId, new List<Account>{acc});
		      }
		}

		List<String> ParentsList = new List<String>();
		// Procesamiento de clientes hijos por cada padre
		for (String parents: ParentToChild.keySet()) {
		      Boolean doTheUpdate = true;
		      // Recorro todos los hijos de un cliente
		      for (Account acc: ParentToChild.get(parents)) {
		            // Si existe una fatctura para alguno de los hijos 
		            // y la billing dates es mayor que 12 meses no se tiene que hacer update del padre
		            if (!acc.Fiscal_Notes__r.isEmpty()) {
		                  doTheUpdate = false;
		                  break;
		            }
		      }

		      if (doTheUpdate) {
		      		ParentsList.add(parents);
		      }
		}
		system.debug('---> Lista de Padres' + ParentsList);
		for (Account ParentAccount: [SELECT Id, OwnerId, Credit_line__c, Client_code_AN8__c, Corporate_Name__c,
											  CNPJ__c, Status__c, Notes__c, Owner.ManagerId, Owner.Name, CreatedDate,
											  Regional__r.Name
				                            FROM Account WHERE Id IN:ParentsList]) {
			if (ParentAccount.Credit_Line__c != null) {
				oldCredtitLine.put(ParentAccount.id, ParentAccount.Credit_line__c);
			} else {
				oldCredtitLine.put(ParentAccount.id, 0);
			}

			ParentAccount = updateAccount(ParentAccount, NotesPadre);
      		toUpdate.add(ParentAccount);
			OwnerToAccounts = addToMap(OwnerToAccounts, ParentAccount);
		}
		Map<Id, String> CreditLineHistory = getCreditLineHistory(toUpdate);


		if (toUpdate.size() > 50) {
			List<Account> finalUpdate = new List<Account>();
			for (Integer i = 0; i < 50; i++) {
				finalUpdate.add(toUpdate[i]);
			}
			update finalUpdate;
		} else {
			update toUpdate;
		}

		

		if (!toUpdate.isEmpty()) {
			system.debug('---> Envio de Emails a Owners');
			// Mail to Owners and Managers
			Map<id, User> uList = new Map<id, User>([SELECT id, Name, Email 
														FROM User 
														WHERE id IN: this.OwnerToAccounts.keySet()
														ORDER BY Name]);
			
			List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
			String AllRows = '';
			Set<String> allreadyAdded = new Set<String>();
			for (String accOwner: this.OwnerToAccounts.keySet()) {
				User OwnerUser = uList.get(accOwner);
				String[] toAddresses = new String[]{};
				if (OwnerUser.Email != null) {
					toAddresses.add(OwnerUser.Email);
				}
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(toAddresses);
				mail.setSubject('Clientes com limite de crédito retirado por falta de faturamento nos últimos ' + months + ' meses'); 
				String html = htmlHeader; 
				String Rows = '';
				for (Account acc: this.OwnerToAccounts.get(accOwner)) {
					String AccCreditLineHist = CreditLineHistory.get(acc.id) != null ? CreditLineHistory.get(acc.id) : oldCredtitLine.get(acc.id) + ' -- ' + acc.CreatedDate.format();
					String DataLimiteAnt = AccCreditLineHist.split('--')[1];
					String LimiteAnt = AccCreditLineHist.split('--')[0];
					String TheRow = '<tr>' +
								'<td style="font-family:sans-serif;border: 1px solid;padding: 5px;">' + (acc.Client_code_AN8__c != null ? acc.Client_code_AN8__c : '') + '</td>' +
								'<td style="font-family:sans-serif;border: 1px solid;padding: 5px;">' + acc.CNPJ__c + '</td>' +
								'<td style="font-family:sans-serif;border: 1px solid;padding: 5px;">' + acc.Corporate_Name__c + '</td>' +
								'<td style="font-family:sans-serif;border: 1px solid;padding: 5px;">' + acc.Regional__r.Name + '</td>' +
								'<td style="font-family:sans-serif;border: 1px solid;padding: 5px;">' + acc.Owner.Name + '</td>' +
								'<td style="font-family:sans-serif;border: 1px solid;padding: 5px;">' + LimiteAnt + '</td>' +
								'<td style="font-family:sans-serif;border: 1px solid;padding: 5px;">' + DataLimiteAnt + '</td>' +
								'<td style="font-family:sans-serif;border: 1px solid;padding: 5px;">' + '1,00' + '</td>' +
								'<td style="font-family:sans-serif;border: 1px solid;padding: 5px;">' + Date.today().format() + '</td>' +
							'</tr>';
					if (!allreadyAdded.contains(acc.id)) {
						AllRows += TheRow;
						allreadyAdded.add(acc.id);
					}
					Rows += TheRow;
				}
				html += Rows + htmlEnd;
				//AllRows += Rows;

 				mail.setSenderDisplayName('noreply@pernod-ricard.com');
				mail.setHtmlBody(html);
				emailList.add(mail);
			}

			system.debug('---> Envio de Emails a C&C y Cadastros');
			//Mail a C&C y Cadastros
			List<String> userOrGroupIds = new List<String>();
			String[] toAddresses = new String[]{};
			for(GroupMember u : [Select UserOrGroupid From GroupMember Where Group.name = 'LAT_BR_GerenciamientoCreditLine']){
		    	userOrGroupIds.add(u.UserOrGroupid);
		    }
		    for(User u : [Select Id, email From User Where Id In :userOrGroupIds]){
		    	toAddresses.add(u.email);
		    }

		    if (!toAddresses.isEmpty()) {
				String AllClientsUpdatedHtml = htmlHeader + AllRows + htmlEnd;
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(toAddresses);
				mail.setSubject('Clientes com limite de crédito retirado por falta de faturamento nos últimos ' + months + ' meses');
				mail.setHtmlBody(AllClientsUpdatedHtml);
 				mail.setSenderDisplayName('noreply@pernod-ricard.com');
				emailList.add(mail);
			}

			if (!emailList.isEmpty()) {
				Messaging.sendEmail(emailList);
			}
		}
	}

	public List<Account> getInitialAccounts (Date clientCreatedDate, Date filterDate) {
		system.debug('---->' + clientCreatedDate);
		Map<id,Account> accMap = new Map<id, Account>([SELECT Id, OwnerId, Credit_line__c, Client_code_AN8__c, Corporate_Name__c,
														  CNPJ__c, Status__c, Notes__c, Owner.ManagerId, Owner.Name, CreatedDate,
														  Regional__r.Name, (Select id FROM ChildAccounts),
							                              (Select id, LAT_BillingDate__c FROM Fiscal_Notes__r 
							                               		WHERE LAT_BillingDate__c >: filterDate LIMIT 1) 
								                        FROM Account 
								                        WHERE RecordTypeId IN: setIdRecordType
								                              AND ParentId = null AND Rating != 'Cliente Inativo' 
								                              AND Credit_line__c != 1 AND Client_code_AN8__c != null
								                              AND CreatedDate <: clientCreatedDate
								                        ORDER BY Corporate_Name__c, Owner.Name]);

		for (ProcessInstance pi: [SELECT Id, TargetObjectId
                                    FROM ProcessInstance 
                                    WHERE TargetObjectId IN : accMap.keySet()
                                        AND Status = 'Pending']) {
			accMap.remove(pi.TargetObjectId);
		}

		system.debug('---->' + accMap.keyset());

		return accMap.values();

	}

	private Account updateAccount(Account acc, String Notes) {
		acc.Credit_line__c = 1;
		acc.Status__c = 'Aprovado - Aguardando retorno do JDE';
		acc.Notes__c = Notes;
		return acc;
	}

	private Map<Id, List<Account>> addToMap(Map<Id, List<Account>> accMap, Account ToAdd) {
		if (accMap.get(ToAdd.OwnerId) != null) {
			accMap.get(ToAdd.OwnerId).add(ToAdd);
		} else {
			accMap.put(ToAdd.OwnerId, new List<Account>{ToAdd});
		}

		if (ToAdd.Owner.ManagerId != null) {
			if (accMap.get(ToAdd.Owner.ManagerId) != null) {
				accMap.get(ToAdd.Owner.ManagerId).add(ToAdd);
			} else {
				accMap.put(ToAdd.Owner.ManagerId, new List<Account>{ToAdd});
			}
		}

		return accMap;
	}

	private Map<Id, String> getCreditLineHistory (List<Account> acc) {
		Map<Id, String> accountIdToHistory = new Map<Id, String>();
		for (AccountHistory history: [SELECT CreatedDate, Field, NewValue, AccountId
										FROM AccountHistory 
										WHERE Field = 'Credit_Line__c' AND AccountId IN : acc
										ORDER BY CreatedDate ASC]) {
			accountIdToHistory.put(history.AccountId, history.NewValue + '--' + history.CreatedDate.format());
		}
		return accountIdToHistory;
	}

	private final String htmlHeader = '<table cellpadding="0" cellspacing="0" border="1" style="font-family:sans-serif;text-align:center;border-spacing: 10px; border-collapse: separate;font-size:12px;">' +
										'<thead>' +
											'<tr>' +
												'<th style="font-family:sans-serif;border: 1px solid;">AN8</th>' +
												'<th style="font-family:sans-serif;border: 1px solid;">CNPJ</th>' +
												'<th style="font-family:sans-serif;border: 1px solid;">Razão Social</th>' +
												'<th style="font-family:sans-serif;border: 1px solid;">Regional</th>' +
												'<th style="font-family:sans-serif;border: 1px solid;">Executivo de Vendas</th>' +
												'<th style="font-family:sans-serif;border: 1px solid;">Limite de Crédito Anterior</th>' +
												'<th style="font-family:sans-serif;border: 1px solid;">Data Limite Credito anterior</th>' +
												'<th style="font-family:sans-serif;border: 1px solid;">Limite de Crédito Atual</th>' +
												'<th style="font-family:sans-serif;border: 1px solid;">Data do limite de crédito atual</th>' +
											'</tr>' +
										'</thead>' +
										'<tbody>';
	private final String htmlEnd = + '</tbody> </table>';
}