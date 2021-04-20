/***************************************************************************************************************************
* Name:        ASI_CRM_CN_OffContractGenerationCtrl
* Description: Controller Class for Off Contract Generation Page
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-08-30       Hector Tsang         Created
****************************************************************************************************************************/

global class ASI_CRM_CN_OffContractGenerationCtrl {

    //Wrapper Class for storing all section
    public class SectionWrapper {
        public String name {get; set;}{name='';}
        public String style {get; set;}{style='';}
        public String content {get; set;}{content='';}
        public String content_original {get; set;}{content_original='';}
        public String LeftContent {get; set;}{LeftContent='';}
        public String RightContent {get; set;}{RightContent='';}
        public String displayNumber {get; set;}{displayNumber='';}
        public String ClassName {get; set;}{ClassName='';}
        public String type {get; set;}{type='';}
        public Map<integer, SectionWrapper> subSectionMap {get; set;}{subSectionMap= new Map<integer, SectionWrapper>();}
        public Boolean hasSubSection {get; set;} {hasSubSection=false;}
        public Boolean isShow {get; set;}
        public Boolean checked {get; set;}
        public SectionWrapper() {}
        
        public SectionWrapper(String name, String content, String style,String displayNumber, String ClassName, String type, Map<integer, SectionWrapper> subSectionMap, Boolean checked) {
            this.name = name;
            this.content = content.trim();
            this.content_original = content.trim();
            this.style= style;
            this.displayNumber = displayNumber;
            this.ClassName = ClassName;
            this.type = type;
            this.subSectionMap = subSectionMap;

            if(subSectionMap == null || subSectionMap.size() == 0) {
                hasSubSection = false;
            } else {
                hasSubSection = true;
            }

            isShow = true;
            this.checked = checked;
        }
        public void hideSectionWrapper(){
            this.content = '';
            this.displayNumber='';
            this.isShow= false;
            this.type = 'Read';
        }
        public void hideSectionWrapperRecursive(){
            hideSectionWrapper();
            if (this.hasSubSection){
                for(integer ChildKey : this.subSectionMap.keySet()){
                    this.subSectionMap.get(ChildKey).hideSectionWrapperRecursive();
                }
            }
        }
    }

    public class SectionType{
        public Integer ColumnNumber {set;get;} {ColumnNumber=0;}
        public String VolumeBase {set;get;}{VolumeBase='';}
        public Integer StyleStringColumnNum {set;get;} {StyleStringColumnNum=0;}
        public String StyleString {set;get;} {StyleString='';}
        public Integer ClassTypeColumnNum {set;get;} {ClassTypeColumnNum=0;}
        public String ClassType {set;get;} {ClassType='';}
        public Map<Integer,String> TableStyleMap {set;get;} {TableStyleMap= new Map<Integer,String>();}
        public List<String> additionalInfo {get; set;} {additionalInfo = new List<String>();}
        public SectionType(){}
    }

    //Store Module Information
    public class interimData{
        public String VolumeBase  {get;set;} {VolumeBase = '';}
        public String Methodology {get;set;} {Methodology = '';}
        public String Criteria    {get;set;} {Criteria = '';}
        public Decimal MinAchievement {get;set;} {MinAchievement = 0;}
        public String Remarks {get; set;} {Remarks = '';}
        public map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap{set;get;}{DetailLineMap=new map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();}
        public interimData(){}
    }

    public String ContractModuleBase {get;set;} {ContractModuleBase = '';}

    public String xmlStringTestClass {get; set;}{xmlStringTestClass='';}
    public String contractId   {get; set;}
    public Boolean isEditable  {get; set;}
    public String partName   {get; set;}
    public String TodayString  {get; set;}{TodayString='';}
    public Boolean Highlight {get; set;}
    public String OutletArea {get;set;}  //CanterDuan 2019/12/4 记录contract的outlet的区域用于判断服务需求的显示
    public String PartyBLegalName='';
    public Boolean IsApprovedVersion {get; set;} {IsApprovedVersion=false;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public Map<integer, SectionWrapper> headerSectionMap   {get; set;}
    public Map<integer, SectionWrapper> BodySectionMap     {get; set;}
    public Map<integer, SectionWrapper> BodySignatureMap     {get; set;}
    public Map<integer, SectionWrapper> AppendixSectionMap {get; set;}
    public Map<integer, SectionWrapper> AppendixSignatureMap {get; set;}
    private Map<String, String> ContractSettingMap   {get; set;}{ContractSettingMap= new Map<String, String>();}
    private Integer BodyContentCuttingNumber = 38;
    private Integer InnerContentCuttingNumber = 36;
    private Set<String> KeySubBrandSet = new Set<String> ();
    public Boolean ExistTwoParty   {get; set;}{ExistTwoParty=false;}
    private Set<String> PartyBIDSet = new Set<String> ();
    public ASI_CRM_CN_OffContractGenerationCtrl() {}
    //Set of Characters that not allowed to be first character after linebreak
    private String reservedPattern = '[.,;。，、:：；　 \'"/）)]';
    private static final String newTableRow = '<tr>';
    private static final String newTableCell = '<td style="border: 1px solid black;">';
    private static final String endTableRow = '</tr>';
    private static final String endTableCell = '</td>';
    private static final String endTable = '</table>';
    private static final String lineBreak = '<br/>';
    private List<ASI_CRM_CN_Covered_Outlet__c> CoveredOutletList = new List<ASI_CRM_CN_Covered_Outlet__c>();
    private Map<String, Integer> FixedCostItemSequenceMap = new Map<String, Integer>{
            '新品进场费/产品条码费' => 1,
            '节庆店庆费' => 2,
            '店家支持' => 3,
            '店家价格促销' => 4,
            '数据分享扣点' => 5,
            '价格补偿' => 6,
            '其他固定费用' => 7
    };

    public static final String TABLE_TYPE_PER_INCENTIVE = 'PerIncentive';
    public static final String TABLE_TYPE_ACTUAL_ACHIEVEMENT = 'ActualAchievement';
    public static final String TABLE_TYPE_REACH_X_GET_Y = 'ReachXGetY';
    public static final String TABLE_TYPE_REBATE_PERCENTAGE = 'Rebate';
    public static final String TABLE_TYPE_REBATE_BY_LADDER = 'Ladder';
    public static final String TABLE_TYPE_REBATE_BY_TAX = 'Tax';
    public static final String TABLE_TYPE_OTHER = 'Other';

    public List<String> tableTypeList = new List<String>{
            TABLE_TYPE_PER_INCENTIVE,
            TABLE_TYPE_ACTUAL_ACHIEVEMENT,
            TABLE_TYPE_REACH_X_GET_Y,
            TABLE_TYPE_REBATE_PERCENTAGE,
            TABLE_TYPE_REBATE_BY_LADDER,
            TABLE_TYPE_REBATE_BY_TAX,
            TABLE_TYPE_OTHER
    };

    public static final String UNIT_CR12 = 'CR12 Extra Eqv.';
    public static final String UNIT_STDBTL = 'Std. Btl.';

    public static final String GROUPBASE_BY_SUBBRAND = 'BySubBrand';
    public static final String GROUPBASE_BY_CATEGORY = 'ByCategory';
    public static final String GROUPBASE_BY_TOTAL = 'ByTotal';
    public static final String GROUPBASE_BY_TOTAL_LADDER = 'Ladder';

    private static final Map<String, String> PSFHeaderMap = new Map<String, String>{
            'Per Incentive Btl;By Sub-Brand;NA' =>'PerIncentive',
            'Actual Achievement%;By Category;NA' =>'ActualAchievement',
            'Actual Achievement%;By Total;NA' =>'ActualAchievement',
            'Reach X get Y;By Sub-Brand;NA' =>'ReachXGetY',
            'Reach X get Y;By Category;NA' =>'ReachXGetY',
            'Reach X get Y;By Total;NA' =>'ReachXGetY',
            'Rebate%;By Sub-Brand;NA' =>'Rebate',
            'Rebate%;By Category;NA' =>'Rebate',
            'Rebate%;By Total;NA' =>'Rebate',
            'Rebate%(By Ladder);By Total;By Ladder' =>'Ladder',
            'Rebate%(By Tax);By Total;By Tax' =>'Tax',
            'Others;null;NA' => 'Other'
    };

    public String headerSectionMapString {
        get {
            return JSON.serialize(headerSectionMap);
        }
    }

    public String BodySectionMapString {
        get {
            return JSON.serialize(BodySectionMap);
        }
    }

    public String BodySignatureMapString {
        get {
            return JSON.serialize(BodySignatureMap);
        }
    }

    public String AppendixSectionMapString {
        get {
            return JSON.serialize(AppendixSectionMap);
        }
    }

    public String AppendixSignatureMapString {
        get {
            return JSON.serialize(AppendixSignatureMap);
        }
    }
    public Decimal PSFModule2Rebate {get;set;}
    public Decimal PSFModule2Min {get;set;}

    public Boolean init() {
        CoveredOutletList = new List<ASI_CRM_CN_Covered_Outlet__c>();

        TodayString=string.valueOf(system.today());
        IsApprovedVersion=false;
        //Finding Contract header
        ContractSelected = [SELECT Id,Name,
                ASI_CRM_CN_Bottle_Collection_Rate__c,
                ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Address__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__r.name,
                ASI_CRM_CN_Outlet_WS__r.Name,
                ASI_CRM_CN_PO_End_Date__c,
                ASI_CRM_CN_PO_No__c,
                ASI_CRM_CN_PO_Start_Date__c,
                ASI_CRM_CN_Status__c,
                ASI_CRM_CN_Two_Party_Contract_Template__c,
                ASI_CRM_Contract_Template_Id__c,
                ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,
                ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
                ASI_CRM_Martell_BC_Rate__c,
                ASI_TH_CRM_Promotion_Type__c,
                ASI_CRM_CN_Activity_Times__c,
                ASI_CRM_CN_Is_Dolphin__c,
                ASI_CRM_CN_Contract_Classification__c,
                ASI_CRM_CN_Target_Base__c
        FROM ASI_TH_CRM_Contract__c
        WHERE id =:contractId ];

        //2019/12/4 CanterDuan 记录outlet的区域 start
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__c != null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c != null){
            OutletArea = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c;
        }
        //2019/12/4 CanterDuan end
        if (ASI_CRM_CN_HeavyContracFunctionClass.GenerateOffContractTemplate(
                ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, true).Id != nuLL) {
            ExistTwoParty=true;
        }
        if (ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
            ExistTwoParty=false;
        }
        List<ASI_CRM_Contract_Printout_Setting__c> ContractSettingList =[select Id,ASI_CRM_Header_Section_Name__c,ASI_CRM_isVisible__c,ASI_CRM_Section_Content__c,ASI_CRM_Content_Section_Name__c from ASI_CRM_Contract_Printout_Setting__c where ASI_CRM_Contract__c = :contractId];
        for(ASI_CRM_Contract_Printout_Setting__c ContractSetting:ContractSettingList){
            String SectionContent = ContractSetting.ASI_CRM_Section_Content__c!=null? ContractSetting.ASI_CRM_Section_Content__c: '';

            ContractSettingMap.put(ContractSetting.ASI_CRM_Content_Section_Name__c,SectionContent);
            if(ContractSetting.ASI_CRM_Content_Section_Name__c.contains('PartyB')){

                PartyBIDSet.add(ContractSetting.ASI_CRM_Content_Section_Name__c);
            }
        }

        // Load Covered Outlet
        CoveredOutletList = [SELECT id, Name,
                ASI_CRM_CN_Contract__c,
                ASI_CRM_CN_Outlet__c,
                ASI_CRM_CN_Outlet__r.ASI_CRM_Account__c,
                ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Address__c,
                ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c,
                ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c,
                ASI_CRM_CN_Outlet__r.Name
        FROM ASI_CRM_CN_Covered_Outlet__c
        WHERE ASI_CRM_CN_Contract__c = :contractId];

        // Load XML template
        LoadDocumentFiles();

        // Load data from Contract Setting
        UpdateHeaderSectionMap();
        UpdateBodySectionMap();
        UpdatingBodySignatureMap();
        UpdateAppendixSectionMap();
        UpdatingAppendixSignatureMap();
        return true;
    }


    public void UpdateHeaderSectionMap(){
        Boolean IsReadOnly= (!isEditable);
        Map<String, String> params = ApexPages.currentPage().getParameters();
        /*
          * if(params.containsKey('ViewType')){
          * if(params.get('ViewType')=='Read'){
          * IsReadOnly=true;
          * }
          * }
          */

        for(integer key : headerSectionMap.keySet()) {
            String PartyAName='';
            // system.debug('IsReadOnly: ' + IsReadOnly);
            // system.debug('ContractSelected.ASI_CRM_CN_Status__c: ' + ContractSelected.ASI_CRM_CN_Status__c);
            // system.debug('Highlight: ' + Highlight);

            if(IsReadOnly)
            {
                headerSectionMap.get(key).hasSubSection = true;
            }
            if(headerSectionMap.get(key).name=='Sales and Branding Promotion Agreement'){
                if(IsReadOnly){
                    if(ContractSelected.ASI_CRM_CN_Status__c=='Approved'){
                        headerSectionMap.get(key).content+='(最终版)';
                        IsApprovedVersion=true;
                    }
                }else if(!Highlight){
                    if(ContractSelected.ASI_CRM_CN_Status__c!='Draft' && ContractSelected.ASI_CRM_CN_Status__c!='Submitted'){
                        headerSectionMap.get(key).content+='(最终版)';
                        IsApprovedVersion=true;
                    }
                }

            }
            if(headerSectionMap.get(key).name=='Party A' ){

                if(headerSectionMap.get(key).content.contains('{1}')){
                    if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
                        PartyAName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
                    }else{
                        PartyAName=ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
                    }
                    List<String> fillers = new String[] {'',PartyAName};
                    headerSectionMap.get(key).content = String.format(headerSectionMap.get(key).content, fillers);
                }else if(headerSectionMap.get(key).content.contains('{InputWholesaler}')){

                    headerSectionMap.get(key).content = headerSectionMap.get(key) != null ? headerSectionMap.get(key).content : '';

                    if (String.isBlank(headerSectionMap.get(key).content) ) {
                        headerSectionMap.get(key).content = '甲方：' + ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name;
                    }

                    // system.debug('Bowen == headerSectionMap.get(key).content  '+headerSectionMap.get(key).content);
                }
                //{InputWholesaler}
            }

            if(headerSectionMap.get(key).name=='Party B' ){
                List<String> fillers = new List<String>() ;
                fillers = new String[] {'',GeneratingPartyB_Header(false)  };
                headerSectionMap.get(key).content = String.format(headerSectionMap.get(key).content, fillers);

            }

            if(headerSectionMap.get(key).content.contains('{InputWholesaler}')){
                headerSectionMap.get(key).content = headerSectionMap.get(key).content.replace('{InputWholesaler}', GeneratingEffectiveSupplierInput(headerSectionMap.get(key).name,false) );
            }

            if(headerSectionMap.get(key).name=='Contract Date' ){
                List<String> DateFillers = new String[]{
                        '', String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.year()),
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.month()),
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()),
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.year()),
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.month()),
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.day())
                };

                // Only show date when "Preview as Approver"
                if (Highlight) {
                    headerSectionMap.get(key).content = String.format(headerSectionMap.get(key).content, DateFillers);
                } else {
                    headerSectionMap.get(key).content = '';
                }
            }

        }

        // System.debug('headerSectionMap:::' + headerSectionMap);
    }


    //*******************************************Main Body *******************************************
    public void UpdateBodySectionMap(){

        final Map<String, ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingsMap
                = getContractPrintoutSettingsMap(contractId);

        // final Map<String, ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingsMapBoolean
        //         = getContractPrintoutSettingsMapBoolean(contractId);

        System.debug(contractPrintoutSettingsMap.keyset());

        for(integer key : BodySectionMap.keySet()) {

            //Main Body Split Line
            BodySectionMap.get(key).content=BodySectionMap.get(key).content.replace('{District}',ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Chinese_Name__c);
            BodySectionMap.get(key).content=SplitLineIntoRow(BodySectionMap.get(key).content,BodyContentCuttingNumber);
            BodySectionMap.get(key).content=BodySectionMap.get(key).content.replace('/n','&nbsp;');

            //update date in the Body Section
            if(BodySectionMap.get(key).name!=null){
                if(BodySectionMap.get(key).name=='Terms of this Agreement' && ContractSelected.ASI_CRM_CN_PO_End_Date__c !=null && ContractSelected.ASI_CRM_CN_PO_Start_Date__c !=null){
                    List<String> fillers = new String[] {'',
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.year()),
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.month()),
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()),
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.year()),
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.month()),
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.day())
                    };

                    BodySectionMap.get(key).content = String.format(BodySectionMap.get(key).content, fillers);
                }
            }

            if(BodySectionMap.get(key).subSectionMap!=null){
                //Looping child content
                for(integer ChildKey : BodySectionMap.get(key).subSectionMap.keySet()){

                    // System.debug('subsection naem ::::' + BodySectionMap.get(key).subSectionMap.get(ChildKey).name);
                    // System.debug(BodySectionMap.get(key).subSectionMap.get(ChildKey).content);
                    // System.debug('----');
                    // Split Line** Do not change the order
                    BodySectionMap.get(key).subSectionMap.get(ChildKey).content=SplitLineIntoRow(BodySectionMap.get(key).subSectionMap.get(ChildKey).content, BodyContentCuttingNumber-5 );
                    BodySectionMap.get(key).subSectionMap.get(ChildKey).content=BodySectionMap.get(key).subSectionMap.get(ChildKey).content.replace('/n','&nbsp;');

                    if(BodySectionMap.get(key).subSectionMap.get(ChildKey).Name !=null ){
                        BodySectionMap.get(key).subSectionMap.get(ChildKey).content= ContentReplace( BodySectionMap.get(key).subSectionMap.get(ChildKey).content,BodySectionMap.get(key).subSectionMap.get(ChildKey).Name,BodySectionMap.get(key).subSectionMap.get(ChildKey).ClassName);
                        if(BodySectionMap.get(key).subSectionMap.get(ChildKey).type == 'Selectable'){
                            // system.debug('Selectable child : ' + BodySectionMap.get(key).subSectionMap.get(ChildKey).Name);
                            BodySectionMap.get(key).subSectionMap.get(ChildKey).isShow = CheckingIsVisibleOrNot(BodySectionMap.get(key).subSectionMap.get(ChildKey).Name);
                        }
                    }
                }
            }

            if (BodySectionMap.get(key).name != null && BodySectionMap.get(key).name == 'section4'){
                // System.debug('BodySectionMap.get(key):::' + BodySectionMap.get(key).name);
                // System.debug('BodySectionMap.get(key).content:::' + BodySectionMap.get(key).content);
                // System.debug('BodySectionMap.get(key).checked:::' + BodySectionMap.get(key).checked);
                final ASI_CRM_Contract_Printout_Setting__c printoutSetting = contractPrintoutSettingsMap.get(BodySectionMap.get(key).name+'Text');
                // System.debug('printoutSetting:::'+ printoutSetting);

                final ASI_CRM_Contract_Printout_Setting__c printoutSettingBoolean = contractPrintoutSettingsMap.get(BodySectionMap.get(key).name+'Boolean');
                // System.debug('printoutSettingBoolean:::'+ printoutSettingBoolean);


                if (printoutSetting != null) {
                    final String printoutSettingContent = printoutSetting.ASI_CRM_Section_Content__c;
                    BodySectionMap.get(key).content = printoutSettingContent;
                    // // 预览合同时，根据xml的checked来判断勾选
                    // if(isEditable)
                    // {
                    //     // system.debug('isEditable ==' + isEditable);
                    //     BodySectionMap.get(key).isShow = BodySectionMap.get(key).checked;
                    // }
                    // // 非预览合同时，根据ASI_CRM_Contract_Printout_Setting__c 中sectionBoolean的值来判断是否显示
                    // else if(printoutSettingBoolean != null)
                    // {
                    //     // system.debug('printoutSetting.ASI_CRM_Section_Content__c ==' + printoutSettingBoolean.ASI_CRM_Section_Content__c);
                    //     final String printoutSettingContentBoolean = printoutSettingBoolean.ASI_CRM_Section_Content__c;
                    //     BodySectionMap.get(key).isShow = Boolean.valueOf(printoutSettingContentBoolean);

                    // }

                    /*
                        Author:Bowen
                        Date: 2019-08-08
                        Function
                            当printoutSet有关于sectionboolean的值，则全部根据printoutset的修改;
                            其余情况，根据xml原有的checked来判断
                    */
                    if(printoutSettingBoolean != null)
                    {
                        // system.debug('printoutSetting.ASI_CRM_Section_Content__c ==' + printoutSettingBoolean.ASI_CRM_Section_Content__c);
                        final String printoutSettingContentBoolean = printoutSettingBoolean.ASI_CRM_Section_Content__c;
                        BodySectionMap.get(key).isShow = Boolean.valueOf(printoutSettingContentBoolean);
                        BodySectionMap.get(key).checked = Boolean.valueOf(printoutSettingContentBoolean);
                    }
                    // 其余情况，根据xml原有的checked来判断
                    else
                    {
                        BodySectionMap.get(key).isShow = BodySectionMap.get(key).checked;
                    }



                    if (String.isNotBlank(printoutSettingContent)) {
                        // if (printoutSettingContent.equals('true') || printoutSettingContent.equals('false')) {
                        // BodySectionMap.get(key).isShow = Boolean.valueOf(printoutSettingContent);
                        // } else {
                        BodySectionMap.get(key).content = SplitLineIntoRow(printoutSettingContent ,40);
                        // }
                    }
                    // System.debug('BodySectionMap.get(key):::' + BodySectionMap.get(key));
                }
                else if(isEditable)
                {
                    BodySectionMap.get(key).isShow = BodySectionMap.get(key).checked;
                }
                // else
                // {
                //    BodySectionMap.get(key).isShow = true;
                // }
            }

            if(BodySectionMap.get(key).type == 'Selectable' && !'section4'.equals(BodySectionMap.get(key).name)) {
                BodySectionMap.get(key).isShow = CheckingIsVisibleOrNot(BodySectionMap.get(key).Name);
            }


            // System.debug(BodySectionMap.get(key).content);
        }
    }

    public void UpdatingBodySignatureMap(){
        //<img src="/resource/ASI_CN_Company_Chop" alt="CHOP" height="2cm" width="2cm" >  ChopSignature
        for(integer key : BodySignatureMap.keySet()) {

            String ContentStr= BodySignatureMap.get(key).content;
            if(ContentStr.indexOf('//')>-1){
                List<String> parts = ContentStr.split('//');
                system.debug('parts == ' + parts);
                if(parts.size()>0){
                    if (parts.size() > 1) {
                        // Size 2+
                        String ChopString = '';
                        String whiteString = '';
                        if(parts[0].contains('{1}')){
                            String PartyAName='';
                            if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
                                PartyAName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
                            }else{
                                PartyAName=ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
                            }
                            parts[0] = parts[0].replace('{1}', PartyAName);

                            if(parts[1].contains('{2}')){
                                parts[1] = GeneratingPartyB_Header(true);
                            }


                        }else if (BodySignatureMap.get(key).name == 'ChopSignature' && IsApprovedVersion){//ASI_CN_Company_Chop
                            ChopString+= '<img src="/resource/ASI_CN_Company_Chop_Placeholder" alt="CHOP" height="2cm" width="2cm" >';
                            whiteString+= '<img src="/resource/ASI_CN_Company_Chop_Placeholder" alt="Placeholder" height="2cm" width="2cm" >';
                        }else if(parts[0].contains('{InputWholesaler}')){
                            system.debug('GeneratingEffectiveSupplierInput=='+GeneratingEffectiveSupplierInput('Party A', true));
                            parts[0] = parts[0].replace('{InputWholesaler}',
                                    GeneratingEffectiveSupplierInput('Party A', true));
                        }


                        BodySignatureMap.get(key).RightContent=parts[1]+ChopString;
                        BodySignatureMap.get(key).LeftContent=parts[0]+whiteString;
                    }

                    if(parts.size()==1){
                        BodySignatureMap.get(key).isShow=false;
                        if(BodySignatureMap.get(key).name =='BodySignature2'){ // 丙     方
                        }
                        BodySignatureMap.get(key).LeftContent=parts[0];
                    }
                }
            }
            System.debug('AppendixSignatureMap ==='+AppendixSignatureMap.get(key));
        }
    }


    public void UpdatingAppendixSignatureMap(){
        for(integer key : AppendixSignatureMap.keySet()) {

            String ContentStr= AppendixSignatureMap.get(key).content;
            if(ContentStr.indexOf('//')>-1){
                List<String> parts = ContentStr.split('//');


                if(parts.size()>0){
                    if (parts.size() > 1) {
                        // Size 2+
                        String ChopString = '';
                        String whiteString = '';
                        if(parts[0].contains('{1}')){
                            String PartyAName='';
                            if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
                                PartyAName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
                            }else{
                                PartyAName=ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
                            }
                            parts[0] = parts[0].replace('{1}', PartyAName);

                            if(parts[1].contains('{2}')){
                                parts[1] = GeneratingPartyB_Header(true);
                            }


                        }else if (AppendixSignatureMap.get(key).name == 'ChopSignature' && IsApprovedVersion){//ASI_CN_Company_Chop
                            ChopString+= '<img src="/resource/ASI_CN_Company_Chop_Placeholder" alt="CHOP" height="2cm" width="2cm" >';
                            whiteString+= '<img src="/resource/ASI_CN_Company_Chop_Placeholder" alt="Placeholder" height="2cm" width="2cm" >';
                        }else if(parts[0].contains('{InputWholesaler}')){
                            parts[0] = parts[0].replace('{InputWholesaler}',
                                    GeneratingEffectiveSupplierInput('Party A', true));
                        }

                        if(parts[1].contains('.')){
                            parts[1] =' ';
                        }

                        AppendixSignatureMap.get(key).RightContent=parts[1]+ChopString;
                        AppendixSignatureMap.get(key).LeftContent=parts[0]+whiteString;
                    }

                }
            }

        }

    }


    public void UpdateAppendixSectionMap(){// Sales_Discount_of_A_Class


        Map<String,interimData> PSF_Item_Map= new Map<String,interimData>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> VECList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        String VECVolumeBase='';
        Boolean HasPSFModule=false;
        KeySubBrandSet = new Set<String> ();
        Decimal PSFBySubBrandTotal= 0.0;
        Decimal PSFByTotalAmount= 0.0;

        Decimal PSFTotalContractAmount = 0;
        Decimal VECTotalAmount = 0.0;
        Decimal BRSFTotalAmount = 0.0;
        Decimal DisplayTotalAmount = 0.0;

        List<String> CoveredOutletNameList = new List<String>();
        Boolean DisplayFixedCostTable = false;
        Boolean DisplayDisplayCostTable = false;
        PSFModule2Rebate = 0;
        PSFModule2Min = 0;
        //Looping BRSF Line
        for (
                ASI_CRM_CN_Contract_BRSF_Line_Item__c contractline
                :
        [SELECT Id,
                ASI_CRM_CN_Activity_Code__c,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Contract_Monthly_Qty__c,
                ASI_CRM_CN_Contract_Purchase_Value__c,
                ASI_CRM_CN_Contract_Total_Dummy__c,
                ASI_CRM_CN_Contract_Total__c,
                ASI_CRM_CN_Contract__c,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Est_Monthly_Qty__c,
                ASI_CRM_CN_Est_Total_Dummy__c,
                ASI_CRM_CN_Est_Total__c,
                ASI_CRM_CN_Max_Purchase_Target__c,
                ASI_CRM_CN_Min_Purchase_Target__c,
                ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_Rebate__c,
                ASI_CRM_CN_Rebate_Percent__c,
                ASI_CRM_CN_Sub_Brand__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                ASI_CRM_CN_Sub_Brand__r.Name,
                ASI_CRM_CN_Target__c,
                ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                ASI_CRM_Contract_Total_QTY_std_Btl__c,
                ASI_CRM_Key_Sub_brand__c,
                ASI_CRM_Module__c,
                ASI_CRM_Module__r.ASI_CRM_CN_Criteria__c,
                ASI_CRM_Module__r.ASI_CRM_CN_Is_Capped__c,
                ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c,
                ASI_CRM_Module__r.ASI_CRM_CN_Minimal_Achievement__c,
                ASI_CRM_Module__r.ASI_CRM_CN_Volume_Value_Base__c,
                ASI_CRM_Module__r.ASI_CRM_Methodology__c,
                ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
                ASI_CRM_Module__r.ASI_CRM_Remark__c,
                ASI_CRM_Module__r.ASI_CRM_Unit__c,
                ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,
                ASI_CRM_Product_Category__c,
                ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_Product_Category__r.Name,
                ASI_CRM_Sub_Brand_Grade__c,
                ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Sub_Brand_Grade__r.Name,
                ASI_CRM_Type__c,
                ASI_CRM_Volume_Base__c
        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :contractId
        ORDER BY ASI_CRM_Module__c, ASI_CRM_CN_Min_Purchase_Target__c, ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c ASC] )
        {
            if(contractline.ASI_CRM_Type__c=='BRSF' && contractline.ASI_CRM_CN_Sub_Brand__c!=null && contractline.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' ){
                BRSFList.add(contractline);
                BRSFTotalAmount+= contractline.ASI_CRM_CN_Contract_Total_Dummy__c== null? 0:contractline.ASI_CRM_CN_Contract_Total_Dummy__c;
                if(contractline.ASI_CRM_Key_Sub_brand__c && ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
                    KeySubBrandSet.add(contractline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c);
                }
            }
            if(contractline.ASI_CRM_Type__c=='PSF'){
                PSFTotalContractAmount += contractline.ASI_CRM_CN_Contract_Total__c ==
                        null ? 0 : contractline.ASI_CRM_CN_Contract_Total__c;
                PSFModule2Rebate = contractline.ASI_CRM_CN_Rebate_Percent__c;
                PSFModule2Min = contractline.ASI_CRM_Module__r.ASI_CRM_CN_Minimal_Achievement__c;
                System.debug(LoggingLevel.INFO, '*** PSFModule2Rebate: ' + PSFModule2Rebate);
                if(contractline.ASI_CRM_Volume_Base__c =='By Sub-Brand' ){
                    PSFBySubBrandTotal += contractline.ASI_CRM_CN_Contract_Total__c== null? 0:contractline.ASI_CRM_CN_Contract_Total__c; // ASI_CRM_CN_Contract_Total_Dummy__c  ASI_CRM_CN_Contract_Total__c
                }
                if(contractline.ASI_CRM_Volume_Base__c =='By Total'){
                    PSFByTotalAmount += contractline.ASI_CRM_CN_Contract_Total_Dummy__c ==
                            null ? 0 : contractline.ASI_CRM_CN_Contract_Total_Dummy__c;
                }
                if(contractline.ASI_CRM_Key_Sub_brand__c){
                    KeySubBrandSet.add(contractline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c);
                }
                if(contractline.ASI_CRM_Module__c!=null){
                    HasPSFModule=true;
                    if(!PSF_Item_Map.containsKey(contractline.ASI_CRM_Module__c)){
                        interimData TempData= new interimData();
                        TempData.VolumeBase = contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                        TempData.Methodology = contractline.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name;
                        TempData.Criteria = contractline.ASI_CRM_Module__r.ASI_CRM_CN_Criteria__c;
                        TempData.MinAchievement = contractline.ASI_CRM_Module__r.ASI_CRM_CN_Minimal_Achievement__c;
                        TempData.Remarks = contractline.ASI_CRM_Module__r.ASI_CRM_Remark__c;
                        PSF_Item_Map.put(contractline.ASI_CRM_Module__c,TempData);
                    }
                    PSF_Item_Map.get(contractline.ASI_CRM_Module__c).DetailLineMap.put(contractline.Id,contractline);
                }
            }
            if(contractline.ASI_CRM_Type__c=='Variable Event Cost'){
                VECTotalAmount+= contractline.ASI_CRM_CN_Contract_Total__c== null? 0:contractline.ASI_CRM_CN_Contract_Total__c;
                if(contractline.ASI_CRM_CN_Sub_Brand__c!=null){
                    if(contractline.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' ){
                        VECVolumeBase=contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                        VECList.add(contractline);
                    }
                }else{
                    VECVolumeBase=contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                    VECList.add(contractline);
                }
            }
            if (contractline.ASI_CRM_Type__c=='Display'){
                system.debug('Display is true:' + contractline);

                DisplayDisplayCostTable = true;
                DisplayTotalAmount += contractline.ASI_CRM_CN_Contract_Total_Dummy__c== null? 0:contractline.ASI_CRM_CN_Contract_Total_Dummy__c;
            }
        }

        for(ASI_CRM_CN_Covered_Outlet__c CoveredOutlet:CoveredOutletList)
        {
            if(CoveredOutlet.ASI_CRM_CN_Outlet__c!=null){
                if (CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c != null){
                    CoveredOutletNameList.add(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c);
                } else if(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c !=null){
                    CoveredOutletNameList.add(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c);
                } else {
                    CoveredOutletNameList.add(CoveredOutlet.ASI_CRM_CN_Outlet__r.Name);
                }
            }
        }


        List<ASI_CRM_Contract_Cost__c> FixCostList = new List<ASI_CRM_Contract_Cost__c>();
        Map<Integer, ASI_CRM_Contract_Cost__c> FixCostMap = new Map<Integer, ASI_CRM_Contract_Cost__c>();
        //Get Contract Cost - Fixed Cost
        Decimal amountRate = 0 ;
        for (ASI_CRM_Contract_Cost__c cc : getContractCostsByContractId(contractId)) {
            if (cc.ASI_CRM_CN_Cost_Type__c == 'Fixed') {
                FixCostList.add(cc);

                if (cc.ASI_CRM_CN_Contract_Amount__c != 0) {
                    DisplayFixedCostTable = true;
                }
                amountRate += cc.ASI_CRM_CN_Contract_Amount_Rate__c == null? 0 : cc.ASI_CRM_CN_Contract_Amount_Rate__c;
                //Create FixCostMap according to global FixedCostItemSequenceMap
                if (cc.ASI_CRM_CN_Chinese_Description__c != null &&
                        FixedCostItemSequenceMap.get(cc.ASI_CRM_CN_Chinese_Description__c) != null
                        ) {
                    FixCostMap.put(FixedCostItemSequenceMap.get(cc.ASI_CRM_CN_Chinese_Description__c), cc);
                    System.debug('Map key:::' + FixedCostItemSequenceMap.get(cc.ASI_CRM_CN_Chinese_Description__c));
                    System.debug('Map value:::' + JSON.serialize(cc));
                }
                system.debug(FixCostMap);
            }
        }


        for(integer key : AppendixSectionMap.keySet()) {
            SectionWrapper AppendixSection = AppendixSectionMap.get(key);
            system.debug('AppendixSection.name == '+AppendixSection.name);

            //Handle Fix cost table
            //===========================================================================
            if( AppendixSection.name =='FixCostTable'){
                // Generate Fix cost table
                if(DisplayFixedCostTable){
                    AppendixSection.content  = GenerateFixCostTable (key,FixCostMap,AppendixSection.subSectionMap);
                    system.debug('*******GenerateFixCostTable*********');
                    system.debug(AppendixSection.content);
                }
            } else if(AppendixSection.name.contains('FixCostTableHeader') || AppendixSection.name.contains('FixCostTableLineHeader') ){
                if(!DisplayFixedCostTable){
                    AppendixSection.content='';
                    AppendixSection.displayNumber='';
                    AppendixSection.isShow= false;
                } else {
                    AppendixSection.content=SplitLineIntoRow(AppendixSection.content, BodyContentCuttingNumber);
                }
            }
            //Handle BRSF table, PSF, VEC table
            //===========================================================================
            else if( AppendixSection.name =='SalesDiscount'){
                AppendixSection.content = SplitStringLine(AppendixSection.content);

                for(integer ChildKey : AppendixSection.subSectionMap.keySet()){
                    SectionWrapper AppendixSubSection = AppendixSection.subSectionMap.get(ChildKey);
                    String ExternalKey=String.valueOf(key)+'_'+String.valueOf(ChildKey);
                    if(AppendixSubSection.name == 'Sales_Discount_of_A_Class' && BRSFList.size()==0){
                        AppendixSubSection.isShow=false;
                    }else if(AppendixSubSection.name.contains('BRSFTable')){

                        if(AppendixSubSection.name == 'BRSFTable'){
                            if(BRSFList.size()>0){
                                String ModuleId = '';

                                String BRSF_content = '';
                                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:BRSFList){
                                    if(BRSFLine.ASI_CRM_Module__c!=null && ModuleId==''){
                                        ModuleId = BRSFLine.ASI_CRM_Module__c;
                                    }
                                }
                                ASI_CRM_Module__c module = [SELECT ASI_CRM_CN_Volume_Value_Base__c ,ASI_CRM_Line_Type__c ,
                                        ASI_CRM_Contract__r.ASI_CRM_CN_Region__c
                                from ASI_CRM_Module__c where id = :ModuleId LIMIT 1];
                                contractModuleBase = module.ASI_CRM_CN_Volume_Value_Base__c;

                                List<String> base = AppendixSubSection.content.split(',,');
                                // Dolphin合同表
                                if (ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
                                    contractModuleBase = contractSelected.ASI_CRM_CN_Target_Base__c;
                                    List<String> parts0 = contractModuleBase == 'Volume'? base.get(0).split('//'):base.get(1).split('//');
                                    BRSF_content += DrawingBRSFTable(BRSFList,AppendixSubSection ,module ,parts0 ,base ,contractModuleBase);

                                }

                                /*
                                    2019-07-30 Laputa(Bowen)
                                        当客户属于中区，并且module.ASI_CRM_CN_Volume_Value_Base__c = Value ，module.ASI_CRM_Line_Type__c == 'BRSF',
                                        需要同时显示两种销售目标数据
                                */
                                else if (module.ASI_CRM_Contract__r.ASI_CRM_CN_Region__c == 'Central Region' && contractModuleBase == 'Value' && module.ASI_CRM_Line_Type__c == 'BRSF')
                                {
                                    List<String> parts0 = base.get(0).split('//');
                                    BRSF_content += DrawingBRSFTable(BRSFList,AppendixSubSection ,module ,parts0 ,base ,'Volume');
                                    // List<String> parts1 = base.get(1).split('//');
                                    // BRSF_content += '<br/>'+ DrawingBRSFTable(BRSFList,AppendixSubSection ,module ,parts1 ,base ,ModuleId);
                                }
                                else if (contractModuleBase == 'Volume'){
                                    List<String> parts0 = base.get(0).split('//');
                                    BRSF_content += DrawingBRSFTable(BRSFList,AppendixSubSection ,module ,parts0 ,base ,'Volume');
                                } else {
                                    List<String> parts1 = base.get(1).split('//');
                                    BRSF_content += DrawingBRSFTable(BRSFList,AppendixSubSection ,module ,parts1 ,base ,contractModuleBase);
                                }

                                /* 2019-08-27 Bowen 
                                    增加一逻辑：仅当name = BRSFTable，初始化时，根据区域和value/volume的不同，显示的类型不同
                                    大前提：如果系统中的setting保存了当前数据的内容，则根据内容上的来
                                        1. 所有的销量基础的 （volume base）
                                        销量目标根据品牌的这个表，默认打勾
                                         
                                        2. 所有的价值基础的 （Value base）， 非中区
                                        销量目标根据品牌的这个表，默认不打勾，但是下面  “合同期目标销售额” 打勾
                                         
                                        3. 所有的价值基础的 （Value base）， 中区
                                        销量目标根据品牌的这个表，默认打勾，下面  “合同期目标销售额” 打勾
                                */
                                system.debug('AppendixSubSection.content == ' +AppendixSubSection.checked );   
                                if(ContractSettingMap.containsKey(AppendixSubSection.Name) && ContractSettingMap.get(AppendixSubSection.Name)=='false'){
                                    AppendixSubSection.checked=false;
                                } 
                                else if(ContractSettingMap.containsKey(AppendixSubSection.Name) && ContractSettingMap.get(AppendixSubSection.Name)=='true')
                                {
                                    AppendixSubSection.checked=true;
                                }                          
                                else if(contractModuleBase == 'Volume')
                                {
                                    AppendixSubSection.checked = true;
                                }
                                else if(module.ASI_CRM_Contract__r.ASI_CRM_CN_Region__c != 'Central Region')
                                {
                                    AppendixSubSection.checked = false;
                                }
                                system.debug('BRSF_content == ' +BRSF_content );
                                AppendixSubSection.content= BRSF_content;
                                system.debug('AppendixSubSection.content == ' +AppendixSubSection.content );
                                //AppendixSubSection.content= DrawingBRSFTable(AppendixSubSection.content,BRSFList,AppendixSubSection);
                            }else{
                                AppendixSubSection.isShow=false;
                            }
                        }
                    }
                    /*
                     * else if(AppendixSubSection.name == 'Non_standard_Convert'){ //English version
                     * if(AppendixSubSection.type!='Editable'){
                     * AppendixSubSection.content = SplitLineIntoRow( AppendixSubSection.content ,67);
                     * }
                     * AppendixSubSection.content=AppendixSubSection.content.replaceAll('nbsp','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '); //else if(AppendixSubSection.name=='Sales_Discount_of_B_Class' && !HasPSFModule ){AppendixSubSection.isShow=false;}
                     * }
                     */
                    else if(AppendixSubSection.name =='PSFTableHeader' && !HasPSFModule){
                        AppendixSubSection.isShow=false;
                        AppendixSubSection.content='';
                        AppendixSubSection.displayNumber='';
                    }else if(AppendixSubSection.name =='PSFTable'){
                        // Drawing PSF Table
                        if(HasPSFModule){
                            AppendixSubSection.content = DrawingPSFTable(AppendixSubSection.content,PSF_Item_Map,AppendixSubSection).replace('{MinPurchaseTarget}', ' ').replace('{MinAchievement}', ' ');

                        }else{
                            AppendixSubSection.isShow=false;
                            AppendixSubSection.content='';
                        }
                    }
                    /*
                     * else if(AppendixSubSection.name == 'Event_Support' && VECList.size()==0){
                     * AppendixSubSection.isShow=false;
                     * AppendixSubSection.content='';
                     * AppendixSubSection.displayNumber='';
                     * }else if(AppendixSubSection.name == 'Event_Support 1' && VECList.size()==0){
                     * AppendixSubSection.isShow=false;
                     * AppendixSubSection.content='';
                     * AppendixSubSection.displayNumber='';
                     * }
                     */
                    else if(AppendixSubSection.name.contains('KeySubBrandPart')){
                        if(AppendixSubSection.content.contains('{Key-SubBrand}')){
                            if(KeySubBrandSet.size()>0){
                                String SubBrandNames= String.valueOf(KeySubBrandSet);
                                SubBrandNames= SubBrandNames.replace('{','');
                                SubBrandNames= SubBrandNames.replace('}','');
                                AppendixSubSection.content=AppendixSubSection.content.replace('{Key-SubBrand}', SubBrandNames);
                                if (ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
                                    AppendixSubSection.content = SplitLineIntoRow( AppendixSubSection.content ,38);
                                    if (ContractSelected.ASI_CRM_CN_Contract_Classification__c != 'A') {
                                        AppendixSubSection.hideSectionWrapper();
                                    }
                                } else {
                                    AppendixSubSection.content = SplitLineIntoRow( AppendixSubSection.content ,45);
                                }
                                AppendixSubSection.content = '<div>' + AppendixSubSection.content + '</div>';
                            }
                        }
                        if(KeySubBrandSet.size()<=0){
                            AppendixSubSection.isShow=false;
                            AppendixSubSection.content = '';
                            if (ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
                                AppendixSubSection.hideSectionWrapper();
                            }
                        }
                        if(AppendixSubSection.content.contains('{OutputPSFTotalAmount}')){
                            AppendixSubSection.content =
                                    AppendixSubSection.content.replace('{OutputPSFTotalAmount}', PSFTotalContractAmount.format());
                        }
                        //ASI_CRM_Expected_V0_PSF_Estimated_Total__c
                    }else if(AppendixSubSection.name=='PSFBySubBrandItems'){
                        if(AppendixSubSection.content.contains('{InputPercent}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputPercent');
                        }
                        if(AppendixSubSection.content.contains('{InputAmount}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputAmount');
                        }
                        if(AppendixSubSection.content.contains('{OutputSubBrandTotal}')){
                            AppendixSubSection.content =AppendixSubSection.content.replace('{OutputSubBrandTotal}', PSFBySubBrandTotal.format());   // String.valueOf(PSFBySubBrandTotal) PSFBySubBrandTotal   //AppendixSubSection.content = AppendixSubSection.content.replace('{InputAmount}', '<input type="text" class="InputAmount " data-id="'+AppendixSubSection.name+'InputAmount2'+'" />');
                        }

                        AppendixSubSection.content = CheckingHighLight(SplitLineIntoRow( AppendixSubSection.content ,40));
                    }else if(AppendixSubSection.name=='PSFByTotalItems'){
                        if(AppendixSubSection.content.contains('{OutputByTotalAmount1}')){
                            AppendixSubSection.content = AppendixSubSection.content.replace('{OutputByTotalAmount1}', PSFByTotalAmount.format());  //UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputAmount1'); // AppendixSubSection.content = AppendixSubSection.content.replace('{InputAmount1}', '<input type="text" class="InputAmount " data-id="'+AppendixSubSection.name+'InputAmount1'+'" />');
                        }
                        if(AppendixSubSection.content.contains('{OutputByTotalAmount2}')){
                            AppendixSubSection.content = AppendixSubSection.content.replace('{OutputByTotalAmount2}',
                                    PSFByTotalAmount.format());
                        }

                        if(AppendixSubSection.content.contains('{InputPercent1}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputPercent1');//AppendixSubSection.content = AppendixSubSection.content.replace('{InputPercent1}', '<input type="text" class="InputAmount " data-id="'+AppendixSubSection.name+'InputPercent1'+'" />');
                        }
                        if(AppendixSubSection.content.contains('{InputPercent2}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputPercent2');//AppendixSubSection.content = AppendixSubSection.content.replace('{InputPercent2}', '<input type="text" class="InputAmount " data-id="'+AppendixSubSection.name+'InputPercent2'+'" />');
                        }
                        if(AppendixSubSection.content.contains('{InputAmount1}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputAmount1');
                        }
                        if(AppendixSubSection.content.contains('{InputAmount2}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputAmount2');
                        }
                        AppendixSubSection.content = CheckingHighLight(SplitLineIntoRow( AppendixSubSection.content ,40));
                    }else if(AppendixSubSection.name=='Event_Support Remark'){
                        if(AppendixSubSection.content.contains('{OutputVECAmount1}')){
                            AppendixSubSection.content = AppendixSubSection.content.replace('{OutputVECAmount1}',VECTotalAmount.format());//UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputAmount1');//AppendixSubSection.content = AppendixSubSection.content.replace('{InputAmount1}', '<input type="text" class="InputAmount " data-id="'+AppendixSubSection.name+'InputAmount1'+'" />');
                        }
                        if(AppendixSubSection.content.contains('{OutputVECAmount2}')){
                            AppendixSubSection.content = AppendixSubSection.content.replace('{OutputVECAmount2}',VECTotalAmount.format());//UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputAmount1');//AppendixSubSection.content = AppendixSubSection.content.replace('{InputAmount1}', '<input type="text" class="InputAmount " data-id="'+AppendixSubSection.name+'InputAmount1'+'" />');
                        }

                        if(AppendixSubSection.content.contains('{InputPercent1}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputPercent1');//AppendixSubSection.content = AppendixSubSection.content.replace('{InputPercent1}', '<input type="text" class="InputAmount " data-id="'+AppendixSubSection.name+'InputPercent1'+'" />');
                        }
                        if(AppendixSubSection.content.contains('{InputPercent2}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputPercent2'); // AppendixSubSection.content = AppendixSubSection.content.replace('{InputPercent2}', '<input type="text" class="InputAmount " data-id="'+AppendixSubSection.name+'InputPercent2'+'" />');
                        }
                        if(AppendixSubSection.content.contains('{InputAmount1}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputAmount1');
                        }
                        if(AppendixSubSection.content.contains('{InputAmount2}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputAmount2');
                        }

                        AppendixSubSection.content = CheckingHighLight(SplitLineIntoRow( AppendixSubSection.content ,40));
                    }else if(AppendixSubSection.name=='ContractLineAddOn'){
                        if (!String.isBlank(AppendixSubSection.className)){
                            system.debug('className:' + AppendixSubSection.className);
                            system.debug('contractModuleBase: '+ contractModuleBase);
                            if (AppendixSubSection.className !=null && !AppendixSubSection.className.contains(contractModuleBase)){
                                AppendixSubSection.hideSectionWrapper();
                            }
                        }
                        if(AppendixSubSection.content.contains('{InputAmount1}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputAmount1');
                        }
                        if(AppendixSubSection.content.contains('{InputPercent}')){
                            AppendixSubSection.content = UpdateInputAmount(AppendixSubSection.name,AppendixSubSection.content, 'InputPercent');
                        }
                        if(AppendixSubSection.content.contains('{OutputPSFTotalAmount}')){
                            AppendixSubSection.content =
                                    AppendixSubSection.content.replace('{OutputPSFTotalAmount}', PSFTotalContractAmount.format());
                        }
                        if(AppendixSubSection.content.contains('{BRSFTotalContractAmount}')){
                            AppendixSubSection.content = AppendixSubSection.content.replace('{BRSFTotalContractAmount}', BRSFTotalAmount.round(System.RoundingMode.FLOOR).format() );
                        }

                        AppendixSubSection.content =
                                CheckingHighLight(SplitLineIntoRow(AppendixSubSection.content, 50));

                        if(ContractSettingMap.containsKey(AppendixSubSection.Name) && ContractSettingMap.get(AppendixSubSection.Name)=='false'){
                            AppendixSubSection.checked=false;
                        } 
                        else if(ContractSettingMap.containsKey(AppendixSubSection.Name) && ContractSettingMap.get(AppendixSubSection.Name)=='true')
                        {
                            AppendixSubSection.checked=true;
                        } 
                    }else if(AppendixSubSection.name=='costRate'){
                        if(AppendixSubSection.content.contains('{costRate}')){
                            AppendixSubSection.content = AppendixSubSection.content.replace('{costRate}', String.valueOf(amountRate));
                            AppendixSubSection.content = SplitLineIntoRow( AppendixSubSection.content ,BodyContentCuttingNumber);
                            if (ContractSelected.ASI_CRM_CN_Contract_Classification__c != 'A' || amountRate == 0) {
                                AppendixSubSection.hideSectionWrapper();
                            } else {
                                if (!KeySubBrandSet.isEmpty() && ContractSelected.ASI_CRM_CN_Activity_Times__c > 0) {
                                    
                                }
                                else if (KeySubBrandSet.isEmpty() && ContractSelected.ASI_CRM_CN_Activity_Times__c == 0) {
                                    AppendixSubSection.displayNumber = '3.4';
                                } else {
                                    AppendixSubSection.displayNumber = '3.5';
                                }

                            }
                        }
                    }else if(AppendixSubSection.name=='activitytimes'){
                        if(AppendixSubSection.content.contains('{activitytimes}')){
                            AppendixSubSection.content = AppendixSubSection.content.replace('{activitytimes}',String.valueOf(ContractSelected.ASI_CRM_CN_Activity_Times__c));
                            AppendixSubSection.content = SplitLineIntoRow( AppendixSubSection.content ,BodyContentCuttingNumber);
                            if (ContractSelected.ASI_CRM_CN_Contract_Classification__c != 'A' || ContractSelected.ASI_CRM_CN_Activity_Times__c == 0) {
                                AppendixSubSection.hideSectionWrapper();
                            } else {
                                if (KeySubBrandSet.isEmpty()) {
                                    AppendixSubSection.displayNumber = '3.4';
                                }
                            }
                        }
                    }
                    else{
                        system.debug('Test 1.0 : '+ AppendixSubSection.content );
                        if(AppendixSubSection.type!='Editable'){
                            AppendixSubSection.content = SplitLineIntoRow( AppendixSubSection.content ,BodyContentCuttingNumber);
                        }

                    }
                    if(AppendixSubSection.ClassName!=null){
                        if(AppendixSubSection.ClassName.contains('VECRemark') && VECList.size()==0 ){
                            AppendixSubSection.hideSectionWrapper();
                        }
                    }
                    if(AppendixSubSection.type=='Selectable'){
                        if(AppendixSubSection.Name !=null && ContractSettingMap.containsKey(AppendixSubSection.Name)){
                            if(ContractSettingMap.get(AppendixSubSection.Name)=='false'){
                                AppendixSubSection.isShow=false;
                            }
                        }
                    }
                }
            }
            //===========================================================================
            //Handle Display Listing table
            //===========================================================================
            else if( AppendixSection.name =='DisplayListingTable'){
                if(DisplayDisplayCostTable){
                    AppendixSection.content = GenerateDisplayListingTable(key, DisplayTotalAmount, AppendixSection.subSectionMap);
                }
                AppendixSection.subSectionMap = null;
            } else if(AppendixSection.name.contains('DisplayListingHeader') || AppendixSection.name.contains('DisplayListingLine') ){
                if(!DisplayDisplayCostTable){
                    AppendixSection.hideSectionWrapper();
                }
            }
            //===========================================================================
            //Handle Cover outlet List
            //      1. If no outlet list, still show the content of the template
            //      2. If all of the subSection is unchecked, do not show outlet list
            //===========================================================================
            else if( AppendixSection.name.contains('Affiliates_List')){
                system.debug('CoveredOutletNameList:' + AppendixSection.hasSubSection);
                system.debug('CoveredOutletNameList:' + AppendixSection.name);

                if(AppendixSection.hasSubSection){
                    //loop child content
                    Boolean showOutletList = false;
                    for(integer ChildKey : AppendixSection.subSectionMap.keySet()){
                        String ExternalKey=String.valueOf(key)+'_'+String.valueOf(ChildKey);
                        SectionWrapper AppendixSubsection = AppendixSection.subSectionMap.get(ChildKey);
                        System.debug(LoggingLevel.INFO, '*** wo: ' + AppendixSubSection);
                        if (AppendixSubsection.type == 'Selectable') {
                            Boolean thisShow;
                            //if select value = null, treated as true
                            thisShow = (ContractSettingMap.get(AppendixSubsection.name) != null) ? Boolean.valueOf(ContractSettingMap.get(AppendixSubsection.name)) : true;
                            showOutletList = (showOutletList || thisShow);
                            AppendixSubsection.isShow = thisShow;
                        }
                        //case 1: if contain '{InputText}'
                        if(AppendixSubsection.content.contains('{InputText}')){
                            String ContentText = ContractSettingMap.containsKey(AppendixSubsection.name + 'InputText') ?
                                    ContractSettingMap.get(AppendixSubsection.name + 'InputText') : '';

                            if (!isEditable) {
                                //PDF
                                AppendixSubsection.content = AppendixSubsection.content.replace('{InputText}', SplitLineIntoRow(ContentText,38) );
                                AppendixSubsection.content = SplitLineIntoRow(AppendixSubsection.content, 38);

                                if (!showOutletList){
                                    AppendixSubsection.hideSectionWrapper();
                                }

                                if(!ContractSettingMap.containsKey(AppendixSubsection.name+'InputText') ){
                                    AppendixSubsection.isShow=false;
                                }else if(ContractSettingMap.containsKey(AppendixSubsection.name) ){
                                    AppendixSubsection.isShow=
                                            ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean(
                                                    ContractSettingMap.get(AppendixSubsection.name));
                                } else {
                                    AppendixSubsection.content = SplitLineIntoRow(AppendixSubsection.content, 38);
                                }
                            }else{
                                String prefixString = AppendixSubsection.content.substringBefore('{InputText}');
                                String subfixString = AppendixSubsection.content.substringAfter('{InputText}');
                                AppendixSubsection.content = SplitLineIntoRow(prefixString, 38) + 
                                '<textarea cols="30" rows="3" class="InputText " data-id="'+AppendixSubsection.name+'InputText"  >'+ContentText+'</textarea>'
                                + SplitLineIntoRow(subfixString, 38);

                            //     SplitLineIntoRow(AppendixSubsection.content.replace('{InputText}', 
                            // '<textarea cols="30" rows="3" class="InputText " data-id="'+AppendixSubsection.name+'InputText"  >'+ContentText+'</textarea>')
                            //     , 38);
                                System.debug(LoggingLevel.INFO, '*** ContentText: ' + ContentText);
                                System.debug(LoggingLevel.INFO, '*** AppendixSubsection.name: ' + AppendixSubsection.name);
                                System.debug(LoggingLevel.INFO, '*** AppendixSubsection.content: ' + AppendixSubsection.content);
                            }
                        }

                        if (AppendixSubsection.content.contains('{Outlet}')){
                            system.debug('showOutletList:' + showOutletList);
                            system.debug('CoveredOutletNameList' + CoveredOutletNameList);
                            if (CoveredOutletNameList.size() > 0){
                                system.debug('bowen -有值的时候--'+coverOutletTable(CoveredOutletNameList, 3));
                                AppendixSubsection.content =  AppendixSubsection.content.replace('{Outlet}',coverOutletTable(CoveredOutletNameList, 3));
                            } else {
                                AppendixSubsection.content =  AppendixSubsection.content.replace('{Outlet}', '');
                            }
                            system.debug('AppendixSubsection.content' + AppendixSubsection.content);

                            AppendixSubsection.isShow = showOutletList;
                            if (!showOutletList){
                                AppendixSection.hideSectionWrapper();
                            }
                        }

                        if(ContractSettingMap.containsKey(AppendixSubsection.name))
                        {
                            if(ContractSettingMap.get(AppendixSubsection.name) == 'false')
                            {
                                AppendixSubsection.checked = false;
                            }
                            else if(ContractSettingMap.get(AppendixSubsection.name) == 'true')
                            {
                                AppendixSubsection.checked = true;
                            }
                        }

                    }
                }

                System.debug(AppendixSection);
            }

            else if (
                    AppendixSection.name.contains('AppendixGeneral') || AppendixSection.name == 'Party A undertakes') {
                // general part
                AppendixSection.content = SplitStringLine(AppendixSection.content);
                if(AppendixSection.hasSubSection){
                    //loop child content
                    for(integer ChildKey : AppendixSection.subSectionMap.keySet()){
                        String ExternalKey=String.valueOf(key)+'_'+String.valueOf(ChildKey);

                        //case 1: if contain '{InputText}'
                        if(AppendixSection.subSectionMap.get(ChildKey).content.contains('{InputText}')){
                            String ContentText = ContractSettingMap.containsKey(
                                    AppendixSection.subSectionMap.get(ChildKey).name + 'InputText') ?
                                    ContractSettingMap.get(
                                            AppendixSection.subSectionMap.get(ChildKey).name +
                                                    'InputText') : '';

                            if (!isEditable) {
                                //PDF
                                AppendixSection.subSectionMap.get(ChildKey).content =
                                        AppendixSection.subSectionMap.get(ChildKey).content.replace('{InputText}', SplitLineIntoRow(ContentText,38) );

                                if(!ContractSettingMap.containsKey(AppendixSection.subSectionMap.get(ChildKey).name+'InputText') ){
                                    AppendixSection.subSectionMap.get(ChildKey).isShow=false;
                                }else if(ContentText=='' ||ContentText==' '){
                                    AppendixSection.subSectionMap.get(ChildKey).isShow=false;
                                }else if(ContractSettingMap.containsKey(AppendixSection.subSectionMap.get(ChildKey).name) ){
                                    AppendixSection.subSectionMap.get(ChildKey).isShow=
                                            ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean(
                                                    ContractSettingMap.get(
                                                            AppendixSection.subSectionMap.get(ChildKey).name));
                                }
                            }else{
                                AppendixSection.subSectionMap.get(ChildKey).content = AppendixSection.subSectionMap.get(ChildKey).content.replace('{InputText}', '<textarea cols="30" rows="3" class="InputText " data-id="'+AppendixSection.subSectionMap.get(ChildKey).name+'InputText"  >'+ContentText+'</textarea>');
                            }
                        } else if(AppendixSection.subSectionMap.get(ChildKey).name.contains('FixCostTable')){//Case 2
                            system.debug('case 2 ');
                            system.debug(AppendixSection.subSectionMap.get(ChildKey).name);
                            AppendixSection.subSectionMap.get(ChildKey).content  = GenerateFixCostTable (ChildKey,FixCostMap,AppendixSection.subSectionMap.get(ChildKey).subSectionMap);
                        } else if(AppendixSection.subSectionMap.get(ChildKey).type == 'Editable'){
                            AppendixSection.subSectionMap.get(ChildKey).content= GeneratingInputText(AppendixSection.subSectionMap.get(ChildKey).name +'InputText',AppendixSection.subSectionMap.get(ChildKey).content);
                            if(AppendixSection.subSectionMap.get(ChildKey).content ==''){
                                AppendixSection.subSectionMap.get(ChildKey).isShow=false;
                            }
                        } else {
                            AppendixSection.subSectionMap.get(ChildKey).content = SplitStringLine(AppendixSection.subSectionMap.get(ChildKey).content);
                        }
                    }
                }

            }else if(AppendixSection.name.contains('Terms of this Agreement') ){
                List<String> DateFillers = new String[] {'',
                        String.valueOf(
                                ContractSelected.ASI_CRM_CN_PO_Start_Date__c.year()),
                        String.valueOf(
                                ContractSelected.ASI_CRM_CN_PO_Start_Date__c.month()),
                        String.valueOf(
                                ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()),
                        String.valueOf(
                                ContractSelected.ASI_CRM_CN_PO_End_Date__c.year()),
                        String.valueOf(
                                ContractSelected.ASI_CRM_CN_PO_End_Date__c.month()),
                        String.valueOf(
                                ContractSelected.ASI_CRM_CN_PO_End_Date__c.day())};

                AppendixSection.content = String.format(AppendixSection.content, DateFillers);


            }else if(AppendixSection.name=='Party A' ){
                System.debug('party A data:::' + AppendixSection.content);
                String PartyAName = '';
                if(AppendixSection.content.contains('{1}')){
                    if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
                        PartyAName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
                    }else{
                        PartyAName=ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
                    }
                    List<String> fillers = new String[] {'',PartyAName};
                    AppendixSection.content = String.format(AppendixSection.content, fillers);
                } else if(AppendixSection.content.contains('{InputWholesaler}')){
                    AppendixSection.content = AppendixSection.content.replace('{InputWholesaler}',
                            GeneratingEffectiveSupplierInput('Party A', true));
                }
                AppendixSection.content = SplitLineIntoRow(AppendixSection.content,40);


            }else if(AppendixSection.name =='Party B' ){
                List<String> fillers = new List<String>() ;
                fillers = new String[] {'',GeneratingPartyB_Header(true)  };
                AppendixSection.content = String.format(AppendixSection.content, fillers);
                if(AppendixSection.content.contains('{InputWholesaler}')){
                    AppendixSection.content = AppendixSection.content.replace('{InputWholesaler}',
                            GeneratingEffectiveSupplierInput('Party B', true));
                }
            } else {
                //others
                AppendixSection.content = SplitStringLine(AppendixSection.content);
                if(AppendixSection.hasSubSection){
                    for(integer ChildKey : AppendixSection.subSectionMap.keySet()){
                        AppendixSection.subSectionMap.get(ChildKey).content = SplitStringLine(AppendixSection.subSectionMap.get(ChildKey).content);
                    }
                }
            }

            if(AppendixSection.content.contains('{CoveredOutletTable}')){
                AppendixSection.content = AppendixSection.content.replace('{CoveredOutletTable}', GeneratingCoveredOutletTable());
            }


            //general second looping
            if(AppendixSection.hasSubSection){
                if(AppendixSection.subSectionMap!=null){
                    for(integer ChildKey : AppendixSection.subSectionMap.keySet()){
                        //case 1 editable
                        if(AppendixSection.subSectionMap.get(ChildKey).type =='Editable' && AppendixSection.subSectionMap.get(ChildKey).name !=null && ContractSettingMap.containsKey(AppendixSection.subSectionMap.get(ChildKey).name)){

                            AppendixSection.subSectionMap.get(ChildKey).content = ContractSettingMap.get(AppendixSection.subSectionMap.get(ChildKey).name);
                        }

                    }
                }

            }

            if(AppendixSection.type =='Editable' && AppendixSection.name !=null && ContractSettingMap.containsKey(AppendixSection.name)){
                AppendixSection.content = ContractSettingMap.get(AppendixSection.name);
                system.debug('Ha:'+AppendixSection.content);
            }


        }

        for(integer key : AppendixSectionMap.keySet()) {
            SectionWrapper AppendixSection = AppendixSectionMap.get(key);
            system.debug('AppendixSection == '+AppendixSection);
        }
        ReOrdering();

    }


    //generate Input Text textarea
    @testVisible
    private string GeneratingInputText(String InputKey, string DefaultValue){

        String OutputHTML='';
        if(!isEditable){
            if(ContractSettingMap.containsKey(InputKey)){
                OutputHTML=SplitLineIntoRow(ContractSettingMap.get(InputKey),InnerContentCuttingNumber);
            }else{
                OutputHTML='';
            }

        }else{
            String ContentText =  ContractSettingMap.containsKey(InputKey) ? ContractSettingMap.get(InputKey):DefaultValue;
            OutputHTML='<textarea cols="30" rows="3" class="InputText " data-id="'+InputKey+'"  >'+ContentText+'</textarea>';
        }
        return OutputHTML;
    }

    private String GenerateDisplayListingTable(integer AppendixKey, Decimal totalAmount, Map<integer, SectionWrapper> ChildMap){
        if (totalAmount > 0){
            string InnerHTML='<table style="page-break-inside:avoid; border: 1px solid black; border-collapse: collapse; ';
            if(!isEditable){
                InnerHTML += 'width: 50px ';
            }
            InnerHTML += '" > ';

            for(integer ChildKey : ChildMap.keySet()){
                SectionWrapper child = ChildMap.get(ChildKey);
                if (child == null){
                    continue;
                }
                SectionType SectionTypeClass = ClassNameHandler(child.ClassName);
                String subSectionName = child.name;
                String ContentStr = child.content;
                List<String> parts = ContentStr.split('//');
                if (parts.size() > 0){
                    InnerHTML+='<tr style="border: 1px solid black; ">';
                    integer columnNum = 1;
                    for(string str:parts){
                        if (str == '.') {
                            str = '';
                        }
                        system.debug('DisplayListingTable str ='+str);
                        InnerHTML+= '<td style="border: 1px solid black; " ';
                        if(columnNum == SectionTypeClass.StyleStringColumnNum){
                            InnerHTML += SectionTypeClass.StyleString;
                        }
                        if(SectionTypeClass.ClassType=='InputText' && columnNum == SectionTypeClass.ClassTypeColumnNum){
                            InnerHTML+='>';
                            if(isEditable){
                                InnerHTML+='<textarea cols="50" rows="2" class="InputText " data-id="'+subSectionName+'" ';
                            }
                            if(ContractSettingMap.containsKey(subSectionName)){
                                InnerHTML += isEditable?  '>'+CheckingHighLight(SplitLineIntoRow(ContractSettingMap.get(subSectionName) ,16))+'</textarea></td>'  : CheckingHighLight(SplitLineIntoRow(ContractSettingMap.get(subSectionName) ,16)) + '</td>';
                            }else{
                                InnerHTML+= isEditable?  '>'+SplitLineIntoRow(str, 16)+'</textarea></td>':SplitLineIntoRow(str, 16)+ '</td>';
                            }
                        } else if(str.contains('{InputAmount}')){
                            InnerHTML += ' >' + '<div id="DisplayTotalAmount" >' + totalAmount.format() + '</div></td>';
                        } else {
                            system.debug('DisplayListingTable str1 ='+str);
                            InnerHTML += ' >' + SplitLineIntoRow(str,16)+'</td>';
                        }
                        columnNum++;
                    }
                    InnerHTML+='</tr>';
                }
            }
            InnerHTML+='</table><br/>';
            return InnerHTML;

        } else {
            return '';
        }
    }

    private String GenerateFixCostTable(integer AppendixKey, Map<Integer,ASI_CRM_Contract_Cost__c> FixCostMap, Map<integer, SectionWrapper> ChildMap){
        decimal FXCTotalAmount = 0.0;
        Boolean DisplayTable = false;

        final Map<Id, ASI_CRM_Contract_Cost_Setting__c> contractCostIdSettingsMap
                = ASI_CRM_CN_OffContractGenerationCtrl.getContractCostIdSettingsMap(Id.valueOf(contractId));

        //Calculate total cost of Fixed Cost
        if (FixCostMap.size() > 0){
            for (ASI_CRM_Contract_Cost__c FixCost : FixCostMap.values() ){
                FXCTotalAmount += denullify(FixCost.ASI_CRM_CN_Contract_Amount__c, 0);
            }
        }

        string InnerHTML='<table style="page-break-inside:avoid; border: 1px solid black; border-collapse: collapse; ';
        if(!isEditable){
            InnerHTML+= 'width: 50px ';
        }
        InnerHTML+= '"> ';

        for(integer ChildKey : ChildMap.keySet()){
            String subSectionName = ChildMap.get(ChildKey).name;
            String ContentStr = ChildMap.get(ChildKey).content;
            Boolean DisplayFixCostLine = false;

            if(FixCostMap.size() > 0 && FXCTotalAmount > 0){
                DisplayFixCostLine=true;
                DisplayTable = true;
            }

            if(ContentStr.indexOf('//')>-1 && DisplayFixCostLine){
                List<String> parts = ContentStr.split('//');
                InnerHTML+='<tr style="border: 1px solid black; " >';

                if(subSectionName == 'TableHeader'){
                    //Header
                    //ContentStr Sample: 服务类型//服务要求//金额//备注

                    for(string str:parts){
                        InnerHTML += '<td style="border: 1px solid black;">' + str + '</td>';
                    }
                } else if(subSectionName == 'TableTotal'){
                    //Total of Items
                    //ContentStr Sample: &lt;br/&gt; //   总计： // {FXTotalAmount}  //&lt;br/&gt;

                    for(string str:parts){
                        InnerHTML+='<td style="border: 1px solid black;"> ';
                        if(str.contains('{FXTotalAmount}')){
                            InnerHTML += '<div id="FixCostTotalAmount" >'+FXCTotalAmount.format()+'</div>';
                        } else {
                            InnerHTML += str;
                        }
                        InnerHTML += '</td>';
                    }
                } else if(subSectionName == 'FixCostTable_InputText'){
                    //Remarks under table
                    //ContentStr Sample: 备注：// {InputText}
                    for(string str:parts){
                        InnerHTML+='<td style="border: 1px solid black;"';
                        if (str.contains('{InputText}')){
                            //Handle html class
                            if(AppendixSectionMap.get(AppendixKey).subSectionMap.get(ChildKey).ClassName !=null){
                                InnerHTML+=  ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler(AppendixSectionMap.get(AppendixKey).subSectionMap.get(ChildKey).ClassName);
                                System.debug('Test html class:' + ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler(AppendixSectionMap.get(AppendixKey).subSectionMap.get(ChildKey).ClassName));
                            }
                            InnerHTML+='>';

                            InnerHTML+= isEditable? '<textarea cols="80" rows="3" class="InputText " data-id="FixCostTable_Remark"': '';
                            if(ContractSettingMap.containsKey('FixCostTable_Remark')){
                                InnerHTML += isEditable?  '>' + ContractSettingMap.get('FixCostTable_Remark') + '</textarea></td>'  : CheckingHighLight(SplitLineIntoRow(ContractSettingMap.get('FixCostTable_Remark'),25)) + '</td>';
                            } else {
                                InnerHTML += isEditable? '></textarea></td>':'</td>';
                            }
                        }
                        else {
                            InnerHTML += '">' + str;
                        }
                        InnerHTML += '</td>';
                    }
                } else {
                    //Detail Line
                    for (ASI_CRM_Contract_Cost__c FixCost : FixCostMap.values() ){
                        //Only display item which is amount > 0
                        if(FixCost.ASI_CRM_CN_Contract_Amount__c>0){
                            InnerHTML+='<tr style="border: 1px solid black; ">';
                            Integer elementCount = 0;   //Provide column count for ContractPrintingSetting
                            for(string str:parts){
                                elementCount++;
                                string SavedKey=AppendixSectionMap.get(AppendixKey).name + '_' + FixedCostItemSequenceMap.get(FixCost.ASI_CRM_CN_Chinese_Description__c) + '_' + ChildKey + '_' + String.valueOf(elementCount);
                                //Open table cell and handle class
                                InnerHTML += '<td style="border: 1px solid black;">';
                                if(str.contains('{FixedCostACCode}')){
                                    InnerHTML += TableSplitLineRow(FixCost.ASI_CRM_CN_Chinese_Description__c, 8);
                                } else if(str.contains('{InputAmount}')){
                                    InnerHTML += FixCost.ASI_CRM_CN_Contract_Amount__c.format();
                                } else if(str.contains('{NewField}')){
                                    ASI_CRM_Contract_Cost_Setting__c costSetting = contractCostIdSettingsMap.get(FixCost.Id);
                                    
                                    //2019/12/4 CanterDuan 根据outlet的区域去判断需要显示什么样的服务需求 start
                                    //final String svcReqFromSettings = costSetting.ASI_CRM_CN_Svc_Req__c;
                                    String svvReqFromCost = '';
                                    String svcReqFromSettings = '';
                                    if(OutletArea == 'Central Region'){
                                        svvReqFromCost = FixCost.ASI_CRM_CN_Service_Requirement_Central__c == null ? '': FixCost.ASI_CRM_CN_Service_Requirement_Central__c;
                                        if(costSetting != null) svcReqFromSettings = costSetting.ASI_CRM_CN_Service_Requirement_Central__c == null ? '': costSetting.ASI_CRM_CN_Service_Requirement_Central__c;
                                    }else if(OutletArea == 'East Region'){
                                        svvReqFromCost = FixCost.ASI_CRM_CN_Service_Requirement_East__c == null ? '': FixCost.ASI_CRM_CN_Service_Requirement_East__c;
                                        if(costSetting != null) svcReqFromSettings = costSetting.ASI_CRM_CN_Service_Requirement_East__c == null ? '': costSetting.ASI_CRM_CN_Service_Requirement_East__c;
                                    }else if(OutletArea == 'North Region'){
                                        svvReqFromCost = FixCost.ASI_CRM_CN_Service_Requirement_North__c == null ? '': FixCost.ASI_CRM_CN_Service_Requirement_North__c;
                                        if(costSetting != null) svcReqFromSettings = costSetting.ASI_CRM_CN_Service_Requirement_North__c == null ? '': costSetting.ASI_CRM_CN_Service_Requirement_North__c;
                                    }else if(OutletArea == 'North West Region'){
                                        svvReqFromCost = FixCost.ASI_CRM_CN_Service_Requirement_Northwest__c == null ? '': FixCost.ASI_CRM_CN_Service_Requirement_Northwest__c;
                                        if(costSetting != null) svcReqFromSettings = costSetting.ASI_CRM_CN_Service_Requirement_Northwest__c == null ? '': costSetting.ASI_CRM_CN_Service_Requirement_Northwest__c;
                                    }else if(OutletArea == 'South Region'){
                                        svvReqFromCost = FixCost.ASI_CRM_CN_Svc_Req__c == null ? '': FixCost.ASI_CRM_CN_Svc_Req__c;
                                        if(costSetting != null) svcReqFromSettings = costSetting.ASI_CRM_CN_Svc_Req__c == null ? '': costSetting.ASI_CRM_CN_Svc_Req__c;
                                    }else if(OutletArea == 'South West Region'){
                                        svvReqFromCost = FixCost.ASI_CRM_CN_Service_Requirement_Southwest__c == null ? '': FixCost.ASI_CRM_CN_Service_Requirement_Southwest__c;
                                        if(costSetting != null) svcReqFromSettings = costSetting.ASI_CRM_CN_Service_Requirement_Southwest__c == null ? '': costSetting.ASI_CRM_CN_Service_Requirement_Southwest__c;
                                    }
                                    if(svvReqFromCost != null && svvReqFromCost != '') {
                                        InnerHTML +=  '<textarea cols="60" rows="3" class="InputText" style="width: 300px !important;">' + repla(svvReqFromCost,16) + '</textarea>';
                                    } else{
                                        InnerHTML +=  '<textarea cols="60" rows="3" class="InputText" style="width: 300px !important;">' + repla(svcReqFromSettings,16) + '</textarea>';
                                    }
                                    /*if(String.isNotBlank(FixCost.ASI_CRM_CN_Svc_Req__c)) {
                                        InnerHTML +=  '<textarea cols="60" rows="3" class="InputText" style="width: 300px !important;">' + SubStringFile(FixCost.ASI_CRM_CN_Svc_Req__c) + '</textarea>';
                                    } else{
                                        InnerHTML +=  '<textarea cols="60" rows="3" class="InputText" style="width: 300px !important;">' + SubStringFile(svcReqFromSettings) + '</textarea>';
                                    }*/
                                    //2018/12/4 CanterDuan end
                                }
                                else {
                                    if(ContractSettingMap.containsKey(SavedKey)){
                                        if (isEditable){
                                            InnerHTML += '<textarea cols="60" rows="3" class="InputText " data-id="'+SavedKey+'" style="width: 200px !important;" ';
                                            if (elementCount == 4){
                                                InnerHTML += ' FixCost-Line="' + FixCost.Id + '"';
                                            }
                                            InnerHTML += ' >' + ContractSettingMap.get(SavedKey) + '</textarea>';
                                        } else {
                                            InnerHTML += CheckingHighLight(SplitLineIntoRow(ContractSettingMap.get(SavedKey),8));
                                        }
                                    } else {
                                        if (isEditable){
                                            InnerHTML += '<textarea cols="60" rows="3" class="InputText " data-id="'+SavedKey+'" style="width: 200px !important;" ';
                                            if (elementCount == 4){
                                                InnerHTML += ' FixCost-Line="' + FixCost.Id + '"';
                                            }
                                            InnerHTML += ' >' + str + '</textarea>';
                                        }
                                    }
                                }
                            }
                            InnerHTML += '</tr>';
                        }
                    }
                }
                InnerHTML+='</tr>';
            }
        }

        InnerHTML+=endTable;
        if(!DisplayTable){
            InnerHTML='';
        }
        return InnerHTML;
    }

    public String SubStringFile(String str)
    {
        String retStr = '';
        if(str != null && str != '')
        {
            str = str.replaceAll('<br/>','');
            String regex = '(.{16})';
            retStr = str.replaceAll(regex, '$1<br/>');
        }

        return retStr;
    }
    //2019/12/4 CanterDuan 添加用于换行的方法 start
    public String repla(String str,Integer size){
        String tempStr = '';
        Integer startSize =0;
        Integer endSize = size;
        for(Integer i = 0;i <= str.length()/size ;i++)
        {
            if(endSize>=str.length()){
                endSize=str.length();
            }
            tempStr=tempStr+'\n'+str.substring(startSize,endSize);
            startSize = startSize+size;
            endSize = endSize+size;

        }
        return tempStr;
    }
    //2019/12/4 CanterDuan end

    //************* Generating Covered Outlet Table**********************
    public String GeneratingCoveredOutletTable(){
        string InnerHTML='<br/><table  style=" page-break-inside:avoid;border: 1px solid black; border-collapse: collapse; ';


        if(!isEditable){
            InnerHTML+= 'width: 50px ';
        }
        InnerHTML+= '" > <tr> <td style="border: 1px solid black;  text-align: left; " > 店名</td><td style="border: 1px solid black;  text-align: left; " >官方名称</td><td style="border: 1px solid black;  text-align: left; " >地址</td></tr>  ';


        //Add current outlet
        String LegalNameString = ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
            LegalNameString= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
        }
        InnerHTML+='<tr><td style="border: 1px solid black;  text-align: left; ">'+
                ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name)+
                '</td><td style="border: 1px solid black;  text-align: left; ">'+LegalNameString+'</td><td style="border: 1px solid black;  text-align: left; ">';
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Address__c!=null){
            InnerHTML+=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Address__c;
        }
        InnerHTML+='</td></tr>';


        //Covered Outlet
        for(ASI_CRM_CN_Covered_Outlet__c CoveredOutlet:CoveredOutletList){
            LegalNameString = ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(CoveredOutlet.Name);
            if(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c!=null){
                LegalNameString=LineBreakProcess(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c,10,5) ;
            }
            InnerHTML+='<tr><td style="border: 1px solid black;  text-align: left; ">'+ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(CoveredOutlet.ASI_CRM_CN_Outlet__r.Name)+'</td><td style="border: 1px solid black;  text-align: left; ">'+LegalNameString+'</td><td style="border: 1px solid black;  text-align: left; ">';
            if(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Address__c!=null){
                InnerHTML+=LineBreakProcess(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Address__c,12,5);
            }
            InnerHTML+='</td></tr>';
        }
        InnerHTML +=endTable;
        return InnerHTML;//return '';
    }


    public void ReOrdering(){
        //Re-Ordering
        Integer HeaderLineNumber=1;
        for(integer key : AppendixSectionMap.keySet()) {
            //reordering PSF Number
            Integer PSFModuleNumber=1;
            //Comment 20180302 unknown reason
            if (AppendixSectionMap.get(key).name == 'SalesDiscount' && !ContractSelected.ASI_CRM_CN_Is_Dolphin__c) {
                for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber !=null &&  AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber !=''){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber=string.valueOf(HeaderLineNumber-1)+'.'+string.valueOf(PSFModuleNumber);
                        PSFModuleNumber++;
                    }
                }
            }

            //Ordering
            if(AppendixSectionMap.get(key).ClassName!=null && AppendixSectionMap.get(key).displayNumber!=null && AppendixSectionMap.get(key).ClassName!='' && AppendixSectionMap.get(key).displayNumber!='' && AppendixSectionMap.get(key).ClassName=='AppendixLineHeader'){
                AppendixSectionMap.get(key).displayNumber=string.valueOf(HeaderLineNumber);
                HeaderLineNumber++;
            }

            if( AppendixSectionMap.get(key).name =='Payment Conditions' && !isEditable){
                Integer OrderNumber=1;
                for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber=String.valueOf(OrderNumber)+')';
                        OrderNumber++;
                    }
                }
            }
        }


    }

    public String UpdateInputAmount(String ContentName,String InputContent,String KeyString){
        String ReturnContent='';
        String DataId=ContentName+KeyString;
        if(ContractSettingMap.containsKey(DataId)){
            String value= ContractSettingMap.get(DataId);
            if (!isEditable) {
                ReturnContent= InputContent.replace('{'+KeyString+'}', value );
            }else{
                if(KeyString.contains('Percent') || KeyString.contains('Amount')){
                    ReturnContent= InputContent.replace('{'+KeyString+'}', '<input type="text" class="InputAmount RequiredField" data-id="'+DataId+'" value="'+value+'" />');
                }else{
                    ReturnContent= InputContent.replace('{'+KeyString+'}', '<input type="text" class="InputAmount " data-id="'+DataId+'" value="'+value+'" />');
                }
            }
        }else if(isEditable){
            if(KeyString.contains('Percent')  ){
                ReturnContent= InputContent.replace('{'+KeyString+'}', '<input type="text" class="InputAmount RequiredField" data-id="'+DataId+'" placeholder="25/50/75/100" />');
            }else{
                ReturnContent= InputContent.replace('{'+KeyString+'}', '<input type="text" class="InputAmount RequiredField" data-id="'+DataId+'" />');
            }
        }
        return ReturnContent;
    }

    public String DrawingBRSFTable(List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList,SectionWrapper ChildMap ,ASI_CRM_Module__c module ,List<String> parts ,List<String> base ,String contractModuleBase){

        String InnerHTML='  <table style="page-break-inside:avoid; border: 1px solid black; border-collapse: collapse;    ';
        if(!isEditable){
            InnerHTML+= 'width:50px  ';
        }
        InnerHTML += '"  >';
        Decimal MonthlyVolume  = 0.0;
        Decimal MonthlyIncentive =0.0;
        Decimal ContractTotalVolume  = 0.0;
        Decimal ContractTotalAmount=0.0;
        // ContentStr= 产品名称和规格//销量目标&lt;br/&gt;(瓶),,产品名称和规格//销售额目标&lt;br/&gt;(元)

        String ModuleId = module.Id;
        // for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:BRSFList){
        //     if(BRSFLine.ASI_CRM_Module__c!=null && ModuleId==''){
        //         ModuleId = BRSFLine.ASI_CRM_Module__c;
        //     }
        // }
        // ASI_CRM_Module__c module = [SELECT ASI_CRM_CN_Volume_Value_Base__c from ASI_CRM_Module__c where id = :ModuleId LIMIT 1];
        // contractModuleBase = module.ASI_CRM_CN_Volume_Value_Base__c;


        //If value based, additionally add 合同期目标销售额XXXX元 into option
        String additionalValueBaseContent;

        if (contractModuleBase == null){
            system.debug('Module Base not found');
            InnerHTML += endTable;
            return InnerHTML;
        }

        // List<String> base = ContentStr.split(',,');




        //parts = base.get(0).split('//');
        InnerHTML+='<tr style="border: 1px solid black; " >';

        for(string str:parts){
            InnerHTML+='<td style="border: 1px solid black; " >'+str+'</td>';
        }
        InnerHTML+='</tr>';
        Integer i = 0 ;
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:BRSFList){
            if(BRSFLine.ASI_CRM_Module__c!=null && ModuleId==''){
                ModuleId=BRSFLine.ASI_CRM_Module__c;
            }
            String SubBrandName= BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c==null? BRSFLine.ASI_CRM_CN_Sub_Brand__r.Name: BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c;
            if(!isEditable){
                SubBrandName= SplitLineIntoRow(SubBrandName,10);
            }
            Decimal TotalVolume = BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c != null ? BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractSelected.ASI_CRM_CN_No_of_Months__c : 0;

            Decimal TotalDummy  = BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c!= null?BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            TotalDummy = TotalDummy.round(System.RoundingMode.FLOOR);

            ContractTotalVolume+=TotalVolume;
            ContractTotalAmount+=BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c!= null?BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            InnerHTML += '<tr style="border: 1px solid black; "><td style="border: 1px solid black; " >'+SubBrandName+'</td><td style="border: 1px solid black;  text-align: right; ">';
            InnerHTML += (contractModuleBase == 'Volume') ? TotalVolume.format() : TotalDummy.format();
            InnerHTML += '</td>';
            if (ContractSelected.ASI_CRM_CN_Is_Dolphin__c && i == 0) {

                String storageRemark = [SELECT Id, ASI_CRM_Contract__c, ASI_CRM_Content_Section_Name__c, ASI_CRM_Header_Section_Name__c,
                        ASI_CRM_Section_Content__c, ASI_CRM_isVisible__c
                FROM ASI_CRM_Contract_Printout_Setting__c
                WHERE ASI_CRM_Contract__c = :contractId AND ASI_CRM_Content_Section_Name__c = 'Remark1' LIMIT 1]?.ASI_CRM_Section_Content__c;

                String remark1 = '1. 甲方必须完成合同总采购额目标' + PSFModule2Min +'%以上才能申请达标折扣';
                String remark2 = '2. 达标折扣将在合同期结束后进行评估并支付';
                String remark = String.isBlank(storageRemark)?(remark1+ '\n'+remark2): storageRemark;
                if (isEditable) {
                    remark = remark.replaceAll(lineBreak, '');
                    remark = '<textarea style="" cols="30" rows="' + (BRSFList.size() + 4)+'" class="InputText Remark1" data-id="Remark1">' + remark+'</textarea>';
                } else {
                    remark = SplitLineIntoRow(remark.replaceAll('\n', lineBreak), 12);
                }
                InnerHTML += '<td style="border: 1px solid black; text-align: center;vertical-align: top;" rowspan="'+ (BRSFList.size() + 1)+'">'+ PSFModule2Rebate.setScale(2) +
                            '%</td><td style="border: 1px solid black;  text-align: left; " rowspan="'+ (BRSFList.size() + 1)+'">'+ remark +'</td>';
            }
            i ++;
        }
        InnerHTML += '<tr style="border: 1px solid black; "><td style="border: 1px solid black; " >总计</td><td style="border: 1px solid black;  text-align: right; ">';
        InnerHTML += (contractModuleBase == 'Volume') ? ContractTotalVolume.format() : ContractTotalAmount.round(System.RoundingMode.FLOOR).format();
        InnerHTML += '</td>';

        //Footer
        if(ChildMap.subSectionMap!=null){
            for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                SectionType SectionTypeClass = ClassNameHandler(ChildMap.subSectionMap.get(InnerKey).ClassName);
                parts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                InnerHTML+='<tr style="border: 1px solid black; ">';
                integer columnNum=1;
                for(string str:parts){
                    InnerHTML+= '<td style="border: 1px solid black; " ';
                    if(columnNum ==SectionTypeClass.StyleStringColumnNum){
                        InnerHTML+=SectionTypeClass.StyleString;
                    }
                    if(SectionTypeClass.ClassType=='InputText' && columnNum ==SectionTypeClass.ClassTypeColumnNum){
                        InnerHTML+='>';
                        if(isEditable){
                            InnerHTML+='<textarea cols="50" rows="3" class="InputText " data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+'"  Module-Id="'+ModuleId+'"';

                        }


                        if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name)){

                            String NoteStr= isEditable?  '>'+ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name)+'</textarea>'  : CheckingHighLight(SplitLineIntoRow( ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name) ,25));
                            InnerHTML+= NoteStr + '</td>';
                        }else{
                            InnerHTML+= isEditable?  '   >'+str+'</textarea></td>':str+ '</td>';
                        }
                    }else{
                        InnerHTML+='  >'+ SplitLineIntoRow(str,25)+'</td>';
                    }
                    columnNum++;
                }
                InnerHTML+='</tr>';
            }
        }
        InnerHTML+=endTable;

        return InnerHTML;
    }

    /*
     * *********************************************
     * Drawing PSF Table
     * Guide for template creation:
     * ============================================
     * Header - Under Subsection of PSFTable
     * The name must contains the word "Header"
     * The type for the table are marked in class, the acceptable class name can be refered to the constant started with prefix "TABLE_TYPE_"
     * SummaryFooter -
     * Under subsection of PSFTable
     * Name = PSFTable_total
     * No class is needed and will adjust by the table type of the contract PSF Module
     * Footer - Under Subsection of PSFTable
     * The name must contains the word "Footer"
     * The type for the table are marked in class, the acceptable class name can be refered to the constant started with prefix "TABLE_TYPE_"
     * **********************************************
     */
    public String DrawingPSFTable(String ContentStr,Map<String,interimData> PSF_Item_Map,SectionWrapper ChildMap){
        integer ModuleNumber=0;
        string ReturnHTML='';
        String tableTypeName = '';
        for(String key:PSF_Item_Map.keySet()){
            interimData PSFItem = PSF_Item_Map.get(key);

            String remarksDefaultValue;
            String InnerHTML='';
            Boolean isTable = true;

            ModuleNumber++;
            Decimal TotalMonthlyVolume  = 0.0;
            Decimal TotalMonthlyIncentive = 0.0;
            Decimal TotalVolume  = 0.0;
            Decimal ContractTotal = 0.0;

            //Header
            //Key = Methodology + VolumeBase + Criteria (empty if null)
            String headerKey = PSF_Item_Map.get(key).Methodology + ';' + PSF_Item_Map.get(key).VolumeBase;
            if (PSF_Item_Map.get(key).Criteria != null){
                headerKey += ';' + PSF_Item_Map.get(key).Criteria;
            } else {
                headerKey += ';NA';
            }
            tableTypeName = PSFHeaderMap.get(headerKey);
            system.debug('获取的类型有：' + tableTypeName + '/;' + headerKey);
            //Quick fix to get Remarks of ReachXGetY
            //TODO: Revamp design of handling Remarks in the content for PSF Table
            if(tableTypeName == TABLE_TYPE_REACH_X_GET_Y && ChildMap.subSectionMap !=null){
                for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                    if (ChildMap.subSectionMap.get(InnerKey).name.contains('Header') && ChildMap.subSectionMap.get(InnerKey).ClassName.contains(tableTypeName)){
                        List<String> parts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                        for (String part : parts){
                            //Get Remarks Template
                            if (part.contains('::')){
                                remarksDefaultValue = part.split('::')[1];
                            }
                        }
                        break;
                    }
                }
            }
            //End Quick fix

            //Special Table Type Handling
            if (tableTypeName == null) continue;
            if (tableTypeName == TABLE_TYPE_REBATE_BY_LADDER || tableTypeName == TABLE_TYPE_REBATE_BY_TAX){
                system.debug('headerKey:' + headerKey);
                system.debug('tableTypeName:' + tableTypeName);
                system.debug('key ==' + key);
                InnerHTML += drawLadderTable(tableTypeName, PSFItem, ChildMap, key);

                ReturnHTML += InnerHTML;
                continue;
            }
            if (tableTypeName == TABLE_TYPE_OTHER)
                isTable = false;

            InnerHTML += generatePSFHeader(tableTypeName, ChildMap, isTable, PSFItem);



            //PSF Table Body
            for(String keyline:PSF_Item_Map.get(key).DetailLineMap.keySet()){
                ASI_CRM_CN_Contract_BRSF_Line_Item__c contractDetailLine = PSFDetailLine(PSF_Item_Map, key, keyline);
                String contractLineHTML = '';
                if (tableTypeName == TABLE_TYPE_PER_INCENTIVE){
                    //Per incentive must be sub-brand
                    String SubBrandTempName = contractDetailLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c!=null? contractDetailLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c:contractDetailLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    String SubBrandName = isEditable ? SubBrandTempName : SplitLineIntoRow(SubBrandTempName,8);
                    Decimal YearlyTotalVolume= contractDetailLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? contractDetailLine.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractSelected.ASI_CRM_CN_No_of_Months__c:0;

                    InnerHTML += newTableRow + tableCell(SubBrandName);
                    InnerHTML += tableCell(denullify(contractDetailLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, 0).format(), 'text-align: right;') ;
                    InnerHTML += tableCell(YearlyTotalVolume.format(), 'text-align: right;');
                    //InnerHTML += tableCell(contractDetailLine.ASI_CRM_CN_Contract_Total_Dummy__c.format(), 'text-align: right;');
                    InnerHTML += endTableRow;

                    TotalMonthlyVolume += contractDetailLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? contractDetailLine.ASI_CRM_CN_Contract_Monthly_Qty__c: 0.0;
                    TotalMonthlyIncentive += contractDetailLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c !=null? contractDetailLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c: 0.0;
                    TotalVolume += YearlyTotalVolume!=null? YearlyTotalVolume:0;
                    ContractTotal += contractDetailLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? contractDetailLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                } else if (tableTypeName == TABLE_TYPE_ACTUAL_ACHIEVEMENT ||
                        tableTypeName == TABLE_TYPE_REACH_X_GET_Y ||
                        tableTypeName == TABLE_TYPE_REBATE_PERCENTAGE){
                    Decimal lineValue;

                    //By Sub-Brand
                    if(VolumeBaseNamingFixing(PSF_Item_Map.get(key).VolumeBase) == GROUPBASE_BY_SUBBRAND){
                        String SubBrandTempName = contractDetailLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c!=null? SplitLineIntoRow(contractDetailLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c ,4):SplitLineIntoRow(contractDetailLine.ASI_CRM_CN_Sub_Brand__r.Name ,4);
                        String SubBrandName = isEditable ? SubBrandTempName : SplitLineIntoRow(SubBrandTempName,8);
                        contractLineHTML += newTableRow + tableCell(SubBrandName);
                    }

                    //By Category
                    if(VolumeBaseNamingFixing(PSF_Item_Map.get(key).VolumeBase) == GROUPBASE_BY_CATEGORY){
                        String CategoryName= contractDetailLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? SplitLineIntoRow(contractDetailLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c ,4)  : SplitLineIntoRow( contractDetailLine.ASI_CRM_Product_Category__r.Name ,4) ;
                        /*if (contractDetailLine.ASI_CRM_Module__r.ASI_CRM_Unit__c == UNIT_CR12){
                            CategoryName += ' (CR12)';
                        }*/
                        contractLineHTML += newTableRow + tableCell(CategoryName);
                    }

                    //By Total
                    if(VolumeBaseNamingFixing(PSF_Item_Map.get(key).VolumeBase) == GROUPBASE_BY_TOTAL){
                        contractLineHTML += newTableRow;
                        //Change for request: All contract should use Standard Bottle instead of CR12
                        //contractLineHTML += contractDetailLine.ASI_CRM_Module__r.ASI_CRM_Unit__c == UNIT_CR12 ? tableCell('按总销量 (CR12)') : tableCell('按总销量');
                        contractLineHTML += tableCell('按总销量');
                    }

                    //For Reach X Get Y and Rebate %, show 年销售额指标 (ASI_CRM_CN_Target__c)
                    //For Actual Achievement, show 年销量指标 (ASI_CRM_Contract_Total_QTY_std_Btl__c / ASI_CRM_Contract_Total_QTY_CR12_Eqv__c)
                    if (tableTypeName == TABLE_TYPE_REACH_X_GET_Y || tableTypeName == TABLE_TYPE_REBATE_PERCENTAGE){
                        lineValue = denullify(contractDetailLine.ASI_CRM_CN_Contract_Purchase_Value__c, 0).round(System.RoundingMode.FLOOR);
                        contractLineHTML+= tableCell(lineValue.format(),'text-align: right;');
                    } else {
                        /*
                        if (contractDetailLine.ASI_CRM_Module__r.ASI_CRM_Unit__c == UNIT_CR12){
                            lineValue = denullify(contractDetailLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c, 0);
                        } else {
                            lineValue = denullify(contractDetailLine.ASI_CRM_Contract_Total_QTY_std_Btl__c, 0);
                        }
                        */
                        //Change for request: All contract should use Standard Bottle instead of CR12
                        lineValue = denullify(contractDetailLine.ASI_CRM_Contract_Total_QTY_std_Btl__c, 0);
                        contractLineHTML+= tableCell(lineValue.format(),'text-align: right;');
                        TotalVolume += lineValue;
                    }

                    //For Rebate %, 年销售额达成折扣 should be Rebate%
                    if (tableTypeName == TABLE_TYPE_REBATE_PERCENTAGE){
                        contractLineHTML += tableCell(denullify(contractDetailLine.ASI_CRM_CN_Rebate_Percent__c, 0).format() + '%', 'text-align: right;');
                    } else {
                        contractLineHTML += tableCell(contractDetailLine.ASI_CRM_CN_Contract_Total_Dummy__c.format(), 'text-align: right;');
                    }

                    //For Reach X Get Y, show extra column of Remarks
                    if (tableTypeName == TABLE_TYPE_REACH_X_GET_Y) {
                        String remarks = remarksDefaultValue;
                        if(remarksDefaultValue.contains('{RebateAmount}') && contractDetailLine.ASI_CRM_CN_Rebate__c != null){
                            remarks = remarks.replace('{RebateAmount}', String.ValueOf(contractDetailLine.ASI_CRM_CN_Rebate__c.format()));
                        }
                        else{
                            remarks = remarks.replace('{RebateAmount}', ' ');
                        }
                        if(remarksDefaultValue.contains('{RebateTarget}') && contractDetailLine.ASI_CRM_CN_Target__c != null){
                            remarks = remarks.replace('{RebateTarget}', String.ValueOf(contractDetailLine.ASI_CRM_CN_Target__c.format()));
                        }
                        else{
                            remarks = remarks.replace('{RebateTarget}', ' ');
                        }
                        if(remarksDefaultValue.contains('{RebatePercent}') && contractDetailLine.ASI_CRM_CN_Rebate_Percent__c != null){
                            remarks = remarks.replace('{RebatePercent}', String.ValueOf(contractDetailLine.ASI_CRM_CN_Rebate_Percent__c));
                        }
                        else{
                            remarks = remarks.replace('{RebatePercent}', ' ');
                        }
                        contractLineHTML += tableCell(remarks);
                    }


                    contractLineHTML += endTableRow;

                    //Hide Product Category line if contract amount = 0
                    if(!(VolumeBaseNamingFixing(PSF_Item_Map.get(key).VolumeBase) == GROUPBASE_BY_CATEGORY && lineValue == 0)){
                        InnerHTML += contractLineHTML;
                        //TODO: Discuss how we get Total value
                        ContractTotal+=PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Total_Dummy__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Total_Dummy__c:0;
                    }


                }
            }//Ending of looping

            //Footer
            if(ChildMap.subSectionMap!=null  ){
                for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                    
                    if(ChildMap.subSectionMap.get(InnerKey).name=='PSFTable_total'){
                        // Display Total Amount
                        /*  TABLE_TYPE_PER_INCENTIVE
                            产品列表//单瓶销售折扣//销量目标

                            TABLE_TYPE_ACTUAL_ACHIEVEMENT
                            产品列表//年销量指标（元）//年达标销售折扣(元)  */

                        if (tableTypeName == TABLE_TYPE_PER_INCENTIVE || tableTypeName == TABLE_TYPE_ACTUAL_ACHIEVEMENT){
                            InnerHTML += newTableRow + tableCell(ChildMap.subSectionMap.get(InnerKey).content);

                            if (tableTypeName == TABLE_TYPE_PER_INCENTIVE){
                                InnerHTML += tableCell('');
                            }
                            InnerHTML += tableCell(TotalVolume.format(), 'text-align: right;');
                            if (tableTypeName == TABLE_TYPE_ACTUAL_ACHIEVEMENT){
                                InnerHTML += tableCell(ContractTotal.format(), 'text-align: right;');
                            }
                            InnerHTML += endTableRow;
                        }
                    } else if(ChildMap.subSectionMap.get(InnerKey).name=='PSFTable_HeaderTerm'){
                        if(ChildMap.subSectionMap.get(InnerKey).ClassName.contains(VolumeBaseNamingFixing(PSF_Item_Map.get(key).VolumeBase) ) ){
                            InnerHTML = String.valueOf(ModuleNumber)+')'+ ChildMap.subSectionMap.get(InnerKey).content+InnerHTML ;
                        }
                    } else {
                        Boolean DisplayFlag= false;
                        SectionType SectionTypeClass = ClassNameHandler(ChildMap.subSectionMap.get(InnerKey).ClassName);

                        if(ChildMap.subSectionMap.get(InnerKey).name.contains('Footer') && ((SectionTypeClass.VolumeBase != null && SectionTypeClass.VolumeBase == '') ||
                                (tableTypeName == SectionTypeClass.VolumeBase))){
                            DisplayFlag=true;
                        }
                        if(DisplayFlag){
                            
                            if (isTable){
                                InnerHTML += newTableRow;
                            }

                            //List<String> FooterParts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                            String NowContent=ChildMap.subSectionMap.get(InnerKey).content;
                            NowContent = StringCaseHandlerPSF(NowContent,TotalMonthlyVolume,ContractTotal, PSFItem);
                            system.debug('包含footer的 NowContent ==' + NowContent);
                            if(ChildMap.subSectionMap.get(InnerKey).content.right(2)=='//'){
                                NowContent+='  ';
                            }
                            List<String> FooterParts = NowContent.split('//');

                            integer columnNum=1;
                            for(string str:FooterParts){
                                
                                if(SectionTypeClass.ClassType=='InputText' && columnNum ==SectionTypeClass.ClassTypeColumnNum){
                                    if (isTable){
                                        InnerHTML+= '<td ';
                                        if(SectionTypeClass.TableStyleMap.containsKey(columnNum)){
                                            InnerHTML+=SectionTypeClass.TableStyleMap.get(columnNum);
                                        }
                                        InnerHTML+=' style="border: 1px solid black; " >';
                                    }

                                    if(isEditable){
                                        InnerHTML+='<textarea cols="50" rows="3" class="InputText " Module-Id="'+key+'"  data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+key+'"  ';
                                    }

                                    if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name+key)){
                                        String NoteStr= isEditable?  ' style="border: 1px solid black; " >'+ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key)+'</textarea>'  : CheckingHighLight(SplitLineIntoRow( ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key) ,30));
                                        InnerHTML+= NoteStr;
                                        if (isTable){
                                            InnerHTML += '</td>';
                                        }
                                    }else{
                                        if (str.trim().length()==0){
                                            str='';
                                        }
                                        InnerHTML+= isEditable? ' style="border: 1px solid black; " >'+str+'</textarea>':SplitLineIntoRow(str, 30)+ '<br/>';
                                        if (isTable){
                                            InnerHTML += '</td>';
                                        }
                                    }
                                }else if(SectionTypeClass.ClassType=='Selectable' && columnNum ==SectionTypeClass.ClassTypeColumnNum){

                                    if(isEditable){
                                        InnerHTML+= '<td ';
                                        if(SectionTypeClass.TableStyleMap.containsKey(columnNum)){
                                            InnerHTML+=SectionTypeClass.TableStyleMap.get(columnNum);
                                        }

                                        if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name+key)){
                                            if(ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key)=='true'){
                                                InnerHTML+=' style="border: 1px solid black; "  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+key+'" Module-Id="'+key+'"  checked="true" />';
                                            }else{
                                                InnerHTML+=' style="border: 1px solid black; "  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+key+'" Module-Id="'+key+'"   />';
                                            }
                                        }else{//default
                                            InnerHTML+=' style="border: 1px solid black; "  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+key+'" Module-Id="'+key+'"   checked="true" />';
                                        }

                                        String TempString = CheckingHighLight(SplitLineIntoRow(str,28));
                                        InnerHTML+= '<span>'+TempString +'</span></td>';
                                    }else{//PDF

                                        if(ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key)=='true'){

                                            if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name+key)){
                                                InnerHTML+= '<td ';
                                                if(SectionTypeClass.TableStyleMap.containsKey(columnNum)){
                                                    InnerHTML+=SectionTypeClass.TableStyleMap.get(columnNum);
                                                }
                                                String TempString =str;
                                                TempString= CheckingHighLight(SplitLineIntoRow(TempString,28));
                                                InnerHTML+=' style="border: 1px solid black; " >'+TempString+'</td>';
                                            }
                                        }
                                    }

                                } else {
                                    if ((!ChildMap.subSectionMap.get(InnerKey).name.contains('Header')) || (!ChildMap.subSectionMap.get(InnerKey).name.contains('Footer'))){
                                        InnerHTML+= '<td ';
                                        if(SectionTypeClass.TableStyleMap.containsKey(columnNum)){
                                            InnerHTML+=SectionTypeClass.TableStyleMap.get(columnNum);
                                        }

                                        InnerHTML+='  style="border: 1px solid black; "  >'+SplitLineIntoRow(str,28)+'</td>';
                                    }
                                }
                                columnNum++;
                            }
                            if (isTable){
                                InnerHTML+='</tr>';
                            }
                        }
                    }
                    system.debug('end --- InnerHTML ==' + InnerHTML);
                }
            }
            if (isTable){
                InnerHTML += '</table><br/>';
            }
            ReturnHTML += InnerHTML;
            system.debug('InnerHTML - ' + key + '-' + ReturnHTML);
        }
        return ReturnHTML;
    }


    public String generatePSFHeader(String tableTypeName, SectionWrapper childMap, Boolean isTable, InterimData PSFItem){
        //Open Table and row
        String headerHTML = '';


        //QuickFix for getting ModuleTemplate for Other
        Decimal contractTotal = 0;
        if(!isTable){
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c contractLine : PSFItem.DetailLineMap.values()){
                contractTotal += denullify(contractLine.ASI_CRM_CN_Contract_Total_Dummy__c, 0);
            }
        }
        //End QuickFix

        headerHTML+=lineBreak;
        if (isTable ){
            if(isEditable)
            {
                headerHTML += '<table style="page-break-inside:avoid; width:100%;border: 1px solid black; border-collapse: collapse;"><tr style="border: 1px solid black;">';
            }
            else 
            {
                 headerHTML += '<table style="page-break-inside:avoid; width:50px;border: 1px solid black; border-collapse: collapse;"><tr style="border: 1px solid black;">';
            }
        }

        if((!String.isBlank(tableTypeName)) && ChildMap.subSectionMap !=null){
            for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                if (ChildMap.subSectionMap.get(InnerKey).name.contains('Header') && ChildMap.subSectionMap.get(InnerKey).ClassName.contains(tableTypeName)){
                    //QuickFix
                    if(!isTable)
                        ChildMap.subSectionMap.get(InnerKey).content = StringCaseHandlerPSF(ChildMap.subSectionMap.get(InnerKey).content,0,contractTotal, PSFItem);
                    //End QuickFix
                    system.debug('Found right header:' + tableTypeName);
                    List<String> parts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                    for (String part : parts){
                        if (part.contains('::')){
                            if (part.split('::')[0] != null){
                                part = part.split('::')[0];
                            }
                        }
                        headerHTML += isTable ? tableCell(part) : span(part + lineBreak);
                    }
                    break;
                }
            }
        }

        //Close header row
        if (isTable){
            headerHTML+= endTableRow;
        }
        system.debug('Bowen generatePSFHeader= '+headerHTML);
        return headerHTML;
    }


    //drawLadderTable: Draw one Ladder/Tax Table for a module
    public String drawLadderTable(String TableTypeName, InterimData PSFItem, SectionWrapper ChildMap, String key){

        String fullRemarks = '', remarksMaximumTemplate = '', remarksMediumTemplate = '', remarksMinimumTemplate = '', remarksFixTemplate = '', remarksAchEvementTemplate = '';
        String tableHTML = '';
        Boolean DisplayFlag= false;
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractLineList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        contractLineList.addAll(PSFItem.DetailLineMap.values());


        Boolean isCapped = false;
        if (contractLineList.size() > 0 && contractLineList.get(0).ASI_CRM_Module__r.ASI_CRM_CN_Is_Capped__c)
            isCapped = true;

        List<String> remarksLineList = new List<String>();
        //Get Suitable Footer Remarks by TableTypeName and isCapped
        for(integer InnerKey : ChildMap.subSectionMap.keySet()){
            SectionWrapper subSectionLine = ChildMap.subSectionMap.get(InnerKey);
            SectionType SectionTypeClass = ClassNameHandler(subSectionLine.ClassName);


            //1. PSF Item is matched witht the class AND
            //2. The Section Name contains 'Footer'
            if(subSectionLine.name.contains('Footer') && ((SectionTypeClass.VolumeBase != null && SectionTypeClass.VolumeBase == '') || (tableTypeName == SectionTypeClass.VolumeBase))){
                DisplayFlag=true;
                //1. The PSF Item is By Tax OR
                //2. The PSF Item is By Ladder AND
                //  2.1 Match the class isCapped with the Module
                if ((TableTypeName == TABLE_TYPE_REBATE_BY_TAX) ||
                        (TableTypeName == TABLE_TYPE_REBATE_BY_LADDER) &&
                        ((isCapped && SectionTypeClass.additionalInfo.contains('isCapped')) ||
                                (!isCapped && SectionTypeClass.additionalInfo.contains('NotCapped')))){
                    fullRemarks = subSectionLine.content;

                    system.debug('subSectionLine.name =='+ subSectionLine.name);
                    system.debug('TableTypeName =='+ TableTypeName);
                    system.debug('isCapped =='+ isCapped);

                    system.debug('fullRemarks =='+ fullRemarks);
                    //Get the latter part without "备注"
                    remarksLineList = fullRemarks.split('//');
                    system.debug('remarksLineList =='+ remarksLineList);
                    List<String> remarksCategoryLineList = !remarksLineList.isEmpty() ? remarksLineList.get(remarksLineList.size() - 1).split('::') : new List<String>();
                    system.debug('remarksCategoryLineList =='+ remarksCategoryLineList);
                    system.debug('Canter remarksCategoryLineList =='+ remarksCategoryLineList.size());
                    //TODO: Make it better?
                    // if (remarksCategoryLineList.size() >= 1)
                    system.debug('remarksFixTemplate begin =='+ remarksFixTemplate);
                    
                    if (remarksCategoryLineList.size() >= 1 && (remarksFixTemplate == null || remarksFixTemplate == ''))
                    {
                        remarksFixTemplate += denullify(remarksCategoryLineList.get(0), '');
                        system.debug('remarksFixTemplate if=='+ remarksFixTemplate);
                    }
                        
                    if (remarksCategoryLineList.size() >= 2)
                        remarksMaximumTemplate += denullify(remarksCategoryLineList.get(1), '');
                    if (remarksCategoryLineList.size() >= 3)
                        remarksMediumTemplate += denullify(remarksCategoryLineList.get(2), '');
                    if (remarksCategoryLineList.size() >= 4)
                        remarksMinimumTemplate += denullify(remarksCategoryLineList.get(3), '');
                }
            }
        }
        //Generate Header
        tableHTML += generatePSFHeader(TableTypeName, ChildMap, true, PSFItem);

        //Generate Content and put data into Remarks
        ASI_CRM_CN_Contract_BRSF_Line_Item__c maxLine, minLine;
        Map<Decimal, ASI_CRM_CN_Contract_BRSF_Line_Item__c> mediumMap = new Map<Decimal, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<Decimal> maxValueList = new List<Decimal>();

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractDetailLine:PSFItem.DetailLineMap.values()){
            //Contract Detail Line is sorted in ascending order?
            //Content: 销售目标, 销售折扣
            Decimal purchaseValue;
            if (tableTypeName == TABLE_TYPE_REBATE_BY_TAX){
                purchaseValue = contractDetailLine.ASI_CRM_CN_Max_Purchase_Target__c != null ? contractDetailLine.ASI_CRM_CN_Max_Purchase_Target__c : 0;
            } else {
                purchaseValue = contractDetailLine.ASI_CRM_CN_Min_Purchase_Target__c != null ? contractDetailLine.ASI_CRM_CN_Min_Purchase_Target__c : 0;
            }
            tableHTML += newTableRow;
            tableHTML += tableCell(purchaseValue != 0 ? purchaseValue.format() : '-', 'text-align: right;');
            tableHTML += tableCell(contractDetailLine.ASI_CRM_CN_Rebate_Percent__c.format() + '%', 'text-align: right;');
            tableHTML += endTableRow;


            /*
                If there are n elements, where A1 is maximum and An is minimum
                For By Tax,
                Max: A1
                Med: A2, A3... A(n-1)
                Min: An
                For By Ladder,
                Max: A1
                Med: A2, A3... An
                Min: An
            */
            //TODO: Refactor this
            if (tableTypeName == TABLE_TYPE_REBATE_BY_TAX){
                //In By Tax,
                //  the maximum line have Maximum Purchase Target = null
                //  the minimum line have Minimum Purchase Target = null
                mediumMap.put(denullify(contractDetailLine.ASI_CRM_CN_Max_Purchase_Target__c, 0), contractDetailLine);
                if (maxLine == null || maxLine.ASI_CRM_CN_Max_Purchase_Target__c < contractDetailLine.ASI_CRM_CN_Max_Purchase_Target__c || contractDetailLine.ASI_CRM_CN_Max_Purchase_Target__c == null){
                    maxLine = contractDetailLine;
                }
                if (minLine == null || minLine.ASI_CRM_CN_Max_Purchase_Target__c > contractDetailLine.ASI_CRM_CN_Max_Purchase_Target__c){
                    minLine = contractDetailLine;
                }

            } else {
                //By Ladder
                mediumMap.put(denullify(contractDetailLine.ASI_CRM_CN_Min_Purchase_Target__c, 0), contractDetailLine);
                if (maxLine == null || denullify(maxLine.ASI_CRM_CN_Min_Purchase_Target__c, 0) < denullify(contractDetailLine.ASI_CRM_CN_Min_Purchase_Target__c, 0)){
                    maxLine = contractDetailLine;
                }
                if (minLine == null || denullify(minLine.ASI_CRM_CN_Min_Purchase_Target__c, 0) > denullify(contractDetailLine.ASI_CRM_CN_Min_Purchase_Target__c, 0)){
                    minLine = contractDetailLine;
                }
            }
        }


        if (tableTypeName == TABLE_TYPE_REBATE_BY_TAX){
            mediumMap.remove(denullify(maxLine.ASI_CRM_CN_Max_Purchase_Target__c, 0));
            mediumMap.remove(denullify(minLine.ASI_CRM_CN_Max_Purchase_Target__c, 0));
        } else {
            mediumMap.remove(denullify(maxLine.ASI_CRM_CN_Min_Purchase_Target__c, 0));
        }

        //Put all maxPurchaseValue into the List for sorting
        maxValueList.addAll(mediumMap.keySet());
        maxValueList.sort();

        //Generate Footer
        //  Fill Minimum
        //  Fill Maximum
        //  For remaining, fill medium
        //  Form ordering of layer,
        //      if ladder, Max -> Medium (descending) -> Minimum
        //      if Tax, Min -> Medium (ascending) -> Maximum
        system.debug('Canter检测结果：' + remarksAchEvementTemplate + '/;' + remarksMinimumTemplate + '/;' + remarksMediumTemplate + '/;' + remarksMaximumTemplate + '/;' + DisplayFlag + '/;' + maxLine + '/;' + minLine);
        String remarksResult = '';
        if(DisplayFlag && maxLine != null && minLine != null){
            List<String> remarksList = new List<String>();
            remarksList.add(StringCaseHandlerLadder(remarksMinimumTemplate, minLine, TableTypeName));
            for (Decimal maxValue : maxValueList){
                remarksList.add(StringCaseHandlerLadder(remarksMediumTemplate, mediumMap.get(maxValue), TableTypeName));
            }
            remarksList.add(StringCaseHandlerLadder(remarksMaximumTemplate, maxLine, TableTypeName));

            if (TableTypeName == TABLE_TYPE_REBATE_BY_LADDER){
                //Reverse order if Table type is by ladder
                List<String> reverse = new List<String>();
                for (Integer i = remarksList.size()-1; i>=0; i--){
                    reverse.add(remarksList[i]);
                }
                remarksList = reverse;
            }
            remarksList.add(StringCaseHandlerLadder(remarksFixTemplate, maxLine, TableTypeName));
            
            remarksResult = String.join(remarksList, lineBreak);
        }

        if(ChildMap.subSectionMap != null){
            for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                SectionWrapper subSectionLine = ChildMap.subSectionMap.get(InnerKey);
                SectionType SectionTypeClass = ClassNameHandler(subSectionLine.ClassName);

                if((subSectionLine.name.contains('Footer') && ((SectionTypeClass.VolumeBase != null && SectionTypeClass.VolumeBase == '') || (tableTypeName == SectionTypeClass.VolumeBase))) &&
                        ((TableTypeName == TABLE_TYPE_REBATE_BY_TAX) ||
                                (TableTypeName == TABLE_TYPE_REBATE_BY_LADDER) &&
                                ((isCapped && SectionTypeClass.additionalInfo.contains('isCapped')) ||
                                        (!isCapped && SectionTypeClass.additionalInfo.contains('NotCapped'))))){
                    SectionWrapper subSection = ChildMap.subSectionMap.get(InnerKey);
                    tableHTML += newTableRow;
                    //Copy from old code
                    //TODO: Refactor the generate footer part as function
                    String NowContent = remarksLineList[0] + '//' + remarksResult;
                    if(subSection.content.right(2)=='//'){
                        NowContent+='  ';
                    }
                    List<String> FooterParts = NowContent.split('//');

                    integer columnNum = 1;
                    for(string str:FooterParts){

                        if(SectionTypeClass.ClassType=='InputText' && columnNum ==SectionTypeClass.ClassTypeColumnNum && (isEditable || (!isEditable && String.isNotBlank(ContractSettingMap.get(subSection.Name+key)))) ){
                            tableHTML+= '<td ';
                            if(SectionTypeClass.TableStyleMap.containsKey(columnNum)){
                                tableHTML+=SectionTypeClass.TableStyleMap.get(columnNum);
                            }
                            tableHTML+=' style="border: 1px solid black; " >';
                            if(isEditable){
                                tableHTML+='<textarea cols="50" rows="3" class="InputText" style="width: 99%;" Module-Id="'+key+'"  data-id="'+subSection.Name+key+'"  ';
                            }

                            if(ContractSettingMap.containsKey(subSection.Name+key) && (ContractSettingMap.get(subSection.Name+key) != null && ContractSettingMap.get(subSection.Name+key) != '')){
                                String NoteStr= isEditable?  ' style="border: 1px solid black; " >'+ContractSettingMap.get(subSection.Name+key)+'</textarea>'  : CheckingHighLight(SplitLineIntoRow( ContractSettingMap.get(subSection.Name+key) ,38));
                                tableHTML+= NoteStr + '</td>';
                            }else{
                                if (str.trim().length()==0){
                                    str='';
                                }
                                else if(subSectionLine.name == 'PSFTableF_Footer_2')
                                {
                                    //str = subSectionLine.content;
                                    //2020/01/14 CanterDuan start 替换掉配置文件中的MinAchievement
                                    str = subSectionLine.content.replace('{MinAchievement}',String.ValueOf(PSFItem.MinAchievement.setScale(2).format()));
                                    //2020/01/14 CanterDuan end
                                    system.debug('str:ss' + subSectionLine.content);
                                }
                                tableHTML+= isEditable? ' style="border: 1px solid black; " >'+str.replace('::', '')+'</textarea></td>' : SplitLineIntoRow(str.replace('::', ''), 38) + '<br/></td>';
                            }
                        }else if(SectionTypeClass.ClassType=='Selectable' && columnNum ==SectionTypeClass.ClassTypeColumnNum){

                            if(isEditable){
                                tableHTML+= '<td ';
                                if(SectionTypeClass.TableStyleMap.containsKey(columnNum)){
                                    tableHTML+=SectionTypeClass.TableStyleMap.get(columnNum);
                                }

                                if(ContractSettingMap.containsKey(subSection.Name+key)){
                                    if(ContractSettingMap.get(subSection.Name+key)=='true'){
                                        tableHTML+=' style="border: 1px solid black; text-align: left;"  ><input type="checkbox" class="bodySelection '+subSection.Name+key+'" Module-Id="'+key+'"  checked="true" />';
                                    }else{
                                        tableHTML+=' style="border: 1px solid black; text-align: left;"  ><input type="checkbox" class="bodySelection '+subSection.Name+key+'" Module-Id="'+key+'"   />';
                                    }
                                }else{//default
                                    tableHTML+=' style="border: 1px solid black; text-align: left;"  ><input type="checkbox" class="bodySelection '+subSection.Name+key+'" Module-Id="'+key+'"   checked="true" />';
                                }
                                String TempString = CheckingHighLight(SplitLineIntoRow(str,38));

                                tableHTML+= span(TempString) + endTableCell;
                            } else {
                                //PDF (!isEditable)
                                if(ContractSettingMap.get(subSection.Name+key)=='true'){
                                    if(ContractSettingMap.containsKey(subSection.Name+key)){
                                        tableHTML+= '<td ';
                                        if(SectionTypeClass.TableStyleMap.containsKey(columnNum)){
                                            tableHTML+=SectionTypeClass.TableStyleMap.get(columnNum);
                                        }
                                        String TempString =str;
                                        TempString= CheckingHighLight(SplitLineIntoRow(TempString,38));
                                        tableHTML+=' style="border: 1px solid black; " >'+TempString+'</td>';
                                    }
                                }
                            }
                        }
                        columnNum++;
                    }
                    tableHTML+='</tr>';
                    //End Copying
                }
            }
        }
        system.debug('----drawLadderTable == '+ tableHTML);
        tableHTML += endTable;
        // Remove empty row, PDF cannot gen empty row
        tableHTML = tableHTML.replace(newTableRow+endTableRow, '');
        return tableHTML;
    }

    public String StringCaseHandlerLadder(String template, ASI_CRM_CN_Contract_BRSF_Line_Item__c contractLine, String TableTypeName){
        String result = template;
        system.debug('template :' + template);
        system.debug('contractLine:' + contractLine);
        if (contractLine != null){
            Decimal rebatePercent = denullify(contractLine.ASI_CRM_CN_Rebate_Percent__c, 0);
            Decimal contractPurchaseValue = denullify(contractLine.ASI_CRM_CN_Contract_Purchase_Value__c, 0);
            Decimal min = denullify(contractLine.ASI_CRM_CN_Min_Purchase_Target__c, 0);

            result = result.replace('{MaxPurchaseTarget}', String.ValueOf(denullify(contractLine.ASI_CRM_CN_Max_Purchase_Target__c, 0).setScale(2).round(System.RoundingMode.HALF_DOWN).format()));
            result = result.replace('{MinPurchaseTarget}', String.ValueOf(min.setScale(2).round(System.RoundingMode.HALF_DOWN).format()));
            result = result.replace('{RebatePercent}', String.ValueOf(rebatePercent.setScale(2).format()));

            if (TableTypeName == TABLE_TYPE_REBATE_BY_LADDER){
                result = result.replace('{ModuleTotal}', String.ValueOf(denullify(ASI_CRM_CN_OffContractUtilitiesClass.getModuleContractTotalByTax(contractLine.ASI_CRM_Module__c), 0).setScale(2).format()));

                result = result.replace('{MaxRebate}', (Math.max(contractPurchaseValue, min) * rebatePercent / 100).setScale(2).format());
            }
            else {
                //TODO: Try to bulkify this to avoid SOQL 101
                result = result.replace('{MaxRebate}', String.ValueOf(denullify(ASI_CRM_CN_OffContractUtilitiesClass.getModuleContractTotalByTax(contractLine.ASI_CRM_Module__c), 0).setScale(2).format()));
            }
        }
        
        result = result.replace('null', '0');
        result = result.replace('{MaxPurchaseTarget}', '').replace('{MinPurchaseTarget}', '').replace('{RebatePercent}', '').replace('{ModuleTotal}', '').replace('{MaxRebate}', '');

        system.debug('result:' + result);
        return result;
    }


    public SectionType ClassNameHandler(String ClassNameStr){
        SectionType TempSectionType = new SectionType();
        List<String> parts = ClassNameStr.split(' ');
        for(string str:parts){

            if(str.contains('rowspan') || str.contains('colspan') ){//system.debug(str.right(1)+'Now '+str.left(1));
                TempSectionType.ColumnNumber= integer.valueOf(str.left(1));
                TempSectionType.StyleString=str.substring(1,8)+'='+str.right(1);
                TempSectionType.StyleStringColumnNum= integer.valueOf(str.left(1));
                TempSectionType.TableStyleMap.put(integer.valueOf(str.left(1)), str.substring(1,8)+'='+str.right(1));

            }else if(tableTypeList.contains(str)){
                TempSectionType.VolumeBase=str;
            }else if(str.contains('InputText') || str.contains('Selectable')){
                TempSectionType.ColumnNumber= integer.valueOf(str.left(1));
                TempSectionType.ClassType= str.substring(1,str.length());
                TempSectionType.ClassTypeColumnNum= integer.valueOf(str.left(1));
            } else {
                TempSectionType.additionalInfo.add(str);
            }
        }

        return TempSectionType;

    }

    public String StringCaseHandlerPSF(String InputString, Decimal TotalMonthlyVolume, Decimal ContractTotal, interimData PSFItem){
        system.debug('PSFItem:' + PSFItem);
        system.debug('InputString:' + InputString);
        if(InputString.contains('{MinAchievement}')){
            InputString=InputString.replace('{MinAchievement}', String.ValueOf(PSFItem.MinAchievement != null ? PSFItem.MinAchievement.setScale(0):0));
        }
        if(InputString.contains('{ModuleTotal}')){
            InputString=InputString.replace('{ModuleTotal}', String.ValueOf(ContractTotal.setScale(2).format()));
        }
        if(InputString.contains('{Remarks}')){
            InputString=InputString.replace('{Remarks}', String.ValueOf(PSFItem.Remarks));
        }

        return StringCaseHandler(InputString, TotalMonthlyVolume, ContractTotal);
    }

    //Old class to handle Contract Data
    public String StringCaseHandler(String InputString,Decimal TotalMonthlyVolume,Decimal ContractTotal){
        if(InputString.contains('{TotalMonthlyVolume}')){
            InputString=InputString.replace('{TotalMonthlyVolume}',TotalMonthlyVolume.format());
        }
        if(InputString.contains('{ContractTotal}')){
            InputString=InputString.replace('{ContractTotal}',ContractTotal.format());
        }
        if(InputString.contains('{BCRate}')){
            InputString=InputString.replace('{BCRate}',ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c.setScale(0)+'%');
        }
        if(InputString.contains('{MartellBCRate}')){
            InputString=InputString.replace('{MartellBCRate}',ContractSelected.ASI_CRM_Martell_BC_Rate__c.setScale(0)+'%');
        }
        if(InputString.contains('{Key-SubBrand}')){
            if(KeySubBrandSet.size()>0){
                String SubBrandNames= String.valueOf(KeySubBrandSet);
                SubBrandNames= SubBrandNames.replace('{','');
                SubBrandNames= SubBrandNames.replace('}','');
                InputString=InputString.replace('{Key-SubBrand}', SubBrandNames);
            }
        }
        return InputString;
    }

    public String VolumeBaseNamingFixing(String InputName){
        String str=InputName.replace('-','');
        return str.replace(' ','');
    }

    private String SplitStringLine(String InputString){
        return SplitLineIntoRow(InputString,BodyContentCuttingNumber);
    }

    @testVisible
    private String TableSplitLineRow(String InputString,integer CutNumber ){
        //handle contain '<br/>' case //system.debug('TableSplitLineRow InputString   '+ InputString);
        String outputString ='';

        if(!isEditable){
            InputString = InputString.replace(lineBreak,'|');

            if(InputString.length() >= CutNumber ){
                if(InputString.contains('|')){
                    while(InputString.length() >= CutNumber ){
                        String StringCut = InputString.subString(0,CutNumber);
                        if(StringCut.contains('|')){
                            integer IndexNum = StringCut.indexOf('|');
                            String FixedString = StringCut.subString(0,IndexNum+1);
                            FixedString=FixedString.replace('|','');

                            outputString = outputString + FixedString + lineBreak;
                            InputString= InputString.subString(IndexNum+1);  // StringCut.subString(IndexNum,StringCut.length()-1)+
                        }else{
                            outputString = outputString + StringCut + lineBreak;
                            InputString= InputString.subString(CutNumber);
                        }
                    }
                }else{
                    while(InputString.length() >= CutNumber ){
                        outputString = outputString + InputString.subString(0,CutNumber) + lineBreak;
                        InputString= InputString.subString(CutNumber);
                    }

                }

            }
            InputString=InputString.replace('|','');
            outputString = outputString + InputString;


        }else{
            outputString=InputString;
        }
        return outputString;
    }

    public string genSpace(integer LoopingTimes){
        String spacestr='1';
        String returnString = '';
        for(integer i =0; i<LoopingTimes; i++ ){
            returnString+= spacestr;
        }

        return returnString;
    }

    public String GenFontSize(){
        String StyleCSS='';
        if(!isEditable){
            //StyleCSS='font-size:11px;';
        }
        return StyleCSS;
    }









    //Generate  Party B Wholesaler input in Header
    private String GeneratingPartyB_Header( Boolean DisplayOnly){

        String HTMLString='<table style="page-break-inside:avoid;" id="WholesalerTable" >';
        system.debug(PartyBIDSet);
        if(PartyBIDSet.size()>0){ // contain in the database
            Integer CountNum=1;

            if(isEditable){
                for(String PartyBstr: PartyBIDSet){
                    if(ContractSettingMap.containsKey(PartyBstr)){
                        List<String> Wholesaler = ContractSettingMap.get(PartyBstr).split(':');
                        HTMLString+= '<tr><td>';
                        if(CountNum!=1){// Button X
                            HTMLString+= '</td><td> <button type="button" style="color: #fff; background-color: #f0ad4e; border-color: #eea236; display: inline-block;  margin-bottom: 0;font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap;user-select: none; background-image: none; border: 1px solid transparent; border-radius: 4px;" > X</button>';
                        }else{// Button +
                            HTMLString+=  ' 乙方：</td><td><button type="button" onclick ="AddingNewWholesaler();" style="color: #fff; background-color:#7e8be4; border-color: #7e8be4; display: inline-block; margin-bottom: 0; font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap;user-select: none; background-image: none; border: 1px solid transparent; border-radius: 4px;" > + </button>' ;
                        }

                        if(Wholesaler.size() == 0)
                        {
                            HTMLString+='<input type="text" class="Header_partyB RequiredField InputText ui-autocomplete-input"" name="PartyB" data-id="PartyB'+string.valueOf(CountNum)+'" id="PartyB" value="" Legal-Name="" data-value ="" ></input></td></tr>' ; //(批发商名称)
                        }
                        else
                        {
                            system.debug('有值==='+PartyBstr);
                            HTMLString+='<input type="text" class="Header_partyB RequiredField InputText ui-autocomplete-input"" name="PartyB" data-id="PartyB'+string.valueOf(CountNum)+'" id="PartyB" value="'+
                                Wholesaler.get(0)+ '" Legal-Name="'+Wholesaler.get(2)+'" data-value ="'+Wholesaler.get(1)+'" ></input></td></tr>' ; //(批发商名称)
                        }
                    }
                    CountNum++;
                }
            }else{// print name
                for(String PartyBstr: PartyBIDSet){
                    if(ContractSettingMap.containsKey(PartyBstr)){
                        List<String> Wholesaler = ContractSettingMap.get(PartyBstr).split(':');
                        if(CountNum!=1){
                            HTMLString+='<tr><td style="color: white;" >乙方：</td> ';
                        }else{ // CountNum == 1
                            HTMLString+='<tr><td >乙方：</td> ';
                        }
                        HTMLString+='<td>'+CheckingHighLight(Wholesaler.get(2))+'</td></tr>';//(批发商名称)
                        CountNum++;
                    }
                }
            }
        }else{
            if(isEditable){
                // default
                String EffectiveSupplierName='';
                String EffectiveSupplierId='';
                PartyBLegalName='';
                List<ASI_CRM_Effective_supplier__c> EffectiveSupplierList =[select id,ASI_CRM_Supplier__c,ASI_CRM_Supplier__r.Name,ASI_CRM_Last_tran_date__c,ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c
                from ASI_CRM_Effective_supplier__c where ASI_CRM_Account__c=:ContractSelected.ASI_CRM_CN_Outlet_WS__c
                order by ASI_CRM_Last_tran_date__c desc];
                if(EffectiveSupplierList.size()>0){
                    EffectiveSupplierName= EffectiveSupplierList[0].ASI_CRM_Supplier__r.Name;
                    EffectiveSupplierId= EffectiveSupplierList[0].ASI_CRM_Supplier__c;
                    PartyBLegalName=EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c !=null?EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c:'';
                }

                HTMLString+= '<tr><td>乙方：</td><td>'+
                        ' <button type="button" onclick ="AddingNewWholesaler();" style="color: #fff; background-color:#7e8be4; border-color: #7e8be4; display: inline-block; margin-bottom: 0; font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap;user-select: none; background-image: none; border: 1px solid transparent; border-radius: 4px;" > + </button>' ;
                HTMLString+= '<input  type="text" class="Header_partyB RequiredField InputText ui-autocomplete-input" name="PartyB"  data-id="PartyB1"  id="PartyB" value="'+EffectiveSupplierName+
                        '" Legal-Name="'+PartyBLegalName+'"  data-value ="'+EffectiveSupplierId+'" ></input> </td></tr>' ;// (批发商名称)
            }else{
                HTMLString+= '<tr><td>乙方：</td><td>'+
                        ' <button type="button" onclick ="AddingNewWholesaler();" style="color: #fff; background-color:#7e8be4; border-color: #7e8be4; display: inline-block; margin-bottom: 0; font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap;user-select: none; background-image: none; border: 1px solid transparent; border-radius: 4px;" > + </button>' ;
                HTMLString+= '<input  type="text" class="Header_partyB RequiredField InputText ui-autocomplete-input" name="PartyB"  data-id="PartyB1"  id="PartyB" value=""></input></td></tr>' ; // (批发商名称)
            }
        }
        HTMLString+=endTable;

        if(DisplayOnly && isEditable){
            HTMLString ='乙方：';
        }
        /*
if(DisplayOnly && !isEditable){
HTMLString ='乙方：'+HTMLString;
}*/

        return HTMLString;

    }




    //Generate  Generating one Effective Supplier Input
    private String GeneratingEffectiveSupplierInput(String InputKey,Boolean DisplayOnly){

        String HTMLString=' ';
        if(ContractSettingMap.containsKey(InputKey)){
            List<String> Wholesaler = ContractSettingMap.get(InputKey).split(':');
            if(isEditable && !DisplayOnly){

                HTMLString+='<input type="text" class="Header_partyB RequiredField InputText" name="PartyB" data-id="'+InputKey+'" id="'+InputKey+'" value="'+
                        Wholesaler.get(0)+ '" Legal-Name="'+Wholesaler.get(2)+'" data-value ="'+Wholesaler.get(1)+'" ></input>' ;

            }else{

                HTMLString+= Wholesaler.get(2)!=null? Wholesaler.get(2): Wholesaler.get(0);
            }
        }else{
            if(isEditable && !DisplayOnly){
                // default
                String EffectiveSupplierName='';
                String EffectiveSupplierId='';
                PartyBLegalName='';
                List<ASI_CRM_Effective_supplier__c> EffectiveSupplierList =[select id,ASI_CRM_Supplier__c,ASI_CRM_Supplier__r.Name,ASI_CRM_Last_tran_date__c,ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c
                from ASI_CRM_Effective_supplier__c where ASI_CRM_Account__c=:ContractSelected.ASI_CRM_CN_Outlet_WS__c
                order by ASI_CRM_Last_tran_date__c desc];
                if(EffectiveSupplierList.size()>0){
                    EffectiveSupplierName= EffectiveSupplierList[0].ASI_CRM_Supplier__r.Name;
                    EffectiveSupplierId= EffectiveSupplierList[0].ASI_CRM_Supplier__c;
                    PartyBLegalName=EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c !=null ? EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c : '';
                }

                HTMLString+= '<input type="text" class="Header_partyB RequiredField InputText" name="EffectiveSupplierName"  data-id="'+InputKey+'"  id="'+InputKey+'" value="'+EffectiveSupplierName+
                        '" Legal-Name="'+PartyBLegalName+'"  data-value ="'+EffectiveSupplierId+'" ></input>' ;
//                HTMLString+= EffectiveSupplierName;
            }
            else
            {
                // default
                String EffectiveSupplierName='';
                String EffectiveSupplierId='';
                PartyBLegalName='';
                List<ASI_CRM_Effective_supplier__c> EffectiveSupplierList =[select id,ASI_CRM_Supplier__c,ASI_CRM_Supplier__r.Name,ASI_CRM_Last_tran_date__c,ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c
                from ASI_CRM_Effective_supplier__c where ASI_CRM_Account__c=:ContractSelected.ASI_CRM_CN_Outlet_WS__c
                order by ASI_CRM_Last_tran_date__c desc];
                if(EffectiveSupplierList.size()>0){
                    EffectiveSupplierName= EffectiveSupplierList[0].ASI_CRM_Supplier__r.Name;
                    EffectiveSupplierId= EffectiveSupplierList[0].ASI_CRM_Supplier__c;
                    PartyBLegalName=EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c !=null ? EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c : '';
                }

//                HTMLString+= '<input type="text" class="Header_partyB RequiredField InputText" name="EffectiveSupplierName"  data-id="'+InputKey+'"  id="'+InputKey+'" value="'+EffectiveSupplierName+
//                        '" Legal-Name="'+PartyBLegalName+'"  data-value ="'+EffectiveSupplierId+'" ></input>' ;
                HTMLString+= EffectiveSupplierName;
            }
            // if(DisplayOnly){
            //     HTMLString=' ';
            // }
        }



        return HTMLString;
    }





    public String CheckingHighLight(String InputContent){
        if(Highlight){ //  #FFFF00
            InputContent='<span style="background-color: #3399ff">'+InputContent+'</span>';
        }
        return  InputContent;
    }


    public String SplitLineIntoRow(String InputString, integer CutNumber){
        String outputString ='';

        integer tempCutNumber = CutNumber;
        // if (!isEditable){
            List<String> inputLineList = InputString.split(lineBreak);
            for (String inputLine:inputLineList){
                if (inputLine.length() < CutNumber){
                    outputString += inputLine + lineBreak;
                } else {
                    while(inputLine.length() >= CutNumber ){
                        //Add 1 for every 2 symbol/number/alphabet
                        //Add 2 for each '\n'
                        Integer offset = inputLine.subString(0,CutNumber).countMatches('/n') * 2 + (inputLine.subString(0, CutNumber).replaceAll('[\\w ,."*()\'=<>%0-9]','c').countMatches('c') / 2);

                        //To prevent out of bound, new cut number cannot exceed length of the line
                        tempCutNumber = Math.min(inputLine.length(), CutNumber + offset);

                        Pattern p = Pattern.compile(reservedPattern);
                        Matcher m;
                        do {
                            m = p.matcher(inputLine.subString(tempCutNumber).left(1));
                            if (m.matches()){
                                tempCutNumber = Math.min(inputLine.length(), tempCutNumber + 1);
                            }
                        } while (m.matches());
                        outputString = outputString + inputLine.subString(0,tempCutNumber);

                        //If next line contains less than 2 characters or the line contain line break, forfeit new line
                        if ((inputLine.subString(tempCutNumber).length() > 2 && !inputLine.subString(0,tempCutNumber).contains('<b'))){
                            outputString += lineBreak;
                        }
                        inputLine= inputLine.subString(tempCutNumber);
                    }
                    outputString += inputLine + lineBreak;
                }
            }
            //outputString = outputString + InputString;
        // }else{
        //     outputString=InputString;
        // }
        return outputString;
    }



    public String LineBreakProcess(String InputString,integer CutNumber,integer EnAddNumber ){
        String outputString ='';
        integer tempCutNumber = CutNumber;
        if(!isEditable){// output for PDF
            if(!ASI_CRM_CN_HeavyContracFunctionClass.containsChineseCharacters(InputString)){
                CutNumber= CutNumber + EnAddNumber;
            }
            outputString = SplitLineIntoRow(InputString, CutNumber);
        }else{
            outputString = InputString;
        }
        return outputString;
    }





    //Replace the content with the key word
    public String ContentReplace(String InputContent,String InputName,String InputClassName){
        if(InputContent!=null){
            if(InputContent.contains('{InputText}')){
                string InnerHTML='';
                String SavedKey = InputName + 'InputText';
                if(ContractSettingMap.containsKey(SavedKey)){
                    string InputTextArea = ContractSettingMap.get(SavedKey)!=null? ContractSettingMap.get(SavedKey) : '';
                    if(!isEditable){
                        InnerHTML+= CheckingHighLight(SplitLineIntoRow(InputTextArea,10));
                    }else{
                        InnerHTML+='<textarea cols="50" rows="3" class="InputText " data-id="'+InputName+'"     >' + InputTextArea + '</textarea>';
                    }
                }else if(isEditable){
                    InnerHTML+='<textarea cols="50" rows="3" class="InputText " data-id="'+SavedKey+'"    >' +'   ' + '</textarea>';
                }
                InputContent = InputContent.replace('{InputText}', InnerHTML);
            }

            if(InputContent.contains('{CoveredOutletTable}')){

                InputContent = InputContent.replace('{CoveredOutletTable}',GeneratingCoveredOutletTable() );
            }
        }
        return InputContent;
    }


    //Checking the checkbox with its content is show or not
    public Boolean CheckingIsVisibleOrNot(String InputName){
        Boolean ReturnIsShow= true;
        if(ContractSettingMap.containsKey(InputName)){
            if(ContractSettingMap.get(InputName)=='false'){
                ReturnIsShow= false;
            }
        }

        return ReturnIsShow;
    }

    private static String getFolderName(String contactType, String regionName, Boolean is2Party) {
        String folderDeveloperName = 'ASI_CRM_CN';

        if (is2Party) folderDeveloperName += '_2Party';

        folderDeveloperName += '_' + 'OFF' + contactType;
        folderDeveloperName += '_' + ASI_CRM_CN_HeavyContracFunctionClass.regionNameCodeMap.get(regionName);

        return folderDeveloperName;
    }


    //*****************************************
    //Loading XML Document
    //***************************************
    private void LoadDocumentFiles() {//ASI_CRM_CN_Central_Premium

        Document DocumentFile  = new Document();

        if(ContractSelected.ASI_CRM_Contract_Template_Id__c != null){
            // The Contract had pre-defined Contract Template
            // ContractSelected.ASI_CRM_Contract_Template_Id__c
            //'0159E000000aYsc'
            DocumentFile =[
                    SELECT Id, Body, FolderId, LastModifiedDate
                    FROM Document
                    WHERE Id = :ContractSelected.ASI_CRM_Contract_Template_Id__c
            ];
        } else {
            // Get the lastest Contract Template
            // Folder Name = ASI_CRM_CN_2Party_OFFMOT / ASI_CRM_CN_OFFMOT
            String FolderDeveloperName='ASI_CRM_CN';
            // Check the PO Type
            If (ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract'){
                FolderDeveloperName += '_OFFMOT';
            }
            FolderDeveloperName = FolderDeveloperName.replace(' ','');
            FolderDeveloperName = ASI_CRM_CN_HeavyContracFunctionClass.getFolderNameByContract(ContractSelected);
            System.debug('FolderDeveloperName:::' + FolderDeveloperName);

            Folder FolderSelected = new Folder();
            try{
                system.debug('1st Try: We get '+FolderDeveloperName);
                FolderSelected =[select id,DeveloperName from Folder where DeveloperName=:FolderDeveloperName limit 1 ];
                DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where FolderId =:FolderSelected.Id order BY LastModifiedDate desc limit 1]; //Document DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where DeveloperName =:'ASI_CRM_CN_South_Prestige' limit 1];
            }catch(exception e){
                system.debug('2nd Try: We get  ASI_CRM_CN_OFFGeneral ');
                if(!Test.isRunningTest()){
                    FolderSelected =[select id,DeveloperName from Folder where DeveloperName='ASI_CRM_CN_OFFMOT' limit 1 ];
                    DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where FolderId =:FolderSelected.Id order BY LastModifiedDate desc limit 1];
                }else{
                    // TODO: Get Test Document
                    //DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where DeveloperName ='ASI_CRM_CN_Heavy_Test_document' limit 1];
                }
            }
        }

        String xmlStr='';
        if(!Test.isRunningTest()){
            System.debug('DocumentFile.Id:::' + DocumentFile.Id);
            System.debug('DocumentFile.FolderId:::' + DocumentFile.FolderId);
            xmlStr = DocumentFile.body.toString();
        }else{
            xmlStr = xmlStringTestClass;
        }
        //String xmlStr = DocumentFile.body.toString();
        Dom.Document doc = new Dom.Document();
        doc.load(xmlStr);

        Dom.XMLNode docRootNode = doc.getRootElement();
        Dom.XMLNode headerNode = docRootNode.getChildElement('header', null);
        Dom.XMLNode bodyNode = docRootNode.getChildElement('body', null);
        Dom.XMLNode BodySignatureNode = docRootNode.getChildElement('BodySignature', null);
        Dom.XMLNode appendixNode = docRootNode.getChildElement('appendix', null);
        Dom.XMLNode AppendixSignatureNode = docRootNode.getChildElement('AppendixSignature', null);

        headerSectionMap   = parseXML(headerNode,'header',BodyContentCuttingNumber);
        BodySectionMap     = parseXML(bodyNode,'body',BodyContentCuttingNumber);
        BodySignatureMap   = parseXML(BodySignatureNode,'BodySignature',BodyContentCuttingNumber);
        AppendixSectionMap = parseXML(appendixNode,'appendix',BodyContentCuttingNumber);
        AppendixSignatureMap= parseXML(AppendixSignatureNode,'AppendixSignature',BodyContentCuttingNumber);
    }



    private Map<integer, SectionWrapper> parseXML(Dom.XMLNode sectionNode,String NodeType,Integer LineCuttingNumber) {
        Map<integer, SectionWrapper> sectionWrapperMap = new Map<integer, SectionWrapper>();
        integer count=1;
        for(Dom.XMLNode childNode : sectionNode.getChildElements()) {



            String name                                = childNode.getAttribute('name', null);
            String style                               = childNode.getAttribute('style', null);
            String content                             = childNode.getChildElement('content', null).getText();
            String displayNumber                       = childNode.getAttribute('displayNumber', null);
            String type                                = childNode.getChildElement('type', null).getText();
            String ClassName                            = childNode.getAttribute('class', null);
            String checkedBoolean;
            if (childNode.getChildElement('checked', null) != null){
                checkedBoolean = childNode.getChildElement('checked', null).getText();
            }


            Boolean checked                             = Boolean.ValueOf(checkedBoolean==null? 'true':checkedBoolean);


            Map<integer, SectionWrapper> subSectionMap = null;
            Dom.XMLNode subSectionNode = childNode.getChildElement('subSection', null);
            if(subSectionNode != null) {
                subSectionMap = parseXML(subSectionNode,NodeType,InnerContentCuttingNumber);
            }

            SectionWrapper sectionWrapper = new SectionWrapper(name, content,style, displayNumber, ClassName,type,subSectionMap, checked);
            system.debug('count次数='+count+'---sectionWrapper for 循环=='+sectionWrapper);
            sectionWrapperMap.put(count,sectionWrapper);
            count++;
        }
        return sectionWrapperMap;
    }




    @RemoteAction
    global static String ChangeTemplate(ASI_TH_CRM_Contract__c InputObject,String RegionName,Boolean IsTwoParty){
        string msg='OK';
        System.debug(LoggingLevel.INFO, '*** : InputObject' + InputObject);
        List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutList = [select id from ASI_CRM_Contract_Printout_Setting__c where ASI_CRM_Contract__c=: InputObject.Id];
        system.debug('IsTwoParty ==' + IsTwoParty);
        try{
            Document DocumentFile;
            ASI_TH_CRM_Contract__c contract = [SELECT Id, ASI_CRM_CN_Is_Dolphin__c FROM ASI_TH_CRM_Contract__c WHERE Id = :InputObject.Id];
            if (contract.ASI_CRM_CN_Is_Dolphin__c) {
                DocumentFile = ASI_CRM_CN_HeavyContracFunctionClass.GenerateGeneralContractTemplate('offDolphin',RegionName,IsTwoParty);
            } else {
                DocumentFile = ASI_CRM_CN_HeavyContracFunctionClass.GenerateOffContractTemplate(RegionName,IsTwoParty);
            }
             
            InputObject.ASI_CRM_Contract_Template_Id__c = DocumentFile != NULL ? DocumentFile.Id : NULL;
            if(IsTwoParty){
                InputObject.ASI_CRM_CN_Two_Party_Contract_Template__c =true;
            }else{
                InputObject.ASI_CRM_CN_Two_Party_Contract_Template__c =false;
            }
            update InputObject;
            system.debug('InputObject.id == '+InputObject.Id);
            system.debug('InputObject.ASI_CRM_Contract_Template_Id__c == '+InputObject.ASI_CRM_Contract_Template_Id__c);

            if(contractPrintoutList.size() > 0) {
                delete contractPrintoutList;
            }

        } catch (DMLException e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_OffContractGenerationCtrl.UpdateRecord <br/> in ASI_CRM_CN_ViewHeavyContractPage class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyContractGenerationPage',' ');
        }

        return msg;
    }





    //nextStep:  'back'/ 'approver' / 'customer'
    //InputAmountUpdatedListJson  : Save to ASI_CRM_Contract_Printout_Setting__c
    //TextUpdatedListJson : Save to ASI_CRM_Contract_Printout_Setting__c
    //ModuleRefListJson  : Save to ASI_CRM_Module__c
    // /ContractCostLinesJson save to  ASI_CRM_Contract_Terms__c in ASI_CRM_Contract_Cost__c
    @RemoteAction
    global static String saveTemplate(
            String nextStep,
            String contractId,
            String InputAmountUpdatedListJson,
            String TextUpdatedListJson,
            String ModuleRefListJson,
            String ContractCostLinesJson
    ) {

        List<String> InputAmountUpdatedList =
                (List<String>) fromJsonString(InputAmountUpdatedListJson, List<String>.class);
        List<String> TextUpdatedList = (List<String>) fromJsonString(TextUpdatedListJson, List<String>.class);
        List<String> ModuleRefList = (List<String>) fromJsonString(ModuleRefListJson, List<String>.class);
        List<String> ContractCostList = (List<String>) fromJsonString(ContractCostLinesJson, List<String>.class);

        system.debug('InputAmountUpdatedList =' +InputAmountUpdatedList);
        system.debug('TextUpdatedList =' +TextUpdatedList);
        system.debug('ModuleRefList =' +ModuleRefList);
        system.debug('ContractCostList =' +ContractCostList);

        String Msg = 'OK';

        System.Savepoint databaseSavepoint = Database.setSavepoint();
        try {
            // *******************************Module *******************************
            Map<String, string> ReferenceMap = new Map<String, string>();

            for (String ModuleRecord : ModuleRefList) {
                List<String> ModuleInformation = ModuleRecord.split('//');
                if (ModuleInformation.size() <= 1) continue;

                if (ReferenceMap.containsKey(ModuleInformation.get(0))) {
                    String TempReference =
                            ReferenceMap.get(ModuleInformation.get(0)) + '<br/>• ' + ModuleInformation.get(1);
                    ReferenceMap.remove(ModuleInformation.get(0));
                    ReferenceMap.put(ModuleInformation.get(0), TempReference);
                } else {
                    ReferenceMap.put(ModuleInformation.get(0), '• ' + ModuleInformation.get(1));
                }
            }
            //Update Module
            List<ASI_CRM_Module__c> UpdatedModuleList = new List<ASI_CRM_Module__c>();
            for (string ModuleKey : ReferenceMap.keySet()) {
                UpdatedModuleList.add(New ASI_CRM_Module__c(Id = ModuleKey,
                        ASI_CRM_Payment_Reference__c = ReferenceMap.get(ModuleKey)));
            }
            if (UpdatedModuleList.size() > 0) {
                update UpdatedModuleList;
            }

            //*********************Contract Print out List ********************* Delete existing saved template
            List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutList = [select id from ASI_CRM_Contract_Printout_Setting__c where ASI_CRM_Contract__c=: contractId];
            if (contractPrintoutList.size() > 0) {
                delete contractPrintoutList;
            }
            List<ASI_CRM_Contract_Printout_Setting__c> ContractPrintoutSettingList =
                    new List<ASI_CRM_Contract_Printout_Setting__c>();

            for (String TextField : TextUpdatedList) {
                List<String> TextInformation = TextField.split('//');
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting =
                        new ASI_CRM_Contract_Printout_Setting__c();
                tempContractPrintoutSetting.ASI_CRM_Contract__c = contractId;
                tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c = 'appendix';
                if(TextInformation.get(0) == 'section4')
                {
                    if(TextInformation.get(1) != 'false' && TextInformation.get(1) != 'true')
                    {
                        tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = TextInformation.get(0)+'Text';
                    }
                    else 
                    {
                        tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = TextInformation.get(0)+'Boolean';
                    }
                }

                else
                {
                    tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = TextInformation.get(0);
                }
                tempContractPrintoutSetting.ASI_CRM_Section_Content__c = TextInformation.get(1);

                // System.debug('tempContractPrintoutSetting:::' + tempContractPrintoutSetting);
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }

            for (String AmountField : InputAmountUpdatedList) {
                List<String> Information = AmountField.split('//');
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting =
                        new ASI_CRM_Contract_Printout_Setting__c();
                system.debug(Information.get(1) + ' 00000 : ' + Information.get(0));
                tempContractPrintoutSetting.ASI_CRM_Contract__c = contractId;
                tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c = 'appendix';
                if(Information.get(0) == 'section4')
                {
                    if(Information.get(1) != 'false' && Information.get(1) != 'true')
                    {
                        tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = Information.get(0)+'Text';
                    }
                    else 
                    {
                        tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = Information.get(0)+'Boolean';
                    }
                }

                else
                {
                    tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = Information.get(0);
                }
                tempContractPrintoutSetting.ASI_CRM_Section_Content__c = Information.get(1);
                // System.debug('tempContractPrintoutSetting:::' + tempContractPrintoutSetting);
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }

            // List<ASI_CRM_Contract_Printout_Setting__c> ContractPrintoutSettingList1 =
            //         mergeSection4Settings(contractPrintoutSettingList);

            // if (contractPrintoutSettingList.size() > 0) {
            //     for (ASI_CRM_Contract_Printout_Setting__c contractPrintoutSetting : contractPrintoutSettingList) {
            //         system.debug(contractPrintoutSetting);
            //     }
            //     // insert contractPrintoutSettingList;
            // }

            for (Integer counter = contractPrintoutSettingList.size() - 1; counter >= 0; counter--) {
                system.debug('--contractPrintoutSettingList.get(counter) ==' + contractPrintoutSettingList.get(counter) );
                if (contractPrintoutSettingList.get(counter) == null) contractPrintoutSettingList.remove(counter);
            }

            if (!contractPrintoutSettingList.isEmpty()) insert contractPrintoutSettingList;
            //***********************Finished Contract Print out Setting************************************************


            //Update Contract Cost Line
            List<ASI_CRM_Contract_Cost__c > UpdatedContractCostList = new List<ASI_CRM_Contract_Cost__c>();
            system.debug(ContractCostList);
            final List<String> basicServicesAndCostDetails = getBasicServicesAndCostDetails(contractPrintoutSettingList);
            system.debug('basicServicesAndCostDetails.size() =='+basicServicesAndCostDetails.size());
            //CanterDuan 2020/01/03 start 添加获取区域
            ASI_TH_CRM_Contract__c ContractSelected = new ASI_TH_CRM_Contract__c();
            ContractSelected = [select id,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c from ASI_TH_CRM_Contract__c where id =:contractId];
            String OutletArea = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c;
            //CanterDuan 2020/01/03 end
            Integer counter = 0;
            for (String ContractCostLine : ContractCostList) {
                // System.debug('ContractCostLine:::' + ContractCostLine);
                List<String> LineInformation = ContractCostLine.split('//');
                // System.debug(LineInformation.size());
                ASI_CRM_Contract_Cost__c ContractCost = new ASI_CRM_Contract_Cost__c();
                ContractCost.ASI_CRM_CN_Contract__c = contractId;
                ContractCost.Id = LineInformation.get(0);
                ContractCost.ASI_CRM_Contract_Terms__c = LineInformation.get(1);
                if(basicServicesAndCostDetails.size() > 0)
                {
                    //ContractCost.ASI_CRM_CN_Svc_Req__c = basicServicesAndCostDetails.get(counter);
                    ////2020/01/03 CanterDuan start 调整页面修改服务需求后，无法显示修改后的数据
                    if(OutletArea == 'Central Region'){ ContractCost.ASI_CRM_CN_Service_Requirement_Central__c = basicServicesAndCostDetails.get(counter);
                    }else if(OutletArea == 'East Region'){ ContractCost.ASI_CRM_CN_Service_Requirement_East__c = basicServicesAndCostDetails.get(counter);
                    }else if(OutletArea == 'North Region'){ ContractCost.ASI_CRM_CN_Service_Requirement_North__c = basicServicesAndCostDetails.get(counter);
                    }else if(OutletArea == 'North West Region'){ ContractCost.ASI_CRM_CN_Service_Requirement_Northwest__c = basicServicesAndCostDetails.get(counter);
                    }else if(OutletArea == 'South Region'){ ContractCost.ASI_CRM_CN_Svc_Req__c = basicServicesAndCostDetails.get(counter);
                    }else if(OutletArea == 'South West Region'){ ContractCost.ASI_CRM_CN_Service_Requirement_Southwest__c = basicServicesAndCostDetails.get(counter);
                    }
                    //2020/01/03 CanterDuan End
                }
                UpdatedContractCostList.add(ContractCost);
                counter++;
            }

            if (UpdatedContractCostList.size() > 0) {
                update UpdatedContractCostList;
            }

        } catch (Exception e) {
            Database.rollback(databaseSavepoint);
            throw e;
            Msg = e.getDmlMessage(0);
        }
        return Msg;
    }

    public static List<ASI_CRM_Contract_Printout_Setting__c> mergeSection4Settings(
        List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingList
        ) {

        List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingList1 = new List<ASI_CRM_Contract_Printout_Setting__c>();
        ASI_CRM_Contract_Printout_Setting__c setting = null;
        Set<Integer> counterSet = new Set<Integer>();
        for (ASI_CRM_Contract_Printout_Setting__c contractPrintoutSetting : contractPrintoutSettingList) {

            if (!'section4'.equals(contractPrintoutSetting.ASI_CRM_Content_Section_Name__c))
            {
                contractPrintoutSettingList1.add(contractPrintoutSetting);
            }

            if (setting == null) setting = contractPrintoutSetting;

            String content =  contractPrintoutSetting.ASI_CRM_Section_Content__c;

            if ('true'.equals(content) || 'false'.equals(content)) {
                setting.ASI_CRM_isVisible__c = Boolean.valueOf(content);
            } else {
                setting.ASI_CRM_Section_Content__c = content ;
            }

        }

        // // System.debug('itemsToRemove:::' + itemsToRemove);

        // // for (counter = itemsToRemove.size() - 1; counter >= 0; counter--) {
        // if(itemsToRemove.size() > 0)
        // {
        //     for (Integer counter1 : itemsToRemove) {
        //         system.debug('contractPrintoutSettingList.get(counter1)----'+contractPrintoutSettingList.get(counter1));
        //         system.debug('contractPrintoutSettingList.get(counter1-1)----'+contractPrintoutSettingList.get(counter1-1));
        //         system.debug('contractPrintoutSettingList.get(counter1+1)----'+contractPrintoutSettingList.get(counter1+1));
        //         contractPrintoutSettingList.remove(counter1);
        //     }
        // }

        // System.debug(setting);
        contractPrintoutSettingList1.add(setting);
        return contractPrintoutSettingList1;
    }

    // static void updateSectionForPrintoutSetting(
    //     List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingList, List<String> TextInformation
    //     ) {

    //     final String sectionContent = TextInformation.get(1);
    //     ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = null;

    //     for (ASI_CRM_Contract_Printout_Setting__c contractPrintoutSetting : contractPrintoutSettingList) {
    //         if(contractPrintoutSetting.ASI_CRM_Content_Section_Name__c.equals('section4')) {
    //             tempContractPrintoutSetting = contractPrintoutSetting;
    //             break;
    //         }
    //     }

    //     if(tempContractPrintoutSetting == null) {

    //     }

    //     if (sectionContent.equals('true') || sectionContent.equals('false')) {
    //         tempContractPrintoutSetting.ASI_CRM_isVisible__c = Boolean.valueOf(sectionContent);
    //     } else {
    //         tempContractPrintoutSetting.ASI_CRM_Section_Content__c = sectionContent;
    //     }
    // }

    @RemoteAction
    global static List<sObject> findList(string obj,string statement, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if

        // create the filter text
        String filter = qry;

        //begin building the dynamic soql query
        String soql;
        if(filter != '' || filter != null)
            soql = 'select '+statement+' from ' + obj + ' ' + filter +' order by Name';
        else
                soql = 'select '+statement+' from ' + obj +' order by Name';

        List<sObject> sobjs = new List<sObject>();

        List<String> results = new List<String>();

        // System.debug('soql:' + soql);
        try{
            sobjs = Database.query(soql);
            return sobjs;
        }//end try
        catch (QueryException e){ return null; }//end catch
        return sobjs;
    }



    global static Object fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }

    private ASI_CRM_CN_Contract_BRSF_Line_Item__c PSFDetailLine(Map<String,interimData> PSF_Item_Map, String key, String keyLine){
        return PSF_Item_Map.get(key).DetailLineMap.get(keyline);
    }

    private String span(String content){
        return '<span>' + content + '</span>';
    }

    private String tableCell(String content){
        return tableCell(content, '');
    }

    private String tableCell(String content, String style){
        return '<td style="border: 1px solid black;' + style + '">' + content + endTableCell;
    }

    private String tableCell(String content, String style, String others){
        return '<td style="border: 1px solid black;' + style + '" ' + others + '>' + content + endTableCell;
    }

    private Decimal denullify(Decimal input, Double nullResult){
        if (input == null)
            return nullResult;
        else return input;
    }

    private Decimal denullify(Decimal input, Integer nullResult){
        if (input == null)
            return Decimal.valueOf(nullResult);
        else return input;
    }

    private String denullify(String input, String nullResult){
        if (input == null)
            return nullResult;
        else return input;
    }

    public String coverOutletTable(List<String> CoveredOutletNameList, Integer colNum) {
        String result;
        Boolean newRow = true;

        if (CoveredOutletNameList.size() <= 0) return result;

        result = '<table style="page-break-inside:avoid; border: 1px solid black; border-collapse: collapse;">';
        Integer columnCounter = 0;
        for (String coveredOutlet : CoveredOutletNameList) {
            //Only open new row if neccessary to avoid empty last row <tr></tr> that will cause PDF fail problem
            if (newRow){
                result += newTableRow;
                newRow = false;
            }
            result += tableCell(coveredOutlet);
            columnCounter++;
            if (columnCounter == colNum){
                result += endTableRow;
                columnCounter = 0;
                newRow = true;
            }
        }

        //Cannot fill one row, close the table directly
        if (CoveredOutletNameList.size() <= colNum) {
            result += endTableRow;
            columnCounter = 0;
        }

        while (columnCounter != 0) {
            result += tableCell('');
            columnCounter++;
            if (columnCounter == colNum) {
                result += endTableRow;
                columnCounter = 0;
            }
        }
        result += endTable + lineBreak;
        return result;
    }

    private static List<ASI_CRM_Contract_Cost__c> getContractCostsByContractId(Id contractId) {
        return [
                SELECT Id, Name, ASI_CRM_CNY_Est__c, ASI_CRM_CN_Activity_Code__c,
                        ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c,
                        ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c,
                        ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CN_Sequence__c, ASI_CRM_MAF_Est__c,
                        ASI_CRM_CN_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__r.Name,
                        ASI_CRM_Other_Est__c, ASI_CRM_CN_Svc_Req__c,ASI_CRM_CN_Service_Requirement_Central__c,ASI_CRM_CN_Service_Requirement_East__c,
                        ASI_CRM_CN_Service_Requirement_North__c,ASI_CRM_CN_Service_Requirement_Northwest__c,
                        ASI_CRM_CN_Service_Requirement_Southwest__c, 
                        ASI_CRM_CN_Contract_Amount_Rate__c
                FROM ASI_CRM_Contract_Cost__c
                WHERE ASI_CRM_CN_Contract__c = :contractId
                order by
                        ASI_CRM_CN_Sequence__c ASC,
                        ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC

        ];
    }

    private static List<ASI_CRM_Contract_Cost_Setting__c> getContractCostSettingsByActivityCodes(
            final List<Id> activityCodes ,final Set<String> chanelGroupSet ,final Set<String> promotionSet) {
        return [
                SELECT Id, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Svc_Req__c, ASI_CRM_CN_Service_Requirement_Central__c, ASI_CRM_CN_Service_Requirement_East__c,
                ASI_CRM_CN_Service_Requirement_North__c, ASI_CRM_CN_Service_Requirement_Northwest__c, ASI_CRM_CN_Service_Requirement_Southwest__c
                FROM ASI_CRM_Contract_Cost_Setting__c
                WHERE ASI_CRM_CN_Activity_Code__c in :activityCodes
                and ASI_CRM_CN_Channel__c in: chanelGroupSet
                and ASI_CRM_CN_Promotion_Type__c in: promotionSet
        ];
    }

    public static Map<Id, ASI_CRM_Contract_Cost_Setting__c> getContractCostIdSettingsMap(Id contractId) {

        final List<ASI_CRM_Contract_Cost__c> contractCosts = getContractCostsByContractId(contractId);
        // system.debug('---getContractCostIdSettingsMap===-'+contractCosts);
        final Map<Id, Id> activityCodeContractCostMap = new Map<Id, Id>();
        final List<Id> activityCodes = new List<Id>();
        final Set<String> chanelGroupSet = new Set<String>();
        final Set<String> promotionSet = new Set<String>();

        for (ASI_CRM_Contract_Cost__c contractCost : contractCosts) {
            activityCodes.add(contractCost.ASI_CRM_CN_Activity_Code__c);
            chanelGroupSet.add(contractCost.ASI_CRM_CN_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__r.Name);
            promotionSet.add(contractCost.ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c);
            activityCodeContractCostMap.put(contractCost.ASI_CRM_CN_Activity_Code__c, contractCost.Id);
        }

        final List<ASI_CRM_Contract_Cost_Setting__c> contractCostSettings = getContractCostSettingsByActivityCodes(
                activityCodes ,chanelGroupSet ,promotionSet
        );
        final Map<Id, ASI_CRM_Contract_Cost_Setting__c> contractCostIdSettingMap =
                new Map<Id, ASI_CRM_Contract_Cost_Setting__c>();

        for (ASI_CRM_Contract_Cost_Setting__c contractCostSetting : contractCostSettings) {
            final Id contractCostId = activityCodeContractCostMap.get(contractCostSetting.ASI_CRM_CN_Activity_Code__c);

            contractCostIdSettingMap.put(contractCostId, contractCostSetting);
        }

        return contractCostIdSettingMap;
    }

    public static List<String> getBasicServicesAndCostDetails(final List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingList) {

        final List<String> values = new List<String>();

        for (ASI_CRM_Contract_Printout_Setting__c contractPrintoutSetting : contractPrintoutSettingList) {
            if (contractPrintoutSetting.ASI_CRM_Content_Section_Name__c.equals('undefined')) {
                values.add(contractPrintoutSetting.ASI_CRM_Section_Content__c);
            }
        }

        return values;
    }

    public static List<ASI_CRM_Contract_Printout_Setting__c> getContractPrintoutSettings(Id contractId) {
        return [
                SELECT Id, ASI_CRM_Contract__c, ASI_CRM_Content_Section_Name__c, ASI_CRM_Header_Section_Name__c,
                        ASI_CRM_Section_Content__c, ASI_CRM_isVisible__c
                FROM ASI_CRM_Contract_Printout_Setting__c
                WHERE ASI_CRM_Contract__c = :contractId
        ];
    }

    public static Map<String, ASI_CRM_Contract_Printout_Setting__c> getContractPrintoutSettingsMap(Id contractId) {
        final List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettings = getContractPrintoutSettings(contractId);

        Map<String, ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingsMap = new Map<String, ASI_CRM_Contract_Printout_Setting__c>();
        for(ASI_CRM_Contract_Printout_Setting__c contractPrintoutSetting : contractPrintoutSettings) {
            contractPrintoutSettingsMap.put(contractPrintoutSetting.ASI_CRM_Content_Section_Name__c, contractPrintoutSetting);
        }

        return contractPrintoutSettingsMap;
    }

    // public static Map<String, ASI_CRM_Contract_Printout_Setting__c> getContractPrintoutSettingsMapBoolean(Id contractId) {
    //     final List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettings = getContractPrintoutSettings(contractId);

    //     Map<String, ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingsMap = new Map<String, ASI_CRM_Contract_Printout_Setting__c>();
    //     for(ASI_CRM_Contract_Printout_Setting__c contractPrintoutSetting : contractPrintoutSettings) {
    //         if(contractPrintoutSetting.ASI_CRM_Section_Content__c == 'false' || contractPrintoutSetting.ASI_CRM_Section_Content__c == 'true')
    //         {
    //             contractPrintoutSettingsMap.put(contractPrintoutSetting.ASI_CRM_Content_Section_Name__c, contractPrintoutSetting);
    //         }
    //     }

    //     return contractPrintoutSettingsMap;
    // }

    public void setContractSettingMap(final Map<String, String> settingMap) {
        this.ContractSettingMap = settingMap;
    }

    // public static List<ASI_CRM_Contract_Printout_Setting__c> getPrintoutSettingsByContract(Id contractId) {
    //     List<ASI_CRM_Contract_Printout_Setting__c> settings = [
    //             SELECT Id,
    //                     ASI_CRM_Content_Section_Name__c,
    //                     ASI_CRM_Contract__c,
    //                     ASI_CRM_Header_Section_Name__c,
    //                     ASI_CRM_isVisible__c,
    //                     ASI_CRM_Section_Content__c
    //             FROM ASI_CRM_Contract_Printout_Setting__c
    //             WHERE ASI_CRM_Contract__c = :contractId
    //     ];

    //     for (ASI_CRM_Contract_Printout_Setting__c setting : settings) {
    //         System.debug(setting.ASI_CRM_Header_Section_Name__c);
    //         System.debug(setting.ASI_CRM_Content_Section_Name__c);
    //         System.debug(setting.ASI_CRM_Section_Content__c);

    //         System.debug('------------------------------');
    //     }

    //     retrun settings;
    // }

}