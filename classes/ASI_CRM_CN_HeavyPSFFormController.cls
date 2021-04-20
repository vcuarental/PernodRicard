/* Filename:    ASI_CRM_CN_HeavyPSFFormController.cls
* Author:       Laputa
* Purpose:      Controller for Payment PSF
* Refernce :  
* Copyright 2017 Laputa Limited. All rights reserved.
* Customer confidential. Do not distribute.
* History     
* -----------------------------------------------------------------------------
* 2017-09-01    Laputa      Created

*/

public class ASI_CRM_CN_HeavyPSFFormController {
    public ASI_CRM_CN_HeavyPSFFormController() {
        
    }
    
    public String PageId {set;get;}
    public ASI_TH_CRM_PaymentRequest__c thisPR {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public Map<string, interimData> PSFMap {set;get;} {PSFMap = NEW Map<string, interimData>();}
    
    public ASI_CRM_CN_HeavyPSFFormController(ApexPages.StandardController controller) {
    }
    public String FisrtModuleId {set;get;} {FisrtModuleId='';}
    
    Public Integer ModuleNumber {set;get;} {ModuleNumber=0;}
    
    public boolean init(){
        RetrieveHeaderInfo();
        PSFMap = NEW Map<string, interimData>();
        ModuleNumber=0;
        Set<Id> ParentModuleIdSet = new Set<Id>();
        //module Id
        Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>(); 
        for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,ASI_CRM_Completion_Ratio__c,
                                       ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,ASI_CRM_Parent_Module__c,
                                       ASI_CRM_End_Date__c,ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,
                                       ASI_CRM_Other_Comments__c,ASI_CRM_Overpayment_Reason__c,ASI_CRM_Actual_Payment__c,ASI_CRM_Adjustment__c,
                                       ASI_CRM_Application_Payment_Amount__c,ASI_CRM_Historical_Paid_Amount__c, ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c 
                                       from ASI_CRM_Module__c where ASI_CRM_Payment_Request__c =:PageId ])
        {
            if(Module.ASI_CRM_Line_Type__c=='PSF'){
                ModuleMap.put(Module.Id,Module);
                ModuleNumber++;
                ParentModuleIdSet.add(Module.ASI_CRM_Parent_Module__c);
            } 
        }
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineList = new  List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        SYSTEM.debug('Now thisPR : '+thisPR);
        IF(thisPR.id!=NULL){
            PaymentRequestLineList = [SELECT id,ASI_CRM_CTD_Actual_Vol_Martell__c ,
                                      ASI_CRM_Full_Contract_Target_ExclPremium__c,ASI_CRM_Intake_Excl_Premium__c,ASI_CRM_BC_Excl_Premium__c,ASI_CRM_Intake_Pure_Excl_Premium__c,ASI_CRM_BC_Pure_Excl_Premium__c,ASI_CRM_Intake_Martell_Excl_Premium__c,ASI_CRM_BC_Martell_Excl_Premium__c,
                                      ASI_CRM_CTD_Actual_Vol_Pure__c,ASI_CRM_CTD_BC_Martell__c ,ASI_CRM_CTD_BC_Pure__c  ,ASI_CRM_Volume_Base__c,
                                      ASI_CRM_CN_Suggested_Amount__c,ASI_CRM_CN_Over_Paid__c,ASI_CRM_Suggested_Value__c,ASI_CRM_Suggested_Volume__c,ASI_CRM_Key_Sub_Brand__c,ASI_CRM_Module__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,ASI_CRM_Product_Category__c,
                                      ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,ASI_CRM_V0_0_Full_Contract_Target__c,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,ASI_CRM_Product_Category__r.Name, ASI_CRM_Sub_Brand_Grade__r.Name, ASI_CRM_Sub_Brand_Grade__c, Name,ASI_CRM_CN_Actual_Vol__c, ASI_TH_CRM_Amount__c,ASI_CRM_CTD_Actual_Vol__c ,ASI_CRM_CTD_Cap_Collection_Vol__c, ASI_CRM_CN_Allow_Changing_Incentive__c ,ASI_CRM_CN_Bottle_Collected__c,ASI_CRM_CN_Collection_Rate__c, ASI_CRM_CN_Completion_Rate__c, ASI_CRM_CN_Offtake_Vol__c, ASI_CRM_CN_Payable_Vol__c, ASI_CRM_CN_Target_BT__c,ASI_CRM_CN_Total_Payable__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,  ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c, ASI_CRM_CN_Incentive_BT__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                                      FROM ASI_TH_CRM_PaymentRequestLineItem__c
                                      WHERE ASI_TH_CRM_Payment_Request__c = :thisPR.id
                                      AND RecordType.DeveloperName = 'ASI_CRM_CN_Payment_Request_Detail_PSF'];
        }

        
        Map<String,String> PaymentModuleMap = new Map<String,String>(); // Parent Id ==> This Payment Module Id
        for(ASI_TH_CRM_PaymentRequestLineItem__c payline:PaymentRequestLineList){
            if(payline.ASI_CRM_Module__c !=null){
                
                PSFPaymentLineMappingHandling(payline,ModuleMap);
                
                if(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c!=null){
                    ParentModuleIdSet.add(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c);
                    if(!PaymentModuleMap.containsKey(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c)){
                        PaymentModuleMap.put(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c, payline.ASI_CRM_Module__c);
                    }
                }
            }
            
        }//end of looping PaymentRequestLineList 
        
