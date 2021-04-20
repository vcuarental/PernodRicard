/* Filename:    ASI_CRM_CN_HeavyCheckPointResultCtrl.cls
* Author:      Laputa
* Purpose:     Controller for checkpoint page
* History     
* -----------------------------------------------------------------------------
* 2017-07-25   Laputa      Created

*/



public class ASI_CRM_CN_HeavyCheckPointResultCtrl {
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    
    public boolean showCN {set;get;}
    public String Msg {get;set;} {Msg='';}
    public boolean ProcessPermission {get;set;}{ProcessPermission=true;}
    public Integer WarningTimes {get;set;} {WarningTimes=0;}
    public String WarningMsg {get;set;} {WarningMsg='';}
    public Integer orgFiscalMonth {set;get;}
    
    private Map<String, String> MethodologyCNMap = new Map<String, String>();
    private Map<String, String> MethodologyENMap = new Map<String, String>();
    private Map<String, ASI_CRM_Methodology__c > MethodologyMap = new  Map<String, ASI_CRM_Methodology__c > ();
    
    public boolean AdorAbove {set;get;}{AdorAbove=false;}
    public List<interimData> SuccessCheckPointList {set;get;}  {SuccessCheckPointList = new List<interimData>();}
    public List<interimData> FailedCheckPointList {set;get;}  {FailedCheckPointList = new List<interimData>();}
    
