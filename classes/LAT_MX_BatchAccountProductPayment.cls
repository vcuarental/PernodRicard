global class LAT_MX_BatchAccountProductPayment implements Database.Batchable<sObject>,Database.Stateful {
    
    public String errors;
    public Integer countCorrect;
    public Integer countErrors;
    public List<Account> accounts {get;set;}
    public List<UDC__c> udcs {get;set;}
    
    //IMPORTANTE: "cantidad Account" x "cantidad UDCs" no debe superar los 10000 registros 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        errors = '';
        countCorrect = 0;
        countErrors = 0;
        accounts = accounts;
        udcs = udcs;
        
        String query = 'SELECT Id, Internal_id__c FROM Product2 WHERE internal_id__c LIKE \'12-%\' AND isActive = true AND sku__c LIKE \'MX%\' AND lat_isrefactorproduct__c = \'Y\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Product2> scope){
        
        List<LAT_Account_product_payment__c> listAPPToInsert = new List<LAT_Account_product_payment__c>();
        
        for(Product2 prod: scope){
            
            for(Account acc: accounts){
                
                for(udc__c udc: udcs){
                    
                    listAPPToInsert.add(
                        new LAT_Account_product_payment__c(
                            
                            Product__c = prod.Id,
                            ProductExternalId__c = prod.Internal_id__c,
                            
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
   
    global void finish(Database.BatchableContext BC){
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