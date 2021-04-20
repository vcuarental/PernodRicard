/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/

global class LAT_MX2_BatchAccountProductPayment implements Database.Batchable<sObject>,Database.Stateful {
	
    public String errors;
    public Integer countCorrect;
    public Integer countErrors;
    public List<Account> accounts {get;set;}
    public List<UDC__c> udcs {get;set;}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		errors = '';
        countCorrect = 0;
        countErrors = 0;
        accounts = accounts;
        udcs = udcs;
        
        String query = 'SELECT Id, LAT_ExternalId__c FROM LAT_Product__c WHERE LAT_ExternalId__c LIKE \'12-%\' AND LAT_IsActive__c = true AND LAT_Sku__c LIKE \'MX%\' AND LAT_IsRefactorProduct__c = \'Y\'';
        return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<LAT_Product__c> scope) {
		        
        List<LAT_Account_product_payment__c> listAPPToInsert = new List<LAT_Account_product_payment__c>();
        
        for(LAT_Product__c prod: scope){
            
            for(Account acc: accounts){
                
                for(udc__c udc: udcs){
                    
                    listAPPToInsert.add(
                        new LAT_Account_product_payment__c(
                            
                            LAT_Product__c = prod.Id,
                            ProductExternalId__c = prod.LAT_ExternalId__c,
                            
                            Account__c = acc.Id,
                            CustomerCountryAN8Code__c = acc.Client_country_AN8__c,
                            
                            Payment__c = udc.id,
                            PaymentCondition__c = udc.CodDefUsuario__c,
                            PaymentConditionDescription__c = udc.Name,
                            PaymentConditionExternalId__c = udc.Internal_Id__c
                            
                            //ExternalUniqueKey__c se actualiza solo con el trigger
                        )
                    );
                }
            }
        }
        
        Database.SaveResult[] apps = Database.insert(listAPPToInsert, false);
        for(Database.SaveResult app: apps){
        	if(app.isSuccess()){
        		countCorrect++;
        	}else{
        		errors += app.getErrors()+'<br/><br/>';
        		countErrors ++;
        	}
        }	
	}
	
	global void finish(Database.BatchableContext BC) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> listEmails = new List<String>();
        //listEmails.add('diego.salido@pernod-ricard.com');
        listEmails.add(UserInfo.getUserEmail());
        mail.setToAddresses(listEmails);
        
        mail.setSubject('"PR MX - Proceso de carga de Account Product Payment"');
        
        String email = '';
        email += 'Ambiente: ' + URL.getSalesforceBaseUrl().getHost();
        email += '<br/><br/>';
        email += 'Cantidad insertados correctamente: '+countCorrect;
        email += '<br/><br/>';
        email += 'Cantidad con error: '+countErrors;
        email += '<br/><br/>';
        email += 'Errores:<br/>';
        email += errors;
        
        mail.setHTMLBody(email);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
	}
	
}