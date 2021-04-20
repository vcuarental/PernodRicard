/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffPaymentCheckCtrl
 * Description: Apex class for ASI_CRM_CN_OffPaymentCheckCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-07       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_OffPaymentCheckCtrl {
    public ASI_TH_CRM_PaymentRequest__c PaymentRequest {set;get;}
    public String PageId {set;get;}
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;} {ContractSelected=new ASI_TH_CRM_Contract__c();}
    public Boolean AdorAbove {set;get;}{AdorAbove=false;}


    public Boolean ShowSubmitApproval {set;get;} {ShowSubmitApproval=false;}


    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> SuccessCheckPointList {set;get;}  {SuccessCheckPointList = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}
    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> FailedCheckPointList {set;get;}  {FailedCheckPointList = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}
    public Boolean NeedRVPApproval {get;set;}{NeedRVPApproval=false;}
    public Date CutOffDay {set;get;}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator HistoricalV00Contract  {set;get;} { HistoricalV00Contract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator HistoricalVFinalContract  {set;get;} { HistoricalVFinalContract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContractV0Estimate {set;get;} { NewContractV0Estimate = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContactVFinal  {set;get;} { NewContactVFinal = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator POModificationData  {set;get;} { POModificationData = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}


    public Boolean showCN {set;get;}
    public String Msg {get;set;} {Msg='';}

    public Boolean ProcessPermission {get;set;}{ProcessPermission=true;}
    public ASI_CRM_CN_OffPaymentUtilClass.FinancialIndicator paymentFI {get;set;} {
        paymentFI =new ASI_CRM_CN_OffPaymentUtilClass.FinancialIndicator(); }

    public Decimal PSFPaymentTotal {get;set;}{PSFPaymentTotal =0;}
    public Decimal DisplayPaymentTotal {get;set;}{DisplayPaymentTotal =0;}
    public Decimal otherCostPaymentTotal {get;set;}{otherCostPaymentTotal =0;}

    public Decimal PaymentSpeed {set;get;}{PaymentSpeed=0.0;}
    public Decimal VolumeSpeed {set;get;}{VolumeSpeed=0.0;}


    public Boolean DisplaySuccessCheckPointPart {get;set;}{DisplaySuccessCheckPointPart=true;}
    public Boolean DisplayFailedCheckPointPart {get;set;}{DisplayFailedCheckPointPart=true;}
    public Decimal PRCGuidance   {set;get;} {PRCGuidance=0.0;}
    Map<String, String> productCategoryChineseNameByEnglishName;
    public ASI_CRM_CN_OffPaymentCheckCtrl(ApexPages.StandardController controller) {
        this.PaymentRequest = (ASI_TH_CRM_PaymentRequest__c)controller.getRecord();
        if(this.PaymentRequest != null)
            PageId = PaymentRequest.Id;
        List <ASI_TH_CRM_PaymentRequest__c> HeaderList  = new List <ASI_TH_CRM_PaymentRequest__c>();



        Map<String, String> params = ApexPages.currentPage().getParameters();
        String TypeName = params.get('Type');
        if(TypeName =='SubmitApproval'){
            ShowSubmitApproval =true;
        }


        //Get Header information
        if (PageId != null){
            HeaderList = [SELECT Id, Name,Owner.Name,ASI_TH_CRM_Contract__r.ASI_CRM_CN_RContract_Fixed_Cost_Total__c,ASI_TH_CRM_Contract__r.ASI_CRM_Contract_Total_Dummy__c,
                ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c,ASI_CRM_Volume_Cut_Off_Date__c,
                ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c,
                ASI_CRM_Total_Actual_Amount__c,ASI_CRM_CN_Payable_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c, ASI_CRM_CN_Other_Reason__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_Last_Year_Payment__c,ASI_CRM_CN_Division__c,ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_Volume_Option__c,ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c, ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, ASI_CRM_CN_PO_Version_Latest__c, ASI_CRM_CN_Overpayment_Reason__c,ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, ASI_CRM_CN_Business_License_Qualify__c ,ASI_CRM_CN_Total_PSF_Amount__c,
                ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c   , ASI_CRM_CN_Total_Payment__c , ASI_CRM_CN_Overpayment_Comment__c,ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Total_BRSF_Actual_Amount__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c  ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c, ASI_CRM_New_FY_Payment__c,
                ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_Channel_Group__c , (select Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c from ASI_CRM_Modules__r)
                
            FROM ASI_TH_CRM_PaymentRequest__c WHERE Id = :PageId];

        }
        if (HeaderList.size()> 0){
            this.PaymentRequest = HeaderList[0];
        }
        checkUserID();

        productCategoryChineseNameByEnglishName = new Map<String, String>();
        List<ASI_HK_CRM_Product_Category__c> productCategories = [
            SELECT Id,ASI_HK_CRM_English_Name__c,ASI_CRM_CN_Chinese_Name__c
            FROM ASI_HK_CRM_Product_Category__c
            WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Product_Category'
            AND ASI_HK_CRM_English_Name__c != 'RTD'
            AND ASI_HK_CRM_English_Name__c != 'Baijiu'
        ];
        for (ASI_HK_CRM_Product_Category__c productCategory : productCategories) {
            productCategoryChineseNameByEnglishName.put(productCategory.ASI_HK_CRM_English_Name__c, productCategory.ASI_CRM_CN_Chinese_Name__c);
        }
        
        init();
    }


    public void init(){
        paymentFI =new ASI_CRM_CN_OffPaymentUtilClass.FinancialIndicator();

        Boolean ExistHistoricalData=false;
        NeedRVPApproval=false;
        CutOffDay=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        VolumeSpeed=0;

        Map<String,ASI_CRM_SegmentationCriteria__c> SegmentationCriteriaMap =  new Map<String,ASI_CRM_SegmentationCriteria__c>();

        ASI_CRM_CN_CustomSetting__c CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        PRCGuidance=CustomSetting.ASI_CRM_PRC_Guidance__c;

        //Getting Contract
        ContractSelected = [SELECT Id,Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_Is_Dolphin__c,
            ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__c,
            Owner.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c,ASI_CRM_CN_Expected_Display_Est_Total__c,
            (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
            ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c
        From ASI_TH_CRM_PaymentRequests_Contract__r)
        FROM ASI_TH_CRM_Contract__c WHERE Id =:PaymentRequest.ASI_TH_CRM_Contract__c ];

        //FICalculation();
        String V0ContractID='';

        List<ASI_Attachment__c> AttachmentList= new List<ASI_Attachment__c>();
        if(ContractSelected.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractID=ContractSelected.ASI_CRM_CN_V0_0_PO_version__c;
            AttachmentList= [select Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c
            where ASI_CRM_Contract__c = :ContractSelected.Id or ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c];
        }else{
            //Geting HistoricalV0.0 and VFinal Data
            AttachmentList= [select Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c
            where ASI_CRM_Contract__c = :ContractSelected.Id ];
            V0ContractID=ContractSelected.Id;
        }


        for (ASI_CRM_CN_ContractOffUtilClass.PaymentSummary paymentSummary : ASI_CRM_CN_ContractOffUtilClass.PaymentSummaryTable(PaymentRequest, ContractSelected)) {
            if (paymentSummary.Name == '合同奖励') {
                PSFPaymentTotal = paymentSummary.PaymentRequestAmount;
            } else if (paymentSummary.Name == '常规陈列费') {
                DisplayPaymentTotal = paymentSummary.PaymentRequestAmount;
            } else {
                otherCostPaymentTotal += paymentSummary.PaymentRequestAmount;
            }
        }
        // Dolphin合同不显示display金额，加到outher Cost金额里，Added by Zhonghui, 2020-10-14
        if (ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
            otherCostPaymentTotal += DisplayPaymentTotal;
            DisplayPaymentTotal = 0;
        }

        for(ASI_Attachment__c att:AttachmentList){
            String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');

            //General Payment Info
            if(att.ASI_CRM_Type__c=='Payment Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){
                paymentFI = (ASI_CRM_CN_OffPaymentUtilClass.FinancialIndicator)System.JSON.deserialize(JsonString,ASI_CRM_CN_OffPaymentUtilClass.FinancialIndicator.class);
            }
            if(att.ASI_CRM_Type__c=='Historical Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){
                List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                if(HistoricalContractList.size()>0){
                    HistoricalV00Contract= HistoricalContractList[0];
                    HistoricalVFinalContract= HistoricalContractList[1];
                }
            }
            if(att.ASI_CRM_Type__c=='Contract Data' && att.ASI_CRM_Contract__c==V0ContractID){// V0.0
                JsonString = JsonString.replaceAll('&quot;','"');
                List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                if(ContractList.size()>0){
                    NewContractV0Estimate = ContractList[0];
                    NewContactV0Contract= ContractList[1];
                }
            }
            if(att.ASI_CRM_Type__c=='PO Modification Data'){
                JsonString = JsonString.replaceAll('&quot;','"');
                List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                if(ContractList.size()>0){
                    System.debug('att id ' + att.Id);
                    POModificationData = ContractList[0];
                }
            }
            if(att.ASI_CRM_Type__c=='Last Payment Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){
                JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                if(ContractList.size()>0){
                    NewContactVFinal= ContractList[0];
                }
            }


        }

        System.debug('paymentFI====' + paymentFI);

        if(!PaymentRequest.ASI_CRM_CN_Last_Payment__c){// if not last payment
            //All Payment Total Amount
            SegmentationCriteriaMap = ASI_CRM_CN_ContractOffUtilClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_Payment_Checkpoint_Criteria_TOT_MOT_Contract');
            for(String key: SegmentationCriteriaMap.keySet()){
                ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData temp = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaMap.get(key));

                temp= NormalPayment1stDimensionAssign(temp);
                temp= NormalPayment2ndDimensionAssign(temp);
                temp= DataOperationChecking(temp);

                if(CheckingDisplayOrNot(temp)){
                    if(temp.ReachTarget =='No'){
                        if(temp.SegmentationCriteria.ASI_CRM_RVP_Special_Approval__c){
                            NeedRVPApproval=true;
                        }
                        FailedCheckPointList.add(temp);
                    }else{
                        SuccessCheckPointList.add(temp);
                    }

                }

            }
        }else{ // which is last payment



            if(HistoricalV00Contract.ContractId!='' ){
                ExistHistoricalData=true;
            }


            SegmentationCriteriaMap = ASI_CRM_CN_ContractOffUtilClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_Last_Payment_Checkpoint_Criteria_TOT_MOT_Contract');
            for(String key: SegmentationCriteriaMap.keySet()){
                ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData temp = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaMap.get(key));

                temp= setDimensionResult(temp, '1');
                temp= setDimensionResult(temp, '2');

                temp= NormalPayment1stDimensionAssign(temp);
                temp= NormalPayment2ndDimensionAssign(temp);


                temp= DataOperationChecking(temp);
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

                if(AllowPut  && CheckingDisplayOrNot(temp)){
                    if(temp.ReachTarget =='Yes'){
                        SuccessCheckPointList.add(temp);
                    }else{
                        if(temp.SegmentationCriteria.ASI_CRM_RVP_Special_Approval__c){
                            NeedRVPApproval=true;
                        }
                        FailedCheckPointList.add(temp);
                    }
                }


            }
        }


        if(FailedCheckPointList.size()==0){
            DisplayFailedCheckPointPart=false;
        }
        if(SuccessCheckPointList.size()==0){
            DisplaySuccessCheckPointPart=false;
        }

    }









    private Boolean CheckingDisplayOrNot(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        Boolean DisplayOrNot=true;
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Achievement Rate') ){
            if(InputInterimData.Dimension2ndResult==9999999.00 || InputInterimData.Dimension1stResult==9999999.00){
                DisplayOrNot=false;
            }
        }

        return DisplayOrNot;
    }



    //First Dimension Assignment for both Normal and last Payment
    private ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData NormalPayment1stDimensionAssign(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData) {
        if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Payment Speed')) {
            InputInterimData.Dimension1stResult = Decimal.valueOf(paymentFI.PaymentExclOthersSpeed).setScale(2);
        } else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Payment Amount')) {
            InputInterimData.Dimension1stResult = paymentFI.TotalPaymentAmountExclOthers.setScale(2);
        }
        return InputInterimData;
    }


    //2nd Dimension Assignment for last payment both Normal and last Payment
    private ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData NormalPayment2ndDimensionAssign(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData) {
        if (InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c == 'Volume Speed%') {
            InputInterimData.Dimension2ndResult = Decimal.valueOf(paymentFI.VolumeSpeed).setScale(2);
        // } else if (InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c == 'GS Speed%') {
        } else if (InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c == 'Purchase Value Speed%') {
            InputInterimData.Dimension2ndResult = paymentFI.ValueSpeed;
            InputInterimData.Dimension2ndResult = InputInterimData.Dimension2ndResult.setScale(2);
        }  else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Payment Amount')) {
            InputInterimData.Dimension2ndResult = paymentFI.SuggestedPayableAmount;
        } else if (InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c != null) {
            InputInterimData.Dimension2ndResult = InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c;
        }
        if (InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c != null) {
            InputInterimData.Dimension2ndResult = InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c;
        }
        return InputInterimData;
    }













    //perform data level checking
    public ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData DataOperationChecking(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData) {
        setDisplayResult(InputInterimData, '1');
        setDisplayResult(InputInterimData, '2');

        return InputInterimData;
    }


    public void setDisplayResult(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData, String firstOrSecond) {
        String displayResult = '';
        String displayResultEN = '';
        String dimension = firstOrSecond == '1'? InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c : InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
        Decimal dimensionResult = firstOrSecond == '1'? InputInterimData.Dimension1stResult : InputInterimData.Dimension2ndResult;
        Decimal Dimension2Value1 = ASI_CRM_CN_HeavyCheckPointResultCtrl.GenerateDimension2Number1(InputInterimData);//Min
        Decimal Dimension2Value2 = ASI_CRM_CN_HeavyCheckPointResultCtrl.GenerateDimension2Number2(InputInterimData);// Max

        if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c == 'Trade Expenses: ROI(Actual)') {
            System.debug(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c);
            System.debug(InputInterimData.Dimension1stResult);
            System.debug(Dimension2Value1);
            System.debug(Dimension2Value2);
        }
        if (!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c, InputInterimData.Dimension1stResult, Dimension2Value1, Dimension2Value2)) {
            InputInterimData.ReachTarget = 'No';
        }

        ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(dimension);
        ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator firstDimensionFI = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c);
        ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator secondDimensionFI = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);

        if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c == 'Volume: By Category') {
            if (!ASI_CRM_CN_ContractOffUtilClass.compareMap(firstDimensionFI.CategoryVolumeMap, secondDimensionFI.CategoryVolumeMap, InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c)) {
                InputInterimData.ReachTarget = 'No';
            }


            for (String category : FIMasterData.CategoryVolumeMap.keySet()) {
                displayResult += productCategoryChineseNameByEnglishName.get(category) + ': ' + FIMasterData.CategoryVolumeMap.get(category).setScale(2) + '<br/>';
                displayResultEN += category + ': ' + FIMasterData.CategoryVolumeMap.get(category).setScale(2) + '<br/>';
            }
        } else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c == 'Volume: By Brand'){
            if (!ASI_CRM_CN_ContractOffUtilClass.compareMap(firstDimensionFI.BrandVolumeMap, secondDimensionFI.BrandVolumeMap, InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c)) {
                InputInterimData.ReachTarget = 'No';
            }

            for (String brand : FIMasterData.BrandVolumeMap.keySet()) {
                displayResult += brand + ': ' + FIMasterData.BrandVolumeMap.get(brand).setScale(2) + '<br/>';
                displayResultEN += brand + ': ' + FIMasterData.BrandVolumeMap.get(brand).setScale(2) + '<br/>';
            }
        }else {
            if (dimension != null) {
                displayResult = ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(dimension);
                displayResultEN = dimension;
            } else {
                displayResult = ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Theoretical Value');
                displayResultEN = 'Theoretical Value';

            }
            if (InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c == 'Within') {
                displayResult += ' :<br/> 最小值=  ' + Dimension2Value1 + '<br/> 最大值=' + Dimension2Value2;
                displayResultEN += ' :<br/>  Min= ' + Dimension2Value1 + '<br/> Max=' + Dimension2Value2;
            } else {
                displayResult += ' = ' + dimensionResult.format();
                displayResultEN += ' = ' + dimensionResult.format();
            }
        }
        System.debug('displayResult == ' + displayResult);
        System.debug('firstOrSecond == ' + firstOrSecond);
        System.debug('InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c ==' + InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c);

        if (firstOrSecond == '1') {
            InputInterimData.Display1stResult = displayResult;
            InputInterimData.Display1stResultEN = displayResultEN;
        } else {
            InputInterimData.Display2ndResult = displayResult;
            InputInterimData.Display2ndResultEN = displayResultEN;
        }
    }

    public ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData setDimensionResult(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData, String firstOrSecond){
        String dimension = firstOrSecond == '1'? InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c : InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
        Decimal dimensionResult = 0;

        ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(dimension);
        if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c == 'Trade Expenses: Other Cost%') {
            dimensionResult= FIMasterData.OtherExpensesRate;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Display'){
            dimensionResult= FIMasterData.DisplayExpensesTotal;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){
            dimensionResult= FIMasterData.InvestmentCR12;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Other Cost'){
            dimensionResult= FIMasterData.OtherExpensesTotal;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI(Pro-forma)'){
            dimensionResult= FIMasterData.ROIProForma;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI(Actual)'){
            dimensionResult= FIMasterData.ROIActual;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Sales Value'){
            dimensionResult= FIMasterData.Value;
        } else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI')){
            dimensionResult= FIMasterData.ROIIntake;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Trade Expenses: Display%'){
            dimensionResult=FIMasterData.DisplayExpensesRate;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date') {
            InputInterimData.Period1stResult = FIMasterData.POStartDate;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: GS Total') {
            dimensionResult = FIMasterData.GrossSalesTotal;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: Total GS%') {
            dimensionResult = FIMasterData.GrossSalesRate;
        } else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')) {
            dimensionResult = FIMasterData.Volumes;
        }

        dimensionResult = dimensionResult == null ? 0 :  dimensionResult.setScale(2);

        if (firstOrSecond == '1') {
            InputInterimData.Dimension1stResult = dimensionResult;
        } else {
            InputInterimData.Dimension2ndResult = dimensionResult;
        }

        return InputInterimData;

    }



    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator FinancialIndicatorMasterData(String Dimension) {
        ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ReturnFI = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator();
        if (Dimension == 'Historical V0.0') {
            ReturnFI = HistoricalV00Contract;
        } else if (Dimension == 'Historical Vfinal') {
            ReturnFI = HistoricalVFinalContract;
        } else if (Dimension == 'New Contact V0.0 Contract') {
            ReturnFI = NewContactV0Contract;
        } else if (Dimension == 'New Contract V0.0 Est.') {
            ReturnFI = NewContractV0Estimate;
        } else if (Dimension == 'New Contract V Final') {
            ReturnFI = NewContactVFinal;
        }

        return ReturnFI;
    }



    public PageReference CancelProcess(){
        PageReference pageRef = null;

        ProcessPermission = true;
        pageRef = new PageReference('/'+PageId);
        pageRef.setRedirect(true);
        return pageRef;
    }




    public PageReference proceed() {

        Msg='';

        ProcessPermission=true;

        ValidationChecking();


        if(ProcessPermission){



            //submit for approval
            try{

                PreSaveRecord();
                Date VolumeCutOffDate=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
                //update Volume Cut Off Date
                PaymentRequest.ASI_CRM_Volume_Cut_Off_Date__c=VolumeCutOffDate;
                IF(NeedRVPApproval){
                    PaymentRequest.ASI_CRM_RVP_Approval__c=TRUE;
                }ELSE{
                    PaymentRequest.ASI_CRM_RVP_Approval__c=FALSE;
                }

                update PaymentRequest;

                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(PaymentRequest.Id);
                Approval.ProcessResult result = Approval.process(req1);
            }catch(Exception e){
                String msgstr = 'submit for approval Error : ' +e.getMessage();
                ASI_MFM_ByPass_Setting.ErrorHandling('submit for approval '+ msgstr+' with Payment Request Id '+PaymentRequest.Id  , 'ASI_CRM_CN_HeavyPaymentCheckCtrl','ASI_CRM_CN_HeavyPaymentCheckCtrl.proceed');
            }

            return new PageReference('/' + PaymentRequest.Id);
        }
        else{
            return null;
        }


    }

    public void PreSaveRecord(){
        List<ASI_Attachment__c> AttachmentList= new  List<ASI_Attachment__c>();
        try{

            String  SuccessCheckPointString= System.JSON.serialize(SuccessCheckPointList);
            SuccessCheckPointString=SuccessCheckPointString.replaceAll('<','&lt;');
            SuccessCheckPointString=SuccessCheckPointString.replaceAll('>','&gt;');

            String  FailedCheckPointString= System.JSON.serialize(FailedCheckPointList);
            FailedCheckPointString=FailedCheckPointString.replaceAll('<','&lt;');

            FailedCheckPointString=FailedCheckPointString.replaceAll('>','&gt;');


            AttachmentList= [select Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c
            where ASI_CRM_Payment_Request__c = :PaymentRequest.Id and ASI_CRM_Type__c like 'CheckPoint%'];
            if(AttachmentList.size()>0){//exist
                for(ASI_Attachment__c attachment:AttachmentList){
                    if(attachment.ASI_CRM_Type__c=='CheckPoint-Success'){
                        attachment.ASI_CRM_Historical_Financial_Data__c=SuccessCheckPointString;//System.JSON.serialize(SuccessCheckPointList) ;
                    }
                    if(attachment.ASI_CRM_Type__c=='CheckPoint-Failed'){
                        attachment.ASI_CRM_Historical_Financial_Data__c=FailedCheckPointString;//System.JSON.serialize(FailedCheckPointList) ;
                    }
                }
            }else if(AttachmentList.size() ==0 ){
                AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Payment_Request__c=PaymentRequest.Id,ASI_CRM_Type__c='CheckPoint-Success',ASI_CRM_For_Contract_Use__c=true,
                    ASI_CRM_Historical_Financial_Data__c=System.JSON.serialize(SuccessCheckPointList)));
                AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Payment_Request__c=PaymentRequest.Id,ASI_CRM_Type__c='CheckPoint-Failed',ASI_CRM_For_Contract_Use__c=true,
                    ASI_CRM_Historical_Financial_Data__c=System.JSON.serialize(FailedCheckPointList)));
            }
            upsert AttachmentList;
        }catch(Exception e){
            String msgstr = 'Upsert ASI_CRM_CN_HeavyCheckPointResultPage Attachment  Error : ' +e.getMessage();
            ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '+ msgstr+' with Payment Request Id '+PaymentRequest.Id + ' with Json string : '+ System.JSON.serialize(FailedCheckPointList) , 'ASI_CRM_CN_HeavyPaymentCheckCtrl','ASI_CRM_CN_HeavyPaymentCheckCtrl.proceed');
        }

    }


    public void ValidationChecking(){
        //****************Business License Checking ****************
        Decimal TotalAmountChecking=1000000;
        Decimal FixedAmountChecking=50000;

        ASI_CRM_CN_CustomSetting__c checking =[select Id,ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c,ASI_CRM_Total_Amount_Checking__c from ASI_CRM_CN_CustomSetting__c ][0];

        if(checking.ASI_CRM_Total_Amount_Checking__c!=null){
            TotalAmountChecking =checking.ASI_CRM_Total_Amount_Checking__c;
        }

        if(checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c!=null){
            FixedAmountChecking =checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c;
        }

        Date businessLicenseStartDate = PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c;
        Date businessLicenseExpireDate = PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c;
        // 2020-10-23 TOT付款校验合同状态，只有final状态才能提交，add by zhonghui
        if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c != 'Final') {
            ErrorHandling(Label.ASI_CRM_CN_PaymentSubmitCheckFinalPO);
        }
        //20191119:AM@introv - fix wrong total - start
        //if ((PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_RContract_Fixed_Cost_Total__c + PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_Contract_Total_Dummy__c) > TotalAmountChecking ||
        //	  (otherCostPaymentTotal > 0 && DisplayPaymentTotal + otherCostPaymentTotal > FixedAmountChecking)) {
        if (DisplayPaymentTotal == NULL)
            DisplayPaymentTotal = 0;
        if (otherCostPaymentTotal == NULL)
            otherCostPaymentTotal = 0;
        decimal dFixedCost = 0;
        decimal dTotalAmt = 0;
        if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_RContract_Fixed_Cost_Total__c != NULL)
            dFixedCost = PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_RContract_Fixed_Cost_Total__c;
		if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c != NULL)
            dTotalAmt = PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c;
        if ((dFixedCost + dTotalAmt > TotalAmountChecking) || (DisplayPaymentTotal + otherCostPaymentTotal > FixedAmountChecking)) {
        //20191119:AM@introv - fix wrong total - end
            if (!PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c) {
                ProcessPermission = false;
                Msg += Label.ASI_CRM_CN_Business_License_not_uploaded + '.<br/>';//'Please note that Business License have not uploaded.<br/>';
            } else {
                if (businessLicenseStartDate != null && PaymentRequest.ASI_CRM_CN_PO_Start_Date__c < businessLicenseStartDate) {
                    ProcessPermission = false;
                    Msg += Label.ASI_CRM_CN_Business_License_after_PO_start_Date_Error + '.<br/>';//'Please note that the Start Date of Business License is after the PO start Date.<br/>';
                }
                if (!PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c) {
                    if (businessLicenseExpireDate != null && PaymentRequest.ASI_CRM_CN_PO_End_Date__c > businessLicenseExpireDate) {
                        ProcessPermission = false;
                        Msg += Label.ASI_CRM_CN_Business_License_before_PO_end_Date_Error + '.<br/>';//'Please note that the End Date of Business License is before the PO end Date.<br/>';
                    }
                }
            }
        }



    }


    public void ErrorHandling(String ErrorMsg){
        Msg += ErrorMsg + '<br/> ';

        ProcessPermission = false;
    }


    public void checkUserID(){
        List<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0)
            AdorAbove = true;
    }
}