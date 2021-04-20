/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffContractHeaderCtrl
 * Description: Apex class for ASI_CRM_CN_OffContractHeaderCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-08-29       Jeffrey Cheung          Created
 * 2018-11-28		Hector Tsang			Added Bypass for Fiscal Year: ASI_CN_FiscalYearBypass
 ****************************************************************************************************************************/

public class ASI_CRM_CN_OffContractHeaderCtrl {
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public String PageId {set;get;}

    public Boolean showCN {set;get;}
    public Boolean EditDate {get; set;}{EditDate=true;}
    public Boolean isV0AndDraft {get; set;}{isV0AndDraft=true;}

    public Boolean ReadOnlyModule {get; set;}{ReadOnlyModule=false;}

    public Boolean POModification {get; set;}

    public Boolean AutoLinkToPO {get; set;} {AutoLinkToPO = false;}
    public Date StartDate  {get; set;}
    public Date EndDate  {get; set;}

    public Boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public String Msg {get;set;} {Msg='';}
    public Integer NoOfMonths {get; set;}{NoOfMonths=1;}


    public ASI_CRM_CN_OffContractHeaderCtrl(ApexPages.StandardController controller) {
        Map<String, String> params = ApexPages.currentPage().getParameters();

        POModification = params.get('POModification') == '1'? true : false;


        this.ContractSelected = (ASI_TH_CRM_Contract__c) controller.getRecord();
        if (this.ContractSelected != null)
            PageId = ContractSelected.Id;


        this.ContractSelected = [
            SELECT Id,ASI_CRM_Heap_Size_Large__c,OwnerId,ASI_CRM_CN_Local_Group_Contract__c,ASI_CRM_Contract_Template_Id__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Auto_PO_Modification_Time__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_System_Debug__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_V0_PSF_Contract_Total__c,Owner.Email,ASI_CRM_Last_RBA_Approver__c,ASI_CRM_CN_Group_Contract__c,Name,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_PSF_Grand_Contract_Total__c,ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,ASI_CRM_PSF_Contract_Adjustment_Amount__c,ASI_CRM_PSF_Estimate_Adjustment_Amount__c,ASI_CRM_Investment_Type__c,ASI_TH_CRM_Summary_Contract_Spending__c, ASI_CRM_CN_Total_Contract_Amount__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,ASI_CRM_PSF_Grand_Estimate_Total__c,ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
                ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,
                ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c, ASI_CRM_CN_Use_PRC_Contract_Template__c, ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                RecordTypeId, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_PO_Modification__c, ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c, ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, CreatedDate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, LastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_End_Date__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c, ASI_CRM_Remarks__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,ASI_CRM_CN_Is_Dolphin__c,ASI_CRM_CN_Activity_Times__c,ASI_CRM_CN_Target_Base__c,ASI_CRM_CN_Contract_Classification__c,
            (
                SELECT Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
                    ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c
                FROM ASI_TH_CRM_PaymentRequests_Contract__r
            )
            FROM ASI_TH_CRM_Contract__c
            WHERE Id = :PageId
        ];
        //save the contract Date
        StartDate = ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
        EndDate = ContractSelected.ASI_CRM_CN_PO_End_Date__c;


        NoOfMonths = Integer.valueOf(ContractSelected.ASI_CRM_CN_No_of_Months__c) ;
        isV0AndDraft = ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0' && ContractSelected.ASI_CRM_CN_Status__c == 'Draft';

        if (ContractSelected.ASI_CRM_CN_PO_Version__c != '0.0' || ContractSelected.ASI_CRM_CN_Status__c != 'Draft') {
            EditDate = false;
        }

        if (POModification && !ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
            EditDate = true;
        }

        if (ContractSelected.ASI_CRM_CN_Status__c == 'Archived' || ContractSelected.ASI_CRM_CN_Status__c == 'FY landing Archive') {
            ReadOnlyModule = true;
        }


    }



