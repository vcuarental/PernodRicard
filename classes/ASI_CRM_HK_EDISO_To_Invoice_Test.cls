/**********************************************************************************
 * Name: ASI_CRM_HK_EDISO_To_Invoice_Test
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/03/2019       Wilken Lee              [WL 1.0] Coverage for SKU Mapping Trigger Class
 * 24/09/2020       COE                     [COE 1.0] Test class for ASI_CRM_HK_SO_PDF_PageController
*/
@isTest 
public class ASI_CRM_HK_EDISO_To_Invoice_Test 
{
    public static ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
    public static ASI_HK_CRM_BrandGenerator brandGen = new ASI_HK_CRM_BrandGenerator();
    public static ASI_HK_CRM_SubBrandGenerator sbGen = new ASI_HK_CRM_SubBrandGenerator();
    public static ASI_HK_CRM_ItemGroupGenerator igGen = new ASI_HK_CRM_ItemGroupGenerator();
    public static ASI_HK_CRM_SKUGenerator skuGen = new ASI_HK_CRM_SKUGenerator();
    public static ASI_HK_CRM_CustomerProductPriceGenerator custPdPriceGen = new ASI_HK_CRM_CustomerProductPriceGenerator();
    
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
            ASI_MFM_SKU_Code__c sku = skuGen.generateSKU(cmData.itemGroup, false);
            sku.ASI_HK_CRM_Available_Quantity__c = 100;
            sku.ASI_HK_CRM_Packaging_Size__c = 10;
            cmData.skuList.add(sku);
        }
        cmData.skuPosList = new List<ASI_MFM_SKU_Code__c>();
        if (numOfSKUPos == null) numOfSKUPos = 1;
        for (Integer i = 0; i < numOfSKUPos; i++) {
            ASI_MFM_SKU_Code__c sku = skuGen.generateSKU(cmData.itemGroup, true);
            sku.ASI_HK_CRM_Available_Quantity__c = 100;
            sku.ASI_HK_CRM_Packaging_Size__c = 10;
            cmData.skuPosList.add(sku);
        }
    
    /*[WL 1.0] BEGIN*/
    ID iMapRTID = Global_RecordTypeCache.getRtId('ASI_CRM_SKU_Mapping__cASI_CRM_HK_EDI_Item_Group_Mapping');
    ASI_CRM_SKU_Mapping__c iMap = new ASI_CRM_SKU_Mapping__c(
                                ASI_CRM_Account__c = cmData.acctDA.ID,
                                ASI_CRM_Item_Number__c = 'Item1',
                                ASI_CRM_Item_Group__c = cmData.itemGroup.Id,
                                RecordTypeID = iMapRTID,
                                ASI_CRM_Inactive__c = false,
                                ASI_CRM_Preferred__c = true
                              );
    insert iMap;
    /*[WL 1.0] END*/
    
    
        List<ASI_MFM_SKU_Code__c> insertSkuList = new List<ASI_MFM_SKU_Code__c>();
        insertSkuList.addAll(cmData.skuList);
        insertSkuList.addAll(cmData.skuPosList);
        insert insertSkuList;

    /*[WL 1.0] BEGIN*/
    ASI_CRM_SKU_Mapping__c iMap2 = new ASI_CRM_SKU_Mapping__c(
                                ASI_CRM_Account__c = cmData.acctDA.ID,
                                ASI_CRM_Item_Number__c = 'Item2',
                                ASI_CRM_Item_Group__c = cmData.itemGroup.Id,
                                RecordTypeID = iMapRTID,
                                ASI_CRM_Inactive__c = false,
                                ASI_CRM_Preferred__c = true
                              );
    insert iMap2;
    /*[WL 1.0] END*/
    
        List<ASI_CRM_SKU_Mapping__c> skuMapList = new List<ASI_CRM_SKU_Mapping__c>();
    
        ID sMapRTID = Global_RecordTypeCache.getRtId('ASI_CRM_SKU_Mapping__cASI_CRM_HK_EDI_SKU_Mapping');
        for (Integer i = 0; i < numOfSKU; i++)
        {
            ASI_CRM_SKU_Mapping__c sMap = new ASI_CRM_SKU_Mapping__c(
                ASI_CRM_Account__c = cmData.acctDA.ID,
                ASI_CRM_Item_Number__c = cmData.skuList[i].ASI_MFM_SKU_Code__c,
                ASI_CRM_SKU__c = cmData.skuList[i].ID,
                RecordTypeID = sMapRTID,
                ASI_CRM_Inactive__c = false
            );

            skuMapList.add(sMap);
        }
        insert skuMapList;

        ID cMapRTID = Global_RecordTypeCache.getRtId('ASI_CRM_Customer_Mapping__cASI_CRM_HK_EDI_Customer_Mapping');
        ASI_CRM_Customer_Mapping__c cMap = new ASI_CRM_Customer_Mapping__c(
            ASI_CRM_Account__c = cmData.acctDA.ID,
            ASI_CRM_Buyer_ID__c = 'BUY1',
            ASI_CRM_UOM__c = 'Bottle',
            RecordTypeID = cMapRTID
        );
        insert cMap;
    }
    
    public static void assignEDISalesOrderData(CommonData soData, Integer numOfSoDetail, Integer numOfSoDetailPos) {

        soData.eso = new ASI_CRM_EDI_SO_Header__c(
            ASI_CRM_Buyer_ID__c = 'BUY1',
            ASI_CRM_Buyer_Name__c = 'BUYNAME',
            ASI_CRM_Buyer_Name_2__c = 'BUYNAME2',
            ASI_CRM_Customer_DA__c = soData.acctDA.ID,
            ASI_CRM_Customer_PO__c = 'PO1',
            ASI_CRM_Delivery_Date__c = System.now().addDays(-10).format('yyyy-MM-dd'),
            ASI_CRM_CRM_SO_Completed__c = true,
            ASI_CRM_ETL_Complete__c = false,
            ASI_CRM_Order_Date__c = System.now().format('yyyy-MM-dd')
        );
        insert soData.eso;

        if (numOfSoDetail == null) numOfSoDetail = 1;
        if (numOfSoDetail > soData.skuList.size()) numOfSoDetail = soData.skuList.size();
        
        soData.esoDetailList = new List<ASI_CRM_EDI_SO_Item__c>();
        
        for (Integer i = 0; i < numOfSoDetail; i++) {
            ASI_CRM_EDI_SO_Item__c soD = new ASI_CRM_EDI_SO_Item__c(
                ASI_CRM_EDI_Sales_Order_Header__c = soData.eso.ID,
                ASI_CRM_CRM_Per_Bottle_Price__c = 100,
                ASI_CRM_EDI_Per_Bottle_Price__c = 100,
                ASI_CRM_Item_Line_Number__c = String.valueOf(i + 1),
                ASI_CRM_Order_Quantity__c = '1',
                ASI_CRM_Price__c = '100.00',
                ASI_CRM_SKU_Code__c = 'SKUC' + String.valueOf(i + 2),
                ASI_CRM_SKU_Description__c = 'SKUD1',
                ASI_CRM_SKU_Description_2__c = 'SKUD2',
                ASI_CRM_Not_Fulfilled__c = false
            );
            soData.esoDetailList.add(soD);
        }
        
        List<ASI_CRM_EDI_SO_Item__c> insertSoDetailList = new List<ASI_CRM_EDI_SO_Item__c>();
        insertSoDetailList.addAll(soData.esoDetailList);
        insert insertSoDetailList;

        soData.eso.ASI_CRM_ETL_Complete__c = true;
        update soData.eso;

        soData.soHist = new ASI_HK_CRM_Sales_Order_History__c(
            ASI_HK_CRM_Account_PA__c = soData.acctDA.ID,
            // ASI_CRM_AccountAdditionalField__c = soData.acctDA.ID,
            ASI_HK_CRM_Customer_PO__c = 'PO1',
            ASI_HK_CRM_JDE_Invoice_No__c = 'INV01',
            ASI_CRM_Invoice_Date__c = System.today(),
            ASI_HK_CRM_Order_Type__c = 'S1'
        );
        insert soData.soHist;

        soData.sodHistList = new List<ASI_HK_CRM_Sales_Order_History_Detail__c>();
        
        for (Integer i = 0; i < numOfSoDetail; i++) {
            ASI_HK_CRM_Sales_Order_History_Detail__c sodHist = new ASI_HK_CRM_Sales_Order_History_Detail__c(
                ASI_HK_CRM_Sales_Order_History__c = soData.soHist.ID,
                ASI_HK_CRM_Product_SKU__c = soData.skuList[i].ID,
                ASI_HK_CRM_Quantity_in_Bottles__c = 100,
                ASI_HK_CRM_Total_Amount__c = 200
            );
            soData.sodHistList.add(sodHist);
        }

        insert soData.sodHistList;
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
        public List<ASI_CRM_SKU_Mapping__c> skuMapList;
        public List<ASI_CRM_Customer_Mapping__c> custMapList;
        public ASI_HK_CRM_Sales_Order_History__c soHist;
        public List<ASI_HK_CRM_Sales_Order_History_Detail__c> sodHistList;

        // Sales Order data
        public ASI_CRM_EDI_SO_Header__c eso;
        public List<ASI_CRM_EDI_SO_Item__c> esoDetailList;
        public List<ASI_CRM_EDI_SO_Item__c> esoDetailPosList;
    }

    static testMethod void EDISO_To_Invoice_Trigger_Test() 
    {
        Test.startTest();

        initSOEssentialSettings();
        initSOWSSettings();
        CommonData cmData = new CommonData();
        assignCreditAccountData(cmData, 3, 3);
        assignEDISalesOrderData(cmData, 3, 3);

        Test.stopTest();
    }

    static testMethod void EDISO_To_Invoice_Batch_Test() 
    {
        initSOEssentialSettings();
        initSOWSSettings();
        CommonData cmData = new CommonData();
        assignCreditAccountData(cmData, 3, 3);
        assignEDISalesOrderData(cmData, 3, 3);

        Test.startTest();

        ASI_CRM_HK_EDISO_To_Invoice_Scheduler sh1 = new ASI_CRM_HK_EDISO_To_Invoice_Scheduler();
        String sch = '0 0 0 1 * ?'; 
        system.schedule('Convert EDI SO To Invoice Scheduler Check', sch, sh1); 
            
        Test.stopTest();
    }
    
    //[COE 1.0]
    static testMethod void EDISO_PDF_Test(){
        //initSOEssentialSettings();
        //initSOWSSettings();
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        Test.startTest();
       
        //CommonData soData = new CommonData();
        
        //EDI SO Header
        ASI_CRM_EDI_SO_Header__c EDISOH = new ASI_CRM_EDI_SO_Header__c(
            ASI_CRM_Buyer_ID__c = 'BUY1',
            ASI_CRM_Buyer_Name__c = 'BUYNAME',
            ASI_CRM_Buyer_Name_2__c = 'BUYNAME2',
            ASI_CRM_Customer_DA__c = cmData.acctDA.ID,
            ASI_CRM_Customer_PO__c = 'PO1',
            ASI_CRM_Delivery_Date__c = System.now().addDays(-10).format('yyyy-MM-dd'),
            ASI_CRM_CRM_SO_Completed__c = true,
            ASI_CRM_ETL_Complete__c = false,
            ASI_CRM_Order_Date__c = System.now().format('yyyy-MM-dd')
        );
        insert EDISOH;
        
        so.ASI_HK_CRM_EDI_SO__c =EDISOH.Id;
        
        update so;
        
         //EDI SO Detail
        List<ASI_CRM_EDI_SO_Item__c> esoDetailList = new List<ASI_CRM_EDI_SO_Item__c>();
        for (Integer i = 0; i < 6; i++) {
            ASI_CRM_EDI_SO_Item__c soD = new ASI_CRM_EDI_SO_Item__c(
                ASI_CRM_EDI_Sales_Order_Header__c = EDISOH.Id,
                ASI_CRM_CRM_Per_Bottle_Price__c = 100,
                ASI_CRM_EDI_Per_Bottle_Price__c = 100,
                ASI_CRM_Item_Line_Number__c = String.valueOf(i + 1),
                ASI_CRM_Order_Quantity__c = '1',
                ASI_CRM_Price__c = '100.00',
                ASI_CRM_SKU_Code__c = 'SKUC' + String.valueOf(i + 2),
                ASI_CRM_SKU_Description__c = 'SKUD1',
                ASI_CRM_SKU_Description_2__c = 'SKUD2',
                ASI_CRM_Not_Fulfilled__c = false
            );
            esoDetailList.add(soD);
        }
        insert esoDetailList;
        
        ASI_CRM_HK_SO_PDF_PageController ext = new ASI_CRM_HK_SO_PDF_PageController(new ApexPages.StandardController(so));
        ext.SOID = so.Id;
        ext.init();
        
        Test.stopTest();
    }
    
    
    
}