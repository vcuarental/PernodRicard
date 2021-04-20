/********************************************************************************
*   Company:Valuenet    Developer:Waldemar Mayo     Date:21/03/2013             *
********************************************************************************/

global class WS02_CustomerHandlerInterface_AR {
    
    private static String country;
    private static String countryCode;
    private static Set<Id> idRecTypeUdc;
    private static Account customerBackUp;
    private static Set<Id> setRecTypeAcc_AR;
    private static Set<Id> setRecTypeAcc_UR;
    private static final String ACTION_INSERT = 'A';
    private static final String ACTION_UPDATE = 'C';
    
    @Future(callout=true)
    Webservice static void CustomerInterfaceJDE(String idSalesforce){
        CustomerInterfaceJDESync(idSalesforce);
    }

    
    Webservice static void CustomerInterfaceJDESync(String idSalesforce){
        
        if(idSalesforce == null){
            return;
        }
        
        CustomerHandlerTypes.CustomerHandlerArgumentsType customerArguments;
        CustomerHandlerTypes.CustomerHandlerResponseType response;
        CustomerHandler.port request = new CustomerHandler.port(); 
        String[] globalPhone;
        String[] globalUDC;
        Account customer;
        LAT_Account__c lat_customer;
                
        setRecTypeAcc_AR = Global_RecordTypeCache.getRtIdSet('Account',new Set<String>{'ACC_1_OffTrade_ARG','ACC_3_OnTrade_ARG','ACC_5_Events_ARG'});
        setRecTypeAcc_UR = Global_RecordTypeCache.getRtIdSet('Account',new Set<String>{'ACC_2_OffTrade_URU','ACC_4_OnTrade_URU','ACC_6_Events_URU'});
        
        idRecTypeUdc = new Set<Id>();
        
        String Error;
        
        try{
            //agrego el campo Owner.C_digo_JDE__c 31/05/13 Rodrigo Aguirre
            List<Account> customerList = [SELECT Id, Name, CurrencyISOCode, Owner.C_digo_JDE__c, CustomerPoRequired_AR__c, CollectionAgent_AR__r.CodDefUsuario__c,
                                          CustomerPriceGroup_AR__r.CodDefUsuario__c, Business_Unit_AR__r.CodDefUsuario__c, Corporate_Name__c, Revenue_Postal_Code__c, Revenue_City__r.Name,
                                          Revenue_Country__c, Revenue_Neighbourhood__c, Revenue_UF__c, ParentId, Phone, CNPJ__c, State_registration__c,
                                          Payment_Condition__r.CodDefUsuario__c, Payment_instrument__r.CodDefUsuario__c, Rating, Credit_line__c, Billing_Priority__c, Customer_GL__r.CodDefUsuario__c,
                                          Regional_AR__r.CodDefUsuario__c, Customer_Organization__r.CodDefUsuario__c, Accept_applications_Incompleted__c, Accept_line_incompleted__c, 
                                          Accept_Backorder__c, Email_NFE__c, Client_code_AN8__c, Billing_Address_Code__c, Shipping_Address_Code__c,
                                          Sub_Channel_Rating__r.CodDefUsuario__c, RecordTypeId, CatCode02_AR__r.CodDefUsuario__c, AddressLine1_AR__c, Status__c
                                          FROM Account WHERE Id=:idSalesforce];
            lat_customer = [SELECT Id, NAme, LAT_JDEZone__c FROM LAT_Account__c WHERE LAT_AccountId__c = :idSalesforce LIMIT 1];
            
            if(customerList.size() == 0){
                return;
            }
            customer = customerList[0];
            
            customerBackUp = customer.clone(true);
            
            if(setRecTypeAcc_AR.contains(customer.RecordTypeId)){
                country = 'Argentina';
                countryCode = '6';
                idRecTypeUdc.add(Global_RecordTypeCache.getRtId('UDC__c' + 'Standard_AR'));
            }else if(setRecTypeAcc_UR.contains(customer.RecordTypeId)){
                country = 'Uruguay';
                countryCode = '5';
                idRecTypeUdc.add(Global_RecordTypeCache.getRtId('UDC__c' + 'Standard_UY'));
            }
            
            customerArguments = new CustomerHandlerTypes.CustomerHandlerArgumentsType();
            
            customerArguments.paiCode = 0;
            if(customer.ParentId != null){
                List<Account> customerParentList = [SELECT Id, Client_code_AN8__c FROM Account WHERE Id =: customer.ParentId];
                if(customerParentList.size() > 0){
                    try{customerArguments.paiCode = Integer.valueOf(customerParentList[0].Client_code_AN8__c);}catch(Exception e){}
                }
            }
            
            customerArguments.IDCRM                    = customer.Id;
            customerArguments.cnpj                     = customer.CNPJ__c;
            customerArguments.customerNickName         = customer.Name;
            customerArguments.CurrencyISOCode          = customer.CurrencyISOCode;
            customerArguments.corporateName            = customer.Corporate_Name__c;
            customerArguments.billingPriority          = customer.Billing_Priority__c;
            customerArguments.collectionAgent          = customer.CollectionAgent_AR__r.CodDefUsuario__c;
            customerArguments.stateRegistration        = customer.State_registration__c;
            customerArguments.customerGL               = customer.Customer_GL__r.CodDefUsuario__c;
            
            //customerArguments.vendorCode             = customer.CatCode02_AR__r.CodDefUsuario__c;
            //cambio solicitado 31/05/13 Rodrigo Aguirre
            customerArguments.vendorCode               = lat_customer.LAT_JDEZone__c;
            
            customerArguments.customerPriceGroup       = customer.CustomerPriceGroup_AR__r.CodDefUsuario__c;
            customerArguments.regionalSales            = customer.Regional_AR__r.CodDefUsuario__c;
            customerArguments.businessUnit             = customer.Business_Unit_AR__r.CodDefUsuario__c;
            customerArguments.paymentTerms             = customer.Payment_Condition__r.CodDefUsuario__c;
            customerArguments.paymentInstrument        = customer.Payment_instrument__r.CodDefUsuario__c;
            customerArguments.incompleteLine           = castBooleantoJDE(customer.Accept_line_incompleted__c);
            customerArguments.orderBalanceBackOrder    = castBooleantoJDE(customer.Accept_Backorder__c);
            customerArguments.PONumberRequired         = castBooleantoJDE(customer.CustomerPoRequired_AR__c);
            customerArguments.customerStatus           = (customer.Rating == 'Cliente inativo') ? '1' : '0';
            customerArguments.customerOrganization     = customer.Customer_Organization__r.CodDefUsuario__c;
            customerArguments.subchannelClassification = customer.Sub_Channel_Rating__r.CodDefUsuario__c;
            customerArguments.incompleteOrders         = castBooleantoJDE(customer.Accept_applications_Incompleted__c);
            customerArguments.creditLimit              = (customer.Credit_line__c != null && customer.Credit_line__c > 0) ? Long.valueOf(String.valueOf(customer.Credit_line__c )) : null;
            
            CustomerHandlerTypes.AddressType invoiceAddress = new CustomerHandlerTypes.AddressType();
            invoiceAddress.address      = customer.AddressLine1_AR__c;
            invoiceAddress.uf           = customer.Revenue_UF__c;
            invoiceAddress.cep          = customer.Revenue_Postal_Code__c;
            invoiceAddress.neighborhood = customer.Revenue_Neighbourhood__c;
            invoiceAddress.country      = customer.Revenue_Country__c;
            invoiceAddress.city         = customer.Revenue_City__r.Name;
            customerArguments.invoiceAddress = invoiceAddress;
            
            CustomerHandlerTypes.ElectronicAddressType emailNFe = new CustomerHandlerTypes.ElectronicAddressType();
            emailNFe.address = customer.Email_NFE__c;
            customerArguments.nfeEmail  = emailNFe;
            
            String actionCode=ACTION_INSERT;
            if (customer.Client_code_AN8__c != null && Integer.valueOf(customer.Client_code_AN8__c.trim())>0){
                actionCode = ACTION_UPDATE;
                customerArguments.customerCode = Integer.valueOf(customer.Client_code_AN8__c);
            }
            customerArguments.actionCode = actionCode;
            
            //JPC: campo personType agregado el 22/5/2013
            if(country == 'Argentina'){
                if(customer.CNPJ__c.startsWith('3')){
                    customerArguments.personType = 'C';
                }else if(customer.CNPJ__c.startsWith('2')){
                    customerArguments.personType = 'P';
                }
            }else if(country == 'Uruguay'){
                customerArguments.personType = 'J';
            }
            
            //Envio a JDE
            request.timeout_x = 120000;
            system.debug('TOKEN getConnectionParameter(): ' + getConnectionParameter());
            system.debug('TOKEN customerArguments: ' + customerArguments);
            response = request.operation(getConnectionParameter(), customerArguments);
            system.debug('TOKEN response: ' + response);
            decodeResponse(response, customer);
            
            customer.Client_country_AN8__c = countryCode + '-' + customer.Client_code_AN8__c;
            
        }catch(Exception e){
            withError(customer, e.getMessage());
            return;
        }
        
        //Actualizo el Cliente
        customer.Is_interface_Process_AR__c = true;
        try{update customer;}catch(Exception e){withError(customer, e.getMessage());return;}
        
        //Envio a aprobacion
        /*
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(customer.Id);
        //if(Test.isRunningTest()){return;}
        try{Approval.Processresult proc = Approval.process(req);}catch(Exception e){withError(customer, e.getMessage());}*/
    }
    
    public static void withError(Account customer, String error){
        customer = customerBackUp;
        customer.Return_JDE_Integration__c = error;
        customer.Status__c = 'Erro JDE';
        customer.Is_interface_Process_AR__c = true;
        update customer;
    }
    
    public static String decodeResponse(CustomerHandlerTypes.CustomerHandlerResponseType response, Account customer){
        String res = '';
        if(response != null &&  customer != null){
          customer.Client_code_AN8__c = String.valueOf(response.customerInvoiceCode);
          customer.Billing_Address_Code__c = String.valueOf(response.customerBillingCode);
          customer.Shipping_Address_Code__c = String.valueOf(response.customerShippingCode);
          customer.Status__c = 'Cliente cadastrado no JDE';
          customer.Return_JDE_Integration__c = '';
        }
        return res;
    }
    
    public static CustomerHandlerTypes.ClientInfoType getConnectionParameter(){
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
 
    public static String castBooleantoJDE(Boolean value){
        if(value != null && value){
            return 'Y';
        }else{
            return 'N';
        }
    }
    
    public static String[] decodePhone(String phone){
        String[] dddPhone = new String[]{'',''};        
        if (phone != null && phone.trim() != ''){
            dddPhone = phone.replace('-','').split(' ');
        }       
        return dddPhone;
    }
           
}