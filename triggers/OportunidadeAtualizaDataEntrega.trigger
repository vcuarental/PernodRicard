/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* NAME: OportunidadeAtualizaDataEntrega.trigger
* AUTHOR:                                               DATE: 
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger OportunidadeAtualizaDataEntrega on Opportunity (before update) {

	//Check if this trigger is bypassed by SESAME (data migration Brazil)
	if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

		//Declaração de variáveis
		Set< Id > setRecTypeOpp = new Set< Id >();
		List< String > lListOppIDs = new List< String >();
		
		//Recupera os ids de tipo de registro de ooportunidade
		setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao'));
		setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao_do_cabecalho'));
		setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Nova_oportunidade'));
		
		setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_1_NewOrder_ARG'));
		setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_2_NewOrder_URU'));
		setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_3_HeaderBlocked_ARG'));
		setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_4_HeaderBlocked_URU'));
		setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_5_OrderBlocked_ARG'));
		setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_6_OrderBlocked_URU'));
		
		for( Opportunity x : Trigger.New ){
			if(setRecTypeOpp.contains( x.RecordTypeId )){
				lListOppIDs.add( x.Id );
			}
		}
		
		if(!lListOppIDs.isEmpty()){
			OportunidadeDataEntrega lCalcula = new OportunidadeDataEntrega( lListOppIDs );
			for( Opportunity x : Trigger.New ){
				if(setRecTypeOpp.contains( x.RecordTypeId )){
					lCalcula.atualizaPedido( x );
				}
			}
		}
	}
}