/*******************************************************************************
 *  Summary         : TOT MOT历史合同刷新成Dolphin合同Batch
 *  Refer Object    : 
 *  Author          :       
 *  CreatedDate     : 
 *  Change Log      : 
 ******************************************************************************/
global class ASI_CRM_CN_OffTOTMOTToDolphinBatch implements Database.Batchable<sObject> {
    public String query;
    public Set<Id> refreshContractIdSet = new Set<Id>();
    public Boolean isSplit = false;
    public static Map<String, String> storeTypeMap = new Map<String, String>{
        'Dolphin A' => 'A',
        'Dolphin B' => 'B',
        'Dolphin C' => 'C',
        'Dolphin Division' => 'Dolphin Division',
        'Falcon' => ''
    };
    global ASI_CRM_CN_OffTOTMOTToDolphinBatch() {
        this.query = query;
        this.refreshContractIdSet = refreshContractIdSet;
        this.isSplit = isSplit;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String querySQL = 'SELECT ASI_CRM_Active_Dummy_PO__c, ASI_CRM_Auto_PO_Modification__c, ASI_CRM_Auto_PO_Modification_Time__c, ASI_CRM_CN_Bottle_Collection_Rate__c,'
                +'ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Business_License__c, ASI_CRM_CN_Contract_Upload__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Description__c,'
                +'ASI_CRM_CN_Effective_Date__c, ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_CN_Expected_Display_Est_Total__c,' 
                +'ASI_CRM_CN_Expected_PSF_Est_Total__c, ASI_CRM_CN_Expected_V0_Display_Est_Total__c, ASI_CRM_CN_Group_Contract__c,'
                +'ASI_CRM_CN_Last_PO_version__c,ASI_CRM_Contract_Total_Dummy__c, ASI_CRM_Est_Total_Dummy__c, '
                +'ASI_CRM_CN_Last_Rejected_Date__c, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Local_Group_Contract__c, '
                +'ASI_CRM_CN_National_Group_Contract__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Outlet_WS__c,'
                +'ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_PO_Modification__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, '
                +'ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_Reason_without_Budget__c, ASI_CRM_CN_Region__c, '
                +'ASI_CRM_CN_Source_of_Contract__c, ASI_CRM_CN_Source_Others__c, ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Status__c,'
                +'ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Use_PRC_Contract_Template__c, ASI_CRM_CN_V0_0_PO_version__c,'
                +'ASI_CRM_CN_V0_Display_Contract_Total__c, ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_Contract_Template_Id__c,'
                +'ASI_CRM_Display_Estimate_Adjustment_Amt__c, ASI_CRM_EVC_Cost_Estimate_Total__c, '
                +'ASI_CRM_Expected_V0_0_VEC_Est_Total__c, ASI_CRM_Expected_V0_BRSF_Estimated_Total__c, '
                +'ASI_CRM_Expected_V0_PSF_Estimated_Total__c, '
                +'ASI_CRM_Heap_Size_Large__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_DolphinFalcon_Flag__c,'
                +'ASI_CRM_Investment_Type__c, ASI_CRM_Last_RBA_Approver__c, ASI_CRM_Martell_BC_Rate__c, ASI_CRM_National_Group__c, '
                +'ASI_CRM_National_Group__r.Name, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_City__c, '
                +'ASI_CRM_PO_City__r.Name, ASI_CRM_PO_Province__c, ASI_CRM_Prev_Version_Display_Est_Total__c, '
                +'ASI_CRM_Previous_Version_PSF_Est_Total__c, ASI_CRM_PSF_Contract_Adjustment_Amount__c, '
                +'ASI_CRM_PSF_Estimate_Adjustment_Amount__c, ASI_CRM_PSF_Grand_Contract_Total__c, '
                +'ASI_CRM_PSF_Grand_Estimate_Total__c, ASI_CRM_PSF_Grd_Est_Total_before_Adj__c, '
                +'ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c, ASI_CRM_System_Debug__c, ASI_CRM_V0_PSF_Contract_Total__c, '
                +'ASI_CRM_Volume_Option__c, ASI_TH_CRM_Promotion_Type__c, ASI_TH_CRM_Summary_Contract_Spending__c, CreatedById,'
                +'CreatedDate, Id, LastModifiedDate, Name, Owner.Email, OwnerId, RecordTypeId,ASI_CRM_CN_Is_Block__c,'
                +'ASI_CRM_CN_Total_RContract_Amount__c, ASI_CRM_CN_Is_Dolphin__c,ASI_CRM_CN_Activity_Times__c,ASI_CRM_CN_Target_Base__c,'
                +'ASI_CRM_CN_Contract_Classification__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c'
            +' FROM ASI_TH_CRM_Contract__c '
            +' WHERE Id IN :refreshContractIdSet';
        return Database.getQueryLocator(querySQL);
    }

    global void execute(Database.BatchableContext BC, list<ASI_TH_CRM_Contract__c> scope) {
        ASI_TH_CRM_Contract__c cont = scope[0];
        handleNormalPO(cont, isSplit);
    }

    global void finish(Database.BatchableContext BC) {

    }
    public static void handleNormalPO(ASI_TH_CRM_Contract__c cont, Boolean isSplit) {
        Decimal otherCostContractTotal = 0;
        Decimal otherCostEstTotal = 0;
        Integer iMonth = 1;
        Decimal monthRate = isSplit? iMonth / cont.ASI_CRM_CN_No_of_Months__c :0;
        List<ASI_CRM_Contract_Cost__c> lstUpsertCost = new List<ASI_CRM_Contract_Cost__c>();
        ASI_TH_CRM_Contract__c newCont = new ASI_TH_CRM_Contract__c();
        if (isSplit) {
            newCont = cont.clone();
            cont.ASI_CRM_CN_PO_End_Date__c = cont.ASI_CRM_CN_PO_Start_Date__c.toStartOfMonth().addMonths(iMonth).addDays(-1);
            newCont.ASI_CRM_CN_PO_Start_Date__c = cont.ASI_CRM_CN_PO_Start_Date__c.toStartOfMonth().addMonths(iMonth);
            newCont.ASI_CRM_CN_Is_Dolphin__c = true;
            newCont.ASI_CRM_CN_Activity_Times__c = 0;
            newCont.ASI_CRM_CN_Target_Base__c = 'Volume';
            newCont.ASI_CRM_CN_Contract_Classification__c = storeTypeMap.get(cont.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_DolphinFalcon_Flag__c);
        } else {
            cont.ASI_CRM_CN_Is_Dolphin__c = true;
            cont.ASI_CRM_CN_Activity_Times__c = 0;
            cont.ASI_CRM_CN_Target_Base__c = 'Volume';
            cont.ASI_CRM_CN_Contract_Classification__c = storeTypeMap.get(cont.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_DolphinFalcon_Flag__c);
        }

        for (ASI_CRM_Contract_Cost__c cost : [SELECT Id, Name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c,ASI_CRM_CN_Contract_Amount_Rate__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Estimate_Amount_Rate__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c
                  FROM ASI_CRM_Contract_Cost__c  WHERE ASI_CRM_CN_Contract__c = :cont.Id
                ]) {
            otherCostContractTotal += cost.ASI_CRM_CN_Contract_Amount__c != null? cost.ASI_CRM_CN_Contract_Amount__c:0;
            otherCostEstTotal += cost.ASI_CRM_CN_Estimate_Amount__c != null?cost.ASI_CRM_CN_Estimate_Amount__c:0;
            cost.ASI_CRM_CN_Contract_Amount__c = isSplit && cost.ASI_CRM_CN_Contract_Amount__c !=null ?cost.ASI_CRM_CN_Contract_Amount__c * monthRate : 0;
            cost.ASI_CRM_CN_Estimate_Amount__c = isSplit && cost.ASI_CRM_CN_Contract_Amount__c !=null?cost.ASI_CRM_CN_Estimate_Amount__c * monthRate : 0;
            // 拆分时新合同没有Display块
            if (isSplit) {
                ASI_CRM_Contract_Cost__c newCost = cost.clone();
                newCost.ASI_CRM_CN_Contract__c = newCont.Id;
                newCost.ASI_CRM_CN_Contract_Amount_Rate__c = 0;
                newCost.ASI_CRM_CN_Estimate_Amount_Rate__c = 0;
                newCost.ASI_CRM_CN_Contract_Amount__c = 0;
                newCost.ASI_CRM_CN_Estimate_Amount__c = 0;
                lstUpsertCost.add(newCost);
            } else {
                cost.ASI_CRM_CN_Contract_Amount_Rate__c = 0;
                cost.ASI_CRM_CN_Estimate_Amount_Rate__c = 0;
            }
            lstUpsertCost.add(cost);
        }
        List<ASI_CRM_Module__c> updateModule = new List<ASI_CRM_Module__c>();
        Decimal ContractTotal = cont.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c==null?0:cont.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c.setScale(2);
        Decimal EstTotal = cont.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c==null?0:cont.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c.setScale(2);

        Decimal psfTotal = cont.ASI_CRM_V0_PSF_Contract_Total__c==null?0:cont.ASI_CRM_V0_PSF_Contract_Total__c;
        Decimal psfEstTotal = cont.ASI_CRM_Expected_V0_PSF_Estimated_Total__c==null?0:cont.ASI_CRM_Expected_V0_PSF_Estimated_Total__c;

        Decimal displayTotal = cont.ASI_CRM_CN_V0_Display_Contract_Total__c==null?0:cont.ASI_CRM_CN_V0_Display_Contract_Total__c;
        Decimal displayEstTotal = cont.ASI_CRM_CN_Expected_V0_Display_Est_Total__c==null?0:cont.ASI_CRM_CN_Expected_V0_Display_Est_Total__c;
        
        Decimal amountTotal = psfTotal + displayTotal + otherCostContractTotal;
        Decimal amountEstTotal = psfEstTotal + displayEstTotal + otherCostEstTotal;
        Decimal TotalRabate = (amountTotal/ContractTotal) * 100;
        Document DocumentFile;
        if (!Test.isRunningTest()) {
            DocumentFile = ASI_CRM_CN_HeavyContracFunctionClass.GenerateGeneralContractTemplate('offDolphin',cont.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,false);
        }
        if (isSplit) {
            cont.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c = ContractTotal * monthRate;
            cont.ASI_CRM_Expected_V0_PSF_Estimated_Total__c = psfEstTotal * monthRate;
            cont.ASI_CRM_CN_Expected_PSF_Est_Total__c = psfEstTotal * monthRate;
            cont.ASI_CRM_V0_PSF_Contract_Total__c = psfTotal * monthRate;
            cont.ASI_CRM_CN_Expected_V0_Display_Est_Total__c = displayEstTotal * monthRate;
            cont.ASI_CRM_CN_Expected_Display_Est_Total__c = displayEstTotal * monthRate;
            cont.ASI_CRM_CN_V0_Display_Contract_Total__c = displayTotal * monthRate;
            cont.ASI_CRM_Contract_Template_Id__c = DocumentFile!=null?DocumentFile.Id:null;
            newCont.ASI_CRM_Expected_V0_BRSF_Estimated_Total__c = ContractTotal *( 1 - monthRate);
            newCont.ASI_CRM_Expected_V0_PSF_Estimated_Total__c = amountEstTotal * ( 1 - monthRate);
            newCont.ASI_CRM_CN_Expected_PSF_Est_Total__c = amountEstTotal * ( 1 - monthRate);
            newCont.ASI_CRM_V0_PSF_Contract_Total__c = amountTotal * ( 1 - monthRate);
            newCont.ASI_CRM_CN_Expected_V0_Display_Est_Total__c = 0;
            newCont.ASI_CRM_CN_Expected_Display_Est_Total__c = 0;
            newCont.ASI_CRM_CN_V0_Display_Contract_Total__c = 0;

            System.debug('*** cont.ASI_CRM_CN_PO_End_Date__c: ' + JSON.serializePretty(cont.ASI_CRM_CN_PO_End_Date__c) + '');
            update cont;
            System.debug('*** newCont: ' + JSON.serializePretty(newCont) + '');
            insert newCont;

        } else {
            cont.ASI_CRM_Expected_V0_PSF_Estimated_Total__c = amountEstTotal;
            cont.ASI_CRM_CN_Expected_PSF_Est_Total__c = amountEstTotal;
            cont.ASI_CRM_V0_PSF_Contract_Total__c = amountTotal;
            cont.ASI_CRM_CN_Expected_V0_Display_Est_Total__c = 0;
            cont.ASI_CRM_CN_Expected_Display_Est_Total__c = 0;
            cont.ASI_CRM_CN_V0_Display_Contract_Total__c = 0;
            cont.ASI_CRM_Contract_Template_Id__c = DocumentFile!=null?DocumentFile.Id:null;

        }

        Set<Id> SubBrandIdSet = new Set<Id> ();

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> upsertLineItems = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_Module__c> deleteModules = new List<ASI_CRM_Module__c>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> deleteLineItems = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        List<ASI_CRM_Module__c> psfModule = new List<ASI_CRM_Module__c>();
        List<ASI_CRM_Module__c> insertModules = new List<ASI_CRM_Module__c>();

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsfLineItems = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> insertBRSFLineItems = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for(ASI_CRM_Module__c module : [SELECT OwnerId, CurrencyIsoCode, RecordTypeId, ASI_CRM_Actual_Payment__c, 
            ASI_CRM_Adjustment__c, ASI_CRM_Application_Payment_Amount__c, ASI_CRM_Completion_Ratio__c,
             ASI_CRM_Contract__c, ASI_CRM_End_Date__c, ASI_CRM_External_ID__c, ASI_CRM_Group_Contract__c,
              ASI_CRM_Historical_Paid_Amount__c, ASI_CRM_Is_Default_Methodology__c, ASI_CRM_Line_Type__c, 
              ASI_CRM_Methodology__c, ASI_CRM_Other_Comments__c, ASI_CRM_Overpayment_Reason__c, 
              ASI_CRM_Parent_Module__c, ASI_CRM_Payment_Reference__c, ASI_CRM_Payment_Request__c,
               ASI_CRM_Reason_NCD_Volume_Base__c, ASI_CRM_Reason_Not_NCD_Methodology__c, 
               ASI_CRM_Remark__c, ASI_CRM_Suggested_Payable_Amount__c, ASI_CRM_Unit__c, ASI_CRM_Volume_Base__c,
                ASI_CRM_CN_AC_Code__c, ASI_CRM_BRSF_Overpayment_Reason__c, ASI_CRM_Created_PO_Version__c, 
                ASI_CRM_PSF_Overpayment_Reason__c, ASI_CRM_Remark_Options__c, ASI_CRM_VEC_Overpayment_Reason__c, 
                ASI_CRM_CN_CTD_Minimal_Achievement__c, ASI_CRM_CN_Contract_Volume_Base__c, ASI_CRM_CN_Criteria__c,
                 ASI_CRM_CN_Is_Capped__c, ASI_CRM_CN_KPI_Base__c, ASI_CRM_CN_Minimal_Achievement__c, 
                 ASI_CRM_CN_Total_Markup__c, ASI_CRM_CN_Volume_Value_Base__c, ASI_CRM_CN_Customer__c, 
                 ASI_CRM_CN_Only_for_Strategy_WS__c, ASI_CRM_CN_Proportion__c, 
                 (SELECT Id,  CurrencyIsoCode, RecordTypeId, ASI_CRM_CN_Contract__c, 
                    ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                     ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total_Dummy__c,
                      ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, 
                      ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_External_ID__c, 
                      ASI_CRM_CN_Sub_Brand__c, ASI_CRM_Contract_Monthly_Volume_CR12__c,
                       ASI_CRM_Contract_Total_QTY_CR12_Eqv__c, 
                       ASI_CRM_Contract_Total_QTY_std_Btl__c, ASI_CRM_Est_Monthly_Volume_CR12__c,
                        ASI_CRM_Est_Total_QTY_CR12_Eqv__c, ASI_CRM_Est_Total_QTY_std_Btl__c, 
                        ASI_CRM_Key_Sub_brand__c, ASI_CRM_Line_Name__c, 
                        ASI_CRM_Max_Incentive__c, ASI_CRM_Module__c, ASI_CRM_Product_Category_Name__c, 
                        ASI_CRM_Product_Category__c, ASI_CRM_Sub_Brand_CR12_Factor__c,
                        ASI_CRM_Sub_Brand_Grade_Name__c, ASI_CRM_Sub_Brand_Grade__c, 
                        ASI_CRM_Type__c, ASI_CRM_Volume_Base__c, ASI_CRM_Map_Key__c, 
                        ASI_CRM_Adjustment_Line__c, ASI_CRM_Contract_MonthlyVol_CR12ExclPrem__c, 
                        ASI_CRM_Contract_MonthlyVol_std_ExclPrem__c, ASI_CRM_Est_MonthlyVolume_CR12_ExclPrem__c, 
                        ASI_CRM_Est_Monthly_Vol_std_Btl_ExclPrem__c, ASI_CRM_Actual_CM_GS__c,
                        ASI_CRM_CN_Contract_Purchase_Value__c, ASI_CRM_CN_Estimate_Purchase_Value__c, 
                        ASI_CRM_CN_GS_Per_9L__c, ASI_CRM_CN_Max_Purchase_Target__c, ASI_CRM_CN_Max_Rebate_Percent__c,
                       ASI_CRM_CN_Min_Purchase_Target__c, ASI_CRM_CN_Rebate_Percent__c, ASI_CRM_CN_Rebate__c, 
                       ASI_CRM_CN_Target__c, ASI_CRM_CN_Date__c, ASI_CRM_CN_Package_Number__c, ASI_CRM_CN_Sub_Brand_Package__c, 
                       ASI_CRM_CN_Sub_brand_Group__c, ASI_CRM_CN_Total_Volume_9L__c, ASI_CRM_CN_Total_Volume_Std_btl__c, 
                       ASI_CRM_Line_Long_Name__c, ASI_CRM_CN_Drop_In__c, ASI_CRM_CN_Pack_Size__c, 
                       ASI_CRM_CN_TP_CM_Per_9L__c, ASI_CRM_CN_TP_Fixed_Cost__c, ASI_CRM_CN_TP_Promotion_Cost__c 
                FROM Contract_BRSF_Line_Item__r
                )
        FROM ASI_CRM_Module__c 
        WHERE ASI_CRM_Contract__c = :cont.Id AND ASI_CRM_Line_Type__c IN ('BRSF', 'PSF', 'Display')])
        {
            if (module.ASI_CRM_Line_Type__c == 'BRSF') {
                if (isSplit) {
                    ASI_CRM_Module__c newBRSFModule = module.clone();
                    newBRSFModule.ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan';
                    newBRSFModule.ASI_CRM_CN_Volume_Value_Base__c = 'Value';
                    newBRSFModule.ASI_CRM_Contract__c = newCont.Id;
                    insertModules.add(newBRSFModule);
                } else {
                    module.ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan';
                    module.ASI_CRM_CN_Volume_Value_Base__c = 'Value';
                    updateModule.add(module);
                }
                brsfLineItems.addAll(module.Contract_BRSF_Line_Item__r);
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : module.Contract_BRSF_Line_Item__r) {
                    // ContractTotal += line.ASI_CRM_CN_Contract_Total_Dummy__c == null?0:line.ASI_CRM_CN_Contract_Total_Dummy__c;
                    // EstTotal += line.ASI_CRM_CN_Est_Total_Dummy__c == null?0:line.ASI_CRM_CN_Est_Total_Dummy__c;
                    if (line.ASI_CRM_CN_Sub_Brand__c != null) {
                        SubBrandIdSet.add(line.ASI_CRM_CN_Sub_Brand__c);
                    }
                    if (isSplit) {
                        ASI_CRM_CN_Contract_BRSF_Line_Item__c newBRSFLineItems = line.clone();
                        upsertLineItems.add(generateBRSFLineItemAmount(line, monthRate));
                        newBRSFLineItems.ASI_CRM_CN_Contract__c = newCont.Id;
                        insertBRSFLineItems.add(generateBRSFLineItemAmount(newBRSFLineItems, 1-monthRate));
                    }
                }
            }
            if (module.ASI_CRM_Line_Type__c == 'PSF') {
                psfModule.add(module);
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : module.Contract_BRSF_Line_Item__r) {
                    // psfTotal += line.ASI_CRM_CN_Contract_Total_Dummy__c == null?0:line.ASI_CRM_CN_Contract_Total_Dummy__c;
                    // psfEstTotal += line.ASI_CRM_CN_Est_Total_Dummy__c == null?0:line.ASI_CRM_CN_Est_Total_Dummy__c;
                    if (isSplit) {
                        upsertLineItems.add(generateBRSFLineItemAmount(line, monthRate));
                    }
                }
                if (!isSplit) {
                    deleteModules.add(module);
                    deleteLineItems.addAll(module.Contract_BRSF_Line_Item__r);
                }
            }
            if (module.ASI_CRM_Line_Type__c == 'Display') {
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : module.Contract_BRSF_Line_Item__r) {
                    // displayTotaesdl += line.ASI_CRM_CN_Contract_Total_Dummy__c == null?0:line.ASI_CRM_CN_Contract_Total_Dummy__c;
                    // displayEstTotal += line.ASI_CRM_CN_Est_Total_Dummy__c == null?0:line.ASI_CRM_CN_Est_Total_Dummy__c;
                    if (isSplit) {
                        line = generateBRSFLineItemAmount(line, monthRate);
                    } else {
                        line.ASI_CRM_CN_Contract_Total_Dummy__c = 0;
                        line.ASI_CRM_CN_Est_Total_Dummy__c = 0;
                    }
                    upsertLineItems.add(line);
                }
            }
        }

        // 计算PSF line Item相关信息
        Map<String, Decimal> CR12FactorMap = ASI_CRM_CN_OffContractUtilitiesClass.GenerateCR12FactorMap(SubBrandIdSet,
                 cont.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, 
                 cont.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c);
        ASI_CRM_CN_Contract_BRSF_Line_Item__c tempLine = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Est_Monthly_Qty__c = 0,
            ASI_CRM_Est_Monthly_Volume_CR12__c = 0,
            ASI_CRM_Est_Total_QTY_std_Btl__c =0,
            ASI_CRM_Est_Total_QTY_CR12_Eqv__c = 0,
            ASI_CRM_CN_Contract_Monthly_Qty__c = 0,
            ASI_CRM_Contract_Monthly_Volume_CR12__c = 0,
            ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = 0,
            ASI_CRM_Contract_Total_QTY_std_Btl__c = 0
            );
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : brsfLineItems) {
            Decimal CR12Factor = CR12FactorMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)? CR12FactorMap.get(line.ASI_CRM_CN_Sub_Brand__c) : 1;
            tempLine.ASI_CRM_CN_Est_Monthly_Qty__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c;
            tempLine.ASI_CRM_Est_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor;
            
            if (line.ASI_CRM_Est_Total_QTY_std_Btl__c != null) {
                tempLine.ASI_CRM_Est_Total_QTY_std_Btl__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c;
                tempLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c * CR12Factor;
            } else {
                tempLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * cont.ASI_CRM_CN_V00_No_of_Month__c;
                tempLine.ASI_CRM_Est_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * cont.ASI_CRM_CN_V00_No_of_Month__c;
            }

            tempLine.ASI_CRM_CN_Contract_Monthly_Qty__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c;
            tempLine.ASI_CRM_Contract_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor;
            tempLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor * cont.ASI_CRM_CN_No_of_Months__c;
            tempLine.ASI_CRM_Contract_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * cont.ASI_CRM_CN_No_of_Months__c;
        }


        // Decimal TotalEstRabate = (psfEstTotal + displayEstTotal + otherCostEstTotal)/EstTotal;
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> insertPSFLineItems = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Id methodologyId = [SELECT Id FROM ASI_CRM_Methodology__c where Name = 'Rebate%' AND RecordType.DeveloperName = 'ASI_CRM_CN_Methodology_TOT_MOT_Contract' LIMIT 1]?.Id;
        // 第一个PSFModule
        ASI_CRM_Module__c module1 = psfModule[0].clone();
        module1 = generatePSFModule(module1);
        module1.ASI_CRM_Contract__c = isSplit?newCont.Id:cont.Id;
        module1.ASI_CRM_Methodology__c = methodologyId;
        module1.ASI_CRM_CN_Minimal_Achievement__c = 0;
        insertModules.add(module1);

        // 第二个PSFModule
        ASI_CRM_Module__c module2 = psfModule[0].clone();
        module2 = generatePSFModule(module2);
        module2.ASI_CRM_Contract__c = isSplit?newCont.Id:cont.Id;
        module2.ASI_CRM_Methodology__c = methodologyId;
        module2.ASI_CRM_CN_Minimal_Achievement__c = 80;
        insertModules.add(module2);

        System.debug('*** insertModules: ' + JSON.serializePretty(insertModules) + '');
        System.debug('*** insertPSFLineItems: ' + JSON.serializePretty(insertPSFLineItems) + '');
        SavePoint sp = Database.setSavePoint();

        try {
            if (!isSplit) {
                update cont;
                update updateModule;
            }
            upsert lstUpsertCost;
            upsert upsertLineItems;
            if (!isSplit) {
                delete deleteModules;
                delete deleteLineItems;
            }
            insert insertModules;
            for (Integer i=0; i<insertModules.size(); i++) {
                ASI_CRM_Module__c module = insertModules[i];
                if (module.ASI_CRM_Line_Type__c == 'PSF') {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c psfLineItem1 = psfModule[0].Contract_BRSF_Line_Item__r[0].clone();
                    psfLineItem1.ASI_CRM_Volume_Base__c = 'By Total';
                    psfLineItem1.ASI_CRM_Module__c = module.Id;
                    psfLineItem1.ASI_CRM_CN_Contract__c = isSplit?newCont.Id:cont.Id;
                    psfLineItem1.ASI_CRM_CN_Contract_Purchase_Value__c = (ContractTotal *  (1-monthRate)).setScale(2);
                    psfLineItem1.ASI_CRM_CN_Estimate_Purchase_Value__c = (EstTotal* (1-monthRate)).setScale(2);
                    if ((isSplit && i == 1 ) || (!isSplit && i == 0)) {
                        psfLineItem1.ASI_CRM_CN_Rebate_Percent__c = 1;
                        psfLineItem1.ASI_CRM_CN_Contract_Total_Dummy__c = ContractTotal* (1-monthRate) * (0.01);
                        psfLineItem1.ASI_CRM_CN_Est_Total_Dummy__c = EstTotal * (1-monthRate) * (0.01);            
                    } else {
                        psfLineItem1.ASI_CRM_CN_Rebate_Percent__c = TotalRabate - 1;
                        System.debug(LoggingLevel.INFO, '*** psfLineItem1.ASI_CRM_CN_Rebate_Percent__c: ' + psfLineItem1.ASI_CRM_CN_Rebate_Percent__c);
                        psfLineItem1.ASI_CRM_CN_Contract_Total_Dummy__c = ContractTotal* (1-monthRate) * (psfLineItem1.ASI_CRM_CN_Rebate_Percent__c/100);
                        psfLineItem1.ASI_CRM_CN_Est_Total_Dummy__c = EstTotal * (1-monthRate) * (psfLineItem1.ASI_CRM_CN_Rebate_Percent__c/100);
                        psfLineItem1.ASI_CRM_CN_Rebate_Percent__c = psfLineItem1.ASI_CRM_CN_Rebate_Percent__c.setScale(2);
                    }
                    psfLineItem1.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = tempLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                    psfLineItem1.ASI_CRM_CN_Contract_Monthly_Qty__c = tempLine.ASI_CRM_CN_Contract_Monthly_Qty__c;
                    psfLineItem1.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = tempLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    psfLineItem1.ASI_CRM_CN_Est_Monthly_Qty__c = tempLine.ASI_CRM_CN_Est_Monthly_Qty__c;
                    psfLineItem1.ASI_CRM_Contract_Total_QTY_std_Btl__c = tempLine.ASI_CRM_Contract_Total_QTY_std_Btl__c == null? 0 : tempLine.ASI_CRM_Contract_Total_QTY_std_Btl__c * (1-monthRate);
                    psfLineItem1.ASI_CRM_Est_Total_QTY_std_Btl__c = tempLine.ASI_CRM_Est_Total_QTY_std_Btl__c == null? 0 : tempLine.ASI_CRM_Est_Total_QTY_std_Btl__c * (1-monthRate);
                    psfLineItem1.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = tempLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null? 0 : tempLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c * (1-monthRate);
                    psfLineItem1.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = tempLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null? 0 : tempLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c * (1-monthRate);
                    insertPSFLineItems.add(psfLineItem1);            
                } else {
                    for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItems : insertBRSFLineItems) {
                        lineItems.ASI_CRM_Module__c = module.Id;
                        insertPSFLineItems.add(lineItems);
                    }

                }
            }
            insert insertPSFLineItems;
        }
        catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getStackTraceString(): ' + e.getStackTraceString());
        }
    }

    public static ASI_CRM_CN_Contract_BRSF_Line_Item__c generateBRSFLineItemAmount(ASI_CRM_CN_Contract_BRSF_Line_Item__c line, Decimal monthRate) {
        line.ASI_CRM_Contract_Total_QTY_std_Btl__c = line.ASI_CRM_Contract_Total_QTY_std_Btl__c !=null?line.ASI_CRM_Contract_Total_QTY_std_Btl__c * monthRate : 0;
        line.ASI_CRM_Est_Total_QTY_std_Btl__c = line.ASI_CRM_Est_Total_QTY_std_Btl__c !=null?line.ASI_CRM_Est_Total_QTY_std_Btl__c * monthRate : 0;
        line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c !=null?line.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c * monthRate : 0;
        line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c !=null?line.ASI_CRM_Est_Total_QTY_CR12_Eqv__c * monthRate : 0;
        line.ASI_CRM_CN_Contract_Total_Dummy__c = line.ASI_CRM_CN_Contract_Total_Dummy__c !=null?line.ASI_CRM_CN_Contract_Total_Dummy__c * monthRate : 0;
        line.ASI_CRM_CN_Est_Total_Dummy__c = line.ASI_CRM_CN_Est_Total_Dummy__c !=null?line.ASI_CRM_CN_Est_Total_Dummy__c * monthRate : 0;
        line.ASI_CRM_CN_Contract_Purchase_Value__c = line.ASI_CRM_CN_Contract_Purchase_Value__c !=null?line.ASI_CRM_CN_Contract_Purchase_Value__c * monthRate : 0;
        line.ASI_CRM_CN_Estimate_Purchase_Value__c = line.ASI_CRM_CN_Estimate_Purchase_Value__c !=null?line.ASI_CRM_CN_Estimate_Purchase_Value__c * monthRate : 0;
        return line;
    }

    public static ASI_CRM_Module__c generatePSFModule(ASI_CRM_Module__c module) {
        module.ASI_CRM_Unit__c = 'RMB';
        module.ASI_CRM_Volume_Base__c = 'By Total';
        module.ASI_CRM_CN_Volume_Value_Base__c = 'Value';
        module.ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan';
        module.ASI_CRM_CN_KPI_Base__c = 'Value base';
        module.ASI_CRM_CN_Is_Capped__c = false;
        return module;
    }

}