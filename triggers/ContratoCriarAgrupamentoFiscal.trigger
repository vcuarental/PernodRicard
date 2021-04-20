/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Trigger que cria o agrupamento fiscal
* NAME: ContratoCriarAgrupamentoFiscal.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 14/09/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 07/01/2013
*******************************************************************************/
trigger ContratoCriarAgrupamentoFiscal on LAT_Contract__c (after update) {
//    Check if this trigger is bypassed by SESAME (data migration Brazil)
	if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
	
		//Declaração de variáveis
		Set< Id > setRecTypeLatCon = new Set< Id >();
		List< String > listRecTypeInv = new List< String >();
		String idRecTypeAgr = RecordTypeForTest.getRecType( 'Agrupamento_Fiscal_Year__c' , 'BRA_Standard');
		List< LAT_Contract__c > lContratos = new List< LAT_Contract__c >();
		List< String > lListContratoID = new List< String >();

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
		//Recupera os Ids dos tipos de registro do objeto Investimento_Bonificacao_e_Pagamento__c
		listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
		listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );


		for ( LAT_Contract__c c : Trigger.new )
			if ( setRecTypeLatCon.contains( c.RecordTypeId ) && c.Status__c == 'Em aprovação' 
				&& c.Status__c != Trigger.oldMap.get( c.id ).Status__c )
			{
			lContratos.add( c );
			lListContratoID.add( c.id );
			}

		if ( lContratos.size() == 0 ) return;

		List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = [ SELECT LAT_contract__c, Ano_Fiscal__c, 
			Ano_fiscal_calculado__c, Custo_Bonificado__c, Valor_R__c, Volume_Cx__c 
			FROM Investimento_Bonificacao_e_Pagamento__c WHERE LAT_contract__c=:lListContratoID 
			AND RecordTypeId =: listRecTypeInv order by LAT_contract__c, Ano_Fiscal__c ];

		if ( lListIBP.size() == 0 ) return;

		Map< String, Agrupamento_Fiscal_Year__c > lMapAgrFiscal = new Map< String, Agrupamento_Fiscal_Year__c >();
		List<Agrupamento_Fiscal_Year__c> listAFY = [SELECT id, Name, Ano_Fiscal__c, LAT_Contract__c  FROM Agrupamento_Fiscal_Year__c WHERE LAT_Contract__c IN: lListContratoID];
		
		for ( Investimento_Bonificacao_e_Pagamento__c lIBP : lListIBP ){
			boolean isDuplicated = false; 
			for(Agrupamento_Fiscal_Year__c afi: listAFY){
				if(lIBP.LAT_contract__c == afi.LAT_Contract__c && lIBP.Ano_Fiscal__c == afi.Ano_Fiscal__c){
					isDuplicated = true;
					break;
				}
			}
			if(!isDuplicated){	
				String lKey = lIBP.LAT_contract__c + '|' + lIBP.Ano_Fiscal__c;
				Agrupamento_Fiscal_Year__c lAgrFiscal = lMapAgrFiscal.get( lKey );
				if ( lAgrFiscal == null ){
				
					lAgrFiscal = new Agrupamento_Fiscal_Year__c();
					lAgrFiscal.LAT_Contract__c = lIBP.LAT_contract__c;
					lAgrFiscal.Ano_Fiscal__c = lIBP.Ano_Fiscal__c;
					lAgrFiscal.Ano_fiscal_calculadoag__c = String.valueOf( lIBP.Ano_fiscal_calculado__c );
					lAgrFiscal.valor_total__c = 0;
					lAgrFiscal.Volume_Total__c = 0;
					lAgrFiscal.RecordTypeId = idRecTypeAgr;
					lMapAgrFiscal.put( lKey, lAgrFiscal );
				}

				lAgrFiscal.CasoEspecial__c = true;
				
				if ( lIBP.Custo_Bonificado__c > 0 ) lAgrFiscal.valor_total__c += lIBP.Custo_Bonificado__c;
				if ( lIBP.Valor_R__c > 0 ) lAgrFiscal.valor_total__c += lIBP.Valor_R__c;
				if ( lIBP.Volume_Cx__c > 0 ) lAgrFiscal.Volume_Total__c += lIBP.Volume_Cx__c;
			}
		}
		insert lMapAgrFiscal.values();
	}
}