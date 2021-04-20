/*
* LAT_signatureFlowController
* Author: Martin Prado (martin@zimmic.com)
* Date: 08/04/2016
*/
public with sharing class LAT_signatureFlowController {

	public Map<String, String> labels {get;set;}
	public Integer currentItem {get;set;}
	public List<String> availableItems {get;set;}
	private final LAT_Contract2__c contract;

	/**
	* LAT_signatureFlowController Constructor
	* Post on the object feed
	*/
	public LAT_signatureFlowController(ApexPages.StandardController controller) {
		this.contract = (LAT_Contract2__c)controller.getRecord();
		labels = new Map<String, String>();
		availableItems = new List<String>();
		Integer i = 0;
		currentItem = -1;

		Schema.DescribeFieldResult fieldResult = LAT_Contract2__c.SignaturesFlow__c.getDescribe();
   	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple){
			if(this.contract.SignaturesFlow__c != '' ){
				if(this.contract.SignaturesFlow__c == f.getValue()){
					currentItem = i;
				}

			}
      labels.put(f.getLabel(), f.getValue());
			availableItems.add(f.getValue());
			i ++;
   	}
	}


	/**
	* chatterPost
	* @param contract signature index
	* Post on the object feed, update the singature flow in the contract, and activate the contract if we are in the last signature
	*/
	public void chatterPost(){

    String item = system.CurrentPageReference().getParameters().get('item');
		Integer index =  Integer.ValueOf(item);

		this.contract.SignaturesFlow__c = availableItems[index];
		if(labels.size()== index+1) {
			this.contract.status__c = 'Ativo';
		}
		update this.contract;
	}

  /**
	* updateSignature
	* @param contract signature index
	* Update the singature flow in the contract and activate the contract if we are in the last signature
	*/
	public void updateSignature(){

    String item = system.CurrentPageReference().getParameters().get('item');
		Integer index =  Integer.ValueOf(item);

    if(index == 0 || labels.size()== index+1){
      insertChatterMessage(index, this.contract.Name, this.contract.owner.Name);
      if(labels.size()== index+1) {
  			this.contract.status__c = 'Ativo';
  		}
    }

    if(index == 1 || index ==3){
      String email = '';

      if(index == 1){
        Id accountId = this.contract.Account__c;
        System.debug(accountId);
        Account lcc = [SELECT Regional__c, Regional__r.Name, LAT_BR_RegionalClientOnPremise__c  FROM Account where id=:accountId limit 1];


				if(lcc.Regional__c != null){
          String regName = lcc.LAT_BR_RegionalClientOnPremise__c;
          List<LAT_RegionalSupervisor__c> ars = [SELECT AssistenteRegional__c, AssistenteRegional__r.Email, LAT_RegionalClientOnPremise__c FROM LAT_RegionalSupervisor__c where LAT_RegionalClientOnPremise__c =:regName and AssistenteRegional__c != '' ];
          if(ars.size()>0){
            LAT_RegionalSupervisor__c ar = ars[0];
            email = ar.AssistenteRegional__r.email;

						sendEmailNotification(index, new String[] {email}, Double.valueOf(this.contract.contractValue__c),this.contract.name, this.contract.Id);
          }
        }
      } else {
        //email = 'martin@zimmic.com';
        String[] emails = LAT_GeneralConfigDao.getValueAsStringArray('LAT_CONTRACT_TRADE_EMAIL', ',');

				List<GroupMember>  groupMembers = [SELECT GroupId,UserOrGroupId, group.developerName FROM GroupMember where group.developerName= 'LAT_BR_ContractTrade'];
        system.debug('>>>>>>'+groupMembers);
				if(!groupMembers.isEmpty()){

					Set<Id> uIds = new Set<Id>();
					List<User> userToNotify = new List<User>();

					for(GroupMember gm : groupMembers){
						uIds.add(gm.UserOrGroupId);
					}

          system.debug('>>>>>>uIds'+uIds);

					userToNotify = [Select email FROM User where id in:uIds];

          system.debug('>>>>>>userToNotify'+userToNotify);
					if(userToNotify.size()>0){
	          String[] mailAddress = new String[]{};
						for(User u : userToNotify){
							mailAddress.add(u.email);
						}
            system.debug('>>>>>>mailAddress'+mailAddress);
	          sendEmailNotification(index, mailAddress, Double.valueOf(this.contract.contractValue__c), this.contract.name, this.contract.Id);
	        }
				}


      }

    }

		this.contract.SignaturesFlow__c = availableItems[index];
		update this.contract;
	}

	/**
	* insertChatterMessage
	* @param step - Number of signature flow step
	* @param contractName - Contract Name
	* @param clientName - Client Name
	* Return the text to post on chatter: 'Contrato CON-000001 do cliente Martin Prado assinado pelo cliente e encaminhado para o Coordenador.'
	*/
	public void insertChatterMessage(Integer step, String contractName, String clientName){
		String text = '';
		// if(step == 0){
		// 	//text = Label.LAT_BR_Step01Signature.replace('{0}', contractName).replace('{1}', clientName);
    //   text = 'Contrato {0} do cliente {1} assinado pelo cliente e encaminhado para o Assistente Regional'.replace('{0}', contractName).replace('{1}', clientName);
		// } else
    if(step == 7) {
      text = 'Contrato {0} do cliente {1} Ativado.'.replace('{0}', contractName).replace('{1}', clientName);
    }

    FeedItem post = new FeedItem();
        if (Test.isRunningTest()) {
            text = 'Test';
        }
		post.Body = text;
		post.ParentId = this.contract.Id;
		post.Title = 'Contrato: ' + this.contract.Name;
		insert post;
	}

	/**
	* sendEmailNotification
	* @param step - Number of signature flow step
	*/
	public void sendEmailNotification(Integer step, String[] mailAddress, Double contractValue, String contractName, String contractId){

	  String html = '';
    String subject = '';
    Boolean mustSend = False;

    if(step == 1){
      mustSend = True;
      subject = 'Assunto: Procedimento - Contrato Assinado Recebido Consultor - '+ ' '+contractName;
      //
      if(contractValue < 20000) {
        html = 'Realizar as seguintes atividades:<br/><ul><li>Coletar assinatura do Gerente Regional</li></ul><br/>Obrigado.';
      }
      // We must add 150k limit
      else {
        html = 'Realizar as seguintes atividades:<br/><ul><li>Coletar assinatura do Gerente Regional</li><li>Entregar o Contrato assinado para Trade Canal</li></ul><br/>Obrigado.';
      }
    } else if(step == 3){
      mustSend = True;
      subject = ' Procedimento - Contrato Assinado Recebido Ass. Regional - '+ ' '+contractName;
      html = 'Realizar as seguintes atividades:<br/><ul><li>###</li><li>Escanear contrato</li><li>Anexar no Contrato no Sistema (Digital)</li><li>Encaminhar via impressa para Assistente Regional</li><li>Arquivar o contrato original (Papel)</li></ul><br/>Obrigado.';
      //
      if(contractValue < 20000 ) {
        html =  html.replace('###','');
      }
      if(contractValue > 20000 && contractValue <150000) {
        html =  html.replace('###','Colher assinatura do Gerente de Trade');
      }
      if(contractValue > 150000 && contractValue <300000) {
        html =  html.replace('###','Colher assinatura do Gerente de Trade + Diretor Comercial');
      }
      if(contractValue > 300000 && contractValue <500000) {
        html =  html.replace('###','Colher assinatura do Gerente de Trade + Diretor Comercial + Diretor Financeiro');
      }
      if(contractValue > 500000 ) {
        html =  html.replace('###','Colher assinatura do Gerente de Trade + Diretor Comercial + Diretor Financeiro + Presidente');
      }
    }
    if(mustSend){
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
     //  String[] toAddresses = ;
      email.setToAddresses( mailAddress );
      email.setSaveAsActivity(false);
      email.setHtmlBody(html);
      email.setBccSender(false);
      email.setSubject(subject);
      email.setUseSignature(false);
      Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

	}



}