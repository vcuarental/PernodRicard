/*********************************************************************************
 * Name: ASI_CRM_JP_ManageSODetailController
 * Description: Controller class for JP Managing Sales Order Detail(Javascript).
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/02/2017       Hugo Cheung             Created
*/
public class ASI_CRM_JP_ManageSODetailController {

    private class ExceptionWrapper {
        private Integer lineNumber {
            get; set;
        }
        private String errorMessage {
            get; set;
        }
        private List<String> fieldAPINameList {
            get; set;
        }

        private ExceptionWrapper(Integer lineNumber, String errorMessage) {
            this.lineNumber = lineNumber;
            this.errorMessage = errorMessage;
        }

        private ExceptionWrapper(Integer lineNumber, String errorMessage, List<String> fieldAPINameList) {
            this(lineNumber, errorMessage);
            this.fieldAPINameList = fieldAPINameList;
        }
    }

    //Record Type
    private final static String SKU_RECORD_TYPE_DEV_NAME               = 'ASI_CRM_JP_SKU';
//    private final static String ITEM_AVAILABILITY_RECORD_TYPE_DEV_NAME = 'ASI_JP_CRM_DF_Item_Availability';
    private final static String ITEM_AVAILABILITY_RECORD_TYPE_DEV_NAME = 'ASI_JP_CRM_DP_Item_Availability';

    //SO Record Type retrieve price with customer group
    private final static String DIRECT_SALES_RECORD_TYPE = 'ASI_CRM_JP_Direct_Sales';
    private final static String MARKETING_FOC_RECORD_TYPE = 'ASI_CRM_JP_Marketing_FOC';

    //SO Record Type need to retrieve price
    //Key = SO Record Type, Value = Item Base Price Record Type
    private final static Map<String, String> RETRIEVE_PRICE_RECORD_TYPE_MAP = new Map<String, String> {
        'ASI_CRM_JP_Normal_SO'      => 'ASI_CRM_JP_Duty_Paid_Product_Price',
        'ASI_CRM_JP_Employee_Sales' => 'ASI_CRM_JP_Employee_Product_Price',
        'ASI_CRM_JP_Direct_Sales'   => 'ASI_CRM_JP_Direct_Sales_Product_Price',
        'ASI_CRM_JP_Duty_Free_SO'   => 'ASI_CRM_JP_Duty_Free_Product_Price'
    };

    //Field Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP        = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SALES_ORDER_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ITEM_AVAILABILITY_FIELD_MAP  = Schema.SObjectType.ASI_CRM_JP_Item_Availability__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SKU_FIELD_MAP                = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ITEM_PRICE_MAP               = Schema.SObjectType.ASI_CRM_JP_Customer_Product_Price__c.fields.getMap();

    //Parameter from VF Page Name
    private final static String SALES_ORDER_ID   = 'id';
    private final static String IS_QUICK_SAVE    = 'isQuickSave';
    private final static String UPSERT_DATA_JSON = 'upsertDataJson';
    private final static String REMOVE_DATA_JSON = 'removeDataJson';

    //COT User permission set
    private final static String COT_USER_PERMISSION_SET_LABEL = 'ASI CRM JP Supply Chain Add-On';
    //Duty Free User permission set
    private final static String DUTY_FREE_USER_PERMISSION_SET_LABEL = 'ASI CRM JP Duty Free User';

    //SO Record
    public ASI_CRM_JP_Sales_Order__c salesOrder                       {get; set;}
    private List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderDetailList {get; set;}

    //Auto complete SKU Id/Name Map
    private Map<String, Id> skuNameIdMap {get; set;}
    private Map<String, Id> itemAvailabilityNameIdMap {get; set;}

    //Field API & Id Map
    private Map<String, Id> fieldIdMap {get; set;}

    //Picklist Value
    private Map<String, String> uomValueMap {get; set;}

    //Page Control
    public String salesOrderRecordTypeAPIName {get; set;}
    public String salesOrderRecordOrderType   {get; set;}
    public Boolean isCOTUser                  {get; set;}
    public Boolean isDutyFreeUser             {get; set;}

