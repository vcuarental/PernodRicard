/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffContractUtilitiesClass
 * Description: Utility Class to generate Aggregated Sub-brand Volume
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-26       Hector Tsang	        Created
 ****************************************************************************************************************************/
 public class ASI_CRM_CN_OffContractUtilitiesClass {
 	
 	//'Financial Indicator' Data structure for checking point // PDF // Email // ROI  //  
 	public final static List<String> RECORD_TYPE_LIST_AGGREGATION = new List<String> {
    	'ASI_CRM_CN_WS_Outlet_Brand_Monthly_Volume',
		'ASI_CRM_CN_WS_Outlet_Region_Monthly_Volume',
		'ASI_CRM_CN_WS_Outlet_Category_Monthly_Volume',
		'ASI_CRM_CN_WS_Outlet_CTD_Sub_Brand_Data',
		'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data'
	};
	
	
	
    public class FinancialIndicator { 
        public Decimal Volumes  {set;get;} {Volumes=0.0;}  //Intake(9L)
        public Decimal Value {get; set;} {Value = 0.0;}
        public Decimal IntakeSTD  {set;get;} {IntakeSTD=0.0;}  //Intake(std. btl) 
        
        public Map<String,Decimal> SubBrandGradeMap  {set;get;} {SubBrandGradeMap = new Map<String,Decimal>();}  // For PDF 
        public Map<String,Decimal> SubBrandGradeGrouping  {set;get;} {SubBrandGradeGrouping = new Map<String,Decimal>();}  //For Check point
        public Map<String,Decimal> SubBrandGSMap  {set;get;} {SubBrandGSMap = new Map<String,Decimal>();}  //For Check point
        public Map<String,Decimal> SubBrandGSPercentageMap  {set;get;} {SubBrandGSPercentageMap = new Map<String,Decimal>();}  //For Check point
        public Map<String,Decimal> SubBrandAPMap  {set;get;} {SubBrandAPMap = new Map<String,Decimal>();}  //For Check point

        public Map<String,Decimal> BrandVolumeMap  {set;get;} {BrandVolumeMap = new Map<String,Decimal>();}
        public Map<String,Decimal> BrandValueMap  {set;get;} {BrandValueMap = new Map<String,Decimal>();}

        public Map<String,Decimal> CategoryVolumeMap  {set;get;} {CategoryVolumeMap = new Map<String,Decimal>();}
        public Map<String,Decimal> CategoryValueMap  {set;get;} {CategoryValueMap = new Map<String,Decimal>();}
        public Map<String,Decimal> CategoryGSMap {get; set;} {CategoryGSMap = new Map<String,Decimal>();}

        public Map<String,ContractLine> ContractLineMap  {set;get;} {ContractLineMap = new Map<String,ContractLine>();}
        public Map<String,ContractLine> PSFLineMap  {set;get;} {PSFLineMap = new Map<String,ContractLine>();}
        public Map<String,ContractLine> OtherExpensesMap  {set;get;} {OtherExpensesMap = new Map<String,ContractLine>();}
        
        public Set<Id> OutletSet {set;get;} {OutletSet=new Set<Id>();}
        public Date POStartDate {set;get;} {POStartDate=Date.today();}
        public Date POEndDate {set;get;} {POEndDate=Date.today();}
        public String ContractId {set;get;} {ContractId='';}
        public String BRSFMethodologyName {set;get;} {BRSFMethodologyName='';} 
        public String PSFMethodologyName {set;get;} {PSFMethodologyName='';} 
        public String PSFVolumeBase {set;get;} {PSFVolumeBase='';} 
        public String DisplayMethodologyName {set;get;} {DisplayMethodologyName='';} 
        public String DisplayVolumeBase {set;get;} {DisplayVolumeBase='';}
        
        public Integer NoOfMonths {set;get;} {NoOfMonths=1;}
        public String AddOnString {set;get;} {AddOnString ='';}
        
        public String CMId  {set;get;} {CMId =' ';}
        public String GSId  {set;get;} {GSId =' ';}
        
        public Decimal TradeExpenses  {
        	get {
        		return (this.PSFExpensesTotal + this.DisplayExpensesTotal + this.OtherExpensesTotal);
        	} 
        	private set;
        }     
        public Decimal GrossSalesTotal  {set;get;} {GrossSalesTotal=0.0;}
        public Decimal GrossSalesRate  {
        	get {
        		return (this.GrossSalesTotal != 0) ? ((this.TradeExpenses.setScale(0)/this.GrossSalesTotal.setScale(0))*100).setScale(2) : 0;
        	} 
        	private set;
        } 
        //Off Contract Logic: PSF Expenses - Module Line Type = 'PSF'
        public Decimal PSFExpensesTotal {get;set;} {PSFExpensesTotal = 0.0;}
        //Off Contract Logic: Display Expenses - Module Line Type = 'Display'
        public Decimal DisplayExpensesTotal  {set;get;} {DisplayExpensesTotal=0.0;}
        public Decimal DisplayExpensesRate  {
        	get {
        		return (this.TradeExpenses != 0) ? ((this.DisplayExpensesTotal/this.TradeExpenses)*100).setScale(2) : 0;
        	} 
        	private set;
        } 
        //Off Contract Logic: Other Expenses - Contract Cost where Cost Type = 'Fixed'
        public Decimal OtherExpensesTotal  {set;get;} {OtherExpensesTotal=0.0;}
        public Decimal OtherExpensesRate  {
        	get {
        		return (this.TradeExpenses != 0) ? ((this.OtherExpensesTotal/this.TradeExpenses)*100).setScale(2) : 0;
        	} 
        	private set;
        } 
        
        public Decimal IntakeCR12  {set;get;} {IntakeCR12=0.0;}   //Intake (CR12) 
        public Decimal CMTotal {set;get;} {CMTotal=0.0;} 
        public Decimal InvestmentCR12  {set;get;} {InvestmentCR12=0.0;}// Investment per CR12 eq btl
        
        public Decimal LatestBudgetCMTotal  {set;get;} {LatestBudgetCMTotal=0.0;}
        
        public Decimal MarginAfterAnP  {set;get;} {MarginAfterAnP=0.0;}
        public Decimal MarginPerBottle {
        	get {
        		return (this.IntakeSTD != 0) ? ((this.MarginAfterAnP/this.IntakeSTD)).setScale(2) : 0;
        	} 
        	private set;
        } 
        
        public Decimal ROIIntake  {set;get;} {ROIIntake=0.0;}
        //In previous logic, ROI Actual is under same calculation with ROI Intake
        //There are no update in Off Contract
        public Decimal ROIActual  {
        	get {
        		return this.ROIIntake;
        	}
        	private set;
        }
        public Decimal ROIProForma  {set;get;} {ROIProForma=0.0;}
        public Map<String,String> DebugMap {set;get;} {DebugMap = new  Map<String,String>();}
        public FinancialIndicator(){  
        }
    	
    	public void DataRounding(){
    		this.GrossSalesRate = this.GrossSalesRate != null ? this.GrossSalesRate.setScale(1) : 0;
        	this.ROIIntake = this.ROIIntake != null ? this.ROIIntake.setScale(2) : 0;
        	this.ROIProForma = this.ROIProForma != null ? this.ROIProForma.setScale(2) : 0;
    	}
        public Decimal DolphinContractPercent{get;set;}{DolphinContractPercent=0.0;}
    }
    
    public class ContractLine{
        public String SubBrandName {set;get;}{SubBrandName='';}
        public String SubBrandCategory {set;get;}{SubBrandCategory='';}
        public String SubBrandGrade {set;get;}{SubBrandGrade='';}
        public String strSubBrand {set;get;}{strSubBrand='';}
        public String strBrand {set;get;}{strBrand='';}
        
        public Decimal HistoricalBottles  {set;get;} {HistoricalBottles=0.0;}
        public Decimal EstimateBottles  {set;get;} {EstimateBottles=0.0;}
        public Decimal ContractBottles  {set;get;} {ContractBottles=0.0;}
        public Decimal VFinalBottles  {set;get;} {VFinalBottles=0.0;}
        
        public Decimal HistoricalValue  {set;get;} {HistoricalValue=0.0;}
        public Decimal EstimateValue  {set;get;} {EstimateValue=0.0;}
        public Decimal ContractValue  {set;get;} {ContractValue=0.0;}
        public Decimal VFinalValue  {set;get;} {VFinalValue=0.0;}

        public Decimal HistoricalFees  {set;get;} {HistoricalFees=0.0;}
        public Decimal EstimateFees  {set;get;} {EstimateFees=0.0;}
        public Decimal ContractFees  {set;get;} {ContractFees=0.0;}
        public Decimal VFinalFees  {set;get;} {VFinalFees=0.0;}
        
        public Decimal HistoricalTotalFees  {set;get;} {HistoricalTotalFees=0.0;}
        public Decimal EstimateTotalFees  {set;get;} {EstimateTotalFees=0.0;}
        public Decimal ContractTotalFees  {set;get;} {ContractTotalFees=0.0;}
        public Decimal VFinalTotalFees  {set;get;} {VFinalTotalFees=0.0;}
        
        public Decimal HistoricalPSFFees  {set;get;} {HistoricalPSFFees=0.0;}
        public Decimal EstimatePSFFees  {set;get;} {EstimatePSFFees=0.0;}
        public Decimal ContractPSFFees  {set;get;} {ContractPSFFees=0.0;}
        public Decimal VFinalPSFFees  {set;get;} {VFinalPSFFees=0.0;}
        
        //Used in Group Contract:   All period Volume in contract
        public Decimal HistoricalVolume  {set;get;} {HistoricalVolume=0.0;} // All period from contract 
        public Decimal EstimateVolume {set;get;} {EstimateVolume=0.0;}
        public Decimal ContractVolume  {set;get;} {ContractVolume=0.0;}
        public Decimal VFinalVolume  {set;get;} {VFinalVolume=0.0;} //Intake (std. btl.) for full contract period

        //Following used in Group Contract:  
        public Decimal HistoricalActualVolume  {set;get;} {HistoricalActualVolume=0.0;} // All period from Intake. For  Historical , all period, 
        public Decimal VFinalActualVolume  {set;get;} {VFinalActualVolume=0.0;} //For New contract Vfinal,  use prorated
        
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
        public Decimal latestBudgetCM {set;get;}
        public Decimal period {set;get;}
        public Decimal target_vol {set;get;}{target_vol=0;}
        public Decimal actual_vol {set;get;}{actual_vol=0;}
        public Decimal actualCM {set;get;}{actualCM=0;}
        public Decimal actualGS {set;get;}{actualGS=0;}
        
        public String year {set;get;}
        public subbrand_data(){} 
        
    }
    
    //Return outlet threshold that trigger using Aggregated Data
    public static Integer outletThreshold(){
    	ASI_CRM_CN_CustomSetting__c customSetting = ASI_CRM_CN_CustomSetting__c.getOrgDefaults();
    	Integer result = Integer.valueOf(customSetting.ASI_CRM_CN_Off_Outlet_Threshold__c);
    	if (result >= 1){
    		return result;
    	} else {
    		return 50;
    	}
    }
    
    public static List<ASI_TH_CRM_Contract__c> getContractOverThreshold (List<ASI_TH_CRM_Contract__c> contractList){
    	Map<Id, Integer> resultMap = new Map<Id, Integer>();
    	List<ASI_TH_CRM_Contract__c> result = new List<ASI_TH_CRM_Contract__c>();
    	for (ASI_TH_CRM_Contract__c contract : contractList){
    		resultMap.put(contract.Id, 0);
    	}
    	
    	AggregateResult[] groupedResults = [SELECT ASI_CRM_CN_Contract__c, COUNT(Id)cnt
    										FROM ASI_CRM_CN_Covered_Outlet__c
    										WHERE ASI_CRM_CN_Contract__c IN :contractList
    										GROUP BY ASI_CRM_CN_Contract__c];
    	for (AggregateResult ar : groupedResults){
    		resultMap.put((Id)ar.get('ASI_CRM_CN_Contract__c'), (Integer)ar.get('cnt'));
    	}
    	
    	for (ASI_TH_CRM_Contract__c contract:contractList){
    		if (resultMap.get(contract.Id) >= outletThreshold()){
    			result.add(contract);
    		}
    	}
    	return result;
    }
    
    //UAT TODO: Combine the function of creating Financial Indicator of 4 different types
    
    //@description: Restructure current PO Record
    //@param: input current Contract
    //@return NewContactV0Contract and NewContractV0Estimate
    public static void  RestructureCurrentFinancialIndicatorData(ASI_TH_CRM_Contract__c contract){
        String strRegion='',CommercialTeam='';
        Set<Id> V00SubBrandIdSet= new Set<Id>();
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal> ();
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = getContract(contract.Id);
        Decimal DolphinContractPercent = 0.0;
        
        strRegion= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
        CommercialTeam= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
        
        FinancialIndicator NewContractV0Estimate = new FinancialIndicator(); //B    New Contract V0.0 Est.
        FinancialIndicator NewContactV0Contract = new FinancialIndicator(); //D  New Contact V0.0 Contract
        NewContractV0Estimate.ContractId = thisCC.Id;
        NewContactV0Contract.ContractId = thisCC.Id;
        
        if (thisCC.ASI_CRM_CN_PO_Start_Date__c!= null){
            NewContractV0Estimate.POStartDate= thisCC.ASI_CRM_CN_PO_Start_Date__c;
            NewContactV0Contract.POStartDate= thisCC.ASI_CRM_CN_PO_Start_Date__c;
        }
        if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null){
            NewContractV0Estimate.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;
            NewContactV0Contract.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;
        }
        
        if (thisCC.ASI_CRM_CN_Contract_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Cost_Total__c != null){
            NewContactV0Contract.TradeExpenses += thisCC.ASI_CRM_CN_Contract_Cost_Total__c;
            NewContactV0Contract.OtherExpensesTotal += thisCC.ASI_CRM_CN_Contract_Cost_Total__c;
        }
        
        if (thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null){
            NewContractV0Estimate.OtherExpensesTotal= thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
        }
        
        //Trade Expenses, Estimate               
        if (thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c!= 0 &&  thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c!= 0){
            NewContractV0Estimate.TradeExpenses += thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;  
        } 
        
        if(thisCC.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_No_of_Months__c != null){
            NewContactV0Contract.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
            NewContractV0Estimate.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
        }
        
        //New Contract Period
        Map<Date, Decimal> thisCC_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        
		//key: date+SubBrand    for Current v0.0
        Map <String, subbrand_data> current_sbDataROI_map =new Map <String, subbrand_data>();
        
        Map<Id, Decimal> ConVolume_map = new Map<Id, Decimal>();
        Map<Id, Decimal> EstVolume_map  = new Map<Id, Decimal>();
        Decimal BRSFEstimateVolumesTotal=0;
        Decimal BRSFContractVolumesTotal=0;
        
        NewContactV0Contract.ContractLineMap = new Map<String,ContractLine>();
        NewContactV0Contract.OtherExpensesMap = new Map<String,ContractLine>();
        
		//Others Cost
        for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, 
        											ASI_CRM_CN_Cost_Type__c, 
        											ASI_CRM_CN_Chinese_Description__c, 
        											ASI_CRM_CN_Contract_Amount__c,
        											ASI_CRM_CN_Activity_Code__c,
                                                	ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,
                                                	ASI_CRM_CN_Estimate_Amount__c, 
                                                	ASI_CRM_CNY_Est__c, 
                                                	ASI_CRM_MAF_Est__c, 
                                                	ASI_CRM_Other_Est__c,
                                                    ASI_CRM_CN_Contract_Amount_Rate__c,
                                                    ASI_CRM_CN_Estimate_Amount_Rate__c
                                                FROM ASI_CRM_Contract_Cost__c 
                                                WHERE ASI_CRM_CN_Contract__c = :thisCC.Id])
        {
            if (ccost.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                if (NewContactV0Contract.OtherExpensesMap != null && NewContactV0Contract.OtherExpensesMap.containsKey(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c)){
                    NewContactV0Contract.OtherExpensesMap.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).EstimateFees+= ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    NewContactV0Contract.OtherExpensesMap.get(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c).ContractFees+= ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
                } else {
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.EstimateFees =ccost.ASI_CRM_CN_Estimate_Amount__c !=null? ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    ContractDetail.ContractFees = ccost.ASI_CRM_CN_Contract_Amount__c !=null? ccost.ASI_CRM_CN_Contract_Amount__c:0;
                    NewContactV0Contract.OtherExpensesMap.put(ccost.Name + ' ' +ccost.ASI_CRM_CN_Chinese_Description__c,ContractDetail);
                    
                }
            }
            if(thisCC.ASI_CRM_CN_Is_Dolphin__c && ccost.ASI_CRM_CN_Contract_Amount_Rate__c != null){
                DolphinContractPercent += ccost.ASI_CRM_CN_Contract_Amount_Rate__c;
            } 
        }
        
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> thisCC_BRSFList = getBRSFLines(thisCC.Id);
        
        Set<String> PSFMethodologySet = new Set<String>();
        Set<String> PSFVolumeBaseSet = new Set<String>();
        //Looping BRSF Line
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : thisCC_BRSFList){
            
            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||
                 (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' )) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){
                     System.debug('NewcontractV00SubBrandIdSet :'+ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c);
                     //if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){
                     V00SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                     Decimal EstimateVolumes=0.0;
                     Decimal ContractVolumes=0.0;
                     Decimal EstimateValue=0.0;
                     Decimal ContractValue=0.0;
                     
                     //Get All BRSF Estimate Volumes and contract volume 
                     if((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || 
						(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ){
                         BRSFEstimateVolumesTotal += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                         BRSFContractVolumesTotal += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
                         if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                             NewContactV0Contract.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                             NewContractV0Estimate.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                         }
                     }
                     
                     // (Estimate Qty Convert 9L * No of Months) ASI_CRM_CN_Estimate_Volume_9L_Month__c
                     if (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                         NewContractV0Estimate.Volumes += (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c* ContractLine.ASI_CRM_CN_No_of_Months__c);
                         EstimateVolumes = (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                         NewContractV0Estimate.Value += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                         EstimateValue = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                     } else {
                         EstimateVolumes = 0;
                     }
                     
                     // Volume 9L (Contract Qty Convert 9L * No of Months) ASI_CRM_CN_Contract_Monthly_Vol9L__c
                     if (ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                         NewContactV0Contract.Volumes += (ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                         ContractVolumes = (ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c * ContractLine.ASI_CRM_CN_No_of_Months__c);
                         NewContactV0Contract.Value += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                         ContractValue = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                     } else {
                         ContractVolumes = 0;
                     }
                     //Calculate Trade Expenses    
                     
                     //Sub-Brand Grouping for 'NewContractV0Estimate' and 'NewContactV0Contract'
                     String SubbrandGroupName='0. Not Specified';
                     String SubBrandName='';
                     String BrandName = '';
                     if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                         SubbrandGroupName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c:ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                         SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                         BrandName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name;
                         System.debug(SubbrandGroupName+' &&&&&&'+SubBrandName);
                     }

                     //String subBrandKey = SubbrandGroupName+ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                     String LineKey = NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) +ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//subBrandKey;//
                     

                     if(NewContactV0Contract.ContractLineMap.containsKey(LineKey)){
						 ContractLine thisContractLine = NewContactV0Contract.ContractLineMap.get(LineKey);
                         thisContractLine.EstimateBottles += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                         thisContractLine.ContractBottles += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;

                         thisContractLine.EstimateValue += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                         thisContractLine.ContractValue += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;

                         thisContractLine.EstimateFees += ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null? ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c:0;
                         thisContractLine.ContractFees += ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null? ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c:0;
                         
                         thisContractLine.EstimateVolume +=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                         thisContractLine.ContractVolume +=ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                                                  
                         if(ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null){
                             thisContractLine.EstimateTotalFees += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * thisCC.ASI_CRM_CN_No_of_Months__c;
                         }
                         if(ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null ){
                             thisContractLine.ContractTotalFees += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c *thisCC.ASI_CRM_CN_No_of_Months__c;
                         }
                     } else {
                         ContractLine ContractDetail = new ContractLine ();
                         ContractDetail.EstimateBottles = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c:0;
                         ContractDetail.ContractBottles = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
                         ContractDetail.EstimateValue = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                         ContractDetail.ContractValue = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                         ContractDetail.EstimateFees = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null?ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c:0;
                         ContractDetail.ContractFees = ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null?ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c:0;
                         ContractDetail.EstimateVolume = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                         ContractDetail.ContractVolume = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                         
                         if(ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c!=null){
                             ContractDetail.EstimateTotalFees = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * thisCC.ASI_CRM_CN_No_of_Months__c;
                         }
                         if(ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null && ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null ){
                             ContractDetail.ContractTotalFees = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c *thisCC.ASI_CRM_CN_No_of_Months__c;
                         }
                         ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                         ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                         ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
                         ContractDetail.strSubBrand = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                         ContractDetail.strBrand = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c;
                         NewContactV0Contract.ContractLineMap.put(LineKey,ContractDetail);
                     }
                     
                     NewContractV0Estimate.SubBrandGradeGrouping = addToDecimalMap(NewContractV0Estimate.SubBrandGradeGrouping, SubBrandName, EstimateVolumes);
                     NewContactV0Contract.SubBrandGradeGrouping = addToDecimalMap(NewContactV0Contract.SubBrandGradeGrouping, SubBrandName, ContractVolumes);

                     NewContractV0Estimate.SubBrandGradeMap = addToDecimalMap(NewContractV0Estimate.SubBrandGradeMap, SubbrandGroupName, EstimateVolumes);
                     NewContactV0Contract.SubBrandGradeMap = addToDecimalMap(NewContactV0Contract.SubBrandGradeMap, SubbrandGroupName, ContractVolumes);
                     
                     NewContractV0Estimate.BrandVolumeMap = addToDecimalMap(NewContractV0Estimate.BrandVolumeMap, BrandName, EstimateVolumes);
                     NewContactV0Contract.BrandVolumeMap = addToDecimalMap(NewContactV0Contract.BrandVolumeMap, BrandName, ContractVolumes);
                     
                     NewContractV0Estimate.BrandValueMap = addToDecimalMap(NewContractV0Estimate.BrandValueMap, BrandName, EstimateValue);
                     NewContactV0Contract.BrandValueMap = addToDecimalMap(NewContactV0Contract.BrandValueMap, BrandName, ContractValue);


                     
                     //By Brand Product Category Grouping 'NewContractV0Estimate' and 'NewContactV0Contract'
                     if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c !=null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                         String CategoryName = getCategoryNameFromContractLine(ContractLine);
                         
                         NewContractV0Estimate.CategoryVolumeMap = addToDecimalMap(NewContractV0Estimate.CategoryVolumeMap, CategoryName, EstimateVolumes);
                         NewContactV0Contract.CategoryVolumeMap = addToDecimalMap(NewContactV0Contract.CategoryVolumeMap, CategoryName, ContractVolumes);
                         
                         NewContractV0Estimate.CategoryValueMap = addToDecimalMap(NewContractV0Estimate.CategoryValueMap, CategoryName, EstimateValue);
                         NewContactV0Contract.CategoryValueMap = addToDecimalMap(NewContactV0Contract.CategoryValueMap, CategoryName, ContractValue);
                         
                         NewContractV0Estimate.CategoryGSMap = addToDecimalMap(NewContractV0Estimate.CategoryGSMap, CategoryName, 0);
                         NewContactV0Contract.CategoryGSMap = addToDecimalMap(NewContactV0Contract.CategoryGSMap, CategoryName, 0);
                     }// end of By Brand Product Category Grouping      
                     
                     
                     if(thisCC_Period_map != null && thisCC_Period_map.size() > 0){
                         for (Date V0CCdate : thisCC_Period_map.keySet() ){
                             Date strDateCC = ASI_CRM_DateUtilClass.getFiscalYearEndDate(V0CCdate);
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
                         System.debug(LoggingLevel.INFO, '*** convol: ' + convol);
                         ConVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, convol);
                     } else {
                         ConVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Contract_Monthly_Vol9L__c);
                     }
                     System.debug(LoggingLevel.INFO, '*** ConVolume_map: ' + ConVolume_map);
                     if (EstVolume_map.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                         Decimal estvol = EstVolume_map.get(ContractLine.ASI_CRM_CN_Sub_Brand__c)+ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c;
                         EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, estvol );
                     } else {
                         EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c);
                     }
                 }
        
            
            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Module__c!=null){
                if(thisCC.ASI_CRM_CN_Is_Dolphin__c && ContractLine.ASI_CRM_CN_Rebate_Percent__c != null){
                    DolphinContractPercent += ContractLine.ASI_CRM_CN_Rebate_Percent__c;
                }
                if(!PSFMethodologySet.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                    PSFMethodologySet.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                    NewContactV0Contract.PSFMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                    NewContractV0Estimate.PSFMethodologyName+=ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                }
                if(!PSFVolumeBaseSet.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                    PSFVolumeBaseSet.add(ContractLine.ASI_CRM_Volume_Base__c);
                    NewContactV0Contract.PSFVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                    NewContractV0Estimate.PSFVolumeBase+=VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                }
                
                //Build PSFLineMap
                String LineKey;
                Boolean isByCategory = false;
                System.debug('ContractLine: ' + ContractLine);
                if (ContractLine.ASI_CRM_Volume_Base__c == 'By Category'){
	                //By Category
	               	isByCategory = true;
	               	LineKey = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
	            } else {
	               	//By Sub-brand
	            	LineKey = NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//subBrandKey;//
	            } /*else {
	            	system.debug('ByTotal');
	               	LineKey = 'ByTotal';
	            } */
                
                if(NewContactV0Contract.PSFLineMap.containsKey(LineKey)){
                	ContractLine thisContractLine = NewContactV0Contract.PSFLineMap.get(LineKey);
					thisContractLine.EstimatePSFFees += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
					thisContractLine.ContractPSFFees += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
				} else {
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.EstimatePSFFees = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
					ContractDetail.ContractPSFFees = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
					
                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    if (isByCategory){
                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
                    } else {
                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
                    }
                    ContractDetail.strSubBrand = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                    ContractDetail.strBrand = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c;
                         
                    NewContactV0Contract.PSFLineMap.put(LineKey,ContractDetail);
                }
               	System.debug('ASI_CRM_CN_Contract_Total_Dummy__c: ' + ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c);
                NewContactV0Contract.PSFExpensesTotal += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                NewContractV0Estimate.PSFExpensesTotal += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
            }
            
            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='Display'){
                if(!PSFMethodologySet.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                    PSFMethodologySet.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                    NewContactV0Contract.DisplayMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                    NewContractV0Estimate.DisplayMethodologyName+=ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                }
                if(!PSFVolumeBaseSet.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                    PSFVolumeBaseSet.add(ContractLine.ASI_CRM_Volume_Base__c);
                    NewContactV0Contract.DisplayVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                    NewContractV0Estimate.DisplayVolumeBase+=VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                }
                NewContactV0Contract.DisplayExpensesTotal += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
                NewContractV0Estimate.DisplayExpensesTotal += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
            }
        }// end of Looping BRSF Line

        NewContactV0Contract.DolphinContractPercent = DolphinContractPercent;

        //CR12Factor 
        Map<String,Decimal> CR12FactorMap = GenerateCR12FactorMap(V00SubBrandIdSet, CommercialTeam, strRegion);
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine :thisCC_BRSFList){
            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||  (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){
                
                Decimal CR12Factor=1;
                if(CR12FactorMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    CR12Factor=CR12FactorMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                }
                System.debug('Estimate CR12 : '+ ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c +'*'+ CR12Factor +'*'+  ContractLine.ASI_CRM_CN_No_of_Months__c);
                System.debug('Contract CR12 : '+ ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c +'*'+ CR12Factor +'*'+  ContractLine.ASI_CRM_CN_No_of_Months__c);
                if (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                    NewContractV0Estimate.IntakeCR12 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                }
                if(ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!= null){
                    NewContactV0Contract.IntakeCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                }
            }
        }
        
        
        //Calculate RegionSubBrandCM_Map
        String currentFY = String.valueOf(ASI_CRM_DateUtilClass.getFiscalYearEndDate(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';
        Map<String,ASI_CRM_CM_GS__c> SubBrandCM_Map = new Map<String,ASI_CRM_CM_GS__c> ();
        Map<String, String> subBrandCategoryMap = new Map<String, String>();
        for (ASI_CRM_CM_GS__c lbcm : [SELECT Id,
										ASI_CRM_CM_GS_per_9L__c, 
										ASI_CRM_PRODUCTCODE__c, 
										ASI_CRM_PRODUCTCODE__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c,
										ASI_CRM_Region__c 
									  FROM ASI_CRM_CM_GS__c
                                      WHERE ASI_CRM_CN_Month__c = 6  
									  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3) 
									  AND ASI_CRM_Region__c = :strRegion  
									  AND ASI_CRM_TYPE__c = 'Budget CM' 
                                      AND ASI_CRM_CM_GS_per_9L__c != NULL
									  AND ASI_CRM_CM_GS_per_9L__c != 0  
									  ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        { 
            String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            Decimal cm=0.0;
            if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                cm = lbcm.ASI_CRM_CM_GS_per_9L__c; 
            }
            if (!RegionSubBrandCM_Map.containsKey(ProductCode)){
                RegionSubBrandCM_Map.put(ProductCode,cm) ;   
                SubBrandCM_Map.put(ProductCode,lbcm);
                subBrandCategoryMap.put(ProductCode, lbcm.ASI_CRM_PRODUCTCODE__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c);
            }
        }
		
        //for querying Budget CM
        Date strStartBGDate;
        Date strEndBGDate;
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_Start_Date__c != null)
            strStartBGDate = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        if(thisCC != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null)
            strEndBGDate = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
        
        Date strStartBGDate2 = Date.newInstance(strStartBGDate.addYears(-1).year(), 6, 30);
        Date strEndBGDate2 = Date.newInstance(strEndBGDate.year(), 6, 30);
        
        Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();
        
        System.debug('RestructureCurrentFinancialIndicatorData CM GS strStartBGDate:'+strStartBGDate);
        System.debug('strEndBGDate:'+strEndBGDate);
        System.debug('strStartBGDate2:'+strStartBGDate2);
        System.debug(' strEndBGDate2:'+strEndBGDate2);

        for (ASI_CRM_CM_GS__c thisbcm : [
            SELECT Id,
                ASI_CRM_CM_GS_per_9L__c,
                ASI_CRM_TYPE__c,
                ASI_CRM_PRODUCTCODE__c,
                ASI_CRM_Region__c,
                ASI_CRM_PRODUCTCODE__r.Name,
                ASI_CRM_PRODUCTCODE__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c,
                ASI_CRM_CN_Month_End_Date__c,
                ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_CN_Month__c
            FROM ASI_CRM_CM_GS__c
            WHERE ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet
            AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            AND ((ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate
            AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate ) OR
            (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2
            AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2
            AND ASI_CRM_CN_Month__c = 6 ))
            AND (ASI_CRM_TYPE__c = 'Budget CM'
            OR ASI_CRM_TYPE__c = 'Budget GS')
            AND ASI_CRM_CM_GS_per_9L__c != 0
            AND ASI_CRM_CM_GS_per_9L__c != NULL
            ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC
        ])
        {
            System.debug(LoggingLevel.INFO, '*** thisbcm: ' + thisbcm);
             //system.debug('new thisbcm New contract :'+thisbcm);    
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
                    System.debug('SubBrandId '+ current_sbDataROI_map.get(key).SubBrandId );
                    System.debug('cmgs id '+ cmgs.Id );
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
            	subbrand_data subBrandData = current_sbDataROI_map.get(key);
            	System.debug(key);
            	String categoryName =  subBrandCategoryMap.get(subBrandData.SubBrandId);
                PeriodStr= null;
                if (subBrandData.period != null){
                    PeriodStr = subBrandData.period;
                }
                
                //Budget CM
                ActualCM = null;
                if (subBrandData.CM != null){
                    ActualCM = subBrandData.CM;
                }
                
                //Latest Budget CM
                LatestBudgetCM = null;
                if (subBrandData.latestBudgetCM != null){
                    LatestBudgetCM = subBrandData.latestBudgetCM;
                }
                //Budget GS
                ActualGS = null;
                if (subBrandData.GS != null){
                    ActualGS = subBrandData.GS;
                }
                
                //Total Volume
                TotalActualVol = null;
                if (ConVolume_map != null && subBrandData != null && subBrandData.SubBrandId != null && ConVolume_map.containsKey(subBrandData.SubBrandId)){
                    TotalActualVol = ConVolume_map.get(subBrandData.SubBrandId);
                }
                TotalEstimateVol = null;
                if (EstVolume_map != null && subBrandData != null && subBrandData.SubBrandId != null && EstVolume_map.containsKey(subBrandData.SubBrandId)){
                    TotalEstimateVol = EstVolume_map.get(subBrandData.SubBrandId);
                }
                if (TotalEstimateVol != null && ActualCM != null && PeriodStr != null){
                    CMTotalV0Estimate += ActualCM * TotalEstimateVol * PeriodStr;
                    System.debug('New contract CMTotalV0Estimate: '+ ActualCM +'*'+ TotalEstimateVol+'*'+ PeriodStr);
                }
                
                if (TotalEstimateVol != null && LatestBudgetCM != null && PeriodStr != null){
                    System.debug('LatestBudgetCMTotalV0: '+ LatestBudgetCM+ '*'+ TotalEstimateVol + '*'+  PeriodStr);
                    LatestBudgetCMTotalV0Estimate += LatestBudgetCM * TotalEstimateVol * PeriodStr;
                }
                
                if (TotalEstimateVol != null && ActualGS != null && PeriodStr != null){
                	Decimal GSSubTotal = ActualGS * TotalEstimateVol * PeriodStr;
                    NewContractV0Estimate.GrossSalesTotal += GSSubTotal;
                    addToDecimalMap(NewContractV0Estimate.SubBrandGSMap, subBrandData.SubBrandId, GSSubTotal);
                    System.debug(GSSubTotal);
                    System.debug('categoryName:' + categoryName);
                    if (categoryName != null)
                    	NewContractV0Estimate.CategoryGSMap = addToDecimalMap(NewContractV0Estimate.CategoryGSMap, categoryName, GSSubTotal);
                }               
                if (TotalActualVol != null && ActualCM != null && PeriodStr != null){
                    CMTotalV0Contract += ActualCM * TotalActualVol * PeriodStr;
                }
                
                if (TotalActualVol != null && LatestBudgetCM != null && PeriodStr != null){
                    LatestBudgetCMTotalV0Contract += LatestBudgetCM * TotalActualVol * PeriodStr;
                }
                
                if (TotalActualVol != null && ActualGS != null && PeriodStr != null){
                	Decimal GSSubTotal = ActualGS * TotalActualVol * PeriodStr;
                    NewContactV0Contract.GrossSalesTotal += GSSubTotal;
                    addToDecimalMap(NewContactV0Contract.SubBrandGSMap, subBrandData.SubBrandId, GSSubTotal);
                    System.debug(GSSubTotal);
                    System.debug('categoryName:' + categoryName);
                    if (categoryName != null)
                    	NewContactV0Contract.CategoryGSMap = addToDecimalMap(NewContactV0Contract.CategoryGSMap, categoryName, GSSubTotal);
                }
                
            }
        } // end of looping current_sbDataROI_map 
        
        //**************************Calculation**************************
        
        //Calculate 'Investment per CR12 eq btl ' = Trade expenses / (CR12 Conversion Factor in Sub-brand * estimate Monthly vol. * PO Period in Sub-Brand )
        if (NewContractV0Estimate.IntakeCR12 != 0 && NewContractV0Estimate.IntakeCR12!= null &&  NewContractV0Estimate.TradeExpenses != 0 &&  NewContractV0Estimate.TradeExpenses != null){
            //NewContractV0Estimate.IntakeCR12=NewContractV0Estimate.InvestmentCR12;
            NewContractV0Estimate.InvestmentCR12 =  (NewContractV0Estimate.TradeExpenses / NewContractV0Estimate.IntakeCR12).setScale(2);
        }
        if (NewContactV0Contract.IntakeCR12 != 0 && NewContactV0Contract.IntakeCR12!= null &&  NewContactV0Contract.TradeExpenses != 0 &&  NewContactV0Contract.TradeExpenses != null){
            //NewContactV0Contract.IntakeCR12=NewContactV0Contract.InvestmentCR12;
            NewContactV0Contract.InvestmentCR12 =  (NewContactV0Contract.TradeExpenses / NewContactV0Contract.IntakeCR12).setScale(2);
        }
        
        //Calculate Historical V0 Cont. Margin after A&P = SUM( Budget CMs * estimate Monthly vol. in 9L  of PO period) - Trade expenses
        if (CMTotalV0Estimate != null && NewContractV0Estimate.TradeExpenses != null){
            NewContractV0Estimate.MarginAfterAnP = CMTotalV0Estimate - NewContractV0Estimate.TradeExpenses;
        }
        if (CMTotalV0Estimate != null && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.MarginAfterAnP = CMTotalV0Contract - NewContactV0Contract.TradeExpenses;
        }
        
        if (BRSFContractVolumesTotal != null && NewContractV0Estimate.NoOfMonths != null){//system.debug(NewContactV0Contract.MarginAfterAnP +'VarExp_AllProducts.strB1.0'+BRSFContractVolumesTotal+'*'+NewContractV0Estimate.NoOfMonths);
            
            //NewContractV0Estimate.MarginPerBottle =BRSFContractVolumesTotal * NewContractV0Estimate.NoOfMonths;
            NewContractV0Estimate.IntakeSTD=BRSFEstimateVolumesTotal * NewContractV0Estimate.NoOfMonths;
        }
        if (BRSFEstimateVolumesTotal != null && NewContractV0Estimate.NoOfMonths != null){//system.debug(NewContractV0Estimate.MarginAfterAnP +'VarExp_AllProducts.strB'+BRSFEstimateVolumesTotal+'*'+NewContactV0Contract.NoOfMonths);
            //NewContactV0Contract.MarginPerBottle =BRSFEstimateVolumesTotal * NewContractV0Estimate.NoOfMonths;
            NewContactV0Contract.IntakeSTD = BRSFContractVolumesTotal* NewContactV0Contract.NoOfMonths;
        }
        
        
        //Margin Per Bottle
        if (NewContractV0Estimate.IntakeSTD!= 0 && NewContractV0Estimate.IntakeSTD != null && NewContractV0Estimate.MarginAfterAnP != 0 && NewContractV0Estimate.MarginAfterAnP != null){
            NewContractV0Estimate.MarginPerBottle = (NewContractV0Estimate.MarginAfterAnP /NewContractV0Estimate.IntakeSTD).setScale(2);
        }
        if (NewContactV0Contract.IntakeSTD!= 0 && NewContactV0Contract.IntakeSTD != null && NewContactV0Contract.MarginAfterAnP != 0 && NewContactV0Contract.MarginAfterAnP != null){
            NewContactV0Contract.MarginPerBottle = (NewContactV0Contract.MarginAfterAnP / NewContactV0Contract.IntakeSTD).setScale(2);
        }
        
        // ROI Intake Historical V0 = Cont. Margin before A&P / Trade expenses
        if (CMTotalV0Estimate != null && CMTotalV0Estimate != 0 && NewContractV0Estimate.TradeExpenses != 0 && NewContractV0Estimate.TradeExpenses != null){
            NewContractV0Estimate.CMTotal=CMTotalV0Estimate;
            NewContractV0Estimate.ROIIntake = (CMTotalV0Estimate / NewContractV0Estimate.TradeExpenses).setScale(2);
            NewContractV0Estimate.ROIActual=NewContractV0Estimate.ROIIntake;
        }                
        
        if (CMTotalV0Contract != null && CMTotalV0Contract != 0 && NewContactV0Contract.TradeExpenses != 0 && NewContactV0Contract.TradeExpenses != null){
            NewContactV0Contract.CMTotal=CMTotalV0Contract;
            NewContactV0Contract.ROIIntake = CMTotalV0Contract / NewContactV0Contract.TradeExpenses;
            NewContactV0Contract.ROIActual=NewContactV0Contract.ROIIntake;
        }
        
        //Calculate ROIProForma = Cont. Margin before A&P from latest CM regardless FY / Trade expenses 
        if (LatestBudgetCMTotalV0Estimate != null && LatestBudgetCMTotalV0Estimate != 0 && NewContractV0Estimate.TradeExpenses != 0 && NewContractV0Estimate.TradeExpenses!= null){
            NewContractV0Estimate.LatestBudgetCMTotal=LatestBudgetCMTotalV0Estimate;
            NewContractV0Estimate.ROIProForma = LatestBudgetCMTotalV0Estimate/ NewContractV0Estimate.TradeExpenses;
        }
        
        if (LatestBudgetCMTotalV0Contract != null && LatestBudgetCMTotalV0Contract != 0 && NewContactV0Contract.TradeExpenses != 0 && NewContactV0Contract.TradeExpenses!= null){
            NewContactV0Contract.LatestBudgetCMTotal=LatestBudgetCMTotalV0Contract;
            NewContactV0Contract.ROIProForma = LatestBudgetCMTotalV0Contract/ NewContactV0Contract.TradeExpenses;
        }
        
        //Calculate Subbrand A&P
        //Subbrand A&P = PSF (By Subbrand) + PSF (By Categroy) * Subbrand%(category) + (PSF(By Total) + Display Cost + Other Cost) * Subbrand%(Total)
        //Subbrand%(category) = Purchase Contract Value of Sub-brand/Total Purchase Contract Value of Same category
        //Subbrand%(Total) = Purchase Contract Value of Sub-brand/Total Contract Purchase Value
        Map<String, Decimal> categoryContractPurchaseTotalMap = new Map<String, Decimal>();
        Map<String, Decimal> subBrandCategoryPercentageMap = new Map<String, Decimal>();

        for (String contractLineKey : NewContactV0Contract.ContractLineMap.keySet()){
        	ContractLine line = NewContactV0Contract.ContractLineMap.get(contractLineKey);
        	if (line != null){
        		//Calculate subtotal of contract purchase value by category
	        	categoryContractPurchaseTotalMap = addToDecimalMap(categoryContractPurchaseTotalMap, line.SubBrandCategory, line.ContractValue);

	        	//PSF (By Subbrand)
	        	if (NewContactV0Contract.PSFLineMap.get(contractLineKey) != null){
	        		Decimal PSFSubbrandFee = NewContactV0Contract.PSFLineMap.get(contractLineKey).ContractPSFFees;
	        		NewContactV0Contract.SubBrandAPMap = addToDecimalMap(NewContactV0Contract.SubBrandAPMap, contractLineKey, PSFSubbrandFee);
	        	}
        	}
        }
        //system.debug('categoryContractPurchaseTotalMap: ' + categoryContractPurchaseTotalMap);
        //system.debug('SubBrandAPMap (After PSF By Brand): ' + NewContactV0Contract.SubBrandAPMap);


        //Calculate Subbrand%(category)
        for (String contractLineKey : NewContactV0Contract.SubBrandAPMap.keySet()){
        	ContractLine line = NewContactV0Contract.ContractLineMap.get(contractLineKey);
        	//PSF (By Category)
        	if (line != null && categoryContractPurchaseTotalMap.containsKey(line.SubBrandCategory) && categoryContractPurchaseTotalMap.get(line.SubBrandCategory) > 0 &&
        			NewContactV0Contract.PSFLineMap != null && NewContactV0Contract.PSFLineMap.containsKey(line.SubBrandCategory) && NewContactV0Contract.PSFLineMap.get(line.SubBrandCategory).ContractPSFFees > 0){
        		Decimal PSFCategoryFee = line.ContractValue / categoryContractPurchaseTotalMap.get(line.SubBrandCategory) * NewContactV0Contract.PSFLineMap.get(line.SubBrandCategory).ContractPSFFees;
        		NewContactV0Contract.SubBrandAPMap = addToDecimalMap(NewContactV0Contract.SubBrandAPMap, contractLineKey, PSFCategoryFee);
        	}
        }
        //system.debug('SubBrandAPMap (After PSF By Category): ' + NewContactV0Contract.SubBrandAPMap);

        //Calculate (PSF(By Total) + Display Cost + Other Cost) * Subbrand%(Total)
        Decimal subTotalCost = 0.0;
        if (NewContactV0Contract.PSFLineMap != null && NewContactV0Contract.PSFLineMap.containsKey('00000null') && NewContactV0Contract.PSFLineMap.get('00000null').ContractTotalFees > 0)
        	subTotalCost += NewContactV0Contract.PSFLineMap.get('00000null').ContractTotalFees;
        subTotalCost += NewContactV0Contract.DisplayExpensesTotal;
        subTotalCost += NewContactV0Contract.OtherExpensesTotal;
        for (String contractLineKey : NewContactV0Contract.SubBrandAPMap.keySet()){
        	ContractLine line = NewContactV0Contract.ContractLineMap.get(contractLineKey);
        	if (NewContactV0Contract.Value > 0)
        		NewContactV0Contract.SubBrandAPMap = addToDecimalMap(NewContactV0Contract.SubBrandAPMap, contractLineKey, subTotalCost * line.ContractValue / NewContactV0Contract.Value);
        }
        //system.debug('SubBrandAPMap (Final): ' + NewContactV0Contract.SubBrandAPMap);

        for (String contractLineKey : NewContactV0Contract.SubBrandAPMap.keySet()){
        	ContractLine line = NewContactV0Contract.ContractLineMap.get(contractLineKey);

        	if (line != null && NewContactV0Contract.SubBrandAPMap != null && NewContactV0Contract.SubBrandGSMap != null && NewContactV0Contract.SubBrandGSMap.get(line.strSubBrand) != null && NewContactV0Contract.SubBrandGSMap.get(line.strSubBrand) != 0){
	        	Decimal subbrandGSPercentage = NewContactV0Contract.SubBrandAPMap.get(contractLineKey) / NewContactV0Contract.SubBrandGSMap.get(line.strSubBrand) * 100;
	        	subbrandGSPercentage = subbrandGSPercentage.setScale(2);
	        	NewContactV0Contract.SubBrandGSPercentageMap = addToDecimalMap(NewContactV0Contract.SubBrandGSPercentageMap, contractLineKey, subbrandGSPercentage);
        	} else {
        		NewContactV0Contract.SubBrandGSPercentageMap = addToDecimalMap(NewContactV0Contract.SubBrandGSPercentageMap, contractLineKey, 0);
        	}
        }


        List<FinancialIndicator> ReturnList = new List<FinancialIndicator>();
        
        ReturnList.add(NewContractV0Estimate);
        System.debug(NewContractV0Estimate);
        System.debug(NewContactV0Contract);
        ReturnList.add(NewContactV0Contract);
        System.debug('RestructureCurrentFinancialIndicatorData ReturnList');
        System.debug(ReturnList);
        UpsertAttachment(thisCC.Id, System.JSON.serialize(ReturnList),'Contract Data' );
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
        
        Set<Id> thisSubbrandId = new Set<Id>();
        Map<String,Decimal> EstVolume_map = new Map<String,Decimal>(); 
        Map<Date, Decimal> thisCC_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        Map <String, subbrand_data> current_sbDataROI_map =new Map <String, subbrand_data>();
        Boolean isPOS = false;
        Boolean isORS = false;//Outlet Reception Scan
        
        String V0_0_POId=thisCC.Id;
        if(thisCC.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0_0_POId=thisCC.ASI_CRM_CN_V0_0_PO_version__c;
        }
        
        if(thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null){
            POModiContractFI.OtherExpensesTotal = thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
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
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c  ContractLine : [SELECT Id, 
        																ASI_CRM_CN_Est_Total_Dummy__c
                                                                    FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :V0_0_POId] )
        {
            TotalVariableCost += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
        }
        //TODO delete PSFEstTotal
        Decimal PSFEstTotal=0;
        Decimal Total_IntakeBtl=0;

        //Looping current contract Detail Lines
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : getBRSFLines(thisCC.Id)){
            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){
                /*if(thisCC.ASI_CRM_CN_Is_Dolphin__c){
                    thisSubbrandId.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                    if (EstVolume_map.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                        Decimal estvol = EstVolume_map.get(ContractLine.ASI_CRM_CN_Sub_Brand__c)+ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c;
                        EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, estvol );
                    } else {
                        EstVolume_map.put(ContractLine.ASI_CRM_CN_Sub_Brand__c, ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c);
                    }
                    if(thisCC_Period_map != null && thisCC_Period_map.size() > 0){
                        for (Date V0CCdate : thisCC_Period_map.keySet() ){
                            Date strDateCC = ASI_CRM_DateUtilClass.getFiscalYearEndDate(V0CCdate);
                            String strkey_p = String.valueOf(strDateCC) + ContractLine.ASI_CRM_CN_Sub_Brand__c ;
                            subbrand_data newitem = new subbrand_data();
                            newitem.period = thisCC_Period_map.get(V0CCdate);//This fiscal year's month number
                            newitem.SubBrandId = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                            newitem.TotalVolume = 0;
                            newitem.TotalEstVolume = 0;
                            current_sbDataROI_map.put(strkey_p, newitem);
                        }
                    }
                }*/
                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                    POModiContractFI.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                    isPOS = (ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c == 'POS');
                }
                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null){
                    isORS = (ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c == 'Outlet Reception Scan');        
                }
                
                String LineKey=NameSortingASC(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                ContractLine thisContractLine = POModiContractFI.ContractLineMap.get(LineKey);
                
                if(POModiContractFI.ContractLineMap.containsKey(LineKey)){
                    thisContractLine.VFinalFees = thisContractLine.VFinalFees + ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    thisContractLine.VFinalVolume+=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.VFinalFees = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    ContractDetail.VFinalTotalFees= ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c *ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c:0;
                    
                    ContractDetail.VFinalVolume=ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c!=null?ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c*thisCC.ASI_CRM_CN_No_of_Months__c:0;
                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                    ContractDetail.strSubBrand = ContractLine.ASI_CRM_CN_Sub_Brand__c;
                    ContractDetail.strBrand = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c;
                         
                    POModiContractFI.ContractLineMap.put(LineKey,ContractDetail);
                }
                
                
            }
            
            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF'){
            	if (ContractLine.ASI_CRM_Type__c=='PSF')
                	PSFEstTotal+=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
            }
            
            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
                POModiContractFI.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total__c==null?0:ContractLine.ASI_CRM_CN_Est_Total__c;
            }else{
                POModiContractFI.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
            }
        }

        POModiContractFI.DisplayExpensesTotal = thisCC.ASI_CRM_CN_Expected_Display_Est_Total__c;
        POModiContractFI.PSFExpensesTotal = thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c;
        POModiContractFI.TradeExpenses = POModiContractFI.PSFExpensesTotal + POModiContractFI.DisplayExpensesTotal + POModiContractFI.OtherExpensesTotal;
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
        
        Date CutOffDay = ASI_CRM_DateUtilClass.getCutOffDate();
        Date TillEndPOM = ASI_CRM_DateUtilClass.findMinMaxDate(CutOffDay, thisCC.ASI_CRM_CN_PO_End_Date__c, 'MIN');
        Date TillEnd;
        if (CutOffDay >= thisCC.ASI_CRM_CN_PO_End_Date__c)
            TillEnd = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_End_Date__c);
        else
            TillEnd = CutOffDay; 
        Integer PeriodA = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
        Integer PeriodB = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        
        System.debug(AllOutlet+'ReconstructCurrentPOModiFIData TillEndPOM: ' + TillEndPOM );
        System.debug('PeriodA: '+PeriodA);
        System.debug('PeriodB: '+PeriodB );
        Set<Id> POMv1_sbid = new Set<Id>();
        Decimal Total_IntakeBtl_prorate=0;
        
        //**************************Looping Sub-Brand Volume**************************
        List<ASI_CRM_Subbrand_Volume__c> subBrandVolumeList = new List<ASI_CRM_Subbrand_Volume__c>();
        String subBrandVolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
        subBrandVolumeQuery += 'WHERE ASI_CRM_Subbrand__c !=null ' + 
                               'AND ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
                               'AND ASI_CRM_End_Date__c >= ' + String.valueOf(thisCC.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
                               'AND ASI_CRM_End_Date__c <= :TillEndPOM ' +
                               'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = false ';
        
        if (AllOutlet.size() >= outletThreshold()){
        	subBrandVolumeQuery += 'AND ASI_CRM_CN_Contract__c = \'' + thisCC.Id + '\' ' +
        							'AND recordtypeId = \'' + Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')+'\' ';
            
        	
        } else {
        	subBrandVolumeQuery += 'AND ASI_CRM_Account__c IN: AllOutlet ' +
        							'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';
                                                         
        }

        subBrandVolumeList = Database.query(subBrandVolumeQuery);
        
        
          
        for (ASI_CRM_Subbrand_Volume__c SubBrandVolume: subBrandVolumeList)
        {
            String SubbrandGroupName='0. Not Specified';
            if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                SubbrandGroupName=SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null?SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c :SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            }
            
            Decimal Volumes = 0;
            if(isORS){
                Volumes = denullify(SubBrandVolume.ASI_CRM_Green_ORS_9L__c,0) + denullify(SubBrandVolume.ASI_CRM_Empty_Bottle__c,0);
            }else{
                Volumes = denullify(SubBrandVolume.ASI_CRM_Actual_Vol__c, 0) * denullify(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Standard_Bottle_Size__c, 700) / 9000;
            }
            Decimal VolumeBtl = 0;
            if(isORS){
                VolumeBtl = denullify(SubBrandVolume.ASI_CRM_Green_ORS_Std_Btl__c,0) + denullify(SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c,0);
            }else{
                VolumeBtl = denullify(SubBrandVolume.ASI_CRM_Actual_Vol_STD__c, 0);
            }
            Decimal Value = 0;
            if (isPOS) {
                Value = denullify(SubBrandVolume.ASI_CRM_POS_GS__c, 0);
            } else if (isORS) {
                Value = denullify(SubBrandVolume.ASI_CRM_Green_ORS_GS__c, 0) + denullify(SubBrandVolume.ASI_CRM_Empty_Bottle_GS__c,0);
            } else {
                Value = denullify(SubBrandVolume.ASI_CRM_CN_Intake_GS_T1_price__c, 0);
            }
            // Decimal Value= isPOS ? denullify(SubBrandVolume.ASI_CRM_POS_GS__c, 0) : denullify(SubBrandVolume.ASI_CRM_CN_Intake_GS_T1_price__c, 0);

            Decimal VariableBottles = 0;    

            Total_IntakeBtl += VolumeBtl;
            Total_IntakeBtl_prorate += VolumeBtl;
            
            
            //**prorate**
            if (PeriodA != 0 && PeriodA != null && PeriodB != 0 && PeriodB != null){
                Volumes = Volumes/PeriodA * PeriodB;
                VolumeBtl = VolumeBtl/PeriodA * PeriodB;
                VariableBottles = VolumeBtl/PeriodB ;//<----Monthly (Std. Btl)                               (VolumeBtl/PeriodA) * PeriodB;
                Value = Value/PeriodA * PeriodB;
            }
            Total_IntakeBtl_prorate+=VolumeBtl;
            
            POModiContractFI.IntakeSTD+=VolumeBtl;
            POModiContractFI.Volumes += Volumes;
            POModiContractFI.Value += Value;
            
            Date pomdate= ASI_CRM_DateUtilClass.getFiscalYearEndDate(SubBrandVolume.ASI_CRM_End_Date__c);
            String strkey = String.valueOf(pomdate) + SubBrandVolume.ASI_CRM_Subbrand__c;
            
            if(isORS){
                POModiContractFI.InvestmentCR12 += denullify(SubBrandVolume.ASI_CRM_Green_ORS_CR12__c,0) + denullify(SubBrandVolume.ASI_CRM_Empty_Bottle_CR12__c,0);
            }else{
                POModiContractFI.InvestmentCR12 += SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c:0;
                POModiContractFI.InvestmentCR12 += SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c:0;
                POModiContractFI.InvestmentCR12 += SubBrandVolume.ASI_CRM_PR_Direct_CR12__c!=null? SubBrandVolume.ASI_CRM_PR_Direct_CR12__c:0;
            }
            

            //Actual Volume (9L) = T1_Depletion + T2_Depletion + PR_Direct
            Decimal ActualVolume=0;
            if(isORS){
                ActualVolume = denullify(SubBrandVolume.ASI_CRM_Green_ORS_9L__c,0) + denullify(SubBrandVolume.ASI_CRM_Empty_Bottle__c,0);
            }else{
                ActualVolume+=SubBrandVolume.ASI_CRM_T1_Depletion__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion__c:0;
                ActualVolume+=SubBrandVolume.ASI_CRM_T2_Depletion__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion__c:0;
                ActualVolume+=SubBrandVolume.ASI_CRM_PR_Direct__c!=null? SubBrandVolume.ASI_CRM_PR_Direct__c:0;
            }

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

            //ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c ASI_CRM_Subbrand__r.Name
            
            String subBrandKey =NameSortingASC(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + SubBrandVolume.ASI_CRM_Subbrand__r.Name; 
            ContractLine subBrandContractLine = POModiContractFI.ContractLineMap.get(subBrandKey);
            
            if(POModiContractFI.ContractLineMap.containsKey(subBrandKey)){
                subBrandContractLine.VFinalBottles =subBrandContractLine.VFinalBottles + VariableBottles ;
                //subBrandContractLine.VFinalTotalFees +=  subBrandContractLine.VFinalFees * VarTotal;
                subBrandContractLine.VFinalActualVolume = subBrandContractLine.VFinalActualVolume + VariableBottles ;
            }else{
                ContractLine ContractDetail = new ContractLine ();
                ContractDetail.VFinalBottles = VariableBottles;
                ContractDetail.VFinalActualVolume=VariableBottles;
                ContractDetail.SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.Name;
                ContractDetail.SubBrandGrade= SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                ContractDetail.strSubBrand = SubBrandVolume.ASI_CRM_Subbrand__c;
                ContractDetail.strBrand = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c;
                
                POModiContractFI.ContractLineMap.put(subBrandKey,ContractDetail);
            }
        }// End of Looping Sub-Brand Volume
        
        
        
        System.debug('POModiContractFI Volumes: '+POModiContractFI.Volumes);
        
        AdditionalFIMap.put('Total_IntakeBtl',Total_IntakeBtl); 
        AdditionalFIMap.put('Total_IntakeBtl_prorate',Total_IntakeBtl_prorate); 
        
        //Prorate 
        if (thisCC.ASI_CRM_CN_PO_End_Date__c > CutOffDay){
            Integer daysperiod = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
            Integer prorateperiod = ASI_CRM_DateUtilClass.monthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
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
        
        
        
        Date v1startdate = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        Date v1enddate;
        if (thisCC.ASI_CRM_CN_PO_End_Date__c < CutOffDay){
            v1enddate = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_End_Date__c);
        }else{
            v1enddate = CutOffDay;
        }
        
        Map<Date, Decimal> Lastest_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        System.debug('PO Modi : Lastest_Period_map'+Lastest_Period_map);
        Map<String, subbrand_data> Lastest_ROImap = new Map <String, subbrand_data>();
        if (Lastest_Period_map != null && Lastest_Period_map.size() > 0){
            String strkey = null;
            for (Date v1period : Lastest_Period_map.keySet()){
                if (POMv1_sbid != null && POMv1_sbid.size() > 0){
                    for (Id sbid : POMv1_sbid){
                        strkey = String.valueOf(v1period) + sbid;
                        //system.debug('strkey: '+strkey);
                        subbrand_data newitem = new subbrand_data();
                        newitem.period = Lastest_Period_map.get(v1period);
                        newitem.SubBrandId = sbid;
                        newitem.year = String.valueOf(ASI_CRM_DateUtilClass.getFiscalYearEndDate(v1period).year());
                        newitem.TotalVolume = 0;
                        Lastest_ROImap.put(strkey, newitem);
                    }
                }
            }
        }
        
        //Calculate RegionSubBrandCM_Map
        String currentFY = String.valueOf(ASI_CRM_DateUtilClass.getFiscalYearEndDate(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';

        System.debug('RegionSubBrandCM_Map SQL : currentFY:'+currentFY+'currentFY2:'+currentFY2);
        Map<String,Decimal> RegionSubBrandCM_Map = new Map<String,Decimal> ();
        String LBCMIDstr_debug=' ';
        for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c
        							  FROM ASI_CRM_CM_GS__c
                                      WHERE ASI_CRM_CN_Month__c = 6  
                                      AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2  OR ASI_CRM_YEAR__c = :currentFY3 ) 
                                      AND ASI_CRM_Region__c = :strRegion  
                                      AND ASI_CRM_TYPE__c = 'Budget CM'
                                      AND ASI_CRM_CM_GS_per_9L__c != NULL
                                      AND ASI_CRM_CM_GS_per_9L__c != 0  
                                      ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
            Decimal cm=0.0;
            if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                cm = lbcm.ASI_CRM_CM_GS_per_9L__c; 
            }
            if (!RegionSubBrandCM_Map.containsKey(ProductCode)){
                LBCMIDstr_debug +=lbcm.Id+',';
                RegionSubBrandCM_Map.put(ProductCode,cm) ;   
            }
        }
        System.debug('LBCMIDstr_debug: '+LBCMIDstr_debug);
        
        Map<String, Decimal> lastestroi = new Map<String, Decimal>();
        Map<String, Decimal> lastestproformaroi = new Map<String, Decimal>();
        Map<String, Decimal> Latest_ActualGS = new Map<String, Decimal>();
        
        System.debug('Now PO Mod v1startdate'+v1startdate);
        System.debug('Now PO Mod v1enddate'+v1enddate);
        
        for (ASI_CRM_CM_GS__c v1budgetcmtemp : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                                FROM ASI_CRM_CM_GS__c
                                                WHERE ASI_CRM_PRODUCTCODE__c IN :POMv1_sbid 
                                                AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                AND ASI_CRM_CN_Month_End_Date__c >= :v1startdate
                                                AND ASI_CRM_CN_Month_End_Date__c <= :v1enddate
                                                AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS' )
                                                AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != NULL ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
        {
            String strkey = String.valueOf(v1budgetcmtemp.ASI_CRM_CN_Month_End_Date__c) + v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c;
            //system.debug('CM GSstrkey:'+strkey);
            String lastestkey = v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c;
            Decimal ActualData = 0;
            
            if (v1budgetcmtemp.ASI_CRM_CM_GS_per_9L__c != null){
                ActualData = v1budgetcmtemp.ASI_CRM_CM_GS_per_9L__c;                
            }
            
            if (v1budgetcmtemp.ASI_CRM_TYPE__c == 'YTD GS'){
                if (!Latest_ActualGS.containsKey(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c)){
                    Latest_ActualGS.put(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c, v1budgetcmtemp.ASI_CRM_CM_GS_per_9L__c);
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
                    //system.debug('Found  GSstrkey:'+v1budgetcmtemp);
                    
                    if (Lastest_ROImap.get(strkey).latestBudgetCM == null || Lastest_ROImap.get(strkey).latestBudgetCM == null){
                        if (RegionSubBrandCM_Map.containsKey(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c)){
                            Lastest_ROImap.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c);
                        }
                    }
                    
                }
                
                if (Lastest_ROImap != null && !lastestroi.containsKey(lastestkey) && ActualData != null && ActualData != 0){//added actualcm != NULL and actualcm != 0
                    lastestroi.put(lastestkey, ActualData);
                }
                if (Lastest_ROImap != null && !lastestproformaroi.containsKey(lastestkey)){
                    if (RegionSubBrandCM_Map.containsKey(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c)) {
                        lastestproformaroi.put(lastestkey, RegionSubBrandCM_Map.get(v1budgetcmtemp.ASI_CRM_PRODUCTCODE__c));
                    }
                }
            }
            
            
            
        }// End of CM/GS Looping
        
        
        if(Lastest_ROImap != null && Lastest_ROImap.size() > 0){
            Integer daysperiod = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c,  CutOffDay);
            Integer prorateperiod = ASI_CRM_DateUtilClass.monthDiff(CutOffDay.addDays(+1), thisCC.ASI_CRM_CN_PO_End_Date__c);
            if (prorateperiod < 0) prorateperiod = 0;
            Decimal Average9L = 0;
            
            for (String v1roitemp : Lastest_ROImap.keySet()){
                Decimal strv1vol = 0;
                Decimal prorate_actualcm = 0;

                if (POMv1_sbvol.containsKey(v1roitemp)){
                    strv1vol = POMv1_sbvol.get(v1roitemp);
                }


                //**********Actual CM *********
                Decimal actualcm =0;
                if (Lastest_ROImap.get(v1roitemp).CM != null && Lastest_ROImap.get(v1roitemp).CM != 0){
                    actualcm = Lastest_ROImap.get(v1roitemp).CM;
                }else if (lastestroi != null && lastestroi.containsKey(Lastest_ROImap.get(v1roitemp).SubBrandId)){
                    actualcm = lastestroi.get(Lastest_ROImap.get(v1roitemp).SubBrandId);
                }
                
                if (strv1vol != null && actualcm != null){
                    CMTotal += strv1vol * actualcm; // ROI_POM.strTotalB

                    Average9L = 0;
                    if (lastestroi != null && lastestroi.containsKey(Lastest_ROImap.get(v1roitemp).SubBrandId))
                        prorate_actualcm = lastestroi.get(Lastest_ROImap.get(v1roitemp).SubBrandId);
                    if (strv1vol != 0 && strv1vol != null && daysperiod != null && daysperiod != 0)
                        Average9L = strv1vol / daysperiod;
                    if (Average9L != null && prorateperiod != null && prorate_actualcm != null){
                        CMTotal += Average9L *  prorateperiod * prorate_actualcm;
                    }
                    
                }
                
                //*********Latest Budget CM*********
                Decimal lbcm = 0;
                Decimal prorate_lbcm = 0;
                if (Lastest_ROImap.get(v1roitemp).latestBudgetCM != null && Lastest_ROImap.get(v1roitemp).latestBudgetCM != 0)
                    lbcm = Lastest_ROImap.get(v1roitemp).latestBudgetCM;
                else if (lastestproformaroi != null && lastestproformaroi.containsKey(Lastest_ROImap.get(v1roitemp).SubBrandId))
                    lbcm = lastestproformaroi.get(Lastest_ROImap.get(v1roitemp).SubBrandId);
                if (strv1vol != null && lbcm != null){
                    LatestBudgetCMTotal += strv1vol * lbcm; //ROI_POM.ProFormaROIstrTotalB
                    Average9L = 0;
                    if (lastestproformaroi != null && lastestproformaroi.containsKey(Lastest_ROImap.get(v1roitemp).SubBrandId))
                        prorate_lbcm = lastestproformaroi.get(Lastest_ROImap.get(v1roitemp).SubBrandId);
                    if (strv1vol != 0 && strv1vol != null && daysperiod != null && daysperiod != 0)
                        Average9L = strv1vol / daysperiod;
                    if (Average9L != null && prorateperiod != null && prorate_lbcm != null)
                        LatestBudgetCMTotal += Average9L *  prorateperiod * prorate_lbcm;   //ROI_POM.ProFormaROIstrTotalB
                }
                
                //**********Actual GS*********
                Decimal ActualGS = null;
                if (Lastest_ROImap.get(v1roitemp).GS != null && Lastest_ROImap.get(v1roitemp).GS != 0){
                    ActualGS = Lastest_ROImap.get(v1roitemp).GS;
                }else{
                    if (Latest_ActualGS != null && Latest_ActualGS.containsKey(Lastest_ROImap.get(v1roitemp).SubBrandId)){
                        ActualGS = Latest_ActualGS.get(Lastest_ROImap.get(v1roitemp).SubBrandId);
                    }else{
                        ActualGS=0;
                    }
                }
                
                if (strv1vol != null && ActualGS != null){
                    System.debug('key ' + v1roitemp);
                    System.debug('ActualGS ' + ActualGS);
                    System.debug('strv1vol ' + strv1vol);
                    POModiContractFI.GrossSalesTotal += ActualGS * strv1vol;
                }
                
                Decimal ActualGS_prorate = 0;
                if (Latest_ActualGS != null && Latest_ActualGS.containsKey(Lastest_ROImap.get(v1roitemp).SubBrandId)){
                    ActualGS_prorate = Latest_ActualGS.get(Lastest_ROImap.get(v1roitemp).SubBrandId);
                }  
                
                if(ActualGS_prorate!=null && strv1vol!=null && daysperiod!=null && daysperiod!=0 && prorateperiod!=null){
                //if (prorateperiod != null && prorateperiod != 0 && strv1vol != null && strv1vol != 0 && PeriodD_prorate != null && ActualGS_prorate != null && daysperiod!=null && daysperiod !=0){
                   POModiContractFI.GrossSalesTotal  += ActualGS_prorate * (strv1vol / daysperiod )* prorateperiod;
                }
                
                
            }

            System.debug('Latest_ActualGS size  ' + Latest_ActualGS.size());
            System.debug('POModiContractFI.GrossSalesTotal ' + POModiContractFI.GrossSalesTotal);
        }
        
        /*if(thisCC.ASI_CRM_CN_Is_Dolphin__c){
            POModiContractFI.GrossSalesTotal = 0;
            //for querying Budget GS
            Date strStartBGDate;
            Date strEndBGDate;
            if(thisCC != null && thisCC.ASI_CRM_CN_PO_Start_Date__c != null)
                strStartBGDate = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
            if(thisCC != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null)
                strEndBGDate = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
            Date strStartBGDate2 = Date.newInstance(strStartBGDate.addYears(-1).year(), 6, 30);
            Date strEndBGDate2 = Date.newInstance(strEndBGDate.year(), 6, 30);
            Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();
            System.debug('RestructureCurrentFinancialIndicatorData CM GS strStartBGDate:'+strStartBGDate);
            System.debug('strEndBGDate:'+strEndBGDate);
            System.debug('strStartBGDate2:'+strStartBGDate2);
            System.debug(' strEndBGDate2:'+strEndBGDate2);
            for (ASI_CRM_CM_GS__c thisbcm : [
                SELECT Id,
                    ASI_CRM_CM_GS_per_9L__c,
                    ASI_CRM_TYPE__c,
                    ASI_CRM_PRODUCTCODE__c,
                    ASI_CRM_Region__c,
                    ASI_CRM_PRODUCTCODE__r.Name,
                    ASI_CRM_PRODUCTCODE__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c,
                    ASI_CRM_CN_Month_End_Date__c,
                    ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                    ASI_CRM_CN_Month__c
                FROM ASI_CRM_CM_GS__c
                WHERE ASI_CRM_PRODUCTCODE__c IN :thisSubbrandId
                AND ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                AND ((ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate
                AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate ) OR
                (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2
                AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2
                AND ASI_CRM_CN_Month__c = 6 ))
                AND ASI_CRM_TYPE__c = 'Budget GS'
                AND ASI_CRM_CM_GS_per_9L__c != 0
                AND ASI_CRM_CM_GS_per_9L__c != NULL
                ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC
            ]){
                Date strCMdate = thisbcm.ASI_CRM_CN_Month_End_Date__c;
                String strkey = String.valueOf(strCMdate) + thisbcm.ASI_CRM_PRODUCTCODE__c;
                if (current_sbDataROI_map.containsKey(strkey)){
                    if (current_sbDataROI_map.get(strkey).GS == null || current_sbDataROI_map.get(strkey).GS == 0){
                        current_sbDataROI_map.get(strkey).GS= thisbcm.ASI_CRM_CM_GS_per_9L__c;
                    }
                }  
            }
            if (current_sbDataROI_map != null && current_sbDataROI_map.size() > 0){
                Decimal ActualGS;
                Decimal TotalEstimateVol; // totalestimatevol--> TotalEstimateVol
                Decimal PeriodStr; //change from strperiod to PeriodStr
                for (String key : current_sbDataROI_map.keySet()){
                    subbrand_data subBrandData = current_sbDataROI_map.get(key);
                    PeriodStr= null;
                    if (subBrandData.period != null){
                        PeriodStr = subBrandData.period;
                    }
                    System.debug(LoggingLevel.INFO, '*** PeriodStr: ' + PeriodStr);
                    //Budget GS
                    ActualGS = null;
                    if (subBrandData.GS != null){
                        ActualGS = subBrandData.GS;
                    }
                    System.debug(LoggingLevel.INFO, '*** ActualGS: ' + ActualGS);
                    TotalEstimateVol = null;
                    if (EstVolume_map != null && subBrandData != null && subBrandData.SubBrandId != null && EstVolume_map.containsKey(subBrandData.SubBrandId)){
                        TotalEstimateVol = EstVolume_map.get(subBrandData.SubBrandId);
                    }
                    System.debug(LoggingLevel.INFO, '*** TotalEstimateVol: ' + TotalEstimateVol);
                    if (TotalEstimateVol != null && ActualGS != null && PeriodStr != null){
                        POModiContractFI.GrossSalesTotal += ActualGS * TotalEstimateVol * PeriodStr;
                    }
                }
            }
            System.debug(LoggingLevel.INFO, '*** POModiContractFI.GrossSalesTotal: ' + POModiContractFI.GrossSalesTotal);
        }*/
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
        Date v0TillEndPOM = ASI_CRM_DateUtilClass.getEndOfMonth(ASI_CRM_DateUtilClass.findMinMaxDate(CutOffDay, thisCC.ASI_CRM_CN_PO_End_Date__c, 'MIN'));
        System.debug('PO Modi:AllOutlet'+AllOutlet);
        System.debug('PO Modi:Start Date'+thisCC.ASI_CRM_CN_PO_Start_Date__c);
        System.debug('PO Modi:End Date'+v0TillEndPOM);
        /*
        v0_VolList = [SELECT id, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,  ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c,ASI_CRM_Subbrand__c
                      FROM ASI_CRM_Subbrand_Volume__c 
                      WHERE ASI_CRM_CN_Competitor_Sub_brand__c != true  
                      AND ASI_CRM_End_Date__c >= :thisCC.ASI_CRM_CN_PO_Start_Date__c  
                      AND ASI_CRM_End_Date__c <= :v0TillEndPOM 
                      AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                      AND ASI_CRM_Account__c IN: AllOutlet ];
        */
        
        String subBrandV0VolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
        subBrandV0VolumeQuery += 'WHERE ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
        							'AND ASI_CRM_End_Date__c >= ' + String.valueOf(thisCC.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
                               		'AND ASI_CRM_End_Date__c <= :v0TillEndPOM ' +
                               		'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE ';
        
        if (AllOutlet.size() >= outletThreshold()){
        	subBrandV0VolumeQuery += 'AND ASI_CRM_CN_Contract__c = \'' + thisCC.Id + '\' ' +
        							'AND recordtypeId = \'' + Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')+'\' ';
            
        	
        } else {
        	subBrandV0VolumeQuery += 'AND ASI_CRM_Account__c IN: AllOutlet ' +
        							'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';
                                                         
        }

        v0_VolList = Database.query(subBrandV0VolumeQuery);
        
        
        Decimal v0_actualvol_pom = 0;
        
        if (v0_VolList != null && v0_VolList.size() > 0){
            for(ASI_CRM_Subbrand_Volume__c v0vol : v0_VolList){
                if(thisCC.ASI_CRM_CN_Is_Dolphin__c){
                    v0_actualvol_pom += denullify(v0vol.ASI_CRM_Green_ORS_CR12__c,0) + denullify(v0vol.ASI_CRM_Empty_Bottle_CR12__c,0);
                }else{
                    if (v0vol.ASI_CRM_T1_Depletion_CR12__c != null)
                        v0_actualvol_pom += v0vol.ASI_CRM_T1_Depletion_CR12__c;
                    if (v0vol.ASI_CRM_T2_Depletion_CR12__c != null)
                        v0_actualvol_pom += v0vol.ASI_CRM_T2_Depletion_CR12__c;
                    if (v0vol.ASI_CRM_PR_Direct_CR12__c != null)
                        v0_actualvol_pom += v0vol.ASI_CRM_PR_Direct_CR12__c;
                }
            }
        }
        
        Decimal v0_estvol_pom=0;
        List<ASI_Attachment__c> AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c
                                                 FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = : thisCC.Id AND ASI_CRM_Type__c ='Historical Modi Data' ];
        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){ 
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                List<FinancialIndicator> HistoricalContractList =(List<FinancialIndicator>)System.JSON.deserialize(JsonString,List<FinancialIndicator>.class); // system.debug(HistoricalContractList[0].AddOnString);
                Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(HistoricalContractList[0].AddOnString,Map<String,Decimal>.class);
                if( TempMap.containsKey('v0_estvol_pom')  ){
                    v0_estvol_pom= TempMap.get('v0_estvol_pom');
                }
                
            }
        }
        
        
        
        Date cutoffend;
        if (CutOffDay > thisCC.ASI_CRM_CN_PO_End_Date__c)
            cutoffend = thisCC.ASI_CRM_CN_PO_End_Date__c;
        else
            cutoffend = CutOffDay;
        Integer thisCCPeriod = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
        Integer v0CCPeriod = thisCCPeriod;
        if (thisCC.ASI_CRM_CN_V0_0_PO_version__c != null)
            v0CCPeriod = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c);
        Integer THCTDPeriod = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, cutoffend);
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
            System.debug('v0_actualVol_Period ' + v0_actualVol_Period);
            System.debug('v0_estvol_pom ' + v0_estvol_pom);
            System.debug('v0CCPeriod ' + v0CCPeriod);
            System.debug('PSFEstTotal ' + PSFEstTotal);
            ActVSEst_Vol = v0_actualVol_Period / (v0_estvol_pom * v0CCPeriod);
        }
        

        if(ActVSEst_Vol!=null){
            ActVSEst_Vol= ActVSEst_Vol*thisCC.ASI_CRM_Expected_V0_PSF_Estimated_Total__c;
        }
        
        if(thisCC.ASI_CRM_CN_Is_Dolphin__c){
            ActVSEst_Vol=PSFEstTotal;
        }
        AdditionalFIMap.put('ActVSEst_Vol',ActVSEst_Vol);
        
        
        
        POModiContractFI.AddOnString = System.JSON.serialize(AdditionalFIMap);
        
        
        List<FinancialIndicator> ReturnList = new List<FinancialIndicator>();
        ReturnList.add(POModiContractFI);
        UpsertAttachment(thisCC.Id, System.JSON.serialize(ReturnList),'PO Modification Data' );
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
        
        FinancialIndicator  V0POModiContractFI= new FinancialIndicator(); 
        Map<String, Decimal> AdditionalFIMap = new Map<String, Decimal>();
        V0POModiContractFI.ContractId = thisCC.ASI_CRM_CN_V0_0_PO_version__c;
        
        
        Decimal v0_estvol_pom = 0;
        Decimal strv0VarCost = 0;
        
        Map<Id, Decimal> BRSF_SBVol = new Map<Id, Decimal>();
        Set<Id> V0SubBrandIdSet= new Set<Id>();
        
        //**************************Looping V0.0 BRSF Lines**************************
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>  ContractLineList = getBRSFLines(thisCC.ASI_CRM_CN_V0_0_PO_version__c);
        
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
        
        System.debug('Now Total Contract Amount: '+thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c);
        System.debug('V0POModiContractFI.InvestmentCR12 '+V0POModiContractFI.InvestmentCR12);
        
        if (V0POModiContractFI.InvestmentCR12 != null && V0POModiContractFI.InvestmentCR12 != 0 && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != null && thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c != 0)
            V0POModiContractFI.InvestmentCR12 = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c / V0POModiContractFI.InvestmentCR12 ;
        
        Date v0startdate= Date.today();
        Date v0enddate= Date.today();
        
        if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!= null){
            v0startdate = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c.addYears(-1));
        }
        
        if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!= null){   
            v0enddate = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c.addYears(+1));
        }
        
        String currentFY = String.valueOf(ASI_CRM_DateUtilClass.getFiscalYearEndDate(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';
        
        //Calculate RegionSubBrandCM_Map
        for (ASI_CRM_CM_GS__c lbcm : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c, ASI_CRM_Region__c FROM ASI_CRM_CM_GS__c
                                      WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3 )
                                      AND ASI_CRM_Region__c = :strRegion  AND ASI_CRM_TYPE__c = 'Budget CM' AND ASI_CRM_PRODUCTCODE__c IN :V0SubBrandIdSet
                                      AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0
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
        
        
        
        
        
        
        Map<Date, Decimal> v0_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c);
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
        
        //Old version
        //date strStartBGDate2 = date.newInstance(v0startdate.addYears(-2).year(), 6, 30);
        //date strEndBGDate2 = date.newInstance(v0enddate.addYears(-1).year(), 6, 30);
        
        
        Date strStartBGDate2 = Date.newInstance(v0startdate.addYears(-1).year(), 6, 30);
        Date strEndBGDate2 = Date.newInstance(v0enddate.year(), 6, 30);
        
        Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();   
        
         
        System.debug('PO Modi V0.0 CM GS strStartBGDate:'+v0startdate);
        System.debug('strEndBGDate:'+v0enddate);
        System.debug('strStartBGDate2:'+strStartBGDate2);
        System.debug(' strEndBGDate2:'+strEndBGDate2);

        
        //AND ((ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c AND ASI_CRM_Channel__c = Null   )
         //                                            OR ( ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c 
        //                                                 AND ASI_CRM_Channel__c = : thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c) )
                                                         
        for (ASI_CRM_CM_GS__c v0budgetcmtemp : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c,ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c,ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Month__c
                                                FROM ASI_CRM_CM_GS__c  WHERE ASI_CRM_PRODUCTCODE__c IN :V0SubBrandIdSet
                                                AND (ASI_CRM_Region__c = :thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c   ) 
                                                AND ((ASI_CRM_CN_Month_End_Date__c >= :v0startdate AND ASI_CRM_CN_Month_End_Date__c <= :v0enddate ) OR 
                                                     (ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate2   AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate2  AND ASI_CRM_CN_Month__c = 6 ))
                                                AND ASI_CRM_TYPE__c = 'Budget CM' AND ASI_CRM_CM_GS_per_9L__c != 0 AND ASI_CRM_CM_GS_per_9L__c != NULL
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
                    System.debug('LatestBudgetCMTotalV0: '+LatestBudgetCMTotalV0 +'+='+ v0_ROImap.get(roitemp).TotalVolume +'*'+ v0_ROImap.get(roitemp).latestBudgetCM +'*'+  v0_ROImap.get(roitemp).period);
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
        
        List<FinancialIndicator> RetuenList = new List<FinancialIndicator>();
        RetuenList.add(V0POModiContractFI);
        UpsertAttachment(thisCC.Id, System.JSON.serialize(RetuenList),'Historical Modi Data' );
    }
    
    //@description: Restructure latest PO record of the Historical V0.0 and v0.0 PO (historical PO record which its PO end date is within 6 months to the PO start date of the selected PO)
    //@param: input current Contract
    //@return
    public static void RestructureHistoricalFinancialIndicatorData(ASI_TH_CRM_Contract__c contract){
        
        Boolean isPOS = false;
        Boolean isORS = false;//Outlet Reception Scan

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
        
        //Calculate RegionSubBrandCM_Map
        String currentFY = String.valueOf(ASI_CRM_DateUtilClass.getFiscalYearEndDate(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';

        //Finding Old Promotion Types
        Set<String> oldPromotionTypes = new Set<String>{'TOT/MOT Contract'};

        
        if (thisCC.ASI_CRM_CN_PO_Start_Date__c != null && thisCC.ASI_CRM_CN_PO_End_Date__c != null && thisCC.ASI_TH_CRM_Promotion_Type__c != null){
            //Criteria within 6 Months (from PO start date)
            Integer strDays = 365/12*6;
            Date strDate = thisCC.ASI_CRM_CN_PO_Start_Date__c - strDays;
            //Retrieve Historical v0.0 contract
            
            try{ 
                PreviousCC = [SELECT Id,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,
                              ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Total_Contract_Amount__c,ASI_CRM_Volume_Option__c, ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_Contract_Estimate_Cost_Total__c, ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c,ASI_CRM_CN_Contract_Variable_Cost_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,   ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__c, Owner.Name, ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,  ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_New_FY_PO__c, ASI_CRM_CN_Status__c,ASI_CRM_CN_Expected_Display_Est_Total__c
                              FROM ASI_TH_CRM_Contract__c 
                              WHERE ASI_CRM_CN_Outlet_WS__c = :thisCC.ASI_CRM_CN_Outlet_WS__c 
                              AND ASI_CRM_CN_PO_End_Date__c != NULL
                              AND ASI_CRM_CN_PO_Start_Date__c != NULL
                              AND ASI_CRM_CN_PO_End_Date__c <= :thisCC.ASI_CRM_CN_PO_Start_Date__c  
                              AND ASI_CRM_CN_PO_End_Date__c >= :strDate 
                              AND (ASI_TH_CRM_Promotion_Type__c = :thisCC.ASI_TH_CRM_Promotion_Type__c OR ASI_TH_CRM_Promotion_Type__c IN : oldPromotionTypes)
                              AND (ASI_CRM_CN_Status__c = 'Final' OR ASI_CRM_CN_Status__c = 'Archived' OR ASI_CRM_CN_Status__c = 'Submitted') 
                              ORDER BY ASI_CRM_CN_Status__c DESC, ASI_CRM_CN_PO_End_Date__c DESC, Name DESC, ASI_CRM_CN_PO_Version__c DESC LIMIT 1];
            }catch(Exception e){
                PreviousCC = new ASI_TH_CRM_Contract__c();
            }
            
            if(PreviousCC!=null && PreviousCC.ASI_CRM_CN_Status__c == 'Archived'){
                String v0Id = PreviousCC.ASI_CRM_CN_V0_0_PO_version__c == null ? PreviousCC.Id : PreviousCC.ASI_CRM_CN_V0_0_PO_version__c;
                List<ASI_TH_CRM_Contract__c> CheckLatestContract  = new List<ASI_TH_CRM_Contract__c>([SELECT Id,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,
                                                                                                      ASI_CRM_CN_PO_Version__c,ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_Total_Contract_Amount__c,ASI_CRM_Volume_Option__c, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_Contract_Estimate_Cost_Total__c,ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c,ASI_CRM_CN_Contract_Variable_Cost_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__c, Owner.Name, ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, ASI_CRM_CN_Contract_Est_Var_Cost_Total__c, ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_New_FY_PO__c, ASI_CRM_CN_Status__c,ASI_CRM_CN_Expected_Display_Est_Total__c
                                                                                                      FROM ASI_TH_CRM_Contract__c  WHERE ASI_CRM_CN_V0_0_PO_version__c = : v0Id
                                                                                                      AND ASI_CRM_CN_Status__c != 'Draft'  AND (NOT ASI_CRM_CN_Status__c LIKE 'FY Landing Archive')
                                                                                                      AND ASI_CRM_CN_PO_End_Date__c != NULL AND ASI_CRM_CN_PO_Start_Date__c != NULL ORDER BY CreatedDate DESC LIMIT 1]);
                
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
                
                HistoricalV00Contract.POStartDate =PreviousCC.ASI_CRM_CN_PO_Start_Date__c!=null?PreviousCC.ASI_CRM_CN_PO_Start_Date__c:null;
                HistoricalV00Contract.POEndDate =PreviousCC.ASI_CRM_CN_PO_End_Date__c!=null?PreviousCC.ASI_CRM_CN_PO_End_Date__c:null;
                
                startDate = PreviousCC.ASI_CRM_CN_PO_Start_Date__c!=null?PreviousCC.ASI_CRM_CN_PO_Start_Date__c:null;
                endDate = PreviousCC.ASI_CRM_CN_PO_End_Date__c!= null?PreviousCC.ASI_CRM_CN_PO_End_Date__c : null;
                StartDateExtend= PreviousCC.ASI_CRM_CN_PO_Start_Date__c!=null? ASI_CRM_DateUtilClass.getEndOfMonth(PreviousCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1)) :null;
                EndDateExtend = PreviousCC.ASI_CRM_CN_PO_End_Date__c!=null? ASI_CRM_DateUtilClass.getEndOfMonth(PreviousCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1)):null;   
                strRegion= PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
                CommercialTeam= PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
                
                //Current Contract is V0.0
                if(PreviousCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                    HistoricalV00Contract.TradeExpenses = PreviousCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
                if(PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
                    HistoricalV00Contract.OtherExpensesTotal = PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
                if(PreviousCC.ASI_CRM_CN_No_of_Months__c != 0 &&  PreviousCC.ASI_CRM_CN_No_of_Months__c != null)
                    HistoricalV00Contract.NoOfMonths = Integer.valueOf(PreviousCC.ASI_CRM_CN_No_of_Months__c);
                
                
            }else if(PreviousCC != null && PreviousCC.ASI_CRM_CN_V0_0_PO_version__c != null){
                HistoricalV00Contract.ContractId = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.Id;
                HistoricalV00ContractId = PreviousCC.ASI_CRM_CN_V0_0_PO_version__c;
                
                HistoricalV00Contract.POStartDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null?PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c:null;
                HistoricalV00Contract.POEndDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null?PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c:null;
                
                startDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null?PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c:null;
                endDate = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null?PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c:null;
                StartDateExtend= PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null? ASI_CRM_DateUtilClass.getEndOfMonth(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c.addYears(-1)) :null;
                EndDateExtend = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null? ASI_CRM_DateUtilClass.getEndOfMonth(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c.addYears(+1)):null;   
                strRegion = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c !=null? PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c: '';
                CommercialTeam= PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?PreviousCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
                
                
                //Current Contract is VFinal
                if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                    HistoricalV00Contract.TradeExpenses = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
                if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)   
                    HistoricalV00Contract.OtherExpensesTotal = PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
                if(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != 0 &&  PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != null)
                    HistoricalV00Contract.NoOfMonths = Integer.valueOf(PreviousCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c);
            } else{
                HistoricalV00ContractId = null;
            }
            
            //Historical v0.0 BRSF Line only for By Sub-Brand
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PreviousV0CC_BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();
            
            System.debug('HistoricalV00ContractId : '+HistoricalV00ContractId);
            if(HistoricalV00ContractId != null){
                Map<Date, Decimal> PreviousV0CC_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(startDate, endDate);
                //CMTotalV0 :  Cont. Margin before A&P  
                Decimal CMTotalV0=0;
                Decimal LatestBudgetCMTotalV0 = 0;
                Decimal BRSFEstimateVolumesTotalV0 = 0; // Calculate BRSF Estimate Volumes Total for V0.0 contract
                
                
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();
                
                //<Sub-Brand Id, Estimate Volume Amount> : the Estimate Volume for each Sub-Brand Mapping
                Map<String, Decimal> EstimateVolumeV0Map =new Map<String, Decimal>();
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = getBRSFLines(HistoricalV00ContractId);
                
                
                /*
                for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c  FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :HistoricalV00ContractId])
                {
                    if (ccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                        HistoricalV00Contract.VariableExpense += ccost.ASI_CRM_CN_Estimate_Amount__c!=null?ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    }
                }
                */
                
                
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
                        Decimal V00Value = 0;
                        if (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                            V00Volumes = (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c* ContractLine.ASI_CRM_CN_No_of_Months__c);
                        }
                        V00Value = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                        //system.debug(ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c+'V00H	 Volumes: '+ContractLine.ASI_CRM_CN_No_of_Months__c);
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
                        HistoricalV00Contract.Value += V00Value;
                        
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
                            String CategoryName = getCategoryNameFromContractLine(ContractLine);
                            HistoricalV00Contract.CategoryVolumeMap = addToDecimalMap(HistoricalV00Contract.CategoryVolumeMap, CategoryName, V00Volumes);
                         	HistoricalV00Contract.CategoryValueMap = addToDecimalMap(HistoricalV00Contract.CategoryValueMap, CategoryName, V00Value);
                         	HistoricalV00Contract.CategoryGSMap = addToDecimalMap(HistoricalV00Contract.CategoryGSMap, CategoryName, 0);
                        }// end of By Brande Product Category Grouping      
                        
                        
                        if (PreviousV0CC_Period_map != null && PreviousV0CC_Period_map.size() > 0){
                            for (Date previousV0CCdate : PreviousV0CC_Period_map.keySet() ){
                                
                                Date strDateCC = ASI_CRM_DateUtilClass.getFiscalYearEndDate(previousV0CCdate);
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
                        //Build PSFLineMap
		                String LineKey;
		                Boolean isByCategory = false;
		                System.debug('ContractLine: ' + ContractLine);
		                if (ContractLine.ASI_CRM_Volume_Base__c == 'By Category'){
			                //By Category
			               	isByCategory = true;
			               	LineKey = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
			            } else {
			               	//By Sub-brand
			            	LineKey = NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//subBrandKey;//
			            } /*else {
			            	system.debug('ByTotal');
			               	LineKey = 'ByTotal';
			            } */
		                
		                if(HistoricalV00Contract.PSFLineMap.containsKey(LineKey)){
		                	ContractLine thisContractLine = HistoricalV00Contract.PSFLineMap.get(LineKey);
							thisContractLine.EstimatePSFFees += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
							thisContractLine.ContractPSFFees += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
						} else {
		                    ContractLine ContractDetail = new ContractLine ();
		                    ContractDetail.EstimatePSFFees = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
							ContractDetail.ContractPSFFees = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
								 
		                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
		                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
		                    if (isByCategory){
		                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
		                    } else {
		                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
		                    }
		                    
		                    HistoricalV00Contract.PSFLineMap.put(LineKey,ContractDetail);
		                }
                    }
                    //Estimate contract cost total 
                    Decimal cost;
	                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
	                	cost = ContractLine.ASI_CRM_CN_Est_Total__c != null ? ContractLine.ASI_CRM_CN_Est_Total__c : 0;
	                }else{
	                	cost = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
	                }
	                HistoricalV00Contract.TradeExpenses += cost;
	                if (ContractLine.ASI_CRM_Type__c == 'PSF'){
	                    HistoricalV00Contract.PSFExpensesTotal += cost;
	                } else if (ContractLine.ASI_CRM_Type__c == 'Display'){
	                   	HistoricalV00Contract.DisplayExpensesTotal += cost;
	                }
                }//end of Looping the Contract Line
                
                
                
                Map<String,Decimal> CR12FactorMap = GenerateCR12FactorMap(V00SubBrandIdSet, CommercialTeam, strRegion);
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine :BRSFList){
                    if (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                        Decimal CR12Factor=1;
                        if(CR12FactorMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                            CR12Factor=CR12FactorMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        }//system.debug(' NOW h :'+ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c +'*'+ CR12Factor +'*'+ ContractLine.ASI_CRM_CN_No_of_Months__c);
                        HistoricalV00Contract.IntakeCR12 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                    }
                }
                
                
                Date StartDateExtend2 = Date.newInstance(StartDateExtend.addYears(-1).year(), 6, 30);
                Date EndDateExtend2 = Date.newInstance(EndDateExtend.year(), 6, 30);
                
                //Getting GM/GS Data
                
                System.debug(' HistoricalV00Contract Now currentFY : '+currentFY);
                System.debug('Now currentFY2 : '+currentFY2);
                
                Map<String, String> subBrandCategoryMap = new Map<String, String>();
                for (ASI_CRM_CM_GS__c lbcm : [SELECT Id,
													ASI_CRM_CM_GS_per_9L__c, 
													ASI_CRM_PRODUCTCODE__c, 
													ASI_CRM_PRODUCTCODE__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c,
													ASI_CRM_Region__c 
												FROM ASI_CRM_CM_GS__c
                                              WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3) AND
                                              ASI_CRM_Region__c = :strRegion  AND ASI_CRM_TYPE__c = 'Budget CM'
                                              AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
                {// and ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet 
                    String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
                    Decimal cm=0.0;
                    if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                        cm = lbcm.ASI_CRM_CM_GS_per_9L__c; 
                    }
                    if (!RegionSubBrandCM_Map.containsKey(ProductCode)){
                        RegionSubBrandCM_Map.put(ProductCode,cm) ; 
                        subBrandCategoryMap.put(ProductCode, lbcm.ASI_CRM_PRODUCTCODE__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c);
                    }
                }
                
                
                Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();   
                System.debug('historicalV0_sbDataROI_map StartDateExtend:'+StartDateExtend);
                System.debug('EndDateExtend:'+EndDateExtend);
                System.debug('StartDateExtend2:'+StartDateExtend2);
                System.debug('EndDateExtend2:'+EndDateExtend2);
                System.debug('strRegion:'+strRegion);
                for (ASI_CRM_CM_GS__c line : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Month__c FROM ASI_CRM_CM_GS__c
                                              WHERE ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet   AND ASI_CRM_Region__c = :strRegion AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS') 
                                              AND ( (ASI_CRM_CN_Month_End_Date__c >= :StartDateExtend AND ASI_CRM_CN_Month_End_Date__c <= :EndDateExtend )
                                                   OR (ASI_CRM_CN_Month_End_Date__c >= :StartDateExtend2   AND ASI_CRM_CN_Month_End_Date__c <= :EndDateExtend2 
                                                       AND ASI_CRM_CN_Month__c = 6  ) )  
                                              AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
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
                            System.debug(' CM to replace null value with latest CMGS data');
                        }
                        
                        if((historicalV0_sbDataROI_map.get(key).GS == null || historicalV0_sbDataROI_map.get(key).GS == 0) && cmgsMap.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget GS')){
                            ASI_CRM_CM_GS__c cmgs = cmgsMap.get(historicalV0_sbDataROI_map.get(key).SubBrandId + 'Budget GS');
                            historicalV0_sbDataROI_map.get(key).GS = cmgs.ASI_CRM_CM_GS_per_9L__c;
                            //HistoricalV00Contract.CMId+=cmgs.Id+';';
                            System.debug(' GS to replace null value with latest CMGS data');
                        }
                        
                        if(historicalV0_sbDataROI_map.get(key).latestBudgetCM == null || historicalV0_sbDataROI_map.get(key).latestBudgetCM == 0){
                            if(RegionSubBrandCM_Map.containsKey(historicalV0_sbDataROI_map.get(key).SubBrandId)){
                                historicalV0_sbDataROI_map.get(key).latestBudgetCM = RegionSubBrandCM_Map.get(historicalV0_sbDataROI_map.get(key).SubBrandId);
                                System.debug('latestBudgetCM  to replace null value with latest CMGS data');
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
                    	subbrand_data subBrandData = historicalV0_sbDataROI_map.get(key);
            			String categoryName =  subBrandCategoryMap.get(subBrandData.SubBrandId);

                        PeriodStr= null;
                        if (subBrandData.period != null){
                            PeriodStr = subBrandData.period;
                        }
                        //Budget CM
                        ActualCM = null;
                        if (subBrandData.CM != null){
                            ActualCM = subBrandData.CM;
                        }
                        // Latest Budget CM
                        LatestBudgetCM = null;
                        if (subBrandData.latestBudgetCM != null){
                            LatestBudgetCM = subBrandData.latestBudgetCM;
                        }
                        //Budget GS
                        ActualGS = null;
                        if (subBrandData.GS != null){
                            ActualGS = subBrandData.GS;
                        }
                        TotalEstimateVol = null;
                        if (EstimateVolumeV0Map != null && subBrandData != null && subBrandData.SubBrandId != null && EstimateVolumeV0Map.containsKey(subBrandData.SubBrandId)){
                            TotalEstimateVol = EstimateVolumeV0Map.get(subBrandData.SubBrandId);
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
                        	Decimal GSSubTotal = ActualGS * TotalEstimateVol * PeriodStr;
                            HistoricalV00Contract.GrossSalesTotal += GSSubTotal;
                            if (categoryName != null)
                            	HistoricalV00Contract.CategoryGSMap = addToDecimalMap(HistoricalV00Contract.CategoryGSMap, categoryName, GSSubTotal);
                        }
                    }
                }// end of historicalV0_sbDataROI_map Looping 
                
                //**************************Calculation**************************
                
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
                HistoricalVFinalContract.OtherExpensesTotal = PreviousCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
            }
                
            HistoricalVFinalContract.ContractId = PreviousCC.Id;
            HistoricalVFinalContract.POStartDate = PreviousCC.ASI_CRM_CN_PO_Start_Date__c;
            HistoricalVFinalContract.POEndDate= PreviousCC.ASI_CRM_CN_PO_End_Date__c;
            
            HistoricalVFinalContract.ContractLineMap = new Map<String,ContractLine>();
            HistoricalVFinalContract.OtherExpensesMap = new Map<String,ContractLine>();
            Decimal TotalHC_VolumeBtl =0; // total historical contract Volume BTL
            Decimal TotalHC_IntakeBtl =0; 
            Decimal PSFEstTotal=0;

            Decimal TotalHistorical_MartellIntakeBtl =0;  // total historical contract Martel Intake Btl
            
            for (ASI_CRM_Contract_Cost__c pccost : [SELECT Id,Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Activity_Code__r.Name,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c, 
                                                    ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c 
                                                    FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :PreviousCC.Id])
            {
                if (pccost.ASI_CRM_CN_Cost_Type__c == 'Fixed' && pccost.ASI_CRM_CN_Estimate_Amount__c != null ){
                    if (HistoricalVFinalContract.OtherExpensesMap.containsKey(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c)){
                        HistoricalVFinalContract.OtherExpensesMap.get(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c).HistoricalFees += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    }else{
                        ContractLine ContractDetail = new ContractLine ();
                        ContractDetail.HistoricalFees=pccost.ASI_CRM_CN_Estimate_Amount__c;
                        HistoricalVFinalContract.OtherExpensesMap.put(pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c, ContractDetail);
                    }
                }
                HistoricalVFinalContract.TradeExpenses+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
            }
            
            
            
            
            Set<String> PSFMethodologySetVFinal = new Set<String>();
            Set<String> PSFVolumeBaseSetVFinal = new Set<String>();
            
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : getBRSFLines(PreviousCC.Id)){
                
                if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){
                    
                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                        HistoricalVFinalContract.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                        isPOS = (ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c == 'POS');
                    }
                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null){
                        isORS = (ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c == 'Outlet Reception Scan');
                    }
                    
                    String LineKey=NameSortingASC(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//ContractLineSBGradeName; //NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) +subBrandKey;//
                    
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

                
                if (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Module__c!=null){
                    if(!PSFMethodologySetVFinal.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                        PSFMethodologySetVFinal.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                        HistoricalVFinalContract.PSFMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                    }
                    if(!PSFVolumeBaseSetVFinal.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                        PSFVolumeBaseSetVFinal.add(ContractLine.ASI_CRM_Volume_Base__c);
                        HistoricalVFinalContract.PSFVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                    }
                    //Build PSFLineMap
	                String LineKey;
	                Boolean isByCategory = false;
	                System.debug('ContractLine: ' + ContractLine);
					if (ContractLine.ASI_CRM_Volume_Base__c == 'By Category'){
		                //By Category
		               	isByCategory = true;
		               	LineKey = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
		            } else {
		               	//By Sub-brand
		            	LineKey = NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//subBrandKey;//
		            } /*else {
		            	system.debug('ByTotal');
		               	LineKey = 'ByTotal';
		            } */
	                
	                if(HistoricalVFinalContract.PSFLineMap.containsKey(LineKey)){
	                	ContractLine thisContractLine = HistoricalVFinalContract.PSFLineMap.get(LineKey);
						thisContractLine.EstimatePSFFees += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
						thisContractLine.ContractPSFFees += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
					} else {
	                    ContractLine ContractDetail = new ContractLine ();
	                    ContractDetail.EstimatePSFFees = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
						ContractDetail.ContractPSFFees = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
							 
	                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
	                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
	                    if (isByCategory){
	                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
	                    } else {
	                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
	                    }
	                    
	                    HistoricalVFinalContract.PSFLineMap.put(LineKey,ContractDetail);
	                }
                }
                
                Decimal cost;
	            if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
	              	cost = ContractLine.ASI_CRM_CN_Est_Total__c != null ? ContractLine.ASI_CRM_CN_Est_Total__c : 0;
	            }else{
	               	cost = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
	            }
	            HistoricalVFinalContract.TradeExpenses += cost;
	            if (ContractLine.ASI_CRM_Type__c == 'PSF'){
	                HistoricalVFinalContract.PSFExpensesTotal += cost;
	            } else if (ContractLine.ASI_CRM_Type__c == 'Display'){
	               	HistoricalVFinalContract.DisplayExpensesTotal += cost;
	            }
            }
            
            //V0.1+ PO will calculate BRSF + PSF VEC part amount
            if (PreviousCC.ASI_CRM_CN_PO_Version__c != '0.0' && PreviousCC.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract') {
                HistoricalVFinalContract.TradeExpenses = PreviousCC.ASI_CRM_CN_Total_Contract_Amount__c;

                HistoricalVFinalContract.PSFExpensesTotal = PreviousCC.ASI_CRM_CN_Expected_PSF_Est_Total__c != null? PreviousCC.ASI_CRM_CN_Expected_PSF_Est_Total__c : 0;
                HistoricalVFinalContract.DisplayExpensesTotal = PreviousCC.ASI_CRM_CN_Expected_Display_Est_Total__c != null? PreviousCC.ASI_CRM_CN_Expected_Display_Est_Total__c : 0;
            }
            AdditionalFIMap.put('PSFEstTotal',PSFEstTotal);

            
            Set<Id> HistoricalVFinalSBIdSet = new Set<Id> ();         
            Date CutOffDay = ASI_CRM_DateUtilClass.getCutOffDate();
            Date TillEnd;
            if (CutOffDay >= PreviousCC.ASI_CRM_CN_PO_End_Date__c)
                TillEnd = ASI_CRM_DateUtilClass.getEndOfMonth(PreviousCC.ASI_CRM_CN_PO_End_Date__c);
            else
                TillEnd = CutOffDay; 
            
            Integer PeriodA = ASI_CRM_DateUtilClass.monthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
            Integer PeriodB = ASI_CRM_DateUtilClass.monthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, PreviousCC.ASI_CRM_CN_PO_End_Date__c);
            
            Decimal TotalHCVolumeBtl=0;
            Map<Date, Decimal> HistoricalVFinal_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, PreviousCC.ASI_CRM_CN_PO_End_Date__c);
            System.debug('PeriodA 0.1: '+PeriodA);
            System.debug('PeriodB 0.1: '+PeriodB);
            System.debug('PreviousCC PreviousCC.ASI_CRM_CN_PO_Start_Date__c : '+PreviousCC.ASI_CRM_CN_PO_Start_Date__c );
            System.debug('PreviousCC TillEnd 0.1: '+TillEnd);
            
            HistoricalVFinalContract.DebugMap.put('HistoricalVFTillEnd',String.valueOf(TillEnd));
            Map <String, subbrand_data> historical_sbDataROI_map = new Map <String, subbrand_data> ();
            /*
            List<ASI_CRM_Subbrand_Volume__c> HistoricalSBVolumeList = new List<ASI_CRM_Subbrand_Volume__c>(); 
            if (HistoricalAllOutlet.size() >= outletThreshold()){
	        	HistoricalSBVolumeList = [SELECT id, Name,ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                                                                       ASI_CRM_DeductCapWithIssue_StdBill__c,ASI_CRM_Grey_Cap_Std_Billing__c,ASI_CRM_Black_Cap_Std_Billing__c,ASI_CRM_Green_Cap_Std_Billing__c,ASI_CRM_Offtake__c,ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c,
                                                                       ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Offtake_CR12__c, ASI_CRM_Subbrand__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c, ASI_CRM_Subbrand__r.Name,  ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_T2_Depletion_BTL__c,ASI_CRM_T1_Depletion__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c, ASI_CRM_T2_Depletion__c, ASI_CRM_PR_Direct__c, ASI_CRM_PR_Direct_Btl__c,ASI_CRM_End_Date__c ,ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,
                                                                       ASI_CRM_PR_Direct_STD__c,ASI_CRM_Black_Cap_Btl__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_DeductibleCapWithIssues_Std_Btl__c,ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c
                                                                       FROM ASI_CRM_Subbrand_Volume__c 
                                                                       WHERE ASI_CRM_CN_Competitor_Sub_brand__c != true 
                                                                       AND ASI_CRM_Subbrand__c !=null 
                                                                       AND ASI_CRM_End_Date__c >= :PreviousCC.ASI_CRM_CN_PO_Start_Date__c 
                                                                       AND ASI_CRM_End_Date__c <= :TillEnd 
                                                                       AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
				                                                       AND ASI_CRM_CN_Contract__c = :PreviousCC.Id 
				                                                       AND recordtypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')];
	        	
	        } else {
	        	HistoricalSBVolumeList = [SELECT id, Name,ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                                                                       ASI_CRM_DeductCapWithIssue_StdBill__c,ASI_CRM_Grey_Cap_Std_Billing__c,ASI_CRM_Black_Cap_Std_Billing__c,ASI_CRM_Green_Cap_Std_Billing__c,ASI_CRM_Offtake__c,ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c,
                                                                       ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Offtake_CR12__c, ASI_CRM_Subbrand__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c, ASI_CRM_Subbrand__r.Name,  ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_T2_Depletion_BTL__c,ASI_CRM_T1_Depletion__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c, ASI_CRM_T2_Depletion__c, ASI_CRM_PR_Direct__c, ASI_CRM_PR_Direct_Btl__c,ASI_CRM_End_Date__c ,ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,
                                                                       ASI_CRM_PR_Direct_STD__c,ASI_CRM_Black_Cap_Btl__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_DeductibleCapWithIssues_Std_Btl__c,ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c
                                                                       FROM ASI_CRM_Subbrand_Volume__c 
                                                                       WHERE ASI_CRM_Account__c IN :HistoricalAllOutlet 
                                                                       AND ASI_CRM_CN_Competitor_Sub_brand__c != true 
                                                                       AND ASI_CRM_Subbrand__c !=null 
                                                                       AND ASI_CRM_End_Date__c >= :PreviousCC.ASI_CRM_CN_PO_Start_Date__c 
                                                                       AND ASI_CRM_End_Date__c <= :TillEnd 
		                                                               AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
			                                                           AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION];
	                                                         
	        }*/
	        List<ASI_CRM_Subbrand_Volume__c> HistoricalSBVolumeList = new List<ASI_CRM_Subbrand_Volume__c>();
	        String historicalSBVolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
	        historicalSBVolumeQuery += 'WHERE ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
	                               'AND ASI_CRM_Subbrand__c != null ' + 
	                               'AND ASI_CRM_End_Date__c >= ' + String.valueOf(PreviousCC.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
	                               'AND ASI_CRM_End_Date__c <= :TillEnd ' +
	                               'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE ';
	        
	        if (HistoricalAllOutlet.size() >= outletThreshold()){
	        	historicalSBVolumeQuery += 'AND ASI_CRM_CN_Contract__c = \'' + PreviousCC.Id + '\' ' +
	        							'AND recordtypeId = \'' + Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')+'\' ';
	            
	        	
	        } else {
	        	historicalSBVolumeQuery += 'AND ASI_CRM_Account__c IN :HistoricalAllOutlet ' +
	        							'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';
	                                                         
	        }
	        System.debug(historicalSBVolumeQuery);
	        HistoricalSBVolumeList = Database.query(historicalSBVolumeQuery);
            
            
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
            
            Decimal Total_IntakeBtl_prorate=0;
            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume: HistoricalSBVolumeList){
                System.debug(SubBrandVolume.Id+ 'HistoricalVFinalSBIdSet SubBrandVolume:'+SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c);
                
                HistoricalVFinalSBIdSet.add(SubBrandVolume.ASI_CRM_Subbrand__c);
                //Calculate Volume 
                Decimal Volumes = 0;
                if(isORS){
                    System.debug(LoggingLevel.INFO, '*** Volumes: ' + Volumes);
                    Volumes = denullify(SubBrandVolume.ASI_CRM_Green_ORS_9L__c,0) + denullify(SubBrandVolume.ASI_CRM_Empty_Bottle__c,0);
                }else{
                    Volumes += SubBrandVolume.ASI_CRM_T1_Depletion__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion__c:0;
                    Volumes += SubBrandVolume.ASI_CRM_T2_Depletion__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion__c:0;
                    Volumes += SubBrandVolume.ASI_CRM_PR_Direct__c!=null? SubBrandVolume.ASI_CRM_PR_Direct__c:0;
                }
                
                //Intake
                Decimal VolumeBtl=0;
                if(isORS){
                    VolumeBtl = denullify(SubBrandVolume.ASI_CRM_Green_ORS_Std_Btl__c,0) + denullify(SubBrandVolume.ASI_CRM_Empty_Bottle_Std_Btl__c,0);
                }else{
                    VolumeBtl += SubBrandVolume.ASI_CRM_T1_Depletion_STD__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion_STD__c:0;
                    VolumeBtl += SubBrandVolume.ASI_CRM_T2_Depletion_STD__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion_STD__c:0;
                    VolumeBtl += SubBrandVolume.ASI_CRM_PR_Direct_STD__c!=null? SubBrandVolume.ASI_CRM_PR_Direct_STD__c:0;
                }
                TotalHC_IntakeBtl+=VolumeBtl;
                
                Decimal Value = 0;
                if (isPOS) {
                    Value = denullify(SubBrandVolume.ASI_CRM_POS_GS__c, 0);
                } else if (isORS) {
                    Value = denullify(SubBrandVolume.ASI_CRM_Green_ORS_GS__c, 0) + denullify(SubBrandVolume.ASI_CRM_Empty_Bottle_GS__c,0);
                } else {
                    Value = denullify(SubBrandVolume.ASI_CRM_CN_Intake_GS_T1_price__c, 0);
                }

                if( ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c) ){
                    TotalHistorical_MartellIntakeBtl+=VolumeBtl;
                }
                
                Decimal VarHistTotal = VolumeBtl;
                Decimal VarHistTotalVolume=Volumes;
                Decimal VariableHistoricalBottles = VolumeBtl/PeriodA;
                
                if (PeriodA != 0 && PeriodA != null && PeriodB != 0 && PeriodB != null){
                    Volumes = Volumes/PeriodA * PeriodB;
                    VolumeBtl = VolumeBtl/PeriodA * PeriodB;
                    Value = Value/PeriodA * PeriodB;
                }
                
                
                Total_IntakeBtl_prorate+=VolumeBtl;
                TotalHC_VolumeBtl += VolumeBtl;
                // Historical VFinal Contract Volume (in 9L cs) INTAKE (Historical Contract vFinal)
                HistoricalVFinalContract.Volumes += Volumes; 
                HistoricalVFinalContract.Value += Value;
                //Sub-Brand Grade Grouping
                String SubbrandGroupName='0. Not Specified';
                String SubBrandName='';
                if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null ){
                    SubbrandGroupName=SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c!=null?SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c:SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                }
                
                HistoricalVFinalContract.SubBrandGradeGrouping = addToDecimalMap(HistoricalVFinalContract.SubBrandGradeGrouping, SubBrandName, Volumes);
                HistoricalVFinalContract.SubBrandGradeMap = addToDecimalMap(HistoricalVFinalContract.SubBrandGradeMap, SubbrandGroupName, Volumes);
                
                
                //By Brand Product Category Grouping  
                if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c !=null && SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                    String CategoryName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
                    HistoricalVFinalContract.CategoryVolumeMap = addToDecimalMap(HistoricalVFinalContract.CategoryVolumeMap, CategoryName, Volumes);
                }// end of By Brand Product Category Grouping      
                
                
                Date SubbrandVolumeDateKey = ASI_CRM_DateUtilClass.getFiscalYearEndDate(SubBrandVolume.ASI_CRM_End_Date__c);
                String SubbrandVolumeStrKey = String.valueOf(SubbrandVolumeDateKey) + SubBrandVolume.ASI_CRM_Subbrand__c;
                
                if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(SubbrandVolumeStrKey)){
                    historical_sbDataROI_map.get(SubbrandVolumeStrKey).TotalVolume += VarHistTotalVolume;
                }
                
                String subBrandKey =NameSortingASC(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + SubBrandVolume.ASI_CRM_Subbrand__r.Name; 
                
                if(HistoricalVFinalContract.ContractLineMap.containsKey(subBrandKey)){
                    HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalBottles =HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalBottles + VariableHistoricalBottles ;
                    HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalTotalFees +=  HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalFees * VarHistTotal;
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.HistoricalBottles = VariableHistoricalBottles;
                    //ContractDetail.HistoricalTotalFees=0;
                    ContractDetail.SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.Name;
                    ContractDetail.SubBrandGrade= SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    HistoricalVFinalContract.ContractLineMap.put(subBrandKey,ContractDetail);
                }
                
                Decimal VolumesCR12 = 0; 
                if(isORS){
                    VolumesCR12 = denullify(SubBrandVolume.ASI_CRM_Green_ORS_CR12__c,0) + denullify(SubBrandVolume.ASI_CRM_Empty_Bottle_CR12__c,0);
                }else{
                    VolumesCR12 += SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c:0;
                    VolumesCR12 += SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c:0;
                    VolumesCR12 += SubBrandVolume.ASI_CRM_PR_Direct_CR12__c!=null? SubBrandVolume.ASI_CRM_PR_Direct_CR12__c:0;
                }
                System.debug(LoggingLevel.INFO, '*** VolumesCR12: ' + VolumesCR12);
                HistoricalVFinalContract.IntakeCR12 += VolumesCR12;
                
            }//end of Sub Brand Volume for looping
             
            AdditionalFIMap.put('Total_IntakeBtl_prorate',Total_IntakeBtl_prorate); 
            
            //Prorate Investment CR12 for Historical Contract
            if (PeriodA != 0 && PeriodB!= 0 && PeriodA != null && PeriodB!= null){
                HistoricalVFinalContract.IntakeCR12 = HistoricalVFinalContract.IntakeCR12/PeriodA * PeriodB;
            }
            
            
            
            //YTD CM/GS
            Map<String, Decimal> Latest_ActualCM = new Map<String, Decimal>();
            Map<String, Decimal> Latest_ActualGS = new Map<String, Decimal>();
            Map<String, Decimal> ProForma_LatestBudgetCM = new Map<String, Decimal>();
            Date HistoricalVFinalStartDate = PreviousCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
            
            System.debug('HistoricalVFinalStartDate : '+HistoricalVFinalStartDate);
            System.debug('HistoricalVFinalStartDate TillEnd : '+TillEnd);
            
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
                            ProForma_LatestBudgetCM.put(line.ASI_CRM_PRODUCTCODE__c,RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c));// system.debug(line.ASI_CRM_PRODUCTCODE__c+'Debug7.1:'+RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c));
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
                         System.debug('LatestBudgetCM Found :  '+line.ASI_CRM_PRODUCTCODE__c);
                        if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                            historical_sbDataROI_map.get(strkey).latestBudgetCM = RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c);
                        }
                    }
                    historical_sbDataROI_map.get(strkey).SubBrandId = line.ASI_CRM_PRODUCTCODE__c;
                }
                
                if(!ProForma_LatestBudgetCM.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                      System.debug('HVFinal ENTER '+line.ASI_CRM_PRODUCTCODE__c);
                    if ( RegionSubBrandCM_Map.containsKey(line.ASI_CRM_PRODUCTCODE__c)){
                        ProForma_LatestBudgetCM.put(line.ASI_CRM_PRODUCTCODE__c,RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c));
                        System.debug('HVFinal '+line.ASI_CRM_PRODUCTCODE__c);
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
                
                if (PreviousCC.ASI_CRM_CN_PO_End_Date__c != null && CutOffDay >= PreviousCC.ASI_CRM_CN_PO_End_Date__c)
                    historicalVFinalTillEnd = ASI_CRM_DateUtilClass.getEndOfMonth(PreviousCC.ASI_CRM_CN_PO_End_Date__c);
                else
                    historicalVFinalTillEnd = CutOffDay;
                
                Integer PeriodA_prorate = ASI_CRM_DateUtilClass.monthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, historicalVFinalTillEnd);
                Integer PeriodB_prorate = ASI_CRM_DateUtilClass.monthDiff(PreviousCC.ASI_CRM_CN_PO_Start_Date__c, PreviousCC.ASI_CRM_CN_PO_End_Date__c);
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
                    System.debug('ActualGS:'+ActualGS);
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
                        HistoricalVFinalContract.GrossSalesTotal += ActualGS * TotalActualVol;//
                        System.debug('New Historical Gross Sales: ' + historical_sbDataROI_map.get(key).SubBrandId + ' ' + ActualGS + ' * ' + TotalActualVol );
                    }
                    ActualGS_prorate = 0;
                    if (Latest_ActualGS != null && Latest_ActualGS.containsKey(historical_sbDataROI_map.get(key).SubBrandId)){
                        ActualGS_prorate = Latest_ActualGS.get(historical_sbDataROI_map.get(key).SubBrandId);
                    }   
                    if (PeriodA_prorate != null && PeriodA_prorate != 0 && TotalActualVol != null && TotalActualVol != 0 && PeriodD_prorate != null && ActualGS_prorate != null){
                        HistoricalVFinalContract.GrossSalesTotal  += ActualGS_prorate * TotalActualVol / PeriodA_prorate * PeriodD_prorate;
                    }
                    
                } // end of looping historical_sbDataROI_map
                
            }
            System.debug(CMTotalVFinal+'Laputa system.debug latestBudgetCMTotal.strA '+LatestBudgetCMTotalVFinal);
            //Historical V Final Calculation
            
            //%Gross Sales Historical
            if (HistoricalVFinalContract.GrossSalesTotal != null && HistoricalVFinalContract.GrossSalesTotal != 0 && HistoricalVFinalContract.TradeExpenses != 0 && HistoricalVFinalContract.TradeExpenses!= null){
                HistoricalVFinalContract.GrossSalesRate = (HistoricalVFinalContract.TradeExpenses/ HistoricalVFinalContract.GrossSalesTotal) *100;
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
            
            AdditionalFIMap.put('TotalHistorical_MartellIntakeBtl',TotalHistorical_MartellIntakeBtl); 
            AdditionalFIMap.put('TotalHC_IntakeBtl',TotalHC_IntakeBtl); 
        }
        
        HistoricalVFinalContract.AddOnString = System.JSON.serialize(AdditionalFIMap);
        
        List<FinancialIndicator> FinancialIndicatorList = new List<FinancialIndicator>();
        FinancialIndicatorList.add(HistoricalV00Contract);
        FinancialIndicatorList.add(HistoricalVFinalContract);
        
        UpsertAttachment(thisCC.Id, System.JSON.serialize(FinancialIndicatorList),'Historical Data' );
        
    } // end of RestructureHistoricalData
    
    
    
    
    
    
    //Restructure Current v0 and VFinal Data
    public static void RestructureCurrentFIData(ASI_TH_CRM_Contract__c contract){
        //Get Current PO data
        ASI_TH_CRM_Contract__c thisCC = [SELECT Id, Name, Owner.Name,
        										ASI_CRM_CN_BRSF_Contract_Total__c,
												ASI_CRM_CN_Bottle_Collection_Rate__c,
												ASI_CRM_CN_Budget_LE__c,
												ASI_CRM_CN_Contract_Cost_Total__c,
												ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
												ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
												ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
												ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
												ASI_CRM_CN_Contract_Variable_Cost_Total__c,
												ASI_CRM_CN_Description__c,
												ASI_CRM_CN_Expected_BRSF_Est_Total__c,
												ASI_CRM_CN_Expected_PSF_Est_Total__c,
												ASI_CRM_CN_Last_PO_version__c,
												ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
												ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
												ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
												ASI_CRM_CN_No_of_Months__c,
												ASI_CRM_CN_Outlet_WS__c,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
												ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,
												ASI_CRM_CN_Outlet_WS__r.ASI_TH_CRM_OutletType__c,
												ASI_CRM_CN_Outlet_WS__r.Name,
												ASI_CRM_CN_PO_End_Date__c,
												ASI_CRM_CN_PO_Modification__c,
												ASI_CRM_CN_PO_No__c,
												ASI_CRM_CN_PO_Start_Date__c,
												ASI_CRM_CN_PO_Version__c,
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
												ASI_CRM_CN_Vol_Budget_LE__c,
												ASI_CRM_EVC_Cost_Estimate_Total__c,
												ASI_CRM_New_FY_PO__c,
												ASI_CRM_PO_Channel__c,
												ASI_CRM_PO_Channel__r.Name,
												ASI_CRM_PO_City__c,
												ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c,
												ASI_CRM_PO_City__r.Name,
												ASI_CRM_PO_Province__c,
												ASI_CRM_PO_Province__r.Name,
												ASI_CRM_Volume_Option__c,
												ASI_TH_CRM_Promotion_Type__c
										FROM ASI_TH_CRM_Contract__c 
                                        WHERE Id = :contract.Id];
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
        String currentFY = String.valueOf(ASI_CRM_DateUtilClass.getFiscalYearEndDate(Date.today()).year());
        String currentFY2 = (Integer.valueOf(currentFY) - 1) + '';
        String currentFY3 = (Integer.valueOf(currentFY) - 2) + '';
        

        
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
                
                HistoricalV00Contract.POStartDate =thisCC.ASI_CRM_CN_PO_Start_Date__c!=null?thisCC.ASI_CRM_CN_PO_Start_Date__c:null;
                HistoricalV00Contract.POEndDate =thisCC.ASI_CRM_CN_PO_End_Date__c!=null?thisCC.ASI_CRM_CN_PO_End_Date__c:null;
                
                startDate = thisCC.ASI_CRM_CN_PO_Start_Date__c!=null?thisCC.ASI_CRM_CN_PO_Start_Date__c:null;
                endDate = thisCC.ASI_CRM_CN_PO_End_Date__c!= null?thisCC.ASI_CRM_CN_PO_End_Date__c : null;
                StartDateExtend= thisCC.ASI_CRM_CN_PO_Start_Date__c!=null? ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_Start_Date__c.addYears(-1)) :null;
                EndDateExtend = thisCC.ASI_CRM_CN_PO_End_Date__c!=null? ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_End_Date__c.addYears(+1)):null;   
                strRegion= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
                CommercialTeam= thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
                
                //Current Contract is V0.0
                if(thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                    HistoricalV00Contract.TradeExpenses = thisCC.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
                if(thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
                    HistoricalV00Contract.OtherExpensesTotal = thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
                if(thisCC.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_No_of_Months__c != null)
                    HistoricalV00Contract.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_No_of_Months__c);
                
                
            }else if(thisCC != null && thisCC.ASI_CRM_CN_V0_0_PO_version__c != null){
                HistoricalV00Contract.ContractId = thisCC.ASI_CRM_CN_V0_0_PO_version__r.Id;
                HistoricalV00ContractId = thisCC.ASI_CRM_CN_V0_0_PO_version__c;
                
                HistoricalV00Contract.POStartDate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null?thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c:null;
                HistoricalV00Contract.POEndDate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null?thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c:null;
                
                startDate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null?thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c:null;
                endDate = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null?thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c:null;
                StartDateExtend= thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c!=null? ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c.addYears(-1)) :null;
                EndDateExtend = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c!=null? ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c.addYears(+1)):null;  
                
                strRegion = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c !=null? thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c: '';
                CommercialTeam= thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?thisCC.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
                
                
                //Current Contract is VFinal
                if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c != null)
                    HistoricalV00Contract.TradeExpenses = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Estimate_Cost_Total__c;
                if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != 0 &&  thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)   
                    HistoricalV00Contract.OtherExpensesTotal = thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
                if(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != 0 &&  thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c != null)
                    HistoricalV00Contract.NoOfMonths = Integer.valueOf(thisCC.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c);
            } else{
                HistoricalV00ContractId = null;
            }
            
            //Historical v0.0 BRSF Line only for By Sub-Brand
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PreviousV0CC_BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();
            
            
            if(HistoricalV00ContractId != null){
                Map<Date, Decimal> PreviousV0CC_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(startDate, endDate);
                //CMTotalV0 :  Cont. Margin before A&P  
                Decimal CMTotalV0=0;
                Decimal LatestBudgetCMTotalV0 = 0;
                Decimal BRSFEstimateVolumesTotalV0 = 0; // Calculate BRSF Estimate Volumes Total for V0.0 contract
                
                
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();
                
                //<Sub-Brand Id, Estimate Volume Amount> : the Estimate Volume for each Sub-Brand Mapping
                Map<String, Decimal> EstimateVolumeV0Map =new Map<String, Decimal>();
                
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = getBRSFLines(HistoricalV00ContractId);
                
                
                /*
                for (ASI_CRM_Contract_Cost__c  ccost : [SELECT Name, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c  FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :HistoricalV00ContractId])
                {
                	
                    if (ccost.ASI_CRM_CN_Cost_Type__c == 'Variable'){
                        HistoricalV00Contract.VariableExpense += ccost.ASI_CRM_CN_Estimate_Amount__c!=null?ccost.ASI_CRM_CN_Estimate_Amount__c:0;
                    }
                }
                */
                
                Set<String> PSFMethodologySet = new  Set<String>();
                Set<String> PSFVolumeBaseSet= new  Set<String>();
                //Looping the Contract Line
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : ContractLineList){       //By Sub-Brand
                    //if(ContractLine.ASI_CRM_CN_Sub_Brand__c!=null){
                    if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null )
                    {
                        
                        V00SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        Decimal V00Volumes = 0;
                        Decimal V00Values = 0;
                        if (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c != null && ContractLine.ASI_CRM_CN_No_of_Months__c != null){
                            V00Volumes = (ContractLine.ASI_CRM_CN_Estimate_Volume_9L_Month__c* ContractLine.ASI_CRM_CN_No_of_Months__c);
                        }
                        V00Values = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
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
                        HistoricalV00Contract.Value += V00Values;
                        
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
                            String CategoryName = getCategoryNameFromContractLine(ContractLine);
                            HistoricalV00Contract.CategoryVolumeMap = addToDecimalMap(HistoricalV00Contract.CategoryVolumeMap, CategoryName, V00Volumes);
                            HistoricalV00Contract.CategoryValueMap = addToDecimalMap(HistoricalV00Contract.CategoryValueMap, CategoryName, V00Values);
                            HistoricalV00Contract.CategoryGSMap = addToDecimalMap(HistoricalV00Contract.CategoryGSMap, CategoryName, 0);
                        }// end of By Brande Product Category Grouping      
                        
                        
                        if (PreviousV0CC_Period_map != null && PreviousV0CC_Period_map.size() > 0){
                            for (Date previousV0CCdate : PreviousV0CC_Period_map.keySet() ){
                                
                                Date strDateCC = ASI_CRM_DateUtilClass.getFiscalYearEndDate(previousV0CCdate);
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
                        //Build PSFLineMap
		                String LineKey;
		                Boolean isByCategory = false;
		                System.debug('ContractLine: ' + ContractLine);
		                if (ContractLine.ASI_CRM_Volume_Base__c == 'By Category'){
			                //By Category
			               	isByCategory = true;
			               	LineKey = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
			            } else {
			               	//By Sub-brand
			            	LineKey = NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//subBrandKey;//
			            } /*else {
			            	system.debug('ByTotal');
			               	LineKey = 'ByTotal';
			            } */
		                
		                if(HistoricalV00Contract.PSFLineMap.containsKey(LineKey)){
		                	ContractLine thisContractLine = HistoricalV00Contract.PSFLineMap.get(LineKey);
							thisContractLine.EstimatePSFFees += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
							thisContractLine.ContractPSFFees += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
						} else {
		                    ContractLine ContractDetail = new ContractLine ();
		                    ContractDetail.EstimatePSFFees = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
							ContractDetail.ContractPSFFees = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
								 
		                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
		                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
		                    if (isByCategory){
		                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
		                    } else {
		                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
		                    }
		                    
		                    HistoricalV00Contract.PSFLineMap.put(LineKey,ContractDetail);
		                }
                    }
                    //Estimate contract cost total 
                    HistoricalV00Contract.TradeExpenses += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c==null?0:ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    
                    //SUM(BRSF estimate cost, Other variable cost)
                    Decimal cost;
	                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
	                	cost = ContractLine.ASI_CRM_CN_Est_Total__c != null ? ContractLine.ASI_CRM_CN_Est_Total__c : 0;
	                }else{
	                	cost = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
	                }
	                HistoricalVFinalContract.TradeExpenses += cost;
	                if (ContractLine.ASI_CRM_Type__c == 'PSF'){
	                    HistoricalVFinalContract.PSFExpensesTotal += cost;
	                } else if (ContractLine.ASI_CRM_Type__c == 'Display'){
	                   	HistoricalVFinalContract.DisplayExpensesTotal += cost;
	                }
                }//end of Looping the Contract Line
                
                
                
                Map<String,Decimal> CR12FactorMap = GenerateCR12FactorMap(V00SubBrandIdSet, CommercialTeam, strRegion);
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine :BRSFList){
                    if (ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                        Decimal CR12Factor=1;
                        if(CR12FactorMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                            CR12Factor=CR12FactorMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                        }//system.debug(' NOW h :'+ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c +'*'+ CR12Factor +'*'+ ContractLine.ASI_CRM_CN_No_of_Months__c);
                        HistoricalV00Contract.IntakeCR12 += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * ContractLine.ASI_CRM_CN_No_of_Months__c;
                    }
                }
                
                
                Date StartDateExtend2 = Date.newInstance(StartDateExtend.addYears(-1).year(), 6, 30);
                Date EndDateExtend2 = Date.newInstance(EndDateExtend.year(), 6, 30);
                
                //Getting GM/GS Data
                
                
                Map<String, String> subBrandCategoryMap = new Map<String, String>();
                for (ASI_CRM_CM_GS__c lbcm : [SELECT Id,
												ASI_CRM_CM_GS_per_9L__c, 
												ASI_CRM_PRODUCTCODE__c, 
												ASI_CRM_PRODUCTCODE__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c,
												ASI_CRM_Region__c  
											  FROM ASI_CRM_CM_GS__c
                                              WHERE ASI_CRM_CN_Month__c = 6  AND (ASI_CRM_YEAR__c = :currentFY OR ASI_CRM_YEAR__c = :currentFY2 OR ASI_CRM_YEAR__c = :currentFY3) AND
                                              ASI_CRM_Region__c = :strRegion  AND ASI_CRM_TYPE__c = 'Budget CM'
                                              AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_YEAR__c DESC, ASI_CRM_VERSION__c DESC ])
                {// and ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet 
                    String ProductCode = lbcm.ASI_CRM_PRODUCTCODE__c;
                    Decimal cm=0.0;
                    if (lbcm.ASI_CRM_CM_GS_per_9L__c != null){
                        cm = lbcm.ASI_CRM_CM_GS_per_9L__c; 
                    }
                    if (!RegionSubBrandCM_Map.containsKey(ProductCode)){
                        RegionSubBrandCM_Map.put(ProductCode,cm);
                        subBrandCategoryMap.put(ProductCode, lbcm.ASI_CRM_PRODUCTCODE__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c);
                    }
                }
                
                
                Map<String, ASI_CRM_CM_GS__c> cmgsMap = new Map<String, ASI_CRM_CM_GS__c>();   
                System.debug('RestructureCurrentFIData StartDateExtend : '+StartDateExtend);
                System.debug('RestructureCurrentFIData EndDateExtend : '+EndDateExtend);
                System.debug('RestructureCurrentFIData StartDateExtend2 : '+StartDateExtend2);
                System.debug('RestructureCurrentFIData EndDateExtend2 : '+EndDateExtend2);
                
                for (ASI_CRM_CM_GS__c line : [SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_TYPE__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_Region__c, ASI_CRM_PRODUCTCODE__r.Name, ASI_CRM_CN_Month_End_Date__c , ASI_CRM_PRODUCTCODE__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Month__c FROM ASI_CRM_CM_GS__c
                                              WHERE ASI_CRM_PRODUCTCODE__c IN :V00SubBrandIdSet   AND ASI_CRM_Region__c = :strRegion AND (ASI_CRM_TYPE__c = 'Budget CM' OR ASI_CRM_TYPE__c = 'Budget GS') 
                                              AND ( (ASI_CRM_CN_Month_End_Date__c >= :StartDateExtend AND ASI_CRM_CN_Month_End_Date__c <= :EndDateExtend )
                                                   OR (ASI_CRM_CN_Month_End_Date__c >= :StartDateExtend2   AND ASI_CRM_CN_Month_End_Date__c <= :EndDateExtend2  AND ASI_CRM_CN_Month__c = 6  ) )  
                                              AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0  ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
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
                    	subbrand_data subBrandData = historicalV0_sbDataROI_map.get(key);
            			String categoryName =  subBrandCategoryMap.get(subBrandData.SubBrandId);
                        PeriodStr= null;
                        if (subBrandData.period != null){
                            PeriodStr = subBrandData.period;
                        }
                        //Budget CM
                        ActualCM = null;
                        if (subBrandData.CM != null){
                            ActualCM = subBrandData.CM;
                        }
                        // Latest Budget CM
                        LatestBudgetCM = null;
                        if (subBrandData.latestBudgetCM != null){
                            LatestBudgetCM = subBrandData.latestBudgetCM;
                        }
                        //Budget GS
                        ActualGS = null;
                        if (subBrandData.GS != null){
                            ActualGS = subBrandData.GS;
                        }
                        TotalEstimateVol = null;
                        if (EstimateVolumeV0Map != null && subBrandData != null && subBrandData.SubBrandId != null && EstimateVolumeV0Map.containsKey(subBrandData.SubBrandId)){
                            TotalEstimateVol = EstimateVolumeV0Map.get(subBrandData.SubBrandId);
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
                        	Decimal GSSubTotal = ActualGS * TotalEstimateVol * PeriodStr;
                            HistoricalV00Contract.GrossSalesTotal += GSSubTotal;
                            if (categoryName != null)
                            	HistoricalV00Contract.CategoryGSMap = addToDecimalMap(HistoricalV00Contract.CategoryGSMap, categoryName, GSSubTotal);
                        }
                    }
                }// end of historicalV0_sbDataROI_map Looping 
                
                //**************************Calculation**************************
                
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
                HistoricalVFinalContract.OtherExpensesTotal = thisCC.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;
            }
            
            HistoricalVFinalContract.ContractId = thisCC.Id;
            HistoricalVFinalContract.POStartDate = thisCC.ASI_CRM_CN_PO_Start_Date__c;
            HistoricalVFinalContract.POEndDate= thisCC.ASI_CRM_CN_PO_End_Date__c;
            
            HistoricalVFinalContract.ContractLineMap = new Map<String,ContractLine>();
            HistoricalVFinalContract.OtherExpensesMap = new Map<String,ContractLine>();
            Decimal TotalHC_VolumeBtl =0; // total historical contract Volume BTL
            Decimal TotalHC_IntakeBtl =0; 
            Decimal PSFEstTotal=0;

            Decimal TotalHistorical_MartellIntakeBtl =0;  // total historical contract Martel Intake Btl
            
            
            for (ASI_CRM_Contract_Cost__c pccost : [SELECT Id,Name, ASI_CRM_CN_Activity_Code__r.Name,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c, 
                                                    ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c 
                                                    FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c = :thisCC.Id])
            {
                if (pccost.ASI_CRM_CN_Cost_Type__c == 'Fixed' && pccost.ASI_CRM_CN_Estimate_Amount__c != null ){
                	String mapKey = pccost.Name + ' ' +pccost.ASI_CRM_CN_Chinese_Description__c;
                    if (HistoricalVFinalContract.OtherExpensesMap.containsKey(mapKey)){
                        HistoricalVFinalContract.OtherExpensesMap.get(mapKey).HistoricalFees += pccost.ASI_CRM_CN_Estimate_Amount__c;
                    }else{
                        ContractLine ContractDetail = new ContractLine ();
                        ContractDetail.HistoricalFees=pccost.ASI_CRM_CN_Estimate_Amount__c;
                        HistoricalVFinalContract.OtherExpensesMap.put(mapKey, ContractDetail);
                    }
                }
                HistoricalVFinalContract.TradeExpenses+=pccost.ASI_CRM_CN_Estimate_Amount__c!=null?pccost.ASI_CRM_CN_Estimate_Amount__c:0;
            }
            
            
            
            
            Set<String> PSFMethodologySetVFinal = new Set<String>();
            Set<String> PSFVolumeBaseSetVFinal = new Set<String>();
            
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : getBRSFLines(thisCC.Id)){
                
                if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){
                    
                    if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF'  && ContractLine.ASI_CRM_Module__c!=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c!=null){
                        HistoricalVFinalContract.BRSFMethodologyName= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c;
                    }
                    
                    String LineKey=NameSortingASC(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//ContractLineSBGradeName; //NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) +subBrandKey;//
                    
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

                
                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='PSF' && ContractLine.ASI_CRM_Module__c!=null){
                    if(!PSFMethodologySetVFinal.contains(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name)){
                        PSFMethodologySetVFinal.add(ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name);
                        HistoricalVFinalContract.PSFMethodologyName+= ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c+';';
                    }
                    if(!PSFVolumeBaseSetVFinal.contains(ContractLine.ASI_CRM_Volume_Base__c)){
                        PSFVolumeBaseSetVFinal.add(ContractLine.ASI_CRM_Volume_Base__c);
                        HistoricalVFinalContract.PSFVolumeBase+= VolumeBaseTranslation(ContractLine.ASI_CRM_Volume_Base__c)+';';
                    }
                    
                    //Build PSFLineMap
	                String LineKey;
	                Boolean isByCategory = false;
	                System.debug('ContractLine: ' + ContractLine);
	                if (ContractLine.ASI_CRM_Volume_Base__c == 'By Category'){
		                //By Category
		               	isByCategory = true;
		               	LineKey = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
		            } else {
		               	//By Sub-brand
		            	LineKey = NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c) + ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;//subBrandKey;//
		            } /*else {
		            	system.debug('ByTotal');
		               	LineKey = 'ByTotal';
		            } */
	                
	                if(HistoricalVFinalContract.PSFLineMap.containsKey(LineKey)){
	                	ContractLine thisContractLine = HistoricalVFinalContract.PSFLineMap.get(LineKey);
						thisContractLine.EstimatePSFFees += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
						thisContractLine.ContractPSFFees += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
					} else {
	                    ContractLine ContractDetail = new ContractLine ();
	                    ContractDetail.EstimatePSFFees = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
						ContractDetail.ContractPSFFees = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
							 
	                    ContractDetail.SubBrandName=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
	                    ContractDetail.SubBrandGrade= ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
	                    if (isByCategory){
	                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
	                    } else {
	                    	ContractDetail.SubBrandCategory = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
	                    }
	                    
	                    HistoricalVFinalContract.PSFLineMap.put(LineKey,ContractDetail);
	                }
                }
                
                Decimal cost;
                if(ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item'){
                	cost = ContractLine.ASI_CRM_CN_Est_Total__c != null ? ContractLine.ASI_CRM_CN_Est_Total__c : 0;
                }else{
                	cost = ContractLine.ASI_CRM_CN_Est_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }
                HistoricalVFinalContract.TradeExpenses += cost;
                if (ContractLine.ASI_CRM_Type__c == 'PSF'){
                    HistoricalVFinalContract.PSFExpensesTotal += cost;
                } else if (ContractLine.ASI_CRM_Type__c == 'Display'){
                   	HistoricalVFinalContract.DisplayExpensesTotal += cost;
                }
            }
            AdditionalFIMap.put('PSFEstTotal',PSFEstTotal);
            
            if(thisCC.ASI_CRM_CN_PO_Version__c!='0.0' && thisCC.ASI_TH_CRM_Promotion_Type__c== 'Heavy Contract Off'){// ASI_CRM_CN_Total_Contract_Amount__c
                HistoricalVFinalContract.TradeExpenses=thisCC.ASI_CRM_CN_Total_Contract_Amount__c!=null?thisCC.ASI_CRM_CN_Total_Contract_Amount__c:0;
                HistoricalVFinalContract.PSFExpensesTotal+=thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
                HistoricalVFinalContract.DisplayExpensesTotal+=thisCC.ASI_CRM_CN_Expected_Display_Est_Total__c!=null?thisCC.ASI_CRM_CN_Expected_Display_Est_Total__c:0;
                
            }
 
 
            
            Set<Id> HistoricalVFinalSBIdSet = new Set<Id> ();         
            Date CutOffDay = ASI_CRM_DateUtilClass.getCutOffDate();
            Date TillEnd;
            if (CutOffDay >= thisCC.ASI_CRM_CN_PO_End_Date__c)
                TillEnd = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_End_Date__c);
            else
                TillEnd = CutOffDay; 
            
            Integer PeriodA = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, TillEnd);
            Integer PeriodB = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
            
            Decimal TotalHCVolumeBtl=0;
            Map<Date, Decimal> HistoricalVFinal_Period_map = ASI_CRM_DateUtilClass.getFiscalYearMonthMap(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
            
            System.debug(HistoricalAllOutlet+'RestructureCurrentFIData TillEnd 0.1: '+TillEnd);
            System.debug('PeriodA: '+PeriodA);
            System.debug('PeriodB: '+PeriodA);
            
            Map <String, subbrand_data> historical_sbDataROI_map = new Map <String, subbrand_data> ();
            
			
			/* 
            if (HistoricalAllOutlet.size() >= outletThreshold()){
	        	HistoricalSBVolumeList = [SELECT id, Name,ASI_CRM_DeductCapWithIssue_StdBill__c,
                                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                                                                       ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_Black_Cap_Std_Billing__c,ASI_CRM_Grey_Cap_Std_Billing__c,ASI_CRM_Offtake__c, ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Offtake_CR12__c, ASI_CRM_Subbrand__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c, ASI_CRM_Subbrand__r.Name,  ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_T2_Depletion_BTL__c,ASI_CRM_T1_Depletion__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c, ASI_CRM_T2_Depletion__c, ASI_CRM_PR_Direct__c, ASI_CRM_PR_Direct_Btl__c,ASI_CRM_End_Date__c ,ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,
                                                                       ASI_CRM_PR_Direct_STD__c,ASI_CRM_Black_Cap_Btl__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_DeductibleCapWithIssues_Std_Btl__c,ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c
                                                                       FROM ASI_CRM_Subbrand_Volume__c 
                                                                       WHERE ASI_CRM_CN_Competitor_Sub_brand__c != true 
                                                                       AND ASI_CRM_Subbrand__c !=null 
                                                                       AND ASI_CRM_End_Date__c >= :thisCC.ASI_CRM_CN_PO_Start_Date__c 
                                                                       AND ASI_CRM_End_Date__c <= :TillEnd 
                                                                       AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
				                                                       AND ASI_CRM_CN_Contract__c = :thisCC.Id 
				                                                       AND recordtypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')];
	        	
	        } else {
	        	HistoricalSBVolumeList = [SELECT id, Name,ASI_CRM_DeductCapWithIssue_StdBill__c,
                                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                                                                       ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_Black_Cap_Std_Billing__c,ASI_CRM_Grey_Cap_Std_Billing__c,ASI_CRM_Offtake__c, ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Offtake_CR12__c, ASI_CRM_Subbrand__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c, ASI_CRM_Subbrand__r.Name,  ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_T2_Depletion_BTL__c,ASI_CRM_T1_Depletion__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c, ASI_CRM_T2_Depletion__c, ASI_CRM_PR_Direct__c, ASI_CRM_PR_Direct_Btl__c,ASI_CRM_End_Date__c ,ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,
                                                                       ASI_CRM_PR_Direct_STD__c,ASI_CRM_Black_Cap_Btl__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_DeductibleCapWithIssues_Std_Btl__c,ASI_CRM_Green_Cap_STD__c, ASI_CRM_Empty_Bottle_Std_Btl__c
                                                                       FROM ASI_CRM_Subbrand_Volume__c 
                                                                       WHERE ASI_CRM_Account__c IN :HistoricalAllOutlet 
                                                                       AND ASI_CRM_CN_Competitor_Sub_brand__c != true 
                                                                       AND ASI_CRM_Subbrand__c !=null 
                                                                       AND ASI_CRM_End_Date__c >= :thisCC.ASI_CRM_CN_PO_Start_Date__c 
                                                                       AND ASI_CRM_End_Date__c <= :TillEnd 
		                                                               AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
			                                                           AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION];
	                                                         
	        }
	        */
            List<ASI_CRM_Subbrand_Volume__c> HistoricalSBVolumeList = new List<ASI_CRM_Subbrand_Volume__c>();
	        String historicalSBVolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
	        historicalSBVolumeQuery += 'WHERE ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
	                               'AND ASI_CRM_Subbrand__c !=null ' + 
	                               'AND ASI_CRM_End_Date__c >= ' + String.valueOf(thisCC.ASI_CRM_CN_PO_Start_Date__c) + ' ' +
	                               'AND ASI_CRM_End_Date__c <= :TillEnd ' +
	                               'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE ';
	        
	        if (HistoricalAllOutlet.size() >= outletThreshold()){
	        	historicalSBVolumeQuery += 'AND ASI_CRM_CN_Contract__c = \'' + thisCC.Id + '\' ' +
	        							'AND recordtypeId = \'' + Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')+'\' ';
	            
	        	
	        } else {
	        	historicalSBVolumeQuery += 'AND ASI_CRM_Account__c IN :HistoricalAllOutlet ' +
	        							'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';
	                                                         
	        }
	        System.debug(historicalSBVolumeQuery);
	        HistoricalSBVolumeList = Database.query(historicalSBVolumeQuery);
	        
            
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
            
            Decimal Total_IntakeBtl_prorate=0;
            Decimal TotalBC_prorate=0;
            for (ASI_CRM_Subbrand_Volume__c SubBrandVolume: HistoricalSBVolumeList){
                
                HistoricalVFinalSBIdSet.add(SubBrandVolume.ASI_CRM_Subbrand__c);
                //Calculate Volume 
                Decimal Volumes = 0;
                Volumes += SubBrandVolume.ASI_CRM_T1_Depletion__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion__c:0;
                Volumes += SubBrandVolume.ASI_CRM_T2_Depletion__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion__c:0;
                Volumes += SubBrandVolume.ASI_CRM_PR_Direct__c!=null? SubBrandVolume.ASI_CRM_PR_Direct__c:0;
                
                
                Decimal VolumeBtl=0;
                VolumeBtl += SubBrandVolume.ASI_CRM_T1_Depletion_STD__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion_STD__c:0;
                VolumeBtl += SubBrandVolume.ASI_CRM_T2_Depletion_STD__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion_STD__c:0;
                VolumeBtl += SubBrandVolume.ASI_CRM_PR_Direct_STD__c!=null? SubBrandVolume.ASI_CRM_PR_Direct_STD__c:0;
                
                if( ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c) ){
                    TotalHistorical_MartellIntakeBtl+=VolumeBtl;
                }
                System.debug('Total Historical VolumeBtl : '+VolumeBtl);
                
                TotalHC_IntakeBtl += VolumeBtl;
                Decimal VarHistTotal = VolumeBtl;
                Decimal VarHistTotalVolume=Volumes;
                Decimal VariableHistoricalBottles = VolumeBtl/PeriodA;
                
                if (PeriodA != 0 && PeriodA != null && PeriodB != 0 && PeriodB != null){
                    Volumes = Volumes/PeriodA * PeriodB;
                    VolumeBtl = VolumeBtl/PeriodA * PeriodB;
                }
                
                Total_IntakeBtl_prorate+=VolumeBtl;
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
                    HistoricalVFinalContract.SubBrandGradeGrouping.put(SubBrandName,TempVolumes); 
                }else{
                    HistoricalVFinalContract.SubBrandGradeGrouping.put(SubBrandName,Volumes); 
                }
                
                if(HistoricalVFinalContract.SubBrandGradeMap.containsKey(SubbrandGroupName)){
                    Decimal TempVolumes=HistoricalVFinalContract.SubBrandGradeMap.get(SubbrandGroupName)+Volumes;
                    HistoricalVFinalContract.SubBrandGradeMap.put(SubbrandGroupName,TempVolumes); 
                }else{
                    HistoricalVFinalContract.SubBrandGradeMap.put(SubbrandGroupName,Volumes); 
                }
                
                //By Brande Product Category Grouping  
                if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c !=null && SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null ){
                    String CategoryName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
                    HistoricalVFinalContract.CategoryVolumeMap = addToDecimalMap(HistoricalVFinalContract.CategoryVolumeMap, CategoryName, Volumes);
                }// end of By Brande Product Category Grouping      
                
                
                Date SubbrandVolumeDateKey = ASI_CRM_DateUtilClass.getFiscalYearEndDate(SubBrandVolume.ASI_CRM_End_Date__c);
                String SubbrandVolumeStrKey = String.valueOf(SubbrandVolumeDateKey) + SubBrandVolume.ASI_CRM_Subbrand__c;
                
                if (historical_sbDataROI_map != null && historical_sbDataROI_map.containsKey(SubbrandVolumeStrKey)){
                    historical_sbDataROI_map.get(SubbrandVolumeStrKey).TotalVolume += VarHistTotalVolume;
                }
                
                String subBrandKey =NameSortingASC(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + SubBrandVolume.ASI_CRM_Subbrand__r.Name; 
                
                if(HistoricalVFinalContract.ContractLineMap.containsKey(subBrandKey)){
                    HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalBottles =HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalBottles + VariableHistoricalBottles ;
                    HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalTotalFees +=  HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalFees * VarHistTotal;
                    HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalActualVolume =HistoricalVFinalContract.ContractLineMap.get(subBrandKey).HistoricalActualVolume + VariableHistoricalBottles ;
                }else{
                    ContractLine ContractDetail = new ContractLine ();
                    ContractDetail.HistoricalBottles = VariableHistoricalBottles;
                    ContractDetail.HistoricalActualVolume= VariableHistoricalBottles;
                    //ContractDetail.HistoricalTotalFees=0;
                    ContractDetail.SubBrandName=SubBrandVolume.ASI_CRM_Subbrand__r.Name;
                    ContractDetail.SubBrandGrade= SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    HistoricalVFinalContract.ContractLineMap.put(subBrandKey,ContractDetail);
                }
                
                Decimal VolumesCR12 = 0; 
                VolumesCR12 += SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T1_Depletion_CR12__c:0;
                VolumesCR12 += SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c!=null? SubBrandVolume.ASI_CRM_T2_Depletion_CR12__c:0;
                VolumesCR12 += SubBrandVolume.ASI_CRM_PR_Direct_CR12__c!=null? SubBrandVolume.ASI_CRM_PR_Direct_CR12__c:0;
                HistoricalVFinalContract.IntakeCR12 += VolumesCR12;
                
            }//end of Sub Brand Volume for looping
             
            AdditionalFIMap.put('Total_IntakeBtl_prorate',Total_IntakeBtl_prorate); 
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
                                          AND (ASI_CRM_TYPE__c = 'YTD CM' OR ASI_CRM_TYPE__c = 'YTD GS') AND ASI_CRM_CM_GS_per_9L__c != NULL AND ASI_CRM_CM_GS_per_9L__c != 0 ORDER BY ASI_CRM_PRODUCTCODE__c ASC, ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC ])
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
                            ProForma_LatestBudgetCM.put(line.ASI_CRM_PRODUCTCODE__c,RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c));// system.debug(line.ASI_CRM_PRODUCTCODE__c+'Debug7.1:'+RegionSubBrandCM_Map.get(line.ASI_CRM_PRODUCTCODE__c));
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
                    historicalVFinalTillEnd = ASI_CRM_DateUtilClass.getEndOfMonth(thisCC.ASI_CRM_CN_PO_End_Date__c);
                else
                    historicalVFinalTillEnd = CutOffDay;
                
                Integer PeriodA_prorate = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, historicalVFinalTillEnd);
                Integer PeriodB_prorate = ASI_CRM_DateUtilClass.monthDiff(thisCC.ASI_CRM_CN_PO_Start_Date__c, thisCC.ASI_CRM_CN_PO_End_Date__c);
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
                        HistoricalVFinalContract.GrossSalesTotal += ActualGS * TotalActualVol;//system.debug('New Historical Gross Sales: ' + historical_sbDataROI_map.get(key).SubBrandId + ' ' + ActualGS + ' * ' + TotalActualVol );
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
            System.debug(CMTotalVFinal+'Laputa system.debug latestBudgetCMTotal.strA '+LatestBudgetCMTotalVFinal);
            //Historical V Final Calculation
            
            //%Gross Sales Historical
            if (HistoricalVFinalContract.GrossSalesTotal != null && HistoricalVFinalContract.GrossSalesTotal != 0 && HistoricalVFinalContract.TradeExpenses != 0 && HistoricalVFinalContract.TradeExpenses!= null){
                HistoricalVFinalContract.GrossSalesRate = (HistoricalVFinalContract.TradeExpenses/ HistoricalVFinalContract.GrossSalesTotal) *100;
            }
            
            //Historical Contract Margin after A&P
            if (CMTotalVFinal != null && HistoricalVFinalContract.OtherExpensesTotal != null){
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
            
            AdditionalFIMap.put('TotalHC_IntakeBtl',TotalHC_IntakeBtl); 
        }
        
        HistoricalVFinalContract.AddOnString = System.JSON.serialize(AdditionalFIMap);
        
        List<FinancialIndicator> FinancialIndicatorList = new List<FinancialIndicator>();
        FinancialIndicatorList.add(HistoricalV00Contract);
        FinancialIndicatorList.add(HistoricalVFinalContract);
        
        UpsertAttachment(thisCC.Id, System.JSON.serialize(FinancialIndicatorList),'Current V0VFinal Data' );
        
    } // end of RestructureHistoricalData
    
    /*
    	Consolidated Shuttle Fields
    		1.	Volumes in 9L (Sum of Group PO's BRSF Line converted to 9L)
    		2. 	Trade Expenses (Sum of all Approved Child's New Contract's v0 Estimate Trade Expense)
	    	3.	Gross Sales (Sum of all Approved Child's New Contract's v0 Estimate Gross Sales)
	    	4.	Gross Sales % ( Trade Expenses / Gross Sales * 100 ) << Calculated by Financial Indicator Class
	    	5.	Cont. Margin after A&P ( Sum of (Group PO's BRSF Line's V0.0 Actual CM) - Trade Expenses )
	    	6.	Cont. Margin per Bottle ( Cont. Margin after A&P / Sum of Group PO's BRSF Line in Standard Bottle ) << Calculated by Financial Indicator Class
	    	7. 	ROI (Actual) ((Cont. Margin after A&P - Trade Expenses) / Trade Expenses)

    */
	public static void calculateGroupFI(Id groupContractId, Id thisContractId) {
		ASI_TH_CRM_Contract__c groupContract = groupContractId != null ? new ASI_TH_CRM_Contract__c(Id = groupContractId) : null;
		ASI_TH_CRM_Contract__c thisContract = thisContractId != null ? new ASI_TH_CRM_Contract__c(Id = thisContractId) : null;
		calculateGroupFI(groupContract, thisContract);
	}

    public static void calculateGroupFI(ASI_TH_CRM_Contract__c groupContract, ASI_TH_CRM_Contract__c thisContract) {
    	if (groupContract == null) return;
    	//If thisContract == null, it is Consolidate shuttle from Group PO Page
    	//else, it is Profit shuttle in Child PO

    	FinancialIndicator groupContractFI = new FinancialIndicator();
    	Boolean thisContractInGroup = false;
    	List<Id> childContractIdList = new List<Id>();
    	List<FinancialIndicator> childPOFIList = new List<FinancialIndicator>();
    	FinancialIndicator thisPOFI = new FinancialIndicator();
    	//Get all APPROVED child (Approval status = 'Approved' or 'Final)
    	//If thisContract is already inside Group Contract, no need to further add
    	List<ASI_TH_CRM_Contract__c> childPOList = [SELECT Id
    												FROM ASI_TH_CRM_Contract__c
    												WHERE ASI_CRM_CN_Group_Contract__c = :groupContract.Id
    												AND (ASI_CRM_CN_Status__c = 'Approved'
    													OR ASI_CRM_CN_Status__c = 'Final')];
    	if (childPOList.size() > 0){
    		for (ASI_TH_CRM_Contract__c childPO : childPOList){
    				childContractIdList.add(childPO.Id);
    		}
    	}

    	thisContractInGroup = thisContract != null ? childContractIdList.contains(thisContract.Id) : false;

    	//	Source: Original Contract Data
    	//		Volumes in 9L (Sum of Group PO's BRSF Line converted to 9L)
    	//		Cont. Margin after A&P ( Sum of (Group PO's BRSF Line's V0.0 Actual CM) - Trade Expenses )
    	RestructureCurrentFinancialIndicatorData(groupContract);

    	//	Source: Aggregate from Child Data
	    //	 	Trade Expenses (Sum of all Approved Child's New Contract's v0 Estimate Trade Expense)
	    //		Gross Sales (Sum of all Approved Child's New Contract's v0 Estimate Gross Sales)
    	List<ASI_Attachment__c> AttachmentList = new List<ASI_Attachment__c>();

    	if (thisContractInGroup || thisContract == null){
    		AttachmentList = [SELECT Id,
    							ASI_CRM_Historical_Financial_Data__c,
        						ASI_CRM_Contract__c,
        						ASI_CRM_Type__c
        					FROM ASI_Attachment__c
        					WHERE (ASI_CRM_Contract__c = :groupContract.Id
        						OR ASI_CRM_Contract__c IN :childContractIdList)
        					AND ASI_CRM_Type__c = 'Contract Data'];
    	} else {
    		AttachmentList = [SELECT Id,
    							ASI_CRM_Historical_Financial_Data__c,
        						ASI_CRM_Contract__c,
        						ASI_CRM_Type__c
        					FROM ASI_Attachment__c
        					WHERE (ASI_CRM_Contract__c = :groupContract.Id
        						OR ASI_CRM_Contract__c IN :childContractIdList
        						OR ASI_CRM_Contract__c = :thisContract.Id)
        					AND ASI_CRM_Type__c = 'Contract Data'];

    	}

       	for(ASI_Attachment__c att:AttachmentList){
       		System.debug('AttachmentList:' + att.Id);
			String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
			List<FinancialIndicator> ContractDataList =(List<FinancialIndicator>)System.JSON.deserialize(JsonString,List<FinancialIndicator>.class);

			if (ContractDataList.size() >= 2){
				FinancialIndicator tempFI = ContractDataList[1];
				if (att.ASI_CRM_Contract__c == groupContract.Id){
					groupContractFI = tempFI;
				} else if (thisContract != null && !thisContractInGroup && att.ASI_CRM_Contract__c == thisContract.Id){
					thisPOFI = tempFI;
				} else {
					childPOFIList.add(tempFI);
				}
			}
		}

		if (groupContractFI != null && childPOFIList.size() > 0){
			groupContractFI.GrossSalesTotal = 0;
			for (FinancialIndicator childFI : childPOFIList){
				groupContractFI.PSFExpensesTotal += childFI.PSFExpensesTotal;
				groupContractFI.OtherExpensesTotal += childFI.OtherExpensesTotal;
				groupContractFI.DisplayExpensesTotal += childFI.DisplayExpensesTotal;
				groupContractFI.GrossSalesTotal += childFI.GrossSalesTotal;
			}
		}
		//If this Contract is not in Group, add the FI to the Consolidated Shuttle
		if (!thisContractInGroup && thisPOFI != null) {
			groupContractFI.PSFExpensesTotal += thisPOFI.PSFExpensesTotal;
			groupContractFI.OtherExpensesTotal += thisPOFI.OtherExpensesTotal;
			groupContractFI.DisplayExpensesTotal += thisPOFI.DisplayExpensesTotal;
			groupContractFI.GrossSalesTotal += thisPOFI.GrossSalesTotal;
		}

		//	Source: Calculated by FI Data
		//	 	ROI (Actual) = ROI (Intake) = ((Cont. Margin after A&P - Trade Expenses) / Trade Expenses)
		if (groupContractFI.TradeExpenses != 0){
			groupContractFI.ROIIntake = (groupContractFI.MarginAfterAnP/groupContractFI.TradeExpenses) - 1;
		}

		//system.debug(groupContractFI);
		UpsertAttachment(groupContract.Id, System.JSON.serialize(groupContractFI), 'Group Contract Data');
    }

    //Sort ascending for Map Name
    public static String NameSortingASC(Decimal strSeq){
        String returnString;
        if (strSeq != null){
        	returnString = (String.valueOf(strSeq)).leftPad(5,'0');
        } else {
            returnString = '00000';
        }
        return returnString; 
    }
    //Sort descending for Map Name
    public static String NameSortingDESC(Decimal strSeq){
        return String.valueOf(99999 - Integer.valueOf(NameSortingASC(strSeq)));
    }
    
    public static Map<String,Decimal> addToDecimalMap(Map<String,Decimal> fullMap, String key, Decimal value){
    	if (fullMap.containsKey(key)){
    		fullMap.put(key, fullMap.get(key) + value);
    	} else {
    		fullMap.put(key, value);
    	}
    	return fullMap;
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
    
    //Generate CR12 Factor Mapping table : Sub-Brand Id, CR12 Factor 
    public static Map<String,Decimal> GenerateCR12FactorMap(Set<Id> SBIdSet, String CommercialTeam, String RegionName){
        Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
        for(ASI_MFM_Sub_brand__c SubBrand: [SELECT Id,
        										ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
        										(SELECT Id,
        												ASI_CRM_CR12_Conversion_Factor__c,
        												ASI_CRM_Commercial_Team__c,
        												ASI_CRM_CN_Region__c 
        										FROM ASI_CRM_CR12_Factors__r)
        									FROM ASI_MFM_Sub_brand__c
        									WHERE Id IN : SBIdSet ]){
            Decimal CR12Factor=1;
            Boolean FoundFactor = false;
            for(ASI_CRM_Sub_Brand_Line__c SubBrandLine: SubBrand.ASI_CRM_CR12_Factors__r){
                if(RegionName !=null && 
                	CommercialTeam !=null && 
                	SubBrandLine.ASI_CRM_CR12_Conversion_Factor__c !=null &&  
                	SubBrandLine.ASI_CRM_Commercial_Team__c == CommercialTeam && 
                	SubBrandLine.ASI_CRM_CN_Region__c == RegionName ){
                		
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
    
    // Insert Attachment Json
    public static void  UpsertAttachment(String ContractId, String JSONString, String TypeName){
        List<ASI_Attachment__c> AttachmentList= new  List<ASI_Attachment__c>();
        
        JSONString= JSONString.replaceAll('<','&lt;');
        
        
        try{
            ASI_Attachment__c FinancialData = new ASI_Attachment__c();
            AttachmentList= [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :ContractId AND ASI_CRM_Type__c = : TypeName];
            
            if(AttachmentList.size()>0){//exist
                FinancialData=AttachmentList[0];
                FinancialData.ASI_CRM_Historical_Financial_Data__c= JSONString;
                
            } else {
                FinancialData= new ASI_Attachment__c(ASI_CRM_For_Contract_Use__c=true,ASI_CRM_Contract__c=ContractId,ASI_CRM_Type__c=TypeName,ASI_CRM_Historical_Financial_Data__c=JSONString);
                
            }
            upsert FinancialData;//system.debug(FinancialData);
            
        }catch(Exception e){ 
            String msg = 'UpsertAttachment  Error : ' +e.getMessage();
            ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '+ msg+' with contarct Id '+ContractId + ' with Json string : '+ JSONString , 'ASI_CRM_CN_OffContractUtilitiesClass','RestructureHistoricalFinancialIndicatorData.UpsertAttachment');
        }
    }
    
    private static ASI_TH_CRM_Contract__c getContract(Id contractId){
    	ASI_TH_CRM_Contract__c contract = [SELECT Id,
											Name,
											Owner.Name,
            ASI_CRM_CN_Expected_Display_Est_Total__c,
											ASI_CRM_CN_BRSF_Contract_Total__c,
											ASI_CRM_CN_Bottle_Collection_Rate__c,
											ASI_CRM_CN_Budget_LE__c,
											ASI_CRM_CN_Contract_Cost_Total__c,
											ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
											ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
											ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
											ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
											ASI_CRM_CN_Contract_Variable_Cost_Total__c,
											ASI_CRM_CN_Description__c,
											ASI_CRM_CN_Last_PO_version__c,
											ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
											ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
											ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
											ASI_CRM_CN_No_of_Months__c,
											ASI_CRM_CN_Outlet_WS__c,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
											ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,
											ASI_CRM_CN_Outlet_WS__r.ASI_TH_CRM_OutletType__c,
											ASI_CRM_CN_Outlet_WS__r.Name,
											ASI_CRM_CN_PO_End_Date__c,
											ASI_CRM_CN_PO_Modification__c,
											ASI_CRM_CN_PO_No__c,
											ASI_CRM_CN_PO_Start_Date__c,
											ASI_CRM_CN_PO_Version__c,
											ASI_CRM_CN_Status__c,
											ASI_CRM_CN_Total_Contract_Amount__c,
											ASI_CRM_CN_V0_0_PO_version__c,
											ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
											ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
											ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
											ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,
											ASI_CRM_CN_Vol_Budget_LE__c,
											ASI_CRM_New_FY_PO__c,
											ASI_CRM_PO_Channel__c,
											ASI_CRM_PO_Channel__r.Name,
											ASI_CRM_PO_City__c,
											ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c,
											ASI_CRM_PO_City__r.Name,
											ASI_CRM_PO_Province__c,
											ASI_CRM_PO_Province__r.Name,
											ASI_CRM_Volume_Option__c,
            ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
            ASI_CRM_CN_Expected_PSF_Est_Total__c,
											ASI_TH_CRM_Promotion_Type__c,
                                            ASI_CRM_CN_Is_Dolphin__c
										FROM ASI_TH_CRM_Contract__c 
										WHERE Id = :contractId];
		return contract;	
    }
    
    public static List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> getBRSFLines(Id contractId){
    	List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> result = [SELECT Id, 
																	RecordType.DeveloperName,
															        ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
																	ASI_CRM_CN_Contract_Monthly_Qty__c,
																	ASI_CRM_CN_Contract_Monthly_Vol9L__c,
																	ASI_CRM_CN_Contract_Purchase_Value__c,
																	ASI_CRM_CN_Contract_Total_Dummy__c,
																	ASI_CRM_CN_Contract_Total__c,
																	ASI_CRM_CN_Contract__c,
																	ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c,
																	ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
																	ASI_CRM_CN_Est_Monthly_Qty__c,
																	ASI_CRM_CN_Est_Total_Dummy__c,
																	ASI_CRM_CN_Est_Total__c,
																	ASI_CRM_CN_Estimate_Purchase_Value__c,
																	ASI_CRM_CN_Estimate_Volume_9L_Month__c,
																	ASI_CRM_CN_No_of_Months__c,
																	ASI_CRM_CN_Sub_Brand_Conversion_Factor__c,
																	ASI_CRM_CN_Sub_Brand__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
																	ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
																	ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name,
																	ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_External_ID__c,
																	ASI_CRM_CN_Sub_Brand__r.Name,
																	ASI_CRM_Module__c,
																	ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c,
																	ASI_CRM_Module__r.ASI_CRM_Methodology__c,
																	ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
																	ASI_CRM_Product_Category_Name__c,
																	ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c,
																	ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
																	ASI_CRM_Type__c,
																	ASI_CRM_Volume_Base__c,
                                                                    ASI_CRM_CN_Rebate_Percent__c
															   FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
															   WHERE ASI_CRM_CN_Contract__c = :contractId
															   ORDER BY ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
															   			ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,
															   			ASI_CRM_CN_Sub_Brand__r.Name];
		if (result.size() > 0){
			return result;
		} else {
			return new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
		}
    }
    
    public static String SubBrandFieldList(){
    	List<String> fieldList = new List<String>{
    		'id',
			'Name',
			'ASI_CRM_Actual_Vol__c',
			'ASI_CRM_Actual_Vol_STD__c',
            'ASI_CRM_Empty_Bottle__c',
            'ASI_CRM_Empty_Bottle_GS__c',
            'ASI_CRM_Empty_Bottle_Std_Billing__c',
            'ASI_CRM_Empty_Bottle_CR12__c',
            'ASI_CRM_Empty_Bottle_Btl__c',
			'ASI_CRM_Empty_Bottle_Std_Btl__c',
			'ASI_CRM_CN_Intake_GS_T1_Price__c',
			'ASI_CRM_End_Date__c',
			'ASI_CRM_Offtake__c',
			'ASI_CRM_Offtake_Btl__c',
			'ASI_CRM_Offtake_CR12__c',
			'ASI_CRM_Offtake_GS__c',
			'ASI_CRM_Offtake_Std__c',
			'ASI_CRM_Offtake_Std_Billing__c',
			'ASI_CRM_POS_Btl__c',
			'ASI_CRM_POS_CR12__c',
			'ASI_CRM_POS_GS__c',
            'ASI_CRM_Green_ORS_GS__c',
            'ASI_CRM_Green_ORS_Std_Billing__c',
            'ASI_CRM_Green_ORS_9L__c',
            'ASI_CRM_Green_ORS_CR12__c',
            'ASI_CRM_Green_ORS_Btl__c',
            'ASI_CRM_Green_ORS_Std_Btl__c',
			'ASI_CRM_POS_Std_Billing__c',
			'ASI_CRM_PR_Direct__c',
			'ASI_CRM_PR_Direct_Btl__c',
			'ASI_CRM_PR_Direct_CR12__c',
			'ASI_CRM_PR_Direct_STD__c',
			'ASI_CRM_PR_Direct_Std_Billing__c',
			'ASI_CRM_Subbrand__c',
			'ASI_CRM_Subbrand__r.ASI_CRM_CN_Standard_Bottle_Size__c',
			'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c',
			'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Description__c',
			'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c',
			'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c',
			'ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name',
			'ASI_CRM_Subbrand__r.ASI_MFM_Brand__c',
			'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c',
			'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c',
			'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name',
			'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c',
			'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c',
			'ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name',
			'ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_Code__c',
			'ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c',
			'ASI_CRM_Subbrand__r.Name',
			'ASI_CRM_T1_Depletion__c',
			'ASI_CRM_T1_Depletion_BTL__c',
			'ASI_CRM_T1_Depletion_CR12__c',
			'ASI_CRM_T1_Depletion_STD__c',
			'ASI_CRM_T1_Depletion_Std_Billing__c',
			'ASI_CRM_T2_Depletion__c',
			'ASI_CRM_T2_Depletion_BTL__c',
			'ASI_CRM_T2_Depletion_CR12__c',
			'ASI_CRM_T2_Depletion_STD__c',
			'ASI_CRM_T2_Depletion_Std_Billing__c'
    	};
    	return String.join(fieldList,',');
    }
    
    public static String getCategoryNameFromContractLine(ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem){
    	if (lineItem.ASI_CRM_Volume_Base__c == 'By Category'){
    		return lineItem.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
    	}
    	return lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c != null ? lineItem.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c : lineItem.ASI_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c;
    }
    
    //TODO: Bulkify this
    public static Decimal getModuleContractTotalByTax(Id moduleId){
    	Decimal result = 0;
    	//Get all lines
    	AggregateResult[] groupedResults = [SELECT SUM(ASI_CRM_CN_Contract_Total_Dummy__c) 
    										FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
    										WHERE ASI_CRM_Module__c = :moduleId]; 
    	
    	for (AggregateResult ar : groupedResults){
    		return (Decimal) ar.get('expr0');
    	}
    	return result;
    }
    
    public static Map<Id, Decimal> getModuleContractTotalByTax(List<Id> moduleIdList){
    	Map<Id, Decimal> result = new Map<Id, Decimal>();
    	
    	AggregateResult[] groupedResults = [SELECT ASI_CRM_Module__c, 
    											SUM(ASI_CRM_CN_Contract_Total_Dummy__c) 
    										FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
    										WHERE ASI_CRM_Module__c IN :moduleIdList
    										GROUP BY ASI_CRM_Module__c]; 
    										
		for (AggregateResult ar : groupedResults){
    		result.put((Id)ar.get('ASI_CRM_Module__c'), (Decimal) ar.get('expr0'));
    	}
    	return result;
    }
    
    //Check if current user is AD or Above
    public static Boolean checkUserID(){
        return checkUserADOrAbove(new List<Id>{UserInfo.getUserId()});
    }
    
    //Check if at least 1 approver is AD or Above
    public static Boolean checkApprover(String RecordId){
        Set<Id> actorIds = new Set<Id>();
        for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status = 'Pending' AND  ProcessInstance.TargetObjectId = :RecordId]){
            actorIds.add(piw.ActorId);
        }
        List<Id> actorIdList = new List<Id>();
        actorIdList.addAll(actorIds);
        return checkUserADOrAbove(actorIdList);
    }
    
    //Check if there are at least 1 user inside the list is AD or Above
    public static Boolean checkUserADOrAbove(List<Id> userOrGroupId){
    	Boolean AdorAbove = false;
    	
    	List<GroupMember> groupMemberList = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId IN :userOrGroupId];
        if(groupMemberList.size()>0){
            AdorAbove = true;
        }
        
        return AdorAbove;
    }
    
    public static Map<String,Decimal> fillMap(Map<String,Decimal> inputMap, String key, Decimal defaultValue){
    	if (inputMap == null) return null;
    	if (!inputMap.containsKey(key)){
    		inputMap.put(key,defaultValue);
    	}
    	return inputMap;
    }
    
    public static Decimal denullify(Decimal input, Double nullResult){
    	if (input == null) 
    		return nullResult;
    	else return input;
    }
    
    public static Decimal denullify(Decimal input, Integer nullResult){
    	return denullify(input, Double.valueOf(nullResult));
    }
}