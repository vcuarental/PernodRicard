global without sharing class ASI_CTY_CN_WS_UploadCSV {

    private static final String ITEM_GROUP = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group');
    private static final String SOT_RECORDTYPE = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item');
    public String errorHeader {get; set;}
    public static List<ASI_CRM_CN_CustomSetting__c> uploadSetting;

    public ASI_CTY_CN_WS_UploadCSV() {
        uploadSetting = [SELECT ASI_CTY_CN_WS_Upload_SOR_Item_Header_Err__c
                         FROM ASI_CRM_CN_CustomSetting__c];
        if (!uploadSetting.isEmpty()) {
            errorHeader = uploadSetting[0].ASI_CTY_CN_WS_Upload_SOR_Item_Header_Err__c;
        }

    }
     
    public class InterimData{
        public ASI_CRM_Order_Form_Detail__c OFD {get; set;}
        public ASI_CRM_Item_Group_Customer_Price__c IGCP {get; set;}
        public ASI_KOR_Sales_Order_Transaction__c salesOrderRequestItem {get; set;}
    }

    public class ProductItem {
        public Integer index;       
        public Boolean show;    
        public List<String> errors;
        public String selected;
        public Boolean loading; 
        public String status;
        public String enName;
        public String cnName;
        public String bottlePerPack;
        public String bottleSize;
        public Decimal orderQty;
        public String uom;  
        public Decimal unitPricePerBottle;
        public String remark;
        public String salesOrderId;
        public String itemGroupId;
        public ProductItem orgData;
    }

    @RemoteAction
    global static void submitProducts(String orderId, String productsJson){
        System.debug(LoggingLevel.INFO, '*** productsJson: ' + productsJson);
        List<ProductItem> products = (List<ProductItem>)JSON.deserialize(productsJson, List<ProductItem>.class);

        Set<String> itemGroupIds = new Set<String>();
       
        for (ProductItem pro : products) {
            itemGroupIds.add(pro.itemGroupId);
        }
        Map<String, ASI_MFM_Item_Group__c> itemGroupMap = new Map<String, ASI_MFM_Item_Group__c>();
        List<ASI_MFM_Item_Group__c> itemGroupList = [SELECT Id, ASI_MFM_Item_Group_External_ID__c
                                                      FROM ASI_MFM_Item_Group__c
                                                      WHERE RecordTypeId = :ITEM_GROUP
                                                      AND ASI_MFM_Item_Group_External_ID__c IN :itemGroupIds];
                
        for (ASI_MFM_Item_Group__c itemGrp : itemGroupList) {
            itemGroupMap.put(itemGrp.ASI_MFM_Item_Group_External_ID__c, itemGrp);
        }
        System.debug(LoggingLevel.INFO, '*** itemGroupMap: ' + itemGroupMap);

        List<ASI_KOR_Sales_Order_Request__c> sorList = [SELECT Id, Name 
                                                        FROM ASI_KOR_Sales_Order_Request__c
                                                        WHERE Id = :orderId];

        // List<ASI_KOR_Sales_Order_Transaction__c> toInsertOrderItems = new List<ASI_KOR_Sales_Order_Transaction__c>();
        Map<String, ASI_KOR_Sales_Order_Transaction__c> toInsertOrderItemMap = new Map<String, ASI_KOR_Sales_Order_Transaction__c>();
        for (ProductItem pro : products) {
            if (toInsertOrderItemMap.containsKey(itemGroupMap.get(pro.itemGroupId).Id)) {
                ASI_KOR_Sales_Order_Transaction__c orderItem = toInsertOrderItemMap.get(itemGroupMap.get(pro.itemGroupId).Id);
                if (pro.orderQty > 0) {
                    orderItem.ASI_KOR_Order_Qty__c += pro.orderQty;
                }
            } else {
                 ASI_KOR_Sales_Order_Transaction__c orderItem = new ASI_KOR_Sales_Order_Transaction__c();
                orderItem.ASI_CRM_CN_Product_Name__c = itemGroupMap.get(pro.itemGroupId).Id;
                orderItem.ASI_KOR_Order_Qty__c = pro.orderQty;
                orderItem.ASI_CRM_UOM_Text__c = 'CA';
                orderItem.ASI_CRM_CN_Remark__c = pro.remark;
                orderItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c = pro.unitPricePerBottle;
                orderItem.ASI_KOR_Sales_Order_Request__c = sorList[0].Id;
                orderItem.RecordTypeId = SOT_RECORDTYPE;
                if (orderItem.ASI_KOR_Order_Qty__c > 0) {
                    toInsertOrderItemMap.put(orderItem.ASI_CRM_CN_Product_Name__c, orderItem);
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** toInsertOrderItemMap: ' + JSON.serialize(toInsertOrderItemMap));
        if (!toInsertOrderItemMap.isEmpty()) {
            Database.insert(toInsertOrderItemMap.values(), true);
        }

    }

    @RemoteAction
    global static Map<String, Object> checkUploadData(String customerId, String input){
        Map<String, object> inputMap = (Map<String, object>)JSON.deserializeUntyped(input);
        Map<String, object> result = new Map<String, object>();
        
        String itemGroupId = (String)inputMap.get('itemGroupId');
        for (ASI_CRM_Item_Group_Customer_Price__c igcp : [SELECT ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_External_ID__c
                                                           FROM ASI_CRM_Item_Group_Customer_Price__c 
                                                           WHERE ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_External_ID__c = :itemGroupId 
                                                           AND ASI_CRM_Customer__c = : customerId]) {
            result.put('itemGroupId', igcp.ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_External_ID__c);
        }
       
        return result;
    }


    @RemoteAction
    @AuraEnabled
    global static List<List<String>> getUploadTemplate() {
        Contact con = getContact();
        // Query the customer information 
        List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Name, ASI_CRM_Account__c, ASI_CRM_CN_Address__c,
                                                                        ASI_CRM_CN_Commercial_Team__c
                                                                  FROM ASI_CRM_AccountsAdditionalField__c
                                                                  WHERE ASI_CRM_Account__c = :con.AccountId];
        String customerId = '';
        String orderFormType = '';
        // the customer team is premium
        if (!customers.isEmpty()) {
            orderFormType = customers[0].ASI_CRM_CN_Commercial_Team__c == 'Premium' 
                                                                          ? 'Premium' 
                                                                          : 'Normal Item';
            customerId = customers[0].Id;
        }

        List<List<String>> uploadtemp = new List<List<String>>();
        uploadSetting = [SELECT ASI_CTY_CN_WS_Upload_SOR_Item_Header__c
                         FROM ASI_CRM_CN_CustomSetting__c];
        List<String> tempTitle = new List<String>();
        if (!uploadSetting.isEmpty()) {
            tempTitle = uploadSetting[0].ASI_CTY_CN_WS_Upload_SOR_Item_Header__c.split(',');
        }
        System.debug(LoggingLevel.INFO, '*** tempTitle: ' + tempTitle);
                                              
        uploadtemp.add(tempTitle);

        // Get latest tax rate
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = [SELECT Id,ASI_CRM_CN_Tax_Rate__c 
                                                            FROM ASI_CRM_CN_Tax_Rate_Config__c 
                                                            ORDER BY ASI_CRM_CN_Effective_From__c DESC];
        Decimal taxRate;
        if(!taxRateList.isEmpty()){
            taxRate = taxRateList[0].ASI_CRM_CN_Tax_Rate__c == null ? 0 : taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }
        
        // order form Ids
        Set<Id> orderFormIdSet = new Set<Id>();
        // item group Ids
        Set<Id> itemGroupIdSet= new Set<Id>();
        
        Map<String, InterimData> interimDataMap = new Map<String, InterimData>();
        
        // Query customer and order form junction object
        for(ASI_CRM_Order_Form_Customer_Relationship__c formCustomerRel:[SELECT Name, ASI_CRM_Order_Form__c 
                                                                        FROM ASI_CRM_Order_Form_Customer_Relationship__c 
                                                                        WHERE ASI_CRM_Customer__c = :customerId]){ 
            orderFormIdSet.add(formCustomerRel.ASI_CRM_Order_Form__c);
        }

        // Query order form detail
        List<ASI_CRM_Order_Form_Detail__c> formDetailList = [SELECT Name, ASI_CRM_Sequence__c,
                                                                    ASI_CRM_Product_Name__c,
                                                                    ASI_CRM_Product_Name__r.Name,
                                                                    ASI_CRM_Product_Name__r.ASI_CRM_CN_Eng_Name__c,
                                                                    ASI_CRM_Product_Name__r.ASI_CRM_CN_Chinese_Name__c,
                                                                    ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_External_ID__c,
                                                                    ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_Code__c,
                                                                    ASI_CRM_Remark__c ,
                                                                    ASI_CRM_Product_Name__r.ASI_CRM_CN_BT_Size_C__c,
                                                                    ASI_CRM_Product_Name__r.ASI_CRM_CN_Pack_Value__c
                                                            FROM ASI_CRM_Order_Form_Detail__c 
                                                            WHERE ASI_CRM_Order_Form__c IN :orderFormIdSet 
                                                            AND ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c = :orderFormType];
        if (!formDetailList.isEmpty()) {
            for(ASI_CRM_Order_Form_Detail__c OFD : formDetailList){
                InterimData temp = new InterimData();
                temp.OFD = OFD;
                interimDataMap.put(customerId + '-' + OFD.ASI_CRM_Product_Name__c, temp);
                itemGroupIdSet.add(OFD.ASI_CRM_Product_Name__c);
            }
        }
        
        // Query item group customer price
        for(ASI_CRM_Item_Group_Customer_Price__c igcp : [SELECT Name, ASI_CRM_Promotion_Expiration_Date__c, ASI_CRM_Customer__c,
                                                                    ASI_CRM_Promotion_Code__r.Name,ASI_CRM_Unit_Price_BT__c,
                                                                    ASI_CRM_Item_Group__r.Name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c,
                                                                    ASI_CRM_Item_Group__c 
                                                           FROM ASI_CRM_Item_Group_Customer_Price__c 
                                                           WHERE ASI_CRM_Item_Group__c IN :itemGroupIdSet 
                                                           AND ASI_CRM_Customer__c = : customerId]){  
            System.debug(LoggingLevel.INFO, '*** igcp: ' + igcp);
            ASI_CRM_Item_Group_Customer_Price__c newIGCP= new ASI_CRM_Item_Group_Customer_Price__c();
            if(interimDataMap.containsKey(igcp.ASI_CRM_Customer__c + '-' + igcp.ASI_CRM_Item_Group__c) && taxRate != null){
                igcp.ASI_CRM_Unit_Price_BT__c = (igcp.ASI_CRM_Unit_Price_BT__c * (1 + taxRate/100)).setScale(2);
                InterimData temp = interimDataMap.get(igcp.ASI_CRM_Customer__c + '-' + igcp.ASI_CRM_Item_Group__c);
                temp.IGCP = igcp;
            }
        }
        
        for (InterimData intdata : interimDataMap.values()) {
            List<String> tembody = new List<String>();
            tembody.add(intdata.OFD.ASI_CRM_Product_Name__r.ASI_CRM_CN_Eng_Name__c == null ? '' : intdata.OFD.ASI_CRM_Product_Name__r.ASI_CRM_CN_Eng_Name__c);
            tembody.add(intdata.OFD.ASI_CRM_Product_Name__r.ASI_CRM_CN_Chinese_Name__c == null ? '' : intdata.OFD.ASI_CRM_Product_Name__r.ASI_CRM_CN_Chinese_Name__c);
            tembody.add(intdata.OFD.ASI_CRM_Product_Name__r.ASI_CRM_CN_Pack_Value__c == null ? '' : String.valueOf(intdata.OFD.ASI_CRM_Product_Name__r.ASI_CRM_CN_Pack_Value__c));
            tembody.add(intdata.OFD.ASI_CRM_Product_Name__r.ASI_CRM_CN_BT_Size_C__c == null ? '' : String.valueOf(intdata.OFD.ASI_CRM_Product_Name__r.ASI_CRM_CN_BT_Size_C__c));
            tembody.add('');
            tembody.add('箱');
            tembody.add(intdata.IGCP.ASI_CRM_Unit_Price_BT__c == null ? '' : String.valueOf(intdata.IGCP.ASI_CRM_Unit_Price_BT__c));
            tembody.add(intdata.OFD.ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_External_ID__c == null ? '' : intdata.OFD.ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_External_ID__c);
            if (intdata.IGCP.ASI_CRM_Unit_Price_BT__c != null) {
                uploadtemp.add(tembody);
            }
        }
        return uploadtemp; 
    }

    public static Contact getContact() {
        final String userId = UserInfo.getUserId();
        final List <User> users = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        
        if (!users.isEmpty()) {
            List<Contact> contactList = [SELECT Name, Phone, Account.Name, AccountId
                                     FROM Contact 
                                     WHERE Id = :users[0].ContactId];
            if (!contactList.isEmpty()) {
                return contactList[0];
            }
        }
        return null;
    }

    

}