    public Boolean DisplaySuccessCheckPointPart {get;set;}{DisplaySuccessCheckPointPart=true;}
    public Boolean DisplayFailedCheckPointPart {get;set;}{DisplayFailedCheckPointPart=true;}
    public Decimal FixedCostTotal {get;set;}{FixedCostTotal=0;}
    public Decimal DetailAmount {get;set;}{DetailAmount=0;}
    public Boolean NeedPRVApproval {get;set;}{NeedPRVApproval=false;}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalV00Contract  {set;get;} { HistoricalV00Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalVFinalContract  {set;get;} { HistoricalVFinalContract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContractV0Esitimate  {set;get;} { NewContractV0Esitimate = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContactVFinal  {set;get;} { NewContactVFinal = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract2nd  {set;get;} { HistoricalV00Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalVFinalContract2nd  {set;get;} { HistoricalVFinalContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContractV0Esitimate2nd  {set;get;} { NewContractV0Esitimate2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactV0Contract2nd  {set;get;} { NewContactV0Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactVFinal2nd  {set;get;} { NewContactVFinal2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    
    public Boolean ShowSubmitApproval {set;get;} {ShowSubmitApproval=false;}
    
    public String BRSFDefaultMethodology {set;get;} {BRSFDefaultMethodology='';}
    
    public String PSFDefaultMethodology {set;get;} {PSFDefaultMethodology='';}

    public String FIXEDefaultMethodology {set;get;} {FIXEDefaultMethodology='';}
    
    
    public String PageId {set;get;}
    public Decimal PRCGuidance   {set;get;} {PRCGuidance=0.0;} 
    
    // Modifier: Bluelinksys_PC Date : 2020-03-12
    public String strVersionType1{GET;SET;}{strVersionType1 = '';}
    public String strVersionType2{GET;SET;}{strVersionType2 = '';}
    public List<ASI_CRM_Segmentation_Criteria_Item__c> sciList;
    public List<ASI_CRM_Segmentation_Criteria_Item__c> RegionalCriteriaItemIdList;
    public Boolean volumeCheckDisplay{GET;SET;}{volumeCheckDisplay = true;}
    // public Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine2nd> VolumeCheckMap1;
    // public Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine2nd> VolumeCheckMap2;
    List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> volumeCheckList1;
    List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> volumeCheckList2;
    public List<interimData> VolumeCheckPortList{GET;SET;}  {VolumeCheckPortList = new List<interimData>();}
    public Map<String,Decimal> RegionalAverageInvestmentMap = new Map<String,Decimal>();
    public Map<String,Decimal> VolumeMixMap1 = new Map<String,Decimal>();
    public Map<String,Decimal> VolumeMixMap2 = new Map<String,Decimal>();
    public Boolean isModify{GET;SET;}

    public String BelongGroup{GET;SET;} {BelongGroup = ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.UserOrGroupInit();}

    public class interimData{
        public ASI_CRM_SegmentationCriteria__c SegmentationCriteria {set;get;}

        public Decimal Dimension1stResult {set;get;} {Dimension1stResult=0.0;}
        public Decimal Dimension2ndResult {set;get;} {Dimension2ndResult=0.0;}

        public String Type1stName {set;get;}{Type1stName='';} // Methodology or Volume Base
        public String Type2ndName {set;get;}{Type2ndName='';}

        public Date Period1stResult {set;get;}{Period1stResult=date.today();}
        public Date Period2ndResult {set;get;}{Period2ndResult=date.today();}
        
        public String Display1stResult {set;get;} {Display1stResult='';}
        public String Display2ndResult {set;get;} {Display2ndResult='';}
        
        public String Display1stResultEN {set;get;} {Display1stResultEN='';}
        public String Display2ndResultEN {set;get;} {Display2ndResultEN='';}
        
        public Boolean DisplayToUser  {set;get;} {DisplayToUser=true;}
        public String ReachTarget  {set;get;} {ReachTarget ='Yes';} // Reach Target ? Or NO

        // VolumeCheck Authoor: Bluelinksys_PC;Date:2020-03-26;
        public String brandName{GET;SET;}{brandName = '';}
        public Decimal volumeCheckResult1{GET;SET;}{volumeCheckResult1 = 0;}
        public Decimal volumeCheckResult2{GET;SET;}{volumeCheckResult2 = 0;}
        public Decimal volumeCheckResult3{GET;SET;}{volumeCheckResult1 = 0;}

        public interimData(){ }
        public interimData(ASI_CRM_SegmentationCriteria__c sc){
            this.SegmentationCriteria= sc;
        }

        public String english_Interpretation {set;get;}
        public String chinese_Interpretation {set;get;}

    }
    
    
    
    public ASI_CRM_CN_HeavyCheckPointResultCtrl(ApexPages.StandardController controller) {
        this.ContractSelected = (ASI_TH_CRM_Contract__c )controller.getRecord();
        if(this.ContractSelected != null)
            PageId = ContractSelected.id;
        this.ContractSelected = [SELECT Id,Name,ASI_CRM_CN_National_Group_Contract__c, ASI_CRM_CN_Local_Group_Contract__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Group_Contract__c,ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__c,ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__r.ASI_CRM_Special_COA_Approval_Flow__c,
                                     ASI_CRM_RVP_Approval__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Last_PO_version__c,
                                     ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,
                                     ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_Copied_From__r.ASI_CRM_EVC_Cost_Estimate_Total__c,
                                     ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c,ASI_CRM_Copied_From__c,
                                     ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c,ASI_CRM_CN_PO_Modification__c,
                                     Owner.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Fixed_Module_Est_Amount1__c,ASI_CRM_CN_Fixed_Module_Est_Amount2__c,
                                     ASI_CRM_Copied_From__r.ASI_CRM_CN_Fixed_Module_Est_Amount1__c,ASI_CRM_Copied_From__r.ASI_CRM_CN_Fixed_Module_Est_Amount2__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,
                                     ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Fixed_Cost_Contract_Total__c,ASI_CRM_CN_Status__c
                                 FROM ASI_TH_CRM_Contract__c 
                                 WHERE id =:pageId ];
        
        // Judge contract version
        if(ContractSelected.ASI_CRM_CN_PO_Version__c != '0.0' && ContractSelected.ASI_CRM_CN_Status__c.toLowerCase() != 'fy landing archive'){
            isModify = true;
        }
        
        init();
    }
    
    public void init(){
        
        boolean ExistHistoricalData=false;
        if(ContractSelected.ASI_CRM_CN_Group_Contract__c!=null){
            if(ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__c!=null){
                if(ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__r.ASI_CRM_Special_COA_Approval_Flow__c){
                    ContractSelected.ASI_CRM_RVP_Approval__c=TRUE;
                    NeedPRVApproval=true;
                }
            }
        }
        
        
        checkUserID();
        orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        
        showCN = USerInfo.getLanguage()=='zh_CN';
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        string TypeName = params.get('Type');
        if(TypeName =='SubmitApproval'){
            ShowSubmitApproval =true;
        }
        
        //Calculate Fix cost amount and Total Amount
        if (!ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c,   ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c  FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id]){
                if (ccost.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                    FixedCostTotal += ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
                }
            }
        }
        
        
      
        
        if(ContractSelected.ASI_CRM_CN_PO_Version__c!='0.0'){
            DetailAmount+=ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null? ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
            DetailAmount+=ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null? ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
            DetailAmount+=ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c!=null? ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                Map<String,ASI_CRM_CN_FixedMappingSetting__c> settingMap = ASI_CRM_CN_FixedMappingSetting__c.getAll();

                for (ASI_CRM_CN_FixedMappingSetting__c fixedSetting :  settingMap.values()) {
                        if (
                            ContractSelected.get(fixedSetting.ASI_CRM_CN_Contract_Mapping_Field__c) != null && 
                            String.valueOf(ContractSelected.get(fixedSetting.ASI_CRM_CN_Contract_Mapping_Field__c)) != null && 
                            String.valueOf(ContractSelected.get(fixedSetting.ASI_CRM_CN_Contract_Mapping_Field__c)) != '') {
                            FixedCostTotal += Decimal.valueOf(String.valueOf(ContractSelected.get(fixedSetting.ASI_CRM_CN_Contract_Mapping_Field__c)));
                        }
                }
            }
        }else{
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> thisCC_BRSFList = [SELECT Id,RecordType.DeveloperName, ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Methodology__c,
                                                                           ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name, 
                                                                           ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,
                                                                           ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name, 
                                                                           ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,
                                                                           ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,ASI_CRM_CN_Estimate_Volume_9L_Month__c, 
                                                                           ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_Volume_Base__c,ASI_CRM_Type__c  from ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                           WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id];
            
            //Looping BRSF Line
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : thisCC_BRSFList){
                if(ContractLine.ASI_CRM_Type__c != 'Fixed'){
                    DetailAmount += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null
                                                                                    ? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c
                                                                                    : 0;
                }else if(ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                    FixedCostTotal += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null
                                                                                      ? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c
                                                                                      : 0;
                }
            }
        }
        System.debug('*********FixedCostTotal*******'+FixedCostTotal);
        
        MethodologyCNMap = new Map<String, String>();
        MethodologyENMap = new Map<String, String>();
        MethodologyMap = new Map<String,ASI_CRM_Methodology__c > ();
        //Find Default value for PSF
        List<ASI_CRM_Methodology__c> MethodologyList=[select Id,ASI_CRM_Default__c,Name,ASI_CRM_Type__c,ASI_CRM_Chinese_Name__c,ASI_CRM_Sequence__c from  ASI_CRM_Methodology__c 
                                                      where  RecordType.DeveloperName ='ASI_CRM_CN_Methodology'and (ASI_CRM_Type__c='BRSF' OR ASI_CRM_Type__c ='PSF') ];
        
        for(ASI_CRM_Methodology__c Methodology:MethodologyList){
            if(Methodology.ASI_CRM_Default__c){
                if(Methodology.ASI_CRM_Type__c =='BRSF'){
                    BRSFDefaultMethodology=Methodology.Id;
                }
                if(Methodology.ASI_CRM_Type__c =='PSF'){
                    PSFDefaultMethodology=Methodology.Id;
                }
            }
            MethodologyMap.put(Methodology.Id,Methodology );
            MethodologyCNMap.put(Methodology.Id, Methodology.ASI_CRM_Chinese_Name__c ) ;
            MethodologyENMap.put(Methodology.Id, Methodology.Name  ) ;
        }
                
        ASI_CRM_CN_CustomSetting__c CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        PRCGuidance=CustomSetting.ASI_CRM_PRC_Guidance__c;
        
        //Geting HistoricalV0.0 and VFinal Data
        List<ASI_Attachment__c> AttachmentList= [SELECT id,
                                                        ASI_CRM_Historical_Financial_Data__c,
                                                        ASI_CRM_Historical_Financial_Data2__c,
                                                        ASI_CRM_Historical_Financial_Data3__c,
                                                        ASI_CRM_Historical_Financial_Data4__c,
                                                        ASI_CRM_Contract__c,ASI_CRM_Type__c 
                                                 FROM ASI_Attachment__c 
                                                 WHERE ASI_CRM_Contract__c = :ContractSelected.Id ];
        if(AttachmentList.size()>0){
            if (!ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                for(ASI_Attachment__c att:AttachmentList){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    if(att.ASI_CRM_Type__c=='Historical Data'){
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(HistoricalContractList.size()>0){
                            HistoricalV00Contract= HistoricalContractList[0];
                            HistoricalVFinalContract= HistoricalContractList[1];
                        } 
                    }else if(att.ASI_CRM_Type__c=='Contract Data' && ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0' ){
                        JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(ContractList.size()>0){
                            NewContractV0Esitimate= ContractList[0];
                            NewContactV0Contract= ContractList[1];
                        } 
                    }else if(att.ASI_CRM_Type__c=='Historical Modi Data' && ContractSelected.ASI_CRM_CN_PO_Version__c !='0.0' ){
                        JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(ContractList.size()>0){
                            NewContractV0Esitimate= ContractList[0];
                            NewContactV0Contract= ContractList[0];
                        } 
                    }else if(att.ASI_CRM_Type__c=='PO Modification Data'){
                        JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class); 
                        if(ContractList.size()>0){
                            NewContactVFinal= ContractList[0];
                        }
                    }
                }
            } else {
                for(ASI_Attachment__c att:AttachmentList){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                            +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                            +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                            +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');

                    if(att.ASI_CRM_Type__c=='Historical Data'){
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                        if(HistoricalContractList.size()>0){
                            HistoricalV00Contract2nd= HistoricalContractList[0];
                            HistoricalVFinalContract2nd= HistoricalContractList[1];
                        }
                    }else if(att.ASI_CRM_Type__c=='Contract Data' && ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0' ){
                        // JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);

                        if(ContractList.size()>0){
                            NewContractV0Esitimate2nd= ContractList[0];
                            NewContactV0Contract2nd= ContractList[1];
                        }
                    }else if(att.ASI_CRM_Type__c=='Historical Modi Data' && ContractSelected.ASI_CRM_CN_PO_Version__c !='0.0' ){
                        // JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                        if(ContractList.size()>0){
                            NewContractV0Esitimate2nd= ContractList[0];
                            NewContactV0Contract2nd= ContractList[0];
                        } 
                    }else if(att.ASI_CRM_Type__c=='PO Modification Data'){
                        // JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                        System.debug(LoggingLevel.INFO, '*** JsonString: ' + JsonString);
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class); 
                        if(ContractList.size()>0){
                            NewContactVFinal2nd= ContractList[0];
                        }
                    }
                }
            }
        }
        
        
        
        if(ContractSelected.ASI_CRM_CN_PO_Version__c!='0.0' && ContractSelected.ASI_CRM_CN_V0_0_PO_version__c !=null){
            ///system.assertEquals(ContractSelected.ASI_CRM_CN_V0_0_PO_version__c, Null);
            system.debug('V0_0_PO_version : '+ContractSelected.ASI_CRM_CN_V0_0_PO_version__c);
            List<ASI_Attachment__c> V0AttachmentList= [SELECT id,
                                                              ASI_CRM_Historical_Financial_Data__c,
                                                              ASI_CRM_Historical_Financial_Data2__c,
                                                              ASI_CRM_Historical_Financial_Data3__c,
                                                              ASI_CRM_Historical_Financial_Data4__c,
                                                              ASI_CRM_Contract__c,
                                                              ASI_CRM_Type__c 
                                                       FROM ASI_Attachment__c 
                                                       WHERE ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c ];
            if (!ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {                                         
                for(ASI_Attachment__c att:V0AttachmentList){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    if(att.ASI_CRM_Type__c=='Historical Data'){
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(HistoricalContractList.size()>0){
                            HistoricalV00Contract= HistoricalContractList[0];
                            HistoricalVFinalContract= HistoricalContractList[1];
                        } 
                    }else if(att.ASI_CRM_Type__c=='Contract Data'  ){
                        //system.debug('Contract Data : '+);
                        
                        JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(ContractList.size()>0){
                            NewContractV0Esitimate= ContractList[0];
                            NewContactV0Contract= ContractList[1];
                        } 
                    }
                    
                }
            } else {
                for(ASI_Attachment__c att:V0AttachmentList){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                            +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                            +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                            +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');
                    if(att.ASI_CRM_Type__c=='Historical Data'){
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                        if(HistoricalContractList.size()>0){
                            HistoricalV00Contract2nd= HistoricalContractList[0];
                            HistoricalVFinalContract2nd= HistoricalContractList[1];
                        }
                    }else if(att.ASI_CRM_Type__c=='Contract Data'  ){
                        
                        JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                        if(ContractList.size()>0){
                            NewContractV0Esitimate2nd= ContractList[0];
                            NewContactV0Contract2nd= ContractList[1];
                        }
                    }
                    
                }
            }
        }
        
        
        
        system.debug('Now HistoricalV00Contract ContractId : '+HistoricalV00Contract.ContractId);
        if(HistoricalV00Contract.ContractId!='' || HistoricalV00Contract2nd.ContractId!=''){
            ExistHistoricalData=true;
        }
        
        //
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmentationCriteriaMap =  new Map<String,ASI_CRM_SegmentationCriteria__c>();
        if(ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0'){
            if(ContractSelected.ASI_CRM_CN_Local_Group_Contract__c || ContractSelected.ASI_CRM_CN_National_Group_Contract__c){
                SegmentationCriteriaMap = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_PO_Open_Group_Contract_Checkpoint_Criteria');
            }else{
                if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {   
                    SegmentationCriteriaMap = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_PO_Open_Checkpoint_Criteria_2nd'); 
                }
                else {
                    SegmentationCriteriaMap = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_PO_Open_Checkpoint_Criteria'); 
                }
            }
        }else{
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {   
                SegmentationCriteriaMap = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_PO_Modi_Checkpoint_Criteria_2nd');
            }
            else {
                SegmentationCriteriaMap = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_PO_Modi_Checkpoint_Criteria');
            }
        }
        
        system.debug('SegmentationCriteriaMap Size:'+SegmentationCriteriaMap.size());

        //SegmentationCriteriaMap put(SegmentationCriteria.Id, SegmentationCriteria)
        String segmentId;
        String RegionalCriteriaItemId;
        for (String key: SegmentationCriteriaMap.keySet()) {

            if (SegmentationCriteriaMap.get(key).ASI_CRM_Financial_Indicator__c == 'Volume mix') {
                segmentId = key;
            }
            // if(SegmentationCriteriaMap.get(key).ASI_CRM_Financial_Indicator__c == 'Regional Average Target'){
            //     RegionalCriteriaItemId = key;
            // }
        }

        if (!string.isBlank(segmentId)) {
            sciList = [SELECT ASI_CRM_CN_Subbrand__r.Name, 
                              ASI_CRM_CN_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                              ASI_CRM_CN_Subbrand__r.ASI_HK_CRM_Sequence__c,
                              ASI_CRM_CN_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c,
                              ASI_CRM_CN_Subbrand__c,
                              ASI_CRM_CN_Subbrand__r.ASI_HK_CRM_English_Name__c
                      FROM ASI_CRM_Segmentation_Criteria_Item__c  
                      WHERE ASI_CRM_SegmentationCriteria__c = :segmentId];

            if (sciList.isEmpty()) {
                volumeCheckDisplay = false;
            }
        }else{
            volumeCheckDisplay = false;
        }

        // if(!String.isBlank(RegionalCriteriaItemId)){
        //     RegionalCriteriaItemIdList = [SELECT ASI_CRM_CN_Subbrand__r.Name, 
        //                                         ASI_CRM_CN_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
        //                                         ASI_CRM_CN_Subbrand__r.ASI_HK_CRM_Sequence__c,
        //                                         ASI_CRM_CN_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c,
        //                                         ASI_CRM_CN_Subbrand__c,
        //                                         ASI_CRM_CN_Subbrand__r.ASI_HK_CRM_English_Name__c
        //                                     FROM ASI_CRM_Segmentation_Criteria_Item__c  
        //                                     WHERE ASI_CRM_SegmentationCriteria__c = :RegionalCriteriaItemId];
        // }
        
        //System.debug('RegionalCriteriaItemId'+RegionalCriteriaItemId);
        // looping SegmentationCriteriaMap Line
        for(String key: SegmentationCriteriaMap.keySet()){
            system.debug('Data:'+SegmentationCriteriaMap.get(key));

            interimData temp = new interimData (SegmentationCriteriaMap.get(key));

            //Comparing values firse
            temp= FirstDimensionAssignment(temp);

            //Comparing values second
            temp= SecondDimensionAssignment(temp);

            //Data Checking
            temp=DataOperationChecking(temp);

            temp=DisplayFormating(temp);

            // GroupMember Group.DeveloperName='ASI_CRM_CN_AD_or_Above'  AdorAbove = true
            if(temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI') && !AdorAbove){
                temp.DisplayToUser=false;
            }

            if(temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('CM/NS%')){
                if (belongGroup.contains('C') || belongGroup.contains('D')) {
                    temp.DisplayToUser=true;
                } else {
                    temp.DisplayToUser=false;
                }
                
            }
            
            Boolean AllowPut= true;

            // VolumeDataCheck  (ASI_CRM_Financial_Indicator__c == 'Volume mix')
            if (volumeCheckDisplay && temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c == 'Volume mix') {
                VolumeChecking(temp);
                AllowPut=false;
            }
            
            //decide if it aloow to put 
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

            //Add RegionalAverageInvestmentMap Data

            // if(temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c == 'Regional Average Target' && !RegionalCriteriaItemIdList.isEmpty() 
            //                                                                                                 && !RegionalAverageInvestmentMap.isEmpty()){
            //     AllowPut=false;
            //     for(ASI_CRM_Segmentation_Criteria_Item__c sci : RegionalCriteriaItemIdList){
            //         if(RegionalAverageInvestmentMap.containsKey(sci.ASI_CRM_CN_Subbrand__c)){

            //             interimData regtemp = RegionalAverageChecking(temp, RegionalAverageInvestmentMap,sci);
            //             if(regtemp.ReachTarget =='Yes'){
            //                 SuccessCheckPointList.add(regtemp);
            //             }else if(regtemp.ReachTarget =='No'){
            //                 FailedCheckPointList.add(regtemp);
            //             }
            //         }
            //     }
            // }
           
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
    
    //Dimension 2 Number adding value or add Alignment Percentage
    public static Decimal GenerateDimension2Number1( interimData InputInterimData ){
        Decimal Dimension2Number = InputInterimData.Dimension2ndResult;
        system.debug('** Dimension2Number 1** :'+Dimension2Number); 
        if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c!=null){
            
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c !='Within'){ // not Within
                //Percentage
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c!=null){
                    Dimension2Number=(1+InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Percentage__c/100)*Dimension2Number;
                }
                //Value
                Dimension2Number =InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c!=null? InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c+Dimension2Number:Dimension2Number;   
            }else{ //  Operation is Within
                if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Theoretical Value'){
                    Dimension2Number =InputInterimData.SegmentationCriteria.ASI_CRM_Min_Value__c!=null ? InputInterimData.SegmentationCriteria.ASI_CRM_Min_Value__c : 0 ;
                  
                }else{//others like 'New Contract V0.0 Est.'
                    if(InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Down__c !=null ){
                        Dimension2Number =Dimension2Number-InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Down__c;
                        system.debug('** Dimension2Number 2** :'+Dimension2Number); 
                    }
                    if(InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Percent_Down__c !=null){
                        Dimension2Number=(1 - InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Percent_Down__c /100)*Dimension2Number;
                        system.debug('** Dimension2Number 3** :'+Dimension2Number); 
                    }
                    
                }
            }
            
        }
        system.debug('** Dimension2Number 4 ** :'+Dimension2Number); 
        //SetSCale
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('BC') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Fixed Expense') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c  ==  'Contract Index' || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c  == 'CM/NS%' || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c  ==  'vs Regional average index' ){
            Dimension2Number=Dimension2Number != null?Dimension2Number.SetSCale(0):0;
        }else{
            Dimension2Number=Dimension2Number != null?Dimension2Number.SetSCale(2):0;
        }
        
        return Dimension2Number;
    }
    
    
    
