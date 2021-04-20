/********************************************************************************
*     Company:Valuenet  Developer:Elena J. Schwarzböck    Date:07/10/2013       *
*********************************************************************************/

global class LAT_MX_WS01_CustomerHandlerInterface {
    
    private static final String ACTION_INSERT = 'A';
    private static final String ACTION_UPDATE = 'C';
    private static String country = 'México';
    private static String countryCode = '12';
    private static Account customerBackUp;
    
    @Future(callout = true)
    Webservice static void CustomerInterfaceJDE(String idSalesforce){
        
        List<Account> customerList = [SELECT Id, Accept_applications_Incompleted__c, Accept_Backorder__c, Accept_line_incompleted__c, 
                                      AccountNumber, AddressLine1_AR__c, Billing_Priority__c, Business_Unit__r.CodDefUsuario__c, 
                                      Business_Unit_AR__r.CodDefUsuario__c, Channel__c, Client_code_AN8__c, Client_country_AN8__c, 
                                      CNPJ__c, Corporate_Name__c, Credit_line__c, CurrencyISOCode, Customer_GL__r.CodDefUsuario__c, 
                                      Is_interface_Process_AR__c, LAT_MX_ABCCode__r.CodDefUsuario__c, LAT_MX_AmountReceiptCopies__c, 
                                      LAT_MX_BatchProcess__r.CodDefUsuario__c, LAT_MX_BreakDownIEPS__c, LAT_MX_CableCodeS__c, 
                                      LAT_MX_Chain__r.CodDefUsuario__c, LAT_MX_City__c, LAT_MX_County__c, LAT_MX_CreditVersionLevel__c, 
                                      LAT_MX_CRMClientCode__c, LAT_MX_FiscalEntityType__c, LAT_MX_FiscalRate__r.CodDefUsuario__c, 
                                      LAT_MX_Group__r.CodDefUsuario__c, LAT_MX_Language__c, LAT_MX_Market__c, LAT_MX_Neighbourhood__c, 
                                      LAT_MX_PostalCode__r.Name, LAT_MX_RelatedAddressAN8__c, LAT_MX_RouteCode__r.CodDefUsuario__c, 
                                      LAT_MX_State__c, LAT_MX_ZoneNumber__r.CodDefUsuario__c, Name, Owner.C_digo_JDE__c, Owner.Email, 
                                      Owner.Name, Parent.Client_code_AN8__c, Payment_Condition__r.CodDefUsuario__c, 
                                      Payment_instrument__r.CodDefUsuario__c, Regional__r.CodDefUsuario__c, Return_JDE_Integration__c, 
                                      Revenue_Country__c, Revenue_Number__c, Segmentation_Type_on_trade__c, Status__c 
                                      FROM Account 
                                      WHERE Id =: idSalesforce];
            
        if(customerList.isEmpty()){return;}
        
        Account customer = customerList[0];
        customerBackUp = customer.clone(true);
        
        CustomerHandlerTypes.CustomerHandlerArgumentsType customerArguments;
        
        try{    
            //Mapeo de Cliente a clase de interfase
            customerArguments = mapCustomer(customer);
            
            //Llamado a la interfase
            CustomerHandler.port request = new CustomerHandler.port();
            request.timeout_x = 120000;
            CustomerHandlerTypes.CustomerHandlerResponseType response = request.operation(getConnectionParameter(), customerArguments);
            
            system.debug('response----->' + response);
            //Mapeo el retorno
            customer.Client_code_AN8__c = String.valueOf(response.customerInvoiceCode);
            customer.Status__c = 'Cliente cadastrado no JDE';
            customer.Return_JDE_Integration__c ='';
            customer.Client_country_AN8__c = countryCode + '-' + customer.Client_code_AN8__c;
            
        }catch(Exception e){
            withError(customer, e.getMessage());
            return;
        }
        
        //Actualizacion del Cliente
        customer.Is_interface_Process_AR__c = true;
        try{update customer;}catch(Exception e){withError(customer, e.getMessage());return;}
        
        //Envio de mail en caso de éxito
        if(customerArguments.actionCode == ACTION_INSERT){sendSuccessEmail(customer);}
    }
    
    private static CustomerHandlerTypes.CustomerHandlerArgumentsType mapCustomer(Account customer){
        CustomerHandlerTypes.CustomerHandlerArgumentsType customerArguments = new CustomerHandlerTypes.CustomerHandlerArgumentsType();
        
        //Campos Customer
        if(customer.Client_code_AN8__c != null && Integer.valueOf(customer.Client_code_AN8__c.trim()) > 0){
            customerArguments.customerCode = Integer.valueOf(customer.Client_code_AN8__c);
        }
        customerArguments.actionCode               = customerArguments.customerCode == null ? ACTION_INSERT : ACTION_UPDATE;
        customerArguments.IDCRM                    = customer.Id;
        customerArguments.CurrencyISOCode          = customer.CurrencyISOCode;
        customerArguments.paiCode                  = (customer.Parent.Client_code_AN8__c != null ? Integer.valueOf(customer.Parent.Client_code_AN8__c) : 0);           
        customerArguments.vendorCode               = customer.Owner.C_digo_JDE__c;
        customerArguments.corporateName            = customer.Corporate_Name__c; 
        customerArguments.subchannelClassification = customer.Channel__c;
        customerArguments.reportCodeAddBook008     = customer.Segmentation_Type_on_trade__c;
        customerArguments.cnpj                     = customer.CNPJ__c;
        customerArguments.creditLimit              = (customer.Credit_line__c != null && customer.Credit_line__c > 0) ? Long.valueOf(String.valueOf(customer.Credit_line__c )) : null;
        customerArguments.incompleteOrders         = castBooleantoJDE(customer.Accept_applications_Incompleted__c);
        customerArguments.incompleteLine           = castBooleantoJDE(customer.Accept_line_incompleted__c);
        customerArguments.orderBalanceBackOrder    = castBooleantoJDE(customer.Accept_Backorder__c);
        customerArguments.billingPriority          = customer.Billing_Priority__c;
        customerArguments.businessUnit             = customer.Business_Unit__r.CodDefUsuario__c;
        customerArguments.language                 = customer.LAT_MX_Language__c;
        customerArguments.altPayor                 = customer.LAT_MX_RelatedAddressAN8__c != null ? integer.valueOf(customer.LAT_MX_RelatedAddressAN8__c) : null;
        customerArguments.stateRegistration        = customer.LAT_MX_BreakDownIEPS__c;
        customerArguments.nielsenArea              = customer.LAT_MX_Market__c;
        customerArguments.regionalSales            = customer.Regional__r.CodDefUsuario__c;
        customerArguments.paymentTerms             = customer.Payment_Condition__r.CodDefUsuario__c;
        customerArguments.paymentInstrument        = customer.Payment_instrument__r.CodDefUsuario__c;
        customerArguments.customerGL               = customer.Customer_GL__r.CodDefUsuario__c;
        customerArguments.abcCodeMargin            = customer.LAT_MX_ABCCode__r.CodDefUsuario__c;
        customerArguments.routeCode                = customer.LAT_MX_RouteCode__r.CodDefUsuario__c;
        customerArguments.categoryCodeAddressBk30  = customer.LAT_MX_BatchProcess__r.CodDefUsuario__c;
        customerArguments.zoneNumber               = customer.LAT_MX_ZoneNumber__r.CodDefUsuario__c;
        customerArguments.customerOrganization     = customer.LAT_MX_Chain__r.CodDefUsuario__c;
        customerArguments.taxArea1                 = customer.LAT_MX_FiscalRate__r.CodDefUsuario__c;
        customerArguments.accountsReceivableCps    = customer.LAT_MX_CreditVersionLevel__c;
        customerArguments.invoiceCopies            = customer.LAT_MX_AmountReceiptCopies__c != null ? integer.valueOf(customer.LAT_MX_AmountReceiptCopies__c) : null;
        customerArguments.reportCodeAddBook009     = customer.LAT_MX_Group__r.CodDefUsuario__c;
        customerArguments.personType               = (customer.LAT_MX_FiscalEntityType__c == 'Company') ? '1' : '2';
        customerArguments.businessUnit             = customer.Business_Unit_AR__r.CodDefUsuario__c;
        
        //Campos Customer Bank
        CustomerHandlerTypes.BankDataType BankData = new CustomerHandlerTypes.BankDataType();
        BankData.currentAccount   = customer.LAT_MX_CableCodeS__c;
        customerArguments.BankData = BankData;
        
        //Campos Customer InvoiceAddress
        CustomerHandlerTypes.AddressType invoiceAddress = new CustomerHandlerTypes.AddressType();
        invoiceAddress.country      = customer.Revenue_Country__c;
        invoiceAddress.city         = customer.LAT_MX_City__c;
        invoiceAddress.neighborhood = customer.LAT_MX_Neighbourhood__c;
        invoiceAddress.uf           = customer.LAT_MX_State__c;
        invoiceAddress.cep          = customer.LAT_MX_PostalCode__r.Name;
        invoiceAddress.complement   = customer.AddressLine1_AR__c;
        invoiceAddress.number_x     = customer.Revenue_Number__c;
        invoiceAddress.address      = customer.AccountNumber;
        invoiceAddress.cityCode     = customer.LAT_MX_County__c;
        customerArguments.invoiceAddress = invoiceAddress;
        
        system.debug('TOKEN customerArguments: ' + customerArguments);
        return customerArguments;
    }
    
    private static void withError(Account customer, String error){
        customer = customerBackUp;
        customer.Return_JDE_Integration__c = error;
        customer.Status__c = 'Erro JDE';
        customer.Is_interface_Process_AR__c = true;
        update customer;
    }
    
    private static CustomerHandlerTypes.ClientInfoType getConnectionParameter(){
        CustomerHandlerTypes.ClientInfoType connParms = new CustomerHandlerTypes.ClientInfoType();
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        if(cred != null){
            connParms.country = cred.Country__c;
            connParms.remoteHostIP = cred.RemoteHostIP__c;
            connParms.system_x = cred.System__c;
            connParms.systemUserID = cred.SystemUserID__c;
            connParms.time_x = Datetime.now();
        }
        return connParms;
    }
    
    private static String castBooleantoJDE(Boolean value){
        return (value != null && value==true) ? 'Y': 'N';
    }
    
    public static void sendSuccessEmail(Account customer){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = LAT_GeneralConfigDao.getValueAsStringArray('ACC_SUCCESS_EMAIL_JDE_RECEIPT',',');
        if (toAddresses != null) {
            toAddresses.add(customer.Owner.Email);
        } else {
            toAddresses = new String[]{customer.Owner.Email};
        }
        mail.setToAddresses(toAddresses);
        mail.setSubject('Cliente registrado en el sistema JDE');
        String cuerpoDeMail = '';
        cuerpoDeMail += 'Estimado(a) ' + customer.Owner.Name + ',<br/><br/><br/>';
        cuerpoDeMail += 'El cliente ' + customer.Name + ' fue registrado en el sistema.<br/><br/>';
        cuerpoDeMail += 'AN8: ' + customer.Client_code_AN8__c + '<br/><br/>';
        cuerpoDeMail += 'Código CRM: ' + customer.LAT_MX_CRMClientCode__c + '<br/><br/><br/>';                 
        cuerpoDeMail += 'Para mirar el estado del mismo, clique sobre el siguiente link: <a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + customer.Id + '>haga click aquí</a> <br/><br/><br/>';
        cuerpoDeMail += 'Cordialmente,<br/><br/><br/>';
        cuerpoDeMail += 'Equipo CRM';
        mail.setHTMLBody(cuerpoDeMail);         
        try{Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}catch(Exception e){}
    }
}