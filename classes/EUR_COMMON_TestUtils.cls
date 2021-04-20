/**
* @Description: Common apex class to create test data to be used in test classes.
* @Author: Minakshi
* @Copyright: PARX
*/
public with sharing class EUR_COMMON_TestUtils
{
    /** Method to create Account */
    public static EUR_CRM_Account__c createAccount(String recordTypeName, String accName)
    {
		Id recordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(
            Name = accName,
            EUR_CRM_Customer_No_ERP__c = '21178',
            EUR_CRM_Street__c = 'MAIN STREET',
            EUR_CRM_City__c = 'BANGOR ERRIS',
            EUR_CRM_Country__c = 'Ireland',
            RecordTypeId = recordTypeId,
            EUR_CRM_Postal_Code__c = 'F26 R6Y9',
            EUR_CRM_Sales_Organization__c = '1100',
            EUR_CRM_Status__c = 'Active',
            EUR_CRM_Customer_Ship_To_No_ERP__c = '653088');
        insert account;
        System.debug('Test account ' + account);
        return account;
    }

    /** Method to create Account */
    public static EUR_CRM_Account__c createAccount(String recordTypeName)
    {
        //Id recordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByName().get('EUR IDL On Trade Account').getRecordTypeId();
        //Id recordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByName().get('EUR DE On Trade B2B').getRecordTypeId();
		Id recordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(
            Name = 'account test1',
            EUR_CRM_Customer_No_ERP__c = '21178',
            EUR_CRM_Street__c = 'MAIN STREET',
            EUR_CRM_City__c = 'BANGOR ERRIS',
            EUR_CRM_Country__c = 'Ireland',
            RecordTypeId = recordTypeId,
            EUR_CRM_Postal_Code__c = 'F26 R6Y9',
            EUR_CRM_Sales_Organization__c = '1100',
            EUR_CRM_Status__c = 'Active',
            EUR_CRM_Customer_Ship_To_No_ERP__c = '653088');
        insert account;
        System.debug('Test account ' + account);
        return account;
    }

    public static Contact createContact(EUR_CRM_Account__c acc)
    {
        Contact conAcc = new Contact(
            EUR_CRM_Account__c = acc.Id,
            FirstName='Jasmin',
            LastName='Ken',
            Phone='12345678');
        insert conAcc;
        return conAcc;
    }

    public static Contact createContact()
    {
        Contact con = new Contact(
            FirstName='Jasmin',
            LastName='Ken',
            Phone='12345678');
        insert con;
        return con;
    }    

    /** Method to create Brand */
    public static EUR_CRM_Brand__c createBrand()
    {
        EUR_CRM_Category__c category = createCategory();
        EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c(
            EUR_CRM_Brand_Code__c = 'TestBrandCode', Name = 'TestBrandName', EUR_CRM_Category__c = category.Id);
        insert brand;
        return brand;
    }

    /** Method to create Category */
    public static EUR_CRM_Category__c createCategory()
    {
        EUR_CRM_Category__c category = new EUR_CRM_Category__c(
        EUR_CRM_Category_Code__c = 'TestCategoryCode', Name = 'TestCategoryName');
        insert category;
        return category;
    }

    /** Method to create Brand Quality */
    public static EUR_CRM_Quality__c createBrandQuality()
    {
        EUR_CRM_Brand__c brand = createBrand();
        EUR_CRM_Quality__c brandQuality = new EUR_CRM_Quality__c(
            Name = 'BrandQuality', EUR_CRM_Brand__c = brand.Id
        );
        insert brandQuality;
        return brandQuality;
    }
    
    /** Method to create Brand Quality Size */
    public static EUR_CRM_Size__c createBrandQualitySize()
    {
        EUR_CRM_Quality__c brandQuality = createBrandQuality();
        EUR_CRM_Size__c brandQualitySize = new EUR_CRM_Size__c(
        Name = 'Small', EUR_CRM_Brand_Quality__c = brandQuality.Id);
        insert brandQualitySize;
        return brandQualitySize;
    }

    /** Method to create SKU */
    public static EUR_CRM_SKU__c createSKU()
    {
        EUR_CRM_Size__c brandQualitySize = createBrandQualitySize();
        EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c(
        EUR_CRM_Brand_Quality_Size__c = brandQualitySize.Id, Name = 'Test SKU', EUR_CRM_Article_no__c = '10113050',
        EUR_CRM_Unit_Type__c = 'Case', EUR_NIM_InventoryAmount__c = 'High', EUR_CRM_SKU_Code__c = 'TestCode', 
        EUR_CRM_Active__c = true);
        insert sku;
        return sku;
    }

    public static EUR_CRM_ProductCatalog__c createProductCatalog()
    {
        EUR_NIM_Sales_Order_Setting__mdt productCatalogName = EUR_COMMON_Utils.getSalesOrderMetadataValuesByCountryCode('IDL');

        EUR_CRM_ProductCatalog__c productCatalog = new EUR_CRM_ProductCatalog__c(Name = productCatalogName.EUR_NIM_Catalog_Name__c);
        insert productCatalog;
        return productCatalog;
    }

    public static EUR_CRM_ProductCatalogItem__c createProductCatalogItem()
    {
        EUR_CRM_SKU__c sku = createSKU();
        EUR_CRM_ProductCatalog__c productCatalog = createProductCatalog();
        EUR_CRM_ProductCatalogItem__c productCatalogItem = new EUR_CRM_ProductCatalogItem__c(
        EUR_CRM_SKU__c = sku.Id, EUR_CRM_PriceBookID__c = productCatalog.Id);
        insert productCatalogItem;
        return productCatalogItem;
    }
    
    /** Method to create Sales Order */
    public static EUR_CRM_Sales_Order__c createSalesOrder()
    {
        EUR_CRM_Sales_Order__c insertRecord = new EUR_CRM_Sales_Order__c();
        EUR_CRM_Account__c acc = [Select Id, Name from EUR_CRM_Account__c limit 1];
        Contact conAcc = [Select Id, Name from Contact limit 1];
        //EUR_CRM_Account__c acc = createAccount('EUR IDL On Trade Account');
        //Contact conAcc = createContact(acc);

        insertRecord.EUR_CRM_Account__c = acc.Id;
        insertRecord.EUR_CRM_Delivery_Date__c = Date.today().addDays(1);
        insertRecord.EUR_CRM_Contact_Person__c = conAcc.Id;
        insertRecord.EUR_CRM_Status__c = 'Draft';
        insertRecord.EUR_CRM_Order_Status__c = 'Draft';
        insertRecord.RecordTypeId = EUR_COMMON_Utils.recordTypes.get('EUR_CRM_Sales_Order__c:EUR_Direct');
        
        insert insertRecord;
        
        return insertRecord;
    }

    /** Method to create Sales Order Items*/
    public static EUR_CRM_Sales_Order_Items__c createSalesOrderItems()
    {
        EUR_CRM_Sales_Order__c salesOrderRec = createSalesOrder();
        EUR_CRM_ProductCatalogItem__c productCatalogItem = createProductCatalogItem();
        EUR_CRM_Sales_Order_Items__c item = new EUR_CRM_Sales_Order_Items__c();
        item.EUR_CRM_Sales_Order__c = salesOrderRec.Id;
        item.EUR_CRM_PriceBookEntryID__c = productCatalogItem.Id;
        item.EUR_CRM_Quantity__c = 2;
        item.EUR_CRM_Unit_Type__c = 'Case';
        item.EUR_CRM_ItemCategory__c = 'Chargable';
        item.EUR_CRM_ERP_Id__c = 'ERP1';
        insert item;
        return item;
    }
    
    /** Method to create Objective Promotions Order Items*/
    public static EUR_CRM_Objectives_Promotions__c createObjectivePromotions(Id accountTargetGroupId)
    {
        EUR_CRM_Objectives_Promotions__c promo = new EUR_CRM_Objectives_Promotions__c();
        promo.EUR_CRM_Status__c = 'Active';
        promo.EUR_CRM_Type__c = 'Objective';
        promo.EUR_CRM_Account_Target_Group__c = accountTargetGroupId;
        promo.EUR_CRM_Active_Start_Date__c = system.today();
        promo.EUR_CRM_Active_End_Date__c = Date.today().addDays(10);
        insert promo;
        return promo;
    }
    
    public static EUR_CRM_Account_in_Promo__c createAccountinPromo(Id accountId, Id promoId)
    {
        EUR_CRM_Account_in_Promo__c accPromo = new EUR_CRM_Account_in_Promo__c();
        accPromo.EUR_CRM_Account__c = accountId;
        accPromo.EUR_CRM_Objectives_Promotions__c = promoId;
        insert accPromo;
        return accPromo;
    }

    public static EUR_CRM_Account_Target_Group__c createAccountTargetGroup()
    {
        EUR_CRM_Account_Target_Group__c accTG = new EUR_CRM_Account_Target_Group__c();
        accTG.Name = 'IDL Direct Business';
        insert accTG;
        return accTG;
    }

    public static EUR_CRM_Account_in_Target_Group__c createAccountinTargetGroup(Id accountId, Id accountTargetGroupId)
    {
        EUR_CRM_Account_in_Target_Group__c accTG = new EUR_CRM_Account_in_Target_Group__c();
        accTG.EUR_CRM_Account__c = accountId;
        accTG.EUR_CRM_Account_Target_Group__c = accountTargetGroupId;
        insert accTG;
        return accTG;
    }
    
    public static EUR_CRM_Deal__c createDeal(String dealLogic, Boolean isMultiply, Id objectivesPromotionsId)
    {
        EUR_CRM_Deal__c newDeal = new EUR_CRM_Deal__c();
        newDeal.EUR_CRM_Deal_logic__c = dealLogic;
        newDeal.EUR_CRM_Objectives_Promotions__c = objectivesPromotionsId;
        newDeal.EUR_CRM_Multiply__c = isMultiply;
        newDeal.recordTypeId = EUR_COMMON_Utils.recordTypes.get('EUR_CRM_Deal__c:EUR_Free');
        insert newDeal;
        return newDeal;
    }
    
    public static EUR_CRM_Product_in_Deal__c createProductInDeal(Id dealId, Id skuId)
    {
        EUR_CRM_Product_in_Deal__c productInDeal = new EUR_CRM_Product_in_Deal__c();
        productInDeal.EUR_CRM_Quantity__c = 200;
        productInDeal.EUR_CRM_AnimationID__c = dealId;
        productInDeal.EUR_CRM_SKU__c = skuId;
        insert productInDeal;
        return productInDeal;
    }
    
    public static EUR_CRM_ProductCatalogItemGrouping__c createProductCatalogItemGrouping(Id dealId, Id skuId)
    {
        EUR_CRM_ProductCatalogItemGrouping__c productCatalogItemGrouping = new EUR_CRM_ProductCatalogItemGrouping__c();
        productCatalogItemGrouping.EUR_CRM_AnimationID__c = dealId;
        productCatalogItemGrouping.EUR_CRM_SKU__c = skuId;
        productCatalogItemGrouping.EUR_CRM_Quantity__c = 5;
        insert productCatalogItemGrouping;
        return productCatalogItemGrouping;
    }
}