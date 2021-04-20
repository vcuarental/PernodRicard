/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* 
*
* NAME: PagamentoDeletaPVTest.cls
* AUTHOR: ROGÉRIO ALVARENGA                         DATE: 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*
* AUTHOR: CARLOS CARVALHO                           DATE: 22/01/2013
* DESC: INSERIDO CAMPO "NAME" NO SELECT DE LAT_Contract__c
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/
public with sharing class ResumoCliente {
  
  private static final Integer DAYS_OF_END = 90;
      
  public Case[] Casos {get;set;}
  public LAT_Case__c[] LAT_Casos {get;set;}
  public Titulos__c[] Titulos {get;set;}
  public LAT_Contract__c[] Contratos {get;set;}
  public Opportunity[] Oportunidade {get;set;}
  public LAT_Opportunity__c[] LAT_Oportunidade {get;set;}
  public boolean inadimplente{get;set;}
  public Integer vencimentoLimit{get;set;}
  
  //MIGRATED 02/11/2016 
  public ResumoCliente( ApexPages.StandardController controller )
  {
    Id idRecTypeTit = RecordTypeForTest.getRecType( 'Titulos__c', 'BRA_Standard' );
    Id lContaId = getAccountId( controller.getRecord().Id );
    
    //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
    Set< Id > setRecTypeLatCon = new Set< Id >();
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
    
    
    // Solicitações e Reclamações
    //MIGRATED 02/11/2016
    if(!Utils.wasMigrationDone('1')){
      Casos = [ Select CaseNumber, type, reason, CreatedDate, Status, Subject from Case 
              where AccountId =: lContaId and RecordType.DeveloperName = 'Solicitacoes_e_Reclamacoes' 
              and IsClosed = false order by CaseNumber];
    }else {
      LAT_Casos = [ Select LAT_CaseNumber__c, LAT_type__c, LAT_reason__c, CreatedDate, LAT_Status__c, LAT_Subject__c from LAT_Case__c 
              where LAT_Account__c =: lContaId and RecordType.DeveloperName = 'Solicitacoes_e_Reclamacoes' 
              and LAT_IsClosed__c = false order by LAT_CaseNumber__c];
    }
              
    Titulos = [ SELECT Status__c, id, Name, numeroDocumento__c, tipoDocumento__c, parcela__c, 
                dataVencimentoAtual__c, dataVencimentoOriginal__c, diasAtraso__c, valorSaldo__c, 
                valorOriginalTitulo__c FROM Titulos__c WHERE Cliente__c =: lContaId 
                AND RecordTypeId =: idRecTypeTit ];
    
    // Contratos Próximos ao Vencimento
    vencimentoLimit = DAYS_OF_END;
    Date lHoje = Date.today();
    Date lDataLimite = lHoje.addDays( DAYS_OF_END );
    Contratos = [ SELECT id, ContractNumber__c, EndDate__c, Name, Status__c, Description__c FROM LAT_Contract__c WHERE Account__c =: lContaId 
                  AND Prazo_indeterminado__c = false AND EndDate__c >= :lHoje AND EndDate__c <= :lDataLimite 
                  AND status__c='Ativo' AND RecordTypeId =: setRecTypeLatCon ];
                  
    // Pedidos 
    carregaOportunidade( lContaId );
    
    // Contas
    List< Account > lAccList = [ select Overdue__c from Account where id =: lContaId limit 1 ];
    
    inadimplente = lAccList.size() > 0 && lAccList[ 0 ].Overdue__c;
  }
  
  private Id getAccountId( Id aVisitaId )
  {
    List< Visitas__c > lVisitas = [ Select Conta__c from Visitas__c where id=:aVisitaId limit 1 ];
    return lVisitas[ 0 ].Conta__c;
  }
  
  private void carregaOportunidade( Id aContaId )
  {
    if(!Utils.wasMigrationDone('1')){    
      Oportunidade = [ Select id, NR_order_JDE__c, StageName, Name, Amount from Opportunity
                       where AccountId =: aContaId and isClosed = false ];
      List< String > lIDList = new List< String >();
      for ( Opportunity lOpp : Oportunidade )
        lIDList.add( lOpp.id );
        
      List< OpportunityLineItem > lItemList = [ select OpportunityId from OpportunityLineItem 
                                                where OpportunityId =:lIDList and cd_line_status__c <> '999' ];
      Set< String > lOppAbertas = new Set< String >();
      for ( OpportunityLineItem lItem : lItemList )
        lOppAbertas.add( lItem.OpportunityId );
      
      for ( Integer i=0; i<Oportunidade.size(); )
      {
        if ( !lOppAbertas.contains( Oportunidade[ i ].id ) )
          Oportunidade.remove( i );
        else i++;
      }
    } 
    //MIGRATED 07/11/2016 
    else {
      LAT_Oportunidade = [ Select id, LAT_NROrderJDE__c, LAT_StageName__c, Name, LAT_Amount__c from LAT_Opportunity__c
                       where LAT_Account__c =: aContaId and LAT_IsClosed__c = false ];
      List< String > lIDList = new List< String >();
      for ( LAT_Opportunity__c lOpp : LAT_Oportunidade )
        lIDList.add( lOpp.id );
        
      List< LAT_OpportunityLineItem__c > lItemList = [ select LAT_Opportunity__c from LAT_OpportunityLineItem__c 
                                                where LAT_Opportunity__c =:lIDList and LAT_CdLineStatus__c <> '999' ];
      Set< String > lOppAbertas = new Set< String >();
      for ( LAT_OpportunityLineItem__c lItem : lItemList )
        lOppAbertas.add( lItem.LAT_Opportunity__c );
      
      for ( Integer i=0; i<LAT_Oportunidade.size(); )
      {
        if ( !lOppAbertas.contains( LAT_Oportunidade[ i ].id ) )
          LAT_Oportunidade.remove( i );
        else i++;
      }      
    }
  }
  
}