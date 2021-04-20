public without sharing class ASI_CTY_CN_WS_ShoppingCartController {
    private static final String ALLOCATION_RTY = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation');
    
    @AuraEnabled
    public static SalesOrder getSalesOrder(String sorId) {
        List <User> users = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        List<Contact> contactList = [SELECT Name, Phone, Account.Name, AccountId
                                     FROM Contact 
                                     WHERE Id = :users[0].ContactId];
        System.debug(LoggingLevel.INFO, '*** contactList: ' + contactList);
        if (contactList.isEmpty()) return null;
        List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Name, ASI_CRM_Account__c, ASI_CRM_CN_Address__c, ASI_CRM_CN_Region__c, ASI_CRM_CN_NewChannel__c
                                                                  FROM ASI_CRM_AccountsAdditionalField__c
                                                                  WHERE ASI_CRM_Account__c = :contactList[0].AccountId];

        System.debug(LoggingLevel.INFO, '*** customers: ' + customers);
        if (customers.isEmpty()) return null;

        List<ASI_KOR_Sales_Order_Request__c> sorlist = [SELECT Name, ASI_CRM_CN_Address__c, ASI_CRM_CN_Contact_Person__c,OwnerId,
                                                            ASI_CRM_CN_Order_Number__c, ASI_CRM_CN_Tel_Mobile__c, ASI_CTY_CN_WS_Status__c,
                                                             ASI_CRM_CN_Total_Qty__c, ASI_CRM_CN_Other_Requirement__c,ASI_CRM_SG_Order_Date__c,
                                                            ASI_CRM_CN_Customer__r.Name, ASI_KOR_Order_Status__c,ASI_KOR_Sales_Amount__c
                                                    FROM ASI_KOR_Sales_Order_Request__c
                                                    WHERE Id = :sorId];
        System.debug(LoggingLevel.INFO, '*** sorlist: ' + sorlist);

        List<ASI_KOR_Sales_Order_Transaction__c> orderItems = [SELECT Id,ASI_CRM_CN_Sales_Oder_TOV__c,
                                                                    ASI_CRM_CN_Sales_Oder_TOV__r.ASI_CRM_SO_Number__c,
                                                                    ASI_CRM_CN_Product_Name__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CTY_CN_WS_Mini_Order_Qty__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c,
                                                                    ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Discount__c,
                                                                    ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Buy_X__c,
                                                                    ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Get_Y__c,
                                                                    ASI_CRM_CN_Promotion_Code__r.Name,
                                                                    ASI_CTY_CN_WS_Item_Final_Amount_With_VAT__c,
                                                                    ASI_CTY_CN_WS_Promotion_Rate__c,
                                                                    ASI_CTY_CN_WS_Disount_Rate__c,
                                                                    ASI_KOR_Order_Qty__c,
                                                                    ASI_CTY_CN_WS_Free_Qty_Value__c,
                                                                    ASI_CRM_Order_Qty_Bottle__c,
                                                                    ASI_CRM_CN_Qty_9L__c,
                                                                    ASI_CRM_CN_UOM__c,
                                                                    ASI_CTY_CN_WS_Promotion_Amount_BT__c,
                                                                    ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c,
                                                                    ASI_CTY_CN_WS_Order_Qty_CA__c,
                                                                    ASI_CRM_CN_Promotion_Code__c,
                                                                    ASI_CRM_CN_Free_Qty_BT__c,
                                                                    ASI_CTY_CN_WS_Actual_Unit_Price__c,
                                                                    ASI_CRM_CN_Released_Qty__c,
                                                                    ASI_CRM_CN_Unit_Price_BT_with_VAT__c,
                                                                    ASI_CRM_MOT_Promotion_Price_non_VAT__c,
                                                                    ASI_CRM_MOT_Price_non_VAT__c,
                                                                    ASI_CRM_CN_Logistics_Remark__c
                                                                FROM ASI_KOR_Sales_Order_Transaction__c
                                                                WHERE ASI_KOR_Sales_Order_Request__c =: sorId];
        // System.debug(LoggingLevel.INFO, '*** orderItems: ' + orderItems);
        Set<Id> itemGroupIds = new Set<Id>();
        for (ASI_KOR_Sales_Order_Transaction__c sorItem : orderItems) {
            itemGroupIds.add(sorItem.ASI_CRM_CN_Product_Name__c);
        }
        // Map<Id,ASI_CTY_CN_WS_Utils.WSPriceWrap> priceMap = ASI_CTY_CN_WS_Utils.calculateWSPriceInfo(customers[0].Id,itemGroupIds);
        // Query the allocation records
        List<ASI_CRM_Item_Group_Allocation__c> itemGroupAllocations = [SELECT ASI_CRM_Item_Group__c, ASI_CRM_MTD_Order_Quantity__c, 
                                                                                ASI_CRM_Commercial_Team__c, ASI_CRM_Inactive__c, 
                                                                                ASI_CRM_UOM__c, ASI_CRM_Allocation_Quantity__c, 
                                                                                ASI_CRM_Allocation_Quantity_Bottle__c, ASI_CRM_Region__c, 
                                                                                ASI_CRM_Effective_Date__c, ASI_CRM_MTD_Order_Quantity_CA__c, 
                                                                                ASI_CRM_Remaining_Qty_BT__c, ASI_CRM_Remaining_Qty_CA__c, 
                                                                                ASI_CRM_Customer__c, ASI_CRM_Channel__c,ASI_CRM_Region__r.Name
                                                                        FROM ASI_CRM_Item_Group_Allocation__c
                                                                        WHERE (ASI_CRM_Customer__c = :customers[0].Id 
                                                                               OR ASI_CRM_Channel__c = :customers[0].ASI_CRM_CN_NewChannel__c
                                                                               OR ASI_CRM_Region__r.Name = :customers[0].ASI_CRM_CN_Region__c)
                                                                        AND ASI_CRM_Item_Group__c IN :itemGroupIds
                                                                        AND ASI_CRM_Commercial_Team__c = :ASI_CTY_CN_WS_Utils.TYPE_PREMIUM
                                                                        AND ASI_CRM_Effective_Date__c <= :System.today()
                                                                        AND RecordTypeId = :ALLOCATION_RTY
                                                                        AND ASI_CRM_Inactive__c = false];
        Map<Id, ASI_CRM_Item_Group_Allocation__c> itemGroupAllocationMap = new Map<Id, ASI_CRM_Item_Group_Allocation__c>();
        for (ASI_CRM_Item_Group_Allocation__c allocation : itemGroupAllocations) {
            
            if (allocation.ASI_CRM_Customer__c != null && allocation.ASI_CRM_Customer__c == customers[0].Id) {
                itemGroupAllocationMap.put(allocation.ASI_CRM_Item_Group__c, allocation);
            } else if (allocation.ASI_CRM_Channel__c != null 
                        && allocation.ASI_CRM_Channel__c == customers[0].ASI_CRM_CN_NewChannel__c
                        && allocation.ASI_CRM_Customer__c == null) {
                itemGroupAllocationMap.put(allocation.ASI_CRM_Item_Group__c, allocation);
            } else if (allocation.ASI_CRM_Region__r != null
                        && allocation.ASI_CRM_Region__r.Name == customers[0].ASI_CRM_CN_Region__c
                        && allocation.ASI_CRM_Customer__c == null
                        && allocation.ASI_CRM_Channel__c == null) {
                itemGroupAllocationMap.put(allocation.ASI_CRM_Item_Group__c, allocation);
            }
        }

        SalesOrder order = new SalesOrder();
        order.sor = sorlist.isEmpty() ? null : sorlist[0];
        List<SalesOrderItem> sorItemList = new List<SalesOrderItem>();
        for (ASI_KOR_Sales_Order_Transaction__c sorItem : orderItems) {
            SalesOrderItem newSorItem = new SalesOrderItem();
            newSorItem.itemId = sorItem.Id;
            newSorItem.productId = sorItem.ASI_CRM_CN_Product_Name__c;
            newSorItem.showMessage = false;
            newSorItem.cnName = sorItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c;
            newSorItem.enName = sorItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c;
            newSorItem.pack = sorItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c;
            newSorItem.packValue = sorItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c;
            newSorItem.unitPrice = sorItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c == null ? 0 : sorItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c.setScale(2);
            newSorItem.originPrice = sorItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c == null ? 0 : sorItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c;
            newSorItem.promotionDiscount = sorItem.ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Discount__c;
            newSorItem.buyx = sorItem.ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Buy_X__c;
            newSorItem.gety = sorItem.ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Get_Y__c;

            // mdy by Bls(wzq) Increase the number of minimum order boxes begin
            newSorItem.miniOrderQty  = sorItem.ASI_CRM_CN_Product_Name__r.ASI_CTY_CN_WS_Mini_Order_Qty__c;
            // mdy by Bls(wzq) Increase the number of minimum order boxes end
            
            newSorItem.promotionAmount = sorItem.ASI_CTY_CN_WS_Promotion_Amount_BT__c == null ? 0 : sorItem.ASI_CTY_CN_WS_Promotion_Amount_BT__c.setScale(2);
           
            newSorItem.discount = sorItem.ASI_CTY_CN_WS_Disount_Rate__c == null ? 0 : sorItem.ASI_CTY_CN_WS_Disount_Rate__c;
           
            newSorItem.actualPrice = sorItem.ASI_CTY_CN_WS_Actual_Unit_Price__c == null ? 0 :sorItem.ASI_CTY_CN_WS_Actual_Unit_Price__c.setScale(2);
            
            newSorItem.caseQty = sorItem.ASI_CTY_CN_WS_Order_Qty_CA__c;
            newSorItem.bottleQty = sorItem.ASI_CRM_Order_Qty_Bottle__c;
            newSorItem.freeQty = sorItem.ASI_CTY_CN_WS_Free_Qty_Value__c;
            newSorItem.maxBottleQty = itemGroupAllocationMap.get(sorItem.ASI_CRM_CN_Product_Name__c) == null 
                                      ? 999999 : itemGroupAllocationMap.get(sorItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Remaining_Qty_BT__c;
            newSorItem.originAmount = sorItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c == null ? 0 : (newSorItem.bottleQty * sorItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c).setScale(4);
            newSorItem.disAmount = sorItem.ASI_CTY_CN_WS_Item_Final_Amount_With_VAT__c == null ? 0 :sorItem.ASI_CTY_CN_WS_Item_Final_Amount_With_VAT__c.setScale(2);
            newSorItem.originDisAmount = sorItem.ASI_CTY_CN_WS_Item_Final_Amount_With_VAT__c;
            sorItemList.add(newSorItem);
        }
        order.orderItems = sorItemList;
        // System.debug(LoggingLevel.INFO, '*** order: ' + order);
        return order;
    }
    
    @AuraEnabled
    public static String deleteOrderItem(String sorItemId) {
        List<ASI_KOR_Sales_Order_Transaction__c> orderItems = [SELECT Id
                                                                FROM ASI_KOR_Sales_Order_Transaction__c 
                                                                WHERE Id =: sorItemId];
        delete orderItems;
        return sorItemId;
    }

    @AuraEnabled
    public static void saveOrder(String orderJson) {
        SalesOrder order = (SalesOrder)JSON.deserialize(orderJson, SalesOrder.class);
        ASI_KOR_Sales_Order_Request__c sor = order.sor;
        setSalesReps(sor);
        sor.ASI_CRM_SG_Order_Date__c = System.today();
        // For invoke Process Builder to set up approval of cn premium wholesaler
        sor.ASI_KOR_Order_Status__c = 'WS_Approval';
        sor.OwnerID = UserInfo.getUserId();
        
        List<ASI_KOR_Sales_Order_Transaction__c> upSorItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();
        for (SalesOrderItem sorItem : order.orderItems) {
            ASI_KOR_Sales_Order_Transaction__c upSorItem = new ASI_KOR_Sales_Order_Transaction__c(Id = sorItem.itemId);
            upSorItem.ASI_KOR_Order_Qty__c = sorItem.caseQty;
            upSorItem.ASI_CRM_UOM_Text__c = 'CA';
            upSorItemList.add(upSorItem);
        }
        update upSorItemList;
        
        update sor;
    }

    public static void setSalesReps(ASI_KOR_Sales_Order_Request__c sor){
        List<ASI_CRM_Sales_Team__c> salesTeams = [SELECT ASI_CTY_CN_WS_Sales_Rep__c 
                                                     FROM ASI_CRM_Sales_Team__c 
                                                    WHERE ASI_CTY_CN_Wholesaler__c = :sor.ASI_CRM_CN_Customer__c
                                                    AND ASI_CTY_CN_Is_Sales_Group_Head__c = false];
        if (salesTeams.size() > 0 && salesTeams.get(0) != null && salesTeams.get(0).ASI_CTY_CN_WS_Sales_Rep__c != null) {
            sor.ASI_CTY_CN_WS_Sales_Rep1__c = salesTeams.get(0).ASI_CTY_CN_WS_Sales_Rep__c;
        }
        if (salesTeams.size() > 1 && salesTeams.get(1) != null && salesTeams.get(1).ASI_CTY_CN_WS_Sales_Rep__c != null) {
            sor.ASI_CTY_CN_WS_Sales_Rep2__c = salesTeams.get(1).ASI_CTY_CN_WS_Sales_Rep__c;
        }
        if (salesTeams.size() > 2 && salesTeams.get(2) != null && salesTeams.get(2).ASI_CTY_CN_WS_Sales_Rep__c != null) {
            sor.ASI_CTY_CN_WS_Sales_Rep3__c = salesTeams.get(2).ASI_CTY_CN_WS_Sales_Rep__c;
        }

         // add by BLS(wzq) 20210107 When placing an order, it is written from the sales team data is sales leader under WS begin
        List<ASI_CRM_Sales_Team__c> salesLeadTeams = [SELECT ASI_CTY_CN_WS_Sales_Rep__c
                                                     FROM ASI_CRM_Sales_Team__c 
                                                    WHERE ASI_CTY_CN_Wholesaler__c = :sor.ASI_CRM_CN_Customer__c 
                                                    AND ASI_CTY_CN_Is_Sales_Group_Head__c = true];
        if(salesLeadTeams.size()> 0 && salesLeadTeams.get(0) != null && salesLeadTeams.get(0).ASI_CTY_CN_WS_Sales_Rep__c != null)
        {
           sor.ASI_CTY_CN_Sales_Leader__c = salesLeadTeams.get(0).ASI_CTY_CN_WS_Sales_Rep__c;
        }
        // add by BLS(wzq) 20210107 When placing an order, it is written from the sales team data is sales leader under WS end
    }


    public class SalesOrderItem {
        @AuraEnabled
        public String itemId {get; set;}
        @AuraEnabled
        public String productId {get; set;}
        @AuraEnabled
        public Boolean showMessage {get; set;}
        @AuraEnabled
        public String cnName {get; set;}
        @AuraEnabled
        public String enName {get; set;}
        @AuraEnabled
        public String pack {get; set;}
        @AuraEnabled
        public Decimal packValue {get; set;}
         @AuraEnabled
        public Decimal originPrice {get; set;}
        @AuraEnabled
        public Decimal unitPrice {get; set;}
        @AuraEnabled
        public Decimal actualPrice {get; set;}
        @AuraEnabled
        public Decimal promotionDiscount {get; set;}
        @AuraEnabled
        public Decimal buyx {get; set;}
        @AuraEnabled
        public Decimal gety {get; set;}
        @AuraEnabled
        public Decimal promotionAmount {get; set;}
        @AuraEnabled
        public Decimal discount {get; set;}
        @AuraEnabled
        public Decimal caseQty {get; set;}
        @AuraEnabled
        public Decimal bottleQty {get; set;}
        @AuraEnabled
        public Decimal freeQty {get; set;}
        @AuraEnabled
        public Decimal maxBottleQty {get; set;}
        @AuraEnabled
        public Decimal originAmount {get; set;}
        @AuraEnabled
        public Decimal disAmount {get; set;}
        @AuraEnabled
        public Decimal originDisAmount {get; set;} 
        @AuraEnabled
        public Decimal miniOrderQty {get; set;}    
         
    }

    public class SalesOrder {
        @AuraEnabled
        public ASI_KOR_Sales_Order_Request__c sor {get; set;}
        @AuraEnabled
        public List<SalesOrderItem> orderItems {get; set;}

    }  

    
                         
}