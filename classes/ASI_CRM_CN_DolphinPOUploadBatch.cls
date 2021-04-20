global without sharing class ASI_CRM_CN_DolphinPOUploadBatch implements Database.Batchable<sObject> {
    public String query;
    public String eventId;
    public static Map<String, String> storeTypeMap = new Map<String, String>{
        'Dolphin A' => 'A',
        'Dolphin B' => 'B',
        'Dolphin C' => 'C',
        'Dolphin Division' => 'Dolphin Division',
        'Falcon' => ''
    };
    public static Id LINE_RT_ID = Schema.getGlobalDescribe().get('ASI_CRM_CN_Contract_BRSF_Line_Item__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ASI_CRM_CRM_CN_Contract_Heavy_BRSF').getRecordTypeId();
    public static Id TOT_CONTRACT_RT_ID = Schema.getGlobalDescribe().get('ASI_TH_CRM_Contract__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ASI_CRM_CN_Contract').getRecordTypeId();
    global ASI_CRM_CN_DolphinPOUploadBatch() {
        this.query = query;
        this.eventId = eventId;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<ASI_MFM_Mass_Upload_Log__c> scope) {
        ASI_MFM_Mass_Upload_Log__c mup = scope[0];
        System.debug(LoggingLevel.INFO, '*** mup.ASI_CRM_Result__c: ' + mup.ASI_CRM_Result__c);
        ASI_TH_CRM_Contract__c newCont = new ASI_TH_CRM_Contract__c();
        SavePoint sp = Database.setSavePoint();
        ASI_CRM_AccountsAdditionalField__c customer =  new ASI_CRM_AccountsAdditionalField__c(); 
        try {
        ASI_CRM_CN_DolphinPOUploadCtl.DolphinPO dolPO = (ASI_CRM_CN_DolphinPOUploadCtl.DolphinPO)JSON.deserialize(mup.ASI_CRM_Result__c, ASI_CRM_CN_DolphinPOUploadCtl.DolphinPO.class);
        System.debug('*** dolPO: ' + JSON.serializePretty(dolPO) + '');
                                                customer = [SELECT Id, 
                                                              Name,
                                                              ASI_CRM_CN_DolphinFalcon_Flag__c,
                                                              ASI_CRM_CN_NewChannel__c,
                                                              ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c,
                                                              ASI_CRM_CN_CCity__c,
                                                              ASI_CRM_CN_Region__c,
                                                              ASI_CRM_CN_Commercial_Team__c,
                                                              ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                        FROM ASI_CRM_AccountsAdditionalField__c
                                                        WHERE Id =:dolPO.outletId];
        Document DocumentFile;
        if (!Test.isRunningTest()) {
            DocumentFile = ASI_CRM_CN_HeavyContracFunctionClass.GenerateGeneralContractTemplate('offDolphin',customer.ASI_CRM_CN_Region__c,false);
        }

        Decimal amountTotal = 0;
        Set<Id> SubBrandIdSet = new Set<Id>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> insertBRSFLineItems = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();

        for (ASI_CRM_CN_DolphinPOUploadCtl.SubbrandInfo sub: dolPO.subbrands) {
            SubBrandIdSet.add(sub.subBrandId);
            ASI_CRM_CN_Contract_BRSF_Line_Item__c line = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
            line.ASI_CRM_CN_Sub_Brand__c = sub.subBrandId;
            line.ASI_CRM_CN_Contract_Total_Dummy__c = sub.subbrandPurchaseValue;
            line.ASI_CRM_CN_Est_Total_Dummy__c = sub.subbrandPurchaseValue;
            line.ASI_CRM_CN_Contract_Monthly_Qty__c = sub.subbrandBtl;
            line.ASI_CRM_CN_Est_Monthly_Qty__c = sub.subbrandBtl;
            line.RecordTypeId = LINE_RT_ID;
            line.ASI_CRM_Type__c = 'BRSF';
            insertBRSFLineItems.add(line);
        }
        newCont.ASI_CRM_CN_Outlet_WS__c = dolPO.outletId;
        newCont.ASI_CRM_CN_PO_Start_Date__c = convertDate(dolPO.startDate);
        newCont.ASI_CRM_CN_PO_End_Date__c = convertDate(dolPO.endDate);
        newCont.OwnerId = dolPO.ownerId;
        Integer iNoMonth = newCont.ASI_CRM_CN_PO_Start_Date__c.monthsBetween(newCont.ASI_CRM_CN_PO_End_Date__c.addMonths(1));
        newCont.ASI_TH_CRM_Promotion_Type__c = 'TOT/MOT Contract';
        newCont.ASI_CRM_CN_Source_of_Contract__c = 'Renew';
        newCont.ASI_CRM_CN_Description__c = dolPO.description;
        newCont.ASI_CRM_CN_Use_PRC_Contract_Template__c = dolPO.usePRCTemplate == 'TRUE';
        newCont.ASI_CRM_CN_Vol_Budget_LE__c = 0;
        newCont.ASI_CRM_CN_Budget_LE__c = 0;
        newCont.ASI_CRM_CN_Reason_without_Budget__c = null;
        newCont.ASI_CRM_PO_Channel__c = customer.ASI_CRM_CN_NewChannel__c;
        newCont.ASI_CRM_PO_Province__c = customer.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
        newCont.ASI_CRM_PO_City__c = customer.ASI_CRM_CN_CCity__c;
        newCont.ASI_CRM_CN_Is_Dolphin__c = true;
        newCont.ASI_CRM_CN_Contract_Classification__c = storeTypeMap.get(customer.ASI_CRM_CN_DolphinFalcon_Flag__c);
        newCont.ASI_CRM_CN_Target_Base__c = dolPO.volumeBase;
        newCont.ASI_CRM_CN_Activity_Times__c = Decimal.valueOf(dolPO.activityTimes);
        newCont.RecordTypeId = TOT_CONTRACT_RT_ID;
        newCont.ASI_CRM_CN_Expected_V0_Display_Est_Total__c = 0;
        newCont.ASI_CRM_CN_Expected_Display_Est_Total__c = 0;
        newCont.ASI_CRM_CN_V0_Display_Contract_Total__c = 0;
        newCont.ASI_CRM_Contract_Template_Id__c = DocumentFile!=null?DocumentFile.Id:null;
        newCont.Name = 'Automated, Do not Change';
        String volumeBase = calculateBRSFLine(insertBRSFLineItems, 
                            newCont, 
                            customer.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,SubBrandIdSet, 
                            iNoMonth);
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : insertBRSFLineItems) {
            amountTotal += lineItem.ASI_CRM_CN_Contract_Total_Dummy__c == null?0:lineItem.ASI_CRM_CN_Contract_Total_Dummy__c;
        }
        Decimal psfTotal = amountTotal * (dolPO.psfModule2Rate + 1)/100;

        newCont.ASI_CRM_Expected_V0_PSF_Estimated_Total__c = psfTotal;
        newCont.ASI_CRM_CN_Expected_PSF_Est_Total__c = psfTotal;
        newCont.ASI_CRM_V0_PSF_Contract_Total__c = psfTotal;


        // 计算PSF line Item相关信息
        Map<String, Decimal> CR12FactorMap = ASI_CRM_CN_OffContractUtilitiesClass.GenerateCR12FactorMap(SubBrandIdSet,
                 customer.ASI_CRM_CN_Commercial_Team__c, 
                 customer.ASI_CRM_CN_Region__c);

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
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c line : insertBRSFLineItems) {
            Decimal CR12Factor = CR12FactorMap.containsKey(line.ASI_CRM_CN_Sub_Brand__c)? CR12FactorMap.get(line.ASI_CRM_CN_Sub_Brand__c) : 1;
            tempLine.ASI_CRM_CN_Est_Monthly_Qty__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c;
            tempLine.ASI_CRM_Est_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor;
            
            if (line.ASI_CRM_Est_Total_QTY_std_Btl__c != null) {
                tempLine.ASI_CRM_Est_Total_QTY_std_Btl__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c;
                tempLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += line.ASI_CRM_Est_Total_QTY_std_Btl__c * CR12Factor;
            } else {
                tempLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * CR12Factor * iNoMonth;
                tempLine.ASI_CRM_Est_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Est_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Est_Monthly_Qty__c * iNoMonth;
            }

            tempLine.ASI_CRM_CN_Contract_Monthly_Qty__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c;
            tempLine.ASI_CRM_Contract_Monthly_Volume_CR12__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor;
            tempLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * CR12Factor * iNoMonth;
            tempLine.ASI_CRM_Contract_Total_QTY_std_Btl__c += (line.ASI_CRM_CN_Contract_Monthly_Qty__c == null)? 0 : line.ASI_CRM_CN_Contract_Monthly_Qty__c * iNoMonth;
        }
        insert newCont;
        
        System.debug(LoggingLevel.INFO, '*** newCont.Id: ' + newCont.Id);
        List<ASI_CRM_Module__c> insertModules = new List<ASI_CRM_Module__c>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> insertLineItems = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        ASI_CRM_Methodology__c defaultMethodology = [SELECT Id,Name 
                                                     FROM ASI_CRM_Methodology__c 
                                                     WHERE ASI_CRM_Type__c = 'PSF' AND 
                                                        ASI_CRM_CN_KPI_Base__c = 'Value Base' AND 
                                                        Name  = 'Rebate%' AND 
                                                        Recordtype.Developername = 'ASI_CRM_CN_Methodology_TOT_MOT_Contract' 
                                                     Limit 1];


        insertModules.add(new ASI_CRM_Module__c(
                ASI_CRM_Line_Type__c = 'BRSF',
                ASI_CRM_Contract__c = newCont.Id,
                ASI_CRM_CN_Volume_Value_Base__c = volumeBase,
                ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan',
                ASI_CRM_CN_Total_Markup__c = 2,
                OwnerId = dolPO.ownerId
            ));
        ASI_CRM_Module__c psfModule1 = generatePSFModule(defaultMethodology?.Id, newCont.Id);
        psfModule1.ASI_CRM_CN_Minimal_Achievement__c = 0;
        psfModule1.OwnerId = dolPO.ownerId;
        insertModules.add(psfModule1);
        ASI_CRM_Module__c psfModule2 = generatePSFModule(defaultMethodology?.Id, newCont.Id);
        psfModule2.ASI_CRM_CN_Minimal_Achievement__c = dolPO.psfModule2MinAchievement;
        psfModule2.OwnerId = dolPO.ownerId;

        insertModules.add(psfModule2);


        insert insertModules;
        System.debug('*** insertModules: ' + JSON.serializePretty(insertModules) + '');
        for (Integer i=0; i<insertModules.size(); i++) {
            ASI_CRM_Module__c module = insertModules[i];
            if (module.ASI_CRM_Line_Type__c == 'PSF') {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c psfLineItem1 = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
                psfLineItem1.RecordTypeId = LINE_RT_ID;
                psfLineItem1.ASI_CRM_Type__c = 'PSF';
                psfLineItem1.ASI_CRM_Volume_Base__c = 'By Total';
                psfLineItem1.ASI_CRM_Module__c = module.Id;
                psfLineItem1.ASI_CRM_CN_Contract__c = newCont.Id;
                psfLineItem1.ASI_CRM_CN_Contract_Purchase_Value__c = amountTotal.setScale(2);
                psfLineItem1.ASI_CRM_CN_Estimate_Purchase_Value__c = amountTotal.setScale(2);
                if (i == 1) {
                    psfLineItem1.ASI_CRM_CN_Rebate_Percent__c = 1;
                    psfLineItem1.ASI_CRM_CN_Contract_Total_Dummy__c = amountTotal * (0.01);
                    psfLineItem1.ASI_CRM_CN_Est_Total_Dummy__c = amountTotal * (0.01);            
                } else {
                    psfLineItem1.ASI_CRM_CN_Rebate_Percent__c = dolPO.psfModule2Rate;
                    System.debug(LoggingLevel.INFO, '*** psfLineItem1.ASI_CRM_CN_Rebate_Percent__c: ' + psfLineItem1.ASI_CRM_CN_Rebate_Percent__c);
                    psfLineItem1.ASI_CRM_CN_Contract_Total_Dummy__c = amountTotal * (psfLineItem1.ASI_CRM_CN_Rebate_Percent__c/100);
                    psfLineItem1.ASI_CRM_CN_Est_Total_Dummy__c = amountTotal * (psfLineItem1.ASI_CRM_CN_Rebate_Percent__c/100);
                    psfLineItem1.ASI_CRM_CN_Rebate_Percent__c = psfLineItem1.ASI_CRM_CN_Rebate_Percent__c.setScale(2);
                }
                psfLineItem1.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = tempLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                psfLineItem1.ASI_CRM_CN_Contract_Monthly_Qty__c = tempLine.ASI_CRM_CN_Contract_Monthly_Qty__c;
                psfLineItem1.ASI_CRM_CN_Est_BRSF_Per_Bottle__c = tempLine.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                psfLineItem1.ASI_CRM_CN_Est_Monthly_Qty__c = tempLine.ASI_CRM_CN_Est_Monthly_Qty__c;
                psfLineItem1.ASI_CRM_Contract_Total_QTY_std_Btl__c = tempLine.ASI_CRM_Contract_Total_QTY_std_Btl__c == null? 0 : tempLine.ASI_CRM_Contract_Total_QTY_std_Btl__c;
                psfLineItem1.ASI_CRM_Est_Total_QTY_std_Btl__c = tempLine.ASI_CRM_Est_Total_QTY_std_Btl__c == null? 0 : tempLine.ASI_CRM_Est_Total_QTY_std_Btl__c;
                psfLineItem1.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c = tempLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c == null? 0 : tempLine.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c;
                psfLineItem1.ASI_CRM_Est_Total_QTY_CR12_Eqv__c = tempLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c == null? 0 : tempLine.ASI_CRM_Est_Total_QTY_CR12_Eqv__c;
                insertLineItems.add(psfLineItem1);            
            } else {
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItems : insertBRSFLineItems) {
                    lineItems.ASI_CRM_Module__c = module.Id;
                    lineItems.ASI_CRM_CN_Contract__c = newCont.Id;
                    insertLineItems.add(lineItems);
                }

            }
        }
        insert insertLineItems;
        updateLogStatus(mup, newCont, 'Success', '', customer.Name);
        }
        catch (Exception e) {
            Database.rollback(sp);
            updateLogStatus(mup, newCont, 'Fail', e.getMessage()+e.getStackTraceString(), customer.Name);
        }
    }

    public static String calculateBRSFLine(List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> lines, 
                                        ASI_TH_CRM_Contract__c ContractSelected,
                                        String region,
                                        Set<Id> subBrandIds,
                                        Integer iNoMonth) {
        Date strStartBGDate = ContractSelected.ASI_CRM_CN_PO_Start_Date__c.addYears(-1);
        Date strEndBGDate = ASI_CRM_DateUtilClass.getFiscalYearEndDate(ContractSelected.ASI_CRM_CN_PO_End_Date__c);
        System.debug(LoggingLevel.INFO, '*** strStartBGDate: ' + strStartBGDate);
        System.debug(LoggingLevel.INFO, '*** strEndBGDate: ' + strEndBGDate);
        System.debug(LoggingLevel.INFO, '*** subBrandIds: ' + subBrandIds);
        String volumeBase = 'value';
        // Get GS List
        List<ASI_CRM_CM_GS__c> gsList = [
            SELECT Id, ASI_CRM_CM_GS_per_9L__c, ASI_CRM_PRODUCTCODE__c,ASI_CRM_YEAR__c,ASI_CRM_CN_Month__c
            FROM ASI_CRM_CM_GS__c
            WHERE ASI_CRM_PRODUCTCODE__c IN :subBrandIds
            AND ASI_CRM_Region__c = :region
            AND ASI_CRM_CN_Month_End_Date__c >= :strStartBGDate
            AND ASI_CRM_CN_Month_End_Date__c <= :strEndBGDate
            AND ASI_CRM_CN_Month__c = 6
            AND ASI_CRM_TYPE__c = 'Budget GS'
            AND ASI_CRM_CM_GS_per_9L__c != 0
            AND ASI_CRM_CM_GS_per_9L__c != NULL
            ORDER BY ASI_CRM_CN_Month_End_Date__c DESC, ASI_CRM_VERSION__c DESC
        ];

        Map<Id, ASI_CRM_CM_GS__c> gsBySubBrandIds = new Map<Id, ASI_CRM_CM_GS__c>();
        for (ASI_CRM_CM_GS__c gs : gsList) {
            // Since the latest GS is already there
            if (gsBySubBrandIds.containsKey(gs.ASI_CRM_PRODUCTCODE__c) || gs.ASI_CRM_CN_Month__c != 6) {
                continue;
            } else {
                gsBySubBrandIds.put(gs.ASI_CRM_PRODUCTCODE__c, gs);
            }
        }

        // Get conversion factor 9L
        List<ASI_MFM_Sub_brand__c> subBrands = [SELECT Id,
                                                       ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c,
                                                       Name,
                                                       ASI_CRM_CN_Sub_brand_Grade__c,
                                                       ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c
                                                FROM ASI_MFM_Sub_brand__c 
                                                WHERE Id IN :subBrandIds];
        Map<Id, Decimal> conversionFactor9LBySubBrandIds = new Map<Id, Decimal>();
        Map<String,ASI_MFM_Sub_brand__c> subBrandMap = new Map<String,ASI_MFM_Sub_brand__c>();

        for (ASI_MFM_Sub_brand__c subBrand : subBrands) {
            conversionFactor9LBySubBrandIds.put(subBrand.Id, subBrand.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_CRM_CN_9L_Conversion_Factor__c);
            subBrandMap.put(subBrand.Id, subBrand);
        }


        Decimal markupPercent = 2;
        Decimal vatPercent = ASI_CRM_CN_CustomSetting__c.getInstance().ASI_CRM_CN_VAT__c != null? ASI_CRM_CN_CustomSetting__c.getInstance().ASI_CRM_CN_VAT__c : 0;

        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c lineItem : lines) {
            ASI_CRM_CM_GS__c gs = gsBySubBrandIds.get(lineItem.ASI_CRM_CN_Sub_Brand__c);
            Decimal gsPer9L = gs == null? 1 : gs.ASI_CRM_CM_GS_per_9L__c;
            Decimal conversionFactor9L = conversionFactor9LBySubBrandIds.get(lineItem.ASI_CRM_CN_Sub_Brand__c);
            conversionFactor9L = conversionFactor9L == null?0:conversionFactor9L;
            lineItem.ASI_CRM_Actual_CM_GS__c = gs == null? null : gs.Id;
            System.debug(LoggingLevel.INFO, '*** gsPer9L: ' + gsPer9L);
            System.debug(LoggingLevel.INFO, '*** conversionFactor9L: ' + conversionFactor9L);
            System.debug(LoggingLevel.INFO, '*** vatPercent: ' + vatPercent);
            System.debug(LoggingLevel.INFO, '*** markupPercent: ' + markupPercent);
            System.debug(LoggingLevel.INFO, '*** lineItem.ASI_CRM_CN_Contract_Total_Dummy__c: ' + lineItem.ASI_CRM_CN_Contract_Total_Dummy__c);

            // Set Contract Monthly QTY (Std. Bottle) +  Contract Total Qty + Est. purchase value
            // 通过销售额算瓶数
            if (lineItem.ASI_CRM_CN_Contract_Total_Dummy__c != null && lineItem.ASI_CRM_CN_Contract_Total_Dummy__c!=0) {
                lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c / (gsPer9L * conversionFactor9L / 9 * (1 + vatPercent/100) * (1 + markupPercent/100)) / iNoMonth;
                System.debug(LoggingLevel.INFO, '*** lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c: ' + lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c);
                lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c.round(System.RoundingMode.FLOOR);
                lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c * iNoMonth;
                lineItem.ASI_CRM_CN_Est_Monthly_Qty__c = lineItem.ASI_CRM_CN_Est_Total_Dummy__c / (gsPer9L * conversionFactor9L / 9 * (1 + vatPercent/100) * (1 + markupPercent/100)) / iNoMonth;
                lineItem.ASI_CRM_CN_Est_Monthly_Qty__c = lineItem.ASI_CRM_CN_Est_Monthly_Qty__c.round(System.RoundingMode.FLOOR);
                lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c = lineItem.ASI_CRM_CN_Est_Monthly_Qty__c * iNoMonth;
            }
            else if (lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c != null && lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c!=0) {
                lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c * iNoMonth;
                lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c.round(System.RoundingMode.FLOOR);
                lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = gsPer9L * conversionFactor9L / 9 * (1 + vatPercent / 100) * lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c * (1 + markupPercent / 100);
                lineItem.ASI_CRM_CN_Est_Monthly_Qty__c = lineItem.ASI_CRM_CN_Contract_Monthly_Qty__c;
                lineItem.ASI_CRM_Est_Total_QTY_std_Btl__c = lineItem.ASI_CRM_Contract_Total_QTY_std_Btl__c;
                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c;
                volumeBase = 'Volume';
            }
                lineItem.ASI_CRM_CN_Contract_Total_Dummy__c = lineItem.ASI_CRM_CN_Contract_Total_Dummy__c.setScale(2, System.RoundingMode.HALF_UP);
                lineItem.ASI_CRM_CN_Est_Total_Dummy__c = lineItem.ASI_CRM_CN_Est_Total_Dummy__c.setScale(2, System.RoundingMode.HALF_UP);
            
            if (SubBrandMap.containsKey(lineItem.ASI_CRM_CN_Sub_Brand__c)) {
                ASI_MFM_Sub_brand__c subBrand = SubBrandMap.get(lineItem.ASI_CRM_CN_Sub_Brand__c);
                lineItem.ASI_CRM_Line_Name__c = subBrand.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c != null? subBrand.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c : subBrand.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                lineItem.ASI_CRM_Sub_Brand_Grade__c = subBrand.ASI_CRM_CN_Sub_brand_Grade__c;
            }
        }
        return volumeBase;

    }

    public static ASI_CRM_Module__c generatePSFModule(Id defaultMethodologyId,
                                                      Id contractId) {
        ASI_CRM_Module__c module = new ASI_CRM_Module__c();
        module.ASI_CRM_Unit__c = 'RMB';
        module.ASI_CRM_Volume_Base__c = 'By Total';
        module.ASI_CRM_CN_Volume_Value_Base__c = 'Value';
        module.ASI_CRM_CN_Contract_Volume_Base__c = 'Outlet Reception Scan';
        module.ASI_CRM_CN_KPI_Base__c = 'Value base';
        module.ASI_CRM_CN_Is_Capped__c = false;
        module.ASI_CRM_Methodology__c = defaultMethodologyId;
        module.ASI_CRM_Contract__c = contractId;
        module.ASI_CRM_Created_PO_Version__c = '0.0';
        module.ASI_CRM_Line_Type__c = 'PSF';
        return module;
    }

    public static Date convertDate(String dateStr) {
        String [] strList = dateStr.split('/');
        return Date.newInstance(Integer.valueOf(strList[0]), Integer.valueOf(strList[1]), Integer.valueOf(strList[2]));
    }


    public static void updateLogStatus(ASI_MFM_Mass_Upload_Log__c log,
                                 ASI_TH_CRM_Contract__c contractSelected,
                                 String status,
                                 String errmsg,
                                 String outletName) {
        String PONO = [SELECT Id, ASI_CRM_CN_PO_No__c 
                                      FROM ASI_TH_CRM_Contract__c WHERE Id =:contractSelected.Id]?.ASI_CRM_CN_PO_No__c;
        log.ASI_CRM_Related_Id__c = contractSelected.Id;
        log.ASI_CRM_Related_Name__c = PONO;
        log.ASI_CRM_Outlet_Name__c = outletName;
        log.ASI_MFM_Status__c = status;
        log.ASI_CRM_Remark__c = errmsg;
        update log;
    }
    global void finish(Database.BatchableContext BC) {
        sendEmailToUser(eventId);
    }

    public static void sendEmailToUser(String eventId) {
        System.debug(LoggingLevel.INFO, '*** eventId: ' + eventId);
        Messaging.SingleEmailMessage[] messages = 
        new List<Messaging.SingleEmailMessage> ();
        String htmlbody = 'Dolphin 合同导入结果';
        htmlbody +='<table style="border: 1px solid black;width:50%;"><thead><tr><th style="border: 1px solid black;width:5%;text-align: center;">#</th><th style="border: 1px solid black;width:5%;text-align: center;">表格PONO</th><th style="border: 1px solid black;width:40%;text-align: center;">Outlet名称</th><th style="border: 1px solid black;width:20%;text-align: center;">状态</th><th style="border: 1px solid black;width:20%;text-align: center;">合同链接</th></tr></thead><tbody>{0}</tbody></table>';
        String tableBody = '';
        List<innerLog> logList = new List<innerLog>();
        for (ASI_MFM_Mass_Upload_Log__c upl : [SELECT Id, ASI_CRM_File_Name__c, ASI_MFM_Name__c,ASI_CRM_Result__c,
                        ASI_MFM_Status__c,ASI_CRM_Remark__c,ASI_CRM_Related_Id__c,ASI_CRM_Related_Name__c,ASI_CRM_Outlet_Name__c
                FROM ASI_MFM_Mass_Upload_Log__c
                WHERE ASI_CRM_File_Name__c=:eventId]) {
                ASI_CRM_CN_DolphinPOUploadCtl.DolphinPO dolPO = (ASI_CRM_CN_DolphinPOUploadCtl.DolphinPO)JSON.deserialize(upl.ASI_CRM_Result__c, ASI_CRM_CN_DolphinPOUploadCtl.DolphinPO.class);
                for (ASI_CRM_CN_DolphinPOUploadCtl.SubbrandInfo sub: dolPO.subbrands) {
                    logList.add(new innerLog(sub.index, dolPO.PONO, upl.ASI_MFM_Status__c, upl.ASI_CRM_Related_Id__c, upl.ASI_CRM_Related_Name__c, upl.ASI_CRM_Outlet_Name__c));
                }
        }
        logList.sort();
        for (innerLog log : logList) {
            tableBody += '<tr><td style="border: 1px solid black;text-align: center;padding:2px;">' +log.index
                         + '</td><td style="border: 1px solid black;text-align: center;padding:2px;">' + log.PONO
                         + '</td><td style="border: 1px solid black;text-align: center;padding:2px;">' + log.outletName
                         + '</td><td style="border: 1px solid black;text-align: center;padding:2px;">' + log.status
                         + '</td><td style="border: 1px solid black;text-align: center;padding:2px;"><a href="' + Url.getSalesforceBaseUrl().toExternalForm()+'/' +log.relatedId
                         + '">' + (log.status == 'Fail'?'':log.relatedName) +'</a></td></tr>';

        }
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { UserInfo.getUserId()};
        message.subject = 'Dolphin 合同导入结果 '+eventId;
        message.htmlbody = String.format(htmlbody,new List<String>{tableBody});
        // message.htmlbody = htmlbody;
        messages.add(message);
        try {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                System.debug(LoggingLevel.INFO, '*** results: ' + results);

        }
        catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }
        
    }

    public class innerLog implements Comparable{
       public Integer index;
       public String PONO;
       public String status;
       public String relatedId;
       public String relatedName;
       public String outletName;
       public innerLog(Integer index, String PONO, String status, String relatedId, String relatedName, String outletName) {
           this.index = index;
           this.PONO = PONO;
           this.status = status;
           this.relatedId = relatedId;
           this.relatedName = relatedName;
           this.relatedName = relatedName;
           this.outletName = outletName;
       }
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            innerLog compareToEmp = (innerLog) compareTo;
            return Integer.valueOf(index - compareToEmp.index);
        }

    }
}