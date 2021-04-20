/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_WS_ProductDetailController       
 * Test Class:  ASI_CTY_CN_WS_ProductDetailCtrlTest
 * Description: Wholesaler Community Product Detail Page Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-11-11       Sera                    Create AuraEnabled functions
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_WS_ProductDetailController {
    
    private static final String RTID_SORITEM = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item');
    
    /*
    * Method Name: getProduct
    * Description: Obtain corresponding attributes of the ItemGroup.
    * Return Type: ItemGroupWrap
    * Parameter  : String(ItemGroup Id)
    */
    @AuraEnabled
    public static ItemGroupWrap getProduct (String itemGroupId) {
        System.debug(LoggingLevel.INFO, '***itemGroupId: ' + itemGroupId);
        if (String.isNotBlank(itemGroupId)){
            List<ASI_MFM_Item_Group__c> itemGroups = [SELECT Id, 
                    										Name,
                    										ASI_CRM_CN_Chinese_Name__c,
                    										ASI_CRM_CN_Eng_Name__c,
                    										ASI_CRM_CN_Pack_Value__c,
                                                            ASI_CRM_CN_pack__c,
                                                            ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                                            ASI_CRM_CN_BT_Size_C__c,
                                                            ASI_CTY_CN_WS_Description__c,
                                                            ASI_MFM_Item_Group_Code__c,
                                                            ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                                                            ASI_MFM_Sub_brand__r.ASI_CRM_CN_CHI_NAME_C__c,
                                                            ASI_CTY_CN_WS_Drinking_Guidelines__c,
                                                            (SELECT Id, 
                                                                ASI_CTY_CN_WS_Premium_Display_Seq__c,
                                                                ASI_MFM_Image_URL_720_480__c
                                                                FROM Product_Warehouse_Photos__r
                                                                WHERE ASI_CTY_CN_WS_Premium_Display_Seq__c != null
                                                                ORDER BY ASI_CTY_CN_WS_Premium_Display_Seq__c LIMIT 5),
                    										(SELECT Id,
                    											ASI_CRM_Alcohol_Degree__c,
                    											ASI_CRM_SKU_Status__c,
                    											ASI_CRM_Country_Of_Origin__c,
                                                                ASI_CRM_Bottle_Barcode__c,
                                                                ASI_CRM_Case_Barcode__c,
                                                                ASI_CRM_Case_Size_LengthWidthHeight_cm3__c,
                                                                ASI_CRM_Case_Weight_Kg__c
                    											FROM SKUs__r
                    											WHERE ASI_CRM_Information_Status__c = :ASI_CTY_CN_WS_Utils.INFOSTATUS_SKUCOMPLETED)
                                                    FROM ASI_MFM_Item_Group__c
                                                    WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_ITEMGROUP
                                                    AND Id = :itemGroupId];
            ItemGroupWrap itemGroupWrap = new ItemGroupWrap();
            
            itemGroupWrap.itemGroup = itemGroups.size() > 0 ? itemGroups[0] : null;
            
            // obtain the corresponding price of this ItemGroup for current User.
            Set<Id> itemGroupIds = new Set<Id>{itemGroupId};
            
            Id accountId = ASI_CTY_CN_WS_Utils.getAccountId();
            // System.debug('accountId: ' + accountId);

            Id customerId;
            
            if (String.isNotBlank(accountId)){
                List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Id, ASI_CRM_CN_Commercial_Team__c, RecordType.DeveloperName 
                                                                        FROM ASI_CRM_AccountsAdditionalField__c 
                                                                        WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_CUSTOMERCNWS
                                                                        AND ASI_CRM_Account__c = :accountId LIMIT 1];
                customerId = customers.size() > 0 ? customers[0].Id : null;
            }
            if (String.isNotBlank(customerId) && itemGroupIds.size() > 0){
                Map<Id, Decimal> priceMap = ASI_CTY_CN_WS_Utils.getItemGroupUnitPriceWithVat(customerId, itemGroupIds);
                // System.debug(LoggingLevel.INFO, '*** priceMap: ' + priceMap);
                itemGroupWrap.originalPriceBTWithVAT = priceMap.containsKey(itemGroupId) ? priceMap.get(itemGroupId) : null;
            }
            // System.debug(LoggingLevel.INFO, '*** itemGroupWrap: ' + itemGroupWrap);
            return itemGroupWrap;
        }
        return null;
    }
    /*
    * Method Name: generateSORItem
    * Description: generate SOR Item according to orderId,productId and caNumber.
    * Return Type: void
    * Parameter  : String orderId, String productId, Integer caNumber
    */
    @AuraEnabled()
    public static void generateSORItem(String orderId, String productId, Integer caNumber){
        List<ASI_KOR_Sales_Order_Transaction__c> sorExistItems = [SELECT Id 
                                                                    FROM ASI_KOR_Sales_Order_Transaction__c 
                                                                    WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_SORITEMCN
                                                                    AND ASI_KOR_Sales_Order_Request__c = :orderId
                                                                    AND ASI_KOR_Sales_Order_Request__r.ASI_KOR_Order_Status__c = :ASI_CTY_CN_WS_Utils.STATUS_SOROPEN
                                                                    AND ASI_CRM_CN_Product_Name__c = :productId
                                                                    LIMIT 1];
        if(sorExistItems.size() > 0){
            ASI_KOR_Sales_Order_Transaction__c sorItem = new ASI_KOR_Sales_Order_Transaction__c();
            sorItem.Id = sorExistItems[0].Id;
            sorItem.ASI_KOR_Order_Qty__c = caNumber;
            sorItem.ASI_CRM_UOM_Text__c = ASI_CTY_CN_WS_Utils.UOM_SORITEMCN;
            update sorItem;
        }else{
            ASI_KOR_Sales_Order_Transaction__c sorItem = new ASI_KOR_Sales_Order_Transaction__c();
            sorItem.RecordTypeId = RTID_SORITEM;
            sorItem.ASI_KOR_Sales_Order_Request__c = orderId;
            sorItem.ASI_CRM_CN_Product_Name__c = productId;
            sorItem.ASI_KOR_Order_Qty__c = caNumber;
            sorItem.ASI_CRM_UOM_Text__c = ASI_CTY_CN_WS_Utils.UOM_SORITEMCN;
            insert sorItem;
        }
    }
    
    public class ItemGroupWrap{
        @AuraEnabled
        public ASI_MFM_Item_Group__c itemGroup;
        @AuraEnabled
        public Decimal originalPriceBTWithVAT;
    }
}