    //JSON String for VF Page
    public String salesOrderDetailListJson      {get {return toJsonString(salesOrderDetailList);}}
    public String skuNameIdMapJson              {get {return toJsonString(skuNameIdMap);}}
    public String itemAvailabilityNameIdMapJson {get {return toJsonString(itemAvailabilityNameIdMap);}}
    public String uomValueMapJson               {get {return toJsonString(uomValueMap);}}
    public String fieldIdMapJson                {get {return toJsonString(fieldIdMap);}}
    public String exceptionListJson             {get {return toJsonString(exceptionList);}}

    //Variable for VF Page
    public Boolean isEditable                   {get; set;}
    public String soDetailRecordTypeId          {get {return '';}}
    public Boolean hasError                     {get; set;}
    public List<ExceptionWrapper> exceptionList {get; set;}

    //Init function
    public ASI_CRM_JP_ManageSODetailController(ApexPages.StandardController standardController) {
        Id salesOrderId      = ApexPages.currentPage().getParameters().get(SALES_ORDER_ID);
        salesOrder           = retrieveSalesOrder(salesOrderId);
        salesOrderDetailList = retrieveSalesOrderDetailList(salesOrderId);
        uomValueMap          = retrievePicklistValues(ASI_CRM_JP_Sales_Order_Item__c.ASI_CRM_UOM__c.getDescribe());
        fieldIdMap           = retrieveFieldId();

        //Set SKU Map for auto complete
        skuNameIdMap = getSkuNameIdMap(retrieveSKUList());
        System.debug('skuNameIdMap:::' + skuNameIdMap);
        itemAvailabilityNameIdMap = getItemAvailabilityNameIdMap(
                retrieveItemAvailabilityMap(salesOrder.ASI_CRM_Branch_Plant__c)
        );
        System.debug('itemAvailabilityNameIdMap:::' + itemAvailabilityNameIdMap);
        salesOrderRecordTypeAPIName = salesOrder.RecordType.DeveloperName;
        salesOrderRecordOrderType = salesOrder.ASI_CRM_Order_Type__c;
        checkUserType();

        isEditable = !salesOrder.ASI_CRM_Status__c.equals('Submitted');
    }

    private void checkUserType() {
        final Id currentUserId = UserInfo.getUserId();
        isCOTUser = !getPermissionSetAssignments(currentUserId, COT_USER_PERMISSION_SET_LABEL).isEmpty();
        isDutyFreeUser = !getPermissionSetAssignments(currentUserId, DUTY_FREE_USER_PERMISSION_SET_LABEL).isEmpty();
    }

