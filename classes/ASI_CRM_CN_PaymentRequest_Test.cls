@isTest (SeeAllData=false)
public class ASI_CRM_CN_PaymentRequest_Test {

    static testMethod void ASI_CRM_CN_PaymentRequestUtilCls_TEST() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //ASI_CRM_Subbrand_Volume__c
             
        ASI_TH_CRM_Contract__c ctLast = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',                                                       
            ASI_CRM_CN_Status__c = 'Archived'
            );
        insert ctLast;
        
        ASI_CRM_Contract_Cost_Setting__c ContractCostSetting = 
            new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_BRSF_Activity_Code_Default__c = true,
            ASI_CRM_CN_Promotion_Type__c = 'New Contract ON');
        insert ContractCostSetting;
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_Last_PO_version__c = ctLast.id,
            ASI_CRM_CN_V0_0_PO_version__c = ctLast.id
            
            );
        insert ct;
        
        List<ASI_CRM_Contract_Cost__c> LContractCost = new List<ASI_CRM_Contract_Cost__c>();
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,name='Promotion Service Fee',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,name='Promotion Service Fee',
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,name='Trading Term Incentives',
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        insert LContractCost;
        
        /*List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        LBRSF.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = ct.id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')));
        LBRSF.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = ctLast.id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')));
        insert LBRSF;*/
ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
       // Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
     /*   a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));*/
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
     /*   a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];*/
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST4',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
        /*    subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));*/
        }
        insert subBrands;
list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                if(subBrand.name !='TEST3'){
                svs.add(new ASI_CRM_Subbrand_Volume__c(
                    ASI_CRM_Account__c=a2s[0].Id,
                    ASI_CRM_Subbrand__c=subBrand.Id,
                    ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                    ASI_CRM_T1_Depletion_STD_Billing__c=1,
                    ASI_CRM_T2_Depletion_STD_Billing__c=1,
                    ASI_CRM_PR_Direct_STD_Billing__c=1,
                    ASI_CRM_T1_Depletion_CR12__c=1,
                    ASI_CRM_T2_Depletion_CR12__c=1,
                    ASI_CRM_PR_Direct_CR12__c=1,
                    ASI_CRM_Empty_Bottle__c=1,
                    ASI_CRM_Green_Cap_Std_Billing__c=1,
                    ASI_CRM_Empty_Bottle_CR12__c=1,
                    ASI_CRM_Green_Cap_CR12__c=1));
            

            svs.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c=a2s[0].Id,
                ASI_CRM_Subbrand__c=null,
                ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                ASI_CRM_T1_Depletion_STD_Billing__c=1,
                ASI_CRM_T2_Depletion_STD_Billing__c=1,
                ASI_CRM_PR_Direct_STD_Billing__c=1,
                ASI_CRM_T1_Depletion_CR12__c=1,
                ASI_CRM_T2_Depletion_CR12__c=1,
                ASI_CRM_PR_Direct_CR12__c=1,
                ASI_CRM_Empty_Bottle__c=1,
                ASI_CRM_Green_Cap_Std_Billing__c=1,
                ASI_CRM_Empty_Bottle_CR12__c=1,
                ASI_CRM_Green_Cap_CR12__c=1));
                }
            }
        }
        insert svs;
list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
     //   list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            if(subBrand.name =='TEST1' || subBrand.name =='TEST3'){
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ctLast.id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
            if(subBrand.name =='TEST4'){
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ctLast.id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        }
        /*ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
        )*/
           // );
        
     /*   cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));*/
        
        insert ctis;
        test.startTest();
        list<ASI_TH_CRM_PaymentRequest__c> prsInsert = new list<ASI_TH_CRM_PaymentRequest__c>();
        prsInsert.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_New_FY_Payment__c=True, ASI_TH_CRM_Status__c='Draft',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_Is_Dolphin_Auto_Payment__c = true,
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        prsInsert.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_New_FY_Payment__c=True, ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_Is_Dolphin_Auto_Payment__c = true,
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prsInsert;
        Set<id> SPRID = new Set<id>();
        for(ASI_TH_CRM_PaymentRequest__c pr : prsInsert){
            SPRID.add(pr.id);
        }
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs = [Select id, ASI_TH_CRM_Contract__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_BRSF_Start_Date__c,
            ASI_CRM_CN_BRSF_End_Date__c, ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,
            ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Bottle_Collection_Rate__c, 
            ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,ASI_CRM_CN_No_of_Month__c,
               ASI_CRM_New_FY_Payment__c
            from ASI_TH_CRM_PaymentRequest__c where id IN :SPRID];
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,ASI_CRM_CN_Incentive_BT__c = 1,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,ASI_CRM_CN_Incentive_BT__c = 1,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,ASI_CRM_CN_Incentive_BT__c = 1,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
        }
        insert LPayee;
        
        
        
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        ASI_CRM_Contract_Cost_Setting__c costSetting = new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_BRSF_Activity_Code_Default__c = true,ASI_CRM_CN_Promotion_Type__c='New Contract ON');    
        insert costSetting;
        
            ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(prs[0],null);
            ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(null,ct);
            ASI_CRM_CN_PaymentRequestUtilCls.genBRSF(prs[0],system.today().addDays(-2),system.today().addDays(-1));
            ASI_CRM_CN_PaymentRequestUtilCls.paymentSummary tmpPS = new ASI_CRM_CN_PaymentRequestUtilCls.paymentSummary('','',null,null,null);
        
        //20160920 Ben @ Elufa
        tmpPS.addremainAmt(0);
        tmpPS.addCNYEst(0);
        tmpPS.addMAFEst(0);
        tmpPS.addOthersEst(0);
        tmpPS.addLastCNYEst(0);
        tmpPS.addLastMAFEst(0);
        tmpPS.addLastOthersEst(0);
        tmpPS.addCNYRequest(0);
        tmpPS.addMAFRequest(0);
        tmpPS.addOthersRequest(0);
        tmpPS.addCNYRemaining(0);
        tmpPS.addMAFRemaining(0);
        tmpPS.addOthersRemaining(0);
        tmpPS.addCNYPaid(0);
        tmpPS.addMAFPaid(0);
        tmpPS.addOthersPaid(0);
        
            update Lpayee;
        test.stopTest();
    }

static testMethod void ASI_CRM_CN_PaymentRequestUtilCls_TEST2() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //ASI_CRM_Subbrand_Volume__c
             
        ASI_TH_CRM_Contract__c ctLast = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Promotion_Type__c = 'New Contract OFF',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',                                                       
            ASI_CRM_CN_Status__c = 'Archived'
            );
        insert ctLast;
        
        ASI_CRM_Contract_Cost_Setting__c ContractCostSetting = 
            new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_BRSF_Activity_Code_Default__c = true,
            ASI_CRM_CN_Promotion_Type__c = 'New Contract OFF');
        insert ContractCostSetting;
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Promotion_Type__c = 'New Contract OFF',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_Last_PO_version__c = ctLast.id,
            ASI_CRM_CN_V0_0_PO_version__c = ctLast.id
            
            );
        insert ct;
        
        List<ASI_CRM_Contract_Cost__c> LContractCost = new List<ASI_CRM_Contract_Cost__c>();
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,name='Promotion Service Fee',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,name='Promotion Service Fee',
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,name='Trading Term Incentives',
            ASI_CRM_CN_Chinese_Description__c = '合同奖励',
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        insert LContractCost;
        
        /*List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        LBRSF.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = ct.id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')));
        LBRSF.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = ctLast.id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')));
        insert LBRSF;*/
ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
       // Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
     /*   a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));*/
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
     /*   a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];*/
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST4',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
        /*    subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));*/
        }
        insert subBrands;
