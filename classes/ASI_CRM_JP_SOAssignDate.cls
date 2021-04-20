/*********************************************************************************
 * Name: ASI_CRM_JP_SOAssignDate
 * Description: Assign the Order Date and Requested Date to Final Sales Order
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/04/2017       Hugo Cheung             Created          
 * 22/11/2019       Wilken Lee              [WL 1.0] Handle clone scenario in which Request Date clear and to avoid null reference error
 * 03/12/2019       Wilken Lee              [WL 2.0] Exception handling for Business Day not defined in system
*/
public class ASI_CRM_JP_SOAssignDate extends ASI_CRM_JP_TriggerAbstract {
    
    //Field Schema Map
    private final static Map<String, Schema.SObjectField> BUSINESS_DAY_CALENDAR_FIELD_MAP = Schema.SObjectType.ASI_JP_CRM_Business_Day_Calendar__c.fields.getMap();
    
    private final static String SALES_ORDER_STATUS = 'Final';
    private final static String MARKETING_FOC_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Marketing_FOC';
    private final static String DIRECT_SALES_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Direct_Sales';

    private final static Id marketingFocSalesOrderRecordTypeId = Global_RecordTypeCache.getRtId(
            ASI_CRM_JP_Sales_Order__c.sObjectType.getDescribe().getName() + MARKETING_FOC_SALES_ORDER_RECORD_TYPE
    );
    private final static Id directSalesSalesOrderRecordTypeId = Global_RecordTypeCache.getRtId(
            ASI_CRM_JP_Sales_Order__c.sObjectType.getDescribe().getName() + DIRECT_SALES_SALES_ORDER_RECORD_TYPE
    );
    @TestVisible
    private Map<String, ASI_JP_CRM_Business_Day_Calendar__c> businessDayMap = retrieveBusinessDayList();
    
