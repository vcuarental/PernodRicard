@isTest
private class LAT_PaymentApproveReproveDA_Test {
	
	@isTest static void test_method_one() {
		LAT_PaymentApproveReproveDA.SdtMsg m1 = new LAT_PaymentApproveReproveDA.SdtMsg();
		LAT_PaymentApproveReproveDA.WSAprovarReprovarDA_ExecuteResponse_element c1 = new LAT_PaymentApproveReproveDA.WSAprovarReprovarDA_ExecuteResponse_element();
		//c1.SdtMsg_SdtMsgItem = new List<LAT_PaymentApproveReproveDA.SdtMsg>{m1};


	}
	

	@isTest static void test_method_two() {
		Map<String,String> mapa = new Map<String,String>();
		mapa.put('ANY key', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		LAT_ContractDAHandlerInterface handler = new LAT_ContractDAHandlerInterface();
		User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
        LAT_ContractsWS_Test.setup(u);
        Test.startTest();
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		insert con;
		LAT_ContractDAHandlerInterface.createNewDA(con.Id);
		//handler.generateDA('123456', Date.today().year(),'1234232', 1000.00, 'DA');
		Test.stopTest();
	}

	@isTest static void test_method_two23() {
		Map<String,String> mapa = new Map<String,String>();
		mapa.put('ANY key', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		LAT_ContractDAHandlerInterface handler = new LAT_ContractDAHandlerInterface();
		User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
        LAT_ContractsWS_Test.setup(u);
        Test.startTest();
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		insert con;
		//LAT_ContractDAHandlerInterface.createNewDA(con.Id);
		//handler.generateDA('123456', Date.today().year(),'1234232', 1000.00, 'DA');
		LAT_PaymentCreateDA.WSCriarDA_ExecuteResponse_element message = new LAT_PaymentCreateDA.WSCriarDA_ExecuteResponse_element();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
				Contract__c = con.Id, 
				DANumber__c = 12345.00,
				Fiscal_Year__c = 'FY17', 
				Type__c = 'TE',
				Status__c = 'Ativo'
				);
		insert conDA;
 //[SELECT Contract__c,DANumber__c,Fiscal_Year__c,Status__c,Type__c,Value__c FROM LAT_ContractDA__c where contract__c =: contractId and Status__c = 'Ativo' order by createddate desc ];

		LAT_ContractDAHandlerInterface.cancelDA(con.Id);
		Test.stopTest();
	}

	@isTest static void test_method_three(){


        Group gp = [select id from group where developername = 'LAT_BR_ContractTrade'];
        GroupMember gm = new GroupMember();
        gm.GroupId = gp.Id;
        gm.UserOrGroupId = UserInfo.getUserId();
        insert gm;



        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
			Test.startTest();


			LAT_ContractDAHandlerInterface handler = new LAT_ContractDAHandlerInterface();
			
			
			
			//Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
			//String conId = con.Id;
			//LAT_ContractDAHandlerInterface.cancelDA(conId);
			LAT_ContractDAHandlerInterface.sendTradeNotification('Test','<h1>Hola</h1>','test@zimmic.com');
			Test.stopTest();


	       }

  	 	//system.RunAs(u){
  	 		
	       	
			
			//LAT_ContractDAHandlerInterface.runApprovalProcess(con.Id);
			//handler.generateDA('123456', Date.today().year(),'1234232', 1000.00, 'DA');
		
		}

		/*@isTest static void test_method_three2() {


        Group gp = [select id from group where developername = 'LAT_BR_ContractTrade'];

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='testudc@yahoo.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc@yahoo.com');

  	 	system.RunAs(u){

	       	GroupMember gm = new GroupMember();
	        gm.GroupId = gp.Id;
	        gm.UserOrGroupId = UserInfo.getUserId();

	        insert gm;
    				
			Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
			LAT_Contract2__c con = LAT_ContractsWS_Test.getContractWithManager();
			con.Status__c = 'Ativo';
			insert con;

			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
			LAT_ContractDAHandlerInterface handler = new LAT_ContractDAHandlerInterface();
			Test.startTest();
			LAT_ContractDA__c conDA = new LAT_ContractDA__c(
				Contract__c = con.Id, 
				DANumber__c = 12345.00,
				Fiscal_Year__c = 'FY17', 
				Type__c = 'TE',
				Status__c = 'Ativo'
				);
			insert conDA;
			String conId = con.Id;
			//LAT_ContractDAHandlerInterface.cancelDA(conId );
			LAT_ContractDAHandlerInterface.sendTradeNotification('Test','<h1>Hola</h1>','test@zimmic.com');
			//LAT_ContractDAHandlerInterface.runApprovalProcess(con.Id);
			//handler.generateDA('123456', Date.today().year(),'1234232', 1000.00, 'DA');
		Test.stopTest();
		}
	}*/

