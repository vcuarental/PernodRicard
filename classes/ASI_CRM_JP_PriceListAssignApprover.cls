/*********************************************************************************
 * Name: ASI_CRM_JP_PriceListAssignApprover
 * Description: Assign the approver of price list
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_PriceListAssignApprover extends ASI_CRM_JP_TriggerAbstract {
    
    private final static Map<String, Schema.SObjectField> ROUTE_TYPE_FIELD_MAP        = Schema.SObjectType.ASI_CRM_Route_Type__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> ROUTE_TYPE_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_CRM_Route_Rule_Detail__c.fields.getMap();
    
    private final static String ROUTE_TYPE_RECORD_TYPE = 'ASI_CRM_JP_Price_Route_Type';
     @testVisible
    private final static String PRICE_LIST_WS_RECORD_TYPE = 'Wholesaler Product Price';
    private final static String PRICE_LIST_DC_RECORD_TYPE = 'D&C Product Price';
    private final static String PRICE_LIST_PO_RECORD_TYPE = 'Promotion Product Price';
    private final static String PRICE_LIST_DS_RECORD_TYPE = 'Direct Sales Product Price';
    
    private final static String ROUTE_TYPE_MODULE = 'Price List';
     @testVisible
    private String ROUTE_TYPE_MODULE_RECORD_TYPE = '';
    
    public ASI_CRM_JP_PriceListAssignApprover() {
        super('ASI_CRM_JP_PriceListAssignApprover');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	List<ASI_CRM_Price_List__c> priceList = (List<ASI_CRM_Price_List__c>) sObjList;
       	Map<Id, ASI_CRM_Price_List__c> priceMap = (Map<Id, ASI_CRM_Price_List__c>) oldMap;
    
        List<ASI_CRM_Price_List__c> filteredPriceList = filterPriceList(priceList, priceMap);
    	for(ASI_CRM_Price_List__c pricelistitem : filteredPriceList) {
            String pricetype = pricelistitem.ASI_CRM_Price_Type__c;
            if(pricetype == PRICE_LIST_WS_RECORD_TYPE) {
                ROUTE_TYPE_MODULE_RECORD_TYPE = PRICE_LIST_WS_RECORD_TYPE;
            }else if(pricetype == PRICE_LIST_DC_RECORD_TYPE) {
                ROUTE_TYPE_MODULE_RECORD_TYPE = PRICE_LIST_DC_RECORD_TYPE;
            }else if(pricetype == PRICE_LIST_PO_RECORD_TYPE) {
                ROUTE_TYPE_MODULE_RECORD_TYPE = PRICE_LIST_PO_RECORD_TYPE;
            }else if(pricetype == PRICE_LIST_DS_RECORD_TYPE) {
                ROUTE_TYPE_MODULE_RECORD_TYPE = PRICE_LIST_DS_RECORD_TYPE;
            }    
        }
        assignApprover(filteredPriceList);
    }
    @testVisible
    private List<ASI_CRM_Price_List__c> filterPriceList(List<ASI_CRM_Price_List__c> priceList, Map<Id, ASI_CRM_Price_List__c> priceMap) {
        if(priceMap != null) {
        	return null;
        }
        return priceList;
    }
    @testVisible
    private void assignApprover(List<ASI_CRM_Price_List__c> priceList) {
    	List<ASI_CRM_Route_Type__c> routeTypeList = retrieveRouteTypeList();
        
        if(routeTypeList == null || routeTypeList.size() == 0) {
        	return;
        }
        
        Set<Id> userIdSet = new Set<Id>();
        for(ASI_CRM_Price_List__c price : priceList) {
            userIdSet.add(price.ownerId);
            
            
        }
        
        Map<Id, User> userMap = retrieveUser(userIdSet);
        
        ASI_CRM_Route_Type__c routeType = routeTypeList.get(0);
        for(ASI_CRM_Price_List__c price : priceList) {
            
            Integer approverIndex = 1;
            for(ASI_CRM_Route_Rule_Detail__c routeTypeDetail : routeType.ASI_CRM_Route_Rule_Details__r) {
                if(routeTypeDetail.ASI_CRM_JP_Approver_Type__c == 'Line Manager') {
                	price.put('ASI_CRM_JP_Approver_' + approverIndex + '__c', userMap.get(price.OwnerId).ManagerId);
                } else {
                	price.put('ASI_CRM_JP_Approver_' + approverIndex + '__c', routeTypeDetail.ASI_CRM_Approver__c);
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
                       'FROM ASI_CRM_Route_Type__c '  + 
                      'WHERE RecordType.DeveloperName = :ROUTE_TYPE_RECORD_TYPE ' + 
                       'AND ASI_CRM_Module__c = :ROUTE_TYPE_MODULE ' + 
                       'AND ASI_CRM_Module_Record_Type__c = :ROUTE_TYPE_MODULE_RECORD_TYPE ';
        
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