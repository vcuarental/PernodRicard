/*********************************************************************************
* Name: ASI_CRM_JP_SOAssignApprover
* Description: Assign the approver of sales order
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 31/05/2017       Hugo Cheung             Created
* 09/03/2020       Wilken Lee              [WL 1.0] Change Marketing FOC approval to be based on SKU Unit Price instead of Standard Cost
*/
public class ASI_CRM_JP_SOAssignApprover extends ASI_CRM_JP_TriggerAbstract {
    
    private final static Map<String, Schema.SObjectField> ROUTE_TYPE_FIELD_MAP        = Schema.SObjectType.ASI_CRM_Route_Type__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ROUTE_TYPE_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_CRM_Route_Rule_Detail__c.fields.getMap();
    @testVisible
    private final static String ROUTE_TYPE_RECORD_TYPE = 'ASI_CRM_JP_Sales_Order_Route_Type';
    
    private final static String ENTERTAINMENT_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Entertainment_Sales';
    private final static String MARKETING_FOC_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Marketing_FOC';
    private final static String MARKETING_FOC_LOCKED_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Marketing_FOC_Locked';
    private final static String DIRECT_SALES_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Direct_Sales';
    private final static String DIRECT_SALES_LOCKED_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Direct_Sales_Locked';
    private final static String BRAND_CODE_EMPTY = '-';
    private final static String BRAND_CODE_OTHERS = 'others';
    
    private final static Id marketingFocSalesOrderRecordTypeId = Global_RecordTypeCache.getRtId(
        'ASI_CRM_JP_Sales_Order__c' + MARKETING_FOC_SALES_ORDER_RECORD_TYPE
    );
    
    private final static Id marketingFocLockedSalesOrderRecordTypeId = Global_RecordTypeCache.getRtId(
        'ASI_CRM_JP_Sales_Order__c' + MARKETING_FOC_LOCKED_SALES_ORDER_RECORD_TYPE
    );
    
    private final static Id directSalesLockedSalesOrderRecordTypeId = Global_RecordTypeCache.getRtId(
        'ASI_CRM_JP_Sales_Order__c' + DIRECT_SALES_LOCKED_SALES_ORDER_RECORD_TYPE
    );
    
    private final static Map<String, String> RECORD_TYPE_FILTER_SET = new Map<String, String> {
        'ASI_CRM_JP_Direct_Sales' => 'Direct Sales SO',
            'ASI_CRM_JP_Entertainment_Sales' => 'Entertainment SO',
            'ASI_CRM_JP_Marketing_FOC' => 'Marketing FOC',
            'ASI_CRM_JP_Sample_Sales' => 'Sample SO'
            };
                
                private final static List<String> RECORD_TYPE_MODULE_FILTER_LIST = RECORD_TYPE_FILTER_SET.values();
    
    private final static String ROUTE_TYPE_MODULE = 'Sales Order';
    
    public ASI_CRM_JP_SOAssignApprover() {
        super('ASI_CRM_JP_SOAssignApprover');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        system.debug('ASI_CRM_JP_SOAssignApprover executeTriggerAction');
        
        final List<ASI_CRM_JP_Sales_Order__c> salesOrderList = (List<ASI_CRM_JP_Sales_Order__c>) sObjList;
        system.debug('salesOrderList:' + salesOrderList);
        system.debug('salesOrderList sold to:' + salesOrderList.get(0).ASI_CRM_Sold_To__c);
        final Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap = (Map<Id, ASI_CRM_JP_Sales_Order__c>) oldMap;
        system.debug('salesOrderMap:' + salesOrderMap);
        system.debug('newMap:' + newMap);
        
        final List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = filterSalesOrderList(salesOrderList, salesOrderMap);
        system.debug('filteredSalesOrderList:' + filteredSalesOrderList);
        if(filteredSalesOrderList != null && filteredSalesOrderList.size() > 0) {
            resetApprover(filteredSalesOrderList);
            if (!Global_RecordTypeCache.getRt(String.valueOf(sObjList.get(0).get('RecordTypeId'))).developerName.equals(MARKETING_FOC_SALES_ORDER_RECORD_TYPE)) {
                assignApprover(filteredSalesOrderList);
            }
                        
            if (newMap == null) return;
            assignApproverForFOC((Map<Id, ASI_CRM_JP_Sales_Order__c>) newMap);
        }
        
        salesOrderQuantityDeduction(salesOrderList, salesOrderMap);
    }
    @testVisible
    private static void salesOrderQuantityDeduction(List<ASI_CRM_JP_Sales_Order__c> salesOrderList, Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap) {
        
        system.debug('function salesOrderQuantityDeduction');
        system.debug('sales order list:' + salesOrderList);
        
        final List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItems = getSalesOrderItemsBySalesOrders(
            salesOrderList,
            marketingFocLockedSalesOrderRecordTypeId
        );
        
        system.debug('sales order item list:' + salesOrderItems);
        
        /*
        final Set<Id> itemAvailabilitiesIds = ASI_CRM_JP_UtilityService.getObjectIdPropertySet(
            salesOrderItems,
            ASI_CRM_JP_Sales_Order_Item__c.ASI_CRM_SKU_Item__c
        );
        */
        Set<Id> itemAvailabilitiesIds = new Set<Id>();
        if(salesOrderItems.size() > 0) {
            List<Id> skuIdList = new List<Id>();
            for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem: salesOrderItems) {skuIdList.add(salesOrderItem.ASI_CRM_SKU_Item__c);}
            itemAvailabilitiesIds = new Set<Id>(skuIdList);
        }
        system.debug('itemAvailabilitiesIds:' + itemAvailabilitiesIds);
        