    public static Decimal GenerateDimension2Number2( interimData InputInterimData ){
        Decimal Dimension2Number = InputInterimData.Dimension2ndResult;
        system.debug(Dimension2Number); 
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c =='Within'){ 
            if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Theoretical Value'){
                Dimension2Number = InputInterimData.SegmentationCriteria.ASI_CRM_Max_Value__c !=null ? InputInterimData.SegmentationCriteria.ASI_CRM_Max_Value__c :0 ;
                
            }else{//others like 'New Contract V0.0 Est.'
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Up__c !=null ){
                    Dimension2Number =Dimension2Number+InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Up__c;
                }
                if( InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Percent_Up__c !=null ){
                    Dimension2Number=(1 + InputInterimData.SegmentationCriteria.ASI_CRM_Floating_Interval_Percent_Up__c /100)*Dimension2Number;
                }
                
            }
        }
        
        //SetSCale
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('BC') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Fixed Expense')|| InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c  ==  'Contract Index' || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c  == 'CM/NS%' ){
            Dimension2Number=Dimension2Number.SetSCale(0);
        }else{
            Dimension2Number=Dimension2Number.SetSCale(2);
        }       
        return Dimension2Number;
    }
    
    
    
    
    //perform data level checking 
    public interimData DataOperationChecking(interimData InputInterimData){
        String FinancialIndicator = InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c;
        InputInterimData.english_Interpretation = InputInterimData.SegmentationCriteria.ASI_CRM_English_Interpretation__c;
        InputInterimData.chinese_Interpretation = InputInterimData.SegmentationCriteria.ASI_CRM_Chinese_Interpretation__c;
        //Number 
        if(FinancialIndicator.contains('Volume:') || FinancialIndicator.contains('Trade Expenses') ||  
           FinancialIndicator.contains('BC') || FinancialIndicator  ==  'Contract Index' || FinancialIndicator  == 'CM/NS%' || FinancialIndicator  == 'vs Regional average index'){
            Decimal Dimension2Value1 = GenerateDimension2Number1(InputInterimData);
            Decimal Dimension2Value2= GenerateDimension2Number2(InputInterimData);
            
            if(FinancialIndicator.contains('Volume:') || FinancialIndicator.contains('BC') || FinancialIndicator.contains('Fixed Expense') ){
                InputInterimData.Dimension1stResult=InputInterimData.Dimension1stResult.SetSCale(0);
            }else{
                InputInterimData.Dimension1stResult=InputInterimData.Dimension1stResult.SetSCale(2);
                
            }
            
            if(!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c, InputInterimData.Dimension1stResult, Dimension2Value1, Dimension2Value2)){
                InputInterimData.ReachTarget ='No';
            }//system.debug('Now ReachTarget : '+InputInterimData.ReachTarget);
            
            //Set displaying result 
            InputInterimData.Display1stResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c+'= '+InputInterimData.Dimension1stResult.format();
            InputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+'= '+InputInterimData.Dimension1stResult.format();
            
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || 
               InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Trade Expenses') ||  
               InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('BC') ||
               FinancialIndicator  ==  'Contract Index' || 
               FinancialIndicator  == 'CM/NS%' || FinancialIndicator  == 'vs Regional average index'){
                if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c!=null ){
                    InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
                    InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);
                }else{
                    
                    InputInterimData.Display2ndResultEN='Theoretical Value';
                    InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Theoretical Value');
                }

                if(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c !='Within'){ 
                    if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('BC') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Fixed Expense')){
                        InputInterimData.Display2ndResultEN+=' = '+InputInterimData.Dimension2ndResult.SetSCale(0).format();
                        InputInterimData.Display2ndResult+=' = '+InputInterimData.Dimension2ndResult.SetSCale(0).format();
                    }else{
                        InputInterimData.Display2ndResultEN+=' = '+InputInterimData.Dimension2ndResult.SetSCale(2).format();
                        InputInterimData.Display2ndResult+=' = '+InputInterimData.Dimension2ndResult.SetSCale(2).format(); 
                    }
                }else{// within display
                    InputInterimData.Display2ndResultEN+=' :<br/>  Min= '+Dimension2Value1.format()+'<br/> Max='+Dimension2Value2.format();
                    InputInterimData.Display2ndResult+=' :<br/> 最小值=  '+Dimension2Value1.format() +'<br/> 最大值='+Dimension2Value2.format();
                } 

                if (FinancialIndicator  == 'CM/NS%') {
                    InputInterimData.Display1stResult = InputInterimData.Display1stResult + '%';
                    InputInterimData.Display1stResultEN = InputInterimData.Display1stResultEN + '%';
                    InputInterimData.Display2ndResult = InputInterimData.Display2ndResult + '%';
                    InputInterimData.Display2ndResultEN = InputInterimData.Display2ndResultEN + '%';
                } 
            }
            
        }else if(FinancialIndicator =='Period: PO Start Date'){
            Date Period2Date= InputInterimData.Period2ndResult;
            system.debug('InputInterimData.Period2ndResult : '+InputInterimData.Period2ndResult);
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c!=null){
                Integer AddDay= Integer.valueOf(InputInterimData.SegmentationCriteria.ASI_CRM_Alignment_Value__c);
                system.debug(Period2Date+'AddDay : '+AddDay);
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
            
        }else if(FinancialIndicator =='Methodology: BRSF Methodology' || FinancialIndicator =='Methodology: PSF Methodology'){
            List<String> Type1stNameParts = InputInterimData.Type1stName.split(';');
            List<String> Type2ndNameParts = InputInterimData.Type2ndName.split(';');
            
            InputInterimData.Display1stResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c+'=';
            InputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+'=';
            
            InputInterimData.ReachTarget ='Yes';
            for(String MethId: Type1stNameParts){
                if(MethodologyMap.containsKey(MethId) && MethodologyMap.containsKey(Type2ndNameParts[0]) ){
                    
            
                    if(MethodologyMap.get(MethId).ASI_CRM_Sequence__c > MethodologyMap.get(Type2ndNameParts[0]).ASI_CRM_Sequence__c  ){
                        InputInterimData.ReachTarget ='No';
                         system.debug(InputInterimData.SegmentationCriteria.ASI_CRM_Chinese_Interpretation__c+ ' Methodology Type1stName 123: '+ MethId );
                    }
                    InputInterimData.Display1stResult += MethodologyMap.get(MethId).ASI_CRM_Chinese_Name__c+';';
                    InputInterimData.Display1stResultEN += MethodologyMap.get(MethId).Name+';';
                    //ASI_CRM_Chinese_Name__c
                }
            }
            
            
            
            /*
            if(!InputInterimData.Type1stName.contains(';')){
                if(MethodologyMap.containsKey(InputInterimData.Type1stName)){
                    InputInterimData.Display1stResult+='No Data';
                    InputInterimData.Display1stResultEN+='No Data';
                }
            }
            */
            
            
            
        }else if(FinancialIndicator=='Methodology: PSF Volume Base'){
            if(InputInterimData.Type1stName.contains('Total') || InputInterimData.Type1stName.contains('Category')  ){
                InputInterimData.ReachTarget ='No';
            }
            
            InputInterimData.Display1stResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c +'='+InputInterimData.Type1stName;
            InputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)
                +'='+InputInterimData.Type1stName;
            if(InputInterimData.Type1stName==''){
                InputInterimData.Display1stResult+='No Data';
                InputInterimData.Display1stResultEN+='No Data';
            }
            
        }
        System.debug(LoggingLevel.INFO, '*** InputInterimData: ' + InputInterimData);
        return InputInterimData;
    }
    
    //2nd Dimension Assignment
    public interimData SecondDimensionAssignment(interimData InputInterimData){
        
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')){
            InputInterimData.Dimension2ndResult = ByVolumeFinancialIndicator(InputInterimData.SegmentationCriteria,'2');
        }else{
            if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c !=null){
                if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd FIMasterData = FinancialIndicatorMasterData2nd(InputInterimData.SegmentationCriteria,'2');
                    if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Fixed Expense %'){
                        InputInterimData.Dimension2ndResult= FIMasterData.FixedExpenseRate.SetSCale(0);
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){
                        InputInterimData.Dimension2ndResult= FIMasterData.InvestmentCR12;
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI')){//InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI'
                        InputInterimData.Dimension2ndResult= FIMasterData.ROIIntake;
                        system.debug('FIMasterData.ROIIntake : '+FIMasterData.ROIIntake );
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='BC: BC%'){
                        InputInterimData.Dimension2ndResult= FIMasterData.BCRate.SetSCale(0);
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Martell BC Rate'){
                        InputInterimData.Dimension2ndResult= FIMasterData.TotalMBCRate.SetSCale(0);
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date'){
                        InputInterimData.Period2ndResult= FIMasterData.POStartDate;
                    }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology'){
                        InputInterimData.Type2ndName=FIMasterData.BRSFMethodologyName;
                        InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
                        InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);
                    }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: PSF Methodology'){
                        InputInterimData.Type2ndName=FIMasterData.PSFMethodologyName;
                        InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
                        InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);
                    }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'CM/NS%') {
                        InputInterimData.Dimension2ndResult= FIMasterData.CMNSRate;
                    }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Contract Index') {
                        InputInterimData.Dimension2ndResult= FIMasterData.DomesticContractIndexProForma;
                    }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Volume mix') {
                        for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd at : FIMasterData.TradeExpenseBySubBrand){
                            VolumeMixMap2.put(at.subBrandId,at.propByStdTotal * 100);
                        }
                    }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'vs Regional average index') {
                        InputInterimData.Dimension2ndResult= FIMasterData.VsRegionalAverageIndexProForma;
                    }
                } else {
                    ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria,'2');
                    if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Fixed Expense %'){
                        InputInterimData.Dimension2ndResult= FIMasterData.FixedExpenseRate.SetSCale(0);
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){
                        InputInterimData.Dimension2ndResult= FIMasterData.InvestmentCR12;
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI')){//InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI'
                        InputInterimData.Dimension2ndResult= FIMasterData.ROIIntake;
                        system.debug('FIMasterData.ROIIntake : '+FIMasterData.ROIIntake );
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='BC: BC%'){
                        InputInterimData.Dimension2ndResult= FIMasterData.BCRate.SetSCale(0);
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Martell BC Rate'){
                        InputInterimData.Dimension2ndResult= FIMasterData.TotalMBCRate.SetSCale(0);
                    }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date'){
                        InputInterimData.Period2ndResult= FIMasterData.POStartDate;
                    }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology'){
                        InputInterimData.Type2ndName=FIMasterData.BRSFMethodologyName;
                        InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
                        InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);
                    }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: PSF Methodology'){
                        InputInterimData.Type2ndName=FIMasterData.PSFMethodologyName;
                        InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
                        InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);
                    }
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
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PRC Guidance'){
                InputInterimData.Dimension2ndResult=PRCGuidance;
                
                InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c+' = '+PRCGuidance;
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c)+' = '+PRCGuidance;
            }
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PO Submit Date'){
                InputInterimData.Period2ndResult=date.today();
                
                InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c+'=Today';
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c)+'=Today (今天)';
            }
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PRC Default Methodology' || InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PSF Methodology'){//if choosing Default Methodology, replace with Default Methodology Id
                //system.debug('Enter PRC Default Methodology ');
                if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology'){
                    InputInterimData.Type2ndName=BRSFDefaultMethodology;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: PSF Methodology'){
                    InputInterimData.Type2ndName=PSFDefaultMethodology;
                }
                InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c;
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c);//'Default Methodology'; 
            }
            
            if(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PRC Default Volume Base'){
                InputInterimData.Type2ndName='By Sub Brand and By Grade.';
                InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c+'=By Sub-Brand or By Grade.';
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c)+'= 按品牌 或 按品牌档次';
            }
            
        }else{
            /*if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || 
               InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Trade Expenses') ||  
               InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('BC') )
            {
                InputInterimData.Dimension2ndResult= InputInterimData.Dimension2ndResult.SetSCale(0);
            }else */
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c =='Period: PO Start Date'){
                InputInterimData.Display2ndResultEN= InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c+' = '+ InputInterimData.Period2ndResult;          
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c)+' = '+ InputInterimData.Period2ndResult;
            }
            
        }
        
        //display Info for Methodology
        if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology' || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: PSF Methodology'){
            if(InputInterimData.Type2ndName==''){
                InputInterimData.Display2ndResultEN+='= No Data;';
                InputInterimData.Display2ndResult+='= No Data;';
            }else if(!InputInterimData.Type2ndName.contains(';')){
                if(MethodologyCNMap.containsKey(InputInterimData.Type2ndName)){
                    InputInterimData.Display2ndResult += '='+ MethodologyCNMap.get(InputInterimData.Type2ndName);
                }
                if(MethodologyENMap.containsKey(InputInterimData.Type2ndName)){
                    InputInterimData.Display2ndResultEN += '='+ MethodologyENMap.get(InputInterimData.Type2ndName);
                }
            }else if(InputInterimData.Type2ndName.contains(';')){
                List<String> MethodologyIdList = InputInterimData.Type2ndName.split(';');
                for(string KeyId : MethodologyIdList){
                    if(MethodologyCNMap.containsKey(KeyId)){
                        InputInterimData.Display2ndResult+=MethodologyCNMap.get(KeyId)+';';
                    } 
                    if(MethodologyENMap.containsKey(KeyId)){
                        InputInterimData.Display2ndResultEN+=MethodologyENMap.get(KeyId)+';';
                    } 
                }
            }
        }
        
        
        
        return InputInterimData; 
    }
    
    
    
    
    //First Dimension Assignment
    public interimData FirstDimensionAssignment(interimData InputInterimData){
        
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')){
            InputInterimData.Dimension1stResult = ByVolumeFinancialIndicator(InputInterimData.SegmentationCriteria,'1');
        }else{
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd FIMasterData = FinancialIndicatorMasterData2nd(InputInterimData.SegmentationCriteria,'1');
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Fixed Expense %'){
                    InputInterimData.Dimension1stResult= FIMasterData.FixedExpenseRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){
                    InputInterimData.Dimension1stResult= FIMasterData.InvestmentCR12;
                } else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI')){//else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI' || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI(Actual)'){
                    InputInterimData.Dimension1stResult= FIMasterData.ROIIntake;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='BC: BC%'){
                    InputInterimData.Dimension1stResult= FIMasterData.BCRate.SetSCale(0);
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Martell BC Rate'){
                    InputInterimData.Dimension1stResult= FIMasterData.TotalMBCRate.SetSCale(0);
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date'){
                    InputInterimData.Period1stResult= FIMasterData.POStartDate;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology'){
                    InputInterimData.Type1stName=FIMasterData.BRSFMethodologyName;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Methodology: PSF Methodology'){
                    InputInterimData.Type1stName=FIMasterData.PSFMethodologyName;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Methodology: PSF Volume Base'){
                    InputInterimData.Type1stName=FIMasterData.PSFVolumeBase;
                }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'CM/NS%') {
                    InputInterimData.Dimension1stResult= FIMasterData.CMNSRate;
                }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Contract Index') {
                    InputInterimData.Dimension1stResult= FIMasterData.DomesticContractIndexProForma;
                }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Volume mix') {
                    for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd at : FIMasterData.TradeExpenseBySubBrand){
                        VolumeMixMap1.put(at.subBrandId,at.propByStdTotal * 100);
                    }
                }
                // else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Regional Average Target'){
                //     for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd at : FIMasterData.TradeExpenseBySubBrand){
                //         RegionalAverageInvestmentMap.put(at.subBrandId,at.GapWithRegionalAverageInvestment);
                //     }
                // }
                else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'vs Regional average index') {
                    InputInterimData.Dimension1stResult= FIMasterData.VsRegionalAverageIndexProForma;
                }
            } else {
                ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria,'1');
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Fixed Expense %'){
                    InputInterimData.Dimension1stResult= FIMasterData.FixedExpenseRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){
                    InputInterimData.Dimension1stResult= FIMasterData.InvestmentCR12;
                } else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI')){//else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI' || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI(Actual)'){
                    InputInterimData.Dimension1stResult= FIMasterData.ROIIntake;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='BC: BC%'){
                    InputInterimData.Dimension1stResult= FIMasterData.BCRate.SetSCale(0);
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Martell BC Rate'){
                    InputInterimData.Dimension1stResult=FIMasterData.TotalMBCRate.SetSCale(0);
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date'){
                    InputInterimData.Period1stResult= FIMasterData.POStartDate;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology'){
                    InputInterimData.Type1stName=FIMasterData.BRSFMethodologyName;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Methodology: PSF Methodology'){
                    InputInterimData.Type1stName=FIMasterData.PSFMethodologyName;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Methodology: PSF Volume Base'){
                    InputInterimData.Type1stName=FIMasterData.PSFVolumeBase;
                }
            }
        }     
        return InputInterimData;
    }
    
    
    public Decimal ByVolumeFinancialIndicator(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria,String Dimension){
        Decimal ReturnResult=0.0;
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd FIMasterData = FinancialIndicatorMasterData2nd(InputSegmentationCriteria,Dimension);
            if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Volume: Total'){
                ReturnResult = FIMasterData.Volumes;
            }else if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains(' - ')){
                List<String> parts = InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.split(' - ');
                String GroupingName = parts[1];
                if (InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Category')){
                    if(FIMasterData.CategoryMap.size()>0){
                        if(FIMasterData.CategoryMap.containskey(GroupingName) && FIMasterData.CategoryMap.get(GroupingName) !=null ){
                            ReturnResult=FIMasterData.CategoryMap.get(GroupingName);
                        }
                    }
                }else{ // By Grade
                    if(FIMasterData.SubBrandGradeGrouping.size()>0){
                        if(FIMasterData.SubBrandGradeGrouping.containskey(GroupingName) && FIMasterData.SubBrandGradeGrouping.get(GroupingName) !=null ){
                            ReturnResult=FIMasterData.SubBrandGradeGrouping.get(GroupingName);
                        }
                    }
                }
                
            }
        } else {
            ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputSegmentationCriteria,Dimension);
            if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Volume: Total'){
                ReturnResult = FIMasterData.Volumes;
            }else if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains(' - ')){
                List<String> parts = InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.split(' - ');
                String GroupingName = parts[1];
                if (InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Category')){
                    if(FIMasterData.CategoryMap.size()>0){
                        if(FIMasterData.CategoryMap.containskey(GroupingName) && FIMasterData.CategoryMap.get(GroupingName) !=null ){
                            ReturnResult=FIMasterData.CategoryMap.get(GroupingName);
                        }
                    }
                }else{ // By Grade
                    if(FIMasterData.SubBrandGradeGrouping.size()>0){
                        if(FIMasterData.SubBrandGradeGrouping.containskey(GroupingName) && FIMasterData.SubBrandGradeGrouping.get(GroupingName) !=null ){
                            ReturnResult=FIMasterData.SubBrandGradeGrouping.get(GroupingName);
                        }
                    }
                }
                
            }
        }
        ReturnResult=ReturnResult.SetSCale(0);
        return ReturnResult;
    }
    
    
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FinancialIndicatorMasterData(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria,String Dimension){
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator RetuenFI= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator();
        if(Dimension == '1'){
            if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='Historical V0.0'){
                RetuenFI = HistoricalV00Contract;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='Historical Vfinal'){
                RetuenFI =HistoricalVFinalContract;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contact V0.0 Contract'){
                RetuenFI = NewContactV0Contract;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contract V0.0 Est.'){
                RetuenFI= NewContractV0Esitimate;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contract V Final'){
                RetuenFI=NewContactVFinal;
            }
        }else{
            if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Historical V0.0'){
                RetuenFI = HistoricalV00Contract;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Historical Vfinal'){
                RetuenFI =HistoricalVFinalContract;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contact V0.0 Contract'){
                RetuenFI = NewContactV0Contract;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contract V0.0 Est.'){
                RetuenFI= NewContractV0Esitimate;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contract V Final'){
                RetuenFI=NewContactVFinal;
            }
        }
        
        return RetuenFI;
    }
    
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd FinancialIndicatorMasterData2nd(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria,String Dimension){
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd RetuenFI= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd();
        if(Dimension == '1'){
            if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='Historical V0.0'){
                RetuenFI = HistoricalV00Contract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='Historical Vfinal'){
                RetuenFI =HistoricalVFinalContract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contact V0.0 Contract'){
                RetuenFI = NewContactV0Contract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contract V0.0 Est.'){
                RetuenFI= NewContractV0Esitimate2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contract V Final'){
                RetuenFI=NewContactVFinal2nd;
            }
        }else{
            if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Historical V0.0'){
                RetuenFI = HistoricalV00Contract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Historical Vfinal'){
                RetuenFI =HistoricalVFinalContract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contact V0.0 Contract'){
                RetuenFI = NewContactV0Contract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contract V0.0 Est.'){
                RetuenFI= NewContractV0Esitimate2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contract V Final'){
                RetuenFI=NewContactVFinal2nd;
            }
        }

        return RetuenFI;
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
        if(ContractSelected.ASI_CRM_CN_Group_Contract__c ==null){
            //Contract generation checking 
            List<ASI_CRM_Contract_Printout_Setting__c> ContractSettingList = NEW List<ASI_CRM_Contract_Printout_Setting__c>();
            try{
                ContractSettingList= [select Id,ASI_CRM_Header_Section_Name__c,ASI_CRM_isVisible__c,ASI_CRM_Section_Content__c,ASI_CRM_Content_Section_Name__c 
                                      from ASI_CRM_Contract_Printout_Setting__c where ASI_CRM_Contract__c = :ContractSelected.Id];
            }catch(Exception e){ 
                String msgstr = 'ValidationChecking: ' +e.getMessage();
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyCheckPointResultPage  '+ msgstr+' with contract Id '+ContractSelected.id , 'ASI_CRM_CN_HeavyCheckPointResultCtrl','ASI_CRM_CN_HeavyCheckPointResultCtrl.ValidationChecking');
            }
            //If the editable terms in the Contract Generation Page have never been saved, System will show a error message and prevent sales from submitting for approval.
            if(ContractSettingList.size()==0 ){
                ProcessPermission = false;
                Msg+=' '+Label.ASI_CRM_CN_Contract_Generation_Page_No_Save; //The editable terms in the Contract Generation Page have never been saved
            }
        }
        
        
        
        //************Business License Checking ***********
        Decimal TotalAmountChecking=1000000;
        Decimal FixedAmountChecking=50000;
        ASI_CRM_CN_CustomSetting__c checking =[select id,ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c,ASI_CRM_Total_Amount_Checking__c from ASI_CRM_CN_CustomSetting__c ][0];
        
        if(checking.ASI_CRM_Total_Amount_Checking__c!=null){
            TotalAmountChecking =checking.ASI_CRM_Total_Amount_Checking__c;
        }
        
        if(checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c!=null){
            FixedAmountChecking =checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c;
        }
        
        //If a PO meets the criteria (Total PO contract amount >= 1M RMB OR Fixed cost total >= 50K RMB),System will show a warning message (but allow to save) 
        //if no business license is uploaded or the uploaded business license is invalid (i.e. the start date & end date of the uploaded business license do not cover the PO period).// WarningMsg   
        Boolean ShowWarning= false;
        if((FixedCostTotal+DetailAmount)>TotalAmountChecking  || FixedCostTotal >FixedAmountChecking){
            if(!ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c){
                ShowWarning=true;
                WarningMsg+=Label.ASI_CRM_CN_Business_License_not_uploaded+'<br/>';//Please note that Business License have not uploaded.
            }else{
                if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c !=null){
                    if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c< ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c){
                        ShowWarning=true;
                        WarningMsg+=Label.ASI_CRM_CN_Business_License_after_PO_start_Date_Error+'<br/>';//Please note that the Start Date of Business License is after the PO start Date.
                    }
                }
                if(!ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c){
                    if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c !=null){
                        if(ContractSelected.ASI_CRM_CN_PO_End_Date__c >ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c){
                            ShowWarning=true;
                            WarningMsg+=Label.ASI_CRM_CN_Business_License_before_PO_end_Date_Error+'<br/>';//Please note that the End Date of Business License is before the PO end Date.
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
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0)
            AdorAbove = true;
    }
    
    public void POModiValidationChecking(){
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable2nd(ContractSelected);
        } else {
            PaymentSummaryList= ASI_CRM_CN_HeavyContractUtilitiesClass.POModificationPaymentSummaryTable(ContractSelected);
        }
        
        Boolean validByACCode = true;
        for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary SummaryData:PaymentSummaryList){//POEstimatedAmount
            system.debug('SummaryData : '+SummaryData);
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
            
            IF(NeedPRVApproval){
                ContractSelected.ASI_CRM_RVP_Approval__c=TRUE; 
            }ELSE{
                ContractSelected.ASI_CRM_RVP_Approval__c=FALSE; 
            }
            UPDATE ContractSelected; 
            
            
            String  SuccessCheckPointString= System.JSON.serialize(SuccessCheckPointList);
            SuccessCheckPointString=SuccessCheckPointString.replaceAll('<','&lt;');
            SuccessCheckPointString=SuccessCheckPointString.replaceAll('>','&gt;');
            
            String  FailedCheckPointString= System.JSON.serialize(FailedCheckPointList);
            FailedCheckPointString=FailedCheckPointString.replaceAll('<','&lt;');
            FailedCheckPointString=FailedCheckPointString.replaceAll('>','&gt;');
            
            AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c 
                             where ASI_CRM_Contract__c = :ContractSelected.id and ASI_CRM_Type__c like 'CheckPoint%'];
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
                AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Contract__c=ContractSelected.id,ASI_CRM_Type__c='CheckPoint-Success',ASI_CRM_For_Contract_Use__c=true,
                                                         ASI_CRM_Historical_Financial_Data__c=SuccessCheckPointString));
                AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Contract__c=ContractSelected.id,ASI_CRM_Type__c='CheckPoint-Failed',ASI_CRM_For_Contract_Use__c=true,
                                                         ASI_CRM_Historical_Financial_Data__c=FailedCheckPointString));
            }
            upsert AttachmentList;
            

            
        }catch(Exception e){
            ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '+ 'Upsert ASI_CRM_CN_HeavyCheckPointResultPage Attachment  Error : ' +e.getMessage()+' with contract Id '+ContractSelected.id + ' with Json string : '+ System.JSON.serialize(FailedCheckPointList) , 'ASI_CRM_CN_HeavyCheckPointResultCtrl','ASI_CRM_CN_HeavyCheckPointResultCtrl.proceed');
        }
    }
    
    
    
    
    public pageReference proceed() {
        ProcessPermission = true;
        Msg='';
        WarningMsg='';
        
       
        if(ContractSelected.ASI_CRM_CN_Group_Contract__c!=null){
            if(ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__c!=null){
                if(ContractSelected.ASI_CRM_CN_Group_Contract__r.ASI_CRM_NationalGroup__r.ASI_CRM_Special_COA_Approval_Flow__c){
                    ContractSelected.ASI_CRM_RVP_Approval__c=TRUE; 
                }
            }
        }
        
        if(!ContractSelected.ASI_CRM_CN_PO_Modification__c){
            ValidationChecking();
        }else{
            POModiValidationChecking();
        }
        
        if(ProcessPermission && WarningTimes!=1 ){
            try{
                if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c != null){
                    if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c <getFiscalYearStart(system.today()).addYears(1)){ 
                        ContractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
                    }
                    else{
                        ContractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(ContractSelected.ASI_CRM_CN_PO_Start_Date__c);
                    }
                }else{
                    ContractSelected.ASI_CRM_CN_Effective_Date__c=getFiscalYearStart(System.today());
                }
                
                
                UPDATE ContractSelected; 
                
               
                PreSaveRecord();
                
            }catch(Exception e){ 
                String msgstr = 'Upsert ASI_CRM_CN_HeavyCheckPointResultPage Attachment  Error : ' +e.getMessage();
                ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '+ msgstr+' with contract Id '+ContractSelected.id + ' with Json string : '+ System.JSON.serialize(FailedCheckPointList) , 'ASI_CRM_CN_HeavyCheckPointResultCtrl','ASI_CRM_CN_HeavyCheckPointResultCtrl.proceed');
            }
                        
            //submit for approval 
            if(!Test.isRunningTest()){
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); req1.setObjectId(ContractSelected.id); Approval.ProcessResult result = Approval.process(req1);
            }
           
            
            return new pageReference('/' + ContractSelected.id);
            
        }else{
            return Null;
        }
        
        
    }
    
    
    
    public Date getFiscalYearStart(Date inputDate){        
        //Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Date fiscalYearStart;
        if(inputDate != null){            
            fiscalYearStart = Date.newinstance(inputDate.year(), orgFiscalMonth, 1);
            if(inputDate.month() < orgFiscalMonth && inputDate.year() == inputDate.year())
                fiscalYearStart = fiscalYearStart.addYears(-1);
        }
        System.debug(inputDate + '/' + fiscalYearStart);
        return fiscalYearStart;
    }

    // public static interimData RegionalAverageChecking(interimData InputInterimData,Map<String,Decimal> checkMap,ASI_CRM_Segmentation_Criteria_Item__c CurrentSci){
    //     interimData newInputInterimData = new interimData();
    //     newInputInterimData = InputInterimData.clone();
    //     String FinancialIndicator = newInputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c;

    //     if(FinancialIndicator == 'Regional Average Target'){
    //         Decimal Dimension2Value1 = GenerateDimension2Number1(newInputInterimData);
    //         Decimal Dimension2Value2= GenerateDimension2Number2(newInputInterimData);

    //         newInputInterimData.Dimension1stResult=checkMap.get(CurrentSci.ASI_CRM_CN_Subbrand__c).SetSCale(0);

    //         if(!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(newInputInterimData.SegmentationCriteria.ASI_CRM_Operation__c, 
    //                                                                            newInputInterimData.Dimension1stResult, 
    //                                                                            Dimension2Value1, 
    //                                                                            Dimension2Value2)){
    //             newInputInterimData.ReachTarget ='No';
    //         }

    //         // interimData(newInputInterimData);
    //         newInputInterimData.english_Interpretation = CurrentSci.ASI_CRM_CN_Subbrand__r.ASI_HK_CRM_English_Name__c +'-'+ newInputInterimData.SegmentationCriteria.ASI_CRM_English_Interpretation__c;
    //         newInputInterimData.chinese_Interpretation = CurrentSci.ASI_CRM_CN_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c+'-'+ newInputInterimData.SegmentationCriteria.ASI_CRM_Chinese_Interpretation__c;
    //         newInputInterimData.Display1stResultEN=newInputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c+'= '+newInputInterimData.Dimension1stResult.format();
    //         newInputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(newInputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+'= '+newInputInterimData.Dimension1stResult.format();
            
    //         if(newInputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c!=null ){
    //             newInputInterimData.Display2ndResultEN=newInputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c;
    //             newInputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(newInputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);
    //         }else{
    //             newInputInterimData.Display2ndResultEN='Theoretical Value';
    //             newInputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Theoretical Value');
    //         }
            
    //         if(newInputInterimData.SegmentationCriteria.ASI_CRM_Operation__c !='Within'){ 
    //             newInputInterimData.Display2ndResultEN+=' = '+newInputInterimData.Dimension2ndResult.SetSCale(0).format();
    //             newInputInterimData.Display2ndResult+=' = '+newInputInterimData.Dimension2ndResult.SetSCale(0).format();
    //         }else{// within display
    //             newInputInterimData.Display2ndResultEN+=' :<br/>  Min= '+Dimension2Value1+'<br/> Max='+Dimension2Value2;
    //             newInputInterimData.Display2ndResult+=' :<br/> 最小值=  '+Dimension2Value1 +'<br/> 最大值='+Dimension2Value2;
    //         } 
    //     }
    //     return newInputInterimData;
    // }

    public void VolumeChecking(interimData InputInterimData){

        if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c != 'Volume mix') {
            return;
        }

        List<interimData> intempList = new List<interimData>();
        for (ASI_CRM_Segmentation_Criteria_Item__c  sci : sciList) {
            interimData itd = new interimData();
            itd.chinese_Interpretation = sci.ASI_CRM_CN_Subbrand__r.Name;
            if(VolumeMixMap1.containsKey(sci.ASI_CRM_CN_Subbrand__c)){
                itd.volumeCheckResult1 = VolumeMixMap1.get(sci.ASI_CRM_CN_Subbrand__c) != null ? VolumeMixMap1.get(sci.ASI_CRM_CN_Subbrand__c):0;
            }
            if(VolumeMixMap2.containsKey(sci.ASI_CRM_CN_Subbrand__c)){
                itd.volumeCheckResult2 = VolumeMixMap2.get(sci.ASI_CRM_CN_Subbrand__c) != null ? VolumeMixMap2.get(sci.ASI_CRM_CN_Subbrand__c):0;
            }
            itd.volumeCheckResult3 = itd.volumeCheckResult1 - itd.volumeCheckResult2;
            intempList.add(itd);
        }
        VolumeCheckPortList.addAll(intempList);
    }
}