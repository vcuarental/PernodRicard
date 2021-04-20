@isTest
private class DAOTest {

  static testMethod void myUnitTest() 
  {
    ClausulaContratoDAO.getInstance().getListClausulaContratoByIdContrato( '1' );
    DistribuicaoValoresDAO.getInstance().getListDistribuicaoByIdsClausula( new List< String >{'1'} );
    InvestimentoBonificaoPagamentoDAO.getInstance().getIBPById( '1' );
    InvestimentoBonificaoPagamentoDAO.getInstance().getListInvestBonifPagByIdsIBP( new List< String >{'1'} );
    PagamentoDAO.getInstance().getPagamentoById( '1' );
    PagamentoVerbaDAO.getInstance().getListPagVerbaByIdPgto( '1' );
    RateioContratoDAO.getInstance().getListRateioByContractId( '1' );
    TipoDocumentoDAO.getInstance().getListTipoDocumento( '1' );
  }
}