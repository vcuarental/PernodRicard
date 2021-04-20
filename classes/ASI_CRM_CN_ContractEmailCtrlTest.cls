@isTest (SeeAllData=false)
public class ASI_CRM_CN_ContractEmailCtrlTest {
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
                ASI_CRM_CN_Contract__c=cts[0].Id,
                ASI_CRM_Year__c = String.valueof(PO_Start_Date.Year()),    
                ASI_CRM_Month__c =String.valueof(PO_Start_Date.month()), 
                ASI_CRM_End_Date__c=PO_Start_Date, 
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Subbrand_Volume__cASI_CRM_CN_WS_Outlet_Sub_brand_Volume'),
                ASI_CRM_CN_Exclude_From_Payment_Volume__c = false
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
        lstAppComment.add(new ASI_CRM_Approval_Comment__c(RecordTypeId=rtAppC1,ASI_CRM_Contract__c=cts[1].id,ASI_CRM_BA_comments__c='“测试”@_——This contract will expire in Jun.2017. During our renewal negotiation, MHD provide an offer with 4.3M(3,000btl/monthly, rough ROI:1.9) and want to grab it. Finally we defeat MHD and successfully safeguard this outlet, but we need to increase 350k of fix cost as the compensation to the outlet.'));
        lstAppComment.add(new ASI_CRM_Approval_Comment__c(RecordTypeId=rtAppC2,ASI_CRM_Contract__c=cts[1].id,ASI_CRM_BA_comments__c=''));
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
            
            con.strPDF='1';
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
            test.stopTest();   
        }
    }
}