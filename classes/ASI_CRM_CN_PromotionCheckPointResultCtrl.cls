/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_PromotionCheckPointResultCtrl
 * Description: Apex class for ASI_CRM_CN_PromotionCheckPointResultPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-1-11        Keith Yip               Created
 ****************************************************************************************************************************/
public class ASI_CRM_CN_PromotionCheckPointResultCtrl {
    public String objectName {get;set;} {objectName='';}
    public Boolean isContract {get;set;}
    public Boolean isPaymentRequest {get;set;}
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public ASI_TH_CRM_PaymentRequest__c paymentRequest {set;get;}

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
    public Decimal VisibilityTotal {get;set;}{VisibilityTotal =0;}
    public Boolean NeedPRVApproval {get;set;}{NeedPRVApproval=false;}
    public ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator HistoricalV00Contract  {set;get;} { HistoricalV00Contract = new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator ();}
    public ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator HistoricalVFinalContract  {set;get;} { HistoricalVFinalContract = new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator ();}
    public ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator NewContractV0Estimate  {set;get;} { NewContractV0Estimate = new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator ();}
    public ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator ();}
    public ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator NewContactVFinal  {set;get;} { NewContactVFinal = new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator ();}


    public Boolean ShowSubmitApproval {set;get;} {ShowSubmitApproval=false;}

    //For Payment CheckPoint
    public Map<String,Decimal> PaymentKPIMap   {get;set;} {PaymentKPIMap=new Map<String,Decimal>(); }
    public decimal PaymentSpeed {set;get;}{PaymentSpeed=0.0;}
    public decimal ValueSpeed {set;get;}{ValueSpeed=0.0;}
    public decimal PaySpeed {set;get;}{PaySpeed=0.0;}

    public Id PageId {set;get;}


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



    public ASI_CRM_CN_PromotionCheckPointResultCtrl() {
        PageId = ApexPages.currentPage().getParameters().get('id');
        objectName = PageId.getSobjectType().getDescribe().getName();
        isContract = objectName == 'ASI_TH_CRM_Contract__c';
        isPaymentRequest = objectName == 'ASI_TH_CRM_PaymentRequest__c';
        if (isContract) {
            this.ContractSelected = getContract(PageId);
        }
        if (isPaymentRequest) {
            this.paymentRequest = getPaymentRequest(PageId);
            this.ContractSelected = getContract(paymentRequest.ASI_TH_CRM_Contract__c);

        }
        init();
    }

    public void init(){

        Boolean ExistHistoricalData=false;

        checkUserID();
        orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;

        showCN = UserInfo.getLanguage()=='zh_CN';

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String TypeName = params.get('Type');
        if(TypeName =='SubmitApproval'){
            ShowSubmitApproval =true;
        }

//        //Calculate Fix cost amount and Total Amount
//        for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c,   ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c  FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id]){
//            if (ccost.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
//                FixedCostTotal += ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
//            }
//        }
//
        if (ContractSelected.ASI_CRM_CN_PO_Version__c != '0.0') {
            PSFTotal = ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c != null? ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c : 0;
            DisplayTotal = ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c != null? ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c : 0;
            VisibilityTotal = ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c != null? ContractSelected.ASI_CRM_CN_Expected_Visibility_Est_Total__c : 0;
        } else {
            PSFTotal = ContractSelected.ASI_CRM_Expected_V0_PSF_Estimated_Total__c != null? ContractSelected.ASI_CRM_Expected_V0_PSF_Estimated_Total__c : 0;
            DisplayTotal = ContractSelected.ASI_CRM_CN_Expected_V0_Display_Est_Total__c != null? ContractSelected.ASI_CRM_CN_Expected_V0_Display_Est_Total__c : 0;
            VisibilityTotal = ContractSelected.ASI_CRM_CN_V0_Visibility_Contract_Total__c != null? ContractSelected.ASI_CRM_CN_V0_Visibility_Contract_Total__c : 0;
        }


        //Getting HistoricalV0.0 and VFinal Data
        if (isContract) {
            List<ASI_Attachment__c> AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c
            WHERE ASI_CRM_Contract__c = :ContractSelected.Id ];
            for(ASI_Attachment__c att:AttachmentList){
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                if(att.ASI_CRM_Type__c=='Historical Data'){
                    List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                    if(HistoricalContractList.size()>0){
                        HistoricalV00Contract= HistoricalContractList[0];
                        HistoricalVFinalContract= HistoricalContractList[1];
                    }
                }else if(att.ASI_CRM_Type__c=='Contract Data' && ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0' ){
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        NewContractV0Estimate= ContractList[0];
                        NewContactV0Contract= ContractList[1];
                    }
                }else if(att.ASI_CRM_Type__c=='Historical Modi Data' && ContractSelected.ASI_CRM_CN_PO_Version__c !='0.0' ){
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        NewContractV0Estimate= ContractList[0];
                        NewContactV0Contract= ContractList[0];
                    }
                }else if(att.ASI_CRM_Type__c=='PO Modification Data'){
                    JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        NewContactVFinal= ContractList[0];
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
                        List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                        if(HistoricalContractList.size()>0){
                            HistoricalV00Contract= HistoricalContractList[0];
                            HistoricalVFinalContract= HistoricalContractList[1];
                        }
                    }else if(att.ASI_CRM_Type__c=='Contract Data'  ){
                        JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                        if(ContractList.size()>0){
                            NewContractV0Estimate= ContractList[0];
                            NewContactV0Contract= ContractList[1];
                        }
                    }

                }
            }

        }


        if (isPaymentRequest) {
            PaymentKPIMap=new Map<String,Decimal>();

            //NeedRVPApproval=false;
            //CutOffDay=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
            //VolumeSpeed=0;

            ASI_CRM_CN_CustomSetting__c CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
            //PRCGuidance=CustomSetting.ASI_CRM_PRC_Guidance__c;

            //Getting Contract
            ContractSelected = [SELECT Id,Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_CN_Expected_Display_Est_Total__c,ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                    ASI_CRM_Copied_From__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,
                    ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Visibility_Est_Total__c,ASI_CRM_Copied_From__r.ASI_CRM_EVC_Cost_Estimate_Total__c,
                    ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__c,
                    Owner.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, ASI_CRM_PO_Channel__c,
                    ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PO_Modification__c,
                    (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
                    ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c
            From ASI_TH_CRM_PaymentRequests_Contract__r)
            FROM ASI_TH_CRM_Contract__c WHERE id =:PaymentRequest.ASI_TH_CRM_Contract__c ];

            //FICalculation();
            Id v0ContractId = ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != null ? ContractSelected.ASI_CRM_CN_V0_0_PO_version__c : ContractSelected.Id;
            List<ASI_Attachment__c> AttachmentList= new List<ASI_Attachment__c>();
//            if(ContractSelected.ASI_CRM_CN_V0_0_PO_version__c!=null){
//                AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c
//                where ASI_CRM_Contract__c = :ContractSelected.Id or ASI_CRM_Contract__c = :v0ContractId];
//            }else{
//                //Geting HistoricalV0.0 and VFinal Data
//                AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c
//                where ASI_CRM_Contract__c = :ContractSelected.Id ];
//
//            }

            AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c
            where ASI_CRM_Contract__c = :ContractSelected.Id ];



            if(AttachmentList.size()>0){
                for(ASI_Attachment__c att:AttachmentList){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');

                    //General Payment Info
                    if(att.ASI_CRM_Type__c=='Payment Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){

                        PaymentKPIMap= (Map<String,Decimal>)System.JSON.deserialize(JsonString,Map<String,Decimal>.class);
                        if( PaymentKPIMap.containsKey('FixedCostTotal')  ){
                            FixedCostTotal= PaymentKPIMap.get('FixedCostTotal');
                        }
                        if( PaymentKPIMap.containsKey('PaymentExclOthersSpeed')  ){
                            PaymentSpeed= PaymentKPIMap.get('PaymentExclOthersSpeed');
                        }
                        if( PaymentKPIMap.containsKey('ValueSpeed')  ){
                            ValueSpeed= PaymentKPIMap.get('ValueSpeed');
                        }
                        if( PaymentKPIMap.containsKey('PaymentSpeed')  ){
                            PaySpeed= PaymentKPIMap.get('PaymentSpeed');
                        }
                    //}else if(att.ASI_CRM_Type__c=='PO Modification Data'){
                    }else if(att.ASI_CRM_Type__c=='PO Actual Data'){
                        JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                        if(ContractList.size()>0){
                            NewContactVFinal= ContractList[0];
                        }
                    }else if(att.ASI_CRM_Type__c=='Contract Data'){
                        JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                        if(ContractList.size()>0){
                            NewContractV0Estimate= ContractList[0];
                            NewContactV0Contract= ContractList[1];
                        }
                    }
                }
            }

        }


        System.debug('Now HistoricalV00Contract ContractId : '+HistoricalV00Contract.ContractId);
        if(HistoricalV00Contract.ContractId!='' ){
            ExistHistoricalData=true;
        }

        String segmentationRecordType;
        if (isContract) {
            segmentationRecordType = ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0' ? 'ASI_CRM_CN_PO_Open_Checkpoint_Criteria_Promotion' : 'ASI_CRM_CN_PO_Modi_Checkpoint_Criteria_Promotion';
        }
        if (isPaymentRequest) {
            segmentationRecordType = paymentRequest.ASI_CRM_CN_Last_Payment__c ? 'ASI_CRM_CN_Last_Payment_Checkpoint_Criteria_Promotion' : 'ASI_CRM_CN_Payment_Checkpoint_Criteria_Promotion';
        }

        List<ASI_CRM_SegmentationCriteria__c> segmentationCriteria = [
            SELECT
                AS_CRM_Predefined_Theoretical_Value__c,
                ASI_CRM_1st_Dimension__c,
                ASI_CRM_2nd_Dimension__c,
                ASI_CRM_Alignment_Percentage__c,
                ASI_CRM_Alignment_Value__c,
                ASI_CRM_Channel__c,
                ASI_CRM_Chinese_Interpretation__c,
                ASI_CRM_CN_Channel_Group__c,
                ASI_CRM_Division__c,
                ASI_CRM_English_Interpretation__c,
                ASI_CRM_Financial_Indicator__c,
                ASI_CRM_Floating_Interval_Down__c,
                ASI_CRM_Floating_Interval_Percent_Down__c,
                ASI_CRM_Floating_Interval_Percent_Up__c,
                ASI_CRM_Floating_Interval_Up__c,
                ASI_CRM_Max_Value__c,
                ASI_CRM_Min_Value__c,
                ASI_CRM_Operation__c,
                ASI_CRM_Region__c,
                ASI_CRM_Region__r.Name,
                ASI_CRM_RVP_Special_Approval__c,
                Id
            FROM ASI_CRM_SegmentationCriteria__c
            WHERE RecordType.DeveloperName = :segmentationRecordType
            AND ASI_CRM_Region__r.Name = :ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c
            AND ASI_CRM_Channel__c = :ContractSelected.ASI_CRM_PO_Channel__c
            AND ASI_CRM_CN_PO_Type__c = :ContractSelected.ASI_TH_CRM_Promotion_Type__c
        ];

        // looping Segmentation Criteria
        for(ASI_CRM_SegmentationCriteria__c sc: segmentationCriteria){
            System.debug(sc.ASI_CRM_Financial_Indicator__c);
            interimData temp = new interimData (sc);
            temp= setDimensionResult(temp, '1');
            temp= setDimensionResult(temp, '2');
            temp=DataOperationChecking(temp);
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


            if(temp.Display1stResultEN.contains('No Data')){
                AllowPut=false;
            }
            System.debug(temp.Display1stResultEN);
            System.debug(AllowPut);
            if(AllowPut){
                if(temp.ReachTarget =='Yes'){//Success
                    SuccessCheckPointList.add(temp);
                }else{//Failed
                    if(temp.SegmentationCriteria.ASI_CRM_RVP_Special_Approval__c){
                        NeedPRVApproval=true;
                    }
                    FailedCheckPointList.add(temp);
                }

            }

        }
        //check if we need to display this part
        if(FailedCheckPointList.isEmpty()){
            DisplayFailedCheckPointPart=false;
        }
        if(SuccessCheckPointList.isEmpty()){
            DisplaySuccessCheckPointPart=false;
        }

    }


    public Decimal generateD2NumberForPTV(interimData InputInterimData) {
        Decimal result;
        if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c == 'Predefined Theoretical Value' && InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c != null){
            if(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c == 'Approved Promotion Plan'){
                if(ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Wholesaler Promotion') {
                    if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Approved_Promotion_Plan__c != null) {
                        result = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Approved_Promotion_Plan__c;
                    } else {
                        result = 0;
                    }
                }else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Outlet Promotion'){
                    if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Approved_Promotion_GS_OP__c != null) {
                        result = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Approved_Promotion_GS_OP__c;
                    } else {
                        result = 0;
                    }
                }else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Consumer Promotion'){
                    if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Approved_Promotion_GS_CP__c != null) {
                        result = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Approved_Promotion_GS_CP__c;
                    } else {
                        result = 0;
                    }
                }
            }
        }
        return result;
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
            System.debug(InputInterimData.Period1stResult);
            if(ASI_CRM_CN_HeavyContractUtilitiesClass.DateOperationChecking(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c,InputInterimData.Period1stResult,Period2Date)){//if(InputInterimData.Period1stResult<Period2Date){
                InputInterimData.ReachTarget ='No';
            }
            InputInterimData.Display1stResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c +' = '+ InputInterimData.Period1stResult.format();
            InputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c) +' = '+ InputInterimData.Period1stResult.format();

        } else {
            //Number
            Decimal Dimension2Value1 = generateDimension2Number(InputInterimData, 1);
            Decimal Dimension2Value2 = generateDimension2Number(InputInterimData, 2);

            //Set Dimension 2 Value for Predefined Theoretical Value
            if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c == 'Predefined Theoretical Value'){
                Dimension2Value1 = generateD2NumberForPTV(InputInterimData);
            }


            InputInterimData.Dimension1stResult = InputInterimData.Dimension1stResult.setScale(2);
            if (!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c, InputInterimData.Dimension1stResult, Dimension2Value1, Dimension2Value2)) {
                InputInterimData.ReachTarget = 'No';
            }

            //Set displaying result

            ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria,'1');
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: GS% by Subbrand') {
                for (Decimal percentage : FIMasterData.SubBrandGSPercentageMap.values()) {
                    if (percentage >= InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c) {
                        InputInterimData.ReachTarget = 'No';
                        break;
                    }
                    InputInterimData.ReachTarget = 'Yes';
                }

                for (String subBrandId : FIMasterData.SubBrandGSPercentageMap.keySet()) {
                    ASI_CRM_CN_PromotionContractUtilClass.ContractLine contractLine = FIMasterData.ContractLineMap.get(subBrandId);
                    InputInterimData.Display1stResult += contractLine.SubBrandName + ': ' + FIMasterData.SubBrandGSPercentageMap.get(subBrandId).setScale(2) + '%<br/>';
                    InputInterimData.Display1stResultEN += contractLine.SubBrandName + ': ' + FIMasterData.SubBrandGSPercentageMap.get(subBrandId).setScale(2) + '%<br/>';
                }
            } else {
                 InputInterimData.Display1stResultEN = InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c + ' = ' + InputInterimData.Dimension1stResult.format();
                 InputInterimData.Display1stResult = ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c) + ' = ' + InputInterimData.Dimension1stResult.format();

            }
            System.debug(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c);
            System.debug(InputInterimData.Display1stResultEN);

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
                if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c == 'Predefined Theoretical Value'){
                    result = Dimension2Value1;
                }
                InputInterimData.Display2ndResultEN += ' = ' + result.format();
                InputInterimData.Display2ndResult += ' = ' + result.format();
            } else {// within display
                InputInterimData.Display2ndResultEN += ' :<br/>  Min = ' + Dimension2Value1.format() + '<br/> Max = ' + Dimension2Value2.format();
                InputInterimData.Display2ndResult += ' :<br/> 最小值 =  ' + Dimension2Value1.format() + '<br/> 最大值 = ' + Dimension2Value2.format();
            }

        }


        return InputInterimData;
    }



    public interimData setDimensionResult(interimData InputInterimData, String firstOrSecond){
        String dimension = firstOrSecond == '1'? InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c : InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
        Decimal dimensionResult = 0;
        Date PeriodResult;
        ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria, firstOrSecond);
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
            //InputInterimData.Period1stResult = FIMasterData.POStartDate;
            PeriodResult = FIMasterData.POStartDate;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: GS Total') {
            dimensionResult = FIMasterData.GrossSalesTotal;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='GS: Total GS%') {
            dimensionResult = FIMasterData.GrossSalesRate;
        } else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')) {
            dimensionResult = FIMasterData.Volumes;
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Payment Speed: Trade Expense (Excl. Fixed Cost)'){ //For Payment CheckPoint
            if(dimension =='Payment Speed%'){
                dimensionResult = PaymentSpeed.SetSCale(0);
            }else if(dimension =='Purchase Value Speed%'){
                dimensionResult = ValueSpeed.SetSCale(0);
            }
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Payment Speed: Trade Expense'){ //For Payment(promotion) CheckPoint
            if(dimension =='Payment Speed%'){
                dimensionResult = PaySpeed.SetSCale(0);
            }else if(dimension =='Purchase Value Speed%'){
                dimensionResult = ValueSpeed.SetSCale(0);
            }
        }


        dimensionResult = dimensionResult == null ? 0 :  dimensionResult.setScale(2);

        if (firstOrSecond == '1') {
            InputInterimData.Dimension1stResult = dimensionResult;
            InputInterimData.Period1stResult = PeriodResult;
        } else {
            InputInterimData.Dimension2ndResult = dimensionResult;
        }

        if(firstOrSecond =='2'){
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
        }

        return InputInterimData;

    }



    public ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator FinancialIndicatorMasterData(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria, String Dimension) {
        String dimensionStr = Dimension == '1'? InputSegmentationCriteria.ASI_CRM_1st_Dimension__c : InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c;

        if (dimensionStr == 'Historical V0.0') {
            return  HistoricalV00Contract;
        } else if (dimensionStr == 'Historical Vfinal') {
            return  HistoricalVFinalContract;
        } else if (dimensionStr == 'New Contact V0.0 Contract') {
            return  NewContactV0Contract;
        } else if (dimensionStr == 'New Contract V0.0 Est.') {
            return  NewContractV0Estimate;
        } else if (dimensionStr == 'New Contract V Final') {
            return  NewContactVFinal;
        } else {
            return new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator();
        }

    }

    public PageReference CancelProcess(){
        ProcessPermission = true;
        PageReference pageRef = new PageReference('/'+PageId);
        pageRef.setRedirect(true);
        return pageRef;
    }


    //Validation
    public void ValidationChecking(){
        //************Business License Checking ***********
//        Decimal TotalAmountChecking=1000000;
//        Decimal FixedAmountChecking=50000;
//        ASI_CRM_CN_CustomSetting__c checking =[SELECT Id,ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c,ASI_CRM_Total_Amount_Checking__c FROM ASI_CRM_CN_CustomSetting__c ][0];
//
//        if(checking.ASI_CRM_Total_Amount_Checking__c!=null){
//            TotalAmountChecking =checking.ASI_CRM_Total_Amount_Checking__c;
//        }
//
//        if(checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c!=null){
//            FixedAmountChecking =checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c;
//        }

        //If a PO meets the criteria (Total PO contract amount >= 1M RMB OR Fixed cost total >= 50K RMB),System will show a warning message (but allow to save)
        //if no business license is uploaded or the uploaded business license is invalid (i.e. the start date & end date of the uploaded business license do not cover the PO period).
        Boolean ShowWarning= false;
        // if total > 2M RMB Vol Budget/LE (9L) & A&P Budget/LE (RMB) is mandatory. if Vol Budget/LE or A&P Budget/LE is blank Reason without Budget/LE is mandatory.
        if ((PSFTotal+DisplayTotal+VisibilityTotal) > 2000000) {
            if ((ContractSelected.ASI_CRM_CN_Vol_Budget_LE__c == null || ContractSelected.ASI_CRM_CN_Budget_LE__c == null) && String.isEmpty(ContractSelected.ASI_CRM_CN_Reason_without_Budget__c)) {
                ProcessPermission = false;
                Msg += Label.ASI_CRM_CN_Budget_LE_Validation + '<br/>';
            }
        }
//        if ((PSFTotal + DisplayTotal + FixedCostTotal) > TotalAmountChecking || (DisplayTotal + FixedCostTotal) > FixedAmountChecking) {
//            if (!ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c) {
//                ShowWarning = true;
//                WarningMsg += Label.ASI_CRM_CN_Business_License_not_uploaded + '<br/>';//Please note that Business License have not uploaded.
//            } else {
//                if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c != null) {
//                    if (ContractSelected.ASI_CRM_CN_PO_Start_Date__c < ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c) {
//                        ShowWarning = true;
//                        WarningMsg += Label.ASI_CRM_CN_Business_License_after_PO_start_Date_Error + '<br/>';//Please note that the Start Date of Business License is after the PO start Date.
//                    }
//                }
//                if (!ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c) {
//                    if (ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c != null) {
//                        if (ContractSelected.ASI_CRM_CN_PO_End_Date__c > ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c) {
//                            ShowWarning = true;
//                            WarningMsg += Label.ASI_CRM_CN_Business_License_before_PO_end_Date_Error + '<br/>';//Please note that the End Date of Business License is before the PO end Date.
//                        }
//                    }
//                }
//            }
//        }// ending of checking

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
        //List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        //PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable(ContractSelected);
        List<ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary> ();
        PaymentSummaryList = ASI_CRM_CN_PromotionContractUtilClass.PaymentSummaryTable(ContractSelected);
        Boolean validByACCode = true;
        //for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary SummaryData:PaymentSummaryList){//POEstimatedAmount
        for(ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary SummaryData:PaymentSummaryList){//POEstimatedAmount
            System.debug('SummaryData : '+SummaryData);
            // Decimal PORemainAmt=SummaryData.POEstimatedAmount-SummaryData.PaidAmount; // change  LastVersion_POEstimatedAmount to  POEstimatedAmount
            if(Math.abs(SummaryData.PaymentRequestAmount)>Math.abs(SummaryData.POEstimatedAmount)+1){
                validByACCode = false;
                //Msg+=SummaryData.PaymentRequestAmount+ '  Test  '+SummaryData.POEstimatedAmount ;
            }
        }

        if(!validByACCode){
            ProcessPermission = false;
            Msg+=Label.ASI_CRM_CN_ContractAmountByACCheckErrMsg;
        }
    }

    public void upsertCheckpointAttachments() {
        //try {
            String SuccessCheckPointString = System.JSON.serialize(SuccessCheckPointList);
            SuccessCheckPointString = SuccessCheckPointString.replaceAll('<', '&lt;');
            SuccessCheckPointString = SuccessCheckPointString.replaceAll('>', '&gt;');

            String FailedCheckPointString = System.JSON.serialize(FailedCheckPointList);
            FailedCheckPointString = FailedCheckPointString.replaceAll('<', '&lt;');
            FailedCheckPointString = FailedCheckPointString.replaceAll('>', '&gt;');
            List<ASI_Attachment__c> AttachmentList = new List<ASI_Attachment__c>();
//            List<ASI_Attachment__c> AttachmentList = [
//                SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
//                FROM ASI_Attachment__c
//                WHERE ASI_CRM_Contract__c = :ContractSelected.Id AND ASI_CRM_Payment_Request__c = :paymentRequest.Id AND ASI_CRM_Type__c LIKE 'CheckPoint%'
//            ];
            if (isContract) {
                AttachmentList = [
                        SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
                        FROM ASI_Attachment__c
                        WHERE ASI_CRM_Contract__c = :ContractSelected.Id AND ASI_CRM_Type__c LIKE 'CheckPoint%'
                ];
            }
            if (isPaymentRequest) {
                AttachmentList = [
                    SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
                    FROM ASI_Attachment__c
                    WHERE ASI_CRM_Contract__c = :ContractSelected.Id AND ASI_CRM_Payment_Request__c = :paymentRequest.Id AND ASI_CRM_Type__c LIKE 'CheckPoint%'
                ];

            }

            if (AttachmentList.size() > 0) {//exist
                for (ASI_Attachment__c attachment : AttachmentList) {
                    if (attachment.ASI_CRM_Type__c == 'CheckPoint-Success') {
                        attachment.ASI_CRM_Historical_Financial_Data__c = SuccessCheckPointString ;
                    }
                    if (attachment.ASI_CRM_Type__c == 'CheckPoint-Failed') {
                        attachment.ASI_CRM_Historical_Financial_Data__c = FailedCheckPointString;
                    }
                }
            } else { // size ==0;
                AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Contract__c = ContractSelected.Id, ASI_CRM_Type__c = 'CheckPoint-Success', ASI_CRM_For_Contract_Use__c = true,
                    ASI_CRM_Historical_Financial_Data__c = SuccessCheckPointString));
                AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Contract__c = ContractSelected.Id, ASI_CRM_Type__c = 'CheckPoint-Failed', ASI_CRM_For_Contract_Use__c = true,
                    ASI_CRM_Historical_Financial_Data__c = FailedCheckPointString));
            }
            upsert AttachmentList;
