@isTest (SeeAllData=false)
public class ASI_CRM_CN_PreContract_Test {

    static testMethod void ASI_CRM_CN_PreContractEval_Ctrl_TEST() {
        
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
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id
        	,ASI_CRM_CN_Commercial_Team__c='Prestige'));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id
        	,ASI_CRM_CN_Commercial_Team__c='Prestige'));
        insert a2s;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false
        );
        insert brand;
        
        List<ASI_MFM_Sub_brand__c> subBrands = new List<ASI_MFM_Sub_brand__c>();

        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
            ASI_MFM_Active_for_CRM__c=true,
            ASI_MFM_Brand__c=brand.Id
        );
        subBrands.add(subBrand);

        subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_MFM_Brand__c=brand.Id));
        insert subBrands;

        ASI_TH_CRM_Contract__c ct2 = new ASI_TH_CRM_Contract__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON');
        
        Insert ct2;
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c = ct2.id
        );
        
        insert ct;
        
        list<ASI_CRM_Contract_Cost__c> costs = new list<ASI_CRM_Contract_Cost__c>();
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Estimate_Amount__c=1));
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Estimate_Amount__c=1));
        //20161020 Ben @ Elufa
        
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=ct2.Id,
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Estimate_Amount__c=1));
        
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=ct2.Id,
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Estimate_Amount__c=1));
        
        //20161020 End
        insert costs;
        
        insert new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id, ASI_CRM_CN_Outlet__c=a2s[1].Id, RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet'));
        insert new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct2.Id, ASI_CRM_CN_Outlet__c=a2s[1].Id, RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet'));
        
        insert new ASI_CRM_Subbrand_Volume__c(
            ASI_CRM_Account__c=a2s[1].Id,
            ASI_CRM_Subbrand__c=subBrand.Id,
            ASI_CRM_End_Date__c=system.today().addMonths(-2));
        
        insert new ASI_CRM_Subbrand_Volume__c(
            ASI_CRM_Account__c=a2s[1].Id,
            ASI_CRM_Subbrand__c=subBrand.Id,
            ASI_CRM_End_Date__c=system.today().addMonths(-4));
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item'),
            ASI_CRM_CN_Sub_Brand__c=subBrand.Id
        ));
        
        //20161020 Ben @ Elufa
        
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct2.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item'),
            ASI_CRM_CN_Sub_Brand__c=subBrand.Id
        ));
        
        //20161020 End
        insert ctis;
    
        ASI_CRM_PreContractEval__c pc = new ASI_CRM_PreContractEval__c(
            ASI_CRM_Start_Date__c=system.today(),
            ASI_CRM_End_Date__c=system.today().addYears(1),
            ASI_CRM_CN_Last_Contract__c=ct.Id);
        insert pc;

        ASI_CRM_Pre_Contract_Sub_Brand__c csb = new ASI_CRM_Pre_Contract_Sub_Brand__c(
            ASI_CRM_Pre_Contract_Eval__c=pc.Id,
            ASI_CRM_Sub_Brand__c=subBrand.Id
        );
        insert csb;

        ASI_CRM_CN_Channel_Strategy__c cs = new ASI_CRM_CN_Channel_Strategy__c(
            ASI_CRM_CN_Fiscal_Year__c = ASI_CRM_CN_Function.getFiscalYear(system.today()),
            ASI_CRM_CN_Image__c = a2s[1].ASI_CRM_CN_Image__c,
            ASI_CRM_CN_Sub_Channel__c=a2s[1].ASI_CRM_CN_Sub_Channel__c,
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_Strategy_Type__c = 'National Strategy');
        insert cs;
        
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> csis = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(
            ASI_CRM_CN_Channel_Strategy__c=cs.Id,
            RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy'),
            ASI_CRM_CN_Brand__c='Priority 1'));
        csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(
            ASI_CRM_CN_Channel_Strategy__c=cs.Id,
            RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy'),
            ASI_CRM_CN_Brand__c='Priority 2'));
        insert csis;
        
        // list<ASI_CRM_CM_GS__c> cgs = new list<ASI_CRM_CM_GS__c>();
        // cgs.add(new ASI_CRM_CM_GS__c(
        //     ASI_CRM_PRODUCTCODE__c=subBrand.Id,
        //     ASI_CRM_Region__c=region.Id,
        //     ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
        //     ASI_CRM_CN_Month__c=system.today().month(),
        //     ASI_CRM_TYPE__c='Budget CM'
        // ));
        // cgs.add(new ASI_CRM_CM_GS__c(
        //     ASI_CRM_PRODUCTCODE__c=subBrand.Id,
        //     ASI_CRM_Region__c=region.Id,
        //     ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
        //     ASI_CRM_CN_Month__c=system.today().month(),
        //     ASI_CRM_TYPE__c='YTD CM'
        // ));        
        // insert cgs;
        Date PO_Start_Date = Pc.ASI_CRM_Start_Date__c;
        List<ASI_CRM_CM_GS__c> CMGSDataList= new List<ASI_CRM_CM_GS__c>();
        for(ASI_MFM_Sub_brand__c subBrand1 :subBrands) {
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget GS',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD GS',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD CM',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget CM',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD CM',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD GS',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Actual_CM_GS')));
            
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD A&D',
                                                  ASI_CRM_VERSION__c=0,ASI_CRM_CN_Month__c=PO_Start_Date.month(),
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='Budget A&D',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()+1),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
            CMGSDataList.add(new ASI_CRM_CM_GS__c(ASI_CRM_PRODUCTCODE__c=subBrand1.Id,ASI_CRM_CM_GS_per_9L__c= Math.random()*1000,
                                                  ASI_CRM_Region__c=region.Id,ASI_CRM_TYPE__c='YTD A&D',
                                                  ASI_CRM_VERSION__c=1,ASI_CRM_CN_Month__c=6,
                                                  ASI_CRM_YEAR__c=string.valueOf(PO_Start_Date.year()),RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CM_GS__cASI_CRM_CN_Competitor_CM_GS')));
        }
        insert CMGSDataList;
        
        test.startTest();
        
        ASI_CRM_CN_PreContractEval_Ctrl.Row row = new ASI_CRM_CN_PreContractEval_Ctrl.Row(0, new ASI_CRM_Pre_Contract_Sub_Brand__c());
        row.EstBtlMonth = row.EstBtlMonth;
        row.BtlIncentive = row.BtlIncentive;
        
        ASI_CRM_CN_PreContractEval_Ctrl con = new ASI_CRM_CN_PreContractEval_Ctrl(new ApexPages.StandardController(pc));
        con.RunEditData();
        
        ApexPages.currentPage().getParameters().put('id', pc.Id);
        ApexPages.currentPage().getParameters().put('OutletId', a2s[1].Id);
        ApexPages.currentPage().getParameters().put('cn', '1');
        con = new ASI_CRM_CN_PreContractEval_Ctrl(new ApexPages.StandardController(pc));
        
        //20161020
        con.NoMonths = 12;
        con.TestInt = Null;
        con.TestStr = Null;
        con.VolumeOption = Null;
        con.showEdit = false;
        con.MonthsPeriod = Null;
        con.POEndtillNow = Null;
        con.POStarttillNow = Null;
        con.sb_chiname = Null;
        ASI_CRM_CN_PreContractEval_Ctrl.SubBrandProrate a = new ASI_CRM_CN_PreContractEval_Ctrl.SubBrandProrate();
        a.strDate = Null;
        con.PC = pc;
        con.strCutOffDay = 16;
        //20161020
        
        con.chooseLocale();
        con.checkUserID();
        con.showCN = true;
        con.Init_Data();
        con.RunEditData();
        con.NoOfCoveredOutlet = con.NoOfCoveredOutlet;
        con.FixedExpense = con.FixedExpense;
        con.PromotionServiceFee = con.PromotionServiceFee;
        con.getLastPO();
        con.refreshSBPriority();
        con.refreshBottleIncentive();
        //con.refreshSBGrade();
        //con.refreshBtlAmount();
        con.getSBGrade();
        con.AddNew();
        con.RemoveRow();
        con.AddNew();
        
        con.SaveAll();
        
        for(ASI_CRM_CN_PreContractEval_Ctrl.Row r: con.Rows) {
            r.Record.ASI_CRM_Sub_Brand__c=subBrand.Id;
            r.Record.ASI_CRM_Estimated_Btl_Month__c=1;
            r.Record.ASI_CRM_Bottle_Incentive__c=1;
        }
        con.SaveAll();
        
        con.view();
        con.ViewPageInitAction();//20161019 Ben @ Elufa
        con.getLastPO();//20161019
        
        pc.ASI_CRM_CN_Last_Contract__c=ct.Id;
        update pc;
        pc = [SELECT name, id, ASI_CRM_No_of_Months__c, ASI_CRM_Bottle_Incentive_Total__c, 
                      ASI_CRM_Variable_Event_Cost__c, ASI_CRM_Promotion_Service_Fee__c,
                      ASI_CRM_CN_Budget_Version__c, ASI_CRM_Contract_Total__c, ASI_CRM_CN_Last_Contract__c,
                      ASI_CRM_Variable_Cost__c, ASI_CRM_CN_Outlet__c,ASI_CRM_No_of_covered_outlet__c,
                      ASI_CRM_Fixed_Expense__c, ASI_CRM_Start_Date__c, ASI_CRM_End_Date__c, 
                      ASI_CRM_CN_Outlet__r.Name, ASI_CRM_Status__c, ASI_CRM_Monthly_Contract_Total_Vol_9LC__c, 
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,ASI_CRM_CN_Outlet__r.RecordType.DeveloperName,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, 
                      ASI_CRM_City__c,ASI_CRM_CN_Sub_Channel_Chi_Name__c,OwnerId,
                      ASI_CRM_Area__c, ASI_CRM_Image__c, ASI_CRM_OutletChannel__c,
                      ASI_CRM_Investment_per_Equiv_Chivas_12Y__c, CreatedDate, ASI_CRM_CN_VS_Total_APGS__c,
                      ASI_CRM_CN_Total_APGS__c, ASI_CRM_CN_Total_APGS_Aligned__c, ASI_CRM_CN_Last_Contract_TotalAPGS__c, ASI_CRM_CN_Total_Volume_9L__c
                      //20160929, added by Leo
                      ,ASI_CRM_CN_Last_V0_Contract_TradeExpense__c,ASI_CRM_CN_Last_V0_Contract_Volume_Total__c,ASI_CRM_CN_Last_V0_Contract_VarExpense__c
                      ,ASI_CRM_CN_Last_V0_Contract_FixedExpense__c,ASI_CRM_CN_Last_V0_Contract_FixExp_Rate__c,ASI_CRM_CN_Last_V0_Contract_Total_APGS__c
                      ,ASI_CRM_CN_Last_V0_Contract_InvestCR12__c,ASI_CRM_CN_Last_V0_Contract_ROI__c
                      ,ASI_CRM_CN_Last_V0_Contract_Pro_FormaROI__c
                      ,ASI_CRM_CN_Monthly_Volume__c
                      ,ASI_CRM_CN_Outlet__r.ASI_CRM_CN_NewChannel__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,
                      ASI_CRM_CN_Outlet__r.ASI_CRM_CN_New_Image__c

                      //20160929, added by Leo
                      from ASI_CRM_PreContractEval__c WHERE id = :pc.Id];
        con.PC = pc;
        con.LastPO = ct;
        
        con.CalculatePC();
        con.CalculateAlign('',0);
        con.Share();
        con.shareChatter();
        con.CutOffDate(1);
        con.checkFYDate(system.today());
        con.FYConversion(system.today());
        con.MainCancel();
        ASI_CRM_CN_PreContractEval_Ctrl.findSObjects('Account','TEST','');

        //--- edit by leo @2014/08/08 ---
        con.DelItems.add(csb);
        con.SaveAll();
        con.CutOffDate(0);
        con.checkFYDate(null);
        con.FYConversion(Date.newinstance(2014,4,30));
        con.checkFYDayPeriod(null, null);

        User u = new User(Alias = 'test001', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='TESTUSER001', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId=UserInfo.getProfileId(),TimeZoneSidKey='America/Los_Angeles', UserName='standarduser001@testorg.com');
        u.Username = 'test'+System.currentTimeMillis()+'@testorg.com';
        insert u;

        currentUser.Managerid = u.Id;
        update currentUser;
        con.shareChatter();
        con.Share();
        
        //20161019 Ben @ Elufa
        //pc.ASI_CRM_CN_Last_Contract__c = ct.id;
        //Update pc;
        //con.getLastPO();
        con.hasV0 = TRUE;
        con.v0Contract = ct2.id;
        con.v0StartD = ct2.ASI_CRM_CN_PO_Start_Date__c;
        con.v0EndD = ct2.ASI_CRM_CN_PO_End_Date__c;
        con.CalculateV0PC();
            
        con.Copy();

        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_PreContractEvalEdit_Ctrl_TEST() {
     
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
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id
        	,ASI_CRM_CN_Commercial_Team__c='Prestige'));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id
        	,ASI_CRM_CN_Commercial_Team__c='Prestige'));
        insert a2s;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false
        );
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(
            Name='TEST',
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
            ASI_MFM_Active_for_CRM__c=true,
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1);
        insert subBrand;
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_TH_CRM_Start_Date__c=system.today().addMonths(-2), 
            ASI_TH_CRM_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Modification__c=true
            //ASI_CRM_CN_Status__c = 'Final'//20161124 Elufa
        );
        insert ct;
        
        list<ASI_CRM_Contract_Cost__c> costs = new list<ASI_CRM_Contract_Cost__c>();
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Estimate_Amount__c=1));
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Estimate_Amount__c=1));
        insert costs;
        
        insert new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id, ASI_CRM_CN_Outlet__c=a2s[1].Id, RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet'));
        
        insert new ASI_CRM_Subbrand_Volume__c(
            ASI_CRM_Account__c=a2s[1].Id,
            ASI_CRM_Subbrand__c=subBrand.Id,
            ASI_CRM_End_Date__c=system.today().addMonths(-2),
            ASI_CRM_Year__c=string.valueOf(system.today().year()),
            ASI_CRM_Offtake__c=1);
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item'),
            ASI_CRM_CN_Sub_Brand__c=subBrand.Id
        ));
        insert ctis;
    
        insert new ASI_CRM_CN_PreContract_AlignSetting__c(
            ASI_CRM_CN_Division__c=division.Id,
            ASI_CRM_CN_On_Off__c=channel.ASI_CRM_CN_On_Off__c,
            ASI_CRM_CN_Align__c='10000',
            ASI_CRM_CN_Type__c='Investment per CR12 eq btl');
                
        ASI_CRM_PreContractEval__c pc = new ASI_CRM_PreContractEval__c(
            ASI_CRM_Start_Date__c=system.today(),
            ASI_CRM_End_Date__c=system.today().addYears(1),
            ASI_CRM_CN_Last_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[1].Id,
            ASI_CRM_Variable_Cost__c=0);
        insert pc;

        ASI_CRM_Pre_Contract_Sub_Brand__c csb = new ASI_CRM_Pre_Contract_Sub_Brand__c(
            ASI_CRM_Pre_Contract_Eval__c=pc.Id,
            ASI_CRM_Sub_Brand__c=subBrand.Id,
            ASI_CRM_Estimated_Btl_Month__c=1
        );
        insert csb;

        ASI_CRM_CN_Channel_Strategy__c cs = new ASI_CRM_CN_Channel_Strategy__c(
            ASI_CRM_CN_Fiscal_Year__c = ASI_CRM_CN_Function.getFiscalYear(system.today()),
            ASI_CRM_CN_Image__c = a2s[1].ASI_CRM_CN_Image__c,
            ASI_CRM_CN_Sub_Channel__c=a2s[1].ASI_CRM_CN_Sub_Channel__c,
            ASI_CRM_CN_Area__c=area.Id,
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_Strategy_Type__c = 'National Strategy');
        insert cs;
        
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> csis = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(
            ASI_CRM_CN_Channel_Strategy__c=cs.Id,
            RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy'),
            ASI_CRM_CN_Brand__c='Priority 1'));
        csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(
            ASI_CRM_CN_Channel_Strategy__c=cs.Id,
            RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy'),
            ASI_CRM_CN_Brand__c='Priority 2'));
        insert csis;
        
        list<ASI_CRM_CM_GS__c> cgs = new list<ASI_CRM_CM_GS__c>();
        cgs.add(new ASI_CRM_CM_GS__c(
            ASI_CRM_PRODUCTCODE__c=subBrand.Id,
            ASI_CRM_Region__c=region.Id,
            ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
            ASI_CRM_CN_Month__c=system.today().month(),
            ASI_CRM_TYPE__c='Budget CM',
            ASI_CRM_CM_GS_per_9L__c=1));
        insert cgs;
        
        ASI_CRM_CN_PreContractEvalEdit_Ctrl con;
            
        test.startTest();
        
        con = new ASI_CRM_CN_PreContractEvalEdit_Ctrl(new ApexPages.StandardController(pc));
        
        ApexPages.currentPage().getParameters().put('id', pc.Id);
        ApexPages.currentPage().getParameters().put('OutletId', a2s[1].Id);
        //20161124
        ct.ASI_CRM_CN_Status__c = 'Final';
        update ct;
        
        con = new ASI_CRM_CN_PreContractEvalEdit_Ctrl(new ApexPages.StandardController(pc));
        //20161019 Ben @ Elufa
        con.LPreContract = NULL;
        con.OutletInfoList = NULL;
        con.ListLastPO = NULL;
        con.LastPO = NULL;
        con.ListSBVolumeFilter = NULL;
        con.strNewFixedCost = NULL;
        con.strOldExpenses = NULL;
        con.strExpensesRate = NULL;
        con.strVcostRate = NULL;
        con.strFcostRate = NULL;
        con.strROIRate = NULL;
        con.strVolumeRate = NULL;
        con.strCR12Rate = NULL;
        con.strFEAlign = NULL;
        con.strVEAlign = NULL;
        con.strTEAlign = NULL;
        con.strVOAlign = NULL;
        //20161019 End
        con.getSubBrandLineItemsMap();
        con.getActualCMGS(new set<Id>(new Id[]{subBrand.Id}));
        con.getBudgetCMGS(new set<Id>(new Id[]{subBrand.Id}));
        con.checkLastPO();
        con.getChannelStrategy(date.newInstance(system.today().year(), 1, 2));
        con.getChannelStrategy(date.newInstance(system.today().year(), 7, 1));
        con.getChannelStrategySingleYear(system.today());
        con.Result();
        con.getLastContractVolume();
        con.GetSubBrandVolumeData('Investment');
        con.GetSubBrandVolumeData('ROI');
        con.CalculationROI('LastContract');
        con.CalculationROI('PC');
        con.Calculation1('LastContract');
        con.Calculation1('PC');
        con.hideResult();
        con.AddNew();
        con.SaveAll();
        con.CancelPC();
        con.BackPC();
        con.EditPC();
