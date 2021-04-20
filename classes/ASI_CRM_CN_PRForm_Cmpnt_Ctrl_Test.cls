/*B5 test class backup*/
@isTest
public class ASI_CRM_CN_PRForm_Cmpnt_Ctrl_Test {
   @TestSetup
    public static void initData() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' or Name = '系统管理员' LIMIT 1];
        User usr = new User(LastName = 'Laputa',
                            FirstName='JASON',
                            Alias = 'jLaputa',
                            Email = 'jason.laputa@laputa.com',
                            Username = 'jason.laputa@laputa.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            ASI_CRM_CN_Prefix__c = 'test'
                           );
        insert usr;
        
        Account acc = new Account(Name='TEST', RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('TH Supplier').getRecordTypeId());
        insert acc;
        Account acc1 = new Account(Name='TEST', RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Supplier (SG)').getRecordTypeId());
        insert acc1;
         
        
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c channelGroup = new ASI_CRM_CN_Channel_Group__c(Name='TEST', ASI_CRM_Channel_Group_Code__c='CN_WS Channel_1');
        insert channelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name ='channel Testing', 
                                                                  ASI_CRM_CN_On_Off__c='ON',
                                                                  recordtypeid=Schema.getGlobalDescribe().get('ASI_CRM_CN_Channel__c').getDescribe().getRecordTypeInfosByName().get('CN New Channel').getRecordTypeId(),
                                                                  ASI_CRM_For_Outlet__c=true,
                                                                  ASI_CRM_CN_Channel_Group__c=channelGroup.Id);
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
        
         list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_CN_ContractPONo_'+usr.ASI_CRM_CN_Prefix__c,ASI_HK_CRM_Running_Number__c = 100.50,ASI_HK_CRM_Format__c  = 'test',ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 01, ASI_HK_CRM_Fiscal_Year__c = Date.today().year()));
        insert rns;
        
         ASI_CRM_AccountsAdditionalField__c AccountsAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
         AccountsAdditionalField.ASI_CRM_CN_Commercial_Team__c = 'Premium';
         AccountsAdditionalField.RecordTypeId= Schema.getGlobalDescribe().get('ASI_CRM_AccountsAdditionalField__c').getDescribe().getRecordTypeInfosByName().get('Outlet (CN)').getRecordTypeId();
         //AccountsAdditionalField.RecordTypeId=Schema.getGlobalDescribe().get('ASI_CRM_AccountsAdditionalField__c').getDescribe().getRecordTypeInfosByName().get('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS').getRecordTypeId();
         AccountsAdditionalField.Name='TEST';
         AccountsAdditionalField.ASI_CRM_CN_Image__c='Iconic';
         AccountsAdditionalField.ASI_CRM_CN_CCity__c=city.Id;
         AccountsAdditionalField.ASI_CRM_CN_Sub_Channel__c=subChannel.Id;
         AccountsAdditionalField.ASI_CRM_CN_NewChannel__c=channel.Id;
         AccountsAdditionalField.ASI_CRM_CN_JDE_Code__c = 'asd';       
         insert AccountsAdditionalField; 
         
        Date enddate = Date.newInstance(2018, 12, 31);
        Date startdate = Date.newInstance(2018, 12, 01);
        ASI_TH_CRM_Contract__c contract2 = new ASI_TH_CRM_Contract__c();
        contract2.ASI_CRM_CN_PO_End_Date__c = enddate;//System.today().addDays(-1);
        contract2.ASI_CRM_CN_PO_Start_Date__c = startdate;//System.today().addMonths(-2);   
        contract2.ASI_TH_CRM_Promotion_Type__c = 'Heavy Contract On';
        contract2.ASI_CRM_CN_PO_Version__c = '0.0';
        contract2.ASI_CRM_CN_Currency__c = 'USD';
        contract2.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;
        contract2.ASI_TH_CRM_Outlet__c = acc.Id;
        contract2.ASI_CRM_CN_Status__c = 'Draft';
        //contract2.ASI_TH_CRM_Nxt_Mth_Amortization_Amount__c = 50;
        insert contract2;
        
        ASI_CRM_Province__c province = new ASI_CRM_Province__c();
        province.Name= 'Province Testing';
        insert province;
        
        
        