        final Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>> salesOrderIdItemsMap = getSalesOrderIdItemsMap(
            salesOrderItems
        );
        system.debug('salesOrderIdItemsMap:' + salesOrderIdItemsMap);
        
        final List<ASI_CRM_JP_Item_Availability__c> itemAvailabilityList =
            ASI_CRM_JP_UtilityService.getItemAvailabilityListByIds(itemAvailabilitiesIds);
        system.debug('itemAvailabilityList:' + itemAvailabilityList);
        
        final Map<Id, ASI_CRM_JP_Item_Availability__c> itemIdAvailabilityMap =
            ASI_CRM_JP_UtilityService.getItemAvailabilityMap(itemAvailabilityList);
        system.debug('itemIdAvailabilityMap:' + itemIdAvailabilityMap);
        
        
        for (ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            
            if (!marketingFocLockedSalesOrderRecordTypeId.equals(salesOrder.RecordTypeId) 
                && !directSalesLockedSalesOrderRecordTypeId.equals(salesOrder.RecordTypeId)) {
                system.debug('sales order record type id:' + salesOrder.RecordTypeId + ' not match marketing foc:' 
                             + marketingFocLockedSalesOrderRecordTypeId + ' or direct sales:' 
                             + directSalesLockedSalesOrderRecordTypeId);
                continue;
            }
            if (!salesOrder.ASI_CRM_JDE_Synced__c) {
                system.debug('sales order jde not synced');
                continue;
            }
            
            ASI_CRM_JP_Sales_Order__c olderSalesOrder = salesOrderMap.get(salesOrder.Id);
            system.debug('salesOrder.ASI_CRM_JDE_Synced__c:' + salesOrder.ASI_CRM_JDE_Synced__c);
            system.debug('olderSalesOrder.ASI_CRM_JDE_Synced__c:' + olderSalesOrder.ASI_CRM_JDE_Synced__c);
            if(olderSalesOrder != null && !(!olderSalesOrder.ASI_CRM_JDE_Synced__c && salesOrder.ASI_CRM_JDE_Synced__c)) { continue;
                system.debug('Deduction sales order only run when just ticked jde synced');
            }
            
            final List<ASI_CRM_JP_Sales_Order_Item__c> soItems = salesOrderIdItemsMap.get(salesOrder.Id);
            system.debug('soItems:' + soItems);
            
            if(soItems != null && soItems.size() > 0){
                for (ASI_CRM_JP_Sales_Order_Item__c soItem : soItems) {
                    
                    final ASI_CRM_JP_Item_Availability__c itemAvailability = itemIdAvailabilityMap.get(soItem.ASI_CRM_SKU_Item__c);
                    System.debug(itemAvailability);
                    
                    if(itemAvailability.ASI_SFDC_SO_Commit__c == null) { itemAvailability.ASI_SFDC_SO_Commit__c = 0; }
                    
                    system.debug('itemAvailability.ASI_SFDC_SO_Commit__c:' + itemAvailability.ASI_SFDC_SO_Commit__c);
                    system.debug('soItem.ASI_CRM_Quantity__c:' + soItem.ASI_CRM_Quantity__c);
                    itemAvailability.ASI_SFDC_SO_Commit__c += soItem.ASI_CRM_Quantity__c;
                    
                    System.debug(itemAvailability);
                    
                    system.debug('itemAvailability.ASI_SFDC_SO_Commit__c' + itemAvailability.ASI_SFDC_SO_Commit__c);
                }
            }
        }
        
