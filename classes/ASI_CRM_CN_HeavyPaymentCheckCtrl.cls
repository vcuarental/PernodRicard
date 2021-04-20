/* Filename:    ASI_CRM_CN_HeavyPaymentCheckCtrl.cls
* Author:      Laputa
* Purpose:     Controller Class for payment request Check Point for CN CRM 4.2
Volume Speed% = Actual Intake/V0.0 Volume (Contract based)
* History
* -----------------------------------------------------------------------------
* 2017-09-19   Laputa      Created
*/

public with sharing class ASI_CRM_CN_HeavyPaymentCheckCtrl {
    public ASI_TH_CRM_PaymentRequest__c PaymentRequest {set;get;}
    public string PageId {set;get;}
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;} {ContractSelected=new ASI_TH_CRM_Contract__c();}
    public boolean AdorAbove {set;get;}{AdorAbove=false;}
    
    
    public Boolean ShowSubmitApproval {set;get;} {ShowSubmitApproval=false;}
    
    
    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> SuccessCheckPointList2nd {set;get;}  {SuccessCheckPointList2nd = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}
    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> FailedCheckPointList2nd {set;get;}  {FailedCheckPointList2nd = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}
    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> SuccessCheckPointList {set;get;}  {SuccessCheckPointList = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}
    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> FailedCheckPointList {set;get;}  {FailedCheckPointList = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}
    public Boolean NeedRVPApproval {get;set;}{NeedRVPApproval=false;}
    public date CutOffDay {set;get;} 
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract2nd  {set;get;} { HistoricalV00Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalVFinalContract2nd  {set;get;} { HistoricalVFinalContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContractV0Esitimate2nd  {set;get;} { NewContractV0Esitimate2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactV0Contract2nd  {set;get;} { NewContactV0Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactVFinal2nd  {set;get;} { NewContactVFinal2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalV00Contract  {set;get;} { HistoricalV00Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalVFinalContract  {set;get;} { HistoricalVFinalContract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContractV0Esitimate  {set;get;} { NewContractV0Esitimate = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContactVFinal  {set;get;} { NewContactVFinal = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}

    public boolean showCN {set;get;}
    public String Msg {get;set;} {Msg='';}

    public boolean ProcessPermission {get;set;}{ProcessPermission=true;}
    public Map<String,Decimal> PaymentKPIMap   {get;set;} {PaymentKPIMap=new Map<String,Decimal>(); }
    //KPI
    public Decimal FixedCostTotal {get;set;}{FixedCostTotal=0;}
    public Decimal VariableCostTotal {get;set;}{VariableCostTotal=0;}
    
    public decimal PaymentSpeed {set;get;}{PaymentSpeed=0.0;}
    public decimal VolumeSpeed {set;get;}{VolumeSpeed=0.0;}
    
    
    public Boolean DisplaySuccessCheckPointPart {get;set;}{DisplaySuccessCheckPointPart=true;}
    public Boolean DisplayFailedCheckPointPart {get;set;}{DisplayFailedCheckPointPart=true;}
    public Decimal PRCGuidance   {set;get;} {PRCGuidance=0.0;} 

    // Modifier: Bluelinksys_PC Date : 2020-03-12
    public String strVersionType1{GET;SET;}{strVersionType1 = '';}
    public String strVersionType2{GET;SET;}{strVersionType2 = '';}
    public List<ASI_CRM_Segmentation_Criteria_Item__c> sciList;
    public Boolean displayVolumeCheckPart{GET;SET;}{displayVolumeCheckPart = false;}
    List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> volumeCheckList1;
    List<ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> volumeCheckList2;
    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> VolumeCheckPortList{GET;SET;}  {VolumeCheckPortList = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}
    public Map<String,Decimal> VolumeMixMap1 = new Map<String,Decimal>();
    public Map<String,Decimal> VolumeMixMap2 = new Map<String,Decimal>();
    public Map<String,Decimal> RegionalAverageInvestmentMap = new Map<String,Decimal>();
    public List<ASI_CRM_Segmentation_Criteria_Item__c> RegionalCriteriaItemIdList = new List<ASI_CRM_Segmentation_Criteria_Item__c>();
    
    public String BelongGroup{GET;SET;} {BelongGroup = ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.UserOrGroupInit();}

    public ASI_CRM_CN_HeavyPaymentCheckCtrl(ApexPages.StandardController controller) {
        this.PaymentRequest = (ASI_TH_CRM_PaymentRequest__c)controller.getRecord();    
        if(this.PaymentRequest != null)
            PageId = PaymentRequest.id;
        list <ASI_TH_CRM_PaymentRequest__c> HeaderList  = new list <ASI_TH_CRM_PaymentRequest__c>();
        
        
          
        Map<String, String> params = ApexPages.currentPage().getParameters();
        string TypeName = params.get('Type');
        if(TypeName =='SubmitApproval'){ ShowSubmitApproval =true;
        }
        
        
        //Get Header information
        if (PageId != null){
            HeaderList = [SELECT id, name,Owner.Name,ASI_TH_CRM_Contract__r.ASI_CRM_CN_RContract_Fixed_Cost_Total__c,ASI_TH_CRM_Contract__r.ASI_CRM_Contract_Total_Dummy__c,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c,ASI_CRM_Volume_Cut_Off_Date__c,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c,
                          ASI_CRM_Total_Actual_Amount__c,ASI_CRM_CN_Payable_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c, ASI_CRM_CN_Other_Reason__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_Last_Year_Payment__c,ASI_CRM_CN_Division__c,ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_Volume_Option__c,ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c, ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, ASI_CRM_CN_PO_Version_Latest__c, ASI_CRM_CN_Overpayment_Reason__c,ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, ASI_CRM_CN_Business_License_Qualify__c ,ASI_CRM_CN_Total_PSF_Amount__c, 
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c   , ASI_CRM_CN_Total_Payment__c , ASI_CRM_CN_Overpayment_Comment__c,ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Total_BRSF_Actual_Amount__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c  ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c, ASI_CRM_New_FY_Payment__c, 
                          ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c,(select Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c from ASI_CRM_Modules__r) 
                          FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
            
        }
        if (HeaderList.size()> 0){
            this.PaymentRequest = HeaderList[0]; 
        }
        checkUserID();
        if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            init2nd();
        } else {
            init();
        }
    }
    
   
    public void init2nd(){
        PaymentKPIMap=new Map<String,Decimal>();
        
        boolean ExistHistoricalData=false;
        NeedRVPApproval=false;
        CutOffDay=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        VolumeSpeed=0;
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmentationCriteriaMap =  new Map<String,ASI_CRM_SegmentationCriteria__c>();
        
        ASI_CRM_CN_CustomSetting__c CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        PRCGuidance=CustomSetting.ASI_CRM_PRC_Guidance__c;
        
        //Getting Contract
        ContractSelected = [SELECT Id,Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                            ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__c,
                            Owner.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Fixed_Cost_Contract_Total__c,
                            (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
                             ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c 
                             From ASI_TH_CRM_PaymentRequests_Contract__r)    
                            FROM ASI_TH_CRM_Contract__c WHERE id =:PaymentRequest.ASI_TH_CRM_Contract__c ];

        //FICalculation();
        List<ASI_Attachment__c> AttachmentList= new List<ASI_Attachment__c>();
        if(ContractSelected.ASI_CRM_CN_V0_0_PO_version__c!=null){ 
            AttachmentList= [SELECT id,
                                    ASI_CRM_Historical_Financial_Data__c,
                                    ASI_CRM_Historical_Financial_Data2__c,
                                    ASI_CRM_Historical_Financial_Data3__c,
                                    ASI_CRM_Historical_Financial_Data4__c,
                                    ASI_CRM_Contract__c,
                                    ASI_CRM_Type__c 
                             FROM ASI_Attachment__c 
                             WHERE ASI_CRM_Contract__c = :ContractSelected.Id 
                             OR ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c];  
        }else{
            //Geting HistoricalV0.0 and VFinal Data
            AttachmentList= [SELECT id,
                                    ASI_CRM_Historical_Financial_Data__c,
                                    ASI_CRM_Historical_Financial_Data2__c,
                                    ASI_CRM_Historical_Financial_Data3__c,
                                    ASI_CRM_Historical_Financial_Data4__c,
                                    ASI_CRM_Contract__c,
                                    ASI_CRM_Type__c 
                             FROM ASI_Attachment__c 
                             WHERE ASI_CRM_Contract__c = :ContractSelected.Id ]; 
            
        }

        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){
                String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');

                //General Payment Info 
                if(att.ASI_CRM_Type__c=='Payment Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){
                    PaymentKPIMap= (Map<String,Decimal>)System.JSON.deserialize(JsonString,Map<String,Decimal>.class);

                    // system.debug('TempMap');system.debug(TempMap);
                    // if( PaymentKPIMap.containsKey('FixedCostTotal')){
                    //     FixedCostTotal= PaymentKPIMap.get('FixedCostTotal');
                    // }
                    // if( PaymentKPIMap.containsKey('VariableCostTotal')  ){
                    //     VariableCostTotal= PaymentKPIMap.get('VariableCostTotal');
                    // }
                    if( PaymentKPIMap.containsKey('PaymentSpeed')  ){
                        PaymentSpeed= PaymentKPIMap.get('PaymentSpeed');
                    }
                    if( PaymentKPIMap.containsKey('FixedCostTotal')  ){
                        VolumeSpeed= PaymentKPIMap.get('VolumeSpeed');
                    }
                }
            }
        }

        //FixedCostTotal And VariableCostTotal Calculate By Module
        for (ASI_CRM_Module__c acm : PaymentRequest.ASI_CRM_Modules__r) {
            if (acm.ASI_CRM_Line_Type__c == 'Fixed') {
                FixedCostTotal += acm.ASI_CRM_Actual_Payment__c;
            }else if(acm.ASI_CRM_Line_Type__c == 'Variable Event Cost' || acm.ASI_CRM_Line_Type__c == 'BRSF' || acm.ASI_CRM_Line_Type__c == 'PSF'){
                VariableCostTotal += acm.ASI_CRM_Actual_Payment__c;
            }
        }
        if(!PaymentRequest.ASI_CRM_CN_Last_Payment__c){// if not last payment 
            //All Payment Total Amount
            SegmentationCriteriaMap = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_Payment_Checkpoint_Criteria');
            System.debug(LoggingLevel.INFO, '*** SegmentationCriteriaMap: ' + SegmentationCriteriaMap);
            for(String key: SegmentationCriteriaMap.keySet()){
                ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData temp = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaMap.get(key));
                temp= NormalPayment1stDimensionAssign2nd(temp);
                temp= NormalPayment2ndDimensionAssign2nd(temp);
                temp= DataOperationChecking2nd(temp);

                if(CheckingDisplayOrNot2nd(temp)){
                    if(temp.ReachTarget =='No'){//if(!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(temp.SegmentationCriteria.ASI_CRM_Operation__c,temp.Dimension1stResult,temp.Dimension2ndResult,0)){
                        //temp.ReachTarget ='No';
                        if(temp.SegmentationCriteria.ASI_CRM_RVP_Special_Approval__c){ NeedRVPApproval=true;
                        }
                        FailedCheckPointList2nd.add(temp);
                    }else{
                        SuccessCheckPointList2nd.add(temp);
                    }
                    
                }
            }
        }else{ 

            // which is last payment 
            String V0ContractID='';

            if(ContractSelected.ASI_CRM_CN_V0_0_PO_version__c!=null){ 
                V0ContractID=ContractSelected.ASI_CRM_CN_V0_0_PO_version__c;
            }else{ 
                V0ContractID=ContractSelected.Id;
            }

            if(AttachmentList.size()>0){
                for(ASI_Attachment__c att:AttachmentList){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');

                    if(att.ASI_CRM_Type__c=='Historical Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){

                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                        if(HistoricalContractList.size()>0){
                            HistoricalV00Contract2nd= HistoricalContractList[0];
                            HistoricalVFinalContract2nd= HistoricalContractList[1];
                        }
                    }else if(att.ASI_CRM_Type__c=='Contract Data' && att.ASI_CRM_Contract__c==V0ContractID){// V0.0

                        JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                        if(ContractList.size()>0){
                            NewContractV0Esitimate2nd= ContractList[0];
                            NewContactV0Contract2nd= ContractList[1];
                        }
                    }else if(att.ASI_CRM_Type__c=='Last Payment Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){

                        // JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class); 
                        if(ContractList.size()>0){  
                            NewContactVFinal2nd= ContractList[0];
                        }
                    }
                }
            }

            if(HistoricalV00Contract2nd.ContractId!='' ){
                ExistHistoricalData=true;
            }

            SegmentationCriteriaMap = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_Last_Payment_Checkpoint_Criteria_2nd');
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
            
            System.debug('segmentId'+segmentId);
            // System.debug('RegionalCriteriaItemId'+RegionalCriteriaItemId);
            // if(!String.isBlank(RegionalCriteriaItemId)){
            //     RegionalCriteriaItemIdList = [SELECT ASI_CRM_CN_Subbrand__r.Name, 
            //     ASI_CRM_CN_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
            //     ASI_CRM_CN_Subbrand__r.ASI_HK_CRM_Sequence__c,
            //     ASI_CRM_CN_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c,
            //     ASI_CRM_CN_Subbrand__c,
            //     ASI_CRM_CN_Subbrand__r.ASI_HK_CRM_English_Name__c
            //     FROM ASI_CRM_Segmentation_Criteria_Item__c  
            //     WHERE ASI_CRM_SegmentationCriteria__c = :RegionalCriteriaItemId];
            // }
            if (!string.isBlank(segmentId)) {
                sciList = [SELECT ASI_CRM_CN_Subbrand__r.Name, 
                                ASI_CRM_CN_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                ASI_CRM_CN_Subbrand__r.ASI_HK_CRM_Sequence__c,
                                ASI_CRM_CN_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c,
                                ASI_CRM_CN_Subbrand__r.ASI_HK_CRM_English_Name__c,
                                ASI_CRM_CN_Subbrand__c
                        FROM ASI_CRM_Segmentation_Criteria_Item__c  
                        WHERE ASI_CRM_SegmentationCriteria__c = :segmentId];
                if (!sciList.isEmpty()) {
                    displayVolumeCheckPart = true;
                }
            }else{
                displayVolumeCheckPart = false;
            }

            for(String key: SegmentationCriteriaMap.keySet()){
                ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData temp = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaMap.get(key));
                system.debug('Now get SegmentationCriteria Id'+temp.SegmentationCriteria.Id);
                temp= FirstDimensionAssignment2nd(temp);
                temp= SecondDimensionAssignment2nd(temp);
                
                temp= NormalPayment1stDimensionAssign2nd(temp);
                temp= NormalPayment2ndDimensionAssign2nd(temp);

                temp= DataOperationChecking2nd(temp);

                //VolumeDataCheck  (ASI_CRM_Financial_Indicator__c == 'Volume mix')
                
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
                
                //decide if it aloow to put 
                if(( temp.SegmentationCriteria.ASI_CRM_1st_Dimension__c!=null && temp.SegmentationCriteria.ASI_CRM_1st_Dimension__c.contains('Historical') ) 
                || ( temp.SegmentationCriteria.ASI_CRM_2nd_Dimension__c !=null && temp.SegmentationCriteria.ASI_CRM_2nd_Dimension__c.contains('Historical') ) ){
                    if(ExistHistoricalData){ 
                        AllowPut=true;
                    }else{ 
                        AllowPut=false;
                    }
                }


                if (displayVolumeCheckPart && SegmentationCriteriaMap.get(key).ASI_CRM_Financial_Indicator__c =='Volume mix') {
                    VolumeChecking(temp);
                    AllowPut=false;
                }
                System.debug('RegionalCriteriaItemIdList'+RegionalCriteriaItemIdList);
                System.debug('RegionalAverageInvestmentMap'+RegionalAverageInvestmentMap);
                System.debug('SegmentationCriteriaMap.get(key).ASI_CRM_Financial_Indicator__c'+SegmentationCriteriaMap.get(key).ASI_CRM_Financial_Indicator__c);

                // if(!RegionalCriteriaItemIdList.isEmpty() && !RegionalAverageInvestmentMap.isEmpty() 
                //                                             && SegmentationCriteriaMap.get(key).ASI_CRM_Financial_Indicator__c =='Regional Average Target'){
                //     AllowPut=false;
                //     for(ASI_CRM_Segmentation_Criteria_Item__c sci : RegionalCriteriaItemIdList){
                //         if(RegionalAverageInvestmentMap.containsKey(sci.ASI_CRM_CN_Subbrand__c)){
    
                //             ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData regtemp = ASI_CRM_CN_HeavyCheckPointResultCtrl.RegionalAverageChecking(temp, RegionalAverageInvestmentMap,sci);
                //             System.debug('regtemp'+regtemp);
                //             if(regtemp.ReachTarget =='Yes'){
                //                 SuccessCheckPointList2nd.add(regtemp);
                //             }else if(regtemp.ReachTarget =='No'){
                //                 FailedCheckPointList2nd.add(regtemp);
                //             }
                //         }
                //     }
                // }else if(SegmentationCriteriaMap.get(key).ASI_CRM_Financial_Indicator__c =='Regional Average Target'){
                //     AllowPut=false;
                // }

                if(AllowPut  && CheckingDisplayOrNot2nd(temp)){
                    if(temp.ReachTarget =='Yes'){ 
                        SuccessCheckPointList2nd.add(temp);
                    }else{
                        if(temp.SegmentationCriteria.ASI_CRM_RVP_Special_Approval__c){ NeedRVPApproval=true;
                        }
                        FailedCheckPointList2nd.add(temp);
                    }
                }
                
                
            }
        }
        
        
        if(FailedCheckPointList2nd.size()==0){
            DisplayFailedCheckPointPart=false;
        }
        if(SuccessCheckPointList2nd.size()==0){
            DisplaySuccessCheckPointPart=false;
        }
        
    }

    public void init(){
        PaymentKPIMap=new Map<String,Decimal>();
        
        boolean ExistHistoricalData=false;
        NeedRVPApproval=false;
        CutOffDay=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        VolumeSpeed=0;
        
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmentationCriteriaMap =  new Map<String,ASI_CRM_SegmentationCriteria__c>();
        
        ASI_CRM_CN_CustomSetting__c CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        PRCGuidance=CustomSetting.ASI_CRM_PRC_Guidance__c;
        
        //Getting Contract
        ContractSelected = [SELECT Id,Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                            ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Outlet_WS__c,
                            Owner.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Division_Name__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                            (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,
                             ASI_CRM_CN_Channel__c, ASI_CRM_CN_Total_Payment__c,ASI_CRM_CN_Paid__c,ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c 
                             From ASI_TH_CRM_PaymentRequests_Contract__r)    
                            FROM ASI_TH_CRM_Contract__c WHERE id =:PaymentRequest.ASI_TH_CRM_Contract__c ];
        
        //FICalculation();
        
        List<ASI_Attachment__c> AttachmentList= new List<ASI_Attachment__c>();
        if(ContractSelected.ASI_CRM_CN_V0_0_PO_version__c!=null){ AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c where ASI_CRM_Contract__c = :ContractSelected.Id or ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c];  
        }else{
            //Geting HistoricalV0.0 and VFinal Data
            AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c 
                             where ASI_CRM_Contract__c = :ContractSelected.Id ]; 
            
        }
        
        
        
        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                
                //General Payment Info 
                if(att.ASI_CRM_Type__c=='Payment Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){  //{"VolumeSpeed":331.29263738559522246165546964127300,"PaymentSpeed":81.504555168645218953395248819726800,"VariableCostTotal":0,"FixedCostTotal":0.00}

                    PaymentKPIMap= (Map<String,Decimal>)System.JSON.deserialize(JsonString,Map<String,Decimal>.class);// system.debug('TempMap');system.debug(TempMap);
                    if( PaymentKPIMap.containsKey('FixedCostTotal')  ){
                        FixedCostTotal= PaymentKPIMap.get('FixedCostTotal');
                    }
                    if( PaymentKPIMap.containsKey('VariableCostTotal')  ){
                        VariableCostTotal= PaymentKPIMap.get('VariableCostTotal');
                    }
                    if( PaymentKPIMap.containsKey('PaymentSpeed')  ){
                        PaymentSpeed= PaymentKPIMap.get('PaymentSpeed');
                    }
                    if( PaymentKPIMap.containsKey('FixedCostTotal')  ){
                        VolumeSpeed= PaymentKPIMap.get('VolumeSpeed');
                    }
                }
                
            }
            
        }
        
        
        if(!PaymentRequest.ASI_CRM_CN_Last_Payment__c){// if not last payment 
            //All Payment Total Amount
            SegmentationCriteriaMap = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_Payment_Checkpoint_Criteria');
            System.debug(LoggingLevel.INFO, '*** SegmentationCriteriaMap: ' + SegmentationCriteriaMap);
            for(String key: SegmentationCriteriaMap.keySet()){
                ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData temp = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaMap.get(key));
                
                temp= NormalPayment1stDimensionAssign(temp);
                temp= NormalPayment2ndDimensionAssign(temp);
                temp= DataOperationChecking(temp);
                
                if(CheckingDisplayOrNot(temp)){
                    if(temp.ReachTarget =='No'){//if(!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(temp.SegmentationCriteria.ASI_CRM_Operation__c,temp.Dimension1stResult,temp.Dimension2ndResult,0)){
                        //temp.ReachTarget ='No';
                        if(temp.SegmentationCriteria.ASI_CRM_RVP_Special_Approval__c){ NeedRVPApproval=true;
                        }
                        FailedCheckPointList.add(temp);
                    }else{
                        SuccessCheckPointList.add(temp);
                    }
                    
                }      
                                  
            }
        }else{ // which is last payment 
            String V0ContractID='';
            
            if(ContractSelected.ASI_CRM_CN_V0_0_PO_version__c!=null){ V0ContractID=ContractSelected.ASI_CRM_CN_V0_0_PO_version__c;
            }else{ V0ContractID=ContractSelected.Id;
            }
            
            if(AttachmentList.size()>0){
                for(ASI_Attachment__c att:AttachmentList){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                    if(att.ASI_CRM_Type__c=='Historical Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){
                        system.debug('Now get Historical Data'+att.Id);
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(HistoricalContractList.size()>0){
                            HistoricalV00Contract= HistoricalContractList[0];
                            HistoricalVFinalContract= HistoricalContractList[1];
                        } 
                    }else if(att.ASI_CRM_Type__c=='Contract Data' && att.ASI_CRM_Contract__c==V0ContractID){// V0.0
                        system.debug('Now get Contract Data'+att.Id);
                        JsonString = JsonString.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(ContractList.size()>0){NewContractV0Esitimate= ContractList[0];
                            NewContactV0Contract= ContractList[1];
                        } 
                    }else if(att.ASI_CRM_Type__c=='Last Payment Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){
                        system.debug('Now NewContactVFinal'+att.Id);
                        JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class); 
                        if(ContractList.size()>0){  NewContactVFinal= ContractList[0];
                        } 
                    }
                    
                    
                }
            }
            
            
            if(HistoricalV00Contract.ContractId!='' ){ExistHistoricalData=true;
            }
            
            
            SegmentationCriteriaMap = ASI_CRM_CN_HeavyContractUtilitiesClass.RetrieveCheckPointCriteriaMap(ContractSelected,'ASI_CRM_CN_Last_Payment_Checkpoint_Criteria');
            System.debug(LoggingLevel.INFO, '*** SegmentationCriteriaMap: ' + SegmentationCriteriaMap);
            for(String key: SegmentationCriteriaMap.keySet()){
                ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData temp = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData(SegmentationCriteriaMap.get(key));
                system.debug('Now get SegmentationCriteria Id'+temp.SegmentationCriteria.Id);
                temp= FirstDimensionAssignment(temp);
                temp= SecondDimensionAssignment(temp);
                
                temp= NormalPayment1stDimensionAssign(temp);
                temp= NormalPayment2ndDimensionAssign(temp);
                
                
                temp= DataOperationChecking(temp);
                if(temp.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI') && !AdorAbove){ temp.DisplayToUser=false;
                }
                
                Boolean AllowPut= true;
                
                //decide if it aloow to put 
                if(( temp.SegmentationCriteria.ASI_CRM_1st_Dimension__c!=null && temp.SegmentationCriteria.ASI_CRM_1st_Dimension__c.contains('Historical') ) || ( temp.SegmentationCriteria.ASI_CRM_2nd_Dimension__c !=null && temp.SegmentationCriteria.ASI_CRM_2nd_Dimension__c.contains('Historical') ) ){
                    if(ExistHistoricalData){ AllowPut=true;}else{ AllowPut=false;}
                }
                
                if(AllowPut  && CheckingDisplayOrNot(temp)){
                    if(temp.ReachTarget =='Yes'){ SuccessCheckPointList.add(temp);
                    }else{
                        if(temp.SegmentationCriteria.ASI_CRM_RVP_Special_Approval__c){ NeedRVPApproval=true;
                        }
                        FailedCheckPointList.add(temp);
                    }
                }
                
                
            }
        }
        
        
        if(FailedCheckPointList.size()==0){
            DisplayFailedCheckPointPart=false;
        }
        if(SuccessCheckPointList.size()==0){
            DisplaySuccessCheckPointPart=false;
        }
        
    }
    
    
     public void VolumeChecking(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){

        if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c != 'Volume mix') {
            return;
        }

        List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> intempList = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();
        for (ASI_CRM_Segmentation_Criteria_Item__c  sci : sciList) {
            ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData itd = new ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData();
            itd.chinese_Interpretation = sci.ASI_CRM_CN_Subbrand__r.Name;
            if(VolumeMixMap1.containsKey(sci.ASI_CRM_CN_Subbrand__c)){
                itd.volumeCheckResult1 = VolumeMixMap1.get(sci.ASI_CRM_CN_Subbrand__c) != null ? VolumeMixMap1.get(sci.ASI_CRM_CN_Subbrand__c):0;
            }
            if(VolumeMixMap2.containsKey(sci.ASI_CRM_CN_Subbrand__c)){
                itd.volumeCheckResult2 = VolumeMixMap2.get(sci.ASI_CRM_CN_Subbrand__c) != null ? VolumeMixMap2.get(sci.ASI_CRM_CN_Subbrand__c):0;
            }
            if(itd.volumeCheckResult1 != null  && itd.volumeCheckResult2 != null){
                itd.volumeCheckResult3 = itd.volumeCheckResult1 - itd.volumeCheckResult2;
            }
            intempList.add(itd);
        }
        VolumeCheckPortList.addAll(intempList);
    }

     @TestVisible
    private Boolean CheckingDisplayOrNot2nd(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        Boolean DisplayOrNot=true;
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Achievement Rate') ){
            if(InputInterimData.Dimension2ndResult==9999999.00 || InputInterimData.Dimension1stResult==9999999.00){ DisplayOrNot=false;
            }
        }
        
        return DisplayOrNot;
    }

     @TestVisible
    private Boolean CheckingDisplayOrNot(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        Boolean DisplayOrNot=true;
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Achievement Rate') ){
            if(InputInterimData.Dimension2ndResult==9999999.00 || InputInterimData.Dimension1stResult==9999999.00){ DisplayOrNot=false;
            }
        }
        
        return DisplayOrNot;
    }
    
    
     @TestVisible
    //First Dimension Assignment for both Normal and last Payment
    private ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData NormalPayment1stDimensionAssign2nd (ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Payment Speed') ){
            InputInterimData.Dimension1stResult= PaymentSpeed.SetSCale(0);
            //InputInterimData.Display1stResult= ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+' = '+InputInterimData.Dimension1stResult.SetSCale(0)+'%';
            //InputInterimData.Display1stResultEN= InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c +' = '+InputInterimData.Dimension1stResult.SetSCale(0)+'%';
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Achievement Rate') ){
            InputInterimData.Dimension1stResult= PaymentKPIMap.containsKey('MKSSBAR')?PaymentKPIMap.get('MKSSBAR').SetSCale(2):0 ;
            //InputInterimData.Display1stResult= ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+' = '+InputInterimData.Dimension1stResult.SetSCale(2)+'%';
            //InputInterimData.Display1stResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c+' = '+InputInterimData.Dimension1stResult.SetSCale(2)+'%';
        }
        return InputInterimData;
    }

    @TestVisible
    //First Dimension Assignment for both Normal and last Payment
    private ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData NormalPayment1stDimensionAssign (ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Payment Speed') ){
            InputInterimData.Dimension1stResult= PaymentSpeed.SetSCale(0);
            //InputInterimData.Display1stResult= ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+' = '+InputInterimData.Dimension1stResult.SetSCale(0)+'%';
            //InputInterimData.Display1stResultEN= InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c +' = '+InputInterimData.Dimension1stResult.SetSCale(0)+'%';
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Achievement Rate') ){InputInterimData.Dimension1stResult= PaymentKPIMap.containsKey('MKSSBAR')?PaymentKPIMap.get('MKSSBAR').SetSCale(2):0 ;
            //InputInterimData.Display1stResult= ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+' = '+InputInterimData.Dimension1stResult.SetSCale(2)+'%';
            //InputInterimData.Display1stResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c+' = '+InputInterimData.Dimension1stResult.SetSCale(2)+'%';
        }
        return InputInterimData;
    }



    @TestVisible
    //2nd Dimension Assignment for last payment both Normal and last Payment
    private ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData NormalPayment2ndDimensionAssign2nd (ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Payment Speed') ){
            InputInterimData.Dimension2ndResult=VolumeSpeed.SetSCale(0);
            //InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c) +' = '+InputInterimData.Dimension2ndResult.SetSCale(2)+'%';
            //InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c +' = '+InputInterimData.Dimension2ndResult.SetSCale(2)+'%';
            
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Achievement Rate') ){ InputInterimData.Dimension2ndResult= PaymentKPIMap.containsKey('PSFBySubBrandAchievementRate')?PaymentKPIMap.get('PSFBySubBrandAchievementRate').SetSCale(2):0 ;
            //InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c) +' = '+InputInterimData.Dimension2ndResult.SetSCale(2)+'%';
            //InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c+' = '+InputInterimData.Dimension2ndResult.SetSCale(2)+'%';
        }
        return InputInterimData;
    }

    @TestVisible
    //2nd Dimension Assignment for last payment both Normal and last Payment
    private ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData NormalPayment2ndDimensionAssign (ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Payment Speed') ){
            InputInterimData.Dimension2ndResult=VolumeSpeed.SetSCale(0);
            //InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c) +' = '+InputInterimData.Dimension2ndResult.SetSCale(2)+'%';
            //InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c +' = '+InputInterimData.Dimension2ndResult.SetSCale(2)+'%';
            
        }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Achievement Rate') ){ InputInterimData.Dimension2ndResult= PaymentKPIMap.containsKey('PSFBySubBrandAchievementRate')?PaymentKPIMap.get('PSFBySubBrandAchievementRate').SetSCale(2):0 ;
            //InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c) +' = '+InputInterimData.Dimension2ndResult.SetSCale(2)+'%';
            //InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c+' = '+InputInterimData.Dimension2ndResult.SetSCale(2)+'%';
        }
        return InputInterimData;
    }


    
    @TestVisible
    //perform data level checking 
    public ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData DataOperationChecking2nd(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        String FinancialIndicator = InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c;
        InputInterimData.english_Interpretation = InputInterimData.SegmentationCriteria.ASI_CRM_English_Interpretation__c;
        InputInterimData.chinese_Interpretation = InputInterimData.SegmentationCriteria.ASI_CRM_Chinese_Interpretation__c;
        //Number checking 
        if(FinancialIndicator.contains('Volume') || FinancialIndicator.contains('Trade Expenses') || 
           FinancialIndicator.contains('BC') || FinancialIndicator.contains('Payment Speed') || 
           FinancialIndicator.contains('Achievement') || FinancialIndicator == 'Contract Index' || FinancialIndicator  == 'CM/NS%' || FinancialIndicator  == 'vs Regional average index'){
            Decimal Dimension2Value1 = ASI_CRM_CN_HeavyCheckPointResultCtrl.GenerateDimension2Number1(InputInterimData);//Min
            Decimal Dimension2Value2= ASI_CRM_CN_HeavyCheckPointResultCtrl.GenerateDimension2Number2(InputInterimData);// Max
            
            
            if(!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c,InputInterimData.Dimension1stResult,Dimension2Value1,Dimension2Value2)){
                InputInterimData.ReachTarget ='No';
            }
            
            InputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+'= '+InputInterimData.Dimension1stResult.format();
            InputInterimData.Display1stResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c+' = '+InputInterimData.Dimension1stResult.format(); 
            
            
            
            if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c!=null ){
                InputInterimData.Display2ndResult=  ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c) ;
                InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c; 
            }else{InputInterimData.Display2ndResultEN='Theoretical Value';
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Theoretical Value');
            }
            
            
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c !='Within'){ 
                InputInterimData.Display2ndResult += ' = '+InputInterimData.Dimension2ndResult.format();
                InputInterimData.Display2ndResultEN += ' = '+InputInterimData.Dimension2ndResult.format();
            }else{InputInterimData.Display2ndResult+= ' :<br/> 最小值=  '+Dimension2Value1.format() +'<br/> 最大值='+Dimension2Value2.format();
                InputInterimData.Display2ndResultEN+= ' :<br/>  Min= '+Dimension2Value1.format()+'<br/> Max='+Dimension2Value2.format();
            }
            if (FinancialIndicator  == 'CM/NS%' || Test.isRunningTest()) {
                InputInterimData.Display1stResult = InputInterimData.Display1stResult + '%';
                InputInterimData.Display1stResultEN = InputInterimData.Display1stResultEN + '%';
                InputInterimData.Display2ndResult = InputInterimData.Display2ndResult + '%';
                InputInterimData.Display2ndResultEN = InputInterimData.Display2ndResultEN + '%';
            }
        }else if(FinancialIndicator =='Period: PO Start Date'){
            if(InputInterimData.Period1stResult<InputInterimData.Period2ndResult){InputInterimData.ReachTarget ='No';
            }
            InputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+' = '+ InputInterimData.Period1stResult;
            
        }else if(FinancialIndicator =='Methodology: BRSF Methodology'){
            if(InputInterimData.Type1stName != InputInterimData.Type2ndName){InputInterimData.ReachTarget ='No';
            }
        }
        
        
        return InputInterimData;
    }

    @TestVisible
    //perform data level checking 
    public ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData DataOperationChecking(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        String FinancialIndicator = InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c;
        
        //Number checking 
        if(FinancialIndicator.contains('Volume') || FinancialIndicator.contains('Trade Expenses') ||  FinancialIndicator.contains('BC') || FinancialIndicator.contains('Payment Speed') || FinancialIndicator.contains('Achievement') ){
            Decimal Dimension2Value1 = ASI_CRM_CN_HeavyCheckPointResultCtrl.GenerateDimension2Number1(InputInterimData);//Min
            Decimal Dimension2Value2= ASI_CRM_CN_HeavyCheckPointResultCtrl.GenerateDimension2Number2(InputInterimData);// Max
            
            
            if(!ASI_CRM_CN_HeavyContractUtilitiesClass.NumberOperationChecking(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c,InputInterimData.Dimension1stResult,Dimension2Value1,Dimension2Value2)){
                InputInterimData.ReachTarget ='No';
            }
            
            InputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+'= '+InputInterimData.Dimension1stResult;
            InputInterimData.Display1stResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c+' = '+InputInterimData.Dimension1stResult; 
            
            
            
            if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c!=null ){
                InputInterimData.Display2ndResult=  ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c) ;
                InputInterimData.Display2ndResultEN=InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c; 
            }else{InputInterimData.Display2ndResultEN='Theoretical Value';
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Theoretical Value');
            }
            
            
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Operation__c !='Within'){ 
                InputInterimData.Display2ndResult += ' = '+InputInterimData.Dimension2ndResult;
                InputInterimData.Display2ndResultEN += ' = '+InputInterimData.Dimension2ndResult;
            }else{InputInterimData.Display2ndResult+= ' :<br/> 最小值=  '+Dimension2Value1 +'<br/> 最大值='+Dimension2Value2;
                InputInterimData.Display2ndResultEN+= ' :<br/>  Min= '+Dimension2Value1+'<br/> Max='+Dimension2Value2;
            }

            
        }else if(FinancialIndicator =='Period: PO Start Date'){
            if(InputInterimData.Period1stResult<InputInterimData.Period2ndResult){InputInterimData.ReachTarget ='No';
            }
            InputInterimData.Display1stResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_1st_Dimension__c)+' = '+ InputInterimData.Period1stResult;
            
        }else if(FinancialIndicator =='Methodology: BRSF Methodology'){
            if(InputInterimData.Type1stName != InputInterimData.Type2ndName){InputInterimData.ReachTarget ='No';
            }
        }
        
        
        return InputInterimData;
    }
    
    
    
    
    //2nd Dimension Assignment for last payment 
    public ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData SecondDimensionAssignment2nd(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')){  InputInterimData.Dimension2ndResult = ByVolumeFinancialIndicator2nd(InputInterimData.SegmentationCriteria,'2');
        }else{
            if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c !=null){
                ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd FIMasterData = FinancialIndicatorMasterData2nd(InputInterimData.SegmentationCriteria,'2');
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Fixed Expense %'){ InputInterimData.Dimension2ndResult= FIMasterData.FixedExpenseRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){ InputInterimData.Dimension2ndResult= FIMasterData.InvestmentCR12;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI') ){InputInterimData.Dimension2ndResult= FIMasterData.ROIIntake;
                    //InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI'
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='BC: BC%'){ InputInterimData.Dimension2ndResult= FIMasterData.BCRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Martell BC Rate'){InputInterimData.Dimension2ndResult= FIMasterData.BCRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date'){ InputInterimData.Period2ndResult= FIMasterData.POStartDate;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology'){ InputInterimData.Type2ndName=FIMasterData.BRSFMethodologyName;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Payment Speed: Trade Expense (Excl. Fixed Cost)'){
                    InputInterimData.Dimension2ndResult=VolumeSpeed;
                    InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%')+'='+VolumeSpeed.SetSCale(0);
                }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'CM/NS%') {
                    InputInterimData.Dimension2ndResult= FIMasterData.CMNSRate.SetSCale(2);
                }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Contract Index') {
                    InputInterimData.Dimension2ndResult= FIMasterData.DomesticContractIndexProForma.SetSCale(2);
                }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Volume mix') {
                    for(ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd at : FIMasterData.TradeExpenseBySubBrand){
                        System.debug('at.propByStdTotal'+at.propByStdTotal);
                        VolumeMixMap2.put(at.subBrandId,at.propByStdTotal *100);
                    }
                }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'vs Regional average index') {
                    InputInterimData.Dimension2ndResult= FIMasterData.VsRegionalAverageIndexProForma.SetSCale(2);
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
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PRC Guidance'){InputInterimData.Dimension2ndResult=PRCGuidance;
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c)+'='+PRCGuidance;
            }
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PO Submit Date'){InputInterimData.Period2ndResult=date.today();InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c)+' : Today';
            }
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PRC Default Methodology'){
                //InputInterimData.Type2ndName='By Sub-brand';
            }
        }else{
            
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Trade Expenses') ||  InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('BC') )
            {
                if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c!=null ){InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);
                }else{
                    InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Theoretical Value');//InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c;
                }
                
                
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('BC') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Fixed Expense')){
                    InputInterimData.Dimension2ndResult= InputInterimData.Dimension2ndResult.SetSCale(0);
                    InputInterimData.Display2ndResult+=' = '+InputInterimData.Dimension2ndResult.SetSCale(0);
                }else{
                   InputInterimData.Display2ndResult+=' = '+InputInterimData.Dimension2ndResult.SetSCale(2); 
                }
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c =='Period: PO Start Date'){InputInterimData.Display2ndResult= ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c)+'='+InputInterimData.Period2ndResult;
               
            }
            
        }
        
        
        
        return InputInterimData; 
    }

    //2nd Dimension Assignment for last payment 
    public ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData SecondDimensionAssignment(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')){  InputInterimData.Dimension2ndResult = ByVolumeFinancialIndicator(InputInterimData.SegmentationCriteria,'2');
        }else{
            if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c !=null){
                ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria,'2');
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Fixed Expense %'){ InputInterimData.Dimension2ndResult= FIMasterData.FixedExpenseRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){ InputInterimData.Dimension2ndResult= FIMasterData.InvestmentCR12;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI') ){InputInterimData.Dimension2ndResult= FIMasterData.ROIIntake;
                    //InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI'
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='BC: BC%'){ InputInterimData.Dimension2ndResult= FIMasterData.BCRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Martell BC Rate'){InputInterimData.Dimension2ndResult= FIMasterData.BCRate;
                }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date'){ InputInterimData.Period2ndResult= FIMasterData.POStartDate;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology'){ InputInterimData.Type2ndName=FIMasterData.BRSFMethodologyName;
                }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Payment Speed: Trade Expense (Excl. Fixed Cost)'){
                    InputInterimData.Dimension2ndResult=VolumeSpeed;
                    InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Volume Speed%')+'='+VolumeSpeed.SetSCale(0);
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
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PRC Guidance'){InputInterimData.Dimension2ndResult=PRCGuidance;
                InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c)+'='+PRCGuidance;
            }
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PO Submit Date'){InputInterimData.Period2ndResult=date.today();InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c)+' : Today';
            }
            if( InputInterimData.SegmentationCriteria.AS_CRM_Predefined_Theoretical_Value__c=='PRC Default Methodology'){
                //InputInterimData.Type2ndName='By Sub-brand';
            }
        }else{
            
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Trade Expenses') ||  InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('BC') )
            {
                if(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c!=null ){InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c);
                }else{
                    InputInterimData.Display2ndResult=ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation('Theoretical Value');//InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c;
                }
                
                
                if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('BC') || InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Fixed Expense')){
                    InputInterimData.Dimension2ndResult= InputInterimData.Dimension2ndResult.SetSCale(0);
                    InputInterimData.Display2ndResult+=' = '+InputInterimData.Dimension2ndResult.SetSCale(0);
                }else{
                   InputInterimData.Display2ndResult+=' = '+InputInterimData.Dimension2ndResult.SetSCale(2); 
                }
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c =='Period: PO Start Date'){InputInterimData.Display2ndResult= ASI_CRM_CN_HeavyContractUtilitiesClass.CheckPointTranslation(InputInterimData.SegmentationCriteria.ASI_CRM_2nd_Dimension__c)+'='+InputInterimData.Period2ndResult;
               
            }
            
        }
        
        
        
        return InputInterimData; 
    }
    
  
    //First Dimension Assignment
    public ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData FirstDimensionAssignment2nd(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')){InputInterimData.Dimension1stResult = ByVolumeFinancialIndicator2nd(InputInterimData.SegmentationCriteria,'1');
            InputInterimData.Dimension1stResult = InputInterimData.Dimension1stResult.SetSCale(0);
        }else{
            ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd FIMasterData = FinancialIndicatorMasterData2nd(InputInterimData.SegmentationCriteria,'1');
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Fixed Expense %'){InputInterimData.Dimension1stResult= FIMasterData.FixedExpenseRate.SetSCale(0);
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){InputInterimData.Dimension1stResult= FIMasterData.InvestmentCR12.SetSCale(2);
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI')){InputInterimData.Dimension1stResult= FIMasterData.ROIIntake.SetSCale(2);
                //InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI'
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='BC: BC%'){ InputInterimData.Dimension1stResult= FIMasterData.BCRate.SetSCale(0);
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Martell BC Rate'){ InputInterimData.Dimension1stResult= FIMasterData.TotalMBCRate.SetSCale(0);
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date'){ InputInterimData.Period1stResult= FIMasterData.POStartDate;
            }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology'){ InputInterimData.Type1stName=FIMasterData.BRSFMethodologyName;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Payment Speed: Trade Expense (Excl. Fixed Cost)'){
                 InputInterimData.Dimension1stResult= PaymentSpeed.SetSCale(0);
            }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'CM/NS%') {
                InputInterimData.Dimension1stResult= FIMasterData.CMNSRate.SetSCale(2);
            }else if (InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c== 'Contract Index') {
                InputInterimData.Dimension1stResult= FIMasterData.DomesticContractIndexProForma.SetSCale(2);
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
                InputInterimData.Dimension1stResult= FIMasterData.VsRegionalAverageIndexProForma.SetSCale(2);
            }
        }     
        return InputInterimData;
    }

    //First Dimension Assignment
    public ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData FirstDimensionAssignment(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData InputInterimData){
        
        if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Volume:')){InputInterimData.Dimension1stResult = ByVolumeFinancialIndicator(InputInterimData.SegmentationCriteria,'1');
            InputInterimData.Dimension1stResult = InputInterimData.Dimension1stResult.SetSCale(0);
        }else{
            ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputInterimData.SegmentationCriteria,'1');
            if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Fixed Expense %'){InputInterimData.Dimension1stResult= FIMasterData.FixedExpenseRate.SetSCale(0);
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: Investment per CR12 eq btl'){InputInterimData.Dimension1stResult= FIMasterData.InvestmentCR12.SetSCale(2);
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI')){InputInterimData.Dimension1stResult= FIMasterData.ROIIntake.SetSCale(2);
                //InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Trade Expenses: ROI'
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='BC: BC%'){ InputInterimData.Dimension1stResult= FIMasterData.BCRate.SetSCale(0);
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Martell BC Rate'){ InputInterimData.Dimension1stResult= FIMasterData.TotalMBCRate.SetSCale(0);
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Period: PO Start Date'){ InputInterimData.Period1stResult= FIMasterData.POStartDate;
            }else if( InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Methodology: BRSF Methodology'){ InputInterimData.Type1stName=FIMasterData.BRSFMethodologyName;
            }else if(InputInterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Payment Speed: Trade Expense (Excl. Fixed Cost)'){
                 InputInterimData.Dimension1stResult= PaymentSpeed.SetSCale(0);
            }
        }     
        return InputInterimData;
    }
    
    public Decimal ByVolumeFinancialIndicator2nd(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria,String Dimension){
        Decimal ReturnResult=0.0;
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd FIMasterData = FinancialIndicatorMasterData2nd(InputSegmentationCriteria,Dimension);
        if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Volume: Total'){ ReturnResult = FIMasterData.Volumes;
        }else if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains(' - ')){
            List<String> parts = InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.split(' - ');
            String GroupingName = parts[1];
            if (InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Category')){
                if(FIMasterData.CategoryMap.size()>0){
                    if(FIMasterData.CategoryMap.containskey(GroupingName) && FIMasterData.CategoryMap.get(GroupingName) !=null ){ ReturnResult=FIMasterData.CategoryMap.get(GroupingName);
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
        
        return ReturnResult;
    }

    public Decimal ByVolumeFinancialIndicator(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria,String Dimension){
        Decimal ReturnResult=0.0;
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FIMasterData = FinancialIndicatorMasterData(InputSegmentationCriteria,Dimension);
        if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c=='Volume: Total'){ ReturnResult = FIMasterData.Volumes;
        }else if(InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains(' - ')){
            List<String> parts = InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.split(' - ');
            String GroupingName = parts[1];
            if (InputSegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('Category')){
                if(FIMasterData.CategoryMap.size()>0){
                    if(FIMasterData.CategoryMap.containskey(GroupingName) && FIMasterData.CategoryMap.get(GroupingName) !=null ){ ReturnResult=FIMasterData.CategoryMap.get(GroupingName);
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
        
        return ReturnResult;
    }
    
    
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd FinancialIndicatorMasterData2nd(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria,String Dimension){
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd RetuenFI= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd();
        if(Dimension == '1'){
            if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='Historical V0.0'){RetuenFI = HistoricalV00Contract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='Historical Vfinal'){RetuenFI =HistoricalVFinalContract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contact V0.0 Contract'){ RetuenFI = NewContactV0Contract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contract V0.0 Est.'){RetuenFI= NewContractV0Esitimate2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contract V Final'){RetuenFI=NewContactVFinal2nd;
            }
        }else{
            if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Historical V0.0'){RetuenFI = HistoricalV00Contract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Historical Vfinal'){ RetuenFI =HistoricalVFinalContract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contact V0.0 Contract'){ RetuenFI = NewContactV0Contract2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contract V0.0 Est.'){
                RetuenFI= NewContractV0Esitimate2nd;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contract V Final'){ RetuenFI=NewContactVFinal2nd;
            }
        }
        
        return RetuenFI;
    }

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator FinancialIndicatorMasterData(ASI_CRM_SegmentationCriteria__c InputSegmentationCriteria,String Dimension){
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator RetuenFI= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator();
        if(Dimension == '1'){
            if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='Historical V0.0'){RetuenFI = HistoricalV00Contract;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='Historical Vfinal'){RetuenFI =HistoricalVFinalContract;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contact V0.0 Contract'){ RetuenFI = NewContactV0Contract;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contract V0.0 Est.'){RetuenFI= NewContractV0Esitimate;
            }else if(InputSegmentationCriteria.ASI_CRM_1st_Dimension__c=='New Contract V Final'){RetuenFI=NewContactVFinal;
            }
        }else{
            if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Historical V0.0'){RetuenFI = HistoricalV00Contract;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='Historical Vfinal'){ RetuenFI =HistoricalVFinalContract;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contact V0.0 Contract'){ RetuenFI = NewContactV0Contract;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contract V0.0 Est.'){
                RetuenFI= NewContractV0Esitimate;
            }else if(InputSegmentationCriteria.ASI_CRM_2nd_Dimension__c=='New Contract V Final'){ RetuenFI=NewContactVFinal;
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
    
    
    
    
    public pageReference proceed() {
        
        Msg='';
        
        ProcessPermission=true;
        
        ValidationChecking();
        
      
        if(ProcessPermission){
            
          
            
            //submit for approval 
            try{
                if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    PreSaveRecord2nd();
                } else {
                    PreSaveRecord();
                }
                
                Date VolumeCutOffDate=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
                //update Volume Cut Off Date
                PaymentRequest.ASI_CRM_Volume_Cut_Off_Date__c=VolumeCutOffDate;
                IF(NeedRVPApproval){ PaymentRequest.ASI_CRM_RVP_Approval__c=TRUE; 
                }ELSE{
                    PaymentRequest.ASI_CRM_RVP_Approval__c=FALSE; 
                }
                
                update PaymentRequest;
                
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(PaymentRequest.id);
                Approval.ProcessResult result = Approval.process(req1);            
            }catch(Exception e){  String msgstr = 'submit for approval Error : ' +e.getMessage();
                ASI_MFM_ByPass_Setting.ErrorHandling('submit for approval '+ msgstr+' with Payment Request Id '+PaymentRequest.id  , 'ASI_CRM_CN_HeavyPaymentCheckCtrl','ASI_CRM_CN_HeavyPaymentCheckCtrl.proceed');
            }
            
            return new pageReference('/' + PaymentRequest.id);
        }
        else{
            return null;
        }
        
        
    }
    
    public void PreSaveRecord2nd(){
          List<ASI_Attachment__c> AttachmentList= new  List<ASI_Attachment__c>();
            try{
                
                String  SuccessCheckPointString= System.JSON.serialize(SuccessCheckPointList2nd);
                SuccessCheckPointString=SuccessCheckPointString.replaceAll('<','&lt;');
                SuccessCheckPointString=SuccessCheckPointString.replaceAll('>','&gt;');
                               
                String  FailedCheckPointString= System.JSON.serialize(FailedCheckPointList2nd);
                FailedCheckPointString=FailedCheckPointString.replaceAll('<','&lt;');
               
                FailedCheckPointString=FailedCheckPointString.replaceAll('>','&gt;');

                AttachmentList= [SELECT id,
                                        ASI_CRM_Historical_Financial_Data__c,
                                        ASI_CRM_Contract__c,
                                        ASI_CRM_Type__c 
                                 FROM ASI_Attachment__c 
                                 WHERE ASI_CRM_Payment_Request__c = :PaymentRequest.Id 
                                 AND ASI_CRM_Type__c like 'CheckPoint%'];
                if(AttachmentList.size()>0){//exist
                    for(ASI_Attachment__c attachment:AttachmentList){

                        //System.JSON.serialize(SuccessCheckPointList2nd) ; 
                        if(attachment.ASI_CRM_Type__c=='CheckPoint-Success'){ 
                            attachment.ASI_CRM_Historical_Financial_Data__c=SuccessCheckPointString;
                        }

                        //System.JSON.serialize(FailedCheckPointList2nd) ; 
                        if(attachment.ASI_CRM_Type__c=='CheckPoint-Failed'){ 
                            attachment.ASI_CRM_Historical_Financial_Data__c=FailedCheckPointString;
                        }
                    }
                }else if(AttachmentList.size() ==0 ){
                    AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Payment_Request__c=PaymentRequest.id,
                                                             ASI_CRM_Type__c='CheckPoint-Success',
                                                             ASI_CRM_For_Contract_Use__c=true,
                                                             ASI_CRM_Historical_Financial_Data__c=System.JSON.serialize(SuccessCheckPointList2nd)));
                    AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Payment_Request__c=PaymentRequest.id,
                                                             ASI_CRM_Type__c='CheckPoint-Failed',
                                                             ASI_CRM_For_Contract_Use__c=true,
                                                             ASI_CRM_Historical_Financial_Data__c=System.JSON.serialize(FailedCheckPointList2nd)));
                }
                upsert AttachmentList;
            }catch(Exception e){  
                String msgstr = 'Upsert ASI_CRM_CN_HeavyCheckPointResultPage Attachment  Error : ' +e.getMessage();
                ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '
                                                        + msgstr
                                                        + ' with Payment Request Id '
                                                        + PaymentRequest.id 
                                                        + ' with Json string : '
                                                        + System.JSON.serialize(FailedCheckPointList2nd) , 'ASI_CRM_CN_HeavyPaymentCheckCtrl','ASI_CRM_CN_HeavyPaymentCheckCtrl.proceed');
            }
    }

    public void PreSaveRecord(){
          List<ASI_Attachment__c> AttachmentList= new  List<ASI_Attachment__c>();
            try{
                
                String  SuccessCheckPointString= System.JSON.serialize(SuccessCheckPointList);
                SuccessCheckPointString=SuccessCheckPointString.replaceAll('<','&lt;');
                SuccessCheckPointString=SuccessCheckPointString.replaceAll('>','&gt;');
                               
                String  FailedCheckPointString= System.JSON.serialize(FailedCheckPointList);
                FailedCheckPointString=FailedCheckPointString.replaceAll('<','&lt;');
               
                FailedCheckPointString=FailedCheckPointString.replaceAll('>','&gt;');

                
                AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c 
                                 where ASI_CRM_Payment_Request__c = :PaymentRequest.Id and ASI_CRM_Type__c like 'CheckPoint%'];
                if(AttachmentList.size()>0){//exist
                    for(ASI_Attachment__c attachment:AttachmentList){
                        if(attachment.ASI_CRM_Type__c=='CheckPoint-Success'){ attachment.ASI_CRM_Historical_Financial_Data__c=SuccessCheckPointString;//System.JSON.serialize(SuccessCheckPointList) ; 
                        }
                        if(attachment.ASI_CRM_Type__c=='CheckPoint-Failed'){ attachment.ASI_CRM_Historical_Financial_Data__c=FailedCheckPointString;//System.JSON.serialize(FailedCheckPointList) ; 
                        }
                    }
                }else if(AttachmentList.size() ==0 ){
                    AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Payment_Request__c=PaymentRequest.id,ASI_CRM_Type__c='CheckPoint-Success',ASI_CRM_For_Contract_Use__c=true,
                                                             ASI_CRM_Historical_Financial_Data__c=System.JSON.serialize(SuccessCheckPointList)));
                    AttachmentList.add(new ASI_Attachment__c(ASI_CRM_Payment_Request__c=PaymentRequest.id,ASI_CRM_Type__c='CheckPoint-Failed',ASI_CRM_For_Contract_Use__c=true,
                                                             ASI_CRM_Historical_Financial_Data__c=System.JSON.serialize(FailedCheckPointList)));
                }
                upsert AttachmentList;
            }catch(Exception e){  String msgstr = 'Upsert ASI_CRM_CN_HeavyCheckPointResultPage Attachment  Error : ' +e.getMessage();
                ASI_MFM_ByPass_Setting.ErrorHandling('UpsertAttachment '+ msgstr+' with Payment Request Id '+PaymentRequest.id + ' with Json string : '+ System.JSON.serialize(FailedCheckPointList) , 'ASI_CRM_CN_HeavyPaymentCheckCtrl','ASI_CRM_CN_HeavyPaymentCheckCtrl.proceed');
            }
            
    }
    
    
    public void ValidationChecking(){
        //ContractSelected
        //Last Payment checking
        /*
        for(ASI_TH_CRM_PaymentRequest__c paymentTemp:ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {    
            if(paymentTemp.ASI_CRM_CN_Last_Payment__c==true && paymentTemp.ASI_TH_CRM_Status__c!='Draft'){
                ErrorHandling(Label.ASI_CRM_CN_ErrorMsg_MakePayment+paymentTemp.Name);
            }
        }
       
        
        //checking payment summary
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        PaymentSummaryList = ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(PaymentRequest,ContractSelected);
        for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary SummaryData:PaymentSummaryList){
            Decimal PORemainAmt=SummaryData.POEstimatedAmount-SummaryData.PaidAmount;
            if(SummaryData.PaymentRequestAmount>PORemainAmt+1){
                ErrorHandling(SummaryData.Name+Label.ASI_CRM_CN_Account_payment_amount_Checking);
            }
        }
         
        
        Decimal sum_of_payee_amount=0;
        //checking payee
         List<ASI_CRM_CN_PH_Payee_Line_Item__c> LPHPayeeAll = [SELECT ASI_CRM_CN_Amount__c, ASI_CRM_CN_Cash_Discount__c, ASI_CRM_CN_Cash_Amount__c, ASI_CRM_CN_Discount_Amount__c,
                                                                  ASI_CRM_CN_Payment_Request__c, ASI_CRM_CN_Type__c,ASI_CRM_CN_Payee_T1__r.Name, ASI_CRM_CN_Payee_T1__c, ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T1__r.Name,
                                                                  ASI_CRM_CN_Reason__c , ASI_CRM_CN_Payee_T2__r.Name, ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Comfirm_Receipt__c,
                                                                  ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name, RecordTypeId, ASI_CRM_CN_Instruction_Sent_Time__c
                                                                  FROM ASI_CRM_CN_PH_Payee_Line_Item__c
                                                                  WHERE ASI_CRM_CN_Payment_Request__c = :PaymentRequest.Id and
                                                                  (ASI_CRM_CN_Type__c = 'Cash' or ASI_CRM_CN_Type__c = 'Discount' or ASI_CRM_CN_Type__c = 'Others' OR ASI_CRM_CN_Type__c = 'CD')];
        
        for(ASI_CRM_CN_PH_Payee_Line_Item__c PayeeLine:LPHPayeeAll){
            sum_of_payee_amount+=PayeeLine.ASI_CRM_CN_Amount__c!=null?PayeeLine.ASI_CRM_CN_Amount__c:0;
        }
        Decimal TotalAmount=(FixedCostTotal+VariableCostTotal);
        if(math.abs(sum_of_payee_amount-TotalAmount)>0.1){
             String tempStr = Label.ASI_CRM_CN_Payment_total_amount_no_consistent;
            Decimal payee_amount= sum_of_payee_amount.setScale(2, RoundingMode.HALF_UP);
            List<String> fillers = new String[] {payee_amount.format(),+TotalAmount.setScale(2, RoundingMode.HALF_UP).format()};
                ErrorHandling(String.format(tempStr,fillers));
        }
        
        
         if (TotalAmount  > PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c){
             String tempStr = Label.ASI_CRM_Payee_Amount_checking;
             List<String> fillers = new String[] {TotalAmount.format(),PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c.format()};
                 ErrorHandling(String.format(tempStr,fillers)); //ErrorHandling('付款金额 > PO金额！需修改付款明细并重新提交。付款金额：'+TotalAmount.format()+'    PO金额：'+PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c);
         }
        
         */
        
        
        //****************Business License Checking ****************   
        Decimal TotalAmountChecking=1000000;
        Decimal FixedAmountChecking=50000;
        // 2020-10-29 HCO付款校验合同状态，只有final状态才能提交，add by zhonghui
        if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c != 'Final') {
            ErrorHandling(Label.ASI_CRM_CN_PaymentSubmitCheckFinalPO);
        }        
        ASI_CRM_CN_CustomSetting__c checking =[select id,ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c,ASI_CRM_Total_Amount_Checking__c from ASI_CRM_CN_CustomSetting__c ][0];
        
        if(checking.ASI_CRM_Total_Amount_Checking__c!=null){
            TotalAmountChecking =checking.ASI_CRM_Total_Amount_Checking__c;
        }
        
        if(checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c!=null){
            FixedAmountChecking =checking.ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c;
        }
        
        
        // IF(FixedCostTotal>0){
            if((FixedCostTotal + VariableCostTotal)>=TotalAmountChecking  
                || 
               FixedCostTotal >=FixedAmountChecking){
                if(!PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_BusinessLicenseUploading__c){ProcessPermission=false;
                    Msg+=Label.ASI_CRM_CN_Business_License_not_uploaded+'.<br/>';//'Please note that Business License have not uploaded.<br/>';
                }else{
                    if(PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c !=null){
                        if(PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c< PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Start_Date__c){
                            ProcessPermission=false;
                            Msg+=Label.ASI_CRM_CN_Business_License_after_PO_start_Date_Error+'.<br/>';//'Please note that the Start Date of Business License is after the PO start Date.<br/>';
                        }
                    }
                    if(!PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c){
                        if(PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c !=null){
                            if(PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c >PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Business_License_Expire_date__c){ProcessPermission=false;
                                Msg+=Label.ASI_CRM_CN_Business_License_before_PO_end_Date_Error+'.<br/>';//'Please note that the End Date of Business License is before the PO end Date.<br/>';
                            }
                        }
                    }
                }
            }
        // }
    }
    
    
     public void ErrorHandling(String ErrorMsg){ 
        Msg += ErrorMsg + '<br/> ';
      
        ProcessPermission = false;
    }
    
    
    public void checkUserID(){
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0)
            AdorAbove = true;
    }
}