/*********************************************************************************
 * Name: ASI_CRM_VN_PromotionRequest_ValidCtrl
 * Description: Check the promotion request before submit for approval
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/12/2017       Hugo Cheung             Created
 * 18/12/2018		Calvin Chiu				Added approval reason          
*/
public class ASI_CRM_VN_PromotionRequest_ValidCtrl {
    
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> REQUEST_FIELD_MAP              = Schema.SObjectType.ASI_GiftBox_Request_Header__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> REQUEST_ITEM_FIELD_MAP         = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PROMOTION_PLAN_FIELD_MAP       = Schema.SObjectType.ASI_CRM_Trade_A_P_Plan__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PROMOTION_PLAN_ITEM_FIELD_MAP  = Schema.SObjectType.ASI_CRM_Trade_A_P_Plan_Item__c.fields.getMap();
    
	private final static String CONTRACT_EXPENDITURE_ITEM_TYPE = 'Promotion';

    private final static Set<String> PROMOTION_REQUEST_RECORD_TYPE_SET = new Set<String> {
    	'ASI_CRM_VN_Promotion_Request',
        'ASI_CRM_VN_Promotion_Request_Read_Only'
    };
    
    private final static Set<String> PROMOTION_REQUEST_STATUS = new Set<String> {
    	'Submitted',
        'Complete'
    };
    
    public String errorMsg {get; set;}
    public String reason {get; set;}
	public String promotionRequestId {get; set;}
   
