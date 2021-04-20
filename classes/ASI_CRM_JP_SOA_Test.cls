@isTest
public class ASI_CRM_JP_SOA_Test {

    
    @isTest
    static void testCalloutSOInterface_DS() {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ASI_CRM_JP_SOACallOutMock());
                
        ID userid =  UserInfo.getUserId();
        Id pId = [Select id from profile where name = 'ASI System Administrator'].id;
        user u = [Select id from user where profileid = :pid and isactive = true][0];
        
        System.runAs(u){
            ASI_CRM_JP_TestHelper.createRunningNumber();
            
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
            
            RecordType tr = [SELECT Id, Name, DeveloperName, SobjectType 
                             FROM RecordType 
                             WHERE DeveloperName = 'ASI_CRM_JP_Entertainment_Sales'];
            
            Id directSalesOrderLockedId = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Direct_Sales');
            
            ASI_CRM_Pay_To__c bankAcc = new ASI_CRM_Pay_To__c ();
            bankAcc.name = 'banks';
            bankAcc.ASI_CRM_JP_PRJ_Bank_Account__c  = true;
            insert bankAcc;
            
            List<ASI_CRM_JP_Sales_Order__c> CustProlist = new List<ASI_CRM_JP_Sales_Order__c>();
            ASI_CRM_JP_Sales_Order__c CustPro = new ASI_CRM_JP_Sales_Order__c();
            CustPro.OwnerId = userid;
            CustPro.RecordTypeId = tr.Id;
            CustPro.ASI_CRM_Branch_Plant__c = '711';
            CustPro.ASI_CRM_JDE_Synced__c = false;
            CustPro.ASI_CRM_JP_Approver_1__c = userid;
            CustPro.ASI_CRM_JP_Approver_2__c = userid;
            CustPro.ASI_CRM_JP_Approver_3__c = userid;
            CustPro.ASI_CRM_JP_Approver_4__c = userid;
            CustPro.ASI_CRM_JP_Approver_5__c = userid;
            CustPro.RecordTypeId = directSalesOrderLockedId;
            CustPro.Allow_Submit_Approval__c = true;
            CustPro.ASI_CRM_Payment_Option__c = 'Invoice';
            CustPro.ASI_CRM_Status__c = 'Submitted';
            CustPro.ASI_CRM_Bank_Account__c = bankAcc.id;
            CustPro.ASI_CRM_Requested_Date__c = System.today().addDays(10);
            insert CustPro;
            CustProlist.add(CustPro);                                
            
            ASI_SOA_Setting__c setting = new ASI_SOA_Setting__c(Name='ASI_CRM_JP_EnableSOAInterface', ASI_SOA_Enable__c=true, ASI_SOA_URL__c = 'http://test.com');
            insert setting;
            
            ASI_SOA_Setting__c setting2 = new ASI_SOA_Setting__c(Name='ASI_CRM_JP_SO_Interface_URL', ASI_SOA_Enable__c=true, ASI_SOA_URL__c = 'http://test.com');
            insert setting2;
            
            
            Test.startTest();
            
            CustPro.ASI_CRM_Status__c = 'AC Verified';
            CustPro.ASI_CRM_Payment_Option__c = 'Advanced Payment';
            update CustPro;
            
            ASI_CRM_JP_SO_InvokeSOA.submitSO(CustPro.id, 'Direct Sales');        
            
            //Test coverage for callout mock
            ASI_CRM_JP_SO_Creation.processResponse_element obj = new ASI_CRM_JP_SO_Creation.processResponse_element();
            ASI_CRM_JP_SO_Creation.process_element obj2 = new ASI_CRM_JP_SO_Creation.process_element();        
            
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('Test', obj);
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCalloutSOInterface_FOC() {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ASI_CRM_JP_SOACallOutMock());
                
        ID userid =  UserInfo.getUserId();
        
        ASI_CRM_JP_TestHelper.createRunningNumber();
        
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
        
        RecordType tr = [SELECT Id, Name, DeveloperName, SobjectType 
                         FROM RecordType 
                         WHERE DeveloperName = 'ASI_CRM_JP_Entertainment_Sales'];
        
                    
        List<ASI_CRM_JP_Sales_Order__c> CustProlist = new List<ASI_CRM_JP_Sales_Order__c>();
        ASI_CRM_JP_Sales_Order__c CustPro = new ASI_CRM_JP_Sales_Order__c();
        CustPro.OwnerId = userid;
        CustPro.RecordTypeId = tr.Id;
        CustPro.ASI_CRM_Branch_Plant__c = '711';
        CustPro.ASI_CRM_JDE_Synced__c = false;
        CustPro.ASI_CRM_JP_Approver_1__c = userid;
        CustPro.ASI_CRM_JP_Approver_2__c = userid;
        CustPro.ASI_CRM_JP_Approver_3__c = userid;
        CustPro.ASI_CRM_JP_Approver_4__c = userid;
        CustPro.ASI_CRM_JP_Approver_5__c = userid;
        CustPro.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Marketing_FOC');
        CustPro.Allow_Submit_Approval__c = true;
        CustPro.ASI_CRM_Payment_Option__c = 'Invoice';
        CustPro.ASI_CRM_Status__c = 'Submitted';
        CustPro.ASI_CRM_Whisky__c  = true;
        CustPro.ASI_CRM_Requested_Date__c = System.today().addDays(10);
        insert CustPro;               
        
        Map<String, Object> itemGroupFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_GROUP_DEFAUL_VALUE_MAP;
        ASI_MFM_Item_Group__c itemGroup = ASI_CRM_JP_TestHelper.createItemGroup(itemGroupFieldValueMap);
        itemGroup.ASI_CRM_Standard_Cost__c = 100;
        insert itemGroup;
        
        List<ASI_MFM_SKU_Code__c> skuCodeList = new List<ASI_MFM_SKU_Code__c>();
        for(Integer index = 0 ; index < 2 ; index++) {
            Map<String, Object> skuCodeFieldValueMap = ASI_CRM_JP_TestHelper.SKU_DEFAULT_VALUE_MAP;
            skuCodeFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
            ASI_MFM_SKU_Code__c skuCode = ASI_CRM_JP_TestHelper.createSKU(skuCodeFieldValueMap);
            skuCode.ASI_HK_CRM_Active__c = true;
            skuCodeList.add(skuCode);
        }
        insert skuCodeList;
        
        ASI_CRM_JP_Sales_Order_Item__c SOLine = new ASI_CRM_JP_Sales_Order_Item__c ();
        SOLine.ASI_CRM_Sales_Order__c = CustPro.id;
        SOLine.ASI_CRM_SKU__c  = skuCodeList[0].Id;
        SOLine.ASI_CRM_Quantity__c = 1;
        SOLine.ASI_CRM_Sys_Item_Availability_Filter__c  = '711';
        
        ASI_CRM_JP_Item_Availability__c ItemA1 = new ASI_CRM_JP_Item_Availability__c();
        ItemA1.ASI_SKU__c = skuCodeList[0].Id;
        ItemA1.ASI_Warehouse_Location__c = '711';
        insert ItemA1;
        
        insert SOLine;
        
        ASI_SOA_Setting__c setting = new ASI_SOA_Setting__c(Name='ASI_CRM_JP_EnableSOAInterface', ASI_SOA_Enable__c=true, ASI_SOA_URL__c = 'http://test.com');
        insert setting;
        
        ASI_SOA_Setting__c setting2 = new ASI_SOA_Setting__c(Name='ASI_CRM_JP_SO_Interface_URL', ASI_SOA_Enable__c=true, ASI_SOA_URL__c = 'http://test.com');
        insert setting2;
        
        
        Test.startTest();        
        
        CustPro.ASI_CRM_Status__c = 'Approved';
        update CustPro;
        
        ASI_CRM_JP_SO_InvokeSOA.submitSO(CustPro.id, 'Marketing FOC');
                
        //Test coverage for callout mock
        ASI_CRM_JP_SO_Creation.processResponse_element obj = new ASI_CRM_JP_SO_Creation.processResponse_element();
        ASI_CRM_JP_SO_Creation.process_element obj2 = new ASI_CRM_JP_SO_Creation.process_element();        
        
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('Test', obj);
        
        Test.stopTest();
    }
}