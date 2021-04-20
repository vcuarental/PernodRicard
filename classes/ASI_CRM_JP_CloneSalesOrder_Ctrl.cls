/*********************************************************************************
 * Name: ASI_CRM_JP_CloneSalesOrder_Ctrl
 * Description: Controller class for cloning the Sales Order and Sales Order Item
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/04/2017       Hugo Cheung             Created
 * 14/06/2019       Wilson Chow             Bug Fix: should use auto number for cloned sales order name
 * 26/06/2019       Wilson Chow             Allow clone Locked sales order with auto assign number
 * 14/11/2019       Wilken Lee              [WL 1.0] Clear Approved Date for cloned order to avoid auto approved
 * 22/11/2019       Wilken Lee              [WL 2.0] Clear Approved Date for cloned order to avoid error of "FOC cannot be delivered on your requested delivery date due to insufficient shipping lead time."
*/
public class ASI_CRM_JP_CloneSalesOrder_Ctrl {
    
    //Field Schema Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP      = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SALES_ORDER_ITEM_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order_Item__c.fields.getMap();
    
    //Record Type Mapping
    private final static Map<String, String> SALES_ORDER_RECORD_TYPE_MAPPING = new Map<String, String> {
        'ASI_CRM_JP_Direct_Sales_Locked'        => 'ASI_CRM_JP_Direct_Sales',
        'ASI_CRM_JP_Duty_Free_SO_Locked'        => 'ASI_CRM_JP_Duty_Free_SO',
        'ASI_CRM_JP_Employee_Sales_Locked'      => 'ASI_CRM_JP_Employee_Sales',
        'ASI_CRM_JP_Entertainment_Sales_Locked' => 'ASI_CRM_JP_Entertainment_Sales',
        'ASI_CRM_JP_Marketing_FOC_Locked'       => 'ASI_CRM_JP_Marketing_FOC',
        'ASI_CRM_JP_Normal_SO_Locked'           => 'ASI_CRM_JP_Normal_SO',
        'ASI_CRM_JP_Sample_Sales_Locked'        => 'ASI_CRM_JP_Sample_Sales'
    };
    
    //Object API Name
    private final static String SALES_ORDER_API_NAME = 'ASI_CRM_JP_Sales_Order__c';
    
    private final static String SALES_ORDER_ID = 'id';
    private final static String IS_CLONE_CHILD = 'cloneChild';
    
    public ASI_CRM_JP_CloneSalesOrder_Ctrl() {
    }

    public PageReference cloneRecord() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String salesOrderId        = params.get(SALES_ORDER_ID);
        Boolean isCloneChild       = String.isBlank(params.get(IS_CLONE_CHILD)) ? false : Boolean.valueOf(params.get(IS_CLONE_CHILD));
        
        System.Savepoint databaseSavepoint = Database.setSavepoint();
        Id clonedSalesOrderId;
        try {
            clonedSalesOrderId = cloneSalesOrder(salesOrderId);
            if(isCloneChild) {
                cloneSalesOrderLineItem(salesOrderId, clonedSalesOrderId);
            }
        } catch(Exception e) {
            Database.rollback(databaseSavepoint);
            throw e;
        }
        
