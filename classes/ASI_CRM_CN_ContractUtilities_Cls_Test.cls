@isTest(seealldata=false)
public class ASI_CRM_CN_ContractUtilities_Cls_Test{
    testmethod static void Test1(){                                                
        //ASI_CRM_CN_ContractUtilities_Cls.ContractSummary newitem = ASI_CRM_CN_ContractUtilities_Cls.getSubbrandVolume('a8cM00000004EyiIAE');
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
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
        Id rtCoveredOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtOutlet,
            Name='TEST2', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;

        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(+3), 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
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
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false
        );
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
            ASI_MFM_Active_for_CRM__c=true,
            ASI_MFM_Brand__c=brand.Id
        );
        insert subBrand;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c =1,
            RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item'),
            ASI_CRM_CN_Sub_Brand__c=subBrand.Id
        ));
        insert ctis;
        
        //Added by Twinkle 20141117
        List<ASI_CRM_CN_Covered_Outlet__c> lstCO = new List<ASI_CRM_CN_Covered_Outlet__c >();
        lstCO.add(new ASI_CRM_CN_Covered_Outlet__c(
        RecordTypeId = rtCoveredOutlet,
        ASI_CRM_CN_Contract__c=ct.id,
        ASI_CRM_CN_Outlet__c=a2s[0].id));
        insert lstCO;
        
        List<ASI_CRM_Subbrand_Volume__c> lstSBVol = new List<ASI_CRM_Subbrand_Volume__c>();
        lstSBVol.add(new ASI_CRM_Subbrand_Volume__c(
            ASI_CRM_Subbrand__c=subBrand.Id,
            ASI_CRM_End_Date__c=system.today().addMonths(-2),
            ASI_CRM_Account__c=a2s[0].id,
            ASI_CRM_T1_Depletion_BTL__c=10,
            ASI_CRM_T2_Depletion_BTL__c=10,
            ASI_CRM_PR_Direct_BTL__c=10,
            ASI_CRM_T1_Depletion_STD__c=10,
            ASI_CRM_T2_Depletion_STD__c=10,
            ASI_CRM_PR_Direct_STD__c=10,
            ASI_CRM_T1_Depletion_CR12__c=10,
            ASI_CRM_T2_Depletion_CR12__c=10,
            ASI_CRM_PR_Direct_CR12__c=10,
            ASI_CRM_T1_Depletion__c=10,
            ASI_CRM_T2_Depletion__c=10,
            ASI_CRM_PR_Direct__c=10));
        lstSBVol.add(new ASI_CRM_Subbrand_Volume__c(
            ASI_CRM_Subbrand__c=subBrand.Id,
            ASI_CRM_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_Account__c=a2s[0].id));
        insert lstSBVol;
        
        Date d = system.today().addMonths(-2);
        String strYear = String.valueOf(d.year());
        Decimal strMonth = Decimal.valueOf(d.Month());
        
        List<ASI_CRM_CM_GS__c> lstGS = new List<ASI_CRM_CM_GS__c>();
        lstGS.add(new ASI_CRM_CM_GS__c(
        ASI_CRM_Region__c=region.Id,
        ASI_CRM_YEAR__c=strYear,
        ASI_CRM_CN_Month__c=strMonth,
        ASI_CRM_TYPE__c='YTD CM',
        ASI_CRM_PRODUCTCODE__c=subBrand.Id));
        
        d = system.today().addMonths(-1);
        strMonth = Decimal.valueOf(d.Month());  
        lstGS.add(new ASI_CRM_CM_GS__c(
        ASI_CRM_Region__c=region.Id,
        ASI_CRM_YEAR__c=strYear,
        ASI_CRM_CN_Month__c=strMonth,
        ASI_CRM_TYPE__c='YTD GS',
        ASI_CRM_PRODUCTCODE__c=subBrand.Id));
        
        d = system.today().addYears(-1);
        strYear = String.valueOf(d.Year());        
        lstGS.add(new ASI_CRM_CM_GS__c(
        ASI_CRM_Region__c=region.Id,
        ASI_CRM_YEAR__c=strYear,
        ASI_CRM_CN_Month__c=6,
        ASI_CRM_TYPE__c='Budget CM',
        ASI_CRM_PRODUCTCODE__c=subBrand.Id));
        
        d = system.today();
        strYear = String.valueOf(d.Year());
        lstGS.add(new ASI_CRM_CM_GS__c(
        ASI_CRM_Region__c=region.Id,
        ASI_CRM_YEAR__c=strYear,
        ASI_CRM_CN_Month__c=6,
        ASI_CRM_TYPE__c='Budget GS',
        ASI_CRM_PRODUCTCODE__c=subBrand.Id));
        
        insert lstGS;
        
        test.startTest();
        ASI_CRM_CN_ContractUtilities_Cls.ContractSummary returnSummary = new ASI_CRM_CN_ContractUtilities_Cls.ContractSummary(); 
        returnSummary.totalExpense = 10;
        returnSummary.strProrateCR12 = 10;
        returnSummary.strTotalCMVol = 10;
        returnSummary.strCutOffPeriod = 10;
        returnSummary.strContractPeriod = 10;
        returnSummary.MarginAP = 10;
        returnSummary.strTotalStdBtl = 10;
        
        returnSummary.AddTotalStdBtl(10);
        returnSummary.AddvarExpense(10);
        returnSummary.AddfixExpense(10);
        
        returnSummary.getFixExpRate();
        returnSummary.getTotalInvestperBtl();       
        returnSummary.getROIvalue();
        returnSummary.getMarginBottle();
        returnSummary.getMonthDiff();
        
        ASI_CRM_CN_ContractUtilities_Cls.VariableExpensesTable returnExpenses = new ASI_CRM_CN_ContractUtilities_Cls.VariableExpensesTable();
        returnExpenses.AddHCQty(10);
        returnExpenses.AddEstimateQty(10);
        returnExpenses.AddContractQty(10);
        
        returnExpenses = new ASI_CRM_CN_ContractUtilities_Cls.VariableExpensesTable('a','a',ct.id,1,1,1,1,1,1,1);
        
        ASI_CRM_CN_ContractUtilities_Cls.MarginTable returnMargin = new ASI_CRM_CN_ContractUtilities_Cls.MarginTable();
        
        Set<id> setTestingId = new Set<id>();
        setTestingId.add(ct.id);
        ASI_CRM_CN_ContractUtilities_Cls.checkFYDayPeriod_MarginTable(date.today(), date.today(), setTestingId);
        
        ASI_CRM_CN_ContractUtilities_Cls.FYConversion(Date.newInstance(2014, 10, 10));
        ASI_CRM_CN_ContractUtilities_Cls.FYConversion(Date.newInstance(2014, 01, 01));
        ASI_CRM_CN_ContractUtilities_Cls.FYConversion(null);
        
        ASI_CRM_CN_ContractUtilities_Cls.checkFYDayPeriod(Date.newInstance(2014, 10, 10),Date.newInstance(2014, 10, 10),setTestingId);
        ASI_CRM_CN_ContractUtilities_Cls.checkFYDayPeriod(Date.newInstance(2014, 01, 01),Date.newInstance(2014, 01, 01),setTestingId);
        
        ASI_CRM_CN_ContractUtilities_Cls.QueryContract(ct.id);
        ASI_CRM_CN_ContractUtilities_Cls.getContractBRSFbyContract(ct);
        ASI_CRM_CN_ContractUtilities_Cls.getSubbrandVolumebyContract(ct);       
        
        Set<Id> setID = new Set<Id>();
        setID.add(ct.id);        
        ASI_CRM_CN_ContractUtilities_Cls.checkFYDayPeriod(system.today(), system.today(), setID);
        
        ASI_CRM_CN_ContractUtilities_Cls.SBGradeSorting(10);
        test.stopTest();  
    }
    
}