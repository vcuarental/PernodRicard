global class LAT_BR_TransferAccounts_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    public class TransferAccountBatchException extends Exception {}

    private static final String BREAK_LINE    = '<br/>';
    private static final String ACTION_INSERT = 'A';
    private static final String ACTION_UPDATE = 'C';
    private static final Integer DDD_POS      = 0;
    private static final Integer PHONE_POS    = 1;
    private static final String COUNTRY_ACCOUNT_PREFIX = '1-';

    public Set<Id> accountsToIntegrate = null;
    public Id newOwner = null;
    public Boolean sendToJDE = null;
    private User objNewOwner = null;

    @TestVisible
    String errors = '';
    Set<Id> accountIds = new Set<Id>();

    global LAT_BR_TransferAccounts_Batch (Set<Id> setAccountIds, Id strNewOwnerId) {
        this(setAccountIds, strNewOwnerId, true);
    }

    global LAT_BR_TransferAccounts_Batch (Set<Id> setAccountIds, Id strNewOwnerId, Boolean boolSendToJDE) {
        System.debug('LAT_BR_TransferAccounts_Batch ->');
        if(String.isNotBlank(strNewOwnerId)) {
            this.sendToJDE = boolSendToJDE; 
            this.newOwner = strNewOwnerId;
            this.accountIds = setAccountIds;
            this.accountsToIntegrate = new Set<Id>();
        } else {
            System.debug('LAT_BR_TransferAccounts_Batch[El nuevo owner no puede ser nulo]');
        }
        System.debug('LAT_BR_TransferAccounts_Batch[] <-');
    }
    
    global Database.QueryLocator start(Database.BatchableContext objBatchableContext) {
        Database.QueryLocator objQueryLocator = null;
        String strSOQL = null;

        System.debug('LAT_BR_TransferAccounts_Batch.start[] ->');

        strSOQL = 'SELECT Id, OwnerId, status__c, LAT_Account__c, Name, CurrencyISOCode, Owner.C_digo_JDE__c, Client_country_AN8__c ';
        strSOQL += 'FROM Account '; 
        strSOQL += 'WHERE Id in :accountIds ';

        System.debug('LAT_BR_TransferAccounts_Batch.start[strSOQL : ' + strSOQL + ']');

        objQueryLocator = Database.getQueryLocator(strSOQL);
 
        System.debug('LAT_BR_TransferAccounts_Batch.start[' + objQueryLocator + '] <-');

        return objQueryLocator;
    }

    global void execute(Database.BatchableContext objBatchableContext, List<Account> lstAccounts) {    
        List<Account> lstActualAccounts = null;
        Set<Id> setAccountsToSearch = null;
        Date datToday = null;
        String strConvertedDate = null;

        System.debug('LAT_BR_TransferAccounts_Batch.execute[objBatchableContext : ' + objBatchableContext + ' - lstAccounts : ' + lstAccounts + '] ->');

        lstActualAccounts = new List<Account>();
        setAccountsToSearch = new Set<Id>();
        datToday = Date.today();
        strConvertedDate = datToday.format();

        for (Account objAccount : lstAccounts) {            
            objAccount.OwnerId = this.newOwner;
            if(String.isNotBlank(objAccount.Client_country_AN8__c) && this.sendToJDE == true) {
                if(objAccount.Client_country_AN8__c.startsWith(COUNTRY_ACCOUNT_PREFIX)) {
                    this.accountsToIntegrate.add(objAccount.Id);
                }
            }
                                  
            lstActualAccounts.add(objAccount);
        }
 
        try {            
            System.debug('LAT_BR_TransferAccounts_Batch.execute[lstActualAccounts: ' + lstActualAccounts + ']');
            update lstActualAccounts;          
        } catch (Exception Ex) {
            System.debug('LAT_BR_TransferAccounts_Batch.execute[Ex : ' + Ex.getMessage() + ']');
            errors += Ex.getMessage();
        }        

        System.debug('LAT_BR_TransferAccounts_Batch.execute[] <-');
    }
    
    global void finish(Database.BatchableContext objBatchableContext) {
        System.debug('LAT_BR_TransferAccounts_Batch.finish[' + objBatchableContext + '] ->');
        
        System.debug('%%%%% accountsToIntegrate : '+accountsToIntegrate);
        if(accountsToIntegrate != NULL && !accountsToIntegrate.IsEmpty()){
            integrateAccounts(accountsToIntegrate);
        }
                
        if(String.isNotBlank(errors)){
            processErrors(errors);                       
        }

        System.debug('LAT_BR_TransferAccounts_Batch.finish[] <-');
    }

    private void integrateAccounts(Set<Id> setAccountsId) {
        List<Account> lstAccounts = null;
        List<Account> lstAccountsToIntegrate = null;
        Account objAccountToIntegrate = null;

        System.debug('LAT_BR_TransferAccounts_Batch.integrateAccounts[setAccountsId : ' + setAccountsId + '] ->');
        
        lstAccountsToIntegrate = new List<Account>();
        lstAccounts = getAccount(setAccountsId);

        for(Account objAccount : lstAccounts) {
            objAccountToIntegrate = CustomerInterfaceJDESync(objAccount);
            lstAccountsToIntegrate.add(objAccountToIntegrate);
        }

        System.debug('LAT_BR_TransferAccounts_Batch.integrateAccounts[lstAccountsToIntegrate : ' + lstAccountsToIntegrate + ']');

        if(!lstAccountsToIntegrate.isEmpty()) {
            Database.update(lstAccountsToIntegrate);
        }

        System.debug('LAT_BR_TransferAccounts_Batch.integrateAccounts[] <-');
    }

    private void processErrors(String strErrors) {
        List<Messaging.SingleEmailMessage> lstEmailsToSent = null;
        Messaging.SingleEmailMessage objMail = null;
        List<String> lstEmails = null;
        String strBaseUrl = null;
        String strEmailBody =  null;

        System.debug('LAT_BR_TransferAccounts_Batch.processErrors[strErrors : ' + strErrors + '] ->');

        strBaseUrl = System.URL.getSalesforceBaseUrl().getHost();
        if(Test.isRunningTest()){
            lstEmails = new String[]{'test@gmail.com'};
        } else {
            lstEmails = LAT_GeneralConfigDao.getValueAsStringArray('ACCOUNT_NOTIFY_ERROR_MAIL', ';');
        }

        strEmailBody = '<html><body><b>Ocorreu um erro na transferencia:</b> <br> <br> Registros com erro: <br> <br>';        
        strEmailBody += strErrors;
        
        objMail = new Messaging.SingleEmailMessage();        
        objMail.setToAddresses(lstEmails);
        objMail.setHtmlBody(strEmailBody);
        objMail.setSenderDisplayName('noreply@pernod-ricard.com');
        objMail.setSubject('Erro ao tentar transferir os clientes.');
        
        lstEmailsToSent = new List<Messaging.SingleEmailMessage>();
        lstEmailsToSent.add(objMail);    
        try{
            if(!Test.isRunningTest()){
                Messaging.sendEmail(lstEmailsToSent);
            }
        } catch (Exception Ex) {
            System.debug('LAT_BR_TransferAccounts_Batch.processErrors[Ex : ' + Ex.getMessage() + ']');
        } 

        System.debug('LAT_BR_TransferAccounts_Batch.processErrors[] <-');
    }

    public static Account CustomerInterfaceJDESync(Account objAccount) { 
        String strCountry = null;
        LAT_WS_CustomerHandlerTypes.CustomerHandlerArgumentsType objCustomerArguments = null;
        LAT_WS_CustomerHandler.port objRequest = null; 
        LAT_WS_CustomerHandlerTypes.ClientInfoType objClientInfo = null;
        LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType objResponse = null;
        String strEndpoint = null;

        System.debug('LAT_BR_TransferAccounts_Batch.getAccount[objAccount : ' + objAccount + '] ->');

        if(objAccount != NULL) {
            System.debug('LAT_BR_TransferAccounts_Batch.getAccount[objAccount.RecordTypeId : ' + objAccount.RecordTypeId + ']');
            strCountry = LAT_WS_CustomerHandlerInterface.getCountryInfo(objAccount.RecordTypeId);
            System.debug('LAT_BR_TransferAccounts_Batch.getAccount[strCountry : ' + strCountry + ']');
            
            objCustomerArguments = LAT_WS_CustomerHandlerInterface.getCustomerArguments(objAccount, strCountry);
            objRequest = new LAT_WS_CustomerHandler.port(); // Timeout and auth handled directly on LAT_WS_CustomerHandler
            objClientInfo = LAT_WS_CustomerHandlerInterface.getConnectionParameter(strCountry);
            
            strEndpoint = getWSEndpoint(objClientInfo.country);
    
            System.debug('LAT_BR_TransferAccounts_Batch.getAccount[objClientInfo : ' + objClientInfo + ']');
            System.debug('LAT_BR_TransferAccounts_Batch.getAccount[objCustomerArguments : ' + objCustomerArguments + ']');
            System.debug('LAT_BR_TransferAccounts_Batch.getAccount[strEndpoint : ' + strEndpoint + ']');
            System.debug('LAT_BR_TransferAccounts_Batch.getAccount[objAccount.Id : ' + objAccount.Id + ']');
            
            if(!Test.isRunningTest()) {
                objResponse = objRequest.operation(objClientInfo, objCustomerArguments, strEndpoint, true, objAccount.Id);
                objAccount = LAT_WS_CustomerHandlerInterface.parseResponse(objResponse, objAccount);
            }

            System.debug('LAT_BR_TransferAccounts_Batch.getAccount[objResponse : ' + objResponse + ']');          
        }

        System.debug('LAT_BR_TransferAccounts_Batch.getAccount[' + objAccount + '] <-');
        return objAccount;
    }

    //MRLLANOS: SE PODRIA METER EN UNA CLASE HELPER
    public static String getWSEndpoint(String strCountry) {
        String strEndpoint = null;
        List<CS001_JDEInterfaceCredentials__c> lstJDECredentials = null;

        System.debug('LAT_BR_TransferAccounts_Batch.getWSEndpoint[setAccountId : ' + strCountry + '] ->');

        if(String.isNotBlank(strCountry)) {
            lstJDECredentials = [SELECT EndPoint_CustomerHandler__c
                                FROM CS001_JDEInterfaceCredentials__c
                                WHERE Country__c =: strCountry];
            if(!lstJDECredentials.IsEmpty()) {
                if(String.isNotBlank(lstJDECredentials[0].EndPoint_CustomerHandler__c)) {
                    strEndpoint = lstJDECredentials[0].EndPoint_CustomerHandler__c;
                } else {
                    throw new TransferAccountBatchException('Debe configurar primero el EndPoint_CustomerHandler__c en CS001_JDEInterfaceCredentials__c');
                }
            } else {
                throw new TransferAccountBatchException('No se encontro la configuracion para el pais dado');
            }
        } else {
            throw new TransferAccountBatchException('Debe ingresar un pais para buscar su configuracion.');
        }

        System.debug('LAT_BR_TransferAccounts_Batch.getWSEndpoint[' + strEndpoint + '] <-');          
 
        return strEndpoint;
    }

    //MRLLANOS: SE PODRIA METER EN UNA CLASE HELPER
    public static List<Account> getAccount(Set<Id> setAccountId) {
        List<Account> lstAccounts = null;

        System.debug('LAT_BR_TransferAccounts_Batch.getAccount[setAccountId : ' + setAccountId + '] ->');

        if(setAccountId != NULL && !setAccountId.isEmpty()) {
            lstAccounts = [SELECT
                                Accept_applications_Incompleted__c,
                                Accept_Backorder__c, 
                                LAT_BR_RegionalClientOnPremise__c,
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
                                WHERE Id IN: setAccountId];
            
            lstAccounts = (lstAccounts.isEmpty())?null:lstAccounts;
        }

        System.debug('LAT_BR_TransferAccounts_Batch.getAccount[' + lstAccounts + '] <-');          
        return lstAccounts;
    }

}