//        } catch (Exception e) {
//            ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment ' + 'Upsert ASI_CRM_CN_HeavyCheckPointResultPage Attachment  Error : ' + e.getMessage() + ' with contract Id ' + ContractSelected.Id + ' with Json string : ' + System.JSON.serialize(FailedCheckPointList), 'ASI_CRM_CN_PromotionCheckPointResultCtrl', 'ASI_CRM_CN_PromotionCheckPointResultCtrl.upsertCheckpointAttachments');
//        }
    }




    public PageReference proceed() {
        ProcessPermission = true;
        Msg='';
        WarningMsg='';

        if(isContract) {
            ValidationChecking();
            if (!ContractSelected.ASI_CRM_CN_PO_Modification__c) {
                //ValidationChecking();
            } else {
                POModiValidationChecking();
            }
        }

        if(ProcessPermission && WarningTimes!=1 ){
            try{
//                if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c != null){
//                    if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c <getFiscalYearStart(System.today()).addYears(1)){
//                        ContractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
//                    }
//                    else{
//                        ContractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(ContractSelected.ASI_CRM_CN_PO_Start_Date__c);
//                    }
//                }else{
//                    ContractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
//                }
                if (isContract) {
                    ContractSelected.ASI_CRM_RVP_Approval__c = NeedPRVApproval;
                    update ContractSelected;
                }

                if (isPaymentRequest) {
                    paymentRequest.ASI_CRM_RVP_Approval__c = NeedPRVApproval;
                    // 增加跳过一些更新付款明细逻辑
                    ASI_CRM_CN_PaymentRequest_TriggerCls.refreshSkip = true;
                    update paymentRequest;
                }


                upsertCheckpointAttachments();

            }catch(Exception e){
                String msgstr = 'Upsert ASI_CRM_CN_HeavyCheckPointResultPage Attachment  Error : ' +e.getMessage();
                ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '+ msgstr+' with contract Id '+ContractSelected.Id + ' with Json string : '+ System.JSON.serialize(FailedCheckPointList) , 'ASI_CRM_CN_HeavyCheckPointResultCtrl','ASI_CRM_CN_HeavyCheckPointResultCtrl.proceed');
            }

            //submit for approval
            if(!Test.isRunningTest()){
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(PageId);
                Approval.ProcessResult result = Approval.process(req1);

            }


            return new PageReference('/' + PageId);

        }else{
            return null;
        }


    }

    public ASI_TH_CRM_Contract__c getContract(Id contractId){
        return [
            SELECT
                ASI_CRM_CN_Budget_LE__c,
                ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                ASI_CRM_CN_Expected_Display_Est_Total__c,
                ASI_CRM_CN_Expected_PSF_Est_Total__c,
                ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                ASI_CRM_CN_Group_Contract__c,
                ASI_CRM_CN_Last_PO_version__c,
                ASI_CRM_CN_Outlet_WS__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Approved_Promotion_Plan__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Approved_Promotion_GS_OP__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Approved_Promotion_GS_CP__c,
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
                ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                ASI_CRM_Copied_From__r.ASI_CRM_EVC_Cost_Estimate_Total__c,
                ASI_CRM_RVP_Approval__c,
                ASI_CRM_V0_PSF_Contract_Total__c,
                ASI_CRM_CN_V0_Display_Contract_Total__c,
                ASI_CRM_CN_V0_Visibility_Contract_Total__c,
                ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
                ASI_CRM_CN_Expected_V0_Display_Est_Total__c,
                ASI_TH_CRM_Promotion_Type__c,
                ASI_CRM_CN_PO_Channel_Group__c,
                ASI_CRM_PO_Channel__c,
                Id,
                Name,
                Owner.Name
            FROM ASI_TH_CRM_Contract__c
            WHERE Id = :contractId
        ];
    }

    public ASI_TH_CRM_PaymentRequest__c getPaymentRequest(Id paymentRequestId){
        return [
            SELECT
                ASI_CRM_CN_Channel__c,
                ASI_CRM_CN_Description__c,
                ASI_CRM_CN_Division__c,
                ASI_CRM_CN_Last_Payment__c,
                ASI_CRM_CN_No_of_Month__c,
                ASI_CRM_CN_Other_Reason__c,
                ASI_CRM_CN_OutletWS__c,
                ASI_CRM_CN_OutletWS__r.ASI_CRM_Channel_Group__c,
                ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
                ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c,
                ASI_CRM_CN_Payable_Amount__c,
                ASI_CRM_CN_Payment_Raised_Date__c,
                ASI_CRM_CN_Payment_Type__c,
                ASI_CRM_CN_PO_End_Date__c,
                ASI_CRM_CN_PO_No__c,
                ASI_CRM_CN_PO_Start_Date__c,
                ASI_CRM_CN_PO_Version__c,
                ASI_CRM_CN_Promotion_Type__c,
                ASI_CRM_CN_Reason_For_Business_License__c,
                ASI_CRM_CN_Reference_Code__c,
                ASI_CRM_CN_Total_BRSF_Actual_Amount__c,
                ASI_CRM_CN_Total_BRSF_Amount__c,
                ASI_CRM_CN_Total_Other_Amount__c,
                ASI_CRM_CN_Total_Payment__c,
                ASI_CRM_CN_Total_PSF_Amount__c,
                ASI_CRM_New_FY_Payment__c,
                ASI_CRM_Total_Actual_Amount__c,
                ASI_CRM_Volume_Cut_Off_Date__c,
                ASI_CRM_Volume_Option__c,
                ASI_TH_CRM_Contract__c,
                ASI_TH_CRM_Status__c,
                ASI_TH_CRM_Total_Amount__c,
                Id,
                Name,
                Owner.Name
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE Id = :paymentRequestId
        ];
    }

//    public Date getFiscalYearStart(Date inputDate){
//        //Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
//        Date fiscalYearStart;
//        if(inputDate != null){
//            fiscalYearStart = Date.newInstance(inputDate.year(), orgFiscalMonth, 1);
//            if(inputDate.month() < orgFiscalMonth && inputDate.year() == inputDate.year())
//                fiscalYearStart = fiscalYearStart.addYears(-1);
//        }
//        System.debug(inputDate + '/' + fiscalYearStart);
//        return fiscalYearStart;
//    }
}