    //*****************Save the record po edit or PO Modification*****************
    public PageReference SaveItems(){
        PageReference pageRef = null;
        UpsertPermission=true;
        Msg='';


        if(!ValidationChecking()){
            UpsertPermission=false;
        }
        if(UpsertPermission){
            System.Savepoint pSavepoint = Database.setSavepoint();

            try{
                if(POModification){
                     Date TempStartDate=ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
                    Date TempEndDate=ContractSelected.ASI_CRM_CN_PO_End_Date__c;

                    ContractSelected.ASI_CRM_CN_PO_Start_Date__c=StartDate;
                    ContractSelected.ASI_CRM_CN_PO_End_Date__c=EndDate;


                    ASI_TH_CRM_Contract__c ContractCloned  = ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO(ContractSelected);

                    System.debug(' ContractCloned ' + ContractCloned.ASI_CRM_CN_Expected_V0_Display_Est_Total__c);
                    System.debug(' ContractCloned ' + ContractCloned.ASI_CRM_CN_V0_Display_Contract_Total__c);
                    System.debug(' ContractCloned ' + ContractCloned.ASI_CRM_CN_Total_RContract_Amount__c);

                    ContractSelected.ASI_CRM_CN_Last_PO_version__c=ContractCloned.Id;
                    ContractSelected.ASI_CRM_CN_PO_Start_Date__c=TempStartDate;
                    ContractSelected.ASI_CRM_CN_PO_End_Date__c=TempEndDate;

                    ContractSelected.ASI_CRM_CN_Last_PO_version__c=ContractCloned.Id;

                    ContractSelected.ASI_CRM_CN_Status__c = 'Draft';
                    ContractSelected.ASI_TH_CRM_Start_Date__c = null;
                    ContractSelected.ASI_TH_CRM_End_Date__c = null;
                    ContractSelected.ASI_CRM_Reject_Return_Comments__c = '';
                    ContractSelected.ASI_CRM_CN_Return_Comments__c = '';
                    ContractSelected.ASI_CRM_CN_Last_Approved_By__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Approved_Date__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Recall_By__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Recall_Date__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Rejected_By__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Rejected_Date__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Submitted_By__c = null;
                    ContractSelected.ASI_CRM_CN_Last_Submitted_Date__c = null;
                    ContractSelected.ASI_CRM_CN_Contract_Upload__c=true;
                    ContractSelected.ASI_CRM_Auto_PO_Modification_Time__c=null;
                    ContractSelected.ASI_CRM_Auto_PO_Modification__c=false;


                    ContractSelected.ASI_CRM_CN_PO_Modification__c = true;

                    if(ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0'){
                        ContractSelected.ASI_CRM_CN_V0_0_PO_version__c=ContractCloned.Id;
                    }

                    List<String> poVersionSplit = ContractSelected.ASI_CRM_CN_PO_Version__c.split('\\.',0);
                    if(poVersionSplit != null && poVersionSplit.size() ==2){
                        ContractSelected.ASI_CRM_CN_PO_Version__c = poVersionSplit[0] + '.' + String.valueOf(Integer.valueOf(poVersionSplit[1])+1);
                    }
                    ContractSelected.ASI_CRM_Copied_From__c=ContractCloned.Id; // Previous Contract

                    // calculate PSF Adjustment and Grand Total and Display
                    calculateAdjustment(ContractSelected);

                    update ContractSelected;
//                    POModificationProcess1(ContractSelected);
                }else{
                    update ContractSelected;
//                    ASI_CRM_CN_HeavyContractUtilitiesClass.ContractChangingPeriod(ContractSelected,NoOfMonths,StartDate,EndDate);
                }

                pageRef = new PageReference('/'+PageId);
                pageRef.setRedirect(true);

            } catch(Exception e){
                Msg += ASI_CRM_CN_HeavyContracFunctionClass.ErrorMsgTransform(e.getMessage()) + '</br>';
                UpsertPermission=false;
                Database.rollback(pSavepoint);
            }

        }

        return pageRef;
    }