    /***************
    View Action Handler
    ***************/
    public PageReference save() {
        hasError = false;
        final Id salesOrderId = salesOrder.Id;
        final String salesOrderWarehouse = salesOrder.ASI_CRM_Branch_Plant__c;
        System.debug('salesOrderId:::' + salesOrderId);
        System.debug('salesOrderWarehouse:::' + salesOrderWarehouse);

        final Map<String, String> params = ApexPages.currentPage().getParameters();
        final Boolean isQuickSave = String.isBlank(params.get(IS_QUICK_SAVE)) ? false : Boolean.valueOf(params.get(IS_QUICK_SAVE));
        final String upsertSODetailJson = params.get(UPSERT_DATA_JSON);
        final String removeSODetailJson = params.get(REMOVE_DATA_JSON);

        final System.Savepoint databaseSavepoint = Database.setSavepoint();
        try {
            final List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemsToUpsert = parseSalesOrderItems(
                    upsertSODetailJson
            );
            final List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemsToRemove = createSalesOrderItemsDeleteList(
                    parseIdList(removeSODetailJson)
            );

            if (!salesOrderItemsToRemove.isEmpty()) Database.delete(salesOrderItemsToRemove);

//            final Map<Id, ASI_CRM_JP_Item_Availability__c> skuIdItemAvailabilityMap = getSkuItemAvailabilityMap(
//                    salesOrderItemsToUpsert
//            );
            final Set<Id> salesOrderItemSkuIds = ASI_CRM_JP_UtilityService.getObjectIdPropertySet(
                    salesOrderItemsToUpsert, ASI_CRM_JP_Sales_Order_Item__c.ASI_CRM_SKU__c
            );
            System.debug('salesOrderItemSkuIds:::' + salesOrderItemSkuIds);
            final List<ASI_CRM_JP_Item_Availability__c> itemAvailabilities = getItemAvailabilityBySkuIds(
                    salesOrderWarehouse, salesOrderItemSkuIds
            );
            System.debug('itemAvailabilities:::' + itemAvailabilities);
            final Map<Id, ASI_CRM_JP_Item_Availability__c> skuIdItemAvailabilityMap = getSkuIdItemAvailabilityMap(
                    itemAvailabilities
            );
            final Map<Id, ASI_MFM_SKU_Code__c> skuIdSkuMap = getIdSkuMap(salesOrderItemSkuIds);

            for (ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemsToUpsert) {

                final ASI_CRM_JP_Item_Availability__c itemAvailability = skuIdItemAvailabilityMap.get(
                    salesOrderItem.ASI_CRM_SKU__c
                );
                System.debug('itemAvailability:::' + itemAvailability);

                if (skuNameIdMap.containsKey(salesOrderItem.ASI_CRM_SKU__c)) {
                    salesOrderItem.ASI_CRM_SKU__c = skuNameIdMap.get(salesOrderItem.ASI_CRM_SKU__c);
                }
                if (itemAvailabilityNameIdMap.containsKey(salesOrderItem.ASI_CRM_SKU_Item__c)) {
                    salesOrderItem.ASI_CRM_SKU_Item__c = itemAvailabilityNameIdMap.get(salesOrderItem.ASI_CRM_SKU_Item__c);
                }

                if (!isValidSalesOrderItemQuantity(salesOrderItem, itemAvailability)) {
                    String exceptionMessage = 'Quantity exceeds available quantity. ';
                    if (itemAvailability != null) {
                        exceptionMessage += 'Available quantity ' + itemAvailability.ASI_Quantity_Availability__c;
                    } else {
                        exceptionMessage = 'Item availability details not found';
                    }
                    throw new ASI_CRM_JP_UtilityService.CustomException(exceptionMessage);
                }
                
                if(salesOrderRecordTypeAPIName == MARKETING_FOC_RECORD_TYPE){
                	setSalesOrderItemUnitPrice(salesOrderItem, skuIdSkuMap);   
                }
            }

            if (!salesOrderItemsToUpsert.isEmpty()) Database.upsert(salesOrderItemsToUpsert);

        } catch (Exception e) {
            hasError = true;
            exceptionList = handleException(e);
            Database.rollback(databaseSavepoint);
            return null;
        }

        PageReference pageRef = null;
        if (!isQuickSave) {
            pageRef = new PageReference('/' + salesOrderId);
            pageRef.setRedirect(true);
        } else {
            salesOrderDetailList = retrieveSalesOrderDetailList(salesOrderId);
        }
        return pageRef;
    }

    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + salesOrder.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    private static Map<Id, ASI_CRM_JP_Item_Availability__c> getSkuItemAvailabilityMap(
            List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItems
    ) {

        final Map<Id, ASI_CRM_JP_Item_Availability__c> skuIdItemAvailabilityMap =
                new Map<Id, ASI_CRM_JP_Item_Availability__c>();

        for (ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItems) {

            skuIdItemAvailabilityMap.put(
                    salesOrderItem.ASI_CRM_SKU_Item__r.ASI_SKU__c, salesOrderItem.ASI_CRM_SKU_Item__r
            );
        }

        return skuIdItemAvailabilityMap;
    }

    private static List<ExceptionWrapper> handleException(Exception e) {
        final List<ExceptionWrapper> exceptionList = new List<ExceptionWrapper>();

        if (e == null) return exceptionList;

        if (e.getTypeName().equals(System.DmlException.class.getName())) {
            final DmlException dmlException = (DmlException) e;
            for (Integer count = 0 ; count < dmlException.getNumDml() ; count++) {
                final ExceptionWrapper exceptionWrapper = new ExceptionWrapper(
                        dmlException.getDmlIndex(count),
                        dmlException.getDmlMessage(count),
                        dmlException.getDmlFieldNames(count)
                );
                exceptionList.add(exceptionWrapper);
            }
        } else {
            final ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
            exceptionList.add(exceptionWrapper);
        }

        return exceptionList;
    }

