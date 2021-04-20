/*********************************************************************************
 * Name: ASI_CRM_JP_ItemBasePriceAssignApprover
 * Description: Assign the approver of item base price
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_ItemBasePriceAssignApprover extends ASI_CRM_JP_TriggerAbstract {
    
    private final static Map<String, Schema.SObjectField> ROUTE_TYPE_FIELD_MAP        = Schema.SObjectType.ASI_CRM_Route_Type__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> ROUTE_TYPE_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_CRM_Route_Rule_Detail__c.fields.getMap();
    @testVisible
    private final static String ROUTE_TYPE_RECORD_TYPE = 'ASI_CRM_JP_Price_Route_Type';
    private final static String BASE_PRICE_WS_RECORD_TYPE = 'ASI_CRM_JP_Wholesaler_Product_Price';
    private final static String BASE_PRICE_DC_RECORD_TYPE = 'ASI_CRM_JP_D_C_Product_Price';
    private final static String BASE_PRICE_PO_RECORD_TYPE = 'ASI_CRM_JP_Promotion_Product_Price';
    private final static String BASE_PRICE_DS_RECORD_TYPE = 'ASI_CRM_JP_Direct_Sales_Product_Price';
    
    private final static String ROUTE_TYPE_MODULE = 'Item Base Price';
    private final static String ROUTE_TYPE_MODULE_RECORD_TYPE_WS = 'Wholesaler Product Price';
    private final static String ROUTE_TYPE_MODULE_RECORD_TYPE_DC = 'D&C Product Price';
    private final static String ROUTE_TYPE_MODULE_RECORD_TYPE_PO = 'Promotion Product Price';
    private final static String ROUTE_TYPE_MODULE_RECORD_TYPE_DS = 'Direct Sales Product Price';
    @testVisible
    private String ROUTE_TYPE_MODULE_RECORD_TYPE = '';
    
    public ASI_CRM_JP_ItemBasePriceAssignApprover() {
        super('ASI_CRM_JP_ItemBasePriceAssignApprover');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_JP_Customer_Product_Price__c> itemBasePriceList = (List<ASI_CRM_JP_Customer_Product_Price__c>) sObjList;
        Map<Id, ASI_CRM_JP_Customer_Product_Price__c> itemBasePriceMap = (Map<Id, ASI_CRM_JP_Customer_Product_Price__c>) oldMap;
       
        List<ASI_CRM_JP_Customer_Product_Price__c> filteredItemBasePriceList = filterItemBasePrice(itemBasePriceList, itemBasePriceMap);
        
        for(ASI_CRM_JP_Customer_Product_Price__c itemBasePrice : filteredItemBasePriceList) {
            String itemRecordType = Global_RecordTypeCache.getRt(itemBasePrice.RecordTypeId).developerName;
            
            if(itemRecordType == BASE_PRICE_WS_RECORD_TYPE) {
                ROUTE_TYPE_MODULE_RECORD_TYPE = ROUTE_TYPE_MODULE_RECORD_TYPE_WS;
            }else if(itemRecordType == BASE_PRICE_DC_RECORD_TYPE) {
                ROUTE_TYPE_MODULE_RECORD_TYPE = ROUTE_TYPE_MODULE_RECORD_TYPE_DC;
            }else if(itemRecordType == BASE_PRICE_PO_RECORD_TYPE) {
                ROUTE_TYPE_MODULE_RECORD_TYPE = ROUTE_TYPE_MODULE_RECORD_TYPE_PO;
            }else if(itemRecordType == BASE_PRICE_DS_RECORD_TYPE) {
                ROUTE_TYPE_MODULE_RECORD_TYPE = ROUTE_TYPE_MODULE_RECORD_TYPE_DS;
            }
        }
        
        assignApprover(filteredItemBasePriceList);
    }
     @testVisible
    private List<ASI_CRM_JP_Customer_Product_Price__c> filterItemBasePrice(List<ASI_CRM_JP_Customer_Product_Price__c> itemBasePriceList, Map<Id, ASI_CRM_JP_Customer_Product_Price__c> itemBasePriceMap) {
    	if(itemBasePriceMap != null) {
        	return null;
        }
        return itemBasePriceList;
    }
    @testVisible
    private void assignApprover(List<ASI_CRM_JP_Customer_Product_Price__c> itemBasePriceList) {
      
    	List<ASI_CRM_Route_Type__c> routeTypeList = retrieveRouteTypeList();
        if(routeTypeList == null || routeTypeList.size() == 0) {
           
        	return;
            
        }
        
        Set<Id> userIdSet = new Set<Id>();
        for(ASI_CRM_JP_Customer_Product_Price__c itemBasePrice : itemBasePriceList) {
            userIdSet.add(itemBasePrice.ownerId);
             }
        
        Map<Id, User> userMap = retrieveUser(userIdSet);
        
        ASI_CRM_Route_Type__c routeType = routeTypeList.get(0);
        for(ASI_CRM_JP_Customer_Product_Price__c itemBasePrice : itemBasePriceList) {
            
            Integer approverIndex = 1;
            for(ASI_CRM_Route_Rule_Detail__c routeTypeDetail : routeType.ASI_CRM_Route_Rule_Details__r) {
                if(routeTypeDetail.ASI_CRM_JP_Approver_Type__c == 'Line Manager') {
                	itemBasePrice.put('ASI_CRM_JP_Approver_' + approverIndex + '__c', userMap.get(itemBasePrice.OwnerId).ManagerId);
                } else {
                	itemBasePrice.put('ASI_CRM_JP_Approver_' + approverIndex + '__c', routeTypeDetail.ASI_CRM_Approver__c);
                }
                approverIndex++;
            }
        }
    }
    
    /***************
	Data Retrievement Function
	***************/
     @testVisible
    private List<ASI_CRM_Route_Type__c> retrieveRouteTypeList() {
        
        String query = 'SELECT ' + genQueryField(ROUTE_TYPE_FIELD_MAP) + ' ' + 
                       ', (SELECT ' + genQueryField(ROUTE_TYPE_DETAIL_FIELD_MAP) + ' FROM ASI_CRM_Route_Rule_Details__r ORDER BY ASI_CRM_JP_Approval_Sequence__c) ' + 
                       'FROM ASI_CRM_Route_Type__c ' + 
                       'WHERE RecordType.DeveloperName = :ROUTE_TYPE_RECORD_TYPE ' + 
                       'AND ASI_CRM_Module__c = :ROUTE_TYPE_MODULE ' + 
                       'AND ASI_CRM_Module_Record_Type__c = :ROUTE_TYPE_MODULE_RECORD_TYPE';
        
        
        return (List<ASI_CRM_Route_Type__c>) Database.query(query);
    }
     @testVisible
    private Map<Id, User> retrieveUser(Set<Id> userIdSet) {
        String query = 'SELECT Id, ManagerId ' + 
                       'FROM User ' + 
                       'WHERE Id in : userIdSet';
        return new Map<Id, User>((List<User>) Database.query(query));
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
}