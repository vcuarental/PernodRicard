/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* De acordo com parametros de caso o objeto contrato é alterado.
* NAME: CasoTratamento.trigger
* AUTHOR:                                           DATE: 11/06/2012

* E.S. 12/06/2014 
* Cambio: Linea 131 agregada por RFC Segmentacion BR
* MAINTENANCE: INSERIDO variável setRecType.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
*******************************************************************************/
trigger CasoTratamento on Case (after update ) {
  String i = '';
/*
//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

    system.debug('ENTRO AL TRIGGER');
  
  Id lRecOnTrade = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato' );
  Id lRecOffTrade = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo' );
  Set< Id > setRecType = new Set< Id >();
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Alteracao_rota_de_promotor') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Alteracao_cadastro_de_clientes') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Cancelar_D_A_no_sistema_ME') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Cliente_inadimplente') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_aprovacao_de_proposta') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_da_diretoria') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_de_distrato_procurador') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_de_distrato_diretoria'));
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_do_procurador') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Negociacao_de_cancelamento') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Processo_de_prorrogacao') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Proposta_de_renovacao') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_assinatura_de_distrato_do_cliente') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_assinatura_de_prorrogacao_de_contrato') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_assinatura_prorroga_o_do_cliente') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_coleta_de_assinatura_do_cliente') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_coleta_de_assinatura_do_cliente_off') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_conferencia_de_documentacao') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_entrega_do_contrato') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_nao_renovacao_de_contrato') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_renovacao_de_contrato') );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Gerar_D_A_no_sistema_ME' ) );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Inserir_o_Tipo_de_Verba' ) );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Justificativa_de_inadimplencia' ) );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Novo_cadastro_de_cliente' ) );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'nao_renovacao' ) );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Proposta_de_pagamento' ) );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Sem_proposta_de_pagamento' ) );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Solicitacoes_e_Reclamacoes' ) );
  setRecType.add( RecordTypeForTest.getRecType('Case', 'Termino_de_contrato' ) );
  
  Id idRecTypeOnContNaoAprovado = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'OnTradeContratoNaoAprovado' );
  
  List< String > lACCIds = new List< String >();
  List< String > lContractIds = new List< String >();
  List< String > lOwnerIds = new List< String >();
  integer j = 0;
  
  for ( Case c : trigger.new )
  {
    if( setRecType.contains( c.RecordTypeId)){
        if ( !c.IsClosed || trigger.old[j].isClosed ) continue;
        if ( c.AccountId != null )
          lACCIds.add( c.AccountId );
        if ( c.LAT_Contract__c != null )
          lContractIds.add( c.LAT_Contract__c );
        lOwnerIds.add( c.OwnerId );
        j++;
    }
  }
  
  if( lOwnerIds.size() == 0 ) return;
  
  // Account 
  List< Account > lAccUpdateList = new List< Account >();
  List< Account > lAccList = [Select Id, Checked_over_Sales_Administration__c, 
                    Checked_over_Comptroller__c, Checked_over_Credit_and_collection__c, 
                    Checked_over_Commercial_Planning__c, Channel__c 
                    from Account where ID = :lACCIds ];
  Map< String, Account > lAccMap = new Map< String, Account >();
  for ( Account c : lAccList )
    lAccMap.put( c.Id, c );
  
  // LAT_Contract__c
  List< LAT_Contract__c > lContractUpdateList = new List< LAT_Contract__c >();
  List< LAT_Contract__c > lContractList = [Select Id, Status__c, Status_do_processo__c, 
                Aprovado_pelo_cliente__c,Encaminhado_para_assinatura__c, Ass_cliente__c,
                Assinatura_coordenador__c, Assinatura_procurador_regional__c, ContractTerm__c,
                Signatario_da_empresa__c, Signatario_do_cliente__c, CompanySigned__c,
                StartDate__c, Data_de_inicio_da_vigencia_da_alteracao__c, CustomerSignedId__c,
                Obs_signatarios__c, CustomerSignedDate__c, CompanySignedDate__c,
                Data_de_vigencia_do_distrato__c, Gerente__c,
                Distrato_Signatario_da_empresa_2__c
                from LAT_Contract__c where ID = :lContractIds ];
  Map< String, LAT_Contract__c > lContractMap = new Map< String, LAT_Contract__c >();
  for ( LAT_Contract__c c : lContractList )
    lContractMap.put( c.ID, c );
    
  // Queue
  List< Queuesobject > lQueueList = [SELECT Id, queue.Name, QueueId FROM QueueSobject WHERE QueueId = :lOwnerIds ];
  Map< String, String > lQueueMap = new Map< String, String >();
  for ( Queuesobject q : lQueueList )
    lQueueMap.put( q.QueueId, q.queue.name );
  
  integer lLen = trigger.new.size();
  for ( Integer i=0; i<lLen; i++ )
  {
    Case c = trigger.new[ i ];
    Case o = trigger.old[ i ];
    if ( !c.IsClosed || o.isClosed ) continue;
    String NomeFila = lQueueMap.get( c.OwnerId );
    Account a = lAccMap.get( c.AccountId );
    LAT_Contract__c ct = lContractMap.get( c.LAT_Contract__c );
    
// CLIENTES
    // Processo de clientes: se a demanda foi fechada, marca campos checkbox correnpondentes na conta.
    // para cada tipo de caso aberto pelo processo de cad clientes, marca o checkbox correspondente.
    if ( c.Type == 'Cadastro de clientes' && c.Reason == 'Análise/complementação de dados' )
    {
      if ( NomeFila == 'Customer service' ) 
      { 
        a.Checked_over_Sales_Administration__c = true;
        lAccUpdateList.add( a );
      } 
      else if ( NomeFila == 'Crédito e cobrança' )
      { 
        a.Checked_over_Credit_and_collection__c = true;
        a.Status__c = 'Em aprovação - Financeiro';
        lAccUpdateList.add( a );
      }
      else if ( NomeFila == 'Planejamento comercial' )
      {
        a.Checked_over_Commercial_Planning__c = true;
        a.Status__c = 'Em aprovação - Financeiro';
        lAccUpdateList.add( a );
      } 
      else if ( NomeFila == 'Controladoria' )
      { 
        a.Checked_over_Comptroller__c = true;
        lAccUpdateList.add( a );
      }
    }
    // Processo de alteração de cliente: Foi feito por workflow

// CONTRATOS
    // Processo de ASSINATURA DE CONTRATOS: se a demanda foi fechada, muda status do contrato na sequência abaixo
    // demandas fechadas
    
    system.debug('TYPE DE DEMANDA: ' + c.Type);
    system.debug('STATUS DE DEMANDA: ' + c.Status);
    system.debug('REASON DE DEMANDA: ' + c.Reason);
    
    boolean chgCT = false;
    if ( c.Type == 'Assinatura de contrato' )
    {
      // DEMANDA Aprovada.
      if ( c.Status == 'Aprovado' )
      {
        //Inserido 2 condições por solicitação do Eduardo - Carlos 12/06/2012
        if ( c.reason == 'Aprovação do cliente' && a.Channel__c == 'Off Trade' ) //Aprovação do Cliente e OFF TRADE
        {
          ct.Signatario_do_cliente__c  = c.Customer_Signatory_2__c ;
          ct.CustomerSigned__c         = c.Customer_Signatory__c ;
          ct.Obs_signatarios__c        = c.Note_signatories__c ;
          ct.CustomerSignedDate__c     = c.Customer_Signature_Date__c ; 
          ct.Status_do_processo__c     = 'Contrato assinado encaminhado para o Coordenador'; 
          ct.fase__c                   = 'Contrato';
          chgCT = true;
        }
        else if ( c.reason == 'Aprovação do cliente' && a.Channel__c == 'On Trade' ) //Aprovação do Cliente e ON TRADE
        {
          ct.Signatario_do_cliente__c  = c.Customer_Signatory_2__c ;
          ct.CustomerSigned__c         = c.Customer_Signatory__c ;
          ct.Obs_signatarios__c        = c.Note_signatories__c ;
          ct.CustomerSignedDate__c     = c.Customer_Signature_Date__c ; 
          ct.Status_do_processo__c     = 'Proposta aprovada pelo cliente'; 
          ct.fase__c                   = 'Contrato';
          chgCT = true;
        }
        else if ( c.reason == 'Coleta de assinatura do cliente' ) 
        {
          ct.Status_do_processo__c = 'Contrato assinado encaminhado para o Coordenador';
          ct.CustomerSignedDate__c = c.Customer_Signature_Date__c ;
          chgCT = true;
        }
      }
      
      // DEMANDA Reprovada.
      // JL 22/mai/2012
      if ( c.Status == 'Não aprovado' )
      {
        if ( c.reason == 'Aprovação do cliente' )
        {
            system.debug('ENTRO AL IF 2');
          ct.Aprovado_pelo_cliente__c = true;
          ct.Status_do_processo__c = 'Proposta não aprovada';
          ct.Status__c = 'Não aprovado';
          ct.RecordTypeId = idRecTypeOnContNaoAprovado;
          chgCT = true;
        }
        else if ( c.reason == 'Coleta de assinatura do cliente' )
        {
          system.debug('ENTRO AL IF');
          ct.Status_do_processo__c = 'Proposta não aprovada';
          ct.Status__c = 'Não aprovado';
          ct.RecordTypeId = idRecTypeOnContNaoAprovado;
          chgCT = true;
        }
      }
      
      // DEMANDA 'Solicitação de ajuste na proposta'.
      // JL 22/mai/2012
      if ( c.Status == 'Solicitação de ajuste na proposta' && c.reason == 'Aprovação do cliente' )
      {
        ct.Aprovado_pelo_cliente__c = true;
        ct.Status_do_processo__c = 'Estudo em elaboração';
        ct.fase__c = 'Estudo';
        chgCT = true;
      }
      
      // DEMANDA 'Fechado e resolvido'.
      // JL 22/mai/2012
      if ( c.Status == 'Fechado e resolvido' )
      {
        if ( c.reason == 'Conferência de contrato' ) 
        {
          ct.Status_do_processo__c = 'Encaminhado para o assistente da regional'; //Adicionado por carlos
          if ( ct.StartDate__c <= System.today() && ct.Status__c != 'Ativo' ) ct.Status__c = 'Ativo';//Adicionado por carlos
          else ct.Status__c = 'Aprovado';
          chgCT = true;
        }
        else if ( c.reason == 'Assinatura do procurador' ) 
        {
          ct.Status_do_processo__c = 'Encaminhado para o assistente de Trade ou Regional';  
          ct.Signatario_da_empresa__c = c.Company_Signatory__c;
          chgCT = true;
        }
        else if ( c.reason == 'Assinatura da diretoria' ) 
        {  
          ct.Status_do_processo__c = 'Assinado e encaminhado para assistente da regional';    
          ct.Signatario_da_empresa_2__c = c.Company_Signatory_2__c;
          chgCT = true;
        }
        else if ( c.reason == 'Encaminhar via assinada para o Consultor' ) 
        {
          ct.Status_do_processo__c = 'Contrato assinado encaminhado para Consultor';
          chgCT = true;
        }
        else if ( c.reason == 'Providenciar correções de documentação' )
        {
          ct.Status_do_processo__c = 'Contrato assinado encaminhado para o Coordenador';
          chgCT = true;
        }//Encaminhado para assinatura do cliente
        else if ( c.reason == 'Entregar contrato assinado ao cliente' )
        {
          ct.Status_do_processo__c = 'Processo finalizado';
          chgCT = true;
        }
      }
      
      // DEMANDA 'Encaminhado para correções'.
      // JL 22/mai/2012
      if ( c.Status == 'Encaminhado para correções' && c.Type == 'Assinatura de contrato' 
      && c.reason == 'Conferência de contrato' )
      {
        ct.Status_do_processo__c = 'Contrato devolvido para o Consultor';
        chgCT = true;  
      }
    }
    
    // Processo DE ALTERAÇÃO DE CONTRATO
    // demandas fechadas
    if ( c.Type == 'Alteração de contrato' )
    {
      // DEMANDA Aprovada JL 23/mai
      if ( c.Status == 'Aprovado' )
      {
        if ( c.reason == 'Impressão do aditamento' && a.Channel__c == 'On Trade' ) 
        {
          ct.Status_do_processo__c = 'Entregue para assinatura do cliente';
          ct.fase__c = 'Contrato';                                
          ct.Signatario_do_cliente__c = c.Customer_Signatory_2__c ;         // Rogerio 28/06/2012 12:10
          ct.CustomerSigned__c = c.Customer_Signatory__c ;
          ct.Obs_signatarios__c = c.Note_signatories__c ;
          chgCT = true;
        }
        else if ( c.reason == 'Assinatura de aditamento' )
        {
          ct.Status_do_processo__c = 'Encaminhado para o coordenador';
          if ( a.Channel__c == 'Off Trade' )
          {
            ct.Signatario_do_cliente__c = c.Customer_Signatory_2__c ;   // Rogerio 28/06/2012 12:10
            ct.CustomerSigned__c = c.Customer_Signatory__c ;
            ct.Obs_signatarios__c = c.Note_signatories__c ;
          }
          ct.CustomerSignedDate__c = c.Customer_Signature_Date__c;
          chgCT = true;
        }
      }
      else if ( c.Status == 'Não aprovado' ) // DEMANDA REprovada JL 22/mai/2012
      {
        /******************************************* NÂO APAGAR - EDUARDO AINDA VAI VALIDAR****************************
        if ( c.reason == 'Impressão do aditamento' && a.Channel__c == 'On Trade' )
        {
          ct.Status_do_processo__c = 'Estudo de alteração de contrato';
          ct.fase__c = 'Pré-estudo';
          ct.Status = 'Em elaboração';
          chgCT = true;
        } ******************************************* NÂO APAGAR - EDUARDO AINDA VAI VALIDAR****************************
        if ( c.reason == 'Impressão do aditamento' && a.Channel__c == 'On Trade' )
        {         
            ct.Status_do_processo__c = 'Proposta não aprovada';
          ct.Status__c = 'Não aprovado';
          ct.RecordTypeId = idRecTypeOnContNaoAprovado;
          chgCT = true;
        }
        else if ( c.reason == 'Assinatura de aditamento' && a.Channel__c == 'Off Trade' ) // Rogerio
        {         
          ct.Status_do_processo__c = 'Proposta não aprovada';
          ct.Status__c = 'Não aprovado';
          ct.RecordTypeId = idRecTypeOnContNaoAprovado;
          chgCT = true;
        }
      }
      else if ( c.Status == 'Encaminhado para correções' )
      {
        if ( a.Channel__c == 'Off Trade' && c.reason == 'Conferência de aditamento' ) // Rogerio
        {
          ct.Status_do_processo__c = 'Aditamento encaminhado para o consultor';
          chgCT = true;
        }
        else
          if ( a.Channel__c == 'On Trade' && c.reason == 'Conferência de aditamento' ) // Rogerio
          {
            ct.Status_do_processo__c = 'Entregue para assinatura do cliente';
            chgCT = true;
          }
      }
      else if ( c.Status == 'Fechado e resolvido' )// Processo de alteração de contratos: se a demanda foi fechada, muda status do contrato na sequência abaixo
      {
        if ( c.reason == 'Impressão do aditamento' ) 
        {
          ct.Status_do_processo__c = 'Entregue para assinatura do cliente';
          chgCT = true;
        }
        if ( c.reason == 'Assinatura do procurador' ) 
        {
          ct.Status_do_processo__c = 'Aditamento assinado encaminhado para a Regional';
          ct.Signatario_da_empresa__c = c.Company_Signatory__c; // Rogerio
          chgCT = true;
        }
        if ( c.reason == 'Assinatura da diretoria' ) 
        {
          ct.Status_do_processo__c = 'Aditamento assinado e encaminhado para assistente da regional';
          ct.Signatario_da_empresa_2__c = c.Company_Signatory_2__c; // Rogerio
          chgCT = true;
        }
        if ( c.reason == 'Conferência de aditamento' ) 
        {
          ct.Status_do_processo__c = 'Encaminhado para assinaturas';
          if ( ct.Data_de_inicio_da_vigencia_da_alteracao__c <= System.today() && ct.Status__c != 'Ativo')
          {
            ct.Status__c = 'Ativo';//Adicionado por carlos
          }
          chgCT = true;
        }
        if ( c.reason == 'Encaminhar aditamento para o consultor' )
        {
          ct.Status_do_processo__c = 'Aditamento assinado encaminhado para o consultor';
          chgCT = true;
        }
        if ( c.reason == 'Entregar aditamento assinado ao cliente' ) 
        {
          ct.Status_do_processo__c = 'Aditamento entregue para o cliente';
          chgCT = true;
        }
      }
    }
    
    // Processo de CANCELAMENTO de contratos: se a demanda foi fechada, muda status do contrato na sequência abaixo
    // demandas fechadas
    if ( c.Type == 'Cancelamento de Contrato' )
    {
      // demanda Aprovada.
      if ( c.Status == 'Aprovado' )
      {
        if ( c.reason == 'Negociação de cancelamento/pagamento' ) 
        {
          ct.Status_do_processo__c = 'Cancelamento aprovado pelo cliente';
          chgCT = true;
        }
        else if ( c.reason == 'Providenciar assinatura do distrato' ) 
        {
          ct.Status_do_processo__c = 'Distrato encaminhado para o Coordenador';
          ct.Distrato_Signatario_do_cliente__c = c.Termination_Customer_Signatory__c;
          ct.Distrato_Signatario_do_cliente_2__c = c.Termination_Customer_Signatory_2__c;
          ct.Data_de_assinatura_do_distrato_cliente__c = c.Signature_of_termination_Date_Customer__c;
          chgCT = true;
        }
      }
      // DEMANDA Não aprovado Reprovada.
      if ( c.Status == 'Não aprovado' )
      {
        if ( c.reason == 'Negociação de cancelamento/pagamento' )
        {
          ct.Status_do_processo__c = 'Proposta de cancelamento não aprovada pelo cliente';
          ct.Status__c = 'Ativo';
          if ( a.Channel__c == 'Off Trade' ) ct.RecordTypeId = lRecOffTrade;
          else ct.RecordTypeId = lRecOnTrade;
          chgCT = true;
        }
        else if ( c.reason == 'Providenciar assinatura do distrato' )
        {
          ct.Status_do_processo__c = 'Distrato não aprovado pelo cliente';
          ct.Status__c = 'Ativo';
          if ( a.Channel__c == 'Off Trade' ) ct.RecordTypeId = lRecOffTrade;
          else ct.RecordTypeId = lRecOnTrade;
          chgCT = true;
        }
      }
      
      /*
      if ( c.Status == 'Encaminhado para correções' && c.reason == 'Conferência de distrato') 
      {
        ct.Status_do_processo__c = 'Distrato devolvido para o Consultor' ;
        chgCT = true;
      }
      
      // DEMANDA Fechado e Resolvido.
      if ( c.Status == 'Fechado e resolvido' )
      {
        if ( c.reason == 'Conferência de distrato' ) 
        {
          ct.Status_do_processo__c = 'Distrato encaminhado para assinaturas';
          if ( ct.Data_de_vigencia_do_distrato__c <= System.today() && ct.Status__c != 'Cancelado' ) // Rogerio
            ct.Status__c = 'Cancelado';
          chgCT = true;
        }
        else if ( c.reason == 'Providenciar assinatura do procurador' ) 
        {
          ct.Status_do_processo__c = 'Distrato assinado pelo procurador';
          ct.Distrato_Signatario_da_empresa__c = c.Termination_Company_Signatory__c;
          chgCT = true;
        }
        else if ( c.reason == 'Providenciar assinatura da Diretoria' ) 
        {
          ct.Status_do_processo__c = 'Distrato assinado encaminhado para a Regional'; // Rogerio
          ct.Distrato_Signatario_da_empresa_2__c = c.Termination_Company_Signatory_2__c;
          chgCT = true;
        }
        else if ( c.reason == 'Encaminhar distrato para o consultor' ) //Rogerio
        {
          ct.Status_do_processo__c = 'Distrato assinado encaminhado para o Consultor';
          chgCT = true;
        }
        else if ( c.reason == 'Entregar via do distrato ao cliente' ) 
        {
          ct.Status_do_processo__c = 'Distrato entregue para o cliente';
          //if ( ct.Data_de_vigencia_do_distrato__c <= System.today() && ct.Status__c != 'Cancelado' )  //Rogerio
          //  ct.Status__c = 'Cancelado';
          chgCT = true;
        }//Adicionado por Eduardo
        else if ( c.reason == 'Entregar distrato assinado ao cliente' ) // Rogerio
        {
            ct.Status_do_processo__c = 'Distrato entregue para o cliente';
            chgCT = true;
        }
      }
    }
    
   // Processo de TÉRMINO de contratos: se a demanda foi fechada, muda status do contrato na sequência abaixo
    // demandas fechadas
    if ( c.Type == 'Prorrogação de Contrato' )
    {
      if ( c.Status == 'Aprovado' && c.Action_Proposal__c == 'Prorrogação do contrato'
      && ( c.reason == 'Negociar prorrogação de contrato' || c.reason == 'Prorrogação de contrato não aprovada' ) )
      {
        DemandaInterna.criademanda(null, c.OwnerId, 'Contrato - assinatura de prorrogação de contrato', c.AccountId, null,
            'Prorrogação de Contrato',
            'Entregar docto de prorrogação ao cliente', 
            'Entregar documento de prorrogação ao cliente',
            'Colher assinaturas da empresa, entregar documento de prorrogação ao cliente e encaminhar outras 2 vias para arquivamento junto ao contrato original.', c.LAT_Contract__c, c.Id );
        
        decimal Prazo = 0;
        if ( c.Contract_Deadline_months__c != null )
        {
          Prazo = c.Contract_Deadline_months__c ;
        }
        ct.ContractTerm__c = ct.ContractTerm__c + Prazo.intValue();
        ct.Status_do_processo__c = 'Contrato prorrogado';
        ct.Prazo_de_prorrogacao_meses__c = c.Contract_Deadline_months__c;
        chgCT = true;
      }
      else if ( c.Status == 'Não aprovado pelo cliente' && c.reason == 'Negociar prorrogação de contrato' )
      {
        DemandaInterna.criademanda(null, c.Manager__c, 'Contrato - processo de prorrogação', c.AccountId, null,
        'Prorrogação de Contrato',
        'Prorrogação de contrato não aprovada', 
        'Negociar com o cliente a prorrogação do contrato',
        'Finalizar a negociação de prorrogação de contrato não aprovada pelo cliente.', c.LAT_Contract__c, c.Id );
        ct.Status_do_processo__c = 'Processo de prorrogação pendente';
        chgCT = true;
      }
      else if ( c.Status == 'Não aprovado pelo cliente' && c.reason == 'Prorrogação de contrato não aprovada'
      && c.Action_Proposal__c == 'Prorrogação do contrato' )
      {
        ct.Status_do_processo__c = 'Prorrogação de contrato não aprovada';
        chgCT = true;
      }
    }
    
    if ( c.Type == 'Término de Contrato' )
    {
      if ( c.reason == 'Vencimento de Contrato' && c.Action_Proposal__c == 'Prorrogação do contrato'
      && c.status == 'Em processo de prorrogação' )
      {
        ct.Status_do_processo__c = 'Em processo de prorrogação';
        chgCT = true;
      }
      // demanda Aprovada (Somente para término).
      if ( c.Termination_approved__c )
      {
        if ( c.reason == 'Vencimento de Contrato' && c.Action_Proposal__c == 'Prorrogação do contrato' )
        {
          DemandaInterna.criademanda(null, c.OwnerId, 'Contrato - Processo de prorrogação', c.AccountId, null,
              'Prorrogação de Contrato',
              'Negociar prorrogação de contrato', 
              'Negociar com cliente prorrogação de contrato, incluindo detalhes da prorrogação',
              'Negociar com cliente prorrogação do contrato.', c.LAT_Contract__c, c.Id );
        }

        if ( c.reason == 'Vencimento de Contrato' && c.Action_Proposal__c == 'Renovação do contrato' 
        && c.Status == 'Em processo de renovação' )
        {
          /*DemandaInterna.criademanda(null, c.OwnerId, 'Contrato - renovação de contrato', c.AccountId, null,
              'Renovação de Contrato',
              'Solicitar aprovação do cliente', 
              'Solicitar ao cliente aprovação de renovação do contrato',
              'Negociar com cliente a renovação do contrato.', c.LAT_Contract__c, c.Id );
              
          ct.Status_do_processo__c = 'Em processo de renovação';
          chgCT = true;
         }

        if ( c.reason == 'Vencimento de Contrato' && c.Action_Proposal__c == 'Não renovação' )
        {
          DemandaInterna.criademanda(null, c.OwnerId, 'Contrato - não renovação de contrato', c.AccountId, null,
              'Não Renovação de Contrato',
              'Carta de não renovação de contrato', 
              'Entregar carta de não renovação ao cliente',
              'Emitir carta conforme modelo, providenciar assinaturas e entregá-la ao cliente.', c.LAT_Contract__c, c.Id );
         }
       }
    }
    
    if ( c.Type == 'Renovação de Contrato' )
    {
      // demanda Aprovada.
      if ( c.Status == 'Aprovado' && c.reason == 'Solicitar aprovação do cliente')
      {
        ct.Status_do_processo__c = 'Contrato renovado' ;
        chgCT = true;
      }
      else if ( c.Status == 'Não aprovado' && c.reason == 'Solicitar aprovação do cliente')
      {
        ct.Status_do_processo__c = 'Contrato não renovado' ;
        chgCT = true;
      }
    }
    
    if ( c.Type == 'Não Renovação de Contrato' && c.Status == 'Fechado e resolvido' 
    && c.reason == 'Carta de não renovação de contrato' )
    {
      ct.Status_do_processo__c = 'Carta de não renovação entregue' ;
      chgCT = true;
    }
    
    if ( chgCT )
    {
      ct.trigger_on__c = true;
      lContractUpdateList.add( ct );
    }
    
  }
  
  try
  {
    update lAccUpdateList;
    update lContractUpdateList;
  }
  catch( Dmlexception e )
  {
    for ( Case c : trigger.new )
      c.addError( e.getDmlMessage( 0 ) );
  }  
  }  
  */
}