/* Filename:    ASI_CRM_CN_EditHeavyPaymentDetailCtrl.cls
* Author:      Laputa
* Purpose:     Controller Class for payment request (new, edit, input payee, input payment detail) for CN CRM 4.2
* History
* -----------------------------------------------------------------------------
* 2017-05-25   Laputa      Created
*/


public without sharing class ASI_CRM_CN_EditHeavyPaymentDetailCtrl {
    public ASI_TH_CRM_PaymentRequest__c PH {set;get;}
    public string PageId {set;get;}
    
    public String RowId {set;get;}
    //Line Detail
    public interimData BRSFItemMap {set;get;} {BRSFItemMap= new interimData();}
    //PSF
    public map<String, interimData> PSF_Item_Map {set;get;} {PSF_Item_Map= new map<String, interimData>();}
    //Fixed
    public map<String, interimData> Fixed_Item_Map {set;get;} {Fixed_Item_Map= new map<String, interimData>();}
    //Variable Event Cost
    public interimData VariableEventCost {set;get;} {VariableEventCost= new interimData();} // Variable Event Cost= VEC
    
    //Other Payment Detail
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> OtherPaymentLineList {set;get;}  {OtherPaymentLineList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();}
    
    public Boolean DisplayVEC {set;get;}  {DisplayVEC=false;}
    
    public Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  {get;set;}{SubBrandGradeMap= new Map<String, ASI_CRM_Sub_Brand_Grade__c>();}
    
    //@description : new line count
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}    
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentLineDeleteList {get;set;}{PaymentLineDeleteList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();}
    
    public String Msg {get;set;} {Msg='';}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public boolean showCN {set;get;}
    public list<ASI_CRM_Module__c> HistoricalModuleList {get;set;}{HistoricalModuleList=new list<ASI_CRM_Module__c>();}
    public List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList {set;get;}{PaymentSummaryList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary>();}

    public Decimal MaxIncentive=99999;

    public ASI_CRM_CN_EditHeavyPaymentDetailCtrl(ApexPages.StandardController controller) {
        this.PH = (ASI_TH_CRM_PaymentRequest__c)controller.getRecord();
        PageId = PH.id;
        list <ASI_TH_CRM_PaymentRequest__c> HeaderList  = new list <ASI_TH_CRM_PaymentRequest__c>();
        
        //Get Header information
        if (PageId != null){
            HeaderList = [SELECT id, name, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,ASI_CRM_Total_Variable_Amount__c,
                          ASI_CRM_Total_Actual_Amount__c,ASI_CRM_CN_Payable_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c,
                          ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c,ASI_TH_CRM_Contract__r.ASI_CRM_Martell_BC_Rate__c,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c ,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,
                          ASI_CRM_CN_Other_Reason__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, 
                          ASI_CRM_CN_BRSF_Start_Date__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_Last_Year_Payment__c,
                          ASI_CRM_CN_Division__c,ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, ASI_CRM_CN_PO_End_Date__c,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, 
                          ASI_CRM_Volume_Option__c,ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                          ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_BRSF__c, 
                          ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c, 
                          ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_VEC__c, 
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c, 
                          ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, ASI_CRM_CN_PO_Version_Latest__c, 
                          ASI_CRM_CN_Overpayment_Reason__c,ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, ASI_CRM_CN_Business_License_Qualify__c ,
                          ASI_CRM_CN_Total_PSF_Amount__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c   ,
                          ASI_CRM_CN_Total_Payment__c , ASI_CRM_CN_Overpayment_Comment__c,ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, 
                          ASI_CRM_CN_Total_BRSF_Actual_Amount__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c  ,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c, ASI_CRM_New_FY_Payment__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c
                          FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
            
        }
        if (HeaderList.size()> 0){
            this.PH = HeaderList[0]; 
        }
        init();
    }
    
    
    
    public void init(){
        DisplayVEC=false;
        showCN = USerInfo.getLanguage()=='zh_CN';
        PH.ASI_CRM_Total_Actual_Amount__c=0;
        //Looping the Sub-Brand Grade
        for(ASI_CRM_Sub_Brand_Grade__c sbg:ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c )){
            if(sbg.ASI_CRM_CN_City_Tier__c!=null){
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }
            SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
        }
        
        //Module : Map <Id, ASI_CRM_Module__c> 
        Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>(); 
        Set<Id> ParentModuleIdSet = new Set<Id>();
        
        for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Completion_Ratio__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Parent_Module__r.ASI_CRM_Payment_Reference__c,ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,ASI_CRM_Suggested_Payable_Amount__c,ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Parent_Module__c,ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                       ASI_CRM_End_Date__c,ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,ASI_CRM_Other_Comments__c,ASI_CRM_Overpayment_Reason__c,ASI_CRM_PSF_Overpayment_Reason__c,
                                       ASI_CRM_Fixedcost_Overpayment_Reason__c,ASI_CRM_Parent_Module__r.ASI_CRM_CN_Expected_Est_Total__c,ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c,
                                       ASI_CRM_Actual_Payment__c,ASI_CRM_Adjustment__c,ASI_CRM_Application_Payment_Amount__c,ASI_CRM_Historical_Paid_Amount__c, ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_VEC_Overpayment_Reason__c,
                                       ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c,
                                      ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c from ASI_CRM_Module__c where ASI_CRM_Payment_Request__c =:pageId ])
        {
            if(Module.ASI_CRM_Line_Type__c=='BRSF'){
                interimData TempData= new interimData(Module);
                BRSFItemMap=TempData;
            }
            if(Module.ASI_CRM_Line_Type__c=='PSF'){
                PSF_Item_Map.put(Module.ASI_CRM_Parent_Module__c,new interimData(Module));
            }
            if(Module.ASI_CRM_Line_Type__c=='Fixed' && PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                Fixed_Item_Map.put(Module.ASI_CRM_Parent_Module__c,new interimData(Module));
            }
            if(Module.ASI_CRM_Line_Type__c=='Variable Event Cost'){//interimData TempData= new interimData(Module);
                DisplayVEC=true;
                VariableEventCost= new interimData(Module);
            }
            ModuleMap.put(Module.Id,Module);
            if(Module.ASI_CRM_Parent_Module__c!=null){
                ParentModuleIdSet.add(Module.ASI_CRM_Parent_Module__c);
            }
        }        
        Map<String,Decimal> HistoricalModuleMap = new Map<String,Decimal>();
        if(ParentModuleIdSet.size()>0){
            HistoricalModuleList=ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(ParentModuleIdSet , PH.id);
            HistoricalModuleMap =ASI_CRM_CN_HeavyContractUtilitiesClass.GetHistoricalModuleAmount(ParentModuleIdSet , PH.ASI_TH_CRM_Contract__c,HistoricalModuleList);
            
        }

        Set<Id> subBrandIdSets = new Set<Id>();
        for (ASI_TH_CRM_PaymentRequestLineItem__c payline : [
            SELECT
                ASI_CRM_CN_AC_Code__c,
                ASI_CRM_CN_Actual_Vol__c,
                ASI_CRM_CN_Allow_Changing_Incentive__c,
                ASI_CRM_CN_Bottle_Collected__c,
                ASI_CRM_CN_Collection_Rate__c,
                ASI_CRM_CN_Comment__c,
                ASI_CRM_CN_Completion_Rate__c,
                ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Contract_Amount__c,
                ASI_CRM_CN_Contract_Cost__r.ASI_CRM_Contract_Terms__c,
                ASI_CRM_CN_Expense_Type__c,
                ASI_CRM_CN_Incentive_BT__c,
                ASI_CRM_CN_Payable_Vol__c,
                ASI_CRM_CN_Remaining_Amount__c,
                ASI_CRM_CN_Standard__c,
                ASI_CRM_CN_Sub_Brand__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                ASI_CRM_CN_Suggested_Amount__c,
                ASI_CRM_CN_Total_Payable__c,
                ASI_CRM_CNY_Est__c,
                ASI_CRM_CTD_Actual_Vol__c,
                ASI_CRM_CTD_Cap_Collection_Vol__c,
                ASI_CRM_Key_Sub_Brand__c,
                ASI_CRM_MAF_Est__c,
                ASI_CRM_Max_Incentive__c,
                ASI_CRM_Module__c,
                ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                ASI_CRM_Non_Contract_Line__c,
                ASI_CRM_Other_Est__c,
                ASI_CRM_Over_Incentive__c,
                ASI_CRM_Product_Category__c,
                ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                ASI_CRM_Sub_Brand_Grade__c,
                ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                ASI_CRM_Suggested_Value__c,
                ASI_CRM_Suggested_Volume__c,
                ASI_CRM_System_Payable_Vol_Std_Bottle__c,
                ASI_CRM_V0_0_Full_Contract_Target__c,
                ASI_CRM_Volume_Base__c,
                ASI_TH_CRM_Amount__c,
                ASI_TH_CRM_Payment_Request__c,
                ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                Id,
                RecordType.DeveloperName,
                RecordTypeId
            FROM ASI_TH_CRM_PaymentRequestLineItem__c
            WHERE ASI_TH_CRM_Payment_Request__c = :PH.id
        ]) {
            if (payline.ASI_CRM_CN_Sub_Brand__c != null) {
                subBrandIdSets.add(payline.ASI_CRM_CN_Sub_Brand__c);
            }
        }

        ASI_TH_CRM_Contract__c ContractSelected= [select Id,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                 ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c
                              from ASI_TH_CRM_Contract__c WHERE id =:PH.ASI_TH_CRM_Contract__c ];
            
        Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());
        String channel = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
        String region = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
        String cityInvestementGrade = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
        String newImage = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;
        Map<String, ASI_CRM_CM_GS__c> gsMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdSets);

        
        for(ASI_TH_CRM_PaymentRequestLineItem__c payline:[SELECT id,ASI_CRM_Suggested_Volume__c ,ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,ASI_CRM_Max_Incentive__c,ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,ASI_CRM_CTD_BC_Martell_CR12__c,ASI_CRM_CTD_BC_Pure_CR12__c,
                                                          ASI_CRM_Brand_Code__c,ASI_CRM_CN_Contract_Cost__r.ASI_CRM_Contract_Terms__c,ASI_CRM_CN_Suggested_Amount__c,ASI_CRM_Non_Contract_Line__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                          ASI_CRM_System_Payable_Vol_Std_Bottle__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                                          ASI_CRM_Over_Incentive__c,ASI_CRM_Suggested_Value__c,ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c,
                                                          ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,ASI_CRM_Product_Category__r.Name, ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Contract_Amount__c,
                                                          ASI_TH_CRM_Payment_Request__c,ASI_CRM_Volume_Base__c ,ASI_CRM_Product_Category__c,ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_CTD_Actual_Vol__c ,ASI_CRM_Line_Name__c, ASI_CRM_CN_Standard__c ,ASI_CRM_CTD_Cap_Collection_Vol__c , ASI_CRM_CN_Payable_Vol__c  , ASI_CRM_Key_Sub_Brand__c, ASI_CRM_CN_Completion_Rate__c, ASI_CRM_V0_0_Full_Contract_Target__c, ASI_CRM_CN_Total_Payable__c , ASI_CRM_CN_Actual_Vol__c , ASI_CRM_CN_Bottle_Collected__c, ASI_CRM_CN_Collection_Rate__c ,ASI_CRM_CN_Incentive_BT__c , ASI_CRM_CN_Allow_Changing_Incentive__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Module__c ,ASI_CRM_CN_Sub_Brand__c,RecordType.DeveloperName, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_Comment__c, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Remaining_Amount__c, recordtypeid , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_AC_Code__c 
                                                          ,ASI_CRM_CTD_BC_Martell__c,ASI_CRM_CTD_BC_Pure__c,ASI_CRM_CTD_Actual_Vol_Martell__c,ASI_CRM_CTD_Actual_Vol_Pure__c FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__c =:PH.id order by ASI_CRM_CN_Allow_Changing_Incentive__c])
        {
            system.debug( 'Payment Suggested Volume ' + payline.ASI_CRM_Suggested_Volume__c);
            payline.ASI_CRM_CN_Payable_Vol__c= payline.ASI_CRM_CN_Payable_Vol__c ==null? 0:payline.ASI_CRM_CN_Payable_Vol__c;
            payline.ASI_CRM_Suggested_Value__c= payline.ASI_CRM_Suggested_Value__c ==null? 0:payline.ASI_CRM_Suggested_Value__c;
            payline.ASI_CRM_Suggested_Volume__c= payline.ASI_CRM_Suggested_Volume__c ==null? 0:payline.ASI_CRM_Suggested_Volume__c;
            
            payline.ASI_CRM_CN_Total_Payable__c= payline.ASI_CRM_CN_Total_Payable__c ==null? 0:payline.ASI_CRM_CN_Total_Payable__c;
            payline.ASI_CRM_CN_Suggested_Amount__c= payline.ASI_CRM_CN_Suggested_Amount__c ==null? 1:payline.ASI_CRM_CN_Suggested_Amount__c;
            
            if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
                if (!PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    OtherPaymentLineList.add(payline);
                }
                if(Fixed_Item_Map.containsKey(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c) && PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                    String Mapkeystr=payline.Id;
                    if(Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                        Mapkeystr=NameSortingASC(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+payline.ASI_CRM_CN_Sub_Brand__c;
                        if(payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                            Mapkeystr='9'+Mapkeystr;
                        }
                        if(payline.ASI_CRM_Key_Sub_Brand__c){
                            Mapkeystr='0'+Mapkeystr;
                        }
                        
                        //if(payline.ASI_CRM_Max_Incentive__c==null){
                        //    payline.ASI_CRM_Max_Incentive__c=0;
                       // }
                        
                        //payline.ASI_CRM_Max_Incentive__c=GeneratingIncentive(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'PSFMax');                            
                        if(gsMap.containsKey(payline.ASI_CRM_CN_Sub_Brand__c) && gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).Actual_CM_GS_Lines__r != null){
                            for (ASI_CRM_Actual_CM_GS_Line__c cmgsLine : gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).Actual_CM_GS_Lines__r ) {
                                if (cmgsLine.ASI_CRM_CN_Activity_Code__c == payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c) {
                                    payline.ASI_CRM_Max_Incentive__c=cmgsLine.ASI_CRM_CN_Max_Incentive__c;
                                    System.debug(LoggingLevel.INFO, '*** payline.ASI_CRM_Max_Incentive__c: ' + payline.ASI_CRM_Max_Incentive__c);
                                }
                            }
                          
                        }

                        if (payline.ASI_CRM_Max_Incentive__c == null) {
                            payline.ASI_CRM_Max_Incentive__c= MaxIncentive;
                        }
                        //PSFMax
                        IF(payline.ASI_CRM_CN_Incentive_BT__c!=null && payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                            if(payline.ASI_CRM_Max_Incentive__c<payline.ASI_CRM_CN_Incentive_BT__c){
                                payline.ASI_CRM_Over_Incentive__c=true;
                            }else{
                                payline.ASI_CRM_Over_Incentive__c=false;
                            }
                        }
                        
                        if(payline.ASI_CRM_Sub_Brand_Grade__c!=null){
                            payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_Sub_Brand_Grade__r.Name;
                        }else{
                            payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        }
                        
                        
                    }
                    if(Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Grade'){
                        Mapkeystr=NameSortingASC(payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c)+payline.ASI_CRM_Sub_Brand_Grade__c;
                        if(payline.ASI_CRM_CN_Incentive_BT__c==null || payline.ASI_CRM_CN_Incentive_BT__c==0){
                            Mapkeystr='9'+Mapkeystr;
                        }
                        payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_Sub_Brand_Grade__r.Name;
                        
                    }
                    if(Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Category'){
                        Mapkeystr=NameSortingASC(payline.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c)+payline.ASI_CRM_Product_Category__c;
                        if(payline.ASI_CRM_CN_Incentive_BT__c==null || payline.ASI_CRM_CN_Incentive_BT__c==0){
                            Mapkeystr='9'+Mapkeystr;
                        }
                        payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c!=null?payline.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c:payline.ASI_CRM_Product_Category__r.Name;
                    }
                    
                    
                    Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                    Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalBC+=payline.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?payline.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                    
                    Boolean AllowCalculation=false;
                    if(payline.ASI_CRM_Non_Contract_Line__c ){
                        if(Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                            if(payline.ASI_CRM_CN_Payable_Vol__c!=0){
                                AllowCalculation=true;
                            } 
                        }else{
                            if(payline.ASI_CRM_CN_Total_Payable__c!=0){
                                AllowCalculation=true;
                            }  
                        }
                    }
                    
                    if(!payline.ASI_CRM_Non_Contract_Line__c || AllowCalculation){
                        Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake_Btl+=payline.ASI_CRM_CN_Actual_Vol__c!=null?payline.ASI_CRM_CN_Actual_Vol__c:0;
                        Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalBC_Btl+=payline.ASI_CRM_CN_Bottle_Collected__c!=null?payline.ASI_CRM_CN_Bottle_Collected__c:0;
                        Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake_Completion+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                        Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalBC_Completion+=payline.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?payline.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                    }
                    
                    Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).DetailLineMap.put(Mapkeystr,payline);
                    Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).RealVolume+=payline.ASI_CRM_CN_Payable_Vol__c!=null?payline.ASI_CRM_CN_Payable_Vol__c:0;
                    Fixed_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).VolumeTarget +=payline.ASI_CRM_V0_0_Full_Contract_Target__c!=null?payline.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                }
            }else if(payline.ASI_CRM_Module__c !=null){
                if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_BRSF'){
                    //payline.ASI_CRM_Max_Incentive__c=GeneratingIncentive(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'BRSFMax');
                    if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c && gsMap.containsKey(payline.ASI_CRM_CN_Sub_Brand__c) && gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_BRSF__c != null){
                        payline.ASI_CRM_Max_Incentive__c=gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_Max_Incentive_BRSF__c;
                    }else{
                        payline.ASI_CRM_Max_Incentive__c=GeneratingIncentive(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'BRSFMax');  
                    }

                    if (payline.ASI_CRM_Max_Incentive__c == null && PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                        payline.ASI_CRM_Max_Incentive__c= MaxIncentive;
                    }

                    //Max incentive checking
                    IF(payline.ASI_CRM_Max_Incentive__c!=null && payline.ASI_CRM_CN_Incentive_BT__c!=null){
                        if(payline.ASI_CRM_Max_Incentive__c<payline.ASI_CRM_CN_Incentive_BT__c){
                            payline.ASI_CRM_Over_Incentive__c=true;
                        }else{
                            payline.ASI_CRM_Over_Incentive__c=false;
                        }
                    }
                    String Mapkeystr=NameSortingASC(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+payline.ASI_CRM_CN_Sub_Brand__c;
                    if(payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                        Mapkeystr='9'+Mapkeystr;
                    }
                    
                    if(payline.ASI_CRM_Sub_Brand_Grade__c!=null){
                        payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_Sub_Brand_Grade__r.Name;
                    }else{
                        payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    }
                    
                    
                    BRSFItemMap.DetailLineMap.put(Mapkeystr,payline);
                }else if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){
                    if(PSF_Item_Map.containsKey(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c)){
                        String Mapkeystr=payline.Id;
                        if(PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                            Mapkeystr=NameSortingASC(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+payline.ASI_CRM_CN_Sub_Brand__c;
                            if(payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                                Mapkeystr='9'+Mapkeystr;
                            }
                            if(payline.ASI_CRM_Key_Sub_Brand__c){
                                Mapkeystr='0'+Mapkeystr;
                            }
                            
                            //if(payline.ASI_CRM_Max_Incentive__c==null){
                            //    payline.ASI_CRM_Max_Incentive__c=0;
                           // }
                            
                            //payline.ASI_CRM_Max_Incentive__c=GeneratingIncentive(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'PSFMax');                            
                            if(gsMap.containsKey(payline.ASI_CRM_CN_Sub_Brand__c) && gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_PSF__c != null ){
                                payline.ASI_CRM_Max_Incentive__c=gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_Max_Incentive_PSF__c;
                                System.debug(LoggingLevel.INFO, '*** payline.ASI_CRM_Max_Incentive__c: ' + payline.ASI_CRM_Max_Incentive__c);
                            }
                            else {
                                payline.ASI_CRM_Max_Incentive__c=GeneratingIncentive(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'PSFMax');
                            }

                            if (payline.ASI_CRM_Max_Incentive__c == null) {
                                payline.ASI_CRM_Max_Incentive__c= MaxIncentive;
                            }
                            //PSFMax
                            IF(payline.ASI_CRM_CN_Incentive_BT__c!=null && payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                                if(payline.ASI_CRM_Max_Incentive__c<payline.ASI_CRM_CN_Incentive_BT__c){
                                    payline.ASI_CRM_Over_Incentive__c=true;
                                }else{
                                    payline.ASI_CRM_Over_Incentive__c=false;
                                }
                            }
                            
                            if(payline.ASI_CRM_Sub_Brand_Grade__c!=null){
                                payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_Sub_Brand_Grade__r.Name;
                            }else{
                                payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                            }
                            
                            
                        }
                        if(PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Grade'){
                            Mapkeystr=NameSortingASC(payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c)+payline.ASI_CRM_Sub_Brand_Grade__c;
                            if(payline.ASI_CRM_CN_Incentive_BT__c==null || payline.ASI_CRM_CN_Incentive_BT__c==0){
                                Mapkeystr='9'+Mapkeystr;
                            }
                            payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_Sub_Brand_Grade__r.Name;
                            
                        }
                        if(PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Category'){
                            Mapkeystr=NameSortingASC(payline.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c)+payline.ASI_CRM_Product_Category__c;
                            if(payline.ASI_CRM_CN_Incentive_BT__c==null || payline.ASI_CRM_CN_Incentive_BT__c==0){
                                Mapkeystr='9'+Mapkeystr;
                            }
                            payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c!=null?payline.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c:payline.ASI_CRM_Product_Category__r.Name;
                        }
                        
                        
                        PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                        PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalBC+=payline.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?payline.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                        
                        Boolean AllowCalculation=false;
                        if(payline.ASI_CRM_Non_Contract_Line__c ){
                            if(PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                                if(payline.ASI_CRM_CN_Payable_Vol__c!=0){
                                    AllowCalculation=true;
                                } 
                            }else{
                                if(payline.ASI_CRM_CN_Total_Payable__c!=0){
                                    AllowCalculation=true;
                                }  
                            }
                        }
                        
                        if(!payline.ASI_CRM_Non_Contract_Line__c || AllowCalculation){
                            PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake_Btl+=payline.ASI_CRM_CN_Actual_Vol__c!=null?payline.ASI_CRM_CN_Actual_Vol__c:0;
                            PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalBC_Btl+=payline.ASI_CRM_CN_Bottle_Collected__c!=null?payline.ASI_CRM_CN_Bottle_Collected__c:0;
                            PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake_Completion+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                            PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalBC_Completion+=payline.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?payline.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                        }
                        
                        PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).DetailLineMap.put(Mapkeystr,payline);
                        PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).RealVolume+=payline.ASI_CRM_CN_Payable_Vol__c!=null?payline.ASI_CRM_CN_Payable_Vol__c:0;
                        PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).VolumeTarget +=payline.ASI_CRM_V0_0_Full_Contract_Target__c!=null?payline.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                    }                    
                }else if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_VEC'){
                    String Mapkeystr=payline.Id;
                    if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                        Mapkeystr=NameSortingASC(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+payline.ASI_CRM_CN_Sub_Brand__c;
                        if(payline.ASI_CRM_Sub_Brand_Grade__c!=null){
                            payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_Sub_Brand_Grade__r.Name;
                        }else{
                            payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        }

                        if(gsMap.containsKey(payline.ASI_CRM_CN_Sub_Brand__c) && gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_VEC__c != null){
                            payline.ASI_CRM_Max_Incentive__c=gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_Max_Incentive_VEC__c;
                        }

                        if (payline.ASI_CRM_Max_Incentive__c == null) {
                            payline.ASI_CRM_Max_Incentive__c= MaxIncentive;
                        }
                        IF(payline.ASI_CRM_Max_Incentive__c!=null && payline.ASI_CRM_CN_Incentive_BT__c!=null && payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                          if(payline.ASI_CRM_Max_Incentive__c<payline.ASI_CRM_CN_Incentive_BT__c){
                              payline.ASI_CRM_Over_Incentive__c=true;
                          }else{
                              payline.ASI_CRM_Over_Incentive__c=false;
                          }
                      }
                        
                    }
                    if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Grade'){
                        Mapkeystr=NameSortingASC(payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c)+payline.ASI_CRM_Sub_Brand_Grade__c;
                        payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:payline.ASI_CRM_Sub_Brand_Grade__r.Name;
                    }
                    if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Category'){
                        Mapkeystr=NameSortingASC(payline.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c)+payline.ASI_CRM_Product_Category__c;
                        payline.ASI_CRM_Line_Name__c= payline.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c!=null?payline.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c:payline.ASI_CRM_Product_Category__r.Name;
                    }
                    if(payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                        Mapkeystr='9'+Mapkeystr;
                    }
                    
                    VariableEventCost.TotalIntake+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                    VariableEventCost.TotalBC+=payline.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?payline.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                    VariableEventCost.TotalIntake_Btl+=payline.ASI_CRM_CN_Actual_Vol__c!=null?payline.ASI_CRM_CN_Actual_Vol__c:0;
                    VariableEventCost.TotalBC_Btl+=payline.ASI_CRM_CN_Bottle_Collected__c!=null?payline.ASI_CRM_CN_Bottle_Collected__c:0;
                    Boolean AllowCalculation=false;
                    if(payline.ASI_CRM_Non_Contract_Line__c ){
                        if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                            if(payline.ASI_CRM_CN_Payable_Vol__c!=0){
                                AllowCalculation=true;
                            } 
                        }else{
                            if(payline.ASI_CRM_CN_Total_Payable__c!=0){
                                AllowCalculation=true;
                            }  
                        }
                    }
                    if(!payline.ASI_CRM_Non_Contract_Line__c || AllowCalculation){
                        VariableEventCost.TotalIntake_Btl+=payline.ASI_CRM_CN_Actual_Vol__c!=null?payline.ASI_CRM_CN_Actual_Vol__c:0;
                        VariableEventCost.TotalBC_Btl+=payline.ASI_CRM_CN_Bottle_Collected__c!=null?payline.ASI_CRM_CN_Bottle_Collected__c:0;
                        VariableEventCost.TotalIntake_Completion+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                        VariableEventCost.TotalBC_Completion+=payline.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?payline.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                    }
                    
                    VariableEventCost.DetailLineMap.put(payline.Id,payline);
                    VariableEventCost.RealVolume+=payline.ASI_CRM_CN_Payable_Vol__c!=null?payline.ASI_CRM_CN_Payable_Vol__c:0;
                    VariableEventCost.VolumeTarget +=payline.ASI_CRM_V0_0_Full_Contract_Target__c!=null?payline.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                }
                
                
            }
        }
        
        
        
        List<ASI_TH_CRM_PaymentRequest__c> Payment000List = [select id,Name,ASI_CRM_CN_Total_PSF_Amount__c ,ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Total_VEC_Amount__c
                                                             from ASI_TH_CRM_PaymentRequest__c 
                                                             where ASI_TH_CRM_Contract__c= :PH.ASI_TH_CRM_Contract__c and Name like '%000%' ];
        // Decimal PaidAmount000=0;
        
        Decimal BRSFPaidAmount000=0;
        Decimal PSFPaidAmount000=0;
        Decimal VECPaidAmount000=0;
        
        
        
        if(Payment000List.size()>0){
            for(ASI_TH_CRM_PaymentRequest__c Paymenttemp:Payment000List){
                if(Paymenttemp.Name.length()>3){
                    if(Paymenttemp.Name.substring(Paymenttemp.Name.length()-3, Paymenttemp.Name.length()) == '000'){
                        BRSFPaidAmount000+=Paymenttemp.ASI_CRM_CN_Total_BRSF_Amount__c!=null?Paymenttemp.ASI_CRM_CN_Total_BRSF_Amount__c:0;
                        PSFPaidAmount000+=Paymenttemp.ASI_CRM_CN_Total_PSF_Amount__c!=null?Paymenttemp.ASI_CRM_CN_Total_PSF_Amount__c:0;
                        VECPaidAmount000+=Paymenttemp.ASI_CRM_CN_Total_VEC_Amount__c!=null?Paymenttemp.ASI_CRM_CN_Total_VEC_Amount__c:0;
                    }
                }
            }
        }
        Integer coun=0;
        for(String ModuleKey:PSF_Item_Map.keySet()){
            if( PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Parent_Module__c !=null && HistoricalModuleMap.containsKey(PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Parent_Module__c)){
                system.debug(' Parent Module Amount PSF :'+HistoricalModuleMap.get(PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Parent_Module__c));
                PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Historical_Paid_Amount__c = HistoricalModuleMap.get(PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Parent_Module__c);
            }
            
            PSF_Item_Map.get(ModuleKey).RealVolume=MethodologyRoute(PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                    PSF_Item_Map.get(ModuleKey).TotalIntake_Completion,
                                                                    PSF_Item_Map.get(ModuleKey).TotalBC_Completion,
                                                                    CalculateBCRate(PSF_Item_Map.get(ModuleKey).TotalIntake_Btl,PSF_Item_Map.get(ModuleKey).TotalBC_Btl)
                                                                    ,false);
        }
        if (PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for(String ModuleKey:Fixed_Item_Map.keySet()){
                if( Fixed_Item_Map.get(ModuleKey).Module.ASI_CRM_Parent_Module__c !=null && HistoricalModuleMap.containsKey(Fixed_Item_Map.get(ModuleKey).Module.ASI_CRM_Parent_Module__c)){
                    system.debug(' Parent Module Amount PSF :'+HistoricalModuleMap.get(Fixed_Item_Map.get(ModuleKey).Module.ASI_CRM_Parent_Module__c));
                    Fixed_Item_Map.get(ModuleKey).Module.ASI_CRM_Historical_Paid_Amount__c = HistoricalModuleMap.get(Fixed_Item_Map.get(ModuleKey).Module.ASI_CRM_Parent_Module__c);
                }
                
                Fixed_Item_Map.get(ModuleKey).RealVolume=MethodologyRoute(Fixed_Item_Map.get(ModuleKey).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                        Fixed_Item_Map.get(ModuleKey).TotalIntake_Completion,
                                                                        Fixed_Item_Map.get(ModuleKey).TotalBC_Completion,
                                                                        CalculateBCRate(Fixed_Item_Map.get(ModuleKey).TotalIntake_Btl,Fixed_Item_Map.get(ModuleKey).TotalBC_Btl)
                                                                        ,false);
            }
        }
        
        
        
        if(BRSFItemMap.Module.ASI_CRM_Parent_Module__c !=null && HistoricalModuleMap.containsKey(BRSFItemMap.Module.ASI_CRM_Parent_Module__c)){
            BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c = HistoricalModuleMap.get(BRSFItemMap.Module.ASI_CRM_Parent_Module__c) == null ? 0 : HistoricalModuleMap.get(BRSFItemMap.Module.ASI_CRM_Parent_Module__c); //BRSFPaidAmount000            
        }
        
        
        if(VariableEventCost.Module.ASI_CRM_Parent_Module__c !=null && HistoricalModuleMap.containsKey(VariableEventCost.Module.ASI_CRM_Parent_Module__c)){
            VariableEventCost.Module.ASI_CRM_Historical_Paid_Amount__c = HistoricalModuleMap.get(VariableEventCost.Module.ASI_CRM_Parent_Module__c);//VECPaidAmount000
        }
        VariableEventCost.RealVolume=MethodologyRoute(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                      VariableEventCost.TotalIntake_Completion,VariableEventCost.TotalBC_Completion,CalculateBCRate(VariableEventCost.TotalIntake_Btl,VariableEventCost.TotalBC_Btl), false);
        
    }
    
    
    //****************Generate Payment Line *******************************************************************************************
    
    
    public void GenerateBRSFVol(){
        RefreshPaymentLine();
        
        UpsertPermission=true;
        Msg='';
        
        system.debug('BRSF End Date : '+ BRSFItemMap.Module.ASI_CRM_End_Date__c);
        if(VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c,
                                        BRSFItemMap.Module.ASI_CRM_End_Date__c,
                                        BRSFItemMap.Module.ASI_CRM_Parent_Module__c,'For BRSF, we meet following error in End Date: <br/>'))
        {
            RefreshAllData();
            //Remove Curent BRSF Line
            for(String key : BRSFItemMap.DetailLineMap.keySet()){
                ASI_TH_CRM_PaymentRequestLineItem__c delTarget= BRSFItemMap.DetailLineMap.get(key);
                if(delTarget.id != null){
                    PaymentLineDeleteList.add(delTarget);
                }
                BRSFItemMap.DetailLineMap.remove(key);
            } 
            
            //Geting Subbrand Volume
            List<ASI_CRM_Subbrand_Volume__c> LVol= RetrieveSubBrandVolume(PH.ASI_CRM_CN_PO_Start_Date__c,BRSFItemMap.Module.ASI_CRM_End_Date__c);
            
            /*String V0_0_POId=PH.ASI_TH_CRM_Contract__c ;
            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
                V0_0_POId=PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
            }*/
            
            //BRSF List from contract
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList = [Select id,ASI_CRM_CN_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                                    ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Activity_Code__c
                                                                    FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                    WHERE ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c  and ASI_CRM_Type__c = 'BRSF'   and ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' 
                                                                    and ASI_CRM_CN_Sub_Brand__c !=null order by ASI_CRM_CN_Contract__c];
            
            //Grouping by Sub-Brand : Map<Sub-Brand Id, ASI_TH_CRM_PaymentRequestLineItem__c>
            Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  SBGroupingMap =SubBrandGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c,BRSFItemMap.Module.ASI_CRM_End_Date__c,BRSFList,BRSFItemMap.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
            
            //Get Historical Payment Line
            List<ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentList =[select Id,ASI_TH_CRM_Payment_Request__c,ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Incentive_BT__c 
                                                                               from ASI_TH_CRM_PaymentRequestLineItem__c 
                                                                               where ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c 
                                                                               and ASI_TH_CRM_Payment_Request__c !=: PH.id and RecordType.DeveloperName = : 'ASI_CRM_CN_Payment_Request_Detail_BRSF' Order by ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_Version__c ];
            Map<String,ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentMap= new Map<String,ASI_TH_CRM_PaymentRequestLineItem__c>();
            for(ASI_TH_CRM_PaymentRequestLineItem__c paymentline: HistoricalPaymentList){
                HistoricalPaymentMap.put(paymentline.ASI_CRM_CN_Sub_Brand__c, paymentline);
            }
            
            //Getting Activity Code base on the 'Contract Cost Setting' table  
            List<ASI_CRM_Contract_Cost_Setting__c> LContractCostSettingList =   [SELECT id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c,
                                                                                 ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c, 
                                                                                 ASI_CRM_CN_Other_Cost_Payment_Request__c 
                                                                                 FROM ASI_CRM_Contract_Cost_Setting__c
                                                                                 where ASI_CRM_CN_Promotion_Type__c = :PH.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c
                                                                                 and ASI_CRM_CN_BRSF_Activity_Code_Default__c = true];
            Id ActivityCode; 
            if(LContractCostSettingList != null && LContractCostSettingList.size()==1){
                ActivityCode = LContractCostSettingList[0].ASI_CRM_CN_Activity_Code__c;
            }
            BRSFItemMap.TotalIntake=0;
            BRSFItemMap.TotalBC=0;
            BRSFItemMap.RealVolume=0;
            BRSFItemMap.TotalBC_Btl=0.0;
            BRSFItemMap.TotalIntake_Btl=0.0;
            BRSFItemMap.TotalCTDPayableAmount=0.0;
            BRSFItemMap.VolumeTarget=0.0;
            //2nd get the segmet
            ASI_TH_CRM_Contract__c contract= [select Id,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,
            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c
                                                    from ASI_TH_CRM_Contract__c WHERE id =:PH.ASI_TH_CRM_Contract__c ];
            // List<Date> dateList = new List<Date>();
            Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());
            // dateList.add(setDate);
            Set<Id> subBrandIdSets = new Set<Id>();
            for(String SubBrandKey:SBGroupingMap.keySet()){
                subBrandIdSets.add(SBGroupingMap.get(SubBrandKey).ASI_CRM_CN_Sub_Brand__c);
            }
            
            String channel = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
            String region = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
            String cityInvestementGrade = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
            String newImage = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;
            Map<String, ASI_CRM_CM_GS__c> gsMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdSets);

            for(String SubBrandKey:SBGroupingMap.keySet()){
                ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= SBGroupingMap.get(SubBrandKey);
                System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                InsertPayLine.ASI_CRM_CN_AC_Code__c = ActivityCode!=null?ActivityCode:null;
                InsertPayLine=PaymentLineRounding(InsertPayLine);
                InsertPayLine.recordtypeid = Global_recordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
                InsertPayLine.ASI_CRM_Module__c=BRSFItemMap.Module.Id;
                if(InsertPayLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c == null || Test.isRunningTest()){
                    //If the outlet sells the sub-brand not listed in the linked PO, the sub-brand item will be added by retrieving from the historical payment, the Incentive (Per Bottle) will be read-only.
                    if(HistoricalPaymentMap.containsKey(InsertPayLine.ASI_CRM_CN_Sub_Brand__c)){
                        InsertPayLine.ASI_CRM_CN_Incentive_BT__c=HistoricalPaymentMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_BT__c;
                        InsertPayLine.ASI_CRM_CN_Allow_Changing_Incentive__c=false;
                    }else{ //Not in HistoricalPaymentMap
                        
                        if(gsMap.containsKey(InsertPayLine.ASI_CRM_CN_Sub_Brand__c) && gsMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_BRSF__c != null && contract.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                          InsertPayLine.ASI_CRM_CN_Incentive_BT__c=gsMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_BRSF__c;
                          InsertPayLine.ASI_CRM_Max_Incentive__c=gsMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_Max_Incentive_BRSF__c;
                        }else{
                          InsertPayLine.ASI_CRM_CN_Incentive_BT__c=GeneratingIncentive(InsertPayLine.ASI_CRM_CN_Standard__c,'BRSFIncentive'); 
                          InsertPayLine.ASI_CRM_Max_Incentive__c=GeneratingIncentive(InsertPayLine.ASI_CRM_CN_Standard__c,'BRSFMax');  
                        }

                        if (InsertPayLine.ASI_CRM_Max_Incentive__c == null) {
                          InsertPayLine.ASI_CRM_Max_Incentive__c= MaxIncentive;
                        }
                    }
                }
                
                InsertPayLine.ASI_CRM_CN_Payable_Vol__c = ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(BRSFItemMap.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                    InsertPayLine.ASI_CRM_CN_Actual_Vol__c,
                                        InsertPayLine.ASI_CRM_CN_Bottle_Collected__c,
                                    CalculateBCRate(InsertPayLine.ASI_CRM_CN_Actual_Vol__c,InsertPayLine.ASI_CRM_CN_Bottle_Collected__c),
                                        BCRateDecision(InsertPayLine.ASI_CRM_Brand_Code__c),false);
                
                System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                //BC%
                if(InsertPayLine.ASI_CRM_CTD_Actual_Vol__c !=0 && InsertPayLine.ASI_CRM_CTD_Actual_Vol__c !=null && InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c !=null){
                    InsertPayLine.ASI_CRM_CN_Collection_Rate__c = (InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c/ InsertPayLine.ASI_CRM_CTD_Actual_Vol__c)*100;
                }else{
                    InsertPayLine.ASI_CRM_CN_Collection_Rate__c=0.0;
                }
               
                InsertPayLine.ASI_CRM_CN_Total_Payable__c = InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null? InsertPayLine.ASI_CRM_CN_Incentive_BT__c * InsertPayLine.ASI_CRM_CN_Payable_Vol__c.setScale(0):0;
                BRSFItemMap.TotalCTDPayableAmount+= InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                
                //When a sales requests a new payment, system will provide the default payable volume/amount based on the calculation of selected methodology or just blank.
                if(!PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_BRSF__c){
                    InsertPayLine.ASI_CRM_Suggested_Value__c =0;
                    InsertPayLine.ASI_CRM_Suggested_Volume__c=0;
                    InsertPayLine.ASI_CRM_CN_Payable_Vol__c=0;
                    InsertPayLine.ASI_CRM_CN_Total_Payable__c = 0;
                }
                
                if(InsertPayLine.ASI_CRM_CN_Allow_Changing_Incentive__c){
                    SubBrandKey='9'+SubBrandKey;
                }else{
                    InsertPayLine.ASI_CRM_Suggested_Value__c = InsertPayLine.ASI_CRM_CN_Incentive_BT__c !=NULL? InsertPayLine.ASI_CRM_CN_Incentive_BT__c: 0;
                }
                
                InsertPayLine.ASI_CRM_Suggested_Volume__c = InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null? InsertPayLine.ASI_CRM_CN_Payable_Vol__c:0;
                InsertPayLine.ASI_CRM_Suggested_Value__c = InsertPayLine.ASI_CRM_CN_Payable_Vol__c !=NULL? InsertPayLine.ASI_CRM_CN_Payable_Vol__c: 0;
                
                BRSFItemMap.TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                BRSFItemMap.TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                InsertPayLine.ASI_CRM_CN_Payable_Vol__c =InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null?Math.floor(InsertPayLine.ASI_CRM_CN_Payable_Vol__c):0;//.setScale(0, RoundingMode.HALF_DOWN)
                
                system.debug('111 SubBrandKey: '+SubBrandKey);
                BRSFItemMap.DetailLineMap.put(SubBrandKey,InsertPayLine);
                
            }
            BRSFItemMap.RealVolume=MethodologyRoute(BRSFItemMap.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                    BRSFItemMap.TotalIntake,
                                                    BRSFItemMap.TotalBC,0,true);
            
            //BRSFItemMap.Module.ASI_CRM_Suggested_Payable_Amount__c = BRSFItemMap.TotalCTDPayableAmount;
            
            if(!PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_BRSF__c){
                BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c=0;
                BRSFItemMap.Module.ASI_CRM_Actual_Payment__c= 0;
                BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c = 0;
            }else{
                BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c=BRSFItemMap.TotalCTDPayableAmount;
                if(BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c!=null){
                    BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c = BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c - BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c;
                }
                if(BRSFItemMap.Module.ASI_CRM_Adjustment__c !=null){
                    BRSFItemMap.Module.ASI_CRM_Actual_Payment__c= (BRSFItemMap.Module.ASI_CRM_Adjustment__c /100) *BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c;
                }
            }
            
            
            
        }
        
    }
    
    
    public void GeneratePSFVol(){
        RefreshPaymentLine();
        UpsertPermission=true;
        Msg='';
        
        Decimal TotalIntakeBTL_Pure=0;
        Decimal TotalBCBTL_Pure=0;
        Decimal TotalIntakeCR12_Pure=0;
        Decimal TotalBCCR12_Pure=0;
        
        Decimal TotalIntakeBTL_MAR=0;
        Decimal TotalBCBTL_MAR=0;
        Decimal TotalIntakeCR12_MAR=0;
        Decimal TotalBCCR12_MAR=0;
        
        String param_Id = Apexpages.currentPage().getParameters().get('PARAMID');
        if(PSF_Item_Map.containsKey(param_Id) && !PSF_Item_Map.isEmpty()){
            if(VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c, 
                                            PSF_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,
                                            PSF_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__c,
                                            'For PSF ('+PSF_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+'), we meet following error in End Date:'))
            {
                //remove existing line in PSF 
                for(String key : PSF_Item_Map.get(param_Id).DetailLineMap.keySet()){
                    ASI_TH_CRM_PaymentRequestLineItem__c delTarget=PSF_Item_Map.get(param_Id).DetailLineMap.get(key);
                    if(delTarget.id != null){
                        PaymentLineDeleteList.add(delTarget);
                    }
                    PSF_Item_Map.get(param_Id).DetailLineMap.remove(key);
                }
                //  ** Reset **
                PSF_Item_Map.get(param_Id).TotalIntake=0;
                PSF_Item_Map.get(param_Id).TotalBC=0;
                PSF_Item_Map.get(param_Id).RealVolume=0;
                PSF_Item_Map.get(param_Id).TotalCTDPayableAmount=0.0;
                PSF_Item_Map.get(param_Id).TotalBC_Btl=0.0;
                PSF_Item_Map.get(param_Id).TotalBC_Completion=0.0;
                PSF_Item_Map.get(param_Id).TotalIntake_Completion=0.0;
                PSF_Item_Map.get(param_Id).TotalIntake_Btl=0.0;
                PSF_Item_Map.get(param_Id).VolumeTarget=0.0;
                PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c=0;
                
                //Geting Subbrand Volume List 
                List<ASI_CRM_Subbrand_Volume__c> LVol= RetrieveSubBrandVolume(PH.ASI_CRM_CN_PO_Start_Date__c, PSF_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c);
                //BRSF List from contract
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
                //HistoricalPaymentLine
                List<ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentList =new List<ASI_TH_CRM_PaymentRequestLineItem__c> ();
                Map<String,ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentMap= new Map<String,ASI_TH_CRM_PaymentRequestLineItem__c>();
                
               /* String V0_0_POId=PH.ASI_TH_CRM_Contract__c ;
                if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
                    V0_0_POId=PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
                }*/
                ///system.assertEquals(, null);
                //system.debug( 'PSF Module ID' + PSF_Item_Map.get(param_Id).Module.Id);
                if(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__c!=null){
                    PSFList= [Select id,ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c,ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c,ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c,ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c,
                              ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_CN_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c, ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c, ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                              ASI_CRM_CN_Contract__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_CN_Sub_Brand__r.Name,
                              ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Sub_Brand_Grade__r.Name,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Product_Category__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c,ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c,ASI_CRM_CN_Est_Monthly_Qty__c,ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Activity_Code__c,ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,ASI_CRM_Product_Category__r.Name 
                              FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                              WHERE ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c and ASI_CRM_Module__c=:PSF_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__c and 
                              ASI_CRM_Type__c = 'PSF' and ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' order by ASI_CRM_CN_Contract__c];
                    
                    System.debug(LoggingLevel.INFO, '*** PSFList: ' + PSFList);
                    HistoricalPaymentList =[select Id,ASI_TH_CRM_Payment_Request__c,ASI_CRM_CN_Sub_Brand__c,ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Product_Category__c,ASI_CRM_CN_Incentive_BT__c 
                                            from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c 
                                            and ASI_CRM_Module__r.ASI_CRM_Parent_Module__c=:PSF_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__c
                                            and ASI_TH_CRM_Payment_Request__c !=: PH.id and RecordType.DeveloperName = : 'ASI_CRM_CN_Payment_Request_Detail_PSF'  Order by ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_Version__c ];
                    
                    
                }
                
                
                
                //Getting Activity Code base on the 'Contract Cost Setting' table  
                List<ASI_CRM_Contract_Cost_Setting__c> LContractCostSettingList =   [SELECT id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c,ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c,  ASI_CRM_CN_Other_Cost_Payment_Request__c 
                                                                                     FROM ASI_CRM_Contract_Cost_Setting__c  where ASI_CRM_CN_Promotion_Type__c = :PH.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c
                                                                                     and ASI_CRM_PSF_Activity_Code_Default__c = true];
                Id ActivityCode; 
                if(LContractCostSettingList != null && LContractCostSettingList.size()==1){
                    ActivityCode = LContractCostSettingList[0].ASI_CRM_CN_Activity_Code__c;
                }
                
                //If Module is By Sub-Brand 
                
                if(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    
                    for(ASI_TH_CRM_PaymentRequestLineItem__c paymentline: HistoricalPaymentList){
                        HistoricalPaymentMap.put(paymentline.ASI_CRM_CN_Sub_Brand__c, paymentline);
                    }
                    
                    //Grouping by Sub-Brand : Map<Sub-Brand Id, ASI_TH_CRM_PaymentRequestLineItem__c>
                    Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  SBGroupingMap =SubBrandGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, PSF_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,PSFList,PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                    
                    //2nd get the segmet
                    ASI_TH_CRM_Contract__c contract= [select Id,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c
                                                            from ASI_TH_CRM_Contract__c WHERE id =:PH.ASI_TH_CRM_Contract__c ];
                    // List<Date> dateList = new List<Date>();
                    Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());
                    // dateList.add(setDate);
                    Set<Id> subBrandIdSets = new Set<Id>();
                    for(String SubBrandKey:SBGroupingMap.keySet()){
                        subBrandIdSets.add(SBGroupingMap.get(SubBrandKey).ASI_CRM_CN_Sub_Brand__c);
                    }
                    
                    String channel = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
                    String region = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
                    String cityInvestementGrade = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
                    String newImage = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;
                    Map<String, ASI_CRM_CM_GS__c> gsMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdSets);

                    
                    for(String SubBrandKey:SBGroupingMap.keySet()){
                        
                        ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= SBGroupingMap.get(SubBrandKey);
                        //system.debug('Payable_Vol1.0 : '+InsertPayLine.ASI_CRM_CN_Payable_Vol__c);
                        System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);

                        if(InsertPayLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c == null || Test.isRunningTest()){
                            //If the outlet sells the sub-brand not listed in the linked PO, the sub-brand item will be added by retrieving from the historical payment, the Incentive (Per Bottle) will be read-only.
                            if(HistoricalPaymentMap.containsKey(InsertPayLine.ASI_CRM_CN_Sub_Brand__c)){
                                InsertPayLine.ASI_CRM_CN_Incentive_BT__c=HistoricalPaymentMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_BT__c;
                                InsertPayLine.ASI_CRM_CN_Allow_Changing_Incentive__c=false;
                            }else{//Not in HistoricalPaymentMap
                              if(gsMap.containsKey(InsertPayLine.ASI_CRM_CN_Sub_Brand__c) && gsMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_PSF__c != null && contract.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                InsertPayLine.ASI_CRM_Max_Incentive__c=gsMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_Max_Incentive_PSF__c;
                                System.debug(LoggingLevel.INFO, '*** InsertPayLine.ASI_CRM_Max_Incentive__c: ' + InsertPayLine.ASI_CRM_Max_Incentive__c);
                              }
                              else {
                                //InsertPayLine.ASI_CRM_CN_Incentive_BT__c=GeneratingIncentive(InsertPayLine.ASI_CRM_CN_Standard__c,'PSFIncentive'); 
                                InsertPayLine.ASI_CRM_Max_Incentive__c=GeneratingIncentive(InsertPayLine.ASI_CRM_CN_Standard__c,'PSFMax');
                              }

                              if (InsertPayLine.ASI_CRM_Max_Incentive__c == null) {
                                  InsertPayLine.ASI_CRM_Max_Incentive__c= MaxIncentive;
                              }
                            }
                        }
                        System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                        
                        InsertPayLine.ASI_CRM_CN_AC_Code__c = ActivityCode!=null?ActivityCode:null;
                        InsertPayLine=PaymentLineRounding(InsertPayLine);
                        // Calulate 'CTD Payable Vol. (Std. Btl.)' 
                        InsertPayLine.ASI_CRM_CN_Payable_Vol__c = ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                            InsertPayLine.ASI_CRM_CN_Actual_Vol__c,
                                                                                                                            InsertPayLine.ASI_CRM_CN_Bottle_Collected__c,
                                                                                                                            CalculateBCRate(InsertPayLine.ASI_CRM_CN_Actual_Vol__c,InsertPayLine.ASI_CRM_CN_Bottle_Collected__c),
                                                                                                                            BCRateDecision(InsertPayLine.ASI_CRM_Brand_Code__c),false);
                
                
                        //InsertPayLine.ASI_CRM_CN_Payable_Vol__c= MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,InsertPayLine);
                        InsertPayLine.ASI_CRM_CN_Total_Payable__c = InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Incentive_BT__c * InsertPayLine.ASI_CRM_CN_Payable_Vol__c.setScale(0):0;
                        PSF_Item_Map.get(param_Id).TotalCTDPayableAmount +=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        PSF_Item_Map.get(param_Id).VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                        InsertPayLine.ASI_CRM_Module__c=PSF_Item_Map.get(param_Id).Module.Id;
                        InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF',PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,true);
                        
                        if(InsertPayLine.ASI_CRM_CN_Allow_Changing_Incentive__c){
                            SubBrandKey='9'+SubBrandKey;
                            //InsertPayLine.ASI_CRM_Max_Incentive__c=0;
                        }else{
                            InsertPayLine.ASI_CRM_Suggested_Value__c = InsertPayLine.ASI_CRM_CN_Incentive_BT__c !=NULL? InsertPayLine.ASI_CRM_CN_Incentive_BT__c: 0;
                        }
                        
                        InsertPayLine.ASI_CRM_Suggested_Volume__c = InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null? InsertPayLine.ASI_CRM_CN_Payable_Vol__c:0;
                        
                        if(InsertPayLine.ASI_CRM_Key_Sub_Brand__c){
                            SubBrandKey='0'+SubBrandKey;
                        }
                        PSF_Item_Map.get(param_Id).TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        PSF_Item_Map.get(param_Id).TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                        
                        if(!InsertPayLine.ASI_CRM_Non_Contract_Line__c){
                            PSF_Item_Map.get(param_Id).TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                            PSF_Item_Map.get(param_Id).TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                            PSF_Item_Map.get(param_Id).TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                            PSF_Item_Map.get(param_Id).TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                            
                        }else{
                            InsertPayLine.ASI_CRM_Suggested_Value__c=0;
                        }
                        PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        PSF_Item_Map.get(param_Id).DetailLineMap.put(SubBrandKey,InsertPayLine);
                            
                        TotalIntakeBTL_Pure +=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c:0;
                        TotalBCBTL_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure__c !=null?InsertPayLine.ASI_CRM_CTD_BC_Pure__c:0;
                        TotalIntakeCR12_Pure+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c:0;
                        TotalBCCR12_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c:0;
                        
                        TotalIntakeBTL_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c:0;
                        TotalBCBTL_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell__c:0;
                        TotalIntakeCR12_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c:0;
                        TotalBCCR12_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c:0;
                        
                    }
                    
                    PSF_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                     TotalIntakeBTL_MAR,TotalBCBTL_MAR,
                                                                                                                     CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                     BCRateDecision('MAR'),false).setScale(0)+
                        ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                  TotalIntakeBTL_Pure,TotalBCBTL_Pure, CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                  BCRateDecision('NoMAR'),false).setScale(0);
                    
                    
                }
                
                
                if(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c=='By Grade'){
                    //Grouping by Sub-Brand Grade: Map<Sub-Brand Grade Id, ASI_TH_CRM_PaymentRequestLineItem__c>
                    Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  SBGroupingMap =SBGradeGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, PSF_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,PSFList,PSF_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                    
                    
                    for(String Key:SBGroupingMap.keySet()){
                        ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= SBGroupingMap.get(Key);
                        InsertPayLine.ASI_CRM_CN_AC_Code__c = ActivityCode!=null?ActivityCode:null;
                        InsertPayLine=PaymentLineRounding(InsertPayLine);
                        InsertPayLine.ASI_CRM_Module__c=PSF_Item_Map.get(param_Id).Module.Id;
                        
                        
                        system.debug('Now InsertPayLine  NoMAR  : '+ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c,
                                                                                      CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),
                                                                                      BCRateDecision('NoMAR'),false));
                        
                        system.debug(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c+ ' BC : '+ InsertPayLine.ASI_CRM_CTD_BC_Martell__c+ 'Now InsertPayLine MAR  '+ ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                          InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c,
                                                                                                                          CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                                                                                                                          BCRateDecision('MAR'),false) );
                        system.debug('Now InsertPayLine2  '+InsertPayLine);
                        
                        
                        
                        if( PSF_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c =='CR12 Extra Eqv.'){
                            
                            InsertPayLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                              InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c,
                                                                                                                              CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                                                                                                                              BCRateDecision('MAR'),false).setScale(0) +
                                ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                          InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c,
                                                                                          CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),
                                                                                          BCRateDecision('NoMAR'),false).setScale(0);
                        }else{
                            InsertPayLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                              InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c,
                                                                                                                              CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                                                                                                                              BCRateDecision('MAR'),false).setScale(0)+
                                ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                          InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c,
                                                                                          CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),
                                                                                          BCRateDecision('NoMAR'),false).setScale(0);
                        }
                        
                   
                        system.debug('Enter InsertPayLine.ASI_CRM_CN_Payable_Vol__c :  '+InsertPayLine.ASI_CRM_CN_Payable_Vol__c);
                        if(InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c !=0){
                            InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CN_Payable_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c )* InsertPayLine.ASI_CRM_CN_Incentive_BT__c).setScale(3);
                            //InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CTD_Actual_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c ))* InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                            system.debug('739 '+InsertPayLine.ASI_CRM_CN_Total_Payable__c);
                        }else{
                            InsertPayLine.ASI_CRM_CN_Total_Payable__c =0;
                        }
                        PSF_Item_Map.get(param_Id).TotalCTDPayableAmount +=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c!=null){
                            InsertPayLine.ASI_CRM_Max_Incentive__c=InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                        }
                        PSF_Item_Map.get(param_Id).VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                        InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF',
                                                                PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,false);
                        system.debug('By Grade InsertPayLine ASI_CRM_Suggested_Value__c :  '+InsertPayLine.ASI_CRM_Suggested_Value__c);
                        
                        if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c==null || InsertPayLine.ASI_CRM_CN_Incentive_BT__c==0 ){
                            Key='9'+Key;
                        }
                        PSF_Item_Map.get(param_Id).TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        PSF_Item_Map.get(param_Id).TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                        
                        if(!InsertPayLine.ASI_CRM_Non_Contract_Line__c){
                            PSF_Item_Map.get(param_Id).TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                            PSF_Item_Map.get(param_Id).TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                            PSF_Item_Map.get(param_Id).TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                            PSF_Item_Map.get(param_Id).TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                        }
                        PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        system.debug('V0.0 Full Contract Target 3.0 : '+InsertPayLine.ASI_CRM_CN_Total_Payable__c);
                        
                        PSF_Item_Map.get(param_Id).DetailLineMap.put(Key,InsertPayLine);
                        
                        TotalIntakeBTL_Pure +=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c:0;
                        TotalBCBTL_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure__c !=null?InsertPayLine.ASI_CRM_CTD_BC_Pure__c:0;
                        TotalIntakeCR12_Pure+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c:0;
                        TotalBCCR12_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c:0;
                        
                        TotalIntakeBTL_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c:0;
                        TotalBCBTL_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell__c:0;
                        TotalIntakeCR12_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c:0;
                        TotalBCCR12_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c:0;
                        
                    }
                    
                    
                    if( PSF_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c =='CR12 Extra Eqv.'){
                        
                        PSF_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                          TotalIntakeCR12_MAR,TotalBCCR12_MAR,
                                                                                                                          CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                          BCRateDecision('MAR'),false).setScale(0) +
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      TotalIntakeCR12_Pure,TotalBCCR12_Pure,
                                                                                      CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                    }else{
                        PSF_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                          TotalIntakeBTL_MAR,TotalBCBTL_MAR,
                                                                                                                          CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                          BCRateDecision('MAR'),false).setScale(0)+
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      TotalIntakeBTL_Pure,TotalBCBTL_Pure, CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                    }
                        
                    
                    
                    
                    /*
                    PSF_Item_Map.get(param_Id).RealVolume=MethodologyRoute(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                           PSF_Item_Map.get(param_Id).TotalIntake_Completion, PSF_Item_Map.get(param_Id).TotalBC_Completion, 
                                                                           CalculateBCRate(PSF_Item_Map.get(param_Id).TotalIntake_Btl,PSF_Item_Map.get(param_Id).TotalBC_Btl),false);
                    */
                    
                    
                }
                
                
                if(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c=='By Category'){
                    //Grouping by Product Category : Map<Product Category Id, ASI_TH_CRM_PaymentRequestLineItem__c>
                    Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  GroupingMap =ProductCategoryGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, PSF_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,PSFList,PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                    
                    for(String Key:GroupingMap.keySet()){
                        ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= GroupingMap.get(Key);
                        InsertPayLine.ASI_CRM_CN_AC_Code__c = ActivityCode!=null?ActivityCode:null;
                        InsertPayLine=PaymentLineRounding(InsertPayLine);
                        InsertPayLine.ASI_CRM_Module__c=PSF_Item_Map.get(param_Id).Module.Id;
                        
                        
                        InsertPayLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c, 
                                                                                                                          InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c,
                                                                                                                          CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                                                                                                                          BCRateDecision('MAR'),false).setScale(0)+
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c, 
                                                                                      InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c,
                                                                                      CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),BCRateDecision('NoMAR'),false).setScale(0);
                        
                        
                        system.debug('PSF InsertPayLine By Category :  '+InsertPayLine);
                        // Calulate 'CTD Payable Vol. (Std. Btl.)'                               InsertPayLine.ASI_CRM_CN_Payable_Vol__c= MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,InsertPayLine);
                        if(InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c !=0){
                            system.debug('PSF By Category Total_Payable : '+'(( '+InsertPayLine.ASI_CRM_CN_Payable_Vol__c +'/'+ InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c +')*'+ InsertPayLine.ASI_CRM_CN_Incentive_BT__c);
                            Decimal CompleteRate=(InsertPayLine.ASI_CRM_CN_Payable_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c );
                            CompleteRate=CompleteRate.setScale(3);
                            InsertPayLine.ASI_CRM_CN_Total_Payable__c = CompleteRate* InsertPayLine.ASI_CRM_CN_Incentive_BT__c;//system.debug('Now PSF By Category  Total_Payable4:'+InsertPayLine.ASI_CRM_CN_Total_Payable__c); 
                        }else{
                            InsertPayLine.ASI_CRM_CN_Total_Payable__c=0;
                        }
                        PSF_Item_Map.get(param_Id).TotalCTDPayableAmount +=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        PSF_Item_Map.get(param_Id).VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                        
                        InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF',
                                                                PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,false);
                        
                        if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c!=null){
                            InsertPayLine.ASI_CRM_Max_Incentive__c=InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                        }
                        
                        if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c==null || InsertPayLine.ASI_CRM_CN_Incentive_BT__c==0 ){
                            Key='9'+Key;
                        }
                        PSF_Item_Map.get(param_Id).TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        PSF_Item_Map.get(param_Id).TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                        
                        if(!InsertPayLine.ASI_CRM_Non_Contract_Line__c){
                            PSF_Item_Map.get(param_Id).TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                            PSF_Item_Map.get(param_Id).TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                            PSF_Item_Map.get(param_Id).TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                            PSF_Item_Map.get(param_Id).TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                        }
                        //system.debug('Now PSF By Category  Total_Payable :'+InsertPayLine.ASI_CRM_CN_Total_Payable__c);
                        PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        PSF_Item_Map.get(param_Id).DetailLineMap.put(Key,InsertPayLine);
                        
                        
                        
                        TotalIntakeBTL_Pure +=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c:0;
                        TotalBCBTL_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure__c !=null?InsertPayLine.ASI_CRM_CTD_BC_Pure__c:0;
                        TotalIntakeCR12_Pure+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c:0;
                        TotalBCCR12_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c:0;
                        
                        TotalIntakeBTL_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c:0;
                        TotalBCBTL_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell__c:0;
                        TotalIntakeCR12_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c:0;
                        TotalBCCR12_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c:0;
                    }
                    
                    
                    
                    if( PSF_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c =='CR12 Extra Eqv.'){
                        
                        PSF_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                         TotalIntakeCR12_MAR,TotalBCCR12_MAR,
                                                                                                                         CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                         BCRateDecision('MAR'),false).setScale(0) +
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      TotalIntakeCR12_Pure,TotalBCCR12_Pure,
                                                                                      CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                    }else{
                        PSF_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                         TotalIntakeBTL_MAR,TotalBCBTL_MAR,
                                                                                                                         CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                         BCRateDecision('MAR'),false).setScale(0)+
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      TotalIntakeBTL_Pure,TotalBCBTL_Pure, CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                    }
                    
                    
                    
                }
                
                if(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c=='By Total'){
                    ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine = ByTotalPaymentLineCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, PSF_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,PSFList,PSF_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                    InsertPayLine=PaymentLineRounding(InsertPayLine);
                    InsertPayLine.ASI_CRM_Module__c=PSF_Item_Map.get(param_Id).Module.Id;
                    InsertPayLine.ASI_CRM_CN_AC_Code__c = ActivityCode!=null?ActivityCode:null;
                    
                    if(InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c !=0){
                        InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CN_Payable_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c )* InsertPayLine.ASI_CRM_CN_Incentive_BT__c).setScale(3);
                        //InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CTD_Actual_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c ))* InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                    }
                    PSF_Item_Map.get(param_Id).TotalCTDPayableAmount +=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                    
                    PSF_Item_Map.get(param_Id).VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                    
                    InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF',
                                                            PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,false);
                    
                    PSF_Item_Map.get(param_Id).TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                    PSF_Item_Map.get(param_Id).TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                    PSF_Item_Map.get(param_Id).TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                    PSF_Item_Map.get(param_Id).TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                    PSF_Item_Map.get(param_Id).TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                    PSF_Item_Map.get(param_Id).TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                    
                    system.debug('ASI_CRM_CTD_Cap_Collection_Vol__c :'+ InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c);
                    system.debug('ASI_CRM_CTD_Actual_Vol__c :'+ InsertPayLine.ASI_CRM_CTD_Actual_Vol__c);
                    
                    PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                    
                    PSF_Item_Map.get(param_Id).DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),InsertPayLine);
                    PSF_Item_Map.get(param_Id).RealVolume= InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null? InsertPayLine.ASI_CRM_CN_Payable_Vol__c:0;
                    
                }
           
                system.debug('RealVolume :'+ PSF_Item_Map.get(param_Id).RealVolume);
                
                PSF_Item_Map.get(param_Id).Module.ASI_CRM_Suggested_Payable_Amount__c=PSF_Item_Map.get(param_Id).TotalCTDPayableAmount;
                
                if(!PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c){
                    PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c=0;
                    PSF_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c=0;
                }else{
                    //PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c=PSF_Item_Map.get(param_Id).TotalCTDPayableAmount;
                    if(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Historical_Paid_Amount__c!=null){
                        PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c = PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c - PSF_Item_Map.get(param_Id).Module.ASI_CRM_Historical_Paid_Amount__c;
                    }
                    if(PSF_Item_Map.get(param_Id).Module.ASI_CRM_Adjustment__c !=null){
                        PSF_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c= (PSF_Item_Map.get(param_Id).Module.ASI_CRM_Adjustment__c /100) *PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c;
                    }
                }
                
                
            }
        }
        
        RefreshAllData();
    }

    public void GenerateFixedVol(){
        RefreshPaymentLine();
        UpsertPermission=true;
        Msg='';
        
        Decimal TotalIntakeBTL_Pure=0;
        Decimal TotalBCBTL_Pure=0;
        Decimal TotalIntakeCR12_Pure=0;
        Decimal TotalBCCR12_Pure=0;
        
        Decimal TotalIntakeBTL_MAR=0;
        Decimal TotalBCBTL_MAR=0;
        Decimal TotalIntakeCR12_MAR=0;
        Decimal TotalBCCR12_MAR=0;
        
        String param_Id = Apexpages.currentPage().getParameters().get('PARAMIDF');
        System.debug(LoggingLevel.INFO, '*** param_Id: ' + param_Id);
        if(Fixed_Item_Map.containsKey(param_Id) && !Fixed_Item_Map.isEmpty()){
            if(VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c, 
                                            Fixed_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,
                                            Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__c,
                                            'For Fixed ('+Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+'), we meet following error in End Date:') || Test.isRunningTest())
            {
                //remove existing line in Fixed 
                for(String key : Fixed_Item_Map.get(param_Id).DetailLineMap.keySet()){
                    ASI_TH_CRM_PaymentRequestLineItem__c delTarget=Fixed_Item_Map.get(param_Id).DetailLineMap.get(key);
                    if(delTarget.id != null){
                        PaymentLineDeleteList.add(delTarget);
                    }
                    Fixed_Item_Map.get(param_Id).DetailLineMap.remove(key);
                }
                //  ** Reset **
                Fixed_Item_Map.get(param_Id).TotalIntake=0;
                Fixed_Item_Map.get(param_Id).TotalBC=0;
                Fixed_Item_Map.get(param_Id).RealVolume=0;
                Fixed_Item_Map.get(param_Id).TotalCTDPayableAmount=0.0;
                Fixed_Item_Map.get(param_Id).TotalBC_Btl=0.0;
                Fixed_Item_Map.get(param_Id).TotalBC_Completion=0.0;
                Fixed_Item_Map.get(param_Id).TotalIntake_Completion=0.0;
                Fixed_Item_Map.get(param_Id).TotalIntake_Btl=0.0;
                Fixed_Item_Map.get(param_Id).VolumeTarget=0.0;
                Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c=0;
                
                //Geting Subbrand Volume List 
                List<ASI_CRM_Subbrand_Volume__c> LVol= RetrieveSubBrandVolume(PH.ASI_CRM_CN_PO_Start_Date__c, Fixed_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c);
                //BRSF List from contract
                List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> PSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
                //HistoricalPaymentLine
                List<ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentList =new List<ASI_TH_CRM_PaymentRequestLineItem__c> ();
                Map<String,ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentMap= new Map<String,ASI_TH_CRM_PaymentRequestLineItem__c>();
                
                Map<String, Decimal> moduleTotalAmountMap = new Map<String, Decimal>();
               /* String V0_0_POId=PH.ASI_TH_CRM_Contract__c ;
                if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
                    V0_0_POId=PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
                }*/
                ///system.assertEquals(, null);
                //system.debug( 'PSF Module ID' + Fixed_Item_Map.get(param_Id).Module.Id);
                if(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__c!=null){
                    PSFList= [Select id,ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c,ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c,ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c,ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c,
                              ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_CN_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c, ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c, ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                              ASI_CRM_CN_Contract__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_CN_Sub_Brand__r.Name,
                              ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Sub_Brand_Grade__r.Name,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Product_Category__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c,ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c,ASI_CRM_CN_Est_Monthly_Qty__c,ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Activity_Code__c,ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,ASI_CRM_Product_Category__r.Name 
                              FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                              WHERE ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c and ASI_CRM_Module__c=:Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__c and 
                              ASI_CRM_Type__c = 'Fixed' and ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' order by ASI_CRM_CN_Contract__c];
                    
                    for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLine : PSFList) {
                        if (moduleTotalAmountMap.containsKey(brsfLine.ASI_CRM_Module__c)) {
                          Decimal moduleTotalAmount = moduleTotalAmountMap.get(brsfLine.ASI_CRM_Module__c) + brsfLine.ASI_CRM_CN_Est_Total_Dummy__c;
                          moduleTotalAmountMap.put(brsfLine.ASI_CRM_Module__c, moduleTotalAmount);
                        } else {
                          moduleTotalAmountMap.put(brsfLine.ASI_CRM_Module__c, brsfLine.ASI_CRM_CN_Est_Total_Dummy__c);
                        }
                    }
                    
                    HistoricalPaymentList =[select Id,ASI_TH_CRM_Payment_Request__c,ASI_CRM_CN_Sub_Brand__c,ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Product_Category__c,ASI_CRM_CN_Incentive_BT__c 
                                            from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c 
                                            and ASI_CRM_Module__r.ASI_CRM_Parent_Module__c=:Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__c
                                            and ASI_TH_CRM_Payment_Request__c !=: PH.id and RecordType.DeveloperName = : 'ASI_CRM_CN_Payment_Request_Detail_Other'  Order by ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_Version__c ];
                    
                    
                }
                
                
                
                //Getting Activity Code base on the 'Contract Cost Setting' table  
                // List<ASI_CRM_Contract_Cost_Setting__c> LContractCostSettingList =   [SELECT id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c,ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c,  ASI_CRM_CN_Other_Cost_Payment_Request__c 
                //                                                                      FROM ASI_CRM_Contract_Cost_Setting__c  where ASI_CRM_CN_Promotion_Type__c = :PH.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c
                //                                                                      and ASI_CRM_PSF_Activity_Code_Default__c = true];
                // Id ActivityCode; 
                // if(LContractCostSettingList != null && LContractCostSettingList.size()==1){
                //     ActivityCode = LContractCostSettingList[0].ASI_CRM_CN_Activity_Code__c;
                // }
                
                //If Module is By Sub-Brand 
                
                if(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    
                    for(ASI_TH_CRM_PaymentRequestLineItem__c paymentline: HistoricalPaymentList){
                        HistoricalPaymentMap.put(paymentline.ASI_CRM_CN_Sub_Brand__c, paymentline);
                    }
                    
                    //Grouping by Sub-Brand : Map<Sub-Brand Id, ASI_TH_CRM_PaymentRequestLineItem__c>
                    Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  SBGroupingMap =SubBrandGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, Fixed_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,PSFList,Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                    
                    //2nd get the segmet
                    ASI_TH_CRM_Contract__c contract= [select Id,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c
                                                            from ASI_TH_CRM_Contract__c WHERE id =:PH.ASI_TH_CRM_Contract__c ];
                    // List<Date> dateList = new List<Date>();
                    Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());
                    // dateList.add(setDate);
                    Set<Id> subBrandIdSets = new Set<Id>();
                    for(String SubBrandKey:SBGroupingMap.keySet()){
                        subBrandIdSets.add(SBGroupingMap.get(SubBrandKey).ASI_CRM_CN_Sub_Brand__c);
                    }
                    
                    String channel = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
                    String region = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
                    String cityInvestementGrade = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
                    String newImage = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;
                    Map<String, ASI_CRM_CM_GS__c> gsMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdSets);

                    for(String SubBrandKey:SBGroupingMap.keySet()){
                        
                        ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= SBGroupingMap.get(SubBrandKey);
                        System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                        //system.debug('Payable_Vol1.0 : '+InsertPayLine.ASI_CRM_CN_Payable_Vol__c);
                        
                        if(InsertPayLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c == null || Test.isRunningTest()){
                            //If the outlet sells the sub-brand not listed in the linked PO, the sub-brand item will be added by retrieving from the historical payment, the Incentive (Per Bottle) will be read-only.
                            if(HistoricalPaymentMap.containsKey(InsertPayLine.ASI_CRM_CN_Sub_Brand__c)){
                                InsertPayLine.ASI_CRM_CN_Incentive_BT__c=HistoricalPaymentMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_BT__c;
                                InsertPayLine.ASI_CRM_CN_Allow_Changing_Incentive__c=false;
                            }else{//Not in HistoricalPaymentMap
                                if(gsMap.containsKey(InsertPayLine.ASI_CRM_CN_Sub_Brand__c) && gsMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).Actual_CM_GS_Lines__r != null){
                                  for (ASI_CRM_Actual_CM_GS_Line__c cmgsLine : gsMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).Actual_CM_GS_Lines__r ) {
                                    if (cmgsLine.ASI_CRM_CN_Activity_Code__c == Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c) {
                                      InsertPayLine.ASI_CRM_Max_Incentive__c=cmgsLine.ASI_CRM_CN_Max_Incentive__c;
                                      System.debug(LoggingLevel.INFO, '*** InsertPayLine.ASI_CRM_Max_Incentive__c: ' + InsertPayLine.ASI_CRM_Max_Incentive__c);
                                    }
                                  }
                                  
                                }

                                if (InsertPayLine.ASI_CRM_Max_Incentive__c == null) {
                                    InsertPayLine.ASI_CRM_Max_Incentive__c= MaxIncentive;
                                }
                            }
                        }
                        System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                        
                        InsertPayLine.ASI_CRM_CN_AC_Code__c = Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c!=null?Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c:null;
                        InsertPayLine=PaymentLineRounding(InsertPayLine);
                        // Calulate 'CTD Payable Vol. (Std. Btl.)' 
                        InsertPayLine.ASI_CRM_CN_Payable_Vol__c = ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                            InsertPayLine.ASI_CRM_CN_Actual_Vol__c,
                                                                                                                            InsertPayLine.ASI_CRM_CN_Bottle_Collected__c,
                                                                                                                            CalculateBCRate(InsertPayLine.ASI_CRM_CN_Actual_Vol__c,InsertPayLine.ASI_CRM_CN_Bottle_Collected__c),
                                                                                                                            BCRateDecision(InsertPayLine.ASI_CRM_Brand_Code__c),false);
                
                
                        //InsertPayLine.ASI_CRM_CN_Payable_Vol__c= MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,InsertPayLine);
                        InsertPayLine.ASI_CRM_CN_Total_Payable__c = InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Incentive_BT__c * InsertPayLine.ASI_CRM_CN_Payable_Vol__c.setScale(0):0;
                        Fixed_Item_Map.get(param_Id).TotalCTDPayableAmount +=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        Fixed_Item_Map.get(param_Id).VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                        InsertPayLine.ASI_CRM_Module__c=Fixed_Item_Map.get(param_Id).Module.Id;
                        InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other',PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,true);
                        
                        if(InsertPayLine.ASI_CRM_CN_Allow_Changing_Incentive__c){
                            SubBrandKey='9'+SubBrandKey;
                            //InsertPayLine.ASI_CRM_Max_Incentive__c=0;
                        }else{
                            InsertPayLine.ASI_CRM_Suggested_Value__c = InsertPayLine.ASI_CRM_CN_Incentive_BT__c !=NULL? InsertPayLine.ASI_CRM_CN_Incentive_BT__c: 0;
                        }
                        
                        InsertPayLine.ASI_CRM_Suggested_Volume__c = InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null? InsertPayLine.ASI_CRM_CN_Payable_Vol__c:0;
                        
                        if(InsertPayLine.ASI_CRM_Key_Sub_Brand__c){
                            SubBrandKey='0'+SubBrandKey;
                        }
                        Fixed_Item_Map.get(param_Id).TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        Fixed_Item_Map.get(param_Id).TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                        
                        if(!InsertPayLine.ASI_CRM_Non_Contract_Line__c){
                            Fixed_Item_Map.get(param_Id).TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                            Fixed_Item_Map.get(param_Id).TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                            Fixed_Item_Map.get(param_Id).TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                            Fixed_Item_Map.get(param_Id).TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                            
                        }else{
                            InsertPayLine.ASI_CRM_Suggested_Value__c=0;
                        }
                        Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        Fixed_Item_Map.get(param_Id).DetailLineMap.put(SubBrandKey,InsertPayLine);
                            
                        TotalIntakeBTL_Pure +=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c:0;
                        TotalBCBTL_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure__c !=null?InsertPayLine.ASI_CRM_CTD_BC_Pure__c:0;
                        TotalIntakeCR12_Pure+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c:0;
                        TotalBCCR12_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c:0;
                        
                        TotalIntakeBTL_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c:0;
                        TotalBCBTL_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell__c:0;
                        TotalIntakeCR12_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c:0;
                        TotalBCCR12_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c:0;
                        
                    }
                    
                    Fixed_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                     TotalIntakeBTL_MAR,TotalBCBTL_MAR,
                                                                                                                     CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                     BCRateDecision('MAR'),false).setScale(0)+
                        ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                  TotalIntakeBTL_Pure,TotalBCBTL_Pure, CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                  BCRateDecision('NoMAR'),false).setScale(0);
                    
                    
                }
                
                
                if(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c=='By Grade'){
                    //Grouping by Sub-Brand Grade: Map<Sub-Brand Grade Id, ASI_TH_CRM_PaymentRequestLineItem__c>
                    Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  SBGroupingMap =SBGradeGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, Fixed_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,PSFList,Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                    
                    
                    for(String Key:SBGroupingMap.keySet()){
                        ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= SBGroupingMap.get(Key);
                        InsertPayLine.ASI_CRM_CN_AC_Code__c = Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c!=null?Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c:null;
                        InsertPayLine=PaymentLineRounding(InsertPayLine);
                        InsertPayLine.ASI_CRM_Module__c=Fixed_Item_Map.get(param_Id).Module.Id;
                        
                        
                        system.debug('Now InsertPayLine  NoMAR  : '+ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c,
                                                                                      CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),
                                                                                      BCRateDecision('NoMAR'),false));
                        
                        system.debug(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c+ ' BC : '+ InsertPayLine.ASI_CRM_CTD_BC_Martell__c+ 'Now InsertPayLine MAR  '+ ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                          InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c,
                                                                                                                          CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                                                                                                                          BCRateDecision('MAR'),false) );
                        system.debug('Now InsertPayLine2  '+InsertPayLine);
                        
                        
                        
                        if( Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c =='CR12 Extra Eqv.'){
                            
                            InsertPayLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                              InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c,
                                                                                                                              CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                                                                                                                              BCRateDecision('MAR'),false).setScale(0) +
                                ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                          InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c,
                                                                                          CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),
                                                                                          BCRateDecision('NoMAR'),false).setScale(0);
                        }else{
                            InsertPayLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                              InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c,
                                                                                                                              CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                                                                                                                              BCRateDecision('MAR'),false).setScale(0)+
                                ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                          InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c,
                                                                                          CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),
                                                                                          BCRateDecision('NoMAR'),false).setScale(0);
                        }
                        
                   
                        system.debug('Enter InsertPayLine.ASI_CRM_CN_Payable_Vol__c :  '+InsertPayLine.ASI_CRM_CN_Payable_Vol__c);
                        if(InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c !=0){
                            InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CN_Payable_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c )* InsertPayLine.ASI_CRM_CN_Incentive_BT__c).setScale(3);
                            //InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CTD_Actual_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c ))* InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                            system.debug('739 '+InsertPayLine.ASI_CRM_CN_Total_Payable__c);
                        }else{
                            InsertPayLine.ASI_CRM_CN_Total_Payable__c =0;
                        }
                        Fixed_Item_Map.get(param_Id).TotalCTDPayableAmount +=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c!=null){
                            InsertPayLine.ASI_CRM_Max_Incentive__c=InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                        }
                        Fixed_Item_Map.get(param_Id).VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                        InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other',
                                                                PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,false);
                        system.debug('By Grade InsertPayLine ASI_CRM_Suggested_Value__c :  '+InsertPayLine.ASI_CRM_Suggested_Value__c);
                        
                        if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c==null || InsertPayLine.ASI_CRM_CN_Incentive_BT__c==0 ){
                            Key='9'+Key;
                        }
                        Fixed_Item_Map.get(param_Id).TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        Fixed_Item_Map.get(param_Id).TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                        
                        if(!InsertPayLine.ASI_CRM_Non_Contract_Line__c){
                            Fixed_Item_Map.get(param_Id).TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                            Fixed_Item_Map.get(param_Id).TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                            Fixed_Item_Map.get(param_Id).TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                            Fixed_Item_Map.get(param_Id).TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                        }
                        Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        system.debug('V0.0 Full Contract Target 3.0 : '+InsertPayLine.ASI_CRM_CN_Total_Payable__c);
                        
                        Fixed_Item_Map.get(param_Id).DetailLineMap.put(Key,InsertPayLine);
                        
                        TotalIntakeBTL_Pure +=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c:0;
                        TotalBCBTL_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure__c !=null?InsertPayLine.ASI_CRM_CTD_BC_Pure__c:0;
                        TotalIntakeCR12_Pure+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c:0;
                        TotalBCCR12_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c:0;
                        
                        TotalIntakeBTL_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c:0;
                        TotalBCBTL_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell__c:0;
                        TotalIntakeCR12_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c:0;
                        TotalBCCR12_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c:0;
                        
                    }
                    
                    
                    if( Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c =='CR12 Extra Eqv.'){
                        
                        Fixed_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                          TotalIntakeCR12_MAR,TotalBCCR12_MAR,
                                                                                                                          CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                          BCRateDecision('MAR'),false).setScale(0) +
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      TotalIntakeCR12_Pure,TotalBCCR12_Pure,
                                                                                      CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                    }else{
                        Fixed_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                          TotalIntakeBTL_MAR,TotalBCBTL_MAR,
                                                                                                                          CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                          BCRateDecision('MAR'),false).setScale(0)+
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      TotalIntakeBTL_Pure,TotalBCBTL_Pure, CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                    }
                        
                    
                    
                    
                    /*
                    Fixed_Item_Map.get(param_Id).RealVolume=MethodologyRoute(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                           Fixed_Item_Map.get(param_Id).TotalIntake_Completion, Fixed_Item_Map.get(param_Id).TotalBC_Completion, 
                                                                           CalculateBCRate(Fixed_Item_Map.get(param_Id).TotalIntake_Btl,Fixed_Item_Map.get(param_Id).TotalBC_Btl),false);
                    */
                    
                    
                }
                
                
                if(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c=='By Category'){
                    //Grouping by Product Category : Map<Product Category Id, ASI_TH_CRM_PaymentRequestLineItem__c>
                    Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  GroupingMap =ProductCategoryGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, Fixed_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,PSFList,Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                    
                    for(String Key:GroupingMap.keySet()){
                        ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= GroupingMap.get(Key);
                        InsertPayLine.ASI_CRM_CN_AC_Code__c = Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c!=null?Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c:null;
                        InsertPayLine=PaymentLineRounding(InsertPayLine);
                        InsertPayLine.ASI_CRM_Module__c=Fixed_Item_Map.get(param_Id).Module.Id;
                        
                        
                        InsertPayLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c, 
                                                                                                                          InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c,
                                                                                                                          CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                                                                                                                          BCRateDecision('MAR'),false).setScale(0)+
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c, 
                                                                                      InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c,
                                                                                      CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),BCRateDecision('NoMAR'),false).setScale(0);
                        
                        
                        system.debug('Fixed InsertPayLine By Category :  '+InsertPayLine);
                        // Calulate 'CTD Payable Vol. (Std. Btl.)'                               InsertPayLine.ASI_CRM_CN_Payable_Vol__c= MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,InsertPayLine);
                        if(InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c !=0){
                            system.debug('Fixed By Category Total_Payable : '+'(( '+InsertPayLine.ASI_CRM_CN_Payable_Vol__c +'/'+ InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c +')*'+ InsertPayLine.ASI_CRM_CN_Incentive_BT__c);
                            Decimal CompleteRate=(InsertPayLine.ASI_CRM_CN_Payable_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c );
                            CompleteRate=CompleteRate.setScale(3);
                            InsertPayLine.ASI_CRM_CN_Total_Payable__c = CompleteRate* InsertPayLine.ASI_CRM_CN_Incentive_BT__c;//system.debug('Now PSF By Category  Total_Payable4:'+InsertPayLine.ASI_CRM_CN_Total_Payable__c); 
                        }else{
                            InsertPayLine.ASI_CRM_CN_Total_Payable__c=0;
                        }
                        Fixed_Item_Map.get(param_Id).TotalCTDPayableAmount +=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        
                        Fixed_Item_Map.get(param_Id).VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                        
                        InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other',
                                                                PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,false);
                        
                        if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c!=null){
                            InsertPayLine.ASI_CRM_Max_Incentive__c=InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                        }
                        
                        if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c==null || InsertPayLine.ASI_CRM_CN_Incentive_BT__c==0 ){
                            Key='9'+Key;
                        }
                        Fixed_Item_Map.get(param_Id).TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        Fixed_Item_Map.get(param_Id).TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                        
                        if(!InsertPayLine.ASI_CRM_Non_Contract_Line__c){
                            Fixed_Item_Map.get(param_Id).TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                            Fixed_Item_Map.get(param_Id).TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                            Fixed_Item_Map.get(param_Id).TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                            Fixed_Item_Map.get(param_Id).TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                        }
                        //system.debug('Now PSF By Category  Total_Payable :'+InsertPayLine.ASI_CRM_CN_Total_Payable__c);
                        Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                        Fixed_Item_Map.get(param_Id).DetailLineMap.put(Key,InsertPayLine);
                        
                        
                        
                        TotalIntakeBTL_Pure +=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c:0;
                        TotalBCBTL_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure__c !=null?InsertPayLine.ASI_CRM_CTD_BC_Pure__c:0;
                        TotalIntakeCR12_Pure+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c:0;
                        TotalBCCR12_Pure+=InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c:0;
                        
                        TotalIntakeBTL_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c:0;
                        TotalBCBTL_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell__c:0;
                        TotalIntakeCR12_MAR+=InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c:0;
                        TotalBCCR12_MAR+=InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c!=null?InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c:0;
                    }
                    
                    
                    
                    if( Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c =='CR12 Extra Eqv.'){
                        
                        Fixed_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                         TotalIntakeCR12_MAR,TotalBCCR12_MAR,
                                                                                                                         CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                         BCRateDecision('MAR'),false).setScale(0) +
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      TotalIntakeCR12_Pure,TotalBCCR12_Pure,
                                                                                      CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                    }else{
                        Fixed_Item_Map.get(param_Id).RealVolume =ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                         TotalIntakeBTL_MAR,TotalBCBTL_MAR,
                                                                                                                         CalculateBCRate(TotalIntakeBTL_MAR,TotalBCBTL_MAR),
                                                                                                                         BCRateDecision('MAR'),false).setScale(0)+
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      TotalIntakeBTL_Pure,TotalBCBTL_Pure, CalculateBCRate(TotalIntakeBTL_Pure,TotalBCBTL_Pure),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                    }
                    
                    
                    
                }
                
                if(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Volume_Base__c=='By Total'){
                    ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine = ByTotalPaymentLineCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, Fixed_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c,PSFList,Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                    InsertPayLine=PaymentLineRounding(InsertPayLine);
                    InsertPayLine.ASI_CRM_Module__c=Fixed_Item_Map.get(param_Id).Module.Id;
                    InsertPayLine.ASI_CRM_CN_AC_Code__c = Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c!=null?Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c:null;
                    

                    if(InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c !=0){
                        InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CN_Payable_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c )* InsertPayLine.ASI_CRM_CN_Incentive_BT__c).setScale(3);
                        //InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CTD_Actual_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c ))* InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                    }
                    else {
                        InsertPayLine.ASI_CRM_CN_Total_Payable__c=0;
                    }
                    System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                    Fixed_Item_Map.get(param_Id).TotalCTDPayableAmount +=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                    
                    Fixed_Item_Map.get(param_Id).VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                    
                    InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other',
                                                            PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,false);
                    
                    System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                    Fixed_Item_Map.get(param_Id).TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                    Fixed_Item_Map.get(param_Id).TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                    Fixed_Item_Map.get(param_Id).TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                    Fixed_Item_Map.get(param_Id).TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                    Fixed_Item_Map.get(param_Id).TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                    Fixed_Item_Map.get(param_Id).TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                    
                    system.debug('ASI_CRM_CTD_Cap_Collection_Vol__c :'+ InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c);
                    system.debug('ASI_CRM_CTD_Actual_Vol__c :'+ InsertPayLine.ASI_CRM_CTD_Actual_Vol__c);
                    
                    Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                    
                    Fixed_Item_Map.get(param_Id).DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),InsertPayLine);
                    Fixed_Item_Map.get(param_Id).RealVolume= InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null? InsertPayLine.ASI_CRM_CN_Payable_Vol__c:0;
                    
                }
           
                system.debug('RealVolume :'+ Fixed_Item_Map.get(param_Id).RealVolume);
                
                Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Suggested_Payable_Amount__c=Fixed_Item_Map.get(param_Id).TotalCTDPayableAmount;
                
                if(!PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c){
                    Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c=0;
                    Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c=0;
                }else{
                    //Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c=Fixed_Item_Map.get(param_Id).TotalCTDPayableAmount;
                    if(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Historical_Paid_Amount__c!=null){
                        Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c = Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c - Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Historical_Paid_Amount__c;
                    }
                    // if(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Adjustment__c !=null){
                    //     Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c=Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c;
                    //     //Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c=Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c - Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Historical_Paid_Amount__c;
                    // }
                    Decimal moduleTotalAmount = 0;
                    if (ph.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null) {
                      moduleTotalAmount = Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_Expected_Est_Total__c != null? Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_Expected_Est_Total__c:0;
                    }
                    else {
                      moduleTotalAmount = moduleTotalAmountMap.get(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Parent_Module__c);
                    }

                    if(Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Historical_Paid_Amount__c!=null){
                        Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c=moduleTotalAmount - Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Historical_Paid_Amount__c;
                    }
                    else {
                      Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c=moduleTotalAmount;
                    }

                    if (Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c != null && Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c !=0)
                      Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Adjustment__c = (Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c/Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c)*100;
                }
                
                
            }
        }
        
        RefreshAllData();
    }
    
    
    public void GenerateVECVol(){
        
        RefreshPaymentLine();
                
        Decimal TotalIntakeBTL_Pure=0;
        Decimal TotalBCBTL_Pure=0;
        Decimal TotalIntakeCR12_Pure=0;
        Decimal TotalBCCR12_Pure=0;
        
        Decimal TotalIntakeBTL_MAR=0;
        Decimal TotalBCBTL_MAR=0;
        Decimal TotalIntakeCR12_MAR=0;
        Decimal TotalBCCR12_MAR=0;
        
        
        if(VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c, VariableEventCost.Module.ASI_CRM_End_Date__c,VariableEventCost.Module.ASI_CRM_Parent_Module__c,
                                        'For Variable Event Cost, we meet following error in End Date: <br/>'))
        {
            RefreshAllData();
            //remove existing line in VariableEventCost 
            for(String key : VariableEventCost.DetailLineMap.keySet()){
                ASI_TH_CRM_PaymentRequestLineItem__c delTarget=VariableEventCost.DetailLineMap.get(key);
                if(delTarget.id != null){
                    PaymentLineDeleteList.add(delTarget);
                }
                VariableEventCost.DetailLineMap.remove(key);
            }
            
            VariableEventCost.TotalIntake=0;
            VariableEventCost.TotalBC=0;
            VariableEventCost.RealVolume=0;
            VariableEventCost.TotalBC_Btl=0.0;
            VariableEventCost.TotalIntake_Completion=0.0;
            VariableEventCost.TotalBC_Completion=0;
            VariableEventCost.TotalIntake_Btl=0.0;
            VariableEventCost.TotalCTDPayableAmount=0.0;
            VariableEventCost.VolumeTarget=0.0;
            VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c=0.0;
            //Geting Subbrand Volume List 
            List<ASI_CRM_Subbrand_Volume__c> LVol= RetrieveSubBrandVolume(PH.ASI_CRM_CN_PO_Start_Date__c, VariableEventCost.Module.ASI_CRM_End_Date__c);
            //BRSF List from contract
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            //HistoricalPaymentLine
            Map<String,ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentMap= new Map<String,ASI_TH_CRM_PaymentRequestLineItem__c>();
            if(VariableEventCost.Module.ASI_CRM_Parent_Module__c!=null){  // List<ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentList =new List<ASI_TH_CRM_PaymentRequestLineItem__c> ();
                /*String V0_0_POId=PH.ASI_TH_CRM_Contract__c ;
                if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
                    V0_0_POId=PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
                }*/
                //Get Historical Payment Line
                List<ASI_TH_CRM_PaymentRequestLineItem__c> HistoricalPaymentList =[select Id,ASI_TH_CRM_Payment_Request__c,ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Incentive_BT__c 
                                                                                   from ASI_TH_CRM_PaymentRequestLineItem__c 
                                                                                   where ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c 
                                                                                   and ASI_TH_CRM_Payment_Request__c !=: PH.id and RecordType.DeveloperName = : 'ASI_CRM_CN_Payment_Request_Detail_VEC' Order by ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_Version__c ];
                
                for(ASI_TH_CRM_PaymentRequestLineItem__c paymentline: HistoricalPaymentList){
                    HistoricalPaymentMap.put(paymentline.ASI_CRM_CN_Sub_Brand__c, paymentline);
                }

                ContractList= [Select id,ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c,ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c,ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c,ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c,
                               ASI_CRM_Contract_Monthly_Volume_CR12__c,ASI_CRM_Est_Monthly_Volume_CR12__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_CN_Contract__r.ASI_CRM_CN_V00_No_of_Month__c,ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,ASI_CRM_Product_Category__r.Name,ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                               ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,  ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_Sub_Brand__r.Name,ASI_CRM_Product_Category__c,ASI_CRM_Key_Sub_brand__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Sub_Brand_Grade__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c,ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Activity_Code__c
                               FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c 
                               and ASI_CRM_Module__c=:VariableEventCost.Module.ASI_CRM_Parent_Module__c 
                               and ASI_CRM_Type__c = 'Variable Event Cost' 
                               and ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' order by ASI_CRM_CN_Contract__c];
            }


            
            //Getting Activity Code base on the 'Contract Cost Setting' table  
            List<ASI_CRM_Contract_Cost_Setting__c> LContractCostSettingList =   [SELECT id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c,  ASI_CRM_CN_Other_Cost_Payment_Request__c 
                                                                                 FROM ASI_CRM_Contract_Cost_Setting__c  where ASI_CRM_CN_Promotion_Type__c = :PH.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c
                                                                                 and ASI_CRM_VEC_Activity_Code_Defaul__c = true];
            Id ActivityCode; 
            if(LContractCostSettingList != null && LContractCostSettingList.size()==1){
                ActivityCode = LContractCostSettingList[0].ASI_CRM_CN_Activity_Code__c;
            }
            
            
            //If Module is By Sub-Brand 
            if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                //Grouping by Sub-Brand : Map<Sub-Brand Id, ASI_TH_CRM_PaymentRequestLineItem__c>
                Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  SBGroupingMap =SubBrandGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, VariableEventCost.Module.ASI_CRM_End_Date__c,ContractList,VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                
                //2nd get the segmet
                ASI_TH_CRM_Contract__c contract= [select Id,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,
                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c
                                                        from ASI_TH_CRM_Contract__c WHERE id =:PH.ASI_TH_CRM_Contract__c ];
                // List<Date> dateList = new List<Date>();
                Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());
                // dateList.add(setDate);
                Set<Id> subBrandIdSets = new Set<Id>();
                for(String SubBrandKey:SBGroupingMap.keySet()){
                    subBrandIdSets.add(SBGroupingMap.get(SubBrandKey).ASI_CRM_CN_Sub_Brand__c);
                }
                
                String channel = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
                String region = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
                String cityInvestementGrade = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
                String newImage = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;
                Map<String, ASI_CRM_CM_GS__c> gsMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdSets);


                for(String SubBrandKey:SBGroupingMap.keySet()){
                    system.debug('********SBGroupingMap*********');
                    ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= SBGroupingMap.get(SubBrandKey);
                    System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                    if(InsertPayLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c == null || Test.isRunningTest()){
                        //If the outlet sells the sub-brand not listed in the linked PO, the sub-brand item will be added by retrieving from the historical payment, the Incentive (Per Bottle) will be read-only.
                        if(HistoricalPaymentMap.containsKey(InsertPayLine.ASI_CRM_CN_Sub_Brand__c)){
                            InsertPayLine.ASI_CRM_CN_Incentive_BT__c=HistoricalPaymentMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_BT__c;
                            InsertPayLine.ASI_CRM_CN_Allow_Changing_Incentive__c=false;
                        }
                        else {
                            if(gsMap.containsKey(InsertPayLine.ASI_CRM_CN_Sub_Brand__c) && gsMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_VEC__c != null && contract.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                InsertPayLine.ASI_CRM_Max_Incentive__c=gsMap.get(InsertPayLine.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_Max_Incentive_VEC__c;
                              }

                            if (InsertPayLine.ASI_CRM_Max_Incentive__c == null || !contract.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                                  InsertPayLine.ASI_CRM_Max_Incentive__c= MaxIncentive;
                              }
                        }
                    }
                    InsertPayLine.ASI_CRM_CN_AC_Code__c = ActivityCode!=null?ActivityCode:null;
                    InsertPayLine=PaymentLineRounding(InsertPayLine);
                    InsertPayLine.ASI_CRM_Module__c=VariableEventCost.Module.Id;
                    InsertPayLine.ASI_CRM_CN_Payable_Vol__c = ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                                                        InsertPayLine.ASI_CRM_CN_Actual_Vol__c,
                                                                                                                        InsertPayLine.ASI_CRM_CN_Bottle_Collected__c,
                                                                                                                        CalculateBCRate(InsertPayLine.ASI_CRM_CN_Actual_Vol__c,InsertPayLine.ASI_CRM_CN_Bottle_Collected__c),
                                                                                                                        BCRateDecision(InsertPayLine.ASI_CRM_Brand_Code__c),false);
                    
                     System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                    // Calulate 'CTD Payable Vol. (Std. Btl.)'
                    //InsertPayLine.ASI_CRM_CN_Payable_Vol__c= MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,InsertPayLine);
                    InsertPayLine.ASI_CRM_CN_Total_Payable__c = InsertPayLine.ASI_CRM_CN_Incentive_BT__c!=null && InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Incentive_BT__c * InsertPayLine.ASI_CRM_CN_Payable_Vol__c:0;
                    VariableEventCost.TotalCTDPayableAmount+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0 ;
                    
                    VariableEventCost.VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                    if(InsertPayLine.ASI_CRM_CN_Allow_Changing_Incentive__c){
                        SubBrandKey='9'+SubBrandKey;
                    }
                    InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC',
                                                            PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_VEC__c,true);
                     System.debug(LoggingLevel.INFO, '*** InsertPayLine: ' + InsertPayLine);
                    system.debug(' SBGroupingMap:*'+InsertPayLine.ASI_CRM_CN_Total_Payable__c);
                    
                    VariableEventCost.TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                    VariableEventCost.TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                    if(!InsertPayLine.ASI_CRM_Non_Contract_Line__c){
                        VariableEventCost.TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                        VariableEventCost.TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                        VariableEventCost.TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        VariableEventCost.TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                    }
                    VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c+= InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                    
                    VariableEventCost.DetailLineMap.put(SubBrandKey,InsertPayLine);
                }
            }
            
            
            if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Grade' || Test.isRunningTest()){
                //Grouping by Sub-Brand Grade: Map<Sub-Brand Grade Id, ASI_TH_CRM_PaymentRequestLineItem__c>
                Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  SBGroupingMap =SBGradeGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, VariableEventCost.Module.ASI_CRM_End_Date__c,ContractList,VariableEventCost.Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                for(String Key:SBGroupingMap.keySet()){
                    ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= SBGroupingMap.get(Key);
                    InsertPayLine.ASI_CRM_CN_AC_Code__c = ActivityCode!=null?ActivityCode:null;
                    InsertPayLine.ASI_CRM_Module__c=VariableEventCost.Module.Id;
                    InsertPayLine=PaymentLineRounding(InsertPayLine);
                    // Calulate 'CTD Payable Vol. (Std. Btl.)'
                    
                    
                    if( VariableEventCost.Module.ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c =='CR12 Extra Eqv.'){
                        
                        InsertPayLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                             InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c,
                                CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                                 BCRateDecision('MAR'),false)+
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c,
                                                                                      CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                        
                        
                    }else{
                        
                        InsertPayLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                            InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c,
                             CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                             BCRateDecision('MAR'),false)+
                            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                                      InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c,
                                                                                      CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),
                                                                                      BCRateDecision('NoMAR'),false).setScale(0);
                        
                        
                    }

                    //InsertPayLine.ASI_CRM_CN_Payable_Vol__c= MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,InsertPayLine);
                    if(InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c !=0){
                        //InsertPayLine.ASI_CRM_CN_Total_Payable__c = (InsertPayLine.ASI_CRM_CN_Incentive_BT__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c )* InsertPayLine.ASI_CRM_CN_Payable_Vol__c;
                        InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CN_Payable_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c ).setScale(3))* InsertPayLine.ASI_CRM_CN_Incentive_BT__c; 
                    }else{
                        InsertPayLine.ASI_CRM_CN_Total_Payable__c=0;
                    }
                    InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC',
                                                            PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_VEC__c,false);
                    
                    VariableEventCost.TotalCTDPayableAmount+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0 ;
                    VariableEventCost.VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                    if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c==null || InsertPayLine.ASI_CRM_CN_Incentive_BT__c==0 ){
                        Key='9'+Key;
                    }
                    VariableEventCost.TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                    VariableEventCost.TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                    if(!InsertPayLine.ASI_CRM_Non_Contract_Line__c){
                        VariableEventCost.TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                        VariableEventCost.TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                        VariableEventCost.TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        VariableEventCost.TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                    }
                    VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c+= InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                    
                    VariableEventCost.DetailLineMap.put(Key,InsertPayLine);
                }
                
            }
            
            
            if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Category' || Test.isRunningTest()){
                
                //Grouping by Product Category : Map<Product Category Id, ASI_TH_CRM_PaymentRequestLineItem__c>
                Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>  GroupingMap =ProductCategoryGroupingCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, VariableEventCost.Module.ASI_CRM_End_Date__c,ContractList,VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                
                for(String Key:GroupingMap.keySet()){
                    ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine= GroupingMap.get(Key);
                    InsertPayLine.ASI_CRM_CN_AC_Code__c = ActivityCode!=null?ActivityCode:null;
                    InsertPayLine.ASI_CRM_Module__c=VariableEventCost.Module.Id;
                    InsertPayLine=PaymentLineRounding(InsertPayLine);
                    
                    // Calulate 'CTD Payable Vol. (Std. Btl.)'
                    
                    InsertPayLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c, 
                        InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Martell_CR12__c,
                        CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Martell__c,InsertPayLine.ASI_CRM_CTD_BC_Martell__c),
                            BCRateDecision('MAR'),false).setScale(0)+
                        ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c, 
                                                                                  InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,InsertPayLine.ASI_CRM_CTD_BC_Pure_CR12__c,
                                                                                  CalculateBCRate(InsertPayLine.ASI_CRM_CTD_Actual_Vol_Pure__c,InsertPayLine.ASI_CRM_CTD_BC_Pure__c),BCRateDecision('NoMAR'),false).setScale(0);
                    
                    //InsertPayLine.ASI_CRM_CN_Payable_Vol__c= MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,InsertPayLine);
                    if(InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c !=0){
                        //InsertPayLine.ASI_CRM_CN_Total_Payable__c = (InsertPayLine.ASI_CRM_CN_Incentive_BT__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c )* InsertPayLine.ASI_CRM_CN_Payable_Vol__c;
                        InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CN_Payable_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c ).setScale(3))* InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                        
                    }else{
                        InsertPayLine.ASI_CRM_CN_Total_Payable__c=0;
                    }
                    VariableEventCost.TotalCTDPayableAmount+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0 ;
                    
                    VariableEventCost.VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                    if(InsertPayLine.ASI_CRM_CN_Incentive_BT__c==null || InsertPayLine.ASI_CRM_CN_Incentive_BT__c==0 ){
                        Key='9'+Key;
                    }
                    InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC',
                                                            PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_VEC__c,false);
                    VariableEventCost.TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                    VariableEventCost.TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                    if(!InsertPayLine.ASI_CRM_Non_Contract_Line__c){
                        VariableEventCost.TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                        VariableEventCost.TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                        VariableEventCost.TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        VariableEventCost.TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                    }
                    VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c+= InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                    
                    VariableEventCost.DetailLineMap.put(Key,InsertPayLine);
                }                
            }
            
            if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Total' || Test.isRunningTest()){
                ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine = ByTotalPaymentLineCalculation(PH.ASI_CRM_CN_PO_Start_Date__c, VariableEventCost.Module.ASI_CRM_End_Date__c,ContractList,VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c);
                InsertPayLine.ASI_CRM_CN_AC_Code__c = ActivityCode!=null?ActivityCode:null;
                InsertPayLine.ASI_CRM_Module__c=VariableEventCost.Module.Id;
                InsertPayLine=PaymentLineRounding(InsertPayLine);
                // Calulate 'CTD Payable Vol. (Std. Btl.)'
                // InsertPayLine.ASI_CRM_CN_Payable_Vol__c= MethodologyDecision(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,InsertPayLine);
                if(InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c !=0){
                    InsertPayLine.ASI_CRM_CN_Total_Payable__c = ((InsertPayLine.ASI_CRM_CN_Payable_Vol__c /InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c ).setScale(3))* InsertPayLine.ASI_CRM_CN_Incentive_BT__c;
                }else{
                    InsertPayLine.ASI_CRM_CN_Total_Payable__c=0;
                }
                VariableEventCost.TotalCTDPayableAmount+=InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0 ;
                InsertPayLine=PaymentLineTransformation(InsertPayLine,'ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_VEC',
                                                        PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_VEC__c,false);
                
                VariableEventCost.VolumeTarget +=InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                VariableEventCost.TotalIntake+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                VariableEventCost.TotalBC+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                VariableEventCost.TotalIntake_Btl+=InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c:0;
                VariableEventCost.TotalBC_Btl+=InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c:0;
                VariableEventCost.TotalIntake_Completion+=InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c:0;
                VariableEventCost.TotalBC_Completion+=InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                
                VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c+= InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?InsertPayLine.ASI_CRM_CN_Total_Payable__c:0;
                
                VariableEventCost.DetailLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newCounterCreatorLine(),InsertPayLine);
                VariableEventCost.RealVolume+=InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Payable_Vol__c:0;
            }
            
            
            /*********Do not delete ******
            VariableEventCost.RealVolume=MethodologyRoute(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                          VariableEventCost.TotalIntake_Completion,
                                                          VariableEventCost.TotalBC_Completion,
                                                          CalculateBCRate(VariableEventCost.TotalIntake_Btl,VariableEventCost.TotalBC_Btl),false); */
            
            
            VariableEventCost.Module.ASI_CRM_Suggested_Payable_Amount__c=VariableEventCost.TotalCTDPayableAmount;
            if(!PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_VEC__c){
                VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c=0;
                VariableEventCost.Module.ASI_CRM_Actual_Payment__c=0;
            }else{
                //VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c=VariableEventCost.TotalCTDPayableAmount;
                if(VariableEventCost.Module.ASI_CRM_Historical_Paid_Amount__c!=null){
                    VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c = VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c - VariableEventCost.Module.ASI_CRM_Historical_Paid_Amount__c;
                }
                if(VariableEventCost.Module.ASI_CRM_Adjustment__c !=null){
                    VariableEventCost.Module.ASI_CRM_Actual_Payment__c= (VariableEventCost.Module.ASI_CRM_Adjustment__c /100) *VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c;
                } 
            }
            
            
        }
        
    }
    
    
    public ASI_TH_CRM_PaymentRequestLineItem__c PaymentLineRounding(ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine){  //Math.floor
        InsertPayLine.ASI_CRM_CN_Actual_Vol__c =InsertPayLine.ASI_CRM_CN_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CN_Actual_Vol__c.setScale(0):0;
        InsertPayLine.ASI_CRM_CN_Bottle_Collected__c =InsertPayLine.ASI_CRM_CN_Bottle_Collected__c!=null?InsertPayLine.ASI_CRM_CN_Bottle_Collected__c.setScale(0):0;
        InsertPayLine.ASI_CRM_CTD_Actual_Vol__c =InsertPayLine.ASI_CRM_CTD_Actual_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Actual_Vol__c.setScale(0):0;
        InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c =InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c.setScale(0):0;
        
        return InsertPayLine;
        
    }
    
    
    //change the value in PSF payment line
    public ASI_TH_CRM_PaymentRequestLineItem__c PaymentLineTransformation(ASI_TH_CRM_PaymentRequestLineItem__c InsertPayLine, String RecordTypeName, Boolean DisplayOrNot,Boolean IsByVol){
        InsertPayLine.recordtypeid = Global_recordTypeCache.getRtId(RecordTypeName);
        //BC%
        if(InsertPayLine.ASI_CRM_CN_Actual_Vol__c !=0 && InsertPayLine.ASI_CRM_CN_Actual_Vol__c !=null && InsertPayLine.ASI_CRM_CN_Bottle_Collected__c !=null){
            InsertPayLine.ASI_CRM_CN_Collection_Rate__c = (InsertPayLine.ASI_CRM_CN_Bottle_Collected__c/ InsertPayLine.ASI_CRM_CN_Actual_Vol__c)*100;//(InsertPayLine.ASI_CRM_CTD_Cap_Collection_Vol__c/ InsertPayLine.ASI_CRM_CTD_Actual_Vol__c)*100;
        }else{
            InsertPayLine.ASI_CRM_CN_Collection_Rate__c=0.0;
        }
        
        //Completion Rate
        If(InsertPayLine.ASI_CRM_CN_Payable_Vol__c !=null && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null  && InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c!=0 ){
            system.debug('Completion_Rate : '+InsertPayLine.ASI_CRM_CN_Payable_Vol__c + '/'+InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c);
            InsertPayLine.ASI_CRM_CN_Completion_Rate__c=(InsertPayLine.ASI_CRM_CN_Payable_Vol__c/InsertPayLine.ASI_CRM_V0_0_Full_Contract_Target__c)*100;
        }
        
        InsertPayLine.ASI_CRM_Suggested_Value__c = InsertPayLine.ASI_CRM_CN_Payable_Vol__c !=NULL? InsertPayLine.ASI_CRM_CN_Payable_Vol__c.setScale(2): 0;
        InsertPayLine.ASI_CRM_Suggested_Volume__c= InsertPayLine.ASI_CRM_CN_Payable_Vol__c !=NULL? InsertPayLine.ASI_CRM_CN_Payable_Vol__c.setScale(2): 0;
        InsertPayLine.ASI_CRM_CN_Suggested_Amount__c= InsertPayLine.ASI_CRM_CN_Total_Payable__c !=NULL? InsertPayLine.ASI_CRM_CN_Total_Payable__c.setScale(2): 0;
        
        //**rounding**
        InsertPayLine.ASI_CRM_CN_Payable_Vol__c =InsertPayLine.ASI_CRM_CN_Payable_Vol__c!=null?Math.floor(InsertPayLine.ASI_CRM_CN_Payable_Vol__c):0;//.setScale(2)
        InsertPayLine.ASI_CRM_CN_Total_Payable__c =InsertPayLine.ASI_CRM_CN_Total_Payable__c!=null?Math.floor(InsertPayLine.ASI_CRM_CN_Total_Payable__c):0;//.setScale(2)
        
        system.debug('DisplayOrNot: '+DisplayOrNot);
        if(!DisplayOrNot){
            if(IsByVol){ //set as 0
                InsertPayLine.ASI_CRM_Suggested_Value__c =0;
                InsertPayLine.ASI_CRM_CN_Payable_Vol__c=0;
            }else{//IsByAmount
                InsertPayLine.ASI_CRM_CN_Suggested_Amount__c = 0;
                InsertPayLine.ASI_CRM_CN_Total_Payable__c = 0;
            }
        }
        //Do no change the order
        if( (InsertPayLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c == null 
            && RecordTypeName!='ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF')
             || Test.isRunningTest()){
            InsertPayLine.ASI_CRM_CN_Payable_Vol__c =0;
            InsertPayLine.ASI_CRM_CN_Total_Payable__c=0;
        }
        
        return InsertPayLine;
    }
    
    
    
    
    //clear all BRSF Payment line
    public void ResetBRSFDetails(){
        //Remove Curent BRSF Line
        for(String key : BRSFItemMap.DetailLineMap.keySet()){
            ASI_TH_CRM_PaymentRequestLineItem__c delTarget= BRSFItemMap.DetailLineMap.get(key);
            if(delTarget.id != null){
                PaymentLineDeleteList.add(delTarget);
            }
            BRSFItemMap.DetailLineMap.remove(key);
        } 
        BRSFItemMap.Module.ASI_CRM_End_Date__c=null;
        BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c=0;
        BRSFItemMap.Module.ASI_CRM_Actual_Payment__c=0;
        BRSFItemMap.Module.ASI_CRM_Other_Comments__c=null;
        BRSFItemMap.Module.ASI_CRM_Overpayment_Reason__c=null;
        BRSFItemMap.Module.ASI_CRM_Adjustment__c=100;
        BRSFItemMap=ResetInterimData(BRSFItemMap);
    }
    
    //clear all PSF Payment line
    public void ResetPSFDetails(){
        String param_Id = Apexpages.currentPage().getParameters().get('PARAMID');
        if(PSF_Item_Map.containsKey(param_Id) && !PSF_Item_Map.isEmpty()){
            for(String key : PSF_Item_Map.get(param_Id).DetailLineMap.keySet()){
                ASI_TH_CRM_PaymentRequestLineItem__c delTarget=PSF_Item_Map.get(param_Id).DetailLineMap.get(key);
                if(delTarget.id != null){
                    PaymentLineDeleteList.add(delTarget);
                }
                PSF_Item_Map.get(param_Id).DetailLineMap.remove(key);
            }
            PSF_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c=null;
            PSF_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c=0;
            PSF_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c=0;
            PSF_Item_Map.get(param_Id).Module.ASI_CRM_Other_Comments__c=null;
            PSF_Item_Map.get(param_Id).Module.ASI_CRM_Overpayment_Reason__c=null;
            PSF_Item_Map.get(param_Id).Module.ASI_CRM_PSF_Overpayment_Reason__c=null;
            
            PSF_Item_Map.get(param_Id).Module.ASI_CRM_Adjustment__c=100;
            interimData TempinterimData =ResetInterimData(PSF_Item_Map.get(param_Id));
            
        }
    }

    //clear all Fixed Payment line
    public void ResetFixedDetails(){
        String param_Id = Apexpages.currentPage().getParameters().get('PARAMIDF');
        if(Fixed_Item_Map.containsKey(param_Id) && !Fixed_Item_Map.isEmpty()){
            for(String key : Fixed_Item_Map.get(param_Id).DetailLineMap.keySet()){
                ASI_TH_CRM_PaymentRequestLineItem__c delTarget=Fixed_Item_Map.get(param_Id).DetailLineMap.get(key);
                if(delTarget.id != null){
                    PaymentLineDeleteList.add(delTarget);
                }
                Fixed_Item_Map.get(param_Id).DetailLineMap.remove(key);
            }
            Fixed_Item_Map.get(param_Id).Module.ASI_CRM_End_Date__c=null;
            Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Application_Payment_Amount__c=0;
            Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Actual_Payment__c=0;
            Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Other_Comments__c=null;
            Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Overpayment_Reason__c=null;
            Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Fixedcost_Overpayment_Reason__c=null;
            
            Fixed_Item_Map.get(param_Id).Module.ASI_CRM_Adjustment__c=100;
            interimData TempinterimData =ResetInterimData(Fixed_Item_Map.get(param_Id));
            
        }
    }
    
    
    //clear all VEC Payment line
    public void ResetVECDetails(){
        
        for(String key : VariableEventCost.DetailLineMap.keySet()){
            ASI_TH_CRM_PaymentRequestLineItem__c delTarget=VariableEventCost.DetailLineMap.get(key);
            if(delTarget.id != null){
                PaymentLineDeleteList.add(delTarget);
            }
            VariableEventCost.DetailLineMap.remove(key);
        }
        VariableEventCost.Module.ASI_CRM_End_Date__c=null;
        VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c=0;
        VariableEventCost.Module.ASI_CRM_Actual_Payment__c=0;
        VariableEventCost.Module.ASI_CRM_Other_Comments__c=null;
        VariableEventCost.Module.ASI_CRM_Overpayment_Reason__c=null;
        VariableEventCost.Module.ASI_CRM_VEC_Overpayment_Reason__c=null;
        VariableEventCost.Module.ASI_CRM_Adjustment__c=100;
        VariableEventCost=ResetInterimData(VariableEventCost);
    }
    
    
    //Reset Value
    public interimData ResetInterimData(interimData InputData){
        InputData.TotalIntake=0;
        InputData.TotalBC=0;
        InputData.RealVolume=0;
        InputData.TotalBC_Btl=0.0;
        InputData.TotalIntake_Completion=0.0;
        InputData.TotalBC_Completion=0;
        InputData.TotalIntake_Btl=0.0;
        InputData.TotalCTDPayableAmount=0.0;
        InputData.VolumeTarget=0.0;
        
        
        return InputData;
        
    }
    
    //@description: Retrieve SubBrand Volume based on start Date and end Date
    public List<ASI_CRM_Subbrand_Volume__c> RetrieveSubBrandVolume(Date StartDate,Date EndDate){
        
        Date InputStartDate =StartDate;
        Date InputEndDate = EndDate;
        Date CutOffDay = CutOffDate(16);
        
        if(InputStartDate != null){
            InputStartDate = InputStartDate.toStartOfMonth(); 
        }
        if(InputEndDate != null){
            InputEndDate = InputEndDate.toStartOfMonth().addMonths(1).addDays(-1); 
        }
        Set<id> OutletID = new Set<id>();
        
        //Getting Outlet Id including 'Covered Outlet'
        for(ASI_CRM_CN_Covered_Outlet__c o : [Select id, ASI_CRM_CN_Outlet__c from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c]){
            OutletID.add(o.ASI_CRM_CN_Outlet__c);
        }
        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c !='Covered Outlet Only'){
            OutletID.add(PH.ASI_CRM_CN_OutletWS__c);
        }
        system.debug(OutletID+'InputEndDate 20171126*'+InputEndDate+InputStartDate);
        
        List<ASI_CRM_Subbrand_Volume__c> ReturnList = [Select ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Actual_Vol__c,ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c,
                                                       ASI_CRM_Bottle_Collected_CR12__c,ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c, ASI_CRM_Bottle_Collected__c,ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                                       ASI_CRM_Subbrand__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_Account__c, ASI_CRM_End_Date__c, ASI_CRM_Sub_Brand_Grade_Incentive__c, ASI_CRM_CN_Payment_Request_Line_Item__c,
                                                       ASI_CRM_Offtake_Std_Billing__c,ASI_CRM_PR_Direct__c,ASI_CRM_T1_Depletion_STD_Billing__c,ASI_CRM_T2_Depletion_STD_Billing__c,ASI_CRM_Green_Cap_Btl__c,ASI_CRM_Empty_Bottle_Btl__c 
                                                       from ASI_CRM_Subbrand_Volume__c   where ASI_CRM_Account__c IN :OutletID 
                                                       and ASI_CRM_End_Date__c <= :InputEndDate and ASI_CRM_End_Date__c >= :InputStartDate
                                                       and ASI_CRM_CN_Competitor_Sub_brand__c = false   AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                                                       order by ASI_CRM_Account__c, ASI_CRM_Subbrand__c, ASI_CRM_End_Date__c]; 
        
        
        return ReturnList;
        
    }
    
    
    
    
    
    //@Description: Base on Sub-Brand Volume, Contract Line and Historical payment Line,  to generate the Payment line  
    //@param      : SubBrandVolumeList :  from RetrieveSubBrandVolume retrun List.
    //@param      : ContractList. Payment--->Contract----> Contract line.
    //@param      : HistoricalPaymentLineList : historical payment which is not included current payment. If the sub-brand incentive can be retrieved from the historical payment, the Incentive (Per Bottle) will be read-only.
    //@param      :  RecordTypeName : Payment request line Record Type
    //@return     : the refreshed Payment Line list 
    public  Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> SubBrandGroupingCalculation(Date StartDate,Date EndDate,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList,String MethodologyCode){
        
        Date InputStartDate =StartDate;
        Date InputEndDate = EndDate;
        Date CutOffDay = CutOffDate(16);
        
        if(InputStartDate != null){
            InputStartDate = InputStartDate.toStartOfMonth(); 
        }
        if(InputEndDate != null){
            InputEndDate = InputEndDate.toStartOfMonth().addMonths(1).addDays(-1); 
        }
        Set<id> OutletID = new Set<id>();
        
        //Getting Outlet Id including 'Covered Outlet'
        for(ASI_CRM_CN_Covered_Outlet__c o : [Select id, ASI_CRM_CN_Outlet__c from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c]){
            OutletID.add(o.ASI_CRM_CN_Outlet__c);
        }
        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c !='Covered Outlet Only'){
            OutletID.add(PH.ASI_CRM_CN_OutletWS__c);
        }
        
        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> SubBrandGroupingMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>(); //Sub-Brand, Payment Line
        
        // Looping the Subbrand Volume       
        for(ASI_CRM_Subbrand_Volume__c SubVol: [Select ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Actual_Vol__c,ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c,
                                                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c,
                                                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                                                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                                ASI_CRM_Bottle_Collected_CR12__c,ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c,
                                                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c, ASI_CRM_Bottle_Collected__c,ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                                ASI_CRM_Subbrand__c, ASI_CRM_End_Date__c, ASI_CRM_Sub_Brand_Grade_Incentive__c, ASI_CRM_CN_Payment_Request_Line_Item__c,
                                                ASI_CRM_Offtake_Std_Billing__c,ASI_CRM_PR_Direct__c,ASI_CRM_T1_Depletion_STD_Billing__c,ASI_CRM_T2_Depletion_STD_Billing__c,ASI_CRM_Green_Cap_Btl__c,ASI_CRM_Empty_Bottle_Btl__c 
                                                from ASI_CRM_Subbrand_Volume__c   where ASI_CRM_Account__c IN :OutletID 
                                                and ASI_CRM_End_Date__c <= :InputEndDate and ASI_CRM_End_Date__c >= :InputStartDate
                                                and ASI_CRM_CN_Competitor_Sub_brand__c = false   AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                                                order by ASI_CRM_Account__c, ASI_CRM_Subbrand__c, ASI_CRM_End_Date__c])
        {
            Boolean AllowPut=false;
            if(Cal_CTD_Actual_Vol(SubVol)!=0 || Cal_CTD_Cap_Collection_Vol(SubVol)!=0){
                AllowPut=true;
            }
            
            if(SubVol.ASI_CRM_Subbrand__c !=null && AllowPut ){
                String Mapkeystr=NameSortingASC(SubVol.ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+SubVol.ASI_CRM_Subbrand__c;
                
              /*  Decimal PayableVol= ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(MethodologyCode,Cal_CTD_Actual_Vol(SubVol),Cal_CTD_Cap_Collection_Vol(SubVol),
                                                                                              CalculateBCRate(Cal_CTD_Actual_Vol(SubVol),Cal_CTD_Cap_Collection_Vol(SubVol)),
                                                                                              BCRateDecision(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c),false);
                system.debug('Now  PayableVol'+ PayableVol );*/
                if(SubBrandGroupingMap.containsKey(Mapkeystr)){ 
                    // If contain, recalculate  'CTD Actual Vollume' and  'CTD Cap Collection Vol' 
                    ASI_TH_CRM_PaymentRequestLineItem__c TempData =SubBrandGroupingMap.get(Mapkeystr);
                    TempData.ASI_CRM_CTD_Actual_Vol__c +=Cal_CTD_Actual_Vol(SubVol);
                    TempData.ASI_CRM_CN_Actual_Vol__c+=Cal_CTD_Actual_Vol(SubVol);
                    TempData.ASI_CRM_CTD_Cap_Collection_Vol__c += Cal_CTD_Cap_Collection_Vol(SubVol);
                    TempData.ASI_CRM_CN_Bottle_Collected__c+= Cal_CTD_Cap_Collection_Vol(SubVol);
                    //TempData.ASI_CRM_CN_Payable_Vol__c += PayableVol;
                    TempData.ASI_CRM_Actual_Volume_Id__c +=';'+SubVol.Id; // save actual volume Id
                    system.debug(' Mapkeystr :'+Mapkeystr+TempData);
                    SubBrandGroupingMap.remove(Mapkeystr);
                    SubBrandGroupingMap.put(Mapkeystr, TempData);
                }else{// If not contain, create new paymen request line
                    ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                        ASI_CRM_CN_Sub_Brand__c=SubVol.ASI_CRM_Subbrand__c,ASI_CRM_Actual_Volume_Id__c=SubVol.Id,
                        ASI_CRM_Sub_Brand_Grade__c=SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_Line_Name__c=SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c:SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_CN_Standard__c=SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_TH_CRM_Payment_Request__c = PH.id,ASI_CRM_Volume_Base__c='By Sub-Brand',
                        ASI_CRM_CN_Allow_Changing_Incentive__c = true,ASI_CRM_Non_Contract_Line__c=true,
                        ASI_CRM_Brand_Code__c= SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c !=null?  SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c:'', 
                        ASI_CRM_V0_0_Full_Contract_Target__c=0.0,ASI_CRM_CN_Incentive_BT__c=0,ASI_CRM_CN_Target_BT__c = 0,
                        ASI_CRM_CN_Completion_Rate__c = 0,ASI_CRM_CN_Collection_Rate__c = 0,ASI_CRM_CN_Suggested_Amount__c = 0, 
                        ASI_CRM_Suggested_Volume__c = 0,
                        ASI_CRM_CTD_Actual_Vol__c = Cal_CTD_Actual_Vol(SubVol),
                        ASI_CRM_CN_Actual_Vol__c= Cal_CTD_Actual_Vol(SubVol),
                        ASI_CRM_CN_Bottle_Collected__c=Cal_CTD_Cap_Collection_Vol(SubVol),
                        ASI_CRM_CTD_Cap_Collection_Vol__c= Cal_CTD_Cap_Collection_Vol(SubVol));
                    
                    SubBrandGroupingMap.put(Mapkeystr, PaymentRequestLine);
                }
            }
        }
        
        
        
        
        //Looping the Contract List
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractList){
            
            if(ContractLine.ASI_CRM_CN_Sub_Brand__c !=null){
                String Mapkeystr=NameSortingASC(ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+ContractLine.ASI_CRM_CN_Sub_Brand__c;
                if(SubBrandGroupingMap.containsKey(Mapkeystr)){
                    ASI_TH_CRM_PaymentRequestLineItem__c TempData =SubBrandGroupingMap.get(Mapkeystr);
                    system.debug('debug Key Sub brand : '+Mapkeystr +ContractLine.ASI_CRM_Key_Sub_brand__c );
                    if(ContractLine.ASI_CRM_Key_Sub_brand__c){
                        TempData.ASI_CRM_Key_Sub_Brand__c=true;
                    }
                    if((ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !='0.0') || 
                      ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null || ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == 0){
                        TempData.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null ? 0 : ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                        TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                    }else{
                        TempData.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                        TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                    }
                    
                    TempData.ASI_CRM_CN_Allow_Changing_Incentive__c = false;
                    TempData.ASI_CRM_Non_Contract_Line__c=false;
                    TempData.ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.id;
                    SubBrandGroupingMap.remove(Mapkeystr);
                    SubBrandGroupingMap.put(Mapkeystr, TempData);
                    
                }else{// create new payment line
                    ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                        ASI_CRM_CN_Sub_Brand__c=ContractLine.ASI_CRM_CN_Sub_Brand__c,
                        ASI_CRM_CN_Standard__c=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_Line_Name__c=ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c:ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_TH_CRM_Payment_Request__c = PH.id,ASI_CRM_Volume_Base__c='By Sub-Brand',
                        ASI_CRM_CN_Allow_Changing_Incentive__c = false,ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.id,
                        ASI_CRM_CTD_Cap_Collection_Vol__c=0,ASI_CRM_CTD_Actual_Vol__c=0,
                        ASI_CRM_Key_Sub_Brand__c=ContractLine.ASI_CRM_Key_Sub_brand__c?true:false,
                        ASI_CRM_CN_Completion_Rate__c = 0,ASI_CRM_Non_Contract_Line__c=false,
                        ASI_CRM_CN_Collection_Rate__c = 0,ASI_CRM_CN_Bottle_Collected__c=0,
                        ASI_CRM_CN_Suggested_Amount__c = 0, ASI_CRM_CN_Target_BT__c = 0,
                        ASI_CRM_Suggested_Volume__c = 0,ASI_CRM_CN_Actual_Vol__c=0
                      );
                    
                    if((ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !='0.0') || 
                      ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null || ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == 0){
                        PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c = ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null ? 0 : ContractLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                        PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                    }else{
                        PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c = ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                        PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        
                    }
                    
                    SubBrandGroupingMap.put(Mapkeystr,PaymentRequestLine);
                }
            }
        }
        
        return SubBrandGroupingMap;
    }
    
    
    
    
    
    //***********************************By Grade Grouping****************************************************
    public  Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> SBGradeGroupingCalculation(Date StartDate,Date EndDate,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList,String UnitName,String MethodologyCode){
        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> SBGradeGroupingMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        Date InputStartDate =StartDate;
        Date InputEndDate = EndDate;
        Date CutOffDay = CutOffDate(16);
        
        if(InputStartDate != null){
            InputStartDate = InputStartDate.toStartOfMonth(); 
        }
        if(InputEndDate != null){
            InputEndDate = InputEndDate.toStartOfMonth().addMonths(1).addDays(-1); 
        }
        Set<id> OutletID = new Set<id>();
        
        //Getting Outlet Id including 'Covered Outlet'
        for(ASI_CRM_CN_Covered_Outlet__c o : [Select id, ASI_CRM_CN_Outlet__c from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c]){
            OutletID.add(o.ASI_CRM_CN_Outlet__c);
        }
        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c !='Covered Outlet Only'){
            OutletID.add(PH.ASI_CRM_CN_OutletWS__c);
        }
        
        
        // Looping the Subbrand Volume       
        for(ASI_CRM_Subbrand_Volume__c SubVol: [Select ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Actual_Vol__c,ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c,
                                                       ASI_CRM_Bottle_Collected_CR12__c,ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c, ASI_CRM_Bottle_Collected__c,ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                                       ASI_CRM_Subbrand__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_Account__c, ASI_CRM_End_Date__c, ASI_CRM_Sub_Brand_Grade_Incentive__c, ASI_CRM_CN_Payment_Request_Line_Item__c,
                                                       ASI_CRM_Offtake_Std_Billing__c,ASI_CRM_PR_Direct__c,ASI_CRM_T1_Depletion_STD_Billing__c,ASI_CRM_T2_Depletion_STD_Billing__c,ASI_CRM_Green_Cap_Btl__c,ASI_CRM_Empty_Bottle_Btl__c 
                                                       from ASI_CRM_Subbrand_Volume__c   where ASI_CRM_Account__c IN :OutletID 
                                                       and ASI_CRM_End_Date__c <= :InputEndDate and ASI_CRM_End_Date__c >= :InputStartDate
                                                       and ASI_CRM_CN_Competitor_Sub_brand__c = false   AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                                                       order by ASI_CRM_Account__c, ASI_CRM_Subbrand__c, ASI_CRM_End_Date__c])
        {
            Boolean AllowPut=false;
            if(UnitName=='CR12 Extra Eqv.'){
                if(Cal_Inteke_VolCR12(SubVol)!=0 || Cal_BottleCollected_VolCR12(SubVol)!=0){
                    AllowPut=true;
                }
            }else{
                if(Cal_CTD_Actual_Vol(SubVol)!=0 || Cal_CTD_Cap_Collection_Vol(SubVol)!=0){
                    AllowPut=true;
                }
            }
           
            
            if(SubVol.ASI_CRM_Subbrand__c !=null && SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c!=null && AllowPut){
                Decimal TempIntake=Cal_CTD_Actual_Vol(SubVol);
                Decimal TempBC=Cal_CTD_Cap_Collection_Vol(SubVol);
                if(UnitName=='CR12 Extra Eqv.'){
                    TempIntake=Cal_Inteke_VolCR12(SubVol);
                    TempBC=Cal_BottleCollected_VolCR12(SubVol);
                }
                String Mapkeystr=NameSortingASC(SubVol.ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
                /*Decimal PayableVol= ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(MethodologyCode,Cal_Inteke_VolCR12(SubVol),Cal_BottleCollected_VolCR12(SubVol),
                    CalculateBCRate(Cal_CTD_Actual_Vol(SubVol),Cal_CTD_Cap_Collection_Vol(SubVol)),
                    BCRateDecision(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c),false);*/
                
                System.debug('SBGradeGroupingCalculation Intake : '+ Cal_Inteke_VolCR12(SubVol));
                
                if(SBGradeGroupingMap.containsKey(Mapkeystr)){// If contain, recalculate  'CTD Actual Vollume' and  'CTD Cap Collection Vol' 
                    ASI_TH_CRM_PaymentRequestLineItem__c TempData =SBGradeGroupingMap.get(Mapkeystr);
                    TempData.ASI_CRM_CTD_Actual_Vol__c +=TempIntake;
                    TempData.ASI_CRM_CTD_Cap_Collection_Vol__c += TempBC;
                    TempData.ASI_CRM_CN_Actual_Vol__c += Cal_CTD_Actual_Vol(SubVol);
                    TempData.ASI_CRM_CN_Bottle_Collected__c += Cal_CTD_Cap_Collection_Vol(SubVol);
                    TempData.ASI_CRM_Actual_Volume_Id__c +=';'+SubVol.Id;
                    if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c)){
                        TempData.ASI_CRM_CTD_Actual_Vol_Martell__c+=Cal_CTD_Actual_Vol(SubVol);
                        TempData.ASI_CRM_CTD_BC_Martell__c+=Cal_CTD_Cap_Collection_Vol(SubVol);
                        TempData.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c+=Cal_Inteke_VolCR12(SubVol);
                        TempData.ASI_CRM_CTD_BC_Martell_CR12__c+=Cal_BottleCollected_VolCR12(SubVol);
                        system.debug('T2233:'+SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c + Cal_BottleCollected_VolCR12(SubVol));
                    }else{
                        TempData.ASI_CRM_CTD_Actual_Vol_Pure__c += Cal_CTD_Actual_Vol(SubVol);
                        TempData.ASI_CRM_CTD_BC_Pure__c +=Cal_CTD_Cap_Collection_Vol(SubVol);
                        TempData.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c+=Cal_Inteke_VolCR12(SubVol);
                        TempData.ASI_CRM_CTD_BC_Pure_CR12__c+=Cal_BottleCollected_VolCR12(SubVol);
                    }
                    
                    //Check (Excl. Premium and below) 
                    if(SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<4){
                        TempData.ASI_CRM_Intake_Excl_Premium__c +=TempIntake;
                        TempData.ASI_CRM_BC_Excl_Premium__c += TempBC;
                        if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c)){
                            TempData.ASI_CRM_Intake_Martell_Excl_Premium__c +=TempIntake;
                            TempData.ASI_CRM_BC_Martell_Excl_Premium__c += TempBC;
                        }else{
                            TempData.ASI_CRM_Intake_Pure_Excl_Premium__c +=TempIntake;
                            TempData.ASI_CRM_BC_Pure_Excl_Premium__c += TempBC;
                        }
                    }
                    
                    SBGradeGroupingMap.remove(Mapkeystr);
                    SBGradeGroupingMap.put(Mapkeystr, TempData);
                }else{// If not contain, create new paymen request line  ASI_CRM_CN_Payable_Vol__c=PayableVol, 
                    ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                        ASI_CRM_Sub_Brand_Grade__c=SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                        ASI_CRM_Actual_Volume_Id__c=SubVol.Id,
                        ASI_CRM_Line_Name__c=SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c!=null?SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c:SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_CN_Standard__c=SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_TH_CRM_Payment_Request__c = PH.id,ASI_CRM_Volume_Base__c='By Grade',
                        ASI_CRM_Suggested_Value__c=0,
                        ASI_CRM_V0_0_Full_Contract_Target__c=0,
                        ASI_CRM_Max_Incentive__c=0,ASI_CRM_Non_Contract_Line__c=true,
                        ASI_CRM_CN_Incentive_BT__c=0,ASI_CRM_CTD_Actual_Vol_Martell__c=0,
                        ASI_CRM_CTD_Actual_Vol_Pure__c=0,ASI_CRM_CTD_Actual_Vol_Pure_CR12__c=0,ASI_CRM_CTD_BC_Pure_CR12__c=0,ASI_CRM_CTD_Actual_Vol_Martell_CR12__c=0,ASI_CRM_CTD_BC_Martell_CR12__c=0,
                        ASI_CRM_CTD_BC_Martell__c=0,ASI_CRM_Full_Contract_Target_ExclPremium__c=0,
                        ASI_CRM_CTD_BC_Pure__c=0,
                        ASI_CRM_Intake_Excl_Premium__c=0,
                        ASI_CRM_BC_Excl_Premium__c=0,
                        ASI_CRM_Intake_Pure_Excl_Premium__c=0,
                        ASI_CRM_BC_Pure_Excl_Premium__c=0,
                        ASI_CRM_Intake_Martell_Excl_Premium__c=0,
                        ASI_CRM_BC_Martell_Excl_Premium__c=0,
                        ASI_CRM_CN_Target_BT__c = 0,
                        ASI_CRM_CN_Completion_Rate__c = 0,
                        ASI_CRM_CN_Collection_Rate__c = 0,ASI_CRM_CN_Suggested_Amount__c = 0, ASI_CRM_Suggested_Volume__c = 0,
                        ASI_CRM_CTD_Actual_Vol__c = TempIntake,ASI_CRM_CTD_Cap_Collection_Vol__c= TempBC,
                        ASI_CRM_CN_Actual_Vol__c= Cal_CTD_Actual_Vol(SubVol),
                        ASI_CRM_CN_Bottle_Collected__c=Cal_CTD_Cap_Collection_Vol(SubVol));
                    
                    if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c)){//Martell
                        PaymentRequestLine.ASI_CRM_CTD_Actual_Vol_Martell__c=Cal_CTD_Actual_Vol(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_BC_Martell__c=Cal_CTD_Cap_Collection_Vol(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c=Cal_Inteke_VolCR12(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_BC_Martell_CR12__c=Cal_BottleCollected_VolCR12(SubVol);
                        system.debug('T2233:'+SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c + Cal_BottleCollected_VolCR12(SubVol));
                    }else{
                        PaymentRequestLine.ASI_CRM_CTD_Actual_Vol_Pure__c=Cal_CTD_Actual_Vol(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_BC_Pure__c=Cal_CTD_Cap_Collection_Vol(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c=Cal_Inteke_VolCR12(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_BC_Pure_CR12__c=Cal_BottleCollected_VolCR12(SubVol);
                    }
                    
                    //Check (Excl. Premium and below) 
                    if(SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<4){
                        PaymentRequestLine.ASI_CRM_Intake_Excl_Premium__c=TempIntake;
                        PaymentRequestLine.ASI_CRM_BC_Excl_Premium__c= TempBC;
                        if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c)){
                            PaymentRequestLine.ASI_CRM_Intake_Martell_Excl_Premium__c=TempIntake;
                            PaymentRequestLine.ASI_CRM_BC_Martell_Excl_Premium__c= TempBC;
                        }else{
                            PaymentRequestLine.ASI_CRM_Intake_Pure_Excl_Premium__c=TempIntake;
                            PaymentRequestLine.ASI_CRM_BC_Pure_Excl_Premium__c= TempBC;
                        }
                    }
                    
                    
                    
                    SBGradeGroupingMap.put(Mapkeystr, PaymentRequestLine);
                }
            }
        }
        
        
        //Looping the Contract List
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractList){
            if(ContractLine.ASI_CRM_Sub_Brand_Grade__c !=null){
                String Mapkeystr=NameSortingASC(ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c)+ContractLine.ASI_CRM_Sub_Brand_Grade__c;
                if(SBGradeGroupingMap.containsKey(Mapkeystr)){
                    ASI_TH_CRM_PaymentRequestLineItem__c TempData =SBGradeGroupingMap.get(Mapkeystr);
                    //TempData.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    TempData.ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.id;
                    TempData.ASI_CRM_Non_Contract_Line__c=false;
                    
                    if((ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !='0.0') ||
                      ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null || ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0){
                        if(UnitName=='CR12 Extra Eqv.'){
                            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null? 0 : ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                            }else{
                                TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                            }
                            TempData.ASI_CRM_Full_Contract_Target_ExclPremium__c += ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }else{
                            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Est_Total_QTY_std_Btl__c == null ? 0 : ContractLine.ASI_CRM_Est_Total_QTY_std_Btl__c;
                            }else{
                                TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                            }
                            TempData.ASI_CRM_Full_Contract_Target_ExclPremium__c += ContractLine.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }
                        TempData.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    }else{// create in V0.0
                        if(UnitName=='CR12 Extra Eqv.'){
                            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c ==null? 0 : ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
                            }else{
                                TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                            }
                            TempData.ASI_CRM_Full_Contract_Target_ExclPremium__c += ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }else{
                            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c ==null? 0 : ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c;        
                            }else{
                                TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                            }
                            TempData.ASI_CRM_Full_Contract_Target_ExclPremium__c += ContractLine.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }
                        TempData.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    }
                    
                    
                    //system.debug('V0.0 Full Contract Target : '+TempData.ASI_CRM_V0_0_Full_Contract_Target__c);
                    SBGradeGroupingMap.remove(Mapkeystr);
                    SBGradeGroupingMap.put(Mapkeystr, TempData);
                }else{// Create new payment line
                    ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = 
                        new ASI_TH_CRM_PaymentRequestLineItem__c(
                            ASI_CRM_Sub_Brand_Grade__c=ContractLine.ASI_CRM_Sub_Brand_Grade__c,ASI_CRM_Max_Incentive__c=0,
                            ASI_CRM_Line_Name__c=ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c!=null? ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c:ContractLine.ASI_CRM_Sub_Brand_Grade__r.Name,
                            ASI_CRM_CN_Standard__c=ContractLine.ASI_CRM_Sub_Brand_Grade__r.Name,
                            ASI_TH_CRM_Payment_Request__c = PH.id,ASI_CRM_CN_Bottle_Collected__c=0,
                            ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Suggested_Value__c=0,
                            ASI_CRM_CN_Allow_Changing_Incentive__c = false,ASI_CRM_CN_Target_BT__c = 0,
                            ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.id,ASI_CRM_CN_Actual_Vol__c=0,
                            ASI_CRM_CTD_Cap_Collection_Vol__c=0,ASI_CRM_Full_Contract_Target_ExclPremium__c=0,
                            ASI_CRM_CTD_Actual_Vol__c=0,
                            ASI_CRM_CTD_Actual_Vol_Martell__c=0,
                            ASI_CRM_CTD_Actual_Vol_Pure__c=0,
                            ASI_CRM_CTD_BC_Martell__c=0,ASI_CRM_CN_Incentive_BT__c=0,
                            ASI_CRM_CTD_BC_Pure__c=0,
                            ASI_CRM_CN_Completion_Rate__c = 0,
                            ASI_CRM_CN_Collection_Rate__c = 0,
                            ASI_CRM_CN_Suggested_Amount__c = 0, 
                            ASI_CRM_Suggested_Volume__c = 0,ASI_CRM_Non_Contract_Line__c=false );
                    
                    
                    //  ASI_CRM_CN_Incentive_BT__c = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c,
                    //ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c
                    
                    
                    if((ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !='0.0') ||
                      ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null || ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0){
                        if(UnitName=='CR12 Extra Eqv.'){
                            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null? 0 : ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                            }else{
                                PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                            }
                            PaymentRequestLine.ASI_CRM_Full_Contract_Target_ExclPremium__c = ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }else{
                            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Est_Total_QTY_std_Btl__c == null ? 0 : ContractLine.ASI_CRM_Est_Total_QTY_std_Btl__c;
                            }else{
                                PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Est_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                            }
                            PaymentRequestLine.ASI_CRM_Full_Contract_Target_ExclPremium__c = ContractLine.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }
                        PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    }else{
                        if(UnitName=='CR12 Extra Eqv.'){
                            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c ==null? 0 : ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
                            }else{
                                PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                            }
                            PaymentRequestLine.ASI_CRM_Full_Contract_Target_ExclPremium__c = ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }else{
                            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                                PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c ==null? 0 : ContractLine.ASI_CRM_Contract_Total_QTY_std_Btl__c;
                            }else{
                                PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                            }
                            PaymentRequestLine.ASI_CRM_Full_Contract_Target_ExclPremium__c = ContractLine.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }
                        PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    }
                    
                    
                    SBGradeGroupingMap.put(Mapkeystr, PaymentRequestLine);
                }
                
                
            }
        }
        return SBGradeGroupingMap;
    }
    
    
    
    
    
    
    //********************Generating Payment Line by Product Category Grouping***************
    public  Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> ProductCategoryGroupingCalculation(Date StartDate,Date EndDate,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList,String MethodologyCode){
        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> GroupingMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        Date InputStartDate =StartDate;
        Date InputEndDate = EndDate;
        Date CutOffDay = CutOffDate(16);
        
        if(InputStartDate != null){
            InputStartDate = InputStartDate.toStartOfMonth(); 
        }
        if(InputEndDate != null){
            InputEndDate = InputEndDate.toStartOfMonth().addMonths(1).addDays(-1); 
        }
        Set<id> OutletID = new Set<id>();
        
        //Getting Outlet Id including 'Covered Outlet'
        for(ASI_CRM_CN_Covered_Outlet__c o : [Select id, ASI_CRM_CN_Outlet__c from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c]){
            OutletID.add(o.ASI_CRM_CN_Outlet__c);
        }
        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c !='Covered Outlet Only'){
            OutletID.add(PH.ASI_CRM_CN_OutletWS__c);
        }
        
        // Looping the Subbrand Volume       
        for(ASI_CRM_Subbrand_Volume__c SubVol: [Select ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Actual_Vol__c,ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c,
                                                       ASI_CRM_Bottle_Collected_CR12__c,ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c, ASI_CRM_Bottle_Collected__c,ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                                       ASI_CRM_Subbrand__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_Account__c, ASI_CRM_End_Date__c, ASI_CRM_Sub_Brand_Grade_Incentive__c, ASI_CRM_CN_Payment_Request_Line_Item__c,
                                                       ASI_CRM_Offtake_Std_Billing__c,ASI_CRM_PR_Direct__c,ASI_CRM_T1_Depletion_STD_Billing__c,ASI_CRM_T2_Depletion_STD_Billing__c,ASI_CRM_Green_Cap_Btl__c,ASI_CRM_Empty_Bottle_Btl__c 
                                                       from ASI_CRM_Subbrand_Volume__c   where ASI_CRM_Account__c IN :OutletID 
                                                       and ASI_CRM_End_Date__c <= :InputEndDate and ASI_CRM_End_Date__c >= :InputStartDate
                                                       and ASI_CRM_CN_Competitor_Sub_brand__c = false   AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                                                       order by ASI_CRM_Account__c, ASI_CRM_Subbrand__c, ASI_CRM_End_Date__c])
        {
            Boolean AllowPut=false;
            if(Cal_Inteke_VolCR12(SubVol)!=0 || Cal_BottleCollected_VolCR12(SubVol)!=0){
                AllowPut=true;
            }
            if(SubVol.ASI_CRM_Subbrand__c !=null && SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c !=null && AllowPut){
                String Mapkeystr=NameSortingASC(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c)+SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c;
                Decimal PayableVol= ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(MethodologyCode,
                                                                                              Cal_Inteke_VolCR12(SubVol),
                                                                                              Cal_BottleCollected_VolCR12(SubVol),
                                                                                              CalculateBCRate(Cal_CTD_Actual_Vol(SubVol),Cal_CTD_Cap_Collection_Vol(SubVol)),
                                                                                              BCRateDecision(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c),false);
                
                System.debug('ProductCategoryGroupingCalculation Intake : '+ Cal_Inteke_VolCR12(SubVol));
                if(GroupingMap.containsKey(Mapkeystr)){ 
                    // If contain, recalculate  'CTD Actual Vollume' and  'CTD Cap Collection Vol' 
                    ASI_TH_CRM_PaymentRequestLineItem__c TempData =GroupingMap.get(Mapkeystr);
                    TempData.ASI_CRM_CTD_Actual_Vol__c +=Cal_Inteke_VolCR12(SubVol);
                    TempData.ASI_CRM_CTD_Cap_Collection_Vol__c += Cal_BottleCollected_VolCR12(SubVol);
                    TempData.ASI_CRM_CN_Actual_Vol__c += Cal_CTD_Actual_Vol(SubVol);
                    TempData.ASI_CRM_CN_Bottle_Collected__c += Cal_CTD_Cap_Collection_Vol(SubVol);
                    TempData.ASI_CRM_Actual_Volume_Id__c +=';'+SubVol.Id;
                    
                    if(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c =='COG'){
                       TempData.ASI_CRM_CTD_Actual_Vol_Martell__c +=Cal_CTD_Actual_Vol(SubVol);
                        TempData.ASI_CRM_CTD_BC_Martell__c +=Cal_CTD_Cap_Collection_Vol(SubVol);
                        TempData.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c +=Cal_Inteke_VolCR12(SubVol);
                        TempData.ASI_CRM_CTD_BC_Martell_CR12__c +=Cal_BottleCollected_VolCR12(SubVol);
                    }else{
                        TempData.ASI_CRM_CTD_Actual_Vol_Pure__c +=Cal_CTD_Actual_Vol(SubVol);
                        TempData.ASI_CRM_CTD_BC_Pure__c +=Cal_CTD_Cap_Collection_Vol(SubVol);
                        TempData.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c +=Cal_Inteke_VolCR12(SubVol);
                        TempData.ASI_CRM_CTD_BC_Pure_CR12__c +=Cal_BottleCollected_VolCR12(SubVol);
                    }   
                    
                    if(SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<4){
                        TempData.ASI_CRM_Intake_Excl_Premium__c+=Cal_Inteke_VolCR12(SubVol);
                        TempData.ASI_CRM_BC_Excl_Premium__c+= Cal_BottleCollected_VolCR12(SubVol);
                        if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c)){
                            TempData.ASI_CRM_Intake_Martell_Excl_Premium__c+=Cal_Inteke_VolCR12(SubVol);
                            TempData.ASI_CRM_BC_Martell_Excl_Premium__c+= Cal_BottleCollected_VolCR12(SubVol);
                        }else{
                            TempData.ASI_CRM_Intake_Pure_Excl_Premium__c+=Cal_Inteke_VolCR12(SubVol);
                            TempData.ASI_CRM_BC_Pure_Excl_Premium__c+= Cal_BottleCollected_VolCR12(SubVol);
                        }
                    }
                    
                    GroupingMap.remove(Mapkeystr);
                    GroupingMap.put(Mapkeystr, TempData);
                }else{// If not contain, create new paymen request line         ASI_CRM_CN_Payable_Vol__c=PayableVol,
                    ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                        ASI_CRM_Product_Category__c=SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c,
                        ASI_TH_CRM_Payment_Request__c = PH.id,ASI_CRM_Volume_Base__c='By Category',
                        ASI_CRM_Max_Incentive__c=0,ASI_CRM_Actual_Volume_Id__c=SubVol.Id,ASI_CRM_Intake_Excl_Premium__c=0,
                        ASI_CRM_BC_Excl_Premium__c=0,
                        ASI_CRM_Intake_Pure_Excl_Premium__c=0,
                        ASI_CRM_BC_Pure_Excl_Premium__c=0,
                        ASI_CRM_Intake_Martell_Excl_Premium__c=0,
                        ASI_CRM_BC_Martell_Excl_Premium__c=0,
                        ASI_CRM_Line_Name__c=SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                        ASI_CRM_V0_0_Full_Contract_Target__c=0,ASI_CRM_Non_Contract_Line__c=true,ASI_CRM_Full_Contract_Target_ExclPremium__c=0,
                        ASI_CRM_CN_Incentive_BT__c=0,ASI_CRM_CN_Target_BT__c = 0,ASI_CRM_CN_Completion_Rate__c = 0,
                        ASI_CRM_CN_Collection_Rate__c = 0,ASI_CRM_CN_Suggested_Amount__c = 0, ASI_CRM_Suggested_Volume__c = 0,
                        ASI_CRM_CN_Actual_Vol__c=Cal_CTD_Actual_Vol(SubVol),ASI_CRM_CTD_Actual_Vol_Pure_CR12__c=0,ASI_CRM_CTD_BC_Pure_CR12__c=0,ASI_CRM_CTD_Actual_Vol_Martell_CR12__c=0,ASI_CRM_CTD_BC_Martell_CR12__c=0,
                        ASI_CRM_CN_Bottle_Collected__c=Cal_CTD_Cap_Collection_Vol(SubVol),ASI_CRM_CTD_Actual_Vol_Pure__c=0,ASI_CRM_CTD_BC_Pure__c=0,
                        ASI_CRM_CTD_Actual_Vol__c = Cal_Inteke_VolCR12(SubVol),ASI_CRM_CTD_Actual_Vol_Martell__c=0,ASI_CRM_CTD_BC_Martell__c=0,
                        ASI_CRM_CTD_Cap_Collection_Vol__c= Cal_BottleCollected_VolCR12(SubVol));
                    
                    
                    if(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c =='COG'){
                        PaymentRequestLine.ASI_CRM_CTD_Actual_Vol_Martell__c=Cal_CTD_Actual_Vol(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_BC_Martell__c=Cal_CTD_Cap_Collection_Vol(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c=Cal_Inteke_VolCR12(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_BC_Martell_CR12__c=Cal_BottleCollected_VolCR12(SubVol);
                    }else{
                        PaymentRequestLine.ASI_CRM_CTD_Actual_Vol_Pure__c=Cal_CTD_Actual_Vol(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_BC_Pure__c=Cal_CTD_Cap_Collection_Vol(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c=Cal_Inteke_VolCR12(SubVol);
                        PaymentRequestLine.ASI_CRM_CTD_BC_Pure_CR12__c=Cal_BottleCollected_VolCR12(SubVol);
                    }  
                    
                    if(SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<4){
                        PaymentRequestLine.ASI_CRM_Intake_Excl_Premium__c=Cal_Inteke_VolCR12(SubVol);
                        PaymentRequestLine.ASI_CRM_BC_Excl_Premium__c= Cal_BottleCollected_VolCR12(SubVol);
                        if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c)){
                            PaymentRequestLine.ASI_CRM_Intake_Martell_Excl_Premium__c=Cal_Inteke_VolCR12(SubVol);
                            PaymentRequestLine.ASI_CRM_BC_Martell_Excl_Premium__c= Cal_BottleCollected_VolCR12(SubVol);
                        }else{
                            PaymentRequestLine.ASI_CRM_Intake_Pure_Excl_Premium__c=Cal_Inteke_VolCR12(SubVol);
                            PaymentRequestLine.ASI_CRM_BC_Pure_Excl_Premium__c= Cal_BottleCollected_VolCR12(SubVol);
                        }
                    }
                    
                    GroupingMap.put(Mapkeystr, PaymentRequestLine);
                }
            }
        }
        //Looping the Contract List
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractList){
            if(ContractLine.ASI_CRM_Product_Category__c !=null){
                String Mapkeystr=NameSortingASC(ContractLine.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c)+ContractLine.ASI_CRM_Product_Category__c;
                
                if(GroupingMap.containsKey(Mapkeystr)){
                    ASI_TH_CRM_PaymentRequestLineItem__c TempData =GroupingMap.get(Mapkeystr);
                    
                    if((ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !='0.0') ||
                      ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null || ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0){
                        TempData.ASI_CRM_Full_Contract_Target_ExclPremium__c += ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                            TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c ==null? 0 : ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                        }else{
                            TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }
                        TempData.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    }else{
                        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                            TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c ==null? 0 : ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
                        }else{
                            TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }
                        TempData.ASI_CRM_Full_Contract_Target_ExclPremium__c += ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        TempData.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    }
                    
                    //TempData.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    //TempData.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c ==null? 0 : ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
                    
                    TempData.ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.id;
                    TempData.ASI_CRM_Non_Contract_Line__c=false;
                    GroupingMap.remove(Mapkeystr);
                    GroupingMap.put(Mapkeystr, TempData);
                }else{// Create new payment line
                    ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_CRM_Product_Category__c=ContractLine.ASI_CRM_Product_Category__c,ASI_CRM_Full_Contract_Target_ExclPremium__c=0,
                                                                                                                       ASI_TH_CRM_Payment_Request__c = PH.id,ASI_CRM_Volume_Base__c='By Category', 
                                                                                                                       ASI_CRM_CN_Allow_Changing_Incentive__c = false,ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.id,
                                                                                                                       ASI_CRM_CTD_Cap_Collection_Vol__c=0,ASI_CRM_CTD_Actual_Vol__c=0,ASI_CRM_CN_Completion_Rate__c = 0,
                                                                                                                       ASI_CRM_CN_Collection_Rate__c = 0,ASI_CRM_CN_Actual_Vol__c=0,ASI_CRM_CN_Incentive_BT__c=0,
                                                                                                                       ASI_CRM_Max_Incentive__c=0,ASI_CRM_CN_Target_BT__c = 0,ASI_CRM_CN_Bottle_Collected__c=0,
                                                                                                                       ASI_CRM_Line_Name__c=ContractLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c!=null?ContractLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c:ContractLine.ASI_CRM_Product_Category__r.Name,
                                                                                                                       ASI_CRM_CN_Suggested_Amount__c = 0, ASI_CRM_Suggested_Volume__c = 0 );
                    ///,ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c ==null? 0 : ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c 
                    //ASI_CRM_CN_Incentive_BT__c = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c
                    if((ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !='0.0'||
                      ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null || ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0)){
                        PaymentRequestLine.ASI_CRM_Full_Contract_Target_ExclPremium__c = ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                            PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c ==null? 0 : ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                        }else{
                            PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;   
                        }
                        PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;
                    }else{
                        PaymentRequestLine.ASI_CRM_Full_Contract_Target_ExclPremium__c = ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                            PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c ==null? 0 : ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
                        }else{
                            PaymentRequestLine.ASI_CRM_V0_0_Full_Contract_Target__c = ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                        }
                        PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c = ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                    }
                    
                    GroupingMap.put(Mapkeystr, PaymentRequestLine);
                }
                
            }
        }
        
        return GroupingMap ;
    }
    
    
    //************************************By Total ****************************************************************
    public ASI_TH_CRM_PaymentRequestLineItem__c ByTotalPaymentLineCalculation(Date StartDate,Date EndDate,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractList,String MethodologyCode ){
          
        Date InputStartDate =StartDate;
        Date InputEndDate = EndDate;
        Date CutOffDay = CutOffDate(16);
        
        if(InputStartDate != null){
            InputStartDate = InputStartDate.toStartOfMonth(); 
        }
        if(InputEndDate != null){
            InputEndDate = InputEndDate.toStartOfMonth().addMonths(1).addDays(-1); 
        }
        Set<id> OutletID = new Set<id>();
        
        //Getting Outlet Id including 'Covered Outlet'
        for(ASI_CRM_CN_Covered_Outlet__c o : [Select id, ASI_CRM_CN_Outlet__c from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c]){
            OutletID.add(o.ASI_CRM_CN_Outlet__c);
        }
        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c !='Covered Outlet Only'){
            OutletID.add(PH.ASI_CRM_CN_OutletWS__c);
        }
        
        ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine= new ASI_TH_CRM_PaymentRequestLineItem__c (ASI_TH_CRM_Payment_Request__c = PH.id,ASI_CRM_Volume_Base__c='By Total',ASI_CRM_CTD_Cap_Collection_Vol__c=0,
                                                                                                    ASI_CRM_Intake_Excl_Premium__c=0,
                                                                                                    ASI_CRM_BC_Excl_Premium__c=0,
                                                                                                    ASI_CRM_Intake_Pure_Excl_Premium__c=0,
                                                                                                    ASI_CRM_BC_Pure_Excl_Premium__c=0,
                                                                                                    ASI_CRM_Intake_Martell_Excl_Premium__c=0,
                                                                                                    ASI_CRM_BC_Martell_Excl_Premium__c=0,
                                                                                                    ASI_CRM_CTD_Actual_Vol__c=0,ASI_CRM_CN_Completion_Rate__c = 0,ASI_CRM_V0_0_Full_Contract_Target__c=0,ASI_CRM_CN_Payable_Vol__c=0,
                                                                                                    ASI_CRM_CN_Collection_Rate__c = 0,ASI_CRM_CTD_Actual_Vol_Martell__c=0,ASI_CRM_CTD_BC_Martell__c=0,ASI_CRM_CTD_Actual_Vol_Pure__c=0,ASI_CRM_CTD_BC_Pure__c=0,
                                                                                                    ASI_CRM_CN_Suggested_Amount__c = 0,ASI_CRM_CN_Incentive_BT__c=0,ASI_CRM_CN_Target_BT__c = 0,ASI_CRM_Full_Contract_Target_ExclPremium__c=0,
                                                                                                    ASI_CRM_Suggested_Volume__c = 0,ASI_CRM_CTD_Actual_Vol_Pure_CR12__c=0,ASI_CRM_CTD_BC_Pure_CR12__c=0,ASI_CRM_CTD_BC_Martell_CR12__c=0,ASI_CRM_CTD_Actual_Vol_Martell_CR12__c=0,ASI_CRM_Actual_Volume_Id__c=' ',ASI_CRM_CN_Actual_Vol__c=0,ASI_CRM_CN_Bottle_Collected__c=0);
        for(ASI_CRM_Subbrand_Volume__c SubVol: [Select ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Actual_Vol__c,ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Category_Code__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.Name,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_Sequence__c,
                                                       ASI_CRM_Bottle_Collected_CR12__c,ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_CR12__c,
                                                       ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c, ASI_CRM_Bottle_Collected__c,ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                                       ASI_CRM_Subbrand__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_Account__c, ASI_CRM_End_Date__c, ASI_CRM_Sub_Brand_Grade_Incentive__c, ASI_CRM_CN_Payment_Request_Line_Item__c,
                                                       ASI_CRM_Offtake_Std_Billing__c,ASI_CRM_PR_Direct__c,ASI_CRM_T1_Depletion_STD_Billing__c,ASI_CRM_T2_Depletion_STD_Billing__c,ASI_CRM_Green_Cap_Btl__c,ASI_CRM_Empty_Bottle_Btl__c 
                                                       from ASI_CRM_Subbrand_Volume__c   where ASI_CRM_Account__c IN :OutletID 
                                                       and ASI_CRM_End_Date__c <= :InputEndDate and ASI_CRM_End_Date__c >= :InputStartDate
                                                       and ASI_CRM_CN_Competitor_Sub_brand__c = false   AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE
                                                       order by ASI_CRM_Account__c, ASI_CRM_Subbrand__c, ASI_CRM_End_Date__c])
        {
            PaymentLine.ASI_CRM_CTD_Actual_Vol__c +=Cal_Inteke_VolCR12(SubVol);
            PaymentLine.ASI_CRM_CTD_Cap_Collection_Vol__c += Cal_BottleCollected_VolCR12(SubVol);
            PaymentLine.ASI_CRM_CN_Actual_Vol__c += Cal_CTD_Actual_Vol(SubVol);
            PaymentLine.ASI_CRM_CN_Bottle_Collected__c += Cal_CTD_Cap_Collection_Vol(SubVol);
            PaymentLine.ASI_CRM_Actual_Volume_Id__c +=';'+SubVol.Id;
            if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c)){
                PaymentLine.ASI_CRM_CTD_Actual_Vol_Martell__c +=Cal_CTD_Actual_Vol(SubVol);
                PaymentLine.ASI_CRM_CTD_BC_Martell__c +=Cal_CTD_Cap_Collection_Vol(SubVol);
                PaymentLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c +=Cal_Inteke_VolCR12(SubVol);
                PaymentLine.ASI_CRM_CTD_BC_Martell_CR12__c +=Cal_BottleCollected_VolCR12(SubVol);
            }else{
                PaymentLine.ASI_CRM_CTD_Actual_Vol_Pure__c +=Cal_CTD_Actual_Vol(SubVol);
                PaymentLine.ASI_CRM_CTD_BC_Pure__c +=Cal_CTD_Cap_Collection_Vol(SubVol);
                PaymentLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c +=Cal_Inteke_VolCR12(SubVol);
                PaymentLine.ASI_CRM_CTD_BC_Pure_CR12__c +=Cal_BottleCollected_VolCR12(SubVol);
            }
            
            if(SubVol.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c<4){
                PaymentLine.ASI_CRM_Intake_Excl_Premium__c +=Cal_Inteke_VolCR12(SubVol);
                PaymentLine.ASI_CRM_BC_Excl_Premium__c += Cal_BottleCollected_VolCR12(SubVol);
                if(ASI_CRM_CN_HeavyPaymentUtilitiesClass.IsMartellSubBrandOrNot(SubVol.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c)){
                    PaymentLine.ASI_CRM_Intake_Martell_Excl_Premium__c +=Cal_Inteke_VolCR12(SubVol);
                    PaymentLine.ASI_CRM_BC_Martell_Excl_Premium__c += Cal_BottleCollected_VolCR12(SubVol);
                }else{
                    PaymentLine.ASI_CRM_Intake_Pure_Excl_Premium__c +=Cal_Inteke_VolCR12(SubVol);
                    PaymentLine.ASI_CRM_BC_Pure_Excl_Premium__c += Cal_BottleCollected_VolCR12(SubVol);
                }
            }
            
        }
        
        
        system.debug('*************** By Total ************');
        system.debug('Actual_Vol_Martell : '+PaymentLine.ASI_CRM_CTD_Actual_Vol_Martell__c);
        system.debug('CTD_Actual_Vol_Pure : '+PaymentLine.ASI_CRM_CTD_Actual_Vol_Pure__c);
        system.debug('CTD_BC_Martell : '+PaymentLine.ASI_CRM_CTD_BC_Martell__c);
        system.debug('CTD_BC_Pure : '+ PaymentLine.ASI_CRM_CTD_BC_Pure__c);        
        
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractList){
            PaymentLine.ASI_CRM_CN_Contract_BRSF_Line_Item__c = ContractLine.id;
            System.debug(LoggingLevel.INFO, '*** ContractLine: ' + ContractLine);
            if(ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !=null && ContractLine.ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c !='0.0'||
                      ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null || ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == 0){
                if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                    PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c ==null? 0 : ContractLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                }else{
                    PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Est_Monthly_Volume_CR12__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                }
                PaymentLine.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Est_Total_Dummy__c;                
                PaymentLine.ASI_CRM_Full_Contract_Target_ExclPremium__c += ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c*PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
            }else{
                if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                    PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c ==null? 0 : ContractLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
                }else{
                    PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c += ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c ==null? 0 : ContractLine.ASI_CRM_Contract_Monthly_Volume_CR12__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
                }
                PaymentLine.ASI_CRM_CN_Incentive_BT__c += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c == null ? 0 : ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c;
                PaymentLine.ASI_CRM_Full_Contract_Target_ExclPremium__c += ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c ==null? 0 : ContractLine.ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c * PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V00_No_of_Month__c;
            }
            
        }
        
        
        PaymentLine.ASI_CRM_CN_Payable_Vol__c=ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(MethodologyCode, PaymentLine.ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,PaymentLine.ASI_CRM_CTD_BC_Martell_CR12__c,
                                                                                                        CalculateBCRate(PaymentLine.ASI_CRM_CTD_Actual_Vol_Martell__c,PaymentLine.ASI_CRM_CTD_BC_Martell__c),
                                                                                                        BCRateDecision('MAR'),false).setScale(0)+
            ASI_CRM_CN_HeavyPaymentUtilitiesClass.MethodologyDecision(MethodologyCode, PaymentLine.ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,PaymentLine.ASI_CRM_CTD_BC_Pure_CR12__c,
                                                                      CalculateBCRate(PaymentLine.ASI_CRM_CTD_Actual_Vol_Pure__c,PaymentLine.ASI_CRM_CTD_BC_Pure__c),BCRateDecision('NoMAR'),false).setScale(0);
        
        System.debug(LoggingLevel.INFO, '*** PaymentLine: ' + PaymentLine);
        return PaymentLine;
    }
    
    
    
    public Decimal BCRateDecision(String BrandCode){
        Decimal ReturnBCRate=1;
        if(BrandCode=='MAR'){
            ReturnBCRate=PH.ASI_TH_CRM_Contract__r.ASI_CRM_Martell_BC_Rate__c;
        }else{
            ReturnBCRate=PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c;
        }
        return ReturnBCRate;
    }
    
    
    
    
    
    //@description:decide the  CTD Payable Vol. (Std. Btl.) based on the Methodology object
    
    public Decimal MethodologyDecision(String MethodologyCode,ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine){//ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c
        //BottleCollection
        Decimal ReturnValue=0.0;
        Decimal BCRate=0;
        if(PaymentLine.ASI_CRM_CN_Actual_Vol__c !=0 && PaymentLine.ASI_CRM_CN_Actual_Vol__c !=null && PaymentLine.ASI_CRM_CN_Bottle_Collected__c !=null){
            BCRate = (PaymentLine.ASI_CRM_CN_Bottle_Collected__c/ PaymentLine.ASI_CRM_CN_Actual_Vol__c)*100;
        }
        ReturnValue=MethodologyRoute(MethodologyCode,PaymentLine.ASI_CRM_CTD_Actual_Vol__c,PaymentLine.ASI_CRM_CTD_Cap_Collection_Vol__c,BCRate,false);
        return ReturnValue;
    }
    
    
    
    //M01: Min (BC, Intake)  --------------> (Min of CTD Actual Vol (Std Btl) &&     CTD Cap Collection Vol (Std Btl)   )
    //M02  :  BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC                  
    //M03: Min (BC/V0.0 BC%, Intake)       ; M04 : Intake  M05: Others 
    Public Decimal MethodologyRoute(String MethodologyCode,Decimal InputIntake,Decimal InputBC,Decimal InputBCRate, Boolean CalBCinFun ){
        // CalBCinFun-->true: Calculate BC in Function
        //  CalBCinFun-->false: using InputBC
        Decimal ReturnNumber=0;
        Decimal BCRate=0;
        
        if(!CalBCinFun){
            BCRate=InputBCRate;
        }else if(InputIntake!=0 && InputIntake!=null){
            BCRate=(InputBC/InputIntake)*100;
        }
        
        if(InputIntake==null){
            InputIntake=0;
        }
        if(InputBC==null){
            InputBC=0;
        }
        //****compare**
        if(MethodologyCode=='M01'){
            if(InputIntake>InputBC){
                ReturnNumber=InputBC;
            }else{
                ReturnNumber=InputIntake;
            }
        }else if(MethodologyCode=='M02'){
            system.debug(BCRate+'MethodologyCode M02'+PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c);
            if(BCRate>=PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c){
                ReturnNumber=InputIntake;
            }else{
                ReturnNumber=InputBC;
            }
            
            if(InputIntake==0){
                ReturnNumber=0;
            }
        }else if(MethodologyCode=='M03'){
            
            Decimal CalIntake=0;
            CalIntake=(InputBC/PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c)*100;
            if(CalIntake>InputIntake){
                ReturnNumber=InputIntake;
            }else{
                ReturnNumber=CalIntake;
            }
            
        }else if(MethodologyCode=='M04'){
            ReturnNumber=InputIntake;
        }else if(MethodologyCode=='M05'){
            ReturnNumber=0;
        }else{
            ReturnNumber=InputIntake;
        }
        
        
        return ReturnNumber;
    }
    
    public Decimal CalculateBCRate(Decimal InputIntake,Decimal InputBC){
        Decimal ReturnBCRate=0;
        
        if(InputIntake!=null && InputIntake!=0){
            ReturnBCRate=(InputBC/InputIntake)*100; 
        }
        
        return ReturnBCRate;
    }
    
    
    //@description: Calculate the 'CTD Actual Vollume' in payment line . CTD Actual Vol: PR Direct (ASI_CRM_PR_Direct__c) , T1 Depletion (STD Billing) (ASI_CRM_T1_Depletion_STD_Billing__c) and T2 Depletion (STD Billing) (ASI_CRM_T2_Depletion_STD_Billing__c)
    public Decimal Cal_CTD_Actual_Vol(ASI_CRM_Subbrand_Volume__c SubbrandVolume){
        Decimal CTDActualVol=0.0;
        CTDActualVol+= SubbrandVolume.ASI_CRM_PR_Direct_STD_Billing__c == null ? 0 :SubbrandVolume.ASI_CRM_PR_Direct_STD_Billing__c;
        CTDActualVol+= SubbrandVolume.ASI_CRM_T1_Depletion_STD_Billing__c == null ? 0 :SubbrandVolume.ASI_CRM_T1_Depletion_STD_Billing__c;
        CTDActualVol+= SubbrandVolume.ASI_CRM_T2_Depletion_STD_Billing__c == null ? 0 :SubbrandVolume.ASI_CRM_T2_Depletion_STD_Billing__c;
        
        if(CTDActualVol>0){
            CTDActualVol= CTDActualVol.round(System.RoundingMode.FLOOR);
        }
        
        return CTDActualVol;
    }
    
    //@description: Calculate the  'CTD Cap Collection Vol' in payment line' in payment line  CTD Cap Collection Vol :  Green Cap (Std Btl) (ASI_CRM_Green_Cap_Btl__c) , Empty Btl (Std Btl) (ASI_CRM_Empty_Bottle_Btl__c) and Gray Cap * coefficient (Std Btl)
    public Decimal Cal_CTD_Cap_Collection_Vol(ASI_CRM_Subbrand_Volume__c SubbrandVolume){
        Decimal CTDCapCollectionVol=0.0;
        if(SubbrandVolume.ASI_CRM_Bottle_Collected__c!=null){
            CTDCapCollectionVol+=SubbrandVolume.ASI_CRM_Bottle_Collected__c;
        }else{
            CTDCapCollectionVol+= SubbrandVolume.ASI_CRM_Green_Cap_Btl__c == null ? 0 :SubbrandVolume.ASI_CRM_Green_Cap_Btl__c;
            CTDCapCollectionVol+= SubbrandVolume.ASI_CRM_Empty_Bottle_Btl__c == null ? 0 :SubbrandVolume.ASI_CRM_Empty_Bottle_Btl__c;
        }
        
        if(CTDCapCollectionVol>0){
            CTDCapCollectionVol= CTDCapCollectionVol.round(System.RoundingMode.FLOOR);
        }

        
        return CTDCapCollectionVol;
    }
    
    
    public Decimal Cal_Inteke_VolCR12(ASI_CRM_Subbrand_Volume__c SubbrandVolume){
        Decimal VolumeValue=0;
        VolumeValue+= SubbrandVolume.ASI_CRM_T1_Depletion_CR12__c == null ? 0 :SubbrandVolume.ASI_CRM_T1_Depletion_CR12__c;
        VolumeValue+= SubbrandVolume.ASI_CRM_T2_Depletion_CR12__c == null ? 0 :SubbrandVolume.ASI_CRM_T2_Depletion_CR12__c;
        VolumeValue+= SubbrandVolume.ASI_CRM_PR_Direct_CR12__c == null ? 0 :SubbrandVolume.ASI_CRM_PR_Direct_CR12__c;
        
        if(VolumeValue>0){
            VolumeValue= VolumeValue.round(System.RoundingMode.FLOOR);
        }

        return VolumeValue;
    }
    
    public Decimal Cal_BottleCollected_VolCR12(ASI_CRM_Subbrand_Volume__c SubbrandVolume){
        Decimal VolumeValue= SubbrandVolume.ASI_CRM_Bottle_Collected_CR12__c == null ? 0 :SubbrandVolume.ASI_CRM_Bottle_Collected_CR12__c;
        
        if(VolumeValue>0){
            VolumeValue= VolumeValue.round(System.RoundingMode.FLOOR);
        }
        return VolumeValue;
    }
    
    public static date CutOffDate(integer strDay){
        Date returnDate;
        Integer strDate = Date.Today().Day();
        Integer strMonth;
        Integer strEndDay;
        Integer strYear;
        if (strDay != 0){
            if (strDate >= strDay){
                strMonth = Date.Today().addMonths(-1).Month();
                strYear = Date.Today().addMonths(-1).year();
            }
            if (strDate < strDay){
                strMonth = Date.Today().addMonths(-2).Month();
                strYear = Date.Today().addMonths(-2).year();
            }
            strEndDay = Date.daysInMonth(strYear, strMonth);
            returnDate = Date.newinstance(strYear,strMonth,strEndDay);
        }else{
            returnDate = Date.Today();
        }
        return returnDate;
    }
    
    //****************End of Generating  Volume*****************************************************************************************************
    
    
    
    
    
    public void ErrorHandling(String ErrorMsg){
        msg +=ErrorMsg + '</br>';
        UpsertPermission = false;
    }
    
    
    Public void ModuleChecking(ASI_CRM_Module__c InputModule,string TypeName){
    }
    
    //***********************************************************Save the record ************************************************************************************
    public PageReference saveItems(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);
        
        PH.ASI_CRM_Total_Actual_Amount__c=0;
        PH.ASI_CRM_Total_Variable_Amount__c=0;
        PageReference pageRef = null;
        //Define variable
        UpsertPermission = true;
        msg='';
        List<ASI_TH_CRM_PaymentRequestLineItem__c> UpsertBRSFList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        Database.upsertResult[] UpsertTarget;
        Database.deleteResult[] DeleteTarget;
        
        UpsertBRSFList=ValdationChecking();
        
        //upsert Module 
        List<ASI_CRM_Module__c> UpsertModuleList= new List<ASI_CRM_Module__c>();
        ModuleChecking(BRSFItemMap.Module,'BRSF 空瓶回收费');
        if(BRSFItemMap.Module.ASI_CRM_End_Date__c!=null){
            if(!VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c, 
                                             BRSFItemMap.Module.ASI_CRM_End_Date__c,
                                             BRSFItemMap.Module.ASI_CRM_Parent_Module__c,
                                             'For BRSF, we meet following error in End Date: <br/>'))
            {
                msg+='<br/>';
                //msg= 'For BRSF, we meet following error in End Date: <br/>'+msg;
            }
        }
        else if (PH.ASI_CRM_CN_Last_Payment__c && PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            msg+= 'For BRSF, we meet following error in End Date: <br/> ';
            msg+= 'Please input the end date and refresh volumes .请输入结束日期并刷新销量。<br/>';
            UpsertPermission=false;
        }
        UpsertModuleList.add(BRSFItemMap.Module);
        
        
        
        if(DisplayVEC){// VariableEventCost.Module.Id != NULL && VariableEventCost.Module.Id !='' 
            ModuleChecking(VariableEventCost.Module,'Variable Event Cost');
            if(VariableEventCost.Module.ASI_CRM_End_Date__c!=null){
                if(!VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c,  VariableEventCost.Module.ASI_CRM_End_Date__c,VariableEventCost.Module.ASI_CRM_Parent_Module__c,
                                                 'For Variable Event Cost, we meet following error in End Date: <br/>'))
                {
                    msg+='<br/>';//msg= 'For Variable Event Cost, we meet following error in End Date: <br/>'+msg;
                }
            }
            else if (PH.ASI_CRM_CN_Last_Payment__c && PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                msg+= 'For Variable Event Cost, we meet following error in End Date: <br/> ';
                msg+= 'Please input the end date and refresh volumes .请输入结束日期并刷新销量。<br/>';
                UpsertPermission=false;
            }
            UpsertModuleList.add(VariableEventCost.Module);
        }
        
        
        for(String key:PSF_Item_Map.keySet()){//ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c
            ModuleChecking(PSF_Item_Map.get(key).Module,'PSF 空瓶回收服务费('+PSF_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+')');
            UpsertModuleList.add( PSF_Item_Map.get(key).Module);
            if(PSF_Item_Map.get(key).Module.ASI_CRM_End_Date__c!=null){
                if(!VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c,
                                                 PSF_Item_Map.get(key).Module.ASI_CRM_End_Date__c,
                                                 PSF_Item_Map.get(key).Module.ASI_CRM_Parent_Module__c,
                                                 'For PSF ('+PSF_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+'), we meet following error in End Date: '))
                {
                    msg+='<br/>';
                    // msg= 'For PSF ('+PSF_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+'), we meet following error in End Date: <br/>'+msg;
                }
            }
            else if (PH.ASI_CRM_CN_Last_Payment__c && PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                msg+= 'For PSF ('+PSF_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+'), we meet following error in End Date: ';
                msg+= 'Please input the end date and refresh volumes .请输入结束日期并刷新销量。<br/>';
                UpsertPermission=false;
            }
        }

        if (PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for(String key:Fixed_Item_Map.keySet()){//ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c
                ModuleChecking(Fixed_Item_Map.get(key).Module,'Fixed 固定成本('+Fixed_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+')');
                System.debug(LoggingLevel.INFO, '*** Fixed_Item_Map.get(key): ' + Fixed_Item_Map.get(key));
                UpsertModuleList.add( Fixed_Item_Map.get(key).Module);
                if(Fixed_Item_Map.get(key).Module.ASI_CRM_End_Date__c!=null){
                    if(!VolumeDateValidationChecking(PH.ASI_CRM_CN_PO_Start_Date__c,
                                                     Fixed_Item_Map.get(key).Module.ASI_CRM_End_Date__c,
                                                     Fixed_Item_Map.get(key).Module.ASI_CRM_Parent_Module__c,
                                                     'For Fixed ('+Fixed_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+'), we meet following error in End Date: '))
                    {
                        msg+='<br/>';
                        // msg= 'For PSF ('+Fixed_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+'), we meet following error in End Date: <br/>'+msg;
                    }
                }
                else if (PH.ASI_CRM_CN_Last_Payment__c) {
                    msg+= 'For Fixed ('+Fixed_Item_Map.get(key).Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c+'), we meet following error in End Date: ';
                    msg+= 'Please input the end date and refresh volumes .请输入结束日期并刷新销量。<br/>';
                    UpsertPermission=false;
                }
            }
        }
        
        
        //system.assertEquals(UpsertPermission, Null);
        
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        
        if(UpsertPermission){
            //Module
            try{
                if(UpsertModuleList.size()>0){
                    upsert UpsertModuleList;
                    UpsertPermission = true;
                }
            }catch(Exception e){
                msg += 'Save Error : ' +e.getMessage() + '</br>';
                pageRef = null;
                Database.rollback(pSavepoint);      
                UpsertPermission = false;
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_EditHeavyPaymentDetailCtrl class have Error  '+msg,'ASI_CRM_CN_EditHeavyPaymentDetailCtrl','Save function failed!');
                return null;
            }
            
            //upsert/Detele Payment Line
            if(UpsertPermission){
                pSavepoint = Database.setSavepoint();
                try{
                    if(PaymentLineDeleteList.size()>0){
                        DeleteTarget = Database.delete(PaymentLineDeleteList);
                        PaymentLineDeleteList.clear();
                    }
                    //Upsert Payment Line
                    if(UpsertBRSFList.size()>0){
                        UpsertTarget = Database.upsert(UpsertBRSFList);
                    }
                    
                    //update header 
                    if(PH.ASI_CRM_Total_Actual_Amount__c!=0){
                        update PH;
                    }
                    
                    
                    if (!isQuickSave){
                        pageRef = new PageReference('/'+PageId);
                        pageRef.setRedirect(true);
                    }else{
                        if (PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                            pageRef = new PageReference('/apex/ASI_CRM_CN_Edit_HeavyPR_Details2ndPage?id='+PageId);
                        } else {
                            pageRef = new PageReference('/apex/ASI_CRM_CN_Edit_HeavyPR_DetailsPage?id='+PageId);
                        }
                        pageRef.setRedirect(true);
                    }
                    
                }catch(Exception e){
                    msg += 'Save Error : ' +e.getMessage() + '</br>';
                    
                    pageRef = null;
                    Database.rollback(pSavepoint);      
                    UpsertPermission = false;
                    ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_EditHeavyPaymentDetailCtrl class have Error  '+msg,'ASI_CRM_CN_EditHeavyPaymentDetailCtrl','Save function!');
                    return null;
                }
            }
        }
        
        
        
        return pageRef; 
    }
    
    
    
    
    
    public List<ASI_TH_CRM_PaymentRequestLineItem__c>  ValdationChecking(){
        List<ASI_TH_CRM_PaymentRequestLineItem__c>  ReturnList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        Decimal TotalCTDPayableAmount=0.0;
        Decimal ApplicationPaymentAmount=0.0;
        Decimal CurrentPaymentAmount=0;
        //***********************************************BRSF Line***********************************************
        integer LineCount=0;
        BRSFItemMap.Module.ASI_CRM_Suggested_Payable_Amount__c=0;
        for(String key:BRSFItemMap.DetailLineMap.keySet()){
            
            LineCount++;
            ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine = BRSFItemMap.DetailLineMap.get(key);
            PaymentLine.ASI_CRM_CN_Incentive_BT__c= PaymentLine.ASI_CRM_CN_Incentive_BT__c!=NULL?PaymentLine.ASI_CRM_CN_Incentive_BT__c:0;
            
            if(PaymentLine.ASI_CRM_CN_Payable_Vol__c ==null){
                PaymentLine.ASI_CRM_CN_Payable_Vol__c=0;
            }
            If(PaymentLine.ASI_CRM_CN_Payable_Vol__c !=null && PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null  && PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=0 ){
                PaymentLine.ASI_CRM_CN_Completion_Rate__c=(PaymentLine.ASI_CRM_CN_Payable_Vol__c/PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c)*100;
            }
            if(PaymentLine.ASI_CRM_CN_Payable_Vol__c!=null && PaymentLine.ASI_CRM_CN_Incentive_BT__c!=null){
                PaymentLine.ASI_CRM_CN_Total_Payable__c = PaymentLine.ASI_CRM_CN_Incentive_BT__c * PaymentLine.ASI_CRM_CN_Payable_Vol__c;
            }
            TotalCTDPayableAmount += PaymentLine.ASI_CRM_CN_Total_Payable__c ;
            
            system.debug('Overpayment checking : Incentive_BT : ' +PaymentLine.ASI_CRM_CN_Incentive_BT__c  + ' Max Incentive : '+ PaymentLine.ASI_CRM_Max_Incentive__c );
            
            if(PaymentLine.ASI_CRM_CN_Allow_Changing_Incentive__c && PaymentLine.ASI_CRM_CN_Incentive_BT__c > PaymentLine.ASI_CRM_Max_Incentive__c ){
                BRSFItemMap.Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_Max_Incentive__c*PaymentLine.ASI_CRM_Suggested_Volume__c;
            }else{
                BRSFItemMap.Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_CN_Incentive_BT__c*PaymentLine.ASI_CRM_Suggested_Volume__c;
            }
            ReturnList.add(PaymentLine);
        }
        
        system.debug(' BRSF Suggested_Payable_Amount : '+BRSFItemMap.Module.ASI_CRM_Suggested_Payable_Amount__c );
        system.debug(' BRSF Actual_Payment : '+BRSFItemMap.Module.ASI_CRM_Actual_Payment__c);
        system.debug(' BRSF ASI_CRM_Historical_Paid_Amount__c : '+ BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c);
        
        if(LineCount>0){
            if (BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c == null){
                BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c = 0;
            }
            ApplicationPaymentAmount= TotalCTDPayableAmount-BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c;
            BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c=ApplicationPaymentAmount;
            if(ApplicationPaymentAmount !=0 && BRSFItemMap.Module.ASI_CRM_Actual_Payment__c!=null  ){
                BRSFItemMap.Module.ASI_CRM_Adjustment__c= (BRSFItemMap.Module.ASI_CRM_Actual_Payment__c/ApplicationPaymentAmount)*100;//BRSFItemMap.Module.ASI_CRM_Actual_Payment__c=  BRSFItemMap.Module.ASI_CRM_Adjustment__c ==null? ApplicationPaymentAmount: (BRSFItemMap.Module.ASI_CRM_Adjustment__c * ApplicationPaymentAmount)/100;
            }else{
                BRSFItemMap.Module.ASI_CRM_Adjustment__c=100;
            }
        }else{
            BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c=0;
            BRSFItemMap.Module.ASI_CRM_Actual_Payment__c=0;
            BRSFItemMap.Module.ASI_CRM_End_Date__c=null;
            BRSFItemMap.Module.ASI_CRM_Adjustment__c=100;
            BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c = 0;
        }

        PH.ASI_CRM_Total_Actual_Amount__c += BRSFItemMap.Module.ASI_CRM_Actual_Payment__c!=null? BRSFItemMap.Module.ASI_CRM_Actual_Payment__c:0 ;
        PH.ASI_CRM_Total_Variable_Amount__c  += BRSFItemMap.Module.ASI_CRM_Actual_Payment__c!=null? BRSFItemMap.Module.ASI_CRM_Actual_Payment__c:0 ;
        CurrentPaymentAmount=BRSFItemMap.Module.ASI_CRM_Actual_Payment__c +BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c;     
        if(LineCount>0 && CurrentPaymentAmount> BRSFItemMap.Module.ASI_CRM_Suggested_Payable_Amount__c){
            if(BRSFItemMap.Module.ASI_CRM_Overpayment_Reason__c ==null){//Plesae input the reason for overpayment.
                ErrorHandling('BRSF: '+Label.ASI_CRM_Input_reason_for_overpayment);  //ErrorHandling('BRSF: Current Payable Amount ('+ASI_CRM_CN_HeavyContractUtilitiesClass.FormatNumber(CurrentPaymentAmount) +') is over Suggested Payable Amount ('+ASI_CRM_CN_HeavyContractUtilitiesClass.FormatNumber(BRSFItemMap.Module.ASI_CRM_Suggested_Payable_Amount__c) +'). Please select Overpayment Reason.Thanks.  ');
            }else if(BRSFItemMap.Module.ASI_CRM_Overpayment_Reason__c =='其他－需填写具体原因' && BRSFItemMap.Module.ASI_CRM_Other_Comments__c==null ){
                ErrorHandling('BRSF: '+Label.ASI_CRM_CN_Please_input_other_reason);
            }
        }
        
        
        
        //**********************************************PSF**********************************************
        for(String key:PSF_Item_Map.keySet()){
            TotalCTDPayableAmount=0.0;
            ApplicationPaymentAmount=0.0;
            CurrentPaymentAmount=0;
            LineCount=0;
            //Looping the PSF Line
            PSF_Item_Map.get(key).TotalIntake_Btl=0;
            PSF_Item_Map.get(key).TotalBC_Btl=0;
            PSF_Item_Map.get(key).TotalIntake_Completion=0;
            PSF_Item_Map.get(key).TotalBC_Completion=0; 
            PSF_Item_Map.get(key).VolumeTarget=0;
            
            
            if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                PSF_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c= 0; 
            }
            
            // Loop every Module
            for(String keyline:PSF_Item_Map.get(key).DetailLineMap.keySet()){
                LineCount++;
                ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine = PSF_Item_Map.get(key).DetailLineMap.get(keyline);
                if(PaymentLine.ASI_CRM_CN_Payable_Vol__c ==null){
                    PaymentLine.ASI_CRM_CN_Payable_Vol__c=0;
                }
                if(PaymentLine.ASI_CRM_CN_Total_Payable__c==null){
                    PaymentLine.ASI_CRM_CN_Total_Payable__c=0;
                }
                
                if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    PaymentLine.ASI_CRM_CN_Incentive_BT__c= PaymentLine.ASI_CRM_CN_Incentive_BT__c !=null? PaymentLine.ASI_CRM_CN_Incentive_BT__c:0;
                    
                    if(PaymentLine.ASI_CRM_CN_Payable_Vol__c!=null && PaymentLine.ASI_CRM_CN_Incentive_BT__c!=null){
                        PaymentLine.ASI_CRM_CN_Total_Payable__c = PaymentLine.ASI_CRM_CN_Incentive_BT__c * PaymentLine.ASI_CRM_CN_Payable_Vol__c;
                    }else{
                        PaymentLine.ASI_CRM_CN_Total_Payable__c=0;
                        PaymentLine.ASI_CRM_CN_Incentive_BT__c=PaymentLine.ASI_CRM_CN_Incentive_BT__c!=null?PaymentLine.ASI_CRM_CN_Incentive_BT__c:0;
                        PaymentLine.ASI_CRM_CN_Payable_Vol__c=PaymentLine.ASI_CRM_CN_Payable_Vol__c!=null?PaymentLine.ASI_CRM_CN_Payable_Vol__c:0; 
                    }
                    
                    if(PaymentLine.ASI_CRM_CN_Allow_Changing_Incentive__c && PaymentLine.ASI_CRM_CN_Incentive_BT__c>PaymentLine.ASI_CRM_Max_Incentive__c){
                        PSF_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_Max_Incentive__c*PaymentLine.ASI_CRM_Suggested_Volume__c;
                    }else{
                        PSF_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_CN_Incentive_BT__c*PaymentLine.ASI_CRM_Suggested_Volume__c;
                    }
                    
                    
                }
                If(PaymentLine.ASI_CRM_CN_Payable_Vol__c !=null && PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null  && PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=0 ){
                    PaymentLine.ASI_CRM_CN_Completion_Rate__c=(PaymentLine.ASI_CRM_CN_Payable_Vol__c/PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c)*100;
                }
                
                TotalCTDPayableAmount += PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0 ;
                
                Boolean AllowCalculation=false;
                if(PaymentLine.ASI_CRM_Non_Contract_Line__c ){
                    if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                        if(PaymentLine.ASI_CRM_CN_Payable_Vol__c!=0){
                            AllowCalculation=true;
                        } 
                    }else{
                        if(PaymentLine.ASI_CRM_CN_Total_Payable__c!=0){
                            AllowCalculation=true;
                        }  
                    }
                }
                if(!PaymentLine.ASI_CRM_Non_Contract_Line__c || AllowCalculation){
                    PSF_Item_Map.get(key).TotalIntake_Btl+=PaymentLine.ASI_CRM_CN_Actual_Vol__c!=null?PaymentLine.ASI_CRM_CN_Actual_Vol__c:0;
                    PSF_Item_Map.get(key).TotalBC_Btl+=PaymentLine.ASI_CRM_CN_Bottle_Collected__c!=null?PaymentLine.ASI_CRM_CN_Bottle_Collected__c:0;
                    PSF_Item_Map.get(key).TotalIntake_Completion+=PaymentLine.ASI_CRM_CTD_Actual_Vol__c!=null?PaymentLine.ASI_CRM_CTD_Actual_Vol__c:0;
                    PSF_Item_Map.get(key).TotalBC_Completion+=PaymentLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?PaymentLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                }
                PSF_Item_Map.get(key).VolumeTarget +=PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                
                
                ReturnList.add(PaymentLine);
            }
            
            if(LineCount>0){
                ApplicationPaymentAmount= TotalCTDPayableAmount-PSF_Item_Map.get(key).Module.ASI_CRM_Historical_Paid_Amount__c;
                PSF_Item_Map.get(key).Module.ASI_CRM_Application_Payment_Amount__c=ApplicationPaymentAmount;
                
                //PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c=  PSF_Item_Map.get(key).Module.ASI_CRM_Adjustment__c ==null? ApplicationPaymentAmount: (PSF_Item_Map.get(key).Module.ASI_CRM_Adjustment__c * ApplicationPaymentAmount)/100;
                if(ApplicationPaymentAmount !=0 ){
                    PSF_Item_Map.get(key).Module.ASI_CRM_Adjustment__c= (PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c/ApplicationPaymentAmount)*100;
                }else{
                    PSF_Item_Map.get(key).Module.ASI_CRM_Adjustment__c=100;
                }
                
                PH.ASI_CRM_Total_Actual_Amount__c += PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c!=null? PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c:0 ;
                PH.ASI_CRM_Total_Variable_Amount__c+= PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c!=null? PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c:0 ;
                CurrentPaymentAmount=PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c +PSF_Item_Map.get(key).Module.ASI_CRM_Historical_Paid_Amount__c;     
            }else{
                PSF_Item_Map.get(key).Module.ASI_CRM_Application_Payment_Amount__c=0;
                PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c=0;
                PSF_Item_Map.get(key).Module.ASI_CRM_End_Date__c=null;
            }
            
            if(LineCount>0 && CurrentPaymentAmount> PSF_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c){
                IF(PSF_Item_Map.get(key).Module.ASI_CRM_PSF_Overpayment_Reason__c ==null){
                    ErrorHandling('PSF: ('+PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c+') :'+Label.ASI_CRM_Input_reason_for_overpayment);
                }else if(PSF_Item_Map.get(key).Module.ASI_CRM_PSF_Overpayment_Reason__c =='其他－需填写具体原因' && PSF_Item_Map.get(key).Module.ASI_CRM_Other_Comments__c==null){
                    ErrorHandling('PSF: ('+PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c+') :'+Label.ASI_CRM_CN_Please_input_other_reason); //ErrorHandling('PSF: ('+PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c+') Current Payable Amount ('+ASI_CRM_CN_HeavyContractUtilitiesClass.FormatNumber(CurrentPaymentAmount) +') is over Suggested Payable Amount ('+ASI_CRM_CN_HeavyContractUtilitiesClass.FormatNumber(PSF_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c) +'). Please select Overpayment Reason.Thanks. ');
                }
            }
            PSF_Item_Map.get(key).RealVolume=MethodologyRoute(PSF_Item_Map.get(key).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                              PSF_Item_Map.get(key).TotalIntake_Completion,
                                                              PSF_Item_Map.get(key).TotalBC_Completion,
                                                              CalculateBCRate(PSF_Item_Map.get(key).TotalIntake_Btl,PSF_Item_Map.get(key).TotalBC_Btl),false);
            if(PSF_Item_Map.get(key).VolumeTarget!=null && PSF_Item_Map.get(key).VolumeTarget !=0 && PSF_Item_Map.get(key).RealVolume!=null){
                PSF_Item_Map.get(key).Module.ASI_CRM_Completion_Ratio__c  =(PSF_Item_Map.get(key).RealVolume/PSF_Item_Map.get(key).VolumeTarget)*100;
            }
            
            
        }
        
        
        //**********************************************Variable Event Cost**********************************************
        TotalCTDPayableAmount=0.0;
        CurrentPaymentAmount=0;
        ApplicationPaymentAmount=0.0;
        LineCount=0;
        VariableEventCost.TotalIntake_Btl=0;
        VariableEventCost.TotalBC_Btl=0;
        VariableEventCost.TotalIntake_Completion=0;
        VariableEventCost.TotalBC_Completion=0; 
        VariableEventCost.VolumeTarget=0;
        
        
        
        for(String key:VariableEventCost.DetailLineMap.keySet()){
            LineCount++;
            ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine = VariableEventCost.DetailLineMap.get(key);
            if(PaymentLine.ASI_CRM_CN_Payable_Vol__c ==null){
                PaymentLine.ASI_CRM_CN_Payable_Vol__c=0;
            }
            if(PaymentLine.ASI_CRM_CN_Total_Payable__c==null){
                PaymentLine.ASI_CRM_CN_Total_Payable__c=0;
            }
            
            if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                if(PaymentLine.ASI_CRM_CN_Payable_Vol__c!=null && PaymentLine.ASI_CRM_CN_Incentive_BT__c!=null){
                    PaymentLine.ASI_CRM_CN_Total_Payable__c = PaymentLine.ASI_CRM_CN_Incentive_BT__c * PaymentLine.ASI_CRM_CN_Payable_Vol__c;
                }else{
                    PaymentLine.ASI_CRM_CN_Total_Payable__c =0;
                    PaymentLine.ASI_CRM_CN_Incentive_BT__c=PaymentLine.ASI_CRM_CN_Incentive_BT__c!=null?PaymentLine.ASI_CRM_CN_Incentive_BT__c:0;
                    PaymentLine.ASI_CRM_CN_Payable_Vol__c=PaymentLine.ASI_CRM_CN_Payable_Vol__c!=null?PaymentLine.ASI_CRM_CN_Payable_Vol__c:0; 
                }                
            }
            If(PaymentLine.ASI_CRM_CN_Payable_Vol__c !=null && PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null  && PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=0 ){
                PaymentLine.ASI_CRM_CN_Completion_Rate__c=(PaymentLine.ASI_CRM_CN_Payable_Vol__c/PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c)*100;
            }
            TotalCTDPayableAmount += PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0 ;
            
            Boolean AllowCalculation=false;
            if(PaymentLine.ASI_CRM_Non_Contract_Line__c ){
                if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    if(PaymentLine.ASI_CRM_CN_Payable_Vol__c!=0){
                        AllowCalculation=true;
                    } 
                }else{
                    if(PaymentLine.ASI_CRM_CN_Total_Payable__c!=0){
                        AllowCalculation=true;
                    }  
                }
            }
            if(!PaymentLine.ASI_CRM_Non_Contract_Line__c || AllowCalculation){
                VariableEventCost.TotalIntake_Btl+=PaymentLine.ASI_CRM_CN_Actual_Vol__c!=null?PaymentLine.ASI_CRM_CN_Actual_Vol__c:0;
                VariableEventCost.TotalBC_Btl+=PaymentLine.ASI_CRM_CN_Bottle_Collected__c!=null?PaymentLine.ASI_CRM_CN_Bottle_Collected__c:0;
                VariableEventCost.TotalIntake_Completion+=PaymentLine.ASI_CRM_CTD_Actual_Vol__c!=null?PaymentLine.ASI_CRM_CTD_Actual_Vol__c:0;
                VariableEventCost.TotalBC_Completion+=PaymentLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?PaymentLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
            }
            VariableEventCost.VolumeTarget +=PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
            
            ReturnList.add(PaymentLine);
        }
        
        
        
        if(LineCount>0){
            ApplicationPaymentAmount= TotalCTDPayableAmount-VariableEventCost.Module.ASI_CRM_Historical_Paid_Amount__c;
            VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c=ApplicationPaymentAmount;
           
            //VariableEventCost.Module.ASI_CRM_Actual_Payment__c=  VariableEventCost.Module.ASI_CRM_Adjustment__c ==null? ApplicationPaymentAmount: (VariableEventCost.Module.ASI_CRM_Adjustment__c * ApplicationPaymentAmount)/100;
            if(ApplicationPaymentAmount !=0 ){
                VariableEventCost.Module.ASI_CRM_Adjustment__c= (VariableEventCost.Module.ASI_CRM_Actual_Payment__c/ApplicationPaymentAmount)*100;
            }else{
                VariableEventCost.Module.ASI_CRM_Adjustment__c=100;
            }
            
            PH.ASI_CRM_Total_Actual_Amount__c += VariableEventCost.Module.ASI_CRM_Actual_Payment__c!=null? VariableEventCost.Module.ASI_CRM_Actual_Payment__c:0 ;
            PH.ASI_CRM_Total_Variable_Amount__c += VariableEventCost.Module.ASI_CRM_Actual_Payment__c!=null? VariableEventCost.Module.ASI_CRM_Actual_Payment__c:0 ;
        }else{
            VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c=0;
            VariableEventCost.Module.ASI_CRM_Actual_Payment__c=0;
            VariableEventCost.Module.ASI_CRM_End_Date__c=null;
        }
        
        CurrentPaymentAmount+=VariableEventCost.Module.ASI_CRM_Actual_Payment__c!=null?VariableEventCost.Module.ASI_CRM_Actual_Payment__c:0;
        CurrentPaymentAmount+=VariableEventCost.Module.ASI_CRM_Historical_Paid_Amount__c!=null?VariableEventCost.Module.ASI_CRM_Historical_Paid_Amount__c:0;     
        if(LineCount>0 &&   CurrentPaymentAmount> VariableEventCost.Module.ASI_CRM_Suggested_Payable_Amount__c){
            if(VariableEventCost.Module.ASI_CRM_VEC_Overpayment_Reason__c ==null){
                ErrorHandling('VEC:'+Label.ASI_CRM_Input_reason_for_overpayment);
            }else if(VariableEventCost.Module.ASI_CRM_VEC_Overpayment_Reason__c =='其他－需填写具体原因' && VariableEventCost.Module.ASI_CRM_Other_Comments__c==null){
                ErrorHandling('VEC:'+Label.ASI_CRM_CN_Please_input_other_reason);
            }//ErrorHandling('VEC : Current Payable Amount ('+ASI_CRM_CN_HeavyContractUtilitiesClass.FormatNumber(CurrentPaymentAmount) +') is over Suggested Payable Amount ('+ASI_CRM_CN_HeavyContractUtilitiesClass.FormatNumber(VariableEventCost.Module.ASI_CRM_Suggested_Payable_Amount__c) +'). Please select Overpayment Reason.Thanks. ');
        }
        
        //***********************************************Other Payment Line List***********************************************
        if (PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for(String key:Fixed_Item_Map.keySet()){
                TotalCTDPayableAmount=0.0;
                ApplicationPaymentAmount=0.0;
                CurrentPaymentAmount=0;
                LineCount=0;
                //Looping the PSF Line
                Fixed_Item_Map.get(key).TotalIntake_Btl=0;
                Fixed_Item_Map.get(key).TotalBC_Btl=0;
                Fixed_Item_Map.get(key).TotalIntake_Completion=0;
                Fixed_Item_Map.get(key).TotalBC_Completion=0; 
                Fixed_Item_Map.get(key).VolumeTarget=0;
                
                
                if(Fixed_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    Fixed_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c= 0; 
                }
                
                // Loop every Module
                for(String keyline:Fixed_Item_Map.get(key).DetailLineMap.keySet()){
                    LineCount++;
                    ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine = Fixed_Item_Map.get(key).DetailLineMap.get(keyline);
                    if(PaymentLine.ASI_CRM_CN_Payable_Vol__c ==null){
                        PaymentLine.ASI_CRM_CN_Payable_Vol__c=0;
                    }
                    if(PaymentLine.ASI_CRM_CN_Total_Payable__c==null){
                        PaymentLine.ASI_CRM_CN_Total_Payable__c=0;
                    }
                    
                    if(Fixed_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                        PaymentLine.ASI_CRM_CN_Incentive_BT__c= PaymentLine.ASI_CRM_CN_Incentive_BT__c !=null? PaymentLine.ASI_CRM_CN_Incentive_BT__c:0;
                        
                        if(PaymentLine.ASI_CRM_CN_Payable_Vol__c!=null && PaymentLine.ASI_CRM_CN_Incentive_BT__c!=null){
                            PaymentLine.ASI_CRM_CN_Total_Payable__c = PaymentLine.ASI_CRM_CN_Incentive_BT__c * PaymentLine.ASI_CRM_CN_Payable_Vol__c;
                        }else{
                            PaymentLine.ASI_CRM_CN_Total_Payable__c=0;
                            PaymentLine.ASI_CRM_CN_Incentive_BT__c=PaymentLine.ASI_CRM_CN_Incentive_BT__c!=null?PaymentLine.ASI_CRM_CN_Incentive_BT__c:0;
                            PaymentLine.ASI_CRM_CN_Payable_Vol__c=PaymentLine.ASI_CRM_CN_Payable_Vol__c!=null?PaymentLine.ASI_CRM_CN_Payable_Vol__c:0; 
                        }
                        
                        if(PaymentLine.ASI_CRM_CN_Allow_Changing_Incentive__c && PaymentLine.ASI_CRM_CN_Incentive_BT__c>PaymentLine.ASI_CRM_Max_Incentive__c){
                            Fixed_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_Max_Incentive__c*PaymentLine.ASI_CRM_Suggested_Volume__c;
                        }else{
                            Fixed_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c += PaymentLine.ASI_CRM_CN_Incentive_BT__c*PaymentLine.ASI_CRM_Suggested_Volume__c;
                        }
                        
                        
                    }
                    If(PaymentLine.ASI_CRM_CN_Payable_Vol__c !=null && PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null  && PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=0 ){
                        PaymentLine.ASI_CRM_CN_Completion_Rate__c=(PaymentLine.ASI_CRM_CN_Payable_Vol__c/PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c)*100;
                    }
                    
                    TotalCTDPayableAmount += PaymentLine.ASI_CRM_CN_Total_Payable__c!=null? PaymentLine.ASI_CRM_CN_Total_Payable__c:0 ;
                    
                    Boolean AllowCalculation=false;
                    if(PaymentLine.ASI_CRM_Non_Contract_Line__c ){
                        if(Fixed_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                            if(PaymentLine.ASI_CRM_CN_Payable_Vol__c!=0){
                                AllowCalculation=true;
                            } 
                        }else{
                            if(PaymentLine.ASI_CRM_CN_Total_Payable__c!=0){
                                AllowCalculation=true;
                            }  
                        }
                    }
                    if(!PaymentLine.ASI_CRM_Non_Contract_Line__c || AllowCalculation){
                        Fixed_Item_Map.get(key).TotalIntake_Btl+=PaymentLine.ASI_CRM_CN_Actual_Vol__c!=null?PaymentLine.ASI_CRM_CN_Actual_Vol__c:0;
                        Fixed_Item_Map.get(key).TotalBC_Btl+=PaymentLine.ASI_CRM_CN_Bottle_Collected__c!=null?PaymentLine.ASI_CRM_CN_Bottle_Collected__c:0;
                        Fixed_Item_Map.get(key).TotalIntake_Completion+=PaymentLine.ASI_CRM_CTD_Actual_Vol__c!=null?PaymentLine.ASI_CRM_CTD_Actual_Vol__c:0;
                        Fixed_Item_Map.get(key).TotalBC_Completion+=PaymentLine.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?PaymentLine.ASI_CRM_CTD_Cap_Collection_Vol__c:0; 
                    }
                    Fixed_Item_Map.get(key).VolumeTarget +=PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c!=null?PaymentLine.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                    
                    
                    ReturnList.add(PaymentLine);
                }
                
                if(LineCount>0){
                    ApplicationPaymentAmount= TotalCTDPayableAmount-Fixed_Item_Map.get(key).Module.ASI_CRM_Historical_Paid_Amount__c;
                    Fixed_Item_Map.get(key).Module.ASI_CRM_Application_Payment_Amount__c=ApplicationPaymentAmount;
                    
                    //Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c=  Fixed_Item_Map.get(key).Module.ASI_CRM_Adjustment__c ==null? ApplicationPaymentAmount: (Fixed_Item_Map.get(key).Module.ASI_CRM_Adjustment__c * ApplicationPaymentAmount)/100;
                    if(ApplicationPaymentAmount !=0 ){
                        Fixed_Item_Map.get(key).Module.ASI_CRM_Adjustment__c= (Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c/ApplicationPaymentAmount)*100;
                    }else{
                        Fixed_Item_Map.get(key).Module.ASI_CRM_Adjustment__c=100;
                    }
                    
                    PH.ASI_CRM_Total_Actual_Amount__c += Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c!=null? Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c:0 ;
                    // PH.ASI_CRM_Total_Variable_Amount__c+= Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c!=null? Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c:0 ;
                    CurrentPaymentAmount=Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c +Fixed_Item_Map.get(key).Module.ASI_CRM_Historical_Paid_Amount__c;     
                }else{
                    Fixed_Item_Map.get(key).Module.ASI_CRM_Application_Payment_Amount__c=0;
                    Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c=0;
                    Fixed_Item_Map.get(key).Module.ASI_CRM_End_Date__c=null;
                }
                System.debug('Fixed'+Fixed_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c);
                if(LineCount>0 && CurrentPaymentAmount> Fixed_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c){
                    IF(Fixed_Item_Map.get(key).Module.ASI_CRM_Fixedcost_Overpayment_Reason__c ==null){
                        ErrorHandling('Fixed: ('+Fixed_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c+') :'+Label.ASI_CRM_Input_reason_for_overpayment);
                    }else if(Fixed_Item_Map.get(key).Module.ASI_CRM_Fixedcost_Overpayment_Reason__c =='其他－需填写具体原因' && Fixed_Item_Map.get(key).Module.ASI_CRM_Other_Comments__c==null){
                        ErrorHandling('Fixed: ('+Fixed_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c+') :'+Label.ASI_CRM_CN_Please_input_other_reason); //ErrorHandling('PSF: ('+Fixed_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c+') Current Payable Amount ('+ASI_CRM_CN_HeavyContractUtilitiesClass.FormatNumber(CurrentPaymentAmount) +') is over Suggested Payable Amount ('+ASI_CRM_CN_HeavyContractUtilitiesClass.FormatNumber(Fixed_Item_Map.get(key).Module.ASI_CRM_Suggested_Payable_Amount__c) +'). Please select Overpayment Reason.Thanks. ');
                    }
                }
                Fixed_Item_Map.get(key).RealVolume=MethodologyRoute(Fixed_Item_Map.get(key).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                  Fixed_Item_Map.get(key).TotalIntake_Completion,
                                                                  Fixed_Item_Map.get(key).TotalBC_Completion,
                                                                  CalculateBCRate(Fixed_Item_Map.get(key).TotalIntake_Btl,Fixed_Item_Map.get(key).TotalBC_Btl),false);
                if(Fixed_Item_Map.get(key).VolumeTarget!=null && Fixed_Item_Map.get(key).VolumeTarget !=0 && Fixed_Item_Map.get(key).RealVolume!=null){
                    Fixed_Item_Map.get(key).Module.ASI_CRM_Completion_Ratio__c  =(Fixed_Item_Map.get(key).RealVolume/Fixed_Item_Map.get(key).VolumeTarget)*100;
                }
                
                
            }
        }

        if (!PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine:OtherPaymentLineList){
                if(PaymentLine.ASI_TH_CRM_Amount__c==null){
                    PaymentLine.ASI_TH_CRM_Amount__c=0;
                }
                PH.ASI_CRM_Total_Actual_Amount__c += PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0 ;
                ReturnList.add(PaymentLine);
                
            }
        }
        
        if (PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            ASI_TH_CRM_Contract__c ContractSelected = [SELECT Id,Name ,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c, ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c,
                                ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,
                                ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c ,   ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                                recordtypeid, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, createddate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, lastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,
                                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c, ASI_CRM_Investment_Type__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_CRM_CN_Fixed_Module_Est_Amount1__c,ASI_CRM_CN_Fixed_Module_Est_Amount2__c

                                FROM ASI_TH_CRM_Contract__c
                                WHERE id =:PH.ASI_TH_CRM_Contract__c ];
            PaymentSummaryList = ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(PH,ContractSelected);
            Decimal poTotalAmount = 0;
            for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary ap : PaymentSummaryList){
                poTotalAmount += ap.POEstimatedAmount;
            }
            
            //Total Amount checking 
            if(PH.ASI_CRM_Total_Actual_Amount__c>poTotalAmount){
                String tempStr = Label.ASI_CRM_Payee_Amount_checking;
                List<String> fillers = new String[] {PH.ASI_CRM_Total_Actual_Amount__c.format() ,poTotalAmount.format()};
                    ErrorHandling(String.format(tempStr,fillers));//付款金额>PO金额！付款金额：{0}  PO金额：{1} //ErrorHandling('付款金额>PO金额！付款金额：'+PH.ASI_CRM_Total_Actual_Amount__c.format()+'  PO金额：'+PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c.format());
            }
        } else {
            //Total Amount checking 
            if(PH.ASI_CRM_Total_Actual_Amount__c>PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c){
                String tempStr = Label.ASI_CRM_Payee_Amount_checking;
                List<String> fillers = new String[] {PH.ASI_CRM_Total_Actual_Amount__c.format() ,PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c.format()};
                    ErrorHandling(String.format(tempStr,fillers));//付款金额>PO金额！付款金额：{0}  PO金额：{1} //ErrorHandling('付款金额>PO金额！付款金额：'+PH.ASI_CRM_Total_Actual_Amount__c.format()+'  PO金额：'+PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c.format());
            }
        }
        
        
        RefreshAllData();
        return ReturnList;
    }
    
    
    
    
    
    
        
    
    
    //refresh BRSF/ PSF/ VEC Payment Line
    private void RefreshPaymentLine(){ 
        //*************Looping BRSF *******************
        Decimal TotalCTDPayableAmount=0.0;
        integer LineCount=0;
        Decimal ApplicationPaymentAmount=0.0;
        for(String key:BRSFItemMap.DetailLineMap.keySet()){
            LineCount++;
            BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c = BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c!=NULL?BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c:0;
            if(BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c ==null){
                BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c=0;
            }
            If(BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c !=null && BRSFItemMap.DetailLineMap.get(key).ASI_CRM_V0_0_Full_Contract_Target__c!=null  && BRSFItemMap.DetailLineMap.get(key).ASI_CRM_V0_0_Full_Contract_Target__c!=0 ){
                BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Completion_Rate__c=(BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c/BRSFItemMap.DetailLineMap.get(key).ASI_CRM_V0_0_Full_Contract_Target__c)*100;
            }
            
            
            if(BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c!=null && BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c!=null){
                BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c = BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c * BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c;
            }
            TotalCTDPayableAmount += BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c ;
        }
        
        if(LineCount>0){
            if (BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c == null){
                BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c = 0;
            }
            ApplicationPaymentAmount= TotalCTDPayableAmount-BRSFItemMap.Module.ASI_CRM_Historical_Paid_Amount__c;
            system.debug('ApplicationPaymentAmount : '+ApplicationPaymentAmount);
            BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c=ApplicationPaymentAmount;
            if(ApplicationPaymentAmount !=0 ){
                BRSFItemMap.Module.ASI_CRM_Adjustment__c= (BRSFItemMap.Module.ASI_CRM_Actual_Payment__c/ApplicationPaymentAmount)*100;
            }else{
                BRSFItemMap.Module.ASI_CRM_Adjustment__c=100;
            }
        }else{
            BRSFItemMap.Module.ASI_CRM_Application_Payment_Amount__c=0;
            BRSFItemMap.Module.ASI_CRM_Actual_Payment__c=0;
            BRSFItemMap.Module.ASI_CRM_Adjustment__c=100;
        }
        
        
        
        //***************Looping PSF *******************
        for(String key:PSF_Item_Map.keySet()){
            TotalCTDPayableAmount=0.0;
             LineCount=0;
            // Loop every Module
            for(String keyline:PSF_Item_Map.get(key).DetailLineMap.keySet()){
                LineCount++;
                if(PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c ==null){
                    PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c=0;
                }
                if(PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c==null){
                    PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c=0;
                }
                if(PSF_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c !=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c:0;
                    if(PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c!=null && PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c!=null){
                        PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c = PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c * PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c;
                    }else{
                        PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c=0;
                        PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c=PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c!=null?PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c:0;
                        PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c=PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c!=null?PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c:0; 
                    }
                }
                TotalCTDPayableAmount += PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c:0 ;
                
                If(PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c !=null && PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_V0_0_Full_Contract_Target__c!=null  && PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_V0_0_Full_Contract_Target__c!=0 ){
                    PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Completion_Rate__c=(PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c/PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_V0_0_Full_Contract_Target__c)*100;
                }
            }
            if(LineCount>0){
                ApplicationPaymentAmount= TotalCTDPayableAmount-PSF_Item_Map.get(key).Module.ASI_CRM_Historical_Paid_Amount__c;
                PSF_Item_Map.get(key).Module.ASI_CRM_Application_Payment_Amount__c=ApplicationPaymentAmount;
                if(ApplicationPaymentAmount !=0 ){
                    PSF_Item_Map.get(key).Module.ASI_CRM_Adjustment__c= (PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c/ApplicationPaymentAmount)*100;
                }else{
                    PSF_Item_Map.get(key).Module.ASI_CRM_Adjustment__c=100;
                }
            }else{
                PSF_Item_Map.get(key).Module.ASI_CRM_Application_Payment_Amount__c=0;
                PSF_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c=0;
            }
            
        }

        //***************Looping FIXED *******************
        if (ph.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for(String key:Fixed_Item_Map.keySet()){
            TotalCTDPayableAmount=0.0;
            LineCount=0;
              // Loop every Module
              for(String keyline:Fixed_Item_Map.get(key).DetailLineMap.keySet()){
                  LineCount++;
                  if(Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c ==null){
                      Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c=0;
                  }
                  if(Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c==null){
                      Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c=0;
                  }
                  if(Fixed_Item_Map.get(key).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                      Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c= Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c !=null? Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c:0;
                      if(Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c!=null && Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c!=null){
                          Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c = Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c * Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c;
                      }else{
                          Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c=0;
                          Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c=Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c!=null?Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c:0;
                          Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c=Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c!=null?Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c:0; 
                      }
                  }
          TotalCTDPayableAmount += Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c!=null? Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c:0 ;
                  
                  If(Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c !=null && Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_V0_0_Full_Contract_Target__c!=null  && Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_V0_0_Full_Contract_Target__c!=0 ){
                      Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Completion_Rate__c=(Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c/Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_V0_0_Full_Contract_Target__c)*100;
                  }
              }
            if(LineCount>0){
                      ApplicationPaymentAmount= TotalCTDPayableAmount-Fixed_Item_Map.get(key).Module.ASI_CRM_Historical_Paid_Amount__c;
                      Fixed_Item_Map.get(key).Module.ASI_CRM_Application_Payment_Amount__c=ApplicationPaymentAmount;
                      if(ApplicationPaymentAmount !=0 ){
                          Fixed_Item_Map.get(key).Module.ASI_CRM_Adjustment__c= (Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c/ApplicationPaymentAmount)*100;
                      }else{
                          Fixed_Item_Map.get(key).Module.ASI_CRM_Adjustment__c=100;
                      }
                  }else{
                      Fixed_Item_Map.get(key).Module.ASI_CRM_Application_Payment_Amount__c=0;
                      Fixed_Item_Map.get(key).Module.ASI_CRM_Actual_Payment__c=0;
                  }
        
          }
        }
        
        
        //***************Looping VEC *******************
        TotalCTDPayableAmount=0.0;
        LineCount=0;
        for(String key:VariableEventCost.DetailLineMap.keySet()){
            LineCount++;
            if(VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c ==null){
                VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c=0;
            }
            if(VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c==null){
                VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c=0;
            }
            
            if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                if(VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c!=null && VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c!=null){
                    VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c = VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c * VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c;
                }else{
                    VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c =0;
                    VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c=VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c!=null?VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c:0;
                    VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c=VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c!=null?VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c:0; 
                }                
            }
            If(VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c !=null && VariableEventCost.DetailLineMap.get(key).ASI_CRM_V0_0_Full_Contract_Target__c!=null  && VariableEventCost.DetailLineMap.get(key).ASI_CRM_V0_0_Full_Contract_Target__c!=0 ){
                VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Completion_Rate__c=(VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c/VariableEventCost.DetailLineMap.get(key).ASI_CRM_V0_0_Full_Contract_Target__c)*100;
            }
             TotalCTDPayableAmount += VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c!=null? VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c:0 ;
            
        }
         if(LineCount>0){
            ApplicationPaymentAmount= TotalCTDPayableAmount-VariableEventCost.Module.ASI_CRM_Historical_Paid_Amount__c;
            VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c=ApplicationPaymentAmount;
           
            //VariableEventCost.Module.ASI_CRM_Actual_Payment__c=  VariableEventCost.Module.ASI_CRM_Adjustment__c ==null? ApplicationPaymentAmount: (VariableEventCost.Module.ASI_CRM_Adjustment__c * ApplicationPaymentAmount)/100;
            if(ApplicationPaymentAmount !=0 ){
                VariableEventCost.Module.ASI_CRM_Adjustment__c= (VariableEventCost.Module.ASI_CRM_Actual_Payment__c/ApplicationPaymentAmount)*100;
            }else{
                VariableEventCost.Module.ASI_CRM_Adjustment__c=100;
            }
        }else{
            VariableEventCost.Module.ASI_CRM_Application_Payment_Amount__c=0;
            VariableEventCost.Module.ASI_CRM_Actual_Payment__c=0;
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public PageReference CancelProcess(){ 
        PageReference pageRef = null;
        
        UpsertPermission = true;
        pageRef = new PageReference('/'+PageId);
        pageRef.setRedirect(true);
        return pageRef; 
    }
    
    
    
    
    public void RefreshAllData(){
        
        for(String key:BRSFItemMap.DetailLineMap.keySet()){
            if(BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Allow_Changing_Incentive__c){
                if(BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c!=null && BRSFItemMap.DetailLineMap.get(key).ASI_CRM_Max_Incentive__c!=null){
                    if(BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c>BRSFItemMap.DetailLineMap.get(key).ASI_CRM_Max_Incentive__c){
                        BRSFItemMap.DetailLineMap.get(key).ASI_CRM_Over_Incentive__c=true;
                    }
                }
            }
            BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c=  BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c!=null? BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c:0;
            BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c=  BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c!=null? BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c:0;
            BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c=  BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c!=null? BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c:0;
            
        }
        for(String key:PSF_Item_Map.keySet()){
            for(String keyline:PSF_Item_Map.get(key).DetailLineMap.keySet()){
                if(PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Allow_Changing_Incentive__c){
                    if(PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c!=null && PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Max_Incentive__c!=null){
                        if(PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c>PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Max_Incentive__c){
                            PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Over_Incentive__c=true;
                        }
                    }
                }
                PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c=  PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c:0;
                PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c=  PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c:0;
                PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c=  PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c:0;
            }
        }
        if (PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for(String key:Fixed_Item_Map.keySet()){
                for(String keyline:Fixed_Item_Map.get(key).DetailLineMap.keySet()){
                    if(Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Allow_Changing_Incentive__c){
                        if(Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c!=null && Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Max_Incentive__c!=null){
                            if(Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c>Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Max_Incentive__c){
                                Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Over_Incentive__c=true;
                            }
                        }
                    }
                    Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c=  Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c!=null? Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Incentive_BT__c:0;
                    Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c=  Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c!=null? Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Total_Payable__c:0;
                    Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c=  Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c!=null? Fixed_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Payable_Vol__c:0;
                }
            }
        }
        
        
        for(String key:VariableEventCost.DetailLineMap.keySet()){
            if(VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Allow_Changing_Incentive__c){
                if(VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c!=null && VariableEventCost.DetailLineMap.get(key).ASI_CRM_Max_Incentive__c!=null){
                    if(VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c>VariableEventCost.DetailLineMap.get(key).ASI_CRM_Max_Incentive__c){
                        VariableEventCost.DetailLineMap.get(key).ASI_CRM_Over_Incentive__c=true;
                    }
                }
            }
            VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c=  VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c!=null? VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Incentive_BT__c:0;
            VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c=  VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c!=null? VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Total_Payable__c:0;
            VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c=  VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c!=null? VariableEventCost.DetailLineMap.get(key).ASI_CRM_CN_Payable_Vol__c:0;
            
        }        
    }
    
    
    // shared function 
    public String newCounterCreatorLine() {
        
        String idNew;
        IF(LINE_ITEM_NEWRECORD_COUNTER == null) {
            LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            LINE_ITEM_NEWRECORD_COUNTER+=1;
        }
        
        String zParser = '';
        Integer oneDigitCounter = LINE_ITEM_NEWRECORD_COUNTER;
        
        if(LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(LINE_ITEM_NEWRECORD_COUNTER, 10);
        }
        
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
        
    }
    
    
    
    
    
    public String NameSortingASC(decimal strSeq){
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
    
    
    
    
    public boolean VolumeDateValidationChecking(Date VolumeStartDate, Date VolumeEndDate,string ParentModuleId ,string ErrorInfo){ // ,BRSFItemMap.Module.ASI_CRM_Parent_Module__c
        
        Boolean ReturnFlag=true; //checking the start day 
        String DisplayErrorMsg=ErrorInfo;
        if(VolumeEndDate==null){
            DisplayErrorMsg +='Please input the end date.请输入结束日期。<br/>';
            ReturnFlag=false;
        }else{
            IF(ParentModuleId!=null && ParentModuleId!=''){
                for(ASI_CRM_Module__c HistoricalModule: HistoricalModuleList){
                    if(HistoricalModule.ASI_CRM_Parent_Module__c==ParentModuleId){
                        if(HistoricalModule.ASI_CRM_End_Date__c!=null){
                            if(HistoricalModule.ASI_CRM_End_Date__c>VolumeEndDate){
                                DisplayErrorMsg +='End date earlier than last payment End Date. 结束日期不能早于最新的付款的结束日期。<br/>';
                                ReturnFlag=false;
                            }
                        }
                    }
                }
            }
            
            if(VolumeStartDate.day()!=1){
                Msg +='Start Day should be the first day of month.<br/>';
                ReturnFlag=false;
            }
            //checking end day         
            Date LastEndDate = VolumeEndDate.addMonths(1).toStartOfMonth().addDays(-1);
            if(VolumeEndDate != LastEndDate){// Label.ASI_CRM_CN_PO_End_Date_Validation+
                DisplayErrorMsg +=Label.ASI_CRM_CN_PO_End_Date_Validation+'<br/>';//End Date should be the last day of the month .
                ReturnFlag=false;
            }
            
            if(PH.ASI_CRM_CN_PO_End_Date__c<VolumeEndDate || VolumeEndDate <PH.ASI_CRM_CN_PO_Start_Date__c){
                DisplayErrorMsg +=Label.ASI_CRM_CN_End_Date_within_PO_period+' .<br/>';//End Date should be within PO period
                ReturnFlag=false;
            }
            ASI_CRM_CN_HeavyContractUtilitiesClass.ReturnResult checkingResult =  ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(VolumeStartDate,VolumeEndDate);
            
            if(!checkingResult.Process){
                ReturnFlag= checkingResult.Process;
                DisplayErrorMsg += checkingResult.msg;
            }
            
        }
        
        if(ReturnFlag==false){
            UpsertPermission=false;
            msg+=DisplayErrorMsg;
        }
        
        return ReturnFlag;
    }
    
    
    
    
    
    
    public Decimal GeneratingIncentive(String SubBrandGradeName,String TypeName){
        
        
        Decimal Incentive=0.0;
        String ExternalKey=SubBrandGradeName;
        
        ExternalKey+= PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null? PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c:'';
        ExternalKey+= PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null? PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
        
        String CityTierExternalKey = ExternalKey;
        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c!=null && PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c !=null){
            CityTierExternalKey+= ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
        }
        system.debug('Now BRSFIncentive Key '+TypeName+' || '+ExternalKey+' || '+CityTierExternalKey);
        
        if(TypeName =='BRSFIncentive'){
            if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                Incentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_CN_Incentive__c;
            }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                Incentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_CN_Incentive__c;
            }else if(SubBrandGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_CN_Incentive__c;
            }           
        }
        
        if(TypeName =='BRSFMax'){
            if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                Incentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive__c;
            }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                Incentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive__c;
            }else if(SubBrandGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive__c;
            }            
        }
        
        
        if(TypeName =='PSFIncentive'){
            if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                Incentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Incentive_for_PSF__c;
            }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                Incentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_Incentive_for_PSF__c;
            }else if(SubBrandGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Incentive_for_PSF__c;
            }            
        }
        
        
        if(TypeName =='PSFMax'){
            if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                Incentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
            }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                Incentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
            }else if(SubBrandGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive_for_PSF__c;
            }            
        }
        
        if(Incentive==null){
            Incentive=0;
        }
        return Incentive;
    }
    
    
    
    
    
    public class PaymentLineObject{
        public Decimal NonMartellIntake  {set;get;} {NonMartellIntake=0.0;} 
        public Decimal NonMartellBC  {set;get;} {NonMartellBC=0.0;} 
        
        public Boolean NonMartellChooseIntake {set;get;} {NonMartellChooseIntake=false;}
        
        public Decimal MartellIntake  {set;get;} {MartellIntake=0.0;} 
        public Decimal MartellBC  {set;get;} {MartellBC=0.0;} 
        
        public Boolean MartellChooseIntake {set;get;} {MartellChooseIntake=false;}
        public PaymentLineObject(){
            NonMartellIntake=0.0;
            NonMartellBC=0.0;
            MartellIntake=0.0;
            MartellBC=0.0;
        }
    }
    
    
    
    
    //*******************************************************************************************************
    //* @description custom class for Line Detail
    // ********************************************************************************************************
    public Class interimData{
        public ASI_CRM_Module__c Module {set;get;} 
        public boolean HaveRefresh  {set;get;} 
        public String MethodologyValue  {set;get;} 
        
        public Decimal TotalIntake {set;get;}{TotalIntake=0;} //Display in the view page
        public Decimal TotalBC {set;get;}{TotalBC=0;}//Display in the view page
        
        public Decimal TotalIntake_Btl {set;get;}{TotalIntake_Btl=0;} // for calculating BC Rate 
        public Decimal TotalBC_Btl {set;get;}{TotalBC_Btl=0;}// for calculating BC Rate
        
        public Decimal TotalIntake_Completion {set;get;}{TotalIntake_Completion=0;} 
        public Decimal TotalBC_Completion {set;get;}{TotalBC_Completion=0;}
        
        public Decimal RealVolume {set;get;}{RealVolume=0;}
        public Decimal VolumeTarget {set;get;}{VolumeTarget=0;}
        
        public Decimal TotalCompletionRatio{set;get;}{TotalCompletionRatio=0;}
        public Decimal  TotalCTDPayableAmount {set;get;} {TotalCTDPayableAmount=0.0;}
        public map<String, ASI_TH_CRM_PaymentRequestLineItem__c> DetailLineMap{set;get;}
        
        public interimData(){
            Module=new ASI_CRM_Module__c();
            MethodologyValue='';
            DetailLineMap= new map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
            this.HaveRefresh=true;
        }
        public interimData(boolean ClickRefresh){
            Module=new ASI_CRM_Module__c();
            MethodologyValue='';
            DetailLineMap= new map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
            HaveRefresh=ClickRefresh;
        }
        
        public interimData( ASI_CRM_Module__c ModuleInput){
            Module=ModuleInput;
            MethodologyValue=ModuleInput.ASI_CRM_Methodology__r.Name;
            DetailLineMap= new map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
            this.HaveRefresh=true;
        }
        
        public interimData( ASI_CRM_Module__c ModuleInput,boolean ClickRefresh){
            Module=ModuleInput;
            MethodologyValue=ModuleInput.ASI_CRM_Methodology__r.Name;
            DetailLineMap= new map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
            this.HaveRefresh=ClickRefresh;
        }
    }
    
    
}