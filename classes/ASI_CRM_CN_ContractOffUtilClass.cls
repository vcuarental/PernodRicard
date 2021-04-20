/***************************************************************************************************************************
* Name:        ASI_CRM_CN_ContractOffUtilClass
* Description: Apex class for ASI_CRM_CN_ContractOffUtilClass
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-08-21       Jeffrey Cheung          Created
****************************************************************************************************************************/

public class ASI_CRM_CN_ContractOffUtilClass {
 
    Public static Decimal MINIMAL_ACHIEVEMENT=80;

    public static List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> GeneratingVolumeValueTargetLine(ASI_TH_CRM_Contract__c contract) {
        // Select contract to avoid null fields
        contract = [SELECT Id, ASI_CRM_CN_Group_Contract__c, ASI_CRM_CN_Outlet_WS__c, 
                    ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c, 
                    ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_CN_Is_Dolphin__c
                    FROM ASI_TH_CRM_Contract__c WHERE Id = :contract.Id];

        if (contract.ASI_CRM_CN_Group_Contract__c != null) {
            return copyGroupPOToContract(contract, contract.ASI_CRM_CN_Group_Contract__c);
        }

        List<ASI_CRM_Module__c> oldModuleList = [SELECT Id,ASI_CRM_Line_Type__c,ASI_CRM_Contract__c 
                                                FROM ASI_CRM_Module__c
                                                WHERE ASI_CRM_Contract__c = :contract.Id AND ASI_CRM_Line_Type__c = 'BRSF'];

        String BRSFActivityCodeId = '';
        String PSFActivityCodeId = '';
        ASI_CRM_Module__c Module = new ASI_CRM_Module__c();
        ASI_CRM_Module__c firstPsfModule = new ASI_CRM_Module__c();
        ASI_CRM_Module__c secondPsfModule = new ASI_CRM_Module__c();

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFLineInsert = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Id BRSFLineRtId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
        //********************Insert module*************************************************************************
        //Find Default value for BRSF

        List<ASI_CRM_Module__c> InsertModuleList = new List<ASI_CRM_Module__c>();

        ASI_CN_Trade_Margin__c margin = getDefaultTradeMargin(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c, contract.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName);

        ASI_CRM_CN_CustomSetting__c customSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        if(contract.ASI_CRM_CN_Is_Dolphin__c){
            Module = new ASI_CRM_Module__c(
                ASI_CRM_Line_Type__c = 'BRSF',
                ASI_CRM_Contract__c = contract.Id,
                ASI_CRM_CN_Volume_Value_Base__c = 'Value',
                ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan',
                ASI_CRM_CN_Total_Markup__c = customSetting.ASI_CRM_CN_Dolphin_PO_Default_Markup__c
            );
            InsertModuleList.add(Module);
            ASI_CRM_Methodology__c defaultMethodology = [SELECT Id,Name FROM ASI_CRM_Methodology__c WHERE ASI_CRM_Type__c = 'PSF' ANd ASI_CRM_CN_KPI_Base__c = 'Value Base' AND Name  = 'Rebate%' AND Recordtype.Developername = 'ASI_CRM_CN_Methodology_TOT_MOT_Contract' Limit 1];
            firstPsfModule = new ASI_CRM_Module__c(
                ASI_CRM_Line_Type__c = 'PSF',
                ASI_CRM_Contract__c = contract.Id,
                ASI_CRM_Created_PO_Version__c = '0.0',
                ASI_CRM_CN_Volume_Value_Base__c = 'Value',
                //ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan',
                ASI_CRM_CN_KPI_Base__c = 'Value base',
                ASI_CRM_CN_Minimal_Achievement__c = 0,
                ASI_CRM_Methodology__c = defaultMethodology.Id,
                //ASI_CRM_CN_Is_Capped__c = true,
                //ASI_CRM_CN_Criteria__c = 'By Ladder',
                ASI_CRM_Volume_Base__c = 'By Total',
                ASI_CRM_Unit__c = 'RMB'
            );
            InsertModuleList.add(firstPsfModule);
            secondPsfModule = new ASI_CRM_Module__c(
                ASI_CRM_Line_Type__c = 'PSF',
                ASI_CRM_Contract__c = contract.Id,
                ASI_CRM_Created_PO_Version__c = '0.0',
                ASI_CRM_CN_Volume_Value_Base__c = 'Value',
                //ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan',
                ASI_CRM_CN_KPI_Base__c = 'Value base',
                //2020-12-15 default 80%
                ASI_CRM_CN_Minimal_Achievement__c = MINIMAL_ACHIEVEMENT,
                ASI_CRM_Methodology__c = defaultMethodology.Id,
                //ASI_CRM_CN_Is_Capped__c = true,
                //ASI_CRM_CN_Criteria__c = 'By Ladder',
                ASI_CRM_Volume_Base__c = 'By Total',
                ASI_CRM_Unit__c = 'RMB'
            );
            InsertModuleList.add(secondPsfModule);
        }else{
            Module = new ASI_CRM_Module__c(
                ASI_CRM_Line_Type__c = 'BRSF',
                ASI_CRM_Contract__c = contract.Id,
                ASI_CRM_CN_Volume_Value_Base__c = 'Volume',
                ASI_CRM_CN_Total_Markup__c = margin != null? margin.ASI_CRM_CN_Default_Margin__c : 0
            );
            InsertModuleList.add(Module);
        }
        
        if (InsertModuleList.size() > 0 && oldModuleList.size() == 0) {
            try {
                insert InsertModuleList;
            } catch (Exception e) {
                String msg = 'Save Error : ' + e.getMessage() + '</br>';
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_ContractOffUtilClass.GeneratingVolumeValueTargetLine class have Error:  ' + msg, 'GeneratingVolumeValueTargetLine', 'Contract Id: ' + contract);
            }
        }
        //----- get Contract Cost Setting List and then get ASI_CRM_CN_Activity_Code__c
        for (ASI_CRM_Contract_Cost_Setting__c ContractCostSetting:[SELECT Id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_BRSF_Activity_Code_Default__c,ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c, ASI_CRM_CN_Other_Cost_Payment_Request__c,ASI_CRM_PSF_Activity_Code_Default__c
                                                                   FROM ASI_CRM_Contract_Cost_Setting__c 
                                                                   WHERE ASI_CRM_CN_Promotion_Type__c='TOT/MOT Contract'])
        {
            if(ContractCostSetting.ASI_CRM_CN_BRSF_Activity_Code_Default__c){
                //if(ContractCostSetting.name.contains('Bottle Return Service')){
                BRSFActivityCodeId=ContractCostSetting.ASI_CRM_CN_Activity_Code__c;
            }
            if (ContractCostSetting.ASI_CRM_PSF_Activity_Code_Default__c) {
                PSFActivityCodeId = ContractCostSetting.ASI_CRM_CN_Activity_Code__c;
            }
        }
        ASI_CRM_AccountsAdditionalField__c Outlet = new ASI_CRM_AccountsAdditionalField__c();
        
        try{
            Outlet = [SELECT Id,ASI_CRM_CN_CCity__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                      ASI_CRM_CN_New_Image__c,ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_Commercial_Team__c,ASI_CRM_Channel_Group__c
                      FROM ASI_CRM_AccountsAdditionalField__c
                      WHERE Id =:contract.ASI_CRM_CN_Outlet_WS__c  AND ASI_CRM_CN_New_Image__c!=NULL AND ASI_CRM_CN_NewChannel__c !=NULL];
        }catch(Exception e){
            
            
        }
        //SubBrandGradeMap: Sub Brand name + Region + Commercial Team,  ASI_CRM_Sub_Brand_Grade__c
        Map<String, ASI_CRM_Sub_Brand_Grade__c> SubBrandGradeMap  = new Map<String,ASI_CRM_Sub_Brand_Grade__c>();
        
        for(ASI_CRM_Sub_Brand_Grade__c sbg:[SELECT Id, Name,ASI_CRM_CN_City_Tier__c,ASI_CRM_External_Key__c,ASI_CRM_CN_Incentive__c,RecordType.DeveloperName,ASI_CRM_Incentive_for_PSF__c,
                                            ASI_CRM_Max_Incentive_for_PSF__c,ASI_CRM_Max_Incentive__c
                                            FROM ASI_CRM_Sub_Brand_Grade__c WHERE
                                            RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade' OR
                                            ( RecordType.DeveloperName ='ASI_CRM_CN_Sub_brand_Grade_TOT_MOT_Contract'
                                             AND ASI_CRM_Commercial_Team__c = :Outlet.ASI_CRM_CN_Commercial_Team__c
                                             AND ASI_CRM_Region__c = :Outlet.ASI_CRM_CN_Region__c) ])
        {
            if(sbg.ASI_CRM_CN_City_Tier__c!=null){
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c+ASI_CRM_CN_HeavyContractUtilitiesClass.CityTierGeneration(sbg.ASI_CRM_CN_City_Tier__c), sbg);
            }else{
                SubBrandGradeMap.put(sbg.ASI_CRM_External_Key__c, sbg);
            }
            
        }
        
