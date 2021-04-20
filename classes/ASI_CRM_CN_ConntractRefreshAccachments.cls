/**
 * @File Name          : ASI_CRM_CN_ConntractRefreshAccachments.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 4/23/2020, 4:47:31 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/20/2020   pengchen@bluelinksys.com     Initial Version
**/
public with sharing class ASI_CRM_CN_ConntractRefreshAccachments {
    public ASI_Attachment__c asiAtt{GET;SET;}
    public String conId{GET;SET;}
    public List<String> countries{GET;SET;}
    public boolean isShowOptions{GET;SET;}
    public String Msg{GET;SET;}
    public List<SelectOption> itemList{GET;SET;}
    public static ASI_TH_CRM_Contract__c ContractSelected;
    public static List<ASI_TH_CRM_PaymentRequest__c> aprList;
    public String refreshStr{GET;SET;}

    public ASI_CRM_CN_ConntractRefreshAccachments() {
        isShowOptions = false;
        Msg = '';
        asiAtt = new ASI_Attachment__c();
        countries = new List<String>();
    }

    public PageReference queryCon(){

        // ASI_TH_CRM_Contract__c ContractSelected = new ASI_TH_CRM_Contract__c();
        itemList = new List<SelectOption>();
        String getId = asiAtt.ASI_CRM_Contract__c;
        System.debug('queryCon'+conId);
        if(conId == null){
            isShowOptions = false;
            asiAtt.ASI_CRM_Contract__c = null;
            countries = new List<String>();
            return null;
        }

        List<ASI_TH_CRM_Contract__c> ContractSelectedList = [SELECT ASI_CRM_System_Debug__c,
                                                                    ASI_CRM_CN_PO_Version__c,
                                                                    ASI_CRM_Heap_Size_Large__c,
                                                                    ASI_CRM_CN_Is_2nd_KPI_PO__c
                                                            FROM ASI_TH_CRM_Contract__c
                                                            WHERE Id = :getId];


        ContractSelected = ContractSelectedList[0];

        if(!ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c){
            isShowOptions = false;
            Msg = '该合同为旧合同';
            asiAtt.ASI_CRM_Contract__c = null;
            countries = new List<String>();
            return null;
        }
        if(ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0'){
            itemList.add(new SelectOption('Historical Data','Historical Data'));
            itemList.add(new SelectOption('Contract Data','Contract Data'));
        }else{
            itemList.add(new SelectOption('PO Modification Data','PO Modification Data'));
            itemList.add(new SelectOption('Historical Modi Data','Historical Modi Data'));
        }

        //Get lastPaymentData
        aprList = getPayMent(getId);
        if(!aprList.isEmpty()){
            itemList.add(new SelectOption('Last Payment Data','Last Payment Data'));
        }

        System.debug('itemList'+itemList);
        if(!itemList.isEmpty()){
            isShowOptions = true;
        }
        return null;
    }

    public void refreshpage(){
        if(refreshStr == 'Delete'){
            isShowOptions = false;
            asiAtt.ASI_CRM_Contract__c = null;
            countries = new List<String>();
            return;
        }
    }



    @RemoteAction
    public static String refreshAtt(String queryId, String countriesValStr){
        System.debug('queryId'+queryId);
        System.debug('countriesValStr'+countriesValStr);
        Set<String> countriesSet = (Set<String>)JSON.deserialize(countriesValStr,Set<String>.class);

        if(countriesSet.contains('Historical Data')){
            restructureFinancialVConHisData(queryId);
        }
        if(countriesSet.contains('Contract Data')){
            restructureFinancialVConConData(queryId);
        }
        if(countriesSet.contains('PO Modification Data')){
            restructureFinancialVConPoModifyData(queryId);
        }
        if(countriesSet.contains('Historical Modi Data')){
            restructureFinancialVConHiModifysData(queryId);
        }
        List<ASI_TH_CRM_PaymentRequest__c> atcList = new List<ASI_TH_CRM_PaymentRequest__c>();
        atcList = getPayMent(queryId);
        if(countriesSet.contains('Last Payment Data') && !atcList.isEmpty()){
            restructureFinancialVConLastPayData(queryId);
        }
        String returnMsg = 'success';
        return returnMsg;
    }

    @future (callout=true) 
    public static void restructureFinancialVConHisData(String queryId){
        ASI_TH_CRM_Contract__c con = new ASI_TH_CRM_Contract__c();
        con = getCon(queryId);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData2nd(con);
        updateCon(con.Id);
    }
    
    @future (callout=true) 
    public static void restructureFinancialVConConData(String queryId){
        ASI_TH_CRM_Contract__c con = new ASI_TH_CRM_Contract__c();
        con = getCon(queryId);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(con);
        updateCon(con.Id);
    }
    
    @future (callout=true) 
    public static void restructureFinancialVConPoModifyData(String queryId){
        ASI_TH_CRM_Contract__c con = new ASI_TH_CRM_Contract__c();
        con = getCon(queryId);
        ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData2nd(con);
        updateCon(con.Id);
    }
    
    @future (callout=true) 
    public static void restructureFinancialVConHiModifysData(String queryId){
        ASI_TH_CRM_Contract__c con = new ASI_TH_CRM_Contract__c();
        con = getCon(queryId);
        ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData2nd(con);
        updateCon(con.Id);
    }
    @future (callout=true) 
    public static void restructureFinancialVConLastPayData(String queryId){
        List<ASI_TH_CRM_PaymentRequest__c> atcList = new List<ASI_TH_CRM_PaymentRequest__c>();
        atcList = getPayMent(queryId);
        ASI_CRM_CN_HeavyPaymentUtilitiesClass.ReconstructLastPaymentFIData2nd(atcList[0]);
        updateCon(atcList[0].ASI_TH_CRM_Contract__c);
    }

    public static void updateCon(String upConId){
        ASI_TH_CRM_Contract__c atc = new ASI_TH_CRM_Contract__c();
        atc.id = upConId;
        atc.ASI_CRM_CN_IS_Manual_Refresh__c = true;
        Update atc;
    }

    public static ASI_TH_CRM_Contract__c getCon(String queryId){
        ASI_TH_CRM_Contract__c ContractSelected = new ASI_TH_CRM_Contract__c();
        ContractSelected = [SELECT ASI_CRM_Martell_BC_Rate__c,
                                    ASI_CRM_Heap_Size_Large__c,
                                    ownerId,
                                    ASI_CRM_CN_Local_Group_Contract__c,
                                    ASI_CRM_Contract_Template_Id__c,
                                    ASI_CRM_CN_CTD_Monthly_Default_Date__c,
                                    ASI_CRM_CN_V0_0_PO_version__c,
                                    ASI_CRM_Auto_PO_Modification_Time__c,
                                    ASI_CRM_Auto_PO_Modification__c,
                                    ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
                                    ASI_CRM_System_Debug__c,
                                    ASI_CRM_Previous_Version_PSF_Est_Total__c,
                                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
                                    ASI_CRM_CN_Expected_PSF_Est_Total__c,
                                    ASI_CRM_V0_PSF_Contract_Total__c,
                                    Owner.Email,
                                    ASI_CRM_Last_RBA_Approver__c,
                                    ASI_CRM_CN_Group_Contract__c,
                                    Name,
                                    ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,
                                    ASI_CRM_Expected_V0_0_VEC_Est_Total__c,
                                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                                    ASI_CRM_PSF_Grand_Contract_Total__c,
                                    ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,
                                    ASI_CRM_PSF_Contract_Adjustment_Amount__c,
                                    ASI_CRM_PSF_Estimate_Adjustment_Amount__c,
                                    ASI_CRM_Investment_Type__c,
                                    ASI_TH_CRM_Summary_Contract_Spending__c,
                                    ASI_CRM_CN_Total_Contract_Amount__c,
                                    ASI_CRM_EVC_Cost_Estimate_Total__c,
                                    ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,
                                    ASI_CRM_PSF_Grand_Estimate_Total__c,
                                    ASI_CRM_CN_Vol_Budget_LE__c,
                                    ASI_CRM_CN_Status__c,
                                    ASI_CRM_CN_Source_of_Contract__c,
                                    ASI_CRM_CN_Source_Others__c,
                                    ASI_CRM_CN_Reason_without_Budget__c,
                                    ASI_TH_CRM_Promotion_Type__c,
                                    ASI_CRM_CN_PP_No__c,
                                    ASI_CRM_CN_PO_Version__c,
                                    ASI_CRM_CN_PO_Start_Date__c,
                                    ASI_CRM_CN_PO_No__c,
                                    ASI_CRM_CN_PO_End_Date__c,
                                    ASI_CRM_CN_Outlet_WS__c,
                                    ASI_CRM_CN_Exchange_Rate__c,
                                    ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                                    ASI_CRM_CN_Description__c,
                                    ASI_CRM_CN_Currency__c,
                                    ASI_CRM_CN_Budget_LE__c,
                                    ASI_CRM_CN_Bottle_Collection_Rate__c,
                                    ASI_CRM_CN_Effective_Date__c,
                                    recordtypeid,
                                    ASI_CRM_CN_No_of_Months__c,
                                    ASI_CRM_CN_PO_Modification__c,
                                    ASI_CRM_CN_Special_Promotion__c,
                                    ASI_CRM_CN_Contract_Upload__c,
                                    ASI_CRM_CN_Last_PO_version__c,
                                    ASI_CRM_CN_National_Group_Contract__c,
                                    ASI_CRM_CN_Business_License__c,
                                    createddate,
                                    ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                                    ASI_CRM_Volume_Option__c,
                                    lastModifiedDate,
                                    ASI_CRM_New_FY_PO__c,
                                    ASI_CRM_PO_Channel__c,
                                    ASI_CRM_PO_Province__c,
                                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                                    ASI_CRM_PO_City__c,
                                    ASI_CRM_PO_City__r.Name,
                                    ASI_CRM_National_Group__c,
                                    ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                    ASI_CRM_National_Group__r.Name,
                                    ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
                                    ASI_CRM_CN_Last_Submitted_Date__c,
                                    ASI_CRM_CN_Last_Rejected_Date__c,
                                    (Select Id, Name, ASI_CRM_CN_Last_Payment__c, 
                                            ASI_TH_CRM_Contract__c, ASI_CRM_CN_PO_Version__c, 
                                            ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c, 
                                            ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c, 
                                            ASI_CRM_CN_Total_Payment__c, ASI_CRM_CN_Paid__c, 
                                            ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c 
                                    From ASI_TH_CRM_PaymentRequests_Contract__r) 
                                FROM ASI_TH_CRM_Contract__c 
                                WHERE id=:queryId];
        return ContractSelected;
    }

    public static List<ASI_TH_CRM_PaymentRequest__c> getPayMent(String queryId){
        List<ASI_TH_CRM_PaymentRequest__c> aprList = new List<ASI_TH_CRM_PaymentRequest__c>();
        aprList = [ SELECT  CreatedDate,
                            ASI_CRM_Auto_PO_Modification__c,
                            ASI_CRM_CN_Adjustment__c,
                            ASI_CRM_CN_Bottle_Collection_Rate__c,
                            ASI_CRM_CN_BRSF_End_Date__c,
                            ASI_CRM_CN_BRSF_Start_Date__c,
                            ASI_CRM_CN_Business_License_Qualify__c,
                            ASI_CRM_CN_Channel__c,
                            ASI_CRM_CN_Currency__c,
                            ASI_CRM_CN_Description__c,
                            ASI_CRM_CN_Division__c,
                            ASI_CRM_CN_Last_Payment__c,
                            ASI_CRM_CN_Last_Year_Payment__c,
                            ASI_CRM_CN_No_of_Month__c,
                            ASI_CRM_CN_Other_Reason__c,
                            ASI_CRM_CN_OutletWS__c,
                            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
                            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c,
                            ASI_CRM_CN_Overpayment_Comment__c,
                            ASI_CRM_CN_Overpayment_Reason__c,
                            ASI_CRM_CN_Payable_Amount__c,
                            ASI_CRM_CN_Payment_Raised_Date__c,
                            ASI_CRM_CN_Payment_Type__c,
                            ASI_CRM_CN_PO_End_Date__c,
                            ASI_CRM_CN_PO_No__c,
                            ASI_CRM_CN_PO_Start_Date__c,
                            ASI_CRM_CN_PO_Version__c,
                            ASI_CRM_CN_PO_Version_Latest__c,
                            ASI_CRM_CN_Promotion_Type__c,
                            ASI_CRM_CN_Reason_For_Business_License__c,
                            ASI_CRM_CN_Reference_Code__c,
                            ASI_CRM_CN_Total_BRSF_Actual_Amount__c,
                            ASI_CRM_CN_Total_BRSF_Amount__c,
                            ASI_CRM_CN_Total_Other_Amount__c,
                            ASI_CRM_CN_Total_Payment__c,
                            ASI_CRM_CN_Total_PSF_Amount__c,
                            ASI_CRM_New_FY_Payment__c,
                            ASI_CRM_System_Debug__c,
                            ASI_CRM_Volume_Cut_Off_Date__c,
                            ASI_CRM_Volume_Option__c,
                            ASI_TH_CRM_Contract__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,
                            ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,
                            ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c,
                            ASI_TH_CRM_Status__c,
                            ASI_TH_CRM_Total_Amount__c,
                            Id,
                            Name,
                            (SELECT Id,
                                ASI_CRM_Line_Type__c,
                                ASI_CRM_Actual_Payment__c,
                                ASI_CRM_Volume_Base__c,
                                ASI_CRM_Completion_Ratio__c ,
                                ASI_CRM_PSF_Overpayment_Reason__c
                            FROM ASI_CRM_Modules__r)
                        FROM ASI_TH_CRM_PaymentRequest__c
                        WHERE ASI_TH_CRM_Contract__c = :queryId
                        AND ASI_CRM_CN_Last_Payment__c = true 
                        ORDER By CreatedDate];
        return aprList;
    }
}