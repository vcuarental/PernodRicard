@isTest (SeeAllData=false)
public class ASI_CRM_CN_Contract_Test {

    static testMethod void ASI_CRM_CN_ContractEmailCtrl_TEST() {
        
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', 
            RecordTypeId=rtWS,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id, 
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', 
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));

        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c (
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
         ASI_CRM_CN_Standard_Bottle_Size__c=10000);
        insert subBrand;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c(
            ASI_CRM_Promotion_Type__c = 'New Contract OFF');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(
            ASI_CRM_Promotion_Type__c = 'Wholesaler Promotion');
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(
            ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,
            ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        Date PO_Start_Date = date.newinstance(system.today().addMonths(-1).year(), system.today().addMonths(-1).month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=PO_Start_Date, 
            ASI_CRM_CN_PO_End_Date__c=PO_End_Date,
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='Wholesaler Promotion',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Description__c='Description',
            ASI_CRM_CN_Bottle_Collection_Rate__c=10,
            ASI_CRM_CN_PO_No__c = 'r2r2',
            ASI_CRM_PO_Channel__c = channel.id,
            ASI_CRM_CN_Vol_Budget_LE__c=10));
            insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=PO_Start_Date.addMonths(5), 
            ASI_CRM_CN_PO_End_Date__c=PO_End_Date.addMonths(5), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='Wholesaler Promotion',
            Name = 'Contract2',
            ASI_CRM_CN_Description__c = 'testing', //20170223 Elufa
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_PO_No__c = 'r2r2',
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_PO_Channel__c = channel.id,
            ASI_CRM_CN_Status__c='Submitted',
            ASI_CRM_CN_PO_Version__c = '0.1'));
        insert cts[1];
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
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
                ASI_CRM_End_Date__c=system.today().addMonths(-i+3)
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
                    ASI_CRM_CM_GS_per_9L__c=1,
                    ASI_CRM_TYPE__c='Budget CM'
                ));
                cgs.add(new ASI_CRM_CM_GS__c(
                    ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                    ASI_CRM_Region__c=region.Id,
                    ASI_CRM_YEAR__c=string.valueOf(system.today().year()+i),
                    ASI_CRM_CN_Month__c=j,
                    ASI_CRM_CM_GS_per_9L__c=1,
                    ASI_CRM_TYPE__c='YTD CM'
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
        
        //Approval Comments
        Id rtAppC1 = Global_RecordTypeCache.getRtId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment');
        Id rtAppC2 = Global_RecordTypeCache.getRtId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment');
        list<ASI_CRM_Approval_Comment__c> lstAppComment = new list<ASI_CRM_Approval_Comment__c>();
        lstAppComment.add(new ASI_CRM_Approval_Comment__c(RecordTypeId=rtAppC1,ASI_CRM_Contract__c=cts[1].id));
        lstAppComment.add(new ASI_CRM_Approval_Comment__c(RecordTypeId=rtAppC2,ASI_CRM_Contract__c=cts[1].id));
        insert lstAppComment;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser){
            test.startTest();
            
            //cts[0]
        ApexPages.StandardController scon = new ApexPages.StandardController(cts[1]);
        ApexPages.currentPage().getParameters().put('id', cts[1].Id);
        ASI_CRM_CN_ContractEmailCtrl con = new ASI_CRM_CN_ContractEmailCtrl();
        con = new ASI_CRM_CN_ContractEmailCtrl(scon);
        
        con.dummyVar = null;
        con.isTestDate = null;
        con.PromotionTypeFilter = null;
        con.fixedDescription = null;
        con.previousCCSalesRep = null;
        con.InitPreviousCCStart = null;
        con.InitPreviousCCEnd = null;
        con.InitPreviousCCSalesRep = null;
        con.InitPreviousCCNoMonths = null;
        con.UserId = null;
        con.PreviousV0CC = null;
        con.boolCheckCCPeriod = null;
            
        con.init();
        //con.getPreviousCCData();
        con.getthisCCData();
        con.finalize_data();
        con.LoopSubbrand_data();
        con.FindMinMaxDate(system.today(), system.today().addDays(1), 'MAX');
        con.FindMinMaxDate(system.today(), system.today().addDays(1), 'MIN');
        con.checkUserID();
        con.checkApprover();
        con.SBGradeSorting(null);
        con.SBGradeSorting(1);
        con.SBGradeSorting(10);
        con.SBGradeSorting(100);
        con.SBGradeSorting(1000);
        
        con.checkFiscalYear(date.newInstance(2014,1,1), date.newInstance(2014,1,1));
        con.checkFiscalYear(date.newInstance(2014,1,1), date.newInstance(2014,7,1));
        con.checkFiscalYear(date.newInstance(2014,7,1), date.newInstance(2015,1,1));
        con.FindMinMaxDate(system.today(), system.today().addDays(1),'MAX');
        con.FindMinMaxDate(system.today(), system.today().addDays(1),'MIN');
        con.MonthDiff(null,null);
        con.FYConversion(date.newInstance(2014,7,1));
        con.FYConversion(date.newInstance(2014,1,1));
        delete ctis;
        
        //cts[1]
        scon = new ApexPages.StandardController(cts[1]);
        ApexPages.currentPage().getParameters().put('id', cts[1].Id);
        con = new ASI_CRM_CN_ContractEmailCtrl(scon);
        
        con.init();
            list<ASI_CRM_CN_Covered_Outlet__c> cos1 = new list<ASI_CRM_CN_Covered_Outlet__c>();
            list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis1 = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            for(ASI_TH_CRM_Contract__c ct :cts) {
                ctis1.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                    ASI_CRM_CN_Contract__c=ct.Id,
                    ASI_CRM_CN_Est_Monthly_Qty__c=1,
                    ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                    ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                    ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
                ));
            }
            insert ctis1;
        con.getPreviousCCData();
        //con.getthisCCData();
        con.finalize_data();
        con.LoopSubbrand_data();
        con.FindMinMaxDate(system.today(), system.today().addDays(1), 'MAX');
        con.FindMinMaxDate(system.today(), system.today().addDays(1), 'MIN');
        con.checkUserID();
        /*con.checkApprover();
        con.SBGradeSorting(null);
        con.SBGradeSorting(1);
        con.SBGradeSorting(10);
        con.SBGradeSorting(100);
        con.SBGradeSorting(1000);

        con.checkFiscalYear(date.newInstance(2014,1,1), date.newInstance(2014,1,1));
        con.checkFiscalYear(date.newInstance(2014,1,1), date.newInstance(2014,7,1));
        con.checkFiscalYear(date.newInstance(2014,7,1), date.newInstance(2015,1,1));
        con.FindMinMaxDate(system.today(), system.today().addDays(1),'MAX');
        con.FindMinMaxDate(system.today(), system.today().addDays(1),'MIN');
        con.MonthDiff(null,null);
        con.FYConversion(date.newInstance(2014,7,1));
        con.FYConversion(date.newInstance(2014,1,1));*/
        
        test.stopTest();   
        }
    }
  
    static testMethod void ASI_CRM_CN_ContractEmailCtrl_TEST2() {
        
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
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', 
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', 
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c (
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
         ASI_CRM_CN_Standard_Bottle_Size__c=10000);
        insert subBrand;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c(
            ASI_CRM_Promotion_Type__c = 'Test');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(
            ASI_CRM_Promotion_Type__c = 'Test2');
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(
            ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,
            ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='Test',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Description__c='Description',
            ASI_CRM_CN_Bottle_Collection_Rate__c=10,
            ASI_CRM_CN_Vol_Budget_LE__c=10));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(+1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='Test2',
            Name = 'Contract2',
            ASI_CRM_CN_Description__c = 'testing', //20170223 Elufa
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_PO_Version__c = '0.1'));
        insert cts[1];
        
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
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
                ASI_CRM_End_Date__c=system.today().addMonths(-i+3)
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
                    ASI_CRM_CM_GS_per_9L__c=1,
                    ASI_CRM_TYPE__c='Budget CM'
                ));
                cgs.add(new ASI_CRM_CM_GS__c(
                    ASI_CRM_PRODUCTCODE__c=subBrand.Id,
                    ASI_CRM_Region__c=region.Id,
                    ASI_CRM_YEAR__c=string.valueOf(system.today().year()+i),
                    ASI_CRM_CN_Month__c=j,
                    ASI_CRM_CM_GS_per_9L__c=1,
                    ASI_CRM_TYPE__c='YTD CM'
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
        
        //Approval Comments
        Id rtAppC1 = Global_RecordTypeCache.getRtId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment');
        Id rtAppC2 = Global_RecordTypeCache.getRtId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment');
        list<ASI_CRM_Approval_Comment__c> lstAppComment = new list<ASI_CRM_Approval_Comment__c>();
        lstAppComment.add(new ASI_CRM_Approval_Comment__c(RecordTypeId=rtAppC1,ASI_CRM_Contract__c=cts[1].id));
        lstAppComment.add(new ASI_CRM_Approval_Comment__c(RecordTypeId=rtAppC2,ASI_CRM_Contract__c=cts[1].id));
        insert lstAppComment;

        test.startTest();
        
        //cts[0]
        ApexPages.StandardController scon = new ApexPages.StandardController(cts[1]);
        ApexPages.currentPage().getParameters().put('id', cts[1].Id);
        ASI_CRM_CN_ContractEmailCtrl con = new ASI_CRM_CN_ContractEmailCtrl();
        con = new ASI_CRM_CN_ContractEmailCtrl(scon);
        
        con.dummyVar = null;
        con.isTestDate = null;
        con.PromotionTypeFilter = null;
        con.fixedDescription = null;
        con.previousCCSalesRep = null;
        con.InitPreviousCCStart = null;
        con.InitPreviousCCEnd = null;
        con.InitPreviousCCSalesRep = null;
        con.InitPreviousCCNoMonths = null;
        con.UserId = null;
        con.PreviousV0CC = null;
        con.boolCheckCCPeriod = null;
            
        con.init();
        //con.getPreviousCCData();
        con.getthisCCData();
        con.finalize_data();
        con.LoopSubbrand_data();
        con.FindMinMaxDate(system.today(), system.today().addDays(1), 'MAX');
        con.FindMinMaxDate(system.today(), system.today().addDays(1), 'MIN');
        con.checkUserID();
        con.checkApprover();
        con.SBGradeSorting(null);
        con.SBGradeSorting(1);
        con.SBGradeSorting(10);
        con.SBGradeSorting(100);
        con.SBGradeSorting(1000);
        
        con.checkFiscalYear(date.newInstance(2014,1,1), date.newInstance(2014,1,1));
        con.checkFiscalYear(date.newInstance(2014,1,1), date.newInstance(2014,7,1));
        con.checkFiscalYear(date.newInstance(2014,7,1), date.newInstance(2015,1,1));
        con.FindMinMaxDate(system.today(), system.today().addDays(1),'MAX');
        con.FindMinMaxDate(system.today(), system.today().addDays(1),'MIN');
        con.MonthDiff(null,null);
        con.FYConversion(date.newInstance(2014,7,1));
        con.FYConversion(date.newInstance(2014,1,1));
        delete ctis;
        
        //cts[1]
        scon = new ApexPages.StandardController(cts[1]);
        ApexPages.currentPage().getParameters().put('id', cts[1].Id);
        con = new ASI_CRM_CN_ContractEmailCtrl(scon);
        
        con.init();
        con.getPreviousCCData();
        con.getthisCCData();
        con.finalize_data();
        con.LoopSubbrand_data();
        con.FindMinMaxDate(system.today(), system.today().addDays(1), 'MAX');
        con.FindMinMaxDate(system.today(), system.today().addDays(1), 'MIN');
        con.checkUserID();
        con.checkApprover();
        con.SBGradeSorting(null);
        con.SBGradeSorting(1);
        con.SBGradeSorting(10);
        con.SBGradeSorting(100);
        con.SBGradeSorting(1000);

        con.checkFiscalYear(date.newInstance(2014,1,1), date.newInstance(2014,1,1));
        con.checkFiscalYear(date.newInstance(2014,1,1), date.newInstance(2014,7,1));
        con.checkFiscalYear(date.newInstance(2014,7,1), date.newInstance(2015,1,1));
        con.FindMinMaxDate(system.today(), system.today().addDays(1),'MAX');
        con.FindMinMaxDate(system.today(), system.today().addDays(1),'MIN');
        con.MonthDiff(null,null);
        con.FYConversion(date.newInstance(2014,7,1));
        con.FYConversion(date.newInstance(2014,1,1));
        
        test.stopTest();                
    }
    
    static testMethod void ASI_CRM_CN_ContractPONoAutoNumber_TEST() {
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST');
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-3), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Status__c='Final'));
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today(), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addDays(1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            Name = 'Contract2',
            ASI_TH_CRM_Promotion_Type__c='New Contract ON'));
        
        test.startTest();
        
        ASI_CRM_CN_ContractPONoAutoNumber a = new ASI_CRM_CN_ContractPONoAutoNumber();
        a.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, cts, null, null);
            
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Contract_BRSF_TriggerClass_TEST() {
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST');
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c (
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1);
        insert subBrand;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-3), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today(), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addDays(1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id));
        insert cts[1];
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        
        test.startTest();
        
        ASI_CRM_CN_Contract_BRSF_TriggerClass t = new ASI_CRM_CN_Contract_BRSF_TriggerClass();
        
        ASI_CRM_CN_Contract_BRSF_TriggerClass.routineBeforeUpsert(ctis, null);
        ASI_CRM_CN_Contract_BRSF_TriggerClass.routineAfterAll(ctis, null);
        ASI_CRM_CN_Contract_BRSF_TriggerClass.routineAfterDelete(ctis);
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST() {
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
        
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
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999', 
                                                RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];
        
        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        insert feedItems;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        //test.startTest();
        
        ASI_CRM_CN_Contract_Controller con;
        
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        
        con.POModification();
        con.UpdateContractRecord();
        con.setCustomerChannel();
        con.genGroupContractPicklist();
        con.genPromotionGroupContractPicklist();
        /*con.changeContractUpload();
        con.changeBusinessLicense();
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());

        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
                
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }
    

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_1() {
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
        
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
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999', 
                                                RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            ASI_CRM_CN_Group_Contract__c = cts[0].Id,
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];
        
        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        insert feedItems;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        //test.startTest();
        
        ASI_CRM_CN_Contract_Controller con;
        
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
    con.GroupContractChange();
        //Laputa remove  ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //Laputa remove  con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        
       //Laputa remove  con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        
        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();*/
       //Laputa remove  con.changeBusinessLicense();
       //Laputa remove  con.UpdateContractDetailRecord();
       //Laputa remove  con.GoURL();
        //Laputa remove  con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());

        /*con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
                
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_2() {
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
        
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999', 
                                                RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];
        
        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        insert feedItems;
        
        //20160920
        List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpSPList1 = new List<ASI_CRM_SpecialPromotionTypeSetting__c>();
        
        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
                                                                                                    , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
                                                                                                    , ASI_CRM_Override_BC_Rate__c = 1
                                                                                                    , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
                                                                                                    , ASI_CRM_Promotion_Type__c = 'Contract ON'
                                                                                                    , ASI_CRM_New_FY_Promotion_Type__c = TRUE
                                                                                                    , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
                                                                                                   );
        
        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList2 = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
                                                                                                    , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
                                                                                                    , ASI_CRM_Override_BC_Rate__c = 1
                                                                                                    , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
                                                                                                    , ASI_CRM_Promotion_Type__c = 'New Contract ON'
                                                                                                    , ASI_CRM_New_FY_Promotion_Type__c = FALSE
                                                                                                    , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
                                                                                                   );
        
        tmpSPList1.add(tmpSPList);
        tmpSPList1.add(tmpSPList2);
        
        insert tmpSPList1;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        //test.startTest();
        
        ASI_CRM_CN_Contract_Controller con;
        
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        //test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        
        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/
        
        //20160920 Ben @ Elufa
        con.ContractOutletListCopy = NULL;
        con.showReturn = FALSE;
        con.Selected = FALSE;
        con.BRSF_Item = NULL;
        con.recordtypeSelected = NULL;
        con.CoveredOutlet_Item = NULL;
        con.SelectOption = NULL;
        con.num = NULL;
        con.SChildCustomersIds = NULL;
        con.isNewFY = TRUE;
        con.DefaultBCRate = NULL;
        con.showSuggestedAmountAndTargetVolume = TRUE;
        con.showCN = TRUE;
        
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        //20160920
        con.isNewFY = FALSE;
    con.CheckSpecialPromotionType();
        //ASI_CRM_CN_Contract_Controller.findCitySObjects('ASI_CRM_City__c');
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_3() {
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
        
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999', 
                                                RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
      ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];
        
        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                                                     recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')
                                                     , ASI_CRM_CN_Outlet__c = a2s[1].id
                                                     , ASI_CRM_CN_Selected_Covered_Outlet__c = TRUE
                                                    ));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        insert feedItems;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        //test.startTest();
        
        ASI_CRM_CN_Contract_Controller con;
        
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        
        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());       
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        
        */        
        /*insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',
                                                ASI_CRM_CN_Paid_In_Progress__c=1,
                                                recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'));*/
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        con.changeContractUpload();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_4() {
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
        
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999', 
                                                RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Draft'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Last_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        //insert ctis;
        insert prs;
        //insert ccs;
        insert cos;
        insert atts;
        insert feedItems;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        test.startTest();

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        
        ASI_CRM_CN_Contract_Controller con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        con.restorePO();
        con.CheckSpecialPromotionType();
        con.GoReturn();
        con.calcBRSF_EstTotal();
        con.calcBRSF_ContractTotal();
        con.Addall_CoveredOutlet();
        con.changeBusinessLicense();
        test.stopTest();
    }
