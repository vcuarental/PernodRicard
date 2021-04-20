/*********************************************************************************
* Name: ASI_CRM_JP_SOAssignApprover_Test
* Description: Test Class for ASI_CRM_JP_SOAssignApprover_Test
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 16/05/2019       Rutuja Bardapurkar            Created
*/

@isTest
public class ASI_CRM_JP_SOAssignApprover_Test {
    @TestSetup
    public static void setupData() {
        ASI_CRM_JP_TestHelper.createApprovalRoute();
        ASI_CRM_JP_TestHelper.createRunningNumber();
        
    }
    
    public static testMethod void testController() {
        
        RecordType rtrn = [SELECT Id, Name, DeveloperName, SobjectType 
                           FROM RecordType 
                           WHERE DeveloperName = 'ASI_CN_Running_Number'];
        
        Map<Id, ASI_CRM_JP_Sales_Order__c> priceMap = new map<Id, ASI_CRM_JP_Sales_Order__c>();
        
        RecordType tr = [SELECT Id, Name, DeveloperName, SobjectType 
                         FROM RecordType 
                         WHERE DeveloperName = 'ASI_CRM_JP_Entertainment_Sales'];
        
        Id directSalesOrderLockedId = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Direct_Sales_Locked');
                
        List<Id> approvers = new list<id>();
        ID userid =  UserInfo.getUserId();
        List<ASI_CRM_JP_Sales_Order__c> CustProlist = new list<ASI_CRM_JP_Sales_Order__c>();
        List<ASI_CRM_JP_Sales_Order__c> salesOrderlist = new list<ASI_CRM_JP_Sales_Order__c>();
        List<ASI_CRM_JP_Sales_Order__c> salesOrderlist2 = new list<ASI_CRM_JP_Sales_Order__c>();
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
        CustProlist.add(CustPro);
        
        ASI_CRM_JP_Sales_Order__c CustPro2 = new ASI_CRM_JP_Sales_Order__c();
        CustPro2.OwnerId = userid;
        CustPro2.RecordTypeId = tr.Id;
        CustPro2.ASI_CRM_Branch_Plant__c = '711';
        CustPro2.Allow_Submit_Approval__c = true;
        CustPro2.ASI_CRM_JDE_Synced__c = false;
       	CustPro2.RecordTypeId = directSalesOrderLockedId;
        CustPro2.ASI_CRM_JP_Approver_5__c = userid;
        CustProlist.add(CustPro2);
		
        insert CustProlist;
        
        ASI_CRM_JP_Sales_Order__c CustPro3 = new ASI_CRM_JP_Sales_Order__c();
        CustPro3.OwnerId = userid;
        CustPro3.RecordTypeId = tr.Id;
       
        CustPro3.ASI_CRM_JDE_Synced__c = true;
        CustPro3.ASI_CRM_JP_Approver_1__c = userid;
        CustPro3.ASI_CRM_JP_Approver_2__c = userid;
        CustPro3.ASI_CRM_JP_Approver_3__c = userid;
        CustPro3.ASI_CRM_JP_Approver_4__c = userid;
        CustPro3.ASI_CRM_JP_Approver_5__c = userid;
        CustPro3.ASI_CRM_Branch_Plant__c = '711';
        CustPro3.Allow_Submit_Approval__c = true;
        salesOrderlist2.add(CustPro3);
        insert salesOrderlist2;
        Map<Id, ASI_CRM_JP_Sales_Order__c> priceMap2 = new map<Id, ASI_CRM_JP_Sales_Order__c>();
        priceMap2.put(CustPro3.Id, CustPro3);
        
        Map<String, Object> itemGroupFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_GROUP_DEFAUL_VALUE_MAP;
        ASI_MFM_Item_Group__c itemGroup = ASI_CRM_JP_TestHelper.createItemGroup(itemGroupFieldValueMap);
        insert itemGroup;
        
        List<ASI_MFM_SKU_Code__c> skuCodeList = new List<ASI_MFM_SKU_Code__c>();
        for(Integer index = 0 ; index < 2 ; index++) {
            Map<String, Object> skuCodeFieldValueMap = ASI_CRM_JP_TestHelper.SKU_DEFAULT_VALUE_MAP;
            skuCodeFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
            ASI_MFM_SKU_Code__c skuCode = ASI_CRM_JP_TestHelper.createSKU(skuCodeFieldValueMap);
            skuCodeList.add(skuCode);
        }
        insert skuCodeList;
        Map<String, Object> SKUFieldValueMap = ASI_CRM_JP_TestHelper.SKU_DEFAULT_VALUE_MAP;
        Map<String, Object> salesOrderItemFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_ITEM_DEFAULT_VALUE_MAP;
        salesOrderItemFieldValueMap.put('ASI_CRM_Sales_Order__c', CustProlist[0].Id);
        salesOrderItemFieldValueMap.put('ASI_CRM_SKU__c', skuCodeList.get(0).Id);
        salesOrderItemFieldValueMap.put('ASI_CRM_JP_Sys_Lookup_Filter__c', 'ASI_CRM_JP_Manual_JDE_SO');
        salesOrderItemFieldValueMap.put('ASI_CRM_Sys_Item_Availability_Filter__c', CustProlist[0].ASI_CRM_Branch_Plant__c);
        ASI_CRM_JP_Sales_Order_Item__c salesOrderItem = ASI_CRM_JP_TestHelper.createSalesOrderLine(salesOrderItemFieldValueMap);
        salesOrderItem.ASI_CRM_SKU__c = skuCodeList[0].Id ;
        
        ASI_CRM_JP_Item_Availability__c ItemA1 = new ASI_CRM_JP_Item_Availability__c();
        ItemA1.ASI_SKU__c = skuCodeList[0].Id;
        ItemA1.ASI_Warehouse_Location__c = '711';
        insert ItemA1;
        try{
		insert salesOrderItem;
        }
        catch (Exception e){}
        
        priceMap.put(CustProlist[0].id,CustProlist[0]);
        salesOrderlist.add(CustProlist[0].clone(true, true, true, true));
        salesOrderlist[0].ASI_CRM_JDE_Synced__c = true;
        
        
        approvers.add(CustPro.id);
        
        Set<Id> userIdSet = new Set<Id>();
        Id Pl1RecordTypeId = Schema.SObjectType.ASI_CRM_Route_Type__c.getRecordTypeInfosByName().get('JP Price Route Type').getRecordTypeId();
        List<ASI_CRM_Route_Type__c> CustProlist1 = new list<ASI_CRM_Route_Type__c>();
        ASI_CRM_Route_Type__c CustPro1 = new ASI_CRM_Route_Type__c();
        CustPro1.ASI_CRM_Module_Record_Type__c = 'ASI_CRM_JP_Sales_Order_Route_Type';
        CustPro1.ASI_CRM_Module__c = 'Sales Order';
        CustProlist1.add(CustPro1);
        insert CustProlist1;
       
        update CustProlist;
        
        
        List<ASI_CRM_Route_Rule_Detail__c> RR = new List<ASI_CRM_Route_Rule_Detail__c>();
        ASI_CRM_Route_Rule_Detail__c Rrd = new ASI_CRM_Route_Rule_Detail__c();
        Rrd.ASI_CRM_Route_Type__c  = CustPro1.Id;
        Rrd.ASI_CRM_Brand_Code__c ='ABC';
        RR.add(Rrd);
        insert RR;
        
        Rrd.ASI_CRM_JP_Approver_Type__c = 'user';
        update Rrd;
        
        List<ASI_CRM_Route_Rule_Detail__c> RR11 = new List<ASI_CRM_Route_Rule_Detail__c>([select id,name,ASI_CRM_Route_Type__r.ASI_CRM_A_P_Code__c from ASI_CRM_Route_Rule_Detail__c]);
        
        
        Set<Id> salesOrderIds = new set<Id>();
        
        List<Id> skuCodeIds = new List<Id>();
        
        List<ASI_CRM_JP_Item_Availability__c> ItemAvail = new List<ASI_CRM_JP_Item_Availability__c>();
        ASI_CRM_JP_Item_Availability__c ItemA = new ASI_CRM_JP_Item_Availability__c();
        ItemA.ASI_SKU__c = skuCodeList[0].Id;
        ItemA.ASI_Warehouse_Location__c = '711';
        ItemAvail.add(ItemA);
        insert ItemAvail;
        skuCodeIds.add(ItemAvail[0].id);        
        
        
        ASI_CRM_JP_SOAssignApprover ItemBase = new ASI_CRM_JP_SOAssignApprover();
        ItemBase.assignApprover(CustProlist);
        ItemBase.retrieveUser(userIdSet);
        
        ASI_CRM_JP_SOAssignApprover.assignApproverForFOC(priceMap);
        ASI_CRM_JP_SOAssignApprover.isAlreadyAnApprover(CustPro, userid);
        ASI_CRM_JP_SOAssignApprover.isSubmitForApproval(CustPro);
        ASI_CRM_JP_SOAssignApprover.isValidRecordType(CustPro);
        test.startTest();
        CustPro2.ASI_CRM_JP_Approver_1__c=userid;
        update CustPro2;
        ASI_CRM_JP_SOAssignApprover.addApprovers(CustPro2, approvers);
        CustPro2.ASI_CRM_JP_Approver_2__c=userid;
        update CustPro2;
        ASI_CRM_JP_SOAssignApprover.addApprovers(CustPro2, approvers);
        CustPro2.ASI_CRM_JP_Approver_3__c=userid;
        update CustPro2;
        ASI_CRM_JP_SOAssignApprover.addApprovers(CustPro2, approvers);
        CustPro2.ASI_CRM_JP_Approver_4__c=userid;
        update CustPro2;
        ASI_CRM_JP_SOAssignApprover.addApprovers(CustPro2, approvers);
        CustPro2.ASI_CRM_JP_Approver_5__c=userid;
        ASI_CRM_JP_SOAssignApprover.addApprovers(CustPro2, approvers);
        test.stopTest();
        ASI_CRM_JP_SOAssignApprover.addApprovers(CustPro, approvers);
        ASI_CRM_JP_SOAssignApprover.getRouteDetails();
        ASI_CRM_JP_SOAssignApprover.getBrandCodeRouteDetailsMap(RR);
        system.debug('CustProlist id:' + CustProlist.get(0).id);
        system.debug('priceMap:' + priceMap);
        ASI_CRM_JP_SOAssignApprover.salesOrderQuantityDeduction(salesOrderlist, priceMap);
        ASI_CRM_JP_SOAssignApprover.getApCodeRouteRuleDetailsMap();
        ASI_CRM_JP_SOAssignApprover.getItemAvailabitlity(skuCodeIds);
        
    }
    