        PageReference pageRef = new PageReference('/' + clonedSalesOrderId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public Id cloneSalesOrder(String salesOrderId) {
        ASI_CRM_JP_Sales_Order__c salesOrder = retrieveSalesOrder(salesOrderId);

        // 20190614
        Map<String, ASI_CRM_JP_AutoNumberAssignment> autoNumAssignMap = new Map<String, ASI_CRM_JP_AutoNumberAssignment>();
        autoNumAssignMap.put('ASI_CRM_JP_Direct_Sales', new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Direct_Sales'));
        autoNumAssignMap.put('ASI_CRM_JP_Duty_Free_SO', new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Duty_Free_SO'));
        autoNumAssignMap.put('ASI_CRM_JP_Employee_Sales', new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Employee_Sales'));
        autoNumAssignMap.put('ASI_CRM_JP_Entertainment_Sales', new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Entertainment_Sales'));
        autoNumAssignMap.put('ASI_CRM_JP_Marketing_FOC', new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Marketing_FOC'));
        autoNumAssignMap.put('ASI_CRM_JP_Normal_SO', new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Normal_SO'));
        autoNumAssignMap.put('ASI_CRM_JP_Sample_Sales', new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Sample_Sales'));
        // 20190614

        ASI_CRM_JP_Sales_Order__c clonedSalesOrder = salesOrder.clone(false, true, false, false);

        // 20190614
//        clonedSalesOrder.Name              = '';
        String recordTypeName = Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).developerName;
        if(recordTypeName.contains('_Locked')){
            recordTypeName = recordTypeName.substring(0, recordTypeName.indexOf('_Locked'));
        }
        if(autoNumAssignMap.containsKey(recordTypeName)) {
            clonedSalesOrder.Name = autoNumAssignMap.get(recordTypeName).nextAutoNumStr();
        }
        for(ASI_CRM_JP_AutoNumberAssignment autoNumAssign : autoNumAssignMap.values()) {
            autoNumAssign.writeToDB();
        }
        // 20190614

        clonedSalesOrder.ASI_CRM_Status__c = 'Open';
        clonedSalesOrder.OwnerId           = UserInfo.getUserId();
        if(SALES_ORDER_RECORD_TYPE_MAPPING.containsKey(salesOrder.RecordType.DeveloperName)) {
            Id tempRecordTypeId = Global_RecordTypeCache.getRtId(SALES_ORDER_API_NAME + SALES_ORDER_RECORD_TYPE_MAPPING.get(salesOrder.RecordType.DeveloperName));
            clonedSalesOrder.RecordTypeId = tempRecordTypeId;
        }
        clonedSalesOrder.ASI_CRM_JP_JDE_Delivery_Date__c    = null;
        clonedSalesOrder.ASI_CRM_JP_JDE_Shipped_Date__c     = null;
        clonedSalesOrder.ASI_CRM_JP_JDE_SO_number__c        = null;
        clonedSalesOrder.ASI_CRM_JP_JDE_Sync_Date__c        = null;
        clonedSalesOrder.ASI_CRM_JP_Original_Sales_Order__c = null;
        clonedSalesOrder.ASI_CRM_JDE_Synced__c              = false;
        clonedSalesOrder.ASI_CRM_Minimal_Requested_Date__c  = null;
        clonedSalesOrder.ASI_CRM_Latest_Approval_Date__c    = null;
        clonedSalesOrder.ASI_CRM_JP_SO_Approval_Date__c    = null; //WL 1.0
        clonedSalesOrder.ASI_CRM_Requested_Date__c = null; //WL 2.0
        clonedSalesOrder.Allow_Submit_Approval__c = false; //WL 2.0
        insert clonedSalesOrder;

        return clonedSalesOrder.Id;
    }
    
    public void cloneSalesOrderLineItem(String salesOrderId, Id clonedSalesOrderId) {
        List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList = retrieveSalesOrderItemList(salesOrderId);
        
        List<ASI_CRM_JP_Sales_Order_Item__c> clonedSalesOrderItemList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            ASI_CRM_JP_Sales_Order_Item__c tempSalesOrderItem = salesOrderItem.clone(false, true, false, false);
            tempSalesOrderItem.ASI_CRM_Sales_Order__c = clonedSalesOrderId;
            clonedSalesOrderItemList.add(tempSalesOrderItem);
        }
        
        if(clonedSalesOrderItemList.size() > 0) {
            insert clonedSalesOrderItemList;
        }
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private ASI_CRM_JP_Sales_Order__c retrieveSalesOrder(Id salesOrderId) {
        String query = 'SELECT ' + genQueryField(SALES_ORDER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       ', ASI_CRM_Ship_To__r.Name, ASI_CRM_Ship_To__r.ASI_CRM_Customer_Name_Kanji__c ' + 
                       ', ASI_CRM_Sold_To__r.ASI_CRM_Customer_Name_Kanji__c ' + 
                       ', ASI_CRM_Bank_Account__r.Name, ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Name__c ' + 
                       'FROM ASI_CRM_JP_Sales_Order__c ' + 
                       'WHERE Id = :salesOrderId ';
        List<ASI_CRM_JP_Sales_Order__c> salesOrderList = (List<ASI_CRM_JP_Sales_Order__c>) Database.query(query);
        return salesOrderList.size() > 0 ? salesOrderList.get(0) : null;
    }
    
    private List<ASI_CRM_JP_Sales_Order_Item__c> retrieveSalesOrderItemList(Id salesOrderId) {
        String query = 'SELECT ' + genQueryField(SALES_ORDER_ITEM_FIELD_MAP) + 
                       ', ASI_CRM_SKU__r.Name ' + 
                       'FROM ASI_CRM_JP_Sales_Order_Item__c ' + 
                       'WHERE ASI_CRM_Sales_Order__c = :salesOrderId ';
        return (List<ASI_CRM_JP_Sales_Order_Item__c>) Database.query(query);
    }
    
    /***************
    Tools Function
    ***************/
    public String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      String queryField = '';
      for(String fields : fieldMap.keySet()) {
        queryField += fields + ',';
      }
      return queryField.subString(0, queryField.length() - 1);
    }
}