/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_PromotionVolumeReportCompCtrl
 * Description: Apex class for ASI_CRM_CN_PromotionVolumeReportCompCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-18       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_PromotionVolumeReportCompCtrl {
    public Id currentHeaderId {set;get;}
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;} {ContractSelected= new ASI_TH_CRM_Contract__c();}
    public String StartDateStr {get; set;}{StartDateStr='';}
    public String EndDateStr {get; set;}{EndDateStr='';}
    public Date StartDate {get; set;}{StartDate = Date.today();}
    public Date EndDate {get; set;}{StartDate = Date.today();}
    public Date CutOffDay {get; set;}

    public Boolean isPOS {get; set;} {isPOS = false;}
    public Boolean noData {get; set;} {noData=false;}
    public String POPeriodStr {set;get;} {POPeriodStr='';}
    public String VolPeriodStr {set;get;} {VolPeriodStr='';}
    public Integer ContractPeriod {set;get;} {ContractPeriod=1;}

    public Set<Id> WSOutletIds {set;get;}// Bowen使用
    public Set<Id> SubBrandExcludeSet {set;get;}// Bowen使用
    public Map<Id ,String> subBrandPackSizeMap {get;set;}
    public Map<Id ,Boolean> subBrandDropInMap {get;set;}

    public Decimal AccExcludeSum {get;set;}
    public Decimal SubExcludeSum {get;set;}


    public Map<String, interimData> interimDataMap{set;get;} {interimDataMap = new Map<String, interimData> ();}
    public Map<String, interimData> OutletDataMap{set;get;} {OutletDataMap = new Map<String, interimData> ();}
    public Map<String, interimData> CategoryVolumeMap{set;get;} {CategoryVolumeMap = new Map<String, interimData> ();}//Product Category

    public Map<String, String> interimDataSortMap{set;get;} {interimDataSortMap = new Map<String, String> ();}
    public Map<String, String> OutletDataSortMap{set;get;} {OutletDataSortMap = new Map<String, String> ();}

    public Map<String, DataClass> OutletSummaryList_Map{set;get;} {OutletSummaryList_Map = new Map<String, DataClass> ();}
    public List<String> districtList{get; set;} {districtList = new List<String>{'South','SW','E','N','Central','NW'};}


    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }

    public Decimal TotalMarkup;

    public ASI_CRM_CN_PromotionVolumeReportCompCtrl(){ }

    private final static List<String> RECORD_TYPE_LIST_AGGREGATION = new List<String> {
        'CN_WS_Outlet_Brand_Monthly_Volume',
        'CN_WS_Outlet_Region_Monthly_Volume',
        'CN_WS_Outlet_Category_Monthly_Volume',
        'CN_WS_Outlet_CTD_Sub_Brand_Data',
        'CN_WS_Outlet_Monthly_Sub_Brand_Data'
    };

    public String ContractId {set;get;} {ContractId='';}

    /*  Initialize by following procedure
            1. Get the Contract information
            2. Initialize Contract data
            3. Initialize Sub-brand Volume data
            4. Aggregate Data by Loop
    */
    public Boolean init(){
        OutletSummaryList_Map = new Map<String, DataClass> ();

        System.debug(StartDateStr);
        System.debug(EndDateStr);
        System.debug(StartDate);
        if(StartDateStr != '')
        {
            StartDate = Date.valueOf(StartDateStr);
        }
        else if(Test.isRunningTest())
        {
            StartDate = date.today();
        }
        
        if(EndDateStr != '')
        {
            EndDate = Date.valueOf(EndDateStr);
        }
        else if(Test.isRunningTest())
        {
            EndDate = date.today();
        }
        CutOffDay = VolumeCutOffDate(1,EndDate, StartDate); //16
        CutOffDay = CutOffDay == null ? EndDate : CutOffDay; //16

        if(!Test.isRunningTest()){
            ContractId = ApexPages.currentPage().getParameters().get('id');
        }
        else
        {
            currentHeaderId = ApexPages.currentPage().getParameters().get('id');
        }

        VolPeriodStr =  ASI_CRM_DateUtilClass.toDMY(StartDate) + ' - ' + ASI_CRM_DateUtilClass.toDMY(CutOffDay);

        if (currentHeaderId != null){
            ContractSelected = [SELECT Id, Owner.Name,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                ASI_CRM_CN_Outlet_WS__r.Name,
                ASI_CRM_CN_PO_End_Date__c,
                ASI_CRM_CN_PO_No__c,
                ASI_CRM_CN_PO_Start_Date__c,
                ASI_CRM_CN_Region__c,
                ASI_CRM_CN_V0_0_PO_version__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                ASI_CRM_New_FY_PO__c,
                ASI_CRM_PO_Channel__r.Name,
                ASI_CRM_PO_City__c,
                ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c,
                ASI_CRM_PO_City__r.Name,
                ASI_CRM_PO_Province__r.Name,
                ASI_TH_CRM_Promotion_Type__c,
                ASI_CRM_CN_Data_Source__c,
                ASI_CRM_Volume_Option__c,
                ASI_CRM_CN_Festival_Season__c,
                (select ASI_CRM_CN_Total_Markup__c
                 from Modules__r
                 where ASI_CRM_Line_Type__c = 'BRSF')
            FROM ASI_TH_CRM_Contract__c
            WHERE Id = :currentHeaderId];

            List<ASI_CRM_Module__c> ModuleList = [SELECT ASI_CRM_CN_Contract_Volume_Base__c
            FROM ASI_CRM_Module__c
            WHERE ASI_CRM_Contract__c = :currentHeaderId];

            for (ASI_CRM_Module__c module : ModuleList){
                if (module.ASI_CRM_CN_Contract_Volume_Base__c == 'POS'){
                    isPOS = true;
                }
            }

            //get total mark up
            TotalMarkup = 1;
            if(ContractSelected.Modules__r.size()>0){
                TotalMarkup = ContractSelected.Modules__r[0].ASI_CRM_CN_Total_Markup__c != null ? 1+ContractSelected.Modules__r[0].ASI_CRM_CN_Total_Markup__c/100 : 1;
            }

            if(CutOffDay > ContractSelected.ASI_CRM_CN_PO_End_Date__c){
                CutOffDay = ContractSelected.ASI_CRM_CN_PO_End_Date__c;
            }
            VolPeriodStr =  ASI_CRM_DateUtilClass.toDMY(StartDate) + ' - ' + ASI_CRM_DateUtilClass.toDMY(CutOffDay);
            POPeriodStr= ASI_CRM_DateUtilClass.toDMY(ContractSelected.ASI_CRM_CN_PO_Start_Date__c) + ' - ' + ASI_CRM_DateUtilClass.toDMY(ContractSelected.ASI_CRM_CN_PO_End_Date__c);
            init_Contractdata();
            init_SubBrandVolumeData();

            try{
                noData = false;
            } catch (Exception e){
                noData = true;
            }
        } else {
            ContractSelected = new ASI_TH_CRM_Contract__c();
            noData = true;
        }


        return true;
    }


    public void init_Contractdata() {
        //Finding V0.0 contract Id
        String v0ContractId = '';
        String strRegion = '';
        String CommercialTeam = '';
        ContractPeriod = ASI_CRM_DateUtilClass.monthDiff(StartDate, CutOffDay);
        if (ContractSelected != null && ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != null) {
            v0ContractId = ContractSelected.ASI_CRM_CN_V0_0_PO_version__c;
            strRegion = ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c : '';
            CommercialTeam = ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c != null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c : '';
        } else {
            v0ContractId = ContractSelected.Id;
            strRegion = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? String.valueOf(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c) : '';
            CommercialTeam = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c != null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c : '';


        }

        SubBrandExcludeSet = new Set<Id>();

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
                ASI_CRM_CN_Sub_Brand__r.Id,
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
                ASI_CRM_CN_Total_Volume_9L__c ,
                ASI_CRM_CN_Pack_Size__c ,
                ASI_CRM_CN_Drop_In__c
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
            WHERE ASI_CRM_CN_Contract__c = :v0ContractId
            AND ASI_CRM_Type__c = 'BRSF'
        ];

        subBrandPackSizeMap = new Map<Id ,String>();
        subBrandDropInMap = new Map<Id ,Boolean>();
        WSOutletIds = new Set<Id>();
        //List<ASI_CRM_CN_Covered_Outlet__c> coveredOutlets = ASI_CRM_CN_PromotionContractUtilClass.getCoveredOutlets(ContractSelected.Id, ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'WS Promotion' ? 'ASI_CRM_CN_WS' : 'ASI_CRM_CN_WS');

        //Build SubBrand Outlet WS map
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractLineList) {

            if(ContractLine.ASI_CRM_CN_Sub_Brand__c == null) continue;

            System.debug('ContractLine.ASI_CRM_CN_Sub_Brand__c ==' + ContractLine.ASI_CRM_CN_Sub_Brand__c);
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
//            for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutlets) {
//                System.debug('key ' + ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c + coveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CRM_Code__c);
//                interimData d = new interimData();
//                d.subBrand = ContractLine.ASI_CRM_CN_Sub_Brand__r;
//                d.outlet = coveredOutlet.ASI_CRM_CN_Outlet__r;
//
//                interimDataMap.put(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c + coveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_CRM_Code__c, d);
//            }
            interimData d = new interimData();
            d.subBrand = ContractLine.ASI_CRM_CN_Sub_Brand__r;
            //d.volume9LV0 = ContractLine.ASI_CRM_CN_Total_Volume_9L__c;
            d.volume9LV0 = ContractLine.ASI_CRM_CN_Total_Volume_9L__c != null ? ContractLine.ASI_CRM_CN_Total_Volume_9L__c : 0;
            d.purchaseValueV0 = ContractLine.ASI_CRM_CN_Contract_Purchase_Value__c != null ? ContractLine.ASI_CRM_CN_Contract_Purchase_Value__c : 0;
            interimDataMap.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, d);
            interimDataSortMap.put(ContractLine.Id,ContractLine.ASI_CRM_CN_Sub_Brand__c);
        }

        
        List<ASI_CRM_CN_Covered_Outlet__c> coveredOutlets = ASI_CRM_CN_PromotionContractUtilClass.getCoveredOutlets(ContractSelected.Id, this.ContractSelected.ASI_CRM_CN_Data_Source__c == 'WS Intake' ? 'ASI_CRM_CN_WS' :'ASI_CRM_Outlet_CN');
        if(coveredOutlets.size()>0){
            for(ASI_CRM_CN_Covered_Outlet__c outlet : coveredOutlets){
                WSOutletIds.add(outlet.ASI_CRM_CN_Outlet__r.Id);
                interimData d = new interimData();
                d.outlet = outlet.ASI_CRM_CN_Outlet__r;
                d.volume9LV0 = outlet.ASI_CRM_CN_Target_Volume_9L__c != null ? outlet.ASI_CRM_CN_Target_Volume_9L__c : 0;
                d.purchaseValueV0 = outlet.ASI_CRM_CN_Target_Value__c != null ? outlet.ASI_CRM_CN_Target_Value__c : 0;
                OutletDataMap.put(outlet.ASI_CRM_CN_Outlet__c, d);
                OutletDataSortMap.put(outlet.Id,outlet.ASI_CRM_CN_Outlet__c);
            }
        }

    }

    //Loading WS/Outlet Sub-brand Volume
    public void init_SubBrandVolumeData(){
        Set<Id> OutletIdSet = generatingOutletId();
        Set<Id> SubBrandIdSet = new Set<Id>();
        for(String key : interimDataMap.keySet()){
            if(key != null && key != '')
            {
                Id subBrandId = Id.valueOf(key);
                SubBrandIdSet.add(subBrandId);
            }
        }

        // List<ASI_CRM_Subbrand_Volume__c> volumes = new List<ASI_CRM_Subbrand_Volume__c>(); 
        //getSubbrandVolume(OutletIdSet);

        // List<ASI_CRM_Exclude_Item_Group_Volume__c> exclusions = new List<ASI_CRM_Exclude_Item_Group_Volume__c>(); 
        //getSubbrandVolume(OutletIdSet);

        String excludeQuery = 'select ' + exclusionFieldList() + ' From ASI_CRM_Exclude_Item_Group_Volume__c';
        excludeQuery += ' Where ASI_CRM_Sub_Brand__c != null '+ ' ' +
                        ' and ASI_CRM_Sub_Brand__c in: SubBrandExcludeSet'+ ' ' +
                        ' and ASI_CRM_End_Date__c >=' + String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
                        ' and ASI_CRM_End_Date__c <=' + String.valueOf(CutOffDay) + ' ' +
                        ' and (ASI_CRM_Account__c in: OutletIdSet or ASI_CRM_Outlet__c in: OutletIdSet)'+ ' ' +
                        ' and ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Exclusion__c = true';

        String subBrandVolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
        subBrandVolumeQuery += 'WHERE ASI_CRM_Subbrand__c !=null ' +
            'AND ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
            'AND ASI_CRM_End_Date__c >= ' + String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
            'AND ASI_CRM_End_Date__c <= ' + String.valueOf(CutOffDay) + ' ' +
            'AND ASI_CRM_Subbrand__c IN :SubBrandIdSet ' +
            'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = false ';

        /*if (OutletIdSet.size() >= ASI_CRM_CN_PromotionContractUtilClass.outletThreshold()){
            subBrandVolumeQuery += 'AND ASI_CRM_CN_Contract__c = \'' + ContractSelected.Id + '\' ' +
                'AND recordtypeId = \'' + Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')+'\' ';


        } else {
            subBrandVolumeQuery += 'AND ASI_CRM_Account__c !=null ' +
                'AND ASI_CRM_Account__c IN :OutletIdSet ' +
                'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';

        }*/

        subBrandVolumeQuery += 'AND ASI_CRM_Account__c !=null ' +
                'AND ASI_CRM_Account__c IN :OutletIdSet ' +
                'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';

        if(Test.isRunningTest()) subBrandVolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
        System.debug('subBrandVolumeQuery: ' + subBrandVolumeQuery);
        System.debug('excludeQuery: ' + excludeQuery);

        // volumes = Database.query(subBrandVolumeQuery);
        // exclusions = Database.query(excludeQuery);

        Decimal AccSum = 0;
        Decimal SubSum = 0;
        //Sub-brand Volume
        for (ASI_CRM_Subbrand_Volume__c volume : Database.query(subBrandVolumeQuery)){
            //String key = volume.ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c + volume.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c;
            String SubBrandkey = volume.ASI_CRM_Subbrand__c;
            String Outletkey = volume.ASI_CRM_Account__c;

            if (interimDataMap.containsKey(SubBrandkey)) {
                Decimal orginalTotal = interimDataMap.get(SubBrandkey).volume9L;
                interimDataMap.get(SubBrandkey).addVolume(volume, this.ContractSelected.ASI_CRM_CN_Data_Source__c, TotalMarkup);
                SubSum += interimDataMap.get(SubBrandkey).volume9L - orginalTotal;
            }

            if(OutletDataMap.containsKey(Outletkey)){
                Decimal orginalTotal = OutletDataMap.get(Outletkey).volume9L;
                OutletDataMap.get(Outletkey).addVolume(volume, this.ContractSelected.ASI_CRM_CN_Data_Source__c, TotalMarkup);
                AccSum += OutletDataMap.get(Outletkey).volume9L - orginalTotal;
                system.debug('OutletDataMap.get(Outletkey).volume9L ' + OutletDataMap.get(Outletkey).volume9L+ 'exclude.Id==='+volume.Id);
            }

            system.debug('SubSum ===='+SubSum +'----AccSum ==='+AccSum + 'exclude.Id==='+volume.Id);

        }

        Map<String ,ASI_CRM_Volume_Aggregation_Breakdown__c> outletPromotionMap = new Map<String ,ASI_CRM_Volume_Aggregation_Breakdown__c>();
        Boolean isSouthRegion = ContractSelected.ASI_CRM_CN_Region__c == 'South Region';

        if (isSouthRegion && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion') 
        {
            List<ASI_CRM_Volume_Aggregation_Breakdown__c> subBrandVolumeBreakdowns = ASI_CRM_CN_PromotionPaymentCtrl.retrieveSubBrandVolumeBreakdown(ContractSelected.ASI_CRM_CN_PO_Start_Date__c, CutOffDay, OutletIdSet,SubBrandExcludeSet);
            for(ASI_CRM_Volume_Aggregation_Breakdown__c breakdown :subBrandVolumeBreakdowns){
                String strKey = breakdown.ASI_CRM_Sub_brand_Volume__r.ASI_CRM_Account__c+';'+breakdown.ASI_CRM_Outlet_Sub_brand_Volume__r.ASI_CRM_Account__c;
                outletPromotionMap.put(strKey,breakdown);
            }
        }
        AccExcludeSum = 0;
        SubExcludeSum = 0;
        // system.debug('数据长度 =='+exclusions.size());


        for (ASI_CRM_Exclude_Item_Group_Volume__c exclude : Database.query(excludeQuery))
        {
            String SubBrandkey = exclude.ASI_CRM_Sub_Brand__c;
            String Outletkey = exclude.ASI_CRM_Outlet__c;
            String Wholesalerkey = exclude.ASI_CRM_Account__c;

            system.debug('是否属于outlet promotion' + (isSouthRegion && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion') + '----'+exclude.Id);

            if(outletPromotionMap.size() > 0)
            {
                system.debug('是否包含---'+(outletPromotionMap.containsKey(Wholesalerkey+';'+Outletkey)));
                if(isSouthRegion && ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && !outletPromotionMap.containsKey(Wholesalerkey+';'+Outletkey))
                {
                    continue;
                }
            }



            String BRSF_PackSize = (subBrandPackSizeMap.containsKey(exclude.ASI_CRM_Sub_Brand__c) ?
                                                subBrandPackSizeMap.get(exclude.ASI_CRM_Sub_Brand__c) : '');
            Boolean isDropIn = (subBrandDropInMap.containsKey(exclude.ASI_CRM_Sub_Brand__c) ?
                                subBrandDropInMap.get(exclude.ASI_CRM_Sub_Brand__c) : false);

            /*
                执行以subbrand进行计算

             */
            if(interimDataMap.containsKey(SubBrandkey))
            {
                interimData inter = interimDataMap.get(SubBrandkey);
                
                // // exclusion的 outlet / wholesaler与数据中的客户不相符，则排除
                // if(inter.outlet.ASI_CRM_CN_CRM_Code__c == null 
                //     || (inter.outlet.ASI_CRM_CN_CRM_Code__c != exclude.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c && inter.outlet.ASI_CRM_CN_CRM_Code__c != exclude.ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c)) continue; 

                if(!isFlag(BRSF_PackSize ,isDropIn ,exclude))
                {
                    Decimal orginalTotal = inter.volume9L;
                    inter.exclusionVolume(exclude , this.ContractSelected.ASI_CRM_CN_Data_Source__c, TotalMarkup);
                    SubExcludeSum += orginalTotal - inter.volume9L;
                }

            }
            

            if(OutletDataMap.containsKey(Outletkey)){
                interimData inter = OutletDataMap.get(Outletkey);

                // exclusion 的subbrand与数据的subbrand不相符，则排除
                // if(inter.subBrand.Id != exclude.ASI_CRM_Sub_Brand__c) continue;

                if(!isFlag(BRSF_PackSize ,isDropIn ,exclude))
                {
                    Decimal orginalTotal = inter.volume9L;
                    inter.exclusionVolume(exclude , this.ContractSelected.ASI_CRM_CN_Data_Source__c, TotalMarkup);
                    AccExcludeSum += orginalTotal - inter.volume9L;
                }
            }
            else if(OutletDataMap.containsKey(Wholesalerkey)){
                interimData inter = OutletDataMap.get(Wholesalerkey);

                // exclusion 的subbrand与数据的subbrand不相符，则排除
                // if(inter.subBrand.Id != exclude.ASI_CRM_Sub_Brand__c) continue;

                if(!isFlag(BRSF_PackSize ,isDropIn ,exclude))
                {
                    Decimal orginalTotal = inter.volume9L;
                    inter.exclusionVolume(exclude , this.ContractSelected.ASI_CRM_CN_Data_Source__c, TotalMarkup);
                    AccExcludeSum += orginalTotal - inter.volume9L;
                }
            }
            system.debug('SubExcludeSum ===='+SubExcludeSum +'----AccExcludeSum ==='+AccExcludeSum + 'exclude.Id==='+exclude.Id);
            
        }

        system.debug('SubExcludeSum ===='+SubExcludeSum +'----AccExcludeSum ==='+AccExcludeSum);

    }

    public Boolean isFlag(String BRSF_PackSize ,boolean isDropIn ,ASI_CRM_Exclude_Item_Group_Volume__c exclude)
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
       
        if((itemFlag && isDropIn 
            && exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c) || Test.isRunningTest())
        {
            itemFlag = false;
        }
        system.debug('BRSF_PackSize =='+ BRSF_PackSize +'---clude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c =='+ exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c);
        system.debug('isDropIn =='+ isDropIn +'---clude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c =='+ exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c);
        system.debug('结果是  ' + itemFlag + '---');
        return itemFlag;

    }

    public DataClass testMethod1()
    {
        DataClass daClass = new DataClass();
        return daClass;
    }

    public DataClass AlignDataClassSBInfo (DataClass InputDataClass, DataClass AddSourceDataClass){
        InputDataClass.sbgrade = AddSourceDataClass.sbgrade;
        InputDataClass.sbname = AddSourceDataClass.sbname;
        return InputDataClass;
    }


    public DataClass AddIntakeDataClass (DataClass InputDataClass, DataClass AddSourceDataClass){
        InputDataClass.IntakeVol+= AddSourceDataClass.IntakeVol;
        InputDataClass.IntakeVolCR12 += AddSourceDataClass.IntakeVolCR12;
        InputDataClass.IntakeValue += AddSourceDataClass.IntakeValue;
        return InputDataClass;
    }

    public DataClass AddOfftakeDataClass (DataClass InputDataClass, DataClass AddSourceDataClass){
        InputDataClass.OffTakeVol += AddSourceDataClass.OffTakeVol;
        InputDataClass.OffTakeVolCR12 += AddSourceDataClass.OffTakeVolCR12;
        InputDataClass.OfftakeValue+= AddSourceDataClass.OfftakeValue;
        return InputDataClass;
    }


    //If BRSF Volume Base = POS, override OffTakeVolume with POS data
    public DataClass CalculatingVolume(Boolean isPOS, ASI_CRM_Subbrand_Volume__c sbtemp){
        DataClass ReturnData = new DataClass();
        ReturnData.sbname=sbtemp.ASI_CRM_Subbrand__r.Name;
        ReturnData.sbgrade=sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
        ReturnData.GradeSequence = Integer.valueOf(sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c);
        ReturnData.ConversionFactorCR12 = sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null ? sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c : 0;

        if (isPOS) {
            ReturnData.OffTakeVol = sbtemp.ASI_CRM_POS_Std_Billing__c!=null? sbtemp.ASI_CRM_POS_Std_Billing__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OffTakeVolCR12 = sbtemp.ASI_CRM_POS_CR12__c!=null? sbtemp.ASI_CRM_POS_CR12__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OfftakeValue = sbtemp.ASI_CRM_POS_GS__c!=null? sbtemp.ASI_CRM_POS_GS__c.round(System.RoundingMode.FLOOR): 0;
        } else {
            ReturnData.OffTakeVol = sbtemp.ASI_CRM_Offtake_Std_Billing__c!=null? sbtemp.ASI_CRM_Offtake_Std_Billing__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OffTakeVolCR12 = sbtemp.ASI_CRM_Offtake_CR12__c!=null? sbtemp.ASI_CRM_Offtake_CR12__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OfftakeValue = sbtemp.ASI_CRM_Offtake_GS__c!=null? sbtemp.ASI_CRM_Offtake_GS__c.round(System.RoundingMode.FLOOR): 0;
        }

        ReturnData.IntakeVol += sbtemp.ASI_CRM_Actual_Vol_STD__c.round(System.RoundingMode.FLOOR);
        ReturnData.IntakeVolCR12 += sbtemp.ASI_CRM_Actual_Vol_CR12__c.round(System.RoundingMode.FLOOR);
        ReturnData.IntakeValue += sbtemp.ASI_CRM_Intake_GS__c!=null? sbtemp.ASI_CRM_Intake_GS__c: 0;

        return ReturnData;
    }







    private Set<Id> generatingOutletId(){
        List<ASI_CRM_CN_Covered_Outlet__c>  CoveredOutlet_List = new List<ASI_CRM_CN_Covered_Outlet__c>();
        String developerName = this.ContractSelected.ASI_CRM_CN_Data_Source__c == 'WS Intake' ? 'ASI_CRM_CN_WS' :'ASI_CRM_Outlet_CN';
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


//        if (ContractSelected.ASI_CRM_Volume_Option__c == 'Normal' ||
//            ContractSelected.ASI_CRM_Volume_Option__c == 'Wholesaler Only' ||
//            ContractSelected.ASI_CRM_Volume_Option__c == null){
//            OutletIdSet.add(ContractSelected.ASI_CRM_CN_Outlet_WS__c);
//            String ChiName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c!=null?ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c:ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name;
//            DataClass TempData= new DataClass();
//            OutletSummaryList_Map.put(ChiName,TempData);
//        }
//
//        if (ContractSelected.ASI_CRM_Volume_Option__c == 'Normal' || ContractSelected.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || ContractSelected.ASI_CRM_Volume_Option__c == null){
//            for (ASI_CRM_CN_Covered_Outlet__c co_temp : CoveredOutlet_List){
//                OutletIdSet.add(co_temp.ASI_CRM_CN_Outlet__c);
//                String ChiName=co_temp.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c!=null? co_temp.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c:co_temp.ASI_CRM_CN_Outlet__r.Name;
//                if(!OutletSummaryList_Map.containsKey(ChiName)){
//                    DataClass TempData= new DataClass();
//                    OutletSummaryList_Map.put(ChiName,TempData);
//                }
//            }
//        }

        for (ASI_CRM_CN_Covered_Outlet__c co_temp : CoveredOutlet_List){
            OutletIdSet.add(co_temp.ASI_CRM_CN_Outlet__c);
        }

        return OutletIdSet;

    }




    public Decimal DataRounding(Decimal InputData){
        InputData=InputData!=null?InputData.setScale(0):0;
        return InputData;
    }

    public Decimal DataRounding(Decimal InputData, Integer setScale){
        InputData=InputData!=null?InputData.setScale(setScale):0;
        return InputData;
    }

    //1 level
    public class interimData{
        public ASI_MFM_Sub_brand__c subBrand {set;get;}
        public  ASI_CRM_AccountsAdditionalField__c outlet {set;get;}
        public Decimal volume9L {set;get;} {volume9L = 0;}
        public Decimal purchaseValue {set;get;} {purchaseValue = 0;}
        public Decimal volume9LV0 {set;get;} {volume9LV0 = 0;}
        public Decimal purchaseValueV0 {set;get;} {purchaseValueV0 = 0;}

        public interimData(){}

//        public void addVolume(ASI_CRM_Subbrand_Volume__c volume){
//            volume9L += volume.ASI_CRM_Actual_Vol_9L__c != null ? volume.ASI_CRM_Actual_Vol_9L__c : 0;
//            purchaseValue += volume.ASI_CRM_T2_Depletion_GS__c != null ? volume.ASI_CRM_T2_Depletion_GS__c : 0;
//        }

        public void addVolume(ASI_CRM_Subbrand_Volume__c volume, String dataSource, Decimal TotalMarkup){
            if(dataSource == 'POS'){
                volume9L += volume.ASI_CRM_POS_9L__c != null ? volume.ASI_CRM_POS_9L__c : 0;
                purchaseValue += volume.ASI_CRM_POS_GS__c != null ? volume.ASI_CRM_POS_GS__c * TotalMarkup : 0;
            }/*else if(dataSource == 'WS Intake'){
                volume9L += volume.ASI_CRM_T1_Depletion__c != null ? volume.ASI_CRM_T1_Depletion__c : 0;
                //purchaseValue += volume.ASI_CRM_T1_Depletion_GS__c != null ? volume.ASI_CRM_T1_Depletion_GS__c : 0;
                purchaseValue += volume.ASI_CRM_CN_Intake_GS_T1_Price__c != null ? volume.ASI_CRM_CN_Intake_GS_T1_Price__c * TotalMarkup : 0;
            }*/else {
                volume9L += volume.ASI_CRM_Actual_Vol_9L__c != null ? volume.ASI_CRM_Actual_Vol_9L__c : 0;
                //purchaseValue += (volume.ASI_CRM_T1_Depletion_GS__c != null ? volume.ASI_CRM_T1_Depletion_GS__c : 0) + (volume.ASI_CRM_T2_Depletion_GS__c != null ? volume.ASI_CRM_T2_Depletion_GS__c : 0) + (volume.ASI_CRM_PR_DIRECT_GS__c != null ? volume.ASI_CRM_PR_DIRECT_GS__c : 0);
                purchaseValue += ((volume.ASI_CRM_CN_Intake_GS_T1_Price__c != null ? volume.ASI_CRM_CN_Intake_GS_T1_Price__c * TotalMarkup : 0) - (volume.ASI_CRM_CN_Volume_Out_GS_Price__c != null? volume.ASI_CRM_CN_Volume_Out_GS_Price__c:0));
            }
        }


        public void exclusionVolume(ASI_CRM_Exclude_Item_Group_Volume__c volume, String dataSource, Decimal TotalMarkup){
            if(dataSource == 'POS'){
                volume9L -= volume.ASI_CRM_POS_9L__c != null ? volume.ASI_CRM_POS_9L__c : 0;
                purchaseValue -= volume.ASI_CRM_POS_GS__c != null ? volume.ASI_CRM_POS_GS__c * TotalMarkup : 0;
            }else {
                if(dataSource == 'WS Intake')
                {
                    system.debug('volume9L===='+volume9L+'-------'+volume.ASI_CRM_Actual_Vol_9L__c);
                    volume9L = ExcludeJudge(volume9L ,volume.ASI_CRM_Actual_Vol_9L__c);
                    system.debug('volume9L===='+volume9L);
                    purchaseValue -= volume.ASI_CRM_CN_Intake_GS_T1_Price__c != null ? volume.ASI_CRM_CN_Intake_GS_T1_Price__c * TotalMarkup : 0;
                }
                else 
                {
                    volume9L = ExcludeJudge(volume9L ,volume.ASI_CRM_Depletion__c);
                    purchaseValue -= volume.ASI_CRM_Depletion_GS_T1_Price__c != null ? volume.ASI_CRM_Depletion_GS_T1_Price__c * TotalMarkup : 0;
                }


                //volume9L -= volume.ASI_CRM_Actual_Vol_9L__c != null ? volume.ASI_CRM_Depletion__c : 0;
                //purchaseValue += (volume.ASI_CRM_T1_Depletion_GS__c != null ? volume.ASI_CRM_T1_Depletion_GS__c : 0) + (volume.ASI_CRM_T2_Depletion_GS__c != null ? volume.ASI_CRM_T2_Depletion_GS__c : 0) + (volume.ASI_CRM_PR_DIRECT_GS__c != null ? volume.ASI_CRM_PR_DIRECT_GS__c : 0);
                
            }
        }
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
        ExcludeResult = orginal - exclude;
        // if(orginal < exclude)
        // {
        //     ExcludeResult = 0;
        // }
        // else
        // {
        //     ExcludeResult = orginal - exclude;
        // }
        return ExcludeResult;
    }

    //2 Level- Base data structure
    public class DataClass{
        public String sbname {get; set;}{sbname='';}
        public String sbgrade {get; set;}{sbgrade='';}
        public Integer GradeSequence {get; set;}  {GradeSequence=9;}

        public Decimal TargetVol {get; set;} {TargetVol=0;}
        public Decimal OffTakeVol {get; set;} {OffTakeVol=0;}
        public Decimal IntakeVol {get; set;} {IntakeVol=0;}

        public Decimal TargetValue {get; set;} {TargetValue=0;}
        public Decimal OfftakeValue {get; set;} {OfftakeValue=0;}
        public Decimal IntakeValue {get; set;} {IntakeValue=0;}

        public Decimal ConversionFactorCR12 {get; set;}

        public Decimal TargetVolCR12 {
            get{
                return convertStdToCR12(TargetVol);
            }
            private set;
        }
        public Decimal OffTakeVolCR12 {get; set;} {OffTakeVolCR12=0;}
        public Decimal IntakeVolCR12 {get; set;} {IntakeVolCR12=0;}


        /*
        public decimal OffTakeVolCR12 {
            get{
                return convertStdToCR12(OffTakeVol);
            }
            private set;
        }
        public decimal IntakeVolCR12 {
            get{
                return convertStdToCR12(IntakeVol);
            }
            private set;
        }
        */

        public Decimal IntakeVSContractVolPercentage {
            get {
                return ratio(this.IntakeVol,this.TargetVol);
            }
            private set;
        }

        public Decimal OffTakeVSIntakeVolPercentage {
            get {
                return ratio(this.OffTakeVol,this.IntakeVol);
            }
            private set;
        }

        public Decimal IntakeVSContractValuePercentage {
            get {
                return ratio(this.IntakeValue,this.TargetValue);
            }
            private set;
        }

        public Decimal OffTakeVSIntakeValuePercentage {
            get {
                return ratio(this.OfftakeValue,this.IntakeValue);
            }
            private set;
        }

        private Decimal convertStdToCR12(Decimal std){
            return (this.ConversionFactorCR12 != null) ? std * ConversionFactorCR12 : 0;
        }

        private Decimal ratio(Decimal numerator, Decimal denominator){
            return (denominator != 0) ? numerator/denominator*100 : 0;
        }

        public DataClass(){}
    }

    public DataClass CopyDataClass(DataClass InputCalVolume){
        DataClass TempVolumeData = new DataClass();

        TempVolumeData.sbgrade= InputCalVolume.sbgrade;
        TempVolumeData.sbname= InputCalVolume.sbname;
        TempVolumeData.GradeSequence = InputCalVolume.GradeSequence;
        TempVolumeData.ConversionFactorCR12 = InputCalVolume.ConversionFactorCR12;

        TempVolumeData.TargetVol= InputCalVolume.TargetVol;
        TempVolumeData.OffTakeVol= InputCalVolume.OffTakeVol;
        TempVolumeData.IntakeVol= InputCalVolume.IntakeVol;

        TempVolumeData.OffTakeVolCR12 = InputCalVolume.OffTakeVolCR12;
        TempVolumeData.IntakeVolCR12 = InputCalVolume.IntakeVolCR12;

        TempVolumeData.TargetValue= InputCalVolume.TargetValue;
        TempVolumeData.OfftakeValue= InputCalVolume.OfftakeValue;
        TempVolumeData.IntakeValue= InputCalVolume.IntakeValue;

        return TempVolumeData;
    }



    public Map<String, String> mapStringMonth = new Map<String, String>{
        '01'=>'Jan',
        '02'=>'Feb',
        '03'=>'Mar',
        '04'=>'Apr',
        '05'=>'May',
        '06'=>'Jun',
        '07'=>'Jul',
        '08'=>'Aug',
        '09'=>'Sept',
        '10'=>'Oct',
        '11'=>'Nov',
        '12'=>'Dec',
        '1'=>'Jan',
        '2'=>'Feb',
        '3'=>'Mar',
        '4'=>'Apr',
        '5'=>'May',
        '6'=>'Jun',
        '7'=>'Jul',
        '8'=>'Aug',
        '9'=>'Sept'
    };

    public static Date VolumeCutOffDate(Integer strDay, Date defaultDate, Date startdate){
        Date returnDate;
        Integer strDate = Date.today().day();
        Integer strMonth;
        Integer strEndDay;

        if (defaultDate != null && startdate != null && strDay != null){
            if (strDay != 0){
                returnDate = ASI_CRM_DateUtilClass.getCutOffDate(strDay);
                if (returnDate < startdate){
                    return null;
                }
                if (returnDate >= defaultDate){
                    returnDate = defaultDate;
                }
            }else{
                returnDate = defaultDate;
            }
        }
        return returnDate;
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
            'ASI_CRM_POS_9L__c',
            'ASI_CRM_PR_DIRECT_GS__c',
            'ASI_CRM_CN_Intake_GS_T1_Price__c',
            'ASI_CRM_CN_Volume_Out_GS_Price__c'

        };
        return String.join(fieldList,',');
    }


}