//        con.SaveAndShare();
//        con.Share();
        con.SaveAsNew();
        con.SaveEval();
        con.RemoveRow();
        //20161124 Elufa
        
        ASI_CRM_CN_PreContractEvalEdit_Ctrl.Evaluation_Result a = new ASI_CRM_CN_PreContractEvalEdit_Ctrl.Evaluation_Result();
        a.EValuation_Result = Null;
        a.name = Null;
        a.Result = Null;
        a.Align = Null;
        a.lastcontract = Null;
        //20161124 End
        
        ASI_CRM_CN_PreContractEvalEdit_Ctrl.findSObjects(null, 'TEST', null);

        test.stopTest();
        
    }

    static testMethod void ASI_CRM_CN_PreContractEvalMain_Ctrl_TEST() {
     
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
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id
        	,ASI_CRM_CN_Commercial_Team__c='Prestige'));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id
        	,ASI_CRM_CN_Commercial_Team__c='Prestige'));
        insert a2s;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false
        );
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
            ASI_MFM_Active_for_CRM__c=true,
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1);
        insert subBrand;
        
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_TH_CRM_Start_Date__c=system.today().addMonths(-2), 
            ASI_TH_CRM_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Modification__c=true);
        insert ct;
        
        list<ASI_CRM_Contract_Cost__c> costs = new list<ASI_CRM_Contract_Cost__c>();
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Cost_Type__c='Fixed',
            ASI_CRM_CN_Estimate_Amount__c=1));
        costs.add(new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Cost_Type__c='Variable',
            ASI_CRM_CN_Estimate_Amount__c=1));
        insert costs;
        
        insert new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id, ASI_CRM_CN_Outlet__c=a2s[1].Id, RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet'));
        
        insert new ASI_CRM_Subbrand_Volume__c(
            ASI_CRM_Account__c=a2s[1].Id,
            ASI_CRM_Subbrand__c=subBrand.Id,
            ASI_CRM_End_Date__c=system.today().addMonths(-2),
            ASI_CRM_Year__c=string.valueOf(system.today().year()),
            ASI_CRM_Offtake__c=1);
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item'),
            ASI_CRM_CN_Sub_Brand__c=subBrand.Id
        ));
        insert ctis;
    
        insert new ASI_CRM_CN_PreContract_AlignSetting__c(
            ASI_CRM_CN_Division__c=division.Id,
            ASI_CRM_CN_On_Off__c=channel.ASI_CRM_CN_On_Off__c,
            ASI_CRM_CN_Align__c='10000',
            ASI_CRM_CN_Type__c='Investment per CR12 eq btl');
                
        ASI_CRM_PreContractEval__c pc = new ASI_CRM_PreContractEval__c(
            ASI_CRM_Start_Date__c=system.today(),
            ASI_CRM_End_Date__c=system.today().addYears(1),
            ASI_CRM_CN_Last_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[1].Id,
            ASI_CRM_Variable_Cost__c=1);
        insert pc;

        ASI_CRM_Pre_Contract_Sub_Brand__c csb = new ASI_CRM_Pre_Contract_Sub_Brand__c(
            ASI_CRM_Pre_Contract_Eval__c=pc.Id,
            ASI_CRM_Sub_Brand__c=subBrand.Id,
            ASI_CRM_Estimated_Btl_Month__c=1
        );
        insert csb;

        ASI_CRM_CN_Channel_Strategy__c cs = new ASI_CRM_CN_Channel_Strategy__c(
            ASI_CRM_CN_Fiscal_Year__c = ASI_CRM_CN_Function.getFiscalYear(system.today()),
            ASI_CRM_CN_Image__c = a2s[1].ASI_CRM_CN_Image__c,
            ASI_CRM_CN_Sub_Channel__c=a2s[1].ASI_CRM_CN_Sub_Channel__c,
            ASI_CRM_CN_Area__c=area.Id,
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_Strategy_Type__c = 'National Strategy');
        insert cs;
        
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> csis = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(
            ASI_CRM_CN_Channel_Strategy__c=cs.Id,
            RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy'),
            ASI_CRM_CN_Brand__c='Priority 1'));
        csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(
            ASI_CRM_CN_Channel_Strategy__c=cs.Id,
            RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy'),
            ASI_CRM_CN_Brand__c='Priority 2'));
        insert csis;
        
        list<ASI_CRM_CM_GS__c> cgs = new list<ASI_CRM_CM_GS__c>();
        cgs.add(new ASI_CRM_CM_GS__c(
            ASI_CRM_PRODUCTCODE__c=subBrand.Id,
            ASI_CRM_Region__c=region.Id,
            ASI_CRM_YEAR__c=string.valueOf(system.today().year()),
            ASI_CRM_CN_Month__c=system.today().month(),
            ASI_CRM_TYPE__c='Budget CM',
            ASI_CRM_CM_GS_per_9L__c=1));
        insert cgs;
            
        test.startTest();
        
        ASI_CRM_CN_PreContractEvalMain_Ctrl con = new ASI_CRM_CN_PreContractEvalMain_Ctrl(new ApexPages.StandardController(pc));
        con.init2();
        con.getStatusItems();
        List<SelectOption> sos = con.SupplierList;
        con.changeStatus();
        con.StatusSelected='1';
        con.Beginning();
        con.Next();
        con.End();
        con.Previous();
        con.StatusSelected='2';
        con.Beginning();
        con.Next();
        con.End();
        con.Previous();
        con.getDisablePrevious();
        con.getDisableNext();
        con.getTotal_size();
        con.getPageNumber();
        con.getTotalPages();
        con.getStartIndex();
        con.getEndIndex();
        con.deletePreContract();
        con.Create();

        con = new ASI_CRM_CN_PreContractEvalMain_Ctrl(new ApexPages.StandardController(pc));
        con.Create();
        
        test.stopTest();
     
    }    
    
}