        if(contract.ASI_CRM_CN_Is_Dolphin__c && oldModuleList.size() == 0){
            //first psf module line
            ASI_CRM_CN_Contract_BRSF_Line_Item__c FirstPSFLINE = createBRSFLine('PSF', BRSFLineRtId, contract.Id, firstPsfModule.Id, PSFActivityCodeId);
            //FirstPSFLINE.ASI_CRM_CN_Min_Purchase_Target__c = 0;
            FirstPSFLINE.ASI_CRM_Volume_Base__c = firstPsfModule.ASI_CRM_Volume_Base__c;
            FirstPSFLINE.ASI_CRM_CN_Contract_Purchase_Value__c = 0;
            FirstPSFLINE.ASI_CRM_CN_Estimate_Purchase_Value__c = 0;
            FirstPSFLINE.ASI_CRM_CN_Rebate_Percent__c = 1;
            BRSFLineInsert.add(FirstPSFLINE);
            //second psf module line
            ASI_CRM_CN_Contract_BRSF_Line_Item__c SecondPSFLINE = createBRSFLine('PSF', BRSFLineRtId, contract.Id, secondPsfModule.Id, PSFActivityCodeId);
            SecondPSFLINE.ASI_CRM_CN_Rebate_Percent__c = 0.5;
            SecondPSFLINE.ASI_CRM_Volume_Base__c = secondPsfModule.ASI_CRM_Volume_Base__c;
            SecondPSFLINE.ASI_CRM_CN_Contract_Purchase_Value__c = 0;
            SecondPSFLINE.ASI_CRM_CN_Estimate_Purchase_Value__c = 0;
            //SecondPSFLINE.ASI_CRM_CN_Min_Purchase_Target__c = 0;
            BRSFLineInsert.add(SecondPSFLINE);
        }
       

