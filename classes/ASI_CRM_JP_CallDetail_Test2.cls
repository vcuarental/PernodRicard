/*********************************************************************************
 * Name:ASI_CRM_JP_CallDetail_Test
 * Description: Test Class for Call Detail of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 5/5/2015         Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_CallDetail_Test2 {
    
    //Test for ASI_CRM_JP_CreateTnEController
    static testMethod void ASI_CRM_JP_CreateTnEController_Test1(){
        //UserRole role = new UserRole(name = 'TEST', DeveloperName = 'TEST');
        //insert role;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ASI_JP_TnE_Department_Category_Code__c = '1',
            LocaleSidKey='en_US', ProfileId = p.Id, CompanyName = 'Pernod Ricard Japan', /*UserRoleId = role.Id,*/
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        u1.ASI_JP_TnE_Department_Category_Code__c = '1';
        insert u1;
        
        system.runAs(u1){
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
            detailList.add(detail1);
            detailList.add(detail2);
            detailList.add(detail3);
            detailList.add(detail4);
            detailList.add(detail5);
            detailList.add(detail6);
            detailList.add(detail7);
            detailList.add(detail8);
            insert detailList;
            
            test.startTest();
            detail1.ASI_CRM_Status__c = 'Achieved';
            detail2.ASI_CRM_Status__c = 'Achieved';
            detail3.ASI_CRM_Status__c = 'Achieved';
            detail4.ASI_CRM_Status__c = 'Achieved';
            detail5.ASI_CRM_Status__c = 'Achieved';
            detail6.ASI_CRM_Status__c = 'Achieved';
            detail7.ASI_CRM_Status__c = 'Achieved';
            detail8.ASI_CRM_Status__c = 'Achieved';
           
            update detailList;
            detail4.ASI_CRM_Status__c = 'Planned';
            update detail4;
            List<ASI_CRM_Call_Detail__c> detailList2 = new List<ASI_CRM_Call_Detail__c>();
            detailList2.add(detail1);
        
            PageReference pageRef = Page.ASI_CRM_JP_CreateTnEPage;
            pageRef.getParameters().put('recs', detail1.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(detailList2);
            ASI_CRM_JP_CreateTnEController controller = new ASI_CRM_JP_CreateTnEController(ssc);
            try{
                controller.save();
            }catch(Exception e){
            
            }
            test.stopTest();
        }
    }
    static testMethod void ASI_CRM_JP_CreateTnEController_Test2(){
        //UserRole role = new UserRole(name = 'TEST', DeveloperName = 'TEST');
        //insert role;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ASI_JP_TnE_Department_Category_Code__c = '1',
            LocaleSidKey='en_US', ProfileId = p.Id, CompanyName = 'Pernod Ricard Japan', /*UserRoleId = role.Id,*/
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        u1.ASI_JP_TnE_Department_Category_Code__c = '1';
        insert u1;
        
        system.runAs(u1){
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
            customerList.add(customer1);
            customerList.add(customer2);
            insert customerList;    
        
            List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();
            ASI_CRM_Call_Detail__c detail9 = new ASI_CRM_Call_Detail__c(ASI_CRM_Customer__c = customer1.Id, ASI_CRM_Actual_Amount__c = 10, ASI_CRM_Activity_Sub_brand_1__c = subBrand2.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));  
            ASI_CRM_Call_Detail__c detail10 = new ASI_CRM_Call_Detail__c(ASI_CRM_Customer__c = customer2.Id, ASI_CRM_Actual_Amount__c = 10, ASI_CRM_Activity_Sub_brand_1__c = subBrand2.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));         
            ASI_CRM_Call_Detail__c detail11 = new ASI_CRM_Call_Detail__c(ASI_CRM_Customer__c = customer1.Id, ASI_CRM_Actual_Amount__c = 10000, ASI_CRM_Activity_Sub_brand_1__c = subBrand2.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));  
            ASI_CRM_Call_Detail__c detail12 = new ASI_CRM_Call_Detail__c(ASI_CRM_Customer__c = customer2.Id, ASI_CRM_Actual_Amount__c = 10000, ASI_CRM_Activity_Sub_brand_1__c = subBrand2.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));          
            ASI_CRM_Call_Detail__c detail13 = new ASI_CRM_Call_Detail__c(ASI_CRM_Customer__c = customer1.Id, ASI_CRM_Actual_Amount__c = 10000, ASI_CRM_Activity_Sub_brand_1__c = subBrand3.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            ASI_CRM_Call_Detail__c detail14 = new ASI_CRM_Call_Detail__c(ASI_CRM_Customer__c = customer2.Id, ASI_CRM_Actual_Amount__c = 10000, ASI_CRM_Activity_Sub_brand_1__c = subBrand3.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            ASI_CRM_Call_Detail__c detail15 = new ASI_CRM_Call_Detail__c(ASI_CRM_Customer__c = customer1.Id, ASI_CRM_Actual_Amount__c = 100000, ASI_CRM_Activity_Sub_brand_1__c = subBrand3.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            ASI_CRM_Call_Detail__c detail16 = new ASI_CRM_Call_Detail__c(ASI_CRM_Customer__c = customer2.Id, ASI_CRM_Actual_Amount__c = 100000, ASI_CRM_Activity_Sub_brand_1__c = subBrand3.Id, ASI_CRM_Dohan__c = false, ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            
            detailList.add(detail9);
            detailList.add(detail10);
            detailList.add(detail11);
            detailList.add(detail12);
            detailList.add(detail13);
            detailList.add(detail14);
            detailList.add(detail15);
            detailList.add(detail16);
            insert detailList;
            
            test.startTest();
            detail9.ASI_CRM_Status__c = 'Achieved';
            detail10.ASI_CRM_Status__c = 'Achieved';
            detail11.ASI_CRM_Status__c = 'Achieved';
            detail12.ASI_CRM_Status__c = 'Achieved';
            detail13.ASI_CRM_Status__c = 'Achieved';
            detail14.ASI_CRM_Status__c = 'Achieved';
            detail15.ASI_CRM_Status__c = 'Achieved';
            detail16.ASI_CRM_Status__c = 'Achieved';
            update detailList;
            test.stopTest();
        }
    }
}