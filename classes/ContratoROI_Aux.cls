/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que auxiliar a trigger de contrato de ROI
* NAME: ContratoROI_Aux.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 18/07/2012
*
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/

public with sharing class ContratoROI_Aux {
  
  private static final String VISIBILIDADE_PROD = 'Visibilidade do produto';
  private static final String TAILOR_MADE = 'Tailor Made';
  private static final String UNIFORME = 'Uniforme';
  private static final String MATERIAL = 'Material';
  private static final String VENDA_GARRAFA = 'Venda de Garrafa';
  private static final String INCENTIVO_BRIGADA = 'Incentivo da Brigada';
  private static final String COMUNICACAO = 'Comunicação';
  private static final String FESTAS_EVENTOS = 'Festas Eventos';
  private static final String CARDAPIO = 'Cardápio';
  private static final String MIXOLOGISTAS = 'Consultoria de Mixologistas';
  private static final String PROJ_ESPECIAIS = 'Projetos Especiais';
  private static final String ATIVACAO = 'Ativação';
  
  private static List< Parametros_ROI__c > fParams;
  private static Map< String, String > fConvProdName = new Map< String, String >();
  private static Map< String, Informacoes_de_Custo_do_Produto__c > fMapInfos = new Map< String, Informacoes_de_Custo_do_Produto__c >();
  
  private static Id fRecPotVolume;
  private static Id fRecRoiMargem;
  private static Id fRecContraClas;
  private static Id fRecContraPont;
  
  static
  {
    // Tipos de Registro de Parâmetros do ROI            
    fRecPotVolume = RecordTypeForTest.getRecType( 'Parametros_ROI__c', 'Pontencial_de_Volume_Litros' );
    fRecRoiMargem = RecordTypeForTest.getRecType( 'Parametros_ROI__c', 'Classificacao_ROI_e_Margem' );
    fRecContraClas = RecordTypeForTest.getRecType( 'Parametros_ROI__c', 'Contrapartida_Visibilidade_Classificacao' );
    fRecContraPont = RecordTypeForTest.getRecType( 'Parametros_ROI__c', 'Contrapartida_Visibilidade_Pontuacao' );
    
    Set< Id > setRecTypePar = new Set< Id >();
    setRecTypePar.add( fRecContraClas );
    setRecTypePar.add( fRecContraPont );
    setRecTypePar.add( fRecRoiMargem );
    setRecTypePar.add( fRecPotVolume );
    setRecTypePar.add( RecordTypeForTest.getRecType('Parametros_ROI__c', 'Padrao'));
    
    Id idRecTupeCP = RecordTypeForTest.getRecType( 'Informacoes_de_Custo_do_Produto__c' , 'Informacoes_de_Custo_do_Produto' );
    
    // Parâmetros do ROI
    fParams = [ SELECT Classificacao_Potencial__c, Litros_DE__c, Litros_ATE__c,
                KPI_GS__c, RecordTypeId, Perc_Classificacao_DE__c, Perc_Classificacao_ATE__c,
                Classificacao_ROI__c, KPI_GD__c, Contrapartida_de_Visibilidade__c, 
                Pontuacao_DE__c, Pontuacao_ATE__c, Classificacao_Contrapartida__c, 
                Classificacao_Margem__c, Tipo_Negocio__c, Pontuacao__c                
                FROM Parametros_ROI__c WHERE RecordTypeId =: setRecTypePar ];
    
    // Tabela De/Para para recuperar as informações do produto
    fConvProdName.put( 'Absolut_100__c', 'Absolut 100' );
    fConvProdName.put( 'Absolut_Elyx__c', 'Absolut Elyx' );
    fConvProdName.put( 'Absolut_Flavors__c', 'Absolut Flavors' );
    fConvProdName.put( 'Absolut_Vodka__c', 'Absolut Vodka' );
    fConvProdName.put( 'Ballantine_s_12Y__c', 'Ballantines 12Y' );
    fConvProdName.put( 'Ballantine_s_17Y__c', 'Ballantines 17Y' );
    fConvProdName.put( 'Ballantine_s_21Y__c', 'Ballantines 21Y' );
    fConvProdName.put( 'Ballantine_s_30Y__c', 'Ballantines 30Y' );
    fConvProdName.put( 'Ballantine_s_Finest__c', 'Ballantines Finest' );
    fConvProdName.put( 'Cachaca_Janeiro__c', 'Cachaca Janeiro' );
    fConvProdName.put( 'Cachaca_Sao_Francisco__c', 'Cachaca Sao Francisco' );
    fConvProdName.put( 'Chivas_Regal_12_Years__c', 'Chivas Regal 12Y' );
    fConvProdName.put( 'Chivas_Regal_18_Years__c', 'Chivas Regal 18Y' );
    fConvProdName.put( 'Chivas_Regal_25_Years__c', 'Chivas Regal 25Y' );
    fConvProdName.put( 'Domecq_Tradicional__c', 'Domecq Tradicional' );
    fConvProdName.put( 'Havana_Club_3_Anos__c', 'Havana Club 3Y' );
    fConvProdName.put( 'Havana_Club_7_anos__c', 'Havana Club 7Y' );
    fConvProdName.put( 'Havana_Club_Anejo_Reserva__c', 'Havana Club Anejo Reserva' );
    fConvProdName.put( 'Jameson_Standard__c', 'Jameson Standard' );
    fConvProdName.put( 'Jim_Beam_Black__c', 'Jim Beam Black' );
    fConvProdName.put( 'Jim_Beam_White__c', 'Jim Beam White' );
    fConvProdName.put( 'Kahlua__c', 'Kahlua' );
    fConvProdName.put( 'Malibu_Nacional__c', 'Malibu Nacional' );
    fConvProdName.put( 'Montilla_Cristal__c', 'Montilla Cristal' );
    fConvProdName.put( 'Mumm_Champagne__c', 'Mumm Champagne' );
    fConvProdName.put( 'Mumm_Espumante__c', 'Mumm Espumante' );
    fConvProdName.put( 'Natu_Nobilis__c', 'Natu Nobilis' );
    fConvProdName.put( 'Olmeca__c', 'Olmeca' );
    fConvProdName.put( 'Orloff__c', 'Orloff' );
    fConvProdName.put( 'Passport_LBS__c', 'Passport LBS' );
    fConvProdName.put( 'Perrier_Jouet__c', 'Perrier Jouet' );
    fConvProdName.put( 'Perrier_Jouet_1_5L__c', 'Perrier Jouet 1.5L' );
    fConvProdName.put( 'Perrier_Jouet_Belle_Epoque__c', 'Perrier Jouet Belle Epoque' );
    fConvProdName.put( 'Perrier_Jouet_Belle_Epq1_5L__c', 'Perrier Jouet Belle Epoque 1.5L' );
    fConvProdName.put( 'Royal_Salute__c', 'Royal Salute' );
    fConvProdName.put( 'Royal_Salute_38YO__c', 'Royal Salute 38Y' );
    fConvProdName.put( 'Sandeman__c', 'Sandeman' );
    fConvProdName.put( 'Teachers__c', 'Teachers' );
    fConvProdName.put( 'Tezon__c', 'Tezon' );
    fConvProdName.put( 'Wall_Street__c', 'Wall Street' );
    fConvProdName.put( 'Wyborowa_Exquisite__c', 'Wyborowa Exquisite' );
      
      
      List< Informacoes_de_Custo_do_Produto__c > lInfos = [SELECT Scheduler_C__r.Tx_Conversao__c, 
                                                            Scheduler_C__r.Scheduler_C__c, Net_Sales_Case__c,
                                                            Scheduler_C__r.SKU_de_referencia__c, 
                                                            UF__c, CM_Case__c, Scheduler_C__r.Indice_litros__c, 
                                                            Scheduler_C__R.Pontuacao_mix__c,
                                                            Scheduler_C__r.Descricao_SchedulerC__c 
                                                            FROM Informacoes_de_Custo_do_Produto__c 
                                                            WHERE RecordTypeId =: idRecTupeCP];
                 
      for ( Informacoes_de_Custo_do_Produto__c i : lInfos )
      {
        fMapInfos.put( i.Scheduler_C__r.Descricao_SchedulerC__c + '|' + i.UF__c, i );
      }
      
      system.debug('fMapInfos: ' + fMapInfos.size());
                                         
  }
  
  public static Parametros_ROI__c getClassPotencial( decimal aVMA )
  {
    for ( Parametros_ROI__c p : fParams )
    {
      if ( p.RecordTypeId == fRecPotVolume && aVMA >= p.Litros_DE__c && aVMA <= p.Litros_ATE__c )
        return p;
    }
    return null;
  }
  
  public static Parametros_ROI__c getKPIFinanceiro( decimal aPerc )
  {
    for ( Parametros_ROI__c p : fParams )
    {
      if ( p.RecordTypeId == fRecRoiMargem && aPerc >= p.Perc_Classificacao_DE__c && aPerc <= p.Perc_Classificacao_ATE__c )
        return p;
    }
    return null;
  }
  
  private static decimal getContrapartidaPontuacao( String aSegmentacao, String aContrapartida )
  {
    for ( Parametros_ROI__c p : fParams )
    {
      if ( p.RecordTypeId == fRecContraPont && p.Contrapartida_de_Visibilidade__c == aContrapartida 
      && p.Tipo_Negocio__c == aSegmentacao )
        return p.Pontuacao__c;
    }
    return 0;
  }
  
  public static decimal getPontosVisibilidade( LAT_Contract__c c, String aSegmentacao )
  {
    decimal lTotal = 0;
    if ( c.Visibilidade_do_produto__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, VISIBILIDADE_PROD );
    if ( c.Tailor_made__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, TAILOR_MADE );
    if ( c.Uniforme__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, UNIFORME );
    if ( c.Material__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, MATERIAL );
    if ( c.Venda_de_Garrafa__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, VENDA_GARRAFA );
    if ( c.Incentivo_da_Brigada__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, INCENTIVO_BRIGADA );
    if ( c.Comunicacao__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, COMUNICACAO );
    if ( c.Festas_Eventos__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, FESTAS_EVENTOS );
    if ( c.Cardapio__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, CARDAPIO );
    if ( c.Consultoria_de_Mixologistas__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, MIXOLOGISTAS );
    if ( c.Projetos_especiais__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, PROJ_ESPECIAIS );
    if ( c.Ativacao__c == 'Sim' ) lTotal += getContrapartidaPontuacao( aSegmentacao, ATIVACAO );
    return lTotal;
  }
  
  public static Parametros_ROI__c getClassifVisibilidade( String aSegmentacao, decimal aPontos )
  {
    for ( Parametros_ROI__c p : fParams )
    {
      if ( p.RecordTypeId == fRecContraClas && p.Tipo_Negocio__c == aSegmentacao
      && aPontos >= p.Pontuacao_DE__c && aPontos <= p.Pontuacao_ATE__c )
        return p;
    }
    return null;
  }
  
    private static String getScheduleC( String aFieldName )
    {
      String lFldName = aFieldName.replace( 'ROI_', '' );
      integer idx = lFldName.indexOf( '_' );
      return fConvProdName.get( lFldName.substring( idx + 1 ) );
    }
    
    public static decimal getNetSales( decimal aPeriodo, String aFieldName, String aUF ) {
        
        String lSchdC = getScheduleC(aFieldName);
        if ( lSchdC == null ) return 0;
        Informacoes_de_Custo_do_Produto__c lInfo = fMapInfos.get( lSchdC + '|' + aUF );
        if ( lInfo == null ) return 0;
    
        Decimal netSalesCase = lInfo.Net_Sales_Case__c != null ? lInfo.Net_Sales_Case__c : 0;        
        Decimal txConversao = lInfo.Scheduler_C__R.Tx_Conversao__c != null ? lInfo.Scheduler_C__R.Tx_Conversao__c : 0;
    
        return aPeriodo * netSalesCase * txConversao;
    
    }
    
    public static decimal getGMDC( decimal aPeriodo, String aFieldName, String aUF ) {
            
        String lSchdC = getScheduleC( aFieldName );
      
        if ( lSchdC == null ) return 0;  
                         
        Informacoes_de_Custo_do_Produto__c lInfo = fMapInfos.get( lSchdC + '|' + aUF );                          
      
        if ( lInfo == null || aPeriodo == null ) return 0;
        
        Decimal CM_Case = lInfo.CM_Case__c != null ? lInfo.CM_Case__c : 0;
        Decimal Tx_Conversao = lInfo.Scheduler_C__R.Tx_Conversao__c != null ? lInfo.Scheduler_C__R.Tx_Conversao__c : 0;
            
        return aPeriodo * CM_Case * Tx_Conversao;
    
    }
    
    public static Informacoes_de_Custo_do_Produto__c getICP (String aFieldName, String aUF) {
    
        String lSchdC = getScheduleC( aFieldName );
        if ( lSchdC == null ) return null;
        
        String key = lSchdC + '|' + aUF;
        
        if (fMapInfos.containsKey(key)) {
            Informacoes_de_Custo_do_Produto__c lInfo = fMapInfos.get( lSchdC + '|' + aUF );
            return lInfo;
        }
        
        return null;                         
        
    }     
  
    public static decimal getVMA( decimal aPeriodo, String aFieldName, String aUF ) {
    
        String lSchdC = getScheduleC( aFieldName );
        if ( lSchdC == null ) return 0;
        Informacoes_de_Custo_do_Produto__c lInfo = fMapInfos.get( lSchdC + '|' + aUF );
        if ( lInfo == null ) return 0;
        
        Decimal indiceLitros = lInfo.Scheduler_C__R.Indice_litros__c != null ? lInfo.Scheduler_C__R.Indice_litros__c : 0;
        
        return aPeriodo * indiceLitros * 12;
        //return aPeriodo * lInfo.Scheduler_C__R.Indice_litros__c * lInfo.Scheduler_C__R.Tx_Conversao__c;
    
    }
  
    private static decimal getMix( String aFieldName, String aUF ) {
        
        String lSchdC = getScheduleC( aFieldName );
        if ( lSchdC == null ) return 0;
        
        Informacoes_de_Custo_do_Produto__c lInfo = fMapInfos.get( lSchdC + '|' + aUF );
        
        if ( lInfo == null ) return 0;
    
        Decimal pontuacaoMix = lInfo.Scheduler_C__R.Pontuacao_mix__c != null ? lInfo.Scheduler_C__R.Pontuacao_mix__c : 0;            
    
        return pontuacaoMix;
    
    }
  
    public static integer getMixProdutos( LAT_Contract__c c,  String aUF ) {
    
        decimal lTotal = 0;
        integer lCount = 0;
    
        if ( c.Volume_absolut_100__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_absolut_100__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Absolut_Elyx__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Absolut_Elyx__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Absolut_Flavors__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Absolut_Flavors__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Absolut_Vodka__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Absolut_Vodka__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Ballantine_s_12Y__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Ballantine_s_12Y__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Ballantine_s_17Y__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Ballantine_s_17Y__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Ballantine_s_21Y__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Ballantine_s_21Y__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Ballantine_s_30Y__c > 0 ) { lCount++; lTotal += getMix( LAT_Contract__c.Volume_Ballantine_s_30Y__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Ballantine_s_Finest__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Ballantine_s_Finest__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Cachaca_Janeiro__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Cachaca_Janeiro__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Cachaca_Sao_Francisco__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Cachaca_Sao_Francisco__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Chivas_Regal_12_Years__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Chivas_Regal_12_Years__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Chivas_Regal_18_Years__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Chivas_Regal_18_Years__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Chivas_Regal_25_Years__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Chivas_Regal_25_Years__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Domecq_Tradicional__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Domecq_Tradicional__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Havana_Club_3_Anos__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Havana_Club_3_Anos__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Havana_Club_7_anos__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Havana_Club_7_anos__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Havana_Club_Anejo_Reserva__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Havana_Club_Anejo_Reserva__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Jameson_Standard__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Jameson_Standard__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Jim_Beam_Black__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Jim_Beam_Black__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Jim_Beam_White__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Jim_Beam_White__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Kahlua__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Kahlua__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Malibu_Nacional__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Malibu_Nacional__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Montilla_Cristal__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Montilla_Cristal__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Mumm_Champagne__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Mumm_Champagne__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Mumm_Espumante__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Mumm_Espumante__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Natu_Nobilis__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Natu_Nobilis__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Olmeca__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Olmeca__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Orloff__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Orloff__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Passport_LBS__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Passport_LBS__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Perrier_Jouet__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Perrier_Jouet__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Perrier_Jouet_1_5L__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Perrier_Jouet_1_5L__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Perrier_Jouet_Belle_Epoque__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Perrier_Jouet_Belle_Epoque__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Perrier_Jouet_Belle_Epq1_5L__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Perrier_Jouet_Belle_Epq1_5L__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Royal_Salute__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Royal_Salute__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Royal_Salute_38YO__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Royal_Salute_38YO__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Sandeman__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Sandeman__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Teachers__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Teachers__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Tezon__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Tezon__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Wall_Street__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Wall_Street__c.getDescribe().Name , aUF ); }
        if ( c.Volume_Wyborowa_Exquisite__c > 0 ){ lCount++; lTotal += getMix( LAT_Contract__c.Volume_Wyborowa_Exquisite__c.getDescribe().Name , aUF ); }
    
        if ( lCount == 0 ) return 0;
    
        else return Math.round( lTotal / lCount );
    
    }
  
}