        if(Outlet.ASI_CRM_CN_NewChannel__c!=null && Outlet.ASI_CRM_CN_New_Image__c  !=null){
            for (ASI_CRM_SegmentationCriteria__c SCLine : [
                SELECT Id,ASI_CRM_Outlet_New_Image__c,ASI_CRM_Channel__c, (SELECT Id,ASI_CRM_Sub_Brand__c,ASI_CRM_Sub_Brand__r.Name,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c,ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name FROM Sub_Brand_Assignments__r)
                FROM ASI_CRM_SegmentationCriteria__c
                WHERE RecordType.DeveloperName = :'ASI_CRM_CN_Segmentation_Criteria_TOT_MOT_Contract'
                AND ASI_CRM_Region__c = :Outlet.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                AND ASI_CRM_CN_Channel_Group__c = :Outlet.ASI_CRM_Channel_Group__c
                AND ASI_CRM_Region__c != NULL AND ASI_CRM_CN_Channel_Group__c != NULL
            ])
            {
                for(ASI_CRM_Sub_Brand_Assignment__c  Assignments:SCLine.Sub_Brand_Assignments__r){

                    ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine;
                    if(oldModuleList.size() == 0){
                        BRSFLine = createBRSFLine('BRSF', BRSFLineRtId, contract.Id, Module.Id, BRSFActivityCodeId);
                    }else{
                        BRSFLine = createBRSFLine('BRSF', BRSFLineRtId, contract.Id, oldModuleList[0].Id, BRSFActivityCodeId);
                    }
                    BRSFLine.ASI_CRM_Sub_Brand_Grade__c = Assignments.ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;
                    BRSFLine.ASI_CRM_CN_Sub_Brand__c = Assignments.ASI_CRM_Sub_Brand__c;
                    BRSFLine.ASI_CRM_CN_Sub_Brand__r = Assignments.ASI_CRM_Sub_Brand__r;

                    BRSFLineInsert.add(BRSFLine);
                }
            }
            

        }

