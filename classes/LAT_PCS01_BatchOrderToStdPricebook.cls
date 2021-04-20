/**************************************************************************
*   Company:Valuenet    Developers:Waldemar Mayo		Date:13/03/2014   *
**************************************************************************/

global class LAT_PCS01_BatchOrderToStdPricebook implements Database.Batchable<sObject>,Database.Stateful {
	
	public set<Id> idsOpp {get;set;}
	private String bodyMail;
	
	/*****************************************************************************************************************************************
	* Descripcion: Este batch sirve para cambiar una oportunidad y sus productos desde un Pricebook que NO es standard al Pricebook Standard *
	* 			   hay que tener en cuenta que este proceso modifica el campo "LastModifyDate" tanto en la oportunidad como un sus productos *
	*			   El proceso envia un mail al usuario logeado con el resultado de la operacion												 *
	*****************************************************************************************************************************************/
	global Database.QueryLocator start(Database.BatchableContext BC){
		idsOpp = idsOpp;
		bodyMail = '<b>Resultados</b><br/><br/>';
		String query = 'SELECT Id FROM Opportunity WHERE Id IN: idsOpp';
        return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Opportunity> scope){
		
		Opportunity opp = scope[0];
		
		//Query al Pricebook Standard
		String pbSta = '';//= new Pricebook2();
		if (!Test.isRunningTest()) {
			pbSta = [SELECT Id FROM Pricebook2 WHERE isStandard = true].id;
		} else {
			pbSta = Test.getStandardPricebookId();
		}
		
		//Query de todos los OLIs de las oportunidades con todos sus campos
		String allFields = '';
		for(Schema.SObjectField nameAPIfield : Schema.SObjectType.OpportunityLineItem.fields.getMap().values()){
		    allFields += allFields==''?String.ValueOf(nameAPIfield):', '+String.ValueOf(nameAPIfield);
		}
		List<OpportunityLineItem> listOldOLIs = Database.query('SELECT '+allFields+', Pricebookentry.Product2Id FROM OpportunityLineItem WHERE OpportunityId = \''+opp.Id+'\'');
		
		//Armo un set con los ids de los produtos de la oportundiad
		set<Id> setProdsIds = new set<Id>();
		for(OpportunityLineItem oli: listOldOLIs){
			setProdsIds.add(oli.Pricebookentry.Product2Id);
		}
		
		//Consulto los pricebook entry de todos los productos
		map<Id, PricebookEntry> mapIdProdPBE = new map<Id, PricebookEntry>();
		for(PricebookEntry pbe: [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id =: pbSta/*pbSta.Id*/ AND Product2Id IN: setProdsIds]){
			mapIdProdPBE.put(pbe.Product2Id, pbe);
		}
		
		List<OpportunityLineItem> listOldToInsert = new List<OpportunityLineItem>();
		
		//Si la cantidad de produtos de la oportunidad es diferente a la cantidad de PricebookEntrys del Pricebook standard es diferente se cancela
		if(listOldOLIs.size() == mapIdProdPBE.size()){
			
			//Se crean nuevos OLIs clones de los existentes pero con el Pricebook Standard
			for(OpportunityLineItem oli: listOldOLIs){
				OpportunityLineItem newOli = oli.clone(false);
				newOli.PricebookEntryId = mapIdProdPBE.get(oli.Pricebookentry.Product2Id).Id;
				newOli.TotalPrice = null;
				listOldToInsert.add(newOli);
			}
			
			Savepoint sp = Database.setSavepoint();
			try{
				//Se eliminan los OLIs existentes
				delete listOldOLIs;
				
				//Se actualiza el Pricebook de la oportundiad
				opp.Pricebook2Id = pbSta;//pbSta.Id;
				update opp;
				
				//Se insertan los nuevos OLIs con el Pricebook Standard
				insert listOldToInsert;
				bodyMail += '<b>'+opp.Id+'</b> - Exito<br/>';
			}catch(Exception e){
				Database.rollback(sp);
				bodyMail += '<b>'+opp.Id+'</b> - Error: '+e.getMessage()+'<br/>';
			}
		}else{
			bodyMail += '<b>'+opp.Id+'</b> - Error: No se encontraron algunos productos en el Pricebook Standard<br/>';
		}
	}
	
	global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
        mail.setSubject('"PR LAT - Proceso de cambio de Pricebook"');
        mail.setHTMLBody(bodyMail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}