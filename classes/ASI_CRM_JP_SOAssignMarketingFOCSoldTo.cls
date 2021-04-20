/*********************************************************************************
 * Name: ASI_CRM_JP_SOAssignMarketingFOCSoldTo
 * Description: Assign the Sold To to sales order when order type is sample so or posm
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/30/2019       SH Ho                   Created          
*/
public class ASI_CRM_JP_SOAssignMarketingFOCSoldTo extends ASI_CRM_JP_TriggerAbstract {
    
    //Field Map
  private final static Map<String, Schema.SObjectField> CUSTOMER_FIELD_MAP = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.fields.getMap();
    
    private static Set<String> ORDER_TYPE_FILTER_SET = new Set<String> {
      'Marketing FOC'
        
    };
    
    private static String RECORD_TYPE_FILTER_STRING = 'ASI_CRM_JP_Marketing_FOC';
    
    private static String DEFAULT_SOLD_TO_CODE = '99999999';
    
    public ASI_CRM_AccountsAdditionalField__c customer;
    
    public ASI_CRM_JP_SOAssignMarketingFOCSoldTo() {
        super('ASI_CRM_JP_SOAssignMarketingFOCSoldTo');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_JP_Sales_Order__c> trigger_new = (List<ASI_CRM_JP_Sales_Order__c>) sObjList;
        Map<Id, ASI_CRM_JP_Sales_Order__c> trigger_oldMap = (Map<Id, ASI_CRM_JP_Sales_Order__c>) oldMap;
            
        for(ASI_CRM_JP_Sales_Order__c salesOrder : trigger_new) {
            if(Global_RecordTypeCache.getRt(salesOrder.recordTypeid).developerName.contains('ASI_CRM_JP_Marketing_FOC'))
            	customer = retrieveCustomerFromCode(DEFAULT_SOLD_TO_CODE);
            if(customer != null){
                salesOrder.ASI_CRM_Sold_To__c  = customer.Id;
                salesOrder.ASI_CRM_Tax_Area__c = customer.ASI_CRM_SG_Tax_Rate_Area__c;
                salesOrder.ASI_CRM_Tax_Code__c = customer.ASI_CRM_SG_Tax_Expl_Code__c;
            }
            
            if(oldMap != null){
                if(Global_RecordTypeCache.getRt(salesOrder.recordTypeid).developerName.contains('ASI_CRM_JP_Marketing_FOC') ||
                   Global_RecordTypeCache.getRt(salesOrder.recordTypeid).developerName.contains('ASI_CRM_JP_Direct_Sales')){
                       if(trigger_oldMap.get(salesOrder.id).ASI_CRM_JP_JDE_SO_number__c == null && salesOrder.ASI_CRM_JP_JDE_SO_number__c != null){
                           salesOrder.ASI_CRM_JP_JDE_Status__c = '520-560';
                       }
                   }
            }
        }
        
    }
        
    
    /***************
  Data Retrievement Function
  ***************/
   
    private ASI_CRM_AccountsAdditionalField__c retrieveCustomerFromCode(String customerCode) {
    String query = 'SELECT id, ASI_CRM_SG_Tax_Rate_Area__c, ASI_CRM_SG_Tax_Expl_Code__c' + 
                   ', RecordType.DeveloperName ' + 
                   'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                   'Where ASI_CRM_CN_CRM_Code__c = :customerCode';
    List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    return customerList.size() == 0 ? null : customerList.get(0);
  }
    
 
}