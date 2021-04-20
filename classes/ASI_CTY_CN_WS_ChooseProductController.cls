/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_WS_ChooseProductController       
 * Test Class:  ASI_CTY_CN_WS_ChooseProductCtrlTest
 * Description: Wholesaler Community Choose Product Page Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-11-11       Sera                    Create AuraEnabled functions
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_WS_ChooseProductController {

    private static final String RTID_SORITEM = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item');
    /*
    * Method Name: getFilterItems
    * Description: Obtain the filter items from Custom Category Brand object.
    * Return Type: List<ASI_CTY_CN_WS_Custom_Category_Brand__c>
    * Parameter  : 
    */
    @AuraEnabled()
    public static List<ASI_CTY_CN_WS_Custom_Category_Brand__c> getFilterItems () {
        List <ASI_CTY_CN_WS_Custom_Category_Brand__c> filterItems = [SELECT Id,
                                                                            Name,
                                                                            ASI_CTY_CN_WS_Sequence__c,
                                                                            ASI_CTY_CN_WS_Type__c,
                                                                            ASI_CTY_CN_WS_Parent__c,
                                                                            ASI_CTY_CN_WS_Bottle_Size__c,
                                                                            ASI_CTY_CN_WS_Level__c,
                                                                            RecordType.DeveloperName,
                                                                            (SELECT Id,
                                                                            Name,
                                                                            ASI_CTY_CN_WS_Sequence__c,
                                                                            ASI_CTY_CN_WS_Type__c,
                                                                            ASI_CTY_CN_WS_Parent__c,
                                                                            ASI_CTY_CN_WS_Bottle_Size__c,
                                                                            ASI_CTY_CN_WS_Level__c,
                                                                            RecordType.DeveloperName FROM Brands__r
                                                                            ORDER BY ASI_CTY_CN_WS_Sequence__c)
                                                                        FROM ASI_CTY_CN_WS_Custom_Category_Brand__c
                                                                        WHERE ASI_CTY_CN_WS_Type__c = :ASI_CTY_CN_WS_Utils.TYPE_PREMIUMWS
                                                                        AND (RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_CATEGORYFILTER
                                                                        OR RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_BOTTLESIZEFILTER)
                                                                        ORDER BY ASI_CTY_CN_WS_Sequence__c];
        if (filterItems.size() > 0){
            return filterItems;
        }
        return null;

    }
    /*
    * Method Name: getBrandRels
    * Description: Obtain the relationship between Custom Category Brand with Item Group.
    * Return Type: Map<String, List<ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c>>
    * Parameter  : 
    */
    @AuraEnabled()
    public static Map<String, List<ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c>> getBrandRels(){
        List<ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c>  customCategoryBrandRelList = [SELECT ASI_CTY_CN_WS_Brand__c,
                                                                                            ASI_CTY_CN_WS_Sub_brand__c,
                                                                                            ASI_CTY_CN_WS_Custom_Category_Brand__c,
                                                                                            ASI_CTY_CN_WS_Custom_Category_Brand__r.ASI_CTY_CN_WS_Type__c,
                                                                                            ASI_CTY_CN_WS_Custom_Category_Brand__r.RecordType.DeveloperName
                                                                                        FROM ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c
                                                                                        WHERE ASI_CTY_CN_WS_Custom_Category_Brand__r.ASI_CTY_CN_WS_Type__c = :ASI_CTY_CN_WS_Utils.TYPE_PREMIUMWS
                                                                                        AND ASI_CTY_CN_WS_Custom_Category_Brand__r.RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_BRANDFILTER
                                                                                        AND RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_CATEGORYBRANDRELATIONSHIP];
        Map<String, List<ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c>> relListMap = new Map<String, List<ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c>>();
        if (customCategoryBrandRelList.size() > 0){
            for (ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c rel : customCategoryBrandRelList){
                if (!relListMap.containsKey(rel.ASI_CTY_CN_WS_Custom_Category_Brand__c)){
                    relListMap.put(rel.ASI_CTY_CN_WS_Custom_Category_Brand__c, new List<ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c>());
                }
                relListMap.get(rel.ASI_CTY_CN_WS_Custom_Category_Brand__c).add(rel);
            }
        }
        return relListMap;
    }
    /*
    * Method Name: fetchProducts
    * Description: Obtain Item Groups for which the current user has permissions.
    * Return Type: List<ItemGroupWrap>
    * Parameter  : 
    */
    @AuraEnabled()
    public static List<ItemGroupWrap> fetchProducts() {

        // Obtain the corresponding Account Id of current User.
        Id accountId = ASI_CTY_CN_WS_Utils.getAccountId();
        // System.debug('accountId : ' + accountId);

        if (String.isNotBlank(accountId)){

            List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Id, ASI_CRM_CN_Commercial_Team__c 
                                                                    FROM ASI_CRM_AccountsAdditionalField__c 
                                                                    WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_CUSTOMERCNWS
                                                                    AND ASI_CRM_Account__c = :accountId LIMIT 1];
            if(customers.size() > 0){

                ASI_CRM_AccountsAdditionalField__c customer = customers[0];

                // Obtain the corresponding Order Form Id Set of the Customer.
                Set<Id> orderFormIds = new Set<Id>();

                List<ASI_CRM_Order_Form_Customer_Relationship__c> ofCustomers = new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
                
                if(customer.ASI_CRM_CN_Commercial_Team__c == ASI_CTY_CN_WS_Utils.TYPE_PREMIUM){
                    ofCustomers = [SELECT ASI_CRM_Order_Form_Type__c,
                                        ASI_CRM_Customer__r.ASI_CRM_Account__c,
                                        ASI_CRM_Order_Form__c,
                                        RecordType.DeveloperName
                                    FROM ASI_CRM_Order_Form_Customer_Relationship__c 
                                    WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_ORDERFORMCUSTOMERRELATIONSHIP
                                    AND ASI_CRM_Order_Form_Type__c = :ASI_CTY_CN_WS_Utils.TYPE_PREMIUM
                                    AND ASI_CRM_Customer__r.ASI_CRM_Account__c = :accountId];
                }else if(customer.ASI_CRM_CN_Commercial_Team__c == ASI_CTY_CN_WS_Utils.TYPE_PRESTIGE){
                    ofCustomers = [SELECT ASI_CRM_Order_Form_Type__c,
                                        ASI_CRM_Customer__r.ASI_CRM_Account__c,
                                        ASI_CRM_Order_Form__c,
                                        RecordType.DeveloperName
                                    FROM ASI_CRM_Order_Form_Customer_Relationship__c 
                                    WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_ORDERFORMCUSTOMERRELATIONSHIP
                                    AND ASI_CRM_Order_Form_Type__c = :ASI_CTY_CN_WS_Utils.TYPE_NORMALITEM
                                    AND ASI_CRM_Customer__r.ASI_CRM_Account__c = :accountId];
                }
                
                if (ofCustomers.size() > 0){
                    for (ASI_CRM_Order_Form_Customer_Relationship__c ofCustomer : ofCustomers){
                        orderFormIds.add(ofCustomer.ASI_CRM_Order_Form__c);
                    }
                }

                // Obtain the corresponding Item Group Id Sets of Order Forms.
                Set<Id> itemGroupIds = new Set<Id>();
                if (orderFormIds.size() > 0){
                    List<ASI_CRM_Order_Form_Detail__c> orderFormDetails  = [SELECT Id, 
                                                                                ASI_CRM_Order_Form__c, 
                                                                                ASI_CRM_Product_Name__c,
                                                                                RecordType.DeveloperName
                                                                            FROM ASI_CRM_Order_Form_Detail__c 
                                                                            WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_ORDERFORMDETAIL
                                                                            AND ASI_CRM_Order_Form__c IN :orderFormIds];
                    if (orderFormDetails.size() > 0){
                        for (ASI_CRM_Order_Form_Detail__c orderFormD : orderFormDetails){
                            itemGroupIds.add(orderFormD.ASI_CRM_Product_Name__c);
                        }
                    }
                }
                String customerId = customer.Id;
                Map<Id, Decimal> priceMap = new Map<Id, Decimal>();
                if (String.isNotBlank(customerId) && itemGroupIds.size() > 0){
                    priceMap = ASI_CTY_CN_WS_Utils.getItemGroupUnitPriceWithVat(customerId, itemGroupIds);
                }
                // Query Item Group Details
                List <ASI_MFM_Item_Group__c> productList = [SELECT Id, 
                                                                Name,
                                                                ASI_CRM_CN_Chinese_Name__c,
                                                                ASI_CRM_CN_Eng_Name__c,
                                                                ASI_CRM_CN_Pack_Value__c,
                                                                ASI_CRM_CN_pack__c,
                                                                ASI_MFM_Sub_brand__c,
                                                                ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c,
                                                                ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                                                ASI_CRM_CN_BT_Size_C__c,
                                                                ASI_CTY_CN_WS_Is_Hot__c,
                                                                ASI_CTY_CN_WS_Is_HighLevel__c,
                                                                ASI_CTY_CN_WS_Is_New__c,
                                                                ASI_CTY_CN_WS_Sequence__c,
                                                                ASI_MFM_Item_Group_Code__c,
                                                                ASI_CTY_CN_WS_Is_Especial_For_WS__c,
                                                                (SELECT Id, 
                                                                    ASI_CTY_CN_WS_Premium_Display_Seq__c,
                                                                    ASI_MFM_Image_URL_720_480__c
                                                                FROM Product_Warehouse_Photos__r
                                                                WHERE ASI_CTY_CN_WS_Premium_Display_Seq__c = '1')
                                                            FROM ASI_MFM_Item_Group__c
                                                            WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_ITEMGROUP 
                                                            AND Id IN: itemGroupIds
                                                            ORDER BY ASI_CTY_CN_WS_Sequence__c ASC NULLS LAST];
                List<ItemGroupWrap> itemGroupList = new List<ItemGroupWrap>();
                if (productList.size() > 0){
                    for (ASI_MFM_Item_Group__c product : productList){
                        if (priceMap.containsKey(product.Id) 
                            && priceMap.get(product.Id) != null
                            && priceMap.get(product.Id) != 0){
                            // System.debug(LoggingLevel.INFO, '*** priceMap.get(product.Id): ' + priceMap.get(product.Id));
                            ItemGroupWrap itemGroupWrap = new ItemGroupWrap();
                            itemGroupWrap.itemGroup = product;
                            itemGroupWrap.originalPriceBTWithVAT = priceMap.get(product.Id);
                            itemGroupList.add(itemGroupWrap);
                        }
                        
                    }
                    // System.debug(LoggingLevel.INFO, '*** itemGroupList: ' + itemGroupList);
                    return itemGroupList;
                }
                

            }
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