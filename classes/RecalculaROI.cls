/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz alteração no IBP para disparar as suas triggers de recalculo
* e em cascata a trigger de recalculo do contrato
* NAME: recalcular.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 22/08/2012
*
*******************************************************************************/
global class RecalculaROI {
  
  webservice static void recalcular( String aContractId )
  {
    Set< Id > setRecTypeIBP = new Set< Id >();
    setRecTypeIBP.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' ));
    setRecTypeIBP.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ));
    
    List< Investimento_Bonificacao_e_Pagamento__c > lIBPIds = [ SELECT id FROM Investimento_Bonificacao_e_Pagamento__c 
                                                                 WHERE LAT_Contract__c = :aContractId AND RecordTypeId =: setRecTypeIBP];
            
    update lIBPIds;
  }


}