/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_PromotionPaymentUtilClass
 * Description: Apex class forA SI_CRM_CN_PromotionPaymentUtilClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-07-30       Keith Yip               Created
 ****************************************************************************************************************************/
public class ASI_CRM_CN_PromotionPaymentUtilClass {
    //TODO:Centralize the recordtype
    private final static List<String> RECORD_TYPE_LIST_AGGREGATION = new List<String> {
            'ASI_CRM_CN_WS_Outlet_Brand_Monthly_Volume',
            'ASI_CRM_CN_WS_Outlet_Region_Monthly_Volume',
            'ASI_CRM_CN_WS_Outlet_Category_Monthly_Volume',
            'ASI_CRM_CN_WS_Outlet_CTD_Sub_Brand_Data',
            'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data'
    };

    public class FinancialIndicator {
        //Payment amount for this time
        public Decimal FixedPaymentTotal {get; set;}
        public Decimal VariablePaymentTotal {get; set;}
        public Decimal SuggestedPayableAmount {get; set;}
        //Total payment amount for same contract
        public Decimal TotalPaymentAmount {get; set;}
        public Decimal TotalPaymentAmountExclOthers {get; set;}
        //Data for v0 Contract
        public Decimal v0Cost {get; set;}
        public Decimal v0CostExclOthers {get; set;}
        public Decimal v0ContractVolume {get; set;}
        public Decimal V0ContractValue {get; set;}
        //Data from Subbrand Volume
        public Decimal ActualVolume {get; set;}
        public Decimal ActualValue {get; set;}
        //Calculated Speed
        public Double PaymentSpeed {
            get{
                if (isNotNullAndZero(v0Cost))
                    return (TotalPaymentAmount / v0Cost) * 100;
                return 0;
            }
            private set;
        }
        public Double PaymentExclOthersSpeed {
            get{
                if (isNotNullAndZero(v0CostExclOthers))
                    return (TotalPaymentAmountExclOthers / v0CostExclOthers) * 100;
                return 0;
            }
            private set;
        }
        public Double VolumeSpeed {
            get{
                if (isNotNullAndZero(v0ContractVolume))
                    return (ActualVolume / v0ContractVolume) * 100;
                return 0;
            }
            private set;
        }
        public Double ValueSpeed {
            get{
                if (isNotNullAndZero(V0ContractValue))
                    return (ActualValue / V0ContractValue) * 100;
                return 0;
            }
            private set;
        }

        public FinancialIndicator(){
            FixedPaymentTotal = 0;
            VariablePaymentTotal = 0;
            SuggestedPayableAmount = 0;
            TotalPaymentAmount = 0;
            TotalPaymentAmountExclOthers = 0;
            v0Cost = 0;
            v0CostExclOthers = 0;
            v0ContractVolume = 0;
            V0ContractValue = 0;
            ActualVolume = 0;
            ActualValue = 0;

        }
    }

    public Class VolumeObject{
        //V0.0 Full Contract Target/合同销量目标

        public Decimal FullContractTarget {set;get;}{FullContractTarget=0;}
        //Actual Performance
        public Decimal CTDActualVol {set;get;}{CTDActualVol=0;}
        public String SubBrandGradeName {set;get;}{SubBrandGradeName='';}
        public VolumeObject(){

        }
    }

    /**
     * Get the sum of actual payment amount of previous payments group by expense type
     *
     * @param paymentId current payment Id
     * @param contractId contract id of current payment
     *
     * @return
     */
    public static List<AggregateResult> calculateOtherCostHistoricalPaidAmount(Id paymentId, Id contractId){
        return [
                SELECT ASI_CRM_CN_Expense_Type__c, SUM(ASI_CRM_Payment_Amount__c) actualPaymentAmountSum
                FROM ASI_TH_CRM_PaymentRequestLineItem__c
                WHERE ASI_TH_CRM_Payment_Request__c != :paymentId
                AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :contractId
                GROUP BY ASI_CRM_CN_Expense_Type__c
        ];
    }