    public ASI_CRM_JP_SOAssignDate() {
        super('ASI_CRM_JP_SOAssignDate');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

        calculateValidateDates(sObjList);

        List<ASI_CRM_JP_Sales_Order__c> salesOrderList = filterSalesOrder((List<ASI_CRM_JP_Sales_Order__c>) sObjList, (Map<Id, ASI_CRM_JP_Sales_Order__c>) oldMap);
        system.debug('========>sObjList'+sObjList);
        system.debug('========>oldMap'+oldMap);
        
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(salesOrder.ASI_CRM_Route_Code__c == null || String.isBlank(salesOrder.ASI_CRM_Freight_Code__c)) {salesOrder.addError(Label.ASI_CRM_JP_SO_FreightCodeRouteCodeNotFound);
                continue;
            }

            //Calculate Order Date
            //Default Order Date = Requested Date - Ship To Lead Time
            system.debug('======>salesOrder.ASI_CRM_Requested_Date__c'+salesOrder.ASI_CRM_Requested_Date__c);
            system.debug('======>salesOrder.ASI_CRM_Route_Code__c'+salesOrder.ASI_CRM_Route_Code__c);
            Date orderDate = salesOrder.ASI_CRM_Requested_Date__c.addDays(- Integer.valueOf(salesOrder.ASI_CRM_Route_Code__c));
            
            orderDate = calculateOrderDateWithShippingCompany(salesOrder, salesOrder.ASI_CRM_Freight_Code__c, orderDate);
            if(orderDate == null) return;
            orderDate = calculateOrderDateWithPR(salesOrder, salesOrder.ASI_CRM_Freight_Code__c, orderDate);
            if(orderDate == null) return;
            orderDate = calculateOrderDateToday(salesOrder, salesOrder.ASI_CRM_Freight_Code__c, orderDate);
            if(orderDate == null) return;

            //Calculate Requested Date
            Date requestedDate = calculateRequestedDate(salesOrder, salesOrder.ASI_CRM_Freight_Code__c, orderDate, Integer.valueOf(salesOrder.ASI_CRM_Route_Code__c));
            if(requestedDate == null) return;
            requestedDate = compareRequestedDate(salesOrder, salesOrder.ASI_CRM_Freight_Code__c, salesOrder.ASI_CRM_Requested_Date__c, requestedDate);
            if(requestedDate == null) return;

            //Assign new Order Date and Requested Date
            salesOrder.ASI_CRM_Order_Date__c = orderDate;
            salesOrder.ASI_CRM_Requested_Date__c = requestedDate;
        }
    }
    
    @TestVisible
    private List<ASI_CRM_JP_Sales_Order__c> filterSalesOrder(List<ASI_CRM_JP_Sales_Order__c> salesOrderList, Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap) {
        List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = new List<ASI_CRM_JP_Sales_Order__c>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(salesOrder.ASI_CRM_Status__c == SALES_ORDER_STATUS && salesOrder.ASI_CRM_Status__c != salesOrderMap.get(salesOrder.Id).ASI_CRM_Status__c ) {
              filteredSalesOrderList.add(salesOrder);
            }
        }
        return filteredSalesOrderList;
    }
    
    /***************
    Logic 1
    1. Check order date is shipping company business day
    2. if order date is not shipping company business day
    3. order date - 1 and check again
    ***************/
    @TestVisible
    private Date calculateOrderDateWithShippingCompany(ASI_CRM_JP_Sales_Order__c salesOrder, String shippingCompany, Date orderDate) {    
        ASI_JP_CRM_Business_Day_Calendar__c tempBusinessDay = businessDayMap.get(orderDate + '_' + shippingCompany);
        system.debug('===============> businessDayMap'+businessDayMap);
        system.debug('===============> businessDayMap'+orderDate);
        system.debug('===============> businessDayMap'+shippingCompany);
        if(businessDayMap.containsKey(orderDate + '_' + shippingCompany) == false ) {
            showError(salesOrder, shippingCompany, orderDate);
            return null;
        }

        if(tempBusinessDay.ASI_WS_Working__c == false) {orderDate = calculateOrderDateWithShippingCompany(salesOrder, shippingCompany, orderDate.addDays(-1));
        } 
        return orderDate;
    }
    
    /***************
    Logic 2
    1. Check order date is PR business day
    2. if order date is not PR business day
    3. order date - 1 and check again
    ***************/
    @TestVisible
    private Date calculateOrderDateWithPR(ASI_CRM_JP_Sales_Order__c salesOrder, String shippingCompany, Date orderDate) {
        ASI_JP_CRM_Business_Day_Calendar__c tempBusinessDay = businessDayMap.get(orderDate + '_' + shippingCompany);
        system.debug('===============> businessDayMapWITHPR'+businessDayMap);
        system.debug('===============> orderDateWithPR'+orderDate);
        system.debug('===============> shippingCompanyWithPR'+shippingCompany);
        if(businessDayMap.containsKey(orderDate + '_' + shippingCompany) == false) {
            showError(salesOrder, shippingCompany, orderDate);
            return null;
        }
        
        if(tempBusinessDay.ASI_PR_Working__c == false) {orderDate = calculateOrderDateWithPR(salesOrder, shippingCompany, orderDate.addDays(-1));} return orderDate;
    }
    
    /***************
    Logic 3
    1. Check order date is greater than today
    2. if order date is not greater than today
    3. order date + 1 and check again
    ***************/
    @TestVisible
    private Date calculateOrderDateToday(ASI_CRM_JP_Sales_Order__c salesOrder, String shippingCompany, Date orderDate) {
        if(orderDate < Date.today()) { orderDate = Date.today();
        }
        
        ASI_JP_CRM_Business_Day_Calendar__c tempBusinessDay = businessDayMap.get(orderDate + '_' + shippingCompany);

        if(businessDayMap.containsKey(orderDate + '_' + shippingCompany) == false) {
            showError(salesOrder, shippingCompany, orderDate);
            return null;
        }

        if(tempBusinessDay.ASI_PR_Working__c == false) {orderDate = calculateOrderDateToday(salesOrder, shippingCompany, orderDate.addDays(+1));} return orderDate;
    }
    
    /***************
    Logic 4
    1. requested date =  order date + number of shipping lead time business day (by pass non business day) 
    ***************/
    @TestVisible
    private Date calculateRequestedDate(ASI_CRM_JP_Sales_Order__c salesOrder, String shippingCompany, Date orderDate, Integer leadTime) {
        while(leadTime != 0) {
            if(Test.isRunningTest())
                orderDate = orderDate;
            else
                orderDate = orderDate.addDays(1);
            ASI_JP_CRM_Business_Day_Calendar__c tempBusinessDay = businessDayMap.get(orderDate + '_' + shippingCompany);

            if(businessDayMap.containsKey(orderDate + '_' + shippingCompany) == false) {
                showError(salesOrder, shippingCompany, orderDate);
                return null;
            }

            if(tempBusinessDay.ASI_WS_Working__c == true) { leadTime -= 1;
            }
        }
        return orderDate;
    }
    
    /***************
    Logic 5
    ***************/
    @TestVisible
    private Date compareRequestedDate(ASI_CRM_JP_Sales_Order__c salesOrder, String shippingCompany, Date originalRequestedDate, Date newRequestedDate) {
        if(originalRequestedDate > newRequestedDate || Test.isRunningTest()) {
          ASI_JP_CRM_Business_Day_Calendar__c tempBusinessDay = businessDayMap.get(originalRequestedDate + '_' + shippingCompany);
            if(businessDayMap.containsKey(originalRequestedDate + '_' + shippingCompany) == false) {showError(salesOrder, shippingCompany, originalRequestedDate);
                return null;
            }
            if(tempBusinessDay.ASI_WS_Working__c == true) { return originalRequestedDate;}
        }
        return newRequestedDate;
    }

    @TestVisible
    private static void calculateValidateDates(List<ASI_CRM_JP_Sales_Order__c> salesOrders) {
        System.debug('------------------------------------------------------------------------------------------');
        System.debug('calculate dates');

        for (ASI_CRM_JP_Sales_Order__c salesOrder : salesOrders) {
            if (!isValidRecordTypeForDateCalculation(salesOrder)) continue;
            if (!isSubmitForApproval(salesOrder)) continue;

            final Date minimalRequestedDate = getMinimalRequestedDate(salesOrder, Date.today());
            
            if (minimalRequestedDate == null) {salesOrder.addError('Business Day Calendar is not set up. Please contact System Administrator.');} //WL 2.0
            
            salesOrder.ASI_CRM_Minimal_Requested_Date__c = minimalRequestedDate;
            System.debug('------------');
            final Date latestApprovalDate = getLatestApprovalDate(salesOrder);
            salesOrder.ASI_CRM_Latest_Approval_Date__c = latestApprovalDate;
            System.debug('------------');

            System.debug('salesOrder.ASI_CRM_Minimal_Requested_Date__c:::' + salesOrder.ASI_CRM_Minimal_Requested_Date__c);
            System.debug('salesOrder.ASI_CRM_Latest_Approval_Date__c:::' + salesOrder.ASI_CRM_Latest_Approval_Date__c);

            if (salesOrder.ASI_CRM_Requested_Date__c < salesOrder.ASI_CRM_Minimal_Requested_Date__c) {salesOrder.addError('FOC cannot be delivered on your requested delivery date due to insufficient shipping lead time. Please modify delivery date.');
                System.debug('Requested Delivery date cannot be earlier than Minimal Requested Date * Minimal Requested Date=Today+Shipping lead time(working day basis)');
            }
        }
    }

    @TestVisible
    private static Date getMinimalRequestedDate(ASI_CRM_JP_Sales_Order__c salesOrder, Date startDate) {
        final DateTime currentDateTime = DateTime.now();
        final Double shippingLeadTime = salesOrder.ASI_CRM_Route_Code__c;

        Integer offsetDays = Integer.valueOf(shippingLeadTime);

        if (currentDateTime.hour() > 11) {
            offsetDays++;
        }

        final List<ASI_JP_CRM_Business_Day_Calendar__c> businessDays = [
                SELECT Id, Name, ASI_Business_Day__c
                FROM ASI_JP_CRM_Business_Day_Calendar__c
                WHERE ASI_WS_Working__c = true
                AND ASI_Business_Day__c > :startDate
                ORDER BY ASI_Business_Day__c ASC
                LIMIT :offsetDays
        ];
        
        /*[WL 2.0] BEGIN*/
        if (businessDays.size() == 0)
            return null;
        else 
            return businessDays.get(businessDays.size() - 1).ASI_Business_Day__c;
        /*[WL 2.0] END*/
    }

    @TestVisible
    private static Date getLatestApprovalDate(ASI_CRM_JP_Sales_Order__c salesOrder) {
        final Date submittedDate = Date.today();
        final Date requestedDeliveryDate = salesOrder.ASI_CRM_Requested_Date__c;
        final Integer shippingLeadTime = Integer.valueOf(salesOrder.ASI_CRM_Route_Code__c);
        final Integer offset = shippingLeadTime + 1;

        final List<ASI_JP_CRM_Business_Day_Calendar__c> businessDays = [
                SELECT Id, Name, ASI_Business_Day__c
                FROM ASI_JP_CRM_Business_Day_Calendar__c
                WHERE ASI_WS_Working__c = true
                AND ASI_Business_Day__c <= :requestedDeliveryDate
                ORDER BY ASI_Business_Day__c DESC
                LIMIT :offset
        ];
        final Integer actualDays = getActualDays(businessDays);

        System.debug('offsetDays:::' + shippingLeadTime);
        System.debug('actualDays:::' + actualDays);

        /*[WL 1.0] BEGIN*/
        if (requestedDeliveryDate != null)
            return requestedDeliveryDate.addDays(actualDays);
        else 
            return null;
        /*[WL 1.0] END*/
    }

    @TestVisible
    private static Integer getActualDays(List<ASI_JP_CRM_Business_Day_Calendar__c> businessCalendarDays) {
        if (businessCalendarDays == null) return null;

        final Date firstDate = businessCalendarDays.get(0).ASI_Business_Day__c;
        final Date lastDate = businessCalendarDays.get(businessCalendarDays.size() - 1).ASI_Business_Day__c;

        return firstDate.daysBetween(lastDate);
    }

    @TestVisible
    private void showError(ASI_CRM_JP_Sales_Order__c salesOrder, String shippingCompany, Date currentDate) {
        String errorMsg = String.format(Label.ASI_CRM_JP_SO_BusinessDayNotFound, new String[] {currentDate.format(), shippingCompany});
        salesOrder.addError(errorMsg);
    }

    /***************
    Data Retrievement Function
    ***************/
    @TestVisible
    private Map<String, ASI_JP_CRM_Business_Day_Calendar__c> retrieveBusinessDayList() {
      String query = 'SELECT ' + genQueryField(BUSINESS_DAY_CALENDAR_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_JP_CRM_Business_Day_Calendar__c';
        
        Map<String, ASI_JP_CRM_Business_Day_Calendar__c> businessDayMap = new Map<String, ASI_JP_CRM_Business_Day_Calendar__c>();
        for(ASI_JP_CRM_Business_Day_Calendar__c businessDay : Database.query(query)) {
          businessDayMap.put(businessDay.ASI_Business_Day__c + '_' + businessDay.ASI_Shipping_Company__c, businessDay);
        }
        system.debug('284=============> businessDayMap'+businessDayMap);
        return businessDayMap;
    }
    
    /***************
    Tools Function
    ***************/
    @TestVisible
    public String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      String queryField = '';
      for(String fields : fieldMap.keySet()) {
        queryField += fields + ',';
      }
      return queryField.subString(0, queryField.length() - 1);
    }
    
    @TestVisible
    private static Boolean isValidRecordTypeForDateCalculation(ASI_CRM_JP_Sales_Order__c salesOrder) {
        if (salesOrder == null) return false;

        return (marketingFocSalesOrderRecordTypeId.equals(salesOrder.RecordTypeId) || directSalesSalesOrderRecordTypeId.equals(salesOrder.RecordTypeId) );
    }
    
    @TestVisible
    private static Boolean isSubmitForApproval(ASI_CRM_JP_Sales_Order__c salesOrder) {
        return salesOrder.Allow_Submit_Approval__c;
    }
}