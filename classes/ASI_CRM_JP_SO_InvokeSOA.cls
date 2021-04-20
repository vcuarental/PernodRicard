/*********************************************************************************
 * Name: ASI_CRM_JP_SO_InvokeSOA
 * Description: Sync SO to JDE by invoking SOA
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/05/2019       SH Ho                   Created          
 * 31/07/2019       Wilken Lee              [WL 1.0] Correct keyword of Payment Option from "Advance Payment" to "Advanced Payment"
*/
global class ASI_CRM_JP_SO_InvokeSOA extends ASI_CRM_JP_TriggerAbstract {
    
    private final static Map<String, Schema.SObjectField> SALES_ORDER_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ITEM_AVAILABILITY_FIELD_MAP  = Schema.SObjectType.ASI_CRM_JP_Item_Availability__c.fields.getMap();
  
    public ASI_CRM_JP_SO_InvokeSOA() {
        super('ASI_CRM_JP_SO_InvokeSOA');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_JP_Sales_Order__c> salesOrderList   = (List<ASI_CRM_JP_Sales_Order__c>) sObjList;
        Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap = (Map<Id, ASI_CRM_JP_Sales_Order__c>) oldMap;
        ASI_SOA_Setting__c customSetting = ASI_SOA_Setting__c.getValues('ASI_CRM_JP_EnableSOAInterface'); 
        
        for(ASI_CRM_JP_Sales_Order__c so: salesOrderList){
            Boolean isCheck = false;
            if(Global_RecordTypeCache.getRt(so.recordTypeId).developerName.contains('Marketing_FOC') ){                
                if(so.ASI_CRM_Status__c  == 'Approved' && salesOrderMap.get(so.id).ASI_CRM_Status__c  != 'Approved' && so.ASI_CRM_JDE_Synced__c == false){
                    isCheck = true;                                                       
                }  
            }else if (Global_RecordTypeCache.getRt(so.recordTypeId).developerName.contains('Direct_Sales') ){
                
                if(so.ASI_CRM_Payment_Option__c == 'Invoice' && so.ASI_CRM_Status__c == 'Approved' && salesOrderMap.get(so.id).ASI_CRM_Status__c != 'Approved' && so.ASI_CRM_JDE_Synced__c == false){
                    isCheck = true;
                }else if(so.ASI_CRM_Payment_Option__c == 'Advanced Payment' && so.ASI_CRM_Status__c == 'AC Verified' && salesOrderMap.get(so.id).ASI_CRM_Status__c != 'AC Verified' && so.ASI_CRM_JDE_Synced__c == false){  //WL 1.0
                    isCheck = true;
                }
                                
            }
            
            if (customSetting != null && customSetting.ASI_SOA_Enable__c == true && isCheck){
                ASI_CRM_JP_SO_InvokeSOA.invokeJapanSOSOA(so.Id, so.RecordType.Name);
            }
        }
    }
    
    // For Testing Only
    public static void submitSO(Id soId, String recName){
        ASI_CRM_JP_SO_InvokeSOA.invokeJapanSOSOA(soId, recName);
    }
    
    @future(callout=true)   
    public static void invokeJapanSOSOA(Id soId, String recName){
        try {
            ASI_CRM_JP_SO_Creation.JP_CRM_SO_Creation_pt soaProcess = new ASI_CRM_JP_SO_Creation.JP_CRM_SO_Creation_pt();

            String result = soaProcess.process(soId);
            system.debug('Result');

            ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c();
            log.Name = recName.contains('Marketing FOC') ? 'JP Marketing FOC Interface - Normal': 'JP Direct Sales SO Interface - Normal';
            log.ASI_HK_CRM_Before_call_webservice__c = System.now();
            log.ASI_HK_CRM_After_call_web_service__c = System.now();
            log.ASI_HK_CRM_Submitter__c = UserInfo.getUserId();
            log.ASI_HK_CRM_WebService_Error_Message__c = '';//result;
            log.ASI_HK_CRM_WebServiceName__c = 'JP SO Interface By Oracle SOA ' + soId;
            
            insert log;
        }
        catch(exception e) {
            /*
            ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c(Name = recName.contains('Marketing FOC') ? 'JP Marketing FOC Interface - Error': 'JP Direct Sales SO Interface - Error', ASI_HK_CRM_Before_call_webservice__c = System.now(), ASI_HK_CRM_After_call_web_service__c = System.now(), ASI_HK_CRM_Submitter__c = UserInfo.getUserId(), ASI_HK_CRM_WebService_Error_Message__c = e.getMessage(), ASI_HK_CRM_WebServiceName__c = 'JP SO interface Error By Oracle SOA ' + soId);
            insert log;         
			*/
        }
    }
}