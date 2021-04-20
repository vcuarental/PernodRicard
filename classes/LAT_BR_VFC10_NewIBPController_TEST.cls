/************************************************************************************************************************
*                                         Company: ValueNet                                      						*
*-----------------------------------------------------------------------------------------------------------------------*
*           Test del controlador "LAT_BR_VFC10_NewIBPController" de la Visualforce page LAT_BR_VFP10_NewIBP             *
************************************************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 20/11/2016
*
********************************************************************************/
@IsTest
public with sharing class LAT_BR_VFC10_NewIBPController_TEST {
    static testMethod void UnitTest(){
        Utils.setMigrationDoneTest(false); 
    	
    	 Account acc = new Account(
	        RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
	        CNPJ__c = '02745728000178',
	        Name = 'test',
	        Overdue__c = true,
	        Type = 'Outros',
	        Corporate_Name__c = 'test',
	        Channel_Type__c = 'Indireto',
	        Channel__c = 'On Trade',
	        Segmentation_Type_on_trade__c = 'Mainstream',
	        Sub_Channel__c = 'Delicatessen',
	        AddressLine1_AR__c= 'test',
	        Shipping_Neighbourhood__c = 'test',
	        Revenue_Neighbourhood__c = 'test',
	        Billing_Neighbourhood__c ='test',
	        Shipping_Country__c ='test',
	        Revenue_Country__c ='test',
	        Billing_Country__c ='test',
	        LAT_BR_RegionalClientOnPremise__c = 'REG CO',
	        Status__c = 'Cliente cadastrado no JDE'
        );
		insert acc;
		
		LAT_Contract__c con = new LAT_Contract__c(
			Account__c = acc.id,
			Status__c = 'Não aprovado',
			LAT_BR_RealValidityDate__c = date.today(),
			RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract__c' + 'Alteracao_de_contrato_aprovada_On_Trade')
    	);
    	test.startTest();
        Utils.setMigrationDoneTest(false); 
    	
    	insert con;
    	
    	Investimento_Bonificacao_e_Pagamento__c Ibp = new Investimento_Bonificacao_e_Pagamento__c();
    	ApexPages.StandardController sTdController = new ApexPages.StandardController(Ibp);
    	LAT_BR_VFC10_NewIBPController testPage0 = new LAT_BR_VFC10_NewIBPController(sTdController);
    	
    	ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('Investimento_Bonificacao_e_Pagamento__c' + 'Dinheiro'));
    	ApexPages.currentPage().getParameters().put('retURL', '/'+con.Id);
    	LAT_BR_VFC10_NewIBPController testPage = new LAT_BR_VFC10_NewIBPController(sTdController);
    	
    	testPage.doNewPaga();
    	testPage.listWrapper[1].isCheckbox = true;
    	testPage.doDelete();
    	testPage.doSave();
    	
    	LAT_BR_VFC10_NewIBPController testPage2 = new LAT_BR_VFC10_NewIBPController(sTdController);
    	testPage2.ibp.Data_de_Previsao_do_Pagamento__c = date.today();
    	testPage2.listWrapper[0].libp.Finalidade__c = 'Contrato';
    	testPage2.doSave();
    	
    	test.stopTest();
    }
    static testMethod void UnitTestB(){
        Utils.setMigrationDoneTest(true); 
        
         Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            CNPJ__c = '02745728000178',
            Name = 'test',
            Overdue__c = true,
            Type = 'Outros',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Indireto',
            Channel__c = 'On Trade',
            Segmentation_Type_on_trade__c = 'Mainstream',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            LAT_BR_RegionalClientOnPremise__c = 'REG CO',
            Status__c = 'Cliente cadastrado no JDE'
        );
        insert acc;
        
        LAT_Contract__c con = new LAT_Contract__c(
            Account__c = acc.id,
            Status__c = 'Não aprovado',
            LAT_BR_RealValidityDate__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract__c' + 'Alteracao_de_contrato_aprovada_On_Trade')
        );
        test.startTest();
        Utils.setMigrationDoneTest(true); 
        
        insert con;
        
        Investimento_Bonificacao_e_Pagamento__c Ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ApexPages.StandardController sTdController = new ApexPages.StandardController(Ibp);
        LAT_BR_VFC10_NewIBPController testPage0 = new LAT_BR_VFC10_NewIBPController(sTdController);
        
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('Investimento_Bonificacao_e_Pagamento__c' + 'Dinheiro'));
        ApexPages.currentPage().getParameters().put('retURL', '/'+con.Id);
        LAT_BR_VFC10_NewIBPController testPage = new LAT_BR_VFC10_NewIBPController(sTdController);
        
        testPage.doNewPaga();
        testPage.listWrapper[1].isCheckbox = true;
        testPage.doDelete();
        testPage.doSave();
        
        LAT_BR_VFC10_NewIBPController testPage2 = new LAT_BR_VFC10_NewIBPController(sTdController);
        testPage2.ibp.Data_de_Previsao_do_Pagamento__c = date.today();
        testPage2.listWrapper[0].libp.Finalidade__c = 'Contrato';
        testPage2.doSave();
        
        test.stopTest();
    }
}