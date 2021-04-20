/*********************************************************************************
 * Name: ASI_CRM_VN_CapsuleCSRequestItemTableCtrl
 * Description: Controller for ASI_CRM_VN_CapsuleCSRequestItemTableCmp
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/11/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_CapsuleCSRequestItemTableCtrl {
    
    private final static Map<String, Schema.SObjectField> REQUEST_ITEM_FIELD_MAP = Schema.SObjectType.ASI_GiftBox_Request_Item__c.fields.getMap();
    
    public String requestId {get; set;}
    
    //Page Parameters
    public Boolean isPageInit {get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}
    
    public List<ASI_GiftBox_Request_Item__c> requestItemList {get; set;}
    
    public ASI_CRM_VN_CapsuleCSRequestItemTableCtrl() {
    	System.debug(requestId);
    }
    
    private Boolean init() {
        requestItemList = retrieveRequestItemList(requestId);
        System.debug(requestItemList);
        return true;
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private List<ASI_GiftBox_Request_Item__c> retrieveRequestItemList(Id requestId) {
        String query = 'SELECT ' + genQueryField(REQUEST_ITEM_FIELD_MAP) + 
                       ', ASI_CRM_Subbrand__r.Name ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Item__c ' + 
                       'Where ASI_GiftBox_Request_Id__c = :requestId ';
        
        return (List<ASI_GiftBox_Request_Item__c>) Database.query(query);
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