        update itemIdAvailabilityMap.values();
    }
    
    private List<ASI_CRM_JP_Sales_Order__c> filterSalesOrderList(List<ASI_CRM_JP_Sales_Order__c> salesOrderList, Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap) {
        List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = new List<ASI_CRM_JP_Sales_Order__c>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(RECORD_TYPE_FILTER_SET.containsKey(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).developerName)) { filteredSalesOrderList.add(salesOrder);
            }
        }
        
        return filteredSalesOrderList;
    }
    @testVisible
    private void resetApprover(List<ASI_CRM_JP_Sales_Order__c> salesOrderList) {
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            
            if (!isSubmitForApproval(salesOrder)) continue;
            
            for(Integer i = 1 ; i < 7 ; i++) { salesOrder.put('ASI_CRM_JP_Approver_' + i + '__c', null);
            }
        }
    }
    @testVisible
    private void assignApprover(List<ASI_CRM_JP_Sales_Order__c> salesOrderList) {
        Map<String, ASI_CRM_Route_Type__c> routeTypeMap = retrieveRouteTypeList();
        if(routeTypeMap == null || routeTypeMap.size() == 0) {return;
        }
        
        Set<Id> userIdSet = new Set<Id>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).developerName == ENTERTAINMENT_SALES_ORDER_RECORD_TYPE &&
               String.isNotBlank(salesOrder.ASI_CRM_JP_Entertainment_Owner__c)) {
                   userIdSet.add(salesOrder.ASI_CRM_JP_Entertainment_Owner__c);
               } else {
                   userIdSet.add(salesOrder.ownerId);
               }
        }
        
        Map<Id, User> userMap = retrieveUser(userIdSet);
        
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            String moduleName = RECORD_TYPE_FILTER_SET.get(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).developerName);
            ASI_CRM_Route_Type__c routeType = routeTypeMap.get(moduleName);
            
            if(routeTypeMap.containsKey(moduleName + '_' + salesOrder.OwnerId)) {
                routeType = routeTypeMap.get(moduleName + '_' + salesOrder.OwnerId);
            }
            
            if(userMap.containsKey(salesOrder.ownerId) &&
               routeTypeMap.containsKey(moduleName + '_' + userMap.get(salesOrder.ownerId).UserRole.Name)) {
                   routeType = routeTypeMap.get(moduleName + '_' + userMap.get(salesOrder.ownerId).UserRole.Name);
               }
            
            System.debug('Debug Log : ' + routeType);
            
            if(routeType == null) {
                continue;
            }
            System.debug('Debug Log : ' + routeType.ASI_CRM_Route_Rule_Details__r);
            
            Integer approverIndex = 1;
            for(ASI_CRM_Route_Rule_Detail__c routeTypeDetail : routeType.ASI_CRM_Route_Rule_Details__r) {
                if(routeTypeDetail.ASI_CRM_JP_Approver_Type__c == 'Line Manager') {
                    if(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).developerName == ENTERTAINMENT_SALES_ORDER_RECORD_TYPE &&
                       String.isNotBlank(salesOrder.ASI_CRM_JP_Entertainment_Owner__c)) {
                           salesOrder.put('ASI_CRM_JP_Approver_' + approverIndex + '__c', userMap.get(salesOrder.ASI_CRM_JP_Entertainment_Owner__c).ManagerId);
                           approverIndex++;
                       } else {
                           salesOrder.put('ASI_CRM_JP_Approver_' + approverIndex + '__c', userMap.get(salesOrder.ownerId).ManagerId);
                           approverIndex++;
                       }
                } else {
                    if(Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).developerName == MARKETING_FOC_SALES_ORDER_RECORD_TYPE) {
                        if(String.isNotBlank(routeTypeDetail.ASI_CRM_Marketing_FOC_Mapping__c) && salesOrder.get(routeTypeDetail.ASI_CRM_Marketing_FOC_Mapping__c) == true) {
                               salesOrder.put('ASI_CRM_JP_Approver_' + approverIndex + '__c', routeTypeDetail.ASI_CRM_Approver__c);
                               approverIndex++;
                           }
                    } else {
                        salesOrder.put('ASI_CRM_JP_Approver_' + approverIndex + '__c', routeTypeDetail.ASI_CRM_Approver__c);
                        approverIndex++;
                    }
                }
            }
        }
    }
    
    
    @testVisible
    public static void assignApproverForFOC(Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderIdObjectMap) {
        System.debug('------------------------------------------------------------------------------------------');
        System.debug('Assign FOC Approvers');
        
        final List<ASI_CRM_JP_Sales_Order_Item__c> items = getItemsBySalesOrderIds(salesOrderIdObjectMap.keySet());
        final Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>> salesOrderIdItemsMap = getSalesOrderIdItemsMap(items);
        final Map<Id, List<Id>> salesOrderIdApproversMap = new Map<Id, List<Id>>();

        for (Id salesOrderId : salesOrderIdObjectMap.keySet()) {

            if (!isValidRecordType(salesOrderIdObjectMap.get(salesOrderId))) continue;
            if (!isSubmitForApproval(salesOrderIdObjectMap.get(salesOrderId))) continue;

            final ASI_CRM_JP_Sales_Order__c salesOrder = salesOrderIdObjectMap.get(salesOrderId);
            final List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItems = salesOrderIdItemsMap.get(salesOrderId) == null? new List<ASI_CRM_JP_Sales_Order_Item__c>():salesOrderIdItemsMap.get(salesOrderId);             
            final Map<String, Double> brandCodeAmountMap = new Map<String, Double>();
            final Map<String, List<ASI_CRM_JP_Sales_Order_Item__c>> brandCodeSalesOrderItemsMap = new Map<String, List<ASI_CRM_JP_Sales_Order_Item__c>>();
            
            for (ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItems) {
                final ASI_MFM_SKU_Code__c sku = salesOrderItem.ASI_CRM_SKU__r;
                final ASI_MFM_Item_Group__c itemGroup = sku.ASI_MFM_Item_Group__r;
                
                final String brandCode = sku.ASI_TH_CRM_Brand_Code__c;
                //final Double standardCost = itemGroup.ASI_CRM_Standard_Cost__c;   //[WL 1.0]
                final Double quantity = salesOrderItem.ASI_CRM_Quantity__c;
                //final Double amount = standardCost * quantity; //[WL 1.0]
                final Double amount = salesOrderItem.ASI_CRM_Unit_Price__c * quantity;  //[WL 1.0]
                 
                
                if (brandCodeSalesOrderItemsMap.get(brandCode) == null) {brandCodeSalesOrderItemsMap.put(brandCode, new List<ASI_CRM_JP_Sales_Order_Item__c>());
                }
                if (brandCodeAmountMap.get(brandCode) == null) {brandCodeAmountMap.put(brandCode, 0);
                }
                if (salesOrderIdApproversMap.get(salesOrderId) == null) {salesOrderIdApproversMap.put(salesOrderId, new List<Id>());
                }
                
                brandCodeSalesOrderItemsMap.get(brandCode).add(salesOrderItem);
                brandCodeAmountMap.put(brandCode, brandCodeAmountMap.get(brandCode) + amount);
            }
            
            final Map<String, List<ASI_CRM_Route_Rule_Detail__c>> apCodeRouteRuleDetailsMap = getApCodeRouteRuleDetailsMap();
            final List<ASI_CRM_Route_Rule_Detail__c> routeRuleDetails = apCodeRouteRuleDetailsMap.get(salesOrder.ASI_CRM_AP_Code__c);
            final Map<String, List<ASI_CRM_Route_Rule_Detail__c>> brandCodeRouteRuleDetailsMap = getBrandCodeRouteDetailsMap(routeRuleDetails);
            
            for (String brandCode : brandCodeSalesOrderItemsMap.keySet()) {
                final List<ASI_CRM_Route_Rule_Detail__c> ruleDetails = brandCodeRouteRuleDetailsMap.get(brandCode);
                
                if (ruleDetails == null) {ruleDetails = brandCodeRouteRuleDetailsMap.get(BRAND_CODE_EMPTY);
                }
                if (ruleDetails == null) {ruleDetails = brandCodeRouteRuleDetailsMap.get(BRAND_CODE_OTHERS);
                } 
                if (ruleDetails == null) continue;
                
                for (ASI_CRM_Route_Rule_Detail__c ruleDetail : ruleDetails) {
                    if (brandCodeAmountMap.get(brandCode) > ruleDetail.ASI_CRM_Threshold__c) {
                        salesOrderIdApproversMap.get(salesOrderId).add(ruleDetail.ASI_CRM_Approver__c);
                    }
                }
            }
            
            addApprovers(salesOrderIdObjectMap.get(salesOrderId), salesOrderIdApproversMap.get(salesOrderId));
        }
    }
    @testVisible
    private static Map<String, List<ASI_CRM_Route_Rule_Detail__c>> getBrandCodeRouteDetailsMap(
        List<ASI_CRM_Route_Rule_Detail__c> ruleDetails
    ) {
        final Map<String, List<ASI_CRM_Route_Rule_Detail__c>> brandCodeRouteDetailsMap =
            new Map<String, List<ASI_CRM_Route_Rule_Detail__c>>();
        
        if (ruleDetails == null) return brandCodeRouteDetailsMap;
        
        for (ASI_CRM_Route_Rule_Detail__c ruleDetail : ruleDetails) {
            if (ruleDetail.ASI_CRM_Brand_Code__c == null) continue;
            
            final List<String> brandCodes = ruleDetail.ASI_CRM_Brand_Code__c.split(',');
            
            for (String brandCode : brandCodes) {
                if (brandCodeRouteDetailsMap.get(brandCode) == null) {
                    brandCodeRouteDetailsMap.put(brandCode, new List<ASI_CRM_Route_Rule_Detail__c>());
                }
                
                brandCodeRouteDetailsMap.get(brandCode).add(ruleDetail);
            }
        }
        
        return brandCodeRouteDetailsMap;
    }
    @testVisible
    private static List<ASI_CRM_JP_Sales_Order_Item__c> getItemsBySalesOrderIds(Set<Id> salesOrderIds) {
        return [
            SELECT Id, Name, ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_TH_CRM_Brand_Code__c, ASI_CRM_Quantity__c,
            ASI_CRM_Sales_Order__c,
            ASI_CRM_Unit_Price__c, //WL 1.0
            ASI_CRM_SKU__r.ASI_MFM_Item_Group__r.ASI_CRM_Standard_Cost__c
            FROM ASI_CRM_JP_Sales_Order_Item__c
            WHERE ASI_CRM_Sales_Order__c IN :salesOrderIds
        ];
    }
    @testVisible
    private static Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>> getSalesOrderIdItemsMap(
        List<ASI_CRM_JP_Sales_Order_Item__c> items
    ) {
        final Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>> salesOrderIdItemsMap =
            new Map<Id, List<ASI_CRM_JP_Sales_Order_Item__c>>();
        for (ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : items) {
            final Id salesOrderId = salesOrderItem.ASI_CRM_Sales_Order__c;
            
            if (salesOrderIdItemsMap.get(salesOrderId) == null) { salesOrderIdItemsMap.put(salesOrderId, new List<ASI_CRM_JP_Sales_Order_Item__c>());
            }
            salesOrderIdItemsMap.get(salesOrderId).add(salesOrderItem);
        }
        
        return salesOrderIdItemsMap;
    }
    @testVisible
    private static List<ASI_CRM_Route_Rule_Detail__c> getRouteDetails() {
        return [
            SELECT Id, Name, ASI_CRM_Brand_Code__c, ASI_CRM_Threshold__c, ASI_CRM_Lowest_Threshold__c,
            ASI_CRM_Approver__c, ASI_CRM_JP_Approver_Type__c, ASI_CRM_JP_Approval_Sequence__c,
            ASI_CRM_Route_Type__r.ASI_CRM_A_P_Code__c
            FROM ASI_CRM_Route_Rule_Detail__c
            WHERE ASI_CRM_Route_Type__r.ASI_CRM_Module__c = 'Sales Order'
            AND ASI_CRM_Route_Type__r.ASI_CRM_Module_Record_Type__c = 'Marketing FOC'
            AND ASI_CRM_Route_Type__r.RecordType.Name = 'JP Sales Order Route Type'
            ORDER BY ASI_CRM_JP_Approval_Sequence__c ASC
        ];
    }
    @testVisible
    private static Map<String, List<ASI_CRM_Route_Rule_Detail__c>> getApCodeRouteRuleDetailsMap() {
        final Map<String, List<ASI_CRM_Route_Rule_Detail__c>> apCodeRuleDetailMap = new
            Map<String, List<ASI_CRM_Route_Rule_Detail__c>>();
        
        for (ASI_CRM_Route_Rule_Detail__c detail : getRouteDetails()) {
            final String apCode = detail.ASI_CRM_Route_Type__r.ASI_CRM_A_P_Code__c;
            if (apCode == null) continue;
            
            if (apCodeRuleDetailMap.get(apCode) == null) {apCodeRuleDetailMap.put(apCode, new List<ASI_CRM_Route_Rule_Detail__c>());
            }
            
            apCodeRuleDetailMap.get(apCode).add(detail);
        }
        
        return apCodeRuleDetailMap;
    }
    @testVisible
    private static void addApprovers(ASI_CRM_JP_Sales_Order__c salesOrder, List<Id> approvers) {
        if (salesOrder == null || approvers == null) return;
        
        Integer counter = 0;
        while (counter < approvers.size()) {
            final Id approver = approvers.get(counter);
            counter++;
            
            if (isAlreadyAnApprover(salesOrder, approver)) continue;
            
            if (salesOrder.ASI_CRM_JP_Approver_1__c == null) {
                salesOrder.ASI_CRM_JP_Approver_1__c = approver;
            } else if (salesOrder.ASI_CRM_JP_Approver_2__c == null) {
                salesOrder.ASI_CRM_JP_Approver_2__c = approver;
            } else if (salesOrder.ASI_CRM_JP_Approver_3__c == null) {
                salesOrder.ASI_CRM_JP_Approver_3__c = approver;
            } else if (salesOrder.ASI_CRM_JP_Approver_4__c == null) {
                salesOrder.ASI_CRM_JP_Approver_4__c = approver;
            } else if (salesOrder.ASI_CRM_JP_Approver_5__c == null) {
                salesOrder.ASI_CRM_JP_Approver_5__c = approver;
            } else if (salesOrder.ASI_CRM_JP_Approver_6__c == null) {
                salesOrder.ASI_CRM_JP_Approver_6__c = approver;
            }
            
        }
    }
    
    @testVisible
    private static Boolean isAlreadyAnApprover(ASI_CRM_JP_Sales_Order__c salesOrder, Id userId) {
        final Set<Id> approvers = new Set<Id>();
        
        if (salesOrder.ASI_CRM_JP_Approver_1__c != null) approvers.add(salesOrder.ASI_CRM_JP_Approver_1__c);
        if (salesOrder.ASI_CRM_JP_Approver_2__c != null) approvers.add(salesOrder.ASI_CRM_JP_Approver_2__c);
        if (salesOrder.ASI_CRM_JP_Approver_3__c != null) approvers.add(salesOrder.ASI_CRM_JP_Approver_3__c);
        if (salesOrder.ASI_CRM_JP_Approver_4__c != null) approvers.add(salesOrder.ASI_CRM_JP_Approver_4__c);
        if (salesOrder.ASI_CRM_JP_Approver_5__c != null) approvers.add(salesOrder.ASI_CRM_JP_Approver_5__c);
        if (salesOrder.ASI_CRM_JP_Approver_6__c != null) approvers.add(salesOrder.ASI_CRM_JP_Approver_6__c);
        
        return approvers.contains(userId);
    }
    
    /***************
Data Retrievement Function
***************/
    @testVisible
    private Map<String, ASI_CRM_Route_Type__c> retrieveRouteTypeList() {
        String query = 'SELECT ' + genQueryField(ROUTE_TYPE_FIELD_MAP) + ' ' +
            ', (SELECT ' + genQueryField(ROUTE_TYPE_DETAIL_FIELD_MAP) + ' FROM ASI_CRM_Route_Rule_Details__r ORDER BY ASI_CRM_JP_Approval_Sequence__c) ' +
            'FROM ASI_CRM_Route_Type__c ' +
            'WHERE RecordType.DeveloperName = :ROUTE_TYPE_RECORD_TYPE ' +
            'AND ASI_CRM_Module__c = :ROUTE_TYPE_MODULE ' +
            'AND ASI_CRM_Module_Record_Type__c in :RECORD_TYPE_MODULE_FILTER_LIST';
        
        
        
        Map<String, ASI_CRM_Route_Type__c> routeTypeMap = new Map<String, ASI_CRM_Route_Type__c>();
        for(ASI_CRM_Route_Type__c routeType : (List<ASI_CRM_Route_Type__c>) Database.query(query)) {
            String key = routeType.ASI_CRM_Module_Record_Type__c;
            if(String.isNotBlank(routeType.ASI_CRM_User__c)) { key += '_' + routeType.ASI_CRM_User__c;
            }
            if(String.isNotBlank(routeType.ASI_CRM_Role__c)) { key += '_' + routeType.ASI_CRM_Role__c;
            }
            if(routeTypeMap.containsKey(key) == false) {
                routeTypeMap.put(key, routeType);
            }
        }
        
        return routeTypeMap;
    }
    @testVisible
    private Map<Id, User> retrieveUser(Set<Id> userIdSet) {
        String query = 'SELECT Id, ManagerId, UserRole.Name ' +
            'FROM User ' +
            'WHERE Id in : userIdSet';
        return new Map<Id, User>((List<User>) Database.query(query));
    }
    
    private static List<ASI_CRM_JP_Sales_Order_Item__c> getSalesOrderItemsBySalesOrders(
        List<ASI_CRM_JP_Sales_Order__c> salesOrders,
        Id salesOrderRecordType
    ){
        if(salesOrders.size() == 0) {return new List<ASI_CRM_JP_Sales_Order_Item__c>();
        }
        List<Id> idList = new List<Id>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder: salesOrders) {
            if(salesOrder.Id != null) {
                idList.add(salesOrder.Id);
            }
        }
        system.debug('idList:' + idList);
        system.debug('salesOrderRecordType' + salesOrderRecordType);

        List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItems = new List<ASI_CRM_JP_Sales_Order_Item__c>();
        if(idList.size() > 0) {
            salesOrderItems = [
                    SELECT Id, Name, ASI_CRM_Quantity__c, ASI_CRM_SKU_Item__c, ASI_CRM_Sales_Order__c
                    FROM ASI_CRM_JP_Sales_Order_Item__c
                    WHERE ASI_CRM_Sales_Order__r.Id IN :idList
                    //AND ASI_CRM_Sales_Order__r.RecordTypeId = :salesOrderRecordType
            ];
        }
        return salesOrderItems;
    }
    @testVisible
    private static List<ASI_CRM_JP_Item_Availability__c> getItemAvailabitlity(List<Id> skuCodeIds) {
        return [
            SELECT Id, ASI_Quantity_Adjustment__c, ASI_Quantity_Hard_Commit__c, ASI_Quantity_Soft_Commit__c
            FROM ASI_CRM_JP_Item_Availability__c
            WHERE ASI_SKU__c IN :skuCodeIds
        ];
    }
    
    /***************
Tools Function
***************/
    @testVisible
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
    @testVisible
    private static Boolean isSubmitForApproval(ASI_CRM_JP_Sales_Order__c salesOrder) {
        system.debug('salesOrder.Allow_Submit_Approval__c========================='+salesOrder.Allow_Submit_Approval__c);
        return salesOrder.Allow_Submit_Approval__c;
    }
    @testVisible
    private static Boolean isValidRecordType(ASI_CRM_JP_Sales_Order__c salesOrder) {
        system.debug('525=============>'+salesOrder);
        if (salesOrder == null) return false;
        
        final String OBJECT_NAME = ASI_CRM_JP_Sales_Order__c.sObjectType.getDescribe().getName();
        
        return (
            Global_RecordTypeCache.getRtId(
                OBJECT_NAME + MARKETING_FOC_SALES_ORDER_RECORD_TYPE
            ).equals(salesOrder.RecordTypeId) /*||
            Global_RecordTypeCache.getRtId(
                OBJECT_NAME + DIRECT_SALES_SALES_ORDER_RECORD_TYPE
            ).equals(salesOrder.RecordTypeId)*/);
    }
}