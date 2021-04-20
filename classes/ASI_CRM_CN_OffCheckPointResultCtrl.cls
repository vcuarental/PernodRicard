/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffCheckPointResultCtrl
 * Description: Apex class for ASI_CRM_CN_OffCheckPointResultCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-07       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_OffCheckPointResultCtrl {
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}

    public Boolean showCN {set;get;}
    public String Msg {get;set;} {Msg='';}
    public Boolean ProcessPermission {get;set;}{ProcessPermission=true;}
    public Integer WarningTimes {get;set;} {WarningTimes=0;}
    public String WarningMsg {get;set;} {WarningMsg='';}
    public Integer orgFiscalMonth {set;get;}

    public Boolean AdorAbove {set;get;}{AdorAbove=false;}
    public List<interimData> SuccessCheckPointList {set;get;}  {SuccessCheckPointList = new List<interimData>();}
    public List<interimData> FailedCheckPointList {set;get;}  {FailedCheckPointList = new List<interimData>();}

    public Boolean DisplaySuccessCheckPointPart {get;set;}{DisplaySuccessCheckPointPart=true;}
    public Boolean DisplayFailedCheckPointPart {get;set;}{DisplayFailedCheckPointPart=true;}
    public Decimal FixedCostTotal {get;set;}{FixedCostTotal=0;}
    public Decimal PSFTotal {get;set;}{PSFTotal =0;}
    public Decimal DisplayTotal {get;set;}{DisplayTotal =0;}
    public Boolean NeedPRVApproval {get;set;}{NeedPRVApproval=false;}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator HistoricalV00Contract  {set;get;} { HistoricalV00Contract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator HistoricalVFinalContract  {set;get;} { HistoricalVFinalContract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContractV0Esitimate  {set;get;} { NewContractV0Esitimate = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContactVFinal  {set;get;} { NewContactVFinal = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}


    public Boolean ShowSubmitApproval {set;get;} {ShowSubmitApproval=false;}


    public String PageId {set;get;}


    public class interimData{
        public ASI_CRM_SegmentationCriteria__c SegmentationCriteria {set;get;}
        public Decimal Dimension1stResult {set;get;} {Dimension1stResult=0.0;}
        public Decimal Dimension2ndResult {set;get;} {Dimension2ndResult=0.0;}
        public String Type1stName {set;get;}{Type1stName='';} // Methodology or Volume Base
        public String Type2ndName {set;get;}{Type2ndName='';}
        public Date Period1stResult {set;get;}{Period1stResult=Date.today();}
        public Date Period2ndResult {set;get;}{Period2ndResult=Date.today();}

        public String Display1stResult {set;get;} {Display1stResult='';}
        public String Display2ndResult {set;get;} {Display2ndResult='';}

        public String Display1stResultEN {set;get;} {Display1stResultEN='';}
        public String Display2ndResultEN {set;get;} {Display2ndResultEN='';}

        public Boolean DisplayToUser  {set;get;} {DisplayToUser=true;}
        public String ReachTarget  {set;get;} {ReachTarget ='Yes';} // Reach Target ?
        public interimData(){ }
        public interimData(ASI_CRM_SegmentationCriteria__c sc){
            this.SegmentationCriteria= sc;
        }
    }

    public ASI_CRM_CN_CustomSetting__c CustomSetting{set;get;}



    public ASI_CRM_CN_OffCheckPointResultCtrl(ApexPages.StandardController controller) {
        this.ContractSelected = (ASI_TH_CRM_Contract__c )controller.getRecord();
        if(this.ContractSelected != null)
            PageId = ContractSelected.Id;
        this.ContractSelected = [
            SELECT
                ASI_CRM_CN_Budget_LE__c,
                ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                ASI_CRM_CN_Expected_Display_Est_Total__c,
                ASI_CRM_CN_Expected_PSF_Est_Total__c,
                ASI_CRM_CN_Group_Contract__c,
                ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__c,
                ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__r.ASI_CRM_Special_COA_Approval_Flow__c,
                ASI_CRM_CN_Last_PO_version__c,
                ASI_CRM_CN_Local_Group_Contract__c,
                ASI_CRM_CN_National_Group_Contract__c,
                ASI_CRM_CN_Outlet_WS__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                ASI_CRM_CN_PO_End_Date__c,
                ASI_CRM_CN_PO_Modification__c,
                ASI_CRM_CN_PO_No__c,
                ASI_CRM_CN_PO_Start_Date__c,
                ASI_CRM_CN_PO_Version__c,
                ASI_CRM_CN_Reason_without_Budget__c,
                ASI_CRM_CN_Use_PRC_Contract_Template__c,
                ASI_CRM_CN_V0_0_PO_version__c,
                ASI_CRM_CN_Vol_Budget_LE__c,
                ASI_CRM_Copied_From__c,
                ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,
                ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,
                ASI_CRM_RVP_Approval__c,
                ASI_CRM_V0_PSF_Contract_Total__c,
                ASI_CRM_CN_V0_Display_Contract_Total__c,
                    Id,
                Name,
                Owner.Name,
                ASI_CRM_CN_Is_Dolphin__c,ASI_CRM_CN_Contract_Classification__c
            FROM ASI_TH_CRM_Contract__c
            WHERE Id = :PageId
        ];
        init();
    }

    public void init(){

        CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();

        Boolean ExistHistoricalData=false;
        if(ContractSelected.ASI_CRM_CN_Group_Contract__c!=null){
            if(ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__c!=null){
                if(ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__r.ASI_CRM_Special_COA_Approval_Flow__c){
                    ContractSelected.ASI_CRM_RVP_Approval__c=true;
                    NeedPRVApproval=true;
                }
            }
        }

        checkUserID();
        orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;

        showCN = UserInfo.getLanguage()=='zh_CN';

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String TypeName = params.get('Type');
        if(TypeName =='SubmitApproval'){
            ShowSubmitApproval =true;
        }

        //Calculate Fix cost amount and Total Amount
        for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c,   ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c  FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id]){
            if (ccost.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                FixedCostTotal += ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
            }
        }


        if (ContractSelected.ASI_CRM_CN_PO_Version__c != '0.0') {
            PSFTotal = ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c != null? ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c : 0;
            DisplayTotal = ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c != null? ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c : 0;
        } else {
            PSFTotal = ContractSelected.ASI_CRM_V0_PSF_Contract_Total__c != null? ContractSelected.ASI_CRM_V0_PSF_Contract_Total__c : 0;
            DisplayTotal = ContractSelected.ASI_CRM_CN_V0_Display_Contract_Total__c != null? ContractSelected.ASI_CRM_CN_V0_Display_Contract_Total__c : 0;
        }


        //Getting HistoricalV0.0 and VFinal Data
        List<ASI_Attachment__c> AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c
        WHERE ASI_CRM_Contract__c = :ContractSelected.Id ];
        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                if(att.ASI_CRM_Type__c=='Historical Data'){
                    List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                    if(HistoricalContractList.size()>0){
                        HistoricalV00Contract= HistoricalContractList[0];
                        HistoricalVFinalContract= HistoricalContractList[1];
                    }
                }else if(att.ASI_CRM_Type__c=='Contract Data' && ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0' ){
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        NewContractV0Esitimate= ContractList[0];
                        NewContactV0Contract= ContractList[1];
                    }
                }else if(att.ASI_CRM_Type__c=='Historical Modi Data' && ContractSelected.ASI_CRM_CN_PO_Version__c !='0.0' ){
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        NewContractV0Esitimate= ContractList[0];
                        NewContactV0Contract= ContractList[0];
                    }
                }else if(att.ASI_CRM_Type__c=='PO Modification Data'){
                    JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        NewContactVFinal= ContractList[0];
                    }
                }
            }
        }



        // Get 0.0 Data if current PO is PO Modification
        if(ContractSelected.ASI_CRM_CN_PO_Version__c!='0.0' && ContractSelected.ASI_CRM_CN_V0_0_PO_version__c !=null){
            List<ASI_Attachment__c> V0AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c
            WHERE ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c ];
            for(ASI_Attachment__c att:V0AttachmentList){
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                if(att.ASI_CRM_Type__c=='Historical Data'){
                    List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                    if(HistoricalContractList.size()>0){
                        HistoricalV00Contract= HistoricalContractList[0];
                        HistoricalVFinalContract= HistoricalContractList[1];
                    }
                }else if(att.ASI_CRM_Type__c=='Contract Data'  ){
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        NewContractV0Esitimate= ContractList[0];
                        NewContactV0Contract= ContractList[1];
                    }
                }

            }
        }



        System.debug('Now HistoricalV00Contract ContractId : '+HistoricalV00Contract.ContractId);
        if(HistoricalV00Contract.ContractId!='' ){
            ExistHistoricalData=true;
        }

        //
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmentationCriteriaMap =  new Map<String,ASI_CRM_SegmentationCriteria__c>();
        String segmentationRecordType = ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0' ? 'ASI_CRM_CN_PO_Open_Checkpoint_Criteria_TOT_MOT_Contract' : 'ASI_CRM_CN_PO_Modi_Checkpoint_Criteria_TOT_MOT_Contract';
        SegmentationCriteriaMap = ASI_CRM_CN_ContractOffUtilClass.RetrieveCheckPointCriteriaMap(ContractSelected,segmentationRecordType);

        System.debug('SegmentationCriteriaMap Size:'+SegmentationCriteriaMap.size());
        // looping SegmentationCriteriaMap Line
        for(String key: SegmentationCriteriaMap.keySet()){
            System.debug('Data:'+SegmentationCriteriaMap.get(key));
            interimData temp = new interimData (SegmentationCriteriaMap.get(key));
            if(ContractSelected.ASI_CRM_CN_Is_Dolphin__c || (!ContractSelected.ASI_CRM_CN_Is_Dolphin__c && temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c != 'Trade Expenses: Total PO' && temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c != 'Trade Expenses: Total Rate')){
                temp= FirstDimensionAssignment(temp);
                temp= SecondDimensionAssignment(temp);
                temp=DataOperationChecking(temp);
                temp=DisplayFormating(temp);
                if(temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI') && !AdorAbove){
                    temp.DisplayToUser=false;
                }

                Boolean AllowPut= true;

                //decide if it allow to put
                if(( temp.SegmentationCriteria.ASI_CRM_1st_Dimension__c!=null && temp.SegmentationCriteria.ASI_CRM_1st_Dimension__c.contains('Historical') ) || ( temp.SegmentationCriteria.ASI_CRM_2nd_Dimension__c !=null && temp.SegmentationCriteria.ASI_CRM_2nd_Dimension__c.contains('Historical') ) ){
                    if(ExistHistoricalData){
                        AllowPut=true;
                    }else{
                        AllowPut=false;
                    }
                }


                if(temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Methodology') && temp.Display1stResultEN.contains('No Data')){
                    AllowPut=false;
                }



                if(AllowPut){
                    if(temp.ReachTarget =='Yes'){//Success
                        /*if(temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Total PO' || temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Total Rate'){
                            if(ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
                                SuccessCheckPointList.add(temp);
                            }
                        }else{
                            SuccessCheckPointList.add(temp);
                        }*/
                        SuccessCheckPointList.add(temp);
                    }else{//Failed
                        if(temp.SegmentationCriteria.ASI_CRM_RVP_Special_Approval__c){
                            NeedPRVApproval=true;
                        }
                        FailedCheckPointList.add(temp);
                        /*if(temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Total PO' || temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Total Rate'){
                            if(ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
                                FailedCheckPointList.add(temp);
                            }
                        }else{
                            FailedCheckPointList.add(temp);
                        }*/
                    }

                }
            }

        }
        //check if we need to display this part
        if(FailedCheckPointList.size()==0){
            DisplayFailedCheckPointPart=false;
        }
        if(SuccessCheckPointList.size()==0){
            DisplaySuccessCheckPointPart=false;
        }

    }

    public interimData DisplayFormating(interimData InputInterimData){

        return InputInterimData;
    }


    /**
     * Generate dimension 2 number. Base on InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c, the number will be different.
     *
     *
     * @param InputInterimData
     * @param num Used when operation = within. 1 will calculate lower bound and 2 will calculate upper bound
     *
     * @return
     */
    public static Decimal generateDimension2Number(interimData InputInterimData, Integer num) {
        Decimal Dimension2Number = InputInterimData.Dimension2ndResult;
        num = num == null? 1 : num;

        if (InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c != null) {

            Decimal percentage = InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c;
            Decimal value = InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c;

            // Not Theoretical Value
            if (InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c == 'Within' && num == 1) {
                if (InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Down__c != null) {
                    Dimension2Number = Dimension2Number - InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Down__c;
                }
                if (InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Percent_Down__c != null) {
                    Dimension2Number = (1 - InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Percent_Down__c / 100) * Dimension2Number;
                }
            } else if (InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c == 'Within' && num == 2) {
                if (InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Up__c != null) {
                    Dimension2Number = Dimension2Number + InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Up__c;
                }
                if (InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Percent_Up__c != null) {
                    Dimension2Number = (1 + InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Percent_Up__c / 100) * Dimension2Number;
                }

            } else {
                //Percentage
                if (percentage != null) {
                    Dimension2Number = (1 + percentage / 100) * Dimension2Number;
                }
                //Value
                Dimension2Number = value != null? value + Dimension2Number : Dimension2Number;
            }

            if (InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c == 'Theoretical Value') {
                if (InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c == 'Within' && num == 1) {
                    Dimension2Number = InputInterimData.SegmentationCriteria.ASI_CRM_Min_Value__c != null? InputInterimData.SegmentationCriteria.ASI_CRM_Min_Value__c : 0 ;
                } else if (InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c == 'Within' && num == 2) {
                    Dimension2Number = InputInterimData.SegmentationCriteria.ASI_CRM_Max_Value__c != null? InputInterimData.SegmentationCriteria.ASI_CRM_Max_Value__c : 0 ;
                } else {
                    Dimension2Number = percentage != null? percentage : value;
                }
            }
        }

        //Set Scale
        if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Fixed Expense')) {
            Dimension2Number = Dimension2Number.setScale(0);
        } else {
            Dimension2Number = Dimension2Number.setScale(2);
        }

        return Dimension2Number;
    }




    //perform data level checking
    public interimData DataOperationChecking(interimData InputInterimData){
        String financialIndicator = InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c;
        if(financialIndicator =='Period: PO Start Date'){
            Date Period2Date= InputInterimData.Period2ndResult;
            System.debug('InputInterimData.Period2ndResult : '+InputInterimData.Period2ndResult);
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c!=null){
                Integer AddDay= Integer.valueOf(InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c);
                System.debug(Period2Date+'AddDay : '+AddDay);
                Period2Date= Period2Date.addDays(AddDay);
                if(AddDay>=0){
                    InputInterimData.Display2ndResult+='+ ';
                    InputInterimData.Display2ndResultEN+='+ ';
                }
                InputInterimData.Display2ndResult+=+String.valueOf(AddDay)+' 天';
                InputInterimData.Display2ndResultEN+=+String.valueOf(AddDay)+' day(s).';
            }

            if(ASI_CRM_CN_HeavyContractUtilitiesClass.DateOperationChecking(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c,InputInterimData.Period1stResult,Period2Date)){//if(InputInterimData.Period1stResult<Period2Date){
                InputInterimData.ReachTarget ='No';
            }
            InputInterimData.Display1stResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c +' = '+ InputInterimData.Period1stResult.format();
            InputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c) +' = '+ InputInterimData.Period1stResult.format();

        } else {
            //Number
            Decimal Dimension2Value1 = generateDimension2Number(InputInterimData, 1);
            Decimal Dimension2Value2 = generateDimension2Number(InputInterimData, 2);

            InputInterimData.Dimension1stResult = InputInterimData.Dimension1stResult.setScale(2);

            if(financialIndicator == 'Trade Expenses: Total PO' && ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
                if (!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c, InputInterimData.Dimension1stResult, Dimension2Value1*CustomSetting.ASI_CRM_CN_Dolphin_POModi_Threshold__c/100, Dimension2Value2)) {
                    InputInterimData.ReachTarget = 'No';
                }
            }else{
                if (!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c, InputInterimData.Dimension1stResult, Dimension2Value1, Dimension2Value2)) {
                    InputInterimData.ReachTarget = 'No';
                }
            }

            //Set displaying result
            ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria,'1');
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: GS% by Subbrand') {
                for (Decimal percentage : FIMasterData.SubBrandGSPercentageMap.values()) {
                    if (percentage >= InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c) {
                        InputInterimData.ReachTarget = 'No';
                        break;
                    }
                    InputInterimData.ReachTarget = 'Yes';
                }

                for (String subBrandId : FIMasterData.SubBrandGSPercentageMap.keySet()) {
                    ASI_CRM_CN_OffContractUtilitiesClass.ContractLine contractLine = FIMasterData.ContractLineMap.get(subBrandId);
                    InputInterimData.Display1stResult += contractLine.SubBrandName + ': ' + FIMasterData.SubBrandGSPercentageMap.get(subBrandId).setScale(2) + '%<br/>';
                    InputInterimData.Display1stResultEN += contractLine.SubBrandName + ': ' + FIMasterData.SubBrandGSPercentageMap.get(subBrandId).setScale(2) + '%<br/>';
                }
            } else {
                 if(financialIndicator == 'Trade Expenses: Total Rate' && ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
                    InputInterimData.Display1stResultEN = InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c + ' = ' + InputInterimData.Dimension1stResult.format() + '%';
                    InputInterimData.Display1stResult = ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c) + ' = ' + InputInterimData.Dimension1stResult.format() + '%'; 
                 }else{
                    InputInterimData.Display1stResultEN = InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c + ' = ' + InputInterimData.Dimension1stResult.format();
                    InputInterimData.Display1stResult = ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c) + ' = ' + InputInterimData.Dimension1stResult.format();
                 }
             }


            if (InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c != null) {
                InputInterimData.Display2ndResultEN = InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
                InputInterimData.Display2ndResult = ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);
            } else {

                InputInterimData.Display2ndResultEN = 'Theoretical Value';
                InputInterimData.Display2ndResult = ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Theoretical Value');
            }

            if (InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c != 'Within') {
                Decimal result = InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c != null ? Dimension2Value1 : InputInterimData.Dimension2ndResult.setScale(2);
                if (InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c == 'Theoretical Value') {
                    result = InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c != null ? InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c : InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c;
                }
                if(financialIndicator == 'Trade Expenses: Total Rate' && ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
                    InputInterimData.Display2ndResultEN += ' = ' + result.format() + '%';
                    InputInterimData.Display2ndResult += ' = ' + result.format() + '%';
                }else{
                    InputInterimData.Display2ndResultEN += ' = ' + result.format();
                    InputInterimData.Display2ndResult += ' = ' + result.format();
                }
            } else {// within display
                InputInterimData.Display2ndResultEN += ' :<br/>  Min = ' + Dimension2Value1.format() + '<br/> Max = ' + Dimension2Value2.format();
                InputInterimData.Display2ndResult += ' :<br/> 最小值 =  ' + Dimension2Value1.format() + '<br/> 最大值 = ' + Dimension2Value2.format();
            }

        }


        return InputInterimData;
    }

    //2nd Dimension Assignment
    public interimData SecondDimensionAssignment(interimData InputInterimData){

        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')){
            InputInterimData.Dimension2ndResult = ByVolumeFinancialIndicator(InputInterimData.SegmentationCriteria,'2');

        }else{
            if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c !=null){
                ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria,'2');
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Other Cost%'){
                    InputInterimData.Dimension2ndResult= FIMasterData.OtherExpensesRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Display'){
                    InputInterimData.Dimension2ndResult= FIMasterData.DisplayExpensesTotal;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Other Cost'){
                    InputInterimData.Dimension2ndResult= FIMasterData.OtherExpensesTotal;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){
                    InputInterimData.Dimension2ndResult= FIMasterData.InvestmentCR12;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI(Pro-forma)'){
                    InputInterimData.Dimension2ndResult= FIMasterData.ROIProForma;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI')){//InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI'
                    InputInterimData.Dimension2ndResult= FIMasterData.ROIIntake;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date'){
                    InputInterimData.Period2ndResult= FIMasterData.POStartDate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: GS Total') {
                    InputInterimData.Dimension2ndResult = FIMasterData.GrossSalesTotal;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: Total GS%') {
                    InputInterimData.Dimension2ndResult = FIMasterData.GrossSalesRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Total PO'){
                    InputInterimData.Dimension2ndResult = FIMasterData.TradeExpenses;
                    System.debug(LoggingLevel.INFO, '*** InputInterimData.Dimension2ndResult: ' + InputInterimData.Dimension2ndResult);
                }

            }else{
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c!=null){
                    InputInterimData.Dimension2ndResult= InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c;
                }
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c!=null){
                    InputInterimData.Dimension2ndResult= InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c;
                }
            }

        }


        if(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c !=null){
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PO Submit Date'){
                InputInterimData.Period2ndResult=Date.today();

                InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c+' = Today';
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c)+'=Today (今天)';
            }

        }else{
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c =='Period: PO Start Date'){
                InputInterimData.Display2ndResultEN= InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c+' = '+ InputInterimData.Period2ndResult;
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c)+' = '+ InputInterimData.Period2ndResult;
            }

        }




        return InputInterimData;
    }




    //First Dimension Assignment
    public interimData FirstDimensionAssignment(interimData InputInterimData){

        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')){
            InputInterimData.Dimension1stResult = ByVolumeFinancialIndicator(InputInterimData.SegmentationCriteria,'1');
        }else{
            ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria,'1');
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Other Cost%'){
                InputInterimData.Dimension1stResult= FIMasterData.OtherExpensesRate;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Display'){
                InputInterimData.Dimension1stResult= FIMasterData.DisplayExpensesTotal;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){
                InputInterimData.Dimension1stResult= FIMasterData.InvestmentCR12;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Other Cost'){
                InputInterimData.Dimension1stResult= FIMasterData.OtherExpensesTotal;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI(Pro-forma)'){
                InputInterimData.Dimension1stResult= FIMasterData.ROIProForma;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI(Actual)'){
                InputInterimData.Dimension1stResult= FIMasterData.ROIActual;
            } else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI')){//else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI' || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI(Actual)'){
                InputInterimData.Dimension1stResult= FIMasterData.ROIIntake;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Trade Expenses: Display%'){
                InputInterimData.Dimension1stResult=FIMasterData.DisplayExpensesRate;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date') {
                InputInterimData.Period1stResult = FIMasterData.POStartDate;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: GS Total') {
                InputInterimData.Dimension1stResult = FIMasterData.GrossSalesTotal;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: Total GS%') {
                InputInterimData.Dimension1stResult = FIMasterData.GrossSalesRate;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Total PO'){
                InputInterimData.Dimension1stResult = FIMasterData.TradeExpenses;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Total Rate'){
                InputInterimData.Dimension1stResult = FIMasterData.DolphinContractPercent;
            }
        }
        return InputInterimData;
    }


    public Decimal ByVolumeFinancialIndicator(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria,String Dimension){
        Decimal ReturnResult=0.0;
        ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputSegmentationCriteria,Dimension);
        if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Volume: Total'){
            ReturnResult = FIMasterData.Volumes;
        }else if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains(' - ')){
            List<String> parts = InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.split(' - ');
            String GroupingName = parts[1];
            if (InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Category')){
                if(FIMasterData.CategoryVolumeMap.size()>0){
                    if(FIMasterData.CategoryVolumeMap.containsKey(GroupingName) && FIMasterData.CategoryVolumeMap.get(GroupingName) !=null ){
                        ReturnResult=FIMasterData.CategoryVolumeMap.get(GroupingName);
                    }
                }
            }else{ // By Grade
                if(FIMasterData.SubBrandGradeGrouping.size()>0){
                    if(FIMasterData.SubBrandGradeGrouping.containsKey(GroupingName) && FIMasterData.SubBrandGradeGrouping.get(GroupingName) !=null ){
                        ReturnResult=FIMasterData.SubBrandGradeGrouping.get(GroupingName);
                    }
                }
            }

        }

        ReturnResult=ReturnResult.setScale(0);
        return ReturnResult;
    }


    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator FinancialIndicatorMasterData(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria, String Dimension) {
        String dimensionStr = Dimension == '1'? InputSegmentationCriteria.ASI_CRM_1st_Dimension__c : InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c;

        if (dimensionStr == 'Historical V0.0') {
            return  HistoricalV00Contract;
        } else if (dimensionStr == 'Historical Vfinal') {
            return  HistoricalVFinalContract;
        } else if (dimensionStr == 'New Contact V0.0 Contract') {
            System.debug(LoggingLevel.INFO, '*** NewContactV0Contract: ' + NewContactV0Contract);
            return  NewContactV0Contract;
        } else if (dimensionStr == 'New Contract V0.0 Est.') {
            System.debug(LoggingLevel.INFO, '*** NewContractV0Esitimate: ' + NewContractV0Esitimate);
            return  NewContractV0Esitimate;
        } else if (dimensionStr == 'New Contract V Final') {
            return  NewContactVFinal;
        } else {
            return new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator();
        }

    }

    public PageReference CancelProcess(){
        PageReference pageRef = null;

        ProcessPermission = true;
        pageRef = new PageReference('/'+PageId);
        pageRef.setRedirect(true);
        return pageRef;
    }


    //Validation
    public void ValidationChecking(){
        //Contract generation checking
        List<ASI_CRM_Contract_Printout_Setting__c> ContractSettingList = new List<ASI_CRM_Contract_Printout_Setting__c>();
        try{
            ContractSettingList= [SELECT Id,ASI_CRM_Header_Section_Name__c,ASI_CRM_isVisible__c,ASI_CRM_Section_Content__c,ASI_CRM_Content_Section_Name__c
            FROM ASI_CRM_Contract_Printout_Setting__c WHERE ASI_CRM_Contract__c = :ContractSelected.Id];
        }catch(Exception e){
            String msgstr = 'ValidationChecking: ' +e.getMessage();
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_OffCheckPointResultPage  '+ msgstr+' with contract Id '+ContractSelected.Id , 'ASI_CRM_CN_OffCheckPointResultCtrl','ASI_CRM_CN_HeavyCheckPointResultCtrl.ValidationChecking');
        }
        //If the editable terms in the Contract Generation Page have never been saved, System will show a error message and prevent sales from submitting for approval.
        if(ContractSettingList.isEmpty() && ContractSelected.ASI_CRM_CN_Use_PRC_Contract_Template__c){
            ProcessPermission = false;
            Msg+=' '+Label.ASI_CRM_CN_Contract_Generation_Page_No_Save; //The editable terms in the Contract Generation Page have never been saved
        }


        //************Business License Checking ***********
        Decimal TotalAmountChecking=1000000;
        Decimal FixedAmountChecking=50000;
        ASI_CRM_CN_CustomSetting__c checking =[SELECT Id,ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c,ASI_CRM_Total_Amount_Checking__c FROM ASI_CRM_CN_CustomSetting__c ][0];

        if(checking.ASI_CRM_Total_Amount_Checking__c!=null){
            TotalAmountChecking =checking.ASI_CRM_Total_Amount_Checking__c;
        }

        if(checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c!=null){
            FixedAmountChecking =checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c;
        }

        //If a PO meets the criteria (Total PO contract amount >= 1M RMB OR Fixed cost total >= 50K RMB),System will show a warning message (but allow to save)
        //if no business license is uploaded or the uploaded business license is invalid (i.e. the start date & end date of the uploaded business license do not cover the PO period).
        Boolean ShowWarning= false;
        // if total > 2M RMB Vol Budget/LE (9L) & A&P Budget/LE (RMB) is mandatory. if Vol Budget/LE or A&P Budget/LE is blank Reason without Budget/LE is mandatory.
        if ((PSFTotal+DisplayTotal+FixedCostTotal) > 2000000) {
            if ((ContractSelected.ASI_CRM_CN_Vol_Budget_LE__c == null || ContractSelected.ASI_CRM_CN_Budget_LE__c == null) && String.isEmpty(ContractSelected.ASI_CRM_CN_Reason_without_Budget__c)) {
                ProcessPermission = false;
                Msg += Label.ASI_CRM_CN_Budget_LE_Validation + '<br/>';
            }
        }
        //A/B total amount > ASI_CRM_CN_Dolphin_Online_Cont_Threshold__c
        if((PSFTotal+FixedCostTotal)> CustomSetting.ASI_CRM_CN_Dolphin_Online_Cont_Threshold__c 
                && ContractSelected.ASI_CRM_CN_Use_PRC_Contract_Template__c == false && ContractSelected.ASI_CRM_CN_Is_Dolphin__c && (ContractSelected.ASI_CRM_CN_Contract_Classification__c == 'A' || ContractSelected.ASI_CRM_CN_Contract_Classification__c == 'B')){
            ShowWarning = true;
            WarningMsg += Label.ASI_CRM_CN_OnlineContract_Validation + '<br/>';
        }
        if ((PSFTotal + DisplayTotal + FixedCostTotal) > TotalAmountChecking || (DisplayTotal + FixedCostTotal) > FixedAmountChecking) {
            if (!ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c) {
                ShowWarning = true;
                WarningMsg += Label.ASI_CRM_CN_Business_License_not_uploaded + '<br/>';//Please note that Business License have not uploaded.
            } else {
                if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c != null) {
                    if (ContractSelected.ASI_CRM_CN_PO_Start_Date__c < ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c) {
                        ShowWarning = true;
                        WarningMsg += Label.ASI_CRM_CN_Business_License_after_PO_start_Date_Error + '<br/>';//Please note that the Start Date of Business License is after the PO start Date.
                    }
                }
                if (!ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c) {
                    if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c != null) {
                        if (ContractSelected.ASI_CRM_CN_PO_End_Date__c > ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c) {
                            ShowWarning = true;
                            WarningMsg += Label.ASI_CRM_CN_Business_License_before_PO_end_Date_Error + '<br/>';//Please note that the End Date of Business License is before the PO end Date.
                        }
                    }
                }
            }
        }// ending of checking


        if(ShowWarning){
            WarningTimes++;
        }


    }


    public void checkUserID(){
        List<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0)
            AdorAbove = true;
    }

    public void POModiValidationChecking(){
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable(ContractSelected);
        Boolean validByACCode = true;
        for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary SummaryData:PaymentSummaryList){//POEstimatedAmount
            System.debug('SummaryData : '+SummaryData);
            // Decimal PORemainAmt=SummaryData.POEstimatedAmount-SummaryData.PaidAmount; // change  LastVersion_POEstimatedAmount to  POEstimatedAmount
            if(SummaryData.PaymentRequestAmount>SummaryData.POEstimatedAmount+1){
                validByACCode = false;
                //Msg+=SummaryData.PaymentRequestAmount+ '  Test  '+SummaryData.POEstimatedAmount ;
            }
        }

        if(!validByACCode){
            ProcessPermission = false;
            Msg+=Label.ASI_CRM_CN_ContractAmountByACCheckErrMsg;
        }
    }

    public void PreSaveRecord(){
        List<ASI_Attachment__c> AttachmentList= new  List<ASI_Attachment__c>();


        try{

            if(NeedPRVApproval){
                ContractSelected.ASI_CRM_RVP_Approval__c=true;
            }else{
                ContractSelected.ASI_CRM_RVP_Approval__c=false;
            }
            update ContractSelected;


            String  SuccessCheckPointString= System.JSON.serialize(SuccessCheckPointList);
            SuccessCheckPointString=SuccessCheckPointString.replaceAll('<','&lt;');
            SuccessCheckPointString=SuccessCheckPointString.replaceAll('>','&gt;');

            String  FailedCheckPointString= System.JSON.serialize(FailedCheckPointList);
            FailedCheckPointString=FailedCheckPointString.replaceAll('<','&lt;');
            FailedCheckPointString=FailedCheckPointString.replaceAll('>','&gt;');

            AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c
            WHERE ASI_CRM_Contract__c = :ContractSelected.Id AND ASI_CRM_Type__c LIKE 'CheckPoint%'];
            if(AttachmentList.size()>0){//exist
                for(ASI_Attachment__c attachment:AttachmentList){
                    if(attachment.ASI_CRM_Type__c=='CheckPoint-Success'){
                        attachment.ASI_CRM_Historical_Financial_Data__c=SuccessCheckPointString ;
                    }
                    if(attachment.ASI_CRM_Type__c=='CheckPoint-Failed'){
                        attachment.ASI_CRM_Historical_Financial_Data__c=FailedCheckPointString;
                    }
                }
            }else{ // size ==0;
                AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Contract__c=ContractSelected.Id,ASI_CRM_Type__c='CheckPoint-Success',ASI_CRM_For_Contract_Use__c=true,
                    ASI_CRM_Historical_Financial_Data__c=SuccessCheckPointString));
                AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Contract__c=ContractSelected.Id,ASI_CRM_Type__c='CheckPoint-Failed',ASI_CRM_For_Contract_Use__c=true,
                    ASI_CRM_Historical_Financial_Data__c=FailedCheckPointString));
            }
            upsert AttachmentList;



        }catch(Exception e){
            ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '+ 'Upsert ASI_CRM_CN_HeavyCheckPointResultPage Attachment  Error : ' +e.getMessage()+' with contract Id '+ContractSelected.Id + ' with Json string : '+ System.JSON.serialize(FailedCheckPointList) , 'ASI_CRM_CN_HeavyCheckPointResultCtrl','ASI_CRM_CN_HeavyCheckPointResultCtrl.proceed');
        }
    }




    public PageReference proceed() {
        ProcessPermission = true;
        Msg='';
        WarningMsg='';


        if(!ContractSelected.ASI_CRM_CN_PO_Modification__c){
            ValidationChecking();
        }else{
            POModiValidationChecking();
        }

        if(ProcessPermission && WarningTimes!=1 ){
            try{
                if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c != null){
                    if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c <getFiscalYearStart(System.today()).addYears(1)){
                        ContractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
                    }
                    else{
                        ContractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(ContractSelected.ASI_CRM_CN_PO_Start_Date__c);
                    }
                }else{
                    ContractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
                }


                update ContractSelected;


                PreSaveRecord();

            }catch(Exception e){
                String msgstr = 'Upsert ASI_CRM_CN_HeavyCheckPointResultPage Attachment  Error : ' +e.getMessage();
                ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '+ msgstr+' with contract Id '+ContractSelected.Id + ' with Json string : '+ System.JSON.serialize(FailedCheckPointList) , 'ASI_CRM_CN_HeavyCheckPointResultCtrl','ASI_CRM_CN_HeavyCheckPointResultCtrl.proceed');
            }

            //submit for approval
            if(!Test.isRunningTest()){
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); req1.setObjectId(ContractSelected.Id); Approval.ProcessResult result = Approval.process(req1);
            }


            return new PageReference('/' + ContractSelected.Id);

        }else{
            return null;
        }


    }



    public Date getFiscalYearStart(Date inputDate){
        //Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Date fiscalYearStart;
        if(inputDate != null){
            fiscalYearStart = Date.newInstance(inputDate.year(), orgFiscalMonth, 1);
            if(inputDate.month() < orgFiscalMonth && inputDate.year() == inputDate.year())
                fiscalYearStart = fiscalYearStart.addYears(-1);
        }
        System.debug(inputDate + '/' + fiscalYearStart);
        return fiscalYearStart;
    }
}