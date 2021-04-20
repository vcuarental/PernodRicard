public without sharing class ASI_CRM_CN_SalesOrderItem_TriggerClass {

    // 20190725 Wilson Chow start
    public Static Void beforeInsertMethod(List<ASI_KOR_Sales_Order_Transaction__c> triggerNew){

        system.debug('ASI_CRM_CN_SalesOrderItem_TriggerClass beforeInsertMethod start');

        Map<Id, ASI_KOR_Sales_Order_Request__c> salesOrderRequestIdMap =
                getSalesOrderRequestIdMap(triggerNew);

        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerIdMap = getCustomerIdMap(salesOrderRequestIdMap);

        Map<Id, ASI_MFM_Item_Group__c> itemGroupIdMap = getItemGroupIdMap(triggerNew);

        processSalesOrderItemTraceability(triggerNew);

        processSeason(triggerNew, salesOrderRequestIdMap, customerIdMap, itemGroupIdMap);

        system.debug('ASI_CRM_CN_SalesOrderItem_TriggerClass beforeInsertMethod end');
    }

    private static Map<Id, ASI_MFM_Item_Group__c> getItemGroupIdMap(
            List<ASI_KOR_Sales_Order_Transaction__c> triggerNew) {

        system.debug('getItemGroupIdMap start');
        Map<Id, ASI_MFM_Item_Group__c> result = new Map<Id, ASI_MFM_Item_Group__c>();

        if(triggerNew != null && triggerNew.size() > 0) {

            List<Id> itemGroupIdList = new List<Id>();

            for(ASI_KOR_Sales_Order_Transaction__c obj: triggerNew) {
                if(obj.ASI_CRM_CN_Product_Name__c != null
                        && !itemGroupIdList.contains(obj.ASI_CRM_CN_Product_Name__c)) {
                    itemGroupIdList.add(obj.ASI_CRM_CN_Product_Name__c);
                }
            }

            if(itemGroupIdList.size() > 0) {
                system.debug('Process to get item group by id list:' + itemGroupIdList);

                for (ASI_MFM_Item_Group__c itemGroup :
                [SELECT Id, ASI_CRM_Product_Category_JDE__c, ASI_CRM_Selective__c
                FROM ASI_MFM_Item_Group__c WHERE Id IN :itemGroupIdList]) {

                    result.put(itemGroup.Id, itemGroup);
                }
            }
        }

        system.debug('result:' + result);
        system.debug('getItemGroupIdMap end');
        return result;
    }

    private static Map<Id, ASI_CRM_AccountsAdditionalField__c> getCustomerIdMap(
            Map<Id, ASI_KOR_Sales_Order_Request__c> salesOrderRequestIdMap) {

        system.debug('getCustomerIdMap start');
        Map<Id, ASI_CRM_AccountsAdditionalField__c> result = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();

        if(salesOrderRequestIdMap != null && !salesOrderRequestIdMap.isEmpty()) {

            List<Id> customerIdList = new List<Id>();

            for(Id requestKey: salesOrderRequestIdMap.keySet()) {
                ASI_KOR_Sales_Order_Request__c request = salesOrderRequestIdMap.get(requestKey);
                if(request.ASI_CRM_CN_Customer__c != null
                        && !customerIdList.contains(request.ASI_CRM_CN_Customer__c)) {
                    customerIdList.add(request.ASI_CRM_CN_Customer__c);
                }
            }

            if(customerIdList.size() > 0) {
                system.debug('Process to get customer by id set:' + customerIdList);

                for (ASI_CRM_AccountsAdditionalField__c customer :
                    [SELECT Id, ASI_CRM_CN_Region__c
                    FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN :customerIdList]) {

                    result.put(customer.Id, customer);
                }
            }
        }

        system.debug('result:' + result);
        system.debug('getCustomerIdMap end');
        return result;
    }

    private static Map<Id, ASI_KOR_Sales_Order_Request__c> getSalesOrderRequestIdMap(
            List<ASI_KOR_Sales_Order_Transaction__c> triggerNew) {

        system.debug('getSalesOrderItemRequestMap start');

        Set<Id> salesOrderRequestIdSet = new Set<Id>();

        if(triggerNew != null && triggerNew.size() > 0) {
            for (ASI_KOR_Sales_Order_Transaction__c obj : triggerNew) {
                if (obj.ASI_KOR_Sales_Order_Request__c != null
                        && !salesOrderRequestIdSet.contains(obj.ASI_KOR_Sales_Order_Request__c)) {
                    salesOrderRequestIdSet.add(obj.ASI_KOR_Sales_Order_Request__c);
                }
            }
        }

        Map<Id, ASI_KOR_Sales_Order_Request__c> result =
                new Map<Id, ASI_KOR_Sales_Order_Request__c>();

        if(salesOrderRequestIdSet.size() > 0) {
            system.debug('Process to get sales order request by id set:' + salesOrderRequestIdSet);

            for (ASI_KOR_Sales_Order_Request__c request :
                [SELECT Id, ASI_CRM_SG_Order_Date__c, ASI_CRM_CN_Customer__c
                FROM ASI_KOR_Sales_Order_Request__c WHERE Id IN :salesOrderRequestIdSet]) {

                result.put(request.Id, request);
            }
        }
        system.debug('result:' + result);
        system.debug('getSalesOrderItemRequestMap end');
        return result;
    }

    private static void processSeason(
            List<ASI_KOR_Sales_Order_Transaction__c> triggerNew,
            Map<Id, ASI_KOR_Sales_Order_Request__c> salesOrderRequestIdMap,
            Map<Id, ASI_CRM_AccountsAdditionalField__c> customerIdMap,
            Map<Id, ASI_MFM_Item_Group__c> itemGroupIdMap) {

        system.debug('processSeason start');

        Date minDate = null;
        Date maxDate = null;
        List<String> regionList = new List<String>();

        for(ASI_KOR_Sales_Order_Transaction__c obj : triggerNew){

            if(obj.ASI_KOR_Sales_Order_Request__c != null
                    && salesOrderRequestIdMap != null
                    && !salesOrderRequestIdMap.isEmpty()
                    && customerIdMap != null
                    && !customerIdMap.isEmpty()) {

                ASI_KOR_Sales_Order_Request__c request = null;

                if(salesOrderRequestIdMap.containsKey(obj.ASI_KOR_Sales_Order_Request__c)
                        && salesOrderRequestIdMap.get(obj.ASI_KOR_Sales_Order_Request__c) != null) {

                    request = salesOrderRequestIdMap.get(obj.ASI_KOR_Sales_Order_Request__c);

                    if (request.ASI_CRM_SG_Order_Date__c != null) {

                        if (minDate == null || request.ASI_CRM_SG_Order_Date__c < minDate) {
                            minDate = request.ASI_CRM_SG_Order_Date__c;
                        }

                        if (maxDate == null || request.ASI_CRM_SG_Order_Date__c > maxDate) {
                            maxDate = request.ASI_CRM_SG_Order_Date__c;
                        }
                    }
                }

                if (request != null
                        && customerIdMap.containsKey(request.ASI_CRM_CN_Customer__c)
                        && customerIdMap.get(request.ASI_CRM_CN_Customer__c) != null
                        && String.isNotBlank(customerIdMap.get(request.ASI_CRM_CN_Customer__c).ASI_CRM_CN_Region__c)
                        && !regionList.contains(customerIdMap.get(request.ASI_CRM_CN_Customer__c).ASI_CRM_CN_Region__c)) {
                    regionList.add(customerIdMap.get(request.ASI_CRM_CN_Customer__c).ASI_CRM_CN_Region__c);
                }
            }
        }

        system.debug('minDate:' + minDate);
        system.debug('maxDate:' + maxDate);
        system.debug('regionList:' + regionList);

        Map<String, List<ASI_CRM_Season__c>> regionSeasonListMap =
                getRegionSeasonListMap(regionList, minDate, maxDate);

        if(regionSeasonListMap != null && !regionSeasonListMap.isEmpty()) {

            system.debug('Continue to process after retrieve regionSeasonListMap');

            for (ASI_KOR_Sales_Order_Transaction__c obj : triggerNew) {
                Date salesOrderRequestedDate = null;
                String customerRegion = null;
                String itemGroupCategory = null;
                Boolean itemGroupSelective = null;

                if (obj.ASI_KOR_Sales_Order_Request__c != null
                        && salesOrderRequestIdMap != null
                        && !salesOrderRequestIdMap.isEmpty()
                        && customerIdMap != null
                        && !customerIdMap.isEmpty()) {

                    ASI_KOR_Sales_Order_Request__c request = null;

                    if(salesOrderRequestIdMap.containsKey(obj.ASI_KOR_Sales_Order_Request__c)
                            && salesOrderRequestIdMap.get(obj.ASI_KOR_Sales_Order_Request__c) != null) {

                        request = salesOrderRequestIdMap.get(obj.ASI_KOR_Sales_Order_Request__c);

                        if (request.ASI_CRM_SG_Order_Date__c != null) {
                            salesOrderRequestedDate = request.ASI_CRM_SG_Order_Date__c;
                        }
                    }

                    if (request != null
                            && customerIdMap.containsKey(request.ASI_CRM_CN_Customer__c)
                            && customerIdMap.get(request.ASI_CRM_CN_Customer__c) != null
                            && String.isNotBlank(customerIdMap.get(request.ASI_CRM_CN_Customer__c).ASI_CRM_CN_Region__c)) {
                        customerRegion = customerIdMap.get(request.ASI_CRM_CN_Customer__c).ASI_CRM_CN_Region__c;
                    }
                }

                if (itemGroupIdMap != null
                        && !itemGroupIdMap.isEmpty()
                        && obj.ASI_CRM_CN_Product_Name__c != null
                        && itemGroupIdMap.containsKey(obj.ASI_CRM_CN_Product_Name__c)
                        && itemGroupIdMap.get(obj.ASI_CRM_CN_Product_Name__c) != null) {

                    ASI_MFM_Item_Group__c itemGroup = itemGroupIdMap.get(obj.ASI_CRM_CN_Product_Name__c);

                    if(itemGroup != null
                            && String.isNotBlank(itemGroup.ASI_CRM_Product_Category_JDE__c)) {
                        itemGroupCategory = itemGroup.ASI_CRM_Product_Category_JDE__c;
                    }
                    if(itemGroup != null
                            && itemGroup.ASI_CRM_Selective__c != null) {
                        itemGroupSelective = itemGroup.ASI_CRM_Selective__c;
                    }
                }

                system.debug('salesOrderRequestedDate:' + salesOrderRequestedDate);
                system.debug('customerRegion:' + customerRegion);
                system.debug('itemGroupCategory:' + itemGroupCategory);
                system.debug('itemGroupSelective:' + itemGroupSelective);
                system.debug('ASI_CRM_Traceability__c:' + obj.ASI_CRM_Traceability__c) ;

                obj.ASI_CRM_Season__c = false;

                if((String.isNotBlank(itemGroupCategory) && itemGroupCategory.equalsIgnoreCase('champagne'))
                        || (itemGroupSelective != null && itemGroupSelective)
                        || (obj.ASI_CRM_Traceability__c != null && obj.ASI_CRM_Traceability__c
                            && String.isNotBlank(itemGroupCategory) && itemGroupCategory.equalsIgnoreCase('wine'))) {

                    system.debug('Continue to process after pass itemGroupCategory, itemGroupSelective, ASI_CRM_Traceability__c');

                    if(regionSeasonListMap.containsKey(customerRegion)
                            && regionSeasonListMap.get(customerRegion) != null
                            && regionSeasonListMap.get(customerRegion).size() > 0) {

                        List<ASI_CRM_Season__c> seasonList = regionSeasonListMap.get(customerRegion);

                        for(ASI_CRM_Season__c season: seasonList) {
                            if(season.ASI_CRM_Start_Date__c != null
                                    && season.ASI_CRM_End_Date__c != null
                                    && salesOrderRequestedDate >= season.ASI_CRM_Start_Date__c
                                    && salesOrderRequestedDate <= season.ASI_CRM_End_Date__c) {
                                obj.ASI_CRM_Season__c = true;
                                system.debug('Sales order item is in active season');
                                break;
                            }
                        }
                    }
                }
            }
        }
        system.debug('processSeason end');
    }

    private static Map<String, List<ASI_CRM_Season__c>> getRegionSeasonListMap(
            List<String> regionList,
            Date startDate,
            Date endDate) {
        Map<String, List<ASI_CRM_Season__c>> regionSeasonListMap = new Map<String, List<ASI_CRM_Season__c>>();

        if(regionList != null && regionList.size() > 0
                && startDate != null && endDate != null) {

            List<ASI_CRM_Season__c> seasonList =
                [SELECT Id, Name, ASI_CRM_Region__c, ASI_CRM_Status__c, ASI_CRM_Start_Date__c, ASI_CRM_End_Date__c
                FROM ASI_CRM_Season__c
                WHERE ASI_CRM_Status__c='Active'
                AND ASI_CRM_Region__c IN :regionList
                AND ((ASI_CRM_Start_Date__c<=:startDate AND ASI_CRM_End_Date__c>=:endDate)
                OR (ASI_CRM_Start_Date__c>=:startDate AND ASI_CRM_End_Date__c<=:endDate)
                OR (ASI_CRM_Start_Date__c<=:startDate AND ASI_CRM_End_Date__c<=:endDate AND ASI_CRM_End_Date__c>=:startDate)
                OR (ASI_CRM_Start_Date__c>=:startDate AND ASI_CRM_End_Date__c>=:endDate AND ASI_CRM_Start_Date__c<=:endDate))
                ORDER BY ASI_CRM_Region__c ASC];

            if(seasonList.size() > 0) {
                for(ASI_CRM_Season__c season: seasonList) {
                    if(!regionSeasonListMap.containsKey(season.ASI_CRM_Region__c)) {
                        regionSeasonListMap.put(season.ASI_CRM_Region__c, new List<ASI_CRM_Season__c>());
                    }
                    List<ASI_CRM_Season__c> tmpSeasonList = regionSeasonListMap.get(season.ASI_CRM_Region__c);
                    if(!tmpSeasonList.contains(season)) {
                        tmpSeasonList.add(season);
                    }
                    regionSeasonListMap.put(season.ASI_CRM_Region__c, tmpSeasonList);
                }
            }
        }
        return regionSeasonListMap;
    }

    private static void processSalesOrderItemTraceability(List<ASI_KOR_Sales_Order_Transaction__c> triggerNew) {
        system.debug('Process traceability start');
        Set<Id> itemGroupIdList = new Set<Id>();

        for(ASI_KOR_Sales_Order_Transaction__c obj : triggerNew){

            if(obj.ASI_CRM_CN_Product_Name__c != null
                    && !itemGroupIdList.contains(obj.ASI_CRM_CN_Product_Name__c)) {
                itemGroupIdList.add(obj.ASI_CRM_CN_Product_Name__c);
            }

            obj.ASI_CRM_Traceability__c = false;
        }

        if(itemGroupIdList.size() > 0) {

            List<String> skuStatusList = new List<String>();
            skuStatusList.add('000');
            skuStatusList.add('001');
            skuStatusList.add('997');
            skuStatusList.add('998');
            system.debug('skuStatusList:' + skuStatusList);

            for(Integer index = 0; index < skuStatusList.size(); index++) {

                system.debug('Process sku status:' + skuStatusList.get(index));
                Map<Id, List<ASI_MFM_SKU_Code__c>> itemGroupIdSkuMap =
                        getItemGroupIdSkuMap(itemGroupIdList, skuStatusList.get(index));

                if (itemGroupIdSkuMap != null && !itemGroupIdSkuMap.isEmpty()) {

                    system.debug('Continue to process after retrieve itemGroupIdSkuMap');

                    for (ASI_KOR_Sales_Order_Transaction__c obj : triggerNew) {

                        if (obj.ASI_CRM_CN_Product_Name__c != null
                                && !obj.ASI_CRM_Traceability__c
                                && itemGroupIdSkuMap.containsKey(obj.ASI_CRM_CN_Product_Name__c)
                                && itemGroupIdSkuMap.get(obj.ASI_CRM_CN_Product_Name__c) != null
                                && itemGroupIdSkuMap.get(obj.ASI_CRM_CN_Product_Name__c).size() > 0) {
                            obj.ASI_CRM_Traceability__c = true;
                        }
                    }
                }
            }
        }
        system.debug('Process traceability end');
    }

    private static Map<Id, List<ASI_MFM_SKU_Code__c>> getItemGroupIdSkuMap(
            Set<Id> itemGroupIdList,
            String skuStatus) {

        Map<Id, List<ASI_MFM_SKU_Code__c>> itemGroupIdSkuMap = new Map<Id, List<ASI_MFM_SKU_Code__c>>();

        if(itemGroupIdList != null && itemGroupIdList.size() > 0 && String.isNotBlank(skuStatus)) {

            List<ASI_MFM_SKU_Code__c> skuList = [
                    SELECT Id, ASI_CRM_SKU_Status__c, ASI_CRM_Traceability_Puma__c, ASI_MFM_Item_Group__c
                    FROM ASI_MFM_SKU_Code__c
                    WHERE ASI_MFM_Item_Group__c IN :itemGroupIdList
                    AND ASI_CRM_SKU_Status__c = :skuStatus
                    AND ASI_CRM_Traceability_Puma__c != null
                    AND ASI_CRM_Traceability_Puma__c != ''
                    ORDER BY ASI_MFM_Item_Group__c ASC
            ];

            if (skuList.size() > 0) {
                for (ASI_MFM_SKU_Code__c sku : skuList) {
                    if (!itemGroupIdSkuMap.containsKey(sku.ASI_MFM_Item_Group__c)) {
                        itemGroupIdSkuMap.put(sku.ASI_MFM_Item_Group__c, new List<ASI_MFM_SKU_Code__c>());
                    }
                    List<ASI_MFM_SKU_Code__c> tmpSkuList = itemGroupIdSkuMap.get(sku.ASI_MFM_Item_Group__c);
                    if(!tmpSkuList.contains(sku)) {
                        tmpSkuList.add(sku);
                    }
                    itemGroupIdSkuMap.put(sku.ASI_MFM_Item_Group__c, tmpSkuList);
                }
            }
        }
        return itemGroupIdSkuMap;
    }
    // 20190725 Wilson Chow end

    Public Static Void beforeUpsertMethod(List<ASI_KOR_Sales_Order_Transaction__c> triggerNew){
        Set<ID> headerId = new Set<ID>();
        Set<ID> customerId = new Set<ID>();
        Set<ID> IHBRCusomterID = new Set<ID>();
        Set<ID> orderFormId = new Set<ID>();
        List<ASI_KOR_Sales_Order_Request__c> headerList = new List<ASI_KOR_Sales_Order_Request__c>();
        List<ASI_CRM_Order_Form_Customer_Relationship__c> ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
        List<ASI_CRM_Order_Form_Detail__c> orderFormItem = new List<ASI_CRM_Order_Form_Detail__c>();
        Map<Id, Id> mapOrderForm = new Map<Id, Id>();
        Map<Id, Id> mapRTDOrderForm = new Map<Id, Id>();
        Map<Id, Id> mapPremiumOrderForm = new Map<Id, Id>();//20161019 Ben @ ELufa
        Map<Id, Id> mapCustomer = new Map<Id, Id>();
        Map<Id, String> mapOfHeaderToCustomerType = new Map<Id, String>(); //20181121 Alan Lau
        Map<Id, Id> mapIHBRCustomer = new Map<Id, Id>();
        Map<Id, Map<id, ASI_CRM_Order_Form_Detail__c>> RTDItem = new Map<Id, Map<id, ASI_CRM_Order_Form_Detail__c>>();
        Map<Id, Map<id, ASI_CRM_Order_Form_Detail__c>> NormalItem = new Map<Id, Map<id, ASI_CRM_Order_Form_Detail__c>>();
        Map<Id, Map<id, ASI_CRM_Order_Form_Detail__c>> PremiumItem = new Map<Id, Map<id, ASI_CRM_Order_Form_Detail__c>>();//20161019 Ben @ Elufa
        Map<Id, Map<Id, ASI_CRM_Order_Form_Detail__c>> mapOrderFormItem = new Map<Id, Map<Id, ASI_CRM_Order_Form_Detail__c>>();
        List<ASI_CRM_Item_Group_Customer_Price__c> itemGroupCustomerPrice = new List<ASI_CRM_Item_Group_Customer_Price__c>();
        Map<Id, Map<Id, ASI_CRM_Item_Group_Customer_Price__c>> mapCustomerPrice = new Map<Id, Map<Id, ASI_CRM_Item_Group_Customer_Price__c>>();
        Map<Id, Map<Id, ASI_CRM_Item_Group_Customer_Price__c>> mapIHBRCustomerPrice = new Map<Id, Map<Id, ASI_CRM_Item_Group_Customer_Price__c>>();
        Date todayDate = Date.today();

        for(ASI_KOR_Sales_Order_Transaction__c obj : triggerNew){
            headerId.add(obj.ASI_KOR_Sales_Order_Request__c);
        }
        headerList = [SELECT id
                , ASI_CRM_CN_RTD__c
                , ASI_CRM_CN_Premium__c
                , ASI_CRM_CN_Customer__c
                , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
                , ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                , ASI_CRM_CN_Customer__r.ASI_CRM_Customer_Type_Picklist__c //20181121 Alan Lau
                , ASI_CRM_SG_Order_Date__c
        FROM ASI_KOR_Sales_Order_Request__c
        WHERE ID IN : headerId
        AND ASI_KOR_Order_Status__c LIKE 'Open'
        ];

        if(headerList.size() > 0){

            for(ASI_KOR_Sales_Order_Request__c obj : headerList){
                mapOfHeaderToCustomerType.put(obj.Id, obj.ASI_CRM_CN_Customer__r.ASI_CRM_Customer_Type_Picklist__c);

                if(!obj.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c){
                    mapCustomer.put(obj.id, obj.ASI_CRM_CN_Customer__c);
                    customerId.add(obj.ASI_CRM_CN_Customer__c);
                }else{
                    mapIHBRCustomer.put(obj.id, obj.ASI_CRM_CN_Customer__c);
                    IHBRCusomterID.add(obj.ASI_CRM_CN_Customer__c);
                }
            }

            itemGroupCustomerPrice = [SELECT ASI_CRM_Customer__c
                    , ASI_CRM_Item_Group__c
                    , ASI_CRM_Price_Type__c
                    , ASI_CRM_Promotion_Code__c
                    , ASI_CRM_Promotion_Expiration_Date__c
                    , ASI_CRM_Unit_Price_BT__c
                    , ASI_CRM_Promotion_Code__r.Name
                    , ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c
                    , ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c
                    , ASI_CRM_Promotion_Code__r.ASI_CRM_Discount__c
                    , ASI_CRM_Effective_Date_To__c //20161124 Elufa
                    , ASI_CRM_Item_Group__r.ASI_CRM_Allocation_Information__c //20170206 Elufa
                    //add by alex 2019-12-11 start
                    , Id
                    , ASI_CRM_Price_And_Discount__c 
                    , ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c
                    , ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c
                    , ASI_CTY_CN_WS_Trade_a_p_Discount__c 
                    , ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Effective_To__c
                    , ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Effective_From__c
                    , ASI_CTY_CN_WS_Normal_Discount__c 
                    , ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Effective_To__c
                    , ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Effective_From__c
                    , ASI_CTY_CN_WS_AD_Discount__c 
                    , ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Effective_To__c
                    , ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Effective_From__c
                    //add by alex 2019-12-11 end
            FROM ASI_CRM_Item_Group_Customer_Price__c
            WHERE (ASI_CRM_Customer__c IN : mapCustomer.values()
            OR ASI_CRM_Customer__c IN : mapIHBRCustomer.values()
            )
            ];

            if(itemGroupCustomerPrice.size() > 0){

                for(ASI_CRM_Item_Group_Customer_Price__c obj : itemGroupCustomerPrice){
                    Map<Id, ASI_CRM_Item_Group_Customer_Price__c> tmpMap = new Map<Id, ASI_CRM_Item_Group_Customer_Price__c>();

                    if(obj.ASI_CRM_Promotion_Expiration_Date__c < todayDate){
                        obj.ASI_CRM_Promotion_Code__c = NULL;
                    }
                    if(customerId.contains(obj.ASI_CRM_Customer__c)){
                        if(mapCustomerPrice.containsKey(obj.ASI_CRM_Customer__c))
                            tmpMap = mapCustomerPrice.get(obj.ASI_CRM_Customer__c);

                        tmpMap.put(obj.ASI_CRM_Item_Group__c, obj);

                        mapCustomerPrice.put(obj.ASI_CRM_Customer__c, tmpMap);
                    }else if(IHBRCusomterID.contains(obj.ASI_CRM_Customer__c)){

                        if(mapIHBRCustomerPrice.containsKey(obj.ASI_CRM_Customer__c))
                            tmpMap = mapIHBRCustomerPrice.get(obj.ASI_CRM_Customer__c);

                        tmpMap.put(obj.ASI_CRM_Item_Group__c, obj);

                        mapIHBRCustomerPrice.put(obj.ASI_CRM_Customer__c, tmpMap);
                    }
                }
            }

            ofcrList = [SELECT id
                    , ASI_CRM_Customer__c
                    , ASI_CRM_Order_Form__c
                    , ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c
            FROM ASI_CRM_Order_Form_Customer_Relationship__c
            WHERE ( ASI_CRM_Customer__c IN : mapCustomer.values()
                    //OR ASI_CRM_Customer__c IN : mapIHBRCustomer.values()
            )
            AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship'
            ];

            if(ofcrList.size() > 0){

                for(ASI_CRM_Order_Form_Customer_Relationship__c obj : ofcrList){

                    if(obj.ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c == 'Normal Item'){

                        mapOrderForm.put(obj.ASI_CRM_Customer__c, obj.ASI_CRM_Order_Form__c);
                    }else if(obj.ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c == 'RTD'){

                        mapRTDOrderForm.put(obj.ASI_CRM_Customer__c, obj.ASI_CRM_Order_Form__c);
                    }else if(obj.ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c == 'Premium'){//20161019 Ben @ Elufa

                        mapPremiumOrderForm.put(obj.ASI_CRM_Customer__c, obj.ASI_CRM_Order_Form__c);
                    }//20161019 End
                    orderFormId.add(obj.ASI_CRM_Order_Form__c);
                }

                orderFormItem = [SELECT id
                        , ASI_CRM_Order_Form__c
                        , ASI_CRM_Product_Name__c
                        , ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c
                        , ASI_CRM_Remark__c
                        , ASI_CRM_Product_Name__r.ASI_CRM_Allocation_Information__c //20170206 Elufa
                FROM ASI_CRM_Order_Form_Detail__c
                WHERE ASI_CRM_Order_Form__c IN : orderFormId
                ];

                if(orderFormItem.size() > 0){
                    for(ASI_CRM_Order_Form_Detail__c obj : orderFormItem){
                        if(obj.ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c == 'RTD'){

                            Map<Id, ASI_CRM_Order_Form_Detail__c> itemGroupId = new Map<Id, ASI_CRM_Order_Form_Detail__c>();

                            if(RTDItem.containsKey(obj.ASI_CRM_Order_Form__c))
                                itemGroupId = RTDItem.get(obj.ASI_CRM_Order_Form__c);

                            itemGroupId.put(obj.ASI_CRM_Product_Name__c, obj);

                            RTDItem.put(obj.ASI_CRM_Order_Form__c, itemGroupId);
                        }else if(obj.ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c == 'Normal Item'){

                            Map<Id, ASI_CRM_Order_Form_Detail__c> itemGroupId = new Map<Id, ASI_CRM_Order_Form_Detail__c>();

                            if(NormalItem.containsKey(obj.ASI_CRM_Order_Form__c))
                                itemGroupId = NormalItem.get(obj.ASI_CRM_Order_Form__c);

                            itemGroupId.put(obj.ASI_CRM_Product_Name__c, obj);

                            NormalItem.put(obj.ASI_CRM_Order_Form__c, itemGroupId);
                        }else if(obj.ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c == 'Premium'){//20161019 Ben @ Elufa

                            Map<Id, ASI_CRM_Order_Form_Detail__c> itemGroupId = new Map<Id, ASI_CRM_Order_Form_Detail__c>();

                            if(PremiumItem.containsKey(obj.ASI_CRM_Order_Form__c))
                                itemGroupId = PremiumItem.get(obj.ASI_CRM_Order_Form__c);

                            itemGroupId.put(obj.ASI_CRM_Product_Name__c, obj);

                            PremiumItem.put(obj.ASI_CRM_Order_Form__c, itemGroupId);
                        }
                    }
                }
            }
            for(ASI_KOR_Sales_Order_Request__c obj : headerList){
                if(mapRTDOrderForm.containsKey(obj.ASI_CRM_CN_Customer__c) && RTDItem.containsKey(mapRTDOrderForm.get(obj.ASI_CRM_CN_Customer__c)) && obj.ASI_CRM_CN_RTD__c){
                    mapOrderFormItem.put(obj.id, RTDItem.get(mapRTDOrderForm.get(obj.ASI_CRM_CN_Customer__c)));
                }else if(mapPremiumOrderForm.containsKey(obj.ASI_CRM_CN_Customer__c) && PremiumItem.containsKey(mapPremiumOrderForm.get(obj.ASI_CRM_CN_Customer__c)) && obj.ASI_CRM_CN_Premium__c){//20161019 Ben @ Elufa
                    mapOrderFormItem.put(obj.id, PremiumItem.get(mapPremiumOrderForm.get(obj.ASI_CRM_CN_Customer__c)));
                }else if(mapOrderForm.containsKey(obj.ASI_CRM_CN_Customer__c) && NormalItem.containsKey(mapOrderForm.get(obj.ASI_CRM_CN_Customer__c)) && !obj.ASI_CRM_CN_RTD__c && !obj.ASI_CRM_CN_Premium__c){
                    mapOrderFormItem.put(obj.id, NormalItem.get(mapOrderForm.get(obj.ASI_CRM_CN_Customer__c)));
                }
            }
        }

        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMap = createLineItemPriceAndDiscountDetailMap(triggerNew, headerList, mapCustomer); //20181101 Alan Lau

        //2019/10/27 CanterDuan 获取最新的汇率 
        /*List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        if (!taxRateList.isEmpty()) {
          taxRate = taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }*/

        //add by alex 2019-12-11 start
        //get different type discounts of customer price
        Map<String, Map<String, Decimal>> customerPriceDiscountMap = getCustomerPriceDiscountMap(itemGroupCustomerPrice);
        //add by alex 2019-12-11 end

        for(ASI_KOR_Sales_Order_Transaction__c salesOrderRequestItem : triggerNew){

            if(mapCustomer.containsKey(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)){
                if(mapOrderFormItem.containsKey(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) && !mapOrderFormItem.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c)){
                    salesOrderRequestItem.addError('Invalid Item Group');
                    break;
                }else if(mapOrderFormItem.containsKey(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) && mapOrderFormItem.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c)){

                    if(trigger.isInsert)//20170206 Elufa
                        salesOrderRequestItem.ASI_CRM_Allocation_Information__c = mapOrderFormItem.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Product_Name__r.ASI_CRM_Allocation_Information__c;

                    salesOrderRequestItem.ASI_CRM_CN_Remark__c = mapOrderFormItem.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Remark__c;
                    if(mapCustomerPrice.containsKey(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c))){
                        //salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c = mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Unit_Price_BT__c * 1.13 : NULL; //20180426 Introv Changed tax rate from 17% to 16%//20190415 Laputa Andy changed Tax Rate from 16% to 13%
                        //salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c = mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Unit_Price_BT__c * (1+(salesOrderRequestItem.ASI_CRM_CN_Tax_Rate__c != 0 && salesOrderRequestItem.ASI_CRM_CN_Tax_Rate__c != null ? salesOrderRequestItem.ASI_CRM_CN_Tax_Rate__c : 13)/100) : NULL; //2019/10/27 CanterDuan将税率修改调整为配置的形式
                        if(mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) && mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Unit_Price_BT__c != null){
                            salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c = mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Unit_Price_BT__c * (1+(salesOrderRequestItem.ASI_CRM_CN_Tax_Rate__c != 0 && salesOrderRequestItem.ASI_CRM_CN_Tax_Rate__c != null ? salesOrderRequestItem.ASI_CRM_CN_Tax_Rate__c : 13)/100);
                        }else{
                            salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c = null;
                        }

                        //add by alex 2019-12-11 start add the relationship
                        ASI_CRM_Item_Group_Customer_Price__c customerPrice = mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) : null;
                        salesOrderRequestItem.ASI_CTY_CN_WS_Item_Group_Customer_Price__c = customerPrice != null ? customerPrice.Id : NULL;
                        Decimal discountRate = 0;
                        if (customerPriceDiscountMap.containsKey(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c)) {
                            //discount
                            if (customerPriceDiscountMap.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).get('discountRate') != null ) {
                                discountRate = customerPriceDiscountMap.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).get('discountRate');
                            }
                            //amount
                            if (customerPriceDiscountMap.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).get('discountPrice') != null && 
                                salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c != null) {
                                discountRate = discountRate + (customerPriceDiscountMap.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).get('discountPrice')) / (salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c) * 100;
                            }
                        }
                        salesOrderRequestItem.ASI_CTY_CN_WS_Disount_Rate__c = discountRate > 0 ? discountRate : null;
                        //if get x buy y and qty > x || discount% type
                        if (customerPrice != null && customerPrice.ASI_CRM_Promotion_Code__c != null) {
                            if (customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Discount__c != null ) {
                                salesOrderRequestItem.ASI_CTY_CN_WS_Promotion_Rate__c = customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Discount__c;
                            } else {
                                salesOrderRequestItem.ASI_CTY_CN_WS_Promotion_Rate__c = customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c.divide((customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c + customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c), 6);
                            }
                        }
                        //add by alex 2019-12-11 end


                        salesOrderRequestItem.ASI_CRM_CN_Promotion_Code__c = (mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) && salesOrderRequestItem.ASI_CRM_Sales_Order_Request_Item__c == null) ? mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Promotion_Code__c : NULL;
                        salesOrderRequestItem.ASI_CRM_CN_Unit_Price_Source__c = mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Price_Type__c : NULL;
                        salesOrderRequestItem.ASI_CRM_CN_Promotion_Expiration_Date__c = mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapCustomerPrice.get(mapCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Promotion_Expiration_Date__c : NULL;
                    }

                    setMotPrice(mapOfHeaderToCustomerType, salesOrderRequestItem, lineItemPriceAndDiscountDetailMap); //20181122 Alan Lau


                    if (salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c == null && 'MOT' != mapOfHeaderToCustomerType.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)) { //20181105 Alan Lau
                        salesOrderRequestItem.addError('There is no Unit Price(Btl) with VAT.');
                        break;
                    } else if (salesOrderRequestItem.ASI_CRM_MOT_Price_non_VAT__c == null && 'MOT' == mapOfHeaderToCustomerType.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)) {
                        salesOrderRequestItem.addError('There is no MOT Price (non-VAT).');
                        break;
                    }
                }
            }else if(mapIHBRCustomer.containsKey(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) && mapIHBRCustomerPrice.containsKey(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c))){

                if(trigger.isInsert)//20170206 Elufa
                    salesOrderRequestItem.ASI_CRM_Allocation_Information__c = mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Item_Group__r.ASI_CRM_Allocation_Information__c : False;

                //salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c = mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Unit_Price_BT__c * 1.13 : NULL; //20180426 Introv Changed tax rate from 17% to 16%//20190415 Laputa Andy changed Tax Rate from 16% to 13%
                salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c = mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Unit_Price_BT__c * (1+(salesOrderRequestItem.ASI_CRM_CN_Tax_Rate__c != 0 && salesOrderRequestItem.ASI_CRM_CN_Tax_Rate__c != null ? salesOrderRequestItem.ASI_CRM_CN_Tax_Rate__c : 13)/100) : NULL; //2019/10/27CanterDuan将税率修改调整为配置的形式
                salesOrderRequestItem.ASI_CRM_CN_Promotion_Code__c = (mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) && salesOrderRequestItem.ASI_CRM_Sales_Order_Request_Item__c == null) ? mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Promotion_Code__c : NULL;
                salesOrderRequestItem.ASI_CRM_CN_Unit_Price_Source__c = mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Price_Type__c : NULL;
                salesOrderRequestItem.ASI_CRM_CN_Promotion_Expiration_Date__c = mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Promotion_Expiration_Date__c : NULL;
                //20161124 Elufa
                salesOrderRequestItem.ASI_CRM_Effective_Date_To__c = mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Effective_Date_To__c : NULL;
                
                //add by alex 2019-12-11 start add the relationship
                ASI_CRM_Item_Group_Customer_Price__c customerPrice = mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? mapIHBRCustomerPrice.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)).get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c): NULL;
                salesOrderRequestItem.ASI_CTY_CN_WS_Item_Group_Customer_Price__c = customerPrice != null ? customerPrice.Id : NULL;
                Decimal discountRate = 0;
                if (customerPriceDiscountMap.containsKey(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c)) {
                    if (customerPriceDiscountMap.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).get('discountRate') != null ) {
                        discountRate = customerPriceDiscountMap.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).get('discountRate');
                    }

                    if (customerPriceDiscountMap.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).get('discountPrice') != null && 
                        salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c != null) {
                        discountRate = discountRate + ((customerPriceDiscountMap.get(mapIHBRCustomer.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c) + '' + salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).get('discountPrice')) / (salesOrderRequestItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c) * 100);
                    }
                }
                salesOrderRequestItem.ASI_CTY_CN_WS_Disount_Rate__c = discountRate > 0 ? discountRate : null;
                //if get x buy y and qty > x || discount% type
                if (customerPrice != null && customerPrice.ASI_CRM_Promotion_Code__c != null) {
                    if (customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Discount__c != null ) {
                        salesOrderRequestItem.ASI_CTY_CN_WS_Promotion_Rate__c = customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Discount__c;
                    } else {
                        salesOrderRequestItem.ASI_CTY_CN_WS_Promotion_Rate__c = customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c.divide((customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c + customerPrice.ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c), 6);
                    }
                }
                //add by alex 2019-12-11 end
            }
        }

    }

    private static  Map<String, Map<String, Decimal>> getCustomerPriceDiscountMap(List<ASI_CRM_Item_Group_Customer_Price__c> itemGroupCustomerPrice){
        Set<Id> customerIds = new Set<Id>();
        Set<Id> priceDiscounts = new Set<Id>();
        for (ASI_CRM_Item_Group_Customer_Price__c customerPrice : itemGroupCustomerPrice) {
            // trade a&p discount
            if (customerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__c != null 
                && customerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Effective_To__c >= Date.today()
                 && customerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Effective_From__c <= Date.today()) {
                priceDiscounts.add(customerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__c);
                customerIds.add(customerPrice.ASI_CRM_Customer__c);
            }
            //normal discount
            if (customerPrice.ASI_CTY_CN_WS_Normal_Discount__c != null 
                && customerPrice.ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Effective_To__c >= Date.today() 
                 && customerPrice.ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Effective_From__c <= Date.today()) {
                priceDiscounts.add(customerPrice.ASI_CTY_CN_WS_Normal_Discount__c);
                customerIds.add(customerPrice.ASI_CRM_Customer__c);
            }
            //a&d discount
            if (customerPrice.ASI_CTY_CN_WS_AD_Discount__c != null 
                && customerPrice.ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Effective_To__c >= Date.today() 
                 && customerPrice.ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Effective_From__c <= Date.today()) {
                priceDiscounts.add(customerPrice.ASI_CTY_CN_WS_AD_Discount__c);
                customerIds.add(customerPrice.ASI_CRM_Customer__c);
            }
        }
        
        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetails = [SELECT id
                                                               , ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c
                                                               , ASI_CRM_Promotion_Code__c 
                                                               , ASI_CRM_Promotion_Code__r.ASI_CRM_Type__c 
                                                               , ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c 
                                                               , ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c 
                                                               , ASI_CRM_Promotion_Code__r.ASI_CRM_Discount__c
                                                               , ASI_CRM_Item_Group_Description__c
                                                               , ASI_CTY_CN_WS_Level1_Promotion_Code__c
                                                               , ASI_CTY_CN_WS_Value_Type__c
                                                               , ASI_CTY_CN_WS_Disount_Value__c
                                                               , ASI_CRM_Price_And_Discount__r.RecordType.Name
                                                               FROM ASI_CRM_Price_And_Discount_Detail__c
                                                              WHERE ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c IN :customerIds 
                                                                AND ASI_CRM_Price_And_Discount__c IN :priceDiscounts];
        Map<String, Map<String, Decimal>> customerPriceDiscountMap = new Map<String, Map<String, Decimal>>();
        for (ASI_CRM_Price_And_Discount_Detail__c priceDiscountDetail : priceAndDiscountDetails) {
            Id customerId = priceDiscountDetail.ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c;
            if (!customerPriceDiscountMap.containsKey(priceDiscountDetail.ASI_CRM_Item_Group_Description__c)) {
                customerPriceDiscountMap.put(customerId+ '' + priceDiscountDetail.ASI_CRM_Item_Group_Description__c, new Map<String, Decimal>());
            }
            //trade a&p discount,normal discount, a&d discount
            String recordTypeName = priceDiscountDetail.ASI_CRM_Price_And_Discount__r.RecordType.Name;
            if (recordTypeName.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P)
                || recordTypeName.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL)
                || recordTypeName.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD)) {
                Decimal discountRate = 0;
                Decimal discountPrice = 0;
                if (priceDiscountDetail.ASI_CTY_CN_WS_Value_Type__c == ASI_CTY_CN_WS_Utils.VALUE_TYPE_PERCENT){// % base price
                    discountRate = priceDiscountDetail.ASI_CTY_CN_WS_Disount_Value__c;
                } else {// add a amount
                    discountPrice = priceDiscountDetail.ASI_CTY_CN_WS_Disount_Value__c;
                }
                
                Map<String, Decimal> discountMap = customerPriceDiscountMap.get(customerid + '' + priceDiscountDetail.ASI_CRM_Item_Group_Description__c);
                if (discountRate != 0) {
                    discountMap.put('discountRate', discountMap.containsKey('discountRate') ? discountMap.get('discountRate') + discountRate : discountRate);
                } else {
                    discountMap.put('discountPrice', discountMap.containsKey('discountPrice') ? discountMap.get('discountPrice') + discountPrice : discountPrice);
                }
                
                customerPriceDiscountMap.put(customerId + '' + priceDiscountDetail.ASI_CRM_Item_Group_Description__c, discountMap);
            }
        }
        System.debug(LoggingLevel.INFO, '*** customerPriceDiscountMap: ' + customerPriceDiscountMap);
        return customerPriceDiscountMap;
    }

    private static void setMotPrice(Map<Id, String> mapOfHeaderToCustomerType, ASI_KOR_Sales_Order_Transaction__c salesOrderRequestItem, Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMap) { //20181122 Alan Lau
        if ('MOT' == mapOfHeaderToCustomerType.get(salesOrderRequestItem.ASI_KOR_Sales_Order_Request__c)) {
            salesOrderRequestItem.ASI_CRM_MOT_Price_non_VAT__c = lineItemPriceAndDiscountDetailMap.containsKey(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c) ? lineItemPriceAndDiscountDetailMap.get(salesOrderRequestItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_New_Price_BT_non_VAT__c : null; //20181121 Alan Lau
        } else {
            salesOrderRequestItem.ASI_CRM_MOT_Price_non_VAT__c = null;
            salesOrderRequestItem.ASI_CRM_MOT_Promotion_Price_non_VAT__c = null;
        }
    }

    private static Map<Id, ASI_CRM_Price_And_Discount_Detail__c> createLineItemPriceAndDiscountDetailMap(List<ASI_KOR_Sales_Order_Transaction__c> lineItemList, List<ASI_KOR_Sales_Order_Request__c> salesOrderHeaderList, Map<Id, Id> mapCustomer) { //20181121 Alan Lau
        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMap = new Map<Id, ASI_CRM_Price_And_Discount_Detail__c>();

        List<String> lineItemProductNameList = getFieldValueList(lineItemList, 'ASI_CRM_CN_Product_Name__c');
        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = getPriceAndDiscountDetailList(salesOrderHeaderList, lineItemProductNameList);

        for (ASI_KOR_Sales_Order_Transaction__c lineItem : lineItemList) {
            for (ASI_CRM_Price_And_Discount_Detail__c priceAndDiscountDetail : priceAndDiscountDetailList) {
                if (priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c == lineItem.ASI_CRM_CN_Product_Name__c && priceAndDiscountDetail.ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c == mapCustomer.get(lineItem.ASI_KOR_Sales_Order_Request__c)) {
                    lineItemPriceAndDiscountDetailMap.put(lineItem.ASI_CRM_CN_Product_Name__c, priceAndDiscountDetail);
                    break;
                }
            }
        }

        return lineItemPriceAndDiscountDetailMap;
    }

    private static List<ASI_CRM_Price_And_Discount_Detail__c> getPriceAndDiscountDetailList(List<ASI_KOR_Sales_Order_Request__c> salesOrderHeaderList, List<String> lineItemProductNameList) { //20181121 Alan Lau

        Date today = Date.today();
        List<String> customerList = getFieldValueList(salesOrderHeaderList, 'ASI_CRM_CN_Customer__c');

        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = [
                SELECT ASI_CRM_Item_Group_Description__c
                        , ASI_CRM_New_Price_BT_non_VAT__c
                        , ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c
                FROM ASI_CRM_Price_And_Discount_Detail__c
                WHERE recordtypeid = :Global_RecordTypeCache.getRtID('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c IN :customerList
                AND ASI_CRM_Item_Group_Description__c IN :lineItemProductNameList
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c <= :today
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c >= :today
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Status__c = 'Completed'
                AND ASI_CRM_New_Price_BT_non_VAT__c != NULL
                ORDER BY ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c DESC
        ];

        return priceAndDiscountDetailList;
    }

    private static List<String> getFieldValueList(List<SObject> objectList, String fieldName) { //20181121 Alan Lau
        List<String> fieldValueList = new List<String>();

        for (SObject objectInList : objectList) {
            fieldValueList.add((String) objectInList.get(fieldName));
        }

        return fieldValueList;
    }
    
    //2019/11/6 CanterDuan 添加功能：新增TOV时，获取最新的税率
    public static void GetTaxRate(List<ASI_KOR_Sales_Order_Transaction__c> triggerNew){
        //获取税率信息
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c 
                                                                                        FROM ASI_CRM_CN_Tax_Rate_Config__c 
                                                                                        ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        if(taxRateList.isEmpty()) return;
        for(ASI_KOR_Sales_Order_Transaction__c tov: triggerNew){
            tov.ASI_CRM_CN_Tax_Rate__c = taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }
    }
    //2019/11/6 END 


    /*Public Static Map<String, ASI_CRM_Item_Group_Allocation__c> calculateRemainingQty(List<ASI_KOR_Sales_Order_Transaction__c> triggerNew, Set<id> regionSet, Set<Id> itemGroupSet, Set<String> commercialTeamSet, Date Startdate, Date endDate){
        
        Startdate = date.newInstance(Startdate.year(), Startdate.month(), 1);
        endDate = date.newInstance(endDate.year(), endDate.month(), date.daysInMonth(endDate.year(), endDate.month()));
        Set<Id> allocatedItemGroup = new Set<Id>();
        Map<String, ASI_CRM_Item_Group_Allocation__c> allocationMap = new Map<String, ASI_CRM_Item_Group_Allocation__c>();
        
        List<ASI_CRM_Item_Group_Allocation__c> allocationList = new List<ASI_CRM_Item_Group_Allocation__c>([SELECT id
                                                                                                            , ASI_CRM_Allocation_Quantity_Bottle__c
                                                                                                            , ASI_CRM_Commercial_Team__c
                                                                                                            , ASI_CRM_Effective_Date__c
                                                                                                            , ASI_CRM_Item_Group__c
                                                                                                            , ASI_CRM_Region__c
                                                                                                            , ASI_CRM_MTD_Order_Quantity__c
                                                                                                            FROM ASI_CRM_Item_Group_Allocation__c
                                                                                                            WHERE ASI_CRM_Effective_Date__c >= : startDate
                                                                                                            AND ASI_CRM_Effective_Date__c <= : endDate
                                                                                                            AND ASI_CRM_Item_Group__c IN : itemGroupSet
                                                                                                            AND ASI_CRM_Region__c IN : regionSet
                                                                                                            AND recordType.developerName Like '%_CN_%'
                                                                                                           ]);
        
        for(ASI_CRM_Item_Group_Allocation__c allocationItem : allocationList){
            
            String Key = '' + allocationItem.ASI_CRM_Item_Group__c + allocationItem.ASI_CRM_Region__c + allocationItem.ASI_CRM_Commercial_Team__c + String.valueOf(date.newInstance(allocationITem.ASI_CRM_Effective_Date__c.year(), allocationITem.ASI_CRM_Effective_Date__c.month(), 1));
            
            allocatedItemGroup.add(allocationItem.ASI_CRM_Item_Group__c);
            
            allocationItem.ASI_CRM_MTD_Order_Quantity__c = 0;
            allocationMap.put(Key, allocationItem);
        }
        
        List<ASI_KOR_Sales_Order_Transaction__c> allSOLines = new List<ASI_KOR_Sales_Order_Transaction__c>([SELECT id
                                                                                                            , ASI_CRM_CN_Product_Name__c
                                                                                                            , ASI_CRM_Order_Qty_Bottle__c
                                                                                                            , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                                                                            , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                                                                            , ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c
                                                                                                            , ASI_KOR_Sales_Order_Request__c
                                                                                                            FROM ASI_KOR_Sales_Order_Transaction__c
                                                                                                            WHERE ASI_CRM_CN_Product_Name__c IN : allocatedItemGroup
                                                                                                            AND id NOT IN : triggerNew
                                                                                                            AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c IN : regionSet
                                                                                                            AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c IN : commercialTeamSet
                                                                                                            AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c >= : startDate
                                                                                                            AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c <= : endDate
                                                                                                            AND (NOT ASI_KOR_Sales_Order_Request__r.ASI_KOR_Order_Status__c Like 'Open')
                                                                                                            AND RecordType.developerName Like '%_CN_%'
                                                                                                           ]);
        
        for(ASI_KOR_Sales_Order_Transaction__c obj : allSOLines){
            
            String key = '' + obj.ASI_CRM_CN_Product_Name__c + obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));
            
            if(allocationMap.containsKey(Key)){
                ASI_CRM_Item_Group_Allocation__c tmp = allocationMap.get(Key);
                tmp.ASI_CRM_MTD_Order_Quantity__c = tmp.ASI_CRM_MTD_Order_Quantity__c + obj.ASI_CRM_Order_Qty_Bottle__c;
                allocationMap.put(Key, tmp);
            }
        }
        
        Return allocationMap;
    }*/
}