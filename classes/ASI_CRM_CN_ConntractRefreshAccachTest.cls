/**
 * @File Name          : ASI_CRM_CN_ConntractRefreshAccachTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 4/24/2020, 11:13:06 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/23/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
private class ASI_CRM_CN_ConntractRefreshAccachTest {
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
                            ASI_CRM_CN_Prefix__c = 'test'
                           );
        insert usr;
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
                                                                  ASI_CRM_CN_SubBrand_Group_c__c=grp.Id,
                                                                  ASI_MFM_Active_for_CRM__c = true,
                                                                  ASI_MFM_Sub_brand_Code__c = '999',
                                                                  RecordtypeId = Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'));
        
         insert subBrand1;
        
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
        contractCost.ASI_CRM_CN_Cost_Type__c= 'PSF';
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Variable Event Cost';
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
        contbrsf.ASI_CRM_CN_Contract_Monthly_Qty__c = 100;//        
        contbrsf.ASI_CRM_CN_Contract__c =contract.Id;
        contbrsf.RecordTypeId=contRecordTypeId;
        insert contbrsf;
        Test.startTest();
 
        date dt = date.today();
        ASI_CRM_CN_ConntractRefreshAccachments hctrl1= new ASI_CRM_CN_ConntractRefreshAccachments();

        List<String> countries = new List<String>();
        hctrl1.asiAtt = attt;
        hctrl1.conId = contract2.id;
        hctrl1.countries = countries;
        hctrl1.isShowOptions = true;
        hctrl1.Msg = 'TEST';
        ASI_CRM_CN_ConntractRefreshAccachments.ContractSelected = contract2;
        hctrl1.refreshStr = 'Delete';
        hctrl1.queryCon();
        ASI_CRM_CN_ConntractRefreshAccachments.refreshAtt(contract2.id, '["Historical Data","Contract Data"]');
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
        
        ASI_CRM_Sub_Brand_Grade__c  grade = new ASI_CRM_Sub_Brand_Grade__c (Name='Premium');
        insert grade;
         
        ASI_CRM_Sub_Brand_Group__c grp = new ASI_CRM_Sub_Brand_Group__c(Name='TEST');
        insert grp;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (ASI_CRM_CN_Competitor__c=false);
        insert brand;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(Name='5260.100000 PRC - Store/Outlet Support',
                                                             ASI_MFM_A_C_Code__c = '5260.100000');
        
        
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
                                                        ASI_CRM_CN_SubBrand_Group_c__c=grp.Id,
                                                        ASI_MFM_Active_for_CRM__c = true,
                                                        ASI_MFM_Sub_brand_Code__c = '999',
                                                        RecordtypeId = Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'));
        
         insert subBrand1;
        
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
                                                                     ASI_CRM_CN_Is_2nd_KPI_PO__c = true,
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',
                                                                     ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
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
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractCost.ASI_CRM_CN_Activity_Code__c = acCode.Id;
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractCost.ASI_CRM_CN_Activity_Code__c = acCode.Id;
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractCost.ASI_CRM_CN_Activity_Code__c = acCode.Id;
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractCost.ASI_CRM_CN_Activity_Code__c = acCode.Id;
        contractcosts.add(contractCost);
        
        insert contractcosts;
        
        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = contract2.Id;
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
        
        ASI_Attachment__c attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Last Payment Data';
        insert attt;
        
         
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Last Payment Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Historical Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Historical Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
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
        contbrsf.ASI_CRM_CN_Contract_Monthly_Qty__c = 100;//        
        contbrsf.ASI_CRM_CN_Contract__c =contract.Id;
        contbrsf.RecordTypeId=contRecordTypeId;
        insert contbrsf;
        Test.startTest();
 
        date dt = date.today();
        ASI_CRM_CN_ConntractRefreshAccachments hctrl1= new ASI_CRM_CN_ConntractRefreshAccachments();

        List<String> countries = new List<String>();
        hctrl1.asiAtt = attt;
        hctrl1.conId = contract2.id;
        hctrl1.countries = countries;
        hctrl1.isShowOptions = true;
        hctrl1.Msg = 'TEST';
        ASI_CRM_CN_ConntractRefreshAccachments.ContractSelected = contract2;
        hctrl1.refreshStr = 'Delete';
        hctrl1.queryCon();
        hctrl1.refreshpage();
        ASI_CRM_CN_ConntractRefreshAccachments.refreshAtt(contract2.id, '["PO Modification Data","Last Payment Data"]');
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

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(Name='5260.100000 PRC - Store/Outlet Support',
                                                             ASI_MFM_A_C_Code__c = '5260.100000');
        
        
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
                                                        ASI_CRM_CN_SubBrand_Group_c__c=grp.Id,
                                                        ASI_MFM_Active_for_CRM__c = true,
                                                        ASI_MFM_Sub_brand_Code__c = '999',
                                                        RecordtypeId = Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'));
        
         insert subBrand1;
        
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
                                                                     ASI_CRM_CN_Is_2nd_KPI_PO__c = true,
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',
                                                                     ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
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
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractCost.ASI_CRM_CN_Activity_Code__c = acCode.Id;
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractCost.ASI_CRM_CN_Activity_Code__c = acCode.Id;
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;        
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractCost.ASI_CRM_CN_Activity_Code__c = acCode.Id;
        contractcosts.add(contractCost);
        
        contractCost = new ASI_CRM_Contract_Cost__c();
        contractCost.ASI_CRM_CN_Contract__c = contract2.Id;
        contractCost.ASI_CRM_CN_Contract_Amount__c = 2;   
        contractCost.ASI_CRM_CN_Estimate_Amount__c = 2;
        contractCost.ASI_CRM_CN_Cost_Type__c= 'Fixed';
        contractCost.ASI_CRM_CN_Activity_Code__c = acCode.Id;
        contractcosts.add(contractCost);
        
        insert contractcosts;
        
        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = contract2.Id;
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
        
        ASI_Attachment__c attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Last Payment Data';
        insert attt;
        
         
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Last Payment Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Historical Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
        attt.ASI_CRM_Type__c='Historical Data';
        insert attt;
        
        attt = new ASI_Attachment__c();        
        attt.ASI_CRM_Historical_Financial_Data__c =System.JSON.serialize(obj);        
        attt.ASI_CRM_Contract__c = contract2.Id;
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
        contbrsf.ASI_CRM_CN_Contract_Monthly_Qty__c = 100;//        
        contbrsf.ASI_CRM_CN_Contract__c =contract.Id;
        contbrsf.RecordTypeId=contRecordTypeId;
        insert contbrsf;
        Test.startTest();
 
        date dt = date.today();
        ASI_CRM_CN_ConntractRefreshAccachments hctrl1= new ASI_CRM_CN_ConntractRefreshAccachments();

        List<String> countries = new List<String>();
        hctrl1.asiAtt = attt;
        hctrl1.conId = '';
        hctrl1.queryCon();
        Test.stopTest();
    }
}