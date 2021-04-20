/* Filename:    ASI_CRM_CN_HeavyPOModificationPDFCtrl.cls
* Author:       Laputa
* Purpose:      Controller PDF for PO Modification
ASI_CRM_CN_HeavyPOModificationPDFComp ,  ASI_CRM_CN_HeavyPOModificationPDFCtrl
* Copyright 2017 Laputa Limited. All rights reserved.
* Customer confidential. Do not distribute.
* History     
* -----------------------------------------------------------------------------
* 2017-09-05    Laputa      Created

*/

public class ASI_CRM_CN_HeavyPOModificationPDFCtrl {
    public id currentHeaderId {set;get;}
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public boolean boolCheckCCPeriod {set;get;}

    public List<CategoryName> nameList {get;set;}
    public string strPDF {set;get;}    
    public List<ShowSubrand> subbrandList {get;set;}
    public ASI_CRM_CN_HeavyPOModificationPDFCtrl(){ }
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = initPage();} return dummyVar; } set; }
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalContract2nd  {set;get;} { 
        HistoricalContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    }
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd CurrentContract2nd  {set;get;} { 
        CurrentContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    }

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalContract  {set;get;} { 
        HistoricalContract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();
    }
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator CurrentContract  {set;get;} { 
        CurrentContract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();
    }
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContractV0EsitContract2nd  {set;get;} { 
        NewContractV0EsitContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    }
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactV0Contract2nd  {set;get;} { 
        NewContactV0Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    }

    public String groupStr {get;set;}
    
    public string td_end {set;get;}
    public string positiveGreen {set;get;}
    public string negativeRed {set;get;}
    public string normalBlack {set;get;}
    public string positiveGreen_bottom {set;get;}
    public string negativeRed_bottom {set;get;}
    public string normalBlack_bottom {set;get;}
    
    public string positiveGreen_Top_bottom {set;get;}
    public string negativeRed_Top_bottom {set;get;}
    public string normalBlack_Top_bottom {set;get;}
    
    public Decimal ModVCAmount {get;set;}
    public Decimal ModFCAmount {get;set;}
    //get Contract Approval Comments
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}{lstApprovalComment= new List<ASI_CRM_Approval_Comment__c> ();}
    public String ApprovalComment {set;get;}
    
    public list<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> paymentRequestSummary {set;get;}
    public boolean ADorAbove {set;get;}
    public Decimal Mod_VCost {set;get;} {Mod_VCost=0.0;}
    public Decimal ActVSEst_Vol  {set;get;} {ActVSEst_Vol=0.0;}
    Public Decimal strv0FixCost  {set;get;} {strv0FixCost=0.0;}

    // Public Decimal strmodifyFixCost  {set;get;} {strmodifyFixCost=0.0;}
    public boolean boolFixedCost {set;get;}
    public boolean boolVariableCost {set;get;}
    public Map<String, String> sbGroup_map {set;get;}
    public Decimal InvestmentCR12Variance  {set;get;} {InvestmentCR12Variance =0.0;}
    Public Integer CurrentCoveredOutletSize {set;get;}{CurrentCoveredOutletSize=0;}
    Public Integer PreviousCoveredOutletSize {set;get;}{PreviousCoveredOutletSize=0;}
    
    public boolean initPage() {
        if (String.isNotBlank(currentHeaderId)) {
            this.ContractSelected = [SELECT Id,ASI_CRM_Copied_From__r.ASI_CRM_CN_Fixed_Module_Est_Amount1__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Fixed_Module_Est_Amount2__c, ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,
                                 ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                                 ASI_CRM_CN_Fixed_Module_Est_Amount1__c,ASI_CRM_CN_Fixed_Module_Est_Amount2__c,
                                 ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Copied_From__r.ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_Copied_From__c,ASI_CRM_CN_Expected_PSF_Est_Total__c ,ASI_CRM_CN_Group_Contract__r.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,ASI_CRM_CN_Contract_Fixed_Cost_Total__c ,ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c ,ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c ,ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c ,ASI_CRM_PO_Province__r.Name, ASI_CRM_PO_Channel__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c, Name,Owner.Name,ASI_CRM_CN_Outlet_WS__r.Name,ASI_CRM_PSF_Grand_Contract_Total__c,ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,ASI_CRM_PSF_Contract_Adjustment_Amount__c,ASI_CRM_PSF_Estimate_Adjustment_Amount__c,ASI_CRM_Investment_Type__c,ASI_TH_CRM_Summary_Contract_Spending__c, ASI_CRM_CN_Total_Contract_Amount__c ,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,ASI_CRM_PSF_Grand_Estimate_Total__c,ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,ASI_CRM_CN_V0_0_PO_version__c,
                                 ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c, 
                                 ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c ,   ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                                 recordtypeid, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, createddate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, lastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c, 
                                 ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                 ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c,OwnerId,
                                 (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c From ASI_TH_CRM_PaymentRequests_Contract__r)                       
                                 FROM ASI_TH_CRM_Contract__c
                                 WHERE id =:currentHeaderId ];
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                return init2nd();
            } else {
                return init();
            }
        }
        return true;
    }

    public boolean init2nd(){

        positiveGreen = '<td  style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        negativeRed = '<td  style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        normalBlack = '<td  style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';
        
        
        positiveGreen_bottom = '<td  style="border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        negativeRed_bottom = '<td  style="border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        normalBlack_bottom = '<td  style="border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';
        td_end = '</td>';
        
        positiveGreen_Top_bottom = '<td  style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        negativeRed_Top_bottom = '<td  style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        normalBlack_Top_bottom = '<td  style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';
        
        
        if (strPDF == '1'){
            groupStr = ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.UserOrGroupInit();
        }else if (strPDF == '0'){
            set<Id> userIds = new set<Id>();
            for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE processinstance.status = 'Pending' AND processinstance.targetobjectid = : ContractSelected.id]){
                userIds.add(piw.ActorId);
            }
            groupStr = checkApprover2nd(userIds);
        } else if (strPDF == '2'){
            set<Id> userIds = new set<Id>();
            userIds.add(ContractSelected.OwnerId);
            groupStr = checkApprover2nd(userIds);
        }
        List<ASI_CRM_CN_Covered_Outlet__c> CurrentContract2ndOutletList = [SELECT id, ASI_CRM_CN_Contract__c FROM ASI_CRM_CN_Covered_Outlet__c   WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id];
        CurrentCoveredOutletSize=CurrentContract2ndOutletList.size()+1;
        
        sbGroup_map = new Map<String, String>();
        
        List<ASI_CRM_CN_Covered_Outlet__c> PreviousContractOutletList = [SELECT id, ASI_CRM_CN_Contract__c FROM ASI_CRM_CN_Covered_Outlet__c   WHERE ASI_CRM_CN_Contract__c = :ContractSelected.ASI_CRM_CN_Last_PO_version__c];
        PreviousCoveredOutletSize=PreviousContractOutletList.size()+1;
        
        List<String> englishNames = new List<String>();

        Map<String, ASI_HK_CRM_Product_Category__c> categoryMap = new Map<String, ASI_HK_CRM_Product_Category__c>();
        for(ASI_HK_CRM_Product_Category__c ProductCategory:[select Id,Name,ASI_CRM_CN_Chinese_Name__c,ASI_HK_CRM_English_Name__c,ASI_HK_CRM_Sequence__c from ASI_HK_CRM_Product_Category__c where RecordType.DeveloperName  ='ASI_CRM_CN_Product_Category'])
        {
            sbGroup_map.put(ProductCategory.name , ProductCategory.ASI_HK_CRM_English_Name__c + ProductCategory.ASI_CRM_CN_Chinese_Name__c);   
            categoryMap.put(ProductCategory.ASI_HK_CRM_English_Name__c + ProductCategory.ASI_CRM_CN_Chinese_Name__c, ProductCategory);
            englishNames.add(ProductCategory.ASI_HK_CRM_English_Name__c + ProductCategory.ASI_CRM_CN_Chinese_Name__c);
        }

        englishNames.sort();


        nameList = new List<CategoryName>();
        for (String enName : englishNames) {
            if (categoryMap.containsKey(enName)) {
                CategoryName cn = new CategoryName();
                cn.Cname = categoryMap.get(enName).name;
                cn.CEnName = categoryMap.get(enName).ASI_HK_CRM_English_Name__c + categoryMap.get(enName).ASI_CRM_CN_Chinese_Name__c;
                nameList.add(cn);
            }
        }

        

        lstApprovalComment = [SELECT id, recordtypeid, ASI_CRM_BA_comments__c, ASI_CRM_Background_Objective__c, ASI_CRM_New_contract_Analsysis__c, ASI_CRM_Historical_Contract_Performance__c FROM ASI_CRM_Approval_Comment__c 
                              WHERE ASI_CRM_Contract__c =:ContractSelected.id];  
        if(lstApprovalComment==null || lstApprovalComment.size()==0){
            ApprovalComment ='';
            lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
        }
        else{
            lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
            for(ASI_CRM_Approval_Comment__c ac : lstApprovalComment){
                if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment')){
                    ApprovalComment = 'new';
                    lstApprovalComment[0] = ac;
                }
                else if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment')){
                    ApprovalComment = 'po';
                    lstApprovalComment[0] = ac;
                    break;
                }
            }
        }
        
        List<ASI_Attachment__c> AttachmentList= [SELECT id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c,
                                                        ASI_CRM_Historical_Financial_Data2__c,
                                                        ASI_CRM_Historical_Financial_Data3__c,ASI_CRM_Historical_Financial_Data4__c
                                                 FROM ASI_Attachment__c 
                                                 WHERE (ASI_CRM_Contract__c = :ContractSelected.Id 
                                                 AND (ASI_CRM_Type__c ='Historical Modi Data' OR ASI_CRM_Type__c ='PO Modification Data' OR  ASI_CRM_Type__c ='Contract Data' ))
                                                 OR (ASI_CRM_Type__c ='Contract Data' AND ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c) order by createddate];
        if(AttachmentList.size()>0){
            Boolean contractDateFlag = false;
            for(ASI_Attachment__c att:AttachmentList){ 
                String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');
                System.debug(LoggingLevel.INFO, '*** JsonString: ' + JsonString);
                List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class); 
                if(att.ASI_CRM_Type__c=='Historical Modi Data' && ContractList.size()>0){
                    HistoricalContract2nd= ContractList[0]; // V0POModiContractFI 
                }else if(att.ASI_CRM_Type__c=='PO Modification Data' && ContractList.size()>0 ){
                    CurrentContract2nd= ContractList[0]; //POModiContractFI
                    if (String.isNotBlank(ContractList[0].AddOnString)) {
                        Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(ContractList[0].AddOnString,Map<String,Decimal>.class);
                        if( TempMap.containsKey('ActVSEst_Vol')  ){
                            ActVSEst_Vol= TempMap.get('ActVSEst_Vol');
                        }
                    } else {
                        ActVSEst_Vol = 0;
                    }
                    
                }else if(att.ASI_CRM_Type__c=='Contract Data' && ContractList.size()>0 && !contractDateFlag){
                    NewContractV0EsitContract2nd = ContractList[0];
                    NewContactV0Contract2nd = ContractList[1];
                    contractDateFlag = true;
                }
            }
        }

        Set<String> removeSBGNameSet = new Set<String>();
        for(String SBGName: sbGroup_map.keySet()){
            Boolean isHave = false;

            if(CurrentContract2nd.CategoryMap==null || !CurrentContract2nd.CategoryMap.containskey(SBGName)){
                CurrentContract2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }

            if(NewContractV0EsitContract2nd.CategoryMap==null || !NewContractV0EsitContract2nd.CategoryMap.containskey(SBGName)){
                NewContractV0EsitContract2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }

            if(NewContactV0Contract2nd.CategoryMap==null || !NewContactV0Contract2nd.CategoryMap.containskey(SBGName)){
                NewContactV0Contract2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }

            if (!isHave) {
                removeSBGNameSet.add(SBGName);
                CurrentContract2nd.CategoryMap.remove(SBGName);
                NewContractV0EsitContract2nd.CategoryMap.remove(SBGName);
                NewContactV0Contract2nd.CategoryMap.remove(SBGName);
            }
        }

        if (!removeSBGNameSet.isEmpty()) {
            for (String SBGName : removeSBGNameSet){
                sbGroup_map.remove(SBGName);
                for (Integer i = nameList.size() - 1;i >= 0; i--) {
                    CategoryName cn = nameList.get(i);
                    if (SBGName == cn.Cname) {
                        nameList.remove(i);
                    }
                }
            }
        }

        Map<String,Decimal> modiDecimalMap = new Map<String,Decimal>();
        Map<String, ShowSubrand> subbrandMap= new Map<String, ShowSubrand>();
        Set<String> subBrandIdSet = new Set<String>();
        for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd subbrand : CurrentContract2nd.TradeExpenseBySubBrand) {
            subBrandIdSet.add(subbrand.subBrandId);
        }

        Map<String, String> subbrandNameMap = new Map<String, String>();
        if(!subBrandIdSet.isEmpty()){
            // for(ASI_MFM_Sub_brand__c amsb : [SELECT Name FROM ASI_MFM_Sub_brand__c WHERE Id IN:subBrandIdSet]){
            //     subbrandNameMap.put(amsb.Id, amsb.Name);
            // }

            for (ASI_MFM_Sub_brand__c sb : [SELECT Name,Id,ASI_HK_CRM_English_Name__c,ASI_CRM_CN_CHI_NAME_C__c FROM ASI_MFM_Sub_brand__c WHERE Id IN: subBrandIdSet]) {
                if (String.isNotBlank(groupStr) && groupStr.contains('D')) {
                    subbrandNameMap.put(sb.Id, sb.ASI_HK_CRM_English_Name__c);
                } else {
                    subbrandNameMap.put(sb.Id, sb.ASI_CRM_CN_CHI_NAME_C__c);
                }
            }
        }
        for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd subbrand : CurrentContract2nd.TradeExpenseBySubBrand) {
            modiDecimalMap.put(subbrand.subBrandName, subbrand.propByStdTotal);
            ShowSubrand ss = new ShowSubrand();
            ss.subBrandId = subbrand.SubBrandId;
            ss.subString = subbrandNameMap.get(subbrand.SubBrandId);
            ss.volumeSTD = subbrand.volumeSTD != null?subbrand.volumeSTD:0;
            ss.monthlyVolumeSTD = subbrand.monthlyVolumeSTD != null?subbrand.monthlyVolumeSTD:0;
            ss.volumeSTDVsEst = subbrand.volumeSTD;
            ss.monthlyVolumeSTDVsEst = subbrand.monthlyVolumeSTD;
            ss.volumeSTDVsCon = subbrand.volumeSTD;
            ss.monthlyVolumeSTDVsCon = subbrand.monthlyVolumeSTD;
            subbrandMap.put(ss.subBrandId,ss);
        } 

        for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd subbrand : NewContractV0EsitContract2nd.TradeExpenseBySubBrand) {
            if (subbrandMap.containsKey(subbrand.SubBrandId)) {
                ShowSubrand ss = subbrandMap.get(subbrand.SubBrandId);
                Decimal monthlyvolume = subbrand.monthlyVolumeSTD != null ? subbrand.monthlyVolumeSTD : 0;
                ss.volumeSTDVsEst = ss.volumeSTD -monthlyvolume*ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c;
                ss.monthlyVolumeSTDVsEst = ss.monthlyVolumeSTD - monthlyvolume;
            }else {
                ShowSubrand ss = new ShowSubrand();
                ss.subBrandId = subbrand.SubBrandId;
                ss.subString = subbrandNameMap.get(subbrand.SubBrandId);
                ss.volumeSTD = subbrand.volumeSTD != null?subbrand.volumeSTD:0;
                ss.monthlyVolumeSTD = subbrand.monthlyVolumeSTD != null?subbrand.monthlyVolumeSTD:0;
                subbrandMap.put(ss.subBrandId,ss);
            }
        }

        for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd subbrand : NewContactV0Contract2nd.TradeExpenseBySubBrand) {
            if (subbrandMap.containsKey(subbrand.SubBrandId)) {
                ShowSubrand ss = subbrandMap.get(subbrand.SubBrandId);
                Decimal monthlyvolume = subbrand.monthlyVolumeSTD != null ? subbrand.monthlyVolumeSTD : 0;
                ss.volumeSTDVsCon = ss.volumeSTD - monthlyvolume*ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c;
                ss.monthlyVolumeSTDVsCon = ss.monthlyVolumeSTD - monthlyvolume;
            }else {
                ShowSubrand ss = new ShowSubrand();
                ss.subBrandId = subbrand.SubBrandId;
                ss.subString = subbrandNameMap.get(subbrand.SubBrandId);
                ss.volumeSTD = subbrand.volumeSTD != null?subbrand.volumeSTD:0;
                ss.monthlyVolumeSTD = subbrand.monthlyVolumeSTD != null?subbrand.monthlyVolumeSTD:0;
                subbrandMap.put(ss.subBrandId,ss);
            }
        }

        subbrandList = subbrandMap.values();
        for(ShowSubrand sw : subbrandList){
            if(sw.volumeSTD == null){
                sw.volumeSTD = 0;
            }
            if(sw.volumeSTDVsEst == null){
                sw.volumeSTDVsEst = 0;
            }
            if(sw.volumeSTDVsCon == null){
                sw.volumeSTDVsCon = 0;
            }
            if(sw.monthlyVolumeSTD == null){
                sw.monthlyVolumeSTD = 0;
            }
            if(sw.monthlyVolumeSTDVsEst == null){
                sw.monthlyVolumeSTDVsEst = 0;
            }
            if(sw.monthlyVolumeSTDVsCon == null){
                sw.monthlyVolumeSTDVsCon = 0;
            }
        }
        for(Integer i = 1; i< subbrandList.size(); i++) {
            Integer j;
            ShowSubrand temp = subbrandList[i];
            for(j = i-1; j >= 0; j--) {
                if(subbrandList[j].volumeSTD < temp.volumeSTD) {
                    subbrandList[j+1] = subbrandList[j];
                }else{
                    break;
                }
            }
            subbrandList[j+1]=temp;
        }

        List<ShowSubrand> conSubbrandList = new List<ShowSubrand>();
        List<ShowSubrand> vsConSubbrandList = new List<ShowSubrand>();
        List<ShowSubrand> vsEstSubbrandList = new List<ShowSubrand>();

        for (ShowSubrand ss : subbrandList) {
            if (ss.volumeSTD != 0) {
                conSubbrandList.add(ss);
            } else {
                if (ss.volumeSTDVsCon != 0) {
                    vsConSubbrandList.add(ss);
                } else {
                    if (ss.volumeSTDVsEst != 0) {
                        vsEstSubbrandList.add(ss);
                    }
                }
            }
        }

        for(Integer i = 1; i< vsConSubbrandList.size(); i++) {
            Integer j;
            ShowSubrand temp = vsConSubbrandList[i];
            for(j = i-1; j >= 0; j--) {
                if(vsConSubbrandList[j].volumeSTDVsCon < temp.volumeSTDVsCon) {
                    vsConSubbrandList[j+1] = vsConSubbrandList[j];
                }else{
                    break;
                }
            }
            vsConSubbrandList[j+1]=temp;
        }

        for(Integer i = 1; i< vsEstSubbrandList.size(); i++) {
            Integer j;
            ShowSubrand temp = vsEstSubbrandList[i];
            for(j = i-1; j >= 0; j--) {
                if(vsEstSubbrandList[j].volumeSTDVsEst < temp.volumeSTDVsEst) {
                    vsEstSubbrandList[j+1] = vsEstSubbrandList[j];
                }else{
                    break;
                }
            }
            vsEstSubbrandList[j+1]=temp;
        }

        subbrandList.clear();
        subbrandList.addAll(conSubbrandList);
        subbrandList.addAll(vsConSubbrandList);
        subbrandList.addAll(vsEstSubbrandList);

        // if (subbrandList.size() > 10) {
        //     for(Integer i = subbrandList.size() - 1; i>= 0; i--) {
        //         if (i > 10) {
        //             subbrandList.remove(i);
        //         }
        //     }
        // }
        System.debug('subbrandList'+subbrandList);

        Id subbrand999 = [SELECT Id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true  AND ASI_MFM_Sub_brand_Code__c = '999'  AND 
                                  recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1].id;

        List<ASI_CRM_CN_FixedMappingSetting__c> settingList = [SELECT ASI_CRM_CN_Activity_CodeId__c,
                                                                      ASI_CRM_CN_Contract_Mapping_Field__c
                                                               FROM ASI_CRM_CN_FixedMappingSetting__c];

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsfItems = [SELECT ASI_CRM_Type__c, ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Est_Total_Dummy__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c =:currentHeaderId];
        // for (ASI_CRM_CN_Contract_BRSF_Line_Item__c item : brsfItems) {
        //     if (item.ASI_CRM_Type__c != 'Fixed' && item.ASI_CRM_CN_Sub_Brand__c != subbrand999) { 
        //         ActVSEst_Vol += item.ASI_CRM_CN_Est_Total_Dummy__c;
        //     }
        // }

        for (ASI_CRM_CN_FixedMappingSetting__c setting : settingList) {
            if (ContractSelected.get(setting.ASI_CRM_CN_Contract_Mapping_Field__c) != null) {
                strv0FixCost += (Decimal)ContractSelected.get(setting.ASI_CRM_CN_Contract_Mapping_Field__c);
            }
        }

        if(strv0FixCost == null || strv0FixCost == 0)
            boolFixedCost = false;
        else
            boolFixedCost = true;


        // System.debug(LoggingLevel.INFO, '*** join: ');
        paymentRequestSummary = ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd( ContractSelected);

        System.debug(LoggingLevel.INFO, '*** paymentRequestSummary: ' + JSON.serialize(paymentRequestSummary));
        
        List<integer> lstRemove = new List<integer>();
        Integer indexNum=0;
        integer c = 0;
        if (paymentRequestSummary != null && paymentRequestSummary.size() > 0){
            for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary displayLine:paymentRequestSummary){
                if(displayLine.LastVersion_POEstimatedAmount==0 && displayLine.PaymentRequestAmount==0 && displayLine.POEstimatedAmount==0){

                    //paymentRequestSummary.remove(indexNum);
                    lstRemove.add(indexNum);
                }
                indexNum++;
            }        
            
            for(integer n : lstRemove){
                if(n!=0){
                    if(c>0) 
                        n=n-c;
                    paymentRequestSummary.remove(n);
                    c++;
                }else{
                    paymentRequestSummary.remove(0);
                    c++;
                }
            }
        }
        
        ModFCAmount = 0;
        ModVCAmount = 0;
        for (ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary displayLine : paymentRequestSummary) {
            if (displayLine.Name.contains('固定费用')) {
                
                if (displayLine.POEstimatedAmount == null) {
                    displayLine.POEstimatedAmount = 0;
                }
                if (displayLine.LastVersion_POEstimatedAmount == null ) {
                    displayLine.LastVersion_POEstimatedAmount = 0;
                }
                ModFCAmount += (displayLine.POEstimatedAmount-displayLine.LastVersion_POEstimatedAmount);
            } else {
                
                if (displayLine.POEstimatedAmount == null) {
                    displayLine.POEstimatedAmount = 0;
                }
                if (displayLine.LastVersion_POEstimatedAmount == null ) {
                    displayLine.LastVersion_POEstimatedAmount = 0;
                }
                ModVCAmount += (displayLine.POEstimatedAmount-displayLine.LastVersion_POEstimatedAmount);
            }
        }


        
        //Calculation
        
        if(HistoricalContract2nd.InvestmentCR12 !=0 && HistoricalContract2nd.InvestmentCR12 !=null){
            InvestmentCR12Variance= ((CurrentContract2nd.InvestmentCR12 -HistoricalContract2nd.InvestmentCR12)/HistoricalContract2nd.InvestmentCR12)*100;
        }
        
        if(ContractSelected != null && ContractSelected.ASI_CRM_CN_Last_PO_version__c !=null){
            if(ContractSelected.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c == ContractSelected.ASI_CRM_CN_PO_Start_Date__c && ContractSelected.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c == ContractSelected.ASI_CRM_CN_PO_End_Date__c){
                boolCheckCCPeriod = true;
            }
            else{
                boolCheckCCPeriod = false;
            }
        }
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>  ContractLineList = [SELECT ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                                                         FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id];
        
        Mod_VCost+=ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=NULL?ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
        Mod_VCost+=ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c!=NULL?ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        Mod_VCost+=ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c!=NULL?ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
        
        
        //ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,
        // if (ContractSelected != null && ContractSelected.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
        //     strv0FixCost = ContractSelected.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
        
        
        if((ActVSEst_Vol == null || ActVSEst_Vol == 0) && (Mod_VCost == null || Mod_VCost == 0) )
            boolVariableCost = false;
        else
            boolVariableCost = true;
        return true;
    }

    public boolean init(){
        positiveGreen = '<td  style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        negativeRed = '<td  style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        normalBlack = '<td  style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';
        
        
        positiveGreen_bottom = '<td  style="border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        negativeRed_bottom = '<td  style="border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        normalBlack_bottom = '<td  style="border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';
        td_end = '</td>';
        
        positiveGreen_Top_bottom = '<td  style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        negativeRed_Top_bottom = '<td  style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        normalBlack_Top_bottom = '<td  style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';
        
      
        List<ASI_CRM_CN_Covered_Outlet__c> CurrentContractOutletList = [SELECT id, ASI_CRM_CN_Contract__c FROM ASI_CRM_CN_Covered_Outlet__c   WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id];
        CurrentCoveredOutletSize=CurrentContractOutletList.size()+1;
        
        
        List<ASI_CRM_CN_Covered_Outlet__c> PreviousContractOutletList = [SELECT id, ASI_CRM_CN_Contract__c FROM ASI_CRM_CN_Covered_Outlet__c   WHERE ASI_CRM_CN_Contract__c = :ContractSelected.ASI_CRM_CN_Last_PO_version__c];
        PreviousCoveredOutletSize=PreviousContractOutletList.size()+1;
        
        
        lstApprovalComment = [SELECT id, recordtypeid, ASI_CRM_BA_comments__c, ASI_CRM_Background_Objective__c, ASI_CRM_New_contract_Analsysis__c, ASI_CRM_Historical_Contract_Performance__c FROM ASI_CRM_Approval_Comment__c 
                              WHERE ASI_CRM_Contract__c =:ContractSelected.id];  
        if(lstApprovalComment==null || lstApprovalComment.size()==0){
            ApprovalComment ='';
            lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
        }
        else{
            lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
            for(ASI_CRM_Approval_Comment__c ac : lstApprovalComment){
                if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment')){
                    ApprovalComment = 'new';
                    lstApprovalComment[0] = ac;
                }
                else if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment')){
                    ApprovalComment = 'po';
                    lstApprovalComment[0] = ac;
                    break;
                }
            }
        }
        
        List<ASI_Attachment__c> AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c 
                                                 from ASI_Attachment__c where ASI_CRM_Contract__c = :ContractSelected.Id and (ASI_CRM_Type__c ='Historical Modi Data' or ASI_CRM_Type__c ='PO Modification Data')];
        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){ 
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                System.debug(LoggingLevel.INFO, '*** JsonString: ' + JsonString);
                List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class); 
                System.debug(LoggingLevel.INFO, '*** ContractList: ' + ContractList);
                if(att.ASI_CRM_Type__c=='Historical Modi Data' && ContractList.size()>0){
                    HistoricalContract= ContractList[0]; // V0POModiContractFI 
                }else if(att.ASI_CRM_Type__c=='PO Modification Data' && ContractList.size()>0 ){
                    CurrentContract= ContractList[0]; //POModiContractFI
                    System.debug(LoggingLevel.INFO, '*** ContractList[0]: ' + ContractList[0]);
                    Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(ContractList[0].AddOnString,Map<String,Decimal>.class);
                    if( TempMap.containsKey('ActVSEst_Vol')  ){
                        ActVSEst_Vol= TempMap.get('ActVSEst_Vol');
                    }
                    
                    
                }
            }
        }
        
        paymentRequestSummary = ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable( ContractSelected);
        
        List<integer> lstRemove = new List<integer>();
        Integer indexNum=0;
        integer c = 0;
        if (paymentRequestSummary != null && paymentRequestSummary.size() > 0){
            for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary displayLine:paymentRequestSummary){
                if(displayLine.LastVersion_POEstimatedAmount==0 && displayLine.PaymentRequestAmount==0 && displayLine.POEstimatedAmount==0){
                    //paymentRequestSummary.remove(indexNum);
                    lstRemove.add(indexNum);
                }
                indexNum++;
            }        
            
            for(integer n : lstRemove){
                if(n!=0){
                    if(c>0) 
                        n=n-c;
                    paymentRequestSummary.remove(n);
                    c++;
                }else{
                    paymentRequestSummary.remove(0);
                    c++;
                }
            }
        }
      


        
        //Calculation
        
        if(HistoricalContract.InvestmentCR12 !=0 && HistoricalContract.InvestmentCR12 !=null){
            InvestmentCR12Variance= ((CurrentContract.InvestmentCR12 -HistoricalContract.InvestmentCR12)/HistoricalContract.InvestmentCR12)*100;
        }
        
        if(ContractSelected != null && ContractSelected.ASI_CRM_CN_Last_PO_version__c !=null){
            if(ContractSelected.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c == ContractSelected.ASI_CRM_CN_PO_Start_Date__c && ContractSelected.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c == ContractSelected.ASI_CRM_CN_PO_End_Date__c){
                boolCheckCCPeriod = true;
            }
            else{
                boolCheckCCPeriod = false;
            }
        }
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>  ContractLineList = [SELECT ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                                                         FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id];
        
        Mod_VCost+=ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=NULL?ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
        Mod_VCost+=ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c!=NULL?ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        Mod_VCost+=ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c!=NULL?ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
        
        
        //ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,
        if (ContractSelected != null && ContractSelected.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
            strv0FixCost = ContractSelected.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
        
        
        if((ActVSEst_Vol == null || ActVSEst_Vol == 0) && (Mod_VCost == null || Mod_VCost == 0) )
            boolVariableCost = false;
        else
            boolVariableCost = true;
        
        if((strv0FixCost == null || strv0FixCost == 0) && (ContractSelected.ASI_CRM_CN_Contract_Fixed_Cost_Total__c == null || ContractSelected.ASI_CRM_CN_Contract_Fixed_Cost_Total__c == 0))
            boolFixedCost = false;
        else
            boolFixedCost = true;
        
        
        
        if (strPDF == '1'){
            ADorAbove = ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        }else if (strPDF == '0'){
            ADorAbove=ASI_CRM_CN_HeavyContractUtilitiesClass.checkApprover(ContractSelected.id);
        }
        
        
        
        
        
        
        
        
        return true;
    }

    public String checkApprover2nd(Set<Id> userIds){
        // AdorAbove = false;
        // list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];

        String groupAName = 'ASI_CN_GS_Commercial_team';
        String groupBName = 'ASI_CN_Commercial_team_ex_GS';
        String groupCName = 'ASI_CN_Finance';
        String groupDName = 'ASI_CN_HQ_Management';

        String belongGroup = 'Group ';

        if (userIds != null && !userIds.isEmpty()) {
            Set<String> groupNames = new Set<String>();
            for (GroupMember gm: [SELECT group.name,
                                         group.DeveloperName
                                  FROM GroupMember
                                  WHERE UserOrGroupId IN: userIds]) {
                groupNames.add(gm.group.DeveloperName);
            }
            if (groupNames.contains(groupAName)) {
                belongGroup += 'A';
            }
            if (groupNames.contains(groupBName)) {
                belongGroup += 'B';
            }
            if (groupNames.contains(groupCName)) {
                belongGroup += 'C';
            }
            if (groupNames.contains(groupDName)) {
                belongGroup += 'D';
            }
        }
        
        return belongGroup;
        // if(gms.size()>0)
        //     AdorAbove = true;
    }
    
    
    
    
    PUBLIC String SplitLineIntoRow(String InputString,integer CutNumber ){
        String outputString ='';
        
        try{
            if(InputString.length() >= CutNumber ){
                while(InputString.length() >= CutNumber ){
                    outputString = outputString + InputString.subString(0,CutNumber) + '<br/>';
                    InputString= InputString.subString(CutNumber);
                }
            }
            outputString = outputString + InputString;
        }catch(exception e){ outputString =  InputString;
        }
        return outputString;
    }

    public class ShowSubrand {
        public String subBrandId{GET;SET;}
        public String subString{GET;SET;}
        public Decimal volumeSTD{GET;SET;}
        public Decimal volumeSTDVsEst{GET;SET;}
        public Decimal volumeSTDVsCon{GET;SET;}
        public Decimal monthlyVolumeSTD {GET;SET;}
        public Decimal monthlyVolumeSTDVsEst{GET;SET;}
        public Decimal monthlyVolumeSTDVsCon{GET;SET;}
    }

    public class CategoryName {
        public String Cname {get;set;}
        public String CEnName {get;set;}
    }
}