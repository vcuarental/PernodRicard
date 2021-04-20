/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Recupera os IDS dos gerentes de um usuário atraves do Id do proprietário do 
* Contrato.
*
* NAME: ContratoCopiaIdGerenteRegionalArea.trigger
* AUTHOR:                                               DATE: 
*
* MAINTENANCE: 
* AUTHOR: CARLOS CARVALHO                               DATE: 12/03/2012
* AUTHOR: ROGERIO ALVARENGA                             DATE: 26/06/2012
* AUTHOR: MARCOS DOBROWOLSKI                            DATE: 26/12/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS
* AUTHOR: CARLOS CARVALHO                               DATE: 07/01/2013
*
* AUTHOR: CARLOS CARVALHO                               DATE: 21/01/2013
* DESC: REMOVIDO TRECHO: if ( lCon.Status__c == 'Ativo' ).
*
* AUTHOR: MARCOS DOBROWOLSKI                            DATE: 15/03/2013
* DESC: Comentados os códigos de atribuição de KAM. Atribuidos Gerente Regional
*       e Gerente de Área a partir dos mesmos do Usuário
********************************************************************************/
trigger ContratoCopiaIdGerenteRegionalArea on LAT_Contract__c (before insert, before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

    //Declaração de variáveis.
    List<String> listContractOrigId = new List<String>();
    List<String> listIdOwnerContract = new List<String>();
    List< String > lListAccId = new List< String >();
    Map< String, User > userMap = new Map< String, User >();
    List<User> listUser = new List<User>();
    Id lRecIdOn = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on' );
    Id lRecIdOff = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_off' );
    Set< Id > setRecTypeLatCon = new Set< Id >();
    List< String > listRecTypeAcc = new List< String >();
    
    //Recupera os Ids dos tipos de registro do objeto Account
    listRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account' , 'Eventos' ) );
    listRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account' , 'Off_Trade' ) );
    listRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account' , 'On_Trade' ) );
    
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
        
    // <Marcos>
    //List<Account> lstAcc = new List<Account>();
    //Map<Id, Account> mapAccount = new Map<Id, Account>();
    //Set<String> setSubChannel = new Set<String>{ 'KA', 'C&C Makro', 'C&C Atacadao' }; 
    // </Marcos>
    for(LAT_Contract__c lCon : trigger.new){
      if( setRecTypeLatCon.contains( lCon.RecordTypeId )){
          if( ContratoSemaphoro.setNewCode( lCon.Id, 'ContratoCopiaIdGerenteRegionalArea' ) ) continue;
          /*if( ContratoSemaphoro.hasExec( lCon.Id )){
             continue;
          }*/
          if ( lCon.Contrato_original__c != null ){
            listContractOrigId.add( lCon.Contrato_original__c );
          }
          if(lCon.OwnerId != null){
                listIdOwnerContract.add(lCon.OwnerId);
            }
          // <Marcos>
          //if ( lCon.Status__c == 'Ativo' ) lListAccId.add( lCon.Account__c );
          // </Marcos>
          lListAccId.add( lCon.Account__c );
          
          if ( Trigger.isInsert && ( lCon.RecordTypeId == lRecIdOn || lCon.RecordTypeId == lRecIdOff ) )
          {
            lCon.CustomerSigned__c = null;
            lCon.Signatario_do_cliente__c = null;
            lCon.CustomerSignedDate__c = null;
          }
      }
    }
    
  if(listIdOwnerContract.size() >0)
  {
    listUser = UserDAO.getInstance().getListUserById(listIdOwnerContract);
    for(User u:listUser)
    {
      userMap.put( u.id, u );
    }
    
    // <Marcos>
    /*if (lListAccId.size() > 0){
        lstAcc = [SELECT Id, Sub_Channel_Rating__r.Name, Parent.Owner.Gerente_regional__c, Name,
                  Parent.Owner.gerente_de_area__c, Owner.Gerente_regional__c, Owner.gerente_de_area__c 
                FROM Account WHERE Id = :lListAccId AND RecordTypeId =: listRecTypeAcc];
      for (Account acc : lstAcc){
        mapAccount.put(acc.Id, acc);
      }
    }*/
    // </Marcos>
    
    for(LAT_Contract__c cont : trigger.new)
    {
      User lUser = userMap.get( cont.OwnerId );
      if ( lUser == null ) continue;
      
      //<Marcos>
      /*Account acc = mapAccount.get( cont.Account__c );
      if ( acc != null ) {
          if ( acc.ParentId != null && setSubChannel.contains( acc.Sub_Channel_Rating__r.Name ) ){
            if( acc.Parent.OwnerId == cont.OwnerId ) cont.Gerente_Regional__c = null;
            else cont.Gerente_Regional__c = acc.Parent.OwnerId;
            
            cont.Gerente_de_area__c = null;//acc.Parent.Owner.Gerente_de_area__c;
          } else {
                cont.Gerente_Regional__c = acc.Owner.gerente_regional__c;
                cont.Gerente_de_area__c = acc.Owner.Gerente_de_area__c;
            }
      }*/
        //<Marcos 15.03.13>
        cont.Gerente_Regional__c = lUser.Gerente_regional__c;
        cont.Gerente_de_area__c = lUser.Gerente_de_area__c;
        //</Marcos 15.03.13>
      //</Marcos> 
      cont.Gerente__c = lUser.ManagerId;
    }
  }
  
  if ( listContractOrigId.size() > 0 )
  {
    List< LAT_Contract__c > lListContractOrig = [ SELECT Tipo_de_contrato__c, StartDate__c, ContractTerm__c 
        FROM LAT_Contract__c WHERE id=:listContractOrigId AND RecordTypeId =: setRecTypeLatCon];
        
        
    Map< String, LAT_Contract__c > lMapContractOrig = new Map< String, LAT_Contract__c >();
    for ( LAT_Contract__c co : lListContractOrig )
    {
      lMapContractOrig.put( co.id, co );
    }
    for(LAT_Contract__c cont:trigger.new)
    {
        if( setRecTypeLatCon.contains( cont.RecordTypeId )){
          LAT_Contract__c co = lMapContractOrig.get( cont.Contrato_original__c );
          if ( co != null )
          {
            cont.Tipo_de_contrato__c = co.Tipo_de_contrato__c;
            cont.StartDate__c = co.StartDate__c;
            cont.ContractTerm__c = co.ContractTerm__c;
          }
        }
    }
  }
  
  if ( lListAccId.size() >0 )
  {
    List< Account > lListAcc = [ SELECT id, Rating FROM account WHERE id=:lListAccId 
        AND Channel__c='On Trade' AND RecordTypeId =: listRecTypeAcc];
        
    Map< String, Account > lMapAcc = new Map< String, Account >();
    for ( Account lAcc : lListAcc )
      lMapAcc.put( lAcc.id, lAcc );
    
    for(LAT_Contract__c cont:trigger.new)
    {  
      Account lAcc = lMapAcc.get( cont.Account__c );
      if ( lAcc != null ) lAcc.Rating = 'Cliente com contrato';
    }
    update lListAcc;
  }
    }
}