    public static void  ReconstructLastPaymentFIData(ASI_TH_CRM_PaymentRequest__c thisPR) {
        Date strStart;
        Date CutOffDay=ASI_CRM_DateUtilClass.getCutOffDate();
        Map<String,VolumeObject> VolumeMap= new Map<String,VolumeObject>();
        Boolean isPOS = false;

        ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator  ActualPerformance= new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator();
        Map<String, String> sbGroup_map = new Map<String, String>();
        sbGroup_map.put('1. Standard + Premium / 标准档 + 高档', 'Standard + Premium / 标准档 + 高档');
        sbGroup_map.put('2. Super Premium / 超高档', 'Super Premium / 超高档');
        sbGroup_map.put('3. Ultra Premium / 特级高档', 'Ultra Premium / 特级高档');
        sbGroup_map.put('4. Prestige + Ultra Prestige / 奢华档 + 特级奢华档', 'Prestige + Ultra Prestige / 奢华档 + 特级奢华档');
        sbGroup_map.put('5. Not Specified / 未指定',  'Not Specified / 未指定');



        Map<String, String> SubbrandGroup = new Map<String, String>();
        SubbrandGroup.put('Premium', '1. Standard + Premium / 标准档 + 高档');
        SubbrandGroup.put('Standard', '1. Standard + Premium / 标准档 + 高档');
        SubbrandGroup.put('Prestige', '4. Prestige + Ultra Prestige / 奢华档 + 特级奢华档');
        SubbrandGroup.put('Ultra Prestige', '4. Prestige + Ultra Prestige / 奢华档 + 特级奢华档');
        SubbrandGroup.put('Super Premium', '2. Super Premium / 超高档');
        SubbrandGroup.put('Ultra Premium', '3. Ultra Premium / 特级高档');
        SubbrandGroup.put('Not Specified / 未指定','5. Not Specified / 未指定');

        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal>();


        for(String SBGName:sbGroup_map.keySet()){
            ActualPerformance.SubBrandGradeMap.put(SBGName,0.0);
        }

        //Query all payment request with vFinal contract
        List<ASI_TH_CRM_PaymentRequest__c> AllPaymentRequest = new List<ASI_TH_CRM_PaymentRequest__c>();
        AllPaymentRequest = getAllPaymentRequest(thisPR.ASI_TH_CRM_Contract__c, thisPR.Id);

        //Sum up previous payments amounts
        if (AllPaymentRequest.size() > 0){
            for (ASI_TH_CRM_PaymentRequest__c allPR_temp : AllPaymentRequest){
                for (ASI_CRM_Module__c module : allPR_temp.ASI_CRM_Modules__r){
                    if (allPR_temp.ASI_CRM_CN_Total_Payment__c != null){
                        if (module.ASI_CRM_Line_Type__c == 'BRSF' && module.ASI_CRM_CN_Contract_Volume_Base__c == 'POS'){
                            isPOS = true;
                        }
                        if(allPR_temp.ASI_CRM_CN_Promotion_Type__c=='TOT/MOT Contract'){
                            if (module.ASI_CRM_Line_Type__c == 'PSF'){
                                ActualPerformance.PSFExpensesTotal += denullify(module.ASI_CRM_Actual_Payment__c);
                            } else if (module.ASI_CRM_Line_Type__c == 'Display'){
                                ActualPerformance.DisplayExpensesTotal += denullify(module.ASI_CRM_Actual_Payment__c);
                            }
                        }
                    }
                }
            }
        }


        List<ASI_TH_CRM_PaymentRequestLineItem__c> PRLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        try{
            //query All Payment Variable & Fixed Cost
            PRLineItems = [SELECT Id, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Total_Payable__c,ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,
                    ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c, RecordTypeId,RecordType.DeveloperName,ASI_CRM_Adjustment__c,
                    ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Cost__c
            FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c and (ASI_TH_CRM_Payment_Request__c =:thisPR.Id OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR
            ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted'  OR
            ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid')];
        }catch(Exception e){
            PRLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c >();
        }

        for ( ASI_TH_CRM_PaymentRequestLineItem__c  li_temp : PRLineItems ){
            if(li_temp.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
                ActualPerformance.OtherExpensesTotal += li_temp.ASI_TH_CRM_Amount__c!=null? li_temp.ASI_TH_CRM_Amount__c:0;
            }
        }


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
                System.debug('Now put '+lbcm.ASI_CRM_YEAR__c+' ' +lbcm.ASI_CRM_PRODUCTCODE__r.Name+lbcm.Id+' into the RegionSubBrandCM_Map ');
                RegionSubBrandCM_Map.put(ProductCode,cm);
            }
        }

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

        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(thisPR.ASI_CRM_CN_OutletWS__c);
        }
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }


        Date TillEnd = ASI_CRM_DateUtilClass.getEndOfMonth(ASI_CRM_DateUtilClass.findMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN'));


        System.debug('Payment thisPR.ASI_CRM_CN_PO_Start_Date__c: '+thisPR.ASI_CRM_CN_PO_Start_Date__c);
        System.debug('Payment TillEnd: '+TillEnd);
        List<ASI_CRM_Subbrand_Volume__c> SubBrandVolumeList = new List<ASI_CRM_Subbrand_Volume__c> ();


        try{
            //Use Contract's Subbrand Field because it needs getting Actual Performance
            String subBrandVolumeQuery = 'SELECT ' + ASI_CRM_CN_PromotionContractUtilClass.SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
            subBrandVolumeQuery += 'WHERE ASI_CRM_Subbrand__c !=null ' +
                    'AND ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
                    'AND ASI_CRM_End_Date__c >= ' + String.valueOf(thisPR.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
                    'AND ASI_CRM_End_Date__c <= ' + String.valueOf(TillEnd) + ' ' +
                    'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = false ';
            if (AllOutlet.size() >= ASI_CRM_CN_PromotionContractUtilClass.outletThreshold()){
                subBrandVolumeQuery += 'AND ASI_CRM_CN_Contract__c = \'' + thisPR.ASI_TH_CRM_Contract__c + '\' ' +
                        'AND recordtypeId = \'' + Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')+'\' ';
            } else {
                subBrandVolumeQuery += 'AND ASI_CRM_Account__c IN: AllOutlet ' +
                        'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';
            }
            subBrandVolumeQuery += 'ORDER BY ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name ';
            if(Test.isRunningTest()) {subBrandVolumeQuery = 'SELECT ' + ASI_CRM_CN_PromotionContractUtilClass.SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';}
            SubBrandVolumeList = Database.query(subBrandVolumeQuery);

            /*
            SB_Vol_List = [SELECT Id,Name,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                           ASI_CRM_T1_Depletion_Std_Billing__c, ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_Std_Billing__c,
                           ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c,
                           ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_Std_Billing__c, ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c, ASI_CRM_Subbrand__c,
                           ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name,ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,ASI_CRM_PR_Direct__c,
                           ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                           ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,ASI_CRM_PR_Direct_STD__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,ASI_CRM_Offtake_Std_Billing__c
                           FROM ASI_CRM_Subbrand_Volume__c
                           WHERE ASI_CRM_End_Date__c >= :thisPR.ASI_CRM_CN_PO_Start_Date__c
                           AND ASI_CRM_End_Date__c <= :TillEnd
                           AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                           AND ASI_CRM_Account__c IN :AllOutlet
                           and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false
                           and ASI_CRM_Subbrand__c !=null];
            */

        }catch(Exception e){
            SubBrandVolumeList = new List<ASI_CRM_Subbrand_Volume__c >();
        }


        List<ASI_CRM_CM_GS__c> ActualCM_List = new List<ASI_CRM_CM_GS__c>();
        Map<Date, Decimal> V1_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(thisPR.ASI_CRM_CN_PO_Start_Date__c, thisPR.ASI_CRM_CN_PO_End_Date__c);
        System.debug('Now V1_Period_map: '+ V1_Period_map);
        Map<String, ASI_CRM_CN_PromotionContractUtilClass.subbrand_data> v1_ROI_newMap = new Map<String, ASI_CRM_CN_PromotionContractUtilClass.subbrand_data>();

        Set<Id> v1_sbid_set = new Set<Id>();
        //system.debug('SubBrandVolumeList:' + SubBrandVolumeList);
        //ActualPerformance
        if (SubBrandVolumeList.size() > 0){
            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume : SubBrandVolumeList ){
                //system.debug('v1_sbid_set : '+SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c);
                v1_sbid_set.add(SubBrandVolume.ASI_CRM_Subbrand__c);
                String sbGradeName ='';
                String BrandName = '';
                String categoryName = '';

                //Get Actual Performance
                Decimal ActualVolumes = 0;
                Decimal ActualSalesValue = 0;


                ActualVolumes += denullify(SubBrandVolume.ASI_CRM_T1_Depletion__c);
                ActualVolumes += denullify(SubBrandVolume.ASI_CRM_T2_Depletion__c);
                ActualVolumes += denullify(SubBrandVolume.ASI_CRM_PR_Direct__c);


                if (isPOS)
                    ActualSalesValue += denullify(SubBrandVolume.ASI_CRM_POS_GS__c);
                else
                        ActualSalesValue += denullify(SubBrandVolume.ASI_CRM_CN_Intake_GS_T1_price__c);

                ActualPerformance.Volumes += ActualVolumes;
                ActualPerformance.Value += ActualSalesValue;

                //Dissect in different Dimension
                String notSpecified = 'Not Specified / 未指定';
                //Brand
                if (SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c != null && SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name != null){
                    BrandName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name;
                }
                if (String.isBlank(BrandName)){
                    BrandName = notSpecified;
                }

                //Subbrand Grade
                if (SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null && SubbrandGroup.containsKey(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name)){
                    sbGradeName = SubbrandGroup.get(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
                }else{
                    sbGradeName = notSpecified;
                }

                //Category
                if (SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c != null &&
                        SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c != null){
                    categoryName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                } else {
                    categoryName = notSpecified;
                }


                //Fill data
                ActualPerformance.SubBrandGradeMap = ASI_CRM_CN_PromotionContractUtilClass.addToDecimalMap(ActualPerformance.SubBrandGradeMap, sbGradeName, ActualVolumes);
                ActualPerformance.BrandVolumeMap = ASI_CRM_CN_PromotionContractUtilClass.addToDecimalMap(ActualPerformance.BrandVolumeMap, BrandName, ActualVolumes);
                ActualPerformance.BrandValueMap = ASI_CRM_CN_PromotionContractUtilClass.addToDecimalMap(ActualPerformance.BrandValueMap, BrandName, ActualSalesValue);
                ActualPerformance.CategoryVolumeMap = ASI_CRM_CN_PromotionContractUtilClass.addToDecimalMap(ActualPerformance.CategoryVolumeMap, categoryName, ActualVolumes);
                ActualPerformance.CategoryValueMap = ASI_CRM_CN_PromotionContractUtilClass.addToDecimalMap(ActualPerformance.CategoryValueMap, categoryName, ActualSalesValue);

            }
        }

        if (V1_Period_map.size() > 0){
            String strkey;
            for (Date v1temp : V1_Period_map.keySet()){
                if (v1_sbid_set.size() > 0){
                    for (Id sbtemp : v1_sbid_set){
                        strkey = String.valueOf(v1temp) + sbtemp;
                        System.debug('V1 strkey : '+strkey);
                        ASI_CRM_CN_PromotionContractUtilClass.subbrand_data newitem = new ASI_CRM_CN_PromotionContractUtilClass.subbrand_data();
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

        //V0ContractId
        ASI_TH_CRM_Contract__c Contractv0 =new ASI_TH_CRM_Contract__c();

        Date strEnd;
        String V0ContractId='';
        if(thisPR.ASI_TH_CRM_Contract__c!=null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        }else if(thisPR.ASI_TH_CRM_Contract__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__c;
        }
        if (V0ContractId != null && V0ContractId != ''){
            Contractv0 = [SELECT ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c  FROM ASI_TH_CRM_Contract__c WHERE Id = :V0ContractId];
        }
        if (Contractv0.ASI_CRM_CN_PO_Start_Date__c !=null ){
            strStart = Contractv0.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
        }else{
            strStart = thisPR.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
        }


        strStart=ASI_CRM_DateUtilClass.getEndOfMonth(strStart);

        try{
            ActualCM_List = [SELECT ASI_CRM_CM_GS_per_9L__c, ASI_CRM_CN_Standard_Bottle_Factor__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_CN_Month__c,
                    ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_TYPE__c
            FROM ASI_CRM_CM_GS__c
            WHERE ASI_CRM_PRODUCTCODE__c IN :v1_sbid_set
            AND ASI_CRM_Region__c = :thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            AND ASI_CRM_CN_Month_End_Date__c >= :strStart
            AND ASI_CRM_CN_Month_End_Date__c <= :strV1End
            AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS')
            AND ASI_CRM_CM_GS_per_9L__c != Null AND ASI_CRM_CM_GS_per_9L__c != 0
            ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC];
        }catch(Exception e){
            ActualCM_List = new List<ASI_CRM_CM_GS__c>();
        }



        if (ActualCM_List.size() > 0){
            String strkey;
            String subbrand_id;
            String lastestkey;
            for (ASI_CRM_CM_GS__c ACM_temp : ActualCM_List){
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
        }

        //Looping Sub-brand Volume
        for (ASI_CRM_Subbrand_Volume__c  SB_Vol_temp : SubBrandVolumeList){
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c!=null?SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c:0;

            Decimal  MarginUseTotalVol_std = 0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_PR_Direct_STD__c!=null?SB_Vol_temp.ASI_CRM_PR_Direct_STD__c:0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c!=null?SB_Vol_temp.ASI_CRM_T1_Depletion_STD__c:0;
            MarginUseTotalVol_std += SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c!=null?SB_Vol_temp.ASI_CRM_T2_Depletion_STD__c:0;
            ActualIntakeTotal += MarginUseTotalVol_std;

            String Mapkeystr= ASI_CRM_CN_PromotionContractUtilClass.NameSortingASC(SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
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
                System.debug(strkey);
                if (v1_ROI_newMap.get(strkey).actual_vol != null)
                    v1_ROI_newMap.get(strkey).actual_vol += FC_actualvol_btl;
                else
                        v1_ROI_newMap.get(strkey).actual_vol = FC_actualvol_btl;
            }else{
                ASI_CRM_CN_PromotionContractUtilClass.subbrand_data newDC1 = new ASI_CRM_CN_PromotionContractUtilClass.subbrand_data();
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

        //VFinal ROI Actual Performance 1452
        if (v1_ROI_newMap.size() > 0){
            Decimal totalsb_cm_v1 = 0;
            Decimal totalsb_gs_v1 = 0;
            Integer tilldateperiod;
            Decimal totalsb_lbcm_v1 = 0;
            System.debug('v1_ROI_newMap.size() ' + v1_ROI_newMap.size());

            for (ASI_CRM_CN_PromotionContractUtilClass.subbrand_data sb_v1 : v1_ROI_newMap.values()){

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
                    totalsb_gs_v1 += sb_v1.actual_vol * actualGS;
                }
            }
            System.debug('totalsb_lbcm_v1 ' + totalsb_lbcm_v1);
            //vFinal Actual ROI
            if (ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null && totalsb_cm_v1 != null && totalsb_cm_v1 != 0){
                ActualPerformance.CMTotal=totalsb_cm_v1;
                ActualPerformance.ROIIntake= totalsb_cm_v1 / ActualPerformance.TradeExpenses;
            }

            if(Vol_CR12_1!=null && Vol_CR12_1 !=0 && ActualPerformance.TradeExpenses !=null && ActualPerformance.TradeExpenses!=0 ){
                ActualPerformance.InvestmentCR12 = ActualPerformance.TradeExpenses/Vol_CR12_1;
            }
            //vFinal Actual Margin AP
            if (ActualPerformance.TradeExpenses != null && totalsb_cm_v1 != null){
                ActualPerformance.MarginAfterAnP = totalsb_cm_v1 - ActualPerformance.TradeExpenses;
            }
            ActualPerformance.IntakeSTD = ActualIntakeTotal;

            //vFinal Actual Pro-Forma ROI
            if (ActualPerformance.TradeExpenses != 0 && ActualPerformance.TradeExpenses != null && totalsb_lbcm_v1 != null && totalsb_lbcm_v1 != 0){
                ActualPerformance.LatestBudgetCMTotal=totalsb_lbcm_v1;
                ActualPerformance.ROIProForma = totalsb_lbcm_v1 / ActualPerformance.TradeExpenses;
            }

        }


        //**Finish
        List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ReturnList = new List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>();
        ReturnList.add(ActualPerformance);
        ASI_CRM_CN_PromotionContractUtilClass.UpsertAttachment(thisPR.ASI_TH_CRM_Contract__c, System.JSON.serialize(ReturnList),'Last Payment Data' );
    }

    public static void lastPaymentAutoPOModification(ASI_TH_CRM_Contract__c Contract, Date PaymentCutOffDate) {
        //clone contract as archived po
        ASI_TH_CRM_Contract__c ContractCloned = ASI_CRM_CN_PromotionContractUtilClass.ArchivePO(Contract);


        //****update existing PO****
        Contract.ASI_CRM_CN_Last_PO_version__c = ContractCloned.Id;


        //Contract.ASI_CRM_CN_Status__c = 'Final';
        if (Contract.ASI_CRM_CN_PO_Version__c == '0.0') {
            Contract.ASI_CRM_CN_V0_0_PO_version__c = ContractCloned.Id;
        }
        List<String> poVersionSplit = Contract.ASI_CRM_CN_PO_Version__c.split('\\.', 0);
        if (poVersionSplit != null && poVersionSplit.size() == 2) {
            Contract.ASI_CRM_CN_PO_Version__c = poVersionSplit[0] + '.' + String.valueOf(Integer.valueOf(poVersionSplit[1]) + 1);
        }
        // New contract end date should be Min(PaymentCutOffDate, contract End Date)
        PaymentCutOffDate = PaymentCutOffDate != null ? PaymentCutOffDate : ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        Contract.ASI_CRM_CN_PO_End_Date__c = PaymentCutOffDate < Contract.ASI_CRM_CN_PO_End_Date__c ?  PaymentCutOffDate : Contract.ASI_CRM_CN_PO_End_Date__c;

        Date fiscalYearStart = ASI_CRM_CN_HeavyPaymentUtilitiesClass.getFiscalYearStart(System.today());
        if (Contract.ASI_CRM_CN_PO_Start_Date__c != null) {
            if (Contract.ASI_CRM_CN_PO_Start_Date__c < fiscalYearStart.addYears(1)) {
                Contract.ASI_CRM_CN_Effective_Date__c = fiscalYearStart;
            } else {
                Contract.ASI_CRM_CN_Effective_Date__c = ASI_CRM_CN_HeavyPaymentUtilitiesClass.getFiscalYearStart(Contract.ASI_CRM_CN_PO_Start_Date__c);
            }
        } else {
            Contract.ASI_CRM_CN_Effective_Date__c = fiscalYearStart;
        }


        Contract.ASI_CRM_Copied_From__c = ContractCloned.Id; // Previous Contract
        Contract.ASI_TH_CRM_Start_Date__c = null;
        Contract.ASI_TH_CRM_End_Date__c = null;
        Contract.ASI_CRM_Reject_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Last_Approved_By__c = null;
        Contract.ASI_CRM_CN_Last_Approved_Date__c = null;
        Contract.ASI_CRM_CN_Last_Recall_By__c = null;
        Contract.ASI_CRM_CN_Last_Recall_Date__c = null;
        Contract.ASI_CRM_CN_Last_Rejected_By__c = null;
        Contract.ASI_CRM_CN_Last_Rejected_Date__c = null;
        Contract.ASI_CRM_CN_Last_Submitted_By__c = null;
        Contract.ASI_CRM_CN_Last_Submitted_Date__c = null;
        Contract.ASI_CRM_Auto_PO_Modification_Time__c = Datetime.now();
        Contract.ASI_CRM_CN_PO_Modification__c = true;
        //Contract.ASI_CRM_CN_Contract_Upload__c=False;
        If(!test.isRunningTest()) {update Contract;}


        ASI_TH_CRM_Contract__c SelectContract = [
                SELECT Id,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_Auto_PO_Modification__c,
                        ASI_CRM_CN_Effective_Date__c,
                        ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_Description__c,
                        ASI_CRM_Copied_From__c,
                        ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,
                        ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,
                        ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                        ASI_CRM_CN_PO_Version__c,
                        ASI_CRM_CN_Contract_Upload__c,
                        ASI_CRM_V0_PSF_Contract_Total__c,
                        ASI_CRM_CN_Expected_PSF_Est_Total__c,
                        ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
                        ASI_CRM_Previous_Version_PSF_Est_Total__c,
                        ASI_CRM_PSF_Grand_Contract_Total__c,
                        ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,
                        ASI_CRM_Expected_V0_0_VEC_Est_Total__c,
                        ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,
                        ASI_CRM_PSF_Contract_Adjustment_Amount__c,
                        ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,
                        ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                        ASI_CRM_PSF_Grand_Estimate_Total__c,
                        ASI_CRM_Prev_Version_Display_Est_Total__c,
                        ASI_CRM_CN_Expected_Display_Est_Total__c,
                        ASI_CRM_Display_Estimate_Adjustment_Amt__c,
                        ASI_CRM_Prev_Ver_Visibility_Est_Total__c,
                        ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                        ASI_CRM_Visibility_Est_Adjust_percent__c
                FROM ASI_TH_CRM_Contract__c
                WHERE Id = :Contract.Id
        ];


        //****************** get Payment info **************************************************
        Decimal BRSFPaidAmount = 0;
        Decimal PSFPaidAmount = 0;
        Decimal displayPaidAmount = 0;
        Decimal visibilityPaidAmount = 0;
        Map<String, Decimal> FixedCostMap = new Map<String, Decimal>();

        for (ASI_TH_CRM_PaymentRequestLineItem__c payline : [
                SELECT Id, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                        ASI_CRM_Over_Incentive__c,ASI_CRM_Suggested_Value__c,ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                        ASI_TH_CRM_Payment_Request__c,ASI_CRM_Volume_Base__c,ASI_CRM_Product_Category__c,ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_CTD_Actual_Vol__c, ASI_CRM_CN_Standard__c,ASI_CRM_CTD_Cap_Collection_Vol__c, ASI_CRM_CN_Payable_Vol__c, ASI_CRM_Key_Sub_Brand__c, ASI_CRM_CN_Completion_Rate__c, ASI_CRM_V0_0_Full_Contract_Target__c, ASI_CRM_CN_Total_Payable__c, ASI_CRM_CN_Actual_Vol__c, ASI_CRM_CN_Bottle_Collected__c, ASI_CRM_CN_Collection_Rate__c,ASI_CRM_CN_Incentive_BT__c, ASI_CRM_CN_Allow_Changing_Incentive__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Module__c,ASI_CRM_CN_Sub_Brand__c,RecordType.DeveloperName, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_Comment__c, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Remaining_Amount__c, RecordTypeId, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_AC_Code__c
                FROM ASI_TH_CRM_PaymentRequestLineItem__c
                WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :Contract.Id
                AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c != 'Draft' AND
                RecordType.DeveloperName = 'ASI_CRM_CN_Payment_Request_Detail_Other'
        ]) {
            if (payline.ASI_CRM_CN_AC_Code__c == null || payline.ASI_TH_CRM_Amount__c == null) {
                continue;
            }
            if (FixedCostMap.containsKey(payline.ASI_CRM_CN_AC_Code__c)) {
                Decimal TempAmount = FixedCostMap.get(payline.ASI_CRM_CN_AC_Code__c) + payline.ASI_TH_CRM_Amount__c;
                FixedCostMap.remove(payline.ASI_CRM_CN_AC_Code__c);
                FixedCostMap.put(payline.ASI_CRM_CN_AC_Code__c, TempAmount);
            } else {
                FixedCostMap.put(payline.ASI_CRM_CN_AC_Code__c, payline.ASI_TH_CRM_Amount__c);
            }
        }


        List<ASI_CRM_Contract_Cost__c> LFixCost = new List<ASI_CRM_Contract_Cost__c>();
        for (ASI_CRM_Contract_Cost__c cc : [
                SELECT Id, Name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c,
                        ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c
                FROM ASI_CRM_Contract_Cost__c
                WHERE ASI_CRM_CN_Contract__c = :Contract.Id
        ]) {
            if (cc.ASI_CRM_CN_Cost_Type__c == 'Fixed') {
                if (FixedCostMap.containsKey(cc.ASI_CRM_CN_Activity_Code__c)) {
                    cc.ASI_CRM_CN_Estimate_Amount__c = FixedCostMap.get(cc.ASI_CRM_CN_Activity_Code__c);
                }
                LFixCost.add(cc);
            }
        }


        //Update Contract Fix cost
        if (LFixCost.size() > 0) {
            update LFixCost;
        }


        Map<String, Decimal> PSFPaidMap = new Map<String, Decimal>();

        //Calculate actual paid amount
        for (ASI_TH_CRM_PaymentRequest__c PaymentRequest : [
                SELECT Id,Name,ASI_TH_CRM_Status__c, ASI_CRM_CN_Total_Free_Goods_Amount__c, (SELECT Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c,ASI_CRM_Parent_Module__c FROM ASI_CRM_Modules__r)
                FROM ASI_TH_CRM_PaymentRequest__c
                WHERE ASI_TH_CRM_Contract__c = :Contract.Id AND ASI_TH_CRM_Status__c != 'Draft'
        ]) {
            for (ASI_CRM_Module__c module : PaymentRequest.ASI_CRM_Modules__r) {
                if (module.ASI_CRM_Line_Type__c == 'PSF') {
                    PSFPaidAmount += module.ASI_CRM_Actual_Payment__c != null? module.ASI_CRM_Actual_Payment__c : 0;
                    if (PSFPaidMap.containsKey(module.ASI_CRM_Parent_Module__c)) {

                        Decimal TempAmount = module.ASI_CRM_Actual_Payment__c != null? module.ASI_CRM_Actual_Payment__c : 0;
                        TempAmount += PSFPaidMap.get(module.ASI_CRM_Parent_Module__c) ;
                        PSFPaidMap.remove(module.ASI_CRM_Parent_Module__c);
                        PSFPaidMap.put(module.ASI_CRM_Parent_Module__c, TempAmount);
                    } else {
                        PSFPaidMap.put(module.ASI_CRM_Parent_Module__c, module.ASI_CRM_Actual_Payment__c != null? module.ASI_CRM_Actual_Payment__c : 0);
                    }

                }
                /*if (module.ASI_CRM_Line_Type__c == 'Display') {
                    displayPaidAmount += module.ASI_CRM_Actual_Payment__c != null? module.ASI_CRM_Actual_Payment__c : 0;
                    System.debug('display payment line!');
                    System.debug(module.ASI_CRM_Actual_Payment__c);
                }*/
                if (module.ASI_CRM_Line_Type__c =='Visibility'){
                    visibilityPaidAmount += module.ASI_CRM_Actual_Payment__c != null? module.ASI_CRM_Actual_Payment__c : 0;
                }
            }
            //Display
            displayPaidAmount += PaymentRequest.ASI_CRM_CN_Total_Free_Goods_Amount__c != null ? PaymentRequest.ASI_CRM_CN_Total_Free_Goods_Amount__c : 0;
        }
        //***********************************Finish Getting Payment Info ********************************************


        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> UpdatedDetailLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        //current version Contract Line
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailLines = [
                SELECT Id,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Volume_Base__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c
                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                WHERE ASI_CRM_CN_Contract__c = :Contract.Id
        ] ;


        Map<String, ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData> ContractLineItem_Map = new Map<String, ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData> ();


        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractDetailLines) {
            //by Line Type(BRSF/PSF/VEC) + Module Id
            if (ContractLineItem_Map.containsKey(ContractLine.ASI_CRM_Type__c + ContractLine.ASI_CRM_Module__c)) {
                ContractLineItem_Map.get(ContractLine.ASI_CRM_Type__c + ContractLine.ASI_CRM_Module__c).DetailLineMap.put(ContractLine.Id, ContractLine);
            } else {//New
                ASI_CRM_Module__c TempModule = new ASI_CRM_Module__c(ASI_CRM_Volume_Base__c = ContractLine.ASI_CRM_Volume_Base__c, ASI_CRM_Line_Type__c = ContractLine.ASI_CRM_Type__c);

                ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData TempData = new ASI_CRM_CN_HeavyPaymentUtilitiesClass.interimData(TempModule);
                TempData.DetailLineMap.put(ContractLine.Id, ContractLine);
                ContractLineItem_Map.put(ContractLine.ASI_CRM_Type__c + ContractLine.ASI_CRM_Module__c, TempData);

            }
        }

        Decimal VECEstimateAmount = 0;
        Decimal PSFEstimateAmount = 0;

        Decimal PSFContractAmount = 0;

        Decimal PSFPreviousEstimateAmount = 0;
        Decimal DisplayPreviousEstimateAmount = 0;
        Decimal VisibilityPreviousEstimateAmount = 0;



        for (String HeaderKey : ContractLineItem_Map.keySet()) {
            Decimal EstimateAmount = 0;// For BRSF VEC Use

            String PSFBySubBrandModuleId = '';
            Decimal PSFAmount_BySubBrand = 0;
            //looping every contract Line
            for (String keyline : ContractLineItem_Map.get(HeaderKey).DetailLineMap.keySet()) {


                ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine = ContractLineItem_Map.get(HeaderKey).DetailLineMap.get(keyline);


                if (ContractLine.ASI_CRM_CN_Sub_Brand__c != null) {// Volume base is by Sub-Brand
                    PSFBySubBrandModuleId = ContractLine.ASI_CRM_Module__c != null? ContractLine.ASI_CRM_Module__c : '';
                    if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                        PSFPreviousEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                    }
                    //if this contarct line is not 999-line, perform calculation
                    PSFAmount_BySubBrand += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    UpdatedDetailLines.add(ContractLine);

                    if (ContractLine.ASI_CRM_Type__c == 'BRSF' || ContractLine.ASI_CRM_Type__c == 'Display') {
                        EstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

                    }

                } else {
                    UpdatedDetailLines.add(ContractLine);

                    if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                        PSFPreviousEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                    }
                    if (ContractLine.ASI_CRM_Type__c == 'BRSF' || ContractLine.ASI_CRM_Type__c == 'Display') {
                        EstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

                    }
                }


                if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                    PSFContractAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    PSFEstimateAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

                }
            }// end of looping this Module



            //PSFPaidMap



        }//Ending of Contract Line looping


        //update existing contract Line
        if (UpdatedDetailLines.size() > 0) {
            upsert UpdatedDetailLines;
        }

        if (SelectContract.ASI_CRM_Copied_From__c != null) {
            PSFPreviousEstimateAmount = SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c != null? SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c : 0 ;
            DisplayPreviousEstimateAmount = SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c != null? SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c : 0 ;
            VisibilityPreviousEstimateAmount = SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Visibility_Est_Total__c != null ? SelectContract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Visibility_Est_Total__c : 0;
        }



        //**************************Contract Details**************************************************

        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        if (SelectContract.ASI_CRM_CN_PO_Start_Date__c != null) {
            if (SelectContract.ASI_CRM_CN_PO_Start_Date__c < ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(System.today(), orgFiscalMonth).addYears(1)) {
                SelectContract.ASI_CRM_CN_Effective_Date__c = ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(System.today(), orgFiscalMonth);
            } else {
                SelectContract.ASI_CRM_CN_Effective_Date__c = ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(SelectContract.ASI_CRM_CN_PO_Start_Date__c, orgFiscalMonth);
            }
        } else {
            SelectContract.ASI_CRM_CN_Effective_Date__c = ASI_CRM_CN_HeavyContractUtilitiesClass.getFiscalYearStart(System.today(), orgFiscalMonth);
        }


        //BRSF
        SelectContract.ASI_CRM_CN_Expected_BRSF_Est_Total__c = BRSFPaidAmount;
        //PSF
        //ASI_CRM_Expected_V0_PSF_Estimated_Total__c
        SelectContract.ASI_CRM_Previous_Version_PSF_Est_Total__c = PSFPreviousEstimateAmount;
        SelectContract.ASI_CRM_PSF_Estimate_Adjustment_Amount__c = PSFPaidAmount - PSFPreviousEstimateAmount;
        SelectContract.ASI_CRM_CN_Expected_PSF_Est_Total__c = PSFPaidAmount;
        SelectContract.ASI_CRM_PSF_Grand_Contract_Total__c = PSFContractAmount;
        SelectContract.ASI_CRM_V0_PSF_Contract_Total__c = PSFContractAmount;
        SelectContract.ASI_CRM_Auto_PO_Modification__c = true;
        //Display
        SelectContract.ASI_CRM_Prev_Version_Display_Est_Total__c = DisplayPreviousEstimateAmount;
        SelectContract.ASI_CRM_CN_Expected_Display_Est_Total__c = displayPaidAmount;
        SelectContract.ASI_CRM_Display_Estimate_Adjustment_Amt__c = displayPaidAmount - DisplayPreviousEstimateAmount;

        //Visibility
        SelectContract.ASI_CRM_Prev_Ver_Visibility_Est_Total__c = VisibilityPreviousEstimateAmount;
        SelectContract.ASI_CRM_CN_Expected_Visibility_Est_Total__c = visibilityPaidAmount;
        SelectContract.ASI_CRM_Visibility_Est_Adjust_percent__c = visibilityPaidAmount - VisibilityPreviousEstimateAmount;

        System.debug(SelectContract.ASI_CRM_Prev_Version_Display_Est_Total__c);
        System.debug(SelectContract.ASI_CRM_CN_Expected_Display_Est_Total__c);
        System.debug(SelectContract.ASI_CRM_Display_Estimate_Adjustment_Amt__c);

        update SelectContract;
    }

    //Get All approved, submitted and paid payment request, with the current Payment 
    public static List<ASI_TH_CRM_PaymentRequest__c> getAllPaymentRequest(Id ContractId, Id thisPaymentId){
        List<ASI_TH_CRM_PaymentRequest__c> allPaymentRequest = new List<ASI_TH_CRM_PaymentRequest__c>();
        try{
            allPaymentRequest = [SELECT Id,
                    Name,
                    ASI_CRM_CN_Promotion_Type__c,
                    ASI_CRM_CN_Total_BRSF_Amount__c,
                    ASI_CRM_CN_Total_Display_Amount__c,
                    ASI_CRM_CN_Total_Other_Amount__c,
                    ASI_CRM_CN_Total_PSF_Amount__c,
                    ASI_CRM_CN_Total_Payment__c,
                    ASI_CRM_CN_Total_VEC_Amount__c,
                    ASI_CRM_Total_Variable_Amount__c,
                    ASI_TH_CRM_Contract__c,
                    ASI_CRM_CN_Total_Free_Goods_Amount__c,
            (SELECT ASI_CRM_Actual_Payment__c,
                    ASI_CRM_CN_Contract_Volume_Base__c,
                    ASI_CRM_CN_Volume_Value_Base__c,
                    ASI_CRM_Methodology__c,
                    ASI_CRM_Methodology__r.Name,
                    ASI_CRM_Line_Type__c,
                    ASI_CRM_Volume_Base__c,
                    ASI_CRM_Completion_Ratio__c
            FROM ASI_CRM_Modules__r)
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE ASI_TH_CRM_Contract__c = :ContractId
            AND (Id = :thisPaymentId
            OR ASI_TH_CRM_Status__c = 'Approved'
            OR ASI_TH_CRM_Status__c = 'Submitted'
            OR ASI_TH_CRM_Status__c = 'Paid')];
        }catch(Exception e){
            String msg = 'Save Error : ' +e.getMessage() + '</br>';
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_PromotionPaymentUtilClass.getAllPaymentRequest  class have Error  '+msg,'ASI_CRM_CN_PromotionPaymentUtilClass',' function failed! with Payment Id: '+ thisPaymentId );
            return null;
        }
        return allPaymentRequest;
    }

    //Payment check Point Page to calculate all Total Paid Amount
    public static Decimal RetrieveTotalPaidAmount(List<ASI_TH_CRM_PaymentRequest__c> AllPaymentRequest){
        Decimal allPaymentTotal = 0;

        //Sum up previous payments amounts
//        if (AllPaymentRequest.size() > 0){
//            for (ASI_TH_CRM_PaymentRequest__c allPR_temp : AllPaymentRequest){
//               allPaymentTotal+=allPR_temp.ASI_CRM_Total_Variable_Amount__c!=NULL?allPR_temp.ASI_CRM_Total_Variable_Amount__c:0;
//            }
//        }
        if (AllPaymentRequest.size() > 0){
            for (ASI_TH_CRM_PaymentRequest__c allPR_temp : AllPaymentRequest){
                for(ASI_CRM_Module__c module : allPR_temp.ASI_CRM_Modules__r){
                    allPaymentTotal += module.ASI_CRM_Actual_Payment__c != null ? module.ASI_CRM_Actual_Payment__c : 0;
                }
                if (allPR_temp.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion')
                    allPaymentTotal += allPR_temp.ASI_CRM_CN_Total_Free_Goods_Amount__c != null ? allPR_temp.ASI_CRM_CN_Total_Free_Goods_Amount__c : 0;
            }
        }

        return allPaymentTotal;
    }

    public static Decimal RetrieveTotalAmountExclOthers(List<ASI_TH_CRM_PaymentRequest__c> AllPaymentRequest){
        Decimal result = 0;

        //Sum up previous payments amounts
        if (AllPaymentRequest.size() > 0){
            for (ASI_TH_CRM_PaymentRequest__c allPR_temp : AllPaymentRequest){
                for(ASI_CRM_Module__c module : allPR_temp.ASI_CRM_Modules__r){
                    //Exclude Line Type = 'Display' and Methodology = 'Others'
                    if (module.ASI_CRM_Line_Type__c != 'Display' && module.ASI_CRM_Line_Type__c != 'Others' && module.ASI_CRM_Line_Type__c !='Visibility') {
                        result += module.ASI_CRM_Actual_Payment__c != null ? module.ASI_CRM_Actual_Payment__c : 0;
                    }
                }
            }
        }
        return result;
    }

    public static Decimal RetrieveTotalSuggestedPayableAmount(ASI_TH_CRM_PaymentRequest__c thisPaymentRequest){
        Decimal result = 0;
        AggregateResult[] groupedResults = [SELECT SUM(ASI_CRM_Suggested_Payable_Amount__c)
        FROM ASI_CRM_Module__c
        WHERE ASI_CRM_Payment_Request__c = :thisPaymentRequest.Id];
        if (groupedResults.size() > 0){
            for (AggregateResult ar : groupedResults)  {
                result += denullify((Decimal) ar.get('expr0'), 0);
            }
        }

        return result;
    }

    public static void PaymentKPICalculation(ASI_TH_CRM_PaymentRequest__c PaymentRequest){
        FinancialIndicator paymentFinancialIndicator = new FinancialIndicator();
        Map<String,Decimal> PaymentKPIMap= new Map<String,Decimal>();
        //Data for Contract
        Boolean isPOS = false;
        String base;

        //KPI 
        Decimal FixedPaymentTotal = 0 ;
        Decimal VariablePaymentTotal = 0;
        Decimal VariableCostTotalExclOthers = 0;
        Decimal PaymentSpeed = 0 ;
        Decimal PaymentExclOthersSpeed = 0;
        Decimal VolumeSpeed = 0;
        Decimal ValueSpeed = 0;

        //Payment Speed
        //Query all payment request with vFinal contract
        List<ASI_TH_CRM_PaymentRequest__c> AllPaymentRequest = getAllPaymentRequest(PaymentRequest.ASI_TH_CRM_Contract__c, PaymentRequest.Id);

        Decimal TotalPaymentAmount = RetrieveTotalPaidAmount(AllPaymentRequest);
        Decimal TotalPaymentAmountExclOthers = RetrieveTotalAmountExclOthers(AllPaymentRequest);

        paymentFinancialIndicator.TotalPaymentAmount = TotalPaymentAmount;
        paymentFinancialIndicator.TotalPaymentAmountExclOthers = TotalPaymentAmountExclOthers;

        Decimal TotalSuggestedPayableAmount = RetrieveTotalSuggestedPayableAmount(PaymentRequest);
        paymentFinancialIndicator.SuggestedPayableAmount = TotalSuggestedPayableAmount;


        Decimal v0_Cost = 0;
        Decimal v0CostExclOthers = 0;

        Decimal Actual_Cost = 0;
        Decimal ActualCostExclOthers = 0;

        Decimal V0ContractVolume = 0;
        Decimal V0ContractValue = 0;

        Decimal ActualIntake = 0;
        Decimal ActualValueSales = 0;

        //Get relation field
        ASI_TH_CRM_PaymentRequest__c thisPR = [select ASI_TH_CRM_Contract__c,
                                                      ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,
                                                      ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                                                      ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                                                      ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c
                                               from ASI_TH_CRM_PaymentRequest__c where Id = :PaymentRequest.Id];

        //Min Key Strategy sub-brands achievement% should greater or equal to total volume achievement%.
        //Decimal  MKSSBAR=9999999;// Min Key Strategy SubBrand Achievement Rate 

        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [Select Id,
                Name,
                RecordType.DeveloperName,
                RecordTypeId,
                ASI_CRM_CN_AC_Code__c,
                ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c,
                ASI_CRM_CN_Completion_Rate__c,
                ASI_CRM_CN_Expense_Type__c,
                ASI_CRM_Key_Sub_Brand__c,
                ASI_CRM_Volume_Base__c,
                ASI_TH_CRM_Amount__c
        from ASI_TH_CRM_PaymentRequestLineItem__c
        where ASI_TH_CRM_Payment_Request__c = :PaymentRequest.Id ])
        {//and  RecordType.DeveloperName='ASI_CRM_CN_Payment_Request_Detail_Other' 
            if(PaymentLine.RecordType.DeveloperName =='ASI_CRM_CN_Payment_Request_Detail_Other'){
                FixedPaymentTotal+=PaymentLine.ASI_TH_CRM_Amount__c !=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
            }
            if(PaymentLine.RecordType.DeveloperName =='ASI_CRM_CN_Payment_Request_Detail_PSF' &&
                    PaymentLine.ASI_CRM_Volume_Base__c!=null &&
                    PaymentLine.ASI_CRM_CN_Completion_Rate__c !=null &&
                    PaymentLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'  &&
                    PaymentLine.ASI_CRM_Key_Sub_Brand__c ){

                PaymentKPIMap.put('Key Strategy sub-brands', 1);
                /*
                if(PaymentLine.ASI_CRM_CN_Completion_Rate__c<MKSSBAR){
                    MKSSBAR=PaymentLine.ASI_CRM_CN_Completion_Rate__c;
                }
                */
            }

        }


        //PaymentKPIMap.put('MKSSBAR', MKSSBAR);


        for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){
            VariablePaymentTotal += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
            System.debug('LineType, Methodology, actualPay: ' + module.ASI_CRM_Line_Type__c + ' : ' + module.ASI_CRM_Methodology__r.Name + ' : ' + module.ASI_CRM_Actual_Payment__c);
            //Exclude if Line Type = 'Others' or Line Type = Display and Methodology Name = 'Others'
            if ((module.ASI_CRM_Line_Type__c != 'Display' || module.ASI_CRM_Methodology__r.Name != 'Others') && module.ASI_CRM_Line_Type__c != 'Others') {
                VariableCostTotalExclOthers += module.ASI_CRM_Actual_Payment__c != null ? module.ASI_CRM_Actual_Payment__c : 0;
                System.debug(VariableCostTotalExclOthers);
            }
            /*
            if(module.ASI_CRM_Line_Type__c=='PSF' && module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                PaymentKPIMap.put('PSFBySubBrandAchievementRate', module.ASI_CRM_Completion_Ratio__c);
            }
            */
        }



        String V0ContractId='';
        if(PaymentRequest.ASI_TH_CRM_Contract__c!=null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        }else if(PaymentRequest.ASI_TH_CRM_Contract__c!=null){
            V0ContractId=PaymentRequest.ASI_TH_CRM_Contract__c;
        }

        //For Volume Base, V0ContractVolume = Sum of (CR12Factor * contractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c * contractDetail.ASI_CRM_CN_No_of_Months__c)
        //  VolumeSpeed = Actual Intake / V0ContractVolume
        //For Value Base, V0ContractValue = Sum of (ASI_CRM_CN_Contract_Total_Dummy__c)
        //	ValueSpeed = (Actual Intake or POS) / V0ContractValue
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractDetailList=[SELECT Id,
                ASI_CRM_Type__c,
                ASI_CRM_CN_Contract_Total_Dummy__c,
                ASI_CRM_CN_Est_Total_Dummy__c,
                ASI_CRM_CN_Contract_Total__c,
                ASI_CRM_CN_Est_Total__c,
                ASI_CRM_CN_Sub_Brand__c,
                ASI_CRM_CN_Sub_Brand__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_Est_Monthly_Qty__c,
                ASI_CRM_CN_Sub_Brand_Conversion_Factor__c,
                ASI_CRM_CN_Contract__c,
                ASI_CRM_CN_Contract__r.ASI_CRM_CN_Total_RContract_Amount__c,
                ASI_CRM_CN_Estimate_Volume_9L_Month__c,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Contract_Monthly_Vol9L__c,
                ASI_CRM_CN_Contract_Monthly_Qty__c,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c,
                ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c,
                ASI_CRM_Module__r.ASI_CRM_CN_Volume_Value_Base__c,
                ASI_CRM_Module__r.ASI_CRM_Line_Type__c,
                ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
                ASI_CRM_CN_Contract_Purchase_Value__c
        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :V0ContractId];

        //v0 cost = Trade expenses from 'Contract Data'
        ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator NewContractV0Estimate = new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator();
        List<ASI_Attachment__c> AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c
        WHERE ASI_CRM_Contract__c = :PaymentRequest.ASI_TH_CRM_Contract__c];
        if(AttachmentList.size() >0) {
            for (ASI_Attachment__c att : AttachmentList) {
                if(att.ASI_CRM_Type__c =='Contract Data') {
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;', '"');
                    JsonString = JsonString.replaceAll('&quot;', '"');
                    List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList = (List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>) System.JSON.deserialize(JsonString, List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                    if (ContractList.size() > 0) {
                        NewContractV0Estimate = ContractList[0];
                        v0_Cost = NewContractV0Estimate.TradeExpenses;
                        v0CostExclOthers = NewContractV0Estimate.PSFExpensesTotal;
                        v0ContractVolume = NewContractV0Estimate.Volumes;
                        V0ContractValue = NewContractV0Estimate.GrossSalesTotal;
                    }
                }
                if(att.ASI_CRM_Type__c =='PO Modification Data'){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        Actual_Cost = ContractList[0].TradeExpenses;
                        ActualCostExclOthers = ContractList[0].PSFExpensesTotal;
                    }
                }
            }
        }

        ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator CurrentContract = new ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator();
        List<ASI_Attachment__c> AttachmentList2= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c
        WHERE ASI_CRM_Contract__c = :PaymentRequest.ASI_TH_CRM_Contract__c];
        if(AttachmentList2.size() >0) {
            for (ASI_Attachment__c att : AttachmentList2) {
                if(att.ASI_CRM_Type__c =='PO Actual Data'){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;', '"');
                    JsonString = JsonString.replaceAll('&quot;', '"');
                    List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator> ContractList = (List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>) System.JSON.deserialize(JsonString, List<ASI_CRM_CN_PromotionContractUtilClass.FinancialIndicator>.class);
                    if (ContractList.size() > 0) {
                        CurrentContract = ContractList[0];
                    }
                }
            }
        }


        Set<Id> SubBrandIdSet = new Set<Id> ();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractDetail:contractDetailList){
            if(ContractDetail.ASI_CRM_Type__c=='BRSF'){
                SubBrandIdSet.add(ContractDetail.ASI_CRM_CN_Sub_Brand__c);
                isPOS = (ContractDetail.ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c == 'POS');
                base = ContractDetail.ASI_CRM_Module__r.ASI_CRM_CN_Volume_Value_Base__c;
            }
        }

        Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
        if(SubBrandIdSet.size()>0){
            CR12FactorMap=ASI_CRM_CN_PromotionContractUtilClass.GenerateCR12FactorMap(SubBrandIdSet,
                    thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                    thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c);
        }

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractDetail:contractDetailList)
        {
            if(contractDetail.ASI_CRM_Type__c=='BRSF'){
                Decimal CR12Factor=1;
                if(CR12FactorMap.containsKey(contractDetail.ASI_CRM_CN_Sub_Brand__c)){
                    CR12Factor=CR12FactorMap.get(contractDetail.ASI_CRM_CN_Sub_Brand__c);
                }
                //V0ContractVolume+=CR12Factor*contractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c * contractDetail.ASI_CRM_CN_No_of_Months__c;

                //Value base
                //V0ContractValue += contractDetail.ASI_CRM_CN_Contract_Purchase_Value__c != null ? contractDetail.ASI_CRM_CN_Contract_Purchase_Value__c : 0;
            } else {
                //Add all contract BRSF Line Contract Total except BRSF Line
                //v0_Cost += denullify(contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c);
                if ((contractDetail.ASI_CRM_Module__r.ASI_CRM_Line_Type__c != 'Display' || contractDetail.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name != 'Others') && contractDetail.ASI_CRM_Module__r.ASI_CRM_Line_Type__c != 'Others') {
                    //v0CostExclOthers += denullify(contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c);
                }
            }
        }

        ///*******************Calculate Volume Speed*******************************************************************
        List<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new List<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
            FROM ASI_CRM_CN_Covered_Outlet__c
            WHERE ASI_CRM_CN_Contract__c = :PaymentRequest.ASI_TH_CRM_Contract__c];
        }catch(Exception e){
            CoveredOutlet = new List<ASI_CRM_CN_Covered_Outlet__c>();
        }

        Set<Id> AllOutlet = new Set<Id>();
        //ASI_TH_CRM_PaymentRequest__c tempPR = [SELECT id, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :thisPR.id]; 
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(PaymentRequest.ASI_CRM_CN_OutletWS__c);
        }
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }

        List<ASI_CRM_Subbrand_Volume__c> SubBrandVolumeList = new List<ASI_CRM_Subbrand_Volume__c> ();
        Date TillEnd = ASI_CRM_DateUtilClass.getEndOfMonth(ASI_CRM_DateUtilClass.findMinMaxDate(ASI_CRM_DateUtilClass.getCutOffDate(), PaymentRequest.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        System.debug('SB Vol TillEnd : '+TillEnd);
        try{
            String subBrandVolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
            subBrandVolumeQuery += 'WHERE ASI_CRM_Subbrand__c !=null ' +
                    'AND ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
                    'AND ASI_CRM_End_Date__c >= ' + String.valueOf(PaymentRequest.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
                    'AND ASI_CRM_End_Date__c <= ' + String.valueOf(TillEnd) + ' ' +
                    'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = false ';
            if (AllOutlet.size() >= ASI_CRM_CN_PromotionContractUtilClass.outletThreshold()){
                subBrandVolumeQuery += 'AND ASI_CRM_CN_Contract__c = \'' + PaymentRequest.ASI_TH_CRM_Contract__c + '\' ' +
                        'AND recordtypeId = \'' + Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')+'\' ';
            } else {
                subBrandVolumeQuery += 'AND ASI_CRM_Account__c IN: AllOutlet ' +
                        'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';
            }
            SubBrandVolumeList = Database.query(subBrandVolumeQuery);

        }catch(Exception e){
            SubBrandVolumeList = new List<ASI_CRM_Subbrand_Volume__c >();
        }

        Decimal markupPercent = 0;
        List<ASI_CRM_Module__c> ModuleList = [
                SELECT ASI_CRM_CN_Contract_Volume_Base__c, ASI_CRM_CN_Total_Markup__c, ASI_CRM_Line_Type__c, (SELECT Id FROM Contract_BRSF_Line_Item__r)
                FROM ASI_CRM_Module__c
                WHERE ASI_CRM_Contract__c = :PaymentRequest.ASI_TH_CRM_Contract__c
        ];

        for (ASI_CRM_Module__c module : ModuleList){
            if (module.ASI_CRM_CN_Contract_Volume_Base__c == 'POS'){
                isPOS = true;
            }
            if (module.ASI_CRM_Line_Type__c == 'BRSF' && module.ASI_CRM_CN_Total_Markup__c != null) {
                markupPercent = module.ASI_CRM_CN_Total_Markup__c;
            }
            // if there is multiple BRSF module, use the one that has BRSF line
            if (!module.Contract_BRSF_Line_Item__r.isEmpty()) {
                break;
            }
        }
        System.debug('markupPercent  ' + markupPercent);

        if (SubBrandVolumeList.size() > 0){
            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume : SubBrandVolumeList ){
                ActualIntake += SubBrandVolume.ASI_CRM_Actual_Vol_CR12__c!=null?SubBrandVolume.ASI_CRM_Actual_Vol_CR12__c:0;
                if (isPOS){
                    ActualValueSales += denullify(SubBrandVolume.ASI_CRM_POS_GS__c);
                } else {
                    ActualValueSales += denullify(SubBrandVolume.ASI_CRM_CN_Intake_GS_T1_price__c);
                }
            }
            ActualValueSales = ActualValueSales * (1 + markupPercent / 100);
            System.debug('ActualValueSales ' + ActualValueSales);

        }

        //paymentFinancialIndicator.ActualVolume = ActualIntake;
        //paymentFinancialIndicator.ActualValue = ActualValueSales;
        paymentFinancialIndicator.ActualVolume = CurrentContract.Volumes;
        paymentFinancialIndicator.ActualValue = CurrentContract.GrossSalesTotal;

        paymentFinancialIndicator.FixedPaymentTotal = FixedPaymentTotal;
        paymentFinancialIndicator.VariablePaymentTotal = VariablePaymentTotal;
        paymentFinancialIndicator.v0Cost = Actual_Cost != null && Actual_Cost != 0 ? Actual_Cost : v0_Cost;
        paymentFinancialIndicator.v0CostExclOthers = ActualCostExclOthers != null && ActualCostExclOthers != 0 ? ActualCostExclOthers : v0CostExclOthers;

        paymentFinancialIndicator.v0ContractVolume = V0ContractVolume;
        paymentFinancialIndicator.V0ContractValue = V0ContractValue;

        paymentFinancialIndicator.PaymentExclOthersSpeed = PaymentExclOthersSpeed;
        paymentFinancialIndicator.PaymentSpeed = PaymentSpeed;

        System.debug('PaymentRequest.ASI_TH_CRM_Contract__c: ' + PaymentRequest.ASI_TH_CRM_Contract__c);
        System.debug('paymentFinancialIndicator: ' + System.JSON.serialize(paymentFinancialIndicator));
        ASI_CRM_CN_PromotionContractUtilClass.UpsertAttachment(PaymentRequest.ASI_TH_CRM_Contract__c, System.JSON.serialize(paymentFinancialIndicator),'Payment Data' );
    }

    public static Decimal denullify(Decimal input){
        return denullify(input, 0);
    }

    public static Decimal denullify(Decimal input, Decimal nullResult){
        if (input == null)
            return nullResult;
        else return input;
    }

    public static Decimal denullify(Decimal input, Integer nullResult){
        return denullify(input, Decimal.valueOf(nullResult));
    }

    public static Boolean isNotNullAndZero(Decimal d){
        if (d != null && d != 0)
            return true;
        else return false;
    }
    public static String SubBrandFieldList(){
        List<String> fieldList = new List<String>{
                'Id',
                'Name',
                'ASI_CRM_Actual_Vol_CR12__c',
                'ASI_CRM_CN_Intake_GS_T1_Price__c',
                'ASI_CRM_POS_GS__c',
                'ASI_CRM_End_Date__c',
                'ASI_CRM_Offtake_Std_Billing__c',
                'ASI_CRM_PR_Direct_CR12__c',
                'ASI_CRM_PR_Direct_STD__c',
                'ASI_CRM_PR_Direct_Std_Billing__c',
                'ASI_CRM_PR_Direct__c',
                'ASI_CRM_Subbrand__c',
                'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c',
                'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c',
                'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name',
                'ASI_CRM_Subbrand__r.Name',
                'ASI_CRM_T1_Depletion_CR12__c',
                'ASI_CRM_T1_Depletion_STD__c',
                'ASI_CRM_T1_Depletion_Std_Billing__c',
                'ASI_CRM_T1_Depletion__c',
                'ASI_CRM_T2_Depletion_CR12__c',
                'ASI_CRM_T2_Depletion_STD__c',
                'ASI_CRM_T2_Depletion_Std_Billing__c',
                'ASI_CRM_T2_Depletion__c'
        };
        return String.join(fieldList,',');
    }

    // Getting Historical Module List
    public static List<ASI_CRM_Module__c> HistoricalModuleQuerying(Set<Id> ParentModuleSet,String CurrentPaymentId){
        List<ASI_CRM_Module__c> HistoricalModuleList = new List<ASI_CRM_Module__c>();

        HistoricalModuleList = [SELECT  Id,
                                        ASI_CRM_Actual_Payment__c,
                                        ASI_CRM_End_Date__c,
                                        ASI_CRM_Parent_Module__c,
                                        ASI_CRM_Line_Type__c,
                                        ASI_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,
                                        ASI_CRM_Payment_Request__r.ASI_CRM_CN_PO_Start_Date__c,
                                        ASI_CRM_Payment_Request__r.Name,
                                        ASI_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,
                                        ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_PSF_Amount__c,
                                        ASI_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c,
                                        ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_BRSF_Amount__c,
                                        ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_VEC_Amount__c,
        (
                SELECT
                        ASI_CRM_CN_Actual_Vol__c,
                        ASI_CRM_CN_Allow_Changing_Incentive__c,
                        ASI_CRM_CN_Comment__c,
                        ASI_CRM_Customer__c,
                        ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Customer__r.Name,
                        ASI_CRM_CN_Rebate_Percent__c,
                        ASI_CRM_Historical_Paid_Amount__c,
                        ASI_CRM_CN_Total_Payable__c,
                        ASI_CRM_CN_Wholesaler__c,
                        ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_CN_Wholesaler__r.Name,
                        ASI_CRM_CTD_Actual_Purchase_Value__c,
                        ASI_CRM_CTD_Actual_Vol__c,
                        ASI_CRM_Line_Long_Name__c,
                        ASI_CRM_Module__c,
                        ASI_CRM_Unit_Price__c,
                        ASI_CRM_Volume_Base__c,
                        ASI_TH_CRM_Payment_Request__c,
                        ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                        ASI_TH_CRM_Quantity__c,
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
                ORDER BY ASI_CRM_CN_Wholesaler__c DESC
        )
        FROM ASI_CRM_Module__c
        WHERE ASI_CRM_Parent_Module__c IN: ParentModuleSet
        AND ASI_CRM_Payment_Request__c!=NULL
        AND ASI_CRM_Payment_Request__r.ASI_TH_CRM_Status__c!='Draft'
        AND ASI_CRM_Payment_Request__r.ASI_TH_CRM_Status__c!='Submitted'
        AND ASI_CRM_Payment_Request__c !=:CurrentPaymentId];

        for(ASI_CRM_Module__c Module:HistoricalModuleList){
            if(Module.ASI_CRM_Payment_Request__r.Name.substring(Module.ASI_CRM_Payment_Request__r.Name.length()-3, Module.ASI_CRM_Payment_Request__r.Name.length()) == '000'){///000-Payment

                if(Module.ASI_CRM_Line_Type__c=='BRSF'){
                    if(Module.ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_BRSF_Amount__c !=null){
                        if(Module.ASI_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c!=null){
                            Module.ASI_CRM_Actual_Payment__c =Module.ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_BRSF_Amount__c * (Module.ASI_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c/100);
                        }else{
                            Module.ASI_CRM_Actual_Payment__c =Module.ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_BRSF_Amount__c;
                        }

                    }
                }
                if(Module.ASI_CRM_Line_Type__c=='PSF'){
                    Module.ASI_CRM_Actual_Payment__c = Module.ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_PSF_Amount__c;
                }
                if(Module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                    Module.ASI_CRM_Actual_Payment__c =Module.ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_VEC_Amount__c;
                }
                if(Module.ASI_CRM_Line_Type__c=='Display'){
                    Module.ASI_CRM_Actual_Payment__c =Module.ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_VEC_Amount__c;
                }
            }
            Module.ASI_CRM_Actual_Payment__c= Module.ASI_CRM_Actual_Payment__c!=null?Module.ASI_CRM_Actual_Payment__c :0;
        }

        return HistoricalModuleList;
    }

    public static Map<String, Decimal> GetHistoricalAmountMap(List<ASI_CRM_Module__c> HistoricalModuleList){
        Map<String, Decimal> resultMap = new Map<String, Decimal>();
        for(ASI_CRM_Module__c module : HistoricalModuleList){
            if(module.Payment_Request_Line_Items__r.size()>0){
                String WholesalerId = module.Payment_Request_Line_Items__r[0].ASI_CRM_CN_Wholesaler__c != null ? String.valueOf(module.Payment_Request_Line_Items__r[0].ASI_CRM_CN_Wholesaler__c) : '';
                String OutletId = module.Payment_Request_Line_Items__r[0].ASI_CRM_Customer__c != null ? String.valueOf(module.Payment_Request_Line_Items__r[0].ASI_CRM_Customer__c) : '';
                String key =  String.valueOf(module.ASI_CRM_Parent_Module__c)+';'+WholesalerId+';'+OutletId;
                if(resultMap.containsKey(key)){
                    Decimal oldValue = resultMap.get(key);
                    resultMap.put(key, oldValue + (module.ASI_CRM_Actual_Payment__c != null ? module.ASI_CRM_Actual_Payment__c :0));
                }else{
                    resultMap.put(key, module.ASI_CRM_Actual_Payment__c != null ? module.ASI_CRM_Actual_Payment__c :0);
                }
            }
        }
        return resultMap;
    }
}