	@isTest static void test_method_four() {
		Map<String,String> mapa = new Map<String,String>();
		mapa.put('ANY key', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		LAT_ContractDAHandlerInterface handler = new LAT_ContractDAHandlerInterface();
		User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
        LAT_ContractsWS_Test.setup(u);
        Test.startTest();
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		insert con;
		String conId = con.Id;
		LAT_ContractDAHandlerInterface.activateDeactivateDA('1','Test','Test', 'FY17', conId);
		//handler.generateDA('123456', Date.today().year(),'1234232', 1000.00, 'DA');
		Test.stopTest();
	}

	@isTest static void test_method_five() {
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
		mapa.put('ANY key', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		//LAT_PaymentCreateDA.WSCriarDA_ExecuteResponse_elementFuture c = new LAT_PaymentCreateDA.WSCriarDA_ExecuteResponse_elementFuture();
		//c.getValue();
		
		Test.stopTest();
	}
	@isTest static void test_method_six() {
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
		mapa.put('ANY key', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		System.continuation con = new System.Continuation(10);
		LAT_PaymentCreateDA.WSCriarDASoapBindingQSPort port = new LAT_PaymentCreateDA.WSCriarDASoapBindingQSPort();
		LAT_PaymentCreateDA.SDTDA  Sdtda = new LAT_PaymentCreateDA.SDTDA(); 
		port.Execute(1,1,Sdtda);
		Test.stopTest();
	}
	@isTest static void test_method_seven() {
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
		mapa.put('ANY key', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		System.continuation con = new System.Continuation(10);
		LAT_PaymentApproveReproveDA.WSAprovarReprovarDASoapBindingQSPort port = new LAT_PaymentApproveReproveDA.WSAprovarReprovarDASoapBindingQSPort();
		LAT_PaymentCreateDA.SDTDA  Sdtda = new LAT_PaymentCreateDA.SDTDA(); 
		port.Execute(1,1,'String Tdocod',1,'String Status','String Usuario');
		Test.stopTest();
	}
	@isTest static void test_method_eight() {
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
		mapa.put('Sdtmsg', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', '{"Sdtmsg":"TEST"}', mapa));
		//LAT_PaymentApproveReproveDA.WSAprovarReprovarDA_ExecuteResponse_elementFuture c = new LAT_PaymentApproveReproveDA.WSAprovarReprovarDA_ExecuteResponse_elementFuture();
		//c.getValue();
		
		Test.stopTest();
	}

	@isTest static void test_method_nine() {
		User u = LAT_ContractsWS_Test.getLAT_SystemAdminUser();
		System.runAs(u) {
			Test.startTest();
			Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
			LAT_CheckStatusPaymentMoneyWS.WSConsultarPagtoCheque_ExecuteResponse_element c = new LAT_CheckStatusPaymentMoneyWS.WSConsultarPagtoCheque_ExecuteResponse_element();
			LAT_CheckStatusPaymentMoneyWS.WSConsultarPagtoChequeSoapBindingQSPort port = new LAT_CheckStatusPaymentMoneyWS.WSConsultarPagtoChequeSoapBindingQSPort();
			//LAT_CheckStatusPaymentMoneyWS.SDTDA  Sdtda = new LAT_CheckStatusPaymentMoneyWS.SDTDA(); 
			port.Execute(1,81,'String Tdocod',1,1);
			
			Test.stopTest();
		}
	}


	@isTest static void test_method_ten() {
		User u = LAT_ContractsWS_Test.getLAT_SystemAdminUser();
		System.runAs(u) {
			Test.startTest();

			Map<String,String> mapa = new Map<String,String>();
			mapa.put('Sdtmsg', 'ANY value');
			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', '{"Sdtmsg":"TEST"}', mapa));
			LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProduto_Execute_element c = new LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProduto_Execute_element();
			LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProdutoSoapBindingQSPort port = new LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProdutoSoapBindingQSPort();
			LAT_CheckStatusPaymentProductWS.Produtos_ProdutosItem p = new  LAT_CheckStatusPaymentProductWS.Produtos_ProdutosItem();
			LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProduto_ExecuteResponse_element ele = new LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProduto_ExecuteResponse_element();
			LAT_CheckStatusPaymentProductWS.SdtMsg s = new LAT_CheckStatusPaymentProductWS.SdtMsg();
			//LAT_CheckStatusPaymentMoneyWS.SDTDA  Sdtda = new LAT_CheckStatusPaymentMoneyWS.SDTDA(); 
			port.Execute(1,81,'String Tdocod',1,1);
			
			Test.stopTest();
		}
	}

	@isTest static void test_method_eleven() {

		User u = LAT_ContractsWS_Test.getLAT_SystemAdminUser();
		LAT_ContractsWS_Test.setup(u);
		System.runAs(u) {
			Test.startTest();
			Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
			LAT_CheckPaymentStatusOnME_Scheduler sh1 = new LAT_CheckPaymentStatusOnME_Scheduler();
			String sch = '0 0 23 * * ?'; 
			system.schedule('Test Territory Check', sch, sh1); 

			
			Test.stopTest();
		}
	}


}