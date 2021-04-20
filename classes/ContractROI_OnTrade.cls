/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe controladora da página que gera um PDF com o anexo 1.2
* NAME: ContractROI_OnTrade.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 03/09/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR:                                            DATE:
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

public with sharing class ContractROI_OnTrade {
        
  public class BonificacaoProdutos
  {
    public String periodo { get; set; }
    public String mes { get; set; }
    public String anoCalendario { get; set; }
    public String produto { get; set; }
    public decimal volume { get; set; }
  }

  public List< Investimento_Bonificacao_e_Pagamento__c > contratos { get; set; }
  public List< Investimento_Bonificacao_e_Pagamento__c > festas { get; set; }
  public List< Investimento_Bonificacao_e_Pagamento__c > tailorMade { get; set; }
  public List< BonificacaoProdutos > bonificacao { get; set; }
  
  
    private LAT_Contract__c fObj;
  
  public boolean temDetalhamento{ 
    get { return fObj.Pecas_Tailor_Made_Quantidade__c>0 || fObj.Festas_Quantidade__c != null; }
    private set;
  }

  public ContractROI_OnTrade( ApexPages.Standardcontroller aController ){
    fObj = ( LAT_Contract__c )aController.getRecord();
    
    Id lRecCash = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
    
    contratos = getIBP( 'Contrato', lRecCash );
    festas = getIBP( 'Festas/Eventos', lRecCash );
    tailorMade = getIBP( 'Tailor Made', lRecCash );
    bonificacao = getIBP2( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' ) );
  }

  private List< Investimento_Bonificacao_e_Pagamento__c > getIBP( String aFinalidade, Id aRecType )
  {
      List< Investimento_Bonificacao_e_Pagamento__c > lList = [ Select Mes__c, Ano_Calendario__c, 
              Valor_R__c, Ano_Fiscal__c
              from Investimento_Bonificacao_e_Pagamento__c where Finalidade__c =:aFinalidade 
              and LAT_Contract__c =: fObj.id and RecordTypeid =: aRecType ];
      return lList;
  }

  //MIGRATED 21/11/2016
  private List< BonificacaoProdutos > getIBP2( Id aRecType ) {
    
    if(!Utils.wasMigrationDone('1')) {
      List< BonificacaoProdutos > lResult = new List< BonificacaoProdutos >();
      List< Investimento_Bonificacao_e_Pagamento__c > lList = [ Select Mes__c, Ano_Calendario__c, 
              Ano_Fiscal__c, Produto_Bonificado__r.name, Volume_Cx__c
              from Investimento_Bonificacao_e_Pagamento__c where LAT_Contract__c =: fObj.id 
              and RecordTypeid =: aRecType order by Data_de_Previsao_do_Pagamento__c];//Ano_Fiscal__c, Ano_Calendario__c, Mes__c ];
      String lLastKey = '';
      for ( Investimento_Bonificacao_e_Pagamento__c ibp : lList )
      {
        String lKey = ibp.Ano_Fiscal__c + '|' + ibp.Mes__c + '|' + ibp.Ano_Calendario__c;
        BonificacaoProdutos lProduto = new BonificacaoProdutos();
        if ( lLastKey != lKey )
        {
          lProduto.anoCalendario = ibp.Ano_Calendario__c;
          lProduto.mes = ibp.Mes__c;
          lProduto.periodo = ibp.Ano_Fiscal__c;
          lLastKey = lKey;
        }
        else
        { 
          lProduto.anoCalendario = '';
          lProduto.mes = '';
          lProduto.periodo = '';
        }
        lProduto.produto = ibp.Produto_Bonificado__r.name;
        lProduto.volume = ibp.Volume_Cx__c;
        lResult.add( lProduto );
      }
      return lResult;
    
    }else{
      List< BonificacaoProdutos > lResult = new List< BonificacaoProdutos >();
      List< Investimento_Bonificacao_e_Pagamento__c > lList = [ Select Mes__c, Ano_Calendario__c, 
              Ano_Fiscal__c, LAT_Product__r.name, Volume_Cx__c
              from Investimento_Bonificacao_e_Pagamento__c where LAT_Contract__c =: fObj.id 
              and RecordTypeid =: aRecType order by Data_de_Previsao_do_Pagamento__c];//Ano_Fiscal__c, Ano_Calendario__c, Mes__c ];
      String lLastKey = '';
      for ( Investimento_Bonificacao_e_Pagamento__c ibp : lList )
      {
        String lKey = ibp.Ano_Fiscal__c + '|' + ibp.Mes__c + '|' + ibp.Ano_Calendario__c;
        BonificacaoProdutos lProduto = new BonificacaoProdutos();
        if ( lLastKey != lKey )
        {
          lProduto.anoCalendario = ibp.Ano_Calendario__c;
          lProduto.mes = ibp.Mes__c;
          lProduto.periodo = ibp.Ano_Fiscal__c;
          lLastKey = lKey;
        }
        else
        { 
          lProduto.anoCalendario = '';
          lProduto.mes = '';
          lProduto.periodo = '';
        }
        lProduto.produto = ibp.LAT_Product__r.name;
        lProduto.volume = ibp.Volume_Cx__c;
        lResult.add( lProduto );
      }
      return lResult;
    }
    return null;
  }
}