        return BRSFLineInsert;

    }


    public static ASI_CN_Trade_Margin__c getDefaultTradeMargin(String regionId, String channelGroupId, String outletRecordType){
        String type;
        if (outletRecordType == 'ASI_CRM_Outlet_CN') {
            type = 'T1 to Outlet';
        }
        if (outletRecordType == 'ASI_CRM_CN_WS') {
            type = 'T1 to T2';
        }

        List<ASI_CN_Trade_Margin__c> margins = [SELECT Id, ASI_CRM_CN_Default_Margin__c, ASI_CRM_CN_Max_Margin__c FROM ASI_CN_Trade_Margin__c
        WHERE
        ASI_CRM_CN_Region__r.Name = :regionId AND
        ASI_CRM_CN_Channel_Group__c= :channelGroupId AND
        Type__c = :type
        LIMIT 1];
        return (margins.size() == 1)? margins.get(0) : null;
    }

    public static ASI_CRM_CN_Contract_BRSF_Line_Item__c createBRSFLine(String type, String RecordTypeId, String contractId, String moduleId, String activityCode) {
        ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c = contractId,
            ASI_CRM_Module__c = moduleId,
            ASI_CRM_CN_Activity_Code__c = String.isNotEmpty(activityCode) ? activityCode : null,
            ASI_CRM_Type__c = type,
            RecordTypeId = RecordTypeId,
            ASI_CRM_CN_Contract_Monthly_Qty__c = 0,
            ASI_CRM_CN_Est_Monthly_Qty__c = 0,
            ASI_CRM_Contract_Total_QTY_std_Btl__c = 0,
            ASI_CRM_Est_Total_QTY_std_Btl__c = 0,
            ASI_CRM_CN_Contract_Total_Dummy__c = 0,
            ASI_CRM_CN_Est_Total_Dummy__c = 0
        );
        return lineItem;
    }

    /**
     * Calculate Rebate Percentage By Ladder.
     * If min <= purchaseValue < max, result = (purchaseValue || cappedValue) * rebatePercent / 100
     *
     * @param min
     * @param max
     * @param purchaseValue
     * @param rebatePercent
     * @param isCapped
     * @param cappedValue
     *
     * @return
     */
    public static Decimal calculateRebatePercentByLadder(Decimal min, Decimal max, Decimal purchaseValue, Decimal rebatePercent, Boolean isCapped, Decimal cappedValue){
        isCapped = isCapped == null ? false :isCapped;
        min = min == null? 0 : min;

        if (purchaseValue >= min && (max == null || purchaseValue < max)) {
            return (isCapped ? cappedValue : purchaseValue) * rebatePercent / 100;
        } else {
            return 0;
        }
    }

    public static List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> copyGroupPOToContract(ASI_TH_CRM_Contract__c contract, Id groupPOId) {
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> newLineItems = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        List<ASI_CRM_Module__c> modules = [
            SELECT
                Id,
                ASI_CRM_CN_Contract_Volume_Base__c,
                ASI_CRM_CN_Volume_Value_Base__c,
                ASI_CRM_CN_Total_Markup__c,
                RecordTypeId,
                ASI_CRM_Remark__c, (
                SELECT
                    ASI_CRM_Type__c,
                    ASI_CRM_CN_Activity_Code__c,
                    ASI_CRM_CN_Contract__c,
                    ASI_CRM_CN_Sub_Brand__c,
                    ASI_CRM_Sub_Brand_Grade__c,
                    ASI_CRM_CN_Contract_Monthly_Qty__c,
                    ASI_CRM_CN_Est_Monthly_Qty__c,
                    ASI_CRM_Contract_Total_QTY_std_Btl__c,
                    ASI_CRM_Est_Total_QTY_std_Btl__c,
                    ASI_CRM_CN_Contract_Total_Dummy__c,
                    ASI_CRM_CN_Est_Total_Dummy__c,RecordTypeId
                FROM Contract_BRSF_Line_Item__r
            )
            FROM ASI_CRM_Module__c
            WHERE ASI_CRM_Contract__c = :groupPOId
            LIMIT 1
        ];
        ASI_CRM_Module__c groupPOModule = (modules.size() == 1)? modules.get(0) : null;

        if (groupPOModule != null) {
            ASI_CRM_Module__c module = new ASI_CRM_Module__c(
                ASI_CRM_CN_Contract_Volume_Base__c = groupPOModule.ASI_CRM_CN_Contract_Volume_Base__c,
                ASI_CRM_CN_Volume_Value_Base__c = groupPOModule.ASI_CRM_CN_Volume_Value_Base__c,
                ASI_CRM_CN_Total_Markup__c = groupPOModule.ASI_CRM_CN_Total_Markup__c,
                ASI_CRM_Remark__c = groupPOModule.ASI_CRM_Remark__c,
                RecordTypeId = groupPOModule.RecordTypeId,
                ASI_CRM_Line_Type__c = 'BRSF',
                ASI_CRM_Contract__c = contract.Id
            );

            insert module;

            System.debug(groupPOModule.Contract_BRSF_Line_Item__r.size());
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : groupPOModule.Contract_BRSF_Line_Item__r) {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c newLineItem = lineItem.clone(false, true);
                newLineItem.ASI_CRM_CN_Contract__c = contract.Id;
                newLineItem.ASI_CRM_Module__c = module.Id;
                newLineItems.add(newLineItem);
            }

        }
        System.debug(newLineItems.size());
        return newLineItems;

    }

       //Retrieve  Check Point Criteria Map   : Channel + Division > Region + Channel > Division > Region > Channel         //.size()
    public static Map<String,ASI_CRM_SegmentationCriteria__c> RetrieveCheckPointCriteriaMap(ASI_TH_CRM_Contract__c contract, String RecordTypeName)
    {
        String SoqlStatement ='select Id,ASI_CRM_Floating_Interval_Percent_Up__c,ASI_CRM_Floating_Interval_Percent_Down__c , ASI_CRM_Floating_Interval_Down__c,ASI_CRM_Floating_Interval_Up__c,ASI_CRM_Max_Value__c,ASI_CRM_Min_Value__c, ASI_CRM_RVP_Special_Approval__c,ASI_CRM_Alignment_Value__c,ASI_CRM_Operation__c,AS_CRM_Predefined_Theoretical_Value__c,ASI_CRM_Alignment_Percentage__c,ASI_CRM_1st_Dimension__c,ASI_CRM_2nd_Dimension__c,ASI_CRM_Region__c,ASI_CRM_Channel__c,ASI_CRM_CN_Channel_Group__c,ASI_CRM_Division__c,ASI_CRM_Financial_Indicator__c,ASI_CRM_Region__r.name,ASI_CRM_Chinese_Interpretation__c,ASI_CRM_English_Interpretation__c '+ ' from ASI_CRM_SegmentationCriteria__c where RecordType.DeveloperName= \''+RecordTypeName+'\'  ';
        //Financial Indicator, Segmentation Criteria
        Map<String,ASI_CRM_SegmentationCriteria__c> SegmentationCriteriaMap = new Map<String,ASI_CRM_SegmentationCriteria__c>();



        String regionName = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c;
        Id channelGroupId = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Channel_Group__c;

        String AddOnStatement=' and ASI_CRM_Region__r.name = \''+ regionName +'\'  and ASI_CRM_CN_Channel_Group__c = \''+channelGroupId+'\'';
        SegmentationCriteriaMap=SQLSegmentationCriteria(SegmentationCriteriaMap,SoqlStatement+ AddOnStatement );
        System.debug('Enter SQL 2'+SoqlStatement+ AddOnStatement);


        return SegmentationCriteriaMap;
    }
    public static Map<String,ASI_CRM_SegmentationCriteria__c> SQLSegmentationCriteria (Map<String,ASI_CRM_SegmentationCriteria__c> SCMap, String Statement) {
        for (ASI_CRM_SegmentationCriteria__c SegmentationCriteria : Database.query(Statement)) {
            SCMap.put(SegmentationCriteria.Id, SegmentationCriteria);
        }
        return SCMap;
    }


    // Getting Historical Actual Payment in ParentModule
    public static Map<String,Decimal> GetHistoricalModuleAmount(List<ASI_CRM_Module__c> HistoricalPaidModulelist){
        Map<String,Decimal> HistoricalModuleMap = new Map<String,Decimal>();

        String PSFModuleId='';
        String VECModuleId='';

        //list<ASI_CRM_Module__c> HistoricalPaidModulelist = HistoricalModuleQuerying(ParentModuleSet , CurrentPaymentId);
        for(ASI_CRM_Module__c ModuleItem:HistoricalPaidModulelist){
            if(HistoricalModuleMap.containsKey(ModuleItem.ASI_CRM_Parent_Module__c)){
                Decimal TempAmount= HistoricalModuleMap.get(ModuleItem.ASI_CRM_Parent_Module__c) !=null? HistoricalModuleMap.get(ModuleItem.ASI_CRM_Parent_Module__c) : 0;
                TempAmount =TempAmount+ModuleItem.ASI_CRM_Actual_Payment__c;
                HistoricalModuleMap.remove(ModuleItem.ASI_CRM_Parent_Module__c);
                HistoricalModuleMap.put(ModuleItem.ASI_CRM_Parent_Module__c, TempAmount);
            }else{
                HistoricalModuleMap.put(ModuleItem.ASI_CRM_Parent_Module__c,ModuleItem.ASI_CRM_Actual_Payment__c);
            }

            if(ModuleItem.ASI_CRM_Line_Type__c=='PSF' && PSFModuleId==''){
                PSFModuleId=ModuleItem.ASI_CRM_Parent_Module__c;
            }
            if(ModuleItem.ASI_CRM_Line_Type__c=='Display' && VECModuleId ==''){
                VECModuleId=ModuleItem.ASI_CRM_Parent_Module__c;
            }
        }


        return HistoricalModuleMap;
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
            this.POEstimatedAmount = 0;
            this.LastVersion_POEstimatedAmount = 0;
            this.PaidAmount = 0;
            this.PaymentRequestAmount = 0;
        }
        public PaymentSummary(String name){
            this.Name = name;
            this.POEstimatedAmount = 0;
            this.LastVersion_POEstimatedAmount = 0;
            this.PaidAmount = 0;
            this.PaymentRequestAmount = 0;
        }
        public PaymentSummary(String activityCodeId, String name,String englishDescription, Decimal POEstimatedAmount) {
            this.ACCodeId = activityCodeId;
            this.Name = name;
            this.EnglishDescription = englishDescription;
            this.POEstimatedAmount = POEstimatedAmount != null? POEstimatedAmount : 0;
        }
        public PaymentSummary(ASI_CRM_Contract_Cost__c contractCost) {
            ACCodeId = contractCost.ASI_CRM_CN_Activity_Code__c;
            Name = contractCost.ASI_CRM_CN_Chinese_Description__c;
            EnglishDescription = contractCost.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c;
            //POEstimatedAmount = contractCost.ASI_CRM_CN_Estimate_Amount__c != null? ContractCost.ASI_CRM_CN_Estimate_Amount__c : 0;
        }
    }

    //For PO Modification Page PDF
    public static List<PaymentSummary> PaymentSummaryTable( ASI_TH_CRM_Contract__c contract){
        Map<String,PaymentSummary> PaymentSummaryMap = new Map<String,PaymentSummary> ();
        String PSFName='合同奖励';
        String DisplayName = '常规陈列费';
        Id lastContractID; // Last version  Contract Id
        if(contract!=null){
            lastContractID = contract.ASI_CRM_CN_Last_PO_version__c;
        }

        //Contract Cost Setting
        for(ASI_CRM_Contract_Cost__c ContractCost:[SELECT id, name,ASI_CRM_Other_Est__c,ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c
        											FROM ASI_CRM_Contract_Cost__c
        											WHERE ASI_CRM_CN_Contract__c = :contract.Id
        											OR ASI_CRM_CN_Contract__c=:lastContractID
        											ORDER BY ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC])
        {
        	PaymentSummary paymentSummaryData = PaymentSummaryMap.containsKey(ContractCost.ASI_CRM_CN_Chinese_Description__c) ? PaymentSummaryMap.get(ContractCost.ASI_CRM_CN_Chinese_Description__c) : new PaymentSummary(ContractCost);
                if(ContractCost.ASI_CRM_CN_Contract__c==lastContractID){
        		paymentSummaryData.LastVersion_POEstimatedAmount += ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
                }else{
            	paymentSummaryData.POEstimatedAmount += ContractCost.ASI_CRM_CN_Estimate_Amount__c !=null? ContractCost.ASI_CRM_CN_Estimate_Amount__c:0;
            }
            PaymentSummaryMap.put(paymentSummaryData.Name, paymentSummaryData);
        }

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:[SELECT id,
          															ASI_CRM_CN_Activity_Code__c,
																	ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
																	ASI_CRM_CN_Contract_Monthly_Qty__c,
																	ASI_CRM_CN_Contract_Total_Dummy__c,
																	ASI_CRM_CN_Contract_Total__c,
																	ASI_CRM_CN_Contract__c,
																	ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
																	ASI_CRM_CN_Est_Monthly_Qty__c,
																	ASI_CRM_CN_Est_Total_Dummy__c,
																	ASI_CRM_CN_Est_Total__c,
																	ASI_CRM_CN_No_of_Months__c,
																	ASI_CRM_CN_Sub_Brand__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
																	ASI_CRM_CN_Sub_Brand__r.Name,
																	ASI_CRM_Key_Sub_brand__c,
																	ASI_CRM_Module__c,
																	ASI_CRM_Product_Category__c,
																	ASI_CRM_Sub_Brand_Grade__c,
																	ASI_CRM_Type__c,
																	ASI_CRM_Volume_Base__c
        														FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        														WHERE ASI_CRM_CN_Contract__c = :contract.Id
        														OR ASI_CRM_CN_Contract__c=:lastContractID  ] )
        {

            if(ContractLine.ASI_CRM_Type__c=='PSF'){
                if(PaymentSummaryMap.containsKey(PSFName)){
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        PaymentSummaryMap.get(PSFName).LastVersion_POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name=PSFName;
                    tempData.EnglishDescription='PRC - PSF & Trading Term Incentives';
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        tempData.LastVersion_POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                    PaymentSummaryMap.put(PSFName, tempData);
                }
            }

            if(ContractLine.ASI_CRM_Type__c=='Display'){
                if(PaymentSummaryMap.containsKey(DisplayName)){
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        PaymentSummaryMap.get(DisplayName).LastVersion_POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                }else{
                    PaymentSummary tempData= new PaymentSummary();
                    tempData.ACCodeId=ContractLine.ASI_CRM_CN_Activity_Code__c;
                    tempData.Name= DisplayName;
                    tempData.EnglishDescription='PRC - Display';
                    if(ContractLine.ASI_CRM_CN_Contract__c==lastContractID){
                        tempData.LastVersion_POEstimatedAmount=ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
                    }
                    PaymentSummaryMap.put(DisplayName, tempData);
                }
            }
        }//End of looping  Contract Line

        //ASI_CRM_CN_Expected_BRSF_Est_Total__c

        if(PaymentSummaryMap.containsKey(PSFName)){
            if(contract.ASI_CRM_CN_PO_Version__c!='0.1' && contract.ASI_CRM_Copied_From__c!=null ){
                PaymentSummaryMap.get(PSFName).LastVersion_POEstimatedAmount=contract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c;
            }
            PaymentSummaryMap.get(PSFName).POEstimatedAmount +=contract.ASI_CRM_CN_Expected_PSF_Est_Total__c!=null? contract.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        }

        if(!contract.ASI_CRM_CN_Is_Dolphin__c){
            if(PaymentSummaryMap.containsKey(DisplayName)){
                if(contract.ASI_CRM_CN_PO_Version__c!='0.1' && contract.ASI_CRM_Copied_From__c!=null  ){
                    PaymentSummaryMap.get(DisplayName).LastVersion_POEstimatedAmount=contract.ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c;
                }
                PaymentSummaryMap.get(DisplayName).POEstimatedAmount = contract.ASI_CRM_CN_Expected_Display_Est_Total__c!=null? contract.ASI_CRM_CN_Expected_Display_Est_Total__c:0;
            }
        }

        //RecordType.DeveloperName like 'ASI_CRM_CN%'
        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [SELECT id, name,ASI_TH_CRM_Payment_Request__r.Name, RecordType.DeveloperName,ASI_CRM_CN_Total_Payable__c, recordtypeid, ASI_TH_CRM_Amount__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_AC_Code__c
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

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){
                        PaymentSummaryKey=PSFName;
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Display'){
                        PaymentSummaryKey= DisplayName;
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

                if(module.ASI_CRM_Line_Type__c=='Display'){
                    if(PaymentSummaryMap.containsKey(DisplayName)){
                        PaymentSummaryMap.get(DisplayName).PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name= DisplayName;
                        tempData.PaymentRequestAmount=module.ASI_CRM_Actual_Payment__c!=null? module.ASI_CRM_Actual_Payment__c:0;
                        PaymentSummaryMap.put(DisplayName, tempData);
                    }
                }

            }
        }

        List<PaymentSummary> PaymentSummaryList= new List<PaymentSummary>();

        for(string key:PaymentSummaryMap.keySet()){
            PaymentSummaryList.add(PaymentSummaryMap.get(key));
        }



        return PaymentSummaryList;
    }

    //For Payment View Page
    public static List<PaymentSummary> PaymentSummaryTable(ASI_TH_CRM_PaymentRequest__c payment, ASI_TH_CRM_Contract__c contract){
        Map<String,PaymentSummary> PaymentSummaryMap = new Map<String,PaymentSummary> ();
        String PSFName='合同奖励';
        String DisplayName = '常规陈列费';

        //******************************************Contract Line******************************************
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : [
            SELECT Id,ASI_CRM_Type__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_Activity_Code__c
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
            WHERE ASI_CRM_CN_Contract__c = :contract.Id
            ORDER BY ASI_CRM_Type__c
        ]) {

            String paymentSummaryName = '';
            if (ContractLine.ASI_CRM_Type__c == 'PSF') {
                paymentSummaryName = PSFName;
            } else if (ContractLine.ASI_CRM_Type__c == 'Display') {
                paymentSummaryName = DisplayName;
            }
            if (String.isEmpty(paymentSummaryName)) {
                continue;
            }

            PaymentSummary paymentSummary = PaymentSummaryMap.containsKey(paymentSummaryName)? PaymentSummaryMap.get(paymentSummaryName) : new PaymentSummary(ContractLine.ASI_CRM_CN_Activity_Code__c, paymentSummaryName,'',0);
            paymentSummary.POEstimatedAmount += ContractLine.ASI_CRM_CN_Est_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Est_Total_Dummy__c:0;
            if (!PaymentSummaryMap.containsKey(paymentSummaryName)) {
                PaymentSummaryMap.put(paymentSummaryName, paymentSummary);
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
            if(PaymentSummaryMap.containsKey(DisplayName)){
                PaymentSummaryMap.get(DisplayName).POEstimatedAmount = contract.ASI_CRM_CN_Expected_Display_Est_Total__c!=null? contract.ASI_CRM_CN_Expected_Display_Est_Total__c:0;
            }else{
                PaymentSummary tempData= new PaymentSummary();
                tempData.Name=DisplayName;
                tempData.POEstimatedAmount= contract.ASI_CRM_CN_Expected_Display_Est_Total__c!=null?  contract.ASI_CRM_CN_Expected_Display_Est_Total__c:0;
                PaymentSummaryMap.put(DisplayName, tempData);
            }

        }

        //*********************Contract Cost Looping******************************************
        for (ASI_CRM_Contract_Cost__c ContractCost : [
            SELECT Id, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Estimate_Amount__c
            FROM ASI_CRM_Contract_Cost__c
            WHERE ASI_CRM_CN_Contract__c = :contract.Id
            ORDER BY ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC
        ]) {

            if (PaymentSummaryMap.containsKey(ContractCost.ASI_CRM_CN_Chinese_Description__c)) {
                PaymentSummaryMap.get(ContractCost.ASI_CRM_CN_Chinese_Description__c).POEstimatedAmount += ContractCost.ASI_CRM_CN_Estimate_Amount__c != null? ContractCost.ASI_CRM_CN_Estimate_Amount__c : 0;
            } else { // dont contain in the map
                PaymentSummary tempData = new PaymentSummary();
                tempData.ACCodeId = ContractCost.ASI_CRM_CN_Activity_Code__c;
                tempData.Name = ContractCost.ASI_CRM_CN_Chinese_Description__c;
                tempData.POEstimatedAmount = ContractCost.ASI_CRM_CN_Estimate_Amount__c != null? ContractCost.ASI_CRM_CN_Estimate_Amount__c : 0;
                PaymentSummaryMap.put(tempData.Name, tempData);
            }
        }



        //RecordType.DeveloperName like 'ASI_CRM_CN%'
        for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: [SELECT id, name,ASI_TH_CRM_Payment_Request__r.Name,ASI_CRM_CN_Total_Payable__c,ASI_TH_CRM_Payment_Request__c, RecordType.DeveloperName, recordtypeid, ASI_TH_CRM_Amount__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_AC_Code__c
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

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){
                        PaymentSummaryKey=PSFName;
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentLine.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_Display'){
                        PaymentSummaryKey= DisplayName;
                        PaymentAmount=PaymentLine.ASI_TH_CRM_Amount__c!=null? PaymentLine.ASI_TH_CRM_Amount__c:0;
                    }

                    if(PaymentSummaryMap.containsKey(PaymentSummaryKey)){
                        if(PaymentLine.ASI_TH_CRM_Payment_Request__c==payment.Id){
                            PaymentSummaryMap.get(PaymentSummaryKey).PaymentRequestAmount +=PaymentAmount;
                        }
                        else {
                            PaymentSummaryMap.get(PaymentSummaryKey).PaidAmount +=PaymentAmount;
                        }
                    }else{
                        PaymentSummary tempData= new PaymentSummary();
                        tempData.Name=PaymentSummaryKey;
                        if(PaymentLine.ASI_TH_CRM_Payment_Request__c==payment.Id){
                            tempData.PaymentRequestAmount=PaymentAmount;
                        }
                        else {
                            tempData.PaidAmount=PaymentAmount;
                        }
                        PaymentSummaryMap.put(PaymentSummaryKey, tempData);
                    }
                }
            }


        }



        // Calculate Payment Request Amount and Paid Amount
        // Payment Request Amount = Sum of current payment
        // Payment Request Amount = Sum of previous payment
        for(ASI_TH_CRM_PaymentRequest__c PaymentRequest : [SELECT Id,Name,ASI_TH_CRM_Status__c,(SELECT Id,ASI_CRM_Line_Type__c,ASI_CRM_Actual_Payment__c,ASI_CRM_Payment_Request__c FROM ASI_CRM_Modules__r)
        FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = :contract.Id AND
        (ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted' OR ASI_TH_CRM_Status__c = 'Paid' OR Id= :payment.Id )])
        {
            for(ASI_CRM_Module__c module:PaymentRequest.ASI_CRM_Modules__r){

                String paymentSummaryName = '';
                if (module.ASI_CRM_Line_Type__c == 'PSF') {
                    paymentSummaryName = PSFName;
                } else if (module.ASI_CRM_Line_Type__c == 'Display') {
                    paymentSummaryName = DisplayName;
                }
                if (String.isEmpty(paymentSummaryName)) {
                    continue;
                }

                PaymentSummary paymentSummary = PaymentSummaryMap.containsKey(paymentSummaryName)? PaymentSummaryMap.get(paymentSummaryName) : new PaymentSummary(paymentSummaryName);
                paymentSummary.PaymentRequestAmount += module.ASI_CRM_Actual_Payment__c != null && PaymentRequest.Id == payment.Id? module.ASI_CRM_Actual_Payment__c : 0;
                paymentSummary.PaidAmount += module.ASI_CRM_Actual_Payment__c != null && PaymentRequest.Id != payment.Id? module.ASI_CRM_Actual_Payment__c : 0;

                PaymentSummaryMap.put(paymentSummaryName, paymentSummary);
            }
        }

        List<PaymentSummary> PaymentSummaryList= new List<PaymentSummary>();

        for (string key : PaymentSummaryMap.keySet()) {
            PaymentSummary paymentSummary = PaymentSummaryMap.get(key);
            if (paymentSummary.POEstimatedAmount != 0) {
                PaymentSummaryList.add(paymentSummary);
            }
    }

        return PaymentSummaryList;
    }

    /**
     * Compare values in 2 map. Return true if every element in first map fulfills the operation against the element in second map
     *
     * @param map1
     * @param map2
     * @param operation One of the following values: Equal to, Greater than, Greater than or Equal to, Less than, Less than or Equal to
     *
     * @return
     */

    public static Boolean compareMap(Map<String, Decimal> map1, Map<String, Decimal> map2, String operation){
        for (String key : map1.keySet()) {
            Decimal value1 = map1.get(key);
            Decimal value2 = map2.get(key);

            // if second map doesn't have this key, skip comparision
            if(value2 == null){
                continue;
            }

            switch on operation {
                when 'Equal to' {
                    if (value1 == value2) {
                        continue;
                    } else {
                        return false;
                    }
                }
                when 'Greater than' {
                    if (value1 > value2) {
                        continue;
                    } else {
                        return false;
                    }
                }
                when 'Greater than or Equal to' {
                    if (value1 >= value2) {
                        continue;
                    } else {
                        return false;
                    }
                }
                when 'Less than' {
                    if (value1 < value2) {
                        continue;
                    } else {
                        return false;
                    }
                }
                when 'Less than or Equal to' {
                    if (value1 <= value2) {
                        continue;
                    } else {
                        return false;
                    }
                }
            }
        }

        // if all element pass the comparision, return true
        return true;
    }

}