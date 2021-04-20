global class LAT2_Delete_ArchivedProducts implements Database.Batchable<sObject> {
	
	String query;
	global integer totalProductos;
	global integer totalBorrados;
	
	global LAT2_Delete_ArchivedProducts() {
		totalProductos = 0;
		totalBorrados = 0;
		query = 'SELECT id, (SELECT id FROM LAT_Checklist_de_Visitas__r limit 1),' +
		'(SELECT id FROM LAT_Checklist_de_Visitas1__r limit 1),' +
		'(SELECT id FROM LAT_Checklist_de_Visitas2__r limit 1),' +
		'(SELECT id FROM LAT_Checklist_de_Visitas3__r limit 1),' +
		'(SELECT id FROM LAT_Checklist_de_Visitas4__r limit 1),' +
		'(SELECT id FROM LAT_Accounts_products_payments__r limit 1),' +
		'(SELECT id FROM LAT_Par_metro_Produto_Concorr_ncia__r limit 1),' +
		'(SELECT id FROM LAT_Investimento_Bonifica_o_e_Pagamento__r limit 1),' +
		'(SELECT id FROM OpportunityLineItems__r limit 1),' +
		'(SELECT Id FROM LAT_Produtos_Concorr_ncia__r limit 1)' +
		' FROM LAT_Product__c where LAT_IsRefactorProduct__c != \'Y\'';	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<LAT_Product__c> toDelete = new List<LAT_Product__c>();
   		

		for(sObject obj : scope){
			totalProductos ++;

			LAT_Product__c pro = (LAT_Product__c)obj;
			if(pro.LAT_Checklist_de_Visitas__r.isEmpty() &&
			   	pro.LAT_Checklist_de_Visitas1__r.isEmpty() &&
				pro.LAT_Checklist_de_Visitas2__r.isEmpty() &&
				pro.LAT_Checklist_de_Visitas3__r.isEmpty() &&
				pro.LAT_Checklist_de_Visitas4__r.isEmpty() &&
				pro.LAT_Accounts_products_payments__r.isEmpty() &&
				pro.LAT_Par_metro_Produto_Concorr_ncia__r.isEmpty() &&
				pro.LAT_Investimento_Bonifica_o_e_Pagamento__r.isEmpty() &&
				pro.LAT_Produtos_Concorr_ncia__r.isEmpty()&&
				pro.OpportunityLineItems__r.isEmpty()) {
					totalBorrados ++;
					toDelete.add(pro);			
			}
		}
		delete toDelete;	
	}
	
	global void finish(Database.BatchableContext BC) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new String[] {'diego.salido@pernod-ricard.com','bruno@zimmic.com','javier@zimmic.com'});
		
		mail.setSubject('Productos procesados');

		mail.setPlainTextBody('Productos procesados: ' + totalProductos +  '\nProductos eliminados: ' +  totalBorrados);
		mail.setHtmlBody('Productos procesados: ' + totalProductos + '<br />' + 'Productos eliminados: ' +  totalBorrados);

		// Send the email you have created.
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});		
	}
	
}