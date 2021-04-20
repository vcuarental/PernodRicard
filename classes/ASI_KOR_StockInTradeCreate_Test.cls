@isTest
public class ASI_KOR_StockInTradeCreate_Test {

  public static testMethod void test_main() {
    ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
    ASI_KOR_StockInTradeGenerator sitGen = new ASI_KOR_StockInTradeGenerator();
    
    Account ws = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_WS);
    insert ws;
    
    ASI_KOR_Stock_In_Trade__c sit = sitGen.generateStockInTrade(ws);
    insert sit;
    
    ApexPages.StandardController stdCon = new ApexPages.StandardController(sit);
    
    Test.startTest();
    
    ASI_KOR_StockInTradeCreateController testCon = new ASI_KOR_StockInTradeCreateController(stdCon);
    PageReference initRedirectPage = testCon.redirect();
    
    System.assertEquals(Page.ASI_KOR_StockInTradeDtEditPage.getUrl(), initRedirectPage.getParameters().get('saveURL'));
    
    Test.stopTest();
  }

}