//-----------------------------------------------------------------------------
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_5() {
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
        
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
                                                       RecordTypeId=rtWS,
                                                       Name='TEST', 
                                                       ASI_CRM_CN_Image__c='Iconic',
                                                       ASI_CRM_CN_Chi_Name__c = 'a',//20170220 Elufa
                                                       ASI_CRM_CN_Eng_Name__c = 'e',
                                                       ASI_CRM_CN_CCity__c=city.Id,
                                                       ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
                                                       RecordTypeId=rtOutlet,
                                                       Name='TEST', 
                                                       ASI_CRM_CN_Chi_Name__c = 'b',//20170220 Elufa
                                                       ASI_CRM_CN_Eng_Name__c = 'f',
                                                       ASI_CRM_CN_Image__c='Iconic',
                                                       ASI_CRM_CN_CCity__c=city.Id,
                                                       ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
                                                       RecordTypeId=rtOutlet,
                                                       Name='TEST2', 
                                                       ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
                                                       ASI_CRM_CN_Eng_Name__c = 'g',
                                                       ASI_CRM_CN_Image__c='Iconic',
                                                       ASI_CRM_CN_CCity__c=city.Id,
                                                       ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id OR Id=:a2s[2].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999', 
                                                RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Expected_BRSF_Est_Total__c=12000,
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Expected_BRSF_Est_Total__c=12000,
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Final'
        ));
        insert cts[1];
        
        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=cts[1].Id,
                                                     recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')
                                                     , ASI_CRM_CN_Outlet__c = a2s[2].id
                                                     , ASI_CRM_CN_Selected_Covered_Outlet__c = TRUE
                                                    ));
        
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        insert feedItems;
        
        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
                                                                                                    , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
                                                                                                    , ASI_CRM_Override_BC_Rate__c = 1
                                                                                                    , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
                                                                                                    , ASI_CRM_Promotion_Type__c = 'New Contract ON'
                                                                                                   );
        
        insert tmpSPList;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        //test.startTest();
        
        ASI_CRM_CN_Contract_Controller con;
        
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        
        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