       /* Date enddate1 = Date.newInstance(2019, 12, 31);
        Date startdate1 = Date.newInstance(2019, 12, 01);*/
        
        Date startdate1 = Date.today().addMonths(-2);
        Date enddate1 = startdate1.addDays(5);
        
        
        
        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
        contract.ASI_CRM_CN_PO_End_Date__c = enddate1;//System.today().addDays(10);
        contract.ASI_CRM_CN_PO_Start_Date__c = startdate1;//System.today().addMonths(-3);   
        contract.ASI_TH_CRM_Promotion_Type__c = 'Heavy Contract On';
        contract.ASI_CRM_CN_PO_Version__c = '0.0';
        contract.ASI_CRM_CN_Currency__c = 'USD';
        contract.ASI_CRM_CN_V0_0_PO_version__c = contract2.Id;
        contract.ASI_CRM_CN_PO_No__c = 'TST-100';
        contract.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;
        contract.ASI_CRM_Investment_Type__c = 'Heavy';
        contract.ASI_CRM_PO_Province__c = province.Id;
        contract.ASI_CRM_PO_Channel__c = channel.Id;
        contract.ASI_CRM_PO_City__c = city.Id;
        contract.ASI_TH_CRM_Outlet__c = acc.Id;
        contract.ASI_TH_CRM_Total_Fund_Advance__c  = 200;
        contract.ASI_CRM_Volume_Option__c= 'Normal';
        contract.recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract'); 
        /*//contract.ASI_CRM_Contract_Amortized_Amount__c = 100;
        //contract.ASI_CRM_Contract_Remaining_Balance_Amt__c = 100;
        contract.ASI_TH_CRM_Start_Date__c = System.today().addMonths(-1);
        contract.ASI_TH_CRM_End_Date__c  = contract.ASI_TH_CRM_Start_Date__c.addMonths(1);
       // contract.ASI_CRM_Contract_Remaining_Month__c = 50;*/
       
        //contract.ASI_TH_CRM_Nxt_Mth_Amortization_Amount__c = 200; // commented on 12-8-2019
        insert contract;
        