list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                if(subBrand.name !='TEST3'){
                svs.add(new ASI_CRM_Subbrand_Volume__c(
                    ASI_CRM_Account__c=a2s[0].Id,
                    ASI_CRM_Subbrand__c=subBrand.Id,
                    ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                    ASI_CRM_T1_Depletion_STD_Billing__c=1,
                    ASI_CRM_T2_Depletion_STD_Billing__c=1,
                    ASI_CRM_PR_Direct_STD_Billing__c=1,
                    ASI_CRM_T1_Depletion_CR12__c=1,
                    ASI_CRM_T2_Depletion_CR12__c=1,
                    ASI_CRM_PR_Direct_CR12__c=1,
                    ASI_CRM_Empty_Bottle__c=1,
                    ASI_CRM_Green_Cap_Std_Billing__c=1,
                    ASI_CRM_Empty_Bottle_CR12__c=1,
                    ASI_CRM_Green_Cap_CR12__c=1));
            

            svs.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c=a2s[0].Id,
                ASI_CRM_Subbrand__c=null,
                ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                ASI_CRM_T1_Depletion_STD_Billing__c=1,
                ASI_CRM_T2_Depletion_STD_Billing__c=1,
                ASI_CRM_PR_Direct_STD_Billing__c=1,
                ASI_CRM_T1_Depletion_CR12__c=1,
                ASI_CRM_T2_Depletion_CR12__c=1,
                ASI_CRM_PR_Direct_CR12__c=1,
                ASI_CRM_Empty_Bottle__c=1,
                ASI_CRM_Green_Cap_Std_Billing__c=1,
                ASI_CRM_Empty_Bottle_CR12__c=1,
                ASI_CRM_Green_Cap_CR12__c=1));
                }
            }
        }
        insert svs;