    public Boolean ValidationChecking(){
        Boolean isProcess = true;

        String version = ContractSelected.ASI_CRM_CN_PO_Version__c;
        Date startDate = ContractSelected.ASI_CRM_CN_PO_Start_Date__c;
        Date endDate = ContractSelected.ASI_CRM_CN_PO_End_Date__c;
        if (ContractSelected.ASI_CRM_CN_Group_Contract__c != null) {// is group contract
            if(startDate<ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_Start_Date__c ||
                endDate>ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_CN_PO_End_Date__c){

                Msg +=Label.ASI_CRM_CN_PO_Date_GroupContract + '</br>';
                isProcess=false;
            }
        }
        if(ContractSelected.ASI_CRM_CN_Source_of_Contract__c == null || ContractSelected.ASI_CRM_CN_Source_of_Contract__c == ''){
            Msg += ' Please input Source of Contract.请输入合同来源' + '</br>';
            isProcess=false;
        }


        if(startDate == null){
            Msg += ' Please input Start Date.请输入开始日期' + '</br>';
            isProcess=false;
        }

        if(endDate == null){
            Msg += ' Please input End Date.请输入结束日期' + '</br>';
            isProcess=false;
        }
        
        if(ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
            if(ContractSelected.ASI_CRM_CN_Activity_Times__c == null){
                Msg += ' Please input Activity Times.请输入活动场次' + '</br>';
                isProcess=false;
            }
            if(ContractSelected.ASI_CRM_CN_Target_Base__c == null){
                Msg += ' Please select Volume/Value Base.请选择销量/销售额' + '</br>';
                isProcess=false;
            }
            /*if(ContractSelected.ASI_CRM_CN_Contract_Classification__c == null){
                Msg += ' Please select Store Type.请选择门店类别' + '</br>';
                isProcess=false;
            }
            if(ContractSelected.ASI_CRM_CN_Contract_Classification__c == 'C' && ContractSelected.ASI_CRM_CN_Use_PRC_Contract_Template__c){
                Msg += ' Not allowed to use contract template when Store Type is C.门店类别为C时,不能使用线上合同模板' + '</br>';
                isProcess=false;
            }*/
        }

        if(!ASI_CRM_DateUtilClass.isStartOfMonth(startDate)){
            Msg += Label.ASI_CRM_CN_PO_Start_Date_Validation+'<br/>';
            isProcess=false;
        }

        //checking end day
        if(!ASI_CRM_DateUtilClass.isEndOfMonth(endDate)){
            Msg +=Label.ASI_CRM_CN_PO_End_Date_Validation+'<br/>';// End Date should be the last day of the month .
            isProcess=false;
        }
		// Canter注释 注释时间：2019/10/11 注释原因：用户要求在修改contract的时候，不要这个限制
        /*if(!ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CN_FiscalYearBypass') && version == '0.0' && ASI_CRM_DateUtilClass.isCrossingFiscalYear(startDate,endDate)){
            Msg += Label.ASI_CRM_CN_Contract_Start_Date_in_Last_FY+'<br/>';
            isProcess=false;
        }*/

        if (startDate != null && endDate != null && !ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CN_checkOverlapBypass')) {
            List<ASI_TH_CRM_Contract__c> contractsWithOverlapPeriod = [
                SELECT Id, Name
                FROM ASI_TH_CRM_Contract__c
                WHERE Id != :ContractSelected.Id
                AND ASI_CRM_CN_PO_No__c != :ContractSelected.ASI_CRM_CN_PO_No__c
                AND ASI_CRM_CN_Status__c != 'Archived'
                AND ASI_CRM_CN_Outlet_WS__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c
                AND ASI_TH_CRM_Promotion_Type__c IN ('TOT/MOT Contract', 'Contract OFF', 'New Contract OFF')
                AND ASI_CRM_CN_PO_Start_Date__c <= :endDate
                AND ASI_CRM_CN_PO_End_Date__c >= :startDate
            ];
            List<String> contractNames = new List<String>();
            for (ASI_TH_CRM_Contract__c contract : contractsWithOverlapPeriod) {
                contractNames.add(contract.Name);
            }
            if (!contractsWithOverlapPeriod.isEmpty()) {
                Msg += 'PO period overlaps with other contract ' + String.join(contractNames, ',') + '<br/>';
                isProcess=false;
            }
        }

        return isProcess;
    }