        /*ASI_TH_CRM_Contract_Amort_History__c schedule = new ASI_TH_CRM_Contract_Amort_History__c();
        schedule.ASI_TH_CRM_Contract__c = contract.Id;
        schedule.ASI_TH_CRM_ETL_Sync_Flag__c = true;
        schedule.ASI_TH_CRM_Amortization_Amount__c = 100;*/
        
        
        
        
        ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLineItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
        BRSFLineItem.ASI_CRM_CN_Contract__c=contract.Id;
        BRSFLineItem.ASI_CRM_CN_Est_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Contract_Monthly_Qty__c=1;
        BRSFLineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10;
        BRSFLineItem.ASI_CRM_CN_Sub_Brand__c=subBrand.Id;
        BRSFLineItem.recordtypeid = Schema.getGlobalDescribe().get('ASI_CRM_CN_Contract_BRSF_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('CRM CN Contract BRSF Line Item').getRecordTypeId();
            
            //Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item');
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
        
        Date enddate2 = Date.newInstance(2019, 12, 31);
        Date startdate2 = Date.newInstance(2019, 12, 01);
        
        contract.ASI_TH_CRM_Total_Fund_Advance__c  = 0;
        contract.ASI_TH_CRM_Contract_Status__c = 'Final';
        update contract;
        
ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request');
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
        paymentRequest.ASI_TH_CRM_Vendor__c = acc.Id;
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = AccountsAdditionalField.Id;
        insert paymentRequest;
       
         Date enddate4 = Date.newInstance(2019, 12, 15);
        Date startdate4 = Date.newInstance(2019, 12, 05);
        
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
        paymentLineItem.ASI_CRM_CN_Period_End__c= enddate1;//System.today().addDays(2);
        paymentLineItem.ASI_CRM_CN_Period_Start__c=startdate1;// System.today().addDays(-10);
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
        paymentLineItem.ASI_CRM_CN_Period_End__c= enddate1;//System.today().addDays(2);
        paymentLineItem.ASI_CRM_CN_Period_Start__c=startdate1;// System.today().addDays(-10);
        paymentLineItems.add(paymentLineItem);
        
      //   Date enddate4 = Date.newInstance(2019, 12, 15);
      //  Date startdate4 = Date.newInstance(2019, 12, 05);
        
        paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
        paymentLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequest.Id;
        paymentLineItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByName().get('ASI CRM CN Payment Request Detail (PSF)').getRecordTypeId();
        paymentLineItem.ASI_CRM_CN_Incentive_BT__c = 1;
        paymentLineItem.ASI_CRM_CN_Target_BT__c=1;
        paymentLineItem.ASI_CRM_CN_Actual_Vol__c = 1;
        paymentLineItem.ASI_CRM_CN_Total_Payable__c = 1;
        paymentLineItem.ASI_CRM_CN_Bottle_Collected__c = 1;
        paymentLineItem.ASI_TH_CRM_Amount__c = 100;
        //paymentLineItem.ASI_CRM_CN_Period_End__c= enddate4;//System.today().addDays(2);
        //paymentLineItem.ASI_CRM_CN_Period_Start__c=startdate4;// System.today().addDays(-10);
        
        paymentLineItem.ASI_CRM_CN_Period_End__c= enddate1;//System.today().addDays(2);
        paymentLineItem.ASI_CRM_CN_Period_Start__c=startdate1;// System.today().addDays(-10);
        
        
        paymentLineItem.ASI_CRM_CN_Comment__c = 'This is the testing comment';
        paymentLineItem.ASI_CRM_CN_Contract_Cost__c = contractcosts[0].Id;
        paymentLineItems.add(paymentLineItem); 
        insert paymentLineItems;
        
        ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        volume.ASI_CRM_Account__c = AccountsAdditionalField.Id;
        volume.ASI_CRM_End_Date__c = contract.ASI_CRM_CN_PO_Start_Date__c.addDays(2);        
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
        volume.ASI_CRM_Account__c =   AccountsAdditionalField.Id;
        volume.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;         
        insert volume;
        
        List<ASI_CRM_CM_GS__c> crmcmgs = new List<ASI_CRM_CM_GS__c>();
        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract2.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_VERSION__c = 3.14;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'Budget GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract2.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmg.ASI_CRM_VERSION__c = 2.14;
        crmcmgs.add(crmcmg);
           
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD CM';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmg.ASI_CRM_VERSION__c = 1.14;
        crmcmgs.add(crmcmg);
        
        crmcmg = new ASI_CRM_CM_GS__c();
        crmcmg.ASI_CRM_CN_Month__c = 6;
        crmcmg.ASI_CRM_Region__c = region.Id;
        crmcmg.ASI_CRM_TYPE__c = 'YTD GS';
        crmcmg.ASI_CRM_CM_GS_per_9L__c = 2;
        crmcmg.ASI_CRM_YEAR__c = String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c.Year());
        crmcmg.ASI_CRM_CN_Month__c  = contract.ASI_CRM_CN_PO_End_Date__c.addMonths(-4).Month();
        crmcmg.ASI_CRM_PRODUCTCODE__c = volume.ASI_CRM_Subbrand__c;
        crmcmg.ASI_CRM_VERSION__c = 0.14;
        crmcmgs.add(crmcmg);
        
