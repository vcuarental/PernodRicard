/***************************************************************************************************************************
* Name:        ASI_CRM_CN_Inventory_Visibility_Schedule
* Description: Apex Scheduler for ASI_CRM_Inventory_Visibility
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-12-03       Alan Lau                Created
* 2019-08-15    	Vincent Lam        		[VL 1.0] IM004740: Rename status "DP Metro warehouse" to "DP MOT_Banner"
****************************************************************************************************************************/

global class ASI_CRM_CN_Inventory_Visibility_Schedule implements Database.Batchable<AggregateResult>, Database.Stateful, Schedulable {

    private final static List<String> OPERATION_TYPE_EXCLUSION_LIST = new List<String>{
            'PO Add Duty', 'PO Add IE', 'PO Add Consumer Tax'
    };
    private final static List<String> API_TYPE_EXCLUSION_LIST = new List<String>{
            'PWC_IN_IRF_4', 'PWC_IN_IDF_8', 'PWC_UP_JDE_PO_2'
    };
    private final static List<String> API_TYPE_OPEN_PO = new List<String>{
            'JDE_IN_PO_1'
    };

    private final static List<String> API_TYPE_PENDING_PO_FOR_CALCULATION = new List<String>{
            'PWC_IN_IDF_8', '3PL_IN_TAX_12'
    };

    private final String OPERATION_TYPE_DUTY_PAID = 'Duty Paid';
    private final String OPERATION_TYPE_DUTY_FREE = 'Duty Free';
    private final String OPERATION_TYPE_DP = 'PO Move to DP';
    private final String OPERATION_TYPE_PENDING = 'PO Move to Pending';
    private final String OPERATION_TYPE_DF = 'PO Move to DF';
    private final String OPERATION_TYPE_IN_TRANSIT = 'PO Intransit';
    private final String OPERATION_TYPE_OPEN_PO = 'OPEN PO';
    private final String RTID_INVENTORYVISIBILITYFINAL = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility__cASI_CRM_CN_Inventory_Visibility_Summary');

    private final String RTID_INVENTORYVISIBILITYRAW = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility__cASI_CRM_CN_Inventory_Visibility');

    private final String RTID_INVENTORYVISIBILITYDETAIL = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility__cASI_CRM_CN_Inventory_Visibility_Detail');


    private final String EXTERNAL_ID_PREFIX = 'CN_Summary_';

    private List<ASI_CRM_CN_InventoryVisibilityWarehouse__mdt> inventoryVisibilityWarehouses = [
            SELECT ASI_CRM_Location__c,
                    ASI_CRM_Warehouse_Code__c,
                    ASI_CRM_Status__c
            FROM ASI_CRM_CN_InventoryVisibilityWarehouse__mdt
    ];

    private Map<String, String> mapOfWarehouseCodeToLocation = new Map<String, String>();
    private Map<String, String> mapOfWarehouseCodeLocationToStatus = new Map<String, String>();

    public Map<string, ASI_CRM_CN_InventoryVisibilityWarehouse__mdt> map_warehouse = new Map<string, ASI_CRM_CN_InventoryVisibilityWarehouse__mdt>();


    public Map<String, Map<String, Decimal>> mapOfItemGroupLocationToPurchaseQuantityByOperationTypeStatus = new Map<String, Map<String, Decimal>>();

    //    First key = item_group + location, Second key = API type => (e.g. 'PWC_IN_IDF_8' / '3PL_IN_TAX_12')
    public Map<String, Map<String, List<AggregateResult>>> map_pendingPO_ar = new Map<String, Map<String, List<AggregateResult>>>();

    public Set<String> item_group_key_set = new Set<String>();

    public set<string> set_externalIDupsert = new set<string>();

    public set<string> processed_key_set = new set<string>();
    public set<string> processed_key_set_OPENPO_itemGroup = new set<string>();
    public set<string> processed_key_set_OPENPO_poNumber = new set<string>();
    public set<string> processed_key_set_OPENPO_itemGroup_poNumber = new set<string>();


    global ASI_CRM_CN_Inventory_Visibility_Schedule() {

        map_warehouse = getWarehouse();

        //delete [select id from ASI_CRM_Inventory_Visibility__c where recordtypeId = :RTID_INVENTORYVISIBILITYFINAL];

        for (ASI_CRM_CN_InventoryVisibilityWarehouse__mdt inventoryVisibilityWarehouse : inventoryVisibilityWarehouses) {
//            String warehouseCodeStatus = String.isBlank(inventoryVisibilityWarehouse.ASI_CRM_Status__c) ? inventoryVisibilityWarehouse.ASI_CRM_Warehouse_Code__c + '_' : inventoryVisibilityWarehouse.ASI_CRM_Warehouse_Code__c + '_' + inventoryVisibilityWarehouse.ASI_CRM_Status__c;
            String warehouseCodeLocation = inventoryVisibilityWarehouse.ASI_CRM_Warehouse_Code__c + '_' + inventoryVisibilityWarehouse.ASI_CRM_Location__c;

            if (!mapOfWarehouseCodeToLocation.containsKey(inventoryVisibilityWarehouse.ASI_CRM_Warehouse_Code__c)) {
                mapOfWarehouseCodeToLocation.put(inventoryVisibilityWarehouse.ASI_CRM_Warehouse_Code__c, inventoryVisibilityWarehouse.ASI_CRM_Location__c);
            }

            if (!mapOfWarehouseCodeLocationToStatus.containsKey(warehouseCodeLocation)) {
                mapOfWarehouseCodeLocationToStatus.put(warehouseCodeLocation, (String.isBlank(inventoryVisibilityWarehouse.ASI_CRM_Status__c) ? '' : inventoryVisibilityWarehouse.ASI_CRM_Status__c));
            }
        }

    }

    public static Map<string, ASI_CRM_CN_InventoryVisibilityWarehouse__mdt> getWarehouse() {
        Map<string, ASI_CRM_CN_InventoryVisibilityWarehouse__mdt> map_warehouse = new Map<string, ASI_CRM_CN_InventoryVisibilityWarehouse__mdt>();

        for (ASI_CRM_CN_InventoryVisibilityWarehouse__mdt w : [
                select ASI_CRM_Location__c, ASI_CRM_Status__c, ASI_CRM_Warehouse_Code__c
                from ASI_CRM_CN_InventoryVisibilityWarehouse__mdt
        ]) {
            map_warehouse.put(w.ASI_CRM_Warehouse_Code__c, w);

        }

        return map_warehouse;
    }

    global Iterable<AggregateResult> start(Database.BatchableContext contextInstance) {
        return new AggregateResultIterable();
    }

    global void execute(Database.BatchableContext contextInstance, List<AggregateResult> aggregateResultList) {
		List<ASI_CRM_Inventory_Visibility__c> inventoryVisibilityUpsertList = new List<ASI_CRM_Inventory_Visibility__c>();

        processed_key_set = new set<string>();
        processed_key_set_OPENPO_itemGroup = new set<string>();
        processed_key_set_OPENPO_poNumber = new set<string>();
        processed_key_set_OPENPO_itemGroup_poNumber = new set<string>();
		
		getMapOfItemGroupLocationToPurchaseQuantityByOperationTypeStatus(mapOfItemGroupLocationToPurchaseQuantityByOperationTypeStatus, aggregateResultList);

        Map<String, decimal> map_openPOsubtractQty = getOpenPOsubtractQty(processed_key_set_OPENPO_itemGroup, processed_key_set_OPENPO_poNumber);
		
				system.debug('processed_key_set_OPENPO_itemGroup: ' + processed_key_set_OPENPO_itemGroup);
				system.debug('processed_key_set_OPENPO_poNumber: ' + processed_key_set_OPENPO_poNumber);
				system.debug(map_openPOsubtractQty);

        for (String key : mapOfItemGroupLocationToPurchaseQuantityByOperationTypeStatus.keySet()) {

            List<String> headerFields = key.split('_');
            String itemGroupId = headerFields.get(0);
            String subBrandId = headerFields.get(1);
            String brandId = headerFields.get(2);
            String location = headerFields.size() == 4 ? headerFields.get(3) : '';

            String key1 = itemGroupId + '_' + location;

            if(processed_key_set.contains(key1)){

                //Decimal subtractQty = map_openPOsubtractQty.containsKey(key1) ? map_openPOsubtractQty.get(key1) : 0;
				Decimal subtractQty = 0;
				for(string key2 : map_openPOsubtractQty.keySet()){
					list<string> key2_attr = key2.split('_');
					if(key2_attr[0] == itemGroupId && key2_attr[1] == location && processed_key_set_OPENPO_itemGroup_poNumber.contains(key2_attr[0] + '_' + key2_attr[2])){
						subtractQty += map_openPOsubtractQty.get(key2);
					}
				}

                Map<String, Decimal> mapOfOperationTypeStatusToPurchaseQuantity = mapOfItemGroupLocationToPurchaseQuantityByOperationTypeStatus.get(key);

                Decimal dpNormalWarehousePurchaseQuantity = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(OPERATION_TYPE_DUTY_PAID + '_' + 'DP Normal warehouse') ? mapOfOperationTypeStatusToPurchaseQuantity.get(OPERATION_TYPE_DUTY_PAID + '_' + 'DP Normal warehouse') : 0;
                Decimal dpIBHRPurchaseQuantity = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(OPERATION_TYPE_DUTY_PAID + '_' + 'DP IHBR') ? mapOfOperationTypeStatusToPurchaseQuantity.get(OPERATION_TYPE_DUTY_PAID + '_' + 'DP IHBR') : 0;
                /* [VL 1.0] BEGIN */
				/*
				Decimal dpMetroWarehousePurchaseQuantity = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(OPERATION_TYPE_DUTY_PAID + '_' + 'DP Metro warehouse') ? mapOfOperationTypeStatusToPurchaseQuantity.get(OPERATION_TYPE_DUTY_PAID + '_' + 'DP Metro warehouse') : 0;
						*/
				Decimal dpMetroWarehousePurchaseQuantity = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(OPERATION_TYPE_DUTY_PAID + '_' + 'DP MOT_Banner') ? mapOfOperationTypeStatusToPurchaseQuantity.get(OPERATION_TYPE_DUTY_PAID + '_' + 'DP MOT_Banner') : 0;
				/* [VL 1.0] END */
                Decimal dpECWarehousePurchaseQuantity = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(OPERATION_TYPE_DUTY_PAID + '_' + 'DP EC warehouse') ? mapOfOperationTypeStatusToPurchaseQuantity.get(OPERATION_TYPE_DUTY_PAID + '_' + 'DP EC warehouse') : 0;
                Decimal dpD2CPurchaseQuantity = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(OPERATION_TYPE_DUTY_PAID + '_' + 'DP D2C') ? mapOfOperationTypeStatusToPurchaseQuantity.get(OPERATION_TYPE_DUTY_PAID + '_' + 'DP D2C') : 0;
                Decimal dpVIPWarehousePurchaseQuantity = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(OPERATION_TYPE_DUTY_PAID + '_' + 'DP VIP warehouse') ? mapOfOperationTypeStatusToPurchaseQuantity.get(OPERATION_TYPE_DUTY_PAID + '_' + 'DP VIP warehouse') : 0;

                //Decimal pendingPurchaseQuantity = getQuantityFromTheDifferenceBetweenTwoOperationType(mapOfOperationTypeStatusToPurchaseQuantity, OPERATION_TYPE_PENDING, OPERATION_TYPE_DP);

                Map<String, List<AggregateResult>> map_pendingPO_apiType_ar = map_pendingPO_ar.get(key1);

                Decimal pendingPurchaseQuantity = 0;

                if(map_pendingPO_apiType_ar != null){
                    Decimal sum_PWC_IN_IDF_8 = 0;

                    List<AggregateResult> list_PWC_IN_IDF_8_ar = map_pendingPO_apiType_ar.get('PWC_IN_IDF_8') != null ? map_pendingPO_apiType_ar.get('PWC_IN_IDF_8') : new List<AggregateResult>();
                    for(AggregateResult ar : list_PWC_IN_IDF_8_ar){
                        sum_PWC_IN_IDF_8 += (Decimal) ar.get('purchase_quantity');
                    }

                    Decimal sum_3PL_IN_TAX_12 = 0;

                    List<AggregateResult> list_3PL_IN_TAX_12_ar = map_pendingPO_apiType_ar.get('3PL_IN_TAX_12') != null ? map_pendingPO_apiType_ar.get('3PL_IN_TAX_12') : new List<AggregateResult>();
                    for(AggregateResult ar : list_3PL_IN_TAX_12_ar){
                        sum_3PL_IN_TAX_12 += (Decimal) ar.get('purchase_quantity');
                    }

                    pendingPurchaseQuantity = sum_PWC_IN_IDF_8 - sum_3PL_IN_TAX_12;
                }

                Decimal dutyFreePurchaseQuantity = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(OPERATION_TYPE_DUTY_FREE) ? mapOfOperationTypeStatusToPurchaseQuantity.get(OPERATION_TYPE_DUTY_FREE): 0;

                dutyFreePurchaseQuantity -= pendingPurchaseQuantity;

                Decimal inTransitPurchaseQuantity = getQuantityFromTheDifferenceBetweenTwoOperationType(mapOfOperationTypeStatusToPurchaseQuantity, OPERATION_TYPE_IN_TRANSIT, OPERATION_TYPE_DF);
                Decimal openPOPurchaseQuantity = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(OPERATION_TYPE_OPEN_PO) ? mapOfOperationTypeStatusToPurchaseQuantity.get(OPERATION_TYPE_OPEN_PO) : 0;
                openPOPurchaseQuantity -= subtractQty;
				mapOfOperationTypeStatusToPurchaseQuantity.put(OPERATION_TYPE_OPEN_PO, openPOPurchaseQuantity);
				
				system.debug(key1);
				system.debug(subtractQty);

                try{

                    ASI_CRM_Inventory_Visibility__c inventoryVisibility = new ASI_CRM_Inventory_Visibility__c(
                            ASI_CRM_Item_Group__c = itemGroupId,
                            ASI_CRM_Location_Text__c = location,
                            ASI_CRM_Open_PO__c = openPOPurchaseQuantity,
                            ASI_CRM_In_transit__c = inTransitPurchaseQuantity,
                            ASI_CRM_DF__c = dutyFreePurchaseQuantity,
                            ASI_CRM_Pending__c = pendingPurchaseQuantity,
                            ASI_CRM_DP_Normal_warehouse__c = dpNormalWarehousePurchaseQuantity,
                            ASI_CRM_DP_IHBR__c = dpIBHRPurchaseQuantity,
                            ASI_CRM_DP_Metro_warehouse__c = dpMetroWarehousePurchaseQuantity,
                            ASI_CRM_DP_EC_warehouse__c = dpECWarehousePurchaseQuantity,
                            ASI_CRM_DP_D2C__c = dpD2CPurchaseQuantity,
                            ASI_CRM_DP_VIP_warehouse__c = dpVIPWarehousePurchaseQuantity,
                            ASI_CRM_Sub_brand__c = subBrandId,
                            ASI_CRM_Brand__c = brandId,
                            RecordTypeId = RTID_INVENTORYVISIBILITYFINAL,
                            ASI_CRM_External_ID__c = EXTERNAL_ID_PREFIX + key

                    );
					system.debug(inventoryVisibility);

                    set_externalIDupsert.add(EXTERNAL_ID_PREFIX + key);

                    inventoryVisibilityUpsertList.add(inventoryVisibility);
                }catch (Exception e){
                    system.debug(e);
                }

            }
        }

            upsert inventoryVisibilityUpsertList ASI_CRM_External_ID__c;
        try{
        }catch (exception e){

        }

    }

    global void finish(Database.BatchableContext contextInstance) {

        List<ASI_CRM_Inventory_Visibility__c> deleteList = [select id from ASI_CRM_Inventory_Visibility__c where recordtypeId = :RTID_INVENTORYVISIBILITYFINAL and ASI_CRM_External_ID__c not in :set_externalIDupsert];

        system.debug('** deleteList size: ' + deleteList.size());

        delete deleteList;

    }

    private void getMapOfItemGroupLocationToPurchaseQuantityByOperationTypeStatus(Map<String, Map<String, Decimal>> mapOfItemGroupLocationToPurchaseQuantityByOperationType, List<AggregateResult> aggregateResultList) {

        List<String> list_pendingPO_poNumber = new List<String>();
        List<String> list_itemGroup = new List<String>();

        for (AggregateResult aggregateResult : aggregateResultList) {

            String poNumber = (String) aggregateResult.get('po_number');
            String itemGroupId = (String) aggregateResult.get('itemGroup');

            list_pendingPO_poNumber.add(poNumber);
            list_itemGroup.add(itemGroupId);
			
			

//            String status = String.isBlank((String) aggregateResult.get('status')) ? '' : (String) aggregateResult.get('status');
            String location = mapOfWarehouseCodeToLocation.containsKey((String) aggregateResult.get('wh_to')) ? mapOfWarehouseCodeToLocation.get((String) aggregateResult.get('wh_to')) : '';
            String key = (String) aggregateResult.get('itemGroup') + '_' + (String) aggregateResult.get('subBrand') + '_' + (String) aggregateResult.get('brand') + '_' + location;
            String operationType = (String) aggregateResult.get('operation_type');
            Decimal purchaseQuantity = (Decimal) aggregateResult.get('purchase_quantity');
			
            processed_key_set.add(itemGroupId + '_' + location);

			processed_key_set_OPENPO_itemGroup.add(itemGroupId);
			processed_key_set_OPENPO_poNumber.add(poNumber);
			processed_key_set_OPENPO_itemGroup_poNumber.add(itemGroupId + '_' + poNumber);

            if (!OPERATION_TYPE_DUTY_PAID.equals(operationType)) {
                if (mapOfItemGroupLocationToPurchaseQuantityByOperationType.containsKey(key)) {
                    Map<String, Decimal> mapOfOperationTypeStatusToPurchaseQuantity = mapOfItemGroupLocationToPurchaseQuantityByOperationType.get(key);
                    decimal oldQty = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(operationType) ? mapOfOperationTypeStatusToPurchaseQuantity.get(operationType) : 0;
                    mapOfOperationTypeStatusToPurchaseQuantity.put(operationType, purchaseQuantity + oldQty);
                    mapOfItemGroupLocationToPurchaseQuantityByOperationType.put(key, mapOfOperationTypeStatusToPurchaseQuantity);
                } else {
                    mapOfItemGroupLocationToPurchaseQuantityByOperationType.put(key, new Map<String, Decimal>{
                            operationType => purchaseQuantity
                    });
                }
            } else {
                String dpStatus = mapOfWarehouseCodeLocationToStatus.get((String) aggregateResult.get('wh_to') + '_' + location);
                String operationTypeStatus = operationType + '_' + dpStatus;
                if (mapOfItemGroupLocationToPurchaseQuantityByOperationType.containsKey(key)) {
                    Map<String, Decimal> mapOfOperationTypeStatusToPurchaseQuantity = mapOfItemGroupLocationToPurchaseQuantityByOperationType.get(key);
                    decimal oldQty = mapOfOperationTypeStatusToPurchaseQuantity.containsKey(operationTypeStatus) ? mapOfOperationTypeStatusToPurchaseQuantity.get(operationTypeStatus) : 0;
                    mapOfOperationTypeStatusToPurchaseQuantity.put(operationTypeStatus, purchaseQuantity + oldQty);
                    mapOfItemGroupLocationToPurchaseQuantityByOperationType.put(key, mapOfOperationTypeStatusToPurchaseQuantity);
                } else {
                    mapOfItemGroupLocationToPurchaseQuantityByOperationType.put(key, new Map<String, Decimal>{
                            operationTypeStatus => purchaseQuantity
                    });
                }
            }

        }

        if(list_itemGroup.size()>0){
            map_pendingPO_ar = get_pendingPO_ar(map_pendingPO_ar, list_pendingPO_poNumber, list_itemGroup);
        }

    }

    public Map<String, Map<String, List<AggregateResult>>> get_pendingPO_ar(map<String, Map<String, List<AggregateResult>>> map_pendingPO_ar, List<String> list_pendingPO_poNumber, List<String> list_itemGroup) {

        //Map<String, Map<String, AggregateResult>> map_pendingPO_ar = new Map<String, Map<String, AggregateResult>>();

        for (AggregateResult ar : [
                select
                //ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c poNumber,
                        ASI_CRM_Item_Group__c itemGroup,
                        ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c warehouse,
                        //ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c date,
                        ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c apiType,
                        //ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c subBrand,
                        //ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c brand,
                        //ASI_CRM_UOM__c uom,
                        sum(ASI_CRM_Purchase_QTY__c) purchase_quantity
                from
                        ASI_CRM_Inventory_Visibility_Detail__c
                where
                ASI_CRM_Inventory_Visibility__r.recordtypeId = :RTID_INVENTORYVISIBILITYRAW
                //and ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c in :list_pendingPO_poNumber
				and ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c <> null
                and ASI_CRM_Item_Group__c in :list_itemGroup
                and ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c in :API_TYPE_PENDING_PO_FOR_CALCULATION
                group by
                        //ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c,
                                ASI_CRM_Item_Group__c ,
                                ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c ,
                                //ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c ,
                                ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c
                //ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c,
                //ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c,
                //ASI_CRM_UOM__c
        ]) {
            String warehouse = (String) ar.get('warehouse');
            ASI_CRM_CN_InventoryVisibilityWarehouse__mdt mdt;
            if(map_warehouse.containsKey(warehouse)){
                mdt = map_warehouse.get(warehouse);
            }

            String location = mdt != null ? mdt.ASI_CRM_Location__c : '';

            //String poNumber = (String) ar.get('poNumber');
            String itemGroup = (String) ar.get('itemGroup');
            String apiType = (String) ar.get('apiType');
            String key = itemGroup + '_' + location;

            //
            String item_group_key = itemGroup  + '_' + warehouse + '_' + apiType;

            // subKey = poNumber;

            Map<String, List<AggregateResult>> map_pendingPO_apiType_ar = map_pendingPO_ar.containsKey(key) ? map_pendingPO_ar.get(key) : new Map<String, List<AggregateResult>>();

            List<AggregateResult> list_ar = map_pendingPO_apiType_ar.containsKey(apiType) ? map_pendingPO_apiType_ar.get(apiType) : new List<AggregateResult>();

            if(!item_group_key_set.contains(item_group_key)){
                list_ar.add(ar);
                item_group_key_set.add(item_group_key);
            }

            map_pendingPO_apiType_ar.put(apiType, list_ar);
            map_pendingPO_ar.put(key, map_pendingPO_apiType_ar);
        }

        return map_pendingPO_ar;
    }


    /**
     * Get difference of 2 operation types' purchase quantity
     * ( 1st operation type qty - 2nd operation type qty )
     * @param mapOfOperationTypeToPurchaseQuantity (Map) map of Operation Type to Purchase Quantity
     * @param firstOperationType (String) 1st Operation Type
     * @param secondOperationType (String) 2nd Operation Type
     */
    private Decimal getQuantityFromTheDifferenceBetweenTwoOperationType(Map<String, Decimal> mapOfOperationTypeToPurchaseQuantity, String firstOperationType, String secondOperationType) {
        Decimal firstOperationTypePurchaseQuantity = mapOfOperationTypeToPurchaseQuantity.get(firstOperationType);
        Decimal secondOperationTypePurchaseQuantity = mapOfOperationTypeToPurchaseQuantity.get(secondOperationType);
        Decimal purchaseQuantity = (firstOperationTypePurchaseQuantity != null ? firstOperationTypePurchaseQuantity - (secondOperationTypePurchaseQuantity != null ? secondOperationTypePurchaseQuantity : 0) : 0 ) ;

        return purchaseQuantity;
    }

    global class AggregateResultIterable implements Iterable<AggregateResult> {

        List<ASI_CRM_Inventory_Visibility__c> inventoryVisibilityList = ASI_CRM_CN_Inventory_Visibility_Schedule.getInventoryVisibilityList('ASI_CRM_CN_Inventory_Visibility');
        List<String> inventoryVisibilityIdList = ASI_CRM_CN_Inventory_Visibility_Schedule.getStringFieldList(inventoryVisibilityList, 'Id');

        global Iterator<AggregateResult> iterator() {
            return new AggregateResultIterator(inventoryVisibilityIdList);
        }

    }

    global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results { get; set; }
        Integer index { get; set; }

        global AggregateResultIterator(List<String> inventoryVisibilityIdList) {
            index = 0;
            results = [
                    SELECT
                            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Operation_Type__c operation_type,
                            SUM(ASI_CRM_Purchase_QTY__c) purchase_quantity,
                            ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c wh_to,
//                            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Status__c status,
                            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c subBrand,
                            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c brand,
                            ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c po_number,
                            ASI_CRM_Item_Group__c itemGroup
                    FROM ASI_CRM_Inventory_Visibility_Detail__c
                    WHERE ASI_CRM_Inventory_Visibility__c IN :inventoryVisibilityIdList
                    AND ASI_CRM_Item_Group__c != NULL
                    GROUP BY ASI_CRM_Inventory_Visibility__r.ASI_CRM_Operation_Type__c,
                            ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c,
//                            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Status__c,
                            ASI_CRM_Item_Group__c,
                            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c,
                            ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c,
                            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c
            ];

        }

        global Boolean hasNext() {
            return results != null && !results.isEmpty() && index < results.size();
        }

        global AggregateResult next() {
            return results[index++];
        }
    }

    global void execute(SchedulableContext ctx) {

    }

    public static List<ASI_CRM_Inventory_Visibility__c> getInventoryVisibilityList(String recordTypeDeveloperName) {
        List<ASI_CRM_Inventory_Visibility__c> inventoryVisibilityList = [
                SELECT Id,
                        Name,
                        ASI_CRM_PO_Number__c,
                        ASI_CRM_Goods_Type__c,
                        ASI_CRM_Operation_Type__c,
                        ASI_CRM_PO_Type__c,
                        ASI_CRM_WH_Code_From__c,
                        ASI_CRM_WH_Code_To__c,
                        ASI_CRM_Request_ETA_Date__c,
                        ASI_CRM_Purchase_QTY__c,
                        ASI_CRM_Available_Date__c,
                        ASI_CRM_Bottling_Date__c,
                        ASI_CRM_SKU__c,
                        ASI_CRM_Item_Group__c,
                        ASI_CRM_Sub_brand__c,
                        ASI_CRM_Original_Doc_Number__c,
                        ASI_CRM_SC_AVA__c
                FROM ASI_CRM_Inventory_Visibility__c
                WHERE ASI_CRM_Operation_Type__c NOT IN :OPERATION_TYPE_EXCLUSION_LIST
                AND ASI_CRM_API_Type__c NOT IN :API_TYPE_EXCLUSION_LIST
                AND RecordType.DeveloperName = :recordTypeDeveloperName
        ];
        return inventoryVisibilityList;
    }

    public static List<String> getStringFieldList(List<SObject> sObjectList, String fieldName) {
        List<String> StringFieldList = new List<String>();

        for (SObject sObj : sObjectList) {
            if (String.isNotBlank((String) sObj.get(fieldName)) && StringFieldList.indexOf((String) sObj.get(fieldName)) < 0) {
                StringFieldList.add((String) sObj.get(fieldName));
            }

        }

        return StringFieldList;
    }

    public Map<String, decimal> getOpenPOsubtractQty(set<string> list_itemGroup, set<string> list_poNumber) {
        Map<String, decimal> map_qty = new Map<String, decimal>();

        for (aggregateResult ar : [
                select
                        ASI_CRM_Item_Group__c itemGroup,
                        ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c wh,
						ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c poNumber,
                        sum(ASI_CRM_Purchase_QTY__c) qty
                from
                        ASI_CRM_Inventory_Visibility_Detail__c
                where
                ASI_CRM_Inventory_Visibility__r.recordtypeId = :Global_RecordTypeCache.getRTId('ASI_CRM_Inventory_Visibility__cASI_CRM_CN_Inventory_Visibility')
                and ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c in :API_TYPE_OPEN_PO
				and ASI_CRM_Item_Group__c in :list_itemGroup
				and ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c in :list_poNumber
                group by
                                ASI_CRM_Item_Group__c,
                                ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c,
						ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c 
								
        ]) {

            String wh = String.valueOf(ar.get('wh'));
            String itemGroup = String.valueOf(ar.get('itemGroup'));
            String poNumber = String.valueOf(ar.get('poNumber'));
            String key = itemGroup + '_' + (mapOfWarehouseCodeToLocation.containsKey(wh) ? mapOfWarehouseCodeToLocation.get(wh) : '') + '_' + poNumber;
            decimal qty = (Decimal) ar.get('qty');
			decimal oldQty = map_qty.containsKey(key) ? map_qty.get(key) : 0;
            map_qty.put(key, qty + oldQty);

        }

        return map_qty;
    }
}