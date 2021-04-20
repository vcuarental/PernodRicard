@isTest
public with sharing class ASI_HK_CRM_SalesOrderRequestDtEdTest {

    private static ASI_HK_CRM_TestUtils.CommonData cmData;
    
    static {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
    }


    static testMethod void salesOrderRequestDtEdTest(){
        Test.startTest();
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        //ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        //ASI_HK_CRM_TestUtils.initSOWSSettings();

        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        insert acctCredit;        

        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Order_Status_Name__c ='Draft';
        
        update so;
        
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cmData.soDetailList);
        
        PageReference testPage = Page.ASI_HK_CRM_SalesOrderRequestDtEdPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', so.id);
        Test.setCurrentPageReference(testPage);
        
        ASI_HK_CRM_SalesOrderRequestDtEdCON testController = new ASI_HK_CRM_SalesOrderRequestDtEdCON(stdSetController);
        ASI_HK_CRM_SalesOrderRequestDtEdCON.lineItemList(so.id);
        ASI_HK_CRM_SalesOrderRequestDtEdCON.normalProductList(acctCredit.id, true);
        
        List<ASI_HK_CRM_SalesOrderRequestDtEdCON.ASI_HK_CRM_DataTableServerInput> dataTableList = new List<ASI_HK_CRM_SalesOrderRequestDtEdCON.ASI_HK_CRM_DataTableServerInput>(); 
        ASI_HK_CRM_SalesOrderRequestDtEdCON.ASI_HK_CRM_DataTableServerInput dataTable;
        dataTable = new ASI_HK_CRM_SalesOrderRequestDtEdCON.ASI_HK_CRM_DataTableServerInput();
        dataTable.name = 'hello';
        dataTableList.add(dataTable);
        ASI_HK_CRM_SalesOrderRequestDtEdCON.posProductDataTableResult(dataTableList);
                        
        List<ASI_HK_CRM_SalesOrderRequestDtEdCON.ASI_HK_CRM_SOLineItem> soRemoteList = new List<ASI_HK_CRM_SalesOrderRequestDtEdCON.ASI_HK_CRM_SOLineItem>();                 
        ASI_HK_CRM_SalesOrderRequestDtEdCON.ASI_HK_CRM_SOLineItem soRemote; 
        soRemote = new ASI_HK_CRM_SalesOrderRequestDtEdCON.ASI_HK_CRM_SOLineItem();
        soRemote.id = cmData.soDetailList[0].id;
        soRemoteList.add(soRemote);
        ASI_HK_CRM_SalesOrderRequestDtEdCON.saveChanges(so.id, soRemoteList);
        
        Test.stopTest();
    }    
}