    public void calculateAdjustment(ASI_TH_CRM_Contract__c Contract){
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> V0ContractDetailLines =[SELECT Id,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c] ;
        Decimal V0BRSFContractAmount = 0;
        Decimal V0PSFContractAmount = 0;
        Decimal V0DisplayContractAmount = 0;

        Decimal V0BRSFEstimateAmount = 0;
        Decimal V0PSFEstimateAmount = 0;
        Decimal V0DisplayEstimateAmount = 0;

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:V0ContractDetailLines) {

            if (ContractLine.ASI_CRM_Type__c == 'BRSF') {
                V0BRSFContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                V0BRSFEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
            if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                V0PSFContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                V0PSFEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
            if (ContractLine.ASI_CRM_Type__c == 'Display') {
                V0DisplayContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                V0DisplayEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
        }

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailLines = [
            SELECT Id,ASI_CRM_Adjustment_Line__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Volume_Base__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
            WHERE ASI_CRM_CN_Contract__c = :PageId
        ] ;

        Decimal BRSFContractAmount = 0;
        Decimal PSFContractAmount = 0;
        Decimal DisplayContractAmount = 0;

        Decimal BRSFEstimateAmount = 0;
        Decimal PSFEstimateAmount = 0;
        Decimal DisplayEstimateAmount = 0;

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractDetailLines) {
            if (ContractLine.ASI_CRM_Type__c == 'BRSF') {
                BRSFContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                BRSFEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            } else if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                PSFContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                PSFEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            } else if (ContractLine.ASI_CRM_Type__c == 'Display') {
                DisplayContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                DisplayEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }

        }

        ASI_TH_CRM_Contract__c prevContract = [SELECT ASI_CRM_CN_Expected_PSF_Est_Total__c, ASI_CRM_CN_Expected_Display_Est_Total__c FROM ASI_TH_CRM_Contract__c WHERE Id = :Contract.ASI_CRM_Copied_From__c LIMIT 1];

        Contract.ASI_CRM_CN_Expected_BRSF_Est_Total__c = BRSFEstimateAmount;
        Contract.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c = BRSFEstimateAmount;

        //PSF
        Contract.ASI_CRM_PSF_Grand_Contract_Total__c = PSFContractAmount;
        Contract.ASI_CRM_PSF_Grand_Estimate_Total__c = PSFEstimateAmount;
        Contract.ASI_CRM_Previous_Version_PSF_Est_Total__c = prevContract.ASI_CRM_CN_Expected_PSF_Est_Total__c;
        Contract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = 0;
        if (Contract.ASI_CRM_CN_PO_Version__c == '0.0' || Contract.ASI_CRM_CN_PO_Version__c == '0.1') {
            Contract.ASI_CRM_CN_Expected_PSF_Est_Total__c = PSFEstimateAmount;
        } else {
            Contract.ASI_CRM_CN_Expected_PSF_Est_Total__c = Contract.ASI_CRM_Previous_Version_PSF_Est_Total__c;
        }
        
        Contract.ASI_CRM_V0_PSF_Contract_Total__c = V0PSFContractAmount;
        Contract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c = V0PSFEstimateAmount;

        //Display
        Contract.ASI_CRM_CN_V0_Display_Contract_Total__c = V0DisplayContractAmount;
        Contract.ASI_CRM_CN_Expected_V0_Display_Est_Total__c = V0DisplayEstimateAmount;
        Contract.ASI_CRM_Prev_Version_Display_Est_Total__c = prevContract.ASI_CRM_CN_Expected_Display_Est_Total__c;
        Contract.ASI_CRM_Display_Estimate_Adjustment_Amt__c = 0;
        if (Contract.ASI_CRM_CN_PO_Version__c == '0.0' || Contract.ASI_CRM_CN_PO_Version__c == '0.1') {
            Contract.ASI_CRM_CN_Expected_Display_Est_Total__c = DisplayEstimateAmount;
        } else {
            Contract.ASI_CRM_CN_Expected_Display_Est_Total__c = Contract.ASI_CRM_Prev_Version_Display_Est_Total__c;
        }

    }



    //Cancel the record
    public PageReference CancelProcess(){
        PageReference pageRef = null;
        pageRef = new PageReference('/'+PageId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}