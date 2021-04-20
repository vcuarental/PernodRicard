@isTest
public class ASI_KOR_StockInTradeRestAPI_Test {

    static testMethod void test_main() {
        ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
        ASI_KOR_BrandGenerator brandGen = new ASI_KOR_BrandGenerator();
        ASI_KOR_SubBrandGenerator sbGen = new ASI_KOR_SubBrandGenerator();
        ASI_KOR_ItemGroupGenerator igGen = new ASI_KOR_ItemGroupGenerator();
        ASI_KOR_StockInTradeGenerator sitGen = new ASI_KOR_StockInTradeGenerator();
        ASI_KOR_StockInTradeDetailGenerator sitDetailGen = new ASI_KOR_StockInTradeDetailGenerator();
        
        Account ws = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_WS);
        insert ws;
        
        ASI_KOR_Brand__c brand = brandGen.generateBrand();
        insert brand;
        ASI_KOR_Sub_Brand__c sb = sbGen.generateSubBrand(brand);
        insert sb;
        List<ASI_KOR_Item_Group__c> itemGroups = new List<ASI_KOR_Item_Group__c>();
        for (Integer i = 0; i < 3; i++) {
            ASI_KOR_Item_Group__c tempIG = igGen.generateItemGroup(sb);
            itemGroups.add(tempIG);
        }
        insert itemGroups;
        
        ASI_KOR_Stock_In_Trade__c sit = sitGen.generateBasicStockInTrade(ws, ASI_KOR_StockInTradeGenerator.DEF_VALUE_YEAR, ASI_KOR_StockInTradeGenerator.DEF_VALUE_MONTH_PREVIOUS);
        insert sit;
        sit = [SELECT Id, Name, ASI_KOR_Wholesaler__c, ASI_KOR_Year__c, ASI_KOR_Month__c, LastModifiedDate FROM ASI_KOR_Stock_In_Trade__c WHERE Id = :sit.Id];
        List<ASI_KOR_WS_Stock_In_Trade_Detail__c> sitDetails = new List<ASI_KOR_WS_Stock_In_Trade_Detail__c>();
        sitDetails.add(sitDetailGen.generateStockInTradeDetail(sit, itemGroups.get(0)));
        sitDetails.add(sitDetailGen.generateStockInTradeDetail(sit, itemGroups.get(1)));
        insert sitDetails;
        ASI_KOR_WS_Stock_In_Trade_Detail__c sitDetail = sitDetails.get(0);
        sitDetail = [SELECT Id, Name, Stock_In_Trade__c, ASI_KOR_Item_Group_Code__c, ASI_KOR_WS_SIT_End_Stock__c, LastModifiedDate FROM ASI_KOR_WS_Stock_In_Trade_Detail__c WHERE Id = :sitDetail.Id];
        
        RestRequest req = new RestRequest();
        RestContext.request = req;
        req.httpMethod = 'POST';
        
        Test.startTest();
        
        String origYear = sit.ASI_KOR_Year__c;
        sit.ASI_KOR_Year__c = 'year';
        Map<String, String> result = null;
        try {
            result = ASI_KOR_StockInTradeRestAPI.submitChanges(sit, null, new List<ASI_KOR_WS_Stock_In_Trade_Detail__c> {sitDetail});
        } catch (ASI_KOR_CustomException ce) {
            System.debug(ce);
        }
        sit.ASI_KOR_Year__c = origYear;
        
        Decimal newEndStock = sitDetail.ASI_KOR_WS_SIT_End_Stock__c + 1;
        sitDetail.ASI_KOR_WS_SIT_End_Stock__c = newEndStock;
        result = ASI_KOR_StockInTradeRestAPI.submitChanges(sit, null, new List<ASI_KOR_WS_Stock_In_Trade_Detail__c> {sitDetail});
        
        Test.stopTest();
        
        System.assertEquals('true', result.get('success'));
        String sitId = result.get('id');
        List<ASI_KOR_Stock_In_Trade__c> sitList = [SELECT Id, (SELECT Id, ASI_KOR_WS_SIT_End_Stock__c FROM Stock_In_Trade_Details__r) FROM ASI_KOR_Stock_In_Trade__c WHERE Id = :sitId];
        System.assertEquals(1, sitList.size());
        System.assertEquals(1, sitList.get(0).Stock_In_Trade_Details__r.size());
        System.assertEquals(newEndStock, sitList.get(0).Stock_In_Trade_Details__r.get(0).ASI_KOR_WS_SIT_End_Stock__c);
    }

}