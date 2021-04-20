@isTest
public with sharing class ASI_HK_CRM_TestUtils {
    
    public static ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
    public static ASI_HK_CRM_BrandGenerator brandGen = new ASI_HK_CRM_BrandGenerator();
    public static ASI_HK_CRM_SubBrandGenerator sbGen = new ASI_HK_CRM_SubBrandGenerator();
    public static ASI_HK_CRM_ItemGroupGenerator igGen = new ASI_HK_CRM_ItemGroupGenerator();
    public static ASI_HK_CRM_SKUGenerator skuGen = new ASI_HK_CRM_SKUGenerator();
    public static ASI_HK_CRM_CustomerProductPriceGenerator custPdPriceGen = new ASI_HK_CRM_CustomerProductPriceGenerator();
    public static ASI_HK_CRM_SalesOrderGenerator soGen = new ASI_HK_CRM_SalesOrderGenerator();
    public static ASI_HK_CRM_SalesOrderDetailGenerator soDetailGen = new ASI_HK_CRM_SalesOrderDetailGenerator();
    
    public static void initSOEssentialSettings() {
        ASI_HK_CRM_CustomSettingGenerator.initThresholdValues();
        ASI_HK_CRM_RunningNumberGenerator.initSORunningNumber();
        ASI_HK_CRM_CustomSettingGenerator.initWebServiceErrorAddress();
        ASI_HK_CRM_CustomSettingGenerator.initRepeatWebService();
    } 

    //Used for testing the delivery date only
    public static void initSOEssentialSettings(String thresold1, String thresold2) {
        ASI_HK_CRM_RunningNumberGenerator.initSORunningNumber();
        ASI_HK_CRM_CustomSettingGenerator.initThresholdValues(thresold1,thresold2);
    }
    
    public static void initSOWSSettings() {
        ASI_HK_CRM_WebServiceSettingGenerator.initSOWSSetting();
    }
    
    public static void initARWSSettings() {
        ASI_HK_CRM_WebServiceSettingGenerator.initARWSSetiing();
    }
    

    
    public static void assignCreditAccountData(CommonData cmData, Integer numOfSKU, Integer numOfSKUPos) {
        cmData.acctDAParent = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT);
        insert cmData.acctDAParent;
        cmData.acctDA = acctGen.generateCreditDAAccount(cmData.acctDAParent);
        insert cmData.acctDA;
        cmData.acctPA = cmData.acctDAParent;
        
        cmData.brand = brandGen.generateBrand();
        insert cmData.brand;
        cmData.subBrand = sbGen.generateSubBrand(cmData.brand);
        insert cmData.subBrand;
        cmData.itemGroup = igGen.generateItemGroup(cmData.subBrand);
        insert cmData.itemGroup;
        cmData.skuList = new List<ASI_MFM_SKU_Code__c>();
        if (numOfSKU == null) numOfSKU = 1;
        for (Integer i = 0; i < numOfSKU; i++) {
            cmData.skuList.add(skuGen.generateSKU(cmData.itemGroup, false));
        }
        cmData.skuPosList = new List<ASI_MFM_SKU_Code__c>();
        if (numOfSKUPos == null) numOfSKUPos = 1;
        for (Integer i = 0; i < numOfSKUPos; i++) {
            cmData.skuPosList.add(skuGen.generateSKU(cmData.itemGroup, true));
        }
        List<ASI_MFM_SKU_Code__c> insertSkuList = new List<ASI_MFM_SKU_Code__c>();
        insertSkuList.addAll(cmData.skuList);
        insertSkuList.addAll(cmData.skuPosList);
        insert insertSkuList;
        
        // TODO: Insert customer product prices
    }
    
    public static void assignSalesOrderData(CommonData soData, Integer numOfSoDetail, Integer numOfSoDetailPos) {
        soData.so = soGen.generateSalesOrder(soData.acctDA, soData.acctPA, ASI_HK_CRM_SalesOrderGenerator.RT_Default);
        insert soData.so;
        if (numOfSoDetail == null) numOfSoDetail = 1;
        if (numOfSoDetail > soData.skuList.size()) numOfSoDetail = soData.skuList.size();
        soData.soDetailList = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        for (Integer i = 0; i < numOfSoDetail; i++) {
            soData.soDetailList.add(soDetailGen.generateSalesOrderDetail(soData.so, soData.skuList.get(i)));
        }
        if (numOfSoDetailPos == null) numOfSoDetailPos = 1;
        if (numOfSoDetailPos > soData.skuPosList.size()) numOfSoDetailPos = soData.skuPosList.size();
        soData.soDetailPosList = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        for (Integer i = 0; i < numOfSoDetail; i++) {
            soData.soDetailPosList.add(soDetailGen.generateSalesOrderDetail(soData.so, soData.skuPosList.get(i)));
        }
        List<ASI_HK_CRM_Sales_Order_Item__c> insertSoDetailList = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        insertSoDetailList.addAll(soData.soDetailList);
        insertSoDetailList.addAll(soData.soDetailPosList);
        insert insertSoDetailList;
    }
    
    public virtual class CommonData {
        public Account acctDA;
        public Account acctDAParent;
        public Account acctPA;
        public ASI_MFM_Brand__c brand;
        public ASI_MFM_Sub_brand__c subBrand;
        public ASI_MFM_Item_Group__c itemGroup;
        public List<ASI_MFM_SKU_Code__c> skuList;
        public List<ASI_MFM_SKU_Code__c> skuPosList;
        // Sales Order data
        public ASI_HK_CRM_Sales_Order__c so;
        public List<ASI_HK_CRM_Sales_Order_Item__c> soDetailList;
        public List<ASI_HK_CRM_Sales_Order_Item__c> soDetailPosList;
    }
}