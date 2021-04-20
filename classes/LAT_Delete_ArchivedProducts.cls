global class LAT_Delete_ArchivedProducts implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	global integer totalProductos;
	global integer totalBorrados;
	
	global LAT_Delete_ArchivedProducts() {
		totalProductos = 0;
		totalBorrados = 0;
		query = 'SELECT id, (SELECT id FROM Checklist_de_Visitas__r limit 1),' +
		'(SELECT id FROM Checklist_de_Visitas1__r limit 1),' +
		'(SELECT id FROM Checklist_de_Visitas2__r limit 1),' +
		'(SELECT id FROM Checklist_de_Visitas3__r limit 1),' +
		'(SELECT id FROM Checklist_de_Visitas4__r limit 1),' +
		'(SELECT id FROM Accounts_products_payments__r limit 1),' +
		'(SELECT id FROM Par_metro_Produto_Concorr_ncia__r limit 1),' +
		'(SELECT id FROM Investimento_Bonifica_o_e_Pagamento__r limit 1),' +
		'(SELECT id FROM PricebookEntries limit 1),' +
		'(SELECT Id FROM Produtos_Concorr_ncia__r limit 1)' +
		' FROM Product2 where LAT_IsRefactorProduct__c != \'Y\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<Product2> toDelete = new List<Product2>();
   		

		for(sObject obj : scope){
			totalProductos ++;

			Product2 pro = (Product2)obj;
			if(pro.Checklist_de_Visitas__r.isEmpty() &&
			   	pro.Checklist_de_Visitas1__r.isEmpty() &&
				pro.Checklist_de_Visitas2__r.isEmpty() &&
				pro.Checklist_de_Visitas3__r.isEmpty() &&
				pro.Checklist_de_Visitas4__r.isEmpty() &&
				pro.Accounts_products_payments__r.isEmpty() &&
				pro.Par_metro_Produto_Concorr_ncia__r.isEmpty() &&
				pro.Investimento_Bonifica_o_e_Pagamento__r.isEmpty() &&
				pro.Produtos_Concorr_ncia__r.isEmpty()) {

					if ([Select id from OpportunityLineItem where PricebookEntry.Product2Id =: pro.id limit 1].isEmpty()){
						totalBorrados ++;
						toDelete.add(pro);
					}
			}
		}
		delete toDelete;
	}
	
	global void finish(Database.BatchableContext BC) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new String[] {'diego.salido@pernod-ricard.com','bruno@zimmic.com'});
		
		mail.setSubject('Productos procesados');

		mail.setPlainTextBody('Productos procesados: ' + totalProductos +  '\nProductos eliminados: ' +  totalBorrados);
		mail.setHtmlBody('Productos procesados: ' + totalProductos + '<br />' + 'Productos eliminados: ' +  totalBorrados);

		// Send the email you have created.
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	}
	
}