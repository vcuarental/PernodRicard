/*******************************************************************************
    2: *                           Company: Zimmic
    3  *-------------------------------------------------------------------------------
    4  *   Clase Schedulable que envia las notificaciones de las cotas
*/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
global class LAT_BR_Cotas_Notifications implements Schedulable {

	global List<String> toAddresses;


	global void execute(SchedulableContext sc) {
		List<String> userOrGroupIds = new List<String>();
		toAddresses = new List<String>();

		for(GroupMember u : [Select UserOrGroupid From GroupMember Where Group.name = 'LAT_BR_COTA_NOTIFICATIONS']){
			userOrGroupIds.add(u.UserOrGroupid);
		}
		for(User u : [Select Id, email From User Where Id In :userOrGroupIds]){
			toAddresses.add(u.email);
		}

		startCotasNotification();
		closeCotasNotification();

	}

	global void startCotasNotification(){
        if(!Utils.wasMigrationDone('1')) { 
			List<LAT_DetalheCotaMarket__c> detalhes = [SELECT id,cotaMarket__c,cotaMarket__r.name,cotaMarket__r.SKU__r.name,name,cliente__r.Name,bandeira__r.Name,consumo__c,cota__c,endDate__c,startDate__c,executivo__r.Name,regional__r.Name,segmento__r.Name,sub_canal__c FROM LAT_DetalheCotaMarket__c where startDate__c = YESTERDAY];
			if(!detalhes.isEmpty()){
				sendEmail('Nova Cota Ativada', detalhes);
			}
		} 
		//MIGRATED 17/11/2016
		else {
			List<LAT_DetalheCotaMarket__c> detalhes = [SELECT id,cotaMarket__c,cotaMarket__r.name,cotaMarket__r.LAT_Product__r.name,name,cliente__r.Name,bandeira__r.Name,consumo__c,cota__c,endDate__c,startDate__c,executivo__r.Name,regional__r.Name,segmento__r.Name,sub_canal__c FROM LAT_DetalheCotaMarket__c where startDate__c = YESTERDAY];
			if(!detalhes.isEmpty()){
				sendEmail('Nova Cota Ativada', detalhes);
			}			
		}
	}

	global void closeCotasNotification(){
        if(!Utils.wasMigrationDone('1')) { 		
			List<LAT_DetalheCotaMarket__c> detalhes = [SELECT id,cotaMarket__c,cotaMarket__r.name,cotaMarket__r.SKU__r.name,name,cliente__r.Name,bandeira__r.Name,consumo__c,cota__c,endDate__c,startDate__c,executivo__r.Name,regional__r.Name,segmento__r.Name,sub_canal__c FROM LAT_DetalheCotaMarket__c where endDate__c = YESTERDAY OR (cantidadDisponible__c <= 0 AND dateConsumida__c = YESTERDAY)];
			if(!detalhes.isEmpty()){
				sendEmail('Cota Encerrada', detalhes);
			}
		}
		//MIGRATED 17/11/2016
		else {
			List<LAT_DetalheCotaMarket__c> detalhes = [SELECT id,cotaMarket__c,cotaMarket__r.name,cotaMarket__r.LAT_Product__r.name,name,cliente__r.Name,bandeira__r.Name,consumo__c,cota__c,endDate__c,startDate__c,executivo__r.Name,regional__r.Name,segmento__r.Name,sub_canal__c FROM LAT_DetalheCotaMarket__c where endDate__c = YESTERDAY OR (cantidadDisponible__c <= 0 AND dateConsumida__c = YESTERDAY)];
			if(!detalhes.isEmpty()){
				sendEmail('Cota Encerrada', detalhes);
			}			
		}
	}

	global void sendEmail(String subject, List<LAT_DetalheCotaMarket__c> detalhes){
        if(!Utils.wasMigrationDone('1')) { 	

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(toAddresses);
			mail.setSubject(subject);
			mail.setPlainTextBody('');
			mail.setHtmlBody('');
			mail.setSenderDisplayName('Salesforce');

			for(LAT_DetalheCotaMarket__c detalhe : detalhes){
				mail.setPlainTextBody(mail.getPlainTextBody() +
				 'Cota: ' + detalhe.cotaMarket__r.name + '\n' + 
				 'Producto: ' + detalhe.cotaMarket__r.SKU__r.name + '\n' + 
				 'Name: ' + detalhe.name + '\n' + 
				 'Segmento: ' + (detalhe.segmento__r.Name == null ? '' : detalhe.segmento__r.Name) + '\n' + 
				 'Sub-Canal: ' + (detalhe.sub_canal__c == null ? '' : detalhe.sub_canal__c) +'\n' + 
				 'Regional: ' + (detalhe.regional__r.Name == null ? '' : detalhe.regional__r.Name) + '\n' + 
				 'Bandeira: ' + (detalhe.bandeira__r.Name == null ? '' : detalhe.bandeira__r.Name) + '\n' + 
				 'Executivo: ' + (detalhe.executivo__r.Name == null ? '' : detalhe.executivo__r.Name) + '\n' + 
				 'Cliente: ' + (detalhe.cliente__r.Name == null ? '' : detalhe.cliente__r.Name) + '\n' + 
				 'Cota: ' + detalhe.cota__c + '\n' + 
				 'Consumo: ' + detalhe.consumo__c + '\n' + 
				 'Data Inicio: ' + String.valueOf(detalhe.startDate__c) + '\n' + 
				 'Data Fim: ' + String.valueOf(detalhe.endDate__c) + '\n\n' + 
				 '-----------------------------------\n');

				 String idString = detalhe.id + ''.toUpperCase();
				 String idCotaString = detalhe.cotaMarket__c + ''.toUpperCase();

				 mail.setHTMLBody(mail.getHTMLBody() +
				  'Cota: <a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + 
	                       '/' + idCotaString +'">' + detalhe.cotaMarket__r.name + '</a><br />' + 
	              'Producto: ' + (detalhe.cotaMarket__r.SKU__r.name == null ? '' : detalhe.cotaMarket__r.SKU__r.name) + '<br />' + 
		
				 'Name: <a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + 
	                       '/' + idString +'">' + detalhe.name + '</a><br />' + 
				 'Segmento: ' + (detalhe.segmento__r.Name == null ? '' : detalhe.segmento__r.Name) + '<br />' + 
				 'Sub-Canal: ' + (detalhe.sub_canal__c == null ? '' : detalhe.sub_canal__c) +'<br />' + 
				 'Regional: ' + (detalhe.regional__r.Name == null ? '' : detalhe.regional__r.Name) + '<br />' + 
				 'Bandeira: ' + (detalhe.bandeira__r.Name == null ? '' : detalhe.bandeira__r.Name) + '<br />' + 
				 'Executivo: ' + (detalhe.executivo__r.Name == null ? '' : detalhe.executivo__r.Name) + '<br />' + 
				 'Cliente: ' + (detalhe.cliente__r.Name == null ? '' : detalhe.cliente__r.Name) + '<br />' + 
				 'Cota: ' + detalhe.cota__c + '<br />' + 
				 'Consumo: ' + detalhe.consumo__c + '<br />' + 
				 'Data Inicio: ' + String.valueOf(detalhe.startDate__c) + '<br />' + 
				 'Data Fim: ' + String.valueOf(detalhe.endDate__c) + '<br /><br />' + 
				 '-----------------------------------<br />');
			}
			// Send the email you have created.
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		} 
		//MIGRATED 17/11/2016
		else {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(toAddresses);
			mail.setSubject(subject);
			mail.setPlainTextBody('');
			mail.setHtmlBody('');
			mail.setSenderDisplayName('Salesforce');

			for(LAT_DetalheCotaMarket__c detalhe : detalhes){
				mail.setPlainTextBody(mail.getPlainTextBody() +
				 'Cota: ' + detalhe.cotaMarket__r.name + '\n' + 
				 'Producto: ' + detalhe.cotaMarket__r.LAT_Product__r.name + '\n' + 
				 'Name: ' + detalhe.name + '\n' + 
				 'Segmento: ' + (detalhe.segmento__r.Name == null ? '' : detalhe.segmento__r.Name) + '\n' + 
				 'Sub-Canal: ' + (detalhe.sub_canal__c == null ? '' : detalhe.sub_canal__c) +'\n' + 
				 'Regional: ' + (detalhe.regional__r.Name == null ? '' : detalhe.regional__r.Name) + '\n' + 
				 'Bandeira: ' + (detalhe.bandeira__r.Name == null ? '' : detalhe.bandeira__r.Name) + '\n' + 
				 'Executivo: ' + (detalhe.executivo__r.Name == null ? '' : detalhe.executivo__r.Name) + '\n' + 
				 'Cliente: ' + (detalhe.cliente__r.Name == null ? '' : detalhe.cliente__r.Name) + '\n' + 
				 'Cota: ' + detalhe.cota__c + '\n' + 
				 'Consumo: ' + detalhe.consumo__c + '\n' + 
				 'Data Inicio: ' + String.valueOf(detalhe.startDate__c) + '\n' + 
				 'Data Fim: ' + String.valueOf(detalhe.endDate__c) + '\n\n' + 
				 '-----------------------------------\n');

				 String idString = detalhe.id + ''.toUpperCase();
				 String idCotaString = detalhe.cotaMarket__c + ''.toUpperCase();

				 mail.setHTMLBody(mail.getHTMLBody() +
				  'Cota: <a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + 
	                       '/' + idCotaString +'">' + detalhe.cotaMarket__r.name + '</a><br />' + 
	              'Producto: ' + (detalhe.cotaMarket__r.LAT_Product__r.name == null ? '' : detalhe.cotaMarket__r.LAT_Product__r.name) + '<br />' + 
		
				 'Name: <a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + 
	                       '/' + idString +'">' + detalhe.name + '</a><br />' + 
				 'Segmento: ' + (detalhe.segmento__r.Name == null ? '' : detalhe.segmento__r.Name) + '<br />' + 
				 'Sub-Canal: ' + (detalhe.sub_canal__c == null ? '' : detalhe.sub_canal__c) +'<br />' + 
				 'Regional: ' + (detalhe.regional__r.Name == null ? '' : detalhe.regional__r.Name) + '<br />' + 
				 'Bandeira: ' + (detalhe.bandeira__r.Name == null ? '' : detalhe.bandeira__r.Name) + '<br />' + 
				 'Executivo: ' + (detalhe.executivo__r.Name == null ? '' : detalhe.executivo__r.Name) + '<br />' + 
				 'Cliente: ' + (detalhe.cliente__r.Name == null ? '' : detalhe.cliente__r.Name) + '<br />' + 
				 'Cota: ' + detalhe.cota__c + '<br />' + 
				 'Consumo: ' + detalhe.consumo__c + '<br />' + 
				 'Data Inicio: ' + String.valueOf(detalhe.startDate__c) + '<br />' + 
				 'Data Fim: ' + String.valueOf(detalhe.endDate__c) + '<br /><br />' + 
				 '-----------------------------------<br />');
			}
			// Send the email you have created.
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		}
	}
}