   public static testMethod void testController2() {
        
        RecordType rtrn = [SELECT Id, Name, DeveloperName, SobjectType 
                           FROM RecordType 
                           WHERE DeveloperName = 'ASI_CN_Running_Number'];
        
        Map<Id, ASI_CRM_JP_Sales_Order__c> priceMap = new map<Id, ASI_CRM_JP_Sales_Order__c>();
       
        
        RecordType tr = [SELECT Id, Name, DeveloperName, SobjectType 
                         FROM RecordType 
                         WHERE DeveloperName = 'ASI_CRM_JP_Entertainment_Sales'];
        
        List<Id> approvers = new list<id>();
        ID userid =  UserInfo.getUserId();
        List<ASI_CRM_JP_Sales_Order__c> salesOrderlist2 = new list<ASI_CRM_JP_Sales_Order__c>();      
        ASI_CRM_JP_Sales_Order__c CustPro3 = new ASI_CRM_JP_Sales_Order__c();
        CustPro3.OwnerId = userid;
        CustPro3.RecordTypeId = tr.Id;
       
        CustPro3.ASI_CRM_JDE_Synced__c = true;
        CustPro3.ASI_CRM_JP_Approver_1__c = userid;
        CustPro3.ASI_CRM_JP_Approver_2__c = userid;
        CustPro3.ASI_CRM_JP_Approver_3__c = userid;
        CustPro3.ASI_CRM_JP_Approver_4__c = userid;
        CustPro3.ASI_CRM_JP_Approver_5__c = userid;
        CustPro3.ASI_CRM_Branch_Plant__c = '111';
       	CustPro3.ASI_CRM_JP_Entertainment_Owner__c = UserInfo.getUserId();
        salesOrderlist2.add(CustPro3);
        insert salesOrderlist2;
        Map<Id, ASI_CRM_JP_Sales_Order__c> priceMap2 = new map<Id, ASI_CRM_JP_Sales_Order__c>();
        priceMap2.put(CustPro3.Id, CustPro3);
        
       	ASI_CRM_JP_SOAssignApprover ItemBase = new ASI_CRM_JP_SOAssignApprover();
        ItemBase.resetApprover(salesOrderlist2);
       	ItemBase.assignApprover(salesOrderlist2);
        ASI_CRM_JP_SOAssignApprover.salesOrderQuantityDeduction(salesOrderlist2, priceMap2);
        
    }

}