        insert crmcmgs;
        
        
    } 
    
    static testMethod void ASI_CRM_CN_PRForm_Cmpnt_Ctrl_TEST() {
        test.startTest();
        User usr = [select Id,LastName ,FirstName,Alias,Email,Username,ProfileId,TimeZoneSidKey,LanguageLocaleKey,EmailEncodingKey,LocaleSidKey,ASI_CRM_CN_Prefix__c from User where Email = 'jason.laputa@laputa.com'];
        
        String userId= usr.Id;
        system.runAs(usr) {     
            
           
            
            Group grp = [select Name,Id,DeveloperName from group where DeveloperName='ASI_CRM_CN_AD_or_Above' limit 1];
            GroupMember gr = new GroupMember();
            gr.UserOrGroupId = usr.Id;
            gr.GroupId = grp.Id;
            insert gr;
            
            List<integer> lstRemove = new List<integer>();
            //
            ASI_CRM_CN_PRForm_Cmpnt_Ctrl ctrlTmp = new ASI_CRM_CN_PRForm_Cmpnt_Ctrl();
            ctrlTmp.UserId = userId;
            system.debug('225--->'+[select Id,ASI_CRM_CN_Month_End_Date__c from ASI_CRM_CM_GS__c where ASI_CRM_TYPE__c IN('YTD CM')]);
            List<ASI_CRM_CM_GS__c> crmcmgs = new List<ASI_CRM_CM_GS__c>();
            for(ASI_CRM_CM_GS__c crmcmg  : [select Id,ASI_CRM_YEAR__c from ASI_CRM_CM_GS__c where ASI_CRM_TYPE__c  IN('Budget CM','Budget GS')]) {
              crmcmg.ASI_CRM_YEAR__c = String.valueOf(ctrlTmp.FYConversion(date.Today()).Year());
              crmcmgs.add(crmcmg);
            }
            update crmcmgs;
                                            
            ASI_TH_CRM_PaymentRequest__c paymentRequest = [select Id,ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c,
                                                           ASI_TH_CRM_Total_Amount__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PSF_Start__c,
                                                           ASI_TH_CRM_Contract__r.ASI_CRM_CN_Contract_Cost_Total__c,ASI_CRM_CN_PSF_End__c,
                                                           ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_Remain_Amount__c,
                                                           ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Total_PSF_Amount__c,
                                                           ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_PO_Province__r.Name from ASI_TH_CRM_PaymentRequest__c];
            system.debug('paymentRequest-->'+paymentRequest);
            ApexPages.currentPage().getParameters().put('id', paymentRequest.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(paymentRequest);
            ASI_CRM_CN_PRForm_Cmpnt_Ctrl ctrl = new ASI_CRM_CN_PRForm_Cmpnt_Ctrl(sc);
            ctrl.dummyVar = false;  
            ctrl.strPDF = '1';
            
            ctrlTmp.totalOffTakeVSInTake = 100.00; 

            
        }
    }
    
    static testMethod void ASI_CRM_CN_PRForm_Cmpnt_Ctrl_TEST_2() {
        string strkey;
        string subbrand_id;
        test.startTest();
        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        User usr = [select Id,LastName ,FirstName,Alias,Email,Username,ProfileId,TimeZoneSidKey,LanguageLocaleKey,EmailEncodingKey,LocaleSidKey,ASI_CRM_CN_Prefix__c from User where Email = 'jason.laputa@laputa.com'];
        system.runAs(usr) {   
            
            ASI_TH_CRM_PaymentRequest__c paymentRequest = [select Id,ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c,
                                                           ASI_TH_CRM_Total_Amount__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PSF_Start__c,
                                                           ASI_TH_CRM_Contract__r.ASI_CRM_CN_Contract_Cost_Total__c,ASI_CRM_CN_PSF_End__c,
                                                           ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_Remain_Amount__c,
                                                           ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Total_PSF_Amount__c,
                                                           ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_PO_Province__r.Name from ASI_TH_CRM_PaymentRequest__c];
            ApexPages.currentPage().getParameters().put('id', paymentRequest.Id);
            ApexPages.currentPage().getParameters().put('isTest', '1');
            ApexPages.currentPage().getParameters().put('cutoff', '20190715'); 
            ApexPages.StandardController sc = new ApexPages.StandardController(paymentRequest);
            ASI_CRM_CN_PRForm_Cmpnt_Ctrl ctrl = new ASI_CRM_CN_PRForm_Cmpnt_Ctrl(sc);
            ctrl.dummyVar = false;  
            ctrl.strPDF = '1';
            
            Group grp1 = new Group();
            grp1.Name = 'testgrp';
            insert grp1;
            
            GroupMember grpmember = new GroupMember();
      grpmember.GroupId =grp1.Id;
             grpmember.UserOrGroupId = UserInfo.getUserId();
            insert grpmember;
              
            //ASI_CRM_CN_PRForm_Cmpnt_Ctrl ctrl = new ASI_CRM_CN_PRForm_Cmpnt_Ctrl();
            //ctrl.initclass();
            ctrl.MonthDiff(null,null);
            ctrl.checkFY(null,null);
            ctrl.checkFYDayPeriod(null,null);
            Date startDate = System.today();   
            ctrl.strPDF = '1';
            ctrl.InitVariable();
            ctrl.strPDF = '0';
            ctrl.InitVariable();
            ctrl.checkFYDayPeriod(Date.newInstance(startDate.Year(),7,1),Date.newInstance(startDate.Year(),8,1));
            ctrl.checkFYDayPeriod(Date.newInstance(startDate.Year(),6,1),Date.newInstance(startDate.Year(),8,1));
            ctrl.checkFYDayPeriod(Date.newInstance(startDate.Year(),4,1),Date.newInstance(startDate.Year(),5,1));
            ctrl.FindMinMaxDate(startDate,startDate.addDays(-1),'MIN');
            ctrl.FindMinMaxDate(startDate,startDate.addDays(-1),'MAX');
            ctrl.FindMinMaxDate(startDate,startDate.addDays(1),'MAX');
            ctrl.checkFY(Date.newInstance(startDate.Year(),7,1),Date.newInstance(startDate.Year()+1,8,1));
            ctrl.checkFY(Date.newInstance(startDate.Year(),5,1),Date.newInstance(startDate.Year()+1,6,1));
            ctrl.CutOffDate(System.today().addDays(-1).day());
            ctrl.CutOffDate(System.today().addDays(2).day());
            ctrl.CutOffDate(0); 
            ctrl.checkUserID();
            ctrl.checkApprover();
        }
    }
    
    /*static testMethod void ASI_CRM_CN_PRForm_Cmpnt_CtrlEmail_TEST3() {
        test.startTest();
        User usr = [select Id,LastName ,FirstName,Alias,Email,Username,ProfileId,TimeZoneSidKey,LanguageLocaleKey,EmailEncodingKey,LocaleSidKey,ASI_CRM_CN_Prefix__c from User where Email = 'jason.laputa@laputa.com'];
        
        String userId= usr.Id;
        system.runAs(usr) {     
            
           
            
            Group grp = [select Name,Id,DeveloperName from group where DeveloperName='ASI_CRM_CN_AD_or_Above' limit 1];
            GroupMember gr = new GroupMember();
            gr.UserOrGroupId = usr.Id;
            gr.GroupId = grp.Id;
            insert gr;
            
            List<integer> lstRemove = new List<integer>();
            //
            ASI_CRM_CN_PRForm_Cmpnt_CtrlEmail ctrlTmp = new ASI_CRM_CN_PRForm_Cmpnt_CtrlEmail();
            ctrlTmp.UserId = userId;
            system.debug('225--->'+[select Id,ASI_CRM_CN_Month_End_Date__c from ASI_CRM_CM_GS__c where ASI_CRM_TYPE__c IN('YTD CM')]);
            List<ASI_CRM_CM_GS__c> crmcmgs = new List<ASI_CRM_CM_GS__c>();
            for(ASI_CRM_CM_GS__c crmcmg  : [select Id,ASI_CRM_YEAR__c from ASI_CRM_CM_GS__c where ASI_CRM_TYPE__c  IN('Budget CM','Budget GS')]) {
              crmcmg.ASI_CRM_YEAR__c = String.valueOf(ctrlTmp.FYConversion(date.Today()).Year());
              crmcmgs.add(crmcmg);
            }
            update crmcmgs;
                                            
            ASI_TH_CRM_PaymentRequest__c paymentRequest = [select Id,ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c,
                                                           ASI_TH_CRM_Total_Amount__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PSF_Start__c,
                                                           ASI_TH_CRM_Contract__r.ASI_CRM_CN_Contract_Cost_Total__c,ASI_CRM_CN_PSF_End__c,
                                                           ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_Remain_Amount__c,
                                                           ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Total_PSF_Amount__c,
                                                           ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_PO_Province__r.Name from ASI_TH_CRM_PaymentRequest__c];
            system.debug('paymentRequest-->'+paymentRequest);
            ApexPages.currentPage().getParameters().put('related_to_id', paymentRequest.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(paymentRequest);
            ASI_CRM_CN_PRForm_Cmpnt_CtrlEmail ctrl = new ASI_CRM_CN_PRForm_Cmpnt_CtrlEmail(sc);
            ctrl.dummyVar = false;  
            ctrl.strPDF = '1';
            
            ctrlTmp.totalOffTakeVSInTake = 100.00; 

            
        }
    }
    
    static testMethod void ASI_CRM_CN_PRForm_Cmpnt_CtrlEmail_TEST_4() {
        string strkey;
        string subbrand_id;
        test.startTest();
        ASI_CRM_CM_GS__c crmcmg = new ASI_CRM_CM_GS__c();
        User usr = [select Id,LastName ,FirstName,Alias,Email,Username,ProfileId,TimeZoneSidKey,LanguageLocaleKey,EmailEncodingKey,LocaleSidKey,ASI_CRM_CN_Prefix__c from User where Email = 'jason.laputa@laputa.com'];
        system.runAs(usr) {   
            
            ASI_TH_CRM_PaymentRequest__c paymentRequest = [select Id,ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c,
                                                           ASI_TH_CRM_Total_Amount__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PSF_Start__c,
                                                           ASI_TH_CRM_Contract__r.ASI_CRM_CN_Contract_Cost_Total__c,ASI_CRM_CN_PSF_End__c,
                                                           ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_Remain_Amount__c,
                                                           ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Total_PSF_Amount__c,
                                                           ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_PO_Province__r.Name from ASI_TH_CRM_PaymentRequest__c];
            ApexPages.currentPage().getParameters().put('related_to_id', paymentRequest.Id);
            ApexPages.currentPage().getParameters().put('isTest', '1');
            ApexPages.currentPage().getParameters().put('cutoff', '20190715'); 
            ApexPages.StandardController sc = new ApexPages.StandardController(paymentRequest);
            ASI_CRM_CN_PRForm_Cmpnt_CtrlEmail ctrl = new ASI_CRM_CN_PRForm_Cmpnt_CtrlEmail(sc);
            ctrl.dummyVar = false;  
            ctrl.strPDF = '1';
            
            Group grp1 = new Group();
            grp1.Name = 'testgrp';
            insert grp1;
            
            GroupMember grpmember = new GroupMember();
      grpmember.GroupId =grp1.Id;
             grpmember.UserOrGroupId = UserInfo.getUserId();
            insert grpmember;
              
            //ASI_CRM_CN_PRForm_Cmpnt_Ctrl ctrl = new ASI_CRM_CN_PRForm_Cmpnt_Ctrl();
            //ctrl.initclass();
            ctrl.MonthDiff(null,null);
            ctrl.checkFY(null,null);
            ctrl.checkFYDayPeriod(null,null);
            Date startDate = System.today();   
            ctrl.strPDF = '1';
            ctrl.InitVariable();
            ctrl.strPDF = '0';
            ctrl.InitVariable();
            ctrl.checkFYDayPeriod(Date.newInstance(startDate.Year(),7,1),Date.newInstance(startDate.Year(),8,1));
            ctrl.checkFYDayPeriod(Date.newInstance(startDate.Year(),6,1),Date.newInstance(startDate.Year(),8,1));
            ctrl.checkFYDayPeriod(Date.newInstance(startDate.Year(),4,1),Date.newInstance(startDate.Year(),5,1));
            ctrl.FindMinMaxDate(startDate,startDate.addDays(-1),'MIN');
            ctrl.FindMinMaxDate(startDate,startDate.addDays(-1),'MAX');
            ctrl.FindMinMaxDate(startDate,startDate.addDays(1),'MAX');
            ctrl.checkFY(Date.newInstance(startDate.Year(),7,1),Date.newInstance(startDate.Year()+1,8,1));
            ctrl.checkFY(Date.newInstance(startDate.Year(),5,1),Date.newInstance(startDate.Year()+1,6,1));
            ctrl.CutOffDate(System.today().addDays(-1).day());
            ctrl.CutOffDate(System.today().addDays(2).day());
            ctrl.CutOffDate(0); 
            ctrl.checkUserID();
            ctrl.checkApprover();
        }
    }*/
     
    
    
     
}