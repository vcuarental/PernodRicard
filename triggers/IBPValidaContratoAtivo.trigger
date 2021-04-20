/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Quando um IBP é atualizado ou inserido o contrato não pode estar em aprovação 
* ou ativo.
*
* NAME: IBPValidaContratoAtivo.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 22/10/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
********************************************************************************/
trigger IBPValidaContratoAtivo on Investimento_Bonificacao_e_Pagamento__c (before insert, before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //DECLARAÇÃO DEVARIÁVEIS
    List< String > listIdContrato = new List< String >();
    List< Investimento_Bonificacao_e_Pagamento__c > listIBP = new List< Investimento_Bonificacao_e_Pagamento__c >();
    List< LAT_Contract__c > listContrato = new List< LAT_Contract__c >();
    Map< String, LAT_Contract__c > mapContrato;
    Set< Id > setRecTypeInv = new Set< Id >();
    Set< Id > setRecTypeLatCon = new Set< Id >();
    
    //Recupera tipos de registro de Investimento_Bonificacao_e_Pagamento__c
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
    
    //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
    
    for(Investimento_Bonificacao_e_Pagamento__c i: trigger.new ){
      if( setRecTypeInv.contains( i.RecordTypeId ) ){
          listIdContrato.add( i.LAT_Contract__c );
          listIBP.add( i );
      }
    }
    
    listContrato = [SELECT Id, Status__c FROM LAT_Contract__c 
        WHERE Id =: listIdContrato AND (Status__c = 'Ativo' OR Status__c = 'Em aprovação') 
        AND RecordTypeId =: setRecTypeLatCon];
    
    if( listContrato != null && listContrato.size() > 0 ){
      mapContrato = new Map< String, LAT_Contract__c >();
        for( LAT_Contract__c c : listContrato ){
          mapContrato.put( c.Id , c );
        }
        for( Investimento_Bonificacao_e_Pagamento__c inv : listIBP ){
          LAT_Contract__c lCon = mapContrato.get( inv.LAT_contract__c );
          if( lCon == null ) continue;
          if( !inv.CasoEspecial__c && inv.Status_da_Verba__c != 'Encerrada'  && !inv.LAT_isAdmin__c){
            inv.addError('Não é possível Inserir/editar registros com o status do contrato = Ativo ou Em Aprovação');
          }
            else{
              inv.CasoEspecial__c = false;
            }
        }
    }
 }
}