global class LAT_AR_TransferAccounts_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    
    String query;
    Id newOwner;
    Set<Id> accountIds = new Set<Id>();
    Set<Id> accountsToIntegrate;
    String errors = '';
    Boolean sendToJDE;
    private static final String BREAK_LINE    = '<br/>';
    private static final String ACTION_INSERT = 'A';
    private static final String ACTION_UPDATE = 'C';
    private static final Integer DDD_POS      = 0;
    private static final Integer PHONE_POS    = 1;


    global LAT_AR_TransferAccounts_Batch (Set<Id> accountIds, Id newOwnerId) {
        sendToJDE = true;
        this.newOwner = newOwnerId;
        this.accountIds = accountIds;
        this.accountsToIntegrate = new Set<Id>();

        system.debug('>>>>>' + accountIds);
        system.debug('>>>>>' + newOwner);
        
        query = 'Select id, OwnerId, status__c, LAT_Account__c, Name, CurrencyISOCode, Owner.C_digo_JDE__c, Client_country_AN8__c From Account Where id in :accountIds';
        system.debug('>>>>> query' + query);

    }

    global LAT_AR_TransferAccounts_Batch (Set<Id> accountIds, Id newOwnerId, Boolean pSendToJDE) {
        sendToJDE = pSendToJDE;
        System.debug('%%% sendToJDE:' + sendToJDE);
        this.newOwner = newOwnerId;
        this.accountIds = accountIds;
        this.accountsToIntegrate = new Set<Id>();

        system.debug('>>>>>' + accountIds);
        system.debug('>>>>>' + newOwner);
        
        query = 'Select id, OwnerId, status__c, LAT_Account__c, Name, CurrencyISOCode, Owner.C_digo_JDE__c, Client_country_AN8__c From Account Where id in :accountIds';
        system.debug('>>>>> query' + query);

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    
        User nuevoOwner = [SELECT Id, C_digo_JDE__c FROM User WHERE Id = :newOwner ];
        List <Account> accounts = (List<Account>)scope;
        List<Account> actualAccs = new List<Account>();
        Set <Id> accountsToSearch = new Set<Id>();

        for (Account myAccount : accounts) {
            
            Date today = Date.today();
            String strConvertedDate = today.format();

            myAccount.ownerId = newOwner;
            if(myAccount.Client_country_AN8__c != null && sendToJDE == true) {
                if(myAccount.Client_country_AN8__c.contains('6-')) {
                    this.accountsToIntegrate.add(myAccount.Id);
                }
            }
            
                      
            actualAccs.add(myAccount);

        }

        try{
            Set<Id> latAccountIds = new Set<Id>();           
            for(Account accu :actualAccs){
                latAccountIds.add(accu.LAT_Account__c);
            }
            /*
            Map<Id, LAT_Account__c> latAccountToUpdate = new Map<Id, LAT_Account__c>([Select id, lat_isadmin__c, LAT_JDEZone__c, LAT_JDEZoneUDC__c, LAT_JDEZoneUDC__r.CodDefUsuario__c  From LAT_Account__c where id in :latAccountIds]);
            

            for(LAT_Account__c accu :latAccountToUpdate.values()){
                if (accu.LAT_JDEZoneUDC__c != null) {
                    accu.LAT_JDEZone__c = accu.LAT_JDEZoneUDC__r.CodDefUsuario__c;
                } else {
                    accu.LAT_JDEZone__c = nuevoOwner.C_digo_JDE__c;
                }
            }

            */
            update actualAccs;
            //update latAccountToUpdate.values();

           
            if(Test.isRunningTest()){
                errors = 'Test error';
            }

            }catch (Exception e){
                System.debug('%%%%%% Error en LAT_AR_TransferAccounts_Batch : ' + e);
                errors += e.getMessage();

            }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
        System.debug('%%%%% accountsToIntegrate : '+accountsToIntegrate);
        if(accountsToIntegrate.size() > 0){
            //try {
                List<Account> toUpdate = new List<Account>();
                for(Account customer :getAccount(accountsToIntegrate)){
                    toUpdate.add(CustomerInterfaceJDESync(customer));
                }
                if(toUpdate.size() > 0) {
                    update toUpdate;
                }
            /*} catch (Exception e) {
                System.debug('%%%%% ERROR en Finish de LAT_AR_TransferAccounts_Batch : '+e);
            }*/
        }
        
        
        if(errors != null && errors != ''){

            String[] emailAddresses = LAT_GeneralConfigDao.getValueAsStringArray('ACCOUNT_NOTIFY_ERROR_MAIL', ';');
            String baseUrl = System.URL.getSalesforceBaseUrl().getHost();

            String emailBody    = '<html><body><b>Ha ocurrido un error al transferir los clientes:</b> <br> <br> A continuación se brinda el registro de error: <br> <br>';
            
            emailBody += errors;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if(Test.isRunningTest()){
                emailAddresses = new String[]{'test@gmail.com'};
                mail.setToAddresses(emailAddresses);
            }else{
                mail.setToAddresses(emailAddresses);
            }
            
            mail.setHtmlBody(emailBody);
            mail.setSenderDisplayName('noreply@pernod-ricard.com');
            mail.setSubject('Error al transferir los clientes.');
            
            List<Messaging.SingleEmailMessage> list_emailsToSent = new List<Messaging.SingleEmailMessage>();
            list_emailsToSent.add(mail);    
            try{
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(list_emailsToSent);
                }
            } catch (Exception e) {
                System.debug('%%%%% ERROR en Finish de LAT_AR_TransferAccounts_Batch2 : '+e);
            } 
            

        }
    }

    public static Account CustomerInterfaceJDESync(Account customer) {
        system.debug('sentcust+++ : ' + customer);
        // Log to the debug object
        
        // do not continue if no id was received
        if (customer == null) {
          system.debug('entrocustomernull');
          return customer;
        }
        
        final String country = LAT_WS_CustomerHandlerInterface.getCountryInfo(customer.RecordTypeId);
        system.debug('ObtainedCountry+++ : ' + country);
    
        //try {
        LAT_WS_CustomerHandlerTypes.CustomerHandlerArgumentsType customerArguments = LAT_WS_CustomerHandlerInterface.getCustomerArguments(customer, country);
        LAT_WS_CustomerHandler.port request = new LAT_WS_CustomerHandler.port(); // Timeout and auth handled directly on LAT_WS_CustomerHandler
        LAT_WS_CustomerHandlerTypes.ClientInfoType clientInfo = LAT_WS_CustomerHandlerInterface.getConnectionParameter(country);
        final String reqEndpoint = getWSEndpoint(clientInfo.country);

          // Make request
        LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType response = request.operation(clientInfo, customerArguments, reqEndpoint, true, customer.Id);
          
        system.debug('Parameterssss : ' + customerArguments);
      
        customer = LAT_WS_CustomerHandlerInterface.parseResponse(response, customer);

        return customer;  
    }

    public static String getWSEndpoint(String country) {
        String reqEndpoint = [SELECT EndPoint_CustomerHandler__c
                            FROM CS001_JDEInterfaceCredentials__c
                            WHERE Country__c =: country].EndPoint_CustomerHandler__c;
        return reqEndpoint;
    }

    public static List<Account> getAccount(Set<Id> idsSalesforce) {
        List<Account> customerList = [SELECT
                                      Accept_applications_Incompleted__c,
                                      Accept_Backorder__c, 
                                      Accept_line_incompleted__c, 
                                      Affiliate__c, 
                                      Agency__c, 
                                      Bank__r.Name, 
                                      Bank_number__c, 
                                      Barcode_EDI__c, 
                                      Billing_Address_Code__c, 
                                      Billing_Priority__c, 
                                      Business_Unit__r.CodDefUsuario__c, 
                                      Carriers_Numbers__c, 
                                      Channel__c, 
                                      Checking_account__c, 
                                      Client_code_AN8__c, 
                                      CNPJ__c, 
                                      Corporate_Name__c,
                                      Credit_line__c, 
                                      Current_account__c, 
                                      Customer_Flag__r.CodDefUsuario__c, 
                                      Customer_Geographic_Region__r.CodDefUsuario__c, 
                                      Customer_GL__r.CodDefUsuario__c, 
                                      Customer_Organization__r.CodDefUsuario__c, 
                                      Discount_Group__c, 
                                      Email_NFE__c, 
                                      Fax, 
                                      Freight_Type__c, 
                                      LAT_BR_BusinessSize__c,
                                      LAT_BR_FiscalBenefit__c,
                                      LAT_BR_PriorityLevel__c, 
                                      Municipal_Registration__c, 
                                      Nielsen_Area__r.CodDefUsuario__c, 
                                      OwnerId, 
                                      ParentId,
                                      Parent.Client_code_AN8__c, 
                                      Payment_Condition__r.CodDefUsuario__c, 
                                      Payment_instrument__r.CodDefUsuario__c,
                                      Phone, 
                                      Rating_segmentation_targert_market__c, 
                                      Rating, 
                                      Receiving_Freight__c, 
                                      RecordTypeId, 
                                      Regional__r.CodDefUsuario__c, 
                                      Revenue_Address__c, 
                                      Revenue_City__r.Name,
                                      Revenue_City_Code__c, 
                                      Revenue_Complement__c, 
                                      Revenue_Country__c, 
                                      Revenue_Neighbourhood__c, 
                                      Revenue_Number__c, 
                                      Revenue_Postal_Code__c,  
                                      Revenue_UF__c,
                                      Shipping_Address_Code__c, 
                                      State_registration__c,     
                                      Sub_Channel_Rating__r.CodDefUsuario__c, 
                                      Type,
                                      WebSite,
                                      Yes_No__c,                                  
                                      CurrencyISOCode,
                                      Owner.C_digo_JDE__c,
                                      LAT_ACCOUNT__r.LAT_MicroRegionalUDC__c,
                                    // AR and UY Fields
                                      AddressLine1_AR__c, 
                                      CatCode02_AR__r.CodDefUsuario__c, 
                                      CollectionAgent_AR__r.CodDefUsuario__c,
                                      CustomerPriceGroup_AR__r.CodDefUsuario__c,
                                      CustomerPoRequired_AR__c,
                                      Id,
                                      Name,
                                      Regional_AR__r.CodDefUsuario__c,
                                      Status__c,
                                      LAT_Account__r.LAT_JDEZone__c,
                                    // MX Fields
                                      AccountNumber,
                                      Business_Unit_AR__r.CodDefUsuario__c,
                                      Client_country_AN8__c, 
                                      Is_interface_Process_AR__c,
                                      LAT_MX_ABCCode__r.CodDefUsuario__c,
                                      LAT_MX_AmountReceiptCopies__c, 
                                      LAT_MX_BatchProcess__r.CodDefUsuario__c,
                                      LAT_MX_BreakDownIEPS__c, 
                                      LAT_MX_CableCodeS__c, 
                                      LAT_MX_Chain__r.CodDefUsuario__c, 
                                      LAT_MX_City__c, 
                                      LAT_MX_County__c, 
                                      LAT_MX_CreditVersionLevel__c, 
                                      LAT_MX_CRMClientCode__c, 
                                      LAT_MX_FiscalEntityType__c, 
                                      LAT_MX_FiscalRate__r.CodDefUsuario__c, 
                                      LAT_MX_Group__r.CodDefUsuario__c, 
                                      LAT_MX_Language__c, 
                                      LAT_MX_Market__c, 
                                      LAT_MX_Neighbourhood__c, 
                                      LAT_MX_PostalCode__r.Name, 
                                      LAT_MX_RelatedAddressAN8__c, 
                                      LAT_MX_RouteCode__r.CodDefUsuario__c, 
                                      LAT_MX_State__c, 
                                      LAT_MX_ZoneNumber__r.CodDefUsuario__c, 
                                      Owner.Email, 
                                      Owner.Name,
                                      Return_JDE_Integration__c
                                      FROM Account
                                      WHERE Id IN: idsSalesforce];
        return (customerList.isEmpty()) ? null : customerList;
    }

}