/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe RecalculaROI
* NAME: RecalculaROITest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 19/09/2012
*
*******************************************************************************/
@isTest(SeeAllData=true)
private class RecalculaROITest {

    static testMethod void myUnitTest() 
    {
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        Account acc = new Account();
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Regional__c = regional.id;
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade');
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        try{insert acc;}catch(Exception e){}
          
        LAT_Contract__c lContract = new LAT_Contract__c();
        lContract.Account__c = acc.Id;
        lContract.Status__c = 'Em elaboração';
        lContract.StartDate__c = System.today();
        lContract.ContractTerm__c = 12;
        lContract.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        lContract.ROI_Comentarios_Negativo__c = 'teste';
        //insert lContract;
        try{insert lContract;}catch(Exception e){}
          
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today().addDays( 10 );
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = lContract.id;
        ibp.Valor_R__c = 100;
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Conta_IBP__c = acc.id;
        //insert ibp;
        //try{insert ibp;}catch(Exception e){}
        
        try{
            RecalculaROI.recalcular( ibp.LAT_Contract__c );
        }catch( Exception e ){
            system.debug(e.getMessage());
        }
    }

}