/*********************************************************************************
 * Name: ASI_CRM_VN_OutletValidateTriggerHandler
 * Test Class : ASI_CRM_VN_OutletValidateTrigHandlerTest
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 09/01/2018       Hugo Cheung             Created  
 * 2020-07-15       PRA                     Add bypass logic        
*/
public class ASI_CRM_VN_OutletValidateTriggerHandler {

    private final static Map<String, Schema.SObjectField> ATTACHEMENT_FIELD_MAP = Schema.SObjectType.Attachment.fields.getMap();
   	
    public ASI_CRM_VN_OutletValidateTriggerHandler() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
    	List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>) newList;
        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = (Map<Id, ASI_CRM_AccountsAdditionalField__c>) oldMap;
        
		List<ASI_CRM_AccountsAdditionalField__c> checkedSpecialOutletCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
        	ASI_CRM_AccountsAdditionalField__c oldCustomer = customerMap.get(customer.Id);
            
            if(oldCustomer.ASI_CRM_Special_Outlet__c == false && 
               customer.ASI_CRM_Special_Outlet__c == true) {
                checkedSpecialOutletCustomer.add(customer);
            }
        }
        
        if(checkedSpecialOutletCustomer.size() > 0 && !ASI_MFM_Function.bypassTriggersFunction('ASI_VN_Admin')) {
            validateSpecialOutlet(checkedSpecialOutletCustomer);
        }
    }
    
    public void validateSpecialOutlet(List<ASI_CRM_AccountsAdditionalField__c> customerList) {
        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>(customerList);
        
        Map<Id, Attachment> attachmentMap = new Map<Id, Attachment>();
        for(Attachment att : retrieveAttachmentList(customerMap.keySet(), UserInfo.getUserId())) {
            if(attachmentMap.containsKey(att.ParentId) == false) {
                attachmentMap.put(att.ParentId, att);
            }
        }
        
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            if(attachmentMap.containsKey(customer.Id) == false) {
                customer.addError('Please upload the attachment before you check the special outlet flag!');
            }
        }
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private List<Attachment> retrieveAttachmentList(Set<Id> customerIdSet, Id ownerId) {
        String query = 'SELECT ' + genQueryField(ATTACHEMENT_FIELD_MAP) + ' ' + 
                       'FROM Attachment ' + 
                       'WHERE ParentId in :customerIdSet ' + 
                       'AND DAY_ONLY(CreatedDate) = TODAY ' + 
                       'AND OwnerId = :ownerId ' + 
                       'ORDER By CreatedDate DESC ';
        
        return (List<Attachment>) Database.query(query);
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