/*****************************************************************************
*                         Copyright 2012 - Cloud2b                           *
******************************************************************************
*                                                                            *
* NAME: CustomerHandlerInterface.trigger                                     *
* AUTHOR: ROGÉRIO ALVARENGA                         DATE:                    *
*                                                                            *
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS. *
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013         *
*****************************************************************************/
global class CustomerHandlerInterface{
    
    private static final String ACTION_INSERT = 'A';
    private static final String ACTION_UPDATE = 'C';
    private static final Integer DDD_POS = 0;
    private static final Integer PHONE_POS = 1;
    private static Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
    
    @Future(callout = true)
    Webservice static void CustomerInterfaceJDE(String idSalesforce){
        System.debug('enter the matrix++++');
        if(idSalesforce == null)return;
        
        //Set<Id> setRecTypeAcc = //Global_RecordTypeCache.getRtIdSet('Account', new set<String>{'Eventos', 'Off_Trade', 'On_Trade'});
        Set<Id> setRecTypeAcc = Global_RecordTypeCache.getRtIdSet('Account', AP01_Account_BR.BR_RECORDTYPES);
        
        Account customer;
        try{
            List<Account> customerList = [SELECT Accept_applications_Incompleted__c, Accept_Backorder__c, Accept_line_incompleted__c, CNPJ__c, Agency__c, 
                                          Affiliate__c, Bank_number__c, Barcode_EDI__c, Billing_Address_Code__c, Billing_Priority__c, Corporate_Name__c,
                                          Business_Unit__r.CodDefUsuario__c, Carriers_Numbers__c, Checking_account__c, Payment_instrument__r.CodDefUsuario__c,
                                          Client_code_AN8__c, Credit_line__c, Current_account__c, Customer_Geographic_Region__r.CodDefUsuario__c, Type,
                                          Customer_Flag__r.CodDefUsuario__c, Revenue_Number__c, Revenue_Postal_Code__c,  Shipping_Address_Code__c, 
                                          Customer_GL__r.CodDefUsuario__c, Customer_Organization__r.CodDefUsuario__c, Phone, Channel__c, Revenue_UF__c,
                                          Discount_Group__c, Email_NFE__c, Fax, Freight_Type__c, Municipal_Registration__c, WebSite,
                                          Nielsen_Area__r.CodDefUsuario__c, OwnerId, ParentId, Payment_Condition__r.CodDefUsuario__c, Bank__r.Name, Yes_No__c,                                  
                                          Rating, Receiving_Freight__c, Regional__r.CodDefUsuario__c, Revenue_Address__c, Revenue_City__r.Name,
                                          Revenue_City_Code__c, Revenue_Complement__c, Revenue_Country__c, Revenue_Neighbourhood__c, State_registration__c,     
                                          Sub_Channel_Rating__r.CodDefUsuario__c, RecordTypeId, LAT_BR_PriorityLevel__c, LAT_BR_FiscalBenefit__c,
                                          Rating_segmentation_targert_market__c, LAT_BR_BusinessSize__c
                                          FROM Account
                                          WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeAcc];
            
            if(customerList.isEmpty()){
                return;
            }
            customer = customerList[0];
            
            CustomerHandlerTypes.CustomerHandlerArgumentsType customerArguments = new CustomerHandlerTypes.CustomerHandlerArgumentsType();
            
            customerArguments.paiCode = 0;
            if(customer.ParentId != null){
                List<Account> customerParentList = [SELECT Client_code_AN8__c FROM account WHERE Id =: customer.ParentId];
                if(!customerParentList.isEmpty()){
                    customerArguments.paiCode = Integer.valueOf(customerParentList[0].Client_code_AN8__c);
                }
            }
            
            customerArguments.vendorCode = '';
            if(customer.OwnerId != null){
                List<User> userOwnerList = [SELECT C_digo_JDE__c FROM User WHERE id=:customer.OwnerId];
                if(!userOwnerList.isEmpty()){
                    customerArguments.vendorCode = userOwnerList[0].C_digo_JDE__c;
                }
            }
            
            //Mapeo de campos de Account
            customerArguments.subchannelClassification  = customer.Sub_Channel_Rating__r.CodDefUsuario__c;
            customerArguments.businessUnit              = customer.Business_Unit__r.CodDefUsuario__c;
            customerArguments.corporateName             = customer.Corporate_Name__c;
            customerArguments.CurrencyISOCode           = 'BRL';
            customerArguments.affiliate                 = customer.Affiliate__c;
            customerArguments.cnpj                      = customer.CNPJ__c;
            customerArguments.stateRegistration         = customer.State_registration__c;
            customerArguments.municipalRegistration     = customer.Municipal_Registration__c;
            customerArguments.paymentTerms              = customer.Payment_Condition__r.CodDefUsuario__c;
            customerArguments.paymentInstrument         = customer.Payment_instrument__r.CodDefUsuario__c;
            customerArguments.customerBarCodeEDI        = customer.Barcode_EDI__c;
            customerArguments.creditLimit               = (customer.Credit_line__c != null && customer.Credit_line__c > 0) ? (Long.valueOf(String.valueOf(customer.Credit_line__c))) : null;
            customerArguments.billingPriority           = customer.Billing_Priority__c;
            customerArguments.customerGL                = customer.Customer_GL__r.CodDefUsuario__c;
            customerArguments.regionalSales             = customer.Regional__r.CodDefUsuario__c;
            customerArguments.nielsenArea               = customer.Nielsen_Area__r.CodDefUsuario__c;
            customerArguments.aditionalDiscountGroup    = customer.Discount_Group__c;
            customerArguments.customerOrganization      = customer.Customer_Organization__r.CodDefUsuario__c;
            customerArguments.customertFlag             = customer.Customer_Flag__r.CodDefUsuario__c;
            customerArguments.customerGeographicRegion  = customer.Customer_Geographic_Region__r.CodDefUsuario__c;
            customerArguments.bonificationGroup         = null;
            customerArguments.incompleteOrders          = castBooleantoJDE(customer.Accept_applications_Incompleted__c);
            customerArguments.incompleteLine            = castBooleantoJDE(customer.Accept_line_incompleted__c);
            customerArguments.orderBalanceBackOrder     = castBooleantoJDE(customer.Accept_Backorder__c);
            customerArguments.freightType               = customer.Freight_Type__c;
            customerArguments.customerStatus            = (customer.Rating == 'Cliente inativo') ? '1': '0';            
            customerArguments.personType                = ' ';
            customerArguments.customerShippingCode      = (customer.Shipping_Address_Code__c != null && customer.Shipping_Address_Code__c != '') ? Integer.valueOf(customer.Shipping_Address_Code__c) : null;
            customerArguments.customerBillingCode       = (customer.Billing_Address_Code__c != null && customer.Billing_Address_Code__c != '') ? Integer.valueOf(customer.Billing_Address_Code__c) : null;
            customerArguments.reportCodeAddBook014      = customer.Yes_No__c ? 'S' : '';
            customerArguments.categoryCodeAddressBk27   = (customer.Receiving_Freight__c == 'Apenas batida' || customer.Receiving_Freight__c == null) ? 'N' : 'S';
            customerArguments.carrierNumber             = customer.Carriers_Numbers__c != null ? Integer.ValueOf(customer.Carriers_Numbers__c) : null;
            
            //reportCode            
                        
            //campos Segmentacion
            customerArguments.reportCodeAddBook018 = null;
            customerArguments.reportCodeAddBook019 = null;
            customerArguments.reportCodeAddBook020 = null; 
            customerArguments.reportCodeAddBook021 = null;

            if((customer.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Off_Trade') && (customer.Channel__c == 'Off Trade'|| customer.Channel__c == 'Distribution')) || (customer.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'On_Trade') && customer.Channel__c == 'On Trade')){           
                Set<String> setName20 = new Set<String>();
                Set<String> setName21 = new Set<String>();
                if(customer.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Off_Trade') && (customer.Channel__c == 'Off Trade'|| customer.Channel__c == 'Distribution')){
                   setName20.add(customer.LAT_BR_PriorityLevel__c);                  
                }
                if(customer.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'On_Trade') && customer.Channel__c == 'On Trade'){
                   if(customer.Rating == 'Cliente com contrato'){
                       setName20.add('SIM');
                   }else{
                       setName20.add('NAO');
                       setName20.add('NÃO');
                   }
                }
                if(customer.LAT_BR_FiscalBenefit__c){
                    setName21.add('SIM');
                }else{
                   setName21.add('NAO');
                   setName21.add('NÃO');                
                }
                
                for (UDC__c udc: [SELECT CodUs__c, CodDefUsuario__c FROM UDC__c WHERE (Internal_id__c LIKE '1-%-01-18' AND Name =: customer.Rating_segmentation_targert_market__c)
                                                                                   OR (Internal_id__c LIKE '1-%-01-19' AND Name =: customer.LAT_BR_BusinessSize__c)
                                                                                   OR (Internal_id__c LIKE '1-%-01-20' AND Name IN: setName20)
                                                                                   OR (Internal_id__c LIKE '1-%-01-21' AND Name IN: setName21)]){                                                                               
                    
                    if(udc.CodUs__c == '18') customerArguments.reportCodeAddBook018 = udc.CodDefUsuario__c;
                    if(udc.CodUs__c == '19') customerArguments.reportCodeAddBook019 = udc.CodDefUsuario__c;
                    if(udc.CodUs__c == '20') customerArguments.reportCodeAddBook020 = udc.CodDefUsuario__c;
                    if(udc.CodUs__c == '21') customerArguments.reportCodeAddBook021 = udc.CodDefUsuario__c;
                }
            }
                                                 
            //invoiceAddress
            CustomerHandlerTypes.AddressType invoiceAddress = new CustomerHandlerTypes.AddressType();
            invoiceAddress.address      = customer.Revenue_Address__c;
            invoiceAddress.cep          = customer.Revenue_Postal_Code__c;
            invoiceAddress.city         = customer.Revenue_City__r.Name;
            invoiceAddress.cityCode     = customer.Revenue_City_Code__c;
            invoiceAddress.complement   = customer.Revenue_Complement__c;
            invoiceAddress.country      = customer.Revenue_Country__c;
            invoiceAddress.neighborhood = customer.Revenue_Neighbourhood__c;
            invoiceAddress.number_x     = customer.Revenue_Number__c;
            invoiceAddress.uf           = customer.Revenue_UF__c;
            customerArguments.invoiceAddress = invoiceAddress;
            
            //shippingAddress
            CustomerHandlerTypes.AddressType shippingAddress = new CustomerHandlerTypes.AddressType();
            customerArguments.shippingAddress = shippingAddress;          
            
            //billingAddress
            CustomerHandlerTypes.AddressType billingAddress = new CustomerHandlerTypes.AddressType();
            customerArguments.billingAddress = billingAddress;          
            
            //businessPhone
            CustomerHandlerTypes.PhoneNumberType businessPhone = new CustomerHandlerTypes.PhoneNumberType();
            String[] globalPhone = decodePhone(customer.Phone);
            businessPhone.areaCode      = '' ;
            businessPhone.contactPhone  = globalPhone[PHONE_POS];
            businessPhone.ddd           = globalPhone[DDD_POS];
            customerArguments.businessPhone = businessPhone;
            
            //fax
            CustomerHandlerTypes.PhoneNumberType fax = new CustomerHandlerTypes.PhoneNumberType();
            globalPhone = decodePhone(customer.fax);
            fax.areaCode     = '';
            fax.contactPhone = globalPhone[PHONE_POS];
            fax.ddd          = globalPhone[DDD_POS];
            customerArguments.fax = fax;
            
            //bankData
            CustomerHandlerTypes.BankDataType bankData = new CustomerHandlerTypes.BankDataType();
            bankData.agency              = customer.Agency__c;
            bankData.bank                = customer.Bank_number__c;
            bankData.bankAccountType     = 'V';
            bankData.bankName            = customer.Bank__r.Name;
            bankData.currentAccount      = customer.Checking_account__c;
            bankData.currentAccountDigit = customer.Current_account__c;          
            customerArguments.bankData = bankData;
            
            //customerSite
            CustomerHandlerTypes.ElectronicAddressType customerSite = new CustomerHandlerTypes.ElectronicAddressType();
            customerSite.address = customer.WebSite;
            customerArguments.customerSite  = customerSite;
            
            //contactEmail
            CustomerHandlerTypes.ElectronicAddressType contactEmail = new CustomerHandlerTypes.ElectronicAddressType();
            contactEmail.address = null;
            customerArguments.contactEmail  = contactEmail;
            
            //emailNFe
            CustomerHandlerTypes.ElectronicAddressType emailNFe = new CustomerHandlerTypes.ElectronicAddressType();
            emailNFe.address = customer.Email_NFE__c;
            customerArguments.nfeEmail = emailNFe;
            
            //Accion "Insert" o "Update"
            String actionCode = ACTION_INSERT;
            if(customer.Client_code_AN8__c != null && Integer.valueOf(customer.Client_code_AN8__c.trim()) > 0){
                actionCode = ACTION_UPDATE;
                customerArguments.customerCode = Integer.valueOf(customer.Client_code_AN8__c);
            }
            customerArguments.actionCode = actionCode;
            
            //LLAMADA A LA INTERFAZ
            CustomerHandler.port request = new CustomerHandler.port();
            request.timeout_x = 120000;           
            CustomerHandlerTypes.CustomerHandlerResponseType response = request.operation(getConnectionParameter(), customerArguments);
            decodeResponse(response, customer);
            
            system.debug('response: '+response);
            
        }catch(Exception e){
            if(system.Test.isRunningTest())return;
            system.debug('e.getMessage(): ' + e.getMessage());
            customer.Return_JDE_Integration__c = e.getMessage();
            customer.Status__c = 'Erro JDE';
        }
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
            customer.Client_country_AN8__c = '1-' + customer.Client_code_AN8__c;
        }
        return res;
    }
    
    public static CustomerHandlerTypes.ClientInfoType getConnectionParameter(){
        CustomerHandlerTypes.ClientInfoType connParms = new CustomerHandlerTypes.ClientInfoType();
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance('Brasil');
        if(cred != null){
            connParms.country      = cred.Country__c;
            connParms.remoteHostIP = cred.RemoteHostIP__c;
            connParms.system_x     = cred.System__c;
            connParms.systemUserID = cred.SystemUserID__c;
            connParms.time_x       = Datetime.now();
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
        if(phone != null && phone.trim() != '') dddPhone = phone.replace('-','').split(' ');
        return dddPhone;
    }

}