    private static ASI_CRM_JP_Sales_Order__c retrieveSalesOrder(Id salesOrderId) {
        String query = 'SELECT ' + generateQuerySelectFields(SALES_ORDER_FIELD_MAP) +
                       ', RecordType.DeveloperName, ASI_CRM_Sold_To__r.ASI_CRM_National_Group__c ' +
                       'FROM ASI_CRM_JP_Sales_Order__c ' +
                       'Where Id = :salesOrderId';

        List<ASI_CRM_JP_Sales_Order__c> salesOrderList = (List<ASI_CRM_JP_Sales_Order__c>) Database.query(query);
        return !salesOrderList.isEmpty() ? salesOrderList.get(0) : null;
    }

    private static List<ASI_CRM_JP_Sales_Order_Item__c> retrieveSalesOrderDetailList(Id salesOrderId) {
        String query = 'SELECT ' + generateQuerySelectFields(SALES_ORDER_DETAIL_FIELD_MAP) +
                       ', ASI_CRM_SKU__r.Name, ASI_CRM_SKU__r.ASI_MFM_Item_Group__c, ASI_CRM_SKU_Item__r.Name ' +
                       ', ASI_CRM_SKU__r.ASI_CRM_JP_English_Name__c, ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c ' +
                       ', ASI_CRM_SKU_Item__r.ASI_Quantity_Availability__c, ASI_CRM_SKU_Item__r.ASI_SKU__c ' +
                       ', ASI_CRM_SKU__r.ASI_Weighted_Average_Cost__c ' +
                       'FROM ASI_CRM_JP_Sales_Order_Item__c ' +
                       'Where ASI_CRM_Sales_Order__c = :salesOrderId ' +
                       'AND ASI_CRM_Status__c != \'980-Cancelled\' ' +
                       'ORDER BY ASI_CRM_Sorting_Number__c ';

        return (List<ASI_CRM_JP_Sales_Order_Item__c>) Database.query(query);
    }

    private static List<ASI_MFM_SKU_Code__c> retrieveSKUList() {
        String query = 'SELECT ' + generateQuerySelectFields(SKU_FIELD_MAP) +
                       ', RecordType.DeveloperName ' +
                       'FROM ASI_MFM_SKU_Code__c ' +
                       'Where RecordType.DeveloperName = :SKU_RECORD_TYPE_DEV_NAME';
        return (List<ASI_MFM_SKU_Code__c>) Database.query(query);
    }


    private static List<ASI_CRM_JP_Item_Availability__c> retrieveItemAvailabilityMap(String warehouseLocation) {
    	String query = 'SELECT ' + generateQuerySelectFields(ITEM_AVAILABILITY_FIELD_MAP) +
                       ', RecordType.DeveloperName ' +
                       'FROM ASI_CRM_JP_Item_Availability__c ' +
                       'Where RecordType.DeveloperName = :ITEM_AVAILABILITY_RECORD_TYPE_DEV_NAME ' +
                       'And ASI_Quantity_Availability__c > 0 ' +
                       'And ASI_Warehouse_Location__c = :warehouseLocation ';

        return (List<ASI_CRM_JP_Item_Availability__c>) Database.query(query);
    }

    private static Map<Id, ASI_MFM_SKU_Code__c> getIdSkuMap(Set<Id> skuIds) {
        final Map<Id, ASI_MFM_SKU_Code__c> idSkuMap = new Map<Id, ASI_MFM_SKU_Code__c>(getSkuById(skuIds));
        return idSkuMap;
    }

    private static List<ASI_MFM_SKU_Code__c> getSkuById(Set<Id> skuIds) {
        return [
            SELECT Id, Name, ASI_Weighted_Average_Cost__c
            FROM ASI_MFM_SKU_Code__c
            WHERE Id IN :skuIds
        ];
    }

    private static Map<String, String> retrievePicklistValues(Schema.DescribeFieldResult fieldResult) {
  		Map<String, String> picklistValueMap = new Map<String, String>();

  		List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
  		for(Schema.PicklistEntry picklistEntry : picklistEntryList) {
    		picklistValueMap.put(picklistEntry.getLabel(), picklistEntry.getValue());
    	}

    	return picklistValueMap;
  	}