list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
     //   list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            if(subBrand.name =='TEST1' || subBrand.name =='TEST3'){
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ctLast.id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
            if(subBrand.name =='TEST4'){
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ctLast.id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        }
        /*ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
        )*/
           // );
        
     /*   cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));*/
        
        insert ctis;
        test.startTest();
        list<ASI_TH_CRM_PaymentRequest__c> prsInsert = new list<ASI_TH_CRM_PaymentRequest__c>();
        prsInsert.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_New_FY_Payment__c=True, ASI_TH_CRM_Status__c='Draft',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        prsInsert.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_New_FY_Payment__c=True, ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prsInsert;
        Set<id> SPRID = new Set<id>();
        for(ASI_TH_CRM_PaymentRequest__c pr : prsInsert){
            SPRID.add(pr.id);
        }
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs = [Select id, ASI_TH_CRM_Contract__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_BRSF_Start_Date__c,
            ASI_CRM_CN_BRSF_End_Date__c, ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,
            ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Bottle_Collection_Rate__c, 
            ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,ASI_CRM_CN_No_of_Month__c,
               ASI_CRM_New_FY_Payment__c
            from ASI_TH_CRM_PaymentRequest__c where id IN :SPRID];
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,ASI_CRM_CN_Incentive_BT__c = 1,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,ASI_CRM_CN_Incentive_BT__c = 1,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,ASI_CRM_CN_Incentive_BT__c = 1,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
        }
        insert LPayee;
        
        
        
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        ASI_CRM_Contract_Cost_Setting__c costSetting = new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_BRSF_Activity_Code_Default__c = true,ASI_CRM_CN_Promotion_Type__c='New Contract ON');    
        insert costSetting;
        
            ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(prs[0],null);
            ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(null,ct);
            ASI_CRM_CN_PaymentRequestUtilCls.genBRSF(prs[0],system.today().addDays(-2),system.today().addDays(-1));
            ASI_CRM_CN_PaymentRequestUtilCls.paymentSummary tmpPS = new ASI_CRM_CN_PaymentRequestUtilCls.paymentSummary('','',null,null,null);
        
        //20160920 Ben @ Elufa
        tmpPS.addremainAmt(0);
        tmpPS.addCNYEst(0);
        tmpPS.addMAFEst(0);
        tmpPS.addOthersEst(0);
        tmpPS.addLastCNYEst(0);
        tmpPS.addLastMAFEst(0);
        tmpPS.addLastOthersEst(0);
        tmpPS.addCNYRequest(0);
        tmpPS.addMAFRequest(0);
        tmpPS.addOthersRequest(0);
        tmpPS.addCNYRemaining(0);
        tmpPS.addMAFRemaining(0);
        tmpPS.addOthersRemaining(0);
        tmpPS.addCNYPaid(0);
        tmpPS.addMAFPaid(0);
        tmpPS.addOthersPaid(0);
        
            update Lpayee;
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_NewChannel__c= channel.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        Id RunningNumberRecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number');
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = RunningNumberRecordTypeId));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = RunningNumberRecordTypeId));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = RunningNumberRecordTypeId));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = RunningNumberRecordTypeId));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = RunningNumberRecordTypeId));
        }
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        Id BRSFLineItemRecordTypeId = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item');
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = BRSFLineItemRecordTypeId
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = BRSFLineItemRecordTypeId
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        Id paymentRequestRecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_Payment_Type__c = 'Cash',
            ASI_CRM_CN_Adjustment__c=80,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
            ASI_TH_CRM_Status__c='Submitted',
            ASI_CRM_CN_Return_Comments__c='a', recordTypeId = paymentRequestRecordTypeId));

        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = paymentRequestRecordTypeId));
        insert prs;
        
        Id rtPRI_BRSF = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        Id rtPRI_Detail = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other');
        Id rtPRI_PSF = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI_BRSF,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI_Detail,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI_PSF,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        Id payeeLineItemRecordTypeId = Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee');
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =payeeLineItemRecordTypeId,ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =payeeLineItemRecordTypeId,ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =payeeLineItemRecordTypeId,ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
            
        
        System.debug(Limits.getDMLRows());
            // ApexPages.CurrentPage().getparameters().put('contractid', ct.id);
            // ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_PaymentRequest__c());
            // ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            // con.refresh();
            // con.updateRecord();
            // con.BRSFReport();
            
        test.startTest();
        
            // ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
            // sc = new ApexPages.standardController(prs[0]);
            // con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            // con.GoReturn();
            // con.CancelBRSFChange();
            // con.cancel();
            // con.digit_formatting(3,19999999);
            // con.digit_formatting(3,1);
            // con.saveDate();
            // con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addDays(10);
            // con.ph.ASI_CRM_CN_BRSF_End_Date__c  = date.today().addDays(10);
            // con.saveDate();
            // con.PSFReport();
            // con.BRSFReport();
            // con.doCancel();
            // con.GoURL();
            // con.GoEditHeader();
            // con.GoEditDetail();
            // con.GoEditPayee();
            
            // con.updatePOVersion();
            // con.updateRecord();
            // con.regenerateBRSFVol();
            // con.updatePayeeRecord();
            // con.submitApproval();
            // con.refresh();
            // con.updateDetailRecord();
            
            // con.addNew_Cash();
            // con.addNew_Discount();
            // con.addNew_CD(); 
            // con.updatePayeeRecord();
            
            // con.addNew_Cash();
            // con.rowidCASH = con.Payee_Item_Map_CASH.size()-1;
            // con.clone_Cash();
            // for(integer i : con.Payee_Item_Map_CASH.keyset()){
            //     con.rowidCASH = i;
            //     con.RemoveRow_Cash();
            // }
            
            // con.addNew_Discount();
            // con.rowidDiscount = con.Payee_Item_Map_Discount.size()-1;
            // con.clone_Discount();
            // for(integer i : con.Payee_Item_Map_Discount.keyset()){
            //     con.rowidDiscount = i;
            //     con.RemoveRow_Discount();
            // }
            
            // con.addNew_CD();            
            // con.rowidCD = con.Payee_Item_Map_CD.size()-1;
            // con.clone_CD();
            // for(integer i : con.Payee_Item_Map_CD.keyset()){
            //     con.rowidCD = i;
            //     con.RemoveRow_CD();
            // }
            // con.updatePayeeRecord();
            
            
            // con.addNew_PSF();
            // con.updatePSF();
            // con.rowidPSF = con.PSF_Item_Map.size()-1;
            // con.clone_PSF();
            // for(integer i : con.PSF_Item_Map.keyset()){
            //     con.rowidPSF = i;
            //     con.removeRow_PSF();
            // }            
            // con.updatePSF();
  
            // ASI_CRM_CN_Payment_Header_Controller.findCashPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            // //ASI_CRM_CN_Payment_Header_Controller.findDiscountWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            // ASI_CRM_CN_Payment_Header_Controller.findDiscountPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            // //ASI_CRM_CN_Payment_Header_Controller.findOtherWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            // //ASI_CRM_CN_Payment_Header_Controller.findOtherPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        test.stopTest();   
    }
    
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST_2() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_NewChannel__c= channel.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        Id BRSFLineItemRecordTypeId = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item');
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = BRSFLineItemRecordTypeId
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = BRSFLineItemRecordTypeId
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        Id paymentRequestRecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_Payment_Type__c = 'Cash',
            ASI_CRM_CN_Adjustment__c=80,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = paymentRequestRecordTypeId));

        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = paymentRequestRecordTypeId));
        insert prs;
       
        test.startTest();
            ASI_CRM_CN_Payment_Header_Controller.findDiscountWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            ASI_CRM_CN_Payment_Header_Controller.findOtherWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            ASI_CRM_CN_Payment_Header_Controller.findOtherPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        test.stopTest();
    }
    
    
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST2() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_NewChannel__c= channel.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
		ASI_CRM_SpecialPromotionTypeSetting__c specialPromotion = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_New_FY_Promotion_Type__c = true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
		insert specialPromotion;
		
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        Id RunningNumberRecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number');
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = RunningNumberRecordTypeId));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = RunningNumberRecordTypeId));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = RunningNumberRecordTypeId));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = RunningNumberRecordTypeId));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = RunningNumberRecordTypeId));
        }
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addMonths(-6),
            ASI_CRM_CN_PO_End_Date__c = system.today().addMonths(1),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        Id BRSFLineItemRecordTypeId = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item');
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = BRSFLineItemRecordTypeId
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = BRSFLineItemRecordTypeId
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        Id paymentRequestRecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_Payment_Type__c = 'Cash',
            ASI_CRM_CN_Adjustment__c=80,
			ASI_CRM_CN_Overpayment_Reason__c='其他－需填写具体原因',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addMonths(-5),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addMonths(-2),
            ASI_TH_CRM_Status__c='Submitted',
            ASI_CRM_CN_Return_Comments__c='a', recordTypeId = paymentRequestRecordTypeId));

        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = paymentRequestRecordTypeId));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        Id payeeLineItemRecordTypeId = Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee');
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =payeeLineItemRecordTypeId,ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =payeeLineItemRecordTypeId,ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =payeeLineItemRecordTypeId,ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
            
        
            ApexPages.CurrentPage().getparameters().put('contractid', ct.id);
   //          ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_PaymentRequest__c());
   //          ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
			// con.othertype = null;
			// con.payableAmount = null;
			// con.OverPaymentReason = null;
			// con.OtherReason = null;
			// con.division = null;
			// con.BRSF_Item_Map = null;
			// con.Save_BRSF_Item = null;
			// con.OTP_Item_Map = null;
			// con.Save_OTP_Item = null;
   //          con.refresh();
   //          con.updateRecord();
   //          con.BRSFReport();
        
            test.startTest();
        
            // ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
            // ApexPages.StandardController sc = new ApexPages.standardController(prs[0]);
            // ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            // //con.GoReturn();
            // con.CancelBRSFChange();
            // //con.cancel();
            // con.digit_formatting(3,19999999);
            // con.digit_formatting(3,1);
            // // con.saveDate();
            // con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addMonths(-8);
            // con.ph.ASI_CRM_CN_BRSF_End_Date__c  = date.today().addMonths(1);
            // con.saveDate();
            // //con.PSFReport();
            // //con.BRSFReport();
            // //con.doCancel();
            // //con.GoURL();
            // con.GoEditHeader();
            // con.GoEditDetail();
            // con.GoEditPayee();
            
            // con.updatePOVersion();
            // con.updateRecord();
            // con.regenerateBRSFVol();
            // con.updatePayeeRecord();
            // //con.submitApproval();
            // con.refresh();
            // con.updateDetailRecord();
            
            // con.addNew_Cash();
            // con.addNew_Discount();
            // con.addNew_CD(); 
            // con.updatePayeeRecord();
            
            // con.addNew_Cash();
            // con.rowidCASH = con.Payee_Item_Map_CASH.size()-1;
            // con.clone_Cash();
            // for(integer i : con.Payee_Item_Map_CASH.keyset()){
            //     con.rowidCASH = i;
            //     con.RemoveRow_Cash();
            // }
            
            // con.addNew_Discount();
            // con.rowidDiscount = con.Payee_Item_Map_Discount.size()-1;
            // con.clone_Discount();
            // for(integer i : con.Payee_Item_Map_Discount.keyset()){
            //     con.rowidDiscount = i;
            //     con.RemoveRow_Discount();
            // }
            
            // con.addNew_CD();            
            // con.rowidCD = con.Payee_Item_Map_CD.size()-1;
            // con.clone_CD();
            // for(integer i : con.Payee_Item_Map_CD.keyset()){
            //     con.rowidCD = i;
            //     con.RemoveRow_CD();
            // }
            // con.updatePayeeRecord();
            
            
            // con.addNew_PSF();
            // con.updatePSF();
            // con.rowidPSF = con.PSF_Item_Map.size()-1;
            // con.clone_PSF();
            // for(integer i : con.PSF_Item_Map.keyset()){
            //     con.rowidPSF = i;
            //     con.removeRow_PSF();
            // }            
            // con.updatePSF();
        test.stopTest();   
    }
	
    static testMethod void ASI_CRM_CN_PaymentRequest_TriggerCls_TEST() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_pr1@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a');//20160914 Ben @ Elufa
        Insert u;
            
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id,ASI_CRM_English_Name__c='TEST');
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c >();
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Payment',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Last Payment',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        insert LDynApproval ;
        
        list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Payment 1st Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
        ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_1__c=0,
        ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_2__c=0,
        ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_3__c=0,
        ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_4__c=0,
        ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_5__c=0,
        ASI_CRM_CN_Approver_6__c = UserInfo.getUserId(), ASI_CRM_Sales_Team__c = 'a'));
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Last Payment 1st Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
        ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_1__c=0,
        ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_2__c=0,
        ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_3__c=0,
        ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_4__c=0,
        ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_5__c=0,
        ASI_CRM_CN_Approver_6__c = UserInfo.getUserId(), ASI_CRM_Sales_Team__c = 'a'));
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Payment 2nd Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
        ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_1__c=0,
        ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_2__c=0,
        ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_3__c=0,
        ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_4__c=0,
        ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_5__c=0,
        ASI_CRM_CN_Approver_6__c = UserInfo.getUserId(), ASI_CRM_Sales_Team__c = 'a'));
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Last Payment 2nd Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
        ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_1__c=0,
        ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_2__c=0,
        ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_3__c=0,
        ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_4__c=0,
        ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_5__c=0,
        ASI_CRM_CN_Approver_6__c = UserInfo.getUserId(), ASI_CRM_Sales_Team__c = 'a'));
        
        insert fars;
        
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',name='testCustomer'
        ,ASI_CRM_CN_CCity__c=city.id,ASI_CRM_CN_NewChannel__c= channel.Id,recordtypeid=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'));
        insert customer;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-3),
            ASI_CRM_CN_PO_End_Date__c = system.today()
            
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;
        test.startTest();
        
        // First Payment
        /*list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_OutletWS__c= customer.id,
            recordtypeid=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'),
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),ASI_CRM_CN_Adjustment__c=90,
            ASI_TH_CRM_Status__c ='Final'));
        insert prs;
        update prs;*/
        
        list<ASI_TH_CRM_PaymentRequest__c> prs2 = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs2.add(new ASI_TH_CRM_PaymentRequest__c(OwnerId = u.id, ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_OutletWS__c= customer.id,
            recordtypeid=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'),
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),ASI_CRM_CN_Adjustment__c=90,
            ASI_CRM_CN_Last_Payment__c =true,
            ASI_CRM_CN_Last_Year_Payment__c = true));
        insert prs2;
        prs2[0].ASI_CRM_CN_Last_Year_Payment__c =false;
        update prs2;
        prs2[0].ASI_CRM_CN_Last_Year_Payment__c =true;
        prs2[0].ASI_CRM_CN_Return_Flag__c =true;//20160914
        update prs2;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs2) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
        }
        insert pris;
        update pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs2) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs2)
            scons.add(new ApexPages.StandardController(pr));
            
        
            
        test.stopTest();
    
    }
    
    static testMethod void ASI_CRM_CN_PaymentRequest_TriggerCls_TEST_1() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_pr2@testing123.com', CompanyName = 'Pernod Ricard China');
        Insert u;
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id,ASI_CRM_English_Name__c='TEST');
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        /*
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c >();
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Payment',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Last Payment',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        insert LDynApproval ;
        
        list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Payment 1st Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
        ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_1__c=0,
        ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_2__c=0,
        ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_3__c=0,
        ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_4__c=0,
        ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_5__c=0,
        ASI_CRM_CN_Approver_6__c = UserInfo.getUserId()));
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Last Payment 1st Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
        ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_1__c=0,
        ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_2__c=0,
        ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_3__c=0,
        ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_4__c=0,
        ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_5__c=0,
        ASI_CRM_CN_Approver_6__c = UserInfo.getUserId()));
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Payment 2nd Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
        ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_1__c=0,
        ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_2__c=0,
        ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_3__c=0,
        ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_4__c=0,
        ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_5__c=0,
        ASI_CRM_CN_Approver_6__c = UserInfo.getUserId()));
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Last Payment 2nd Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
        ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_1__c=0,
        ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_2__c=0,
        ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_3__c=0,
        ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_4__c=0,
        ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),ASI_CRM_CN_Approval_Limit_5__c=0,
        ASI_CRM_CN_Approver_6__c = UserInfo.getUserId()));
        
        insert fars;
        */
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',name='testCustomer'
        ,ASI_CRM_CN_CCity__c=city.id,ASI_CRM_CN_NewChannel__c= channel.Id,recordtypeid=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'));
        insert customer;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-3),
            ASI_CRM_CN_PO_End_Date__c = system.today()
            
            );
        insert ct;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;*/
        test.startTest();
        
        // First Payment
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_OutletWS__c= customer.id,
            recordtypeid=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'),
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),ASI_CRM_CN_Adjustment__c=90,
            ASI_TH_CRM_Status__c ='Final'));
        insert prs;
        update prs;
        
        /*list<ASI_TH_CRM_PaymentRequest__c> prs2 = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs2.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_OutletWS__c= customer.id,
            recordtypeid=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'),
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),ASI_CRM_CN_Adjustment__c=90,
            ASI_CRM_CN_Last_Payment__c =true,
            ASI_CRM_CN_Last_Year_Payment__c = true ));
        insert prs2;
        prs2[0].ASI_CRM_CN_Last_Year_Payment__c =false;
        update prs2;
        prs2[0].ASI_CRM_CN_Last_Year_Payment__c =true;
        update prs2;*/
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
        }
        insert pris;
        update pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
            
        
            
        test.stopTest();
    
    }
    
    static testMethod void ASI_CRM_CN_PaymentRequestLine_TriggerCls_TEST() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id);
        insert ct;
        test.startTest();
            list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
                ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
                ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            insert prs;
            
            Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
            
            list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
            for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
                pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                    ASI_TH_CRM_Payment_Request__c=pr.Id,
                    RecordTypeId=rtPRI,
                    ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
                ));
            }
            insert pris;
        test.stopTest();
    
    }
    
    static testMethod void ASI_TH_CRM_PaymentRequestAutoNumber_TEST() {
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id,ASI_CRM_English_Name__c='TEST');
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',name='testCustomer'
        ,ASI_CRM_CN_CCity__c=city.id,ASI_CRM_CN_NewChannel__c= channel.Id,recordtypeid=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'));
        insert customer;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-3),
            ASI_CRM_CN_PO_End_Date__c = system.today()
            
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_OutletWS__c= customer.id,
            recordtypeid=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'),
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),ASI_CRM_CN_Adjustment__c=90,
            ASI_TH_CRM_Status__c ='Final'));
        insert prs;

        test.startTest();
        
        ASI_TH_CRM_PaymentRequestAutoNumber a = new ASI_TH_CRM_PaymentRequestAutoNumber();
        a.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, prs, null, null);
            
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PaymentInstruction_CmpntCtrl_TEST(){
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_AccountsAdditionalField__c a2 = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        insert a2;
        
        a2 = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2.Id];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=a2.ASI_CRM_Account__c);
        insert ct;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
            ASI_CRM_CN_OutletWS__c=a2.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> ppis = new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            ppis.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(
                ASI_CRM_CN_Payment_Request__c=pr.Id,
                ASI_CRM_CN_Type__c='Cash',
                ASI_CRM_CN_Amount__c=-1,
                ASI_CRM_CN_Payee_Name_T1__c=a2.Id,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            ppis.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(
                ASI_CRM_CN_Payment_Request__c=pr.Id,
                ASI_CRM_CN_Type__c='Discount',
                ASI_CRM_CN_Payee_Name_T1__c=a2.Id,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
        }
        insert ppis;

        test.startTest();
        {   
            ASI_CRM_CN_PaymentInstruction_CmpntCtrl compnt = new ASI_CRM_CN_PaymentInstruction_CmpntCtrl();
            compnt.thisPayee = ppis[0];
            compnt.init();
        }
        test.stopTest();

    }

    /*
    static testMethod void ASI_CRM_CN_POPaymentCO_Cmpnt_Ctrl_TEST(){
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_AccountsAdditionalField__c a2 = new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        insert a2;
        
        a2 = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2.Id];        
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c'));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c'));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo'));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_CRM_Sub_Brand_Grade__c grade = new ASI_CRM_Sub_Brand_Grade__c (
            Name='TEST');
        insert grade;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c (
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
          ASI_CRM_CN_Sub_brand_Grade__c=grade.Id);
        insert subBrand;
             
        ASI_TH_CRM_Contract__c ctLast = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=a2.ASI_CRM_Account__c,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = date.newInstance(2014,7,31),
            ASI_CRM_CN_PO_End_Date__c = date.newInstance(2014,9,2),
            ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
            ASI_CRM_CN_Status__c = 'Archived'
            );
        insert ctLast;
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=a2.ASI_CRM_Account__c,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_PO_Start_Date__c = date.newInstance(2014,7,31),
            ASI_CRM_CN_PO_End_Date__c = date.newInstance(2014,9,2),
            ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
            ASI_CRM_CN_Status__c = 'Draft',
            ASI_CRM_CN_Last_PO_version__c = ctLast.id,
            ASI_CRM_CN_V0_0_PO_version__c = ctLast.id
            
            );
        insert ct;

        List<ASI_CRM_Contract_Cost__c> LContractCost = new List<ASI_CRM_Contract_Cost__c>();
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        LContractCost.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ctLast.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        ));
        insert LContractCost;

        list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            svs.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c=a2.Id,
                ASI_CRM_Subbrand__c=subBrand.Id,
                ASI_CRM_End_Date__c=system.today().addMonths(-12+i)
            ));
        }
        insert svs;

        list<ASI_CRM_CM_GS__c> cgs = new list<ASI_CRM_CM_GS__c>();
        cgs.add(new ASI_CRM_CM_GS__c(
            ASI_CRM_PRODUCTCODE__c=subBrand.Id,
            ASI_CRM_Region__c=region.Id,
            ASI_CRM_Sub_Channel__c=subChannel.Id,
            ASI_CRM_YEAR__c='2014',
            ASI_CRM_CN_Month__c=8,
            ASI_CRM_TYPE__c='Budget CM'
        ));
        cgs.add(new ASI_CRM_CM_GS__c(
            ASI_CRM_PRODUCTCODE__c=subBrand.Id,
            ASI_CRM_Region__c=region.Id,
            ASI_CRM_Sub_Channel__c=subChannel.Id,
            ASI_CRM_YEAR__c='2014',
            ASI_CRM_CN_Month__c=8,
            ASI_CRM_TYPE__c='Budget GS'
        ));
        cgs.add(new ASI_CRM_CM_GS__c(
            ASI_CRM_PRODUCTCODE__c=subBrand.Id,
            ASI_CRM_Region__c=region.Id,
            ASI_CRM_Sub_Channel__c=subChannel.Id,
            ASI_CRM_YEAR__c='2014',
            ASI_CRM_CN_Month__c=8,
            ASI_CRM_TYPE__c='YTD CM'
        ));
        cgs.add(new ASI_CRM_CM_GS__c(
            ASI_CRM_PRODUCTCODE__c=subBrand.Id,
            ASI_CRM_Region__c=region.Id,
            ASI_CRM_Sub_Channel__c=subChannel.Id,
            ASI_CRM_YEAR__c='2014',
            ASI_CRM_CN_Month__c=8,
            ASI_CRM_TYPE__c='YTD GS'
        ));
        insert cgs;

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        LBRSF.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = ct.id, ASI_CRM_CN_Sub_Brand__c=subBrand.Id));
        LBRSF.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c = ctLast.id, ASI_CRM_CN_Sub_Brand__c=subBrand.Id));
        insert LBRSF;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_BRSF_Start_Date__c = date.newInstance(2014,7,31),
            ASI_CRM_CN_BRSF_End_Date__c = date.newInstance(2014,9,2),
            ASI_CRM_CN_OutletWS__c=a2.Id));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ctLast.Id,
            ASI_CRM_CN_BRSF_Start_Date__c = date.newInstance(2014,7,31),
            ASI_CRM_CN_BRSF_End_Date__c = date.newInstance(2014,9,2),
            ASI_CRM_CN_OutletWS__c=a2.Id));        
        insert prs;

        ASI_TH_CRM_PaymentRequest__c paymentReq = [SELECT Name, Id, ASI_CRM_CN_BRSF_Start_Date__c, ASI_CRM_CN_BRSF_End_Date__c, ASI_TH_CRM_Contract__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,  ASI_CRM_CN_OutletWS__c FROM ASI_TH_CRM_PaymentRequest__c WHERE Id=:prs[0].id];

        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        Id rtPSF = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPSF,
                ASI_CRM_CN_Period_Start__c=date.newInstance(2014,8,1),
                ASI_CRM_CN_Period_End__c=date.newInstance(2014,9,1),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> ppis = new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            ppis.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(
                ASI_CRM_CN_Payment_Request__c=pr.Id,
                ASI_CRM_CN_Type__c='Cash',
                ASI_CRM_CN_Amount__c=-1,
                ASI_CRM_CN_Payee_Name_T1__c=a2.Id));
            ppis.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(
                ASI_CRM_CN_Payment_Request__c=pr.Id,
                ASI_CRM_CN_Type__c='Discount',
                ASI_CRM_CN_Payee_Name_T1__c=a2.Id));
        }
        insert ppis;

        test.startTest();
        {   
            ASI_CRM_CN_POPaymentCO_Cmpnt_Ctrl compnt = new ASI_CRM_CN_POPaymentCO_Cmpnt_Ctrl();
            compnt.thisPR = paymentReq;
            compnt.init();
        }
        test.stopTest();
    }
    */

    static testMethod void ASI_CRM_CN_PaymentSlipCtrl_TEST(){
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_NewChannel__c= channel.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'), //20180116 Introv
            Name = 'Contract1',
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'), //20180116 Introv
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id));
        insert cts[1];
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ct.Id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            }
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ct.Id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        }
        insert ctis;
        insert cos;
        
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[0].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[1].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[0].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[1].Id));
        insert ccs;
        
        list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                svs.add(new ASI_CRM_Subbrand_Volume__c(
                    ASI_CRM_Account__c=a2s[0].Id,
                    ASI_CRM_Subbrand__c=subBrand.Id,
                    ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                    ASI_CRM_T1_Depletion_STD_Billing__c=1,
                    ASI_CRM_T2_Depletion_STD_Billing__c=1,
                    ASI_CRM_PR_Direct_STD_Billing__c=1,
                    ASI_CRM_T1_Depletion_CR12__c=1,
                    ASI_CRM_T2_Depletion_CR12__c=1,
                    ASI_CRM_PR_Direct_CR12__c=1,
                    ASI_CRM_Empty_Bottle__c=1,
                    ASI_CRM_Green_Cap_Std_Billing__c=1,
                    ASI_CRM_Empty_Bottle_CR12__c=1,
                    ASI_CRM_Green_Cap_CR12__c=1));
            }

            svs.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c=a2s[0].Id,
                ASI_CRM_Subbrand__c=null,
                ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                ASI_CRM_T1_Depletion_STD_Billing__c=1,
                ASI_CRM_T2_Depletion_STD_Billing__c=1,
                ASI_CRM_PR_Direct_STD_Billing__c=1,
                ASI_CRM_T1_Depletion_CR12__c=1,
                ASI_CRM_T2_Depletion_CR12__c=1,
                ASI_CRM_PR_Direct_CR12__c=1,
                ASI_CRM_Empty_Bottle__c=1,
                ASI_CRM_Green_Cap_Std_Billing__c=1,
                ASI_CRM_Empty_Bottle_CR12__c=1,
                ASI_CRM_Green_Cap_CR12__c=1));
        }
        insert svs;
        
        list<ASI_CRM_CM_GS__c> cgs = new list<ASI_CRM_CM_GS__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='Budget CM'
            ));
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='Budget GS'
            ));
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='YTD CM'
            ));
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='YTD GS'
            ));
        }
        insert cgs;
        
        test.startTest();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
