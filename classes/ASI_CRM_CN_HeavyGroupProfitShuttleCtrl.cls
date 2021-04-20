/* Filename  :  ASI_CRM_CN_HeavyGroupProfitShuttleCtrl.cls
* Author     :  Laputa
* Purpose    :  Controller for Group Contract PDF 
* Study From :  ASI_CRM_CN_HeavyGroupProfitShuttleCtrl
* Testing    :   
* History
"%v0.0 对比新合同V0.0"=(New contract Vfinal-New contract V0.0 Estimate)/(New contract V0.0 Estimate )

'"% vFinal对比历史完成'=(New contract V0.0 Estimate- Historical VFinal)/Historical VFinal
* -----------------------------------------------------------------------------
* 2017-10-15   Laputa                        Created
* 2020-04-04   pengchen@bluelinksys.com      Update2nd
*/

public with sharing class ASI_CRM_CN_HeavyGroupProfitShuttleCtrl {
    public String PageId {set;get;}
    public string strPDF {set;get;}{strPDF='1';}
    public string groupStr {set;get;}
    public String PoStartDateStr {set;get;}
    public String PoEndDateStr {set;get;}
    public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract2nd  {set;get;} { HistoricalV00Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalVFinalContract2nd  {set;get;} { HistoricalVFinalContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContractV0Esitimate2nd  {set;get;} { NewContractV0Esitimate2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactV0Contract2nd  {set;get;} { 
        NewContactV0Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    }
    public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactVFinal2nd  {set;get;} { 
        NewContactVFinal2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    }
    
    public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalContractCompared2nd  {set;get;} { 
        HistoricalContractCompared2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    }

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalV00Contract  {set;get;} { HistoricalV00Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalVFinalContract  {set;get;} { HistoricalVFinalContract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContractV0Esitimate  {set;get;} { NewContractV0Esitimate = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContactVFinal  {set;get;} { NewContactVFinal = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalContractCompared  {set;get;} { HistoricalContractCompared = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    //public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HVfinalComparedContract  {set;get;} { HVfinalComparedContract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public static Map<String, String> sbGroup_map {set;get;} {sbGroup_map = new Map<String, String>();}

    public static Map<String, ContractObject2nd> SummaryContractMap2nd {set;get;} {SummaryContractMap2nd = new Map<String, ContractObject2nd> (); } 

    public Map<String, ContractObject> SummaryContractMap {set;get;} {SummaryContractMap = new Map<String, ContractObject> (); } 
    
    public class ContractObject2nd {
        public ASI_TH_CRM_Contract__c CurrentContract {set;get;}{
            CurrentContract= new ASI_TH_CRM_Contract__c();
        } 
        public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ContractFI   {set;get;}{
            ContractFI= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd();
        }  
        public String ContractId {set;get;} {ContractId = '';}
        public ContractObject2nd(){  
        }
    }

    public class ContractObject {
        public ASI_TH_CRM_Contract__c CurrentContract {set;get;}{CurrentContract= new ASI_TH_CRM_Contract__c();} 
        public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ContractFI   {set;get;}{ContractFI= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator();}  
        public String ContractId {set;get;} { ContractId = ''; }
        public ContractObject(){  
        }
    }
    
    
    public Boolean ExistHistoricalData {set;get;} {ExistHistoricalData=false;}
    
    public Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine> SubBrandContractMap  {set;get;}  { SubBrandContractMap = new Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine> ();}
    
    
    public ASI_TH_CRM_Contract__c thisCC {set;get;}{thisCC=new ASI_TH_CRM_Contract__c();}
    public ASI_TH_CRM_Contract__c HistoricalContract {set;get;}{HistoricalContract=new ASI_TH_CRM_Contract__c();}
    public String ApprovalComment {set;get;} {ApprovalComment='';}
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = initPage();} return dummyVar; } set; }
    public boolean AdorAbove {set;get;}
    public boolean showCN {set;get;}
    
    public ASI_CRM_KA_Account__c KAAccount {set;get;}{KAAccount=new ASI_CRM_KA_Account__c();}
    Public Boolean ShowAchievementRecognition  {set;get;}  {ShowAchievementRecognition=false;} 
    
    public ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine PSFDetailTotal {set;get;} {PSFDetailTotal = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine VECDetailTotal {set;get;} {VECDetailTotal = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine AdjustmentRecognition  {set;get;} {AdjustmentRecognition = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();}
    
    public Decimal HistoricalPSFEstTotal {set;get;}  {HistoricalPSFEstTotal=0;}
    public Decimal HistoricalVECEstTotal {set;get;}  {HistoricalVECEstTotal=0;}
    
    public ASI_CRM_CN_HeavyGroupProfitShuttleCtrl(){}
    
    public Decimal HistoricalVFinalTotalBCRate {set;get;}  {HistoricalVFinalTotalBCRate=0;} 
    public Decimal HistoricalVFinalNetBCRate {set;get;}  {HistoricalVFinalNetBCRate=0;}
    
    
    public Decimal Hist_VFinalTotalMarBCRate {set;get;}  {Hist_VFinalTotalMarBCRate=0;}
    public Decimal Hist_VFinalNetMarBCRate {set;get;}  {Hist_VFinalNetMarBCRate=0;}
    
    
    public Decimal NewContractVFinalTotalBCRate {set;get;}  {NewContractVFinalTotalBCRate=0;} 
    public Decimal NewContractVFinalNetBCRate {set;get;}  {NewContractVFinalNetBCRate=0;} 
    
    
    public Decimal New_VFinalTotalMartellBCRate {set;get;}  {New_VFinalTotalMartellBCRate=0;} 
    public Decimal New_VFinalNetMartellBCRate {set;get;}  {New_VFinalNetMartellBCRate=0;} 
    
    
    
    //get Contract Approval Comments
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}{lstApprovalComment= new List<ASI_CRM_Approval_Comment__c> ();}
    
    public ASI_CRM_CN_HeavyGroupProfitShuttleCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
    }
    
    Public Integer HistoricalCoveredOutletSize {set;get;}{HistoricalCoveredOutletSize=0;}
    Public Integer V0CoveredOutletSize {set;get;}{V0CoveredOutletSize=0;}
    Public Integer VFinalCoveredOutletSize {set;get;}{VFinalCoveredOutletSize=0;}
    
    public Boolean IsLocalGroupContract {set;get;} {IsLocalGroupContract=false;}

    // public Map<String, String> sbGroup_ByCategoryMap {set;get;} {sbGroup_ByCategoryMap = ASI_CRM_CN_HeavyContractUtilitiesClass.SUB_BRAND_GRADE_GROUPING_MAP2ND;}
    
    public Map<String, String> sbGroup_ByCategoryVFMap {set;get;} {sbGroup_ByCategoryVFMap = new Map<String, String>{
        'Cognac干邑' => 'Cognac干邑',
        'Whisky威士忌' => 'Whisky威士忌',
        'White Spirits白色烈酒' => 'White Spirits白色烈酒',
        'Champagne香槟' => 'Champagne香槟',
        'Wine红酒' => 'Wine红酒'
    };}

    public Map<String, String> byCategoryMap{GET;SET;}
    public String MarginafterTableHeader{GET;SET;}
    
    public Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> investmentBySubBrandByContractBySubBrand {set;get;} {investmentBySubBrandByContractBySubBrand= new Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>{};}

    public static List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> HistoricalV0List =  new List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>();
    public static List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> HistoricalVFinalList =  new List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>();
    public static List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> EsitimateList =  new List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>();
    public static List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> NewContractVFinalList =  new List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>();
    public static List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> New_VFinalList =  new List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>();
    
    //History V0.0
    public  static Map<String, Decimal> HistoricalV0MonthBottleMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> HistoricalV0TotalFreeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> HistoricalV0TotalVolumeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> HistoricalV0TotalExpenseMap = new Map<String, Decimal>();

    //History
    public  static Map<String, Decimal> HistoricalVFinalMonthBottleMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> HistoricalVFinalTotalFreeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> HistoricalVFinalTotalVolumeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> HistoricalVFinalTotalExpenseMap = new Map<String, Decimal>();
    
    //NewContractV0Esitimate2nd   Esitimate
    public  static Map<String, Decimal>  EsitimateMonthBottleMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal>  EsitimateTotalFreeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal>  EsitimateTotalVolumeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal>  EsitimateTotalExpenseMap = new Map<String, Decimal>();

    //Contract
    public  static Map<String, Decimal> NewContractVFinalMonthBottleMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> NewContractVFinalTotalFreeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> NewContractVFinalTotalVolumeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> NewContractVFinalTotalExpenseMap = new Map<String, Decimal>();

    //v fina
    public  static Map<String, Decimal> New_VFinalMonthBottleMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> New_VFinalTotalFreeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> New_VFinalTotalVolumeMap =  new Map<String, Decimal>();
    public  static Map<String, Decimal> New_VFinalTotalExpenseMap = new Map<String, Decimal>();

    public Decimal HistoricalV0DomesticAfterSpendingTarget=0;
    public Decimal HistoricalVFinalDomesticAfterSpendingTarget=0;
    public Decimal EsitimateDomesticAfterSpendingTarget=0;
    public Decimal NewContractVFinalDomesticAfterSpendingTarget=0;
    public Decimal New_VFinalDomesticAfterSpendingTarget=0;
    public Set<String> existSubids = new Set<String>() ;

    public static Map<String, String> IndexTargetMap{GET;SET;}{IndexTargetMap = new Map<String,String>{};}
    public static Map<Decimal, String> subEnNameMap{GET;SET;}{subEnNameMap = new Map<Decimal,String>();}

    public boolean initPage() {
        if (String.isNotBlank(PageId)) {
            thisCC = [SELECT id, ASI_CRM_Martell_BC_Rate__c,ASI_CRM_SG_PRS_Contract_No__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_TH_CRM_Target_Distribution_Channel__c,Name,RecordType.DeveloperName,ownerId,ASI_CRM_Remarks__c,ASI_CRM_NationalGroup__c,ASI_CRM_NationalGroup__r.name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, ASI_CRM_CN_Vol_Budget_LE__c,ASI_CRM_CN_PO_Modification__c,ASI_CRM_CN_Contract_Est_Var_Cost_Total__c, ASI_CRM_CN_Contract_Estimate_Cost_Total__c,ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,  ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PO_No__c, ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c,ASI_CRM_CN_Contract_Variable_Cost_Total__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Outlet_WS__r.ASI_TH_CRM_OutletType__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,ASI_CRM_CN_Total_Contract_Amount__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c, ASI_CRM_CN_Description__c,  ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_V0_0_PO_version__c, Owner.Name,ASI_CRM_CN_Status__c , ASI_CRM_Volume_Option__c,ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,ASI_CRM_PO_Channel__r.Name, ASI_CRM_PO_Province__r.Name,ASI_CRM_PO_City__c,ASI_CRM_PO_City__r.Name ,ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c
                          FROM ASI_TH_CRM_Contract__c WHERE id = :PageId];
            if (thisCC.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                return init2nd();
                //return init();
            } else {
                return init();
            }
        }
        return true;
    }
    /**
    * @description 
    * @author pengchen@bluelinksys.com | 4/6/2020 
    * @return boolean 
    **/
    public boolean init2nd(){
        MarginafterTableHeader='<td bgcolor="#FFFF99" style="border-bottom: 1px solid black;border-left: 1px solid black; border-right: 1px solid black;"><strong>Cont. Margin after A &P 销售净利</strong></td>';
        HistoricalPSFEstTotal=0;
        HistoricalVECEstTotal=0;

        sbGroup_map = new Map<String, String>();
        sbGroup_map.put('1. Standard + Premium 标准档 + 高档', 'Standard + Premium 标准档 + 高档');
        sbGroup_map.put('2. Super Premium 超高档', 'Super Premium 超高档');
        sbGroup_map.put('3. Ultra Premium 特级高档', 'Ultra Premium 特级高档');
        sbGroup_map.put('4. Prestige + Ultra Prestige 奢华档 + 特级奢华档', 'Prestige + Ultra Prestige 奢华档 + 特级奢华档');

        HistoricalV00Contract2nd = InitData2nd( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd () ) ;
        HistoricalVFinalContract2nd =InitData2nd( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd () );
        NewContractV0Esitimate2nd = InitData2nd( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd () );
        NewContactV0Contract2nd = InitData2nd( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd () );
        NewContactVFinal2nd = InitData2nd( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd () );

        //PSFDetailTotal = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();
        //VECDetailTotal = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();
        //AdjustmentRecognition = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();

        byCategoryMap = new Map<String, String>();
        for(ASI_HK_CRM_Product_Category__c ProductCategory:[SELECT Id,Name,ASI_CRM_CN_Chinese_Name__c,ASI_HK_CRM_English_Name__c,ASI_HK_CRM_Sequence__c 
                                                            FROM ASI_HK_CRM_Product_Category__c 
                                                            WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Product_Category']){
            byCategoryMap.put(ProductCategory.name , ProductCategory.ASI_HK_CRM_English_Name__c + ProductCategory.ASI_CRM_CN_Chinese_Name__c);   
        }

        if (PageId != null){
            try{
                if(thisCC.RecordType.DeveloperName.contains('Local')){
                    IsLocalGroupContract=true;
                }
                KAAccount = [SELECT Id,
                                    RecordType.DeveloperName,ASI_CRM_VEC_Methodology__c,ASI_CRM_VEC_Unit__c,ASI_CRM_VEC_Volume_Base__c,ASI_CRM_BRSF_Methodology__c,ASI_CRM_BRSF_Unit__c,ASI_CRM_BRSF_Volume_Base__c,
                                    ASI_CRM_PSF_Meth_Mod1__c,
                                    ASI_CRM_PSF_Meth_Mod2__c,
                                    ASI_CRM_PSF_Meth_Mod3__c,
                                    ASI_CRM_PSF_Unit_Mod1__c,
                                    ASI_CRM_PSF_Unit_Mod2__c,ASI_CRM_PSF_Unit_Mod3__c,
                                    ASI_CRM_PSF_Volume_Base_Mod1__c,ASI_CRM_PSF_Volume_Base_Mod2__c,ASI_CRM_PSF_Volume_Base_Mod3__c,
                                    ASI_CRM_PSF_Meth_Mod1__r.Name,ASI_CRM_PSF_Meth_Mod2__r.Name,ASI_CRM_PSF_Meth_Mod3__r.Name,ASI_CRM_BRSF_Methodology__r.Name,ASI_CRM_VEC_Methodology__r.Name,
                                    ASI_CRM_PSF_Meth_Mod1__r.ASI_CRM_Chinese_Name__c,ASI_CRM_PSF_Meth_Mod2__r.ASI_CRM_Chinese_Name__c,ASI_CRM_PSF_Meth_Mod3__r.ASI_CRM_Chinese_Name__c,ASI_CRM_BRSF_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_VEC_Methodology__r.ASI_CRM_Chinese_Name__c
                             FROM ASI_CRM_KA_Account__c 
                             WHERE id=:thisCC.ASI_CRM_NationalGroup__c];
                System.debug(LoggingLevel.INFO, '*** thisCC: ' + thisCC);
                System.debug(LoggingLevel.INFO, '*** KAAccount: ' + KAAccount);
            }catch(exception e){
                
                system.debug(e.getMessage());
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyGroupProfitShuttleCtrl in init class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyGroupProfitShuttleCtrl','PDF function failed! with contract Id: '+PageId );
            }
            
            LoadingFIData2nd();
            
            DataConsolidation2nd();
            DataReconstruct2nd();

            // V0.2 Assemble EXPENSES (in RMB) without changing the original logic
            BuildDataFunction();
        }
        showCN = USerInfo.getLanguage()=='zh_CN';
        
        System.debug(LoggingLevel.INFO, '*** thisCC: ' + thisCC);
        
        if (strPDF == '0'){
            //checkApprover();
            set<Id> userIds = new set<Id>();
            for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE processinstance.status = 'Pending' AND processinstance.targetobjectid = : thisCC.id]){
                userIds.add(piw.ActorId);
            }
            groupStr = checkApprover2nd(userIds);
        }else{
            //checkUserID();
            set<Id> userIds = new set<Id>();
            userIds.add(UserInfo.getUserId());
            groupStr = checkApprover2nd(userIds);
        }
        return true;
    }

    public boolean init(){
        System.debug(LoggingLevel.INFO, '*** PageId: ' + PageId);
        HistoricalPSFEstTotal=0;
        HistoricalVECEstTotal=0;
        
        sbGroup_map = new Map<String, String>();
        sbGroup_map.put('1. Standard + Premium 标准档 + 高档', 'Standard + Premium 标准档 + 高档');
        sbGroup_map.put('2. Super Premium 超高档', 'Super Premium 超高档');
        sbGroup_map.put('3. Ultra Premium 特级高档', 'Ultra Premium 特级高档');
        sbGroup_map.put('4. Prestige + Ultra Prestige 奢华档 + 特级奢华档', 'Prestige + Ultra Prestige 奢华档 + 特级奢华档');
        
        
        HistoricalV00Contract = InitData( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator () ) ;
        HistoricalVFinalContract =InitData( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator () );
        NewContractV0Esitimate = InitData( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator () );
        NewContactV0Contract = InitData( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator () );
        NewContactVFinal = InitData( new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator () );
        
        
        
        
        
        
        
        
        PSFDetailTotal = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();
        VECDetailTotal = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();
        AdjustmentRecognition = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();
        
        if (PageId != null){
            try{
                if(thisCC.RecordType.DeveloperName.contains('Local')){
                    IsLocalGroupContract=true;
                }
                KAAccount = [select Id,RecordType.DeveloperName,ASI_CRM_VEC_Methodology__c,ASI_CRM_VEC_Unit__c,ASI_CRM_VEC_Volume_Base__c,ASI_CRM_BRSF_Methodology__c,ASI_CRM_BRSF_Unit__c,ASI_CRM_BRSF_Volume_Base__c,
                             ASI_CRM_PSF_Meth_Mod1__c,ASI_CRM_PSF_Meth_Mod2__c,ASI_CRM_PSF_Meth_Mod3__c,
                             ASI_CRM_PSF_Unit_Mod1__c,ASI_CRM_PSF_Unit_Mod2__c,ASI_CRM_PSF_Unit_Mod3__c,
                             ASI_CRM_PSF_Volume_Base_Mod1__c,ASI_CRM_PSF_Volume_Base_Mod2__c,ASI_CRM_PSF_Volume_Base_Mod3__c,
                             ASI_CRM_PSF_Meth_Mod1__r.Name,ASI_CRM_PSF_Meth_Mod2__r.Name,ASI_CRM_PSF_Meth_Mod3__r.Name,ASI_CRM_BRSF_Methodology__r.Name,ASI_CRM_VEC_Methodology__r.Name,
                             ASI_CRM_PSF_Meth_Mod1__r.ASI_CRM_Chinese_Name__c,ASI_CRM_PSF_Meth_Mod2__r.ASI_CRM_Chinese_Name__c,ASI_CRM_PSF_Meth_Mod3__r.ASI_CRM_Chinese_Name__c,ASI_CRM_BRSF_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_VEC_Methodology__r.ASI_CRM_Chinese_Name__c
                             from ASI_CRM_KA_Account__c where id=:thisCC.ASI_CRM_NationalGroup__c];
                System.debug(LoggingLevel.INFO, '*** KAAccount: ' + KAAccount);
            }catch(exception e){
                System.debug(LoggingLevel.INFO, '*** 1: ' + 1);
                system.debug(e.getMessage());
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyGroupProfitShuttleCtrl in init class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyGroupProfitShuttleCtrl','PDF function failed! with contract Id: '+PageId );
            }
            
            LoadingFIData();
            
            DataConsolidation();
            DataReconstruct();
            
        }
        showCN = USerInfo.getLanguage()=='zh_CN';
        
        
        if (strPDF == '0'){
            checkApprover();
        }else{
            checkUserID();
        }
        
        System.debug(LoggingLevel.INFO, '*** thisCC: ' + thisCC);
        
        return true;   
    }

    public String checkApprover2nd(Set<Id> userIds){
        String groupAName = 'ASI_CN_GS_Commercial_team';
        String groupBName = 'ASI_CN_Commercial_team_ex_GS';
        String groupCName = 'ASI_CN_Finance';
        String groupDName = 'ASI_CN_HQ_Management';

        String belongGroup = 'Group ';

        if (userIds != null && !userIds.isEmpty()) {
            Set<String> groupNames = new Set<String>();
            for (GroupMember gm: [SELECT group.name,
                                         group.DeveloperName
                                  FROM GroupMember
                                  WHERE UserOrGroupId IN: userIds]) {
                groupNames.add(gm.group.DeveloperName);
            }
            if (groupNames.contains(groupAName)) {
                belongGroup += 'A';
            }
            if (groupNames.contains(groupBName)) {
                belongGroup += 'B';
            }
            if (groupNames.contains(groupCName)) {
                belongGroup += 'C';
            }
            if (groupNames.contains(groupDName)) {
                belongGroup += 'D';
            }
        }
        
        return belongGroup;
    }

    public void LoadingFIData2nd(){
        SummaryContractMap2nd = new Map<String, ContractObject2nd> ();       
        Decimal TotalHC_BC=0;
        Decimal TotalHC_BackCap=0;
        Decimal TotalHC_IntakeBtl=0;
        
        Decimal Total_BC=0;
        Decimal Total_BackCap=0;
        Decimal Total_IntakeBtl=0;
        
        Decimal TotalHC_BC_Martell=0;
        Decimal TotalHC_BackCap_Martell=0;
        Decimal TotalHC_IntakeBtl_Martell=0;
        
        Decimal Total_BC_Martell=0;
        Decimal Total_BackCap_Martell=0;
        Decimal Total_IntakeBtl_Martell=0;
        
        
        
        //Historical Contract set
        Set<String> HistoricalContractset = new Set<String>();
        Set<String> Check_HistoricalContractset = new Set<String>();
        
        //New contract V0.0 Id Set
        Set<String> NewContractV00set = new Set<String>();
        Set<String> Check_NewContractV00set = new Set<String>();
        
        //New contract VFinal Id Set
        Set<String> NewContractVFinalset = new Set<String>();
        Set<String> Check_NewContractVFinalset = new Set<String>();
        
        
        //Historical Contract set
        Set<String> HistoricalContractOutletset = new Set<String>();
        //New contract V0.0 Id Set
        Set<String> NewContractV00Outletset = new Set<String>();
        //New contract VFinal Id Set
        Set<String> NewContractVFinalOutletset = new Set<String>();
        
        Set<String> AllContractIdSet = new Set<String>();
        
        map<integer, string> MonthMapping = new map<integer, string>();
        MonthMapping.put(1,'Jan');
        MonthMapping.put(2,'Feb');
        MonthMapping.put(3,'Mar');
        MonthMapping.put(4,'Apr');
        MonthMapping.put(5,'May');
        MonthMapping.put(6,'Jun');
        MonthMapping.put(7,'Jul');
        MonthMapping.put(8,'Aug');
        MonthMapping.put(9,'Sept');
        MonthMapping.put(10,'Oct');
        MonthMapping.put(11,'Nov');
        MonthMapping.put(12,'Dec');
        
        
        lstApprovalComment = [SELECT id,
                                     recordtypeid, 
                                     ASI_CRM_BA_comments__c, 
                                     ASI_CRM_Background_Objective__c, 
                                     ASI_CRM_New_contract_Analsysis__c,
                                      ASI_CRM_Historical_Contract_Performance__c 
                              FROM ASI_CRM_Approval_Comment__c 
                              WHERE ASI_CRM_Contract__c =:thisCC.id];
        
        
        if(lstApprovalComment==null || lstApprovalComment.size()==0){
            ApprovalComment ='';
            lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
        }
        else{
            lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
            for(ASI_CRM_Approval_Comment__c ac : lstApprovalComment){
                if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment')){
                    ApprovalComment = 'new';
                    lstApprovalComment[0] = ac;
                }
                else if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment')){
                    ApprovalComment = 'po';
                    lstApprovalComment[0] = ac;
                    break;
                }
                
            }
        }
        
        
        
        
        if(thisCC.ASI_CRM_CN_PO_Start_Date__c!= null){
            if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH())){
                thisCC.ASI_CRM_SG_PRS_Contract_No__c = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH());
                PoStartDateStr = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH());
            }
        }
        
        if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null){
            if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH())){
                thisCC.ASI_TH_CRM_Target_Distribution_Channel__c = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH());
                PoEndDateStr = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH());
            }
        }
        
        
        
        //Finding bacth job contract ID 
        List<ASI_Attachment__c> AttList = [SELECT id,
                                                  ownerId,
                                                  ASI_CRM_External_Key__c,
                                                  ASI_CRM_Last_Run_Time__c,
                                                  ASI_CRM_Historical_Financial_Data__c,
                                                  ASI_CRM_Historical_Financial_Data2__c,
                                                  ASI_CRM_Historical_Financial_Data3__c,
                                                  ASI_CRM_Historical_Financial_Data4__c,
                                                  ASI_CRM_New_Contract_v0_0__c,
                                                  ASI_CRM_New_Contract_vFinal__c,
                                                  ASI_CRM_Comments__c
                                           FROM ASI_Attachment__c 
                                           WHERE ASI_CRM_Contract__c =:thisCC.Id 
                                           AND (ownerId=:UserInfo.getUserId() 
                                                OR ownerId=:thisCC.ownerId) 
                                                AND ASI_CRM_Type__c='Group Contract'];

        if(AttList.size()>0){
            Boolean Found=false;
            ASI_Attachment__c TempRecord= new ASI_Attachment__c();
            for(ASI_Attachment__c att : AttList){
                if(att.ownerId == UserInfo.getUserId() || att.ownerId == thisCC.ownerId ){
                    TempRecord = att;
                    Found = true;
                }
                
                if(att.ownerId==UserInfo.getUserId()){
                    Break;
                }
                /*
                if(att.ownerId==UserInfo.getUserId() && !Found){
                    TempRecord=att;
                    
                }
                if(!Found && att.ownerId==thisCC.ownerId ){
                    TempRecord=att;
                    Found=true;
                }*/
            }

            //ASI_Attachment__c TempRecord= AttList[0];

            if(TempRecord.ASI_CRM_Historical_Financial_Data__c!=null && TempRecord.ASI_CRM_Historical_Financial_Data__c!=''){
                List<String> HistoricalContractIdList=TempRecord.ASI_CRM_Historical_Financial_Data__c.split(';');
                HistoricalContractset=ListToSet(HistoricalContractIdList);
                AllContractIdSet.addAll(HistoricalContractset);
            }

            if(TempRecord.ASI_CRM_New_Contract_v0_0__c!=null && TempRecord.ASI_CRM_New_Contract_v0_0__c!=''){
                List<String> NewContractV00IdList=TempRecord.ASI_CRM_New_Contract_v0_0__c.split(';');
                NewContractV00set=ListToSet(NewContractV00IdList);
                AllContractIdSet.addAll(NewContractV00set);
            }

            if(TempRecord.ASI_CRM_New_Contract_vFinal__c!=null && TempRecord.ASI_CRM_New_Contract_vFinal__c!=''){
                List<String> NewContractVFinalIdList=TempRecord.ASI_CRM_New_Contract_vFinal__c.split(';');
                NewContractVFinalset=ListToSet(NewContractVFinalIdList);
                AllContractIdSet.addAll(NewContractVFinalset);
            }
            //List<String> IdSet =str.split(';');

            //GROUP Contract
            if(TempRecord.ASI_CRM_Comments__c!=null && TempRecord.ASI_CRM_Comments__c!='' && TempRecord.ASI_CRM_Comments__c.contains(';')){
                List<String> ContractIdList=TempRecord.ASI_CRM_Comments__c.split(';');
                String HistoricalContractID='';
                if(ContractIdList.size()>1){
                    HistoricalContractID=ContractIdList[1];
                    ExistHistoricalData=true;
                }
                if(HistoricalContractID!=''){

                    HistoricalContract=[SELECT id,
                                               Name,
                                               ASI_CRM_Martell_BC_Rate__c,
                                               ASI_CRM_CN_No_of_Months__c,
                                               ASI_CRM_CN_Bottle_Collection_Rate__c,
                                               ASI_CRM_CN_PO_Start_Date__c,
                                               ASI_CRM_CN_PO_End_Date__c,
                                               ASI_CRM_Remarks__c,
                                               ASI_CRM_CN_Description__c,
                                               Owner.Name
                                        FROM ASI_TH_CRM_Contract__c 
                                        WHERE id = :HistoricalContractID];

                    if (HistoricalContract.ASI_CRM_CN_PO_Start_Date__c!= null){
                        if (MonthMapping.containskey((HistoricalContract.ASI_CRM_CN_PO_Start_Date__c).MONTH())){
                            HistoricalContract.ASI_CRM_Remarks__c = (HistoricalContract.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((HistoricalContract.ASI_CRM_CN_PO_Start_Date__c).MONTH());
                        }
                    }
                    
                    if (HistoricalContract.ASI_CRM_CN_PO_End_Date__c!= null){
                        if (MonthMapping.containskey((HistoricalContract.ASI_CRM_CN_PO_End_Date__c).MONTH())){
                            HistoricalContract.ASI_CRM_CN_Description__c = (HistoricalContract.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((HistoricalContract.ASI_CRM_CN_PO_End_Date__c).MONTH());
                        }
                    }
                }
            }

            //HistoricalContract
        }

        List<ASI_Attachment__c> AttachmentList= [SELECT id,
                                                        ASI_CRM_Historical_Financial_Data__c,
                                                        ASI_CRM_Historical_Financial_Data2__c,
                                                        ASI_CRM_Historical_Financial_Data3__c,
                                                        ASI_CRM_Historical_Financial_Data4__c,
                                                        ASI_CRM_Contract__c,
                                                        ASI_CRM_Type__c 
                                                 FROM ASI_Attachment__c 
                                                 WHERE ASI_CRM_Contract__c IN:AllContractIdSet
                                                 AND ASI_CRM_Contract__c!=null];

        Map<String, Decimal> hisTradeBottleMap =  new Map<String, Decimal>();

        for(ASI_Attachment__c att:AttachmentList){
            //Historical Contract V0.0 and Historical VFinal 
            if(HistoricalContractset.contains(att.ASI_CRM_Contract__c) && !Check_HistoricalContractset.contains(att.ASI_CRM_Contract__c)){

                if(att.ASI_CRM_Type__c=='Current V0VFinal Data'){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');
                    System.debug(LoggingLevel.INFO, '*** : Current V0VFinal Data' + att.Id);
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);

                    if(HistoricalContractList.size()>0){
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Temp= HistoricalContractList[0];
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalVFinalTemp= HistoricalContractList[1];

                        if(HistoricalVFinalTemp.AddOnString!=''){
                            Check_HistoricalContractset.add(att.ASI_CRM_Contract__c);
                            Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(HistoricalVFinalTemp.AddOnString,Map<String,Decimal>.class);
                            if( TempMap.containsKey('PSFEstTotal')  ){//HistoricalPSFEstTotal += TempMap.get('PSFEstTotal');
                                PSFDetailTotal.HistoricalTotalFees+= TempMap.get('PSFEstTotal');
                            }
                            if( TempMap.containsKey('VECEstTotal')  ){//HistoricalVECEstTotal+= TempMap.get('VECEstTotal');
                                VECDetailTotal.HistoricalTotalFees+= TempMap.get('VECEstTotal');
                            }
                            
                            if( TempMap.containsKey('TotalBC_prorate')  ){//TotalHC_BC
                                TotalHC_BC+= TempMap.get('TotalBC_prorate');
                            }
                            if( TempMap.containsKey('TotalBlackCap_prorate')  ){//TotalBackCap
                                TotalHC_BackCap+= TempMap.get('TotalBlackCap_prorate');
                            }
                            if( TempMap.containsKey('Total_IntakeBtl_prorate')  ){//TotalHC_IntakeBtl
                                TotalHC_IntakeBtl+= TempMap.get('Total_IntakeBtl_prorate');
                            }
                            
                            if( TempMap.containsKey('Total_MartellBC')  ){//Total_MartellBC
                                TotalHC_BC_Martell+= TempMap.get('Total_MartellBC');
                            }
                            if( TempMap.containsKey('Total_MartellIntakeBtl')  ){//Total_MartellIntakeBtl
                                TotalHC_IntakeBtl_Martell+= TempMap.get('Total_MartellIntakeBtl');
                            }
                            if( TempMap.containsKey('Total_MartellBlackCap')  ){//Total_MartellBlackCap
                                TotalHC_BackCap_Martell += TempMap.get('Total_MartellBlackCap');
                            } 
                        }        
                        HistoricalV00Contract2nd= FIConsolidation2nd(HistoricalV00Contract2nd,HistoricalV00Temp);
                        HistoricalVFinalContract2nd= FIConsolidation2nd(HistoricalVFinalContract2nd,HistoricalVFinalTemp);

                        HistoricalV0List.addAll(HistoricalV00Contract2nd.TradeExpenseBySubBrand);
                        HistoricalVFinalList.addAll(HistoricalVFinalContract2nd.TradeExpenseBySubBrand);
                        //History
                        if(!HistoricalV00Contract2nd.TradeExpenseBySubBrand.isEmpty()){
                            for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd breakdown : HistoricalV00Contract2nd.TradeExpenseBySubBrand){

                                if(HistoricalVFinalTotalFreeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpensePerBottle = HistoricalV0TotalFreeMap.get(breakdown.subBrandId) + breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd;
                                    HistoricalV0TotalFreeMap.put(breakdown.subBrandId, tradeExpensePerBottle);
                                }else{
                                    HistoricalV0TotalFreeMap.put(breakdown.subBrandId, breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd);
                                }

                                if(HistoricalV0TotalExpenseMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpense = HistoricalV0TotalExpenseMap.get(breakdown.subBrandId) + breakdown.totalTradeExpense;
                                    HistoricalV0TotalExpenseMap.put(breakdown.subBrandId, tradeExpense);
                                }else{
                                    HistoricalV0TotalExpenseMap.put(breakdown.subBrandId, breakdown.totalTradeExpense);
                                }
                    

                                if(HistoricalV0TotalVolumeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseVoluem = HistoricalV0TotalVolumeMap.get(breakdown.subBrandId) + breakdown.volumeSTD;
                                    HistoricalV0TotalVolumeMap.put(breakdown.subBrandId, tradeExpenseVoluem);
                                }else{
                                    HistoricalV0TotalVolumeMap.put(breakdown.subBrandId, breakdown.volumeSTD);
                                }

                                if(HistoricalV0MonthBottleMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseMonthVolume = HistoricalV0MonthBottleMap.get(breakdown.subBrandId) + breakdown.monthlyVolumeSTD;
                                    HistoricalV0MonthBottleMap.put(breakdown.subBrandId, tradeExpenseMonthVolume);
                                }else{
                                    HistoricalV0MonthBottleMap.put(breakdown.subBrandId, breakdown.monthlyVolumeSTD);
                                }

                                HistoricalV0DomesticAfterSpendingTarget += breakdown.volumeSTD * breakdown.DomesticCMAfterSpending * breakdown.factor9L/9 ;
                                existSubids.add(breakdown.subBrandId);
                            }
                        }
                        if(!HistoricalVFinalContract2nd.TradeExpenseBySubBrand.isEmpty()){
                            for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd breakdown : HistoricalVFinalContract2nd.TradeExpenseBySubBrand){

                                if(HistoricalVFinalTotalFreeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpensePerBottle = HistoricalVFinalTotalFreeMap.get(breakdown.subBrandId) + breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd;
                                    HistoricalVFinalTotalFreeMap.put(breakdown.subBrandId, tradeExpensePerBottle);
                                }else{
                                    HistoricalVFinalTotalFreeMap.put(breakdown.subBrandId, breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd);
                                }

                                if(HistoricalVFinalTotalExpenseMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpense = HistoricalVFinalTotalExpenseMap.get(breakdown.subBrandId) + breakdown.totalTradeExpense;
                                    HistoricalVFinalTotalExpenseMap.put(breakdown.subBrandId, tradeExpense);
                                }else{
                                    HistoricalVFinalTotalExpenseMap.put(breakdown.subBrandId, breakdown.totalTradeExpense);
                                }

                                if(HistoricalVFinalTotalVolumeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseVoluem = HistoricalVFinalTotalVolumeMap.get(breakdown.subBrandId) + breakdown.volumeSTD;
                                    HistoricalVFinalTotalVolumeMap.put(breakdown.subBrandId, tradeExpenseVoluem);
                                }else{
                                    HistoricalVFinalTotalVolumeMap.put(breakdown.subBrandId, breakdown.volumeSTD);
                                }

                                if(HistoricalVFinalMonthBottleMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseMonthVolume = HistoricalVFinalMonthBottleMap.get(breakdown.subBrandId) + breakdown.monthlyVolumeSTD;
                                    HistoricalVFinalMonthBottleMap.put(breakdown.subBrandId, tradeExpenseMonthVolume);
                                }else{
                                    HistoricalVFinalMonthBottleMap.put(breakdown.subBrandId, breakdown.monthlyVolumeSTD);
                                }

                                HistoricalVFinalDomesticAfterSpendingTarget += breakdown.volumeSTD * breakdown.DomesticCMAfterSpending * breakdown.factor9L/9 ;
                                existSubids.add(breakdown.subBrandId);
                            }
                        }
                    }
                }
            }
            
            // new contract V0.0 and new Contract VFinal Data
            if(NewContractV00set.contains(att.ASI_CRM_Contract__c) && !Check_NewContractV00set.contains(att.ASI_CRM_Contract__c) ){ 
                if(att.ASI_CRM_Type__c=='Contract Data'){
                    System.debug(LoggingLevel.INFO, '*** : Contract Data' + att.Id);
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&lt;','<'):'');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                    if(ContractList.size()>0){
                        Check_NewContractV00set.add(att.ASI_CRM_Contract__c);
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContractV0EsitimateTemp= ContractList[0];
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactV0ContractTemp= ContractList[1];
                        
                        NewContactV0Contract2nd= FIConsolidation2nd(NewContactV0Contract2nd,NewContactV0ContractTemp);
                        NewContractV0Esitimate2nd= FIConsolidation2nd(NewContractV0Esitimate2nd,NewContractV0EsitimateTemp);
                        
                        
                        ContractObject2nd TempContract = new ContractObject2nd ();
                        TempContract.ContractFI= ContractList[0];
                        IF(ContractList[0].ContractId!='' ){
                            TempContract.ContractId= ContractList[0].ContractId;
                        }
                        SummaryContractMap2nd.put(ContractList[0].ContractId,TempContract);

                        if (NewContractV0Esitimate2nd != null && NewContractV0Esitimate2nd.TradeExpenseBySubBrand != null && EsitimateList != null) {
                            EsitimateList.addAll(NewContractV0Esitimate2nd.TradeExpenseBySubBrand);
                        }
                        if (NewContactV0Contract2nd != null && NewContactV0Contract2nd.TradeExpenseBySubBrand != null && NewContractVFinalList != null) {
                            NewContractVFinalList.addAll(NewContactV0Contract2nd.TradeExpenseBySubBrand);
                        }
                        
                        
                        //NewContractV0Esitimate2nd   Esitimate
                        if(NewContractV0Esitimate2nd.TradeExpenseBySubBrand != null && !NewContractV0Esitimate2nd.TradeExpenseBySubBrand.isEmpty()){
                            for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd breakdown : NewContractV0Esitimate2nd.TradeExpenseBySubBrand){
                                if(EsitimateTotalFreeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpensePerBottle = EsitimateTotalFreeMap.get(breakdown.subBrandId) + breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd;
                                    EsitimateTotalFreeMap.put(breakdown.subBrandId, tradeExpensePerBottle);
                                }else{
                                    EsitimateTotalFreeMap.put(breakdown.subBrandId, breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd);
                                }

                                if(EsitimateTotalExpenseMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpense = EsitimateTotalExpenseMap.get(breakdown.subBrandId) + breakdown.totalTradeExpense;
                                    EsitimateTotalExpenseMap.put(breakdown.subBrandId, tradeExpense);
                                }else{
                                    EsitimateTotalExpenseMap.put(breakdown.subBrandId, breakdown.totalTradeExpense);
                                }

                                if(EsitimateTotalVolumeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseVoluem = EsitimateTotalVolumeMap.get(breakdown.subBrandId) + breakdown.volumeSTD;
                                    EsitimateTotalVolumeMap.put(breakdown.subBrandId, tradeExpenseVoluem);
                                }else{
                                    EsitimateTotalVolumeMap.put(breakdown.subBrandId, breakdown.volumeSTD);
                                }

                                if(EsitimateMonthBottleMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseMonthVolume = EsitimateMonthBottleMap.get(breakdown.subBrandId) + breakdown.monthlyVolumeSTD;
                                    EsitimateMonthBottleMap.put(breakdown.subBrandId, tradeExpenseMonthVolume);
                                }else{
                                    EsitimateMonthBottleMap.put(breakdown.subBrandId, breakdown.monthlyVolumeSTD);
                                }
                                System.debug(LoggingLevel.INFO, '*** breakdown: ' + breakdown);
                                EsitimateDomesticAfterSpendingTarget += breakdown.volumeSTD * breakdown.DomesticCMAfterSpending * breakdown.factor9L/9 ;
                                existSubids.add(breakdown.subBrandId);
                            }
                        }

                        //Contract
                        if(NewContactV0Contract2nd.TradeExpenseBySubBrand != null && !NewContactV0Contract2nd.TradeExpenseBySubBrand.isEmpty()){
                            for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd breakdown : NewContactV0Contract2nd.TradeExpenseBySubBrand){
                                if(NewContractVFinalTotalFreeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpensePerBottle = NewContractVFinalTotalFreeMap.get(breakdown.subBrandId) + breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd;
                                    NewContractVFinalTotalFreeMap.put(breakdown.subBrandId, tradeExpensePerBottle);
                                }else{
                                    NewContractVFinalTotalFreeMap.put(breakdown.subBrandId, breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd);
                                }

                                if(NewContractVFinalTotalExpenseMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpense = NewContractVFinalTotalExpenseMap.get(breakdown.subBrandId) + breakdown.totalTradeExpense;
                                    NewContractVFinalTotalExpenseMap.put(breakdown.subBrandId, tradeExpense);
                                }else{
                                    NewContractVFinalTotalExpenseMap.put(breakdown.subBrandId, breakdown.totalTradeExpense);
                                }

                                if(NewContractVFinalTotalVolumeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseVoluem = NewContractVFinalTotalVolumeMap.get(breakdown.subBrandId) + breakdown.volumeSTD;
                                    NewContractVFinalTotalVolumeMap.put(breakdown.subBrandId, tradeExpenseVoluem);
                                }else{
                                    NewContractVFinalTotalVolumeMap.put(breakdown.subBrandId, breakdown.volumeSTD);
                                }

                                if(NewContractVFinalMonthBottleMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseMonthVolume = NewContractVFinalMonthBottleMap.get(breakdown.subBrandId) + breakdown.monthlyVolumeSTD;
                                    NewContractVFinalMonthBottleMap.put(breakdown.subBrandId, tradeExpenseMonthVolume);
                                }else{
                                    NewContractVFinalMonthBottleMap.put(breakdown.subBrandId, breakdown.monthlyVolumeSTD);
                                }
                                NewContractVFinalDomesticAfterSpendingTarget += breakdown.volumeSTD * breakdown.DomesticCMAfterSpending * breakdown.factor9L/9 ;
                                existSubids.add(breakdown.subBrandId);
                            }
                        }
                    } 
                }
            }

            if(NewContractVFinalset.contains(att.ASI_CRM_Contract__c) && !Check_NewContractVFinalset.contains(att.ASI_CRM_Contract__c)){// new contract VFinal 
                if(att.ASI_CRM_Type__c=='PO Modification Data'){

                    //new contract Vfinal
                    System.debug(LoggingLevel.INFO, '*** : PO Modification Data' + att.Id);
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class); 
                    if(ContractList.size()>0){
                        Check_NewContractVFinalset.add(att.ASI_CRM_Contract__c);
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd CurrentContractVFinal= ContractList[0];
                        NewContactVFinal2nd= FIConsolidation2nd(NewContactVFinal2nd,CurrentContractVFinal);

                        if(CurrentContractVFinal.AddOnString!=''){
                            Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(CurrentContractVFinal.AddOnString,Map<String,Decimal>.class);
                            if( TempMap.containsKey('TotalBC_prorate')  ){//TotalBC
                                Total_BC+= TempMap.get('TotalBC_prorate');
                            }
                            if( TempMap.containsKey('TotalBlackCap_prorate')  ){//TotalBackCap
                                Total_BackCap+= TempMap.get('TotalBlackCap_prorate');
                            }
                            if( TempMap.containsKey('Total_IntakeBtl_prorate')  ){//Total_IntakeBtl
                                Total_IntakeBtl+= TempMap.get('Total_IntakeBtl_prorate');
                            }
                            
                            if( TempMap.containsKey('Total_MartellBC')  ){//Total Martell BC
                                Total_BC_Martell+= TempMap.get('Total_MartellBC');
                            }
                            if( TempMap.containsKey('Total_MartellIntakeBtl')  ){//Total Martell BackCap
                                Total_IntakeBtl_Martell+= TempMap.get('Total_MartellIntakeBtl');
                            }
                            if( TempMap.containsKey('Total_MartellBlackCap')  ){//Total Martell Intake Btl
                                Total_BackCap_Martell+= TempMap.get('Total_MartellBlackCap');
                            }
                        }

                        New_VFinalList.addAll(NewContactVFinal2nd.TradeExpenseBySubBrand);
                        //v fina
                        if(!NewContactVFinal2nd.TradeExpenseBySubBrand.isEmpty()){
                            for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd breakdown : NewContactVFinal2nd.TradeExpenseBySubBrand){
                                if(New_VFinalTotalFreeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpensePerBottle = New_VFinalTotalFreeMap.get(breakdown.subBrandId) + breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd;
                                    New_VFinalTotalFreeMap.put(breakdown.subBrandId, tradeExpensePerBottle);
                                }else{
                                    New_VFinalTotalFreeMap.put(breakdown.subBrandId, breakdown.volumeSTD * breakdown.tradeExpensePerBottle2nd);
                                }

                                if(New_VFinalTotalExpenseMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpense = New_VFinalTotalExpenseMap.get(breakdown.subBrandId) + breakdown.totalTradeExpense;
                                    New_VFinalTotalExpenseMap.put(breakdown.subBrandId, tradeExpense);
                                }else{
                                    New_VFinalTotalExpenseMap.put(breakdown.subBrandId, breakdown.totalTradeExpense);
                                }

                                if(New_VFinalTotalVolumeMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseVoluem = New_VFinalTotalVolumeMap.get(breakdown.subBrandId) + breakdown.volumeSTD;
                                    New_VFinalTotalVolumeMap.put(breakdown.subBrandId, tradeExpenseVoluem);
                                }else{
                                    New_VFinalTotalVolumeMap.put(breakdown.subBrandId, breakdown.volumeSTD);
                                }

                                if(New_VFinalMonthBottleMap.containsKey(breakdown.subBrandId)){
                                    Decimal tradeExpenseMonthVolume = New_VFinalMonthBottleMap.get(breakdown.subBrandId) + breakdown.monthlyVolumeSTD;
                                    New_VFinalMonthBottleMap.put(breakdown.subBrandId, tradeExpenseMonthVolume);
                                }else{
                                    New_VFinalMonthBottleMap.put(breakdown.subBrandId, breakdown.monthlyVolumeSTD);
                                }
                                if (breakdown.volumeSTD != null && breakdown.DomesticCMAfterSpending != null && breakdown.factor9L != null) {
                                    New_VFinalDomesticAfterSpendingTarget += breakdown.volumeSTD * breakdown.DomesticCMAfterSpending * breakdown.factor9L/9 ;
                                }
                                // New_VFinalDomesticAfterSpendingTarget += breakdown.volumeSTD * breakdown.DomesticCMAfterSpending * breakdown.factor9L/9 ;
                                existSubids.add(breakdown.subBrandId);
                            }
                        }
                    }
                }
            }
        }
        
        // The data is filtered for empty sales 
        DataScreen();

        //Calculate Historical and new contract vFinal Total BC Rate and Net BC Rate
        if(TotalHC_IntakeBtl!=0){
            HistoricalVFinalTotalBCRate=(TotalHC_BC/TotalHC_IntakeBtl)*100;
            HistoricalVFinalNetBCRate=((TotalHC_BC-TotalHC_BackCap)/TotalHC_IntakeBtl)*100;
        }
        
        
        if(Total_IntakeBtl!=0){
            NewContractVFinalTotalBCRate=(Total_BC/Total_IntakeBtl)*100;
            NewContractVFinalNetBCRate=((Total_BC-Total_BackCap)/Total_IntakeBtl)*100;
        }
        
        
        if(TotalHC_IntakeBtl!=0 && TotalHC_IntakeBtl_Martell!=0){
            Hist_VFinalTotalMarBCRate=(TotalHC_BC_Martell/TotalHC_IntakeBtl_Martell)*100;
            Hist_VFinalNetMarBCRate=((TotalHC_BC_Martell-TotalHC_BackCap_Martell)/TotalHC_IntakeBtl_Martell)*100;
        }
        
        
        if(Total_IntakeBtl!=0 && Total_IntakeBtl_Martell!=0){
            New_VFinalTotalMartellBCRate=(Total_BC_Martell/Total_IntakeBtl_Martell)*100;
            New_VFinalNetMartellBCRate=((Total_BC_Martell-Total_BackCap_Martell)/Total_IntakeBtl_Martell)*100;
        }
        
        
        
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:[SELECT Id, ASI_CRM_Max_Incentive__c,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c, ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,  ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                WHERE ASI_CRM_CN_Contract__c!=null and (ASI_CRM_CN_Contract__c in :NewContractV00set or ASI_CRM_CN_Contract__c in :NewContractVFinalset) ] )
        {
            IF(ContractLine.ASI_CRM_Type__c=='PSF'){
                if(NewContractV00set.contains(ContractLine.ASI_CRM_CN_Contract__c)){
                    PSFDetailTotal.ContractTotalFees +=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    PSFDetailTotal.EstimateTotalFees+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }
                if(NewContractVFinalset.contains(ContractLine.ASI_CRM_CN_Contract__c)){
                    PSFDetailTotal.VFinalTotalFees +=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                } 
            }
            
            if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                if(NewContractV00set.contains(ContractLine.ASI_CRM_CN_Contract__c)){
                    VECDetailTotal.ContractTotalFees +=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    VECDetailTotal.EstimateTotalFees+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }
                
                if(NewContractVFinalset.contains(ContractLine.ASI_CRM_CN_Contract__c)){
                    VECDetailTotal.VFinalTotalFees +=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                }
                
            }
        }

        //Looping the Real contract
        for(ASI_TH_CRM_Contract__c RealContract:[select Id,Name,ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Outlet_WS__r.Name,ASI_CRM_CN_PO_No__c from ASI_TH_CRM_Contract__c where id in:AllContractIdSet and ASI_CRM_CN_Outlet_WS__c!=null]){
            if(SummaryContractMap2nd.containsKey(RealContract.Id)){
                SummaryContractMap2nd.get(RealContract.Id).CurrentContract = RealContract ;
            }
            if(HistoricalContractset.contains(RealContract.Id)){
                HistoricalContractOutletset.add(RealContract.ASI_CRM_CN_Outlet_WS__c);
            }
            if(NewContractV00set.contains(RealContract.Id)){
                NewContractV00Outletset.add(RealContract.ASI_CRM_CN_Outlet_WS__c);
            }
            if(NewContractVFinalset.contains(RealContract.Id)){
                NewContractVFinalOutletset.add(RealContract.ASI_CRM_CN_Outlet_WS__c);
            }
        }
        
        
        for(ASI_CRM_CN_Covered_Outlet__c CoveredOutlet:[SELECT id, ASI_CRM_CN_Contract__c,ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c   WHERE ASI_CRM_CN_Contract__c in:AllContractIdSet and ASI_CRM_CN_Outlet__c!=null ]){
            if(HistoricalContractset.contains(CoveredOutlet.ASI_CRM_CN_Contract__c)){
                HistoricalContractOutletset.add(CoveredOutlet.ASI_CRM_CN_Outlet__c);
            }
            if(NewContractV00set.contains(CoveredOutlet.ASI_CRM_CN_Contract__c)){
                NewContractV00Outletset.add(CoveredOutlet.ASI_CRM_CN_Outlet__c);
            }
            if(NewContractVFinalset.contains(CoveredOutlet.ASI_CRM_CN_Contract__c)){
                NewContractVFinalOutletset.add(CoveredOutlet.ASI_CRM_CN_Outlet__c);
            }
        }
        
        HistoricalCoveredOutletSize=HistoricalContractOutletset.size();
        V0CoveredOutletSize=NewContractV00Outletset.size();
        VFinalCoveredOutletSize=NewContractVFinalOutletset.size();
    }

    public void LoadingFIData(){
        
        
        
        SummaryContractMap = new Map<String, ContractObject> ();       
        Decimal TotalHC_BC=0;
        Decimal TotalHC_BackCap=0;
        Decimal TotalHC_IntakeBtl=0;
        
        Decimal Total_BC=0;
        Decimal Total_BackCap=0;
        Decimal Total_IntakeBtl=0;
        
        Decimal TotalHC_BC_Martell=0;
        Decimal TotalHC_BackCap_Martell=0;
        Decimal TotalHC_IntakeBtl_Martell=0;
        
        Decimal Total_BC_Martell=0;
        Decimal Total_BackCap_Martell=0;
        Decimal Total_IntakeBtl_Martell=0;
        
        
        
        //Historical Contract set
        Set<String> HistoricalContractset = new Set<String>();
        Set<String> Check_HistoricalContractset = new Set<String>();
        
        //New contract V0.0 Id Set
        Set<String> NewContractV00set = new Set<String>();
        Set<String> Check_NewContractV00set = new Set<String>();
        
        //New contract VFinal Id Set
        Set<String> NewContractVFinalset = new Set<String>();
        Set<String> Check_NewContractVFinalset = new Set<String>();
        
        
        //Historical Contract set
        Set<String> HistoricalContractOutletset = new Set<String>();
        //New contract V0.0 Id Set
        Set<String> NewContractV00Outletset = new Set<String>();
        //New contract VFinal Id Set
        Set<String> NewContractVFinalOutletset = new Set<String>();
        
        Set<String> AllContractIdSet = new Set<String>();
        
        map<integer, string> MonthMapping = new map<integer, string>();
        MonthMapping.put(1,'Jan');
        MonthMapping.put(2,'Feb');
        MonthMapping.put(3,'Mar');
        MonthMapping.put(4,'Apr');
        MonthMapping.put(5,'May');
        MonthMapping.put(6,'Jun');
        MonthMapping.put(7,'Jul');
        MonthMapping.put(8,'Aug');
        MonthMapping.put(9,'Sept');
        MonthMapping.put(10,'Oct');
        MonthMapping.put(11,'Nov');
        MonthMapping.put(12,'Dec');
        
        
        lstApprovalComment = [SELECT id, recordtypeid, ASI_CRM_BA_comments__c, ASI_CRM_Background_Objective__c, ASI_CRM_New_contract_Analsysis__c, ASI_CRM_Historical_Contract_Performance__c FROM ASI_CRM_Approval_Comment__c 
                              WHERE ASI_CRM_Contract__c =:thisCC.id];  
        
        
        if(lstApprovalComment==null || lstApprovalComment.size()==0){
            ApprovalComment ='';
            lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
        }
        else{
            lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
            for(ASI_CRM_Approval_Comment__c ac : lstApprovalComment){
                if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment')){
                    ApprovalComment = 'new';
                    lstApprovalComment[0] = ac;
                }
                else if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment')){
                    ApprovalComment = 'po';
                    lstApprovalComment[0] = ac;
                    break;
                }
                
            }
        }
        
        
        
        
        if(thisCC.ASI_CRM_CN_PO_Start_Date__c!= null){
            if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH())){
                thisCC.ASI_CRM_SG_PRS_Contract_No__c = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH());
                PoStartDateStr = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH());
            }
        }
        
        if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null){
            if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH())){
                thisCC.ASI_TH_CRM_Target_Distribution_Channel__c = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH());
                PoEndDateStr = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH());
            }
        }
        
        
        
        //Finding bacth job contract ID 
        List<ASI_Attachment__c> AttList = [select id,ownerId,ASI_CRM_External_Key__c,ASI_CRM_Last_Run_Time__c,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_New_Contract_v0_0__c,ASI_CRM_New_Contract_vFinal__c,ASI_CRM_Comments__c  
                                           from ASI_Attachment__c where ASI_CRM_Contract__c =:thisCC.Id 
                                           and (ownerId=:UserInfo.getUserId() or ownerId=:thisCC.ownerId) and ASI_CRM_Type__c='Group Contract'];
        if(AttList.size()>0){
            Boolean Found=false;
            ASI_Attachment__c TempRecord= new ASI_Attachment__c();
            for(ASI_Attachment__c att:AttList){
                if(att.ownerId==UserInfo.getUserId() ||att.ownerId==thisCC.ownerId ){
                    TempRecord=att;
                    Found=true;
                    
                }
                
                IF(att.ownerId==UserInfo.getUserId()){
                    Break;
                }
                /*
                if(att.ownerId==UserInfo.getUserId() && !Found){
                    TempRecord=att;
                    
                }
                if(!Found && att.ownerId==thisCC.ownerId ){
                    TempRecord=att;
                    Found=true;
                }*/
            }
            
            
            //ASI_Attachment__c TempRecord= AttList[0];
            
            if(TempRecord.ASI_CRM_Historical_Financial_Data__c!=null && TempRecord.ASI_CRM_Historical_Financial_Data__c!=''){
                
                system.debug('Historical Financial_Data : '+TempRecord.ASI_CRM_Historical_Financial_Data__c);
                List<String> HistoricalContractIdList=TempRecord.ASI_CRM_Historical_Financial_Data__c.split(';');
                HistoricalContractset=ListToSet(HistoricalContractIdList);
                system.debug('HistoricalContractIdList : '+HistoricalContractIdList);
                
                AllContractIdSet.addAll(HistoricalContractset);
            }
            if(TempRecord.ASI_CRM_New_Contract_v0_0__c!=null && TempRecord.ASI_CRM_New_Contract_v0_0__c!=''){
                List<String> NewContractV00IdList=TempRecord.ASI_CRM_New_Contract_v0_0__c.split(';');
                NewContractV00set=ListToSet(NewContractV00IdList);
                AllContractIdSet.addAll(NewContractV00set);
            }
            if(TempRecord.ASI_CRM_New_Contract_vFinal__c!=null && TempRecord.ASI_CRM_New_Contract_vFinal__c!=''){
                List<String> NewContractVFinalIdList=TempRecord.ASI_CRM_New_Contract_vFinal__c.split(';');
                NewContractVFinalset=ListToSet(NewContractVFinalIdList);
                AllContractIdSet.addAll(NewContractVFinalset);
            }//List<String> IdSet =str.split(';');
            
            if(TempRecord.ASI_CRM_Comments__c!=null && TempRecord.ASI_CRM_Comments__c!='' && TempRecord.ASI_CRM_Comments__c.contains(';')){
                List<String> ContractIdList=TempRecord.ASI_CRM_Comments__c.split(';');
                String HistoricalContractID='';
                if(ContractIdList.size()>1){
                    HistoricalContractID=ContractIdList[1];
                    ExistHistoricalData=true;
                }
                if(HistoricalContractID!=''){
                    HistoricalContract=[select id,Name,ASI_CRM_Martell_BC_Rate__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_PO_Start_Date__c,  ASI_CRM_CN_PO_End_Date__c,ASI_CRM_Remarks__c,ASI_CRM_CN_Description__c  FROM ASI_TH_CRM_Contract__c WHERE id = :HistoricalContractID];
                    if (HistoricalContract.ASI_CRM_CN_PO_Start_Date__c!= null){
                        if (MonthMapping.containskey((HistoricalContract.ASI_CRM_CN_PO_Start_Date__c).MONTH())){
                            HistoricalContract.ASI_CRM_Remarks__c = (HistoricalContract.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((HistoricalContract.ASI_CRM_CN_PO_Start_Date__c).MONTH());
                        }
                    }
                    
                    if (HistoricalContract.ASI_CRM_CN_PO_End_Date__c!= null){
                        if (MonthMapping.containskey((HistoricalContract.ASI_CRM_CN_PO_End_Date__c).MONTH())){
                            HistoricalContract.ASI_CRM_CN_Description__c = (HistoricalContract.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((HistoricalContract.ASI_CRM_CN_PO_End_Date__c).MONTH());
                        }
                    }
                    
                }
            }
            
            //HistoricalContract
        }
        
        system.debug('AllContractIdSet: '+AllContractIdSet);
        system.debug('HistoricalContractset: '+HistoricalContractset);
        
        List<ASI_Attachment__c> AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c 
                                                 where ASI_CRM_Contract__c in:AllContractIdSet and ASI_CRM_Contract__c!=null ];
        
        
        system.debug('Enter 12: '+AttachmentList);
        
        for(ASI_Attachment__c att:AttachmentList){
            system.debug('Enter 12: ');
            if(HistoricalContractset.contains(att.ASI_CRM_Contract__c) && !Check_HistoricalContractset.contains(att.ASI_CRM_Contract__c)){//Historical Contract V0.0 and Historical VFinal 
                if(att.ASI_CRM_Type__c=='Current V0VFinal Data'){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                    system.debug('HistoricalContractList: '+HistoricalContractList);
                    if(HistoricalContractList.size()>0){
                        
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalV00Temp= HistoricalContractList[0];
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalVFinalTemp= HistoricalContractList[1];
                        
                        if(HistoricalVFinalTemp.AddOnString!=''){
                            Check_HistoricalContractset.add(att.ASI_CRM_Contract__c);
                            Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(HistoricalVFinalTemp.AddOnString,Map<String,Decimal>.class);
                            if( TempMap.containsKey('PSFEstTotal')  ){//HistoricalPSFEstTotal += TempMap.get('PSFEstTotal');
                                PSFDetailTotal.HistoricalTotalFees+= TempMap.get('PSFEstTotal');
                            }
                            if( TempMap.containsKey('VECEstTotal')  ){//HistoricalVECEstTotal+= TempMap.get('VECEstTotal');
                                VECDetailTotal.HistoricalTotalFees+= TempMap.get('VECEstTotal');
                            }
                            
                            if( TempMap.containsKey('TotalBC_prorate')  ){//TotalHC_BC
                                TotalHC_BC+= TempMap.get('TotalBC_prorate');
                            }
                            if( TempMap.containsKey('TotalBlackCap_prorate')  ){//TotalBackCap
                                TotalHC_BackCap+= TempMap.get('TotalBlackCap_prorate');
                            }
                            if( TempMap.containsKey('Total_IntakeBtl_prorate')  ){//TotalHC_IntakeBtl
                                TotalHC_IntakeBtl+= TempMap.get('Total_IntakeBtl_prorate');
                            }
                            
                            if( TempMap.containsKey('TotalHistorical_MartellBC')  ){//TotalHC_BC
                                TotalHC_BC_Martell+= TempMap.get('TotalHistorical_MartellBC');
                            }
                            if( TempMap.containsKey('TotalHistorical_MartellIntakeBtl')  ){//TotalBackCap
                                TotalHC_IntakeBtl_Martell+= TempMap.get('TotalHistorical_MartellIntakeBtl');
                            }
                            if( TempMap.containsKey('TotalHistorical_MartellBlackCap')  ){//TotalHC_IntakeBtl
                                TotalHC_BackCap_Martell += TempMap.get('TotalHistorical_MartellBlackCap');
                            } 
                        }        
                        HistoricalV00Contract= FIConsolidation(HistoricalV00Contract,HistoricalV00Temp);
                        HistoricalVFinalContract= FIConsolidation(HistoricalVFinalContract,HistoricalVFinalTemp);
                    }
                }
            }
            
            if(NewContractV00set.contains(att.ASI_CRM_Contract__c) && !Check_NewContractV00set.contains(att.ASI_CRM_Contract__c) ){ // new contract V0.0 and new Contract VFinal Data
                if(att.ASI_CRM_Type__c=='Contract Data'){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        Check_NewContractV00set.add(att.ASI_CRM_Contract__c);
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContractV0EsitimateTemp= ContractList[0];
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContactV0ContractTemp= ContractList[1];
                        
                        NewContactV0Contract= FIConsolidation(NewContactV0Contract,NewContactV0ContractTemp);
                        NewContractV0Esitimate= FIConsolidation(NewContractV0Esitimate,NewContractV0EsitimateTemp);
                        
                        
                        ContractObject TempContract = new ContractObject ();
                        TempContract.ContractFI= ContractList[0];
                        IF(ContractList[0].ContractId!='' ){
                            TempContract.ContractId= ContractList[0].ContractId;
                        }
                        SummaryContractMap.put(ContractList[0].ContractId,TempContract);
                        
                    } 
                }
            }
            
            if(NewContractVFinalset.contains(att.ASI_CRM_Contract__c) && !Check_NewContractVFinalset.contains(att.ASI_CRM_Contract__c)){// new contract VFinal 
                if(att.ASI_CRM_Type__c=='PO Modification Data'){//new contract Vfinal
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class); 
                    if(ContractList.size()>0){
                        Check_NewContractVFinalset.add(att.ASI_CRM_Contract__c);
                        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator CurrentContractVFinal= ContractList[0];
                        NewContactVFinal= FIConsolidation(NewContactVFinal,CurrentContractVFinal);
                        system.debug('CurrentContractVFinal Volumes: '+CurrentContractVFinal.Volumes);
                        
                        if(CurrentContractVFinal.AddOnString!=''){
                            Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(CurrentContractVFinal.AddOnString,Map<String,Decimal>.class);
                            if( TempMap.containsKey('TotalBC_prorate')  ){//TotalBC
                                Total_BC+= TempMap.get('TotalBC_prorate');
                            }
                            if( TempMap.containsKey('TotalBlackCap_prorate')  ){//TotalBackCap
                                Total_BackCap+= TempMap.get('TotalBlackCap_prorate');
                            }
                            if( TempMap.containsKey('Total_IntakeBtl_prorate')  ){//Total_IntakeBtl
                                Total_IntakeBtl+= TempMap.get('Total_IntakeBtl_prorate');
                            }
                            
                            if( TempMap.containsKey('Total_MartellBC')  ){//Total Martell BC
                                Total_BC_Martell+= TempMap.get('Total_MartellBC');
                            }
                            if( TempMap.containsKey('Total_MartellIntakeBtl')  ){//Total Martell BackCap
                                Total_IntakeBtl_Martell+= TempMap.get('Total_MartellIntakeBtl');
                            }
                            if( TempMap.containsKey('Total_MartellBlackCap')  ){//Total Martell Intake Btl
                                Total_BackCap_Martell+= TempMap.get('Total_MartellBlackCap');
                            }
                            
                            
                        }
                    }
                }
                
            }
            
        }
        
        //Calculate Historical and new contract vFinal Total BC Rate and Net BC Rate
        
        if(TotalHC_IntakeBtl!=0){
            HistoricalVFinalTotalBCRate=(TotalHC_BC/TotalHC_IntakeBtl)*100;
            HistoricalVFinalNetBCRate=((TotalHC_BC-TotalHC_BackCap)/TotalHC_IntakeBtl)*100;
        }
        
        
        if(Total_IntakeBtl!=0){
            NewContractVFinalTotalBCRate=(Total_BC/Total_IntakeBtl)*100;
            NewContractVFinalNetBCRate=((Total_BC-Total_BackCap)/Total_IntakeBtl)*100;
        }
        
        
        if(TotalHC_IntakeBtl!=0 && TotalHC_IntakeBtl_Martell!=0){
            Hist_VFinalTotalMarBCRate=(TotalHC_BC_Martell/TotalHC_IntakeBtl_Martell)*100;
            Hist_VFinalNetMarBCRate=((TotalHC_BC_Martell-TotalHC_BackCap_Martell)/TotalHC_IntakeBtl_Martell)*100;
        }
        
        
        if(Total_IntakeBtl!=0 && Total_IntakeBtl_Martell!=0){
            New_VFinalTotalMartellBCRate=(Total_BC_Martell/Total_IntakeBtl_Martell)*100;
            New_VFinalNetMartellBCRate=((Total_BC_Martell-Total_BackCap_Martell)/Total_IntakeBtl_Martell)*100;
        }
        
        
        
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:[SELECT Id, ASI_CRM_Max_Incentive__c,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c, ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,  ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                WHERE ASI_CRM_CN_Contract__c!=null and (ASI_CRM_CN_Contract__c in :NewContractV00set or ASI_CRM_CN_Contract__c in :NewContractVFinalset) ] )
        {
            IF(ContractLine.ASI_CRM_Type__c=='PSF'){
                if(NewContractV00set.contains(ContractLine.ASI_CRM_CN_Contract__c)){
                    PSFDetailTotal.ContractTotalFees +=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    PSFDetailTotal.EstimateTotalFees+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }
                if(NewContractVFinalset.contains(ContractLine.ASI_CRM_CN_Contract__c)){
                    PSFDetailTotal.VFinalTotalFees +=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                } 
            }
            
            if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                if(NewContractV00set.contains(ContractLine.ASI_CRM_CN_Contract__c)){
                    VECDetailTotal.ContractTotalFees +=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    VECDetailTotal.EstimateTotalFees+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }
                
                if(NewContractVFinalset.contains(ContractLine.ASI_CRM_CN_Contract__c)){
                    VECDetailTotal.VFinalTotalFees +=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                }
                
            }
            
        }
        
        
        //Looping the Real contract
        for(ASI_TH_CRM_Contract__c RealContract:[select Id,Name,ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Outlet_WS__r.Name,ASI_CRM_CN_PO_No__c from ASI_TH_CRM_Contract__c where id in:AllContractIdSet and ASI_CRM_CN_Outlet_WS__c!=null]){
            if(SummaryContractMap.containsKey(RealContract.Id)){
                SummaryContractMap.get(RealContract.Id).CurrentContract = RealContract ;
            }
            if(HistoricalContractset.contains(RealContract.Id)){
                HistoricalContractOutletset.add(RealContract.ASI_CRM_CN_Outlet_WS__c);
            }
            if(NewContractV00set.contains(RealContract.Id)){
                NewContractV00Outletset.add(RealContract.ASI_CRM_CN_Outlet_WS__c);
            }
            if(NewContractVFinalset.contains(RealContract.Id)){
                NewContractVFinalOutletset.add(RealContract.ASI_CRM_CN_Outlet_WS__c);
            }
        }
        
        
        for(ASI_CRM_CN_Covered_Outlet__c CoveredOutlet:[SELECT id, ASI_CRM_CN_Contract__c,ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c   WHERE ASI_CRM_CN_Contract__c in:AllContractIdSet and ASI_CRM_CN_Outlet__c!=null ]){
            if(HistoricalContractset.contains(CoveredOutlet.ASI_CRM_CN_Contract__c)){
                HistoricalContractOutletset.add(CoveredOutlet.ASI_CRM_CN_Outlet__c);
            }
            if(NewContractV00set.contains(CoveredOutlet.ASI_CRM_CN_Contract__c)){
                NewContractV00Outletset.add(CoveredOutlet.ASI_CRM_CN_Outlet__c);
            }
            if(NewContractVFinalset.contains(CoveredOutlet.ASI_CRM_CN_Contract__c)){
                NewContractVFinalOutletset.add(CoveredOutlet.ASI_CRM_CN_Outlet__c);
            }
        }
        
        HistoricalCoveredOutletSize=HistoricalContractOutletset.size();
        V0CoveredOutletSize=NewContractV00Outletset.size();
        VFinalCoveredOutletSize=NewContractVFinalOutletset.size();
        
    }

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd FIConsolidation2nd(ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd CurrentFIData,ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd RawFIData){
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd TempFIData = CurrentFIData;
        //Volumes 销量 (in 9L cs)
        TempFIData.Volumes+=RawFIData.Volumes!=null?RawFIData.Volumes:0;
        //Trade expenses 销售费用
        TempFIData.TradeExpenses+=RawFIData.TradeExpenses!=null?RawFIData.TradeExpenses:0;
        
        //Gross Sales Total
        SYSTEM.debug('GrossSalesTotal   : '+RawFIData.GrossSalesTotal);
        TempFIData.GrossSalesTotal +=RawFIData.GrossSalesTotal!=null?RawFIData.GrossSalesTotal:0;
        //Investment CR12
        TempFIData.IntakeCR12 +=RawFIData.IntakeCR12!=null?RawFIData.IntakeCR12:0;
        
        //Variable expense 变动费用
        TempFIData.VariableExpense +=RawFIData.VariableExpense!=null?RawFIData.VariableExpense:0;
        
        //Fixed Expense 固定费用
        TempFIData.FixedExpense +=RawFIData.FixedExpense!=null?RawFIData.FixedExpense:0;
        TempFIData.CMTotal +=RawFIData.CMTotal!=null?RawFIData.CMTotal:0;
        TempFIData.IntakeSTD +=RawFIData.IntakeSTD!=null?RawFIData.IntakeSTD:0;
        TempFIData.LatestBudgetCMTotal+=RawFIData.LatestBudgetCMTotal!=null?RawFIData.LatestBudgetCMTotal:0;

        //add 2ndKPI 
        TempFIData.GrossSalesTotalProForma += RawFIData.GrossSalesTotalProForma!=null?RawFIData.GrossSalesTotalProForma:0;
        TempFIData.ADTotal += RawFIData.ADTotal!=null?RawFIData.ADTotal:0;
        TempFIData.ADTotalProForma += RawFIData.ADTotalProForma!=null?RawFIData.ADTotalProForma:0;
        
        if(CurrentFIData.ContractLineMap.size()>0){
            TempFIData.ContractLineMap=CurrentFIData.ContractLineMap;
        }else{
            TempFIData.ContractLineMap=new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine>();
        }

        //2nd Data
        System.debug('RawFIData.TradeExpenseBySubBrand'+RawFIData.TradeExpenseBySubBrand);
        TempFIData.TradeExpenseBySubBrand = RawFIData.TradeExpenseBySubBrand;
        System.debug('TempFIData.TradeExpenseBySubBrand'+TempFIData.TradeExpenseBySubBrand);
        //Bottles / month ---> adding all Bottles calculated of real PO
        //Historical 'Est. BRSF'(Fees/Month 单瓶费用)= Total Amount / Total Volume all period
        for(String ContractLineKey:RawFIData.ContractLineMap.keySet()){
            if(TempFIData.ContractLineMap.containsKey(ContractLineKey)){
                TempFIData.ContractLineMap.get(ContractLineKey).HistoricalBottles+=RawFIData.ContractLineMap.get(ContractLineKey).HistoricalBottles;
                TempFIData.ContractLineMap.get(ContractLineKey).EstimateBottles+=RawFIData.ContractLineMap.get(ContractLineKey).EstimateBottles;
                TempFIData.ContractLineMap.get(ContractLineKey).ContractBottles+=RawFIData.ContractLineMap.get(ContractLineKey).ContractBottles;
                TempFIData.ContractLineMap.get(ContractLineKey).VFinalBottles+=RawFIData.ContractLineMap.get(ContractLineKey).VFinalBottles;
                
                TempFIData.ContractLineMap.get(ContractLineKey).HistoricalVolume+=RawFIData.ContractLineMap.get(ContractLineKey).HistoricalVolume;
                TempFIData.ContractLineMap.get(ContractLineKey).EstimateVolume+=RawFIData.ContractLineMap.get(ContractLineKey).EstimateVolume;
                TempFIData.ContractLineMap.get(ContractLineKey).ContractVolume+=RawFIData.ContractLineMap.get(ContractLineKey).ContractVolume;
                TempFIData.ContractLineMap.get(ContractLineKey).VFinalVolume+=RawFIData.ContractLineMap.get(ContractLineKey).VFinalVolume;
                
                TempFIData.ContractLineMap.get(ContractLineKey).HistoricalTotalFees+=RawFIData.ContractLineMap.get(ContractLineKey).HistoricalTotalFees;
                TempFIData.ContractLineMap.get(ContractLineKey).EstimateTotalFees+=RawFIData.ContractLineMap.get(ContractLineKey).EstimateTotalFees;
                TempFIData.ContractLineMap.get(ContractLineKey).ContractTotalFees+=RawFIData.ContractLineMap.get(ContractLineKey).ContractTotalFees;
                TempFIData.ContractLineMap.get(ContractLineKey).VFinalTotalFees+=RawFIData.ContractLineMap.get(ContractLineKey).VFinalTotalFees;
                
                TempFIData.ContractLineMap.get(ContractLineKey).HistoricalActualVolume+=RawFIData.ContractLineMap.get(ContractLineKey).HistoricalActualVolume;
                TempFIData.ContractLineMap.get(ContractLineKey).VFinalActualVolume+=RawFIData.ContractLineMap.get(ContractLineKey).VFinalActualVolume;
                
            }else{
                TempFIData.ContractLineMap.put(ContractLineKey, RawFIData.ContractLineMap.get(ContractLineKey));
            }
        }
        
        
        
        
        for(String SBGName: sbGroup_map.keySet()){
            //CurrentFIData
            if( (RawFIData.SubBrandGradeMap==null || !RawFIData.SubBrandGradeMap.containskey(SBGName) ) && (TempFIData.SubBrandGradeMap==null || !TempFIData.SubBrandGradeMap.containskey(SBGName)) ){
                TempFIData.SubBrandGradeMap.put(SBGName,0.0);  
            }else if( RawFIData.SubBrandGradeMap!=null && RawFIData.SubBrandGradeMap.containskey(SBGName) && (TempFIData.SubBrandGradeMap==null || !TempFIData.SubBrandGradeMap.containskey(SBGName) ) ){
                TempFIData.SubBrandGradeMap.put(SBGName,RawFIData.SubBrandGradeMap.get(SBGName));  
            }else if ( RawFIData.SubBrandGradeMap!=null && RawFIData.SubBrandGradeMap.containskey(SBGName) && TempFIData.SubBrandGradeMap!=null && TempFIData.SubBrandGradeMap.containskey(SBGName) )  {
                Decimal SubBrandVolume = RawFIData.SubBrandGradeMap.get(SBGName) + TempFIData.SubBrandGradeMap.get(SBGName);
                TempFIData.SubBrandGradeMap.remove(SBGName);
                TempFIData.SubBrandGradeMap.put(SBGName,SubBrandVolume ); 
            }
        }

        System.debug(LoggingLevel.INFO, '*** RawFIData.CategoryMap: ' + RawFIData.CategoryMap);
        System.debug(LoggingLevel.INFO, '*** : TempFIData.CategoryMap' + TempFIData.CategoryMap);
        
        for(String categoryName: byCategoryMap.keySet()){
            //CurrentFIData
            // if( (RawFIData.CategoryMap==null || !RawFIData.CategoryMap.containskey(categoryName) ) && (TempFIData.CategoryMap==null || !TempFIData.CategoryMap.containskey(categoryName)) ){
            //     TempFIData.CategoryMap.put(categoryName,0.0);  
            // }else 
            if( RawFIData.CategoryMap!=null && RawFIData.CategoryMap.containskey(categoryName) && (TempFIData.CategoryMap==null || !TempFIData.CategoryMap.containskey(categoryName) ) ){
                TempFIData.CategoryMap.put(categoryName,RawFIData.CategoryMap.get(categoryName));  
            }else if ( RawFIData.CategoryMap!=null && RawFIData.CategoryMap.containskey(categoryName) && TempFIData.CategoryMap!=null && TempFIData.CategoryMap.containskey(categoryName) )  {
                Decimal SubBrandVolume = RawFIData.CategoryMap.get(categoryName) + TempFIData.CategoryMap.get(categoryName);
                TempFIData.CategoryMap.remove(categoryName);
                TempFIData.CategoryMap.put(categoryName,SubBrandVolume); 
            }
        }
        return TempFIData;
    }

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FIConsolidation(ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator CurrentFIData,ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator RawFIData){
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator TempFIData = CurrentFIData;
        //Volumes 销量 (in 9L cs)
        TempFIData.Volumes+=RawFIData.Volumes!=null?RawFIData.Volumes:0;
        //Trade expenses 销售费用
        TempFIData.TradeExpenses+=RawFIData.TradeExpenses!=null?RawFIData.TradeExpenses:0;
        
        //Gross Sales Total
        SYSTEM.debug('GrossSalesTotal   : '+RawFIData.GrossSalesTotal);
        TempFIData.GrossSalesTotal +=RawFIData.GrossSalesTotal!=null?RawFIData.GrossSalesTotal:0;
        //Investment CR12
        TempFIData.IntakeCR12 +=RawFIData.IntakeCR12!=null?RawFIData.IntakeCR12:0;
        
        //Variable expense 变动费用
        TempFIData.VariableExpense +=RawFIData.VariableExpense!=null?RawFIData.VariableExpense:0;
        
        //Fixed Expense 固定费用
        TempFIData.FixedExpense +=RawFIData.FixedExpense!=null?RawFIData.FixedExpense:0;
        TempFIData.CMTotal +=RawFIData.CMTotal!=null?RawFIData.CMTotal:0;
        TempFIData.IntakeSTD +=RawFIData.IntakeSTD!=null?RawFIData.IntakeSTD:0;
        TempFIData.LatestBudgetCMTotal+=RawFIData.LatestBudgetCMTotal!=null?RawFIData.LatestBudgetCMTotal:0;
        
        if(CurrentFIData.ContractLineMap.size()>0){
            TempFIData.ContractLineMap=CurrentFIData.ContractLineMap;
        }else{
            TempFIData.ContractLineMap=new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine>();
        }
        
        //Bottles / month ---> adding all Bottles calculated of real PO
        //Historical 'Est. BRSF'(Fees/Month 单瓶费用)= Total Amount / Total Volume all period
        for(String ContractLineKey:RawFIData.ContractLineMap.keySet()){
            if(TempFIData.ContractLineMap.containsKey(ContractLineKey)){
                TempFIData.ContractLineMap.get(ContractLineKey).HistoricalBottles+=RawFIData.ContractLineMap.get(ContractLineKey).HistoricalBottles;
                TempFIData.ContractLineMap.get(ContractLineKey).EstimateBottles+=RawFIData.ContractLineMap.get(ContractLineKey).EstimateBottles;
                TempFIData.ContractLineMap.get(ContractLineKey).ContractBottles+=RawFIData.ContractLineMap.get(ContractLineKey).ContractBottles;
                TempFIData.ContractLineMap.get(ContractLineKey).VFinalBottles+=RawFIData.ContractLineMap.get(ContractLineKey).VFinalBottles;
                
                TempFIData.ContractLineMap.get(ContractLineKey).HistoricalVolume+=RawFIData.ContractLineMap.get(ContractLineKey).HistoricalVolume;
                TempFIData.ContractLineMap.get(ContractLineKey).EstimateVolume+=RawFIData.ContractLineMap.get(ContractLineKey).EstimateVolume;
                TempFIData.ContractLineMap.get(ContractLineKey).ContractVolume+=RawFIData.ContractLineMap.get(ContractLineKey).ContractVolume;
                TempFIData.ContractLineMap.get(ContractLineKey).VFinalVolume+=RawFIData.ContractLineMap.get(ContractLineKey).VFinalVolume;
                
                TempFIData.ContractLineMap.get(ContractLineKey).HistoricalTotalFees+=RawFIData.ContractLineMap.get(ContractLineKey).HistoricalTotalFees;
                TempFIData.ContractLineMap.get(ContractLineKey).EstimateTotalFees+=RawFIData.ContractLineMap.get(ContractLineKey).EstimateTotalFees;
                TempFIData.ContractLineMap.get(ContractLineKey).ContractTotalFees+=RawFIData.ContractLineMap.get(ContractLineKey).ContractTotalFees;
                TempFIData.ContractLineMap.get(ContractLineKey).VFinalTotalFees+=RawFIData.ContractLineMap.get(ContractLineKey).VFinalTotalFees;
                
                TempFIData.ContractLineMap.get(ContractLineKey).HistoricalActualVolume+=RawFIData.ContractLineMap.get(ContractLineKey).HistoricalActualVolume;
                TempFIData.ContractLineMap.get(ContractLineKey).VFinalActualVolume+=RawFIData.ContractLineMap.get(ContractLineKey).VFinalActualVolume;
                
            }else{
                TempFIData.ContractLineMap.put(ContractLineKey, RawFIData.ContractLineMap.get(ContractLineKey));
            }
        }
        
        
        
        
        for(String SBGName: sbGroup_map.keySet()){//CurrentFIData
            if( (RawFIData.SubBrandGradeMap==null || !RawFIData.SubBrandGradeMap.containskey(SBGName) ) && (TempFIData.SubBrandGradeMap==null || !TempFIData.SubBrandGradeMap.containskey(SBGName)) ){
                TempFIData.SubBrandGradeMap.put(SBGName,0.0);  
            }else if( RawFIData.SubBrandGradeMap!=null && RawFIData.SubBrandGradeMap.containskey(SBGName) && (TempFIData.SubBrandGradeMap==null || !TempFIData.SubBrandGradeMap.containskey(SBGName) ) ){
                TempFIData.SubBrandGradeMap.put(SBGName,RawFIData.SubBrandGradeMap.get(SBGName));  
            }else if ( RawFIData.SubBrandGradeMap!=null && RawFIData.SubBrandGradeMap.containskey(SBGName) && TempFIData.SubBrandGradeMap!=null && TempFIData.SubBrandGradeMap.containskey(SBGName) )  {
                Decimal SubBrandVolume = RawFIData.SubBrandGradeMap.get(SBGName) + TempFIData.SubBrandGradeMap.get(SBGName);
                TempFIData.SubBrandGradeMap.remove(SBGName);
                TempFIData.SubBrandGradeMap.put(SBGName,SubBrandVolume ); 
            }
            
            
        }
        
        
        return TempFIData;
    }
    
    //*********************Finished FIConsolidation *********************
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd InitData2nd(ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd InputFIData){

        for(String SBGName: sbGroup_map.keySet()){
            InputFIData.SubBrandGradeMap.put(SBGName,0.0);  
        }

        // author: Bluelinksys_PC Date : 2020-03-30
        for(String categoryName: sbGroup_ByCategoryVFMap.keySet()){
            InputFIData.CategoryMap.put(categoryName,0.0);
        }

        return InputFIData;
    }

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator InitData(ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator InputFIData){
        
        for(String SBGName: sbGroup_map.keySet()){
            InputFIData.SubBrandGradeMap.put(SBGName,0.0);  
        }
        
        return InputFIData;
    }
    
    
    
    
    //Sub-Brand Data 
    public void DataReconstruct2nd(){

        SubBrandContractMap = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine>(NewContactV0Contract2nd.ContractLineMap);
        //Historical VFinal Contract FI Data 
        for(String ContractLineKey:HistoricalVFinalContract2nd.ContractLineMap.keySet()){
            if(SubBrandContractMap.containsKey(ContractLineKey)){
                SubBrandContractMap.get(ContractLineKey).HistoricalBottles+=HistoricalVFinalContract2nd.ContractLineMap.get(ContractLineKey).HistoricalBottles;
                SubBrandContractMap.get(ContractLineKey).HistoricalFees += HistoricalVFinalContract2nd.ContractLineMap.get(ContractLineKey).HistoricalFees;
                SubBrandContractMap.get(ContractLineKey).HistoricalTotalFees += HistoricalVFinalContract2nd.ContractLineMap.get(ContractLineKey).HistoricalTotalFees;
                SubBrandContractMap.get(ContractLineKey).HistoricalVolume += HistoricalVFinalContract2nd.ContractLineMap.get(ContractLineKey).HistoricalVolume;
            }else{
                SubBrandContractMap.put(ContractLineKey, HistoricalVFinalContract2nd.ContractLineMap.get(ContractLineKey));
            }
        }
        
        //New Contract VFinal  FI Data 
        for(String ContractLineKey:NewContactVFinal2nd.ContractLineMap.keySet()){
            if(SubBrandContractMap.containsKey(ContractLineKey)){
                SubBrandContractMap.get(ContractLineKey).VFinalBottles+=NewContactVFinal2nd.ContractLineMap.get(ContractLineKey).VFinalBottles;
                SubBrandContractMap.get(ContractLineKey).VFinalActualVolume += NewContactVFinal2nd.ContractLineMap.get(ContractLineKey).VFinalActualVolume;
                SubBrandContractMap.get(ContractLineKey).VFinalTotalFees += NewContactVFinal2nd.ContractLineMap.get(ContractLineKey).VFinalTotalFees;
                SubBrandContractMap.get(ContractLineKey).VFinalVolume += NewContactVFinal2nd.ContractLineMap.get(ContractLineKey).VFinalVolume;
                
            }else{
                SubBrandContractMap.put(ContractLineKey, NewContactVFinal2nd.ContractLineMap.get(ContractLineKey));
            }
        }
        
        //Looping SubBrandContractMap to calculate 'Fees / month'
        for(String SubBrandContractKey:SubBrandContractMap.keySet()){
            if(SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume !=null && SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume !=0 ){
                SubBrandContractMap.get(SubBrandContractKey).HistoricalFees = SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees / SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume ;
            }else{
                SubBrandContractMap.get(SubBrandContractKey).HistoricalFees =0;
            }
            
            if(SubBrandContractMap.get(SubBrandContractKey).EstimateVolume !=null && SubBrandContractMap.get(SubBrandContractKey).EstimateVolume !=0 ){
                SubBrandContractMap.get(SubBrandContractKey).EstimateFees = SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees / SubBrandContractMap.get(SubBrandContractKey).EstimateVolume ;
            }else{
                SubBrandContractMap.get(SubBrandContractKey).EstimateFees =0;
            }
            
            
            if(SubBrandContractMap.get(SubBrandContractKey).ContractVolume !=null && SubBrandContractMap.get(SubBrandContractKey).ContractVolume !=0 ){
                SubBrandContractMap.get(SubBrandContractKey).ContractFees = SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees / SubBrandContractMap.get(SubBrandContractKey).ContractVolume ;
            }else{
                SubBrandContractMap.get(SubBrandContractKey).ContractFees =0;
            }
            
            if(SubBrandContractMap.get(SubBrandContractKey).VFinalVolume !=null && SubBrandContractMap.get(SubBrandContractKey).VFinalVolume !=0 ){
                system.debug('VFinalTotalFees : '+  SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees );
                system.debug('VFinalVolume : '+  SubBrandContractMap.get(SubBrandContractKey).VFinalVolume );
                SubBrandContractMap.get(SubBrandContractKey).VFinalFees = SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees / SubBrandContractMap.get(SubBrandContractKey).VFinalVolume ;
            }else{
                SubBrandContractMap.get(SubBrandContractKey).VFinalFees =0;
            }
            
            
            if(SubBrandContractMap.get(SubBrandContractKey).HistoricalFees !=null &&  SubBrandContractMap.get(SubBrandContractKey).HistoricalActualVolume!=null ){
                SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees= SubBrandContractMap.get(SubBrandContractKey).HistoricalFees * SubBrandContractMap.get(SubBrandContractKey).HistoricalActualVolume;
            }
            if(SubBrandContractMap.get(SubBrandContractKey).VFinalFees !=null && SubBrandContractMap.get(SubBrandContractKey).VFinalActualVolume !=null ){
                 system.debug('VFinalFees : '+  SubBrandContractMap.get(SubBrandContractKey).VFinalFees );
                 system.debug('VFinalActualVolume : '+  SubBrandContractMap.get(SubBrandContractKey).VFinalActualVolume );
                SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees=SubBrandContractMap.get(SubBrandContractKey).VFinalFees  * SubBrandContractMap.get(SubBrandContractKey).VFinalActualVolume;
                
            }
            
        }
        
        
        Decimal Sum_HistoricalTotalFees=0;
        Decimal Sum_EstimateTotalFees=0;
        Decimal Sum_ContractTotalFees=0;
        Decimal Sum_vFinalTotalFees=0;
        
        
        //Fix rounding case
        for(String SubBrandContractKey:SubBrandContractMap.keySet()){
            
            SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles);
            SubBrandContractMap.get(SubBrandContractKey).HistoricalFees=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalFees);
            
            SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees);
            
            
            SubBrandContractMap.get(SubBrandContractKey).VFinalFees=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).VFinalFees);
            
            
            SubBrandContractMap.get(SubBrandContractKey).EstimateBottles=Math.floor(SubBrandContractMap.get(SubBrandContractKey).EstimateBottles);
            SubBrandContractMap.get(SubBrandContractKey).EstimateFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).EstimateFees);
            SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees);
            
            
            
            SubBrandContractMap.get(SubBrandContractKey).ContractBottles=Math.floor(SubBrandContractMap.get(SubBrandContractKey).ContractBottles);
            SubBrandContractMap.get(SubBrandContractKey).ContractFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).ContractFees);
            SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees);
            
            
            SubBrandContractMap.get(SubBrandContractKey).VFinalBottles=Math.floor(SubBrandContractMap.get(SubBrandContractKey).VFinalBottles);
            SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees);
            
            if(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateBottles==0 
                && SubBrandContractMap.get(SubBrandContractKey).ContractBottles ==0 && SubBrandContractMap.get(SubBrandContractKey).VFinalBottles==0
               && SubBrandContractMap.get(SubBrandContractKey).HistoricalFees ==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateFees==0 
               && SubBrandContractMap.get(SubBrandContractKey).ContractFees ==0 && SubBrandContractMap.get(SubBrandContractKey).VFinalFees==0
               && SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees==0 
               && SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees==0 && SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees==0 )
            {
                SubBrandContractMap.remove(SubBrandContractKey);
            }else{
                integer intlength = SubBrandContractMap.get(SubBrandContractKey).SubBrandName.length();
                if(intlength >= 4 && SubBrandContractMap.get(SubBrandContractKey).SubBrandName.contains('-')){
                    SubBrandContractMap.get(SubBrandContractKey).strSubBrand =  SubBrandContractMap.get(SubBrandContractKey).SubBrandName.substring(0, (intlength-4));
                }
                
                
                SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles =SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles!=null? SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles.setScale(0, RoundingMode.HALF_UP):0;
                system.debug(' VFinalBottles : '+SubBrandContractMap.get(SubBrandContractKey).VFinalBottles );
                SubBrandContractMap.get(SubBrandContractKey).VFinalBottles =SubBrandContractMap.get(SubBrandContractKey).VFinalBottles!=null? SubBrandContractMap.get(SubBrandContractKey).VFinalBottles.setScale(0, RoundingMode.HALF_UP):0;
                
                
                //calculate Fees / month
                if(SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume!=0 && SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees !=null){
                    SubBrandContractMap.get(SubBrandContractKey).HistoricalFees= NumberRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees/SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume);
                }
                
                if(SubBrandContractMap.get(SubBrandContractKey).EstimateVolume!=0 && SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees !=null){
                    SubBrandContractMap.get(SubBrandContractKey).EstimateFees= NumberRounding(SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees/SubBrandContractMap.get(SubBrandContractKey).EstimateVolume);
                }
                
                if(SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume!=0 && SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees !=null){
                    SubBrandContractMap.get(SubBrandContractKey).ContractFees= NumberRounding(SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees/SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume);
                }
                
                //if(SubBrandContractMap.get(SubBrandContractKey).VFinalVolume!=0 && SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees !=null){
                //SubBrandContractMap.get(SubBrandContractKey).VFinalFees= NumberRounding(SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees/SubBrandContractMap.get(SubBrandContractKey).VFinalVolume);
                //}
                //Calculate Sum                 
                Sum_HistoricalTotalFees+=SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees;
                Sum_EstimateTotalFees +=SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees!=null?SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees:0;
                Sum_ContractTotalFees +=SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees!=null? SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees:0;
                Sum_vFinalTotalFees +=SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees!=null? SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees:0;
                
            }
        }
        
        
        
        
        //AdjustmentRecognition
        AdjustmentRecognition.HistoricalTotalFees= -(HistoricalVFinalContract2nd.VariableExpense-PSFDetailTotal.HistoricalTotalFees-VECDetailTotal.HistoricalTotalFees-Sum_HistoricalTotalFees);
        AdjustmentRecognition.EstimateTotalFees=-(NewContractV0Esitimate2nd.VariableExpense-PSFDetailTotal.EstimateTotalFees-VECDetailTotal.EstimateTotalFees-Sum_EstimateTotalFees);
        AdjustmentRecognition.ContractTotalFees=-(NewContactV0Contract2nd.VariableExpense-PSFDetailTotal.ContractTotalFees-VECDetailTotal.ContractTotalFees-Sum_ContractTotalFees);
        AdjustmentRecognition.VFinalTotalFees=-(NewContactVFinal2nd.VariableExpense-PSFDetailTotal.VFinalTotalFees-VECDetailTotal.VFinalTotalFees-Sum_vFinalTotalFees);
        
        if(AdjustmentRecognition.HistoricalTotalFees!=0 || AdjustmentRecognition.ContractTotalFees!=0 || AdjustmentRecognition.EstimateTotalFees!=0 ||  AdjustmentRecognition.VFinalTotalFees!=0){
            ShowAchievementRecognition=true;
        }
        
    }

    //Sub-Brand Data 
    public void DataReconstruct(){
        SubBrandContractMap = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine>(NewContactV0Contract.ContractLineMap);
        //Historical VFinal Contract FI Data 
        for(String ContractLineKey:HistoricalVFinalContract.ContractLineMap.keySet()){
            if(SubBrandContractMap.containsKey(ContractLineKey)){
                SubBrandContractMap.get(ContractLineKey).HistoricalBottles+=HistoricalVFinalContract.ContractLineMap.get(ContractLineKey).HistoricalBottles;
                SubBrandContractMap.get(ContractLineKey).HistoricalFees += HistoricalVFinalContract.ContractLineMap.get(ContractLineKey).HistoricalFees;
                SubBrandContractMap.get(ContractLineKey).HistoricalTotalFees += HistoricalVFinalContract.ContractLineMap.get(ContractLineKey).HistoricalTotalFees;
                SubBrandContractMap.get(ContractLineKey).HistoricalVolume += HistoricalVFinalContract.ContractLineMap.get(ContractLineKey).HistoricalVolume;
            }else{
                SubBrandContractMap.put(ContractLineKey, HistoricalVFinalContract.ContractLineMap.get(ContractLineKey));
            }
        }
        
        //New Contract VFinal  FI Data 
        for(String ContractLineKey:NewContactVFinal.ContractLineMap.keySet()){
            if(SubBrandContractMap.containsKey(ContractLineKey)){
                SubBrandContractMap.get(ContractLineKey).VFinalBottles+=NewContactVFinal.ContractLineMap.get(ContractLineKey).VFinalBottles;
                SubBrandContractMap.get(ContractLineKey).VFinalActualVolume += NewContactVFinal.ContractLineMap.get(ContractLineKey).VFinalActualVolume;
                SubBrandContractMap.get(ContractLineKey).VFinalTotalFees += NewContactVFinal.ContractLineMap.get(ContractLineKey).VFinalTotalFees;
                SubBrandContractMap.get(ContractLineKey).VFinalVolume += NewContactVFinal.ContractLineMap.get(ContractLineKey).VFinalVolume;
                
            }else{
                SubBrandContractMap.put(ContractLineKey, NewContactVFinal.ContractLineMap.get(ContractLineKey));
            }
        }
        
        //Looping SubBrandContractMap to calculate 'Fees / month'
        for(String SubBrandContractKey:SubBrandContractMap.keySet()){
            if(SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume !=null && SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume !=0 ){
                SubBrandContractMap.get(SubBrandContractKey).HistoricalFees = SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees / SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume ;
            }else{
                SubBrandContractMap.get(SubBrandContractKey).HistoricalFees =0;
            }
            
            if(SubBrandContractMap.get(SubBrandContractKey).EstimateVolume !=null && SubBrandContractMap.get(SubBrandContractKey).EstimateVolume !=0 ){
                SubBrandContractMap.get(SubBrandContractKey).EstimateFees = SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees / SubBrandContractMap.get(SubBrandContractKey).EstimateVolume ;
            }else{
                SubBrandContractMap.get(SubBrandContractKey).EstimateFees =0;
            }
            
            
            if(SubBrandContractMap.get(SubBrandContractKey).ContractVolume !=null && SubBrandContractMap.get(SubBrandContractKey).ContractVolume !=0 ){
                SubBrandContractMap.get(SubBrandContractKey).ContractFees = SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees / SubBrandContractMap.get(SubBrandContractKey).ContractVolume ;
            }else{
                SubBrandContractMap.get(SubBrandContractKey).ContractFees =0;
            }
            
            if(SubBrandContractMap.get(SubBrandContractKey).VFinalVolume !=null && SubBrandContractMap.get(SubBrandContractKey).VFinalVolume !=0 ){
                system.debug('VFinalTotalFees : '+  SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees );
                system.debug('VFinalVolume : '+  SubBrandContractMap.get(SubBrandContractKey).VFinalVolume );
                SubBrandContractMap.get(SubBrandContractKey).VFinalFees = SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees / SubBrandContractMap.get(SubBrandContractKey).VFinalVolume ;
            }else{
                SubBrandContractMap.get(SubBrandContractKey).VFinalFees =0;
            }
            
            
            if(SubBrandContractMap.get(SubBrandContractKey).HistoricalFees !=null &&  SubBrandContractMap.get(SubBrandContractKey).HistoricalActualVolume!=null ){
                SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees= SubBrandContractMap.get(SubBrandContractKey).HistoricalFees * SubBrandContractMap.get(SubBrandContractKey).HistoricalActualVolume;
            }
            if(SubBrandContractMap.get(SubBrandContractKey).VFinalFees !=null && SubBrandContractMap.get(SubBrandContractKey).VFinalActualVolume !=null ){
                 system.debug('VFinalFees : '+  SubBrandContractMap.get(SubBrandContractKey).VFinalFees );
                 system.debug('VFinalActualVolume : '+  SubBrandContractMap.get(SubBrandContractKey).VFinalActualVolume );
                SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees=SubBrandContractMap.get(SubBrandContractKey).VFinalFees  * SubBrandContractMap.get(SubBrandContractKey).VFinalActualVolume;
                
            }
            
        }
        
        
        Decimal Sum_HistoricalTotalFees=0;
        Decimal Sum_EstimateTotalFees=0;
        Decimal Sum_ContractTotalFees=0;
        Decimal Sum_vFinalTotalFees=0;
        
        
        //Fix rounding case
        for(String SubBrandContractKey:SubBrandContractMap.keySet()){
            
            SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles);
            SubBrandContractMap.get(SubBrandContractKey).HistoricalFees=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalFees);
            
            SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees);
            
            
            SubBrandContractMap.get(SubBrandContractKey).VFinalFees=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).VFinalFees);
            
            
            SubBrandContractMap.get(SubBrandContractKey).EstimateBottles=Math.floor(SubBrandContractMap.get(SubBrandContractKey).EstimateBottles);
            SubBrandContractMap.get(SubBrandContractKey).EstimateFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).EstimateFees);
            SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees);
            
            
            
            SubBrandContractMap.get(SubBrandContractKey).ContractBottles=Math.floor(SubBrandContractMap.get(SubBrandContractKey).ContractBottles);
            SubBrandContractMap.get(SubBrandContractKey).ContractFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).ContractFees);
            SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees);
            
            
            SubBrandContractMap.get(SubBrandContractKey).VFinalBottles=Math.floor(SubBrandContractMap.get(SubBrandContractKey).VFinalBottles);
            SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees=Math.floor(SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees);
            
            
            
            
            
            
            
            if(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateBottles==0 && SubBrandContractMap.get(SubBrandContractKey).ContractBottles ==0 && SubBrandContractMap.get(SubBrandContractKey).VFinalBottles==0
               && SubBrandContractMap.get(SubBrandContractKey).HistoricalFees ==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateFees==0 && SubBrandContractMap.get(SubBrandContractKey).ContractFees ==0 && SubBrandContractMap.get(SubBrandContractKey).VFinalFees==0
               && SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees==0 && SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees==0 && SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees==0 )
            {
                SubBrandContractMap.remove(SubBrandContractKey);
            }else{
                integer intlength = SubBrandContractMap.get(SubBrandContractKey).SubBrandName.length();
                if(intlength >= 4 && SubBrandContractMap.get(SubBrandContractKey).SubBrandName.contains('-')){
                    SubBrandContractMap.get(SubBrandContractKey).strSubBrand =  SubBrandContractMap.get(SubBrandContractKey).SubBrandName.substring(0, (intlength-4));
                }
                
                
                SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles =SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles!=null? SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles.setScale(0, RoundingMode.HALF_UP):0;
                system.debug(' VFinalBottles : '+SubBrandContractMap.get(SubBrandContractKey).VFinalBottles );
                SubBrandContractMap.get(SubBrandContractKey).VFinalBottles =SubBrandContractMap.get(SubBrandContractKey).VFinalBottles!=null? SubBrandContractMap.get(SubBrandContractKey).VFinalBottles.setScale(0, RoundingMode.HALF_UP):0;
                
                
                //calculate Fees / month
                if(SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume!=0 && SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees !=null){
                    SubBrandContractMap.get(SubBrandContractKey).HistoricalFees= NumberRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees/SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume);
                }
                
                if(SubBrandContractMap.get(SubBrandContractKey).EstimateVolume!=0 && SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees !=null){
                    SubBrandContractMap.get(SubBrandContractKey).EstimateFees= NumberRounding(SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees/SubBrandContractMap.get(SubBrandContractKey).EstimateVolume);
                }
                
                if(SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume!=0 && SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees !=null){
                    SubBrandContractMap.get(SubBrandContractKey).ContractFees= NumberRounding(SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees/SubBrandContractMap.get(SubBrandContractKey).HistoricalVolume);
                }
                
                //if(SubBrandContractMap.get(SubBrandContractKey).VFinalVolume!=0 && SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees !=null){
                //SubBrandContractMap.get(SubBrandContractKey).VFinalFees= NumberRounding(SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees/SubBrandContractMap.get(SubBrandContractKey).VFinalVolume);
                //}
                //Calculate Sum                 
                Sum_HistoricalTotalFees+=SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees;
                Sum_EstimateTotalFees +=SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees!=null?SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees:0;
                Sum_ContractTotalFees +=SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees!=null? SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees:0;
                Sum_vFinalTotalFees +=SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees!=null? SubBrandContractMap.get(SubBrandContractKey).VFinalTotalFees:0;
                
            }
        }
        
        
        
        
        //AdjustmentRecognition
        AdjustmentRecognition.HistoricalTotalFees= -(HistoricalVFinalContract.VariableExpense-PSFDetailTotal.HistoricalTotalFees-VECDetailTotal.HistoricalTotalFees-Sum_HistoricalTotalFees);
        AdjustmentRecognition.EstimateTotalFees=-(NewContractV0Esitimate.VariableExpense-PSFDetailTotal.EstimateTotalFees-VECDetailTotal.EstimateTotalFees-Sum_EstimateTotalFees);
        AdjustmentRecognition.ContractTotalFees=-(NewContactV0Contract.VariableExpense-PSFDetailTotal.ContractTotalFees-VECDetailTotal.ContractTotalFees-Sum_ContractTotalFees);
        AdjustmentRecognition.VFinalTotalFees=-(NewContactVFinal.VariableExpense-PSFDetailTotal.VFinalTotalFees-VECDetailTotal.VFinalTotalFees-Sum_vFinalTotalFees);
        
        if(AdjustmentRecognition.HistoricalTotalFees!=0 || AdjustmentRecognition.ContractTotalFees!=0 || AdjustmentRecognition.EstimateTotalFees!=0 ||  AdjustmentRecognition.VFinalTotalFees!=0){
            ShowAchievementRecognition=true;
        }
        
    }
    
    
    
    public Decimal NumberRounding(Decimal InputNumber){
        Decimal ResultValue =0;
        if(InputNumber!=null){
            ResultValue = InputNumber.round();
        }else{
            ResultValue=0;
        }
        
        if(math.abs(InputNumber-ResultValue)==0.5){
            ResultValue= ResultValue+ 1;
            
        }
        system.debug(ResultValue);
        
        return ResultValue;
    }
    
    
    
    
    public Decimal DecimalRounding(Decimal InputNumber){
        if(InputNumber!=null){
            if(InputNumber<1 && InputNumber>0){
                InputNumber=0; 
            }
        }
        
        return InputNumber;
    }
    
    
    
    public void DataConsolidation2nd(){
        //Gross Sales Rate
        if (HistoricalV00Contract2nd.GrossSalesTotal  != null && HistoricalV00Contract2nd.GrossSalesTotal  != 0 && HistoricalV00Contract2nd.TradeExpenses!= 0 && HistoricalV00Contract2nd.TradeExpenses != null){
            HistoricalV00Contract2nd.GrossSalesRate = (HistoricalV00Contract2nd.TradeExpenses / HistoricalV00Contract2nd.GrossSalesTotal  *100).SetSCale(2);
        }
        if (HistoricalVFinalContract2nd.GrossSalesTotal  != null && HistoricalVFinalContract2nd.GrossSalesTotal  != 0 && HistoricalVFinalContract2nd.TradeExpenses!= 0 && HistoricalVFinalContract2nd.TradeExpenses != null){
            HistoricalVFinalContract2nd.GrossSalesRate = (HistoricalVFinalContract2nd.TradeExpenses / HistoricalVFinalContract2nd.GrossSalesTotal  *100).SetSCale(2);
        }
        
        system.debug('**************debug0.1 **************');
        system.debug(NewContractV0Esitimate2nd.TradeExpenses);
        system.debug(NewContractV0Esitimate2nd.GrossSalesTotal);
        
        if (NewContractV0Esitimate2nd.GrossSalesTotal  != null && NewContractV0Esitimate2nd.GrossSalesTotal  != 0 && NewContractV0Esitimate2nd.TradeExpenses!= 0 && NewContractV0Esitimate2nd.TradeExpenses != null){
            NewContractV0Esitimate2nd.GrossSalesRate = (NewContractV0Esitimate2nd.TradeExpenses / NewContractV0Esitimate2nd.GrossSalesTotal  *100).SetSCale(2);
        }
        if (NewContactV0Contract2nd.GrossSalesTotal  != null && NewContactV0Contract2nd.GrossSalesTotal  != 0 && NewContactV0Contract2nd.TradeExpenses!= 0 && NewContactV0Contract2nd.TradeExpenses != null){
            NewContactV0Contract2nd.GrossSalesRate = (NewContactV0Contract2nd.TradeExpenses / NewContactV0Contract2nd.GrossSalesTotal  *100).SetSCale(2);
        }
        if (NewContactVFinal2nd.GrossSalesTotal  != null && NewContactVFinal2nd.GrossSalesTotal  != 0 && NewContactVFinal2nd.TradeExpenses!= 0 && NewContactVFinal2nd.TradeExpenses != null){
            NewContactVFinal2nd.GrossSalesRate = (NewContactVFinal2nd.TradeExpenses / NewContactVFinal2nd.GrossSalesTotal  *100).SetSCale(2);
        }

        //Gross Sales Rate Proform
        if (HistoricalV00Contract2nd.GrossSalesTotalProForma  != null && HistoricalV00Contract2nd.GrossSalesTotalProForma  != 0 && HistoricalV00Contract2nd.TradeExpenses!= 0 && HistoricalV00Contract2nd.TradeExpenses != null){
            HistoricalV00Contract2nd.GrossSalesRateProForma = (HistoricalV00Contract2nd.TradeExpenses / HistoricalV00Contract2nd.GrossSalesTotalProForma  *100).SetSCale(2);
        }
        if (HistoricalVFinalContract2nd.GrossSalesTotalProForma  != null && HistoricalVFinalContract2nd.GrossSalesTotalProForma  != 0 && HistoricalVFinalContract2nd.TradeExpenses!= 0 && HistoricalVFinalContract2nd.TradeExpenses != null){
            HistoricalVFinalContract2nd.GrossSalesRateProForma = (HistoricalVFinalContract2nd.TradeExpenses / HistoricalVFinalContract2nd.GrossSalesTotalProForma  *100).SetSCale(2);
        }
        
        if (NewContractV0Esitimate2nd.GrossSalesTotalProForma  != null && NewContractV0Esitimate2nd.GrossSalesTotalProForma  != 0 && NewContractV0Esitimate2nd.TradeExpenses!= 0 && NewContractV0Esitimate2nd.TradeExpenses != null){
            NewContractV0Esitimate2nd.GrossSalesRateProForma = (NewContractV0Esitimate2nd.TradeExpenses / NewContractV0Esitimate2nd.GrossSalesTotalProForma  *100).SetSCale(2);
        }
        if (NewContactV0Contract2nd.GrossSalesTotalProForma  != null && NewContactV0Contract2nd.GrossSalesTotalProForma  != 0 && NewContactV0Contract2nd.TradeExpenses!= 0 && NewContactV0Contract2nd.TradeExpenses != null){
            NewContactV0Contract2nd.GrossSalesRateProForma = (NewContactV0Contract2nd.TradeExpenses / NewContactV0Contract2nd.GrossSalesTotalProForma  *100).SetSCale(2);
        }
        if (NewContactVFinal2nd.GrossSalesTotalProForma  != null && NewContactVFinal2nd.GrossSalesTotalProForma  != 0 && NewContactVFinal2nd.TradeExpenses!= 0 && NewContactVFinal2nd.TradeExpenses != null){
            NewContactVFinal2nd.GrossSalesRateProForma = (NewContactVFinal2nd.TradeExpenses / NewContactVFinal2nd.GrossSalesTotalProForma  *100).SetSCale(2);
        }
        
        
        //InvestmentCR12
        if (HistoricalV00Contract2nd.IntakeCR12 != 0 && HistoricalV00Contract2nd.IntakeCR12!= null &&  HistoricalV00Contract2nd.TradeExpenses != 0 &&  HistoricalV00Contract2nd.TradeExpenses != null){
            HistoricalV00Contract2nd.InvestmentCR12 =  (HistoricalV00Contract2nd.TradeExpenses / HistoricalV00Contract2nd.IntakeCR12).SetSCale(2);
        }
        if (HistoricalVFinalContract2nd.IntakeCR12 != 0 && HistoricalVFinalContract2nd.IntakeCR12!= null &&  HistoricalVFinalContract2nd.TradeExpenses != 0 &&  HistoricalVFinalContract2nd.TradeExpenses != null){
            HistoricalVFinalContract2nd.InvestmentCR12 =  (HistoricalVFinalContract2nd.TradeExpenses / HistoricalVFinalContract2nd.IntakeCR12).SetSCale(2);
        }
        if (NewContractV0Esitimate2nd.IntakeCR12 != 0 && NewContractV0Esitimate2nd.IntakeCR12!= null &&  NewContractV0Esitimate2nd.TradeExpenses != 0 &&  NewContractV0Esitimate2nd.TradeExpenses != null){
            NewContractV0Esitimate2nd.InvestmentCR12 =  (NewContractV0Esitimate2nd.TradeExpenses / NewContractV0Esitimate2nd.IntakeCR12).SetSCale(2);
        }
        if (NewContactV0Contract2nd.IntakeCR12 != 0 && NewContactV0Contract2nd.IntakeCR12!= null &&  NewContactV0Contract2nd.TradeExpenses != 0 &&  NewContactV0Contract2nd.TradeExpenses != null){
            NewContactV0Contract2nd.InvestmentCR12 =  (NewContactV0Contract2nd.TradeExpenses / NewContactV0Contract2nd.IntakeCR12).SetSCale(2);
        }
        if (NewContactVFinal2nd.IntakeCR12 != 0 && NewContactVFinal2nd.IntakeCR12!= null &&  NewContactVFinal2nd.TradeExpenses != 0 &&  NewContactVFinal2nd.TradeExpenses != null){
            NewContactVFinal2nd.InvestmentCR12 =  (NewContactVFinal2nd.TradeExpenses / NewContactVFinal2nd.IntakeCR12).SetSCale(2);
        }
        
        //Fix Expense Rate
        if(HistoricalV00Contract2nd.TradeExpenses !=0 && HistoricalV00Contract2nd.TradeExpenses !=null && HistoricalV00Contract2nd.FixedExpense!=null ){
            HistoricalV00Contract2nd.FixedExpenseRate = (HistoricalV00Contract2nd.FixedExpense / HistoricalV00Contract2nd.TradeExpenses *100).SetSCale(2);  
        }
        if(HistoricalVFinalContract2nd.TradeExpenses !=0 && HistoricalVFinalContract2nd.TradeExpenses !=null && HistoricalVFinalContract2nd.FixedExpense!=null ){
            HistoricalVFinalContract2nd.FixedExpenseRate = (HistoricalVFinalContract2nd.FixedExpense / HistoricalVFinalContract2nd.TradeExpenses *100).SetSCale(2);  
        }        
        if(NewContractV0Esitimate2nd.TradeExpenses !=0 && NewContractV0Esitimate2nd.TradeExpenses !=null && NewContractV0Esitimate2nd.FixedExpense!=null ){
            NewContractV0Esitimate2nd.FixedExpenseRate = (NewContractV0Esitimate2nd.FixedExpense / NewContractV0Esitimate2nd.TradeExpenses *100).SetSCale(2);  
        }
        if(NewContactV0Contract2nd.TradeExpenses !=0 && NewContactV0Contract2nd.TradeExpenses !=null && NewContactV0Contract2nd.FixedExpense!=null ){
            NewContactV0Contract2nd.FixedExpenseRate = (NewContactV0Contract2nd.FixedExpense / NewContactV0Contract2nd.TradeExpenses *100).SetSCale(2);  
        }
        if(NewContactVFinal2nd.TradeExpenses !=0 && NewContactVFinal2nd.TradeExpenses !=null && NewContactVFinal2nd.FixedExpense!=null ){
            NewContactVFinal2nd.FixedExpenseRate = (NewContactVFinal2nd.FixedExpense / NewContactVFinal2nd.TradeExpenses *100).SetSCale(2);  
        }        
        
        
        //MarginAfterAnP
        if (HistoricalV00Contract2nd.CMTotal != null && HistoricalV00Contract2nd.TradeExpenses != null){
            HistoricalV00Contract2nd.MarginAfterAnP = HistoricalV00Contract2nd.CMTotal - HistoricalV00Contract2nd.TradeExpenses;
        }
        if (HistoricalVFinalContract2nd.CMTotal != null && HistoricalVFinalContract2nd.TradeExpenses != null){
            HistoricalVFinalContract2nd.MarginAfterAnP = HistoricalVFinalContract2nd.CMTotal - HistoricalVFinalContract2nd.TradeExpenses;
        }
        if (NewContractV0Esitimate2nd.CMTotal != null && NewContractV0Esitimate2nd.TradeExpenses != null){
            NewContractV0Esitimate2nd.MarginAfterAnP = NewContractV0Esitimate2nd.CMTotal - NewContractV0Esitimate2nd.TradeExpenses;
        }
        if (NewContactV0Contract2nd.CMTotal != null && NewContactV0Contract2nd.TradeExpenses != null){
            NewContactV0Contract2nd.MarginAfterAnP = NewContactV0Contract2nd.CMTotal - NewContactV0Contract2nd.TradeExpenses;
        }
        if (NewContactVFinal2nd.CMTotal != null && NewContactVFinal2nd.TradeExpenses != null){
            NewContactVFinal2nd.MarginAfterAnP = NewContactVFinal2nd.CMTotal - NewContactVFinal2nd.TradeExpenses;
        }

        //MarginAfterAnP Proforma
        if (HistoricalV00Contract2nd.LatestBudgetCMTotal != null && HistoricalV00Contract2nd.TradeExpenses != null){
            HistoricalV00Contract2nd.MarginAfterAnPProForma = HistoricalV00Contract2nd.LatestBudgetCMTotal - HistoricalV00Contract2nd.TradeExpenses;
        }
        if (HistoricalVFinalContract2nd.LatestBudgetCMTotal != null && HistoricalVFinalContract2nd.TradeExpenses != null){
            HistoricalVFinalContract2nd.MarginAfterAnPProForma = HistoricalVFinalContract2nd.LatestBudgetCMTotal - HistoricalVFinalContract2nd.TradeExpenses;
        }
        if (NewContractV0Esitimate2nd.LatestBudgetCMTotal != null && NewContractV0Esitimate2nd.TradeExpenses != null){
            NewContractV0Esitimate2nd.MarginAfterAnPProForma = NewContractV0Esitimate2nd.LatestBudgetCMTotal - NewContractV0Esitimate2nd.TradeExpenses;
        }
        if (NewContactV0Contract2nd.LatestBudgetCMTotal != null && NewContactV0Contract2nd.TradeExpenses != null){
            NewContactV0Contract2nd.MarginAfterAnPProForma = NewContactV0Contract2nd.LatestBudgetCMTotal - NewContactV0Contract2nd.TradeExpenses;
        }
        if (NewContactVFinal2nd.LatestBudgetCMTotal != null && NewContactVFinal2nd.TradeExpenses != null){
            NewContactVFinal2nd.MarginAfterAnPProForma = NewContactVFinal2nd.LatestBudgetCMTotal - NewContactVFinal2nd.TradeExpenses;
        }
        
        
        
        
        //MarginPerBottle
        if (HistoricalV00Contract2nd.IntakeSTD!= 0 && HistoricalV00Contract2nd.IntakeSTD != null && HistoricalV00Contract2nd.MarginAfterAnP != 0 && HistoricalV00Contract2nd.MarginAfterAnP != null){
            HistoricalV00Contract2nd.MarginPerBottle = (HistoricalV00Contract2nd.MarginAfterAnP / HistoricalV00Contract2nd.IntakeSTD).SetSCale(2);
        }
        if (HistoricalVFinalContract2nd.IntakeSTD!= 0 && HistoricalVFinalContract2nd.IntakeSTD != null && HistoricalVFinalContract2nd.MarginAfterAnP != 0 && HistoricalVFinalContract2nd.MarginAfterAnP != null){
            HistoricalVFinalContract2nd.MarginPerBottle = (HistoricalVFinalContract2nd.MarginAfterAnP / HistoricalVFinalContract2nd.IntakeSTD).SetSCale(2);
        }
        if (NewContractV0Esitimate2nd.IntakeSTD!= 0 && NewContractV0Esitimate2nd.IntakeSTD != null && NewContractV0Esitimate2nd.MarginAfterAnP != 0 && NewContractV0Esitimate2nd.MarginAfterAnP != null){
            NewContractV0Esitimate2nd.MarginPerBottle = (NewContractV0Esitimate2nd.MarginAfterAnP / NewContractV0Esitimate2nd.IntakeSTD).SetSCale(2);
        }
        if (NewContactV0Contract2nd.IntakeSTD!= 0 && NewContactV0Contract2nd.IntakeSTD != null && NewContactV0Contract2nd.MarginAfterAnP != 0 && NewContactV0Contract2nd.MarginAfterAnP != null){
            NewContactV0Contract2nd.MarginPerBottle = (NewContactV0Contract2nd.MarginAfterAnP / NewContactV0Contract2nd.IntakeSTD).SetSCale(2);
        }
        if (NewContactVFinal2nd.IntakeSTD!= 0 && NewContactVFinal2nd.IntakeSTD != null && NewContactVFinal2nd.MarginAfterAnP != 0 && NewContactVFinal2nd.MarginAfterAnP != null){
            NewContactVFinal2nd.MarginPerBottle = (NewContactVFinal2nd.MarginAfterAnP / NewContactVFinal2nd.IntakeSTD).SetSCale(2);
        }

        //MarginPerCase
        if (HistoricalV00Contract2nd.volumes!= 0 && HistoricalV00Contract2nd.volumes != null && HistoricalV00Contract2nd.MarginAfterAnP != 0 && HistoricalV00Contract2nd.MarginAfterAnP != null){
            HistoricalV00Contract2nd.MarginPerCase = (HistoricalV00Contract2nd.MarginAfterAnP / HistoricalV00Contract2nd.volumes).SetSCale(2);
        }
        if (HistoricalVFinalContract2nd.volumes!= 0 && HistoricalVFinalContract2nd.volumes != null && HistoricalVFinalContract2nd.MarginAfterAnP != 0 && HistoricalVFinalContract2nd.MarginAfterAnP != null){
            HistoricalVFinalContract2nd.MarginPerCase = (HistoricalVFinalContract2nd.MarginAfterAnP / HistoricalVFinalContract2nd.volumes).SetSCale(2);
        }
        if (NewContractV0Esitimate2nd.volumes!= 0 && NewContractV0Esitimate2nd.volumes != null && NewContractV0Esitimate2nd.MarginAfterAnP != 0 && NewContractV0Esitimate2nd.MarginAfterAnP != null){
            NewContractV0Esitimate2nd.MarginPerCase = (NewContractV0Esitimate2nd.MarginAfterAnP / NewContractV0Esitimate2nd.volumes).SetSCale(2);
        }
        if (NewContactV0Contract2nd.volumes!= 0 && NewContactV0Contract2nd.volumes != null && NewContactV0Contract2nd.MarginAfterAnP != 0 && NewContactV0Contract2nd.MarginAfterAnP != null){
            NewContactV0Contract2nd.MarginPerCase = (NewContactV0Contract2nd.MarginAfterAnP / NewContactV0Contract2nd.volumes).SetSCale(2);
        }
        if (NewContactVFinal2nd.volumes!= 0 && NewContactVFinal2nd.volumes != null && NewContactVFinal2nd.MarginAfterAnP != 0 && NewContactVFinal2nd.MarginAfterAnP != null){
            NewContactVFinal2nd.MarginPerCase = (NewContactVFinal2nd.MarginAfterAnP / NewContactVFinal2nd.volumes).SetSCale(2);
        }

        //MarginPerBottle Proforma
        if (HistoricalV00Contract2nd.IntakeSTD!= 0 && HistoricalV00Contract2nd.IntakeSTD != null && HistoricalV00Contract2nd.MarginAfterAnPProForma != 0 && HistoricalV00Contract2nd.MarginAfterAnPProForma != null){
            HistoricalV00Contract2nd.MarginPerBottleProForma = (HistoricalV00Contract2nd.MarginAfterAnPProForma / HistoricalV00Contract2nd.IntakeSTD).SetSCale(2);
        }
        if (HistoricalVFinalContract2nd.IntakeSTD!= 0 && HistoricalVFinalContract2nd.IntakeSTD != null && HistoricalVFinalContract2nd.MarginAfterAnPProForma != 0 && HistoricalVFinalContract2nd.MarginAfterAnPProForma != null){
            HistoricalVFinalContract2nd.MarginPerBottleProForma = (HistoricalVFinalContract2nd.MarginAfterAnPProForma / HistoricalVFinalContract2nd.IntakeSTD).SetSCale(2);
        }
        if (NewContractV0Esitimate2nd.IntakeSTD!= 0 && NewContractV0Esitimate2nd.IntakeSTD != null && NewContractV0Esitimate2nd.MarginAfterAnPProForma != 0 && NewContractV0Esitimate2nd.MarginAfterAnPProForma != null){
            NewContractV0Esitimate2nd.MarginPerBottleProForma = (NewContractV0Esitimate2nd.MarginAfterAnPProForma / NewContractV0Esitimate2nd.IntakeSTD).SetSCale(2);
        }
        if (NewContactV0Contract2nd.IntakeSTD!= 0 && NewContactV0Contract2nd.IntakeSTD != null && NewContactV0Contract2nd.MarginAfterAnPProForma != 0 && NewContactV0Contract2nd.MarginAfterAnPProForma != null){
            NewContactV0Contract2nd.MarginPerBottleProForma = (NewContactV0Contract2nd.MarginAfterAnPProForma / NewContactV0Contract2nd.IntakeSTD).SetSCale(2);
        }
        if (NewContactVFinal2nd.IntakeSTD!= 0 && NewContactVFinal2nd.IntakeSTD != null && NewContactVFinal2nd.MarginAfterAnPProForma != 0 && NewContactVFinal2nd.MarginAfterAnPProForma != null){
            NewContactVFinal2nd.MarginPerBottleProForma = (NewContactVFinal2nd.MarginAfterAnPProForma / NewContactVFinal2nd.IntakeSTD).SetSCale(2);
        }
        

        //ROI Intake
        if (HistoricalV00Contract2nd.CMTotal != null && HistoricalV00Contract2nd.CMTotal != 0 && HistoricalV00Contract2nd.TradeExpenses != 0 && HistoricalV00Contract2nd.TradeExpenses != null){
            HistoricalV00Contract2nd.ROIIntake = HistoricalV00Contract2nd.CMTotal / HistoricalV00Contract2nd.TradeExpenses;
        }
        if (HistoricalVFinalContract2nd.CMTotal != null && HistoricalVFinalContract2nd.CMTotal != 0 && HistoricalVFinalContract2nd.TradeExpenses != 0 && HistoricalVFinalContract2nd.TradeExpenses != null){
            HistoricalVFinalContract2nd.ROIIntake = HistoricalVFinalContract2nd.CMTotal / HistoricalVFinalContract2nd.TradeExpenses;
        }
        if (NewContractV0Esitimate2nd.CMTotal != null && NewContractV0Esitimate2nd.CMTotal != 0 && NewContractV0Esitimate2nd.TradeExpenses != 0 && NewContractV0Esitimate2nd.TradeExpenses != null){
            NewContractV0Esitimate2nd.ROIIntake = NewContractV0Esitimate2nd.CMTotal / NewContractV0Esitimate2nd.TradeExpenses;
        }
        if (NewContactV0Contract2nd.CMTotal != null && NewContactV0Contract2nd.CMTotal != 0 && NewContactV0Contract2nd.TradeExpenses != 0 && NewContactV0Contract2nd.TradeExpenses != null){
            NewContactV0Contract2nd.ROIIntake = NewContactV0Contract2nd.CMTotal / NewContactV0Contract2nd.TradeExpenses;
        }
        if (NewContactVFinal2nd.CMTotal != null && NewContactVFinal2nd.CMTotal != 0 && NewContactVFinal2nd.TradeExpenses != 0 && NewContactVFinal2nd.TradeExpenses != null){
            NewContactVFinal2nd.ROIIntake = NewContactVFinal2nd.CMTotal / NewContactVFinal2nd.TradeExpenses;
        }
        
        
        //Calculate ROIProForma = Cont. Margin before A&P from latest CM regardless FY / Trade expenses 
        if (HistoricalV00Contract2nd.LatestBudgetCMTotal!= null && HistoricalV00Contract2nd.LatestBudgetCMTotal != 0 && HistoricalV00Contract2nd.TradeExpenses != 0 && HistoricalV00Contract2nd.TradeExpenses!= null){
            HistoricalV00Contract2nd.ROIProForma = HistoricalV00Contract2nd.LatestBudgetCMTotal/ HistoricalV00Contract2nd.TradeExpenses;
        }
        if (HistoricalVFinalContract2nd.LatestBudgetCMTotal!= null && HistoricalVFinalContract2nd.LatestBudgetCMTotal != 0 && HistoricalVFinalContract2nd.TradeExpenses != 0 && HistoricalVFinalContract2nd.TradeExpenses!= null){
            HistoricalVFinalContract2nd.ROIProForma = HistoricalVFinalContract2nd.LatestBudgetCMTotal/ HistoricalVFinalContract2nd.TradeExpenses;
        }
        if (NewContractV0Esitimate2nd.LatestBudgetCMTotal!= null && NewContractV0Esitimate2nd.LatestBudgetCMTotal != 0 && NewContractV0Esitimate2nd.TradeExpenses != 0 && NewContractV0Esitimate2nd.TradeExpenses!= null){
            NewContractV0Esitimate2nd.ROIProForma = NewContractV0Esitimate2nd.LatestBudgetCMTotal/ NewContractV0Esitimate2nd.TradeExpenses;
        }
        if (NewContactV0Contract2nd.LatestBudgetCMTotal!= null && NewContactV0Contract2nd.LatestBudgetCMTotal != 0 && NewContactV0Contract2nd.TradeExpenses != 0 && NewContactV0Contract2nd.TradeExpenses!= null){
            NewContactV0Contract2nd.ROIProForma = NewContactV0Contract2nd.LatestBudgetCMTotal/ NewContactV0Contract2nd.TradeExpenses;
        }
        if (NewContactVFinal2nd.LatestBudgetCMTotal!= null && NewContactVFinal2nd.LatestBudgetCMTotal != 0 && NewContactVFinal2nd.TradeExpenses != 0 && NewContactVFinal2nd.TradeExpenses!= null){
            NewContactVFinal2nd.ROIProForma = NewContactVFinal2nd.LatestBudgetCMTotal/ NewContactVFinal2nd.TradeExpenses;
        }

        //CM/NS%
        if (HistoricalV00Contract2nd.GrossSalesTotal-HistoricalV00Contract2nd.TradeExpenses-HistoricalV00Contract2nd.ADTotal != 0)
        {
            HistoricalV00Contract2nd.CMNSRate = (HistoricalV00Contract2nd.MarginAfterAnP / (HistoricalV00Contract2nd.GrossSalesTotal-HistoricalV00Contract2nd.TradeExpenses-HistoricalV00Contract2nd.ADTotal) * 100).setScale(2);
        }
        if (HistoricalVFinalContract2nd.GrossSalesTotal-HistoricalVFinalContract2nd.TradeExpenses-HistoricalVFinalContract2nd.ADTotal != 0)
        {
            HistoricalVFinalContract2nd.CMNSRate = (HistoricalVFinalContract2nd.MarginAfterAnP / (HistoricalVFinalContract2nd.GrossSalesTotal-HistoricalVFinalContract2nd.TradeExpenses-HistoricalVFinalContract2nd.ADTotal) * 100).setScale(2);
        }
        if (NewContractV0Esitimate2nd.GrossSalesTotal-NewContractV0Esitimate2nd.TradeExpenses-NewContractV0Esitimate2nd.ADTotal != 0)
        {
            NewContractV0Esitimate2nd.CMNSRate = (NewContractV0Esitimate2nd.MarginAfterAnP / (NewContractV0Esitimate2nd.GrossSalesTotal-NewContractV0Esitimate2nd.TradeExpenses-NewContractV0Esitimate2nd.ADTotal) * 100).setScale(2);
        }
        if (NewContactV0Contract2nd.GrossSalesTotal-NewContactV0Contract2nd.TradeExpenses-NewContactV0Contract2nd.ADTotal != 0)
        {
            NewContactV0Contract2nd.CMNSRate = (NewContactV0Contract2nd.MarginAfterAnP / (NewContactV0Contract2nd.GrossSalesTotal-NewContactV0Contract2nd.TradeExpenses-NewContactV0Contract2nd.ADTotal) * 100).setScale(2);
        }
        if (NewContactVFinal2nd.GrossSalesTotal-NewContactVFinal2nd.TradeExpenses-NewContactVFinal2nd.ADTotal != 0)
        {
            NewContactVFinal2nd.CMNSRate = (NewContactVFinal2nd.MarginAfterAnP / (NewContactVFinal2nd.GrossSalesTotal-NewContactVFinal2nd.TradeExpenses-NewContactVFinal2nd.ADTotal) * 100).setScale(2);
        }

        //CM/NS% proforma
        if (HistoricalV00Contract2nd.GrossSalesTotalProForma-HistoricalV00Contract2nd.TradeExpenses-HistoricalV00Contract2nd.ADTotalProForma != 0)
        {
            HistoricalV00Contract2nd.CMNSRateProForma = (HistoricalV00Contract2nd.MarginAfterAnPProForma / (HistoricalV00Contract2nd.GrossSalesTotalProForma-HistoricalV00Contract2nd.TradeExpenses-HistoricalV00Contract2nd.ADTotalProForma) * 100).setScale(2);
        }
        if (HistoricalVFinalContract2nd.GrossSalesTotalProForma-HistoricalVFinalContract2nd.TradeExpenses-HistoricalVFinalContract2nd.ADTotalProForma != 0)
        {
            HistoricalVFinalContract2nd.CMNSRateProForma = (HistoricalVFinalContract2nd.MarginAfterAnPProForma / (HistoricalVFinalContract2nd.GrossSalesTotalProForma-HistoricalVFinalContract2nd.TradeExpenses-HistoricalVFinalContract2nd.ADTotalProForma) * 100).setScale(2);
        }
        if (NewContractV0Esitimate2nd.GrossSalesTotalProForma-NewContractV0Esitimate2nd.TradeExpenses-NewContractV0Esitimate2nd.ADTotalProForma != 0)
        {
            NewContractV0Esitimate2nd.CMNSRateProForma = (NewContractV0Esitimate2nd.MarginAfterAnPProForma / (NewContractV0Esitimate2nd.GrossSalesTotalProForma-NewContractV0Esitimate2nd.TradeExpenses-NewContractV0Esitimate2nd.ADTotalProForma) * 100).setScale(2);
        }
        if (NewContactV0Contract2nd.GrossSalesTotalProForma-NewContactV0Contract2nd.TradeExpenses-NewContactV0Contract2nd.ADTotalProForma != 0)
        {
            NewContactV0Contract2nd.CMNSRateProForma = (NewContactV0Contract2nd.MarginAfterAnPProForma / (NewContactV0Contract2nd.GrossSalesTotalProForma-NewContactV0Contract2nd.TradeExpenses-NewContactV0Contract2nd.ADTotalProForma) * 100).setScale(2);
        }
        if (NewContactVFinal2nd.GrossSalesTotalProForma-NewContactVFinal2nd.TradeExpenses-NewContactVFinal2nd.ADTotalProForma != 0)
        {
            NewContactVFinal2nd.CMNSRateProForma = (NewContactVFinal2nd.MarginAfterAnPProForma / (NewContactVFinal2nd.GrossSalesTotalProForma-NewContactVFinal2nd.TradeExpenses-NewContactVFinal2nd.ADTotalProForma) * 100).setScale(2);
        }


        System.debug(LoggingLevel.INFO, '*** HistoricalV0DomesticAfterSpendingTarget: ' + HistoricalV0DomesticAfterSpendingTarget);
        System.debug(LoggingLevel.INFO, '*** HistoricalVFinalDomesticAfterSpendingTarget: ' + HistoricalVFinalDomesticAfterSpendingTarget);
        System.debug(LoggingLevel.INFO, '*** EsitimateDomesticAfterSpendingTarget: ' + EsitimateDomesticAfterSpendingTarget);
        System.debug(LoggingLevel.INFO, '*** NewContractVFinalDomesticAfterSpendingTarget: ' + NewContractVFinalDomesticAfterSpendingTarget);
        System.debug(LoggingLevel.INFO, '*** New_VFinalDomesticAfterSpendingTarget: ' + New_VFinalDomesticAfterSpendingTarget);

        //Domestic Target - CM/Btl
        if (HistoricalV00Contract2nd.IntakeSTD != null && HistoricalV00Contract2nd.IntakeSTD != 0) {
            HistoricalV00Contract2nd.DomesticTarget = HistoricalV0DomesticAfterSpendingTarget/HistoricalV00Contract2nd.IntakeSTD;
        }
        if (HistoricalVFinalContract2nd.IntakeSTD != null && HistoricalVFinalContract2nd.IntakeSTD != 0) {
            HistoricalVFinalContract2nd.DomesticTarget = HistoricalVFinalDomesticAfterSpendingTarget/HistoricalVFinalContract2nd.IntakeSTD;
        }
        if (NewContractV0Esitimate2nd.IntakeSTD != null && NewContractV0Esitimate2nd.IntakeSTD != 0) {
            NewContractV0Esitimate2nd.DomesticTarget = EsitimateDomesticAfterSpendingTarget/NewContractV0Esitimate2nd.IntakeSTD;
        }
        if (NewContactV0Contract2nd.IntakeSTD != null && NewContactV0Contract2nd.IntakeSTD != 0) {
            NewContactV0Contract2nd.DomesticTarget = NewContractVFinalDomesticAfterSpendingTarget/NewContactV0Contract2nd.IntakeSTD;
        }
        if (NewContactVFinal2nd.IntakeSTD != null && NewContactVFinal2nd.IntakeSTD != 0) {
            NewContactVFinal2nd.DomesticTarget = New_VFinalDomesticAfterSpendingTarget/NewContactVFinal2nd.IntakeSTD;
        }
        
        //DomesticContractIndex 
        if (HistoricalV00Contract2nd.DomesticTarget != null && HistoricalV00Contract2nd.DomesticTarget != 0) {
            HistoricalV00Contract2nd.DomesticContractIndex = (HistoricalV00Contract2nd.MarginPerBottle/HistoricalV00Contract2nd.DomesticTarget * 100).setScale(2);
        }
        if (HistoricalVFinalContract2nd.DomesticTarget != null && HistoricalVFinalContract2nd.DomesticTarget != 0) {
            HistoricalVFinalContract2nd.DomesticContractIndex = (HistoricalVFinalContract2nd.MarginPerBottle/HistoricalVFinalContract2nd.DomesticTarget * 100).setScale(2);
        }
        if (NewContractV0Esitimate2nd.DomesticTarget != null && NewContractV0Esitimate2nd.DomesticTarget != 0) {
            NewContractV0Esitimate2nd.DomesticContractIndex = (NewContractV0Esitimate2nd.MarginPerBottle/NewContractV0Esitimate2nd.DomesticTarget * 100).setScale(2);
        }
        if (NewContactV0Contract2nd.DomesticTarget != null && NewContactV0Contract2nd.DomesticTarget != 0) {
            NewContactV0Contract2nd.DomesticContractIndex = (NewContactV0Contract2nd.MarginPerBottle/NewContactV0Contract2nd.DomesticTarget * 100).setScale(2);
        }
        if (NewContactVFinal2nd.DomesticTarget != null && NewContactVFinal2nd.DomesticTarget != 0) {
            NewContactVFinal2nd.DomesticContractIndex = (NewContactVFinal2nd.MarginPerBottle/NewContactVFinal2nd.DomesticTarget * 100).setScale(2);
        }

        //DomesticContractIndexProForma
        if (HistoricalV00Contract2nd.DomesticTarget != null && HistoricalV00Contract2nd.DomesticTarget != 0) {
            HistoricalV00Contract2nd.DomesticContractIndexProForma = (HistoricalV00Contract2nd.MarginPerBottleProForma/HistoricalV00Contract2nd.DomesticTarget * 100).setScale(2);
        }
        if (HistoricalVFinalContract2nd.DomesticTarget != null && HistoricalVFinalContract2nd.DomesticTarget != 0) {
            HistoricalVFinalContract2nd.DomesticContractIndexProForma = (HistoricalVFinalContract2nd.MarginPerBottleProForma/HistoricalVFinalContract2nd.DomesticTarget * 100).setScale(2);
        }
        if (NewContractV0Esitimate2nd.DomesticTarget != null && NewContractV0Esitimate2nd.DomesticTarget != 0) {
            NewContractV0Esitimate2nd.DomesticContractIndexProForma = (NewContractV0Esitimate2nd.MarginPerBottleProForma/NewContractV0Esitimate2nd.DomesticTarget * 100).setScale(2);
        }
        if (NewContactV0Contract2nd.DomesticTarget != null && NewContactV0Contract2nd.DomesticTarget != 0) {
            NewContactV0Contract2nd.DomesticContractIndexProForma = (NewContactV0Contract2nd.MarginPerBottleProForma/NewContactV0Contract2nd.DomesticTarget * 100).setScale(2);
        }
        if (NewContactVFinal2nd.DomesticTarget != null && NewContactVFinal2nd.DomesticTarget != 0) {
            NewContactVFinal2nd.DomesticContractIndexProForma = (NewContactVFinal2nd.MarginPerBottleProForma/NewContactVFinal2nd.DomesticTarget * 100).setScale(2);
        }
    }

    public void DataConsolidation(){
        //Gross Sales Rate
        if (HistoricalV00Contract.GrossSalesTotal  != null && HistoricalV00Contract.GrossSalesTotal  != 0 && HistoricalV00Contract.TradeExpenses!= 0 && HistoricalV00Contract.TradeExpenses != null){
            HistoricalV00Contract.GrossSalesRate = (HistoricalV00Contract.TradeExpenses / HistoricalV00Contract.GrossSalesTotal  *100).SetSCale(2);
        }
        if (HistoricalVFinalContract.GrossSalesTotal  != null && HistoricalVFinalContract.GrossSalesTotal  != 0 && HistoricalVFinalContract.TradeExpenses!= 0 && HistoricalVFinalContract.TradeExpenses != null){
            HistoricalVFinalContract.GrossSalesRate = (HistoricalVFinalContract.TradeExpenses / HistoricalVFinalContract.GrossSalesTotal  *100).SetSCale(2);
        }
        
       
        
        system.debug('**************debug0.1 **************');
        system.debug(NewContractV0Esitimate.TradeExpenses);
        system.debug(NewContractV0Esitimate.GrossSalesTotal);
        
        if (NewContractV0Esitimate.GrossSalesTotal  != null && NewContractV0Esitimate.GrossSalesTotal  != 0 && NewContractV0Esitimate.TradeExpenses!= 0 && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.GrossSalesRate = (NewContractV0Esitimate.TradeExpenses / NewContractV0Esitimate.GrossSalesTotal  *100).SetSCale(2);
        }
        if (NewContactV0Contract.GrossSalesTotal  != null && NewContactV0Contract.GrossSalesTotal  != 0 && NewContactV0Contract.TradeExpenses!= 0 && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.GrossSalesRate = (NewContactV0Contract.TradeExpenses / NewContactV0Contract.GrossSalesTotal  *100).SetSCale(2);
        }
        if (NewContactVFinal.GrossSalesTotal  != null && NewContactVFinal.GrossSalesTotal  != 0 && NewContactVFinal.TradeExpenses!= 0 && NewContactVFinal.TradeExpenses != null){
            NewContactVFinal.GrossSalesRate = (NewContactVFinal.TradeExpenses / NewContactVFinal.GrossSalesTotal  *100).SetSCale(2);
        }
        
        
        //InvestmentCR12
        if (HistoricalV00Contract.IntakeCR12 != 0 && HistoricalV00Contract.IntakeCR12!= null &&  HistoricalV00Contract.TradeExpenses != 0 &&  HistoricalV00Contract.TradeExpenses != null){
            HistoricalV00Contract.InvestmentCR12 =  (HistoricalV00Contract.TradeExpenses / HistoricalV00Contract.IntakeCR12).SetSCale(2);
        }
        if (HistoricalVFinalContract.IntakeCR12 != 0 && HistoricalVFinalContract.IntakeCR12!= null &&  HistoricalVFinalContract.TradeExpenses != 0 &&  HistoricalVFinalContract.TradeExpenses != null){
            HistoricalVFinalContract.InvestmentCR12 =  (HistoricalVFinalContract.TradeExpenses / HistoricalVFinalContract.IntakeCR12).SetSCale(2);
        }
        if (NewContractV0Esitimate.IntakeCR12 != 0 && NewContractV0Esitimate.IntakeCR12!= null &&  NewContractV0Esitimate.TradeExpenses != 0 &&  NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.InvestmentCR12 =  (NewContractV0Esitimate.TradeExpenses / NewContractV0Esitimate.IntakeCR12).SetSCale(2);
        }
        if (NewContactV0Contract.IntakeCR12 != 0 && NewContactV0Contract.IntakeCR12!= null &&  NewContactV0Contract.TradeExpenses != 0 &&  NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.InvestmentCR12 =  (NewContactV0Contract.TradeExpenses / NewContactV0Contract.IntakeCR12).SetSCale(2);
        }
        if (NewContactVFinal.IntakeCR12 != 0 && NewContactVFinal.IntakeCR12!= null &&  NewContactVFinal.TradeExpenses != 0 &&  NewContactVFinal.TradeExpenses != null){
            NewContactVFinal.InvestmentCR12 =  (NewContactVFinal.TradeExpenses / NewContactVFinal.IntakeCR12).SetSCale(2);
        }
        
        //Fix Expense Rate
        if(HistoricalV00Contract.TradeExpenses !=0 && HistoricalV00Contract.TradeExpenses !=null && HistoricalV00Contract.FixedExpense!=null ){
            HistoricalV00Contract.FixedExpenseRate = (HistoricalV00Contract.FixedExpense / HistoricalV00Contract.TradeExpenses *100).SetSCale(2);  
        }
        if(HistoricalVFinalContract.TradeExpenses !=0 && HistoricalVFinalContract.TradeExpenses !=null && HistoricalVFinalContract.FixedExpense!=null ){
            HistoricalVFinalContract.FixedExpenseRate = (HistoricalVFinalContract.FixedExpense / HistoricalVFinalContract.TradeExpenses *100).SetSCale(2);  
        }        
        if(NewContractV0Esitimate.TradeExpenses !=0 && NewContractV0Esitimate.TradeExpenses !=null && NewContractV0Esitimate.FixedExpense!=null ){
            NewContractV0Esitimate.FixedExpenseRate = (NewContractV0Esitimate.FixedExpense / NewContractV0Esitimate.TradeExpenses *100).SetSCale(2);  
        }
        if(NewContactV0Contract.TradeExpenses !=0 && NewContactV0Contract.TradeExpenses !=null && NewContactV0Contract.FixedExpense!=null ){
            NewContactV0Contract.FixedExpenseRate = (NewContactV0Contract.FixedExpense / NewContactV0Contract.TradeExpenses *100).SetSCale(2);  
        }
        if(NewContactVFinal.TradeExpenses !=0 && NewContactVFinal.TradeExpenses !=null && NewContactVFinal.FixedExpense!=null ){
            NewContactVFinal.FixedExpenseRate = (NewContactVFinal.FixedExpense / NewContactVFinal.TradeExpenses *100).SetSCale(2);  
        }        
        
        
        //MarginAfterAnP
        if (HistoricalV00Contract.CMTotal != null && HistoricalV00Contract.TradeExpenses != null){
            HistoricalV00Contract.MarginAfterAnP = HistoricalV00Contract.CMTotal - HistoricalV00Contract.TradeExpenses;
        }
        if (HistoricalVFinalContract.CMTotal != null && HistoricalVFinalContract.TradeExpenses != null){
            HistoricalVFinalContract.MarginAfterAnP = HistoricalVFinalContract.CMTotal - HistoricalVFinalContract.TradeExpenses;
        }
        if (NewContractV0Esitimate.CMTotal != null && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.MarginAfterAnP = NewContractV0Esitimate.CMTotal - NewContractV0Esitimate.TradeExpenses;
        }
        if (NewContactV0Contract.CMTotal != null && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.MarginAfterAnP = NewContactV0Contract.CMTotal - NewContactV0Contract.TradeExpenses;
        }
        if (NewContactVFinal.CMTotal != null && NewContactVFinal.TradeExpenses != null){
            NewContactVFinal.MarginAfterAnP = NewContactVFinal.CMTotal - NewContactVFinal.TradeExpenses;
        }
        
        
        
        
        //MarginPerBottle
        if (HistoricalV00Contract.IntakeSTD!= 0 && HistoricalV00Contract.IntakeSTD != null && HistoricalV00Contract.MarginAfterAnP != 0 && HistoricalV00Contract.MarginAfterAnP != null){
            HistoricalV00Contract.MarginPerBottle = (HistoricalV00Contract.MarginAfterAnP / HistoricalV00Contract.IntakeSTD).SetSCale(2);
        }
        if (HistoricalVFinalContract.IntakeSTD!= 0 && HistoricalVFinalContract.IntakeSTD != null && HistoricalVFinalContract.MarginAfterAnP != 0 && HistoricalVFinalContract.MarginAfterAnP != null){
            HistoricalVFinalContract.MarginPerBottle = (HistoricalVFinalContract.MarginAfterAnP / HistoricalVFinalContract.IntakeSTD).SetSCale(2);
        }
        if (NewContractV0Esitimate.IntakeSTD!= 0 && NewContractV0Esitimate.IntakeSTD != null && NewContractV0Esitimate.MarginAfterAnP != 0 && NewContractV0Esitimate.MarginAfterAnP != null){
            NewContractV0Esitimate.MarginPerBottle = (NewContractV0Esitimate.MarginAfterAnP / NewContractV0Esitimate.IntakeSTD).SetSCale(2);
        }
        if (NewContactV0Contract.IntakeSTD!= 0 && NewContactV0Contract.IntakeSTD != null && NewContactV0Contract.MarginAfterAnP != 0 && NewContactV0Contract.MarginAfterAnP != null){
            NewContactV0Contract.MarginPerBottle = (NewContactV0Contract.MarginAfterAnP / NewContactV0Contract.IntakeSTD).SetSCale(2);
        }
        if (NewContactVFinal.IntakeSTD!= 0 && NewContactVFinal.IntakeSTD != null && NewContactVFinal.MarginAfterAnP != 0 && NewContactVFinal.MarginAfterAnP != null){
            NewContactVFinal.MarginPerBottle = (NewContactVFinal.MarginAfterAnP / NewContactVFinal.IntakeSTD).SetSCale(2);
        }
        
        
        
        //ROI Intake
        if (HistoricalV00Contract.CMTotal != null && HistoricalV00Contract.CMTotal != 0 && HistoricalV00Contract.TradeExpenses != 0 && HistoricalV00Contract.TradeExpenses != null){
            HistoricalV00Contract.ROIIntake = HistoricalV00Contract.CMTotal / HistoricalV00Contract.TradeExpenses;
        }
        if (HistoricalVFinalContract.CMTotal != null && HistoricalVFinalContract.CMTotal != 0 && HistoricalVFinalContract.TradeExpenses != 0 && HistoricalVFinalContract.TradeExpenses != null){
            HistoricalVFinalContract.ROIIntake = HistoricalVFinalContract.CMTotal / HistoricalVFinalContract.TradeExpenses;
        }
        if (NewContractV0Esitimate.CMTotal != null && NewContractV0Esitimate.CMTotal != 0 && NewContractV0Esitimate.TradeExpenses != 0 && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.ROIIntake = NewContractV0Esitimate.CMTotal / NewContractV0Esitimate.TradeExpenses;
        }
        if (NewContactV0Contract.CMTotal != null && NewContactV0Contract.CMTotal != 0 && NewContactV0Contract.TradeExpenses != 0 && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.ROIIntake = NewContactV0Contract.CMTotal / NewContactV0Contract.TradeExpenses;
        }
        if (NewContactVFinal.CMTotal != null && NewContactVFinal.CMTotal != 0 && NewContactVFinal.TradeExpenses != 0 && NewContactVFinal.TradeExpenses != null){
            NewContactVFinal.ROIIntake = NewContactVFinal.CMTotal / NewContactVFinal.TradeExpenses;
        }
        
        
        //Calculate ROIProForma = Cont. Margin before A&P from latest CM regardless FY / Trade expenses 
        if (HistoricalV00Contract.LatestBudgetCMTotal!= null && HistoricalV00Contract.LatestBudgetCMTotal != 0 && HistoricalV00Contract.TradeExpenses != 0 && HistoricalV00Contract.TradeExpenses!= null){
            HistoricalV00Contract.ROIProForma = HistoricalV00Contract.LatestBudgetCMTotal/ HistoricalV00Contract.TradeExpenses;
        }
        if (HistoricalVFinalContract.LatestBudgetCMTotal!= null && HistoricalVFinalContract.LatestBudgetCMTotal != 0 && HistoricalVFinalContract.TradeExpenses != 0 && HistoricalVFinalContract.TradeExpenses!= null){
            HistoricalVFinalContract.ROIProForma = HistoricalVFinalContract.LatestBudgetCMTotal/ HistoricalVFinalContract.TradeExpenses;
        }
        if (NewContractV0Esitimate.LatestBudgetCMTotal!= null && NewContractV0Esitimate.LatestBudgetCMTotal != 0 && NewContractV0Esitimate.TradeExpenses != 0 && NewContractV0Esitimate.TradeExpenses!= null){
            NewContractV0Esitimate.ROIProForma = NewContractV0Esitimate.LatestBudgetCMTotal/ NewContractV0Esitimate.TradeExpenses;
        }
        if (NewContactV0Contract.LatestBudgetCMTotal!= null && NewContactV0Contract.LatestBudgetCMTotal != 0 && NewContactV0Contract.TradeExpenses != 0 && NewContactV0Contract.TradeExpenses!= null){
            NewContactV0Contract.ROIProForma = NewContactV0Contract.LatestBudgetCMTotal/ NewContactV0Contract.TradeExpenses;
        }
        if (NewContactVFinal.LatestBudgetCMTotal!= null && NewContactVFinal.LatestBudgetCMTotal != 0 && NewContactVFinal.TradeExpenses != 0 && NewContactVFinal.TradeExpenses!= null){
            NewContactVFinal.ROIProForma = NewContactVFinal.LatestBudgetCMTotal/ NewContactVFinal.TradeExpenses;
        }
    }
    
    
    public set<String> ListToSet(List<String>  InputList){
        set<String> ReturnSet = new set<String> ();
        for(string str: InputList){
            ReturnSet.add(str);
        }
        return ReturnSet;
    }
    
    
    public void checkUserID(){
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0)
            AdorAbove = true;
    }
    
    
    
    public void checkApprover(){
        AdorAbove = false;
        set<Id> actorIds = new set<Id>();
        for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE processinstance.status = 'Pending' AND processinstance.targetobjectid = : thisCC.id]){
            actorIds.add(piw.ActorId);
        }
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];
        if(gms.size()>0)
            AdorAbove = true;
    }

    public void BuildDataFunction(){
        System.debug(LoggingLevel.INFO, '*** : HistoricalV0List' + HistoricalV0List);
        System.debug(LoggingLevel.INFO, '*** : HistoricalVFinalList' + HistoricalVFinalList);
        System.debug(LoggingLevel.INFO, '*** : EsitimateList' + EsitimateList);
        System.debug(LoggingLevel.INFO, '*** : NewContractVFinalList' + NewContractVFinalList);
        System.debug(LoggingLevel.INFO, '*** : New_VFinalList' + New_VFinalList);

        System.debug(LoggingLevel.INFO, '*** : HistoricalV0MonthBottleMap' + HistoricalV0MonthBottleMap);
        System.debug(LoggingLevel.INFO, '*** : HistoricalV0TotalFreeMap' + HistoricalV0TotalFreeMap);
        System.debug(LoggingLevel.INFO, '*** : HistoricalV0TotalVolumeMap' + HistoricalV0TotalVolumeMap);
        System.debug(LoggingLevel.INFO, '*** : HistoricalV0TotalExpenseMap' + HistoricalV0TotalExpenseMap);


        System.debug(LoggingLevel.INFO, '*** : HistoricalVFinalMonthBottleMap' + HistoricalVFinalMonthBottleMap);
        System.debug(LoggingLevel.INFO, '*** : HistoricalVFinalTotalFreeMap' + HistoricalVFinalTotalFreeMap);
        System.debug(LoggingLevel.INFO, '*** : HistoricalVFinalTotalVolumeMap' + HistoricalVFinalTotalVolumeMap);
        System.debug(LoggingLevel.INFO, '*** : HistoricalVFinalTotalExpenseMap' + HistoricalVFinalTotalExpenseMap);

        System.debug(LoggingLevel.INFO, '*** : EsitimateMonthBottleMap' + EsitimateMonthBottleMap);
        System.debug(LoggingLevel.INFO, '*** : EsitimateTotalFreeMap' + EsitimateTotalFreeMap);
        System.debug(LoggingLevel.INFO, '*** : EsitimateTotalVolumeMap' + EsitimateTotalVolumeMap);
        System.debug(LoggingLevel.INFO, '*** : EsitimateTotalExpenseMap' + EsitimateTotalExpenseMap);

        System.debug(LoggingLevel.INFO, '*** : NewContractVFinalMonthBottleMap' + NewContractVFinalMonthBottleMap);
        System.debug(LoggingLevel.INFO, '*** : NewContractVFinalTotalFreeMap' + NewContractVFinalTotalFreeMap);
        System.debug(LoggingLevel.INFO, '*** : NewContractVFinalTotalVolumeMap' + NewContractVFinalTotalVolumeMap);
        System.debug(LoggingLevel.INFO, '*** : NewContractVFinalTotalExpenseMap' + NewContractVFinalTotalExpenseMap);

        System.debug(LoggingLevel.INFO, '*** : New_VFinalMonthBottleMap' + New_VFinalMonthBottleMap);
        System.debug(LoggingLevel.INFO, '*** : New_VFinalTotalFreeMap' + New_VFinalTotalFreeMap);
        System.debug(LoggingLevel.INFO, '*** : New_VFinalTotalVolumeMap' + New_VFinalTotalVolumeMap);
        System.debug(LoggingLevel.INFO, '*** : New_VFinalTotalExpenseMap' + New_VFinalTotalExpenseMap);

        Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> result = new Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>();
        List<String> typeName  = new List<String>{'History','Esitimate','Contract','vfina'};

        for (String subBrandId : getSelectedSubBrandIds(existSubids)) {
            result.put(subBrandId, new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>());
            for (String key : typeName) {
                Boolean  isAdd = false;
                result.get(subBrandId).put(key,new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd());
                if(key == 'History'){
                    for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd hisAcct : HistoricalVFinalList){
                        if(hisAcct.subBrandId == subBrandId || Test.isRunningTest()){
                            // if(HistoricalVFinalTotalVolumeMap.get(subBrandId) != null && HistoricalVFinalTotalVolumeMap.get(subBrandId) != 0){
                            //     hisAcct.tradeExpensePerBottle2nd = HistoricalVFinalTotalExpenseMap.get(subBrandId)/HistoricalVFinalTotalVolumeMap.get(subBrandId);
                            // }
                            if(!HistoricalVFinalMonthBottleMap.isEmpty()){
                                hisAcct.monthlyVolumeSTD  = HistoricalVFinalMonthBottleMap.get(subBrandId);
                            }
                            if(!HistoricalVFinalTotalVolumeMap.isEmpty() && HistoricalVFinalTotalVolumeMap.get(subBrandId) != null && HistoricalVFinalTotalVolumeMap.get(subBrandId) != 0){
                                hisAcct.BRSFPerTradeExpense = HistoricalVFinalTotalFreeMap.get(subBrandId)/HistoricalVFinalTotalVolumeMap.get(subBrandId);
                                hisAcct.tradeExpenseByPSFModule  = null;
                                hisAcct.tradeExpenseByFXModule = null;
                                hisAcct.VECPerTradeExpense = 0;
                                hisAcct.fixCostPerTradeExpense = 0;
                                hisAcct.PSFPerTradeExpense = 0;
                            }
                            else {
                                hisAcct.BRSFPerTradeExpense = 0;
                                hisAcct.tradeExpenseByPSFModule  = null;
                                hisAcct.tradeExpenseByFXModule = null;
                                hisAcct.VECPerTradeExpense = 0;
                                hisAcct.fixCostPerTradeExpense = 0;
                                hisAcct.PSFPerTradeExpense = 0;
                            }
                            if(!HistoricalVFinalTotalVolumeMap.isEmpty()){
                                hisAcct.volumeSTD = HistoricalVFinalTotalVolumeMap.get(subBrandId) != null ? HistoricalVFinalTotalVolumeMap.get(subBrandId) : 0;
                                if (HistoricalVFinalContract2nd.IntakeSTD != null && HistoricalVFinalContract2nd.IntakeSTD != 0) {
                                    hisAcct.propByStdTotal = hisAcct.volumeSTD/HistoricalVFinalContract2nd.IntakeSTD;
                                }
                            }
                            if(!HistoricalVFinalTotalExpenseMap.isEmpty()){
                                Decimal BRSFAmountTemp = HistoricalVFinalTotalExpenseMap.get(subBrandId) != null ? HistoricalVFinalTotalExpenseMap.get(subBrandId) : 0;
                                hisAcct.BRSFAmount = BRSFAmountTemp.setScale(4);
                                hisAcct.BRSFGap = 0;
                                hisAcct.PSFGap = 0;
                                hisAcct.PSFAmount = 0;
                                hisAcct.VECGap = 0;
                                hisAcct.tradeExpenseByPSFModule  = null;
                                hisAcct.tradeExpenseByFXModule = null;
                                hisAcct.VECAmount = 0;
                                hisAcct.fixCostTradeExpense = 0;
                            }
                            hisAcct.MarginPerBottle = (hisAcct.CMBeforeSpending * hisAcct.factor9L/9- hisAcct.tradeExpensePerBottle2nd).setScale(4) ;
                            if (hisAcct.DomesticCMAfterSpending != null && hisAcct.DomesticCMAfterSpending != 0) {
                               hisAcct.DomesticContractIndex = (hisAcct.MarginPerBottle / (hisAcct.DomesticCMAfterSpending * hisAcct.factor9L/9) * 100).setScale(2); 
                               hisAcct.GapWithDomesticIndexTarget = hisAcct.DomesticContractIndex - hisAcct.DomesticIndexTarget;
                            }

                            // if (hisAcct.volumeSTD > 0)
                            // {
                                hisAcct.GapWithDomesticIndexTarget = hisAcct.DomesticContractIndex - hisAcct.DomesticIndexTarget;
                            //}
                            
                            // if (hisAcct.tradeExpensePerBottle2nd > 0)
                            // {
                                hisAcct.GapWithDomesticInvestment = hisAcct.tradeExpensePerBottle2nd - (hisAcct.DomesticInvestment * hisAcct.factor9L/9).setScale(4);
                            // }

                            result.get(subBrandId).put(key,hisAcct);
                        }
                    }
                }
                if(key == 'Esitimate'){
                    for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd estAcct : EsitimateList){
                        if(estAcct.subBrandId == subBrandId || Test.isRunningTest()){
                            // if(EsitimateTotalVolumeMap.get(subBrandId) != null && EsitimateTotalVolumeMap.get(subBrandId) != 0){
                            //     estAcct.tradeExpensePerBottle2nd = EsitimateTotalExpenseMap.get(subBrandId)/EsitimateTotalVolumeMap.get(subBrandId);
                            // }
                            if(!EsitimateMonthBottleMap.isEmpty()){
                                estAcct.monthlyVolumeSTD  = EsitimateMonthBottleMap.get(subBrandId);
                            }
                            if(!EsitimateTotalVolumeMap.isEmpty() && EsitimateTotalVolumeMap.get(subBrandId) != null && EsitimateTotalVolumeMap.get(subBrandId) != 0){
                                estAcct.BRSFPerTradeExpense = EsitimateTotalFreeMap.get(subBrandId)/EsitimateTotalVolumeMap.get(subBrandId);
                                estAcct.tradeExpenseByPSFModule  = null;
                                estAcct.tradeExpenseByFXModule = null;
                                estAcct.VECPerTradeExpense = 0;
                                estAcct.fixCostPerTradeExpense = 0;
                                estAcct.PSFPerTradeExpense = 0;
                            }
                            else {
                                estAcct.BRSFPerTradeExpense =0;
                                estAcct.tradeExpenseByPSFModule  = null;
                                estAcct.tradeExpenseByFXModule = null;
                                estAcct.VECPerTradeExpense = 0;
                                estAcct.fixCostPerTradeExpense = 0;
                                estAcct.PSFPerTradeExpense = 0;
                            }
                            if(!EsitimateTotalVolumeMap.isEmpty()){
                                estAcct.volumeSTD = EsitimateTotalVolumeMap.get(subBrandId) != null ? EsitimateTotalVolumeMap.get(subBrandId) : 0;
                                if (NewContractV0Esitimate2nd.IntakeSTD != null && NewContractV0Esitimate2nd.IntakeSTD != 0) {
                                    estAcct.propByStdTotal = estAcct.volumeSTD/NewContractV0Esitimate2nd.IntakeSTD;
                                }
                            }

                            if(!EsitimateTotalExpenseMap.isEmpty()){
                                Decimal BRSFAmountTemp = EsitimateTotalExpenseMap.get(subBrandId) != null ? EsitimateTotalExpenseMap.get(subBrandId) : 0;
                                estAcct.BRSFAmount = BRSFAmountTemp.setScale(4);
                                estAcct.BRSFGap = 0;
                                estAcct.PSFGap = 0;
                                estAcct.PSFAmount = 0;
                                estAcct.VECGap = 0;
                                estAcct.tradeExpenseByPSFModule  = null;
                                estAcct.tradeExpenseByFXModule = null;
                                estAcct.VECAmount = 0;
                                estAcct.fixCostTradeExpense = 0;
                            }
                            estAcct.MarginPerBottle = (estAcct.CMBeforeSpending * estAcct.factor9L/9- estAcct.tradeExpensePerBottle2nd).setScale(4) ;
                            if (estAcct.DomesticCMAfterSpending != null && estAcct.DomesticCMAfterSpending != 0) {
                               estAcct.DomesticContractIndex = (estAcct.MarginPerBottle / (estAcct.DomesticCMAfterSpending * estAcct.factor9L/9) * 100).setScale(2); 
                            }

                            // if (estAcct.volumeSTD > 0)
                            // {
                                estAcct.GapWithDomesticIndexTarget = estAcct.DomesticContractIndex - estAcct.DomesticIndexTarget;
                            // }
                            
                            // if (estAcct.tradeExpensePerBottle2nd > 0)
                            // {
                                estAcct.GapWithDomesticInvestment = estAcct.tradeExpensePerBottle2nd - (estAcct.DomesticInvestment * estAcct.factor9L/9).setScale(4);
                            // }

                            result.get(subBrandId).put(key,estAcct);
                        }
                    }
                }
                if(key == 'Contract'){
                    for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd conAcct : NewContractVFinalList){
                        if(conAcct.subBrandId == subBrandId || Test.isRunningTest()){
                            // if(NewContractVFinalTotalVolumeMap.get(subBrandId) != null && NewContractVFinalTotalVolumeMap.get(subBrandId) != 0){
                            //     conAcct.tradeExpensePerBottle2nd = NewContractVFinalTotalExpenseMap.get(subBrandId)/NewContractVFinalTotalVolumeMap.get(subBrandId);
                            // }
                            if(!NewContractVFinalMonthBottleMap.isEmpty()){
                                conAcct.monthlyVolumeSTD  = NewContractVFinalMonthBottleMap.get(subBrandId);
                            }
                            if(!NewContractVFinalTotalVolumeMap.isEmpty() && NewContractVFinalTotalVolumeMap.get(subBrandId) != null && NewContractVFinalTotalVolumeMap.get(subBrandId) != 0){
                                conAcct.BRSFPerTradeExpense = NewContractVFinalTotalFreeMap.get(subBrandId)/NewContractVFinalTotalVolumeMap.get(subBrandId);
                                conAcct.tradeExpenseByPSFModule  = null;
                                conAcct.tradeExpenseByFXModule = null;
                                conAcct.VECPerTradeExpense = 0;
                                conAcct.fixCostPerTradeExpense = 0;
                                conAcct.PSFPerTradeExpense = 0;
                            } else {
                                conAcct.BRSFPerTradeExpense =0;
                                conAcct.tradeExpenseByPSFModule  = null;
                                conAcct.tradeExpenseByFXModule = null;
                                conAcct.VECPerTradeExpense = 0;
                                conAcct.fixCostPerTradeExpense = 0;
                                conAcct.PSFPerTradeExpense = 0;
                            }
                            if(!NewContractVFinalTotalVolumeMap.isEmpty()){
                                conAcct.volumeSTD = NewContractVFinalTotalVolumeMap.get(subBrandId) != null ? NewContractVFinalTotalVolumeMap.get(subBrandId) : 0;
                                if (NewContactV0Contract2nd.IntakeSTD != null && NewContactV0Contract2nd.IntakeSTD != 0) {
                                    conAcct.propByStdTotal = conAcct.volumeSTD/NewContactV0Contract2nd.IntakeSTD;
                                }
                            }

                            if(!NewContractVFinalTotalExpenseMap.isEmpty()){
                                Decimal BRSFAmountTemp = NewContractVFinalTotalExpenseMap.get(subBrandId) != null ? NewContractVFinalTotalExpenseMap.get(subBrandId) : 0;
                                conAcct.BRSFAmount = BRSFAmountTemp.setScale(4);
                                conAcct.BRSFGap = 0;
                                conAcct.PSFGap = 0;
                                conAcct.PSFAmount = 0;
                                conAcct.VECGap = 0;
                                conAcct.tradeExpenseByPSFModule  = null;
                                conAcct.tradeExpenseByFXModule = null;
                                conAcct.VECAmount = 0;
                                conAcct.fixCostTradeExpense = 0;
                            }
                            conAcct.MarginPerBottle = (conAcct.CMBeforeSpending * conAcct.factor9L/9- conAcct.tradeExpensePerBottle2nd).setScale(4) ;
                            if (conAcct.DomesticCMAfterSpending != null && conAcct.DomesticCMAfterSpending != 0) {
                               conAcct.DomesticContractIndex = (conAcct.MarginPerBottle / (conAcct.DomesticCMAfterSpending * conAcct.factor9L/9) * 100).setScale(2); 
                            }

                            // if (conAcct.volumeSTD > 0)
                            // {
                                conAcct.GapWithDomesticIndexTarget = conAcct.DomesticContractIndex - conAcct.DomesticIndexTarget;
                            // }
                            
                            // if (conAcct.tradeExpensePerBottle2nd > 0)
                            // {
                                conAcct.GapWithDomesticInvestment = conAcct.tradeExpensePerBottle2nd - (conAcct.DomesticInvestment * conAcct.factor9L/9).setScale(4);
                            // }
                            System.debug(LoggingLevel.INFO, '*** conAcct.DomesticContractIndex: ' + conAcct.DomesticContractIndex);
                            System.debug(LoggingLevel.INFO, '*** conAcct.GapWithDomesticInvestment: ' + conAcct.GapWithDomesticInvestment);
                            result.get(subBrandId).put(key,conAcct);
                        }
                    }
                }
                if(key == 'vfina'){
                    for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd vfAcct : New_VFinalList){
                        if(vfAcct.subBrandId == subBrandId || Test.isRunningTest()){
                            // if(New_VFinalTotalVolumeMap.get(subBrandId) != null && New_VFinalTotalVolumeMap.get(subBrandId) != 0){
                            //     vfAcct.tradeExpensePerBottle2nd = New_VFinalTotalExpenseMap.get(subBrandId)/New_VFinalTotalVolumeMap.get(subBrandId);
                            // }
                            if(!New_VFinalMonthBottleMap.isEmpty()){
                                vfAcct.monthlyVolumeSTD  = New_VFinalMonthBottleMap.get(subBrandId);
                            }
                            if(!New_VFinalTotalVolumeMap.isEmpty() && New_VFinalTotalVolumeMap.get(subBrandId) != null && New_VFinalTotalVolumeMap.get(subBrandId) != 0){
                                vfAcct.BRSFPerTradeExpense = New_VFinalTotalFreeMap.get(subBrandId)/New_VFinalTotalVolumeMap.get(subBrandId);
                                vfAcct.tradeExpenseByPSFModule  = null;
                                vfAcct.tradeExpenseByFXModule = null;
                                vfAcct.VECPerTradeExpense = 0;
                                vfAcct.fixCostPerTradeExpense = 0;
                                vfAcct.PSFPerTradeExpense = 0;
                           }else {
                                vfAcct.BRSFPerTradeExpense =0;
                                vfAcct.tradeExpenseByPSFModule  = null;
                                vfAcct.tradeExpenseByFXModule = null;
                                vfAcct.VECPerTradeExpense = 0;
                                vfAcct.fixCostPerTradeExpense = 0;
                                vfAcct.PSFPerTradeExpense = 0;
                            }
                            if(!New_VFinalTotalVolumeMap.isEmpty()){
                                vfAcct.volumeSTD = New_VFinalTotalVolumeMap.get(subBrandId) != null ? New_VFinalTotalVolumeMap.get(subBrandId) : 0;
                                if (NewContactVFinal2nd.IntakeSTD != null && NewContactVFinal2nd.IntakeSTD != 0) {
                                    vfAcct.propByStdTotal = vfAcct.volumeSTD/NewContactVFinal2nd.IntakeSTD;
                                }
                                
                            }

                            if(!New_VFinalTotalExpenseMap.isEmpty()){
                                Decimal BRSFAmountTemp = New_VFinalTotalExpenseMap.get(subBrandId) != null ? New_VFinalTotalExpenseMap.get(subBrandId) : 0;
                                vfAcct.BRSFAmount = BRSFAmountTemp.setScale(4);
                                vfAcct.BRSFGap = 0;
                                vfAcct.PSFGap = 0;
                                vfAcct.PSFAmount = 0;
                                vfAcct.VECGap = 0;
                                vfAcct.tradeExpenseByPSFModule  = null;
                                vfAcct.tradeExpenseByFXModule = null;
                                vfAcct.VECAmount = 0;
                                vfAcct.fixCostTradeExpense = 0;
                            }
                            vfAcct.CMBeforeSpending = vfAcct.CMBeforeSpending != null ? vfAcct.CMBeforeSpending : 0;
                            vfAcct.factor9L = vfAcct.factor9L != null ? vfAcct.factor9L : 0;
                            vfAcct.tradeExpensePerBottle2nd = vfAcct.tradeExpensePerBottle2nd != null ? vfAcct.tradeExpensePerBottle2nd : 0;
                            vfAcct.MarginPerBottle = (vfAcct.CMBeforeSpending * vfAcct.factor9L/9- vfAcct.tradeExpensePerBottle2nd).setScale(4) ;
                            if (vfAcct.DomesticCMAfterSpending != null && vfAcct.DomesticCMAfterSpending != 0) {
                               vfAcct.DomesticContractIndex = (vfAcct.MarginPerBottle / (vfAcct.DomesticCMAfterSpending * vfAcct.factor9L/9) * 100).setScale(2); 
                            }

                            // if (vfAcct.volumeSTD > 0)
                            // {
                                vfAcct.DomesticContractIndex = vfAcct.DomesticContractIndex != null ? vfAcct.DomesticContractIndex : 0;
                                vfAcct.DomesticIndexTarget = vfAcct.DomesticIndexTarget != null ? vfAcct.DomesticIndexTarget : 0;
                                vfAcct.GapWithDomesticIndexTarget = vfAcct.DomesticContractIndex - vfAcct.DomesticIndexTarget;
                            // }
                            
                            // if (vfAcct.tradeExpensePerBottle2nd > 0)
                            // {
                                vfAcct.DomesticInvestment = vfAcct.DomesticInvestment != null ? vfAcct.DomesticInvestment : 0;
                                vfAcct.GapWithDomesticInvestment = vfAcct.tradeExpensePerBottle2nd - (vfAcct.DomesticInvestment * vfAcct.factor9L/9).setScale(4);
                            // }
                            result.get(subBrandId).put(key,vfAcct);
                        }
                    }
                }
            }
        }
        // Remove empty map
        for (String subBrandId : result.keySet()) {
            Boolean allEmpty = true;

            for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd breakdown : result.get(subBrandId).values()) {
                if (breakdown.subBrandId != null) {
                    allEmpty = false;
                }
            }
            if (allEmpty) {
                result.remove(subBrandId);
            }
        }
        
        System.debug(LoggingLevel.INFO, '*** result: ' + result);
        investmentBySubBrandByContractBySubBrand = investmentBySubBrandByContractByLastVolume(result);

        Map<String, String> newIndexTargetMap = new Map<String, String>();
        for (String key : result.keySet()) {
            Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> resultMap = new Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>();
            resultMap = result.get(key);
            
            
            System.debug(LoggingLevel.INFO, '*** resultMap: ' + resultMap);
            
            if (resultMap.containsKey('Esitimate') && resultMap.get('Esitimate').DomesticIndexTarget != null && resultMap.get('Esitimate').DomesticIndexTarget != 0.0) {
                newIndexTargetMap.put(key, String.valueOf(resultMap.get('Esitimate').DomesticIndexTarget.setScale(0)));
            }else if (resultMap.containsKey('Contract') && resultMap.get('Contract').DomesticIndexTarget != null && resultMap.get('Contract').DomesticIndexTarget != 0.0) {
                newIndexTargetMap.put(key, String.valueOf(resultMap.get('Contract').DomesticIndexTarget.setScale(0)));
            }else if (resultMap.containsKey('History') && resultMap.get('History').DomesticIndexTarget != null && resultMap.get('History').DomesticIndexTarget != 0.0) {
                newIndexTargetMap.put(key, String.valueOf(resultMap.get('History').DomesticIndexTarget.setScale(0))) ;
            }else if (resultMap.containsKey('vfina') && resultMap.get('vfina').DomesticIndexTarget != null && resultMap.get('vfina').DomesticIndexTarget != 0.0) {
                newIndexTargetMap.put(key, String.valueOf(resultMap.get('vfina').DomesticIndexTarget.setScale(0)));
            }else {
                newIndexTargetMap.put(key, '');
            }
            
        }

        IndexTargetMap = newIndexTargetMap;
        System.debug(LoggingLevel.INFO, '*** IndexTargetMap: ' + IndexTargetMap);
    }
    public Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> investmentBySubBrandByContractByLastVolume(
        Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> ActualPerformanceSortBRSFAmtMap){

        Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> result = new Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>();
        Map<String,String> subBrandValueMap = new Map<String,String>();

        subBrandValueMap = eNgetSelectedSubBrandName();


        List<Decimal> sortESCLsit = new List<Decimal>();
        List<Decimal> sortDESCLsit = new List<Decimal>();
        String nineId = getSelectedNineIds();
        for(String key : ActualPerformanceSortBRSFAmtMap.keySet()){
            if(key != nineId){
                sortESCLsit.add(ActualPerformanceSortBRSFAmtMap.get(key).get('Esitimate').volumeSTD);
            }else{
                result.put(999,ActualPerformanceSortBRSFAmtMap.get(key));
                subEnNameMap.put(999,'999');
            }

        }
        sortESCLsit.sort();
        System.debug('sortESCLsit'+sortESCLsit);
        // DESC
        for(Integer i = sortESCLsit.size()-1; i>=0;i--){
            sortDESCLsit.add(sortESCLsit.get(i));
        }

        Decimal i = 0;
        Set<String> checkSet = new Set<String>();
        
        for(Decimal dec : sortDESCLsit){
            Decimal num = i++;
            for(String key : ActualPerformanceSortBRSFAmtMap.keySet()){
                if(ActualPerformanceSortBRSFAmtMap.get(key).get('Esitimate').volumeSTD == dec && !checkSet.contains(key) && key != nineId){
                    result.put(num,ActualPerformanceSortBRSFAmtMap.get(key));
                    subEnNameMap.put(num,subBrandValueMap.get(key));
                    checkSet.add(key);
                    break;
                }
            }
        }
        System.debug('result'+result);
        return result;
    }

    public Set<Id> getSelectedSubBrandIds(Set<String> existSubids){
        return (new Map<Id, ASI_MFM_Sub_brand__c>([SELECT Id  FROM ASI_MFM_Sub_brand__c where id in :existSubids]).keySet());
    }

    public void DataScreen(){

        Set<String> removeSBGNameSet = new Set<String>();
        for(String SBGName: byCategoryMap.keySet()){
            Boolean isHave = false;

            if(HistoricalV00Contract2nd.CategoryMap==null || !HistoricalV00Contract2nd.CategoryMap.containskey(SBGName)){
                HistoricalV00Contract2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }

            if(HistoricalVFinalContract2nd.CategoryMap==null || !HistoricalVFinalContract2nd.CategoryMap.containskey(SBGName)){
                HistoricalVFinalContract2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }

            if(NewContractV0Esitimate2nd.CategoryMap==null || !NewContractV0Esitimate2nd.CategoryMap.containskey(SBGName)){
                NewContractV0Esitimate2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }
            if(NewContactV0Contract2nd.CategoryMap==null || !NewContactV0Contract2nd.CategoryMap.containskey(SBGName)){
                NewContactV0Contract2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }
            if (NewContactVFinal2nd.CategoryMap==null || !NewContactVFinal2nd.CategoryMap.containskey(SBGName)) {
                NewContactVFinal2nd.CategoryMap.put(SBGName,0.0);
            }else {
                isHave=true;
            }

            if (!isHave) {
                removeSBGNameSet.add(SBGName);
                HistoricalV00Contract2nd.CategoryMap.remove(SBGName);
                HistoricalVFinalContract2nd.CategoryMap.remove(SBGName);
                NewContractV0Esitimate2nd.CategoryMap.remove(SBGName);
                NewContactV0Contract2nd.CategoryMap.remove(SBGName);
                NewContactVFinal2nd.CategoryMap.remove(SBGName);
            } 
            // else {
            //     if(HistoricalContractCompared2nd.CategoryMap==null || !HistoricalContractCompared2nd.CategoryMap.containskey(SBGName)){
            //         Decimal ComparedRate=0;
            //         if(HistoricalV00Contract2nd.CategoryMap.get(SBGName)!=0){
            //             ComparedRate=((HistoricalVFinalContract2nd.CategoryMap.get(SBGName)-HistoricalV00Contract2nd.CategoryMap.get(SBGName))*100)/HistoricalV00Contract2nd.CategoryMap.get(SBGName);
            //         }
            //         HistoricalContractCompared2nd.CategoryMap.put(SBGName,ComparedRate);
            //     }
            // }
            if (!removeSBGNameSet.isEmpty()) {
                for (String categoryName : removeSBGNameSet){
                    byCategoryMap.remove(categoryName);
                }
            }
        }
    }

    public Map<String, String> eNgetSelectedSubBrandName(){
        Map<String, String> subbrandNameMap = new Map<String, String>();
        for(ASI_MFM_Sub_brand__c amsb : [SELECT Id, Name,ASI_HK_CRM_English_Name__c FROM ASI_MFM_Sub_brand__c WHERE RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand' OR Name = '999']){
            subbrandNameMap.put(amsb.Id, amsb.ASI_HK_CRM_English_Name__c);
        }
        return subbrandNameMap;
    }

    public static String getSelectedNineIds(){
        List<ASI_MFM_Sub_brand__c> amsbList = [SELECT Id  FROM ASI_MFM_Sub_brand__c WHERE Name = :'999'];
        if(!amsbList.isEmpty()){
            return amsbList[0].Id;
        }else{
            return '';
        }
    }
}