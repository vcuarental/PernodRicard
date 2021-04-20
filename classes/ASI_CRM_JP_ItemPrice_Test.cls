@isTest
public class ASI_CRM_JP_ItemPrice_Test {

    
    static testMethod void ItemPrice_Test(){
        Map<String, Object> priceListFieldValueMap = ASI_CRM_JP_TestHelper.PRICE_LIST_DEFAULT_VALUE_MAP;
        ASI_CRM_Price_List__c priceList = ASI_CRM_JP_TestHelper.createPriceList(priceListFieldValueMap);
        priceList.ASI_CRM_JP_Effective_Date__c = System.today().addDays(2);
        insert priceList;
        
        Map<String, Object> itemGroupFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_GROUP_DEFAUL_VALUE_MAP;
        ASI_MFM_Item_Group__c itemGroup = ASI_CRM_JP_TestHelper.createItemGroup(itemGroupFieldValueMap);
        itemGroup.ASI_CRM_Group_RSP__c = 100;
        insert itemGroup;
        
        List<ASI_MFM_SKU_Code__c> skuCodeList = new List<ASI_MFM_SKU_Code__c>();
        for(Integer index = 0 ; index < 2 ; index++) {
            Map<String, Object> skuCodeFieldValueMap = ASI_CRM_JP_TestHelper.SKU_DEFAULT_VALUE_MAP;
            skuCodeFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
            ASI_MFM_SKU_Code__c skuCode = ASI_CRM_JP_TestHelper.createSKU(skuCodeFieldValueMap);
            skuCode.ASI_HK_CRM_Active__c = true;
            skuCodeList.add(skuCode);
        }
        insert skuCodeList;
        
        ASI_CRM_Customer_Group__c CustGrp = new ASI_CRM_Customer_Group__c ();
        CustGrp.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Customer_Group__cASI_CRM_JP_D_C_Customer_Group');
        CustGrp.name = 'Test group';
        CustGrp.ASI_CRM_Customer_Group_Code__c = '123';
        insert CustGrp;
        
        ASI_CRM_Customer_Group__c CustGrp1 = new ASI_CRM_Customer_Group__c ();
        CustGrp1.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Customer_Group__cASI_CRM_JP_D_C_Customer_Group');
        CustGrp1.name = 'Test group1';
        CustGrp1.ASI_CRM_Customer_Group_Code__c = '234';
        insert CustGrp1;
        
        List<ASI_CRM_JP_Customer_Product_Price__c> tempList = new List<ASI_CRM_JP_Customer_Product_Price__c>();
        ASI_CRM_JP_Customer_Product_Price__c itemBasePrice = new ASI_CRM_JP_Customer_Product_Price__c();
        itemBasePrice.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Customer_Product_Price__cASI_CRM_JP_D_C_Product_Price');
        itemBasePrice.ASI_CRM_JP_Active__c = true;
        itemBasePrice.ASI_Bottle_Price__c = 100;
        itemBasePrice.ASI_MFM_Item_Group__c = itemGroup.id;
        itemBasePrice.ASI_Effective_Date__c = System.today();
        itemBasePrice.ASI_CRM_Customer_Group__c = CustGrp.id; 
        tempList.add(itemBasePrice);
        
        ASI_CRM_JP_Customer_Product_Price__c itemBasePrice1 = new ASI_CRM_JP_Customer_Product_Price__c();
        itemBasePrice1.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Customer_Product_Price__cASI_CRM_JP_D_C_Product_Price');
        itemBasePrice1.ASI_CRM_JP_Active__c = true;
        itemBasePrice1.ASI_Bottle_Price__c = 100;
        itemBasePrice1.ASI_MFM_Item_Group__c = itemGroup.id;
        itemBasePrice1.ASI_Effective_Date__c = System.today();
        itemBasePrice1.ASI_CRM_Customer_Group__c = CustGrp1.id; 
        tempList.add(itemBasePrice1);
        
        insert tempList;
        
        ASI_CRM_JP_ItemPrice_Webservice.ItemPriceList itemPriceList = ASI_CRM_JP_ItemPrice_Webservice.getPriceList(String.valueOf(system.today()));
        
    }
    
    static testMethod void ItemPriceUpdate_Test(){
        Map<String, Object> priceListFieldValueMap = ASI_CRM_JP_TestHelper.PRICE_LIST_DEFAULT_VALUE_MAP;
        ASI_CRM_Price_List__c priceList = ASI_CRM_JP_TestHelper.createPriceList(priceListFieldValueMap);
        priceList.ASI_CRM_JP_Effective_Date__c = System.today().addDays(2);        
        insert priceList;
        
        Map<String, Object> itemGroupFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_GROUP_DEFAUL_VALUE_MAP;
        ASI_MFM_Item_Group__c itemGroup = ASI_CRM_JP_TestHelper.createItemGroup(itemGroupFieldValueMap);
        insert itemGroup;
        
        
        ASI_CRM_Customer_Group__c CustGrp = new ASI_CRM_Customer_Group__c ();
        CustGrp.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Customer_Group__cASI_CRM_JP_Direct_Sales_Customer_Group');
        CustGrp.name = 'Test group';
        CustGrp.ASI_CRM_Customer_Group_Code__c = '123';
        insert CustGrp;
        
        Map<String, Object> itemBasePriceFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_DEFAULT_VALUE_MAP;
        itemBasePriceFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_RECORD_TYPE.get('ASI_CRM_JP_Direct_Sales_Product_Price'));
        itemBasePriceFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
        ASI_CRM_JP_Customer_Product_Price__c itemBasePrice = ASI_CRM_JP_TestHelper.createItemBasePrice(itemBasePriceFieldValueMap);
        itemBasePrice.ASI_CRM_Customer_Group__c = CustGrp.id;
        insert itemBasePrice;
        
        List<ASI_CRM_JP_ItemPriceUpdate_Webservice.InputResult> inputList = new List<ASI_CRM_JP_ItemPriceUpdate_Webservice.InputResult>();
        ASI_CRM_JP_ItemPriceUpdate_Webservice.InputResult input = new ASI_CRM_JP_ItemPriceUpdate_Webservice.InputResult();
        input.SKUCode = '000001';
        input.ItemGroupPrice = itemBasePrice.id;
        
        inputList.add(input);
        
        ASI_CRM_JP_ItemPriceUpdate_Webservice.OutputResult result = ASI_CRM_JP_ItemPriceUpdate_Webservice.updateItemPrice(inputList);
        
    }
}