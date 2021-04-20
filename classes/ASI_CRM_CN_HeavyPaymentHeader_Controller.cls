/* Filename:    ASI_CRM_CN_HeavyPaymentHeader_Controller.cls
* Author:      Laputa
* Purpose:     Controller Class for payment request (new, edit, input payee, input payment detail) for CN CRM 4.2
ASI_CRM_CN_Payment_Header_Page
* History
* -----------------------------------------------------------------------------
* 2017-05-25   Laputa      Created
*/
public without sharing class ASI_CRM_CN_HeavyPaymentHeader_Controller {

    public void Calculation() {
        //Calculate all normal Data
        if(PH.ASI_CRM_System_Debug__c){
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                ASI_CRM_CN_HeavyPaymentUtilitiesClass.PaymentKPICalculation2nd(PH);
            } else {
                ASI_CRM_CN_HeavyPaymentUtilitiesClass.PaymentKPICalculation(PH);
            }
        }else{
            try{
                if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    ASI_CRM_CN_HeavyPaymentUtilitiesClass.PaymentKPICalculation2nd(PH);
                } else {
                    ASI_CRM_CN_HeavyPaymentUtilitiesClass.PaymentKPICalculation(PH);
                }
            } catch(Exception e){
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyPaymentHeader_Controller.Calculation <br/> in ASI_CRM_CN_ViewHeavyContractPage Page have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyPaymentHeader_Controller','Calculation function failed! with contract Id: '+ContractSelected.id );
            }

        }



        if(PH.ASI_CRM_CN_Last_Payment__c && !PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_IS_Manual_Refresh__c){

            try{
                String V0ContractID='';
                if(ContractSelected.ASI_CRM_CN_V0_0_PO_version__c!=null){
                    ASI_TH_CRM_Contract__c  V0Contract = [SELECT Id,Name,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c, ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
                                                          ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,
                                                          ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c ,   ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                                                          recordtypeid, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, createddate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, lastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,
                                                          ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                                          ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c
                                                          FROM ASI_TH_CRM_Contract__c
                                                          WHERE id =:ContractSelected.ASI_CRM_CN_V0_0_PO_version__c ];
                    if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {                                     
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> CurrentContractList =ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(V0Contract);   //ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected);
                    } else {
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> CurrentContractList =ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(V0Contract);   //ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected);
                    }
                }else{// this contract is V0.0
                    if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {   
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> CurrentContractList =ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(ContractSelected);//ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(ContractSelected);
                    } else {
                        ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected);
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> CurrentContractList =ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(ContractSelected);//ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(ContractSelected);
                    }
                }

                if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {   
                    ASI_CRM_CN_HeavyPaymentUtilitiesClass.ReconstructLastPaymentFIData2nd(PH);
                } else {
                    ASI_CRM_CN_HeavyPaymentUtilitiesClass.ReconstructLastPaymentFIData(PH);
                }
            }catch(Exception e){
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyPaymentHeader_Controller.Calculation <br/> in ASI_CRM_CN_ViewHeavyContractPage Page have Error  '+'Save Error : ' +e.getMessage() + '</br>'+e.getStackTraceString() + '</br>','ASI_CRM_CN_HeavyPaymentHeader_Controller','Calculation function failed! with contract Id: '+ContractSelected.id );
            }
        }
        //ContractSelected
    }

    //@description :variable definition 
    public ASI_TH_CRM_PaymentRequest__c PH {set;get;}
    public boolean cashtype {set;get;}
    public boolean discounttype{set;get;}

    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public Boolean DisplayVEC {set;get;}  {DisplayVEC=false;}

    public string PageId {set;get;}
    //Line Detail
    //****Other Payment Detail***
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> OtherPaymentLineList {set;get;}  {OtherPaymentLineList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();}
    public boolean showCN {set;get;}
    public Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  {get;set;}{SubBrandGradeMap= new Map<String, ASI_CRM_Sub_Brand_Grade__c>();}

    public interimData BRSFItemMap {set;get;} {BRSFItemMap= new interimData();}
    //PSF
    public map<String, interimData> PSF_Item_Map {set;get;} {PSF_Item_Map= new map<String, interimData>();}
    //PSF_Fixed
    public map<String, interimData> PSF_Fixed_Map {set;get;} {PSF_Fixed_Map= new map<String, interimData>();}
    //Variable Event Cost
    public interimData VariableEventCost {set;get;} {VariableEventCost= new interimData();} // Variable Event Cost= VEC

    public Boolean showReturn {set;get;}  {showReturn=false;}
    public map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CD {set;get;}{Payee_Item_Map_CD =new map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();}
    public map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_DISCOUNT {set;get;}{Payee_Item_Map_DISCOUNT =new map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();}
    public map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CASH {set;get;}{Payee_Item_Map_CASH =new map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();}


    public String Msg {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList {set;get;}{PaymentSummaryList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary>();}

    public Decimal MaxIncentive=99999;

    //******************************Initialization Start******************************************************   
    public ASI_CRM_CN_HeavyPaymentHeader_Controller(ApexPages.StandardController controller) {
        DisplayVEC=false;
        showCN = USerInfo.getLanguage()=='zh_CN';
        this.PH = (ASI_TH_CRM_PaymentRequest__c)controller.getRecord();
        PageId = PH.id;
        list <ASI_TH_CRM_PaymentRequest__c> HeaderList  = new list <ASI_TH_CRM_PaymentRequest__c>();

        //Get Header information
        if (PageId != null){
            HeaderList = [
                SELECT
                    ASI_CRM_Auto_PO_Modification__c,
                    ASI_CRM_CN_Adjustment__c,
                    ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_CRM_CN_BRSF_End_Date__c,
                    ASI_CRM_CN_BRSF_Start_Date__c,
                    ASI_CRM_CN_Business_License_Qualify__c,
                    ASI_CRM_CN_Channel__c,
                    ASI_CRM_CN_Currency__c,
                    ASI_CRM_CN_Description__c,
                    ASI_CRM_CN_Division__c,
                    ASI_CRM_CN_Last_Payment__c,
                    ASI_CRM_CN_Last_Year_Payment__c,
                    ASI_CRM_CN_No_of_Month__c,
                    ASI_CRM_CN_Other_Reason__c,
                    ASI_CRM_CN_OutletWS__c,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
                    ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c,
                    ASI_CRM_CN_Overpayment_Comment__c,
                    ASI_CRM_CN_Overpayment_Reason__c,
                    ASI_CRM_CN_Payable_Amount__c,
                    ASI_CRM_CN_Payment_Raised_Date__c,
                    ASI_CRM_CN_Payment_Type__c,
                    ASI_CRM_CN_PO_End_Date__c,
                    ASI_CRM_CN_PO_No__c,
                    ASI_CRM_CN_PO_Start_Date__c,
                    ASI_CRM_CN_PO_Version__c,
                    ASI_CRM_CN_PO_Version_Latest__c,
                    ASI_CRM_CN_Promotion_Type__c,
                    ASI_CRM_CN_Reason_For_Business_License__c,
                    ASI_CRM_CN_Reference_Code__c,
                    ASI_CRM_CN_Total_BRSF_Actual_Amount__c,
                    ASI_CRM_CN_Total_BRSF_Amount__c,
                    ASI_CRM_CN_Total_Other_Amount__c,
                    ASI_CRM_CN_Total_Payment__c,
                    ASI_CRM_CN_Total_PSF_Amount__c,
                    ASI_CRM_New_FY_Payment__c,
                    ASI_CRM_System_Debug__c,
                    ASI_CRM_Volume_Cut_Off_Date__c,
                    ASI_CRM_Volume_Option__c,
                    ASI_TH_CRM_Contract__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,
                    ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,
                    ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c,
                    ASI_TH_CRM_Status__c,
                    ASI_TH_CRM_Total_Amount__c,
                    Id,
                    Name,
                    ASI_TH_CRM_Contract__r.ASI_CRM_CN_IS_Manual_Refresh__c,
                    ASI_TH_CRM_GL_Date__c,ASI_CRM_CN_Invoice_Date__c,
                (SELECT
                    Id,
                    ASI_CRM_Line_Type__c,
                    ASI_CRM_Actual_Payment__c,
                    ASI_CRM_Volume_Base__c,
                    ASI_CRM_Completion_Ratio__c ,
                    ASI_CRM_PSF_Overpayment_Reason__c,
                    ASI_CRM_Fixedcost_Overpayment_Reason__c
                FROM ASI_CRM_Modules__r)
                FROM ASI_TH_CRM_PaymentRequest__c
                WHERE Id = :PageId
            ];

        }
        if (HeaderList.size()> 0){
            this.PH = HeaderList[0];
            ContractSelected = [SELECT Id,Name ,ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_Auto_PO_Modification__c,ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c, ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,ASI_CRM_Expected_V0_0_VEC_Est_Total__c,
                                ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,
                                ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c ,   ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c,
                                recordtypeid, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, createddate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, lastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,
                                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c, ASI_CRM_Investment_Type__c,ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_CRM_CN_Fixed_Module_Est_Amount1__c,ASI_CRM_CN_Fixed_Module_Est_Amount2__c
                                FROM ASI_TH_CRM_Contract__c
                                WHERE id =:PH.ASI_TH_CRM_Contract__c ];
        }
        init();
    }




    public void init(){

        String PSFSubBrandModuleId='';
        showReturn=false;
        if([SELECT Assignee.Name, PermissionSet.name
            FROM PermissionSetAssignment where permissionSet.name ='ASI_CRM_CN_General_BA' and Assigneeid = :Userinfo.getUserid()].size()>0 && PH.ASI_TH_CRM_Status__c == 'Submitted'){
                showReturn= true;
            }

        //Looping the Sub-Brand Grade
        for(ASI_CRM_Sub_Brand_Grade__c sbg:ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingSubBrandGrade(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c )){
            if(sbg.ASI_CRM_CN_City_Tier__c!=null){
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }
            SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
        }


        //Module : Map <Id, ASI_CRM_Module__c> 
        Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>();
        for (ASI_CRM_Module__c Module : [
            SELECT
                ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c,
                ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c,
                ASI_CRM_Actual_Payment__c,
                ASI_CRM_Fixedcost_Overpayment_Reason__c,
                ASI_CRM_Adjustment__c,
                ASI_CRM_Application_Payment_Amount__c,
                ASI_CRM_Completion_Ratio__c,
                ASI_CRM_End_Date__c,
                ASI_CRM_Historical_Paid_Amount__c,
                ASI_CRM_Line_Type__c,
                ASI_CRM_Methodology__c,
                ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                ASI_CRM_Methodology__r.Name,
                ASI_CRM_Other_Comments__c,
                ASI_CRM_Overpayment_Reason__c,
                ASI_CRM_PSF_Overpayment_Reason__c,
                ASI_CRM_Parent_Module__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Payment_Reference__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,
                ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,
                ASI_CRM_Payment_Reference__c,
                ASI_CRM_Reason_NCD_Volume_Base__c,
                ASI_CRM_Reason_Not_NCD_Methodology__c,
                ASI_CRM_Remark__c,
                ASI_CRM_Unit__c,
                ASI_CRM_Volume_Base__c,
                Id
            FROM ASI_CRM_Module__c
            WHERE ASI_CRM_Payment_Request__c = :PageId
        ])
        {
            if(Module.ASI_CRM_Line_Type__c=='BRSF'){
                interimData TempData= new interimData(Module);
                BRSFItemMap=TempData;
            }
            if(Module.ASI_CRM_Line_Type__c=='PSF'){
                interimData TempData= new interimData(Module);
                PSF_Item_Map.put(Module.ASI_CRM_Parent_Module__c,TempData);
                if(Module.ASI_CRM_Parent_Module__c !=NULL && Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    PSFSubBrandModuleId = Module.ASI_CRM_Parent_Module__c;
                }
            }
            if(Module.ASI_CRM_Line_Type__c=='Fixed' && ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                interimData TempData= new interimData(Module);
                PSF_Fixed_Map.put(Module.ASI_CRM_Parent_Module__c,TempData);
                if(Module.ASI_CRM_Parent_Module__c !=NULL && Module.ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                    PSFSubBrandModuleId = Module.ASI_CRM_Parent_Module__c;
                }
            }
            if(Module.ASI_CRM_Line_Type__c=='Variable Event Cost'){
                DisplayVEC=true;
                interimData TempData= new interimData(Module);
                VariableEventCost=TempData;
            }
            ModuleMap.put(Module.Id,Module);
        }

        //2nd get the segmet
        // List<Date> dateList = new List<Date>();
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
        Date setDate = ASI_CRM_CN_HeavyContractUtilitiesClass.FYConversion(Date.today());
        String channel = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c;
        String region = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
        String cityInvestementGrade = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Investment_Grade__c;
        String newImage = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c;
        Map<String, ASI_CRM_CM_GS__c> gsMap = ASI_CRM_CN_HeavyContractUtilitiesClass.GeneratingRegionTarget(channel,region,cityInvestementGrade,newImage,setDate,subBrandIdSets);

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
                ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c,
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
        ])
        {
            if(payline.ASI_CRM_CN_Suggested_Amount__c==null){
                payline.ASI_CRM_CN_Suggested_Amount__c=0;
            }
            if(payline.ASI_CRM_CN_Total_Payable__c==null){
                payline.ASI_CRM_CN_Total_Payable__c=0;
            }
            if(payline.ASI_CRM_Suggested_Volume__c ==null){
                payline.ASI_CRM_Suggested_Volume__c=0;
            }
            if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other'){
                if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                    if(PSF_Fixed_Map.containsKey(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c)){
                        String Mapkeystr=payline.Id;
                        System.debug(LoggingLevel.INFO, '*** payline: ' + payline);
                        System.debug(LoggingLevel.INFO, '*** payline.ASI_CRM_Suggested_Volume__c: ' + payline.ASI_CRM_Suggested_Volume__c);
                        System.debug(LoggingLevel.INFO, '*** payline.ASI_CRM_CN_Payable_Vol__c: ' + payline.ASI_CRM_CN_Payable_Vol__c);
                        
                        if(PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                           // payline.ASI_CRM_Max_Incentive__c=GeneratingIncentive(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'PSFMax');
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
                            IF(payline.ASI_CRM_Max_Incentive__c!=null && payline.ASI_CRM_CN_Incentive_BT__c!=null && payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                                if(payline.ASI_CRM_Max_Incentive__c<payline.ASI_CRM_CN_Incentive_BT__c){
                                    payline.ASI_CRM_Over_Incentive__c=true;
                                }else{
                                    payline.ASI_CRM_Over_Incentive__c=false;
                                }
                            }
                            Mapkeystr=NameSortingASC(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+payline.ASI_CRM_CN_Sub_Brand__c;
                            if(payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                                Mapkeystr='9'+Mapkeystr;
                            }
                            if(payline.ASI_CRM_Key_Sub_Brand__c){
                                Mapkeystr='0'+Mapkeystr;
                            }

                        }
                        if(PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Grade'){
                            Mapkeystr=NameSortingASC(payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c)+payline.ASI_CRM_Sub_Brand_Grade__c;
                            if(payline.ASI_CRM_CN_Incentive_BT__c==null || payline.ASI_CRM_CN_Incentive_BT__c==0){
                                Mapkeystr='9'+Mapkeystr;
                            }
                        }
                        if(PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Category'){
                            Mapkeystr=NameSortingASC(payline.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c)+payline.ASI_CRM_Product_Category__c;
                            if(payline.ASI_CRM_CN_Incentive_BT__c==null || payline.ASI_CRM_CN_Incentive_BT__c==0){
                                Mapkeystr='9'+Mapkeystr;
                            }
                        }
                        if(payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                            Mapkeystr='9'+Mapkeystr;
                        }

                        PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                        PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalBC+=payline.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?payline.ASI_CRM_CTD_Cap_Collection_Vol__c:0;

                        Boolean AllowCalculation=false;
                         if(payline.ASI_CRM_Non_Contract_Line__c ){
                            if(PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
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
                            PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake_Btl+=payline.ASI_CRM_CN_Actual_Vol__c!=null?payline.ASI_CRM_CN_Actual_Vol__c:0;
                            PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalBC_Btl+=payline.ASI_CRM_CN_Bottle_Collected__c!=null?payline.ASI_CRM_CN_Bottle_Collected__c:0;
                            PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalIntake_Completion+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                            PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).TotalBC_Completion+=payline.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?payline.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                        }

                        PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).VolumeTarget +=payline.ASI_CRM_V0_0_Full_Contract_Target__c!=null?payline.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                        PSF_Fixed_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).DetailLineMap.put(Mapkeystr,payline);
                    }
                } else {
                    OtherPaymentLineList.add(payline);
                }
            }else if(payline.ASI_CRM_Module__c !=null){
                if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_BRSF'){
                    if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                        if(gsMap.containsKey(payline.ASI_CRM_CN_Sub_Brand__c) && gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_CN_Incentive_BRSF__c != null){
                            payline.ASI_CRM_Max_Incentive__c=gsMap.get(payline.ASI_CRM_CN_Sub_Brand__c).ASI_CRM_Max_Incentive_BRSF__c;
                        }else{
                            payline.ASI_CRM_Max_Incentive__c=GeneratingIncentive(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'BRSFMax');  
                        }

                        if (payline.ASI_CRM_Max_Incentive__c == null) {
                            payline.ASI_CRM_Max_Incentive__c= MaxIncentive;
                        }
                    }
                    else {
                        payline.ASI_CRM_Max_Incentive__c=GeneratingIncentive(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'BRSFMax');
                    }
                    //Max incentive checking
                    IF(payline.ASI_CRM_Max_Incentive__c!=null && payline.ASI_CRM_CN_Incentive_BT__c!=null && payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
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
                    BRSFItemMap.DetailLineMap.put(Mapkeystr,payline);
                }else if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){

                    if(PSF_Item_Map.containsKey(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c)){
                         String Mapkeystr=payline.Id;
                        if(PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                           // payline.ASI_CRM_Max_Incentive__c=GeneratingIncentive(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,'PSFMax');
                            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
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
                            }

                            IF(payline.ASI_CRM_Max_Incentive__c!=null && payline.ASI_CRM_CN_Incentive_BT__c!=null && payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                                if(payline.ASI_CRM_Max_Incentive__c<payline.ASI_CRM_CN_Incentive_BT__c){
                                    payline.ASI_CRM_Over_Incentive__c=true;
                                }else{
                                    payline.ASI_CRM_Over_Incentive__c=false;
                                }
                            }
                            Mapkeystr=NameSortingASC(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+payline.ASI_CRM_CN_Sub_Brand__c;
                            if(payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                                Mapkeystr='9'+Mapkeystr;
                            }
                            if(payline.ASI_CRM_Key_Sub_Brand__c){
                                Mapkeystr='0'+Mapkeystr;
                            }

                        }
                        if(PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Grade'){
                            Mapkeystr=NameSortingASC(payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c)+payline.ASI_CRM_Sub_Brand_Grade__c;
                            if(payline.ASI_CRM_CN_Incentive_BT__c==null || payline.ASI_CRM_CN_Incentive_BT__c==0){
                                Mapkeystr='9'+Mapkeystr;
                            }
                        }
                        if(PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).Module.ASI_CRM_Volume_Base__c=='By Category'){
                            Mapkeystr=NameSortingASC(payline.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c)+payline.ASI_CRM_Product_Category__c;
                            if(payline.ASI_CRM_CN_Incentive_BT__c==null || payline.ASI_CRM_CN_Incentive_BT__c==0){
                                Mapkeystr='9'+Mapkeystr;
                            }
                        }
                        if(payline.ASI_CRM_CN_Allow_Changing_Incentive__c){
                            Mapkeystr='9'+Mapkeystr;
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

                        PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).VolumeTarget +=payline.ASI_CRM_V0_0_Full_Contract_Target__c!=null?payline.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                        PSF_Item_Map.get(payline.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c).DetailLineMap.put(Mapkeystr,payline);
                    }
                }else if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_VEC'){
                     String Mapkeystr=payline.Id;
                    if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Sub-Brand'){

                        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
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

                        Mapkeystr=NameSortingASC(payline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c)+payline.ASI_CRM_CN_Sub_Brand__c;
                    }
                    if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Grade'){
                        Mapkeystr=NameSortingASC(payline.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c)+payline.ASI_CRM_Sub_Brand_Grade__c;
                    }
                    if(VariableEventCost.Module.ASI_CRM_Volume_Base__c=='By Category'){
                        Mapkeystr=NameSortingASC(payline.ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c)+payline.ASI_CRM_Product_Category__c;
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

					VariableEventCost.VolumeTarget +=payline.ASI_CRM_V0_0_Full_Contract_Target__c!=null?payline.ASI_CRM_V0_0_Full_Contract_Target__c:0;
                    VariableEventCost.DetailLineMap.put(Mapkeystr,payline);
                }
            }else if(payline.ASI_CRM_Module__c ==null){
                if(payline.ASI_CRM_CN_Sub_Brand__c!=null && payline.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c=='999' && payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF' ){
                    PSF_Item_Map.get(PSFSubBrandModuleId).DetailLineMap.put(payline.Id,payline);
                }

                if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c && payline.ASI_CRM_CN_Sub_Brand__c!=null && payline.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c=='999' && payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Other') {
                    PSF_Fixed_Map.get(PSFSubBrandModuleId).DetailLineMap.put(payline.Id,payline);
                }

            }
        }

        for(String ModuleKey:PSF_Item_Map.keySet()){
            PSF_Item_Map.get(ModuleKey).RealVolume=MethodologyRoute(PSF_Item_Map.get(ModuleKey).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                    PSF_Item_Map.get(ModuleKey).TotalIntake_Completion,
                                                                    PSF_Item_Map.get(ModuleKey).TotalBC_Completion,
                                                                   CalculateBCRate(PSF_Item_Map.get(ModuleKey).TotalIntake_Btl,PSF_Item_Map.get(ModuleKey).TotalBC_Btl));
        }

        for(String ModuleKey:PSF_Fixed_Map.keySet()){
            PSF_Fixed_Map.get(ModuleKey).RealVolume=MethodologyRoute(PSF_Fixed_Map.get(ModuleKey).Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                                    PSF_Fixed_Map.get(ModuleKey).TotalIntake_Completion,
                                                                    PSF_Fixed_Map.get(ModuleKey).TotalBC_Completion,
                                                                   CalculateBCRate(PSF_Fixed_Map.get(ModuleKey).TotalIntake_Btl,PSF_Fixed_Map.get(ModuleKey).TotalBC_Btl));
        }

        VariableEventCost.RealVolume=MethodologyRoute(VariableEventCost.Module.ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                                      VariableEventCost.TotalIntake_Completion,VariableEventCost.TotalBC_Completion,
                                                      CalculateBCRate(VariableEventCost.TotalIntake_Btl,VariableEventCost.TotalBC_Btl));

        //PaymentSummaryList= new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary>();
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            PaymentSummaryList = ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(PH,ContractSelected);
        } else {
            PaymentSummaryList = ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(PH,ContractSelected);
        }

        if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Cash')||PH.ASI_CRM_CN_Payment_Type__c.contains('cash')))
            cashtype = true;
        else
            cashtype = false;

        if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Discount')||PH.ASI_CRM_CN_Payment_Type__c.contains('discount')))
            discounttype = true;
        else
            discounttype = false;



        integer indexCASH = 0;
        integer indexDISCOUNT = 0;
        integer indexCD = 0;

        List<ASI_CRM_CN_PH_Payee_Line_Item__c> LPHPayeeAll = [SELECT ASI_CRM_CN_Amount__c, ASI_CRM_CN_Cash_Discount__c, ASI_CRM_CN_Cash_Amount__c, ASI_CRM_CN_Discount_Amount__c,
                                                              ASI_CRM_CN_Payment_Request__c, ASI_CRM_CN_Type__c,ASI_CRM_CN_Payee_T1__r.Name, ASI_CRM_CN_Payee_T1__c, ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T1__r.Name,
                                                              ASI_CRM_CN_Reason__c , ASI_CRM_CN_Payee_T2__r.Name, ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Comfirm_Receipt__c,
                                                              ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name, RecordTypeId, ASI_CRM_CN_Instruction_Sent_Time__c
                                                              FROM ASI_CRM_CN_PH_Payee_Line_Item__c
                                                              WHERE ASI_CRM_CN_Payment_Request__c = :PH.Id and
                                                              (ASI_CRM_CN_Type__c = 'Cash' or ASI_CRM_CN_Type__c = 'Discount' or ASI_CRM_CN_Type__c = 'Others' OR ASI_CRM_CN_Type__c = 'CD')];

        for(ASI_CRM_CN_PH_Payee_Line_Item__c payee : LPHPayeeAll){
            if(payee.ASI_CRM_CN_Type__c == 'Cash'){
                Payee_Item_Map_CASH.put(indexCASH++, payee);
            }else if(payee.ASI_CRM_CN_Type__c == 'Discount'){
                Payee_Item_Map_DISCOUNT.put(indexDISCOUNT++, payee);
            }else if(payee.ASI_CRM_CN_Type__c == 'Others' || payee.ASI_CRM_CN_Type__c == 'CD'){
                Payee_Item_Map_CD.put(indexCD++, payee);
            }
        }


    }




    //******************************Initialization End******************************************************    




    //Go To Check Point Page    
    public PageReference GoToCheckPoint(){
        Msg=' ';
        UpsertPermission= true;


         //Last Payment checking
        for(ASI_TH_CRM_PaymentRequest__c paymentTemp:ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {
            if(paymentTemp.ASI_CRM_CN_Last_Payment__c==true && paymentTemp.ASI_TH_CRM_Status__c!='Draft'){
                ErrorHandling(Label.ASI_CRM_CN_ErrorMsg_MakePayment+paymentTemp.Name);
            }
        }


        //checking payment summary
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList =new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> ();
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            PaymentSummaryList = ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(PH,ContractSelected);
        } else {
            PaymentSummaryList = ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(PH,ContractSelected);
        }
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
                                                                  WHERE ASI_CRM_CN_Payment_Request__c = :PH.Id and
                                                                  (ASI_CRM_CN_Type__c = 'Cash' or ASI_CRM_CN_Type__c = 'Discount' or ASI_CRM_CN_Type__c = 'Others' OR ASI_CRM_CN_Type__c = 'CD')];

        for(ASI_CRM_CN_PH_Payee_Line_Item__c PayeeLine:LPHPayeeAll){
            sum_of_payee_amount+=PayeeLine.ASI_CRM_CN_Amount__c!=null?PayeeLine.ASI_CRM_CN_Amount__c:0;
        }




        List<ASI_Attachment__c> AttachmentList= new List<ASI_Attachment__c>();
        if(ContractSelected.ASI_CRM_CN_V0_0_PO_version__c!=null){
            AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c
                             where ASI_CRM_Contract__c = :ContractSelected.Id or ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c];
        }else{
            //Geting HistoricalV0.0 and VFinal Data
            AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c
                             where ASI_CRM_Contract__c = :ContractSelected.Id ];

        }


        Decimal FixedCostTotal=0;
        Decimal VariableCostTotal=0;
        if(AttachmentList.size()>0){
            Map<String,Decimal> PaymentKPIMap=new Map<String,Decimal>();

            for(ASI_Attachment__c att:AttachmentList){
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');

                //General Payment Info 
                if(att.ASI_CRM_Type__c=='Payment Data' &&  att.ASI_CRM_Contract__c==ContractSelected.Id){

                    PaymentKPIMap= (Map<String,Decimal>)System.JSON.deserialize(JsonString,Map<String,Decimal>.class);// system.debug('TempMap');system.debug(TempMap);
                    if( PaymentKPIMap.containsKey('FixedCostTotal')  ){
                        FixedCostTotal= PaymentKPIMap.get('FixedCostTotal');
                    }
                    if( PaymentKPIMap.containsKey('VariableCostTotal')  ){
                        VariableCostTotal= PaymentKPIMap.get('VariableCostTotal');
                    }

                }

            }

        }

        Decimal TotalAmount=(FixedCostTotal+VariableCostTotal);
        if(math.abs(sum_of_payee_amount-TotalAmount)>0.1){
            String tempStr = Label.ASI_CRM_CN_Payment_total_amount_no_consistent;
            Decimal payee_amount= sum_of_payee_amount.setScale(2, RoundingMode.HALF_UP);
            List<String> fillers = new String[] {payee_amount.format(),+TotalAmount.setScale(2, RoundingMode.HALF_UP).format()};
                ErrorHandling(String.format(tempStr,fillers));
        }

        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            Decimal poTotalAmount = 0;
            for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary ap : PaymentSummaryList){
                poTotalAmount += ap.POEstimatedAmount;
            }

            //if (TotalAmount  > PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c){
            if (TotalAmount  > poTotalAmount){
                String tempStr = Label.ASI_CRM_Payee_Amount_checking;
                List<String> fillers = new String[] {TotalAmount.format(),poTotalAmount.format()};
                     ErrorHandling(String.format(tempStr,fillers));
            }
        } else {
            if (TotalAmount  > PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c){
                String tempStr = Label.ASI_CRM_Payee_Amount_checking;
                List<String> fillers = new String[] {TotalAmount.format(),PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c.format()};
                     ErrorHandling(String.format(tempStr,fillers));
            }
        }

        if(UpsertPermission){
            PageReference redirect;
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                redirect = new PageReference('/apex/ASI_CRM_CN_HeavyPaymentCheckPage2nd?id='+PH.Id+'&Type=SubmitApproval');
            }
            else {
                redirect = new PageReference('/apex/ASI_CRM_CN_HeavyPaymentCheckPage?id='+PH.Id+'&Type=SubmitApproval');
            }
            
            redirect.getParameters().put('id',PageId);
            redirect.setRedirect(true);
            return redirect;
        }else{
            return null;
        }



    }



    public PageReference GoEditPayee(){
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_HeavyEditPaymentPayeePage');  // ASI_CRM_CN_EditPaymentPayeePage
        redirect.getParameters().put('id',PageId);
        redirect.setRedirect(true);
        return redirect;
    }


    public PageReference GoEditHeader(){
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditHeavyPayment_Header_Page');
        redirect.getParameters().put('id',PageId);
        redirect.setRedirect(true);
        return redirect;
    }

    public PageReference GoSubmitApproval(){
        //ASI_CN_SubmitApprovalController
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(PH.Id);
        req1.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult result = Approval.process(req1);
        return new pageReference('/' + PageId);


    }


    public Decimal CalculateBCRate(Decimal InputIntake,Decimal InputBC){
        Decimal ReturnBCRate=0;

        if(InputIntake!=null && InputIntake!=0){
            ReturnBCRate=(InputBC/InputIntake)*100;
        }

        return ReturnBCRate;
    }

     //M01: Min (BC, Intake)  --------------> (Min of CTD Actual Vol (Std Btl) &&     CTD Cap Collection Vol (Std Btl)   )
    //M02  :  BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC                  
    //M03: Min (BC/V0.0 BC%, Intake)       ; M04 : Intake  M05: Others 
    Public Decimal MethodologyRoute(String MethodologyCode,Decimal InputIntake,Decimal InputBC,Decimal InputBCRate){
        Decimal ReturnNumber=0;
        Decimal BCRate=InputBCRate;
        if(InputIntake==null){
            InputIntake=0;
        }
        if(InputBC==null){
            InputBC=0;
        }
       // if(InputIntake!=0){
            //BCRate=(InputBC/InputIntake)*100;
       // }
        //****compare**
        if(MethodologyCode=='M01'){
            if(InputIntake>InputBC){
                ReturnNumber=InputBC;
            }else{
                ReturnNumber=InputIntake;
            }
        }else if(MethodologyCode=='M02'){
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


     public PageReference GoReturn(){
         Msg='';
        List<ASI_TH_CRM_PaymentRequest__c> LPayment = [Select Id, ASI_TH_CRM_Status__c, ASI_CRM_CN_Return_Comments__c from ASI_TH_CRM_PaymentRequest__c where id=:PageId LIMIT 1];
        List<Profile> LProfileID = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = LProfileID[0].Name;

        if(LPayment.size() > 0){
            if(LPayment [0].ASI_TH_CRM_Status__c != 'Submitted'){
                if(USerInfo.getLanguage()=='zh_CN'){
                    UpsertPermission=false;
                    Msg+='付款不得退回！\nPO付款状态仅在"已提交"时方可退回。';//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'付款不得退回！\nPO付款状态仅在"已提交"时方可退回。'));
                }else{
                    UpsertPermission=false;
                    Msg+='Cannot Return Payment.\nOnly Payment with "Submitted" status can be returned';//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot Return Payment.\nOnly Payment with "Submitted" status can be returned'));
                }
            }
            else{
                if(LPayment[0].ASI_CRM_CN_Return_Comments__c != ''){
                    try{
                        LPayment[0].ASI_CRM_CN_Return_Comments__c = '';
                        update LPayment[0];
                    }catch(dmlException e){
                         UpsertPermission=false;
                         Msg+='Unable to save Return Comments.';//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Return Comments'));
                    }
                }

                PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_HeavyReturnPaymentPage?scontrolCaching=1&id='+PageId);
                pageRef.setRedirect(True);
                return pageRef;
            }
        }
        return null;
    }



    public PageReference GoEditDetailPage(){
        PageReference redirect ; 
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            redirect = new PageReference('/apex/ASI_CRM_CN_Edit_HeavyPR_Details2ndPage');
        } else {
            redirect = new PageReference('/apex/ASI_CRM_CN_Edit_HeavyPR_DetailsPage');
        }
        redirect.getParameters().put('id',PageId);
        redirect.setRedirect(true);
        return redirect;
    }


    public PageReference AutoPOModification(){
        if(PH.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c=='Final'){
            PH.ASI_CRM_Auto_PO_Modification__c =true;
            update PH;
            if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                ASI_CRM_CN_HeavyPaymentUtilitiesClass.LastPaymentAutoPOModification2nd(ContractSelected,PH.ASI_CRM_Volume_Cut_Off_Date__c);
            } else {
                ASI_CRM_CN_HeavyPaymentUtilitiesClass.LastPaymentAutoPOModification(ContractSelected,PH.ASI_CRM_Volume_Cut_Off_Date__c);
            }
            return new pageReference('/' + PageId);
        }else{
            UpsertPermission=false;
            Msg ='我们发现改合同不是	已批准 状态，无法继续执行PO自动修改。We found that contract is not in Final Status, cannot process Auto-PO Modi.';
            return null;
        }


    }



     public void ErrorHandling(String ErrorMsg){
        Msg += ErrorMsg + '<br/> ';

        UpsertPermission = false;
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


    public Decimal GeneratingIncentive(String SubBrandGradeName,String TypeName){


        Decimal Incentive=0.0;
        String ExternalKey=SubBrandGradeName;

        ExternalKey+= PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null? PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c:'';
        ExternalKey+= PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null? PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';

        String CityTierExternalKey = ExternalKey;
        if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__c!=null && PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c !=null){
            CityTierExternalKey+= ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c) ;
        }

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

        if(TypeName =='PSFMax'){
            if(SubBrandGradeMap.containsKey(CityTierExternalKey)){
                Incentive=SubBrandGradeMap.get(CityTierExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
            }else if(SubBrandGradeMap.containsKey(ExternalKey)){
                Incentive=SubBrandGradeMap.get(ExternalKey).ASI_CRM_Max_Incentive_for_PSF__c;
            }else if(SubBrandGradeMap.containsKey(SubBrandGradeName)){
                Incentive=SubBrandGradeMap.get(SubBrandGradeName).ASI_CRM_Max_Incentive_for_PSF__c;
            }
        }


        return Incentive;
    }



    //*******************************************************************************************************
    //* @description custom class for Line Detail
    // ********************************************************************************************************
    public Class interimData{
        public ASI_CRM_Module__c Module {set;get;}
        public boolean HaveRefresh  {set;get;}
        public String MethodologyValue  {set;get;}

        public Decimal TotalIntake {set;get;}{TotalIntake=0;}
        public Decimal TotalBC {set;get;}{TotalBC=0;}


        public Decimal TotalIntake_Btl {set;get;}{TotalIntake_Btl=0;}
        public Decimal TotalBC_Btl {set;get;}{TotalBC_Btl=0;}

        public Decimal TotalIntake_Completion {set;get;}{TotalIntake_Completion=0;}
        public Decimal TotalBC_Completion {set;get;}{TotalBC_Completion=0;}

        public Decimal RealVolume {set;get;}{RealVolume=0;}
        public Decimal VolumeTarget {set;get;}{VolumeTarget=0;}

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

    //20200317:AM@introv - copy "Tax Calculation" button (ASI_CRM_CN_Payment_Header_Controller [class] + ASI_CRM_CN_Payment_Header_Page [vf page])
    Public pageReference reDirectToTaxSavingPage(){
        return new pageReference('/apex/ASI_CRM_CN_Payment_Tax_Saving_Page?id=' + PageId);
    }

}