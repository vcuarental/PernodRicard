/**
 * Util class to handle the subtask of the docusign object trigger
 * @author ernesto@zimmic.com
 */
public with sharing class LAT_BR_DocusignDataTriggerHandler {
	
	
	/**
	 * When an envelope completes a signature flow (or it's decline) this process will update the contract
	 * accordingly
	 * @param newMap
	 * @param oldMap
	 * @param contractById
	 *
	 */
	public static void updateContractStatus(Map<Id,LAT_DocuSign_Status__c> newMap, Map<Id,LAT_DocuSign_Status__c> oldMap,Map<Id, Lat_Contract2__c> contractById){
		system.debug('ernestoJavi+++ 1');
		List<Attachment> attToDelete = new List<Attachment>();
		List<Lat_Contract2__c> contractToUpdate = new list<Lat_Contract2__c>();
		Map<Id, List<Attachment>> attBycontractId = new Map<Id, List<Attachment>> ();
		for (Attachment att:[SELECT Id,Name,ParentId FROM Attachment WHERE ParentId IN :contractById.keySet()]){
			if (attBycontractId.get(att.ParentId) == null){
				attBycontractId.put(att.ParentId, new List<Attachment>());
			}
			attBycontractId.get(att.ParentId).add(att);
		}
		system.debug('ernestoJavi+++ 2' + attBycontractId);

		 
		for (LAT_DocuSign_Status__c status: newMap.values()){
			
			Lat_Contract2__c lc2 = contractById.get(status.Lat_Contract2__c);

			// if the status goes from something to completed means the flow of signatures finished
			if (status.Envelope_Status__c == LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED 
					&& oldMap.get(status.Id).Envelope_Status__c != LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED ){
				system.debug('ernestoJavi+++ 3' + status.Envelope_Status__c);
				system.debug('ernestoJavi+++ 4' + lc2.Status__c);
				if(lc2.Status__c == 'Distrato Aprovado'){
	                lc2.Status__c = 'Cancelado';
	                attToDelete.addAll(cleanUpContract(lc2, attBycontractId.get(lc2.Id)));
	            } else if(lc2.Status__c == 'Aprovado'){
	                

	            	attToDelete.addAll(cleanUpContract(lc2, attBycontractId.get(lc2.Id)));
	                lc2.Status__c = 'Ativo';
	            }
	            lc2.ProcessStatus__c = 'Processo Finalizado';
	            //
	            lc2.Current_Signatary__c = '';
	            contractToUpdate.add(lc2);


			// the signature process was declined
			} else if (status.Envelope_Status__c == LAT_Docusign_Utils.DS_ENVELOPE_STATUS_DECLINED 
					&& oldMap.get(status.Id).Envelope_Status__c != LAT_Docusign_Utils.DS_ENVELOPE_STATUS_DECLINED ){

				if(lc2.Status__c == 'Aprovado'){
	                lc2.Status__c = 'Reprovado';

	            }
	            // que hacemos si es un distrato
	            //lc2.ProcessStatus__c = 'Processo Finalizado';

	            contractToUpdate.add(lc2);

			} else if (status.Envelope_Status__c == LAT_Docusign_Utils.DS_ENVELOPE_STATUS_DECLINED){

			}

		}
		delete attToDelete;
		update contractToUpdate;
		


	}

	private static List<Attachment> cleanUpContract(Lat_Contract2__c contract, List<Attachment> atts){
		system.debug('ernestoJavi+++ 5' + atts);
		List<Attachment> attToDelete = new List<Attachment>();

		for (Attachment at: atts) {
				system.debug('ernestoJavi+++ 6-->' + at.Name);
                if(at.name == 'Contrato - ' + contract.Name + ' - Anexo 1.1.pdf' ) {
                    attToDelete.add(at);
                }
                if(at.name == 'Contrato - ' + contract.Name + ' - Anexo 1.2.pdf' ) {
                    attToDelete.add(at);
                }
                // Check
                if(at.name == 'Contrato -  ' + contract.Name + ' - Minuta Padrao.pdf' || at.name == 'Contrato - ' + contract.Name + ' - Minuta Padrao.pdf') {
                       attToDelete.add(at); 
                }
                if(at.name == 'Contrato - ' + contract.Name + ' - Minuta Padrao Carta Acordo.pdf') {
                    attToDelete.add(at);
                }

                if(at.name.contains('CANC') && !at.name.contains('Completed')) {
                    attToDelete.add(at);
                }

            }
		return attToDelete;

	}


	public static void updateSignataryAndProcessStatus(Map<Id,LAT_DocuSign_Recipient_Status__c> newMap, Map<Id,LAT_DocuSign_Recipient_Status__c> oldMap,Map<Id, Lat_Contract2__c> contractById,Set<Id> dsStatusIds){
		
		List<Lat_Contract2__c> contractToUpdate = new list<Lat_Contract2__c>();
		//Map<Id,Map<Integer, LAT_DocuSign_Recipient_Status__c>> recipientByOrder = getDocusignRecipientByOrder(dsStatusIds);
		//system.debug('Recipients by Order---:' + recipientByOrder);

		for (LAT_DocuSign_Recipient_Status__c rec: newMap.values()){
			
				system.debug('ernestoTest+++ entrststus new' + rec.Recipient_Status__c);
				system.debug('ernestoTest+++ entrststus old' + oldMap.get(rec.Id).Recipient_Status__c);
			Lat_Contract2__c lc2 = contractById.get(rec.Lat_Contract2__c);
			system.debug('ernestoTest+++ entro22' + lc2);
			// if the status goes from something to completed means the recipient is complete and we need to move to the next signatary
			if (rec.Recipient_Status__c == LAT_Docusign_Utils.DS_RECIPIENT_STATUS_COMPLETED 
					&& oldMap.get(rec.Id).Recipient_Status__c != LAT_Docusign_Utils.DS_RECIPIENT_STATUS_COMPLETED ){
				system.debug('ernestoTest+++ entro1');

				/**if (recipientByOrder.get(rec.Parent_Status_Record__c)!= null &&
						recipientByOrder.get(rec.Parent_Status_Record__c).get(Integer.valueOf(rec.Routing_Order__c + 1))!= null) {

					// set next recipient
					lc2.Current_Signatary__c = recipientByOrder.get(rec.Parent_Status_Record__c).get(Integer.valueOf(rec.Routing_Order__c + 1)).Role__c;
					contractToUpdate.add(lc2);

				} else {
					lc2.Current_Signatary__c = '';
					contractToUpdate.add(lc2);

				} */
				//contractToUpdate


			} else if (rec.Recipient_Status__c == LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DELIVERY_FAIL
					&& oldMap.get(rec.Id).Recipient_Status__c != LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DELIVERY_FAIL ){
					system.debug('ernestoTest+++ entro2');

				sendEmailNotification(rec, lc2.Owner.Email);
			} else if (rec.Recipient_Status__c == LAT_Docusign_Utils.DS_RECIPIENT_STATUS_SENT 
					&& (oldMap.get(rec.Id).Recipient_Status__c == LAT_Docusign_Utils.DS_RECIPIENT_STATUS_CREATED || oldMap.get(rec.Id).Recipient_Status__c == LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DELIVERY_FAIL)){
				lc2.Current_Signatary__c = rec.Role__c + ' - ' + rec.Recipient_Name__c;
				contractToUpdate.add(lc2);
				system.debug('ernestoTest+++ entro3');
			} else if (rec.Recipient_Status__c == LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED
					&& oldMap.get(rec.Id).Recipient_Status__c != LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED ){

				lc2.ProcessStatus__c = 'Não Assinado ' + rec.Role__c;
				lc2.Current_Signatary__c = rec.Role__c + ' - ' + rec.Recipient_Name__c;
				contractToUpdate.add(lc2);
				system.debug('ernestoTest+++ entro4');
			}

		}

		update contractToUpdate;
	}

	/*
	 * Generates a map of the order for each docusign status being updated
	 * @param Set<Id> docusign Status id's
	 * @return Map<docusignStatusId, ordervalue, docusignRecipientobj>
	 *
	 // NOT USED NOW
	public static Map<Id,Map<Integer, LAT_DocuSign_Recipient_Status__c>> getDocusignRecipientByOrder(Set<Id> dsStatusIds){

		Map<Id,Map<Integer, LAT_DocuSign_Recipient_Status__c>> retMap = new Map<Id,Map<Integer, LAT_DocuSign_Recipient_Status__c>>();
		List<LAT_DocuSign_Recipient_Status__c> recipients = [SELECT Id, 
																	Name,
																	Routing_Order__c,
																	Parent_Status_Record__c,
																	Role__c
														     FROM
														     	 LAT_DocuSign_Recipient_Status__c
														      WHERE Parent_Status_Record__c in: dsStatusIds];



		for(LAT_DocuSign_Recipient_Status__c rec: recipients){
			if (retMap.get(rec.Parent_Status_Record__c) == null){
				retMap.put(rec.Parent_Status_Record__c, new Map<Integer, LAT_DocuSign_Recipient_Status__c>());
			}
			retMap.get(rec.Parent_Status_Record__c).put(Integer.valueOf(rec.Routing_Order__c), rec);
		}

		return retMap;
	}*/

	/**
	 * get contracts by Id
	 * @para idSetOfContracts
	 * @return get contracts for Ids
	 */
	public static Map<Id, Lat_Contract2__c> getContractsById(Set<Id> idSetOfContracts){
		Set<Id> contractsId = idSetOfContracts; //new Set<Id>();
		//for (LAT_DocuSign_Status__c ds:newMap.values()){
		//	contractsId.add(ds.Lat_Contract2__c);
		//}

		Map<Id, Lat_Contract2__c> contractById = 
				new Map<Id, Lat_Contract2__c>  ([SELECT id, 
	                                                    Status__c, 
	                                                    RecordType.DeveloperName, 
	                                                    StandardClausesPRB__c, 
	                                                    Name,
	                                                    CustomerSignedBy__r.Email,
	                                                    CustomerSignedBy__r.Name,
	                                                    CustomerSignedBy__c,
	                                                    OwnerId,
	                                                    Owner.Name,
	                                                    Owner.Email,
	                                                    CustomerSignatory__r.Email,
	                                                    CustomerSignatory__r.Name,
	                                                    CustomerSignatory__c,
	                                                    ProcessStatus__c,
	                                                    GeneralManager__c,
	                                                    Manager__c,
	                                                    RegionalManager__c,
	                                                    Use_Consultant_to_Testify__c,
	                                                    Value__c
	                                             FROM LAT_Contract2__c 
	                                             WHERE id IN : contractsId]);
		return contractById;
	}

/**
  * sendEmailNotification
  * if the ME integration fails we send an email to the contract Owner
  * @param payment
  */
  private static void sendEmailNotification(LAT_DocuSign_Recipient_Status__c recipient, String ownerEmail) {

    String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + recipient.Id;
    String html = 'Favor revisar o(s) erro(s) encontrado(s) na criação do Envelope na Docusign para o Contrato <a href="'+fullRecordURL+'">'+LAT_DocuSign_Recipient_Status__c.Name+'</a>';
    String subject = 'Erro Integração Docusign ';

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    String[] mailAddress =  new String[]{ownerEmail};

    email.setToAddresses( mailAddress );
    email.setSaveAsActivity(false);
    email.setHtmlBody(html);
    email.setBccSender(false);
    email.setSubject(subject);
    email.setUseSignature(false);
    if(!test.isrunningtest()){
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
  }

}