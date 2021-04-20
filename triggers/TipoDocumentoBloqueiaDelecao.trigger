/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
********************************************************************************
* Bloqueia exclusão de tipo de pagamento quando o contrato estiver ATIVO ou EM 
* PROCESSO.
* 
* NAME: TipoDocumentoBloqueiaDelecao.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 25/10/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 09/01/2013
*******************************************************************************/
trigger TipoDocumentoBloqueiaDelecao on Tipo_de_Documento__c (before delete) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variáveis
    List< Tipo_de_Documento__c > listTipo = new List< Tipo_de_Documento__c >();
    List< String > listIdContrato = new List< String >();
    List< LAT_Contract__c > listContrato = new List< LAT_Contract__c >();
    Map< String, LAT_Contract__c > mapContrato = new Map< String, LAT_Contract__c >();
    Set< Id > setRecTypeLatCon = new Set< Id >();
    Id idRectypeTD = RecordTypeForTest.getRecType('Tipo_de_Documento__c', 'Tipo_de_Documento');
    
    //Recupera ids dos tipos de registro
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
    
    
    for(Tipo_de_Documento__c t : trigger.old ){
        if( t.RecordTypeId == idRectypeTD ){
            listIdContrato.add( t.LAT_Contract__c );
            listTipo.add( t );
        }
    }
    //Recupera objetos do tipo LAT_Contract__c com determinados tipos de status
    listContrato = [SELECT Id, Status__c 
                           FROM LAT_Contract__c 
                           WHERE Id =: listIdContrato
                           AND RecordTypeId =: setRecTypeLatCon
                           AND ( Status__c = 'Ativo' OR Status__c = 'Em aprovação' 
                                 OR Status__c = 'Aditado' OR Status__c = 'Cancelado' ) ];
    
    if( listContrato.size() > 0 ){
      for(LAT_Contract__c c : listContrato ){
            mapContrato.put( c.Id, c );   
      }
      
      for(Tipo_de_Documento__c t : listTipo ){
        LAT_Contract__c lCon = mapContrato.get( t.LAT_Contract__c );
        if( lCon == null ) continue;
        
        t.addError('Não é possível excluir Tipo de Pagamento com status do Contrato ATIVO/EM APROVAÇÃO.');
      }
    }
 }
}