        if(ParentModuleIdSet.size()>0){
            // Getting Historical Module List 
            list<ASI_CRM_Module__c> HistoricalPaidModulelist = ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleIdSet , thisPR.id);
            for(ASI_CRM_Module__c ModuleItem:HistoricalPaidModulelist){
                if(PaymentModuleMap.containsKey(ModuleItem.ASI_CRM_Parent_Module__c)){
                    String PaymentModuleId= PaymentModuleMap.get(ModuleItem.ASI_CRM_Parent_Module__c);
                    if(PSFMap.containsKey(PaymentModuleId)){
                        PSFMap.get(PaymentModuleId).HistoricalModuleList.add(ModuleItem);
                        PSFMap.get(PaymentModuleId).HaveHistoricalPaymentSummary=true;
                    }
                }
            }
        }
        
        if(FisrtModuleId!=null){
            List<ASI_TH_CRM_PaymentRequest__c> Payment000List = [select id,Name,ASI_CRM_CN_Total_PSF_Amount__c 
                                                                 from ASI_TH_CRM_PaymentRequest__c 
                                                                 where ASI_TH_CRM_Contract__c= :thisPR.ASI_TH_CRM_Contract__c and Name like '%000%' ];
            for(ASI_TH_CRM_PaymentRequest__c paymenTemp:Payment000List){
                
            }
        
        }
        
        return true;
    }
    
    
    
    public void PSFPaymentLineMappingHandling(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine, Map<String,ASI_CRM_Module__c> ModuleMap){
        string sbGradeSort;
        integer intlength; 
        integer intRP6;
        string sbGrade;
        string sbGrade_Chi='';
        
        if (PaymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
            sbGrade = PaymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
            if (PaymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c != null){
                intlength = PaymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c.length();
                intRP6 = PaymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c.lastIndexOf('-');
                sbGrade_Chi = PaymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
            }else{
                sbGrade_Chi = '未有中文档次名称';
            }
        }else{
            sbGrade = 'No Sub Brand Grade specified';
            sbGrade_Chi = '未指定档次';
        }
        if (PaymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
            sbGradeSort = sbGradeSorting(PaymentLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + sbGrade;
        }
        
        if(PaymentLine.ASI_CRM_CN_Sub_Brand__r.Name != null){
            intlength = PaymentLine.ASI_CRM_CN_Sub_Brand__r.Name.length();
            intRP6 = PaymentLine.ASI_CRM_CN_Sub_Brand__r.Name.lastIndexOf('-');     
            if(intlength >= 4 && intRP6 == (intlength-4)){
                PaymentLine.ASI_CRM_CN_Sub_Brand__r.Name = PaymentLine.ASI_CRM_CN_Sub_Brand__r.Name.substring(0, (intlength-4));
            }
        }
        
        if(PaymentLine.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
            PaymentLine.ASI_CRM_CN_Payable_Vol__c =  PaymentLine.ASI_CRM_CN_Payable_Vol__c!=null?  PaymentLine.ASI_CRM_CN_Payable_Vol__c:0;
            PaymentLine.ASI_CRM_Suggested_Volume__c =  PaymentLine.ASI_CRM_Suggested_Volume__c!=null?  PaymentLine.ASI_CRM_Suggested_Volume__c:0;
            if(PaymentLine.ASI_CRM_CN_Payable_Vol__c>PaymentLine.ASI_CRM_Suggested_Volume__c){
                PaymentLine.ASI_CRM_CN_Over_Paid__c=true;
            }else{
                PaymentLine.ASI_CRM_CN_Over_Paid__c=false;
            }
        }else{
            PaymentLine.ASI_CRM_CN_Suggested_Amount__c =  PaymentLine.ASI_CRM_CN_Suggested_Amount__c!=null?  PaymentLine.ASI_CRM_CN_Suggested_Amount__c:0;
            PaymentLine.ASI_CRM_CN_Total_Payable__c =  PaymentLine.ASI_CRM_CN_Total_Payable__c!=null?  PaymentLine.ASI_CRM_CN_Total_Payable__c:0;
            if(PaymentLine.ASI_CRM_CN_Total_Payable__c>PaymentLine.ASI_CRM_CN_Suggested_Amount__c){
                PaymentLine.ASI_CRM_CN_Over_Paid__c=true;
            }else{
                PaymentLine.ASI_CRM_CN_Over_Paid__c=false;
            }
        }
        
        
        
        if(PSFMap.containsKey(PaymentLine.ASI_CRM_Module__c)){//contain
            if(ModuleMap.containsKey(PaymentLine.ASI_CRM_Module__c) ){
                if(EmptyRecordChecking(PaymentLine)){
                    if(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c=='By Sub-Brand'){ //By Sub-Brand
                        if(PSFMap.get(PaymentLine.ASI_CRM_Module__c).DetailLineMap.containsKey(sbGradeSort)){
                            PSFMap.get(PaymentLine.ASI_CRM_Module__c).DetailLineMap.get(sbGradeSort).PaymenDetailList.add(PaymentLine);
                        }else{
                            PaymentLine TempPaymentLine = new PaymentLine();
                            TempPaymentLine.SBGradeCN = sbGrade_Chi;
                            TempPaymentLine.PaymenDetailList.add(PaymentLine);
                            PSFMap.get(PaymentLine.ASI_CRM_Module__c).DetailLineMap.put(sbGradeSort,TempPaymentLine);
                        }
                    }else{ //not by Sub-Brand  
                        if(PSFMap.get(PaymentLine.ASI_CRM_Module__c).DetailLineMap.containsKey(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c)){
                            PSFMap.get(PaymentLine.ASI_CRM_Module__c).DetailLineMap.get(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c).PaymenDetailList.add(PaymentLine);
                        }else{
                            PaymentLine TempPaymentLine = new PaymentLine();
                            TempPaymentLine.PaymenDetailList.add(PaymentLine);
                            PSFMap.get(PaymentLine.ASI_CRM_Module__c).DetailLineMap.put(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c,TempPaymentLine);
                        }
                    }
                }
                
                
                
                ///Added later
                if(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c!='By Total' && ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c!='By Sub-Brand'){ 
                    String Mapkeystr=PaymentLine.Id;
                    if(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c=='By Grade'){
                        Mapkeystr=KeyNameSortingASC(PaymentLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c)+PaymentLine.ASI_CRM_Sub_Brand_Grade__c;
                    }
                    if(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c=='By Category'){
                        Mapkeystr=KeyNameSortingASC(PaymentLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c)+PaymentLine.ASI_CRM_Product_Category__c;
                    }
                    if(PaymentLine.ASI_CRM_CN_Incentive_BT__c==null || PaymentLine.ASI_CRM_CN_Incentive_BT__c==0){
                        Mapkeystr='9'+Mapkeystr;
                    }
                    system.debug(PaymentLine.ASI_CRM_Sub_Brand_Grade__r.Name+'Now Mapkeystr'+Mapkeystr);
                    
                    if(PSFMap.get(PaymentLine.ASI_CRM_Module__c).ContractLineMap.containsKey(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c)){
                        PaymentLine TempPaymentLine = new PaymentLine();
                        TempPaymentLine.PaymenDetailList.add(PaymentLine);
                        PSFMap.get(PaymentLine.ASI_CRM_Module__c).ContractLineMap.get(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c).put(Mapkeystr, TempPaymentLine);
                    }else{
                        map<String, PaymentLine> TempMap =new map<String, PaymentLine>(); //map<String,  map<String, PaymentLine> TempMap= new 
                        PaymentLine TempPaymentLine = new PaymentLine();
                        TempPaymentLine.PaymenDetailList.add(PaymentLine);
                        TempMap.put(Mapkeystr, TempPaymentLine);
                        PSFMap.get(PaymentLine.ASI_CRM_Module__c).ContractLineMap.put(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c,TempMap);
                    }
                }
                
                
            }
            
        }else{ // dont contain
            if(ModuleMap.containsKey(PaymentLine.ASI_CRM_Module__c)){
                interimData TempData= new interimData();
                TempData.Module= ModuleMap.get(PaymentLine.ASI_CRM_Module__c);
                if(FisrtModuleId==''){
                    FisrtModuleId=ModuleMap.get(PaymentLine.ASI_CRM_Module__c).Id;
                }
                
                if(EmptyRecordChecking(PaymentLine)){
                    PaymentLine TempPaymentLine = new PaymentLine();
                    TempPaymentLine.PaymenDetailList.add(PaymentLine);
                    if(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c=='By Sub-Brand'){ 
                        TempPaymentLine.SBGradeCN = sbGrade_Chi;
                        TempData.DetailLineMap.put(sbGradeSort,TempPaymentLine);
                    }else{
                        TempData.DetailLineMap.put(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c,TempPaymentLine);                         
                    }
                }
                
                
                if(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c!='By Total' && ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c!='By Sub-Brand'){ 
                    //'By Grade' or  'By Category'
                    String Mapkeystr=PaymentLine.Id;
                    if(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c=='By Grade'){
                        TempData.SequenceNum= PaymentLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c !=null? Integer.valueOf(PaymentLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c): 9;
                        Mapkeystr=KeyNameSortingASC(PaymentLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c)+PaymentLine.ASI_CRM_Sub_Brand_Grade__c;
                    }
                    if(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c=='By Category'){
                        Mapkeystr=KeyNameSortingASC(PaymentLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c)+PaymentLine.ASI_CRM_Product_Category__c;
                    }
                    if(PaymentLine.ASI_CRM_CN_Incentive_BT__c==null || PaymentLine.ASI_CRM_CN_Incentive_BT__c==0){
                        Mapkeystr='9'+Mapkeystr;
                    }
                    system.debug(PaymentLine.ASI_CRM_Sub_Brand_Grade__r.Name+'Now Mapkeystr'+Mapkeystr);
                    
                    map<String, PaymentLine> TempMap =new map<String, PaymentLine>(); 
                    PaymentLine TempPaymentLine = new PaymentLine();
                    //Put in the List 
                    TempPaymentLine.PaymenDetailList.add(PaymentLine);
                    TempMap.put(Mapkeystr, TempPaymentLine);
                    TempData.ContractLineMap.put(ModuleMap.get(PaymentLine.ASI_CRM_Module__c).ASI_CRM_Volume_Base__c,TempMap); 
                }
                PSFMap.put(PaymentLine.ASI_CRM_Module__c, TempData);
            }
            
        }
        
    }
    
    public String KeyNameSortingASC(decimal strSeq){
        if(strSeq==0){
            strSeq=9;
        }
        string returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = string.valueof(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString =  string.valueof(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString =  string.valueof(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = string.valueof(strSeq);
            }
        }else{
            returnString = '0';
        }
        return returnString; 
    }
    
    
    
    public class interimData{
        public ASI_CRM_Module__c Module {set;get;} {Module= new ASI_CRM_Module__c();}
        public String SBGradeCN {set;get;} {SBGradeCN = '';}
        public Integer SequenceNum {set;get;}  {SequenceNum=9;}
        public map<String, PaymentLine> DetailLineMap{set;get;} {DetailLineMap = new map<String, PaymentLine>();} 
        public map<String,  map<String, PaymentLine>> ContractLineMap{set;get;} {ContractLineMap = new map<String,  map<String, PaymentLine>>();} 
        public Boolean HaveHistoricalPaymentSummary {set;get;}  {HaveHistoricalPaymentSummary=false;}
        
        
        public List<ASI_CRM_Module__c> HistoricalModuleList {set;get;} {HistoricalModuleList =new List<ASI_CRM_Module__c>();}
        public interimData(){ }
        
    }
    
    public class PaymentLine{
        public String SBGradeCN {set;get;} {SBGradeCN = '';}
        public List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymenDetailList {set;get;} {PaymenDetailList =new List<ASI_TH_CRM_PaymentRequestLineItem__c>(); }
        public PaymentLine(){ }
        
    }
    
    public class PSFPaymentRequest{
        public ASI_TH_CRM_PaymentRequest__c HistoricalPayment {set;get;} {HistoricalPayment = new ASI_TH_CRM_PaymentRequest__c (); }
        public Date PSFStartDate {set;get;} 	
        public Date PSFEndDate	 {set;get;}  
        public Decimal PSFActualPaidAmt  {set;get;}  {PSFActualPaidAmt = 0.0;}
        
        
        public PSFPaymentRequest(){ }
    }
    
    
    
    
    
    private boolean EmptyRecordChecking(ASI_TH_CRM_PaymentRequestLineItem__c InputPaymentLine){
        Boolean ReturnFlag=false;
        if((InputPaymentLine.ASI_CRM_CN_Incentive_BT__c != null && InputPaymentLine.ASI_CRM_CN_Incentive_BT__c != 0) || (InputPaymentLine.ASI_CRM_CN_Target_BT__c != null && InputPaymentLine.ASI_CRM_CN_Target_BT__c != 0) ||
           (InputPaymentLine.ASI_CRM_CN_Actual_Vol__c != null && InputPaymentLine.ASI_CRM_CN_Actual_Vol__c != 0) || (InputPaymentLine.ASI_CRM_CN_Completion_Rate__c != null && InputPaymentLine.ASI_CRM_CN_Completion_Rate__c != 0) ||
           (InputPaymentLine.ASI_CRM_CN_Total_Payable__c != null && InputPaymentLine.ASI_CRM_CN_Total_Payable__c != 0) || (InputPaymentLine.ASI_CRM_CN_Payable_Vol__c != null && InputPaymentLine.ASI_CRM_CN_Payable_Vol__c != 0) || (InputPaymentLine.ASI_CRM_CN_Bottle_Collected__c != null && InputPaymentLine.ASI_CRM_CN_Bottle_Collected__c != 0) || (InputPaymentLine.ASI_CRM_CN_Collection_Rate__c != null && InputPaymentLine.ASI_CRM_CN_Collection_Rate__c != 0) ||
           (InputPaymentLine.ASI_CRM_CN_Offtake_Vol__c != null && InputPaymentLine.ASI_CRM_CN_Offtake_Vol__c != 0)){
               ReturnFlag=true;
           }
        return ReturnFlag;
    }
    
    
    
    
    //getting header info 
    public void RetrieveHeaderInfo(){ //if(ApexPages.currentPage().getParameters().contains('id')){
        //   PageId = ApexPages.currentPage().getParameters().get('id'); // } ASI_TH_CRM_Contract__c
        system.debug('PageId'+ PageId);
        try{
            thisPR = [SELECT id,ASI_TH_CRM_Contract__r.ASI_CRM_Martell_BC_Rate__c,ASI_TH_CRM_Contract__c, Name, ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c,ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_OutletWS__r.Name,ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Region__c, ASI_CRM_CN_Bottle_Collection_Rate__c
                      FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
        }catch(Exception e){ thisPR=new ASI_TH_CRM_PaymentRequest__c();
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyBRSFFormCtrl thisPR Try Exception:  class have Error  '+ 'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyBRSFFormCtrl','  Id: '+PageId);
        }
    }
    
    
    public string SBGradeSorting(decimal strSeq){
        string returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = '0000' + string.valueof(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString = '000' + string.valueof(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString = '00' + string.valueof(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = '0' + string.valueof(strSeq);
            }
        }else{
            returnString = '00000';
        }
        system.debug('SBGradeSorting: ' + returnString);
        return returnString;
    }
    
}