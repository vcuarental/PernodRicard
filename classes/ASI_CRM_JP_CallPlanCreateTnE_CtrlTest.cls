/*********************************************************************************
 * Name: ASI_CRM_JP_CallPlanCreateTnE_CtrlTest
 * Description: Test class for ASI_CRM_JP_CallPlanCreateTnE_Ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/06/2018       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_JP_CallPlanCreateTnE_CtrlTest {
    
    @TestSetup
    public static void setupDate() {
    	ASI_CRM_JP_TestClassHelper.createTaxRoutingTbl();
            ASI_CRM_JP_TestClassHelper.createRunningNumbers();
            ASI_CRM_JP_TestClassHelper.createDueDateMapping();   
            ASI_TnE_ClaimHeader__c  claimHeader = ASI_CRM_JP_TestClassHelper.createClaimHeaderPaperRecordType(); 
            ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), ASI_CRM_TnE_Number__c = claimHeader.Id, Name = 'Test', ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today(), ASI_CRM_Period_To__c = system.today().addDays(60));
            insert plan;
        
            List<ASI_MFM_Brand__c> brandList = new List<ASI_MFM_Brand__c>();
            ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_JP_Brand'), Name = 'Test', ASI_MFM_Brand_Description__c = 'PERRIER JOUET');  
            brandList.add(brand1);
            ASI_MFM_Brand__c brand2 = new ASI_MFM_Brand__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_JP_Brand'), Name = 'Test2', ASI_MFM_Brand_Description__c = 'MARTELL');
            brandList.add(brand2);
            ASI_MFM_Brand__c brand3 = new ASI_MFM_Brand__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_JP_Brand'), Name = 'Test3', ASI_MFM_Brand_Description__c = 'CAFE de PARIS');
            brandList.add(brand3);
            insert brandList;
        
            List<ASI_MFM_Sub_brand__c> subBrandList = new List<ASI_MFM_Sub_brand__c>();
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c = brand1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_JP_Sub_brand'), ASI_MFM_Active_for_CRM__c = true);
            subBrandList.add(subBrand1);
            ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c = brand2.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_JP_Sub_brand'), ASI_MFM_Active_for_CRM__c = true);
            subBrandList.add(subBrand2);
            ASI_MFM_Sub_brand__c subBrand3 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c = brand3.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_JP_Sub_brand'), ASI_MFM_Active_for_CRM__c = true);
            subBrandList.add(subBrand3);
            insert subBrandList;
            
            List<ASI_TH_CRM_OutletType__c> outletTypeList = new List<ASI_TH_CRM_OutletType__c>();
            ASI_TH_CRM_OutletType__c outletType1 = new ASI_TH_CRM_OutletType__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_JP_Outlet_Type'), Name = 'Test1', ASI_TH_CRM_Code__c = '301', ASI_CRM_Class__c = 'Middle');  
            ASI_TH_CRM_OutletType__c outletType2 = new ASI_TH_CRM_OutletType__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_JP_Outlet_Type'), Name = 'Test2', ASI_TH_CRM_Code__c = '302', ASI_CRM_Class__c = 'High');
            outletTypeList.add(outletType1);
            outletTypeList.add(outletType2);
            insert outletTypeList;
            
            List<ASI_CRM_Postal_Code__c> postList = new List<ASI_CRM_Postal_Code__c>();
            ASI_CRM_Postal_Code__c postalCode1 = new ASI_CRM_Postal_Code__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Postal_Code__cASI_CRM_JP_Postal_Code'), Name ='0000000', ASI_CRM_JP_Metropolitan__c = true); 
            ASI_CRM_Postal_Code__c postalCode2 = new ASI_CRM_Postal_Code__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Postal_Code__cASI_CRM_JP_Postal_Code'), Name ='1234567', ASI_CRM_JP_Metropolitan__c = false);
            postList.add(postalCode1);
            postList.add(postalCode2);
            insert postList;
            List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test1', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_On_Trade_Outlet'), ASI_TH_CRM_OutletType__c = outletType1.Id, ASI_CRM_PostalCode__c= postalCode1.Name);
            ASI_CRM_AccountsAdditionalField__c customer2 = new ASI_CRM_AccountsAdditionalField__c(Name='Test1', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_On_Trade_Outlet'), ASI_TH_CRM_OutletType__c = outletType2.Id, ASI_CRM_PostalCode__c= postalCode2.Name);
            customer1.ASI_CRM_Allow_Create__c = true;
        	customer2.ASI_CRM_Allow_Create__c = true;
        	customerList.add(customer1);
            customerList.add(customer2);
            insert customerList;    
        
            List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();
            ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(ASI_CRM_Actual_Amount__c = 10, ASI_CRM_Dohan__c = true, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now(), ASI_CRM_Visit_Date_To__c = system.now());
            ASI_CRM_Call_Detail__c detail2 = new ASI_CRM_Call_Detail__c(ASI_CRM_Dohan__c = true, ASI_CRM_Actual_Amount__c = 1000000, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(1), ASI_CRM_Visit_Date_To__c = system.now().addDays(1));
            ASI_CRM_Call_Detail__c detail3 = new ASI_CRM_Call_Detail__c(ASI_CRM_Actual_Amount__c = 0, ASI_CRM_Number_of_SKU1_Consumed__c = 0, ASI_CRM_Number_of_SKU3_Consumed__c = 0, ASI_CRM_Activity_Sub_brand_1__c = subBrand1.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            ASI_CRM_Call_Detail__c detail4 = new ASI_CRM_Call_Detail__c(ASI_CRM_Actual_Amount__c = 1000000, ASI_CRM_Activity_Sub_brand_1__c = subBrand1.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            ASI_CRM_Call_Detail__c detail5 = new ASI_CRM_Call_Detail__c(ASI_CRM_Actual_Amount__c = 10, ASI_CRM_Activity_Sub_brand_1__c = subBrand2.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            ASI_CRM_Call_Detail__c detail6 = new ASI_CRM_Call_Detail__c(ASI_CRM_Actual_Amount__c = 1000000, ASI_CRM_Activity_Sub_brand_1__c = subBrand2.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            ASI_CRM_Call_Detail__c detail7 = new ASI_CRM_Call_Detail__c(ASI_CRM_Actual_Amount__c = 10, ASI_CRM_Activity_Sub_brand_1__c = subBrand3.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            ASI_CRM_Call_Detail__c detail8 = new ASI_CRM_Call_Detail__c(ASI_CRM_Actual_Amount__c = 1000000, ASI_CRM_Activity_Sub_brand_1__c = subBrand3.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            detail1.ASI_CRM_Payment_Option__c = 'Cash';
        	detail1.ASI_CRM_Sys_Call_Plan_TnE__c = plan.Id;
        	detail2.ASI_CRM_Payment_Option__c = 'Cash';
        	detail2.ASI_CRM_Sys_Call_Plan_TnE__c = plan.Id;
        	detail3.ASI_CRM_Payment_Option__c = 'Cash';
        	detail3.ASI_CRM_Sys_Call_Plan_TnE__c = plan.Id;
        	detail4.ASI_CRM_Payment_Option__c = 'Cash';
        	detail4.ASI_CRM_Sys_Call_Plan_TnE__c = plan.Id;
        	detail5.ASI_CRM_Payment_Option__c = 'Cash';
        	detail5.ASI_CRM_Sys_Call_Plan_TnE__c = plan.Id;
       	 	detail6.ASI_CRM_Payment_Option__c = 'Cash';
        	detail6.ASI_CRM_Sys_Call_Plan_TnE__c = plan.Id;
        	detail7.ASI_CRM_Payment_Option__c = 'Cash';
        	detail7.ASI_CRM_Sys_Call_Plan_TnE__c = plan.Id;
       		detail8.ASI_CRM_Payment_Option__c = 'Cash';
        	detail8.ASI_CRM_Sys_Call_Plan_TnE__c = plan.Id;
        	detailList.add(detail1);
            detailList.add(detail2);
            detailList.add(detail3);
            detailList.add(detail4);
            detailList.add(detail5);
            detailList.add(detail6);
            detailList.add(detail7);
            detailList.add(detail8);
            insert detailList;
    }
    
    public static testMethod void testCtrl() {
        ASI_CRM_Call_Plan__c callPlan = [SELECT Id FROM ASI_CRM_Call_Plan__c LIMIT 1];
        
        Map<Id, ASI_CRM_Call_Detail__c> callDetailMap = new Map<Id, ASI_CRM_Call_Detail__c>([SELECT Id FROM ASI_CRM_Call_Detail__c where ASI_CRM_Call_Plan__c = :callPlan.Id]);        
        
        System.debug(callDetailMap);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(callPlan);
        PageReference pageRef = Page.ASI_CRM_JP_CallPlanCreateTnE_Page;
        pageRef.getParameters().put('id', callPlan.Id);
        Test.setCurrentPage(pageRef);
        
    	ASI_CRM_JP_CallPlanCreateTnE_Ctrl ctrl = new ASI_CRM_JP_CallPlanCreateTnE_Ctrl(sc);
        pageRef.getParameters().put('selectDetailIdSetJson', System.JSON.serialize(callDetailMap.keySet()));
        ctrl.createTnE();
        ctrl.cancel();
        Test.stopTest();
    }
}