    private static Map<String, Id> retrieveFieldId() {
        Map<String, String> tempFieldIdMap = new Map<String, String>();
        List<ASI_CRM_Field_ID_Mappings__c> fieldIdMappingList = ASI_CRM_Field_ID_Mappings__c.getAll().values();
        for(ASI_CRM_Field_ID_Mappings__c fieldIdMapping : fieldIdMappingList) {
            tempFieldIdMap.put(fieldIdMapping.ASI_CRM_Field_Name__c, fieldIdMapping.ASI_CRM_Field_ID__c.subString(0, 15));
        }
        return tempFieldIdMap;
    }

    private static String generateQuerySelectFields(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    private static String generateQuerySelectFields(Schema.SObjectType objectType) {
        final Map<String, Schema.SObjectField> fieldNameObjectTypeMap = objectType.getDescribe().fields.getMap();
        final List<String> queryFields = new List<String>();

        for (String fieldName : fieldNameObjectTypeMap.keySet()) {
            queryFields.add(fieldName);
        }

        return String.join(queryFields, ', ');
    }

    private static String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private static List<Object> fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return (List<Object>) System.JSON.deserialize(jsonString, apexType);
    }

    private static Map<String, Id> getSkuNameIdMap(List<ASI_MFM_SKU_Code__c> skuCodes) {
        final Map<String, Id> skuNameIdMap = new Map<String, Id>();

        if (skuCodes == null) return skuNameIdMap;

        for (ASI_MFM_SKU_Code__c sku : skuCodes) {
            skuNameIdMap.put(sku.Name, sku.Id);
        }

        return skuNameIdMap;
    }

    private static Map<String, Id> getItemAvailabilityNameIdMap(
            List<ASI_CRM_JP_Item_Availability__c> itemAvailabilities
            ) {
        final Map<String, Id> itemAvailabilityNameIdMap = new Map<String, Id>();

        if (itemAvailabilities == null) return itemAvailabilityNameIdMap;

        for (ASI_CRM_JP_Item_Availability__c itemAvailability : itemAvailabilities) {
            itemAvailabilityNameIdMap.put(itemAvailability.Name, itemAvailability.Id);
        }

        return itemAvailabilityNameIdMap;
    }

    private static List<PermissionSetAssignment> getPermissionSetAssignments(
            final Id assigneeId,
            final String permissionLabel
            ) {
        return [
                SELECT AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :assigneeId
                AND PermissionSet.Label = :permissionLabel
        ];
    }

    private static Boolean isValidSalesOrderItemQuantity(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem) {
        return (salesOrderItem.ASI_CRM_Quantity__c <= salesOrderItem.ASI_CRM_Available_Quantity__c);
    }

    private static Boolean isValidSalesOrderItemQuantity(
            ASI_CRM_JP_Sales_Order_Item__c salesOrderItem,
            ASI_CRM_JP_Item_Availability__c itemAvailability
            ) {
        if (itemAvailability == null) return false;

        return (salesOrderItem.ASI_CRM_Quantity__c <= itemAvailability.ASI_Quantity_Availability__c);
    }

    private static void setSalesOrderItemUnitPrice(
            ASI_CRM_JP_Sales_Order_Item__c salesOrderItem,
            Map<Id, ASI_MFM_SKU_Code__c> skuIdSkuMap
            ) {

        final ASI_MFM_SKU_Code__c skuCode = skuIdSkuMap.get(salesOrderItem.ASI_CRM_SKU__c);
        System.debug('skuCode:::' + skuCode);

        if (skuCode.ASI_Weighted_Average_Cost__c == null) {
            System.debug('Missing:::skuCode.ASI_Weighted_Average_Cost__c');
        }
        salesOrderItem.ASI_CRM_Unit_Price__c = skuCode.ASI_Weighted_Average_Cost__c;
    }

    private static List<ASI_CRM_JP_Sales_Order_Item__c> parseSalesOrderItems(String salesOrderItemsJsonString) {
        try {
            return (List<ASI_CRM_JP_Sales_Order_Item__c>) fromJsonString(
                    salesOrderItemsJsonString, List<ASI_CRM_JP_Sales_Order_Item__c>.class
            );
        } catch (Exception e) {
            throw new ASI_CRM_JP_UtilityService.CustomException(e.getMessage());
        }
        return null;
    }

