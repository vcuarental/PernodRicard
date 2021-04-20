public without sharing class ASI_CRM_CN_IGCP_TriggerClass {
    //modify by 20191203 Alex add Trade a&p Discount, Normal Discount, A&D Discount
    public static void beforeUpsertMethod(List<ASI_CRM_Item_Group_Customer_Price__c> triggerNew){
        Set<id> customerIDSet = new Set<id>();
        Set<id> itemGroupIDSet = new Set<id>();
        
        for(ASI_CRM_Item_Group_Customer_Price__c obj : triggerNew){
            customerIDSet.add(obj.ASI_CRM_Customer__c);
            itemGroupIDSet.add(obj.ASI_CRM_Item_Group__c);
        }
        
        List<ASI_CRM_Price_And_Discount__c> priceAndDiscount = new List<ASI_CRM_Price_And_Discount__c>([SELECT id 
                                                                                                        , ASI_CRM_Effective_From__c
                                                                                                        , ASI_CRM_Effective_To__c
                                                                                                        , ASI_CRM_Customer__c
                                                                                                        , ASI_CRM_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                                                                                                        , RecordType.Name //add by 20191203 Alex 
                                                                                                        , (SELECT id
                                                                                                           , ASI_CRM_Promotion_Code__c
                                                                                                           , ASI_CRM_Item_Group_Description__c
                                                                                                           , ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c
                                                                                                           , ASI_CRM_Price_And_Discount__c
                                                                                                           , ASI_CTY_CN_WS_Level1_Promotion_Code__c
                                                                                                           FROM Price_And_Discount_Details__r
                                                                                                           WHERE ASI_CRM_Item_Group_Description__c IN : itemGroupIDSet
                                                                                                           //AND 	ASI_CRM_Promotion_Code__c != NULL 20161122 Elufa
                                                                                                           AND recordType.DeveloperName = 'ASI_CRM_CN_Price_And_Discount_Detail'
                                                                                                          )
                                                                                                        FROM ASI_CRM_Price_And_Discount__c
                                                                                                        WHERE ASI_CRM_Effective_From__c <=: date.today()
                                                                                                        AND ASI_CRM_Effective_To__c >=: date.today().addDays(-183) //20180809 Introv
                                                                                                        AND ASI_CRM_Customer__c IN : customerIDSet
                                                                                                        AND (recordType.DeveloperName = 'ASI_CRM_CN_Customer_Price_and_Discount_Request' 
                                                                                                             OR recordType.DeveloperName = 'ASI_CRM_CN_Customer_Price_and_Discount_Request_RO' 
                                                                                                             OR recordType.DeveloperName LIKE 'ASI_CTY_CN_WS_Customer_Price_and_Discount_Request%')
                                                                                                        AND ( ASI_CRM_Status__c = 'Approved'
                                                                                                        	 OR ASI_CRM_Status__c = 'Completed' ) 
                                                                                                        ORDER BY ASI_CRM_Approved_Date__c desc
                                                                                                       ]);
        
        //Map<id, Map<id, ASI_CRM_Price_And_Discount_Detail__c>> mapPromtionCode = new Map<id, Map<id, ASI_CRM_Price_And_Discount_Detail__c>>();
        Map<String, ASI_CRM_Price_And_Discount_Detail__c> mapItemGroup = new Map<String, ASI_CRM_Price_And_Discount_Detail__c>();
        Map<String, ASI_CRM_Price_And_Discount_Detail__c> mapItemGroupTAPD = new Map<String, ASI_CRM_Price_And_Discount_Detail__c>();
        Map<String, ASI_CRM_Price_And_Discount_Detail__c> mapItemGroupND = new Map<String, ASI_CRM_Price_And_Discount_Detail__c>();
        Map<String, ASI_CRM_Price_And_Discount_Detail__c> mapItemGroupAD = new Map<String, ASI_CRM_Price_And_Discount_Detail__c>();
        Set<Id> IHBRSet = new Set<Id>();
        for(ASI_CRM_Price_And_Discount__c obj : priceAndDiscount){
            String recordTypeName = obj.RecordType.Name;

            if(obj.ASI_CRM_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c){
                IHBRSet.add(obj.ASI_CRM_Customer__c);
            }
            
            for(ASI_CRM_Price_And_Discount_Detail__c detailObj : obj.Price_And_Discount_Details__r){
                if(obj.ASI_CRM_Customer__c != Null){
                    getMapItemGroup(recordTypeName, obj.ASI_CRM_Customer__c, detailObj, mapItemGroup, mapItemGroupTAPD, mapItemGroupND, mapItemGroupAD);
                }
            }
        }

        for(ASI_CRM_Item_Group_Customer_Price__c itemGroupCustomerPrice : triggerNew){
            
            itemGroupCustomerPrice.ASI_CRM_Promotion_Expiration_Date__c = null;
            itemGroupCustomerPrice.ASI_CRM_Price_And_Discount__c = null;
            itemGroupCustomerPrice.ASI_CRM_Promotion_Code__c = null;

            // add by 20191203 Alex start
            itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c = null;
            itemGroupCustomerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__c = null;
            itemGroupCustomerPrice.ASI_CTY_CN_WS_Normal_Discount__c = null;
            itemGroupCustomerPrice.ASI_CTY_CN_WS_AD_Discount__c = null;
            // add by 20191203 Alex end

            if(mapItemGroup.containsKey(itemGroupCustomerPrice.ASI_CRM_Customer__c + '' + itemGroupCustomerPrice.ASI_CRM_Item_Group__c)){
                
                itemGroupCustomerPrice.ASI_CRM_Promotion_Code__c = mapItemGroup.get(itemGroupCustomerPrice.ASI_CRM_Customer__c + '' + itemGroupCustomerPrice.ASI_CRM_Item_Group__c).ASI_CRM_Promotion_Code__c;

                if(itemGroupCustomerPrice.ASI_CRM_Promotion_Code__c != null){
                    itemGroupCustomerPrice.ASI_CRM_Promotion_Expiration_Date__c = mapItemGroup.get(itemGroupCustomerPrice.ASI_CRM_Customer__c + '' + itemGroupCustomerPrice.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c;
                    itemGroupCustomerPrice.ASI_CRM_Price_And_Discount__c = mapItemGroup.get(itemGroupCustomerPrice.ASI_CRM_Customer__c + '' + itemGroupCustomerPrice.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__c;
                }
                if(IHBRSet.contains(itemGroupCustomerPrice.ASI_CRM_Customer__c)){
                    itemGroupCustomerPrice.ASI_CRM_Effective_Date_To__c = mapItemGroup.get(itemGroupCustomerPrice.ASI_CRM_Customer__c + '' + itemGroupCustomerPrice.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c;
                    itemGroupCustomerPrice.ASI_CRM_Price_And_Discount__c = mapItemGroup.get(itemGroupCustomerPrice.ASI_CRM_Customer__c + '' + itemGroupCustomerPrice.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__c;
                }
            }

            // add by 20191203 Alex start
            if (mapItemGroupTAPD.containsKey(itemGroupCustomerPrice.ASI_CRM_Customer__c)) {
                itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c = itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c == null ? mapItemGroupTAPD.get(itemGroupCustomerPrice.ASI_CRM_Customer__c).ASI_CTY_CN_WS_Level1_Promotion_Code__c : itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c;
                
                if(itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c != null){
                    itemGroupCustomerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__c = mapItemGroupTAPD.get(itemGroupCustomerPrice.ASI_CRM_Customer__c).ASI_CRM_Price_And_Discount__c;
                }
            }

            if (mapItemGroupND.containsKey(itemGroupCustomerPrice.ASI_CRM_Customer__c)) {
                itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c = itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c == null ? mapItemGroupND.get(itemGroupCustomerPrice.ASI_CRM_Customer__c).ASI_CTY_CN_WS_Level1_Promotion_Code__c : itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c;
                
                if(itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c != null){
                    itemGroupCustomerPrice.ASI_CTY_CN_WS_Normal_Discount__c = mapItemGroupND.get(itemGroupCustomerPrice.ASI_CRM_Customer__c).ASI_CRM_Price_And_Discount__c;
                }
            }

            if (mapItemGroupAD.containsKey(itemGroupCustomerPrice.ASI_CRM_Customer__c)) {
                itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c = itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c == null ? mapItemGroupAD.get(itemGroupCustomerPrice.ASI_CRM_Customer__c).ASI_CTY_CN_WS_Level1_Promotion_Code__c : itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c;
                
                if(itemGroupCustomerPrice.ASI_CTY_CN_WS_Promotion_Code__c != null){
                    itemGroupCustomerPrice.ASI_CTY_CN_WS_AD_Discount__c = mapItemGroupAD.get(itemGroupCustomerPrice.ASI_CRM_Customer__c).ASI_CRM_Price_And_Discount__c;
                }
            }
            // add by 20191203 Alex end
        }
    }

    private static void getMapItemGroup(String recordTypeName, String customerId, ASI_CRM_Price_And_Discount_Detail__c detailObj,
                                 Map<String, ASI_CRM_Price_And_Discount_Detail__c> mapItemGroup,
                                 Map<String, ASI_CRM_Price_And_Discount_Detail__c> mapItemGroupTAPD,
                                 Map<String, ASI_CRM_Price_And_Discount_Detail__c> mapItemGroupND,
                                 Map<String, ASI_CRM_Price_And_Discount_Detail__c> mapItemGroupAD) {
        if (recordTypeName.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P) 
            && !mapItemGroupTAPD.containsKey(customerId)) {
            mapItemGroupTAPD.put(customerId, detailObj);
        } else if (recordTypeName.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL) 
                   && !mapItemGroupND.containsKey(customerId)) {
            mapItemGroupND.put(customerId, detailObj);
        } else if (recordTypeName.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD)
                   && !mapItemGroupAD.containsKey(customerId)) {
            mapItemGroupAD.put(customerId, detailObj);
        }else if (!recordTypeName.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P) 
                   && !recordTypeName.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL) 
                   && !recordTypeName.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD)
                   && !mapItemGroup.containsKey(customerId + '' + detailObj.ASI_CRM_Item_Group_Description__c)) {
            mapItemGroup.put(customerId + '' + detailObj.ASI_CRM_Item_Group_Description__c, detailObj);
        } 
    }
}