//        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        cos[2].ASI_CRM_CN_Selected_Covered_Outlet__c = FALSE;
        con.UpdateContractDetailRecord();
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }
//-----------------------------------------------------------------------------    
    
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_6() {
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
        
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
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
                                                       RecordTypeId=rtOutlet,
                                                       Name='TEST', 
                                                       ASI_CRM_CN_Image__c='Iconic',
                                                       ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
                                                       ASI_CRM_CN_Eng_Name__c = 'g',
                                                       ASI_CRM_CN_CCity__c=city.Id,
                                                       ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
                                                       RecordTypeId=rtOutlet,
                                                       Name='TEST', 
                                                       ASI_CRM_CN_Chi_Name__c = 'd',//20170220 Elufa
                                                       ASI_CRM_CN_Eng_Name__c = 'h',
                                                       ASI_CRM_CN_Image__c='Iconic',
                                                       ASI_CRM_CN_CCity__c=city.Id,
                                                       ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999', 
                                                RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Archived'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Archived'
        ));
        insert cts[1];
        
        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        insert feedItems;
        
        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
                                                                                                    , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
                                                                                                    , ASI_CRM_Override_BC_Rate__c = 1
                                                                                                    , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
                                                                                                    , ASI_CRM_Promotion_Type__c = 'New Contract ON'
                                                                                                   );
        
        insert tmpSPList;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        //test.startTest();
        
        ASI_CRM_CN_Contract_Controller con;
        
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        
        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
