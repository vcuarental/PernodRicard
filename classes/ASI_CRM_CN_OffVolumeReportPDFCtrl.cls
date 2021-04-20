/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffVolumeReportPDFCtrl
 * Description: Controller for Page ASI_CRM_CN_OffVolumeReportComp, ASI_CRM_CN_OffVolumeReportPDF
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-07       Hector Tsang          Created
 ****************************************************************************************************************************/


public class ASI_CRM_CN_OffVolumeReportPDFCtrl {
    public id currentHeaderId {set;get;}
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;} {ContractSelected= new ASI_TH_CRM_Contract__c();}
    public String StartDateStr {get; set;}{StartDateStr='';}
    public String EndDateStr {get; set;}{EndDateStr='';}
    public Date StartDate {get; set;}
    public Date EndDate {get; set;}
    public Date CutOffDay {get; set;}
    
    public Boolean isPOS {get; set;} {isPOS = false;}
    public Decimal markupPercent {get; set;} {markupPercent = 0;}
    public Boolean noData {get; set;} {noData=false;}
    public String POPeriodStr {set;get;} {POPeriodStr='';}
    public String SelectedPeriodStr {set;get;} {SelectedPeriodStr='';}
    public integer ContractPeriod {set;get;} {ContractPeriod=1;}
    
    
    public Map<String, interimData> GradeVolumeMap{set;get;} {GradeVolumeMap = new Map<String, interimData> ();}
    public Map<String, interimData> CategoryVolumeMap{set;get;} {CategoryVolumeMap = new Map<String, interimData> ();}//Product Category
    
    public Map<String, DataClass> OutletSummaryList_Map{set;get;} {OutletSummaryList_Map = new Map<String, DataClass> ();}
    public List<String> districtList{get; set;} {districtList = new List<String>{'South','SW','E','N','Central','NW'};}
    
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public Boolean DisplayIssueCapTable {set;get;} {DisplayIssueCapTable=true;}
    public ASI_CRM_CN_OffVolumeReportPDFCtrl(){ }
    public ASI_CRM_CN_OffVolumeReportPDFCtrl(ApexPages.StandardController controller) {}
    
    private final static List<String> RECORD_TYPE_LIST_AGGREGATION = new List<String> {
    	'ASI_CRM_CN_WS_Outlet_Brand_Monthly_Volume',
		'ASI_CRM_CN_WS_Outlet_Region_Monthly_Volume',
		'ASI_CRM_CN_WS_Outlet_Category_Monthly_Volume',
		'ASI_CRM_CN_WS_Outlet_CTD_Sub_Brand_Data',
		'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data'
	};
    
    public string ContractId {set;get;} {ContractId='';}
    
    /*  Initializate by following procedure
    	   	1. Get the Contract information
     		2. Initialize Contract data
    		3. Initialize Sub-brand Volume data
    		4. Aggregate Data by Loop
    */    
    public boolean init(){
        OutletSummaryList_Map = new Map<String, DataClass> ();
        
        StartDate = Date.valueOf(StartDateStr);
        EndDate = Date.valueOf(EndDateStr);
        CutOffDay = VolumeCutOffDate(1,EndDate, StartDate); //16
        CutOffDay = CutOffDay == null ? EndDate : CutOffDay; //16
        SelectedPeriodStr = ASI_CRM_DateUtilClass.toDMY(StartDate) + ' - ' + ASI_CRM_DateUtilClass.toDMY(CutOffDay);
        
        if(!Test.isRunningTest()){    
            ContractId = ApexPages.currentPage().getParameters().get('id');
        }
        
        
        if (currentHeaderId != null){
            ContractSelected = [SELECT id, Owner.Name, 
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
									ASI_CRM_Volume_Option__c,
                                    ASI_CRM_CN_Is_Dolphin__c
                                FROM ASI_TH_CRM_Contract__c  
                                WHERE Id = :currentHeaderId];


            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> lineItems = [
                SELECT
                    Id,
                    ASI_CRM_Module__r.ASI_CRM_CN_Total_Markup__c,
                    ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c
                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                WHERE ASI_CRM_CN_Contract__c = :currentHeaderId
                AND ASI_CRM_Type__c = 'BRSF'
            ];

            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : lineItems){
            	if (lineItem.ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c == 'POS'){
            		isPOS = true;
            	}
                if (lineItem.ASI_CRM_Module__r.ASI_CRM_CN_Total_Markup__c != null) {
                    markupPercent = lineItem.ASI_CRM_Module__r.ASI_CRM_CN_Total_Markup__c;
                }
            }
            
            
            POPeriodStr= ASI_CRM_DateUtilClass.toDMY(ContractSelected.ASI_CRM_CN_PO_Start_Date__c) + ' - ' + ASI_CRM_DateUtilClass.toDMY(ContractSelected.ASI_CRM_CN_PO_End_Date__c);
            init_Contractdata();
            init_SubBrandVolumeData();
            interimDataLooping();
            
            try{
                noData = false;
            } catch (exception e){ 
            	noData = true;
            }
        } else {
            ContractSelected = new ASI_TH_CRM_Contract__c();
            noData = true;
        }
        system.debug('GradeVolumeMap: ' + GradeVolumeMap);
        system.debug('CategoryVolumeMap: ' + CategoryVolumeMap);
        
        
        return true;   
    }
    
    
    
    public void init_Contractdata(){
        //Finding V0.0 contract Id
        String v0ContractId = '';
        String strRegion = '';
        String CommercialTeam = '';
        ContractPeriod= ASI_CRM_DateUtilClass.MonthDiff(StartDate, CutOffDay);
        if (ContractSelected != null && ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != null){ 
            v0ContractId = ContractSelected.ASI_CRM_CN_V0_0_PO_version__c;
            strRegion = ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c !=null? ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c: '';
            CommercialTeam= ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
        } else {
            v0ContractId = ContractSelected.id;
            strRegion= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
            CommercialTeam= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
            
            
        }
        
        //Get Contract detail Line 
        Set<Id> V00SubBrandIdSet = new Set<Id> ();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>  ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();
        try{            
            ContractLineList = [SELECT Id,
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
									ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Category__c,
									ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Convfactor_Ltocr12_C__c,
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
									ASI_CRM_CN_Sub_Brand__r.Name,
									ASI_CRM_Contract_Total_QTY_std_Btl__c,
									ASI_CRM_Type__c,
									RecordType.DeveloperName
                                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                WHERE ASI_CRM_CN_Contract__c = :v0ContractId];
        }catch(exception e){
            ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }
        
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine: ContractLineList){
            if (ContractLine.ASI_CRM_CN_Sub_Brand__c != null){
                V00SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c );
            }
        }
        
        //Build GradeVolumeMap
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine: ContractLineList){
        	    
            if(((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  || 
            	(ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' )) && 
                 ContractLine.ASI_CRM_CN_Sub_Brand__c!=null ){
                
                //By Sub-Brand Grade
                String SBGradeName='';
                decimal SBSortNo = 0;
                if (ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                    SBGradeName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    SBSortNo = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c;
                } else {
                    SBGradeName = 'Not Specified';
                    SBSortNo = null;
                }
                
                String SBGradeSort = ASI_CRM_CN_OffContractUtilitiesClass.NameSortingDESC(SBSortNo) + SBGradeName;
                
                //decimal conversionFactor9L = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c != null ? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c : 0.7;
                decimal conversionFactorCR12 = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Convfactor_Ltocr12_C__c != null ? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Convfactor_Ltocr12_C__c : 0;
                
	        	decimal contractVolTargetStd = ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c != null ? ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c : 0;
	            decimal contractPurchaseValue =  ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c != null ? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;

                    
                if(GradeVolumeMap.containsKey(SBGradeSort)){
                	interimData gradeVolumeLine = GradeVolumeMap.get(SBGradeSort);
                	if(gradeVolumeLine.SubBrandLine.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name)){
                        gradeVolumeLine.SubBrandLine.get(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name).TargetVol += contractVolTargetStd;
                        gradeVolumeLine.SubBrandLine.get(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name).TargetValue += contractPurchaseValue;
                    } else {//Don't contain this Sub-Brand
                        DataClass TempData = new DataClass();
                        TempData.sbname=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                        TempData.ConversionFactorCR12 = conversionFactorCR12;
                        TempData.TargetVol += contractVolTargetStd; 
                        TempData.TargetValue += contractPurchaseValue;
                        
                        gradeVolumeLine.SubBrandLine.put(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name,TempData);
                    }
                    
                    gradeVolumeLine.FullData.TargetVol += contractVolTargetStd; 
                    gradeVolumeLine.FullData.TargetValue += contractPurchaseValue;
                    
                    if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot( ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c )){
                    	//Martell
                    	gradeVolumeLine.MartellData.TargetVol += contractVolTargetStd; 
                    	gradeVolumeLine.MartellData.TargetValue += contractPurchaseValue;
                    } else {
                    	//Non-Martell
                    	gradeVolumeLine.NonMartellData.TargetVol += contractVolTargetStd; 
                    	gradeVolumeLine.NonMartellData.TargetValue += contractPurchaseValue; 
                    }
                } else {
                	//Don't contain, create new line
                    DataClass TempData = new DataClass();
                    TempData.sbname=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    TempData.ConversionFactorCR12 = conversionFactorCR12;
                    TempData.TargetVol += contractVolTargetStd; 
                    TempData.TargetValue += contractPurchaseValue;
                        
                    interimData SubBrandData= new interimData(); // high
                    SubBrandData.SequenceNum = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c!=null?Integer.valueOf(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c):7;
                    SubBrandData.SubBrandLine.put(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name,TempData);
                    SubBrandData.SubBrandGradeName = SBGradeName;
                    SubBrandData.FullData.TargetVol += contractVolTargetStd; 
                    SubBrandData.FullData.TargetValue += contractPurchaseValue; 
                    
                    if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot( ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c )){//Martell
                        SubBrandData.MartellData.TargetVol += contractVolTargetStd; 
                    	SubBrandData.MartellData.TargetValue += contractPurchaseValue; 
                    } else {
                        SubBrandData.NonMartellData.TargetVol += contractVolTargetStd; 
                    	SubBrandData.NonMartellData.TargetValue += contractPurchaseValue; 
                    }
                    
                    GradeVolumeMap.put(SBGradeSort, SubBrandData);
                }
                
                
                //****************By Sub-Brand Grade Category****************
                String SortingName='';
                decimal SortingNumber = 0;
                if (ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Category__c != null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c != null){
                    SortingName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Category__c;
                    SortingNumber = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c;//ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c;
                } else {
                    SortingName = 'Not Specified';
                    SortingNumber = null;
                }
                String CategoryName = ASI_CRM_CN_OffContractUtilitiesClass.NameSortingASC(SortingNumber) + SortingName;
                interimData categoryVolumeLine = CategoryVolumeMap.containsKey(CategoryName) ? CategoryVolumeMap.get(CategoryName) : new interimData();
                categoryVolumeLine.CategoryName=SortingName;
                categoryVolumeLine.SequenceNum =(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c != null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c != null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c!=null ) ? Integer.valueOf(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c):7;

                categoryVolumeLine.FullData.TargetVol += contractVolTargetStd;
                categoryVolumeLine.FullData.TargetValue += contractPurchaseValue;

                DataClass subBrandData = categoryVolumeLine.SubBrandLine.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name)? categoryVolumeLine.SubBrandLine.get(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name) : new DataClass();
                subBrandData.sbname = ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                subBrandData.ConversionFactorCR12 = conversionFactorCR12;
                subBrandData.TargetVol += contractVolTargetStd;
                subBrandData.TargetValue += contractPurchaseValue;
                subBrandData.GradeSequence = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c != null? Integer.valueOf(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c):7;

                categoryVolumeLine.SubBrandLine.put(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name,subBrandData);




                if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c =='COG'){ //Martell
                    categoryVolumeLine.MartellData.TargetVol += contractVolTargetStd;
                    categoryVolumeLine.MartellData.TargetValue += contractPurchaseValue;
                } else {
                    categoryVolumeLine.NonMartellData.TargetVol += contractVolTargetStd;
                    categoryVolumeLine.NonMartellData.TargetValue += contractPurchaseValue;
                }

                CategoryVolumeMap.put(CategoryName, categoryVolumeLine);

                //CategoryVolumeMap
            }
        }
    }
    
    //Loading WS/Outlet Sub-brand Volume
    public void init_SubBrandVolumeData(){
        set<id> OutletIdSet = generatingOutletId();
        list<ASI_CRM_Subbrand_Volume__c> Contract_SBVolList = new List<ASI_CRM_Subbrand_Volume__c>(); //getSubbrandVolume(OutletIdSet);
        
        String subBrandVolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';
        subBrandVolumeQuery += 'WHERE ASI_CRM_Subbrand__c !=null ' + 
                               'AND ASI_CRM_CN_Competitor_Sub_brand__c != true ' +
                               'AND ASI_CRM_End_Date__c >= ' + String.ValueOf(StartDate) + ' ' +
                               'AND ASI_CRM_End_Date__c <= ' + String.ValueOf(CutOffDay) + ' ' +
                               'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = false ';
        
        if (OutletIdSet.size() >= ASI_CRM_CN_OffContractUtilitiesClass.outletThreshold()){
        	subBrandVolumeQuery += 'AND ASI_CRM_CN_Contract__c = \'' + ContractSelected.Id + '\' ' +
        							'AND recordtypeId = \'' + Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data')+'\' ';
            
        	
        } else {
        	subBrandVolumeQuery += 'AND ASI_CRM_Account__c !=null ' + 
        							'AND ASI_CRM_Account__c IN :OutletIdSet ' +
        							'AND recordType.DeveloperName NOT IN :RECORD_TYPE_LIST_AGGREGATION ';
                                                         
        }
        System.debug(LoggingLevel.INFO, '*** OutletIdSet: ' + OutletIdSet);
        system.debug('subBrandVolumeQuery: ' + subBrandVolumeQuery);
        if(Test.isRunningTest()){subBrandVolumeQuery = 'SELECT ' + SubBrandFieldList() + ' FROM ASI_CRM_Subbrand_Volume__c ';}
        //Contract_SBVolList = Database.Query(subBrandVolumeQuery);
        
        //Subbrand Volume 
        for (ASI_CRM_Subbrand_Volume__c SubBrandVolume : Database.Query(subBrandVolumeQuery) ){
            
            //By Sub-Brand Grade
            DataClass CalVolume = CalculatingVolume(isPOS, SubBrandVolume);
            GradeMappingHandling(SubBrandVolume,CalVolume);
            CategoryMappingHandling(SubBrandVolume,CalVolume);
            
            OutletSummaryMappingHandling(SubBrandVolume,CalculatingVolume(isPOS, SubBrandVolume));
        }
        
    }
    
    
    public void OutletSummaryMappingHandling(ASI_CRM_Subbrand_Volume__c SubBrandVolume, DataClass CalVolume){
        String ChiName= SubBrandVolume.ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c!=null?SubBrandVolume.ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c:SubBrandVolume.ASI_CRM_Account__r.Name;
        
        if(OutletSummaryList_Map.containsKey(ChiName)){
            OutletSummaryList_Map.get(ChiName).OffTakeVol+= CalVolume.OffTakeVol;
            OutletSummaryList_Map.get(ChiName).IntakeVol+= CalVolume.IntakeVol;
            
            OutletSummaryList_Map.get(ChiName).OffTakeVolCR12 += CalVolume.OffTakeVolCR12;
            OutletSummaryList_Map.get(ChiName).IntakeVolCR12+= CalVolume.IntakeVolCR12;
        }
        
    }
    
    public void GradeMappingHandling(ASI_CRM_Subbrand_Volume__c SubBrandVolume, DataClass CalVolume){
        
        String SBName = SubBrandVolume.ASI_CRM_Subbrand__r.Name;
        decimal SBSortNo = 0;
        String SBGradeName='';
        if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
            SBGradeName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            SBSortNo = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c;
        } else {
            SBGradeName = 'Not Specified';
            SBSortNo = null;
        }
        
        String SBGradeSort = ASI_CRM_CN_OffContractUtilitiesClass.NameSortingDESC(SBSortNo) + SBGradeName;
        
        if(GradeVolumeMap.containsKey(SBGradeSort)){
        	InterimData gradeVolumeLine = GradeVolumeMap.get(SBGradeSort);
            if(gradeVolumeLine.SubBrandLine.containsKey(SubBrandVolume.ASI_CRM_Subbrand__r.Name)){

                DataClass TempVolumeData  =CopyDataClass(gradeVolumeLine.SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name));
                gradeVolumeLine.SubBrandLine.remove(SubBrandVolume.ASI_CRM_Subbrand__r.Name);
                
                TempVolumeData = AddIntakeDataClass(TempVolumeData, CalVolume);
                TempVolumeData = AddOfftakeDataClass(TempVolumeData, CalVolume);

                gradeVolumeLine.SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,TempVolumeData);

            } else { //not in the sub-brand List
                DataClass TempVolumeData = CopyDataClass(CalVolume);
                gradeVolumeLine.SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,TempVolumeData);//system.debug('debug2.0:'+SubBrandVolume.ASI_CRM_Subbrand__r.Name+CalVolume.BtlCollection);
            }
            
            gradeVolumeLine.FullData.OffTakeVol+= CalVolume.OffTakeVol;
            gradeVolumeLine.FullData.OfftakeValue+= CalVolume.OfftakeValue;
            
            gradeVolumeLine.FullData.IntakeVol+= CalVolume.IntakeVol;
            gradeVolumeLine.FullData.IntakeValue+= CalVolume.IntakeValue;
            
            
            if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot( SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c )){//Martell
                gradeVolumeLine.MartellData=AggregateDataClass(gradeVolumeLine.MartellData, CalVolume);
            } else {
                gradeVolumeLine.NonMartellData =AggregateDataClass(gradeVolumeLine.NonMartellData, CalVolume);
            }
        } else { // not contain 
            interimData SubBrandData= new interimData();
            SubBrandData.SequenceNum = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c!=null?Integer.valueOf(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c):7;
            
            SubBrandData.SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,CalVolume);
            SubBrandData.FullData=CopyDataClass(CalVolume);
            
            if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot( SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c )){//Martell
                SubBrandData.MartellData=CopyDataClass(CalVolume);
            } else {
                SubBrandData.NonMartellData =CopyDataClass(CalVolume);
            }
            SubBrandData.SubBrandGradeName = SBGradeName;
            GradeVolumeMap.put(SBGradeSort, SubBrandData);
        }
              
    }
    
    private DataClass AlignDataClassSBInfo (DataClass InputDataClass, DataClass AddSourceDataClass){
        InputDataClass.sbgrade = AddSourceDataClass.sbgrade;
        InputDataClass.sbname = AddSourceDataClass.sbname;
        return InputDataClass;
    }

    private DataClass AddIntakeDataClass (DataClass InputDataClass, DataClass AddSourceDataClass){
        InputDataClass.IntakeVol+= AddSourceDataClass.IntakeVol;
        InputDataClass.IntakeVolCR12 += AddSourceDataClass.IntakeVolCR12;
        InputDataClass.IntakeValue += AddSourceDataClass.IntakeValue;
        return InputDataClass;
    }
    
    private DataClass AddOfftakeDataClass (DataClass InputDataClass, DataClass AddSourceDataClass){
        InputDataClass.OffTakeVol += AddSourceDataClass.OffTakeVol;
        InputDataClass.OfftakeVolCR12 += AddSourceDataClass.OfftakeVolCR12;
        InputDataClass.OfftakeValue+= AddSourceDataClass.OfftakeValue;
        return InputDataClass;
    }
    
    private DataClass AggregateDataClass (DataClass InputDataClass, DataClass AddSourceDataClass){
    	InputDataClass = AlignDataClassSBInfo(InputDataClass, AddSourceDataClass);
    	InputDataClass = AddIntakeDataClass(InputDataClass, AddSourceDataClass);
    	InputDataClass = AddOfftakeDataClass(InputDataClass, AddSourceDataClass);
    	return InputDataClass;
    }
        
    public void CategoryMappingHandling(ASI_CRM_Subbrand_Volume__c SubBrandVolume, DataClass CalVolume){
        
        String SBName = SubBrandVolume.ASI_CRM_Subbrand__r.Name;
        
        String SortingName='';
        Decimal SortingNumber = 0;
        
        if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Category__c != null && SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null){
            SortingName =SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Category__c;
            SortingNumber = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c;//ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c;
        } else {
            SortingName = 'Not Specified';
            SortingNumber = null;
        }


        String CategoryName = ASI_CRM_CN_OffContractUtilitiesClass.NameSortingASC(SortingNumber) + SortingName;

        if (SubBrandVolume.ASI_CRM_Subbrand__r.Name.contains('杰卡斯酿酒师臻选系列')) {
            System.debug('CategoryName' + CategoryName);
            System.debug('SubBrandVolume iid ' + SubBrandVolume.Id);
            System.debug('CalVolume ' + CalVolume);
            System.debug('CalVolume.IntakeVol ' + CalVolume.IntakeVol);
        }
        
        if(CategoryVolumeMap.containsKey(CategoryName)){
            if(CategoryVolumeMap.get(CategoryName).SubBrandLine.containsKey(SubBrandVolume.ASI_CRM_Subbrand__r.Name)){

                DataClass tempData = CopyDataClass(CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name));
                
                CategoryVolumeMap.get(CategoryName).SubBrandLine.remove(SubBrandVolume.ASI_CRM_Subbrand__r.Name);
                
                tempData.OffTakeVol+= CalVolume.OffTakeVol;
                tempData.OffTakeVolCR12+= CalVolume.OffTakeVolCR12;
                tempData.OfftakeValue+= CalVolume.OfftakeValue;
                
                tempData.IntakeVol+= CalVolume.IntakeVol;
                tempData.IntakeVolCR12+= CalVolume.IntakeVolCR12;
                tempData.IntakeValue+= CalVolume.IntakeValue;
                
                
                
                CategoryVolumeMap.get(CategoryName).SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name, tempData );
                

            } else { //not in the sub-brand List
                CategoryVolumeMap.get(CategoryName).SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,CopyDataClass(CalVolume));
            }
            
            CategoryVolumeMap.get(CategoryName).FullData.OffTakeVol+= CalVolume.OffTakeVol;
            CategoryVolumeMap.get(CategoryName).FullData.OffTakeVolCR12 += CalVolume.OffTakeVolCR12;
            CategoryVolumeMap.get(CategoryName).FullData.OfftakeValue+= CalVolume.OfftakeValue;
            CategoryVolumeMap.get(CategoryName).FullData.IntakeVol+= CalVolume.IntakeVol;
            CategoryVolumeMap.get(CategoryName).FullData.IntakeVolCR12 += CalVolume.IntakeVolCR12;
            CategoryVolumeMap.get(CategoryName).FullData.IntakeValue+= CalVolume.IntakeValue;
        } else { // not contain 
            interimData CategoryData= new interimData();
            CategoryData.SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,CalVolume);
            CategoryData.FullData=CopyDataClass(CalVolume);
            CategoryData.CategoryName=SortingName;
            CategoryVolumeMap.put(CategoryName, CategoryData);
            
        }
    }
   
    //If BRSF Volume Base = POS, override OffTakeVolume with POS data
    private DataClass CalculatingVolume(Boolean isPOS, ASI_CRM_Subbrand_Volume__c sbtemp){
        DataClass ReturnData = new DataClass();
        ReturnData.sbname=sbtemp.ASI_CRM_Subbrand__r.Name;
        ReturnData.sbgrade=sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
        ReturnData.GradeSequence = Integer.ValueOf(sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c);
        ReturnData.ConversionFactorCR12 = sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Convfactor_Ltocr12_C__c != null ? sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Convfactor_Ltocr12_C__c : 0;
        
        if (isPOS) {
        	ReturnData.OffTakeVol = sbtemp.ASI_CRM_POS_Std_Billing__c!=null? sbtemp.ASI_CRM_POS_Std_Billing__c.round(System.RoundingMode.FLOOR): 0;
        	ReturnData.OffTakeVolCR12 = sbtemp.ASI_CRM_POS_CR12__c!=null? sbtemp.ASI_CRM_POS_CR12__c.round(System.RoundingMode.FLOOR): 0;
        	ReturnData.OfftakeValue = sbtemp.ASI_CRM_POS_GS__c!=null? (sbtemp.ASI_CRM_POS_GS__c * (1 + markupPercent / 100)).round(System.RoundingMode.FLOOR): 0;
        } else if (ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
            ReturnData.OffTakeVol = sbtemp.ASI_CRM_Green_ORS_Std_Billing__c!=null? sbtemp.ASI_CRM_Green_ORS_Std_Billing__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OffTakeVol += sbtemp.ASI_CRM_Empty_Bottle_Std_Billing__c!=null? sbtemp.ASI_CRM_Empty_Bottle_Std_Billing__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OffTakeVolCR12 = sbtemp.ASI_CRM_Green_ORS_CR12__c!=null? sbtemp.ASI_CRM_Green_ORS_CR12__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OffTakeVolCR12 += sbtemp.ASI_CRM_Empty_Bottle_CR12__c!=null? sbtemp.ASI_CRM_Empty_Bottle_CR12__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OfftakeValue = sbtemp.ASI_CRM_Green_ORS_GS__c!=null? (sbtemp.ASI_CRM_Green_ORS_GS__c * (1 + markupPercent / 100)).round(System.RoundingMode.FLOOR): 0;
            ReturnData.OfftakeValue += sbtemp.ASI_CRM_Empty_Bottle_GS__c!=null? (sbtemp.ASI_CRM_Empty_Bottle_GS__c * (1 + markupPercent / 100)).round(System.RoundingMode.FLOOR): 0;
        } else {
            ReturnData.OffTakeVol = sbtemp.ASI_CRM_Offtake_Std_Billing__c!=null? sbtemp.ASI_CRM_Offtake_Std_Billing__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OffTakeVolCR12 = sbtemp.ASI_CRM_Offtake_CR12__c!=null? sbtemp.ASI_CRM_Offtake_CR12__c.round(System.RoundingMode.FLOOR): 0;
            ReturnData.OfftakeValue = sbtemp.ASI_CRM_Offtake_GS__c!=null? (sbtemp.ASI_CRM_Offtake_GS__c * (1 + markupPercent / 100)).round(System.RoundingMode.FLOOR): 0;
        }
        
        ReturnData.IntakeVol += sbtemp.ASI_CRM_Actual_Vol_STD__c.round(System.RoundingMode.FLOOR);
        ReturnData.IntakeVolCR12 += sbtemp.ASI_CRM_Actual_Vol_CR12__c.round(System.RoundingMode.FLOOR);
        ReturnData.IntakeValue += sbtemp.ASI_CRM_CN_Intake_GS_T1_Price__c!=null? (sbtemp.ASI_CRM_CN_Intake_GS_T1_Price__c * (1 + markupPercent / 100)): 0;

        return ReturnData;
    }
    
    
    
    //Calculate interimData 
    public void interimDataLooping(){
        for (string SubBrandGradeKey : GradeVolumeMap.keyset()){
        	InterimData gradeVolumeLine = gradeVolumeMap.get(SubBrandGradeKey);
            for(string  SubBrandKey: GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.keyset()){
            	DataClass gradeVolumeSubbrandLine = gradeVolumeLine.SubBrandLine.get(SubBrandKey);
                gradeVolumeSubbrandLine.IntakeVol = DataRounding(gradeVolumeSubbrandLine.IntakeVol);
                gradeVolumeSubbrandLine.IntakeValue = DataRounding(gradeVolumeSubbrandLine.IntakeValue);
                gradeVolumeSubbrandLine.OffTakeVol = DataRounding(gradeVolumeSubbrandLine.OffTakeVol);
                gradeVolumeSubbrandLine.OfftakeValue = DataRounding(gradeVolumeSubbrandLine.OfftakeValue);
                gradeVolumeSubbrandLine.TargetVol = DataRounding(gradeVolumeSubbrandLine.TargetVol);
                gradeVolumeSubbrandLine.TargetValue = DataRounding(gradeVolumeSubbrandLine.TargetValue);
                
                gradeVolumeSubbrandLine.OffTakeVol= gradeVolumeSubbrandLine.OffTakeVol.setScale(0);
                gradeVolumeSubbrandLine.OfftakeValue= gradeVolumeSubbrandLine.OfftakeValue.setScale(0);
                gradeVolumeSubbrandLine.IntakeVol=gradeVolumeSubbrandLine.IntakeVol.setScale(0);
                gradeVolumeSubbrandLine.IntakeValue=gradeVolumeSubbrandLine.IntakeValue.setScale(0);
            }
        }
        
        
        for (string CategoryName : CategoryVolumeMap.keyset()){
        	InterimData categoryVolumeLine = CategoryVolumeMap.get(CategoryName);
            for(string  SubBrandKey: CategoryVolumeMap.get(CategoryName).SubBrandLine.keyset()){
            	DataClass categoryVolumeSubbrandLine = categoryVolumeLine.SubBrandLine.get(SubBrandKey);
                categoryVolumeSubbrandLine.IntakeVol= DataRounding(categoryVolumeSubbrandLine.IntakeVol);
                categoryVolumeSubbrandLine.IntakeValue= DataRounding(categoryVolumeSubbrandLine.IntakeValue);
                categoryVolumeSubbrandLine.OffTakeVol= DataRounding(categoryVolumeSubbrandLine.OffTakeVol);
                categoryVolumeSubbrandLine.OfftakeValue= DataRounding(categoryVolumeSubbrandLine.OfftakeValue);
                categoryVolumeSubbrandLine.TargetVol= DataRounding(categoryVolumeSubbrandLine.TargetVol);
                categoryVolumeSubbrandLine.TargetValue= DataRounding(categoryVolumeSubbrandLine.TargetValue);                
            }
            
            categoryVolumeLine.FullData.IntakeVol = DataRounding(categoryVolumeLine.FullData.IntakeVol);
            categoryVolumeLine.FullData.IntakeValue = DataRounding(categoryVolumeLine.FullData.IntakeValue);
            
            categoryVolumeLine.FullData.OffTakeVol = DataRounding(categoryVolumeLine.FullData.OffTakeVol);
            categoryVolumeLine.FullData.OfftakeValue = DataRounding(categoryVolumeLine.FullData.OfftakeValue);
            
            categoryVolumeLine.FullData.TargetVol = DataRounding(categoryVolumeLine.FullData.TargetVol);
            categoryVolumeLine.FullData.TargetValue = DataRounding(categoryVolumeLine.FullData.TargetValue);   
        }
    }
    
    
    
    
    private set<id> generatingOutletId(){
        list<ASI_CRM_CN_Covered_Outlet__c>  CoveredOutlet_List = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet_List = [SELECT ASI_CRM_CN_Outlet__c,
            							ASI_CRM_CN_Outlet__r.Name,
            							ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c
                                  FROM ASI_CRM_CN_Covered_Outlet__c
                                  WHERE ASI_CRM_CN_Contract__c = :ContractSelected.id 
                                  ORDER BY ASI_CRM_CN_Outlet__r.Name ASC];
        }catch(exception e){
            CoveredOutlet_List = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }
        set<id> OutletIdSet = new set<id>();
        
        
        if (ContractSelected.ASI_CRM_Volume_Option__c == 'Normal' || 
        		ContractSelected.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || 
        		ContractSelected.ASI_CRM_Volume_Option__c == null){
            OutletIdSet.add(ContractSelected.ASI_CRM_CN_Outlet_WS__c); 
            String ChiName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c!=null?ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c:ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name;
            DataClass TempData= new DataClass();
            OutletSummaryList_Map.put(ChiName,TempData);
        }
        
        if (ContractSelected.ASI_CRM_Volume_Option__c == 'Normal' || ContractSelected.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || ContractSelected.ASI_CRM_Volume_Option__c == null){
            for (ASI_CRM_CN_Covered_Outlet__c co_temp : CoveredOutlet_List){
                OutletIdSet.add(co_temp.ASI_CRM_CN_Outlet__c);
                String ChiName=co_temp.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c!=null? co_temp.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c:co_temp.ASI_CRM_CN_Outlet__r.Name;
                if(!OutletSummaryList_Map.containsKey(ChiName)){
                    DataClass TempData= new DataClass();
                    OutletSummaryList_Map.put(ChiName,TempData);
                }
            }
        }
        
        return OutletIdSet;
        
    }
    
    
    

    private Decimal DataRounding(Decimal InputData){
        InputData=InputData!=null?InputData.setScale(0):0;
        return InputData;
    }
    
    private Decimal DataRounding(Decimal InputData, Integer setScale){
    	InputData=InputData!=null?InputData.setScale(setScale):0;
        return InputData;
    }
    
    //1 level
    public class interimData{
        public String SubBrandGradeName {set;get;} {SubBrandGradeName='';}
        public String CategoryName  {set;get;}{CategoryName='';}
        
        //All
        public DataClass FullData {set;get;} {FullData=new DataClass();} // its own level with all Martell and non-Martell
        public DataClass MartellData {set;get;} {MartellData=new DataClass();} // With Martell Volume Data
        public DataClass NonMartellData {set;get;} {NonMartellData=new DataClass();} //  With non-Martell Volume Data
        
        //Child Level
        public Map<String,DataClass> SubBrandLine {set;get;} {SubBrandLine= new Map<String,DataClass> ();}
        public Integer SequenceNum {set;get;}  {SequenceNum=9;}
        public interimData(){}
    }
    
    
    
    
    //2 Level- Base data structure
    public class DataClass{
        public string sbname {get; set;}{sbname='';}
        public string sbgrade {get; set;}{sbgrade='';}
        public Integer GradeSequence {get; set;}  {GradeSequence=9;}
        
        public decimal TargetVol {get; set;} {TargetVol=0;}
        public decimal OffTakeVol {get; set;} {OffTakeVol=0;}
        public decimal IntakeVol {get; set;} {IntakeVol=0;}
        
        public decimal TargetValue {get; set;} {TargetValue=0;}
        public decimal OfftakeValue {get; set;} {OfftakeValue=0;}
        public decimal IntakeValue {get; set;} {IntakeValue=0;}
        
        public decimal ConversionFactorCR12 {get; set;}
        
        public decimal TargetVolCR12 {
        	get{
        		return convertStdToCR12(TargetVol);
        	} 
        	private set;
        }
        public decimal OffTakeVolCR12 {get; set;} {OffTakeVolCR12=0;}
        public decimal IntakeVolCR12 {get; set;} {IntakeVolCR12=0;}
        
        
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
        
        public decimal IntakeVSContractVolPercentage {
        	get {
        		return ratio(this.IntakeVol,this.TargetVol);
        	}
        	private set;
        }
        
        public decimal OffTakeVSIntakeVolPercentage {
        	get {
        		return ratio(this.OffTakeVol,this.IntakeVol);
        	}
        	private set;
        }
        
        public decimal IntakeVSOffTakeVolPercentage {
            get {
                return ratio(this.IntakeVol,this.OffTakeVol);
            }
            private set;
        }
        public decimal OffTakeVSContractVolPercentage {
            get {
                return ratio(this.OffTakeVol,this.TargetVol);
            }
            private set;
        }
        public decimal IntakeVSContractValuePercentage {
        	get {
        		return ratio(this.IntakeValue,this.TargetValue);
        	}
        	private set;
        }
        
        public decimal OffTakeVSIntakeValuePercentage {
        	get {
        		return ratio(this.OfftakeValue,this.IntakeValue);
        	}
        	private set;
        }
        public decimal IntakeVSOffTakeValuePercentage {
            get {
                return ratio(this.IntakeValue,this.OfftakeValue);
            }
            private set;
        }
        public decimal OffTakeVSContractValuePercentage {
            get {
                return ratio(this.OfftakeValue,this.TargetValue);
            }
            private set;
        }        
        private decimal convertStdToCR12(Decimal std){
        	return (this.ConversionFactorCR12 != null) ? std * ConversionFactorCR12 : 0;
        }
        
        private decimal ratio(Decimal numerator, Decimal denominator){
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
    
    
    
    public map<string, string> mapStringMonth = new map<string, string>{
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
     
     public static date VolumeCutOffDate(integer strDay, date defaultDate, date startdate){
        Date returnDate;
        Integer strDate = Date.Today().Day();
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
			'ASI_CRM_Account__r.Name',
			'ASI_CRM_Actual_Vol_CR12__c',
			'ASI_CRM_Actual_Vol_STD__c',
			'ASI_CRM_CN_Intake_GS_T1_Price__c',
			'ASI_CRM_Offtake_GS__c',
			'ASI_CRM_POS_GS__c',
			'ASI_CRM_Empty_Bottle_CR12__c',
            'ASI_CRM_POS_Std_Billing__c',
			'ASI_CRM_Empty_Bottle_Std_Billing__c',
			'ASI_CRM_Month__c',
			'ASI_CRM_Offtake_CR12__c',
			'ASI_CRM_Offtake_Std_Billing__c',
			'ASI_CRM_POS_CR12__c',
			'ASI_CRM_Green_ORS_Std_Billing__c',
            'ASI_CRM_Green_ORS_GS__c',
            'ASI_CRM_Green_ORS_CR12__c',
            'ASI_CRM_Empty_Bottle_GS__c',
			'ASI_CRM_PR_Direct_CR12__c',
			'ASI_CRM_PR_Direct_STD_Billing__c',
			'ASI_CRM_Penalty_Coefficient_Applied__c',
			'ASI_CRM_Subbrand__c',
			'ASI_CRM_Subbrand__r.ASI_CRM_CN_Category__c',
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
			'ASI_CRM_Subbrand__r.Name',
			'ASI_CRM_T1_Depletion_CR12__c',
			'ASI_CRM_T1_Depletion_STD_Billing__c',
			'ASI_CRM_T2_Depletion_CR12__c',
			'ASI_CRM_T2_Depletion_STD_Billing__c',
			'ASI_CRM_Year__c'
    	};
    	return String.join(fieldList,',');
    }           
}