/*********************************************************************************
 * Name: ASI_CRM_JP_SOSalesContract_Ctrl
 * Description: Controller class for ASI_CRM_JP_SOSalesContract_Com
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/08/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOSalesContract_Ctrl {
    
    //Field Schema Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP      = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SALES_ORDER_ITEM_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order_Item__c.fields.getMap();
    
    //Month List
    private final static List<String> monthList = new List<String> {
    	'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    };
    
    //UOM Map
    private final static Map<String, String> uomMap = new Map<String, String> {
    	'BT' => 'bottles',
        'CA' => 'cases',
        'PC' => 'piece'
    };
    
    //Page Parameters
    public Boolean isPageInit {get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}
    
    public String salesOrderId {get; set;}
    public String fontSizeStr  {get; set;}
    
    //For Displaying 
    public Date todayDate = Date.today();
    public ASI_CRM_JP_Sales_Order__c salesOrder                    {get; set;}
    public List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList {get; set;}
    
    public String timeOfDelivery {get; set;}
    public String paymentDate    {get; set;}
    public Decimal totalQuantity {get; set;}
    public String  defaultUOM    {get; set;}
   
    public ASI_CRM_JP_SOSalesContract_Ctrl() {
    }
    
    private Boolean init() {
    	salesOrder         = retrieveSalesOrder(salesOrderId);
        salesOrderItemList = retrieveSalesOrderItemList(salesOrderId);
        calculateSalesOrder();
        
        if(salesOrderItemList.size() > 0) {
            defaultUOM = uomMap.get(salesOrderItemList.get(0).ASI_CRM_UOM__c);
        }
        
        if(salesOrder.ASI_CRM_Requested_Date__c == null) {
        } else {
        	Integer year  = salesOrder.ASI_CRM_Requested_Date__c.year();
            Integer month = salesOrder.ASI_CRM_Requested_Date__c.month();
            Integer day   = salesOrder.ASI_CRM_Requested_Date__c.day();
            timeOfDelivery = monthList.get(month - 1) + ' ' + day + ', ' + year;
        }
        
        if(salesOrder.ASI_CRM_Payment_Request_Date__c == null) {
        } else {
        	Integer year  = salesOrder.ASI_CRM_Payment_Request_Date__c.year();
            Integer month = salesOrder.ASI_CRM_Payment_Request_Date__c.month();
            Integer day   = salesOrder.ASI_CRM_Payment_Request_Date__c.day();
            paymentDate = monthList.get(month - 1) + ' ' + day + ', ' + year;
        }
        
        return true;
    }
    
    private void calculateSalesOrder() {
    	totalQuantity = 0;
        
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
        	totalQuantity += Integer.valueOf(salesOrderItem.ASI_CRM_Quantity__c == null ? 0 : salesOrderItem.ASI_CRM_Quantity__c);
        }
    }
    
	/***************
  	Data Retrievement Function
  	***************/
    private ASI_CRM_JP_Sales_Order__c retrieveSalesOrder(Id salesOrderId) {
    	String query = 'SELECT ' + genQueryField(SALES_ORDER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       ', ASI_CRM_Ship_To__r.ASI_CRM_VN_EnglishName__c, ASI_CRM_Sold_To__r.ASI_CRM_VN_EnglishName__c ' + 
                       'FROM ASI_CRM_JP_Sales_Order__c ' + 
                       'WHERE Id = :salesOrderId ';
        List<ASI_CRM_JP_Sales_Order__c> salesOrderList = (List<ASI_CRM_JP_Sales_Order__c>) Database.query(query);
        return salesOrderList.size() > 0 ? salesOrderList.get(0) : null;
    }
    
    private List<ASI_CRM_JP_Sales_Order_Item__c> retrieveSalesOrderItemList(Id salesOrderId) {
    	String query = 'SELECT ' + genQueryField(SALES_ORDER_ITEM_FIELD_MAP) + ', toLabel(ASI_CRM_UOM__c) ' + 
                       ', ASI_CRM_SKU__r.Name, ASI_CRM_SKU__r.ASI_CRM_JP_English_Name__c ' + 
                       'FROM ASI_CRM_JP_Sales_Order_Item__c ' + 
                       'WHERE ASI_CRM_Sales_Order__c = :salesOrderId ' + 
                       'AND ASI_CRM_Status__c != \'980-Cancelled\'';
        return (List<ASI_CRM_JP_Sales_Order_Item__c>) Database.query(query);
    }
    
    /***************
  	Tools Function
  	***************/
    public String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      String queryField = '';
      for(String fields : fieldMap.keySet()) {
      if(fields != 'ASI_CRM_UOM__c') {
       queryField += fields + ',';
        }
      }
      return queryField.subString(0, queryField.length() - 1);
    }
}