//        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_7() {
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON', ASI_CRM_For_Outlet__c = TRUE, recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'));
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
                                                       RecordTypeId=rtOutlet,
                                                       Name='TEST', 
                                                       ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
                                                       ASI_CRM_CN_Eng_Name__c = 'g',
                                                       ASI_CRM_CN_Image__c='Iconic',
                                                       ASI_CRM_CN_CCity__c=city.Id,
                                                       ASI_CRM_CN_NewChannel__c = channel.id,
                                                       ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
                                                       RecordTypeId=rtOutlet,
                                                       Name='TEST', 
                                                       ASI_CRM_CN_Chi_Name__c = 'e',//20170220 Elufa
                                                       ASI_CRM_CN_Eng_Name__c = 'h',
                                                       ASI_CRM_CN_Image__c='Iconic',
                                                       ASI_CRM_CN_CCity__c=city.Id,
                                                       ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999', 
                                                RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,
            ASI_TH_CRM_Promotion_Type__c='Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Submitted'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,
            ASI_TH_CRM_Promotion_Type__c='Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Submitted'
        ));
        insert cts[1];
        
        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        insert feedItems;
        
        //20160920
        List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpSPList1 = new List<ASI_CRM_SpecialPromotionTypeSetting__c>();
        
        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
                                                                                                    , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
                                                                                                    , ASI_CRM_Override_BC_Rate__c = 1
                                                                                                    , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
                                                                                                    , ASI_CRM_Promotion_Type__c = 'Contract ON'
                                                                                                    , ASI_CRM_New_FY_Promotion_Type__c = TRUE
                                                                                                    , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
                                                                                                   );
        
        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList2 = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
                                                                                                    , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
                                                                                                    , ASI_CRM_Override_BC_Rate__c = 1
                                                                                                    , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
                                                                                                    , ASI_CRM_Promotion_Type__c = 'New Contract ON'
                                                                                                    , ASI_CRM_New_FY_Promotion_Type__c = FALSE
                                                                                                    , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
                                                                                                   );
        
        tmpSPList1.add(tmpSPList);
        tmpSPList1.add(tmpSPList2);
        
        insert tmpSPList1;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        //test.startTest();
        
        ASI_CRM_CN_Contract_Controller con;
        
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        //test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        
        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/
        
        //20160920 Ben @ Elufa
        con.ContractOutletListCopy = NULL;
        con.showReturn = FALSE;
        con.Selected = FALSE;
        con.BRSF_Item = NULL;
        con.recordtypeSelected = NULL;
        con.CoveredOutlet_Item = NULL;
        con.SelectOption = NULL;
        con.num = NULL;
        con.SChildCustomersIds = NULL;
        con.isNewFY = TRUE;
        con.DefaultBCRate = NULL;
        con.showSuggestedAmountAndTargetVolume = TRUE;
        con.showCN = TRUE;
        
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        //20160920
        con.isNewFY = FALSE;
    con.CheckSpecialPromotionType();
        ASI_CRM_CN_Contract_Controller.findCitySObjects('ASI_CRM_City__c');
        con.ContractSelected.ASI_CRM_CN_Outlet_WS__c = a2s[0].id;
        con.setCustomerChannel();
        con.ContractSelected.ASI_CRM_CN_Outlet_WS__c = a2s[1].id;
        con.setCustomerChannel();
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }
    
