/***************************************************************************************************************************
* Name:        ASI_CRM_CN_InventoryVisibilityDetail_Job
* Description: Apex Scheduler for ASI_CRM_Inventory_Visibility
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-02-12       vincent Lam             Created
****************************************************************************************************************************/

global class ASI_CRM_CN_InventoryVisibilityDetail_Job implements Database.Batchable<AggregateResult>, Database.Stateful, Schedulable {

    //private final String OPERATION_TYPE_SALES_ORDER = 'SALES ORDER';
    //private final String OPERATION_TYPE_STO = 'STO';
    private final String OPERATION_TYPE_DP = 'Duty Paid';
    private final String OPERATION_TYPE_MOVE_TO_DP = 'PO Move to DP';
    private final String OPERATION_TYPE_PENDING = 'PO Move to Pending';
    private final String OPERATION_TYPE_DF = 'Duty Free';
    private final String OPERATION_TYPE_MOVE_TO_DF = 'PO Move to DF';
    private final String OPERATION_TYPE_IN_TRANSIT = 'PO Intransit';
    private final String OPERATION_TYPE_OPEN_PO = 'OPEN PO';
  private final String STATUS_OPEN_PO = '1. OPEN PO';
  private final String STATUS_IN_TRANSIT = '2. IN-TRANSIT';
  private final String STATUS_DUTY_FREE = '3. Duty Free';
  private final String STATUS_PENDING = '4. PENDING';
  private final String STATUS_DUTY_PAID = '5. Duty Paid';
  private final String RTID_INVENTORYVISIBILITYDETAIL = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility__cASI_CRM_CN_Inventory_Visibility_Detail');
  private final String RTID_INVENTORYVISIBILITYRAW = Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility__cASI_CRM_CN_Inventory_Visibility');
  private final String EXTERNAL_ID_PREFIX = 'CN_Detail_';
  private final String PWC_IN_IDF_8 = 'PWC_IN_IDF_8';

    private final static List<String> OPERATION_TYPE_EXCLUSION_LIST = new List<String>{
            'PO Add Duty', 'PO Add IE', 'PO Add Consumer Tax', 'PO Move to Pending', 'PO Move to DP'
    };
    private final static List<String> API_TYPE_EXCLUSION_LIST = new List<String>{
            'PWC_IN_IRF_4', 'PWC_IN_IDF_8', 'PWC_UP_JDE_PO_2'
    };
    private final static List<String> API_TYPE_PENDING_PO_FOR_DATE = new List<String>{
            'PWC_IN_IDF_8'
    };
    private final static List<String> API_TYPE_PENDING_PO_FOR_CALCULATION = new List<String>{
            'PWC_IN_IDF_8', '3PL_IN_TAX_12'
    };
    private final static List<String> API_TYPE_OPEN_PO = new List<String>{
            'JDE_IN_PO_1'
    };

    private final Map<String, String> MAP_OF_OPERATION_TYPE_TO_STATUS = new Map<String, String>{
            OPERATION_TYPE_OPEN_PO => STATUS_OPEN_PO,
            OPERATION_TYPE_IN_TRANSIT => STATUS_IN_TRANSIT,
            OPERATION_TYPE_MOVE_TO_DF => STATUS_IN_TRANSIT,
            OPERATION_TYPE_DF => STATUS_DUTY_FREE,
            //OPERATION_TYPE_PENDING => STATUS_PENDING,
            //OPERATION_TYPE_MOVE_TO_DP => STATUS_PENDING,
            OPERATION_TYPE_DP => STATUS_DUTY_PAID
    };

    private final Map<String, boolean> MAP_OF_OPERATION_TYPE_TO_ADD = new Map<String, boolean>{
            OPERATION_TYPE_OPEN_PO => true,
            OPERATION_TYPE_IN_TRANSIT => true,
            OPERATION_TYPE_MOVE_TO_DF => false,
            OPERATION_TYPE_DF => true,
            //OPERATION_TYPE_PENDING => true,
            OPERATION_TYPE_MOVE_TO_DP => false,
            OPERATION_TYPE_DP => true
    };

    private final List<String> LIST_NEED_DATE_KEY = new List<String>{
            STATUS_OPEN_PO,
            //STATUS_PENDING,
            STATUS_IN_TRANSIT
    };

  public Map<string, ASI_CRM_CN_InventoryVisibilityWarehouse__mdt> map_warehouse = new Map<string, ASI_CRM_CN_InventoryVisibilityWarehouse__mdt>();
    public Map<String, wrapper> map_wrappers = new Map<String, wrapper>();
  public set<string> set_externalIDupsert = new set<string>();
    public Map<String, Map<String, ASI_CRM_Inventory_Visibility__c>> mapOfSysKeyForAggregationToInventoryVisibilityByOperationType = new Map<String, Map<String, ASI_CRM_Inventory_Visibility__c>>();
  public set<string> set_rawUniqueKey = new set<string>();
  public set<string> set_proceededDF = new set<string>();

    public string inputLocation;

  global ASI_CRM_CN_InventoryVisibilityDetail_Job(){
    // delete [select id from ASI_CRM_Inventory_Visibility__c where recordtypeId = :RTID_INVENTORYVISIBILITYDETAIL];
    map_warehouse = getWarehouse();
  }
  
	global ASI_CRM_CN_InventoryVisibilityDetail_Job(string location){
		// delete [select id from ASI_CRM_Inventory_Visibility__c where recordtypeId = :RTID_INVENTORYVISIBILITYDETAIL];
		map_warehouse = getWarehouse();
        inputLocation = location;
	}
	
    global Iterable<AggregateResult> start(Database.BatchableContext contextInstance) {
        return new AggregateResultIterable(inputLocation);
    }

    global void execute(Database.BatchableContext contextInstance, List<AggregateResult> aggregateResultList) {

        map_wrappers = buildWrappers(map_wrappers, aggregateResultList);
    }

    private Map<String, wrapper> buildWrappers(Map<String, wrapper> map_wrappers,List<AggregateResult> aggregateResultList) {

    Map<String, wrapper> map_wrappersInExecute = new Map<String, wrapper>();
    map<string, date> map_poNumber_pendingDate = new map<string, date>();
    map<string, map<string, map<string, List<AggregateResult>>>> map_pendingPO_ar = new map<string, map<string, map<string, List<AggregateResult>>>>();
    List<string> list_pendingPO_poNumber = new List<string>();
    List<string> list_location = new List<string>();
    List<string> list_itemGroup = new List<string>();
    map<string, decimal> map_openPO_poNumber_subtract = new map<string, decimal>();
    List<string> list_openPO_poNumber = new List<string>();
    
    for (AggregateResult aggregateResult : aggregateResultList){
      String operationType = (String) aggregateResult.get('operation_type');
      String poNumber = (String) aggregateResult.get('po_number');
      String itemGroupId = (String) aggregateResult.get('itemGroup');
      String warehouse = (String) aggregateResult.get('warehouse');
      String status = MAP_OF_OPERATION_TYPE_TO_STATUS.containsKey(operationType) ? MAP_OF_OPERATION_TYPE_TO_STATUS.get(operationType) : '';
      /*
      if(status == STATUS_PENDING){
        list_pendingPO_poNumber.add(poNumber);
      }
      */
	  ASI_CRM_CN_InventoryVisibilityWarehouse__mdt mdt;
      if(map_warehouse.containsKey(warehouse)){
        mdt = map_warehouse.get(warehouse);
      }
      String location = mdt != null ? mdt.ASI_CRM_Location__c : '';
	  
      list_pendingPO_poNumber.add(poNumber);
      list_itemGroup.add(itemGroupId);
      list_location.add(location);
      if(status == STATUS_OPEN_PO){
        list_openPO_poNumber.add(poNumber);
      }
    }
    if(list_pendingPO_poNumber.size()>0){
      map_poNumber_pendingDate = get_poNumber_pendingDate(list_pendingPO_poNumber, list_itemGroup, list_location);
    }
    if(list_itemGroup.size()>0){
      map_pendingPO_ar = get_pendingPO_ar(list_pendingPO_poNumber, list_itemGroup);
    }
    if(list_openPO_poNumber.size()>0){
      map_openPO_poNumber_subtract = get_openPO_poNumber_subtract(list_openPO_poNumber, list_itemGroup);
    }
  
        for (AggregateResult aggregateResult : aggregateResultList) {
      String warehouse = (String) aggregateResult.get('warehouse');
            ASI_CRM_CN_InventoryVisibilityWarehouse__mdt mdt;
      if(map_warehouse.containsKey(warehouse)){
        mdt = map_warehouse.get(warehouse);
      }
      String location = mdt != null ? mdt.ASI_CRM_Location__c : '';
      String poNumber = (String) aggregateResult.get('po_number');
      String itemGroupId = (String) aggregateResult.get('itemGroup');
      String subBrandId = (String) aggregateResult.get('subBrand');
      String brandId = (String) aggregateResult.get('brand');
      String operationType = (String) aggregateResult.get('operation_type');
      String uom = (String) aggregateResult.get('uom');
      String status = '';
      if(operationType == OPERATION_TYPE_DP && mdt != null && mdt.ASI_CRM_Status__c != null){
        status = mdt.ASI_CRM_Status__c;
      } else {
        status = MAP_OF_OPERATION_TYPE_TO_STATUS.containsKey(operationType) ? MAP_OF_OPERATION_TYPE_TO_STATUS.get(operationType) : '';
      }
      Date dateValue = null;
      Date estimatedDate = null;
      Decimal subtractQty = 0;
      if(status == STATUS_OPEN_PO){
        dateValue = (Date)aggregateResult.get('date');
        estimatedDate = dateValue != null ? (dateValue + (Integer.valueOf(aggregateResult.get('requestDispatchDay')) != null ? Integer.valueOf(aggregateResult.get('requestDispatchDay')) : 0)) : null;
        String key = poNumber + '_' + itemGroupId + '_' + location;
        subtractQty = map_openPO_poNumber_subtract.containsKey(key) ? map_openPO_poNumber_subtract.get(key) : 0;
      } else
      if(status == STATUS_IN_TRANSIT){
        dateValue = (Date)aggregateResult.get('date');
        //estimatedDate = (Date)aggregateResult.get('ETADate') != null ? addDaysIgnoreWeekend((Date)aggregateResult.get('ETADate'), 10) : null;
        estimatedDate = (Date)aggregateResult.get('ETADate') != null ? (Date)aggregateResult.get('ETADate') + 7 : null;
      }
      /*
       else
      if(status == STATUS_PENDING){
        String key = poNumber + '_' + itemGroupId + '_' + location;
        dateValue = map_poNumber_pendingDate.containsKey(key) ? map_poNumber_pendingDate.get(key) : null;
        //estimatedDate = (Date)aggregateResult.get('IDFDate') != null ? addDaysIgnoreWeekend((Date)aggregateResult.get('IDFDate'), 11) : null;
        //estimatedDate = (Date)aggregateResult.get('IDFDate') != null ? (Date)aggregateResult.get('IDFDate') + 11 : null;
        estimatedDate = dateValue != null ? dateValue + 14 : null;
      }
      */
      
      String key = '';
      if(LIST_NEED_DATE_KEY.contains(status)){
        key = status + '_' + itemGroupId + '_' + location + '_' + poNumber + '_' + dateValue;
      } else {
        key = status + '_' + itemGroupId + '_' + location;
      }
            Decimal purchaseQuantity = (Decimal) aggregateResult.get('purchase_quantity');

      wrapper w = map_wrappers.containsKey(key) ? map_wrappers.get(key) : new wrapper(poNumber, itemGroupId, uom, location, status, dateValue, estimatedDate, subBrandId, brandId, subtractQty);
      
      
      if(MAP_OF_OPERATION_TYPE_TO_ADD.containsKey(operationType)){
        if(MAP_OF_OPERATION_TYPE_TO_ADD.get(operationType)){
          w.add_listAdd(aggregateResult);
        } else {
          w.add_listMinus(aggregateResult);
        }
      }
      // additional handling of Duty Free
      //if(status == STATUS_DUTY_FREE){
        string keyPending = itemGroupId + '_' + location;
        if(!set_proceededDF.contains(keyPending)){
			
          string keyDF = STATUS_DUTY_FREE + '_' + itemGroupId + '_' + location;
		  wrapper wDF = (status == STATUS_DUTY_FREE) ? w : new wrapper(null, itemGroupId, uom, location, STATUS_DUTY_FREE, null, null, subBrandId, brandId, 0);
		  
		  if(map_pendingPO_ar.containsKey(keyPending)){
            map<string, map<string, List<AggregateResult>>> map_pendingPO_date_ar = map_pendingPO_ar.get(keyPending);
            for(string subKeyPending : map_pendingPO_date_ar.keySet()){
              map<string, List<AggregateResult>> map_pendingPO_apiType_ar = map_pendingPO_date_ar.get(subKeyPending);
              for(string apiTypePending : map_pendingPO_apiType_ar.keySet()){
                List<AggregateResult> list_ar = map_pendingPO_apiType_ar.get(apiTypePending);
                for(AggregateResult ar : list_ar){
                  if(apiTypePending == PWC_IN_IDF_8){
                    wDF.add_listMinus(ar);
                  } else {
                    wDF.add_listAdd(ar);
                  }
                }
                
              }
              
            }
          }
		  map_wrappers.put(keyDF, wDF);
		  map_wrappersInExecute.put(keyDF, wDF);
		  set_externalIDupsert.add(EXTERNAL_ID_PREFIX + keyDF);
          set_proceededDF.add(keyPending);
        } 
        
      //}
      map_wrappers.put(key, w);
      map_wrappersInExecute.put(key, w);
      set_externalIDupsert.add(EXTERNAL_ID_PREFIX + key);

        }

    for(string keyPendingDate : map_poNumber_pendingDate.keySet()){
      // handle date of PENDING status
      Date dateValue = null;
      Date estimatedDate = null;
      if(map_poNumber_pendingDate.containsKey(keyPendingDate)){
        //dateValue = map_poNumber_pendingDate.get(keyPendingDate);
        //estimatedDate = dateValue != null ? dateValue + 14 : null;
      }
      List<string> keyList = keyPendingDate.split('_');
      String poNumber = keyList[0];
      String itemGroupId = keyList[1];
      String location = keyList.size() == 3 ? keyList[2] : '';
      
      string keyPending = itemGroupId + '_' + location;
	  
      if(map_pendingPO_ar.containsKey(keyPending)){
        map<string, map<string, List<AggregateResult>>> map_pendingPO_date_ar = map_pendingPO_ar.get(keyPending);
        //String subKeyPending = poNumber + '_' + dateValue;
        //if(map_pendingPO_date_ar.containsKey(subKeyPending)){
			
		// only handle the data of corresponding PO Number
        for(string subKeyPending : map_pendingPO_date_ar.keySet()){
          dateValue = null;
          estimatedDate = null;
          String thisPoNumber = subKeyPending.split('_')[0];
          if(thisPoNumber != poNumber){
            continue;
          }
          system.debug(subKeyPending.split('_')[1]);
          if(subKeyPending.split('_')[1] != 'null'){
            dateValue = Date.valueOf(subKeyPending.split('_')[1]);
          }
          estimatedDate = dateValue != null ? dateValue + 14 : null;
          map<string, List<AggregateResult>> map_pendingPO_apiType_ar = map_pendingPO_date_ar.get(subKeyPending);
          
          /*
          for(string apiTypePending : map_pendingPO_apiType_ar.keySet()){
            List<AggregateResult> list_ar = map_pendingPO_apiType_ar.get(apiTypePending);
            for(aggregateResult aggregateResult : list_ar){
              String subBrandId = (String) aggregateResult.get('subBrand');
              String brandId = (String) aggregateResult.get('brand');
              String uom = (String) aggregateResult.get('uom');
              String status = STATUS_PENDING;

              String key = status + '_' + itemGroupId + '_' + location + '_' + poNumber + '_' + dateValue;
              wrapper w = map_wrappers.containsKey(key) ? map_wrappers.get(key) : new wrapper(poNumber, itemGroupId, uom, location, status, dateValue, estimatedDate, subBrandId, brandId, 0);

              if(apiTypePending == PWC_IN_IDF_8){
                w.add_listAdd(aggregateResult);
              } else {
                w.add_listMinus(aggregateResult);
              }

              map_wrappers.put(key, w);
              map_wrappersInExecute.put(key, w);
              set_externalIDupsert.add(EXTERNAL_ID_PREFIX + key);

            }
          }
          */
          String status = STATUS_PENDING;
          String key = status + '_' + itemGroupId + '_' + location + '_' + poNumber + '_' + dateValue;
          wrapper w = new wrapper(poNumber, itemGroupId, null, location, status, dateValue, estimatedDate, null, null, 0);

          for(string apiTypePending : map_pendingPO_apiType_ar.keySet()){
            List<AggregateResult> list_ar = map_pendingPO_apiType_ar.get(apiTypePending);
            for(aggregateResult aggregateResult : list_ar){
              w.subBrandId = (String) aggregateResult.get('subBrand');
              w.brandId = (String) aggregateResult.get('brand');
              w.uom = (String) aggregateResult.get('uom');
              
              if(apiTypePending == PWC_IN_IDF_8){
                w.add_listAdd(aggregateResult);
              } else {
                w.add_listMinus(aggregateResult);
              }


            }
          }
          
          map_wrappers.put(key, w);
          map_wrappersInExecute.put(key, w);
          set_externalIDupsert.add(EXTERNAL_ID_PREFIX + key);
		  map_pendingPO_date_ar.remove(subKeyPending);
          
        }
		
		// handle the rest of PO Number in the map
		for(string subKeyPending : map_pendingPO_date_ar.keySet()){
          dateValue = null;
          estimatedDate = null;
          String thisPoNumber = subKeyPending.split('_')[0];
          system.debug(subKeyPending.split('_')[1]);
          if(subKeyPending.split('_')[1] != 'null'){
            dateValue = Date.valueOf(subKeyPending.split('_')[1]);
          }
          estimatedDate = dateValue != null ? dateValue + 14 : null;
          map<string, List<AggregateResult>> map_pendingPO_apiType_ar = map_pendingPO_date_ar.get(subKeyPending);
          
          
          String status = STATUS_PENDING;
          String key = status + '_' + itemGroupId + '_' + location + '_' + thisPoNumber + '_' + dateValue;
          wrapper w = new wrapper(thisPoNumber, itemGroupId, null, location, status, dateValue, estimatedDate, null, null, 0);

          for(string apiTypePending : map_pendingPO_apiType_ar.keySet()){
            List<AggregateResult> list_ar = map_pendingPO_apiType_ar.get(apiTypePending);
            for(aggregateResult aggregateResult : list_ar){
              w.subBrandId = (String) aggregateResult.get('subBrand');
              w.brandId = (String) aggregateResult.get('brand');
              w.uom = (String) aggregateResult.get('uom');
              
              if(apiTypePending == PWC_IN_IDF_8){
                w.add_listAdd(aggregateResult);
              } else {
                w.add_listMinus(aggregateResult);
              }


            }
          }
          
          map_wrappers.put(key, w);
          map_wrappersInExecute.put(key, w);
          set_externalIDupsert.add(EXTERNAL_ID_PREFIX + key);
          
        }
    
      }
    }
    
    upsertDetail(map_wrappersInExecute);

        return map_wrappers;
    }

    global void finish(Database.BatchableContext contextInstance) {
    
    

    delete [select id from ASI_CRM_Inventory_Visibility__c where recordtypeId = :RTID_INVENTORYVISIBILITYDETAIL and ASI_CRM_External_ID__c not in :set_externalIDupsert and ASI_CRM_Location_Text__c = :inputLocation];

    }

    global class AggregateResultIterable implements Iterable<AggregateResult> {

        global string inputLocation;
        global Iterator<AggregateResult> iterator() {
            return new AggregateResultIterator(inputLocation);
        }
        global AggregateResultIterable(string inputLocation){
            this.inputLocation = inputLocation;
        }

    }

    global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results { get; set; }
        Integer index { get; set; }

        global AggregateResultIterator(string inputLocation) {
            index = 0;
            if(inputLocation == null){
                results = [
                    SELECT
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c po_number,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Operation_Type__c operation_type,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c warehouse,
            ASI_CRM_Item_Group__c itemGroup,
            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c subBrand,
            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c brand,
            AVG(ASI_CRM_Item_Group__r.ASI_CRM_Request_Dispatch_Day__c) requestDispatchDay,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_ETA_Date__c ETADate,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_IDF_Invoice_Date__c IDFDate,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c date,
            ASI_CRM_UOM__c uom,
            SUM(ASI_CRM_Purchase_QTY__c) purchase_quantity
                    FROM 
            ASI_CRM_Inventory_Visibility_Detail__c
                    WHERE 
            ASI_CRM_Inventory_Visibility__r.recordtypeid = :Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility__cASI_CRM_CN_Inventory_Visibility')
            AND ASI_CRM_Item_Group__c <> null
            AND ASI_CRM_Inventory_Visibility__r.ASI_CRM_Operation_Type__c NOT IN :OPERATION_TYPE_EXCLUSION_LIST
            AND ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c NOT IN :API_TYPE_EXCLUSION_LIST
                    GROUP BY 
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Operation_Type__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c,
            ASI_CRM_Item_Group__c,
            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c,
            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c,
            //ASI_CRM_Item_Group__r.ASI_CRM_Request_Dispatch_Date__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_ETA_Date__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_IDF_Invoice_Date__c,
            ASI_CRM_UOM__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c
                order by 
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c ,
            ASI_CRM_Item_Group__c 
            ];
            }else{
                results = [
                    SELECT
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c po_number,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Operation_Type__c operation_type,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c warehouse,
            ASI_CRM_Item_Group__c itemGroup,
            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c subBrand,
            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c brand,
            AVG(ASI_CRM_Item_Group__r.ASI_CRM_Request_Dispatch_Day__c) requestDispatchDay,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_ETA_Date__c ETADate,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_IDF_Invoice_Date__c IDFDate,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c date,
            ASI_CRM_UOM__c uom,
            SUM(ASI_CRM_Purchase_QTY__c) purchase_quantity
                    FROM 
            ASI_CRM_Inventory_Visibility_Detail__c
                    WHERE 
            ASI_CRM_Inventory_Visibility__r.recordtypeid = :Global_RecordTypeCache.getRtId('ASI_CRM_Inventory_Visibility__cASI_CRM_CN_Inventory_Visibility')
            AND ASI_CRM_Item_Group__c <> null
            AND ASI_CRM_Inventory_Visibility__r.ASI_CRM_Operation_Type__c NOT IN :OPERATION_TYPE_EXCLUSION_LIST
            AND ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c NOT IN :API_TYPE_EXCLUSION_LIST
                and ASI_CRM_Inventory_Visibility__r.ASI_CRM_Location__c = :inputLocation
                    GROUP BY 
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Operation_Type__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c,
            ASI_CRM_Item_Group__c,
            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c,
            ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c,
            //ASI_CRM_Item_Group__r.ASI_CRM_Request_Dispatch_Date__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_ETA_Date__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_IDF_Invoice_Date__c,
            ASI_CRM_UOM__c,
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c
                order by 
            ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c ,
            ASI_CRM_Item_Group__c 
            ];
            }
            

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

    public map<string, date> get_poNumber_pendingDate(list<string> list_pendingPO_poNumber, list<string> list_itemGroup, list<string> list_location) {
    map<string, date> map_poNumber_pendingDate = new map<string, date>();
  
        for (ASI_CRM_Inventory_Visibility_Detail__c w : [
      select 
        ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c,
        ASI_CRM_Item_Group__c,
        ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c,
        ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c
      from 
        ASI_CRM_Inventory_Visibility_Detail__c
      where 
        ASI_CRM_Inventory_Visibility__r.recordtypeId = :RTID_INVENTORYVISIBILITYRAW
        //and ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c in :list_pendingPO_poNumber
        and ASI_CRM_Inventory_Visibility__r.ASI_CRM_Location__c in :list_location
        and ASI_CRM_Item_Group__c in :list_itemGroup
        and ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c in :API_TYPE_PENDING_PO_FOR_CALCULATION
    ]) {
            String warehouse = w.ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c;
            ASI_CRM_CN_InventoryVisibilityWarehouse__mdt mdt;
      if(map_warehouse.containsKey(warehouse)){
        mdt = map_warehouse.get(warehouse);
      }
      String location = mdt != null ? mdt.ASI_CRM_Location__c : '';
      
            String key = w.ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c + '_' + w.ASI_CRM_Item_Group__c + '_' + location;
      if(!map_poNumber_pendingDate.containsKey(key)){
        map_poNumber_pendingDate.put(key, w.ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c);
      }

        }

        return map_poNumber_pendingDate;
    }
    public map<string, map<string, map<string, List<AggregateResult>>>> get_pendingPO_ar(list<string> list_pendingPO_poNumber, list<string> list_itemGroup) {
    map<string, map<string, map<string, List<AggregateResult>>>> map_pendingPO_ar = new map<string, map<string, map<string, List<AggregateResult>>>>();
  
        for (AggregateResult ar : [
        select 
          ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c poNumber,
          ASI_CRM_Item_Group__c itemGroup,
          ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c warehouse,
          ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c date,
          ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c apiType,
          ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c subBrand,
          ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c brand,
          ASI_CRM_UOM__c uom,
          sum(ASI_CRM_Purchase_QTY__c) purchase_quantity 
        from 
          ASI_CRM_Inventory_Visibility_Detail__c
        where 
          ASI_CRM_Inventory_Visibility__r.recordtypeId = :RTID_INVENTORYVISIBILITYRAW
        and ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c <> null
          and ASI_CRM_Item_Group__c in :list_itemGroup
          and ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c in :API_TYPE_PENDING_PO_FOR_CALCULATION
        group by
          ASI_CRM_Inventory_Visibility__r.ASI_CRM_PO_Number__c,
          ASI_CRM_Item_Group__c ,
          ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c ,
          ASI_CRM_Inventory_Visibility__r.ASI_CRM_Date__c ,
          ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c, 
          ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c,
          ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c,
          ASI_CRM_UOM__c
      ]
    ) {
            String warehouse = (String) ar.get('warehouse');
            ASI_CRM_CN_InventoryVisibilityWarehouse__mdt mdt;
      if(map_warehouse.containsKey(warehouse)){
        mdt = map_warehouse.get(warehouse);
      }
      String location = mdt != null ? mdt.ASI_CRM_Location__c : '';
      
            String poNumber = (String) ar.get('poNumber');
            String itemGroup = (String) ar.get('itemGroup');
            date dateValue = (date) ar.get('date');
            String apiType = (String) ar.get('apiType');
            String key = itemGroup + '_' + location;
      String subKey = poNumber + '_' + dateValue;
      String uniqueKey = itemGroup + '_' + warehouse + '_' + poNumber + '_' + dateValue + '_' + apiType;
      /*
      if(set_rawUniqueKey.contains(uniqueKey)){
        continue;
      } else {
        set_rawUniqueKey.add(uniqueKey);
      }
      */

      map<string, map<string, List<AggregateResult>>> map_pendingPO_date_ar = map_pendingPO_ar.containsKey(key) ? map_pendingPO_ar.get(key) : new map<string, map<string, List<AggregateResult>>>();
      map<string, List<AggregateResult>> map_pendingPO_apiType_ar = map_pendingPO_date_ar.containsKey(subKey) ? map_pendingPO_date_ar.get(subKey) : new map<string, List<AggregateResult>>();
      List<AggregateResult> list_ar = map_pendingPO_apiType_ar.containsKey(apiType) ? map_pendingPO_apiType_ar.get(apiType) : new List<AggregateResult>();
      list_ar.add(ar);
      map_pendingPO_apiType_ar.put(apiType, list_ar);
      map_pendingPO_date_ar.put(subKey, map_pendingPO_apiType_ar);
      map_pendingPO_ar.put(key, map_pendingPO_date_ar);
      system.debug(poNumber + '_' + dateValue + '_' + map_pendingPO_apiType_ar);

        }

        return map_pendingPO_ar;
    }
    public map<string, decimal> get_openPO_poNumber_subtract(list<string> list_poNumber, list<string> list_itemGroup) {
    map<string, decimal> map_qty = new map<string, decimal>();
  
        for (aggregateResult ar : [
      select 
        ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c poNumber,
        ASI_CRM_Item_Group__c itemGroup,
        ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c warehouse,
        sum(ASI_CRM_Purchase_QTY__c) qty
      from 
        ASI_CRM_Inventory_Visibility_Detail__c
      where 
        ASI_CRM_Inventory_Visibility__r.recordtypeId = :RTID_INVENTORYVISIBILITYRAW
        and ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c in :list_poNumber
        and ASI_CRM_Item_Group__c in :list_itemGroup
        and ASI_CRM_Inventory_Visibility__r.ASI_CRM_API_Type__c in :API_TYPE_OPEN_PO
      group by 
        ASI_CRM_Inventory_Visibility__r.ASI_CRM_Original_Doc_Number__c,
        ASI_CRM_Item_Group__c,
        ASI_CRM_Inventory_Visibility__r.ASI_CRM_WH_Code_To__c
    ]) {
            String warehouse = (String) ar.get('warehouse');
            ASI_CRM_CN_InventoryVisibilityWarehouse__mdt mdt;
      if(map_warehouse.containsKey(warehouse)){
        mdt = map_warehouse.get(warehouse);
      }
      String location = mdt != null ? mdt.ASI_CRM_Location__c : '';
      
      string poNumber = String.valueOf(ar.get('poNumber'));
            string itemGroup = String.valueOf(ar.get('itemGroup'));
      string key = poNumber + '_' + itemGroup + '_' + location;
      decimal qty = (Decimal) ar.get('qty');
      decimal originalQty = map_qty.containsKey(key) ? map_qty.get(key) : 0;
      map_qty.put(key, qty + originalQty);

        }

        return map_qty;
    }
  /*
  public date addDaysIgnoreWeekend(Date dtStartDate, integer noOfDays){
    for(integer i = 0; i<noOfDays; i++){
      datetime myDate = datetime.newInstance(dtStartDate.year(), 
                                                   dtStartDate.month(),
                                                     dtStartDate.day());
            if(myDate.format('EEEE') == 'Friday' ){
                dtStartDate = dtStartDate.addDays(3);
            } else
      if(myDate.format('EEEE') == 'Saturday' ){
                dtStartDate = dtStartDate.addDays(2);
            } else {
        dtStartDate = dtStartDate.addDays(1);
      }
    }
    return dtStartDate;
  }
  */
  
  public void upsertDetail(Map<String, wrapper> map_wrappersInExecute){
    List<ASI_CRM_Inventory_Visibility__c> inventoryVisibilityUpsertList = new List<ASI_CRM_Inventory_Visibility__c>();

        for (string key : map_wrappersInExecute.keySet()) {
            wrapper w = map_wrappersInExecute.get(key);
      ASI_CRM_Inventory_Visibility__c inventoryVisibility = new ASI_CRM_Inventory_Visibility__c(
        ASI_CRM_PO_Number__c = w.poNumber,
        ASI_CRM_Item_Group__c = w.itemGroupId,
        ASI_CRM_Location_Text__c = w.location,
        ASI_CRM_Date__c = w.dateValue,
        ASI_CRM_Estimated_Date_to_Next_Status__c = w.estimatedDate,
        ASI_CRM_QTY_by_Case__c = w.finalQuantity(),
        ASI_CRM_Status__c = w.status,
        ASI_CRM_UOM__c = w.uom,
        ASI_CRM_Sub_brand__c = w.subBrandId,
        ASI_CRM_Brand__c = w.brandId,
        RecordTypeId = RTID_INVENTORYVISIBILITYDETAIL,
        ASI_CRM_External_ID__c = EXTERNAL_ID_PREFIX + key
      );
      inventoryVisibilityUpsertList.add(inventoryVisibility);
        }

        upsert inventoryVisibilityUpsertList ASI_CRM_External_ID__c;
  }

  public class wrapper{
    public string poNumber {get;set;}
    public string itemGroupId {get;set;}
    public string subBrandId {get;set;}
    public string brandId {get;set;}
    public string uom {get;set;}
    public string location {get;set;}
    public string status {get;set;}
    public date dateValue {get;set;}
    public date estimatedDate {get;set;}
    public decimal subtractQty {get;set;}
    public list<aggregateResult> list_ar_add {get;set;}
    public list<aggregateResult> list_ar_minus {get;set;}
    
    public wrapper(string poNumber, string itemGroupId, string uom, string location, string status, date dateValue, date estimatedDate, string subBrandId, string brandId, decimal subtractQty){
      this.poNumber = poNumber;
      this.itemGroupId = itemGroupId;
      this.subBrandId = subBrandId;
      this.brandId = brandId;
      this.uom = uom;
      this.location = location;
      this.status = status;
      this.dateValue = dateValue;
      this.estimatedDate = estimatedDate;
      this.subtractQty = subtractQty;
      this.list_ar_add = new list<aggregateResult>();
      this.list_ar_minus = new list<aggregateResult>();
    }
    
    public void add_listAdd(aggregateResult ar){
      this.list_ar_add.add(ar);
    }
    public void add_listMinus(aggregateResult ar){
      this.list_ar_minus.add(ar);
    }
    public decimal finalQuantity(){
      decimal qty = 0;
      for(aggregateResult ar : this.list_ar_add){
        qty += (Decimal) ar.get('purchase_quantity');
      }
      for(aggregateResult ar : this.list_ar_minus){
        qty -= (Decimal) ar.get('purchase_quantity');
      }
      return qty - subtractQty;
    }
  }
}