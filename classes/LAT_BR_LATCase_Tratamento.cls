//LAT_CASE__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_LATCase_Tratamento {
	
	public static void execute(){
		
		//    Check if this trigger is bypassed by SESAME (data migration Brazil)
		if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

		    system.debug('ENTRO AL TRIGGER');
		  
		  Id lRecOnTrade = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato' );
		  Id lRecOffTrade = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo' );
		  Set< Id > setRecType = new Set< Id >();
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Alteracao_rota_de_promotor') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Alteracao_cadastro_de_clientes') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Cancelar_D_A_no_sistema_ME') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Cliente_inadimplente') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_aprovacao_de_proposta') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_da_diretoria') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_de_distrato_procurador') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_de_distrato_diretoria'));
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_do_procurador') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Negociacao_de_cancelamento') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Processo_de_prorrogacao') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Proposta_de_renovacao') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_assinatura_de_distrato_do_cliente') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_assinatura_de_prorrogacao_de_contrato') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_assinatura_prorroga_o_do_cliente') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_coleta_de_assinatura_do_cliente') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_coleta_de_assinatura_do_cliente_off') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_conferencia_de_documentacao') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_entrega_do_contrato') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_nao_renovacao_de_contrato') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_renovacao_de_contrato') );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Gerar_D_A_no_sistema_ME' ) );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Inserir_o_Tipo_de_Verba' ) );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Justificativa_de_inadimplencia' ) );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Novo_cadastro_de_cliente' ) );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'nao_renovacao' ) );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Proposta_de_pagamento' ) );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Sem_proposta_de_pagamento' ) );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Solicitacoes_e_Reclamacoes' ) );
		  setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Termino_de_contrato' ) );
		  
		  Id idRecTypeOnContNaoAprovado = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'OnTradeContratoNaoAprovado' );
		  
		  List< String > lACCIds = new List< String >();
		  List< String > lContractIds = new List< String >();
		  List< String > lOwnerIds = new List< String >();
		  integer j = 0;
		  
		  for ( LAT_Case__c c : LAT_CaseTriggerHandler.triggerNew )
		  {
		    if( setRecType.contains( c.RecordTypeId)){
		        if ( !c.LAT_IsClosed__c || LAT_CaseTriggerHandler.triggerOld[j].LAT_isClosed__c ) continue;
		        if ( c.LAT_Account__c != null )
		          lACCIds.add( c.LAT_Account__c );
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
		                    Checked_over_Commercial_Planning__c, Channel__c, RecordType.DeveloperName
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
		  
		  integer lLen = LAT_CaseTriggerHandler.triggerNew.size();
		  for ( Integer i=0; i<lLen; i++ )
		  {
		    LAT_Case__c c = LAT_CaseTriggerHandler.triggerNew[ i ];
		    LAT_Case__c o = LAT_CaseTriggerHandler.triggerOld[ i ];
		    if ( !c.LAT_IsClosed__c || o.LAT_IsClosed__c ) continue;
		    String NomeFila = lQueueMap.get( c.OwnerId );
		    Account a = lAccMap.get( c.LAT_Account__c );
		    LAT_Contract__c ct = lContractMap.get( c.LAT_Contract__c );
		    
		// CLIENTES
		    // Processo de clientes: se a demanda foi fechada, marca campos checkbox correnpondentes na conta.
		    // para cada tipo de caso aberto pelo processo de cad clientes, marca o checkbox correspondente.
		    if ( c.LAT_Type__c == 'Cadastro de clientes' && c.LAT_Reason__c == 'Análise/complementação de dados' )
		    {
		      if ( NomeFila == 'Customer service' ) 
		      { 
		      	// Moved to LAT_BR_AP01_CASE
		        a.Checked_over_Sales_Administration__c = true;
		        //lAccUpdateList.add( a );
		      } 
		      else if ( NomeFila == 'Crédito e cobrança' && a.Channel__c != 'Eventos')
		      { 
		      	// Moved to LAT_BR_AP01_CASE
		      	system.debug('LAT_BR_LATCase_Tratamento: StatusChange tratamento1');
		        a.Checked_over_Credit_and_collection__c = true;
		        a.Status__c = 'Em aprovação - Financeiro';
		       
		        //lAccUpdateList.add( a );
		      }
		      else if ( NomeFila == 'Planejamento comercial' )
		      {
		      	system.debug('LAT_BR_LATCase_Tratamento: StatusChange tratamento2');
		        a.Checked_over_Commercial_Planning__c = true;
		        a.Status__c = 'Em aprovação - Financeiro';
		        lAccUpdateList.add( a );
		      } 
		      else if ( NomeFila == 'Controladoria' )
		      { 
		      	system.debug('LAT_BR_LATCase_Tratamento: StatusChange tratamento3');
		        a.Checked_over_Comptroller__c = true;
		        lAccUpdateList.add( a );
		      }
		    }
		    // Processo de alteração de cliente: Foi feito por workflow

		// CONTRATOS
		    // Processo de ASSINATURA DE CONTRATOS: se a demanda foi fechada, muda status do contrato na sequência abaixo
		    // demandas fechadas
		    
		    system.debug('TYPE DE DEMANDA: ' + c.LAT_Type__c);
		    system.debug('STATUS DE DEMANDA: ' + c.LAT_Status__c);
		    system.debug('REASON DE DEMANDA: ' + c.LAT_Reason__c);
		    
		    boolean chgCT = false;
		    if ( c.LAT_Type__c == 'Assinatura de contrato' )
		    {
		      // DEMANDA Aprovada.
		      if ( c.LAT_Status__c == 'Aprovado' )
		      {
		        //Inserido 2 condições por solicitação do Eduardo - Carlos 12/06/2012
		        if ( c.LAT_reason__c == 'Aprovação do cliente' && a.Channel__c == 'Off Trade' ) //Aprovação do Cliente e OFF TRADE
		        {
		          ct.Signatario_do_cliente__c  = c.LAT_CustomerSignatory2__c ;
		          ct.CustomerSigned__c         = c.LAT_CustomerSignatory__c ;
		          ct.Obs_signatarios__c        = c.LAT_SigningNote__c ;
		          ct.CustomerSignedDate__c     = c.LAT_CustomerSignatureDate__c ; 
		          ct.Status_do_processo__c     = 'Contrato assinado encaminhado para o Coordenador'; 
		          ct.fase__c                   = 'Contrato';
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Aprovação do cliente' && a.Channel__c == 'On Trade' ) //Aprovação do Cliente e ON TRADE
		        {
		          ct.Signatario_do_cliente__c  = c.LAT_CustomerSignatory2__c ;
		          ct.CustomerSigned__c         = c.LAT_CustomerSignatory__c ;
		          ct.Obs_signatarios__c        = c.LAT_SigningNote__c ;
		          ct.CustomerSignedDate__c     = c.LAT_CustomerSignatureDate__c ; 
		          ct.Status_do_processo__c     = 'Proposta aprovada pelo cliente'; 
		          ct.fase__c                   = 'Contrato';
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Coleta de assinatura do cliente' ) 
		        {
		          ct.Status_do_processo__c = 'Contrato assinado encaminhado para o Coordenador';
		          ct.CustomerSignedDate__c = c.LAT_CustomerSignatureDate__c ;
		          chgCT = true;
		        }
		      }
		      
		      // DEMANDA Reprovada.
		      // JL 22/mai/2012
		      if ( c.LAT_Status__c == 'Não aprovado' )
		      {
		        if ( c.LAT_reason__c == 'Aprovação do cliente' )
		        {
		            system.debug('ENTRO AL IF 2');
		          ct.Aprovado_pelo_cliente__c = true;
		          ct.Status_do_processo__c = 'Proposta não aprovada';
		          ct.Status__c = 'Não aprovado';
		          ct.RecordTypeId = idRecTypeOnContNaoAprovado;
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Coleta de assinatura do cliente' )
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
		      if ( c.LAT_Status__c == 'Solicitação de ajuste na proposta' && c.LAT_reason__c == 'Aprovação do cliente' )
		      {
		        ct.Aprovado_pelo_cliente__c = true;
		        ct.Status_do_processo__c = 'Estudo em elaboração';
		        ct.fase__c = 'Estudo';
		        chgCT = true;
		      }
		      
		      // DEMANDA 'Fechado e resolvido'.
		      // JL 22/mai/2012
		      if ( c.LAT_Status__c == 'Fechado e resolvido' )
		      {
		        if ( c.LAT_reason__c == 'Conferência de contrato' ) 
		        {
		          ct.Status_do_processo__c = 'Encaminhado para o assistente da regional'; //Adicionado por carlos
		          if ( ct.StartDate__c <= System.today() && ct.Status__c != 'Ativo' ) ct.Status__c = 'Ativo';//Adicionado por carlos
		          else ct.Status__c = 'Aprovado';
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Assinatura do procurador' ) 
		        {
		          ct.Status_do_processo__c = 'Encaminhado para o assistente de Trade ou Regional';  
		          ct.Signatario_da_empresa__c = c.LAT_CompanySignatory__c;
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Assinatura da diretoria' ) 
		        {  
		          ct.Status_do_processo__c = 'Assinado e encaminhado para assistente da regional';    
		          ct.Signatario_da_empresa_2__c = c.LAT_CompanySignatory2__c;
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Encaminhar via assinada para o Consultor' ) 
		        {
		          ct.Status_do_processo__c = 'Contrato assinado encaminhado para Consultor';
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Providenciar correções de documentação' )
		        {
		          ct.Status_do_processo__c = 'Contrato assinado encaminhado para o Coordenador';
		          chgCT = true;
		        }//Encaminhado para assinatura do cliente
		        else if ( c.LAT_reason__c == 'Entregar contrato assinado ao cliente' )
		        {
		          ct.Status_do_processo__c = 'Processo finalizado';
		          chgCT = true;
		        }
		      }
		      
		      // DEMANDA 'Encaminhado para correções'.
		      // JL 22/mai/2012
		      if ( c.LAT_Status__c == 'Encaminhado para correções' && c.LAT_Type__c == 'Assinatura de contrato' 
		      && c.LAT_reason__c == 'Conferência de contrato' )
		      {
		        ct.Status_do_processo__c = 'Contrato devolvido para o Consultor';
		        chgCT = true;  
		      }
		    }
		    
		    // Processo DE ALTERAÇÃO DE CONTRATO
		    // demandas fechadas
		    if ( c.LAT_Type__c == 'Alteração de contrato' )
		    {
		      // DEMANDA Aprovada JL 23/mai
		      if ( c.LAT_Status__c == 'Aprovado' )
		      {
		        if ( c.LAT_reason__c == 'Impressão do aditamento' && a.Channel__c == 'On Trade' ) 
		        {
		          ct.Status_do_processo__c = 'Entregue para assinatura do cliente';
		          ct.fase__c = 'Contrato';                                
		          ct.Signatario_do_cliente__c = c.LAT_CustomerSignatory2__c ;         // Rogerio 28/06/2012 12:10
		          ct.CustomerSigned__c = c.LAT_CustomerSignatory__c ;
		          ct.Obs_signatarios__c = c.LAT_SigningNote__c ;
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Assinatura de aditamento' )
		        {
		          ct.Status_do_processo__c = 'Encaminhado para o coordenador';
		          if ( a.Channel__c == 'Off Trade' )
		          {
		            ct.Signatario_do_cliente__c = c.LAT_CustomerSignatory2__c ;   // Rogerio 28/06/2012 12:10
		            ct.CustomerSigned__c = c.LAT_CustomerSignatory__c ;
		            ct.Obs_signatarios__c = c.LAT_SigningNote__c ;
		          }
		          ct.CustomerSignedDate__c = c.LAT_CustomerSignatureDate__c;
		          chgCT = true;
		        }
		      }
		      else if ( c.LAT_Status__c == 'Não aprovado' ) // DEMANDA REprovada JL 22/mai/2012
		      {
		        /******************************************* NÂO APAGAR - EDUARDO AINDA VAI VALIDAR****************************
		        if ( c.reason == 'Impressão do aditamento' && a.Channel__c == 'On Trade' )
		        {
		          ct.Status_do_processo__c = 'Estudo de alteração de contrato';
		          ct.fase__c = 'Pré-estudo';
		          ct.Status = 'Em elaboração';
		          chgCT = true;
		        } ******************************************* NÂO APAGAR - EDUARDO AINDA VAI VALIDAR****************************/
		        if ( c.LAT_reason__c == 'Impressão do aditamento' && a.Channel__c == 'On Trade' )
		        {         
		            ct.Status_do_processo__c = 'Proposta não aprovada';
		          ct.Status__c = 'Não aprovado';
		          ct.RecordTypeId = idRecTypeOnContNaoAprovado;
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Assinatura de aditamento' && a.Channel__c == 'Off Trade' ) // Rogerio
		        {         
		          ct.Status_do_processo__c = 'Proposta não aprovada';
		          ct.Status__c = 'Não aprovado';
		          ct.RecordTypeId = idRecTypeOnContNaoAprovado;
		          chgCT = true;
		        }
		      }
		      else if ( c.LAT_Status__c == 'Encaminhado para correções' )
		      {
		        if ( a.Channel__c == 'Off Trade' && c.LAT_reason__c == 'Conferência de aditamento' ) // Rogerio
		        {
		          ct.Status_do_processo__c = 'Aditamento encaminhado para o consultor';
		          chgCT = true;
		        }
		        else
		          if ( a.Channel__c == 'On Trade' && c.LAT_reason__c == 'Conferência de aditamento' ) // Rogerio
		          {
		            ct.Status_do_processo__c = 'Entregue para assinatura do cliente';
		            chgCT = true;
		          }
		      }
		      else if ( c.LAT_Status__c == 'Fechado e resolvido' )// Processo de alteração de contratos: se a demanda foi fechada, muda status do contrato na sequência abaixo
		      {
		        if ( c.LAT_reason__c == 'Impressão do aditamento' ) 
		        {
		          ct.Status_do_processo__c = 'Entregue para assinatura do cliente';
		          chgCT = true;
		        }
		        if ( c.LAT_reason__c == 'Assinatura do procurador' ) 
		        {
		          ct.Status_do_processo__c = 'Aditamento assinado encaminhado para a Regional';
		          ct.Signatario_da_empresa__c = c.LAT_CompanySignatory__c; // Rogerio
		          chgCT = true;
		        }
		        if ( c.LAT_reason__c == 'Assinatura da diretoria' ) 
		        {
		          ct.Status_do_processo__c = 'Aditamento assinado e encaminhado para assistente da regional';
		          ct.Signatario_da_empresa_2__c = c.LAT_CompanySignatory2__c; // Rogerio
		          chgCT = true;
		        }
		        if ( c.LAT_reason__c == 'Conferência de aditamento' ) 
		        {
		          ct.Status_do_processo__c = 'Encaminhado para assinaturas';
		          if ( ct.Data_de_inicio_da_vigencia_da_alteracao__c <= System.today() && ct.Status__c != 'Ativo')
		          {
		            ct.Status__c = 'Ativo';//Adicionado por carlos
		          }
		          chgCT = true;
		        }
		        if ( c.LAT_reason__c == 'Encaminhar aditamento para o consultor' )
		        {
		          ct.Status_do_processo__c = 'Aditamento assinado encaminhado para o consultor';
		          chgCT = true;
		        }
		        if ( c.LAT_reason__c == 'Entregar aditamento assinado ao cliente' ) 
		        {
		          ct.Status_do_processo__c = 'Aditamento entregue para o cliente';
		          chgCT = true;
		        }
		      }
		    }
		    
		    // Processo de CANCELAMENTO de contratos: se a demanda foi fechada, muda status do contrato na sequência abaixo
		    // demandas fechadas
		    if ( c.LAT_Type__c == 'Cancelamento de Contrato' )
		    {
		      // demanda Aprovada.
		      if ( c.LAT_Status__c == 'Aprovado' )
		      {
		        if ( c.LAT_reason__c == 'Negociação de cancelamento/pagamento' ) 
		        {
		          ct.Status_do_processo__c = 'Cancelamento aprovado pelo cliente';
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Providenciar assinatura do distrato' ) 
		        {
		          ct.Status_do_processo__c = 'Distrato encaminhado para o Coordenador';
		          ct.Distrato_Signatario_do_cliente__c = c.LAT_TerminationCustomerSignatory__c;
		          ct.Distrato_Signatario_do_cliente_2__c = c.LAT_TerminationCustomerSignatory2__c;
		          ct.Data_de_assinatura_do_distrato_cliente__c = c.LAT_SignatureOfTerminationDateCustomer__c;
		          chgCT = true;
		        }
		      }
		      // DEMANDA Não aprovado Reprovada.
		      if ( c.LAT_Status__c == 'Não aprovado' )
		      {
		        if ( c.LAT_reason__c == 'Negociação de cancelamento/pagamento' )
		        {
		          ct.Status_do_processo__c = 'Proposta de cancelamento não aprovada pelo cliente';
		          ct.Status__c = 'Ativo';
		          if ( a.Channel__c == 'Off Trade' ) ct.RecordTypeId = lRecOffTrade;
		          else ct.RecordTypeId = lRecOnTrade;
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Providenciar assinatura do distrato' )
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
		      }*/
		      
		      // DEMANDA Fechado e Resolvido.
		      if ( c.LAT_Status__c == 'Fechado e resolvido' )
		      {
		        if ( c.LAT_reason__c == 'Conferência de distrato' ) 
		        {
		          ct.Status_do_processo__c = 'Distrato encaminhado para assinaturas';
		          if ( ct.Data_de_vigencia_do_distrato__c <= System.today() && ct.Status__c != 'Cancelado' ) // Rogerio
		            ct.Status__c = 'Cancelado';
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Providenciar assinatura do procurador' ) 
		        {
		          ct.Status_do_processo__c = 'Distrato assinado pelo procurador';
		          ct.Distrato_Signatario_da_empresa__c = c.LAT_TerminationCompanySignatory__c;
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Providenciar assinatura da Diretoria' ) 
		        {
		          ct.Status_do_processo__c = 'Distrato assinado encaminhado para a Regional'; // Rogerio
		          ct.Distrato_Signatario_da_empresa_2__c = c.LAT_TerminationCompanySignatory2__c;
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Encaminhar distrato para o consultor' ) //Rogerio
		        {
		          ct.Status_do_processo__c = 'Distrato assinado encaminhado para o Consultor';
		          chgCT = true;
		        }
		        else if ( c.LAT_reason__c == 'Entregar via do distrato ao cliente' ) 
		        {
		          ct.Status_do_processo__c = 'Distrato entregue para o cliente';
		          //if ( ct.Data_de_vigencia_do_distrato__c <= System.today() && ct.Status__c != 'Cancelado' )  //Rogerio
		          //  ct.Status__c = 'Cancelado';
		          chgCT = true;
		        }//Adicionado por Eduardo
		        else if ( c.LAT_reason__c == 'Entregar distrato assinado ao cliente' ) // Rogerio
		        {
		            ct.Status_do_processo__c = 'Distrato entregue para o cliente';
		            chgCT = true;
		        }
		      }
		    }
		    
		   // Processo de TÉRMINO de contratos: se a demanda foi fechada, muda status do contrato na sequência abaixo
		    // demandas fechadas
		    if ( c.LAT_Type__c == 'Prorrogação de Contrato' )
		    {
		      if ( c.LAT_Status__c == 'Aprovado' && c.LAT_PurposesAction__c == 'Prorrogação do contrato'
		      && ( c.LAT_reason__c == 'Negociar prorrogação de contrato' || c.LAT_reason__c == 'Prorrogação de contrato não aprovada' ) )
		      {
		        DemandaInterna.criademanda(null, c.OwnerId, 'Contrato - assinatura de prorrogação de contrato', c.LAT_Account__c, null,
		            'Prorrogação de Contrato',
		            'Entregar docto de prorrogação ao cliente', 
		            'Entregar documento de prorrogação ao cliente',
		            'Colher assinaturas da empresa, entregar documento de prorrogação ao cliente e encaminhar outras 2 vias para arquivamento junto ao contrato original.', c.LAT_Contract__c, c.Id );
		        
		        decimal Prazo = 0;
		        if ( c.LAT_ContractDeadlineMonths__c != null )
		        {
		          Prazo = c.LAT_ContractDeadlineMonths__c ;
		        }
		        ct.ContractTerm__c = ct.ContractTerm__c + Prazo.intValue();
		        ct.Status_do_processo__c = 'Contrato prorrogado';
		        ct.Prazo_de_prorrogacao_meses__c = c.LAT_ContractDeadlineMonths__c;
		        chgCT = true;
		      }
		      else if ( c.LAT_Status__c == 'Não aprovado pelo cliente' && c.LAT_reason__c == 'Negociar prorrogação de contrato' )
		      {
		        DemandaInterna.criademanda(null, c.LAT_Manager__c, 'Contrato - processo de prorrogação', c.LAT_Account__c, null,
		        'Prorrogação de Contrato',
		        'Prorrogação de contrato não aprovada', 
		        'Negociar com o cliente a prorrogação do contrato',
		        'Finalizar a negociação de prorrogação de contrato não aprovada pelo cliente.', c.LAT_Contract__c, c.Id );
		        ct.Status_do_processo__c = 'Processo de prorrogação pendente';
		        chgCT = true;
		      }
		      else if ( c.LAT_Status__c == 'Não aprovado pelo cliente' && c.LAT_reason__c == 'Prorrogação de contrato não aprovada'
		      && c.LAT_PurposesAction__c == 'Prorrogação do contrato' )
		      {
		        ct.Status_do_processo__c = 'Prorrogação de contrato não aprovada';
		        chgCT = true;
		      }
		    }
		    
		    if ( c.LAT_Type__c == 'Término de Contrato' )
		    {
		      if ( c.LAT_reason__c == 'Vencimento de Contrato' && c.LAT_PurposesAction__c == 'Prorrogação do contrato'
		      && c.LAT_status__c == 'Em processo de prorrogação' )
		      {
		        ct.Status_do_processo__c = 'Em processo de prorrogação';
		        chgCT = true;
		      }
		      // demanda Aprovada (Somente para término).
		      if ( c.LAT_TerminationApproved__c )
		      {
		        if ( c.LAT_reason__c == 'Vencimento de Contrato' && c.LAT_PurposesAction__c == 'Prorrogação do contrato' )
		        {
		          DemandaInterna.criademanda(null, c.OwnerId, 'Contrato - Processo de prorrogação', c.LAT_Account__c, null,
		              'Prorrogação de Contrato',
		              'Negociar prorrogação de contrato', 
		              'Negociar com cliente prorrogação de contrato, incluindo detalhes da prorrogação',
		              'Negociar com cliente prorrogação do contrato.', c.LAT_Contract__c, c.Id );
		        }

		        if ( c.LAT_reason__c == 'Vencimento de Contrato' && c.LAT_PurposesAction__c == 'Renovação do contrato' 
		        && c.LAT_Status__c == 'Em processo de renovação' )
		        {
		          /*DemandaInterna.criademanda(null, c.OwnerId, 'Contrato - renovação de contrato', c.AccountId, null,
		              'Renovação de Contrato',
		              'Solicitar aprovação do cliente', 
		              'Solicitar ao cliente aprovação de renovação do contrato',
		              'Negociar com cliente a renovação do contrato.', c.LAT_Contract__c, c.Id );
		              */
		          ct.Status_do_processo__c = 'Em processo de renovação';
		          chgCT = true;
		         }

		        if ( c.LAT_reason__c == 'Vencimento de Contrato' && c.LAT_PurposesAction__c == 'Não renovação' )
		        {
		          DemandaInterna.criademanda(null, c.OwnerId, 'Contrato - não renovação de contrato', c.LAT_Account__c, null,
		              'Não Renovação de Contrato',
		              'Carta de não renovação de contrato', 
		              'Entregar carta de não renovação ao cliente',
		              'Emitir carta conforme modelo, providenciar assinaturas e entregá-la ao cliente.', c.LAT_Contract__c, c.Id );
		         }
		       }
		    }
		    
		    if ( c.LAT_Type__c == 'Renovação de Contrato' )
		    {
		      // demanda Aprovada.
		      if ( c.LAT_Status__c == 'Aprovado' && c.LAT_reason__c == 'Solicitar aprovação do cliente')
		      {
		        ct.Status_do_processo__c = 'Contrato renovado' ;
		        chgCT = true;
		      }
		      else if ( c.LAT_Status__c == 'Não aprovado' && c.LAT_reason__c == 'Solicitar aprovação do cliente')
		      {
		        ct.Status_do_processo__c = 'Contrato não renovado' ;
		        chgCT = true;
		      }
		    }
		    
		    if ( c.LAT_Type__c == 'Não Renovação de Contrato' && c.LAT_Status__c == 'Fechado e resolvido' 
		    && c.LAT_reason__c == 'Carta de não renovação de contrato' )
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
		  	if (!lAccUpdateList.isEmpty()){
		    	update lAccUpdateList;
		  	}
		    update lContractUpdateList;
		  }
		  catch( Dmlexception e )
		  {
		    for ( LAT_Case__c c : LAT_CaseTriggerHandler.triggerNew )
		      c.addError( e.getDmlMessage( 0 ) );
		  }  
		  }  
	}

}