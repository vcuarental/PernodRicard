/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_PromoPaymentRequestFrmCmpCtrl
 * Description: Apex class for ASI_CRM_CN_PromoPaymentRequestFrmCmpCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-07-31       Keith Yip               Created
 ****************************************************************************************************************************/
public class ASI_CRM_CN_PromoPaymentRequestFrmCmpCtrl {
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public Id HeaderId {set;get;}
    public String strPDF {set;get;}
    public ASI_TH_CRM_PaymentRequest__c thisPR {set;get;}
    public ASI_TH_CRM_Contract__c  ContractSelected {set;get;}{ContractSelected = new ASI_TH_CRM_Contract__c(); }
    public Decimal ContractBCRate {set;get;}{ContractBCRate=0;}

    public Date CutOffDay {set;get;} //Pending Custom Setting follow for Sub Brand Volume
    //AD or Above Identity checking
    public Boolean AdorAbove {set;get;}
    public String UserId {set;get;}
    public List<ASI_CRM_CN_PH_Payee_Line_Item__c> PayeeList {set;get;}{PayeeList=new List<ASI_CRM_CN_PH_Payee_Line_Item__c>(); }
    public List<ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary> PaymentSummaryList {set;get;}{PaymentSummaryList = new List<ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary>();}
    public Decimal Other_VOL_CR12 {set;get;} {Other_VOL_CR12 =0;}
    public Decimal BRSF_CTD_CR12=0;// Total BRSF Volume all period
    public Decimal PaymentSpeed {set;get;}
    public Decimal PaymentSpeedexcFixCost {set;get;}
    public Date strStart;
    Public Decimal TotalPaymentAmount=0;
    //BA Comment
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}

    public Map<String, Decimal> categoriesMap {set;get;} {categoriesMap = new Map<String, Decimal>();}
    public Map<String, String> categoriesDisplayMap {set;get;} {categoriesDisplayMap = new Map<String, String>();}
    public Map<String, String> sbGroup_map {set;get;} {sbGroup_map = new Map<String, String>();}
    public Integer BRSFmonthsBetween   {set;get;} {BRSFmonthsBetween=1;}
    //BRSF
    public interimData BRSFItemMap {set;get;} {BRSFItemMap= new interimData();}
    //PSF
    public Map<String, interimData> PSFItemMap {set;get;} {PSFItemMap= new Map<String, interimData>();}
    public Map<String, interimData> DisplayItemMap {set;get;} {DisplayItemMap= new Map<String, interimData>();}

    public Map<String,VolumeObject> VolumeMap {set;get;} {VolumeMap= new Map<String,VolumeObject>(); }

    public Map<String, String> SubbrandGroup {set;get;}{SubbrandGroup = new Map<String, String>(); }
    public ASI_CRM_CN_PromoPaymentRequestFrmCmpCtrl(){}

    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContractV0Estimate  {set;get;} { NewContractV0Estimate = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ActualPerformance  {set;get;} { ActualPerformance = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}

    public ASI_CRM_CN_PromotionPaymentUtilClass.FinancialIndicator paymentData {get; set;} { paymentData = new ASI_CRM_CN_PromotionPaymentUtilClass.FinancialIndicator();}

    public Map<String, ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data> v0_ROI_newMap  {set;get;} {v0_ROI_newMap=new Map<String, ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data>();}
    public Map<String, ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data> v1_ROI_newMap  {set;get;} {v1_ROI_newMap= new Map<String, ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data>();}
    public Decimal TotalPaymentVariableAmount {set;get;} {TotalPaymentVariableAmount=0;}

    public Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal>();

    public Boolean DisplayBRSFPart {set;get;} {DisplayBRSFPart=false;}
    public Boolean DisplayPSFPart {set;get;} {DisplayPSFPart=false;}
    public Boolean DisplayDisplayPart {set;get;} {DisplayDisplayPart=false;}

    public Map<String, VolValueInterimData> SubBrandInterimDataMap{set;get;} {SubBrandInterimDataMap = new Map<String, VolValueInterimData> ();}
    public Map<String, String> interimDataSortMap{set;get;} {interimDataSortMap = new Map<String, String> ();}
    public Map<String, WholeSalerInterimData> WholeSalerInterimDataMap{set;get;} {WholeSalerInterimDataMap = new Map<String, WholeSalerInterimData> ();}
    public Decimal TotalWsPurchaseValue {set;get;} {TotalWsPurchaseValue=0;}
    public Decimal TotalWsIncentive {set;get;} {TotalWsIncentive=0;}
    public Decimal TotalWsIncentivePercent {set;get;} {TotalWsIncentivePercent=0;}
    public Decimal VolSpeed {set;get;} {VolSpeed=0;}
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> freeGoodsList {get;set;}
    public Boolean DisplayFreeGoods {set;get;} {DisplayFreeGoods = false;}

    public Map<Integer, String> WholeSalerInterimDataSortMap {set;get;} {WholeSalerInterimDataSortMap = new Map<Integer, String> ();}

    public ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator V0Contract  {set;get;} {
        V0Contract = new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator ();
    }
    public ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator CurrentContract  {set;get;} {
        CurrentContract = new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator ();
    }

    public ASI_CRM_CN_PromoPaymentRequestFrmCmpCtrl(ApexPages.StandardController controller) {

    }

    public Boolean init(){
        System.debug(HeaderId);
        if (HeaderId != null){
            thisPR = [SELECT Id, ASI_TH_CRM_Contract__c ,ASI_CRM_CN_Payment_Raised_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c,ASI_TH_CRM_Contract__r.ASI_CRM_Martell_BC_Rate__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Eng_Name__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Total_BRSF_Amount__c,
                    ASI_CRM_CN_Total_PSF_Amount__c, ASI_CRM_CN_Total_Other_Amount__c , ASI_CRM_CN_PO_Remain_Amount__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.Name,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,  ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.Name, toLabel(ASI_CRM_CN_Payment_Type__c), ASI_CRM_CN_Overpayment_Reason__c, ASI_CRM_CN_Other_Reason__c, ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_PO_End_Date__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PSF_End__c , ASI_CRM_CN_PSF_Start__c ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,
                    Owner.Name, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Cost_Total__c ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c, ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.Name, ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Currency__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_National_Group_Contract__c,
                    ASI_CRM_CN_BRSF_End_Date__c , ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_BRSF_Start_Date__c, ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_CRM_CN_PO_No__c, ASI_CRM_CN_Region__c, ASI_CRM_CN_OutletWS__r.Name, Name,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Group_Contract__r.Name,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Group_Contract__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,
                    ASI_CRM_CN_Total_Payment__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_CRM_New_FY_Payment__c, ASI_TH_CRM_Contract__r.ASI_CRM_PO_Province__r.Name, ASI_TH_CRM_Contract__r.ASI_CRM_PO_Channel__r.Name ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__c ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__r.Name,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c ,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_NewChannel__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                    ASI_TH_CRM_Contract__r.ASI_CRM_Investment_Type__c, ASI_CRM_CN_Total_Free_Goods_Amount__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_PO_Channel__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Description__c,
                    toLabel(ASI_TH_CRM_Contract__r.ASI_CRM_CN_Data_Source__c),
                    toLabel(ASI_TH_CRM_Contract__r.ASI_CRM_CN_Festival_Season__c)
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE Id = :HeaderId];


        }

        List<ASI_Attachment__c> AttachmentList= [select Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c ,ASI_CRM_Contract__r.ASI_CRM_CN_PO_Version__c
        from ASI_Attachment__c where ASI_CRM_Contract__c != null and (ASI_CRM_Contract__c = :thisPR.ASI_TH_CRM_Contract__c or ASI_CRM_Contract__c = :thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c) ORDER BY LastModifiedDate desc];
        //paymentData
        if(AttachmentList.size()>0){
            List<ASI_CRM_CN_PromotionPaymentUtilClass.FinancialIndicator> paymentDataList = new List<ASI_CRM_CN_PromotionPaymentUtilClass.FinancialIndicator>();
            String CRMTypeRead = '';
            for(ASI_Attachment__c att:AttachmentList){
                if(att.ASI_CRM_Type__c =='Payment Data' && CRMTypeRead.indexOf(att.ASI_CRM_Type__c) == -1) {
                    CRMTypeRead += '-'+att.ASI_CRM_Type__c;
                    
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;', '"');
                    paymentData = (ASI_CRM_CN_PromotionPaymentUtilClass.FinancialIndicator) System.JSON.deserialize(JsonString, ASI_CRM_CN_PromotionPaymentUtilClass.FinancialIndicator.class);
                }
                // 2020-01-14 Bowen V0Contract需要取v0.0版本的attachment
                else if (att.ASI_CRM_Type__c=='Contract Data' && CRMTypeRead.indexOf(att.ASI_CRM_Type__c) == -1 && att.ASI_CRM_Contract__r.ASI_CRM_CN_PO_Version__c == '0.0'){
                    CRMTypeRead += '-'+att.ASI_CRM_Type__c;

                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                    V0Contract= ContractList[0]; // Contract Data
                    system.debug('----V0Contract =='+V0Contract.Volumes + '===att.id'+att.Id);
                }else if(att.ASI_CRM_Type__c=='PO Actual Data' && CRMTypeRead.indexOf(att.ASI_CRM_Type__c) == -1) {
                    CRMTypeRead += '-'+att.ASI_CRM_Type__c;

                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                    CurrentContract = ContractList[0];
                }
            }
        }
        System.debug('paymentData: ' + paymentData);

        InitVariable();

        if (thisPR != null){
            ContractSelected = [SELECT Id,
                    Name,
                    CreatedDate,
                    LastModifiedDate,
                    RecordTypeId,
                    ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_CRM_CN_Budget_LE__c,
                    ASI_CRM_CN_Business_License__c,
                    ASI_CRM_CN_Contract_Upload__c,
                    ASI_CRM_CN_Currency__c,
                    ASI_CRM_CN_Description__c,
                    ASI_CRM_CN_Effective_Date__c,
                    ASI_CRM_CN_Exchange_Rate__c,
                    ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                    ASI_CRM_CN_Expected_PSF_Est_Total__c,
                    ASI_CRM_CN_Last_PO_version__c,
                    ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                    ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
                    ASI_CRM_CN_Last_Rejected_Date__c,
                    ASI_CRM_CN_Last_Submitted_Date__c,
                    ASI_CRM_CN_National_Group_Contract__c,
                    ASI_CRM_CN_No_of_Months__c,
                    ASI_CRM_CN_Outlet_WS__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                    ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                    ASI_CRM_CN_PO_End_Date__c,
                    ASI_CRM_CN_PO_Modification__c,
                    ASI_CRM_CN_PO_No__c,
                    ASI_CRM_CN_PO_Start_Date__c,
                    ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_CN_PP_No__c,
                    ASI_CRM_CN_Reason_without_Budget__c,
                    ASI_CRM_CN_Source_Others__c,
                    ASI_CRM_CN_Source_of_Contract__c,
                    ASI_CRM_CN_Special_Promotion__c,
                    ASI_CRM_CN_Status__c,
                    ASI_CRM_CN_Total_Contract_Amount__c,
                    ASI_CRM_CN_Vol_Budget_LE__c,
                    ASI_CRM_Investment_Type__c,
                    ASI_CRM_National_Group__c,
                    ASI_CRM_National_Group__r.Name,
                    ASI_CRM_New_FY_PO__c,
                    ASI_CRM_PO_Channel__c,
                    ASI_CRM_PO_City__c,
                    ASI_CRM_PO_City__r.Name,
                    ASI_CRM_PO_Province__c,
                    ASI_CRM_Volume_Option__c,
                    ASI_CRM_CN_Expected_Display_Est_Total__c,
                    ASI_TH_CRM_Promotion_Type__c,
                    ASI_CRM_Copied_From__c,
                    ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,
                    ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,
                    ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                    ASI_CRM_CN_Data_Source__c,
                    ASI_CRM_CN_V0_0_PO_version__c
            FROM ASI_TH_CRM_Contract__c
            WHERE Id =:thisPR.ASI_TH_CRM_Contract__c ];

            try{
                PayeeList = [SELECT Id, toLabel(ASI_CRM_CN_Type__c), ASI_CRM_CN_Amount__c, ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T2_lookup__c,ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Payee_Name_T1__r.Name,ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name,ASI_CRM_CN_Cash_Amount__c
                FROM ASI_CRM_CN_PH_Payee_Line_Item__c WHERE ASI_CRM_CN_Payment_Request__c = :thisPR.Id];
            }catch(Exception e){
                PayeeList = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            }

            //Calculate Actual Expenses which equals total payee amount
            CurrentContract.DisplayExpensesTotal = 0;
            CurrentContract.VisibilityExpensesTotal = 0;
            CurrentContract.PSFExpensesTotal = 0;
            integer thisPRSeq = Integer.valueOf(thisPR.Name.substring(thisPR.Name.length()-3, thisPR.Name.length()));
            for(ASI_CRM_Module__c m :[select ASI_CRM_Actual_Payment__c,
                                             ASI_CRM_Payment_Request__r.Name
                                      from ASI_CRM_Module__c
                                      WHERE ASI_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :thisPR.ASI_TH_CRM_Contract__c
                                      //AND ASI_CRM_Payment_Request__r.ASI_TH_CRM_Status__c!='Draft'
                                      //AND ASI_CRM_Payment_Request__r.ASI_TH_CRM_Status__c!='Submitted'
                                      and ASI_CRM_Parent_Module__c != null]){
                //if(m.ASI_CRM_Payment_Request__r.Name.substring(m.ASI_CRM_Payment_Request__r.Name.length()-3, m.ASI_CRM_Payment_Request__r.Name.length())!=null){
                    //Include Historical module payment in trade expense,  module payment Seq < current payment Seq, it should be Historical module
                    //if(Integer.valueOf(m.ASI_CRM_Payment_Request__r.Name.substring(m.ASI_CRM_Payment_Request__r.Name.length()-3, m.ASI_CRM_Payment_Request__r.Name.length()))<= thisPRSeq){
                        CurrentContract.PSFExpensesTotal += m.ASI_CRM_Actual_Payment__c != null ? m.ASI_CRM_Actual_Payment__c : 0;
                   //}
                //}
            }

            for(ASI_TH_CRM_PaymentRequest__c p :[select ASI_CRM_CN_Total_Free_Goods_Amount__c,ASI_CRM_CN_Promotion_Type__c,
                                                        Name
                                                        from ASI_TH_CRM_PaymentRequest__c
                                                        where  ASI_TH_CRM_Contract__c = :thisPR.ASI_TH_CRM_Contract__c
                                                       ]){
                //if(p.Name.substring(p.Name.length()-3, p.Name.length())!=null) {
                    //Include Historical module payment in trade expense,  module payment Seq < current payment Seq, it should be Historical module
                    //if (Integer.valueOf(p.Name.substring(p.Name.length() - 3, p.Name.length())) <= thisPRSeq) {
                    if (p.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion')
                        CurrentContract.PSFExpensesTotal += p.ASI_CRM_CN_Total_Free_Goods_Amount__c != null ? p.ASI_CRM_CN_Total_Free_Goods_Amount__c : 0;
                    //}
                //}
            }

            //MarginAfterAnP = CM Total - Total Payment Amount
            CurrentContract.MarginAfterAnP = CurrentContract.CMTotal - CurrentContract.TradeExpenses;

            //PaymentSummaryList = ASI_CRM_CN_PromotionContractUtilClass.PaymentSummaryTable(thisPR,ContractSelected);
            PaymentSummaryList = ASI_CRM_CN_PromotionContractUtilClass.PaymentSummaryTable(ContractSelected, thisPR);

            List<Integer> lstRemove = new List<Integer>();
            Integer indexNum=0;
            Integer c = 0;
            if (PaymentSummaryList != null && PaymentSummaryList.size() > 0){
                for(ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary displayLine:PaymentSummaryList){
                    if(displayLine.POEstimatedAmount==0 && displayLine.PaymentRequestAmount==0){
                        lstRemove.add(indexNum);
                    }
                    indexNum++;
                }

                for(Integer n : lstRemove){
                    if(n!=0){
                        if(c>0)
                            n=n-c;
                        PaymentSummaryList.remove(n);
                        c++;
                    }else{
                        PaymentSummaryList.remove(0);
                        c++;
                    }
                }
            }

            String PSFName='合同奖励';
            String DisplayName = '常规陈列费';
            for (ASI_CRM_CN_PromotionContractUtilClass.PaymentSummary paymentSummary : PaymentSummaryList){
                if (paymentSummary.Name == PSFName){
                    ActualPerformance.PSFExpensesTotal += paymentSummary.PaidAmount + paymentSummary.PaymentRequestAmount;
                } else if (paymentSummary.Name == DisplayName){
                    ActualPerformance.DisplayExpensesTotal += paymentSummary.PaidAmount + paymentSummary.PaymentRequestAmount;
                } else {
                    ActualPerformance.OtherExpensesTotal += paymentSummary.PaidAmount + paymentSummary.PaymentRequestAmount;
                }

            }
            /*
            //Get all Payment Request (Approved/Submitted/Paid)
            List<ASI_TH_CRM_PaymentRequest__c> allPaymentRequests = ASI_CRM_CN_PromotionPaymentUtilClass.getAllPaymentRequest(thisPR.ASI_TH_CRM_Contract__c, thisPR.id);
            system.debug('allPaymentRequests: ' + allPaymentRequests);
            //Calculate the Subtotal amount
            if (allPaymentRequests.size() > 0){
                for (ASI_TH_CRM_PaymentRequest__c allPR_temp : allPaymentRequests){
                    if(allPR_temp.ASI_CRM_CN_Promotion_Type__c=='TOT/MOT Contract'){
                        ActualPerformance.PSFExpensesTotal += ASI_CRM_CN_PromotionPaymentUtilClass.denullify(allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c, 0);
                        ActualPerformance.DisplayExpensesTotal += ASI_CRM_CN_PromotionPaymentUtilClass.denullify(allPR_temp.ASI_CRM_CN_Total_Display_Amount__c, 0);
                        ActualPerformance.OtherExpensesTotal += ASI_CRM_CN_PromotionPaymentUtilClass.denullify(allPR_temp.ASI_CRM_CN_Total_Other_Amount__c, 0);

                        //if(allPR_temp.Name.length()>3 && (allPR_temp.Name.substring(allPR_temp.Name.length()-3, allPR_temp.Name.length()) == '000')){///000-Payment
                        //    TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c:0;
                        //    TotalPaymentVariableAmount += allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c:0;
                        //    TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c:0;
                        //}else{
                        //    TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_Total_Variable_Amount__c!=NULL?allPR_temp.ASI_CRM_Total_Variable_Amount__c:0;
                        //}


                    }else{
                        ActualPerformance.PSFExpensesTotal += ASI_CRM_CN_PromotionPaymentUtilClass.denullify(allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c, 0);
                        ActualPerformance.DisplayExpensesTotal += ASI_CRM_CN_PromotionPaymentUtilClass.denullify(allPR_temp.ASI_CRM_CN_Total_Display_Amount__c, 0);
                        ActualPerformance.OtherExpensesTotal += ASI_CRM_CN_PromotionPaymentUtilClass.denullify(allPR_temp.ASI_CRM_CN_Total_Other_Amount__c, 0);

                        //TotalPaymentVariableAmount += allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c:0;
                        //TotalPaymentVariableAmount += allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c:0;
                        //TotalPaymentVariableAmount += allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c:0;

                    }
                }
            }
            */
            /* The TradeExpenses is auto calculated by sum of 3 subtotal
            //Calculate Total Paid Amount
            TotalPaymentAmount = ASI_CRM_CN_PromotionPaymentUtilClass.RetrieveTotalPaidAmount(allPaymentRequests);

            ActualPerformance.TradeExpenses=TotalPaymentAmount;
            ActualPerformance.VariableExpense+=TotalPaymentVariableAmount;
            */
            Decimal V0FixCostAmount=CalculateV0ContractCostAmount();
            Decimal V0ContractAmount =  CalculateV0ContractDetailCost();
            /*
            if (ASI_CRM_CN_PromotionPaymentUtilClass.isNotNullOrZero(V0ContractAmount) && (ASI_CRM_CN_PromotionPaymentUtilClass.isNotNullOrZero(ActualPerformance.DisplayExpensesTotal) || ASI_CRM_CN_PromotionPaymentUtilClass.isNotNullOrZero(ActualPerformance.PSFExpensesTotal))){
                system.debug('Now PSFExpensesTotal: '+ActualPerformance.PSFExpensesTotal);
                system.debug('Now DisplayExpensesTotal: '+ActualPerformance.DisplayExpensesTotal);
                system.debug('Now OtherExpensesTotal: '+ActualPerformance.OtherExpensesTotal);
                system.debug('Now V0ContractAmount: ' + V0ContractAmount);
                PaymentSpeedexcFixCost = ((ActualPerformance.DisplayExpensesTotal + ActualPerformance.PSFExpensesTotal) / V0ContractAmount) * 100; // No inculding Fix Cost
            }*/


            List<ASI_TH_CRM_PaymentRequestLineItem__c> PRLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            // try{
                //query All Payment Variable & Fixed Cost
            //     PRLineItems = [SELECT Id, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Total_Payable__c,ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,
            //             ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c, RecordTypeId,RecordType.DeveloperName,ASI_CRM_Adjustment__c,
            //             ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Cost__c, 
            //             ASI_TH_CRM_Payment_Request__r.Name,ASI_CRM_CN_Item_Group__r.Name,
            //             ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Unit_Price__c,ASI_TH_CRM_Quantity__c
            //     FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c and (ASI_TH_CRM_Payment_Request__c =:thisPR.Id
            //     OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR
            //     ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted'  OR
            //     ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid')];
            // }catch(Exception e){
            //     PRLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c >();
            // }

            /*Other Expenses is calculated already
            for ( ASI_TH_CRM_PaymentRequestLineItem__c  li_temp : PRLineItems ){
                if(li_temp.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_Other'){
                    if(li_temp.ASI_CRM_CN_Cost_Type__c == 'Fixed' ){
                        ActualPerformance.OtherExpensesTotal += li_temp.ASI_TH_CRM_Amount__c!=null? li_temp.ASI_TH_CRM_Amount__c:0;
                    }
                }
            }*/

            //add freegoods payment Line item
            freeGoodsList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            for ( ASI_TH_CRM_PaymentRequestLineItem__c  li_temp : [SELECT Id, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Total_Payable__c,ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,
                        ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c, RecordTypeId,RecordType.DeveloperName,ASI_CRM_Adjustment__c,
                        ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Cost__c, 
                        ASI_TH_CRM_Payment_Request__r.Name,ASI_CRM_CN_Item_Group__r.Name,
                        ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Unit_Price__c,ASI_TH_CRM_Quantity__c
                FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c 
                AND RecordType.DeveloperName = 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods' 
                and (ASI_TH_CRM_Payment_Request__c =:thisPR.Id
                OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR
                ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted'  OR
                ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid')] ){
                // if(li_temp.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods'){
                    freeGoodsList.add(li_temp);
                // }
            }

            if (!freeGoodsList.isEmpty()) {
                DisplayFreeGoods = true;
            }


            V0ContractAmount += V0FixCostAmount;
            /*
            if (V0ContractAmount != null && V0ContractAmount !=0 && ActualPerformance.TradeExpenses != null && ActualPerformance.TradeExpenses != 0){
                system.debug('now ActualPerformance.TradeExpenses: ' + ActualPerformance.TradeExpenses);
                system.debug('now V0FixCostAmount: '+V0FixCostAmount);
                PaymentSpeed = (ActualPerformance.TradeExpenses / V0ContractAmount) * 100;
            }*/


            LoopingSubBrandVolumeCMGSList();
            LoopingPaymentRequestLine();

            lstApprovalComment = [SELECT Id, ASI_CRM_BA_comments__c FROM ASI_CRM_Approval_Comment__c
            WHERE ASI_CRM_Payment_Request__c =:thisPR.Id];
            if(lstApprovalComment==null || lstApprovalComment.size()==0){
                lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
            }
            ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
        }

        init_SubBrandVolumeData();

        if(thisPR.ASI_CRM_CN_Last_Payment__c && ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Wholesaler Promotion'){
            init_WholeSalerInterimData();
        }

        return true;
    }


    //Loading WS/Outlet Sub-brand Volume
    public void init_SubBrandVolumeData(){

        Date endDate = ContractSelected.ASI_CRM_CN_PO_End_Date__c;
        List<ASI_CRM_Module__c> moduleList = [select ASI_CRM_End_Date__c FROM ASI_CRM_Module__c WHERE ASI_CRM_Payment_Request__c = :HeaderId and ASI_CRM_End_Date__c != null];
        if(moduleList.size()>0){
            endDate = moduleList[0].ASI_CRM_End_Date__c;
        }

        //Get Contract detail Line
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = [
                SELECT Id,
                        ASI_CRM_CN_Contract_Monthly_Qty__c,
                        ASI_CRM_CN_Contract_Monthly_Vol9L__c,
                        ASI_CRM_CN_Contract_Purchase_Value__c,
                        ASI_CRM_CN_Contract_Total_Dummy__c,
                        ASI_CRM_CN_Contract__c,
                        ASI_CRM_CN_Est_Monthly_Qty__c,
                        ASI_CRM_CN_Estimate_Volume_9L_Month__c,
                        ASI_CRM_CN_Estimate_Purchase_Value__c,
                        ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_Sub_Brand__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_English_Name__c,
                        ASI_CRM_CN_Sub_Brand__r.Name,
                        ASI_CRM_Contract_Total_QTY_std_Btl__c,
                        ASI_CRM_Type__c,
                        RecordType.DeveloperName,
                        ASI_CRM_CN_Total_Volume_9L__c,
                        ASI_CRM_CN_Pack_Size__c ,
                        ASI_CRM_CN_Drop_In__c
                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id
                AND ASI_CRM_Type__c = 'BRSF'
        ];

        Set<Id> SubBrandExcludeSet = new Set<Id>(); 
        Map<Id ,String> subBrandPackSizeMap = new Map<Id ,String>();
        Map<Id ,Boolean> subBrandDropInMap = new Map<Id ,Boolean>();               
        //Build SubBrand Outlet WS map
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractLineList) {

            if(ContractLine.ASI_CRM_CN_Pack_Size__c != null)
            {
                SubBrandExcludeSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                if(subBrandPackSizeMap.size() > 0 && !subBrandPackSizeMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c))
                {
                    subBrandPackSizeMap.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Pack_Size__c);
                }
                else
                {
                    String packSize = subBrandPackSizeMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                    subBrandPackSizeMap.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, packSize + ContractLine.ASI_CRM_CN_Pack_Size__c);
                }
            }

            if(ContractLine.ASI_CRM_CN_Drop_In__c)
            {
                SubBrandExcludeSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                subBrandDropInMap.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Drop_In__c);

            }

            VolValueInterimData d = new VolValueInterimData();
            d.subBrand = ContractLine.ASI_CRM_CN_Sub_Brand__r;
            d.volume9LV0 = ContractLine.ASI_CRM_CN_Total_Volume_9L__c != null ? ContractLine.ASI_CRM_CN_Total_Volume_9L__c : 0;
            SubBrandInterimDataMap.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, d);
            interimDataSortMap.put(ContractLine.Id,ContractLine.ASI_CRM_CN_Sub_Brand__c);
        }

        Set<Id> OutletIdSet = generatingOutletId(this.ContractSelected.ASI_CRM_CN_Data_Source__c == 'WS Intake' ? 'ASI_CRM_CN_WS' :'ASI_CRM_Outlet_CN');
        Set<Id> SubBrandIdSet = new Set<Id>();
        for(String key : SubBrandInterimDataMap.keySet()){
            Id subBrandId = Id.valueOf(key);
            SubBrandIdSet.add(subBrandId);
        }

        //ASI_CRM_Exclude_Item_Group_Volume__c
        List<ASI_CRM_Exclude_Item_Group_Volume__c> exclusionList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>(); //getSubbrandVolume(OutletIdSet);
        String excludeQuery = 'select ' + exclusionFieldList() + ' From ASI_CRM_Exclude_Item_Group_Volume__c';
        if(!Test.isRunningTest())
        {
            excludeQuery += ' Where ASI_CRM_Sub_Brand__c != null '+ ' ' +
                        ' and ASI_CRM_Sub_Brand__c in: SubBrandExcludeSet'+ ' ' +
                        ' and ASI_CRM_End_Date__c >=' + String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
                        ' and ASI_CRM_End_Date__c <=' + String.valueOf(endDate) + ' ' +
                        ' and (ASI_CRM_Account__c in: OutletIdSet or ASI_CRM_Outlet__c in: OutletIdSet)'+ ' ' +
                        ' and ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Exclusion__c = true';
        }
        exclusionList  = Database.query(excludeQuery);


        //Sub-brand Volume
        List<ASI_CRM_Subbrand_Volume__c> volumes = new List<ASI_CRM_Subbrand_Volume__c>(); //getSubbrandVolume(OutletIdSet);

        String subBrandVolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
        subBrandVolumeQuery += 'WHERE ASI_CRM_Subbrand__c !=null ' +
                'AND ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
                'AND ASI_CRM_End_Date__c >= ' + String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
                'AND ASI_CRM_End_Date__c <= ' + String.valueOf(endDate) + ' ' +
                'AND ASI_CRM_Subbrand__c IN :SubBrandIdSet ' +
                'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = false ';

        subBrandVolumeQuery += 'AND ASI_CRM_Account__c !=null ' +
                'AND ASI_CRM_Account__c IN :OutletIdSet ' +
                'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';

        System.debug('subBrandVolumeQuery: ' + subBrandVolumeQuery);
        volumes = Database.query(subBrandVolumeQuery);

        //Sub-brand Volume
        for (ASI_CRM_Subbrand_Volume__c volume : volumes){
            String SubBrandkey = volume.ASI_CRM_Subbrand__c;

            if (SubBrandInterimDataMap.containsKey(SubBrandkey)) {
                SubBrandInterimDataMap.get(SubBrandkey).addVolume(volume, this.ContractSelected.ASI_CRM_CN_Data_Source__c);
            }
        }

        // ASI_CRM_Exclude_Item_Group_Volume__c
        // Bowen 扣减逻辑，判断subbrandid所包含的packsize和dropin，与exclusion进行对比，符合条件的，即进行扣减逻辑
        for (ASI_CRM_Exclude_Item_Group_Volume__c exclude : exclusionList)
        {
            String SubBrandkey = exclude.ASI_CRM_Sub_Brand__c;

            String BRSF_PackSize = (subBrandPackSizeMap.containsKey(exclude.ASI_CRM_Sub_Brand__c) ?
                                                subBrandPackSizeMap.get(exclude.ASI_CRM_Sub_Brand__c) : '');
            Boolean isDropIn = (subBrandDropInMap.containsKey(exclude.ASI_CRM_Sub_Brand__c) ?
                                subBrandDropInMap.get(exclude.ASI_CRM_Sub_Brand__c) : false);

            if(SubBrandInterimDataMap.containsKey(SubBrandkey))
            {
                if(!isFlag(BRSF_PackSize, isDropIn, exclude))
                {
                    SubBrandInterimDataMap.get(SubBrandkey).exclusionVolume(exclude, this.ContractSelected.ASI_CRM_CN_Data_Source__c);
                }
            }
            
        }

        Decimal TotalV0VolCR12 = 0;
        Decimal TotalActualVolCR12 = 0;
        for(VolValueInterimData data :SubBrandInterimDataMap.values()){
            TotalV0VolCR12 += (data.volume9LV0 * (data.subBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null ? data.subBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c : 1));
            TotalActualVolCR12 += (data.volume9L * (data.subBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null ? data.subBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c : 1));
        }
        if(TotalV0VolCR12 != null && TotalV0VolCR12 != 0){
            VolSpeed = (TotalActualVolCR12 / TotalV0VolCR12) * 100;
        }
    }

    /*
        Author：Bowen
        Function：判断exclusion是否符合BRSF line中需扣减的条件
     */
    public static Boolean isFlag(String BRSF_PackSize ,boolean isDropIn ,ASI_CRM_Exclude_Item_Group_Volume__c exclude)
    {
        boolean itemFlag = true;
 
        if((BRSF_PackSize != null || BRSF_PackSize != '' )
            && (exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c  != null))
        {
                        
            Integer pointCount = exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c.indexOf('.');
            String BT_Size = exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c.substring(0 ,pointCount);
            // system.debug('BRSF_PackSize =='+ BRSF_PackSize +'---BT_Size =='+ BT_Size);
            if(BRSF_PackSize.indexOf(BT_Size) != -1)
            {
                itemFlag = false;
            }
            
        }
        /* 
            如果payment request line item中BRSF line item的drop in 为true
            且当前exclude item group volume中item group 的drop in也为true，
            即将exclude item group volume视为可扣减对象，进行标识
        */
       
        if(itemFlag && isDropIn 
            && exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c)
        {
            itemFlag = false;
        }
        return itemFlag;

    }

    public void init_WholeSalerInterimData(){
        Set<Id> WSIdSet = generatingOutletId(this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' ? 'ASI_CRM_CN_WS' :'ASI_CRM_Outlet_CN');
        integer Index = 1;
        for(ASI_TH_CRM_PaymentRequestLineItem__c p :[select Id,
                                                            ASI_CRM_CN_Wholesaler__c,
                                                            ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c,
                                                            ASI_CRM_CN_Wholesaler__r.Name,
                                                            ASI_CRM_Actual_Value_Base__c
                                                     from ASI_TH_CRM_PaymentRequestLineItem__c
                                                     where ASI_TH_CRM_Payment_Request__c = :thisPR.Id
                                                     and recordType.DeveloperName = 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS'
                                                     and ASI_CRM_CN_Wholesaler__c in :WSIdSet
                                                     order by ASI_CRM_Actual_Value_Base__c desc
        ]){
            //Show top 10 only
            if(Index <= 10) {
                WholeSalerInterimData Data = new WholeSalerInterimData();
                Data.paymentRequestLineOutletWS = p;
                WholeSalerInterimDataMap.put(p.ASI_CRM_CN_Wholesaler__c, Data);
                WholeSalerInterimDataSortMap.put(Index, p.ASI_CRM_CN_Wholesaler__c);
            }
            TotalWsPurchaseValue += p.ASI_CRM_Actual_Value_Base__c != null ? p.ASI_CRM_Actual_Value_Base__c : 0;
            Index++;
        }

        for (ASI_CRM_Module__c module : [
                SELECT
                        ASI_CRM_Actual_Payment__c,
                        ASI_CRM_Application_Payment_Amount__c,
                        ASI_CRM_CN_Customer__c,
                        ASI_CRM_CN_Customer__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_End_Date__c,
                        ASI_CRM_Historical_Paid_Amount__c,
                        ASI_CRM_Line_Type__c,
                        ASI_CRM_Methodology__c,
                        ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
                        ASI_CRM_Methodology__r.Name,
                        ASI_CRM_Other_Comments__c,
                        ASI_CRM_Parent_Module__c,
                        ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,
                        ASI_CRM_Parent_Module__r.ASI_CRM_Created_PO_Version__c,
                        ASI_CRM_Parent_Module__r.Name,
                        ASI_CRM_Created_PO_Version__c,
                        ASI_CRM_Volume_Base__c,
                        Id, (
                        SELECT
                                ASI_CRM_CN_Actual_Vol__c,
                                ASI_CRM_CN_Allow_Changing_Incentive__c,
                                ASI_CRM_CN_Comment__c,
                                ASI_CRM_Customer__c,
                                ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c,
                                ASI_CRM_Customer__r.Name,
                                ASI_CRM_CN_Rebate_Percent__c,
                                ASI_CRM_Historical_Paid_Amount__c,
                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c,
                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c,
                                ASI_CRM_CN_Item_Group__c,
                                ASI_CRM_CN_Item_Group__r.Name,
                                ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,
                                ASI_CRM_CN_Sub_Brand__c,
                                ASI_CRM_CN_Total_Payable__c,
                                ASI_CRM_CN_Wholesaler__c,
                                ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c,
                                ASI_CRM_CN_Wholesaler__r.Name,
                                ASI_CRM_CTD_Actual_Purchase_Value__c,
                                ASI_CRM_CTD_Actual_Vol__c,
                                ASI_CRM_Line_Long_Name__c,
                                ASI_CRM_Module__c,
                                ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                                ASI_CRM_Volume_Base__c,
                                ASI_TH_CRM_Payment_Request__c,
                                ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                                ASI_CRM_CN_WS_Intake_9L__c,
                                ASI_CRM_CN_Outlet_Intake_9L__c,
                                ASI_CRM_CN_POS_Volume__c,
                                ASI_CRM_CN_POS_Value__c,
                                ASI_CRM_CTD_Actual_Retail_Value__c,
                                ASI_CRM_Actual_Value_Base__c,
                                Id,
                                RecordType.DeveloperName,
                                RecordTypeId
                        FROM Payment_Request_Line_Items__r
                        WHERE ASI_TH_CRM_Payment_Request__c = :thisPR.Id
                        ORDER BY ASI_CRM_CN_Wholesaler__c DESC
                )
                FROM ASI_CRM_Module__c
                WHERE ASI_CRM_Payment_Request__c = :thisPR.Id
        ]) {
            if(module.Payment_Request_Line_Items__r.size()>0){
                if(WholeSalerInterimDataMap.containsKey(module.Payment_Request_Line_Items__r[0].ASI_CRM_CN_Wholesaler__c)){
                    WholeSalerInterimDataMap.get(module.Payment_Request_Line_Items__r[0].ASI_CRM_CN_Wholesaler__c).incentive += module.ASI_CRM_Actual_Payment__c != null ? module.ASI_CRM_Actual_Payment__c : 0;
                }
                TotalWsIncentive += module.ASI_CRM_Actual_Payment__c != null ? module.ASI_CRM_Actual_Payment__c :0;
            }
        }
        if(TotalWsPurchaseValue != null && TotalWsPurchaseValue != 0){
            TotalWsIncentivePercent =  TotalWsIncentive/TotalWsPurchaseValue*100;
        }

    }

    //setup init variable
    public void InitVariable(){
        TotalPaymentVariableAmount=0;
        BRSF_CTD_CR12=0;
        PayeeList=new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        CutOffDay=ASI_CRM_DateUtilClass.getCutOffDate();
        if (strPDF == '1'){
            AdorAbove = ASI_CRM_CN_OffContractUtilitiesClass.checkUserID();
        }else if (strPDF == '0'){
            AdorAbove=ASI_CRM_CN_OffContractUtilitiesClass.checkApprover(thisPR.Id);
        }


        //Sub Brand Grade---> Sub Brand Grade Group
        SubbrandGroup = new Map<String, String>();
        NewContractV0Estimate = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();
        NewContactV0Contract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();
        ActualPerformance = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();
        RegionSubBrandCM_Map = new Map<String,Decimal>();
        if(thisPR.ASI_CRM_CN_Last_Payment__c){
            List<ASI_HK_CRM_Product_Category__c> productCategoryList = [
                    SELECT Name, ASI_HK_CRM_English_Name__c, ASI_CRM_CN_Chinese_Name__c, ASI_HK_CRM_Sequence__c
                    FROM ASI_HK_CRM_Product_Category__c
                    WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Product_Category'
                    AND ASI_HK_CRM_English_Name__c != 'RTD'
                    AND ASI_HK_CRM_English_Name__c != 'Baijiu'
                    ORDER BY ASI_HK_CRM_Sequence__c
            ];
            for (ASI_HK_CRM_Product_Category__c productCategory : productCategoryList){
                String categoriesMapKey = productCategory.ASI_HK_CRM_Sequence__c + '. ' + productCategory.ASI_HK_CRM_English_Name__c + ' - ' + productCategory.ASI_CRM_CN_Chinese_Name__c;
                String productCategoryEnglishName = productCategory.ASI_HK_CRM_English_Name__c;
                categoriesMap.put(productCategoryEnglishName, 0);
                categoriesDisplayMap.put(categoriesMapKey, productCategoryEnglishName);

                ASI_CRM_CN_OffContractUtilitiesClass.fillMap(NewContractV0Estimate.CategoryVolumeMap, productCategoryEnglishName, 0.0);
                ASI_CRM_CN_OffContractUtilitiesClass.fillMap(NewContactV0Contract.CategoryVolumeMap, productCategoryEnglishName, 0.0);
                ASI_CRM_CN_OffContractUtilitiesClass.fillMap(ActualPerformance.CategoryVolumeMap, productCategoryEnglishName, 0.0);

                ASI_CRM_CN_OffContractUtilitiesClass.fillMap(NewContractV0Estimate.CategoryVolumeMap, productCategoryEnglishName, 0.0);
                ASI_CRM_CN_OffContractUtilitiesClass.fillMap(NewContactV0Contract.CategoryVolumeMap, productCategoryEnglishName, 0.0);
                ASI_CRM_CN_OffContractUtilitiesClass.fillMap(ActualPerformance.CategoryVolumeMap, productCategoryEnglishName, 0.0);

            }
        }
    }



    public void LoopingSubBrandVolumeCMGSList(){
        Decimal Vol_CR12_1 =0; //All Payment Period


        Map<String, Decimal> ActualCM_v1_map = new Map<String, Decimal>();
        Map<String, Decimal> ActualGS_v1_map= new Map<String, Decimal>();
        Map<String, Decimal> lbcm_v1_map= new Map<String, Decimal>();
        Decimal ActualIntakeTotal = 0;//for calculating bc%
        List<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new List<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
            FROM ASI_CRM_CN_Covered_Outlet__c
            WHERE ASI_CRM_CN_Contract__c = :thisPR.ASI_TH_CRM_Contract__c];
        }catch(Exception e){
            CoveredOutlet = new List<ASI_CRM_CN_Covered_Outlet__c>();
        }
        Set<Id> AllOutlet = new Set<Id>();
        ASI_TH_CRM_PaymentRequest__c tempPR = [SELECT Id, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_PaymentRequest__c WHERE Id = :thisPR.Id];
        if (tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(thisPR.ASI_CRM_CN_OutletWS__c);
        }
        if (tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }
        Date TillEnd = ASI_CRM_DateUtilClass.getEndOfMonth(ASI_CRM_DateUtilClass.findMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN'));


        System.debug('Payment thisPR.ASI_CRM_CN_PO_Start_Date__c: '+thisPR.ASI_CRM_CN_PO_Start_Date__c);
        System.debug('Payment TillEnd: '+TillEnd);
        List<ASI_CRM_Subbrand_Volume__c> subBrandVolumeList = new List<ASI_CRM_Subbrand_Volume__c> ();
        Id PRDORecordTypeId = ASI_CRM_Subbrand_Volume__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data').getRecordTypeId();
        // try{
            String subBrandVolumeQuery = 'SELECT ' + ASI_CRM_CN_OffContractUtilitiesClass.SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
            subBrandVolumeQuery += 'WHERE ASI_CRM_Subbrand__c !=null ' +
                    'AND ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
                    'AND ASI_CRM_End_Date__c >= ' + String.valueOf(thisPR.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
                    'AND ASI_CRM_End_Date__c <= ' + String.valueOf(TillEnd) + ' ' +
                    'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = false ';

            if (AllOutlet.size() >= ASI_CRM_CN_OffContractUtilitiesClass.outletThreshold()){
                subBrandVolumeQuery += 'AND ASI_CRM_CN_Contract__c = \'' + thisPR.ASI_TH_CRM_Contract__c + '\' ' +
                        'AND recordtypeId = \'' + PRDORecordTypeId+'\' ';


            } else {
                subBrandVolumeQuery += 'AND ASI_CRM_Account__c IN :AllOutlet ' +
                        'AND recordType.DeveloperName NOT IN (\'' + String.join(ASI_CRM_CN_OffContractUtilitiesClass.RECORD_TYPE_LIST_AGGREGATION, '\',\'') + '\') ';

            }
            System.debug('subBrandVolumeQuery: ' + subBrandVolumeQuery);
            if(test.isRunningTest()) {subBrandVolumeQuery = 'SELECT ' + ASI_CRM_CN_OffContractUtilitiesClass.SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';}
            subBrandVolumeList = Database.query(subBrandVolumeQuery);
        // }catch(Exception e){
        //     System.debug(e.getMessage());
        //     subBrandVolumeList = new List<ASI_CRM_Subbrand_Volume__c >();
        // }

        if(thisPR.ASI_CRM_CN_Last_Payment__c){ // If it is last Payment
            List<ASI_CRM_CM_GS__c> ActualCM_List = new List<ASI_CRM_CM_GS__c>();
            Map<Date, Decimal> V1_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(thisPR.ASI_CRM_CN_PO_Start_Date__c, thisPR.ASI_CRM_CN_PO_End_Date__c);
            System.debug('Now V1_Period_map: '+ V1_Period_map);
            v1_ROI_newMap = new Map<String, ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data>();

            Set<Id> v1_sbid_set = new Set<Id>(); //ActualPerformance
            // if (subBrandVolumeList.size() > 0){
                for (ASI_CRM_Subbrand_Volume__c SubBrandVolume : Database.query(subBrandVolumeQuery) ){

                    v1_sbid_set.add(SubBrandVolume.ASI_CRM_Subbrand__c);
                    String sbGradeName ='';
                    Decimal ActualVolumes=0;
                    ActualVolumes+=SubBrandVolume.ASI_CRM_T1_Depletion__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion__c:0;
                    ActualVolumes+=SubBrandVolume.ASI_CRM_T2_Depletion__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion__c:0;
                    ActualVolumes+=SubBrandVolume.ASI_CRM_PR_Direct__c!=null? SubBrandVolume.ASI_CRM_PR_Direct__c:0;

                    ActualPerformance.Volumes+=ActualVolumes;

                    //Put data into CategoryVolumeMap
                    if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c !=null && SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                        String CategoryName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;

                        ActualPerformance.CategoryVolumeMap = ASI_CRM_CN_OffContractUtilitiesClass.addToDecimalMap(ActualPerformance.CategoryVolumeMap, CategoryName, ActualVolumes);
                    }
                    /*
                    if (SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                        if (SubbrandGroup.containskey(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name)){
                            sbGradeName = SubbrandGroup.get(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                        }else{
                            sbGradeName = 'Not Specified / 未指定';
                        }
                    }else{
                        sbGradeName = 'Not Specified / 未指定';
                    }

                    if(ActualPerformance.SubBrandGradeMap.containskey(sbGradeName)){
                        Decimal TempVolumes=ActualPerformance.SubBrandGradeMap.get(sbGradeName)+ActualVolumes;
                        ActualPerformance.SubBrandGradeMap.remove(sbGradeName);//remove orignal one
                        ActualPerformance.SubBrandGradeMap.put(sbGradeName,TempVolumes);
                    }else{
                        ActualPerformance.SubBrandGradeMap.put(sbGradeName,ActualVolumes);
                    }
                    */

                }
            // }

            if (V1_Period_map.size() > 0){
                String strkey;
                for (Date v1temp : V1_Period_map.keySet()){
                    if (v1_sbid_set.size() > 0){
                        for (Id sbtemp : v1_sbid_set){
                            strkey = String.valueOf(v1temp) + sbtemp;
                            System.debug('V1 strkey : '+strkey);
                            ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data();
                            newitem.period = V1_Period_map.get(v1temp);
                            newitem.SubBrandId = sbtemp;
                            newitem.year = String.valueOf(v1temp.year());
                            newitem.TotalVolume = 0;

                            if (!v1_ROI_newMap.containsKey(strkey)){
                                v1_ROI_newMap.put(strkey, newitem);
                            }
                        }
                    }
                }
            }

            Date strV1End = ASI_CRM_DateUtilClass.findMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN');
            System.debug('ActualCM Now strStart '+strStart);
            System.debug('ActualCM Now strV1End '+strV1End);

            // try{
            //     ActualCM_List = [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,
            //             ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_TYPE__c
            //     FROM ASI_CRM_CM_GS__c
            //     WHERE ASI_CRM_PRODUCTCODE__c IN :v1_sbid_set
            //     AND ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            //     AND ASI_CRM_CN_Month_End_Date__c >= :strStart
            //     AND ASI_CRM_CN_Month_End_Date__c <= :strV1End
            //     AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS')
            //     AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0
            //     ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC];
            // }catch(Exception e){
            //     ActualCM_List = new List<ASI_CRM_CM_GS__c>();
            // }



            // if (ActualCM_List.size() > 0){
                String strkey;
                String subbrand_id;
                String lastestkey;
                for (ASI_CRM_CM_GS__c ACM_temp : [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,
                        ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_TYPE__c
                FROM ASI_CRM_CM_GS__c
                WHERE ASI_CRM_PRODUCTCODE__c IN :v1_sbid_set
                AND ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                AND ASI_CRM_CN_Month_End_Date__c >= :strStart
                AND ASI_CRM_CN_Month_End_Date__c <= :strV1End
                AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS')
                AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0
                ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC]){
                    subbrand_id = ACM_temp.ASI_CRM_PRODUCTCODE__c;
                    strkey = String.valueOf(ACM_temp.ASI_CRM_CN_Month_End_Date__c) + subbrand_id;

                    Decimal ActualCMperBtl = null;
                    if (ACM_temp.ASI_CRM_CM_GS_per_9L__c != null){
                        ActualCMperBtl = ACM_temp.ASI_CRM_CM_GS_per_9L__c;
                    }

                    lastestkey = subbrand_id;
                    if (ACM_temp.ASI_CRM_TYPE__c == 'YTD CM'){
                        if (!ActualCM_v1_map.containsKey(lastestkey) && ActualCMperBtl != Null && ActualCMperBtl != 0){//system.debug('Now Put '+lastestkey+' ActualCMperBtl : '+ActualCMperBtl);
                            ActualCM_v1_map.put(lastestkey, ActualCMperBtl);
                        }
                        if (v1_ROI_newMap.containsKey(strkey)){
                            if ((v1_ROI_newMap.get(strkey).actualCM == null || v1_ROI_newMap.get(strkey).actualCM == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0){
                                v1_ROI_newMap.get(strkey).actualCM = ActualCMperBtl; //v1_ROI_newMap.get(strkey).sbname = ACM_temp.ASI_CRM_PRODUCTCODE__r.Name;
                            }
                        }
                    }
                    if (ACM_temp.ASI_CRM_TYPE__c == 'YTD GS'){
                        if (!ActualGS_v1_map.containsKey(lastestkey) && ActualCMperBtl != Null && ActualCMperBtl != 0){//system.debug('Now Put '+lastestkey+' ActualCMperBtl : '+ActualCMperBtl);
                            ActualGS_v1_map.put(lastestkey, ActualCMperBtl);
                        }

                        if (v1_ROI_newMap.containsKey(strkey)){
                            if ((v1_ROI_newMap.get(strkey).actualGS == null || v1_ROI_newMap.get(strkey).actualGS == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0){
                                v1_ROI_newMap.get(strkey).actualGS = ActualCMperBtl;

                            }
                        }else{

                        }
                    }

                    if (!lbcm_v1_map.containsKey(lastestkey))
                        if ( RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c)) {
                            lbcm_v1_map.put(lastestkey, RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_PRODUCTCODE__c));
                        }


                    if (v1_ROI_newMap.containsKey(strkey)){
                        if (v1_ROI_newMap.get(strkey).latestBudgetCM == null || v1_ROI_newMap.get(strkey).latestBudgetCM == 0){
                            if (RegionSubBrandCM_Map.containsKey(ACM_temp.ASI_CRM_PRODUCTCODE__c)) {
                                v1_ROI_newMap.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(ACM_temp.ASI_CRM_PRODUCTCODE__c);
                            }
                        }// v1_ROI_newMap.get(strkey).sbname = ACM_temp.ASI_CRM_PRODUCTCODE__r.Name;
                    }

                }
            // }


        }




        //Looping Sub-brand Volume
        for (ASI_CRM_Subbrand_Volume__c  SB_Vol_temp : Database.query(subBrandVolumeQuery)){
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c!=null?SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c:0;

            Decimal  MarginUseTotalVol_std = 0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_PR_Direct_STD__c!=null?SB_Vol_temp.ASI_CRM_PR_Direct_STD__c:0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c!=null?SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c:0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c!=null?SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c:0;
            ActualIntakeTotal += MarginUseTotalVol_std;

            String Mapkeystr= ASI_CRM_CN_OffContractUtilitiesClass.NameSortingASC(SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            Decimal CTDActualVol=0.0;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c;

            CTDActualVol=CTDActualVol.setScale(0);
            if(VolumeMap.containsKey(Mapkeystr)){
                VolumeObject TempObject= VolumeMap.get(Mapkeystr);
                TempObject.CTDActualVol +=CTDActualVol;
                VolumeMap.remove(Mapkeystr);
                VolumeMap.put(Mapkeystr, TempObject);
            }else{
                VolumeObject TempObject= new VolumeObject();
                TempObject.SubBrandGradeName=SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                TempObject.SubBrandGradeCNName = SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                TempObject.CTDActualVol=CTDActualVol;
                VolumeMap.put(Mapkeystr, TempObject);
            }

            Decimal   FC_actualvol_btl = 0;// Full Contract
            if (SB_Vol_temp.ASI_CRM_T1_Depletion__c!= null)
                FC_actualvol_btl = SB_Vol_temp.ASI_CRM_T1_Depletion__c;
            if (SB_Vol_temp.ASI_CRM_T2_Depletion__c!= null)
                FC_actualvol_btl += SB_Vol_temp.ASI_CRM_T2_Depletion__c;
            if (SB_Vol_temp.ASI_CRM_PR_Direct__c!= null)
                FC_actualvol_btl += SB_Vol_temp.ASI_CRM_PR_Direct__c;

            Date endDate = ASI_CRM_DateUtilClass.getFiscalYearEndDate(SB_Vol_temp.ASI_CRM_End_Date__c);
            String strkey = String.valueOf(endDate) + SB_Vol_temp.ASI_CRM_Subbrand__c;


            if (v1_ROI_newMap.containsKey(strkey)){
                if (v1_ROI_newMap.get(strkey).actual_vol != null)
                    v1_ROI_newMap.get(strkey).actual_vol += FC_actualvol_btl;
                else
                        v1_ROI_newMap.get(strkey).actual_vol = FC_actualvol_btl;
            }else{
                ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data newDC1 = new ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data();
                newDC1.actual_vol = FC_actualvol_btl;
                newDC1.SubBrandId = SB_Vol_temp.ASI_CRM_Subbrand__c;
                v1_ROI_newMap.put(strkey, newDC1);
            }

        }





        for (String  VolumeMapKey:VolumeMap.keySet()){
            if(VolumeMap.get(VolumeMapKey).FullContractTarget==0 && VolumeMap.get(VolumeMapKey).CTDActualVol==0){
                VolumeMap.remove(VolumeMapKey);
            }
        }


        //************************Calculation****************************************
        if (Vol_CR12_1  != null && Vol_CR12_1  != 0 && BRSF_CTD_CR12 != null && BRSF_CTD_CR12 != 0){
            System.debug('Now Vol_CR12_1'+Vol_CR12_1);
            System.debug('Now BRSF_CTD_CR12'+BRSF_CTD_CR12);
            Other_VOL_CR12 =  (Vol_CR12_1 / BRSF_CTD_CR12)  * 100;
        }

        //VFinal ROI Actual Performance 1452
        if (v1_ROI_newMap.size() > 0){
            Decimal totalsb_cm_v1 = 0;
            Decimal totalsb_gs_v1 = 0;
            Integer tilldateperiod;
            Decimal totalsb_lbcm_v1 = 0;
            System.debug('v1_ROI_newMap.size() ' + v1_ROI_newMap.size());
            for (ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data sb_v1 : v1_ROI_newMap.values()){

                Decimal actualCM = null;
                if (sb_v1.actualCM != null && sb_v1.actualCM != 0){
                    actualCM = sb_v1.actualCM;
                }else if (ActualCM_v1_map.containsKey(sb_v1.SubBrandId)){
                    actualCM = ActualCM_v1_map.get(sb_v1.SubBrandId);
                }

                if (sb_v1.actual_vol != null && actualCM != null){
                    totalsb_cm_v1 += sb_v1.actual_vol * actualCM;
                }


                Decimal latestBudgetCM = null;
                if (sb_v1.actualCM != null && sb_v1.actualCM != 0){
                    latestBudgetCM = sb_v1.latestBudgetCM;
                }else if (lbcm_v1_map.containsKey(sb_v1.SubBrandId)){
                    latestBudgetCM = lbcm_v1_map.get(sb_v1.SubBrandId);
                }
                if (sb_v1.actual_vol != null && latestBudgetCM != null){
                    totalsb_lbcm_v1 += sb_v1.actual_vol * latestBudgetCM;
                }


                //GS
                Decimal actualGS = null;
                if (sb_v1.actualGS != null && sb_v1.actualGS != 0){
                    actualGS = sb_v1.actualGS;
                }else if (ActualGS_v1_map.containsKey(sb_v1.SubBrandId)){
                    actualGS = ActualGS_v1_map.get(sb_v1.SubBrandId);
                }
                if (sb_v1.actual_vol != null && actualGS != null){
                    totalsb_gs_v1 += sb_v1.actual_vol * actualgs;
                }
            }
            System.debug('totalsb_lbcm_v1 ' + totalsb_lbcm_v1);

            ActualPerformance.GrossSalesTotal = totalsb_gs_v1;
            ActualPerformance.IntakeSTD = ActualIntakeTotal;

            //vFinal Actual ROI
            if (ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null && totalsb_cm_v1 != null && totalsb_cm_v1 != 0)
                ActualPerformance.ROIIntake= totalsb_cm_v1 / ActualPerformance.TradeExpenses;

            if(Vol_CR12_1!=null && Vol_CR12_1 !=0 && ActualPerformance.TradeExpenses !=null && ActualPerformance.TradeExpenses!=0 ){
                ActualPerformance.InvestmentCR12 = ActualPerformance.TradeExpenses /Vol_CR12_1;
            }
            //vFinal Actual Margin AP
            if (ActualPerformance.TradeExpenses != null && totalsb_cm_v1 != null)
                ActualPerformance.MarginAfterAnP = totalsb_cm_v1 - ActualPerformance.TradeExpenses;

            //vFinal Actual Pro-Forma ROI
            if (ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null && totalsb_lbcm_v1 != null && totalsb_lbcm_v1 != 0)
                ActualPerformance.ROIProForma = totalsb_lbcm_v1 / ActualPerformance.TradeExpenses;
        }
    }




    // Calculate Payment V0.0 Contract Detail Line Contarct Cost (not including Fix cost)
    Public Decimal CalculateV0ContractDetailCost(){
        Decimal BRSF_CTD_CR12_contract =0;// BRSF Total Volume in CR 12 All period

        Decimal BRSF_CTD_CR12_estimate =0;
        Decimal ContractAmount=0;
        Decimal v0Contract_totalBtl =0; // V0.0 contract Total per bt
        Decimal v0Estimate_totalBtl =0;// V0.0 Estimate Total per bt
        Set<Id> SubBrandIdSet = new Set<Id> ();
        Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
        Map<String, ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data> Subbrand_ROI_map_v0 =new Map<String, ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();

        Id V0ContractId = (Id)getV0ContractId();
        System.debug('Now V0ContractId'+V0ContractId);
        try{
            //query ContractBRSF Sub Brands & Data
            ContractLines = ASI_CRM_CN_OffContractUtilitiesClass.getBRSFLines(V0ContractId);
        }catch(Exception e){
            String msg = 'Save Error : ' +e.getMessage() + '</br>';
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_OffContractUtilitiesClass.CalculateV0EstCost  class have Error  '+msg,'ASI_CRM_CN_OffContractUtilitiesClass',' function failed! with Payment Id: '+thisPR.Id );
        }

        //1st Time Looping
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractDetail:ContractLines){
            if(ContractDetail.ASI_CRM_Type__c=='BRSF'){
                Decimal ContractVolumes9L=ContractDetail.ASI_CRM_CN_Contract_Monthly_Vol9L__c!=null? ContractDetail.ASI_CRM_CN_Contract_Monthly_Vol9L__c * ContractDetail.ASI_CRM_CN_No_of_Months__c:0;
                Decimal EstimateVolumes9L=ContractDetail.ASI_CRM_CN_Estimate_Volume_9L_Month__c!=null?ContractDetail.ASI_CRM_CN_Estimate_Volume_9L_Month__c * ContractDetail.ASI_CRM_CN_No_of_Months__c:0;


                //v0Contract_totalBtl += ContractVolumes9L;
                //v0Estimate_totalBtl+=EstimateVolumes9L;
                v0Contract_totalBtl+= ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractDetail.ASI_CRM_CN_No_of_Months__c:0;
                v0Estimate_totalBtl+= ContractDetail.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractDetail.ASI_CRM_CN_Est_Monthly_Qty__c*ContractDetail.ASI_CRM_CN_No_of_Months__c:0;


                Decimal ContractTarget=ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractDetail.ASI_CRM_CN_No_of_Months__c:0;

                String Mapkeystr= ASI_CRM_CN_OffContractUtilitiesClass.NameSortingASC(ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+ ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;

                if(VolumeMap.containsKey(Mapkeystr)){
                    VolumeObject TempObject= VolumeMap.get(Mapkeystr);
                    TempObject.FullContractTarget +=ContractTarget.setScale(0);
                    VolumeMap.remove(Mapkeystr);
                    VolumeMap.put(Mapkeystr, TempObject);
                }else{
                    VolumeObject TempObject= new VolumeObject();
                    TempObject.SubBrandGradeName=ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    TempObject.SubBrandGradeCNName = ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                    TempObject.FullContractTarget=ContractTarget.setScale(0);
                    VolumeMap.put(Mapkeystr, TempObject);
                }

                //Put data into CategoryVolumeMap
                if(ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c !=null && ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                    String CategoryName = ASI_CRM_CN_OffContractUtilitiesClass.getCategoryNameFromContractLine(ContractDetail);

                    NewContractV0Estimate.CategoryVolumeMap = ASI_CRM_CN_OffContractUtilitiesClass.addToDecimalMap(NewContractV0Estimate.CategoryVolumeMap, CategoryName, EstimateVolumes9L);
                    NewContactV0Contract.CategoryVolumeMap = ASI_CRM_CN_OffContractUtilitiesClass.addToDecimalMap(NewContactV0Contract.CategoryVolumeMap, CategoryName, ContractVolumes9L);
                }

                /*
                String sbGradeName='';

                if (ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                    if (SubbrandGroup.containskey(ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name)){
                        sbGradeName = SubbrandGroup.get(ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                    }else{
                        sbGradeName = 'Not Specified / 未指定';
                    }
                }else{
                    sbGradeName = 'Not Specified / 未指定';
                }

                if(NewContractV0Estimate.SubBrandGradeMap.containskey(sbGradeName)){
                    Decimal TempVolumes=NewContractV0Estimate.SubBrandGradeMap.get(sbGradeName)+EstimateVolumes9L;
                    NewContractV0Estimate.SubBrandGradeMap.remove(sbGradeName); //remove orignal one
                    NewContractV0Estimate.SubBrandGradeMap.put(sbGradeName,TempVolumes);
                }else{
                    NewContractV0Estimate.SubBrandGradeMap.put(sbGradeName,EstimateVolumes9L);
                }

                if(NewContactV0Contract.SubBrandGradeMap.containskey(sbGradeName)){
                    Decimal TempVolumes=NewContactV0Contract.SubBrandGradeMap.get(sbGradeName)+EstimateVolumes9L;
                    NewContactV0Contract.SubBrandGradeMap.remove(sbGradeName);//remove orignal one
                    NewContactV0Contract.SubBrandGradeMap.put(sbGradeName,TempVolumes);
                }else{
                    NewContactV0Contract.SubBrandGradeMap.put(sbGradeName,EstimateVolumes9L);
                }
                */


                SubBrandIdSet.add(ContractDetail.ASI_CRM_CN_Sub_Brand__c);//ASI_CRM_CN_Estimate_Volume_9L_Month__c
                //Calculate Volume
                NewContactV0Contract.Volumes+=ContractVolumes9L;
                NewContractV0Estimate.Volumes+=EstimateVolumes9L;

                Decimal ContractVolumes9LnoMonth=ContractDetail.ASI_CRM_CN_Contract_Monthly_Vol9L__c!=null? ContractDetail.ASI_CRM_CN_Contract_Monthly_Vol9L__c :0;
                Decimal EstimateVolumes9LnoMonth=ContractDetail.ASI_CRM_CN_Estimate_Volume_9L_Month__c!=null?ContractDetail.ASI_CRM_CN_Estimate_Volume_9L_Month__c :0;

                System.debug(ContractDetail.ASI_CRM_CN_Sub_Brand__c+' Subbrand_ROI_map_v0 '+EstimateVolumes9L);
                if (Subbrand_ROI_map_v0.containsKey(ContractDetail.ASI_CRM_CN_Sub_Brand__c)){
                    Subbrand_ROI_map_v0.get(ContractDetail.ASI_CRM_CN_Sub_Brand__c).actual_vol += EstimateVolumes9LnoMonth; //estimate volume
                    Subbrand_ROI_map_v0.get(ContractDetail.ASI_CRM_CN_Sub_Brand__c).target_vol += ContractVolumes9LnoMonth ;
                }else{
                    ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data newDC1 = new ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data();
                    newDC1.actualCM = 0;
                    newDC1.actualGS = 0;
                    newDC1.actual_vol = EstimateVolumes9LnoMonth;
                    newDC1.target_vol = ContractVolumes9LnoMonth ;
                    Subbrand_ROI_map_v0.put(ContractDetail.ASI_CRM_CN_Sub_Brand__c, newDC1);
                }
            } else if(ContractDetail.ASI_CRM_Type__c=='PSF'){
                NewContractV0Estimate.PSFExpensesTotal += ContractDetail.ASI_CRM_CN_Est_Total_Dummy__c;
                //NewContactV0Contract.PSFExpensesTotal += ContractDetail.ASI_CRM_CN_Contract_Total_Dummy__c;

            } else if(ContractDetail.ASI_CRM_Type__c=='Display'){
                NewContractV0Estimate.DisplayExpensesTotal += ContractDetail.ASI_CRM_CN_Est_Total_Dummy__c;
                //NewContactV0Contract.DisplayExpensesTotal += ContractDetail.ASI_CRM_CN_Contract_Total_Dummy__c;

            }
            /*
            NewContractV0Estimate.TradeExpenses+= ContractDetail.ASI_CRM_CN_Est_Total_Dummy__c;
            NewContactV0Contract.TradeExpenses+= ContractDetail.ASI_CRM_CN_Contract_Total_Dummy__c;
            */
        }

        if(SubBrandIdSet.size()>0){
            CR12FactorMap = ASI_CRM_CN_OffContractUtilitiesClass.GenerateCR12FactorMap(SubBrandIdSet, ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c);
        }


        //2nd Time Looping
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractDetail:ContractLines){
            ContractAmount+= contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c!=null? contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            Decimal CR12Factor=1;
            if(CR12FactorMap.containsKey(contractDetail.ASI_CRM_CN_Sub_Brand__c)){
                CR12Factor=CR12FactorMap.get(contractDetail.ASI_CRM_CN_Sub_Brand__c);
            }


            if(contractDetail.ASI_CRM_Type__c=='BRSF'){
                //BRSF_CTD_CR12+=CR12Factor*contractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c* contractDetail.ASI_CRM_CN_No_of_Months__c;//CR12Factor*contractDetail.ASI_CRM_CN_Est_Monthly_Qty__c* contractDetail.ASI_CRM_CN_No_of_Months__c;
                BRSF_CTD_CR12_contract+=  contractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?  CR12Factor*contractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c*contractDetail.ASI_CRM_CN_No_of_Months__c :0;
                BRSF_CTD_CR12_estimate+= contractDetail.ASI_CRM_CN_Est_Monthly_Qty__c!=null?  CR12Factor*contractDetail.ASI_CRM_CN_Est_Monthly_Qty__c*contractDetail.ASI_CRM_CN_No_of_Months__c :0;
            }
            /*
            NewContractV0Estimate.VariableExpense += contractDetail.ASI_CRM_CN_Est_Total_Dummy__c!=null? contractDetail.ASI_CRM_CN_Est_Total_Dummy__c:0;
            NewContactV0Contract.VariableExpense +=contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c!=null? contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            */
        }


        if(thisPR.ASI_CRM_CN_Last_Payment__c){ // If it is last Payment


            // get latest Budget CM for all Sub-Brands
            String currentFY = String.valueOf(ASI_CRM_DateUtilClass.getFiscalYearEndDate(Date.today()).year());
            String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
            String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';
            System.debug('currentFY'+currentFY);
            System.debug('currentFY2'+currentFY2);
            System.debug('currentFY3'+currentFY3);
            String ProductCode;
            Decimal cm;
            for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_YEAR__c,ASI_CRM_CM_GS_per_9L__c,ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c, ASI_CRM_CN_Month__c FROM ASI_CRM_CM_GS__c WHERE ASI_CRM_CN_Month__c = 6
            AND ASI_CRM_Region__c = : thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            AND (ASI_CRM_YEAR__c = :currentFY  OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3)
            AND (ASI_CRM_TYPE__c = 'Budget CM')  AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0  ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
            {
                ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
                if (lbcm.ASI_CRM_CM_GS_per_9L__c == null){
                    cm = 0;
                }else{
                    cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
                }
                if(!RegionSubBrandCM_Map.containsKey(ProductCode) && cm != Null && cm != 0){
                    RegionSubBrandCM_Map.put(ProductCode,cm);
                }

            }






            Map<Date, Decimal> V0_Period_map = new Map<Date, Decimal>();
            if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null){
                if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c != null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c != null)
                    V0_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c, thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c);
            }else{
                if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c != null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c != null)
                    V0_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c, thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c);
            }

            v0_ROI_newMap=new Map<String, ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data>();
            if (V0_Period_map.size() > 0){
                String strkey;
                for (Date v0temp : V0_Period_map.keySet()){
                    System.debug('now v0temp'+ v0temp);
                    if (SubBrandIdSet.size() > 0){
                        for (String idtemp : SubBrandIdSet){

                            strkey = String.valueOf(v0temp) + idtemp;
                            System.debug('now v0_ROI_newMap strkey'+ strkey);
                            if (!v0_ROI_newMap.containsKey(strkey)){
                                ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data newitem = new ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data();
                                newitem.period = V0_Period_map.get(v0temp);
                                System.debug('now V0_Period_map.get(v0temp)'+ V0_Period_map.get(v0temp));
                                newitem.SubBrandId = idtemp;
                                newitem.year = String.valueOf(v0temp.year());
                                newitem.TotalVolume = 0;
                                v0_ROI_newMap.put(strkey, newitem);
                            }
                        }
                    }
                }
            }

            //V0ContractId
            ASI_TH_CRM_Contract__c Contractv0 =new ASI_TH_CRM_Contract__c();
            System.debug('V0ContractId: ' + V0ContractId);
            Date strEnd;
            if (V0ContractId != null){
                Contractv0 = [SELECT Id, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c  FROM ASI_TH_CRM_Contract__c WHERE Id = :V0ContractId LIMIT 1];
            }
            if (Contractv0.ASI_CRM_CN_PO_Start_Date__c !=null ){
                strStart = Contractv0.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
            }else{
                strStart = thisPR.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
            }

            if (Contractv0.ASI_CRM_CN_PO_End_Date__c !=null ){
                strEnd = ASI_CRM_DateUtilClass.getEndOfMonth(Contractv0.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
            }else{
                strEnd = ASI_CRM_DateUtilClass.getEndOfMonth(thisPR.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
            }

            //last Payment
            // Date strStart2 = date.newInstance(strStart.addYears(-1).year(), 6, 30);
            //Date strEnd2 = date.newInstance(strEnd.addYears(1).year(), 6, 30);

            Date strStart2 = Date.newInstance(strStart.addYears(-3).year(), 6, 30);
            Date strEnd2 = Date.newInstance(strEnd.year(), 6, 30);
            strStart=ASI_CRM_DateUtilClass.getEndOfMonth(strStart);


            Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();
            List<ASI_CRM_CM_GS__c> BudgetCM_List_v0 = new List<ASI_CRM_CM_GS__c>();

            System.debug('CM GS strStart:'+strStart);
            System.debug('strEnd:'+strEnd);
            System.debug('strStart2:'+strStart2);
            System.debug(' strEnd2:'+strEnd2);


            try{
                BudgetCM_List_v0 = [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,ASI_CRM_CN_Month_End_Date__c, ASI_CRM_TYPE__c
                FROM ASI_CRM_CM_GS__c
                WHERE ASI_CRM_PRODUCTCODE__c IN :SubBrandIdSet AND ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                AND ((ASI_CRM_CN_Month_End_Date__c >= :strStart AND ASI_CRM_CN_Month_End_Date__c <= :strEnd)
                OR (ASI_CRM_CN_Month_End_Date__c >= : strStart2  AND ASI_CRM_CN_Month_End_Date__c <= : strEnd2 AND ASI_CRM_CN_Month__c = 6 ) )
                AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
                AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != Null
                ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC];
            }catch(Exception e){
                BudgetCM_List_v0 = new List<ASI_CRM_CM_GS__c>();
            }


            if (BudgetCM_List_v0.size() > 0){
                String strkey;
                String subbrand_id;
                Decimal BrsfVol;
                Decimal BrsfTargetVol;
                Decimal ActualCMperBtl;

                for (ASI_CRM_CM_GS__c ACM_v0_temp : BudgetCM_List_v0){
                    subbrand_id = ACM_v0_temp.ASI_CRM_PRODUCTCODE__c;
                    strkey = String.valueOf(ACM_v0_temp.ASI_CRM_CN_Month_End_Date__c) + subbrand_id;

                    ActualCMperBtl = null;

                    if(ACM_v0_temp.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(ACM_v0_temp.ASI_CRM_PRODUCTCODE__c + ACM_v0_temp.ASI_CRM_TYPE__c) && ACM_v0_temp.ASI_CRM_CM_GS_per_9L__c != null && ACM_v0_temp.ASI_CRM_CM_GS_per_9L__c != 0){
                        cmgsMap.put(ACM_v0_temp.ASI_CRM_PRODUCTCODE__c + ACM_v0_temp.ASI_CRM_TYPE__c, ACM_v0_temp);
                    }

                    if (ACM_v0_temp.ASI_CRM_CM_GS_per_9L__c != null)
                        ActualCMperBtl = ACM_v0_temp.ASI_CRM_CM_GS_per_9L__c;

                    //Estimate volume
                    BrsfVol = 0;
                    if (Subbrand_ROI_map_v0.containsKey(subbrand_id)){
                        BrsfVol = Subbrand_ROI_map_v0.get(subbrand_id).actual_vol;
                    }
                    //Contract volume
                    BrsfTargetVol = 0;
                    if (Subbrand_ROI_map_v0.containsKey(subbrand_id)){
                        BrsfTargetVol = Subbrand_ROI_map_v0.get(subbrand_id).target_vol;
                    }

                    //Budget CM
                    if (ACM_v0_temp.ASI_CRM_TYPE__c == 'Budget CM'){
                        if (v0_ROI_newMap.containsKey(strkey)){

                            if ((v0_ROI_newMap.get(strkey).actualCM == null || v0_ROI_newMap.get(strkey).actualCM == 0 )&& ActualCMperBtl != Null && ActualCMperBtl != 0)
                                v0_ROI_newMap.get(strkey).actualCM = ActualCMperBtl;
                            if (v0_ROI_newMap.get(strkey).actual_vol == null || v0_ROI_newMap.get(strkey).actual_vol == 0)
                                v0_ROI_newMap.get(strkey).actual_vol = BrsfVol;
                            if (v0_ROI_newMap.get(strkey).target_vol == null || v0_ROI_newMap.get(strkey).target_vol == 0)
                                v0_ROI_newMap.get(strkey).target_vol = BrsfTargetVol;
                        }
                    }
                    //Budget GS
                    if (ACM_v0_temp.ASI_CRM_TYPE__c == 'Budget GS'){
                        if (v0_ROI_newMap.containsKey(strkey)){
                            if((v0_ROI_newMap.get(strkey).actualGS == null || v0_ROI_newMap.get(strkey).actualGS == 0) && ActualCMperBtl != Null && ActualCMperBtl != 0)
                                v0_ROI_newMap.get(strkey).actualGS = ActualCMperBtl;
                            if (v0_ROI_newMap.get(strkey).target_vol == null || v0_ROI_newMap.get(strkey).target_vol == 0)
                                v0_ROI_newMap.get(strkey).target_vol = BrsfTargetVol;
                            if (v0_ROI_newMap.get(strkey).actual_vol == null || v0_ROI_newMap.get(strkey).actual_vol == 0)
                                v0_ROI_newMap.get(strkey).actual_vol = BrsfVol;
                        }
                    }

                    if (v0_ROI_newMap.containsKey(strkey)){
                        if (v0_ROI_newMap.get(strkey).latestBudgetCM == null || v0_ROI_newMap.get(strkey).latestBudgetCM == 0){
                            if(RegionSubBrandCM_Map.containsKey(ACM_v0_temp.ASI_CRM_PRODUCTCODE__c)){
                                v0_ROI_newMap.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(ACM_v0_temp.ASI_CRM_PRODUCTCODE__c);
                            }
                        }

                    }


                }

                for(String key : v0_ROI_newMap.keySet()){
                    if(v0_ROI_newMap.get(key).actualCM == Null || v0_ROI_newMap.get(key).actualCM == 0 || v0_ROI_newMap.get(key).actualGS == Null || v0_ROI_newMap.get(key).actualGS == 0 || v0_ROI_newMap.get(key).latestBudgetCM == Null || v0_ROI_newMap.get(key).latestBudgetCM == 0){
                        if((v0_ROI_newMap.get(key).actualCM == Null || v0_ROI_newMap.get(key).actualCM == 0) && cmgsMap.containsKey(v0_ROI_newMap.get(key).SubBrandId + 'Budget CM')){
                            ASI_CRM_CM_GS__c cmgs = cmgsMap.get(v0_ROI_newMap.get(key).SubBrandId + 'Budget CM');

                            v0_ROI_newMap.get(key).actualCM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                        }

                        if((v0_ROI_newMap.get(key).actualGS == Null || v0_ROI_newMap.get(key).actualGS == 0) && cmgsMap.containsKey(v0_ROI_newMap.get(key).SubBrandId + 'Budget GS')){
                            ASI_CRM_CM_GS__c cmgs = cmgsMap.get(v0_ROI_newMap.get(key).SubBrandId + 'Budget GS');

                            v0_ROI_newMap.get(key).actualGS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                        }

                        if(v0_ROI_newMap.get(key).latestBudgetCM == Null || v0_ROI_newMap.get(key).latestBudgetCM == 0){
                            if( RegionSubBrandCM_Map.containsKey(v0_ROI_newMap.get(key).SubBrandId))
                                v0_ROI_newMap.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(v0_ROI_newMap.get(key).SubBrandId);
                        }
                    }

                    if(v0_ROI_newMap.get(key).actual_vol == 0 && Subbrand_ROI_map_v0.containsKey(v0_ROI_newMap.get(key).SubBrandId))
                        v0_ROI_newMap.get(key).actual_vol = Subbrand_ROI_map_v0.get(v0_ROI_newMap.get(key).SubBrandId).actual_vol;
                    if(v0_ROI_newMap.get(key).target_vol == 0 && Subbrand_ROI_map_v0.containsKey(v0_ROI_newMap.get(key).SubBrandId))
                        v0_ROI_newMap.get(key).target_vol = Subbrand_ROI_map_v0.get(v0_ROI_newMap.get(key).SubBrandId).target_vol;
                }
            }

            if (v0_ROI_newMap.size() > 0){
                Decimal TotalSubBrandCM_estimate = 0;
                Decimal TotalSubBrandGS_estimate = 0;
                Decimal TotalSubBrandCM_contract = 0;
                Decimal TotalSubBrandGS_contract = 0;
                Decimal TotalSubBrand_LBCM_contract = 0;
                Decimal TotalSubBrand_LBCM_estimate = 0;
                for (ASI_CRM_CN_OffContractUtilitiesClass.subbrand_data sb_v0 : v0_ROI_newMap.values()){
                    //estimate volume * budget cm
                    if (sb_v0.actual_vol != null && sb_v0.period != null && sb_v0.actualCM != null){
                        System.debug(sb_v0.SubBrandId+'TotalSubBrandCM_estimate= '+ sb_v0.actual_vol +'*'+ sb_v0.actualCM +'*'+ sb_v0.period);
                        TotalSubBrandCM_estimate += sb_v0.actual_vol * sb_v0.actualCM * sb_v0.period;
                    }
                    //estimate volume * budget gs
                    if (sb_v0.actual_vol != null && sb_v0.period != null && sb_v0.actualGS != null){
                        TotalSubBrandGS_estimate += sb_v0.actual_vol * sb_v0.actualGS * sb_v0.period;
                    }
                    //contract volume * budget cm
                    if (sb_v0.target_vol != null && sb_v0.period != null && sb_v0.actualCM != null){
                        TotalSubBrandCM_contract += sb_v0.target_vol * sb_v0.actualCM * sb_v0.period;
                    }
                    //contract volume * budget gs
                    if (sb_v0.target_vol != null && sb_v0.period != null && sb_v0.actualGS != null){

                        TotalSubBrandGS_contract += sb_v0.target_vol * sb_v0.actualGS * sb_v0.period;
                    }

                    // contract volume * latest budget cm
                    if (sb_v0.target_vol != null && sb_v0.period != null && sb_v0.latestBudgetCM != null){
                        TotalSubBrand_LBCM_contract += sb_v0.target_vol * sb_v0.latestBudgetCM * sb_v0.period;
                    }
                    //estimate volume * budget cm
                    if (sb_v0.actual_vol != null && sb_v0.period != null && sb_v0.latestBudgetCM != null){
                        TotalSubBrand_LBCM_estimate += sb_v0.actual_vol * sb_v0.latestBudgetCM * sb_v0.period;
                    }


                }
                NewContractV0Estimate.GrossSalesTotal = TotalSubBrandGS_estimate;
                NewContactV0Contract.GrossSalesTotal = TotalSubBrandGS_contract;
                NewContractV0Estimate.IntakeSTD = v0Estimate_totalBtl;
                NewContactV0Contract.IntakeSTD = v0Contract_totalBtl;

                if(NewContactV0Contract.TradeExpenses!=null && BRSF_CTD_CR12_contract !=0 && BRSF_CTD_CR12_contract!=null ){
                    NewContactV0Contract.InvestmentCR12 = NewContactV0Contract.TradeExpenses/BRSF_CTD_CR12_contract;
                }
                if(NewContractV0Estimate.TradeExpenses!=null && BRSF_CTD_CR12_estimate !=0 && BRSF_CTD_CR12_estimate !=null ){
                    NewContractV0Estimate.InvestmentCR12 = NewContractV0Estimate.TradeExpenses/BRSF_CTD_CR12_estimate;
                }

                //v0.0 estimate Margin AP
                if (NewContractV0Estimate.TradeExpenses != null && TotalSubBrandCM_estimate != null)
                    NewContractV0Estimate.MarginAfterAnP = TotalSubBrandCM_estimate - NewContractV0Estimate.TradeExpenses;

                //v0.0 contract Margin AP
                if ( NewContactV0Contract.TradeExpenses!= null && TotalSubBrandCM_contract != null)
                    NewContactV0Contract.MarginAfterAnP= TotalSubBrandCM_contract -  NewContactV0Contract.TradeExpenses;

                //v0.0 estimate ROI
                if (NewContractV0Estimate.TradeExpenses != 0 && NewContractV0Estimate.TradeExpenses != null && TotalSubBrandCM_estimate != null && TotalSubBrandCM_estimate != 0){
                    //vALLROI.v0 = TotalSubBrandCM_estimate / NewContractV0Estimate.TradeExpenses; //NewContractV0Estimate.TradeExpenses----->v0_EstCost
                    NewContractV0Estimate.ROIIntake = TotalSubBrandCM_estimate / NewContractV0Estimate.TradeExpenses; //v0_EstCost
                }

                //v0.0 contract ROI
                if ( NewContactV0Contract.TradeExpenses != 0 &&  NewContactV0Contract.TradeExpenses != null && TotalSubBrandCM_contract != null && TotalSubBrandCM_contract != 0){
                    NewContactV0Contract.ROIIntake = TotalSubBrandCM_contract /  NewContactV0Contract.TradeExpenses;
                }



                // v0.0 Pro-Forma ROI
                if ( NewContactV0Contract.TradeExpenses!= 0 &&  NewContactV0Contract.TradeExpenses != null && TotalSubBrand_LBCM_contract != null && TotalSubBrand_LBCM_contract != 0){
                    NewContactV0Contract.ROIProForma = TotalSubBrand_LBCM_contract /  NewContactV0Contract.TradeExpenses;
                }
                //v0.0 Pro-Forma estimate ROI
                if (NewContractV0Estimate.TradeExpenses != 0 && NewContractV0Estimate.TradeExpenses != null && TotalSubBrand_LBCM_estimate != null && TotalSubBrand_LBCM_estimate != 0){
                    NewContractV0Estimate.ROIProForma= TotalSubBrand_LBCM_estimate / NewContractV0Estimate.TradeExpenses;  //NewContractV0Estimate.TradeExpenses----->v0_EstCost
                }

            }


        }

        return ContractAmount;
    }

    public void LoopingPaymentRequestLine(){
        Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>();
        for(ASI_CRM_Module__c Module: [select Id,
                ASI_CRM_Actual_Payment__c,
                ASI_CRM_Adjustment__c,
                ASI_CRM_Application_Payment_Amount__c,
                ASI_CRM_End_Date__c,
                ASI_CRM_Historical_Paid_Amount__c,
                ASI_CRM_Line_Type__c,
                ASI_CRM_Methodology__c,
                ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                ASI_CRM_Methodology__r.Name,
                ASI_CRM_Other_Comments__c,
                ASI_CRM_Overpayment_Reason__c,
                ASI_CRM_PSF_Overpayment_Reason__c,
                ASI_CRM_VEC_Overpayment_Reason__c,
                ASI_CRM_Parent_Module__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Payment_Reference__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,
                ASI_CRM_Payment_Reference__c,
                ASI_CRM_Reason_NCD_Volume_Base__c,
                ASI_CRM_Reason_Not_NCD_Methodology__c,
                ASI_CRM_Remark__c,
                ASI_CRM_Unit__c,
                ASI_CRM_Volume_Base__c
        from ASI_CRM_Module__c
        where ASI_CRM_Payment_Request__c =:thisPR.Id
        AND (ASI_CRM_Line_Type__c='PSF'
        OR ASI_CRM_Line_Type__c='Display')])
        {
            if(Module.ASI_CRM_Line_Type__c=='BRSF'){
                if(Module.ASI_CRM_End_Date__c!=null){
                    DisplayBRSFPart=true;
                }
                interimData TempData= new interimData(Module);
                BRSFItemMap=TempData;
            }
            if(Module.ASI_CRM_Line_Type__c=='PSF'){
                interimData TempData= new interimData(Module);
                if(Module.ASI_CRM_End_Date__c!=null){
                    PSFItemMap.put(Module.Id,TempData);
                }
            }
            //Also show Display (ASI_CRM_Methodology__r.Name != 'Others')
            if (Module.ASI_CRM_Line_Type__c == 'Display' && Module.ASI_CRM_Methodology__r.Name != 'Others'){
                interimData TempData= new interimData(Module);
                if(Module.ASI_CRM_End_Date__c!=null){
                    DisplayItemMap.put(Module.Id,TempData);
                }

            }
            ModuleMap.put(Module.Id,Module);
        }


        for(ASI_TH_CRM_PaymentRequestLineItem__c payline:[SELECT Id, ASI_CRM_Suggested_Value__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_TH_CRM_Payment_Request__c,ASI_CRM_Volume_Base__c ,
                ASI_CRM_Product_Category__c,ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_CTD_Actual_Vol__c , ASI_CRM_CN_Standard__c ,ASI_CRM_CTD_Cap_Collection_Vol__c ,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_CN_Payable_Vol__c  , ASI_CRM_Key_Sub_Brand__c, ASI_CRM_CN_Completion_Rate__c,
                ASI_CRM_V0_0_Full_Contract_Target__c, ASI_CRM_CN_Total_Payable__c , ASI_CRM_CN_Actual_Vol__c ,
                ASI_CRM_CN_Bottle_Collected__c, ASI_CRM_CN_Collection_Rate__c ,ASI_CRM_CN_Incentive_BT__c , ASI_CRM_CN_Allow_Changing_Incentive__c ,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Module__c ,ASI_CRM_CN_Sub_Brand__c,RecordType.DeveloperName,
                ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_Comment__c, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Remaining_Amount__c, RecordTypeId , ASI_CRM_CNY_Est__c,
                ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_AC_Code__c
        FROM ASI_TH_CRM_PaymentRequestLineItem__c
        WHERE ASI_TH_CRM_Payment_Request__c =:thisPR.Id ])
        {
            if(payline.ASI_CRM_Module__c !=null){
                if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_BRSF'){
                    BRSFItemMap.TotalIntake+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                    BRSFItemMap.DetailLineMap.put(payline.ASI_CRM_CN_Sub_Brand__c,payline);

                    //ASI_CRM_V0_0_Full_Contract_Target__c
                }else if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){
                    if(PSFItemMap.containsKey(payline.ASI_CRM_Module__c)){
                        PSFItemMap.get(payline.ASI_CRM_Module__c).DetailLineMap.put(payline.Id,payline);
                    }
                } else if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Display'){
                    if(DisplayItemMap.containsKey(payline.ASI_CRM_Module__c)){
                        DisplayItemMap.get(payline.ASI_CRM_Module__c).DetailLineMap.put(payline.Id,payline);
                    }
                }
            }
        }


        if(PSFItemMap.size() > 0 ){
            DisplayPSFPart=true;
        }
        if(DisplayItemMap.size() > 0){
            DisplayDisplayPart = true;
        }


        if(BRSFItemMap.TotalIntake!=null && BRSFItemMap.TotalIntake!=0 && BRSFItemMap.TotalBC!=null ){
            BRSFItemMap.BCRate = (BRSFItemMap.TotalBC / BRSFItemMap.TotalIntake)*100;
        }
        if(BRSFItemMap.Module.ASI_CRM_End_Date__c !=null){
            BRSFmonthsBetween =  ContractSelected.ASI_CRM_CN_PO_Start_Date__c.monthsBetween(BRSFItemMap.Module.ASI_CRM_End_Date__c);
            //BRSFItemMap.Module.ASI_CRM_End_Date__c.monthsBetween(ContractSelected.ASI_CRM_CN_PO_Start_Date__c);
            BRSFmonthsBetween= BRSFmonthsBetween+1;
        }

    }

    //Looping Fix cost
    public Decimal CalculateV0ContractCostAmount(){
        Decimal FixCostAmount=0;
        String V0ContractId = getV0ContractId();
        List<ASI_CRM_Contract_Cost__c>  v0_EstCostList = new List<ASI_CRM_Contract_Cost__c>();
        try{
            v0_EstCostList = [SELECT Id,
                    Name,
                    ASI_CRM_CN_Estimate_Amount__c,
                    ASI_CRM_CN_Cost_Type__c,
                    ASI_CRM_CN_Contract_Amount__c
            FROM ASI_CRM_Contract_Cost__c
            WHERE ASI_CRM_CN_Contract__c = :V0ContractId
            AND ASI_CRM_CN_Cost_Type__c='Fixed'];
        }catch(Exception e){
            System.debug('Try v0_EstCostList failed: ' + e);
        }


        if (v0_EstCostList.size() > 0){
            for (ASI_CRM_Contract_Cost__c V0ContractCost : v0_EstCostList){
                FixCostAmount += ASI_CRM_CN_PromotionPaymentUtilClass.denullify(V0ContractCost.ASI_CRM_CN_Contract_Amount__c);
                NewContractV0Estimate.OtherExpensesTotal += ASI_CRM_CN_PromotionPaymentUtilClass.denullify(V0ContractCost.ASI_CRM_CN_Estimate_Amount__c);
                NewContactV0Contract.OtherExpensesTotal += ASI_CRM_CN_PromotionPaymentUtilClass.denullify(V0ContractCost.ASI_CRM_CN_Contract_Amount__c);
            }
        }
        return FixCostAmount;
    }



    //generate V0.0 Contract Id
    public String getV0ContractId(){
        String V0ContractId='';
        if(thisPR.ASI_TH_CRM_Contract__c!=null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        }else if(thisPR.ASI_TH_CRM_Contract__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__c;
        }
        return V0ContractId;
    }

    private Set<Id> generatingOutletId(String developerName){
        List<ASI_CRM_CN_Covered_Outlet__c>  CoveredOutlet_List = new List<ASI_CRM_CN_Covered_Outlet__c>();
        //String developerName = this.ContractSelected.ASI_CRM_CN_Data_Source__c == 'WS Intake' ? 'ASI_CRM_CN_WS' :'ASI_CRM_Outlet_CN';
        //String developerName = this.ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' ? 'ASI_CRM_CN_WS' :'ASI_CRM_Outlet_CN';
        //String developerName = this.ContractSelected.ASI_CRM_CN_Data_Source__c == 'WS Intake' ? 'ASI_CRM_CN_WS' :'ASI_CRM_Outlet_CN';
        try{
            CoveredOutlet_List = [SELECT ASI_CRM_CN_Outlet__c,
                    ASI_CRM_CN_Outlet__r.Name,
                    ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c
            FROM ASI_CRM_CN_Covered_Outlet__c
            WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id
            AND ASI_CRM_CN_Outlet__r.RecordType.DeveloperName = :developerName
            ORDER BY ASI_CRM_CN_Outlet__r.Name ASC];
        }catch(Exception e){
            CoveredOutlet_List = new List<ASI_CRM_CN_Covered_Outlet__c>();
        }
        Set<Id> OutletIdSet = new Set<Id>();

        for (ASI_CRM_CN_Covered_Outlet__c co_temp : CoveredOutlet_List){
            OutletIdSet.add(co_temp.ASI_CRM_CN_Outlet__c);
        }

        return OutletIdSet;

    }

    //Deprecated, use Map<String,Decimal> ASI_CRM_CN_OffContractUtilitiesClass.GenerateCR12FactorMap(Set<Id> SBIdSet, String CommercialTeam, String RegionName) instead
    //Generate CR12 Factor Mapping table : Sub-Brand Id, CR12 Factor
    // private Map<String,Decimal> GenerateCR12FactorMap(Set<String> SBIdSet){
    //     Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
    //     for(ASI_MFM_Sub_brand__c SubBrand: [SELECT Id,
    //             ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
    //     (SELECT Id,
    //             ASI_CRM_CR12_Conversion_Factor__c,
    //             ASI_CRM_Commercial_Team__c,
    //             ASI_CRM_CN_Region__c
    //     FROM ASI_CRM_CR12_Factors__r)
    //     FROM ASI_MFM_Sub_brand__c
    //     WHERE Id in :SBIdSet ]){
    //         Decimal CR12Factor=1;
    //         Boolean FoundFactor = false;
    //         for(ASI_CRM_Sub_Brand_Line__c SubBrandLine: SubBrand.ASI_CRM_CR12_Factors__r){
    //             if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c !=null &&
    //                     ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c !=null &&
    //                     SubBrandLine.ASI_CRM_CR12_Conversion_Factor__c !=null &&
    //                     SubBrandLine.ASI_CRM_Commercial_Team__c == ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c &&
    //                     SubBrandLine.ASI_CRM_CN_Region__c == ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c ){

    //                 CR12Factor=SubBrandLine.ASI_CRM_CR12_Conversion_Factor__c;
    //                 FoundFactor=true;
    //             }
    //         }
    //         if(!FoundFactor && SubBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c!=NULL ){
    //             CR12Factor=SubBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
    //             FoundFactor=true;
    //         }
    //         if(FoundFactor){
    //             CR12FactorMap.put(SubBrand.Id, CR12Factor);
    //         }
    //     }
    //     return CR12FactorMap;
    // }

    //*******************************************************************************************************
    //* @description custom class for Line Detail
    // ********************************************************************************************************
    public Class interimData{
        public ASI_CRM_Module__c Module {set;get;}
        public String MethodologyValue  {set;get;}
        public Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> DetailLineMap{set;get;}
        public Decimal TotalIntake {set;get;}{TotalIntake=0;}
        public Decimal TotalBC {set;get;}{TotalBC=0;}
        public Decimal BCRate {set;get;}{BCRate=0;}

        public interimData(){
            Module=new ASI_CRM_Module__c();
            MethodologyValue='';
            DetailLineMap= new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        }

        public interimData( ASI_CRM_Module__c ModuleInput){
            Module=ModuleInput;
            MethodologyValue=ModuleInput.ASI_CRM_Methodology__r.Name;
            DetailLineMap= new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        }

        public interimData( ASI_CRM_Module__c ModuleInput,Boolean ClickRefresh){
            Module=ModuleInput;
            MethodologyValue=ModuleInput.ASI_CRM_Methodology__r.Name;
            DetailLineMap= new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();

        }
    }


    public Class VolumeObject {
        //V0.0 Full Contract Target/合同销量目标

        public Decimal FullContractTarget { set; get; }{
            FullContractTarget = 0;
        }
        //Actual Performance
        public Decimal CTDActualVol { set; get; }{
            CTDActualVol = 0;
        }
        public String SubBrandGradeName { set; get; }{
            SubBrandGradeName = '';
        }
        public String SubBrandGradeCNName { set; get; }{
            SubBrandGradeCNName = '';
        }
        public VolumeObject() {

        }
    }

    public class VolValueInterimData{
        public ASI_MFM_Sub_brand__c subBrand {set;get;}
        public  ASI_CRM_AccountsAdditionalField__c outlet {set;get;}
        public Decimal volume9L {set;get;} {volume9L = 0;}
        public Decimal volume9LV0 {set;get;} {volume9LV0 = 0;}

        public VolValueInterimData(){}

        public void addVolume(ASI_CRM_Subbrand_Volume__c volume, String dataSource){
            if(dataSource == 'POS'){
                volume9L += volume.ASI_CRM_POS_9L__c != null ? volume.ASI_CRM_POS_9L__c : 0;
            }/*else if(dataSource == 'WS Intake'){
                volume9L += volume.ASI_CRM_T1_Depletion__c != null ? volume.ASI_CRM_T1_Depletion__c : 0;
            }*/else {
                volume9L += volume.ASI_CRM_Actual_Vol_9L__c != null ? volume.ASI_CRM_Actual_Vol_9L__c : 0;
            }
        }

        public void exclusionVolume(ASI_CRM_Exclude_Item_Group_Volume__c volume, String dataSource){
            if(dataSource == 'POS'){
                volume9L -= volume.ASI_CRM_POS_9L__c != null ? volume.ASI_CRM_POS_9L__c : 0;
            }else {
                if(dataSource == 'WS Intake')
                {
                    volume9L = ExcludeJudge(volume9L ,volume.ASI_CRM_Actual_Vol_9L__c);
                }
                else 
                {
                    volume9L = ExcludeJudge(volume9L ,volume.ASI_CRM_Depletion__c);
                }


                //volume9L -= volume.ASI_CRM_Actual_Vol_9L__c != null ? volume.ASI_CRM_Depletion__c : 0;
                //purchaseValue += (volume.ASI_CRM_T1_Depletion_GS__c != null ? volume.ASI_CRM_T1_Depletion_GS__c : 0) + (volume.ASI_CRM_T2_Depletion_GS__c != null ? volume.ASI_CRM_T2_Depletion_GS__c : 0) + (volume.ASI_CRM_PR_DIRECT_GS__c != null ? volume.ASI_CRM_PR_DIRECT_GS__c : 0);
                
            }
        }
    }

    public static String SubBrandFieldList(){
        List<String> fieldList = new List<String>{
                'Id',
                'ASI_CRM_Account__c',
                'ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c',
                'ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c',
                'ASI_CRM_Account__r.Name',
                'ASI_CRM_Actual_Vol_CR12__c',
                'ASI_CRM_Actual_Vol_STD__c',
                'ASI_CRM_Intake_GS__c',
                'ASI_CRM_Offtake_GS__c',
                'ASI_CRM_POS_GS__c',
                'ASI_CRM_Empty_Bottle_CR12__c',
                'ASI_CRM_Empty_Bottle_Std_Billing__c',
                'ASI_CRM_Month__c',
                'ASI_CRM_Offtake_CR12__c',
                'ASI_CRM_Offtake_Std_Billing__c',
                'ASI_CRM_POS_CR12__c',
                'ASI_CRM_POS_Std_Billing__c',
                'ASI_CRM_PR_Direct_CR12__c',
                'ASI_CRM_PR_Direct_STD_Billing__c',
                'ASI_CRM_Penalty_Coefficient_Applied__c',
                'ASI_CRM_Subbrand__c',
                'ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c',
                'ASI_CRM_Subbrand__r.ASI_CRM_CN_Convfactor_Ltocr12_C__c',
                'ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c',
                'ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name',
                'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c',
                'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c',
                'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name',
                'ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__c',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name',
                'ASI_CRM_Subbrand__r.Name',
                'ASI_CRM_T1_Depletion_CR12__c',
                'ASI_CRM_T1_Depletion_STD_Billing__c',
                'ASI_CRM_T2_Depletion_CR12__c',
                'ASI_CRM_T1_Depletion_GS__c',
                'ASI_CRM_T1_Depletion__c',
                'ASI_CRM_T2_Depletion_STD_Billing__c',
                'ASI_CRM_Offtake__c',
                'ASI_CRM_Year__c',
                'ASI_CRM_Actual_Vol_9L__c',
                'ASI_CRM_T2_Depletion_GS__c',
                'ASI_CRM_POS_9L__c'


        };
        return String.join(fieldList,',');
    }

    public static String exclusionFieldList(){
        List<String> fieldList = new List<String>{
            'Id',
            'ASI_CRM_POS_GS__c',
            'ASI_CRM_POS_9L__c',
            'ASI_CRM_Depletion__c',
            'ASI_CRM_Actual_Vol_9L__c',
            'ASI_CRM_CN_Intake_GS_T1_price__c',
            'ASI_CRM_Outlet__c',
            'ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c',
            'ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c' ,
            'ASI_CRM_Account__c',
            'ASI_CRM_Sub_Brand__c',
            'ASI_CRM_Depletion_GS_T1_Price__c',
            'ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c',
            'ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c'

        };
        return String.join(fieldList,',');
    }

    private final static List<String> RECORD_TYPE_LIST_AGGREGATION = new List<String> {
            'CN_WS_Outlet_Brand_Monthly_Volume',
            'CN_WS_Outlet_Region_Monthly_Volume',
            'CN_WS_Outlet_Category_Monthly_Volume',
            'CN_WS_Outlet_CTD_Sub_Brand_Data',
            'CN_WS_Outlet_Monthly_Sub_Brand_Data'
    };

    public class WholeSalerInterimData {
        public ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLineOutletWS { set; get; }
        public Decimal incentive {get;set;}


        public WholeSalerInterimData() {
            paymentRequestLineOutletWS = new ASI_TH_CRM_PaymentRequestLineItem__c();
            incentive = 0;
        }
    }

    /*
        Author：Bowen
        Date:2019-11-01
        Function:
            功能类，当被减数小于减数，则返回0；反之按正常的计算逻辑走
     */
    public static Decimal ExcludeJudge(Decimal orginal ,Decimal exclude)
    {
        Decimal ExcludeResult = 0;
        if(orginal == null) orginal = 0;
        if(exclude == null) exclude = 0;

        if(orginal < exclude)
        {
            ExcludeResult = 0;
        }
        else
        {
            ExcludeResult = orginal - exclude;
        }
        return ExcludeResult;
    }

}