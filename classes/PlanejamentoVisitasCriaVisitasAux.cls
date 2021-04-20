public with sharing class PlanejamentoVisitasCriaVisitasAux {
  
  private static Map< String, Integer > monthOfYear = new Map< String, Integer >();
  private static BusinessHours stdBusinessHours;
 
  static {
    stdBusinessHours = [select id from Businesshours where isDefault = true];
    
    monthOfYear.put( 'Janeiro', 1 );
    monthOfYear.put( 'Fevereiro', 2 );
    monthOfYear.put( 'Março', 3 );
    monthOfYear.put( 'Abril', 4 );
    monthOfYear.put( 'Maio', 5 );
    monthOfYear.put( 'Junho', 6 );
    monthOfYear.put( 'Julho', 7 );
    monthOfYear.put( 'Agosto', 8 );
    monthOfYear.put( 'Setembro', 9 );
    monthOfYear.put( 'Outubro', 10 );
    monthOfYear.put( 'Novembro', 11 );
    monthOfYear.put( 'Dezembro', 12 );
  }
  
  public static Integer getMonth( String aMonth )
  {
        return monthOfYear.get( aMonth );
  }
  
  private static Integer getBusinessDay( Integer aYear, Integer aMonth )
  {
    Integer lQtt = Date.daysInMonth( aYear, aMonth );
    Integer lCount = 0;
    for ( Integer i=1; i<=lQtt; i++ )
    {
      Date lCheckDate = date.newInstance( aYear, aMonth, i );
      DateTime lDate = BusinessHours.add( stdBusinessHours.Id, lCheckDate, 1 ).date();
      if ( lDate.isSameDay( lCheckDate ) ) lCount++;
    }
    if ( lCount == 0 )
    {
      for ( Integer i=1; i<=lQtt; i++ )
      {
        DateTime lCheckDate = Datetime.newInstance( aYear, aMonth, i );
        String lDayOfWeek = lCheckDate.format( 'EEE' );
        if ( !lDayOfWeek.equalsIgnoreCase( 'SAT' ) && !lDayOfWeek.equalsIgnoreCase( 'SUN' ) )
          lCount++;
      }
    }
    return lCount;
  }
  
  public static Integer getPeriodicity( String aPeriodicity, Integer aYear, Integer aMonth )
  {
    if ( aPeriodicity == 'Diária' ) return getBusinessDay( aYear, aMonth );
    else if ( aPeriodicity == '2 x Semana' ) return 8;
    else if ( aPeriodicity == 'Semanal' ) return 4;
    else if ( aPeriodicity == 'Quinzenal' ) return 2;
    else if ( aPeriodicity == 'Mensal') return 1;
    else return 0;
  }
  
  public static Map< String, List< Par_metro_Produto_Concorr_ncia__c > > getParamProdConcorrencia()
  {
    List< Par_metro_Produto_Concorr_ncia__c > lListParam = ParametroProdutoConcorrenciaDAO.getInstance().getListParametros();
    
    //Inicializa o map.
    Map< String, List< Par_metro_Produto_Concorr_ncia__c > > lMapParam = new Map< String, List< Par_metro_Produto_Concorr_ncia__c > >();
    
    
    /* Para cada iteração na lista listParametros se a CHAVE atual NÃO existir é montado um map de listas, a lista é inicializada e inserido o valor,
     * se existir é atribuído a lista um novo valor.
     */
     
    for ( Par_metro_Produto_Concorr_ncia__c p : lListParam )
    {
      String key = p.RecordTypeId + '|' + p.Canal__c + '|' + p.Regional__c ;
      if ( p.RecordTypeId == ChecklistVisitaCria.REC_TYPE_PARAM_PROD_CONCORRENCIA ) key += '|' + p.Sub__c;
      List< Par_metro_Produto_Concorr_ncia__c > lParams = lMapParam.get( key );
      if ( lParams == null )
      {
        lParams = new List< Par_metro_Produto_Concorr_ncia__c >();
        lMapParam.put( key, lParams );
      }
      lParams.add( p );
    }
    return lMapParam;
  }
  
  public static Map< String, List< List< String > > > getParamProdContrato( List< String > aAccounts,
                       Map< String, List< String > > aAccountContracts )
  {
    Map< String, List< List< String > > > lMapParam = new Map< String, List< List< String > > >();
    
    List< LAT_Contract__c > lListContrato = ContractDAO.getInstance().getListContractByAccount( aAccounts );
    System.debug('%%%%%%%%%%%%% en getParamProdContrato lListContrato : '+ lListContrato);
    Schema.DescribeSObjectResult lSOT = Schema.SObjectType.LAT_Contract__c.SObjectType.getDescribe();
    for ( LAT_Contract__c p : lListContrato )
    {
      List< List< String > > lParams = new List< List< String > >();
      
      List< String > lVolume = new List< String >();
      List< String > lContrapartida = new List< String >();
      List< String > lPortifPernod = new List< String >();
      List< String > lVisibilidade = new List< String >();
      List< String > lAcordo = new List< String >();
      List< String > lDetalhamento = new List< String >();
      
      lParams.add( lVolume );
      lParams.add( lContrapartida );
      lParams.add( lPortifPernod );
      lParams.add( lVisibilidade );
      lParams.add( lAcordo );
      lParams.add( lDetalhamento );
      
      List< String > l = aAccountContracts.get( p.Account__c );
      if ( l == null )
      {
        l = new List< String >();
        aAccountContracts.put( p.Account__c, l );
      }
      l.add( p.id );
      
      lMapParam.put( p.Id, lParams );
      
      // Volume Mínimo em Caixas Físicas
      if ( p.Volume_absolut_100__c > 0 ) lVolume.add( LAT_Contract__c.Volume_absolut_100__c.getDescribe().getLabel() );
      if ( p.Volume_Absolut_Elyx__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Absolut_Elyx__c.getDescribe().getLabel() );
      if ( p.Volume_Absolut_Flavors__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Absolut_Flavors__c.getDescribe().getLabel() );
      if ( p.Volume_Absolut_Vodka__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Absolut_Vodka__c.getDescribe().getLabel() );
      if ( p.Volume_Ballantine_s_12Y__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Ballantine_s_12Y__c.getDescribe().getLabel() );
      if ( p.Volume_Ballantine_s_17Y__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Ballantine_s_17Y__c.getDescribe().getLabel() );
      if ( p.Volume_Ballantine_s_21Y__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Ballantine_s_21Y__c.getDescribe().getLabel() );
      if ( p.Volume_Ballantine_s_30Y__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Ballantine_s_30Y__c.getDescribe().getLabel() );
      if ( p.Volume_Ballantine_s_Finest__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Ballantine_s_Finest__c.getDescribe().getLabel() );
      if ( p.Volume_Cachaca_Janeiro__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Cachaca_Janeiro__c.getDescribe().getLabel() );
      if ( p.Volume_Cachaca_Sao_Francisco__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Cachaca_Sao_Francisco__c.getDescribe().getLabel() );
      if ( p.Volume_Chivas_Regal_12_Years__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Chivas_Regal_12_Years__c.getDescribe().getLabel() );
      if ( p.Volume_Chivas_Regal_18_Years__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Chivas_Regal_18_Years__c.getDescribe().getLabel() );
      if ( p.Volume_Chivas_Regal_25_Years__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Chivas_Regal_25_Years__c.getDescribe().getLabel() );
      if ( p.Volume_Domecq_Tradicional__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Domecq_Tradicional__c.getDescribe().getLabel() );
      if ( p.Volume_Havana_Club_3_Anos__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Havana_Club_3_Anos__c.getDescribe().getLabel() );
      if ( p.Volume_Havana_Club_7_anos__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Havana_Club_7_anos__c.getDescribe().getLabel() );
      if ( p.Volume_Havana_Club_Anejo_Reserva__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Havana_Club_Anejo_Reserva__c.getDescribe().getLabel() );
      if ( p.Volume_Jameson_Standard__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Jameson_Standard__c.getDescribe().getLabel() );
      if ( p.Volume_Jim_Beam_Black__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Jim_Beam_Black__c.getDescribe().getLabel() );
      if ( p.Volume_Jim_Beam_White__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Jim_Beam_White__c.getDescribe().getLabel() );
      if ( p.Volume_Kahlua__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Kahlua__c.getDescribe().getLabel() );
      if ( p.Volume_Malibu_Nacional__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Malibu_Nacional__c.getDescribe().getLabel() );
      if ( p.Volume_Montilla_Cristal__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Montilla_Cristal__c.getDescribe().getLabel() );
      if ( p.Volume_Mumm_Champagne__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Mumm_Champagne__c.getDescribe().getLabel() );
      if ( p.Volume_Mumm_Espumante__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Mumm_Espumante__c.getDescribe().getLabel() );
      if ( p.Volume_Natu_Nobilis__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Natu_Nobilis__c.getDescribe().getLabel() );
      if ( p.Volume_Olmeca__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Olmeca__c.getDescribe().getLabel() );
      if ( p.Volume_Orloff__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Orloff__c.getDescribe().getLabel() );
      if ( p.Volume_Passport_LBS__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Passport_LBS__c.getDescribe().getLabel() );
      if ( p.Volume_Perrier_Jouet__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Perrier_Jouet__c.getDescribe().getLabel() );
      if ( p.Volume_Perrier_Jouet_1_5L__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Perrier_Jouet_1_5L__c.getDescribe().getLabel() );
      if ( p.Volume_Perrier_Jouet_Belle_Epoque__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Perrier_Jouet_Belle_Epoque__c.getDescribe().getLabel() );
      if ( p.Volume_Perrier_Jouet_Belle_Epq1_5L__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Perrier_Jouet_Belle_Epq1_5L__c.getDescribe().getLabel() );
      if ( p.Volume_Royal_Salute__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Royal_Salute__c.getDescribe().getLabel() );
      if ( p.Volume_Royal_Salute_38YO__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Royal_Salute_38YO__c.getDescribe().getLabel() );
      if ( p.Volume_Sandeman__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Sandeman__c.getDescribe().getLabel() );
      if ( p.Volume_Teachers__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Teachers__c.getDescribe().getLabel() );
      if ( p.Volume_Tezon__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Tezon__c.getDescribe().getLabel() );
      if ( p.Volume_Wall_Street__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Wall_Street__c.getDescribe().getLabel() );
      if ( p.Volume_Wyborowa_Exquisite__c > 0 ) lVolume.add( LAT_Contract__c.Volume_Wyborowa_Exquisite__c.getDescribe().getLabel() );

      // Contrapartida
      if ( valorSim( p.Visibilidade_do_produto__c ) ) lContrapartida.add( LAT_Contract__c.Visibilidade_do_produto__c.getDescribe().getLabel() );
      if ( valorSim( p.Tailor_made__c ) ) lContrapartida.add( LAT_Contract__c.Tailor_made__c.getDescribe().getLabel() );
      if ( valorSim( p.Uniforme__c ) ) lContrapartida.add( LAT_Contract__c.Uniforme__c.getDescribe().getLabel() );
      if ( valorSim( p.Material__c ) ) lContrapartida.add( LAT_Contract__c.Material__c.getDescribe().getLabel() );
      if ( valorSim( p.Venda_de_Garrafa__c ) ) lContrapartida.add( LAT_Contract__c.Venda_de_Garrafa__c.getDescribe().getLabel() );
      if ( valorSim( p.Incentivo_da_Brigada__c ) ) lContrapartida.add( LAT_Contract__c.Incentivo_da_Brigada__c.getDescribe().getLabel() );
      if ( valorSim( p.Comunicacao__c ) ) lContrapartida.add( LAT_Contract__c.Comunicacao__c.getDescribe().getLabel() );
      if ( valorSim( p.Festas_Eventos__c ) ) lContrapartida.add( LAT_Contract__c.Festas_Eventos__c.getDescribe().getLabel() );
      if ( valorSim( p.Cardapio__c ) ) lContrapartida.add( LAT_Contract__c.Cardapio__c.getDescribe().getLabel() );
      if ( valorSim( p.Consultoria_de_Mixologistas__c ) ) lContrapartida.add( LAT_Contract__c.Consultoria_de_Mixologistas__c.getDescribe().getLabel() );
      if ( valorSim( p.Projetos_Especiais__c ) ) lContrapartida.add( LAT_Contract__c.Projetos_Especiais__c.getDescribe().getLabel() );
      if ( valorSim( p.Ativacao__c ) ) lContrapartida.add( LAT_Contract__c.Ativacao__c.getDescribe().getLabel() );
      
      // Portifólio Pernod Ricard
      if ( valorSim( p.Vodkas_importadas_Absolut__c ) ) lPortifPernod.add( LAT_Contract__c.Vodkas_importadas_Absolut__c.getDescribe().getLabel() );
      if ( valorSim( p.Vodkas_importadas_Absolut_Flavours__c ) ) lPortifPernod.add( LAT_Contract__c.Vodkas_importadas_Absolut_Flavours__c.getDescribe().getLabel() );
      if ( valorSim( p.Vodkas_importadas_Wyborowa_Exquisite__c ) ) lPortifPernod.add( LAT_Contract__c.Vodkas_importadas_Wyborowa_Exquisite__c.getDescribe().getLabel() );
      if ( valorSim( p.Vodkas_importadas_Wyborowa__c ) ) lPortifPernod.add( LAT_Contract__c.Vodkas_importadas_Wyborowa__c.getDescribe().getLabel() );
      if ( valorSim( p.Vodkas_importadas_Absolut_Elyx__c ) ) lPortifPernod.add( LAT_Contract__c.Vodkas_importadas_Absolut_Elyx__c.getDescribe().getLabel() );
      if ( valorSim( p.Vodkas_nacionais_Orloff__c ) ) lPortifPernod.add( LAT_Contract__c.Vodkas_nacionais_Orloff__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Std_Ballantines_Finest__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Std_Ballantines_Finest__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Premium_12_anos_Chivas_12__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Premium_12_anos_Chivas_12__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Premium_12_anos_Ballantines_12__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Premium_12_anos_Ballantines_12__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Super_Premium_Chivas_18__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Super_Premium_Chivas_18__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Super_Premium_Chivas_25__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Super_Premium_Chivas_25__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Super_Premium_Royal_Salute__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Super_Premium_Royal_Salute__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Super_Premium_Ballantines_17__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Super_Premium_Ballantines_17__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Super_Premium_Ballantines_21__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Super_Premium_Ballantines_21__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Super_Premium_Ballantines_30__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Super_Premium_Ballantines_30__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Irlandes_Jameson__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Irlandes_Jameson__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Engarrafado_Passport__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Engarrafado_Passport__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Engarrafado_Teachers__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Engarrafado_Teachers__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Nacional_Natu_Nobilis__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Nacional_Natu_Nobilis__c.getDescribe().getLabel() );
      if ( valorSim( p.Whisky_Bourbon_Jim_Bean__c ) ) lPortifPernod.add( LAT_Contract__c.Whisky_Bourbon_Jim_Bean__c.getDescribe().getLabel() );
      if ( valorSim( p.Champagne_Perrier_Jouet_Belle_Epoque__c ) ) lPortifPernod.add( LAT_Contract__c.Champagne_Perrier_Jouet_Belle_Epoque__c.getDescribe().getLabel() );
      if ( valorSim( p.Champagne_Perrier_Jouet_Grand_Brut__c ) ) lPortifPernod.add( LAT_Contract__c.Champagne_Perrier_Jouet_Grand_Brut__c.getDescribe().getLabel() );
      if ( valorSim( p.Champagne_Mumm_Cordon_Rouge__c ) ) lPortifPernod.add( LAT_Contract__c.Champagne_Mumm_Cordon_Rouge__c.getDescribe().getLabel() );
      if ( valorSim( p.Espumante_Mumm_Cuvee__c ) ) lPortifPernod.add( LAT_Contract__c.Espumante_Mumm_Cuvee__c.getDescribe().getLabel() );
      if ( valorSim( p.Espumante_Mumm_Petit__c ) ) lPortifPernod.add( LAT_Contract__c.Espumante_Mumm_Petit__c.getDescribe().getLabel() );
      if ( valorSim( p.Rum_Importado_Havana_Club__c ) ) lPortifPernod.add( LAT_Contract__c.Rum_Importado_Havana_Club__c.getDescribe().getLabel() );
      if ( valorSim( p.Rum_Nacional_Malibu__c ) ) lPortifPernod.add( LAT_Contract__c.Rum_Nacional_Malibu__c.getDescribe().getLabel() );
      if ( valorSim( p.Rum_Nacional_Montila__c ) ) lPortifPernod.add( LAT_Contract__c.Rum_Nacional_Montila__c.getDescribe().getLabel() );
      if ( valorSim( p.Gin_Beefeater__c ) ) lPortifPernod.add( LAT_Contract__c.Gin_Beefeater__c.getDescribe().getLabel() );
      if ( valorSim( p.Cachaca_Janeiro__c ) ) lPortifPernod.add( LAT_Contract__c.Cachaca_Janeiro__c.getDescribe().getLabel() );
      if ( valorSim( p.Licor_Kahlua__c ) ) lPortifPernod.add( LAT_Contract__c.Licor_Kahlua__c.getDescribe().getLabel() );
      if ( valorSim( p.Licor_Ricard__c ) ) lPortifPernod.add( LAT_Contract__c.Licor_Ricard__c.getDescribe().getLabel() );
      if ( valorSim( p.Vinhos_Jacobs_Creek__c ) ) lPortifPernod.add( LAT_Contract__c.Vinhos_Jacobs_Creek__c.getDescribe().getLabel() );
      if ( valorSim( p.Vinhos_Marques_de_Arienzo__c ) ) lPortifPernod.add( LAT_Contract__c.Vinhos_Marques_de_Arienzo__c.getDescribe().getLabel() );
      if ( valorSim( p.Vinhos_Graffigna__c ) ) lPortifPernod.add( LAT_Contract__c.Vinhos_Graffigna__c.getDescribe().getLabel() );
      if ( valorSim( p.Cognac_Martell__c ) ) lPortifPernod.add( LAT_Contract__c.Cognac_Martell__c.getDescribe().getLabel() );
      
      // Visibilidade
      if ( p.Armarios_de_Clube_da_Vodka__c > 0 ) lVisibilidade.add( LAT_Contract__c.Armarios_de_Clube_da_Vodka__c.getDescribe().getLabel() );
      if ( p.Armarios_de_Clube_de_Whisky__c > 0 ) lVisibilidade.add( LAT_Contract__c.Armarios_de_Clube_de_Whisky__c.getDescribe().getLabel() );
      if ( p.Prateleiras_dos_Bares__c > 0 ) lVisibilidade.add( LAT_Contract__c.Prateleiras_dos_Bares__c.getDescribe().getLabel() );
      if ( p.Cabine_de_DJ__c > 0 ) lVisibilidade.add( LAT_Contract__c.Cabine_de_DJ__c.getDescribe().getLabel() );

      // Acordo
      if ( valorSim( p.Prioridade_venda_Vodkas_Nacionais__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Vodkas_Nacionais__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Vodka_Super_Premium__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Vodka_Super_Premium__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Whisky_Nacional__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Whisky_Nacional__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Whiskie_Americano__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Whiskie_Americano__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Whiskie_Irlandes__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Whiskie_Irlandes__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Whisky_12_anos__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Whisky_12_anos__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Rum_Nacional__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Rum_Nacional__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Rum_Nacional__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Rum_Nacional__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Champagne__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Champagne__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Vinhos__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Vinhos__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Vodkas_Nacionais__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Vodkas_Nacionais__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Vodka_Super_Premium__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Vodka_Super_Premium__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Whisky_Nacional__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Whisky_Nacional__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Whiskie_Bourbon__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Whiskie_Bourbon__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Whiskie_Irlandes__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Whiskie_Irlandes__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Whisky_12_anos__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Whisky_12_anos__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Rum_Nacional__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Rum_Nacional__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Champagne__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Champagne__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Vinhos__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Vinhos__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Vodkas_Nacionais__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Vodkas_Nacionais__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Vodka_Super_Premium__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Vodka_Super_Premium__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Whisky_Nacional__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Whisky_Nacional__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Whiskie_Bourbon__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Whiskie_Bourbon__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Whiskie_Irlandes__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Whiskie_Irlandes__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Whisky_12_anos__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Whisky_12_anos__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Rum_Nacional__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Rum_Nacional__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Champagne__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Champagne__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Vinhos__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Vinhos__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Vodkas_Importadas__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Vodkas_Importadas__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Tequila_Std__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Tequila_Std__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Whisky_Engarrafado__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Whisky_Engarrafado__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Tequila_S_Premium__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Tequila_S_Premium__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Whisky_Std__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Whisky_Std__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Whisky_Super_Premium__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Whisky_Super_Premium__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Rum_Importado__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Rum_Importado__c.getDescribe().getLabel() );
      if ( valorSim( p.Prioridade_venda_Espumantes__c ) ) lAcordo.add( LAT_Contract__c.Prioridade_venda_Espumantes__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Vodkas_Importadas__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Vodkas_Importadas__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Tequila__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Tequila__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Whisky_Engarrafado__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Whisky_Engarrafado__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Tequila_super_premium__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Tequila_super_premium__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Whisky_Std__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Whisky_Std__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Whisky_Super_Premium__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Whisky_Super_Premium__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Rum_Importado__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Rum_Importado__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_promoc_Espumantes__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_promoc_Espumantes__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Vodkas_Importadas__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Vodkas_Importadas__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Tequila__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Tequila__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Whisky_Engarrafado__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Whisky_Engarrafado__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Tequila_super_premium__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Tequila_super_premium__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Whisky_Std__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Whisky_Std__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Whisky_Super_Premium__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Whisky_Super_Premium__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Rum_Importado__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Rum_Importado__c.getDescribe().getLabel() );
      if ( valorSim( p.Exclusiv_visual_Espumantes__c ) ) lAcordo.add( LAT_Contract__c.Exclusiv_visual_Espumantes__c.getDescribe().getLabel() );
      
      // Detalhamento
      if ( p.Pecas_Tailor_Made_Quantidade__c > 0 )
      {
        String lText = LAT_Contract__c.Pecas_Tailor_Made_Quantidade__c.getDescribe().getLabel();
        Integer lPos = lText.indexOf( '-' );
        if ( lPos > 0 ) lText = lText.substring( lPos + 1 ); 
        lDetalhamento.add( lText + ' - ' + p.Pecas_Tailor_Made_Quantidade__c );
      }
      montaDetalhamento( lDetalhamento, p.Pecas_Tailor_Made_Marcas1__c, p.Pecas_Tailor_Made_Ambiente_Local1__c );
      montaDetalhamento( lDetalhamento, p.Pecas_Tailor_Made_Marcas2__c, p.Pecas_Tailor_Made_Ambiente_Local2__c );
      montaDetalhamento( lDetalhamento, p.Pecas_Tailor_Made_Marcas3__c, p.Pecas_Tailor_Made_Ambiente_Local3__c );
    }
    return lMapParam; 
  }
  
  private static boolean valorSim( String aValue )
  {
    return aValue != null && aValue.equalsIgnoreCase( 'Sim' );
  }
  
  private static void montaDetalhamento( List< String > aList, String aText1, String aText2 )
  {
    if ( hasValue( aText1 ) )
    {
      String lResult = aText1;
      if ( hasValue( aText2 ) ) lResult += ' - ' + aText2;
      aList.add( lResult );
    }
  }
  
  private static boolean hasValue( String aValue )
  {
    return aValue != null && aValue.length() > 0;
  }
  
  public static List< Decimal > getRSPProfile( Map< String, CustomerRSPProfiles__c > aAN8, 
           Map< String, CustomerRSPProfiles__c > aOrgBand, Map< String, CustomerRSPProfiles__c > aCanalUFAN8 )
  {
    List< CustomerRSPProfiles__c > lList = CustomerRSPProfileDAO.getInstance().getListCustomerRSPProfiles();
    List< Decimal > lIDList = new List< Decimal >();
    for ( CustomerRSPProfiles__c lProf : lList )
    {
      if ( lProf.AN8__c != null ) aAN8.put( lProf.AN8__c, lProf );
      if ( lProf.codigo_organizacao__c != null && lProf.codigo_bandeira__c != null ) aOrgBand.put( lProf.codigo_organizacao__c + '|' + lProf.codigo_bandeira__c, lProf );
      if ( lProf.canal__c != null && lProf.uf_an8__c != null ) aCanalUFAN8.put( lProf.canal__c + '|' + lProf.uf_an8__c, lProf );
      lIDList.add( lProf.profile_id__c );
    }
    return lIDList;
  }
  
  public static Map< String, CustomerRSPProducts__c > getCustomerRSPProdMap( Decimal aProfIDs )
  {
     Map< String, CustomerRSPProducts__c > lMap = new Map< String, CustomerRSPProducts__c >();
     List< CustomerRSPProducts__c > lList = CustomerRSPProductsDAO.getInstance().getListCustomerRSPProducts( aProfIDs );
     for ( CustomerRSPProducts__c lProd : lList )
     {
       if ( lProd.Profile2_Id__c != null && lProd.sku__c != null )
         lMap.put( String.valueOf( lProd.sku__c ) , lProd );
     }
     return lMap;
  }
  
  public static Map< String, List< String > > getContrapartidaContratoVisita( List< String > aContractList )
  {
    Map< String, List< String > > lMap = new Map< String, List< String > >();
    List< Contrapartida_de_Contrato_visitas__c > lList = [ Select Nome_da_Contrapartida_do_Contrato__c, LAT_Contract__c 
      from Contrapartida_de_Contrato_visitas__c where LAT_Contract__c=: aContractList ];
    for ( Contrapartida_de_Contrato_visitas__c lCCV : lList )
    {
      List< String > lLabels = lMap.get( lCCV.LAT_Contract__c );
      if ( lLabels == null )
      {
        lLabels = new List< String >();
        lMap.put( lCCV.LAT_Contract__c, lLabels );
      }
      lLabels.add( lCCV.Nome_da_Contrapartida_do_Contrato__c );
    }
    return lMap;
  }

  public static Date getStartOfWeek(Date current) {
    Datetime dt = DateTime.newInstance(current, Time.newInstance(0, 0, 0, 0));
    Integer toMonday = (Integer.valueOf(dt.format('u')) - 1) * -1;

    system.debug('---->' + toMonday);

    Date startOfWeek = current;
    startOfWeek = startOfWeek.addDays(toMonday);
    return startOfWeek;
  }
  
}