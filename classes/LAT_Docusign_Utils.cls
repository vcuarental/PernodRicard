/**
 * Docusign Utils:
 * Usage is to have all the static methods to create and sent envolopes to 
 * Docusign, also contains wrappers classes for create the requests
 * @author ernesto@zimmic.com
 */
global with sharing class LAT_Docusign_Utils {
	public class Lat_Docusign_Exception extends Exception {}

    // Recipients Status
    public static final String DS_RECIPIENT_STATUS_COMPLETED = 'Completed';
    public static final String DS_RECIPIENT_STATUS_CREATED = 'Created';
    public static final String DS_RECIPIENT_STATUS_SENT = 'Sent';
    public static final String DS_RECIPIENT_STATUS_DELIVERED = 'Delivered';
    public static final String DS_RECIPIENT_STATUS_DELIVERY_FAIL = 'AutoResponded';
    public static final String DS_RECIPIENT_STATUS_DECLINED = 'Declined';

    // Docusign envelope status
    public static final String DS_ENVELOPE_STATUS_COMPLETED = 'Completed';
    public static final String DS_ENVELOPE_STATUS_CREATED = 'Created';
    public static final String DS_ENVELOPE_STATUS_SENT = 'Sent';
    public static final String DS_ENVELOPE_STATUS_DELIVERED = 'Delivered';
    public static final String DS_ENVELOPE_STATUS_DECLINED = 'Declined';

    // configuration of docusing used as singleton in the class
    public static LAT_Docusign_Config__c dsConfig {get;set;}

    // TODO: Move to docusign c
    public static  Double SENT_TO_PRESIDENT_GREATER_THAN = getDocusignConfig().Sent_to_President__c;
    public static  Double SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN = getDocusignConfig().Sent_to_Financial_Director__c;
    public static  Double SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN = getDocusignConfig().Sent_to_Comercial_Director__c;
    
    public static  Double SENT_TO_PRESIDENT_GREATER_THAN_PRESTIGE = getDocusignConfig().Sent_to_President_PRESTIGE__c;
    public static  Double SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_PRESTIGE = getDocusignConfig().Sent_to_Financial_Director_PRESTIGE__c;
    public static  Double SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_PRESTIGE = getDocusignConfig().Sent_to_Comercial_Director_PRESTIGE__c;
    
    public static  Double SENT_TO_PRESIDENT_GREATER_THAN_EVENTOS = getDocusignConfig().Sent_to_President_Eventos__c;
    public static  Double SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_EVENTOS = getDocusignConfig().Sent_to_Financial_Director_Eventos__c;
    public static  Double SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_EVENTOS = getDocusignConfig().Sent_to_Comercial_Director_Eventos__c;
    public static  Double SENT_TO_GERENTE_NACIONAL_ONTRADE_THAN_EVENTOS   = getDocusignConfig().Sent_to_Gerente_Nacional_Eventos__c;

    public static final String AUTH_HEADER = 'X-DocuSign-Authentication';
    public static final String RESEND_ENVELOPE_URL_PARAM = '?resend_envelope=true';

    
    webservice static String requestResendButton(Id recipientId){
		String strResponse = null;
		HTTPResponse objResponse = null;

		System.debug('LAT_Docusign_Utils.requestResendButton [recipientId : ' + recipientId + '] ->');

        objResponse = requestModifyRecipient(recipientId, true);

		if(objResponse != null && objResponse.getStatusCode() != null) {
			System.debug('LAT_Docusign_Utils.requestResendButton [objResponse : ' + objResponse + ']');

			if (objResponse.getStatusCode() >= 200 && objResponse.getStatusCode() < 300) {
				strResponse = 'Alteração realizada na Docusign.';
			} else {
				strResponse = 'Erro ao reenviar o Signatário a Docusign : ' + objResponse.getStatusCode() + objResponse.getBody();
			}
		} else {
			strResponse = 'Erro ao reenviar o Signatário a Docusign';
		}
		
		System.debug('LAT_Docusign_Utils.requestResendButton [' + strResponse + '] <-');
		return strResponse;
    }


	@future(callout=true)
    webservice static void cancelDocusignFuture(Id contractId) {
		List<Lat_contract2__c> lstContract = null;
		List<Attachment> lstAttachments = null;
		Lat_contract2__c objContract = null;

		System.debug('LAT_Docusign_Utils.cancelDocusignFuture [contractId : ' + contractId + '] ->');
		lstContract = [SELECT id, 
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
								Value__c,
								RegionalCustomerOnPremise__c,
								LAT_ClientRegional__c,
								ContractValue__c
							FROM LAT_Contract2__c 
							WHERE Id = :contractId];

		if(!lstContract.IsEmpty()) {
			objContract = lstContract[0];

			lstAttachments = [	SELECT Name, Body 
							  	FROM Attachment 
								WHERE ParentId =: objContract.Id 
								AND Name LIKE 'CANC%'];

			System.debug('LAT_Docusign_Utils.cancelDocusignFuture [lstAttachments : ' + lstAttachments + ']');
			if(!lstAttachments.isEmpty()){
				System.debug('LAT_Docusign_Utils.cancelDocusignFuture [lstAttachments.size() : ' + lstAttachments.size() + ' - lstAttachments[0].Id : ' + lstAttachments[0].Id + ']');
				requestEnvelopeCreation(objContract, lstAttachments);
			} else {
				System.debug('LAT_Docusign_Utils.cancelDocusignFuture [NO CANCE ATTATCHMENT FOUND FOR ' + contractId + ']');
				objContract.ProcessStatus__c = 'Erro Integração DS';
                objContract.Docusign_Error_integration__c = 'NO CANCE ATTATCHMENT FOUND FOR ' + contractId;
                update objContract;
                
			}
		} else {
			throw new Lat_Docusign_Exception('No se encontro el contrato que desea cancelar.');
		}

		System.debug('LAT_Docusign_Utils.cancelDocusignFuture [] <-');
    }
    /**
     * update an recipient in docusign based on our user and resend
     */
    public static HTTPResponse requestModifyRecipient(Id recipientId, boolean resend){
		List<LAT_DocuSign_Recipient_Status__c> lstRecipientStatus = null;    
		LAT_DocuSign_Recipient_Status__c objRecipientStatus = null;        
        Recipients objRecipient = null;
        List<Signers> lstSigners = null;
		Signers objSigner = null;
		String strUrl = null;
		HTTPResponse objReponse = null;

		System.debug('LAT_Docusign_Utils.requestModifyRecipient [recipientId : ' + recipientId + ' - resend : ' + resend + '] ->');
		lstRecipientStatus = [SELECT Id, 
									Name,
									Routing_Order__c,
									Parent_Status_Record__c,
									Role__c,
									RecipientId__c,
									Envelope_Id__c,
									Recipient_Name__c,
									DocuSign_Recipient_Email__c
								FROM LAT_DocuSign_Recipient_Status__c
								WHERE Id = :recipientId];
		
		if(!lstRecipientStatus.IsEmpty()) {
			objRecipientStatus = lstRecipientStatus[0]; 
			objRecipient = new Recipients();
			lstSigners = new List<Signers>();
			objSigner = new Signers();
			
			objSigner.name = objRecipientStatus.Recipient_Name__c;
			objSigner.email =  objRecipientStatus.DocuSign_Recipient_Email__c;
			objSigner.recipientId = objRecipientStatus.RecipientId__c;
			lstSigners.add(objSigner);
			objRecipient.signers = lstSigners;

			strUrl = getBaseUrl();
			strUrl = strUrl + '/envelopes/' + objRecipientStatus.Envelope_Id__c +  '/recipients';
			if (resend){
				strUrl = strUrl + RESEND_ENVELOPE_URL_PARAM;
			}
			
			System.debug('LAT_Docusign_Utils.requestModifyRecipient [strUrl : ' + strUrl + ' - objRecipient : ' + objRecipient + ']');

			objReponse = sentRequestDocusign(JSON.serialize(objRecipient, true), strUrl, 'PUT');
		} else {
			throw new Lat_Docusign_Exception('No se encontro el recipiente a reenviar.');
		}

		System.debug('LAT_Docusign_Utils.requestModifyRecipient [objReponse : ' + objReponse + '] <-');
        return objReponse;
    }

     /**
     * update an recipient in docusign based on our user
     */
    public static void voidEnvelope(){
        // TODO: ADD LOGIC
    }

    /**
     * Create envelope and the docusign mapped objects:
     *      -get the base url to make the callouts
     *      -create the documents based on the attachment list
     *      -create the signers based on the contract information and other conditions
     *      -send request and create objects using the envelope id (those objects will be updated by docusign connect)
     * @param contract
     * @param attachments
     */
    public static void requestEnvelopeCreation(Lat_contract2__c contract, List<Attachment> docToInsert) {
        DS_envelope objEnvelope = null;
        List<DS_document> lstDSDocuments = null;
        List<Signers> lstSigners = null;
		Recipients objRecipients = null;
		DS_document objDSDocument =  null;
		Integer intIndex = 0;
		String strUrl = null;
		HTTPResponse objResponse = null;
		EnvelopeResponse objEnvelopeResponse = null;
		
		System.debug('LAT_Docusign_Utils.requestModifyRecipient [contract : ' + contract + ' - docToInsert : ' + docToInsert + '] ->');

		objEnvelope = new DS_envelope();
        lstDSDocuments = new List<DS_document>();
        lstSigners = new List<Signers>();
		objRecipients = new Recipients();
		
        try{
			intIndex = 1;

            for (Attachment objAttachment : docToInsert){
                objDSDocument = new DS_document();
                objDSDocument.documentBase64 = EncodingUtil.base64Encode(objAttachment.Body);
                objDSDocument.documentId = String.valueOf(intIndex);
                objDSDocument.fileExtension = 'pdf';
                objDSDocument.name = objAttachment.Name;

                objDSDocument.order = String.valueOf(intIndex);
                objDSDocument.transformPdfFields = 'true';
				lstDSDocuments.add(objDSDocument);				
				intIndex++;

				System.debug('LAT_Docusign_Utils.requestModifyRecipient [adding... : ' + intIndex + ' - ' +  objAttachment.Name + ']');
			}
			
			lstSigners = generateSignersFromContract(contract);
			
			objEnvelope.recipients = objRecipients;
			objEnvelope.status = 'sent';
			objEnvelope.emailSubject = 'Assinatura Contrato ' + contract.Name + ' - PERNOD RICARD BRASIL';
            objEnvelope.documents = lstDSDocuments;
			objEnvelope.recipients.signers = lstSigners;
			
            strUrl = getBaseUrl();
			strUrl = strUrl + '/envelopes';
			
			System.debug('LAT_Docusign_Utils.requestModifyRecipient [lstSigners : ' + lstSigners + ']');
			System.debug('LAT_Docusign_Utils.requestModifyRecipient [objEnvelope : ' + objEnvelope + ']');
			System.debug('LAT_Docusign_Utils.requestModifyRecipient [strUrl : ' + strUrl + ']');

            //SENT REQ AND PARSE
            if (Test.isRunningTest()){
                objResponse = new HTTPResponse();
                objResponse.setStatusCode(200);

				objEnvelopeResponse = new EnvelopeResponse();
                objEnvelopeResponse.envelopeId = 'test';
                objEnvelopeResponse.status = 'test';
				objEnvelopeResponse.uri = 'test';
				
                objResponse.setBody(JSON.serialize(objEnvelopeResponse));
            } else {
                objResponse = sentRequestDocusign(JSON.serialize(objEnvelope), strUrl, 'POST');
            }
			 
			System.debug('LAT_Docusign_Utils.requestModifyRecipient [objResponse : ' + objResponse + ']');
			
            if (objResponse.getStatusCode() >= 200 && objResponse.getStatusCode() < 300) {
                objEnvelopeResponse = (EnvelopeResponse) JSON.deserialize(String.valueOf(objResponse.getBody()), EnvelopeResponse.class);
                
                createDsMappingObjects(objEnvelopeResponse, contract.Id, objEnvelope);
				
				contract.ProcessStatus__c = 'Em Assinatura';
                contract.Docusign_Error_integration__c = '';
				contract.ds_Envelope_Id__c = objEnvelopeResponse.envelopeId;
				
				System.debug('LAT_Docusign_Utils.requestModifyRecipient [OK - objEnvelopeResponse.envelopeId : ' + objEnvelopeResponse.envelopeId + ']');
                update contract;
            } else {
                contract.ProcessStatus__c = 'Erro Integração DS';
                contract.Docusign_Error_integration__c = 'response: ' + objResponse + 'Body: ' + objResponse.getBody();

				System.debug('LAT_Docusign_Utils.requestModifyRecipient [Fail - contract.Docusign_Error_integration__c : ' + contract.Docusign_Error_integration__c + ']');

                update contract;
            }
        } catch (Lat_Docusign_Exception Ex) {
            contract.ProcessStatus__c = 'Erro Integração DS';
            contract.Docusign_Error_integration__c = Ex.getMessage();
            update contract;
			
			System.debug('LAT_Docusign_Utils.requestModifyRecipient [Fail - Ex : ' + Ex + ']');

			throw Ex;
        } catch (Exception Ex) {
			System.debug('LAT_Docusign_Utils.requestModifyRecipient [Fail - Ex : ' + Ex + ']');
            throw Ex;
		}
		
		System.debug('LAT_Docusign_Utils.requestModifyRecipient [] <-');
    }


    /**
     * Generate the objects that docusign will keep updating with status change
     * the objects represent a envelope, and each recipient for the envelope
     * @param evelopeId - returned by the docusign ws
     * @param signersInst - the list of signers (the same sent to docusign)
     */
    public static void createDsMappingObjects(EnvelopeResponse resp,Id contractId,DS_envelope env) {
        for (DS_document doc: env.documents){
            doc.documentBase64 = '';
        }

        List<Signers> signersInst = env.recipients.signers;
        LAT_DocuSign_Status__c status = new LAT_DocuSign_Status__c();
        status.DocuSign_Envelope_ID__c = resp.envelopeId;
        status.RecipientsSize__c = signersInst.size();
        status.Lat_contract2__c = contractId;
        status.Api_request_body__c = JSON.serialize(env);
        insert status;

        List<LAT_DocuSign_Recipient_Status__c> recipients = new List<LAT_DocuSign_Recipient_Status__c>();
        for (Signers signer: signersInst){
            LAT_DocuSign_Recipient_Status__c recipient = new LAT_DocuSign_Recipient_Status__c();
            recipient.Recipient_Name__c = signer.name;
            recipient.Name = signer.name;
            recipient.Role__c = signer.RoleName;
            recipient.Parent_Status_Record__c = status.Id;
            recipient.DocuSign_Recipient_Email__c = signer.email;
            recipient.Lat_contract2__c = contractId;
            recipient.RecipientId__c = signer.recipientId;
            recipient.routing_Order__c = Integer.valueOf(signer.routingOrder);
            recipient.Recipient_Status__c = 'Created';
            recipient.related_sfId__c = signer.related_sfId;
            recipients.add(recipient);
        }
        insert recipients;


	}
	
    /**
     * Generate the List on signers based on a contract, this includes
     *  the signers itself and the routing for them
     * @param contract
     * @return list of signers
     */
    public static List<Signers> generateSignersFromContract(Lat_contract2__c objContract){
		List<Signers> lstSigners = null;
		System.debug('LAT_Docusign_Utils.generateSignersFromContract [objContract : ' + objContract.Id + '] ->');

		System.debug('LAT_Docusign_Utils.generateSignersFromContract [objContract.Status__c : ' + objContract.Status__c + ']');
		System.debug('LAT_Docusign_Utils.generateSignersFromContract [objContract.RecordType.DeveloperName : ' + objContract.RecordType.DeveloperName + ']');
		System.debug('LAT_Docusign_Utils.generateSignersFromContract [objContract.LAT_ClientRegional__c : ' + objContract.LAT_ClientRegional__c + ']');

        if (objContract.Status__c == 'Distrato Aprovado') {
            System.debug('LAT_Docusign_Utils.generateSignersFromContract [creating signers for distrato...]');
            if(objContract.RecordType.DeveloperName == 'LAT_BR_Acordo'){
				System.debug('LAT_Docusign_Utils.generateSignersFromContract [creating signers for acordo distrato...]');
                lstSigners = generateSignersNewUpdateContractAcordo(objContract, 'Cancel');
            } else {
                lstSigners = generateSignersForCancel(objContract);
            } 
        } else {
            if(objContract.RecordType.DeveloperName == 'LAT_Eventos_Contrato_de_Parceria') {
				System.debug('LAT_Docusign_Utils.generateSignersFromContract [creating signers for events PRODUTOR...]');
                lstSigners =  generateSignersNewUpdateContractEventos(objContract);
            } else if(objContract.RecordType.DeveloperName == 'LAT_Eventos_Contrato_de_Parceria_Distribuidor'){
				System.debug('LAT_Docusign_Utils.generateSignersFromContract [creating signers for events DISTRIBUIDOR...]');
                lstSigners =  generateSignersNewUpdateContractEventos(objContract);
            } else if(objContract.RecordType.DeveloperName == 'LAT_CartaAtivacao'){
				System.debug('LAT_Docusign_Utils.generateSignersFromContract [creating signers for carta activacion...]');
				lstSigners = generateSignersNewUpdateContractCartaAtivacao(objContract);
			} else if(objContract.RecordType.DeveloperName == 'LAT_BR_Acordo'){
				System.debug('LAT_Docusign_Utils.generateSignersFromContract [creating signers for acordos...]');
                lstSigners = generateSignersNewUpdateContractAcordo(objContract, 'Create');
            } else {
				System.debug('LAT_Docusign_Utils.generateSignersFromContract [others...]');
                if (objContract.LAT_ClientRegional__c  == 'REG NBD') {
					System.debug('LAT_Docusign_Utils.generateSignersFromContract [REG NED...]');
                    lstSigners = generateSignersNewUpdateContractPRESTIGE(objContract);
                } else {
					System.debug('LAT_Docusign_Utils.generateSignersFromContract [others others...]');
                    lstSigners =  generateSignersNewUpdateContract(objContract);
                }
            }            
		}
		
		System.debug('LAT_Docusign_Utils.generateSignersFromContract [' + lstSigners + '] <-');
		return lstSigners;
    }

	public static List<Signers> generateSignersForCancel(Lat_contract2__c contract){
        List<Signers> retSigners = new List<Signers>();
        Set<Id> signersIds = new Set<Id>();
        signersIds.add(contract.GeneralManager__c);
        signersIds.add(contract.Manager__c);
        signersIds.add(contract.RegionalManager__c);
        signersIds.add(getDocusignConfig().LAT_ComercialDirectorId__c);
        signersIds.add(getDocusignConfig().LAT_FinancialDirectorId__c);
        signersIds.add(getDocusignConfig().LAT_PresidentId__c);
        signersIds.add(getDocusignConfig().LAT_TradeManagerId__c);
        signersIds.add(getDocusignConfig().LAT_Testemunha_PRB_Id__c);

        Map<Id, User> userSignMap = new Map<Id, User>([SELECT Id, Name, Email from user where Id in:signersIds]);
        Integer i = 1;
        Integer routingOrder = 1;
        
        // REGIONAL MANAGER
        user regManager = userSignMap.get(contract.RegionalManager__c);
        Signers sign1 = new Signers();
        sign1.recipientId = String.valueOf(1);
        sign1.email = regManager.email;
        sign1.Name = regManager.Name;
        
        sign1.roleName = 'Gerente Regional';
        sign1.tabs = new Tabs(sign1.roleName);
        sign1.related_sfId =contract.RegionalManager__c;
        sign1.routingOrder = String.valueOf(routingOrder );
        routingOrder++;
        system.debug('Signers1+++' + sign1);
        retSigners.add(sign1);
        
        //First add the Client
        Signers client = new Signers();
        client.email = contract.CustomerSignatory__r.email;
        client.name = contract.CustomerSignatory__r.Name;
        client.recipientId = String.valueOf(2);
        client.related_sfId = contract.CustomerSignatory__c;
        client.roleName = 'Cliente';
        client.tabs = new Tabs(client.roleName);
        client.routingOrder = String.valueOf(routingOrder);
        routingOrder++;
        retSigners.add(client);

        return retSigners;
    }

	public static List<Signers> generateSignersNewUpdateContractEventos(Lat_contract2__c contract){
        List<Signers> retSigners = new List<Signers>();
        Set<Id> signersIds = new Set<Id>();
        signersIds.add(contract.GeneralManager__c);
        signersIds.add(contract.Manager__c);
        signersIds.add(contract.RegionalManager__c);
        signersIds.add(getDocusignConfig().LAT_ComercialDirectorId__c);
        signersIds.add(getDocusignConfig().LAT_FinancialDirectorId__c);
        signersIds.add(getDocusignConfig().LAT_PresidentId__c);
        signersIds.add(getDocusignConfig().LAT_TradeManagerId__c);
        signersIds.add(getDocusignConfig().LAT_Testemunha_PRB_Id_Eventos__c);

        Lat_contract2__c conValor = [SELECT id, ContractValue__c, TotalEventContractPRBCost__c,LAT_ClientRegional__c FROM LAT_Contract2__c WHERE ID = :contract.Id LIMIT 1];

        Double valor = conValor.TotalEventContractPRBCost__c;

        Map<Id, User> userSignMap = new Map<Id, User>([SELECT Id, Name, Email from user where Id in:signersIds]);

        Integer i = 1;
        Integer routingOrder = 1;
        //First add the Client
        Signers client = new Signers();
        client.email = contract.CustomerSignatory__r.email;
        client.name = contract.CustomerSignatory__r.Name;
        client.recipientId = String.valueOf(i);
        client.related_sfId = contract.CustomerSignatory__c;
        client.roleName = 'Cliente';
        client.tabs = new Tabs(client.roleName);
        client.routingOrder = String.valueOf(routingOrder);
        routingOrder++;
        retSigners.add(client);

        //  Testemunha Cliente
        if (!contract.Use_Consultant_to_Testify__c){
            Signers testify = new Signers();
            testify.email = contract.CustomerSignedBy__r.email;
            testify.name = contract.CustomerSignedBy__r.Name;
            i++;
            testify.recipientId = String.valueOf(i);
            testify.roleName = 'Testemunha Cliente';
            testify.tabs = new Tabs(testify.roleName);
            testify.related_sfId = contract.CustomerSignedBy__c;
            testify.routingOrder =  String.valueOf(routingOrder);
            routingOrder++;
            retSigners.add(testify);
        } else {
            Signers testify = new Signers();
            testify.email = contract.Owner.email;
            testify.name = contract.Owner.Name;
            i++;
            testify.recipientId = String.valueOf(i);
            testify.roleName = 'Testemunha Cliente';
            testify.related_sfId = contract.OwnerId;
            testify.tabs = new Tabs(testify.roleName);
            testify.routingOrder = String.valueOf(routingOrder);
            routingOrder++;
            retSigners.add(testify);
        }
        
        // TRADE MANAGER
        user tradeManager = userSignMap.get(getDocusignConfig().LAT_TradeManagerId__c);
        Signers sign1 = new Signers();
        i++;
        sign1.recipientId = String.valueOf(i);
        sign1.email = tradeManager.email;
        sign1.Name = tradeManager.Name;
        sign1.roleName = 'Gerente Trade';
        sign1.tabs = new Tabs(sign1.roleName);
        sign1.related_sfId = getDocusignConfig().LAT_TradeManagerId__c;
        sign1.routingOrder = String.valueOf(routingOrder);
        routingOrder++;
        retSigners.add(sign1);

        //GERENTE REGIONAL ON TRADE
        system.debug('VALOR CONTRATO++ = ' + conValor.TotalEventContractPRBCost__c);
        system.debug('VALOR SENT_TO_GERENTE_NACIONAL_ONTRADE_THAN_EVENTOS++ = ' + SENT_TO_GERENTE_NACIONAL_ONTRADE_THAN_EVENTOS);
        if (valor > SENT_TO_GERENTE_NACIONAL_ONTRADE_THAN_EVENTOS){
            if (userSignMap.get(contract.RegionalManager__c) != null) {
                user regManager = userSignMap.get(contract.RegionalManager__c);
                Signers sign1B = new Signers();
                i++;
                sign1B.recipientId = String.valueOf(i);
                sign1B.email = regManager.email;
                sign1B.Name = regManager.Name;
                sign1B.roleName = 'Gerente Nacional On Trade';
                sign1B.tabs = new Tabs(sign1B.roleName);
                sign1B.related_sfId = contract.RegionalManager__c;
                sign1B.routingOrder = String.valueOf(routingOrder );
                routingOrder++;
                retSigners.add(sign1B);
            } else {
                throw new Lat_Docusign_Exception('Gerente Nacional On Trade no encontrado');
            }
        }



        // DIRECTOR COMERCIAL
        system.debug('VALOR CONTRATO++ = ' + conValor.TotalEventContractPRBCost__c);
        system.debug('VALOR SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN++ = ' + SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_EVENTOS);
        if (valor > SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_EVENTOS){
            if (userSignMap.get(getDocusignConfig().LAT_ComercialDirectorId_PRESTIGE__c) != null) {
                user comercialDir = userSignMap.get(getDocusignConfig().LAT_ComercialDirectorId_PRESTIGE__c);
                Signers sign3 = new Signers();
                i++;
                sign3.recipientId = String.valueOf(i);
                sign3.email = comercialDir.email;
                sign3.Name = comercialDir.Name;
                sign3.related_sfId = comercialDir.Id;
                sign3.roleName = 'Diretor Novos Negócios';
                sign3.tabs = new Tabs(sign3.roleName);
                sign3.routingOrder = String.valueOf(routingOrder);
                routingOrder++;
                retSigners.add(sign3);
            } else {
                throw new Lat_Docusign_Exception('Diretro Comercial no encontrado');
            }
        }

        // DIRECTOR FINANCIERO
        system.debug('VALOR CONTRATO++ = ' + conValor.TotalEventContractPRBCost__c);
        system.debug('VALOR SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN++ = ' + SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_EVENTOS);
        if (valor > SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_EVENTOS){
            if (userSignMap.get(getDocusignConfig().LAT_FinancialDirectorId__c) != null) {
                user financialDir = userSignMap.get(getDocusignConfig().LAT_FinancialDirectorId__c);
                Signers sign4 = new Signers();
                i++;
                sign4.recipientId = String.valueOf(i);
                sign4.email = financialDir.email;
                sign4.Name = financialDir.Name;
                sign4.roleName = 'Diretor Financeiro';
                sign4.tabs = new Tabs(sign4.roleName);
                sign4.related_sfId = financialDir.Id;
                sign4.routingOrder = String.valueOf(routingOrder);
                routingOrder++;
                retSigners.add(sign4);
            } else {
                throw new Lat_Docusign_Exception('Diretor Financeiro no encontrado');
            }
        }

        // Presidente
        system.debug('VALOR CONTRATO++ = ' + conValor.TotalEventContractPRBCost__c);
        system.debug('VALOR CONTRAT222++ = ' + valor);
        system.debug('VALOR SENT_TO_PRESIDENT_GREATER_THAN++ = ' + SENT_TO_PRESIDENT_GREATER_THAN_EVENTOS);
        if (valor > SENT_TO_PRESIDENT_GREATER_THAN_EVENTOS){
            if (userSignMap.get(getDocusignConfig().LAT_PresidentId__c) != null) {
                user president = userSignMap.get(getDocusignConfig().LAT_PresidentId__c);
                Signers sign5 = new Signers();
                i++;
                sign5.recipientId = String.valueOf(i);
                sign5.email = president.email;
                sign5.Name = president.Name;
                sign5.roleName = 'Presidente';
                sign5.tabs = new Tabs(sign5.roleName);
                sign5.routingOrder = String.valueOf(routingOrder);  
                routingOrder++;
                retSigners.add(sign5);
            } else {
                throw new Lat_Docusign_Exception('President no encontrado');
            }
        }

        //  Testemunha PRB (ALLWAYS LAST)
        if (userSignMap.get(getDocusignConfig().LAT_Testemunha_PRB_Id_Eventos__c) != null) {
            user testPRB = userSignMap.get(getDocusignConfig().LAT_Testemunha_PRB_Id_Eventos__c);
            Signers sign6 = new Signers();
            i++;
            sign6.recipientId = String.valueOf(i);
            sign6.email = testPRB.email;
            sign6.Name = testPRB.Name;
            sign6.roleName = 'Testemunha PRB';
            sign6.tabs = new Tabs(sign6.roleName);
            sign6.routingOrder = String.valueOf(routingOrder);  
            routingOrder++;
            retSigners.add(sign6);
        } else {
            throw new Lat_Docusign_Exception('Testemunha Prb no encontrado');
        }
        
        return retSigners;
    }

    public static List<Signers> generateSignersNewUpdateContractCartaAtivacao(Lat_contract2__c contract){
        system.debug('entroAca+++');
        List<Signers> retSigners = new List<Signers>();
        Set<Id> signersIds = new Set<Id>();
        signersIds.add(contract.GeneralManager__c);
        signersIds.add(contract.Manager__c);
        signersIds.add(contract.RegionalManager__c);
        signersIds.add(getDocusignConfig().LAT_ComercialDirectorId__c);
        signersIds.add(getDocusignConfig().LAT_FinancialDirectorId__c);
        signersIds.add(getDocusignConfig().LAT_PresidentId__c);
        signersIds.add(getDocusignConfig().LAT_TradeManagerId__c);
        signersIds.add(getDocusignConfig().LAT_Testemunha_PRB_Id_Eventos__c);

        Lat_contract2__c conValor = [SELECT id, ContractValue__c, TotalEventContractPRBCost__c,LAT_ClientRegional__c FROM LAT_Contract2__c WHERE ID = :contract.Id LIMIT 1];


        Double valor = conValor.ContractValue__c;

        Map<Id, User> userSignMap = new Map<Id, User>([SELECT Id, Name, Email from user where Id in:signersIds]);
        Integer i = 1;
        Integer routingOrder = 1;
        //First add the Client
        Signers client = new Signers();
        client.email = contract.CustomerSignatory__r.email;
        client.name = contract.CustomerSignatory__r.Name;
        client.recipientId = String.valueOf(i);
        client.related_sfId = contract.CustomerSignatory__c;
        client.roleName = 'Cliente';
        client.tabs = new Tabs(client.roleName);
        client.routingOrder = String.valueOf(routingOrder);
        routingOrder++;
        retSigners.add(client);
        //  Testemunha Cliente
        if (!contract.Use_Consultant_to_Testify__c){
            Signers testify = new Signers();
            testify.email = contract.CustomerSignedBy__r.email;
            testify.name = contract.CustomerSignedBy__r.Name;
            i++;
            testify.recipientId = String.valueOf(i);
            testify.roleName = 'Testemunha Cliente';
            testify.tabs = new Tabs(testify.roleName);
            testify.related_sfId = contract.CustomerSignedBy__c;
            testify.routingOrder =  String.valueOf(routingOrder);
            routingOrder++;
            retSigners.add(testify);
        } else {
            Signers testify = new Signers();
            testify.email = contract.Owner.email;
            testify.name = contract.Owner.Name;
            i++;
            testify.recipientId = String.valueOf(i);
            testify.roleName = 'Testemunha Cliente';
            testify.related_sfId = contract.OwnerId;
            testify.tabs = new Tabs(testify.roleName);
            testify.routingOrder = String.valueOf(routingOrder);
            routingOrder++;
            retSigners.add(testify);
        }
        
        // TRADE MANAGER
        user tradeManager = userSignMap.get(getDocusignConfig().LAT_TradeManagerId__c);
        Signers sign1 = new Signers();
        i++;
        sign1.recipientId = String.valueOf(i);
        sign1.email = tradeManager.email;
        sign1.Name = tradeManager.Name;
        sign1.roleName = 'Gerente Trade';
        sign1.tabs = new Tabs(sign1.roleName);
        sign1.related_sfId = getDocusignConfig().LAT_TradeManagerId__c;
        sign1.routingOrder = String.valueOf(routingOrder);
        routingOrder++;
        retSigners.add(sign1);

        //GERENTE REGIONAL ON TRADE
        system.debug('VALOR CONTRATO++ = ' + conValor.ContractValue__c);
        system.debug('VALOR SENT_TO_GERENTE_NACIONAL_ONTRADE_THAN_EVENTOS++ = ' + SENT_TO_GERENTE_NACIONAL_ONTRADE_THAN_EVENTOS);
        if (valor > SENT_TO_GERENTE_NACIONAL_ONTRADE_THAN_EVENTOS){
            if (userSignMap.get(contract.RegionalManager__c) != null) {
                user regManager = userSignMap.get(contract.RegionalManager__c);
                Signers sign1B = new Signers();
                i++;
                sign1B.recipientId = String.valueOf(i);
                sign1B.email = regManager.email;
                sign1B.Name = regManager.Name;
                sign1B.roleName = 'Gerente Nacional On Trade';
                sign1B.tabs = new Tabs(sign1B.roleName);
                sign1B.related_sfId = contract.RegionalManager__c;
                sign1B.routingOrder = String.valueOf(routingOrder );
                routingOrder++;
                retSigners.add(sign1B);
            } else {
                throw new Lat_Docusign_Exception('Gerente Nacional On Trade no encontrado');
            }
        }

        //  Testemunha PRB (ALLWAYS LAST)
        if (userSignMap.get(getDocusignConfig().LAT_Testemunha_PRB_Id_Eventos__c) != null) {
            user testPRB = userSignMap.get(getDocusignConfig().LAT_Testemunha_PRB_Id_Eventos__c);
            Signers sign6 = new Signers();
            i++;
            sign6.recipientId = String.valueOf(i);
            sign6.email = testPRB.email;
            sign6.Name = testPRB.Name;
            sign6.roleName = 'Testemunha PRB';
            sign6.tabs = new Tabs(sign6.roleName);
            sign6.routingOrder = String.valueOf(routingOrder);  
            routingOrder++;
            retSigners.add(sign6);
        } else {
            throw new Lat_Docusign_Exception('Testemunha Prb no encontrado');
        }

        return retSigners;
    }

	public static List<Signers> generateSignersNewUpdateContractAcordo(Lat_contract2__c objContractFull, String strAction){
		List<Signers> lstSigners = null;
		List<LAT_Docusign_Signer__c> lstSignersC = null;
        Integer intSignIndex = null;
		Signers objSigner = null;

		System.debug('LAT_Docusign_Utils.generateSignersNewUpdateContractAcordo [objContractFull : ' + objContractFull  + '] ->');
		lstSigners = new List<Signers>();
		
		lstSignersC = retrieveSignersList(objContractFull.RecordType.DeveloperName, strAction);
		intSignIndex = 1;
        
		for(LAT_Docusign_Signer__c objSignerC : lstSignersC) {
			if(objSignerC.LAT_Role__c == 'Cliente') {
				objSigner = createSigner(intSignIndex, objSignerC,objContractFull.CustomerSignatory__c, objContractFull.CustomerSignatory__r.Name, objContractFull.CustomerSignatory__r.Email);
				System.debug('LAT_Docusign_Utils.generateSignersNewUpdateContractAcordo [objSignerC.Role__c : ' + objSignerC.LAT_Role__c + ' - CustomerSignatory__c : ' + objContractFull.CustomerSignatory__c + ' - objSigner : ' + objSigner  + ']');
			} else if(objSignerC.LAT_Role__c == 'Testemunha Cliente') {
				if (objContractFull.Use_Consultant_to_Testify__c) { 
					objSigner = createSigner(intSignIndex, objSignerC,objContractFull.OwnerId, objContractFull.Owner.Name,objContractFull.Owner.Email);					 
					System.debug('LAT_Docusign_Utils.generateSignersNewUpdateContractAcordo [objSignerC.Role__c : ' + objSignerC.LAT_Role__c + ' - Use_Consultant_to_Testify__c : ' + objContractFull.Use_Consultant_to_Testify__c + ' - Owner : ' + objContractFull.Owner + ' - objSigner : ' + objSigner  + ']');
				} else {
					objSigner = createSigner(intSignIndex, objSignerC,objContractFull.CustomerSignedBy__c, objContractFull.CustomerSignedBy__r.Name, objContractFull.CustomerSignedBy__r.Email);					 
					System.debug('LAT_Docusign_Utils.generateSignersNewUpdateContractAcordo [objSignerC.Role__c : ' + objSignerC.LAT_Role__c + ' - Use_Consultant_to_Testify__c : ' + objContractFull.Use_Consultant_to_Testify__c + ' - CustomerSignedBy__c : ' + objContractFull.CustomerSignedBy__c + ' - objSigner : ' + objSigner  + ']');
				}
			} else if(objSignerC.LAT_Signer__c != NULL) {
				objSigner = createSigner(intSignIndex, objSignerC, objSignerC.LAT_Signer__c, objSignerC.LAT_Signer__r.Name, objSignerC.LAT_Signer__r.Email);					 
				System.debug('LAT_Docusign_Utils.generateSignersNewUpdateContractAcordo [objSignerC.Role__c : ' + objSignerC.LAT_Role__c + ' - Signer__c : ' + objSignerC.LAT_Signer__c + ' - objSigner : ' + objSigner  + ']');
			} else {
				throw new Lat_Docusign_Exception('No se configuro el rol para la firma de contratos : ' + objSignerC.LAT_Role__c );
			}

			lstSigners.add(objSigner);
			intSignIndex++;
		}

		System.debug('LAT_Docusign_Utils.generateSignersNewUpdateContractAcordo [' + lstSigners  + '] <-');

        return lstSigners;
    }

	private static Signers createSigner(Integer intSignIndex, LAT_Docusign_Signer__c objSignerC, Id objSFID, String strName, String strEmail) {
		Signers objSigner = null;

	    System.debug('LAT_Docusign_Utils.createSignerByUser[intSignIndex : ' + intSignIndex + ' - objSignerC : ' + objSignerC + ' - strName : ' + strName + ' - strEmail : ' + strEmail + '] ->');
		objSigner = new Signers();
		objSigner.email = strEmail;
		//objSigner.email = 'matias@zimmic.com';
        objSigner.name = strName;
        objSigner.recipientId = String.valueOf(intSignIndex);
        objSigner.related_sfId = objSFID;
        objSigner.roleName = objSignerC.LAT_Role__c;
        objSigner.tabs = new Tabs(objSigner.roleName);
        objSigner.routingOrder = String.valueOf(intSignIndex);

		System.debug('LAT_Docusign_Utils.createSignerByUser[' + objSigner + '] <-');

		return objSigner;
	}

	private static List<LAT_Docusign_Signer__c> retrieveSignersList(String strRecordType, String strAction) {
        Map<String, String> mapRecordMap = null;
        String strType = null;
		List<LAT_Docusign_Signer__c> lstSigners = null;
		Set<Id> setSettingsId = null;

		System.debug('LAT_Docusign_Utils.retrieveSignersList [strRecordType : ' + strRecordType + ' - strAction : ' + strAction + '] ->');

		if(String.IsNotBlank(strRecordType)) {
			mapRecordMap = retrieveRecordMaps();

			if(mapRecordMap.containsKey(strRecordType)) {
				strType = mapRecordMap.get(strRecordType);

				lstSigners = [	SELECT Id,LAT_Docusign__c, LAT_Order__c, LAT_Role__c, LAT_Signer__c, LAT_Signer__r.Name, LAT_Signer__r.Email 
								FROM LAT_Docusign_Signer__c 
                                WHERE LAT_Docusign__r.LAT_Document_Type__c =: strType 
                                AND LAT_Docusign__r.LAT_Action__c =: strAction
								ORDER BY LAT_Order__c ASC];
						
				setSettingsId = new Set<Id>();
				for(LAT_Docusign_Signer__c objSigner : lstSigners) {
					setSettingsId.add(objSigner.LAT_Docusign__c);
				}

				if(setSettingsId.size() > 1) {
					throw new Lat_Docusign_Exception('Se encontraron varias configuraciones para el tipo de contrato : ' + strRecordType );
				}
				if(lstSigners.IsEmpty()) {
					throw new Lat_Docusign_Exception('No se encontraron firmantes para el tipo de contrato : ' + strRecordType );
                }
			} else {
				throw new Lat_Docusign_Exception('Debe configurar los firmantes para el tipo de contrato : ' + strRecordType+ ' - [Error 110]' );
			}
		} else {
			throw new Lat_Docusign_Exception('Debe configurar los firmantes para el tipo de contrato : ' + strRecordType + ' - [Error 100]' );
		}

		System.debug('LAT_Docusign_Utils.retrieveSignersList [' + lstSigners  + '] <-');
				
		return lstSigners;
    }
    
    //RELACION ENTRE EL RECORDDYPE Y EL TYPE
    private static Map<String, String> retrieveRecordMaps() {
        Map<String, String> mapRecordMap = null;

        System.debug('LAT_Docusign_Utils.retrieveRecordMaps[] ->');
        mapRecordMap = new Map<String,String>();
        mapRecordMap.put('LAT_BR_Acordo','Acordo');

        System.debug('LAT_Docusign_Utils.retrieveRecordMaps[' + mapRecordMap + '] <-');
        return mapRecordMap;
    }
	
    public static List<Signers> generateSignersNewUpdateContract(Lat_contract2__c contract){
        system.debug('entroAca+++');
        List<Signers> retSigners = new List<Signers>();
        Set<Id> signersIds = new Set<Id>();
        signersIds.add(contract.GeneralManager__c);
        signersIds.add(contract.Manager__c);
        signersIds.add(contract.RegionalManager__c);
        signersIds.add(getDocusignConfig().LAT_ComercialDirectorId__c);
        signersIds.add(getDocusignConfig().LAT_FinancialDirectorId__c);
        signersIds.add(getDocusignConfig().LAT_PresidentId__c);
        signersIds.add(getDocusignConfig().LAT_TradeManagerId__c);
        signersIds.add(getDocusignConfig().LAT_Testemunha_PRB_Id__c);

        Lat_contract2__c conValor = [SELECT id, ContractValue__c FROM LAT_Contract2__c WHERE ID = :contract.Id LIMIT 1];


        Double valor = conValor.ContractValue__c;

        Map<Id, User> userSignMap = new Map<Id, User>([SELECT Id, Name, Email from user where Id in:signersIds]);
        Integer i = 1;
        Integer routingOrder = 1;
        //First add the Client
        Signers client = new Signers();
        client.email = contract.CustomerSignatory__r.email;
        client.name = contract.CustomerSignatory__r.Name;
        client.recipientId = String.valueOf(i);
        client.related_sfId = contract.CustomerSignatory__c;
        client.roleName = 'Cliente';
        client.tabs = new Tabs(client.roleName);
        client.routingOrder = String.valueOf(routingOrder);
        routingOrder++;
        retSigners.add(client);
        //  Testemunha Cliente
        if (!contract.Use_Consultant_to_Testify__c){
            Signers testify = new Signers();
            testify.email = contract.CustomerSignedBy__r.email;
            testify.name = contract.CustomerSignedBy__r.Name;
            i++;
            testify.recipientId = String.valueOf(i);
            testify.roleName = 'Testemunha Cliente';
            testify.tabs = new Tabs(testify.roleName);
            testify.related_sfId = contract.CustomerSignedBy__c;
            testify.routingOrder =  String.valueOf(routingOrder);
            routingOrder++;
            retSigners.add(testify);
        } else {
            Signers testify = new Signers();
            testify.email = contract.Owner.email;
            testify.name = contract.Owner.Name;
            i++;
            testify.recipientId = String.valueOf(i);
            testify.roleName = 'Testemunha Cliente';
            testify.related_sfId = contract.OwnerId;
            testify.tabs = new Tabs(testify.roleName);
            testify.routingOrder = String.valueOf(routingOrder);
            routingOrder++;
            retSigners.add(testify);
        }

        

        // TRADE GERENTE
        user tradeManager = userSignMap.get(getDocusignConfig().LAT_TradeManagerId__c);
        Signers sign2 = new Signers();
        i++;
        sign2.recipientId = String.valueOf(i);
        sign2.email = tradeManager.email;
        sign2.Name = tradeManager.Name;

        sign2.roleName = 'Gerente Trade';
        sign2.tabs = new Tabs(sign2.roleName);
        sign2.related_sfId = tradeManager.Id;
        sign2.routingOrder = String.valueOf(routingOrder);
        routingOrder++;
        retSigners.add(sign2);
        
        // REGIONAL MANAGER
        user regManager = userSignMap.get(contract.RegionalManager__c);
        Signers sign1 = new Signers();
        i++;
        sign1.recipientId = String.valueOf(i);
        sign1.email = regManager.email;
        sign1.Name = regManager.Name;
        sign1.roleName = 'Gerente Nacional On Trade';
        sign1.tabs = new Tabs(sign1.roleName);
        sign1.related_sfId =contract.RegionalManager__c;
        sign1.routingOrder = String.valueOf(routingOrder );
        routingOrder++;
        retSigners.add(sign1);



        // DIRECTOR COMERCIAL
        system.debug('VALOR CONTRATO++ = ' + contract.ContractValue__c);
        system.debug('VALOR SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN++ = ' + SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN);
        if (valor > SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN){
            if (userSignMap.get(getDocusignConfig().LAT_ComercialDirectorId__c) != null) {
                user comercialDir = userSignMap.get(getDocusignConfig().LAT_ComercialDirectorId__c);
                Signers sign3 = new Signers();
                i++;
                sign3.recipientId = String.valueOf(i);
                sign3.email = comercialDir.email;
                sign3.Name = comercialDir.Name;
                sign3.related_sfId = comercialDir.Id;
                sign3.roleName = 'Diretor Comercial';
                sign3.tabs = new Tabs(sign3.roleName);
                sign3.routingOrder = String.valueOf(routingOrder);
                routingOrder++;
                retSigners.add(sign3);
            } else {
                throw new Lat_Docusign_Exception('Diretro Comercial no encontrado');
            }
        }

        // DIRECTOR FINANCIERO
        system.debug('VALOR CONTRATO++ = ' + contract.ContractValue__c);
        system.debug('VALOR SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN++ = ' + SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN);
        if (valor > SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN){
            if (userSignMap.get(getDocusignConfig().LAT_FinancialDirectorId__c) != null) {
                user financialDir = userSignMap.get(getDocusignConfig().LAT_FinancialDirectorId__c);
                Signers sign4 = new Signers();
                i++;
                sign4.recipientId = String.valueOf(i);
                sign4.email = financialDir.email;
                sign4.Name = financialDir.Name;
                sign4.roleName = 'Diretor Financeiro';
                sign4.tabs = new Tabs(sign4.roleName);
                sign4.related_sfId = financialDir.Id;
                sign4.routingOrder = String.valueOf(routingOrder);
                routingOrder++;
                retSigners.add(sign4);
            } else {
                throw new Lat_Docusign_Exception('Diretor Financeiro no encontrado');
            }
        }



        // Presidente
        system.debug('VALOR CONTRATO++ = ' + contract.ContractValue__c);
        system.debug('VALOR CONTRAT222++ = ' + valor);
        system.debug('VALOR SENT_TO_PRESIDENT_GREATER_THAN++ = ' + SENT_TO_PRESIDENT_GREATER_THAN);
        if (valor > SENT_TO_PRESIDENT_GREATER_THAN){
            if (userSignMap.get(getDocusignConfig().LAT_PresidentId__c) != null) {
                user president = userSignMap.get(getDocusignConfig().LAT_PresidentId__c);
                Signers sign5 = new Signers();
                i++;
                sign5.recipientId = String.valueOf(i);
                sign5.email = president.email;
                sign5.Name = president.Name;
                sign5.roleName = 'Presidente';
                sign5.tabs = new Tabs(sign5.roleName);
                sign5.routingOrder = String.valueOf(routingOrder);  
                routingOrder++;
                retSigners.add(sign5);
            } else {
                throw new Lat_Docusign_Exception('President no encontrado');
            }
        }

        //  Testemunha PRB (ALLWAYS LAST)
        if (userSignMap.get(getDocusignConfig().LAT_Testemunha_PRB_Id__c) != null) {
            user testPRB = userSignMap.get(getDocusignConfig().LAT_Testemunha_PRB_Id__c);
            Signers sign6 = new Signers();
            i++;
            sign6.recipientId = String.valueOf(i);
            sign6.email = testPRB.email;
            sign6.Name = testPRB.Name;
            sign6.roleName = 'Testemunha PRB';
            sign6.tabs = new Tabs(sign6.roleName);
            sign6.routingOrder = String.valueOf(routingOrder);  
            routingOrder++;
            retSigners.add(sign6);
        } else {
            throw new Lat_Docusign_Exception('Testemunha Prb no encontrado');
        }
        
        return retSigners;
    }

    public static List<Signers> generateSignersNewUpdateContractPRESTIGE(Lat_contract2__c contract){
        system.debug('entroAca+++');
        List<Signers> retSigners = new List<Signers>();
        Set<Id> signersIds = new Set<Id>();
        signersIds.add(contract.GeneralManager__c);
        signersIds.add(contract.Manager__c);
        signersIds.add(contract.RegionalManager__c);
        signersIds.add(getDocusignConfig().LAT_ComercialDirectorId_PRESTIGE__c);
        signersIds.add(getDocusignConfig().LAT_FinancialDirectorId__c);
        signersIds.add(getDocusignConfig().LAT_PresidentId__c);
        signersIds.add(getDocusignConfig().LAT_TradeManagerId__c);
        signersIds.add(getDocusignConfig().LAT_Testemunha_PRB_Id_PRESTIGE__c);

        Lat_contract2__c conValor = [SELECT id, ContractValue__c,LAT_ClientRegional__c FROM LAT_Contract2__c WHERE ID = :contract.Id LIMIT 1];


        Double valor = conValor.ContractValue__c;

        Map<Id, User> userSignMap = new Map<Id, User>([SELECT Id, Name, Email from user where Id in:signersIds]);
        Integer i = 1;
        Integer routingOrder = 1;
        //First add the Client
        Signers client = new Signers();
        client.email = contract.CustomerSignatory__r.email;
        client.name = contract.CustomerSignatory__r.Name;
        client.recipientId = String.valueOf(i);
        client.related_sfId = contract.CustomerSignatory__c;
        client.roleName = 'Cliente';
        client.tabs = new Tabs(client.roleName);
        client.routingOrder = String.valueOf(routingOrder);
        routingOrder++;
        retSigners.add(client);
        //  Testemunha Cliente
        if (!contract.Use_Consultant_to_Testify__c){
            Signers testify = new Signers();
            testify.email = contract.CustomerSignedBy__r.email;
            testify.name = contract.CustomerSignedBy__r.Name;
            i++;
            testify.recipientId = String.valueOf(i);
            testify.roleName = 'Testemunha Cliente';
            testify.tabs = new Tabs(testify.roleName);
            testify.related_sfId = contract.CustomerSignedBy__c;
            testify.routingOrder =  String.valueOf(routingOrder);
            routingOrder++;
            retSigners.add(testify);
        } else {
            Signers testify = new Signers();
            testify.email = contract.Owner.email;
            testify.name = contract.Owner.Name;
            i++;
            testify.recipientId = String.valueOf(i);
            testify.roleName = 'Testemunha Cliente';
            testify.related_sfId = contract.OwnerId;
            testify.tabs = new Tabs(testify.roleName);
            testify.routingOrder = String.valueOf(routingOrder);
            routingOrder++;
            retSigners.add(testify);
        }
        
        // REGIONAL MANAGER
        user regManager = userSignMap.get(contract.RegionalManager__c);
        Signers sign1 = new Signers();
        i++;
        sign1.recipientId = String.valueOf(i);
        sign1.email = regManager.email;
        sign1.Name = regManager.Name;
        sign1.roleName = 'Gerente Nacional NBD';
        sign1.tabs = new Tabs(sign1.roleName);
        sign1.related_sfId =contract.RegionalManager__c;
        sign1.routingOrder = String.valueOf(routingOrder );
        routingOrder++;
        retSigners.add(sign1);



        // DIRECTOR COMERCIAL
        system.debug('VALOR CONTRATO++ = ' + contract.ContractValue__c);
        system.debug('VALOR SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN++ = ' + SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_PRESTIGE);
        if (valor > SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_PRESTIGE){
            if (userSignMap.get(getDocusignConfig().LAT_ComercialDirectorId_PRESTIGE__c) != null) {
                user comercialDir = userSignMap.get(getDocusignConfig().LAT_ComercialDirectorId_PRESTIGE__c);
                Signers sign3 = new Signers();
                i++;
                sign3.recipientId = String.valueOf(i);
                sign3.email = comercialDir.email;
                sign3.Name = comercialDir.Name;
                sign3.related_sfId = comercialDir.Id;
                sign3.roleName = 'Diretor Novos Negócios';
                sign3.tabs = new Tabs(sign3.roleName);
                sign3.routingOrder = String.valueOf(routingOrder);
                routingOrder++;
                retSigners.add(sign3);
            } else {
                throw new Lat_Docusign_Exception('Diretro Comercial no encontrado');
            }
        }

        // DIRECTOR FINANCIERO
        system.debug('VALOR CONTRATO++ = ' + contract.ContractValue__c);
        system.debug('VALOR SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN++ = ' + SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_PRESTIGE);
        if (valor > SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_PRESTIGE){
            if (userSignMap.get(getDocusignConfig().LAT_FinancialDirectorId__c) != null) {
                user financialDir = userSignMap.get(getDocusignConfig().LAT_FinancialDirectorId__c);
                Signers sign4 = new Signers();
                i++;
                sign4.recipientId = String.valueOf(i);
                sign4.email = financialDir.email;
                sign4.Name = financialDir.Name;
                sign4.roleName = 'Diretor Financeiro';
                sign4.tabs = new Tabs(sign4.roleName);
                sign4.related_sfId = financialDir.Id;
                sign4.routingOrder = String.valueOf(routingOrder);
                routingOrder++;
                retSigners.add(sign4);
            } else {
                throw new Lat_Docusign_Exception('Diretor Financeiro no encontrado');
            }
        }



        // Presidente
        system.debug('VALOR CONTRATO++ = ' + contract.ContractValue__c);
        system.debug('VALOR CONTRAT222++ = ' + valor);
        system.debug('VALOR SENT_TO_PRESIDENT_GREATER_THAN++ = ' + SENT_TO_PRESIDENT_GREATER_THAN_PRESTIGE);
        if (valor > SENT_TO_PRESIDENT_GREATER_THAN_PRESTIGE){
            if (userSignMap.get(getDocusignConfig().LAT_PresidentId__c) != null) {
                user president = userSignMap.get(getDocusignConfig().LAT_PresidentId__c);
                Signers sign5 = new Signers();
                i++;
                sign5.recipientId = String.valueOf(i);
                sign5.email = president.email;
                sign5.Name = president.Name;
                sign5.roleName = 'Presidente';
                sign5.tabs = new Tabs(sign5.roleName);
                sign5.routingOrder = String.valueOf(routingOrder);  
                routingOrder++;
                retSigners.add(sign5);
            } else {
                throw new Lat_Docusign_Exception('President no encontrado');
            }
        }

        //  Testemunha PRB (ALLWAYS LAST)
        if (userSignMap.get(getDocusignConfig().LAT_Testemunha_PRB_Id_PRESTIGE__c) != null) {
            user testPRB = userSignMap.get(getDocusignConfig().LAT_Testemunha_PRB_Id_PRESTIGE__c);
            Signers sign6 = new Signers();
            i++;
            sign6.recipientId = String.valueOf(i);
            sign6.email = testPRB.email;
            sign6.Name = testPRB.Name;
            sign6.roleName = 'Testemunha PRB';
            sign6.tabs = new Tabs(sign6.roleName);
            sign6.routingOrder = String.valueOf(routingOrder);  
            routingOrder++;
            retSigners.add(sign6);
        } else {
            throw new Lat_Docusign_Exception('Testemunha Prb no encontrado');
        }
        
        return retSigners;
	}
	
    /**
     * get the base Url for the next callouts 
     */
    public static String getBaseUrl(){
        String strInitUrl = null;
        HTTPResponse objResponse = null;
        LoginInfo objLoginInfo = null;
		LoginAccounts objLoginAccounts = null;
		String strBaseUrl = null;

		System.debug('LAT_Docusign_Utils.getBaseUrl [] ->');

		strInitUrl = LAT_Docusign_Config__c.getInstance().ds_InitUrl__c;
        objResponse = sentRequestDocusign(null, strInitUrl, 'GET');
		
		if(Test.isRunningTest()){
            objLoginInfo = new LoginInfo();
            objLoginInfo.loginAccounts = new List<LoginAccounts>();
            objLoginAccounts = new LoginAccounts();
            objLoginAccounts.accountId = 'test';
            objLoginAccounts.baseUrl = 'test';
            objLoginAccounts.isDefault = 'test';
            objLoginAccounts.userName = 'test';
            objLoginAccounts.userId = 'test';
            objLoginAccounts.email = 'test';
            objLoginAccounts.siteDescription = 'test';
            objLoginInfo.loginAccounts.add(objLoginAccounts);
        } else {
            objLoginInfo = (LoginInfo) JSON.deserialize(String.valueOf(objResponse.getBody()), LoginInfo.class);
		}
		
		if(objLoginInfo != NULL && objLoginInfo.loginAccounts != NULL && objLoginInfo.loginAccounts.size() > 0 && String.IsNotBlank(objLoginInfo.loginAccounts[0].baseUrl)) {
			strBaseUrl = objLoginInfo.loginAccounts[0].baseUrl;
		} else {
			System.debug('LAT_Docusign_Utils.getBaseUrl [Invalid objLoginInfo : ' + objLoginInfo + ']');

			throw new Lat_Docusign_Exception('No se ha podido retornar la URL base');
		}

		System.debug('LAT_Docusign_Utils.getBaseUrl [' + strBaseUrl + '] <-');
        return strBaseUrl;
    }

    /**
     * Sent an request to docusing, handle the authentication and generate the request
     * @return httpresponse - resp from the server
     */
    public static HttpResponse sentRequestDocusign(String strBody, String strUrl,String strMethod){
        HttpRequest objRequest = null;
        Http objHttp = null;
        HTTPResponse objResponse = null;
		AuthHeader objAuthHeader = null;

		System.debug('LAT_Docusign_Utils.sentRequestDocusign [strBody : ' + strBody + ' - strUrl : ' + strUrl + ' - strMethod : ' + strMethod  + '] ->');

		if(Test.isRunningTest()){
            strUrl = 'test';
            strMethod = 'POST';
            strBody = 'test';
		}
		
		objAuthHeader = getCredentialData();
        objRequest = new HttpRequest();
        objRequest.setHeader('Content-Type' , 'application/json');
        objRequest.setHeader(AUTH_HEADER , JSON.serialize(objAuthHeader));
        objRequest.setEndPoint(strUrl);
        objRequest.setMethod(strMethod);

        if ( String.IsNotBlank(strBody)){
            objRequest.setBody(strBody);
        }
		objHttp = new Http();
		System.debug('LAT_Docusign_Utils.sentRequestDocusign[objAuthHeader : ' + objAuthHeader + ']');
		System.debug('LAT_Docusign_Utils.sentRequestDocusign [strUrl : ' + strUrl + ']');
		System.debug('LAT_Docusign_Utils.sentRequestDocusign [strMethod : ' + strMethod + ']');
		System.debug('LAT_Docusign_Utils.sentRequestDocusign [strBody : ' + strBody + ']');

        if(Test.isRunningTest()){
            objResponse = new HTTPResponse();
        } else {
            objResponse = objHttp.send(objRequest);
        }
		
		System.debug('LAT_Docusign_Utils.sentRequestDocusign [' + objResponse + '] <-');
        return objResponse;
    }

    /**
     * Method to get the Credentials to Log into docusign
     * TODO: usage of a custom setting to handle the data.
     */
    public static AuthHeader getCredentialData(){
		LAT_Docusign_Config__c objConfig = null;
		AuthHeader objAuthHeader = null;

		System.debug('LAT_Docusign_Utils.getCredentialData [] ->');

		objConfig = getDocusignConfig();
		objAuthHeader = new AuthHeader(objConfig.ds_Username__c, objConfig.ds_password__c, objConfig.ds_integrationKey__c);

		System.debug('LAT_Docusign_Utils.getCredentialData [' + objAuthHeader + '] <-');

        return objAuthHeader;
    }

    /**
     * class to get the docusign config data
     * singleton usage
     * @return - config for docusign confing
     */
    public static LAT_Docusign_Config__c getDocusignConfig(){
		System.debug('LAT_Docusign_Utils.getDocusignConfig [] ->');

		if (dsConfig == null){
            dsConfig = LAT_Docusign_Config__c.getInstance();
		}

		System.debug('LAT_Docusign_Utils.getDocusignConfig [' + dsConfig + '] <-');

        return dsConfig;
	}
	
	
    /**
     * Wrapper classes to handle the envelope creation
     */
    public class DS_envelope{
		public List<ds_document> documents{get;set;}
		public String emailSubject{get;set;}
		public Recipients recipients{get;set;}
		public String status{get;set;}
  	}

	public class DS_document{
		public String documentBase64{get;set;}
		public String documentId{get;set;} 
		public String fileExtension{get;set;} 
		public String name{get;set;} 
		public String order{get;set;} 
		public String transformPdfFields{get;set;} 
	}

	public class Signers{
		public String email{get;set;} 
		public String name{get;set;} 
		public String recipientId{get;set;} 
		public String roleName{get;set;} 
		public String routingOrder{get;set;} 
		public Tabs tabs{get;set;} 

		// Local usage only, transient to avoid sent to docusign
		public transient String related_sfId{get;set;} 
	}

	public class Recipients{
		public List<Signers> signers; 
	}

	public class Tabs {
		public List<SignHereTabs> signHereTabs{get;set;} 
		public List<TextTabs> textTabs{get;set;}
		public List<FullNameTabs> fullNameTabs{get;set;} 
		

		public Tabs(String role){
			this.signHereTabs = new List<SignHereTabs>();
			this.textTabs = new List<TextTabs>();
			this.fullNameTabs = new List<FullNameTabs>();

			this.signHereTabs.add(new SignHereTabs('/signTabv1' + role.replaceAll( '\\s+', '') + '/'));
			this.signHereTabs.add(new SignHereTabs('/signTabv2' + role.replaceAll( '\\s+', '') + '/'));
			this.signHereTabs.add(new SignHereTabs('/signTabMinuta' + role.replaceAll( '\\s+', '') + '/'));
			this.fullNameTabs.add(new FullNameTabs('/nameTabv1' + role.replaceAll( '\\s+', '') + '/'));
			this.fullNameTabs.add(new FullNameTabs('/nameTabv2' + role.replaceAll( '\\s+', '') + '/'));
			this.fullNameTabs.add(new FullNameTabs('/nameTabMinuta' + role.replaceAll( '\\s+', '') + '/'));
			this.textTabs.add(new textTabs('/textTabCPFv1' + role.replaceAll( '\\s+', '') + '/'));
			this.textTabs.add(new textTabs('/textTabCPFv2' + role.replaceAll( '\\s+', '') + '/'));
			this.textTabs.add(new textTabs('/textTabCPFMinuta' + role.replaceAll( '\\s+', '') + '/'));
		}
	}

	public class SignHereTabs {
		public String anchorString{get;set;}
		public String anchorUnits{get;set;} 
		public String anchorXOffset{get;set;}
		public String anchorYOffset{get;set;}
		public String width {get;set;}
		public String required {get;set;}
		public String anchorIgnoreIfNotPresent{get;set;}

		/*
		* Basic constructor, only set the anchor string and use constant data
		*/
		public SignHereTabs (String tab){
			this.anchorString = tab;
			this.anchorUnits = 'cms';
			this.anchorXOffset = '0';
			this.anchorYOffset = '0';
			this.required = 'true';
			this.width = '50';
			this.anchorIgnoreIfNotPresent = 'true';
		}
	}

	public class TextTabs {
		public String anchorString{get;set;}
		public String anchorUnits{get;set;} 
		public String anchorXOffset{get;set;}
		public String anchorYOffset{get;set;}
		public String width {get;set;}
		public String required {get;set;}
		public String anchorIgnoreIfNotPresent{get;set;}
		/*
		* Basic constructor, only set the anchor string and use constant data
		*/
		public TextTabs (String tab){
			this.anchorString = tab;
			this.anchorUnits = 'cms';
			this.anchorXOffset = '0';
			this.anchorYOffset = '0';
			this.width = '65';
			this.required = 'true';
			this.anchorIgnoreIfNotPresent = 'true';

		}

	}

	public class FullNameTabs {
		public String anchorString{get;set;}
		public String anchorUnits{get;set;} 
		public String anchorXOffset{get;set;}
		public String anchorYOffset{get;set;}
		public String width {get;set;}
		public String required {get;set;}
		public String anchorIgnoreIfNotPresent{get;set;}
		public String FontSize{get;set;}
		/*
		* Basic constructor, only set the anchor string and use constant data
		*/
	  	public FullNameTabs (String tab){
			this.anchorString = tab;
			this.anchorUnits = 'cms';
			this.anchorXOffset = '0';
			this.anchorYOffset = '0';
			this.width = '50';
			this.required = 'true';
			this.anchorIgnoreIfNotPresent = 'true';
			this.FontSize = 'Size8';
	  	}
  	}
	/**
	 * Wrapper classes to handle the login info
	*/
	public class LoginAccounts{
		public String name{get;set;}  
		public String accountId{get;set;}  
		public String baseUrl{get;set;}  
		public String isDefault{get;set;}  
		public String userName{get;set;}  
		public String userId{get;set;} 
		public String email{get;set;} 
		public String siteDescription{get;set;} 
	}
	  
	public class LoginInfo{
		public List<LoginAccounts> loginAccounts{get;set;}  
	}
	
    public class AuthHeader {
        public String Username;
        public String Password;
        public String IntegratorKey;

        public AuthHeader(String Username, String Password, String IntegratorKey){
            this.Username = Username;
            this.Password = Password;
            this.IntegratorKey = IntegratorKey;
        }
    }

    public class EnvelopeResponse {
        public String envelopeId{get;set;} 
        public String status{get;set;} 
        public String uri{get;set;} 
        public String statusDateTime{get;set;}
    }

}