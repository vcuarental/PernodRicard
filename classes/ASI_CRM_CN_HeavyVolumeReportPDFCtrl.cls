/* Filename:    ASI_CRM_CN_HeavyVolumeReportPDFCtrl.cls
* Author:       Laputa
* Purpose:      Controller Volume Report
* ASI_CRM_CN_HeavyVolumeReportComp ,  ASI_CRM_CN_HeavyVolumeReportPDF
* Copyright 2017 Laputa Limited. All rights reserved.
* Customer confidential. Do not distribute.

* History     
* -----------------------------------------------------------------------------
* 2017-09-06    Laputa      Created

*/


public class ASI_CRM_CN_HeavyVolumeReportPDFCtrl {
    public id currentHeaderId {set;get;}
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;} {ContractSelected= new ASI_TH_CRM_Contract__c();}
    public String StartDateStr {get; set;}{StartDateStr='';}
    public String EndDateStr {get; set;}{EndDateStr='';}
    public Date StartDate {get; set;}
    public Date EndDate {get; set;}
    public Date CutOffDay {get; set;}
    
    public Boolean noData {get; set;} {noData=false;}
    public String POPeriodStr {set;get;} {POPeriodStr='';}
    public String SelectedPeriodStr {set;get;} {SelectedPeriodStr='';}
    public integer ContractPeriod {set;get;} {ContractPeriod=1;}
    
    
    public Map<String, interimData> GradeVolumeMap{set;get;} {GradeVolumeMap = new Map<String, interimData> ();}
    public Map<String, interimData> CategoryVolumeMap{set;get;} {CategoryVolumeMap = new Map<String, interimData> ();}//Product Category
    
    public Map<String, Map<String, List<DataClass>>> IssueCapMap{set;get;} {IssueCapMap = new Map<String, Map<String, List<DataClass>>>();}
    
    public Map<String, Map<String, DataClass>> TotalIssueCapMap{set;get;} {TotalIssueCapMap = new Map<String, Map<String, DataClass>>();}
    
    public Map<String, DataClass> OutletSummaryList_Map{set;get;} {OutletSummaryList_Map = new Map<String, DataClass> ();}
    
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public Boolean DisplayIssueCapTable {set;get;} {DisplayIssueCapTable=true;}
    public ASI_CRM_CN_HeavyVolumeReportPDFCtrl(){ }
    public ASI_CRM_CN_HeavyVolumeReportPDFCtrl(ApexPages.StandardController controller) {
    }
    
    
    public string ContractId {set;get;} {ContractId='';}
    
    public boolean init(){
        OutletSummaryList_Map = new Map<String, DataClass> ();
        
        StartDate = Date.valueOf(StartDateStr);
        EndDate = Date.valueOf(EndDateStr);
        CutOffDay = ASI_CRM_CN_HeavyContractUtilitiesClass.VolumeCutOffDate(1,EndDate, StartDate); //16
        SelectedPeriodStr = ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(StartDate) + ' - ' + ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(CutOffDay);
        
        if(!Test.isRunningTest()){    
            ContractId = ApexPages.currentPage().getParameters().get('id');
        }
        
        
        if (currentHeaderId != null){
            ContractSelected = [SELECT id,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name, ASI_CRM_Volume_Option__c, ASI_CRM_CN_Region__c, Owner.Name, ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_New_FY_PO__c,ASI_CRM_PO_Channel__r.Name,ASI_CRM_PO_Province__r.Name ,ASI_CRM_PO_City__c  ,ASI_CRM_PO_City__r.Name ,ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c 
                                FROM ASI_TH_CRM_Contract__c  WHERE Id = :currentHeaderId];
            
            POPeriodStr= ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(ContractSelected.ASI_CRM_CN_PO_Start_Date__c) + ' - ' + ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertDate(ContractSelected.ASI_CRM_CN_PO_End_Date__c);
            init_Contractdata();
            init_SubBrandVolumeData();
            interimDataLooping();
            
            
            if(IssueCapMap.size()==0){
                DisplayIssueCapTable=false;
            }
            
            try{
                noData = false;
            }catch(exception e){ noData = true;}
        }else{
            ContractSelected = new ASI_TH_CRM_Contract__c();
            noData = true;
        }
        
        
        return true;   
    }
    
    
    
    
    
    public void init_Contractdata(){
        //Finding V0.0 contract Id
        String v0ContractId='';
        String strRegion ='';
        String CommercialTeam ='';
        ContractPeriod= ASI_CRM_CN_HeavyContractUtilitiesClass.ConvertPeriod(StartDate, CutOffDay);
        if (ContractSelected != null && ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != null){ 
            v0ContractId = ContractSelected.ASI_CRM_CN_V0_0_PO_version__c;
            strRegion = ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c !=null? ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c: '';
            CommercialTeam= ContractSelected.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
            
        }else{
            v0ContractId = ContractSelected.id;
            strRegion= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != null? ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c :'';
            CommercialTeam= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null?ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
            
            
        }
        
        //Get Contract detail Line 
        Set<Id> V00SubBrandIdSet = new Set<Id> ();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>  ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();
        try{            
            ContractLineList = [SELECT Id,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name, RecordType.DeveloperName,ASI_CRM_Type__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c, ASI_CRM_CN_Contract_Monthly_Qty__c
                                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                WHERE ASI_CRM_CN_Contract__c = :v0ContractId];
        }catch(exception e){
            ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }
        //ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c
        //ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c
        
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine: ContractLineList){
            if (ContractLine.ASI_CRM_CN_Sub_Brand__c != null){
                V00SubBrandIdSet.add(ContractLine.ASI_CRM_CN_Sub_Brand__c );
            }
        }
        
        
        
        
        //Get CR12 Factor
        Map<String,Decimal> CR12FactorMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCR12FactorMap(V00SubBrandIdSet, CommercialTeam, strRegion);
        
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine: ContractLineList){
            //if (ContractLine.ASI_CRM_CN_Sub_Brand__c != null){
            if( ((ContractLine.RecordType.DeveloperName =='ASI_CRM_CN_Contract_BRSF_Line_Item')  ||
                 (ContractLine.RecordType.DeveloperName =='ASI_CRM_CRM_CN_Contract_Heavy_BRSF' && ContractLine.ASI_CRM_Type__c=='BRSF' ) ) && ContractLine.ASI_CRM_CN_Sub_Brand__c!=null )
            {
                
                Decimal CR12Factor=1;
                if(CR12FactorMap.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__c)){
                    CR12Factor=CR12FactorMap.get(ContractLine.ASI_CRM_CN_Sub_Brand__c);
                }
                
                //By Sub-Brand Grade
                String SBGradeName='';
                decimal SBSortNo = 0;
                if (ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                    SBGradeName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    SBSortNo = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c;
                }else{
                    SBGradeName = 'Not Specified';
                    SBSortNo = null;
                }
                
                String SBGradeSort = ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(SBSortNo) + SBGradeName;
                
                if(GradeVolumeMap.containsKey(SBGradeSort)){
                    if(GradeVolumeMap.get(SBGradeSort).SubBrandLine.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name)){
                        GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name).TargetVol+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name).TargetVolCR12+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor : 0; 
                    }else{//Don't contain this Sub-Brand
                        DataClass TempData = new DataClass();
                        TempData.sbname=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                        TempData.TargetVol+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        TempData.TargetVolCR12+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null?  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor : 0; 
                        GradeVolumeMap.get(SBGradeSort).SubBrandLine.put(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name,TempData);
                    }
                    GradeVolumeMap.get(SBGradeSort).VolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                    GradeVolumeMap.get(SBGradeSort).VolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    
                    if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot( ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c )){//Martell
                        GradeVolumeMap.get(SBGradeSort).MartellVolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        GradeVolumeMap.get(SBGradeSort).MartellVolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    }else{
                        GradeVolumeMap.get(SBGradeSort).PureVolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        GradeVolumeMap.get(SBGradeSort).PureVolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    }
                
                }else{//Don't contain
                    DataClass TempData = new DataClass();
                    TempData.sbname=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    TempData.TargetVol+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                    TempData.TargetVolCR12+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null?  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor : 0; 
                    
                    interimData SubBrandData= new interimData(); // high
                    SubBrandData.SequenceNum = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c!=null?Integer.valueOf(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c):7;
                    SubBrandData.SubBrandLine.put(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name,TempData);
                    SubBrandData.SubBrandGradeName = SBGradeName;
                    SubBrandData.VolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                    SubBrandData.VolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor : 0; 
                    
                    if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot( ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c )){//Martell
                       
                        SubBrandData.MartellVolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        SubBrandData.MartellVolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    }else{
                        SubBrandData.PureVolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        SubBrandData.PureVolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    }
                    
                    GradeVolumeMap.put(SBGradeSort, SubBrandData);
                }
                
                
                //****************By Sub-Brand Grade Category****************
                String SortingName='';
                decimal SortingNumber = 0;
                if (ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c != null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c != null){
                    SortingName = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name;//ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                    SortingNumber = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c;//ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c;
                }else{
                    SortingName = 'Not Specified';
                    SortingNumber = null;
                }
                String CategoryName = ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(SortingNumber) + SortingName;                
                
                if(CategoryVolumeMap.containsKey(CategoryName)){
                    if(CategoryVolumeMap.get(CategoryName).SubBrandLine.containsKey(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name)){
                        CategoryVolumeMap.get(CategoryName).SubBrandLine.get(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name).TargetVol+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        CategoryVolumeMap.get(CategoryName).SubBrandLine.get(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name).TargetVolCR12+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor : 0; 
                    }else{//Don't contain this Sub-Brand---> New Sub-Brand
                        DataClass TempData = new DataClass();
                        TempData.sbname=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                        TempData.TargetVol+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        TempData.TargetVolCR12+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null?  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor : 0; 
                        TempData.GradeSequence = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c!=null?Integer.valueOf(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c):7;
                    
                        CategoryVolumeMap.get(CategoryName).SubBrandLine.put(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name,TempData);
                    }
                    CategoryVolumeMap.get(CategoryName).VolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                    CategoryVolumeMap.get(CategoryName).VolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c =='COG'){ //Martell 
                        CategoryVolumeMap.get(CategoryName).MartellVolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        CategoryVolumeMap.get(CategoryName).MartellVolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    }else{
                        CategoryVolumeMap.get(CategoryName).PureVolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        CategoryVolumeMap.get(CategoryName).PureVolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    }
                }else{//Don't contain
                    DataClass TempData = new DataClass();
                    TempData.sbname=ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    TempData.TargetVol+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                    TempData.TargetVolCR12+= ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null?  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor : 0; 
                    TempData.GradeSequence = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c!=null?Integer.valueOf(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c):7;
                    
                    
                    interimData CategoryData= new interimData(); //high ---> New Sub-Brand
                    CategoryData.CategoryName=SortingName;
                    CategoryData.SequenceNum =(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__c != null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c != null && ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c!=null ) ? Integer.valueOf(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c):7;
                    
                    CategoryData.SubBrandLine.put(ContractLine.ASI_CRM_CN_Sub_Brand__r.Name,TempData);
                    CategoryData.VolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                    CategoryData.VolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor : 0; 
                    
                    if(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c =='COG'){ //Martell 
                        CategoryData.MartellVolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        CategoryData.MartellVolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    }else{
                        CategoryData.PureVolumeData.TargetVol += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c: 0; 
                        CategoryData.PureVolumeData.TargetVolCR12 += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractLine.ASI_CRM_CN_No_of_Months__c * CR12Factor: 0; 
                    }
                    
                    CategoryVolumeMap.put(CategoryName, CategoryData);
                }
                //CategoryVolumeMap
            }
        }
    }
    
    //Loading WS/Outlet Sub-brand Volume
    public void init_SubBrandVolumeData(){
        set<id> OutletIdSet = generatingOutletId();
        list<ASI_CRM_Subbrand_Volume__c> Contract_SBVolList = GettingSubbrandVolume(OutletIdSet);
        
        //Subbrand Volume 
        for (ASI_CRM_Subbrand_Volume__c SubBrandVolume : Contract_SBVolList ){
            
            //By Sub-Brand Grade
            DataClass CalVolume = CalculatingVolume(SubBrandVolume);
            
            GradeMappingHandling(SubBrandVolume,CalVolume);
            
            CategoryMappingHandling(SubBrandVolume,CalVolume);
            
            
            OutletSummaryMappingHandling(SubBrandVolume,CalculatingVolume(SubBrandVolume));
            
            if(CalVolume.CapwithIssues!=0 || CalVolume.DeductibleCapswithIssues!=0 || CalVolume.PenaltyCoefficient!=0 ){
                IssueCapMappingHandling(SubBrandVolume,CalVolume);
                TotalIssueCapMappingHandling(SubBrandVolume,CalVolume);
            }
            
        }
        
    }
    
    
    public void OutletSummaryMappingHandling(ASI_CRM_Subbrand_Volume__c SubBrandVolume, DataClass CalVolume){
        String ChiName= SubBrandVolume.ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c!=null?SubBrandVolume.ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c:SubBrandVolume.ASI_CRM_Account__r.Name;
        
        if(OutletSummaryList_Map.containsKey(ChiName)){
            OutletSummaryList_Map.get(ChiName).OffTakeVol+= CalVolume.OffTakeVol;
            OutletSummaryList_Map.get(ChiName).IntakeVol+= CalVolume.IntakeVol;
            OutletSummaryList_Map.get(ChiName).BtlCollection+= CalVolume.BtlCollection;
        }
        
    }
    
    public void GradeMappingHandling(ASI_CRM_Subbrand_Volume__c SubBrandVolume, DataClass CalVolume){
        
        String SBName = SubBrandVolume.ASI_CRM_Subbrand__r.Name;
        decimal SBSortNo = 0;
        String SBGradeName='';
        if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
            SBGradeName = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            SBSortNo = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c;
        }else{
            SBGradeName = 'Not Specified';
            SBSortNo = null;
        }
        
        String SBGradeSort = ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(SBSortNo) + SBGradeName;
        
        system.debug(SBGradeSort+ SubBrandVolume.ASI_CRM_Subbrand__r.Name + ' Intake Vol : '+CalVolume.IntakeVol);
        if(GradeVolumeMap.containsKey(SBGradeSort)){
            if(GradeVolumeMap.get(SBGradeSort).SubBrandLine.containsKey(SubBrandVolume.ASI_CRM_Subbrand__r.Name)){//system.debug('debug4.0:'+GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).BtlCollection);
                system.debug(' Now enter A: Old Value'+GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).IntakeVol);
                
                DataClass TempVolumeData  =CopyDataClass(GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name));
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.remove(SubBrandVolume.ASI_CRM_Subbrand__r.Name);
                
                TempVolumeData.OffTakeVol+= CalVolume.OffTakeVol;
                TempVolumeData.OffTakeVolCR12+= CalVolume.OffTakeVolCR12;
                TempVolumeData.IntakeVol+= CalVolume.IntakeVol;
                TempVolumeData.IntakeVolCR12+= CalVolume.IntakeVolCR12;
                TempVolumeData.BtlCollection+= CalVolume.BtlCollection;
                TempVolumeData.BtlCollectionCR12+= CalVolume.BtlCollectionCR12;
                TempVolumeData.CapwithIssues+= CalVolume.CapwithIssues;
                TempVolumeData.CapwithIssuesCR12+= CalVolume.CapwithIssuesCR12;                
                TempVolumeData.DeductibleCapswithIssues+= CalVolume.DeductibleCapswithIssues;
                TempVolumeData.DeductibleCapswithIssuesCR12+= CalVolume.DeductibleCapswithIssuesCR12;
                
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,TempVolumeData);
                /*
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).OffTakeVol+= CalVolume.OffTakeVol;
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).OffTakeVolCR12+= CalVolume.OffTakeVolCR12;
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).IntakeVol+= CalVolume.IntakeVol;
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).IntakeVolCR12+= CalVolume.IntakeVolCR12;
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).BtlCollection+= CalVolume.BtlCollection;
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).BtlCollectionCR12+= CalVolume.BtlCollectionCR12;
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).CapwithIssues+= CalVolume.CapwithIssues;
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).CapwithIssuesCR12+= CalVolume.CapwithIssuesCR12;                
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).DeductibleCapswithIssues+= CalVolume.DeductibleCapswithIssues;
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).DeductibleCapswithIssuesCR12+= CalVolume.DeductibleCapswithIssuesCR12;
                */
                system.debug(' Now IntakeVol A: '+GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).IntakeVol);
            }else{ //not in the sub-brand List
                DataClass TempVolumeData  =CopyDataClass(CalVolume);
                GradeVolumeMap.get(SBGradeSort).SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,TempVolumeData);//system.debug('debug2.0:'+SubBrandVolume.ASI_CRM_Subbrand__r.Name+CalVolume.BtlCollection);
                
                system.debug(' Now IntakeVol B: '+GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).IntakeVol);
            }
            
            GradeVolumeMap.get(SBGradeSort).VolumeData.OffTakeVol+= CalVolume.OffTakeVol;
            GradeVolumeMap.get(SBGradeSort).VolumeData.OffTakeVolCR12+= CalVolume.OffTakeVolCR12;
            GradeVolumeMap.get(SBGradeSort).VolumeData.IntakeVol+= CalVolume.IntakeVol;
            GradeVolumeMap.get(SBGradeSort).VolumeData.IntakeVolCR12+= CalVolume.IntakeVolCR12;
            GradeVolumeMap.get(SBGradeSort).VolumeData.BtlCollection+= CalVolume.BtlCollection;
            GradeVolumeMap.get(SBGradeSort).VolumeData.BtlCollectionCR12+= CalVolume.BtlCollectionCR12;
            GradeVolumeMap.get(SBGradeSort).VolumeData.CapwithIssues+= CalVolume.CapwithIssues;
            GradeVolumeMap.get(SBGradeSort).VolumeData.CapwithIssuesCR12+= CalVolume.CapwithIssuesCR12;
            GradeVolumeMap.get(SBGradeSort).VolumeData.DeductibleCapswithIssues+= CalVolume.DeductibleCapswithIssues;
            GradeVolumeMap.get(SBGradeSort).VolumeData.DeductibleCapswithIssuesCR12+= CalVolume.DeductibleCapswithIssuesCR12;
            
            if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot( SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c )){//Martell
                GradeVolumeMap.get(SBGradeSort).MartellVolumeData=AggregateDataClass(GradeVolumeMap.get(SBGradeSort).MartellVolumeData, CalVolume);
                system.debug(SubBrandVolume.ID+'T123: '+SBGradeName+CalVolume.BtlCollectionCR12);
            }else{
                GradeVolumeMap.get(SBGradeSort).PureVolumeData =AggregateDataClass(GradeVolumeMap.get(SBGradeSort).PureVolumeData, CalVolume);
            }
        }else{ // not contain 
            interimData SubBrandData= new interimData();
            SubBrandData.SequenceNum = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c!=null?Integer.valueOf(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c):7;
            
            SubBrandData.SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,CalVolume);
            SubBrandData.VolumeData=CopyDataClass(CalVolume);
            
            if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot( SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c )){//Martell
                SubBrandData.MartellVolumeData=CopyDataClass(CalVolume);
                system.debug(SubBrandVolume.ID+'T123: '+SBGradeName+CalVolume.BtlCollectionCR12);
            }else{
                SubBrandData.PureVolumeData =CopyDataClass(CalVolume);
            }
            SubBrandData.SubBrandGradeName = SBGradeName;
            GradeVolumeMap.put(SBGradeSort, SubBrandData);//system.debug('debug3.0:'+SubBrandVolume.ASI_CRM_Subbrand__r.Name+CalVolume.BtlCollection);
            system.debug(' Now IntakeVol C: '+GradeVolumeMap.get(SBGradeSort).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).IntakeVol);
            
            
            
        }
              
    }
    
    
    private DataClass AggregateDataClass (DataClass InputCalVolume, DataClass AddOnVolume){
        InputCalVolume.sbgrade= AddOnVolume.sbgrade;
        InputCalVolume.sbname= AddOnVolume.sbname;
        
        InputCalVolume.OffTakeVol += AddOnVolume.OffTakeVol;
        InputCalVolume.OffTakeVolCR12+= AddOnVolume.OffTakeVolCR12;
        InputCalVolume.IntakeVol+= AddOnVolume.IntakeVol;
        InputCalVolume.IntakeVolCR12+= AddOnVolume.IntakeVolCR12;
        
        InputCalVolume.BtlCollection+= AddOnVolume.BtlCollection;
        
        InputCalVolume.BtlCollectionCR12+= AddOnVolume.BtlCollectionCR12;
        InputCalVolume.CapwithIssues+= AddOnVolume.CapwithIssues;
        InputCalVolume.CapwithIssuesCR12+= AddOnVolume.CapwithIssuesCR12;
        InputCalVolume.DeductibleCapswithIssues+= AddOnVolume.DeductibleCapswithIssues;
        InputCalVolume.DeductibleCapswithIssuesCR12+= AddOnVolume.DeductibleCapswithIssuesCR12;
        
        return InputCalVolume;
    }
    
    
    
    public DataClass CopyDataClass(DataClass InputCalVolume){
        DataClass TempVolumeData = new DataClass();
        TempVolumeData.sbgrade= InputCalVolume.sbgrade;
        TempVolumeData.sbname= InputCalVolume.sbname;
        
        TempVolumeData.TargetVol= InputCalVolume.TargetVol;
        TempVolumeData.TargetVolCR12= InputCalVolume.TargetVolCR12;
        
        TempVolumeData.OffTakeVol= InputCalVolume.OffTakeVol;
        TempVolumeData.OffTakeVolCR12= InputCalVolume.OffTakeVolCR12;
        TempVolumeData.IntakeVol= InputCalVolume.IntakeVol;
        TempVolumeData.IntakeVolCR12= InputCalVolume.IntakeVolCR12;
        TempVolumeData.BtlCollection= InputCalVolume.BtlCollection;
        TempVolumeData.BtlCollectionCR12= InputCalVolume.BtlCollectionCR12;
        TempVolumeData.CapwithIssues= InputCalVolume.CapwithIssues;
        TempVolumeData.CapwithIssuesCR12= InputCalVolume.CapwithIssuesCR12;
        TempVolumeData.DeductibleCapswithIssues= InputCalVolume.DeductibleCapswithIssues;
        TempVolumeData.DeductibleCapswithIssuesCR12= InputCalVolume.DeductibleCapswithIssuesCR12;
        TempVolumeData.PenaltyCoefficient= InputCalVolume.PenaltyCoefficient;
        
        
        return TempVolumeData;
    }
    
    
    
    private DataClass CombinedVolumeData(DataClass OldCalVolume , DataClass NewCalVolume){
        DataClass NewIssueCapData = new DataClass();
        NewIssueCapData.sbname= OldCalVolume.sbname;
        
        NewIssueCapData.CapwithIssues =OldCalVolume.CapwithIssues+NewCalVolume.CapwithIssues;
        NewIssueCapData.CapwithIssuesCR12= OldCalVolume.CapwithIssuesCR12+NewCalVolume.CapwithIssuesCR12;
        NewIssueCapData.DeductibleCapswithIssues =OldCalVolume.DeductibleCapswithIssues+NewCalVolume.DeductibleCapswithIssues;
        NewIssueCapData.DeductibleCapswithIssuesCR12 =OldCalVolume.DeductibleCapswithIssuesCR12+NewCalVolume.DeductibleCapswithIssuesCR12;
        NewIssueCapData.PenaltyCoefficient = OldCalVolume.PenaltyCoefficient+NewCalVolume.PenaltyCoefficient;
        
        
        
        return NewIssueCapData;
    }
    
    
    public void TotalIssueCapMappingHandling(ASI_CRM_Subbrand_Volume__c SubBrandVolume, DataClass CalVolume){
        
        //Total 
        if(TotalIssueCapMap.containsKey(SubBrandVolume.ASI_CRM_Account__r.Name)){
            if(TotalIssueCapMap.get(SubBrandVolume.ASI_CRM_Account__r.Name).containsKey(SubBrandVolume.ASI_CRM_Subbrand__r.Name)){
                DataClass TempIssueCapData =CombinedVolumeData( TotalIssueCapMap.get(SubBrandVolume.ASI_CRM_Account__r.Name).get(SubBrandVolume.ASI_CRM_Subbrand__r.Name), CalVolume);
                
                TotalIssueCapMap.get(SubBrandVolume.ASI_CRM_Account__r.Name).remove(SubBrandVolume.ASI_CRM_Subbrand__r.Name);
                TotalIssueCapMap.get(SubBrandVolume.ASI_CRM_Account__r.Name).put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,TempIssueCapData);
            }else{
                TotalIssueCapMap.get(SubBrandVolume.ASI_CRM_Account__r.Name).put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,CopyDataClass(CalVolume));   
            }
        }else{
            Map<String,DataClass> TempDataClassMap = new Map<String,DataClass>();
            TempDataClassMap.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,CopyDataClass(CalVolume)); 
            
            
            TotalIssueCapMap.put(SubBrandVolume.ASI_CRM_Account__r.Name,TempDataClassMap);
        }
        
    }    
    
    
    
    
    //IssueCapMap
    public void IssueCapMappingHandling(ASI_CRM_Subbrand_Volume__c SubBrandVolume, DataClass CalVolume){
        String KeyName='';
        if(SubBrandVolume.ASI_CRM_Month__c !=null){
            if(mapStringMonth.containsKey(SubBrandVolume.ASI_CRM_Month__c)){
                KeyName+=mapStringMonth.get(SubBrandVolume.ASI_CRM_Month__c) +'-';
            }
        }
        KeyName += SubBrandVolume.ASI_CRM_Year__c!=null? SubBrandVolume.ASI_CRM_Year__c:'';
        if(IssueCapMap.containsKey(KeyName)){
            if(IssueCapMap.get(KeyName).containsKey(SubBrandVolume.ASI_CRM_Account__r.Name)){
                IssueCapMap.get(KeyName).get(SubBrandVolume.ASI_CRM_Account__r.Name).add(CalVolume);
            }else{
                List<DataClass> DataList= new List<DataClass>();
                DataList.add(CalVolume);
                IssueCapMap.get(KeyName).put(SubBrandVolume.ASI_CRM_Account__r.Name, DataList);
            }
        }else{
            List<DataClass> DataList= new List<DataClass>();
            DataList.add(CalVolume);
            Map<String,List<DataClass>> TempDataClassMap = new Map<String,List<DataClass>>();
            TempDataClassMap.put(SubBrandVolume.ASI_CRM_Account__r.Name, DataList);
            IssueCapMap.put(KeyName, TempDataClassMap);
        }//system.debug(KeyName+SubBrandVolume.ASI_CRM_Account__r.Name +SubBrandVolume.ASI_CRM_Subbrand__r.Name+' ** '+  ' CapwithIssues'+CalVolume.CapwithIssues);system.debug(IssueCapMap.get(KeyName).get(SubBrandVolume.ASI_CRM_Account__r.Name)) ;     
    }
    
    
    public void CategoryMappingHandling(ASI_CRM_Subbrand_Volume__c SubBrandVolume, DataClass CalVolume){
        
        String SBName = SubBrandVolume.ASI_CRM_Subbrand__r.Name;
        
        String SortingName='';
        Decimal SortingNumber = 0;
        
        if(SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c != null && SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c !=null){
            SortingName =SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name;// SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
            SortingNumber = SubBrandVolume.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c;//ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c;
        }else{
            SortingName = 'Not Specified';
            SortingNumber = null;
        }
        system.debug('CategoryMappingHandling A: '+CalVolume.IntakeVol);
        
        String CategoryName = ASI_CRM_CN_HeavyContractUtilitiesClass.NameSorting(SortingNumber) + SortingName;
        
        if(CategoryVolumeMap.containsKey(CategoryName)){
            if(CategoryVolumeMap.get(CategoryName).SubBrandLine.containsKey(SubBrandVolume.ASI_CRM_Subbrand__r.Name)){
               // system.debug('*Finished GradeMappingHandling '+GradeVolumeMap.get('99994Premium').SubBrandLine.get('绝对伏特加(原味) Absolut Blue-AB1').IntakeVol);
                //system.debug(CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name));
                DataClass tempData =CopyDataClass(CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name));
                
                CategoryVolumeMap.get(CategoryName).SubBrandLine.remove(SubBrandVolume.ASI_CRM_Subbrand__r.Name);
                
                tempData.OffTakeVol+= CalVolume.OffTakeVol;
                tempData.OffTakeVolCR12+= CalVolume.OffTakeVolCR12;
                tempData.IntakeVol+= CalVolume.IntakeVol;
                tempData.IntakeVolCR12+= CalVolume.IntakeVolCR12;
                tempData.BtlCollection+= CalVolume.BtlCollection;
                tempData.BtlCollectionCR12+= CalVolume.BtlCollectionCR12;
                tempData.CapwithIssues+= CalVolume.CapwithIssues;
                tempData.CapwithIssuesCR12+= CalVolume.CapwithIssuesCR12;
                
                CategoryVolumeMap.get(CategoryName).SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name, tempData );
                
                
                //system.debug('*Finished GradeMappingHandling '+GradeVolumeMap.get('99994Premium').SubBrandLine.get('绝对伏特加(原味) Absolut Blue-AB1').IntakeVol);
               /*
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).OffTakeVol+= CalVolume.OffTakeVol;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).OffTakeVolCR12+= CalVolume.OffTakeVolCR12;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).IntakeVol+= CalVolume.IntakeVol;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).IntakeVolCR12+= CalVolume.IntakeVolCR12;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).BtlCollection+= CalVolume.BtlCollection;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).BtlCollectionCR12+= CalVolume.BtlCollectionCR12;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).CapwithIssues+= CalVolume.CapwithIssues;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandVolume.ASI_CRM_Subbrand__r.Name).CapwithIssuesCR12+= CalVolume.CapwithIssuesCR12;
               */
                
            }else{ //not in the sub-brand List
                CategoryVolumeMap.get(CategoryName).SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,CopyDataClass(CalVolume));
            }
            
            CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVol+= CalVolume.OffTakeVol;
            CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVolCR12+= CalVolume.OffTakeVolCR12;
            CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVol+= CalVolume.IntakeVol;
            CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVolCR12+= CalVolume.IntakeVolCR12;
            CategoryVolumeMap.get(CategoryName).VolumeData.BtlCollection+= CalVolume.BtlCollection;
            CategoryVolumeMap.get(CategoryName).VolumeData.BtlCollectionCR12+= CalVolume.BtlCollectionCR12;
            CategoryVolumeMap.get(CategoryName).VolumeData.CapwithIssues+= CalVolume.CapwithIssues;
            CategoryVolumeMap.get(CategoryName).VolumeData.CapwithIssuesCR12+= CalVolume.CapwithIssuesCR12;
        }else{ // not contain 
            interimData CategoryData= new interimData();
            CategoryData.SubBrandLine.put(SubBrandVolume.ASI_CRM_Subbrand__r.Name,CalVolume);
            CategoryData.VolumeData=CopyDataClass(CalVolume);
            CategoryData.CategoryName=SortingName;
            CategoryVolumeMap.put(CategoryName, CategoryData);
            
        }
        system.debug('CategoryMappingHandling B: '+CalVolume.IntakeVol);
    }
    
    
    
    
    
    
    //Description   :  Calculate Sub-Brand Volume Data
    Private DataClass CalculatingVolume(ASI_CRM_Subbrand_Volume__c sbtemp){
        DataClass ReturnData = new DataClass();
        ReturnData.sbname=sbtemp.ASI_CRM_Subbrand__r.Name;
        ReturnData.sbgrade=sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
        
        //off take
        ReturnData.OffTakeVol = sbtemp.ASI_CRM_Offtake_Std_Billing__c!=null? sbtemp.ASI_CRM_Offtake_Std_Billing__c.round(System.RoundingMode.FLOOR): 0;
        ReturnData.OffTakeVolCR12 = sbtemp.ASI_CRM_Offtake_CR12__c!=null? sbtemp.ASI_CRM_Offtake_CR12__c.round(System.RoundingMode.FLOOR): 0;
        
        //Intake
        Decimal IntakeVolTemp =0;
        IntakeVolTemp+= sbtemp.ASI_CRM_T1_Depletion_STD_Billing__c!=null? sbtemp.ASI_CRM_T1_Depletion_STD_Billing__c: 0;
        IntakeVolTemp+= sbtemp.ASI_CRM_T2_Depletion_STD_Billing__c!=null? sbtemp.ASI_CRM_T2_Depletion_STD_Billing__c: 0;
        IntakeVolTemp+= sbtemp.ASI_CRM_PR_Direct_STD_Billing__c!=null? sbtemp.ASI_CRM_PR_Direct_STD_Billing__c: 0;
        
        
        ReturnData.IntakeVol += IntakeVolTemp.round(System.RoundingMode.FLOOR);
            
        Decimal IntakeCR12Temp = 0 ;    
        IntakeCR12Temp += sbtemp.ASI_CRM_T1_Depletion_CR12__c!=null? sbtemp.ASI_CRM_T1_Depletion_CR12__c: 0;
        IntakeCR12Temp += sbtemp.ASI_CRM_T2_Depletion_CR12__c!=null? sbtemp.ASI_CRM_T2_Depletion_CR12__c: 0;
        IntakeCR12Temp += sbtemp.ASI_CRM_PR_Direct_CR12__c!=null? sbtemp.ASI_CRM_PR_Direct_CR12__c: 0;
        ReturnData.IntakeVolCR12 += IntakeCR12Temp.round(System.RoundingMode.FLOOR);
        
        //Bottle Collection
        ReturnData.BtlCollection = sbtemp.ASI_CRM_Bottle_Collected__c!=null? sbtemp.ASI_CRM_Bottle_Collected__c.round(System.RoundingMode.FLOOR): 0;
        ReturnData.BtlCollectionCR12  =sbtemp.ASI_CRM_Bottle_Collected_CR12__c!=null? sbtemp.ASI_CRM_Bottle_Collected_CR12__c.round(System.RoundingMode.FLOOR): 0; 
        
        ReturnData.CapwithIssues = sbtemp.ASI_CRM_Cap_with_Issues_Std_Billing__c!=null? sbtemp.ASI_CRM_Cap_with_Issues_Std_Billing__c.round(System.RoundingMode.FLOOR): 0;
        ReturnData.CapwithIssuesCR12= sbtemp.ASI_CRM_Cap_with_Issues_CR12__c!=null? sbtemp.ASI_CRM_Cap_with_Issues_CR12__c.round(System.RoundingMode.FLOOR): 0;
        
        //ASI_CRM_Cap_with_Issues_CR12__c
        //
        ReturnData.DeductibleCapswithIssues = sbtemp.ASI_CRM_DeductCapWithIssue_StdBill__c!=null? sbtemp.ASI_CRM_DeductCapWithIssue_StdBill__c.round(System.RoundingMode.FLOOR): 0;
        ReturnData.DeductibleCapswithIssuesCR12 = sbtemp.ASI_CRM_Deductible_Cap_with_Issues_CR12__c!=null? sbtemp.ASI_CRM_Deductible_Cap_with_Issues_CR12__c.round(System.RoundingMode.FLOOR): 0;
        
        ReturnData.PenaltyCoefficient = sbtemp.ASI_CRM_Penalty_Coefficient_Applied__c!=null? sbtemp.ASI_CRM_Penalty_Coefficient_Applied__c.round(System.RoundingMode.FLOOR): 0;
        
        return ReturnData;
    }
    
    
    
    //Calculate interimData 
    public void interimDataLooping(){
        for (string SubBrandGradeKey : GradeVolumeMap.keyset()){
            for(string  SubBrandKey: GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.keyset()){
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVol =DataRounding(GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVol);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVolCR12 =DataRounding(GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVolCR12);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVol =DataRounding(GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVol);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVolCR12 =DataRounding(GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVolCR12);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVol =DataRounding(GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVol);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVolCR12 =DataRounding(GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVolCR12);
                
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVol= GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVol.setScale(0);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVolCR12= GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVolCR12.setScale(0);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVol=GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVol.setScale(0);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVolCR12=GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVolCR12.setScale(0);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollection= GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollection.setScale(0);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollectionCR12= GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollectionCR12.setScale(0);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CapwithIssues= GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CapwithIssues.setScale(0);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CapwithIssuesCR12= GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CapwithIssuesCR12.setScale(0);
                
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).DeductibleCapswithIssues= GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).DeductibleCapswithIssues.setScale(0);
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).DeductibleCapswithIssuesCR12= GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).DeductibleCapswithIssuesCR12.setScale(0);
                
                
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVSIntake = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVol / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVol )*100 : 0;
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CollectionVSOfftake = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVol )*100 : 0;
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CollectionVSIntake = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVol )*100 : 0;
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CollectionVSContract = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVol )*100 : 0;
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVSContract = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVol / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVol )*100 : 0;
                
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVSIntakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVolCR12 / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVolCR12 )*100 : 0;
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CollectionVSOfftakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).OffTakeVolCR12 )*100 : 0;
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CollectionVSIntakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVolCR12 )*100 : 0;
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).CollectionVSContractCR12 = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVolCR12 )*100 : 0;
                GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVSContractCR12 = GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).IntakeVolCR12 / GradeVolumeMap.get(SubBrandGradeKey).SubBrandLine.get(SubBrandKey).TargetVolCR12 )*100 : 0;
                
            }
           
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.OffTakeVSIntake = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.OffTakeVol / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.CollectionVSOfftake = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.OffTakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.OffTakeVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.CollectionVSIntake = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.CollectionVSContract = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.TargetVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.TargetVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVSContract = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.TargetVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVol / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.TargetVol )*100 : 0;
            
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.OffTakeVSIntakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.OffTakeVolCR12 / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.CollectionVSOfftakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.OffTakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.OffTakeVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.CollectionVSIntakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.CollectionVSContractCR12 = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.TargetVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.TargetVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVSContractCR12 = GradeVolumeMap.get(SubBrandGradeKey).VolumeData.TargetVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).VolumeData.IntakeVolCR12 / GradeVolumeMap.get(SubBrandGradeKey).VolumeData.TargetVolCR12 )*100 : 0;
            
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.OffTakeVSIntake = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.OffTakeVol / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.CollectionVSOfftake = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.OffTakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.OffTakeVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.CollectionVSIntake = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.CollectionVSContract = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.TargetVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.TargetVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVSContract = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.TargetVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVol / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.TargetVol )*100 : 0;
            
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.OffTakeVSIntakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.OffTakeVolCR12 / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.CollectionVSOfftakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.OffTakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.OffTakeVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.CollectionVSIntakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.CollectionVSContractCR12 = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.TargetVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.TargetVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVSContractCR12 = GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.TargetVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.IntakeVolCR12 / GradeVolumeMap.get(SubBrandGradeKey).MartellVolumeData.TargetVolCR12 )*100 : 0;
            
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.OffTakeVSIntake = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.OffTakeVol / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.CollectionVSOfftake = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.OffTakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.OffTakeVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.CollectionVSIntake = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.CollectionVSContract = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.TargetVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.BtlCollection / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.TargetVol )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVSContract = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.TargetVol !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVol / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.TargetVol )*100 : 0;
            
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.OffTakeVSIntakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.OffTakeVolCR12 / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.CollectionVSOfftakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.OffTakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.OffTakeVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.CollectionVSIntakeCR12 = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.CollectionVSContractCR12 = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.TargetVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.BtlCollectionCR12 / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.TargetVolCR12 )*100 : 0;
            GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVSContractCR12 = GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.TargetVolCR12 !=0? (GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.IntakeVolCR12 / GradeVolumeMap.get(SubBrandGradeKey).PureVolumeData.TargetVolCR12 )*100 : 0;
            
        }
        
        
        for (string CategoryName : CategoryVolumeMap.keyset()){
            for(string  SubBrandKey: CategoryVolumeMap.get(CategoryName).SubBrandLine.keyset()){
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVol= DataRounding(CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVol);
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVolCR12= DataRounding(CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVolCR12);
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVol= DataRounding(CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVol);
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVolCR12= DataRounding(CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVolCR12);
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVol= DataRounding(CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVol);
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVolCR12= DataRounding(CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVolCR12);
                
                
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVSIntake = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVol !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVol / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVol )*100 : 0;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).CollectionVSOfftake = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVol !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).BtlCollection / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVol )*100 : 0;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).CollectionVSIntake = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVol !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).BtlCollection / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVol )*100 : 0;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).CollectionVSContract = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVol !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).BtlCollection / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVol )*100 : 0;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVSContract = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVol !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVol / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVol )*100 : 0;
                
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVSIntakeCR12 = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVolCR12 / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVolCR12 )*100 : 0;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).CollectionVSOfftakeCR12 = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).BtlCollectionCR12 / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).OffTakeVolCR12 )*100 : 0;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).CollectionVSIntakeCR12 = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).BtlCollectionCR12 / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVolCR12 )*100 : 0;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).CollectionVSContractCR12 = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).BtlCollectionCR12 / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVolCR12 )*100 : 0;
                CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVSContractCR12 = CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).IntakeVolCR12 / CategoryVolumeMap.get(CategoryName).SubBrandLine.get(SubBrandKey).TargetVolCR12 )*100 : 0;
                
            }
            
            CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVol = DataRounding(CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVol);
            CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVolCR12 = DataRounding(CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVolCR12);
            
            CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVol = DataRounding(CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVol);
            CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVolCR12 = DataRounding(CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVolCR12);
            
            CategoryVolumeMap.get(CategoryName).VolumeData.TargetVol = DataRounding(CategoryVolumeMap.get(CategoryName).VolumeData.TargetVol);
            CategoryVolumeMap.get(CategoryName).VolumeData.TargetVolCR12 = DataRounding(CategoryVolumeMap.get(CategoryName).VolumeData.TargetVolCR12);
            
            CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVSIntake = CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVol !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVol / CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVol )*100 : 0;
            CategoryVolumeMap.get(CategoryName).VolumeData.CollectionVSOfftake = CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVol !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.BtlCollection / CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVol )*100 : 0;
            CategoryVolumeMap.get(CategoryName).VolumeData.CollectionVSIntake = CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVol !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.BtlCollection / CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVol )*100 : 0;
            CategoryVolumeMap.get(CategoryName).VolumeData.CollectionVSContract = CategoryVolumeMap.get(CategoryName).VolumeData.TargetVol !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.BtlCollection / CategoryVolumeMap.get(CategoryName).VolumeData.TargetVol )*100 : 0;
            CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVSContract = CategoryVolumeMap.get(CategoryName).VolumeData.TargetVol !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVol / CategoryVolumeMap.get(CategoryName).VolumeData.TargetVol )*100 : 0;
            
            CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVSIntakeCR12 = CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVolCR12 / CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVolCR12 )*100 : 0;
            CategoryVolumeMap.get(CategoryName).VolumeData.CollectionVSOfftakeCR12 = CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.BtlCollectionCR12 / CategoryVolumeMap.get(CategoryName).VolumeData.OffTakeVolCR12 )*100 : 0;
            CategoryVolumeMap.get(CategoryName).VolumeData.CollectionVSIntakeCR12 = CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.BtlCollectionCR12 / CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVolCR12 )*100 : 0;
            CategoryVolumeMap.get(CategoryName).VolumeData.CollectionVSContractCR12 = CategoryVolumeMap.get(CategoryName).VolumeData.TargetVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.BtlCollectionCR12 / CategoryVolumeMap.get(CategoryName).VolumeData.TargetVolCR12 )*100 : 0;
            CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVSContractCR12 = CategoryVolumeMap.get(CategoryName).VolumeData.TargetVolCR12 !=0? (CategoryVolumeMap.get(CategoryName).VolumeData.IntakeVolCR12 / CategoryVolumeMap.get(CategoryName).VolumeData.TargetVolCR12 )*100 : 0;
            
        }
        
        
    }
    
    
    
    
    private set<id> generatingOutletId(){
        list<ASI_CRM_CN_Covered_Outlet__c>  CoveredOutlet_List = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet_List = [SELECT ASI_CRM_CN_Outlet__c,ASI_CRM_CN_Outlet__r.Name,ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c
                                  FROM ASI_CRM_CN_Covered_Outlet__c
                                  WHERE ASI_CRM_CN_Contract__c = :ContractSelected.id ORDER BY ASI_CRM_CN_Outlet__r.Name ASC];
        }catch(exception e){
            CoveredOutlet_List = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }
        set<id> OutletIdSet = new set<id>();
        
        
        if (ContractSelected.ASI_CRM_Volume_Option__c == 'Normal' || ContractSelected.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || ContractSelected.ASI_CRM_Volume_Option__c == null){
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
    
    
    
    //Geting ASI_CRM_Subbrand_Volume__c 
    private list<ASI_CRM_Subbrand_Volume__c> GettingSubbrandVolume(Set<Id> OutletSet){
        list<ASI_CRM_Subbrand_Volume__c> ContractSubbrandVolumeList = new list<ASI_CRM_Subbrand_Volume__c>();
        system.debug('now OutletSet:'+OutletSet);
        system.debug('debug StartDate:'+StartDate);
        system.debug('debug CutOffDay:'+CutOffDay);
        try{
            ContractSubbrandVolumeList = [SELECT Id,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c,
                                          ASI_CRM_Month__c,ASI_CRM_Year__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                                          ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,
                                          ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c,
                                          ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.Name,ASI_CRM_Subbrand__r.ASI_MFM_Brand__c, 
                                          ASI_CRM_Cap_with_Issues_CR12__c,ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_Bottle_Collected_CR12__c,ASI_CRM_Offtake_Std_Billing__c, ASI_CRM_Offtake_CR12__c,ASI_CRM_Account__c,ASI_CRM_Account__r.Name,ASI_CRM_T1_Depletion_STD_Billing__c, ASI_CRM_T2_Depletion_STD_Billing__c,
                                          ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c,
                                          ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_DeductCapWithIssue_StdBill__c, ASI_CRM_Deductible_Cap_with_Issues_CR12__c,
                                          ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c, ASI_CRM_Empty_Bottle_Std_Billing__c, 
                                          ASI_CRM_Green_Cap_Std_Billing__c,ASI_CRM_Green_Cap_CR12__c, ASI_CRM_Penalty_Coefficient_Applied__c,
                                          ASI_CRM_Empty_Bottle_CR12__c,ASI_CRM_Bottle_Collected__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                          ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                          ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name, ASI_CRM_Subbrand__r.Name, 
                                          ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c
                                          FROM ASI_CRM_Subbrand_Volume__c 
                                          WHERE ASI_CRM_End_Date__c >= :StartDate AND ASI_CRM_Account__c !=null and
                                          ASI_CRM_End_Date__c <= :CutOffDay AND ASI_CRM_CN_Competitor_Sub_brand__c != true  AND ASI_CRM_Account__c IN :OutletSet 
                                          and ASI_CRM_CN_Exclude_From_Payment_Volume__c =FALSE and ASI_CRM_Subbrand__c != null ];
        }catch(exception e){
            ContractSubbrandVolumeList = new list<ASI_CRM_Subbrand_Volume__c>();
        }
        return ContractSubbrandVolumeList;
    }
    
    
    private Decimal DataRounding(Decimal InputData){
        InputData=InputData!=null?InputData.setScale(0):0;
        return InputData;
    }
    
    
    
    //1 level
    public Class interimData{
        public String SubBrandGradeName {set;get;} {SubBrandGradeName='';}
        public String CategoryName  {set;get;}{CategoryName='';}
        
        //All
        public DataClass VolumeData {set;get;} {VolumeData=new DataClass();} // its own level with all Martell and non-Martell
        
        public DataClass MartellVolumeData {set;get;} {MartellVolumeData=new DataClass();} // With Martell Volume Data
        public DataClass PureVolumeData {set;get;} {PureVolumeData=new DataClass();} //  With non-Martell Volume Data
        
        
        //Child Level
        public Map<String,DataClass> SubBrandLine {set;get;} {SubBrandLine= new Map<String,DataClass> ();}
        public Integer SequenceNum {set;get;}  {SequenceNum=9;}
        public interimData(){}
    }
    
    
    
    
    //2 Level- Base data structure
    public class DataClass{
        public string sbname {set;get;}{sbname='';}
        public string sbgrade {set;get;}{sbgrade='';}
        public Integer GradeSequence {set;get;}  {GradeSequence=9;}
        
        
        public decimal TargetVol {set;get;} {TargetVol=0;}
        public decimal TargetVolCR12 {set;get;} {TargetVolCR12=0;}
        
        public decimal OffTakeVol {set;get;} {OffTakeVol=0;}
        public decimal OffTakeVolCR12 {set;get;} {OffTakeVolCR12=0;}
        
        public decimal IntakeVol {set;get;}{IntakeVol=0;}
        public decimal IntakeVolCR12 {set;get;}{IntakeVolCR12=0;}
        
        public decimal BtlCollection {set;get;}{BtlCollection=0;}
        public decimal BtlCollectionCR12 {set;get;}{BtlCollectionCR12=0;}
        public decimal CapwithIssues {set;get;}{CapwithIssues=0;}
        public decimal CapwithIssuesCR12 {set;get;}{CapwithIssuesCR12=0;}     
        public decimal DeductibleCapswithIssues	{set;get;}{DeductibleCapswithIssues=0;}  
        public decimal DeductibleCapswithIssuesCR12	{set;get;}{DeductibleCapswithIssuesCR12=0;}  
        
        public decimal PenaltyCoefficient	{set;get;}{PenaltyCoefficient=0;}   
        public decimal OffTakeVSIntake {set;get;}{OffTakeVSIntake=0;}
        public decimal OffTakeVSIntakeCR12 {set;get;}{OffTakeVSIntakeCR12=0;}
        
        public decimal CollectionVSOfftake {set;get;}{CollectionVSOfftake=0;}
        public decimal CollectionVSOfftakeCR12 {set;get;}{CollectionVSOfftakeCR12=0;}
        
        public decimal CollectionVSIntake {set;get;}{CollectionVSIntake=0;}
        public decimal CollectionVSIntakeCR12 {set;get;}{CollectionVSIntakeCR12=0;}
        
        public decimal CollectionVSContract {set;get;}{CollectionVSContract=0;}
        public decimal CollectionVSContractCR12 {set;get;}{CollectionVSContractCR12=0;}
        
        public decimal IntakeVSContract {set;get;} {IntakeVSContract=0;}
        public decimal IntakeVSContractCR12 {set;get;} {IntakeVSContractCR12=0;}
        
        public DataClass(){}
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
                
                }