//----------------------------------------------------------------------------------
    static testMethod void ASI_CRM_CN_Contract_TriggerClass_TEST() {
        
        Profile p = [SELECT Id FROM Profile where name = '系统管理员' or name = 'System Administrator']; 
        List<User> LUser = new List<User>();
        LUser.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ASI_CRM_Sales_Team__c = 'a',//20160914 Ben @ Elufa
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c1@testing123.com', CompanyName = 'Pernod Ricard China'));
        insert LUser[0];
        LUser.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ManagerID = LUser[0].id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c2@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));//20160914 Ben @ Elufa));
        insert LUser[1];
        
        update new User(Id=LUser[0].id, BypassTriggers__c='');
        //update new User(Id=UserInfo.getUserId(), BypassTriggers__c='');
        
        ASI_CRM_Dynamic_Approval_Route__c dar = new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Contract');
        insert dar;
        
        list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
        fars.add(new ASI_CRM_Fix_Approval_Route__c(  ASI_CRM_Sales_Team__c = 'a', ASI_CRM_CN_Approver_1__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_2__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_3__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_4__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_5__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_6__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approval_Limit_1__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_2__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_3__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_4__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_5__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_6__c = -999999
                                                   ,ASI_CRM_CN_Type__c = 'Contract 1st Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=-999999));
        fars.add(new ASI_CRM_Fix_Approval_Route__c(  ASI_CRM_Sales_Team__c = 'a', ASI_CRM_CN_Approver_1__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_2__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_3__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_4__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_5__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_6__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approval_Limit_1__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_2__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_3__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_4__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_5__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_6__c = -999999
                                                   , ASI_CRM_CN_Type__c = 'Contract 2nd Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=-999999));
        insert fars;
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', 
            RecordTypeId=rtWS,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id, 
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', 
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));

        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        insert new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='CRM',
            ASI_MFM_Country__c='CN',
            ASI_MFM_Base_Currency__c='RMB',
            ASI_MFM_Counter_Currency__c='USD',
            ASI_MFM_Effective_Date__c=system.today().addYears(-10),
            ASI_MFM_Exchange_Rate__c=1);
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c (
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1);
        insert subBrand;
        
        ASI_CRM_Contract_Cost_Setting__c ccs = new ASI_CRM_Contract_Cost_Setting__c(
            ASI_CRM_CN_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,
            ASI_CRM_CN_Variable_Cost_Contract__c=true);
        insert ccs;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c(
            ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(
            ASI_CRM_Promotion_Type__c = 'b');
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(
            ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,
            ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        ASI_TH_CRM_Contract__c ct0 = new ASI_TH_CRM_Contract__c(ownerId = LUser[0].id,
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Draft',
            ASI_CRM_CN_PO_Version__c='1.0',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c ct1 = new ASI_TH_CRM_Contract__c(ownerId = LUser[0].id,
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Draft',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_PO_Version__c='1.1',
            Name = 'Contract1',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');
        ASI_TH_CRM_Contract__c ct2 = new ASI_TH_CRM_Contract__c(ownerId = LUser[0].id,
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-6), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-5),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_PO_Version__c='1.0',
            Name = 'Contract2',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');
        cts.add(ct1);
        cts.add(ct2);
        insert cts;
        ASI_TH_CRM_Contract__c ct1a = ct1.clone();
        ct1a.Id = ct1.Id;
        ct1.ASI_CRM_CN_Status__c = 'Submitted';
        ct1a.ASI_CRM_CN_PO_Modification__c=true; 
        
        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> costs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            costs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            costs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        insert ctis;
        insert prs;
        insert costs;
        insert cos;
        insert atts;
        insert feedItems;
        
        list<ASI_TH_CRM_Contract__c> newList0 = new list<ASI_TH_CRM_Contract__c>();
        newList0.add(ct0);
        list<ASI_TH_CRM_Contract__c> newList1 = new list<ASI_TH_CRM_Contract__c>();
        newList1.add(ct1a);
        map<Id, ASI_TH_CRM_Contract__c> oldMap = new map<Id, ASI_TH_CRM_Contract__c>();
        oldMap.put(ct1.Id, ct1);
        
        test.startTest();
        
        ASI_CRM_CN_Contract_TriggerClass.routineBeforeUpsert(newList1,oldMap);
        ASI_CRM_CN_Contract_TriggerClass.routineAfterInsert(newList1);
        ASI_CRM_CN_Contract_TriggerClass.routineBeforeInsert(newList0);
        ASI_CRM_CN_Contract_TriggerClass.routineBeforeUpdate(newList1,oldMap);
        ASI_CRM_CN_Contract_TriggerClass.routineBeforeDelete(newList1);
        ASI_CRM_CN_Contract_TriggerClass.routineAfterAll(newList1,oldMap);
        ASI_CRM_CN_Contract_TriggerClass.routineAfterDelete(newList1);
        
        for(integer i=0; i<10; i++)
            ASI_CRM_CN_Contract_TriggerClass.setApproverByCount(ct0, i, LUser[0].id);
        
        for(integer i=0; i<10; i++)
            ASI_CRM_CN_Contract_TriggerClass.setReturnApproverByCount(ct0, i, LUser[0].id);
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Covered_Outlet_TriggerClass_TEST() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        insert new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='CRM',
            ASI_MFM_Country__c='CN',
            ASI_MFM_Base_Currency__c='RMB',
            ASI_MFM_Counter_Currency__c='USD',
            ASI_MFM_Effective_Date__c=system.today().addYears(-10),
            ASI_MFM_Exchange_Rate__c=1);
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c (
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1);
        insert subBrand;
        
        ASI_CRM_Contract_Cost_Setting__c ccs = new ASI_CRM_Contract_Cost_Setting__c(
            ASI_CRM_CN_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,
            ASI_CRM_CN_Variable_Cost_Contract__c=true);
        insert ccs;
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Draft',
            ASI_CRM_CN_PO_Version__c='1.0',
            Name = 'Contract1',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');
        insert ct;
        
        ASI_CRM_CN_Covered_Outlet__c co0 = new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet'));
        insert co0;
        ASI_CRM_CN_Covered_Outlet__c co1 = new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet'));
        list<ASI_CRM_CN_Covered_Outlet__c> newList = new list<ASI_CRM_CN_Covered_Outlet__c>();
        newList.add(co1);
        
        test.startTest();
        
        ASI_CRM_CN_Covered_Outlet_TriggerClass t = new ASI_CRM_CN_Covered_Outlet_TriggerClass();
        
        ASI_CRM_CN_Covered_Outlet_TriggerClass.routineBeforeUpdate(newList, null);
        ASI_CRM_CN_Covered_Outlet_TriggerClass.routineBeforeUpsert(newList, null);
            
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PSFForm_CTD_Ctrl_TEST() {
        
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
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
        }
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
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
        
        ASI_CRM_CN_PSFForm_CTD_Ctrl con0 = new ASI_CRM_CN_PSFForm_CTD_Ctrl();
        
        ApexPages.currentPage().getParameters().put('id', null);
        ASI_CRM_CN_PSFForm_CTD_Ctrl con = new ASI_CRM_CN_PSFForm_CTD_Ctrl(new ApexPages.StandardController(cts[1]));
        
        ApexPages.currentPage().getParameters().put('id', cts[1].Id);
        con = new ASI_CRM_CN_PSFForm_CTD_Ctrl(new ApexPages.StandardController(cts[1]));
        con.init();
        
        con.SBGradeSorting(null);
        con.SBGradeSorting(1);
        con.SBGradeSorting(10);
        con.SBGradeSorting(100);
        con.SBGradeSorting(1000);
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Competitor_Contract_TEST() {
        
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
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
        }
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
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
        
        
        test.startTest();
        ASI_CRM_Competitor_Contract__c compCont = new ASI_CRM_Competitor_Contract__c(Recordtypeid = Global_RecordTypeCache.getRtid('ASI_CRM_Competitor_Contract__cASI_CRM_CN_Competitor_Contract'), ASI_CRM_WS_Outlet__c = a2s[0].id); 
        insert compCont;
        update compCont;
      
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_ReturnContractByBACtrl_TEST() {
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
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
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
        }
        insert subBrands;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
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
        
        ApexPages.currentPage().getParameters().put('id', cts[1].Id);
        ASI_CRM_CN_ReturnContractByBACtrl con = new ASI_CRM_CN_ReturnContractByBACtrl(new ApexPages.StandardController(cts[1]));
        
        test.startTest();
        con.cancel();
        con.doApprove();
        test.stopTest();
    }

}