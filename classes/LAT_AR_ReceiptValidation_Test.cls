@isTest
private class LAT_AR_ReceiptValidation_Test {
	
	 @testSetup static void setup() {
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        Account acc = new Account(
            RecordTypeId =  Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            CNPJ__c = '20354266645',
            Name = 'testAccount',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test'
        );
        insert acc;
	}
	
	@isTest static void test_method_1() {
		Account acc = [SELECT Id, Name FROM Account limit 1];
        RCP_Receipt_ARG__c receipt = LAT_AR_WS01_ReceiptHandlerInterface_TEST.createReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C');
        receipt.RedemptionNo_AR__c = '1100004444';
        insert receipt;
        Test.startTest();  
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = 'https://na11.salesforce.com';  // sample Endpoint
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        LAT_AR_ReceiptValidation.ValidarRecibosRendidos();
        LAT_AR_RestBTN01_RCPRedeemedBtn.ValidarRecibosRendidos();
        LAT_AR_RestBTN01_RCPRedeemedBtn.Post(new List<String>{receipt.Id});
        Test.stopTest();  
	}
	
	@isTest static void test_method_2() {
		Account acc = [SELECT Id, Name FROM Account limit 1];
        RCP_Receipt_ARG__c receipt = LAT_AR_WS01_ReceiptHandlerInterface_TEST.createReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'T');      
        insert receipt;
        Test.startTest();
        LAT_AR_ReceiptValidation.ValidarRecibosRendidos();
        LAT_AR_RestBTN01_RCPRedeemedBtn.ValidarRecibosRendidos();
        Test.stopTest();

	}

	@isTest static void test_method_3() {
		Account acc = [SELECT Id, Name FROM Account limit 1];
        RCP_Receipt_ARG__c receipt = LAT_AR_WS01_ReceiptHandlerInterface_TEST.createReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'R');      
        insert receipt;
        
        DPT_Deposit_ARG__c deposit = new DPT_Deposit_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 123,
            AccType_AR__c = 'Collection Bank Account',
            Date_AR__c  =   Date.Today(),
            Name = '2'
        );       
        insert deposit;  
        Test.startTest();
        LAT_AR_ReceiptValidation.ValidarRecibosRendidos();
        LAT_AR_RestBTN01_RCPRedeemedBtn.ValidarRecibosRendidos();
        Test.stopTest();
	}

    @isTest 
    static void test_method_4() {

        ApexPages.StandardController sc = new ApexPages.standardController(new LAT_Receipt_Range__c());
        LAT_AR_CreateReceiptRange cont = new LAT_AR_CreateReceiptRange(sc);
        User vendedor = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'LAT_AR2_Vendedor' LIMIT 1];
        LAT_GeneralConfig__c cs = new LAT_GeneralConfig__c(
              Name = 'AR_PROFILES_CREATE_RANGE',
            LAT_Value__c = 'LAT_AR2_Vendedor');
        insert cs;
        LAT_GeneralConfig__c cs2 = new LAT_GeneralConfig__c(
              Name = 'RECEIPT_NRO_APP',
            LAT_Value__c = '1000');
        insert cs2;
        System.runAs(vendedor) {
            cont.createRange();
            LAT_AR_CreateReceiptRange.inProgress = null;
            cont.currentRange.OwnerId = vendedor.Id;
            cont.createRange();
        }
        cont.createRange();

    }

    @isTest 
    static void test_method_5() {

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<LAT_Receipt_Range__c>());
        LAT_ReceiptRange_ListViewCont cont = new LAT_ReceiptRange_ListViewCont(sc);
        cont.goToNuevoRango();
        

    }

    @isTest 
    static void test_method_6() {
        Account acc = [SELECT Id, Name FROM Account limit 1];
        RCP_Receipt_ARG__c receipt = LAT_AR_WS01_ReceiptHandlerInterface_TEST.createReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'R');      
        insert receipt;
        Test.startTest();
        DPT_Deposit_ARG__c deposit = new DPT_Deposit_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 123,
            AccType_AR__c = 'Collection Bank Account',
            Date_AR__c  =   Date.Today(),
            Name = '2000'
        );       
        insert deposit;

        Titulos__c titulo = new Titulos__c(
            Internal_id_pk__c = 'TEST-99-000-000-000',
            Cliente__c = acc.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            NetSRReceipts_AR__c = 0,
            valorSaldo__c = 10,
            PaymentID_AR__c = 2000,
            TipoDocumento__c = 'RU'
        );
        insert titulo;

        Map<Id, List<Titulos__c>> mapTitulosByAccount = new Map<Id, List<Titulos__c>>();
        mapTitulosByAccount.put(acc.Id, new List<Titulos__c>{titulo});
        Map<Id, DPT_Deposit_ARG__c> mapDepositsById = new Map<Id, DPT_Deposit_ARG__c>();
        mapDepositsById.put(deposit.Id, deposit);

        receipt = [SELECT Id, Account_AR__c, LAT_ValidationStatus__c, Validation_Error_Message__c, Discount_AR__c, Comercial_Discount__c, LAT_AR_DepositAccountType__c,
                                                (SELECT Id, Name, Amount_AR__c FROM Deposits__r),
                                                (SELECT Id, PaymentID_AR__c, Amounttoapply_AR__c, TipoDocumento_AR__c FROM Documents__r WHERE TipoDocumento_AR__c = 'RU')
                                                FROM RCP_Receipt_ARG__c LIMIT 1];

        List<Titulos__c> titulos = [SELECT Id, Cliente__c, PaymentID_AR__c, NetOpenBalance_AR__c, NetSRReceipts_AR__c, Internal_id_pk__c  FROM Titulos__c];                                        
        LAT_AR_ReceiptValidation.setRUDeposits(receipt, mapTitulosByAccount, mapDepositsById, titulos, new List<LAT_RUDeposit__c>());
        
        LAT_AR_ReceiptValidation.ValidarRecibosRendidos();
        LAT_AR_RestBTN01_RCPRedeemedBtn.ValidarRecibosRendidos();
        Test.stopTest();
    }

}