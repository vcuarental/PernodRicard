@isTest
public class ASI_CRM_JP_SOAssignDate_Test{

    // 20190624 Wilson Chow
    @testSetup
    static void testDataSetup() {
        ASI_CRM_JP_TestHelper.createRunningNumber();
    }
    // 20190624 Wilson Chow

    static  testmethod void getTested(){
        test.startTest();

        string shippingCompany = 'test adddress';
        date orderdate = date.today();
        list<ASI_JP_CRM_Business_Day_Calendar__c> aps = new list<ASI_JP_CRM_Business_Day_Calendar__c>();
        ASI_JP_CRM_Business_Day_Calendar__c ap =  new ASI_JP_CRM_Business_Day_Calendar__c();
        ap.ASI_WS_Working__c  = true;
        ap.ASI_PR_Working__c = true;
        ap.ASI_Business_Day__c = date.today();
        ap.ASI_Shipping_Company__c  = 'MS';
        insert ap;
        Date day1 = date.today()+2;
        Date day2 = date.today()+5;
        ASI_JP_CRM_Business_Day_Calendar__c ap1 =  new ASI_JP_CRM_Business_Day_Calendar__c();
        ap1.ASI_WS_Working__c  = true;
        ap1.ASI_PR_Working__c = true;
        ap1.ASI_Business_Day__c = date.today()+3;
        ap1.ASI_Shipping_Company__c  = 'MS';
        insert ap1;

        ASI_CRM_JP_SOAssignDate asiObj = new ASI_CRM_JP_SOAssignDate();
        Map<Id,ASI_CRM_JP_Sales_Order__c> mapSalesOrder = new Map<Id,ASI_CRM_JP_Sales_Order__c>();
        ID userid =  UserInfo.getUserId();
        List<ASI_CRM_JP_Sales_Order__c> CustProlist = new list<ASI_CRM_JP_Sales_Order__c>();
        ASI_CRM_JP_Sales_Order__c CustPro = new ASI_CRM_JP_Sales_Order__c();
        CustPro.ASI_CRM_Requested_Date__c= date.today().addDays(5);
        CustPro.ASI_CRM_Branch_Plant__c = '711';
        CustPro.ASI_CRM_JDE_Synced__c = false;
        CustPro.ASI_CRM_JP_Approver_1__c = userid;
        CustPro.ASI_CRM_JP_Approver_2__c = userid;
        CustPro.ASI_CRM_JP_Approver_3__c = userid;
        CustPro.ASI_CRM_JP_Approver_4__c = userid;
        CustPro.ASI_CRM_JP_Approver_5__c = userid;
        CustPro.ASI_CRM_Status__c = 'Final';
        CustPro.ASI_CRM_Freight_Code__c = 'MS';
        //CustPro.RecordTypeId = directSalesOrderLockedId;
        CustPro.Allow_Submit_Approval__c = true;
        CustPro.ASI_CRM_Route_Code__c = 1;
        CustPro.ASI_CRM_Order_Date__c = date.today();

        // 20190624 Wilson Chow
        CustPro.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Direct_Sales');
        // 20190624 Wilson Chow

        //insert CustPro;
        CustProlist.add(CustPro);
        insert CustProlist;
        mapSalesOrder.put(CustPro.Id, CustPro);
        
        
        ASI_CRM_JP_Sales_Order__c CustPro1 = new ASI_CRM_JP_Sales_Order__c();
        CustPro1.ASI_CRM_Order_Date__c = date.today();
        CustPro1.ASI_CRM_Branch_Plant__c = '711';
        CustPro1.ASI_CRM_JDE_Synced__c = false;
        CustPro1.ASI_CRM_JP_Approver_1__c = userid;
        CustPro1.ASI_CRM_JP_Approver_2__c = userid;
        CustPro1.ASI_CRM_JP_Approver_3__c = userid;
        CustPro1.ASI_CRM_JP_Approver_4__c = userid;
        CustPro1.ASI_CRM_JP_Approver_5__c = userid;
        CustPro1.ASI_CRM_Status__c = 'Open';
        CustPro1.ASI_CRM_Route_Code__c = 1;
        CustPro1.ASI_CRM_Freight_Code__c = 'MS';
        //CustPro.RecordTypeId = directSalesOrderLockedId;
        CustPro1.Allow_Submit_Approval__c = true;
        CustPro1.ASI_CRM_Requested_Date__c = date.today().addDays(5);

        // 20190624 Wilson Chow
        CustPro1.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Direct_Sales');
        // 20190624 Wilson Chow

        insert CustPro1;
       // CustProlist.add(CustPro1);
       // insert CustProlist;
        CustPro1.ASI_CRM_Requested_Date__c = date.today()+1;
        CustPro1.ASI_CRM_Route_Code__c = 1;
        CustPro1.ASI_CRM_Status__c = 'Final';
       // update CustPro1;
      
        system.debug('inserted'+CustPro1);

        aps.add(ap1);
        Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap =  new Map<Id, ASI_CRM_JP_Sales_Order__c>();
        salesOrderMap.put(CustPro1.id,CustPro1);
        asiObj.calculateOrderDateWithShippingCompany(CustPro1,shippingCompany,orderdate);
        asiObj.calculateOrderDateWithPR(CustPro1,shippingCompany,orderdate);
        asiObj.calculateOrderDateToday(CustPro1,shippingCompany,orderdate);
        asiObj.calculateRequestedDate(CustPro1,shippingCompany,orderdate,12);
        asiObj.compareRequestedDate(CustPro1,shippingCompany,day1,day2);
        ASI_CRM_JP_SOAssignDate.isSubmitForApproval(CustPro);
        //CustPro.ASI_CRM_Status__c = 'Final';
         update CustPro;
        ASI_CRM_JP_SOAssignDate.calculateValidateDates(CustProlist);
        //asiObj.filterSalesOrder(CustProlist,salesOrderMap);
        
        ASI_CRM_JP_SOAssignDate.getMinimalRequestedDate(CustPro,date.today());
        ASI_CRM_JP_SOAssignDate.getLatestApprovalDate(CustPro);
        ASI_CRM_JP_SOAssignDate.getActualDays(aps);
        test.stopTest();
    }
}