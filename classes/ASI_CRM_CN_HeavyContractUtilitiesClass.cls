/* Filename:    ASI_CRM_CN_HeavyContractUtilitiesClass.cls
* Author:      Laputa
* Purpose:     CRM 4.2 CN help Class
* History  : Compare ASI_CRM_CN_ContractEmailCtrl  && ASI_CRM_CN_ContractEmail_Cmpnt
* -----------------------------------------------------------------------------
* 2017-07-29   Laputa      Created
*/

public class ASI_CRM_CN_HeavyContractUtilitiesClass {

    /**
     * Key is the same as the key in FI.SubBrandGradeMap. Use values to display in PDF
     */
    public static Map<String, String> SUB_BRAND_GRADE_GROUPING_MAP = new Map<String, String>{
        '1. Standard + Premium 标准档 + 高档' => 'Standard + Premium 标准档 + 高档',
        '2. Super Premium 超高档' => 'Super Premium 超高档',
        '3. Ultra Premium 特级高档' => 'Ultra Premium 特级高档',
        '4. Prestige + Ultra Prestige 奢华档 + 特级奢华档' => 'Prestige + Ultra Prestige 奢华档 + 特级奢华档'
    };

    public static Map<String, String> SUB_BRAND_CATEGORY_GROUPING_MAP2ND = new Map<String, String>{
        '干邑' => 'Cognac干邑',
        '威士忌' => 'Whisky威士忌',
        '白色烈酒' => 'White Spirits白色烈酒',
        '香槟' => 'Champagne香槟',
        '红酒' => 'Wine红酒'
    };


    //'Financial Indicator' Data structure for checking point // PDF // Email // ROI  //  √
    public class FinancialIndicator {
        public Decimal Volumes  {set;get;} {Volumes=0.0;}  //Intake(9L)
        public Decimal IntakeSTD  {set;get;} {IntakeSTD=0.0;}  //Intake(std. btl) 

        public Map<String,Decimal> SubBrandGradeMap  {set;get;} {SubBrandGradeMap = new Map<String,Decimal>();}  // For PDF
        public Map<String,Decimal> SubBrandGradeGrouping  {set;get;} {SubBrandGradeGrouping = new Map<String,Decimal>();}  //For Check point
        public Map<String,Decimal> CategoryMap  {set;get;} {CategoryMap = new Map<String,Decimal>();}
        public Map<String,ContractLine> ContractLineMap  {set;get;} {ContractLineMap = new Map<String,ContractLine>();}
        public Map<String,ContractLine> FixedExpensesMap  {set;get;} {FixedExpensesMap = new Map<String,ContractLine>();}
        public Map<String,ContractLine> VariableExpensesMap  {set;get;} {VariableExpensesMap = new Map<String,ContractLine>();}
        public List<TradeExpenseBreakdown> TradeExpenseBySubBrand  {set;get;} {TradeExpenseBySubBrand = new List<TradeExpenseBreakdown>();}

        public Decimal TradeExpenses  {set;get;} {TradeExpenses=0.0;}
        public Decimal GrossSalesTotal  {set;get;} {GrossSalesTotal=0.0;}
        public Decimal GrossSalesRate  {set;get;} {GrossSalesRate=0.0;}
        public Decimal VariableExpense  {set;get;} {VariableExpense=0.0;}  // Theoretical Amount in PO Modification Data
        public Decimal FixedExpense  {set;get;} {FixedExpense=0.0;}
        public Decimal FixedExpenseRate  {set;get;} {FixedExpenseRate=0.0;}
        public Decimal IntakeCR12  {set;get;} {IntakeCR12=0.0;}   //Intake (CR12)
        public Decimal CMTotal {set;get;} {CMTotal=0.0;}
        public Decimal InvestmentCR12  {set;get;} {InvestmentCR12=0.0;}// Investment per CR12 eq btl

        public Decimal LatestBudgetCMTotal  {set;get;} {LatestBudgetCMTotal=0.0;}

        public Decimal MarginAfterAnP  {set;get;} {MarginAfterAnP=0.0;}
        public Decimal MarginPerBottle  {set;get;} {MarginPerBottle=0.0;}
        public Decimal ROIIntake  {set;get;} {ROIIntake=0.0;}
        public Decimal ROIActual  {set;get;} {ROIActual=0.0;}
        public Decimal ROIProForma  {set;get;} {ROIProForma=0.0;}

        public Decimal GrossSalesRateExcl  {set;get;} {GrossSalesRateExcl=0.0;}
        public Decimal ROIIntakeExcl  {set;get;} {ROIIntakeExcl=0.0;}
        public Decimal ROIProFormaExcl  {set;get;} {ROIProFormaExcl=0.0;}

        public Decimal BCRate  {set;get;} {BCRate=0.0;}


        public Decimal TotalBCRate  {set;get;} {TotalBCRate=0.0;}  // Total BC% = (Green Cap + Empty Btl) / Intake;
        public Decimal NetBCRate  {set;get;} {NetBCRate=0.0;}  //Net BC% = (Green Cap + Empty Btl – Black / Grey Caps) / Intake (without coefficient); Only for historical vFINAL

        public Decimal TotalMBCRate  {set;get;} {TotalMBCRate=0.0;}
        public Decimal NetMBCRate  {set;get;} {NetMBCRate=0.0;}

        public Set<Id> OutletSet {set;get;} {OutletSet=new Set<Id>();}
        public Date POStartDate {set;get;} {POStartDate=Date.today();}
        public Date POEndDate {set;get;} {POEndDate=Date.today();}
        public String ContractId {set;get;} {ContractId='';}
        public String BRSFMethodologyName {set;get;} {BRSFMethodologyName='';}
        public String PSFMethodologyName {set;get;} {PSFMethodologyName='';}
        public String PSFVolumeBase {set;get;} {PSFVolumeBase='';}

        public Integer NoOfMonths {set;get;} {NoOfMonths=1;}
        public String AddOnString {set;get;} {AddOnString ='';}

        public String CMId  {set;get;} {CMId =' ';}
        public String GSId  {set;get;} {GSId =' ';}


        //add by BLS 20200323 for Heavy Contract ON 2nd KPI begin
        // public Decimal GrossSalesTotalProForma {set;get;} {GrossSalesTotalProForma=0.0;}
        // public Decimal GrossSalesRateProForma  {set;get;} {GrossSalesRateProForma=0.0;}
        // public Decimal MarginAfterAnPProForma {set;get;} {MarginAfterAnPProForma=0.0;}  //CMTotalProForma - TradeExpenses
        // public Decimal MarginPerBottleProForma {set;get;} {MarginPerBottleProForma=0.0;} // MarginAfterAnPProForma/IntakeSTD
        // public Decimal ADTotal {set;get;} {ADTotal=0.0;}   //All period from contract
        // public Decimal ADTotalProForma {set;get;} {ADTotalProForma=0.0;}
        // public Decimal CMNSRate {set;get;} {CMNSRate=0.0;}         //  MarginAfterAnP/(GrossSalesTotal-ADTotal-TradeExpenses)
        // public Decimal CMNSRateProForma {set;get;} {CMNSRateProForma=0.0;} // MarginAfterAnPProForma/(GrossSalesTotalProForma-ADTotalProForma-TradeExpenses)
        // public Decimal DomesticContractIndex {set;get;} {DomesticContractIndex=0.0;} //  MarginPerBottle/DomesticTarget * 100
        // public Decimal DomesticContractIndexProForma {set;get;} {DomesticContractIndexProForma=0.0;} //MarginPerBottleProForma/DomesticTarget * 100
        // public Decimal RegionalAverageIndex {set;get;} {RegionalAverageIndex=0.0;}     //  RegionalAverageTarget/DomesticTarget * 100
        // public Decimal RegionalAverageIndexProForma {set;get;} {RegionalAverageIndexProForma=0.0;} //  RegionalAverageTarget/DomesticTarget *100  same with RegionalAverageIndex
        // public Decimal VsRegionalAverageIndex {set;get;} {VsRegionalAverageIndex=0.0;}  // DomesticContractIndex - RegionalAverageIndex
        // public Decimal VsRegionalAverageIndexProForma {set;get;} {VsRegionalAverageIndexProForma=0.0;} // DomesticContractIndexProForma - RegionalAverageIndexProForma
        // public Decimal RegionalTargetIndex {set;get;} {RegionalTargetIndex=0.0;}  //  MarginPerBottle/RegionalAverageTarget * 100
        // public Decimal RegionalTargetIndexProForma {set;get;} {RegionalTargetIndexProForma=0.0;} //MarginPerBottleProForma/RegionalAverageTarget * 100
        // public Decimal DomesticTarget {set;get;} {DomesticTarget=0.0;}
        // public Decimal RegionalAverageTarget {set;get;} {RegionalAverageTarget=0.0;}
        //add by BLS 20200323 for Heavy Contract ON 2nd KPI end

        public Map<String,String> DebugMap {set;get;} {DebugMap = new  Map<String,String>();}
        public FinancialIndicator(){
        }
    }

    //add by BLS 20200323 for Heavy Contract ON 2nd KPI begin
    public class FinancialIndicator2nd {
        public Decimal Volumes  {set;get;} {Volumes=0.0;}  //Intake(9L)
        public Decimal IntakeSTD  {set;get;} {IntakeSTD=0.0;}  //Intake(std. btl) 

        public Map<String,Decimal> SubBrandGradeMap  {set;get;} {SubBrandGradeMap = new Map<String,Decimal>();}  // For PDF
        public Map<String,Decimal> SubBrandGradeGrouping  {set;get;} {SubBrandGradeGrouping = new Map<String,Decimal>();}  //For Check point
        public Map<String,Decimal> CategoryMap  {set;get;} {CategoryMap = new Map<String,Decimal>();}
        public Map<String,ContractLine> ContractLineMap  {set;get;} {ContractLineMap = new Map<String,ContractLine>();}
        public Map<String,ContractLine> FixedExpensesMap  {set;get;} {FixedExpensesMap = new Map<String,ContractLine>();}
        public Map<String,ContractLine> VariableExpensesMap  {set;get;} {VariableExpensesMap = new Map<String,ContractLine>();}
        public List<TradeExpenseBreakdown2nd> TradeExpenseBySubBrand  {set;get;} {TradeExpenseBySubBrand = new List<TradeExpenseBreakdown2nd>();}

        public Decimal TradeExpenses  {set;get;} {TradeExpenses=0.0;}
        public Decimal GrossSalesTotal  {set;get;} {GrossSalesTotal=0.0;}
        public Decimal GrossSalesRate  {set;get;} {GrossSalesRate=0.0;}
        public Decimal VariableExpense  {set;get;} {VariableExpense=0.0;}  // Theoretical Amount in PO Modification Data
        public Decimal FixedExpense  {set;get;} {FixedExpense=0.0;}
        public Decimal FixedExpenseRate  {set;get;} {FixedExpenseRate=0.0;}
        public Decimal IntakeCR12  {set;get;} {IntakeCR12=0.0;}   //Intake (CR12)
        public Decimal CMTotal {set;get;} {CMTotal=0.0;}
        public Decimal InvestmentCR12  {set;get;} {InvestmentCR12=0.0;}// Investment per CR12 eq btl

        public Decimal LatestBudgetCMTotal  {set;get;} {LatestBudgetCMTotal=0.0;}

        public Decimal MarginAfterAnP  {set;get;} {MarginAfterAnP=0.0;}
        public Decimal MarginPerBottle  {set;get;} {MarginPerBottle=0.0;}
        public Decimal ROIIntake  {set;get;} {ROIIntake=0.0;}
        public Decimal ROIActual  {set;get;} {ROIActual=0.0;}
        public Decimal ROIProForma  {set;get;} {ROIProForma=0.0;}

        public Decimal GrossSalesRateExcl  {set;get;} {GrossSalesRateExcl=0.0;}
        public Decimal ROIIntakeExcl  {set;get;} {ROIIntakeExcl=0.0;}
        public Decimal ROIProFormaExcl  {set;get;} {ROIProFormaExcl=0.0;}

        public Decimal BCRate  {set;get;} {BCRate=0.0;}


        public Decimal TotalBCRate  {set;get;} {TotalBCRate=0.0;}  // Total BC% = (Green Cap + Empty Btl) / Intake;
        public Decimal NetBCRate  {set;get;} {NetBCRate=0.0;}  //Net BC% = (Green Cap + Empty Btl – Black / Grey Caps) / Intake (without coefficient); Only for historical vFINAL

        public Decimal TotalMBCRate  {set;get;} {TotalMBCRate=0.0;}
        public Decimal NetMBCRate  {set;get;} {NetMBCRate=0.0;}

        public Set<Id> OutletSet {set;get;} {OutletSet=new Set<Id>();}
        public Date POStartDate {set;get;} {POStartDate=Date.today();}
        public Date POEndDate {set;get;} {POEndDate=Date.today();}
        public String ContractId {set;get;} {ContractId='';}
        public String BRSFMethodologyName {set;get;} {BRSFMethodologyName='';}
        public String PSFMethodologyName {set;get;} {PSFMethodologyName='';}
        public String PSFVolumeBase {set;get;} {PSFVolumeBase='';}

        public Integer NoOfMonths {set;get;} {NoOfMonths=1;}
        public String AddOnString {set;get;} {AddOnString ='';}

        public String CMId  {set;get;} {CMId =' ';}
        public String GSId  {set;get;} {GSId =' ';}


        //add by BLS 20200323 for Heavy Contract ON 2nd KPI begin
        public Decimal GrossSalesTotalProForma {set;get;} {GrossSalesTotalProForma=0.0;}
        public Decimal GrossSalesRateProForma  {set;get;} {GrossSalesRateProForma=0.0;}
        public Decimal MarginAfterAnPProForma {set;get;} {MarginAfterAnPProForma=0.0;}  //CMTotalProForma - TradeExpenses
        public Decimal MarginPerBottleProForma {set;get;} {MarginPerBottleProForma=0.0;} // MarginAfterAnPProForma/IntakeSTD
        public Decimal MarginPerCase {set;get;} {MarginPerCase=0.0;} //MarginAfterAnP/Volumes
        public Decimal ADTotal {set;get;} {ADTotal=0.0;}   //All period from contract
        public Decimal ADTotalProForma {set;get;} {ADTotalProForma=0.0;}
        public Decimal CMNSRate {set;get;} {CMNSRate=0.0;}         //  MarginAfterAnP/(GrossSalesTotal-ADTotal-TradeExpenses)
        public Decimal CMNSRateProForma {set;get;} {CMNSRateProForma=0.0;} // MarginAfterAnPProForma/(GrossSalesTotalProForma-ADTotalProForma-TradeExpenses)
        public Decimal DomesticContractIndex {set;get;} {DomesticContractIndex=0.0;} //  MarginPerBottle/DomesticTarget * 100
        public Decimal DomesticContractIndexProForma {set;get;} {DomesticContractIndexProForma=0.0;} //MarginPerBottleProForma/DomesticTarget * 100
        public Decimal RegionalAverageIndex {set;get;} {RegionalAverageIndex=0.0;}     //  RegionalAverageTarget/DomesticTarget * 100
        public Decimal RegionalAverageIndexProForma {set;get;} {RegionalAverageIndexProForma=0.0;} //  RegionalAverageTarget/DomesticTarget *100  same with RegionalAverageIndex
        public Decimal VsRegionalAverageIndex {set;get;} {VsRegionalAverageIndex=0.0;}  // DomesticContractIndex - RegionalAverageIndex
        public Decimal VsRegionalAverageIndexProForma {set;get;} {VsRegionalAverageIndexProForma=0.0;} // DomesticContractIndexProForma - RegionalAverageIndexProForma
        public Decimal RegionalTargetIndex {set;get;} {RegionalTargetIndex=0.0;}  //  MarginPerBottle/RegionalAverageTarget * 100
        public Decimal RegionalTargetIndexProForma {set;get;} {RegionalTargetIndexProForma=0.0;} //MarginPerBottleProForma/RegionalAverageTarget * 100
        public Decimal DomesticTarget {set;get;} {DomesticTarget=0.0;}
        public Decimal RegionalAverageTarget {set;get;} {RegionalAverageTarget=0.0;}
        //add by BLS 20200323 for Heavy Contract ON 2nd KPI end

        public Map<String,String> DebugMap {set;get;} {DebugMap = new  Map<String,String>();}
        public FinancialIndicator2nd(){
        }
    }

    public class ContractLine{
        public String SubBrandName {set;get;}{SubBrandName='';}
        public String SubBrandCategory {set;get;}{SubBrandCategory='';}
        public String SubBrandGrade {set;get;}{SubBrandGrade='';}
        public String strSubBrand {set;get;}{strSubBrand='';}


        public Decimal HistoricalBottles  {set;get;} {HistoricalBottles=0.0;}
        public Decimal EstimateBottles  {set;get;} {EstimateBottles=0.0;}
        public Decimal ContractBottles  {set;get;} {ContractBottles=0.0;}
        public Decimal VFinalBottles  {set;get;} {VFinalBottles=0.0;}

        public Decimal HistoricalFees  {set;get;} {HistoricalFees=0.0;}
        public Decimal EstimateFees  {set;get;} {EstimateFees=0.0;}
        public Decimal ContractFees  {set;get;} {ContractFees=0.0;}
        public Decimal VFinalFees  {set;get;} {VFinalFees=0.0;}

        public Decimal HistoricalTotalFees  {set;get;} {HistoricalTotalFees=0.0;}
        public Decimal EstimateTotalFees  {set;get;} {EstimateTotalFees=0.0;}
        public Decimal ContractTotalFees  {set;get;} {ContractTotalFees=0.0;}
        public Decimal VFinalTotalFees  {set;get;} {VFinalTotalFees=0.0;}



        //Used in Group Contract:   All period Volume in contract
        public Decimal HistoricalVolume  {set;get;} {HistoricalVolume=0.0;} // All period from contract
        public Decimal EstimateVolume {set;get;} {EstimateVolume=0.0;}
        public Decimal ContractVolume  {set;get;} {ContractVolume=0.0;}
        public Decimal VFinalVolume  {set;get;} {VFinalVolume=0.0;} //Intake (std. btl.) for full contract period




        //Following used in Group Contract:
        public Decimal HistoricalActualVolume  {set;get;} {HistoricalActualVolume=0.0;} // All period from Intake. For  Historical , all period,
        public Decimal VFinalActualVolume  {set;get;} {VFinalActualVolume=0.0;} //For New contract Vfinal,  use prorated

        //Used in Group Contract:   All period Volume in contract
        // public Decimal AllPeriodContractVolume  {set;get;} {AllPeriodContractVolume=0.0;} // All period from contract
        //Used in Group Contract:   All Contract/Estimate Total
        //public Decimal TotalAmount  {set;get;} {TotalAmount=0.0;}

        public ContractLine(){
        }
    }


    //Data Class for Sub-Brand Sales(CM/GS)
    public class subbrand_data{
        public String SubBrandId {set;get;}
        public Decimal TotalVolume {set;get;}
        public Decimal TotalEstVolume {set;get;}
        public Decimal GS {set;get;}{GS=0;}
        public Decimal CM {set;get;}{CM=0;}
        public Decimal latestBudgetCM {set;get;}{latestBudgetCM=0;}
        public Decimal period {set;get;}
        public Decimal target_vol {set;get;}{target_vol=0;}
        public Decimal actual_vol {set;get;}{actual_vol=0;}
        public Decimal actualCM {set;get;}{actualCM=0;}
        public Decimal actualGS {set;get;}{actualGS=0;}

        //add by BLS 20200323 for Heavy Contract ON 2nd KPI begin
        public Decimal AD {set;get;}{AD=0;}
        public Decimal actualAD {set;get;}{actualAD=0;}
        public Decimal latestBudgetGS {set;get;}{latestBudgetGS=0;}
        public Decimal latestBudgetAD {set;get;}{latestBudgetAD=0;}
        //add by BLS 20200323 for Heavy Contract ON 2nd KPI end

        public String year {set;get;}
        public subbrand_data(){}

    }

    public class TradeExpenseBreakdown {
        Boolean nonContract { set; get; } {
            nonContract = false;
        }
        public String subBrandId { set; get; }
        public String subBrandName { set; get; }
        public String subBrandCode { set; get; } { subBrandCode = '';}
        public String gradeId { set; get; }
        public String gradeName { set; get; }
        public String categoryId { set; get; }
        public String categoryName { set; get; }
        // Total volume in different units. Need to Project volume in PO Modi case
        public  Decimal volumeSTD { set; get; } {
            volumeSTD = 0;
        }
        public  Decimal volumeCR12 {
            set;
            get {
                return ((this.volumeSTD != null ? this.volumeSTD : 0) 
                    * (this.cr12Factor != null ? this.cr12Factor : 0)).setScale(4);
            }
        }
        public  Decimal volume9L {
            set;
            get {
                return ((this.volumeSTD != null ? this.volumeSTD : 0)
                        * (this.factor9L != null ? this.factor9L : 0) / 9).setScale(4);
            }
        }

        public  Decimal cr12Factor { set; get; } {cr12Factor = 1;}
        public  Decimal factor9L { set; get; } {
            factor9L = 1;}
        public  Decimal propByBRSFAmt { set; get; }
        public Decimal propByGrade { set; get; } {
            propByGrade = 1;}
        public Decimal propByCategory { set; get; } {
            propByCategory = 1;}
        public Decimal propByTotal { set; get; } {
            propByTotal = 1;}
        public  Decimal BRSFIncentive { set; get; } {
            BRSFIncentive = 0;
        }
        public  Decimal BRSFAmount { set; get ; } {
            BRSFAmount = 0;
        }
        // Calculate by proportion, multiple by the difference between system amount and user input amount
        public  Decimal BRSFGap { set; get; }{
            BRSFGap = 0;
        }
        public  Decimal BRSFTradeExpense {
            set;
            get {
                return ((this.BRSFAmount != null ? this.BRSFAmount : 0)
                        + (this.BRSFGap != null ? this.BRSFGap : 0)).setScale(4);
            }
        }
        public  Decimal PSFGap { set; get; } {
            PSFGap = 0;
        }
        public  Decimal PSFTradeExpense {
            set;
            get {
                this.PSFTradeExpense = 0;
                if(this.tradeExpenseByPSFModule.size() > 0 )
                {
                    for (ModuleTradeExpense moduleData : this.tradeExpenseByPSFModule) {
                        this.PSFTradeExpense += (moduleData.tradeExpense != null ? moduleData.tradeExpense : 0);
                    }
                }
                return (this.PSFTradeExpense 
                        + (this.PSFGap != null ? this.PSFGap : 0)).setScale(4);
            }
        } {
            PSFTradeExpense = 0;
        }
        public  Decimal PSFAmount {
            set;
            get {
                this.PSFAmount = 0;
                if(this.tradeExpenseByPSFModule.size() > 0)
                {
                    for (ModuleTradeExpense moduleData : this.tradeExpenseByPSFModule) {
                        this.PSFAmount += (moduleData.amount != null ? moduleData.amount : 0);
                    }
                }
                return this.PSFAmount.setScale(4);
            }
        } {
            PSFTradeExpense = 0;
        }
        public Decimal VECAmount { set; get ; } {
            VECAmount = 0;
        }
        // Calculate by proportion, multiple by the difference between system amount and user input amount
        public Decimal VECGap { set; get; }{
            VECGap = 0;
        }
        public Decimal VECTradeExpense { set; get {
            return ((this.VECAmount != null ? this.VECAmount : 0) 
                    + (this.VECGap != null ? this.VECGap : 0)).setScale(4);
        } } {
            VECTradeExpense = 0;
        }
        public Decimal fixCostTradeExpense { set; get; } {
            fixCostTradeExpense = 0;
        }
        public Decimal totalTradeExpense {
            set;
            get {
                // return (this.BRSFTradeExpense + this.PSFTradeExpense + this.VECTradeExpense + this.fixCostTradeExpense).setScale(4);
                return ((this.BRSFTradeExpense != null ? this.BRSFTradeExpense : 0) 
                        + (this.PSFTradeExpense != null ? this.PSFTradeExpense : 0) 
                        + (this.VECTradeExpense != null ? this.VECTradeExpense : 0) 
                        + (this.fixCostTradeExpense != null ? this.fixCostTradeExpense : 0)).setScale(4);
            }
        }
        public Decimal tradeExpensePerBottle {
            set;
            get {
                return this.volumeSTD != 0 && this.volumeSTD != null && this.totalTradeExpense != null ? (this.totalTradeExpense / this.volumeSTD).setScale(4) : 0;
                // return this.volumeSTD != 0 ? (this.totalTradeExpense / this.volumeSTD).setScale(4) : 0;
            }
        }

        public Decimal GSTotal { set; get; }{
            GSTotal = 0;
        }
        public Decimal CMTotal { set; get; }{
            CMTotal = 0;
        }
        public Decimal latestBudgetCMTotal { set; get; }{
            latestBudgetCMTotal = 0;
        }

        public Decimal GSPercent {set;get{
            return this.GSTotal != 0 && this.GSTotal != null && this.totalTradeExpense != null ? (this.totalTradeExpense / this.GSTotal * 100).setScale(4) : 0;
        }}
        public Decimal ROI {set;get{
            return this.totalTradeExpense != 0 && this.totalTradeExpense != null && this.CMTotal != null ? (this.CMTotal / this.totalTradeExpense).setScale(4) : 0;
        }}

        public  List<ModuleTradeExpense> tradeExpenseByPSFModule { set; get; } {
            tradeExpenseByPSFModule = new List<ModuleTradeExpense>();
        }


        //add by BLS 20200323 for Heavy Contract ON 2nd KPI begin
        // public  Decimal BRSFPerTradeExpense {set;get;} {BRSFPerTradeExpense=0;}
        // public  Decimal PSFPerTradeExpense {set;get;} {PSFPerTradeExpense=0;}
        // public  Decimal VECPerTradeExpense {set;get;} {VECPerTradeExpense=0;}
        // public  Decimal fixCostPerTradeExpense {set;get;} {fixCostPerTradeExpense=0;}

        // public Decimal tradeExpensePerBottle2nd {
        //     set;
        //     get {
        //         return ((this.BRSFPerTradeExpense != null ? this.BRSFPerTradeExpense : 0) 
        //                 + (this.PSFPerTradeExpense != null ? this.PSFPerTradeExpense : 0) 
        //                 + (this.VECPerTradeExpense != null ? this.VECPerTradeExpense : 0) 
        //                 + (this.fixCostPerTradeExpense != null ? this.fixCostPerTradeExpense : 0)).setScale(4);
        //     }
        // }

        // public  Decimal monthlyVolumeSTD { set; get; } {
        //     monthlyVolumeSTD = 0;
        // }
        // public  Decimal monthlyVolumeCR12 {
        //     set;
        //     get {
        //         return ((this.monthlyVolumeSTD != null ? this.monthlyVolumeSTD : 0) 
        //             * (this.cr12Factor != null ? this.cr12Factor : 0)).setScale(4);
        //     }
        // }
        // public  Decimal monthlyVolume9L {
        //     set;
        //     get {
        //         return ((this.monthlyVolumeSTD != null ? this.monthlyVolumeSTD : 0)
        //                 * (this.factor9L != null ? this.factor9L : 0) / 9).setScale(4);
        //     }
        // }
        // public Decimal propByStdTotal  {set;get;} {propByStdTotal=0;} // All period from contract
        // public Decimal MarginPerBottle  {set;get;} {MarginPerBottle=0.0;} 
        // public Decimal CMBeforeSpending {set;get;} {CMBeforeSpending=0.0;}
        // public Decimal DomesticIndexTarget  {set;get;} {DomesticIndexTarget=0.0;}
        // public Decimal DomesticInvestment  {set;get;} {DomesticInvestment=0.0;}
        // public Decimal DomesticCMAfterSpending {set;get;} {DomesticCMAfterSpending=0.0;}
        // public Decimal RegionalAverageIndex  {set;get;} {RegionalAverageIndex=0.0;}
        // public Decimal RegionalAverageInvestment  {set;get;} {RegionalAverageInvestment=0.0;}
        // public Decimal RegionalAverageAfterSpending {set;get;} {RegionalAverageAfterSpending=0.0;}
        // public Decimal DomesticContractIndex {set;get;} {DomesticContractIndex=0.0;}
        // public Decimal RegionalTargetIndex {set;get;} {RegionalTargetIndex=0.0;}
        // public Decimal GapWithDomesticIndexTarget {set;get;} 
        // public Decimal GapWithRegionalAverageIndex {set;get;} 
        // public Decimal GapWithDomesticInvestment {set;get;} {GapWithDomesticInvestment=0.0;}
        // public Decimal GapWithRegionalAverageInvestment {set;get;} {GapWithRegionalAverageInvestment=0.0;}
        
        // public  List<ModuleTradeExpense> tradeExpenseByFXModule { set; get; } {
        //     tradeExpenseByFXModule = new List<ModuleTradeExpense>();
        // }
        //add by BLS 20200323 for Heavy Contract ON 2nd KPI end

        public TradeExpenseBreakdown(){
        }
        public TradeExpenseBreakdown(ASI_CRM_Subbrand_Volume__c subBrandVolume){
            this.subBrandId = subBrandVolume.ASI_CRM_Subbrand__c;
            this.subBrandName = subBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c;
            this.subBrandCode = subBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c;
            this.gradeId = subBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            this.gradeName = subBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            this.categoryId = subBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
            this.categoryName = subBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
            this.cr12Factor = denullify(subBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,1);
            this.factor9L = denullify(subBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,1);
            this.nonContract = true;
        }
        public TradeExpenseBreakdown(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem){
            this.subBrandId = lineItem.ASI_CRM_CN_Sub_Brand__c;
            this.subBrandName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c;
            this.subBrandCode = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c;
            this.gradeId = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            this.gradeName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            this.categoryId = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
            this.categoryName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
            this.cr12Factor = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,1);
            this.factor9L = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,1);
            this.nonContract = false;
        }

        // public TradeExpenseBreakdown(ASI_TH_CRM_PaymentRequestLineItem__c lineItem){
        //     this.subBrandId = lineItem.ASI_CRM_CN_Sub_Brand__c;
        //     this.subBrandName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c;
        //     this.subBrandCode = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c;
        //     this.gradeId = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;
        //     this.gradeName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
        //     this.categoryId = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
        //     this.categoryName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
        //     this.cr12Factor = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,1);
        //     this.factor9L = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,1);
        //     this.nonContract = false;
        // }
    }

    public class TradeExpenseBreakdown2nd {
        Boolean nonContract { set; get; } {
            nonContract = false;
        }
        public String subBrandId { set; get; }
        public String subBrandName { set; get; }
        public String subBrandCode { set; get; } { subBrandCode = '';}
        public String gradeId { set; get; }
        public String gradeName { set; get; }
        public String categoryId { set; get; }
        public String categoryName { set; get; }
        // Total volume in different units. Need to Project volume in PO Modi case
        public  Decimal volumeSTD { set; get; } {
            volumeSTD = 0;
        }
        public  Decimal volumeCR12 {
            set;
            get {
                return ((this.volumeSTD != null ? this.volumeSTD : 0) 
                    * (this.cr12Factor != null ? this.cr12Factor : 0)).setScale(4);
            }
        }
        public  Decimal volume9L {
            set;
            get {
                return ((this.volumeSTD != null ? this.volumeSTD : 0)
                        * (this.factor9L != null ? this.factor9L : 0) / 9).setScale(4);
            }
        }

        public  Decimal cr12Factor { set; get; } {cr12Factor = 1;}
        public  Decimal factor9L { set; get; } {
            factor9L = 1;}
        public  Decimal propByBRSFAmt { set; get; }
        public Decimal propByGrade { set; get; } {
            propByGrade = 1;}
        public Decimal propByCategory { set; get; } {
            propByCategory = 1;}
        public Decimal propByTotal { set; get; } {
            propByTotal = 1;}
        public  Decimal BRSFIncentive { set; get; } {
            BRSFIncentive = 0;
        }
        public  Decimal BRSFAmount { set; get ; } {
            BRSFAmount = 0;
        }
        // Calculate by proportion, multiple by the difference between system amount and user input amount
        public  Decimal BRSFGap { set; get; }{
            BRSFGap = 0;
        }
        public  Decimal BRSFTradeExpense {
            set;
            get {
                return ((this.BRSFAmount != null ? this.BRSFAmount : 0)
                        + (this.BRSFGap != null ? this.BRSFGap : 0)).setScale(4);
            }
        }
        public  Decimal PSFGap { set; get; } {
            PSFGap = 0;
        }
        public  Decimal PSFTradeExpense {
            set;
            get {
                this.PSFTradeExpense = 0;
                if(this.tradeExpenseByPSFModule.size() > 0 )
                {
                    for (ModuleTradeExpense moduleData : this.tradeExpenseByPSFModule) {
                        this.PSFTradeExpense += (moduleData.tradeExpense != null ? moduleData.tradeExpense : 0);
                    }
                }
                return (this.PSFTradeExpense 
                        + (this.PSFGap != null ? this.PSFGap : 0)).setScale(4);
            }
        } {
            PSFTradeExpense = 0;
        }
        public  Decimal PSFAmount {
            set;
            get {
                this.PSFAmount = 0;
                if(this.tradeExpenseByPSFModule.size() > 0)
                {
                    for (ModuleTradeExpense moduleData : this.tradeExpenseByPSFModule) {
                        this.PSFAmount += (moduleData.amount != null ? moduleData.amount : 0);
                    }
                }
                return this.PSFAmount.setScale(4);
            }
        } {
            PSFTradeExpense = 0;
        }
        public Decimal VECAmount { set; get ; } {
            VECAmount = 0;
        }
        // Calculate by proportion, multiple by the difference between system amount and user input amount
        public Decimal VECGap { set; get; }{
            VECGap = 0;
        }
        public Decimal VECTradeExpense { set; get {
            return ((this.VECAmount != null ? this.VECAmount : 0) 
                    + (this.VECGap != null ? this.VECGap : 0)).setScale(4);
        } } {
            VECTradeExpense = 0;
        }
        public Decimal fixCostTradeExpense { set; get; } {
            fixCostTradeExpense = 0;
        }
        public Decimal totalTradeExpense {
            set;
            get {
                // return (this.BRSFTradeExpense + this.PSFTradeExpense + this.VECTradeExpense + this.fixCostTradeExpense).setScale(4);
                return ((this.BRSFTradeExpense != null ? this.BRSFTradeExpense : 0) 
                        + (this.PSFTradeExpense != null ? this.PSFTradeExpense : 0) 
                        + (this.VECTradeExpense != null ? this.VECTradeExpense : 0) 
                        + (this.fixCostTradeExpense != null ? this.fixCostTradeExpense : 0)).setScale(4);
            }
        }
        public Decimal tradeExpensePerBottle {
            set;
            get {
                return this.volumeSTD != 0 && this.volumeSTD != null && this.totalTradeExpense != null ? (this.totalTradeExpense / this.volumeSTD).setScale(4) : 0;
                // return this.volumeSTD != 0 ? (this.totalTradeExpense / this.volumeSTD).setScale(4) : 0;
            }
        }

        public Decimal GSTotal { set; get; }{
            GSTotal = 0;
        }
        public Decimal CMTotal { set; get; }{
            CMTotal = 0;
        }
        public Decimal latestBudgetCMTotal { set; get; }{
            latestBudgetCMTotal = 0;
        }

        public Decimal GSPercent {set;get{
            return this.GSTotal != 0 && this.GSTotal != null && this.totalTradeExpense != null ? (this.totalTradeExpense / this.GSTotal * 100).setScale(4) : 0;
        }}
        public Decimal ROI {set;get{
            return this.totalTradeExpense != 0 && this.totalTradeExpense != null && this.CMTotal != null ? (this.CMTotal / this.totalTradeExpense).setScale(4) : 0;
        }}

        public  List<ModuleTradeExpense> tradeExpenseByPSFModule { set; get; } {
            tradeExpenseByPSFModule = new List<ModuleTradeExpense>();
        }


        //add by BLS 20200323 for Heavy Contract ON 2nd KPI begin
        public  Decimal BRSFPerTradeExpense {set;get;} {BRSFPerTradeExpense=0;}
        public  Decimal PSFPerTradeExpense {set;get;} {PSFPerTradeExpense=0;}
        public  Decimal VECPerTradeExpense {set;get;} {VECPerTradeExpense=0;}
        public  Decimal fixCostPerTradeExpense {set;get;} {fixCostPerTradeExpense=0;}

        public Decimal tradeExpensePerBottle2nd {
            set;
            get {
                return ((this.BRSFPerTradeExpense != null ? this.BRSFPerTradeExpense : 0) 
                        + (this.PSFPerTradeExpense != null ? this.PSFPerTradeExpense : 0) 
                        + (this.VECPerTradeExpense != null ? this.VECPerTradeExpense : 0) 
                        + (this.fixCostPerTradeExpense != null ? this.fixCostPerTradeExpense : 0)).setScale(4);
            }
        }

        public  Decimal monthlyVolumeSTD { set; get; } {
            monthlyVolumeSTD = 0;
        }
        public  Decimal monthlyVolumeCR12 {
            set;
            get {
                return ((this.monthlyVolumeSTD != null ? this.monthlyVolumeSTD : 0) 
                    * (this.cr12Factor != null ? this.cr12Factor : 0)).setScale(4);
            }
        }
        public  Decimal monthlyVolume9L {
            set;
            get {
                return ((this.monthlyVolumeSTD != null ? this.monthlyVolumeSTD : 0)
                        * (this.factor9L != null ? this.factor9L : 0) / 9).setScale(4);
            }
        }
        public Decimal propByStdTotal  {set;get;} {propByStdTotal=0;} // All period from contract
        public Decimal MarginPerBottle  {set;get;} {MarginPerBottle=0.0;} 
        public Decimal CMBeforeSpending {set;get;} {CMBeforeSpending=0.0;}
        public Decimal DomesticIndexTarget  {set;get;} {DomesticIndexTarget=0.0;}
        public Decimal DomesticInvestment  {set;get;} {DomesticInvestment=0.0;}
        public Decimal DomesticCMAfterSpending {set;get;} {DomesticCMAfterSpending=0.0;}
        public Decimal RegionalAverageIndex  {set;get;} {RegionalAverageIndex=0.0;}
        public Decimal RegionalAverageInvestment  {set;get;} {RegionalAverageInvestment=0.0;}
        public Decimal RegionalAverageAfterSpending {set;get;} {RegionalAverageAfterSpending=0.0;}
        public Decimal DomesticContractIndex {set;get;} {DomesticContractIndex=0.0;}
        public Decimal RegionalTargetIndex {set;get;} {RegionalTargetIndex=0.0;}
        public Decimal GapWithDomesticIndexTarget {set;get;} 
        public Decimal GapWithRegionalAverageIndex {set;get;} 
        public Decimal GapWithDomesticInvestment {set;get;} {GapWithDomesticInvestment=0.0;}
        public Decimal GapWithRegionalAverageInvestment {set;get;} {GapWithRegionalAverageInvestment=0.0;}
        
        public  List<ModuleTradeExpense> tradeExpenseByFXModule { set; get; } {
            tradeExpenseByFXModule = new List<ModuleTradeExpense>();
        }
        //add by BLS 20200323 for Heavy Contract ON 2nd KPI end

        public TradeExpenseBreakdown2nd(){
        }
        public TradeExpenseBreakdown2nd(ASI_CRM_Subbrand_Volume__c subBrandVolume){
            this.subBrandId = subBrandVolume.ASI_CRM_Subbrand__c;
            this.subBrandName = subBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c;
            this.subBrandCode = subBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c;
            this.gradeId = subBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            this.gradeName = subBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            this.categoryId = subBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
            this.categoryName = subBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
            this.cr12Factor = denullify(subBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,1);
            //this.factor9L = denullify(subBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,1);
            this.factor9L = denullify(subBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Standard_Bottle_Size__c,1000)/1000;
            this.nonContract = true;
        }
        public TradeExpenseBreakdown2nd(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem){
            this.subBrandId = lineItem.ASI_CRM_CN_Sub_Brand__c;
            this.subBrandName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c;
            this.subBrandCode = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c;
            this.gradeId = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            this.gradeName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            this.categoryId = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
            this.categoryName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
            this.cr12Factor = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,1);
            //this.factor9L = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,1);
            this.factor9L = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,1000)/1000;
            this.nonContract = false;
        }

        public TradeExpenseBreakdown2nd(ASI_TH_CRM_PaymentRequestLineItem__c lineItem){
            this.subBrandId = lineItem.ASI_CRM_CN_Sub_Brand__c;
            this.subBrandName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c;
            this.subBrandCode = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c;
            this.gradeId = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            this.gradeName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            this.categoryId = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
            this.categoryName = lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
            this.cr12Factor = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,1);
            //this.factor9L = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,1);
            this.factor9L = denullify(lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,1000)/1000;
            this.nonContract = false;
        }
    }

    public class ModuleTradeExpense {
        String moduleId {set;get;}
        // Need in PO Modi case
        Decimal incentivePerCR12  {set;get;} {incentivePerCR12 = 0;}
        Decimal incentivePer  {set;get;} {incentivePer = 0;}
        // Calculate by proportion, multiple by the difference between system amount and user input amount
        Decimal amount {set;get;} {amount = 0;}
        Decimal gap {
            set;
            get ;
        } {
            gap = 0;
        }
        Decimal tradeExpense  {set;get{
            //20191113:AM@introv - fix approval submittal failure
            //return amount + gap;
            return ((amount!=NULL ? amount : 0) 
                + (gap!=NULL ? gap : 0));
        }}
        Decimal historicalPaidAmount {set;get;} {historicalPaidAmount = 0;}
        Decimal actualPayment {set;get;} {actualPayment = 0;}
        Decimal totalCTDPayableAmount {set;get;} {totalCTDPayableAmount = 0;}
        Decimal applicationPaymentAmount {set;get;} {applicationPaymentAmount = 0;}

        public ModuleTradeExpense(){

        }

        public ModuleTradeExpense(ASI_CRM_Module__c module){
            this.moduleId = module.Id;
            this.historicalPaidAmount = module.ASI_CRM_Historical_Paid_Amount__c;
            this.actualPayment = module.ASI_CRM_Actual_Payment__c;
            this.applicationPaymentAmount = module.ASI_CRM_Application_Payment_Amount__c;
        }
    }




    //PO Modification  Calculation
    //@description: Restructure Current PO Modi Record FI Data
    //@param: input current Contract
    //@return
    public static void  ReconstructCurrentPOModiFIData(ASI_TH_CRM_Contract__c contract) {
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);
        String strRegion= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';

        Decimal CMTotal=0;
        Decimal LatestBudgetCMTotal = 0;
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        // Calculate Variable Cost (变动费用) in Theoretical Amount(建议预估金额)
        Decimal TotalVariableCost = 0;
        FinancialIndicator  POModiContractFI= new FinancialIndicator();
        POModiContractFI.ContractLineMap = new Map<String,ContractLine>();
        POModiContractFI.ContractId = thisCC.Id;
        POModiContractFI.ContractLineMap = new Map<String,ContractLine>();
        POModiContractFI.BCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c!= null?thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c:0;
        POModiContractFI.TotalMBCRate = thisCC.ASI_CRM_Martell_BC_Rate__c!= null?thisCC.ASI_CRM_Martell_BC_Rate__c:0;


        String V0_0_POId=thisCC.Id;
        if(thisCC.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0_0_POId=thisCC.ASI_CRM_CN_V0_0_PO_version__c;
        }

        if(thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null){
            POModiContractFI.FixedExpense = thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
        }

        if(thisCC.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_No_of_Months__c != null){
            POModiContractFI.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
        }
        POModiContractFI.POStartDate = thisCC.ASI_CRM_CN_PO_Start_Date__c;
        POModiContractFI.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;

        //Looping v0.0 Contract Cost
        for (ASI_CRM_Contract_Cost__c v0cost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c FROM ASI_CRM_Contract_Cost__c
        WHERE ASI_CRM_CN_Contract__c = :V0_0_POId])
        {
            if (v0cost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                TotalVariableCost += v0cost.ASI_CRM_CN_Estimate_Amount__c!=null?v0cost.ASI_CRM_CN_Estimate_Amount__c:0;
            }
        }


        //Contract v0.0 details Line
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c  ContractLine : [SELECT ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,
            ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :V0_0_POId] )
        {
            TotalVariableCost += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
        }

        Decimal PSFEstTotal=0;
        Decimal VECEstTotal=0;
        Decimal TotalBackCap=0;
        Decimal Total_IntakeBtl=0;
        Decimal TotalBC =0;
        for (ASI_CRM_Contract_Cost__c pccost : [SELECT Id,Name, ASI_CRM_CN_Activity_Code__r.Name,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,
            ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c
        FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id])
        {
            if(pccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                POModiContractFI.VariableExpense +=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                if(pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('PSF') || pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('Promotion Service Fee')){
                    PSFEstTotal+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                }
                if(pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('Variable Event Cost') ){
                    VECEstTotal+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                }
            }
            POModiContractFI.TradeExpenses+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
        }

        //Looping current contract Detail Lines
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : [
            SELECT
                Id,
                ASI_CRM_Volume_Base__c,
                ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,
                ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
                ASI_CRM_Type__c,
                ASI_CRM_Module__c,
                ASI_CRM_Module__r.ASI_CRM_Methodology__c,
                RecordType.DeveloperName,
                ASI_CRM_CN_Sub_Brand__c,
                ASI_CRM_CN_Contract_Monthly_Qty__c,
                ASI_CRM_CN_Est_Monthly_Qty__c,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Sub_Brand__r.Name,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_CN_Contract_Total__c,
                ASI_CRM_CN_Est_Total_Dummy__c,
                ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_Est_Total__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_CN_Estimate_Volume_9L_Month__c
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
            WHERE ASI_CRM_CN_Contract__c = :thisCC.Id
        ]) {


            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){
                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                    POModiContractFI.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                }

                String LineKey=SBGradeSorting(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                if(POModiContractFI.ContractLineMap.containsKey(LineKey)){
                    POModiContractFI.ContractLineMap.get(LineKey).VFinalFees = POModiContractFI.ContractLineMap.get(LineKey).VFinalFees + ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    POModiContractFI.ContractLineMap.get(LineKey).VFinalVolume+=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.VFinalFees = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    ContractDetail.VFinalTotalFees= ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c *ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c:0;

                    ContractDetail.VFinalVolume=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    POModiContractFI.ContractLineMap.put(LineKey,ContractDetail);
                }


            }

            // if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' ){
            //     PSFEstTotal+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            // }
            // if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='Variable Event Cost' ){
            //     VECEstTotal+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            // }


            // if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
            //     POModiContractFI.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
            //     POModiContractFI.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
            // }else{
            //     POModiContractFI.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
            //     POModiContractFI.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
            // }


        }

        PSFEstTotal += thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        VECEstTotal += thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c!=null?thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c:0;

        POModiContractFI.VariableExpense+=thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        POModiContractFI.VariableExpense+=thisCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
        POModiContractFI.VariableExpense+=thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c!=null?thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c:0;

        POModiContractFI.TradeExpenses+=thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        POModiContractFI.TradeExpenses+=thisCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
        POModiContractFI.TradeExpenses+=thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c!=null?thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c:0;

        AdditionalFIMap.put('PSFEstTotal',PSFEstTotal);
        AdditionalFIMap.put('VECEstTotal',VECEstTotal);

        //POModiContractFI.VariableExpense=TotalVariableCost;

        Map<String, Decimal> POMv1_sbvol = new Map<String, Decimal>(); // Date --->Volume
        Set<Id> AllOutlet = new Set<Id>();
        if(thisCC.ASI_CRM_Volume_Option__c == 'Wholesaler Only' ){
            AllOutlet.add(thisCC.ASI_CRM_CN_Outlet_WS__c);
        }else{
            AllOutlet.add(thisCC.ASI_CRM_CN_Outlet_WS__c);
            for (ASI_CRM_CN_Covered_Outlet__c CO_temp: [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id]){
                AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
            }
        }

        POModiContractFI.OutletSet=AllOutlet;

        Date CutOffDay =GenerateCutOffDate();
        Date TillEnd;
        if (CutOffDay >= thisCC.ASI_CRM_CN_PO_End_Date__c)
            TillEnd = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c);
        else
            TillEnd = CutOffDay;
        Integer PeriodA = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
        Integer PeriodB = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);

        Set<Id> POMv1_sbid = new Set<Id>();

        Decimal TotalBlackCap_prorate=0;
        Decimal Total_IntakeBtl_prorate=0;
        Decimal TotalBC_prorate=0;

        Decimal Total_MartellBC =0;  // total contract Martel BC
        Decimal Total_MartellIntakeBtl =0;  // total contract Martel Intake Btl
        Decimal Total_MartellBlackCap =0;  // total contract Martel BlackCap


        //**************************Looping Sub-Brand Volume**************************
        for (ASI_CRM_Subbrand_Volume__c SubBrandVolume: retrieveSubBrandVolumes(thisCC))
        {
            String SubbrandGroupName='0. Not Specified';
            if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                SubbrandGroupName=SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null?SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c :SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            }

            Decimal Volumes = getVolume(SubBrandVolume, '9L');
            Decimal VolumeBtl = getVolume(SubBrandVolume, 'std');
            Decimal VariableBottles =0;

            //BC
            Decimal BottleCollection=0;
            BottleCollection += SubBrandVolume.ASI_CRM_Green_Cap_STD__c != null? SubBrandVolume.ASI_CRM_Green_Cap_STD__c:0;
            BottleCollection += SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c != null? SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c:0;

            TotalBC += BottleCollection;
            TotalBC_prorate+=BottleCollection;

            //Black Cap ASI_CRM_DeductCapWithIssue_StdBill__c
            Decimal BlackCap=0;
            BlackCap+= SubBrandVolume.ASI_CRM_Cap_with_Issues_Std_Billing__c != null? SubBrandVolume.ASI_CRM_Cap_with_Issues_Std_Billing__c:0;

            TotalBackCap+=BlackCap;
            TotalBlackCap_prorate+=BlackCap;


            Total_IntakeBtl+=VolumeBtl;
            Total_IntakeBtl_prorate+=VolumeBtl;

            if( ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c) ){
                Total_MartellBC += BottleCollection;
                Total_MartellIntakeBtl+=VolumeBtl;
                Total_MartellBlackCap+=BlackCap;
            }


            //**prorate**
            if (PeriodA != 0 && PeriodA != null && PeriodB != 0 && PeriodB != null){
                Volumes = Volumes/PeriodA * PeriodB;
                VolumeBtl = VolumeBtl/PeriodA * PeriodB;
                BlackCap= BlackCap/PeriodA * PeriodB;
                BottleCollection=BottleCollection/PeriodA * PeriodB;
                VariableBottles = VolumeBtl/PeriodB ;//<----Monthly (Std. Btl)                               (VolumeBtl/PeriodA) * PeriodB;
            }
            TotalBlackCap_prorate+=BlackCap;
            TotalBC_prorate+=BottleCollection;
            Total_IntakeBtl_prorate+=VolumeBtl;

            POModiContractFI.IntakeSTD+=VolumeBtl;
            POModiContractFI.Volumes += Volumes;

            Date pomdate= FYConversion(SubBrandVolume.ASI_CRM_End_Date__c);
            String strkey = String.valueOf(pomdate) + SubBrandVolume.ASI_CRM_Subbrand__c;

            POModiContractFI.InvestmentCR12 += SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c:0;
            POModiContractFI.InvestmentCR12 += SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c:0;
            POModiContractFI.InvestmentCR12 += SubBrandVolume.ASI_CRM_PR_Direct_CR12__c!=null? SubBrandVolume.ASI_CRM_PR_Direct_CR12__c:0;


            ////Actual Volume (9L) = T1_Depletion + T2_Depletion + PR_Direct
            Decimal ActualVolume=0;
            ActualVolume+=SubBrandVolume.ASI_CRM_T1_Depletion__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion__c:0;
            ActualVolume+=SubBrandVolume.ASI_CRM_T2_Depletion__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion__c:0;
            ActualVolume+=SubBrandVolume.ASI_CRM_PR_Direct__c!=null? SubBrandVolume.ASI_CRM_PR_Direct__c:0;

            //POModiContractFI.Volumes+=ActualVolume;
            if (POMv1_sbvol != null && POMv1_sbvol.containsKey(strkey)){
                ActualVolume += POMv1_sbvol.get(strkey);
                POMv1_sbvol.put(strkey, ActualVolume);
            }else{
                POMv1_sbvol.put(strkey,ActualVolume);
            }

            POMv1_sbid.add(SubBrandVolume.ASI_CRM_Subbrand__c);



            if(POModiContractFI.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                Decimal TempVolumes=POModiContractFI.SubBrandGradeMap.get(SubbrandGroupName)+Volumes;
                //remove orignal one
                POModiContractFI.SubBrandGradeMap.remove(SubbrandGroupName);
                POModiContractFI.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
            }else{
                POModiContractFI.SubBrandGradeMap.put(SubbrandGroupName,Volumes);
            }



            String SuBBrandKey =SBGradeSorting(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + SubBrandVolume.ASI_CRM_Subbrand__r.Name;

            if(POModiContractFI.ContractLineMap.containsKey(SuBBrandKey)){
                POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalBottles =POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalBottles + VariableBottles ;
                //POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalTotalFees +=  POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalFees * VarTotal;
                POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalActualVolume = POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalActualVolume + VariableBottles ;
            }else{
                ContractLine ContractDetail = new ContractLine ();
                ContractDetail.VFinalBottles = VariableBottles;
                ContractDetail.VFinalActualVolume=VariableBottles;
                ContractDetail.SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.Name;
                ContractDetail.SubBrandGrade= SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                POModiContractFI.ContractLineMap.put(SuBBrandKey,ContractDetail);
            }



        }// End of Looping Sub-Brand Volume




        AdditionalFIMap.put('Total_MartellBC',Total_MartellBC);
        AdditionalFIMap.put('Total_MartellIntakeBtl',Total_MartellIntakeBtl);
        AdditionalFIMap.put('Total_MartellBlackCap',Total_MartellBlackCap);


        AdditionalFIMap.put('TotalBackCap',TotalBackCap);
        AdditionalFIMap.put('TotalBC',TotalBC);
        AdditionalFIMap.put('Total_IntakeBtl',Total_IntakeBtl);

        AdditionalFIMap.put('TotalBlackCap_prorate',TotalBlackCap_prorate);
        AdditionalFIMap.put('Total_IntakeBtl_prorate',Total_IntakeBtl_prorate);
        AdditionalFIMap.put('TotalBC_prorate',TotalBC_prorate);

        if(TotalBC!=0 && TotalBC !=null && Total_IntakeBtl !=null && Total_IntakeBtl!=0){
            POModiContractFI.TotalBCRate=(TotalBC/Total_IntakeBtl)*100;
            POModiContractFI.NetBCRate=((TotalBC-TotalBackCap)/Total_IntakeBtl)*100;
        }


        //Prorate
        if (thisCC.ASI_CRM_CN_PO_End_Date__c > CutOffDay){
            Integer daysperiod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
            Integer prorateperiod = MonthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
            if (prorateperiod < 0)
                prorateperiod = 0;

            Decimal AverageCR12= 0;
            Decimal Average9L= 0;
            //for Latest Investment CR12
            if (daysperiod != null && daysperiod != 0 && POModiContractFI.InvestmentCR12 != 0)
                AverageCR12 = POModiContractFI.InvestmentCR12 / daysperiod;
            if (prorateperiod != 0 && prorateperiod != null && AverageCR12 != null && AverageCR12 !=0)
                POModiContractFI.InvestmentCR12 += AverageCR12 * prorateperiod ;

        }

        if (thisCC != null && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null && POModiContractFI.InvestmentCR12 != 0){
            POModiContractFI.IntakeCR12=POModiContractFI.InvestmentCR12;
            POModiContractFI.InvestmentCR12 = thisCC.ASI_CRM_CN_Total_Contract_Amount__c / POModiContractFI.InvestmentCR12;
        }



        Date v1startdate = getEndDate(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        Date v1enddate;
        if (thisCC.ASI_CRM_CN_PO_End_Date__c < CutOffDay){
            v1enddate = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c);
        }else{
            v1enddate = CutOffDay;
        }

        Map<Date, Decimal> Lastest_Period_map = checkFYDayPeriod(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        System.debug('PO Modi : Lastest_Period_map'+Lastest_Period_map);
        Map<String, subbrand_data> Lastest_ROImap = new Map <String, subbrand_data>();
        if (Lastest_Period_map != null && Lastest_Period_map.size() > 0){
            String strkey = null;
            for (Date v1period : Lastest_Period_map.keySet()){
                if (POMv1_sbid != null && POMv1_sbid.size() > 0){
                    for (Id sbid : POMv1_sbid){
                        strkey = String.valueOf(v1period) + sbid;
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = Lastest_Period_map.get(v1period);
                        newitem.SubBrandId = sbid;
                        newitem.year = String.valueOf(FYConversion(v1period).year());
                        newitem.TotalVolume = 0;
                        Lastest_ROImap.put(strkey, newitem);
                    }
                }
            }
        }

        //Calculate RegionSubBrandCM_Map
        String currentFY = String.valueOf(FYConversion(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';

        System.debug('RegionSubBrandCM_Map SQL : currentFY:'+currentFY+'currentFY2:'+currentFY2);
        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal> ();
        for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c FROM ASI_CRM_CM_GS__c
        WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2  OR ASI_CRM_YEAR__c = :currentFY3 ) AND
        ASI_CRM_Region__c = :strRegion  AND ASI_CRM_TYPE__c = 'Budget CM'
        AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS') 
        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            if (!RegionSubBrandCM_Map.containsKey(ProductCode)){
                RegionSubBrandCM_Map.put(ProductCode,denullify(lbcm.ASI_CRM_CM_GS_per_9L__c));
            }
        }

        Map<String, Decimal> latestContributionMargin = new Map<String, Decimal>();
        Map<String, Decimal> latestBudgetContributionMargin = new Map<String, Decimal>();
        Map<String, Decimal> latestGrossSales = new Map<String, Decimal>();

        System.debug('Now PO Mod v1startdate'+v1startdate);
        System.debug('Now PO Mod v1enddate'+v1enddate);

        for (ASI_CRM_CM_GS__c v1budgetcmtemp : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
        FROM ASI_CRM_CM_GS__c
        WHERE ASI_CRM_PRODUCTCODE__c IN :POMv1_sbid
        AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
        AND ASI_CRM_CN_Month_End_Date__c >= :v1startdate
        AND ASI_CRM_CN_Month_End_Date__c <= :v1enddate
        AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS' )
        AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != NULL 
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS') 
        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            String subBrandId = v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c;
            String strkey = String.valueOf(v1budgetcmtemp.ASI_CRM_CN_Month_End_Date__c) + subBrandId;
            Decimal ActualData = denullify(v1budgetcmtemp.ASI_CRM_CM_GS_per_9L__c);


            if (v1budgetcmtemp.ASI_CRM_TYPE__c == 'YTD GS'){
                if (!latestGrossSales.containsKey(subBrandId)){
                    latestGrossSales.put(subBrandId, ActualData);
                }
                if (Lastest_ROImap != null && Lastest_ROImap.containsKey(strkey)){
                    if (Lastest_ROImap.get(strkey).GS == null || Lastest_ROImap.get(strkey).GS == 0){
                        Lastest_ROImap.get(strkey).GS = ActualData;
                        //POModiContractFI.GSId+=v1budgetcmtemp.Id+';';
                    }
                }
            }
            if (v1budgetcmtemp.ASI_CRM_TYPE__c == 'YTD CM'){
                if (Lastest_ROImap != null && Lastest_ROImap.containsKey(strkey)){
                    if (Lastest_ROImap.get(strkey).CM == null || Lastest_ROImap.get(strkey).CM == 0){
                        Lastest_ROImap.get(strkey).CM = ActualData;
                        //POModiContractFI.CMId+=v1budgetcmtemp.Id+';';
                    }

                    if (Lastest_ROImap.get(strkey).latestBudgetCM == null || Lastest_ROImap.get(strkey).latestBudgetCM == null){
                        if (RegionSubBrandCM_Map.containsKey(subBrandId)){
                            Lastest_ROImap.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(subBrandId);
                        }
                    }

                }

                if (Lastest_ROImap != null && !latestContributionMargin.containsKey(subBrandId) && ActualData != null && ActualData != 0){
                    latestContributionMargin.put(subBrandId, ActualData);
                }
                if (Lastest_ROImap != null && !latestBudgetContributionMargin.containsKey(subBrandId)){
                    if (RegionSubBrandCM_Map.containsKey(subBrandId)) {
                        latestBudgetContributionMargin.put(subBrandId, RegionSubBrandCM_Map.get(subBrandId));
                    }
                }
            }



        }// End of CM/GS Looping

        Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> CMGSBySubBrand = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        if(Lastest_ROImap != null && Lastest_ROImap.size() > 0){
            Integer startToCutoffMonth = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
            Integer cutoffToEndMonth = MonthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
            if (cutoffToEndMonth < 0) cutoffToEndMonth = 0;
            Decimal Average9L = 0;

            /*
            What is the difference between actualVolume and projectedVolume?
            actualVolume: The volume from contract start to current. It should be taken from data.
            projectedVolume: The estimate volume when the whole contract end.
                 The estimation comes from actualVolume, by calculating the monthly volume then multiples the whole contract period.
            */
            for (String v1roitemp : Lastest_ROImap.keySet()){
                String subBrandId = Lastest_ROImap.get(v1roitemp).SubBrandId;
                Decimal actualVolume = denullify(POMv1_sbvol.get(v1roitemp));
                ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.containsKey(subBrandId) ? CMGSBySubBrand.get(subBrandId) : new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();


                //**********Actual CM *********
                /*
                Total Contribution Margin = YTD Contribution Margin * CTD Volume + YTD Contribution Margin * Project Volume
                */
                Decimal actualcm =0;
                Decimal prorate_actualcm = 0;
                Average9L = actualVolume / startToCutoffMonth;

                if (Lastest_ROImap.get(v1roitemp).CM != null && Lastest_ROImap.get(v1roitemp).CM != 0){
                    actualcm = Lastest_ROImap.get(v1roitemp).CM;
                }else if (latestContributionMargin.containsKey(subBrandId)){
                    actualcm = latestContributionMargin.get(subBrandId);
                }

                if (actualcm != null){
                    CMTotal += actualVolume * actualcm;
                    CMGSData.CM += actualVolume * actualcm;

                    if (latestContributionMargin.containsKey(subBrandId))
                        prorate_actualcm = latestContributionMargin.get(subBrandId);

                    if (Average9L != null && cutoffToEndMonth != null && prorate_actualcm != null){
                        CMTotal += Average9L * cutoffToEndMonth * prorate_actualcm;
                        CMGSData.CM += Average9L * cutoffToEndMonth * prorate_actualcm;
                    }

                }

                //*********Latest Budget CM*********
                /*
                Total Budget Contribution Margin = YTD Contribution Margin * CTD Volume  + YTD Contribution Margin * Project Volume
                */
                Decimal lbcm = 0;
                Decimal prorate_lbcm = 0;
                if (Lastest_ROImap.get(v1roitemp).latestBudgetCM != null && Lastest_ROImap.get(v1roitemp).latestBudgetCM != 0)
                    lbcm = Lastest_ROImap.get(v1roitemp).latestBudgetCM;
                else if (latestBudgetContributionMargin.containsKey(subBrandId))
                    lbcm = latestBudgetContributionMargin.get(subBrandId);
                if (lbcm != null){
                    LatestBudgetCMTotal += actualVolume * lbcm;
                    CMGSData.latestBudgetCM += actualVolume * lbcm;

                    if (latestBudgetContributionMargin.containsKey(subBrandId))
                        prorate_lbcm = latestBudgetContributionMargin.get(subBrandId);

                    if (Average9L != null && cutoffToEndMonth != null && prorate_lbcm != null) {
                        LatestBudgetCMTotal += Average9L * cutoffToEndMonth * prorate_lbcm;
                        CMGSData.latestBudgetCM += Average9L * cutoffToEndMonth * prorate_lbcm;
                    }
                }

                //**********Actual GS*********
                /*
                Total Gross Sales = YTD Gross Sales * CTD Volume + YTD Gross Sales * Project Volume
                */

                Decimal ActualGS = 0;
                if (Lastest_ROImap.get(v1roitemp).GS != null && Lastest_ROImap.get(v1roitemp).GS != 0) {
                    ActualGS = Lastest_ROImap.get(v1roitemp).GS;
                } else if (latestGrossSales.containsKey(subBrandId)) {
                    ActualGS = latestGrossSales.get(subBrandId);
                }

                if (ActualGS != null){
                    POModiContractFI.GrossSalesTotal += ActualGS * actualVolume;
                    CMGSData.GS += ActualGS * actualVolume;
                }

                Decimal ActualGS_prorate = 0;
                if (latestGrossSales.containsKey(subBrandId)){
                    ActualGS_prorate = latestGrossSales.get(subBrandId);
                }

                if(ActualGS_prorate!=null && actualVolume !=null && startToCutoffMonth !=null && startToCutoffMonth !=0 && cutoffToEndMonth !=null){
                    POModiContractFI.GrossSalesTotal  += ActualGS_prorate * Average9L* cutoffToEndMonth;
                    CMGSData.GS  += ActualGS_prorate * Average9L* cutoffToEndMonth;
                }

                CMGSBySubBrand.put(subBrandId, CMGSData);
            }
        }
        //        if(Lastest_ROImap != null && Lastest_ROImap.size() > 0){
        //            Integer startToCutoffMonth = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
        //            Integer cutoffToEndMonth = MonthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
        //            if (cutoffToEndMonth < 0) cutoffToEndMonth = 0;
        //
        //            //                The original code is so bad that no one can understand, so I rewrite it using with better variable names and flow
        //            for (String v1roitemp : Lastest_ROImap.keySet()){
        //                Decimal actualVolume = denullify(POMv1_sbvol.get(v1roitemp));
        //                Decimal projectedVolume = actualVolume / startToCutoffMonth * (startToCutoffMonth + cutoffToEndMonth);
        //                String subBrandId = Lastest_ROImap.get(v1roitemp).SubBrandId;
        //
        //                //**********Actual GS*********
        //                /*
        //                Total Gross Sales = YTD Gross Sales * Projected Volume
        //                 */
        //                Decimal actualGS = Lastest_ROImap.get(v1roitemp).GS != null ? Lastest_ROImap.get(v1roitemp).GS : denullify(latestGrossSales.get(subBrandId));
        //                POModiContractFI.GrossSalesTotal += actualGS * projectedVolume;
        //
        //                //**********Actual CM *********
        //                /*
        //                Total Contribution Margin = YTD Contribution Margin * Projected Volume
        //                */
        //                Decimal actualCM = Lastest_ROImap.get(v1roitemp).CM != null ? Lastest_ROImap.get(v1roitemp).CM : denullify(latestContributionMargin.get(subBrandId));
        //                CMTotal += actualCM * projectedVolume;
        //
        //
        //                //*********Latest Budget CM*********
        //                /*
        //                Total Budget Contribution Margin = YTD Contribution Margin * Projected Volume
        //                */
        //                Decimal latestBudgetCM = Lastest_ROImap.get(v1roitemp).latestBudgetCM != null ? Lastest_ROImap.get(v1roitemp).latestBudgetCM : denullify(latestBudgetContributionMargin.get(subBrandId));
        //                LatestBudgetCMTotal += latestBudgetCM * projectedVolume;
        //            }
        //        }

        AdditionalFIMap.put('CMTotal',CMTotal);
        AdditionalFIMap.put('LatestBudgetCMTotal',LatestBudgetCMTotal);

        POModiContractFI.CMTotal=CMTotal;
        if (CMTotal != null && CMTotal != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null){
            POModiContractFI.ROIIntake = POModiContractFI.CMTotal / thisCC.ASI_CRM_CN_Total_Contract_Amount__c; // ROI_POM.strB
        }

        if (LatestBudgetCMTotal != null && LatestBudgetCMTotal != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null){
            POModiContractFI.LatestBudgetCMTotal=LatestBudgetCMTotal;
            POModiContractFI.ROIProForma = LatestBudgetCMTotal / thisCC.ASI_CRM_CN_Total_Contract_Amount__c; //ROI_POM.ProFormaROIstrB
        }





        List<ASI_CRM_Subbrand_Volume__c> v0_VolList = new List<ASI_CRM_Subbrand_Volume__c>();
        Date v0TillEndPOM = getEndDate(FindMinMaxDate(CutOffDay, thisCC.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        v0_VolList = [SELECT Id, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,  ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c,ASI_CRM_Subbrand__c
        FROM ASI_CRM_Subbrand_Volume__c WHERE  ASI_CRM_Account__c IN: AllOutlet AND ASI_CRM_CN_Competitor_Sub_brand__c != TRUE
        AND ASI_CRM_End_Date__c >= :thisCC.ASI_CRM_CN_PO_Start_Date__c  AND ASI_CRM_End_Date__c <= :v0TillEndPOM AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE];


        Decimal v0_actualvol_pom = 0;

        if (v0_VolList != null && v0_VolList.size() > 0){
            for(ASI_CRM_Subbrand_Volume__c v0vol : v0_VolList){
                if (v0vol.ASI_CRM_T1_Depletion_CR12__c != null)
                    v0_actualvol_pom += v0vol.ASI_CRM_T1_Depletion_CR12__c;
                if (v0vol.ASI_CRM_T2_Depletion_CR12__c != null)
                    v0_actualvol_pom += v0vol.ASI_CRM_T2_Depletion_CR12__c;
                if (v0vol.ASI_CRM_PR_Direct_CR12__c != null)
                    v0_actualvol_pom += v0vol.ASI_CRM_PR_Direct_CR12__c;
            }
        }

        Decimal v0_estvol_pom=0;
        List<ASI_Attachment__c> AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
        FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = : thisCC.Id AND ASI_CRM_Type__c ='Historical Modi Data' ];
        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                if (String.isNotBlank(HistoricalContractList[0].AddOnString)) {
                    Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(HistoricalContractList[0].AddOnString,Map<String,Decimal>.class);
                    if( TempMap.containsKey('v0_estvol_pom')  ){
                        v0_estvol_pom= TempMap.get('v0_estvol_pom');
                    }
                }
            }
        }



        Date cutoffend;
        if (CutOffDay > thisCC.ASI_CRM_CN_PO_End_Date__c)
            cutoffend = thisCC.ASI_CRM_CN_PO_End_Date__c;
        else
            cutoffend = CutOffDay;
        Integer thisCCPeriod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        Integer v0CCPeriod = thisCCPeriod;
        if (thisCC.ASI_CRM_CN_V0_0_PO_version__c != null)
            v0CCPeriod = MonthDiff(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c);
        Integer THCTDPeriod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, cutoffend);
        Decimal ActVSEst_Vol = 0;
        Decimal v0_actualVol_Period = 0;
        Decimal v0_actualVol_Period_Month = 0;
        AdditionalFIMap.put('v0_actualvol_pom',v0_actualvol_pom);

        if (THCTDPeriod != null && THCTDPeriod != 0 && v0_actualvol_pom != null && v0_actualvol_pom != 0){
            v0_actualVol_Period_Month =  v0_actualvol_pom /  THCTDPeriod ;
        }

        if (v0_actualVol_Period_Month != null && v0_actualVol_Period_Month  != 0 && thisCCPeriod != null && thisCCPeriod != 0){
            v0_actualVol_Period  = v0_actualVol_Period_Month * thisCCPeriod ;
        }


        if (v0_actualVol_Period != null && v0_actualVol_Period != 0 && v0_estvol_pom != null && v0_estvol_pom != 0 && v0CCPeriod != null && v0CCPeriod != 0){
            ActVSEst_Vol = v0_actualVol_Period / (v0_estvol_pom * v0CCPeriod);
        }

        if(ActVSEst_Vol!=null){
            ActVSEst_Vol= ActVSEst_Vol*TotalVariableCost;
        }

        AdditionalFIMap.put('ActVSEst_Vol',ActVSEst_Vol);



        POModiContractFI.AddOnString = System.JSON.serialize(AdditionalFIMap);
        POModiContractFI.TradeExpenseBySubBrand = constructTradeExpenseBySubBrand(thisCC, 'estimate', 'PO Modi');
        // Set CM/GS By Sub-Brand
        for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown tradeExpenseBreakdown : POModiContractFI.TradeExpenseBySubBrand) {
            if (!CMGSBySubBrand.containsKey(tradeExpenseBreakdown.subBrandId)) {
                continue;
            }
            ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.get(tradeExpenseBreakdown.subBrandId);

            tradeExpenseBreakdown.GSTotal = CMGSData.GS;
            tradeExpenseBreakdown.CMTotal = CMGSData.CM;
            tradeExpenseBreakdown.latestBudgetCMTotal = CMGSData.latestBudgetCM;
        }

        POModiContractFI = calculateFIExcludeSelectedSubBrands(POModiContractFI);

        List<FinancialIndicator> ReturnList = new List<FinancialIndicator>();
        ReturnList.add(POModiContractFI);
        UpsertAttachment(thisCC.Id, System.JSON.serialize(ReturnList),'PO Modification Data' );


    }


    //PO Modification  Calculation for 2ndKPI
    //@description: Restructure Current PO Modi Record FI Data
    //@param: input current Contract
    //@return
    public static void  ReconstructCurrentPOModiFIData2nd(ASI_TH_CRM_Contract__c contract) {
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);
        FinancialIndicator2nd  POModiContractFI= new FinancialIndicator2nd();
        // if (thisCC.ASI_CRM_Auto_PO_Modification__c) {
        //     List<ASI_TH_CRM_PaymentRequest__c> LastPaymentRequest = [SELECT Id,Name,ASI_CRM_CN_Total_VEC_Amount__c,
        //                  ASI_CRM_Total_Variable_Amount__c,ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c,
        //                  ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c
        //                  FROM ASI_TH_CRM_PaymentRequest__c
        //                  WHERE 
        //                  ASI_CRM_CN_PO_No__c = :thisCC.ASI_CRM_CN_PO_No__c
        //                 AND ASI_CRM_CN_Last_Payment__c = TRUE
        //                 Order By CreatedDate desc];
        //     if (LastPaymentRequest.isEmpty()) {
        //         POModiContractFI =  ReconstructCurrentPOModiFIDataList2nd(thisCC).get(0);
        //     }
        //     else {
        //         POModiContractFI = ASI_CRM_CN_HeavyPaymentUtilitiesClass.ReconstructLastPaymentFIDataList2nd(LastPaymentRequest.get(0)).get(0);
        //     }
            
        // }
        // else {
        //     POModiContractFI =  ReconstructCurrentPOModiFIDataList2nd(thisCC).get(0);
        // }
        POModiContractFI =  ReconstructCurrentPOModiFIDataList2nd(thisCC).get(0);
        List<FinancialIndicator2nd> ReturnList = new List<FinancialIndicator2nd>();
        ReturnList.add(POModiContractFI);
        
        UpsertAttachment2nd(contract.Id, System.JSON.serialize(ReturnList),'PO Modification Data' );

        //if (thiscc.ASI_CRM_CN_Status__c != 'Draft' && thiscc.ASI_CRM_CN_Status__c != 'FY landing Archive') {
        if (!thisCC.ASI_CRM_Auto_PO_Modification__c){
            UpsertKPIData(contract, null, POModiContractFI);
        }
    }

    public static List<FinancialIndicator2nd>  ReconstructCurrentPOModiFIDataList2nd(ASI_TH_CRM_Contract__c contract) {
        String strRegion='',CommercialTeam='';

        String channel='',region='',cityInvestementGrade='',newImage='';

        Set<Id> V00SubBrandIdSet= new Set<Id>();
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);

        strRegion= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
        CommercialTeam= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';

        channel = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
        region = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
        cityInvestementGrade = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
        newImage = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;

        // Calculate Variable Cost (变动费用) in Theoretical Amount(建议预估金额)
        Decimal TotalVariableCost = 0;
        FinancialIndicator2nd  POModiContractFI= new FinancialIndicator2nd();
        POModiContractFI.ContractId = thisCC.Id;
        POModiContractFI.ContractLineMap = new Map<String,ContractLine>();
        POModiContractFI.BCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c!= null?thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c:0;
        POModiContractFI.TotalMBCRate = thisCC.ASI_CRM_Martell_BC_Rate__c!= null?thisCC.ASI_CRM_Martell_BC_Rate__c:0;
        POModiContractFI.TotalBCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
        if (thisCC.ASI_CRM_CN_PO_Start_Date__c!= null){
            POModiContractFI.POStartDate= thisCC.ASI_CRM_CN_PO_Start_Date__c;
        }
        if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null){
            POModiContractFI.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;
        }

        if(thisCC.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_No_of_Months__c != null){
            POModiContractFI.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
        }

        // String V0_0_POId=thisCC.Id;
        // if(thisCC.ASI_CRM_CN_V0_0_PO_version__c!=null){
        //     V0_0_POId=thisCC.ASI_CRM_CN_V0_0_PO_version__c;
        // }

        // if(thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null){
        //     POModiContractFI.FixedExpense = thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
        // }

        if(thisCC.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_No_of_Months__c != null){
            POModiContractFI.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
        }
        POModiContractFI.POStartDate = thisCC.ASI_CRM_CN_PO_Start_Date__c;
        POModiContractFI.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;

        //Looping v0.0 Contract Cost
        // for (ASI_CRM_Contract_Cost__c v0cost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c FROM ASI_CRM_Contract_Cost__c
        // WHERE ASI_CRM_CN_Contract__c = :V0_0_POId])
        // {
        //     if (v0cost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
        //         TotalVariableCost += v0cost.ASI_CRM_CN_Estimate_Amount__c!=null?v0cost.ASI_CRM_CN_Estimate_Amount__c:0;
        //     }
        // }


        // //Contract v0.0 details Line
        // for (ASI_CRM_CN_Contract_BRSF_Line_Item__c  ContractLine : [SELECT ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
        //     ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,
        //     ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
        // FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :V0_0_POId and ASI_CRM_Type__c!='Fixed'] )
        // {
        //     TotalVariableCost += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
        // }

        Decimal VariableExpense = 0;
        Decimal PSFEstTotal=0;
        Decimal VECEstTotal=0;
        Decimal TotalBackCap=0;
        Decimal Total_IntakeBtl=0;
        Decimal TotalBC =0;
        for (ASI_CRM_Contract_Cost__c pccost : [SELECT Id,Name, ASI_CRM_CN_Activity_Code__r.Name,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,
            ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c
        FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id])
        {
            if(pccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                POModiContractFI.VariableExpense +=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                if(pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('PSF') || pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('Promotion Service Fee')){
                    PSFEstTotal+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                }
                if(pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('Variable Event Cost') ){
                    VECEstTotal+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                }
            }
            POModiContractFI.TradeExpenses+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
        }

        //Set<String> ModuleIds = new Set<String>();
        Decimal BRSFEstimateVolumesTotal=0;
        Map<String, Decimal> EstVolume_map = new Map<String, Decimal>();

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> thisCC_BRSFList = [
            SELECT
                Id,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
            ASI_CRM_CN_Contract_Monthly_Qty__c,
            ASI_CRM_CN_Contract_Monthly_Vol9L__c,
            ASI_CRM_CN_Contract_Total_Dummy__c,
            ASI_CRM_CN_Contract_Total__c,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
            ASI_CRM_CN_Est_Monthly_Qty__c,
            ASI_CRM_CN_Est_Total_Dummy__c,
            ASI_CRM_CN_Est_Total__c,
            ASI_CRM_CN_Estimate_Volume_9L_Month__c,
            ASI_CRM_CN_No_of_Months__c,
            ASI_CRM_Contract_Total_QTY_std_Btl__c,
            ASI_CRM_Est_Total_QTY_std_Btl__c,
            ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
            ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
            ASI_CRM_CN_Sub_Brand__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
            ASI_CRM_CN_Sub_Brand__r.Name,
            ASI_CRM_Module__c,
            ASI_CRM_Module__r.ASI_CRM_Line_Type__c,
            ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,
            ASI_CRM_Module__r.ASI_CRM_Methodology__c,
            ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
            ASI_CRM_Module__r.ASI_CRM_CN_Expected_Est_Total__c,
            ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
            ASI_CRM_Type__c,
            ASI_CRM_Volume_Base__c,
            RecordType.DeveloperName
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
            WHERE ASI_CRM_CN_Contract__c = :thisCC.Id
        ];
        //Looping current contract Detail Lines
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : thisCC_BRSFList) {


            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c != '999'){
                
                V00SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                Decimal EstimateVolumes=0.0;

                //Get All BRSF Estimate Volumes and contract volume
                if((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ){
                    BRSFEstimateVolumesTotal += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                        POModiContractFI.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                    }
                }


                // (Estimate Qty Convert 9L * No of Months) ASI_CRM_CN_Estimate_Volume_9L_Month__c
                if (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                    POModiContractFI.Volumes += (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c* ContractLine.ASI_CRM_CN_No_of_Months__c);
                    EstimateVolumes = (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                }else{
                    EstimateVolumes = 0;
                }

                //Sub-Brand Grouping for 'POModiContractFI' and 'NewContactV0Contract'
                String SubbrandGroupName='0. Not Specified';
                String SubBrandName='';
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                    SubbrandGroupName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c:ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                }

                if(POModiContractFI.SubBrandGradeGrouping.containsKey(SubBrandName)){
                    Decimal TempVolumes=POModiContractFI.SubBrandGradeGrouping.get(SubBrandName)+EstimateVolumes;
                    POModiContractFI.SubBrandGradeGrouping.remove(SubBrandName);//remove orignal one
                    POModiContractFI.SubBrandGradeGrouping.put(SubBrandName,TempVolumes);
                }else{
                    POModiContractFI.SubBrandGradeGrouping.put(SubBrandName,EstimateVolumes);
                }

                if(POModiContractFI.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                    Decimal TempVolumes=POModiContractFI.SubBrandGradeMap.get(SubbrandGroupName)+EstimateVolumes;
                    //remove orignal one
                    POModiContractFI.SubBrandGradeMap.remove(SubbrandGroupName);
                    POModiContractFI.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
                }else{
                    POModiContractFI.SubBrandGradeMap.put(SubbrandGroupName,EstimateVolumes);
                }

                //By Brande Product Category Grouping 'POModiContractFI' and 'NewContactV0Contract'
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c !=null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                    String CategoryName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    if(POModiContractFI.CategoryMap.containsKey(CategoryName)){
                        Decimal TempVolumes=POModiContractFI.CategoryMap.get(CategoryName)+EstimateVolumes;
                        //remove orignal one
                        POModiContractFI.CategoryMap.remove(CategoryName);
                        POModiContractFI.CategoryMap.put(CategoryName,TempVolumes);
                    }else{
                        POModiContractFI.CategoryMap.put(CategoryName,EstimateVolumes);
                    }
                }// end of By Brande Product Category Grouping

                String LineKey=SBGradeSorting(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                if(POModiContractFI.ContractLineMap.containsKey(LineKey)){
                    POModiContractFI.ContractLineMap.get(LineKey).VFinalFees = POModiContractFI.ContractLineMap.get(LineKey).VFinalFees + ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    POModiContractFI.ContractLineMap.get(LineKey).VFinalVolume+=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.VFinalFees = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    ContractDetail.VFinalTotalFees= ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c *ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c:0;

                    ContractDetail.VFinalVolume=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    POModiContractFI.ContractLineMap.put(LineKey,ContractDetail);
                }

                if (EstVolume_map.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    Decimal estvol = EstVolume_map.get(ContractLine.ASI_CRM_CN_Sub_Brand__c)+ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c;
                    EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, estvol );
                }else{
                    EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c);
                }

            }

            // if (ContractLine.ASI_CRM_Type__c=='Fixed' && !ModuleIds.contains(ContractLine.ASI_CRM_Module__c))
            // {
            //     POModiContractFI.FixedExpense += ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Expected_Est_Total__c!=null? ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Expected_Est_Total__c : 0;
            // }

            if (ContractLine.ASI_CRM_Type__c !='Fixed') {
                VariableExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }

            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' ){
                PSFEstTotal+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='Variable Event Cost' ){
                VECEstTotal+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }


            // if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
            //     POModiContractFI.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
            //     POModiContractFI.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
            // }else{
            //     POModiContractFI.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
            //     POModiContractFI.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
            // }


        }

        AdditionalFIMap.put('PSFEstTotal',PSFEstTotal);
        AdditionalFIMap.put('VECEstTotal',VECEstTotal);

        Map<String,ASI_CRM_CN_FixedMappingSetting__c> settingMap = ASI_CRM_CN_FixedMappingSetting__c.getAll();
        for (ASI_CRM_CN_FixedMappingSetting__c fixedField : settingMap.values()) {
            POModiContractFI.FixedExpense += thisCC.get(fixedField.ASI_CRM_CN_Contract_Mapping_Field__c) != null ? Decimal.valueOf(String.valueOf(thisCC.get(fixedField.ASI_CRM_CN_Contract_Mapping_Field__c))):0;
        }

        POModiContractFI.VariableExpense =0;
        POModiContractFI.VariableExpense+=thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        POModiContractFI.VariableExpense+=thisCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
        POModiContractFI.VariableExpense+=thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c!=null?thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
        POModiContractFI.TradeExpenses = POModiContractFI.VariableExpense + POModiContractFI.FixedExpense;

        //POModiContractFI.VariableExpense=TotalVariableCost;

        //CR12Factor
        Map<String,Decimal> CR12FactorMap = GenerateCR12FactorMap(V00SubBrandIdSet, CommercialTeam, strRegion);

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine :thisCC_BRSFList){
            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||  (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){

                Decimal CR12Factor=1;
                if(CR12FactorMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    CR12Factor=CR12FactorMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                }
                if (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                    POModiContractFI.IntakeCR12 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                }
            }
        }

        // contract std volumes
        if (BRSFEstimateVolumesTotal != null && POModiContractFI.NoOfMonths != null){
            POModiContractFI.IntakeSTD=BRSFEstimateVolumesTotal * POModiContractFI.NoOfMonths;
        }

        Map<String, Decimal> POMv1_sbvol = new Map<String, Decimal>(); // Date --->Volume
        Set<Id> AllOutlet = new Set<Id>();
        if(thisCC.ASI_CRM_Volume_Option__c == 'Wholesaler Only' ){
            AllOutlet.add(thisCC.ASI_CRM_CN_Outlet_WS__c);
        }else{
            AllOutlet.add(thisCC.ASI_CRM_CN_Outlet_WS__c);
            for (ASI_CRM_CN_Covered_Outlet__c CO_temp: [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id]){
                AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
            }
        }

        POModiContractFI.OutletSet=AllOutlet;

        Date CutOffDay =GenerateCutOffDate();
        Date TillEnd;
        if (CutOffDay >= thisCC.ASI_CRM_CN_PO_End_Date__c)
            TillEnd = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c);
        else
            TillEnd = CutOffDay;
        Integer PeriodA = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
        Integer PeriodB = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);

        Set<Id> POMv1_sbid = new Set<Id>();

        Decimal TotalBlackCap_prorate=0;
        Decimal Total_IntakeBtl_prorate=0;
        Decimal TotalBC_prorate=0;

        Decimal Total_MartellBC =0;  // total contract Martel BC
        Decimal Total_MartellIntakeBtl =0;  // total contract Martel Intake Btl
        Decimal Total_MartellBlackCap =0;  // total contract Martel BlackCap


        //**************************Looping Sub-Brand Volume**************************
        for (ASI_CRM_Subbrand_Volume__c SubBrandVolume: retrieveSubBrandVolumes(thisCC))
        {
            String SubbrandGroupName='0. Not Specified';
            if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                SubbrandGroupName=SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null?SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c :SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            }

            Decimal Volumes = getVolume(SubBrandVolume, '9L');
            Decimal VolumeBtl = getVolume(SubBrandVolume, 'std');
            Decimal VariableBottles =0;

            //BC
            Decimal BottleCollection=0;
            BottleCollection += SubBrandVolume.ASI_CRM_Green_Cap_STD__c != null? SubBrandVolume.ASI_CRM_Green_Cap_STD__c:0;
            BottleCollection += SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c != null? SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c:0;

            TotalBC += BottleCollection;
            TotalBC_prorate+=BottleCollection;

            //Black Cap ASI_CRM_DeductCapWithIssue_StdBill__c
            Decimal BlackCap=0;
            BlackCap+= SubBrandVolume.ASI_CRM_Cap_with_Issues_Std_Billing__c != null? SubBrandVolume.ASI_CRM_Cap_with_Issues_Std_Billing__c:0;

            TotalBackCap+=BlackCap;
            TotalBlackCap_prorate+=BlackCap;


            Total_IntakeBtl+=VolumeBtl;
            Total_IntakeBtl_prorate+=VolumeBtl;

            if( ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c) ){
                Total_MartellBC += BottleCollection;
                Total_MartellIntakeBtl+=VolumeBtl;
                Total_MartellBlackCap+=BlackCap;
            }


            //**prorate**
            if (PeriodA != 0 && PeriodA != null && PeriodB != 0 && PeriodB != null){
                Volumes = Volumes/PeriodA * PeriodB;
                VolumeBtl = VolumeBtl/PeriodA * PeriodB;
                BlackCap= BlackCap/PeriodA * PeriodB;
                BottleCollection=BottleCollection/PeriodA * PeriodB;
                VariableBottles = VolumeBtl/PeriodB ;//<----Monthly (Std. Btl)                               (VolumeBtl/PeriodA) * PeriodB;
            }
            TotalBlackCap_prorate+=BlackCap;
            TotalBC_prorate+=BottleCollection;
            Total_IntakeBtl_prorate+=VolumeBtl;

            //POModiContractFI.IntakeSTD+=VolumeBtl;
            //POModiContractFI.Volumes += Volumes;

            Date pomdate= FYConversion(SubBrandVolume.ASI_CRM_End_Date__c);
            String strkey = String.valueOf(pomdate) + SubBrandVolume.ASI_CRM_Subbrand__c;

            POModiContractFI.InvestmentCR12 += SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c:0;
            POModiContractFI.InvestmentCR12 += SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c:0;
            POModiContractFI.InvestmentCR12 += SubBrandVolume.ASI_CRM_PR_Direct_CR12__c!=null? SubBrandVolume.ASI_CRM_PR_Direct_CR12__c:0;


            ////Actual Volume (9L) = T1_Depletion + T2_Depletion + PR_Direct
            Decimal ActualVolume=0;
            ActualVolume+=SubBrandVolume.ASI_CRM_T1_Depletion__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion__c:0;
            ActualVolume+=SubBrandVolume.ASI_CRM_T2_Depletion__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion__c:0;
            ActualVolume+=SubBrandVolume.ASI_CRM_PR_Direct__c!=null? SubBrandVolume.ASI_CRM_PR_Direct__c:0;

            //POModiContractFI.Volumes+=ActualVolume;
            if (POMv1_sbvol != null && POMv1_sbvol.containsKey(strkey)){
                ActualVolume += POMv1_sbvol.get(strkey);
                POMv1_sbvol.put(strkey, ActualVolume);
            }else{
                POMv1_sbvol.put(strkey,ActualVolume);
            }

            POMv1_sbid.add(SubBrandVolume.ASI_CRM_Subbrand__c);



            // if(POModiContractFI.SubBrandGradeMap.containsKey(SubbrandGroupName)){
            //     Decimal TempVolumes=POModiContractFI.SubBrandGradeMap.get(SubbrandGroupName)+Volumes;
            //     //remove orignal one
            //     POModiContractFI.SubBrandGradeMap.remove(SubbrandGroupName);
            //     POModiContractFI.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
            // }else{
            //     POModiContractFI.SubBrandGradeMap.put(SubbrandGroupName,Volumes);
            // }



            String SuBBrandKey =SBGradeSorting(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + SubBrandVolume.ASI_CRM_Subbrand__r.Name;

            if(POModiContractFI.ContractLineMap.containsKey(SuBBrandKey)){
                POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalBottles =POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalBottles + VariableBottles ;
                //POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalTotalFees +=  POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalFees * VarTotal;
                POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalActualVolume = POModiContractFI.ContractLineMap.get(SuBBrandKey).VFinalActualVolume + VariableBottles ;
            }else{
                ContractLine ContractDetail = new ContractLine ();
                ContractDetail.VFinalBottles = VariableBottles;
                ContractDetail.VFinalActualVolume=VariableBottles;
                ContractDetail.SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.Name;
                ContractDetail.SubBrandGrade= SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                POModiContractFI.ContractLineMap.put(SuBBrandKey,ContractDetail);
            }



        }// End of Looping Sub-Brand Volume




        AdditionalFIMap.put('Total_MartellBC',Total_MartellBC);
        AdditionalFIMap.put('Total_MartellIntakeBtl',Total_MartellIntakeBtl);
        AdditionalFIMap.put('Total_MartellBlackCap',Total_MartellBlackCap);


        AdditionalFIMap.put('TotalBackCap',TotalBackCap);
        AdditionalFIMap.put('TotalBC',TotalBC);
        AdditionalFIMap.put('Total_IntakeBtl',Total_IntakeBtl);

        AdditionalFIMap.put('TotalBlackCap_prorate',TotalBlackCap_prorate);
        AdditionalFIMap.put('Total_IntakeBtl_prorate',Total_IntakeBtl_prorate);
        AdditionalFIMap.put('TotalBC_prorate',TotalBC_prorate);

        if(TotalBC!=0 && TotalBC !=null && Total_IntakeBtl !=null && Total_IntakeBtl!=0){
            POModiContractFI.TotalBCRate=(TotalBC/Total_IntakeBtl)*100;
            POModiContractFI.NetBCRate=((TotalBC-TotalBackCap)/Total_IntakeBtl)*100;
        }


        //Prorate
        if (thisCC.ASI_CRM_CN_PO_End_Date__c > CutOffDay){
            Integer daysperiod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
            Integer prorateperiod = MonthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
            if (prorateperiod < 0)
                prorateperiod = 0;

            Decimal AverageCR12= 0;
            Decimal Average9L= 0;
            //for Latest Investment CR12
            if (daysperiod != null && daysperiod != 0 && POModiContractFI.InvestmentCR12 != 0)
                AverageCR12 = POModiContractFI.InvestmentCR12 / daysperiod;
            if (prorateperiod != 0 && prorateperiod != null && AverageCR12 != null && AverageCR12 !=0)
                POModiContractFI.InvestmentCR12 += AverageCR12 * prorateperiod ;

        }

        if (thisCC != null && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null && POModiContractFI.InvestmentCR12 != 0){
            //POModiContractFI.IntakeCR12=POModiContractFI.InvestmentCR12;
            POModiContractFI.InvestmentCR12 = thisCC.ASI_CRM_CN_Total_Contract_Amount__c / POModiContractFI.InvestmentCR12;
        }



        Date v1startdate = getEndDate(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        Date v1enddate;
        if (thisCC.ASI_CRM_CN_PO_End_Date__c < CutOffDay){
            v1enddate = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c);
        }else{
            v1enddate = CutOffDay;
        }

        Map<Date, Decimal> Lastest_Period_map = checkFYDayPeriod(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        System.debug('PO Modi : Lastest_Period_map'+Lastest_Period_map);
        Map<String, subbrand_data> Lastest_ROImap = new Map <String, subbrand_data>();
        if (Lastest_Period_map != null && Lastest_Period_map.size() > 0){
            String strkey = null;
            for (Date v1period : Lastest_Period_map.keySet()){
                if (V00SubBrandIdSet != null && V00SubBrandIdSet.size() > 0){
                    for (Id sbid : V00SubBrandIdSet){
                        strkey = String.valueOf(v1period) + sbid;
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = Lastest_Period_map.get(v1period);
                        newitem.SubBrandId = sbid;
                        newitem.year = String.valueOf(FYConversion(v1period).year());
                        newitem.TotalVolume = 0;
                        newitem.TotalEstVolume = 0;
                        Lastest_ROImap.put(strkey, newitem);
                    }
                }
            }
        }

        //Calculate RegionSubBrandCM_Map
        String currentFY = String.valueOf(FYConversion(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';

        System.debug('RegionSubBrandCM_Map SQL : currentFY:'+currentFY+'currentFY2:'+currentFY2);
        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal> ();
        for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c,ASI_CRM_TYPE__c FROM ASI_CRM_CM_GS__c
        WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2  OR ASI_CRM_YEAR__c = :currentFY3 ) AND
        ASI_CRM_Region__c = :strRegion  AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS' OR ASI_CRM_TYPE__c = 'Budget A&D')
        AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0   AND ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS')
        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            Decimal cm=0.0;
            if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
            }
            if (!RegionSubBrandCM_Map.containsKey(ProductCode + lbcm.ASI_CRM_TYPE__c) && cm != 0){
                RegionSubBrandCM_Map.put(ProductCode + lbcm.ASI_CRM_TYPE__c,cm) ;
                
            }
        }

        // Map<String, Decimal> latestContributionMargin = new Map<String, Decimal>();
        // Map<String, Decimal> latestBudgetContributionMargin = new Map<String, Decimal>();
        // Map<String, Decimal> latestGrossSales = new Map<String, Decimal>();

        // System.debug('Now PO Mod v1startdate'+v1startdate);
        // System.debug('Now PO Mod v1enddate'+v1enddate);

        // for (ASI_CRM_CM_GS__c v1budgetcmtemp : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
        // FROM ASI_CRM_CM_GS__c
        // WHERE ASI_CRM_PRODUCTCODE__c IN :POMv1_sbid
        // AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
        // AND ASI_CRM_CN_Month_End_Date__c >= :v1startdate
        // AND ASI_CRM_CN_Month_End_Date__c <= :v1enddate
        // AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS' )
        // AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != NULL ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
        // {
        //     String subBrandId = v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c;
        //     String strkey = String.valueOf(v1budgetcmtemp.ASI_CRM_CN_Month_End_Date__c) + subBrandId;
        //     Decimal ActualData = denullify(v1budgetcmtemp.ASI_CRM_CM_GS_per_9L__c);


        //     if (v1budgetcmtemp.ASI_CRM_TYPE__c == 'YTD GS'){
        //         if (!latestGrossSales.containsKey(subBrandId)){
        //             latestGrossSales.put(subBrandId, ActualData);
        //         }
        //         if (Lastest_ROImap != null && Lastest_ROImap.containsKey(strkey)){
        //             if (Lastest_ROImap.get(strkey).GS == null || Lastest_ROImap.get(strkey).GS == 0){
        //                 Lastest_ROImap.get(strkey).GS = ActualData;
        //                 //POModiContractFI.GSId+=v1budgetcmtemp.Id+';';
        //             }
        //         }
        //     }
        //     if (v1budgetcmtemp.ASI_CRM_TYPE__c == 'YTD CM'){
        //         if (Lastest_ROImap != null && Lastest_ROImap.containsKey(strkey)){
        //             if (Lastest_ROImap.get(strkey).CM == null || Lastest_ROImap.get(strkey).CM == 0){
        //                 Lastest_ROImap.get(strkey).CM = ActualData;
        //                 //POModiContractFI.CMId+=v1budgetcmtemp.Id+';';
        //             }

        //             if (Lastest_ROImap.get(strkey).latestBudgetCM == null || Lastest_ROImap.get(strkey).latestBudgetCM == null){
        //                 if (RegionSubBrandCM_Map.containsKey(subBrandId)){
        //                     Lastest_ROImap.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(subBrandId);
        //                 }
        //             }

        //         }

        //         if (Lastest_ROImap != null && !latestContributionMargin.containsKey(subBrandId) && ActualData != null && ActualData != 0){
        //             latestContributionMargin.put(subBrandId, ActualData);
        //         }
        //         if (Lastest_ROImap != null && !latestBudgetContributionMargin.containsKey(subBrandId)){
        //             if (RegionSubBrandCM_Map.containsKey(subBrandId)) {
        //                 latestBudgetContributionMargin.put(subBrandId, RegionSubBrandCM_Map.get(subBrandId));
        //             }
        //         }
        //     }



        // }// End of CM/GS Looping

        // Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> CMGSBySubBrand = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
        // if(Lastest_ROImap != null && Lastest_ROImap.size() > 0){
        //     Integer startToCutoffMonth = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
        //     Integer cutoffToEndMonth = MonthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
        //     if (cutoffToEndMonth < 0) cutoffToEndMonth = 0;
        //     Decimal Average9L = 0;

        //     /*
        //     What is the difference between actualVolume and projectedVolume?
        //     actualVolume: The volume from contract start to current. It should be taken from data.
        //     projectedVolume: The estimate volume when the whole contract end.
        //          The estimation comes from actualVolume, by calculating the monthly volume then multiples the whole contract period.
        //     */
        //     for (String v1roitemp : Lastest_ROImap.keySet()){
        //         String subBrandId = Lastest_ROImap.get(v1roitemp).SubBrandId;
        //         Decimal actualVolume = denullify(POMv1_sbvol.get(v1roitemp));
        //         ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.containsKey(subBrandId) ? CMGSBySubBrand.get(subBrandId) : new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();


        //         //**********Actual CM *********
        //         /*
        //         Total Contribution Margin = YTD Contribution Margin * CTD Volume + YTD Contribution Margin * Project Volume
        //         */
        //         Decimal actualcm =0;
        //         Decimal prorate_actualcm = 0;
        //         Average9L = actualVolume / startToCutoffMonth;

        //         if (Lastest_ROImap.get(v1roitemp).CM != null && Lastest_ROImap.get(v1roitemp).CM != 0){
        //             actualcm = Lastest_ROImap.get(v1roitemp).CM;
        //         }else if (latestContributionMargin.containsKey(subBrandId)){
        //             actualcm = latestContributionMargin.get(subBrandId);
        //         }

        //         if (actualcm != null){
        //             CMTotal += actualVolume * actualcm;
        //             CMGSData.CM += actualVolume * actualcm;

        //             if (latestContributionMargin.containsKey(subBrandId))
        //                 prorate_actualcm = latestContributionMargin.get(subBrandId);

        //             if (Average9L != null && cutoffToEndMonth != null && prorate_actualcm != null){
        //                 CMTotal += Average9L * cutoffToEndMonth * prorate_actualcm;
        //                 CMGSData.CM += Average9L * cutoffToEndMonth * prorate_actualcm;
        //             }

        //         }

        //         //*********Latest Budget CM*********
        //         /*
        //         Total Budget Contribution Margin = YTD Contribution Margin * CTD Volume  + YTD Contribution Margin * Project Volume
        //         */
        //         Decimal lbcm = 0;
        //         Decimal prorate_lbcm = 0;
        //         if (Lastest_ROImap.get(v1roitemp).latestBudgetCM != null && Lastest_ROImap.get(v1roitemp).latestBudgetCM != 0)
        //             lbcm = Lastest_ROImap.get(v1roitemp).latestBudgetCM;
        //         else if (latestBudgetContributionMargin.containsKey(subBrandId))
        //             lbcm = latestBudgetContributionMargin.get(subBrandId);
        //         if (lbcm != null){
        //             LatestBudgetCMTotal += actualVolume * lbcm;
        //             CMGSData.latestBudgetCM += actualVolume * lbcm;

        //             if (latestBudgetContributionMargin.containsKey(subBrandId))
        //                 prorate_lbcm = latestBudgetContributionMargin.get(subBrandId);

        //             if (Average9L != null && cutoffToEndMonth != null && prorate_lbcm != null) {
        //                 LatestBudgetCMTotal += Average9L * cutoffToEndMonth * prorate_lbcm;
        //                 CMGSData.latestBudgetCM += Average9L * cutoffToEndMonth * prorate_lbcm;
        //             }
        //         }

        //         //**********Actual GS*********
        //         /*
        //         Total Gross Sales = YTD Gross Sales * CTD Volume + YTD Gross Sales * Project Volume
        //         */

        //         Decimal ActualGS = 0;
        //         if (Lastest_ROImap.get(v1roitemp).GS != null && Lastest_ROImap.get(v1roitemp).GS != 0) {
        //             ActualGS = Lastest_ROImap.get(v1roitemp).GS;
        //         } else if (latestGrossSales.containsKey(subBrandId)) {
        //             ActualGS = latestGrossSales.get(subBrandId);
        //         }

        //         if (ActualGS != null){
        //             POModiContractFI.GrossSalesTotal += ActualGS * actualVolume;
        //             CMGSData.GS += ActualGS * actualVolume;
        //         }

        //         Decimal ActualGS_prorate = 0;
        //         if (latestGrossSales.containsKey(subBrandId)){
        //             ActualGS_prorate = latestGrossSales.get(subBrandId);
        //         }

        //         if(ActualGS_prorate!=null && actualVolume !=null && startToCutoffMonth !=null && startToCutoffMonth !=0 && cutoffToEndMonth !=null){
        //             POModiContractFI.GrossSalesTotal  += ActualGS_prorate * Average9L* cutoffToEndMonth;
        //             CMGSData.GS  += ActualGS_prorate * Average9L* cutoffToEndMonth;
        //         }

        //         CMGSBySubBrand.put(subBrandId, CMGSData);
        //     }
        // }
        // //        if(Lastest_ROImap != null && Lastest_ROImap.size() > 0){
        // //            Integer startToCutoffMonth = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
        // //            Integer cutoffToEndMonth = MonthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
        // //            if (cutoffToEndMonth < 0) cutoffToEndMonth = 0;
        // //
        // //            //                The original code is so bad that no one can understand, so I rewrite it using with better variable names and flow
        // //            for (String v1roitemp : Lastest_ROImap.keySet()){
        // //                Decimal actualVolume = denullify(POMv1_sbvol.get(v1roitemp));
        // //                Decimal projectedVolume = actualVolume / startToCutoffMonth * (startToCutoffMonth + cutoffToEndMonth);
        // //                String subBrandId = Lastest_ROImap.get(v1roitemp).SubBrandId;
        // //
        // //                //**********Actual GS*********
        // //                /*
        // //                Total Gross Sales = YTD Gross Sales * Projected Volume
        // //                 */
        // //                Decimal actualGS = Lastest_ROImap.get(v1roitemp).GS != null ? Lastest_ROImap.get(v1roitemp).GS : denullify(latestGrossSales.get(subBrandId));
        // //                POModiContractFI.GrossSalesTotal += actualGS * projectedVolume;
        // //
        // //                //**********Actual CM *********
        // //                /*
        // //                Total Contribution Margin = YTD Contribution Margin * Projected Volume
        // //                */
        // //                Decimal actualCM = Lastest_ROImap.get(v1roitemp).CM != null ? Lastest_ROImap.get(v1roitemp).CM : denullify(latestContributionMargin.get(subBrandId));
        // //                CMTotal += actualCM * projectedVolume;
        // //
        // //
        // //                //*********Latest Budget CM*********
        // //                /*
        // //                Total Budget Contribution Margin = YTD Contribution Margin * Projected Volume
        // //                */
        // //                Decimal latestBudgetCM = Lastest_ROImap.get(v1roitemp).latestBudgetCM != null ? Lastest_ROImap.get(v1roitemp).latestBudgetCM : denullify(latestBudgetContributionMargin.get(subBrandId));
        // //                LatestBudgetCMTotal += latestBudgetCM * projectedVolume;
        // //            }
        // //        }


        Date strStartBGDate;
        Date strEndBGDate;
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_Start_Date__c != null)
            strStartBGDate = getEndDate(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null)
            strEndBGDate = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1));

        Date strStartBGDate2 = Date.newInstance(strStartBGDate.addYears(-1).year(), 6, 30);
        Date strEndBGDate2 = Date.newInstance(strEndBGDate.year(), 6, 30);

        Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();


        for (ASI_CRM_CM_GS__c thisbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,
            ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c , ASI_CRM_CN_Month__c
        FROM ASI_CRM_CM_GS__c  WHERE ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
        AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
        AND ((ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate ) OR
        (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2 AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2 AND ASI_CRM_CN_Month__c = 6 ))
        AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS' OR ASI_CRM_TYPE__c = 'Budget A&D')
        AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != NULL
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS')
        ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            Date strCMdate = thisbcm.ASI_CRM_CN_Month_End_Date__c;
            String strkey = String.valueOf(strCMdate) + thisbcm.ASI_CRM_PRODUCTCODE__c;

            if(thisbcm.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + thisbcm.ASI_CRM_TYPE__c) && thisbcm.ASI_CRM_CM_GS_per_9L__c != null && thisbcm.ASI_CRM_CM_GS_per_9L__c != 0){
                cmgsMap.put(thisbcm.ASI_CRM_PRODUCTCODE__c + thisbcm.ASI_CRM_TYPE__c, thisbcm);
            }

            if (Lastest_ROImap.containsKey(strkey)){
                if (thisbcm.ASI_CRM_TYPE__c == 'Budget CM'){
                    if (Lastest_ROImap.get(strkey).CM == null || Lastest_ROImap.get(strkey).CM == 0){
                        Lastest_ROImap.get(strkey).CM = thisbcm.ASI_CRM_CM_GS_per_9L__c;
                    }
                }

                else if (thisbcm.ASI_CRM_TYPE__c == 'Budget GS'){
                    if (Lastest_ROImap.get(strkey).GS == null || Lastest_ROImap.get(strkey).GS == 0){
                        Lastest_ROImap.get(strkey).GS = thisbcm.ASI_CRM_CM_GS_per_9L__c;
                    }
                }

                else if (thisbcm.ASI_CRM_TYPE__c == 'Budget A&D'){
                    if (Lastest_ROImap.get(strkey).AD == null || Lastest_ROImap.get(strkey).AD == 0){
                        Lastest_ROImap.get(strkey).AD = thisbcm.ASI_CRM_CM_GS_per_9L__c;
                    }
                }

                if (Lastest_ROImap.containsKey(strkey)){
                    if (Lastest_ROImap.get(strkey).latestBudgetCM == null){
                        if ( RegionSubBrandCM_Map.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget CM')){
                            Lastest_ROImap.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget CM');
                        }
                    }
                    if (Lastest_ROImap.get(strkey).latestBudgetGS == null){
                        if ( RegionSubBrandCM_Map.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget GS')){
                            Lastest_ROImap.get(strkey).latestBudgetGS = RegionSubBrandCM_Map.get(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget GS');
                        }
                    }
                    if (Lastest_ROImap.get(strkey).latestBudgetAD == null){
                        if ( RegionSubBrandCM_Map.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget A&D')){
                            Lastest_ROImap.get(strkey).latestBudgetAD = RegionSubBrandCM_Map.get(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget A&D');
                        }
                    }
                }

            }
        }// End of looping Budget CM/GS


        //Replace null/0 value with latest CMGS data

        for(String key : Lastest_ROImap.keySet()){
            if(Lastest_ROImap.get(key).CM == null || Lastest_ROImap.get(key).CM == 0 || Lastest_ROImap.get(key).GS == null ||
                Lastest_ROImap.get(key).GS == 0 || Lastest_ROImap.get(key).AD == null || Lastest_ROImap.get(key).AD == 0 || 
                Lastest_ROImap.get(key).latestBudgetCM == null || Lastest_ROImap.get(key).latestBudgetCM == 0 || 
                Lastest_ROImap.get(key).latestBudgetGS == null || Lastest_ROImap.get(key).latestBudgetGS == 0 || 
                Lastest_ROImap.get(key).latestBudgetAD == null || Lastest_ROImap.get(key).latestBudgetAD == 0 ){
                if((Lastest_ROImap.get(key).CM == null || Lastest_ROImap.get(key).CM == 0) && cmgsMap.containsKey(Lastest_ROImap.get(key).SubBrandId + 'Budget CM')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(Lastest_ROImap.get(key).SubBrandId + 'Budget CM');

                    Lastest_ROImap.get(key).CM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }

                if((Lastest_ROImap.get(key).GS == null || Lastest_ROImap.get(key).GS == 0) && cmgsMap.containsKey(Lastest_ROImap.get(key).SubBrandId + 'Budget GS')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(Lastest_ROImap.get(key).SubBrandId + 'Budget GS');
                    Lastest_ROImap.get(key).GS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }

                if((Lastest_ROImap.get(key).AD == null || Lastest_ROImap.get(key).AD == 0) && cmgsMap.containsKey(Lastest_ROImap.get(key).SubBrandId + 'Budget A&D')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(Lastest_ROImap.get(key).SubBrandId + 'Budget A&D');
                    Lastest_ROImap.get(key).AD = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }

                if(Lastest_ROImap.get(key).latestBudgetCM == null || Lastest_ROImap.get(key).latestBudgetCM == 0){
                    if(RegionSubBrandCM_Map.containsKey(Lastest_ROImap.get(key).SubBrandId+ 'Budget CM'))
                        Lastest_ROImap.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(Lastest_ROImap.get(key).SubBrandId+ 'Budget CM');
                }

                if(Lastest_ROImap.get(key).latestBudgetGS == null || Lastest_ROImap.get(key).latestBudgetGS == 0){
                    if(RegionSubBrandCM_Map.containsKey(Lastest_ROImap.get(key).SubBrandId+ 'Budget GS'))
                        Lastest_ROImap.get(key).latestBudgetGS = RegionSubBrandCM_Map.get(Lastest_ROImap.get(key).SubBrandId+ 'Budget GS');
                }

                if(Lastest_ROImap.get(key).latestBudgetAD == null || Lastest_ROImap.get(key).latestBudgetAD == 0){
                    if(RegionSubBrandCM_Map.containsKey(Lastest_ROImap.get(key).SubBrandId+ 'Budget A&D'))
                        Lastest_ROImap.get(key).latestBudgetAD = RegionSubBrandCM_Map.get(Lastest_ROImap.get(key).SubBrandId+ 'Budget A&D');
                }
            }
        }


        Decimal CMTotal=0;
        Decimal LatestBudgetCMTotal = 0;
        Map<String, Decimal> CMSubbrandMap = new Map<String, Decimal>();
        Map<String, Decimal> latestCMSubbrandMap = new Map<String, Decimal>();
        Map<String, Decimal> GSSubbrandMap = new Map<String, Decimal>();

        if (Lastest_ROImap != null && Lastest_ROImap.size() > 0){
            Decimal ActualCM;
            Decimal LatestBudgetCM; // lbcm--> LatestBudgetCM
            Decimal ActualGS;
            Decimal LatestBudgetGs;
            Decimal ActualAD;
            Decimal LatestBudgetAD;
            Decimal TotalEstimateVol; // totalestimatevol--> TotalEstimateVol
            Decimal PeriodStr; //change from strperiod to PeriodStr
            for (String key : Lastest_ROImap.keySet()){
                PeriodStr= null;
                if (Lastest_ROImap.get(key).period != null){
                    PeriodStr = Lastest_ROImap.get(key).period;
                }

                //Budget CM
                ActualCM = null;
                if (Lastest_ROImap.get(key).CM != null){
                    ActualCM = Lastest_ROImap.get(key).CM;
                }

                //Latest Budget CM
                LatestBudgetCM = null;
                if (Lastest_ROImap.get(key).latestBudgetCM != null){
                    LatestBudgetCM = Lastest_ROImap.get(key).latestBudgetCM;
                }
                //Budget GS
                ActualGS = null;
                if (Lastest_ROImap.get(key).GS != null){
                    ActualGS = Lastest_ROImap.get(key).GS;
                }

                //Latest Budget GS
                LatestBudgetGS = null;
                if (Lastest_ROImap.get(key).latestBudgetGS != null){
                    LatestBudgetGS = Lastest_ROImap.get(key).latestBudgetGS;
                }

                //Budget AD
                ActualAD = null;
                if (Lastest_ROImap.get(key).AD != null){
                    ActualAD = Lastest_ROImap.get(key).AD;
                }

                LatestBudgetAD = null;
                if (Lastest_ROImap.get(key).latestBudgetAD != null){
                    LatestBudgetAD = Lastest_ROImap.get(key).latestBudgetAD;
                }

                TotalEstimateVol = 0;
                if (EstVolume_map != null && Lastest_ROImap.get(key) != null && Lastest_ROImap.get(key).SubBrandId != null && EstVolume_map.containsKey(Lastest_ROImap.get(key).SubBrandId)){
                    TotalEstimateVol = EstVolume_map.get(Lastest_ROImap.get(key).SubBrandId);
                }

                if (TotalEstimateVol != null && ActualCM != null && PeriodStr != null){
                    CMTotal += ActualCM * TotalEstimateVol * PeriodStr;
                    if (!CMSubbrandMap.containsKey(Lastest_ROImap.get(key).SubBrandId))
                    {
                        CMSubbrandMap.put(Lastest_ROImap.get(key).SubBrandId, ActualCM * TotalEstimateVol * PeriodStr);
                    }
                    CMSubbrandMap.put(Lastest_ROImap.get(key).SubBrandId,CMSubbrandMap.get(Lastest_ROImap.get(key).SubBrandId)+ ActualCM * TotalEstimateVol * PeriodStr);
                }

                if (TotalEstimateVol != null && LatestBudgetCM != null && PeriodStr != null){
                    LatestBudgetCMTotal += LatestBudgetCM * TotalEstimateVol * PeriodStr;
                    if (!latestCMSubbrandMap.containsKey(Lastest_ROImap.get(key).SubBrandId))
                    {
                        latestCMSubbrandMap.put(Lastest_ROImap.get(key).SubBrandId, LatestBudgetCM * TotalEstimateVol * PeriodStr);
                    }
                    latestCMSubbrandMap.put(Lastest_ROImap.get(key).SubBrandId,latestCMSubbrandMap.get(Lastest_ROImap.get(key).SubBrandId)+ LatestBudgetCM * TotalEstimateVol * PeriodStr);
                
                }

                if (TotalEstimateVol != null && ActualGS != null && PeriodStr != null){
                    POModiContractFI.GrossSalesTotal += ActualGS * TotalEstimateVol * PeriodStr;
                    if (!GSSubbrandMap.containsKey(Lastest_ROImap.get(key).SubBrandId))
                    {
                        GSSubbrandMap.put(Lastest_ROImap.get(key).SubBrandId,ActualGS * TotalEstimateVol * PeriodStr);
                    }
                    GSSubbrandMap.put(Lastest_ROImap.get(key).SubBrandId,CMSubbrandMap.get(Lastest_ROImap.get(key).SubBrandId)+ActualGS * TotalEstimateVol * PeriodStr);
                }

                if (TotalEstimateVol != null && LatestBudgetGs != null && PeriodStr != null){
                    POModiContractFI.GrossSalesTotalProForma += LatestBudgetGs * TotalEstimateVol * PeriodStr;
                }


                if (TotalEstimateVol != null && ActualAD != null && PeriodStr != null){
                    POModiContractFI.ADTotal += ActualAD * TotalEstimateVol * PeriodStr;
                }

                if (TotalEstimateVol != null && LatestBudgetAD != null && PeriodStr != null){
                    POModiContractFI.ADTotalProForma += LatestBudgetAD * TotalEstimateVol * PeriodStr;
                }

            }
        } // end of looping current_sbDataROI_map

        AdditionalFIMap.put('CMTotal',CMTotal);
        AdditionalFIMap.put('LatestBudgetCMTotal',LatestBudgetCMTotal);

        POModiContractFI.CMTotal=CMTotal;
        if (CMTotal != null && CMTotal != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null){
            POModiContractFI.ROIIntake = POModiContractFI.CMTotal / thisCC.ASI_CRM_CN_Total_Contract_Amount__c; // ROI_POM.strB
        }

        if (LatestBudgetCMTotal != null && LatestBudgetCMTotal != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != 0 && thisCC.ASI_CRM_CN_Total_Contract_Amount__c != null){
            POModiContractFI.LatestBudgetCMTotal=LatestBudgetCMTotal;
            POModiContractFI.ROIProForma = LatestBudgetCMTotal / thisCC.ASI_CRM_CN_Total_Contract_Amount__c; //ROI_POM.ProFormaROIstrB
        }

        // List<ASI_CRM_Subbrand_Volume__c> v0_VolList = new List<ASI_CRM_Subbrand_Volume__c>();
        // Date v0TillEndPOM = getEndDate(FindMinMaxDate(CutOffDay, thisCC.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        // v0_VolList = [SELECT Id, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,  ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c,ASI_CRM_Subbrand__c
        // FROM ASI_CRM_Subbrand_Volume__c WHERE  ASI_CRM_Account__c IN: AllOutlet AND ASI_CRM_CN_Competitor_Sub_brand__c != TRUE
        // AND ASI_CRM_End_Date__c >= :thisCC.ASI_CRM_CN_PO_Start_Date__c  AND ASI_CRM_End_Date__c <= :v0TillEndPOM AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE];


        // Decimal v0_actualvol_pom = 0;

        // if (v0_VolList != null && v0_VolList.size() > 0){
        //     for(ASI_CRM_Subbrand_Volume__c v0vol : v0_VolList){
        //         if (v0vol.ASI_CRM_T1_Depletion_CR12__c != null)
        //             v0_actualvol_pom += v0vol.ASI_CRM_T1_Depletion_CR12__c;
        //         if (v0vol.ASI_CRM_T2_Depletion_CR12__c != null)
        //             v0_actualvol_pom += v0vol.ASI_CRM_T2_Depletion_CR12__c;
        //         if (v0vol.ASI_CRM_PR_Direct_CR12__c != null)
        //             v0_actualvol_pom += v0vol.ASI_CRM_PR_Direct_CR12__c;
        //     }
        // }

        // Decimal v0_estvol_pom=0;
        // List<ASI_Attachment__c> AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
        // FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = : thisCC.Id AND ASI_CRM_Type__c ='Historical Modi Data' ];
        // if(AttachmentList.size()>0){
        //     for(ASI_Attachment__c att:AttachmentList){
        //         String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
        //         List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
        //         Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(HistoricalContractList[0].AddOnString,Map<String,Decimal>.class);
        //         if( TempMap.containsKey('v0_estvol_pom')  ){
        //             v0_estvol_pom= TempMap.get('v0_estvol_pom');
        //         }

        //     }
        // }



        // Date cutoffend;
        // if (CutOffDay > thisCC.ASI_CRM_CN_PO_End_Date__c)
        //     cutoffend = thisCC.ASI_CRM_CN_PO_End_Date__c;
        // else
        //     cutoffend = CutOffDay;
        // Integer thisCCPeriod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        // Integer v0CCPeriod = thisCCPeriod;
        // if (thisCC.ASI_CRM_CN_V0_0_PO_version__c != null)
        //     v0CCPeriod = MonthDiff(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c);
        // Integer THCTDPeriod = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, cutoffend);
        // Decimal ActVSEst_Vol = 0;
        // Decimal v0_actualVol_Period = 0;
        // Decimal v0_actualVol_Period_Month = 0;
        // AdditionalFIMap.put('v0_actualvol_pom',v0_actualvol_pom);

        // if (THCTDPeriod != null && THCTDPeriod != 0 && v0_actualvol_pom != null && v0_actualvol_pom != 0){
        //     v0_actualVol_Period_Month =  v0_actualvol_pom /  THCTDPeriod ;
        // }

        // if (v0_actualVol_Period_Month != null && v0_actualVol_Period_Month  != 0 && thisCCPeriod != null && thisCCPeriod != 0){
        //     v0_actualVol_Period  = v0_actualVol_Period_Month * thisCCPeriod ;
        // }


        // if (v0_actualVol_Period != null && v0_actualVol_Period != 0 && v0_estvol_pom != null && v0_estvol_pom != 0 && v0CCPeriod != null && v0CCPeriod != 0){
        //     ActVSEst_Vol = v0_actualVol_Period / (v0_estvol_pom * v0CCPeriod);
        // }

        // if(ActVSEst_Vol!=null){
        //     ActVSEst_Vol= ActVSEst_Vol*TotalVariableCost;
        // }

        AdditionalFIMap.put('ActVSEst_Vol',VariableExpense);

        //**************************Calculation**************************
        if(POModiContractFI.TradeExpenses !=0 && POModiContractFI.TradeExpenses !=null ){
            POModiContractFI.FixedExpenseRate = (POModiContractFI.FixedExpense / POModiContractFI.TradeExpenses *100).setScale(4);

        }

        //Calculate 'Investment per CR12 eq btl ' = Trade expenses / (CR12 Conversion Factor in Sub-brand * estimate Monthly vol. * PO Period in Sub-Brand )
        if (POModiContractFI.IntakeCR12 != 0 && POModiContractFI.IntakeCR12!= null &&  POModiContractFI.TradeExpenses != 0 &&  POModiContractFI.TradeExpenses != null){
            //POModiContractFI.IntakeCR12=POModiContractFI.InvestmentCR12;
            POModiContractFI.InvestmentCR12 =  (POModiContractFI.TradeExpenses / POModiContractFI.IntakeCR12).setScale(2);
        }

        //Calculate Historical V0 Cont. Margin after A&P = SUM( Budget CMs * estimate Monthly vol. in 9L  of PO period) - Trade expenses
        if (CMTotal != null && POModiContractFI.TradeExpenses != null){
            POModiContractFI.MarginAfterAnP = CMTotal - POModiContractFI.TradeExpenses;
        }

        //CM before spending proforma
        if (LatestBudgetCMTotal != null && POModiContractFI.TradeExpenses != null){
            POModiContractFI.MarginAfterAnPProForma = LatestBudgetCMTotal - POModiContractFI.TradeExpenses;
        }

        //Margin Per Bottle
        if (POModiContractFI.IntakeSTD!= 0 && POModiContractFI.IntakeSTD != null && POModiContractFI.MarginAfterAnP != 0 && POModiContractFI.MarginAfterAnP != null){
            POModiContractFI.MarginPerBottle = (POModiContractFI.MarginAfterAnP /POModiContractFI.IntakeSTD).setScale(4);
        }

        //Margin Per Bottle proforma
        if (POModiContractFI.IntakeSTD!= 0 && POModiContractFI.IntakeSTD != null && POModiContractFI.MarginAfterAnPProForma != 0 && POModiContractFI.MarginAfterAnPProForma != null){
            POModiContractFI.MarginPerBottleProForma = (POModiContractFI.MarginAfterAnPProForma /POModiContractFI.IntakeSTD).setScale(4);
        }

        //Gross Sales Rate Historical V0
        if (POModiContractFI.GrossSalesTotal  != null && POModiContractFI.GrossSalesTotal  != 0 && POModiContractFI.TradeExpenses!= 0 && POModiContractFI.TradeExpenses != null){
            POModiContractFI.GrossSalesRate = (POModiContractFI.TradeExpenses / POModiContractFI.GrossSalesTotal  *100).setScale(4);
        }

        //Gross Sales Rate ProForma
        if (POModiContractFI.GrossSalesTotalProForma  != null && POModiContractFI.GrossSalesTotalProForma  != 0 && POModiContractFI.TradeExpenses!= 0 && POModiContractFI.TradeExpenses != null){
            POModiContractFI.GrossSalesRateProForma = (POModiContractFI.TradeExpenses / POModiContractFI.GrossSalesTotalProForma  *100).setScale(4);
        }
        


        POModiContractFI.AddOnString = System.JSON.serialize(AdditionalFIMap);
        POModiContractFI.TradeExpenseBySubBrand = constructTradeExpenseBySubBrand2nd(thisCC, 'estimate', 'PO Modi');
        // Set CM/GS By Sub-Brand
        for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd tradeExpenseBreakdown : POModiContractFI.TradeExpenseBySubBrand) {
            if (!GSSubbrandMap.containsKey(tradeExpenseBreakdown.subBrandId)) {
                continue;
            }
            //ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.get(tradeExpenseBreakdown.subBrandId);

            tradeExpenseBreakdown.GSTotal = GSSubbrandMap.containsKey(tradeExpenseBreakdown.subBrandId)? GSSubbrandMap.get(tradeExpenseBreakdown.subBrandId):0;
            tradeExpenseBreakdown.CMTotal = CMSubbrandMap.containsKey(tradeExpenseBreakdown.subBrandId)? CMSubbrandMap.get(tradeExpenseBreakdown.subBrandId):0;
            tradeExpenseBreakdown.latestBudgetCMTotal = latestCMSubbrandMap.containsKey(tradeExpenseBreakdown.subBrandId)? latestCMSubbrandMap.get(tradeExpenseBreakdown.subBrandId):0;
        }

        POModiContractFI = calculateFIExcludeSelectedSubBrands2nd(POModiContractFI);

        //**************************Calculation 2nd KPI Sub-brand Trade Expense**************************
        Date setDate = FYConversion(Date.today());

        //Domestic Target
        Map<String, ASI_CRM_CM_GS__c>  DomesticTargetMap = GeneratingDomesticTarget(setDate,V00SubBrandIdSet);
        //Regional Target
        Map<String, ASI_CRM_CM_GS__c> RegionalAverageMap = GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,V00SubBrandIdSet);

        POModiContractFI = calculatedTradeExpense(POModiContractFI,DomesticTargetMap,RegionalAverageMap,RegionSubBrandCM_Map);
        //**************************Calculation 2nd KPI Sub-brand Trade Expense end**************************

        List<FinancialIndicator2nd> ReturnList = new List<FinancialIndicator2nd>();
        ReturnList.add(POModiContractFI);
        
        return ReturnList;

    }











    //PO Modification  (ASI_CRM_CN_ContractEmailCtrl - 2535)
    //@description: Restructure Historical PO Modi Record FI Data
    //@param: input current Contract
    //@return
    public static void RestructureHistoricalPOModiFIData(ASI_TH_CRM_Contract__c contract) {

        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal> ();
        Decimal CMTotalV0=0;
        Decimal LatestBudgetCMTotalV0 = 0;
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);
        String strRegion= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
        String CommercialTeam= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';


        FinancialIndicator V0POModiContractFI = new FinancialIndicator();
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        V0POModiContractFI.ContractId = thisCC.ASI_CRM_CN_V0_0_PO_version__c;
        V0POModiContractFI.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c);
        V0POModiContractFI.TradeExpenses = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c;

        Decimal v0_estvol_pom = 0;
        Decimal strv0VarCost = 0;

        Map<Id, Decimal> BRSF_SBVol = new Map<Id, Decimal>();
        Set<Id> V0SubBrandIdSet= new Set<Id>();

        //**************************Looping V0.0 BRSF Lines**************************
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>  ContractLineList = [SELECT Id,ASI_CRM_Type__c,RecordType.DeveloperName,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :
            thisCC.ASI_CRM_CN_V0_0_PO_version__c];

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c  ContractLine : ContractLineList){
            //if(pombrsf.ASI_CRM_CN_Sub_Brand__c !=null){
            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||
                (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){


                V0SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
            }
        }
        Map<String,Decimal> CR12FactorMap = GenerateCR12FactorMap(V0SubBrandIdSet, CommercialTeam, strRegion);

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c  pombrsf : ContractLineList){
            Decimal brsfvol_roi = 0;
            //if(pombrsf.ASI_CRM_CN_Sub_Brand__c !=null){

            if( ((pombrsf.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||  (pombrsf.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && pombrsf.ASI_CRM_Type__c=='BRSF' ) ) && pombrsf.ASI_CRM_CN_Sub_Brand__c!=null ){

                Decimal v0Brsf = 0;
                if (pombrsf.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                    Decimal CR12Factor=1;
                    if(CR12FactorMap.containsKey(pombrsf.ASI_CRM_CN_Sub_Brand__c)){
                        CR12Factor=CR12FactorMap.get(pombrsf.ASI_CRM_CN_Sub_Brand__c);
                    }
                    v0Brsf = pombrsf.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor;
                }
                v0_estvol_pom += v0Brsf ;
                if (pombrsf.ASI_CRM_CN_No_of_Months__c != null){
                    v0Brsf *= pombrsf.ASI_CRM_CN_No_of_Months__c;
                }
                if (pombrsf.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null){
                    brsfvol_roi = pombrsf.ASI_CRM_CN_Estimate_Volume_9L_Month__c ;
                }
                if (pombrsf.ASI_CRM_CN_Est_Total__c!= null)
                    strv0VarCost += pombrsf.ASI_CRM_CN_Est_Total__c;

                V0POModiContractFI.InvestmentCR12 += v0Brsf;


                if (BRSF_SBVol.containsKey(pombrsf.ASI_CRM_CN_Sub_Brand__c)){
                    brsfvol_roi += BRSF_SBVol.get(pombrsf.ASI_CRM_CN_Sub_Brand__c);
                    BRSF_SBVol.put(pombrsf.ASI_CRM_CN_Sub_Brand__c, brsfvol_roi);
                }else{
                    BRSF_SBVol.put(pombrsf.ASI_CRM_CN_Sub_Brand__c, brsfvol_roi);
                }
            }
        }
        AdditionalFIMap.put('v0_estvol_pom',v0_estvol_pom);


        if (V0POModiContractFI.InvestmentCR12 != null && V0POModiContractFI.InvestmentCR12 != 0 && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != null && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != 0)
            V0POModiContractFI.InvestmentCR12 = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c / V0POModiContractFI.InvestmentCR12 ;

        Date v0startdate= Date.today();
        Date v0enddate= Date.today();

        if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!= null){
            v0startdate = getEndDate(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        }

        if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!= null){
            v0enddate = getEndDate(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
        }

        String currentFY = String.valueOf(FYConversion(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';

        //Calculate RegionSubBrandCM_Map
        for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c FROM ASI_CRM_CM_GS__c
        WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3 )
        AND ASI_CRM_Region__c = :strRegion  AND ASI_CRM_TYPE__c = 'Budget CM' AND ASI_CRM_PRODUCTCODE__c IN :V0SubBrandIdSet
        AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS')
        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        {

            String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            Decimal cm=0.0;
            if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
            }
            if (!RegionSubBrandCM_Map.containsKey(ProductCode)){
                RegionSubBrandCM_Map.put(ProductCode,cm) ;
            }
        }






        Map<Date, Decimal> v0_Period_map = checkFYDayPeriod(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c);
        Map<String, subbrand_data> v0_ROImap = new Map <String, subbrand_data>();

        if (v0_Period_map != null && v0_Period_map.size() > 0){
            String strkey = null;
            for (Date v0period : v0_Period_map.keySet()){
                if (V0SubBrandIdSet != null && V0SubBrandIdSet.size() > 0){
                    for (Id sbid : V0SubBrandIdSet){
                        strkey = String.valueOf(v0period) + sbid;
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = v0_Period_map.get(v0period);
                        newitem.SubBrandId = sbid;
                        newitem.TotalVolume = 0;
                        v0_ROImap.put(strkey, newitem);
                    }
                }
            }
        }


        //Getting CM GS Data



        Date strStartBGDate2 = Date.newInstance(v0startdate.addYears(-1).year(), 6, 30);
        Date strEndBGDate2 = Date.newInstance(v0enddate.year(), 6, 30);

        Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();





        for (ASI_CRM_CM_GS__c v0budgetcmtemp : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Month__c
        FROM ASI_CRM_CM_GS__c  WHERE ASI_CRM_PRODUCTCODE__c IN :V0SubBrandIdSet
        AND (ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c   )
        AND ((ASI_CRM_CN_Month_End_Date__c >= :v0startdate AND ASI_CRM_CN_Month_End_Date__c <= :v0enddate ) OR
        (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2   AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2  AND ASI_CRM_CN_Month__c = 6 ))
        AND ASI_CRM_TYPE__c = 'Budget CM' AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != NULL
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS')
        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            String strkey = String.valueOf(v0budgetcmtemp.ASI_CRM_CN_Month_End_Date__c) + v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c;
            Decimal budgetcm = 0;
            if(v0budgetcmtemp.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c + v0budgetcmtemp.ASI_CRM_TYPE__c) && v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != null && v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != 0){
                cmgsMap.put(v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c + v0budgetcmtemp.ASI_CRM_TYPE__c, v0budgetcmtemp);
            }
            if (v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != null)
                budgetcm = v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c;
            if (v0_ROImap != null && v0_ROImap.containsKey(strkey)){
                if (v0_ROImap.get(strkey).CM == null || v0_ROImap.get(strkey).CM == 0){

                    if (v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != null && v0budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != 0){
                        v0_ROImap.get(strkey).CM = budgetcm;
                        //V0POModiContractFI.CMId+=v0budgetcmtemp.Id+';';
                    }
                }
                if (v0_ROImap.get(strkey).latestBudgetCM == null ||  v0_ROImap.get(strkey).latestBudgetCM == 0){
                    if (RegionSubBrandCM_Map.containsKey(v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c)){
                        v0_ROImap.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(v0budgetcmtemp.ASI_CRM_PRODUCTCODE__c);
                    }
                }
            }
        }


        //replace null/0 value with latest CMGS data
        for(String key : v0_ROImap.keySet()){
            if(v0_ROImap.get(key).CM == null || v0_ROImap.get(key).CM == 0 || v0_ROImap.get(key).latestBudgetCM == null || v0_ROImap.get(key).latestBudgetCM == 0){
                if((v0_ROImap.get(key).CM == null || v0_ROImap.get(key).CM == 0) && cmgsMap.containsKey(v0_ROImap.get(key).SubBrandId + 'Budget CM')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(v0_ROImap.get(key).SubBrandId + 'Budget CM');

                    v0_ROImap.get(key).CM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }

                if(v0_ROImap.get(key).latestBudgetCM == null || v0_ROImap.get(key).latestBudgetCM == 0){
                    if(RegionSubBrandCM_Map.containsKey(v0_ROImap.get(key).SubBrandId)){
                        v0_ROImap.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(v0_ROImap.get(key).SubBrandId);
                    }
                }
            }
        }


        if (v0_ROImap != null && v0_ROImap.size() > 0){
            for (String roitemp : v0_ROImap.keySet()){
                if (BRSF_SBVol != null && BRSF_SBVol.containsKey(v0_ROImap.get(roitemp).SubBrandId)){
                    v0_ROImap.get(roitemp).TotalVolume = BRSF_SBVol.get(v0_ROImap.get(roitemp).SubBrandId);
                }
                if (v0_ROImap.get(roitemp).TotalVolume != null && v0_ROImap.get(roitemp).CM != null && v0_ROImap.get(roitemp).period != null){
                    CMTotalV0 += v0_ROImap.get(roitemp).TotalVolume * v0_ROImap.get(roitemp).CM * v0_ROImap.get(roitemp).period;
                }

                if (v0_ROImap.get(roitemp).TotalVolume != null && v0_ROImap.get(roitemp).latestBudgetCM != null && v0_ROImap.get(roitemp).period != null){
                    LatestBudgetCMTotalV0 += v0_ROImap.get(roitemp).TotalVolume * v0_ROImap.get(roitemp).latestBudgetCM * v0_ROImap.get(roitemp).period;
                }

            }
        }



        if (CMTotalV0 != null && CMTotalV0 != 0 && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != null && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != 0){
            V0POModiContractFI.CMTotal=CMTotalV0;
            V0POModiContractFI.ROIIntake = (CMTotalV0 / thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c).setScale(2);
        }

        if (LatestBudgetCMTotalV0 != null && LatestBudgetCMTotalV0 != 0 && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != null && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != 0){
            V0POModiContractFI.LatestBudgetCMTotal=LatestBudgetCMTotalV0;
            V0POModiContractFI.ROIProForma = (LatestBudgetCMTotalV0 / thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c).setScale(2);
        }
        AdditionalFIMap.put('CMTotalV0',CMTotalV0);
        AdditionalFIMap.put('LatestBudgetCMTotalV0',LatestBudgetCMTotalV0);
        V0POModiContractFI.AddOnString = System.JSON.serialize(AdditionalFIMap);

        system.debug('thisCC.ASI_CRM_CN_V0_0_PO_version__c'+thisCC.ASI_CRM_CN_V0_0_PO_version__c);
        if (String.isNotBlank(thisCC.ASI_CRM_CN_V0_0_PO_version__c)) {
            V0POModiContractFI.TradeExpenseBySubBrand = constructTradeExpenseBySubBrand(getContract(thisCC.ASI_CRM_CN_V0_0_PO_version__c), 'estimate', 'PO Open');
        }
        
        V0POModiContractFI.TradeExpenseBySubBrand = updateCMGSInTradeExpenseBySubBrand(V0POModiContractFI, V0POModiContractFI.TradeExpenseBySubBrand, v0_ROImap);
        V0POModiContractFI = calculateFIExcludeSelectedSubBrands(V0POModiContractFI);


        List<FinancialIndicator> ReturnList = new List<FinancialIndicator>();
        ReturnList.add(V0POModiContractFI);
        UpsertAttachment(thisCC.Id, System.JSON.serialize(ReturnList),'Historical Modi Data' );



    }

    public static void RestructureHistoricalPOModiFIData2nd(ASI_TH_CRM_Contract__c contract) {

        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);
        ASI_TH_CRM_Contract__c V0POModiContract = new ASI_TH_CRM_Contract__c();
        V0POModiContract.Id = thisCC.ASI_CRM_CN_V0_0_PO_version__c;
        List<FinancialIndicator2nd> contractList = RestructureCurrentFinancialIndicatorDataList2nd(V0POModiContract);

        List<FinancialIndicator2nd> ReturnList = new List<FinancialIndicator2nd>();
        ReturnList.add(contractList.get(0));
        UpsertAttachment2nd(contract.Id, System.JSON.serialize(ReturnList),'Historical Modi Data' );

        UpsertAttachment2nd(contract.Id, System.JSON.serialize(contractList),'Contract Data' );
        UpsertKPIData(contract, contractList.get(0),null);
    }





    //@description: Restructure current PO Record
    //@param: input current Contract
    //@return NewContactV0Contract and NewContractV0Esitimate
    public static List<FinancialIndicator>  RestructureCurrentFinancialIndicatorData(ASI_TH_CRM_Contract__c contract){
        String strRegion='',CommercialTeam='';
        Set<Id> V00SubBrandIdSet= new Set<Id>();
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal> ();
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);

        strRegion= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
        CommercialTeam= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';

        FinancialIndicator  NewContractV0Esitimate= new FinancialIndicator(); //B    New Contract V0.0 Est.
        FinancialIndicator NewContactV0Contract = new FinancialIndicator(); //D  New Contact V0.0 Contract
        NewContractV0Esitimate.ContractId = thisCC.Id;
        NewContractV0Esitimate.ContractId = thisCC.Id;
        if (thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c != null){
            NewContractV0Esitimate.BCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
            NewContactV0Contract.BCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
            NewContractV0Esitimate.TotalBCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
            NewContactV0Contract.TotalBCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;

            NewContractV0Esitimate.TotalMBCRate = thisCC.ASI_CRM_Martell_BC_Rate__c!= null?thisCC.ASI_CRM_Martell_BC_Rate__c:0;
            NewContactV0Contract.TotalMBCRate = thisCC.ASI_CRM_Martell_BC_Rate__c!= null?thisCC.ASI_CRM_Martell_BC_Rate__c:0;
        }

        if (thisCC.ASI_CRM_CN_PO_Start_Date__c!= null){
            NewContractV0Esitimate.POStartDate= thisCC.ASI_CRM_CN_PO_Start_Date__c;
            NewContactV0Contract.POStartDate= thisCC.ASI_CRM_CN_PO_Start_Date__c;
        }
        if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null){
            NewContractV0Esitimate.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;
            NewContactV0Contract.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;
        }

        if (thisCC.ASI_CRM_CN_Contract_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Cost_Total__c != null){
            NewContactV0Contract.TradeExpenses += thisCC.ASI_CRM_CN_Contract_Cost_Total__c;
            NewContactV0Contract.FixedExpense += thisCC.ASI_CRM_CN_Contract_Cost_Total__c;
        }

        if (thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null){
            NewContractV0Esitimate.FixedExpense= thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
        }

        //Trade Expenses, Esitmate
        if (thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c!= 0 &&  thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c!= 0){
            NewContractV0Esitimate.TradeExpenses += thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
        }

        if(thisCC.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_No_of_Months__c != null){
            NewContactV0Contract.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
            NewContractV0Esitimate.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
        }

        //New Contract Period
        Map<Date, Decimal> thisCC_Period_map = checkFYDayPeriod(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        //key: date+SubBrand    for Current v0.0
        Map <String, subbrand_data> current_sbDataROI_map =new Map <String, subbrand_data>();

        Map<Id, Decimal> ConVolume_map = new Map<Id, Decimal>();
        Map<Id, Decimal> EstVolume_map  = new Map<Id, Decimal>();
        Decimal BRSFEstimateVolumesTotal=0;
        Decimal BRSFContractVolumesTotal=0;

        NewContactV0Contract.ContractLineMap = new Map<String,ContractLine>();
        NewContactV0Contract.FixedExpensesMap = new Map<String,ContractLine>();
        NewContactV0Contract.VariableExpensesMap= new Map<String,ContractLine>();

        for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c,ASI_CRM_CN_Activity_Code__c,
            ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,
            ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c
        FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id])
        {
            if (ccost.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                if (NewContactV0Contract.FixedExpensesMap != null && NewContactV0Contract.FixedExpensesMap.containsKey(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c)){
                    NewContactV0Contract.FixedExpensesMap.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).EstimateFees+= ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    NewContactV0Contract.FixedExpensesMap.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).ContractFees+= ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.EstimateFees =ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    ContractDetail.ContractFees = ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
                    NewContactV0Contract.FixedExpensesMap.put(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c,ContractDetail);

                }
            }else{
                String MapKeyStr='';
                if(ccost.ASI_CRM_CN_Activity_Code__c!=null && ccost.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c!=null){
                    MapKeyStr=ccost.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c;
                }
                if(NewContactV0Contract.VariableExpensesMap!=null && NewContactV0Contract.FixedExpensesMap.containsKey(MapKeyStr)){
                    NewContactV0Contract.VariableExpensesMap.get(MapKeyStr).EstimateFees+= ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    NewContactV0Contract.VariableExpensesMap.get(MapKeyStr).ContractFees+= ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;

                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.EstimateFees =ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    ContractDetail.ContractFees = ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
                    NewContactV0Contract.VariableExpensesMap.put(MapKeyStr,ContractDetail);
                }
            }
        }


        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> thisCC_BRSFList = [SELECT Id,
            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
            ASI_CRM_CN_Contract_Monthly_Qty__c,
            ASI_CRM_CN_Contract_Monthly_Vol9L__c,
            ASI_CRM_CN_Contract_Total_Dummy__c,
            ASI_CRM_CN_Contract_Total__c,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
            ASI_CRM_CN_Est_Monthly_Qty__c,
            ASI_CRM_CN_Est_Total_Dummy__c,
            ASI_CRM_CN_Est_Total__c,
            ASI_CRM_CN_Estimate_Volume_9L_Month__c,
            ASI_CRM_CN_No_of_Months__c,
            ASI_CRM_CN_Sub_Brand__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c,
            ASI_CRM_CN_Sub_Brand__r.Name,
            ASI_CRM_Module__c,
            ASI_CRM_Module__r.ASI_CRM_Line_Type__c,
            ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,
            ASI_CRM_Module__r.ASI_CRM_Methodology__c,
            ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
            ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
            ASI_CRM_Type__c,
            ASI_CRM_Volume_Base__c,
            RecordType.DeveloperName
        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :thisCC.Id];

        Set<String> PSFMethodologySet = new Set<String>();
        Set<String> PSFVolumeBaseSet = new Set<String>();
        //Looping BRSF Line
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : thisCC_BRSFList){

            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||
                (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){
                System.debug('NewcontractV00SubBrandIdSet :'+ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c);
                //if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){
                V00SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                Decimal EstimateVolumes=0.0;
                Decimal ContractVolumes=0.0;

                //Get All BRSF Estimate Volumes and contract volume
                if((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ){
                    BRSFEstimateVolumesTotal += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                    BRSFContractVolumesTotal += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                        NewContactV0Contract.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                        NewContractV0Esitimate.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                    }
                }


                // (Estimate Qty Convert 9L * No of Months) ASI_CRM_CN_Estimate_Volume_9L_Month__c
                if (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                    NewContractV0Esitimate.Volumes += (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c* ContractLine.ASI_CRM_CN_No_of_Months__c);
                    EstimateVolumes = (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                }else{
                    EstimateVolumes = 0;
                }
                // Volume 9L (Contract Qty Convert 9L * No of Months) ASI_CRM_CN_Contract_Monthly_Vol9L__c
                if (ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                    NewContactV0Contract.Volumes += (ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                    ContractVolumes = (ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                }else{
                    ContractVolumes = 0;
                }
                //Calculate Trade Expenses

                //Sub-Brand Grouping for 'NewContractV0Esitimate' and 'NewContactV0Contract'
                String SubbrandGroupName='0. Not Specified';
                String SubBrandName='';
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                    SubbrandGroupName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c:ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                }
                String LineKey=NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) +ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//SuBBrandKey;//

                if(NewContactV0Contract.ContractLineMap.containsKey(LineKey)){
                    NewContactV0Contract.ContractLineMap.get(LineKey).EstimateBottles += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                    NewContactV0Contract.ContractLineMap.get(LineKey).ContractBottles += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
                    NewContactV0Contract.ContractLineMap.get(LineKey).EstimateFees += ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null? ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c:0;
                    NewContactV0Contract.ContractLineMap.get(LineKey).ContractFees += ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null? ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c:0;

                    NewContactV0Contract.ContractLineMap.get(LineKey).EstimateVolume +=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                    NewContactV0Contract.ContractLineMap.get(LineKey).ContractVolume +=ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;




                    if(ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null){
                        NewContactV0Contract.ContractLineMap.get(LineKey).EstimateTotalFees += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * thisCC.ASI_CRM_CN_No_of_Months__c;
                    }
                    if(ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null ){
                        NewContactV0Contract.ContractLineMap.get(LineKey).ContractTotalFees += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c *thisCC.ASI_CRM_CN_No_of_Months__c;
                    }
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.EstimateBottles=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                    ContractDetail.ContractBottles = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
                    ContractDetail.EstimateFees  = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null?ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c:0;
                    ContractDetail.ContractFees =  ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null?ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c:0;

                    ContractDetail.EstimateVolume=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                    ContractDetail.ContractVolume=ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;

                    if(ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null){
                        ContractDetail.EstimateTotalFees = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * thisCC.ASI_CRM_CN_No_of_Months__c;
                    }
                    if(ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null ){
                        ContractDetail.ContractTotalFees = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c *thisCC.ASI_CRM_CN_No_of_Months__c;
                    }
                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    NewContactV0Contract.ContractLineMap.put(LineKey,ContractDetail);
                }


                if(NewContractV0Esitimate.SubBrandGradeGrouping.containsKey(SubBrandName)){
                    Decimal TempVolumes=NewContractV0Esitimate.SubBrandGradeGrouping.get(SubBrandName)+EstimateVolumes;
                    NewContractV0Esitimate.SubBrandGradeGrouping.remove(SubBrandName);//remove orignal one
                    NewContractV0Esitimate.SubBrandGradeGrouping.put(SubBrandName,TempVolumes);
                }else{
                    NewContractV0Esitimate.SubBrandGradeGrouping.put(SubBrandName,EstimateVolumes);
                }

                if(NewContactV0Contract.SubBrandGradeGrouping.containsKey(SubBrandName)){
                    Decimal TempVolumes=NewContactV0Contract.SubBrandGradeGrouping.get(SubBrandName)+ContractVolumes;
                    NewContactV0Contract.SubBrandGradeGrouping.remove(SubBrandName); //remove orignal one
                    NewContactV0Contract.SubBrandGradeGrouping.put(SubBrandName,TempVolumes);
                }else{
                    NewContactV0Contract.SubBrandGradeGrouping.put(SubBrandName,ContractVolumes);
                }


                if(NewContractV0Esitimate.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                    Decimal TempVolumes=NewContractV0Esitimate.SubBrandGradeMap.get(SubbrandGroupName)+EstimateVolumes;
                    //remove orignal one
                    NewContractV0Esitimate.SubBrandGradeMap.remove(SubbrandGroupName);
                    NewContractV0Esitimate.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
                }else{
                    NewContractV0Esitimate.SubBrandGradeMap.put(SubbrandGroupName,EstimateVolumes);
                }

                if(NewContactV0Contract.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                    Decimal TempVolumes=NewContactV0Contract.SubBrandGradeMap.get(SubbrandGroupName)+ContractVolumes;
                    //remove orignal one
                    NewContactV0Contract.SubBrandGradeMap.remove(SubbrandGroupName);
                    NewContactV0Contract.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
                }else{
                    NewContactV0Contract.SubBrandGradeMap.put(SubbrandGroupName,ContractVolumes);
                }

                //By Brande Product Category Grouping 'NewContractV0Esitimate' and 'NewContactV0Contract'
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c !=null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                    String CategoryName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    if(NewContractV0Esitimate.CategoryMap.containsKey(CategoryName)){
                        Decimal TempVolumes=NewContractV0Esitimate.CategoryMap.get(CategoryName)+EstimateVolumes;
                        //remove orignal one
                        NewContractV0Esitimate.CategoryMap.remove(CategoryName);
                        NewContractV0Esitimate.CategoryMap.put(CategoryName,TempVolumes);
                    }else{
                        NewContractV0Esitimate.CategoryMap.put(CategoryName,EstimateVolumes);
                    }
                    if(NewContactV0Contract.CategoryMap.containsKey(CategoryName)){
                        Decimal TempVolumes=NewContactV0Contract.CategoryMap.get(CategoryName)+ContractVolumes;
                        //remove orignal one
                        NewContactV0Contract.CategoryMap.remove(CategoryName);
                        NewContactV0Contract.CategoryMap.put(CategoryName,TempVolumes);
                    }else{
                        NewContactV0Contract.CategoryMap.put(CategoryName,ContractVolumes);
                    }
                }// end of By Brande Product Category Grouping


                if(thisCC_Period_map != null && thisCC_Period_map.size() > 0){
                    for (Date V0CCdate : thisCC_Period_map.keySet() ){
                        Date strDateCC = FYConversion(V0CCdate);
                        String strkey_p = String.valueOf(strDateCC) + ContractLine.ASI_CRM_CN_Sub_Brand__c ;
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = thisCC_Period_map.get(V0CCdate);//This fiscal year's month number
                        newitem.SubBrandId = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                        newitem.TotalVolume = 0;
                        newitem.TotalEstVolume = 0;
                        current_sbDataROI_map.put(strkey_p, newitem);
                    }
                }

                if (ConVolume_map.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    Decimal convol = ConVolume_map.get(ContractLine.ASI_CRM_CN_Sub_Brand__c) + ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c;
                    ConVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, convol);
                }else{
                    ConVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c);
                }

                if (EstVolume_map.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    Decimal estvol = EstVolume_map.get(ContractLine.ASI_CRM_CN_Sub_Brand__c)+ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c;
                    EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, estvol );
                }else{
                    EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c);
                }

            }else{ // not by sub-Brand
                //NewContractV0Esitimate.TradeExpenses +=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                //NewContactV0Contract.TradeExpenses+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
            }

            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Module__c!=null){
                if(!PSFMethodologySet.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                    PSFMethodologySet.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                    NewContactV0Contract.PSFMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                    NewContractV0Esitimate.PSFMethodologyName+=ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                }
                if(!PSFVolumeBaseSet.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                    PSFVolumeBaseSet.add(ContractLine.ASI_CRM_Volume_Base__c);
                    NewContactV0Contract.PSFVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                    NewContractV0Esitimate.PSFVolumeBase+=VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                }
            }


            NewContractV0Esitimate.TradeExpenses+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

            NewContactV0Contract.TradeExpenses+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;

            NewContractV0Esitimate.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            NewContactV0Contract.VariableExpense+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;

        }// end of Looping BRSF Line


        //CR12Factor
        Map<String,Decimal> CR12FactorMap = GenerateCR12FactorMap(V00SubBrandIdSet, CommercialTeam, strRegion);

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine :thisCC_BRSFList){
            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||  (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){

                Decimal CR12Factor=1;
                if(CR12FactorMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    CR12Factor=CR12FactorMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                }
                if (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                    NewContractV0Esitimate.IntakeCR12 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                }
                if(ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!= null){
                    NewContactV0Contract.IntakeCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                }

            }
        }


        //Calculate RegionSubBrandCM_Map
        String currentFY = String.valueOf(FYConversion(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';
        Map<String,ASI_CRM_CM_GS__c> SubBrandCM_Map = new Map<String,ASI_CRM_CM_GS__c> ();

        for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c FROM ASI_CRM_CM_GS__c
        WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3) AND
        ASI_CRM_Region__c = :strRegion  AND ASI_CRM_TYPE__c = 'Budget CM'
        AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS')
        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        {// and ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
            String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            Decimal cm=0.0;
            if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
            }
            if (!RegionSubBrandCM_Map.containsKey(ProductCode)){
                RegionSubBrandCM_Map.put(ProductCode,cm) ;
                SubBrandCM_Map.put(ProductCode,lbcm);
            }
        }




        //for querying Budget CM
        Date strStartBGDate;
        Date strEndBGDate;
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_Start_Date__c != null)
            strStartBGDate = getEndDate(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null)
            strEndBGDate = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1));

        Date strStartBGDate2 = Date.newInstance(strStartBGDate.addYears(-1).year(), 6, 30);
        Date strEndBGDate2 = Date.newInstance(strEndBGDate.year(), 6, 30);

        Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();


        for (ASI_CRM_CM_GS__c thisbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,
            ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c , ASI_CRM_CN_Month__c
        FROM ASI_CRM_CM_GS__c  WHERE ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
        AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
        AND ((ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate ) OR
        (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2 AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2 AND ASI_CRM_CN_Month__c = 6 ))
        AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
        AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != NULL
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS')
        ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            Date strCMdate = thisbcm.ASI_CRM_CN_Month_End_Date__c;
            String strkey = String.valueOf(strCMdate) + thisbcm.ASI_CRM_PRODUCTCODE__c;

            if(thisbcm.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + thisbcm.ASI_CRM_TYPE__c) && thisbcm.ASI_CRM_CM_GS_per_9L__c != null && thisbcm.ASI_CRM_CM_GS_per_9L__c != 0){
                cmgsMap.put(thisbcm.ASI_CRM_PRODUCTCODE__c + thisbcm.ASI_CRM_TYPE__c, thisbcm);
            }

            if (current_sbDataROI_map.containsKey(strkey)){
                if (thisbcm.ASI_CRM_TYPE__c == 'Budget CM'){
                    if (current_sbDataROI_map.get(strkey).CM == null || current_sbDataROI_map.get(strkey).CM == 0){
                        current_sbDataROI_map.get(strkey).CM = thisbcm.ASI_CRM_CM_GS_per_9L__c;
                        //NewContactV0Contract.CMId+=thisbcm.Id+';';
                    }
                    /*if (current_sbDataROI_map.get(strkey).latestBudgetCM == null){ current_sbDataROI_map.get(strkey).latestBudgetCM =thisbcm.ASI_CRM_CM_GS_per_9L__c;}*/
                }

                if (thisbcm.ASI_CRM_TYPE__c == 'Budget GS'){
                    if (current_sbDataROI_map.get(strkey).GS == null || current_sbDataROI_map.get(strkey).GS == 0){
                        current_sbDataROI_map.get(strkey).GS= thisbcm.ASI_CRM_CM_GS_per_9L__c;
                        //NewContactV0Contract.GSId+=thisbcm.Id+';';
                    }
                }

                if (current_sbDataROI_map.containsKey(strkey)){
                    if (current_sbDataROI_map.get(strkey).latestBudgetCM == null){
                        if ( RegionSubBrandCM_Map.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c)){
                            current_sbDataROI_map.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(thisbcm.ASI_CRM_PRODUCTCODE__c);
                        }
                    }
                }

            }
        }// End of looping Budget CM/GS


        //Replace null/0 value with latest CMGS data

        for(String key : current_sbDataROI_map.keySet()){
            if(current_sbDataROI_map.get(key).CM == null || current_sbDataROI_map.get(key).CM == 0 || current_sbDataROI_map.get(key).GS == null ||
                current_sbDataROI_map.get(key).GS == 0 || current_sbDataROI_map.get(key).latestBudgetCM == null || current_sbDataROI_map.get(key).latestBudgetCM == 0){
                if((current_sbDataROI_map.get(key).CM == null || current_sbDataROI_map.get(key).CM == 0) && cmgsMap.containsKey(current_sbDataROI_map.get(key).SubBrandId + 'Budget CM')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(current_sbDataROI_map.get(key).SubBrandId + 'Budget CM');

                    current_sbDataROI_map.get(key).CM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }

                if((current_sbDataROI_map.get(key).GS == null || current_sbDataROI_map.get(key).GS == 0) && cmgsMap.containsKey(current_sbDataROI_map.get(key).SubBrandId + 'Budget GS')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(current_sbDataROI_map.get(key).SubBrandId + 'Budget GS');
                    current_sbDataROI_map.get(key).GS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }

                if(current_sbDataROI_map.get(key).latestBudgetCM == null || current_sbDataROI_map.get(key).latestBudgetCM == 0){
                    if(RegionSubBrandCM_Map.containsKey(current_sbDataROI_map.get(key).SubBrandId))
                        current_sbDataROI_map.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(current_sbDataROI_map.get(key).SubBrandId);
                }
            }
        }


        Decimal CMTotalV0Estimate=0;
        Decimal CMTotalV0Contract=0;
        Decimal LatestBudgetCMTotalV0Estimate = 0;
        Decimal LatestBudgetCMTotalV0Contract = 0;

        if (current_sbDataROI_map != null && current_sbDataROI_map.size() > 0){
            Decimal ActualCM;
            Decimal LatestBudgetCM; // lbcm--> LatestBudgetCM
            Decimal ActualGS;
            Decimal TotalActualVol;// totalactualvol--->TotalActualVol
            Decimal TotalEstimateVol; // totalestimatevol--> TotalEstimateVol
            Decimal PeriodStr; //change from strperiod to PeriodStr
            for (String key : current_sbDataROI_map.keySet()){
                PeriodStr= null;
                if (current_sbDataROI_map.get(key).period != null){
                    PeriodStr = current_sbDataROI_map.get(key).period;
                }

                //Budget CM
                ActualCM = null;
                if (current_sbDataROI_map.get(key).CM != null){
                    ActualCM = current_sbDataROI_map.get(key).CM;
                }

                //Latest Budget CM
                LatestBudgetCM = null;
                if (current_sbDataROI_map.get(key).latestBudgetCM != null){
                    LatestBudgetCM = current_sbDataROI_map.get(key).latestBudgetCM;
                }
                //Budget GS
                ActualGS = null;
                if (current_sbDataROI_map.get(key).GS != null){
                    ActualGS = current_sbDataROI_map.get(key).GS;
                }

                //Total Volume
                TotalActualVol = null;
                if (ConVolume_map != null && current_sbDataROI_map.get(key) != null && current_sbDataROI_map.get(key).SubBrandId != null && ConVolume_map.containsKey(current_sbDataROI_map.get(key).SubBrandId)){
                    TotalActualVol = ConVolume_map.get(current_sbDataROI_map.get(key).SubBrandId);
                }
                TotalEstimateVol = null;
                if (EstVolume_map != null && current_sbDataROI_map.get(key) != null && current_sbDataROI_map.get(key).SubBrandId != null && EstVolume_map.containsKey(current_sbDataROI_map.get(key).SubBrandId)){
                    TotalEstimateVol = EstVolume_map.get(current_sbDataROI_map.get(key).SubBrandId);
                }
                if (TotalEstimateVol != null && ActualCM != null && PeriodStr != null){
                    CMTotalV0Estimate += ActualCM * TotalEstimateVol * PeriodStr;
                }

                if (TotalEstimateVol != null && LatestBudgetCM != null && PeriodStr != null){
                    LatestBudgetCMTotalV0Estimate += LatestBudgetCM * TotalEstimateVol * PeriodStr;
                }

                if (TotalEstimateVol != null && ActualGS != null && PeriodStr != null){
                    NewContractV0Esitimate.GrossSalesTotal += ActualGS * TotalEstimateVol * PeriodStr;
                }
                if (TotalActualVol != null && ActualCM != null && PeriodStr != null){
                    CMTotalV0Contract += ActualCM * TotalActualVol * PeriodStr;
                }

                if (TotalActualVol != null && LatestBudgetCM != null && PeriodStr != null){
                    LatestBudgetCMTotalV0Contract += LatestBudgetCM * TotalActualVol * PeriodStr;
                }

                if (TotalActualVol != null && ActualGS != null && PeriodStr != null){
                    NewContactV0Contract.GrossSalesTotal += ActualGS * TotalActualVol * PeriodStr;
                }

            }
        } // end of looping current_sbDataROI_map

        //**************************Calculation**************************

        if(NewContractV0Esitimate.TradeExpenses !=0 && NewContractV0Esitimate.TradeExpenses !=null ){
            NewContractV0Esitimate.FixedExpenseRate = (NewContractV0Esitimate.FixedExpense / NewContractV0Esitimate.TradeExpenses *100).setScale(2);

        }
        if(NewContactV0Contract.TradeExpenses !=0 && NewContactV0Contract.TradeExpenses !=null ){
            NewContactV0Contract.FixedExpenseRate = (NewContactV0Contract.FixedExpense / NewContactV0Contract.TradeExpenses *100).setScale(2);
        }

        //Calculate 'Investment per CR12 eq btl ' = Trade expenses / (CR12 Conversion Factor in Sub-brand * estimate Monthly vol. * PO Period in Sub-Brand )
        if (NewContractV0Esitimate.IntakeCR12 != 0 && NewContractV0Esitimate.IntakeCR12!= null &&  NewContractV0Esitimate.TradeExpenses != 0 &&  NewContractV0Esitimate.TradeExpenses != null){
            //NewContractV0Esitimate.IntakeCR12=NewContractV0Esitimate.InvestmentCR12;
            NewContractV0Esitimate.InvestmentCR12 =  (NewContractV0Esitimate.TradeExpenses / NewContractV0Esitimate.IntakeCR12).setScale(2);
        }
        if (NewContactV0Contract.IntakeCR12 != 0 && NewContactV0Contract.IntakeCR12!= null &&  NewContactV0Contract.TradeExpenses != 0 &&  NewContactV0Contract.TradeExpenses != null){
            //NewContactV0Contract.IntakeCR12=NewContactV0Contract.InvestmentCR12;
            NewContactV0Contract.InvestmentCR12 =  (NewContactV0Contract.TradeExpenses / NewContactV0Contract.IntakeCR12).setScale(2);
        }

        //Calculate Historical V0 Cont. Margin after A&P = SUM( Budget CMs * estimate Monthly vol. in 9L  of PO period) - Trade expenses
        if (CMTotalV0Estimate != null && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.MarginAfterAnP = CMTotalV0Estimate - NewContractV0Esitimate.TradeExpenses;
        }
        if (CMTotalV0Estimate != null && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.MarginAfterAnP = CMTotalV0Contract - NewContactV0Contract.TradeExpenses;
        }

        if (BRSFContractVolumesTotal != null && NewContractV0Esitimate.NoOfMonths != null){

            //NewContractV0Esitimate.MarginPerBottle =BRSFContractVolumesTotal * NewContractV0Esitimate.NoOfMonths;
            NewContractV0Esitimate.IntakeSTD=BRSFEstimateVolumesTotal * NewContractV0Esitimate.NoOfMonths;
        }
        if (BRSFEstimateVolumesTotal != null && NewContractV0Esitimate.NoOfMonths != null){
            //NewContactV0Contract.MarginPerBottle =BRSFEstimateVolumesTotal * NewContractV0Esitimate.NoOfMonths;
            NewContactV0Contract.IntakeSTD = BRSFContractVolumesTotal* NewContactV0Contract.NoOfMonths;
        }


        //Margin Per Bottle
        if (NewContractV0Esitimate.IntakeSTD!= 0 && NewContractV0Esitimate.IntakeSTD != null && NewContractV0Esitimate.MarginAfterAnP != 0 && NewContractV0Esitimate.MarginAfterAnP != null){
            NewContractV0Esitimate.MarginPerBottle = (NewContractV0Esitimate.MarginAfterAnP /NewContractV0Esitimate.IntakeSTD).setScale(2);
        }
        if (NewContactV0Contract.IntakeSTD!= 0 && NewContactV0Contract.IntakeSTD != null && NewContactV0Contract.MarginAfterAnP != 0 && NewContactV0Contract.MarginAfterAnP != null){
            NewContactV0Contract.MarginPerBottle = (NewContactV0Contract.MarginAfterAnP / NewContactV0Contract.IntakeSTD).setScale(2);
        }

        //Gross Sales Rate Historical V0
        if (NewContractV0Esitimate.GrossSalesTotal  != null && NewContractV0Esitimate.GrossSalesTotal  != 0 && NewContractV0Esitimate.TradeExpenses!= 0 && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.GrossSalesRate = (NewContractV0Esitimate.TradeExpenses / NewContractV0Esitimate.GrossSalesTotal  *100).setScale(2);
        }
        if (NewContactV0Contract.GrossSalesTotal  != null && NewContactV0Contract.GrossSalesTotal  != 0 && NewContactV0Contract.TradeExpenses!= 0 && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.GrossSalesRate = (NewContactV0Contract.TradeExpenses / NewContactV0Contract.GrossSalesTotal  *100).setScale(2);
        }


        // ROI Intake Historical V0 = Cont. Margin before A&P / Trade expenses
        if (CMTotalV0Estimate != null && CMTotalV0Estimate != 0 && NewContractV0Esitimate.TradeExpenses != 0 && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.CMTotal=CMTotalV0Estimate;
            NewContractV0Esitimate.ROIIntake = (CMTotalV0Estimate / NewContractV0Esitimate.TradeExpenses).setScale(2);
            NewContractV0Esitimate.ROIActual=NewContractV0Esitimate.ROIIntake;
        }

        if (CMTotalV0Contract != null && CMTotalV0Contract != 0 && NewContactV0Contract.TradeExpenses != 0 && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.CMTotal=CMTotalV0Contract;
            NewContactV0Contract.ROIIntake = CMTotalV0Contract / NewContactV0Contract.TradeExpenses;
            NewContactV0Contract.ROIActual=NewContactV0Contract.ROIIntake;
        }

        //Calculate ROIProForma = Cont. Margin before A&P from latest CM regardless FY / Trade expenses
        if (LatestBudgetCMTotalV0Estimate != null && LatestBudgetCMTotalV0Estimate != 0 && NewContractV0Esitimate.TradeExpenses != 0 && NewContractV0Esitimate.TradeExpenses!= null){
            NewContractV0Esitimate.LatestBudgetCMTotal=LatestBudgetCMTotalV0Estimate;
            NewContractV0Esitimate.ROIProForma = LatestBudgetCMTotalV0Estimate/ NewContractV0Esitimate.TradeExpenses;
        }

        if (LatestBudgetCMTotalV0Contract != null && LatestBudgetCMTotalV0Contract != 0 && NewContactV0Contract.TradeExpenses != 0 && NewContactV0Contract.TradeExpenses!= null){
            NewContactV0Contract.LatestBudgetCMTotal=LatestBudgetCMTotalV0Contract;
            NewContactV0Contract.ROIProForma = LatestBudgetCMTotalV0Contract/ NewContactV0Contract.TradeExpenses;
        }

        NewContactV0Contract.TradeExpenseBySubBrand = constructTradeExpenseBySubBrand(thisCC, 'contract', 'PO Open');
        NewContractV0Esitimate.TradeExpenseBySubBrand = constructTradeExpenseBySubBrand(thisCC, 'estimate', 'PO Open');

        NewContactV0Contract.TradeExpenseBySubBrand = updateCMGSInTradeExpenseBySubBrand(NewContactV0Contract, NewContactV0Contract.TradeExpenseBySubBrand, current_sbDataROI_map);
        NewContractV0Esitimate.TradeExpenseBySubBrand = updateCMGSInTradeExpenseBySubBrand(NewContractV0Esitimate, NewContractV0Esitimate.TradeExpenseBySubBrand, current_sbDataROI_map);

        NewContactV0Contract = calculateFIExcludeSelectedSubBrands(NewContactV0Contract);
        NewContractV0Esitimate = calculateFIExcludeSelectedSubBrands(NewContractV0Esitimate);


        List<FinancialIndicator> ReturnList = new List<FinancialIndicator>();

        ReturnList.add(NewContractV0Esitimate);
        ReturnList.add(NewContactV0Contract);
        UpsertAttachment(thisCC.Id, System.JSON.serialize(ReturnList),'Contract Data' );

        return ReturnList;
    }

    //@description: Restructure current PO Record for 2ndKPI
    //@param: input current Contract
    //@return NewContactV0Contract and NewContractV0Esitimate
    public static List<FinancialIndicator2nd>  RestructureCurrentFinancialIndicatorData2nd(ASI_TH_CRM_Contract__c contract){
        List<FinancialIndicator2nd> ReturnList = RestructureCurrentFinancialIndicatorDataList2nd(contract);
        FinancialIndicator2nd NewContractV0Esitimate = ReturnList.get(0);
        FinancialIndicator2nd NewContractV0Contract = ReturnList.get(1);
        
        UpsertAttachment2nd(contract.Id, System.JSON.serialize(ReturnList),'Contract Data' );
        UpsertKPIData(contract, NewContractV0Esitimate,null);
        return ReturnList;
    }


    //@description: Restructure current PO Record for 2ndKPI
    //@param: input current Contract
    //@return NewContactV0Contract and NewContractV0Esitimate
    public static List<FinancialIndicator2nd>  RestructureCurrentFinancialIndicatorDataList2nd(ASI_TH_CRM_Contract__c contract){
        String strRegion='',CommercialTeam='';

        String channel='',region='',cityInvestementGrade='',newImage='';

        Set<Id> V00SubBrandIdSet= new Set<Id>();
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal> ();
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);

        strRegion= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
        CommercialTeam= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';

        channel = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
        region = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
        cityInvestementGrade = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
        newImage = thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;

        FinancialIndicator2nd  NewContractV0Esitimate= new FinancialIndicator2nd(); //B    New Contract V0.0 Est.
        FinancialIndicator2nd NewContactV0Contract = new FinancialIndicator2nd(); //D  New Contact V0.0 Contract
        NewContractV0Esitimate.ContractId = thisCC.Id;
        NewContractV0Esitimate.ContractId = thisCC.Id;
        if (thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c != null){
            NewContractV0Esitimate.BCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
            NewContactV0Contract.BCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
            NewContractV0Esitimate.TotalBCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;
            NewContactV0Contract.TotalBCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c;

            NewContractV0Esitimate.TotalMBCRate = thisCC.ASI_CRM_Martell_BC_Rate__c!= null?thisCC.ASI_CRM_Martell_BC_Rate__c:0;
            NewContactV0Contract.TotalMBCRate = thisCC.ASI_CRM_Martell_BC_Rate__c!= null?thisCC.ASI_CRM_Martell_BC_Rate__c:0;
        }

        if (thisCC.ASI_CRM_CN_PO_Start_Date__c!= null){
            NewContractV0Esitimate.POStartDate= thisCC.ASI_CRM_CN_PO_Start_Date__c;
            NewContactV0Contract.POStartDate= thisCC.ASI_CRM_CN_PO_Start_Date__c;
        }
        if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null){
            NewContractV0Esitimate.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;
            NewContactV0Contract.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;
        }

        //Fixed Expense changed to module 
        // if (thisCC.ASI_CRM_CN_Contract_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Cost_Total__c != null){
        //     NewContactV0Contract.TradeExpenses += thisCC.ASI_CRM_CN_Contract_Cost_Total__c;
        //     NewContactV0Contract.FixedExpense += thisCC.ASI_CRM_CN_Contract_Cost_Total__c;
        // }

        // if (thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null){
        //     NewContractV0Esitimate.FixedExpense= thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
        // }

        // //Trade Expenses, Esitmate
        // if (thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c!= 0 &&  thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c!= 0){
        //     NewContractV0Esitimate.TradeExpenses += thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
        // }

        if(thisCC.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_No_of_Months__c != null){
            NewContactV0Contract.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
            NewContractV0Esitimate.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
        }

        //New Contract Period
        Map<Date, Decimal> thisCC_Period_map = checkFYDayPeriod(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        //key: date+SubBrand    for Current v0.0
        Map <String, subbrand_data> current_sbDataROI_map =new Map <String, subbrand_data>();

        Map<Id, Decimal> ConVolume_map = new Map<Id, Decimal>();
        Map<Id, Decimal> EstVolume_map  = new Map<Id, Decimal>();
        Decimal BRSFEstimateVolumesTotal=0;
        Decimal BRSFContractVolumesTotal=0;

        NewContactV0Contract.ContractLineMap = new Map<String,ContractLine>();
        //2ndKPI remove
        //NewContactV0Contract.FixedExpensesMap = new Map<String,ContractLine>();   
        //NewContactV0Contract.VariableExpensesMap= new Map<String,ContractLine>();  

        // for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c,ASI_CRM_CN_Activity_Code__c,
        //     ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,
        //     ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c
        // FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id])
        // {
        //     if (ccost.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
        //         if (NewContactV0Contract.FixedExpensesMap != null && NewContactV0Contract.FixedExpensesMap.containsKey(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c)){
        //             NewContactV0Contract.FixedExpensesMap.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).EstimateFees+= ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
        //             NewContactV0Contract.FixedExpensesMap.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).ContractFees+= ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
        //         }else{
        //             ContractLine ContractDetail = new ContractLine ();
        //             ContractDetail.EstimateFees =ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
        //             ContractDetail.ContractFees = ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
        //             NewContactV0Contract.FixedExpensesMap.put(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c,ContractDetail);

        //         }
        //     }else{
        //         String MapKeyStr='';
        //         if(ccost.ASI_CRM_CN_Activity_Code__c!=null && ccost.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c!=null){
        //             MapKeyStr=ccost.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c;
        //         }
        //         if(NewContactV0Contract.VariableExpensesMap!=null && NewContactV0Contract.FixedExpensesMap.containsKey(MapKeyStr)){
        //             NewContactV0Contract.VariableExpensesMap.get(MapKeyStr).EstimateFees+= ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
        //             NewContactV0Contract.VariableExpensesMap.get(MapKeyStr).ContractFees+= ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;

        //         }else{
        //             ContractLine ContractDetail = new ContractLine ();
        //             ContractDetail.EstimateFees =ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
        //             ContractDetail.ContractFees = ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
        //             NewContactV0Contract.VariableExpensesMap.put(MapKeyStr,ContractDetail);
        //         }
        //     }
        // }


        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> thisCC_BRSFList = [SELECT Id,
            ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
            ASI_CRM_CN_Contract_Monthly_Qty__c,
            ASI_CRM_CN_Contract_Monthly_Vol9L__c,
            ASI_CRM_CN_Contract_Total_Dummy__c,
            ASI_CRM_CN_Contract_Total__c,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
            ASI_CRM_CN_Est_Monthly_Qty__c,
            ASI_CRM_CN_Est_Total_Dummy__c,
            ASI_CRM_CN_Est_Total__c,
            ASI_CRM_CN_Estimate_Volume_9L_Month__c,
            ASI_CRM_CN_No_of_Months__c,
            ASI_CRM_CN_Sub_Brand__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
            ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c,
            ASI_CRM_CN_Sub_Brand__r.Name,
            ASI_CRM_Module__c,
            ASI_CRM_Module__r.ASI_CRM_Line_Type__c,
            ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,
            ASI_CRM_Module__r.ASI_CRM_Methodology__c,
            ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
            ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
            ASI_CRM_Type__c,
            ASI_CRM_Volume_Base__c,
            RecordType.DeveloperName
        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :thisCC.Id];

        Set<String> PSFMethodologySet = new Set<String>();
        Set<String> PSFVolumeBaseSet = new Set<String>();
        //Looping BRSF Line
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : thisCC_BRSFList){

            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||
                (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){
                System.debug('NewcontractV00SubBrandIdSet :'+ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c);
                //if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){
                V00SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                Decimal EstimateVolumes=0.0;
                Decimal ContractVolumes=0.0;

                //Get All BRSF Estimate Volumes and contract volume
                if((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ){
                    BRSFEstimateVolumesTotal += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                    BRSFContractVolumesTotal += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                        NewContactV0Contract.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                        NewContractV0Esitimate.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                    }
                }


                // (Estimate Qty Convert 9L * No of Months) ASI_CRM_CN_Estimate_Volume_9L_Month__c
                if (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                    NewContractV0Esitimate.Volumes += (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c* ContractLine.ASI_CRM_CN_No_of_Months__c);
                    EstimateVolumes = (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                }else{
                    EstimateVolumes = 0;
                }
                // Volume 9L (Contract Qty Convert 9L * No of Months) ASI_CRM_CN_Contract_Monthly_Vol9L__c
                if (ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                    NewContactV0Contract.Volumes += (ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                    ContractVolumes = (ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                }else{
                    ContractVolumes = 0;
                }
                //Calculate Trade Expenses

                //Sub-Brand Grouping for 'NewContractV0Esitimate' and 'NewContactV0Contract'
                String SubbrandGroupName='0. Not Specified';
                String SubBrandName='';
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                    SubbrandGroupName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c:ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                }
                String LineKey=NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) +ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//SuBBrandKey;//

                if(NewContactV0Contract.ContractLineMap.containsKey(LineKey)){
                    NewContactV0Contract.ContractLineMap.get(LineKey).EstimateBottles += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                    NewContactV0Contract.ContractLineMap.get(LineKey).ContractBottles += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
                    NewContactV0Contract.ContractLineMap.get(LineKey).EstimateFees += ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null? ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c:0;
                    NewContactV0Contract.ContractLineMap.get(LineKey).ContractFees += ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null? ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c:0;

                    NewContactV0Contract.ContractLineMap.get(LineKey).EstimateVolume +=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                    NewContactV0Contract.ContractLineMap.get(LineKey).ContractVolume +=ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;




                    if(ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null){
                        NewContactV0Contract.ContractLineMap.get(LineKey).EstimateTotalFees += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * thisCC.ASI_CRM_CN_No_of_Months__c;
                    }
                    if(ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null ){
                        NewContactV0Contract.ContractLineMap.get(LineKey).ContractTotalFees += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c *thisCC.ASI_CRM_CN_No_of_Months__c;
                    }
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.EstimateBottles=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                    ContractDetail.ContractBottles = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
                    ContractDetail.EstimateFees  = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null?ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c:0;
                    ContractDetail.ContractFees =  ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null?ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c:0;

                    ContractDetail.EstimateVolume=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                    ContractDetail.ContractVolume=ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;

                    if(ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null){
                        ContractDetail.EstimateTotalFees = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * thisCC.ASI_CRM_CN_No_of_Months__c;
                    }
                    if(ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null ){
                        ContractDetail.ContractTotalFees = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c *thisCC.ASI_CRM_CN_No_of_Months__c;
                    }
                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    NewContactV0Contract.ContractLineMap.put(LineKey,ContractDetail);
                }


                if(NewContractV0Esitimate.SubBrandGradeGrouping.containsKey(SubBrandName)){
                    Decimal TempVolumes=NewContractV0Esitimate.SubBrandGradeGrouping.get(SubBrandName)+EstimateVolumes;
                    NewContractV0Esitimate.SubBrandGradeGrouping.remove(SubBrandName);//remove orignal one
                    NewContractV0Esitimate.SubBrandGradeGrouping.put(SubBrandName,TempVolumes);
                }else{
                    NewContractV0Esitimate.SubBrandGradeGrouping.put(SubBrandName,EstimateVolumes);
                }

                if(NewContactV0Contract.SubBrandGradeGrouping.containsKey(SubBrandName)){
                    Decimal TempVolumes=NewContactV0Contract.SubBrandGradeGrouping.get(SubBrandName)+ContractVolumes;
                    NewContactV0Contract.SubBrandGradeGrouping.remove(SubBrandName); //remove orignal one
                    NewContactV0Contract.SubBrandGradeGrouping.put(SubBrandName,TempVolumes);
                }else{
                    NewContactV0Contract.SubBrandGradeGrouping.put(SubBrandName,ContractVolumes);
                }


                if(NewContractV0Esitimate.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                    Decimal TempVolumes=NewContractV0Esitimate.SubBrandGradeMap.get(SubbrandGroupName)+EstimateVolumes;
                    //remove orignal one
                    NewContractV0Esitimate.SubBrandGradeMap.remove(SubbrandGroupName);
                    NewContractV0Esitimate.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
                }else{
                    NewContractV0Esitimate.SubBrandGradeMap.put(SubbrandGroupName,EstimateVolumes);
                }

                if(NewContactV0Contract.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                    Decimal TempVolumes=NewContactV0Contract.SubBrandGradeMap.get(SubbrandGroupName)+ContractVolumes;
                    //remove orignal one
                    NewContactV0Contract.SubBrandGradeMap.remove(SubbrandGroupName);
                    NewContactV0Contract.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
                }else{
                    NewContactV0Contract.SubBrandGradeMap.put(SubbrandGroupName,ContractVolumes);
                }

                //By Brande Product Category Grouping 'NewContractV0Esitimate' and 'NewContactV0Contract'
                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c !=null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                    String CategoryName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    if(NewContractV0Esitimate.CategoryMap.containsKey(CategoryName)){
                        Decimal TempVolumes=NewContractV0Esitimate.CategoryMap.get(CategoryName)+EstimateVolumes;
                        //remove orignal one
                        NewContractV0Esitimate.CategoryMap.remove(CategoryName);
                        NewContractV0Esitimate.CategoryMap.put(CategoryName,TempVolumes);
                    }else{
                        NewContractV0Esitimate.CategoryMap.put(CategoryName,EstimateVolumes);
                    }
                    if(NewContactV0Contract.CategoryMap.containsKey(CategoryName)){
                        Decimal TempVolumes=NewContactV0Contract.CategoryMap.get(CategoryName)+ContractVolumes;
                        //remove orignal one
                        NewContactV0Contract.CategoryMap.remove(CategoryName);
                        NewContactV0Contract.CategoryMap.put(CategoryName,TempVolumes);
                    }else{
                        NewContactV0Contract.CategoryMap.put(CategoryName,ContractVolumes);
                    }
                }// end of By Brande Product Category Grouping


                if(thisCC_Period_map != null && thisCC_Period_map.size() > 0){
                    for (Date V0CCdate : thisCC_Period_map.keySet() ){
                        Date strDateCC = FYConversion(V0CCdate);
                        String strkey_p = String.valueOf(strDateCC) + ContractLine.ASI_CRM_CN_Sub_Brand__c ;
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = thisCC_Period_map.get(V0CCdate);//This fiscal year's month number
                        newitem.SubBrandId = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                        newitem.TotalVolume = 0;
                        newitem.TotalEstVolume = 0;
                        current_sbDataROI_map.put(strkey_p, newitem);
                    }
                }

                if (ConVolume_map.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    Decimal convol = ConVolume_map.get(ContractLine.ASI_CRM_CN_Sub_Brand__c) + ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c;
                    ConVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, convol);
                }else{
                    ConVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c);
                }

                if (EstVolume_map.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    Decimal estvol = EstVolume_map.get(ContractLine.ASI_CRM_CN_Sub_Brand__c)+ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c;
                    EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, estvol );
                }else{
                    EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c);
                }

            }else{ // not by sub-Brand
                //NewContractV0Esitimate.TradeExpenses +=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                //NewContactV0Contract.TradeExpenses+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
            }

            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Module__c!=null){
                if(!PSFMethodologySet.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                    PSFMethodologySet.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                    NewContactV0Contract.PSFMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                    NewContractV0Esitimate.PSFMethodologyName+=ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                }
                if(!PSFVolumeBaseSet.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                    PSFVolumeBaseSet.add(ContractLine.ASI_CRM_Volume_Base__c);
                    NewContactV0Contract.PSFVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                    NewContractV0Esitimate.PSFVolumeBase+=VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                }
            }


            NewContractV0Esitimate.TradeExpenses+= ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

            NewContactV0Contract.TradeExpenses+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;

            if (ContractLine.ASI_CRM_Type__c=='Fixed')
            {
                NewContractV0Esitimate.FixedExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                NewContactV0Contract.FixedExpense += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            }
            else
            {
                NewContractV0Esitimate.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                NewContactV0Contract.VariableExpense+=ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            }
        }// end of Looping BRSF Line


        //CR12Factor
        Map<String,Decimal> CR12FactorMap = GenerateCR12FactorMap(V00SubBrandIdSet, CommercialTeam, strRegion);

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine :thisCC_BRSFList){
            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||  (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){

                Decimal CR12Factor=1;
                if(CR12FactorMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    CR12Factor=CR12FactorMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                }
                if (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                    NewContractV0Esitimate.IntakeCR12 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                }
                if(ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!= null){
                    NewContactV0Contract.IntakeCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                }

            }
        }


        //Calculate RegionSubBrandCM_Map
        String currentFY = String.valueOf(FYConversion(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';
        //Map<String,ASI_CRM_CM_GS__c> SubBrandCM_Map = new Map<String,ASI_CRM_CM_GS__c> ();

        for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_YEAR__c,ASI_CRM_CN_Month__c, ASI_CRM_Region__c,ASI_CRM_TYPE__c FROM ASI_CRM_CM_GS__c
        WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3) AND
        ASI_CRM_Region__c = :strRegion  AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS' OR ASI_CRM_TYPE__c = 'Budget A&D')
        AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0   AND ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS')
        ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        {// and ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
            String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            Decimal cm=0.0;
            if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
            }
            if (!RegionSubBrandCM_Map.containsKey(ProductCode + lbcm.ASI_CRM_TYPE__c)){
                RegionSubBrandCM_Map.put(ProductCode + lbcm.ASI_CRM_TYPE__c ,cm) ;
                //SubBrandCM_Map.put(ProductCode,lbcm);
            }
        }




        //for querying Budget CM
        Date strStartBGDate;
        Date strEndBGDate;
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_Start_Date__c != null)
            strStartBGDate = getEndDate(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null)
            strEndBGDate = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1));

        Date strStartBGDate2 = Date.newInstance(strStartBGDate.addYears(-1).year(), 6, 30);
        Date strEndBGDate2 = Date.newInstance(strEndBGDate.year(), 6, 30);

        Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();


        for (ASI_CRM_CM_GS__c thisbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,
            ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c , ASI_CRM_CN_Month__c
        FROM ASI_CRM_CM_GS__c  WHERE ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
        AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
        AND ((ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate ) OR
        (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2 AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2 AND ASI_CRM_CN_Month__c = 6 ))
        AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS' OR ASI_CRM_TYPE__c = 'Budget A&D')
        AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != NULL
        AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS')
        ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            Date strCMdate = thisbcm.ASI_CRM_CN_Month_End_Date__c;
            String strkey = String.valueOf(strCMdate) + thisbcm.ASI_CRM_PRODUCTCODE__c;

            if(thisbcm.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + thisbcm.ASI_CRM_TYPE__c) && thisbcm.ASI_CRM_CM_GS_per_9L__c != null && thisbcm.ASI_CRM_CM_GS_per_9L__c != 0){
                cmgsMap.put(thisbcm.ASI_CRM_PRODUCTCODE__c + thisbcm.ASI_CRM_TYPE__c, thisbcm);
            }

            if (current_sbDataROI_map.containsKey(strkey)){
                if (thisbcm.ASI_CRM_TYPE__c == 'Budget CM'){
                    if (current_sbDataROI_map.get(strkey).CM == null || current_sbDataROI_map.get(strkey).CM == 0){
                        current_sbDataROI_map.get(strkey).CM = thisbcm.ASI_CRM_CM_GS_per_9L__c;
                        //NewContactV0Contract.CMId+=thisbcm.Id+';';
                    }
                    /*if (current_sbDataROI_map.get(strkey).latestBudgetCM == null){ current_sbDataROI_map.get(strkey).latestBudgetCM =thisbcm.ASI_CRM_CM_GS_per_9L__c;}*/
                }

                else if (thisbcm.ASI_CRM_TYPE__c == 'Budget GS'){
                    if (current_sbDataROI_map.get(strkey).GS == null || current_sbDataROI_map.get(strkey).GS == 0){
                        current_sbDataROI_map.get(strkey).GS= thisbcm.ASI_CRM_CM_GS_per_9L__c;
                        //NewContactV0Contract.GSId+=thisbcm.Id+';';
                    }
                }

                else if (thisbcm.ASI_CRM_TYPE__c == 'Budget A&D'){
                    if (current_sbDataROI_map.get(strkey).AD == null || current_sbDataROI_map.get(strkey).AD == 0){
                        current_sbDataROI_map.get(strkey).AD= thisbcm.ASI_CRM_CM_GS_per_9L__c;
                        //NewContactV0Contract.GSId+=thisbcm.Id+';';
                    }
                }

                if (current_sbDataROI_map.containsKey(strkey)){
                    if (current_sbDataROI_map.get(strkey).latestBudgetCM == null){
                        if ( RegionSubBrandCM_Map.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget CM')){
                            current_sbDataROI_map.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget CM');
                        }
                    }
                    if (current_sbDataROI_map.get(strkey).latestBudgetGS == null){
                        if ( RegionSubBrandCM_Map.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget GS')){
                            current_sbDataROI_map.get(strkey).latestBudgetGS = RegionSubBrandCM_Map.get(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget GS');
                        }
                    }
                    if (current_sbDataROI_map.get(strkey).latestBudgetAD == null){
                        if ( RegionSubBrandCM_Map.containsKey(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget A&D')){
                            current_sbDataROI_map.get(strkey).latestBudgetAD = RegionSubBrandCM_Map.get(thisbcm.ASI_CRM_PRODUCTCODE__c + 'Budget A&D');
                        }
                    }
                }

            }
        }// End of looping Budget CM/GS


        //Replace null/0 value with latest CMGS data

        for(String key : current_sbDataROI_map.keySet()){
            if(current_sbDataROI_map.get(key).CM == null || current_sbDataROI_map.get(key).CM == 0 || current_sbDataROI_map.get(key).GS == null ||
                current_sbDataROI_map.get(key).GS == 0 || current_sbDataROI_map.get(key).AD == null || current_sbDataROI_map.get(key).AD == 0 || 
                current_sbDataROI_map.get(key).latestBudgetCM == null || current_sbDataROI_map.get(key).latestBudgetCM == 0 || 
                current_sbDataROI_map.get(key).latestBudgetGS == null || current_sbDataROI_map.get(key).latestBudgetGS == 0 || 
                current_sbDataROI_map.get(key).latestBudgetAD == null || current_sbDataROI_map.get(key).latestBudgetAD == 0 ){
                if((current_sbDataROI_map.get(key).CM == null || current_sbDataROI_map.get(key).CM == 0) && cmgsMap.containsKey(current_sbDataROI_map.get(key).SubBrandId + 'Budget CM')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(current_sbDataROI_map.get(key).SubBrandId + 'Budget CM');

                    current_sbDataROI_map.get(key).CM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }

                if((current_sbDataROI_map.get(key).GS == null || current_sbDataROI_map.get(key).GS == 0) && cmgsMap.containsKey(current_sbDataROI_map.get(key).SubBrandId + 'Budget GS')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(current_sbDataROI_map.get(key).SubBrandId + 'Budget GS');
                    current_sbDataROI_map.get(key).GS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }

                if((current_sbDataROI_map.get(key).AD == null || current_sbDataROI_map.get(key).AD == 0) && cmgsMap.containsKey(current_sbDataROI_map.get(key).SubBrandId + 'Budget A&D')){
                    ASI_CRM_CM_GS__c cmgs = cmgsMap.get(current_sbDataROI_map.get(key).SubBrandId + 'Budget A&D');
                    current_sbDataROI_map.get(key).AD = cmgs.ASI_CRM_CM_GS_per_9L__c;
                }

                if(current_sbDataROI_map.get(key).latestBudgetCM == null || current_sbDataROI_map.get(key).latestBudgetCM == 0){
                    if(RegionSubBrandCM_Map.containsKey(current_sbDataROI_map.get(key).SubBrandId+ 'Budget CM'))
                        current_sbDataROI_map.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(current_sbDataROI_map.get(key).SubBrandId+ 'Budget CM');
                }

                if(current_sbDataROI_map.get(key).latestBudgetGS == null || current_sbDataROI_map.get(key).latestBudgetGS == 0){
                    if(RegionSubBrandCM_Map.containsKey(current_sbDataROI_map.get(key).SubBrandId+ 'Budget GS'))
                        current_sbDataROI_map.get(key).latestBudgetGS = RegionSubBrandCM_Map.get(current_sbDataROI_map.get(key).SubBrandId+ 'Budget GS');
                }

                if(current_sbDataROI_map.get(key).latestBudgetAD == null || current_sbDataROI_map.get(key).latestBudgetAD == 0){
                    if(RegionSubBrandCM_Map.containsKey(current_sbDataROI_map.get(key).SubBrandId+ 'Budget A&D'))
                        current_sbDataROI_map.get(key).latestBudgetAD = RegionSubBrandCM_Map.get(current_sbDataROI_map.get(key).SubBrandId+ 'Budget A&D');
                }
            }
        }


        Decimal CMTotalV0Estimate=0;
        Decimal CMTotalV0Contract=0;
        Decimal LatestBudgetCMTotalV0Estimate = 0;
        Decimal LatestBudgetCMTotalV0Contract = 0;

        if (current_sbDataROI_map != null && current_sbDataROI_map.size() > 0){
            Decimal ActualCM;
            Decimal LatestBudgetCM; // lbcm--> LatestBudgetCM
            Decimal ActualGS;
            Decimal LatestBudgetGs;
            Decimal ActualAD;
            Decimal LatestBudgetAD;
            Decimal TotalActualVol;// totalactualvol--->TotalActualVol
            Decimal TotalEstimateVol; // totalestimatevol--> TotalEstimateVol
            Decimal PeriodStr; //change from strperiod to PeriodStr
            for (String key : current_sbDataROI_map.keySet()){
                PeriodStr= null;
                if (current_sbDataROI_map.get(key).period != null){
                    PeriodStr = current_sbDataROI_map.get(key).period;
                }

                //Budget CM
                ActualCM = null;
                if (current_sbDataROI_map.get(key).CM != null){
                    ActualCM = current_sbDataROI_map.get(key).CM;
                }

                //Latest Budget CM
                LatestBudgetCM = null;
                if (current_sbDataROI_map.get(key).latestBudgetCM != null){
                    LatestBudgetCM = current_sbDataROI_map.get(key).latestBudgetCM;
                }
                //Budget GS
                ActualGS = null;
                if (current_sbDataROI_map.get(key).GS != null){
                    ActualGS = current_sbDataROI_map.get(key).GS;
                }

                //Latest Budget GS
                LatestBudgetGS = null;
                if (current_sbDataROI_map.get(key).latestBudgetGS != null){
                    LatestBudgetGS = current_sbDataROI_map.get(key).latestBudgetGS;
                }

                //Budget AD
                ActualAD = null;
                if (current_sbDataROI_map.get(key).AD != null){
                    ActualAD = current_sbDataROI_map.get(key).AD;
                }

                LatestBudgetAD = null;
                if (current_sbDataROI_map.get(key).latestBudgetAD != null){
                    LatestBudgetAD = current_sbDataROI_map.get(key).latestBudgetAD;
                }
                
                System.debug(LoggingLevel.INFO, '*** key: ' + key);
                System.debug(LoggingLevel.INFO, '*** PeriodStr: ' + PeriodStr);
                System.debug(LoggingLevel.INFO, '*** ActualCM: ' + ActualCM);
                System.debug(LoggingLevel.INFO, '*** latestBudgetCM: ' + latestBudgetCM);
                System.debug(LoggingLevel.INFO, '*** ActualGS: ' + ActualGS);
                System.debug(LoggingLevel.INFO, '*** LatestBudgetGS: ' + LatestBudgetGS);
                System.debug(LoggingLevel.INFO, '*** ActualAD: ' + ActualAD);
                System.debug(LoggingLevel.INFO, '*** LatestBudgetAD: ' + LatestBudgetAD);





                //Total Volume
                TotalActualVol = null;
                if (ConVolume_map != null && current_sbDataROI_map.get(key) != null && current_sbDataROI_map.get(key).SubBrandId != null && ConVolume_map.containsKey(current_sbDataROI_map.get(key).SubBrandId)){
                    TotalActualVol = ConVolume_map.get(current_sbDataROI_map.get(key).SubBrandId);
                }
                TotalEstimateVol = null;
                if (EstVolume_map != null && current_sbDataROI_map.get(key) != null && current_sbDataROI_map.get(key).SubBrandId != null && EstVolume_map.containsKey(current_sbDataROI_map.get(key).SubBrandId)){
                    TotalEstimateVol = EstVolume_map.get(current_sbDataROI_map.get(key).SubBrandId);
                }

                if (TotalEstimateVol != null && ActualCM != null && PeriodStr != null){
                    CMTotalV0Estimate += ActualCM * TotalEstimateVol * PeriodStr;
                }

                if (TotalEstimateVol != null && LatestBudgetCM != null && PeriodStr != null){
                    LatestBudgetCMTotalV0Estimate += LatestBudgetCM * TotalEstimateVol * PeriodStr;
                }

                //Esitimate GrossSalesTotal & GrossSalesTotalProForma
                if (TotalEstimateVol != null && ActualGS != null && PeriodStr != null){
                    NewContractV0Esitimate.GrossSalesTotal += ActualGS * TotalEstimateVol * PeriodStr;
                }

                if (TotalEstimateVol != null && LatestBudgetGs != null && PeriodStr != null){
                    NewContractV0Esitimate.GrossSalesTotalProForma += LatestBudgetGs * TotalEstimateVol * PeriodStr;
                }

                //Esitimate ADTotal & ADTotalProForma
                if (TotalEstimateVol != null && ActualAD != null && PeriodStr != null){
                    NewContractV0Esitimate.ADTotal += ActualAD * TotalEstimateVol * PeriodStr;
                }

                if (TotalEstimateVol != null && LatestBudgetAD != null && PeriodStr != null){
                    NewContractV0Esitimate.ADTotalProForma += LatestBudgetAD * TotalEstimateVol * PeriodStr;
                }

                System.debug(LoggingLevel.INFO, '*** TotalEstimateVol: ' + TotalEstimateVol);
                System.debug(LoggingLevel.INFO, '*** TotalActualVol: ' + TotalActualVol);
                System.debug(LoggingLevel.INFO, '*** CMTotalV0Estimate: ' + CMTotalV0Estimate);
                System.debug(LoggingLevel.INFO, '*** LatestBudgetCMTotalV0Estimate: ' + LatestBudgetCMTotalV0Estimate);
                System.debug(LoggingLevel.INFO, '*** NewContractV0Esitimate.GrossSalesTotal: ' + NewContractV0Esitimate.GrossSalesTotal);
                System.debug(LoggingLevel.INFO, '*** NewContractV0Esitimate.GrossSalesTotalProForma: ' + NewContractV0Esitimate.GrossSalesTotalProForma);
                System.debug(LoggingLevel.INFO, '*** NewContractV0Esitimate.ADTotal: ' + NewContractV0Esitimate.ADTotal);
                System.debug(LoggingLevel.INFO, '*** NewContractV0Esitimate.ADTotalProForma: ' + NewContractV0Esitimate.ADTotalProForma);


                if (TotalActualVol != null && ActualCM != null && PeriodStr != null){
                    CMTotalV0Contract += ActualCM * TotalActualVol * PeriodStr;
                }

                if (TotalActualVol != null && LatestBudgetCM != null && PeriodStr != null){
                    LatestBudgetCMTotalV0Contract += LatestBudgetCM * TotalActualVol * PeriodStr;
                }

                //Contact GrossSalesTotal & GrossSalesTotalProForma
                if (TotalActualVol != null && ActualGS != null && PeriodStr != null){
                    NewContactV0Contract.GrossSalesTotal += ActualGS * TotalActualVol * PeriodStr;
                }

                if (TotalActualVol != null && LatestBudgetGS != null && PeriodStr != null){
                    NewContactV0Contract.GrossSalesTotalProForma += LatestBudgetGS * TotalActualVol * PeriodStr;
                }

                //Contact ADTotal & ADTotalProForma
                if (TotalActualVol != null && ActualAD != null && PeriodStr != null){
                    NewContactV0Contract.ADTotal += ActualAD * TotalActualVol * PeriodStr;
                }

                if (TotalActualVol != null && LatestBudgetAD != null && PeriodStr != null){
                    NewContactV0Contract.ADTotalProForma += LatestBudgetAD * TotalActualVol * PeriodStr;
                }

                
                System.debug(LoggingLevel.INFO, '*** CMTotalV0Contract: ' + CMTotalV0Contract);
                System.debug(LoggingLevel.INFO, '*** LatestBudgetCMTotalV0Contract: ' + LatestBudgetCMTotalV0Contract);
                System.debug(LoggingLevel.INFO, '*** NewContactV0Contract.GrossSalesTotal: ' + NewContactV0Contract.GrossSalesTotal);
                System.debug(LoggingLevel.INFO, '*** NewContactV0Contract.GrossSalesTotalProForma: ' + NewContactV0Contract.GrossSalesTotalProForma);
                System.debug(LoggingLevel.INFO, '*** NewContactV0Contract.ADTotal: ' + NewContactV0Contract.ADTotal);
                System.debug(LoggingLevel.INFO, '*** NewContactV0Contract.ADTotalProForma: ' + NewContactV0Contract.ADTotalProForma);


            }
        } // end of looping current_sbDataROI_map

        //**************************Calculation**************************
        NewContractV0Esitimate.CMTotal = CMTotalV0Estimate;
        NewContractV0Esitimate.LatestBudgetCMTotal = LatestBudgetCMTotalV0Estimate;

        NewContactV0Contract.CMTotal = CMTotalV0Contract;
        NewContactV0Contract.LatestBudgetCMTotal = LatestBudgetCMTotalV0Contract;

        if(NewContractV0Esitimate.TradeExpenses !=0 && NewContractV0Esitimate.TradeExpenses !=null ){
            NewContractV0Esitimate.FixedExpenseRate = (NewContractV0Esitimate.FixedExpense / NewContractV0Esitimate.TradeExpenses *100).setScale(4);

        }
        if(NewContactV0Contract.TradeExpenses !=0 && NewContactV0Contract.TradeExpenses !=null ){
            NewContactV0Contract.FixedExpenseRate = (NewContactV0Contract.FixedExpense / NewContactV0Contract.TradeExpenses *100).setScale(4);
        }

        //Calculate 'Investment per CR12 eq btl ' = Trade expenses / (CR12 Conversion Factor in Sub-brand * estimate Monthly vol. * PO Period in Sub-Brand )
        if (NewContractV0Esitimate.IntakeCR12 != 0 && NewContractV0Esitimate.IntakeCR12!= null &&  NewContractV0Esitimate.TradeExpenses != 0 &&  NewContractV0Esitimate.TradeExpenses != null){
            //NewContractV0Esitimate.IntakeCR12=NewContractV0Esitimate.InvestmentCR12;
            NewContractV0Esitimate.InvestmentCR12 =  (NewContractV0Esitimate.TradeExpenses / NewContractV0Esitimate.IntakeCR12).setScale(2);
        }
        if (NewContactV0Contract.IntakeCR12 != 0 && NewContactV0Contract.IntakeCR12!= null &&  NewContactV0Contract.TradeExpenses != 0 &&  NewContactV0Contract.TradeExpenses != null){
            //NewContactV0Contract.IntakeCR12=NewContactV0Contract.InvestmentCR12;
            NewContactV0Contract.InvestmentCR12 =  (NewContactV0Contract.TradeExpenses / NewContactV0Contract.IntakeCR12).setScale(2);
        }

        //Calculate  Margin after A&P = SUM( Budget CMs * estimate Monthly vol. in 9L  of PO period) - Trade expenses
        if (CMTotalV0Estimate != null && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.MarginAfterAnP = CMTotalV0Estimate - NewContractV0Esitimate.TradeExpenses;
        }
        if (CMTotalV0Estimate != null && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.MarginAfterAnP = CMTotalV0Contract - NewContactV0Contract.TradeExpenses;
        }

        //Calculate  Margin after A&P proforma = SUM( Latest Budget CMs * estimate Monthly vol. in 9L  of PO period) - Trade expenses
        if (LatestBudgetCMTotalV0Estimate != null && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.MarginAfterAnPProForma = LatestBudgetCMTotalV0Estimate - NewContractV0Esitimate.TradeExpenses;
        }
        if (LatestBudgetCMTotalV0Contract != null && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.MarginAfterAnPProForma = LatestBudgetCMTotalV0Contract - NewContactV0Contract.TradeExpenses;
        }

        if (BRSFEstimateVolumesTotal != null && NewContractV0Esitimate.NoOfMonths != null){
            NewContractV0Esitimate.IntakeSTD=BRSFEstimateVolumesTotal * NewContractV0Esitimate.NoOfMonths;
        }
        if (BRSFContractVolumesTotal != null && NewContactV0Contract.NoOfMonths != null){
            NewContactV0Contract.IntakeSTD = BRSFContractVolumesTotal* NewContactV0Contract.NoOfMonths;
        }


        //Margin Per Bottle
        if (NewContractV0Esitimate.IntakeSTD!= 0 && NewContractV0Esitimate.IntakeSTD != null && NewContractV0Esitimate.MarginAfterAnP != 0 && NewContractV0Esitimate.MarginAfterAnP != null){
            NewContractV0Esitimate.MarginPerBottle = (NewContractV0Esitimate.MarginAfterAnP /NewContractV0Esitimate.IntakeSTD).setScale(4);
        }
        if (NewContactV0Contract.IntakeSTD!= 0 && NewContactV0Contract.IntakeSTD != null && NewContactV0Contract.MarginAfterAnP != 0 && NewContactV0Contract.MarginAfterAnP != null){
            NewContactV0Contract.MarginPerBottle = (NewContactV0Contract.MarginAfterAnP / NewContactV0Contract.IntakeSTD).setScale(4);
        }

        //Gross Sales Rate Historical V0
        if (NewContractV0Esitimate.GrossSalesTotal  != null && NewContractV0Esitimate.GrossSalesTotal  != 0 && NewContractV0Esitimate.TradeExpenses!= 0 && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.GrossSalesRate = (NewContractV0Esitimate.TradeExpenses / NewContractV0Esitimate.GrossSalesTotal  *100).setScale(4);
        }
        if (NewContactV0Contract.GrossSalesTotal  != null && NewContactV0Contract.GrossSalesTotal  != 0 && NewContactV0Contract.TradeExpenses!= 0 && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.GrossSalesRate = (NewContactV0Contract.TradeExpenses / NewContactV0Contract.GrossSalesTotal  *100).setScale(4);
        }

        //Gross Sales Rate ProForma
        if (NewContractV0Esitimate.GrossSalesTotalProForma  != null && NewContractV0Esitimate.GrossSalesTotalProForma  != 0 && NewContractV0Esitimate.TradeExpenses!= 0 && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.GrossSalesRateProForma = (NewContractV0Esitimate.TradeExpenses / NewContractV0Esitimate.GrossSalesTotalProForma  *100).setScale(4);
        }
        if (NewContactV0Contract.GrossSalesTotalProForma  != null && NewContactV0Contract.GrossSalesTotalProForma  != 0 && NewContactV0Contract.TradeExpenses!= 0 && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.GrossSalesRateProForma = (NewContactV0Contract.TradeExpenses / NewContactV0Contract.GrossSalesTotalProForma  *100).setScale(4);
        }
        


        // ROI Intake Historical V0 = Cont. Margin before A&P / Trade expenses
        if (CMTotalV0Estimate != null && CMTotalV0Estimate != 0 && NewContractV0Esitimate.TradeExpenses != 0 && NewContractV0Esitimate.TradeExpenses != null){
            NewContractV0Esitimate.ROIIntake = (CMTotalV0Estimate / NewContractV0Esitimate.TradeExpenses).setScale(2);
            NewContractV0Esitimate.ROIActual=NewContractV0Esitimate.ROIIntake;
        }

        if (CMTotalV0Contract != null && CMTotalV0Contract != 0 && NewContactV0Contract.TradeExpenses != 0 && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.ROIIntake = CMTotalV0Contract / NewContactV0Contract.TradeExpenses;
            NewContactV0Contract.ROIActual=NewContactV0Contract.ROIIntake;
        }

        //Calculate ROIProForma = Cont. Margin before A&P from latest CM regardless FY / Trade expenses
        if (LatestBudgetCMTotalV0Estimate != null && LatestBudgetCMTotalV0Estimate != 0 && NewContractV0Esitimate.TradeExpenses != 0 && NewContractV0Esitimate.TradeExpenses!= null){
            NewContractV0Esitimate.ROIProForma = LatestBudgetCMTotalV0Estimate/ NewContractV0Esitimate.TradeExpenses;
        }

        if (LatestBudgetCMTotalV0Contract != null && LatestBudgetCMTotalV0Contract != 0 && NewContactV0Contract.TradeExpenses != 0 && NewContactV0Contract.TradeExpenses!= null){
            NewContactV0Contract.ROIProForma = LatestBudgetCMTotalV0Contract/ NewContactV0Contract.TradeExpenses;
        }

        NewContactV0Contract.TradeExpenseBySubBrand = constructTradeExpenseBySubBrand2nd(thisCC, 'contract', 'PO Open');
        NewContractV0Esitimate.TradeExpenseBySubBrand = constructTradeExpenseBySubBrand2nd(thisCC, 'estimate', 'PO Open');

        NewContactV0Contract.TradeExpenseBySubBrand = updateCMGSInTradeExpenseBySubBrand2nd(NewContactV0Contract, NewContactV0Contract.TradeExpenseBySubBrand, current_sbDataROI_map);
        NewContractV0Esitimate.TradeExpenseBySubBrand = updateCMGSInTradeExpenseBySubBrand2nd(NewContractV0Esitimate, NewContractV0Esitimate.TradeExpenseBySubBrand, current_sbDataROI_map);

        NewContactV0Contract = calculateFIExcludeSelectedSubBrands2nd(NewContactV0Contract);
        NewContractV0Esitimate = calculateFIExcludeSelectedSubBrands2nd(NewContractV0Esitimate);

        //**************************Calculation 2nd KPI Sub-brand Trade Expense**************************
        Date setDate = FYConversion(Date.today());

        //Domestic Target
        Map<String, ASI_CRM_CM_GS__c>  DomesticTargetMap = GeneratingDomesticTarget(setDate,V00SubBrandIdSet);
        //Regional Target
        Map<String, ASI_CRM_CM_GS__c> RegionalAverageMap = GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,V00SubBrandIdSet);

        NewContactV0Contract = calculatedTradeExpense(NewContactV0Contract,DomesticTargetMap,RegionalAverageMap,RegionSubBrandCM_Map);
        NewContractV0Esitimate = calculatedTradeExpense(NewContractV0Esitimate,DomesticTargetMap,RegionalAverageMap,RegionSubBrandCM_Map);
        //**************************Calculation 2nd KPI Sub-brand Trade Expense end**************************
        List<FinancialIndicator2nd> ReturnList = new List<FinancialIndicator2nd>();

        ReturnList.add(NewContractV0Esitimate);
        ReturnList.add(NewContactV0Contract);

        return ReturnList;
    }


    //@description: calculated subbrand TradeExpense include PSF,VEC,Fixed
    //@param: ContractLine2nd & List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> 
    //@return
    public static FinancialIndicator2nd calculatedTradeExpense(FinancialIndicator2nd financialIndicator, Map<String, ASI_CRM_CM_GS__c>  DomesticTargetMap, Map<String, ASI_CRM_CM_GS__c> RegionalAverageMap, Map<String,Decimal> RegionSubBrandCM_Map){
        Decimal ContractTotalDomesticAfterSpendingTarget = 0;
        Decimal ContractTotalRegionalAverageAfterSpendingTarget = 0;
        for (TradeExpenseBreakdown2nd tradeExpenseBreakdown : financialIndicator.TradeExpenseBySubBrand) {
            if (tradeExpenseBreakdown.subBrandCode == '999') {
                continue;
            }
            String subBrandId = tradeExpenseBreakdown.subBrandId;

            if (RegionSubBrandCM_Map.containsKey(subBrandId + 'Budget CM')) {
                tradeExpenseBreakdown.CMBeforeSpending = RegionSubBrandCM_Map.get(subBrandId + 'Budget CM');
            }            


            //Domestic Target Info
            if (DomesticTargetMap.containsKey(subBrandId)) {
                tradeExpenseBreakdown.DomesticIndexTarget = DomesticTargetMap.containsKey(subBrandId) && DomesticTargetMap.get(subBrandId).ASI_CRM_CN_Domestic_Index_Target__c != null ?DomesticTargetMap.get(subBrandId).ASI_CRM_CN_Domestic_Index_Target__c:0;
                tradeExpenseBreakdown.DomesticInvestment = DomesticTargetMap.containsKey(subBrandId) && DomesticTargetMap.get(subBrandId).ASI_CRM_CN_Domestic_Spending__c != null?DomesticTargetMap.get(subBrandId).ASI_CRM_CN_Domestic_Spending__c:0;
                tradeExpenseBreakdown.DomesticCMAfterSpending = DomesticTargetMap.containsKey(subBrandId) && DomesticTargetMap.get(subBrandId).ASI_CRM_CN_Domestic_CM_After_Spending__c!= null?DomesticTargetMap.get(subBrandId).ASI_CRM_CN_Domestic_CM_After_Spending__c:0;
            }

            //Regional Target Info
            if (RegionalAverageMap.containsKey(subBrandId)) {
                tradeExpenseBreakdown.RegionalAverageIndex = RegionalAverageMap.containsKey(subBrandId) && RegionalAverageMap.get(subBrandId).ASI_CRM_CN_Regional_Average_Index__c!=null?RegionalAverageMap.get(subBrandId).ASI_CRM_CN_Regional_Average_Index__c:0;
                tradeExpenseBreakdown.RegionalAverageInvestment = RegionalAverageMap.containsKey(subBrandId) && RegionalAverageMap.get(subBrandId).ASI_CRM_CN_Regional_Average_Investment__c!= null?RegionalAverageMap.get(subBrandId).ASI_CRM_CN_Regional_Average_Investment__c:0;
                tradeExpenseBreakdown.RegionalAverageAfterSpending = RegionalAverageMap.containsKey(subBrandId) && RegionalAverageMap.get(subBrandId).ASI_CRM_CN_Regional_Average_After_Spend__c!= null?RegionalAverageMap.get(subBrandId).ASI_CRM_CN_Regional_Average_After_Spend__c:0;
            }

            tradeExpenseBreakdown.MarginPerBottle = (tradeExpenseBreakdown.CMBeforeSpending * tradeExpenseBreakdown.factor9L/9- tradeExpenseBreakdown.tradeExpensePerBottle2nd).setScale(4) ;
            if (tradeExpenseBreakdown.DomesticCMAfterSpending != null && tradeExpenseBreakdown.DomesticCMAfterSpending != 0) {
               tradeExpenseBreakdown.DomesticContractIndex = (tradeExpenseBreakdown.MarginPerBottle / (tradeExpenseBreakdown.DomesticCMAfterSpending * tradeExpenseBreakdown.factor9L/9) * 100).setScale(4); 
            }
            if (tradeExpenseBreakdown.RegionalAverageAfterSpending != null && tradeExpenseBreakdown.RegionalAverageAfterSpending != 0) {
                tradeExpenseBreakdown.RegionalTargetIndex = (tradeExpenseBreakdown.MarginPerBottle / (tradeExpenseBreakdown.RegionalAverageAfterSpending * tradeExpenseBreakdown.factor9L/9) * 100).setScale(4);
            }

            // if (tradeExpenseBreakdown.volumeSTD > 0)
            // {
                tradeExpenseBreakdown.GapWithDomesticIndexTarget = tradeExpenseBreakdown.DomesticContractIndex - tradeExpenseBreakdown.DomesticIndexTarget;
                tradeExpenseBreakdown.GapWithRegionalAverageIndex = tradeExpenseBreakdown.RegionalTargetIndex - tradeExpenseBreakdown.RegionalAverageIndex;
            // }
            
            // if (tradeExpenseBreakdown.tradeExpensePerBottle2nd > 0)
            // {
                tradeExpenseBreakdown.GapWithDomesticInvestment = tradeExpenseBreakdown.tradeExpensePerBottle2nd - (tradeExpenseBreakdown.DomesticInvestment * tradeExpenseBreakdown.factor9L/9).setScale(4);
                tradeExpenseBreakdown.GapWithRegionalAverageInvestment = tradeExpenseBreakdown.tradeExpensePerBottle2nd - (tradeExpenseBreakdown.RegionalAverageInvestment * tradeExpenseBreakdown.factor9L/9).setScale(4);
            // } 

            ContractTotalDomesticAfterSpendingTarget += tradeExpenseBreakdown.volumeSTD * tradeExpenseBreakdown.DomesticCMAfterSpending * tradeExpenseBreakdown.factor9L/9 ;
            ContractTotalRegionalAverageAfterSpendingTarget += tradeExpenseBreakdown.volumeSTD * tradeExpenseBreakdown.RegionalAverageAfterSpending * tradeExpenseBreakdown.factor9L/9 ;
        } // end of looping TradeExpenseBySubBrand

        //Margin Per Bottle proforma
        if (financialIndicator.IntakeSTD!= 0 && financialIndicator.IntakeSTD != null && financialIndicator.MarginAfterAnPProForma != 0 && financialIndicator.MarginAfterAnPProForma != null){
            financialIndicator.MarginPerBottleProForma = (financialIndicator.MarginAfterAnPProForma / financialIndicator.IntakeSTD).setScale(4);
        }

        
        //Margin Per Case (9L)
        if (financialIndicator.volumes!= 0 && financialIndicator.volumes != null && financialIndicator.MarginAfterAnP != 0 && financialIndicator.MarginAfterAnP != null){
            financialIndicator.MarginPerCase = (financialIndicator.MarginAfterAnP /financialIndicator.volumes).setScale(4);
        }


        //CM/NS% & CM/NS% proforma
        if (financialIndicator.GrossSalesTotal-financialIndicator.TradeExpenses-financialIndicator.ADTotal != 0)
        {
            financialIndicator.CMNSRate = (financialIndicator.MarginAfterAnP / (financialIndicator.GrossSalesTotal-financialIndicator.TradeExpenses-financialIndicator.ADTotal) * 100).setScale(4);
        }
        if (financialIndicator.GrossSalesTotalProForma-financialIndicator.TradeExpenses-financialIndicator.ADTotalProForma != 0)
        {
            financialIndicator.CMNSRateProForma = (financialIndicator.MarginAfterAnPProForma / (financialIndicator.GrossSalesTotalProForma-financialIndicator.TradeExpenses-financialIndicator.ADTotalProForma) * 100).setScale(4);
        }

        //DomesticTarget & RegionalAverageTarget
        if (financialIndicator.IntakeSTD != null && financialIndicator.IntakeSTD != 0) {
            financialIndicator.DomesticTarget = ContractTotalDomesticAfterSpendingTarget/financialIndicator.IntakeSTD;
            financialIndicator.RegionalAverageTarget = ContractTotalRegionalAverageAfterSpendingTarget/financialIndicator.IntakeSTD;
        }
        
        //DomesticContractIndex & DomesticContractIndexProForma
        if (financialIndicator.DomesticTarget != null && financialIndicator.DomesticTarget != 0) {
            financialIndicator.DomesticContractIndex = (financialIndicator.MarginPerBottle/financialIndicator.DomesticTarget * 100).setScale(4);
            financialIndicator.DomesticContractIndexProForma = (financialIndicator.MarginPerBottleProForma/financialIndicator.DomesticTarget * 100).setScale(4);
        }

        //RegionalAverageIndex & RegionalAverageIndexProForma
        if (financialIndicator.DomesticTarget != null && financialIndicator.DomesticTarget != 0) {
            financialIndicator.RegionalAverageIndex = (financialIndicator.RegionalAverageTarget/financialIndicator.DomesticTarget * 100).setScale(4);
            financialIndicator.RegionalAverageIndexProForma = financialIndicator.RegionalAverageIndex;
        }

        //VsRegionalAverageIndex & VsRegionalAverageIndexProForma
        financialIndicator.VsRegionalAverageIndex = financialIndicator.DomesticContractIndex - financialIndicator.RegionalAverageIndex;
        financialIndicator.VsRegionalAverageIndexProForma = financialIndicator.DomesticContractIndexProForma - financialIndicator.RegionalAverageIndexProForma;

        if (financialIndicator.RegionalAverageTarget != null && financialIndicator.RegionalAverageTarget != 0) {
            financialIndicator.RegionalTargetIndex = (financialIndicator.MarginPerBottle/financialIndicator.RegionalAverageTarget * 100).setScale(4);
            financialIndicator.RegionalTargetIndexProForma = (financialIndicator.MarginPerBottleProForma/financialIndicator.RegionalAverageTarget * 100).setScale(4);
        }

        return financialIndicator;
    }

    //@description: Save V0.0 & VFinalETL KPI Data
    //@param: input current Contract, V0.0 FinancialIndicator, VFinal FinancialIndicator
    //@return 
    public static void UpsertKPIData(ASI_TH_CRM_Contract__c contract, FinancialIndicator2nd V0financialData, FinancialIndicator2nd VfinalfinancialData) {
        Map<String, ASI_CRM_CN_Subbrand_Financial__c> subFinancialMap = new Map<String, ASI_CRM_CN_Subbrand_Financial__c>();
        Map<String, ASI_CRM_CN_Subbrand_Financial__c> existSubFinancialMap = new Map<String, ASI_CRM_CN_Subbrand_Financial__c>();
        String recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Subbrand_Financial__cASI_CRM_CN_Heavy_Contract_ON');
        System.debug(LoggingLevel.INFO, '*** contract: ' + contract);
        for (ASI_CRM_CN_Subbrand_Financial__c sf : [select id, ASI_CRM_Subbrand__c from ASI_CRM_CN_Subbrand_Financial__c where ASI_TH_CRM_Contract__c =: contract.id and RecordType.DeveloperName = 'ASI_CRM_CN_Heavy_Contract_ON']) {
            existSubFinancialMap.put(sf.ASI_CRM_Subbrand__c,sf);
        }
        if (V0financialData != null) {
            contract.ASI_CRM_CN_V0_Trade_Expenses__c = V0financialData.TradeExpenses;
            contract.ASI_CRM_CN_V0_Variable_Expenses__c = V0financialData.VariableExpense;
            contract.ASI_CRM_CN_V0_Fixed_Expenses__c = V0financialData.FixedExpense;
            contract.ASI_CRM_CN_V0_Total_Std_Volums__c = V0financialData.IntakeSTD;
            contract.ASI_CRM_CN_V0_Gross_Sales__c = V0financialData.GrossSalesTotal;
            contract.ASI_CRM_CN_V0_Gross_Sales_ProForma__c = V0financialData.GrossSalesTotalProForma;
            contract.ASI_CRM_CN_V0_CM_before_spending__c = V0financialData.CMTotal;
            contract.ASI_CRM_CN_V0_CM_before_spend_ProForma__c = V0financialData.LatestBudgetCMTotal;
            contract.ASI_CRM_CN_V0_A_D__c = V0financialData.ADTotal;
            contract.ASI_CRM_CN_V0_A_D_ProForma__c = V0financialData.ADTotalProForma;
            contract.ASI_CRM_CN_V0_Margin_AP__c = V0financialData.MarginAfterAnP;
            contract.ASI_CRM_CN_V0_Margin_AP_ProForma__c = V0financialData.MarginAfterAnPProForma;
            contract.ASI_CRM_CN_V0_Margin_PerBottle__c = V0financialData.MarginPerBottle;
            contract.ASI_CRM_CN_V0_Margin_PerBottle_ProForma__c = V0financialData.MarginPerBottleProForma;
            contract.ASI_CRM_CN_V0_Domestic_Target_CM__c = V0financialData.DomesticTarget;
            contract.ASI_CRM_CN_V0_Region_Average_CM__c = V0financialData.RegionalAverageTarget;
            contract.ASI_CRM_CN_V0_Contract_Index_Domestic__c = V0financialData.DomesticContractIndex;
            contract.ASI_CRM_CN_V0_Cont_Index_Dom_ProForma__c = V0financialData.DomesticContractIndexProForma;
            contract.ASI_CRM_CN_V0_Regional_Average_Index__c = V0financialData.RegionalAverageIndex;
            contract.ASI_CRM_CN_V0_Reg_Average_Index_ProForma__c = V0financialData.RegionalAverageIndexProForma;
            contract.ASI_CRM_CN_V0_Regional_Target_Index__c = V0financialData.RegionalTargetIndex;
            contract.ASI_CRM_CN_V0_Reg_Target_Index_ProForma__c = V0financialData.RegionalTargetIndexProForma;

            V0financialData.TradeExpenseBySubBrand = V0financialData.TradeExpenseBySubBrand == null ? new List<TradeExpenseBreakdown2nd>() : V0financialData.TradeExpenseBySubBrand;
            for (TradeExpenseBreakdown2nd breakdown : V0financialData.TradeExpenseBySubBrand) {
                ASI_CRM_CN_Subbrand_Financial__c subFinancial = new ASI_CRM_CN_Subbrand_Financial__c();
                subFinancial.ASI_TH_CRM_Contract__c = contract.Id;
                subFinancial.RecordTypeId = recordTypeId;
                subFinancial.ASI_CRM_Subbrand__c = breakdown.subBrandId;
                subFinancial.ASI_CRM_CN_External_Id__c = contract.Id + '' +subFinancial.ASI_CRM_Subbrand__c;
                subFinancial.ASI_CRM_CN_COnvfactor_Ltocr12__c = breakdown.cr12Factor;
                subFinancial.ASI_CRM_CN_Factor_9L__c = breakdown.factor9L;
                subFinancial.ASI_CRM_CN_CM_Before_Spending__C = breakdown.CMBeforeSpending != null ? (breakdown.CMBeforeSpending * breakdown.factor9L/9).setScale(4):0;
                subFinancial.ASI_CRM_CN_Domestic_Index_Target__c = breakdown.DomesticIndexTarget;
                subFinancial.ASI_CRM_CN_Domestic_Investment__c = breakdown.DomesticInvestment != null ? (breakdown.DomesticInvestment * breakdown.factor9L/9).setScale(4) : 0;
                subFinancial.ASI_CRM_CN_Domestic_CM_After_Spending__c = breakdown.DomesticCMAfterSpending != null ? (breakdown.DomesticCMAfterSpending * breakdown.factor9L/9).setScale(4) : 0;
                subFinancial.ASI_CRM_CN_Regional_Average_Index__c = breakdown.RegionalAverageIndex;
                subFinancial.ASI_CRM_CN_Regional_Average_Investment__c = breakdown.RegionalAverageInvestment != null ? (breakdown.RegionalAverageInvestment * breakdown.factor9L/9).setScale(4) : 0;
                subFinancial.ASI_CRM_CN_Regional_Average_After_Spend__c = breakdown.RegionalAverageAfterSpending != null ? (breakdown.RegionalAverageAfterSpending * breakdown.factor9L/9).setScale(4) : 0;
                subFinancial.ASI_CRM_CN_V0_Trade_Expenses__c = breakdown.totalTradeExpense;
                subFinancial.ASI_CRM_CN_V0_Total_Volums__c = breakdown.volumeSTD;
                subFinancial.ASI_CRM_CN_V0_Trade_Expenses_PerBottle__c = breakdown.tradeExpensePerBottle2nd;
                subFinancial.ASI_CRM_CN_V0_Monthly_Volums__c = breakdown.monthlyVolumeSTD;
                subFinancial.ASI_CRM_CN_V0_BRSF_Trade_Expenses__c = breakdown.BRSFPerTradeExpense;
                subFinancial.ASI_CRM_CN_V0_PSF_Trade_Expenses__c = breakdown.PSFPerTradeExpense;
                subFinancial.ASI_CRM_CN_V0_VEC_Trade_Expenses__c = breakdown.VECPerTradeExpense;
                subFinancial.ASI_CRM_CN_V0_Fixed_Trade_Expenses__c = breakdown.fixCostPerTradeExpense;
                subFinancial.ASI_CRM_CN_V0_Margin_PerBottle__c = breakdown.MarginPerBottle;
                if (subFinancial.ASI_CRM_CN_Domestic_CM_After_Spending__c != null && subFinancial.ASI_CRM_CN_Domestic_CM_After_Spending__c !=0) {
                    subFinancial.ASI_CRM_CN_V0_Contract_Index_Domestic__c = subFinancial.ASI_CRM_CN_V0_Margin_PerBottle__c != null ? (subFinancial.ASI_CRM_CN_V0_Margin_PerBottle__c/subFinancial.ASI_CRM_CN_Domestic_CM_After_Spending__c * 100).setScale(2):0;
                }

                if (subFinancial.ASI_CRM_CN_Regional_Average_After_Spend__c != null && subFinancial.ASI_CRM_CN_Regional_Average_After_Spend__c !=0) {
                    subFinancial.ASI_CRM_CN_V0_Regional_Target_Index__c = subFinancial.ASI_CRM_CN_V0_Margin_PerBottle__c != null ? (subFinancial.ASI_CRM_CN_V0_Margin_PerBottle__c/subFinancial.ASI_CRM_CN_Regional_Average_After_Spend__c * 100).setScale(2):0;
                }
                
                subFinancialMap.put(breakdown.subBrandId, subFinancial);
                existSubFinancialMap.remove(breakdown.subBrandId);
            }
        }   

        if (VfinalfinancialData != null) {
            contract.ASI_CRM_CN_VF_Trade_Expenses__c = VfinalfinancialData.TradeExpenses;
            contract.ASI_CRM_CN_VF_Variable_Expenses__c = VfinalfinancialData.VariableExpense;
            contract.ASI_CRM_CN_VF_Fixed_Expenses__c = VfinalfinancialData.FixedExpense;
            contract.ASI_CRM_CN_VF_Total_Std_Volums__c = VfinalfinancialData.IntakeSTD;
            contract.ASI_CRM_CN_VF_Gross_Sales__c = VfinalfinancialData.GrossSalesTotal;
            contract.ASI_CRM_CN_VF_Gross_Sales_ProForma__c = VfinalfinancialData.GrossSalesTotalProForma;
            contract.ASI_CRM_CN_VF_CM_before_spending__c = VfinalfinancialData.CMTotal;
            contract.ASI_CRM_CN_VF_CM_before_spend_ProForma__c = VfinalfinancialData.LatestBudgetCMTotal;
            contract.ASI_CRM_CN_VF_A_D__c = VfinalfinancialData.ADTotal;
            contract.ASI_CRM_CN_VF_A_D_ProForma__c = VfinalfinancialData.ADTotalProForma;
            contract.ASI_CRM_CN_VF_Margin_AP__c = VfinalfinancialData.MarginAfterAnP;
            contract.ASI_CRM_CN_VF_Margin_AP_ProForma__c = VfinalfinancialData.MarginAfterAnPProForma;
            contract.ASI_CRM_CN_VF_Margin_PerBottle__c = VfinalfinancialData.MarginPerBottle;
            contract.ASI_CRM_CN_VF_Margin_PerBottle_ProForma__c = VfinalfinancialData.MarginPerBottleProForma;
            contract.ASI_CRM_CN_VF_Domestic_Target_CM__c = VfinalfinancialData.DomesticTarget;
            contract.ASI_CRM_CN_VF_Region_Average_CM__c = VfinalfinancialData.RegionalAverageTarget;
            contract.ASI_CRM_CN_VF_Contract_Index_Domestic__c = VfinalfinancialData.DomesticContractIndex;
            contract.ASI_CRM_CN_VF_Cont_Index_Dom_ProForma__c = VfinalfinancialData.DomesticContractIndexProForma;
            contract.ASI_CRM_CN_VF_Regional_Average_Index__c = VfinalfinancialData.RegionalAverageIndex;
            contract.ASI_CRM_CN_VF_Reg_Average_Index_ProForma__c = VfinalfinancialData.RegionalAverageIndexProForma;
            contract.ASI_CRM_CN_VF_Regional_Target_Index__c = VfinalfinancialData.RegionalTargetIndex;
            contract.ASI_CRM_CN_VF_Reg_Target_Index_ProForma__c = VfinalfinancialData.RegionalTargetIndexProForma;

            for (TradeExpenseBreakdown2nd breakdown : VFinalfinancialData.TradeExpenseBySubBrand) {
                ASI_CRM_CN_Subbrand_Financial__c subFinancial = new ASI_CRM_CN_Subbrand_Financial__c();
                if (subFinancialMap.containsKey(breakdown.subBrandId)) {
                    subFinancial = subFinancialMap.get(breakdown.subBrandId);
                }
                subFinancial.ASI_TH_CRM_Contract__c = contract.Id;
                subFinancial.RecordTypeId = recordTypeId;
                subFinancial.ASI_CRM_Subbrand__c = breakdown.subBrandId;
                subFinancial.ASI_CRM_CN_External_Id__c = contract.Id + '' +subFinancial.ASI_CRM_Subbrand__c;
                subFinancial.ASI_CRM_CN_COnvfactor_Ltocr12__c = breakdown.cr12Factor;
                subFinancial.ASI_CRM_CN_Factor_9L__c = breakdown.factor9L;
                subFinancial.ASI_CRM_CN_CM_Before_Spending__C = breakdown.CMBeforeSpending != null ? (breakdown.CMBeforeSpending * breakdown.factor9L/9).setScale(4):0;
                subFinancial.ASI_CRM_CN_Domestic_Index_Target__c = breakdown.DomesticIndexTarget;
                subFinancial.ASI_CRM_CN_Domestic_Investment__c = breakdown.DomesticInvestment != null ? (breakdown.DomesticInvestment * breakdown.factor9L/9).setScale(4):0;
                subFinancial.ASI_CRM_CN_Domestic_CM_After_Spending__c = breakdown.DomesticCMAfterSpending != null ? (breakdown.DomesticCMAfterSpending * breakdown.factor9L/9).setScale(4):0;
                subFinancial.ASI_CRM_CN_Regional_Average_Index__c = breakdown.RegionalAverageIndex;
                subFinancial.ASI_CRM_CN_Regional_Average_Investment__c = breakdown.RegionalAverageInvestment != null ? (breakdown.RegionalAverageInvestment * breakdown.factor9L/9).setScale(4):0;
                subFinancial.ASI_CRM_CN_Regional_Average_After_Spend__c = breakdown.RegionalAverageAfterSpending != null ? (breakdown.RegionalAverageAfterSpending * breakdown.factor9L/9).setScale(4):0;
                subFinancial.ASI_CRM_CN_VF_Trade_Expenses__c = breakdown.totalTradeExpense;
                subFinancial.ASI_CRM_CN_VF_Total_Volums__c = breakdown.volumeSTD;
                subFinancial.ASI_CRM_CN_VF_Trade_Expenses_PerBottle__c = breakdown.tradeExpensePerBottle2nd;
                subFinancial.ASI_CRM_CN_VF_Monthly_Volums__c = breakdown.monthlyVolumeSTD;
                subFinancial.ASI_CRM_CN_VF_BRSF_Trade_Expenses__c = breakdown.BRSFPerTradeExpense;
                subFinancial.ASI_CRM_CN_VF_PSF_Trade_Expenses__c = breakdown.PSFPerTradeExpense;
                subFinancial.ASI_CRM_CN_VF_VEC_Trade_Expenses__c = breakdown.VECPerTradeExpense;
                subFinancial.ASI_CRM_CN_VF_Fixed_Trade_Expenses__c = breakdown.fixCostPerTradeExpense;
                subFinancial.ASI_CRM_CN_VF_Margin_PerBottle__c = breakdown.MarginPerBottle;
                if (subFinancial.ASI_CRM_CN_Domestic_CM_After_Spending__c != null && subFinancial.ASI_CRM_CN_Domestic_CM_After_Spending__c !=0) {
                    subFinancial.ASI_CRM_CN_VF_Contract_Index_Domestic__c = subFinancial.ASI_CRM_CN_VF_Margin_PerBottle__c != null ? (subFinancial.ASI_CRM_CN_VF_Margin_PerBottle__c/subFinancial.ASI_CRM_CN_Domestic_CM_After_Spending__c * 100).setScale(2):0;
                }

                if (subFinancial.ASI_CRM_CN_Regional_Average_After_Spend__c != null && subFinancial.ASI_CRM_CN_Regional_Average_After_Spend__c !=0) {
                    subFinancial.ASI_CRM_CN_VF_Regional_Target_Index__c = subFinancial.ASI_CRM_CN_VF_Margin_PerBottle__c != null ? (subFinancial.ASI_CRM_CN_VF_Margin_PerBottle__c/subFinancial.ASI_CRM_CN_Regional_Average_After_Spend__c * 100).setScale(2):0;
                }
                
                subFinancialMap.put(breakdown.subBrandId, subFinancial);
                existSubFinancialMap.remove(breakdown.subBrandId);
            }
        }

        update contract;

        if (!existSubFinancialMap.isEmpty()) {
            delete existSubFinancialMap.values();
        }

        System.debug(LoggingLevel.INFO, '*** subFinancialMap: ' + subFinancialMap);
        if (!subFinancialMap.isEmpty()) {
            upsert subFinancialMap.values() ASI_CRM_CN_External_Id__c;
        }


    }

    //@description: Restructure latest PO record of the Historical V0.0 and v0.0 PO (historical PO record which its PO end date is within 6 months to the PO start date of the selected PO)
    //@param: input current Contract
    //@return
    public static void RestructureHistoricalFinancialIndicatorData(ASI_TH_CRM_Contract__c contract){
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);
        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal> ();
        //Define variable
        ASI_TH_CRM_Contract__c PreviousCC = new ASI_TH_CRM_Contract__c();
        FinancialIndicator HistoricalV00Contract = new FinancialIndicator();
        FinancialIndicator HistoricalVFinalContract = new FinancialIndicator();
        Date startDate;
        Date endDate;
        String strRegion='',CommercialTeam='';
        Set<Id> HistoricalAllOutlet = new Set<Id>();
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        //key: date+SubBrand    for historical v0.0
        Map <String, subbrand_data> historicalV0_sbDataROI_map =new Map <String, subbrand_data>();
        Map <String, subbrand_data> historical_sbDataROI_map =new Map <String, subbrand_data>();

        //Calculate RegionSubBrandCM_Map
        String currentFY = String.valueOf(FYConversion(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';

        //Finding Old Promotion Types
        Set<String> oldPromotionTypes = new Set<String>();
        if(thisCC.ASI_CRM_New_FY_PO__c){
            for(ASI_CRM_Special_Promotion_Type_Mapping__c obj:[SELECT Id,ASI_CRM_Mapping_of_New_Promotion_Type__c , ASI_CRM_Mapping_of_Old_Promotion_Type__c , ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c , ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c FROM ASI_CRM_Special_Promotion_Type_Mapping__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Special_Promotion_Type_Mapping' AND ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c = : thisCC.ASI_TH_CRM_Promotion_Type__c ]){
                oldPromotionTypes.add(obj.ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c);
            }
        }

        Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> CMGSBySubBrand = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();

        if (thisCC.ASI_CRM_CN_PO_Start_Date__c != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null && thisCC.ASI_TH_CRM_Promotion_Type__c != null){
            //Criteria within 6 Months (from PO start date)
            Integer strDays = 365/12*6;
            Date strDate = thisCC.ASI_CRM_CN_PO_Start_Date__c - strDays;
            //Retrieve Historical v0.0 contract

            try {
                PreviousCC = [
                    SELECT
                        Id,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c,
                        ASI_CRM_Martell_BC_Rate__c,
                        ASI_CRM_CN_Expected_PSF_Est_Total__c,
                        ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                        ASI_CRM_EVC_Cost_Estimate_Total__c,

                        ASI_TH_CRM_Promotion_Type__c,
                        ASI_CRM_CN_PO_Version__c,
                        ASI_CRM_CN_Total_Contract_Amount__c,
                        ASI_CRM_Volume_Option__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                        ASI_CRM_CN_Outlet_WS__c,
                        ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                        ASI_CRM_CN_BRSF_Contract_Total__c,
                        ASI_CRM_CN_Contract_Cost_Total__c,
                        ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                        ASI_CRM_CN_Contract_Variable_Cost_Total__c,
                        ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__c,
                        Owner.Name,
                        ASI_CRM_CN_V0_0_PO_version__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                        ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                        ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                        ASI_CRM_CN_Bottle_Collection_Rate__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                        ASI_CRM_New_FY_PO__c,
                        ASI_CRM_CN_Status__c
                    FROM ASI_TH_CRM_Contract__c
                    WHERE ASI_CRM_CN_Outlet_WS__c = :thisCC.ASI_CRM_CN_Outlet_WS__c AND ASI_CRM_CN_PO_End_Date__c != NULL AND
                    ASI_CRM_CN_PO_Start_Date__c != NULL
                    AND ASI_CRM_CN_PO_End_Date__c <= :thisCC.ASI_CRM_CN_PO_Start_Date__c AND ASI_CRM_CN_PO_End_Date__c >= :strDate AND
                    (ASI_TH_CRM_Promotion_Type__c = :thisCC.ASI_TH_CRM_Promotion_Type__c OR ASI_TH_CRM_Promotion_Type__c IN :oldPromotionTypes)
                    AND (ASI_CRM_CN_Status__c = 'Final' OR ASI_CRM_CN_Status__c = 'Archived' OR ASI_CRM_CN_Status__c = 'Submitted')
                    ORDER BY ASI_CRM_CN_Status__c DESC, ASI_CRM_CN_PO_End_Date__c DESC, Name DESC, ASI_CRM_CN_PO_Version__c DESC
                    LIMIT 1
                ];
            } catch (Exception e) {
                PreviousCC = new ASI_TH_CRM_Contract__c();
            }

            if (PreviousCC != null && PreviousCC.ASI_CRM_CN_Status__c == 'Archived') {
                String v0Id = PreviousCC.ASI_CRM_CN_V0_0_PO_version__c == null? PreviousCC.Id : PreviousCC.ASI_CRM_CN_V0_0_PO_version__c;
                List<ASI_TH_CRM_Contract__c> CheckLatestContract = new List<ASI_TH_CRM_Contract__c>([
                    SELECT
                        Id,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c,
                        ASI_CRM_Martell_BC_Rate__c,
                        ASI_CRM_CN_Expected_PSF_Est_Total__c,
                        ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                        ASI_CRM_EVC_Cost_Estimate_Total__c,

                        ASI_CRM_CN_PO_Version__c,
                        ASI_TH_CRM_Promotion_Type__c,
                        ASI_CRM_CN_Total_Contract_Amount__c,
                        ASI_CRM_Volume_Option__c,
                        ASI_CRM_CN_Outlet_WS__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                        ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                        ASI_CRM_CN_BRSF_Contract_Total__c,
                        ASI_CRM_CN_Contract_Cost_Total__c,
                        ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                        ASI_CRM_CN_Contract_Variable_Cost_Total__c,
                        ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__c,
                        Owner.Name,
                        ASI_CRM_CN_V0_0_PO_version__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                        ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                        ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                        ASI_CRM_CN_Bottle_Collection_Rate__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                        ASI_CRM_New_FY_PO__c,
                        ASI_CRM_CN_Status__c
                    FROM ASI_TH_CRM_Contract__c
                    WHERE ASI_CRM_CN_V0_0_PO_version__c = :v0Id
                    AND ASI_CRM_CN_Status__c != 'Draft' AND (NOT ASI_CRM_CN_Status__c LIKE 'FY Landing Archive')
                    AND ASI_CRM_CN_PO_End_Date__c != NULL AND ASI_CRM_CN_PO_Start_Date__c != NULL
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ]);

                if(CheckLatestContract.size()>0){
                    if(CheckLatestContract[0].ASI_CRM_CN_PO_End_Date__c <= thisCC.ASI_CRM_CN_PO_Start_Date__c && CheckLatestContract[0].ASI_CRM_CN_PO_End_Date__c >= strDate){
                        PreviousCC = CheckLatestContract[0];
                    }else{
                        PreviousCC = new ASI_TH_CRM_Contract__c();
                    }
                }
            }
            //End of finding Historical v0.0 contract
        }


        //Assign/Calculate data
        if(PreviousCC.Id != null){
            String HistoricalV00ContractId = null;
            Date StartDateExtend;
            Date EndDateExtend;
            Set<Id> V00SubBrandIdSet = new Set<Id> ();
            HistoricalAllOutlet.add(PreviousCC.ASI_CRM_CN_Outlet_WS__c);
            //Getting Historical Outlet Id  for vFinal
            if(PreviousCC.ASI_CRM_Volume_Option__c == 'Wholesaler Only' ){
                System.debug('Now Outlet HC:'+PreviousCC.ASI_CRM_CN_Outlet_WS__c);
                HistoricalAllOutlet.add(PreviousCC.ASI_CRM_CN_Outlet_WS__c);
            }else{
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :PreviousCC.Id]){
                    System.debug('Now Outlet HC 2:'+CO_temp.ASI_CRM_CN_Outlet__c);
                    HistoricalAllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }

            HistoricalVFinalContract.OutletSet=HistoricalAllOutlet;


            //Contract level Handling
            if(PreviousCC != null && PreviousCC.Id != null && PreviousCC.ASI_CRM_CN_V0_0_PO_version__c == null){
                HistoricalV00Contract.ContractId = PreviousCC.Id;
                HistoricalV00ContractId = PreviousCC.Id;

                HistoricalV00Contract.TotalMBCRate = PreviousCC.ASI_CRM_Martell_BC_Rate__c!= null?PreviousCC.ASI_CRM_Martell_BC_Rate__c:0;
                HistoricalV00Contract.BCRate = PreviousCC.ASI_CRM_CN_Bottle_Collection_Rate__c!= null?PreviousCC.ASI_CRM_CN_Bottle_Collection_Rate__c:0;
                HistoricalV00Contract.POStartDate =PreviousCC.ASI_CRM_CN_PO_Start_Date__c!=null?PreviousCC.ASI_CRM_CN_PO_Start_Date__c:null;
                HistoricalV00Contract.POEndDate =PreviousCC.ASI_CRM_CN_PO_End_Date__c!=null?PreviousCC.ASI_CRM_CN_PO_End_Date__c:null;

                startDate = PreviousCC.ASI_CRM_CN_PO_Start_Date__c!=null?PreviousCC.ASI_CRM_CN_PO_Start_Date__c:null;
                endDate = PreviousCC.ASI_CRM_CN_PO_End_Date__c!= null?PreviousCC.ASI_CRM_CN_PO_End_Date__c : null;
                StartDateExtend= PreviousCC.ASI_CRM_CN_PO_Start_Date__c!=null? getEndDate(PreviousCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1)) :null;
                EndDateExtend = PreviousCC.ASI_CRM_CN_PO_End_Date__c!=null? getEndDate(PreviousCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1)):null;
                strRegion= PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
                CommercialTeam= PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';

                //Current Contract is V0.0
                if(PreviousCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                    HistoricalV00Contract.TradeExpenses = PreviousCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
                if(PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
                    HistoricalV00Contract.FixedExpense = PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
                if(PreviousCC.ASI_CRM_CN_No_of_Months__c != 0 &&  PreviousCC.ASI_CRM_CN_No_of_Months__c != null)
                    HistoricalV00Contract.NoOfMonths = Integer.valueOf(PreviousCC.ASI_CRM_CN_No_of_Months__c);


            }else if(PreviousCC != null && PreviousCC.ASI_CRM_CN_V0_0_PO_version__c != null){
                HistoricalV00Contract.ContractId = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.Id;
                HistoricalV00ContractId = PreviousCC.ASI_CRM_CN_V0_0_PO_version__c;

                HistoricalV00Contract.TotalMBCRate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c!=null? PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c:0;
                HistoricalV00Contract.BCRate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c!=null? PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c:0;

                HistoricalV00Contract.POStartDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null?PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c:null;
                HistoricalV00Contract.POEndDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null?PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c:null;

                startDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null?PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c:null;
                endDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null?PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c:null;
                StartDateExtend= PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null? getEndDate(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c.addYears(-1)) :null;
                EndDateExtend = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null? getEndDate(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c.addYears(+1)):null;
                strRegion = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c !=null? PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c: '';
                CommercialTeam= PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';


                //Current Contract is VFinal
                if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                    HistoricalV00Contract.TradeExpenses = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
                if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
                    HistoricalV00Contract.FixedExpense = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
                if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != 0 &&  PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != null)
                    HistoricalV00Contract.NoOfMonths = Integer.valueOf(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c);
            } else{
                HistoricalV00ContractId = null;
            }

            //Historical v0.0 BRSF Line only for By Sub-Brand
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PreviousV0CC_BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();

            System.debug('HistoricalV00ContractId : '+HistoricalV00ContractId);
            if(HistoricalV00ContractId != null){
                Map<Date, Decimal> PreviousV0CC_Period_map = checkFYDayPeriod(startDate, endDate);
                //CMTotalV0 :  Cont. Margin before A&P
                Decimal CMTotalV0=0;
                Decimal LatestBudgetCMTotalV0 = 0;
                Decimal BRSFEstimateVolumesTotalV0 = 0; // Calculate BRSF Estimate Volumes Total for V0.0 contract


                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();

                //<Sub-Brand Id, Estimate Volume Amount> : the Estimate Volume for each Sub-Brand Mapping
                Map<String, Decimal> EstimateVolumeV0Map =new Map<String, Decimal>();
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = [SELECT Id,RecordType.DeveloperName, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Methodology__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c,ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
                    ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,ASI_CRM_CN_Estimate_Volume_9L_Month__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_Volume_Base__c,ASI_CRM_Type__c
                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c =:HistoricalV00ContractId ];



                for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c  FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :HistoricalV00ContractId])
                {
                    if (ccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                        HistoricalV00Contract.VariableExpense += ccost.ASI_CRM_CN_Estimate_Amount__c!=null?ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    }
                }


                Set<String> PSFMethodologySet = new  Set<String>();
                Set<String> PSFVolumeBaseSet= new  Set<String>();
                //Looping the Contract Line
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractLineList){       //By Sub-Brand
                    //if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){
                    if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null )
                    {
                        System.debug('V00SubBrandIdSet :'+ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c);
                        V00SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        Decimal V00Volumes = 0;
                        if (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                            V00Volumes = (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c* ContractLine.ASI_CRM_CN_No_of_Months__c);
                        }
                        //Get All BRSF Estimate Volumes
                        if((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ){
                            BRSFEstimateVolumesTotalV0 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                            BRSFList.add(ContractLine);
                            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                                HistoricalV00Contract.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                            }
                        }
                        if(ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c!=null){
                            if(EstimateVolumeV0Map.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                                Decimal TempEstimateVolume = EstimateVolumeV0Map.get(ContractLine.ASI_CRM_CN_Sub_Brand__c)+ ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c ;
                                EstimateVolumeV0Map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, TempEstimateVolume);
                            }else{
                                EstimateVolumeV0Map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c);
                            }
                        }


                        //Calculate Volume
                        HistoricalV00Contract.Volumes += V00Volumes;

                        //By Sub-Brand Grade Grouping
                        String SubbrandGroupName='0. Not Specified';
                        String SubBrandName='';
                        if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                            SubbrandGroupName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null?ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c:ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                            SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        }

                        if(HistoricalV00Contract.SubBrandGradeGrouping.containsKey(SubBrandName)){
                            Decimal TempVolumes=HistoricalV00Contract.SubBrandGradeGrouping.get(SubBrandName)+V00Volumes;
                            HistoricalV00Contract.SubBrandGradeGrouping.remove(SubBrandName);//remove orignal one
                            HistoricalV00Contract.SubBrandGradeGrouping.put(SubBrandName,TempVolumes);
                        }else{
                            HistoricalV00Contract.SubBrandGradeGrouping.put(SubBrandName,V00Volumes);
                        }

                        if(HistoricalV00Contract.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                            Decimal TempVolumes=HistoricalV00Contract.SubBrandGradeMap.get(SubbrandGroupName)+V00Volumes;
                            //remove orignal one
                            HistoricalV00Contract.SubBrandGradeMap.remove(SubbrandGroupName);
                            HistoricalV00Contract.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
                        }else{
                            HistoricalV00Contract.SubBrandGradeMap.put(SubbrandGroupName,V00Volumes);
                        }

                        //By Brande Product Category Grouping
                        if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c !=null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                            String CategoryName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                            if(HistoricalV00Contract.CategoryMap.containsKey(CategoryName)){
                                Decimal TempVolumes=HistoricalV00Contract.CategoryMap.get(CategoryName)+V00Volumes;
                                //remove orignal one
                                HistoricalV00Contract.CategoryMap.remove(CategoryName);
                                HistoricalV00Contract.CategoryMap.put(CategoryName,TempVolumes);
                            }else{
                                HistoricalV00Contract.CategoryMap.put(CategoryName,V00Volumes);
                            }
                        }// end of By Brande Product Category Grouping


                        if (PreviousV0CC_Period_map != null && PreviousV0CC_Period_map.size() > 0){
                            for (Date previousV0CCdate : PreviousV0CC_Period_map.keySet() ){

                                Date strDateCC = FYConversion(previousV0CCdate);
                                String strkey_p = String.valueOf(strDateCC) + ContractLine.ASI_CRM_CN_Sub_Brand__c ;
                                subbrand_data newitem = new subbrand_data();
                                newitem.period = PreviousV0CC_Period_map.get(previousV0CCdate);//This fiscal year's month number
                                newitem.SubBrandId = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                                newitem.TotalVolume = 0;
                                newitem.TotalEstVolume = 0;
                                historicalV0_sbDataROI_map.put(strkey_p, newitem);
                            }
                        }
                        //HistoricalV00Contract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;

                    }else{//Not By Sub-Brand

                    }
                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Module__c!=null){
                        if(!PSFMethodologySet.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                            PSFMethodologySet.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                            HistoricalV00Contract.PSFMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                        }
                        if(!PSFVolumeBaseSet.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                            PSFVolumeBaseSet.add(ContractLine.ASI_CRM_Volume_Base__c);
                            HistoricalV00Contract.PSFVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                        }
                    }
                    //Estimate contract cost total
                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
                        HistoricalV00Contract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
                        HistoricalV00Contract.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
                    }else{
                        HistoricalV00Contract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                        //SUM(BRSF estimate cost, Other variable cost)
                        HistoricalV00Contract.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    }

                }//end of Looping the Contract Line



                Map<String,Decimal> CR12FactorMap = GenerateCR12FactorMap(V00SubBrandIdSet, CommercialTeam, strRegion);
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine :BRSFList){
                    if (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                        Decimal CR12Factor=1;
                        if(CR12FactorMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                            CR12Factor=CR12FactorMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        }
                        HistoricalV00Contract.IntakeCR12 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                    }
                }


                Date StartDateExtend2 = Date.newInstance(StartDateExtend.addYears(-1).year(), 6, 30);
                Date EndDateExtend2 = Date.newInstance(EndDateExtend.year(), 6, 30);

                //Getting GM/GS Data


                for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c FROM ASI_CRM_CM_GS__c
                WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3) AND
                ASI_CRM_Region__c = :strRegion  AND ASI_CRM_TYPE__c = 'Budget CM'
                AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  
                AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS') 
                ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
                {// and ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
                    String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
                    Decimal cm=0.0;
                    if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                        cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
                    }
                    if (!RegionSubBrandCM_Map.containsKey(ProductCode)){
                        RegionSubBrandCM_Map.put(ProductCode,cm) ;
                    }
                }


                Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();
                for (ASI_CRM_CM_GS__c line : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Month__c FROM ASI_CRM_CM_GS__c
                WHERE ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet   AND ASI_CRM_Region__c = :strRegion AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
                AND ( (ASI_CRM_CN_Month_End_Date__c >= :StartDateExtend AND ASI_CRM_CN_Month_End_Date__c <= :EndDateExtend )
                OR (ASI_CRM_CN_Month_End_Date__c >= :StartDateExtend2   AND ASI_CRM_CN_Month_End_Date__c <= :EndDateExtend2
                AND ASI_CRM_CN_Month__c = 6  ) )
                AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  
                AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS') 
                ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
                {

                    String strkey_v0 = String.valueOf(line.ASI_CRM_CN_Month_End_Date__c) + line.ASI_CRM_PRODUCTCODE__c;
                    if(line.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(line.ASI_CRM_PRODUCTCODE__c + line.ASI_CRM_TYPE__c) &&
                        line.ASI_CRM_CM_GS_per_9L__c != null && line.ASI_CRM_CM_GS_per_9L__c != 0){
                        cmgsMap.put(line.ASI_CRM_PRODUCTCODE__c +line.ASI_CRM_TYPE__c, line);
                    }

                    if (historicalV0_sbDataROI_map.containsKey(strkey_v0) && line.ASI_CRM_CM_GS_per_9L__c != null && line.ASI_CRM_CM_GS_per_9L__c != 0  ){
                        if ( historicalV0_sbDataROI_map.get(strkey_v0).CM == null || historicalV0_sbDataROI_map.get(strkey_v0).CM == 0 ){
                            if (line.ASI_CRM_TYPE__c == 'Budget CM'){
                                historicalV0_sbDataROI_map.get(strkey_v0).CM = line.ASI_CRM_CM_GS_per_9L__c;
                                //HistoricalV00Contract.CMId+=line.Id+';';
                            }
                        }
                        if(historicalV0_sbDataROI_map.get(strkey_v0).GS == null || historicalV0_sbDataROI_map.get(strkey_v0).GS == 0){
                            if (line.ASI_CRM_TYPE__c == 'Budget GS'){
                                historicalV0_sbDataROI_map.get(strkey_v0).GS = line.ASI_CRM_CM_GS_per_9L__c;
                                //HistoricalV00Contract.GSId+=line.Id+';';
                            }
                        }

                        if (historicalV0_sbDataROI_map.containsKey(strkey_v0)){
                            if (historicalV0_sbDataROI_map.get(strkey_v0).latestBudgetCM == null || historicalV0_sbDataROI_map.get(strkey_v0).latestBudgetCM == 0){
                                if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                                    historicalV0_sbDataROI_map.get(strkey_v0).latestBudgetCM = RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c);
                                }
                            }
                        }
                    }
                }// End of CM/GS Looping



                // to replace null value with latest CMGS data
                for(String key : historicalV0_sbDataROI_map.keySet()){
                    if(historicalV0_sbDataROI_map.get(key).CM == null || historicalV0_sbDataROI_map.get(key).CM == 0 || historicalV0_sbDataROI_map.get(key).GS == null || historicalV0_sbDataROI_map.get(key).GS == 0 || historicalV0_sbDataROI_map.get(key).latestBudgetCM == null || historicalV0_sbDataROI_map.get(key).latestBudgetCM == 0){
                        if((historicalV0_sbDataROI_map.get(key).CM == null || historicalV0_sbDataROI_map.get(key).CM == 0) &&
                            cmgsMap.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget CM')){
                            ASI_CRM_CM_GS__c cmgs = cmgsMap.get(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget CM');
                            historicalV0_sbDataROI_map.get(key).CM = cmgs.ASI_CRM_CM_GS_per_9L__c;
                            //HistoricalV00Contract.GSId+=cmgs.Id+';';
                        }

                        if((historicalV0_sbDataROI_map.get(key).GS == null || historicalV0_sbDataROI_map.get(key).GS == 0) && cmgsMap.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget GS')){
                            ASI_CRM_CM_GS__c cmgs = cmgsMap.get(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget GS');
                            historicalV0_sbDataROI_map.get(key).GS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                            //HistoricalV00Contract.CMId+=cmgs.Id+';';
                        }

                        if(historicalV0_sbDataROI_map.get(key).latestBudgetCM == null || historicalV0_sbDataROI_map.get(key).latestBudgetCM == 0){
                            if(RegionSubBrandCM_Map.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId)){
                                historicalV0_sbDataROI_map.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(historicalV0_sbDataROI_map.get(key).SubBrandId);
                            }

                        }
                    }
                }



                //Calculate Total CM
                if (historicalV0_sbDataROI_map != null && historicalV0_sbDataROI_map.size() > 0){
                    Decimal ActualGS;
                    Decimal ActualCM; //Budget CM
                    Decimal LatestBudgetCM; // Latest Budget CM
                    Decimal TotalEstimateVol;
                    Decimal PeriodStr; // Number of month

                    for (String key : historicalV0_sbDataROI_map.keySet()){
                        PeriodStr= null;
                        if (historicalV0_sbDataROI_map.get(key).period != null){
                            PeriodStr = historicalV0_sbDataROI_map.get(key).period;
                        }
                        //Budget CM
                        ActualCM = null;
                        if (historicalV0_sbDataROI_map.get(key).CM != null){
                            ActualCM = historicalV0_sbDataROI_map.get(key).CM;
                        }
                        // Latest Budget CM
                        LatestBudgetCM = null;
                        if (historicalV0_sbDataROI_map.get(key).latestBudgetCM != null){
                            LatestBudgetCM = historicalV0_sbDataROI_map.get(key).latestBudgetCM;
                        }
                        //Budget GS
                        ActualGS = null;
                        if (historicalV0_sbDataROI_map.get(key).GS != null){
                            ActualGS = historicalV0_sbDataROI_map.get(key).GS;
                        }
                        TotalEstimateVol = null;
                        if (EstimateVolumeV0Map != null && historicalV0_sbDataROI_map.get(key) != null && historicalV0_sbDataROI_map.get(key).SubBrandId != null && EstimateVolumeV0Map.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId)){
                            TotalEstimateVol = EstimateVolumeV0Map.get(historicalV0_sbDataROI_map.get(key).SubBrandId);
                        }//system.debug('NEW totalestimatevol : '+TotalEstimateVol);
                        //Total Volume
                        if (TotalEstimateVol != null && ActualCM != null && PeriodStr != null){
                            CMTotalV0 += ActualCM * TotalEstimateVol * PeriodStr;
                        }

                        if (TotalEstimateVol != null && LatestBudgetCM != null && PeriodStr != null){
                            LatestBudgetCMTotalV0 += LatestBudgetCM * TotalEstimateVol * PeriodStr;
                        }
                        //Gross Sales
                        if (TotalEstimateVol != null && ActualGS != null && PeriodStr != null){
                            HistoricalV00Contract.GrossSalesTotal += ActualGS * TotalEstimateVol * PeriodStr;
                        }
                    }
                }// end of historicalV0_sbDataROI_map Looping

                //**************************Calculation**************************

                if(HistoricalV00Contract.TradeExpenses != null && HistoricalV00Contract.TradeExpenses != 0 ){
                    HistoricalV00Contract.FixedExpenseRate = HistoricalV00Contract.FixedExpense / HistoricalV00Contract.TradeExpenses *100;

                }

                //Calculate 'Investment per CR12 eq btl ' = Trade expenses / (CR12 Conversion Factor in Sub-brand * estimate Monthly vol. * PO Period in Sub-Brand )
                if (HistoricalV00Contract.IntakeCR12 != 0 && HistoricalV00Contract.IntakeCR12!= null &&  HistoricalV00Contract.TradeExpenses != 0 &&  HistoricalV00Contract.TradeExpenses != null){
                    HistoricalV00Contract.InvestmentCR12 =  (HistoricalV00Contract.TradeExpenses / HistoricalV00Contract.IntakeCR12).setScale(2);
                }

                //Calculate Historical V0 Cont. Margin after A&P = SUM( Budget CMs * estimate Monthly vol. in 9L  of PO period) - Trade expenses
                if (CMTotalV0 != null && HistoricalV00Contract.TradeExpenses != null){
                    HistoricalV00Contract.MarginAfterAnP = CMTotalV0 - HistoricalV00Contract.TradeExpenses;
                }

                //
                if (BRSFEstimateVolumesTotalV0 != null && HistoricalV00Contract.NoOfMonths != null){
                    //HistoricalV00Contract.MarginPerBottle =BRSFEstimateVolumesTotalV0 * HistoricalV00Contract.NoOfMonths;
                    HistoricalV00Contract.IntakeSTD=BRSFEstimateVolumesTotalV0 * HistoricalV00Contract.NoOfMonths;
                }

                if (HistoricalV00Contract.IntakeSTD!= 0 && HistoricalV00Contract.IntakeSTD != null && HistoricalV00Contract.MarginAfterAnP != 0 && HistoricalV00Contract.MarginAfterAnP != null){
                    HistoricalV00Contract.MarginPerBottle = (HistoricalV00Contract.MarginAfterAnP / HistoricalV00Contract.IntakeSTD).setScale(2);
                }

                //Gross Sales Rate Historical V0
                if (HistoricalV00Contract.GrossSalesTotal  != null && HistoricalV00Contract.GrossSalesTotal  != 0 && HistoricalV00Contract.TradeExpenses!= 0 && HistoricalV00Contract.TradeExpenses != null){
                    HistoricalV00Contract.GrossSalesRate = (HistoricalV00Contract.TradeExpenses / HistoricalV00Contract.GrossSalesTotal  * 100).setScale(2);
                }

                // ROI Intake Historical V0 = Cont. Margin before A&P / Trade expenses
                if (CMTotalV0 != null && CMTotalV0 != 0 && HistoricalV00Contract.TradeExpenses != 0 && HistoricalV00Contract.TradeExpenses != null){
                    HistoricalV00Contract.CMTotal=CMTotalV0;
                    HistoricalV00Contract.ROIIntake = (CMTotalV0 / HistoricalV00Contract.TradeExpenses).setScale(2);
                    HistoricalV00Contract.ROIActual=HistoricalV00Contract.ROIIntake;
                }

                //Calculate ROIProForma = Cont. Margin before A&P from latest CM regardless FY / Trade expenses
                if (LatestBudgetCMTotalV0 != null && LatestBudgetCMTotalV0 != 0 && HistoricalV00Contract.TradeExpenses != 0 && HistoricalV00Contract.TradeExpenses!= null){
                    HistoricalV00Contract.LatestBudgetCMTotal=LatestBudgetCMTotalV0;
                    HistoricalV00Contract.ROIProForma = (LatestBudgetCMTotalV0/ HistoricalV00Contract.TradeExpenses).setScale(2);
                }


            }//Finished getting/Calculate V0.0 data


            //
            //******************************************************   Starting Calculating VFinal Data**********************************************
            if(PreviousCC.ASI_CRM_CN_No_of_Months__c != 0 &&  PreviousCC.ASI_CRM_CN_No_of_Months__c != null){
                HistoricalVFinalContract.NoOfMonths = Integer.valueOf(PreviousCC.ASI_CRM_CN_No_of_Months__c);
            }


            if(PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null){
                HistoricalVFinalContract.FixedExpense = PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
            }


            HistoricalVFinalContract.BCRate = PreviousCC.ASI_CRM_CN_Bottle_Collection_Rate__c!= null?PreviousCC.ASI_CRM_CN_Bottle_Collection_Rate__c:0;
            HistoricalVFinalContract.ContractId = PreviousCC.Id;
            HistoricalVFinalContract.POStartDate = PreviousCC.ASI_CRM_CN_PO_Start_Date__c;
            HistoricalVFinalContract.POEndDate= PreviousCC.ASI_CRM_CN_PO_End_Date__c;

            HistoricalVFinalContract.ContractLineMap = new Map<String,ContractLine>();
            HistoricalVFinalContract.FixedExpensesMap = new Map<String,ContractLine>();
            Decimal TotalHC_VolumeBtl =0; // total historical contract Volume BTL
            Decimal TotalHC_IntakeBtl =0;
            Decimal TotalHC_BC =0;  // total historical contract BC

            Decimal TotalBackCap=0;
            Decimal PSFEstTotal=0;
            Decimal VECEstTotal=0;



            Decimal TotalHistorical_MartellBC =0;  // total historical contract Martel BC
            Decimal TotalHistorical_MartellIntakeBtl =0;  // total historical contract Martel Intake Btl
            Decimal TotalHistorical_MartellBlackCap =0;  // total historical contract Martel BlackCap




            for (ASI_CRM_Contract_Cost__c pccost : [SELECT Id,Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Activity_Code__r.Name,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,
                ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c
            FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :PreviousCC.Id])
            {
                if (pccost.ASI_CRM_CN_Cost_Type__c == 'Fixed' && pccost.ASI_CRM_CN_Estimate_Amount__c != null ){
                    if (HistoricalVFinalContract.FixedExpensesMap.containsKey(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c)){
                        HistoricalVFinalContract.FixedExpensesMap.get(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c).HistoricalFees += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    }else{
                        ContractLine ContractDetail = new ContractLine ();
                        ContractDetail.HistoricalFees=pccost.ASI_CRM_CN_Estimate_Amount__c;
                        HistoricalVFinalContract.FixedExpensesMap.put(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c, ContractDetail);
                    }
                }
                if(pccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                    HistoricalVFinalContract.VariableExpense +=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    if(pccost.ASI_CRM_CN_Activity_Code__c!=null ){
                        if(pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('PSF') || pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('Promotion Service Fee')){
                            PSFEstTotal+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                        }
                    }
                    if(pccost.ASI_CRM_CN_Activity_Code__c!=null && pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('Variable Event Cost') ){
                        VECEstTotal+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    }

                }
                HistoricalVFinalContract.TradeExpenses+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
            }




            Set<String> PSFMethodologySetVFinal = new Set<String>();
            Set<String> PSFVolumeBaseSetVFinal = new Set<String>();

            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : [SELECT Id,ASI_CRM_Volume_Base__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,ASI_CRM_Type__c,ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Methodology__c,RecordType.DeveloperName,ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Sub_Brand__r.Name,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Total__c ,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Estimate_Volume_9L_Month__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :PreviousCC.Id]){

                if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){

                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                        HistoricalVFinalContract.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                    }

                    String LineKey=SBGradeSorting(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//ContractLineSBGradeName; //NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) +SuBBrandKey;//

                    if(HistoricalVFinalContract.ContractLineMap.containsKey(LineKey)){
                        HistoricalVFinalContract.ContractLineMap.get(LineKey).HistoricalFees = HistoricalVFinalContract.ContractLineMap.get(LineKey).HistoricalFees + ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    }else{
                        ContractLine ContractDetail = new ContractLine ();
                        ContractDetail.HistoricalFees = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                        ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                        ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        HistoricalVFinalContract.ContractLineMap.put(LineKey,ContractDetail);
                    }
                }

                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' ){
                    PSFEstTotal+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }
                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='Variable Event Cost' ){
                    VECEstTotal+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }


                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Module__c!=null){
                    if(!PSFMethodologySetVFinal.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                        PSFMethodologySetVFinal.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                        HistoricalVFinalContract.PSFMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                    }
                    if(!PSFVolumeBaseSetVFinal.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                        PSFVolumeBaseSetVFinal.add(ContractLine.ASI_CRM_Volume_Base__c);
                        HistoricalVFinalContract.PSFVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                    }
                }

                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
                    HistoricalVFinalContract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
                    HistoricalVFinalContract.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;

                }else{
                    HistoricalVFinalContract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    HistoricalVFinalContract.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }

            }

            //V0.1+ PO will calculate BRSF + PSF VEC part amount
            if(PreviousCC.ASI_CRM_CN_PO_Version__c!='0.0' && PreviousCC.ASI_TH_CRM_Promotion_Type__c== 'Heavy Contract On'){// ASI_CRM_CN_Total_Contract_Amount__c
                HistoricalVFinalContract.TradeExpenses=PreviousCC.ASI_CRM_CN_Total_Contract_Amount__c;
                HistoricalVFinalContract.VariableExpense=0;
                HistoricalVFinalContract.VariableExpense+=PreviousCC.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?PreviousCC.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
                HistoricalVFinalContract.VariableExpense+=PreviousCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null?PreviousCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
                HistoricalVFinalContract.VariableExpense+=PreviousCC.ASI_CRM_EVC_Cost_Estimate_Total__c!=null?PreviousCC.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
                HistoricalVFinalContract.VariableExpense+=PreviousCC.ASI_CRM_CN_Contract_Variable_Cost_Total__c!=null?PreviousCC.ASI_CRM_CN_Contract_Variable_Cost_Total__c:0;

            }
            AdditionalFIMap.put('PSFEstTotal',PSFEstTotal);
            AdditionalFIMap.put('VECEstTotal',VECEstTotal);


            Set<Id> HistoricalVFinalSBIdSet = new Set<Id> ();
            Date CutOffDay =GenerateCutOffDate();
            Date TillEnd;
            if (CutOffDay >= PreviousCC.ASI_CRM_CN_PO_End_Date__c)
                TillEnd = getEndDate(PreviousCC.ASI_CRM_CN_PO_End_Date__c);
            else
                TillEnd = CutOffDay;

            Integer PeriodA = MonthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
            Integer PeriodB = MonthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, PreviousCC.ASI_CRM_CN_PO_End_Date__c);

            Decimal TotalHCVolumeBtl=0;
            Map<Date, Decimal> HistoricalVFinal_Period_map = checkFYDayPeriod(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, PreviousCC.ASI_CRM_CN_PO_End_Date__c);
            System.debug('PeriodA 0.1: '+PeriodA);
            System.debug('PeriodB 0.1: '+PeriodB);
            System.debug('PreviousCC PreviousCC.ASI_CRM_CN_PO_Start_Date__c : '+PreviousCC.ASI_CRM_CN_PO_Start_Date__c );
            System.debug('PreviousCC TillEnd 0.1: '+TillEnd);

            HistoricalVFinalContract.DebugMap.put('HistoricalVFTillEnd',String.valueOf(TillEnd));

            List<ASI_CRM_Subbrand_Volume__c> HistoricalSBVolumeList = [SELECT Id, Name,ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                ASI_CRM_DeductCapWithIssue_StdBill__c,ASI_CRM_Grey_Cap_Std_Billing__c,ASI_CRM_Black_Cap_Std_Billing__c,ASI_CRM_Green_Cap_Std_Billing__c,ASI_CRM_Offtake__c,ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Offtake_CR12__c, ASI_CRM_Subbrand__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c, ASI_CRM_Subbrand__r.Name,  ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_T2_Depletion_BTL__c,ASI_CRM_T1_Depletion__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c, ASI_CRM_T2_Depletion__c, ASI_CRM_PR_Direct__c, ASI_CRM_PR_Direct_Btl__c,ASI_CRM_End_Date__c ,ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,
                ASI_CRM_PR_Direct_STD__c,ASI_CRM_Black_Cap_Btl__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_DeductibleCapWithIssues_Std_Btl__c,ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c
            FROM ASI_CRM_Subbrand_Volume__c WHERE  ASI_CRM_Account__c IN :HistoricalAllOutlet
            AND ASI_CRM_CN_Competitor_Sub_brand__c != TRUE AND ASI_CRM_Subbrand__c !=NULL
            AND ASI_CRM_End_Date__c >= :PreviousCC.ASI_CRM_CN_PO_Start_Date__c AND
            ASI_CRM_End_Date__c <= :TillEnd AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE];

            Set<Id> PreviousCC_SBId = new Set<Id>();

            for (ASI_CRM_Subbrand_Volume__c sbid : HistoricalSBVolumeList){
                PreviousCC_SBId.add(sbid.ASI_CRM_Subbrand__c);
            }

            for (Date PCCperiod: HistoricalVFinal_Period_map.keySet() ){
                if (PreviousCC_SBId.size() > 0){
                    for (Id sbidtemp : PreviousCC_SBId){
                        String   PeriodKey = String.valueOf(PCCperiod) + sbidtemp;
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = HistoricalVFinal_Period_map.get(PCCperiod);
                        newitem.SubBrandId = sbidtemp;
                        newitem.year = String.valueOf(PCCperiod.year());
                        newitem.TotalVolume = 0;
                        historical_sbDataROI_map.put(PeriodKey, newitem);

                    }
                }
            }

            Decimal TotalBlackCap_prorate=0;
            Decimal Total_IntakeBtl_prorate=0;
            Decimal TotalBC_prorate=0;

            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume: HistoricalSBVolumeList){

                HistoricalVFinalSBIdSet.add(SubBrandVolume.ASI_CRM_Subbrand__c);
                //Calculate Volume
                Decimal Volumes = getVolume(SubBrandVolume, '9L');
                Decimal VolumeBtl = getVolume(SubBrandVolume, 'std');
                TotalHC_IntakeBtl+=VolumeBtl;

                //Bottle Collection
                Decimal BottleCollection=0;
                BottleCollection += SubBrandVolume.ASI_CRM_Green_Cap_STD__c != null? SubBrandVolume.ASI_CRM_Green_Cap_STD__c:0;
                BottleCollection += SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c != null? SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c:0;
                //BottleCollection += SubBrandVolume.ASI_CRM_DeductibleCapWithIssues_Std_Btl__c != null? SubBrandVolume.ASI_CRM_DeductibleCapWithIssues_Std_Btl__c:0;
                TotalHC_BC += BottleCollection;

                //Black Cap ASI_CRM_DeductCapWithIssue_StdBill__c
                Decimal BlackCap=0;
                BlackCap+= SubBrandVolume.ASI_CRM_Cap_with_Issues_Std_Billing__c != null? SubBrandVolume.ASI_CRM_Cap_with_Issues_Std_Billing__c:0;   // BlackCap+= SubBrandVolume.ASI_CRM_Black_Cap_Std_Billing__c != null? SubBrandVolume.ASI_CRM_Black_Cap_Std_Billing__c:0;

                TotalBackCap+=BlackCap;   // BlackCap+= SubBrandVolume.ASI_CRM_Grey_Cap_Std_Billing__c != null? SubBrandVolume.ASI_CRM_Grey_Cap_Std_Billing__c:0;


                if( ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c) ){

                    TotalHistorical_MartellBC += BottleCollection;
                    TotalHistorical_MartellIntakeBtl+=VolumeBtl;
                    TotalHistorical_MartellBlackCap+=BlackCap;
                }




                Decimal VarHistTotal = VolumeBtl;
                Decimal VarHistTotalVolume=Volumes;
                Decimal VariableHistoricalBottles = VolumeBtl/PeriodA;

                if (PeriodA != 0 && PeriodA != null && PeriodB != 0 && PeriodB != null){
                    Volumes = Volumes/PeriodA * PeriodB;
                    VolumeBtl = VolumeBtl/PeriodA * PeriodB;
                    BottleCollection = BottleCollection/PeriodA * PeriodB;
                    BlackCap = BlackCap/PeriodA * PeriodB;
                }


                Total_IntakeBtl_prorate+=VolumeBtl;
                TotalBC_prorate+=BottleCollection;
                TotalBlackCap_prorate+=BlackCap;

                TotalHC_VolumeBtl += VolumeBtl;
                // Historical VFinal Contract Volume (in 9L cs) INTAKE (Historical Contract vFinal)
                HistoricalVFinalContract.Volumes += Volumes;
                //Sub-Brand Grade Grouping
                String SubbrandGroupName='0. Not Specified';
                String SubBrandName='';
                if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                    SubbrandGroupName=SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null?SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c:SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                }

                if(HistoricalVFinalContract.SubBrandGradeGrouping.containsKey(SubBrandName)){
                    Decimal TempVolumes=HistoricalVFinalContract.SubBrandGradeGrouping.get(SubBrandName)+Volumes;
                    //remove orignal one
                    HistoricalVFinalContract.SubBrandGradeGrouping.remove(SubBrandName);
                    HistoricalVFinalContract.SubBrandGradeGrouping.put(SubBrandName,TempVolumes);
                }else{
                    HistoricalVFinalContract.SubBrandGradeGrouping.put(SubBrandName,Volumes);
                }

                if(HistoricalVFinalContract.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                    Decimal TempVolumes=HistoricalVFinalContract.SubBrandGradeMap.get(SubbrandGroupName)+Volumes;
                    //remove orignal one
                    HistoricalVFinalContract.SubBrandGradeMap.remove(SubbrandGroupName);
                    HistoricalVFinalContract.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
                }else{
                    HistoricalVFinalContract.SubBrandGradeMap.put(SubbrandGroupName,Volumes);
                }

                //By Brande Product Category Grouping
                if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c !=null && SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                    String CategoryName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    if(HistoricalVFinalContract.CategoryMap.containsKey(CategoryName)){
                        Decimal TempVolumes=HistoricalVFinalContract.CategoryMap.get(CategoryName)+Volumes;
                        //remove orignal one
                        HistoricalVFinalContract.CategoryMap.remove(CategoryName);
                        HistoricalVFinalContract.CategoryMap.put(CategoryName,TempVolumes);
                    }else{
                        HistoricalVFinalContract.CategoryMap.put(CategoryName,Volumes);
                    }
                }// end of By Brande Product Category Grouping


                Date SubbrandVolumeDateKey = FYConversion(SubBrandVolume.ASI_CRM_End_Date__c);
                String SubbrandVolumeStrKey = String.valueOf(SubbrandVolumeDateKey) + SubBrandVolume.ASI_CRM_Subbrand__c;

                if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(SubbrandVolumeStrKey)){
                    historical_sbDataROI_map.get(SubbrandVolumeStrKey).TotalVolume += VarHistTotalVolume;
                }

                String SuBBrandKey =SBGradeSorting(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + SubBrandVolume.ASI_CRM_Subbrand__r.Name;

                if(HistoricalVFinalContract.ContractLineMap.containsKey(SuBBrandKey)){
                    HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalBottles =(HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalBottles + VariableHistoricalBottles).setScale(4) ;
                    HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalTotalFees +=  HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalFees * VarHistTotal;
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.HistoricalBottles = VariableHistoricalBottles.setScale(4);
                    //ContractDetail.HistoricalTotalFees=0;
                    ContractDetail.SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.Name;
                    ContractDetail.SubBrandGrade= SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    HistoricalVFinalContract.ContractLineMap.put(SuBBrandKey,ContractDetail);
                }

                Decimal VolumesCR12 = 0;
                VolumesCR12 += SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c:0;
                VolumesCR12 += SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c:0;
                VolumesCR12 += SubBrandVolume.ASI_CRM_PR_Direct_CR12__c!=null? SubBrandVolume.ASI_CRM_PR_Direct_CR12__c:0;
                HistoricalVFinalContract.IntakeCR12 += VolumesCR12;

            }//end of Sub Brand Volume for looping



            AdditionalFIMap.put('TotalBlackCap_prorate',TotalBlackCap_prorate);
            AdditionalFIMap.put('Total_IntakeBtl_prorate',Total_IntakeBtl_prorate);
            AdditionalFIMap.put('TotalBC_prorate',TotalBC_prorate);


            //Prorate Investment CR12 for Historical Contract
            if (PeriodA != 0 && PeriodB!= 0 && PeriodA != null && PeriodB!= null){
                HistoricalVFinalContract.IntakeCR12 = HistoricalVFinalContract.IntakeCR12/PeriodA * PeriodB;
            }



            //YTD CM/GS
            Map<String, Decimal> Latest_ActualCM = new Map<String, Decimal>();
            Map<String, Decimal> Latest_ActualGS = new Map<String, Decimal>();
            Map<String, Decimal> ProForma_LatestBudgetCM = new Map<String, Decimal>();
            Date HistoricalVFinalStartDate = PreviousCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);


            for (ASI_CRM_CM_GS__c line : [SELECT Id,
                ASI_CRM_CM_GS_per_9L__c,
                ASI_CRM_CN_Month_End_Date__c,
                ASI_CRM_PRODUCTCODE__c,
                ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_PRODUCTCODE__r.Name,
                ASI_CRM_Region__c,
                ASI_CRM_TYPE__c
            FROM ASI_CRM_CM_GS__c
            WHERE ASI_CRM_PRODUCTCODE__c IN :HistoricalVFinalSBIdSet
            AND ASI_CRM_Region__c = :PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            AND ASI_CRM_CN_Month_End_Date__c >= :HistoricalVFinalStartDate
            AND ASI_CRM_CN_Month_End_Date__c <= :TillEnd
            AND (ASI_CRM_TYPE__c = 'YTD CM'
            OR ASI_CRM_TYPE__c = 'YTD GS')
            AND ASI_CRM_CM_GS_per_9L__c != NULL
            AND ASI_CRM_CM_GS_per_9L__c != 0
            AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS') 
            ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
            {

                String strkey = String.valueOf(line.ASI_CRM_CN_Month_End_Date__c) + line.ASI_CRM_PRODUCTCODE__c;
                if (line.ASI_CRM_TYPE__c == 'YTD CM'){

                    if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(strkey)){
                        if (historical_sbDataROI_map.get(strkey).CM == null || historical_sbDataROI_map.get(strkey).CM == 0){
                            historical_sbDataROI_map.get(strkey).CM = line.ASI_CRM_CM_GS_per_9L__c;

                            historical_sbDataROI_map.get(strkey).SubBrandId = line.ASI_CRM_PRODUCTCODE__c;
                        }
                    }
                    if (!Latest_ActualCM.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                        Latest_ActualCM.put(line.ASI_CRM_PRODUCTCODE__c, line.ASI_CRM_CM_GS_per_9L__c);
                    }

                    if(!ProForma_LatestBudgetCM.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                        if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                            ProForma_LatestBudgetCM.put(line.ASI_CRM_PRODUCTCODE__c,RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c));
                        }
                    }
                }

                if (line.ASI_CRM_TYPE__c == 'YTD GS'){
                    if (!Latest_ActualGS.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                        Latest_ActualGS.put(line.ASI_CRM_PRODUCTCODE__c, line.ASI_CRM_CM_GS_per_9L__c);
                    }
                    if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(strkey)){
                        if (historical_sbDataROI_map.get(strkey).GS == null || historical_sbDataROI_map.get(strkey).GS == 0){
                            historical_sbDataROI_map.get(strkey).GS =  line.ASI_CRM_CM_GS_per_9L__c;
                            historical_sbDataROI_map.get(strkey).SubBrandId = line.ASI_CRM_PRODUCTCODE__c;
                        }
                    }
                }

                if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(strkey)){
                    if (historical_sbDataROI_map.get(strkey).latestBudgetCM == null || historical_sbDataROI_map.get(strkey).latestBudgetCM == 0){
                        if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                            historical_sbDataROI_map.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c);
                        }
                    }
                    historical_sbDataROI_map.get(strkey).SubBrandId = line.ASI_CRM_PRODUCTCODE__c;
                }

                if(!ProForma_LatestBudgetCM.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                    if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                        ProForma_LatestBudgetCM.put(line.ASI_CRM_PRODUCTCODE__c,RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c));
                    }
                }


            } // end of CM /GS Looping



            Decimal CMTotalVFinal=0;
            Decimal LatestBudgetCMTotalVFinal = 0;

            //ROI Calculations for Historical
            //            if (historical_sbDataROI_map != null && historical_sbDataROI_map.size() > 0){
            //                Decimal ActualCM;
            //                Decimal LatestBudgetCM;
            //                Decimal LatestBudgetCM_prorate;
            //                Decimal ActualGS;
            //                Decimal TotalActualVol;
            //                Decimal PeriodStr;
            //                Decimal ActualCM_prorate;
            //                Decimal ActualGS_prorate;
            //                Date historicalVFinalTillEnd;
            //
            //                if (PreviousCC.ASI_CRM_CN_PO_End_Date__c != null && CutOffDay >= PreviousCC.ASI_CRM_CN_PO_End_Date__c)
            //                    historicalVFinalTillEnd = getEndDate(PreviousCC.ASI_CRM_CN_PO_End_Date__c);
            //                else
            //                    historicalVFinalTillEnd = CutOffDay;
            //
            //                Integer PeriodA_prorate = MonthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, historicalVFinalTillEnd);
            //                Integer PeriodB_prorate = MonthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, PreviousCC.ASI_CRM_CN_PO_End_Date__c);
            //                Integer PeriodD_prorate = PeriodB_prorate - PeriodA_prorate;
            //
            //
            //                for (String key : historical_sbDataROI_map.keySet()){
            //                    ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.containsKey(historical_sbDataROI_map.get(key).SubBrandId) ? CMGSBySubBrand.get(historical_sbDataROI_map.get(key).SubBrandId) : new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();
            //
            //                    PeriodStr= null;
            //                    if (historical_sbDataROI_map.get(key).period != null){
            //                        PeriodStr = historical_sbDataROI_map.get(key).period;
            //                    }
            //                    //Actual CM
            //                    ActualCM = null;
            //                    if (historical_sbDataROI_map.get(key).CM != null && historical_sbDataROI_map.get(key).CM != 0){
            //                        ActualCM = historical_sbDataROI_map.get(key).CM;
            //                    }else{
            //                        if (Latest_ActualCM != null && Latest_ActualCM.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
            //                            ActualCM = Latest_ActualCM.get(historical_sbDataROI_map.get(key).SubBrandId);
            //                        }
            //                    }
            //
            //                    //Latest Budget CM
            //                    LatestBudgetCM = null;
            //                    if (historical_sbDataROI_map.get(key).latestBudgetCM != null){
            //                        LatestBudgetCM = historical_sbDataROI_map.get(key).latestBudgetCM;
            //                    }else{
            //                        if (ProForma_LatestBudgetCM != null && ProForma_LatestBudgetCM.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
            //                            LatestBudgetCM = ProForma_LatestBudgetCM.get(historical_sbDataROI_map.get(key).SubBrandId);
            //                        }
            //                    }
            //                    //Actual GS
            //                    ActualGS = null;
            //                    if (historical_sbDataROI_map.get(key).GS != null && historical_sbDataROI_map.get(key).GS != 0){
            //                        ActualGS = historical_sbDataROI_map.get(key).GS;
            //                    }else{
            //                        if (Latest_ActualGS != null && Latest_ActualGS.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
            //                            ActualGS = Latest_ActualGS.get(historical_sbDataROI_map.get(key).SubBrandId);
            //                        }
            //                    }
            //                    //Total Volume
            //                    TotalActualVol = null;
            //                    if (historical_sbDataROI_map.get(key).TotalVolume != null){
            //                        TotalActualVol = historical_sbDataROI_map.get(key).TotalVolume;
            //                    }
            //                    if (TotalActualVol != null && ActualCM != null ){
            //                        CMTotalVFinal += ActualCM * TotalActualVol;
            //                        CMGSData.CM += ActualCM * TotalActualVol;
            //
            //                    }
            //
            //                    if (TotalActualVol != null && LatestBudgetCM != null ){
            //                        LatestBudgetCMTotalVFinal += LatestBudgetCM * TotalActualVol;
            //                        CMGSData.latestBudgetCM += LatestBudgetCM * TotalActualVol;
            //                    }
            //
            //                    ActualCM_prorate = 0;
            //                    if (Latest_ActualCM != null && Latest_ActualCM.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
            //                        ActualCM_prorate = Latest_ActualCM.get(historical_sbDataROI_map.get(key).SubBrandId);
            //                    }
            //
            //                    LatestBudgetCM_prorate = 0;
            //                    if (ProForma_LatestBudgetCM != null && ProForma_LatestBudgetCM.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
            //                        LatestBudgetCM_prorate = ProForma_LatestBudgetCM.get(historical_sbDataROI_map.get(key).SubBrandId);
            //                    }
            //
            //                    if (PeriodA_prorate != null && PeriodA_prorate != 0 && TotalActualVol != null && TotalActualVol != 0 && PeriodD_prorate != null && ActualCM_prorate != null){
            //                        CMTotalVFinal += ActualCM_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;
            //                        CMGSData.CM += ActualCM_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;
            //                    }
            //
            //                    if (PeriodA_prorate != null && PeriodA_prorate != 0 && TotalActualVol != null && TotalActualVol != 0 && PeriodD_prorate != null && LatestBudgetCM_prorate != null){
            //                        LatestBudgetCMTotalVFinal += LatestBudgetCM_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;
            //                        CMGSData.latestBudgetCM += LatestBudgetCM_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;
            //                    }
            //
            //                    if (TotalActualVol != null && ActualGS != null){
            //                        HistoricalVFinalContract.GrossSalesTotal += ActualGS * TotalActualVol;
            //                        CMGSData.GS += ActualGS * TotalActualVol;
            //                    }
            //                    ActualGS_prorate = 0;
            //                    if (Latest_ActualGS != null && Latest_ActualGS.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
            //                        ActualGS_prorate = Latest_ActualGS.get(historical_sbDataROI_map.get(key).SubBrandId);
            //                    }
            //                    if (PeriodA_prorate != null && PeriodA_prorate != 0 && TotalActualVol != null && TotalActualVol != 0 && PeriodD_prorate != null && ActualGS_prorate != null){
            //                        HistoricalVFinalContract.GrossSalesTotal  += ActualGS_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;
            //                        CMGSData.GS  += ActualGS_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;
            //                    }
            //                    CMGSBySubBrand.put(historical_sbDataROI_map.get(key).SubBrandId, CMGSData);
            //                } // end of looping historical_sbDataROI_map
            //
            //            }
            //Historical V Final Calculation
            if(historical_sbDataROI_map != null && historical_sbDataROI_map.size() > 0){
                Integer startToCutoffMonth = MonthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
                Integer cutoffToEndMonth = MonthDiff(CutOffDay.addDays(+1), PreviousCC.ASI_CRM_CN_PO_End_Date__c);
                if (cutoffToEndMonth < 0) cutoffToEndMonth = 0;
                Decimal Average9L = 0;
                System.debug(startToCutoffMonth);
                System.debug(cutoffToEndMonth);
                /*
                What is the difference between actualVolume and projectedVolume?
                actualVolume: The volume from contract start to current. It should be taken from data.
                projectedVolume: The estimate volume when the whole contract end.
                     The estimation comes from actualVolume, by calculating the monthly volume then multiples the whole contract period.
                */
                for (String v1roitemp : historical_sbDataROI_map.keySet()){
                    String subBrandId = historical_sbDataROI_map.get(v1roitemp).SubBrandId;
                    Decimal actualVolume = denullify(historical_sbDataROI_map.get(v1roitemp).TotalVolume);
                    ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.containsKey(subBrandId) ? CMGSBySubBrand.get(subBrandId) : new ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data();


                    //**********Actual CM *********
                    /*
                    Total Contribution Margin = YTD Contribution Margin * CTD Volume + YTD Contribution Margin * Project Volume
                    */
                    Decimal actualcm =0;
                    Decimal prorate_actualcm = 0;
                    Average9L = actualVolume / startToCutoffMonth;

                    if (historical_sbDataROI_map.get(v1roitemp).CM != null && historical_sbDataROI_map.get(v1roitemp).CM != 0){
                        actualcm = historical_sbDataROI_map.get(v1roitemp).CM;
                    }else if (Latest_ActualCM.containsKey(subBrandId)){
                        actualcm = Latest_ActualCM.get(subBrandId);
                    }

                    if (actualcm != null){
                        CMTotalVFinal += actualVolume * actualcm;
                        CMGSData.CM += actualVolume * actualcm;

                        if (Latest_ActualCM.containsKey(subBrandId))
                            prorate_actualcm = Latest_ActualCM.get(subBrandId);

                        if (Average9L != null && cutoffToEndMonth != null && prorate_actualcm != null){
                            CMTotalVFinal += Average9L * cutoffToEndMonth * prorate_actualcm;
                            CMGSData.CM += Average9L * cutoffToEndMonth * prorate_actualcm;
                        }

                    }

                    //*********Latest Budget CM*********
                    /*
                    Total Budget Contribution Margin = YTD Contribution Margin * CTD Volume  + YTD Contribution Margin * Project Volume
                    */
                    Decimal lbcm = 0;
                    Decimal prorate_lbcm = 0;
                    if (historical_sbDataROI_map.get(v1roitemp).latestBudgetCM != null && historical_sbDataROI_map.get(v1roitemp).latestBudgetCM != 0)
                        lbcm = historical_sbDataROI_map.get(v1roitemp).latestBudgetCM;
                    else if (ProForma_LatestBudgetCM.containsKey(subBrandId))
                        lbcm = ProForma_LatestBudgetCM.get(subBrandId);
                    if (lbcm != null){
                        LatestBudgetCMTotalVFinal += actualVolume * lbcm;
                        CMGSData.latestBudgetCM += actualVolume * lbcm;

                        if (ProForma_LatestBudgetCM.containsKey(subBrandId))
                            prorate_lbcm = ProForma_LatestBudgetCM.get(subBrandId);

                        if (Average9L != null && cutoffToEndMonth != null && prorate_lbcm != null) {
                            LatestBudgetCMTotalVFinal += Average9L * cutoffToEndMonth * prorate_lbcm;
                            CMGSData.latestBudgetCM += Average9L * cutoffToEndMonth * prorate_lbcm;
                        }
                    }

                    //**********Actual GS*********
                    /*
                    Total Gross Sales = YTD Gross Sales * CTD Volume + YTD Gross Sales * Project Volume
                    */

                    Decimal ActualGS = 0;
                    if (historical_sbDataROI_map.get(v1roitemp).GS != null && historical_sbDataROI_map.get(v1roitemp).GS != 0) {
                        ActualGS = historical_sbDataROI_map.get(v1roitemp).GS;
                    } else if (Latest_ActualGS.containsKey(subBrandId)) {
                        ActualGS = Latest_ActualGS.get(subBrandId);
                    }

                    if (ActualGS != null){
                        HistoricalVFinalContract.GrossSalesTotal += ActualGS * actualVolume;
                        CMGSData.GS += ActualGS * actualVolume;
                    }

                    Decimal ActualGS_prorate = 0;
                    if (Latest_ActualGS.containsKey(subBrandId)){
                        ActualGS_prorate = Latest_ActualGS.get(subBrandId);
                    }

                    if(ActualGS_prorate!=null && actualVolume !=null && startToCutoffMonth !=null && startToCutoffMonth !=0 && cutoffToEndMonth !=null){
                        HistoricalVFinalContract.GrossSalesTotal  += ActualGS_prorate * Average9L* cutoffToEndMonth;
                        CMGSData.GS  += ActualGS_prorate * Average9L* cutoffToEndMonth;
                    }

                    CMGSBySubBrand.put(subBrandId, CMGSData);
                }
            }
            //%Gross Sales Historical
            if (HistoricalVFinalContract.GrossSalesTotal != null && HistoricalVFinalContract.GrossSalesTotal != 0 && HistoricalVFinalContract.TradeExpenses != 0 && HistoricalVFinalContract.TradeExpenses!= null){
                HistoricalVFinalContract.GrossSalesRate = (HistoricalVFinalContract.TradeExpenses/ HistoricalVFinalContract.GrossSalesTotal) *100;
            }

            //Fixed Expense Rate
            if (HistoricalVFinalContract.FixedExpense != 0 &&  HistoricalVFinalContract.TradeExpenses!= 0 && HistoricalVFinalContract.FixedExpense != null &&  HistoricalVFinalContract.TradeExpenses != null){
                HistoricalVFinalContract.FixedExpenseRate = HistoricalVFinalContract.FixedExpense/ HistoricalVFinalContract.TradeExpenses * 100;
            }
            //Historical Contract Margin after A&P
            if (CMTotalVFinal != null && HistoricalVFinalContract.TradeExpenses != null){
                HistoricalVFinalContract.MarginAfterAnP = CMTotalVFinal - HistoricalVFinalContract.TradeExpenses;
            }

            if (TotalHC_VolumeBtl != 0 && TotalHC_VolumeBtl!= null && HistoricalVFinalContract.MarginAfterAnP != 0 && HistoricalVFinalContract.MarginAfterAnP != null){
                HistoricalVFinalContract.MarginPerBottle = HistoricalVFinalContract.MarginAfterAnP / TotalHC_VolumeBtl;
                HistoricalVFinalContract.IntakeSTD=TotalHC_VolumeBtl;
            }


            if(HistoricalVFinalContract.IntakeCR12!=null && HistoricalVFinalContract.IntakeCR12 !=0 && HistoricalVFinalContract.TradeExpenses!=null){
                HistoricalVFinalContract.InvestmentCR12 =HistoricalVFinalContract.TradeExpenses/HistoricalVFinalContract.IntakeCR12;
            }

            if (CMTotalVFinal != null && CMTotalVFinal != 0 && HistoricalVFinalContract.TradeExpenses != 0 && HistoricalVFinalContract.TradeExpenses!= null){
                HistoricalVFinalContract.CMTotal=CMTotalVFinal;
                HistoricalVFinalContract.ROIIntake = CMTotalVFinal / HistoricalVFinalContract.TradeExpenses;
            }
            //ProForma_ROI Historical
            if (LatestBudgetCMTotalVFinal != null && LatestBudgetCMTotalVFinal != 0 &&   HistoricalVFinalContract.TradeExpenses!= 0 &&  HistoricalVFinalContract.TradeExpenses!= null){
                HistoricalVFinalContract.LatestBudgetCMTotal=LatestBudgetCMTotalVFinal;
                HistoricalVFinalContract.ROIProForma = LatestBudgetCMTotalVFinal / HistoricalVFinalContract.TradeExpenses;
            }

            if(TotalHC_BC!=0 && TotalHC_BC !=null && TotalHC_IntakeBtl !=null && TotalHC_IntakeBtl!=0){
                HistoricalVFinalContract.TotalBCRate=(TotalHC_BC/TotalHC_IntakeBtl)*100;
                HistoricalVFinalContract.NetBCRate=((TotalHC_BC-TotalBackCap)/TotalHC_IntakeBtl)*100;
            }

            if(TotalHistorical_MartellBC!=0 && TotalHistorical_MartellBC !=null && TotalHistorical_MartellIntakeBtl !=null && TotalHistorical_MartellIntakeBtl!=0){
                HistoricalVFinalContract.TotalMBCRate=(TotalHistorical_MartellBC/TotalHistorical_MartellIntakeBtl)*100;
                HistoricalVFinalContract.NetMBCRate=((TotalHistorical_MartellBC-TotalHistorical_MartellBlackCap)/TotalHistorical_MartellIntakeBtl)*100;
            }


            AdditionalFIMap.put('TotalHistorical_MartellBC',TotalHistorical_MartellBC);
            AdditionalFIMap.put('TotalHistorical_MartellIntakeBtl',TotalHistorical_MartellIntakeBtl);
            AdditionalFIMap.put('TotalHistorical_MartellBlackCap',TotalHistorical_MartellBlackCap);


            AdditionalFIMap.put('TotalHC_BC',TotalHC_BC);
            AdditionalFIMap.put('TotalBackCap',TotalBackCap);
            AdditionalFIMap.put('TotalHC_IntakeBtl',TotalHC_IntakeBtl);
        }

        HistoricalVFinalContract.AddOnString = System.JSON.serialize(AdditionalFIMap);

        // Because user wants to have TradeExpenseBySubBrand only if previous is HCO
        if (PreviousCC.Id != null && PreviousCC.ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On') {
            ASI_TH_CRM_Contract__c previousV0Contract = getContract(HistoricalV00Contract.ContractId);
            ASI_TH_CRM_Contract__c previousVFinalContract = getContract(PreviousCC.Id);
            HistoricalV00Contract.TradeExpenseBySubBrand = constructTradeExpenseBySubBrand(previousV0Contract, 'estimate', 'PO Open');
            HistoricalVFinalContract.TradeExpenseBySubBrand = constructTradeExpenseBySubBrand(previousVFinalContract, 'estimate', 'PO Modi');

            HistoricalV00Contract.TradeExpenseBySubBrand = updateCMGSInTradeExpenseBySubBrand(HistoricalV00Contract, HistoricalV00Contract.TradeExpenseBySubBrand, historicalV0_sbDataROI_map);
            for (TradeExpenseBreakdown tradeExpenseBreakdown : HistoricalVFinalContract.TradeExpenseBySubBrand) {
                if (!CMGSBySubBrand.containsKey(tradeExpenseBreakdown.subBrandId)) {
                    continue;
                }
                ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data CMGSData = CMGSBySubBrand.get(tradeExpenseBreakdown.subBrandId);

                tradeExpenseBreakdown.GSTotal = CMGSData.GS.setScale(4);
                tradeExpenseBreakdown.CMTotal = CMGSData.CM.setScale(4);
                tradeExpenseBreakdown.latestBudgetCMTotal = CMGSData.latestBudgetCM.setScale(4);
            }

            HistoricalV00Contract = calculateFIExcludeSelectedSubBrands(HistoricalV00Contract);
            HistoricalVFinalContract = calculateFIExcludeSelectedSubBrands(HistoricalVFinalContract);
        }


        List<FinancialIndicator> FinancialIndicatorList = new List<FinancialIndicator>();
        FinancialIndicatorList.add(HistoricalV00Contract);
        FinancialIndicatorList.add(HistoricalVFinalContract);

        UpsertAttachment(thisCC.Id, System.JSON.serialize(FinancialIndicatorList),'Historical Data' );

    } // end of RestructureHistoricalData

    public static void RestructureHistoricalFinancialIndicatorData2nd(ASI_TH_CRM_Contract__c contract){
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);
        
        //Define variable
        ASI_TH_CRM_Contract__c PreviousCC = new ASI_TH_CRM_Contract__c();
        ASI_TH_CRM_Contract__c PreviousV00CC = new ASI_TH_CRM_Contract__c();
        FinancialIndicator2nd HistoricalV00Contract = new FinancialIndicator2nd();
        FinancialIndicator2nd HistoricalVFinalContract = new FinancialIndicator2nd();
        Date startDate;
        Date endDate;
        if (thisCC.ASI_CRM_CN_PO_Start_Date__c != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null && thisCC.ASI_TH_CRM_Promotion_Type__c != null){
            //Criteria within 6 Months (from PO start date)
            Integer strDays = 365/12*6;
            Date strDate = thisCC.ASI_CRM_CN_PO_Start_Date__c - strDays;
            //Retrieve Historical v0.0 contract

            try {
                PreviousCC = [
                    SELECT
                        Id,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c,
                        ASI_CRM_Martell_BC_Rate__c,
                        ASI_CRM_CN_Expected_PSF_Est_Total__c,
                        ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                        ASI_CRM_EVC_Cost_Estimate_Total__c,
                        ASI_TH_CRM_Promotion_Type__c,
                        ASI_CRM_CN_PO_Version__c,
                        ASI_CRM_CN_Total_Contract_Amount__c,
                        ASI_CRM_Volume_Option__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                        ASI_CRM_CN_Outlet_WS__c,
                        ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                        ASI_CRM_CN_BRSF_Contract_Total__c,
                        ASI_CRM_CN_Contract_Cost_Total__c,
                        ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                        ASI_CRM_CN_Contract_Variable_Cost_Total__c,
                        ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__c,
                        Owner.Name,
                        ASI_CRM_CN_V0_0_PO_version__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                        ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                        ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                        ASI_CRM_CN_Bottle_Collection_Rate__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                        ASI_CRM_New_FY_PO__c,
                        ASI_CRM_CN_Status__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_CN_PO_No__c
                    FROM ASI_TH_CRM_Contract__c
                    WHERE ASI_CRM_CN_Outlet_WS__c = :thisCC.ASI_CRM_CN_Outlet_WS__c AND ASI_CRM_CN_PO_End_Date__c != NULL AND
                    ASI_CRM_CN_PO_Start_Date__c != NULL
                    AND ASI_CRM_CN_PO_End_Date__c <= :thisCC.ASI_CRM_CN_PO_Start_Date__c AND ASI_CRM_CN_PO_End_Date__c >= :strDate 
                    AND ASI_TH_CRM_Promotion_Type__c = 'Heavy Contract ON' AND ASI_CRM_CN_Is_2nd_KPI_PO__c = true
                    AND (ASI_CRM_CN_Status__c = 'Final' OR ASI_CRM_CN_Status__c = 'Archived' OR ASI_CRM_CN_Status__c = 'Submitted')
                    ORDER BY ASI_CRM_CN_Status__c DESC, ASI_CRM_CN_PO_End_Date__c DESC, Name DESC, ASI_CRM_CN_PO_Version__c DESC
                    LIMIT 1
                ];
            } catch (Exception e) {
                PreviousCC = new ASI_TH_CRM_Contract__c();
            }

            if (PreviousCC != null && PreviousCC.ASI_CRM_CN_Status__c == 'Archived') {
                String v0Id = PreviousCC.ASI_CRM_CN_V0_0_PO_version__c == null? PreviousCC.Id : PreviousCC.ASI_CRM_CN_V0_0_PO_version__c;
                List<ASI_TH_CRM_Contract__c> CheckLatestContract = new List<ASI_TH_CRM_Contract__c>([
                    SELECT
                        Id,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c,
                        ASI_CRM_Martell_BC_Rate__c,
                        ASI_CRM_CN_Expected_PSF_Est_Total__c,
                        ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                        ASI_CRM_EVC_Cost_Estimate_Total__c,
                        ASI_CRM_CN_PO_Version__c,
                        ASI_TH_CRM_Promotion_Type__c,
                        ASI_CRM_CN_Total_Contract_Amount__c,
                        ASI_CRM_Volume_Option__c,
                        ASI_CRM_CN_Outlet_WS__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                        ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                        ASI_CRM_CN_BRSF_Contract_Total__c,
                        ASI_CRM_CN_Contract_Cost_Total__c,
                        ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                        ASI_CRM_CN_Contract_Variable_Cost_Total__c,
                        ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__c,
                        Owner.Name,
                        ASI_CRM_CN_V0_0_PO_version__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                        ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                        ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                        ASI_CRM_CN_Bottle_Collection_Rate__c,
                        ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                        ASI_CRM_New_FY_PO__c,
                        ASI_CRM_CN_Status__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_CN_PO_No__c
                    FROM ASI_TH_CRM_Contract__c
                    WHERE ASI_CRM_CN_V0_0_PO_version__c = :v0Id
                    AND ASI_CRM_CN_Status__c != 'Draft' AND (NOT ASI_CRM_CN_Status__c LIKE 'FY Landing Archive')
                    AND ASI_CRM_CN_PO_End_Date__c != NULL AND ASI_CRM_CN_PO_Start_Date__c != NULL
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ]);

                if(CheckLatestContract.size()>0){
                    if(CheckLatestContract[0].ASI_CRM_CN_PO_End_Date__c <= thisCC.ASI_CRM_CN_PO_Start_Date__c && CheckLatestContract[0].ASI_CRM_CN_PO_End_Date__c >= strDate){
                        PreviousCC = CheckLatestContract[0];
                    }else{
                        PreviousCC = new ASI_TH_CRM_Contract__c();
                    }
                }
            }
            //End of finding Historical v0.0 contract
        }

        if (PreviousCC.Id != null)
        {

            if (PreviousCC.ASI_CRM_CN_V0_0_PO_version__c != null) {
                PreviousV00CC.Id = PreviousCC.ASI_CRM_CN_V0_0_PO_version__c;
                HistoricalV00Contract = RestructureCurrentFinancialIndicatorDataList2nd(PreviousV00CC).get(0);
                if (PreviousCC.ASI_CRM_Auto_PO_Modification__c) {
                    List<ASI_TH_CRM_PaymentRequest__c> LastPaymentRequest = [SELECT Id,Name,ASI_CRM_CN_Total_VEC_Amount__c,
                             ASI_CRM_Total_Variable_Amount__c,ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c,
                             ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,
                             ASI_CRM_CN_OutletWS__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                             ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c
                                 FROM ASI_TH_CRM_PaymentRequest__c
                                 WHERE 
                                 ASI_CRM_CN_PO_No__c = :PreviousCC.ASI_CRM_CN_PO_No__c
                                AND ASI_CRM_CN_Last_Payment__c = TRUE
                                Order By CreatedDate desc];
                    if (LastPaymentRequest.isEmpty()) {
                        HistoricalVFinalContract =  ReconstructCurrentPOModiFIDataList2nd(PreviousCC).get(0);
                    }
                    else {
                        HistoricalVFinalContract = ASI_CRM_CN_HeavyPaymentUtilitiesClass.ReconstructLastPaymentFIDataList2nd(LastPaymentRequest.get(0)).get(0);
                    }
                    
                }
                else {
                    HistoricalVFinalContract =  ReconstructCurrentPOModiFIDataList2nd(PreviousCC).get(0);
                }
            }
            else {
                HistoricalV00Contract = RestructureCurrentFinancialIndicatorDataList2nd(PreviousCC).get(0);
            }
        }

        List<FinancialIndicator2nd> FinancialIndicatorList = new List<FinancialIndicator2nd>();
        FinancialIndicatorList.add(HistoricalV00Contract);
        FinancialIndicatorList.add(HistoricalVFinalContract);

        UpsertAttachment2nd(contract.Id, System.JSON.serialize(FinancialIndicatorList),'Historical Data' );

    } // end of RestructureHistoricalData





    //Restructure Current v0 and VFinal Data
    public static void RestructureCurrentFIData(ASI_TH_CRM_Contract__c contract){
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);
        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal> ();
        //Define variable

        FinancialIndicator HistoricalV00Contract = new FinancialIndicator();
        FinancialIndicator HistoricalVFinalContract = new FinancialIndicator();
        Date startDate;
        Date endDate;
        String strRegion='',CommercialTeam='';
        Set<Id> HistoricalAllOutlet = new Set<Id>();
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        //key: date+SubBrand    for historical v0.0
        Map <String, subbrand_data> historicalV0_sbDataROI_map =new Map <String, subbrand_data>();

        //Calculate RegionSubBrandCM_Map
        String currentFY = String.valueOf(FYConversion(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';

        //Finding Old Promotion Types
        Set<String> oldPromotionTypes = new Set<String>();
        if(thisCC.ASI_CRM_New_FY_PO__c){
            for(ASI_CRM_Special_Promotion_Type_Mapping__c obj:[SELECT Id,ASI_CRM_Mapping_of_New_Promotion_Type__c , ASI_CRM_Mapping_of_Old_Promotion_Type__c , ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c , ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c FROM ASI_CRM_Special_Promotion_Type_Mapping__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Special_Promotion_Type_Mapping' AND ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c = : thisCC.ASI_TH_CRM_Promotion_Type__c ]){
                oldPromotionTypes.add(obj.ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c);
            }
        }


        //Assign/Calculate data
        if(thisCC.Id != null){
            String HistoricalV00ContractId = null;
            Date StartDateExtend;
            Date EndDateExtend;
            Set<Id> V00SubBrandIdSet = new Set<Id> ();
            HistoricalAllOutlet.add(thisCC.ASI_CRM_CN_Outlet_WS__c);
            //Getting Historical Outlet Id  for vFinal
            if(thisCC.ASI_CRM_Volume_Option__c == 'Wholesaler Only' ){
                HistoricalAllOutlet.add(thisCC.ASI_CRM_CN_Outlet_WS__c);
            }else{
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id]){
                    HistoricalAllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
            HistoricalVFinalContract.OutletSet=HistoricalAllOutlet;

            //Contract level Handling
            if(thisCC != null && thisCC.Id != null && thisCC.ASI_CRM_CN_V0_0_PO_version__c == null){
                HistoricalV00Contract.ContractId = thisCC.Id;
                HistoricalV00ContractId = thisCC.Id;

                HistoricalV00Contract.BCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c!= null?thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c:0;
                HistoricalV00Contract.TotalBCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c!= null?thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c:0;
                HistoricalV00Contract.TotalMBCRate = thisCC.ASI_CRM_Martell_BC_Rate__c!= null?thisCC.ASI_CRM_Martell_BC_Rate__c:0;

                HistoricalV00Contract.POStartDate =thisCC.ASI_CRM_CN_PO_Start_Date__c!=null?thisCC.ASI_CRM_CN_PO_Start_Date__c:null;
                HistoricalV00Contract.POEndDate =thisCC.ASI_CRM_CN_PO_End_Date__c!=null?thisCC.ASI_CRM_CN_PO_End_Date__c:null;

                startDate = thisCC.ASI_CRM_CN_PO_Start_Date__c!=null?thisCC.ASI_CRM_CN_PO_Start_Date__c:null;
                endDate = thisCC.ASI_CRM_CN_PO_End_Date__c!= null?thisCC.ASI_CRM_CN_PO_End_Date__c : null;
                StartDateExtend= thisCC.ASI_CRM_CN_PO_Start_Date__c!=null? getEndDate(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1)) :null;
                EndDateExtend = thisCC.ASI_CRM_CN_PO_End_Date__c!=null? getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1)):null;
                strRegion= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
                CommercialTeam= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';

                //Current Contract is V0.0
                if(thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                    HistoricalV00Contract.TradeExpenses = thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
                if(thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
                    HistoricalV00Contract.FixedExpense = thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
                if(thisCC.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_No_of_Months__c != null)
                    HistoricalV00Contract.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);


            }else if(thisCC != null && thisCC.ASI_CRM_CN_V0_0_PO_version__c != null){
                HistoricalV00Contract.ContractId = thisCC.ASI_CRM_CN_V0_0_PO_version__r.Id;
                HistoricalV00ContractId = thisCC.ASI_CRM_CN_V0_0_PO_version__c;

                HistoricalV00Contract.BCRate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c!=null?HistoricalV00Contract.BCRate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c:0;
                HistoricalV00Contract.TotalBCRate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c!=null?HistoricalV00Contract.BCRate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c:0;
                HistoricalV00Contract.TotalMBCRate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c!=null?thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c:0;


                HistoricalV00Contract.POStartDate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null?thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c:null;
                HistoricalV00Contract.POEndDate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null?thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c:null;

                startDate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null?thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c:null;
                endDate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null?thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c:null;
                StartDateExtend= thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null? getEndDate(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c.addYears(-1)) :null;
                EndDateExtend = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null? getEndDate(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c.addYears(+1)):null;

                strRegion = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c !=null? thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c: '';
                CommercialTeam= thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';


                //Current Contract is VFinal
                if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                    HistoricalV00Contract.TradeExpenses = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
                if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
                    HistoricalV00Contract.FixedExpense = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
                if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != null)
                    HistoricalV00Contract.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c);
            } else{
                HistoricalV00ContractId = null;
            }

            //Historical v0.0 BRSF Line only for By Sub-Brand
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PreviousV0CC_BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();


            if(HistoricalV00ContractId != null){
                Map<Date, Decimal> PreviousV0CC_Period_map = checkFYDayPeriod(startDate, endDate);
                //CMTotalV0 :  Cont. Margin before A&P
                Decimal CMTotalV0=0;
                Decimal LatestBudgetCMTotalV0 = 0;
                Decimal BRSFEstimateVolumesTotalV0 = 0; // Calculate BRSF Estimate Volumes Total for V0.0 contract


                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();

                //<Sub-Brand Id, Estimate Volume Amount> : the Estimate Volume for each Sub-Brand Mapping
                Map<String, Decimal> EstimateVolumeV0Map =new Map<String, Decimal>();
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = [SELECT Id,RecordType.DeveloperName, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Methodology__c,
                    ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
                    ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,ASI_CRM_CN_Estimate_Volume_9L_Month__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_Volume_Base__c,ASI_CRM_Type__c
                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c =:HistoricalV00ContractId ];



                for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c  FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :HistoricalV00ContractId])
                {
                    if (ccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                        HistoricalV00Contract.VariableExpense += ccost.ASI_CRM_CN_Estimate_Amount__c!=null?ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    }
                }


                Set<String> PSFMethodologySet = new  Set<String>();
                Set<String> PSFVolumeBaseSet= new  Set<String>();
                //Looping the Contract Line
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractLineList){       //By Sub-Brand
                    //if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){
                    if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null )
                    {

                        V00SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        Decimal V00Volumes = 0;
                        if (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                            V00Volumes = (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c* ContractLine.ASI_CRM_CN_No_of_Months__c);
                        }

                        //Get All BRSF Estimate Volumes
                        if((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ){
                            BRSFEstimateVolumesTotalV0 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                            BRSFList.add(ContractLine);
                            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                                HistoricalV00Contract.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                            }
                        }
                        if(ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c!=null){
                            if(EstimateVolumeV0Map.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                                Decimal TempEstimateVolume = EstimateVolumeV0Map.get(ContractLine.ASI_CRM_CN_Sub_Brand__c)+ ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c ;
                                EstimateVolumeV0Map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, TempEstimateVolume);
                            }else{
                                EstimateVolumeV0Map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c);
                            }
                        }


                        //Calculate Volume
                        HistoricalV00Contract.Volumes += V00Volumes;

                        //By Sub-Brand Grade Grouping
                        String SubbrandGroupName='0. Not Specified';
                        String SubBrandName='';
                        if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                            SubbrandGroupName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c:ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                            SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        }

                        if(HistoricalV00Contract.SubBrandGradeGrouping.containsKey(SubBrandName)){
                            Decimal TempVolumes=HistoricalV00Contract.SubBrandGradeGrouping.get(SubBrandName)+V00Volumes;
                            HistoricalV00Contract.SubBrandGradeGrouping.remove(SubBrandName);//remove orignal one
                            HistoricalV00Contract.SubBrandGradeGrouping.put(SubBrandName,TempVolumes);
                        }else{
                            HistoricalV00Contract.SubBrandGradeGrouping.put(SubBrandName,V00Volumes);
                        }

                        if(HistoricalV00Contract.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                            Decimal TempVolumes=HistoricalV00Contract.SubBrandGradeMap.get(SubbrandGroupName)+V00Volumes;
                            //remove orignal one
                            HistoricalV00Contract.SubBrandGradeMap.remove(SubbrandGroupName);
                            HistoricalV00Contract.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
                        }else{
                            HistoricalV00Contract.SubBrandGradeMap.put(SubbrandGroupName,V00Volumes);
                        }

                        //By Brande Product Category Grouping
                        if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c !=null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                            String CategoryName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                            if(HistoricalV00Contract.CategoryMap.containsKey(CategoryName)){
                                Decimal TempVolumes=HistoricalV00Contract.CategoryMap.get(CategoryName)+V00Volumes;
                                //remove orignal one
                                HistoricalV00Contract.CategoryMap.remove(CategoryName);
                                HistoricalV00Contract.CategoryMap.put(CategoryName,TempVolumes);
                            }else{
                                HistoricalV00Contract.CategoryMap.put(CategoryName,V00Volumes);
                            }
                        }// end of By Brande Product Category Grouping


                        if (PreviousV0CC_Period_map != null && PreviousV0CC_Period_map.size() > 0){
                            for (Date previousV0CCdate : PreviousV0CC_Period_map.keySet() ){

                                Date strDateCC = FYConversion(previousV0CCdate);
                                String strkey_p = String.valueOf(strDateCC) + ContractLine.ASI_CRM_CN_Sub_Brand__c ;
                                subbrand_data newitem = new subbrand_data();
                                newitem.period = PreviousV0CC_Period_map.get(previousV0CCdate);//This fiscal year's month number
                                newitem.SubBrandId = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                                newitem.TotalVolume = 0;
                                newitem.TotalEstVolume = 0;
                                historicalV0_sbDataROI_map.put(strkey_p, newitem);
                            }
                        }
                        //HistoricalV00Contract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;

                    }else{//Not By Sub-Brand

                    }
                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Module__c!=null){
                        if(!PSFMethodologySet.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                            PSFMethodologySet.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                            HistoricalV00Contract.PSFMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                        }
                        if(!PSFVolumeBaseSet.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                            PSFVolumeBaseSet.add(ContractLine.ASI_CRM_Volume_Base__c);
                            HistoricalV00Contract.PSFVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                        }
                    }
                    //Estimate contract cost total
                    HistoricalV00Contract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;

                    //SUM(BRSF estimate cost, Other variable cost)
                    HistoricalV00Contract.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }//end of Looping the Contract Line



                Map<String,Decimal> CR12FactorMap = GenerateCR12FactorMap(V00SubBrandIdSet, CommercialTeam, strRegion);
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine :BRSFList){
                    if (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                        Decimal CR12Factor=1;
                        if(CR12FactorMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                            CR12Factor=CR12FactorMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        }
                        HistoricalV00Contract.IntakeCR12 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                    }
                }


                Date StartDateExtend2 = Date.newInstance(StartDateExtend.addYears(-1).year(), 6, 30);
                Date EndDateExtend2 = Date.newInstance(EndDateExtend.year(), 6, 30);

                //Getting GM/GS Data



                for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c FROM ASI_CRM_CM_GS__c
                WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3) AND
                ASI_CRM_Region__c = :strRegion  AND ASI_CRM_TYPE__c = 'Budget CM'
                AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  
                AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS') 
                ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
                {// and ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
                    String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
                    Decimal cm=0.0;
                    if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                        cm = lbcm.ASI_CRM_CM_GS_per_9L__c;
                    }
                    if (!RegionSubBrandCM_Map.containsKey(ProductCode)){
                        RegionSubBrandCM_Map.put(ProductCode,cm) ;
                    }
                }


                Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();

                for (ASI_CRM_CM_GS__c line : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Month__c FROM ASI_CRM_CM_GS__c
                WHERE ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet   AND ASI_CRM_Region__c = :strRegion AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS')
                AND ( (ASI_CRM_CN_Month_End_Date__c >= :StartDateExtend AND ASI_CRM_CN_Month_End_Date__c <= :EndDateExtend )
                OR (ASI_CRM_CN_Month_End_Date__c >= :StartDateExtend2   AND ASI_CRM_CN_Month_End_Date__c <= :EndDateExtend2  AND ASI_CRM_CN_Month__c = 6  ) )
                AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS') ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
                {

                    String strkey_v0 = String.valueOf(line.ASI_CRM_CN_Month_End_Date__c) + line.ASI_CRM_PRODUCTCODE__c;
                    if(line.ASI_CRM_CN_Month__c == 6 && !cmgsMap.containsKey(line.ASI_CRM_PRODUCTCODE__c + line.ASI_CRM_TYPE__c) && line.ASI_CRM_CM_GS_per_9L__c != null && line.ASI_CRM_CM_GS_per_9L__c != 0){
                        cmgsMap.put(line.ASI_CRM_PRODUCTCODE__c +line.ASI_CRM_TYPE__c, line);
                    }

                    if (historicalV0_sbDataROI_map.containsKey(strkey_v0) && line.ASI_CRM_CM_GS_per_9L__c != null && line.ASI_CRM_CM_GS_per_9L__c != 0  ){
                        if ( historicalV0_sbDataROI_map.get(strkey_v0).CM == null || historicalV0_sbDataROI_map.get(strkey_v0).CM == 0 ){
                            if (line.ASI_CRM_TYPE__c == 'Budget CM'){
                                historicalV0_sbDataROI_map.get(strkey_v0).CM = line.ASI_CRM_CM_GS_per_9L__c;
                            }
                        }
                        if(historicalV0_sbDataROI_map.get(strkey_v0).GS == null || historicalV0_sbDataROI_map.get(strkey_v0).GS == 0){
                            if (line.ASI_CRM_TYPE__c == 'Budget GS'){
                                historicalV0_sbDataROI_map.get(strkey_v0).GS = line.ASI_CRM_CM_GS_per_9L__c;
                            }
                        }

                        if (historicalV0_sbDataROI_map.containsKey(strkey_v0)){
                            if (historicalV0_sbDataROI_map.get(strkey_v0).latestBudgetCM == null || historicalV0_sbDataROI_map.get(strkey_v0).latestBudgetCM == 0){
                                if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                                    historicalV0_sbDataROI_map.get(strkey_v0).latestBudgetCM = RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c);
                                }
                            }
                        }
                    }
                }// End of CM/GS Looping



                // to replace null value with latest CMGS data
                for(String key : historicalV0_sbDataROI_map.keySet()){
                    if(historicalV0_sbDataROI_map.get(key).CM == null || historicalV0_sbDataROI_map.get(key).CM == 0 || historicalV0_sbDataROI_map.get(key).GS == null || historicalV0_sbDataROI_map.get(key).GS == 0 || historicalV0_sbDataROI_map.get(key).latestBudgetCM == null || historicalV0_sbDataROI_map.get(key).latestBudgetCM == 0){
                        if((historicalV0_sbDataROI_map.get(key).CM == null || historicalV0_sbDataROI_map.get(key).CM == 0) && cmgsMap.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget CM')){
                            ASI_CRM_CM_GS__c cmgs = cmgsMap.get(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget CM');
                            historicalV0_sbDataROI_map.get(key).CM = cmgs.ASI_CRM_CM_GS_per_9L__c;

                        }

                        if((historicalV0_sbDataROI_map.get(key).GS == null || historicalV0_sbDataROI_map.get(key).GS == 0) && cmgsMap.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget GS')){
                            ASI_CRM_CM_GS__c cmgs = cmgsMap.get(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget GS');
                            historicalV0_sbDataROI_map.get(key).GS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                        }

                        if(historicalV0_sbDataROI_map.get(key).latestBudgetCM == null || historicalV0_sbDataROI_map.get(key).latestBudgetCM == 0){
                            if(RegionSubBrandCM_Map.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId)){
                                historicalV0_sbDataROI_map.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(historicalV0_sbDataROI_map.get(key).SubBrandId);
                            }

                        }
                    }
                }



                //Calculate Total CM
                if (historicalV0_sbDataROI_map != null && historicalV0_sbDataROI_map.size() > 0){
                    Decimal ActualGS;
                    Decimal ActualCM; //Budget CM
                    Decimal LatestBudgetCM; // Latest Budget CM
                    Decimal TotalEstimateVol;
                    Decimal PeriodStr; // Number of month

                    for (String key : historicalV0_sbDataROI_map.keySet()){
                        PeriodStr= null;
                        if (historicalV0_sbDataROI_map.get(key).period != null){
                            PeriodStr = historicalV0_sbDataROI_map.get(key).period;
                        }
                        //Budget CM
                        ActualCM = null;
                        if (historicalV0_sbDataROI_map.get(key).CM != null){
                            ActualCM = historicalV0_sbDataROI_map.get(key).CM;
                        }
                        // Latest Budget CM
                        LatestBudgetCM = null;
                        if (historicalV0_sbDataROI_map.get(key).latestBudgetCM != null){
                            LatestBudgetCM = historicalV0_sbDataROI_map.get(key).latestBudgetCM;
                        }
                        //Budget GS
                        ActualGS = null;
                        if (historicalV0_sbDataROI_map.get(key).GS != null){
                            ActualGS = historicalV0_sbDataROI_map.get(key).GS;
                        }
                        TotalEstimateVol = null;
                        if (EstimateVolumeV0Map != null && historicalV0_sbDataROI_map.get(key) != null && historicalV0_sbDataROI_map.get(key).SubBrandId != null && EstimateVolumeV0Map.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId)){
                            TotalEstimateVol = EstimateVolumeV0Map.get(historicalV0_sbDataROI_map.get(key).SubBrandId);
                        }
                        //Total Volume
                        if (TotalEstimateVol != null && ActualCM != null && PeriodStr != null){
                            CMTotalV0 += ActualCM * TotalEstimateVol * PeriodStr;
                        }

                        if (TotalEstimateVol != null && LatestBudgetCM != null && PeriodStr != null){
                            LatestBudgetCMTotalV0 += LatestBudgetCM * TotalEstimateVol * PeriodStr;
                        }
                        //Gross Sales
                        if (TotalEstimateVol != null && ActualGS != null && PeriodStr != null){
                            HistoricalV00Contract.GrossSalesTotal += ActualGS * TotalEstimateVol * PeriodStr;
                        }
                    }
                }// end of historicalV0_sbDataROI_map Looping

                //**************************Calculation**************************

                if(HistoricalV00Contract.TradeExpenses != null && HistoricalV00Contract.TradeExpenses != 0 ){
                    HistoricalV00Contract.FixedExpenseRate = HistoricalV00Contract.FixedExpense / HistoricalV00Contract.TradeExpenses *100;

                }

                //Calculate 'Investment per CR12 eq btl ' = Trade expenses / (CR12 Conversion Factor in Sub-brand * estimate Monthly vol. * PO Period in Sub-Brand )
                if (HistoricalV00Contract.IntakeCR12 != 0 && HistoricalV00Contract.IntakeCR12!= null &&  HistoricalV00Contract.TradeExpenses != 0 &&  HistoricalV00Contract.TradeExpenses != null){
                    HistoricalV00Contract.InvestmentCR12 =  (HistoricalV00Contract.TradeExpenses / HistoricalV00Contract.IntakeCR12).setScale(2);
                }

                //Calculate Historical V0 Cont. Margin after A&P = SUM( Budget CMs * estimate Monthly vol. in 9L  of PO period) - Trade expenses
                if (CMTotalV0 != null && HistoricalV00Contract.TradeExpenses != null){
                    HistoricalV00Contract.MarginAfterAnP = CMTotalV0 - HistoricalV00Contract.TradeExpenses;
                }

                //
                if (BRSFEstimateVolumesTotalV0 != null && HistoricalV00Contract.NoOfMonths != null){
                    //HistoricalV00Contract.MarginPerBottle =BRSFEstimateVolumesTotalV0 * HistoricalV00Contract.NoOfMonths;
                    HistoricalV00Contract.IntakeSTD=BRSFEstimateVolumesTotalV0 * HistoricalV00Contract.NoOfMonths;
                }

                if (HistoricalV00Contract.IntakeSTD!= 0 && HistoricalV00Contract.IntakeSTD != null && HistoricalV00Contract.MarginAfterAnP != 0 && HistoricalV00Contract.MarginAfterAnP != null){
                    HistoricalV00Contract.MarginPerBottle = (HistoricalV00Contract.MarginAfterAnP / HistoricalV00Contract.IntakeSTD).setScale(2);
                }

                //Gross Sales Rate Historical V0
                if (HistoricalV00Contract.GrossSalesTotal  != null && HistoricalV00Contract.GrossSalesTotal  != 0 && HistoricalV00Contract.TradeExpenses!= 0 && HistoricalV00Contract.TradeExpenses != null){
                    HistoricalV00Contract.GrossSalesRate = (HistoricalV00Contract.TradeExpenses / HistoricalV00Contract.GrossSalesTotal  * 100).setScale(2);
                }

                // ROI Intake Historical V0 = Cont. Margin before A&P / Trade expenses
                if (CMTotalV0 != null && CMTotalV0 != 0 && HistoricalV00Contract.TradeExpenses != 0 && HistoricalV00Contract.TradeExpenses != null){
                    HistoricalV00Contract.CMTotal=CMTotalV0;
                    HistoricalV00Contract.ROIIntake = (CMTotalV0 / HistoricalV00Contract.TradeExpenses).setScale(2);
                    HistoricalV00Contract.ROIActual=HistoricalV00Contract.ROIIntake;
                }

                //Calculate ROIProForma = Cont. Margin before A&P from latest CM regardless FY / Trade expenses
                if (LatestBudgetCMTotalV0 != null && LatestBudgetCMTotalV0 != 0 && HistoricalV00Contract.TradeExpenses != 0 && HistoricalV00Contract.TradeExpenses!= null){
                    HistoricalV00Contract.LatestBudgetCMTotal=LatestBudgetCMTotalV0;
                    HistoricalV00Contract.ROIProForma = (LatestBudgetCMTotalV0/ HistoricalV00Contract.TradeExpenses).setScale(2);
                }


            }//Finished getting/Calculate V0.0 data


            //
            //******************************************************   Starting Calculating VFinal Data**********************************************
            if(thisCC.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_No_of_Months__c != null){
                HistoricalVFinalContract.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
            }


            if(thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null){
                HistoricalVFinalContract.FixedExpense = thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
            }
            HistoricalVFinalContract.BCRate = thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c!= null?thisCC.ASI_CRM_CN_Bottle_Collection_Rate__c:0;
            HistoricalVFinalContract.ContractId = thisCC.Id;
            HistoricalVFinalContract.POStartDate = thisCC.ASI_CRM_CN_PO_Start_Date__c;
            HistoricalVFinalContract.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;

            HistoricalVFinalContract.ContractLineMap = new Map<String,ContractLine>();
            HistoricalVFinalContract.FixedExpensesMap = new Map<String,ContractLine>();
            Decimal TotalHC_VolumeBtl =0; // total historical contract Volume BTL
            Decimal TotalHC_IntakeBtl =0;
            Decimal TotalHC_BC =0;  // total historical contract BC
            Decimal TotalBackCap=0;
            Decimal PSFEstTotal=0;
            Decimal VECEstTotal=0;


            Decimal TotalHistorical_MartellBC =0;  // total historical contract Martel BC
            Decimal TotalHistorical_MartellIntakeBtl =0;  // total historical contract Martel Intake Btl
            Decimal TotalHistorical_MartellBlackCap =0;  // total historical contract Martel BlackCap


            for (ASI_CRM_Contract_Cost__c pccost : [SELECT Id,Name, ASI_CRM_CN_Activity_Code__r.Name,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,
                ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c
            FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id])
            {
                if (pccost.ASI_CRM_CN_Cost_Type__c == 'Fixed' && pccost.ASI_CRM_CN_Estimate_Amount__c != null ){
                    if (HistoricalVFinalContract.FixedExpensesMap.containsKey(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c)){
                        HistoricalVFinalContract.FixedExpensesMap.get(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c).HistoricalFees += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    }else{
                        ContractLine ContractDetail = new ContractLine ();
                        ContractDetail.HistoricalFees=pccost.ASI_CRM_CN_Estimate_Amount__c;
                        HistoricalVFinalContract.FixedExpensesMap.put(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c, ContractDetail);
                    }
                }
                if(pccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                    HistoricalVFinalContract.VariableExpense +=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    if(pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('PSF') || pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('Promotion Service Fee') ){
                        PSFEstTotal+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    }
                    if(pccost.ASI_CRM_CN_Activity_Code__r.Name.contains('Variable Event Cost') ){
                        VECEstTotal+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    }

                }
                HistoricalVFinalContract.TradeExpenses+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
            }




            Set<String> PSFMethodologySetVFinal = new Set<String>();
            Set<String> PSFVolumeBaseSetVFinal = new Set<String>();

            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : [SELECT Id,ASI_CRM_Volume_Base__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,ASI_CRM_Type__c,ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Methodology__c,RecordType.DeveloperName,ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Sub_Brand__r.Name,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Total__c ,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Estimate_Volume_9L_Month__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id]){

                if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){

                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                        HistoricalVFinalContract.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                    }

                    String LineKey=SBGradeSorting(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//ContractLineSBGradeName; //NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) +SuBBrandKey;//

                    if(HistoricalVFinalContract.ContractLineMap.containsKey(LineKey)){
                        HistoricalVFinalContract.ContractLineMap.get(LineKey).HistoricalVolume += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c* ContractLine.ASI_CRM_CN_No_of_Months__c:0;
                        HistoricalVFinalContract.ContractLineMap.get(LineKey).HistoricalFees = HistoricalVFinalContract.ContractLineMap.get(LineKey).HistoricalFees + ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    }else{
                        ContractLine ContractDetail = new ContractLine ();
                        ContractDetail.HistoricalVolume=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c* ContractLine.ASI_CRM_CN_No_of_Months__c:0;
                        ContractDetail.HistoricalFees = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                        ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                        ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        HistoricalVFinalContract.ContractLineMap.put(LineKey,ContractDetail);
                    }
                }

                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' ){
                    PSFEstTotal+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }
                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='Variable Event Cost' ){
                    VECEstTotal+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }


                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Module__c!=null){
                    if(!PSFMethodologySetVFinal.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                        PSFMethodologySetVFinal.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                        HistoricalVFinalContract.PSFMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                    }
                    if(!PSFVolumeBaseSetVFinal.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                        PSFVolumeBaseSetVFinal.add(ContractLine.ASI_CRM_Volume_Base__c);
                        HistoricalVFinalContract.PSFVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                    }
                }

                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
                    HistoricalVFinalContract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
                    HistoricalVFinalContract.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
                }else{
                    HistoricalVFinalContract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    HistoricalVFinalContract.VariableExpense += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                }
            }
            AdditionalFIMap.put('PSFEstTotal',PSFEstTotal);
            AdditionalFIMap.put('VECEstTotal',VECEstTotal);


            if(thisCC.ASI_CRM_CN_PO_Version__c!='0.0' && thisCC.ASI_TH_CRM_Promotion_Type__c== 'Heavy Contract On'){// ASI_CRM_CN_Total_Contract_Amount__c
                HistoricalVFinalContract.TradeExpenses=thisCC.ASI_CRM_CN_Total_Contract_Amount__c!=null?thisCC.ASI_CRM_CN_Total_Contract_Amount__c:0;
                HistoricalVFinalContract.VariableExpense=0;
                HistoricalVFinalContract.VariableExpense+=thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
                HistoricalVFinalContract.VariableExpense+=thisCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
                HistoricalVFinalContract.VariableExpense+=thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c!=null?thisCC.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
                HistoricalVFinalContract.VariableExpense+=thisCC.ASI_CRM_CN_Contract_Variable_Cost_Total__c!=null?thisCC.ASI_CRM_CN_Contract_Variable_Cost_Total__c:0;

            }



            Set<Id> HistoricalVFinalSBIdSet = new Set<Id> ();
            Date CutOffDay =GenerateCutOffDate();
            Date TillEnd;
            if (CutOffDay >= thisCC.ASI_CRM_CN_PO_End_Date__c)
                TillEnd = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c);
            else
                TillEnd = CutOffDay;

            Integer PeriodA = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
            Integer PeriodB = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);

            Decimal TotalHCVolumeBtl=0;
            Map<Date, Decimal> HistoricalVFinal_Period_map = checkFYDayPeriod(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);

            System.debug(HistoricalAllOutlet+'RestructureCurrentFIData TillEnd 0.1: '+TillEnd);
            System.debug('PeriodA: '+PeriodA);
            System.debug('PeriodB: '+PeriodA);

            Map <String, subbrand_data> historical_sbDataROI_map = new Map <String, subbrand_data> ();
            List<ASI_CRM_Subbrand_Volume__c> HistoricalSBVolumeList = [SELECT Id, Name,ASI_CRM_DeductCapWithIssue_StdBill__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_Black_Cap_Std_Billing__c,ASI_CRM_Grey_Cap_Std_Billing__c,ASI_CRM_Offtake__c, ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Offtake_CR12__c, ASI_CRM_Subbrand__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c, ASI_CRM_Subbrand__r.Name,  ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_T2_Depletion_BTL__c,ASI_CRM_T1_Depletion__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c, ASI_CRM_T2_Depletion__c, ASI_CRM_PR_Direct__c, ASI_CRM_PR_Direct_Btl__c,ASI_CRM_End_Date__c ,ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,
                ASI_CRM_PR_Direct_STD__c,ASI_CRM_Black_Cap_Btl__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_DeductibleCapWithIssues_Std_Btl__c,ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c
            FROM ASI_CRM_Subbrand_Volume__c WHERE  ASI_CRM_Account__c IN :HistoricalAllOutlet
            AND ASI_CRM_CN_Competitor_Sub_brand__c != TRUE AND ASI_CRM_Subbrand__c !=NULL
            AND ASI_CRM_End_Date__c >= :thisCC.ASI_CRM_CN_PO_Start_Date__c AND
            ASI_CRM_End_Date__c <= :TillEnd AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE];


            Set<Id> PreviousCC_SBId = new Set<Id>();

            for (ASI_CRM_Subbrand_Volume__c sbid : HistoricalSBVolumeList){
                PreviousCC_SBId.add(sbid.ASI_CRM_Subbrand__c);
            }

            for (Date PCCperiod: HistoricalVFinal_Period_map.keySet() ){
                if (PreviousCC_SBId.size() > 0){
                    for (Id sbidtemp : PreviousCC_SBId){
                        String   PeriodKey = String.valueOf(PCCperiod) + sbidtemp;
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = HistoricalVFinal_Period_map.get(PCCperiod);
                        newitem.SubBrandId = sbidtemp;
                        newitem.year = String.valueOf(PCCperiod.year());
                        newitem.TotalVolume = 0;
                        historical_sbDataROI_map.put(PeriodKey, newitem);

                    }
                }
            }


            Decimal TotalBlackCap_prorate=0;
            Decimal Total_IntakeBtl_prorate=0;
            Decimal TotalBC_prorate=0;
            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume: HistoricalSBVolumeList){

                HistoricalVFinalSBIdSet.add(SubBrandVolume.ASI_CRM_Subbrand__c);
                //Calculate Volume
                Decimal Volumes = getVolume(SubBrandVolume, '9L');
                Decimal VolumeBtl = getVolume(SubBrandVolume, 'std');


                Decimal BottleCollection=0;
                BottleCollection += SubBrandVolume.ASI_CRM_Green_Cap_STD__c != null? SubBrandVolume.ASI_CRM_Green_Cap_STD__c:0;
                BottleCollection += SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c != null? SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c:0;
                //BottleCollection += SubBrandVolume.ASI_CRM_DeductibleCapWithIssues_Std_Btl__c != null? SubBrandVolume.ASI_CRM_DeductibleCapWithIssues_Std_Btl__c:0;
                TotalHC_BC +=BottleCollection;

                Decimal BlackCap=0;
                BlackCap+= SubBrandVolume.ASI_CRM_Cap_with_Issues_Std_Billing__c != null? SubBrandVolume.ASI_CRM_Cap_with_Issues_Std_Billing__c:0;   //BlackCap+= SubBrandVolume.ASI_CRM_Black_Cap_Std_Billing__c != null? SubBrandVolume.ASI_CRM_Black_Cap_Std_Billing__c:0;
                //BlackCap+= SubBrandVolume.ASI_CRM_Grey_Cap_Std_Billing__c != null? SubBrandVolume.ASI_CRM_Grey_Cap_Std_Billing__c:0;
                TotalBackCap+=BlackCap;


                if( ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c) ){
                    TotalHistorical_MartellBC += BottleCollection;
                    TotalHistorical_MartellIntakeBtl+=VolumeBtl;
                    TotalHistorical_MartellBlackCap+=BlackCap;
                }

                TotalHC_IntakeBtl+=VolumeBtl;
                Decimal VarHistTotal = VolumeBtl;
                Decimal VarHistTotalVolume=Volumes;
                Decimal VariableHistoricalBottles = VolumeBtl/PeriodA;

                if (PeriodA != 0 && PeriodA != null && PeriodB != 0 && PeriodB != null){
                    Volumes = Volumes/PeriodA * PeriodB;
                    VolumeBtl = VolumeBtl/PeriodA * PeriodB;
                    BottleCollection = BottleCollection/PeriodA * PeriodB;
                    BlackCap = BlackCap/PeriodA * PeriodB;

                }


                TotalBlackCap_prorate+=BlackCap;
                Total_IntakeBtl_prorate+=VolumeBtl;
                TotalBC_prorate+=BottleCollection;


                TotalHC_VolumeBtl += VolumeBtl;
                // Historical VFinal Contract Volume (in 9L cs) INTAKE (Historical Contract vFinal)
                HistoricalVFinalContract.Volumes += Volumes;
                //Sub-Brand Grade Grouping
                String SubbrandGroupName='0. Not Specified';
                String SubBrandName='';
                if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                    SubbrandGroupName=SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null?SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c:SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                }

                if(HistoricalVFinalContract.SubBrandGradeGrouping.containsKey(SubBrandName)){
                    Decimal TempVolumes=HistoricalVFinalContract.SubBrandGradeGrouping.get(SubBrandName)+Volumes;
                    //remove orignal one
                    HistoricalVFinalContract.SubBrandGradeGrouping.remove(SubBrandName);
                    HistoricalVFinalContract.SubBrandGradeGrouping.put(SubBrandName,TempVolumes);
                }else{
                    HistoricalVFinalContract.SubBrandGradeGrouping.put(SubBrandName,Volumes);
                }

                if(HistoricalVFinalContract.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                    Decimal TempVolumes=HistoricalVFinalContract.SubBrandGradeMap.get(SubbrandGroupName)+Volumes;
                    //remove orignal one
                    HistoricalVFinalContract.SubBrandGradeMap.remove(SubbrandGroupName);
                    HistoricalVFinalContract.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes);
                }else{
                    HistoricalVFinalContract.SubBrandGradeMap.put(SubbrandGroupName,Volumes);
                }

                //By Brande Product Category Grouping
                if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c !=null && SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                    String CategoryName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    if(HistoricalVFinalContract.CategoryMap.containsKey(CategoryName)){
                        Decimal TempVolumes=HistoricalVFinalContract.CategoryMap.get(CategoryName)+Volumes;
                        //remove orignal one
                        HistoricalVFinalContract.CategoryMap.remove(CategoryName);
                        HistoricalVFinalContract.CategoryMap.put(CategoryName,TempVolumes);
                    }else{
                        HistoricalVFinalContract.CategoryMap.put(CategoryName,Volumes);
                    }
                }// end of By Brande Product Category Grouping


                Date SubbrandVolumeDateKey = FYConversion(SubBrandVolume.ASI_CRM_End_Date__c);
                String SubbrandVolumeStrKey = String.valueOf(SubbrandVolumeDateKey) + SubBrandVolume.ASI_CRM_Subbrand__c;

                if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(SubbrandVolumeStrKey)){
                    historical_sbDataROI_map.get(SubbrandVolumeStrKey).TotalVolume += VarHistTotalVolume;
                }

                String SuBBrandKey =SBGradeSorting(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + SubBrandVolume.ASI_CRM_Subbrand__r.Name;

                if(HistoricalVFinalContract.ContractLineMap.containsKey(SuBBrandKey)){
                    HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalBottles =HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalBottles + VariableHistoricalBottles ;
                    HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalTotalFees +=  HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalFees * VarHistTotal;
                    HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalActualVolume =HistoricalVFinalContract.ContractLineMap.get(SuBBrandKey).HistoricalActualVolume + VariableHistoricalBottles ;
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.HistoricalBottles = VariableHistoricalBottles;
                    ContractDetail.HistoricalActualVolume= VariableHistoricalBottles;
                    //ContractDetail.HistoricalTotalFees=0;
                    ContractDetail.SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.Name;
                    ContractDetail.SubBrandGrade= SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    HistoricalVFinalContract.ContractLineMap.put(SuBBrandKey,ContractDetail);
                }

                Decimal VolumesCR12 = 0;
                VolumesCR12 += SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c:0;
                VolumesCR12 += SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c:0;
                VolumesCR12 += SubBrandVolume.ASI_CRM_PR_Direct_CR12__c!=null? SubBrandVolume.ASI_CRM_PR_Direct_CR12__c:0;
                HistoricalVFinalContract.IntakeCR12 += VolumesCR12;

            }//end of Sub Brand Volume for looping


            AdditionalFIMap.put('TotalBlackCap_prorate',TotalBlackCap_prorate);
            AdditionalFIMap.put('Total_IntakeBtl_prorate',Total_IntakeBtl_prorate);
            AdditionalFIMap.put('TotalBC_prorate',TotalBC_prorate);
            System.debug('HistoricalVFinalContract Volumes: '+HistoricalVFinalContract.Volumes);


            //Prorate Investment CR12 for Historical Contract
            if (PeriodA != 0 && PeriodB!= 0 && PeriodA != null && PeriodB!= null){
                HistoricalVFinalContract.IntakeCR12 = HistoricalVFinalContract.IntakeCR12/PeriodA * PeriodB;
            }



            //YTD CM/GS
            Map<String, Decimal> Latest_ActualCM = new Map<String, Decimal>();
            Map<String, Decimal> Latest_ActualGS = new Map<String, Decimal>();
            Map<String, Decimal> ProForma_LatestBudgetCM = new Map<String, Decimal>();
            Date HistoricalVFinalStartDate = thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);

            System.debug('HistoricalVFinalStartDate: '+HistoricalVFinalStartDate);
            System.debug('TillEnd: '+TillEnd);
            for (ASI_CRM_CM_GS__c line : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c,
                ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,
                ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
            FROM ASI_CRM_CM_GS__c
            WHERE ASI_CRM_PRODUCTCODE__c IN :HistoricalVFinalSBIdSet
            AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            AND ASI_CRM_CN_Month_End_Date__c >= :HistoricalVFinalStartDate
            AND ASI_CRM_CN_Month_End_Date__c <= :TillEnd
            AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS') AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0 
            AND RecordType.DeveloperName in ('ASI_CRM_CN_Actual_CM_GS','ASI_CRM_CN_Competitor_CM_GS') 
            ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
            {

                String strkey = String.valueOf(line.ASI_CRM_CN_Month_End_Date__c) + line.ASI_CRM_PRODUCTCODE__c;
                if (line.ASI_CRM_TYPE__c == 'YTD CM'){

                    if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(strkey)){
                        if (historical_sbDataROI_map.get(strkey).CM == null || historical_sbDataROI_map.get(strkey).CM == 0){
                            historical_sbDataROI_map.get(strkey).CM = line.ASI_CRM_CM_GS_per_9L__c;
                            historical_sbDataROI_map.get(strkey).SubBrandId = line.ASI_CRM_PRODUCTCODE__c;
                        }
                    }
                    if (!Latest_ActualCM.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                        Latest_ActualCM.put(line.ASI_CRM_PRODUCTCODE__c, line.ASI_CRM_CM_GS_per_9L__c);
                    }

                    if(!ProForma_LatestBudgetCM.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                        if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                            ProForma_LatestBudgetCM.put(line.ASI_CRM_PRODUCTCODE__c,RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c));
                        }
                    }
                }

                if (line.ASI_CRM_TYPE__c == 'YTD GS'){
                    if (!Latest_ActualGS.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                        Latest_ActualGS.put(line.ASI_CRM_PRODUCTCODE__c, line.ASI_CRM_CM_GS_per_9L__c);
                    }
                    if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(strkey)){
                        if (historical_sbDataROI_map.get(strkey).GS == null || historical_sbDataROI_map.get(strkey).GS == 0){
                            historical_sbDataROI_map.get(strkey).GS =  line.ASI_CRM_CM_GS_per_9L__c;
                            historical_sbDataROI_map.get(strkey).SubBrandId = line.ASI_CRM_PRODUCTCODE__c;
                        }
                    }
                }

                if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(strkey)){
                    if (historical_sbDataROI_map.get(strkey).latestBudgetCM == null || historical_sbDataROI_map.get(strkey).latestBudgetCM == 0){
                        if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                            historical_sbDataROI_map.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c);
                        }
                    }
                    historical_sbDataROI_map.get(strkey).SubBrandId = line.ASI_CRM_PRODUCTCODE__c;
                }

                if(!ProForma_LatestBudgetCM.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                    if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                        ProForma_LatestBudgetCM.put(line.ASI_CRM_PRODUCTCODE__c,RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c));
                    }
                }


            } // end of CM /GS Looping



            Decimal CMTotalVFinal=0;
            Decimal LatestBudgetCMTotalVFinal = 0;
            //ROI Calculations for Historical
            if (historical_sbDataROI_map != null && historical_sbDataROI_map.size() > 0){
                Decimal ActualCM;
                Decimal LatestBudgetCM;
                Decimal LatestBudgetCM_prorate;
                Decimal ActualGS;
                Decimal TotalActualVol;
                Decimal PeriodStr;
                Decimal ActualCM_prorate;
                Decimal ActualGS_prorate;
                Date historicalVFinalTillEnd;

                if (thisCC.ASI_CRM_CN_PO_End_Date__c != null && CutOffDay >= thisCC.ASI_CRM_CN_PO_End_Date__c)
                    historicalVFinalTillEnd = getEndDate(thisCC.ASI_CRM_CN_PO_End_Date__c);
                else
                    historicalVFinalTillEnd = CutOffDay;

                Integer PeriodA_prorate = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, historicalVFinalTillEnd);
                Integer PeriodB_prorate = MonthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
                Integer PeriodD_prorate = PeriodB_prorate - PeriodA_prorate;

                for (String key : historical_sbDataROI_map.keySet()){
                    PeriodStr= null;
                    if (historical_sbDataROI_map.get(key).period != null){
                        PeriodStr = historical_sbDataROI_map.get(key).period;
                    }
                    //Actual CM
                    ActualCM = null;
                    if (historical_sbDataROI_map.get(key).CM != null && historical_sbDataROI_map.get(key).CM != 0){
                        ActualCM = historical_sbDataROI_map.get(key).CM;
                    }else{
                        if (Latest_ActualCM != null && Latest_ActualCM.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
                            ActualCM = Latest_ActualCM.get(historical_sbDataROI_map.get(key).SubBrandId);
                        }
                    }

                    //Latest Budget CM
                    LatestBudgetCM = null;
                    if (historical_sbDataROI_map.get(key).latestBudgetCM != null){
                        LatestBudgetCM = historical_sbDataROI_map.get(key).latestBudgetCM;
                    }else{
                        if (ProForma_LatestBudgetCM != null && ProForma_LatestBudgetCM.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
                            LatestBudgetCM = ProForma_LatestBudgetCM.get(historical_sbDataROI_map.get(key).SubBrandId);
                        }
                    }
                    //Actual GS
                    ActualGS = null;
                    if (historical_sbDataROI_map.get(key).GS != null && historical_sbDataROI_map.get(key).GS != 0){
                        ActualGS = historical_sbDataROI_map.get(key).GS;
                    }else{
                        if (Latest_ActualGS != null && Latest_ActualGS.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
                            ActualGS = Latest_ActualGS.get(historical_sbDataROI_map.get(key).SubBrandId);
                        }
                    }
                    //Total Volume
                    TotalActualVol = null;
                    if (historical_sbDataROI_map.get(key).TotalVolume != null){
                        TotalActualVol = historical_sbDataROI_map.get(key).TotalVolume;
                    }
                    if (TotalActualVol != null && ActualCM != null ){
                        CMTotalVFinal += ActualCM * TotalActualVol;
                    }

                    if (TotalActualVol != null && LatestBudgetCM != null ){
                        LatestBudgetCMTotalVFinal += LatestBudgetCM * TotalActualVol;
                    }

                    ActualCM_prorate = 0;
                    if (Latest_ActualCM != null && Latest_ActualCM.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
                        ActualCM_prorate = Latest_ActualCM.get(historical_sbDataROI_map.get(key).SubBrandId);
                    }

                    LatestBudgetCM_prorate = 0;
                    if (ProForma_LatestBudgetCM != null && ProForma_LatestBudgetCM.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
                        LatestBudgetCM_prorate = ProForma_LatestBudgetCM.get(historical_sbDataROI_map.get(key).SubBrandId);
                    }

                    if (PeriodA_prorate != null && PeriodA_prorate != 0 && TotalActualVol != null && TotalActualVol != 0 && PeriodD_prorate != null && ActualCM_prorate != null)
                        CMTotalVFinal += ActualCM_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;

                    if (PeriodA_prorate != null && PeriodA_prorate != 0 && TotalActualVol != null && TotalActualVol != 0 && PeriodD_prorate != null && LatestBudgetCM_prorate != null){
                        LatestBudgetCMTotalVFinal += LatestBudgetCM_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;
                    }

                    if (TotalActualVol != null && ActualGS != null){
                        HistoricalVFinalContract.GrossSalesTotal += ActualGS * TotalActualVol;
                    }
                    ActualGS_prorate = 0;
                    if (Latest_ActualCM != null && Latest_ActualGS.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
                        ActualGS_prorate = Latest_ActualGS.get(historical_sbDataROI_map.get(key).SubBrandId);
                    }
                    if (PeriodA_prorate != null && PeriodA_prorate != 0 && TotalActualVol != null && TotalActualVol != 0 && PeriodD_prorate != null && ActualGS_prorate != null){
                        HistoricalVFinalContract.GrossSalesTotal  += ActualGS_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;
                    }

                } // end of looping historical_sbDataROI_map

            }
            //Historical V Final Calculation

            //%Gross Sales Historical
            if (HistoricalVFinalContract.GrossSalesTotal != null && HistoricalVFinalContract.GrossSalesTotal != 0 && HistoricalVFinalContract.TradeExpenses != 0 && HistoricalVFinalContract.TradeExpenses!= null){
                HistoricalVFinalContract.GrossSalesRate = (HistoricalVFinalContract.TradeExpenses/ HistoricalVFinalContract.GrossSalesTotal) *100;
            }

            //Fixed Expense Rate
            if (HistoricalVFinalContract.FixedExpense != 0 &&  HistoricalVFinalContract.TradeExpenses!= 0 && HistoricalVFinalContract.FixedExpense != null &&  HistoricalVFinalContract.TradeExpenses != null){
                HistoricalVFinalContract.FixedExpenseRate = HistoricalVFinalContract.FixedExpense/ HistoricalVFinalContract.TradeExpenses * 100;
            }
            //Historical Contract Margin after A&P
            if (CMTotalVFinal != null && HistoricalVFinalContract.FixedExpense != null){
                HistoricalVFinalContract.MarginAfterAnP = CMTotalVFinal - HistoricalVFinalContract.TradeExpenses;
            }

            if (TotalHC_VolumeBtl != 0 && TotalHC_VolumeBtl!= null && HistoricalVFinalContract.MarginAfterAnP != 0 && HistoricalVFinalContract.MarginAfterAnP != null){
                HistoricalVFinalContract.MarginPerBottle = HistoricalVFinalContract.MarginAfterAnP / TotalHC_VolumeBtl;
                HistoricalVFinalContract.IntakeSTD=TotalHC_VolumeBtl;
            }


            if(HistoricalVFinalContract.IntakeCR12!=null && HistoricalVFinalContract.IntakeCR12 !=0 && HistoricalVFinalContract.TradeExpenses!=null){
                HistoricalVFinalContract.InvestmentCR12 =HistoricalVFinalContract.TradeExpenses/HistoricalVFinalContract.IntakeCR12;
            }

            if (CMTotalVFinal != null && CMTotalVFinal != 0 && HistoricalVFinalContract.TradeExpenses != 0 && HistoricalVFinalContract.TradeExpenses!= null){
                HistoricalVFinalContract.CMTotal=CMTotalVFinal;
                HistoricalVFinalContract.ROIIntake = CMTotalVFinal / HistoricalVFinalContract.TradeExpenses;
            }
            //ProForma_ROI Historical
            if (LatestBudgetCMTotalVFinal != null && LatestBudgetCMTotalVFinal != 0 &&   HistoricalVFinalContract.TradeExpenses!= 0 &&  HistoricalVFinalContract.TradeExpenses!= null){
                HistoricalVFinalContract.LatestBudgetCMTotal=LatestBudgetCMTotalVFinal;
                HistoricalVFinalContract.ROIProForma = LatestBudgetCMTotalVFinal / HistoricalVFinalContract.TradeExpenses;
            }

            if(TotalHC_BC!=0 && TotalHC_BC !=null && TotalHC_IntakeBtl !=null && TotalHC_IntakeBtl!=0){
                HistoricalVFinalContract.TotalBCRate=(TotalHC_BC/TotalHC_IntakeBtl)*100;
                HistoricalVFinalContract.NetBCRate=((TotalHC_BC-TotalBackCap)/TotalHC_IntakeBtl)*100;
            }

            if(TotalHistorical_MartellBC!=0 && TotalHistorical_MartellBC !=null && TotalHistorical_MartellIntakeBtl !=null && TotalHistorical_MartellIntakeBtl!=0){
                HistoricalVFinalContract.TotalMBCRate=(TotalHistorical_MartellBC/TotalHistorical_MartellIntakeBtl)*100;
                HistoricalVFinalContract.NetMBCRate=((TotalHistorical_MartellBC-TotalHistorical_MartellBlackCap)/TotalHistorical_MartellIntakeBtl)*100;
            }



            AdditionalFIMap.put('TotalHistorical_MartellBC',TotalHistorical_MartellBC);
            AdditionalFIMap.put('TotalHistorical_MartellIntakeBtl',TotalHistorical_MartellIntakeBtl);
            AdditionalFIMap.put('TotalHistorical_MartellBlackCap',TotalHistorical_MartellBlackCap);

            AdditionalFIMap.put('TotalHC_BC',TotalHC_BC);
            AdditionalFIMap.put('TotalHC_IntakeBtl',TotalHC_IntakeBtl);
        }

        HistoricalVFinalContract.AddOnString = System.JSON.serialize(AdditionalFIMap);

        List<FinancialIndicator> FinancialIndicatorList = new List<FinancialIndicator>();
        FinancialIndicatorList.add(HistoricalV00Contract);
        FinancialIndicatorList.add(HistoricalVFinalContract);

        UpsertAttachment(thisCC.Id, System.JSON.serialize(FinancialIndicatorList),'Current V0VFinal Data' );

    } // end of RestructureHistoricalData

    //Restructure Current v0 and VFinal Data
    public static void RestructureCurrentFIData2nd(ASI_TH_CRM_Contract__c contract){
        

        FinancialIndicator2nd HistoricalV00Contract = new FinancialIndicator2nd();
        FinancialIndicator2nd HistoricalVFinalContract = new FinancialIndicator2nd();
        
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);
        ASI_TH_CRM_Contract__c PreviousV00CC = new ASI_TH_CRM_Contract__c();
        
        if (thisCC.ASI_CRM_CN_V0_0_PO_version__c != null) {
            PreviousV00CC.Id = thisCC.ASI_CRM_CN_V0_0_PO_version__c;
            HistoricalV00Contract = RestructureCurrentFinancialIndicatorDataList2nd(PreviousV00CC).get(0);
            if (thisCC.ASI_CRM_Auto_PO_Modification__c) {
                List<ASI_TH_CRM_PaymentRequest__c> LastPaymentRequest = [SELECT Id,Name,ASI_CRM_CN_Total_VEC_Amount__c,
                             ASI_CRM_Total_Variable_Amount__c,ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c,
                             ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,
                             ASI_CRM_CN_OutletWS__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                             ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c
                            FROM ASI_TH_CRM_PaymentRequest__c
                             WHERE 
                             ASI_CRM_CN_PO_No__c = :thisCC.ASI_CRM_CN_PO_No__c
                            AND ASI_CRM_CN_Last_Payment__c = TRUE
                            Order By CreatedDate desc];
                if (LastPaymentRequest.isEmpty()) {
                    HistoricalVFinalContract =  ReconstructCurrentPOModiFIDataList2nd(thisCC).get(0);
                }
                else {
                    HistoricalVFinalContract = ASI_CRM_CN_HeavyPaymentUtilitiesClass.ReconstructLastPaymentFIDataList2nd(LastPaymentRequest.get(0)).get(0);
                }
                
            }
            else {
                HistoricalVFinalContract =  ReconstructCurrentPOModiFIDataList2nd(thisCC).get(0);
            }
        }
        else {
            HistoricalV00Contract = RestructureCurrentFinancialIndicatorDataList2nd(thisCC).get(0);
        }

        List<FinancialIndicator2nd> FinancialIndicatorList = new List<FinancialIndicator2nd>();
        FinancialIndicatorList.add(HistoricalV00Contract);
        FinancialIndicatorList.add(HistoricalVFinalContract);

        UpsertAttachment2nd(thisCC.Id, System.JSON.serialize(FinancialIndicatorList),'Current V0VFinal Data' );

    } // end of RestructureHistoricalData

    public static List<TradeExpenseBreakdown> constructTradeExpenseBySubBrand(ASI_TH_CRM_PaymentRequest__c paymentRequest, String contractOrEstimate, String version) {
        ASI_TH_CRM_Contract__c contract = getContract(paymentRequest.ASI_TH_CRM_Contract__c);
        return constructTradeExpenseBySubBrand(contract, contractOrEstimate, version);
    }

    public static List<TradeExpenseBreakdown2nd> constructTradeExpenseBySubBrand2nd(ASI_TH_CRM_PaymentRequest__c paymentRequest, String contractOrEstimate, String version) {
        ASI_TH_CRM_Contract__c contract = getContract(paymentRequest.ASI_TH_CRM_Contract__c);
        return constructTradeExpenseBySubBrand2nd(contract, contractOrEstimate, version);
    }

    public static List<TradeExpenseBreakdown> constructTradeExpenseBySubBrand(ASI_TH_CRM_Contract__c contract, String contractOrEstimate, String version) {
        Map<String, TradeExpenseBreakdown> TradeExpenseBySubBrand = new Map<String, TradeExpenseBreakdown>();
        Map<String, Decimal> totalVolumeByGrade = new Map<String, Decimal>();
        Map<String, Decimal> totalVolumeByCategory = new Map<String, Decimal>();
        Decimal totalVolume = 0;
        Decimal totalBRSFAmount = 0;
        Decimal totalBRSFAmountFromInput = denullify(contract.ASI_CRM_CN_Expected_BRSF_Est_Total__c);
        Decimal totalPSFAmount = 0;
        Decimal totalPSFAmountFromInput = denullify(contract.ASI_CRM_CN_Expected_PSF_Est_Total__c);
        Decimal totalVECAmount = 0;
        Decimal totalVECAmountFromInput = denullify(contract.ASI_CRM_EVC_Cost_Estimate_Total__c);
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFLines = retrieveBRSFLines(contract, new List<String>{
            'BRSF'
        }, true);
        Map<Id, ASI_CRM_CN_Contract_BRSF_Line_Item__c> subBrandBRSFLineMap = new Map<Id, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine : BRSFLines){
            subBrandBRSFLineMap.put(BRSFLine.ASI_CRM_CN_Sub_Brand__c, BRSFLine);
        }


        // Get Historical Payment, Must use PO number rather than Id because historical contract has no payment
        List<ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentList = [
            SELECT
                Id,ASI_TH_CRM_Payment_Request__c,ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Incentive_BT__c
            FROM ASI_TH_CRM_PaymentRequestLineItem__c
            WHERE ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_No__c = :contract.ASI_CRM_CN_PO_No__c
            AND RecordType.DeveloperName = :'ASI_CRM_CN_Payment_Request_Detail_BRSF'
            ORDER BY ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_Version__c
        ];
        Map<String, Decimal> HistoricalPaymentIncentiveBySubBrand = new Map<String, Decimal>();
        for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : HistoricalPaymentList) {
            HistoricalPaymentIncentiveBySubBrand.put(lineItem.ASI_CRM_CN_Sub_Brand__c, lineItem.ASI_CRM_CN_Incentive_BT__c);
        }

        List<ASI_TH_CRM_PaymentRequest__c> lastPayments = [
            SELECT
                Id,Name,ASI_TH_CRM_Status__c,
            (SELECT
                Id,ASI_CRM_Line_Type__c, ASI_CRM_Historical_Paid_Amount__c, ASI_CRM_Actual_Payment__c
            FROM ASI_CRM_Modules__r),
            (SELECT
                Id, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_Product_Category__c, ASI_CRM_Module__c,ASI_TH_CRM_Amount__c,
                ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                ASI_CRM_Module__r.ASI_CRM_Historical_Paid_Amount__c,
                ASI_CRM_Module__r.ASI_CRM_Actual_Payment__c,
                ASI_CRM_Module__r.ASI_CRM_Application_Payment_Amount__c,
                ASI_CRM_Volume_Base__c, ASI_CRM_CN_Total_Payable__c, RecordType.DeveloperName
            FROM ASI_TH_CRM_PRLI_PaymentRequest__r)
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE ASI_CRM_CN_PO_No__c = :contract.ASI_CRM_CN_PO_No__c
            AND ASI_CRM_CN_Last_Payment__c = TRUE
        ];

        Decimal historicalBRSFPaymentSum = 0;
        Decimal historicalVECPaymentSum = 0;
        for (ASI_TH_CRM_PaymentRequest__c lastPayment : lastPayments) {
            for (ASI_CRM_Module__c module : lastPayment.ASI_CRM_Modules__r) {
                if (module.ASI_CRM_Line_Type__c == 'BRSF') {
                    historicalBRSFPaymentSum += module.ASI_CRM_Historical_Paid_Amount__c;
                    if (version == 'Last Payment') {
                        totalBRSFAmountFromInput = module.ASI_CRM_Actual_Payment__c;
                    }
                }
                if (module.ASI_CRM_Line_Type__c == 'VEC' || module.ASI_CRM_Line_Type__c == 'Variable Event Cost') {
                    historicalVECPaymentSum += module.ASI_CRM_Historical_Paid_Amount__c;
                    if (version == 'Last Payment') {
                        totalVECAmountFromInput = module.ASI_CRM_Actual_Payment__c;
                    }
                }

            }
        }
        System.debug(LoggingLevel.INFO, '*** version: ' + version);
        System.debug(LoggingLevel.INFO, '*** historicalVECPaymentSum: ' + historicalVECPaymentSum);
        System.debug(LoggingLevel.INFO, '*** totalVECAmountFromInput: ' + totalVECAmountFromInput);

        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap = new Map<String, ASI_CRM_Sub_Brand_Grade__c>();
        for (ASI_CRM_Sub_Brand_Grade__c sbg : GeneratingSubBrandGrade(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c)) {
            if (sbg.ASI_CRM_CN_City_Tier__c != null) {
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c + CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }
            SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
        }

        List<ASI_CRM_Subbrand_Volume__c> volumes = retrieveSubBrandVolumes(contract);

        // Calculate CTD Volume and project to the whole period
        if (version == 'PO Modi' || version == 'Last Payment') {
            for (ASI_CRM_Subbrand_Volume__c subBrandVolume : volumes) {
                TradeExpenseBreakdown data = TradeExpenseBySubBrand.containsKey(subBrandVolume.ASI_CRM_Subbrand__c)? TradeExpenseBySubBrand.get(subBrandVolume.ASI_CRM_Subbrand__c) : new TradeExpenseBreakdown(subBrandVolume);
                data.volumeSTD += getVolume(subBrandVolume, 'std');
                TradeExpenseBySubBrand.put(subBrandVolume.ASI_CRM_Subbrand__c, data);
            }
            // Project to the whole period
            for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
                TradeExpenseBreakdown data = TradeExpenseBySubBrand.get(subBrandId);
                // Not contract Sub-Brand will get incentive from payment, if no payment, take default value
                if (data.nonContract) {
                    Decimal defaultIncentive = 0;
                    String ExternalKey = data.gradeName;

                    ExternalKey += contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c != null? contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c : '';
                    ExternalKey += contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c != null? contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c : '';

                    String CityTierExternalKey = ExternalKey;
                    if (contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c != null && contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c != null) {
                        CityTierExternalKey += ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
                    }

                    if (SubBrandGradeMap.containsKey(CityTierExternalKey)) {
                        defaultIncentive = SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive__c;
                    } else if (SubBrandGradeMap.containsKey(ExternalKey)) {
                        defaultIncentive = SubBrandGradeMap.get(ExternalKey).ASI_CRM_CN_Incentive__c;
                    } else if (SubBrandGradeMap.containsKey(data.gradeName)) {
                        defaultIncentive = SubBrandGradeMap.get(data.gradeName).ASI_CRM_CN_Incentive__c;
                    }
                    //LS-194: Logic Change
                    //  Old logic: If no historical payment, use Default
                    //  New logic:  If no historical payment, use Contract data
                    //              If no Contract data, use default
                    // data.BRSFIncentive = HistoricalPaymentIncentiveBySubBrand.containsKey(subBrandId)? HistoricalPaymentIncentiveBySubBrand.get(subBrandId) : defaultIncentive;
                    if (HistoricalPaymentIncentiveBySubBrand.containsKey(subBrandId)){
                        data.BRSFIncentive = HistoricalPaymentIncentiveBySubBrand.get(subBrandId);
                    } else {
                        if (subBrandBRSFLineMap.containsKey(subBrandId)){
                            ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem = subBrandBRSFLineMap.get(subBrandId);
                            data.BRSFIncentive = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c : lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c);
                        }
                        if (data.BRSFIncentive == null || data.BRSFIncentive == 0){
                            data.BRSFIncentive = defaultIncentive;
                        }
                    }
                }
                data.volumeSTD = projectVolume(data.volumeSTD, contract).setScale(4);
                data.BRSFAmount = data.volumeSTD * data.BRSFIncentive.setScale(4);
                TradeExpenseBySubBrand.put(subBrandId, data);
            }

        }

        // Use BRSF line as Trade expense calculation if PO OPen or no volume at all
        if (version == 'PO Open' || volumes.isEmpty()) {
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : BRSFLines) {
                TradeExpenseBreakdown data = TradeExpenseBySubBrand.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)? TradeExpenseBySubBrand.get(lineItem.ASI_CRM_CN_Sub_Brand__c) : new TradeExpenseBreakdown(lineItem);
                data.nonContract = false;

                // If no Sub-Brand volume, take contract value
                if (!TradeExpenseBySubBrand.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)) {
                    data.volumeSTD = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c : lineItem.ASI_CRM_CN_Est_Monthly_Qty__c) * contract.ASI_CRM_CN_No_of_Months__c;
                }
                data.BRSFIncentive = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c : lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c);
                data.BRSFAmount = (data.volumeSTD * data.BRSFIncentive).setScale(4);

                TradeExpenseBySubBrand.put(lineItem.ASI_CRM_CN_Sub_Brand__c, data);
            }
        }

        // Get Payment Request Line, use its CTD Payable Amount as BRSF Amount
        if (version == 'Last Payment') {
            for (ASI_TH_CRM_PaymentRequest__c lastPayment : lastPayments) {
                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : lastPayment.ASI_TH_CRM_PRLI_PaymentRequest__r) {
                    if (lineItem.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_BRSF' && TradeExpenseBySubBrand.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)) {
                        TradeExpenseBySubBrand.get(lineItem.ASI_CRM_CN_Sub_Brand__c).BRSFAmount = denullify(lineItem.ASI_CRM_CN_Total_Payable__c);
                    }

                }
            }
        }

        for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
            TradeExpenseBreakdown data = TradeExpenseBySubBrand.get(subBrandId);
            if (totalVolumeByGrade.containsKey(data.gradeId)) {
                totalVolumeByGrade.put(data.gradeId, totalVolumeByGrade.get(data.gradeId) + data.volumeCR12);
            } else {
                totalVolumeByGrade.put(data.gradeId, data.volumeCR12);
            }

            if (totalVolumeByCategory.containsKey(data.categoryId)) {
                totalVolumeByCategory.put(data.categoryId, totalVolumeByCategory.get(data.categoryId) + data.volumeCR12);
            } else {
                totalVolumeByCategory.put(data.categoryId, data.volumeCR12);
            }

            totalVolume += data.volumeCR12;
        }
        for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
            TradeExpenseBreakdown data = TradeExpenseBySubBrand.get(subBrandId);

            data.propByGrade = totalVolumeByGrade.get(data.gradeId) != 0? data.volumeCR12 / totalVolumeByGrade.get(data.gradeId) : 1;
            data.propByCategory = totalVolumeByCategory.get(data.categoryId) != 0? data.volumeCR12 / totalVolumeByCategory.get(data.categoryId) : 1;
            data.propByTotal = totalVolume != 0? data.volumeCR12 / totalVolume : 1;

            data.propByGrade = data.propByGrade.setScale(4);
            data.propByCategory = data.propByCategory.setScale(4);
            data.propByTotal = data.propByTotal.setScale(4);
        }

        List<ASI_CRM_Module__c> modules = retrieveModulesAndLines(contract, new List<String>{
            'PSF', 'Variable Event Cost'
        });

        // Key: sub-brandId + contractModuleId, value: incentive from Payment request line
        Map<String, Decimal> incentiveBySubBrandByModule = new Map<String, Decimal>();

        List<ASI_TH_CRM_PaymentRequest__c> latestPayments = [
            SELECT
                Id,Name,ASI_TH_CRM_Status__c,
            (SELECT
                Id, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_Product_Category__c, ASI_CRM_CN_Incentive_BT__c,
                ASI_CRM_Module__c,
                ASI_CRM_Module__r.ASI_CRM_Parent_Module__c
            FROM ASI_TH_CRM_PRLI_PaymentRequest__r
            WHERE ASI_CRM_Module__r.ASI_CRM_Volume_Base__c = 'By Sub-Brand')
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE ASI_CRM_CN_PO_No__c = :contract.ASI_CRM_CN_PO_No__c
            ORDER BY Name DESC
            LIMIT 1
        ];
        if (latestPayments.size() > 0) {
            for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : latestPayments[0].ASI_TH_CRM_PRLI_PaymentRequest__r) {
                incentiveBySubBrandByModule.put(String.valueOf(lineItem.ASI_CRM_CN_Sub_Brand__c) + String.valueOf(lineItem.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c), lineItem.ASI_CRM_CN_Incentive_BT__c);
            }
        }
        for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
            TradeExpenseBreakdown data = TradeExpenseBySubBrand.get(subBrandId);
            for (ASI_CRM_Module__c module : modules) {
                if (module.Contract_BRSF_Line_Item__r.isEmpty()) {
                    continue;
                }
                Decimal amount = 0;
                Decimal tradeExpense = 0;
                Decimal incentivePerCR12 = 0;

                // For non contract sub-brand, its By Sub-Brand trade expense depends on Payment incentive
                if (data.nonContract && module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                    tradeExpense = data.volumeSTD * denullify(incentiveBySubBrandByModule.get(data.subBrandId + module.Id));
                }
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : module.Contract_BRSF_Line_Item__r) {
                    if (version == 'PO Open') {
                        amount = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_Total_Dummy__c : lineItem.ASI_CRM_CN_Est_Total_Dummy__c);
                    }

                    if (lineItem.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && lineItem.ASI_CRM_CN_Sub_Brand__c == subBrandId) {
                        if (version == 'PO Open') {
                            tradeExpense += amount;
                        }
                        if (version == 'PO Modi') {
                            tradeExpense = data.volumeSTD * lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                        }
                    }
                    if (lineItem.ASI_CRM_Volume_Base__c == 'By Grade' && lineItem.ASI_CRM_Sub_Brand_Grade__c == data.gradeId) {
                        if (version == 'PO Open') {
                            tradeExpense += amount * data.propByGrade;
                        }
                        if (version == 'PO Modi') {
                            incentivePerCR12 = lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c != 0? lineItem.ASI_CRM_CN_Est_Total_Dummy__c / lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c : 0;
                            tradeExpense = data.volumeCR12 * incentivePerCR12;
                        }
                    }
                    if (lineItem.ASI_CRM_Volume_Base__c == 'By Category' && lineItem.ASI_CRM_Product_Category__c == data.categoryId) {
                        if (version == 'PO Open') {
                            tradeExpense += amount * data.propByCategory;
                        }
                        if (version == 'PO Modi') {
                            incentivePerCR12 = lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c != 0? lineItem.ASI_CRM_CN_Est_Total_Dummy__c / lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c : 0;
                            tradeExpense = data.volumeCR12 * incentivePerCR12;
                        }
                    }
                    if (lineItem.ASI_CRM_Volume_Base__c == 'By Total') {
                        if (version == 'PO Open') {
                            tradeExpense += amount * data.propByTotal;
                        }
                        if (version == 'PO Modi') {
                            incentivePerCR12 = lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c != 0? lineItem.ASI_CRM_CN_Est_Total_Dummy__c / lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c : 0;
                            tradeExpense = data.volumeCR12 * incentivePerCR12;
                        }
                    }
                }
                if (module.ASI_CRM_Line_Type__c == 'PSF') {
                    ModuleTradeExpense moduleData = new ModuleTradeExpense(module);
                    moduleData.amount = tradeExpense.setScale(4);
                    moduleData.incentivePerCR12 = incentivePerCR12.setScale(4);
                    data.tradeExpenseByPSFModule.add(moduleData);
                }
                // BUG: VEC module doesn't have line type, so I have to use AC Code to know it is VEC
                if (module.ASI_CRM_Line_Type__c == 'Variable Event Cost' || (module.ASI_CRM_CN_AC_Code__c != null && module.ASI_CRM_CN_AC_Code__r.Name.contains('Variable Event Cost'))) {
                    data.VECAmount += tradeExpense.setScale(4);
                }

            }
            if (version == 'Last Payment') {
                Map<String, Decimal> totalCTDPayableAmountByPSFModule = new Map<String, Decimal>();
                Map<String, ModuleTradeExpense> tradeExpenseByPSFModule = new Map<String, ModuleTradeExpense>();

                // Construct totalCTDPayableAmountByPSFModule
                for (ASI_TH_CRM_PaymentRequest__c lastPayment : lastPayments) {
                    for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : lastPayment.ASI_TH_CRM_PRLI_PaymentRequest__r) {
                        Decimal sum = denullify(totalCTDPayableAmountByPSFModule.get(lineItem.ASI_CRM_Module__c));
                        totalCTDPayableAmountByPSFModule.put(lineItem.ASI_CRM_Module__c, sum + denullify(lineItem.ASI_CRM_CN_Total_Payable__c));
                    }
                }

                for (ASI_TH_CRM_PaymentRequest__c lastPayment : lastPayments) {
                    for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : lastPayment.ASI_TH_CRM_PRLI_PaymentRequest__r) {
                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && lineItem.ASI_CRM_CN_Sub_Brand__c != subBrandId) {
                            continue;
                        }
                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Grade' && lineItem.ASI_CRM_Sub_Brand_Grade__c != data.gradeId) {
                            continue;
                        }
                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Category' && lineItem.ASI_CRM_Product_Category__c != data.categoryId) {
                            continue;
                        }

                        Decimal tradeExpense = 0;

                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && lineItem.ASI_CRM_CN_Sub_Brand__c == subBrandId) {
                            tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c);
                        }
                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Grade' && lineItem.ASI_CRM_Sub_Brand_Grade__c == data.gradeId) {
                            tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c) * denullify(data.propByGrade, 1);
                        }
                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Category' && lineItem.ASI_CRM_Product_Category__c == data.categoryId) {
                            tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c) * denullify(data.propByCategory, 1);
                        }
                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Total') {
                            tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c) * denullify(data.propByTotal, 1);
                        }

                        if (lineItem.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_PSF') {
                            ModuleTradeExpense moduleData = tradeExpenseByPSFModule.containsKey(lineItem.ASI_CRM_Module__c) ? tradeExpenseByPSFModule.get(lineItem.ASI_CRM_Module__c) : new ModuleTradeExpense(lineItem.ASI_CRM_Module__r);

                            moduleData.amount = tradeExpense.setScale(4);
                            moduleData.totalCTDPayableAmount = totalCTDPayableAmountByPSFModule.get(lineItem.ASI_CRM_Module__c);
                            tradeExpenseByPSFModule.put(lineItem.ASI_CRM_Module__c, moduleData);
                        }
                        if (lineItem.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_VEC') {
                            data.VECAmount += tradeExpense.setScale(4);
                        }

                    }
                }

                data.tradeExpenseByPSFModule = tradeExpenseByPSFModule.values();
            }

        }

        // Sum of all Trade expenses
        Map<String, Decimal> totalPSFAmountByPSFModule = new Map<String, Decimal>();
        for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
            TradeExpenseBreakdown data = TradeExpenseBySubBrand.get(subBrandId);
            totalBRSFAmount += data.BRSFAmount;
            totalPSFAmount += data.PSFTradeExpense;
            for (ModuleTradeExpense moduleTradeExpense : data.tradeExpenseByPSFModule) {
                Decimal sum = denullify(totalPSFAmountByPSFModule.get(moduleTradeExpense.moduleId));
                totalPSFAmountByPSFModule.put(moduleTradeExpense.moduleId, sum + moduleTradeExpense.amount);
            }
            System.debug(LoggingLevel.INFO, '*** data: ' + data);
            totalVECAmount += data.VECAmount;
        }
        System.debug(LoggingLevel.INFO, '*** totalVECAmount: ' + totalVECAmount);

        // Gap calculation.
        for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
            TradeExpenseBreakdown data = TradeExpenseBySubBrand.get(subBrandId);
            data.propByBRSFAmt = totalBRSFAmount != 0? data.BRSFAmount / totalBRSFAmount : 1;
            data.propByBRSFAmt = data.propByBRSFAmt.setScale(6);

            // In PO Open, gap is always zero.
            if (version == 'PO Open') {
                data.BRSFGap = 0;
                data.PSFGap = 0;
                data.VECGap = 0;
            }
            // Gap = (inputByUser - calculatedTradeExpense) * proportionOverTotalTradeExpense
            if (version == 'PO Modi') {
                data.BRSFGap = (totalBRSFAmountFromInput - totalBRSFAmount) * data.propByBRSFAmt;
                data.PSFGap = totalPSFAmount != 0? (totalPSFAmountFromInput - totalPSFAmount) * data.PSFTradeExpense / totalPSFAmount : 0;
                data.VECGap = totalVECAmount != 0? (totalVECAmountFromInput - totalVECAmount) * data.VECAmount / totalVECAmount : 0;
            }
            // In last Payment, PSF Gap is stored in tradeExpenseByPSFModule, not the overall PSFGap
            if (version == 'Last Payment') {
                data.BRSFGap = (historicalBRSFPaymentSum + totalBRSFAmountFromInput - totalBRSFAmount) * data.propByBRSFAmt;
                data.PSFGap = 0;
                for (ModuleTradeExpense moduleTradeExpense : data.tradeExpenseByPSFModule) {
                    moduleTradeExpense.gap = totalPSFAmountByPSFModule.get(moduleTradeExpense.moduleId) != 0 ? ((moduleTradeExpense.historicalPaidAmount + moduleTradeExpense.actualPayment - moduleTradeExpense.totalCTDPayableAmount) * moduleTradeExpense.amount / totalPSFAmountByPSFModule.get(moduleTradeExpense.moduleId)).setScale(4) : 0;
                }
                data.VECGap = totalVECAmount != 0? (historicalVECPaymentSum + totalVECAmountFromInput - totalVECAmount) * data.VECAmount / totalVECAmount : 0;
            }

            if (version == 'PO Modi' || version == 'Last Payment') {
                data.BRSFGap = data.BRSFGap.setScale(4);
                data.PSFGap = data.PSFGap.setScale(4);
                data.VECGap = data.VECGap.setScale(4);
            }
        }


        // PO Open and Modi will calculate fix cost from contract cost object, whereas Last Payment will calculate from payment request line
        if (version == 'PO Open' || version == 'PO Modi') {
            List<AggregateResult> fixCosts = [
                SELECT SUM(ASI_CRM_CN_Contract_Amount__c) contract, SUM(ASI_CRM_CN_Estimate_Amount__c) estimate
                FROM ASI_CRM_Contract_Cost__c
                WHERE ASI_CRM_CN_Contract__c = :contract.Id
            ];

            for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
                TradeExpenseBreakdown data = TradeExpenseBySubBrand.get(subBrandId);
                data.fixCostTradeExpense = denullify((Decimal) fixCosts[0].get(contractOrEstimate)) * data.propByTotal;
                data.fixCostTradeExpense = data.fixCostTradeExpense.setScale(3);
            }
        }

        // Remove any nonContract and zero volume data
        for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
            TradeExpenseBreakdown data = TradeExpenseBySubBrand.get(subBrandId);
            if (data.nonContract && data.volumeSTD == 0) {
                TradeExpenseBySubBrand.remove(subBrandId);
            }
        }


        return TradeExpenseBySubBrand.values();
    }

    public static List<TradeExpenseBreakdown2nd> constructTradeExpenseBySubBrand2nd(ASI_TH_CRM_Contract__c contract, String contractOrEstimate, String version) {
        System.debug(LoggingLevel.INFO, '*** contract: ' + contract);
        Map<String, TradeExpenseBreakdown2nd> TradeExpenseBySubBrand = new Map<String, TradeExpenseBreakdown2nd>();
        Map<String, Decimal> totalVolumeByGrade = new Map<String, Decimal>();
        Map<String, Decimal> totalVolumeByCategory = new Map<String, Decimal>();
        Map<String, Decimal> totalStdVolumeByGrade = new Map<String, Decimal>();
        Decimal totalVolume = 0;
        Decimal totalStdVolume = 0;
        Decimal totalEstVariableAmount = 0;
        Decimal totalBRSFAmountFromInput = denullify(contract.ASI_CRM_CN_Expected_BRSF_Est_Total__c);
        Decimal totalPSFAmountFromInput = denullify(contract.ASI_CRM_CN_Expected_PSF_Est_Total__c);
        Decimal totalVECAmountFromInput = denullify(contract.ASI_CRM_EVC_Cost_Estimate_Total__c);
        

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFLines = retrieveBRSFLines(contract, new List<String>{
            'BRSF'
        }, true);

        Map<Id, ASI_CRM_CN_Contract_BRSF_Line_Item__c> subBrandBRSFLineMap = new Map<Id, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine : BRSFLines){
            subBrandBRSFLineMap.put(BRSFLine.ASI_CRM_CN_Sub_Brand__c, BRSFLine);
            totalEstVariableAmount += denullify(BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c);
        }

        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap = new Map<String, ASI_CRM_Sub_Brand_Grade__c>();
        for (ASI_CRM_Sub_Brand_Grade__c sbg : GeneratingSubBrandGrade(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c)) {
            if (sbg.ASI_CRM_CN_City_Tier__c != null) {
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c + CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }
            SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
        }

        if (version == 'PO Modi' || version == 'PO Open') {
            
            // Use BRSF line as Trade expense calculation if PO OPen or no volume at all
            // if (version == 'PO Modi' || version == 'PO Open' || volumes.isEmpty()) {
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : BRSFLines) {
                TradeExpenseBreakdown2nd data = TradeExpenseBySubBrand.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)? TradeExpenseBySubBrand.get(lineItem.ASI_CRM_CN_Sub_Brand__c) : new TradeExpenseBreakdown2nd(lineItem);
                data.nonContract = false;

                // If no Sub-Brand volume, take contract value
                if (!TradeExpenseBySubBrand.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)) {
                    data.volumeSTD = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c : lineItem.ASI_CRM_CN_Est_Monthly_Qty__c) * contract.ASI_CRM_CN_No_of_Months__c;
                    data.monthlyVolumeSTD = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c : lineItem.ASI_CRM_CN_Est_Monthly_Qty__c);
                }
                data.BRSFIncentive = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c : lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c);
                data.BRSFPerTradeExpense = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c : lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c);
                data.BRSFAmount = (data.volumeSTD * data.BRSFIncentive).setScale(4);

                TradeExpenseBySubBrand.put(lineItem.ASI_CRM_CN_Sub_Brand__c, data);
            }
            // }

            for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
                TradeExpenseBreakdown2nd data = TradeExpenseBySubBrand.get(subBrandId);
                if (totalVolumeByGrade.containsKey(data.gradeId)) {
                    totalVolumeByGrade.put(data.gradeId, totalVolumeByGrade.get(data.gradeId) + data.volumeCR12);
                } else {
                    totalVolumeByGrade.put(data.gradeId, data.volumeCR12);
                }

                if (totalStdVolumeByGrade.containsKey(data.gradeId)) {
                    totalStdVolumeByGrade.put(data.gradeId, totalStdVolumeByGrade.get(data.gradeId) + data.volumeSTD);
                } else {
                    totalStdVolumeByGrade.put(data.gradeId, data.volumeSTD);
                }

                if (totalVolumeByCategory.containsKey(data.categoryId)) {
                    totalVolumeByCategory.put(data.categoryId, totalVolumeByCategory.get(data.categoryId) + data.volumeCR12);
                } else {
                    totalVolumeByCategory.put(data.categoryId, data.volumeCR12);
                }
                
                totalVolume += data.volumeCR12;
                totalStdVolume += data.volumeSTD;
            }
            for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
                TradeExpenseBreakdown2nd data = TradeExpenseBySubBrand.get(subBrandId);

                data.propByGrade = totalVolumeByGrade.get(data.gradeId) != 0? data.volumeCR12 / totalVolumeByGrade.get(data.gradeId) : 1;
                data.propByCategory = totalVolumeByCategory.get(data.categoryId) != 0? data.volumeCR12 / totalVolumeByCategory.get(data.categoryId) : 1;
                data.propByTotal = totalVolume != 0? data.volumeCR12 / totalVolume : 1;
                data.propByStdTotal = totalStdVolume != 0? data.volumeSTD / totalStdVolume : 1;

                data.propByGrade = data.propByGrade.setScale(8);
                data.propByCategory = data.propByCategory.setScale(8);
                data.propByTotal = data.propByTotal.setScale(8);
                data.propByStdTotal = data.propByStdTotal.setScale(8);
            }

            List<ASI_CRM_Module__c> modules = new List<ASI_CRM_Module__c>();
            Map<String, List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>> moduleLineItemMap = new Map<String, List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>>();

            if (version == 'PO Modi') {
                modules = retrieveModulesAndLines(contract, new List<String>{
                    'PSF', 'Variable Event Cost', 'Fixed'
                });
                for (ASI_CRM_Module__c module : modules) {
                    moduleLineItemMap.put(module.Id, module.Contract_BRSF_Line_Item__r);
                }
            }
            else if (version == 'PO Open') {
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> otherLines = retrieveBRSFLines(contract, new List<String>{
                'PSF', 'Variable Event Cost', 'Fixed'
                }, true);
                Map<String, ASI_CRM_Module__c> moduleMap = new Map<String, ASI_CRM_Module__c>();
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : otherLines) {
                    if (!moduleMap.containsKey(line.ASI_CRM_Module__c)) {
                        ASI_CRM_Module__c module = line.ASI_CRM_Module__r;
                        System.debug(LoggingLevel.INFO, '*** module: ' + module);
                        moduleMap.put(line.ASI_CRM_Module__c, module);
                        moduleLineItemMap.put(line.ASI_CRM_Module__c, new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>());
                    }
                    moduleLineItemMap.get(line.ASI_CRM_Module__c).add(line);
                }
                modules = moduleMap.values();
            }
            System.debug(LoggingLevel.INFO, '*** modules: ' + modules);

            Map<String,ASI_CRM_CN_FixedMappingSetting__c> settingMap = ASI_CRM_CN_FixedMappingSetting__c.getAll();

            Map<String, Decimal> moduleEstAmountMap = new Map<String, Decimal>();
            for (ASI_CRM_Module__c module : modules) {
                Decimal totalEstAmount = 0;
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : moduleLineItemMap.get(module.Id)) {
                    totalEstAmount += lineItem.ASI_CRM_CN_Est_Total_Dummy__c != null?lineItem.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    if (module.ASI_CRM_Line_Type__c != 'Fixed' && lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c != '999') {
                        System.debug(LoggingLevel.INFO, '*** lineItem.ASI_CRM_CN_Est_Total_Dummy__c: ' + lineItem.ASI_CRM_CN_Est_Total_Dummy__c);
                        totalEstVariableAmount += denullify(lineItem.ASI_CRM_CN_Est_Total_Dummy__c);
                    }
                }
                moduleEstAmountMap.put(module.id, totalEstAmount);
            }
            System.debug(LoggingLevel.INFO, '*** moduleEstAmountMap: ' + moduleEstAmountMap);

            for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
                TradeExpenseBreakdown2nd data = TradeExpenseBySubBrand.get(subBrandId);
                for (ASI_CRM_Module__c module : modules) {
                    System.debug(LoggingLevel.INFO, '*** module: ' + module);
                    if (moduleLineItemMap.get(module.Id) == null || moduleLineItemMap.get(module.Id).isEmpty()) {
                        continue;
                    }
                    System.debug(LoggingLevel.INFO, '*** module.Contract_BRSF_Line_Item__r: ' + module.Contract_BRSF_Line_Item__r);
                    Decimal amount = 0;
                    Decimal lineValumeCR12 = 0;
                    Decimal perBottleFee=0;

                    Decimal tradeExpensePerBottle = 0;
                    Decimal tradeExpense = 0;
                    Decimal incentivePerCR12 = 0;

                    // For non contract sub-brand, its By Sub-Brand trade expense depends on Payment incentive
                    // if (data.nonContract && module.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                    //     tradeExpense = data.volumeSTD * denullify(incentiveBySubBrandByModule.get(data.subBrandId + module.Id));
                    // }
                    if (module.ASI_CRM_Line_Type__c == 'Variable Event Cost' || (module.ASI_CRM_CN_AC_Code__c != null && module.ASI_CRM_CN_AC_Code__r.Name.contains('Variable Event Cost')) || module.ASI_CRM_Line_Type__c == 'PSF')
                    {
                        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : moduleLineItemMap.get(module.Id)) {
                            
                            amount = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_Total_Dummy__c : lineItem.ASI_CRM_CN_Est_Total_Dummy__c);
                            lineValumeCR12 = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c : lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                            perBottleFee = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c : lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c);

                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && lineItem.ASI_CRM_CN_Sub_Brand__c == subBrandId) {
                                tradeExpense += amount;
                                tradeExpensePerBottle += perBottleFee;
                            }
                            else if (lineItem.ASI_CRM_Volume_Base__c == 'By Grade' && lineItem.ASI_CRM_Sub_Brand_Grade__c == data.gradeId) {
                                incentivePerCR12 += lineValumeCR12 != 0? amount / lineValumeCR12 : 0;
                                tradeExpense += data.volumeCR12 * incentivePerCR12;
                                tradeExpensePerBottle += incentivePerCR12 * data.cr12Factor;
                            }
                            else if (lineItem.ASI_CRM_Volume_Base__c == 'By Category' && lineItem.ASI_CRM_Product_Category__c == data.categoryId) {
                                incentivePerCR12 = lineValumeCR12 != 0? amount / lineValumeCR12 : 0;
                                tradeExpense = data.volumeCR12 * incentivePerCR12;
                                tradeExpensePerBottle = incentivePerCR12 * data.cr12Factor;
                            }
                            else if (lineItem.ASI_CRM_Volume_Base__c == 'By Total') {
                                incentivePerCR12 = lineValumeCR12 != 0? amount / lineValumeCR12 : 0;
                                tradeExpense = data.volumeCR12 * incentivePerCR12;
                                tradeExpensePerBottle = incentivePerCR12 * data.cr12Factor;
                            }
                        }
                        if (module.ASI_CRM_Line_Type__c == 'PSF') {
                            ModuleTradeExpense moduleData = new ModuleTradeExpense(module);
                            moduleData.amount = tradeExpense.setScale(4);
                            moduleData.incentivePerCR12 = incentivePerCR12.setScale(4);
                            moduleData.incentivePer = tradeExpensePerBottle.setScale(4);
                            data.tradeExpenseByPSFModule.add(moduleData);
                            data.PSFAmount += tradeExpense.setScale(4);
                            data.PSFPerTradeExpense += tradeExpensePerBottle.setScale(4);
                        }
                        // BUG: VEC module doesn't have line type, so I have to use AC Code to know it is VEC
                        if (module.ASI_CRM_Line_Type__c == 'Variable Event Cost' || (module.ASI_CRM_CN_AC_Code__c != null && module.ASI_CRM_CN_AC_Code__r.Name.contains('Variable Event Cost'))) {
                            data.VECAmount += tradeExpense.setScale(4);
                            data.VECPerTradeExpense += tradeExpensePerBottle.setScale(4);
                        }
                    }
                    else if (module.ASI_CRM_Line_Type__c == 'Fixed')
                    {
                        Decimal moduleTotalAmount = moduleEstAmountMap.get(module.id);
                        Decimal moduleTotalExpectedAmount = 0;
                        if (settingMap.containsKey(module.ASI_CRM_CN_AC_Code__c)) {
                            System.debug(LoggingLevel.INFO, '*** settingMap.get(module.ASI_CRM_CN_AC_Code__c).ASI_CRM_CN_Contract_Mapping_Field__c: ' + settingMap.get(module.ASI_CRM_CN_AC_Code__c).ASI_CRM_CN_Contract_Mapping_Field__c);
                            moduleTotalExpectedAmount = contract.get(settingMap.get(module.ASI_CRM_CN_AC_Code__c).ASI_CRM_CN_Contract_Mapping_Field__c) != null ? Decimal.valueOf(String.valueOf(contract.get(settingMap.get(module.ASI_CRM_CN_AC_Code__c).ASI_CRM_CN_Contract_Mapping_Field__c))):0;
                        }
                        System.debug(LoggingLevel.INFO, '*** moduleTotalAmount: ' + moduleTotalAmount);
                        System.debug(LoggingLevel.INFO, '*** moduleTotalExpectedAmount: ' + moduleTotalExpectedAmount);
                        

                        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : moduleLineItemMap.get(module.Id)) {
                            
                            if (version == 'PO Open') {
                                amount = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_Total_Dummy__c : lineItem.ASI_CRM_CN_Est_Total_Dummy__c);
                                lineValumeCR12 = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c : lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c);
                                perBottleFee = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c : lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c);
                            }

                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && lineItem.ASI_CRM_CN_Sub_Brand__c == subBrandId) {
                                if (version == 'PO Open') {
                                    tradeExpense += amount;
                                    tradeExpensePerBottle += perBottleFee;
                                }
                                if (version == 'PO Modi') {
                                    if (moduleTotalAmount == 0)
                                    {
                                        continue;
                                    }
                                    tradeExpense += lineItem.ASI_CRM_CN_Est_Total_Dummy__c/moduleTotalAmount * moduleTotalExpectedAmount;
                                    tradeExpensePerBottle += (data.volumeSTD!=0?lineItem.ASI_CRM_CN_Est_Total_Dummy__c/moduleTotalAmount * moduleTotalExpectedAmount/data.volumeSTD:0);
                                }
                            }
                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Grade' && lineItem.ASI_CRM_Sub_Brand_Grade__c == data.gradeId) {
                                if (version == 'PO Open') {
                                    tradeExpense += amount * data.propByGrade;
                                    tradeExpensePerBottle += (lineValumeCR12!=0?amount/lineValumeCR12 * data.cr12Factor:0);
                                }
                                if (version == 'PO Modi') {
                                    if (moduleTotalAmount == 0)
                                    {
                                        continue;
                                    }
                                    incentivePerCR12 = lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c != 0? lineItem.ASI_CRM_CN_Est_Total_Dummy__c / moduleTotalAmount * moduleTotalExpectedAmount / lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c : 0;
                                    tradeExpense += data.volumeCR12 * incentivePerCR12;
                                    tradeExpensePerBottle += incentivePerCR12 * data.cr12Factor;
                                }
                            }
                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Category' && lineItem.ASI_CRM_Product_Category__c == data.categoryId) {
                                if (version == 'PO Open') {
                                    tradeExpense += amount * data.propByCategory;
                                    tradeExpensePerBottle += (lineValumeCR12!=0?amount/lineValumeCR12 * data.cr12Factor:0);
                                }
                                if (version == 'PO Modi') {
                                    if (moduleTotalAmount == 0)
                                    {
                                        continue;
                                    }
                                    incentivePerCR12 = lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c != 0? lineItem.ASI_CRM_CN_Est_Total_Dummy__c / moduleTotalAmount * moduleTotalExpectedAmount / lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c : 0;
                                    tradeExpense += data.volumeCR12 * incentivePerCR12;
                                    tradeExpensePerBottle += incentivePerCR12 * data.cr12Factor;
                                }
                            }
                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Total') {
                                if (version == 'PO Open') {
                                    tradeExpense += amount * data.propByTotal;
                                    tradeExpensePerBottle += (lineValumeCR12!=0?amount/lineValumeCR12 * data.cr12Factor:0);
                                }
                                if (version == 'PO Modi') {
                                    if (moduleTotalAmount == 0)
                                    {
                                        continue;
                                    }
                                    incentivePerCR12 = lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c != 0? lineItem.ASI_CRM_CN_Est_Total_Dummy__c / moduleTotalAmount * moduleTotalExpectedAmount / lineItem.ASI_CRM_Est_Total_QTY_CR12_Eqv__c : 0;
                                    tradeExpense += data.volumeCR12 * incentivePerCR12;
                                    tradeExpensePerBottle += incentivePerCR12 * data.cr12Factor;
                                }
                            }
                        }

                        ModuleTradeExpense moduleData = new ModuleTradeExpense(module);
                        moduleData.amount = tradeExpense.setScale(4);
                        moduleData.incentivePerCR12 = incentivePerCR12.setScale(4);
                        moduleData.incentivePer = tradeExpensePerBottle.setScale(4);
                        data.tradeExpenseByFXModule.add(moduleData);
                        data.fixCostTradeExpense += tradeExpense.setScale(4);
                        data.fixCostPerTradeExpense += tradeExpensePerBottle.setScale(4);

                    }

                }
            }

            // Sum of all Trade expenses
            

            // Gap calculation.
            if (version == 'PO Modi') {
                System.debug(LoggingLevel.INFO, '*** : totalBRSFAmountFromInput + totalPSFAmountFromInput + totalVECAmountFromInput' + (totalBRSFAmountFromInput + totalPSFAmountFromInput + totalVECAmountFromInput));
                System.debug(LoggingLevel.INFO, '*** : totalEstVariableAmount' + totalEstVariableAmount);
                
                Decimal totalGapAmount = totalBRSFAmountFromInput + totalPSFAmountFromInput + totalVECAmountFromInput - totalEstVariableAmount;
                if (totalGapAmount != 0)
                {
                    ASI_MFM_Sub_brand__c subbrand999 = [SELECT Id,Name,ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
                                                            ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.name,  ASI_MFM_Sub_brand_Code__c,
                                                            ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.Name
                                                            FROM ASI_MFM_Sub_brand__c 
                                                            WHERE ASI_MFM_Active_for_CRM__c = true  AND 
                                                            ASI_MFM_Sub_brand_Code__c = '999'  AND 
                                                            recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1];
                    TradeExpenseBreakdown2nd data = new TradeExpenseBreakdown2nd();
                    data.subBrandId = subbrand999.Id;
                    data.subBrandCode = subbrand999.ASI_MFM_Sub_brand_Code__c;
                    data.subBrandName = subbrand999.Name;
                    data.gradeId = subbrand999.ASI_CRM_CN_Sub_brand_Grade__c;
                    data.gradeName = subbrand999.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    data.categoryId = subbrand999.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
                    data.categoryName = subbrand999.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    data.BRSFAmount = totalGapAmount;
                    data.totalTradeExpense = totalGapAmount;
                    TradeExpenseBySubBrand.put(subbrand999.Id, data);
                }
            }
        } else if (version == 'Last Payment') {
            // Get Historical Payment, Must use PO number rather than Id because historical contract has no payment
            // List<ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentList = [
            //     SELECT
            //         Id,ASI_TH_CRM_Payment_Request__c,ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Incentive_BT__c
            //     FROM ASI_TH_CRM_PaymentRequestLineItem__c
            //     WHERE ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_No__c = :contract.ASI_CRM_CN_PO_No__c
            //     AND RecordType.DeveloperName = :'ASI_CRM_CN_Payment_Request_Detail_BRSF'
            //     ORDER BY ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_Version__c
            // ];
            // Map<String, Decimal> HistoricalPaymentIncentiveBySubBrand = new Map<String, Decimal>();
            // for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : HistoricalPaymentList) {
            //     HistoricalPaymentIncentiveBySubBrand.put(lineItem.ASI_CRM_CN_Sub_Brand__c, lineItem.ASI_CRM_CN_Incentive_BT__c);
            // }

            List<ASI_TH_CRM_PaymentRequest__c> lastPayments = [
                SELECT
                    Id,Name,ASI_TH_CRM_Status__c,
                (SELECT
                    Id,ASI_CRM_Line_Type__c, ASI_CRM_Volume_Base__c, ASI_CRM_Historical_Paid_Amount__c, ASI_CRM_Actual_Payment__c
                FROM ASI_CRM_Modules__r),
                (SELECT
                    Id, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_Product_Category__c, ASI_CRM_Module__c,ASI_TH_CRM_Amount__c,
                    ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                    ASI_CRM_Module__r.ASI_CRM_Historical_Paid_Amount__c,
                    ASI_CRM_Module__r.ASI_CRM_Actual_Payment__c,
                    ASI_CRM_Module__r.ASI_CRM_Application_Payment_Amount__c,
                    ASI_CRM_Module__r.ASI_CRM_Line_Type__c,
                    ASI_CRM_Volume_Base__c, ASI_CRM_CN_Total_Payable__c, RecordType.DeveloperName,
                    ASI_CRM_CN_Incentive_BT__c,ASI_CRM_V0_0_Full_Contract_Target__c,ASI_CRM_CN_Actual_Vol__c,
                    ASI_CRM_CTD_Actual_Vol__c,ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,
                    ASI_CRM_CN_Sub_brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                    ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c
                FROM ASI_TH_CRM_PRLI_PaymentRequest__r)
                FROM ASI_TH_CRM_PaymentRequest__c
                WHERE ASI_CRM_CN_PO_No__c = :contract.ASI_CRM_CN_PO_No__c
                AND ASI_CRM_CN_Last_Payment__c = TRUE
            ];
            //Decimal historicalBRSFPaymentSum = 0;
            //Decimal historicalVECPaymentSum = 0;
            Decimal totalActualPayment = 0;
            Decimal totalPayableAmount = 0;
            Map<String, Decimal> moduleActualPaymentMap = new Map<String, Decimal>();
            Map<String, Decimal> modulePayablePaymentMap = new Map<String, Decimal>();
            for (ASI_TH_CRM_PaymentRequest__c lastPayment : lastPayments) {
                System.debug(LoggingLevel.INFO, '*** lastPayment: ' + lastPayment);
                for (ASI_CRM_Module__c module : lastPayment.ASI_CRM_Modules__r) {
                    Decimal moduleActualPayment = 0;

                    moduleActualPayment += module.ASI_CRM_Historical_Paid_Amount__c !=  null?module.ASI_CRM_Historical_Paid_Amount__c : 0;
                    moduleActualPayment += module.ASI_CRM_Actual_Payment__c !=  null?module.ASI_CRM_Actual_Payment__c : 0;
                    moduleActualPaymentMap.put(module.Id, moduleActualPayment);
                    if (module.ASI_CRM_Line_Type__c != 'Fixed') {
                        totalActualPayment += moduleActualPayment;
                    }
                }
                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : lastPayment.ASI_TH_CRM_PRLI_PaymentRequest__r) {
                    System.debug(LoggingLevel.INFO, '*** lineItem: ' + lineItem);
                    if (lineItem.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_BRSF') {
                        TradeExpenseBreakdown2nd data = TradeExpenseBySubBrand.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)? TradeExpenseBySubBrand.get(lineItem.ASI_CRM_CN_Sub_Brand__c) : new TradeExpenseBreakdown2nd(lineItem);
                        data.BRSFAmount = lineItem.ASI_CRM_CN_Total_Payable__c != null ?lineItem.ASI_CRM_CN_Total_Payable__c:0;
                        data.BRSFIncentive = lineItem.ASI_CRM_CN_Incentive_BT__c != null ?lineItem.ASI_CRM_CN_Incentive_BT__c:0;
                        data.BRSFPerTradeExpense = data.BRSFIncentive;
                        if (!TradeExpenseBySubBrand.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)) {
                            data.volumeSTD = lineItem.ASI_CRM_CN_Actual_Vol__c;
                        }
                        TradeExpenseBySubBrand.put(lineItem.ASI_CRM_CN_Sub_Brand__c, data);
                    }

                    Decimal payablePayment = lineItem.ASI_CRM_CN_Total_Payable__c != null ?lineItem.ASI_CRM_CN_Total_Payable__c:0;
                    if (lineItem.ASI_CRM_Module__r.ASI_CRM_Line_Type__c != 'Fixed') {
                        totalPayableAmount += payablePayment;
                    } 

                    if (modulePayablePaymentMap.containsKey(lineItem.ASI_CRM_Module__c))
                    {
                        payablePayment += modulePayablePaymentMap.get(lineItem.ASI_CRM_Module__c);
                    }
                    modulePayablePaymentMap.put(lineItem.ASI_CRM_Module__c,payablePayment);  
                }
            }


            System.debug(LoggingLevel.INFO, '*** moduleActualPaymentMap: ' + moduleActualPaymentMap);
            System.debug(LoggingLevel.INFO, '*** modulePayablePaymentMap: ' + modulePayablePaymentMap);

            // List<ASI_CRM_Subbrand_Volume__c> volumes = retrieveSubBrandVolumes(contract);

            // // Calculate CTD Volume and project to the whole period
            // for (ASI_CRM_Subbrand_Volume__c subBrandVolume : volumes) {
            //     TradeExpenseBreakdown data = TradeExpenseBySubBrand.containsKey(subBrandVolume.ASI_CRM_Subbrand__c)? TradeExpenseBySubBrand.get(subBrandVolume.ASI_CRM_Subbrand__c) : new TradeExpenseBreakdown(subBrandVolume);
            //     data.volumeSTD += getVolume(subBrandVolume, 'std');
            //     TradeExpenseBySubBrand.put(subBrandVolume.ASI_CRM_Subbrand__c, data);
            // }
            // Project to the whole period
            // for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
            //     TradeExpenseBreakdown data = TradeExpenseBySubBrand.get(subBrandId);
            //     // Not contract Sub-Brand will get incentive from payment, if no payment, take default value
            //     if (data.nonContract) {
            //         Decimal defaultIncentive = 0;
            //         String ExternalKey = data.gradeName;

            //         ExternalKey += contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c != null? contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c : '';
            //         ExternalKey += contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c != null? contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c : '';

            //         String CityTierExternalKey = ExternalKey;
            //         if (contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c != null && contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c != null) {
            //             CityTierExternalKey += ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
            //         }

            //         if (SubBrandGradeMap.containsKey(CityTierExternalKey)) {
            //             defaultIncentive = SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive__c;
            //         } else if (SubBrandGradeMap.containsKey(ExternalKey)) {
            //             defaultIncentive = SubBrandGradeMap.get(ExternalKey).ASI_CRM_CN_Incentive__c;
            //         } else if (SubBrandGradeMap.containsKey(data.gradeName)) {
            //             defaultIncentive = SubBrandGradeMap.get(data.gradeName).ASI_CRM_CN_Incentive__c;
            //         }
            //         //LS-194: Logic Change
            //         //  Old logic: If no historical payment, use Default
            //         //  New logic:  If no historical payment, use Contract data
            //         //              If no Contract data, use default
            //         // data.BRSFIncentive = HistoricalPaymentIncentiveBySubBrand.containsKey(subBrandId)? HistoricalPaymentIncentiveBySubBrand.get(subBrandId) : defaultIncentive;
            //         if (HistoricalPaymentIncentiveBySubBrand.containsKey(subBrandId)){
            //             data.BRSFIncentive = HistoricalPaymentIncentiveBySubBrand.get(subBrandId);
            //         } else {
            //             if (subBrandBRSFLineMap.containsKey(subBrandId)){
            //                 ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem = subBrandBRSFLineMap.get(subBrandId);
            //                 data.BRSFIncentive = denullify(contractOrEstimate == 'contract'? lineItem.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c : lineItem.ASI_CRM_CN_Est_BRSF_Per_Bottle__c);
            //             }
            //             if (data.BRSFIncentive == null || data.BRSFIncentive == 0){
            //                 data.BRSFIncentive = defaultIncentive;
            //             }
            //         }
            //     }
            //     data.volumeSTD = projectVolume(data.volumeSTD, contract).setScale(4);
            //     data.BRSFAmount = data.volumeSTD * data.BRSFIncentive.setScale(4);
            //     data.BRSFPerTradeExpense = data.BRSFIncentive;
            //     TradeExpenseBySubBrand.put(subBrandId, data);
            // }

            // Get Payment Request Line, use its CTD Payable Amount as BRSF Amount
            
            // for (ASI_TH_CRM_PaymentRequest__c lastPayment : lastPayments) {
            //     for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : lastPayment.ASI_TH_CRM_PRLI_PaymentRequest__r) {
            //         if (lineItem.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_BRSF' && TradeExpenseBySubBrand.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)) {
            //             TradeExpenseBySubBrand.get(lineItem.ASI_CRM_CN_Sub_Brand__c).BRSFAmount = denullify(lineItem.ASI_CRM_CN_Total_Payable__c);
            //         }

            //     }
            // }

            // Key: sub-brandId + contractModuleId, value: incentive from Payment request line
            // Map<String, Decimal> incentiveBySubBrandByModule = new Map<String, Decimal>();

            // List<ASI_TH_CRM_PaymentRequest__c> latestPayments = [
            //     SELECT
            //         Id,Name,ASI_TH_CRM_Status__c,
            //     (SELECT
            //         Id, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_Product_Category__c, ASI_CRM_CN_Incentive_BT__c,
            //         ASI_CRM_Module__c,
            //         ASI_CRM_Module__r.ASI_CRM_Parent_Module__c
            //     FROM ASI_TH_CRM_PRLI_PaymentRequest__r
            //     WHERE ASI_CRM_Module__r.ASI_CRM_Volume_Base__c = 'By Sub-Brand')
            //     FROM ASI_TH_CRM_PaymentRequest__c
            //     WHERE ASI_CRM_CN_PO_No__c = :contract.ASI_CRM_CN_PO_No__c
            //     ORDER BY Name DESC
            //     LIMIT 1
            // ];
            // if (latestPayments.size() > 0) {
            //     for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : latestPayments[0].ASI_TH_CRM_PRLI_PaymentRequest__r) {
            //         incentiveBySubBrandByModule.put(String.valueOf(lineItem.ASI_CRM_CN_Sub_Brand__c) + String.valueOf(lineItem.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c), lineItem.ASI_CRM_CN_Incentive_BT__c);
            //     }
            // }

            Integer totalMonths = MonthDiff(contract.ASI_CRM_CN_PO_Start_Date__c, contract.ASI_CRM_CN_PO_End_Date__c);


            for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
                TradeExpenseBreakdown2nd data = TradeExpenseBySubBrand.get(subBrandId);
                if (totalVolumeByGrade.containsKey(data.gradeId)) {
                    totalVolumeByGrade.put(data.gradeId, totalVolumeByGrade.get(data.gradeId) + data.volumeCR12);
                } else {
                    totalVolumeByGrade.put(data.gradeId, data.volumeCR12);
                }

                if (totalStdVolumeByGrade.containsKey(data.gradeId)) {
                    totalStdVolumeByGrade.put(data.gradeId, totalStdVolumeByGrade.get(data.gradeId) + data.volumeSTD);
                } else {
                    totalStdVolumeByGrade.put(data.gradeId, data.volumeSTD);
                }

                if (totalVolumeByCategory.containsKey(data.categoryId)) {
                    totalVolumeByCategory.put(data.categoryId, totalVolumeByCategory.get(data.categoryId) + data.volumeCR12);
                } else {
                    totalVolumeByCategory.put(data.categoryId, data.volumeCR12);
                }
                
                totalVolume += data.volumeCR12;
                totalStdVolume += data.volumeSTD;

                if (totalMonths==0){
                    data.monthlyVolumeSTD = data.volumeSTD;
                }
                else {
                    data.monthlyVolumeSTD = (data.volumeSTD/totalMonths).setScale(4);
                }
            }
            for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
                TradeExpenseBreakdown2nd data = TradeExpenseBySubBrand.get(subBrandId);

                data.propByGrade = totalVolumeByGrade.get(data.gradeId) != 0? data.volumeCR12 / totalVolumeByGrade.get(data.gradeId) : 1;
                data.propByCategory = totalVolumeByCategory.get(data.categoryId) != 0? data.volumeCR12 / totalVolumeByCategory.get(data.categoryId) : 1;
                data.propByTotal = totalVolume != 0? data.volumeCR12 / totalVolume : 1;
                data.propByStdTotal = totalStdVolume != 0? data.volumeSTD / totalStdVolume : 1;

                data.propByGrade = data.propByGrade.setScale(8);
                data.propByCategory = data.propByCategory.setScale(8);
                data.propByTotal = data.propByTotal.setScale(8);
                data.propByStdTotal = data.propByStdTotal.setScale(8);
            }
            
            //Map<String, Decimal> totalCTDPayableAmountByPSFModule = new Map<String, Decimal>();
            //Map<String, ModuleTradeExpense> tradeExpenseByPSFModule = new Map<String, ModuleTradeExpense>();

            // // Construct totalCTDPayableAmountByPSFModule
            // for (ASI_TH_CRM_PaymentRequest__c lastPayment : lastPayments) {
            //     for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : lastPayment.ASI_TH_CRM_PRLI_PaymentRequest__r) {
            //         Decimal sum = denullify(totalCTDPayableAmountByPSFModule.get(lineItem.ASI_CRM_Module__c));
            //         totalCTDPayableAmountByPSFModule.put(lineItem.ASI_CRM_Module__c, sum + denullify(lineItem.ASI_CRM_CN_Total_Payable__c));
            //     }
            // }

            // Map<String, ModuleTradeExpense> tradeExpenseByPSFModule = new Map<String, ModuleTradeExpense>();
            // Map<String, ModuleTradeExpense> tradeExpenseByFixedModule = new Map<String, ModuleTradeExpense>();
            for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
                TradeExpenseBreakdown2nd data = TradeExpenseBySubBrand.get(subBrandId);
                for (ASI_TH_CRM_PaymentRequest__c lastPayment : lastPayments) {
                    for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : lastPayment.ASI_TH_CRM_PRLI_PaymentRequest__r) {
                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && lineItem.ASI_CRM_CN_Sub_Brand__c != subBrandId) {
                            continue;
                        }
                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Grade' && lineItem.ASI_CRM_Sub_Brand_Grade__c != data.gradeId) {
                            continue;
                        }
                        if (lineItem.ASI_CRM_Volume_Base__c == 'By Category' && lineItem.ASI_CRM_Product_Category__c != data.categoryId) {
                            continue;
                        }

                        if (lineItem.ASI_CRM_Module__r.ASI_CRM_Line_Type__c == 'Variable Event Cost' || lineItem.ASI_CRM_Module__r.ASI_CRM_Line_Type__c == 'PSF')
                        {
                            Decimal tradeExpensePerBottle = 0;
                            Decimal tradeExpense = 0;

                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && lineItem.ASI_CRM_CN_Sub_Brand__c == subBrandId) {
                                tradeExpensePerBottle += denullify(lineItem.ASI_CRM_CN_Incentive_BT__c);
                                tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c);
                            }
                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Grade' && lineItem.ASI_CRM_Sub_Brand_Grade__c == data.gradeId) {
                                tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c) * denullify(data.propByGrade, 1);
                                if (lineItem.ASI_CRM_V0_0_Full_Contract_Target__c != null && lineItem.ASI_CRM_V0_0_Full_Contract_Target__c != 0) {
                                    if (lineItem.ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c=='CR12 Extra Eqv.') {
                                        tradeExpensePerBottle += denullify(lineItem.ASI_CRM_CN_Incentive_BT__c)/lineItem.ASI_CRM_V0_0_Full_Contract_Target__c * denullify(data.cr12Factor, 1);
                                    }
                                    else{
                                        tradeExpensePerBottle += denullify(lineItem.ASI_CRM_CN_Incentive_BT__c)/lineItem.ASI_CRM_V0_0_Full_Contract_Target__c ;
                                    }
                                    
                                } else if (lineItem.ASI_CRM_CN_Total_Payable__c != null && lineItem.ASI_CRM_CN_Total_Payable__c != 0 
                                        && lineItem.ASI_CRM_CTD_Actual_Vol__c != null && lineItem.ASI_CRM_CTD_Actual_Vol__c != 0 ) {
                                    if (lineItem.ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c=='CR12 Extra Eqv.') {
                                        tradeExpensePerBottle += (lineItem.ASI_CRM_CN_Total_Payable__c/lineItem.ASI_CRM_CTD_Actual_Vol__c)* denullify(data.cr12Factor, 1);
                                    }
                                    else{
                                        tradeExpensePerBottle += lineItem.ASI_CRM_CN_Total_Payable__c/lineItem.ASI_CRM_CTD_Actual_Vol__c ;
                                    }
                                }
                            }
                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Category' && lineItem.ASI_CRM_Product_Category__c == data.categoryId) {
                                tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c) * denullify(data.propByCategory, 1);
                                if (lineItem.ASI_CRM_V0_0_Full_Contract_Target__c != null && lineItem.ASI_CRM_V0_0_Full_Contract_Target__c != 0) {
                                    tradeExpensePerBottle += denullify(lineItem.ASI_CRM_CN_Incentive_BT__c)/lineItem.ASI_CRM_V0_0_Full_Contract_Target__c * denullify(data.cr12Factor, 1);
                                } else if (lineItem.ASI_CRM_CN_Total_Payable__c != null && lineItem.ASI_CRM_CN_Total_Payable__c != 0 
                                        && lineItem.ASI_CRM_CTD_Actual_Vol__c != null && lineItem.ASI_CRM_CTD_Actual_Vol__c != 0 ) {
                                    tradeExpensePerBottle += (lineItem.ASI_CRM_CN_Total_Payable__c/lineItem.ASI_CRM_CTD_Actual_Vol__c)* denullify(data.cr12Factor, 1);
                                }

                            }
                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Total') {
                                tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c) * denullify(data.propByTotal, 1);
                                if (lineItem.ASI_CRM_V0_0_Full_Contract_Target__c != null && lineItem.ASI_CRM_V0_0_Full_Contract_Target__c != 0) {
                                    tradeExpensePerBottle += denullify(lineItem.ASI_CRM_CN_Incentive_BT__c)/lineItem.ASI_CRM_V0_0_Full_Contract_Target__c * denullify(data.cr12Factor, 1);
                                } else if (lineItem.ASI_CRM_CN_Total_Payable__c != null && lineItem.ASI_CRM_CN_Total_Payable__c != 0 
                                        && lineItem.ASI_CRM_CTD_Actual_Vol__c != null && lineItem.ASI_CRM_CTD_Actual_Vol__c != 0 ) {
                                    tradeExpensePerBottle += (lineItem.ASI_CRM_CN_Total_Payable__c/lineItem.ASI_CRM_CTD_Actual_Vol__c)* denullify(data.cr12Factor, 1);
                                }
                            }

                            if (lineItem.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_PSF') {
                                ModuleTradeExpense moduleData = new ModuleTradeExpense(lineItem.ASI_CRM_Module__r);

                                moduleData.amount = tradeExpense.setScale(4);
                                //moduleData.totalCTDPayableAmount = totalCTDPayableAmountByPSFModule.get(lineItem.ASI_CRM_Module__c);
                                moduleData.totalCTDPayableAmount = modulePayablePaymentMap.get(lineItem.ASI_CRM_Module__c);
                                moduleData.incentivePer = tradeExpensePerBottle.setScale(4);
                                //tradeExpenseByPSFModule.put(lineItem.ASI_CRM_Module__c, moduleData);
                                data.tradeExpenseByPSFModule.add(moduleData);
                                data.PSFAmount += tradeExpense.setScale(4);
                                data.PSFPerTradeExpense += tradeExpensePerBottle.setScale(4);
                            }
                            if (lineItem.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request_Detail_VEC') {
                                data.VECAmount += tradeExpense.setScale(4);
                                data.VECPerTradeExpense += tradeExpensePerBottle.setScale(4);
                            }
                        }
                        else if ( lineItem.ASI_CRM_Module__r.ASI_CRM_Line_Type__c == 'Fixed') {
                            Decimal tradeExpensePerBottle = 0;
                            Decimal tradeExpense = 0;
                            Decimal moduleTotalAmount = modulePayablePaymentMap.get(lineItem.ASI_CRM_Module__c);
                            Decimal moduleActualAmount = moduleActualPaymentMap.get(lineItem.ASI_CRM_Module__c);

                            if (moduleTotalAmount == null || moduleTotalAmount == 0) {
                                continue;
                            }

                            // if (lineItem.ASI_CRM_Volume_Base__c == 'By Grade' && lineItem.ASI_CRM_Sub_Brand_Grade__c == data.gradeId) {
                            //     tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c) * denullify(data.propByGrade, 1);
                            //     if (lineItem.ASI_CRM_V0_0_Full_Contract_Target__c != null && lineItem.ASI_CRM_V0_0_Full_Contract_Target__c != 0) {
                            //         if (lineItem.ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c=='CR12 Extra Eqv.') {
                            //             tradeExpensePerBottle += denullify(lineItem.ASI_CRM_CN_Incentive_BT__c)/lineItem.ASI_CRM_V0_0_Full_Contract_Target__c * denullify(data.cr12Factor, 1);
                            //         }
                            //         else{
                            //             tradeExpensePerBottle += denullify(lineItem.ASI_CRM_CN_Incentive_BT__c)/lineItem.ASI_CRM_V0_0_Full_Contract_Target__c ;
                            //         }
                                    
                            //     } else if (lineItem.ASI_CRM_CN_Total_Payable__c != null && lineItem.ASI_CRM_CN_Total_Payable__c != 0 
                            //             && lineItem.ASI_CRM_CTD_Actual_Vol__c != null && lineItem.ASI_CRM_CTD_Actual_Vol__c != 0 ) {
                            //         if (lineItem.ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c=='CR12 Extra Eqv.') {
                            //             tradeExpensePerBottle += (lineItem.ASI_CRM_CN_Total_Payable__c/lineItem.ASI_CRM_CTD_Actual_Vol__c)* denullify(data.cr12Factor, 1);
                            //         }
                            //         else{
                            //             tradeExpensePerBottle += lineItem.ASI_CRM_CN_Total_Payable__c/lineItem.ASI_CRM_CTD_Actual_Vol__c ;
                            //         }
                            //     }
                            // }

                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Sub-Brand' && lineItem.ASI_CRM_CN_Sub_Brand__c == subBrandId) {
                                tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c)/moduleTotalAmount * moduleActualAmount;
                            }
                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Grade' && lineItem.ASI_CRM_Sub_Brand_Grade__c == data.gradeId) {
                                tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c)/moduleTotalAmount * moduleActualAmount * denullify(data.propByGrade, 1);
                                // if (lineItem.ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c=='CR12 Extra Eqv.') {
                                //     tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c)/moduleTotalAmount * moduleActualAmount* denullify(data.propByGrade, 1);
                                // }
                                // else {

                                //     Decimal gradeStdVolume = totalStdVolumeByGrade.get(data.gradeId);
                                //     Decimal propByGrade = gradeStdVolume!= null && gradeStdVolume !=0 ? denullify(data.volumeSTD)/gradeStdVolume : 1;
                                //     tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c)/moduleTotalAmount * moduleActualAmount* denullify(propByGrade,1);
                                // }
                            }
                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Category' && lineItem.ASI_CRM_Product_Category__c == data.categoryId) {
                                tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c)/moduleTotalAmount * moduleActualAmount * denullify(data.propByCategory, 1);
                            }
                            if (lineItem.ASI_CRM_Volume_Base__c == 'By Total') {
                                tradeExpense += denullify(lineItem.ASI_CRM_CN_Total_Payable__c)/moduleTotalAmount * moduleActualAmount * denullify(data.propByTotal, 1);
                            }

                            if (tradeExpense != 0 && data.volumeSTD != 0)
                            {
                                tradeExpensePerBottle = tradeExpense/denullify(data.volumeSTD,1);
                            }

                            data.fixCostTradeExpense += tradeExpense.setScale(4);
                            data.fixCostPerTradeExpense += tradeExpensePerBottle.setScale(4);

                            ModuleTradeExpense moduleData = new ModuleTradeExpense(lineItem.ASI_CRM_Module__r);
                            moduleData.amount += tradeExpense.setScale(4);
                            moduleData.totalCTDPayableAmount = modulePayablePaymentMap.get(lineItem.ASI_CRM_Module__c);
                            moduleData.incentivePer = tradeExpensePerBottle.setScale(4);
                            data.tradeExpenseByFXModule.add(moduleData);
                            //tradeExpenseByFixedModule.put(lineItem.ASI_CRM_Module__c, moduleData);
                        }

                    }
                }
                // data.tradeExpenseByPSFModule = tradeExpenseByPSFModule.values();
                // data.tradeExpenseByFXModule = tradeExpenseByFixedModule.values();
            }

            Decimal totalGapAmount = totalActualPayment - totalPayableAmount;
            if (totalGapAmount != 0)
            {
                ASI_MFM_Sub_brand__c subbrand999 = [SELECT Id,Name,ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
                                                        ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.name,  ASI_MFM_Sub_brand_Code__c,
                                                        ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_brand_Grade__r.Name
                                                        FROM ASI_MFM_Sub_brand__c 
                                                        WHERE ASI_MFM_Active_for_CRM__c = true  AND 
                                                        ASI_MFM_Sub_brand_Code__c = '999'  AND 
                                                        recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1];
                TradeExpenseBreakdown2nd data = new TradeExpenseBreakdown2nd();
                data.subBrandId = subbrand999.Id;
                data.subBrandCode = subbrand999.ASI_MFM_Sub_brand_Code__c;
                data.subBrandName = subbrand999.Name;
                data.gradeId = subbrand999.ASI_CRM_CN_Sub_brand_Grade__c;
                data.gradeName = subbrand999.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                data.categoryId = subbrand999.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c;
                data.categoryName = subbrand999.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                data.BRSFAmount = totalGapAmount;
                data.totalTradeExpense = totalGapAmount;
                TradeExpenseBySubBrand.put(subbrand999.Id, data);
            }
        }
        

        // Remove any nonContract and zero volume data
        for (String subBrandId : TradeExpenseBySubBrand.keySet()) {
            TradeExpenseBreakdown2nd data = TradeExpenseBySubBrand.get(subBrandId);
            if (data.nonContract && data.volumeSTD == 0 && data.subBrandCode != '999') {
                TradeExpenseBySubBrand.remove(subBrandId);
            }
        }





        return TradeExpenseBySubBrand.values();
    }



    public static List<TradeExpenseBreakdown> updateCMGSInTradeExpenseBySubBrand(FinancialIndicator financialIndicator, List<TradeExpenseBreakdown> tradeExpenseBySubBrand, Map <String, subbrand_data> subBrandData) {
        for (TradeExpenseBreakdown tradeExpenseBreakdown : tradeExpenseBySubBrand) {
            for (subbrand_data data : subBrandData.values()) {
                if (tradeExpenseBreakdown.subBrandId == data.SubBrandId) {
                    tradeExpenseBreakdown.GSTotal += denullify(data.actualGS != 0 ? data.actualGS : data.GS) * denullify(tradeExpenseBreakdown.volume9L) * denullify(data.period) / financialIndicator.NoOfMonths;
                    tradeExpenseBreakdown.CMTotal += denullify(data.actualCM != 0 ? data.actualCM : data.CM) * denullify(tradeExpenseBreakdown.volume9L) * denullify(data.period) / financialIndicator.NoOfMonths;
                    tradeExpenseBreakdown.latestBudgetCMTotal += denullify(data.latestBudgetCM) * denullify(tradeExpenseBreakdown.volume9L) * denullify(data.period) / financialIndicator.NoOfMonths;
                }
            }

            tradeExpenseBreakdown.GSTotal = tradeExpenseBreakdown.GSTotal.setScale(4);
            tradeExpenseBreakdown.CMTotal = tradeExpenseBreakdown.CMTotal.setScale(4);
            tradeExpenseBreakdown.latestBudgetCMTotal = tradeExpenseBreakdown.latestBudgetCMTotal.setScale(4);
        }
        return tradeExpenseBySubBrand;
    }

    public static List<TradeExpenseBreakdown2nd> updateCMGSInTradeExpenseBySubBrand2nd(FinancialIndicator2nd financialIndicator, List<TradeExpenseBreakdown2nd> tradeExpenseBySubBrand, Map <String, subbrand_data> subBrandData) {
        for (TradeExpenseBreakdown2nd tradeExpenseBreakdown : tradeExpenseBySubBrand) {
            for (subbrand_data data : subBrandData.values()) {
                if (tradeExpenseBreakdown.subBrandId == data.SubBrandId) {
                    tradeExpenseBreakdown.GSTotal += denullify(data.actualGS != 0 ? data.actualGS : data.GS) * denullify(tradeExpenseBreakdown.volume9L) * denullify(data.period) / financialIndicator.NoOfMonths;
                    tradeExpenseBreakdown.CMTotal += denullify(data.actualCM != 0 ? data.actualCM : data.CM) * denullify(tradeExpenseBreakdown.volume9L) * denullify(data.period) / financialIndicator.NoOfMonths;
                    tradeExpenseBreakdown.latestBudgetCMTotal += denullify(data.latestBudgetCM) * denullify(tradeExpenseBreakdown.volume9L) * denullify(data.period) / financialIndicator.NoOfMonths;
                }
            }

            tradeExpenseBreakdown.GSTotal = tradeExpenseBreakdown.GSTotal.setScale(4);
            tradeExpenseBreakdown.CMTotal = tradeExpenseBreakdown.CMTotal.setScale(4);
            tradeExpenseBreakdown.latestBudgetCMTotal = tradeExpenseBreakdown.latestBudgetCMTotal.setScale(4);
        }
        return tradeExpenseBySubBrand;
    }


    public static List<String> getSelectedSubBrandCode(){
        return new List<String>{'AB1','ABT','BAF','JCS'};
    }

    public static Set<Id> getSelectedSubBrandIds(){
        return (new Map<Id, ASI_MFM_Sub_brand__c>([SELECT Id  FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Sub_brand_Code__c IN :getSelectedSubBrandCode() AND RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand']).keySet());
    }

    public static Set<Id> getSelectedSubBrandIds2nd(){
        return (new Map<Id, ASI_MFM_Sub_brand__c>([SELECT Id  FROM ASI_MFM_Sub_brand__c WHERE RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand']).keySet());
    }

    public static String getSelectedSubBrandDescription(){
        String result = 'Premium brands/高档品牌**: ';
        List<ASI_MFM_Sub_brand__c> subBrands = [SELECT Id, ASI_CRM_CN_CHI_NAME_C__c, ASI_HK_CRM_English_Name__c  FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Sub_brand_Code__c IN :getSelectedSubBrandCode() AND RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand'];
        List<String> names = new List<String>();

        for (ASI_MFM_Sub_brand__c subBrand : subBrands) {
            names.add(subBrand.ASI_CRM_CN_CHI_NAME_C__c + subBrand.ASI_HK_CRM_English_Name__c);
        }

        return result + String.join(names, ', ');
    }

    public static FinancialIndicator calculateFIExcludeSelectedSubBrands(FinancialIndicator financialIndicator) {
        List<String> subBrands = getSelectedSubBrandCode();

        Decimal tradeExpensesExcl = 0;
        Decimal grossSalesExcl = 0;
        Decimal contributionMarginExcl = 0;
        Decimal latestBudgetContributionMarginExcl = 0;
        for (TradeExpenseBreakdown breakdown : financialIndicator.TradeExpenseBySubBrand) {
            if (subBrands.contains(breakdown.subBrandCode)) {
                continue;
            }
            System.debug(LoggingLevel.INFO, '*** breakdown.totalTradeExpense: ' + breakdown.totalTradeExpense);
            System.debug(LoggingLevel.INFO, '*** breakdown.CMTotal: ' + breakdown.CMTotal);
            tradeExpensesExcl += breakdown.totalTradeExpense;
            grossSalesExcl += breakdown.GSTotal;
            contributionMarginExcl += breakdown.CMTotal;
            latestBudgetContributionMarginExcl += breakdown.latestBudgetCMTotal;
        }
        System.debug(LoggingLevel.INFO, '*** tradeExpensesExcl: ' + tradeExpensesExcl);
        System.debug(LoggingLevel.INFO, '*** contributionMarginExcl: ' + contributionMarginExcl);
        financialIndicator.GrossSalesRateExcl = grossSalesExcl != 0? (tradeExpensesExcl / grossSalesExcl * 100) : 0;
        financialIndicator.ROIIntakeExcl = tradeExpensesExcl != 0? (contributionMarginExcl / tradeExpensesExcl) : 0;
        financialIndicator.ROIProFormaExcl = tradeExpensesExcl != 0? (latestBudgetContributionMarginExcl / tradeExpensesExcl) : 0;

        return financialIndicator;
    }

    public static FinancialIndicator2nd calculateFIExcludeSelectedSubBrands2nd(FinancialIndicator2nd financialIndicator) {
        List<String> subBrands = getSelectedSubBrandCode();

        Decimal tradeExpensesExcl = 0;
        Decimal grossSalesExcl = 0;
        Decimal contributionMarginExcl = 0;
        Decimal latestBudgetContributionMarginExcl = 0;
        financialIndicator.TradeExpenseBySubBrand = financialIndicator.TradeExpenseBySubBrand == null ? new List<TradeExpenseBreakdown2nd>() : financialIndicator.TradeExpenseBySubBrand;
        for (TradeExpenseBreakdown2nd breakdown : financialIndicator.TradeExpenseBySubBrand) {
            if (subBrands.contains(breakdown.subBrandCode)) {
                continue;
            }
            tradeExpensesExcl += breakdown.totalTradeExpense;
            grossSalesExcl += breakdown.GSTotal;
            contributionMarginExcl += breakdown.CMTotal;
            latestBudgetContributionMarginExcl += breakdown.latestBudgetCMTotal;
        }

        financialIndicator.GrossSalesRateExcl = grossSalesExcl != 0? (tradeExpensesExcl / grossSalesExcl * 100) : 0;
        financialIndicator.ROIIntakeExcl = tradeExpensesExcl != 0? (contributionMarginExcl / tradeExpensesExcl) : 0;
        financialIndicator.ROIProFormaExcl = tradeExpensesExcl != 0? (latestBudgetContributionMarginExcl / tradeExpensesExcl) : 0;

        return financialIndicator;
    }

    /**
     * First key is Sub-brand Id, second key is element in keys.
     * Value is the tradeExpenseBreakdown object
     * keys and financialIndicators must have the same length
     *
     * @param keys
     * @param financialIndicators
     *
     * @return
     */
    public static Map<String, Map<String, TradeExpenseBreakdown>> getInvestmentBySubBrand(List<String> keys, List<FinancialIndicator> financialIndicators){
        Map<String, Map<String, TradeExpenseBreakdown>> result = new Map<String, Map<String, TradeExpenseBreakdown>>();

        for (String subBrandId : getSelectedSubBrandIds()) {
            result.put(subBrandId, new Map<String, TradeExpenseBreakdown>());
            for (String key : keys) {
                result.get(subBrandId).put(key, new TradeExpenseBreakdown());
            }
        }

        for (Integer i = 0; i < keys.size(); i++) {
            String key = keys[i];
            if (financialIndicators[i].TradeExpenseBySubBrand == null) {
                continue;
            }
            for (TradeExpenseBreakdown breakdown : financialIndicators[i].TradeExpenseBySubBrand) {
                if (!result.containsKey(breakdown.subBrandId)) {
                    continue;
                }
                result.get(breakdown.subBrandId).put(key, breakdown);
            }

        }

        // Remove empty map
        for (String subBrandId : result.keySet()) {
            Boolean allEmpty = true;

            for (TradeExpenseBreakdown breakdown : result.get(subBrandId).values()) {
                if (breakdown.subBrandId != null) {
                    allEmpty = false;
                }
            }
            if (allEmpty) {
                result.remove(subBrandId);
            }
        }

        return result;
    }

    public static Map<String, Map<String, TradeExpenseBreakdown2nd>> getInvestmentBySubBrand2nd(List<String> keys, List<FinancialIndicator2nd> financialIndicators){
        Map<String, Map<String, TradeExpenseBreakdown2nd>> result = new Map<String, Map<String, TradeExpenseBreakdown2nd>>();

        for (String subBrandId : getSelectedSubBrandIds2nd()) {
            result.put(subBrandId, new Map<String, TradeExpenseBreakdown2nd>());
            for (String key : keys) {
                result.get(subBrandId).put(key, new TradeExpenseBreakdown2nd());
            }
        }

        for (Integer i = 0; i < keys.size(); i++) {
            String key = keys[i];
            if (financialIndicators[i].TradeExpenseBySubBrand == null) {
                continue;
            }
            for (TradeExpenseBreakdown2nd breakdown : financialIndicators[i].TradeExpenseBySubBrand) {
                if (!result.containsKey(breakdown.subBrandId)) {
                    continue;
                }
                result.get(breakdown.subBrandId).put(key, breakdown);
            }

        }

        // Remove empty map
        for (String subBrandId : result.keySet()) {
            Boolean allEmpty = true;

            for (TradeExpenseBreakdown2nd breakdown : result.get(subBrandId).values()) {
                if (breakdown.subBrandId != null) {
                    allEmpty = false;
                }
            }
            if (allEmpty) {
                result.remove(subBrandId);
            }
        }

        return result;
    }

    //*****************************Function support for 'RestructureHistoricalData' class ****************************************************
    public static List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> retrieveBRSFLines(ASI_TH_CRM_Contract__c contract, List<String> types, Boolean exclude999) {
        String query = 'SELECT ' +
            'Id,' +
            'ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,' +
            'ASI_CRM_CN_Contract_Monthly_Qty__c,' +
            'ASI_CRM_CN_Contract_Monthly_Vol9L__c,' +
            'ASI_CRM_CN_Contract_Total_Dummy__c,' +
            'ASI_CRM_CN_Contract_Total__c,' +
            'ASI_CRM_CN_Est_BRSF_Per_Bottle__c,' +
            'ASI_CRM_CN_Est_Monthly_Qty__c,' +
            'ASI_CRM_CN_Est_Total_Dummy__c,' +
            'ASI_CRM_CN_Est_Total__c,' +
            'ASI_CRM_CN_Estimate_Volume_9L_Month__c,' +
            'ASI_CRM_Contract_Total_QTY_std_Btl__c, ' +
            'ASI_CRM_Est_Total_QTY_std_Btl__c, '+
            'ASI_CRM_Contract_Total_QTY_CR12_Eqv__c, '+
            'ASI_CRM_Est_Total_QTY_CR12_Eqv__c,' +
            'ASI_CRM_CN_No_of_Months__c,' +
            'ASI_CRM_CN_Sub_Brand__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,' +
            'ASI_CRM_Product_Category__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c,' +
            'ASI_CRM_CN_Sub_Brand__r.Name,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c,' +
            'ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,' +
            'ASI_CRM_Module__c,' +
            'ASI_CRM_Module__r.Id,' +
            'ASI_CRM_Module__r.ASI_CRM_Methodology__c,' +
            'ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,' +
            'ASI_CRM_Module__r.ASI_CRM_Line_Type__c,' +
            'ASI_CRM_Module__r.ASI_CRM_Historical_Paid_Amount__c,' +
            'ASI_CRM_Module__r.ASI_CRM_Actual_Payment__c,' +
            'ASI_CRM_Module__r.ASI_CRM_Application_Payment_Amount__c,' +
            'ASI_CRM_Module__r.ASI_CRM_CN_AC_Code__c,'+
            'ASI_CRM_Module__r.ASI_CRM_CN_Expected_Est_Total__c,' +
            'ASI_CRM_Module__r.ASI_CRM_CN_AC_Code__r.Name,'+
            'ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,' +
            'ASI_CRM_Type__c,' +
            'ASI_CRM_Volume_Base__c,' +
            'RecordType.DeveloperName ' +
            'FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c ' +
            'WHERE ASI_CRM_CN_Contract__c = \'' + contract.Id + '\' ' +
            'AND ASI_CRM_Type__c IN :types ';

        if (exclude999) {
            query += 'AND ASI_CRM_CN_Sub_Brand__r.Name != \'999\' ';
        }

        return Database.query(query);
    }

    /**
     * Get the modules and lines by this contract.
     * Because the module still stay in the original contract when doing modify,
     * I have to query the lines first to get the correct module Ids
     *
     * @param contract
     * @param types
     *
     * @return
     */
    public static List<ASI_CRM_Module__c> retrieveModulesAndLines(ASI_TH_CRM_Contract__c contract, List<String> types) {
        Set<Id> moduleIds = new Set<Id>();
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : [SELECT Id, ASI_CRM_Module__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :contract.Id AND ASI_CRM_Type__c IN :types]) {
            moduleIds.add(lineItem.ASI_CRM_Module__c);
        }
        return [
            SELECT
                Id,
                ASI_CRM_Methodology__c,
                ASI_CRM_Methodology__r.Name,
                ASI_CRM_Line_Type__c,
                ASI_CRM_Historical_Paid_Amount__c,
                ASI_CRM_Actual_Payment__c,
                ASI_CRM_Application_Payment_Amount__c,
                ASI_CRM_Volume_Base__c,
                ASI_CRM_CN_AC_Code__r.Name,
                ASI_CRM_CN_AC_Code__c,
                ASI_CRM_CN_Expected_Est_Total__c,
            (SELECT
                Id,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Contract_Monthly_Qty__c,
                ASI_CRM_CN_Contract_Monthly_Vol9L__c,
                ASI_CRM_CN_Contract_Total_Dummy__c,
                ASI_CRM_CN_Contract_Total__c,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
                ASI_CRM_CN_Est_Monthly_Qty__c,
                ASI_CRM_CN_Est_Total_Dummy__c,
                ASI_CRM_CN_Est_Total__c,
                ASI_CRM_CN_Estimate_Volume_9L_Month__c,
                ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_Sub_Brand__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,
                ASI_CRM_Product_Category__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c,
                ASI_CRM_CN_Sub_Brand__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_Type__c,
                ASI_CRM_Volume_Base__c,
                RecordType.DeveloperName
            FROM Contract_BRSF_Line_Item__r
            WHERE ASI_CRM_CN_Contract__c = :contract.Id)
            FROM ASI_CRM_Module__c
            WHERE Id IN :moduleIds
        ];
    }

    public static List<ASI_CRM_Subbrand_Volume__c> retrieveSubBrandVolumes(ASI_TH_CRM_Contract__c contract){
        Set<Id> outletIds = new Set<Id>{contract.ASI_CRM_CN_Outlet_WS__c};
        if(contract.ASI_CRM_Volume_Option__c != 'Wholesaler Only'){
            for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :contract.Id]){
                outletIds.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
            }
        }

        Date endDate = FindMinMaxDate(GenerateCutOffDate(), contract.ASI_CRM_CN_PO_End_Date__c, 'MIN');
        return [
            SELECT
                ASI_CRM_Black_Cap_Btl__c,
                ASI_CRM_Black_Cap_Std_Billing__c,
                ASI_CRM_Cap_with_Issues_Std_Billing__c,
                ASI_CRM_Cap_with_Issues_Std_Btl__c,
                ASI_CRM_DeductCapWithIssue_StdBill__c,
                ASI_CRM_DeductibleCapWithIssues_Std_Btl__c,
                ASI_CRM_Empty_Bottle_Std_Btl__c,
                ASI_CRM_End_Date__c,
                ASI_CRM_Green_Cap_STD__c,
                ASI_CRM_Grey_Cap_Std_Billing__c,
                ASI_CRM_PR_Direct__c,
                ASI_CRM_PR_Direct_CR12__c,
                ASI_CRM_PR_Direct_STD__c,
                ASI_CRM_Subbrand__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c,
                ASI_CRM_Subbrand__r.Name,
                ASI_CRM_T1_Depletion__c,
                ASI_CRM_T1_Depletion_CR12__c,
                ASI_CRM_T1_Depletion_STD__c,
                ASI_CRM_T2_Depletion__c,
                ASI_CRM_T2_Depletion_CR12__c,
                ASI_CRM_T2_Depletion_STD__c,
                Id
            FROM ASI_CRM_Subbrand_Volume__c
            WHERE ASI_CRM_Account__c IN:outletIds
            AND ASI_CRM_Subbrand__c != NULL
            AND ASI_CRM_CN_Competitor_Sub_brand__c != TRUE
            AND ASI_CRM_End_Date__c >= :contract.ASI_CRM_CN_PO_Start_Date__c
            AND ASI_CRM_End_Date__c <= :endDate
            AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
        ];

    }

    public static Decimal getVolume(ASI_CRM_Subbrand_Volume__c subBrandVolume, String unit) {
        Decimal volume = 0;
        if (unit == 'std') {
            volume += subBrandVolume.ASI_CRM_T1_Depletion_STD__c != null? subBrandVolume.ASI_CRM_T1_Depletion_STD__c : 0;
            volume += subBrandVolume.ASI_CRM_T2_Depletion_STD__c != null? subBrandVolume.ASI_CRM_T2_Depletion_STD__c : 0;
            volume += subBrandVolume.ASI_CRM_PR_Direct_STD__c != null? subBrandVolume.ASI_CRM_PR_Direct_STD__c : 0;
        } else {
            volume += subBrandVolume.ASI_CRM_T1_Depletion__c != null? subBrandVolume.ASI_CRM_T1_Depletion__c : 0;
            volume += subBrandVolume.ASI_CRM_T2_Depletion__c != null? subBrandVolume.ASI_CRM_T2_Depletion__c : 0;
            volume += subBrandVolume.ASI_CRM_PR_Direct__c != null? subBrandVolume.ASI_CRM_PR_Direct__c : 0;
        }

        return volume;
    }

    /**
     * Project current volume to the whole contract period.
     * Whole contract volume = CTD volumes / current months * whole contract period
     *
     * @param CTDVolume
     * @param contract
     *
     * @return
     */
    public static Decimal projectVolume(Decimal CTDVolume, ASI_TH_CRM_Contract__c contract){
        Integer currentMonths = MonthDiff(contract.ASI_CRM_CN_PO_Start_Date__c, FindMinMaxDate(GenerateCutOffDate(), contract.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        Integer totalMonths = MonthDiff(contract.ASI_CRM_CN_PO_Start_Date__c, contract.ASI_CRM_CN_PO_End_Date__c);
        if (Test.isRunningTest()) {
            currentMonths = 1;
        }
        return CTDVolume / currentMonths * totalMonths;
    }

    // Insert Attachment Json
    public static void  UpsertAttachment(String ContractId, String JSONString, String TypeName){// Update field ASI_CRM_Historical_Financial_Data__c
        List<ASI_Attachment__c> AttachmentList= new  List<ASI_Attachment__c>();

        JSONString= JSONString.replaceAll('<','&lt;');


        try{
            ASI_Attachment__c FinancialData = new ASI_Attachment__c();
            AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :ContractId AND ASI_CRM_Type__c = : TypeName];

            if(AttachmentList.size()>0){//exist
                FinancialData=AttachmentList[0];
                FinancialData.ASI_CRM_Historical_Financial_Data__c= JSONString;

            }else{
                FinancialData= new ASI_Attachment__c(ASI_CRM_For_Contract_Use__c=true,ASI_CRM_Contract__c=ContractId,ASI_CRM_Type__c=TypeName,ASI_CRM_Historical_Financial_Data__c=JSONString);

            }
            upsert FinancialData;

        }catch(Exception e){
            String msg = 'UpsertAttachment  Error : ' +e.getMessage();
            ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '+ msg+' with contarct Id '+ContractId + ' with Json string : '+ JSONString , 'ASI_CRM_CN_HeavyContractUtilitiesClass','RestructureHistoricalFinancialIndicatorData.UpsertAttachment');
        }
    }

    // Insert Attachment Json
    public static void  UpsertAttachment2nd(String ContractId, String JSONString, String TypeName){// Update field ASI_CRM_Historical_Financial_Data__c
        List<ASI_Attachment__c> AttachmentList= new  List<ASI_Attachment__c>();

        JSONString= JSONString.replaceAll('<','&lt;');


        try{
            ASI_Attachment__c FinancialData = new ASI_Attachment__c();
            AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :ContractId AND ASI_CRM_Type__c = : TypeName];

            if(AttachmentList.size()>0){//exist
                FinancialData=AttachmentList[0];
            }else{
                FinancialData= new ASI_Attachment__c(ASI_CRM_For_Contract_Use__c=true,ASI_CRM_Contract__c=ContractId,ASI_CRM_Type__c=TypeName);

            }
            String TempString = JsonString;
            Integer splitLength = 90000;
            System.debug(LoggingLevel.INFO, '*** TempString.length(): ' + TempString.length());
            System.debug(LoggingLevel.INFO, '*** TempString.length()<splitLength: ' + (TempString.length()<splitLength));
            
            if (TempString.length() < splitLength) {
                FinancialData.ASI_CRM_Historical_Financial_Data__c= TempString;
                System.debug(LoggingLevel.INFO, '*** FinancialData.ASI_CRM_Historical_Financial_Data__c: ' + FinancialData.ASI_CRM_Historical_Financial_Data__c.length()); 
            }
            else {
                FinancialData.ASI_CRM_Historical_Financial_Data__c = TempString.substring(0,splitLength);
                System.debug(LoggingLevel.INFO, '*** FinancialData.ASI_CRM_Historical_Financial_Data__c: ' + FinancialData.ASI_CRM_Historical_Financial_Data__c.length()); 
                TempString = TempString.substring(splitLength);
                if (TempString.length() < splitLength) {
                    FinancialData.ASI_CRM_Historical_Financial_Data2__c= TempString;
                    System.debug(LoggingLevel.INFO, '*** FinancialData.ASI_CRM_Historical_Financial_Data2__c: ' + FinancialData.ASI_CRM_Historical_Financial_Data2__c.length());
                }
                else {
                    FinancialData.ASI_CRM_Historical_Financial_Data2__c = TempString.substring(0,splitLength);
                    System.debug(LoggingLevel.INFO, '*** FinancialData.ASI_CRM_Historical_Financial_Data2__c: ' + FinancialData.ASI_CRM_Historical_Financial_Data2__c.length());
                    TempString = TempString.substring(splitLength);
                    if (TempString.length() < splitLength) {
                        FinancialData.ASI_CRM_Historical_Financial_Data3__c= TempString;
                        System.debug(LoggingLevel.INFO, '*** FinancialData.ASI_CRM_Historical_Financial_Data3__c: ' + FinancialData.ASI_CRM_Historical_Financial_Data3__c.length());
                    }
                    else {
                        FinancialData.ASI_CRM_Historical_Financial_Data3__c = TempString.substring(0,splitLength);
                        TempString = TempString.substring(splitLength);
                        FinancialData.ASI_CRM_Historical_Financial_Data4__c = TempString;
                        System.debug(LoggingLevel.INFO, '*** FinancialData.ASI_CRM_Historical_Financial_Data3__c: ' + FinancialData.ASI_CRM_Historical_Financial_Data3__c.length());
                        System.debug(LoggingLevel.INFO, '*** FinancialData.ASI_CRM_Historical_Financial_Data4__c: ' + FinancialData.ASI_CRM_Historical_Financial_Data4__c.length());
                    }
                }
            }
            
            upsert FinancialData;

        }catch(Exception e){
            String msg = 'UpsertAttachment2nd  Error : ' +e.getMessage();
            ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment2nd '+ msg+' with contarct Id '+ContractId + ' with Json string : '+ JSONString  , 'ASI_CRM_CN_HeavyContractUtilitiesClass','RestructureHistoricalFinancialIndicatorData.UpsertAttachment2nd');
        }
    }

    //Generate Cut Off Date  If today <16, previous 2 month; else previous one month
    public static Date GenerateCutOffDate(){
        Integer strDay=16;
        Date returnDate;
        Integer strDate = Date.today().day();
        Integer strMonth;
        Integer strEndDay;

        if (strDate >= strDay){
            strMonth = Date.today().month() - 1;
        }
        else if (strDate < strDay){
            strMonth = Date.today().month() - 2;
        }
        strEndDay = Date.daysInMonth(Date.today().year(), strMonth);
        returnDate = Date.newInstance(Date.today().year(),strMonth,strEndDay);

        return returnDate;
    }




    //Generate CR12 Factor Mapping table : Sub-Brand Id, CR12 Factor
    public static Map<String,Decimal> GenerateCR12FactorMap(Set<Id> SBIdSet, String CommercialTeam, String RegionName){
        Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
        for(ASI_MFM_Sub_brand__c SubBrand: [SELECT Id,ASI_CRM_CN_COnvfactor_Ltocr12_C__c,(SELECT Id,ASI_CRM_CR12_Conversion_Factor__c,ASI_CRM_Commercial_Team__c,ASI_CRM_CN_Region__c FROM ASI_CRM_CR12_Factors__r) FROM ASI_MFM_Sub_brand__c  WHERE Id IN : SBIdSet ]){
            Decimal CR12Factor=1;
            Boolean FoundFactor = false;
            for(ASI_CRM_Sub_Brand_Line__c SubBrandLine: SubBrand.ASI_CRM_CR12_Factors__r){
                if(RegionName !=null && CommercialTeam !=null && SubBrandLine.ASI_CRM_CR12_Conversion_Factor__c !=null &&  SubBrandLine.ASI_CRM_Commercial_Team__c == CommercialTeam && SubBrandLine.ASI_CRM_CN_Region__c == RegionName ){
                    CR12Factor=SubBrandLine.ASI_CRM_CR12_Conversion_Factor__c;
                    FoundFactor=true;
                }
            }
            if(!FoundFactor && SubBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c!=null ){
                CR12Factor=SubBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                FoundFactor=true;
            }
            if(FoundFactor && CR12Factor!=null){
                CR12FactorMap.put(SubBrand.Id, CR12Factor);
            }
        }
        return CR12FactorMap;
    }


    public static Date getEndDate(Date strDate){
        Integer numberOfDays = Date.daysInMonth(strDate.year(), strDate.month());
        Date lastDayOfMonth = Date.newInstance(strDate.year(), strDate.month(), numberOfDays);
        return lastDayOfMonth;
    }



    public static Date FindMinMaxDate(Date Date1, Date Date2, String strType){
        //strType: MIN, MAX
        Date returnDate;
        if (strType == 'MIN'){
            if (Date1 <= Date2)
                returnDate = Date1;
            else
                returnDate = Date2;
        }
        else if (strType == 'MAX'){
            if (Date1 >= Date2)
                returnDate = Date1;
            else
                returnDate = Date2;
        }
        return returnDate;
    }



    public static Map<Date, Decimal> checkFYDayPeriod(Date startDate, Date endDate){
        Map<Date, Decimal> returnDateMap = new Map<Date, Decimal>();
        Integer EndFY;
        Integer StartFY;
        Date returnDate;
        Date tempDate = startDate;
        if (startDate != null && endDate != null){
            if (startDate.month() > 6 && startDate.month() < 13){
                StartFY = startDate.year() + 1;
            }else if (startDate.month() < 7 && startDate.month() > 0){
                StartFY = startDate.year();
            }
            if (endDate.month() > 6 && endDate.month() < 13){
                EndFY = endDate.year() + 1;
            }else if (endDate.month() < 7 && endDate.month() > 0){
                EndFY = endDate.year();
            }
            Integer strPeriod = EndFY - StartFY + 1;
            Integer strtemp = 0;
            if (strPeriod >= 0){
                for (Integer i=0; i<strPeriod; i++){
                    returnDate = Date.newInstance(StartFY,6,30);
                    if (returnDate <= startDate){
                        strtemp = MonthDiff(returnDate, startDate);
                    }else if (returnDate > startDate && returnDate < endDate){
                        strtemp = MonthDiff(tempDate, returnDate);
                    }else if (returnDate >= endDate){
                        strtemp = MonthDiff(tempDate, endDate);
                    }else if (returnDate >= startDate && returnDate >= endDate){
                        strtemp = MonthDiff(startDate, returnDate);
                    }
                    returnDateMap.put(returnDate, Decimal.valueof(strtemp));
                    tempDate = Date.newInstance(StartFY,7,1);
                    StartFY++;
                }
            }
            return returnDateMap;
        }else{
            return null;
        }
    }

    public static Date FYConversion(Date strDate){
        Date returndate;
        Integer EndFY;
        if (strDate.month() > 6 && strDate.month() < 13){
            EndFY = strDate.year() + 1;
        }else if (strDate.month() < 7 && strDate.month() > 0){
            EndFY = strDate.year();
        }
        returndate = Date.newInstance(EndFY,6,30);
        return returndate;
    }

    //Calculate month difference : like Integer PeriodA = MonthDiff(date.newinstance(2016,7, 1), date.newinstance(2017,6, 30));
    public static Integer MonthDiff(Date startDate, Date endDate){
        Integer monthDiff;
        if (startDate != null && endDate != null){
            monthDiff = ((endDate.year() - startDate.year() - 1) *12) + (12 - startDate.month() +1) + endDate.month();
            return monthDiff;
        }else{
            return null;
        }
    }



    //Payment Summary table in Payment view page
    public class PaymentSummary{
        public String Name {set;get;}{Name='';}
        public String EnglishDescription {set;get;}{EnglishDescription='';}
        public String ACCodeId {set;get;}{ACCodeId='';}
        public Decimal POEstimatedAmount {set;get;}{POEstimatedAmount=0;}
        public Decimal LastVersion_POEstimatedAmount {set;get;}{LastVersion_POEstimatedAmount=0;}
        public Decimal PaidAmount{set;get;}{PaidAmount=0;}
        public Decimal PaymentRequestAmount {set;get;} {PaymentRequestAmount=0;}

        public PaymentSummary(){

        }
    }




    //For PO Modification Page PDF
    public static List<PaymentSummary> POModificationPaymentSummaryTable( ASI_TH_CRM_Contract__c contract){
        Map<String,PaymentSummary> PaymentSummaryMap = new Map<String,PaymentSummary> ();
        String BRSFName='空瓶回收费';
        String PSFName='合同奖励';
        String VECName= '活动费用(变动)';
        Id lastContractID; // Last version  Contract Id
        if(contract!=null){
            lastContractID = contract.ASI_CRM_CN_Last_PO_version__c;
        }

        //Contract Cost Setting
        for(ASI_CRM_Contract_Cost__c ContractCost:[SELECT Id, Name,ASI_CRM_Other_Est__c,ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c  FROM ASI_CRM_Contract_Cost__c
        WHERE ASI_CRM_CN_Contract__c = :contract.Id OR ASI_CRM_CN_Contract__c=:lastContractID  ORDER BY ASI_CRM_CN_Sequence__c ASC,
            ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC])
        {
            if(PaymentSummaryMap.containsKey(ContractCost.ASI_CRM_CN_Chinese_Description__c)){
                if(ContractCost.ASI_CRM_CN_Contract__c==lastContractID){
                    PaymentSummaryMap.get(ContractCost.ASI_CRM_CN_Chinese_Description__c).LastVersion_POEstimatedAmount += ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
                }else{
                    PaymentSummaryMap.get(ContractCost.ASI_CRM_CN_Chinese_Description__c).POEstimatedAmount += ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
                }
            }else{ // dont contain in the map
                PaymentSummary tempData= new PaymentSummary();
                tempData.ACCodeId=ContractCost.ASI_CRM_CN_Activity_Code__c;
                tempData.Name=ContractCost.ASI_CRM_CN_Chinese_Description__c;
                tempData.EnglishDescription=ContractCost.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c;
                if(ContractCost.ASI_CRM_CN_Contract__c==lastContractID){
                    tempData.LastVersion_POEstimatedAmount=ContractCost.ASI_CRM_CN_Estimate_Amount__c!=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
                }else{
                    tempData.POEstimatedAmount=ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
                }
                PaymentSummaryMap.put(tempData.Name, tempData);
            }

        }

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:[SELECT Id,ASI_CRM_Module__c, ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :contract.Id  OR ASI_CRM_CN_Contract__c=:lastContractID  ] )
        {
            if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                if(PaymentSummaryMap.containsKey(BRSFName)){
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        PaymentSummaryMap.get(BRSFName).LastVersion_POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        // PaymentSummaryMap.get(BRSFName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                    }
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=BRSFName;
                    tempData.EnglishDescription='BRSF';
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        tempData.LastVersion_POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        //tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                    }
                    PaymentSummaryMap.put(BRSFName, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='PSF'){
                if(PaymentSummaryMap.containsKey(PSFName)){
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        PaymentSummaryMap.get(PSFName).LastVersion_POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        // PaymentSummaryMap.get(PSFName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=PSFName;
                    tempData.EnglishDescription='PRC - PSF & Trading Term Incentives';
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        tempData.LastVersion_POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        //  tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                    }
                    PaymentSummaryMap.put(PSFName, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                if(PaymentSummaryMap.containsKey(VECName)){
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        PaymentSummaryMap.get(VECName).LastVersion_POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        //  PaymentSummaryMap.get(VECName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=VECName;
                    tempData.EnglishDescription='PRC - Variable Event Cost';
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        tempData.LastVersion_POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        //  tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                    PaymentSummaryMap.put(VECName, tempData);
                }
            }
        }//End of looping  Contract Line

        //ASI_CRM_CN_Expected_BRSF_Est_Total__c

        if(PaymentSummaryMap.containsKey(BRSFName)){
            if(contract.ASI_CRM_CN_PO_Version__c!='0.1' && contract.ASI_CRM_Copied_From__c!=null){
                PaymentSummaryMap.get(BRSFName).LastVersion_POEstimatedAmount=contract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_BRSF_Est_Total__c;
            }
            PaymentSummaryMap.get(BRSFName).POEstimatedAmount +=contract.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null? contract.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
        }
        if(PaymentSummaryMap.containsKey(PSFName)){
            if(contract.ASI_CRM_CN_PO_Version__c!='0.1' && contract.ASI_CRM_Copied_From__c!=null ){
                PaymentSummaryMap.get(PSFName).LastVersion_POEstimatedAmount=contract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c;
            }
            PaymentSummaryMap.get(PSFName).POEstimatedAmount +=contract.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null? contract.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        }
        if(PaymentSummaryMap.containsKey(VECName)){
            if(contract.ASI_CRM_CN_PO_Version__c!='0.1' && contract.ASI_CRM_Copied_From__c!=null  ){
                PaymentSummaryMap.get(VECName).LastVersion_POEstimatedAmount=contract.ASI_CRM_Copied_From__r.ASI_CRM_EVC_Cost_Estimate_Total__c;
            }
            PaymentSummaryMap.get(VECName).POEstimatedAmount +=contract.ASI_CRM_EVC_Cost_Estimate_Total__c!=null? contract.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
        }



        //RecordType.DeveloperName like 'ASI_CRM_CN%'
        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [SELECT Id, Name,ASI_TH_CRM_Payment_Request__r.Name, RecordType.DeveloperName,ASI_CRM_CN_Total_Payable__c, RecordTypeId, ASI_TH_CRM_Amount__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_AC_Code__c
        FROM ASI_TH_CRM_PaymentRequestLineItem__c
        WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :contract.Id
        AND (ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid') ])
        {
            if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
                if(PaymentSummaryMap.containsKey(PaymentLine.ASI_CRM_CN_Expense_Type__c)){
                    PaymentSummaryMap.get(PaymentLine.ASI_CRM_CN_Expense_Type__c).PaymentRequestAmount += PaymentLine.ASI_TH_CRM_Amount__c !=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                }else{ // dont contain in the map
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=PaymentLine.ASI_CRM_CN_AC_Code__c;
                    tempData.Name=PaymentLine.ASI_CRM_CN_Expense_Type__c;
                    tempData.PaymentRequestAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    PaymentSummaryMap.put(tempData.Name, tempData);
                }
            }else if(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()>3){

                //Including 000- Payment
                if(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.substring(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()-3, PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()) == '000'){
                    String PaymentSummaryKey ='';
                    Decimal PaymentAmount=0;
                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_BRSF'){
                        PaymentSummaryKey=BRSFName;
                        PaymentAmount=PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){
                        PaymentSummaryKey=PSFName;
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_VEC'){
                        PaymentSummaryKey=VECName;
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentSummaryMap.containsKey(PaymentSummaryKey)){//ASI_CRM_CN_Total_Payable__c
                        PaymentSummaryMap.get(PaymentSummaryKey).PaymentRequestAmount += PaymentAmount;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=PaymentSummaryKey;
                        tempData.PaymentRequestAmount=PaymentAmount;
                        PaymentSummaryMap.put(PaymentSummaryKey, tempData);
                    }

                }

            }

        }



        for(ASI_TH_CRM_PaymentRequest__c PaymentRequest : [SELECT Id,Name,ASI_TH_CRM_Status__c,(SELECT Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c FROM ASI_CRM_Modules__r)
        FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = :contract.Id AND (ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted' OR ASI_TH_CRM_Status__c = 'Paid') ])
        {//or
            for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){
                System.debug(module.ASI_CRM_Line_Type__c+'Actual_Payment Amount11:'+module.ASI_CRM_Actual_Payment__c);
                if(module.ASI_CRM_Line_Type__c=='BRSF'){
                    if(PaymentSummaryMap.containsKey(BRSFName)){
                        PaymentSummaryMap.get(BRSFName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=BRSFName;
                        tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        PaymentSummaryMap.put(BRSFName, tempData);
                    }
                }

                if(module.ASI_CRM_Line_Type__c=='PSF'){
                    if(PaymentSummaryMap.containsKey(PSFName)){
                        PaymentSummaryMap.get(PSFName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=PSFName;
                        tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        PaymentSummaryMap.put(PSFName, tempData);
                    }
                }

                if(module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                    if(PaymentSummaryMap.containsKey(VECName)){
                        PaymentSummaryMap.get(VECName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=VECName;
                        tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        PaymentSummaryMap.put(VECName, tempData);
                    }
                }

            }
        }

        List<PaymentSummary> PaymentSummaryList= new List<PaymentSummary>();

        for(String key:PaymentSummaryMap.keySet()){
            PaymentSummaryList.add(PaymentSummaryMap.get(key));
        }



        return PaymentSummaryList;
    }

    public static List<PaymentSummary> POModificationPaymentSummaryTable2nd( ASI_TH_CRM_Contract__c contract){
        Map<String,PaymentSummary> PaymentSummaryMap = new Map<String,PaymentSummary> ();
        String FixedName = '固定费用';
        String BRSFName='空瓶回收费';
        String PSFName='合同奖励';
        String VECName= '活动赞助成本';

        Boolean haveFixed = false;
        Id lastContractID; // Last version  Contract Id
        if(contract!=null){
            lastContractID = contract.ASI_CRM_CN_Last_PO_version__c;
        }

        //Contract Cost Setting
        // for(ASI_CRM_Contract_Cost__c ContractCost:[SELECT Id, Name,ASI_CRM_Other_Est__c,ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c  FROM ASI_CRM_Contract_Cost__c
        // WHERE ASI_CRM_CN_Contract__c = :contract.Id OR ASI_CRM_CN_Contract__c=:lastContractID  ORDER BY ASI_CRM_CN_Sequence__c ASC,
        //     ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC])
        // {
        //     if(PaymentSummaryMap.containsKey(ContractCost.ASI_CRM_CN_Chinese_Description__c)){
        //         if(ContractCost.ASI_CRM_CN_Contract__c==lastContractID){
        //             PaymentSummaryMap.get(ContractCost.ASI_CRM_CN_Chinese_Description__c).LastVersion_POEstimatedAmount += ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
        //         }else{
        //             PaymentSummaryMap.get(ContractCost.ASI_CRM_CN_Chinese_Description__c).POEstimatedAmount += ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
        //         }
        //     }else{ // dont contain in the map
        //         PaymentSummary tempData= new PaymentSummary();
        //         tempData.ACCodeId=ContractCost.ASI_CRM_CN_Activity_Code__c;
        //         tempData.Name=ContractCost.ASI_CRM_CN_Chinese_Description__c;
        //         tempData.EnglishDescription=ContractCost.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c;
        //         if(ContractCost.ASI_CRM_CN_Contract__c==lastContractID){
        //             tempData.LastVersion_POEstimatedAmount=ContractCost.ASI_CRM_CN_Estimate_Amount__c!=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
        //         }else{
        //             tempData.POEstimatedAmount=ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
        //         }
        //         PaymentSummaryMap.put(tempData.Name, tempData);
        //     }

        // }

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:[SELECT Id,ASI_CRM_Module__c, ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :contract.Id  OR ASI_CRM_CN_Contract__c=:lastContractID  ] )
        {
            if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                if(PaymentSummaryMap.containsKey(BRSFName)){
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        PaymentSummaryMap.get(BRSFName).LastVersion_POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        // PaymentSummaryMap.get(BRSFName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                    }
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=BRSFName;
                    tempData.EnglishDescription='BRSF';
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        tempData.LastVersion_POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        //tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                    }
                    PaymentSummaryMap.put(BRSFName, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='PSF'){
                if(PaymentSummaryMap.containsKey(PSFName)){
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        PaymentSummaryMap.get(PSFName).LastVersion_POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        // PaymentSummaryMap.get(PSFName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=PSFName;
                    tempData.EnglishDescription='PRC - PSF & Trading Term Incentives';
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        tempData.LastVersion_POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        //  tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                    }
                    PaymentSummaryMap.put(PSFName, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                if(PaymentSummaryMap.containsKey(VECName)){
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        PaymentSummaryMap.get(VECName).LastVersion_POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        //  PaymentSummaryMap.get(VECName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=VECName;
                    tempData.EnglishDescription='PRC - Variable Event Cost';
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        tempData.LastVersion_POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        //  tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                    PaymentSummaryMap.put(VECName, tempData);
                }
            }

            //3.31edit Fixed Fee
            if (ContractLine.ASI_CRM_Type__c == 'Fixed') {
                if(PaymentSummaryMap.containsKey(FixedName+'---'+ContractLine.ASI_CRM_CN_Activity_Code__c)){
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        PaymentSummaryMap.get(FixedName+'---'+ContractLine.ASI_CRM_CN_Activity_Code__c).LastVersion_POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        // PaymentSummaryMap.get(FixedName+'---'+ContractLine.ASI_CRM_CN_Activity_Code__c).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=FixedName + '-' + ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c;
                    tempData.EnglishDescription=ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c;
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        tempData.LastVersion_POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }else{
                        //  tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                    }
                    haveFixed = true;
                    PaymentSummaryMap.put(FixedName+'---'+ContractLine.ASI_CRM_CN_Activity_Code__c, tempData);
                }
            }
            
        }//End of looping  Contract Line

        //ASI_CRM_CN_Expected_BRSF_Est_Total__c
        if(PaymentSummaryMap.containsKey(BRSFName)){
            if(contract.ASI_CRM_CN_PO_Version__c!='0.1' && contract.ASI_CRM_Copied_From__c!=null){
                PaymentSummaryMap.get(BRSFName).LastVersion_POEstimatedAmount=contract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_BRSF_Est_Total__c;
            }
            PaymentSummaryMap.get(BRSFName).POEstimatedAmount +=contract.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null? contract.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
        }
        if(PaymentSummaryMap.containsKey(PSFName)){
            if(contract.ASI_CRM_CN_PO_Version__c!='0.1' && contract.ASI_CRM_Copied_From__c!=null ){
                PaymentSummaryMap.get(PSFName).LastVersion_POEstimatedAmount=contract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c;
            }
            PaymentSummaryMap.get(PSFName).POEstimatedAmount +=contract.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null? contract.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        }
        if(PaymentSummaryMap.containsKey(VECName)){
            if(contract.ASI_CRM_CN_PO_Version__c!='0.1' && contract.ASI_CRM_Copied_From__c!=null  ){
                PaymentSummaryMap.get(VECName).LastVersion_POEstimatedAmount=contract.ASI_CRM_Copied_From__r.ASI_CRM_EVC_Cost_Estimate_Total__c;
            }
            PaymentSummaryMap.get(VECName).POEstimatedAmount +=contract.ASI_CRM_EVC_Cost_Estimate_Total__c!=null? contract.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
        }
        

        if (haveFixed) {
            System.debug(LoggingLevel.INFO, '*** haveFixed: ' + haveFixed);
            for (String key : PaymentSummaryMap.keySet()) {
                if (key.contains(FixedName)) {
                    List<String> tempStrList = key.split('---');
                    ASI_CRM_CN_FixedMappingSetting__c setting = ASI_CRM_CN_FixedMappingSetting__c.getInstance(tempStrList.get(1));
                    if(contract.ASI_CRM_CN_PO_Version__c!='0.1' && contract.ASI_CRM_Copied_From__c!=null ){
                        ASI_TH_CRM_Contract__c copiedContract = contract.ASI_CRM_Copied_From__r;
                        PaymentSummaryMap.get(key).LastVersion_POEstimatedAmount = (Decimal)copiedContract.get(setting.ASI_CRM_CN_Contract_Mapping_Field__c);
                    }
                    if (PaymentSummaryMap.get(key).POEstimatedAmount == null) {
                        PaymentSummaryMap.get(key).POEstimatedAmount = 0;
                    }
                    if (setting != null) {
                        PaymentSummaryMap.get(key).POEstimatedAmount +=(contract.get(setting.ASI_CRM_CN_Contract_Mapping_Field__c)!=null? (Decimal)contract.get(setting.ASI_CRM_CN_Contract_Mapping_Field__c):0);
                    }

                }
            }
        }



        //RecordType.DeveloperName like 'ASI_CRM_CN%'
        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [SELECT Id, Name,ASI_TH_CRM_Payment_Request__r.Name, RecordType.DeveloperName,ASI_CRM_CN_Total_Payable__c, RecordTypeId, ASI_TH_CRM_Amount__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_AC_Code__c
        FROM ASI_TH_CRM_PaymentRequestLineItem__c
        WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :contract.Id
        AND (ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid') ])
        {
            String PaymentSummaryKey ='';
            String EnglishDescription='';
            Decimal PaymentAmount=0;
            // if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
            //     PaymentSummaryKey = FixedName+'---'+PaymentLine.ASI_CRM_CN_AC_Code__c;
            //     PaymentAmount=PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0;
            // }else 

            if(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()>3){

                //Including 000- Payment
                if(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.substring(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()-3, PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()) == '000'){

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_BRSF'){
                        PaymentSummaryKey=BRSFName;
                        EnglishDescription = 'BRSF';
                        PaymentAmount=PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){
                        PaymentSummaryKey=PSFName;
                        EnglishDescription='PRC - PSF & Trading Term Incentives';
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_VEC'){
                        PaymentSummaryKey=VECName;
                        EnglishDescription='PRC - Variable Event Cost';
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
                        PaymentSummaryKey = FixedName+'---'+PaymentLine.ASI_CRM_CN_AC_Code__c;
                        EnglishDescription=PaymentLine.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c;
                        PaymentAmount=PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0;
                    }

                    if(PaymentSummaryMap.containsKey(PaymentSummaryKey)){//ASI_CRM_CN_Total_Payable__c
                        PaymentSummaryMap.get(PaymentSummaryKey).PaymentRequestAmount += PaymentAmount;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        if (PaymentSummaryKey.contains(FixedName)) {
                            tempData.Name = FixedName + PaymentLine.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c;

                        } else {
                            tempData.Name=PaymentSummaryKey;
                        }
                        tempData.EnglishDescription = EnglishDescription;
                        tempData.PaymentRequestAmount=PaymentAmount;
                        PaymentSummaryMap.put(PaymentSummaryKey, tempData);
                    }
                }
            }

        }



        for(ASI_TH_CRM_PaymentRequest__c PaymentRequest : [SELECT Id,Name,ASI_TH_CRM_Status__c, (SELECT Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c,ASI_CRM_CN_AC_Code__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c  FROM ASI_CRM_Modules__r)
        FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = :contract.Id AND (ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted' OR ASI_TH_CRM_Status__c = 'Paid') ])
        {//or
            for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){
                System.debug(module.ASI_CRM_Line_Type__c+'Actual_Payment Amount11:'+module.ASI_CRM_Actual_Payment__c);
                if(module.ASI_CRM_Line_Type__c=='BRSF'){
                    if(PaymentSummaryMap.containsKey(BRSFName)){
                        PaymentSummaryMap.get(BRSFName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=BRSFName;
                        tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        PaymentSummaryMap.put(BRSFName, tempData);
                    }
                }

                if(module.ASI_CRM_Line_Type__c=='PSF'){
                    if(PaymentSummaryMap.containsKey(PSFName)){
                        PaymentSummaryMap.get(PSFName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=PSFName;
                        tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        PaymentSummaryMap.put(PSFName, tempData);
                    }
                }

                if(module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                    if(PaymentSummaryMap.containsKey(VECName)){
                        PaymentSummaryMap.get(VECName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=VECName;
                        tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        PaymentSummaryMap.put(VECName, tempData);
                    }
                }


                if(module.ASI_CRM_Line_Type__c== 'Fixed'){
                    if(PaymentSummaryMap.containsKey(FixedName+'---'+module.ASI_CRM_CN_AC_Code__c)){
                        PaymentSummaryMap.get(FixedName+'---'+module.ASI_CRM_CN_AC_Code__c).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=FixedName + '-' + module.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c;
                        tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        PaymentSummaryMap.put(FixedName+'---'+module.ASI_CRM_CN_AC_Code__c, tempData);
                    }
                }

            }
        }

        List<PaymentSummary> PaymentSummaryList= new List<PaymentSummary>();

        for(String key:PaymentSummaryMap.keySet()){
            PaymentSummaryList.add(PaymentSummaryMap.get(key));
        }



        return PaymentSummaryList;
    }






    //For Payment View Page
    public static List<PaymentSummary> PaymentSummaryTable(ASI_TH_CRM_PaymentRequest__c payment, ASI_TH_CRM_Contract__c contract){
        Map<String,PaymentSummary> PaymentSummaryMap = new Map<String,PaymentSummary> (); //AC Code/ PaymentSummary Table
        String BRSFName='空瓶回收费';
        String PSFName='合同奖励';
        String VECName= '活动费用(变动)';

        //*********************Contract Cost Looping******************************************
        for(ASI_CRM_Contract_Cost__c ContractCost:[SELECT Id, Name, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c  FROM ASI_CRM_Contract_Cost__c
        WHERE ASI_CRM_CN_Contract__c = :contract.Id ORDER BY ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC])
        {
            if(PaymentSummaryMap.containsKey(ContractCost.ASI_CRM_CN_Chinese_Description__c))
            {
                PaymentSummaryMap.get(ContractCost.ASI_CRM_CN_Chinese_Description__c).POEstimatedAmount += ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
            }else{ // dont contain in the map
                PaymentSummary tempData= new PaymentSummary();
                tempData.ACCodeId=ContractCost.ASI_CRM_CN_Activity_Code__c;
                tempData.Name=ContractCost.ASI_CRM_CN_Chinese_Description__c;
                tempData.POEstimatedAmount=ContractCost.ASI_CRM_CN_Estimate_Amount__c!=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
                PaymentSummaryMap.put(tempData.Name, tempData);
            }
        }


        //******************************************Contract Line******************************************
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:[SELECT Id,ASI_CRM_Module__c, ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :contract.Id ] )
        {
            if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                if(PaymentSummaryMap.containsKey(BRSFName)){
                    PaymentSummaryMap.get(BRSFName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=BRSFName;
                    tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                    PaymentSummaryMap.put(BRSFName, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='PSF'){
                if(PaymentSummaryMap.containsKey(PSFName)){
                    PaymentSummaryMap.get(PSFName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=PSFName;
                    tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    PaymentSummaryMap.put(PSFName, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                if(PaymentSummaryMap.containsKey(VECName)){
                    PaymentSummaryMap.get(VECName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=VECName;
                    tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    PaymentSummaryMap.put(VECName, tempData);
                }
            }
        }//End of looping  Contract Line

        if(contract.ASI_CRM_CN_PO_Version__c!='0.0'){
            if(PaymentSummaryMap.containsKey(PSFName)){
                PaymentSummaryMap.get(PSFName).POEstimatedAmount = contract.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null? contract.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
            }else{
                PaymentSummary tempData= new PaymentSummary();
                tempData.Name=PSFName;
                tempData.POEstimatedAmount= contract.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?  contract.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
                PaymentSummaryMap.put(PSFName, tempData);
            }

        }

        //RecordType.DeveloperName like 'ASI_CRM_CN%'
        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [SELECT Id, Name,ASI_TH_CRM_Payment_Request__r.Name,ASI_CRM_CN_Total_Payable__c,ASI_TH_CRM_Payment_Request__c, RecordType.DeveloperName, RecordTypeId, ASI_TH_CRM_Amount__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_AC_Code__c
        FROM ASI_TH_CRM_PaymentRequestLineItem__c
        WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :contract.Id
        AND (ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid'
        OR ASI_TH_CRM_Payment_Request__c = :payment.Id )  ])
        {
            if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
                if(PaymentSummaryMap.containsKey(PaymentLine.ASI_CRM_CN_Expense_Type__c)){
                    if(PaymentLine.ASI_TH_CRM_Payment_Request__c==payment.Id){
                        PaymentSummaryMap.get(PaymentLine.ASI_CRM_CN_Expense_Type__c).PaymentRequestAmount += PaymentLine.ASI_TH_CRM_Amount__c !=null? PaymentLine.ASI_TH_CRM_Amount__c:0;//tempData.PaymentRequestAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }else{
                        PaymentSummaryMap.get(PaymentLine.ASI_CRM_CN_Expense_Type__c).PaidAmount += PaymentLine.ASI_TH_CRM_Amount__c !=null? PaymentLine.ASI_TH_CRM_Amount__c:0;// tempData.PaidAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                }else{ // dont contain in the map
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=PaymentLine.ASI_CRM_CN_AC_Code__c;
                    tempData.Name=PaymentLine.ASI_CRM_CN_Expense_Type__c;
                    if(PaymentLine.ASI_TH_CRM_Payment_Request__c==payment.Id){
                        tempData.PaymentRequestAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }else{
                        tempData.PaidAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    PaymentSummaryMap.put(tempData.Name, tempData);
                }
            }else if(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()>3){
                if(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.substring(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()-3, PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()) == '000'){
                    Decimal PaymentAmount=0;
                    String PaymentSummaryKey ='';
                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_BRSF'){
                        PaymentSummaryKey=BRSFName;
                        PaymentAmount=PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){
                        PaymentSummaryKey=PSFName;
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_VEC'){
                        PaymentSummaryKey=VECName;
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentSummaryMap.containsKey(PaymentSummaryKey)){
                        PaymentSummaryMap.get(PaymentSummaryKey).PaidAmount +=PaymentAmount;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=PaymentSummaryKey;
                        tempData.PaidAmount=PaymentAmount;
                        PaymentSummaryMap.put(PaymentSummaryKey, tempData);
                    }
                }
            }


        }



        //PaidAmount
        for(ASI_TH_CRM_PaymentRequest__c PaymentRequest : [SELECT Id,Name,ASI_TH_CRM_Status__c,(SELECT Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c,ASI_CRM_Payment_Request__c FROM ASI_CRM_Modules__r)
        FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = :contract.Id AND
        (ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted' OR ASI_TH_CRM_Status__c = 'Paid' OR Id= :payment.Id )])
        {
            for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){
                if(module.ASI_CRM_Line_Type__c=='BRSF'){
                    if(PaymentSummaryMap.containsKey(BRSFName)){
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            PaymentSummaryMap.get(BRSFName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            PaymentSummaryMap.get(BRSFName).PaidAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=BRSFName;
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            tempData.PaidAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                        PaymentSummaryMap.put(BRSFName, tempData);
                    }
                }

                if(module.ASI_CRM_Line_Type__c=='PSF'){
                    if(PaymentSummaryMap.containsKey(PSFName)){
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            PaymentSummaryMap.get(PSFName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            PaymentSummaryMap.get(PSFName).PaidAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=PSFName;
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            tempData.PaidAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                        PaymentSummaryMap.put(PSFName, tempData);
                    }
                }

                if(module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                    if(PaymentSummaryMap.containsKey(VECName)){
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            PaymentSummaryMap.get(VECName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            PaymentSummaryMap.get(VECName).PaidAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=VECName;
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            tempData.PaidAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                        PaymentSummaryMap.put(VECName, tempData);
                    }
                }

            }
        }

        List<PaymentSummary> PaymentSummaryList= new List<PaymentSummary>();

        for(String key:PaymentSummaryMap.keySet()){
            PaymentSummaryList.add(PaymentSummaryMap.get(key));
        }

        return PaymentSummaryList;
    }

    //For Payment View Page 2nd
    public static List<PaymentSummary> PaymentSummaryTable2nd(ASI_TH_CRM_PaymentRequest__c payment, ASI_TH_CRM_Contract__c contract){
        Map<String,PaymentSummary> PaymentSummaryMap = new Map<String,PaymentSummary> (); //AC Code/ PaymentSummary Table
        String BRSFName='空瓶回收费';
        String PSFName='合同奖励';
        String VECName= '活动费用(变动)';

        ASI_TH_CRM_Contract__c contractSeleted = getContract(contract.Id);

        //*********************Contract Cost Looping******************************************
        for(ASI_CRM_Contract_Cost__c ContractCost:[SELECT Id, Name, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c  FROM ASI_CRM_Contract_Cost__c
        WHERE ASI_CRM_CN_Contract__c = :contract.Id ORDER BY ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC])
        {
            if(PaymentSummaryMap.containsKey(ContractCost.ASI_CRM_CN_Chinese_Description__c))
            {
                PaymentSummaryMap.get(ContractCost.ASI_CRM_CN_Chinese_Description__c).POEstimatedAmount += ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
            }else{ // dont contain in the map
                PaymentSummary tempData= new PaymentSummary();
                tempData.ACCodeId=ContractCost.ASI_CRM_CN_Activity_Code__c;
                tempData.Name=ContractCost.ASI_CRM_CN_Chinese_Description__c;
                tempData.POEstimatedAmount=ContractCost.ASI_CRM_CN_Estimate_Amount__c!=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
                PaymentSummaryMap.put(tempData.Name, tempData);
            }
        }


        //******************************************Contract Line******************************************
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:[SELECT Id,ASI_CRM_Module__c, ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c,
        ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c, 
        ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :contract.Id ] ){
            if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                if(PaymentSummaryMap.containsKey(BRSFName)){
                    PaymentSummaryMap.get(BRSFName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=BRSFName;
                    tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total__c!=null? ContractLine.ASI_CRM_CN_Est_Total__c:0;
                    PaymentSummaryMap.put(BRSFName, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='PSF'){
                if(PaymentSummaryMap.containsKey(PSFName)){
                    PaymentSummaryMap.get(PSFName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=PSFName;
                    tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    PaymentSummaryMap.put(PSFName, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='Fixed'){
                if(PaymentSummaryMap.containsKey(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c)){
                    PaymentSummaryMap.get(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c;
                    tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    PaymentSummaryMap.put(ContractLine.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                if(PaymentSummaryMap.containsKey(VECName)){
                    PaymentSummaryMap.get(VECName).POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=VECName;
                    tempData.POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    PaymentSummaryMap.put(VECName, tempData);
                }
            }
        }//End of looping  Contract Line

        if(contract.ASI_CRM_CN_PO_Version__c!='0.0'){
            if(PaymentSummaryMap.containsKey(PSFName)){
                PaymentSummaryMap.get(PSFName).POEstimatedAmount = contractSeleted.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null? contractSeleted.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
            }else{
                PaymentSummary tempData= new PaymentSummary();
                tempData.Name=PSFName;
                tempData.POEstimatedAmount= contractSeleted.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?  contractSeleted.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
                PaymentSummaryMap.put(PSFName, tempData);
            }

            if(PaymentSummaryMap.containsKey(BRSFName)){
                PaymentSummaryMap.get(BRSFName).POEstimatedAmount = contractSeleted.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null? contractSeleted.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
            }else{
                PaymentSummary tempData= new PaymentSummary();
                tempData.Name=BRSFName;
                tempData.POEstimatedAmount= contractSeleted.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=null?  contractSeleted.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
                PaymentSummaryMap.put(BRSFName, tempData);
            }

            if(PaymentSummaryMap.containsKey(VECName)){
                PaymentSummaryMap.get(VECName).POEstimatedAmount = contractSeleted.ASI_CRM_EVC_Cost_Estimate_Total__c!=null? contractSeleted.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
            }else{
                PaymentSummary tempData= new PaymentSummary();
                tempData.Name=VECName;
                tempData.POEstimatedAmount= contractSeleted.ASI_CRM_EVC_Cost_Estimate_Total__c!=null?  contractSeleted.ASI_CRM_EVC_Cost_Estimate_Total__c:0;
                PaymentSummaryMap.put(VECName, tempData);
            }

            Map<String,ASI_CRM_CN_FixedMappingSetting__c> settingMap = ASI_CRM_CN_FixedMappingSetting__c.getAll();

            for (String key :  PaymentSummaryMap.keySet()) {
                if (key != BRSFName && key != PSFName && key != VECName) {
                    PaymentSummary tempData = PaymentSummaryMap.get(key);
                    if (settingMap.containsKey(tempData.ACCodeId) && 
                        contractSeleted.get(settingMap.get(tempData.ACCodeId).ASI_CRM_CN_Contract_Mapping_Field__c) != null && 
                        String.valueOf(contractSeleted.get(settingMap.get(tempData.ACCodeId).ASI_CRM_CN_Contract_Mapping_Field__c)) != null && 
                        String.valueOf(contractSeleted.get(settingMap.get(tempData.ACCodeId).ASI_CRM_CN_Contract_Mapping_Field__c)) != '') {
                        tempData.POEstimatedAmount = Decimal.valueOf(String.valueOf(contractSeleted.get(settingMap.get(tempData.ACCodeId).ASI_CRM_CN_Contract_Mapping_Field__c)));
                    }
                }
            }
        }

        //RecordType.DeveloperName like 'ASI_CRM_CN%'
        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [SELECT Id, Name,ASI_TH_CRM_Payment_Request__r.Name,ASI_CRM_CN_Total_Payable__c,ASI_TH_CRM_Payment_Request__c, RecordType.DeveloperName, RecordTypeId, ASI_TH_CRM_Amount__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_AC_Code__c,
        ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c FROM ASI_TH_CRM_PaymentRequestLineItem__c
        WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :contract.Id
        AND (ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid'
        OR ASI_TH_CRM_Payment_Request__c = :payment.Id )  ])
        {
            // if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
            //     if(PaymentSummaryMap.containsKey(PaymentLine.ASI_CRM_CN_Expense_Type__c)){
            //         if(PaymentLine.ASI_TH_CRM_Payment_Request__c==payment.Id){
            //             PaymentSummaryMap.get(PaymentLine.ASI_CRM_CN_Expense_Type__c).PaymentRequestAmount += PaymentLine.ASI_TH_CRM_Amount__c !=null? PaymentLine.ASI_TH_CRM_Amount__c:0;//tempData.PaymentRequestAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
            //         }else{
            //             PaymentSummaryMap.get(PaymentLine.ASI_CRM_CN_Expense_Type__c).PaidAmount += PaymentLine.ASI_TH_CRM_Amount__c !=null? PaymentLine.ASI_TH_CRM_Amount__c:0;// tempData.PaidAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
            //         }

            //     }else{ // dont contain in the map
            //         PaymentSummary tempData= new PaymentSummary();
            //         tempData.ACCodeId=PaymentLine.ASI_CRM_CN_AC_Code__c;
            //         tempData.Name=PaymentLine.ASI_CRM_CN_Expense_Type__c;
            //         if(PaymentLine.ASI_TH_CRM_Payment_Request__c==payment.Id){
            //             tempData.PaymentRequestAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
            //         }else{
            //             tempData.PaidAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
            //         }

            //         PaymentSummaryMap.put(tempData.Name, tempData);
            //     }
            // }else 
            if(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()>3){
                if(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.substring(PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()-3, PaymentLine.ASI_TH_CRM_Payment_Request__r.Name.length()) == '000'){
                    Decimal PaymentAmount=0;
                    String PaymentSummaryKey ='';
                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
                        PaymentSummaryKey=PaymentLine.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c;
                        PaymentAmount=PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_BRSF'){
                        PaymentSummaryKey=BRSFName;
                        PaymentAmount=PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){
                        PaymentSummaryKey=PSFName;
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_VEC'){
                        PaymentSummaryKey=VECName;
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentSummaryMap.containsKey(PaymentSummaryKey)){
                        PaymentSummaryMap.get(PaymentSummaryKey).PaidAmount +=PaymentAmount;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=PaymentSummaryKey;
                        tempData.PaidAmount=PaymentAmount;
                        PaymentSummaryMap.put(PaymentSummaryKey, tempData);
                    }
                }
            }


        }



        //PaidAmount
        for(ASI_TH_CRM_PaymentRequest__c PaymentRequest : [SELECT Id,Name,ASI_TH_CRM_Status__c,(SELECT Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c,ASI_CRM_Payment_Request__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c FROM ASI_CRM_Modules__r)
        FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = :contract.Id AND
        (ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted' OR ASI_TH_CRM_Status__c = 'Paid' OR Id= :payment.Id )])
        {
            for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){
                if(module.ASI_CRM_Line_Type__c=='BRSF'){
                    if(PaymentSummaryMap.containsKey(BRSFName)){
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            PaymentSummaryMap.get(BRSFName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            PaymentSummaryMap.get(BRSFName).PaidAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=BRSFName;
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            tempData.PaidAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                        PaymentSummaryMap.put(BRSFName, tempData);
                    }
                }

                if(module.ASI_CRM_Line_Type__c=='PSF'){
                    if(PaymentSummaryMap.containsKey(PSFName)){
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            PaymentSummaryMap.get(PSFName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            PaymentSummaryMap.get(PSFName).PaidAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=PSFName;
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            tempData.PaidAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                        PaymentSummaryMap.put(PSFName, tempData);
                    }
                }

                if(module.ASI_CRM_Line_Type__c=='Fixed'){
                    if(PaymentSummaryMap.containsKey(module.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c)){
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            PaymentSummaryMap.get(module.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            PaymentSummaryMap.get(module.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c).PaidAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=module.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c;
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            tempData.PaidAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                        PaymentSummaryMap.put(module.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c, tempData);
                    }
                }


                if(module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                    if(PaymentSummaryMap.containsKey(VECName)){
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            PaymentSummaryMap.get(VECName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            PaymentSummaryMap.get(VECName).PaidAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=VECName;
                        if(module.ASI_CRM_Payment_Request__c==payment.Id){
                            tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }else{
                            tempData.PaidAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        }
                        PaymentSummaryMap.put(VECName, tempData);
                    }
                }

            }
        }

        List<PaymentSummary> PaymentSummaryList= new List<PaymentSummary>();

        for(String key:PaymentSummaryMap.keySet()){
            PaymentSummaryList.add(PaymentSummaryMap.get(key));
        }

        return PaymentSummaryList;
    }


    //Generate BRSF Line when Contratc create
    public static  void GeneratingBRSFLine(ASI_TH_CRM_Contract__c contract){

        String BRSFActivityCodeId='';
        ASI_CRM_Module__c Module = new ASI_CRM_Module__c();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFLineInsert= new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        //********************Insert module*************************************************************************
        //Find Default value for BRSF
        List<ASI_CRM_Methodology__c> MethodologyList=[SELECT Id,ASI_CRM_Default__c FROM ASI_CRM_Methodology__c WHERE ASI_CRM_Type__c='BRSF' AND ASI_CRM_Default__c = TRUE AND RecordType.DeveloperName ='ASI_CRM_CN_Methodology'];
        // Sub-Brand Grade Map: Sub-Brand Grade Id,Sub-Brand Grade Object
        if(MethodologyList.size()>0){
            List<ASI_CRM_Module__c> InsertModuleList = new List<ASI_CRM_Module__c>();

            if(contract.ASI_CRM_CN_Group_Contract__c!=null){ // this is Group Contract
                //Finding Group Contract
                ASI_TH_CRM_Contract__c NationalGroup =[SELECT Id,ASI_CRM_NationalGroup__c FROM  ASI_TH_CRM_Contract__c WHERE  Id=:contract.ASI_CRM_CN_Group_Contract__c];


                //ASI_CRM_Group_Contract__c
                if(NationalGroup.ASI_CRM_NationalGroup__c !=null){ // if KA Account is not null
                    ASI_CRM_KA_Account__c KAAccount = [SELECT Id,ASI_CRM_VEC_Methodology__c,ASI_CRM_VEC_Unit__c,ASI_CRM_VEC_Volume_Base__c,ASI_CRM_BRSF_Methodology__c,ASI_CRM_BRSF_Unit__c,ASI_CRM_BRSF_Volume_Base__c,
                        ASI_CRM_PSF_Meth_Mod1__c,ASI_CRM_PSF_Meth_Mod2__c,ASI_CRM_PSF_Meth_Mod3__c,
                        ASI_CRM_PSF_Unit_Mod1__c,ASI_CRM_PSF_Unit_Mod2__c,ASI_CRM_PSF_Unit_Mod3__c,
                        ASI_CRM_PSF_Volume_Base_Mod1__c,ASI_CRM_PSF_Volume_Base_Mod2__c,ASI_CRM_PSF_Volume_Base_Mod3__c
                    FROM ASI_CRM_KA_Account__c WHERE Id=:NationalGroup.ASI_CRM_NationalGroup__c];

                    if(KAAccount.ASI_CRM_BRSF_Methodology__c!=null){
                        Module= new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_BRSF_Methodology__c,
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(Module);
                    }

                    if(KAAccount.ASI_CRM_PSF_Meth_Mod1__c!=null && KAAccount.ASI_CRM_PSF_Unit_Mod1__c!=null  && KAAccount.ASI_CRM_PSF_Volume_Base_Mod1__c!=null ){
                        ASI_CRM_Module__c TempModule =new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_PSF_Meth_Mod1__c,
                            ASI_CRM_Line_Type__c='PSF',
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Unit__c = KAAccount.ASI_CRM_PSF_Unit_Mod1__c,
                            ASI_CRM_Volume_Base__c=KAAccount.ASI_CRM_PSF_Volume_Base_Mod1__c,
                            ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(TempModule);
                    }
                    if(KAAccount.ASI_CRM_PSF_Meth_Mod2__c!=null && KAAccount.ASI_CRM_PSF_Unit_Mod2__c!=null  && KAAccount.ASI_CRM_PSF_Volume_Base_Mod2__c!=null ){
                        ASI_CRM_Module__c TempModule =new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_PSF_Meth_Mod2__c,
                            ASI_CRM_Line_Type__c='PSF',
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Unit__c = KAAccount.ASI_CRM_PSF_Unit_Mod2__c,
                            ASI_CRM_Volume_Base__c=KAAccount.ASI_CRM_PSF_Volume_Base_Mod2__c,
                            ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(TempModule);
                    }
                    if(KAAccount.ASI_CRM_PSF_Meth_Mod3__c!=null && KAAccount.ASI_CRM_PSF_Unit_Mod3__c!=null  && KAAccount.ASI_CRM_PSF_Volume_Base_Mod3__c!=null ){
                        ASI_CRM_Module__c TempModule =new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_PSF_Meth_Mod3__c,
                            ASI_CRM_Line_Type__c='PSF',
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Unit__c = KAAccount.ASI_CRM_PSF_Unit_Mod3__c,
                            ASI_CRM_Volume_Base__c=KAAccount.ASI_CRM_PSF_Volume_Base_Mod3__c,
                            ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(TempModule);
                    }
                    if(KAAccount.ASI_CRM_VEC_Methodology__c!=null && KAAccount.ASI_CRM_VEC_Unit__c!=null  && KAAccount.ASI_CRM_VEC_Volume_Base__c!=null ){
                        ASI_CRM_Module__c TempModule =new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_VEC_Methodology__c,
                            ASI_CRM_Line_Type__c='Variable Event Cost',
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Unit__c = KAAccount.ASI_CRM_VEC_Unit__c,
                            ASI_CRM_Volume_Base__c=KAAccount.ASI_CRM_VEC_Volume_Base__c,
                            ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(TempModule);
                    }

                    if(InsertModuleList.size()>0){

                        insert InsertModuleList;
                    }
                }


            }else{
                Module= new ASI_CRM_Module__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Contract__c=contract.Id);
                InsertModuleList.add(Module);

                if(InsertModuleList.size()>0){
                    try{
                        insert InsertModuleList;
                    }catch(Exception e){
                        String msg = 'Save Error : ' +e.getMessage() + '</br>';
                        ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine class have Error:  '+msg,'GeneratingBRSFLine','Contract Id: '+contract );
                    }
                }

            }

        }


        //----- get Contract Cost Setting List and then get ASI_CRM_CN_Activity_Code__c
        for (ASI_CRM_Contract_Cost_Setting__c ContractCostSetting:[SELECT Id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_BRSF_Activity_Code_Default__c,ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c, ASI_CRM_CN_Other_Cost_Payment_Request__c FROM ASI_CRM_Contract_Cost_Setting__c WHERE ASI_CRM_CN_Promotion_Type__c='Heavy Contract On']) {
            if(ContractCostSetting.ASI_CRM_CN_BRSF_Activity_Code_Default__c){
                //if(ContractCostSetting.name.contains('Bottle Return Service')){
                BRSFActivityCodeId=ContractCostSetting.ASI_CRM_CN_Activity_Code__c;
            }
        }
        ASI_CRM_AccountsAdditionalField__c Outlet = new ASI_CRM_AccountsAdditionalField__c();

        try{
            Outlet = [SELECT Id,ASI_CRM_CN_CCity__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_New_Image__c,ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_Commercial_Team__c FROM ASI_CRM_AccountsAdditionalField__c
            WHERE Id =:contract.ASI_CRM_CN_Outlet_WS__c  AND ASI_CRM_CN_New_Image__c!=NULL AND ASI_CRM_CN_NewChannel__c !=NULL];
        }catch(Exception e){


        }
        //SubBrandGradeMap: Sub Brand name + Region + Commercial Team,  ASI_CRM_Sub_Brand_Grade__c
        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  = new Map<String,ASI_CRM_Sub_Brand_Grade__c>();
        //Central Region Prestige GeneratingSubBrandGrade(Outlet.ASI_CRM_CN_Region__c,Outlet.ASI_CRM_CN_Commercial_Team__c)
        for(ASI_CRM_Sub_Brand_Grade__c sbg:[SELECT Id, Name,ASI_CRM_CN_City_Tier__c,ASI_CRM_External_Key__c,ASI_CRM_CN_Incentive__c,RecordType.DeveloperName,ASI_CRM_Incentive_for_PSF__c,
            ASI_CRM_Max_Incentive_for_PSF__c,ASI_CRM_Max_Incentive__c
        FROM ASI_CRM_Sub_Brand_Grade__c WHERE
        RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade' OR
        ( RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade_Heavy_Contract_ON'
        AND ASI_CRM_Commercial_Team__c = :Outlet.ASI_CRM_CN_Commercial_Team__c
        AND ASI_CRM_Region__c = :Outlet.ASI_CRM_CN_Region__c) ])
        {
            if(sbg.ASI_CRM_CN_City_Tier__c!=null){
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }else{
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
            }

        }


        if(Outlet.ASI_CRM_CN_NewChannel__c!=null && Outlet.ASI_CRM_CN_New_Image__c  !=null){
            // Segmentation Criteria Map
            Map<String,ASI_CRM_SegmentationCriteria__c> SCMap =new Map<String,ASI_CRM_SegmentationCriteria__c>();
            for(ASI_CRM_SegmentationCriteria__c SCLine: [SELECT Id,ASI_CRM_Outlet_New_Image__c,ASI_CRM_Channel__c,(SELECT Id,ASI_CRM_Sub_Brand__c,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name FROM Sub_Brand_Assignments__r )
            FROM ASI_CRM_SegmentationCriteria__c WHERE RecordType.DeveloperName =:'ASI_CRM_CN_Segmentation_Criteria'
            AND ASI_CRM_Channel__c = :Outlet.ASI_CRM_CN_NewChannel__c AND ASI_CRM_Outlet_New_Image__c =: Outlet.ASI_CRM_CN_New_Image__c
            AND ASI_CRM_Channel__c !=NULL AND ASI_CRM_Outlet_New_Image__c !=NULL ])
            {
                for(ASI_CRM_Sub_Brand_Assignment__c  Assignments:SCLine.Sub_Brand_Assignments__r){
                    Decimal Incentive=0.0;
                    String ExternalKey=Assignments.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name; //ExternalKey=ASI_CRM_CN_Region__c,ASI_CRM_CN_Commercial_Team__c
                    ExternalKey+=Outlet.ASI_CRM_CN_Region__c;
                    ExternalKey+=Outlet.ASI_CRM_CN_Commercial_Team__c;

                    String CityTierExternalKey = ExternalKey;
                    if(Outlet.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c !=null){
                        CityTierExternalKey+= CityTierGeneration(Outlet.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
                    }
                    if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                        Incentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive__c;
                    }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                        Incentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_CN_Incentive__c;
                    }else if(SubBrandGradeMap.containsKey(Assignments.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name)){
                        Incentive=SubBrandGradeMap.get(Assignments.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name).ASI_CRM_CN_Incentive__c;
                    }

                    ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine= new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=contract.Id,
                        ASI_CRM_Module__c=Module.Id,
                        ASI_CRM_CN_Activity_Code__c=BRSFActivityCodeId,
                        ASI_CRM_CN_Est_BRSF_Per_Bottle__c=Incentive,
                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=Incentive,
                        ASI_CRM_Sub_Brand_Grade__c=Assignments.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_CN_Sub_Brand__c =Assignments.ASI_CRM_Sub_Brand__c,
                        ASI_CRM_Type__c='BRSF',RecordTypeId=BRSFLineRtId);
                    BRSFLineInsert.add(BRSFLine);
                }
            }

        }

        if(BRSFLineInsert !=null && BRSFLineInsert.size()>0){
            insert BRSFLineInsert;
        }


    }

    //Generate BRSF Line when Contratc create
    public static  void GeneratingBRSFLine2nd(ASI_TH_CRM_Contract__c contract){

        String BRSFActivityCodeId='';
        ASI_CRM_Module__c Module = new ASI_CRM_Module__c();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFLineInsert= new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        //********************Insert module*************************************************************************
        //Find Default value for BRSF
        List<ASI_CRM_Methodology__c> MethodologyList=[SELECT Id,ASI_CRM_Default__c FROM ASI_CRM_Methodology__c WHERE ASI_CRM_Type__c='BRSF' AND ASI_CRM_Default__c = TRUE AND RecordType.DeveloperName ='ASI_CRM_CN_Methodology'];
        // Sub-Brand Grade Map: Sub-Brand Grade Id,Sub-Brand Grade Object
        if(MethodologyList.size()>0){
            List<ASI_CRM_Module__c> InsertModuleList = new List<ASI_CRM_Module__c>();

            if(contract.ASI_CRM_CN_Group_Contract__c!=null){ // this is Group Contract
                //Finding Group Contract
                ASI_TH_CRM_Contract__c NationalGroup =[SELECT Id,ASI_CRM_NationalGroup__c FROM  ASI_TH_CRM_Contract__c WHERE  Id=:contract.ASI_CRM_CN_Group_Contract__c];


                //ASI_CRM_Group_Contract__c
                if(NationalGroup.ASI_CRM_NationalGroup__c !=null){ // if KA Account is not null
                    ASI_CRM_KA_Account__c KAAccount = [SELECT Id,ASI_CRM_VEC_Methodology__c,ASI_CRM_VEC_Unit__c,ASI_CRM_VEC_Volume_Base__c,ASI_CRM_BRSF_Methodology__c,ASI_CRM_BRSF_Unit__c,ASI_CRM_BRSF_Volume_Base__c,
                        ASI_CRM_PSF_Meth_Mod1__c,ASI_CRM_PSF_Meth_Mod2__c,ASI_CRM_PSF_Meth_Mod3__c,
                        ASI_CRM_PSF_Unit_Mod1__c,ASI_CRM_PSF_Unit_Mod2__c,ASI_CRM_PSF_Unit_Mod3__c,
                        ASI_CRM_PSF_Volume_Base_Mod1__c,ASI_CRM_PSF_Volume_Base_Mod2__c,ASI_CRM_PSF_Volume_Base_Mod3__c
                    FROM ASI_CRM_KA_Account__c WHERE Id=:NationalGroup.ASI_CRM_NationalGroup__c];

                    if(KAAccount.ASI_CRM_BRSF_Methodology__c!=null){
                        Module= new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_BRSF_Methodology__c,
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(Module);
                    }

                    if(KAAccount.ASI_CRM_PSF_Meth_Mod1__c!=null && KAAccount.ASI_CRM_PSF_Unit_Mod1__c!=null  && KAAccount.ASI_CRM_PSF_Volume_Base_Mod1__c!=null ){
                        ASI_CRM_Module__c TempModule =new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_PSF_Meth_Mod1__c,
                            ASI_CRM_Line_Type__c='PSF',
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Unit__c = KAAccount.ASI_CRM_PSF_Unit_Mod1__c,
                            ASI_CRM_Volume_Base__c=KAAccount.ASI_CRM_PSF_Volume_Base_Mod1__c,
                            ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(TempModule);
                    }
                    if(KAAccount.ASI_CRM_PSF_Meth_Mod2__c!=null && KAAccount.ASI_CRM_PSF_Unit_Mod2__c!=null  && KAAccount.ASI_CRM_PSF_Volume_Base_Mod2__c!=null ){
                        ASI_CRM_Module__c TempModule =new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_PSF_Meth_Mod2__c,
                            ASI_CRM_Line_Type__c='PSF',
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Unit__c = KAAccount.ASI_CRM_PSF_Unit_Mod2__c,
                            ASI_CRM_Volume_Base__c=KAAccount.ASI_CRM_PSF_Volume_Base_Mod2__c,
                            ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(TempModule);
                    }
                    if(KAAccount.ASI_CRM_PSF_Meth_Mod3__c!=null && KAAccount.ASI_CRM_PSF_Unit_Mod3__c!=null  && KAAccount.ASI_CRM_PSF_Volume_Base_Mod3__c!=null ){
                        ASI_CRM_Module__c TempModule =new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_PSF_Meth_Mod3__c,
                            ASI_CRM_Line_Type__c='PSF',
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Unit__c = KAAccount.ASI_CRM_PSF_Unit_Mod3__c,
                            ASI_CRM_Volume_Base__c=KAAccount.ASI_CRM_PSF_Volume_Base_Mod3__c,
                            ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(TempModule);
                    }
                    if(KAAccount.ASI_CRM_VEC_Methodology__c!=null && KAAccount.ASI_CRM_VEC_Unit__c!=null  && KAAccount.ASI_CRM_VEC_Volume_Base__c!=null ){
                        ASI_CRM_Module__c TempModule =new ASI_CRM_Module__c(ASI_CRM_Methodology__c=KAAccount.ASI_CRM_VEC_Methodology__c,
                            ASI_CRM_Line_Type__c='Variable Event Cost',
                            ASI_CRM_Group_Contract__c=true,
                            ASI_CRM_Unit__c = KAAccount.ASI_CRM_VEC_Unit__c,
                            ASI_CRM_Volume_Base__c=KAAccount.ASI_CRM_VEC_Volume_Base__c,
                            ASI_CRM_Contract__c=contract.Id);
                        InsertModuleList.add(TempModule);
                    }

                    if(InsertModuleList.size()>0){

                        insert InsertModuleList;
                    }
                }


            }else{
                Module= new ASI_CRM_Module__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Contract__c=contract.Id);
                InsertModuleList.add(Module);

                if(InsertModuleList.size()>0){
                    try{
                        insert InsertModuleList;
                    }catch(Exception e){
                        String msg = 'Save Error : ' +e.getMessage() + '</br>';
                        ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingBRSFLine class have Error:  '+msg,'GeneratingBRSFLine','Contract Id: '+contract );
                    }
                }

            }

        }


        //----- get Contract Cost Setting List and then get ASI_CRM_CN_Activity_Code__c
        for (ASI_CRM_Contract_Cost_Setting__c ContractCostSetting:[SELECT Id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_BRSF_Activity_Code_Default__c,ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c, ASI_CRM_CN_Other_Cost_Payment_Request__c FROM ASI_CRM_Contract_Cost_Setting__c WHERE ASI_CRM_CN_Promotion_Type__c='Heavy Contract On']) {
            if(ContractCostSetting.ASI_CRM_CN_BRSF_Activity_Code_Default__c){
                //if(ContractCostSetting.name.contains('Bottle Return Service')){
                BRSFActivityCodeId=ContractCostSetting.ASI_CRM_CN_Activity_Code__c;
            }
        }
        ASI_CRM_AccountsAdditionalField__c Outlet = new ASI_CRM_AccountsAdditionalField__c();

        try{
            Outlet = [SELECT Id,ASI_CRM_CN_CCity__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_New_Image__c,ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_Commercial_Team__c FROM ASI_CRM_AccountsAdditionalField__c
            WHERE Id =:contract.ASI_CRM_CN_Outlet_WS__c  AND ASI_CRM_CN_New_Image__c!=NULL AND ASI_CRM_CN_NewChannel__c !=NULL];
        }catch(Exception e){


        }

        Set<Id> subBrandIdSets = new Set<Id>();

        for (ASI_MFM_Sub_brand__c brand : [SELECT Id FROM ASI_MFM_Sub_brand__c]) {
            subBrandIdSets.add(brand.Id);
        }
        // List<Date> dateList = new List<Date>();
        Date setDate = FYConversion(Date.today());
        // dateList.add(setDate);

        String channel = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
        String region = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
        String cityInvestementGrade = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
        String newImage = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;

        Map<String, ASI_CRM_CM_GS__c> gsMap = GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdSets);
        //SubBrandGradeMap: Sub Brand name + Region + Commercial Team,  ASI_CRM_Sub_Brand_Grade__c
        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  = new Map<String,ASI_CRM_Sub_Brand_Grade__c>();
        //Central Region Prestige GeneratingSubBrandGrade(Outlet.ASI_CRM_CN_Region__c,Outlet.ASI_CRM_CN_Commercial_Team__c)
        for(ASI_CRM_Sub_Brand_Grade__c sbg:[SELECT Id, Name,ASI_CRM_CN_City_Tier__c,ASI_CRM_External_Key__c,ASI_CRM_CN_Incentive__c,RecordType.DeveloperName,ASI_CRM_Incentive_for_PSF__c,
            ASI_CRM_Max_Incentive_for_PSF__c,ASI_CRM_Max_Incentive__c
        FROM ASI_CRM_Sub_Brand_Grade__c WHERE
        RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade' OR
        ( RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade_Heavy_Contract_ON'
        AND ASI_CRM_Commercial_Team__c = :Outlet.ASI_CRM_CN_Commercial_Team__c
        AND ASI_CRM_Region__c = :Outlet.ASI_CRM_CN_Region__c) ])
        {
            if(sbg.ASI_CRM_CN_City_Tier__c!=null){
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }else{
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
            }

        }


        if(Outlet.ASI_CRM_CN_NewChannel__c!=null && Outlet.ASI_CRM_CN_New_Image__c  !=null){
            // Segmentation Criteria Map
            Map<String,ASI_CRM_SegmentationCriteria__c> SCMap =new Map<String,ASI_CRM_SegmentationCriteria__c>();
            for(ASI_CRM_SegmentationCriteria__c SCLine: [SELECT Id,ASI_CRM_Outlet_New_Image__c,ASI_CRM_Channel__c,(SELECT Id,ASI_CRM_Sub_Brand__c,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name FROM Sub_Brand_Assignments__r )
            FROM ASI_CRM_SegmentationCriteria__c WHERE RecordType.DeveloperName =:'ASI_CRM_CN_Segmentation_Criteria'
            AND ASI_CRM_Channel__c = :Outlet.ASI_CRM_CN_NewChannel__c AND ASI_CRM_Outlet_New_Image__c =: Outlet.ASI_CRM_CN_New_Image__c
            AND ASI_CRM_Channel__c !=NULL AND ASI_CRM_Outlet_New_Image__c !=NULL ])
            {
                for(ASI_CRM_Sub_Brand_Assignment__c  Assignments:SCLine.Sub_Brand_Assignments__r){
                    Decimal Incentive;
                    if (gsMap.containsKey(Assignments.ASI_CRM_Sub_Brand__c)) {
                        Incentive=gsMap.get(Assignments.ASI_CRM_Sub_Brand__c).ASI_CRM_CN_Incentive_BRSF__c;
                    }
                    if (Incentive == null) {
                        String ExternalKey=Assignments.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name; //ExternalKey=ASI_CRM_CN_Region__c,ASI_CRM_CN_Commercial_Team__c
                        ExternalKey+=Outlet.ASI_CRM_CN_Region__c;
                        ExternalKey+=Outlet.ASI_CRM_CN_Commercial_Team__c;

                        String CityTierExternalKey = ExternalKey;
                        if(Outlet.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c !=null){
                            CityTierExternalKey+= CityTierGeneration(Outlet.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
                        }
                        if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                            Incentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive__c;
                        }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                            Incentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_CN_Incentive__c;
                        }else if(SubBrandGradeMap.containsKey(Assignments.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name)){
                            Incentive=SubBrandGradeMap.get(Assignments.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name).ASI_CRM_CN_Incentive__c;
                        }
                    }

                    ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine= new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=contract.Id,
                        ASI_CRM_Module__c=Module.Id,
                        ASI_CRM_CN_Activity_Code__c=BRSFActivityCodeId,
                        ASI_CRM_CN_Est_BRSF_Per_Bottle__c=Incentive,
                        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=Incentive,
                        ASI_CRM_Sub_Brand_Grade__c=Assignments.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_CN_Sub_Brand__c =Assignments.ASI_CRM_Sub_Brand__c,
                        ASI_CRM_Type__c='BRSF',RecordTypeId=BRSFLineRtId);
                    BRSFLineInsert.add(BRSFLine);
                }
            }

        }

        if(BRSFLineInsert !=null && BRSFLineInsert.size()>0){
            insert BRSFLineInsert;
        }


    }


    public static String CityTierGeneration(String InputCityTier){
        if(InputCityTier=='5' || InputCityTier=='6'){
            return 'Other';
        }else{
            return InputCityTier;
        }
    }





    //Retrieve  Check Point Criteria Map   : Channel + Division > Region + Channel > Division > Region > Channel         //.size()
    public static Map<String,ASI_CRM_SegmentationCriteria__c> RetrieveCheckPointCriteriaMap(ASI_TH_CRM_Contract__c contract, String RecordTypeName)
    {
        String SoqlStatement ='select Id,ASI_CRM_Floating_Interval_Percent_Up__c,ASI_CRM_Floating_Interval_Percent_Down__c , ASI_CRM_Floating_Interval_Down__c,ASI_CRM_Floating_Interval_Up__c,ASI_CRM_Max_Value__c,ASI_CRM_Min_Value__c, ASI_CRM_RVP_Special_Approval__c,ASI_CRM_Alignment_Value__c,ASI_CRM_Operation__c,AS_CRM_Predefined_Theoretical_Value__c,ASI_CRM_Alignment_Percentage__c,ASI_CRM_1st_Dimension__c,ASI_CRM_2nd_Dimension__c,ASI_CRM_Region__c,ASI_CRM_Channel__c,ASI_CRM_Division__c,ASI_CRM_Financial_Indicator__c,ASI_CRM_Region__r.name,ASI_CRM_Chinese_Interpretation__c,ASI_CRM_English_Interpretation__c '+ ' from ASI_CRM_SegmentationCriteria__c where RecordType.DeveloperName= \''+RecordTypeName+'\'  ';
        //Financial Indicator, Segmentation Criteria
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmentationCriteriaMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();


        // SQL1 : Channel + Division ,  Division = null
        if( contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c!=null && contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c !=null ){
            String AddOnStatement=' and ASI_CRM_Division__r.name = \''+contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c
                +'\'  and ASI_CRM_Channel__c = \''+contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c+'\' and ASI_CRM_Division__r.name  =null';
            SegmentationCriteriaMap=SQLSegmentationCriteria(SegmentationCriteriaMap,SoqlStatement+ AddOnStatement );
            System.debug('Enter SQL 1'+SoqlStatement+ AddOnStatement);
        }

        //SQL2 : Region + Channel ,  Division = null
        if(SegmentationCriteriaMap.size()==0 && contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null && contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c !=null ){
            String AddOnStatement=' and ASI_CRM_Region__r.name = \''+contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c
                +'\'  and ASI_CRM_Channel__c = \''+contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c+'\' and  ASI_CRM_Division__r.name = Null ';
            SegmentationCriteriaMap=SQLSegmentationCriteria(SegmentationCriteriaMap,SoqlStatement+ AddOnStatement );
            System.debug('Enter SQL 2'+SoqlStatement+ AddOnStatement);
        }

        //Division
        if( SegmentationCriteriaMap.size()==0 && contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c!=null){
            String AddOnStatement=' and ASI_CRM_Division__r.name = \''+contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c+
                '\' and  ASI_CRM_Division__r.name = Null and ASI_CRM_Channel__c=null';
            SegmentationCriteriaMap=SQLSegmentationCriteria(SegmentationCriteriaMap,SoqlStatement+ AddOnStatement );
            System.debug('Enter SQL 3'+SoqlStatement+ AddOnStatement);
        }


        //Region
        if(SegmentationCriteriaMap.size()==0 && contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null ){
            String AddOnStatement=' and ASI_CRM_Region__r.name = \''+contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c
                +'\'  and  ASI_CRM_Division__r.name = Null and ASI_CRM_Channel__c=null ';
            SegmentationCriteriaMap=SQLSegmentationCriteria(SegmentationCriteriaMap,SoqlStatement+ AddOnStatement );
            System.debug('Enter SQL 4'+SoqlStatement+ AddOnStatement);

        }

        //Channel
        if(SegmentationCriteriaMap.size()==0 && contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c !=null ){
            String AddOnStatement= ' and ASI_CRM_Region__r.name = Null and ASI_CRM_Division__r.name = Null  and ASI_CRM_Channel__c = \''+contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c+'\' ';
            SegmentationCriteriaMap=SQLSegmentationCriteria(SegmentationCriteriaMap,SoqlStatement+ AddOnStatement );
            System.debug('Enter SQL 5'+SoqlStatement+ AddOnStatement);
        }



        return SegmentationCriteriaMap;
    }


    //SQL Segmentation Criteria Object DaTa
    public static Map<String,ASI_CRM_SegmentationCriteria__c> SQLSegmentationCriteria (Map<String,ASI_CRM_SegmentationCriteria__c> SCMap, String Statement){
        for(ASI_CRM_SegmentationCriteria__c SegmentationCriteria : Database.query(Statement)){
            /*
             * if(!SCMap.containsKey(SegmentationCriteria.ASI_CRM_Financial_Indicator__c)){
                SCMap.put(SegmentationCriteria.ASI_CRM_Financial_Indicator__c, SegmentationCriteria);
            }
            */
            SCMap.put(SegmentationCriteria.Id, SegmentationCriteria);

        }
        return SCMap;
    }











    //return result Object
    public class ReturnResult{
        public String Msg {set;get;} {Msg= '';}
        public Boolean Process {set;get;} {Process=true;}
        public ReturnResult (){}
    }


    //checking the volume if it is ready in SFDC
    public static ReturnResult  CheckingVolumeIsReady(Date InputStartDate, Date InputEndDay){
        ReturnResult tempReturnResult = new ReturnResult ();
        Date cutOffDate = GenerateCutOffDate();
        Date ChangedStartDate;
        Date ChangedEndDate;

        if(InputStartDate != null){
            ChangedStartDate = InputStartDate.toStartOfMonth().addMonths(1).addDays(-1);
        }
        if(InputEndDay != null){
            ChangedEndDate = InputEndDay.toStartOfMonth().addMonths(1).addDays(-1);
        }

        if(cutOffDate < ChangedStartDate || cutOffDate < ChangedEndDate){
            tempReturnResult.Process= false;
            String endString = '';
            endString = Label.ASI_CRM_CN_Volume_Not_Ready;

            Date enddate = cutOffDate.addMonths(1);
            while(enddate <= ChangedEndDate){
                endString += (enddate.year() + '-' + enddate.month() + ', ');
                enddate = enddate.addMonths(1);
            }

            if(enddate>ChangedEndDate){
                endString ='销量尚未更新至SFDC.The volume is not ready yet in SFDC.';
            }else{
                endString += endString.substring(0, endString.length() - 2 );
            }
            //endString += endString.substring(0, endString.length() - 2 );
            tempReturnResult.Msg= endString;
        }


        return tempReturnResult;
    }




    //Change the date to String with formatting
    // can be 'yyyy-MM-dd'
    public static String DateToString (Date InputDate, String formatingString){ //'yyyy-MM-dd'
        Integer d = InputDate.day();
        Integer mo = InputDate.month();
        Integer yr = InputDate.year();
        Datetime DT = Datetime.newInstance(yr, mo, d);
        return  DT.format(formatingString);
    }



    public static Boolean checkUserID(){
        Boolean AdorAbove =false;
        List<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0){
            AdorAbove = true;
        }
        return AdorAbove;
    }

    //Convert Date to String
    public static String ConvertDate(Date strDate){
        String datestring;
        if (strDate != null){
            datestring = String.valueOf(strDate.day()) + '/' + String.valueOf(strDate.month()) + '/' + String.valueOf(strDate.year());
        }else{
            datestring = '';
        }
        return datestring;
    }

    public static Date VolumeCutOffDate(Integer strDay, Date defaultDate, Date startdate){
        Date returnDate;
        Integer strDate = Date.today().day();
        Integer strMonth;
        Integer strEndDay;

        if (defaultDate != null && startdate != null && strDay != null){
            if (strDay != 0){
                if (strDate >= strDay){
                    strMonth = Date.today().month() - 1;
                }
                if (strDate < strDay){
                    strMonth = Date.today().month() - 2;
                }
                strEndDay = Date.daysInMonth(Date.today().year(), strMonth);
                returnDate = Date.newInstance(Date.today().year(),strMonth,strEndDay);
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



    //Sort Descending for Map Name
    public static String NameSorting(Decimal strSeq){
        String returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = '0000' + String.valueOf(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString = '000' + String.valueOf(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString = '00' + String.valueOf(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = '0' + String.valueOf(strSeq);
            }
        }else{
            returnString = '00000';
        }
        returnString = String.valueOf(99999 - Integer.valueOf(returnString));

        return returnString;
    }

    //Sort ascending  for Map Name
    public static String NameSortingASC(Decimal strSeq){
        String returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = '0000' + String.valueOf(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString = '000' + String.valueOf(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString = '00' + String.valueOf(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = '0' + String.valueOf(strSeq);
            }
        }else{
            returnString = '00000';
        }
        return returnString;
    }




    public static String KeyNameSortingASC(Decimal strSeq){
        if(strSeq==0){
            strSeq=9;
        }
        String returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = String.valueOf(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString =  String.valueOf(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString =  String.valueOf(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = String.valueOf(strSeq);
            }
        }else{
            returnString = '0';
        }
        return returnString;
    }


    //Convert two dates into Period (No of Months)
    public static Integer ConvertPeriod(Date startDate, Date endDate){
        Integer strPeriod;
        if (startDate != null && endDate != null){
            strPeriod = ((endDate.year() - startDate.year() - 1) *12) + (12 - startDate.month() +1) + endDate.month();
        }else{
            strPeriod = 0;
        }

        return strPeriod;
    }


    // Getting Historical Module List
    public static List<ASI_CRM_Module__c> HistoricalModuleQuerying(Set<Id> ParentModuleSet,String CurrentPaymentId){
        List<ASI_CRM_Module__c> HistoricalModuleList = new List<ASI_CRM_Module__c>();

        HistoricalModuleList = [SELECT Id,ASI_CRM_Actual_Payment__c,ASI_CRM_End_Date__c,ASI_CRM_Parent_Module__c,ASI_CRM_Line_Type__c,
            ASI_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c, ASI_CRM_Payment_Request__r.ASI_CRM_CN_PO_Start_Date__c,
            ASI_CRM_Payment_Request__r.Name,ASI_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_PSF_Amount__c,
            ASI_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c,ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_Payment_Request__r.ASI_CRM_CN_Total_VEC_Amount__c
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
            Module.ASI_CRM_Actual_Payment__c= Module.ASI_CRM_Actual_Payment__c!=null?Module.ASI_CRM_Actual_Payment__c.setScale(2):0;
        }


        //
        return HistoricalModuleList;
    }



    // Getting Historical Actual Payment in ParentModule
    public static Map<String,Decimal> GetHistoricalModuleAmount(Set<Id> ParentModuleSet,String ContractId, List<ASI_CRM_Module__c> HistoricalPaidModulelist){
        Map<String,Decimal> HistoricalModuleMap = new Map<String,Decimal>();

        String BRSFModuleId='';
        String PSFModuleId='';
        String VECModuleId='';

        //list<ASI_CRM_Module__c> HistoricalPaidModulelist = HistoricalModuleQuerying(ParentModuleSet , CurrentPaymentId);
        for(ASI_CRM_Module__c ModuleItem:HistoricalPaidModulelist){
            if(HistoricalModuleMap.containsKey(ModuleItem.ASI_CRM_Parent_Module__c)){
                Decimal TempAmount= HistoricalModuleMap.get(ModuleItem.ASI_CRM_Parent_Module__c) !=null? HistoricalModuleMap.get(ModuleItem.ASI_CRM_Parent_Module__c) : 0;
                TempAmount =TempAmount+(ModuleItem.ASI_CRM_Actual_Payment__c != null ? ModuleItem.ASI_CRM_Actual_Payment__c : 0);
                HistoricalModuleMap.remove(ModuleItem.ASI_CRM_Parent_Module__c);
                HistoricalModuleMap.put(ModuleItem.ASI_CRM_Parent_Module__c, TempAmount);
            }else{
                HistoricalModuleMap.put(ModuleItem.ASI_CRM_Parent_Module__c,ModuleItem.ASI_CRM_Actual_Payment__c);
            }

            if(ModuleItem.ASI_CRM_Line_Type__c=='BRSF' && BRSFModuleId=='' ){
                BRSFModuleId=ModuleItem.ASI_CRM_Parent_Module__c;
            }
            if(ModuleItem.ASI_CRM_Line_Type__c=='PSF' && PSFModuleId==''){
                PSFModuleId=ModuleItem.ASI_CRM_Parent_Module__c;
            }
            if(ModuleItem.ASI_CRM_Line_Type__c=='Variable Event Cost' && VECModuleId ==''){
                VECModuleId=ModuleItem.ASI_CRM_Parent_Module__c;
            }
        }


        /*
        //For 000-payment
        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [Select id, name,ASI_TH_CRM_Payment_Request__r.Name,ASI_CRM_CN_Total_Payable__c,
                                                               ASI_TH_CRM_Payment_Request__c, RecordType.DeveloperName, recordtypeid, ASI_TH_CRM_Amount__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_AC_Code__c
                                                               from ASI_TH_CRM_PaymentRequestLineItem__c
                                                               where ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :ContractId and ASI_TH_CRM_Payment_Request__r.Name like '%-000%'
                                                               and (ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' or ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted' or
                                                                    ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid'  )  ])
        {
            if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_BRSF'){ // ASI_CRM_CN_Total_Payable__c
                if(HistoricalModuleMap.containsKey(BRSFModuleId)){
                    Decimal TempAmount= HistoricalModuleMap.get(BRSFModuleId) !=null? HistoricalModuleMap.get(BRSFModuleId) : 0;
                    TempAmount =TempAmount+PaymentLine.ASI_CRM_CN_Total_Payable__c;
                    HistoricalModuleMap.remove(BRSFModuleId);
                    HistoricalModuleMap.put(BRSFModuleId, TempAmount);
                }
            }else if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){ //ASI_TH_CRM_Amount__c
                if(HistoricalModuleMap.containsKey(PSFModuleId)){
                    Decimal TempAmount= HistoricalModuleMap.get(PSFModuleId) !=null? HistoricalModuleMap.get(PSFModuleId) : 0;
                    TempAmount =TempAmount+PaymentLine.ASI_TH_CRM_Amount__c;
                    HistoricalModuleMap.remove(PSFModuleId);
                    HistoricalModuleMap.put(PSFModuleId, TempAmount);
                }
            }else if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_VEC'){ //
                if(HistoricalModuleMap.containsKey(VECModuleId)){
                    Decimal TempAmount= HistoricalModuleMap.get(VECModuleId) !=null? HistoricalModuleMap.get(VECModuleId) : 0;
                    TempAmount =TempAmount+PaymentLine.ASI_TH_CRM_Amount__c;
                    HistoricalModuleMap.remove(VECModuleId);
                    HistoricalModuleMap.put(VECModuleId, TempAmount);
                }
            }
        }
            */
        return HistoricalModuleMap;
    }




    // Calculate Total Contract Amount
    public static Decimal CalTotalContractAmount(ASI_TH_CRM_Contract__c Contract){
        Decimal TotalAmount=0.0;
        try {
            if(Contract.ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On' && Contract.ASI_CRM_CN_PO_Version__c=='0.0'){
                TotalAmount += Contract.ASI_CRM_Est_Total_Dummy__c!=null? Contract.ASI_CRM_Est_Total_Dummy__c: 0;
                TotalAmount += Contract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c!=null? Contract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c: 0;
            } else if (Contract.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract') {
                TotalAmount += Contract.ASI_CRM_CN_Total_Contract_Amount__c!=null?Contract.ASI_CRM_CN_Total_Contract_Amount__c:0;
            }else{
                TotalAmount += Contract.ASI_CRM_CN_Total_Contract_Amount__c!=null?Contract.ASI_CRM_CN_Total_Contract_Amount__c:0;
            }
        } catch (Exception e) {
            System.debug('has error in CalTotalContractAmount');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            TotalAmount += Contract.ASI_CRM_Est_Total_Dummy__c!=null? Contract.ASI_CRM_Est_Total_Dummy__c: 0;
            TotalAmount += Contract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c!=null? Contract.ASI_CRM_CN_Contract_Fixed_Cost_Total__c: 0;
        }

        return TotalAmount;
    }






    //*********************************************************
    //@description:Generate Sub-Brand Grade for incentive
    //@param: Commercial Team &  Region Name
    //@return: List of Sub Brand Grade
    // *********************************************************
    public static List<ASI_CRM_Sub_Brand_Grade__c> GeneratingSubBrandGrade(String CommercialTeam,String RegionName){
        List<ASI_CRM_Sub_Brand_Grade__c> TempList = new List<ASI_CRM_Sub_Brand_Grade__c>();

        try{

            TempList = [SELECT Id, Name,ASI_CRM_Chinese_Name__c,ASI_CRM_CN_City_Tier__c,ASI_CRM_External_Key__c,ASI_CRM_CN_Incentive__c,RecordType.DeveloperName,ASI_CRM_Incentive_for_PSF__c,
                ASI_CRM_Max_Incentive_for_PSF__c,ASI_CRM_Max_Incentive__c
            FROM ASI_CRM_Sub_Brand_Grade__c WHERE
            RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade' OR
            ( RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade_Heavy_Contract_ON'
            AND ASI_CRM_Commercial_Team__c = :CommercialTeam
            AND ASI_CRM_Region__c = :RegionName) ];
            System.debug(RegionName+CommercialTeam+'TempList:  '+TempList.size());
        }catch(Exception e){
            TempList = [SELECT Id, Name,ASI_CRM_Chinese_Name__c,ASI_CRM_CN_City_Tier__c,ASI_CRM_External_Key__c,ASI_CRM_CN_Incentive__c,RecordType.DeveloperName,ASI_CRM_Incentive_for_PSF__c,ASI_CRM_Max_Incentive_for_PSF__c,ASI_CRM_Max_Incentive__c
            FROM ASI_CRM_Sub_Brand_Grade__c WHERE
            RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade' OR  RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade_Heavy_Contract_ON'  ];

        }
        /*
        if(CommercialTeam!=null && RegionName!=null){

        }else{
         }

        */

        return TempList;
    }


    //*********************************************************
    //@description:Generate Region SubBrand Incentive
    //@param: Commercial Team &  Region Name & CityInvestementGrade & NewImage & dateList & subBrandIdSets
    //@return: Map of Region SubBrand Incentive
    // *********************************************************
    // public static Map<String,ASI_CRM_CM_GS__c> GeneratingRegionSubBrandIncentive(String Channel,String Region,String CityInvestementGrade, String NewImage, List<Date> dateList, Set<Id> subBrandIdSets){
    //     Map<String,ASI_CRM_CM_GS__c> TempMap = new Map<String,ASI_CRM_CM_GS__c>();

    //     try{
    //         String queryStr = 'SELECT Id, Name, ASI_CRM_CN_Incentive_BRSF__c, ASI_CRM_CN_Incentive_PSF__c, ' + 
    //                             'ASI_CRM_CN_Incentive_VEC__c,ASI_CRM_Max_Incentive_BRSF__c,ASI_CRM_Max_Incentive_PSF__c, ' +
    //                             'ASI_CRM_Max_Incentive_VEC__c, ASI_CRM_CN_Month__c, ASI_CRM_YEAR__c, ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__c, ' + 
    //                             'ASI_CRM_CN_Regional_Average_Index__c, ASI_CRM_CN_Regional_Average_After_Spend__c, ASI_CRM_CN_Regional_Average_Investment__c, ' + 
    //                             '(Select id, ASI_CRM_CN_Activity_Code__c, ASI_MFM_A_C_Description__c,ASI_CRM_CN_Activity_Description__c,ASI_CRM_CN_Incentive__c, ASI_CRM_CN_Max_Incentive__c ' +
    //                             'From Actual_CM_GS_Lines__r )' +
    //                           'FROM ASI_CRM_CM_GS__c ' +
    //                           'WHERE RecordType.DeveloperName =\'ASI_CRM_CN_Regional_Average_Target\' AND '+
    //                           'ASI_CRM_Channel__c =: Channel AND ' + 
    //                           'ASI_CRM_Region__c =: Region  AND ' + 
    //                           'ASI_CRM_CN_City_Investement_Grade__c =: CityInvestementGrade  AND ' + 
    //                           'ASI_CRM_CN_New_Image__c =: NewImage  AND ' + 
    //                           'ASI_CRM_Region__c =: Region  AND ' + 
    //                           'ASI_CRM_CN_Month_End_Date__c in : dateList AND '+
    //                           'ASI_CRM_PRODUCTCODE__c in : subBrandIdSets AND '+
    //                           'Order By ASI_CRM_VERSION__c desc';
            
    //         for (ASI_CRM_CM_GS__c regionValue : Database.query(queryStr))
    //         {
    //             String regionKey = regionValue.ASI_CRM_CN_Month_End_Date__c + '-'+ regionValue.ASI_CRM_PRODUCTCODE__c;
    //             if (!TempMap.containsKey(regionKey))
    //             {
    //                 TempMap.put(regionKey, regionValue);
    //             }
    //         }
    //         System.debug(LoggingLevel.INFO, '*** TempMap: ' + TempMap);
    //     }catch(Exception e){
    //         System.debug(LoggingLevel.INFO, '*** Exception: ' + e.getMessage());
    //     }

    //     return TempMap;
    // }

    //*********************************************************
    //@description:Generate Region SubBrand Target
    //@param: Commercial Team &  Region Name & CityInvestementGrade & NewImage & enddate & subBrandIdSets
    //@return: Map of Region SubBrand Target
    // *********************************************************
    public static Map<String,ASI_CRM_CM_GS__c> GeneratingRegionTarget(String Channel,String Region,String CityInvestementGrade, String NewImage, Date endDate, Set<Id> subBrandIdSets){
        Map<String,ASI_CRM_CM_GS__c> TempMap = new Map<String,ASI_CRM_CM_GS__c>();

        try{
            String queryStr = 'SELECT Id, Name, ASI_CRM_CN_Incentive_BRSF__c, ASI_CRM_CN_Incentive_PSF__c, ' + 
                                'ASI_CRM_CN_Incentive_VEC__c,ASI_CRM_Max_Incentive_BRSF__c,ASI_CRM_Max_Incentive_PSF__c, ' +
                                'ASI_CRM_Max_Incentive_VEC__c, ASI_CRM_CN_Month__c, ASI_CRM_YEAR__c, ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__c, ' + 
                                'ASI_CRM_CN_Regional_Average_Index__c, ASI_CRM_CN_Regional_Average_After_Spend__c, ASI_CRM_CN_Regional_Average_Investment__c, ' + 
                                'ASI_CRM_CN_Domestic_Index_Target__c, ASI_CRM_CN_Domestic_CM_After_Spending__c, ASI_CRM_CN_Domestic_Spending__c, ' + 
                                '(Select id, ASI_CRM_CN_Activity_Code__c, ASI_MFM_A_C_Description__c,ASI_CRM_CN_Activity_Description__c,ASI_CRM_CN_Incentive__c, ASI_CRM_CN_Max_Incentive__c ' +
                                'From Actual_CM_GS_Lines__r )' +
                              'FROM ASI_CRM_CM_GS__c ' +
                              'WHERE RecordType.DeveloperName =\'ASI_CRM_CN_Regional_Average_Target\' AND '+
                              'ASI_CRM_Channel__c =: Channel AND ' + 
                              'ASI_CRM_Region__c =: Region  AND ' + 
                              'ASI_CRM_CN_City_Investment_Grade__c =: CityInvestementGrade  AND ' + 
                              'ASI_CRM_CN_New_Image__c =: NewImage  AND ' + 
                              'ASI_CRM_CN_Month_End_Date__c = : endDate AND '+
                              'ASI_CRM_PRODUCTCODE__c in : subBrandIdSets '+
                              'Order By ASI_CRM_VERSION__c desc';
            
            for (ASI_CRM_CM_GS__c regionValue : Database.query(queryStr))
            {
                if (!TempMap.containsKey(regionValue.ASI_CRM_PRODUCTCODE__c))
                {
                    TempMap.put(regionValue.ASI_CRM_PRODUCTCODE__c, regionValue);
                }
            }
            System.debug(LoggingLevel.INFO, '*** TempMap: ' + TempMap);
        }catch(Exception e){
            System.debug(LoggingLevel.INFO, '*** Exception: ' + e.getMessage());
        }

        return TempMap;
    }

    //*********************************************************
    //@description:Generate Domestic SubBrand Target
    //@param:  enddate & subBrandIdSets
    //@return: Map of Domestic SubBrand Target
    // *********************************************************
    public static Map<String,ASI_CRM_CM_GS__c> GeneratingDomesticTarget(Date endDate, Set<Id> subBrandIdSets){
        Map<String,ASI_CRM_CM_GS__c> TempMap = new Map<String,ASI_CRM_CM_GS__c>();

        try{
            String queryStr = 'SELECT Id, Name, ASI_CRM_CN_Incentive_BRSF__c, ASI_CRM_CN_Incentive_PSF__c, ' + 
                                'ASI_CRM_CN_Incentive_VEC__c,ASI_CRM_Max_Incentive_BRSF__c,ASI_CRM_Max_Incentive_PSF__c, ' +
                                'ASI_CRM_Max_Incentive_VEC__c, ASI_CRM_CN_Month__c, ASI_CRM_YEAR__c, ASI_CRM_CN_Month_End_Date__c, ASI_CRM_PRODUCTCODE__c, ' + 
                                'ASI_CRM_CN_Regional_Average_Index__c, ASI_CRM_CN_Regional_Average_After_Spend__c, ASI_CRM_CN_Regional_Average_Investment__c, ' + 
                                'ASI_CRM_CN_Domestic_Index_Target__c, ASI_CRM_CN_Domestic_CM_After_Spending__c, ASI_CRM_CN_Domestic_Spending__c, ' + 
                                '(Select id, ASI_CRM_CN_Activity_Code__c, ASI_MFM_A_C_Description__c,ASI_CRM_CN_Activity_Description__c,ASI_CRM_CN_Incentive__c, ASI_CRM_CN_Max_Incentive__c ' +
                                'From Actual_CM_GS_Lines__r )' +
                              'FROM ASI_CRM_CM_GS__c ' +
                              'WHERE RecordType.DeveloperName =\'ASI_CRM_CN_Domestic_Target\' AND '+
                              'ASI_CRM_CN_Month_End_Date__c = : endDate AND '+
                              'ASI_CRM_PRODUCTCODE__c in : subBrandIdSets '+
                              'Order By ASI_CRM_VERSION__c desc';
            
            for (ASI_CRM_CM_GS__c domesticValue : Database.query(queryStr))
            {
                if (!TempMap.containsKey(domesticValue.ASI_CRM_PRODUCTCODE__c))
                {
                    TempMap.put(domesticValue.ASI_CRM_PRODUCTCODE__c, domesticValue);
                }
            }
            System.debug(LoggingLevel.INFO, '*** TempMap: ' + TempMap);
        }catch(Exception e){
            System.debug(LoggingLevel.INFO, '*** Exception: ' + e.getMessage());
        }

        return TempMap;
    }



    //Base on current Contract Promotion Types generate related old Promotion Types
    public static Set<String> GeneratingPromotionTypes(String CurrentPromotionType){
        Set<String> oldPromotionTypes = new Set<String>();

        for(ASI_CRM_Special_Promotion_Type_Mapping__c obj:[SELECT Id,ASI_CRM_Mapping_of_New_Promotion_Type__c , ASI_CRM_Mapping_of_Old_Promotion_Type__c ,
            ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c , ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c
        FROM ASI_CRM_Special_Promotion_Type_Mapping__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Special_Promotion_Type_Mapping' AND
        ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c = : CurrentPromotionType ])
        {
            oldPromotionTypes.add(obj.ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c);
        }
        return oldPromotionTypes;
    }






    //Generate Contract Detail Line List by Contract Line Id
    //RecordTypeName: ASI_CRM_CRM_CN_Contract_Heavy_BRSF
    public static  List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> GenerateContractList( String ContractId,String RecordTypeName,String AddFilter){

        Map<String, Schema.SObjectField> ContractLine_FieldMap       = Schema.SObjectType.ASI_CRM_CN_Contract_BRSF_Line_Item__c.fields.getMap();
        String query = 'SELECT ' + genQueryField(ContractLine_FieldMap) + ',ASI_CRM_CN_Sub_Brand__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c, RecordType.DeveloperName  from ASI_CRM_CN_Contract_BRSF_Line_Item__c where ASI_CRM_CN_Contract__c =\''+ ContractId+'\' AND RecordType.DeveloperName=\''+RecordTypeName+'\'' + AddFilter ;
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();
        ContractLineList=Database.query(query);
        return ContractLineList;
    }

    private static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.substring(0, queryField.length() - 1);
    }




    //Genrate Newest Contract by KA Account
    public static ASI_TH_CRM_Contract__c KAAccountQueryNewestContract(String KAAccountId){
        //ASI_CRM_KA_Account__c KAAccount
        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();

        List<ASI_TH_CRM_Contract__c> TempList=[SELECT Id,Name, CreatedDate,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_Martell_BC_Rate__c FROM ASI_TH_CRM_Contract__c
        WHERE (RecordType.DeveloperName ='ASI_CRM_CN_Group_Contract'  OR RecordType.DeveloperName LIKE 'ASI_CRM_CN_Local_Group_Contract%' ) AND
        ASI_CRM_NationalGroup__c =:KAAccountId AND ASI_CRM_Active_Dummy_PO__c=TRUE
        ORDER BY CreatedDate DESC];
        if(TempList.size()>0){
            contract=TempList[0];
        }
        //system.assertEquals(TempList, Null);

        return contract;
    }




    //Generate National contract select option
    public static  List<SelectOption>  GenerateNationalContractOption(String KAAccountId){
        List<SelectOption> NationalContractOption = new List<SelectOption>();  //NationalContractOption.add(new SelectOption('', '--None--'));

        for(ASI_TH_CRM_Contract__c NationalContract: [SELECT Id,Name, CreatedDate FROM ASI_TH_CRM_Contract__c WHERE RecordType.DeveloperName ='ASI_CRM_CN_Group_Contract' AND ASI_CRM_NationalGroup__c =:KAAccountId AND ASI_CRM_Active_Dummy_PO__c=TRUE ORDER BY CreatedDate DESC]){
            NationalContractOption.add(new SelectOption(NationalContract.Id, NationalContract.Name));
        }
        return NationalContractOption;
    }


    //In V0.0 Contract, if user change PO start Date or end date , system will auto-modi the Contract Line
    public static void ContractChangingPeriod(ASI_TH_CRM_Contract__c Contract,Integer OriginalMonth,Date OriginalStartDate,Date OriginalEndDate){
        if( OriginalStartDate!=Contract.ASI_CRM_CN_PO_Start_Date__c || OriginalEndDate != Contract.ASI_CRM_CN_PO_End_Date__c){
            Contract.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c=0;

            Contract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c=0;
            Contract.ASI_CRM_CN_Expected_PSF_Est_Total__c=0;
            Contract.ASI_CRM_V0_PSF_Contract_Total__c=0;

            Contract.ASI_CRM_Expected_V0_0_VEC_Est_Total__c=0;

            ASI_TH_CRM_Contract__c SelectContract= [SELECT Id,ASI_CRM_PSF_Grand_Contract_Total__c,ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,
                ASI_CRM_PSF_Contract_Adjustment_Amount__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,
                ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_PSF_Grand_Estimate_Total__c
            FROM ASI_TH_CRM_Contract__c WHERE Id =:Contract.Id];

            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractDetailList =[SELECT Id,ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Module__c, ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Volume_Base__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
            WHERE ASI_CRM_CN_Contract__c = :Contract.Id] ;
            //Looping all contract Lines
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractDetailList){

                if((ContractLine.ASI_CRM_Type__c=='BRSF') || (ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Volume_Base__c=='By Sub-Brand' ) ||
                    (ContractLine.ASI_CRM_Type__c=='Variable Event Cost' && ContractLine.ASI_CRM_Volume_Base__c=='By Sub-Brand') ){
                    if(ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c !=null && ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c !=null){
                        ContractLine.ASI_CRM_CN_Est_Total_Dummy__c= ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    }
                    if( ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c  !=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c !=null ){
                        ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * SelectContract.ASI_CRM_CN_No_of_Months__c;

                    }

                    if(ContractLine.ASI_CRM_Type__c=='BRSF'){
                        Contract.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c +=  ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }



                }else{

                    ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c = (ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c==null) ? 0:ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    ContractLine.ASI_CRM_Est_Total_QTY_std_Btl__c = (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c==null) ? 0:ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = (ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c==null) ? 0:ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                    ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = (ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c==null) ? 0:ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c * SelectContract.ASI_CRM_CN_No_of_Months__c;
                }
                if(ContractLine.ASI_CRM_Type__c=='PSF'){
                    Contract.ASI_CRM_Expected_V0_PSF_Estimated_Total__c +=  ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    Contract.ASI_CRM_CN_Expected_PSF_Est_Total__c +=  ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    Contract.ASI_CRM_V0_PSF_Contract_Total__c += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                }

                if(ContractLine.ASI_CRM_Type__c=='Variable Event Cost'){
                    Contract.ASI_CRM_Expected_V0_0_VEC_Est_Total__c +=  ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                }
            }

            if(ContractDetailList.size()>0){
                update ContractDetailList;
            }

            update Contract ;
        }
    }










    // format number with comma in apex
    public static String FormatNumber(Decimal InputNumber ){
        List<String> args = new String[]{'0','number','###,###,##0.00'};
        String str = String.format(InputNumber.format(), args);
        return str;

    }


    //Payment check Point Page to calculate all Total Paid Amount
    public static Decimal RetrieveTotalPaidAmount(ASI_TH_CRM_PaymentRequest__c CurrentPayment){
        Decimal allPaymentTotal = 0;
        //Query all payment request with vFinal contract
        List<ASI_TH_CRM_PaymentRequest__c> AllPaymentRequest = new List<ASI_TH_CRM_PaymentRequest__c>();
        try{
            AllPaymentRequest = [SELECT Id,Name,ASI_CRM_Total_Variable_Amount__c,ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c, ASI_CRM_CN_Total_VEC_Amount__c,ASI_CRM_CN_Total_Other_Amount__c, ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE ASI_TH_CRM_Contract__c =:CurrentPayment.ASI_TH_CRM_Contract__c
            AND (Id = :CurrentPayment.Id OR ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted'  OR ASI_TH_CRM_Status__c = 'Paid')];
        }catch(Exception e){
            String msg = 'Save Error : ' +e.getMessage() + '</br>';
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyPaymentCheckCtrl. RetrieveTotalPaidAmount  class have Error  '+msg,'ASI_CRM_CN_HeavyContractUtilitiesClass',' function failed! with Payment Id: '+CurrentPayment.Id );
        }

        //Sum up previous payments amounts
        if (AllPaymentRequest.size() > 0){
            for (ASI_TH_CRM_PaymentRequest__c allPR_temp : AllPaymentRequest){
                if(allPR_temp.ASI_CRM_CN_Promotion_Type__c=='Heavy Contract On'){
                    allPaymentTotal+=allPR_temp.ASI_CRM_Total_Variable_Amount__c!=null?allPR_temp.ASI_CRM_Total_Variable_Amount__c:0;
                }else{
                    allPaymentTotal+=allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c!=null?allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c:0;
                    allPaymentTotal+=allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c!=null?allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c:0;
                    allPaymentTotal+=allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c!=null?allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c:0;
                }

                //if (allPR_temp.ASI_CRM_CN_Total_Payment__c != null){
                //allPaymentTotal += allPR_temp.ASI_CRM_CN_Total_Payment__c;
                //allPaymentTotal+=allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c:0;
                //allPaymentTotal+=allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c:0;
                //allPaymentTotal+=allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c:0;

                //}
            }
        }

        return allPaymentTotal;
    }



    //check Point compare : SecondDimension_1 : Min SecondDimension_2 : Max
    public static Boolean NumberOperationChecking (String Operation, Decimal FirstDimension,Decimal SecondDimension_1,Decimal SecondDimension_2){
        Boolean ReturnFlag = true;
        if(Operation=='Equal to'){
            if(Math.abs(FirstDimension-SecondDimension_1)>0.1){
                ReturnFlag=false;
            }
        }else if(Operation=='Greater than'){
            if(FirstDimension<SecondDimension_1 ){
                ReturnFlag=false;
            }
        }else if(Operation=='Greater than or Equal to'){
            if(FirstDimension<SecondDimension_1 ){
                ReturnFlag=false;
            }
        }else if(Operation=='Less than'){
            if(FirstDimension>=SecondDimension_1 ){
                ReturnFlag=false;
            }
        }else if(Operation=='Less than or Equal to'){
            if(FirstDimension>SecondDimension_1 ){
                ReturnFlag=false;
            }
        }else if(Operation=='Within'){
            System.debug('FirstDimension : '+FirstDimension);
            System.debug('SecondDimension_1 : '+SecondDimension_1);
            System.debug('SecondDimension_2 : '+SecondDimension_2);
            if(FirstDimension<SecondDimension_1 || FirstDimension>SecondDimension_2){
                ReturnFlag=false;
            }
        }

        return ReturnFlag;
    }

    //check Point Date compare
    public static Boolean DateOperationChecking  (String Operation, Date FirstDimension,Date SecondDimension){
        Boolean ReturnFlag = true;

        if(Operation=='Equal to'){
            if(FirstDimension!=SecondDimension){
                ReturnFlag=false;
            }
        }else if(Operation=='Greater than'){
            if(FirstDimension<SecondDimension ){
                ReturnFlag=false;
            }
        }else if(Operation=='Greater than or Equal to'){
            if(FirstDimension<=SecondDimension ){
                ReturnFlag=false;
            }
        }else if(Operation=='Less than'){
            if(FirstDimension>SecondDimension ){
                ReturnFlag=false;
            }
        }

        return ReturnFlag;
    }


    public static Boolean ChangeStringToBoolean(String InputString){
        Boolean ReturnFlag=false;
        return Boolean.valueOf(InputString);
    }



    public static ASI_TH_CRM_Contract__c ArchivePO(ASI_TH_CRM_Contract__c InputContract){
        //---- original child objects ----

        ASI_TH_CRM_Contract__c Contract = [SELECT Id,Name,ASI_CRM_Reject_Return_Comments__c,ASI_CRM_CN_Return_Comments__c,ASI_CRM_CN_Last_Approved_By__c,ASI_CRM_CN_Last_Approved_Date__c,
            ASI_CRM_PSF_Estimate_Adjustment_Amount__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_CN_V0_0_PO_version__c,
            ASI_CRM_V0_PSF_Contract_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_Martell_BC_Rate__c,ASI_CRM_Auto_PO_Modification_Time__c,ASI_CRM_Auto_PO_Modification__c,
            ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_Converted_From__c,
            ASI_CRM_CN_Last_Recall_By__c,ASI_CRM_CN_Last_Recall_Date__c,ASI_CRM_CN_Last_Rejected_By__c,ASI_CRM_CN_Last_Submitted_By__c,
            ASI_CRM_CN_Group_Contract__c, ASI_CRM_Investment_Type__c,ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
            ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,
            ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c , ASI_CRM_Expected_V0_0_VEC_Est_Total__c,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,  ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
            RecordTypeId, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, CreatedDate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, LastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
            ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c,
            ASI_CRM_CN_Expected_Display_Est_Total__c,
            ASI_CRM_CN_V0_Display_Contract_Total__c,
            ASI_CRM_CN_Expected_V0_Display_Est_Total__c,
            ASI_CRM_Prev_Version_Display_Est_Total__c,
            ASI_CRM_Display_Estimate_Adjustment_Amt__c,
            ASI_CRM_CN_Is_Dolphin__c,ASI_CRM_CN_Activity_Times__c,ASI_CRM_CN_Target_Base__c,ASI_CRM_CN_Contract_Classification__c,
        (SELECT Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c FROM ASI_TH_CRM_PaymentRequests_Contract__r)
        FROM ASI_TH_CRM_Contract__c WHERE Id =:InputContract.Id ];


        String whereClause = 'ASI_CRM_CN_Contract__c =\'' + Contract.Id + '\'';
        String whereClauseAtth = 'Parentid = \'' + Contract.Id + '\'';
        String whereClauseFeed = 'Type = \'ContentPost\' AND ParentId = \'' + Contract.Id + '\' AND Id != null ORDER BY ContentFileName';

        //---- get original BRSF line items ----
        String soqlBRSF = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_CN_Contract_BRSF_Line_Item__c', whereClause, 'ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c');
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = Database.query(soqlBRSF);

        //---- get original Contract Cost items ----
        String soqlContractCost = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_Contract_Cost__c', whereClause, '');
        List<ASI_CRM_Contract_Cost__c> LContractCost = Database.query(soqlContractCost);

        //---- get original Covered Outlet items ----
        String soqlCoveredOutlet = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_CN_Covered_Outlet__c', whereClause, '');
        List<ASI_CRM_CN_Covered_Outlet__c>  LCoveredOutlet = Database.query(soqlCoveredOutlet);





        //cloned header
        ASI_TH_CRM_Contract__c ContractCloned = Contract.clone(false, true);
        //ContractCloned.ASI_CRM_CN_V0_0_PO_version__c=Contract.ASI_CRM_CN_V0_0_PO_version__c;
        ContractCloned.ASI_CRM_CN_IsClone__c = true;
        ContractCloned.ASI_TH_CRM_Contract_External_ID__c=null;
        ContractCloned.ASI_CRM_CN_PO_Modification__c = false;
        ContractCloned.ASI_CRM_CN_Status__c = 'Archived';
        ContractCloned.ASI_CRM_CN_PO_Version__c =Contract.ASI_CRM_CN_PO_Version__c;
        ContractCloned.ASI_CRM_Converted_From__c = InputContract.Id; // Master Contract ID
        ContractCloned.Id=null;
        insert ContractCloned;

        //************Detail**********************************************************************************************

        //move Contract Approval Comment
        List<ASI_CRM_Approval_Comment__c> LTransferContractComment_Insert = [SELECT Id, ASI_CRM_Contract__c FROM ASI_CRM_Approval_Comment__c WHERE ASI_CRM_Contract__c =: Contract.Id];
        for(ASI_CRM_Approval_Comment__c tcc : LTransferContractComment_Insert){
            tcc.ASI_CRM_Contract__c = ContractCloned.Id;
        }
        update LTransferContractComment_Insert;



        //------ Process BRSF Line Items ------
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF_Clone = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        if(LBRSF != null && LBRSF.size()>0){
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c originalBRSF :LBRSF) {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c cloneBRSF = originalBRSF.clone(false, true);
                cloneBRSF.ASI_CRM_CN_Contract__c = ContractCloned.Id;
                cloneBRSF.ASI_CRM_CN_External_ID__c=null;
                LBRSF_Clone.add(cloneBRSF);
            }
        }
        if(LBRSF_Clone != null && LBRSF_Clone.size() > 0) {
            insert LBRSF_Clone;
        }

        //------ Process Constract Cost Items ------
        List<ASI_CRM_Contract_Cost__c> LContractCost_Clone = new List<ASI_CRM_Contract_Cost__c>();
        if(LContractCost != null && LContractCost.size()>0){
            for(ASI_CRM_Contract_Cost__c originalCost :LContractCost) {
                ASI_CRM_Contract_Cost__c cloneCost = originalCost.clone(false, true);
                cloneCost.ASI_CRM_CN_Contract__c = ContractCloned.Id;
                cloneCost.ASI_CRM_CN_External_ID__c=null;
                LContractCost_Clone.add(cloneCost);
            }
        }

        if(LContractCost_Clone != null && LContractCost_Clone.size() > 0) {
            insert LContractCost_Clone;
        }




        //------ Process Covered Outlet Items ------
        List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet_Clone = new List<ASI_CRM_CN_Covered_Outlet__c>();

        if(LCoveredOutlet != null && LCoveredOutlet.size()>0)
        {
            for(ASI_CRM_CN_Covered_Outlet__c originalCoveredOutlet :LCoveredOutlet) {
                ASI_CRM_CN_Covered_Outlet__c cloneCoveredOutlet = originalCoveredOutlet.clone(false, true);
                cloneCoveredOutlet.ASI_CRM_CN_Contract__c = ContractCloned.Id;
                cloneCoveredOutlet.ASI_CRM_CN_External_ID__c=null;
                LCoveredOutlet_Clone.add(cloneCoveredOutlet);
            }
        }

        if(LCoveredOutlet_Clone != null && LCoveredOutlet_Clone.size() > 0) {
            insert LCoveredOutlet_Clone;
        }


        ASI_CRM_Approval_Comment__c ApprovalComment=new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c = Contract.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment'));
        insert ApprovalComment;



        return ContractCloned;
    }



    public static ASI_TH_CRM_Contract__c ArchivePO2nd(ASI_TH_CRM_Contract__c InputContract){
        //---- original child objects ----

        ASI_TH_CRM_Contract__c Contract = [SELECT Id,Name,ASI_CRM_Reject_Return_Comments__c,ASI_CRM_CN_Return_Comments__c,ASI_CRM_CN_Last_Approved_By__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_CRM_CN_Last_Approved_Date__c,ASI_CRM_Copied_From__c,
            ASI_CRM_PSF_Estimate_Adjustment_Amount__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_CN_CTD_Monthly_Default_Date__c,
            ASI_CRM_V0_PSF_Contract_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
            ASI_CRM_CN_Fixed_Module_Est_Amount1__c,
                ASI_CRM_CN_Fixed_Module_Est_Amount2__c,ASI_CRM_Martell_BC_Rate__c,ASI_CRM_Auto_PO_Modification_Time__c,ASI_CRM_Auto_PO_Modification__c,
            ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_Converted_From__c,
            ASI_CRM_CN_Last_Recall_By__c,ASI_CRM_CN_Last_Recall_Date__c,ASI_CRM_CN_Last_Rejected_By__c,ASI_CRM_CN_Last_Submitted_By__c,
            ASI_CRM_CN_Group_Contract__c, ASI_CRM_Investment_Type__c,ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
            ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,
            ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c , ASI_CRM_Expected_V0_0_VEC_Est_Total__c,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,  ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
            RecordTypeId, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, CreatedDate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, LastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
            ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c,
            ASI_CRM_CN_Expected_Display_Est_Total__c,
            ASI_CRM_CN_V0_Display_Contract_Total__c,
            ASI_CRM_CN_Expected_V0_Display_Est_Total__c,
            ASI_CRM_Prev_Version_Display_Est_Total__c,
            ASI_CRM_Display_Estimate_Adjustment_Amt__c,

        (SELECT Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c FROM ASI_TH_CRM_PaymentRequests_Contract__r)
        FROM ASI_TH_CRM_Contract__c WHERE Id =:InputContract.Id ];


        String whereClause = 'ASI_CRM_CN_Contract__c =\'' + Contract.Id + '\'';
        String whereClauseAtth = 'Parentid = \'' + Contract.Id + '\'';
        String whereClauseFeed = 'Type = \'ContentPost\' AND ParentId = \'' + Contract.Id + '\' AND Id != null ORDER BY ContentFileName';

        //---- get original BRSF line items ----
        String soqlBRSF = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_CN_Contract_BRSF_Line_Item__c', whereClause, 'ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c');
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = Database.query(soqlBRSF);

        //---- get original Contract Cost items ----
        String soqlContractCost = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_Contract_Cost__c', whereClause, '');
        List<ASI_CRM_Contract_Cost__c> LContractCost = Database.query(soqlContractCost);

        //---- get original Covered Outlet items ----
        String soqlCoveredOutlet = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_CN_Covered_Outlet__c', whereClause, '');
        List<ASI_CRM_CN_Covered_Outlet__c>  LCoveredOutlet = Database.query(soqlCoveredOutlet);





        //cloned header
        ASI_TH_CRM_Contract__c ContractCloned = Contract.clone(false, true);
        //ContractCloned.ASI_CRM_CN_V0_0_PO_version__c=Contract.ASI_CRM_CN_V0_0_PO_version__c;
        ContractCloned.ASI_CRM_CN_IsClone__c = true;
        ContractCloned.ASI_TH_CRM_Contract_External_ID__c=null;
        ContractCloned.ASI_CRM_CN_PO_Modification__c = false;
        ContractCloned.ASI_CRM_CN_Status__c = 'Archived';
        ContractCloned.ASI_CRM_CN_PO_Version__c =Contract.ASI_CRM_CN_PO_Version__c;
        ContractCloned.ASI_CRM_Converted_From__c = InputContract.Id; // Master Contract ID
        ContractCloned.Id=null;

        

        //************Detail**********************************************************************************************

        



        //------ Process BRSF Line Items ------
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF_Clone = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        if (ContractCloned.ASI_CRM_CN_PO_Version__c == '0.0') {
            Map<Id,Decimal> v0FCPerEstimateAmount = new Map<Id,Decimal> ();
            if(LBRSF != null && LBRSF.size()>0){
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c originalBRSF :LBRSF) {
                    if(originalBRSF.ASI_CRM_CN_Sub_Brand__c!=null){// Volume base is by Sub-Brand
                        if(originalBRSF.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c !='999'){

                            //计算上个版本的固定费用单独module的预计总金额
                            if(originalBRSF.ASI_CRM_Type__c== 'Fixed'){
                                if (v0FCPerEstimateAmount.containsKey(originalBRSF.ASI_CRM_CN_Activity_Code__c)) {
                                    Decimal amount = v0FCPerEstimateAmount.get(originalBRSF.ASI_CRM_CN_Activity_Code__c);
                                    amount += originalBRSF.ASI_CRM_CN_Est_Total_Dummy__c;
                                    v0FCPerEstimateAmount.put(originalBRSF.ASI_CRM_CN_Activity_Code__c,amount);
                                } else {
                                    v0FCPerEstimateAmount.put(originalBRSF.ASI_CRM_CN_Activity_Code__c, originalBRSF.ASI_CRM_CN_Est_Total_Dummy__c);
                                }
                            }
                        }
                    }else{
                        if (originalBRSF.ASI_CRM_Type__c == 'Fixed') {
                            // if (originalBRSF.ASI_CRM_Volume_Base__c != 'By Sub-Brand') {
                            if (v0FCPerEstimateAmount.containsKey(originalBRSF.ASI_CRM_CN_Activity_Code__c)) {
                                Decimal amount = v0FCPerEstimateAmount.get(originalBRSF.ASI_CRM_CN_Activity_Code__c);
                                amount += originalBRSF.ASI_CRM_CN_Est_Total_Dummy__c;
                                v0FCPerEstimateAmount.put(originalBRSF.ASI_CRM_CN_Activity_Code__c,amount);
                            } else {
                                v0FCPerEstimateAmount.put(originalBRSF.ASI_CRM_CN_Activity_Code__c, originalBRSF.ASI_CRM_CN_Est_Total_Dummy__c);
                            }
                        }
                    }
                }
            }

            List<ASI_CRM_CN_FixedMappingSetting__c> settingList = new List<ASI_CRM_CN_FixedMappingSetting__c>();
            for (String key : v0FCPerEstimateAmount.keySet()) {
                ASI_CRM_CN_FixedMappingSetting__c setting = ASI_CRM_CN_FixedMappingSetting__c.getInstance(key);
                if (setting != null) {
                    settingList.add(setting);
                }
            }
            // SObject obj = ContractCloned;
            for (ASI_CRM_CN_FixedMappingSetting__c setting : settingList) {
                if (v0FCPerEstimateAmount.containsKey(setting.ASI_CRM_CN_Activity_CodeId__c)) {
                    ContractCloned.put(setting.ASI_CRM_CN_Contract_Mapping_Field__c, v0FCPerEstimateAmount.get(setting.ASI_CRM_CN_Activity_CodeId__c));
                }
            }
        }

        insert ContractCloned;

        //move Contract Approval Comment
        List<ASI_CRM_Approval_Comment__c> LTransferContractComment_Insert = [SELECT Id, ASI_CRM_Contract__c FROM ASI_CRM_Approval_Comment__c WHERE ASI_CRM_Contract__c =: Contract.Id];
        for(ASI_CRM_Approval_Comment__c tcc : LTransferContractComment_Insert){
            tcc.ASI_CRM_Contract__c = ContractCloned.Id;
        }
        update LTransferContractComment_Insert;

                        
        if(LBRSF != null && LBRSF.size()>0){
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c originalBRSF :LBRSF) {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c cloneBRSF = originalBRSF.clone(false, true);
                cloneBRSF.ASI_CRM_CN_Contract__c = ContractCloned.Id;
                cloneBRSF.ASI_CRM_CN_External_ID__c=null;
                cloneBRSF.ASI_CRM_CN_Is_Payment_New__c = false;
                LBRSF_Clone.add(cloneBRSF);
            }
        }
        if(LBRSF_Clone != null && LBRSF_Clone.size() > 0) {
            insert LBRSF_Clone;
        }

        //------ Process Constract Cost Items ------
        List<ASI_CRM_Contract_Cost__c> LContractCost_Clone = new List<ASI_CRM_Contract_Cost__c>();
        if(LContractCost != null && LContractCost.size()>0){
            for(ASI_CRM_Contract_Cost__c originalCost :LContractCost) {
                ASI_CRM_Contract_Cost__c cloneCost = originalCost.clone(false, true);
                cloneCost.ASI_CRM_CN_Contract__c = ContractCloned.Id;
                cloneCost.ASI_CRM_CN_External_ID__c=null;
                LContractCost_Clone.add(cloneCost);
            }
        }

        if(LContractCost_Clone != null && LContractCost_Clone.size() > 0) {
            insert LContractCost_Clone;
        }




        //------ Process Covered Outlet Items ------
        List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet_Clone = new List<ASI_CRM_CN_Covered_Outlet__c>();

        if(LCoveredOutlet != null && LCoveredOutlet.size()>0)
        {
            for(ASI_CRM_CN_Covered_Outlet__c originalCoveredOutlet :LCoveredOutlet) {
                ASI_CRM_CN_Covered_Outlet__c cloneCoveredOutlet = originalCoveredOutlet.clone(false, true);
                cloneCoveredOutlet.ASI_CRM_CN_Contract__c = ContractCloned.Id;
                cloneCoveredOutlet.ASI_CRM_CN_External_ID__c=null;
                LCoveredOutlet_Clone.add(cloneCoveredOutlet);
            }
        }

        if(LCoveredOutlet_Clone != null && LCoveredOutlet_Clone.size() > 0) {
            insert LCoveredOutlet_Clone;
        }


        ASI_CRM_Approval_Comment__c ApprovalComment=new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c = Contract.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment'));
        insert ApprovalComment;



        return ContractCloned;
    }



    //Contract Generation class name helper class
    public static String ContractGenClassNameHandler(String ClassName){
        String ReturnString= '';
        if(ClassName == 'colspan4'){
            ReturnString=' colspan="4" ';
        }
        if(ClassName == 'colspan3'){
            ReturnString=' colspan="3" ';
        }
        if(ClassName == 'rowspan1'){
            ReturnString=' rowspan="1" ';
        }
        if(ClassName == 'rowspan2'){
            ReturnString=' rowspan="2" ';
        }
        if(ClassName == 'rowspan3'){
            ReturnString=' rowspan="3" ';
        }
        if(ClassName == 'rowspan4'){
            ReturnString=' rowspan="4" ';
        }
        if(ClassName == 'rowspan5'){
            ReturnString=' rowspan="5" ';
        }
        if(ClassName == 'rowspan6'){
            ReturnString=' rowspan="6" ';
        }


        return ReturnString;
    }



    public static Boolean checkApprover(String RecordId){
        Boolean AdorAbove = false;
        Set<Id> actorIds = new Set<Id>();
        for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status = 'Pending' AND  ProcessInstance.TargetObjectId = :RecordId]){
            actorIds.add(piw.ActorId);
        }
        List<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId IN :actorIds];
        if(gms.size()>0){
            AdorAbove = true;
        }

        return AdorAbove;
    }






    // Calculate Payment V0.0 Contract Detail Line Contarct Cost (not including Fix cost)
    public static Decimal CalculateV0ContractDetailCost(ASI_TH_CRM_PaymentRequest__c CurrentPayment){
        Decimal ContractAmount=0;

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLines = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();

        String V0ContractId='';
        if(CurrentPayment.ASI_TH_CRM_Contract__c!=null && CurrentPayment.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractId=CurrentPayment.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        }else if(CurrentPayment.ASI_TH_CRM_Contract__c!=null){
            V0ContractId=CurrentPayment.ASI_TH_CRM_Contract__c;
        }

        try{
            //query ContractBRSF Sub Brands & Data
            ContractLines = [SELECT Id, ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Monthly_Qty__c , ASI_CRM_CN_Sub_Brand_Conversion_Factor__c,
                ASI_CRM_CN_Contract__c, ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c,ASI_CRM_CN_Contract_Total_Dummy__c,
                ASI_CRM_CN_Contract_Monthly_Vol9L__c, ASI_CRM_CN_Contract_Monthly_Qty__c,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :V0ContractId];
        }catch(Exception e){
            String msg = 'Save Error : ' +e.getMessage() + '</br>';
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractUtilitiesClass.CalculateV0ContractDetailCost  class have Error  '+msg,'ASI_CRM_CN_HeavyContractUtilitiesClass',' function failed! with Payment Id: '+CurrentPayment.Id );
        }
        if(ContractLines.size()>0){
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractDetail:ContractLines){
                ContractAmount+= contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c!=null? contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            }
        }

        return ContractAmount;
    }



    public static String SBGradeSorting(Decimal strSeq){
        String returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = '0000' + String.valueOf(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString = '000' + String.valueOf(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString = '00' + String.valueOf(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = '0' + String.valueOf(strSeq);
            }
        }else{
            returnString = '00000';
        }
        return returnString;
    }





    public static Date getFiscalYearStart(Date inputDate , Integer orgFiscalMonth){

        Date fiscalYearStart;
        if(inputDate != null){
            fiscalYearStart = Date.newInstance(inputDate.year(), orgFiscalMonth, 1);
            if(inputDate.month() < orgFiscalMonth && inputDate.year() == inputDate.year())
                fiscalYearStart = fiscalYearStart.addYears(-1);
        }

        return fiscalYearStart;
    }

    //FOR ASI_CRM_CN_HeavyGenerateGroupShuttleJob
    public static void UpdateAttachmentHistoricalData(String ContractId, String HistoricalId){
        List<ASI_Attachment__c> TempList = [SELECT Id,ASI_CRM_External_Key__c,ASI_CRM_For_Contract_Use__c,ASI_CRM_Last_Run_Time__c,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_New_Contract_v0_0__c,ASI_CRM_New_Contract_vFinal__c
        FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c =:ContractId AND OwnerId=:UserInfo.getUserId() AND ASI_CRM_Type__c='Group Contract'];

        if(TempList.size()>0){
            ASI_Attachment__c TempRecord= TempList[0];
            TempRecord.ASI_CRM_For_Contract_Use__c=true;
            if(TempRecord.ASI_CRM_Historical_Financial_Data__c=='' || TempRecord.ASI_CRM_Historical_Financial_Data__c==null){
                TempRecord.ASI_CRM_Historical_Financial_Data__c=HistoricalId+';';
            }else{
                TempRecord.ASI_CRM_Historical_Financial_Data__c=TempRecord.ASI_CRM_Historical_Financial_Data__c+=HistoricalId+';';
            } //=TempRecord.ASI_CRM_Historical_Financial_Data__c+HistoricalId+';';
            update TempRecord;
        }
    }

    public static String CheckPointTranslation(String InputString){
        if(InputString=='Historical V0.0'){
            InputString='旧合同V0.0';
        }else if(InputString=='Historical Vfinal'){
            InputString='旧合同最终版';
        }else if(InputString=='New Contact V0.0 Contract'){
            InputString='新合同V0.0合同';
        }else if(InputString=='New Contract V0.0 Est.'){
            InputString='新合同V0.0预估';
        }else if(InputString=='New Contract V Final'){
            InputString='新合同最终版';
        }else if(InputString=='Payment Speed%'){
            InputString='付款进度(除固定费用）';
        }else if(InputString=='Theoretical Value'){
            InputString='建议值';
        }else if(InputString=='Predefined Theoretical Value'){
            InputString='建议值';
        }else if(InputString=='Volume Speed%'){
            InputString='销量完成率';
        }else if(InputString=='PRC Guidance'){
            InputString='公司规定';
        }else if(InputString=='PO Submit Date'){
            InputString='PO提交日期';
        }else if(InputString=='PRC Default Methodology'){
            InputString='公司建议计算方式';
        }else if(InputString=='PRC Default Volume Base'){
            InputString='公司建议计算基础';
        }else if(InputString=='Min Key Strategy Achievement Rate'){
            InputString='最低战略品牌完成率';
        } else if(InputString=='Total Volume Achievement Rate'){
            InputString='销量完成率';
        } else if(InputString=='Purchase Value Speed%'){
            InputString='销售额达成率';
        } else if(InputString=='Payment Amount'){
            InputString='付款金额';
        } else if(InputString=='Suggested Payment Amount'){
            InputString='系统建议付款金额';
        }
        return InputString;
    }

    public static String VolumeBaseTranslation(String VolumeBaseName){
        if(VolumeBaseName!=null){
            if(VolumeBaseName.contains('Sub-Brand')){
                VolumeBaseName+='(按品牌)';
            }
            if(VolumeBaseName.contains('Grade')){
                VolumeBaseName+='(按品牌档次)';
            }
            if(VolumeBaseName.contains('Category')){
                VolumeBaseName+='(按产品类别)';
            }
            if(VolumeBaseName.contains('Total')){
                VolumeBaseName+='(按总销量)';
            }
        }

        return VolumeBaseName;

    }

    //FOR ASI_CRM_CN_HeavyGenerateGroupShuttleJob
    public static void UpdateAttachmentContractData(String ContractId, String v00Id,String vFinalId){
        List<ASI_Attachment__c> TempList = [SELECT Id,ASI_CRM_External_Key__c,ASI_CRM_For_Contract_Use__c,ASI_CRM_Last_Run_Time__c,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_New_Contract_v0_0__c,ASI_CRM_New_Contract_vFinal__c
        FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c =:ContractId AND OwnerId=:UserInfo.getUserId() AND ASI_CRM_Type__c='Group Contract'];

        if(TempList.size()>0){
            ASI_Attachment__c TempRecord= TempList[0];
            TempRecord.ASI_CRM_For_Contract_Use__c=true;
            if (v00Id != null && v00Id != '') {
                if(TempRecord.ASI_CRM_New_Contract_v0_0__c=='' || TempRecord.ASI_CRM_New_Contract_v0_0__c==null){
                TempRecord.ASI_CRM_New_Contract_v0_0__c=v00Id+';';
                }else{
                    TempRecord.ASI_CRM_New_Contract_v0_0__c= TempRecord.ASI_CRM_New_Contract_v0_0__c+v00Id+';';
                }
            }
            
            if (vFinalId != null && vFinalId != '') {
                if(TempRecord.ASI_CRM_New_Contract_vFinal__c=='' || TempRecord.ASI_CRM_New_Contract_vFinal__c==null){
                    TempRecord.ASI_CRM_New_Contract_vFinal__c=vFinalId+';';
                }else{
                    TempRecord.ASI_CRM_New_Contract_vFinal__c=TempRecord.ASI_CRM_New_Contract_vFinal__c+vFinalId+';';
                }
            }
            //TempRecord.ASI_CRM_New_Contract_v0_0__c!=''?TempRecord.ASI_CRM_New_Contract_v0_0__c+v00Id+';':v00Id+';';
            //TempRecord.ASI_CRM_New_Contract_vFinal__c=TempRecord.ASI_CRM_New_Contract_vFinal__c!=''? TempRecord.ASI_CRM_New_Contract_vFinal__c+vFinalId+';':vFinalId+';';
            update TempRecord;
        }
    }


    public static void SendGroupContractShuttle(String ContractId){

        //Getting user email
        ASI_TH_CRM_Contract__c Contract = [SELECT Id,Name FROM ASI_TH_CRM_Contract__c WHERE Id=:ContractId];
        User u =[SELECT Id,Email FROM User WHERE Id=:UserInfo.getUserId()];

        //get system debug email
        ASI_CRM_CN_CustomSetting__c CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> setToAddressList = new List<String>();
        setToAddressList.add(u.Email);
        mail.setToAddresses(setToAddressList);
        mail.setReplyTo(CustomSetting.ASI_CRM_System_Debug_Email__c);
        mail.setSenderDisplayName(' Group Contract Profit Shuttle');
        mail.setSubject('Group Contract Profit Shuttle');
        mail.setPlainTextBody('Please find your Group Contract Profit Shuttle as attached. Thanks. ');

        //Generate PDF
        PageReference pdf = Page.ASI_CRM_CN_HeavyGroupProfitShuttlePDF;
        pdf.getParameters().put('id',Contract.Id);
        //pdf.getParameters().put('EndDate','2017-07-31');
        //pdf.getParameters().put('StartDate','2017-07-01');
        Blob body;
        //Blob content = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pr.getContent();
        //body = pdf.getContent();
        body=Test.isRunningTest() ?Blob.valueOf('UNIT.TEST') :pdf.getContent();


        List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();

        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();   //Define the email
        efa.setFileName(Contract.Name+'.pdf');
        efa.setBody(body);
        efa.setContentType('application/pdf');

        efaList.add(efa);

        if(efaList.size()>0){
            mail.setFileAttachments(efaList);
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });


    }

    public static void SendGroupContractShuttle2nd(String ContractId){ 

        //Getting user email
        ASI_TH_CRM_Contract__c Contract = [SELECT Id,Name FROM ASI_TH_CRM_Contract__c WHERE Id=:ContractId];
        User u =[SELECT Id,Email FROM User WHERE Id=:UserInfo.getUserId()];

        //get system debug email
        ASI_CRM_CN_CustomSetting__c CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> setToAddressList = new List<String>();
        setToAddressList.add(u.Email);
        mail.setToAddresses(setToAddressList);
        mail.setReplyTo(CustomSetting.ASI_CRM_System_Debug_Email__c);
        mail.setSenderDisplayName(' Group Contract Profit Shuttle');
        mail.setSubject('Group Contract Profit Shuttle');
        mail.setPlainTextBody('Please find your Group Contract Profit Shuttle as attached. Thanks. ');

        //Generate PDF
        PageReference pdf = Page.ASI_CRM_CN_HeavyGroupProfitShuttle2ndPDF;//Page.ASI_CRM_CN_HeavyGroupProfitShuttlePDF2nd;
        pdf.getParameters().put('id',Contract.Id);
        //pdf.getParameters().put('EndDate','2017-07-31');
        //pdf.getParameters().put('StartDate','2017-07-01');
        Blob body;
        //Blob content = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pr.getContent();
        //body = pdf.getContent();
        body=Test.isRunningTest() ?Blob.valueOf('UNIT.TEST') :pdf.getContent();


        List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();

        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();   //Define the email
        efa.setFileName(Contract.Name+'.pdf');
        efa.setBody(body);
        efa.setContentType('application/pdf');

        efaList.add(efa);

        if(efaList.size()>0){
            mail.setFileAttachments(efaList);
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });


    }

    public static Decimal denullify(Decimal input, Decimal defaultValue){
        return input == null ? defaultValue : input;
    }

    public static Decimal denullify(Decimal input){
        return input == null ? 0 : input;
    }


    /*
    Data Retrieval Functions
     */
    public static ASI_TH_CRM_Contract__c getContract(Id contractId) {
        return [
            SELECT
                ASI_CRM_CN_Bottle_Collection_Rate__c,
                ASI_CRM_CN_Is_2nd_KPI_PO__c,
                ASI_CRM_CN_BRSF_Contract_Total__c,
                ASI_CRM_CN_Budget_LE__c,
                ASI_CRM_CN_Business_License__c,
                ASI_CRM_CN_Contract_Cost_Total__c,
                ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                ASI_CRM_Expected_V0_0_VEC_Est_Total__c,
                ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
                ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
                ASI_CRM_CN_Contract_Upload__c,
                ASI_CRM_CN_Contract_Variable_Cost_Total__c,
                ASI_CRM_CN_Fixed_Module_Est_Amount1__c,
                ASI_CRM_CN_Fixed_Module_Est_Amount2__c,
                ASI_CRM_CN_Currency__c,
                ASI_CRM_CN_Description__c,
                ASI_CRM_CN_Effective_Date__c,
                ASI_CRM_CN_Exchange_Rate__c,
                ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                ASI_CRM_CN_Expected_PSF_Est_Total__c,
                ASI_CRM_CN_Group_Contract__c,
                ASI_CRM_CN_Group_Contract__r.Name,
                ASI_CRM_CN_Last_PO_version__c,
                ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
                ASI_CRM_CN_Last_Rejected_Date__c,
                ASI_CRM_CN_Last_Submitted_Date__c,
                ASI_CRM_CN_National_Group_Contract__c,
                ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_Outlet_WS__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,
                ASI_CRM_CN_Outlet_WS__r.ASI_TH_CRM_OutletType__c,
                ASI_CRM_CN_Outlet_WS__r.Name,
                ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                ASI_CRM_CN_PO_End_Date__c,
                ASI_CRM_CN_PO_Modification__c,
                ASI_CRM_CN_PO_No__c,
                ASI_CRM_CN_PO_Start_Date__c,
                ASI_CRM_CN_PO_Version__c,
                ASI_CRM_CN_PP_No__c,
                ASI_CRM_CN_Reason_without_Budget__c,
                ASI_CRM_CN_Source_of_Contract__c,
                ASI_CRM_CN_Source_Others__c,
                ASI_CRM_CN_Special_Promotion__c,
                ASI_CRM_CN_Status__c,
                ASI_CRM_CN_Total_Contract_Amount__c,
                ASI_CRM_CN_V0_0_PO_version__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,
                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c,
                ASI_CRM_CN_Vol_Budget_LE__c,
                ASI_CRM_EVC_Cost_Estimate_Total__c,
                ASI_CRM_Investment_Type__c,
                ASI_CRM_Last_RBA_Approver__c,
                ASI_CRM_Martell_BC_Rate__c,
                ASI_CRM_National_Group__c,
                ASI_CRM_National_Group__r.Name,
                ASI_CRM_New_FY_PO__c,
                ASI_CRM_PO_Channel__c,
                ASI_CRM_PO_Channel__r.Name,
                ASI_CRM_PO_City__c,
                ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c,
                ASI_CRM_PO_City__r.Name,
                ASI_CRM_PO_Province__c,
                ASI_CRM_PO_Province__r.Name,
                ASI_CRM_Volume_Option__c,
                ASI_TH_CRM_Promotion_Type__c,
                CreatedDate,
                Id,
                LastModifiedDate,
                Name,
                Owner.Name,
                OwnerId,
                RecordTypeId,ASI_CRM_Auto_PO_Modification__c,
                ASI_CRM_CN_IS_Manual_Refresh__c
            FROM ASI_TH_CRM_Contract__c
            WHERE Id = :contractId
        ];
    }

}