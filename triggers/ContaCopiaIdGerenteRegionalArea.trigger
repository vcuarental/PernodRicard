/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Recupera os IDS dos gerentes de um usuário atraves do Id do proprietário da 
* Conta.
*
* NAME: ContratoCopiaIdGerenteRegionalArea.trigger
* AUTHOR:                                               DATE: 
*
* MAINTENANCE: 
* AUTHOR: CARLOS CARVALHO                               DATE: 14/03/2012
* AUTHOR: ROGERIO ALVARENGA                             DATE: 26/06/2012
* AUTHOR: MARCOS DOBROWOLSKI                            DATE: 21/12/2012
*
* AUTHOR: CARLOS CARVALHO                               DATE: 07/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*
* AUTHOR: CARLOS CARVALHO                               DATE: 21/01/2013
* DESC: INSERIDO ELSE NO CÓDIGO.
*
* AUTHOR: MARCOS DOBROWOLSKI                            DATE: 21/01/2013
* DESC: Gerente de Area recebia null. Agora recebe o gerente de Area do Usuário
********************************************************************************/
trigger ContaCopiaIdGerenteRegionalArea on Account (before insert, before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
 
    //Declaração de variáveis.
    List<String> listIdOwnerAccount = new List<String>();
    Map<String, String> mapGerenteRegional = new Map<String, String>();
    Map<String, String> mapGerenteArea = new Map<String, String>();
    List<User> listUser = new List<User>();
    List< Account > listAccount = new List< Account >();
    Map< String, User > userMap = new Map< String, User >();
    //Set<Id> setIdsRecType = Global_RecordTypeCache.getRtIdSet('Account', new set<String>{'Eventos', 'Off_Trade', 'On_Trade'});
    Set<Id> setIdsRecType = Global_RecordTypeCache.getRtIdSet('Account', AP01_Account_BR.BR_RECORDTYPES);
    String idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
    
    // <Marcos>
    //Set de tipos de subchannel utilizados
    //20131202 - LF - Eliminação doe processo de HV
    //Set< String > setSubChannel = new Set<String>{'KA', 'C&C Makro', 'C&C Atacadao','Varejo Regional'};
    Set< String > setSubChannel = new Set<String>{'X'};
   
    //Lista de Classificacao de Subcanais
    List< String > lstSubChannelId = new List< String >();
    List< UDC__c > lstSubChannel = new List< UDC__c >();

    //Lista de Contas Pai
    List< String > lstParentId = new List< String >();
    List< Account > lstParent = new List< Account >();
    //</Marcos>
    
    
    for(Account acc : trigger.new){
        if( setIdsRecType.contains( acc.RecordTypeId ) ){
            if(acc.OwnerId != null){
                listIdOwnerAccount.add(acc.OwnerId);
                listAccount.add( acc );
            }
            // <Marcos>
            if ( acc.Sub_Channel_Rating__c != null ) lstSubChannelId.add(acc.Sub_Channel_Rating__c);
            if ( acc.ParentId != null ) lstParentId.add(acc.ParentId);
            //</Marcos>
        }
    }
    // <Marcos>
	// Cidade
        List< String > lListCidadeName = new List< String >();
        lListCidadeName.add( 'BELFORD ROXO' );
        lListCidadeName.add( 'DUQUE DE CAXIAS' );
        lListCidadeName.add( 'MESQUITA' );
        lListCidadeName.add( 'NILOPOLIS' );
        lListCidadeName.add( 'NITEROI' );
        lListCidadeName.add( 'NOVA IGUACU' );
        lListCidadeName.add( 'RIO DE JANEIRO' );
        lListCidadeName.add( 'SAO GONCALO' );
        lListCidadeName.add( 'SAO JOAO DE MERITI' );
        lListCidadeName.add( 'DIADEMA' );
        lListCidadeName.add( 'EMBU' );
        lListCidadeName.add( 'GUARULHOS' );
        lListCidadeName.add( 'MAUA' );
        lListCidadeName.add( 'OSASCO' );
        lListCidadeName.add( 'SANTO ANDRE' );
        lListCidadeName.add( 'SAO BERNARDO DO CAMPO' );
        lListCidadeName.add( 'SAO CAETANO DO SUL' );
        lListCidadeName.add( 'SAO PAULO' );
        lListCidadeName.add( 'TABOAO DA SERRA' );

    List<UDC__c> todasLasUDCaUsar = [SELECT Id, Name, RecordTypeId, CodDefUsuario__c, CodProd__c, codUs__c FROM UDC__c 
                                  WHERE (
									  	(Id = :lstSubChannelId )
								  	  	OR (CodProd__c='01' AND codUs__c='11')
										OR (CodProd__c='01' AND codUs__c='04')
										OR (CodProd__c='00' AND codUs__c='CT' AND Name=:lListCidadeName)
										OR (CodProd__c='01' AND codUs__c='01')
								  )
								  AND RecordTypeId =: idRecTypeUDC];

    // Query e Mapa das classificações de SubChannel
    Map<Id, UDC__c> mapSubChannel = new Map<Id, UDC__c>();
    if ( lstSubChannelId.size() > 0 )
    {
		for(UDC__c subChannel : todasLasUDCaUsar){
			if(lstSubChannelId.contains(subChannel.Id)){
				mapSubChannel.put(subChannel.Id, subChannel);
			}	
        }
        /*
		for(UDC__c subChannel : [SELECT Id, Name FROM UDC__c WHERE Id = :lstSubChannelId 
         	 AND RecordTypeId =: idRecTypeUDC] ){
          	mapSubChannel.put(subChannel.Id, subChannel);
        }
		*/
    }
      
      // Query e Mapa de Parent
      Map<Id, Account> mapParent = new Map<Id, Account>();
      if ( lstParentId.size() > 0 )
      {
          for (Account parent : [ SELECT Id, OwnerId, Owner.Gerente_de_area__c, Owner.gerente_regional__c 
            FROM Account WHERE Id = :lstParentId AND RecordTypeId =: setIdsRecType]){
            mapParent.put(parent.Id, parent);
          }
      }
      
    //</Marcos> 
    
    if(listIdOwnerAccount.size() >0)
    {
        for(User u : UserDAO.getInstance().getListUserById(listIdOwnerAccount) ){
            userMap.put( u.id, u );
        }
        // Regiao Geografica
		List< UDC__c > lListReg = new List< UDC__c >();
		for(UDC__c udc : todasLasUDCaUsar){
			if(udc.CodProd__c=='01' && udc.CodUs__c=='11'){
				lListReg.add(udc);
			}
		}
		/*
        List< UDC__c > lListReg = [ SELECT CodDefUsuario__c, id FROM UDC__c 
            WHERE CodProd__c='01' AND codUs__c='11' AND RecordTypeId =: idRecTypeUDC];*/
            
        Map< String, id > lMapReg = new Map< String, id >();
        for ( UDC__c lUdc : lListReg )
          lMapReg.put( lUdc.CodDefUsuario__c, lUdc.id );
          
        // Area Nielsen
		List< UDC__c > lListNielsen = new List< UDC__c >();
		for(UDC__c udc : todasLasUDCaUsar){
			if(udc.CodProd__c=='01' && udc.codUs__c=='04'){
				lListNielsen.add(udc);
			}
		}
		/*
        List< UDC__c > lListNielsen = [ SELECT CodDefUsuario__c, id FROM UDC__c 
            WHERE CodProd__c='01' AND codUs__c='04' AND RecordTypeId =: idRecTypeUDC ];*/
            
        Map< String, id > lMapNielsen = new Map< String, id >();
        for ( UDC__c lUdc : lListNielsen )
          lMapNielsen.put( lUdc.CodDefUsuario__c, lUdc.id );
          
        
        
		List< UDC__c > lListCidade = new List< UDC__c >();
		for(UDC__c udc : todasLasUDCaUsar){
			if(udc.CodProd__c=='00' && udc.codUs__c=='CT' && lListCidadeName.contains(udc.Name)){
				lListCidade.add(udc);
			}
		}
		/*
        List< UDC__c > lListCidade = [ SELECT id FROM UDC__c WHERE CodProd__c='00' AND codUs__c='CT' 
            AND name=:lListCidadeName AND RecordTypeId =: idRecTypeUDC];*/
            
        Set< Id > lMapCidade = new Set< id >();
        for ( UDC__c lUdc : lListCidade )
          lMapCidade.add( lUdc.id );
          
        // Regional do Usuário
		List< UDC__c > lListRegional = new List< UDC__c >();
		for(UDC__c udc : todasLasUDCaUsar){
			if(udc.CodProd__c=='01' && udc.codUs__c=='01'){
				lListRegional.add(udc);
			}
		}
		/*
        List< UDC__c > lListRegional = [ SELECT Name, id FROM UDC__c 
            WHERE CodProd__c='01' AND codUs__c='01' AND RecordTypeId =: idRecTypeUDC];*/
            
        Map< String, id > lMapRegional = new Map< String, id >();
        for ( UDC__c lUdc : lListRegional )
          lMapRegional.put( lUdc.Name, lUdc.id );
        
        
        for( Account acc : listAccount ){
                User lUser = userMap.get( acc.OwnerId );
                if ( lUser == null ) continue;
                // <Marcos>
                if ( acc.Sub_Channel_Rating__c != null )
                {
                    UDC__c subChannel = mapSubChannel.get(acc.Sub_Channel_Rating__c);
                    
                    if( acc.ParentId != null && setSubChannel.contains( subChannel.Name ) ){
                        Account parent = mapParent.get( acc.ParentId );
                        
                        if( acc.OwnerId == parent.OwnerId) {
                          if (acc.Type == 'Outros'){
                            acc.Regional_Manager__c = null;
                          } else {
                             acc.Regional_Manager__c = lUser.gerente_regional__c;
                             acc.Area_Manager__c = lUser.gerente_de_area__c;
                          }
                        } else {
                          acc.Regional_Manager__c = parent.OwnerId;
                        }
                        
                        acc.Area_Manager__c = lUser.Gerente_de_area__c; // Alterado de null para gerente do user em 14/03/13
                        
                        acc.Customer_is_KA__c = true;
                        
                    } else {
                        acc.Regional_Manager__c = lUser.gerente_regional__c;
                        acc.Area_Manager__c = lUser.gerente_de_area__c;
                    }
                    
                }else {//Carlos Modification - 21/01/2013
                    acc.Regional_Manager__c = lUser.gerente_regional__c;
                    acc.Area_Manager__c = lUser.gerente_de_area__c;
                }//End Carlos Modification - 21/01/2013
                // </Marcos>
                
                Id lReg = lMapRegional.get( lUser.Regional_de_vendas__c );
                if ( lReg != null && acc.Regional__c == null ) acc.Regional__c = lReg; 
                
                String lRegiao;
                if ( acc.Revenue_UF__c == 'SP' || acc.Revenue_UF__c == 'RJ' 
                || acc.Revenue_UF__c == 'MG'|| acc.Revenue_UF__c == 'ES' )
                  lRegiao = 'SE';
                else if ( acc.Revenue_UF__c == 'RS' || acc.Revenue_UF__c == 'PR'
                || acc.Revenue_UF__c == 'SC' )
                  lRegiao = 'SU';
                else if ( acc.Revenue_UF__c == 'DF' || acc.Revenue_UF__c == 'GO'
                || acc.Revenue_UF__c == 'MS' || acc.Revenue_UF__c == 'MT' )
                  lRegiao = 'CO';
                else if ( acc.Revenue_UF__c == 'AL' || acc.Revenue_UF__c == 'BA'
                || acc.Revenue_UF__c == 'CE' || acc.Revenue_UF__c == 'MA'
                || acc.Revenue_UF__c == 'PB' || acc.Revenue_UF__c == 'PE'
                || acc.Revenue_UF__c == 'PI' || acc.Revenue_UF__c == 'RN'
                || acc.Revenue_UF__c == 'SE' )
                  lRegiao = 'NE';
                else lRegiao = 'NO';
                  
                acc.Customer_Geographic_Region__c = lMapReg.get( lRegiao );
                
                String lNielsen = '0';
                if ( acc.Revenue_UF__c == 'AL' || acc.Revenue_UF__c == 'BA' || acc.Revenue_UF__c == 'CE' 
                || acc.Revenue_UF__c == 'PB' || acc.Revenue_UF__c == 'PE' || acc.Revenue_UF__c == 'RN'
                || acc.Revenue_UF__c == 'SE' )
                  lNielsen = '1';
                else if ( acc.Revenue_UF__c == 'RJ' && lMapCidade.contains( acc.Revenue_City__c ) )
                  lNielsen = '3';
                else if ( acc.Revenue_UF__c == 'RJ' || acc.Revenue_UF__c == 'MG' || acc.Revenue_UF__c == 'ES' )
                  lNielsen = '2';
                else if ( acc.Revenue_UF__c == 'SP' && lMapCidade.contains( acc.Revenue_City__c ) )
                  lNielsen = '4';
                else if ( acc.Revenue_UF__c == 'SP' )
                  lNielsen = '5';
                else if ( acc.Revenue_UF__c == 'RS' || acc.Revenue_UF__c == 'PR' || acc.Revenue_UF__c == 'SC' )
                  lNielsen = '6';
                else if ( acc.Revenue_UF__c == 'DF' || acc.Revenue_UF__c == 'GO' || acc.Revenue_UF__c == 'MS' )
                  lNielsen = '7';
                
                acc.Nielsen_Area__c = lMapNielsen.get( lNielsen );
        }
    }
 }

}