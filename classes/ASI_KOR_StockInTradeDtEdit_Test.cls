@isTest
public class ASI_KOR_StockInTradeDtEdit_Test{

public static testMethod void test_main() {
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
        
        ASI_KOR_Stock_In_Trade__c prevSit = sitGen.generateBasicStockInTrade(ws, ASI_KOR_StockInTradeGenerator.DEF_VALUE_YEAR, ASI_KOR_StockInTradeGenerator.DEF_VALUE_MONTH_PREVIOUS);
        insert prevSit;
        ASI_KOR_WS_Stock_In_Trade_Detail__c prevSitDetail = sitDetailGen.generateStockInTradeDetail(prevSit, itemGroups.get(0));
        insert prevSitDetail;
        
        ASI_KOR_Stock_In_Trade__c sit = sitGen.generateStockInTrade(ws);
        insert sit;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(sit);
        
        Test.startTest();
        
        // Initialize the page
        PageReference testPage = Page.ASI_KOR_StockInTradeDtEditPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', sit.Id);
        Test.setCurrentPageReference(testPage);
        ASI_KOR_StockInTradeDtEditController testCon = new ASI_KOR_StockInTradeDtEditController(stdController);
        ASI_KOR_MassCreateAndUpdateController mcauCon = new ASI_KOR_MassCreateAndUpdateController();
        ASI_KOR_SFObjSelectTableController sobjstCon = new ASI_KOR_SFObjSelectTableController();
        
        // Assign component attributes
        mcauCon.sObjTypeStr = 'ASI_KOR_WS_Stock_In_Trade_Detail__c';
        mcauCon.displayFieldsStr = 'ASI_KOR_Item_Group_Code__c&req=T&read=A, ASI_KOR_WS_SIT_End_Stock__c&req=T, ASI_KOR_WS_SIT_LastMonthEndingStock__c&read=A';
        mcauCon.whereStatm = 'Stock_In_Trade__c = \'' + testCon.stockInTradeHeader.Id + '\'';
        mcauCon.pageBlockTitleStr = Schema.SObjectType.ASI_KOR_WS_Stock_In_Trade_Detail__c.getLabel();
        mcauCon.successLink = '/' + testCon.stockInTradeHeader.Id;
        mcauCon.cancelLink = '/' + testCon.stockInTradeHeader.Id;
        mcauCon.mode = 'EDIT';
        mcauCon.showAllRT = true;
        mcauCon.isUseFirstRowForNew = false;
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.pageController = testCon.thisController;
        
        sobjstCon.sObjTypeStr = 'ASI_KOR_Item_Group__c';
        sobjstCon.displayFieldsStr = 'Name, ASI_KOR_Name_Kor__c, ASI_KOR_Sub_Brand__c, ASI_KOR_Product_Grade__c, ASI_KOR_Standard_Bottle_Size__c';
        sobjstCon.defWhereStatmStr = testCon.baseWhereStatm;
        sobjstCon.orderByStr = 'Name';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.componentKey = 'selectTable';
        sobjstCon.pageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        // Start testing user actions
        
        // Clone from previous month
        pageParams.put('PARAM_PB_BTN_ID', 'cloneLatest');
        mcauCon.triggerPageBlockAction();
        
        // Change page number
        sobjstCon.nextPage();
        sobjstCon.lastPage();
        sobjstCon.prevPage();
        sobjstCon.firstPage();
        
        // Filter products
        testCon.filterIGNameOrCode = itemGroups.get(1).Name;
        testCon.filterItemGroup();
        System.assertEquals(1, sobjstCon.tableEleList.size());
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Remove product
        pageParams.put(mcauCon.PARAM_RTID, ASI_KOR_MassCreateAndUpdateController.RTDEVNAME_MASTER);
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
        mcauCon.removeNew();
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Set values
        mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_KOR_WS_SIT_End_Stock__c', 2);
        
        // Save
        mcauCon.commitAll();
        
        List<ASI_KOR_WS_Stock_In_Trade_Detail__c> sitDetails = [
            SELECT Id FROM ASI_KOR_WS_Stock_In_Trade_Detail__c WHERE Stock_In_Trade__c = :sit.Id
        ];
        //System.assertEquals(2, sitDetails.size());
        
        Test.stopTest();
    }

}