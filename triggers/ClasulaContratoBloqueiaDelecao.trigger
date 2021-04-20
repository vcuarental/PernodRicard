/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
********************************************************************************
* Bloqueia exclusão de clasula de contrato quando o contrato estiver ATIVO ou EM 
* PROCESSO.
* 
* NAME: ClasulaContratoBloqueiaDelecao.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 25/10/2012
*
*
* MAINTENANCE: INSERIDO VARIÁVEL lList QUE ARMAZENA O ID DOS TIPOS DE REGISTRO.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
*******************************************************************************/
trigger ClasulaContratoBloqueiaDelecao on Cl_usulas_do_Contrato__c (before delete) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variável
    List< Cl_usulas_do_Contrato__c > listCla = new List< Cl_usulas_do_Contrato__c >();
    List< String > listIdContrato = new List< String >();
    List< LAT_Contract__c > listContrato = new List< LAT_Contract__c >();
    Map< String, LAT_Contract__c > mapContrato = new Map< String, LAT_Contract__c >();
    List< Id > lList = new List< Id >();
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
    
    for(Cl_usulas_do_Contrato__c cl : trigger.old ){
        listIdContrato.add( cl.Contrato__c );
        listCla.add( cl );
    }
    
    listContrato = [Select Id, Status__c From LAT_Contract__c Where Id =: listIdContrato
                        AND RecordTypeId =: lList
                        AND ( Status__c = 'Ativo' OR Status__c = 'Em aprovação' OR Status__c = 'Aditado' 
                        OR Status__c = 'Cancelado'  )];
    
    if( listContrato.size() > 0 ){
        for(LAT_Contract__c c : listContrato ){
            mapContrato.put( c.Id, c );     
        }
        
        for(Cl_usulas_do_Contrato__c cl : listCla ){
            LAT_Contract__c lCon = mapContrato.get( cl.Contrato__c );
            if( lCon == null ) continue;
            
            cl.addError('Não é possível excluir Clásula de contrato com status do contrato ATIVO/EM PROCESSO.');
        }
    } 
 } 
}