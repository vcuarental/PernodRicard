public with sharing class LAT_POP_ColetarEvidenciaController {


	public static List<Attachment> allAttachment {get;set;}
    public String filterOption {get;set;}

    //Objects to be filtered
    public LAT_ClientPOP__c clientPop {get;set;}

    public Contact dataEntregaDeMock {get;set;}
    public Contact dataEntregaAteMock {get;set;}

    public Date dataEntregaDe {get;set;}
    public Date dataEntregaAte {get;set;}
    public LAT_AccountInAction__c clienteFoco {get;set;}

    public LAT_POP_ColetarEvidenciaController() {
    	clientPop = new LAT_ClientPOP__c();
    	clienteFoco = new LAT_AccountInAction__c();
    	dataEntregaDeMock = new Contact(Birthdate = null);
    	dataEntregaAteMock = new Contact(Birthdate = null);
        allAttachment = new List<Attachment>();
    }
     public List<SelectOption> getFilterOptiones() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('--None--','--None--'));
            options.add(new SelectOption('MATERIAL POP', label.LAT_ColetarEvidenciaOpciones));
            options.add(new SelectOption('AÇÕES PROMOCIONAIS',label.LAT_ColetarEvidenciaOpciones3));

            return options;
     }

     public PageReference changeOption (){
	     	listAttachmentItem = new List<AttachmentItem>();
	     	allAttachmentMaterial = new LIst<Attachment>();
     		return null;
     }

     public List<Attachment> allAttachmentMaterial{get;set;}
     public List<AttachmentItem> listAttachmentItem {get;set;}

     public PageReference searchEvidencia(){

     	listAttachmentItem = new List<AttachmentItem>();
     	Map<String,String> mapTaskWithMaterial = new Map<String,String>();
     	Map<Id,LAT_ClientPOP__c> mapIdMaterialPop = new Map<Id,LAT_ClientPOP__c>();
     	allAttachmentMaterial = new LIst<Attachment>();

     	try{

     		String queryStr = 'Select Id,Name,Material_POP__c,Material_POP__r.Name,LAT_Client__c,LAT_Client__r.Client_code_AN8__c,LAT_Client__r.Name,Delivered__c,Delivered_Date__c From LAT_ClientPOP__c ';
 			//Search Material POP
	     	if(filterOption == 'MATERIAL POP'){


	     		if(clientPop.LAT_Client__c != null && clientPop.Material_POP__c != null){
	     			queryStr += 'WHERE Material_POP__c =\'' +clientPop.Material_Pop__c+'\'';
	     			queryStr += ' AND LAT_Client__c =\'' +clientPop.LAT_Client__c+'\'';
	     		}else if(clientPop.LAT_Client__c == null && clientPop.Material_POP__c != null){
	     			queryStr += 'WHERE Material_POP__c =\'' +clientPop.Material_Pop__c+'\'';
	     		}else if(clientPop.LAT_Client__c != null && clientPop.Material_POP__c == null){
	     			queryStr += 'WHERE LAT_Client__c =\'' +clientPop.LAT_Client__c+'\'';
	     		}

	     		if(queryStr.contains('WHERE')){
	     			queryStr += ' AND';
	     		}else{
	     			queryStr += 'WHERE';
	     		}
	     		if(dataEntregaDeMock.Birthdate != null && dataEntregaAteMock.Birthdate != null){
	     			String deDate = String.valueOf(dataEntregaDeMock.Birthdate).split(' ')[0];
	     			String ateDAte = String.valueOf(dataEntregaAteMock.Birthdate).split(' ')[0];
	     			queryStr += ' Delivered_Date__c >= ' + deDate + ' AND Delivered_Date__c <= '+ateDAte;
	     		}else if(dataEntregaDeMock.Birthdate == null && dataEntregaAteMock.Birthdate != null){
	     			String ateDAte = String.valueOf(dataEntregaAteMock.Birthdate).split(' ')[0];
	     			queryStr += ' Delivered_Date__c <= '+ateDAte;
	     		}else if(dataEntregaDeMock.Birthdate != null && dataEntregaAteMock.Birthdate == null){
	     			String deDate = String.valueOf(dataEntregaDeMock.Birthdate).split(' ')[0];
	     			queryStr += ' Delivered_Date__c >= ' +  deDate;
	     		}else{
	     			queryStr = queryStr.subString(0,queryStr.length()-3);
	     		}

	     		system.debug('queryStr: ' + queryStr);
	     		List<LAT_ClientPOP__c> listEntregaMaterial = (List<LAT_ClientPOP__c>)Database.query(queryStr);
	     		if(!listEntregaMaterial.isEmpty()){
	     			Set<Id> materialIds = new Set<Id>();
	     			for(LAT_ClientPOP__c lcp : listEntregaMaterial) {
	     				materialIds.add(lcp.Id);
	     				//Maps & lists to be used to match attId url
	     				mapIdMaterialPop.put(lcp.Id,lcp);
	     			}
	     			List<Task> allTask = [SELECT id,whatId
	     							      from task
	     							      where (LAT_Tipo__c =: 'POP-Coletar Evidencia'
	     							      OR LAT_Tipo__c =: 'POP-Entregar Material')
	     							      AND WhatId In :materialIds];

	     			if(allTask != null &&  allTAsk.size()>0){
			        	Set<Id> taskIds = new Set<Id>();
			        	for(Task t: allTask){
			        		taskIds.add(t.Id);
				        	mapTaskWithMaterial.put(t.Id,t.whatId);
			        	}
			            allAttachmentMaterial = [SELECT id,name, parentID
					             				  from Attachment
					             				  where parentID IN: taskIds];
					    AttachmentItem aItem;
						for(Attachment a : allAttachmentMaterial){
							if(mapTaskWithMaterial.get(a.ParentId) != null){
								String materialId = mapTaskWithMaterial.get(a.ParentId);
								if(mapIdMaterialPop.get(materialId) != null){
									LAT_ClientPOP__c lcp = mapIdMaterialPop.get(materialId);
									aItem = new AttachmentItem();
				     				aItem.clientNameAN8 = lcp.LAT_Client__r.Client_code_AN8__c + ' - ' + lcp.LAT_Client__r.Name;
				     				aItem.clientURL = URL.getSalesforceBaseUrl().toExternalForm() +'/'+lcp.LAT_Client__c;
				     				aItem.dataEntrega = lcp.Delivered_Date__c;
				     				aItem.quantidadeEntrega = lcp.Delivered__c;
				     				aItem.materialId = lcp.Id;
				     				aItem.materialName = lcp.Material_POP__r.Name;
				     				aItem.taskId = a.ParentId;
									aItem.attId = a.Id;
									aItem.rowMessage = '<b>Cliente:</b> <a href="'+aItem.clientURL+'" target="_blank">' +aItem.clientNameAN8 + '</a><br/>' + '<b>Material POP:</b> '+aItem.materialName + '<br/>' + '<b>Data Entrega:</b> ' + aItem.dataEntrega.format() + '<br/>' + '<b>Quantidade Entregue:</b> ' + aItem.quantidadeEntrega;
				     				listAttachmentItem.add(aItem);
								}
							}
						}

			        }
	     		}
	     	}else if(filterOption == 'AÇÕES PROMOCIONAIS'){

	     		String queryStrFoco = 'SELECT LAT_PromotionalAction__r.LAT_Quantidade_de_Clientes__c,LAT_PromotionalAction__r.LAT_StartDate__c,LAT_PromotionalAction__r.LAT_EndDate__c,LAT_PromotionalAction__r.Name,LAT_Account__r.Client_code_AN8__c,LAT_Account__r.Name,Id,LastViewedDate,LAT_Account__c,LAT_PromotionalAction__c,LAT_Status__c,Name, LAT_PromotionalAction__r.LAT_Status__c FROM LAT_AccountInAction__c ';

	     		if(clienteFoco.LAT_Account__c != null && clienteFoco.LAT_PromotionalAction__c != null){
	     			queryStrFoco += 'WHERE LAT_PromotionalAction__c =\'' +clienteFoco.LAT_PromotionalAction__c+'\'';
	     			queryStrFoco += ' AND LAT_Account__c =\'' +clienteFoco.LAT_Account__c+'\'';
	     		}else if(clienteFoco.LAT_Account__c == null && clienteFoco.LAT_PromotionalAction__c != null){
	     			queryStrFoco += 'WHERE LAT_PromotionalAction__c =\'' +clienteFoco.LAT_PromotionalAction__c+'\'';
	     		}else if(clienteFoco.LAT_Account__c != null && clienteFoco.LAT_PromotionalAction__c == null){
	     			queryStrFoco += 'WHERE LAT_Account__c =\'' +clienteFoco.LAT_Account__c+'\'';
	     		}
	     		List<LAT_AccountInAction__c> listClienteFoco = (List<LAT_AccountInAction__c>)Database.query(queryStrFoco);
	     		Map<Id,LAT_AccountInAction__c> mapIdClienteFoco = new Map<Id,LAT_AccountInAction__c>();
	     		Map<String,String> mapTaskWithFoco= new Map<String,String>();
	     		if(!listClienteFoco.isEmpty()){
	     			Set<Id> focosIds = new Set<Id>();
	     			for(LAT_AccountInAction__c clienteFoco : listClienteFoco) {
	     				focosIds.add(clienteFoco.Id);
	     				//Maps & lists to be used to match attId url
	     				mapIdClienteFoco.put(clienteFoco.Id,clienteFoco);
	     			}
	     			List<Task> allTask = [SELECT id,whatId
	     							      from task
	     							      where LAT_Tipo__c = 'AP-Coletar Evidencia'
	     							      AND WhatId In :focosIds];
	     	        system.debug('allTask: ' + allTask);
	     			if(allTask != null &&  allTAsk.size()>0){
			       	Set<Id> taskIds = new Set<Id>();
			       	for(Task t: allTask){
			       		taskIds.add(t.Id);
				       	mapTaskWithFoco.put(t.Id,t.whatId);
			       	}
			           allAttachmentMaterial = [SELECT id,name, parentID
					            				  from Attachment
					            				  where parentID IN: taskIds];
					   AttachmentItem aItem;
						for(Attachment a : allAttachmentMaterial){
							if(mapTaskWithFoco.get(a.ParentId) != null){
								String focoId = mapTaskWithFoco.get(a.ParentId);
								if(mapIdClienteFoco.get(focoId) != null){
									LAT_AccountInAction__c foco = mapIdClienteFoco.get(focoId);
									aItem = new AttachmentItem();
				    				aItem.clientNameAN8 = foco.LAT_Account__r.Client_code_AN8__c + ' - ' + foco.LAT_Account__r.Name;
				    				aItem.clientURL = URL.getSalesforceBaseUrl().toExternalForm() +'/'+foco.LAT_Account__c;
				    				aItem.dataInicio = foco.LAT_PromotionalAction__r.LAT_StartDate__c;
				    				aItem.quiantidadeDeClientes = foco.LAT_PromotionalAction__r.LAT_Quantidade_de_Clientes__c;
				    				aItem.focoId = foco.Id;
				    				aItem.focoName = foco.LAT_PromotionalAction__r.Name;
				    				aItem.taskId = a.ParentId;
										aItem.datafim = foco.LAT_PromotionalAction__r.LAT_EndDate__c;
										aItem.status = foco.LAT_PromotionalAction__r.LAT_Status__c;
										aItem.attId = a.Id;
										aItem.rowMessage = '<b>Cliente:</b> <a href="'+aItem.clientURL+'" target="_blank">' +aItem.clientNameAN8 + '</a><br/>' + '<b>Ação promocional:</b> '+aItem.focoName + '<br/>' + '<b>Data de Inicio:</b> ' + aItem.dataInicio.format() + '<br/>' + '<b>Data de Fim:</b> ' + aItem.dataFim.format() + '<br/>' + '<b>Status:</b> ' +aItem.status;
				    				listAttachmentItem.add(aItem);
								}
							}
						}

			       }
	     		}
	     	}

 		}catch(Exception e){
 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,e.getMessage()));
 		}

     	return null;
     }

     public class AttachmentItem {


     	//Acao promocional
     	public String focoId {get;set;}
     	public String focoName {get;set;}
     	public Date dataInicio {get;set;}
     	public Date dataFim {get;set;}
     	public String status {get;set;}
     	public Decimal quiantidadeDeClientes {get;set;}

     	//Material Pop
     	public String materialId {get;set;}
     	public String materialName {get;set;}
     	public Date dataEntrega {get;set;}
     	public Decimal quantidadeEntrega {get;set;}

     	//Both
     	public String attId {get;set;}
     	public String clientNameAN8 {get;set;}
     	public String clientURL {get;set;}
     	public String taskId {get;set;}
     	public String rowMessage {get;set;}

     	public AttachmentItem(){

     	}
     }

}