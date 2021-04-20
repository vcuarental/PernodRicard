@isTest
private class LAT_Deposit_Test {
	
	@isTest static void test_method_one() {

        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
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
        
        system.Test.startTest();
        
        RCP_Receipt_ARG__c rece = new RCP_Receipt_ARG__c(
            Account_AR__c = acc.id,
            LAT_AR_DepositAccountType__c = 'C',
            RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR')
        );
        
        insert rece;

        DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(
            ReceiptNo_AR__c = rece.id,
            Amount_AR__c = 123,
            AccType_AR__c = 'Bank Account',
            Name = '2',
            RecordTypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );
        
        insert dep;
        
        rece.LAT_AR_DepositAccountType__c = 'R';
        //update rece;
        
        rece.LAT_AR_DepositAccountType__c = 'c';
		 
        //update rece;


        List<DPT_Deposit_ARG__c> lista = new List<DPT_Deposit_ARG__c>();
        lista.add(dep);
        LAT_Deposit.createDeposit(lista);
        LAT_Deposit.validateDeposit(lista,dep);
        LAT_Deposit.deleteDeposit(lista);
        LAT_Deposit.updateBankSlipNo(lista);

       Map<id,DPT_Deposit_ARG__c> mapa = new Map<id,DPT_Deposit_ARG__c>();
       mapa.put(dep.Id, dep);
       LAT_Deposit.DepositCheckPrintStatus(mapa);
		// Implement test code
	} 


    @isTest static void test_method_two() {
        

        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario;
        System.runAs(usuario) {
            new LAT_MX_VFP10_Links_COntroller();
            Utils.setMigrationDoneTest(true); 
            new LAT_MX_VFP10_Links_COntroller();
        }         
    }

        @isTest static void test_method_three() {
        
        User vendedor = [SELECT id FROM User WHERE Profile.Name = 'LAT_AR2_Vendedor' AND IsActive=true LIMIT 1];
        System.runAs(vendedor){
            Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
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
            
            Test.startTest();
            
            RCP_Receipt_ARG__c rece = new RCP_Receipt_ARG__c(
                Account_AR__c = acc.id,
                LAT_AR_DepositAccountType__c = 'C',
                RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR')
            );
            
            insert rece;

            DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(
                ReceiptNo_AR__c = rece.id,
                Amount_AR__c = 123,
                AccType_AR__c = 'Bank Account',
                Name = '2',
                From_Document__c = true,
                RecordTypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
            );
            
            insert dep;
            dep.Date_AR__c = Date.today();
            try{update dep;}catch(Exception e){}
            dep.Branch_AR__c = 'R';
            try{update dep;}catch(Exception e){}
            dep.Bank_AR__c = '014';
            try{update dep;}catch(Exception e){}

            dep.Name = 'sssss';
            try{update dep;}catch(Exception e){}
            dep.AccType_AR__c = 'R';
            try{update dep;}catch(Exception e){}

        
        
            Test.stopTest();
        }
    } 

	
}