//        prs.add(new ASI_TH_CRM_PaymentRequest__c(
//            ASI_TH_CRM_Contract__c=cts[1].Id));
          prs.add(new ASI_TH_CRM_PaymentRequest__c(
            ASI_TH_CRM_Contract__c=cts[1].Id,
            ASI_CRM_CN_OutletWS__c=a2s[0].Id,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            for(integer i=0; i<5; i++)
                                
                pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                    ASI_TH_CRM_Payment_Request__c=pr.Id,
                    RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                    ASI_CRM_CN_Period_Start__c=system.today().addMonths(-2), ASI_CRM_CN_Period_End__c=system.today().addMonths(-1),
                    ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
                ));
            // //no approval process for PR
            //{
            //    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            //    req1.setComments('Submitting request for approval.');
            //    req1.setObjectId(pr.Id);
            //    Approval.process(req1);
            //}
        }
        insert pris;

        list<ASI_CRM_CN_PH_Payee_Line_Item__c> ppis = new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            ppis.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(
                ASI_CRM_CN_Payment_Request__c=pr.Id,
                ASI_CRM_CN_Invoice_Number__c='000000001',
                ASI_CRM_CN_Cash_Payee_Name_T1__c=a2s[0].ASI_CRM_Account__c,
                ASI_CRM_CN_Type__c='Cash',
                ASI_CRM_CN_Amount__c=-1,
                ASI_CRM_CN_Reason__c='xxxxxxxx',
                ASI_CRM_CN_Payee_Name_T1__c=a2s[0].Id,
                ASI_CRM_CN_Payee_Name_T2_lookup__c=a2s[0].Id,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            ppis.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(
                ASI_CRM_CN_Payment_Request__c=pr.Id,
                ASI_CRM_CN_Invoice_Number__c='000000002',
                ASI_CRM_CN_Cash_Payee_Name_T1__c=a2s[0].ASI_CRM_Account__c,
                ASI_CRM_CN_Type__c='Discount',
                ASI_CRM_CN_Amount__c=1,
                ASI_CRM_CN_Reason__c='xxxxxxxx',
                ASI_CRM_CN_Payee_Name_T1__c=a2s[0].Id,
                ASI_CRM_CN_Payee_Name_T2_lookup__c=a2s[0].Id,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));    
            ppis.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(
                ASI_CRM_CN_Payment_Request__c=pr.Id,
                ASI_CRM_CN_Invoice_Number__c='000000001',
                ASI_CRM_CN_Type__c='Discount',
                ASI_CRM_CN_Reason__c='xxxxxxxx',
                ASI_CRM_CN_Payee_Name_T1__c=a2s[0].Id,
                ASI_CRM_CN_Payee_Name_T2_lookup__c=a2s[0].Id,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
        }
        insert ppis;

        
        {
            ApexPages.currentPage().getParameters().put('id', prs[0].Id);
            ASI_CRM_CN_PaymentSlipCtrl con0 = new ASI_CRM_CN_PaymentSlipCtrl(new ApexPages.StandardController(prs[0]));

            
            ASI_CRM_CN_PaymentSlipCtrl con1 = new ASI_CRM_CN_PaymentSlipCtrl(new ApexPages.StandardController(prs[0]));
            
            con1.PayeeItem = ppis[0].id;
            con1.PTSelected = 'Instruction';
            con1.getPayee();
            con1.GeneratePDF();
            con1.GeneratePDFT2();
            con1.PayeeItem = ppis[1].id;
            con1.PTSelected = 'Receipt';
            con1.getPayee();
            con1.GeneratePDF(); 
            con1.GeneratePDFT2();
            con1.CancelPage();

        }
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_BRSFFormPDFCtrl_TEST() {
        
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id);
        insert ct;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            for(integer i=0; i<5; i++)
                pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                    ASI_TH_CRM_Payment_Request__c=pr.Id,
                    RecordTypeId=rtPRI,
                    ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
                ));
        }
        insert pris;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        test.startTest();
        
        ASI_CRM_CN_BRSFFormPDFCtrl.BRSFTotal t = new ASI_CRM_CN_BRSFFormPDFCtrl.BRSFTotal();
        
        ASI_CRM_CN_BRSFFormPDFCtrl con0 = new ASI_CRM_CN_BRSFFormPDFCtrl();
        
        for(ApexPages.StandardController scon :scons) {
            ApexPages.currentPage().getParameters().put('id', scon.getId());
            ASI_CRM_CN_BRSFFormPDFCtrl con = new ASI_CRM_CN_BRSFFormPDFCtrl(scon);
            con.init();
            con.SBGradeSorting(null);
            con.SBGradeSorting(1);
            con.SBGradeSorting(11);
            con.SBGradeSorting(101);
            con.SBGradeSorting(1001);
        }
        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr_TEST() {
            
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_AccountsAdditionalField__c a2 = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        insert a2;
        
        a2 = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2.Id];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=a2.ASI_CRM_Account__c);
        insert ct;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
            ASI_CRM_CN_OutletWS__c=a2.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> ppis = new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            ppis.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(
                ASI_CRM_CN_Payment_Request__c=pr.Id,
                ASI_CRM_CN_Type__c='Cash',
                ASI_CRM_CN_Payee_Name_T1__c=a2.Id,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
            ppis.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(
                ASI_CRM_CN_Payment_Request__c=pr.Id,
                ASI_CRM_CN_Type__c='Discount',
                ASI_CRM_CN_Payee_Name_T1__c=a2.Id,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee')));
        }
        insert ppis;
        
        map<Id, SObject> oldMap = new map<Id, SObject>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            ASI_TH_CRM_PaymentRequest__c prOld = pr.clone(true,true,true,true);
            oldMap.put(pr.Id, prOld);
            pr.ASI_TH_CRM_GL_Date__c=system.today();
        }
        
        test.startTest();
        
        ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr t = new ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr();
        
        t.executeTriggerAction(null, prs, null, oldMap);
        
        test.stopTest();
        
    }

    static testMethod void ASI_CRM_CN_PRForm_Cmpnt_Ctrl_TEST() {
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_NewChannel__c= channel.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_CRM_Sub_Brand_Grade__c grade = new ASI_CRM_Sub_Brand_Grade__c (
            Name='TEST');
        insert grade;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c (
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
            ASI_CRM_CN_Sub_brand_Grade__c=grade.Id);
        insert subBrand;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'), //20180116 Introv
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'), //20180116 Introv
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id));
        insert cts[1];
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        }
        insert ctis;
        insert cos;
        
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[0].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[1].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[0].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[1].Id));
        insert ccs;
        
        list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            svs.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c=a2s[0].Id,
                ASI_CRM_Subbrand__c=subBrand.Id,
                ASI_CRM_End_Date__c=system.today().addMonths(-12+i)
            ));
        }
        insert svs;
        
        list<ASI_CRM_CM_GS__c> cgs = new list<ASI_CRM_CM_GS__c>();
        for(integer i=-2; i<=2; i++)
            for(integer j=1; j<=12; j++) {
                cgs.add(new ASI_CRM_CM_GS__c(
                    ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                    ASI_CRM_Region__c=region.Id,
                    ASI_CRM_YEAR__c=string.valueOf(system.today().year()+i),
                    ASI_CRM_CN_Month__c=j,
                    ASI_CRM_CM_GS_per_9L__c = 1,//20170223 Elufa
                    ASI_CRM_TYPE__c='Budget CM'
                ));
                cgs.add(new ASI_CRM_CM_GS__c(
                    ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                    ASI_CRM_Region__c=region.Id,
                    ASI_CRM_YEAR__c=string.valueOf(system.today().year()+i),
                    ASI_CRM_CN_Month__c=j,
                    ASI_CRM_CM_GS_per_9L__c = 1,
                    ASI_CRM_TYPE__c='Budget GS'
                ));
                cgs.add(new ASI_CRM_CM_GS__c(
                    ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                    ASI_CRM_Region__c=region.Id,
                    ASI_CRM_YEAR__c=string.valueOf(system.today().year()+i),
                    ASI_CRM_CN_Month__c=j,
                    ASI_CRM_CM_GS_per_9L__c = 1,
                    ASI_CRM_TYPE__c='YTD CM'
                ));
                cgs.add(new ASI_CRM_CM_GS__c(
                    ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                    ASI_CRM_Region__c=region.Id,
                    ASI_CRM_YEAR__c=string.valueOf(system.today().year()+i),
                    ASI_CRM_CN_Month__c=j,
                    ASI_CRM_CM_GS_per_9L__c = 1,
                    ASI_CRM_TYPE__c='YTD GS'
                ));
            }
        insert cgs;
        
        list<ASI_CRM_CN_Channel_Strategy__c> css = new list<ASI_CRM_CN_Channel_Strategy__c>();
        css.add(new ASI_CRM_CN_Channel_Strategy__c(
            ASI_CRM_CN_Area__c=area.Id,
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_Fiscal_Year__c=ASI_CRM_CN_Function.getFiscalYear(system.today()),
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert css;
                
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> csis = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        for(ASI_CRM_CN_Channel_Strategy__c cs :css) {
            csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_CRM_CN_Channel_Strategy__c=cs.Id, ASI_CRM_CN_Brand__c='Priority 1'));
            csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_CRM_CN_Channel_Strategy__c=cs.Id, ASI_CRM_CN_Brand__c='Priority 2'));
        }
        insert csis;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
