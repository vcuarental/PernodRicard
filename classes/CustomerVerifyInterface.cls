/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* NAME: CustomerVerifyInterface.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                               DATE: 14/01/2013 
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS. 
*******************************************************************************/
global class CustomerVerifyInterface {
  
   @Future(callout=true)
    
    Webservice static void CustomerVerifyInterfaceJDE( String idSalesforce ){
       
        if ( idSalesforce == null ) return;
        
        Set< Id > setRecTypeAcc = new Set< Id >();
	    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
	    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
	    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));
        
        List<Account> customerList = [ SELECT CNPJ__c, Client_code_AN8__c FROM Account 
            WHERE Id=:idSalesforce AND RecordTypeId =: setRecTypeAcc ];
            
        Account customer;
        if ( customerList.size()==0 ) return;
        customer = customerList[0];
        CustomerVerifyTypes.CustomerVerifyArgumentsType customerArguments = new CustomerVerifyTypes.CustomerVerifyArgumentsType();
        customerArguments.customerLegalId = customer.CNPJ__c;
        CustomerVerify.port request = new CustomerVerify.port();
        CustomerVerifyTypes.CustomerVerifyResponseType response;
        request.timeout_x = 120000;
        try
        {
          response = request.operation( getConnectionParameter(), customerArguments );
          if( response == null || response.customerCode == 0 ) return;
          customer.Client_code_AN8__c = String.valueOf( response.customerCode );
          customer.Billing_Address_Code__c= String.valueOf(response.customerBillingCode);
          customer.Shipping_Address_Code__c = String.valueOf(response.customerShippingCode);
          customer.Status__c = 'Cliente cadastrado no JDE';
        }
        catch( CalloutException c )
        {
          return;
        }
        catch(Exception e) {
          customer.Return_JDE_Integration__c = e.getMessage();
          customer.Status__c = 'Erro JDE';            
        }
        update customer;
    }
    
    public static CustomerVerifyTypes.ClientInfoType getConnectionParameter(){
        CustomerVerifyTypes.ClientInfoType connParms = new CustomerVerifyTypes.ClientInfoType();
        connParms.country='';
        connParms.remoteHostIP='';
        connParms.system_x='';
        connParms.systemUserID='';
        //connParms.time_x=today;
        return connParms;
    }

}