/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Recupera os IDS dos gerentes de um usuário atraves do Id do proprietário do 
* Caso.
*
* NAME: ContratoCopiaIdGerenteRegionalArea.trigger
* AUTHOR:                                               DATE: 
*
* MAINTENANCE: 
* AUTHOR: CARLOS CARVALHO                               DATE: 14/03/2012
*
* MAINTENANCE: INSERIDO MÉTODO RecordTypeForTest.
* AUTHOR: CARLOS CARVALHO                               DATE: 07/01/2013
********************************************************************************/
trigger CasoCopiaIdGerenteRegionalArea on Case (before insert, before update) {
    String i = '';
/*    

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
  
    //Declaração de variáveis.
    List<String> listIdOwnerObjeto = new List<String>();
    Map< String, User > userMap = new Map< String, User >();
    List<User> listUser = new List<User>();
    Set< Id > setRecType = new Set< Id >();
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Alteracao_rota_de_promotor') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Alteracao_cadastro_de_clientes') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Cancelar_D_A_no_sistema_ME') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Cliente_inadimplente') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_aprovacao_de_proposta') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_da_diretoria') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_de_distrato_procurador') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_do_procurador') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Negociacao_de_cancelamento') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Processo_de_prorrogacao') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'Contrato_Proposta_de_renovacao') );
    setRecType.add( RecordTypeForTest.getRecType('Case', 'LAT_BR_ContractProrogation') );
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
    
    set<Id> setIdContaCaso = new set<Id>();
    
    for(Case caso : trigger.new){
        if( caso.OwnerId != null && setRecType.contains( caso.RecordTypeId ) ){
            listIdOwnerObjeto.add(caso.OwnerId);
            setIdContaCaso.add(caso.AccountId);
        }
    }
    
    // <Marcos 14.03.13>
    // Tipos de registro nos quais tem atribuições diferentes de gerentes
    set <Id> setRecTypeKAM = new set<id>();
    setRecTypeKAM.add( RecordTypeForTest.getRecType('Case', 'Alteracao_cadastro_de_clientes') );
    setRecTypeKAM.add( RecordTypeForTest.getRecType('Case', 'Novo_cadastro_de_cliente') );
    // </Marcos>
    
    if(listIdOwnerObjeto.size() >0)
    {
        listUser = UserDAO.getInstance().getListUserById(listIdOwnerObjeto);
        
        for(User u:listUser){
            userMap.put( u.id, u );
        }
        
        map<Id,Account> mapAccCaso = new map<Id, Account>(
                [SELECT Id, Regional_Manager__c, Area_Manager__c, Customer_is_KA__c FROM Account WHERE Id = :setIdContaCaso]);
        
        for(Case caso:trigger.new){
            User lUser = userMap.get( caso.OwnerId );
            if ( lUser == null ) continue;
            //<Marcos 14.03.2013>
            Account contaCaso = mapAccCaso.get( caso.AccountId );
            if( contaCaso == null ) continue;
            if ( setRecTypeKAM.contains(caso.RecordTypeId) ){
              if (contaCaso.Regional_Manager__c != null) { caso.Regional_Manager__c = contaCaso.Regional_Manager__c; }
              if (contaCaso.Area_Manager__c != null) { caso.Area_Manager__c = contaCaso.Area_Manager__c; }
            } else {
              caso.Regional_Manager__c = lUser.gerente_regional__c;
              caso.Area_Manager__c = lUser.gerente_de_area__c;
            }
            caso.Manager__c = lUser.ManagerId;
            
            caso.Customer_is_KA__c = contaCaso.Customer_is_KA__c;
            //</Marcos>
        }
    } 
  }
*/
}