    public ASI_CRM_VN_PromotionRequest_ValidCtrl() {
        promotionRequestId = ApexPages.currentPage().getParameters().get('id');
        reason = ApexPages.currentPage().getParameters().get('reason');
        
        ASI_GiftBox_Request_Header__c promotionRequest = retrieveRequest(promotionRequestId);
        List<ASI_GiftBox_Request_Item__c> promotionRequestItemList = retrieveRequestItemList(promotionRequestId);
        
        if(promotionRequestItemList.size() == 0) {
            errorMsg = 'Promotion Request does not contain item.';
        	return;
        }
        
        //Data pre processing
        Set<Id> customerIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> planIdSet     = new Set<Id>();
        
        customerIdSet.add(promotionRequest.ASI_CRM_Customer__c);
        contractIdSet.add(promotionRequest.ASI_CRM_VN_Contract__c);
        planIdSet.add(promotionRequest.ASI_CRM_Trade_A_P_Plan__c);
        
        //Get required records
        Map<Id, ASI_CRM_Trade_A_P_Plan__c> planMap                               = new Map<Id, ASI_CRM_Trade_A_P_Plan__c>(retrievePromotionPlan(planIdSet));
        Map<Id, List<ASI_CRM_Trade_A_P_Plan_Item__c>> planItemMap                = (Map<Id, List<ASI_CRM_Trade_A_P_Plan_Item__c>>) convertToKeyListMap(retrievePromotionPlanItem(planIdSet), 'ASI_CRM_Trade_A_P_Plan__c');
        Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>> contractExpenditureMap = (Map<Id, List<ASI_CRM_VN_Contract_Expenditure__c>>) convertToKeyListMap(retrieveContractExpenditure(contractIdSet), 'ASI_CRM_VN_Contract__c');
        Map<Id, List<ASI_GiftBox_Request_Header__c>> customerPromotionRequestMap = (Map<Id, List<ASI_GiftBox_Request_Header__c>>) convertToKeyListMap(retrieveSameOutletRequest(customerIdSet), 'ASI_CRM_Customer__c');

       	ASI_CRM_Trade_A_P_Plan__c plan = planMap.get(promotionRequest.ASI_CRM_Trade_A_P_Plan__c);
        
        //Check Promotion Plan Balance Amount
        if(plan.ASI_CRM_Balance_Amount__c < promotionRequest.ASI_CRM_VN_Amount__c) {
            errorMsg = 'Promotion Request is exceed the promotion plan balance amount.';
        	return;
        }
        System.debug(customerPromotionRequestMap);
        System.debug(customerPromotionRequestMap.get(promotionRequest.ASI_CRM_Customer__c));

        //Check Promotion Plan Balance Outlet
        Boolean outletAlreadyContainsInPlan = false;
        if (customerPromotionRequestMap.get(promotionRequest.ASI_CRM_Customer__c) != null) {
            for (ASI_GiftBox_Request_Header__c otherPromotionRequest : customerPromotionRequestMap.get(promotionRequest.ASI_CRM_Customer__c)) {
                if (otherPromotionRequest.Id != promotionRequest.Id &&
                        otherPromotionRequest.ASI_CRM_Trade_A_P_Plan__c == promotionRequest.ASI_CRM_Trade_A_P_Plan__c)
                    outletAlreadyContainsInPlan = true;
            }
        }

        if(outletAlreadyContainsInPlan == false && 
           plan.ASI_CRM_Outlet_Balance__c == 0) {
            errorMsg = 'Promotion Request exceeds the promotion plan balance outlet.';
        	return;
        }
      	
        //Check Promotion Plan Item Balance Quantity
        Map<String, ASI_CRM_Trade_A_P_Plan_Item__c> planItemSchemeMap = new Map<String, ASI_CRM_Trade_A_P_Plan_Item__c>();
        for(ASI_CRM_Trade_A_P_Plan_Item__c planItem : planItemMap.get(promotionRequest.ASI_CRM_Trade_A_P_Plan__c)) {
            planItemSchemeMap.put(planItem.ASI_CRM_Promotion_Scheme__c, planItem);
        }
        
        for(ASI_GiftBox_Request_Item__c promotionRequestItem : promotionRequestItemList) {
            ASI_CRM_Trade_A_P_Plan_Item__c planItem = planItemSchemeMap.get(promotionRequestItem.ASI_CRM_Promotion_Scheme__c);
            if(planItem.ASI_CRM_Balance_Quantity__c < promotionRequestItem.ASI_GiftBox_Request_Quantity__c) {
                errorMsg = 'Promotion Request Item ' + planItem.Name + ' exceeds the promotion plan item balance quantity.';
            	return;
            }
        }
        
        //Check Promotion Contract Expenditure
        ASI_CRM_VN_Contract_Expenditure__c promotionContractExpenditure;
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureMap.get(promotionRequest.ASI_CRM_VN_Contract__c)) {
            if(contractExpenditure.ASI_CRM_VN_Item__c == CONTRACT_EXPENDITURE_ITEM_TYPE) 
                promotionContractExpenditure = contractExpenditure;
        }
        if(promotionContractExpenditure == null) {
            errorMsg = 'System does not find the Promotion Contract Expenditure.';
        	return;
        }
        
        Decimal totalAmount = promotionRequest.ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c == 'USD' 
                            ? promotionRequest.ASI_CRM_VN_Amount__c * promotionRequest.ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c 
                            : promotionRequest.ASI_CRM_VN_Amount__c;
        
