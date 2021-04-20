public without sharing class ASI_CTY_CN_WS_OrderDetailController {
    
    private static final String RTDEVNAME_SORITEMCN = 'ASI_CRM_CN_SalesOrder_Item';

    @AuraEnabled
    public static ASI_KOR_Sales_Order_Request__c getSalesOrder(String sorId) {
        List<ASI_KOR_Sales_Order_Request__c> sorlist = [SELECT Name, ASI_CRM_CN_Address__c, ASI_CRM_CN_Contact_Person__c,ASI_CTY_CN_WS_Total_Order_Qty_CA__c,
                                                            ASI_CRM_CN_Order_Number__c,ASI_CRM_CN_Tel_Mobile__c,ASI_CTY_CN_WS_Status__c,
                                                             ASI_CRM_SG_Order_Date__c,ASI_CRM_CN_Total_Qty__c,ASI_CRM_CN_Other_Requirement__c
                                                    FROM ASI_KOR_Sales_Order_Request__c
                                                    WHERE Id = :sorId];
        return sorlist[0];
    }

    @AuraEnabled
    public static Map<String, String> getSalesOrderId(String notifId) {
        ASI_CTY_CN_WS_Notifications__c notif = [SELECT ASI_CTY_CN_WS_Sales_Order_Request__c, ASI_CTY_CN_WS_TOV__c 
                                                FROM ASI_CTY_CN_WS_Notifications__c
                                                WHERE Id = :notifId];
        Map<String, String> resultMap = new Map<String, String>();
        if (notif.ASI_CTY_CN_WS_TOV__c != null) {
            ASI_CRM_TOV__c tov = [SELECT ASI_CRM_SF_SO_Request_Number__c
                                FROM ASI_CRM_TOV__c
                                WHERE Id = :notif.ASI_CTY_CN_WS_TOV__c
                                AND RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCN];
            resultMap.put('orderId', tov.ASI_CRM_SF_SO_Request_Number__c);
            resultMap.put('tovId', tov.Id);
        } else {
            resultMap.put('orderId', notif.ASI_CTY_CN_WS_Sales_Order_Request__c);
        }
        
        return resultMap;
    }

    @AuraEnabled
    public static List<SaleOrderItem> getOrderItems(String sorId) {
        System.debug(LoggingLevel.INFO, '*** sorId: ' + sorId);
        List<ASI_KOR_Sales_Order_Transaction__c> orderItems = [SELECT ASI_CRM_CN_Sales_Oder_TOV__c,
                                                                    ASI_CRM_CN_Sales_Oder_TOV__r.ASI_CRM_SO_Number__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c,
                                                                    ASI_KOR_Order_Qty__c,
                                                                    ASI_CRM_CN_Qty_9L__c,
                                                                    ASI_CTY_CN_WS_Order_Qty_CA__c,
                                                                    ASI_CRM_CN_UOM__c,
                                                                    ASI_CTY_CN_WS_Actual_Unit_Price__c,
                                                                    ASI_CTY_CN_WS_Disount_Rate__c,
                                                                    ASI_CTY_CN_WS_Promotion_Rate__c,
                                                                    ASI_CRM_CN_Promotion_Code__r.Name,
                                                                    ASI_CRM_CN_Free_Qty_BT__c,
                                                                    ASI_CRM_CN_Released_Qty__c,
                                                                    ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c,
                                                                    ASI_CTY_CN_WS_Promotion_Amount_BT__c,
                                                                    ASI_CRM_CN_Unit_Price_BT_with_VAT__c,
                                                                    ASI_CRM_MOT_Promotion_Price_non_VAT__c,
                                                                    ASI_CRM_MOT_Price_non_VAT__c,
                                                                    ASI_CRM_CN_Logistics_Remark__c
                                                                FROM ASI_KOR_Sales_Order_Transaction__c 
                                                                WHERE ASI_KOR_Sales_Order_Request__c =: sorId];
        Map<String, ASI_KOR_Sales_Order_Transaction__c> sotMap = new Map<String, ASI_KOR_Sales_Order_Transaction__c>();
        for (ASI_KOR_Sales_Order_Transaction__c sot : orderItems) {
            sotMap.put(sot.Id, sot);
        }
        // Get tovs of order items
        List<ASI_CRM_TOV_Detail__c> tovItems = [SELECT ASI_CRM_SF_SO_Request_Line_Number__c,
                                                        ASI_CRM_TOV__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Order_Qty_CA__c,
                                                        ASI_CTY_CN_WS_Order_Qty_CA__c,
                                                        ASI_CRM_TOV__r.ASI_CRM_SO_Number__c                                             
                                                FROM ASI_CRM_TOV_Detail__c
                                                WHERE ASI_CRM_SF_SO_Request_Line_Number__c IN :sotMap.keySet()
                                                AND ASI_CRM_TOV__r.RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCN];
        Map<String, List<ASI_CRM_TOV_Detail__c>> tovdMap = new Map<String, List<ASI_CRM_TOV_Detail__c>>();
        for (ASI_CRM_TOV_Detail__c tovd : tovItems) {
            if (tovdMap.containsKey(tovd.ASI_CRM_SF_SO_Request_Line_Number__c)) {
                tovdMap.get(tovd.ASI_CRM_SF_SO_Request_Line_Number__c).add(tovd);
            } else {
                tovdMap.put(tovd.ASI_CRM_SF_SO_Request_Line_Number__c, new List<ASI_CRM_TOV_Detail__c>{tovd});
            }
        }
        List<SaleOrderItem> noTovList =  new List<SaleOrderItem>();
        for (String sotkey : sotMap.keySet()) {
            ASI_KOR_Sales_Order_Transaction__c sot = sotMap.get(sotkey);

            Map<String,SaleOrderItem> newSOTMap = new Map<String,SaleOrderItem>();
            // if sor item has tovs
            if (tovdMap.get(sotkey) != null) {

                List<ASI_CRM_TOV_Detail__c> tovdList = tovdMap.get(sotkey);
                for (ASI_CRM_TOV_Detail__c tovd : tovdList) {
                    // the tov no is exist, summary the qty
                    if (newSOTMap.containsKey(tovd.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c)) {
                        SaleOrderItem upsorItem= newSOTMap.get(tovd.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c);
                        upsorItem.qty += tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Order_Qty_CA__c == null ? 0 : tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Order_Qty_CA__c;
                    } else {
                        SaleOrderItem sorItem = newSaleOrderItem(sot);
                        sorItem.tovNO = tovd.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c;
                        sorItem.qty = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Order_Qty_CA__c == null ? 0 : tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Order_Qty_CA__c;
                        newSOTMap.put(sorItem.tovNO, sorItem);
                    }
                    
                }
            } else {
                noTovList.add(newSaleOrderItem(sot));
            }
            noTovList.addAll(newSOTMap.values());
        }
        return noTovList;
    }

    // Generate sales order item wrapper object
    public static SaleOrderItem newSaleOrderItem(ASI_KOR_Sales_Order_Transaction__c sot) {
        SaleOrderItem sorItem = new SaleOrderItem();
        sorItem.productName = sot.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c;
        sorItem.productENName = sot.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c;
        sorItem.pack = sot.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c;
        sorItem.qty = sot.ASI_CTY_CN_WS_Order_Qty_CA__c;
        sorItem.releasedQty = sot.ASI_CRM_CN_Released_Qty__c == null ? 0 : sot.ASI_CRM_CN_Released_Qty__c;
        sorItem.unitPrice = sot.ASI_CRM_CN_Unit_Price_BT_with_VAT__c == null ? 0 : sot.ASI_CRM_CN_Unit_Price_BT_with_VAT__c.setScale(2);
        sorItem.promotionAmount = sot.ASI_CTY_CN_WS_Promotion_Amount_BT__c == null ? 0 : sot.ASI_CTY_CN_WS_Promotion_Amount_BT__c.setScale(2);
        sorItem.discountRate = sot.ASI_CTY_CN_WS_Disount_Rate__c == null ? 0 : sot.ASI_CTY_CN_WS_Disount_Rate__c;
        sorItem.actualPrice = sot.ASI_CTY_CN_WS_Actual_Unit_Price__c == null ? 0 : sot.ASI_CTY_CN_WS_Actual_Unit_Price__c.setScale(2);
        
        sorItem.releasedAmount = sot.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c == null 
                                 ? 0 : (sorItem.releasedQty * sorItem.actualPrice * sot.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c).setScale(2) ;
        return sorItem;
    }

    @AuraEnabled
    public static List<TOVWrapper> getOrderTOVs(String sorId) {
        Map<String, ASI_CRM_TOV__c> tovnoMap = new Map<String, ASI_CRM_TOV__c>();
        List<ASI_CRM_TOV__c> tovs = [SELECT Name,
                                            ASI_CRM_SO_Number__c,
                                            ASI_CRM_Status__c,
                                            ASI_CRM_Total_TOV_Qty__c,
                                            ASI_CRM_Total_Number_of_Line__c,
                                            ASI_MFM_Total_Amount_wTax__c,
                                            ASI_CTY_CN_WS_Status__c,
                                            RecordType.DeveloperName
                                        FROM ASI_CRM_TOV__c
                                        WHERE ASI_CRM_SF_SO_Request_Number__c =: sorId
                                        AND (RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCN
                                        OR RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCNFINAL)];
        for (ASI_CRM_TOV__c tov : tovs) {
            if (tovnoMap.containsKey(tov.ASI_CRM_SO_Number__c)) {
                if (tov.RecordType.DeveloperName == ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCNFINAL) {
                    tovnoMap.put(tov.ASI_CRM_SO_Number__c, tov);
                }
            } else {
                tovnoMap.put(tov.ASI_CRM_SO_Number__c, tov);
            }
        }
        Set<Id> tovIds = new Set<Id>();
        for (ASI_CRM_TOV__c tov : tovnoMap.values()) {
            tovIds.add(tov.Id);
        }

        // Tovno and tov detail map
        Map<String, List<TOVDetail>> tovdMap = new Map<String, List<TOVDetail>>();
        List<ASI_CRM_TOV_Detail__c> tovdItems = [SELECT ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Released_Qty__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c,
                                                        ASI_CRM_Pack_Description__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Unit_Price_BT_with_VAT__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Promotion_Rate__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Disount_Rate__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Promotion_Amount_BT__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Actual_Unit_Price__c,
                                                        ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Order_Qty_CA__c,
                                                        ASI_CRM_SF_Promotion_Code__c,
                                                        ASI_CRM_Price_BT__c,
                                                        ASI_CTY_CN_WS_Order_Qty_CA__c,
                                                        ASI_CRM_SF_SO_Price_BT_with_VAT__c,
                                                        ASI_CRM_TOV__r.ASI_CRM_SO_Number__c,
                                                        ASI_CRM_Order_QTY__c,
                                                        ASI_CRM_TOV__r.ASI_CTY_CN_WS_Status__c,
                                                        ASI_CRM_Total_Amount__c
                                                 FROM ASI_CRM_TOV_Detail__c
                                                 WHERE ASI_CRM_TOV__c IN :tovIds];
        for (ASI_CRM_TOV_Detail__c tovd : tovdItems) {
            if (tovdMap.containsKey(tovd.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c)) {
                TOVDetail tovdwrapper = newTOVDetail(tovd);             
                tovdMap.get(tovd.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c).add(tovdwrapper);
            } else {
                TOVDetail tovdwrapper = newTOVDetail(tovd);
                tovdMap.put(tovd.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c, new List<TOVDetail>{tovdwrapper});
            }
        }

        Map<String, List<DeliveryInfo>> deliveryMap = new Map<String, List<DeliveryInfo>>();
        for (String tovno : tovnoMap.keySet()) {
            deliveryMap.put(tovno, getDeliveryInfo(tovno));
        }
        List<TOVWrapper> tovWrapperList = new List<TOVWrapper>();
        for (String tovno : tovdMap.keySet()) {
            TOVWrapper tovWrapper = new TOVWrapper();
            tovWrapper.tovId = tovnoMap.get(tovno).Id;
            tovWrapper.tovNO = tovno;
            tovWrapper.tovStatus = tovnoMap.get(tovno).ASI_CTY_CN_WS_Status__c;
            System.debug(LoggingLevel.INFO, '*** deliveryMap: ' + deliveryMap);
            List<DeliveryInfo>  delivlist = deliveryMap.get(tovno) == null ? new List<DeliveryInfo>() : deliveryMap.get(tovno);
            // List<DeliveryInfo>  delivlist = getDeliveryInfo('40320215');
            List<DeliveryInfo>  reverseDelivlist = new List<DeliveryInfo>();
            for (Integer i = delivlist.size()-1; i >= 0; i --) {
                if (delivlist[i].trackingstatus == ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_INTRANSIT_EN){
                    delivlist[i].trackingstatus = ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_INTRANSIT_CN;
                } else if (delivlist[i].trackingstatus == ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_ARRIVED_EN) {
                    delivlist[i].trackingstatus = ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_ARRIVED_CN;
                } else if (delivlist[i].trackingstatus == ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_PICKED_EN){
                    delivlist[i].trackingstatus = ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_PICKED_CN;
                }  else if (delivlist[i].trackingstatus == ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_CLOSED_EN){
                    delivlist[i].trackingstatus = ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_CLOSED_CN;
                }  else if (delivlist[i].trackingstatus == ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_TOV_GENERATED_EN){
                    delivlist[i].trackingstatus = ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_TOV_GENERATED_CN;
                } else if (delivlist[i].trackingstatus == ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_SHIPPING_DATE_EN){
                    delivlist[i].trackingstatus = ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_SHIPPING_DATE_CN;
                } else if (delivlist[i].trackingstatus == ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_DISPATCHING_DATE_EN){
                    delivlist[i].trackingstatus = ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_DISPATCHING_DATE_CN;
                } else {
                    delivlist[i].trackingstatus = ASI_CTY_CN_WS_Utils.DELIVERTY_STATUS_UNKNOWN;
                }
                reverseDelivlist.add(delivlist[i]);
            }
            System.debug(LoggingLevel.INFO, '*** reverseDelivlist: ' + reverseDelivlist);
            tovWrapper.tovDetails = tovdMap.get(tovno);
            tovWrapper.deliveryInfos = reverseDelivlist;
            tovWrapperList.add(tovWrapper);
        }
        System.debug(LoggingLevel.INFO, '*** tovWrapperList: ' + tovWrapperList);
        return tovWrapperList;
    }

    // Generate TOV detail wrapper object
    public static TOVDetail newTOVDetail(ASI_CRM_TOV_Detail__c tovd) {
        TOVDetail tovdwrapper = new TOVDetail();  
        tovdwrapper.productName = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c;
        tovdwrapper.productENName = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c;
        tovdwrapper.pack = tovd.ASI_CRM_Pack_Description__c;
        tovdwrapper.price = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Unit_Price_BT_with_VAT__c == null ? 0 : tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Unit_Price_BT_with_VAT__c.setScale(2);
        tovdwrapper.promotionAmount = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Promotion_Amount_BT__c == null ? 0 :  tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Promotion_Amount_BT__c.setScale(2);
        tovdwrapper.discount = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Disount_Rate__c == null 
                                ? 0 : tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Disount_Rate__c;
        tovdwrapper.actualPrice = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Actual_Unit_Price__c == null ? 0 : tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Actual_Unit_Price__c.setScale(2);
        tovdwrapper.qty = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Order_Qty_CA__c;
        tovdwrapper.releasedQty = tovd.ASI_CTY_CN_WS_Order_Qty_CA__c;
        // if (tovd.ASI_CRM_TOV__r.ASI_CTY_CN_WS_Status__c == ASI_CTY_CN_WS_Utils.TOV_STATUS_DISPATCHED_CN || tovd.ASI_CRM_TOV__r.ASI_CTY_CN_WS_Status__c == ASI_CTY_CN_WS_Utils.TOV_STATUS_RECIEVED_CN) {
        //     tovdwrapper.releasedAmount = (tovdwrapper.releasedQty * tovdwrapper.price * tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c).setScale(2);
        // } else {
        //     tovdwrapper.releasedAmount = 0;
        // }
        tovdwrapper.releasedAmount =  tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c == null 
                                      ? 0 : (tovdwrapper.releasedQty * tovdwrapper.actualPrice * tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c).setScale(2) ;
        return tovdwrapper;
    }

    // Delivery information request
    public static List<DeliveryInfo> getDeliveryInfo(String tovno) {
        // List<ASI_CTY_CN_WS_Remote_Site_Setting__mdt> deliverySettings = new List<ASI_CTY_CN_WS_Remote_Site_Setting__mdt>();
        List<ASI_CRM_CN_CustomSetting__c> deliverySettings = [SELECT ASI_CTY_CN_WS_Dev_EndPoint__c, ASI_CTY_CN_WS_Dev_JWT_Key__c,
                                                                    ASI_CTY_CN_WS_Pro_EndPoint__c, ASI_CTY_CN_WS_Pro_JWT_Key__c
                                                              FROM ASI_CRM_CN_CustomSetting__c];
        Boolean isSBX = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endPt = '';
        String jwtKey = '';
        if (isSBX) {
            endPt = deliverySettings[0].ASI_CTY_CN_WS_Dev_EndPoint__c;
            jwtKey = deliverySettings[0].ASI_CTY_CN_WS_Dev_JWT_Key__c;
        } else {
            endPt = deliverySettings[0].ASI_CTY_CN_WS_Pro_EndPoint__c;
            jwtKey = deliverySettings[0].ASI_CTY_CN_WS_Pro_JWT_Key__c;
        }
        
        if (deliverySettings.isEmpty()) return null;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPt);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        String sign = generateJWT(jwtKey);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('user_id', 'BLS');
        gen.writeStringField('tovno', tovno);
        gen.writeStringField('sign', sign);
        gen.writeEndObject();
        request.setBody(gen.getAsString());
        if (!Test.isRunningTest()) {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                    response.getStatusCode() + ' ' + response.getStatus());
                return null;
            } else {
                System.debug( 'response body' + response.getBody());
                Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> dataJson = (Map<String, Object>)resJson.get('data');
                System.debug(LoggingLevel.INFO, '*** dataJson: ' + dataJson);
                List<DeliveryInfo> deliveryInfo = (List<DeliveryInfo>)JSON.deserialize(JSON.serialize(dataJson.get('trans')), List<DeliveryInfo>.class);
                return deliveryInfo;
            }
        } else {
            return null;
        }
        
        
    }

    // Generate JWT
    public static String generateJWT(String jwtKey) {
        Map<String,String> claims = new Map<String,String>();
        String jwt = '';
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('typ', 'JWT');
        header.writeStringField('alg', 'HS256');
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));

        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('sub', 'BLS');
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        body.writeNumberField('iat', rightNow);
        if (claims != null) {
            for (String claim : claims.keySet()) {
                body.writeStringField(claim, claims.get(claim));
            }
        }
        body.writeEndObject();

        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        System.debug(LoggingLevel.INFO, '*** jwt: ' + jwt);
        // Production
        // Blob key = EncodingUtil.base64Decode('1gfi5g6unMVJaeT4WtXLGENSYaJjuELA');
        // Test
        Blob key = EncodingUtil.base64Decode(jwtKey);

        Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
        jwt += '.' + base64URLencode(signature);
        System.debug(LoggingLevel.INFO, '*** jwt: ' + jwt);
        return jwt;

    }


    // Generate Base64 string
    public static String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }

    // Order Item class
    class SaleOrderItem{
        @AuraEnabled
        public String tovNO {get; set;}
        @AuraEnabled
        public String productName {get; set;}
        @AuraEnabled
        public String productENName {get; set;}
        @AuraEnabled
        public String pack {get; set;}
        @AuraEnabled
        public Decimal qty {get; set;}
         @AuraEnabled
        public Decimal releasedQty {get; set;}
        @AuraEnabled
        public Decimal unitPrice {get; set;}
        @AuraEnabled
        public Decimal promotionAmount {get; set;}
        @AuraEnabled
        public Decimal discountRate {get; set;}
        @AuraEnabled
        public Decimal actualPrice {get; set;}
         @AuraEnabled
        public Decimal releasedAmount {get; set;}
        
    }

    // TOV wrapper class
    class TOVWrapper {
        @AuraEnabled
        public String tovId {get; set;}
        @AuraEnabled
        public String tovNO {get; set;}
        @AuraEnabled
        public String tovStatus {get; set;}
        @AuraEnabled
        public List<TOVDetail> tovDetails {get; set;}
        @AuraEnabled
        public List<DeliveryInfo> deliveryInfos {get; set;}
    }

     // TOV Detail class
    class TOVDetail{
        @AuraEnabled
        public String productName {get; set;}
        @AuraEnabled
        public String productENName {get; set;}
        @AuraEnabled
        public String pack {get; set;}
        @AuraEnabled
        public Decimal price {get; set;}
        @AuraEnabled
        public Decimal promotionAmount {get; set;}
         @AuraEnabled
        public Decimal discount {get; set;}
        @AuraEnabled
        public Decimal actualPrice {get; set;}
        @AuraEnabled
        public Decimal qty {get; set;}
        @AuraEnabled
        public Decimal releasedQty {get; set;}
        @AuraEnabled
        public Decimal releasedAmount {get; set;}
    }

    // Delivery Info class
    class DeliveryInfo {
        @AuraEnabled
        public String transportcompany {get; set;}
        @AuraEnabled
        public Integer documentid {get; set;}
        @AuraEnabled
        public String trackingstatus {get; set;}
        @AuraEnabled
        public String batchid {get; set;}
        @AuraEnabled
        public String transno {get; set;}
        @AuraEnabled
        public String tovno {get; set;}
        @AuraEnabled
        public String trackingtime {get; set;}
        @AuraEnabled
        public String location {get; set;}
    }

    @AuraEnabled
    public static List<List<String>> getSORDetail(String sorId) {
        List<List<String>> uploadtemp = new List<List<String>>();
        ASI_CRM_CN_CustomSetting__c customSetting = ASI_CRM_CN_CustomSetting__c.getInstance();

        List<String> tempTitle = new List<String>();
        if (NULL != customSetting) {
            if(String.isNotBlank(customSetting.ASI_CTY_CN_WS_Download_SOR_Item_Header__c)){
                tempTitle = customSetting.ASI_CTY_CN_WS_Download_SOR_Item_Header__c.split(',');
            }
        }
                                              
        uploadtemp.add(tempTitle);

        
        List<ASI_KOR_Sales_Order_Transaction__c> orderItems = [SELECT ASI_CRM_CN_Sales_Oder_TOV__c,
                                                                        ASI_CRM_CN_Sales_Oder_TOV__r.ASI_CRM_SO_Number__c,
                                                                        ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c,
                                                                        ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c,
                                                                        ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c,
                                                                        ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c,
                                                                        ASI_KOR_Order_Qty__c,
                                                                        ASI_CRM_CN_Qty_9L__c,
                                                                        ASI_CTY_CN_WS_Order_Qty_CA__c,
                                                                        ASI_CRM_CN_UOM__c,
                                                                        ASI_CTY_CN_WS_Actual_Unit_Price__c,
                                                                        ASI_CTY_CN_WS_Disount_Rate__c,
                                                                        ASI_CTY_CN_WS_Promotion_Rate__c,
                                                                        ASI_CRM_CN_Promotion_Code__r.Name,
                                                                        ASI_CRM_CN_Free_Qty_BT__c,
                                                                        ASI_CRM_CN_Released_Qty__c,
                                                                        ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c,
                                                                        ASI_CRM_CN_Unit_Price_BT_with_VAT__c,
                                                                        ASI_CRM_MOT_Promotion_Price_non_VAT__c,
                                                                        ASI_CRM_MOT_Price_non_VAT__c,
                                                                        ASI_CRM_CN_Logistics_Remark__c,
                                                                        ASI_KOR_Sales_Order_Request__r.Name,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Status__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Contact_Person__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Tel_Mobile__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Total_Order_Qty_CA__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Other_Requirement__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Address__c
                                                                    FROM ASI_KOR_Sales_Order_Transaction__c 
                                                                    WHERE ASI_KOR_Sales_Order_Request__c =: sorId
                                                                   AND RecordType.DeveloperName =: RTDEVNAME_SORITEMCN];
        System.debug(LoggingLevel.INFO, '*** orderItems: ' + orderItems);
        Set<String> orderItemIds = new Set<String>();
        for(ASI_KOR_Sales_Order_Transaction__c orderItem : orderItems){
            orderItemIds.add(orderItem.Id);
        }
        List<ASI_CRM_TOV_Detail__c> tovItems = [SELECT ASI_CRM_SF_SO_Request_Line_Number__c,
                                                        ASI_CRM_TOV__r.ASI_CRM_SO_Number__c                                             
                                                FROM ASI_CRM_TOV_Detail__c
                                                WHERE ASI_CRM_SF_SO_Request_Line_Number__c IN :orderItemIds
                                                AND ASI_CRM_TOV__r.RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCN];
        System.debug(LoggingLevel.INFO, '*** tovItems: ' + tovItems);
        Map<String, String> tovSORItemMap = new Map<String, String>();
        for(ASI_CRM_TOV_Detail__c tovItem : tovItems){
            tovSORItemMap.put(tovItem.ASI_CRM_SF_SO_Request_Line_Number__c, tovItem.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c);
        }
        System.debug(LoggingLevel.INFO, '*** tovSORItemMap: ' + tovSORItemMap);
        for(ASI_KOR_Sales_Order_Transaction__c orderItem : orderItems){
            List<String> tembody = new List<String>();
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.Name == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.Name);
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Status__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Status__c);
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Contact_Person__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Contact_Person__c);
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Tel_Mobile__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Tel_Mobile__c);
            // tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Total_Order_Qty_CA__c == null ? '0' : String.valueOf(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Total_Order_Qty_CA__c));
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c == null ? '' : String.valueOf(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c));
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Other_Requirement__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Other_Requirement__c);
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Address__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Address__c);
            tembody.add(tovSORItemMap.containsKey(orderItem.Id) ? tovSORItemMap.get(orderItem.Id) : '');
            String name = orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c == null ? '' : orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c;
            name += '\n' + orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c == null ? '' : orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c;
            tembody.add(name);
            tembody.add(orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c == null ? '' : orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c);
            tembody.add(orderItem.ASI_CTY_CN_WS_Order_Qty_CA__c == null ? '0' : String.valueOf(orderItem.ASI_CTY_CN_WS_Order_Qty_CA__c));
            tembody.add(orderItem.ASI_CRM_CN_Released_Qty__c == null ? '0' : String.valueOf(orderItem.ASI_CRM_CN_Released_Qty__c));
            tembody.add(orderItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c == null ? '0' : String.valueOf(orderItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c.setScale(3)));
            tembody.add(orderItem.ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c == null ? '0' : String.valueOf(orderItem.ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c));
            tembody.add(orderItem.ASI_CTY_CN_WS_Disount_Rate__c == null ? '0' : String.valueOf(orderItem.ASI_CTY_CN_WS_Disount_Rate__c));
            tembody.add(orderItem.ASI_CTY_CN_WS_Actual_Unit_Price__c == null ? '0' : String.valueOf(orderItem.ASI_CTY_CN_WS_Actual_Unit_Price__c.setScale(3)));
            Double packValue = orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c == null ? 0 : orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c;
            Double releasedQty = orderItem.ASI_CRM_CN_Released_Qty__c == null ? 0 : orderItem.ASI_CRM_CN_Released_Qty__c;
            Decimal actualPrice = orderItem.ASI_CTY_CN_WS_Actual_Unit_Price__c == null ? 0 : orderItem.ASI_CTY_CN_WS_Actual_Unit_Price__c;
            tembody.add(String.valueOf(packValue * releasedQty * actualPrice));
            uploadtemp.add(tembody);
        }
        System.debug(LoggingLevel.INFO, '*** uploadtemp: ' + uploadtemp);
        return uploadtemp;
    }

}