    private static List<Id> parseIdList(String idListJsonString) {
        try {
            return (List<Id>) fromJsonString(idListJsonString, List<Id>.class);
        } catch (Exception e) {
            throw new ASI_CRM_JP_UtilityService.CustomException(e.getMessage());
        }
        return null;
    }

    private static List<ASI_CRM_JP_Sales_Order_Item__c> createSalesOrderItemsDeleteList(
            List<Id> salesOrderItemIdsToRemove
            ) {
        final List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItems = new List<ASI_CRM_JP_Sales_Order_Item__c>();

        if (salesOrderItemIdsToRemove == null) return salesOrderItems;

        for (String removeId : salesOrderItemIdsToRemove) {
            salesOrderItems.add(new ASI_CRM_JP_Sales_Order_Item__c(Id = removeId));
        }

        return salesOrderItems;
    }

    private static List<ASI_CRM_JP_Item_Availability__c> getItemAvailabilityBySkuIds(
            String warehouseLocation, Set<Id> skuIds
            ) {
        return [
                SELECT Id, Name, RecordType.DeveloperName, ASI_SKU__c, ASI_Quantity_Availability__c
                FROM ASI_CRM_JP_Item_Availability__c
                WHERE RecordType.DeveloperName = :ITEM_AVAILABILITY_RECORD_TYPE_DEV_NAME
                AND ASI_Warehouse_Location__c = :warehouseLocation
                AND ASI_SKU__c IN :skuIds
        ];
    }

    private static Map<Id, ASI_CRM_JP_Item_Availability__c> getSkuIdItemAvailabilityMap(
            List<ASI_CRM_JP_Item_Availability__c> itemAvailabilities
            ) {
        final Map<Id, ASI_CRM_JP_Item_Availability__c> skuIdItemAvailabilityMap =
                new Map<Id, ASI_CRM_JP_Item_Availability__c>();
        for (ASI_CRM_JP_Item_Availability__c itemAvailability : itemAvailabilities) {
            skuIdItemAvailabilityMap.put(itemAvailability.ASI_SKU__c, itemAvailability);
        }
        return skuIdItemAvailabilityMap;
    }

//    private static List<ASI_CRM_JP_Sales_Order_Item__c> createSalesOrderItemsUpsertList(
//            List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItems
//    ) {
//        final List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemsToUpsert = new List<ASI_CRM_JP_Sales_Order_Item__c>();
//
//        if (salesOrderItems != null && !salesOrderItems.isEmpty()) return salesOrderItemsToUpsert;
//
//        final Set<Id> salesOrderItemSkuIds = ASI_CRM_JP_UtilityService.getObjectIdPropertySet(
//                salesOrderItemsToUpsert, ASI_CRM_JP_Sales_Order_Item__c.ASI_CRM_SKU__c
//        );
//        final Map<String, Id> skuNameIdMap = new Map<String, Id>();
//        final Map<String, Id> itemAvailabilityNameIdMap = new Map<String, Id>();
//        final Map<Id, ASI_MFM_SKU_Code__c> skuIdSkuMap = getIdSkuMap(salesOrderItemSkuIds);
//
//        for (ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItems) {
//            if (skuNameIdMap.containsKey(salesOrderItem.ASI_CRM_SKU__c)) {
//                salesOrderItem.ASI_CRM_SKU__c = skuNameIdMap.get(salesOrderItem.ASI_CRM_SKU__c);
//            }
//            if (itemAvailabilityNameIdMap.containsKey(salesOrderItem.ASI_CRM_SKU_Item__c)) {
//                salesOrderItem.ASI_CRM_SKU_Item__c = itemAvailabilityNameIdMap.get(salesOrderItem.ASI_CRM_SKU_Item__c);
//            }
//
//            if (!isValidSalesOrderItemQuantity(salesOrderItem)) {
//                throw new ASI_CRM_JP_UtilityService.CustomException('Quantity exceeds available quantity');
//            }
//
//            setSalesOrderItemUnitPrice(salesOrderItem, skuIdSkuMap);
//        }
//
//        return salesOrderItems;
//    }

}