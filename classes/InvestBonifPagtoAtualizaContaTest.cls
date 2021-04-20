/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe InvestBonifPagtoAtualizaConta
* NAME: InvestBonifPagtoAtualizaContaTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 30/10/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                         DATE: 15/01/2013
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 20/11/2016
*
********************************************************************************/

@isTest
private class InvestBonifPagtoAtualizaContaTest {

    static testMethod void myUnitTest() 
    {
        Utils.setMigrationDoneTest(false); 
        
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        
        //Cria nova UDC
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        Account lAcc = new Account();
        lAcc.Name = 'Teste';
        lAcc.Revenue_UF__c = 'SP';
        lAcc.Corporate_Name__c = 'Teste';
        lAcc.Status__c = 'Cliente cadastrado no JDE';
        lAcc.CNPJ__c = '65746267000178';
        lAcc.Regional__c = regional.id;
        lAcc.RecordTypeId = idRecTypeAcc;
        lAcc.Segmentation_Type_on_trade__c = 'Bar';
        lAcc.Rating = 'Cliente';
        //insert lAcc;
        try{insert lAcc;}catch(Exception e){}
        
        LAT_Contract__c lContrato = new LAT_Contract__c();
        lContrato.Account__c = lAcc.id;
        lContrato.Status__c = 'Em elaboração';
        lContrato.StartDate__c = System.today();
        lContrato.ContractTerm__c = 12;
        lContrato.trigger_on__c = true;
        lContrato.RecordTypeId = idrecTypeLatCon;
        lContrato.ROI_Comentarios_Negativo__c = 'teste';
        //insert lContrato;
        try{insert lContrato;}catch(Exception e){}
        
        Investimento_Bonificacao_e_Pagamento__c IBP = new Investimento_Bonificacao_e_Pagamento__c();
        IBP.LAT_Contract__c = lContrato.Id;
        IBP.Data_de_Previsao_do_Pagamento__c = System.today() ;
        IBP.Finalidade__c = 'Contrato';
        IBP.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        //insert IBP;
        //try{insert IBP;}catch(Exception e){}
    }

    static testMethod void myUnitTestB() 
    {
        Utils.setMigrationDoneTest(true); 
        
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        
        //Cria nova UDC
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        Account lAcc = new Account();
        lAcc.Name = 'Teste';
        lAcc.Revenue_UF__c = 'SP';
        lAcc.Corporate_Name__c = 'Teste';
        lAcc.Status__c = 'Cliente cadastrado no JDE';
        lAcc.CNPJ__c = '65746267000178';
        lAcc.Regional__c = regional.id;
        lAcc.RecordTypeId = idRecTypeAcc;
        lAcc.Segmentation_Type_on_trade__c = 'Bar';
        lAcc.Rating = 'Cliente';
        //insert lAcc;
        try{insert lAcc;}catch(Exception e){}
        
        LAT_Contract__c lContrato = new LAT_Contract__c();
        lContrato.Account__c = lAcc.id;
        lContrato.Status__c = 'Em elaboração';
        lContrato.StartDate__c = System.today();
        lContrato.ContractTerm__c = 12;
        lContrato.trigger_on__c = true;
        lContrato.RecordTypeId = idrecTypeLatCon;
        lContrato.ROI_Comentarios_Negativo__c = 'teste';
        //insert lContrato;
        try{insert lContrato;}catch(Exception e){}
        
        Investimento_Bonificacao_e_Pagamento__c IBP = new Investimento_Bonificacao_e_Pagamento__c();
        IBP.LAT_Contract__c = lContrato.Id;
        IBP.Data_de_Previsao_do_Pagamento__c = System.today() ;
        IBP.Finalidade__c = 'Contrato';
        IBP.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        //insert IBP;
        //try{insert IBP;}catch(Exception e){}
    }
}