//        prs.add(new ASI_TH_CRM_PaymentRequest__c(
//            ASI_TH_CRM_Contract__c=cts[1].Id));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(
            ASI_TH_CRM_Contract__c=cts[1].Id,
            ASI_CRM_CN_OutletWS__c=a2s[0].Id,
            ASI_CRM_CN_Description__c ='testing', //20170223 Elufa
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            for(integer i=0; i<5; i++)
                                
                pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                    ASI_TH_CRM_Payment_Request__c=pr.Id,
                    RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                    ASI_CRM_CN_Period_Start__c=system.today().addMonths(-2), ASI_CRM_CN_Period_End__c=system.today().addMonths(-1),
                    ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                    ASI_CRM_CN_Comment__c = 'testing' //20170223 Elufa
                ));
            // //no approval process for PR
            //{
            //    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            //    req1.setComments('Submitting request for approval.');
            //    req1.setObjectId(pr.Id);
            //    Approval.process(req1);
            //}
        }
        insert pris;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
                
        test.startTest();
        
        ASI_CRM_CN_PRForm_Cmpnt_Ctrl con0 = new ASI_CRM_CN_PRForm_Cmpnt_Ctrl();
        
        //20170223 Elufa
        con0.isTestDate = Null;
        con0.relatedto = Null;
        con0.dummyVar = Null;
        con0.totalOffTakeVSInTake = Null;
        con0.totalOffTakeVSBC = Null;
        //con0.SB_Vol_List_All = Null;
        con0.UserId = Null;
        
        
        for(ApexPages.StandardController scon :scons) {
            ApexPages.currentPage().getParameters().put('id', scon.getId());
            ASI_CRM_CN_PRForm_Cmpnt_Ctrl con = new ASI_CRM_CN_PRForm_Cmpnt_Ctrl(scon);
            con.strPDF='1';
            con.init();
            
            con.checkFY(date.newInstance(2014,1,1), date.newInstance(2014,1,1));
            con.checkFY(date.newInstance(2014,1,1), date.newInstance(2014,7,1));
            con.checkFY(date.newInstance(2014,7,1), date.newInstance(2014,7,1));
            con.checkFY(date.newInstance(2014,7,1), date.newInstance(2015,1,1));
            con.checkFYDayPeriod(date.newInstance(2014,1,1), date.newInstance(2014,1,1));
            con.checkFYDayPeriod(date.newInstance(2014,1,1), date.newInstance(2014,7,1));
            con.checkFYDayPeriod(date.newInstance(2014,7,1), date.newInstance(2014,7,1));
            con.checkFYDayPeriod(date.newInstance(2014,7,1), date.newInstance(2015,1,1));

            con.FYConversion(system.today());
            con.checkUserID();
            con.checkApprover();
        }
        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_PSFFormPDFCtrl_TEST() {
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_NewChannel__c= channel.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
                                                       
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'), //20180116 Introv
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'), //20180116 Introv
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id));
        insert cts[1];
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ct.Id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            }
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ct.Id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        }
        insert ctis;
        insert cos;
        
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[0].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[1].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[0].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[1].Id));
        insert ccs;
        
        list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                svs.add(new ASI_CRM_Subbrand_Volume__c(
                    ASI_CRM_Account__c=a2s[0].Id,
                    ASI_CRM_Subbrand__c=subBrand.Id,
                    ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                    ASI_CRM_T1_Depletion_STD_Billing__c=1,
                    ASI_CRM_T2_Depletion_STD_Billing__c=1,
                    ASI_CRM_PR_Direct_STD_Billing__c=1,
                    ASI_CRM_T1_Depletion_CR12__c=1,
                    ASI_CRM_T2_Depletion_CR12__c=1,
                    ASI_CRM_PR_Direct_CR12__c=1,
                    ASI_CRM_Empty_Bottle__c=1,
                    ASI_CRM_Green_Cap_Std_Billing__c=1,
                    ASI_CRM_Empty_Bottle_CR12__c=1,
                    ASI_CRM_Green_Cap_CR12__c=1));
            }
                svs.add(new ASI_CRM_Subbrand_Volume__c(
                    ASI_CRM_Account__c=a2s[0].Id,
                    ASI_CRM_Subbrand__c=null,
                    ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                    ASI_CRM_T1_Depletion_STD_Billing__c=1,
                    ASI_CRM_T2_Depletion_STD_Billing__c=1,
                    ASI_CRM_PR_Direct_STD_Billing__c=1,
                    ASI_CRM_T1_Depletion_CR12__c=1,
                    ASI_CRM_T2_Depletion_CR12__c=1,
                    ASI_CRM_PR_Direct_CR12__c=1,
                    ASI_CRM_Empty_Bottle__c=1,
                    ASI_CRM_Green_Cap_Std_Billing__c=1,
                    ASI_CRM_Empty_Bottle_CR12__c=1,
                    ASI_CRM_Green_Cap_CR12__c=1));
        }
        insert svs;
        
        list<ASI_CRM_CM_GS__c> cgs = new list<ASI_CRM_CM_GS__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='Budget CM'
            ));
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='Budget GS'
            ));
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='YTD CM'
            ));
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='YTD GS'
            ));
        }
        insert cgs;
        
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
//        prs.add(new ASI_TH_CRM_PaymentRequest__c(
//            ASI_TH_CRM_Contract__c=cts[1].Id));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(
            ASI_TH_CRM_Contract__c=cts[1].Id,
            ASI_CRM_CN_OutletWS__c=a2s[0].Id,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            for(integer i=0; i<5; i++)
                                
                pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                    ASI_TH_CRM_Payment_Request__c=pr.Id,
                    RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                    ASI_CRM_CN_Period_Start__c=system.today().addMonths(-2), ASI_CRM_CN_Period_End__c=system.today().addMonths(-1),
                    ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
                ));
            // //no approval process for PR
            //{
            //    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            //    req1.setComments('Submitting request for approval.');
            //    req1.setObjectId(pr.Id);
            //    Approval.process(req1);
            //}
        }
        insert pris;
        
        
        test.startTest();
        
        ASI_CRM_CN_PSFFormPDFCtrl con0 = new ASI_CRM_CN_PSFFormPDFCtrl();
        
        ApexPages.currentPage().getParameters().put('id', null);
        ASI_CRM_CN_PSFFormPDFCtrl con = new ASI_CRM_CN_PSFFormPDFCtrl(new ApexPages.StandardController(prs[0]));
        
        ApexPages.currentPage().getParameters().put('id', prs[0].Id);
        con = new ASI_CRM_CN_PSFFormPDFCtrl(new ApexPages.StandardController(prs[0]));
        con.init();
        
        con.SBGradeSorting(null);
        con.SBGradeSorting(1);
        con.SBGradeSorting(10);
        con.SBGradeSorting(100);
        con.SBGradeSorting(1000);
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_ReturnPaymentByBACtrl_TEST() {
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                  RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = '新兴业务部',
            RecordTypeId=rtWS,
            ASI_CRM_CN_NewChannel__c= channel.Id,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'), //20180116 Introv
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'), //20180116 Introv
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id));
        insert cts[1];
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ct.Id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            }
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ct.Id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        }
        insert ctis;
        insert cos;
        
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[0].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[1].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[0].Id));
        ccs.add(new ASI_CRM_Contract_Cost__c(
            Name='TEST',
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Contract_Amount__c=1,
            ASI_CRM_CN_Estimate_Amount__c=1,
            ASI_CRM_CN_Contract__c=cts[1].Id));
        insert ccs;
        
        list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                svs.add(new ASI_CRM_Subbrand_Volume__c(
                    ASI_CRM_Account__c=a2s[0].Id,
                    ASI_CRM_Subbrand__c=subBrand.Id,
                    ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                    ASI_CRM_T1_Depletion_STD_Billing__c=1,
                    ASI_CRM_T2_Depletion_STD_Billing__c=1,
                    ASI_CRM_PR_Direct_STD_Billing__c=1,
                    ASI_CRM_T1_Depletion_CR12__c=1,
                    ASI_CRM_T2_Depletion_CR12__c=1,
                    ASI_CRM_PR_Direct_CR12__c=1,
                    ASI_CRM_Empty_Bottle__c=1,
                    ASI_CRM_Green_Cap_Std_Billing__c=1,
                    ASI_CRM_Empty_Bottle_CR12__c=1,
                    ASI_CRM_Green_Cap_CR12__c=1));
            }
                svs.add(new ASI_CRM_Subbrand_Volume__c(
                    ASI_CRM_Account__c=a2s[0].Id,
                    ASI_CRM_Subbrand__c=null,
                    ASI_CRM_End_Date__c=system.today().addMonths(-12+i),
                    ASI_CRM_T1_Depletion_STD_Billing__c=1,
                    ASI_CRM_T2_Depletion_STD_Billing__c=1,
                    ASI_CRM_PR_Direct_STD_Billing__c=1,
                    ASI_CRM_T1_Depletion_CR12__c=1,
                    ASI_CRM_T2_Depletion_CR12__c=1,
                    ASI_CRM_PR_Direct_CR12__c=1,
                    ASI_CRM_Empty_Bottle__c=1,
                    ASI_CRM_Green_Cap_Std_Billing__c=1,
                    ASI_CRM_Empty_Bottle_CR12__c=1,
                    ASI_CRM_Green_Cap_CR12__c=1));
        }
        insert svs;
        
        list<ASI_CRM_CM_GS__c> cgs = new list<ASI_CRM_CM_GS__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='Budget CM'
            ));
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='Budget GS'
            ));
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='YTD CM'
            ));
            cgs.add(new ASI_CRM_CM_GS__c(
                ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                ASI_CRM_Region__c=region.Id,
                ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
                ASI_CRM_CN_Month__c=system.today().month(),
                ASI_CRM_TYPE__c='YTD GS'
            ));
        }
        insert cgs;
        
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(
            ASI_TH_CRM_Contract__c=cts[1].Id,
            ASI_CRM_CN_OutletWS__c=a2s[0].Id,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            for(integer i=0; i<5; i++)
                                
                pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                    ASI_TH_CRM_Payment_Request__c=pr.Id,
                    RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                    ASI_CRM_CN_Period_Start__c=system.today().addMonths(-2), ASI_CRM_CN_Period_End__c=system.today().addMonths(-1),
                    ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
                ));
        }
        insert pris;
        
        
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', prs[0].Id);
        ASI_CRM_CN_ReturnPaymentByBACtrl con = new ASI_CRM_CN_ReturnPaymentByBACtrl(new ApexPages.StandardController(prs[0]));
            
        con.cancel();
        con.doApprove();
        test.stopTest();
    }
}