/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Trigger que atualiza alguns campos em contrato para o tratamento do ROI (Return
* On Investiment)
* NAME: ContratoROI.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 16/07/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/

trigger ContratoROI on LAT_Contract__c (before insert, before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

    //Declaração de variáveis
    Set< Id > setRecTypeAcc = new Set< Id >();
    List< String > listRecTypeInv = new List< String >();
    List< String > lListIDs = new List< String >();
    List< String > lListAccIDs = new List< String >();
    Set< Id > setRecTypeLatCon = new Set < Id >();
    
    // Tipo_segmentacao_on_trade__c
    // Recuperando tipos de registro
    Id lRecBoniProd = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
    Id lRecAlteraOn = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on' );
    Id lRecAssinaOn = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato' );
    Id lRecAtivaOn = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato' );
    Id lRecAsAprOn = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao') ;
    
    //Recupera os Ids dos tipos de registro do objeto Account
    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));
    
    //Recupera os Ids dos tipos de registro do objeto Investimento_Bonificacao_e_Pagamento__c
    listRecTypeInv.add( lRecBoniProd );
    listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
    
    //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on') );
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato') );
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato') );
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
    
    //Recupera os Ids dos tipos de registro do objeto Rateio_do_Contrato__c
    String idRecTypeRateio = RecordTypeForTest.getRecType('Rateio_do_Contrato__c', 'BRA_Standard');
    
    // Tipos de registros de contrato de ON TRADE
    //OK - Alteracao_de_contrato_on
    //OK - Assinatura_de_contrato
    //Alteracao_de_contrato_aprovada_On_Trade
    //Assinatura_de_contrato_aprovada
    //Assinatura_de_contrato_com_aprovacao
    //OK - Ativacao_de_contrato
    //Cancelamento_de_contrato_On_Trade
    //Cancelamento_de_contrato_aprovado_on
        
    // Agrupamento de Contrato
    for ( LAT_Contract__c ct : trigger.new )
    {
       if (ct.RecordTypeId == lRecAlteraOn || ct.RecordTypeId == lRecAssinaOn || ct.RecordTypeId == lRecAtivaOn || ct.RecordTypeId == lRecAsAprOn)
       {
           lListIDs.add( ct.id );
           lListAccIDs.add( ct.Account__c );
       }
    }
    if ( lListAccIDs.size() == 0 ) return;
    
    // Buscar contas relacionadas e colocar em um mapa
    List< Account > lListAcc = [ SELECT Segmentation_Type_on_trade__c, 
        Rating_segmentation_targert_market__c, Revenue_UF__c FROM Account 
        WHERE id =: lListAccIDs AND RecordTypeId =: setRecTypeAcc];
        
    Map< String, Account > lMapAcc = new Map< String, Account >();
    for ( Account acc : lListAcc )
    {
        lMapAcc.put( acc.id, acc );
    }
    
    List< Investimento_Bonificacao_e_Pagamento__c > lListInvBonif = 
        [ SELECT id, LAT_contract__c, RecordTypeId, Valor_R__c, Perc_de_Rateio__c, Valor_Percebido__c, 
                Custo_Bonificado__c 
        FROM Investimento_Bonificacao_e_Pagamento__c 
        WHERE LAT_contract__c =:lListIDs
        AND RecordTypeId =: listRecTypeInv];
        

    Map< String, List< Investimento_Bonificacao_e_Pagamento__c > > lMapContract = new Map< String, List< Investimento_Bonificacao_e_Pagamento__c > >();
    for ( Investimento_Bonificacao_e_Pagamento__c ibp : lListInvBonif )
    {
        List< Investimento_Bonificacao_e_Pagamento__c > lList = lMapContract.get( ibp.LAT_contract__c );
        if ( lList == null )
        {
            lList = new List< Investimento_Bonificacao_e_Pagamento__c >();
            lMapContract.put( ibp.LAT_contract__c, lList );
        }
        lList.add( ibp );
    }
    
    // Buscar dados do rateio do contrato
    List< Rateio_do_Contrato__c > lListRateio = 
        [ SELECT LAT_Contract__c, Perc_de_Rateio__c FROM Rateio_do_Contrato__c 
          WHERE LAT_Contract__c =: lListIDs AND RecordTypeId =: idRecTypeRateio];
          
          
    Map< ID, decimal > lMapRateio = new Map< ID, decimal >();
    for ( Rateio_do_Contrato__c rateio : lListRateio )
    {
        decimal lValor = lMapRateio.get( rateio.LAT_Contract__c );
        if ( lValor == null ) lValor = 0;
        lValor += rateio.Perc_de_Rateio__c;
        lMapRateio.put( rateio.LAT_Contract__c, lValor );
    }
    
    // Loop de execução
    for ( LAT_Contract__c c : trigger.new )
    {
       if (c.RecordTypeId == lRecAlteraOn || c.RecordTypeId == lRecAssinaOn || c.RecordTypeId == lRecAtivaOn || c.RecordTypeId == lRecAsAprOn)
       {
        Account lAcc = lMapAcc.get( c.Account__c );
        
        // Somatória de valores
        c.ROI_Total_Contrato__c = 0;
        c.ROI_Bonificacao__c = 0;
        c.ROI_Total_Dinheiro__c = 0;
        c.ROI_Total_do_Rateio__c = 0;
        c.ROI_Custo_Total_Bonificado__c = 0;
        List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = lMapContract.get( c.id );
        if ( lListIBP != null )
        {
            
            for ( Investimento_Bonificacao_e_Pagamento__c ibp : lListIBP )
            {
                
                if ( ibp.RecordTypeId == lRecBoniProd )
                {
                    if ( ibp.Valor_Percebido__c != null ) c.ROI_Total_Contrato__c += ibp.Valor_Percebido__c;
                    if ( ibp.Valor_Percebido__c != null ) c.ROI_Bonificacao__c += ibp.Valor_Percebido__c;
                    if ( ibp.Custo_Bonificado__c != null ) c.ROI_Custo_Total_Bonificado__c += ibp.Custo_Bonificado__c;
                }
                else
                {
                    
                    if ( ibp.Valor_R__c != null ) c.ROI_Total_Dinheiro__c += ibp.Valor_R__c;
                }
                
                // 6/ago/2012 - João Lopes
                // Atualiza o total do contrato. Somente se houver valores a atualizar.
                // 25/set/2012 - João Lopes
                // Alterado do c.ROI_Total_Contrato para c.ROI_Custo_Total_Bonificado__c
                if (c.ROI_Custo_Total_Bonificado__c+c.ROI_Total_Dinheiro__c > 0)
                {
                    c.Valor_do_contrato__c = c.ROI_Custo_Total_Bonificado__c+c.ROI_Total_Dinheiro__c ;
                }
                
             }
        }
    
            // NetSales
            c.ROI_NetSales_Absolut_100__c = ContratoROI_Aux.getNetSales( c.Absolut_100_periodo__c, LAT_Contract__c.ROI_NetSales_Absolut_100__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Absolut_Elyx__c = ContratoROI_Aux.getNetSales( c.Absolut_Elyx_periodo__c, LAT_Contract__c.ROI_NetSales_Absolut_Elyx__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Absolut_Flavors__c = ContratoROI_Aux.getNetSales( c.Absolut_Flavors_periodo__c, LAT_Contract__c.ROI_NetSales_Absolut_Flavors__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Absolut_Vodka__c = ContratoROI_Aux.getNetSales( c.Absolut_Vodka_periodo__c, LAT_Contract__c.ROI_NetSales_Absolut_Vodka__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Ballantine_s_12Y__c = ContratoROI_Aux.getNetSales( c.Ballantines_12Y_periodo__c, LAT_Contract__c.ROI_NetSales_Ballantine_s_12Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Ballantine_s_17Y__c = ContratoROI_Aux.getNetSales( c.Ballantines_17Y_periodo__c, LAT_Contract__c.ROI_NetSales_Ballantine_s_17Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Ballantine_s_21Y__c = ContratoROI_Aux.getNetSales( c.Ballantines_21Y_periodo__c, LAT_Contract__c.ROI_NetSales_Ballantine_s_21Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Ballantine_s_30Y__c = ContratoROI_Aux.getNetSales( c.Ballantines_30Y_periodo__c, LAT_Contract__c.ROI_NetSales_Ballantine_s_30Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Ballantine_s_Finest__c = ContratoROI_Aux.getNetSales( c.Ballantines_Finest_periodo__c, LAT_Contract__c.ROI_NetSales_Ballantine_s_Finest__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Cachaca_Janeiro__c = ContratoROI_Aux.getNetSales( c.Cachaca_Janeiro_periodo__c, LAT_Contract__c.ROI_NetSales_Cachaca_Janeiro__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Cachaca_Sao_Francisco__c = ContratoROI_Aux.getNetSales( c.Cachaca_Sao_Francisco_periodo__c, LAT_Contract__c.ROI_NetSales_Cachaca_Sao_Francisco__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Chivas_Regal_12_Years__c = ContratoROI_Aux.getNetSales( c.Chivas_Regal_12_Years_periodo__c, LAT_Contract__c.ROI_NetSales_Chivas_Regal_12_Years__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Chivas_Regal_18_Years__c = ContratoROI_Aux.getNetSales( c.Chivas_Regal_18_Years_periodo__c, LAT_Contract__c.ROI_NetSales_Chivas_Regal_18_Years__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Chivas_Regal_25_Years__c = ContratoROI_Aux.getNetSales( c.Chivas_Regal_25_Years_periodo__c, LAT_Contract__c.ROI_NetSales_Chivas_Regal_25_Years__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Domecq_Tradicional__c = ContratoROI_Aux.getNetSales( c.Domecq_Tradicional_periodo__c, LAT_Contract__c.ROI_NetSales_Domecq_Tradicional__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Havana_Club_3_Anos__c = ContratoROI_Aux.getNetSales( c.Havana_Club_3_Anos_periodo__c, LAT_Contract__c.ROI_NetSales_Havana_Club_3_Anos__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Havana_Club_7_anos__c = ContratoROI_Aux.getNetSales( c.Havana_Club_7_anos_periodo__c, LAT_Contract__c.ROI_NetSales_Havana_Club_7_anos__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Havana_Club_Anejo_Reserva__c = ContratoROI_Aux.getNetSales( c.Havana_Club_Anejo_Reserva_periodo__c, LAT_Contract__c.ROI_NetSales_Havana_Club_Anejo_Reserva__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Jameson_Standard__c = ContratoROI_Aux.getNetSales( c.Jameson_Standard_periodo__c, LAT_Contract__c.ROI_NetSales_Jameson_Standard__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Jim_Beam_Black__c = ContratoROI_Aux.getNetSales( c.Jim_Beam_Black_periodo__c, LAT_Contract__c.ROI_NetSales_Jim_Beam_Black__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Jim_Beam_White__c = ContratoROI_Aux.getNetSales( c.Jim_Beam_White_periodo__c, LAT_Contract__c.ROI_NetSales_Jim_Beam_White__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Kahlua__c = ContratoROI_Aux.getNetSales( c.Kahlua_periodo__c, LAT_Contract__c.ROI_NetSales_Kahlua__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Malibu_Nacional__c = ContratoROI_Aux.getNetSales( c.Malibu_Nacional_periodo__c, LAT_Contract__c.ROI_NetSales_Malibu_Nacional__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Montilla_Cristal__c = ContratoROI_Aux.getNetSales( c.Montilla_Cristal_periodo__c, LAT_Contract__c.ROI_NetSales_Montilla_Cristal__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Mumm_Champagne__c = ContratoROI_Aux.getNetSales( c.Mumm_Champagne_periodo__c, LAT_Contract__c.ROI_NetSales_Mumm_Champagne__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Mumm_Espumante__c = ContratoROI_Aux.getNetSales( c.Mumm_Espumante_periodo__c, LAT_Contract__c.ROI_NetSales_Mumm_Espumante__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Natu_Nobilis__c = ContratoROI_Aux.getNetSales( c.Natu_Nobilis_periodo__c, LAT_Contract__c.ROI_NetSales_Natu_Nobilis__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Olmeca__c = ContratoROI_Aux.getNetSales( c.Olmeca_periodo__c, LAT_Contract__c.ROI_NetSales_Olmeca__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Orloff__c = ContratoROI_Aux.getNetSales( c.Orloff_periodo__c, LAT_Contract__c.ROI_NetSales_Orloff__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Passport_LBS__c = ContratoROI_Aux.getNetSales( c.Passport_LBS_periodo__c, LAT_Contract__c.ROI_NetSales_Passport_LBS__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Perrier_Jouet__c = ContratoROI_Aux.getNetSales( c.Perrier_Jouet_periodo__c, LAT_Contract__c.ROI_NetSales_Perrier_Jouet__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Perrier_Jouet_1_5L__c = ContratoROI_Aux.getNetSales( c.Perrier_Jouet_1_5L_periodo__c, LAT_Contract__c.ROI_NetSales_Perrier_Jouet_1_5L__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Perrier_Jouet_Belle_Epoque__c = ContratoROI_Aux.getNetSales( c.Perrier_Jouet_Belle_Epoque_periodo__c, LAT_Contract__c.ROI_NetSales_Perrier_Jouet_Belle_Epoque__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Perrier_Jouet_Belle_Epq1_5L__c = ContratoROI_Aux.getNetSales( c.Perrier_Jouet_Belle_Epq1_5L_periodo__c, LAT_Contract__c.ROI_NetSales_Perrier_Jouet_Belle_Epq1_5L__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Royal_Salute__c = ContratoROI_Aux.getNetSales( c.Royal_Salute_periodo__c, LAT_Contract__c.ROI_NetSales_Royal_Salute__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Royal_Salute_38YO__c = ContratoROI_Aux.getNetSales( c.Royal_Salute_38YO_periodo__c, LAT_Contract__c.ROI_NetSales_Royal_Salute_38YO__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Sandeman__c = ContratoROI_Aux.getNetSales( c.Sandeman_periodo__c, LAT_Contract__c.ROI_NetSales_Sandeman__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Teachers__c = ContratoROI_Aux.getNetSales( c.Teachers_periodo__c, LAT_Contract__c.ROI_NetSales_Teachers__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Tezon__c = ContratoROI_Aux.getNetSales( c.Tezon_periodo__c, LAT_Contract__c.ROI_NetSales_Tezon__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Wall_Street__c = ContratoROI_Aux.getNetSales( c.Wall_Street_periodo__c, LAT_Contract__c.ROI_NetSales_Wall_Street__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_NetSales_Wyborowa_Exquisite__c = ContratoROI_Aux.getNetSales( c.Wyborowa_Exquisite_periodo__c, LAT_Contract__c.ROI_NetSales_Wyborowa_Exquisite__c.getDescribe().Name, lAcc.Revenue_UF__c );
        
        // GMDC
        c.ROI_GMDC_Absolut_100__c = ContratoROI_Aux.getGMDC( c.Absolut_100_periodo__c, LAT_Contract__c.ROI_GMDC_Absolut_100__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Absolut_Elyx__c = ContratoROI_Aux.getGMDC( c.Absolut_Elyx_periodo__c, LAT_Contract__c.ROI_GMDC_Absolut_Elyx__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Absolut_Flavors__c = ContratoROI_Aux.getGMDC( c.Absolut_Flavors_periodo__c, LAT_Contract__c.ROI_GMDC_Absolut_Flavors__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Absolut_Vodka__c = ContratoROI_Aux.getGMDC( c.Absolut_Vodka_periodo__c, LAT_Contract__c.ROI_GMDC_Absolut_Vodka__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Ballantine_s_12Y__c = ContratoROI_Aux.getGMDC( c.Ballantines_12Y_periodo__c, LAT_Contract__c.ROI_GMDC_Ballantine_s_12Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Ballantine_s_17Y__c = ContratoROI_Aux.getGMDC( c.Ballantines_17Y_periodo__c, LAT_Contract__c.ROI_GMDC_Ballantine_s_17Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Ballantine_s_21Y__c = ContratoROI_Aux.getGMDC( c.Ballantines_21Y_periodo__c, LAT_Contract__c.ROI_GMDC_Ballantine_s_21Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Ballantine_s_30Y__c = ContratoROI_Aux.getGMDC( c.Ballantines_30Y_periodo__c, LAT_Contract__c.ROI_GMDC_Ballantine_s_30Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Ballantine_s_Finest__c = ContratoROI_Aux.getGMDC( c.Ballantines_Finest_periodo__c, LAT_Contract__c.ROI_GMDC_Ballantine_s_Finest__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Cachaca_Janeiro__c = ContratoROI_Aux.getGMDC( c.Cachaca_Janeiro_periodo__c, LAT_Contract__c.ROI_GMDC_Cachaca_Janeiro__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Cachaca_Sao_Francisco__c = ContratoROI_Aux.getGMDC( c.Cachaca_Sao_Francisco_periodo__c, LAT_Contract__c.ROI_GMDC_Cachaca_Sao_Francisco__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Chivas_Regal_12_Years__c = ContratoROI_Aux.getGMDC( c.Chivas_Regal_12_Years_periodo__c, LAT_Contract__c.ROI_GMDC_Chivas_Regal_12_Years__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Chivas_Regal_18_Years__c = ContratoROI_Aux.getGMDC( c.Chivas_Regal_18_Years_periodo__c, LAT_Contract__c.ROI_GMDC_Chivas_Regal_18_Years__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Chivas_Regal_25_Years__c = ContratoROI_Aux.getGMDC( c.Chivas_Regal_25_Years_periodo__c, LAT_Contract__c.ROI_GMDC_Chivas_Regal_25_Years__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Domecq_Tradicional__c = ContratoROI_Aux.getGMDC( c.Domecq_Tradicional_periodo__c, LAT_Contract__c.ROI_GMDC_Domecq_Tradicional__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Havana_Club_3_Anos__c = ContratoROI_Aux.getGMDC( c.Havana_Club_3_Anos_periodo__c, LAT_Contract__c.ROI_GMDC_Havana_Club_3_Anos__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Havana_Club_7_anos__c = ContratoROI_Aux.getGMDC( c.Havana_Club_7_anos_periodo__c, LAT_Contract__c.ROI_GMDC_Havana_Club_7_anos__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Havana_Club_Anejo_Reserva__c = ContratoROI_Aux.getGMDC( c.Havana_Club_Anejo_Reserva_periodo__c, LAT_Contract__c.ROI_GMDC_Havana_Club_Anejo_Reserva__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Jameson_Standard__c = ContratoROI_Aux.getGMDC( c.Jameson_Standard_periodo__c, LAT_Contract__c.ROI_GMDC_Jameson_Standard__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Jim_Beam_Black__c = ContratoROI_Aux.getGMDC( c.Jim_Beam_Black_periodo__c, LAT_Contract__c.ROI_GMDC_Jim_Beam_Black__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Jim_Beam_White__c = ContratoROI_Aux.getGMDC( c.Jim_Beam_White_periodo__c, LAT_Contract__c.ROI_GMDC_Jim_Beam_White__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Kahlua__c = ContratoROI_Aux.getGMDC( c.Kahlua_periodo__c, LAT_Contract__c.ROI_GMDC_Kahlua__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Malibu_Nacional__c = ContratoROI_Aux.getGMDC( c.Malibu_Nacional_periodo__c, LAT_Contract__c.ROI_GMDC_Malibu_Nacional__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Montilla_Cristal__c = ContratoROI_Aux.getGMDC( c.Montilla_Cristal_periodo__c, LAT_Contract__c.ROI_GMDC_Montilla_Cristal__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Mumm_Champagne__c = ContratoROI_Aux.getGMDC( c.Mumm_Champagne_periodo__c, LAT_Contract__c.ROI_GMDC_Mumm_Champagne__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Mumm_Espumante__c = ContratoROI_Aux.getGMDC( c.Mumm_Espumante_periodo__c, LAT_Contract__c.ROI_GMDC_Mumm_Espumante__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Natu_Nobilis__c = ContratoROI_Aux.getGMDC( c.Natu_Nobilis_periodo__c, LAT_Contract__c.ROI_GMDC_Natu_Nobilis__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Olmeca__c = ContratoROI_Aux.getGMDC( c.Olmeca_periodo__c, LAT_Contract__c.ROI_GMDC_Olmeca__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Orloff__c = ContratoROI_Aux.getGMDC( c.Orloff_periodo__c, LAT_Contract__c.ROI_GMDC_Orloff__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Passport_LBS__c = ContratoROI_Aux.getGMDC( c.Passport_LBS_periodo__c, LAT_Contract__c.ROI_GMDC_Passport_LBS__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Perrier_Jouet__c = ContratoROI_Aux.getGMDC( c.Perrier_Jouet_periodo__c, LAT_Contract__c.ROI_GMDC_Perrier_Jouet__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Perrier_Jouet_1_5L__c = ContratoROI_Aux.getGMDC( c.Perrier_Jouet_1_5L_periodo__c, LAT_Contract__c.ROI_GMDC_Perrier_Jouet_1_5L__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Perrier_Jouet_Belle_Epoque__c = ContratoROI_Aux.getGMDC( c.Perrier_Jouet_Belle_Epoque_periodo__c, LAT_Contract__c.ROI_GMDC_Perrier_Jouet_Belle_Epoque__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Perrier_Jouet_Belle_Epq1_5L__c = ContratoROI_Aux.getGMDC( c.Perrier_Jouet_Belle_Epq1_5L_periodo__c, LAT_Contract__c.ROI_GMDC_Perrier_Jouet_Belle_Epq1_5L__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Royal_Salute__c = ContratoROI_Aux.getGMDC( c.Royal_Salute_periodo__c, LAT_Contract__c.ROI_GMDC_Royal_Salute__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Royal_Salute_38YO__c = ContratoROI_Aux.getGMDC( c.Royal_Salute_38YO_periodo__c, LAT_Contract__c.ROI_GMDC_Royal_Salute_38YO__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Sandeman__c = ContratoROI_Aux.getGMDC( c.Sandeman_periodo__c, LAT_Contract__c.ROI_GMDC_Sandeman__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Teachers__c = ContratoROI_Aux.getGMDC( c.Teachers_periodo__c, LAT_Contract__c.ROI_GMDC_Teachers__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Tezon__c = ContratoROI_Aux.getGMDC( c.Tezon_periodo__c, LAT_Contract__c.ROI_GMDC_Tezon__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Wall_Street__c = ContratoROI_Aux.getGMDC( c.Wall_Street_periodo__c, LAT_Contract__c.ROI_GMDC_Wall_Street__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_GMDC_Wyborowa_Exquisite__c = ContratoROI_Aux.getGMDC( c.Wyborowa_Exquisite_periodo__c, LAT_Contract__c.ROI_GMDC_Wyborowa_Exquisite__c.getDescribe().Name, lAcc.Revenue_UF__c );
  
            // VMA
            if( c.ContractTerm__c == null || c.ContractTerm__c == 0 ) c.ContractTerm__c = 1; 
            c.ROI_VMA_Absolut_100__c = ContratoROI_Aux.getVMA( c.Absolut_100_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Absolut_100__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Absolut_Elyx__c = ContratoROI_Aux.getVMA( c.Absolut_Elyx_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Absolut_Elyx__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Absolut_Flavors__c = ContratoROI_Aux.getVMA( c.Absolut_Flavors_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Absolut_Flavors__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Absolut_Vodka__c = ContratoROI_Aux.getVMA( c.Absolut_Vodka_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Absolut_Vodka__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Ballantine_s_12Y__c = ContratoROI_Aux.getVMA( c.Ballantines_12Y_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Ballantine_s_12Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Ballantine_s_17Y__c = ContratoROI_Aux.getVMA( c.Ballantines_17Y_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Ballantine_s_17Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Ballantine_s_21Y__c = ContratoROI_Aux.getVMA( c.Ballantines_21Y_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Ballantine_s_21Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Ballantine_s_30Y__c = ContratoROI_Aux.getVMA( c.Ballantines_30Y_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Ballantine_s_30Y__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Ballantine_s_Finest__c = ContratoROI_Aux.getVMA( c.Ballantines_Finest_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Ballantine_s_Finest__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Cachaca_Janeiro__c = ContratoROI_Aux.getVMA( c.Cachaca_Janeiro_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Cachaca_Janeiro__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Cachaca_Sao_Francisco__c = ContratoROI_Aux.getVMA( c.Cachaca_Sao_Francisco_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Cachaca_Sao_Francisco__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Chivas_Regal_12_Years__c = ContratoROI_Aux.getVMA( c.Chivas_Regal_12_Years_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Chivas_Regal_12_Years__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Chivas_Regal_18_Years__c = ContratoROI_Aux.getVMA( c.Chivas_Regal_18_Years_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Chivas_Regal_18_Years__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Chivas_Regal_25_Years__c = ContratoROI_Aux.getVMA( c.Chivas_Regal_25_Years_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Chivas_Regal_25_Years__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Domecq_Tradicional__c = ContratoROI_Aux.getVMA( c.Domecq_Tradicional_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Domecq_Tradicional__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Havana_Club_3_Anos__c = ContratoROI_Aux.getVMA( c.Havana_Club_3_Anos_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Havana_Club_3_Anos__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Havana_Club_7_anos__c = ContratoROI_Aux.getVMA( c.Havana_Club_7_anos_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Havana_Club_7_anos__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Havana_Club_Anejo_Reserva__c = ContratoROI_Aux.getVMA( c.Havana_Club_Anejo_Reserva_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Havana_Club_Anejo_Reserva__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Jameson_Standard__c = ContratoROI_Aux.getVMA( c.Jameson_Standard_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Jameson_Standard__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Jim_Beam_Black__c = ContratoROI_Aux.getVMA( c.Jim_Beam_Black_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Jim_Beam_Black__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Jim_Beam_White__c = ContratoROI_Aux.getVMA( c.Jim_Beam_White_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Jim_Beam_White__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Kahlua__c = ContratoROI_Aux.getVMA( c.Kahlua_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Kahlua__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Malibu_Nacional__c = ContratoROI_Aux.getVMA( c.Malibu_Nacional_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Malibu_Nacional__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Montilla_Cristal__c = ContratoROI_Aux.getVMA( c.Montilla_Cristal_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Montilla_Cristal__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Mumm_Champagne__c = ContratoROI_Aux.getVMA( c.Mumm_Champagne_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Mumm_Champagne__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Mumm_Espumante__c = ContratoROI_Aux.getVMA( c.Mumm_Espumante_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Mumm_Espumante__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Natu_Nobilis__c = ContratoROI_Aux.getVMA( c.Natu_Nobilis_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Natu_Nobilis__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Olmeca__c = ContratoROI_Aux.getVMA( c.Olmeca_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Olmeca__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Orloff__c = ContratoROI_Aux.getVMA( c.Orloff_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Orloff__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Passport_LBS__c = ContratoROI_Aux.getVMA( c.Passport_LBS_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Passport_LBS__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Perrier_Jouet__c = ContratoROI_Aux.getVMA( c.Perrier_Jouet_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Perrier_Jouet__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Perrier_Jouet_1_5L__c = ContratoROI_Aux.getVMA( c.Perrier_Jouet_1_5L_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Perrier_Jouet_1_5L__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Perrier_Jouet_Belle_Epoque__c = ContratoROI_Aux.getVMA( c.Perrier_Jouet_Belle_Epoque_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Perrier_Jouet_Belle_Epoque__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Perrier_Jouet_Belle_Epq1_5L__c = ContratoROI_Aux.getVMA( c.Perrier_Jouet_Belle_Epq1_5L_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Perrier_Jouet_Belle_Epq1_5L__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Royal_Salute__c = ContratoROI_Aux.getVMA( c.Royal_Salute_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Royal_Salute__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Royal_Salute_38YO__c = ContratoROI_Aux.getVMA( c.Royal_Salute_38YO_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Royal_Salute_38YO__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Sandeman__c = ContratoROI_Aux.getVMA( c.Sandeman_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Sandeman__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Teachers__c = ContratoROI_Aux.getVMA( c.Teachers_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Teachers__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Tezon__c = ContratoROI_Aux.getVMA( c.Tezon_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Tezon__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Wall_Street__c = ContratoROI_Aux.getVMA( c.Wall_Street_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Wall_Street__c.getDescribe().Name, lAcc.Revenue_UF__c );
            c.ROI_VMA_Wyborowa_Exquisite__c = ContratoROI_Aux.getVMA( c.Wyborowa_Exquisite_periodo__c/c.ContractTerm__c, LAT_Contract__c.ROI_VMA_Wyborowa_Exquisite__c.getDescribe().Name, lAcc.Revenue_UF__c );

            decimal lVMATotal = c.ROI_VMA_Absolut_100__c + c.ROI_VMA_Absolut_Elyx__c + c.ROI_VMA_Absolut_Flavors__c
                              + c.ROI_VMA_Absolut_Vodka__c + c.ROI_VMA_Ballantine_s_12Y__c + c.ROI_VMA_Ballantine_s_17Y__c 
                              + c.ROI_VMA_Ballantine_s_21Y__c + c.ROI_VMA_Ballantine_s_30Y__c 
                              + c.ROI_VMA_Ballantine_s_Finest__c+ + c.ROI_VMA_Cachaca_Janeiro__c
                              + c.ROI_VMA_Cachaca_Sao_Francisco__c + c.ROI_VMA_Chivas_Regal_12_Years__c 
                              + c.ROI_VMA_Chivas_Regal_18_Years__c + c.ROI_VMA_Chivas_Regal_25_Years__c 
                              + c.ROI_VMA_Domecq_Tradicional__c + c.ROI_VMA_Havana_Club_3_Anos__c
                              + c.ROI_VMA_Havana_Club_7_anos__c + c.ROI_VMA_Havana_Club_Anejo_Reserva__c 
                              + c.ROI_VMA_Jameson_Standard__c + c.ROI_VMA_Jim_Beam_Black__c 
                              + c.ROI_VMA_Jim_Beam_White__c + c.ROI_VMA_Kahlua__c 
                              + c.ROI_VMA_Malibu_Nacional__c + c.ROI_VMA_Montilla_Cristal__c 
                              + c.ROI_VMA_Mumm_Champagne__c + c.ROI_VMA_Mumm_Espumante__c 
                              + c.ROI_VMA_Natu_Nobilis__c + c.ROI_VMA_Olmeca__c + c.ROI_VMA_Orloff__c 
                              + c.ROI_VMA_Passport_LBS__c + c.ROI_VMA_Perrier_Jouet_1_5L__c
                              + c.ROI_VMA_Perrier_Jouet__c + c.ROI_VMA_Perrier_Jouet_Belle_Epoque__c
                              + c.ROI_VMA_Perrier_Jouet_Belle_Epq1_5L__c + c.ROI_VMA_Royal_Salute_38YO__c
                              + c.ROI_VMA_Royal_Salute__c + c.ROI_VMA_Sandeman__c + c.ROI_VMA_Teachers__c
                              + c.ROI_VMA_Tezon__c + c.ROI_VMA_Wall_Street__c + c.ROI_VMA_Wyborowa_Exquisite__c;
            
                
        decimal lValor = lMapRateio.get( c.id );
          if ( lValor == null ) lValor = 0;
          c.ROI_Total_do_Rateio__c = lValor;
        
        // Classificação Potencial de Volume
        Parametros_ROI__c lParam = ContratoROI_Aux.getClassPotencial( lVMATotal );
        if ( lParam == null )
        {
            c.ROI_Class_Potencial_Volume__c = '';
            c.ROI_Potencial_Volume_GS__c = 0;
        }
        else
        {
            c.ROI_Class_Potencial_Volume__c = lParam.Classificacao_Potencial__c;
            c.ROI_Potencial_Volume_GS__c = lParam.KPI_GS__c;
        }
        
        // Retorno KPI financeiro 
        lParam = ContratoROI_Aux.getKPIFinanceiro( c.ROI_Perc_ROI_formula__c );
        if ( lParam == null )
            {
            c.Percentual_KPI_financeiro_ROI__c = 0;
            c.ROI_KPI_Financeiro_GS__c = 0;
            c.ROI_KPI_Financeiro_GD__c = 0;
            c.ROI_Perc_ROI_formula_Abs__c = 0;
            }
            else
            {
              c.Retorno_KPI_Financeiro__c = lParam.Classificacao_ROI__c;
              c.ROI_KPI_Financeiro_GS__c = lParam.KPI_GS__c;
              c.ROI_KPI_Financeiro_GD__c = lParam.KPI_GD__c;
              c.ROI_Perc_ROI_formula_Abs__c = c.ROI_Perc_ROI_formula__c ;
            }
    
            // Total de Pontos Visibilidade
            // Rating_segmentation_targert_market__c por Tipo_segmentacao_on_trade__c
            c.ROI_Total_de_Pontos_Visibilidade__c = ContratoROI_Aux.getPontosVisibilidade( c, lAcc.Segmentation_Type_on_trade__c );
                
        // KPI de visibilidade
        // Rating_segmentation_targert_market__c por Tipo_segmentacao_on_trade__c
        lParam = ContratoROI_Aux.getClassifVisibilidade( lAcc.Segmentation_Type_on_trade__c, c.ROI_Total_de_Pontos_Visibilidade__c );
        if ( lParam == null )
            {
              c.KPI_de_visibilidade__c = '';
              c.ROI_KPI_visibilidade_GS__c = 0;
              c.ROI_KPI_visibilidade_GD__c = 0;
            }
            else
            { 
              c.KPI_de_visibilidade__c = lParam.Classificacao_Contrapartida__c;
              c.ROI_KPI_visibilidade_GS__c = lParam.KPI_GS__c;
              c.ROI_KPI_visibilidade_GD__c = lParam.KPI_GD__c;
            }
    
            // Margem CAAP (CAAP %)
            lParam = ContratoROI_Aux.getKPIFinanceiro( c.ROI_CAAP_Net__c );
            if ( lParam == null )
            {
              c.ROI_Margem_CAAP_Texto__c = '';
              c.ROI_Margem_CAAP_GS__c = 0;
              c.Margem_CAAP_GD__c = 0;
            }
            else
            {
              c.ROI_Margem_CAAP_Texto__c = lParam.Classificacao_Margem__c ;
              c.ROI_Margem_CAAP_GS__c = lParam.KPI_GS__c;
              c.Margem_CAAP_GD__c = lParam.KPI_GD__c;
            }
    
            //Mix Produtos
            c.ROI_Mix_Produto__c = ContratoROI_Aux.getMixProdutos( c, lAcc.Revenue_UF__c );
          }
    }
 }
}