/**
 * @File Name          : ASI_CRM_CN_Heavy_PRForm_Ctrl2nd_Test.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/15/2020, 9:28:09 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/17/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
private class ASI_CRM_CN_Heavy_PRForm_Ctrl2nd_Test {
    @TestSetup
    public static void initData() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'ASI Vendor Support System Administrator' LIMIT 1];
        User usr = new User(LastName = 'Chen',
                            FirstName='Peng',
                            Alias = 'Pc',
                            Email = 'penngchen@bluelinksys.com',
                            Username = 'penngchen@bluelinksys.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            ASI_CRM_CN_Prefix__c = 'test',
                            CompanyName = 'Pernod Ricard China');
        insert usr;

        Group gm = new Group();
        gm = [SELECT DeveloperName,Name FROM Group WHERE DeveloperName = :'ASI_CN_GS_Commercial_team' limit 1];

        Group gm1 = new Group();
        gm1 = [SELECT DeveloperName,Name FROM Group WHERE DeveloperName = :'ASI_CN_Commercial_team_ex_GS' limit 1];
        
        Group gm2 = new Group();
        gm2 = [SELECT DeveloperName,Name FROM Group WHERE DeveloperName = :'ASI_CN_Finance' limit 1];

        Group gm3 = new Group();
        gm3 = [SELECT DeveloperName,Name FROM Group WHERE DeveloperName = :'ASI_CN_HQ_Management' limit 1];

        GroupMember amb = new GroupMember();
        amb.GroupId = gm.Id;
        amb.UserOrGroupId = usr.Id;
        Insert amb;

        GroupMember amb1 = new GroupMember();
        amb1.GroupId = gm1.Id;
        amb1.UserOrGroupId = usr.Id;
        Insert amb1;

        GroupMember amb2 = new GroupMember();
        amb2.GroupId = gm2.Id;
        amb2.UserOrGroupId = usr.Id;
        Insert amb2;

        GroupMember amb3 = new GroupMember();
        amb3.GroupId = gm3.Id;
        amb3.UserOrGroupId = usr.Id;
        Insert amb3;

        
    } 

    static testMethod void ASI_CRM_CN_PRForm_Cmpnt_Ctrl2nd_TEST1(){
        User usr = [select Id,LastName ,FirstName,Alias,Email,Username,ProfileId,TimeZoneSidKey,LanguageLocaleKey,EmailEncodingKey,LocaleSidKey,ASI_CRM_CN_Prefix__c from User where Email = 'penngchen@bluelinksys.com'];

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name ='channel Testing', ASI_CRM_CN_On_Off__c='ON',recordtypeid=Schema.getGlobalDescribe().get('ASI_CRM_CN_Channel__c').getDescribe().getRecordTypeInfosByName().get('CN New Channel').getRecordTypeId(),ASI_CRM_For_Outlet__c=true);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_HK_CRM_Product_Category__c ProductCategory = new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,ASI_HK_CRM_Category_Code__c='COG',recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category'));

        insert ProductCategory;

        ASI_TH_CRM_Sub_category__c SubCategory = new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategory.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category'));

        insert SubCategory;
        
        ASI_CRM_Sub_Brand_Grade__c  grade = new ASI_CRM_Sub_Brand_Grade__c (Name='Premium');
        insert grade;
         
        ASI_CRM_Sub_Brand_Group__c grp = new ASI_CRM_Sub_Brand_Group__c(Name='TEST');
        insert grp;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (ASI_CRM_CN_Competitor__c=false, ASI_TH_CRM_Sub_category__c=SubCategory.Id);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand=  new ASI_MFM_Sub_brand__c (Name='TEST1',
                                                                  ASI_MFM_Brand__c=brand.Id,                                                                  
                                                                  ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                                  ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                                                                  ASI_CRM_CN_SubBrand_Group_c__c=grp.Id);
        insert subBrand;

        ASI_MFM_Sub_brand__c subBrand1=  new ASI_MFM_Sub_brand__c (Name='999',
                                                                  ASI_MFM_Brand__c=brand.Id,                                                                  
                                                                  ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                                  ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                                                                  ASI_CRM_CN_SubBrand_Group_c__c=grp.Id);
        Insert subBrand1;
        
         ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 
        
        //ASI_CRM_CN_Outlet_WS__c
        Date TodayDateBefore3= system.today().addMonths(-5);
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        Id contractId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'); 
        
        ASI_TH_CRM_Contract__c contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = contractId,
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=AccountsAdditionalField.Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert contract2;        

        ASI_CRM_Province__c province = new ASI_CRM_Province__c();
        province.Name= 'Province Testing';
        insert province;

        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
        contract.ASI_CRM_CN_PO_End_Date__c = PO_End_Date;
        contract.ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date;   
        contract.ASI_TH_CRM_Promotion_Type__c = 'TOT/MOT Contract';
        contract.ASI_CRM_CN_PO_Version__c = '0.0';
        contract.ASI_CRM_CN_Currency__c = 'USD';
        contract.ASI_CRM_CN_V0_0_PO_version__c = contract2.Id;
        contract.ASI_CRM_CN_PO_No__c = 'TST-100';
        contract.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;
        contract.ASI_CRM_Investment_Type__c = 'Heavy';
        contract.ASI_CRM_PO_Province__c = province.Id;
        contract.ASI_CRM_PO_Channel__c = channel.Id;
        contract.ASI_CRM_PO_City__c = city.Id;
        contract.recordtypeid = contractId;
        insert contract;
        
        
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'ASI_CRM_CN_Contract_BRSF_Line_Item__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        
        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLineItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
        BRSFLineItem.ASI_CRM_CN_Contract__c=contract2.Id;
        BRSFLineItem.ASI_CRM_CN_Est_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Contract_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Sub_Brand__c=subBrand.Id;
        BRSFLineItem.ASI_CRM_Type__c='BRSF';
        BRSFLineItem.recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item');
        BRSFLineItem.RecordTypeId=contRecordTypeId;
        insert BRSFLineItem;

        List<ASI_CRM_Contract_Cost__c> contractcosts = new List<ASI_CRM_Contract_Cost__c> ();
        
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Variable';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Variable';
        contractcosts.add(contractCost);
        
        insert contractcosts;
        
        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        insert paymentRequest;
        
         ASI_CRM_Methodology__c methodology = new ASI_CRM_Methodology__c();
        methodology.Name= 'test';
        insert methodology;
        
       // Id contRecordTypeId1 = [Select id from RecordType where sObjectType = 'ASI_CRM_Module__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        ASI_CRM_Module__c mod= new ASI_CRM_Module__c();
        mod.ASI_CRM_Line_Type__c ='PSF';
        mod.ASI_CRM_Payment_Request__c = paymentRequest.Id;
        mod.ASI_CRM_Methodology__c = methodology.Id;
        insert mod;

        
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> obj = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>();
        
        ASI_Attachment__c attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract.Id;
        attt.ASI_CRM_Type__c='Last Payment Data';
        insert attt;
        
         
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Last Payment Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract.Id;
        attt.ASI_CRM_Type__c='Historical Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Historical Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract.Id;
        attt.ASI_CRM_Type__c='Contract Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Contract Data';
        insert attt;
        
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Cost_Type__c = 'Fixed';  
        paymentLineItem.ASI_CRM_Module__c = mod.Id;
        paymentLineItems.add(paymentLineItem);
        
        paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByName().get('ASI CRM CN Payment Request Detail (Other)').getRecordTypeId(); 
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Cost_Type__c = 'Variable';  
        paymentLineItems.add(paymentLineItem);
        
        paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByName().get('ASI CRM CN Payment Request Detail (PSF)').getRecordTypeId();
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Period_End__c= System.today().addDays(2);
        paymentLineItem.ASI_CRM_CN_Period_Start__c= System.today().addDays(-10);
        paymentLineItem.ASI_CRM_CN_Comment__c = 'This is the testing comment';
        paymentLineItem.ASI_CRM_CN_Contract_Cost__c = contractcosts[0].Id;
        paymentLineItems.add(paymentLineItem); 
        insert paymentLineItems;
        
        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);        
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrand.Id;    
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;
        
        List<ASI_CRM_CM_GS__c> crmcmgs = new List<ASI_CRM_CM_GS__c>();
        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
           
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        insert crmcmgs;
        
         List<ASI_CRM_CN_PH_Payee_Line_Item__c> PLIlst = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        ASI_CRM_CN_PH_Payee_Line_Item__c pLI = new ASI_CRM_CN_PH_Payee_Line_Item__c();
        pLI.CurrencyIsoCode='CNY';
        pLI.ASI_CRM_CN_Payment_Request__c=paymentRequest.Id;
        PLIlst.add(pLI);
        insert PLIlst;
                
        
        ASI_CRM_CN_HeavyContractUtilitiesClass hcUtl= new ASI_CRM_CN_HeavyContractUtilitiesClass();
        //Id contRecordTypeId = [Select id from RecordType where sObjectType = 'ASI_CRM_CN_Contract_BRSF_Line_Item__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        ASI_CRM_CN_Contract_BRSF_Line_Item__c contbrsf = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
        contbrsf.ASI_CRM_Type__c='BRSF';
        contbrsf.ASI_CRM_CN_Contract_Monthly_Qty__c = 100;
        contbrsf.ASI_CRM_CN_Contract__c =contract.Id;
        contbrsf.RecordTypeId=contRecordTypeId;
        insert contbrsf;
        Test.startTest();
 
        date dt = date.today();
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl hctrl1= new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl();
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl hctrl = new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl(new ApexPages.StandardController(paymentRequest));
        hctrl1.HeaderId= paymentRequest.Id;
        hctrl1.strPDF='0';
        hctrl1.dummyVar=True;
        hctrl1.CutOffDay= date.today()+10;
        hctrl1.AdorAbove= true;
        hctrl1.UserId=usr.Id;
        hctrl1.PayeeList=PLIlst;
        //hctrl1.init();
        hctrl1.initPage();
        hctrl1.InitVariable();
        hctrl1.NameSortingASC(5);
        hctrl1.NameSortingASC(50);
        hctrl1.NameSortingASC(500);
        hctrl1.NameSortingASC(5000);
        hctrl1.NameSortingASC(null);
        hctrl1.CalculateV0ContractDetailCost();
        hctrl1.checkFYDayPeriod(dt,dt);
        //hctrl1.DataRounding(new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd());
        hctrl1.DataRounding(new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator());

        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.MonthDiff(dt,dt);
        
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.interimData data = new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.interimData([select Id,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name from ASI_CRM_Module__c limit 1],true);

        Test.stopTest();
    }

    static testMethod void ASI_CRM_CN_PRForm_Cmpnt_Ctrl2nd_TEST2(){
        User usr = [select Id,LastName ,FirstName,Alias,Email,Username,ProfileId,TimeZoneSidKey,LanguageLocaleKey,EmailEncodingKey,LocaleSidKey,ASI_CRM_CN_Prefix__c from User where Email = 'penngchen@bluelinksys.com'];
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name ='channel Testing', ASI_CRM_CN_On_Off__c='ON',recordtypeid=Schema.getGlobalDescribe().get('ASI_CRM_CN_Channel__c').getDescribe().getRecordTypeInfosByName().get('CN New Channel').getRecordTypeId(),ASI_CRM_For_Outlet__c=true);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_Sub_Brand_Grade__c  grade = new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',
                                                                            ASI_CRM_CN_Sequence__c = 0);
        insert grade;
         
        ASI_CRM_Sub_Brand_Group__c grp = new ASI_CRM_Sub_Brand_Group__c(Name='TEST');
        insert grp;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand=  new ASI_MFM_Sub_brand__c (Name='TEST1',
                                                                  ASI_MFM_Brand__c=brand.Id,                                                                  
                                                                  ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                                  ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                                                                  ASI_CRM_CN_SubBrand_Group_c__c=grp.Id);
        
         insert subBrand;

         ASI_MFM_Sub_brand__c subBrand1=  new ASI_MFM_Sub_brand__c (Name='999',
                                                                  ASI_MFM_Brand__c=brand.Id,                                                                  
                                                                  ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                                  ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                                                                  ASI_CRM_CN_SubBrand_Group_c__c=grp.Id);
        Insert subBrand1;
        
         ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 
        
        //ASI_CRM_CN_Outlet_WS__c
        Date TodayDateBefore3= system.today().addMonths(-5);
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        Id contractId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'); 
        
        ASI_TH_CRM_Contract__c contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = contractId,
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=AccountsAdditionalField.Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert contract2;        

        ASI_CRM_Province__c province = new ASI_CRM_Province__c();
        province.Name= 'Province Testing';
        insert province;

        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
        contract.ASI_CRM_CN_PO_End_Date__c = PO_End_Date;
        contract.ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date;   
        contract.ASI_TH_CRM_Promotion_Type__c = 'TOT/MOT Contract';
        contract.ASI_CRM_CN_PO_Version__c = '0.0';
        contract.ASI_CRM_CN_Currency__c = 'USD';
        contract.ASI_CRM_CN_V0_0_PO_version__c = contract2.Id;
        contract.ASI_CRM_CN_PO_No__c = 'TST-100';
        contract.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;
        contract.ASI_CRM_Investment_Type__c = 'Heavy';
        contract.ASI_CRM_PO_Province__c = province.Id;
        contract.ASI_CRM_PO_Channel__c = channel.Id;
        contract.ASI_CRM_PO_City__c = city.Id;
        contract.recordtypeid = contractId;
        insert contract;
        
        
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'ASI_CRM_CN_Contract_BRSF_Line_Item__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        
        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLineItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
        BRSFLineItem.ASI_CRM_CN_Contract__c=contract2.Id;
        BRSFLineItem.ASI_CRM_CN_Est_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Contract_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Sub_Brand__c=subBrand.Id;
        BRSFLineItem.ASI_CRM_Type__c='BRSF';
        BRSFLineItem.recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item');
        BRSFLineItem.RecordTypeId=contRecordTypeId;
        insert BRSFLineItem;

        List<ASI_CRM_Contract_Cost__c> contractcosts = new List<ASI_CRM_Contract_Cost__c> ();
        
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Variable';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Variable';
        contractcosts.add(contractCost);
        
        insert contractcosts;
        
        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        insert paymentRequest;
        
         ASI_CRM_Methodology__c methodology = new ASI_CRM_Methodology__c();
        methodology.Name= 'test';
        insert methodology;
        
       // Id contRecordTypeId1 = [Select id from RecordType where sObjectType = 'ASI_CRM_Module__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        ASI_CRM_Module__c mod= new ASI_CRM_Module__c();
        mod.ASI_CRM_Line_Type__c ='BRSF';
        mod.ASI_CRM_Payment_Request__c = paymentRequest.Id;
        mod.ASI_CRM_Methodology__c = methodology.Id;
        insert mod;
        
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> obj = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>();

        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Cost_Type__c = 'Fixed';
        paymentLineItem.ASI_CRM_Module__c = mod.Id;
        paymentLineItems.add(paymentLineItem);
        
        paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByName().get('ASI CRM CN Payment Request Detail (Other)').getRecordTypeId(); 
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Cost_Type__c = 'Variable';
        paymentLineItems.add(paymentLineItem);
        
        paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByName().get('ASI CRM CN Payment Request Detail (PSF)').getRecordTypeId();
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Period_End__c= System.today().addDays(2);
        paymentLineItem.ASI_CRM_CN_Period_Start__c= System.today().addDays(-10);
        paymentLineItem.ASI_CRM_CN_Comment__c = 'This is the testing comment';
        paymentLineItem.ASI_CRM_CN_Contract_Cost__c = contractcosts[0].Id;
        paymentLineItems.add(paymentLineItem); 
        insert paymentLineItems;
        
        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;
        volume.ASI_CRM_Subbrand__c = subBrand.Id;
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;
        
        List<ASI_CRM_CM_GS__c> crmcmgs = new List<ASI_CRM_CM_GS__c>();
        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
           
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        insert crmcmgs;
        
         List<ASI_CRM_CN_PH_Payee_Line_Item__c> PLIlst = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        ASI_CRM_CN_PH_Payee_Line_Item__c pLI = new ASI_CRM_CN_PH_Payee_Line_Item__c();
        pLI.CurrencyIsoCode='CNY';
        pLI.ASI_CRM_CN_Payment_Request__c=paymentRequest.Id;
        PLIlst.add(pLI);
        insert PLIlst;
                
        
        ASI_CRM_CN_HeavyContractUtilitiesClass hcUtl= new ASI_CRM_CN_HeavyContractUtilitiesClass();
        //Id contRecordTypeId = [Select id from RecordType where sObjectType = 'ASI_CRM_CN_Contract_BRSF_Line_Item__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        ASI_CRM_CN_Contract_BRSF_Line_Item__c contbrsf = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
        contbrsf.ASI_CRM_Type__c='BRSF';
        contbrsf.ASI_CRM_CN_Contract_Monthly_Qty__c = 100;
        contbrsf.ASI_CRM_CN_Contract__c =contract.Id;
        contbrsf.RecordTypeId=contRecordTypeId;
        insert contbrsf;



        Test.startTest();
        date dt = date.today();
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl hctrl1= new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl();
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl hctrl = new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl(new ApexPages.StandardController(paymentRequest));
        hctrl1.HeaderId= paymentRequest.Id;
        hctrl1.dummyVar=True;
        hctrl1.CutOffDay= date.today()+10;
        hctrl1.AdorAbove= true;
        hctrl1.UserId=usr.Id;
        hctrl1.strPDF='1';
        hctrl1.PayeeList=PLIlst;
        //hctrl1.init();
        hctrl1.initPage();
        hctrl1.InitVariable();
        hctrl1.NameSortingASC(5);
        hctrl1.NameSortingASC(50);
        hctrl1.NameSortingASC(500);
        hctrl1.NameSortingASC(5000);
        hctrl1.NameSortingASC(null);
        hctrl1.CalculateV0ContractDetailCost();
        hctrl1.checkFYDayPeriod(dt,dt);
        //hctrl1.DataRounding(new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd());
        hctrl1.DataRounding2nd(new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd());
        
        hctrl1.PaymentSpeed = 0;
        hctrl1.PaymentSpeedexcFixCost = 0;
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.MonthDiff(dt,dt);
        
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.interimData data = new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.interimData([select Id,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name from ASI_CRM_Module__c limit 1],true);
        Test.stopTest();
    }

    static testMethod void ASI_CRM_CN_PRForm_Cmpnt_Ctrl2nd_TEST3(){
        User usr = [select Id,LastName ,FirstName,Alias,Email,Username,ProfileId,TimeZoneSidKey,LanguageLocaleKey,EmailEncodingKey,LocaleSidKey,ASI_CRM_CN_Prefix__c from User where Email = 'penngchen@bluelinksys.com'];
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name ='channel Testing', ASI_CRM_CN_On_Off__c='ON',recordtypeid=Schema.getGlobalDescribe().get('ASI_CRM_CN_Channel__c').getDescribe().getRecordTypeInfosByName().get('CN New Channel').getRecordTypeId(),ASI_CRM_For_Outlet__c=true);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_Sub_Brand_Grade__c  grade = new ASI_CRM_Sub_Brand_Grade__c (Name='Premium');
        insert grade;
         
        ASI_CRM_Sub_Brand_Group__c grp = new ASI_CRM_Sub_Brand_Group__c(Name='TEST');
        insert grp;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand=  new ASI_MFM_Sub_brand__c (Name='TEST1',
                                                                  ASI_MFM_Brand__c=brand.Id,                                                                  
                                                                  ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                                  ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                                                                  ASI_CRM_CN_SubBrand_Group_c__c=grp.Id);
        
         insert subBrand;

         ASI_MFM_Sub_brand__c subBrand1=  new ASI_MFM_Sub_brand__c (Name='999',
                                                                  ASI_MFM_Brand__c=brand.Id,                                                                  
                                                                  ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                                  ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                                                                  ASI_CRM_CN_SubBrand_Group_c__c=grp.Id);
        Insert subBrand1;
        
         ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 
        
        //ASI_CRM_CN_Outlet_WS__c
        Date TodayDateBefore3= system.today().addMonths(-5);
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        Id contractId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'); 
        
        ASI_TH_CRM_Contract__c contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = contractId,
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=AccountsAdditionalField.Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert contract2;        

        ASI_CRM_Province__c province = new ASI_CRM_Province__c();
        province.Name= 'Province Testing';
        insert province;

        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
        contract.ASI_CRM_CN_PO_End_Date__c = PO_End_Date;
        contract.ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date;   
        contract.ASI_TH_CRM_Promotion_Type__c = 'TOT/MOT Contract';
        contract.ASI_CRM_CN_PO_Version__c = '0.0';
        contract.ASI_CRM_CN_Currency__c = 'USD';
        contract.ASI_CRM_CN_V0_0_PO_version__c = null;
        contract.ASI_CRM_CN_PO_No__c = 'TST-100';
        contract.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;
        contract.ASI_CRM_Investment_Type__c = 'Heavy';
        contract.ASI_CRM_PO_Province__c = province.Id;
        contract.ASI_CRM_PO_Channel__c = channel.Id;
        contract.ASI_CRM_PO_City__c = city.Id;
        contract.recordtypeid = contractId;
        // contract.ASI_TH_CRM_Promotion_Type__c = 'Heavy Contract On';
        insert contract;

        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=contract.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"VsRegionalAverageIndexProForma":0.0,"VsRegionalAverageIndex":0.0,"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TradeExpenseBySubBrand":[],"TotalMBCRate":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProFormaExcl":0.0,"ROIProForma":0.0,"ROIIntakeExcl":0.0,"ROIIntake":0.0,"ROIActual":0.0,"RegionalTargetIndexProForma":0.0,"RegionalTargetIndex":0.0,"RegionalAverageTarget":0.0,"RegionalAverageIndexProForma":0.0,"RegionalAverageIndex":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2020-04-29","POEndDate":"2020-04-29","OutletSet":[],"NoOfMonths":1,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":0.0,"MarginPerBottle":0.0,"MarginAfterAnPProForma":0.0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotalProForma":0.0,"GrossSalesTotal":0.0,"GrossSalesRateProForma":0.0,"GrossSalesRateExcl":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DomesticTarget":0.0,"DomesticContractIndexProForma":0.0,"DomesticContractIndex":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMNSRateProForma":0.0,"CMNSRate":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"ADTotalProForma":0.0,"ADTotal":0.0,"AddOnString":""},{"VsRegionalAverageIndexProForma":0.0,"VsRegionalAverageIndex":0.0,"Volumes":0.0,"VariableExpensesMap":{},"VariableExpense":0.0,"TradeExpenses":0.0,"TradeExpenseBySubBrand":[],"TotalMBCRate":0.0,"TotalBCRate":0.0,"SubBrandGradeMap":{},"SubBrandGradeGrouping":{},"ROIProFormaExcl":0.0,"ROIProForma":0.0,"ROIIntakeExcl":0.0,"ROIIntake":0.0,"ROIActual":0.0,"RegionalTargetIndexProForma":0.0,"RegionalTargetIndex":0.0,"RegionalAverageTarget":0.0,"RegionalAverageIndexProForma":0.0,"RegionalAverageIndex":0.0,"PSFVolumeBase":"","PSFMethodologyName":"","POStartDate":"2020-04-29","POEndDate":"2020-04-29","OutletSet":[],"NoOfMonths":1,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":0.0,"MarginPerBottle":0.0,"MarginAfterAnPProForma":0.0,"MarginAfterAnP":0.0,"LatestBudgetCMTotal":0.0,"InvestmentCR12":0.0,"IntakeSTD":0.0,"IntakeCR12":0.0,"GSId":" ","GrossSalesTotalProForma":0.0,"GrossSalesTotal":0.0,"GrossSalesRateProForma":0.0,"GrossSalesRateExcl":0.0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":0.0,"FixedExpense":0.0,"DomesticTarget":0.0,"DomesticContractIndexProForma":0.0,"DomesticContractIndex":0.0,"DebugMap":{},"ContractLineMap":{},"ContractId":"","CMTotal":0.0,"CMNSRateProForma":0.0,"CMNSRate":0.0,"CMId":" ","CategoryMap":{},"BRSFMethodologyName":"","BCRate":0.0,"ADTotalProForma":0.0,"ADTotal":0.0,"AddOnString":""}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=contract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37,"ROIActual":3.37,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{},"ContractId":"aBt3N000000CahySAC","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""},{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37405803901500866574965612104539,"ROIActual":3.37405803901500866574965612104539,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{"00001皇家礼炮62响 Royal Salute 62 Gun Salute-ROI":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮62响 Royal Salute 62 Gun Salute-ROI","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":300,"EstimateTotalFees":12000.00,"EstimateFees":40.00,"EstimateBottles":100,"ContractVolume":300,"ContractTotalFees":12000.00,"ContractFees":40.00,"ContractBottles":100},"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":1200,"EstimateTotalFees":48000.00,"EstimateFees":40.00,"EstimateBottles":400,"ContractVolume":1200,"ContractTotalFees":48000.00,"ContractFees":40.00,"ContractBottles":400},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":600,"EstimateTotalFees":54000.00,"EstimateFees":90.00,"EstimateBottles":200,"ContractVolume":600,"ContractTotalFees":54000.00,"ContractFees":90.00,"ContractBottles":200},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"干邑","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":900,"EstimateTotalFees":90000.00,"EstimateFees":100.00,"EstimateBottles":300,"ContractVolume":900,"ContractTotalFees":90000.00,"ContractFees":100.00,"ContractBottles":300}},"ContractId":"","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""}]';
        AttachmentList.add(Attachment2); 

        ASI_Attachment__c Attachment3=new ASI_Attachment__c (ASI_CRM_Contract__c=contract.Id,ASI_CRM_Type__c='Last Payment Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment3.ASI_CRM_Historical_Financial_Data__c='[{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37,"ROIActual":3.37,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{"00001皇家礼炮62响 Royal Salute 62 Gun Salute-ROI":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮62响 Royal Salute 62 Gun Salute-ROI","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":300,"EstimateTotalFees":12000.00,"EstimateFees":40.00,"EstimateBottles":100,"ContractVolume":300,"ContractTotalFees":12000.00,"ContractFees":40.00,"ContractBottles":100},"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":1200,"EstimateTotalFees":48000.00,"EstimateFees":40.00,"EstimateBottles":400,"ContractVolume":1200,"ContractTotalFees":48000.00,"ContractFees":40.00,"ContractBottles":400},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":600,"EstimateTotalFees":54000.00,"EstimateFees":90.00,"EstimateBottles":200,"ContractVolume":600,"ContractTotalFees":54000.00,"ContractFees":90.00,"ContractBottles":200},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"干邑","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":900,"EstimateTotalFees":90000.00,"EstimateFees":100.00,"EstimateBottles":300,"ContractVolume":900,"ContractTotalFees":90000.00,"ContractFees":100.00,"ContractBottles":300}},"ContractId":"aBt3N000000CahySAC","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""},{"VsRegionalAverageIndexProForma":48.48,"VsRegionalAverageIndex":48.48,"Volumes":233.3334,"VariableExpensesMap":{},"VariableExpense":559000.00,"TradeExpenses":727000.00,"TradeExpenseBySubBrand":[{"volumeSTD":900,"volumeCR12":1350.0000,"volume9L":70.0000,"VECTradeExpense":54000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":54000.0000,"tradeExpensePerBottle2nd":242.2222,"tradeExpensePerBottle":242.2222,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":50.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":2000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.4815,"incentivePer":2.2222,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":2000.0000,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":27000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":27000.0000,"actualPayment":0.00}],"totalTradeExpense":218000.0000,"subBrandName":"马爹利名士","subBrandId":"a8G3N0000004D8mUAE","subBrandCode":"MLE","ROI":1.1587,"RegionalTargetIndex":15.90,"RegionalAverageInvestment":400.000000,"RegionalAverageIndex":85.00,"RegionalAverageAfterSpending":3108.610000,"PSFTradeExpense":47000.0000,"PSFPerTradeExpense":52.2222,"PSFGap":0,"PSFAmount":47000.0000,"propByTotal":0.0769,"propByStdTotal":0.3000,"propByGrade":0.3103,"propByCategory":1.0000,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":300,"monthlyVolumeCR12":450.0000,"monthlyVolume9L":23.3333,"MarginPerBottle":38.4472,"latestBudgetCMTotal":252602.4797,"GSTotal":356017.6991,"GSPercent":61.2329,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":211.1111,"GapWithRegionalAverageIndex":-69.10,"GapWithDomesticInvestment":209.6333,"GapWithDomesticIndexTarget":-83.52,"fixCostTradeExpense":27000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":419.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":16.48,"DomesticCMAfterSpending":3000.330000,"cr12Factor":1.50,"CMTotal":252602.4797,"CMBeforeSpending":3608.606853,"categoryName":"干邑","categoryId":"a8X3N00000001ElUAI","BRSFTradeExpense":90000.0000,"BRSFPerTradeExpense":100.00,"BRSFIncentive":100.00,"BRSFGap":0,"BRSFAmount":90000.0000},{"volumeSTD":600,"volumeCR12":2700.0000,"volume9L":46.6667,"VECTradeExpense":30000.0000,"VECPerTradeExpense":50.0000,"VECGap":0,"VECAmount":30000.0000,"tradeExpensePerBottle2nd":285.5556,"tradeExpensePerBottle":285.5556,"tradeExpenseByPSFModule":[{"tradeExpense":24000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":40.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":24000.0000,"actualPayment":0.00},{"tradeExpense":3333.3333,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":5.5556,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3333.3333,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":60000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":100.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":60000.0000,"actualPayment":0.00}],"totalTradeExpense":171333.3333,"subBrandName":"皇家礼炮21年","subBrandId":"a8G3N0000004D84UAE","subBrandCode":"ROC","ROI":2.0147,"RegionalTargetIndex":90.67,"RegionalAverageInvestment":500.000000,"RegionalAverageIndex":105.00,"RegionalAverageAfterSpending":4108.610000,"PSFTradeExpense":27333.3333,"PSFPerTradeExpense":45.5556,"PSFGap":0,"PSFAmount":27333.3333,"propByTotal":0.1538,"propByStdTotal":0.2000,"propByGrade":1.0000,"propByCategory":0.1667,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":200,"monthlyVolumeCR12":900.0000,"monthlyVolume9L":15.5556,"MarginPerBottle":289.7391,"latestBudgetCMTotal":345177.0683,"GSTotal":513451.6944,"GSPercent":33.3689,"gradeName":"Prestige","gradeId":"aFA3N000000002YWAQ","GapWithRegionalAverageInvestment":246.6667,"GapWithRegionalAverageIndex":-14.33,"GapWithDomesticInvestment":200.3112,"GapWithDomesticIndexTarget":-40.88,"fixCostTradeExpense":60000.0000,"fixCostPerTradeExpense":100.0000,"factor9L":0.70,"DomesticInvestment":1096.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":59.12,"DomesticCMAfterSpending":6300.646180,"cr12Factor":4.50,"CMTotal":345177.0683,"CMBeforeSpending":7396.646180,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":54000.0000,"BRSFPerTradeExpense":90.00,"BRSFIncentive":90.00,"BRSFGap":0,"BRSFAmount":54000.0000},{"volumeSTD":1200,"volumeCR12":3000.0000,"volume9L":93.3333,"VECTradeExpense":72000.0000,"VECPerTradeExpense":60.0000,"VECGap":0,"VECAmount":72000.0000,"tradeExpensePerBottle2nd":168.0864,"tradeExpensePerBottle":168.0864,"tradeExpenseByPSFModule":[{"tradeExpense":42000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":35.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":42000.0000,"actualPayment":0.00},{"tradeExpense":3703.7037,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":3.0864,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":3703.7037,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":36000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":30.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":36000.0000,"actualPayment":0.00}],"totalTradeExpense":201703.7037,"subBrandName":"芝华士18年","subBrandId":"a8G3N0000004D88UAE","subBrandCode":"CH2","ROI":1.9967,"RegionalTargetIndex":58.08,"RegionalAverageInvestment":450.000000,"RegionalAverageIndex":90.00,"RegionalAverageAfterSpending":3708.610000,"PSFTradeExpense":45703.7037,"PSFPerTradeExpense":38.0864,"PSFGap":0,"PSFAmount":45703.7037,"propByTotal":0.1709,"propByStdTotal":0.4000,"propByGrade":0.6897,"propByCategory":0.1852,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":400,"monthlyVolumeCR12":1000.0000,"monthlyVolume9L":31.1111,"MarginPerBottle":167.5346,"latestBudgetCMTotal":402745.0187,"GSTotal":484247.6147,"GSPercent":41.6530,"gradeName":"Ultra Premium","gradeId":"aFA3N000000002iWAA","GapWithRegionalAverageInvestment":133.0864,"GapWithRegionalAverageIndex":-31.92,"GapWithDomesticInvestment":128.0308,"GapWithDomesticIndexTarget":-43.32,"fixCostTradeExpense":36000.0000,"fixCostPerTradeExpense":30.0000,"factor9L":0.70,"DomesticInvestment":515.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":56.68,"DomesticCMAfterSpending":3800.126742,"cr12Factor":2.50,"CMTotal":402745.0187,"CMBeforeSpending":4315.126742,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":48000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":48000.0000},{"volumeSTD":300,"volumeCR12":10500.0000,"volume9L":23.3333,"VECTradeExpense":21000.0000,"VECPerTradeExpense":70.0000,"VECGap":0,"VECAmount":21000.0000,"tradeExpensePerBottle2nd":453.2099,"tradeExpensePerBottle":453.2099,"tradeExpenseByPSFModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJwSAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00},{"tradeExpense":12962.9630,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJxSAM","incentivePerCR12":1.2346,"incentivePer":43.2099,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":12962.9630,"actualPayment":0.00}],"tradeExpenseByFXModule":[{"tradeExpense":45000.0000,"totalCTDPayableAmount":0,"moduleId":"aRo3N0000004CJySAM","incentivePerCR12":0.0000,"incentivePer":150.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":45000.0000,"actualPayment":0.00}],"totalTradeExpense":135962.9630,"subBrandName":"皇家礼炮62响","subBrandId":"a8G3N0000004ClqUAE","subBrandCode":"ROI","ROI":10.6824,"RegionalTargetIndex":0.0,"RegionalAverageInvestment":0.0,"RegionalAverageIndex":0.0,"RegionalAverageAfterSpending":0.0,"PSFTradeExpense":57962.9630,"PSFPerTradeExpense":193.2099,"PSFGap":0,"PSFAmount":57962.9630,"propByTotal":0.5983,"propByStdTotal":0.1000,"propByGrade":1.0000,"propByCategory":0.6481,"propByBRSFAmt":null,"nonContract":false,"monthlyVolumeSTD":100,"monthlyVolumeCR12":3500.0000,"monthlyVolume9L":7.7778,"MarginPerBottle":4388.1604,"latestBudgetCMTotal":1452409.0242,"GSTotal":2871792.3588,"GSPercent":4.7344,"gradeName":"Ultra Prestige","gradeId":"aFA3N000000002TWAQ","GapWithRegionalAverageInvestment":453.2099,"GapWithRegionalAverageIndex":0.0,"GapWithDomesticInvestment":-577.0345,"GapWithDomesticIndexTarget":15.14,"fixCostTradeExpense":45000.0000,"fixCostPerTradeExpense":150.0000,"factor9L":0.70,"DomesticInvestment":13246.000000,"DomesticIndexTarget":100.00,"DomesticContractIndex":115.14,"DomesticCMAfterSpending":49000.189960,"cr12Factor":35.00,"CMTotal":1452409.0242,"CMBeforeSpending":62246.189960,"categoryName":"威士忌","categoryId":"a8X3N00000001EmUAI","BRSFTradeExpense":12000.0000,"BRSFPerTradeExpense":40.00,"BRSFIncentive":40.00,"BRSFGap":0,"BRSFAmount":12000.0000}],"TotalMBCRate":97.00,"TotalBCRate":3.00,"SubBrandGradeMap":{"4. Prestige + Ultra Prestige 奢华档 + 特级奢华档":70.0002,"3. Ultra Premium 特级高档":163.3332},"SubBrandGradeGrouping":{"Ultra Prestige":23.3334,"Ultra Premium":163.3332,"Prestige":46.6668},"ROIProFormaExcl":3.37404895584594222833562585969739,"ROIProForma":3.37405803901500866574965612104539,"ROIIntakeExcl":3.37404895584594222833562585969739,"ROIIntake":3.37405803901500866574965612104539,"ROIActual":3.37405803901500866574965612104539,"RegionalTargetIndexProForma":228.46,"RegionalTargetIndex":228.46,"RegionalAverageTarget":251.824922222222222222222222222222,"RegionalAverageIndexProForma":37.73,"RegionalAverageIndex":37.73,"PSFVolumeBase":"By Sub-Brand(按品牌);By Category(按产品类别);","PSFMethodologyName":"aRn3N000000000aSAA;","POStartDate":"2020-10-01","POEndDate":"2020-12-31","OutletSet":[],"NoOfMonths":3,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottleProForma":575.31,"MarginPerBottle":575.31,"MarginAfterAnPProForma":1725940.1943639113,"MarginAfterAnP":1725940.1943639113,"LatestBudgetCMTotal":2452940.1943639113,"InvestmentCR12":41.42,"IntakeSTD":3000,"IntakeCR12":17550.00,"GSId":" ","GrossSalesTotalProForma":4225522.2663075219,"GrossSalesTotal":4225522.2663075219,"GrossSalesRateProForma":17.20,"GrossSalesRateExcl":17.205026349667064884298480363539100,"GrossSalesRate":17.20,"FixedExpensesMap":{},"FixedExpenseRate":23.11,"FixedExpense":168000.00,"DomesticTarget":667.356505573333333333333333333332,"DomesticContractIndexProForma":86.21,"DomesticContractIndex":86.21,"DebugMap":{},"ContractLineMap":{"00001皇家礼炮62响 Royal Salute 62 Gun Salute-ROI":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮62响 Royal Salute 62 Gun Salute-ROI","SubBrandGrade":"Ultra Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":300,"EstimateTotalFees":12000.00,"EstimateFees":40.00,"EstimateBottles":100,"ContractVolume":300,"ContractTotalFees":12000.00,"ContractFees":40.00,"ContractBottles":100},"00003芝华士18年 Chivas 18YO-CH2":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"芝华士18年 Chivas 18YO-CH2","SubBrandGrade":"Ultra Premium","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":1200,"EstimateTotalFees":48000.00,"EstimateFees":40.00,"EstimateBottles":400,"ContractVolume":1200,"ContractTotalFees":48000.00,"ContractFees":40.00,"ContractBottles":400},"00002皇家礼炮21年 Royal Salute 21YO-ROC":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"皇家礼炮21年 Royal Salute 21YO-ROC","SubBrandGrade":"Prestige","SubBrandCategory":"威士忌","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":600,"EstimateTotalFees":54000.00,"EstimateFees":90.00,"EstimateBottles":200,"ContractVolume":600,"ContractTotalFees":54000.00,"ContractFees":90.00,"ContractBottles":200},"00003马爹利名士 Martell Noblige-MLE":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"马爹利名士 Martell Noblige-MLE","SubBrandGrade":"Ultra Premium","SubBrandCategory":"干邑","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":900,"EstimateTotalFees":90000.00,"EstimateFees":100.00,"EstimateBottles":300,"ContractVolume":900,"ContractTotalFees":90000.00,"ContractFees":100.00,"ContractBottles":300}},"ContractId":"","CMTotal":2452940.1943639113,"CMNSRateProForma":50.24,"CMNSRate":50.24,"CMId":" ","CategoryMap":{"威士忌":163.3335,"干邑":69.9999},"BRSFMethodologyName":"aRn3N000000000fSAA","BCRate":3.00,"ADTotalProForma":62999.9100000000,"ADTotal":62999.9100000000,"AddOnString":""}]';
        AttachmentList.add(Attachment3); 
        
        insert AttachmentList;
        
        
        
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'ASI_CRM_CN_Contract_BRSF_Line_Item__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        
        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLineItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
        BRSFLineItem.ASI_CRM_CN_Contract__c=contract2.Id;
        BRSFLineItem.ASI_CRM_CN_Est_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Contract_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Sub_Brand__c=subBrand.Id;
        BRSFLineItem.ASI_CRM_Type__c='BRSF';
        BRSFLineItem.recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item');
        BRSFLineItem.RecordTypeId=contRecordTypeId;
        insert BRSFLineItem;

        List<ASI_CRM_Contract_Cost__c> contractcosts = new List<ASI_CRM_Contract_Cost__c> ();
        
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Variable';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Variable';
        contractcosts.add(contractCost);
        
        insert contractcosts;
        
        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = false;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        // paymentRequest.ASI_CRM_CN_Promotion_Type__c = 'Heavy Contract On';
        insert paymentRequest;
        
         ASI_CRM_Methodology__c methodology = new ASI_CRM_Methodology__c();
        methodology.Name= 'test';
        insert methodology;
        
       // Id contRecordTypeId1 = [Select id from RecordType where sObjectType = 'ASI_CRM_Module__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        ASI_CRM_Module__c mod= new ASI_CRM_Module__c();
        mod.ASI_CRM_Line_Type__c ='BRSF';
        mod.ASI_CRM_Payment_Request__c = paymentRequest.Id;
        mod.ASI_CRM_Methodology__c = methodology.Id;
        insert mod;
        
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> obj = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>();

        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        // paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        // paymentLineItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        // paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        // paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        // paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        // paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        // paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        // paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        // paymentLineItem.ASI_CRM_CN_Cost_Type__c = 'Fixed';  
        // paymentLineItem.ASI_CRM_Module__c = mod.Id;
        
        // paymentLineItems.add(paymentLineItem);


        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Cost_Type__c = 'Fixed';  
        paymentLineItem.ASI_CRM_Module__c = mod.Id;
        
        paymentLineItems.add(paymentLineItem);
        
        paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByName().get('ASI CRM CN Payment Request Detail (Other)').getRecordTypeId(); 
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Cost_Type__c = 'Variable';  
        paymentLineItems.add(paymentLineItem);
        
        paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByName().get('ASI CRM CN Payment Request Detail (PSF)').getRecordTypeId();
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Period_End__c= System.today().addDays(2);
        paymentLineItem.ASI_CRM_CN_Period_Start__c= System.today().addDays(-10);
        paymentLineItem.ASI_CRM_CN_Comment__c = 'This is the testing comment';
        paymentLineItem.ASI_CRM_CN_Contract_Cost__c = contractcosts[0].Id;
        paymentLineItems.add(paymentLineItem); 
        insert paymentLineItems;
        
        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);        
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrand.Id;    
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;
        
        List<ASI_CRM_CM_GS__c> crmcmgs = new List<ASI_CRM_CM_GS__c>();
        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
           
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        insert crmcmgs;
        
         List<ASI_CRM_CN_PH_Payee_Line_Item__c> PLIlst = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        ASI_CRM_CN_PH_Payee_Line_Item__c pLI = new ASI_CRM_CN_PH_Payee_Line_Item__c();
        pLI.CurrencyIsoCode='CNY';
        pLI.ASI_CRM_CN_Payment_Request__c=paymentRequest.Id;
        PLIlst.add(pLI);
        insert PLIlst;
                
        
        ASI_CRM_CN_HeavyContractUtilitiesClass hcUtl= new ASI_CRM_CN_HeavyContractUtilitiesClass();
        //Id contRecordTypeId = [Select id from RecordType where sObjectType = 'ASI_CRM_CN_Contract_BRSF_Line_Item__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        ASI_CRM_CN_Contract_BRSF_Line_Item__c contbrsf = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
        contbrsf.ASI_CRM_Type__c='BRSF';
        contbrsf.ASI_CRM_CN_Contract_Monthly_Qty__c = 100;//        
        contbrsf.ASI_CRM_CN_Contract__c =contract.Id;
        contbrsf.RecordTypeId=contRecordTypeId;
        insert contbrsf;



        Test.startTest();
        date dt = date.today();
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl hctrl1= new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl();
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl hctrl = new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl(new ApexPages.StandardController(paymentRequest));
        hctrl1.HeaderId= paymentRequest.Id;
        hctrl1.strPDF='2';
        hctrl1.dummyVar=True;
        hctrl1.CutOffDay= date.today()+10;
        hctrl1.AdorAbove= true;
        hctrl1.UserId=usr.Id;
        hctrl1.PayeeList=PLIlst;
        //hctrl1.init();
        hctrl1.initPage();
        hctrl1.InitVariable();
        hctrl1.NameSortingASC(5);
        hctrl1.NameSortingASC(50);
        hctrl1.NameSortingASC(500);
        hctrl1.NameSortingASC(5000);
        hctrl1.NameSortingASC(null);
        hctrl1.CalculateV0ContractDetailCost();
        hctrl1.checkFYDayPeriod(dt,dt);
        //hctrl1.DataRounding(new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd());
        hctrl1.DataRounding2nd(new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd());

        hctrl1.PaymentSpeed = 0;
        hctrl1.PaymentSpeedexcFixCost = 0;
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.MonthDiff(dt,dt);

        String inverJSON = '{1={lastPayment = BRSFAmount = 48000.0000, BRSFGap = 0, BRSFIncentive = 40.00, BRSFPerTradeExpense = 40.00, BRSFTradeExpense = 48000.0000, CMBeforeSpending = 4315.126742, CMTotal = 402745.0187, DomesticCMAfterSpending = 3800.126742, DomesticContractIndex = 56.68, DomesticIndexTarget = 100.00, DomesticInvestment = 515.000000, GSPercent = 41.6530, GSTotal = 484247.6147, GapWithDomesticIndexTarget = -43.32, GapWithDomesticInvestment = 128.0308, GapWithRegionalAverageIndex = -31.92, GapWithRegionalAverageInvestment = 133.0864, MarginPerBottle = 167.5346, PSFAmount = 45703.7037, PSFGap = 0, PSFPerTradeExpense = 38.0864, PSFTradeExpense = 45703.7037, ROI = 1.9967, RegionalAverageAfterSpending = 3708.610000, RegionalAverageIndex = 90.00, RegionalAverageInvestment = 450.000000, RegionalTargetIndex = 58.08, VECAmount = 72000.0000, VECGap = 0, VECPerTradeExpense = 60.0000, VECTradeExpense = 72000.0000, categoryId = a8X3N00000001EmUAI, categoryName = 威士忌, cr12Factor = 2.50, factor9L = 0.70, fixCostPerTradeExpense = 30.0000, fixCostTradeExpense = 36000.0000, gradeId = aFA3N000000002iWAA, gradeName = Ultra Premium, latestBudgetCMTotal = 402745.0187, monthlyVolume9L = 31.1111, monthlyVolumeCR12 = 1000.0000, monthlyVolumeSTD = 400, nonContract = false, propByBRSFAmt = null, propByCategory = 0.1852, propByGrade = 0.6897, propByStdTotal = 0.4000, propByTotal = 0.1709, subBrandCode = CH2, subBrandId = a8G3N0000004D88UAE, subBrandName = 芝华士18年, totalTradeExpense = 201703.7037, tradeExpenseByFXModule = (ModuleTradeExpense: [actualPayment = 0.00, amount = 36000.0000, applicationPaymentAmount = 0.00, gap = 0, historicalPaidAmount = 0.00, incentivePer = 30.0000, incentivePerCR12 = 0.0000, moduleId = aRo3N0000004CJySAM, totalCTDPayableAmount = 0, tradeExpense = 36000.0000]), tradeExpenseByPSFModule = (ModuleTradeExpense: [actualPayment = 0.00, amount = 42000.0000, applicationPaymentAmount = 0.00, gap = 0, historicalPaidAmount = 0.00, incentivePer = 35.0000, incentivePerCR12 = 0.0000, moduleId = aRo3N0000004CJwSAM, totalCTDPayableAmount = 0, tradeExpense = 42000.0000], ModuleTradeExpense: [actualPayment = 0.00, amount = 3703.7037, applicationPaymentAmount = 0.00, gap = 0, historicalPaidAmount = 0.00, incentivePer = 3.0864, incentivePerCR12 = 1.2346, moduleId = aRo3N0000004CJxSAM, totalCTDPayableAmount = 0, tradeExpense = 3703.7037]), tradeExpensePerBottle2nd = 168.0864, tradeExpensePerBottle = 168.0864, volume9L = 93.3333, volumeCR12 = 3000.0000, volumeSTD = 1200}}';
        // Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> result2 = hctrl1.investmentBySubBrandByContractByLastVolume((Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>)System.JSON.deserialize(inverJSON, Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>.class));
        
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.interimData data = new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.interimData([select Id,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name from ASI_CRM_Module__c limit 1],true);
        
        contract.ASI_CRM_CN_Is_2nd_KPI_PO__c = true;
        update contract;
        hctrl1.initPage();

        Test.stopTest();
    }

    // static testMethod void ASI_CRM_CN_PRForm_Cmpnt_Ctrl2nd_TEST4(){

    //     Test.startTest();
    //     ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl hctrl1= new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl();
    //         Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> result = ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.getInvestmentBySubBrand(keys,financialIndicators);
    //         Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> result2 = hctrl1.investmentBySubBrandByContractByLastVolume(result);
    //         Set<Id> usIdSet = new Set<Id>();
    //         usIdSet.add(usr.Id);
    //         hctrl1.checkOtherUserGroup(usIdSet);
    //         ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.checkAdorAbove(usr.Id);
    //     Test.stopTest();
    // }
    
    static testMethod void ASI_CRM_CN_PRForm_Cmpnt_Ctrl2nd_TEST4(){
        User usr = [select Id,LastName ,FirstName,Alias,Email,Username,ProfileId,TimeZoneSidKey,LanguageLocaleKey,EmailEncodingKey,LocaleSidKey,ASI_CRM_CN_Prefix__c from User where Email = 'penngchen@bluelinksys.com'];

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name ='channel Testing', ASI_CRM_CN_On_Off__c='ON',recordtypeid=Schema.getGlobalDescribe().get('ASI_CRM_CN_Channel__c').getDescribe().getRecordTypeInfosByName().get('CN New Channel').getRecordTypeId(),ASI_CRM_For_Outlet__c=true);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_HK_CRM_Product_Category__c ProductCategory = new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,ASI_HK_CRM_Category_Code__c='COG',recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category'));

        insert ProductCategory;

        ASI_TH_CRM_Sub_category__c SubCategory = new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategory.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category'));

        insert SubCategory;
        
        ASI_CRM_Sub_Brand_Grade__c  grade = new ASI_CRM_Sub_Brand_Grade__c (Name='Premium');
        insert grade;
         
        ASI_CRM_Sub_Brand_Group__c grp = new ASI_CRM_Sub_Brand_Group__c(Name='TEST');
        insert grp;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (ASI_CRM_CN_Competitor__c=false, ASI_TH_CRM_Sub_category__c=SubCategory.Id);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand=  new ASI_MFM_Sub_brand__c (Name='TEST1',
                                                                  ASI_MFM_Brand__c=brand.Id,                                                                  
                                                                  ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                                  ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                                                                  ASI_CRM_CN_SubBrand_Group_c__c=grp.Id);
        insert subBrand;

        ASI_MFM_Sub_brand__c subBrand1=  new ASI_MFM_Sub_brand__c (Name='999',
                                                                  ASI_MFM_Brand__c=brand.Id,                                                                  
                                                                  ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                                  ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                                                                  ASI_CRM_CN_SubBrand_Group_c__c=grp.Id);
        Insert subBrand1;
        
         ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;       
         insert AccountsAdditionalField; 
        
        //ASI_CRM_CN_Outlet_WS__c
        Date TodayDateBefore3= system.today().addMonths(-5);
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        Id contractId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'); 
        
        ASI_TH_CRM_Contract__c contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = contractId,
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=AccountsAdditionalField.Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert contract2;        

        ASI_CRM_Province__c province = new ASI_CRM_Province__c();
        province.Name= 'Province Testing';
        insert province;

        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
        contract.ASI_CRM_CN_PO_End_Date__c = PO_End_Date;
        contract.ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date;   
        contract.ASI_TH_CRM_Promotion_Type__c = 'TOT/MOT Contract';
        contract.ASI_CRM_CN_PO_Version__c = '0.0';
        contract.ASI_CRM_CN_Currency__c = 'USD';
        contract.ASI_CRM_CN_V0_0_PO_version__c = contract2.Id;
        contract.ASI_CRM_CN_PO_No__c = 'TST-100';
        contract.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;
        contract.ASI_CRM_Investment_Type__c = 'Heavy';
        contract.ASI_CRM_PO_Province__c = province.Id;
        contract.ASI_CRM_PO_Channel__c = channel.Id;
        contract.ASI_CRM_PO_City__c = city.Id;
        contract.recordtypeid = contractId;
        contract.ASI_CRM_CN_Is_2nd_KPI_PO__c = true;
        insert contract;
        
        
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'ASI_CRM_CN_Contract_BRSF_Line_Item__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        
        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLineItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
        BRSFLineItem.ASI_CRM_CN_Contract__c=contract2.Id;
        BRSFLineItem.ASI_CRM_CN_Est_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Contract_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Sub_Brand__c=subBrand.Id;
        BRSFLineItem.ASI_CRM_Type__c='BRSF';
        BRSFLineItem.recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item');
        BRSFLineItem.RecordTypeId=contRecordTypeId;
        insert BRSFLineItem;

        List<ASI_CRM_Contract_Cost__c> contractcosts = new List<ASI_CRM_Contract_Cost__c> ();
        
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Variable';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Variable';
        contractcosts.add(contractCost);
        
        insert contractcosts;
        
        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        insert paymentRequest;
        
         ASI_CRM_Methodology__c methodology = new ASI_CRM_Methodology__c();
        methodology.Name= 'test';
        insert methodology;
        
       // Id contRecordTypeId1 = [Select id from RecordType where sObjectType = 'ASI_CRM_Module__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        ASI_CRM_Module__c mod= new ASI_CRM_Module__c();
        mod.ASI_CRM_Line_Type__c ='PSF';
        mod.ASI_CRM_Payment_Request__c = paymentRequest.Id;
        mod.ASI_CRM_Methodology__c = methodology.Id;
        insert mod;

        
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> obj = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>();
        
        ASI_Attachment__c attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract.Id;
        attt.ASI_CRM_Type__c='Last Payment Data';
        insert attt;
        
         
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Last Payment Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract.Id;
        attt.ASI_CRM_Type__c='Historical Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Historical Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract.Id;
        attt.ASI_CRM_Type__c='Contract Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Contract Data';
        insert attt;
        
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Cost_Type__c = 'Fixed';  
        paymentLineItem.ASI_CRM_Module__c = mod.Id;
        paymentLineItems.add(paymentLineItem);
        
        paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByName().get('ASI CRM CN Payment Request Detail (Other)').getRecordTypeId(); 
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Cost_Type__c = 'Variable';  
        paymentLineItems.add(paymentLineItem);
        
        paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByName().get('ASI CRM CN Payment Request Detail (PSF)').getRecordTypeId();
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        paymentLineItem.ASI_CRM_CN_Period_End__c= System.today().addDays(2);
        paymentLineItem.ASI_CRM_CN_Period_Start__c= System.today().addDays(-10);
        paymentLineItem.ASI_CRM_CN_Comment__c = 'This is the testing comment';
        paymentLineItem.ASI_CRM_CN_Contract_Cost__c = contractcosts[0].Id;
        paymentLineItems.add(paymentLineItem); 
        insert paymentLineItems;
        
        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(10);        
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;    
        volume.ASI_CRM_Subbrand__c = subBrand.Id;    
        volume.ASI_CRM_PR_Direct_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_STD__c = 10;
        volume.ASI_CRM_T2_Depletion_STD__c = 10;
        volume.ASI_CRM_T1_Depletion_CR12__c =10;
        volume.ASI_CRM_T2_Depletion_CR12__c= 10;
        volume.ASI_CRM_PR_Direct_CR12__c =10;
        volume.ASI_CRM_Green_Cap_STD__c=10;
        volume.ASI_CRM_Empty_Bottle_Std_Btl__c=10;
        insert volume;
        
        List<ASI_CRM_CM_GS__c> crmcmgs = new List<ASI_CRM_CM_GS__c>();
        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
           
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmgs.add(crmcmg);
        
        insert crmcmgs;
        
         List<ASI_CRM_CN_PH_Payee_Line_Item__c> PLIlst = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        ASI_CRM_CN_PH_Payee_Line_Item__c pLI = new ASI_CRM_CN_PH_Payee_Line_Item__c();
        pLI.CurrencyIsoCode='CNY';
        pLI.ASI_CRM_CN_Payment_Request__c=paymentRequest.Id;
        PLIlst.add(pLI);
        insert PLIlst;
                
        
        ASI_CRM_CN_HeavyContractUtilitiesClass hcUtl= new ASI_CRM_CN_HeavyContractUtilitiesClass();
        //Id contRecordTypeId = [Select id from RecordType where sObjectType = 'ASI_CRM_CN_Contract_BRSF_Line_Item__c' and developerName ='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' ].id;
        ASI_CRM_CN_Contract_BRSF_Line_Item__c contbrsf = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
        contbrsf.ASI_CRM_Type__c='BRSF';
        contbrsf.ASI_CRM_CN_Contract_Monthly_Qty__c = 100;
        contbrsf.ASI_CRM_CN_Contract__c =contract.Id;
        contbrsf.RecordTypeId=contRecordTypeId;
        insert contbrsf;
        Test.startTest();
 
        date dt = date.today();
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl hctrl1= new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl();
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl hctrl = new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl(new ApexPages.StandardController(paymentRequest));
        hctrl1.HeaderId= paymentRequest.Id;
        hctrl1.strPDF='0';
        hctrl1.dummyVar=True;
        hctrl1.CutOffDay= date.today()+10;
        hctrl1.AdorAbove= true;
        hctrl1.UserId=usr.Id;
        hctrl1.PayeeList=PLIlst;
        //hctrl1.init();
        hctrl1.initPage();
        hctrl1.InitVariable();
        hctrl1.NameSortingASC(5);
        hctrl1.NameSortingASC(50);
        hctrl1.NameSortingASC(500);
        hctrl1.NameSortingASC(5000);
        hctrl1.NameSortingASC(null);
        hctrl1.CalculateV0ContractDetailCost();
        hctrl1.checkFYDayPeriod(dt,dt);
        //hctrl1.DataRounding(new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd());
        hctrl1.DataRounding(new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator());

        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.MonthDiff(dt,dt);
        
        ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.interimData data = new ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.interimData([select Id,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name from ASI_CRM_Module__c limit 1],true);

        Test.stopTest();
    }

}