        if(promotionContractExpenditure.ASI_CRM_Balance_Amount__c < totalAmount) {
            errorMsg = 'Promotion Request is exceed the promotion contract expenditure balance amount.';
        	return;
        }

    }

    public void updatePromotionRequest(){
        System.debug('updatePromotionRequest![');
        // Update promotion request Sys_Pending Approval flag to true
        promotionRequestId = ApexPages.currentPage().getParameters().get('id');
        ASI_GiftBox_Request_Header__c promotionRequest = retrieveRequest(promotionRequestId);
        promotionRequest.ASI_CRM_Sys_Pending_Approval__c = true;
        update promotionRequest;
    }

    private Map<Id, List<sObject>> convertToKeyListMap(List<sObject> sObjList, String keyField) {
        Map<Id, List<sObject>> sObjMap = new Map<Id, List<sObject>>();
        for(sObject sObj : sObjList) {
            Id key = (Id) sObj.get(keyField);
            List<sObject> tempSObjectList = sObjMap.containsKey(key) ? sObjMap.get(key) : new List<sObject>();
            tempSObjectList.add(sObj);
            sObjMap.put(key, tempSObjectList);
        }
        
        return sObjMap;
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditure(Set<Id> contractIdSet) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) + ' ' +
                       'FROM ASI_CRM_VN_Contract_Expenditure__c ' +
                       'WHERE ASI_CRM_VN_Contract__c in :contractIdSet ' +
                       'AND ASI_CRM_VN_Item__c = :CONTRACT_EXPENDITURE_ITEM_TYPE ';

    	return (List<ASI_CRM_VN_Contract_Expenditure__c>) Database.query(query);
  	}
    
    private ASI_GiftBox_Request_Header__c retrieveRequest(Id requestId) {
    	String query = 'SELECT ' + genQueryField(REQUEST_FIELD_MAP) + 
                       ',ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c, ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c, RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Header__c ' + 
                       'Where Id = :requestId ';
        
        List<ASI_GiftBox_Request_Header__c> requestList = (List<ASI_GiftBox_Request_Header__c>) Database.query(query);
        
    	return requestList.size() == 0 ? null : requestList.get(0);
    }
    
    private List<ASI_GiftBox_Request_Header__c> retrieveSameOutletRequest(Set<Id> customerIdSet) {
        String query = 'SELECT ' + genQueryField(REQUEST_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Header__c ' + 
                       'Where ASI_CRM_Customer__c = :customerIdSet ' + 
                       'AND RecordType.DeveloperName in :PROMOTION_REQUEST_RECORD_TYPE_SET ' + 
                       'AND ASI_GiftBox_Status__c in :PROMOTION_REQUEST_STATUS ';
        
        return (List<ASI_GiftBox_Request_Header__c>) Database.query(query);
    }
    
    private List<ASI_GiftBox_Request_Item__c> retrieveRequestItemList(Id requestId) {
    	String query = 'SELECT ' + genQueryField(REQUEST_ITEM_FIELD_MAP) + 
                       ',ASI_GiftBox_Request_Item__r.Name, ASI_GiftBox_Request_Item__r.ASI_GiftBox_Item_Brand__r.ASI_MFM_Brand_Code__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Item__c ' + 
                       'Where ASI_GiftBox_Request_Id__c = :requestId ';
        
    	return (List<ASI_GiftBox_Request_Item__c>) Database.query(query);
    }
    
    private List<ASI_CRM_Trade_A_P_Plan__c> retrievePromotionPlan(Set<Id> planIdSet) {
        String query = 'SELECT ' + genQueryField(PROMOTION_PLAN_FIELD_MAP) + ' ' + 
                       'FROM ASI_CRM_Trade_A_P_Plan__c ' + 
                       'WHERE Id in :planIdSet ';
        return (List<ASI_CRM_Trade_A_P_Plan__c>) Database.query(query);
    }
    
    private List<ASI_CRM_Trade_A_P_Plan_Item__c> retrievePromotionPlanItem(Set<Id> planIdSet) {
    	String query = 'SELECT ' + genQueryField(PROMOTION_PLAN_ITEM_FIELD_MAP) + ' ' + 
                       'FROM ASI_CRM_Trade_A_P_Plan_Item__c ' + 
                       'WHERE ASI_CRM_Trade_A_P_Plan__c in :planIdSet ';
        
        return (List<ASI_CRM_Trade_A_P_Plan_Item__c>) Database.query(query);
    }
    
    /***************
  	Tools Function
  	***************/
	private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      	String queryField = '';
      	for(String fields : fieldMap.keySet()) {
       		queryField += fields + ',';
   		}
    	return queryField.subString(0, queryField.length() - 1);
    }
}