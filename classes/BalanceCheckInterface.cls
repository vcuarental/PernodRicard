/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Interface responsável por consultar o saldo da DA no sistema ME.
* NAME: BalanceCheckInterface.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 25/09/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 04/10/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 18/10/2012
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 09/01/2013 
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/
global class BalanceCheckInterface {
    
    private static final Integer COD_EMPRESA = 81;
    private static final Integer COD_PAIS = 1;
    
     //MIGRATED 02/11/2016 
    Webservice static String BalanceCheckInvoke( String idCase ) {
        if( idCase == null || idCase.trim().equals('') ) return 'Favor informar um ID. Recebido: '+idCase;
        //Declaração de variáveis
        Case caso;
        LAT_Case__c latCaso;
        String userDA, tipoWorkflow;
        Integer numeroDA;
        Set< Id > setRecTypeCase = new Set< Id >();
        
        //wasMigrationDone
        if(!Utils.wasMigrationDone('1')){
          //Declaração de variáveis
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Alteracao_rota_de_promotor') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Alteracao_cadastro_de_clientes') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Cancelar_D_A_no_sistema_ME') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Cliente_inadimplente') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_aprovacao_de_proposta') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_da_diretoria') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_de_distrato_procurador') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_do_procurador') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Negociacao_de_cancelamento') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Processo_de_prorrogacao') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Proposta_de_renovacao') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_assinatura_de_distrato_do_cliente') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_assinatura_de_prorrogacao_de_contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_assinatura_prorroga_o_do_cliente') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_coleta_de_assinatura_do_cliente') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_coleta_de_assinatura_do_cliente_off') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_conferencia_de_documentacao') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_entrega_do_contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_nao_renovacao_de_contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_renovacao_de_contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Gerar_D_A_no_sistema_ME' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Inserir_o_Tipo_de_Verba' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Justificativa_de_inadimplencia' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Novo_cadastro_de_cliente' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'nao_renovacao' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Proposta_de_pagamento' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Sem_proposta_de_pagamento' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Solicitacoes_e_Reclamacoes' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Termino_de_contrato' ) );
          try{
            //Recupera o agrupamento de fiscal year 
              caso = [ SELECT Id, WF_Type__c, Amount_Type__c, DA_Number__c, Owner.UserName,
                              OwnerId, Total_Value__c, Integration_Message__c, Integration_Status__c,
                              Inquiry_held__c
                              FROM Case WHERE id =: idCase 
                              AND RecordTypeId =: setRecTypeCase limit 1 ];
                              
          }catch( QueryException e ){
              System.debug( e.getMessage() );
          }
          //Verifica se retornou algum caso
          if( caso == null ) return 'Não existe Demanda com o Id Informado. ID= '+idCase; 
          //Verifica se o número da DA e o Tipo de Workflow foram preenchidos
          if( caso.DA_Number__c == null || caso.WF_Type__c == null ) {
              return 'Número da DA e o Tipo de Workflow são obrigatórios.';
          }
          //Armazena dados em variaveis
          userDA = Utils.getUserNameSplit( caso.Owner.Username );
          tipoWorkflow = caso.WF_Type__c;
          numeroDA = Integer.valueOf( caso.DA_Number__c );
          
          //Inicializa objetos do webservice
          BalanceCheck.PMEWS010SoapPort lResponse = new BalanceCheck.PMEWS010SoapPort();
          BalanceCheck.PMEWS010_ExecuteResponse_element lReturn = new BalanceCheck.PMEWS010_ExecuteResponse_element();
          
          //Verifica se o código esta sendo executado por uma classe de teste
          if( !Test.isRunningTest() ){
             //Invoca o método do webservice
             lReturn = lResponse.Execute( COD_PAIS, 
                                          COD_EMPRESA, 
                                          'MECRMBR',//userDA,//'BILINSKY' 
                                          tipoWorkflow , 
                                          numeroDA);
             
          }else{
            //Invoca método mock se for uma classe de teste que executou o código.
              lReturn = callOutMock();
          }
          
          //Verifica o código de retorno
         if( lReturn.Codret != '00' ){
             caso.Integration_Message__c = lReturn.Msgret;
             caso.Integration_Status__c = 'Erro de integração';
         }else if( lReturn.Domsta == 'A' || lReturn.Domsta == 'B' ){
             if( lReturn.Saldo < caso.Total_Value__c ){
                 caso.Integration_Status__c = 'Não possui Saldo';
                 caso.Integration_Message__c = 'Valor da DA é menor que o solicitado.';
             }else{
                 caso.Integration_Message__c = '';
                 caso.Integration_Status__c = 'Reservado';
             }
         }else{
             caso.Integration_Message__c = 'Esse número de DA esta com status diferente de Aprovado ou Em Processo.';
             caso.Integration_Status__c = 'Erro de integração';
         }
         //Atualiza campo de consulta
          caso.Inquiry_held__c = true;
          
          //Atualiza o caso
          update caso;
          
          //Retorna na tela do usuário que a consulta foi realiza com sucesso.
          return 'Consulta realizada com sucesso!';
        }else{
          //Declaração de variáveis
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Alteracao_rota_de_promotor') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Alteracao_cadastro_de_clientes') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Cancelar_D_A_no_sistema_ME') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Cliente_inadimplente') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_aprovacao_de_proposta') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_da_diretoria') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_de_distrato_procurador') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_do_procurador') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Negociacao_de_cancelamento') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Processo_de_prorrogacao') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Proposta_de_renovacao') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_assinatura_de_distrato_do_cliente') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_assinatura_de_prorrogacao_de_contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_assinatura_prorroga_o_do_cliente') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_coleta_de_assinatura_do_cliente') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_coleta_de_assinatura_do_cliente_off') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_conferencia_de_documentacao') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_entrega_do_contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_nao_renovacao_de_contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_renovacao_de_contrato') );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Gerar_D_A_no_sistema_ME' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Inserir_o_Tipo_de_Verba' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Justificativa_de_inadimplencia' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Novo_cadastro_de_cliente' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'nao_renovacao' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Proposta_de_pagamento' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Sem_proposta_de_pagamento' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Solicitacoes_e_Reclamacoes' ) );
          setRecTypeCase.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Termino_de_contrato' ) );
          try{
          //Recupera o agrupamento de fiscal year 
            latCaso = [ SELECT Id, LAT_WFType__c, LAT_AmountType__c, LAT_DANumber__c, Owner.UserName,
                            OwnerId, LAT_TotalValue__c, LAT_IntegrationMessage__c, LAT_IntegrationStatus__c,
                            LAT_InquiryHeld__c
                            FROM LAT_Case__c WHERE id =: idCase 
                            AND RecordTypeId =: setRecTypeCase limit 1 ];
                            
          }catch( QueryException e ){
              System.debug( e.getMessage() );
          }
          //Verifica se retornou algum caso
          if( latCaso == null ) return 'Não existe Demanda com o Id Informado. ID= '+idCase; 
          //Verifica se o número da DA e o Tipo de Workflow foram preenchidos
          if( latCaso.LAT_DANumber__c == null || latCaso.LAT_WFType__c == null ) {
              return 'Número da DA e o Tipo de Workflow são obrigatórios.';
          }
          //Armazena dados em variaveis
          userDA = Utils.getUserNameSplit( latCaso.Owner.Username );
          tipoWorkflow = latCaso.LAT_WFType__c;
          numeroDA = Integer.valueOf( latCaso.LAT_DANumber__c );
          
          //Inicializa objetos do webservice
          BalanceCheck.PMEWS010SoapPort lResponse = new BalanceCheck.PMEWS010SoapPort();
          BalanceCheck.PMEWS010_ExecuteResponse_element lReturn = new BalanceCheck.PMEWS010_ExecuteResponse_element();
          
          //Verifica se o código esta sendo executado por uma classe de teste
          if( !Test.isRunningTest() ){
             //Invoca o método do webservice
             lReturn = lResponse.Execute( COD_PAIS, 
                                          COD_EMPRESA, 
                                          'MECRMBR',//userDA,//'BILINSKY' 
                                          tipoWorkflow , 
                                          numeroDA);
             
          }else{
            //Invoca método mock se for uma classe de teste que executou o código.
              lReturn = callOutMock();
          }
          
          //Verifica o código de retorno
         if( lReturn.Codret != '00' ){
             latCaso.LAT_IntegrationMessage__c = lReturn.Msgret;
             latCaso.LAT_IntegrationStatus__c = 'Erro de integração';
         }else if( lReturn.Domsta == 'A' || lReturn.Domsta == 'B' ){
             if( lReturn.Saldo < latCaso.LAT_TotalValue__c ){
                 latCaso.LAT_IntegrationStatus__c = 'Não possui Saldo';
                 latCaso.LAT_IntegrationMessage__c = 'Valor da DA é menor que o solicitado.';
             }else{
                 latCaso.LAT_IntegrationMessage__c = '';
                 latCaso.LAT_IntegrationStatus__c = 'Reservado';
             }
         }else{
             latCaso.LAT_IntegrationMessage__c = 'Esse número de DA esta com status diferente de Aprovado ou Em Processo.';
             latCaso.LAT_IntegrationStatus__c = 'Erro de integração';
         }
         //Atualiza campo de consulta
        latCaso.LAT_InquiryHeld__c = true;
          
          //Atualiza o caso
        update latCaso;
          
          //Retorna na tela do usuário que a consulta foi realiza com sucesso.
        return 'Consulta realizada com sucesso!';
      }
      return null;
    }
    
    //Cria um retorno falso caso seja uma classe de teste que execute o código.
    private static BalanceCheck.PMEWS010_ExecuteResponse_element callOutMock(){
        BalanceCheck.PMEWS010_ExecuteResponse_element lReturn = new BalanceCheck.PMEWS010_ExecuteResponse_element();
        lReturn.Codret = '00';
        lReturn.Domsta = 'A';
        lReturn.Msgret = '';
        lReturn.Saldo = 1000000;
        return lReturn;
    } 
}