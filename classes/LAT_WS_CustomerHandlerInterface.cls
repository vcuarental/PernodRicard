public class LAT_WS_CustomerHandlerInterface {
  
  public static final String BREAK_LINE    = '<br/>';
  private static final String ACTION_INSERT = 'A';
  private static final String ACTION_UPDATE = 'C';
  private static final Integer DDD_POS      = 0;
  private static final Integer PHONE_POS    = 1;

  @future(callout = true)
  public static void CustomerInterfaceJDE (String idSalesforce) {
    if(Test.isRunningTest()) {
      Map<String,String> mapa = new Map<String,String>();
      mapa.put('ANY key', 'ANY value');
      Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
    }

    Account customer = LAT_WS_CustomerHandlerInterface.getAccount(idSalesforce);
    system.debug('entrocustomernullAccount');

       // do not continue if a customer was not found
    if (customer == null) {
      system.debug('');
      LAT_DebugUtil debugUtil = new LAT_DebugUtil();
      debugUtil.setOrigin('LAT_WS_CustomerHandlerInterface');
      debugUtil.addData('Could not find Customer with id: ' + idSalesforce);
      debugUtil.insertDebug();
      return;
    }
    CustomerInterfaceJDESync(customer);
  }
 

  public static void CustomerInterfaceJDESync (Account customer) {
    system.debug('sentcust+++ : ' + customer);
    // Log to the debug object
    LAT_DebugUtil debugUtil = new LAT_DebugUtil();
    
    // do not continue if no id was received
    if (customer == null) {
      system.debug('entrocustomernull');
      debugUtil.addData('Received Account is null');
      debugUtil.insertDebug();
      return;
    }
  
    
    final String country = LAT_WS_CustomerHandlerInterface.getCountryInfo(customer.RecordTypeId);
    system.debug('ObtainedCountry+++ : ' + country);
    Boolean useBridge = false;
    if(country == 'México'){
        LAT_BridgeGS1_Customer.execute(customer.Id, debugUtil);
    } else {
      //try {
        LAT_WS_CustomerHandlerTypes.CustomerHandlerArgumentsType customerArguments = LAT_WS_CustomerHandlerInterface.getCustomerArguments(customer, country);
        LAT_WS_CustomerHandler.port request = new LAT_WS_CustomerHandler.port(); // Timeout and auth handled directly on LAT_WS_CustomerHandler
        LAT_WS_CustomerHandlerTypes.ClientInfoType clientInfo = LAT_WS_CustomerHandlerInterface.getConnectionParameter(country);
        final String reqEndpoint = LAT_WS_Utils.getWSEndpoint(clientInfo.country);

        debugUtil.addTitle('Request Start');
        debugUtil.addData(BREAK_LINE + 'Endpoint: ' + reqEndpoint + BREAK_LINE + BREAK_LINE);
        debugUtil.addData(BREAK_LINE + 'Client Info: ' + clientInfo + BREAK_LINE + BREAK_LINE);
        debugUtil.addData(BREAK_LINE + 'Customer Arguments: ' + customerArguments);
        debugUtil.addTitle('Request END');

        // Make request
        LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType response = request.operation(clientInfo, customerArguments, reqEndpoint, true, customer.Id);
        
        system.debug('Parameterssss : ' + customerArguments);
        

        debugUtil.addTitle('Response Start');
        debugUtil.addData(BREAK_LINE+ 'Error Code: ' + response.errorCode + BREAK_LINE);
        debugUtil.addData(BREAK_LINE + 'Error Message: ' + response.errorMsg);
        debugUtil.addTitle('Response END');

        // Parse Response
        customer = LAT_WS_CustomerHandlerInterface.parseResponse(response, customer);

        // Save debug info and update customer
        debugUtil.setOrigin('LAT_WS_CustomerHandlerInterface');
        debugUtil.insertDebug();
        
      /*} catch (DMLException e) {
        if (System.Test.isRunningTest()) return;
        System.Debug('DML PROBLEM');
        System.Debug(e);
        customer.Return_JDE_Integration__c = e.getMessage();
        customer.Status__c = 'Erro JDE';
        debugUtil = new LAT_DebugUtil();
        debugUtil.setOrigin('LAT_WS_CustomerHandlerInterface.EXCEPTION');
        debugUtil.addTitle('DML Exception!');
        debugUtil.addException(e);
        debugUtil.insertDebug();
      } catch (Exception e) {
        if (System.Test.isRunningTest()) return;
        System.Debug('e.getMessage(): ' + e.getMessage());
        customer.Return_JDE_Integration__c = e.getMessage();
        customer.Status__c = 'Erro JDE';
        debugUtil = new LAT_DebugUtil();
        debugUtil.setOrigin('LAT_WS_CustomerHandlerInterface.EXCEPTION');
        debugUtil.addTitle('Exception!');
        debugUtil.addException(e);
        debugUtil.insertDebug();
      }*/
    }
    update customer;  
  }

  public static List<Account> getAccounts(List<String> idsSalesforce) {
    List<Account> customerList = [SELECT id, Name FROM Account
                                      WHERE Id in: idsSalesforce];

    return (customerList.isEmpty()) ? null : customerList;
  }

  public static void updateCustomerStatus(List<String> customerIds){
    List<Account> customerList = LAT_WS_CustomerHandlerInterface.getAccounts(customerIds);
    if(customerList != null && customerList.size()>0){
      for(Account cus : customerList){
        cus.Status__c = 'Customer Sent to JDE - Please Wait';
      }
    }
    update customerList;
  }
  
    
  public static Account getAccount(String idSalesforce) {
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
                                      Return_JDE_Integration__c, 
                                      Segmentation_Type_on_trade__c,
                                      LAT_BR_RegionalClientOnPremise__c,
                                      LAT_Account__r.LAT_MicroRegionalUDC__c,
                                      LAT_Account__r.LAT_MicroRegionalUDC__r.CodDefUsuario__c,
                                          (Select Id,
                                                    Name,
                                                    Obtained_Beneficio_Fiscal_Udc__r.CodDefUsuario__c,
                                                    Obtained_Segment_Udc__r.CodDefUsuario__c,
                                                    Obtained_Perfil_Udc__r.CodDefUsuario__c,
                                                    Obtained_Client_type_Udc__r.CodDefUsuario__c,
                                                    Obtained_Estrategia_comercial_Udc__r.CodDefUsuario__c,
                                                    Obtained_Channel_Udc__r.CodDefUsuario__c,
                                                    Obtained_SubChannel_Udc__r.CodDefUsuario__c,
                                                    Obtained_PRIOR_DE_INVESTIMENTO_Udc__r.CodDefUsuario__c,
                                                    Obtained_Formato_Udc__r.CodDefUsuario__c,
                                                    Obtained_POLiTICA_DE_PRECO_Udc__r.CodDefUsuario__c
                                                    FROM Segmentation_Results__r WHERE Client_Segmentation_2__r.Status__c ='Active')
                                      FROM Account
                                      WHERE Id =: idSalesforce
                                      LIMIT 1];
    return (customerList.isEmpty()) ? null : customerList[0];
  }



  public static String getCountryInfo(String recordTypeId) {
    final String ret;
    final Set<Id> setRecTypeAcc_AR = Global_RecordTypeCache.getRtIdSet('Account', new Set<String> {'ACC_1_OffTrade_ARG', 'ACC_3_OnTrade_ARG', 'ACC_5_Events_ARG'});
    final Set<Id> setRecTypeAcc_UY = Global_RecordTypeCache.getRtIdSet('Account', new Set<String> {'ACC_2_OffTrade_URU', 'ACC_4_OnTrade_URU', 'ACC_6_Events_URU'});
    final Set<Id> setRecTypeAcc_BR = Global_RecordTypeCache.getRtIdSet('Account', AP01_Account_BR.BR_RECORDTYPES);
    final Set<Id> setRecTypeAcc_MX = Global_RecordTypeCache.getRtIdSet('Account', new set<String> {'LAT_MX_ACC_OffTrade', 'LAT_MX_ACC_OnTrade'});

    if (setRecTypeAcc_AR.contains(recordTypeId)) {
      ret = 'Argentina';
      //countryCode = '6';
    } else if (setRecTypeAcc_UY.contains(recordTypeId)) {
      ret = 'Uruguay';
      //countryCode = '5';
    } else if (setRecTypeAcc_BR.contains(recordTypeId)) {
      system.debug('brasil e brasil brasileiro');
      ret = 'Brasil';
      //countryCode = '1';
    } else if (setRecTypeAcc_MX.contains(recordTypeId)) {
      ret = 'México';
      //countryCode = '12';
    }
    return ret;
  }

  public static LAT_WS_CustomerHandlerTypes.CustomerHandlerArgumentsType getCustomerArguments(Account customer, String country) {
    system.debug('entro1');

    LAT_WS_CustomerHandlerTypes.CustomerHandlerArgumentsType customerArguments = new LAT_WS_CustomerHandlerTypes.CustomerHandlerArgumentsType();
    

    system.debug('entro2');
   

    //Map account fields
    customerArguments.paiCode                   = (customer.Parent.Client_code_AN8__c != null ? Integer.valueOf(customer.Parent.Client_code_AN8__c) : 0);
    customerArguments.IDCRM                     = customer.Id;
    customerArguments.cnpj                      = customer.CNPJ__c;
    customerArguments.CurrencyISOCode           = customer.CurrencyISOCode;
    customerArguments.corporateName             = customer.Corporate_Name__c;
    customerArguments.billingPriority           = customer.Billing_Priority__c;
    customerArguments.stateRegistration         = ('México' == country) ? customer.LAT_MX_BreakDownIEPS__c : customer.State_registration__c;
    customerArguments.customerGL                = customer.Customer_GL__r.CodDefUsuario__c;
    customerArguments.paymentTerms              = customer.Payment_Condition__r.CodDefUsuario__c;
    customerArguments.paymentInstrument         = customer.Payment_instrument__r.CodDefUsuario__c;
    customerArguments.incompleteLine            = castBooleantoJDE(customer.Accept_line_incompleted__c);
    customerArguments.incompleteOrders          = castBooleantoJDE(customer.Accept_applications_Incompleted__c);
    customerArguments.customerOrganization      = customer.Customer_Organization__r.CodDefUsuario__c;
    customerArguments.creditLimit               = (customer.Credit_line__c != null && customer.Credit_line__c > 0) ? (Long)Decimal.valueOf(String.valueOf(customer.Credit_line__c)) : null;
    customerArguments.subchannelClassification  = ('México' == country) ? customer.Channel__c : customer.Sub_Channel_Rating__r.CodDefUsuario__c;
    customerArguments.regionalSales             = customer.Regional__r.CodDefUsuario__c;
    customerArguments.orderBalanceBackOrder     = castBooleantoJDE(customer.Accept_Backorder__c);
    customerArguments.customerStatus            = (customer.Rating == 'Cliente inativo') ? '1' : '0';

    system.debug('entro3');
    if ('Brasil' == country) {
      LAT_BR_ClientChannelSegmentation2Result__c customerSegm;
     if(!customer.Segmentation_Results__r.isEmpty()){
        system.debug('entro4');
        customerSegm = customer.Segmentation_Results__r[0];
     }
      system.debug('segment+++: ' + customerSegm);

      system.debug('segment+++: ' + customerArguments.reportCodeAddBook018);
      system.debug('segment+++: ' + customerArguments.reportCodeAddBook019);
      system.debug('segment+++: ' + customerArguments.reportCodeAddBook020);
      system.debug('segment+++: ' + customerArguments.reportCodeAddBook021);
      customerArguments.subchannelClassification  = (customerSegm == null) ? null : customerSegm.Obtained_Segment_Udc__r.CodDefUsuario__c;
      customerArguments.businessUnit              = customer.Business_Unit__r.CodDefUsuario__c;
      customerArguments.affiliate                 = customer.Affiliate__c;
      customerArguments.municipalRegistration     = customer.Municipal_Registration__c;
      customerArguments.customerBarCodeEDI        = customer.Barcode_EDI__c;
      customerArguments.nielsenArea               = customer.Nielsen_Area__r.CodDefUsuario__c;
      customerArguments.aditionalDiscountGroup    = customer.Discount_Group__c;
      customerArguments.customertFlag             = customer.Customer_Flag__r.CodDefUsuario__c;
      customerArguments.customerGeographicRegion  = customer.Customer_Geographic_Region__r.CodDefUsuario__c;
      customerArguments.bonificationGroup         = null;
      customerArguments.freightType               = customer.Freight_Type__c;
      customerArguments.personType                = ' ';
      customerArguments.customerShippingCode      = (customer.Shipping_Address_Code__c != null && customer.Shipping_Address_Code__c != '') ? Integer.valueOf(customer.Shipping_Address_Code__c) : null;
      customerArguments.customerBillingCode       = (customer.Billing_Address_Code__c != null && customer.Billing_Address_Code__c != '') ? Integer.valueOf(customer.Billing_Address_Code__c) : null;
      customerArguments.reportCodeAddBook014      = customer.Yes_No__c ? 'S' : '';
      customerArguments.categoryCodeAddressBk27   = (customer.Receiving_Freight__c == 'Apenas batida' || customer.Receiving_Freight__c == null) ? 'N' : 'S';
      customerArguments.carrierNumber             = null; 

      //campos Segmentacion
      system.debug('entro5');
      customerArguments.reportCodeAddBook018 = (customerSegm == null) ? null : customerSegm.Obtained_Perfil_Udc__r.CodDefUsuario__c;
      customerArguments.reportCodeAddBook019 = (customerSegm == null) ? null : customerSegm.Obtained_Formato_Udc__r.CodDefUsuario__c;
      customerArguments.reportCodeAddBook020 = (customerSegm == null) ? null : customerSegm.Obtained_Client_type_Udc__r.CodDefUsuario__c;
      customerArguments.reportCodeAddBook021 = (customerSegm == null) ? null : customerSegm.Obtained_Estrategia_comercial_Udc__r.CodDefUsuario__c;
      customerArguments.reportCodeAddBook025 = (customerSegm == null) ? null : customerSegm.Obtained_Beneficio_Fiscal_Udc__r.CodDefUsuario__c;
      customerArguments.reportCodeAddBook009 = (customerSegm == null) ? null : customerSegm.Obtained_PRIOR_DE_INVESTIMENTO_Udc__r.CodDefUsuario__c;
      customerArguments.aditionalDiscountGroup = (customerSegm == null) ? null : customerSegm.Obtained_POLiTICA_DE_PRECO_Udc__r.CodDefUsuario__c;
      //customerArguments.vendorCode                = customer.Owner.C_digo_JDE__c;
      customerArguments.vendorCode                = customer.LAT_Account__r.LAT_JDEZone__c;
      if(customer.LAT_BR_RegionalClientOnPremise__c != null && customer.LAT_BR_RegionalClientOnPremise__c != '') {
        UDC__c udcMicroRegional = [SELECT CodDefUsuario__c FROM UDC__c WHERE name =:customer.LAT_BR_RegionalClientOnPremise__c  AND CodProd__c = '01' AND CodUs__c = '07' AND Recordtype.DeveloperName = 'BRA_Standard' Limit 1];
        if(udcMicroRegional != null)
          customerArguments.microRegional             = udcMicroRegional.CodDefUsuario__c;
      }
      
    }

    if ('Argentina' == country || 'Uruguay' == country) {
      customerArguments.customerNickName         = customer.Name;
      customerArguments.collectionAgent          = customer.CollectionAgent_AR__r.CodDefUsuario__c;
      customerArguments.customerPriceGroup       = customer.CustomerPriceGroup_AR__r.CodDefUsuario__c;
      customerArguments.PONumberRequired         = castBooleantoJDE(customer.CustomerPoRequired_AR__c);
      customerArguments.businessUnit             = customer.Business_Unit_AR__r.CodDefUsuario__c;
      customerArguments.regionalSales            = customer.Regional_AR__r.CodDefUsuario__c;
      customerArguments.vendorCode               = customer.LAT_Account__r.LAT_JDEZone__c;
      if(customer.LAT_Account__r.LAT_MicroRegionalUDC__c !=null) {
        customerArguments.microRegional            =  customer.LAT_Account__r.LAT_MicroRegionalUDC__r.CodDefUsuario__c;
      }
      

    }

    if ('México' == country) {
        customerArguments.reportCodeAddBook008     = customer.Segmentation_Type_on_trade__c;
        customerArguments.language                 = customer.LAT_MX_Language__c;
        customerArguments.altPayor                 = customer.LAT_MX_RelatedAddressAN8__c != null ? integer.valueOf(customer.LAT_MX_RelatedAddressAN8__c) : null;
        customerArguments.nielsenArea              = customer.LAT_MX_Market__c;
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
        customerArguments.vendorCode               = customer.Owner.C_digo_JDE__c;
    }
    
    if('Argentina' == country){
      if (customer.CNPJ__c.startsWith('3')) {
        customerArguments.personType = 'C';
      } else if (customer.CNPJ__c.startsWith('2')) {
        customerArguments.personType = 'P';
      }
    } else if ('Uruguay' == country){
        customerArguments.personType = 'J';
    }
                      
    
    /// SOLO BRASIL
    if ('Brasil' == country) {




      if ((customer.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Off_Trade') && (customer.Channel__c == 'Off Trade'|| customer.Channel__c == 'Distribution')) 
            || (customer.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'On_Trade') && customer.Channel__c == 'On Trade')) {           
          Set<String> setName20 = new Set<String>();
          Set<String> setName21 = new Set<String>();
          if (customer.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Off_Trade') 
                && (customer.Channel__c == 'Off Trade'|| customer.Channel__c == 'Distribution')){
             setName20.add(customer.LAT_BR_PriorityLevel__c);                  
          }
          if (customer.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'On_Trade') && customer.Channel__c == 'On Trade') {
             if (customer.Rating == 'Cliente com contrato') {
                 setName20.add('SIM');
             } else{
                 setName20.add('NAO');
                 setName20.add('NÃO');
             }
          }
          if (customer.LAT_BR_FiscalBenefit__c) {
              setName21.add('SIM');
          } else {
             setName21.add('NAO');
             setName21.add('NÃO');                
          }
          /*
          for (UDC__c udc: [SELECT CodUs__c, CodDefUsuario__c 
                                            FROM UDC__c 
                                            WHERE (Internal_id__c LIKE '1-%-01-18' AND Name =: customer.Rating_segmentation_targert_market__c)
                              OR (Internal_id__c LIKE '1-%-01-19' AND Name =: customer.LAT_BR_BusinessSize__c)
                              OR (Internal_id__c LIKE '1-%-01-20' AND Name IN: setName20)
                              OR (Internal_id__c LIKE '1-%-01-21' AND Name IN: setName21)]) {                                                                               
              
              if (udc.CodUs__c == '18') customerArguments.reportCodeAddBook018 = udc.CodDefUsuario__c;
              if (udc.CodUs__c == '19') customerArguments.reportCodeAddBook019 = udc.CodDefUsuario__c;
              if (udc.CodUs__c == '20') customerArguments.reportCodeAddBook020 = udc.CodDefUsuario__c;
              if (udc.CodUs__c == '21') customerArguments.reportCodeAddBook021 = udc.CodDefUsuario__c;
          }*/
      }
    }
                                               
    //invoiceAddress
    LAT_WS_CustomerHandlerTypes.AddressType invoiceAddress = new LAT_WS_CustomerHandlerTypes.AddressType();
    
    if ('Argentina' == country || 'Uruguay' == country) invoiceAddress.address = customer.AddressLine1_AR__c;

    if ('Brasil' == country) {
      invoiceAddress.address      = customer.Revenue_Address__c;
      invoiceAddress.cityCode     = customer.Revenue_City_Code__c;
      invoiceAddress.complement   = customer.Revenue_Complement__c;
      invoiceAddress.number_x     = customer.Revenue_Number__c;
    }

    if ('México' == country) {
      invoiceAddress.country      = customer.Revenue_Country__c;
      invoiceAddress.city         = customer.LAT_MX_City__c;
      invoiceAddress.neighborhood = customer.LAT_MX_Neighbourhood__c;
      invoiceAddress.uf           = customer.LAT_MX_State__c;
      invoiceAddress.cep          = customer.LAT_MX_PostalCode__r.Name;
      
      invoiceAddress.complement   = customer.AddressLine1_AR__c;
      invoiceAddress.number_x     = customer.Revenue_Number__c;
      invoiceAddress.address      = customer.AccountNumber;
      invoiceAddress.cityCode     = customer.LAT_MX_County__c;
    } else {
      invoiceAddress.city         = customer.Revenue_City__r.Name;
      invoiceAddress.country      = customer.Revenue_Country__c;
      invoiceAddress.neighborhood = customer.Revenue_Neighbourhood__c;
      invoiceAddress.cep          = customer.Revenue_Postal_Code__c;
      invoiceAddress.uf           = customer.Revenue_UF__c;
    }
    
    customerArguments.invoiceAddress = invoiceAddress;

    if ('Brasil' == country) {    
      //shippingAddress
      LAT_WS_CustomerHandlerTypes.AddressType shippingAddress = new LAT_WS_CustomerHandlerTypes.AddressType();
      customerArguments.shippingAddress = shippingAddress;          
            
      //billingAddress
      LAT_WS_CustomerHandlerTypes.AddressType billingAddress = new LAT_WS_CustomerHandlerTypes.AddressType();
      customerArguments.billingAddress = billingAddress;          
            
      //businessPhone
      LAT_WS_CustomerHandlerTypes.PhoneNumberType businessPhone = new LAT_WS_CustomerHandlerTypes.PhoneNumberType();
      String[] globalPhone                      = decodePhone(customer.Phone);
      businessPhone.areaCode            = '' ;
      businessPhone.contactPhone        = globalPhone[PHONE_POS];
      businessPhone.ddd                 = globalPhone[DDD_POS];
      customerArguments.businessPhone = businessPhone;
            
      //fax
      LAT_WS_CustomerHandlerTypes.PhoneNumberType fax = new LAT_WS_CustomerHandlerTypes.PhoneNumberType();
      globalPhone = decodePhone(customer.fax);
      fax.areaCode     = '';
      fax.contactPhone = globalPhone[PHONE_POS];
      fax.ddd          = globalPhone[DDD_POS];
      customerArguments.fax = fax;
            
      //bankData
      LAT_WS_CustomerHandlerTypes.BankDataType bankData = new LAT_WS_CustomerHandlerTypes.BankDataType();
      bankData.agency              = customer.Agency__c;
      bankData.bank                = customer.Bank_number__c;
      bankData.bankAccountType     = 'V';
      bankData.bankName            = customer.Bank__r.Name;
      bankData.currentAccount      = customer.Checking_account__c;
      bankData.currentAccountDigit = customer.Current_account__c;          
      customerArguments.bankData = bankData;
            
      //customerSite
      LAT_WS_CustomerHandlerTypes.ElectronicAddressType customerSite = new LAT_WS_CustomerHandlerTypes.ElectronicAddressType();
      customerSite.address = customer.WebSite;
      customerArguments.customerSite  = customerSite;
            
      //contactEmail
      LAT_WS_CustomerHandlerTypes.ElectronicAddressType contactEmail = new LAT_WS_CustomerHandlerTypes.ElectronicAddressType();
      contactEmail.address = null;
      customerArguments.contactEmail  = contactEmail;
    }

    /*if ('México' == country) {
      LAT_WS_CustomerHandlerTypes.BankDataType bankData = new LAT_WS_CustomerHandlerTypes.BankDataType();
      bankData.currentAccount   = customer.LAT_MX_CableCodeS__c;
      customerArguments.BankData = bankData;
    }*/
          
    //emailNFe
    LAT_WS_CustomerHandlerTypes.ElectronicAddressType emailNFe = new LAT_WS_CustomerHandlerTypes.ElectronicAddressType();
    emailNFe.address = customer.Email_NFE__c;
    customerArguments.nfeEmail = emailNFe;
          
    //Accion "Insert" o "Update"
    String actionCode = ACTION_INSERT;
    if (customer.Client_code_AN8__c != null && Integer.valueOf(customer.Client_code_AN8__c.trim()) > 0) {
        actionCode = ACTION_UPDATE;
        customerArguments.customerCode = Integer.valueOf(customer.Client_code_AN8__c);
    }
    customerArguments.actionCode = actionCode;

    return customerArguments;
  }

  public static Account parseResponse(LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType response, Account c){
    if (c != null) {
      if ('0' == response.errorCode) {
        //c.Status__c = 'Customer Sent to JDE - Please Wait';
      
      } else if ('-2' == response.errorCode) {
        c.Status__c = 'JDE under maintenance - To be processed later - Please Wait';
        c.Return_JDE_Integration__c = 'Response Code: ' + response.errorCode + '\n\nResponse Message: ' + response.errorMsg;
      
      } else if ('-4' == response.errorCode) {
        c.Status__c = 'JDE Integration Error'; // Falta la variable Environment (OrgID) en el parametro system
        c.Return_JDE_Integration__c = 'Response Code: ' + response.errorCode + '\n\nResponse Message: ' + response.errorMsg;
      
      } else if ('-5' == response.errorCode) { // Pedido com erro no JDE Estamos revisando el problema
        c.Status__c = 'JDE Integration Error';
        c.Return_JDE_Integration__c = 'Response Code: ' + response.errorCode + '\n\nResponse Message: ' + response.errorMsg;
      
      } else if ('-9' == response.errorCode) {
        c.Status__c = 'Service Not Available';
        c.Return_JDE_Integration__c = 'Response Code: ' + response.errorCode + '\n\nResponse Message: ' + response.errorMsg;
      
      } else {
        c.Status__c = 'Erro JDE';
        c.Return_JDE_Integration__c = 'Response Code: ' + response.errorCode + '\n\nResponse Message: ' + response.errorMsg;
        
      }
    }
    return c;
  }
  
  public static LAT_WS_CustomerHandlerTypes.ClientInfoType getConnectionParameter(String country) {
      LAT_WS_CustomerHandlerTypes.ClientInfoType connParms = new LAT_WS_CustomerHandlerTypes.ClientInfoType();
      CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
      system.debug('connectData+++:' + cred);
      if(cred != null){
          connParms.country = cred.Country__c;
          connParms.remoteHostIP = cred.RemoteHostIP__c;
          connParms.system_x     = cred.System__c;
          connParms.systemUserID = cred.SystemUserID__c;
          connParms.time_x       = Datetime.now();
      }
      return connParms;
  }

  public static String castBooleantoJDE(Boolean value) {
      String ret = 'N';
      if (value != null && value) {
          ret = 'Y';
      }
      return ret;
  }
  
  public static String[] decodePhone(String phone) {
      String[] dddPhone = new String[]{'',''};
      if (phone != null && phone.trim() != '') dddPhone = phone.replace('-', '').split(' ');
      return dddPhone;
  }

}